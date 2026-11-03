-- cleanup-michelin-2026-switzerland-list-2026-11-03.sql
-- CompassEats, Nov 3 2026. Swiss cleanup list (decision 2). It holds DELETE. One transaction. Run after the price file and the backfill file.
-- Ben: Nov 2 18:09 ET "2A"; Nov 3 16:29 ET "1,2,3".
-- 1. Grand Hotel Les Trois Rois ve_d159e1bbd3 into Cheval Blanc by Peter Knogl ve_46e15d96d7 (the hotel's restaurant, Blumenrain 8, Basel).
--    Delete award 111 (Michelin 2025 Three Stars, copy: the survivor holds row 20659; the Nov 2 morning list has 4 Three Stars cards, the database had 5 rows).
--    Move the blurb (the text describes Cheval Blanc; status needs_rewrite; the survivor has none). Delete legacy price and 2 labels (same values as the survivor).
-- 2. Carlton Hotel St. Moritz LHW ve_7c75b49d07 into Da Vittorio - St. Moritz ve_dcfa59471a (restaurant of the Carlton, Via Johannes Badrutt 11).
--    Move award 2940 (Michelin 2025 Two Stars; capture of the Da Vittorio card names the 2025 guide, Two Stars; the survivor has no 2025 row). Delete legacy price. Move 2 labels.
-- 3. Restaurant Magdalena (Lucerne) ve_7d4e3b91ec into Magdalena ve_1489b03a45 (Rickenbach).
--    Move award 18514 (OAD 2025 No. 498). https://www.oadguides.com/restaurant/magdalena-switzerland: Magdalena, Rickenbachstrasse 127, 6432 Rickenbach, OAD city label Lucerne; no second Magdalena.
--    Limit: the OAD page gives no year and does not print No. 498. Move 2 labels.
-- Old slugs stay, non-canonical, on the survivors. Old URLs keep working. Listings and venues of the 3 go. City counts: Basel 8 to 7, Saint Moritz 5 to 4, Lucerne 8 to 7.
-- Expected after: venues 11,320 (active 11,028, closed 292); awards 25,324; Michelin 2025 4,997; slugs 13,144 (canonical 11,320, non-canonical 1,824); price 7,759 (legacy 2,180);
--   listings 11,320; labels 24,047; blurbs 142; cities sum 11,028; ledger 194 rows; audit +24: awards DELETE 1 UPDATE 2, blurbs UPDATE 1, cities UPDATE 3,
--   city_label_source DELETE 2 UPDATE 4 (hand), listings DELETE 3, price DELETE 2, slugs UPDATE 3, venues DELETE 3.
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text;
  v1 constant text := 've_d159e1bbd3'; k1 constant text := 've_46e15d96d7';
  v2 constant text := 've_7c75b49d07'; k2 constant text := 've_dcfa59471a';
  v3 constant text := 've_7d4e3b91ec'; k3 constant text := 've_1489b03a45';
  c_job constant text := 'merge:cleanup-michelin-2026-switzerland-list-2026-11-03 | Swiss decision 2, Ben Nov 2 18:09 ET 2A, Nov 3 16:29 ET';
BEGIN
  ---------------- PRE gates
  IF (SELECT count(*) FROM venues) <> 11323 OR (SELECT count(*) FROM venues WHERE status='active') <> 11031 OR (SELECT count(*) FROM venues WHERE status='closed') <> 292 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25325 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4998 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13144 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11323 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1821 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7761 OR (SELECT count(*) FROM price WHERE source::text='legacy_guide') <> 2182 OR (SELECT count(*) FROM listings) <> 11323 OR (SELECT count(*) FROM city_label_source) <> 24049 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3279 OR (SELECT sum(venues_count) FROM cities) <> 11031 THEN RAISE EXCEPTION 'blurbs redirects cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 192 OR led_max <> 246 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 119740 OR aud_max <> 125569 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(x.id||'|'||x.name||'|'||x.status||'|'||x.city_id||'|'||coalesce(x.norm_key,''), E'\n' ORDER BY x.id COLLATE "C")) INTO s FROM venues x WHERE x.id IN (v1,k1,v2,k2,v3,k3);
  IF s IS DISTINCT FROM 'e13fd30d029287f9aabd521f7f61bbb0' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id IN (v1,k1,v2,k2,v3,k3);
  IF s IS DISTINCT FROM '3694f89760c5c0a4caa544595c89f66f' THEN RAISE EXCEPTION 'award fingerprint %', s; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||coalesce(l.publisher,''), E'\n' ORDER BY l.id)) INTO s FROM city_label_source l WHERE l.venue_id IN (v1,v2,v3);
  IF s IS DISTINCT FROM '13daece0dd3626784a90e91295aefe23' THEN RAISE EXCEPTION 'label fingerprint %', s; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.city_slug||'|'||x.slug||'|'||x.is_canonical, E'\n' ORDER BY x.venue_id COLLATE "C", x.slug COLLATE "C")) INTO s FROM slugs x WHERE x.venue_id IN (v1,k1,v2,k2,v3,k3);
  IF s IS DISTINCT FROM '03e45bb6ca69332506e94d8f9e73beef' THEN RAISE EXCEPTION 'slug fingerprint %', s; END IF;
  IF (SELECT md5(short||long) FROM blurbs WHERE venue_id=v1) IS DISTINCT FROM '1437c2af82169aebdf2c8caa4833e072' THEN RAISE EXCEPTION 'blurb text'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id=k1) THEN RAISE EXCEPTION 'survivor blurb'; END IF;
  IF (SELECT count(*) FROM awards WHERE id=20659 AND venue_id=k1 AND source_id='michelin' AND year=2025 AND category='Three Stars') <> 1 THEN RAISE EXCEPTION 'row 20659'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id IN (v1,v2) AND source::text='legacy_guide' AND symbol_raw='$$$$' AND source_url IS NULL) <> 2 OR (SELECT count(*) FROM price WHERE venue_id=v3) <> 0 THEN RAISE EXCEPTION 'price on the 3'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id IN (k1,k2,k3) AND source::text='guide_ingest' AND currency='CHF') <> 3 THEN RAISE EXCEPTION 'survivor price (run the price file first)'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (v1,v2,v3) AND property_id='eats' AND published) <> 3 OR (SELECT count(*) FROM listings WHERE venue_id IN (v1,v2,v3)) <> 3 THEN RAISE EXCEPTION 'listings on the 3'; END IF;
  IF (SELECT count(*) FROM geo WHERE venue_id IN (v1,v2,v3)) + (SELECT count(*) FROM addresses WHERE venue_id IN (v1,v2,v3)) + (SELECT count(*) FROM hours WHERE venue_id IN (v1,v2,v3))
     + (SELECT count(*) FROM photo_refs WHERE venue_id IN (v1,v2,v3)) + (SELECT count(*) FROM rename_rows WHERE venue_id IN (v1,v2,v3)) <> 0 THEN RAISE EXCEPTION 'other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(grand-hotel-les-trois-rois|carlton-hotel-st-moritz-lhw|lucerne/restaurant-magdalena)' OR to_path ~ '(grand-hotel-les-trois-rois|carlton-hotel-st-moritz-lhw|lucerne/restaurant-magdalena)') THEN RAISE EXCEPTION 'redirects'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_7aaf6c53e9') <> 8 OR (SELECT venues_count FROM cities WHERE id='ci_e6464db2fa') <> 5 OR (SELECT venues_count FROM cities WHERE id='ci_c58e546c81') <> 8 THEN RAISE EXCEPTION 'city counts'; END IF;
  ---------------- 1. Labels: hand audit rows, then writes
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'DELETE', to_jsonb(l), NULL FROM city_label_source l WHERE l.id IN (29,30) AND l.venue_id=v1 ORDER BY l.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'label delete audit %', n; END IF;
  DELETE FROM city_label_source WHERE id IN (29,30) AND venue_id=v1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels deleted %', n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'UPDATE', to_jsonb(l), to_jsonb(l) || jsonb_build_object('venue_id', CASE l.venue_id WHEN v2 THEN k2 ELSE k3 END)
    FROM city_label_source l WHERE l.id IN (1064,1065,17999,18000) AND l.venue_id IN (v2,v3) ORDER BY l.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'label move audit %', n; END IF;
  UPDATE city_label_source SET venue_id=k2 WHERE id IN (1064,1065) AND venue_id=v2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'carlton labels %', n; END IF;
  UPDATE city_label_source SET venue_id=k3 WHERE id IN (17999,18000) AND venue_id=v3;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'magdalena labels %', n; END IF;
  ---------------- 2. Awards
  DELETE FROM awards WHERE id=111 AND venue_id=v1 AND source_id='michelin' AND year=2025 AND category='Three Stars' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'row 111 %', n; END IF;
  UPDATE awards SET venue_id=k2 WHERE id=2940 AND venue_id=v2 AND source_id='michelin' AND year=2025 AND category='Two Stars';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'row 2940 %', n; END IF;
  UPDATE awards SET venue_id=k3 WHERE id=18514 AND venue_id=v3 AND source_id='oad' AND year=2025;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'row 18514 %', n; END IF;
  ---------------- 3. Blurb, price
  UPDATE blurbs SET venue_id=k1 WHERE venue_id=v1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'blurb %', n; END IF;
  DELETE FROM price WHERE venue_id IN (v1,v2) AND source::text='legacy_guide' AND symbol_raw='$$$$' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'price %', n; END IF;
  ---------------- 4. Old slugs stay, non-canonical, on the survivors
  UPDATE slugs SET venue_id=k1, is_canonical=false WHERE venue_id=v1 AND property_id='eats' AND city_slug='basel' AND slug='grand-hotel-les-trois-rois' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug 1 %', n; END IF;
  UPDATE slugs SET venue_id=k2, is_canonical=false WHERE venue_id=v2 AND property_id='eats' AND city_slug='saint-moritz' AND slug='carlton-hotel-st-moritz-lhw' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug 2 %', n; END IF;
  UPDATE slugs SET venue_id=k3, is_canonical=false WHERE venue_id=v3 AND property_id='eats' AND city_slug='lucerne' AND slug='restaurant-magdalena' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug 3 %', n; END IF;
  ---------------- 5. Listings, venues, city counts
  DELETE FROM listings WHERE venue_id IN (v1,v2,v3);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'listings %', n; END IF;
  DELETE FROM venues WHERE id IN (v1,v2,v3);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'venues %', n; END IF;
  UPDATE cities SET venues_count=7 WHERE id='ci_7aaf6c53e9' AND venues_count=8;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'basel %', n; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_e6464db2fa' AND venues_count=5;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'saint moritz %', n; END IF;
  UPDATE cities SET venues_count=7 WHERE id='ci_c58e546c81' AND venues_count=8;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'lucerne %', n; END IF;
  ---------------- 6. Ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',2, c_job||' | ve_d159e1bbd3 Grand Hotel Les Trois Rois = ve_46e15d96d7 Cheval Blanc by Peter Knogl: award 111 deleted (copy of 20659), blurb moved, legacy price and 2 labels deleted | ve_7c75b49d07 Carlton Hotel St. Moritz LHW = ve_dcfa59471a Da Vittorio - St. Moritz: award 2940 moved, legacy price deleted, 2 labels moved | old slugs non-canonical'),
    ('oad','award',1, c_job||' | ve_7d4e3b91ec Restaurant Magdalena (Lucerne) = ve_1489b03a45 Magdalena (Rickenbach): award 18514 moved, 2 labels moved, old slug non-canonical | https://www.oadguides.com/restaurant/magdalena-switzerland');
  ---------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM venues WHERE status='active') <> 11028 OR (SELECT count(*) FROM venues WHERE status='closed') <> 292 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25324 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4997 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id IN (v1,v2,v3)) <> 0 THEN RAISE EXCEPTION 'awards left'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13144 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11320 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1824 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues x LEFT JOIN slugs y ON y.venue_id=x.id AND y.property_id='eats' AND y.is_canonical GROUP BY x.id HAVING count(y.slug) <> 1) THEN RAISE EXCEPTION 'canonical slug check'; END IF;
  IF (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM price WHERE source::text='legacy_guide') <> 2180 OR (SELECT count(*) FROM listings) <> 11320 OR (SELECT count(*) FROM city_label_source) <> 24047 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11028 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues x ON x.id=l.venue_id WHERE x.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues x ON x.id=l.venue_id WHERE x.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 194 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||':'||cnt, ',' ORDER BY table_name, action) INTO s FROM (SELECT table_name, action, count(*) cnt FROM audit_log WHERE id>aud_max GROUP BY 1,2) q;
  IF s IS DISTINCT FROM 'awards:DELETE:1,awards:UPDATE:2,blurbs:UPDATE:1,cities:UPDATE:3,city_label_source:DELETE:2,city_label_source:UPDATE:4,listings:DELETE:3,price:DELETE:2,slugs:UPDATE:3,venues:DELETE:3' THEN RAISE EXCEPTION 'audit by table: %', s; END IF;
END
$fix$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
