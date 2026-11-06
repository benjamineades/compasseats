-- load-michelin-2026-canada-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Canada, 3 guides. Ben choices 1-8 A, Nov 5 2026 21:32 ET. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7, per guide:
-- Quebec: ceremony May 6, 2026, before the capture window (https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-quebec-for-2026-and-the-year-s-key-trends). The 36 legacy rows hold the 2026 edition. Relabel 36 rows 2025 -> 2026, source_url = the card (/us/en/). Retire 0.
-- Toronto & Region: ceremony Sep 22, 2026, after June 1 (https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-toronto-region-for-2026). The 43 legacy rows hold the 2025 edition and stay as 2025. 46 new rows, year 2026.
-- Vancouver: ceremony Oct 6, 2026, after June 1 (https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-vancouver-for-2026). The 27 legacy rows hold the 2025 edition and stay as 2025. 27 new rows, year 2026.
-- 7 new venues, card name, restaurant, active, published. RPM Bakehouse (card city Jordan) goes in Lincoln, as the alias "jordan station" does. Les Incompetents (card city St. Catharines) goes in Saint Catharines.
-- Closed: Fable Kitchen, status closed, published false (https://dailyhive.com/vancouver/fable-kitchen-vancouver-2026). Award row and slug stay.
-- Source: docs/michelin-2026-canada-2026-11-05/relay-ca-2026-list-pages-2026-11-05.txt sha256 cddbbd98fa74dab4268d4cacb4e0a6d9858ad894a9d5eee5259b022b60adafa3.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11698 (active 11390, closed 308); awards 28592; slugs 13642; listings 11698; labels 24803; cities 3321, sum 11390; ledger 268 rows; Michelin 2025/2026/2027 4447/7299/122; audit_log +150.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$2851|ve_443da5bf6f|Two Stars|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/taniere
6621|ve_c21f506fe9|One Star|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/hoogan-et-beaufort
6622|ve_9a5fc5a478|One Star|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/jerome-ferrer-europea
6623|ve_ab4f160bc9|One Star|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/mastard
6625|ve_0b49d36ca6|One Star|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/sabayon
6627|ve_9782e31af1|One Star|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/sushi-nishinokaze
7507|ve_9fc9478b68|One Star|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/arvi
7508|ve_f6bd4271be|One Star|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/kebec-club-prive
7509|ve_0240c86817|One Star|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/laurie-raphael
7510|ve_1f7aadbfff|One Star|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/le-clan
7511|ve_b9b893ade5|One Star|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/legende
7572|ve_f255e32faa|One Star|https://guide.michelin.com/us/en/quebec/rimouski_2986917/restaurant/narval
7709|ve_49ad9513d3|One Star|https://guide.michelin.com/us/en/quebec/saint-mathieu-du-parc_2434226/restaurant/auberge-saint-mathieu
9386|ve_825a08608d|Bib Gourmand|https://guide.michelin.com/us/en/quebec/baie-saint-paul_2433987/restaurant/buvette-gentille
10083|ve_34e6c7d459|Bib Gourmand|https://guide.michelin.com/us/en/quebec/drummondville_2434606/restaurant/bibine-buvette
10700|ve_2539c833f4|Bib Gourmand|https://guide.michelin.com/us/en/quebec/kamouraska_2986670/restaurant/cote-est
11237|ve_fb57673047|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/annette-bar-a-vin
11238|ve_d5de99de2a|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/cadet-1218284
11239|ve_3e6e6ac26a|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/casavant
11240|ve_12dda1d3e0|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/le-petit-alep
11241|ve_75c8b8bbf9|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/limbo
11242|ve_8123febfee|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/parapluie-1216819
11243|ve_ddf48c1b76|Bib Gourmand|https://guide.michelin.com/us/en/quebec/montreal_2433514/restaurant/rotisserie-la-lune
11707|ve_59ded0d1f8|Bib Gourmand|https://guide.michelin.com/us/en/quebec/piedmont_2433540/restaurant/baumier
11792|ve_925de5d611|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/battuto
11793|ve_b15194cc68|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/bistro-b-1215948
11794|ve_82d27db7bb|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/buvette-scott
11795|ve_430031fb39|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/hono-izakaya
11796|ve_4c2b5d1904|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/le-clocher-penche
11797|ve_ef22c812b8|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/lueur
11798|ve_f216403682|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/melba
11799|ve_72503c667d|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/ouroboros
11800|ve_6f413685d3|Bib Gourmand|https://guide.michelin.com/us/en/quebec/quebec_2434166/restaurant/torii-buvette-japonaise
11830|ve_eb2c82682d|Bib Gourmand|https://guide.michelin.com/us/en/quebec/rimouski_2986917/restaurant/losange
11926|ve_f55070939a|Bib Gourmand|https://guide.michelin.com/us/en/quebec/sainte-anne-de-beaupre_2434253/restaurant/coquette
11928|ve_c162984a89|Bib Gourmand|https://guide.michelin.com/us/en/quebec/sainte-marie_2434983/restaurant/saindoux-restaurant-bbq$plan$;
  aw text := $plan$ve_00ef9f0113|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/bb-s
ve_075f814915|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/conejo-negro
ve_108ef51bf4|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/okeya-kyujiro
ve_142644bcab|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/chef-s-choice-chinese-cuisine
ve_1858b87671|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/mhel
ve_1d0d58b780|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/bar-raval
ve_1ee2f24c1d|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/alma-1200445
ve_1f862bbd2a|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/tiflisi
ve_2540ccab0a|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/farmer-s-apprentice
ve_2c33752f07|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/st-lawrence
ve_2df5b9d44b|Two Stars|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/annalena
ve_35134fbb56|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/sunnys-chinese
ve_38b45e4f9e|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/kavita
ve_39715ef838|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/r-d
ve_3dd7dca5aa|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/puerto-bravo
ve_5230f6f33f|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/motonobu-udon
ve_53f1658223|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/edulis
ve_5604e900a5|Bib Gourmand|https://guide.michelin.com/us/en/ontario/jordan_7770321/restaurant/rpm-bakehouse
ve_57d08e541e|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/sumibiyaki-arashi
ve_5b05e05457|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/kaiseki-yu-zen-hashimoto
ve_60557aefdd|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/the-lunch-lady-of-saigon
ve_63a62a738b|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/burdock-co
ve_63b570ba6f|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/sushi-hyun
ve_6654bb51d4|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/vij-s
ve_671992d417|Bib Gourmand|https://guide.michelin.com/us/en/ontario/mississauga_1245409/restaurant/guru-lukshmi
ve_67433802a4|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/grey-gardens
ve_7240c3809f|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/rasa-1200548
ve_7681351bed|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/gary-s
ve_7de075b29a|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/oca-pastificio
ve_7f6b059ce1|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/little-bird-dim-sum-craft-beer
ve_80b7bb0c1c|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/alo
ve_847c1983f8|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/seaport-city-seafood
ve_85833dfbe6|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/shoushin
ve_868be43e83|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/golden-horseshoe-barbecue
ve_8719c0a53d|Bib Gourmand|https://guide.michelin.com/us/en/ontario/dundas_1244982/restaurant/barrel-heart-brewing
ve_9013f1c867|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/chica-s-chicken
ve_919de817cb|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/campechano
ve_940714a4e7|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/good-thief
ve_9787e80ff3|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/antylia
ve_98262d7ccb|Bib Gourmand|https://guide.michelin.com/us/en/ontario/saint-catharines_1245759/restaurant/les-incompetents
ve_9bd6c70b69|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/sushi-masaki-saito
ve_9fcc331be1|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/danico
ve_a28a30edaa|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/kin-kao-song
ve_a7fe602c8e|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/kappo-sato
ve_b31e8f3690|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/indian-street-food-company
ve_b65ef42b07|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/ricky-olivia
ve_bc0aa78c2e|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/sushi-masuda-1214860
ve_bc9efb7b28|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/iden-quanjude-beijing-duck-house
ve_bd5785c5bf|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/sumilicious-smoked-meat-deli
ve_bdf5e77973|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/akin-1212180
ve_bfcac91803|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/phnom-penh
ve_c5c4355a84|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/masayoshi
ve_ccd4d1ec94|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/don-alfonso-1890-toronto
ve_cf9e1d8399|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/cherry-st-bar-b-que
ve_d3187f10ce|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/kissa-tanto
ve_d3bcf64825|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/white-lily-diner
ve_d4d872fb38|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/enigma-yorkville
ve_d595bf1e5c|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/anh-and-chi
ve_d7c0adb34f|Two Stars|https://guide.michelin.com/us/en/ontario/lincoln_1246046/restaurant/restaurant-pearl-morissette
ve_dc116642ee|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/karma-indian-bistro
ve_dd636e9355|One Star|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/published-on-main
ve_e1d7bb6690|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/favorites-thai
ve_e3e5905165|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/the-cottage-cheese
ve_e96f2aab64|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/osteria-giulia
ve_e9e21ec201|One Star|https://guide.michelin.com/us/en/ontario/creemore_1244926/restaurant/the-pine-1209935
ve_eaafd35634|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/the-ace
ve_eeea4c8187|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/quetzal
ve_f4a918e36b|Bib Gourmand|https://guide.michelin.com/us/en/ontario/toronto/restaurant/enoteca-sociale
ve_fbf2d9f536|One Star|https://guide.michelin.com/us/en/ontario/toronto/restaurant/restaurant-20-victoria
ve_fd25bd01e7|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/lunch-lady
ve_fe4e2fa157|Bib Gourmand|https://guide.michelin.com/us/en/british-columbia/ca-vancouver/restaurant/sushi-hil
ve_ff53c3b6e6|Bib Gourmand|https://guide.michelin.com/us/en/ontario/oakville_1245509/restaurant/7-enoteca
ve_ff61f4b92c|Bib Gourmand|https://guide.michelin.com/us/en/ontario/uxbridge_1245859/restaurant/sundays$plan$;
  nw text := $plan$ve_142644bcab|chef-s-choice-seafood-restaurant|vancouver|ci_2ad52028d6|Vancouver|Vancouver|Chef’s Choice Seafood Restaurant
ve_38b45e4f9e|kavita|vancouver|ci_2ad52028d6|Vancouver|Vancouver|Kavita
ve_5604e900a5|rpm-bakehouse|lincoln|ci_aa45997477|Lincoln|Jordan|RPM Bakehouse
ve_60557aefdd|the-lunch-lady-of-saigon|toronto|ci_79cca97018|Toronto|Toronto|The Lunch Lady of Saigon
ve_868be43e83|golden-horseshoe-barbecue|toronto|ci_79cca97018|Toronto|Toronto|Golden Horseshoe Barbecue
ve_9787e80ff3|antylia|toronto|ci_79cca97018|Toronto|Toronto|Antylia
ve_98262d7ccb|les-incompetents|saint-catharines|ci_7dfcecf2b4|Saint Catharines|St. Catharines|Les Incompetents$plan$;
  cl text := $plan$ve_3160c0aec9|Fable Kitchen|active|ci_2ad52028d6$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '22d75277f449e1edaf2bdf92300d88fe' OR md5(aw) <> '619d9acea3b2abb6c39d32373d25f54f' OR md5(nw) <> '4a057dbec8d190e7d054492fa811c9a4' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) y;
  IF fp IS DISTINCT FROM '81195e6d1cf47d1a48ff1d225025fead' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada') <> 106 THEN RAISE EXCEPTION 'Canada Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11691 OR (SELECT count(*) FROM venues WHERE status='active') <> 11384 OR (SELECT count(*) FROM venues WHERE status='closed') <> 307 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28519 OR (SELECT max(id) FROM awards) <> 35690 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4483 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7190 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13635 OR (SELECT count(*) FROM listings) <> 11691 OR (SELECT count(*) FROM city_label_source) <> 24789 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11384 OR (SELECT count(*) FROM source_capture_ledger) <> 265 OR (SELECT max(id) FROM source_capture_ledger) <> 319 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_2ad52028d6') <> 45 OR (SELECT venues_count FROM cities WHERE id='ci_79cca97018') <> 72 OR (SELECT venues_count FROM cities WHERE id='ci_7dfcecf2b4') <> 1 OR (SELECT venues_count FROM cities WHERE id='ci_aa45997477') <> 1 THEN RAISE EXCEPTION 'city counts before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 126938 OR aud_max <> 132767 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) AND v.status='active' AND c.country='Canada');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x UNION ALL SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\n') x UNION ALL SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  SELECT v.id||'|'||v.name||'|'||v.status||'|'||v.city_id INTO s FROM venues v WHERE v.id=split_part(cl,'|',1);
  IF s IS DISTINCT FROM cl THEN RAISE EXCEPTION 'closure %', s; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id=split_part(cl,'|',1) AND published) <> 1 THEN RAISE EXCEPTION 'closure listing'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) OR (c.country='Canada' AND v.norm_key=norm_key(split_part(x,'|',7)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5) AND c.country='Canada');
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel Quebec
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 36 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',7), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows. The label is the card city.
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',6),'city_display'),('Canada','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 73 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: closure
  UPDATE venues SET status='closed' WHERE id=split_part(cl,'|',1) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id=split_part(cl,'|',1) AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=46 WHERE id='ci_2ad52028d6' AND venues_count=45;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_2ad52028d6 %', n; END IF;
  UPDATE cities SET venues_count=75 WHERE id='ci_79cca97018' AND venues_count=72;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_79cca97018 %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_7dfcecf2b4' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_7dfcecf2b4 %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_aa45997477' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_aa45997477 %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',36,'relabel:load-michelin-2026-canada-2026-11-05 | rule 2.1.7: Quebec edition live at capture = 2026 (ceremony May 6, 2026, https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-quebec-for-2026-and-the-year-s-key-trends) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 cddbbd98fa74dab4268d4cacb4e0a6d9858ad894a9d5eee5259b022b60adafa3 | Ben choices 1-8 A, Nov 5 2026 21:32 ET'),
    ('michelin','award',73,'cleanup:load-michelin-2026-canada-2026-11-05 | rule 2.1.1 and 2.1.7: Toronto & Region ceremony Sep 22, 2026 (https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-toronto-region-for-2026), Vancouver ceremony Oct 6, 2026 (https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-vancouver-for-2026), legacy rows hold the 2025 edition, relabel 0, retire 0 | list read Nov 5, 2026 | relay sha256 cddbbd98fa74dab4268d4cacb4e0a6d9858ad894a9d5eee5259b022b60adafa3 | Ben choices 1-8 A, Nov 5 2026 21:32 ET'),
    ('michelin','city_label',14,'cleanup:load-michelin-2026-canada-2026-11-05 | city labels of 7 new venues | Ben choices 1-8 A, Nov 5 2026 21:32 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11698 OR (SELECT count(*) FROM venues WHERE status='active') <> 11390 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28592 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 73 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> md5((SELECT string_agg(x, E'\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4447 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7299 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=70,One Star=36,Two Stars=3' THEN RAISE EXCEPTION 'Canada 2026 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2025 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=41,One Star=28,Two Stars=1' THEN RAISE EXCEPTION 'Canada 2025 %', s; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 109 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13642 OR (SELECT count(*) FROM listings) <> 11698 OR (SELECT count(*) FROM city_label_source) <> 24803 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11390 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 268 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=73,awards:UPDATE=36,cities:UPDATE=4,city_label_source:INSERT=14,listings:INSERT=7,listings:UPDATE=1,slugs:INSERT=7,venues:INSERT=7,venues:UPDATE=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
