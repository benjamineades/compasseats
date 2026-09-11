import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

import { connectTo, type Db } from "../lib/db.ts";

/**
 * A disposable database for the ingest tests.
 *
 * Built from the repo's own canonical schema (docs/compass-schema-v1.sql) plus
 * the two Phase 2 migrations, so the tests run against the same DDL the live
 * project has - not a hand-written approximation that can drift from it.
 */

export const TEST_DB_URL = process.env.INGEST_TEST_DB_URL ?? "";

/**
 * One piece of measured drift, applied here and NOT as a migration.
 *
 * The live norm_key() returns NULL for keys under three characters (the Aug 11
 * dedupe rule: all-CJK names never auto-group). docs/compass-schema-v1.sql was
 * written before that and still has the older body. Live is already correct,
 * so there is nothing to migrate - the test database just has to match live.
 * Flagged so the schema doc gets fixed separately.
 */
const NORM_KEY_AS_LIVE = `
CREATE OR REPLACE FUNCTION norm_key(text)
  RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
  AS $$
    SELECT CASE
      WHEN length(regexp_replace(lower(f_unaccent($1)), '[^a-z0-9]+', '', 'g')) < 3
        THEN NULL
      ELSE regexp_replace(lower(f_unaccent($1)), '[^a-z0-9]+', '', 'g')
    END
  $$;
`;

export async function buildTestDb(
  repoRoot: string,
): Promise<{ db: Db; close: () => Promise<void> }> {
  if (!TEST_DB_URL) {
    throw new Error(
      "INGEST_TEST_DB_URL is not set. These tests need a throwaway Postgres - " +
        "never point them at the live project.",
    );
  }
  const { client: db, close } = await connectTo(TEST_DB_URL);

  await db.query(`drop schema if exists public cascade; create schema public;`);
  await db.query(readFileSync(join(repoRoot, "docs/compass-schema-v1.sql"), "utf8"));
  await db.query(NORM_KEY_AS_LIVE);

  const migrationDir = join(repoRoot, "supabase/migrations");
  for (const file of readdirSync(migrationDir).sort()) {
    if (!file.endsWith(".sql")) continue;
    await db.query(readFileSync(join(migrationDir, file), "utf8"));
  }

  await db.query(readFileSync(join(repoRoot, "scripts/ingest/test/seed.sql"), "utf8"));
  return { db, close };
}

export async function counts(db: Db): Promise<Record<string, number>> {
  const { rows } = await db.query<{ k: string; n: string }>(`
    select 'venues' k, count(*)::text n from venues
    union all select 'awards', count(*)::text from awards
    union all select 'listings', count(*)::text from listings
    union all select 'slugs', count(*)::text from slugs
    union all select 'city_label_source', count(*)::text from city_label_source
    union all select 'price', count(*)::text from price
    union all select 'source_capture_ledger', count(*)::text from source_capture_ledger
    union all select 'ingest_batches', count(*)::text from ingest_batches
    union all select 'ingest_rows', count(*)::text from ingest_rows
  `);
  const out: Record<string, number> = {};
  for (const r of rows) out[r.k] = Number(r.n);
  return out;
}

export async function verdicts(db: Db, batchKey: string): Promise<Record<string, number>> {
  const { rows } = await db.query<{ verdict: string; n: string }>(
    `select r.verdict, count(*)::text n
       from ingest_rows r join ingest_batches b on b.id = r.batch_id
      where b.batch_key = $1 group by 1`,
    [batchKey],
  );
  const out: Record<string, number> = {};
  for (const r of rows) out[r.verdict ?? "null"] = Number(r.n);
  return out;
}
