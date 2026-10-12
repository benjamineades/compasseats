-- status-active-jl-studio-taichung.sql
-- Purpose: mark JL STUDIO (Taichung, ve_506425696b) as active. Status-only change.
-- Open item 1 (handoff-taiwan-promoted-2026-10-11): JL STUDIO status.
-- The 'closed' value came from the legacy import (audit 3312, INSERT Aug 14, 2026; audit 67636 kept it).
-- Rule (Germany cleanup precedent, docs/cleanup-michelin-de-status-active.sql): the venue holds a live
-- 2026 Michelin card and current evidence shows it open. No closure notice. No evidence conflicts.
-- Evidence (read Oct 11, 2026):
--   1. Live 2026 Michelin card, Three Stars, no closure note (Taiwan capture log, card price $$$$, address
--      "...West District, Taichung"): https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/jl-studio
--      Award 29301 (batch 17, promoted Oct 12 00:49:54 UTC).
--   2. 2026 Taiwan star list article prints "JL Studio" in the Three Stars block; no entry marked closed.
--   3. TVBS, Aug 15, 2026: JL Studio reopened in a new space (the former site of Le Mout, where the chef
--      worked for eight years): https://cars.tvbs.com.tw/life/337454
--   4. Asia's 50 Best Restaurants 2026 No. 50 (award 1199) is on the venue.
-- Awards not touched (11 rows). Blurb not touched (1 row, status needs_rewrite).
-- No ledger row (status-only gate; Regent and De Groene Lantaarn precedent).
-- Gates: row md5 before; status before; the live card row; venue counts before and after;
--        exactly 1 audit row; only status changed.
-- Dry run: send the whole DO block through the Read connector. It stops at the UPDATE with
--   "read-only transaction".

BEGIN;

DO $$
DECLARE
  v_id        constant text := 've_506425696b';
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
  -- Gate 1: the row is exactly as read on Oct 11, 2026 (21:1x Atlanta).
  SELECT md5(to_jsonb(v)::text), v.status::text INTO v_md5, v_status FROM venues v WHERE v.id = v_id;
  IF v_md5 IS DISTINCT FROM '644a7737c8f603b3b4fc8c680f65b6d9' THEN
    RAISE EXCEPTION 'Gate 1 failed: venue row md5 is %, expected 644a7737c8f603b3b4fc8c680f65b6d9', v_md5;
  END IF;
  IF v_status IS DISTINCT FROM 'closed' THEN
    RAISE EXCEPTION 'Gate 1 failed: status is %, expected closed', v_status;
  END IF;

  -- Gate 1b: the live 2026 card row sits on this venue.
  SELECT count(*) INTO n_upd FROM awards
   WHERE id = 29301 AND venue_id = v_id AND source_id = 'michelin' AND year = 2026
     AND category = 'Three Stars'
     AND source_url = 'https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/jl-studio';
  IF n_upd <> 1 THEN
    RAISE EXCEPTION 'Gate 1b failed: live card rows %, expected 1', n_upd;
  END IF;

  -- Gate 2: whole-table counts before.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11315::bigint, 10947::bigint, 368::bigint) THEN
    RAISE EXCEPTION 'Gate 2 failed: venues/active/closed = %/%/%, expected 11315/10947/368', n_venues, n_active, n_closed;
  END IF;

  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;

  -- The change.
  UPDATE venues SET status = 'active' WHERE id = v_id AND status = 'closed';
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 1 THEN
    RAISE EXCEPTION 'Update failed: % rows changed, expected 1', n_upd;
  END IF;

  -- Gate 3: whole-table counts after.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11315::bigint, 10948::bigint, 367::bigint) THEN
    RAISE EXCEPTION 'Gate 3 failed: venues/active/closed = %/%/%, expected 11315/10948/367', n_venues, n_active, n_closed;
  END IF;

  -- Gate 4: exactly 1 new audit row, venues UPDATE on this id, and only status changed (closed -> active).
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre
     AND NOT (table_name = 'venues' AND row_pk = v_id AND action = 'UPDATE'
              AND old_row->>'status' = 'closed' AND new_row->>'status' = 'active'
              AND (old_row - 'status') = (new_row - 'status'));
  IF n_audit <> 1 OR n_badaudit <> 0 THEN
    RAISE EXCEPTION 'Gate 4 failed: % new audit rows (expected 1), % not a status-only venues UPDATE on %', n_audit, n_badaudit, v_id;
  END IF;

  RAISE NOTICE 'OK: % active. Audit id %.', v_id, a_max_pre + 1;
END
$$;

COMMIT;

-- Read-back (run after the commit):
-- SELECT id, name, status FROM venues WHERE id = 've_506425696b';
