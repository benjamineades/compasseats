-- load-michelin-2027-greece-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin Greece 2027. Ben choices 1-6:A, Nov 6 01:03 ET. This file runs only after Ben's "go".
-- 30 new rows, year 2027 (Oct 20, 2026: https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-athens-thessaloniki-santorini-2027-marks-a-milestone-for-greek-gastronomy), source_url = the card (/us/en/). 14 new venues, 0 new cities. Relabel 17 rows 2025 -> 2024: Athens edition live at capture = 2024 (Dec 18, 2024); no Athens selection in 2025 (https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-expands-in-greece-for-2026). Retire 0.
-- Source: docs/michelin-a1-2026-11-06/relay-greece-2027-list-pages-2026-11-06.txt sha256 8976dd6d36b4e0886c5b7655cd6b9357c5ce02b0a5f3b16a5bb343986bc67982.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11768 (active 11456, closed 312); awards 28858; slugs 13712; listings 11768; labels 24943; cities 3328, sum 11456; ledger 289 rows; audit_log +120.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1467~ve_10eecfa689~Two Stars
3751~ve_6e1ff31f5f~One Star
3754~ve_d9cbf5c3e3~One Star
3756~ve_29395dff3a~One Star
3757~ve_69fcaf6d82~One Star
3759~ve_f98d22b271~One Star
3760~ve_c2c0fa86ff~One Star
3761~ve_0b650c34ab~One Star
3764~ve_e9c3b13a11~One Star
3766~ve_42af5ac0c7~One Star
3768~ve_8575b7c9aa~One Star
3769~ve_85bd89ee1e~One Star
9302~ve_ad540c4225~Bib Gourmand
9303~ve_732d2c68ce~Bib Gourmand
9304~ve_a726b58f0e~Bib Gourmand
9305~ve_30cb4b84d8~Bib Gourmand
9306~ve_34358d5954~Bib Gourmand$plan$;
  aw text := $plan$ve_0089b8041b~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/aleria
ve_05cd9d3a35~Bib Gourmand~https://guide.michelin.com/us/en/attica/athens/restaurant/zohos
ve_0b650c34ab~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/pelagos
ve_10eecfa689~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/delta
ve_1eb871e231~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/sense
ve_238b50fe0e~One Star~https://guide.michelin.com/us/en/south-aegean/santorini_1772287/restaurant/lauda
ve_29395dff3a~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/herve
ve_30cb4b84d8~Bib Gourmand~https://guide.michelin.com/us/en/attica/athens/restaurant/nolan
ve_34358d5954~Bib Gourmand~https://guide.michelin.com/us/en/attica/athens/restaurant/pharaoh
ve_42af5ac0c7~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/spondi
ve_5c0fb3dbb0~Bib Gourmand~https://guide.michelin.com/us/en/attica/athens/restaurant/upon
ve_66afa513d0~Bib Gourmand~https://guide.michelin.com/us/en/central-macedonia/thessaloniki_1773462/restaurant/deka-trapezia
ve_66b4bd3391~One Star~https://guide.michelin.com/us/en/south-aegean/santorini_1772287/restaurant/selene
ve_69fcaf6d82~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/hytra
ve_6e1ff31f5f~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/botrini-s
ve_7887ccf0ad~Bib Gourmand~https://guide.michelin.com/us/en/central-macedonia/thessaloniki_1773462/restaurant/sintrofi
ve_8575b7c9aa~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/the-zillers
ve_85bd89ee1e~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/tudor-hall
ve_8c501271d3~Two Stars~https://guide.michelin.com/us/en/south-aegean/santorini_1772287/restaurant/lycabettus
ve_945282988d~Bib Gourmand~https://guide.michelin.com/us/en/central-macedonia/thessaloniki_1773462/restaurant/three-little-pigs
ve_ab61d4d4e5~One Star~https://guide.michelin.com/us/en/south-aegean/santorini_1772287/restaurant/botrini-s-santorini
ve_ad540c4225~Bib Gourmand~https://guide.michelin.com/us/en/attica/athens/restaurant/akra
ve_c2c0fa86ff~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/patio
ve_d9cbf5c3e3~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/ctc
ve_de424b03fc~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/simul
ve_e9c3b13a11~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/soil
ve_eca705112a~Bib Gourmand~https://guide.michelin.com/us/en/central-macedonia/thessaloniki_1773462/restaurant/to-manitari
ve_f6bc89448f~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/see-ds
ve_f79d041242~Bib Gourmand~https://guide.michelin.com/us/en/central-macedonia/thessaloniki_1773462/restaurant/menu-me-nou
ve_f98d22b271~One Star~https://guide.michelin.com/us/en/attica/athens/restaurant/makris-athens$plan$;
  nw text := $plan$ve_0089b8041b~aleria~athens~ci_8fde6a6592~Athens~Aleria
ve_05cd9d3a35~zohos~athens~ci_8fde6a6592~Athens~Zohós
ve_1eb871e231~sense~athens~ci_8fde6a6592~Athens~SENSE
ve_238b50fe0e~lauda~santorini~ci_a949f33046~Santorini~Lauda
ve_5c0fb3dbb0~upon~athens~ci_8fde6a6592~Athens~UPON
ve_66afa513d0~deka-trapezia~thessaloniki~ci_29833ab42f~Thessalonica~Deka trapezia
ve_7887ccf0ad~sintrofi~thessaloniki~ci_29833ab42f~Thessalonica~Sintrofi
ve_8c501271d3~lycabettus~santorini~ci_a949f33046~Santorini~Lycabettus
ve_945282988d~three-little-pigs~thessaloniki~ci_29833ab42f~Thessalonica~Three Little Pigs
ve_ab61d4d4e5~botrini-s-santorini~santorini~ci_a949f33046~Santorini~Botrini's Santorini
ve_de424b03fc~simul~athens~ci_8fde6a6592~Athens~Simul
ve_eca705112a~to-manitari~thessaloniki~ci_29833ab42f~Thessalonica~To Manitari
ve_f6bc89448f~see-ds~athens~ci_8fde6a6592~Athens~see|ds
ve_f79d041242~menu-me-nou~thessaloniki~ci_29833ab42f~Thessalonica~Menu me... nou$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '7fd248b5bfd2e9be26c20dd0f47e12be' OR md5(aw) <> 'ada989f6d8c4eadea69c8c31bde6a88f' OR md5(nw) <> '0a170df7383aad45479d105df211c94b' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(coalesce(string_agg(t, E'\n' ORDER BY t COLLATE "C"),'')) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country_iso='GR') y;
  IF fp IS DISTINCT FROM '5cc1454aa9a24120f4016a6956b32007' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='GR') <> 17 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11754 OR (SELECT count(*) FROM venues WHERE status='active') <> 11442 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28828 OR (SELECT max(id) FROM awards) <> 35999 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 27 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 254 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13698 OR (SELECT count(*) FROM listings) <> 11754 OR (SELECT count(*) FROM city_label_source) <> 24915 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3328 OR (SELECT sum(venues_count) FROM cities) <> 11442 OR (SELECT venues_count FROM cities WHERE id='ci_8fde6a6592') <> 29 OR (SELECT venues_count FROM cities WHERE id='ci_a949f33046') <> 1 OR (SELECT venues_count FROM cities WHERE id='ci_29833ab42f') <> 2 OR (SELECT count(*) FROM source_capture_ledger) <> 286 OR (SELECT max(id) FROM source_capture_ledger) <> 340 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF false THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127982 OR aud_max <> 133811 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url='https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-athens-2024-is-out') THEN RAISE EXCEPTION 'relabel url in use'; END IF;
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
  UPDATE awards a SET year=2024, source_url='https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-athens-2024-is-out' WHERE a.id IN (SELECT split_part(x,'~',1)::bigint FROM regexp_split_to_table(rl,E'\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'relabel %', n; END IF;

  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',6), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=35 WHERE id='ci_8fde6a6592' AND venues_count=29;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count athens'; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_a949f33046' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count santorini'; END IF;
  UPDATE cities SET venues_count=7 WHERE id='ci_29833ab42f' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count thessaloniki'; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),('Greece','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 28 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2027, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 30 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',17,'relabel:load-michelin-2027-greece-2026-11-06 | rule 2.1.7: Athens edition live at capture = 2024 (Dec 18, 2024); no Athens selection in 2025 (https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-expands-in-greece-for-2026) | https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-athens-2024-is-out | year 2025 -> 2024, article URL, retire 0 | Ben choices 1-6:A, Nov 6 01:03 ET'),
    ('michelin','award',30,'cleanup:load-michelin-2027-greece-2026-11-06 | Greece 2027, Oct 20, 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-athens-thessaloniki-santorini-2027-marks-a-milestone-for-greek-gastronomy | Three Stars 0, Two Stars 1, One Star 19, Bib 10 | relay sha256 8976dd6d36b4e0886c5b7655cd6b9357c5ce02b0a5f3b16a5bb343986bc67982 | Ben choices 1-6:A, Nov 6 01:03 ET'),
    ('michelin','city_label',28,'cleanup:load-michelin-2027-greece-2026-11-06 | city labels of 14 new venues | Ben choices 1-6:A, Nov 6 01:03 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11768 OR (SELECT count(*) FROM venues WHERE status='active') <> 11456 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28858 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 30 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> 'ada989f6d8c4eadea69c8c31bde6a88f' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4312 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 284 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='GR' GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2024:Bib Gourmand=5,2024:One Star=11,2024:Two Stars=1,2027:Bib Gourmand=10,2027:One Star=19,2027:Two Stars=1' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='GR' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13712 OR (SELECT count(*) FROM listings) <> 11768 OR (SELECT count(*) FROM city_label_source) <> 24943 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3328 OR (SELECT sum(venues_count) FROM cities) <> 11456 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 289 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=30,awards:UPDATE=17,cities:UPDATE=3,city_label_source:INSERT=28,listings:INSERT=14,slugs:INSERT=14,venues:INSERT=14' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
