-- status-close-de-groene-lantaarn.sql
-- Purpose: mark De Groene Lantaarn (Staphorst, ve_fa28a0b2dd) as closed. Status-only change.
-- Ben's decision, Oct 10, 2026: mark Demain, Spectrum and De Groene Lantaarn closed; keep De Juwelier open.
--   Demain (ve_9a294cfd32) and Spectrum (ve_e75c1b364b) were already closed: no write.
--   De Juwelier (ve_8a277bc814) stays active and keeps Michelin 2025 One Star row 3680 as history: no write.
-- Evidence (Michelin-closed venue rule, Sep 28 standing rules):
--   1. Ceremony article, Oct 5, 2026, says De Groene Lantaarn "closed earlier this year":
--      https://guide.michelin.com/en/article/michelin-guide-ceremony/azurite-and-suis-awarded-two-michelin-stars-each-in-the-2026-netherlands-michelin-guide
--   2. Michelin venue page shows "Restaurant niet gevonden" (Oct 10, 2026):
--      https://guide.michelin.com/nl/nl/overijssel/staphorst/restaurant/de-groene-lantaarn
-- Awards are not touched: Best Chef 2024 (15957), Best Chef 2025 (15956), La Liste 2026 (15958) stay as history.
-- No ledger row (status-only gate; GB&I and Germany precedent, audit 108,051-108,052).
-- Gates: row md5 before; status before; venue counts before and after; exactly 1 audit row; only status changed.

BEGIN;

DO $$
DECLARE
  v_id        constant text := 've_fa28a0b2dd';
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
  -- Gate 1: the row is exactly as read on Oct 10, 2026 (22:5x Atlanta).
  SELECT md5(to_jsonb(v)::text), v.status::text INTO v_md5, v_status FROM venues v WHERE v.id = v_id;
  IF v_md5 IS DISTINCT FROM 'e0cdfddefc3216e0ec86677ceb043200' THEN
    RAISE EXCEPTION 'Gate 1 failed: venue row md5 is %, expected e0cdfddefc3216e0ec86677ceb043200', v_md5;
  END IF;
  IF v_status IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'Gate 1 failed: status is %, expected active', v_status;
  END IF;

  -- Gate 2: whole-table counts before.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11233::bigint, 10867::bigint, 366::bigint) THEN
    RAISE EXCEPTION 'Gate 2 failed: venues/active/closed = %/%/%, expected 11233/10867/366', n_venues, n_active, n_closed;
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
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11233::bigint, 10866::bigint, 367::bigint) THEN
    RAISE EXCEPTION 'Gate 3 failed: venues/active/closed = %/%/%, expected 11233/10866/367', n_venues, n_active, n_closed;
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
-- SELECT id, name, status FROM venues WHERE id IN ('ve_fa28a0b2dd','ve_9a294cfd32','ve_e75c1b364b','ve_8a277bc814') ORDER BY name;
