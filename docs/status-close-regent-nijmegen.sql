-- status-close-regent-nijmegen.sql
-- Purpose: mark Regent (Bistrot Regent, Nijmegen, ve_7b3edc3520) as closed. Status-only change.
-- Open item 2 (handoff-netherlands-slugs-done-2026-10-11): Netherlands status items.
-- Population read Oct 11, 2026: 10 venues (Restaurant Daalder*, Da Vinci, Sense, and the 7 dropped
-- Bibs with legacy rows). 9 have no closure evidence and stay active (no write). 1 closes (this file).
-- Evidence (closure with a date; Sep 28 standing rules):
--   1. Venue site regent-nijmegen.nl (read Oct 11, 2026; page modified Jul 15, 2026): the owners say
--      they close the doors; last menu service through June 28; address Hertogstraat 71, Nijmegen.
--   2. ChefsFriends, May 12, 2026: Bib Gourmand restaurant Bistrot Regent closes; last day Sunday June 28, 2026:
--      https://chefsfriends.nl/bib-gourmand-restaurant-in-nijmegen-kondigt-sluiting-aan/
--   3. Not on the 2026 Bib list. Michelin page /us/en/gelderland/nijmegen/restaurant/bistrot-regent
--      gives "Restaurant not found" (404, Oct 11, 2026).
-- Award not touched: Michelin 2025 Bib Gourmand (11431) stays as history.
-- No ledger row (status-only gate; De Groene Lantaarn precedent, audit 110,369).
-- Gates: row md5 before; status before; venue counts before and after; exactly 1 audit row; only status changed.

BEGIN;

DO $$
DECLARE
  v_id        constant text := 've_7b3edc3520';
  v_md5       text;
  v_status    text;
  n_venues    bigint;
  n_active    bigint;
  n_closed    bigint;
  a_max_pre   bigint;
  n_upd       bigint;
  n_audit     bigint;
  n_badaudit  bigint;
BEGIN
  -- Gate 1: the row is exactly as read on Oct 11, 2026 (16:3x Atlanta).
  SELECT md5(to_jsonb(v)::text), v.status::text INTO v_md5, v_status FROM venues v WHERE v.id = v_id;
  IF v_md5 IS DISTINCT FROM '0646b7e8be6fb591bd7b6bbf5f50c3e3' THEN
    RAISE EXCEPTION 'Gate 1 failed: venue row md5 is %, expected 0646b7e8be6fb591bd7b6bbf5f50c3e3', v_md5;
  END IF;
  IF v_status IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'Gate 1 failed: status is %, expected active', v_status;
  END IF;

  -- Gate 2: whole-table counts before.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11254::bigint, 10887::bigint, 367::bigint) THEN
    RAISE EXCEPTION 'Gate 2 failed: venues/active/closed = %/%/%, expected 11254/10887/367', n_venues, n_active, n_closed;
  END IF;

  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;

  -- The change.
  UPDATE venues SET status = 'closed' WHERE id = v_id AND status = 'active';
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 1 THEN
    RAISE EXCEPTION 'Update failed: % rows changed, expected 1', n_upd;
  END IF;

  -- Gate 3: whole-table counts after.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11254::bigint, 10886::bigint, 368::bigint) THEN
    RAISE EXCEPTION 'Gate 3 failed: venues/active/closed = %/%/%, expected 11254/10886/368', n_venues, n_active, n_closed;
  END IF;

  -- Gate 4: exactly 1 new audit row, venues UPDATE on this id, and only status changed (active -> closed).
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre
     AND NOT (table_name = 'venues' AND row_pk = v_id AND action = 'UPDATE'
              AND old_row->>'status' = 'active' AND new_row->>'status' = 'closed'
              AND (old_row - 'status') = (new_row - 'status'));
  IF n_audit <> 1 OR n_badaudit <> 0 THEN
    RAISE EXCEPTION 'Gate 4 failed: % new audit rows (expected 1), % not a status-only venues UPDATE on %', n_audit, n_badaudit, v_id;
  END IF;

  RAISE NOTICE 'OK: % closed. Audit id %.', v_id, a_max_pre + 1;
END
$$;

COMMIT;

-- Read-back (run after the commit):
-- SELECT id, name, status FROM venues WHERE id = 've_7b3edc3520';
