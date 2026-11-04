-- cleanup-oad-2026-holds-status-2026-11-04.sql
-- CompassEats, Nov 4 2026. Open items 1, 2 and 4 of handoff-oad-2026-holds-summer-palace-done. Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A". This file runs only after his "go".
-- 9 new OAD 2026 rows (6 on new venues, 3 on live venues). 1 OAD 2025 row moved (18993). 6 new venues (3 active, 3 closed). 3 venues closed (Testina, Art di Daniele Sperindio, Sustanza). 2 renames. 1 city move. 1 redirect.
-- Evidence: oad-2026-holds-status-evidence-2026-11-04.csv. No price, address, geo or blurb.
-- Expected after: venues 11,593 (active 11,287, closed 306); awards 27,479; OAD 2026 2,857; OAD 2025 2,437; slugs 13,443; listings 11,593; labels 24,593; price 7,759; redirects 33; aliases 222; cities 3,318, sum 11,287; ledger 237 rows; audit_log +62 (124,343 rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$a|283|Tempura Tenon|hong-kong|a|Hong Kong|China
a|494|Gloria Maris Shark's Fin Restaurant|manila|a|Manilla|Philippines
e|403|Arnanz|madrid|c|Madrid|Spain
e|534|Defune|london|c|London|United Kingdom
j|460|Koide|kanazawa|a|Kanazawa|Japan
j|501|Sushi Ichi|tokyo|c|Tokyo|Japan$plan$;
  al text := $plan$a|486|ve_84687b6ab6
j|180|ve_515b6a646f
j|462|ve_ebb1779b86$plan$;
  st text := $plan$ve_6698b9aa28
ve_856c6504e9
ve_9715b2f266$plan$;
  n bigint; s text; aud_max bigint; first_award bigint; sl text[]; bid bigint; r record;
BEGIN
  -- PRE gates. A paste can turn line ends into CR LF, so remove CR before the check. The error gives the lengths.
  nl:=replace(nl,E'\r',''); al:=replace(al,E'\r',''); st:=replace(st,E'\r','');
  IF md5(nl||E'\n#\n'||al||E'\n#\n'||st) <> 'cc0a1d24c74db167f21d01bace4dfe5c' THEN RAISE EXCEPTION 'plan text: lengths %, %, %', length(nl), length(al), length(st); END IF;
  sl := regexp_split_to_array(st,E'\n');
  IF (SELECT count(*) FROM venues) <> 11587 OR (SELECT count(*) FROM venues WHERE status='active') <> 11287 OR (SELECT count(*) FROM venues WHERE status='closed') <> 300 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27470 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2848 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13435 OR (SELECT count(*) FROM listings) <> 11587 OR (SELECT count(*) FROM city_label_source) <> 24581 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 32 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11287 OR (SELECT count(*) FROM source_capture_ledger) <> 231 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 124281 OR aud_max <> 130110 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.rank, E'\n' ORDER BY a.id)) FROM awards a WHERE a.id=18993) <> '4ae9a0b2d0c10d538c931b1fa0af023d' THEN RAISE EXCEPTION 'moved row fingerprint'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id IN ('ve_515b6a646f','ve_6698b9aa28','ve_7f732a531c','ve_84687b6ab6','ve_856c6504e9','ve_9715b2f266','ve_ebb1779b86')) <> '200fe36d8d41b5b8819d563b87498ca8' THEN RAISE EXCEPTION 'live venues fingerprint'; END IF;
  -- Slugs as read
  IF (SELECT count(*) FROM slugs WHERE property_id='eats' AND ((venue_id='ve_84687b6ab6' AND city_slug='beijing' AND slug='yatang' AND is_canonical) OR (venue_id='ve_ebb1779b86' AND city_slug='yokahama' AND slug='omino' AND is_canonical) OR (venue_id='ve_7f732a531c' AND city_slug='tokyo' AND slug='ginza-sushi-ichi-singapore' AND NOT is_canonical))) <> 3 THEN RAISE EXCEPTION 'slugs as read'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE (city_slug,slug) IN (('tokyo','omino'),('tokyo','omino-kamiyacho'),('beijing','jing-yaa-tang'))) THEN RAISE EXCEPTION 'rename slug clash'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path='/yokahama/omino') THEN RAISE EXCEPTION 'redirect exists'; END IF;
  IF norm_key('Jing Yaa Tang') IN (SELECT v.norm_key FROM venues v WHERE v.city_id='ci_0420a206ae') OR norm_key('Omino Kamiyacho') IN (SELECT v.norm_key FROM venues v WHERE v.city_id='ci_ef0cc10ff4') OR 'omino' IN (SELECT v.norm_key FROM venues v WHERE v.city_id='ci_ef0cc10ff4') THEN RAISE EXCEPTION 'norm_key collision'; END IF;
  -- New venue id, slug and clash rules
  SELECT count(*) INTO n FROM regexp_split_to_table(nl,E'\n') x, LATERAL (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g')) sl) y WHERE EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',4) AND t.slug=y.sl) OR EXISTS (SELECT 1 FROM venues v WHERE v.id='ve_'||left(md5(split_part(x,'|',4)||':'||y.sl),10)) OR EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE c.slug=split_part(x,'|',4) AND v.norm_key=norm_key(split_part(x,'|',3))) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.slug=split_part(x,'|',4));
  IF n <> 0 THEN RAISE EXCEPTION 'new venue clash %', n; END IF;
  -- 2026 ranks free in each list
  SELECT count(*) INTO n FROM (SELECT split_part(x,'|',1) l, split_part(x,'|',2)::int rk FROM regexp_split_to_table(nl||E'\n'||al,E'\n') x) q JOIN awards a ON a.source_id='oad' AND a.year=2026 AND a.rank=q.rk AND a.source_url='https://www.oadguides.com/lists/'||(CASE q.l WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026';
  IF n <> 0 THEN RAISE EXCEPTION 'rank taken %', n; END IF;
  -- WRITE: new venues, listings, slugs, labels. Closed venues are not published.
  FOR r IN SELECT split_part(x,'|',3) name, split_part(x,'|',4) cs, split_part(x,'|',5) st, split_part(x,'|',6) clab, split_part(x,'|',7) colab, trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g')) sl FROM regexp_split_to_table(nl,E'\n') x LOOP
    INSERT INTO venues (id, name, category, city_id, status) SELECT 've_'||left(md5(r.cs||':'||r.sl),10), r.name, 'restaurant'::venue_category, c.id, (CASE r.st WHEN 'a' THEN 'active' ELSE 'closed' END)::venue_status FROM cities c WHERE c.slug=r.cs;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue % %', r.name, n; END IF;
    INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), 'eats', r.st='a');
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.sl, 've_'||left(md5(r.cs||':'||r.sl),10), true);
    WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), r.clab, 'city_display'::label_column_t, 'oad', 'OAD 2026 holds, Nov 4'), ('ve_'||left(md5(r.cs||':'||r.sl),10), r.colab, 'country'::label_column_t, 'oad', 'OAD 2026 holds, Nov 4') RETURNING *)
      INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  END LOOP;
  -- WRITE: 9 new OAD 2026 rows
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT q.vid, 'oad', 2026, q.rk, 'No. '||q.rk, NULL, q.url FROM (
      SELECT 've_'||left(md5(split_part(x,'|',4)||':'||trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g'))),10) vid, split_part(x,'|',2)::int rk, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' url FROM regexp_split_to_table(nl,E'\n') x
      UNION ALL SELECT split_part(x,'|',3), split_part(x,'|',2)::int, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' FROM regexp_split_to_table(al,E'\n') x) q ORDER BY q.url, q.rk;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 9 THEN RAISE EXCEPTION 'new awards %', n; END IF;
  -- WRITE: OAD 2025 row 18993 and its old slug leave Ginza Fukuju for Sushi Ichi
  UPDATE awards SET venue_id='ve_'||left(md5('tokyo:sushi-ichi'),10) WHERE id=18993 AND venue_id='ve_7f732a531c' AND source_id='oad'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'moved award %', n; END IF;
  UPDATE slugs SET venue_id='ve_'||left(md5('tokyo:sushi-ichi'),10) WHERE property_id='eats' AND venue_id='ve_7f732a531c' AND city_slug='tokyo' AND slug='ginza-sushi-ichi-singapore' AND NOT is_canonical; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'moved slug %', n; END IF;
  -- WRITE: 3 closures (closed rule, Nov 2: status closed and published false, same transaction)
  UPDATE venues SET status='closed' WHERE id = ANY(sl) AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'closures %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id = ANY(sl) AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'unpublish %', n; END IF;
  -- WRITE: Omino moves from Yokahama to Tokyo. City labels stay as OAD printed them.
  UPDATE venues SET city_id='ci_ef0cc10ff4' WHERE id='ve_ebb1779b86' AND city_id='ci_49b6bab436'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city move %', n; END IF;
  UPDATE slugs SET city_slug='tokyo' WHERE property_id='eats' AND venue_id='ve_ebb1779b86' AND city_slug='yokahama' AND slug='omino' AND is_canonical; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city move slug %', n; END IF;
  WITH ins AS (INSERT INTO redirects (from_path, to_path) VALUES ('/yokahama/omino','/tokyo/omino-kamiyacho') RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'redirects', i.from_path, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  -- WRITE: 2 renames. Old slugs stay non-canonical.
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('rename-oad-2026-holds-status-2026-11-04', 'staged', 'Open item 2 (Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"): OAD 2025 and 2026 lists print the name, live name came from the Sheet.') RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  FOR r IN SELECT * FROM (VALUES
    (1,'ve_84687b6ab6','Yatang','Jing Yaa Tang','beijing','yatang','jing-yaa-tang','https://www.oadguides.com/lists/asia/top-restaurants/2025','OAD 2025 rank 384 and 2026 rank 486 print Jing Yaa Tang, chef Li Dong. Own hotel page uses this name.'),
    (2,'ve_ebb1779b86','Omino','Omino Kamiyacho','tokyo','omino','omino-kamiyacho','https://www.oadguides.com/lists/japan/top-restaurants/2025','OAD 2025 rank 518 and 2026 rank 462 print Omino Kamiyacho, Tokyo, chef Kiyotaka Nakajo. OAD phone is the Kamiyacho shop.')
  ) t(line, vid, oldn, newn, cs, olds, news, url, ev) LOOP
    INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
      SELECT bid, r.line, v.id, v.name, r.newn, 'oad', r.url, 'rename', jsonb_build_object('note', r.ev, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', r.cs, 'slug', r.olds) FROM venues v WHERE v.id=r.vid AND v.name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename row %', r.vid; END IF;
    UPDATE venues SET name=r.newn WHERE id=r.vid AND name=r.oldn; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename %', r.vid; END IF;
    IF trim(both '-' from regexp_replace(lower(f_unaccent(r.newn)),'[^a-z0-9]+','-','g')) <> r.news THEN RAISE EXCEPTION 'slug rule %', r.vid; END IF;
    UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug=r.cs AND slug=r.olds AND is_canonical; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', r.vid; END IF;
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.news, r.vid, true);
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch %', n; END IF;
  -- WRITE: city counts
  UPDATE cities c SET venues_count=coalesce(k.active_venues,0) FROM cities d LEFT JOIN city_venue_counts k ON k.city_id=d.id WHERE d.id=c.id AND c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 6 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', 3, 'cleanup:cleanup-oad-2026-holds-status-2026-11-04 | OAD 2026 hold rows, asia | https://www.oadguides.com/lists/asia/top-restaurants/2026 | Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'award', 2, 'cleanup:cleanup-oad-2026-holds-status-2026-11-04 | OAD 2026 hold rows, europe | https://www.oadguides.com/lists/europe/top-restaurants/2026 | Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'award', 4, 'cleanup:cleanup-oad-2026-holds-status-2026-11-04 | OAD 2026 hold rows, japan | https://www.oadguides.com/lists/japan/top-restaurants/2026 | Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'award', 1, 'cleanup:cleanup-oad-2026-holds-status-2026-11-04 | OAD 2025 row 18993 moved from Ginza Fukuju to Sushi Ichi, read from the 2025 list Nov 4 | Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'city_label', 12, 'cleanup:cleanup-oad-2026-holds-status-2026-11-04 | city labels of the 6 new venues | Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'name', 2, 'rename-apply:rename-oad-2026-holds-status-2026-11-04 | Jing Yaa Tang, Omino Kamiyacho | Ben Nov 4 09:06 ET "1A, 2A, 3A, 4A, 5A, 6A"');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11593 OR (SELECT count(*) FROM venues WHERE status='active') <> 11287 OR (SELECT count(*) FROM venues WHERE status='closed') <> 306 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27479 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2857 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 9 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13443 OR (SELECT count(*) FROM listings) <> 11593 OR (SELECT count(*) FROM city_label_source) <> 24593 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 33 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11287 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 237 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=9,awards:UPDATE=1,cities:UPDATE=6,city_label_source:INSERT=12,listings:INSERT=6,listings:UPDATE=3,redirects:INSERT=1,slugs:INSERT=8,slugs:UPDATE=4,venues:INSERT=6,venues:UPDATE=6' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
