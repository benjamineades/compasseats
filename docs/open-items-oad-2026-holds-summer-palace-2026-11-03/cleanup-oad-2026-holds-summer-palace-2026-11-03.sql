-- cleanup-oad-2026-holds-summer-palace-2026-11-03.sql
-- CompassEats, Nov 4 2026. Open items 1 and 2 of handoff-oad-2026-read-block-done. Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A". This file runs only after his "go".
-- 15 new OAD 2026 rows (14 on new venues, 1 Summer Palace on Hong Kong). 4 OAD rows moved (Summer Palace 3, Pirouette 1). 14 new venues (13 active, 1 closed). 1 venue deleted (Le Choubichou, 404, no redirect). 3 new cities.
-- Evidence: oad-2026-holds-summer-palace-evidence-2026-11-03.csv. No price, address, geo or blurb.
-- Expected after: venues 11,587 (active 11,287, closed 300); awards 27,470; OAD 2026 2,848; OAD 2025 2,437; slugs 13,435; listings 11,587; labels 24,581; price 7,759; redirects 32; aliases 222; cities 3,318, sum 11,287; ledger 231 rows; audit_log +108 (124,281 rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$a|325|Bangkok Bold Kitchen|bangkok|a|Bangkok|Thailand
e|412|Restaurant Pirouette|paris|c|Paris|France
j|214|Uran|otsu|a|Osaka|Japan
j|313|Yakiniku Kousen|tokyo|a|Tokyo|Japan
j|318|Hisada|akaiwa|a|Hiroshima|Japan
j|448|Katatsumuri|yamagata-gifu|a|Nagoya|Japan
j|479|Kimiya|ikoma|a|Nara|Japan
j|609|Kappo Yoshida|fukuoka|a|Fukuoka|Japan
j|638|Hamagen|nagoya|a|Nagoya|Japan
j|702|Mudai|tokyo|a|Tokyo|Japan
j|746|Seto|kyoto|a|Kyoto|Japan
j|769|Tempura Yokota|tokyo|a|Tokyo|Japan
j|784|Sushi Hachiya|kanazawa|a|Kanazawa|Japan
j|789|Shangu|tokyo|a|Tokyo|Japan$plan$;
  al text := $plan$a|259|ve_54ab6673c8$plan$;
  mv text := $plan$5562|ve_54ab6673c8|ve_6a1064e62c
18119|ve_6a1064e62c|ve_54ab6673c8
18463|ve_3a0ba9fb7b|ve_acb290badf
32880|ve_54ab6673c8|ve_6a1064e62c$plan$;
  cl text := $plan$akaiwa|Akaiwa
ikoma|Ikoma
yamagata-gifu|Yamagata (Gifu)$plan$;
  dv text := $plan$ve_3a0ba9fb7b$plan$;
  n bigint; s text; aud_max bigint; first_award bigint; dl text[]; r record;
BEGIN
  -- PRE gates. A paste can turn line ends into CR LF, so remove CR before the check. The error gives the lengths.
  nl:=replace(nl,E'\r',''); al:=replace(al,E'\r',''); mv:=replace(mv,E'\r',''); cl:=replace(cl,E'\r',''); dv:=replace(dv,E'\r','');
  IF md5(nl||E'\n#\n'||al||E'\n#\n'||mv||E'\n#\n'||cl||E'\n#\n'||dv) <> '680ec6e4b7b73307fae40fabd0376080' THEN RAISE EXCEPTION 'plan text: lengths %, %, %, %, %', length(nl), length(al), length(mv), length(cl), length(dv); END IF;
  dl := regexp_split_to_array(dv,E'\n');
  IF (SELECT count(*) FROM venues) <> 11574 OR (SELECT count(*) FROM venues WHERE status='active') <> 11275 OR (SELECT count(*) FROM venues WHERE status='closed') <> 299 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27455 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2833 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13422 OR (SELECT count(*) FROM listings) <> 11574 OR (SELECT count(*) FROM city_label_source) <> 24555 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 32 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3315 OR (SELECT sum(venues_count) FROM cities) <> 11275 OR (SELECT count(*) FROM source_capture_ledger) <> 225 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 124173 OR aud_max <> 130002 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.rank, E'\n' ORDER BY a.id)) FROM awards a WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(mv,E'\n') x)) <> '78cc39447db7e6a72e0c56d7bcd3190d' THEN RAISE EXCEPTION 'moved rows fingerprint'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id IN ('ve_54ab6673c8','ve_6a1064e62c','ve_3a0ba9fb7b')) <> 'b262339b21f292ecf386adc4ba4a8df8' THEN RAISE EXCEPTION 'live venues fingerprint'; END IF;
  -- Children of the deleted venue: 1 award through the moved row, 2 labels, 1 slug, 1 listing, nothing else.
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY(dl)) <> 1 OR (SELECT count(*) FROM city_label_source WHERE venue_id = ANY(dl)) <> 2 OR (SELECT count(*) FROM slugs WHERE venue_id = ANY(dl)) <> 1 OR (SELECT count(*) FROM listings WHERE venue_id = ANY(dl)) <> 1 THEN RAISE EXCEPTION 'children of deleted'; END IF;
  IF (SELECT (SELECT count(*) FROM price WHERE venue_id = ANY(dl))+(SELECT count(*) FROM addresses WHERE venue_id = ANY(dl))+(SELECT count(*) FROM geo WHERE venue_id = ANY(dl))+(SELECT count(*) FROM hours WHERE venue_id = ANY(dl))+(SELECT count(*) FROM photo_refs WHERE venue_id = ANY(dl))+(SELECT count(*) FROM blurbs WHERE venue_id = ANY(dl))+(SELECT count(*) FROM rename_rows WHERE venue_id = ANY(dl))) <> 0 THEN RAISE EXCEPTION 'other children of deleted'; END IF;
  IF EXISTS (SELECT 1 FROM redirects x JOIN slugs t ON t.venue_id = ANY(dl) AND x.to_path='/'||t.city_slug||'/'||t.slug) THEN RAISE EXCEPTION 'redirect points at a deleted venue'; END IF;
  -- New venue id, slug and clash rules
  SELECT count(*) INTO n FROM regexp_split_to_table(nl,E'\n') x, LATERAL (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g')) sl) y WHERE EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',4) AND t.slug=y.sl) OR EXISTS (SELECT 1 FROM venues v WHERE v.id='ve_'||left(md5(split_part(x,'|',4)||':'||y.sl),10)) OR EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE c.slug=split_part(x,'|',4) AND v.norm_key=norm_key(split_part(x,'|',3)) AND NOT v.id = ANY(dl));
  IF n <> 0 THEN RAISE EXCEPTION 'new venue clash %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(cl,E'\n') x WHERE EXISTS (SELECT 1 FROM cities c WHERE c.slug=split_part(x,'|',1) OR c.id='ci_'||left(md5(split_part(x,'|',1)),10)) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',1) AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  -- 2026 ranks free in each list
  SELECT count(*) INTO n FROM (SELECT split_part(x,'|',1) l, split_part(x,'|',2)::int rk FROM regexp_split_to_table(nl||E'\n'||al,E'\n') x) q JOIN awards a ON a.source_id='oad' AND a.year=2026 AND a.rank=q.rk AND a.source_url='https://www.oadguides.com/lists/'||(CASE q.l WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026';
  IF n <> 0 THEN RAISE EXCEPTION 'rank taken %', n; END IF;
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT 'ci_'||left(md5(split_part(x,'|',1)),10), split_part(x,'|',1), split_part(x,'|',2), 'Japan', 'JP', 'city'::city_kind, NULL, NULL, NULL, 0 FROM regexp_split_to_table(cl,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'cities %', n; END IF;
  -- WRITE: new venues, listings, slugs, labels
  FOR r IN SELECT split_part(x,'|',3) name, split_part(x,'|',4) cs, split_part(x,'|',5) st, split_part(x,'|',6) clab, split_part(x,'|',7) colab, trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g')) sl FROM regexp_split_to_table(nl,E'\n') x LOOP
    INSERT INTO venues (id, name, category, city_id, status) SELECT 've_'||left(md5(r.cs||':'||r.sl),10), r.name, 'restaurant'::venue_category, c.id, (CASE r.st WHEN 'a' THEN 'active' ELSE 'closed' END)::venue_status FROM cities c WHERE c.slug=r.cs;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue % %', r.name, n; END IF;
    INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), 'eats', r.st='a');
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.sl, 've_'||left(md5(r.cs||':'||r.sl),10), true);
    WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), r.clab, 'city_display'::label_column_t, 'oad', 'OAD 2026 holds'), ('ve_'||left(md5(r.cs||':'||r.sl),10), r.colab, 'country'::label_column_t, 'oad', 'OAD 2026 holds') RETURNING *)
      INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  END LOOP;
  -- WRITE: new OAD 2026 rows
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT q.vid, 'oad', 2026, q.rk, 'No. '||q.rk, NULL, q.url FROM (
      SELECT 've_'||left(md5(split_part(x,'|',4)||':'||trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g'))),10) vid, split_part(x,'|',2)::int rk, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' url FROM regexp_split_to_table(nl,E'\n') x
      UNION ALL SELECT split_part(x,'|',3), split_part(x,'|',2)::int, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' FROM regexp_split_to_table(al,E'\n') x) q ORDER BY q.url, q.rk;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 15 THEN RAISE EXCEPTION 'new awards %', n; END IF;
  -- WRITE: move OAD rows
  UPDATE awards a SET venue_id=y.n FROM (SELECT split_part(x,'|',1)::bigint id, split_part(x,'|',2) o, split_part(x,'|',3) n FROM regexp_split_to_table(mv,E'\n') x) y WHERE a.id=y.id AND a.venue_id=y.o AND a.source_id='oad';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'moved awards %', n; END IF;
  -- WRITE: delete the venue with no award left
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY(dl)) <> 0 THEN RAISE EXCEPTION 'award left on deleted'; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL FROM city_label_source c WHERE c.venue_id = ANY(dl);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'label audit %', n; END IF;
  DELETE FROM city_label_source WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  DELETE FROM slugs WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  DELETE FROM listings WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings %', n; END IF;
  DELETE FROM venues WHERE id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues %', n; END IF;
  -- WRITE: city counts
  UPDATE cities c SET venues_count=coalesce(k.active_venues,0) FROM cities d LEFT JOIN city_venue_counts k ON k.city_id=d.id WHERE d.id=c.id AND c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 11 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', 2, 'cleanup:cleanup-oad-2026-holds-summer-palace-2026-11-03 | OAD 2026 hold rows and Summer Palace, asia | https://www.oadguides.com/lists/asia/top-restaurants/2026 | Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A"'),
    ('oad', 'award', 1, 'cleanup:cleanup-oad-2026-holds-summer-palace-2026-11-03 | OAD 2026 hold rows, europe | https://www.oadguides.com/lists/europe/top-restaurants/2026 | Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A"'),
    ('oad', 'award', 12, 'cleanup:cleanup-oad-2026-holds-summer-palace-2026-11-03 | OAD 2026 hold rows, japan | https://www.oadguides.com/lists/japan/top-restaurants/2026 | Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A"'),
    ('oad', 'award', 4, 'cleanup:cleanup-oad-2026-holds-summer-palace-2026-11-03 | 4 OAD rows moved to the printed restaurant: Summer Palace 5562, 18119, 32880, Pirouette 18463 | Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A"'),
    ('oad', 'award', 1, 'cleanup:cleanup-oad-2026-holds-summer-palace-2026-11-03 | contamination rule (Ben, Sep 28): Le Choubichou ve_3a0ba9fb7b deleted, no award after the move, 404, no redirect | Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A"'),
    ('oad', 'city_label', 28, 'cleanup:cleanup-oad-2026-holds-summer-palace-2026-11-03 | city labels of the 14 new venues | Ben Nov 3 23:37 ET "1A, 2A, 3A, 4A, 5A"');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11587 OR (SELECT count(*) FROM venues WHERE status='active') <> 11287 OR (SELECT count(*) FROM venues WHERE status='closed') <> 300 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27470 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2848 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 15 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13435 OR (SELECT count(*) FROM listings) <> 11587 OR (SELECT count(*) FROM city_label_source) <> 24581 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 32 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11287 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 231 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=15,awards:UPDATE=4,cities:INSERT=3,cities:UPDATE=11,city_label_source:DELETE=2,city_label_source:INSERT=28,listings:DELETE=1,listings:INSERT=14,slugs:DELETE=1,slugs:INSERT=14,venues:DELETE=1,venues:INSERT=14' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
