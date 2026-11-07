/**
 * publish-build - read the database once, read-only, and write one new version
 * folder of files into the preview tree. It does not move the preview pointer.
 *
 * Every gate runs before a single file is written. If one fails, no version
 * folder is written and the report says which gate and why.
 *
 *   bun run scripts/publish/build.ts --tree <preview checkout>
 *        [--live-file data/venues.json] [--allow-decrease "ALLOW DECREASE <n>"]
 *        [--note <text>] [--out publish-out] [--version-id <YYYYMMDDTHHMMSSZ>]
 *
 * It never writes to the database: the read is one REPEATABLE READ, READ ONLY
 * transaction, so Postgres itself refuses a write.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

import { connect } from "../ingest/lib/db.ts";
import { Args } from "../ingest/lib/args.ts";
import { canonical, sha256 } from "./lib/canonical.ts";
import { compareLive, type LiveRow } from "./lib/compare.ts";
import { runGates } from "./lib/gates.ts";
import { readSnapshot } from "./lib/read.ts";
import { diffAgainst, reportCsvs, reportMarkdown, type ReportInputs } from "./lib/report.ts";
import { shape } from "./lib/shape.ts";
import {
  KEEP_VERSIONS,
  VERSION_ID,
  contentHash,
  ensureReadme,
  listVersions,
  prune,
  readChannel,
  readManifest,
  versionId,
  writeVersion,
  type Manifest,
} from "./lib/tree.ts";

const USAGE =
  "usage: build.ts --tree <dir> [--live-file data/venues.json] " +
  '[--allow-decrease "ALLOW DECREASE <n>"] [--note <text>] [--out <dir>] [--version-id <id>]';

function writeOut(path: string, body: string): void {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, body, "utf8");
}

function gitSha(explicit: string): string {
  if (explicit) return explicit;
  if (process.env.GITHUB_SHA) return process.env.GITHUB_SHA;
  const r = Bun.spawnSync(["git", "rev-parse", "HEAD"], { stdout: "pipe", stderr: "pipe" });
  return r.exitCode === 0 ? r.stdout.toString().trim() : "unknown";
}

async function main(): Promise<number> {
  const args = new Args(process.argv.slice(2));
  const tree = args.required("tree", USAGE);
  const liveFile = args.optional("live-file", "data/venues.json");
  const allowDecrease = args.optional("allow-decrease");
  const note = args.optional("note") || null;
  const out = args.optional("out", "publish-out");
  const keep = Number(args.optional("keep", String(KEEP_VERSIONS)));
  const builtAt = new Date();
  const id = args.optional("version-id") || versionId(builtAt);
  const sha = gitSha(args.optional("git-sha"));

  if (!VERSION_ID.test(id)) throw new Error(`"${id}" is not a version id (YYYYMMDDTHHMMSSZ).`);
  if (!Number.isInteger(keep) || keep < 2) throw new Error("--keep must be a whole number of 2 or more.");
  mkdirSync(tree, { recursive: true });

  const existing = listVersions(tree);
  const last = existing.length ? existing[existing.length - 1] : null;
  if (last && id <= last) {
    throw new Error(`Version ${id} is not newer than the newest version in the tree (${last}). Nothing was written.`);
  }
  // Read the channel now: an edited-by-hand channel stops the build before the database is read.
  const channel = readChannel(tree);

  console.log(`[publish] version ${id}: reading the database (one read-only transaction)...`);
  const { client, close } = await connect();
  let snap;
  try {
    snap = await readSnapshot(client);
  } finally {
    await close();
  }
  console.log(
    `[publish] read at ${snap.readAt}: ${snap.venues.length} published venues, ${snap.awards.length} award rows, ` +
      `${snap.cities.length} cities, ${snap.slugs.length} slugs. Read only = ${snap.transactionReadOnly}.`,
  );

  const shaped = shape(snap);
  const texts = new Map<string, string>();
  const rows = new Map<string, number>();
  for (const [path, f] of shaped.files) {
    texts.set(path, canonical(f.value));
    rows.set(path, f.rows);
  }

  const lastManifest: Manifest | null = last ? readManifest(tree, last) : null;
  const gates = runGates({
    snap,
    shaped,
    texts,
    lastVenueCount: lastManifest ? lastManifest.counts.venues : null,
    lastVersion: last,
    allowDecrease,
  });
  const pass = gates.every((g) => g.pass);

  let live = null;
  if (existsSync(liveFile)) {
    const liveRows = JSON.parse(readFileSync(liveFile, "utf8")) as LiveRow[];
    live = compareLive(liveRows, snap, shaped);
  }
  const diff = diffAgainst(tree, last, shaped.venues);

  // the folders a successful build would remove, worked out before anything is written
  const after = [...existing, id];
  const protect = new Set([...after.slice(-keep), ...channel.stack.slice(-2)]);
  const willPrune = after.filter((v) => !protect.has(v));

  const dataHashes = [...texts.entries()].map(([path, text]) => ({ path, sha256: sha256(text) }));
  const inputs: ReportInputs = {
    version: id,
    builtAt: builtAt.toISOString().replace(/\.\d{3}Z$/, "Z"),
    gitSha: sha,
    note,
    snap,
    shaped,
    gates,
    diff,
    live,
    liveFile,
    pruned: pass ? willPrune : [],
  };
  const csvs = reportCsvs(inputs);
  const dataBytes = [...texts.values()].reduce((n, t) => n + Buffer.byteLength(t, "utf8"), 0);
  if (pass) {
    inputs.files = {
      count: texts.size + csvs.size + 2,
      dataFiles: texts.size,
      bytes: dataBytes,
      contentSha256: contentHash(dataHashes),
    };
  }
  const md = reportMarkdown(inputs);

  // the report always lands in the out folder, for the run summary and the artifact
  writeOut(join(out, "report.md"), md);
  for (const [path, body] of csvs) writeOut(join(out, path.replace(/^report\//, "")), body);
  writeOut(join(out, "result.json"), canonical({ version: id, pass }, 2));

  if (!pass) {
    console.log(md);
    console.error(`[publish] FAIL: ${gates.filter((g) => !g.pass).map((g) => g.name).join(", ")}. No version written.`);
    return 1;
  }

  texts.set("report/report.md", md);
  for (const [path, body] of csvs) texts.set(path, body);

  const manifest = writeVersion(
    tree,
    id,
    texts,
    (files) => ({
      format: 1,
      version: id,
      built_at: inputs.builtAt,
      git_sha: sha,
      note,
      database: {
        read_at: snap.readAt,
        isolation: snap.isolation,
        transaction_read_only: snap.transactionReadOnly,
        source_capture_ledger_last_id: snap.ledgerLastId,
        audit_log_last_id: snap.auditLastId,
      },
      counts: {
        venues: shaped.counts.venues,
        restaurants: shaped.counts.restaurants,
        bars: shaped.counts.bars,
        city_files: shaped.counts.cityFiles,
        cities: shaped.counts.cities,
        regions: shaped.counts.regions,
        awards: shaped.counts.awards,
        prices: shaped.counts.prices,
        blurbs: shaped.counts.blurbs,
        redirects: shaped.counts.redirects,
      },
      previous_version: last,
      gates,
      content_sha256: contentHash(files),
      data_files: files.filter((f) => !f.path.startsWith("report/")).length,
      files,
    }),
    rows,
  );
  ensureReadme(tree);
  const pruned = prune(tree, keep);

  console.log(md);
  console.log(
    `[publish] PASS: wrote versions/${id} (${manifest.files.length + 1} files, content ${manifest.content_sha256}). ` +
      `Removed from the tree: ${pruned.removed.length ? pruned.removed.join(", ") : "none"}. ` +
      `The preview pointer did not move.`,
  );
  writeOut(join(out, "version.txt"), id + "\n");
  return 0;
}

main().then(
  (code) => process.exit(code),
  (err) => {
    console.error(`[publish] Build failed: ${(err as Error).message}`);
    process.exit(2);
  },
);
