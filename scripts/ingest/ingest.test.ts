import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

import { TEST_DB_URL, buildTestDb, counts, verdicts } from "./test/harness.ts";
import { asJson, type Db } from "./lib/db.ts";
import type { CityCandidate, VenueCandidate } from "./lib/stageLogic.ts";
import { parseCsv, parseCsvRecords, toCsv } from "./lib/csv.ts";
import { disambiguate, mintVenueId, slugify } from "./lib/slug.ts";

const REPO = resolve(import.meta.dir, "../..");
const OUT = mkdtempSync(join(tmpdir(), "ingest-reports-"));

interface Run {
  ok: boolean;
  stdout: string;
  stderr: string;
}

async function run(
  script: "stage" | "promote" | "undo",
  args: string[],
  extraEnv: Record<string, string> = {},
): Promise<Run> {
  const proc = Bun.spawn(
    ["bun", "run", join(REPO, `scripts/ingest/${script}.ts`), ...args, "--out", OUT],
    {
      cwd: REPO,
      env: { ...process.env, SUPABASE_DB_URL: TEST_DB_URL, ...extraEnv },
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

/* ====================================================================== */
/* Undo - reversing a promoted batch                                      */
/* ====================================================================== */

/**
 * A fresh database, promoted once from the acceptance fixture. The undo tests
 * take that batch apart, so they get their own build rather than inheriting
 * whatever the promote tests above left behind.
 */
describe.skipIf(skip)("undo", () => {
  let db: Db;
  let close: () => Promise<void>;

  const KEY = "first-batch-2026-09";
  const ACCEPTANCE = join(REPO, "fixtures/ingest/first-batch-2026-09.csv");
  // Guy Savoy is the batch-created venue three of the ten award rows hang on.
  const GUY_SAVOY = mintVenueId("paris", "guy-savoy");
  const BRABO = mintVenueId("barcelona", "brabo");

  /** A one-row CSV whose venue already exists, so it stages as a `match`. */
  const HEADER =
    "batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note\n";

  beforeAll(async () => {
    const built = await buildTestDb(REPO);
    db = built.db;
    close = built.close;
    expect((await run("stage", ["--csv", ACCEPTANCE, "--batch-key", KEY])).ok).toBe(true);
    expect((await run("promote", ["--batch-key", KEY, "--confirm", `PROMOTE ${KEY}`])).ok).toBe(
      true,
    );
  });
  afterAll(async () => {
    await close();
  });

  test("undo refuses without the exact confirmation", async () => {
    const before = await counts(db);
    for (const wrong of [
      "UNDO",
      "undo first-batch-2026-09",
      "UNDO wrong-key",
      "",
      `UNDO ${KEY} `,
    ]) {
      const r = await run("undo", ["--batch-key", KEY, "--confirm", wrong]);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("Nothing was undone");
      expect(r.stderr).toContain(`UNDO ${KEY}`);
    }
    // and a repeated confirmation is refused outright, not first-one-wins
    const twice = await run("undo", [
      "--batch-key",
      KEY,
      "--confirm",
      `UNDO ${KEY}`,
      "--confirm",
      `UNDO ${KEY}`,
    ]);
    expect(twice.ok).toBe(false);
    expect(twice.stderr).toContain("more than once");

    expect(await counts(db)).toEqual(before);
  });

  test("undo refuses on a batch that is not promoted, and on a key that is not there", async () => {
    const live = async () => {
      const { ingest_batches: _b, ingest_rows: _r, ...rest } = await counts(db);
      return rest;
    };
    const before = await live();

    const missing = await run("undo", [
      "--batch-key",
      "no-such-key",
      "--confirm",
      "UNDO no-such-key",
    ]);
    expect(missing.ok).toBe(false);
    expect(missing.stderr).toContain("No batch with key");

    const staged = "staged-only-2026-09";
    await Bun.write(
      join(OUT, "staged-only.csv"),
      HEADER +
        `${staged},michelin,2026,,One Star,,https://guide.michelin.com/x,Lone Star,London,United Kingdom,restaurant,,,\n`,
    );
    expect(
      (await run("stage", ["--csv", join(OUT, "staged-only.csv"), "--batch-key", staged])).ok,
    ).toBe(true);

    const r = await run("undo", ["--batch-key", staged, "--confirm", `UNDO ${staged}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("is staged, not promoted");

    // staging that batch added its own ingest_batches and ingest_rows rows; no
    // live table moved
    expect(await live()).toEqual(before);
  });

  test("the dry run states every count with its population and changes nothing", async () => {
    const before = await counts(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`, "--dry-run"]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const md = report(`${KEY}-undo.md`);
    expect(md).toContain("Dry run - rolled back");
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("Population: whole table");
    // before -> expected -> actual, all three agreeing, on the rolled-back run
    expect(md).toContain("| venues | 15 | 7 | 7 |");
    expect(md).toContain("| awards | 13 | 3 | 3 |");
    expect(md).toContain("| listings | 15 | 7 | 7 |");
    expect(md).toContain("| slugs | 15 | 7 | 7 |");
    expect(md).toContain("| city_label_source | 16 | 0 | 0 |");
    expect(md).toContain("| source_capture_ledger | 10 | 0 | 0 |");
    // the job never creates a city, so a clean undo never removes one
    expect(md).toContain("| cities | 12 | 12 | 12 |");
    expect(md).toContain("The promote transaction inserted no `cities` row");

    expect(await counts(db)).toEqual(before);
  });

  test("undo refuses while another batch's award sits on a venue this batch created", async () => {
    const extra = "extra-2026-09";
    const csv = join(OUT, "extra.csv");
    await Bun.write(
      csv,
      HEADER +
        `${extra},worlds-50-best-restaurants,2006,6,No. 6,,https://www.the50.com/restaurants/best-in-the-world/previous-list/2006,Guy Savoy,Paris,France,restaurant,active,,\n`,
    );
    expect((await run("stage", ["--csv", csv, "--batch-key", extra])).ok).toBe(true);
    // it matches the venue the acceptance batch created, it does not create one
    expect(await verdicts(db, extra)).toEqual({ match: 1 });
    expect((await run("promote", ["--batch-key", extra, "--confirm", `PROMOTE ${extra}`])).ok).toBe(
      true,
    );

    const before = await counts(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain(GUY_SAVOY);
    expect(r.stderr).toContain("which this batch did not add");
    expect(r.stderr).toContain("would take another batch's award with it");
    expect(await counts(db)).toEqual(before);

    /* ---- rule 4: undoing the matched batch takes only its own award ---- */
    const back = await run("undo", ["--batch-key", extra, "--confirm", `UNDO ${extra}`]);
    expect(back.stderr).toBe("");
    expect(back.ok).toBe(true);

    const md = report(`${extra}-undo.md`);
    expect(md).toContain("Venues this batch matched (kept)");
    expect(md).toContain("| `" + GUY_SAVOY + "` | Guy Savoy | 1 | 3 |");
    expect(md).not.toContain("Venues this batch created");

    const after = await counts(db);
    expect(after.venues).toBe(before.venues); // the matched venue stayed
    expect(after.awards).toBe(before.awards - 1); // only its own award went
    expect(after.listings).toBe(before.listings);
    expect(after.slugs).toBe(before.slugs);

    // Guy Savoy still has the three awards the acceptance batch gave it
    const { rows } = await db.query<{ n: string }>(
      `select count(*)::text n from awards where venue_id = $1`,
      [GUY_SAVOY],
    );
    expect(Number(rows[0].n)).toBe(3);
  });

  test("undo refuses when a batch-created URL has gained a redirect", async () => {
    const before = await counts(db);
    await db.query(
      `insert into redirects (from_path, to_path) values ('/paris/guy-savoy-2005', $1)`,
      [`/paris/guy-savoy`],
    );

    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("is named by a redirect");
    expect(r.stderr).toContain("/paris/guy-savoy-2005");
    expect(await counts(db)).toEqual(before);

    await db.query(`delete from redirects where from_path = '/paris/guy-savoy-2005'`);
  });

  test("undo refuses when a venue or its listing has been changed by hand, and says what moved", async () => {
    const before = await counts(db);

    await db.query(`update listings set published = false where venue_id = $1`, [BRABO]);
    const listing = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(listing.ok).toBe(false);
    expect(listing.stderr).toContain("has changed since the promote");
    expect(listing.stderr).toContain("published true -> false");
    await db.query(`update listings set published = true where venue_id = $1`, [BRABO]);

    await db.query(`update venues set status = 'closed' where id = $1`, [BRABO]);
    const venue = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(venue.ok).toBe(false);
    expect(venue.stderr).toContain(`the venue row ${BRABO} has changed since the promote`);
    expect(venue.stderr).toContain('status "active" -> "closed"');
    await db.query(`update venues set status = 'active' where id = $1`, [BRABO]);

    // and a Phase 3 enrichment row is equally a refusal
    await db.query(
      `insert into geo (venue_id, lat, lng, precision, source) values ($1, 41.4, 2.2, 'venue', 'overture')`,
      [BRABO],
    );
    const geo = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(geo.ok).toBe(false);
    expect(geo.stderr).toContain("has a geo row");
    await db.query(`delete from geo where venue_id = $1`, [BRABO]);

    expect(await counts(db)).toEqual(before);
  });

  test("undo removes exactly what the batch wrote, in one transaction", async () => {
    const before = await counts(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const after = await counts(db);
    // the acceptance batch: 10 award rows over 8 new venues
    expect(after.venues - before.venues).toBe(-8);
    expect(after.awards - before.awards).toBe(-10);
    expect(after.listings - before.listings).toBe(-8);
    expect(after.slugs - before.slugs).toBe(-8);
    expect(after.city_label_source - before.city_label_source).toBe(-16);
    expect(after.source_capture_ledger - before.source_capture_ledger).toBe(-10);
    expect(after.price).toBe(0);

    // back to exactly the seed
    expect(after.venues).toBe(7);
    expect(after.awards).toBe(3);
    expect(after.listings).toBe(7);
    expect(after.slugs).toBe(7);
    expect(after.city_label_source).toBe(0);
    expect(after.source_capture_ledger).toBe(0);

    // the job never creates a city, so it never removes one: Jiménez de Jamuz
    // was in `cities` before this batch and is still there
    const { rows: cities } = await db.query<{ n: string }>(
      `select count(*)::text n from cities where slug = 'jimenez-de-jamuz'`,
    );
    expect(Number(cities[0].n)).toBe(1);

    // history is never deleted
    const { rows: batch } = await db.query<{
      status: string;
      undone_at: string | null;
      rows: string;
    }>(
      `select b.status::text as status, b.undone_at::text as undone_at,
              (select count(*)::text from ingest_rows r where r.batch_id = b.id) as rows
         from ingest_batches b where b.batch_key = $1`,
      [KEY],
    );
    expect(batch[0].status).toBe("undone");
    expect(batch[0].undone_at).not.toBeNull();
    expect(Number(batch[0].rows)).toBe(10);

    // the undo's own audit row, plus a DELETE row for every row it removed
    // the document is a real jsonb object, not a quoted string, so it is
    // queryable: that is what makes the trail worth writing
    const { rows: undoAudit } = await db.query<{
      n: string;
      job: string;
      venues: string;
      awards: string;
    }>(
      `select count(*)::text n, min(new_row->>'job') as job,
              min(new_row->'removed'->>'venues') as venues,
              min(new_row->>'awards_deleted') as awards
         from audit_log
        where table_name = 'ingest_batches' and action = 'UNDO'
          and new_row->>'batch_key' = $1`,
      [KEY],
    );
    expect(Number(undoAudit[0].n)).toBe(1);
    expect(undoAudit[0].job).toBe(`ingest-undo:${KEY}`);
    expect(Number(undoAudit[0].venues)).toBe(-8);
    expect(Number(undoAudit[0].awards)).toBe(10);
    const { rows: deletes } = await db.query<{ n: string }>(
      `select count(*)::text n from audit_log where action = 'DELETE' and table_name = 'venues'`,
    );
    expect(Number(deletes[0].n)).toBe(8);

    const md = report(`${KEY}-undo.md`);
    expect(md).toContain("One transaction, all of it or none of it");
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("| venues | 15 | 7 | 7 |");
  });

  test("a second undo of the same key is an error, not a no-op", async () => {
    const before = await counts(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO ${KEY}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("already undone");
    expect(r.stderr).toContain("stage it under a NEW batch key");
    expect(await counts(db)).toEqual(before);
  });

  test("an undone batch cannot be promoted again under the same key", async () => {
    const before = await counts(db);
    const r = await run("promote", ["--batch-key", KEY, "--confirm", `PROMOTE ${KEY}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("is undone, not staged");
    expect(await counts(db)).toEqual(before);
  });

  /**
   * The mixed batch, end to end. Seven new venues, one match, and rows of every
   * other verdict - duplicate, subsumed, reject, skipped - which wrote nothing at
   * promote and so must remove nothing at undo. It also carries the slug
   * collision: the two incumbent London Brines have to come out of this with
   * their own URLs untouched.
   */
  test("a batch of every verdict undoes back to exactly where it started", async () => {
    const key = "cases-2026-09";
    const before = await counts(db);

    expect((await run("stage", ["--csv", fixture("cases.csv"), "--batch-key", key])).ok).toBe(true);
    expect(
      (
        await run("stage", [
          "--csv",
          fixture("cases.csv"),
          "--batch-key",
          key,
          "--decisions",
          fixture("decisions.csv"),
        ])
      ).ok,
    ).toBe(true);
    expect((await run("promote", ["--batch-key", key, "--confirm", `PROMOTE ${key}`])).ok).toBe(
      true,
    );

    const promoted = await counts(db);
    expect(promoted.venues - before.venues).toBe(7);
    expect(promoted.awards - before.awards).toBe(8);

    // the batch's Brine took brine-3; the two already there kept theirs
    const londonBrines = async () => {
      const { rows } = await db.query<{ slug: string }>(
        `select s.slug from slugs s join venues v on v.id = s.venue_id
          where v.name = 'Brine' and s.city_slug = 'london' order by s.slug`,
      );
      return rows.map((r) => r.slug);
    };
    expect(await londonBrines()).toEqual(["brine", "brine-2", "brine-3"]);

    const r = await run("undo", ["--batch-key", key, "--confirm", `UNDO ${key}`]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    // every live table back to where it was before the promote
    const { ingest_batches: _b, ingest_rows: _r, ...liveAfter } = await counts(db);
    const { ingest_batches: _b2, ingest_rows: _r2, ...liveBefore } = before;
    expect(liveAfter).toEqual(liveBefore);

    // the incumbents kept their URLs; only the newcomer's went
    expect(await londonBrines()).toEqual(["brine", "brine-2"]);

    // Tallow was matched, not created: it keeps its row and its seeded awards
    const { rows: tallow } = await db.query<{ n: string }>(
      `select count(*)::text n from awards where venue_id = 've_aaaaaaaaa1'`,
    );
    expect(Number(tallow[0].n)).toBe(2);

    // and every staged row of the batch is still there, all 21 of them
    const { rows: kept } = await db.query<{ status: string; rows: string }>(
      `select b.status::text as status,
              (select count(*)::text from ingest_rows r where r.batch_id = b.id) as rows
         from ingest_batches b where b.batch_key = $1`,
      [key],
    );
    expect(kept[0].status).toBe("undone");
    expect(Number(kept[0].rows)).toBe(21);
  });
});

/* ====================================================================== */
/* Resolution parity - the set-based path against the SQL path it replaced */
/* ====================================================================== */

/**
 * The optimisation this suite has to defend is a change of *where* the
 * matching happens, not *what* it decides. The old path joined every staged
 * row against every city inside one statement, re-normalising 3,177 city slugs
 * and displays once per CSV row; the new one normalises each side once and
 * matches in memory. Both are still in the tree, and this describe block runs
 * the whole Michelin fixture through each of them and diffs the result row by
 * row.
 *
 * Diffed: the verdict, the reason, and everything the verdict is built from -
 * the resolved city and venue, the new-venue group, and the candidate sets.
 *
 * Not diffed: the ORDER of a multi-candidate list. The SQL path got that from
 * `order by city_slug` under the database's own collation, which is C.UTF-8 on
 * one machine and en_US.UTF-8 on the live project - so it was never fixed to
 * begin with. It reaches the review CSV's `candidates` column and nothing
 * else; no verdict depends on it.
 */
describe.skipIf(skip)("resolution parity", () => {
  let db: Db;
  let close: () => Promise<void>;

  /** Seeded from the fixture itself, so every branch below is actually hit. */
  beforeAll(async () => {
    const built = await buildTestDb(REPO);
    db = built.db;
    close = built.close;

    const { records } = parseCsvRecords(
      readFileSync(join(REPO, "fixtures/ingest/michelin-2026-france.csv"), "utf8"),
    );
    const labels = [...new Set(records.map((r) => r.city_label))];
    const names = [...new Set(records.map((r) => r.venue_name))];

    const slugify = (s: string) =>
      s
        .normalize("NFKD")
        .replace(/[̀-ͯ]/g, "")
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-|-$/g, "");

    // Michelin's vocabulary, so the rows are not all rejected on category.
    await db.query(
      `insert into award_categories (source_id, category) values
         ('michelin','Three Stars'),('michelin','Two Stars'),('michelin','Bib Gourmand')
       on conflict do nothing`,
    );

    // Cities for most of the fixture's labels. Every 17th is left out so the
    // city_not_found branch is live, and three get a same-display twin in
    // another country so city_ambiguous is too.
    // The base seed already holds a few cities (Paris among them). Reuse those
    // rather than colliding with their slugs or doubling their displays.
    const { rows: already } = await db.query<{ id: string; slug: string; display: string }>(
      `select id, slug, display from cities`,
    );
    const cityIdFor = new Map<string, string>(already.map((c) => [c.display, c.id]));
    const seen = new Set<string>(already.map((c) => c.slug));
    const values: string[] = [];
    const params: string[] = [];
    let n = 0;
    for (const [i, label] of labels.entries()) {
      if (i % 17 === 0) continue;
      if (cityIdFor.has(label)) continue;
      let slug = slugify(label);
      if (slug === "" || seen.has(slug)) slug = `${slug || "city"}-${i}`;
      seen.add(slug);
      const id = `ci_p${String(n).padStart(8, "0")}`;
      n += 1;
      cityIdFor.set(label, id);
      const b = params.length;
      params.push(id, slug, label, "France", "FR");
      values.push(`($${b + 1},$${b + 2},$${b + 3},$${b + 4},$${b + 5})`);

      if (i % 211 === 0) {
        // the same display in another country: two candidates, no country hint
        // strong enough to split them apart on its own
        const twin = `ci_p${String(n).padStart(8, "0")}`;
        n += 1;
        const twinSlug = `${slug}-be`;
        seen.add(twinSlug);
        const c = params.length;
        params.push(twin, twinSlug, label, "Belgium", "BE");
        values.push(`($${c + 1},$${c + 2},$${c + 3},$${c + 4},$${c + 5})`);
      }
    }
    for (const part of [values]) {
      await db.query(
        `insert into cities (id, slug, display, country, country_iso) values ${part.join(",")}`,
        params,
      );
    }

    // One alias, to keep the alias route in the diff.
    const aliasCity = [...cityIdFor.values()][0];
    await db.query(`insert into city_aliases (alias, city_id) values ('parparis', $1)`, [
      aliasCity,
    ]);

    // Venues, placed so that each venue branch fires:
    //   every 5th name  -> in its own city        => match
    //   every 7th name  -> in a different city    => same_key_other_city
    //   every 11th name -> twice in its own city  => venue_ambiguous_in_city
    const cityOfName = new Map<string, string>();
    for (const rec of records)
      if (!cityOfName.has(rec.venue_name)) cityOfName.set(rec.venue_name, rec.city_label);
    const allCityIds = [...cityIdFor.values()];
    const vVals: string[] = [];
    const vParams: string[] = [];
    let v = 0;
    const addVenue = (name: string, cityId: string) => {
      const id = `ve_p${String(v).padStart(8, "0")}`;
      v += 1;
      const b = vParams.length;
      vParams.push(id, name, cityId);
      vVals.push(`($${b + 1},$${b + 2},'restaurant',$${b + 3},'active')`);
      return id;
    };
    for (const [i, name] of names.entries()) {
      const own = cityIdFor.get(cityOfName.get(name) ?? "");
      if (i % 5 === 0 && own) addVenue(name, own);
      else if (i % 7 === 0) addVenue(name, allCityIds[i % allCityIds.length]);
      else if (i % 11 === 0 && own) {
        addVenue(name, own);
        addVenue(name, own);
      }
    }
    await db.query(
      `insert into venues (id, name, category, city_id, status) values ${vVals.join(",")}`,
      vParams,
    );
    await db.query(
      `insert into listings (venue_id, property_id, published)
       select id, 'eats', true from venues where id like 've_p%'`,
    );
    await db.query(`
      insert into slugs (property_id, city_slug, slug, venue_id, is_canonical)
      select 'eats', c.slug,
             regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g') || '-' || v.id,
             v.id, true
        from venues v join cities c on c.id = v.city_id
       where v.id like 've_p%'
    `);
    // Cities the published fixtures cannot reach, for the two rules that are
    // easiest to get wrong in a rewrite and that no real Michelin row touches:
    // a country that is NULL rather than wrong, and a city found by more than
    // one route. See the "corner cases" test below for what each is for.
    await db.query(`
      insert into cities (id, slug, display, country, country_iso) values
        ('ci_pnull0001','nullcountry','Nullcountry', null,       null),
        ('ci_pnull0002','isoonly',    'Isoonly',     null,       'PT'),
        ('ci_pnull0003','nameonly',   'Nameonly',    'Portugal', null),
        ('ci_ptwo00001','tworoutes',  'Tworoutes',   'Portugal', 'PT')
    `);
    // an alias onto a city that its own slug already matches: via must be the
    // alphabetically first route, which is "alias", not "slug"
    await db.query(
      `insert into city_aliases (alias, city_id) values ('tworoutes', 'ci_ptwo00001')`,
    );

    // A handful of awards so duplicate and subsume are in the diff too.
    await db.query(`
      insert into awards (venue_id, source_id, year, rank, category, distinction, source_url)
      select id, 'michelin', 2026, null, 'One Star', null, 'https://guide.michelin.com/'
        from venues where id like 've_p%' order by id limit 40
      on conflict do nothing
    `);
  });

  afterAll(async () => {
    await close();
  });

  /** The slice of the stored validation document this diff reads. */
  interface Validation {
    line: number;
    reason: string | null;
    city_id: string | null;
    city_slug: string | null;
    venue_id: string | null;
    new_venue_group: string | null;
    venue_category: string | null;
    venue_status: string | null;
    candidates?: { cities: CityCandidate[]; venues: VenueCandidate[] };
    collides_with?: number[];
    supersedes?: number[];
    rank_held_by?: { award_id: number }[];
  }

  /** Everything a verdict is made of, order-independent. */
  interface Shape {
    line: number;
    verdict: string;
    reason: string | null;
    city_id: string | null;
    city_slug: string | null;
    venue_id: string | null;
    new_venue_group: string | null;
    venue_category: string | null;
    venue_status: string | null;
    cities: string[];
    venues: string[];
    collides_with: number[];
    supersedes: number[];
    rank_held_by: number[];
  }

  async function shapes(batchKey: string): Promise<Shape[]> {
    const { rows } = await db.query<{ verdict: string; validation: unknown }>(
      `select r.verdict, r.validation
         from ingest_rows r join ingest_batches b on b.id = r.batch_id
        where b.batch_key = $1`,
      [batchKey],
    );
    const nums = (a: number[]) => [...a].sort((x, y) => x - y);
    const strs = (a: string[]) => [...a].sort();

    return rows
      .map(({ verdict, validation }) => {
        const v = asJson<Validation | null>(validation, null);
        if (v === null) throw new Error(`a row of batch "${batchKey}" has no validation`);
        return {
          line: Number(v.line),
          verdict,
          reason: v.reason ?? null,
          city_id: v.city_id ?? null,
          city_slug: v.city_slug ?? null,
          venue_id: v.venue_id ?? null,
          new_venue_group: v.new_venue_group ?? null,
          venue_category: v.venue_category ?? null,
          venue_status: v.venue_status ?? null,
          cities: strs((v.candidates?.cities ?? []).map((c) => `${c.city_id}|${c.via}`)),
          venues: strs((v.candidates?.venues ?? []).map((x) => `${x.venue_id}|${x.same_city}`)),
          collides_with: nums(v.collides_with ?? []),
          supersedes: nums(v.supersedes ?? []),
          rank_held_by: nums((v.rank_held_by ?? []).map((h) => Number(h.award_id))),
        } satisfies Shape;
      })
      .sort((a, b) => a.line - b.line);
  }

  /**
   * Both fixtures carry their own batch_key column, and stage refuses a run
   * whose rows disagree with the key it was given. Each path therefore gets
   * its own copy of the file with the key rewritten - same rows, same order,
   * two batches to diff.
   */
  function csvWithKey(src: string, key: string): string {
    const { header, records } = parseCsvRecords(readFileSync(src, "utf8"));
    const path = join(OUT, `${key}.csv`);
    writeFileSync(
      path,
      toCsv(
        header,
        records.map((r) => ({ ...r, batch_key: key })),
      ),
    );
    return path;
  }

  async function stageBoth(csv: string, key: string): Promise<[Shape[], Shape[]]> {
    const memo = await run("stage", [
      "--csv",
      csvWithKey(csv, `${key}-memory`),
      "--batch-key",
      `${key}-memory`,
    ]);
    expect(memo.stderr).toBe("");
    expect(memo.ok).toBe(true);

    const sql = await run(
      "stage",
      ["--csv", csvWithKey(csv, `${key}-sql`), "--batch-key", `${key}-sql`],
      { INGEST_STAGE_RESOLVER: "sql" },
    );
    expect(sql.stderr).toBe("");
    expect(sql.ok).toBe(true);

    return [await shapes(`${key}-memory`), await shapes(`${key}-sql`)];
  }

  test("1,071 Michelin rows resolve identically on both paths", async () => {
    const [memory, sql] = await stageBoth(
      join(REPO, "fixtures/ingest/michelin-2026-france.csv"),
      "parity-michelin",
    );

    expect(memory).toHaveLength(1071);
    expect(sql).toHaveLength(1071);

    // Name the first disagreement rather than dumping 1,071 rows.
    const differing = memory.filter((m, i) => JSON.stringify(m) !== JSON.stringify(sql[i]));
    expect(
      differing.length === 0
        ? "identical"
        : `line ${differing[0].line}: memory ${JSON.stringify(
            differing[0],
          )} vs sql ${JSON.stringify(sql.find((s) => s.line === differing[0].line))}`,
    ).toBe("identical");
    expect(memory).toEqual(sql);

    // A diff of two empty sets proves nothing: the fixture has to exercise
    // the branches. These are the counts the seeding above is built to give.
    const tally = new Map<string, number>();
    for (const m of memory) tally.set(m.verdict, (tally.get(m.verdict) ?? 0) + 1);
    for (const v of ["match", "new_venue", "review_city", "review_venue"]) {
      expect(tally.get(v) ?? 0).toBeGreaterThan(0);
    }
    const reasons = new Set(memory.map((m) => m.reason).filter(Boolean));
    expect(reasons).toContain("city_not_found");
    expect(reasons).toContain("same_key_other_city");
    expect(reasons).toContain("venue_ambiguous_in_city");
    // and the city route that only an alias or a display can reach
    expect(memory.some((m) => m.cities.some((c) => c.endsWith("|display")))).toBe(true);
  }, 180_000);

  /**
   * The published fixtures leave two rules untested, and a parity test that
   * cannot see a rule is not defending it:
   *
   *   - no city_label in either fixture contains a comma, so the "London, UK"
   *     form - match on the part before the comma, treat the rest as a country
   *     hint - never fires;
   *   - every seeded city has a country, so `norm_label(c.country) = n_country`
   *     is never NULL, and the three-valued logic that decides whether a row
   *     keeps its candidates or loses all of them is never exercised.
   *
   * Both are branches where the SQL and the in-memory paths could plausibly
   * disagree, so this fixture goes at them directly.
   */
  test("the corner cases the published fixtures never reach resolve identically", async () => {
    const rows = [
      // the comma form: nothing matches "paris france", "paris" does
      ["Comma Head Bistro", "Paris, France", ""],
      // country is NULL, not wrong: UNKNOWN, so the candidate is dropped
      ["Null Country Grill", "Nullcountry", "Portugal"],
      // country NULL but the ISO agrees
      ["Iso Only Grill", "Isoonly", "PT"],
      // ISO NULL but the name agrees
      ["Name Only Grill", "Nameonly", "Portugal"],
      // ISO NULL and the name disagrees: UNKNOWN again, candidate dropped
      ["Name Mismatch Grill", "Nameonly", "Spain"],
      // one city, two routes: min(via) has to pick "alias" over "slug"
      ["Two Routes Grill", "tworoutes", ""],
      // no hint at all, so every candidate is kept
      ["No Hint Grill", "Nullcountry", ""],
    ];
    const key = "parity-corners";
    const path = join(OUT, `${key}.csv`);
    writeFileSync(
      path,
      toCsv(
        [
          "batch_key",
          "source_id",
          "year",
          "category",
          "source_url",
          "venue_name",
          "city_label",
          "country_label",
        ],
        rows.map(([venue, city, country]) => ({
          batch_key: key,
          source_id: "michelin",
          year: "2026",
          category: "One Star",
          source_url: "https://guide.michelin.com/x",
          venue_name: venue,
          city_label: city,
          country_label: country,
        })),
      ),
    );

    const [memory, sql] = await stageBoth(path, key);
    expect(memory).toEqual(sql);

    const at = (n: number) => memory[n - 1];
    expect(at(1).city_slug).toBe("paris"); // the comma form resolved
    // A country that is NULL is UNKNOWN, not a disagreement: the candidate
    // is dropped and the row reads as city_not_found, never as a match.
    expect(at(2)).toMatchObject({ verdict: "review_city", reason: "city_not_found" });
    expect(at(3).city_slug).toBe("isoonly");
    expect(at(4).city_slug).toBe("nameonly");
    expect(at(5)).toMatchObject({ verdict: "review_city", reason: "city_not_found" });
    expect(at(6).cities).toEqual(["ci_ptwo00001|alias"]);
    expect(at(7).city_slug).toBe("nullcountry"); // no hint, candidate kept
  }, 180_000);

  test("the hand-built edge cases resolve identically on both paths", async () => {
    const [memory, sql] = await stageBoth(fixture("cases.csv"), "parity-cases");
    expect(memory).toEqual(sql);
    // cases.csv is the file that carries country_label_disagrees, the
    // ambiguous city and the short norm_key, so the three-valued country
    // logic and the NULL-key rule are both inside this diff.
    const reasons = new Set(memory.map((m) => m.reason).filter(Boolean));
    expect(reasons).toContain("country_label_disagrees");
    expect(reasons).toContain("city_ambiguous");
    expect(reasons).toContain("norm_key_too_short");
  }, 180_000);
});

/* ====================================================================== */
/* What a run leaves behind when it does not finish                       */
/* ====================================================================== */

/**
 * The Michelin run was cancelled after twelve minutes and left nothing at all
 * - no batch row, no report, no review CSV, and no way to tell how far it had
 * got. These tests pin the other behaviour: the report file is rewritten as
 * each phase completes, and a run that dies still leaves the report and, once
 * the verdicts exist, the review CSV.
 */
describe.skipIf(skip)("a run that does not finish", () => {
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

  test("a failure after the verdicts exist still writes the report and the review CSV", async () => {
    const key = "cases-2026-09";
    // `price` is read by loadPlanState, which runs after the verdicts are
    // settled and after the review CSV is written - so parking the table
    // fails the run at exactly the point this behaviour is about.
    await db.query(`alter table price rename to price_parked`);
    let r: Run;
    try {
      r = await run("stage", ["--csv", fixture("cases.csv"), "--batch-key", key]);
    } finally {
      await db.query(`alter table price_parked rename to price`);
    }
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("Stage failed");

    const md = report(`${key}-stage.md`);
    expect(md).toContain("(INCOMPLETE)");
    expect(md).toContain("This run **did not finish**");
    expect(md).toContain('relation "price" does not exist');
    // and it names how far it got
    expect(md).toContain("row checks");
    expect(md).toContain("resolved venues");
    expect(md).toContain("It stopped **after**");

    // the rows that need Ben's eyes are on disk even though the run died
    const { records } = parseCsvRecords(readFileSync(join(OUT, `${key}-review.csv`), "utf8"));
    expect(records.map((x) => x.line).sort()).toEqual(["14", "16", "19", "20", "8", "9"]);

    // and the transaction took nothing with it
    const { rows } = await db.query<{ n: string }>(
      `select count(*)::text n from ingest_batches where batch_key = $1`,
      [key],
    );
    expect(Number(rows[0].n)).toBe(0);
  }, 60_000);

  test("a cancel writes the report, names the phase, and stages nothing", async () => {
    const key = "cancelled-2026-09";
    const csv = join(OUT, `${key}.csv`);
    const { header, records } = parseCsvRecords(
      readFileSync(join(REPO, "fixtures/ingest/michelin-2026-france.csv"), "utf8"),
    );
    writeFileSync(
      csv,
      toCsv(
        header,
        records.map((x) => ({ ...x, batch_key: key })),
      ),
    );

    // The SQL reference path is slow enough to interrupt on purpose. The
    // signal is sent on a line of output, not on a timer, so this does not
    // race: by the time that phase has printed, the next one has started.
    const proc = Bun.spawn(
      [
        "bun",
        "run",
        join(REPO, "scripts/ingest/stage.ts"),
        "--csv",
        csv,
        "--batch-key",
        key,
        "--out",
        OUT,
      ],
      {
        cwd: REPO,
        env: { ...process.env, SUPABASE_DB_URL: TEST_DB_URL, INGEST_STAGE_RESOLVER: "sql" },
        stdout: "pipe",
        stderr: "pipe",
      },
    );

    let seen = "";
    const reader = proc.stdout.getReader();
    const decoder = new TextDecoder();
    while (!seen.includes("loaded the live rows into the resolver")) {
      const { done, value } = await reader.read();
      if (done) break;
      seen += decoder.decode(value, { stream: true });
    }
    expect(seen).toContain("loaded the live rows into the resolver");
    proc.kill("SIGINT");
    await proc.exited;

    const md = report(`${key}-stage.md`);
    expect(md).toContain("(INCOMPLETE)");
    expect(md).toContain("cancelled (SIG");
    expect(md).toContain("| 1 | read the CSV |");
    expect(md).toContain("It stopped **after**");

    const { rows } = await db.query<{ n: string }>(
      `select count(*)::text n from ingest_batches where batch_key = $1`,
      [key],
    );
    expect(Number(rows[0].n)).toBe(0);
  }, 120_000);

  test("the report file is rewritten as each phase completes", async () => {
    // The finished report carries the same phase table, so a reader gets the
    // timings whether the run ended well or badly.
    const key = "phases-2026-09";
    const csv = join(OUT, `${key}.csv`);
    const { header, records } = parseCsvRecords(readFileSync(fixture("cases.csv"), "utf8"));
    writeFileSync(
      csv,
      toCsv(
        header,
        records.map((x) => ({ ...x, batch_key: key })),
      ),
    );

    const r = await run("stage", ["--csv", csv, "--batch-key", key]);
    expect(r.ok).toBe(true);
    // progress went to stdout, where the Actions log can see it
    expect(r.stdout).toContain("read the CSV");
    expect(r.stdout).toContain("checked 21/21");
    expect(r.stdout).toContain("committed");

    const md = report(`${key}-stage.md`);
    expect(md).not.toContain("INCOMPLETE");
    expect(md).toContain("## Timings");
    expect(md).toContain("| read the CSV |");
    expect(md).toContain("| committed |");
  }, 60_000);
});
