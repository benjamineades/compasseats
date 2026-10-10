-- retire-michelin-legacy-be-lu.sql
-- CompassEats, Oct 10 2026. Retire the Belgium & Luxembourg legacy Michelin twins.
-- Run AFTER the promote of batch 15 (michelin-2026-belgium-luxembourg, Oct 10 20:36:03 UTC,
--   ledger 109-110, audit 109,593-109,842).
-- Rule: amended rule 2.1.1 and rule 2.1.7. The 2026 ceremony was May 4, 2026 (before May 13),
--   so the legacy rows labelled 2025 hold the 2026 edition. Each one that now has a sourced
--   2026 card row on the same venue in the same category is a twin, and is deleted.
--   Same method as retire-michelin-legacy-gb-ie (ledger 75): awards DELETE only, trigger audit
--   rows, one ledger row. No venue, slug, listing, price or city label changes.
-- Population (read Oct 10 after the promote): Michelin rows on venues in BE and LU cities.
--   Legacy (no source_url) 249: 2025 only, 2 / 22 / 114 / 111.
--   Sourced 247, all from batch 15.
--   Twins 246 on 246 venues: Three Stars 2, Two Stars 21, One Star 112, Bib Gourmand 111.
--   Category mismatches 0.
--   Orphans kept (no card, cleanup later): 1443 La Paix (closed, Two Stars),
--   3711 Kommilfoo (active, One Star), 5195 La Table de Manon (active, One Star).
-- Guards:
--   twin award ids md5 (by id, ',')                    5f7f7ea1f2ac10ebecbe05a92369fd65 (246)
--   plan fingerprint (md5 of id|venue_id|source_id|year|category|source_url or '',
--     by id, newline)                                  1cade4a519545e4bd51a3b17f079fa80
-- Expected audit rows: 246 (awards DELETE, from trg_audit_awards). No table has a foreign key
--   to awards.
-- After: awards 22,709 -> 22,463. Michelin 2025 3,791 -> 3,545. Michelin 2026 5,124 (no change).
--   BE and LU Michelin rows: 247 sourced 2026 + 3 orphans. Ledger 79 -> 80.
-- Dry run: send only the DO block through the Read connector. All pre-checks run, then the
--   block stops at the first DELETE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  tids     bigint[] := ARRAY[
    23,938,1453,1455,1461,1551,1636,1664,1890,1945,1955,2028,2144,2165,2268,2293,2734,2741,2788,3198,
    3200,3434,3445,3604,3707,3708,3709,3713,3714,3715,3716,3717,3734,4088,4190,4225,4256,4264,4277,4278,
    4279,4308,4309,4312,4314,4318,4320,4606,4717,4723,4726,4753,4896,4953,4954,5003,5020,5046,5119,5131,
    5132,5136,5138,5139,5329,5330,5364,5366,5609,5651,5653,5666,5694,5695,5701,5881,5892,5928,5929,5932,
    5935,5980,5981,6187,6201,6202,6203,6204,6206,6407,6408,6410,6429,6431,6459,6562,6673,6920,6921,6987,
    7001,7003,7130,7139,7154,7513,7603,7646,7701,7704,7898,7919,8223,8224,8225,8226,8229,8230,8244,8267,
    8280,8319,8454,8463,8661,8662,8762,8927,8957,9069,9070,9073,9085,9104,9112,9210,9236,9265,9279,9280,
    9281,9282,9294,9338,9339,9444,9448,9516,9522,9535,9542,9551,9559,9561,9571,9580,9621,9622,9623,9624,
    9625,9626,9627,9628,9661,9759,9766,9865,9939,9951,10053,10054,10080,10130,10135,10157,10168,10171,10177,10178,
    10195,10260,10262,10293,10326,10467,10470,10519,10634,10635,10676,10677,10678,10679,10680,10695,10696,10756,10858,10861,
    10889,10917,10927,10928,10929,10930,11042,11125,11137,11211,11214,11230,11277,11321,11499,11596,11597,11658,11727,11899,
    11900,11901,12054,12257,12259,12261,12262,12564,12565,12762,12763,12764,12817,12818,12822,12868,12870,12877,12914,12915,
    12916,12924,12948,12960,12967,13008
  ]::bigint[];
  fp       text;
  n        int;
  x        int;
  y        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
  job_txt  text := 'retire:retire-michelin-legacy-be-lu | Belgium & Luxembourg 2026 (ceremony May 4, 2026, before May 13: rule 2.1.1 retire path, GB&I precedent ledger 75) | 246 same-category legacy twins of the batch 15 card rows (michelin-2026-belgium-luxembourg, ledger 109-110) | 2/21/112/111 | orphans kept: 1443 La Paix, 3711 Kommilfoo, 5195 La Table de Manon';
BEGIN
  -- 1. Guards
  IF cardinality(tids) <> 246 THEN RAISE EXCEPTION 'twin id list has % ids (expected 246)', cardinality(tids); END IF;
  IF md5(array_to_string(tids, ',')) <> '5f7f7ea1f2ac10ebecbe05a92369fd65' THEN
    RAISE EXCEPTION 'twin award id list md5 does not match';
  END IF;
  SELECT count(*), md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                                   E'\n' ORDER BY a.id))
    INTO n, fp FROM awards a WHERE a.id = ANY (tids);
  IF n <> 246 THEN RAISE EXCEPTION 'twin rows found % (expected 246)', n; END IF;
  IF fp <> '1cade4a519545e4bd51a3b17f079fa80' THEN RAISE EXCEPTION 'plan fingerprint changed: %', fp; END IF;

  -- 2. Pre-checks
  -- 2a. Every row to delete is an unsourced Michelin 2025 row on a BE or LU venue
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.id = ANY (tids) AND a.source_id = 'michelin' AND a.year = 2025 AND a.source_url IS NULL
     AND a.rank IS NULL AND a.distinction IS NULL AND c.country_iso IN ('BE','LU');
  IF x <> 246 THEN RAISE EXCEPTION 'rows that are unsourced Michelin 2025 BE/LU rows % (expected 246)', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE a.category = 'Three Stars'), count(*) FILTER (WHERE a.category = 'Two Stars'),
         count(*) FILTER (WHERE a.category = 'One Star')
    INTO x, y, n, aud_n FROM awards a WHERE a.id = ANY (tids);
  IF y <> 2 OR n <> 21 OR aud_n <> 112 OR x - y - n - aud_n <> 111 THEN
    RAISE EXCEPTION 'category split %/%/%/% (expected 2/21/112/111)', y, n, aud_n, x - y - n - aud_n;
  END IF;
  -- 2b. Each row has exactly one sourced 2026 card row from batch 15 on the same venue, same category
  SELECT count(*) INTO x FROM awards a
   WHERE a.id = ANY (tids)
     AND (SELECT count(*) FROM awards s
           WHERE s.venue_id = a.venue_id AND s.source_id = 'michelin' AND s.year = 2026
             AND s.category = a.category AND s.rank IS NULL AND s.distinction IS NULL
             AND s.source_url IN (SELECT r.raw->>'source_url' FROM ingest_rows r WHERE r.batch_id = 15)) = 1;
  IF x <> 246 THEN RAISE EXCEPTION 'rows with exactly one batch 15 card twin % (expected 246)', x; END IF;
  SELECT count(DISTINCT venue_id) INTO x FROM awards WHERE id = ANY (tids);
  IF x <> 246 THEN RAISE EXCEPTION 'distinct venues % (expected 246)', x; END IF;
  SELECT count(*) INTO x FROM ingest_batches WHERE id = 15 AND batch_key = 'michelin-2026-belgium-luxembourg' AND status::text = 'promoted';
  IF x <> 1 THEN RAISE EXCEPTION 'batch 15 is not promoted'; END IF;
  -- 2c. The 3 orphans stay and are not in the plan
  SELECT count(*) INTO x FROM awards
   WHERE id IN (1443, 3711, 5195) AND source_id = 'michelin' AND year = 2025 AND source_url IS NULL
     AND NOT (id = ANY (tids));
  IF x <> 3 THEN RAISE EXCEPTION 'orphan rows present % (expected 3)', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE a.source_url IS NULL), count(*) FILTER (WHERE a.source_url IS NOT NULL)
    INTO x, y, n FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND c.country_iso IN ('BE','LU');
  IF x <> 496 OR y <> 249 OR n <> 247 THEN RAISE EXCEPTION 'BE/LU Michelin rows % / legacy % / sourced % (expected 496 / 249 / 247)', x, y, n; END IF;

  -- 3. Counts before
  SELECT count(*) INTO x FROM venues;            IF x <> 11233 THEN RAISE EXCEPTION 'venues before % (expected 11233)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                 IF x <> 10867 THEN RAISE EXCEPTION 'active before % (expected 10867)', x; END IF;
  SELECT count(*) INTO x FROM awards;            IF x <> 22709 THEN RAISE EXCEPTION 'awards before % (expected 22709)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                 IF x <> 3791 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3791)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                 IF x <> 5124 THEN RAISE EXCEPTION 'Michelin 2026 before % (expected 5124)', x; END IF;
  SELECT count(*) INTO x FROM listings;          IF x <> 11233 THEN RAISE EXCEPTION 'listings before % (expected 11233)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12576 THEN RAISE EXCEPTION 'slugs before % (expected 12576)', x; END IF;
  SELECT count(*) INTO x FROM price;             IF x <> 7048 THEN RAISE EXCEPTION 'price before % (expected 7048)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 23870 THEN RAISE EXCEPTION 'city labels before % (expected 23870)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 79 OR led_max <> 110 THEN RAISE EXCEPTION 'ledger before % / max % (expected 79 / 110)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 105607 OR aud_max <> 109842 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 105607 / 109842)', aud_n, aud_max; END IF;

  -- 4. Write
  DELETE FROM awards WHERE id = ANY (tids) AND source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 246 THEN RAISE EXCEPTION 'awards deleted % (expected 246)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 246, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 5. Post-checks
  SELECT count(*) INTO x FROM awards WHERE id = ANY (tids);
  IF x <> 0 THEN RAISE EXCEPTION 'deleted rows left: %', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE a.source_url IS NULL), count(*) FILTER (WHERE a.source_url IS NOT NULL AND a.year = 2026)
    INTO x, y, n FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND c.country_iso IN ('BE','LU');
  IF x <> 250 OR y <> 3 OR n <> 247 THEN RAISE EXCEPTION 'BE/LU Michelin rows after % / legacy % / sourced 2026 % (expected 250 / 3 / 247)', x, y, n; END IF;
  SELECT count(*) INTO x FROM awards WHERE id IN (1443, 3711, 5195);
  IF x <> 3 THEN RAISE EXCEPTION 'orphan rows after % (expected 3)', x; END IF;

  SELECT count(*) INTO x FROM venues;            IF x <> 11233 THEN RAISE EXCEPTION 'venues after % (expected 11233)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                 IF x <> 10867 THEN RAISE EXCEPTION 'active after % (expected 10867)', x; END IF;
  SELECT count(*) INTO x FROM awards;            IF x <> 22463 THEN RAISE EXCEPTION 'awards after % (expected 22463)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                 IF x <> 3545 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3545)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                 IF x <> 5124 THEN RAISE EXCEPTION 'Michelin 2026 after % (expected 5124)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND source_url IS NOT NULL;
                                                 IF x <> 4583 THEN RAISE EXCEPTION 'sourced Michelin rows after % (expected 4583)', x; END IF;
  SELECT count(*) INTO x FROM listings;          IF x <> 11233 THEN RAISE EXCEPTION 'listings after % (expected 11233)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12576 THEN RAISE EXCEPTION 'slugs after % (expected 12576)', x; END IF;
  SELECT count(*) INTO x FROM price;             IF x <> 7048 THEN RAISE EXCEPTION 'price after % (expected 7048)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 23870 THEN RAISE EXCEPTION 'city labels after % (expected 23870)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;            IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM redirects;         IF x <> 9 THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id, year, category FROM awards WHERE source_id = 'michelin'
                               GROUP BY 1, 2, 3 HAVING count(*) > 1) d;
                                                 IF x <> 0 THEN RAISE EXCEPTION 'venues with two Michelin rows of one year and category: %', x; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id, year FROM awards WHERE source_id = 'michelin'
                               GROUP BY 1, 2 HAVING count(DISTINCT category) > 1) d;
                                                 IF x <> 18 THEN RAISE EXCEPTION 'venue-years with two Michelin categories after % (expected 18)', x; END IF;

  -- 5a. Ledger and audit
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 80 THEN RAISE EXCEPTION 'ledger after % (expected 80)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 246 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 246 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 246)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND table_name = 'awards' AND action = 'DELETE' AND new_row IS NULL
     AND row_pk = ANY (SELECT unnest(tids)::text) AND old_row->>'source_url' IS NULL AND (old_row->>'year')::int = 2025;
  IF x <> 246 THEN RAISE EXCEPTION 'DELETE audit rows that match the plan % (expected 246)', x; END IF;
END
$do$;
COMMIT;
