-- name-native-michelin-2026-hong-kong-macau.sql
-- Purpose: set venues.name_native for Hong Kong and Macau venues from the Michelin Chinese card name.
-- Open item 1 (handoff-hkmo-renamed-2026-11-01): HK/MO name_native from venue_name_zh.
-- Population: venues of the 2026 Michelin award rows whose source_url = a card in ingest_rows batch 19
--   (michelin-2026-hong-kong-macau, 180 cards, 180 venues). 135 cards hold Chinese script and are set.
--   45 cards with a Latin-only venue_name_zh are skipped (name_native stays null, Taiwan precedent).
--   The 5 Green Star 2026 rows (30131-30135) share a card URL with a star row; DISTINCT gives 1 row per venue.
-- Option A: card venue_name_zh as written; branch part " (...)" kept (Taiwan precedent).
-- name_native only. No name, status, slug, price or award change. No ledger row
--   (China Sep 27 and Taiwan Oct 27 name_native precedent).
-- Gates: whole-table counts and last audit id before; plan count and md5; every target active, in
--   Hong Kong or Macao, name_native null; target rows md5; counts after; exactly 135 audit rows,
--   venues UPDATE, only name_native changed, pairs md5 = plan.
-- Target rows md5 (Gate 4, read Nov 1, 2026): 6dcc463166ccb76016be404d70968b76.
-- Plan md5 (vid|name_native by vid): 8823c9956c7fd990dc41a2d084d545ac.
-- Built by docs/hkmo-2026-build/build_name_native_hkmo_2026_11_01.py A.
-- Dry run: send the whole DO block through the Read connector. It stops at the UPDATE with
--   "read-only transaction".

BEGIN;

DO $$
DECLARE
  n_venues    bigint;
  n_nn        bigint;
  n_awards    bigint;
  n_slugs     bigint;
  n_plan      bigint;
  n_dist      bigint;
  m_plan      text;
  m_rows      text;
  n_bad       bigint;
  a_max_pre   bigint;
  n_upd       bigint;
  n_audit     bigint;
  n_badaudit  bigint;
  m_audit     text;
BEGIN
  -- Gate 1: whole-table counts and last audit id before.
  SELECT count(*), count(name_native) INTO n_venues, n_nn FROM venues;
  SELECT count(*) INTO n_awards FROM awards;
  SELECT count(*) INTO n_slugs FROM slugs;
  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;
  IF (n_venues, n_nn, n_awards, n_slugs, a_max_pre)
     IS DISTINCT FROM (11300::bigint, 203::bigint, 23368::bigint, 13001::bigint, 121259::bigint) THEN
    RAISE EXCEPTION 'Gate 1 failed: venues/name_native/awards/slugs/audit max = %/%/%/%/%, expected 11300/203/23368/13001/121259',
      n_venues, n_nn, n_awards, n_slugs, a_max_pre;
  END IF;

  -- Gate 2: the plan, read from ingest_rows batch 19.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
        JOIN venues v ON v.id = a.venue_id
       WHERE r.batch_id = 19
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    )
  SELECT count(*), count(DISTINCT vid), md5(coalesce(string_agg(vid || '|' || nn, E'\n' ORDER BY vid), ''))
    INTO n_plan, n_dist, m_plan FROM plan;
  IF n_plan <> 135 OR n_dist <> 135 OR m_plan IS DISTINCT FROM '8823c9956c7fd990dc41a2d084d545ac' THEN
    RAISE EXCEPTION 'Gate 2 failed: plan rows %, distinct %, md5 %, expected 135 / 135 / 8823c9956c7fd990dc41a2d084d545ac', n_plan, n_dist, m_plan;
  END IF;

  -- Gate 3: every target is active, in Hong Kong or Macao, and has no name_native.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
        JOIN venues v ON v.id = a.venue_id
       WHERE r.batch_id = 19
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    )
  SELECT count(*) INTO n_bad
    FROM plan p
    LEFT JOIN venues v ON v.id = p.vid
    LEFT JOIN cities c ON c.id = v.city_id
   WHERE v.id IS NULL OR v.status::text <> 'active' OR c.country NOT IN ('Hong Kong', 'Macao')
      OR c.country IS NULL OR v.name_native IS NOT NULL;
  IF n_bad <> 0 THEN
    RAISE EXCEPTION 'Gate 3 failed: % target rows not active, not Hong Kong/Macao, or already set', n_bad;
  END IF;

  -- Gate 4: the target rows are exactly as read on Nov 1, 2026.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
        JOIN venues v ON v.id = a.venue_id
       WHERE r.batch_id = 19
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    )
  SELECT md5(string_agg(md5(to_jsonb(v)::text), '' ORDER BY v.id)) INTO m_rows
    FROM venues v WHERE v.id IN (SELECT vid FROM plan);
  IF m_rows IS DISTINCT FROM '6dcc463166ccb76016be404d70968b76' THEN
    RAISE EXCEPTION 'Gate 4 failed: target rows md5 %, expected 6dcc463166ccb76016be404d70968b76', m_rows;
  END IF;

  -- The change.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'venue_name_zh' AS nn
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
        JOIN venues v ON v.id = a.venue_id
       WHERE r.batch_id = 19
         AND r.raw->>'venue_name_zh' ~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'
    )
  UPDATE venues v SET name_native = p.nn
    FROM plan p
   WHERE v.id = p.vid AND v.name_native IS NULL;
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 135 THEN
    RAISE EXCEPTION 'Update failed: % rows changed, expected 135', n_upd;
  END IF;

  -- Gate 5: whole-table counts after.
  SELECT count(*), count(name_native) INTO n_venues, n_nn FROM venues;
  SELECT count(*) INTO n_awards FROM awards;
  SELECT count(*) INTO n_slugs FROM slugs;
  IF (n_venues, n_nn, n_awards, n_slugs)
     IS DISTINCT FROM (11300::bigint, 338::bigint, 23368::bigint, 13001::bigint) THEN
    RAISE EXCEPTION 'Gate 5 failed: venues/name_native/awards/slugs = %/%/%/%, expected 11300/338/23368/13001',
      n_venues, n_nn, n_awards, n_slugs;
  END IF;

  -- Gate 6: exactly 135 new audit rows, venues UPDATE, only name_native changed (null -> value),
  --         and the audit pairs md5 = the plan md5.
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre
     AND NOT (table_name = 'venues' AND action = 'UPDATE'
              AND old_row->>'name_native' IS NULL AND new_row->>'name_native' IS NOT NULL
              AND (old_row - 'name_native') = (new_row - 'name_native'));
  SELECT md5(string_agg(row_pk || '|' || (new_row->>'name_native'), E'\n' ORDER BY row_pk)) INTO m_audit
    FROM audit_log WHERE id > a_max_pre;
  IF n_audit <> 135 OR n_badaudit <> 0 OR m_audit IS DISTINCT FROM '8823c9956c7fd990dc41a2d084d545ac' THEN
    RAISE EXCEPTION 'Gate 6 failed: % audit rows (expected 135), % not name_native-only, md5 %', n_audit, n_badaudit, m_audit;
  END IF;

  RAISE NOTICE 'OK: name_native set on % venues. Audit ids % to %.', n_upd, a_max_pre + 1, a_max_pre + n_audit;
END
$$;

COMMIT;

-- Read-back (run after the commit):
-- SELECT count(name_native) FROM venues;  -- expect 338
-- SELECT v.id, v.name, v.name_native FROM venues v JOIN cities c ON c.id = v.city_id
--  WHERE c.country IN ('Hong Kong', 'Macao') AND v.name_native IS NOT NULL ORDER BY v.id;
