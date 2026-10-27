-- name-native-michelin-2026-taiwan.sql
-- Purpose: set venues.name_native for Taiwan venues from the Michelin Chinese card name.
-- Open item 1 (handoff-taiwan-drops-done-2026-10-27): name_native for Taiwan, Ben Q3 A (Oct 11).
-- Population A (182): venues of the batch-17 award rows 29301-29507 (2026 cards), joined to
--   ingest_rows batch 17 by source_url, whose venue_name_zh holds Chinese or Japanese script.
--   The values come from ingest_rows inside this file (not typed). Includes the 29 Chinese-only
--   venues of rename batch 24. The 25 cards with a Latin-only venue_name_zh are skipped.
-- Population B (3): venues of rename batch 26 (no 2026 card). Values from
--   fixtures/rename/michelin-2026-taiwan-drops-names.csv (sha256 9f4ef858...d32530d, Oct 27 cards)
--   and, for Pale Jade Pavilion, docs/handoff-taiwan-contamination-done-2026-10-13.md
--   (sha256 cad9e6f4...ab6786d, Michelin 2025 list, UDN reprint). Option: michelin.
-- Branch part " (...)": keep.
-- name_native only. No name, status, slug, price or award change. No ledger row
--   (China Sep 27 name_native precedent, audit 104,050-104,066).
-- Gates: whole-table counts before; plan count and md5 (A, B, full); every target active, in
--   Taiwan, name_native null, live name as expected (B); target rows md5; counts after;
--   exactly 185 audit rows, venues UPDATE, only name_native changed, pairs md5 = plan.
-- Target rows md5 (Gate 5, read Oct 27, 2026): c1cf12a26560ba19d6cd9238dac97a52.
-- Plan md5 (vid|name_native by vid): A f58794f317f7e9dfb993d70ea33e758a, full 3f86304ce5aec824a2815045c6b89ae0.
--   B (vid|live name|name_native by vid): cb2c3f8a2ab88f6e92529e72c4aa4d27.
-- Dry run: send the whole DO block through the Read connector. It stops at the UPDATE with
--   "read-only transaction".

BEGIN;

DO $$
DECLARE
  n_venues    bigint;
  n_nn        bigint;
  n_plan      bigint;
  n_dist      bigint;
  m_ing       text;
  m_lit       text;
  m_full      text;
  m_rows      text;
  n_bad       bigint;
  a_max_pre   bigint;
  n_upd       bigint;
  n_audit     bigint;
  n_badaudit  bigint;
  m_audit     text;
BEGIN
  -- Gate 1: whole-table counts before.
  SELECT count(*), count(name_native) INTO n_venues, n_nn FROM venues;
  IF (n_venues, n_nn) IS DISTINCT FROM (11291::bigint, 18::bigint) THEN
    RAISE EXCEPTION 'Gate 1 failed: venues/name_native = %/%, expected 11291/18', n_venues, n_nn;
  END IF;

  -- Gate 2: the plan from ingest_rows (population A).
  WITH plan_ing AS (
      SELECT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM awards a
        JOIN ingest_rows r ON r.batch_id = 17 AND r.raw->>'source_url' = a.source_url
       WHERE a.id BETWEEN 29301 AND 29507 AND a.source_id = 'michelin' AND a.year = 2026
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    ), plan_lit(vid, live_name, nn) AS (VALUES
      ('ve_02b8c23984', U&'Mai Yen Shun', U&'\8CE3\5869\9806'),
      ('ve_96994a1e21', U&'Pale Jade Pavilion', U&'\767D\7389\6A13'),
      ('ve_d851917163', U&'Zhu Xin Ju', U&'\7B51\99A8\5C45')
    ), plan AS (
      SELECT vid, nn FROM plan_ing UNION ALL SELECT vid, nn FROM plan_lit
    )
  SELECT count(*), md5(coalesce(string_agg(vid || '|' || nn, E'\n' ORDER BY vid), ''))
    INTO n_plan, m_ing FROM plan_ing;
  IF n_plan <> 182 OR m_ing IS DISTINCT FROM 'f58794f317f7e9dfb993d70ea33e758a' THEN
    RAISE EXCEPTION 'Gate 2 failed: plan A rows %, md5 %, expected 182 / f58794f317f7e9dfb993d70ea33e758a', n_plan, m_ing;
  END IF;

  -- Gate 3: the literal rows (population B) and the full plan.
  WITH plan_ing AS (
      SELECT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM awards a
        JOIN ingest_rows r ON r.batch_id = 17 AND r.raw->>'source_url' = a.source_url
       WHERE a.id BETWEEN 29301 AND 29507 AND a.source_id = 'michelin' AND a.year = 2026
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    ), plan_lit(vid, live_name, nn) AS (VALUES
      ('ve_02b8c23984', U&'Mai Yen Shun', U&'\8CE3\5869\9806'),
      ('ve_96994a1e21', U&'Pale Jade Pavilion', U&'\767D\7389\6A13'),
      ('ve_d851917163', U&'Zhu Xin Ju', U&'\7B51\99A8\5C45')
    ), plan AS (
      SELECT vid, nn FROM plan_ing UNION ALL SELECT vid, nn FROM plan_lit
    )
  SELECT (SELECT md5(string_agg(vid || '|' || live_name || '|' || nn, E'\n' ORDER BY vid)) FROM plan_lit),
         (SELECT md5(string_agg(vid || '|' || nn, E'\n' ORDER BY vid)) FROM plan),
         (SELECT count(*) FROM plan), (SELECT count(DISTINCT vid) FROM plan)
    INTO m_lit, m_full, n_plan, n_dist;
  IF m_lit IS DISTINCT FROM 'cb2c3f8a2ab88f6e92529e72c4aa4d27' OR m_full IS DISTINCT FROM '3f86304ce5aec824a2815045c6b89ae0'
     OR n_plan <> 185 OR n_dist <> 185 THEN
    RAISE EXCEPTION 'Gate 3 failed: B md5 %, full md5 %, rows %, distinct %', m_lit, m_full, n_plan, n_dist;
  END IF;

  -- Gate 4: every target is active, in Taiwan, has no name_native; B live names as expected.
  WITH plan_ing AS (
      SELECT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM awards a
        JOIN ingest_rows r ON r.batch_id = 17 AND r.raw->>'source_url' = a.source_url
       WHERE a.id BETWEEN 29301 AND 29507 AND a.source_id = 'michelin' AND a.year = 2026
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    ), plan_lit(vid, live_name, nn) AS (VALUES
      ('ve_02b8c23984', U&'Mai Yen Shun', U&'\8CE3\5869\9806'),
      ('ve_96994a1e21', U&'Pale Jade Pavilion', U&'\767D\7389\6A13'),
      ('ve_d851917163', U&'Zhu Xin Ju', U&'\7B51\99A8\5C45')
    ), plan AS (
      SELECT vid, nn FROM plan_ing UNION ALL SELECT vid, nn FROM plan_lit
    )
  SELECT count(*) INTO n_bad
    FROM plan p
    LEFT JOIN venues v ON v.id = p.vid
    LEFT JOIN cities c ON c.id = v.city_id
    LEFT JOIN plan_lit l ON l.vid = p.vid
   WHERE v.id IS NULL OR v.status::text <> 'active' OR c.country IS DISTINCT FROM 'Taiwan'
      OR v.name_native IS NOT NULL OR (l.vid IS NOT NULL AND v.name IS DISTINCT FROM l.live_name);
  IF n_bad <> 0 THEN
    RAISE EXCEPTION 'Gate 4 failed: % target rows not active, not Taiwan, already set or renamed', n_bad;
  END IF;

  -- Gate 5: the target rows are exactly as read on Oct 27, 2026.
  WITH plan_ing AS (
      SELECT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM awards a
        JOIN ingest_rows r ON r.batch_id = 17 AND r.raw->>'source_url' = a.source_url
       WHERE a.id BETWEEN 29301 AND 29507 AND a.source_id = 'michelin' AND a.year = 2026
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    ), plan_lit(vid, live_name, nn) AS (VALUES
      ('ve_02b8c23984', U&'Mai Yen Shun', U&'\8CE3\5869\9806'),
      ('ve_96994a1e21', U&'Pale Jade Pavilion', U&'\767D\7389\6A13'),
      ('ve_d851917163', U&'Zhu Xin Ju', U&'\7B51\99A8\5C45')
    ), plan AS (
      SELECT vid, nn FROM plan_ing UNION ALL SELECT vid, nn FROM plan_lit
    )
  SELECT md5(string_agg(md5(to_jsonb(v)::text), '' ORDER BY v.id)) INTO m_rows
    FROM venues v WHERE v.id IN (SELECT vid FROM plan);
  IF m_rows IS DISTINCT FROM 'c1cf12a26560ba19d6cd9238dac97a52' THEN
    RAISE EXCEPTION 'Gate 5 failed: target rows md5 %, expected c1cf12a26560ba19d6cd9238dac97a52', m_rows;
  END IF;

  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;

  -- The change.
  WITH plan_ing AS (
      SELECT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM awards a
        JOIN ingest_rows r ON r.batch_id = 17 AND r.raw->>'source_url' = a.source_url
       WHERE a.id BETWEEN 29301 AND 29507 AND a.source_id = 'michelin' AND a.year = 2026
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    ), plan_lit(vid, live_name, nn) AS (VALUES
      ('ve_02b8c23984', U&'Mai Yen Shun', U&'\8CE3\5869\9806'),
      ('ve_96994a1e21', U&'Pale Jade Pavilion', U&'\767D\7389\6A13'),
      ('ve_d851917163', U&'Zhu Xin Ju', U&'\7B51\99A8\5C45')
    ), plan AS (
      SELECT vid, nn FROM plan_ing UNION ALL SELECT vid, nn FROM plan_lit
    )
  UPDATE venues v SET name_native = p.nn
    FROM plan p
   WHERE v.id = p.vid AND v.name_native IS NULL;
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 185 THEN
    RAISE EXCEPTION 'Update failed: % rows changed, expected 185', n_upd;
  END IF;

  -- Gate 6: whole-table counts after.
  SELECT count(*), count(name_native) INTO n_venues, n_nn FROM venues;
  IF (n_venues, n_nn) IS DISTINCT FROM (11291::bigint, 203::bigint) THEN
    RAISE EXCEPTION 'Gate 6 failed: venues/name_native = %/%, expected 11291/203', n_venues, n_nn;
  END IF;

  -- Gate 7: exactly 185 new audit rows, venues UPDATE, only name_native changed (null -> value),
  --         and the audit pairs md5 = the full plan md5.
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre
     AND NOT (table_name = 'venues' AND action = 'UPDATE'
              AND old_row->>'name_native' IS NULL AND new_row->>'name_native' IS NOT NULL
              AND (old_row - 'name_native') = (new_row - 'name_native'));
  SELECT md5(string_agg(row_pk || '|' || (new_row->>'name_native'), E'\n' ORDER BY row_pk)) INTO m_audit
    FROM audit_log WHERE id > a_max_pre;
  IF n_audit <> 185 OR n_badaudit <> 0 OR m_audit IS DISTINCT FROM '3f86304ce5aec824a2815045c6b89ae0' THEN
    RAISE EXCEPTION 'Gate 7 failed: % audit rows (expected 185), % not name_native-only, md5 %', n_audit, n_badaudit, m_audit;
  END IF;

  RAISE NOTICE 'OK: name_native set on % venues. Audit ids % to %.', n_upd, a_max_pre + 1, a_max_pre + n_audit;
END
$$;

COMMIT;

-- Read-back (run after the commit):
-- SELECT count(name_native) FROM venues;  -- expect 203
-- SELECT v.id, v.name, v.name_native FROM venues v JOIN cities c ON c.id = v.city_id
--  WHERE c.country = 'Taiwan' AND v.name_native IS NOT NULL ORDER BY v.id;
