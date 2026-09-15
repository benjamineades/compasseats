-- ============================================================================
-- Phase 2 · rename job · migration 4
-- The fourth button's own bookkeeping: a batch of venue renames, and one row
-- per line of the CSV that produced it (Plan v1.19: "renames get a fourth
-- button, same shape as the others - a CSV of venue id and new name, dry run,
-- one transaction, a ledger row, and a refusal if a venue's current name is
-- not the one the file expected").
--
-- NOT ingest_batches. That table carries a single source_id and a single
-- list_year, because an award list is one publisher in one year. A rename
-- batch is neither: the French file alone follows Michelin's spelling on some
-- rows and another publisher's - or the venue's own website's - on others.
-- Forcing it into ingest_batches would mean either a lie in source_id or a
-- NULL that stops meaning "multi-source" and starts meaning nothing.
--
-- Measured on the live database before writing, 2026-09-15:
--   * `venues` holds 11,258 rows.
--   * `venues` carries BOTH triggers this job depends on -
--     `trg_venue_rename` BEFORE UPDATE (the guard: it refuses any change to
--     venues.name unless the session sets app.allow_rename) and
--     `trg_audit_venues` AFTER INSERT OR UPDATE OR DELETE (the receipt: every
--     rename lands in audit_log with the old and the new row). Neither is
--     created here; both were already there.
--   * Neither table below exists yet, so nothing is migrated - this file only
--     creates.
--
-- The guard flag is set by exactly one thing, in exactly one way: the rename
-- job, with SET LOCAL, inside its own transaction. There is no hand-SQL route
-- and this migration deliberately does not document one.
--
-- Apply with `supabase db push`, or paste this whole file into the Supabase
-- SQL editor. One transaction: it lands whole or not at all.
-- ============================================================================
BEGIN;

CREATE TYPE rename_status_t AS ENUM ('staged', 'applied', 'undone');

CREATE TABLE rename_batches (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  batch_key  text NOT NULL UNIQUE,
  status     rename_status_t NOT NULL DEFAULT 'staged',
  created_at timestamptz NOT NULL DEFAULT now(),
  applied_at timestamptz,
  undone_at  timestamptz,
  note       text
);

COMMENT ON TABLE rename_batches IS
  'One row per rename batch. Kept for ever, undone batches included: history is never deleted.';
COMMENT ON COLUMN rename_batches.batch_key IS
  'The idempotency key Ben types into both rename workflows. One batch per key, for ever - a key that exists is refused whatever its status.';
COMMENT ON COLUMN rename_batches.status IS
  'staged is a transient value inside the apply transaction only. A batch that has committed is applied or undone; a run that did not finish left no row at all.';

CREATE TABLE rename_rows (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  batch_id      bigint NOT NULL REFERENCES rename_batches(id),
  line          integer NOT NULL,
  venue_id      text NOT NULL,
  expected_name text NOT NULL,
  new_name      text NOT NULL,
  source_id     text NOT NULL,
  source_url    text NOT NULL,
  verdict       text NOT NULL,
  detail        jsonb,
  CONSTRAINT rename_rows_line_unique UNIQUE (batch_id, line)
);
CREATE INDEX rename_rows_batch ON rename_rows (batch_id);
CREATE INDEX rename_rows_venue ON rename_rows (venue_id);

COMMENT ON TABLE rename_rows IS
  'One row per line of the rename CSV, with the verdict the apply gave it. The undo reads expected_name back out of here; nothing else does.';
COMMENT ON COLUMN rename_rows.venue_id IS
  'No foreign key on purpose. This is history, and history must never be the thing that stops a venue being deleted later.';
COMMENT ON COLUMN rename_rows.expected_name IS
  'The name the file expected the venue to have. On a rename row it is by construction the name the venue had a moment earlier, and it is what the undo puts back. On a no_change row the venue already carried new_name, and detail->>''live_name'' records what was actually there.';
COMMENT ON COLUMN rename_rows.source_id IS
  'The publisher whose spelling new_name follows. No foreign key to award_sources: the literal value "venue" is allowed and means the venue''s own website settled it, and source_url is that website.';
COMMENT ON COLUMN rename_rows.verdict IS
  'rename or no_change. A batch carrying a reject or a review row never commits, so those verdicts are never stored.';

COMMIT;

-- Three queries to run afterwards, to see that it landed:
--   SELECT count(*) FROM rename_batches;                    -- expect 0
--   SELECT count(*) FROM rename_rows;                       -- expect 0
--   SELECT unnest(enum_range(NULL::rename_status_t));       -- staged/applied/undone
