-- CompassEats, Nov 1 2026. Michelin Guide Hong Kong & Macau 2026: Green Star rows (open item 1, D9 = A).
-- Ben, Nov 1 10:14 ET "D1-9 all recommended": D9 = A, 5 Green Star 2026 rows in a small file after the promote,
--   source_url = venue page (same rule as the Japan green-mark rows, QG A of Oct 29).
-- Source: docs/michelin-2026-hong-kong-macau-log.md part 13 (sha256 8ddf67809aa00f8773b9c1b091a5b3cbd95a2b1551e30631dbd36e00e99239df).
--   Ceremony article https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026
--   names 5 Green Stars (Hong Kong 4, Macau 1). Each venue page carries the green sustainability block.
-- Built by docs/hkmo-2026-build/build_green_star_hkmo_2026_11_01.py from the log table (no retyped rows).
-- Venue match: inside this transaction, by the venue page URL = source_url of exactly one Michelin 2026 award row
--   of the stated category on an active venue.
-- Guards: plan md5 9a367fc13e3132fa0284e2469ca84415 (line|name|category|url); line:venue md5 cac32b7a4b64f3a279bf13a830bebe9c
--   (read-only plan query, Nov 1); no Green Star row on these venues in any year.
-- Expected: awards INSERT 5 (Green Star, 2026); 1 ledger row; 5 audit rows (trigger). awards 23,363 -> 23,368.
--   Nothing is updated or deleted. Venues, slugs, cities and listings do not change.
-- Dry run: send this file through the Read connector. All pre-checks run, then the block stops at the
--   first INSERT with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '[[1, "Amber", "Three Stars", "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/amber569032"], [2, "Feuille", "One Star", "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/feuille"], [3, "Mora", "One Star", "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/mora"], [4, "Roganic", "One Star", "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/roganic1185143"], [5, "UTM Educational Restaurant", "Bib Gourmand", "https://guide.michelin.com/us/en/macau-region/macau/restaurant/ift-educational-restaurant"]]';
  job_txt  text := 'special-awards:michelin-2026-hong-kong-macau-green-star | D9 = A (Ben, Nov 1 10:14 ET "D1-9 all recommended"): 5 Green Star 2026 rows (Hong Kong 4: Amber, Feuille, Mora, Roganic; Macau 1: UTM Educational Restaurant), source_url = venue page | ceremony article https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026 | log part 13 sha256 8ddf6780...39df';
  pj jsonb;
  n int; x int; s text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO s, n FROM jsonb_array_elements(pj) e;
  IF s <> '9a367fc13e3132fa0284e2469ca84415' OR n <> 5 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected 9a367fc13e3132fa0284e2469ca84415 / 5)', s, n; END IF;

  WITH p AS (SELECT (e->>0)::int l, e->>2 c, e->>3 u FROM jsonb_array_elements(pj) e),
  r AS (SELECT p.l,
      (SELECT min(a.venue_id) FROM awards a JOIN venues v ON v.id = a.venue_id
        WHERE a.source_id = 'michelin' AND a.year = 2026 AND a.category = p.c AND a.source_url = p.u AND v.status = 'active') vid,
      (SELECT count(*) FROM awards a WHERE a.source_id = 'michelin' AND a.source_url = p.u) nu
    FROM p)
  SELECT count(*) FILTER (WHERE vid IS NOT NULL AND nu = 1), count(DISTINCT vid),
         md5(string_agg(l || ':' || coalesce(vid, '-'), ',' ORDER BY l))
    INTO n, x, s FROM r;
  IF n <> 5 OR x <> 5 THEN RAISE EXCEPTION 'rows matching exactly one active venue % / distinct venues % (expected 5 / 5)', n, x; END IF;
  IF s <> 'cac32b7a4b64f3a279bf13a830bebe9c' THEN RAISE EXCEPTION 'line:venue md5 % (expected cac32b7a4b64f3a279bf13a830bebe9c)', s; END IF;

  WITH p AS (SELECT e->>3 u FROM jsonb_array_elements(pj) e)
  SELECT count(*), string_agg(g.id::text, ',') INTO x, s
    FROM p JOIN awards a ON a.source_id = 'michelin' AND a.source_url = p.u
    JOIN awards g ON g.venue_id = a.venue_id AND g.source_id = 'michelin' AND g.category = 'Green Star';
  IF x <> 0 THEN RAISE EXCEPTION 'Green Star rows already on these venues: %', s; END IF;

  -- 2. Counts before (read Nov 1 15:59 UTC)
  SELECT count(*) INTO x FROM awards;           IF x <> 23363 THEN RAISE EXCEPTION 'awards before % (expected 23363)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9659 THEN RAISE EXCEPTION 'Michelin awards before % (expected 9659)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND category = 'Green Star' AND year = 2026;
                                                IF x <> 124 THEN RAISE EXCEPTION 'Green Star 2026 before % (expected 124)', x; END IF;
  SELECT count(*) INTO x FROM award_categories WHERE source_id = 'michelin' AND category = 'Green Star';
                                                IF x <> 1 THEN RAISE EXCEPTION 'Green Star category rows % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11300 THEN RAISE EXCEPTION 'venues before % (expected 11300)', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 12952 THEN RAISE EXCEPTION 'slugs before % (expected 12952)', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;  IF x <> 10935 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10935)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 154 OR led_max <> 204 THEN RAISE EXCEPTION 'ledger before % / max % (expected 154 / 204)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 115752 OR aud_max <> 121090 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 115752 / 121090)', aud_n, aud_max; END IF;

  -- 3. Write
  WITH p AS (SELECT (e->>0)::int l, e->>2 c, e->>3 u FROM jsonb_array_elements(pj) e),
  r AS (SELECT p.l, p.u,
      (SELECT min(a.venue_id) FROM awards a JOIN venues v ON v.id = a.venue_id
        WHERE a.source_id = 'michelin' AND a.year = 2026 AND a.category = p.c AND a.source_url = p.u AND v.status = 'active') vid
    FROM p)
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT vid, 'michelin', 2026, NULL, 'Green Star', NULL, u FROM r ORDER BY l;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 5 THEN RAISE EXCEPTION 'award rows inserted % (expected 5)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 5, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM awards;           IF x <> 23368 THEN RAISE EXCEPTION 'awards after % (expected 23368)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9664 THEN RAISE EXCEPTION 'Michelin awards after % (expected 9664)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND category = 'Green Star' AND year = 2026;
                                                IF x <> 129 THEN RAISE EXCEPTION 'Green Star 2026 after % (expected 129)', x; END IF;
  WITH p AS (SELECT e->>3 u FROM jsonb_array_elements(pj) e)
  SELECT md5(string_agg(g.venue_id || '|' || g.source_url, E'\n' ORDER BY g.venue_id)), count(*) INTO s, x
    FROM awards g JOIN p ON g.source_url = p.u
   WHERE g.source_id = 'michelin' AND g.category = 'Green Star' AND g.year = 2026 AND g.rank IS NULL AND g.distinction IS NULL;
  IF x <> 5 THEN RAISE EXCEPTION 'new Green Star rows found % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM (SELECT 1 FROM awards WHERE source_id = 'michelin' AND category = 'Green Star'
                               GROUP BY venue_id, year HAVING count(*) > 1) d;
  IF x <> 0 THEN RAISE EXCEPTION 'venue + Green Star + year twice after: %', x; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11300 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 12952 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3260 THEN RAISE EXCEPTION 'cities changed: %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;  IF x <> 10935 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', x; END IF;

  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 155 THEN RAISE EXCEPTION 'ledger after % (expected 155)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 5 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 5 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.category = 'Green Star' AND a.year = 2026
     AND al.new_row->>'source_url' = a.source_url;
  IF x <> 5 THEN RAISE EXCEPTION 'audit INSERT rows for the new Green Star rows % (expected 5)', x; END IF;
END
$do$;
COMMIT;
