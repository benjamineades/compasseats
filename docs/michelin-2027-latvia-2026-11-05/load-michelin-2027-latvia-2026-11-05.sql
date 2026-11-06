-- load-michelin-2027-latvia-2026-11-05.sql
-- CompassEats, Nov 6 2026. Michelin Latvia 2027 and the 2026 label. Ben choices 1-5:A, Nov 5 23:33 ET. This file runs only after Ben's "go".
-- Rule 2.1.7: the 7 legacy rows hold the 2026 edition (Oct 22, 2025: https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2026-winners-michelin-guide-ceremony). Relabel 2025 -> 2026, source_url = that article. Retire 0.
-- Then 9 new rows, year 2027 (Nov 5, 2026: https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2027-winners-michelin-guide-ceremony): One Star 2, Bib Gourmand 7, source_url = the card (/us/en/). 2 new venues.
-- Then 5 history rows, year 2025, source_url = https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2025-winners-michelin-guide-ceremony: One Star 2, Bib Gourmand 3.
-- Source: docs/michelin-2027-latvia-2026-11-05/relay-lv-2027-list-pages-2026-11-05.txt sha256 4b49d822714d5c80072e5f4c493c74819d705a8bd936eb09a034886ac860e164.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11719 (active 11407, closed 312); awards 28705; slugs 13663; listings 11719; labels 24845; cities 3325, sum 11407; ledger 281 rows; Michelin 2025/2026/2027 4363/7487/131; audit_log +32.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$7557|ve_4e6e00fcea|One Star
7559|ve_c8293fb725|One Star
9985|ve_19940406fd|Bib Gourmand
11823|ve_fc08eea783|Bib Gourmand
11824|ve_a79704e992|Bib Gourmand
11825|ve_072176a06f|Bib Gourmand
11826|ve_99bd11222f|Bib Gourmand$plan$;
  aw text := $plan$ve_072176a06f|Bib Gourmand|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/smor-bistro
ve_19940406fd|Bib Gourmand|https://guide.michelin.com/us/en/vidzeme/cesis_1988584/restaurant/h-e-vanadzins
ve_4e6e00fcea|One Star|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/john-chef-s-hall
ve_6b3fda5d22|Bib Gourmand|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/cafe-mimosa
ve_99bd11222f|Bib Gourmand|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/snatch
ve_a79704e992|Bib Gourmand|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/shoyu
ve_c8293fb725|One Star|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/max-cekot-kitchen
ve_eb67a13d26|Bib Gourmand|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/balta-kaza
ve_fc08eea783|Bib Gourmand|https://guide.michelin.com/us/en/riga-region/riga_1991577/restaurant/milda$plan$;
  hi text := $plan$ve_4e6e00fcea|One Star
ve_99bd11222f|Bib Gourmand
ve_a79704e992|Bib Gourmand
ve_c8293fb725|One Star
ve_fc08eea783|Bib Gourmand$plan$;
  nw text := $plan$ve_6b3fda5d22|cafe-mimosa|riga|ci_922f13fdf0|Riga|Café Mimosa
ve_eb67a13d26|balta-kaza|riga|ci_922f13fdf0|Riga|Baltā Kaza$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'adf5bbaeafb411744ce317137f65f045' OR md5(aw) <> '65a2ba852c526756a1a5ab5f664a267c' OR md5(hi) <> 'ea5f38fa3e7e429c5837e0badae7038d' OR md5(nw) <> '92883170fa7b78acb02842fe33853ebf' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Latvia' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '8be8e7c5acb901e6140c38599b138d30' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia') <> 7 THEN RAISE EXCEPTION 'Latvia Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11717 OR (SELECT count(*) FROM venues WHERE status='active') <> 11405 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28691 OR (SELECT max(id) FROM awards) <> 35862 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4365 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7480 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13661 OR (SELECT count(*) FROM listings) <> 11717 OR (SELECT count(*) FROM city_label_source) <> 24841 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3325 OR (SELECT sum(venues_count) FROM cities) <> 11405 OR (SELECT venues_count FROM cities WHERE id='ci_922f13fdf0') <> 7 OR (SELECT count(*) FROM source_capture_ledger) <> 277 OR (SELECT max(id) FROM source_capture_ledger) <> 331 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127611 OR aud_max <> 133440 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x) OR a.source_url IN ('https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2025-winners-michelin-guide-ceremony','https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2026-winners-michelin-guide-ceremony','https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2027-winners-michelin-guide-ceremony')) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url='https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2026-winners-michelin-guide-ceremony' WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(rl,E'\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venues, listings, slugs, city count
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=9 WHERE id='ci_922f13fdf0' AND venues_count=7;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Latvia','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 9 THEN RAISE EXCEPTION 'awards 2027 %', n; END IF;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2025, NULL, split_part(x,'|',2), NULL, 'https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2025-winners-michelin-guide-ceremony' FROM regexp_split_to_table(hi,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 5 THEN RAISE EXCEPTION 'awards 2025 %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',7,'relabel:load-michelin-2027-latvia-2026-11-05 | rule 2.1.7: Latvia edition live at capture = 2026 (Oct 22, 2025, https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2026-winners-michelin-guide-ceremony) | year 2025 -> 2026, article URL, retire 0 | Ben choices 1-5:A, Nov 5 23:33 ET'),
    ('michelin','award',9,'cleanup:load-michelin-2027-latvia-2026-11-05 | Latvia 2027, Nov 5, 2026, https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2027-winners-michelin-guide-ceremony | One Star 2, Bib 7 | relay sha256 4b49d822714d5c80072e5f4c493c74819d705a8bd936eb09a034886ac860e164 | Ben choices 1-5:A, Nov 5 23:33 ET'),
    ('michelin','award',5,'cleanup:load-michelin-2027-latvia-2026-11-05 | Latvia 2025 history, https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2025-winners-michelin-guide-ceremony | One Star 2, Bib 3 | Ben choices 1-5:A, Nov 5 23:33 ET'),
    ('michelin','city_label',4,'cleanup:load-michelin-2027-latvia-2026-11-05 | city labels of 2 new venues | Ben choices 1-5:A, Nov 5 23:33 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11719 OR (SELECT count(*) FROM venues WHERE status='active') <> 11407 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28705 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 14 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '65a2ba852c526756a1a5ab5f664a267c' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4363 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7487 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 131 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia' AND a.source_url IS NOT NULL GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2025:Bib Gourmand=3,2025:One Star=2,2026:Bib Gourmand=5,2026:One Star=2,2027:Bib Gourmand=7,2027:One Star=2' THEN RAISE EXCEPTION 'Latvia after %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia') <> 21 THEN RAISE EXCEPTION 'Latvia rows after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13663 OR (SELECT count(*) FROM listings) <> 11719 OR (SELECT count(*) FROM city_label_source) <> 24845 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3325 OR (SELECT sum(venues_count) FROM cities) <> 11407 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 281 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=14,awards:UPDATE=7,cities:UPDATE=1,city_label_source:INSERT=4,listings:INSERT=2,slugs:INSERT=2,venues:INSERT=2' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
