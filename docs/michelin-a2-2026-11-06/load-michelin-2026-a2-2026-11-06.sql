-- load-michelin-2026-a2-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin A2: Brazil, Malta, Qatar, Serbia 2026. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Relabel 94 rows 2025 -> 2026 (rule 2.1.7), 92 with the /us/en/ card URL, 1 archive URL (Didier), 1 no URL (Piu Higienopolis). Retire 0.
-- 2 new Bib rows and 2 new venues in Sao Paulo: Taboa Cozinha Artesanal, Peti no MAM.
-- 2 closures: Didier (press, closed Jun 28, 2026), Lasai (card: temporarily closed, relocation; reopening December 2026, recheck). Award rows stay. Slugs stay.
-- Source: docs/michelin-a2-2026-11-06/relay-a2-2026-list-pages-2026-11-06.txt sha256 6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11797 (active 11479, closed 318); awards 28929; slugs 13741; listings 11797; labels 25001; cities 3335, sum 11479; ledger 299 rows; audit_log +112.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1173~ve_72e32dfdf5~Three Stars~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/evvai
1185~ve_164d9e4fc4~Three Stars~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/tuju
2883~ve_dfa308c00a~Two Stars~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/lasai
2896~ve_a1852a622b~Two Stars~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/oro
3217~ve_a9cf86ec4d~Two Stars~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/d-o-m
3462~ve_373bb68723~Two Stars~https://guide.michelin.com/us/en/malta-south-eastern-region/valletta/restaurant/ion-the-harbour
4127~ve_33c924ca48~One Star~https://guide.michelin.com/us/en/belgrade-region/belgrade/restaurant/langouste
4757~ve_79f91198a4~One Star~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/alba-1213877
4760~ve_8627607527~One Star~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/idam-by-alain-ducasse
4762~ve_2d2bcdc8be~One Star~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/jamavar-1197472
6458~ve_14fb4690c9~One Star~https://guide.michelin.com/us/en/malta-northern-region/mdina/restaurant/de-mondion
6944~ve_60863491c7~One Star~https://guide.michelin.com/us/en/syrmia/novi-slankamen_7770386/restaurant/fleur-de-sel-1212486
7573~ve_f8e6aa9e90~One Star~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/casa-201
7575~ve_8b9afd43ea~One Star~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/madame-olympe
7576~ve_5e5b8e2f93~One Star~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/mee
7577~ve_456d74e80c~One Star~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/oseille
7580~ve_a913beb4fa~One Star~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/oteque
7594~ve_9371b16a9c~One Star~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/san-omakase-room
8241~ve_24191bc2ae~One Star~https://guide.michelin.com/us/en/malta-northern-region/sliema/restaurant/fernando-gastrotheque
8242~ve_b37d29a671~One Star~https://guide.michelin.com/us/en/malta-northern-region/sliema/restaurant/le-gv
8266~ve_a9bfb8812e~One Star~https://guide.michelin.com/us/en/malta-central-region/st-julian-s/restaurant/rosami
8343~ve_cf5567ee42~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/fame-osteria
8347~ve_e410d6a003~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/jun-sakamoto
8351~ve_e79c71e66d~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kan-suke
8354~ve_5c41cdc803~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kanoe
8356~ve_169947e477~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kazuo
8359~ve_d56d381b6a~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kinoshita
8360~ve_20799ee8b2~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kuro
8370~ve_db6835ff43~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/mani
8376~ve_6873c5e900~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/murakami
8377~ve_2165ca414c~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/oizumi-sushi
8378~ve_091d050268~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/picchi
8379~ve_ef28dd0821~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/ryo-gastronomia
8380~ve_80a0782b77~One Star~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/tangara-jean-georges
8826~ve_fd0e8d9bab~One Star~https://guide.michelin.com/us/en/malta-south-eastern-region/valletta/restaurant/noni
8828~ve_e4a5a2fde0~One Star~https://guide.michelin.com/us/en/malta-south-eastern-region/valletta/restaurant/under-grain
9483~ve_e4d67c41ae~Bib Gourmand~https://guide.michelin.com/us/en/belgrade-region/belgrade/restaurant/bela-reka
9484~ve_d60e864dcf~Bib Gourmand~https://guide.michelin.com/us/en/belgrade-region/belgrade/restaurant/istok
9485~ve_6e1ccfb132~Bib Gourmand~https://guide.michelin.com/us/en/belgrade-region/belgrade/restaurant/iva-new-balkan-cuisine
10063~ve_45008f97c7~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/argan
10064~ve_3b8c78a9f9~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/baron
10065~ve_3596a7aa8f~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/berenjak-al-maha-island
10066~ve_cb064b5372~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/fenyal
10067~ve_06a50f2165~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/hoppers-1206059
10068~ve_73851bd35c~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/isaan
10069~ve_c997d60acb~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/jiwan
10070~ve_d455f4afc9~Bib Gourmand~https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/mila-1243026
10372~ve_be4d3ae1c0~Bib Gourmand~https://guide.michelin.com/us/en/malta-central-region/gira/restaurant/ayu
11154~ve_9aef1006b3~Bib Gourmand~https://guide.michelin.com/us/en/malta-northern-region/melliea/restaurant/commando
11161~ve_e641663972~Bib Gourmand~https://guide.michelin.com/us/en/malta-northern-region/marr/restaurant/verbena
11831~ve_832f8ac3d4~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/artigiano
11832~ve_aad1f0be42~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/brota
11833~ve_99f41235da~Bib Gourmand~https://web.archive.org/web/20260712091053id_/https://guide.michelin.com/es/es/rio-de-janeiro-region/rio-de-janeiro/restaurante/didier
11834~ve_a3161c988d~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/koral
11835~ve_779f32c5c6~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/maria-e-o-boi
11836~ve_775449eafb~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/miam-miam
11837~ve_edeab52f5d~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/pici-trattoria
11838~ve_a9b5e91e52~Bib Gourmand~https://guide.michelin.com/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/sult
12336~ve_d50e71fba4~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/a-baianeira-masp
12346~ve_b8d05bb5fd~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/a-casa-do-porco
12354~ve_962d427bd4~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/ae-cozinha
12355~ve_149a7d280a~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/balaio-ims
12356~ve_550d8cc585~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/banzeiro
12357~ve_922fbd97e1~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/baru-marisqueria
12358~ve_18dcd4cf51~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/brasserie-victoria
12359~ve_eba52c0cfa~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/capim-santo
12360~ve_f949dd0f26~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/cepa
12362~ve_79d8ce5b75~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/clandestina
12363~ve_5fce35ac81~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/cora-1210174
12364~ve_c14d62645c~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/corrutela
12369~ve_2908ed9b18~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/cuia
12370~ve_a51e12476b~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/ecully-perdizes
12371~ve_139fb793be~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/fito
12372~ve_f94f54acea~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/jaco-1212676
12373~ve_4169766097~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/jiquitaia-1190078
12374~ve_5e0e0564a6~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/komah
12377~ve_d0a95b78e4~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kotori
12382~ve_a1715198b5~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/le-bife
12383~ve_f43f2059d1~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/manioca
12384~ve_01b9dd7661~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/manioca-da-mata
12385~ve_e3af36a8d7~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/manioca-jk
12386~ve_715ea6fbc6~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/mocoto-vila-leopoldina
12392~ve_4898647fdf~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/mocoto
12395~ve_1d1485a18e~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/nomo
12396~ve_aab432c9c4~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/ping-yang-thai-bar-food
12397~ve_195c01f75c~Bib Gourmand~
12398~ve_17a43e2120~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/piu
12399~ve_1bd996d675~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/shihoma-pasta-fresca
12400~ve_c6606378d5~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/tanit
12401~ve_958b322247~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/kith-2%C2%BA-andar
12402~ve_eec52d5553~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/tordesilhas
12405~ve_ad2b46ef0a~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/zena-caffe
12789~ve_1ac631cc5b~Bib Gourmand~https://guide.michelin.com/us/en/malta-south-eastern-region/valletta/restaurant/grain-street
12790~ve_86af80f753~Bib Gourmand~https://guide.michelin.com/us/en/malta-south-eastern-region/valletta/restaurant/rubino$plan$;
  aw text := $plan$ve_5fda7f9a22~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/taboa-cozinha-artesanal
ve_8d1d7b9493~Bib Gourmand~https://guide.michelin.com/us/en/sao-paulo-region/sao-paulo/restaurant/peti-gastronomia$plan$;
  nw text := $plan$ve_5fda7f9a22~taboa-cozinha-artesanal~sao-paulo~ci_7d2b023f60~São Paulo~Tabōa Cozinha Artesanal
ve_8d1d7b9493~peti-no-mam~sao-paulo~ci_7d2b023f60~São Paulo~Petí no MAM$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint; ids text[] := ARRAY['ve_99f41235da','ve_dfa308c00a'];
BEGIN
  -- PRE gates
  IF md5(rl) <> '8d436450aea169db4d93b90af5e04a0b' OR md5(aw) <> '98c70ced04501ea6a4351b8374b2ecab' OR md5(nw) <> '1bc80908d7469c7dbbb0b0856f738e0e' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country_iso IN ('BR','MT','QA','RS')) y;
  IF fp IS DISTINCT FROM '2c423b61e00bee5f9806ccee194a1424' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('BR','MT','QA','RS')) <> 94 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id = ANY(ids)) IS DISTINCT FROM '8ee1738ca8e7dc3dd3cf0601be76867b' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = ANY(ids) AND published) <> 2 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11795 OR (SELECT count(*) FROM venues WHERE status='active') <> 11479 OR (SELECT count(*) FROM venues WHERE status='closed') <> 316 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28927 OR (SELECT max(id) FROM awards) <> 36098 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4312 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7563 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13739 OR (SELECT count(*) FROM listings) <> 11795 OR (SELECT count(*) FROM city_label_source) <> 24997 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3335 OR (SELECT sum(venues_count) FROM cities) <> 11479 OR (SELECT venues_count FROM cities WHERE id='ci_7d2b023f60') <> 71 OR (SELECT venues_count FROM cities WHERE id='ci_a7418b493c') <> 22 OR (SELECT count(*) FROM source_capture_ledger) <> 293 OR (SELECT max(id) FROM source_capture_ledger) <> 347 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 128326 OR aud_max <> 134155 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE split_part(x,'~',4)<>'') OR a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',6)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
  UPDATE awards a SET year=2026, source_url=NULLIF(split_part(x,'~',4),'') FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 94 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',6), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),('Brazil','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'labels %', n; END IF;
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2026, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: closures
  UPDATE venues SET status='closed' WHERE id = ANY(ids) AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'closures %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id = ANY(ids) AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'unpublish %', n; END IF;
  UPDATE cities SET venues_count=73 WHERE id='ci_7d2b023f60' AND venues_count=71; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'sao paulo'; END IF;
  UPDATE cities SET venues_count=20 WHERE id='ci_a7418b493c' AND venues_count=22; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rio'; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',66,'relabel:load-michelin-2026-a2-2026-11-06 | rule 2.1.7: Brazil (Rio de Janeiro & Sao Paulo) edition live at capture = 2026 (Apr 13, 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/brazil-restaurants-three-michelin-stars) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | award 11833 Didier: archive capture Jul 12, 2026, card gone, 12397 Piu Higienopolis: no 2026 capture, no URL, named in the 2026 list by CNN Brasil Apr 14, 2026 | relay sha256 6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796 | DRAFT, choices not yet given'),
    ('michelin','award',12,'relabel:load-michelin-2026-a2-2026-11-06 | rule 2.1.7: Malta edition live at capture = 2026 (Feb 17, 2026, https://guide.michelin.com/mt/en/article/michelin-guide-ceremony/the-michelin-guide-malta-2026-is-launched-today) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796 | DRAFT, choices not yet given'),
    ('michelin','award',11,'relabel:load-michelin-2026-a2-2026-11-06 | rule 2.1.7: Qatar (Doha) edition live at capture = 2026 (Dec 9, 2025, https://guide.michelin.com/qa/en/article/michelin-guide-ceremony/full-list-michelin-guide-doha-selection) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796 | DRAFT, choices not yet given'),
    ('michelin','award',5,'relabel:load-michelin-2026-a2-2026-11-06 | rule 2.1.7: Serbia (Belgrade) edition live at capture = 2026 (Dec 10, 2025, https://guide.michelin.com/rs/en/article/michelin-guide-ceremony/michelin-guide-belgrade-2026-celebrates-growth-and-culinary-excellence) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796 | DRAFT, choices not yet given'),
    ('michelin','award',2,'cleanup:load-michelin-2026-a2-2026-11-06 | Brazil 2026, Apr 13, 2026 | Bib 2 missing from the capture: Taboa Cozinha Artesanal, Peti no MAM (Peti Gastronomia in the 2026 list) | 2 new venues | DRAFT, choices not yet given'),
    ('michelin','city_label',4,'cleanup:load-michelin-2026-a2-2026-11-06 | city labels of 2 new venues, Sao Paulo | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11797 OR (SELECT count(*) FROM venues WHERE status='active') <> 11479 OR (SELECT count(*) FROM venues WHERE status='closed') <> 318 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28929 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 2 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '98c70ced04501ea6a4351b8374b2ecab' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4218 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7659 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('BR','MT','QA','RS') GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2026:Bib Gourmand=60,2026:One Star=30,2026:Three Stars=2,2026:Two Stars=4' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, first_award, aud_max FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('BR','MT','QA','RS');
  IF n <> 96 OR first_award <> 95 OR aud_max <> 95 THEN RAISE EXCEPTION 'urls after % % %', n, first_award, aud_max; END IF;
  IF (SELECT count(*) FROM slugs) <> 13741 OR (SELECT count(*) FROM listings) <> 11797 OR (SELECT count(*) FROM city_label_source) <> 25001 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3335 OR (SELECT sum(venues_count) FROM cities) <> 11479 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 299 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT max(id) INTO aud_max FROM audit_log;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134155 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=2,awards:UPDATE=94,cities:UPDATE=2,city_label_source:INSERT=4,listings:INSERT=2,listings:UPDATE=2,slugs:INSERT=2,venues:INSERT=2,venues:UPDATE=2' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
