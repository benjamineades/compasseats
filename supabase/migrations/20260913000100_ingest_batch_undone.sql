-- ============================================================================
-- Phase 2 · ingest undo · migration 3
-- Gives a promoted batch somewhere to go when it is reversed.
--
-- Two additions, both additive:
--   * batch_status_t gains 'undone'. A reversed batch keeps its ingest_batches
--     row and all of its ingest_rows for ever - history is never deleted - so
--     the status is the only thing that records the reversal.
--   * ingest_batches.undone_at records when it happened.
--
-- 'undone' is deliberately NOT a status promote will run on. promote requires
-- 'staged', so an undone batch can never be re-promoted under the same key:
-- re-landing the same list means staging it again under a NEW key, with a fresh
-- report read against the database as it is then.
--
-- Measured before writing: on 2026-09-12 ingest_batches held 1 row
-- (first-batch-2026-09, status 'promoted'). Neither statement below touches it.
--
-- Apply with `supabase db push`, or paste this whole file into the Supabase SQL
-- editor. One transaction: it lands whole or not at all.
--
-- ALTER TYPE ... ADD VALUE inside a transaction block is allowed on PostgreSQL
-- 12 and later (Supabase is 15+); the only restriction is that the new value
-- cannot be *used* in the same transaction, and nothing here uses it.
-- ============================================================================
BEGIN;

ALTER TYPE batch_status_t ADD VALUE IF NOT EXISTS 'undone';

ALTER TABLE ingest_batches ADD COLUMN IF NOT EXISTS undone_at timestamptz;

COMMENT ON COLUMN ingest_batches.undone_at IS
  'When the undo job reversed this batch. Set once, with status = undone. The batch row and its ingest_rows stay for ever.';

COMMIT;
