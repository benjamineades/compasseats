import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  renameSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, relative, sep } from "node:path";

import { byCodePoint, canonical, sha256 } from "./canonical.ts";

/**
 * The preview tree: what lives on the `publish-preview` branch.
 *
 *   versions/<version id>/manifest.json   one folder per build
 *   versions/<version id>/...             the files, and report/
 *   channels/preview.json                 which version is the preview now
 *   README.md                             what this branch is
 *
 * No site code lives here, and the live site does not read it.
 */

export const VERSION_ID = /^\d{8}T\d{6}Z$/;
export const MANIFEST = "manifest.json";
export const CHANNEL = "channels/preview.json";
export const KEEP_VERSIONS = 10;

export function versionId(date: Date): string {
  const p = (n: number, w = 2) => String(n).padStart(w, "0");
  return (
    `${p(date.getUTCFullYear(), 4)}${p(date.getUTCMonth() + 1)}${p(date.getUTCDate())}` +
    `T${p(date.getUTCHours())}${p(date.getUTCMinutes())}${p(date.getUTCSeconds())}Z`
  );
}

export function versionDir(tree: string, id: string): string {
  return join(tree, "versions", id);
}

/** Version ids in the tree, oldest first. Only folders with a manifest count. */
export function listVersions(tree: string): string[] {
  const dir = join(tree, "versions");
  if (!existsSync(dir)) return [];
  return readdirSync(dir)
    .filter((d) => VERSION_ID.test(d) && existsSync(join(dir, d, MANIFEST)))
    .sort(byCodePoint);
}

export interface ManifestFile {
  path: string;
  sha256: string;
  bytes: number;
  rows: number | null;
}

export interface Manifest {
  format: 1;
  version: string;
  built_at: string;
  git_sha: string;
  note: string | null;
  database: {
    read_at: string;
    isolation: string;
    transaction_read_only: string;
    source_capture_ledger_last_id: number | null;
    audit_log_last_id: number | null;
  };
  counts: Record<string, number>;
  previous_version: string | null;
  gates: { name: string; pass: boolean; detail: string }[];
  /** sha256 of the sorted "path sha256" lines of the data files - equal builds of one database state give equal values */
  content_sha256: string;
  data_files: number;
  files: ManifestFile[];
}

export function readManifest(tree: string, id: string): Manifest {
  return JSON.parse(readFileSync(join(versionDir(tree, id), MANIFEST), "utf8")) as Manifest;
}

/** The data files: everything a site would read. The report and manifest are about the build, not data. */
export function isDataFile(path: string): boolean {
  return path !== MANIFEST && !path.startsWith("report/");
}

export function contentHash(files: readonly { path: string; sha256: string }[]): string {
  const lines = files
    .filter((f) => isDataFile(f.path))
    .map((f) => `${f.path} ${f.sha256}`)
    .sort(byCodePoint);
  return sha256(lines.join("\n") + "\n");
}

function walk(dir: string): string[] {
  const out: string[] = [];
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) out.push(...walk(full));
    else out.push(full);
  }
  return out;
}

/**
 * Write a whole version folder, or nothing.
 *
 * The files go to a hidden temporary folder first, then one rename puts it in
 * place. A run that dies part way leaves no `versions/<id>` behind, so a
 * half-written version can never be promoted.
 */
export function writeVersion(
  tree: string,
  id: string,
  texts: Map<string, string>,
  makeManifest: (files: ManifestFile[]) => Manifest,
  rows: Map<string, number>,
): Manifest {
  if (!VERSION_ID.test(id)) throw new Error(`"${id}" is not a version id (YYYYMMDDTHHMMSSZ).`);
  const final = versionDir(tree, id);
  if (existsSync(final)) throw new Error(`Version ${id} already exists. Nothing was written.`);
  const tmp = join(tree, "versions", `.tmp-${id}`);
  rmSync(tmp, { recursive: true, force: true });

  const files: ManifestFile[] = [];
  for (const path of [...texts.keys()].sort(byCodePoint)) {
    if (path === MANIFEST || path.includes("..") || path.startsWith("/")) {
      throw new Error(`Refusing to write "${path}" into a version folder.`);
    }
    const text = texts.get(path)!;
    const full = join(tmp, path);
    mkdirSync(dirname(full), { recursive: true });
    writeFileSync(full, text, "utf8");
    files.push({
      path,
      sha256: sha256(text),
      bytes: Buffer.byteLength(text, "utf8"),
      rows: rows.get(path) ?? null,
    });
  }
  const manifest = makeManifest(files);
  writeFileSync(join(tmp, MANIFEST), canonical(manifest, 2), "utf8");
  mkdirSync(dirname(final), { recursive: true });
  renameSync(tmp, final);
  return manifest;
}

/**
 * Check a version folder against its manifest: every listed file is there with
 * the same sha256 and size, no file is there that the manifest does not list,
 * the content hash adds up, and every gate passed. Returns the problems; an
 * empty list means the folder is exactly what the build wrote.
 */
export function verifyVersion(tree: string, id: string): { problems: string[]; manifest: Manifest | null } {
  const dir = versionDir(tree, id);
  const problems: string[] = [];
  if (!existsSync(join(dir, MANIFEST))) {
    return {
      problems: [
        `versions/${id} is not in the tree (or has no manifest). Older versions stay in git history; ` +
          `see docs/publish-job.md, "A version that is no longer in the tree".`,
      ],
      manifest: null,
    };
  }
  let manifest: Manifest;
  try {
    manifest = readManifest(tree, id);
  } catch (err) {
    return { problems: [`versions/${id}/manifest.json does not parse: ${(err as Error).message}`], manifest: null };
  }
  if (manifest.version !== id) problems.push(`manifest names version ${manifest.version}, folder is ${id}`);

  const listed = new Set<string>();
  for (const f of manifest.files) {
    listed.add(f.path);
    const full = join(dir, f.path);
    if (!existsSync(full)) {
      problems.push(`${f.path} is missing`);
      continue;
    }
    const bytes = readFileSync(full);
    if (bytes.length !== f.bytes) problems.push(`${f.path}: ${bytes.length} bytes, manifest says ${f.bytes}`);
    const h = sha256(bytes);
    if (h !== f.sha256) problems.push(`${f.path}: sha256 ${h.slice(0, 12)}..., manifest says ${f.sha256.slice(0, 12)}...`);
  }
  for (const full of walk(dir)) {
    const rel = relative(dir, full).split(sep).join("/");
    if (rel !== MANIFEST && !listed.has(rel)) problems.push(`${rel} is in the folder but not in the manifest`);
  }
  const ch = contentHash(manifest.files);
  if (ch !== manifest.content_sha256) problems.push(`content hash ${ch.slice(0, 12)}... does not match the manifest`);
  const failed = manifest.gates.filter((g) => !g.pass).map((g) => g.name);
  if (failed.length) problems.push(`gates failed at build: ${failed.join(", ")}`);
  return { problems, manifest };
}

/* --------------------------------------------------------------- channel --- */

export interface ChannelEvent {
  action: "promote" | "rollback";
  version: string;
  from: string | null;
  at: string;
  run: string | null;
}

export interface Channel {
  channel: "preview";
  /** the version the preview points at now, or null before the first promote */
  current: string | null;
  /** the promote stack: promote pushes, rollback pops. The last entry is `current`. */
  stack: string[];
  /** every promote and rollback, oldest first, never trimmed */
  history: ChannelEvent[];
}

export function readChannel(tree: string): Channel {
  const path = join(tree, CHANNEL);
  if (!existsSync(path)) return { channel: "preview", current: null, stack: [], history: [] };
  const c = JSON.parse(readFileSync(path, "utf8")) as Channel;
  if (c.stack.length > 0 && c.stack[c.stack.length - 1] !== c.current) {
    throw new Error(
      `${CHANNEL} is inconsistent: current is ${c.current} but the top of the stack is ` +
        `${c.stack[c.stack.length - 1]}. It has been edited by hand. Nothing was changed.`,
    );
  }
  if (c.stack.length === 0 && c.current !== null) {
    throw new Error(`${CHANNEL} is inconsistent: current is ${c.current} but the stack is empty.`);
  }
  return c;
}

export function writeChannel(tree: string, channel: Channel): void {
  const path = join(tree, CHANNEL);
  mkdirSync(dirname(path), { recursive: true });
  const tmp = `${path}.tmp`;
  writeFileSync(tmp, canonical(channel, 2), "utf8");
  renameSync(tmp, path);
}

/**
 * Keep the newest KEEP_VERSIONS folders, plus the version the preview points
 * at and the one a rollback would go back to, whatever their age. Older
 * folders are removed from the tree; every one stays in git history.
 */
export function prune(tree: string, keep = KEEP_VERSIONS): { kept: string[]; removed: string[] } {
  const all = listVersions(tree);
  const channel = readChannel(tree);
  const protect = new Set<string>(all.slice(-keep));
  for (const v of channel.stack.slice(-2)) protect.add(v);
  const removed: string[] = [];
  for (const v of all) {
    if (protect.has(v)) continue;
    rmSync(versionDir(tree, v), { recursive: true, force: true });
    removed.push(v);
  }
  return { kept: all.filter((v) => !removed.includes(v)), removed };
}

export function ensureReadme(tree: string): void {
  const path = join(tree, "README.md");
  if (existsSync(path)) return;
  writeFileSync(
    path,
    [
      "# publish-preview",
      "",
      "Built by the **Publish — build** workflow from the Supabase database. Not site code.",
      "The live site does not read this branch.",
      "",
      "- `versions/<id>/` holds one build: data files, `report/`, and `manifest.json` with the sha256 of every file.",
      "- `channels/preview.json` says which version is the preview now (`current`), and the promote stack a rollback walks back through.",
      "",
      "The manual is `docs/publish-job.md` on the `main` branch.",
      "",
    ].join("\n"),
    "utf8",
  );
}
