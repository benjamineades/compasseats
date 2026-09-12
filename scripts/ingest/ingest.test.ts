import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

import { TEST_DB_URL, buildTestDb, counts, verdicts } from "./test/harness.ts";
import type { Db } from "./lib/db.ts";
import { parseCsv, parseCsvRecords, toCsv } from "./lib/csv.ts";
import { disambiguate, mintVenueId, slugify } from "./lib/slug.ts";

const REPO = resolve(import.meta.dir, "../..");
const OUT = mkdtempSync(join(tmpdir(), "ingest-reports-"));

interface Run {
  ok: boolean;
  stdout: string;
  stderr: string;
}

async function run(script: "stage" | "promote", args: string[]): Promise<Run> {
  const proc = Bun.spawn(
    ["bun", "run", join(REPO, `scripts/ingest/${script}.ts`), ...args, "--out", OUT],
    {
      cwd: REPO,
      env: { ...process.env, SUPABASE_DB_URL: TEST_DB_URL },
      stdout: "pipe",
      stderr: "pipe",
    },
  );
  const [stdout, stderr] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
  ]);
  const code = await proc.exited;
  return { ok: code === 0, stdout, stderr };
}

const fixture = (name: string) => join(REPO, "scripts/ingest/test", name);
const report = (name: string) => readFileSync(join(OUT, name), "utf8");

/* ====================================================================== */
/* Pure units - no database                                               */
/* ====================================================================== */

describe("csv", () => {
  test("handles quotes, embedded commas and newlines", () => {
    const text = 'a,b,c\n1,"two, and a half","line\none"\n"say ""hi""",x,y\n';
    const { header, rows } = parseCsv(text);
    expect(header).toEqual(["a", "b", "c"]);
    expect(rows).toEqual([
      ["1", "two, and a half", "line\none"],
      ['say "hi"', "x", "y"],
    ]);
  });

  test("strips a BOM and survives a round trip", () => {
    const { records } = parseCsvRecords("﻿a,b\n1,2\n");
    expect(records).toEqual([{ a: "1", b: "2" }]);
    const round = parseCsvRecords(toCsv(["a", "b"], [{ a: 'x"y', b: "p,q" }]));
    expect(round.records).toEqual([{ a: 'x"y', b: "p,q" }]);
  });
});

describe("slug and id minting", () => {
  test("matches the house convention", () => {
    expect(slugify("Le Manoir aux Quat’Saisons", "oxford")).toBe("le-manoir-aux-quat-saisons");
    expect(slugify("Café Arixi", "mexico-city")).toBe("cafe-arixi");
    expect(slugify("Ralph's Bar", "chengdu")).toBe("ralph-s-bar");
    expect(slugify("La Cúpula de El Capricho", "jimenez-de-jamuz")).toBe(
      "la-cupula-de-el-capricho",
    );
  });

  test("falls back deterministically when a name slugifies to nothing", () => {
    const a = slugify("台処 かみ谷", "osaka");
    const b = slugify("台処 かみ谷", "osaka");
    expect(a).toBe(b);
    expect(a.startsWith("osaka-")).toBe(true);
  });

  test("the incumbent keeps its slug", () => {
    expect(disambiguate("brine", new Set(["brine"]))).toBe("brine-2");
    expect(disambiguate("brine", new Set(["brine", "brine-2"]))).toBe("brine-3");
    expect(disambiguate("brine", new Set())).toBe("brine");
  });

  test("venue id is the Batch D mint rule", () => {
    // 've_' || left(md5(city_slug || ':' || slug), 10)
    const hasher = new Bun.CryptoHasher("md5");
    hasher.update("paris:guy-savoy");
    expect(mintVenueId("paris", "guy-savoy")).toBe(`ve_${hasher.digest("hex").slice(0, 10)}`);
    expect(mintVenueId("paris", "guy-savoy")).toMatch(/^ve_[a-z0-9]{10}$/);
  });
});

/* ====================================================================== */
/* Against a throwaway database                                           */
/* ====================================================================== */

const skip = TEST_DB_URL === "";
if (skip) {
  console.warn("INGEST_TEST_DB_URL is not set - database tests skipped.");
}

describe.skipIf(skip)("stage and promote", () => {
  let db: Db;
  let close: () => Promise<void>;

  beforeAll(async () => {
    const built = await buildTestDb(REPO);
    db = built.db;
    close = built.close;
  });
  afterAll(async () => {
    await close();
  });

  /* ---------------- the acceptance batch ---------------- */

  test("the acceptance batch stages clean: 10 rows, 8 venues, 0 rejects, 0 review", async () => {
    const key = "first-batch-2026-09";
    const r = await run("stage", [
      "--csv",
      join(REPO, "fixtures/ingest/first-batch-2026-09.csv"),
      "--batch-key",
      key,
    ]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    expect(await verdicts(db, key)).toEqual({ new_venue: 10 });

    const md = report(`${key}-stage.md`);
    expect(md).toContain("| venues | 7 | 15 | +8 |");
    expect(md).toContain("| awards | 3 | 13 | +10 |");
    expect(md).toContain("| listings | 7 | 15 | +8 |");
    expect(md).toContain("| slugs | 7 | 15 | +8 |");
    // 8 new venues x (city_display + country)
    expect(md).toContain("| city_label_source | 0 | 16 | +16 |");
    expect(md).toContain("| price | 0 | 0 | +0 |");
    expect(md).toContain("| source_capture_ledger | 0 | 10 | +10 |");
    // the rank-1 clash with the seeded steakhouse award is surfaced
    expect(md).toContain("Ranks another venue already holds");
    expect(md).toContain("PROMOTE first-batch-2026-09");

    // nothing touched the live tables
    const c = await counts(db);
    expect(c.venues).toBe(7);
    expect(c.awards).toBe(3);
    expect(c.ingest_rows).toBe(10);
  });

  test("re-staging the same key is a no-op", async () => {
    const key = "first-batch-2026-09";
    const before = await counts(db);
    const r = await run("stage", [
      "--csv",
      join(REPO, "fixtures/ingest/first-batch-2026-09.csv"),
      "--batch-key",
      key,
    ]);
    expect(r.ok).toBe(true);
    expect(r.stdout).toContain("no-op");
    expect(await counts(db)).toEqual(before);
  });

  test("promote refuses without the exact confirmation", async () => {
    for (const wrong of ["PROMOTE", "promote first-batch-2026-09", "PROMOTE wrong-key", ""]) {
      const r = await run("promote", ["--batch-key", "first-batch-2026-09", "--confirm", wrong]);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("Nothing was promoted");
    }
    const c = await counts(db);
    expect(c.venues).toBe(7);
  });

  test("a dry run checks every invariant and changes nothing", async () => {
    const key = "first-batch-2026-09";
    const before = await counts(db);
    const r = await run("promote", [
      "--batch-key",
      key,
      "--confirm",
      `PROMOTE ${key}`,
      "--dry-run",
    ]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const md = report(`${key}-promote.md`);
    expect(md).toContain("Dry run - rolled back");
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("| venues | 7 | 15 | 15 |");
    expect(md).toContain("| awards | 3 | 13 | 13 |");

    expect(await counts(db)).toEqual(before);
  });

  test("promote lands the batch and the arithmetic holds", async () => {
    const key = "first-batch-2026-09";
    const r = await run("promote", ["--batch-key", key, "--confirm", `PROMOTE ${key}`]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const c = await counts(db);
    expect(c.venues).toBe(15);
    expect(c.awards).toBe(13);
    expect(c.listings).toBe(15);
    expect(c.slugs).toBe(15);
    expect(c.city_label_source).toBe(16);
    expect(c.price).toBe(0);
    expect(c.source_capture_ledger).toBe(10);

    // Guy Savoy: three award rows, one venue
    const { rows } = await db.query<{ n: string; id: string; slug: string }>(
      `select count(*)::text n, v.id, s.slug
         from venues v join awards a on a.venue_id = v.id
         join slugs s on s.venue_id = v.id
        where v.name = 'Guy Savoy' group by v.id, s.slug`,
    );
    expect(rows.length).toBe(1);
    expect(Number(rows[0].n)).toBe(3);
    expect(rows[0].slug).toBe("guy-savoy");
    expect(rows[0].id).toBe(mintVenueId("paris", "guy-savoy"));

    // every new award carries a source_url and no competitor host
    const { rows: bad } = await db.query<{ n: string }>(
      `select count(*)::text n from awards
        where source_url is null or btrim(source_url) = '' or source_url ilike '%joinpearl%'`,
    );
    expect(Number(bad[0].n)).toBe(0);

    // the ledger names the batch
    const { rows: led } = await db.query<{ n: string }>(
      `select count(*)::text n from source_capture_ledger where job = $1`,
      [`ingest-promote:${key}`],
    );
    expect(Number(led[0].n)).toBe(10);

    // city_label_source carries the batch key
    const { rows: lab } = await db.query<{ n: string }>(
      `select count(*)::text n from city_label_source where note = $1`,
      [key],
    );
    expect(Number(lab[0].n)).toBe(16);
  });

  test("re-promoting the same key is a no-op", async () => {
    const key = "first-batch-2026-09";
    const before = await counts(db);
    const r = await run("promote", ["--batch-key", key, "--confirm", `PROMOTE ${key}`]);
    expect(r.ok).toBe(true);
    expect(r.stdout).toContain("no-op");
    expect(await counts(db)).toEqual(before);
  });

  /* ---------------- the validation cases ---------------- */

  test("every verdict class lands where it should", async () => {
    const key = "cases-2026-09";
    const r = await run("stage", ["--csv", fixture("cases.csv"), "--batch-key", key]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const { rows } = await db.query<{ line: number; verdict: string; reason: string | null }>(
      `select (r.raw->>'_line')::int as line, r.verdict, r.validation->>'reason' as reason
         from ingest_rows r join ingest_batches b on b.id = r.batch_id
        where b.batch_key = $1 order by 1`,
      [key],
    );
    const byLine = new Map(rows.map((r) => [Number(r.line), r]));
    const at = (n: number) => byLine.get(n) as { verdict: string; reason: string | null };

    expect(at(1)).toMatchObject({ verdict: "reject", reason: "source_not_registered" });
    expect(at(2)).toMatchObject({ verdict: "reject", reason: "source_suspended" });
    expect(at(3)).toMatchObject({ verdict: "reject", reason: "missing_source_url" });
    expect(at(4)).toMatchObject({ verdict: "reject", reason: "competitor_source_url" });
    expect(at(5)).toMatchObject({ verdict: "reject", reason: "year_out_of_range" });
    expect(at(6)).toMatchObject({ verdict: "reject", reason: "rank_not_positive" });
    expect(at(7)).toMatchObject({ verdict: "reject", reason: "unknown_category" });
    expect(at(8)).toMatchObject({ verdict: "review_city", reason: "city_not_found" });
    expect(at(9)).toMatchObject({ verdict: "review_venue", reason: "venue_ambiguous_in_city" });
    expect(at(10)).toMatchObject({ verdict: "duplicate", reason: "duplicate_of_existing_award" });
    expect(at(11).verdict).toBe("match");
    expect(at(12)).toMatchObject({ verdict: "subsumed", reason: "subsumed_by_higher_distinction" });
    expect(at(13).verdict).toBe("new_venue");
    expect(at(14)).toMatchObject({ verdict: "review_venue", reason: "norm_key_too_short" });
    expect(at(15)).toMatchObject({ verdict: "duplicate", reason: "duplicate_in_batch" });
    expect(at(16)).toMatchObject({ verdict: "review_city", reason: "city_ambiguous" });
    expect(at(17).verdict).toBe("new_venue"); // the country hint disambiguated it
    expect(at(18).verdict).toBe("new_venue");
    expect(at(19)).toMatchObject({ verdict: "review_venue", reason: "same_key_other_city" });
    expect(at(20)).toMatchObject({ verdict: "review_city", reason: "country_label_disagrees" });
    expect(at(21)).toMatchObject({ verdict: "reject", reason: "missing_venue_name" });

    const review = readFileSync(join(OUT, `${key}-review.csv`), "utf8");
    const { records } = parseCsvRecords(review);
    expect(records.map((x) => x.line).sort()).toEqual(["14", "16", "19", "20", "8", "9"]);
    expect(records.find((x) => x.line === "9")?.candidates).toContain("use:ve_bbbbbbbbb2");
    expect(records.find((x) => x.line === "19")?.candidates).toContain("use:ve_ggggggggg7");
  });

  test("promote refuses while any review row remains", async () => {
    const key = "cases-2026-09";
    const before = await counts(db);
    const r = await run("promote", ["--batch-key", key, "--confirm", `PROMOTE ${key}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("still in review");
    expect(await counts(db)).toEqual(before);
  });

  test("review decisions overwrite verdicts for those rows only", async () => {
    const key = "cases-2026-09";
    const r = await run("stage", [
      "--csv",
      fixture("cases.csv"),
      "--batch-key",
      key,
      "--decisions",
      fixture("decisions.csv"),
    ]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const v = await verdicts(db, key);
    expect(v.review_city ?? 0).toBe(0);
    expect(v.review_venue ?? 0).toBe(0);
    expect(v.skipped).toBe(2); // lines 8 and 20
    expect(v.reject).toBe(8); // untouched
  });

  test("the decided batch promotes, and the -2 slug rule protects the incumbent", async () => {
    const key = "cases-2026-09";
    const before = await counts(db);
    const r = await run("promote", ["--batch-key", key, "--confirm", `PROMOTE ${key}`]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const after = await counts(db);
    // new venues: Brine (decision new), Ao (decision new), Sea Fret,
    // Twin Peak x2 (San Jose CA and CR), Shuttered Place, Aurum => 7
    expect(after.venues - before.venues).toBe(7);
    expect(after.listings - before.listings).toBe(7);
    expect(after.slugs - before.slugs).toBe(7);
    // awards: line 11 (match) plus the seven new_venue rows => 8
    expect(after.awards - before.awards).toBe(8);
    // city_label_source: two labels each, except Twin Peak (CA) which has no
    // country label => 13
    expect(after.city_label_source - before.city_label_source).toBe(13);

    // the two London Brines keep their slugs; the newcomer takes the next one
    const { rows: brine } = await db.query<{ slug: string; city_slug: string }>(
      `select s.slug, s.city_slug from slugs s join venues v on v.id = s.venue_id
        where v.name = 'Brine' and s.city_slug = 'london' order by s.slug`,
    );
    expect(brine.map((b) => b.slug)).toEqual(["brine", "brine-2", "brine-3"]);

    // the closed venue landed unpublished
    const { rows: closed } = await db.query<{ published: boolean; status: string }>(
      `select l.published, v.status::text as status from venues v
         join listings l on l.venue_id = v.id where v.name = 'Shuttered Place'`,
    );
    expect(closed[0]).toMatchObject({ published: false, status: "closed" });

    // michelin is not price_capable, so the $$$ on line 18 wrote nothing
    expect(after.price).toBe(0);
  });

  /* ---------------- staged-then-stale ---------------- */

  test("a second staged batch that has gone stale refuses to promote", async () => {
    // Two batches staged before either promotes, both naming the same new venue.
    // Both stage reports predict the same venue id. Promoting the first makes
    // the second's plan wrong, and it must refuse rather than create a twin.
    const csv = join(OUT, "stale.csv");
    const header =
      "batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note\n";
    const row = (key: string) =>
      `${key},michelin,2026,,One Star,,https://guide.michelin.com/x,Twin Stack,London,United Kingdom,restaurant,,,\n`;

    await Bun.write(csv, header + row("stale-a"));
    expect((await run("stage", ["--csv", csv, "--batch-key", "stale-a"])).ok).toBe(true);
    await Bun.write(csv, header + row("stale-b"));
    expect((await run("stage", ["--csv", csv, "--batch-key", "stale-b"])).ok).toBe(true);

    expect(
      (await run("promote", ["--batch-key", "stale-a", "--confirm", "PROMOTE stale-a"])).ok,
    ).toBe(true);

    const before = await counts(db);
    const second = await run("promote", ["--batch-key", "stale-b", "--confirm", "PROMOTE stale-b"]);
    expect(second.ok).toBe(false);
    expect(second.stderr).toContain("already exists");
    expect(second.stderr).toContain("Re-stage under a NEW batch key");
    expect(await counts(db)).toEqual(before);

    // exactly one Twin Stack, not two
    const { rows } = await db.query<{ n: string }>(
      `select count(*)::text n from venues where name = 'Twin Stack'`,
    );
    expect(Number(rows[0].n)).toBe(1);
  });

  test("a repeated --confirm is refused, not first-one-wins", async () => {
    const before = await counts(db);
    const r = await run("promote", [
      "--batch-key",
      "stale-b",
      "--confirm",
      "PROMOTE stale-b",
      "--confirm",
      "PROMOTE stale-b",
    ]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("more than once");
    expect(await counts(db)).toEqual(before);
  });

  /* ---------------- the Award Radar shape ---------------- */

  test("the Award Radar column shape is mapped, and the ignored columns are named", async () => {
    const key = "legacy-2026-09";
    const r = await run("stage", ["--csv", fixture("legacy-shape.csv"), "--batch-key", key]);
    expect(r.ok).toBe(true);
    const md = report(`${key}-stage.md`);
    expect(md).toContain("`source_slug`");
    expect(md).toContain("`category_override`");
    expect(md).toContain("`address_raw`");
    expect(md).toContain("not used by this job");
    expect(await verdicts(db, key)).toEqual({ new_venue: 1 });
  });

  test("a CSV with no source_url column aborts before staging anything", async () => {
    const before = await counts(db);
    const r = await run("stage", [
      "--csv",
      fixture("legacy-no-url.csv"),
      "--batch-key",
      "no-url-key",
    ]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("no column for: source_url");
    expect(await counts(db)).toEqual(before);
  });

  test("an unregistered source is reported, not a crash", async () => {
    const csv = join(OUT, "bad-source.csv");
    await Bun.write(
      csv,
      "batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note\n" +
        "bad-source,not-a-guide,2026,,,,https://example.com/x,Ghost Kitchen,London,United Kingdom,restaurant,,,\n",
    );
    const r = await run("stage", ["--csv", csv, "--batch-key", "bad-source"]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);
    expect(await verdicts(db, "bad-source")).toEqual({ reject: 1 });
  });

  test("a batch_key that disagrees with the workflow input aborts before staging", async () => {
    const before = await counts(db);
    const r = await run("stage", [
      "--csv",
      join(REPO, "fixtures/ingest/first-batch-2026-09.csv"),
      "--batch-key",
      "some-other-key",
    ]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("batch_key mismatch");
    expect(r.stderr).toContain("Nothing was staged");
    expect(await counts(db)).toEqual(before);
  });
});
