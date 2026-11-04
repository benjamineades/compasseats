-- fix-placeid-tailor-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open items 1 and 2. Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A". This file runs only after his "go".
-- 1A: The Tailory ve_d1e61a315d becomes Tailor, status closed, published false. New canonical /new-york/tailor. Old slug non-canonical. Award 15336 gets the 50 Best URL. No redirect (Nov 2 rule: a hidden venue URL gives a 404).
-- 2A: 6 award rows move to the venue the publisher names, each with a URL. Asia 2026 No. 65 to Fumee. OAD Joel Robuchon at The Mansion (2), Fiola da Fabio Trabocchi (2), Sukiyabashi Jiro Roppongi (1).
-- 4A: 5 new active venues under the Michelin card names, 6 Bib rows move to them with a URL. Stars stay on the old venues. No price row on a new venue. Old venue names and prices do not change.
-- 5A: new city Naples, Florida (naples-fl). Bleu Provence moves, redirect /naples/bleu-provence. No URL on award 21794 (the page does not print 2026). Kabuki, Carmen, Fiesta: no change.
-- 3B: 12 A2 rows: no change.
-- Expected after: venues 11,325 (active 11,032, closed 293); awards 25,323; Michelin 2025 no URL 3,029; Michelin 2026 no URL 434; slugs 13,173 (non-canonical 1,848); listings 11,325; city labels 24,057;
--   cities 3,280, sum 11,032; redirects 11; price 7,759; rename_batches 33; rename_rows 1,398; ledger 205 rows; audit_log +54 (120,092 rows).
BEGIN;
DO $fix$
DECLARE n bigint; s text; fp text; aud_max bigint; bid bigint; x bigint;
BEGIN
  -- PRE gates
  SELECT md5(t) INTO fp FROM (SELECT (SELECT string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id) FROM venues v WHERE v.id = ANY (ARRAY['ve_175f7d63c2','ve_1779942f15','ve_273774c457','ve_38916224da','ve_732d5cc78a','ve_7a967f498b','ve_842d853e13','ve_965e0e3908','ve_9acf561dcf','ve_b6eb74a0a2','ve_c2e6c8acfb','ve_c5e00877c1','ve_d1e61a315d','ve_d6d7a07cee','ve_fb7dc1ff33'])) || E'\n' || (SELECT string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.rank::text,'')||'|'||coalesce(a.source_url,''), E'\n' ORDER BY a.id) FROM awards a WHERE a.id = ANY (ARRAY[3142,3422,5898,5938,8214,12737,12739,15336,15683,16921,16923,17151,17153])) || E'\n' || (SELECT string_agg(s.city_slug||'|'||s.slug||'|'||s.venue_id||'|'||s.is_canonical, E'\n' ORDER BY s.city_slug,s.slug) FROM slugs s WHERE s.venue_id IN ('ve_d1e61a315d','ve_732d5cc78a')) AS t) z;
  IF fp IS DISTINCT FROM 'd2f05ab8b2bafaddb9b38c3648ae118c' THEN RAISE EXCEPTION 'plan fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM venues WHERE status='active') <> 11028 OR (SELECT count(*) FROM venues WHERE status='closed') <> 292 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25323 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3033 THEN RAISE EXCEPTION '2025 no URL before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 436 THEN RAISE EXCEPTION '2026 no URL before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13167 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1847 OR (SELECT count(*) FROM listings) <> 11320 OR (SELECT count(*) FROM city_label_source) <> 24047 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3279 OR (SELECT sum(venues_count) FROM cities) <> 11028 OR (SELECT count(*) FROM redirects) <> 10 OR (SELECT count(*) FROM price) <> 7759 THEN RAISE EXCEPTION 'cities, redirects, price before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 32 OR (SELECT count(*) FROM rename_rows) <> 1397 OR EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='rename-tailor-new-york-2026-11-03') OR EXISTS (SELECT 1 FROM rename_rows WHERE venue_id='ve_d1e61a315d') THEN RAISE EXCEPTION 'rename before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 199 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 120038 OR aud_max <> 125867 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF 'ci_9072b5c1e5' <> 'ci_'||left(md5('naples-fl'),10) THEN RAISE EXCEPTION 'city id rule'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_9072b5c1e5' OR slug='naples-fl') OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='naples-fl') THEN RAISE EXCEPTION 'city clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='new-york' AND slug='tailor') OR EXISTS (SELECT 1 FROM venues WHERE city_id='ci_d44d6be1a3' AND norm_key=norm_key('Tailor')) THEN RAISE EXCEPTION 'tailor clash'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path IN ('/naples/bleu-provence','/naples-fl/bleu-provence') OR to_path LIKE '%bleu-provence%' OR from_path LIKE '/new-york/t%' OR to_path LIKE '%tailor%') THEN RAISE EXCEPTION 'redirect clash'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id IN ('ve_d1e61a315d','ve_732d5cc78a')) THEN RAISE EXCEPTION 'blurb'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id='ve_38916224da' AND source_id='asia-50-best-restaurants' AND year=2026) OR EXISTS (SELECT 1 FROM awards WHERE venue_id IN ('ve_273774c457','ve_842d853e13','ve_175f7d63c2') AND source_id='oad') THEN RAISE EXCEPTION 'target already holds the row'; END IF;
  IF 've_3019edc0d9' <> 've_'||left(md5('ligist:worgotter-wirtshaus'),10) THEN RAISE EXCEPTION 'venue id rule worgotter-wirtshaus'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('Wörgötter - Wirtshaus')),'[^a-z0-9]+','-','g')) <> 'worgotter-wirtshaus' THEN RAISE EXCEPTION 'slug rule worgotter-wirtshaus'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id='ve_3019edc0d9' OR (city_id='ci_4421c43eb7' AND norm_key=norm_key('Wörgötter - Wirtshaus'))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='ligist' AND slug='worgotter-wirtshaus') THEN RAISE EXCEPTION 'clash worgotter-wirtshaus'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_4421c43eb7' AND slug='ligist') IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'count ligist'; END IF;
  IF 've_d3fd2ae165' <> 've_'||left(md5('leibnitz:schlosskeller-wirtshaus'),10) THEN RAISE EXCEPTION 'venue id rule schlosskeller-wirtshaus'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('Schlosskeller Wirtshaus')),'[^a-z0-9]+','-','g')) <> 'schlosskeller-wirtshaus' THEN RAISE EXCEPTION 'slug rule schlosskeller-wirtshaus'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id='ve_d3fd2ae165' OR (city_id='ci_f957c08967' AND norm_key=norm_key('Schlosskeller Wirtshaus'))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='leibnitz' AND slug='schlosskeller-wirtshaus') THEN RAISE EXCEPTION 'clash schlosskeller-wirtshaus'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_f957c08967' AND slug='leibnitz') IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'count leibnitz'; END IF;
  IF 've_677a6f224a' <> 've_'||left(md5('singapore:tai-wah-pork-noodle'),10) THEN RAISE EXCEPTION 'venue id rule tai-wah-pork-noodle'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('Tai Wah Pork Noodle')),'[^a-z0-9]+','-','g')) <> 'tai-wah-pork-noodle' THEN RAISE EXCEPTION 'slug rule tai-wah-pork-noodle'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id='ve_677a6f224a' OR (city_id='ci_d3197fb64e' AND norm_key=norm_key('Tai Wah Pork Noodle'))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='singapore' AND slug='tai-wah-pork-noodle') THEN RAISE EXCEPTION 'clash tai-wah-pork-noodle'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_d3197fb64e' AND slug='singapore') IS DISTINCT FROM 205 THEN RAISE EXCEPTION 'count singapore'; END IF;
  IF 've_754faabbde' <> 've_'||left(md5('trondheim:fagn-bistro'),10) THEN RAISE EXCEPTION 'venue id rule fagn-bistro'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('FAGN-Bistro')),'[^a-z0-9]+','-','g')) <> 'fagn-bistro' THEN RAISE EXCEPTION 'slug rule fagn-bistro'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id='ve_754faabbde' OR (city_id='ci_9bd6842b49' AND norm_key=norm_key('FAGN-Bistro'))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='trondheim' AND slug='fagn-bistro') THEN RAISE EXCEPTION 'clash fagn-bistro'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_9bd6842b49' AND slug='trondheim') IS DISTINCT FROM 2 THEN RAISE EXCEPTION 'count trondheim'; END IF;
  IF 've_431ae3ca78' <> 've_'||left(md5('simrishamn:vyn-food-wine-bar'),10) THEN RAISE EXCEPTION 'venue id rule vyn-food-wine-bar'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('Vyn Food & Wine Bar')),'[^a-z0-9]+','-','g')) <> 'vyn-food-wine-bar' THEN RAISE EXCEPTION 'slug rule vyn-food-wine-bar'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id='ve_431ae3ca78' OR (city_id='ci_50fc6ffdaf' AND norm_key=norm_key('Vyn Food & Wine Bar'))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='simrishamn' AND slug='vyn-food-wine-bar') THEN RAISE EXCEPTION 'clash vyn-food-wine-bar'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_50fc6ffdaf' AND slug='simrishamn') IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'count simrishamn'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_d44d6be1a3' AND slug='new-york') IS DISTINCT FROM 346 OR (SELECT venues_count FROM cities WHERE id='ci_d5fc4b0e45' AND slug='naples') IS DISTINCT FROM 9 THEN RAISE EXCEPTION 'count new-york, naples'; END IF;

  -- WRITE: 1A The Tailory
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('rename-tailor-new-york-2026-11-03', 'staged', 'Open item 2: The Tailory to Tailor; fixture fixtures/rename/tailor-new-york-2026-11-03.csv; Ben Nov 3 20:14 ET "1A"') RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, 1, v.id, v.name, 'Tailor', 'worlds-50-best-bars', 'https://www.the50.com/bars/best-in-the-world/previous-list/2009', 'rename', jsonb_build_object('note', 'Open item 2; live name is a Google place name of a suit shop; 50 Best prints Tailor, New York, 2009 No. 49; closed Nov 2009 (https://punchdrink.com/articles/most-influential-failed-bar-tailor-nyc/); Ben Nov 3 20:14 ET "1A"', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', s.city_slug, 'slug', s.slug)
    FROM venues v JOIN slugs s ON s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical WHERE v.id='ve_d1e61a315d';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name='Tailor' WHERE id='ve_d1e61a315d' AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 1 THEN RAISE EXCEPTION 'renamed %', n; END IF;
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;
  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND city_slug='new-york' AND slug='the-tailory-new-york-custom-suits-nyc-bespoke-tailor' AND venue_id='ve_d1e61a315d' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','new-york','tailor','ve_d1e61a315d',true);
  UPDATE venues SET status='closed' WHERE id='ve_d1e61a315d' AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id='ve_d1e61a315d' AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listing %', n; END IF;
  UPDATE cities SET venues_count=345 WHERE id='ci_d44d6be1a3' AND venues_count=346;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'new-york %', n; END IF;
  UPDATE awards SET source_url='https://www.the50.com/bars/best-in-the-world/previous-list/2009' WHERE id=15336 AND venue_id='ve_d1e61a315d' AND source_id='worlds-50-best-bars' AND year=2009 AND rank=49 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '15336 %', n; END IF;

  -- WRITE: 2A award moves
  UPDATE awards SET venue_id='ve_38916224da', source_url='https://www.the50.com/stories/News/asias-50-best-restaurants-2026-the-51-100-list.html' WHERE id=15683 AND venue_id='ve_d6d7a07cee' AND source_id='asia-50-best-restaurants' AND year=2026 AND rank=65 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '15683 %', n; END IF;
  UPDATE awards SET venue_id='ve_273774c457', source_url='https://www.oadguides.com/lists/north-america/top-restaurants/2025' WHERE id=16923 AND venue_id='ve_965e0e3908' AND source_id='oad' AND year=2025 AND rank=88 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '16923 %', n; END IF;
  UPDATE awards SET venue_id='ve_273774c457', source_url='https://www.oadguides.com/lists/north-america/top-restaurants/2026' WHERE id=16921 AND venue_id='ve_965e0e3908' AND source_id='oad' AND year=2026 AND rank=16 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '16921 %', n; END IF;
  UPDATE awards SET venue_id='ve_842d853e13', source_url='https://www.oadguides.com/lists/north-america/top-restaurants/2025' WHERE id=17153 AND venue_id='ve_1779942f15' AND source_id='oad' AND year=2025 AND rank=509 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '17153 %', n; END IF;
  UPDATE awards SET venue_id='ve_842d853e13', source_url='https://www.oadguides.com/lists/north-america/top-restaurants/2026' WHERE id=17151 AND venue_id='ve_1779942f15' AND source_id='oad' AND year=2026 AND rank=486 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '17151 %', n; END IF;
  UPDATE awards SET venue_id='ve_175f7d63c2', source_url='https://www.oadguides.com/lists/japan/top-restaurants/2025' WHERE id=3422 AND venue_id='ve_b6eb74a0a2' AND source_id='oad' AND year=2025 AND rank=196 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '3422 %', n; END IF;

  -- WRITE: 4A new venues
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('ve_3019edc0d9', 'Wörgötter - Wirtshaus', 'restaurant', 'ci_4421c43eb7', 'active');
  INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_3019edc0d9', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'ligist', 'worgotter-wirtshaus', 've_3019edc0d9', true);
  UPDATE cities SET venues_count=2 WHERE id='ci_4421c43eb7' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'count ligist %', n; END IF;
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      ('ve_3019edc0d9', 'Ligist', 'city_display', 'michelin', 'Michelin card and list: open item 1, split from a merged venue'),
      ('ve_3019edc0d9', 'Austria', 'country', 'michelin', 'Michelin card and list: open item 1, split from a merged venue')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  UPDATE awards SET venue_id='ve_3019edc0d9', source_url='https://guide.michelin.com/at/en/article/michelin-guide-ceremony/43-bib-gourmands-for-austria-guide-michelin' WHERE id=5938 AND venue_id='ve_9acf561dcf' AND source_id='michelin' AND year=2025 AND category='Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '5938 %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('ve_d3fd2ae165', 'Schlosskeller Wirtshaus', 'restaurant', 'ci_f957c08967', 'active');
  INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_d3fd2ae165', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'leibnitz', 'schlosskeller-wirtshaus', 've_d3fd2ae165', true);
  UPDATE cities SET venues_count=2 WHERE id='ci_f957c08967' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'count leibnitz %', n; END IF;
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      ('ve_d3fd2ae165', 'Leibnitz', 'city_display', 'michelin', 'Michelin card and list: open item 1, split from a merged venue'),
      ('ve_d3fd2ae165', 'Austria', 'country', 'michelin', 'Michelin card and list: open item 1, split from a merged venue')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  UPDATE awards SET venue_id='ve_d3fd2ae165', source_url='https://guide.michelin.com/at/en/article/michelin-guide-ceremony/43-bib-gourmands-for-austria-guide-michelin' WHERE id=5898 AND venue_id='ve_fb7dc1ff33' AND source_id='michelin' AND year=2025 AND category='Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '5898 %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('ve_677a6f224a', 'Tai Wah Pork Noodle', 'restaurant', 'ci_d3197fb64e', 'active');
  INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_677a6f224a', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'singapore', 'tai-wah-pork-noodle', 've_677a6f224a', true);
  UPDATE cities SET venues_count=206 WHERE id='ci_d3197fb64e' AND venues_count=205;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'count singapore %', n; END IF;
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      ('ve_677a6f224a', 'Singapore', 'city_display', 'michelin', 'Michelin card and list: open item 1, split from a merged venue'),
      ('ve_677a6f224a', 'Singapore', 'country', 'michelin', 'Michelin card and list: open item 1, split from a merged venue')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  UPDATE awards SET venue_id='ve_677a6f224a', source_url='https://guide.michelin.com/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025' WHERE id=8214 AND venue_id='ve_c2e6c8acfb' AND source_id='michelin' AND year=2025 AND category='Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '8214 %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('ve_754faabbde', 'FAGN-Bistro', 'restaurant', 'ci_9bd6842b49', 'active');
  INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_754faabbde', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'trondheim', 'fagn-bistro', 've_754faabbde', true);
  UPDATE cities SET venues_count=3 WHERE id='ci_9bd6842b49' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'count trondheim %', n; END IF;
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      ('ve_754faabbde', 'Trondheim', 'city_display', 'michelin', 'Michelin card and list: open item 1, split from a merged venue'),
      ('ve_754faabbde', 'Norway', 'country', 'michelin', 'Michelin card and list: open item 1, split from a merged venue')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  UPDATE awards SET venue_id='ve_754faabbde', source_url='https://guide.michelin.com/us/en/trondelag/trondheim/restaurant/fagn-bistro' WHERE id=12737 AND venue_id='ve_7a967f498b' AND source_id='michelin' AND year=2026 AND category='Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '12737 %', n; END IF;
  UPDATE awards SET venue_id='ve_754faabbde', source_url='https://web.archive.org/web/20250813153751id_/https://guide.michelin.com/en/trondelag/trondheim/restaurant/fagn-bistro' WHERE id=12739 AND venue_id='ve_7a967f498b' AND source_id='michelin' AND year=2025 AND category='Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '12739 %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('ve_431ae3ca78', 'Vyn Food & Wine Bar', 'restaurant', 'ci_50fc6ffdaf', 'active');
  INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_431ae3ca78', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'simrishamn', 'vyn-food-wine-bar', 've_431ae3ca78', true);
  UPDATE cities SET venues_count=2 WHERE id='ci_50fc6ffdaf' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'count simrishamn %', n; END IF;
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      ('ve_431ae3ca78', 'Simrishamn', 'city_display', 'michelin', 'Michelin card and list: open item 1, split from a merged venue'),
      ('ve_431ae3ca78', 'Sweden', 'country', 'michelin', 'Michelin card and list: open item 1, split from a merged venue')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  UPDATE awards SET venue_id='ve_431ae3ca78', source_url='https://guide.michelin.com/is/en/skane/simrishamn_2683288/restaurant/vyn-food-wine-bar' WHERE id=3142 AND venue_id='ve_c5e00877c1' AND source_id='michelin' AND year=2026 AND category='Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '3142 %', n; END IF;

  -- WRITE: 5A Bleu Provence
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_9072b5c1e5', 'naples-fl', 'Naples, Florida', 'United States', 'US', 'city', NULL, NULL, NULL, 1);
  UPDATE venues SET city_id='ci_9072b5c1e5' WHERE id='ve_732d5cc78a' AND city_id='ci_d5fc4b0e45';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'bleu city %', n; END IF;
  UPDATE slugs SET city_slug='naples-fl' WHERE property_id='eats' AND city_slug='naples' AND slug='bleu-provence' AND venue_id='ve_732d5cc78a' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'bleu slug %', n; END IF;
  UPDATE cities SET venues_count=8 WHERE id='ci_d5fc4b0e45' AND venues_count=9;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'naples %', n; END IF;
  INSERT INTO redirects (from_path, to_path) VALUES ('/naples/bleu-provence','/naples-fl/bleu-provence');
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) VALUES ('redirects','/naples/bleu-provence','INSERT',NULL,jsonb_build_object('from_path','/naples/bleu-provence','to_path','/naples-fl/bleu-provence'));

  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('worlds-50-best-bars', 'name', 1, 'rename-apply:rename-tailor-new-york-2026-11-03 | gated SQL file docs/fix-placeid-tailor-2026-11-03.sql (Write connector), same writes as the job | https://www.the50.com/bars/best-in-the-world/previous-list/2009 | Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"'),
    ('worlds-50-best-bars', 'award', 1, 'cleanup:fix-placeid-tailor-2026-11-03 | open item 2: award 15336 URL; Tailor closed Nov 2009 (https://punchdrink.com/articles/most-influential-failed-bar-tailor-nyc/) | Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"'),
    ('asia-50-best-restaurants', 'award', 1, 'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: award 15683 Asia 2026 No. 65 moved from Ensue ve_d6d7a07cee to Fumee ve_38916224da | https://www.the50.com/stories/News/asias-50-best-restaurants-2026-the-51-100-list.html | Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"'),
    ('oad', 'award', 5, 'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: awards 16923, 16921, 17153, 17151, 3422 moved to the venue the OAD list names | https://www.oadguides.com/lists/north-america/top-restaurants/2025 | https://www.oadguides.com/lists/north-america/top-restaurants/2026 | https://www.oadguides.com/lists/japan/top-restaurants/2025 | Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"'),
    ('michelin', 'award', 6, 'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: Bib rows 5938, 5898, 8214, 12737, 12739, 3142 moved to 5 new venues under the Michelin card names, each with a URL | Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"'),
    ('michelin', 'city_label', 10, 'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: city labels of the 5 new venues | Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"');

  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11325 OR (SELECT count(*) FROM venues WHERE status='active') <> 11032 OR (SELECT count(*) FROM venues WHERE status='closed') <> 293 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25323 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3029 THEN RAISE EXCEPTION '2025 no URL after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 434 THEN RAISE EXCEPTION '2026 no URL after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13173 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1848 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11325 OR (SELECT count(*) FROM listings) <> 11325 OR (SELECT count(*) FROM city_label_source) <> 24057 THEN RAISE EXCEPTION 'child tables after'; END IF;
  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF x <> 0 THEN RAISE EXCEPTION 'canonical %', x; END IF;
  IF (SELECT count(*) FROM cities) <> 3280 OR (SELECT sum(venues_count) FROM cities) <> 11032 OR (SELECT count(*) FROM redirects) <> 11 OR (SELECT count(*) FROM price) <> 7759 THEN RAISE EXCEPTION 'cities, redirects, price after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  IF (SELECT norm_key FROM venues WHERE id='ve_d1e61a315d') IS DISTINCT FROM 'tailor' THEN RAISE EXCEPTION 'norm key'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 33 OR (SELECT count(*) FROM rename_rows) <> 1398 THEN RAISE EXCEPTION 'rename after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 205 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id, year FROM awards WHERE source_id='michelin' AND category IN ('Bib Gourmand','One Star','Two Stars','Three Stars') GROUP BY 1,2 HAVING count(*)>1) z; IF x <> 0 THEN RAISE EXCEPTION 'Bib and star on one venue %', x; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=13,cities:INSERT=1,cities:UPDATE=7,city_label_source:INSERT=10,listings:INSERT=5,listings:UPDATE=1,redirects:INSERT=1,slugs:INSERT=6,slugs:UPDATE=2,venues:INSERT=5,venues:UPDATE=3' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  SELECT count(*) INTO x FROM audit_log a WHERE a.id>aud_max AND a.table_name='venues' AND a.action='UPDATE' AND a.row_pk='ve_d1e61a315d' AND a.new_row->>'name'='Tailor'; IF x <> 2 THEN RAISE EXCEPTION 'audit tailor %', x; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
