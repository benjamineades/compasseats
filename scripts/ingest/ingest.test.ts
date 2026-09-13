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

async function run(script: "stage" | "promote" | "undo", args: string[]): Promise<Run> {
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
