-- ============================================================================
-- Phase 2 · ingest importer · migration 2 of 2
-- The per-source controlled category vocabulary (Plan v1.16, Phase 2 addendum,
-- Ruling 5: "Category vocabulary per source is a controlled list validated at
-- ingest"). Seeded from what is already in `awards`. Never auto-extended by a
-- job — Ben adds a row by hand and re-stages under a new batch key.
--
-- READ THIS BEFORE YOU TRUST THE SEED COUNTS.
-- Measured on the live table 2026-09-10: for 13 of the 21 sources that hold
-- awards, `category` is not a vocabulary at all — it is the rank written out
-- ("No. 1" … "No. 673" for OAD, 500 of them for Top 500 Bars) or a score
-- ("75.5/100" for La Liste). Only these 8 carry a real vocabulary:
--   michelin (11), james-beard (37), gault-millau (34), spirited-awards (23),
--   best-chef-awards (3), pinnacle-guide (3), forbes-travel-guide (2),
--   wine-spectator (1).
-- The seed below therefore contains ~1,900 rows, most of them rank strings.
-- The importer handles this with a narrow, documented exception: a category of
-- the exact form "No. <n>" is accepted when <n> equals that row's own rank,
-- even if it is not in this table. A typo still cannot get in (the number has
-- to match the rank), and a 51-100 backfill is not rejected for ranks the
-- database has simply never seen. Everything else must be in this table.
--
-- Two known contaminations, left alone here because this migration only copies
-- what exists — flagged for the cleanup list, not fixed by a seed:
--   asia-50-best-restaurants holds "3 Knives" (a best-chef-awards value) and
--   "99.5/100" (a la-liste value).
--
-- Apply with `supabase db push`, or paste this whole file into the Supabase
-- SQL editor. One transaction: it lands whole or not at all.
-- ============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS award_categories (
  source_id text NOT NULL REFERENCES award_sources(slug),
  category  text NOT NULL,
  PRIMARY KEY (source_id, category)
);

COMMENT ON TABLE award_categories IS
  'Ruling 5 controlled vocabulary, per source. Ingest rejects a category absent '
  'from here (reason: unknown_category), except an exact "No. <rank>" echo. '
  'Never written by a job.';

INSERT INTO award_categories (source_id, category)
SELECT DISTINCT source_id, category
  FROM awards
 WHERE category IS NOT NULL
   AND btrim(category) <> ''
ON CONFLICT DO NOTHING;

COMMIT;

-- Seed counts per source, for the record. Run this after applying:
--   SELECT source_id, count(*) AS categories
--     FROM award_categories GROUP BY 1 ORDER BY 2 DESC, 1;
