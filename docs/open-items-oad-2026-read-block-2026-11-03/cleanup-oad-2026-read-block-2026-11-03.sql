-- cleanup-oad-2026-read-block-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open item 2 of handoff-oad-2026-no-live-venue-done. Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go". This file runs only after his "go".
-- 56 new OAD 2026 rows. 49 OAD 2025 rows moved. 22 new venues (18 active, 4 closed). 42 venues deleted. 14 venues change city. Al Mahara active. 2 renames. 19 redirects. 7 new cities.
-- Evidence: oad-2026-separate-read-block-evidence-2026-11-03.csv. No price, address, geo or blurb.
-- Expected after: venues 11,574 (active 11,275, closed 299); awards 27,455; OAD 2026 2,833; OAD 2025 2,437; slugs 13,422; listings 11,574; labels 24,555; price 7,759; redirects 32; aliases 222; cities 3,315, sum 11,275; ledger 225 rows; audit_log +531 (124,173 rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$e|445|Brikz|berlin|a|Berlin|Germany
e|573|Mos|desenzano-del-garda|a|Desenza de la Garda|Italy
e|711|Mural|munich|a|Munich|Germany
a|254|Ling Long Beijing|beijing|a|Beijing|China
a|327|Country Kitchen|beijing|a|Beijing|China
a|389|Orchid|taipei|a|Taipei City|Taiwan
j|241|Saika|kyoto|a|Kyoto|Japan
j|243|Pierre Gagnaire|tokyo|c|Tokyo|Japan
j|353|Hinode|kuwana|a|Mie|Japan
j|356|Kyo Seika|kyoto|a|Kyoto|Japan
j|378|Mikasa|kawasaki|c|Tokyo|Japan
j|404|Sushi Ueda|nagoya|a|Nagoya|Japan
j|524|Tsugumi|fukuoka|a|Okinawa|Japan
j|528|Kawada|tokyo|a|Tokyo|Japan
j|558|Rokkan|tokyo|a|Tokyo|Japan
a|143|Howard's Gourmet Beijing|beijing|c|Beijing|China
a|170|1949 Duck de Chine|beijing|a|Beijing|China
e|304|Punk Royale Copenhagen|copenhagen|a|Copenhagen|Denmark
j|459|Kitafuku Akasaka|tokyo|a|Tokyo|Japan
j|590|Romantico|tokyo|a|Tokyo|Japan
j|680|Arakawa|kyoto|a|Kyoto|Japan
j|515|Miyako Zushi|tokyo|c|Tokyo|Japan$plan$;
  al text := $plan$e|97|ve_ee9dbbdba9
e|116|ve_8cd307127e
e|378|ve_9b831f5bbc
e|396|ve_d1d544cb55
e|541|ve_f98f790eff
e|716|ve_fc37e08929
e|741|ve_53659a02aa
a|48|ve_29a960cf7b
a|68|ve_ad8e3e0807
a|383|ve_59e2ad8e2e
a|569|ve_109d5fea42
a|575|ve_d2c67e7d3d
a|588|ve_716f9013a3
j|6|ve_2aa23782b0
j|27|ve_b48f87e3df
j|62|ve_a6de801104
j|191|ve_4502858503
j|287|ve_5888595dfd
j|339|ve_867747314e
j|395|ve_4e76fc5d6b
j|397|ve_314eb75a52
j|398|ve_38c4c03bad
j|422|ve_acf1abc574
j|425|ve_841b4979a6
j|433|ve_6597d5d543
j|438|ve_049a332738
j|484|ve_6edf88e8db
j|518|ve_9f8a4d46c3
j|540|ve_d47d2ce7dd
j|610|ve_74eb3c7820
j|626|ve_d5f252440c
j|677|ve_234bc5fd17
j|696|ve_a6dc74a321
j|700|ve_9bef9d816c$plan$;
  gl text := $plan$ve_d1d544cb55|barcelona|ci_dea56e47f1|beersel|ci_1edbcd420e|terborght-restaurant
ve_fc37e08929|san-sebastian|ci_453d152d6b|milan|ci_83227a721a|motelombroso
ve_53659a02aa|london|ci_bc180dbc58|vienna|ci_2f7515e8c5|heunisch-erben
ve_b48f87e3df|gunma|ci_682f64ae58|tatebayashi|ci_2a005b7b93|sushi-obana
ve_867747314e|saga|ci_e0145e19f4|karatsu|ci_9e29bcc8e7|tsukuta
ve_314eb75a52|tokyo|ci_ef0cc10ff4|utsunomiya|ci_aa3d3657a9|otowa-restaurant
ve_38c4c03bad|sugawara|ci_1dc5713332|kitakyushu|ci_bc54b43bf0|teruzushi
ve_049a332738|saga|ci_e0145e19f4|karatsu|ci_9e29bcc8e7|amegen
ve_9f8a4d46c3|shizuoka|ci_ce90100a18|hamamatsu|ci_73f801ff4f|rin
ve_d47d2ce7dd|tokyo|ci_ef0cc10ff4|gifu|ci_a70bda71cc|kaikatei
ve_74eb3c7820|shizuoka|ci_ce90100a18|tokyo|ci_ef0cc10ff4|seika-kobayashi
ve_234bc5fd17|kobe|ci_2357e8fb99|nishinomiya|ci_480c548a04|komago
ve_a6dc74a321|shizuoka|ci_ce90100a18|hamamatsu|ci_73f801ff4f|seirin
ve_9bef9d816c|kyoto|ci_e27d6ba3c4|tokyo|ci_ef0cc10ff4|grill-ukai-marunouchi$plan$;
  rd text := $plan$/barcelona/terborght-restaurant|/beersel/terborght-restaurant
/san-sebastian/motelombroso|/milan/motelombroso
/london/heunisch-erben|/vienna/heunisch-erben
/gunma/sushi-obana|/tatebayashi/sushi-obana
/saga/tsukuta|/karatsu/tsukuta
/tokyo/otowa-restaurant|/utsunomiya/otowa-restaurant
/sugawara/teruzushi|/kitakyushu/teruzushi
/saga/amegen|/karatsu/amegen
/shizuoka/rin|/hamamatsu/rin
/tokyo/kaikatei|/gifu/kaikatei
/shizuoka/seika-kobayashi|/tokyo/seika-kobayashi
/kobe/komago|/nishinomiya/komago
/shizuoka/seirin|/hamamatsu/seirin
/kyoto/grill-ukai-marunouchi|/tokyo/grill-ukai-marunouchi
/torshavn/kol|/london/kol
/munich/mugaritz|/san-sebastian/mugaritz
/paris/yamazato|/amsterdam/yamazato
/kyoto/ryuzu|/tokyo/ryuzu
/kyoto/masuda|/tokyo/sushi-masuda$plan$;
  mv text := $plan$5772|ve_7ba5a45715|ve_45acc64582
7070|ve_cf1874968b|ve_5e147ebd94
15965|ve_83aca60857|ve_8cd307127e
18051|ve_2ead0176c8|ve_1b85694549
18060|ve_5126fcd962|ve_decfdabd1b
18084|ve_7797bd66bd|ve_416b201016
18110|ve_2760d564fe|ve_1af6a9c4c4
18157|ve_10b312a8c3|ve_92db485cc4
18185|ve_5be4142ef6|ve_2bba64fd77
18232|ve_7e3068bc36|ve_67409605cb
18293|ve_a73796bf14|ve_abccb8710d
18306|ve_ff1c2fe6e6|ve_e4f54dd59b
18307|ve_6f6e265236|ve_934b1cb36a
18352|ve_04d463f18a|ve_4d0167e3ff
18365|ve_9ac925a36e|ve_57517b6560
18386|ve_383d531c0a|ve_cbb6307531
18408|ve_9159a30107|ve_5073942728
18418|ve_d506cb62f8|ve_bfda4f7b82
18431|ve_fea80d77c8|ve_3ffab4597c
18457|ve_6318a102be|ve_969a2eb301
18478|ve_5ded6b173b|ve_61fa83ffc1
18539|ve_0a68920747|ve_292dd0b5e7
18560|ve_bafcec17d6|ve_b6934408cf
18570|ve_1c5f2c33e9|ve_e7a030373c
18581|ve_51fccb143f|ve_664dd3a0cd
18602|ve_62e4b855de|ve_247efac0c9
18732|ve_5667947ced|ve_813ac16f84
18761|ve_f40bce7d13|ve_893dbeaa44
18772|ve_e3c60e040c|ve_1613162f00
18777|ve_96292e1874|ve_7169692a4c
18873|ve_1b66998fec|ve_075ad36342
18886|ve_e67359bf24|ve_b129b5c20e
18889|ve_49fdf50eda|ve_31417deb9e
18891|ve_445ca5a848|ve_7d7bd459c6
18909|ve_034bdfaa6b|ve_2e21a1be11
18938|ve_c26eac7c0d|ve_418d1e9238
18941|ve_cf2ad8356c|ve_6fd605f948
18952|ve_af6c894a24|ve_d82cc2a6b8
18972|ve_7ff0bac8d5|ve_78a621b46d
18999|ve_5f3035e6f8|ve_bfd691cfd9
19014|ve_ad9f275625|ve_2dbb60d900
19044|ve_5669aef5b4|ve_ce398e568f
19045|ve_4565df5d21|ve_cd8ab23517
19060|ve_b5a03ee530|ve_fbc1526c55
19076|ve_01ed923bb7|ve_38014b33f3
19085|ve_55101794e8|ve_2c881f6f4f
19088|ve_7ff2913e10|ve_f2ad5f4dfc
19110|ve_311a84938e|ve_11e485fd6d
20377|ve_ed8fe96699|ve_29a960cf7b$plan$;
  dv text := $plan$ve_01ed923bb7
ve_034bdfaa6b
ve_04d463f18a
ve_0a68920747
ve_10b312a8c3
ve_1b66998fec
ve_1c5f2c33e9
ve_2760d564fe
ve_2ead0176c8
ve_311a84938e
ve_383d531c0a
ve_445ca5a848
ve_4565df5d21
ve_49fdf50eda
ve_51fccb143f
ve_55101794e8
ve_5667947ced
ve_5669aef5b4
ve_5be4142ef6
ve_5ded6b173b
ve_5f3035e6f8
ve_62e4b855de
ve_6318a102be
ve_6f6e265236
ve_7e3068bc36
ve_7ff0bac8d5
ve_7ff2913e10
ve_9159a30107
ve_96292e1874
ve_9ac925a36e
ve_a73796bf14
ve_ad9f275625
ve_af6c894a24
ve_b5a03ee530
ve_bafcec17d6
ve_c26eac7c0d
ve_cf2ad8356c
ve_e3c60e040c
ve_e67359bf24
ve_f40bce7d13
ve_fea80d77c8
ve_ff1c2fe6e6$plan$;
  cl text := $plan$kuwana|Kuwana
kawasaki|Kawasaki
tatebayashi|Tatebayashi
karatsu|Karatsu
utsunomiya|Utsunomiya
hamamatsu|Hamamatsu
nishinomiya|Nishinomiya$plan$;
  n bigint; s text; aud_max bigint; first_award bigint; bid bigint; dl text[]; ids text[]; r record;
BEGIN
  -- PRE gates. A paste can turn line ends into CR LF, so remove CR before the check. The error gives the lengths.
  nl:=replace(nl,E'\r',''); al:=replace(al,E'\r',''); gl:=replace(gl,E'\r',''); rd:=replace(rd,E'\r',''); mv:=replace(mv,E'\r',''); dv:=replace(dv,E'\r',''); cl:=replace(cl,E'\r','');
  IF md5(nl||E'\n#\n'||al||E'\n#\n'||gl||E'\n#\n'||rd||E'\n#\n'||mv||E'\n#\n'||dv||E'\n#\n'||cl) <> 'de1b1cfae2a9f3c395539e9601cea3ce' THEN RAISE EXCEPTION 'plan text: lengths %, %, %, %, %, %, %', length(nl), length(al), length(gl), length(rd), length(mv), length(dv), length(cl); END IF;
  dl := regexp_split_to_array(dv,E'\n');
  IF (SELECT count(*) FROM venues) <> 11594 OR (SELECT count(*) FROM venues WHERE status='active') <> 11297 OR (SELECT count(*) FROM venues WHERE status='closed') <> 297 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27399 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2777 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13442 OR (SELECT count(*) FROM listings) <> 11594 OR (SELECT count(*) FROM city_label_source) <> 24595 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3308 OR (SELECT sum(venues_count) FROM cities) <> 11297 OR (SELECT count(*) FROM source_capture_ledger) <> 218 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 123642 OR aud_max <> 129471 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.rank, E'\n' ORDER BY a.id)) FROM awards a WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(mv,E'\n') x)) <> '93eeb5e6d8432a43c5ebbef42d7b0702' THEN RAISE EXCEPTION 'moved rows fingerprint'; END IF;
  IF (SELECT count(*) FROM awards a JOIN (SELECT split_part(x,'|',1)::bigint id, split_part(x,'|',2) o FROM regexp_split_to_table(mv,E'\n') x) y ON y.id=a.id AND y.o=a.venue_id) <> 49 THEN RAISE EXCEPTION 'moved rows owner'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id = ANY(dl)) <> '9d15fa7a0b9d1c2bcb8aa91e1cdfa572' THEN RAISE EXCEPTION 'deleted venues fingerprint'; END IF;
  ids := ARRAY['ve_049a332738','ve_109d5fea42','ve_1613162f00','ve_1af6a9c4c4','ve_1b85694549','ve_234bc5fd17','ve_292dd0b5e7','ve_29a960cf7b','ve_2aa23782b0','ve_2c881f6f4f','ve_2dbb60d900','ve_2e21a1be11','ve_314eb75a52','ve_38014b33f3','ve_38c4c03bad','ve_3ffab4597c','ve_418d1e9238','ve_4502858503','ve_4d0167e3ff','ve_4e76fc5d6b','ve_5073942728','ve_5126fcd962','ve_53659a02aa','ve_57517b6560','ve_5888595dfd','ve_59e2ad8e2e','ve_61fa83ffc1','ve_6597d5d543','ve_67409605cb','ve_6edf88e8db','ve_7169692a4c','ve_716f9013a3','ve_74eb3c7820','ve_7797bd66bd','ve_7ba5a45715','ve_83aca60857','ve_841b4979a6','ve_867747314e','ve_893dbeaa44','ve_8cd307127e','ve_934b1cb36a','ve_969a2eb301','ve_9b831f5bbc','ve_9bef9d816c','ve_9f8a4d46c3','ve_a6dc74a321','ve_a6de801104','ve_abccb8710d','ve_acf1abc574','ve_ad8e3e0807','ve_b129b5c20e','ve_b48f87e3df','ve_b6934408cf','ve_bfda4f7b82','ve_cbb6307531','ve_ce398e568f','ve_cf1874968b','ve_d1d544cb55','ve_d2c67e7d3d','ve_d47d2ce7dd','ve_d506cb62f8','ve_d5f252440c','ve_e4f54dd59b','ve_ed8fe96699','ve_ee9dbbdba9','ve_f0f0978f15','ve_f98f790eff','ve_fbc1526c55','ve_fc37e08929','ve_fdea70bea1'];
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id = ANY(ids)) <> '943b4662659ab2a36911e4a4d230b644' THEN RAISE EXCEPTION 'live venues fingerprint'; END IF;
  -- Children of the deleted venues: awards only through the moved rows; labels 2 each; no price, address, geo, hours, photo, blurb.
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY(dl)) <> 42 OR (SELECT count(*) FROM city_label_source WHERE venue_id = ANY(dl)) <> 84 OR (SELECT count(*) FROM slugs WHERE venue_id = ANY(dl)) <> 44 OR (SELECT count(*) FROM listings WHERE venue_id = ANY(dl)) <> 42 THEN RAISE EXCEPTION 'children of deleted'; END IF;
  IF (SELECT (SELECT count(*) FROM price WHERE venue_id = ANY(dl))+(SELECT count(*) FROM addresses WHERE venue_id = ANY(dl))+(SELECT count(*) FROM geo WHERE venue_id = ANY(dl))+(SELECT count(*) FROM hours WHERE venue_id = ANY(dl))+(SELECT count(*) FROM photo_refs WHERE venue_id = ANY(dl))+(SELECT count(*) FROM blurbs WHERE venue_id = ANY(dl))) <> 0 THEN RAISE EXCEPTION 'other children of deleted'; END IF;
  IF EXISTS (SELECT 1 FROM redirects x JOIN slugs t ON t.venue_id = ANY(dl) AND x.to_path='/'||t.city_slug||'/'||t.slug) THEN RAISE EXCEPTION 'redirect points at a deleted venue'; END IF;
  -- New venue id, slug and clash rules
  SELECT count(*) INTO n FROM (SELECT split_part(x,'|',3) name, split_part(x,'|',4) cs FROM regexp_split_to_table(nl,E'\n') x) q, LATERAL (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(q.name)),'[^a-z0-9]+','-','g')) sl) y WHERE EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=q.cs AND t.slug=y.sl) OR EXISTS (SELECT 1 FROM venues v WHERE v.id='ve_'||left(md5(q.cs||':'||y.sl),10)) OR EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE c.slug=q.cs AND v.norm_key=norm_key(q.name) AND NOT v.id = ANY(dl));
  IF n <> 0 THEN RAISE EXCEPTION 'new venue clash %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(cl,E'\n') x WHERE EXISTS (SELECT 1 FROM cities c WHERE c.slug=split_part(x,'|',1) OR c.id='ci_'||left(md5(split_part(x,'|',1)),10)) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',1) AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  -- City moves: venue and slug as read, target slug and name free
  SELECT count(*) INTO n FROM regexp_split_to_table(gl,E'\n') x JOIN venues v ON v.id=split_part(x,'|',1) AND v.city_id=split_part(x,'|',3) JOIN slugs t ON t.venue_id=v.id AND t.city_slug=split_part(x,'|',2) AND t.slug=split_part(x,'|',6) AND t.is_canonical;
  IF n <> 14 THEN RAISE EXCEPTION 'city moves as read %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(gl,E'\n') x WHERE EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',4) AND t.slug=split_part(x,'|',6)) OR EXISTS (SELECT 1 FROM venues a JOIN venues b ON b.id=split_part(x,'|',1) AND a.norm_key=b.norm_key AND a.id<>b.id WHERE a.city_id=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'city move clash %', n; END IF;
  IF EXISTS (SELECT 1 FROM redirects t, regexp_split_to_table(rd,E'\n') x WHERE t.from_path=split_part(x,'|',1)) THEN RAISE EXCEPTION 'redirect exists'; END IF;
  -- 2026 ranks free in each list
  SELECT count(*) INTO n FROM (SELECT split_part(x,'|',1) l, split_part(x,'|',2)::int rk FROM regexp_split_to_table(nl||E'\n'||al,E'\n') x) q JOIN awards a ON a.source_id='oad' AND a.year=2026 AND a.rank=q.rk AND a.source_url='https://www.oadguides.com/lists/'||(CASE q.l WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026';
  IF n <> 0 THEN RAISE EXCEPTION 'rank taken %', n; END IF;
  IF (SELECT status FROM venues WHERE id='ve_d2c67e7d3d') <> 'closed' OR (SELECT published FROM listings WHERE venue_id='ve_d2c67e7d3d') THEN RAISE EXCEPTION 'al mahara before'; END IF;
  IF (SELECT country FROM cities WHERE id='ci_1edbcd420e') IS NOT NULL THEN RAISE EXCEPTION 'beersel before'; END IF;
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT 'ci_'||left(md5(split_part(x,'|',1)),10), split_part(x,'|',1), split_part(x,'|',2), 'Japan', 'JP', 'city'::city_kind, NULL, NULL, NULL, 0 FROM regexp_split_to_table(cl,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'cities %', n; END IF;
  UPDATE cities SET country='Belgium', country_iso='BE' WHERE id='ci_1edbcd420e' AND country IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'beersel %', n; END IF;
  -- WRITE: new venues, listings, slugs, labels
  FOR r IN SELECT split_part(x,'|',3) name, split_part(x,'|',4) cs, split_part(x,'|',5) st, split_part(x,'|',6) clab, split_part(x,'|',7) colab, trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g')) sl FROM regexp_split_to_table(nl,E'\n') x LOOP
    INSERT INTO venues (id, name, category, city_id, status) SELECT 've_'||left(md5(r.cs||':'||r.sl),10), r.name, 'restaurant'::venue_category, c.id, (CASE r.st WHEN 'a' THEN 'active' ELSE 'closed' END)::venue_status FROM cities c WHERE c.slug=r.cs;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue % %', r.name, n; END IF;
    INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), 'eats', r.st='a');
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.sl, 've_'||left(md5(r.cs||':'||r.sl),10), true);
    WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), r.clab, 'city_display'::label_column_t, 'oad', 'OAD 2026 read block'), ('ve_'||left(md5(r.cs||':'||r.sl),10), r.colab, 'country'::label_column_t, 'oad', 'OAD 2026 read block') RETURNING *)
      INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  END LOOP;
  -- WRITE: new OAD 2026 rows
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT q.vid, 'oad', 2026, q.rk, 'No. '||q.rk, NULL, q.url FROM (
      SELECT 've_'||left(md5(split_part(x,'|',4)||':'||trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g'))),10) vid, split_part(x,'|',2)::int rk, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' url FROM regexp_split_to_table(nl,E'\n') x
      UNION ALL SELECT split_part(x,'|',3), split_part(x,'|',2)::int, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' FROM regexp_split_to_table(al,E'\n') x) q ORDER BY q.url, q.rk;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 56 THEN RAISE EXCEPTION 'new awards %', n; END IF;
  -- WRITE: move OAD 2025 rows
  UPDATE awards a SET venue_id=y.n FROM (SELECT split_part(x,'|',1)::bigint id, split_part(x,'|',2) o, split_part(x,'|',3) n FROM regexp_split_to_table(mv,E'\n') x) y WHERE a.id=y.id AND a.venue_id=y.o AND a.source_id='oad' AND a.year=2025;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 49 THEN RAISE EXCEPTION 'moved awards %', n; END IF;
  -- WRITE: delete the 42 venues
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY(dl)) <> 0 THEN RAISE EXCEPTION 'award left on deleted'; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL FROM city_label_source c WHERE c.venue_id = ANY(dl);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 84 THEN RAISE EXCEPTION 'label audit %', n; END IF;
  DELETE FROM city_label_source WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 84 THEN RAISE EXCEPTION 'labels %', n; END IF;
  DELETE FROM slugs WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 44 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  DELETE FROM listings WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 42 THEN RAISE EXCEPTION 'listings %', n; END IF;
  DELETE FROM venues WHERE id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 42 THEN RAISE EXCEPTION 'venues %', n; END IF;
  -- WRITE: 14 city moves. City labels stay as OAD printed them.
  UPDATE venues v SET city_id=split_part(x,'|',5) FROM regexp_split_to_table(gl,E'\n') x WHERE v.id=split_part(x,'|',1) AND v.city_id=split_part(x,'|',3);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'moved venues %', n; END IF;
  UPDATE slugs t SET city_slug=split_part(x,'|',4) FROM regexp_split_to_table(gl,E'\n') x WHERE t.property_id='eats' AND t.venue_id=split_part(x,'|',1) AND t.city_slug=split_part(x,'|',2) AND t.slug=split_part(x,'|',6) AND t.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'moved slugs %', n; END IF;
  -- WRITE: 19 redirects (14 moves, 5 twins)
  WITH ins AS (INSERT INTO redirects (from_path, to_path) SELECT split_part(x,'|',1), split_part(x,'|',2) FROM regexp_split_to_table(rd,E'\n') x RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'redirects', i.from_path, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 19 THEN RAISE EXCEPTION 'redirects %', n; END IF;
  -- WRITE: Al Mahara open (Ben 7A)
  UPDATE venues SET status='active' WHERE id='ve_d2c67e7d3d' AND status='closed'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'al mahara %', n; END IF;
  UPDATE listings SET published=true WHERE venue_id='ve_d2c67e7d3d' AND NOT published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'al mahara listing %', n; END IF;
  -- WRITE: 2 renames (Ben 8A)
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('rename-oad-2026-read-block-2026-11-03', 'staged', 'Open item 2 (Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"): 2 live names with note or promotion text.') RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  FOR r IN SELECT * FROM (VALUES
    (1,'ve_fdea70bea1','Ginza Kojyu - prenotato il 27','Ginza Kojyu','tokyo','ginza-kojyu-prenotato-il-27','ginza-kojyu','https://www.kojyu.jp/','Note text removed. OAD 2026 prints Ginza Koju, own domain kojyu.jp.'),
    (2,'ve_f0f0978f15','Toritama | Yakitori | Michelin | Curated','Toritama','hong-kong','toritama-yakitori-michelin-curated','toritama','https://www.oadguides.com/lists/asia/top-restaurants/2026','Promotion text removed. OAD 2026 prints Toritama, Asia 172.')
  ) t(line, vid, oldn, newn, cs, olds, news, url, ev) LOOP
    IF norm_key(r.newn) IN (SELECT v.norm_key FROM venues v JOIN venues w ON w.id=r.vid AND v.city_id=w.city_id) THEN RAISE EXCEPTION 'norm_key collision %', r.vid; END IF;
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
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 41 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', 11, 'cleanup:cleanup-oad-2026-read-block-2026-11-03 | open item 2: OAD 2026 hold and move rows, asia | https://www.oadguides.com/lists/asia/top-restaurants/2026 | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"'),
    ('oad', 'award', 11, 'cleanup:cleanup-oad-2026-read-block-2026-11-03 | open item 2: OAD 2026 hold and move rows, europe | https://www.oadguides.com/lists/europe/top-restaurants/2026 | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"'),
    ('oad', 'award', 34, 'cleanup:cleanup-oad-2026-read-block-2026-11-03 | open item 2: OAD 2026 hold and move rows, japan | https://www.oadguides.com/lists/japan/top-restaurants/2026 | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"'),
    ('oad', 'award', 49, 'cleanup:cleanup-oad-2026-read-block-2026-11-03 | open item 2: 49 OAD 2025 rows moved to the printed restaurant, read from the 2025 lists Nov 4 | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"'),
    ('oad', 'award', 42, 'cleanup:cleanup-oad-2026-read-block-2026-11-03 | contamination rule (Ben, Sep 28): 42 venues with no award after the move deleted | 5 twins redirect, others 404 | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"'),
    ('oad', 'city_label', 44, 'cleanup:cleanup-oad-2026-read-block-2026-11-03 | open item 2: city labels of the 22 new venues | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"'),
    ('oad', 'name', 2, 'rename-apply:rename-oad-2026-read-block-2026-11-03 | Ginza Kojyu, Toritama | Ben Nov 3 22:29 ET "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A", 22:53 "B, go"');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11574 OR (SELECT count(*) FROM venues WHERE status='active') <> 11275 OR (SELECT count(*) FROM venues WHERE status='closed') <> 299 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27455 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2833 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 56 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13422 OR (SELECT count(*) FROM listings) <> 11574 OR (SELECT count(*) FROM city_label_source) <> 24555 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 32 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3315 OR (SELECT sum(venues_count) FROM cities) <> 11275 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 225 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=56,awards:UPDATE=49,cities:INSERT=7,cities:UPDATE=42,city_label_source:DELETE=84,city_label_source:INSERT=44,listings:DELETE=42,listings:INSERT=22,listings:UPDATE=1,redirects:INSERT=19,slugs:DELETE=44,slugs:INSERT=24,slugs:UPDATE=16,venues:DELETE=42,venues:INSERT=22,venues:UPDATE=17' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
