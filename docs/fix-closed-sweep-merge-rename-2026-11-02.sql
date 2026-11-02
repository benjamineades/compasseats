-- fix-closed-sweep-merge-rename-2026-11-02.sql
-- CompassEats, Nov 2 2026. Closed-venue sweep: twin merges and rename read. It holds DELETE. One transaction.
-- Ben: Nov 2 14:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A, 9A". This file runs only after his "go".
-- Population: 6 venues. No write for choices 1A, 4A, 5A, 8A, 9A (handoff recheck list and Swiss batch).
--
-- 2A merge: Hotel Tannenhof ve_aed4b4a9f3 (active) into Gourmetrestaurant Tannenhof ve_bd408ea3c3 (closed, then active and published).
--   Evidence read Nov 2: https://gourmet.hoteltannenhof.net/ (Gourmetrestaurant Tannenhof, Hotel Tannenhof, Nassereinerstrasse 98, season Jul 29 to Oct 31 2026, chef Dennis Ilies);
--   https://guide.michelin.com/en/tirol/sankt-anton-am-arlberg_1045218/restaurant/gourmetrestaurant-tannenhof (Two Stars, 2026 guide, same address; no other restaurant named).
--   Limit: awards 18532 and 18533 have no URL; the link rests on hotel and town. No winter dates on the site; active under the seasonal rule.
--   Moves awards 18532 (OAD 2025 No. 528) and 18533 (La Liste 2026 78.5/100). Slug hotel-tannenhof stays, non-canonical.
--   Deletes labels 18028, 18029 (no publisher, same values as the survivor). Moves label 18030 (neighborhood, "St. Anton em Arlburg"). City count stays 3.
-- 3A merge: Baumaniere 1850 ve_070ced1e07 (closed) into Slalom 1850 ve_5f98076100 (active). Name stays Slalom 1850.
--   Evidence read Nov 2: both Michelin cards give Le Strato, Route de Bellecote, chef Thomas Prod'homme; Slalom card has photos credited Baumaniere 1850;
--   https://guide.michelin.com/en/auvergne-rhone-alpes/courchevel/restaurant/baumaniere-1850 ; https://guide.michelin.com/en/auvergne-rhone-alpes/courchevel/restaurant/slalom-1850 ;
--   https://courchevel.com/en/a/slalom-1850-185100/ uses the same page id as https://courchevel.com/en/a/baumaniere-1850-185100
--   Moves awards 1824 (Michelin 2025 Two Stars) and 1825 (La Liste 2026 76/100). Deletes legacy price ($$$$, no URL; Sep 28 ruling), labels 524, 525 (no publisher, same values).
--   Slug baumaniere-1850 stays, non-canonical. City count stays 7.
-- 6A rename: Katsukani Ryori Akasaka Kitafuku ve_af6c894a24 to Azabu-Juban Kitafuku, native name, active, published. Tokyo 593 to 594.
--   Evidence read Nov 2: https://tabelog.com/tokyo/A1308/A130801/13149065/ (moved to Azabu-Juban Kitafuku); https://www.tablecheck.com/kanikitafuku-azabujuban (booking, 3-6-9 Azabujuban).
-- 7A rename: Wine RVLT ve_7e3068bc36 to Revolution Wine Bistro, active, published. Singapore 204 to 205.
--   Evidence read Nov 2: https://www.r-evolution.sg/ ("Revolution wine bistro is our next chapter", same founders after RVLT closed, 211 Henderson Road);
--   our row name holds the OAD note "Now operating as Revolution wine bistro"; https://www.timeout.com/singapore/restaurants/revolution-wine-bistro
--   The site title and logo write "Revolution". The body writes "Revolution wine bistro". Ben chose Revolution Wine Bistro.
--
-- Expected after: venues 11,294 (active 10,990, closed 304); awards 25,097; slugs 13,019 (canonical 11,294, non-canonical 1,725); price 7,727; listings 11,294;
--   city labels 23,989; cities sum 10,990; closed published 0; active not published 0; rename_batches 27; rename_rows 1,298; ledger 185 rows;
--   audit_log +30 (118,806 rows): awards UPDATE 4, cities UPDATE 2, city_label_source DELETE 4 and UPDATE 1 (hand), listings DELETE 2 and UPDATE 3,
--   price DELETE 1, slugs INSERT 2 and UPDATE 4, venues DELETE 2 and UPDATE 5.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text; bid bigint;
  v_gt constant text := 've_bd408ea3c3';  -- Gourmetrestaurant Tannenhof, survivor
  v_ht constant text := 've_aed4b4a9f3';  -- Hotel Tannenhof, goes
  v_sl constant text := 've_5f98076100';  -- Slalom 1850, survivor
  v_ba constant text := 've_070ced1e07';  -- Baumaniere 1850, goes
  v_ki constant text := 've_af6c894a24';  -- Kitafuku, renamed
  v_rv constant text := 've_7e3068bc36';  -- Wine RVLT, renamed
  c_key constant text := 'rename-closed-sweep-moved-2-2026-11-02';
  c_job constant text := 'merge:fix-closed-sweep-merge-rename-2026-11-02 | Ben Nov 2 14:29 ET 2A, 3A';
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 19:30 UTC)
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10988 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13017 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11296 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1721 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7728 OR (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM city_label_source) <> 23993 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3264 THEN RAISE EXCEPTION 'blurbs redirects cities before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10988 THEN RAISE EXCEPTION 'cities sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 26 OR (SELECT count(*) FROM rename_rows) <> 1296 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key=c_key) THEN RAISE EXCEPTION 'batch key used'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 182 OR led_max <> 234 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118776 OR aud_max <> 124290 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Fingerprints: venues, awards, labels, slugs
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (v_gt,v_ht,v_sl,v_ba,v_ki,v_rv);
  IF s IS DISTINCT FROM '3e1ff22da3ca4c79bf39951a7e96ebd3' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id IN (v_gt,v_ht,v_sl,v_ba,v_ki,v_rv);
  IF s IS DISTINCT FROM 'cc1a99ac92f26fe646e1056c964e1046' THEN RAISE EXCEPTION 'award fingerprint %', s; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||coalesce(l.publisher,''), E'\n' ORDER BY l.id)) INTO s FROM city_label_source l WHERE l.venue_id IN (v_ht,v_ba);
  IF s IS DISTINCT FROM '1a440141ef45ad10afb9c6e7b4789700' THEN RAISE EXCEPTION 'label fingerprint %', s; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.city_slug||'|'||x.slug||'|'||x.is_canonical, E'\n' ORDER BY x.venue_id COLLATE "C", x.slug COLLATE "C")) INTO s FROM slugs x WHERE x.venue_id IN (v_gt,v_ht,v_sl,v_ba,v_ki,v_rv);
  IF s IS DISTINCT FROM 'e22fb79528e161e76c6caf653a6f2aac' THEN RAISE EXCEPTION 'slug fingerprint %', s; END IF;
  -- Child rows on the venues that go: only the rows this file handles
  IF (SELECT count(*) FROM price WHERE venue_id=v_ht) <> 0 THEN RAISE EXCEPTION 'hotel price'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id=v_ba AND source='legacy_guide' AND symbol_raw='$$$$' AND source_url IS NULL) <> 1 OR (SELECT count(*) FROM price WHERE venue_id=v_ba) <> 1 THEN RAISE EXCEPTION 'baumaniere price'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id=v_sl AND source='guide_ingest') <> 1 THEN RAISE EXCEPTION 'slalom price'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id=v_ht AND property_id='eats' AND published) <> 1 OR (SELECT count(*) FROM listings WHERE venue_id=v_ba AND property_id='eats' AND NOT published) <> 1 THEN RAISE EXCEPTION 'listings of the twins'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (v_gt,v_ki,v_rv) AND property_id='eats' AND NOT published) <> 3 THEN RAISE EXCEPTION 'listings to publish'; END IF;
  IF (SELECT count(*) FROM blurbs WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM geo WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM addresses WHERE venue_id IN (v_ht,v_ba))
     + (SELECT count(*) FROM hours WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM photo_refs WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM rename_rows WHERE venue_id IN (v_ht,v_ba,v_ki,v_rv)) <> 0
    THEN RAISE EXCEPTION 'other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(hotel-tannenhof|baumaniere-1850|azabu-juban-kitafuku|revolution-wine-bistro)' OR to_path ~ '(hotel-tannenhof|baumaniere-1850|azabu-juban-kitafuku|revolution-wine-bistro)') THEN RAISE EXCEPTION 'redirect'; END IF;
  -- New slugs and names are free
  IF EXISTS (SELECT 1 FROM slugs WHERE property_id='eats' AND ((city_slug='tokyo' AND slug='azabu-juban-kitafuku') OR (city_slug='singapore' AND slug='revolution-wine-bistro'))) THEN RAISE EXCEPTION 'new slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE (city_id='ci_ef0cc10ff4' AND norm_key=norm_key('Azabu-Juban Kitafuku')) OR (city_id='ci_d3197fb64e' AND norm_key=norm_key('Revolution Wine Bistro'))) THEN RAISE EXCEPTION 'norm_key collision'; END IF;
  -- City counts
  IF (SELECT venues_count FROM cities WHERE id='ci_ef0cc10ff4') <> 593 OR (SELECT venues_count FROM cities WHERE id='ci_d3197fb64e') <> 204 OR (SELECT venues_count FROM cities WHERE id='ci_9ae6a3ac12') <> 3 OR (SELECT venues_count FROM cities WHERE id='ci_8a64416c66') <> 7 THEN RAISE EXCEPTION 'city counts before'; END IF;

  ---------------------------------------------------------------- 1. City labels: hand audit rows, then writes
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'DELETE', to_jsonb(l), NULL FROM city_label_source l WHERE l.id IN (524,525,18028,18029) ORDER BY l.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'label delete audit %', n; END IF;
  DELETE FROM city_label_source WHERE id IN (524,525,18028,18029) AND venue_id IN (v_ba,v_ht);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'labels deleted %', n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'UPDATE', to_jsonb(l), to_jsonb(l) || jsonb_build_object('venue_id', v_gt) FROM city_label_source l WHERE l.id=18030 AND l.venue_id=v_ht;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'label move audit %', n; END IF;
  UPDATE city_label_source SET venue_id=v_gt WHERE id=18030 AND venue_id=v_ht;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'label moved %', n; END IF;

  ---------------------------------------------------------------- 2. Awards move
  UPDATE awards SET venue_id=v_gt WHERE id IN (18532,18533) AND venue_id=v_ht;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'tannenhof awards %', n; END IF;
  UPDATE awards SET venue_id=v_sl WHERE id IN (1824,1825) AND venue_id=v_ba;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'baumaniere awards %', n; END IF;

  ---------------------------------------------------------------- 3. Legacy price
  DELETE FROM price WHERE venue_id=v_ba AND source='legacy_guide' AND symbol_raw='$$$$' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price %', n; END IF;

  ---------------------------------------------------------------- 4. Old slugs stay, non-canonical, on the survivors
  UPDATE slugs SET venue_id=v_gt, is_canonical=false WHERE venue_id=v_ht AND property_id='eats' AND city_slug='sankt-anton-am-arlberg' AND slug='hotel-tannenhof' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'hotel slug %', n; END IF;
  UPDATE slugs SET venue_id=v_sl, is_canonical=false WHERE venue_id=v_ba AND property_id='eats' AND city_slug='courchevel' AND slug='baumaniere-1850' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'baumaniere slug %', n; END IF;

  ---------------------------------------------------------------- 5. Listings and venues of the twins
  DELETE FROM listings WHERE venue_id IN (v_ht,v_ba);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'listings deleted %', n; END IF;
  DELETE FROM venues WHERE id IN (v_ht,v_ba);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues deleted %', n; END IF;

  ---------------------------------------------------------------- 6. Rename batch (same writes as scripts/rename/apply.ts)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES (c_key, 'staged', 'Closed-venue sweep, moved venues (Ben, Nov 2 14:29 ET "6A, 7A"): Akasaka Kitafuku moved and is Azabu-Juban Kitafuku; Wine RVLT closed and its founders run Revolution Wine Bistro. Run as a gated SQL file, not the rename job; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, p.line, p.vid, p.old_name, p.new_name, 'venue', p.url, 'rename',
         jsonb_build_object('note', p.note, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', x.city_slug, 'slug', x.slug)
    FROM (VALUES
      (1, v_ki, 'Katsukani Ryōri Akasaka Kitafuku', 'Azabu-Juban Kitafuku', 'https://www.tablecheck.com/kanikitafuku-azabujuban',
       'Closed-venue sweep, Nov 2 2026; TableCheck booking page name, 3-6-9 Azabujuban; Tabelog https://tabelog.com/tokyo/A1308/A130801/13149065/ says Akasaka Kitafuku moved to Azabu-Juban Kitafuku; OAD 2025 row stays; Ben Nov 2 14:29 ET 6A'),
      (2, v_rv, 'Wine RVLT **Now operating as Revolution wine bistro**', 'Revolution Wine Bistro', 'https://www.r-evolution.sg/',
       'Closed-venue sweep, Nov 2 2026; site title and logo "Revolution", body "Revolution wine bistro is our next chapter", founders of RVLT; OAD row name held the note; Time Out https://www.timeout.com/singapore/restaurants/revolution-wine-bistro; Ben Nov 2 14:29 ET 7A')
    ) AS p(line, vid, old_name, new_name, url, note)
    JOIN venues v ON v.id=p.vid AND v.name=p.old_name
    JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name='Azabu-Juban Kitafuku' WHERE id=v_ki AND name='Katsukani Ryōri Akasaka Kitafuku';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename kitafuku %', n; END IF;
  UPDATE venues SET name='Revolution Wine Bistro' WHERE id=v_rv AND name='Wine RVLT **Now operating as Revolution wine bistro**';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename rvlt %', n; END IF;
  PERFORM set_config('app.allow_rename', 'off', true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;

  ---------------------------------------------------------------- 7. New canonical slugs (slug rule: Ben option A, Oct 8)
  UPDATE slugs SET is_canonical=false WHERE venue_id=v_ki AND property_id='eats' AND city_slug='tokyo' AND slug='katsukani-ryori-akasaka-kitafuku' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'kitafuku old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','tokyo','azabu-juban-kitafuku',v_ki,true);
  UPDATE slugs SET is_canonical=false WHERE venue_id=v_rv AND property_id='eats' AND city_slug='singapore' AND slug='wine-rvlt-now-operating-as-revolution-wine-bistro' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rvlt old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','singapore','revolution-wine-bistro',v_rv,true);

  ---------------------------------------------------------------- 8. Status, native name, published, city counts
  UPDATE venues SET status='active' WHERE id=v_gt AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'tannenhof status %', n; END IF;
  UPDATE venues SET status='active', name_native='麻布十番 きた福' WHERE id=v_ki AND status='closed' AND name_native IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'kitafuku status %', n; END IF;
  UPDATE venues SET status='active' WHERE id=v_rv AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rvlt status %', n; END IF;
  UPDATE listings SET published=true WHERE venue_id IN (v_gt,v_ki,v_rv) AND NOT published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=594 WHERE id='ci_ef0cc10ff4' AND venues_count=593;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'tokyo %', n; END IF;
  UPDATE cities SET venues_count=205 WHERE id='ci_d3197fb64e' AND venues_count=204;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'singapore %', n; END IF;

  ---------------------------------------------------------------- 9. Ledger (rename rows name the venue itself: no publisher, no ledger row, as the job)
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin', 'award', 1, c_job||' | ve_070ced1e07 Baumaniere 1850 = ve_5f98076100 Slalom 1850 (same Michelin address and chef) | award 1824 moved, legacy price and 2 labels deleted, old slug non-canonical, listing and venue deleted'),
    ('la-liste', 'award', 2, c_job||' | awards 18533 (ve_aed4b4a9f3 to ve_bd408ea3c3) and 1825 (ve_070ced1e07 to ve_5f98076100) moved, same restaurants'),
    ('oad', 'award', 1, c_job||' | award 18532 ve_aed4b4a9f3 Hotel Tannenhof to ve_bd408ea3c3 Gourmetrestaurant Tannenhof, same restaurant, survivor set active and published, old slug non-canonical, listing and venue deleted');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'ledger %', n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11294 OR (SELECT count(*) FROM venues WHERE status='active') <> 10990 OR (SELECT count(*) FROM venues WHERE status='closed') <> 304 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM awards WHERE venue_id=v_gt) <> 3 OR (SELECT count(*) FROM awards WHERE venue_id=v_sl) <> 3 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13019 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11294 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1725 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical GROUP BY v.id HAVING count(x.slug) <> 1) THEN RAISE EXCEPTION 'venue without 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11294 OR (SELECT count(*) FROM city_label_source) <> 23989 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10990 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 27 OR (SELECT count(*) FROM rename_rows) <> 1298 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3264 THEN RAISE EXCEPTION 'blurbs redirects cities after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 185 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM slugs WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM city_label_source WHERE venue_id IN (v_ht,v_ba))
     + (SELECT count(*) FROM price WHERE venue_id IN (v_ht,v_ba)) + (SELECT count(*) FROM listings WHERE venue_id IN (v_ht,v_ba)) <> 0 THEN RAISE EXCEPTION 'rows left on the twins'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=4,cities:UPDATE=2,city_label_source:DELETE=4,city_label_source:UPDATE=1,listings:DELETE=2,listings:UPDATE=3,price:DELETE=1,slugs:INSERT=2,slugs:UPDATE=4,venues:DELETE=2,venues:UPDATE=5' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log) <> 118806 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
