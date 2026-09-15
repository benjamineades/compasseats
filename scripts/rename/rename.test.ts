import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

import { TEST_DB_URL, buildTestDb } from "../ingest/test/harness.ts";
import type { Db } from "../ingest/lib/db.ts";
import type { SourceRow } from "../ingest/lib/stageLogic.ts";
import { checkRow, linesByVenue, loadRenameCsv } from "./lib/renameCsv.ts";

const REPO = resolve(import.meta.dir, "../..");
const OUT = mkdtempSync(join(tmpdir(), "rename-reports-"));

interface Run {
  ok: boolean;
  stdout: string;
  stderr: string;
}

async function run(script: "apply" | "undo", args: string[]): Promise<Run> {
  const proc = Bun.spawn(
    ["bun", "run", join(REPO, `scripts/rename/${script}.ts`), ...args, "--out", OUT],
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

const HAPPY = join(REPO, "scripts/rename/test/happy.csv");
const HEADER = "batch_key,venue_id,expected_name,new_name,source_id,source_url,note\n";
const MICHELIN = "https://guide.michelin.com/en/ile-de-france/paris/restaurant/x";
const report = (name: string) => readFileSync(join(OUT, name), "utf8");

/** Write a CSV into the temp dir and hand back its path. */
async function csv(name: string, body: string): Promise<string> {
  const path = join(OUT, name);
  await Bun.write(path, body);
  return path;
}

async function buildRenameDb(): Promise<{ db: Db; close: () => Promise<void> }> {
  const built = await buildTestDb(REPO);
  await built.db.query(readFileSync(join(REPO, "scripts/rename/test/seed.sql"), "utf8"));
  return built;
}

async function names(db: Db): Promise<Record<string, string>> {
  const { rows } = await db.query<{ id: string; name: string }>(
    `select id, name from venues where id like 've_rn%' order by id`,
  );
  return Object.fromEntries(rows.map((r) => [r.id, r.name]));
}

async function tally(db: Db): Promise<Record<string, number>> {
  const { rows } = await db.query<{ k: string; n: string }>(`
    select 'venues' k, count(*)::text n from venues
    union all select 'awards', count(*)::text from awards
    union all select 'slugs', count(*)::text from slugs
    union all select 'blurbs', count(*)::text from blurbs
    union all select 'ledger', count(*)::text from source_capture_ledger
    union all select 'rename_batches', count(*)::text from rename_batches
    union all select 'rename_rows', count(*)::text from rename_rows
  `);
  return Object.fromEntries(rows.map((r) => [r.k, Number(r.n)]));
}

/* ====================================================================== */
/* Pure units - no database                                               */
/* ====================================================================== */

describe("the rename CSV", () => {
  const sources = new Map<string, SourceRow>([
    [
      "michelin",
      {
        slug: "michelin",
        status: "active",
        price_capable: false,
        capture_permission: false,
        geo_capable: false,
      },
    ],
  ]);
  const one = (over: Partial<Record<string, string>> = {}) => {
    const row = {
      batch_key: "k",
      venue_id: "ve_1",
      expected_name: "Old",
      new_name: "New",
      source_id: "michelin",
      source_url: MICHELIN,
      note: "",
      ...over,
    };
    const inputs = loadRenameCsv(
      "test.csv",
      HEADER +
        `${row.batch_key},${row.venue_id},${row.expected_name},${row.new_name},${row.source_id},${row.source_url},${row.note}\n`,
    );
    return checkRow(inputs[0], "k", sources, linesByVenue(inputs));
  };

  test("a good row passes every check that needs no database", () => {
    const r = one();
    expect(r.verdict).toBe("rename");
    expect(r.reason).toBeNull();
  });

  test("each reject reason fires on its own shape", () => {
    expect(one({ batch_key: "other" }).reason).toBe("batch_key_mismatch");
    expect(one({ new_name: "" }).reason).toBe("empty_new_name");
    expect(one({ venue_id: "" }).reason).toBe("venue_not_found");
    expect(one({ source_url: "" }).reason).toBe("missing_source_url");
    expect(one({ source_url: "not a url" }).reason).toBe("malformed_source_url");
    expect(one({ source_url: "https://www.joinpearl.co/venue/x" }).reason).toBe(
      "competitor_source_url",
    );
    expect(one({ source_id: "not-a-guide" }).reason).toBe("source_not_registered");
    // the venue's own website is the one source that is not a publisher
    expect(one({ source_id: "venue", source_url: "https://legabriel.example/" }).verdict).toBe(
      "rename",
    );
  });

  test("two rows for one venue take each other down", () => {
    const inputs = loadRenameCsv(
      "test.csv",
      HEADER +
        `k,ve_1,Old,New,michelin,${MICHELIN},\n` +
        `k,ve_1,Old,Other,michelin,${MICHELIN},\n`,
    );
    const dupes = linesByVenue(inputs);
    for (const input of inputs) {
      const r = checkRow(input, "k", sources, dupes);
      expect(r.verdict).toBe("reject");
      expect(r.reason).toBe("duplicate_venue_in_file");
      expect(r.detail).toContain("lines 1, 2");
    }
  });

  test("a column the job does not know stops the file, and so does a missing one", () => {
    expect(() =>
      loadRenameCsv("test.csv", "batch_key,venue_id,expected_name,new_name,source_id\nk,v,a,b,c\n"),
    ).toThrow(/no column for: source_url/);
    expect(() => loadRenameCsv("test.csv", HEADER.trim() + ",city\nk,v,a,b,c,d,e,f\n")).toThrow(
      /does not know/,
    );
  });

  test("a name is taken exactly as written, whitespace at the two ends aside", () => {
    const inputs = loadRenameCsv(
      "test.csv",
      HEADER +
        `k,ve_1,"  Le Gabriel - La Réserve Paris  ","  LE GABRIEL  ",michelin,${MICHELIN},\n`,
    );
    expect(inputs[0].expected_name).toBe("Le Gabriel - La Réserve Paris");
    // not lowercased, not trimmed at the dash, not tidied in any way
    expect(inputs[0].new_name).toBe("LE GABRIEL");
  });
});

/* ====================================================================== */
/* Against a throwaway database                                           */
/* ====================================================================== */

const skip = TEST_DB_URL === "";
if (skip) {
  console.warn("INGEST_TEST_DB_URL is not set - database tests skipped.");
}

describe.skipIf(skip)("rename apply", () => {
  let db: Db;
  let close: () => Promise<void>;
  const KEY = "rename-test-happy";

  beforeAll(async () => {
    const built = await buildRenameDb();
    db = built.db;
    close = built.close;
  });
  afterAll(async () => {
    await close();
  });

  test("the trigger blocks a plain UPDATE, with no job anywhere near it", async () => {
    await expect(
      db.query(`update venues set name = 'Hand Edit' where id = 've_rn11111111'`),
    ).rejects.toThrow(/rename job/);
    expect((await names(db))["ve_rn11111111"]).toBe("Restaurant Le Gabriel");
  });

  test("apply refuses without the exact confirmation", async () => {
    const before = await tally(db);
    for (const wrong of ["RENAME", "rename rename-test-happy", "RENAME wrong-key", ""]) {
      const r = await run("apply", ["--csv", HAPPY, "--batch-key", KEY, "--confirm", wrong]);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("Nothing was renamed");
      expect(r.stderr).toContain(`RENAME ${KEY}`);
    }
    // a repeated confirmation is refused outright, not first-one-wins
    const twice = await run("apply", [
      "--csv",
      HAPPY,
      "--batch-key",
      KEY,
      "--confirm",
      `RENAME ${KEY}`,
      "--confirm",
      `RENAME ${KEY}`,
    ]);
    expect(twice.ok).toBe(false);
    expect(twice.stderr).toContain("more than once");

    expect(await tally(db)).toEqual(before);
    expect((await names(db))["ve_rn11111111"]).toBe("Restaurant Le Gabriel");
  });

  test("the dry run does the whole job, prints it, and leaves no trace", async () => {
    const before = await tally(db);
    const beforeNames = await names(db);
    const r = await run("apply", [
      "--csv",
      HAPPY,
      "--batch-key",
      KEY,
      "--confirm",
      `RENAME ${KEY}`,
      "--dry-run",
    ]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const md = report(`${KEY}-rename.md`);
    expect(md).toContain("**DRY RUN - rolled back.**");
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("Population: whole table");
    // the impact table is printed before anything changes, for every rename row
    expect(md).toContain("## Downstream impact");
    expect(md).toContain("michelin 1");
    expect(md).toContain("/paris/restaurant-le-gabriel");
    expect(md).toContain("The slug does not change");

    expect(await tally(db)).toEqual(before);
    expect(await names(db)).toEqual(beforeNames);
  });

  test("a name that has moved since the file was built stops the whole batch", async () => {
    const key = "rename-test-moved";
    const path = await csv(
      "moved.csv",
      HEADER +
        `${key},ve_rn11111111,Restaurant Le Gabriel,Le Gabriel,michelin,${MICHELIN},\n` +
        `${key},ve_rn22222222,Something Else,La Table,michelin,${MICHELIN},\n`,
    );
    const before = await tally(db);
    const r = await run("apply", ["--csv", path, "--batch-key", key, "--confirm", `RENAME ${key}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("name_moved");
    expect(r.stderr).toContain("Nothing was renamed");

    const md = report(`${key}-rename.md`);
    expect(md).toContain("**REFUSED. Nothing was renamed.**");
    expect(md).toContain('live name is "Table du Marche", the file expected "Something Else"');

    // not even the good row landed, and the key is still free
    expect(await tally(db)).toEqual(before);
    expect((await names(db))["ve_rn11111111"]).toBe("Restaurant Le Gabriel");
  });

  test("a file with no data rows does not spend the key", async () => {
    const key = "rename-test-empty";
    const path = await csv("empty.csv", HEADER);
    const r = await run("apply", ["--csv", path, "--batch-key", key, "--confirm", `RENAME ${key}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("no data rows");
    expect(r.stderr).toContain("still free");
  });

  test("a venue that is not there is a refusal, not a skip", async () => {
    const key = "rename-test-missing";
    const path = await csv(
      "missing.csv",
      HEADER + `${key},ve_nosuchvenue,Whatever,Something,michelin,${MICHELIN},\n`,
    );
    const r = await run("apply", ["--csv", path, "--batch-key", key, "--confirm", `RENAME ${key}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("venue_not_found");
  });

  test("a norm_key collision in the same city comes back as review and blocks the apply", async () => {
    const key = "rename-test-collision";
    const path = await csv(
      "collision.csv",
      // "Hollow" is already a venue in Paris, and norm_key folds the accent and
      // the case away: both names reduce to "hollow"
      HEADER + `${key},ve_rn22222222,Table du Marche,Hôllow,michelin,${MICHELIN},\n`,
    );
    const before = await tally(db);
    const r = await run("apply", ["--csv", path, "--batch-key", key, "--confirm", `RENAME ${key}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("norm_key_collision");
    expect(r.stderr).toContain("ve_rn44444444");

    const md = report(`${key}-rename.md`);
    expect(md).toContain("Rows that need you");
    expect(md).toContain('ve_rn44444444 ("Hollow")');

    expect(await tally(db)).toEqual(before);
    expect((await names(db))["ve_rn22222222"]).toBe("Table du Marche");
  });

  test("the happy path: three renamed, one already right, one transaction", async () => {
    const before = await tally(db);
    const r = await run("apply", [
      "--csv",
      HAPPY,
      "--batch-key",
      KEY,
      "--confirm",
      `RENAME ${KEY}`,
    ]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    expect(await names(db)).toEqual({
      ve_rn11111111: "Le Gabriel",
      ve_rn22222222: "Table du Marche",
      ve_rn33333333: "Le Comptoir",
      ve_rn44444444: "Hollow",
      ve_rn55555555: "Sel & Poivre",
    });

    const after = await tally(db);
    expect(after.venues).toBe(before.venues);
    expect(after.awards).toBe(before.awards);
    expect(after.slugs).toBe(before.slugs);
    expect(after.blurbs).toBe(before.blurbs);
    // michelin and la-liste; `venue` is not a publisher, so it writes no row
    expect(after.ledger).toBe(before.ledger + 2);
    expect(after.rename_batches).toBe(before.rename_batches + 1);
    expect(after.rename_rows).toBe(before.rename_rows + 4);

    const { rows: verdicts } = await db.query<{ verdict: string; n: string }>(
      `select verdict, count(*)::text n from rename_rows group by 1 order by 1`,
    );
    expect(verdicts).toEqual([
      { verdict: "no_change", n: "1" },
      { verdict: "rename", n: "3" },
    ]);

    const { rows: ledger } = await db.query<{
      publisher: string;
      field_type: string;
      items: number;
    }>(
      `select publisher, field_type, items from source_capture_ledger
        where job = $1 order by publisher`,
      [`rename-apply:${KEY}`],
    );
    expect(ledger).toEqual([
      { publisher: "la-liste", field_type: "name", items: 1 },
      { publisher: "michelin", field_type: "name", items: 1 },
    ]);

    const { rows: batch } = await db.query<{ status: string; applied_at: string | null }>(
      `select status::text, applied_at::text as applied_at from rename_batches where batch_key = $1`,
      [KEY],
    );
    expect(batch[0].status).toBe("applied");
    expect(batch[0].applied_at).not.toBeNull();

    const md = report(`${KEY}-rename.md`);
    expect(md).toContain("One transaction, all of it or none of it.");
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("| `rename` | 3 |");
    expect(md).toContain("| `no_change` | 1 |");
    // the sample, and the name scan, both stated with their population
    expect(md).toContain("| `ve_rn11111111` | Restaurant Le Gabriel | Le Gabriel | michelin |");
    expect(md).toContain("Searched, not assumed");
    expect(md).toContain("`venue` as their source - the venue's own website settled");
  });

  test("the audit log holds both names for every rename", async () => {
    const { rows } = await db.query<{ old_name: string; new_name: string }>(
      `select old_row->>'name' as old_name, new_row->>'name' as new_name
         from audit_log
        where table_name = 'venues' and action = 'UPDATE' and row_pk = 've_rn11111111'`,
    );
    expect(rows).toEqual([{ old_name: "Restaurant Le Gabriel", new_name: "Le Gabriel" }]);
  });

  test("the guard is off again as soon as the transaction ends", async () => {
    await expect(
      db.query(`update venues set name = 'Hand Edit' where id = 've_rn11111111'`),
    ).rejects.toThrow(/rename job/);
  });

  test("the same key is refused for ever, applied or not", async () => {
    const before = await tally(db);
    const r = await run("apply", [
      "--csv",
      HAPPY,
      "--batch-key",
      KEY,
      "--confirm",
      `RENAME ${KEY}`,
    ]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("already exists");
    expect(r.stderr).toContain("NEW key");
    expect(await tally(db)).toEqual(before);
  });
});

/* ====================================================================== */
/* Undo                                                                   */
/* ====================================================================== */

describe.skipIf(skip)("rename undo", () => {
  let db: Db;
  let close: () => Promise<void>;
  const KEY = "rename-test-happy";

  beforeAll(async () => {
    const built = await buildRenameDb();
    db = built.db;
    close = built.close;
    expect(
      (await run("apply", ["--csv", HAPPY, "--batch-key", KEY, "--confirm", `RENAME ${KEY}`])).ok,
    ).toBe(true);
  });
  afterAll(async () => {
    await close();
  });

  test("undo refuses without the exact confirmation", async () => {
    const before = await names(db);
    for (const wrong of ["UNDO rename-test-happy", "UNDO-RENAME wrong-key", "", "undo-rename x"]) {
      const r = await run("undo", ["--batch-key", KEY, "--confirm", wrong]);
      expect(r.ok).toBe(false);
      expect(r.stderr).toContain("Nothing was undone");
      expect(r.stderr).toContain(`UNDO-RENAME ${KEY}`);
    }
    expect(await names(db)).toEqual(before);
  });

  test("undo refuses on a key that is not there", async () => {
    const r = await run("undo", [
      "--batch-key",
      "no-such-key",
      "--confirm",
      "UNDO-RENAME no-such-key",
    ]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("No rename batch with key");
  });

  test("the undo dry run states every count and changes nothing", async () => {
    const before = await tally(db);
    const beforeNames = await names(db);
    const r = await run("undo", [
      "--batch-key",
      KEY,
      "--confirm",
      `UNDO-RENAME ${KEY}`,
      "--dry-run",
    ]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    const md = report(`${KEY}-rename-undo.md`);
    expect(md).toContain("**DRY RUN - rolled back.**");
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("Population: whole table");
    expect(md).toContain("| names to put back | 3 |");
    expect(md).toContain("| ledger rows to remove | 2 |");

    expect(await tally(db)).toEqual(before);
    expect(await names(db)).toEqual(beforeNames);
  });

  test("undo puts every name back and takes the ledger rows with it", async () => {
    const before = await tally(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO-RENAME ${KEY}`]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);

    expect(await names(db)).toEqual({
      ve_rn11111111: "Restaurant Le Gabriel",
      ve_rn22222222: "Table du Marche",
      ve_rn33333333: "Comptoir",
      ve_rn44444444: "Hollow",
      ve_rn55555555: "Sel et Poivre",
    });

    const after = await tally(db);
    expect(after.ledger).toBe(before.ledger - 2);
    expect(after.venues).toBe(before.venues);
    expect(after.awards).toBe(before.awards);
    expect(after.slugs).toBe(before.slugs);
    // history is never deleted
    expect(after.rename_batches).toBe(before.rename_batches);
    expect(after.rename_rows).toBe(before.rename_rows);

    const { rows: batch } = await db.query<{ status: string; undone_at: string | null }>(
      `select status::text, undone_at::text as undone_at from rename_batches where batch_key = $1`,
      [KEY],
    );
    expect(batch[0].status).toBe("undone");
    expect(batch[0].undone_at).not.toBeNull();

    const md = report(`${KEY}-rename-undo.md`);
    expect(md).not.toContain("**FAIL**");
    expect(md).toContain("One transaction, all of it or none of it.");
  });

  test("a second undo is an error, not a no-op", async () => {
    const before = await names(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO-RENAME ${KEY}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("already undone");
    expect(r.stderr).toContain("An undo runs once");
    expect(await names(db)).toEqual(before);
  });

  test("the guard is back on after the undo too", async () => {
    await expect(
      db.query(`update venues set name = 'Hand Edit' where id = 've_rn33333333'`),
    ).rejects.toThrow(/rename job/);
  });
});

describe.skipIf(skip)("rename undo, when the name moved again", () => {
  let db: Db;
  let close: () => Promise<void>;
  const KEY = "rename-test-happy";
  const SECOND = "rename-test-second";

  beforeAll(async () => {
    const built = await buildRenameDb();
    db = built.db;
    close = built.close;
    expect(
      (await run("apply", ["--csv", HAPPY, "--batch-key", KEY, "--confirm", `RENAME ${KEY}`])).ok,
    ).toBe(true);

    // a second batch renames one of the same venues again, exactly as a later
    // list would
    const path = await csv(
      "second.csv",
      HEADER + `${SECOND},ve_rn11111111,Le Gabriel,Gabriel,michelin,${MICHELIN},\n`,
    );
    expect(
      (await run("apply", ["--csv", path, "--batch-key", SECOND, "--confirm", `RENAME ${SECOND}`]))
        .ok,
    ).toBe(true);
  });
  afterAll(async () => {
    await close();
  });

  test("the first batch's undo refuses and names the venue that moved", async () => {
    const before = await names(db);
    const r = await run("undo", ["--batch-key", KEY, "--confirm", `UNDO-RENAME ${KEY}`]);
    expect(r.ok).toBe(false);
    expect(r.stderr).toContain("ve_rn11111111");
    expect(r.stderr).toContain('is called "Gabriel" now');
    expect(r.stderr).toContain("cannot be undone as it stands");

    const md = report(`${KEY}-rename-undo.md`);
    expect(md).toContain("**REFUSED. Nothing was changed.**");

    // not one of the other two names went back either
    expect(await names(db)).toEqual(before);

    const { rows } = await db.query<{ status: string }>(
      `select status::text from rename_batches where batch_key = $1`,
      [KEY],
    );
    expect(rows[0].status).toBe("applied");
  });

  test("the second batch's own undo still works, and takes only its own row", async () => {
    const r = await run("undo", ["--batch-key", SECOND, "--confirm", `UNDO-RENAME ${SECOND}`]);
    expect(r.stderr).toBe("");
    expect(r.ok).toBe(true);
    expect((await names(db))["ve_rn11111111"]).toBe("Le Gabriel");
    expect((await names(db))["ve_rn33333333"]).toBe("Le Comptoir");
  });
});
