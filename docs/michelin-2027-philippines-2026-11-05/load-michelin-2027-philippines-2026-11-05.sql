-- load-michelin-2027-philippines-2026-11-05.sql
-- CompassEats, Nov 6 2026. Michelin Philippines 2027 and the 2026 label. Ben choices 1-6:A, Nov 5 23:54 ET. This file runs only after Ben's "go".
-- Rule 2.1.7: the 34 legacy rows hold the 2026 edition, the first Philippine edition (Oct 30, 2025: https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2026). Relabel 2025 -> 2026, source_url = that article. Retire 0.
-- Then 41 new rows, year 2027 (Oct 29, 2026: https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2027): Two Stars 1, One Star 9, Bib Gourmand 31, source_url = the card (/us/en/). 11 new venues, 2 new cities.
-- Source: docs/michelin-2027-philippines-2026-11-05/relay-ph-2027-list-pages-2026-11-05.txt sha256 08b28ab3b5cf1ee81c8e46f4469f3c6b86d18f951783b53aa91a6c5aab502cbc.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11730 (active 11418, closed 312); awards 28746; slugs 13674; listings 11730; labels 24867; cities 3327, sum 11418; ledger 284 rows; Michelin 2025/2026/2027 4329/7521/172; audit_log +135.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$2452|ve_3aa7504a5c|Two Stars
4477|ve_c1fad6f34d|One Star
6356|ve_02414fbadb|One Star
6359|ve_9c188a1e77|One Star
6361|ve_1b52721d24|One Star
6362|ve_b35e1074dd|One Star
6364|ve_5d017018da|One Star
7168|ve_c098594959|One Star
8386|ve_8539e5beaf|One Star
9729|ve_afed6a84b8|Bib Gourmand
9730|ve_fe597436c3|Bib Gourmand
9731|ve_3322a01dd3|Bib Gourmand
9732|ve_6b4653a3c2|Bib Gourmand
9733|ve_6f47f1c8ed|Bib Gourmand
9734|ve_84ded2e04a|Bib Gourmand
11097|ve_9ef43ea0c6|Bib Gourmand
11098|ve_15ab352ddc|Bib Gourmand
11099|ve_7bba9e3816|Bib Gourmand
11100|ve_0733ac977c|Bib Gourmand
11101|ve_a33d03b879|Bib Gourmand
11102|ve_55fa37e356|Bib Gourmand
11103|ve_be4b78a978|Bib Gourmand
11104|ve_bdca6d0be9|Bib Gourmand
11105|ve_acb0fd2749|Bib Gourmand
11123|ve_42732bab00|Bib Gourmand
11611|ve_de1afd46e7|Bib Gourmand
11786|ve_c9c94a8b08|Bib Gourmand
11787|ve_8853feb456|Bib Gourmand
11788|ve_b983ca4787|Bib Gourmand
12410|ve_d5d1159488|Bib Gourmand
12411|ve_c699c5b252|Bib Gourmand
12412|ve_0b81280910|Bib Gourmand
12413|ve_b541c134d7|Bib Gourmand
12414|ve_a74c96e583|Bib Gourmand$plan$;
  aw text := $plan$ve_02414fbadb|One Star|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/celera
ve_02e1325d23|Bib Gourmand|https://guide.michelin.com/us/en/national-capital-region/las-pinas-city_2320883/restaurant/butcher-boy
ve_0733ac977c|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/manam-at-the-triangle
ve_0b81280910|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/cochi
ve_15ab352ddc|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/la-pita-poblacion
ve_1b52721d24|One Star|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/inato
ve_3322a01dd3|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/esmen
ve_3aa7504a5c|Two Stars|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/helm
ve_3bcb8dc268|Bib Gourmand|https://guide.michelin.com/us/en/central-luzon/pampanga/restaurant/apag-marangle
ve_42732bab00|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/manila_2329836/restaurant/cabel
ve_55fa37e356|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/sarsa
ve_5d017018da|One Star|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/toyo-eatery
ve_6a8ae6b0b4|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/tatang-s-lechon
ve_6b4653a3c2|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/lasa-1241166
ve_7bba9e3816|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/lampara
ve_84ded2e04a|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/the-pig-palm
ve_8539e5beaf|One Star|https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/gallery-by-chele
ve_8853feb456|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/quenzon-city_2323700/restaurant/palm-grill-diliman
ve_9457d9b2b1|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/kalipay
ve_9c188a1e77|One Star|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/hapag
ve_a33d03b879|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/pilya-s-kitchen
ve_a74c96e583|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/los-tacos
ve_afed6a84b8|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/abaseria-deli-cafe
ve_b35e1074dd|One Star|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/kasa-palma
ve_b3687c0a99|Bib Gourmand|https://guide.michelin.com/us/en/central-visayas/cebu-city_2340421/restaurant/ato-ah
ve_b4f59db272|Bib Gourmand|https://guide.michelin.com/us/en/calabarzon/cavite_2318043/restaurant/bawai-s-vietnamese-kitchen
ve_b541c134d7|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/em-ha-noi
ve_b983ca4787|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/quenzon-city_2323700/restaurant/some-thai-tomas-morato
ve_b9ea4035d8|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/c-h-e-bacolod-chicken-house-express
ve_bdca6d0be9|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/the-underbelly
ve_be4b78a978|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/taqueria-franco
ve_c098594959|One Star|https://guide.michelin.com/us/en/metro-manila/paranaque-city_2322454/restaurant/linamnam
ve_c1fad6f34d|One Star|https://guide.michelin.com/us/en/calabarzon/cavite_2318043/restaurant/asador-alfonso
ve_c699c5b252|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/brick-corner
ve_c9c94a8b08|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/quenzon-city_2323700/restaurant/morning-sun-eatery
ve_cff657d2a8|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/manila_2329836/restaurant/azela-manila
ve_d5d1159488|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/bolero-1217698
ve_d9f34de123|Bib Gourmand|https://guide.michelin.com/us/en/calabarzon/cavite_2318043/restaurant/balay-dako
ve_de1afd46e7|Bib Gourmand|https://guide.michelin.com/us/en/metro-manila/paranaque-city_2322454/restaurant/kumba
ve_deef23b63c|One Star|https://guide.michelin.com/us/en/metro-manila/makati-city_2329358/restaurant/flow
ve_f04279e210|Bib Gourmand|https://guide.michelin.com/us/en/central-luzon/pampanga/restaurant/tito-boy$plan$;
  nw text := $plan$ve_02e1325d23|butcher-boy|las-pinas-metro-manila|ci_a338350536|Las Piñas - Metro Manila|BUTCHER BOY
ve_3bcb8dc268|apag-marangle|pampanga|ci_d6ce481bcf|Pampanga|Apag Marangle
ve_6a8ae6b0b4|tatang-s-lechon|cebu|ci_91b1fd2bea|Cebu|Tatang's Lechon
ve_9457d9b2b1|kalipay|cebu|ci_91b1fd2bea|Cebu|Kalipay!
ve_b3687c0a99|ato-ah|cebu|ci_91b1fd2bea|Cebu|ATO-AH
ve_b4f59db272|bawai-s-vietnamese-kitchen|cavite|ci_e8e2660d1e|Cavite|Bawai’s Vietnamese Kitchen
ve_b9ea4035d8|c-h-e-bacolod-chicken-house-express|manila|ci_198432e80d|Makati - Metro Manila|C.H.E. Bacolod Chicken House Express
ve_cff657d2a8|azela-manila|manila|ci_198432e80d|Manila - Metro Manila|Azela (Manila)
ve_d9f34de123|balay-dako|cavite|ci_e8e2660d1e|Cavite|Balay Dako
ve_deef23b63c|flow|manila|ci_198432e80d|Makati - Metro Manila|FLOW
ve_f04279e210|tito-boy|pampanga|ci_d6ce481bcf|Pampanga|Tito Boy$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'da4d97abb28b290c2d19a5e0b2b24966' OR md5(aw) <> '40d18c3e429d8222c1c840f32b4adeab' OR md5(nw) <> 'f57083ea2ed805835917796fb6ca22a4' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Philippines' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '6fea93181a0f7e2a3217cdc8f0dfe149' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines') <> 34 THEN RAISE EXCEPTION 'Philippines Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11719 OR (SELECT count(*) FROM venues WHERE status='active') <> 11407 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28705 OR (SELECT max(id) FROM awards) <> 35876 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4363 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7487 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 131 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13663 OR (SELECT count(*) FROM listings) <> 11719 OR (SELECT count(*) FROM city_label_source) <> 24845 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3325 OR (SELECT sum(venues_count) FROM cities) <> 11407 OR (SELECT venues_count FROM cities WHERE id='ci_198432e80d') <> 27 OR (SELECT venues_count FROM cities WHERE id='ci_91b1fd2bea') <> 6 OR (SELECT venues_count FROM cities WHERE id='ci_e8e2660d1e') <> 1 OR (SELECT count(*) FROM source_capture_ledger) <> 281 OR (SELECT max(id) FROM source_capture_ledger) <> 335 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_d6ce481bcf' OR slug='pampanga') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Pampanga')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_a338350536' OR slug='las-pinas-metro-manila') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Las Piñas - Metro Manila')) THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127643 OR aud_max <> 133472 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x) OR a.source_url='https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2026') THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url='https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2026' WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(rl,E'\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 34 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: new cities, venues, listings, slugs, city counts
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_d6ce481bcf', 'pampanga', 'Pampanga', 'Philippines', 'PH', 'city', NULL, NULL, NULL, 2);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_a338350536', 'las-pinas-metro-manila', 'Las Piñas - Metro Manila', 'Philippines', 'PH', 'city', NULL, NULL, NULL, 1);
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 11 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 11 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 11 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=30 WHERE id='ci_198432e80d' AND venues_count=27;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count manila'; END IF;
  UPDATE cities SET venues_count=9 WHERE id='ci_91b1fd2bea' AND venues_count=6;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count cebu'; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_e8e2660d1e' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count cavite'; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Philippines','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 22 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 41 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',34,'relabel:load-michelin-2027-philippines-2026-11-05 | rule 2.1.7: Philippines edition live at capture = 2026 (Oct 30, 2025, https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2026) | year 2025 -> 2026, article URL, retire 0 | Ben choices 1-6:A, Nov 5 23:54 ET'),
    ('michelin','award',41,'cleanup:load-michelin-2027-philippines-2026-11-05 | Philippines 2027, Oct 29, 2026, https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2027 | Two Stars 1, One Star 9, Bib 31 | relay sha256 08b28ab3b5cf1ee81c8e46f4469f3c6b86d18f951783b53aa91a6c5aab502cbc | Ben choices 1-6:A, Nov 5 23:54 ET'),
    ('michelin','city_label',22,'cleanup:load-michelin-2027-philippines-2026-11-05 | city labels of 11 new venues, new cities pampanga, las-pinas-metro-manila | Ben choices 1-6:A, Nov 5 23:54 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11730 OR (SELECT count(*) FROM venues WHERE status='active') <> 11418 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28746 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 41 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '40d18c3e429d8222c1c840f32b4adeab' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 172 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines' AND a.source_url IS NOT NULL GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2026:Bib Gourmand=25,2026:One Star=8,2026:Two Stars=1,2027:Bib Gourmand=31,2027:One Star=9,2027:Two Stars=1' THEN RAISE EXCEPTION 'Philippines after %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines') <> 75 THEN RAISE EXCEPTION 'Philippines rows after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13674 OR (SELECT count(*) FROM listings) <> 11730 OR (SELECT count(*) FROM city_label_source) <> 24867 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3327 OR (SELECT sum(venues_count) FROM cities) <> 11418 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 284 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=41,awards:UPDATE=34,cities:INSERT=2,cities:UPDATE=3,city_label_source:INSERT=22,listings:INSERT=11,slugs:INSERT=11,venues:INSERT=11' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
