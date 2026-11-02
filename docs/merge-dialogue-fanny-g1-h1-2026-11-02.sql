-- merge-dialogue-fanny-g1-h1-2026-11-02.sql
-- CompassEats, Nov 2 2026. Open items 2 and 3 of handoff-open-items-a1-d1-done-2026-11-02.md. It holds DELETE.
-- Ben: Nov 2 09:09 ET "Fanny rey et jonathan wahid is the hotel that L'Auberge is at"; 09:48 ET "G1, H1". This file runs only after his "go".
-- G1: Dialog in the Dark Japan ve_02074ec7f9 is a museum (triage verdict Aug 24: NOT_A_VENUE). Delete the venue, keep its 2 awards:
--   award 21913 Michelin 2025 Bib Gourmand -> DIALOGUE ve_0f8d54f738 (Tokyo). Legacy row and card agree: Tokyo, French, Bib Gourmand, price level 2.
--     Card https://guide.michelin.com/us/en/tokyo-region/tokyo/restaurant/dialogue-1200268 (read Nov 2). No 2025 list found that names it. Row stays with no URL.
--   award 21914 Forbes 2020 Five-Star -> new closed venue Dialogue, Santa Monica. The award came from the Los Angeles legacy row (audit 84590, 84602).
--     Forbes names Dialogue, Santa Monica, Five-Star: https://stories.forbestravelguide.com/forbes-travel-guide-reveals-its-2019-star-award-winners
--     Closed Nov 7, 2020: https://en.wikipedia.org/wiki/Dialogue_(restaurant). No 2020 list found that names it. Row stays with no URL.
--   Price (legacy $$) and 2 Michelin labels of the museum venue are deleted: DIALOGUE has the card price and the same labels. Old URL 404, no redirect.
-- H1: Fanny rey et jonathan wahid ve_77657c7bbf = L'Auberge de Saint-Rémy ve_4e77c0295c (Ben; same chefs in the card slug). Merge:
--   award 21248 Gault-Millau 2021 -> L'Auberge. 2 slugs -> L'Auberge, non-canonical (old URLs keep working). 3 gault-millau labels -> L'Auberge (Hangzhou, La Table precedent).
--   Listing and venue deleted.
-- Expected after: venues 11,296 (active 10,930, closed 366); awards 25,081; slugs 13,008 (canonical 11,296, non-canonical 1,712);
--   listings 11,296; blurbs 142; price 7,729; city_label_source 23,993; cities 3,263, venues_count sum 10,930 (Tokyo 591, Saint-Rémy-de-Provence 2, Santa Monica 10);
--   rename tables unchanged; ledger 175 rows, last id 227; audit_log +23.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text;
  v_dark constant text := 've_02074ec7f9';
  v_dia  constant text := 've_0f8d54f738';
  v_fan  constant text := 've_77657c7bbf';
  v_aub  constant text := 've_4e77c0295c';
  v_new  constant text := 've_'||left(md5('santa-monica:dialogue'),10);
  c_tok  constant text := 'ci_ef0cc10ff4';
  c_sm   constant text := 'ci_fb02de8541';
  c_prov constant text := 'ci_931967f233';
  c_note constant text := 'forbes-2020-dialogue-split-2026-11-02';
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 14:48 UTC)
  IF (SELECT count(*) FROM venues) <> 11297 OR (SELECT count(*) FROM venues WHERE status='active') <> 10932 OR (SELECT count(*) FROM venues WHERE status='closed') <> 365 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25081 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13008 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1711 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11297 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'listings/blurbs/price before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23993 OR (SELECT count(*) FROM city_aliases) <> 266 OR (SELECT count(*) FROM redirects) <> 9 THEN RAISE EXCEPTION 'labels/aliases/redirects before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3263 OR (SELECT sum(venues_count) FROM cities) <> 10932 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 24 OR (SELECT count(*) FROM rename_rows) <> 1285 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 172 OR led_max <> 224 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118130 OR aud_max <> 123644 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;

  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (v_dark,v_dia,v_fan,v_aub);
  IF s IS DISTINCT FROM 'c55707611d4c4cf4aac8c619b98be615' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;

  -- awards
  SELECT string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,'-'), ';' ORDER BY a.id) INTO s FROM awards a WHERE a.venue_id IN (v_dark,v_fan);
  IF s IS DISTINCT FROM '21248|ve_77657c7bbf|gault-millau|2021|Grand de Demain|-;21913|ve_02074ec7f9|michelin|2025|Bib Gourmand|-;21914|ve_02074ec7f9|forbes-travel-guide|2020|Five-Star|-' THEN RAISE EXCEPTION 'award rows %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id=v_dia AND source_id='michelin' AND year=2025) THEN RAISE EXCEPTION 'DIALOGUE has a 2025 row'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id=v_aub AND source_id='gault-millau') THEN RAISE EXCEPTION 'LAuberge has a Gault-Millau row'; END IF;
  -- labels
  SELECT string_agg(l.id||'|'||l.venue_id||'|'||l.label||'|'||l.from_column||'|'||coalesce(l.publisher,'-'), ';' ORDER BY l.id) INTO s FROM city_label_source l WHERE l.venue_id IN (v_dark,v_fan);
  IF s IS DISTINCT FROM '13526|ve_02074ec7f9|Tokyo|city_display|michelin;13527|ve_02074ec7f9|Japan|country|michelin;21670|ve_77657c7bbf|Saint-Rémy|city_display|gault-millau;21671|ve_77657c7bbf|France|country|gault-millau;21672|ve_77657c7bbf|Saint-Rémy-de-Provence|neighborhood|gault-millau' THEN RAISE EXCEPTION 'label rows %', s; END IF;
  -- slugs
  SELECT string_agg(sl.venue_id||'|'||sl.city_slug||'/'||sl.slug||'|'||sl.is_canonical, ';' ORDER BY sl.venue_id COLLATE "C", sl.city_slug COLLATE "C") INTO s FROM slugs sl WHERE sl.venue_id IN (v_dark,v_fan);
  IF s IS DISTINCT FROM 've_02074ec7f9|tokyo/dialog-in-the-dark-japan|true;ve_77657c7bbf|saint-remy/fanny-rey-et-jonathan-wahid|false;ve_77657c7bbf|saint-remy-de-provence/fanny-rey-et-jonathan-wahid|true' THEN RAISE EXCEPTION 'slug rows %', s; END IF;
  -- other child rows
  IF (SELECT count(*) FROM price WHERE venue_id=v_dark AND source::text='legacy_guide' AND symbol_raw='$$') <> 1 OR (SELECT count(*) FROM price WHERE venue_id=v_fan) <> 0 THEN RAISE EXCEPTION 'price rows'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id=v_dia AND source::text='guide_ingest') <> 1 THEN RAISE EXCEPTION 'DIALOGUE price'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (v_dark,v_fan)) <> 2 THEN RAISE EXCEPTION 'listings'; END IF;
  IF (SELECT count(*) FROM blurbs WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM addresses WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM geo WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM hours WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM photo_refs WHERE venue_id IN (v_dark,v_fan)) <> 0 THEN RAISE EXCEPTION 'other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id IN (v_dark,v_fan)) THEN RAISE EXCEPTION 'rename row'; END IF;
  IF EXISTS (SELECT 1 FROM ingest_rows WHERE raw::text ~ '(ve_02074ec7f9|ve_77657c7bbf)') THEN RAISE EXCEPTION 'ingest row'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(dialog-in-the-dark-japan|fanny-rey-et-jonathan-wahid|santa-monica/dialogue)' OR to_path ~ '(dialog-in-the-dark-japan|fanny-rey-et-jonathan-wahid|santa-monica/dialogue)') THEN RAISE EXCEPTION 'redirect on a path'; END IF;
  -- new venue
  IF EXISTS (SELECT 1 FROM venues WHERE id=v_new OR (city_id=c_sm AND norm_key='dialogue')) THEN RAISE EXCEPTION 'new venue clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='santa-monica' AND slug='dialogue') THEN RAISE EXCEPTION 'new slug in use'; END IF;
  -- city counts
  IF (SELECT venues_count FROM cities WHERE id=c_tok AND slug='tokyo') <> 592 OR (SELECT venues_count FROM cities WHERE id=c_prov AND slug='saint-remy-de-provence') <> 3 OR (SELECT venues_count FROM cities WHERE id=c_sm AND slug='santa-monica') <> 10 THEN RAISE EXCEPTION 'city counts before'; END IF;

  ---------------------------------------------------------------- WRITE 1 (G1): new closed venue Dialogue, Santa Monica
  INSERT INTO venues (id, name, category, city_id, status) VALUES (v_new, 'Dialogue', 'restaurant', c_sm, 'closed');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue insert %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) VALUES (v_new, 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','santa-monica','dialogue',v_new,true);
  INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
    (v_new,'Santa Monica','city_display','forbes-travel-guide',c_note),
    (v_new,'United States','country','forbes-travel-guide',c_note);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'new labels %', n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'INSERT', NULL, to_jsonb(l) FROM city_label_source l WHERE l.venue_id=v_new ORDER BY l.id;

  ---------------------------------------------------------------- WRITE 2 (G1): move 2 awards
  UPDATE awards SET venue_id=v_dia WHERE id=21913 AND venue_id=v_dark AND source_id='michelin' AND year=2025 AND category='Bib Gourmand';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 21913 %', n; END IF;
  UPDATE awards SET venue_id=v_new WHERE id=21914 AND venue_id=v_dark AND source_id='forbes-travel-guide' AND year=2020 AND category='Five-Star';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 21914 %', n; END IF;

  ---------------------------------------------------------------- WRITE 3 (G1): delete the museum venue
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'DELETE', to_jsonb(l), NULL FROM city_label_source l WHERE l.id IN (13526,13527) ORDER BY l.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'hand audit labels %', n; END IF;
  DELETE FROM city_label_source WHERE id IN (13526,13527) AND venue_id=v_dark;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels deleted %', n; END IF;
  DELETE FROM price WHERE venue_id=v_dark;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price deleted %', n; END IF;
  DELETE FROM slugs WHERE venue_id=v_dark;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug deleted %', n; END IF;
  DELETE FROM listings WHERE venue_id=v_dark;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listing deleted %', n; END IF;
  DELETE FROM venues WHERE id=v_dark;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue deleted %', n; END IF;
  UPDATE cities SET venues_count=591 WHERE id=c_tok AND venues_count=592;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Tokyo %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 1, 'merge:merge-dialogue-fanny-g1-h1-2026-11-02 | Dialog in the Dark Japan ve_02074ec7f9 is a museum (triage Aug 24), venue deleted | award 21913 (2025 Bib Gourmand, no URL) -> DIALOGUE ve_0f8d54f738 (legacy row and card agree: Tokyo, French, Bib, price level 2; no 2025 list found) | Ben Nov 2 09:48 ET "G1, H1"');
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('forbes-travel-guide', 'award', 1, 'merge:merge-dialogue-fanny-g1-h1-2026-11-02 | award 21914 (2020 Five-Star, no URL) ve_02074ec7f9 -> new closed venue Dialogue, Santa Monica '||v_new||' | came from the Los Angeles legacy row (audit 84590, 84602) | Forbes 2019 list names Dialogue, Santa Monica, Five-Star; no 2020 list found; closed Nov 7, 2020 | Ben Nov 2 09:48 ET "G1, H1"');

  ---------------------------------------------------------------- WRITE 4 (H1): merge Fanny rey et jonathan wahid into L'Auberge
  UPDATE awards SET venue_id=v_aub WHERE id=21248 AND venue_id=v_fan AND source_id='gault-millau' AND year=2021;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 21248 %', n; END IF;
  UPDATE slugs SET venue_id=v_aub, is_canonical=false WHERE property_id='eats' AND venue_id=v_fan AND slug='fanny-rey-et-jonathan-wahid' AND city_slug IN ('saint-remy','saint-remy-de-provence');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'slugs moved %', n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'UPDATE', to_jsonb(l), to_jsonb(l) || jsonb_build_object('venue_id', v_aub) FROM city_label_source l WHERE l.venue_id=v_fan ORDER BY l.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'hand audit moved labels %', n; END IF;
  UPDATE city_label_source SET venue_id=v_aub WHERE venue_id=v_fan;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'labels moved %', n; END IF;
  DELETE FROM listings WHERE venue_id=v_fan;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listing deleted %', n; END IF;
  DELETE FROM venues WHERE id=v_fan;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue deleted %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id=c_prov AND venues_count=3;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Provence count %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('gault-millau', 'award', 1, 'merge:merge-dialogue-fanny-g1-h1-2026-11-02 | ve_77657c7bbf "Fanny rey et jonathan wahid" = ve_4e77c0295c L''Auberge de Saint-Rémy (Ben: the hotel where L''Auberge is; same chefs in the card slug) | award 21248 (2021 Grand de Demain) -> ve_4e77c0295c | 2 old slugs non-canonical; 3 gault-millau labels moved; listing and venue deleted | Ben Nov 2 09:48 ET "G1, H1"');

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10930 OR (SELECT count(*) FROM venues WHERE status='closed') <> 366 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25081 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13008 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1712 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11296 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7729 THEN RAISE EXCEPTION 'listings/blurbs/price after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23993 OR (SELECT count(*) FROM city_aliases) <> 266 OR (SELECT count(*) FROM redirects) <> 9 THEN RAISE EXCEPTION 'labels/aliases/redirects after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3263 OR (SELECT sum(venues_count) FROM cities) <> 10930 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 24 OR (SELECT count(*) FROM rename_rows) <> 1285 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 175 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical AND sl.property_id='eats' GROUP BY v.id HAVING count(sl.slug) <> 1) THEN RAISE EXCEPTION 'canonical slug count'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM slugs WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM city_label_source WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM listings WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM price WHERE venue_id IN (v_dark,v_fan)) + (SELECT count(*) FROM venues WHERE id IN (v_dark,v_fan)) <> 0 THEN RAISE EXCEPTION 'rows left on deleted venues'; END IF;
  SELECT string_agg(a.id||' '||a.source_id||' '||a.year, ', ' ORDER BY a.id) INTO s FROM awards a WHERE a.venue_id=v_dia;
  IF s IS DISTINCT FROM '21913 michelin 2025, 24688 michelin 2026' THEN RAISE EXCEPTION 'DIALOGUE awards %', s; END IF;
  SELECT string_agg(a.id||' '||a.source_id||' '||a.year, ', ' ORDER BY a.id) INTO s FROM awards a WHERE a.venue_id=v_new;
  IF s IS DISTINCT FROM '21914 forbes-travel-guide 2020' THEN RAISE EXCEPTION 'new venue awards %', s; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id=v_aub) <> 6 THEN RAISE EXCEPTION 'LAuberge awards'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id=v_aub AND is_canonical AND city_slug='saint-remy-de-provence' AND slug='l-auberge-de-saint-remy') <> 1 OR (SELECT count(*) FROM slugs WHERE venue_id=v_aub) <> 4 THEN RAISE EXCEPTION 'LAuberge slugs'; END IF;
  IF (SELECT count(*) FROM city_label_source WHERE venue_id=v_aub) <> 6 THEN RAISE EXCEPTION 'LAuberge labels'; END IF;
  IF (SELECT count(*) FROM venues WHERE id=v_new AND status='closed' AND name='Dialogue' AND city_id=c_sm) <> 1 THEN RAISE EXCEPTION 'new venue row'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=3,cities:UPDATE=2,city_label_source:DELETE=2,city_label_source:INSERT=2,city_label_source:UPDATE=3,listings:DELETE=2,listings:INSERT=1,price:DELETE=1,slugs:DELETE=1,slugs:INSERT=1,slugs:UPDATE=2,venues:DELETE=2,venues:INSERT=1' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
