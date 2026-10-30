-- status-close-slow-low-barcelona.sql
-- Purpose: mark SLOW&LOW (Barcelona, ve_18248f03f5) as closed. Status-only change.
-- Held P2 card pass, Oct 30, 2026 (handoff-price-card-p2-b10-done-2026-10-30, open item 1). Of the 27 held cards:
-- 9 new card path (file price-michelin-card-p2-held-moved-2026-10-30, ledgers 151-152), 15 left the guide with no closure
-- evidence (no write), 3 with closure news. Ben (Oct 30, 2026): close the closed venues, hold Unforgettable (temporary).
-- Café Spice Namasté is also held: the Oct 28, 2026 report calls it "temporarily closed", not a permanent goodbye.
-- Evidence for SLOW&LOW (closure with a date; Sep 28 standing rules):
--   1. Time Out Barcelona, Sep 14, 2026: the restaurant closes as a gastronomic restaurant; last service Oct 17, 2026;
--      the company keeps Bar Canyí (a separate venue):
--      https://www.timeout.es/barcelona/es/noticias/un-chef-con-estrella-michelin-de-barcelona-cierra-su-restaurante-para-centrarse-en-las-tapas-tradicionales-y-nuevos-proyectos-091426
--   2. Directo al Paladar, Sep 22, 2026: closes on Oct 17, 2026:
--      https://www.directoalpaladar.com/viajes/slow-low-anuncia-su-cierre-barcelona-pierde-uno-sus-restaurantes-estrella-michelin
--   3. Michelin card /us/en/catalunya/barcelona/restaurant/slow-low gives 404 (Oct 30, 2026, also /gb/en and /en);
--      not in the Barcelona city list (122 restaurants, read Oct 30, 2026).
-- Award not touched: Michelin 2026 One Star (25603) stays as history. Price row (legacy_guide) not touched.
-- No ledger row (status-only gate; De Groene Lantaarn and Regent precedent).
-- Gates: row md5 before; status before; venue counts before and after; award and price rows unchanged;
-- exactly 1 audit row; only status changed.

BEGIN;

DO $$
DECLARE
  v_id        constant text := 've_18248f03f5';
  v_md5       text;
  v_status    text;
  n_venues    bigint;
  n_active    bigint;
  n_closed    bigint;
  a_max_pre   bigint;
  n_upd       bigint;
  n_audit     bigint;
  n_badaudit  bigint;
  x           bigint;
BEGIN
  -- Gate 1: the row is exactly as read on Oct 30, 2026 (17:0x UTC).
  SELECT md5(to_jsonb(v)::text), v.status::text INTO v_md5, v_status FROM venues v WHERE v.id = v_id;
  IF v_md5 IS DISTINCT FROM 'e13444a7cc5548fc921791f67f64b7bb' THEN
    RAISE EXCEPTION 'Gate 1 failed: venue row md5 is %, expected e13444a7cc5548fc921791f67f64b7bb', v_md5;
  END IF;
  IF v_status IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'Gate 1 failed: status is %, expected active', v_status;
  END IF;

  -- Gate 2: whole-table counts before; ledger and audit max before.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11307::bigint, 10940::bigint, 367::bigint) THEN
    RAISE EXCEPTION 'Gate 2 failed: venues/active/closed = %/%/%, expected 11307/10940/367', n_venues, n_active, n_closed;
  END IF;
  SELECT max(id) INTO x FROM source_capture_ledger;
  IF x <> 152 THEN RAISE EXCEPTION 'Gate 2 failed: ledger max %, expected 152', x; END IF;
  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;
  IF a_max_pre <> 118392 THEN RAISE EXCEPTION 'Gate 2 failed: audit max %, expected 118392', a_max_pre; END IF;

  -- Gate 3: the rows that stay as history.
  SELECT count(*) INTO x FROM awards WHERE venue_id = v_id;
  IF x <> 1 THEN RAISE EXCEPTION 'Gate 3 failed: % award rows, expected 1', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id = 25603 AND venue_id = v_id AND source_id = 'michelin' AND year = 2026 AND category = 'One Star';
  IF x <> 1 THEN RAISE EXCEPTION 'Gate 3 failed: award 25603 changed'; END IF;
  SELECT count(*) INTO x FROM price WHERE venue_id = v_id AND source = 'legacy_guide' AND source_url IS NULL AND tier = 4;
  IF x <> 1 THEN RAISE EXCEPTION 'Gate 3 failed: price row changed'; END IF;

  -- The change.
  UPDATE venues SET status = 'closed' WHERE id = v_id AND status = 'active';
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 1 THEN
    RAISE EXCEPTION 'Update failed: % rows changed, expected 1', n_upd;
  END IF;

  -- Gate 4: whole-table counts after.
  SELECT count(*), count(*) FILTER (WHERE status = 'active'), count(*) FILTER (WHERE status = 'closed')
    INTO n_venues, n_active, n_closed FROM venues;
  IF (n_venues, n_active, n_closed) IS DISTINCT FROM (11307::bigint, 10939::bigint, 368::bigint) THEN
    RAISE EXCEPTION 'Gate 4 failed: venues/active/closed = %/%/%, expected 11307/10939/368', n_venues, n_active, n_closed;
  END IF;
  SELECT max(id) INTO x FROM source_capture_ledger;
  IF x <> 152 THEN RAISE EXCEPTION 'Gate 4 failed: ledger changed (max %)', x; END IF;

  -- Gate 5: exactly 1 new audit row, venues UPDATE on this id, and only status changed (active -> closed).
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre
     AND NOT (table_name = 'venues' AND row_pk = v_id AND action = 'UPDATE'
              AND old_row->>'status' = 'active' AND new_row->>'status' = 'closed'
              AND (old_row - 'status') = (new_row - 'status'));
  IF n_audit <> 1 OR n_badaudit <> 0 THEN
    RAISE EXCEPTION 'Gate 5 failed: % new audit rows (expected 1), % not a status-only venues UPDATE on %', n_audit, n_badaudit, v_id;
  END IF;

  RAISE NOTICE 'OK: % closed. Audit id %.', v_id, a_max_pre + 1;
END
$$;

COMMIT;

-- Read-back (run after the commit):
-- SELECT id, name, status FROM venues WHERE id = 've_18248f03f5';
