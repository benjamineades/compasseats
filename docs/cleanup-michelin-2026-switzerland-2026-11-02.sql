-- cleanup-michelin-2026-switzerland-2026-11-02.sql
-- CompassEats, Nov 2 2026 (Nov 3 UTC). Michelin Switzerland 2026, write 4 of the plan: cleanup after the promote of batch 20. One transaction.
-- Ben: Nov 2 ET 18:09 "1A", 18:17 "2A", 18:53 "1A, 2A". This file runs only after his "go".
-- Built by docs/ch-2026-build/build_cleanup_ch_2026_11_02.py. Values read Nov 3 00:00-00:05 UTC after the promote.
--
-- 1. Move 9 Michelin 2025 rows to the venue of their 2026 card (each target holds only its 2026 row of the same category):
--   231 One Star     ve_a024c1df89 -> ve_b76744c249  Ollon card; archive 20260128201135 = One Star 2025 in Ollon (Ben 1A 18:09)
--   3629 Bib Gourmand ve_7561fa5d25 -> ve_858eea062b  Adelboden twin: Alpenblick - Bistro (Ben 1A 18:53)
--   3812 Bib Gourmand ve_063365e885 -> ve_6cedf32a8c  Aubonne twin: Njørd café (Ben 1A 18:53)
--   4310 One Star     ve_2552a6a023 -> ve_d84ee8e403  Brunnen twin: Birdy's by Achtien - The Nest (Ben 1A 18:53)
--   6468 Bib Gourmand ve_27a2d86ff0 -> ve_b9da8d6de9  Mels twin: Restaurant Schlüssel - Schlüsselstube (Ben 1A 18:53)
--   7556 Bib Gourmand ve_46053b218b -> ve_4766480819  Riedholz twin: Château Attisholz - Brasserie la Source (Ben 1A 18:53)
--   7627 Bib Gourmand ve_b0b6289cfe -> ve_08fb4a4859  Romoos twin: Wiesner Mysterion – Werkstatt Kost (Ben 1A 18:53)
--   8278 Bib Gourmand ve_e412256f8a -> ve_2a76b77e16  Steffisburg twin: Panorama - Bistro (Ben 1A 18:53)
--   9048 Bib Gourmand ve_1ff8df1642 -> ve_bcb98826f3  Ebersecken card; archive 20251208045545 = Bib 2025 in Ebersecken (Ben 2A 18:17)
-- 2. Delete row 9060 (Bib Gourmand 2025 on Hotel Alpenblick ve_dd38531f8f, Wilderswil). Contamination rule (Ben 2A 18:53):
--    the Bib card goes to Swiss Bistro im Hotel Alpenblick ve_59b228c72a, which holds its own Bib 2025 row 12947. No table points to awards.
-- 3. cities.venues_count on the 26 cities that differ from city_venue_counts (30 new venues; sum 10,999 -> 11,029).
-- 4. Ledger: 1 row (michelin, award, 10 = 9 moved + 1 deleted), as ledger 232.
--
-- No change: venues, slugs, listings, price, city labels, aliases.
-- Expected after: awards 25,321; cities sum 11,029, view difference 0; ledger 189 rows, last id 243;
--   audit_log +36 (awards:DELETE=1, awards:UPDATE=9, cities:UPDATE=26), 119,226 rows.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text; r record;
  row_ids constant bigint[] := ARRAY[231,3629,3812,4310,6468,7556,7627,8278,9048,9060];
  ven_ids constant text[] := ARRAY['ve_063365e885','ve_08fb4a4859','ve_1ff8df1642','ve_2552a6a023','ve_27a2d86ff0','ve_2a76b77e16','ve_46053b218b','ve_4766480819','ve_59b228c72a','ve_6cedf32a8c','ve_7561fa5d25','ve_858eea062b','ve_a024c1df89','ve_b0b6289cfe','ve_b76744c249','ve_b9da8d6de9','ve_bcb98826f3','ve_d84ee8e403','ve_dd38531f8f','ve_e412256f8a'];
  mv_id constant bigint[] := ARRAY[231,3629,3812,4310,6468,7556,7627,8278,9048];
  mv_cat constant text[] := ARRAY['One Star','Bib Gourmand','Bib Gourmand','One Star','Bib Gourmand','Bib Gourmand','Bib Gourmand','Bib Gourmand','Bib Gourmand'];
  mv_from constant text[] := ARRAY['ve_a024c1df89','ve_7561fa5d25','ve_063365e885','ve_2552a6a023','ve_27a2d86ff0','ve_46053b218b','ve_b0b6289cfe','ve_e412256f8a','ve_1ff8df1642'];
  mv_to constant text[] := ARRAY['ve_b76744c249','ve_858eea062b','ve_6cedf32a8c','ve_d84ee8e403','ve_b9da8d6de9','ve_4766480819','ve_08fb4a4859','ve_2a76b77e16','ve_bcb98826f3'];
  mv_ta constant bigint[] := ARRAY[32296,32479,32403,32388,32485,32473,32467,32419,32487];
  ct_id constant text[] := ARRAY['ci_0a56f8cfef','ci_10bd8ad705','ci_12152d7fd8','ci_1776a9795b','ci_187d5ee939','ci_1c026c14e3','ci_2138aeb041','ci_2baf689f34','ci_5d0661d785','ci_5ebc89110d','ci_6e8574ca6c','ci_6f6257483c','ci_7aaf6c53e9','ci_8012e949be','ci_a14062e6ed','ci_a456f7a2d5','ci_a89407b990','ci_b206712e95','ci_b2c3668514','ci_bac45d1f1a','ci_c8093069b1','ci_caebcc3d7a','ci_d5a526af37','ci_db61a34f59','ci_e84ec9ed9f','ci_fc17ea368d'];
  ct_was constant int[] := ARRAY[0,0,0,0,1,2,0,1,1,1,33,0,7,5,0,0,0,0,1,0,0,0,1,0,1,1];
  ct_now constant int[] := ARRAY[1,1,1,1,2,3,1,2,2,2,37,1,8,6,1,1,1,1,2,1,2,1,2,1,2,2];
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 3 00:00:47 UTC)
  IF (SELECT count(*) FROM venues) <> 11323 OR (SELECT count(*) FROM venues WHERE status='active') <> 11029 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25322 OR (SELECT count(*) FROM slugs) <> 13052 OR (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11323 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24049 OR (SELECT count(*) FROM cities) <> 3279 OR (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'labels cities aliases before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10999 THEN RAISE EXCEPTION 'cities sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 26 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT status FROM ingest_batches WHERE id=20) IS DISTINCT FROM 'promoted' OR (SELECT max(id) FROM ingest_batches) <> 20 THEN RAISE EXCEPTION 'batch 20'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM source_capture_ledger; IF n <> 188 OR aud_max <> 242 THEN RAISE EXCEPTION 'ledger before % / %', n, aud_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 119190 OR aud_max <> 125019 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,'-'), E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.id = ANY (row_ids);
  IF s IS DISTINCT FROM 'f3adc54df11fe28fc91f8eea6a3cc3a8' THEN RAISE EXCEPTION 'award rows fingerprint %', s; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.city_id||'|'||v.status||'|'||coalesce((SELECT string_agg(a.id||'/'||a.year||'/'||a.category, ';' ORDER BY a.id) FROM awards a WHERE a.venue_id=v.id),'-'), E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (ven_ids);
  IF s IS DISTINCT FROM 'c323b8d00db1ea8e7948c895bd456d5f' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;

  -- each row is a Michelin 2025 row of the stated category on the stated venue; each target holds exactly its 2026 row of that category
  IF (SELECT count(*) FROM unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) JOIN awards a ON a.id=mv.award_id AND a.venue_id=mv.from_v AND a.category=mv.category AND a.year=2025 AND a.source_id='michelin' AND a.source_url IS NULL) <> 9 THEN RAISE EXCEPTION 'move rows'; END IF;
  IF (SELECT count(*) FROM unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) JOIN awards a ON a.id=mv.to_award AND a.venue_id=mv.to_v AND a.category=mv.category AND a.year=2026 AND a.source_id='michelin') <> 9 THEN RAISE EXCEPTION 'target 2026 rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) ON a.venue_id=mv.to_v) <> 9 THEN RAISE EXCEPTION 'targets hold other rows'; END IF;
  IF (SELECT count(*) FROM awards WHERE id=9060 AND venue_id='ve_dd38531f8f' AND category='Bib Gourmand' AND year=2025 AND source_id='michelin' AND source_url IS NULL) <> 1 THEN RAISE EXCEPTION 'delete row'; END IF;
  IF (SELECT count(*) FROM awards WHERE id=12947 AND venue_id='ve_59b228c72a' AND category='Bib Gourmand' AND year=2025) <> 1 THEN RAISE EXCEPTION 'swiss bistro 2025 row'; END IF;
  IF (SELECT count(*) FROM unnest(ct_id, ct_was, ct_now) AS ct(city_id, was, now_live) JOIN cities c ON c.id=ct.city_id AND c.venues_count=ct.was JOIN city_venue_counts x ON x.city_id=ct.city_id AND x.active_venues=ct.now_live) <> 26 THEN RAISE EXCEPTION 'city counts before'; END IF;

  ---------------------------------------------------------------- 1. Moves
  UPDATE awards a SET venue_id=mv.to_v FROM unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) WHERE a.id=mv.award_id AND a.venue_id=mv.from_v;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 9 THEN RAISE EXCEPTION 'moves %', n; END IF;
  ---------------------------------------------------------------- 2. Delete
  DELETE FROM awards WHERE id=9060 AND venue_id='ve_dd38531f8f';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'delete %', n; END IF;
  ---------------------------------------------------------------- 3. City counts
  UPDATE cities c SET venues_count=ct.now_live FROM unnest(ct_id, ct_was, ct_now) AS ct(city_id, was, now_live) WHERE c.id=ct.city_id AND c.venues_count=ct.was;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 26 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  ---------------------------------------------------------------- 4. Ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 10, 'cleanup:cleanup-michelin-2026-switzerland | Ben Nov 2 ET 18:09 1A, 18:17 2A, 18:53 1A and 2A | after promote of batch 20 | moved Michelin 2025 rows: 231 ve_a024c1df89->ve_b76744c249, 3629 ve_7561fa5d25->ve_858eea062b, 3812 ve_063365e885->ve_6cedf32a8c, 4310 ve_2552a6a023->ve_d84ee8e403, 6468 ve_27a2d86ff0->ve_b9da8d6de9, 7556 ve_46053b218b->ve_4766480819, 7627 ve_b0b6289cfe->ve_08fb4a4859, 8278 ve_e412256f8a->ve_2a76b77e16, 9048 ve_1ff8df1642->ve_bcb98826f3 | deleted 9060 (Bib 2025 copy on ve_dd38531f8f; the Bib card is on ve_59b228c72a with Bib 2025 row 12947) | city counts set on 26 cities');

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) JOIN awards a ON a.id=mv.award_id AND a.venue_id=mv.to_v) <> 9 THEN RAISE EXCEPTION 'moves after'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE id=9060) THEN RAISE EXCEPTION 'deleted row still there'; END IF;
  IF (SELECT count(*) FROM awards a JOIN unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) ON a.venue_id=mv.to_v) <> 18 THEN RAISE EXCEPTION 'targets after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25321 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11323 OR (SELECT count(*) FROM venues WHERE status='active') <> 11029 OR (SELECT count(*) FROM slugs) <> 13052 OR (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11323 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24049 OR (SELECT count(*) FROM cities) <> 3279 OR (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'labels cities aliases after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11029 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 189 OR (SELECT count(*) FROM source_capture_ledger WHERE id > 242 AND publisher='michelin' AND field_type='award' AND items=10 AND job LIKE 'cleanup:cleanup-michelin-2026-switzerland |%') <> 1 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:DELETE=1,awards:UPDATE=9,cities:UPDATE=26' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log) <> 119226 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log al JOIN unnest(mv_id, mv_cat, mv_from, mv_to, mv_ta) AS mv(award_id, category, from_v, to_v, to_award) ON al.row_pk=mv.award_id::text WHERE al.id > aud_max AND al.table_name='awards' AND al.action='UPDATE'
        AND al.old_row->>'venue_id'=mv.from_v AND al.new_row->>'venue_id'=mv.to_v AND (al.old_row-'venue_id')=(al.new_row-'venue_id')) <> 9 THEN RAISE EXCEPTION 'audit move rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
