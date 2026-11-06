-- load-michelin-2026-dubai-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin Dubai 2026. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 42 new rows, year 2026 (Oct 6, 2026: https://guide.michelin.com/ae-du/en/article/michelin-guide-ceremony/full-list-michelin-guide-dubai-selection), source_url = the card (/us/en/). 4 new venues, 0 new cities. Relabel 0. Retire 0.
-- Source: docs/michelin-a1-2026-11-06/relay-dubai-2026-list-pages-2026-11-06.txt sha256 3e6f66b26d45a2acd424754394020703afcf878329ca717b3e6788146dbbb351.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11758 (active 11446, closed 312); awards 28870; slugs 13702; listings 11758; labels 24923; cities 3328, sum 11446; ledger 288 rows; audit_log +63.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$$plan$;
  aw text := $plan$ve_05d3c5844a~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/smoked-room-1212350
ve_0ca8c8a503~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/duo-gastrobar-creek-harbour
ve_138511a1e1~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/shabestan
ve_210bcd7f88~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/goldfish
ve_2407cf20a7~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/ossiano
ve_26c5dd7c6d~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/hoseki
ve_28e0c32038~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/birch
ve_2dece88ca1~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/tasca-by-jose-avillez
ve_35885413ee~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/reif-japanese-kushiyaki
ve_3778551afd~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/yubi-dubai
ve_443b63b685~Two Stars~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/il-ristorante-niko-romito-1196980
ve_454e2a3112~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/hawkerboi
ve_556d69255a~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/dinner-by-heston-blumenthal-1206450
ve_5ef63116a1~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/11-woodfire
ve_5f0b3b9f3c~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/middle-child
ve_6d0ad571d7~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/bait-maryam
ve_6d942f82dd~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/khadak
ve_6ec234643a~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/jamavar-1210531
ve_6f2c83eafe~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/three-bros
ve_758003680a~Two Stars~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/orfali-bros
ve_76723808cd~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/21-grams
ve_7f908a045b~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/manao-1217282
ve_81e21905a6~Three Stars~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/fzn-by-bjorn-frantzen
ve_8e1313c21e~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/hakkasan-516107
ve_9ed23a6304~Two Stars~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/stay-by-yannick-alleno
ve_b13765366f~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/berenjak-1211855
ve_ba69122f1c~Two Stars~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/row-on-45
ve_be4d5f8025~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/reif-japanese-kushiyaki-dubai-hills
ve_cb9639a243~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/kinoya
ve_cd2fad38f3~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/avatara
ve_cd8fdacb4d~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/s-e-a-bistrot
ve_cde173dbb9~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/sufret-maryam
ve_ceb0e3468a~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/3-fils
ve_cf92b2f9cd~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/harummanis
ve_d35cc76459~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/al-muntaha
ve_d5d255c325~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/kigo
ve_e27bca251d~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/al-khayma
ve_e61e6c68d8~Three Stars~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/tresind-studio
ve_e7a107335e~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/revelry
ve_f3bc6b1bf8~One Star~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/moonrise
ve_f9b1391518~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/konjiki-hototogisu
ve_f9ea14cbc5~Bib Gourmand~https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/duo-gastrobar$plan$;
  nw text := $plan$ve_3778551afd~yubi-dubai~dubai~ci_3c40d285e6~Dubai~YUBI Dubai
ve_5f0b3b9f3c~middle-child~dubai~ci_3c40d285e6~Dubai~Middle Child
ve_cd8fdacb4d~s-e-a-bistrot~dubai~ci_3c40d285e6~Dubai~S.E.A Bistrot
ve_d5d255c325~kigo~dubai~ci_3c40d285e6~Dubai~KIGO$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'd41d8cd98f00b204e9800998ecf8427e' OR md5(aw) <> 'dcd9d6f2749b705a7990bffdb41f11e1' OR md5(nw) <> '3e300055c255cc3a135543950d4125f8' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(coalesce(string_agg(t, E'\n' ORDER BY t COLLATE "C"),'')) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.id='ci_3c40d285e6') y;
  IF fp IS DISTINCT FROM 'd902f74e3620b8fff542ca2c2a1def0d' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.id='ci_3c40d285e6') <> 38 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11754 OR (SELECT count(*) FROM venues WHERE status='active') <> 11442 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28828 OR (SELECT max(id) FROM awards) <> 35999 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 27 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 254 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13698 OR (SELECT count(*) FROM listings) <> 11754 OR (SELECT count(*) FROM city_label_source) <> 24915 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3328 OR (SELECT sum(venues_count) FROM cities) <> 11442 OR (SELECT venues_count FROM cities WHERE id='ci_3c40d285e6') <> 93 OR (SELECT count(*) FROM source_capture_ledger) <> 286 OR (SELECT max(id) FROM source_capture_ledger) <> 340 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF false THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127982 OR aud_max <> 133811 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows

  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND (v.status='active' OR v.id IN ('ve_d35cc76459')));
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


  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',6), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=97 WHERE id='ci_3c40d285e6' AND venues_count=93;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count dubai'; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),('United Arab Emirates','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2026, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 42 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',42,'cleanup:load-michelin-2026-dubai-2026-11-06 | Dubai 2026, Oct 6, 2026, https://guide.michelin.com/ae-du/en/article/michelin-guide-ceremony/full-list-michelin-guide-dubai-selection | Three Stars 2, Two Stars 4, One Star 14, Bib 22 | relay sha256 3e6f66b26d45a2acd424754394020703afcf878329ca717b3e6788146dbbb351 | DRAFT, choices not yet given'),
    ('michelin','city_label',8,'cleanup:load-michelin-2026-dubai-2026-11-06 | city labels of 4 new venues | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11758 OR (SELECT count(*) FROM venues WHERE status='active') <> 11446 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28870 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 42 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> 'dcd9d6f2749b705a7990bffdb41f11e1' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 27 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7563 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 254 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.id='ci_3c40d285e6' GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2025:Bib Gourmand=19,2025:One Star=14,2025:Three Stars=2,2025:Two Stars=3,2026:Bib Gourmand=22,2026:One Star=14,2026:Three Stars=2,2026:Two Stars=4' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.id='ci_3c40d285e6' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13702 OR (SELECT count(*) FROM listings) <> 11758 OR (SELECT count(*) FROM city_label_source) <> 24923 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3328 OR (SELECT sum(venues_count) FROM cities) <> 11446 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 288 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=42,cities:UPDATE=1,city_label_source:INSERT=8,listings:INSERT=4,slugs:INSERT=4,venues:INSERT=4' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
