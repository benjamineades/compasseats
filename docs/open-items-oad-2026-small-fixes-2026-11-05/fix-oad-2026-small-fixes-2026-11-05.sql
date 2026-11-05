-- fix-oad-2026-small-fixes-2026-11-05.sql
-- CompassEats, Nov 5 2026. This file runs only after Ben's choices and his "go".
-- A: Kawaki ve_60a5408dd6 moves from Fukui to Sakai. Own site: Sakai, Mikuni. Redirect /fukui/kawaki.
-- B: Nakajo ve_5f76d01346 moves from Yokahama to Yokohama. Own site: Naka-ku, Yokohama. Redirect /yokahama/nakajo.
-- C: City otsu display "otsu" to "Otsu".
-- D: New venue Endo Chelsea ve_4393da55b7, London, active. OAD 2026 No. 169, award 33167, moves from Endo at the Rotunda ve_b9d291ce2a. OAD prints Endo Chelsea at 8-9 Blacklands Terrace.
-- E: 花小路さわ田 ve_f17195ac4b renamed Tsubotsubo, name_native つぼつぼ, active, published, slug sapporo/tsubotsubo. Own site: moved Jul 6 2025. Award rows stay.
-- Expected after: venues 11,595 (active 11,292, closed 303); awards 27,481; OAD 2026 2,859; OAD 2025 2,437; slugs 13,539; listings 11,595; labels 24,597; price 7,759; redirects 35; aliases 222; cities 3,318, sum 11,292; ledger +2; rename batch +1; rename_rows 1,563; audit_log +26. Closed venues with an OAD 2026 row 76.
BEGIN;
DO $do$
DECLARE
  n bigint; aud bigint; s text; bid bigint;
  k constant text := 've_60a5408dd6'; nj constant text := 've_5f76d01346'; ro constant text := 've_b9d291ce2a'; ec constant text := 've_4393da55b7'; hs constant text := 've_f17195ac4b';
  c_fukui constant text := 'ci_286da19d94'; c_sakai constant text := 'ci_9546d3af1d'; c_yokahama constant text := 'ci_49b6bab436'; c_yokohama constant text := 'ci_b35828edaa'; c_otsu constant text := 'ci_3d734c6df0'; c_london constant text := 'ci_bc180dbc58'; c_sapporo constant text := 'ci_8c88ffee57';
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11290 OR (SELECT count(*) FROM venues WHERE status='closed')<>304 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026)<>2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025)<>2437 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs)<>13535 OR (SELECT count(*) FROM listings)<>11594 OR (SELECT count(*) FROM city_label_source)<>24595 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 OR (SELECT count(*) FROM city_aliases)<>222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities)<>3318 OR (SELECT sum(venues_count) FROM cities)<>11290 OR (SELECT count(*) FROM source_capture_ledger)<>241 OR (SELECT max(id) FROM source_capture_ledger)<>295 OR (SELECT count(*) FROM rename_rows)<>1562 THEN RAISE EXCEPTION 'cities, ledger, rename before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0))<>0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published)<>0 THEN RAISE EXCEPTION 'published before'; END IF;
  SELECT count(*),max(id) INTO n,aud FROM audit_log; IF n<>124803 OR aud<>130632 THEN RAISE EXCEPTION 'audit before % / %',n,aud; END IF;
  IF (SELECT count(*) FROM venues WHERE id=k AND name='Kawaki' AND status='active' AND city_id=c_fukui)<>1 THEN RAISE EXCEPTION 'Kawaki as read'; END IF;
  IF (SELECT count(*) FROM venues WHERE id=nj AND name='Nakajo' AND status='active' AND city_id=c_yokahama)<>1 THEN RAISE EXCEPTION 'Nakajo as read'; END IF;
  IF (SELECT count(*) FROM venues WHERE id=ro AND name='Endo at the Rotunda' AND status='closed' AND city_id=c_london)<>1 THEN RAISE EXCEPTION 'Rotunda as read'; END IF;
  IF (SELECT count(*) FROM venues WHERE id=hs AND name='花小路さわ田' AND status='closed' AND city_id=c_sapporo AND name_native IS NULL)<>1 THEN RAISE EXCEPTION 'Sawada as read'; END IF;
  IF (SELECT count(*) FROM awards WHERE id=33167 AND venue_id=ro AND source_id='oad' AND year=2026 AND rank=169)<>1 THEN RAISE EXCEPTION 'award 33167 as read'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id=ro)<>4 THEN RAISE EXCEPTION 'Rotunda awards'; END IF;
  IF (SELECT count(*) FROM cities WHERE (id=c_fukui AND venues_count=2) OR (id=c_sakai AND venues_count=1) OR (id=c_yokahama AND venues_count=1) OR (id=c_yokohama AND venues_count=2) OR (id=c_otsu AND venues_count=2 AND display='otsu') OR (id=c_london AND venues_count=250) OR (id=c_sapporo AND venues_count=16))<>7 THEN RAISE EXCEPTION 'cities as read'; END IF;
  IF (SELECT count(*) FROM slugs WHERE property_id='eats' AND venue_id=k AND city_slug='fukui' AND slug='kawaki' AND is_canonical)<>1 THEN RAISE EXCEPTION 'Kawaki slug'; END IF;
  IF (SELECT count(*) FROM slugs WHERE property_id='eats' AND venue_id=nj AND city_slug='yokahama' AND slug='nakajo' AND is_canonical)<>1 THEN RAISE EXCEPTION 'Nakajo slug'; END IF;
  IF (SELECT count(*) FROM slugs WHERE property_id='eats' AND venue_id=hs AND city_slug='sapporo' AND slug='sapporo-sdi424' AND is_canonical)<>1 OR (SELECT count(*) FROM listings WHERE venue_id=hs AND property_id='eats' AND NOT published)<>1 THEN RAISE EXCEPTION 'Sawada slug, listing'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE (city_slug='sakai' AND slug='kawaki') OR (city_slug='yokohama' AND slug='nakajo') OR (city_slug='london' AND slug='endo-chelsea') OR (city_slug='sapporo' AND slug='tsubotsubo')) THEN RAISE EXCEPTION 'slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path IN ('/fukui/kawaki','/yokahama/nakajo','/sakai/kawaki','/yokohama/nakajo','/london/endo-chelsea','/sapporo/tsubotsubo')) THEN RAISE EXCEPTION 'redirect taken'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id=ec) OR EXISTS (SELECT 1 FROM venues WHERE city_id=c_london AND norm_key=norm_key('Endo Chelsea')) THEN RAISE EXCEPTION 'Endo Chelsea clash'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE city_id=c_sapporo AND id<>hs AND norm_key=norm_key('Tsubotsubo')) THEN RAISE EXCEPTION 'Tsubotsubo twin'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='fix-oad-2026-small-fixes-2026-11-05') THEN RAISE EXCEPTION 'batch key used'; END IF;
  -- WRITE A: Kawaki
  UPDATE venues SET city_id=c_sakai WHERE id=k AND city_id=c_fukui; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'Kawaki city %',n; END IF;
  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=k AND city_slug='fukui' AND slug='kawaki' AND is_canonical; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'Kawaki old slug %',n; END IF;
  INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats','sakai','kawaki',k,true);
  -- WRITE B: Nakajo
  UPDATE venues SET city_id=c_yokohama WHERE id=nj AND city_id=c_yokahama; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'Nakajo city %',n; END IF;
  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=nj AND city_slug='yokahama' AND slug='nakajo' AND is_canonical; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'Nakajo old slug %',n; END IF;
  INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats','yokohama','nakajo',nj,true);
  -- Redirects for A and B. No trigger on this table: hand audit rows.
  WITH ins AS (INSERT INTO redirects (from_path,to_path) VALUES ('/fukui/kawaki','/sakai/kawaki'),('/yokahama/nakajo','/yokohama/nakajo') RETURNING *)
    INSERT INTO audit_log (table_name,row_pk,action,old_row,new_row) SELECT 'redirects',i.from_path,'INSERT',NULL,to_jsonb(i) FROM ins i;
  -- WRITE C: Otsu
  UPDATE cities SET display='Otsu' WHERE id=c_otsu AND display='otsu'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'Otsu %',n; END IF;
  -- WRITE D: Endo Chelsea
  INSERT INTO venues (id,name,category,city_id,status) VALUES (ec,'Endo Chelsea','restaurant'::venue_category,c_london,'active'::venue_status);
  INSERT INTO listings (venue_id,property_id,published) VALUES (ec,'eats',true);
  INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats','london','endo-chelsea',ec,true);
  WITH ins AS (INSERT INTO city_label_source (venue_id,label,from_column,publisher,note) VALUES (ec,'London','city_display'::label_column_t,'oad','OAD 2026 small fixes, Nov 5'),(ec,'United Kingdom','country'::label_column_t,'oad','OAD 2026 small fixes, Nov 5') RETURNING *)
    INSERT INTO audit_log (table_name,row_pk,action,old_row,new_row) SELECT 'city_label_source',i.id::text,'INSERT',NULL,to_jsonb(i) FROM ins i;
  UPDATE awards SET venue_id=ec WHERE id=33167 AND venue_id=ro; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'award move %',n; END IF;
  -- WRITE E: Tsubotsubo
  INSERT INTO rename_batches (batch_key,status,note) VALUES ('fix-oad-2026-small-fixes-2026-11-05','staged',$n$花小路さわ田 to Tsubotsubo. Own site: moved Jul 6 2025 to Miyanomori as お料理と蕎麦の店 つぼつぼ. Same phone as OAD 2026.$n$) RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  INSERT INTO rename_rows (batch_id,line,venue_id,expected_name,new_name,source_id,source_url,verdict,detail)
    SELECT bid,1,v.id,v.name,'Tsubotsubo','venue','https://hanakoji-sawada.com/','rename',jsonb_build_object('live_name',v.name,'city_id',v.city_id) FROM venues v WHERE v.id=hs AND v.name='花小路さわ田';
  GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename row %',n; END IF;
  UPDATE venues SET name='Tsubotsubo', name_native='つぼつぼ' WHERE id=hs AND name='花小路さわ田'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename %',n; END IF;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=hs AND city_slug='sapporo' AND slug='sapporo-sdi424' AND is_canonical; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'Sawada old slug %',n; END IF;
  INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats','sapporo','tsubotsubo',hs,true);
  UPDATE rename_batches SET status='applied',applied_at=now() WHERE id=bid AND status='staged'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'batch %',n; END IF;
  UPDATE venues SET status='active' WHERE id=hs AND status='closed'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'status %',n; END IF;
  UPDATE listings SET published=true WHERE venue_id=hs AND property_id='eats' AND NOT published; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'published %',n; END IF;
  -- City counts
  UPDATE cities c SET venues_count=coalesce(x.active_venues,0) FROM cities d LEFT JOIN city_venue_counts x ON x.city_id=d.id WHERE d.id=c.id AND c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0);
  GET DIAGNOSTICS n=ROW_COUNT; IF n<>6 THEN RAISE EXCEPTION 'city counts %',n; END IF;
  INSERT INTO source_capture_ledger (publisher,field_type,items,job) VALUES
    ('oad','award',1,'cleanup:fix-oad-2026-small-fixes-2026-11-05 | OAD 2026 No. 169 moved to Endo Chelsea, OAD prints that name | https://www.oadguides.com/restaurant/endo-at-the-rotunda'),
    ('oad','city_label',2,'cleanup:fix-oad-2026-small-fixes-2026-11-05 | city labels of Endo Chelsea');
  -- POST
  IF (SELECT count(*) FROM venues)<>11595 OR (SELECT count(*) FROM venues WHERE status='active')<>11292 OR (SELECT count(*) FROM venues WHERE status='closed')<>303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026)<>2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025)<>2437 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs)<>13539 OR (SELECT count(*) FROM listings)<>11595 OR (SELECT count(*) FROM city_label_source)<>24597 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>35 OR (SELECT count(*) FROM city_aliases)<>222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities)<>3318 OR (SELECT sum(venues_count) FROM cities)<>11292 OR (SELECT count(*) FROM source_capture_ledger)<>243 OR (SELECT count(*) FROM rename_rows)<>1563 THEN RAISE EXCEPTION 'cities, ledger, rename after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0))<>0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM cities WHERE (id=c_fukui AND venues_count=1) OR (id=c_sakai AND venues_count=2) OR (id=c_yokahama AND venues_count=0) OR (id=c_yokohama AND venues_count=3) OR (id=c_otsu AND venues_count=2 AND display='Otsu') OR (id=c_london AND venues_count=251) OR (id=c_sapporo AND venues_count=17))<>7 THEN RAISE EXCEPTION 'cities after as planned'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published)<>0 THEN RAISE EXCEPTION 'published after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs s ON s.venue_id=v.id AND s.is_canonical GROUP BY v.id HAVING count(s.slug)<>1) THEN RAISE EXCEPTION 'canonical slugs'; END IF;
  IF (SELECT count(DISTINCT a.venue_id) FROM awards a JOIN venues v ON v.id=a.venue_id WHERE v.status='closed' AND a.source_id='oad' AND a.year=2026)<>76 THEN RAISE EXCEPTION 'closed with OAD 2026'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name,action,count(*) c FROM audit_log WHERE id>aud GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=1,cities:UPDATE=7,city_label_source:INSERT=2,listings:INSERT=1,listings:UPDATE=1,redirects:INSERT=2,slugs:INSERT=4,slugs:UPDATE=3,venues:INSERT=1,venues:UPDATE=4' THEN RAISE EXCEPTION 'audit after %',s; END IF;
  RAISE NOTICE 'OK: all gates passed, batch %',bid;
END $do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
