-- cities-venues-count-recount-2026-10-31.sql
-- Open items block 4, item 2, option B part 1 (Ben, Oct 31, 2026 00:09 ET "2. b"): recount cities.venues_count once.
-- Definition (as in docs/cities-jackson-wy-split.sql): venues_count = number of venues with status 'active' in the city.
-- Population: all 3,259 cities. Read Oct 31 ~04:12 UTC: 259 cities differ (212 too low, 47 too high); 3,000 match.
-- Rows: 259 UPDATE of cities.venues_count only. No other column, no other table. No ledger row (city edits have none).
-- Part 2 (separate migration supabase/migrations/20261031000100_city_venue_counts_view.sql) adds a live-count view.
-- Gates (PRE): cities 3,259; venues 11,303 (active 10,934); ledger max 172; audit max 119,112;
--   md5 of all cities id|venues_count (by id) 0b65621e48af26068dad1875f0f8cf8f;
--   plan md5 a31795e2d78dd2d91dd1336432e2edd4 (md5 of id|old|new lines of the 259 cities that differ, by id COLLATE "C").
-- Post-checks: 259 rows updated; 0 cities differ from the live active count; sum of venues_count 10,934;
--   audit: exactly 259 new rows, all cities UPDATE, each changes venues_count only and to the planned value;
--   ledger max still 172; cities 3,259.
BEGIN;
DO $do$
DECLARE
  v_plan text;
  v_all  text;
  rel    jsonb;
  v_n    int;
  v_upd  int;
BEGIN
  IF (SELECT count(*) FROM cities) <> 3259 THEN RAISE EXCEPTION 'cities before is not 3259'; END IF;
  IF (SELECT count(*) FROM venues) <> 11303 THEN RAISE EXCEPTION 'venues before is not 11303'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10934 THEN RAISE EXCEPTION 'active venues before is not 10934'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 172 THEN RAISE EXCEPTION 'ledger max before is not 172'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119112 THEN RAISE EXCEPTION 'audit max before is not 119112'; END IF;

  SELECT md5(string_agg(c.id||'|'||c.venues_count, E'\n' ORDER BY c.id COLLATE "C")) INTO v_all FROM cities c;
  IF v_all IS DISTINCT FROM '0b65621e48af26068dad1875f0f8cf8f' THEN RAISE EXCEPTION 'cities venues_count md5 %', v_all; END IF;

  SELECT jsonb_agg(jsonb_build_object('id', id, 'old_n', old_n, 'new_n', new_n) ORDER BY id COLLATE "C"),
         count(*), md5(string_agg(id||'|'||old_n||'|'||new_n, E'\n' ORDER BY id COLLATE "C"))
    INTO rel, v_n, v_plan
    FROM (SELECT c.id, c.venues_count AS old_n, count(v.id) FILTER (WHERE v.status = 'active')::int AS new_n
            FROM cities c LEFT JOIN venues v ON v.city_id = c.id
           GROUP BY c.id, c.venues_count
          HAVING c.venues_count <> count(v.id) FILTER (WHERE v.status = 'active')) q;
  IF v_n <> 259 THEN RAISE EXCEPTION 'plan rows %', v_n; END IF;
  IF v_plan IS DISTINCT FROM 'a31795e2d78dd2d91dd1336432e2edd4' THEN RAISE EXCEPTION 'plan md5 %', v_plan; END IF;

  UPDATE cities c SET venues_count = p.new_n FROM jsonb_to_recordset(rel) AS p(id text, old_n int, new_n int) WHERE c.id = p.id AND c.venues_count = p.old_n;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> 259 THEN RAISE EXCEPTION 'rows updated %', v_upd; END IF;

  -- post-checks
  IF (SELECT count(*) FROM cities) <> 3259 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF EXISTS (SELECT 1 FROM cities c LEFT JOIN venues v ON v.city_id = c.id
              GROUP BY c.id, c.venues_count
             HAVING c.venues_count <> count(v.id) FILTER (WHERE v.status = 'active'))
    THEN RAISE EXCEPTION 'a city still differs'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10934 THEN RAISE EXCEPTION 'sum of venues_count after'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 172 THEN RAISE EXCEPTION 'ledger changed'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119112) <> 259 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS p(id text, old_n int, new_n int) ON p.id = a.row_pk
       WHERE a.id > 119112 AND a.table_name = 'cities' AND a.action = 'UPDATE'
         AND (a.old_row - 'venues_count') = (a.new_row - 'venues_count')
         AND (a.old_row->>'venues_count')::int = p.old_n
         AND (a.new_row->>'venues_count')::int = p.new_n) <> 259
    THEN RAISE EXCEPTION 'audit rows do not match the plan'; END IF;
END
$do$;
COMMIT;
