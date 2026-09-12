-- ============================================================================
-- Phase 2 · ingest importer · migration 1 of 2
-- Adds the idempotency key to ingest_batches (Plan v1.16 §03: "Idempotent by
-- batch ID"). Re-running stage or promote with the same key is a no-op.
--
-- Measured before writing: ingest_batches held 0 rows on 2026-09-10, so the
-- backfill below touches nothing. It exists only so the migration stays safe
-- if a batch lands between now and the moment Ben runs it.
--
-- Apply with `supabase db push`, or paste this whole file into the Supabase
-- SQL editor. It runs as one transaction: it lands whole or not at all.
-- ============================================================================
BEGIN;

ALTER TABLE ingest_batches ADD COLUMN IF NOT EXISTS batch_key text;

UPDATE ingest_batches
   SET batch_key = 'legacy-batch-' || id
 WHERE batch_key IS NULL;

ALTER TABLE ingest_batches ALTER COLUMN batch_key SET NOT NULL;

ALTER TABLE ingest_batches
  ADD CONSTRAINT ingest_batches_batch_key_key UNIQUE (batch_key);

COMMENT ON COLUMN ingest_batches.batch_key IS
  'The idempotency key Ben types into both workflows. One batch per key, for ever.';

COMMIT;
