-- load-michelin-2027-south-australia-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin South Australia 2027. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 27 new rows, year 2027 (Oct 14, 2026: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-south-australia-restaurant-selection-2027), source_url = the card (/us/en/). 23 new venues, 7 new cities. Relabel 0. Retire 0.
-- Source: docs/michelin-a1-2026-11-06/relay-south-australia-2027-list-pages-2026-11-06.txt sha256 de4c2f370b6bc608e9afe3d65114b16bc1c93c874695939f18498d8c86899829.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11777 (active 11465, closed 312); awards 28855; slugs 13721; listings 11777; labels 24961; cities 3335, sum 11465; ledger 288 rows; audit_log +151.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$$plan$;
  aw text := $plan$ve_0ee8a8dc98~One Star~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/arkhe-1244917
ve_1fbccbad94~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/seppeltsfield_7770486/restaurant/fino-seppeltsfield
ve_21b3b550d6~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/sunny-s-pizza
ve_22583eeda6~One Star~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/botanic
ve_26e78dd764~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/kingscote_7770485/restaurant/tirage-on-kangaroo-island
ve_38df6dc168~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/bar-torino
ve_39f8bcfd63~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/mclaren-vale_7770483/restaurant/the-salopian-inn
ve_416a9d611f~One Star~https://guide.michelin.com/us/en/south-australia/mclaren-vale_7770483/restaurant/maxwell-restaurant
ve_485ec46ed8~One Star~https://guide.michelin.com/us/en/south-australia/sevenhill_7770480/restaurant/skillogalee-barrel-house
ve_515c9750c3~One Star~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/aurora-at-ila
ve_5ed1af4ca0~One Star~https://guide.michelin.com/us/en/south-australia/woodside_7770481/restaurant/lvn-restaurant-at-bird-in-hand
ve_74a176d4a4~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/golden-boy
ve_793c410ab7~One Star~https://guide.michelin.com/us/en/south-australia/kangarilla_7770484/restaurant/anvers-restaurant
ve_7cbc50b440~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/la-popular-taqueria
ve_894a2e8b1e~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/africola
ve_9266964529~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/noi-vietnamese-eatery
ve_9383af1b56~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/stamps
ve_98d8033367~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/part-time-lover
ve_af3b34625d~One Star~https://guide.michelin.com/us/en/south-australia/seppeltsfield_7770486/restaurant/hentley-farm
ve_cb2b37098b~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/pantry-on-prospect
ve_cda3cbe43d~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/gondola-gondola
ve_db895dfccb~One Star~https://guide.michelin.com/us/en/south-australia/stirling_7770500/restaurant/aptos
ve_e8c09e673f~One Star~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/esmay
ve_e9fe8b1bdf~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/parwana-afghan-kitchen
ve_f6bc917177~Two Stars~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/magill-estate-restaurant
ve_f94730c17d~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/adelaide_7770061/restaurant/bistro-francais
ve_fda7d94b1f~Bib Gourmand~https://guide.michelin.com/us/en/south-australia/clare_7770499/restaurant/antidote-kitchen$plan$;
  nw text := $plan$ve_1fbccbad94~fino-seppeltsfield~seppeltsfield~ci_37a1f5075f~Seppeltsfield~Fino Seppeltsfield
ve_21b3b550d6~sunny-s-pizza~adelaide~ci_851819adaa~Adelaide~Sunny's Pizza
ve_26e78dd764~tirage-on-kangaroo-island~kingscote~ci_79fd273a12~Kingscote~Tirage on Kangaroo Island
ve_38df6dc168~bar-torino~adelaide~ci_851819adaa~Adelaide~Bar Torino
ve_39f8bcfd63~the-salopian-inn~mclaren-vale~ci_7f4807b8f8~McLaren Vale~The Salopian Inn
ve_416a9d611f~maxwell-restaurant~mclaren-vale~ci_7f4807b8f8~McLaren Vale~Maxwell Restaurant
ve_485ec46ed8~skillogalee-barrel-house~sevenhill~ci_6024dbf0cf~Sevenhill~Skillogalee Barrel House
ve_515c9750c3~aurora-at-ila~adelaide~ci_851819adaa~Adelaide~Aurora at ILA
ve_5ed1af4ca0~lvn-restaurant-at-bird-in-hand~woodside-au~ci_5ffa8386ab~Woodside~LVN Restaurant at Bird in Hand
ve_74a176d4a4~golden-boy~adelaide~ci_851819adaa~Adelaide~Golden Boy
ve_793c410ab7~anvers-restaurant~kangarilla~ci_197fa43f87~Kangarilla~Anvers Restaurant
ve_7cbc50b440~la-popular-taqueria~adelaide~ci_851819adaa~Adelaide~La Popular Taqueria
ve_894a2e8b1e~africola~adelaide~ci_851819adaa~Adelaide~Africola
ve_9266964529~noi-vietnamese-eatery~adelaide~ci_851819adaa~Adelaide~Noi Vietnamese Eatery
ve_9383af1b56~stamps~adelaide~ci_851819adaa~Adelaide~Stamps
ve_98d8033367~part-time-lover~adelaide~ci_851819adaa~Adelaide~Part Time Lover
ve_cb2b37098b~pantry-on-prospect~adelaide~ci_851819adaa~Adelaide~Pantry on Prospect
ve_cda3cbe43d~gondola-gondola~adelaide~ci_851819adaa~Adelaide~Gondola Gondola
ve_db895dfccb~aptos~stirling~ci_eeb9a95c72~Stirling~Aptos
ve_e8c09e673f~esmay~adelaide~ci_851819adaa~Adelaide~Esmay
ve_e9fe8b1bdf~parwana-afghan-kitchen~adelaide~ci_851819adaa~Adelaide~Parwana Afghan Kitchen
ve_f94730c17d~bistro-francais~adelaide~ci_851819adaa~Adelaide~Bistro Français
ve_fda7d94b1f~antidote-kitchen~clare~ci_babc2860c1~Clare~Antidote Kitchen$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'd41d8cd98f00b204e9800998ecf8427e' OR md5(aw) <> 'f7cca9a5341fc07e9c2e532b810b34d7' OR md5(nw) <> '3761f1ee95df9b619de858f687ad0809' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(coalesce(string_agg(t, E'\n' ORDER BY t COLLATE "C"),'')) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country_iso='AU') y;
  IF fp IS DISTINCT FROM 'd41d8cd98f00b204e9800998ecf8427e' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='AU') <> 0 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11754 OR (SELECT count(*) FROM venues WHERE status='active') <> 11442 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28828 OR (SELECT max(id) FROM awards) <> 35999 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 27 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 254 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13698 OR (SELECT count(*) FROM listings) <> 11754 OR (SELECT count(*) FROM city_label_source) <> 24915 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3328 OR (SELECT sum(venues_count) FROM cities) <> 11442 OR (SELECT venues_count FROM cities WHERE id='ci_851819adaa') <> 5 OR (SELECT venues_count FROM cities WHERE id='ci_37a1f5075f') <> 1 OR (SELECT count(*) FROM source_capture_ledger) <> 286 OR (SELECT max(id) FROM source_capture_ledger) <> 340 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_eeb9a95c72' OR slug='stirling') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Stirling')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_7f4807b8f8' OR slug='mclaren-vale') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('McLaren Vale')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_6024dbf0cf' OR slug='sevenhill') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Sevenhill')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_197fa43f87' OR slug='kangarilla') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Kangarilla')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_5ffa8386ab' OR slug='woodside-au') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Woodside')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_babc2860c1' OR slug='clare') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Clare')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_79fd273a12' OR slug='kingscote') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Kingscote')) THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127982 OR aud_max <> 133811 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows

  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND (v.status='active' OR v.id IN ('')));
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE x<>'' AND (split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',6))),'[^a-z0-9]+','-','g')));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE x<>'' AND (EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',6)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2)));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start

  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_eeb9a95c72', 'stirling', 'Stirling', 'Australia', 'AU', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_7f4807b8f8', 'mclaren-vale', 'McLaren Vale', 'Australia', 'AU', 'city', NULL, NULL, NULL, 2);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_6024dbf0cf', 'sevenhill', 'Sevenhill', 'Australia', 'AU', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_197fa43f87', 'kangarilla', 'Kangarilla', 'Australia', 'AU', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_5ffa8386ab', 'woodside-au', 'Woodside', 'Australia', 'AU', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_babc2860c1', 'clare', 'Clare', 'Australia', 'AU', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_79fd273a12', 'kingscote', 'Kingscote', 'Australia', 'AU', 'city', NULL, NULL, NULL, 1);
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',6), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 23 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 23 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 23 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=19 WHERE id='ci_851819adaa' AND venues_count=5;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count adelaide'; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_37a1f5075f' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count seppeltsfield'; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),('Australia','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 46 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2027, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 27 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',27,'cleanup:load-michelin-2027-south-australia-2026-11-06 | South Australia 2027, Oct 14, 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-south-australia-restaurant-selection-2027 | Three Stars 0, Two Stars 1, One Star 10, Bib 16 | relay sha256 de4c2f370b6bc608e9afe3d65114b16bc1c93c874695939f18498d8c86899829 | DRAFT, choices not yet given'),
    ('michelin','city_label',46,'cleanup:load-michelin-2027-south-australia-2026-11-06 | city labels of 23 new venues, new cities stirling, mclaren-vale, sevenhill, kangarilla, woodside-au, clare, kingscote | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11777 OR (SELECT count(*) FROM venues WHERE status='active') <> 11465 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28855 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 27 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> 'f7cca9a5341fc07e9c2e532b810b34d7' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 27 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 281 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='AU' GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2027:Bib Gourmand=16,2027:One Star=10,2027:Two Stars=1' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='AU' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13721 OR (SELECT count(*) FROM listings) <> 11777 OR (SELECT count(*) FROM city_label_source) <> 24961 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3335 OR (SELECT sum(venues_count) FROM cities) <> 11465 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 288 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=27,cities:INSERT=7,cities:UPDATE=2,city_label_source:INSERT=46,listings:INSERT=23,slugs:INSERT=23,venues:INSERT=23' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
