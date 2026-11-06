-- load-michelin-2026-a3-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin A3: Argentina, Abu Dhabi, Czechia, Estonia 2026. Ben choices 1-9:A, Nov 6 08:43 ET. This file runs only after Ben's "go".
-- Relabel 39 rows 2025 -> 2026 (rule 2.1.7): Abu Dhabi 12, Czechia 27. 37 with the /us/en/ card URL, Goldfish the article URL, Perk an archive URL. Retire 0.
-- 37 new 2026 rows: Abu Dhabi 1, Estonia 11, Argentina 25. 15 new venues: Buenos Aires 10, Mendoza 3, Tallinn 2. Argentina and Estonia 2025 rows stay.
-- Source: docs/michelin-a3-2026-11-06/relay-a3-2026-list-pages-2026-11-06.txt sha256 f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11812 (active 11494, closed 318); awards 28966; slugs 13756; listings 11812; labels 25031; cities 3335, sum 11494; ledger 305 rows; audit_log +154.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$3523~ve_8755f6afbb~Two Stars~https://guide.michelin.com/us/en/stredocesky/vysoky-ujezd_1272168/restaurant/restaurant-papilio
3615~ve_d0abb7315f~One Star~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/talea-by-antonio-guida
3617~ve_03b05a284f~One Star~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/erth
5370~ve_f98b9c7e60~One Star~https://guide.michelin.com/us/en/jihomoravsky/hlohovec_1274686/restaurant/essens
6993~ve_9576bbb675~One Star~https://guide.michelin.com/us/en/olomoucky/olomouc_1277165/restaurant/entree
7466~ve_bc0d3d687c~One Star~https://guide.michelin.com/us/en/prague/prague/restaurant/casa-de-carli
7467~ve_ab175fc8f5~One Star~https://guide.michelin.com/us/en/prague/prague/restaurant/field
7469~ve_5d4ba53dd8~One Star~https://guide.michelin.com/us/en/prague/prague/restaurant/la-degustation-boheme-bourgeoise
7471~ve_377c6477c0~One Star~https://guide.michelin.com/us/en/prague/prague/restaurant/levitate-1208342
7472~ve_4f0bab6fd9~One Star~https://guide.michelin.com/us/en/prague/prague/restaurant/stangl
9111~ve_315e6272a8~One Star~https://guide.michelin.com/us/en/zlinsky/zlin_1279638/restaurant/la-villa-1211435
9198~ve_cac886fd50~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/almayass-1202415
9199~ve_e45c0380d2~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/beirut-sur-mer
9200~ve_3de8722614~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/tazal
9202~ve_c17972f8e7~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/3fils-abu-dhabi
9203~ve_a9828b143d~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/al-mrzab
9204~ve_cc08771532~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/bua-thai-cafe
9205~ve_85088316db~Bib Gourmand~https://guide.michelin.com/ae-az/en/article/michelin-guide-ceremony/just-unveiled-the-michelin-guide-abu-dhabi-2026
9206~ve_510f83360e~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/mika
9207~ve_31dc687975~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/otoro
9208~ve_aa718ce811~Bib Gourmand~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/ryba
9594~ve_2bb552adb7~Bib Gourmand~https://guide.michelin.com/us/en/jihomoravsky/brno_1273693/restaurant/bar-atelier-bistro
9595~ve_5ae3a515e0~Bib Gourmand~https://guide.michelin.com/us/en/jihomoravsky/brno_1273693/restaurant/valoria
9636~ve_3eb0fcc1dd~Bib Gourmand~https://guide.michelin.com/us/en/ustecky/budyne-nad-ohri_1264274/restaurant/dvur-perlova-voda
10617~ve_6aa1c7f272~Bib Gourmand~https://guide.michelin.com/us/en/hradec-kralove-region/hradec-kralove_1265999/restaurant/satlava
10925~ve_fe4a79af15~Bib Gourmand~https://guide.michelin.com/us/en/pardubicky/litomysl_1267653/restaurant/bohem
11496~ve_dd8e1e7ab8~Bib Gourmand~https://guide.michelin.com/us/en/olomoucky/olomouc_1277165/restaurant/long-story-short-eatery-bakery
11712~ve_ab8959e7cf~Bib Gourmand~https://guide.michelin.com/us/en/plzensky/plzen_1269468/restaurant/stipec
11744~ve_cebc3bcf80~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/alma-1218075
11745~ve_06f25ac0a5~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/dejvicka-34-by-tomas-cerny
11746~ve_fc0ee5a6f1~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/na-kopci
11747~ve_58ce6a8434~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/the-eatery
11748~ve_3e827a52c1~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/u-kalendu
11749~ve_ee392234c3~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/u-mateje
11750~ve_863df9ea78~Bib Gourmand~https://guide.michelin.com/us/en/prague/prague/restaurant/vycep
12757~ve_b964eda4a9~Bib Gourmand~https://guide.michelin.com/us/en/south-bohemian/tabor_1278891/restaurant/goldie-1211724
12758~ve_ce27500ff8~Bib Gourmand~https://guide.michelin.com/us/en/jihocesky/trebon_1278941/restaurant/supina-a-supinka
13038~ve_c8f0a3b986~Bib Gourmand~https://guide.michelin.com/us/en/moravskoslezsky/celadna_1279845/restaurant/miura
13039~ve_fe70f07ca7~Bib Gourmand~https://web.archive.org/web/20251221005857id_/https://guide.michelin.com/us/en/olomoucky/sumperk_1280119/restaurant/perk-restaurant$plan$;
  aw text := $plan$ve_1aa93c684f~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/vesta-1246700
ve_294a4c62c3~One Star~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/trescha
ve_335d635543~One Star~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/don-julio
ve_38dee4b5fe~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/mn-santa-ines
ve_39db3a14e9~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/centauro
ve_425f829f4b~One Star~https://guide.michelin.com/us/en/harju/tallinn/restaurant/noa-chef%E2%80%99s-hall
ve_48611c89d7~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/bis-bistro
ve_5aaa1b2409~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/cal
ve_60bc7f7623~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/reliquia
ve_61c19195c5~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/garabato-bistro
ve_686120991a~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/acido
ve_68c96f306c~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/fume
ve_6a95136b73~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/uma-1217018
ve_7261ce4c40~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/brindillas
ve_72c1cb3555~Two Stars~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/aramburu
ve_7ed7d856da~Two Stars~https://guide.michelin.com/us/en/harju/tallinn/restaurant/180%C2%B0-by-matthias-diether
ve_80686a6329~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/azafran-532684
ve_8318719674~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/caseros
ve_867f67e9eb~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/fotografiska-1199007
ve_86d26ed855~One Star~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/han
ve_89a4464be4~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/casa-vigil
ve_8b758ec442~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/lore-bistroo
ve_91e91bae75~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/mengano
ve_99b8be1b50~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/anafe
ve_a1395b237f~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/noa
ve_a53b0b6956~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/riccitelli-bistro
ve_a968fed555~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/la-vida
ve_ab54b3cc90~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/mantel-ja-korsten
ve_ae11c601d6~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/angelica-cocina-maestra
ve_b523973674~One Star~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/crizia
ve_b792775eb5~Bib Gourmand~https://guide.michelin.com/us/en/harju/tallinn/restaurant/tuljak
ve_cdd176b0ae~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/chuchu
ve_d1bf0d558e~Bib Gourmand~https://guide.michelin.com/us/en/viljandi-region/viljandi/restaurant/fellin
ve_dda5b49090~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/la-alacena-trattoria
ve_e2c411f7e0~One Star~https://guide.michelin.com/us/en/provincia-mendoza/mendoza_777010/restaurant/zonda-cocina-de-paisaje
ve_e3c65a6b4d~Bib Gourmand~https://guide.michelin.com/us/en/ciudad-autonoma-de-buenos-aires/buenos-aires_777009/restaurant/ajo-negro-mar-de-tapas
ve_f3d370f518~One Star~https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/hakkasan-514821$plan$;
  nw text := $plan$ve_1aa93c684f~vesta~tallinn~ci_5b3f332b80~Tallinn~Estonia~Vesta
ve_38dee4b5fe~mn-santa-ines~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~MN Santa Inés
ve_39db3a14e9~centauro~mendoza~ci_cfcd7931ab~Mendoza~Argentina~Centauro
ve_48611c89d7~bis-bistro~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Bis Bistró
ve_5aaa1b2409~cal-gastronomia-viva~mendoza~ci_cfcd7931ab~Mendoza~Argentina~Cal - Gastronomía Viva
ve_60bc7f7623~reliquia~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Reliquia
ve_61c19195c5~garabato-bistro~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Garabato Bistro
ve_686120991a~acido~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Ácido
ve_68c96f306c~fume~tallinn~ci_5b3f332b80~Tallinn~Estonia~FUME
ve_8318719674~caseros~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Caseros
ve_86d26ed855~han~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Han
ve_a968fed555~la-vida~mendoza~ci_cfcd7931ab~Mendoza~Argentina~La VidA
ve_cdd176b0ae~chuchu~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Chuchú
ve_dda5b49090~la-alacena-trattoria~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~La Alacena Trattoria
ve_e3c65a6b4d~ajo-negro-mar-de-tapas~buenos-aires~ci_087a90256e~Buenos Aires~Argentina~Ajo Negro - Mar de Tapas$plan$;
  n bigint; s text; fp text; first_award bigint; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'd592465e2ed6e724a5fa5c9d6fe911bd' OR md5(aw) <> '1b4c6180b32fc03b079a8525c40685ed' OR md5(nw) <> 'bb99d9adf73619bd6e530ae155f6f6af' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND (c.country_iso IN ('AR','CZ','EE') OR c.id='ci_e1cf943b49')) y;
  IF fp IS DISTINCT FROM 'dfc428c3d44a9027018a076bf3381a1d' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND (c.country_iso IN ('AR','CZ','EE') OR c.id='ci_e1cf943b49')) <> 58 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11797 OR (SELECT count(*) FROM venues WHERE status='active') <> 11479 OR (SELECT count(*) FROM venues WHERE status='closed') <> 318 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28929 OR (SELECT max(id) FROM awards) <> 36100 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4218 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7659 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13741 OR (SELECT count(*) FROM listings) <> 11797 OR (SELECT count(*) FROM city_label_source) <> 25001 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3335 OR (SELECT sum(venues_count) FROM cities) <> 11479 OR (SELECT venues_count FROM cities WHERE id='ci_5b3f332b80') <> 11 OR (SELECT venues_count FROM cities WHERE id='ci_087a90256e') <> 43 OR (SELECT venues_count FROM cities WHERE id='ci_cfcd7931ab') <> 8 OR (SELECT count(*) FROM source_capture_ledger) <> 299 OR (SELECT max(id) FROM source_capture_ledger) <> 353 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 128438 OR u2 <> 134267 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE EXISTS (SELECT 1 FROM awards a WHERE a.venue_id=split_part(x,'~',1) AND a.source_id='michelin' AND a.year=2026);
  IF n <> 0 THEN RAISE EXCEPTION 'venue already has 2026 %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x) OR a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',7)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
  UPDATE awards a SET year=2026, source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 39 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',7), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 15 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 15 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 15 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=13 WHERE id='ci_5b3f332b80' AND venues_count=11; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city tallinn'; END IF;
  UPDATE cities SET venues_count=53 WHERE id='ci_087a90256e' AND venues_count=43; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city buenos-aires'; END IF;
  UPDATE cities SET venues_count=11 WHERE id='ci_cfcd7931ab' AND venues_count=8; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city mendoza'; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),(split_part(x,'~',6),'country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 30 THEN RAISE EXCEPTION 'labels %', n; END IF;
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2026, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 37 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',12,'relabel:load-michelin-2026-a3-2026-11-06 | rule 2.1.7: Abu Dhabi edition live at capture = 2026 (Oct 23, 2025, https://guide.michelin.com/ae-az/en/article/michelin-guide-ceremony/just-unveiled-the-michelin-guide-abu-dhabi-2026) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | award 9205 Goldfish: card gone, no capture, article URL names it | relay sha256 f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45 | Ben choices 1-9:A, Nov 6 08:43 ET'),
    ('michelin','award',27,'relabel:load-michelin-2026-a3-2026-11-06 | rule 2.1.7: Czechia edition live at capture (Dec 11, 2025, https://guide.michelin.com/cz/en/article/michelin-guide-ceremony/czechia-the-full-list-of-michelin-starred-restaurants): article says 2025, cards say 2026, label set to the card | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | award 13039 Perk: card gone, archive capture Dec 21, 2025 | relay sha256 f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45 | Ben choices 1-9:A, Nov 6 08:43 ET'),
    ('michelin','award',1,'cleanup:load-michelin-2026-a3-2026-11-06 | Abu Dhabi 2026, Oct 23, 2025, https://guide.michelin.com/ae-az/en/article/michelin-guide-ceremony/just-unveiled-the-michelin-guide-abu-dhabi-2026 | One Star Hakkasan, missing from the capture, venue exists | Ben choices 1-9:A, Nov 6 08:43 ET'),
    ('michelin','award',11,'cleanup:load-michelin-2026-a3-2026-11-06 | rule 2.1.1 and 2.1.7: Estonia 2026, May 19, 2026, https://guide.michelin.com/ee/en/article/michelin-guide-ceremony/all-the-winners-in-the-michelin-guide-estonia-2026-new-stars-bib-gourmands-special-awards | capture holds the 2025 edition (Jun 19, 2025), 2025 rows stay, relabel 0 | Two Stars 1, One Star 1, Bib 9 | relay sha256 f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45 | Ben choices 1-9:A, Nov 6 08:43 ET'),
    ('michelin','award',25,'cleanup:load-michelin-2026-a3-2026-11-06 | rule 2.1.1 and 2.1.7: Argentina 2026, Jul 13, 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-newly-starred-restaurants-in-buenos-aires-and-mendoza | after the capture window, 2025 rows stay, relabel 0 | Two Stars 1, One Star 13, Bib 11 | relay sha256 f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45 | Ben choices 1-9:A, Nov 6 08:43 ET'),
    ('michelin','city_label',30,'cleanup:load-michelin-2026-a3-2026-11-06 | city labels of 15 new venues (Buenos Aires 10, Mendoza 3, Tallinn 2) | Ben choices 1-9:A, Nov 6 08:43 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11812 OR (SELECT count(*) FROM venues WHERE status='active') <> 11494 OR (SELECT count(*) FROM venues WHERE status='closed') <> 318 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28966 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 37 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '1b4c6180b32fc03b079a8525c40685ed' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7735 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND (c.country_iso IN ('AR','CZ','EE') OR c.id='ci_e1cf943b49') GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2025:Bib Gourmand=7,2025:One Star=10,2025:Two Stars=2,2026:Bib Gourmand=48,2026:One Star=25,2026:Two Stars=3' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, u1, u2 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND (c.country_iso IN ('AR','CZ','EE') OR c.id='ci_e1cf943b49');
  IF n <> 76 OR u1 <> 76 OR u2 <> 76 THEN RAISE EXCEPTION 'urls after % % %', n, u1, u2; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND (c.country_iso IN ('AR','CZ','EE') OR c.id='ci_e1cf943b49') GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13756 OR (SELECT count(*) FROM listings) <> 11812 OR (SELECT count(*) FROM city_label_source) <> 25031 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3335 OR (SELECT sum(venues_count) FROM cities) <> 11494 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 305 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134267 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=37,awards:UPDATE=39,cities:UPDATE=3,city_label_source:INSERT=30,listings:INSERT=15,slugs:INSERT=15,venues:INSERT=15' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
