-- fix-closed-sweep-goh-barbary-union-2026-11-02.sql
-- CompassEats, Nov 2 2026. Closed-venue sweep item 6, follow-up. It holds DELETE. One transaction.
-- Ben: Nov 2 15:29 ET "1A, 2A, 3A". This file runs only after his "go".
-- Population: 4 venues.
--
-- 1A status and rename: D.F. Cantina by Barbary Coast ve_e5e9d66f60 to Barbary Coast, back to closed, not published (set active by fix-status-sweep-7-active-2026-11-02.sql, audit 124,321-124,341). Singapore 206 to 205. Recheck.
--   Evidence read Nov 2: https://www.barbarycoastsg.com/deadfallcantina redirects to an unrelated lottery page, own site gone;
--   https://88bamboo.co/blogs/escapades/deadfall-revamps-with-an-agave-centric-twist (Aug 16 2024) gives Barbary Coast as No. 29 on Asia's 50 Best Bars 2021, the row 19516 on this venue;
--   https://www.timeout.sg/bars/barbary-coast (updated Aug 6 2026) and https://www.timeout.sg/bars/deadfall-cantina (updated Aug 8 2026) list two separate bars at 16 North Canal Rd. Listing only, no dated source shows either bar trading.
--   Limit: row 19518 (Top 500 Bars 2024 No. 363) and row 19517 (Asia 2022 No. 95) have no URL; the bar they name is not proved. They stay.
-- 2A merge: La Maison de la Nature Goh ve_61f0698a02 (closed) into Goh ve_ce25175db1 (active). Name stays Goh.
--   Evidence read Nov 2: https://hitosara.com/0031593980/ (closed Oct 2022 for relocation; Goh on the 3rd floor of the 010 Building, chef Fukuyama);
--   https://www.tatlerasia.com/dining/food/takeshi-fukuyama-goh-gohgan-chef-interview (Sep 7 2023, same chef, "It's a new Goh");
--   https://www.the50.com/discovery/Establishments/Japan/Fukuoka/Goh.html (shuttered Oct 2022, reopened 2023 with Goh, "a new concept").
--   Limit: 50 Best calls it a new concept. Ben chose the merge.
--   Moves awards 20322, 20323, 20324 (Asia's 50 Best Restaurants 2019, 2021, 2022). Moves labels 20429, 20430 (publisher asia-50-best-restaurants, values kept). No price. Slug la-maison-de-la-nature-goh stays, non-canonical. City count stays 18.
-- 3A rename: The Union Trading Company Bar ve_c71805d8dd to Union Trading Company. Active, published. Shanghai stays 112.
--   Evidence read Nov 2: https://www.the50.com/discovery/Establishments/China/Shanghai/Union-Trading-Company.html (Union Trading Company, 306 Hengshan Rd); https://www.thespiritsbusiness.com/?p=915429 (Jun 30 2026, same name).
--
-- Expected after: venues 11,293 (active 10,996, closed 297); awards 25,097; slugs 13,021 (canonical 11,293, non-canonical 1,728); price 7,727; listings 11,293;
--   city labels 23,989; cities sum 10,996; closed published 0; active not published 0; rename_batches 28; rename_rows 1,300; ledger 186 rows;
--   audit_log +17 (118,844 rows): awards UPDATE 3, cities UPDATE 1, city_label_source UPDATE 2 (hand), listings DELETE 1 and UPDATE 1, slugs INSERT 2 and UPDATE 3, venues DELETE 1 and UPDATE 3.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text; bid bigint;
  v_go constant text := 've_ce25175db1';  -- Goh, survivor
  v_lm constant text := 've_61f0698a02';  -- La Maison de la Nature Goh, goes
  v_df constant text := 've_e5e9d66f60';  -- D.F. Cantina by Barbary Coast, renamed, closed
  v_un constant text := 've_c71805d8dd';  -- The Union Trading Company Bar, renamed
  c_key constant text := 'rename-closed-sweep-item6-2-2026-11-02';
  c_job constant text := 'merge:fix-closed-sweep-goh-barbary-union-2026-11-02 | Ben Nov 2 15:29 ET 2A';
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 20:29 UTC)
  IF (SELECT count(*) FROM venues) <> 11294 OR (SELECT count(*) FROM venues WHERE status='active') <> 10997 OR (SELECT count(*) FROM venues WHERE status='closed') <> 297 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13019 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11294 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1725 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11294 OR (SELECT count(*) FROM city_label_source) <> 23989 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3264 THEN RAISE EXCEPTION 'blurbs redirects cities before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10997 THEN RAISE EXCEPTION 'cities sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 27 OR (SELECT count(*) FROM rename_rows) <> 1298 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key=c_key) THEN RAISE EXCEPTION 'batch key used'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 185 OR led_max <> 237 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118827 OR aud_max <> 124341 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Fingerprints: venues, awards, labels, slugs
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (v_go,v_lm,v_df,v_un);
  IF s IS DISTINCT FROM '1e605fe3626f0c26b45ddc070ad164de' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id IN (v_go,v_lm,v_df,v_un);
  IF s IS DISTINCT FROM 'a9880ea8ee92767652039ee353a6f58a' THEN RAISE EXCEPTION 'award fingerprint %', s; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||coalesce(l.publisher,''), E'\n' ORDER BY l.id)) INTO s FROM city_label_source l WHERE l.venue_id=v_lm;
  IF s IS DISTINCT FROM 'e9301d7d8b611234b86d62821711b0f3' THEN RAISE EXCEPTION 'label fingerprint %', s; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.city_slug||'|'||x.slug||'|'||x.is_canonical, E'\n' ORDER BY x.venue_id COLLATE "C", x.slug COLLATE "C")) INTO s FROM slugs x WHERE x.venue_id IN (v_go,v_lm,v_df,v_un);
  IF s IS DISTINCT FROM 'b93a68458b65dad0d2e422b3219dda21' THEN RAISE EXCEPTION 'slug fingerprint %', s; END IF;
  -- Child rows on the venue that goes: only the rows this file handles
  IF (SELECT count(*) FROM listings WHERE venue_id=v_lm AND property_id='eats' AND NOT published) <> 1 THEN RAISE EXCEPTION 'listing of la maison'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id=v_df AND property_id='eats' AND published) <> 1 THEN RAISE EXCEPTION 'listing of df'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id=v_lm) + (SELECT count(*) FROM blurbs WHERE venue_id=v_lm) + (SELECT count(*) FROM geo WHERE venue_id=v_lm) + (SELECT count(*) FROM addresses WHERE venue_id=v_lm)
     + (SELECT count(*) FROM hours WHERE venue_id=v_lm) + (SELECT count(*) FROM photo_refs WHERE venue_id=v_lm) + (SELECT count(*) FROM rename_rows WHERE venue_id IN (v_lm,v_df,v_un)) <> 0
    THEN RAISE EXCEPTION 'other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(la-maison-de-la-nature-goh|d-f-cantina|barbary-coast|union-trading)' OR to_path ~ '(la-maison-de-la-nature-goh|d-f-cantina|barbary-coast|union-trading)') THEN RAISE EXCEPTION 'redirect'; END IF;
  -- New slugs and names are free
  IF EXISTS (SELECT 1 FROM slugs WHERE property_id='eats' AND ((city_slug='singapore' AND slug='barbary-coast') OR (city_slug='shanghai' AND slug='union-trading-company'))) THEN RAISE EXCEPTION 'new slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE (city_id='ci_d3197fb64e' AND norm_key=norm_key('Barbary Coast')) OR (city_id='ci_22638a3131' AND norm_key=norm_key('Union Trading Company'))) THEN RAISE EXCEPTION 'norm_key collision'; END IF;
  -- City counts
  IF (SELECT venues_count FROM cities WHERE id='ci_d3197fb64e') <> 206 OR (SELECT venues_count FROM cities WHERE id='ci_bd7396e9f8') <> 18 OR (SELECT venues_count FROM cities WHERE id='ci_22638a3131') <> 112 THEN RAISE EXCEPTION 'city counts before'; END IF;

  ---------------------------------------------------------------- 1. City labels move: hand audit rows, then the write
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'UPDATE', to_jsonb(l), to_jsonb(l) || jsonb_build_object('venue_id', v_go) FROM city_label_source l WHERE l.id IN (20429,20430) AND l.venue_id=v_lm ORDER BY l.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'label move audit %', n; END IF;
  UPDATE city_label_source SET venue_id=v_go WHERE id IN (20429,20430) AND venue_id=v_lm;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels moved %', n; END IF;

  ---------------------------------------------------------------- 2. Awards move
  UPDATE awards SET venue_id=v_go WHERE id IN (20322,20323,20324) AND venue_id=v_lm;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'goh awards %', n; END IF;

  ---------------------------------------------------------------- 3. Old slug stays, non-canonical, on the survivor
  UPDATE slugs SET venue_id=v_go, is_canonical=false WHERE venue_id=v_lm AND property_id='eats' AND city_slug='fukuoka' AND slug='la-maison-de-la-nature-goh' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'la maison slug %', n; END IF;

  ---------------------------------------------------------------- 4. Listing and venue of the twin
  DELETE FROM listings WHERE venue_id=v_lm;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listing deleted %', n; END IF;
  DELETE FROM venues WHERE id=v_lm;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue deleted %', n; END IF;

  ---------------------------------------------------------------- 5. Rename batch (same writes as scripts/rename/apply.ts)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES (c_key, 'staged', 'Closed-venue sweep item 6 (Ben, Nov 2 15:29 ET "1A, 3A"): D.F. Cantina by Barbary Coast is Barbary Coast; The Union Trading Company Bar is Union Trading Company. Run as a gated SQL file, not the rename job; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, p.line, p.vid, p.old_name, p.new_name, 'venue', p.url, 'rename',
         jsonb_build_object('note', p.note, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', x.city_slug, 'slug', x.slug)
    FROM (VALUES
      (1, v_df, 'D.F. Cantina by Barbary Coast', 'Barbary Coast', 'https://www.timeout.sg/bars/barbary-coast',
       'Closed-venue sweep item 6, Nov 2 2026; Time Out lists Barbary Coast and Deadfall Cantina as separate bars at 16 North Canal Rd; 88bamboo https://88bamboo.co/blogs/escapades/deadfall-revamps-with-an-agave-centric-twist gives Barbary Coast as Asia 2021 No. 29, row 19516; rows 19517 and 19518 have no URL; Ben Nov 2 15:29 ET 1A'),
      (2, v_un, 'The Union Trading Company Bar', 'Union Trading Company', 'https://www.the50.com/discovery/Establishments/China/Shanghai/Union-Trading-Company.html',
       'Closed-venue sweep item 6, Nov 2 2026; 50 Best Discovery name, 306 Hengshan Rd; The Spirits Business https://www.thespiritsbusiness.com/?p=915429 (Jun 30 2026) same name; Ben Nov 2 15:29 ET 3A')
    ) AS p(line, vid, old_name, new_name, url, note)
    JOIN venues v ON v.id=p.vid AND v.name=p.old_name
    JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name='Barbary Coast' WHERE id=v_df AND name='D.F. Cantina by Barbary Coast';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename df %', n; END IF;
  UPDATE venues SET name='Union Trading Company' WHERE id=v_un AND name='The Union Trading Company Bar';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename union %', n; END IF;
  PERFORM set_config('app.allow_rename', 'off', true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;

  ---------------------------------------------------------------- 6. New canonical slugs (slug rule: Ben option A, Oct 8)
  UPDATE slugs SET is_canonical=false WHERE venue_id=v_df AND property_id='eats' AND city_slug='singapore' AND slug='d-f-cantina-by-barbary-coast' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'df old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','singapore','barbary-coast',v_df,true);
  UPDATE slugs SET is_canonical=false WHERE venue_id=v_un AND property_id='eats' AND city_slug='shanghai' AND slug='the-union-trading-company-bar' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'union old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','shanghai','union-trading-company',v_un,true);

  ---------------------------------------------------------------- 7. Barbary Coast: status closed, not published, city count
  UPDATE venues SET status='closed' WHERE id=v_df AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'df status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id=v_df AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'df listing %', n; END IF;
  UPDATE cities SET venues_count=205 WHERE id='ci_d3197fb64e' AND venues_count=206;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'singapore %', n; END IF;

  ---------------------------------------------------------------- 8. Ledger (rename rows name the venue itself: no publisher, no ledger row, as the job)
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('asia-50-best-restaurants', 'award', 3, c_job||' | ve_61f0698a02 La Maison de la Nature Goh = ve_ce25175db1 Goh (same chef, closed Oct 2022 for relocation) | awards 20322, 20323, 20324 moved, labels 20429, 20430 moved, old slug non-canonical, listing and venue deleted');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger %', n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11293 OR (SELECT count(*) FROM venues WHERE status='active') <> 10996 OR (SELECT count(*) FROM venues WHERE status='closed') <> 297 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM awards WHERE venue_id=v_go) <> 9 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13021 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11293 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1728 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical GROUP BY v.id HAVING count(x.slug) <> 1) THEN RAISE EXCEPTION 'venue without 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11293 OR (SELECT count(*) FROM city_label_source) <> 23989 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10996 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 28 OR (SELECT count(*) FROM rename_rows) <> 1300 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3264 THEN RAISE EXCEPTION 'blurbs redirects cities after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 186 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id=v_lm) + (SELECT count(*) FROM slugs WHERE venue_id=v_lm) + (SELECT count(*) FROM city_label_source WHERE venue_id=v_lm) + (SELECT count(*) FROM listings WHERE venue_id=v_lm) <> 0 THEN RAISE EXCEPTION 'rows left on the twin'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=3,cities:UPDATE=1,city_label_source:UPDATE=2,listings:DELETE=1,listings:UPDATE=1,slugs:INSERT=2,slugs:UPDATE=3,venues:DELETE=1,venues:UPDATE=3' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log) <> 118844 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
