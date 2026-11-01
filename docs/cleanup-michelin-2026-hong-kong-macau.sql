-- cleanup-michelin-2026-hong-kong-macau.sql
-- CompassEats, Nov 1 2026 (Atlanta). Hong Kong / Macau 2026, step 4 of 4 (after relabel ledger 197, promote ledger 200-201).
-- Ben, Nov 1 10:14 ET: D1-D9 all recommended. 10:47 ET "start cleanup". DELETE: SQL Editor route if the Write connector refuses.
-- Reads (Nov 1):
--   Putien card https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/putien-causeway-bay
--     "Shop A, 7F, Lee Theatre Plaza, 99 Percival Street, Causeway Bay" -> our "Putien (Lee Theatre Plaza)" = the card venue (D5).
--   OAD Top Restaurants in Asia 2025 https://www.oadguides.com/lists/asia/top-restaurants/2025 (Chrome): No. 79 "Lai Ching Heen,
--     Hong Kong"; No. 352 "Lai Heen, Hong Kong". OAD page /restaurant/lai-heen: address "Ritz-Carlton Macau, Estrada da Baia de
--     Nossa Senhora da Esperanca". One restaurant has one rank per list, so No. 352 is not Lai Ching Heen; the address is Macau.
--   La Liste https://www.laliste.com/places/lai-ching-heen-yan-toh-heen-hk (Chrome): "Lai Ching Heen (Yan Toh Heen)", Hong Kong,
--     92.5, Top 1000 Restaurants 2026, 18 Salisbury Rd, Tsim Sha Tsui (the only "lai heen" search result).
-- Writes (one transaction):
--   1. Delete Michelin rows (7): 5409 Duddell's 2025 One Star (copy of 30110, D6); 10532 3D Inn, 10535 Eaton HK, 10591 Ocean Park,
--      10534 Ying Kee Noodle (contamination, D3/D4); 10562 Putien (Lee Theatre Plaza) (copy of 30129, D5); 18227 Hong Kong "Lai Heen"
--      Two Stars (Lai Ching Heen's row, now 30123, D2).
--   2. Move awards (3, with source URL): 18229 OAD 2025 No. 79 and 18226 La Liste 2026 92.5 -> Lai Ching Heen ve_403f3ed56b;
--      18228 OAD 2025 No. 352 -> Macau Lai Heen ve_cdd31cd894.
--   3. Delete 4 contamination venues (3D Inn ve_be7682ae49, Eaton HK ve_25ab6083a0, Ocean Park ve_36af47460a, Ying Kee Noodle
--      ve_d179ef70d6) with price, slug, listing, city labels. Old URLs 404, no redirect (Chengdu rule).
--   4. Merge Putien (Lee Theatre Plaza) ve_8c68834f71 -> ve_73d901a8fe and Hong Kong "Lai Heen" ve_d970e6b8ab -> Lai Ching Heen
--      ve_403f3ed56b: legacy price row moves (card price agrees: $$, $$$), old slug moves as non-canonical (old URL keeps working),
--      city labels deleted (survivor has its own), listing and venue deleted.
--   cities.venues_count: Hong Kong stays 262 (the promote left it at 262 with 268 active; after this file 262 active).
-- Expected: awards 23370 -> 23363; venues 11306 -> 11300 (active 10941 -> 10935); listings -6; slugs 12956 -> 12952
--   (non-canonical 1650 -> 1652); price 7731 -> 7727; city labels 24011 -> 23999; 3 ledger rows; audit +46
--   (awards DELETE 7 + UPDATE 3, price DELETE 4 + UPDATE 2, slugs DELETE 4 + UPDATE 2, listings DELETE 6, venues DELETE 6,
--   city_label_source DELETE 12 hand rows).
BEGIN;
DO $do$
DECLARE
  v_aud bigint; v_led bigint; v_txt text; n int; l1 bigint; l2 bigint; l3 bigint;
BEGIN
  -- 0. Counts before (read Nov 1, after the promote)
  IF (SELECT count(*) FROM venues) <> 11306 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10941
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 365 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23370 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12956 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1650 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11306 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7731 THEN RAISE EXCEPTION 'price before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24011 THEN RAISE EXCEPTION 'city labels before'; END IF;
  IF (SELECT count(*) FROM rename_rows) <> 1211 THEN RAISE EXCEPTION 'rename_rows before'; END IF;
  SELECT max(id) INTO v_led FROM source_capture_ledger;
  IF v_led <> 201 OR (SELECT count(*) FROM source_capture_ledger) <> 151 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT max(id) INTO v_aud FROM audit_log;
  IF v_aud <> 121044 OR (SELECT count(*) FROM audit_log) <> 115706 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10935 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  SELECT string_agg(c.id||':'||c.venues_count||'/'||coalesce(x.active_venues, 0), ',') INTO v_txt
    FROM cities c LEFT JOIN city_venue_counts x ON x.city_id = c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues, 0);
  IF v_txt IS DISTINCT FROM 'ci_1b1537ad28:262/268' THEN RAISE EXCEPTION 'cities differ before: %', v_txt; END IF;

  -- 0a. Fingerprints of every row this file touches (read Nov 1)
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||coalesce(a.rank::text,'')||'|'||a.category||'|'||coalesce(a.distinction,'')||'|'||coalesce(a.source_url,''), E'\n' ORDER BY a.id))
    INTO v_txt FROM awards a
   WHERE a.venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab') OR a.id = 5409;
  IF v_txt IS DISTINCT FROM '5bc03f4d3a59745aa9047eae987141e8' THEN RAISE EXCEPTION 'award rows %', v_txt; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||coalesce(l.publisher,''), E'\n' ORDER BY l.id))
    INTO v_txt FROM city_label_source l
   WHERE l.venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab');
  IF v_txt IS DISTINCT FROM 'd5dfadcd3c8a48a1da0f142aae5dd5c5' THEN RAISE EXCEPTION 'city label rows %', v_txt; END IF;
  SELECT md5(string_agg(p.venue_id||'|'||coalesce(p.tier::text,'')||'|'||p.symbol_raw||'|'||coalesce(p.currency,'')||'|'||p.source, E'\n' ORDER BY p.venue_id))
    INTO v_txt FROM price p
   WHERE p.venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab');
  IF v_txt IS DISTINCT FROM '0b8873f8c9c310a831205a8a0a589458' THEN RAISE EXCEPTION 'price rows %', v_txt; END IF;
  SELECT md5(string_agg(s.venue_id||'|'||s.property_id||'|'||s.city_slug||'|'||s.slug||'|'||s.is_canonical, E'\n' ORDER BY s.venue_id))
    INTO v_txt FROM slugs s
   WHERE s.venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab');
  IF v_txt IS DISTINCT FROM '5bc4ff2f411122a88ec3813f499cfeb8' THEN RAISE EXCEPTION 'slug rows %', v_txt; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id))
    INTO v_txt FROM venues v
   WHERE v.id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab','ve_73d901a8fe','ve_403f3ed56b','ve_cdd31cd894');
  IF v_txt IS DISTINCT FROM '657051b346a81ebc42c4fad63ea2e9c6' THEN RAISE EXCEPTION 'venue rows %', v_txt; END IF;
  -- other child rows on the 6 venues must be 0, and no redirect on the old paths
  IF (SELECT count(*) FROM addresses WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab'))
     + (SELECT count(*) FROM blurbs WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab'))
     + (SELECT count(*) FROM geo WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab'))
     + (SELECT count(*) FROM hours WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab'))
     + (SELECT count(*) FROM photo_refs WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab'))
     + (SELECT count(*) FROM rename_rows WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab')) <> 0
    THEN RAISE EXCEPTION 'other child rows on the 6 venues'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab')) <> 6
    THEN RAISE EXCEPTION 'listings on the 6 venues'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(hong-kong-l10sv4|eaton-hk|ocean-park|ying-kee-noodle|putien-lee-theatre-plaza|/lai-heen)'
              OR to_path ~ '(hong-kong-l10sv4|eaton-hk|ocean-park|ying-kee-noodle|putien-lee-theatre-plaza|/lai-heen)') THEN RAISE EXCEPTION 'redirect on an old path'; END IF;
  -- survivors: no price row; no OAD 2025 / La Liste 2026 row; their 2026 Michelin card rows present
  IF (SELECT count(*) FROM price WHERE venue_id IN ('ve_73d901a8fe','ve_403f3ed56b')) <> 0 THEN RAISE EXCEPTION 'survivor price'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id IN ('ve_403f3ed56b','ve_cdd31cd894') AND source_id IN ('oad','la-liste')) THEN RAISE EXCEPTION 'survivor already has OAD / La Liste'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, year, category) IN ((30110,'ve_a3512f9a51',2026,'One Star'),(30129,'ve_73d901a8fe',2026,'Bib Gourmand'),(30123,'ve_403f3ed56b',2026,'Two Stars'))
        AND source_id = 'michelin' AND source_url LIKE 'https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/%') <> 3 THEN RAISE EXCEPTION 'card rows 30110/30129/30123'; END IF;

  -- 1. City labels of the 6 venues: hand audit rows, then delete
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'DELETE', to_jsonb(l), NULL FROM city_label_source l
   WHERE l.venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab') ORDER BY l.id;
  DELETE FROM city_label_source WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 12 THEN RAISE EXCEPTION 'city labels deleted %', n; END IF;

  -- 2. Michelin rows deleted (7)
  DELETE FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL AND (id, venue_id, category) IN (
    (5409,'ve_a3512f9a51','One Star'),(10532,'ve_be7682ae49','Bib Gourmand'),(10535,'ve_25ab6083a0','Bib Gourmand'),
    (10591,'ve_36af47460a','Bib Gourmand'),(10534,'ve_d179ef70d6','Bib Gourmand'),(10562,'ve_8c68834f71','Bib Gourmand'),
    (18227,'ve_d970e6b8ab','Two Stars'));
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'awards deleted %', n; END IF;

  -- 3. Awards moved with source URL (3)
  UPDATE awards SET venue_id = 've_403f3ed56b', source_url = 'https://www.oadguides.com/lists/asia/top-restaurants/2025'
   WHERE id = 18229 AND venue_id = 've_d970e6b8ab' AND source_id = 'oad' AND year = 2025 AND rank = 79 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 18229 %', n; END IF;
  UPDATE awards SET venue_id = 've_403f3ed56b', source_url = 'https://www.laliste.com/places/lai-ching-heen-yan-toh-heen-hk'
   WHERE id = 18226 AND venue_id = 've_d970e6b8ab' AND source_id = 'la-liste' AND year = 2026 AND category = '92.5/100' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 18226 %', n; END IF;
  UPDATE awards SET venue_id = 've_cdd31cd894', source_url = 'https://www.oadguides.com/lists/asia/top-restaurants/2025'
   WHERE id = 18228 AND venue_id = 've_d970e6b8ab' AND source_id = 'oad' AND year = 2025 AND rank = 352 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 18228 %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab'))
    THEN RAISE EXCEPTION 'awards left on the 6 venues'; END IF;

  -- 4. Price: delete 4 (contamination venues), move 2 (merges; card price agrees)
  DELETE FROM price WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'price deleted %', n; END IF;
  UPDATE price SET venue_id = 've_73d901a8fe' WHERE venue_id = 've_8c68834f71' AND symbol_raw = '$$';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price Putien %', n; END IF;
  UPDATE price SET venue_id = 've_403f3ed56b' WHERE venue_id = 've_d970e6b8ab' AND symbol_raw = '$$$';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price Lai Heen %', n; END IF;

  -- 5. Slugs: delete 4 (contamination venues), move 2 as non-canonical (merges)
  DELETE FROM slugs WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'slugs deleted %', n; END IF;
  UPDATE slugs SET venue_id = 've_73d901a8fe', is_canonical = false
   WHERE venue_id = 've_8c68834f71' AND city_slug = 'hong-kong' AND slug = 'putien-lee-theatre-plaza';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug Putien %', n; END IF;
  UPDATE slugs SET venue_id = 've_403f3ed56b', is_canonical = false
   WHERE venue_id = 've_d970e6b8ab' AND city_slug = 'hong-kong' AND slug = 'lai-heen';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug Lai Heen %', n; END IF;

  -- 6. Listings and venues
  DELETE FROM listings WHERE venue_id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 6 THEN RAISE EXCEPTION 'listings deleted %', n; END IF;
  DELETE FROM venues WHERE id IN ('ve_be7682ae49','ve_25ab6083a0','ve_36af47460a','ve_d179ef70d6','ve_8c68834f71','ve_d970e6b8ab');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 6 THEN RAISE EXCEPTION 'venues deleted %', n; END IF;

  -- 7. Ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 7, 'cleanup:cleanup-michelin-2026-hong-kong-macau | Ben D1-D9 "all recommended" Nov 1 10:14 ET, "start cleanup" 10:47 ET | deleted (legacy, labelled 2025, no URL): 5409 Duddell''s One Star (copy of 30110, D6); 10532 3D Inn Hong Kong - Dragon, 10535 Eaton HK, 10591 Ocean Park, 10534 Ying Kee Noodle (Bib rows on other business names, D3/D4; cards Dragon Inn, Eton, Eng Kee Noodle Shop are new venues); 10562 Putien (Lee Theatre Plaza) (copy of 30129; card address Lee Theatre Plaza, D5); 18227 Hong Kong "Lai Heen" Two Stars (Lai Ching Heen, now 30123, D2) | venues deleted: ve_be7682ae49, ve_25ab6083a0, ve_36af47460a, ve_d179ef70d6 (old URLs 404); merged: ve_8c68834f71 -> ve_73d901a8fe, ve_d970e6b8ab -> ve_403f3ed56b (old slugs non-canonical)')
  RETURNING id INTO l1;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('oad', 'award', 2, 'cleanup:cleanup-michelin-2026-hong-kong-macau | https://www.oadguides.com/lists/asia/top-restaurants/2025 (read Nov 1, Chrome) | 18229 No. 79 "Lai Ching Heen, Hong Kong" -> ve_403f3ed56b; 18228 No. 352 "Lai Heen" -> Macau Lai Heen ve_cdd31cd894 (OAD page /restaurant/lai-heen address Ritz-Carlton Macau; one rank per restaurant per list) | both from Hong Kong "Lai Heen" ve_d970e6b8ab (merged)')
  RETURNING id INTO l2;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('la-liste', 'award', 1, 'cleanup:cleanup-michelin-2026-hong-kong-macau | 18226 2026 92.5/100 -> Lai Ching Heen ve_403f3ed56b | https://www.laliste.com/places/lai-ching-heen-yan-toh-heen-hk "Lai Ching Heen (Yan Toh Heen)", Top 1000 Restaurants 2026, 18 Salisbury Rd (read Nov 1, Chrome; only result of the "lai heen" search) | from Hong Kong "Lai Heen" ve_d970e6b8ab (merged)')
  RETURNING id INTO l3;

  -- 8. Post-checks
  IF l1 <= v_led OR l2 <> l1 + 1 OR l3 <> l2 + 1 THEN RAISE EXCEPTION 'ledger ids % % %', l1, l2, l3; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 154 THEN RAISE EXCEPTION 'ledger rows after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11300 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10935
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 365 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12952 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1652
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11300 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11300 THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23999 THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10935 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical GROUP BY v.id HAVING count(s.slug) <> 1)
    THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM (SELECT venue_id FROM awards WHERE source_id = 'michelin' GROUP BY venue_id, year, category HAVING count(*) > 1) d) <> 0
    THEN RAISE EXCEPTION 'two Michelin rows of one year and category'; END IF;
  SELECT string_agg(a.id::text, ',' ORDER BY a.id) INTO v_txt FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE v.city_id IN ('ci_1b1537ad28','ci_9690a92f29') AND a.source_id = 'michelin' AND a.year = 2025;
  IF v_txt IS DISTINCT FROM '10529' THEN RAISE EXCEPTION 'HK/MO Michelin 2025 after: %', v_txt; END IF;
  SELECT string_agg(id||' '||source_id||' '||category, ', ' ORDER BY id) INTO v_txt FROM awards WHERE venue_id = 've_403f3ed56b';
  IF v_txt IS DISTINCT FROM '18226 la-liste 92.5/100, 18229 oad No. 79, 30123 michelin Two Stars' THEN RAISE EXCEPTION 'Lai Ching Heen awards: %', v_txt; END IF;
  SELECT string_agg(id||' '||source_id||' '||category, ', ' ORDER BY id) INTO v_txt FROM awards WHERE venue_id = 've_73d901a8fe';
  IF v_txt IS DISTINCT FROM '18297 oad No. 421, 30129 michelin Bib Gourmand' THEN RAISE EXCEPTION 'Putien awards: %', v_txt; END IF;
  IF NOT EXISTS (SELECT 1 FROM awards WHERE id = 18228 AND venue_id = 've_cdd31cd894') THEN RAISE EXCEPTION 'Macau Lai Heen OAD'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud) <> 46 THEN RAISE EXCEPTION 'audit rows after %', (SELECT count(*) FROM audit_log WHERE id > v_aud); END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name, action) INTO v_txt
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > v_aud GROUP BY 1, 2) z;
  IF v_txt IS DISTINCT FROM 'awards:DELETE=7,awards:UPDATE=3,city_label_source:DELETE=12,listings:DELETE=6,price:DELETE=4,price:UPDATE=2,slugs:DELETE=4,slugs:UPDATE=2,venues:DELETE=6'
    THEN RAISE EXCEPTION 'audit rows by table and action: %', v_txt; END IF;
END
$do$;
COMMIT;
