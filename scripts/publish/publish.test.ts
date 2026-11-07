import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

import { TEST_DB_URL, buildSchema } from "../ingest/test/harness.ts";
import { connectTo, type Db } from "../ingest/lib/db.ts";
import { byKeys, canonical, sha256 } from "./lib/canonical.ts";
import { GOOGLE_ID, GOOGLE_URL, decreaseOverrideText } from "./lib/gates.ts";
import {
  CHANNEL,
  isDataFile,
  listVersions,
  readChannel,
  readManifest,
  verifyVersion,
  versionDir,
  versionId,
} from "./lib/tree.ts";

/*
 * Every database test runs against a throwaway Postgres built from the repo's
 * canonical schema, the migrations and scripts/publish/test/seed.sql. Never the
 * live project: INGEST_TEST_DB_URL must point at a disposable database.
 */

const REPO = resolve(import.meta.dir, "../..");
const LIVE = join(REPO, "scripts/publish/test/live-venues.json");
const tmp = (p: string) => mkdtempSync(join(tmpdir(), `publish-${p}-`));

interface Run {
  ok: boolean;
  code: number;
  stdout: string;
  stderr: string;
}

async function run(script: "build" | "promote" | "rollback", args: string[]): Promise<Run> {
  const proc = Bun.spawn(["bun", "run", join(REPO, `scripts/publish/${script}.ts`), ...args], {
    cwd: REPO,
    env: { ...process.env, SUPABASE_DB_URL: TEST_DB_URL, GITHUB_SHA: "testsha" },
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
  ]);
  const code = await proc.exited;
  return { ok: code === 0, code, stdout, stderr };
}

function build(tree: string, id: string, extra: string[] = []): Promise<Run> {
  return run("build", [
    "--tree", tree,
    "--version-id", id,
    "--live-file", LIVE,
    "--out", join(tree, "..", `out-${id}`),
    ...extra,
  ]);
}

const readJson = <T>(path: string): T => JSON.parse(readFileSync(path, "utf8")) as T;

let db: Db;
let close: () => Promise<void>;

async function freshDb(): Promise<void> {
  await buildSchema(db, REPO);
  await db.query(readFileSync(join(REPO, "scripts/publish/test/seed.sql"), "utf8"));
}

beforeAll(async () => {
  if (!TEST_DB_URL) throw new Error("INGEST_TEST_DB_URL is not set. Point it at a throwaway Postgres.");
  ({ client: db, close } = await connectTo(TEST_DB_URL));
  await freshDb();
});

afterAll(async () => {
  await close?.();
});

/* ====================================================================== */
/* Pure units - no database                                               */
/* ====================================================================== */

describe("canonical JSON", () => {
  test("sorts keys at every depth and ends with one newline", () => {
    expect(canonical({ b: 1, a: { d: [3, { z: 1, y: 2 }], c: null } })).toBe(
      '{"a":{"c":null,"d":[3,{"y":2,"z":1}]},"b":1}\n',
    );
  });
  test("the same value built in another key order gives the same bytes", () => {
    const one = { x: 1, y: "é", z: [1, 2] };
    const two: Record<string, unknown> = {};
    two.z = [1, 2];
    two.y = "é";
    two.x = 1;
    expect(sha256(canonical(one))).toBe(sha256(canonical(two)));
  });
  test("refuses values it cannot write the same way twice", () => {
    expect(() => canonical({ d: new Date() })).toThrow();
    expect(() => canonical({ n: Number.NaN })).toThrow();
    expect(() => canonical({ b: 1n })).toThrow();
  });
  test("tuple order is code-point order, null first", () => {
    expect(byKeys(["a", 2], ["a", 10])).toBeLessThan(0);
    expect(byKeys([null], ["a"])).toBeLessThan(0);
    expect(byKeys(["Z"], ["a"])).toBeLessThan(0);
  });
});

describe("version ids and the Google pattern", () => {
  test("a version id is UTC time to the second", () => {
    expect(versionId(new Date(Date.UTC(2026, 10, 7, 2, 3, 4)))).toBe("20261107T020304Z");
  });
  test("the Google patterns catch place ids and Google hosts, not ordinary text", () => {
    expect(GOOGLE_ID.test("ChIJSw-GLl2z0hIRX8zyKXltoq8")).toBe(true);
    expect(GOOGLE_URL.test("https://lh3.googleusercontent.com/x")).toBe(true);
    expect(GOOGLE_URL.test("https://maps.google.com/?cid=1")).toBe(true);
    expect(GOOGLE_ID.test("Chijmes Singapore")).toBe(false);
    expect(GOOGLE_URL.test("https://guide.michelin.com/en/paris")).toBe(false);
  });
  test("the decrease override names the new count", () => {
    expect(decreaseOverrideText(11402)).toBe("ALLOW DECREASE 11402");
  });
});

/* ====================================================================== */
/* Build                                                                  */
/* ====================================================================== */

describe("build", () => {
  const tree = join(tmp("build"), "tree");
  const V1 = "20260101T000001Z";
  const V2 = "20260101T000002Z";
  let first: Run;

  beforeAll(async () => {
    await freshDb();
    first = await build(tree, V1);
  });

  test("passes every gate and writes one version folder", () => {
    expect(first.stderr).toBe("");
    expect(first.ok).toBe(true);
    expect(listVersions(tree)).toEqual([V1]);
    expect(first.stdout).toContain("Result: PASS");
  });

  test("the folder is exactly what its manifest lists", () => {
    const { problems, manifest } = verifyVersion(tree, V1);
    expect(problems).toEqual([]);
    expect(manifest!.gates.every((g) => g.pass)).toBe(true);
    expect(manifest!.database.transaction_read_only).toBe("on");
    expect(manifest!.database.isolation).toBe("repeatable read");
    expect(manifest!.git_sha).toBe("testsha");
  });

  test("files and counts: 6 published venues in 4 city files, the closed venue left out", () => {
    const dir = versionDir(tree, V1);
    const index = readJson<{ id: string }[]>(join(dir, "index.json"));
    expect(index.map((r) => r.id).sort()).toEqual([
      "ve_pub0000001", "ve_pub0000002", "ve_pub0000003", "ve_pub0000004", "ve_pub0000006", "ve_pub0000007",
    ]);
    expect(readdirSync(join(dir, "venues")).sort()).toEqual([
      "kyoto.json", "london.json", "osaka.json", "paris.json",
    ]);
    const m = readManifest(tree, V1);
    expect(m.counts.venues).toBe(6);
    expect(m.counts.city_files).toBe(4);
    expect(JSON.stringify(readdirSync(dir))).not.toContain("ghost-town");
    expect(readFileSync(join(dir, "index.json"), "utf8")).not.toContain("ve_pub0000005");
  });

  test("blurbs follow rule Q4; suspended sources and Google values stay out", () => {
    const paris = readJson<{ venues: { id: string; blurb: unknown; awards: unknown[]; price: unknown }[] }>(
      join(versionDir(tree, V1), "venues/paris.json"),
    );
    const gabriel = paris.venues.find((v) => v.id === "ve_pub0000001")!;
    const nouveau = paris.venues.find((v) => v.id === "ve_pub0000002")!;
    expect(gabriel.blurb).toEqual({ short: "A short line.", long: "A longer paragraph.", version: 1 });
    expect(nouveau.blurb).toBeNull();
    expect(gabriel.awards.length).toBe(3);
    expect(gabriel.price).toEqual({ tier: 4, symbol: "€€€€", currency: "EUR", publisher: "michelin" });

    const kyoto = readJson<{ venues: { name_native: string; awards: { source: string }[] }[] }>(
      join(versionDir(tree, V1), "venues/kyoto.json"),
    );
    expect(kyoto.venues[0].name_native).toBe("菊乃井");
    expect(kyoto.venues[0].awards.map((a) => a.source)).toEqual(["michelin"]);

    const attribution = readJson<{ source: string }[]>(join(versionDir(tree, V1), "attribution.json"));
    expect(attribution.map((a) => a.source)).not.toContain("wine-spectator");

    for (const f of verifyVersion(tree, V1).manifest!.files) {
      if (!isDataFile(f.path)) continue;
      const text = readFileSync(join(versionDir(tree, V1), f.path), "utf8");
      expect(GOOGLE_ID.test(text)).toBe(false);
    }
  });

  test("awards inside a venue are in a fixed order: source, newest year, rank", () => {
    const paris = readJson<{ venues: { id: string; awards: { source: string; year: number }[] }[] }>(
      join(versionDir(tree, V1), "venues/paris.json"),
    );
    const g = paris.venues.find((v) => v.id === "ve_pub0000001")!;
    expect(g.awards.map((a) => `${a.source} ${a.year}`)).toEqual(["michelin 2026", "michelin 2025", "oad 2026"]);
  });

  test("redirects: the table row and the old slug of a published venue, not of a closed one", () => {
    const r = readJson<{ from: string; to: string; kind: string }[]>(join(versionDir(tree, V1), "redirects.json"));
    expect(r).toEqual([
      { from: "/osaka/fujiya-1935", kind: "old_slug", to: "/osaka/fujiya" },
      { from: "/paris/gabriel", kind: "redirect", to: "/paris/le-gabriel" },
    ]);
  });

  test("city and region counts are made by the job, and the stored count difference is reported", () => {
    const cities = readJson<{ slug: string; venue_count: number; region: string | null }[]>(
      join(versionDir(tree, V1), "cities.json"),
    );
    expect(cities.find((c) => c.slug === "london")!.venue_count).toBe(2);
    expect(cities.find((c) => c.slug === "kyoto")!.region).toBe("kansai");
    const regions = readJson<{ slug: string; display: string; city_count: number; cities: string[]; venue_count: number }[]>(
      join(versionDir(tree, V1), "regions.json"),
    );
    expect(regions).toEqual([{ slug: "kansai", display: "Kansai", city_count: 2, venue_count: 2, cities: ["kyoto", "osaka"] }]);
    const counts = readFileSync(join(versionDir(tree, V1), "report/city-counts.csv"), "utf8");
    expect(counts).toContain("london,3,2");
  });

  test("the live compare puts each live page in one group", () => {
    const report = readFileSync(join(versionDir(tree, V1), "report/report.md"), "utf8");
    const csv = readFileSync(join(versionDir(tree, V1), "report/compare-live.csv"), "utf8");
    // population: 5 active rows in the fixture; the closed row is not a page
    expect(report).toContain("the 5 live pages");
    expect(csv).toContain("same_address,,/paris/le-gabriel");
    expect(csv).toContain("same_address,yes,/paris/bar-nouveau");
    expect(csv).toContain("old_slug,,/osaka/fujiya-1935");
    expect(csv).toContain("closed_in_database,,/london/closed-spot");
    expect(csv).toContain("no_slug_row,,/london/unknown-place");
    expect((csv.match(/^no_live_page/gm) ?? []).length).toBe(4);
    expect(csv).not.toContain("ChIJ");
  });

  test("the build writes nothing to the database", async () => {
    const before = await db.query<{ a: string; l: string; n: string }>(
      `select (select max(id) from audit_log)::text a, (select max(id) from source_capture_ledger)::text l,
              (select count(*) from awards)::text n`,
    );
    const again = await build(tree, "20260101T000005Z");
    expect(again.ok).toBe(true);
    const after = await db.query<{ a: string; l: string; n: string }>(
      `select (select max(id) from audit_log)::text a, (select max(id) from source_capture_ledger)::text l,
              (select count(*) from awards)::text n`,
    );
    expect(after.rows[0]).toEqual(before.rows[0]);
    const m = readManifest(tree, "20260101T000005Z");
    expect(m.database.audit_log_last_id).toBe(Number(before.rows[0].a));
    expect(m.database.source_capture_ledger_last_id).toBe(Number(before.rows[0].l));
  });

  test("one database state gives the same bytes: a second build has the same data files", async () => {
    const tree2 = join(tmp("determinism"), "tree");
    const a = await build(tree2, V1);
    const b = await build(tree2, V2);
    expect(a.ok && b.ok).toBe(true);
    const m1 = readManifest(tree2, V1);
    const m2 = readManifest(tree2, V2);
    const data = (m: typeof m1) => m.files.filter((f) => isDataFile(f.path)).map((f) => `${f.path} ${f.sha256}`);
    expect(data(m2)).toEqual(data(m1));
    expect(m2.content_sha256).toBe(m1.content_sha256);
    expect(m2.previous_version).toBe(V1);
    expect(readFileSync(join(versionDir(tree2, V2), "report/report.md"), "utf8")).toContain(
      "Added 0, removed 0, changed 0, same 6",
    );
  });

  test("a version id that is not newer than the newest one is refused", async () => {
    const r = await build(tree, "20250101T000000Z");
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("is not newer");
  });
});

/* ====================================================================== */
/* Gates: a failed gate writes no version                                 */
/* ====================================================================== */

describe("gates", () => {
  async function failsWith(sql: string, gate: string, undo: string): Promise<Run> {
    const tree = join(tmp("gate"), "tree");
    await db.query(sql);
    try {
      const r = await build(tree, "20260201T000000Z");
      expect(r.ok).toBe(false);
      expect(r.code).toBe(1);
      expect(r.stdout).toContain("Result: FAIL");
      expect(r.stdout).toMatch(new RegExp("`" + gate + "` \\| \\*\\*FAIL\\*\\*"));
      expect(listVersions(tree)).toEqual([]);
      expect(existsSync(join(tree, "versions"))).toBe(false);
      expect(existsSync(join(tree, "..", "out-20260201T000000Z", "report.md"))).toBe(true);
      return r;
    } finally {
      await db.query(undo);
    }
  }

  beforeAll(freshDb);

  test("a closed venue with a published listing", async () => {
    await failsWith(
      `update listings set published = true where venue_id = 've_pub0000005'`,
      "no_closed_venue",
      `update listings set published = false where venue_id = 've_pub0000005'`,
    );
  });

  test("two Michelin rows of one year and category on one venue", async () => {
    await failsWith(
      `insert into awards (venue_id, source_id, year, category, distinction) values ('ve_pub0000001','michelin',2026,'Three Stars','x')`,
      "no_duplicate_michelin",
      `delete from awards where venue_id = 've_pub0000001' and distinction = 'x'`,
    );
  });

  test("a venue with two canonical slugs", async () => {
    await failsWith(
      `insert into slugs (property_id, city_slug, slug, venue_id, is_canonical) values ('eats','london','tallow-2','ve_pub0000006',true)`,
      "one_canonical_slug",
      `delete from slugs where slug = 'tallow-2'`,
    );
  });

  test("a Google value in the files", async () => {
    await failsWith(
      `update awards set source_url = 'https://maps.google.com/?cid=123' where venue_id = 've_pub0000006'`,
      "no_google_value",
      `update awards set source_url = 'https://top500bars.com/2026' where venue_id = 've_pub0000006'`,
    );
  });

  test("an old slug the redirects table already sends to the same page is written once", async () => {
    const tree = join(tmp("folded"), "tree");
    await db.query(`insert into redirects (from_path, to_path) values ('/osaka/fujiya-1935', '/osaka/fujiya')`);
    try {
      const r = await build(tree, "20260201T000002Z");
      expect(r.ok).toBe(true);
      const rows = readJson<{ from: string; kind: string }[]>(join(versionDir(tree, "20260201T000002Z"), "redirects.json"));
      expect(rows.filter((x) => x.from === "/osaka/fujiya-1935")).toEqual([
        { from: "/osaka/fujiya-1935", kind: "redirect", to: "/osaka/fujiya" } as never,
      ]);
      expect(r.stdout).toContain("| Old slugs the redirects table already sends to the same page | 1 |");
    } finally {
      await db.query(`delete from redirects where from_path = '/osaka/fujiya-1935'`);
    }
  });

  test("an old address with two different answers", async () => {
    await failsWith(
      `insert into redirects (from_path, to_path) values ('/osaka/fujiya-1935', '/paris/le-gabriel')`,
      "redirect_from_unique",
      `delete from redirects where from_path = '/osaka/fujiya-1935'`,
    );
  });

  test("an award from a suspended source never reaches the files (it is left out, not failed)", async () => {
    const tree = join(tmp("suspended"), "tree");
    const r = await build(tree, "20260201T000001Z");
    expect(r.ok).toBe(true);
    expect(r.stdout).toContain("| Award rows from a source that is not active | 1 |");
  });

  test("a fall of more than 0.5% needs the exact typed override", async () => {
    const tree = join(tmp("decrease"), "tree");
    expect((await build(tree, "20260301T000001Z")).ok).toBe(true);
    await db.query(`update listings set published = false where venue_id = 've_pub0000007'`);
    try {
      const plain = await build(tree, "20260301T000002Z");
      expect(plain.ok).toBe(false);
      expect(plain.stdout).toContain('type exactly "ALLOW DECREASE 5"');
      expect(listVersions(tree)).toEqual(["20260301T000001Z"]);

      const wrong = await build(tree, "20260301T000003Z", ["--allow-decrease", "ALLOW DECREASE 6"]);
      expect(wrong.ok).toBe(false);

      const right = await build(tree, "20260301T000004Z", ["--allow-decrease", "ALLOW DECREASE 5"]);
      expect(right.ok).toBe(true);
      expect(readManifest(tree, "20260301T000004Z").counts.venues).toBe(5);
    } finally {
      await db.query(`update listings set published = true where venue_id = 've_pub0000007'`);
    }
  });
});

/* ====================================================================== */
/* Promote and rollback                                                   */
/* ====================================================================== */

describe("promote and rollback", () => {
  const tree = join(tmp("channel"), "tree");
  const A = "20260401T000001Z";
  const B = "20260401T000002Z";
  const C = "20260401T000003Z";
  const promote = (v: string, confirm: string, extra: string[] = []) =>
    run("promote", ["--tree", tree, "--version", v, "--confirm", confirm, ...extra]);
  const rollback = (confirm: string, extra: string[] = []) =>
    run("rollback", ["--tree", tree, "--confirm", confirm, ...extra]);

  beforeAll(async () => {
    await freshDb();
    for (const v of [A, B, C]) expect((await build(tree, v)).ok).toBe(true);
  });

  test("building never moves the pointer", () => {
    expect(existsSync(join(tree, CHANNEL))).toBe(false);
    expect(readChannel(tree).current).toBeNull();
  });

  test("promote refuses anything but the exact confirmation", async () => {
    for (const bad of ["", `PUBLISH ${B}`, `publish ${A}`, `PUBLISH ${A} `, "PUBLISH"]) {
      const r = await promote(A, bad);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain(`must read exactly "PUBLISH ${A}"`);
    }
    expect(existsSync(join(tree, CHANNEL))).toBe(false);
  });

  test("a repeated --confirm is an error, not first-one-wins", async () => {
    const r = await run("promote", ["--tree", tree, "--version", A, "--confirm", `PUBLISH ${A}`, "--confirm", `PUBLISH ${A}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("more than once");
  });

  test("a dry run checks everything and changes nothing", async () => {
    const r = await promote(A, `PUBLISH ${A}`, ["--dry-run"]);
    expect(r.ok).toBe(true);
    expect(r.stdout).toContain("Dry run");
    expect(existsSync(join(tree, CHANNEL))).toBe(false);
  });

  test("promote points the preview at the version, after its hash check", async () => {
    const r = await promote(A, `PUBLISH ${A}`);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);
    expect(readChannel(tree)).toMatchObject({ current: A, stack: [A] });
  });

  test("promoting the current version again is safe and changes nothing", async () => {
    const before = readFileSync(join(tree, CHANNEL), "utf8");
    const r = await promote(A, `PUBLISH ${A}`);
    expect(r.ok).toBe(true);
    expect(r.stdout).toContain("already the preview");
    expect(readFileSync(join(tree, CHANNEL), "utf8")).toBe(before);
  });

  test("a changed file in the version stops the promote", async () => {
    const file = join(versionDir(tree, C), "cities.json");
    const good = readFileSync(file, "utf8");
    writeFileSync(file, good.replace("London", "Londres"));
    try {
      const r = await promote(C, `PUBLISH ${C}`);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("cities.json: sha256");
      expect(readChannel(tree).current).toBe(A);
    } finally {
      writeFileSync(file, good);
    }
  });

  test("an extra file in the version stops the promote", async () => {
    const extra = join(versionDir(tree, C), "venues/extra.json");
    writeFileSync(extra, "[]\n");
    try {
      const r = await promote(C, `PUBLISH ${C}`);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("venues/extra.json is in the folder but not in the manifest");
    } finally {
      Bun.spawnSync(["rm", extra]);
    }
  });

  test("rollback with only one version promoted has nowhere to go", async () => {
    const r = await rollback(`ROLLBACK ${A}`);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("no earlier version");
  });

  test("rollback goes back one promote at a time, and only with the exact confirmation", async () => {
    expect((await promote(B, `PUBLISH ${B}`)).ok).toBe(true);
    expect((await promote(C, `PUBLISH ${C}`)).ok).toBe(true);
    expect(readChannel(tree)).toMatchObject({ current: C, stack: [A, B, C] });

    // the confirmation names the version the preview points at now
    const wrong = await rollback(`ROLLBACK ${B}`);
    expect(wrong.ok).toBe(false);
    expect(wrong.stderr).toContain(`must read exactly "ROLLBACK ${C}"`);

    const dry = await rollback(`ROLLBACK ${C}`, ["--dry-run"]);
    expect(dry.ok).toBe(true);
    expect(readChannel(tree).current).toBe(C);

    const one = await rollback(`ROLLBACK ${C}`);
    expect(one.stderr).toBe("");
    expect(one.ok).toBe(true);
    expect(readChannel(tree)).toMatchObject({ current: B, stack: [A, B] });

    const two = await rollback(`ROLLBACK ${B}`);
    expect(two.ok).toBe(true);
    expect(readChannel(tree)).toMatchObject({ current: A, stack: [A] });

    const h = readChannel(tree).history.map((e) => `${e.action} ${e.version} from ${e.from}`);
    expect(h).toEqual([
      `promote ${A} from null`,
      `promote ${B} from ${A}`,
      `promote ${C} from ${B}`,
      `rollback ${B} from ${C}`,
      `rollback ${A} from ${B}`,
    ]);
  });

  test("rollback refuses when the version it goes back to fails its hash check", async () => {
    expect((await promote(B, `PUBLISH ${B}`)).ok).toBe(true);
    const file = join(versionDir(tree, A), "index.json");
    const good = readFileSync(file, "utf8");
    writeFileSync(file, good + " ");
    try {
      const r = await rollback(`ROLLBACK ${B}`);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("did not pass its hash check");
      expect(readChannel(tree).current).toBe(B);
    } finally {
      writeFileSync(file, good);
    }
  });

  test("a channel file edited by hand stops every button", async () => {
    const path = join(tree, CHANNEL);
    const good = readFileSync(path, "utf8");
    writeFileSync(path, good.replace(`"current": "${B}"`, `"current": "${C}"`));
    try {
      const r = await rollback(`ROLLBACK ${C}`);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("edited by hand");
    } finally {
      writeFileSync(path, good);
    }
  });
});

/* ====================================================================== */
/* Keeping the last versions                                              */
/* ====================================================================== */

describe("pruning", () => {
  test("keeps the newest versions plus the current and the rollback target, whatever their age", async () => {
    await freshDb();
    const tree = join(tmp("prune"), "tree");
    const ids = [1, 2, 3, 4, 5, 6].map((n) => `20260501T00000${n}Z`);
    expect((await build(tree, ids[0], ["--keep", "3"])).ok).toBe(true);
    expect((await build(tree, ids[1], ["--keep", "3"])).ok).toBe(true);
    expect((await run("promote", ["--tree", tree, "--version", ids[0], "--confirm", `PUBLISH ${ids[0]}`])).ok).toBe(true);
    expect((await run("promote", ["--tree", tree, "--version", ids[1], "--confirm", `PUBLISH ${ids[1]}`])).ok).toBe(true);
    for (const id of ids.slice(2)) expect((await build(tree, id, ["--keep", "3"])).ok).toBe(true);
    // newest 3 are 4, 5, 6; the stack protects 1 (rollback target) and 2 (current); 3 goes
    expect(listVersions(tree)).toEqual([ids[0], ids[1], ids[3], ids[4], ids[5]]);
    const last = readFileSync(join(versionDir(tree, ids[5]), "report/report.md"), "utf8");
    expect(last).toContain("Removed from the tree");
  });
});
