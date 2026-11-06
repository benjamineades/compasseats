-- load-michelin-2026-portugal-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Portugal 2026. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: ceremony March 10, 2026, before the capture window (https://guide.michelin.com/en/article/michelin-guide-ceremony/All%20About%20the%20MICHELIN%20Guide%20Portugal%202026). The 78 legacy rows hold the 2026 edition. Relabel 78 rows 2025 -> 2026. Retire 0.
-- source_url: 77 rows = the card (/us/en/). O Tipico (award 13031), card 404 today: capture of June 1, 2026, says "2026 MICHELIN Guide" and Bib Gourmand (https://web.archive.org/web/20260601200735id_/https://guide.michelin.com/pt/pt_PT/aveiro-region/gueda/restaurant/o-tipico). Venue stays active.
-- New: A Cozinha do Paco, One Star 2026, card name, restaurant, active, published. New city Evora, country Portugal. No price, address, geo, blurb or chef.
-- Source: docs/michelin-2026-portugal-2026-11-05/relay-pt-2026-list-pages-2026-11-05.txt sha256 717227e03a4005fdfa8c522424f834d74c6bfa7452f892e8b2b1442accc9882a.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11699 (active 11391, closed 308); awards 28593; slugs 13643; listings 11699; labels 24805; cities 3322, sum 11391; ledger 271 rows; Michelin 2025/2026/2027 4369/7378/122; audit_log +85.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1420|ve_77ab02854d|Two Stars|https://guide.michelin.com/us/en/faro-region/albufeira/restaurant/vila-joya
1946|ve_9ee0193f68|Two Stars|https://guide.michelin.com/us/en/ilha-da-madeira/funchal/restaurant/il-gallo-d-oro
2259|ve_e47cd9ab64|Two Stars|https://guide.michelin.com/us/en/porto-region/lea-da-palmeira/restaurant/casa-de-cha-da-boa-nova
2283|ve_66a88537f6|Two Stars|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/fifty-seconds
2287|ve_43ae6e7a39|Two Stars|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/henrique-sa-pessoa
2839|ve_d92c6ae3a5|Two Stars|https://guide.michelin.com/us/en/faro-region/porches/restaurant/ocean216602
2843|ve_f322c5f6d8|Two Stars|https://guide.michelin.com/us/en/porto-region/porto/restaurant/antiqvvm
3515|ve_63b7b5b6e1|Two Stars|https://guide.michelin.com/us/en/porto-region/vila-nova-de-gaia/restaurant/the-yeatman
3653|ve_e78a5228c4|One Star|https://guide.michelin.com/us/en/faro-region/almancil/restaurant/gusto378372
3661|ve_29050824f6|One Star|https://guide.michelin.com/us/en/porto-region/amarante/restaurant/largo-do-paco
4274|ve_c571d9d3eb|One Star|https://guide.michelin.com/us/en/braga-region/braga/restaurant/palatial
4275|ve_a5a73f1b60|One Star|https://guide.michelin.com/us/en/braganca-region/braganca/restaurant/g-pousada
4451|ve_d5257db805|One Star|https://guide.michelin.com/us/en/lisboa-region/cascais/restaurant/fortaleza-do-guincho
4453|ve_aea1eaea0f|One Star|https://guide.michelin.com/us/en/lisboa-region/cascais/restaurant/kappo-1196985
4989|ve_ef8635f354|One Star|https://guide.michelin.com/us/en/faro-region/faro/restaurant/alameda-1198788
5094|ve_83dcfcb027|One Star|https://guide.michelin.com/us/en/ilha-da-madeira/funchal/restaurant/desarma
5095|ve_6fce85097f|One Star|https://guide.michelin.com/us/en/ilha-da-madeira/funchal/restaurant/william216831
5238|ve_7f5e557320|One Star|https://guide.michelin.com/us/en/braga-region/guimares/restaurant/a-cozinha
5841|ve_c697311d35|One Star|https://guide.michelin.com/us/en/faro-region/lagoa/restaurant/bon-bon472583
5957|ve_7f24200a5a|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/2monkeys
5958|ve_ecfec26b66|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/cura
5962|ve_c663d4a73a|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/encanto
5963|ve_e4dff87d89|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/epur
5966|ve_03ce225ed2|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/feitoria
5968|ve_e637956b15|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/grenache
5969|ve_3db0864af6|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/kabuki-lisboa
5970|ve_b64fdc78e5|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/kanazawa
5971|ve_12fb6f3b13|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/loco
5974|ve_b6fb48f8f1|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/marlene
5978|ve_fd3f9b0e88|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/sala1154759
5979|ve_de4fd42462|One Star|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/yoso-1214668
6598|ve_5c92670da6|One Star|https://guide.michelin.com/us/en/evora-region/montemor-o-novo/restaurant/mapa
7354|ve_1465ed893a|One Star|https://guide.michelin.com/us/en/vila-real-region/peso-da-rgua/restaurant/schisto
7426|ve_cef6099299|One Star|https://guide.michelin.com/us/en/faro-region/portimo/restaurant/vista365067
7433|ve_ebdea8383b|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/blind
7434|ve_a44b4d1920|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/dop
7435|ve_ebed1b5620|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/euskalduna-studio
7440|ve_f7858aaf09|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/gastro-by-elemento
7441|ve_11508e8a71|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/in-diferente
7442|ve_8faf5fe211|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/le-monument
7444|ve_1dbd4f3301|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/pedro-lemos
7448|ve_02ec8f0c23|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/vila-foz
7449|ve_82e0750c94|One Star|https://guide.michelin.com/us/en/porto-region/porto/restaurant/eon
7534|ve_1cb90206e2|One Star|https://guide.michelin.com/us/en/evora-region/reguengos-de-monsaraz/restaurant/esporao
7865|ve_e46916cd7e|One Star|https://guide.michelin.com/us/en/santarem-region/santarm/restaurant/o-balcao
8095|ve_36dc4c44af|One Star|https://guide.michelin.com/us/en/viseu-region/silgueiros_2424590/restaurant/mesa-de-lemos
8233|ve_c1c6d84e4b|One Star|https://guide.michelin.com/us/en/lisboa-region/sintra/restaurant/lab-by-sergi-arola
8235|ve_2eff8391c7|One Star|https://guide.michelin.com/us/en/lisboa-region/sintra/restaurant/midori
8448|ve_eb931b4166|One Star|https://guide.michelin.com/us/en/faro-region/tavira/restaurant/a-ver-tavira
8918|ve_db3718b695|One Star|https://guide.michelin.com/us/en/porto-region/vila-do-conde/restaurant/oculto
8919|ve_06c15a6bb1|One Star|https://guide.michelin.com/us/en/porto-region/vila-nova-de-gaia/restaurant/vinha
9197|ve_578415de8d|Bib Gourmand|https://guide.michelin.com/us/en/santarem-region/abrantes/restaurant/casa-chef-victor-felisberto
9243|ve_cd8fae6f67|Bib Gourmand|https://guide.michelin.com/us/en/leiria/alvados_3138159/restaurant/terruja
9244|ve_a5e2345ee7|Bib Gourmand|https://guide.michelin.com/us/en/lisboa-region/alverca-do-ribatejo_7770439/restaurant/taberna-sakra
9578|ve_dbd8c080bd|Bib Gourmand|https://guide.michelin.com/us/en/braganca-region/braganca/restaurant/contradicao
9579|ve_2f504d218f|Bib Gourmand|https://guide.michelin.com/us/en/braganca-region/braganca/restaurant/o-javali
9886|ve_32b9d20f06|Bib Gourmand|https://guide.michelin.com/us/en/coimbra/coimbra/restaurant/solar-do-bacalhau
10185|ve_3d5550286a|Bib Gourmand|https://guide.michelin.com/us/en/coimbra/figueira-da-foz_2419538/restaurant/olaias
10222|ve_d8936e2258|Bib Gourmand|https://guide.michelin.com/us/en/ilha-da-madeira/funchal/restaurant/casal-da-penha
10238|ve_f590bedecd|Bib Gourmand|https://guide.michelin.com/us/en/aveiro-region/gafanha-da-encarnacao_2419914/restaurant/dori
10370|ve_3441608188|Bib Gourmand|https://guide.michelin.com/us/en/braga-region/guimares/restaurant/norma-1207644
10898|ve_db6cfedd9b|Bib Gourmand|https://guide.michelin.com/us/en/leiria/leiria_2432572/restaurant/mesa15
10919|ve_0f14da650a|Bib Gourmand|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/canalha
10920|ve_0c1c6c2179|Bib Gourmand|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/carnal-1200315
10921|ve_9c9425eedd|Bib Gourmand|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/oficio
10922|ve_612141d31c|Bib Gourmand|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/pigmeu
10923|ve_902f41c40c|Bib Gourmand|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/zunzum-gastrobar
11095|ve_e87afefdc9|Bib Gourmand|https://guide.michelin.com/us/en/porto-region/maia_2420974/restaurant/machado
11223|ve_eea3c9af60|Bib Gourmand|https://guide.michelin.com/us/en/evora-region/montemor-o-novo/restaurant/poda
11735|ve_985b6561a5|Bib Gourmand|https://guide.michelin.com/us/en/portalegre-region/portalegre/restaurant/solar-do-forcado
11736|ve_5f82dab470|Bib Gourmand|https://guide.michelin.com/us/en/porto-region/porto/restaurant/oma-1203846
11737|ve_683132f77c|Bib Gourmand|https://guide.michelin.com/us/en/porto-region/porto/restaurant/patio-44
12132|ve_da24f20eaa|Bib Gourmand|https://guide.michelin.com/us/en/setubal/setubal/restaurant/xtoria
12693|ve_d8a2bac9f9|Bib Gourmand|https://guide.michelin.com/us/en/viseu-region/tonda/restaurant/3-pipos
12824|ve_9c5faf9b1a|Bib Gourmand|https://guide.michelin.com/us/en/viana-do-castelo-region/viana-do-castelo/restaurant/camelo
12866|ve_cdb234e39f|Bib Gourmand|https://guide.michelin.com/us/en/viseu-region/viseu/restaurant/flora-1210835
13031|ve_eb0e147299|Bib Gourmand|https://web.archive.org/web/20260601200735id_/https://guide.michelin.com/pt/pt_PT/aveiro-region/gueda/restaurant/o-tipico
13158|ve_b401142d6e|Two Stars|https://guide.michelin.com/us/en/lisboa-region/lisboa/restaurant/belcanto$plan$;
  aw text := $plan$ve_ce7726880f|One Star|https://guide.michelin.com/us/en/evora-region/vora/restaurant/a-cozinha-do-paco$plan$;
  nw text := $plan$ve_ce7726880f|a-cozinha-do-paco|evora|ci_4b3712949e|Évora|Évora|A Cozinha do Paço$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '0838b94e05c052e1ad935585c6e20a87' OR md5(aw) <> '39a2e188488e891e7a8cf7808a6fd571' OR md5(nw) <> 'cb0ae2be4f657ad4331004005d0a5c20' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Portugal' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) y;
  IF fp IS DISTINCT FROM 'd921c14d6da839e97cb69a824072d10f' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Portugal') <> 78 THEN RAISE EXCEPTION 'Portugal Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11698 OR (SELECT count(*) FROM venues WHERE status='active') <> 11390 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28592 OR (SELECT max(id) FROM awards) <> 35763 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4447 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7299 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13642 OR (SELECT count(*) FROM listings) <> 11698 OR (SELECT count(*) FROM city_label_source) <> 24803 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11390 OR (SELECT count(*) FROM source_capture_ledger) <> 268 OR (SELECT max(id) FROM source_capture_ledger) <> 322 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127088 OR aud_max <> 132917 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x UNION ALL SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  -- New city and venue
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_4b3712949e' OR slug='evora') OR EXISTS (SELECT 1 FROM city_aliases WHERE alias='evora') OR 'ci_4b3712949e' <> 'ci_'||left(md5('evora'),10) THEN RAISE EXCEPTION 'city clash'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) OR (c.country='Portugal' AND v.norm_key=norm_key(split_part(x,'|',7)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 78 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: city
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_4b3712949e', 'evora', 'Évora', 'Portugal', 'PT', 'city', NULL, NULL, NULL, 1);
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',7), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows. The label is the card city.
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',6),'city_display'),('Portugal','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',78,'relabel:load-michelin-2026-portugal-2026-11-05 | rule 2.1.7: Portugal edition live at capture = 2026 (ceremony March 10, 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/All%20About%20the%20MICHELIN%20Guide%20Portugal%202026) | year 2025 -> 2026, source_url = the card (/us/en/), 1 archive capture for award 13031, retire 0 | relay sha256 717227e03a4005fdfa8c522424f834d74c6bfa7452f892e8b2b1442accc9882a | DRAFT, choices not yet given'),
    ('michelin','award',1,'cleanup:load-michelin-2026-portugal-2026-11-05 | A Cozinha do Paco, One Star 2026, absent from the legacy rows | list read Nov 5, 2026 | relay sha256 717227e03a4005fdfa8c522424f834d74c6bfa7452f892e8b2b1442accc9882a | DRAFT, choices not yet given'),
    ('michelin','city_label',2,'cleanup:load-michelin-2026-portugal-2026-11-05 | city labels of 1 new venue, new city evora | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11699 OR (SELECT count(*) FROM venues WHERE status='active') <> 11391 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28593 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 1 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> md5((SELECT string_agg(x, E'\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4369 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7378 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Portugal' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=26,One Star=44,Two Stars=9' THEN RAISE EXCEPTION 'Portugal 2026 %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Portugal' AND a.year=2025) <> 0 THEN RAISE EXCEPTION 'Portugal 2025'; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Portugal' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 78 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Portugal' AND a.year=2026 AND a.source_url ~ '^https://web\.archive\.org/web/\d{14}id_/https://guide\.michelin\.com/') <> 1 THEN RAISE EXCEPTION 'archive URL after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Portugal' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13643 OR (SELECT count(*) FROM listings) <> 11699 OR (SELECT count(*) FROM city_label_source) <> 24805 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3322 OR (SELECT sum(venues_count) FROM cities) <> 11391 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 271 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=1,awards:UPDATE=78,cities:INSERT=1,city_label_source:INSERT=2,listings:INSERT=1,slugs:INSERT=1,venues:INSERT=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
