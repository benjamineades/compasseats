-- load-michelin-2026-b-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group B: Poland, Croatia, Slovenia 2026. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 86 new 2026 rows (Poland 45, Croatia 22, Slovenia 19), /us/en/ card URL. 5 rows already labelled 2026 get the card URL. 8 sourced rows checked, no change. Legacy 2025 rows stay. Relabel 0. Retire 0.
-- 19 new venues and 9 new cities, all Poland.
-- Source: docs/michelin-b-2026-11-06/relay-b-2026-list-pages-2026-11-06.txt sha256 69dca933c4a4070625876a5f28565efe09aa89663a09feb7b63a34d09dbc36d5.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11831 (active 11513, closed 318); awards 29052; slugs 13775; listings 11831; labels 25069; cities 3344, sum 11513; ledger 309 rows; audit_log +200.
BEGIN;
DO $load$
DECLARE
  ul text := $plan$2925~ve_557b114bfd~Two Stars~https://guide.michelin.com/us/en/istria/rovinj/restaurant/agli-amici-rovinj
8089~ve_d4eadf0bd3~One Star~https://guide.michelin.com/us/en/sibenik-knin/sibenik/restaurant/pelegrini
12964~ve_321c00c095~One Star~https://guide.michelin.com/us/en/lower-silesian/wroclaw_2399695/restaurant/baba-1219184
21170~ve_44dd0ee127~One Star~https://guide.michelin.com/us/en/savinja/petrovce/restaurant/galerija-okusov
21171~ve_40e788bc57~Bib Gourmand~https://guide.michelin.com/us/en/gorizia/medana_7770441/restaurant/klinec$plan$;
  xl text := $plan$21048~ve_71d26b9cb5~One Star~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/alon-omakase
21049~ve_00d8a2d2b6~One Star~https://guide.michelin.com/us/en/lower-silesian/wroclaw_2399695/restaurant/most
21050~ve_9f50697f1f~One Star~https://guide.michelin.com/us/en/silesia/pszczyna_2382223/restaurant/steampunk
21172~ve_b9249cb9cb~Bib Gourmand~https://guide.michelin.com/us/en/savinja/celje/restaurant/gostilna-francl
21173~ve_edecaf0478~One Star~https://guide.michelin.com/us/en/istria/porec/restaurant/harry-s-piccolo-porec
21174~ve_c7ded05de6~Bib Gourmand~https://guide.michelin.com/us/en/osijek-baranja/dakovo_1784403/restaurant/bistro-loora
21175~ve_f3378b4564~Bib Gourmand~https://guide.michelin.com/us/en/osijek-baranja/osijek/restaurant/lulu-fusion-bistro
21176~ve_23c9c842a2~Bib Gourmand~https://guide.michelin.com/us/en/zagreb-region/zagreb/restaurant/nure$plan$;
  aw text := $plan$ve_004d840d0c~Bib Gourmand~https://guide.michelin.com/us/en/podlaskie/bialystok_2401507/restaurant/kwestia-czasu-nago
ve_09cd1a520f~Bib Gourmand~https://guide.michelin.com/us/en/podlaskie/rzeszow_2367318/restaurant/naama
ve_0e9f819ada~Bib Gourmand~https://guide.michelin.com/us/en/dubrovnik-neretva/korcula/restaurant/konoba-mate
ve_0f072a7818~Three Stars~https://guide.michelin.com/us/en/gorizia/kobarid/restaurant/hisa-franko
ve_0f96ebd61e~Bib Gourmand~https://guide.michelin.com/us/en/lodz-region/lodz_2386189/restaurant/acanti
ve_0f9dcb7ce8~One Star~https://guide.michelin.com/us/en/zagreb-region/jastrebarsko_1779514/restaurant/korak
ve_0fb26d6a92~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/krakow/restaurant/molam
ve_0fb769627e~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/win-wine-bar-shop
ve_1064e8559c~Bib Gourmand~https://guide.michelin.com/us/en/silesia/katowice_2377909/restaurant/krzywa-sztuka-wina
ve_1968a4d3c2~Bib Gourmand~https://guide.michelin.com/us/en/savinja/celje/restaurant/lalu-bistro
ve_1a70ff6b74~Bib Gourmand~https://guide.michelin.com/us/en/gorizia/idrija/restaurant/jozef
ve_1c6c61d7b4~Bib Gourmand~https://guide.michelin.com/us/en/split-dalmatia/split/restaurant/k-uzina
ve_2054ae216d~Bib Gourmand~https://guide.michelin.com/us/en/lublin-region/lublin_2361556/restaurant/2pier
ve_209c59814e~One Star~https://guide.michelin.com/us/en/primorje-gorski-kotar/rijeka/restaurant/nebo
ve_2469bad7a5~One Star~https://guide.michelin.com/us/en/lika-senj/novalja/restaurant/boskinac
ve_2f264a0bf6~One Star~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/rozbrat-20
ve_319b291669~Bib Gourmand~https://guide.michelin.com/us/en/zagreb-region/zagreb/restaurant/bestija
ve_33fa847e2a~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/le-braci
ve_3c7265bce1~One Star~https://guide.michelin.com/us/en/gorizia/vipava/restaurant/pri-lojzetu
ve_3d9f14819e~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/kielce_2358496/restaurant/the-moment
ve_3e99e6d438~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/ahaan
ve_3f83fe7750~Bib Gourmand~https://guide.michelin.com/us/en/coastal%E2%80%93karst/divaca/restaurant/etna
ve_40405748a5~Bib Gourmand~https://guide.michelin.com/us/en/wielkopolskie/poznan_2395985/restaurant/spot
ve_45eccd6bba~Bib Gourmand~https://guide.michelin.com/us/en/wielkopolskie/skorzewo_2397439/restaurant/farmer-sons
ve_4786d9d0b0~Bib Gourmand~https://guide.michelin.com/us/en/pomerania/sopot_2411807/restaurant/vinissimo
ve_498e434f24~Bib Gourmand~https://guide.michelin.com/us/en/sibenik-knin/konjevrate/restaurant/konoba-vinko
ve_4dd82462e8~One Star~https://guide.michelin.com/us/en/wielkopolskie/poznan_2395985/restaurant/muga
ve_4fb62bdf02~Bib Gourmand~https://guide.michelin.com/us/en/zagreb-region/zagreb/restaurant/izakaya-by-time
ve_53628a4a44~Bib Gourmand~https://guide.michelin.com/us/en/mura/murska-sobota/restaurant/rajh
ve_5d994223ad~Bib Gourmand~https://guide.michelin.com/us/en/upper-carniola/gozd-martuljek_7770292/restaurant/triangel
ve_63c6bd3237~One Star~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/hub-praga
ve_6d4792efb2~Bib Gourmand~https://guide.michelin.com/us/en/gorizia/dobrovo-v-brdih/restaurant/gredic
ve_705faf733a~One Star~https://guide.michelin.com/us/en/upper-carniola/radovljica/restaurant/hisa-linhart
ve_712fd39ff8~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/krakow/restaurant/noah
ve_7d7c043f13~One Star~https://guide.michelin.com/us/en/dubrovnik-neretva/dubrovnik/restaurant/360%C2%BA
ve_7ebc3d3427~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/wandal
ve_7ecf71c263~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/wyraj
ve_7f248ad343~Bib Gourmand~https://guide.michelin.com/us/en/coastal%E2%80%93karst/rodik/restaurant/mahorcic
ve_80b6916ead~Bib Gourmand~https://guide.michelin.com/us/en/pomerania/gdansk_2403599/restaurant/brut-bistro
ve_814c70a95c~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/blisko-bar
ve_82320b2e5b~One Star~https://guide.michelin.com/us/en/istria/rovinj/restaurant/monte
ve_854eee0d22~One Star~https://guide.michelin.com/us/en/coastal%E2%80%93karst/portoroz/restaurant/cob
ve_891390df7e~One Star~https://guide.michelin.com/us/en/drava/zgornja-kungota/restaurant/hisa-denk
ve_8cf2bd7a7d~Bib Gourmand~https://guide.michelin.com/us/en/wielkopolskie/poznan_2395985/restaurant/tu-restaurant
ve_8dcfc55059~One Star~https://guide.michelin.com/us/en/istria/rovinj/restaurant/cap-aureo
ve_8f3b3e3a44~Bib Gourmand~https://guide.michelin.com/us/en/pomerania/gdansk_2403599/restaurant/treinta-y-tres
ve_8fe63287e4~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/krakow/restaurant/bufet-krk
ve_9403faf514~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/kontakt
ve_9b981764b6~Bib Gourmand~https://guide.michelin.com/us/en/lower-silesian/wroclaw_2399695/restaurant/ida-kuchnia-i-wino
ve_9bf981b8d2~One Star~https://guide.michelin.com/us/en/split-dalmatia/split/restaurant/krug
ve_9dbfc286ba~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/zakopane_2385511/restaurant/stary-niedzwiedz
ve_9f42ad0554~One Star~https://guide.michelin.com/us/en/zagreb-region/zagreb/restaurant/dubravkin-put
ve_a399839329~Two Stars~https://guide.michelin.com/us/en/upper-carniola/kranjska-gora/restaurant/milka
ve_a6f2cd7042~Bib Gourmand~https://guide.michelin.com/us/en/lower-silesian/wroclaw_2399695/restaurant/pijalni
ve_a6fefc4896~Bib Gourmand~https://guide.michelin.com/us/en/istria/valbandon/restaurant/alla-beccaccia
ve_a8c75a8e75~Bib Gourmand~https://guide.michelin.com/us/en/dolnoslaskie/walbrzych_2399184/restaurant/biblioteka
ve_b45ab55c9e~Bib Gourmand~https://guide.michelin.com/us/en/istria/buje/restaurant/konoba-malo-selo
ve_b8818ce290~Bib Gourmand~https://guide.michelin.com/us/en/wielkopolskie/poznan_2395985/restaurant/fromazeria
ve_ba7ad8f326~Bib Gourmand~https://guide.michelin.com/us/en/warmia-masuria/olsztyn_2409296/restaurant/da-andrea-1248066
ve_bfb315bcf6~Two Stars~https://guide.michelin.com/us/en/lesser-poland/krakow/restaurant/bottiglieria-1881
ve_bfd9b0e0b0~One Star~https://guide.michelin.com/us/en/lower-carniola/sentjost-nad-horjulom/restaurant/gostisce-gric
ve_c012be71d2~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/kieliszki-na-proznej
ve_c2c970bb0e~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/krakow/restaurant/nat-bistro
ve_c43fdbf96e~Bib Gourmand~https://guide.michelin.com/us/en/podlaskie/bialystok_2401507/restaurant/sztuka-chleba-i-wina
ve_c4dd0404fa~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/koneser-grill
ve_caf934eb20~Bib Gourmand~https://guide.michelin.com/us/en/lesser-poland/krakow/restaurant/folga
ve_cff170dada~Bib Gourmand~https://guide.michelin.com/us/en/coastal%E2%80%93karst/dol-pri-vogljah/restaurant/ruj
ve_d0274f64c7~Bib Gourmand~https://guide.michelin.com/us/en/upper-carniola/stara-fuzina_7770293/restaurant/restavracija-majerca
ve_d114a19d4e~Bib Gourmand~https://guide.michelin.com/us/en/pomerania/torun_2398786/restaurant/piernicova
ve_d2518b1b2c~One Star~https://guide.michelin.com/us/en/zagreb-region/zagreb/restaurant/noel
ve_d7419b951d~One Star~https://guide.michelin.com/us/en/dubrovnik-neretva/korcula/restaurant/ld-terrace
ve_dc6527692c~Bib Gourmand~https://guide.michelin.com/us/en/primorje-gorski-kotar/moscenicka-draga/restaurant/konoba-pescaria
ve_dd7b89e2b7~Bib Gourmand~https://guide.michelin.com/us/en/krapina-zagorje/krapina/restaurant/vuglec-breg
ve_e14df75660~Bib Gourmand~https://guide.michelin.com/us/en/dubrovnik-neretva/dubrovnik/restaurant/taj-mahal
ve_e44f58332b~One Star~https://guide.michelin.com/us/en/savinja/lasko/restaurant/pavus
ve_e4b0c2a3c1~Bib Gourmand~https://guide.michelin.com/us/en/koprivnica-krizevci/legrad_1780426/restaurant/fakin
ve_e6b88aa6f3~Bib Gourmand~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/ceviche-bar
ve_e71ebb1f5f~One Star~https://guide.michelin.com/us/en/masovia/warsaw/restaurant/nuta
ve_e8f635bf11~One Star~https://guide.michelin.com/us/en/primorje-gorski-kotar/mali-losinj/restaurant/alfred-keller
ve_e96d006b1c~Bib Gourmand~https://guide.michelin.com/us/en/wielkopolskie/poznan_2395985/restaurant/posto
ve_f0d2217bbe~One Star~https://guide.michelin.com/us/en/lesser-poland/koscielisko_2378757/restaurant/giewont
ve_f3809e085a~Bib Gourmand~https://guide.michelin.com/us/en/mura/murska-sobota/restaurant/kodila
ve_f5c83ada0c~Bib Gourmand~https://guide.michelin.com/us/en/lower-silesian/wroclaw_2399695/restaurant/tarasowa
ve_f7eea34b19~One Star~https://guide.michelin.com/us/en/gorizia/nova-gorica/restaurant/dam
ve_f95e815a9a~Bib Gourmand~https://guide.michelin.com/us/en/pomerania/gdansk_2403599/restaurant/hewelke
ve_fe3a2862fe~One Star~https://guide.michelin.com/us/en/pomerania/gdansk_2403599/restaurant/arco-by-paco-perez$plan$;
  nw text := $plan$ve_004d840d0c~kwestia-czasu-nago~bialystok~ci_856151938c~Białystok~Poland~Kwestia Czasu / NAGO
ve_09cd1a520f~naama~rzeszow~ci_60495990c4~Rzeszów~Poland~Naama
ve_0f96ebd61e~acanti~lodz~ci_37d769d5fe~Łódź~Poland~Acanti
ve_0fb769627e~win-wine-bar-shop~warsaw~ci_d3ee3f1229~Warsaw~Poland~WIN wine bar & shop
ve_1064e8559c~krzywa-sztuka-wina~katowice~ci_eece5a7109~Katowice~Poland~KRZYWA Sztuka Wina
ve_2054ae216d~2pier~lublin~ci_9be7925e9f~Lublin~Poland~2PiEr
ve_3d9f14819e~the-moment~kielce~ci_d84032f2c9~Kielce~Poland~The Moment
ve_3e99e6d438~ahaan~warsaw~ci_d3ee3f1229~Warsaw~Poland~AHAAN
ve_45eccd6bba~farmer-sons~skorzewo~ci_75e1679ea8~Skórzewo~Poland~Farmer & Sons
ve_7ebc3d3427~wandal~warsaw~ci_d3ee3f1229~Warsaw~Poland~WANDAL
ve_80b6916ead~brut-bistro~gdansk~ci_5f55488e0a~Gdańsk~Poland~Brut Bistro
ve_814c70a95c~blisko-bar~warsaw~ci_d3ee3f1229~Warsaw~Poland~Blisko Bar
ve_8fe63287e4~bufet-krk~krakow~ci_7dd3f7a74c~Kraków~Poland~Bufet KRK
ve_a6f2cd7042~pijalni~wroc-aw~ci_527e20892b~Wrocław~Poland~Pijalni
ve_a8c75a8e75~biblioteka~walbrzych~ci_0bb8796f12~Wałbrzych~Poland~Biblioteka
ve_ba7ad8f326~da-andrea~olsztyn~ci_47b3d4062b~Olsztyn~Poland~Da Andrea
ve_c2c970bb0e~nat-bistro~krakow~ci_7dd3f7a74c~Kraków~Poland~Nat Bistro
ve_c43fdbf96e~sztuka-chleba-i-wina~bialystok~ci_856151938c~Białystok~Poland~Sztuka Chleba i Wina
ve_d114a19d4e~piernicova~torun~ci_6e62311b9e~Toruń~Poland~Piernicova$plan$;
  n bigint; s text; fp text; first_award bigint; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(ul) <> '145b4acea226c9c440828427e0ce87df' OR md5(xl) <> '0ce8727bc5ba60f087a9adf53422edd9' OR md5(aw) <> '657d446b46a62392cb579cc62724775f' OR md5(nw) <> '35b5daa1e8c882039663156a74345b3b' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country_iso IN ('PL','HR','SI')) y;
  IF fp IS DISTINCT FROM 'ef355241a07dfc9834c2f66acde03638' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('PL','HR','SI')) <> 89 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11812 OR (SELECT count(*) FROM venues WHERE status='active') <> 11494 OR (SELECT count(*) FROM venues WHERE status='closed') <> 318 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28966 OR (SELECT max(id) FROM awards) <> 36137 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7735 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13756 OR (SELECT count(*) FROM listings) <> 11812 OR (SELECT count(*) FROM city_label_source) <> 25031 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3335 OR (SELECT sum(venues_count) FROM cities) <> 11494 OR (SELECT venues_count FROM cities WHERE id='ci_7dd3f7a74c') <> 6 OR (SELECT venues_count FROM cities WHERE id='ci_d3ee3f1229') <> 13 OR (SELECT venues_count FROM cities WHERE id='ci_527e20892b') <> 4 OR (SELECT venues_count FROM cities WHERE id='ci_5f55488e0a') <> 3 OR (SELECT venues_count FROM cities WHERE id='ci_eece5a7109') <> 1 OR (SELECT count(*) FROM source_capture_ledger) <> 305 OR (SELECT max(id) FROM source_capture_ledger) <> 359 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_0bb8796f12' OR slug='walbrzych') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Wałbrzych')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_d84032f2c9' OR slug='kielce') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Kielce')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_37d769d5fe' OR slug='lodz') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Łódź')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_9be7925e9f' OR slug='lublin') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Lublin')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_856151938c' OR slug='bialystok') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Białystok')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_60495990c4' OR slug='rzeszow') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Rzeszów')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_6e62311b9e' OR slug='torun') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Toruń')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_47b3d4062b' OR slug='olsztyn') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Olsztyn')) OR EXISTS (SELECT 1 FROM cities WHERE id='ci_75e1679ea8' OR slug='skorzewo') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('Skórzewo')) THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 128592 OR u2 <> 134421 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(ul,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'url rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(xl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS DISTINCT FROM split_part(x,'~',4);
  IF n <> 0 THEN RAISE EXCEPTION 'sourced rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE EXISTS (SELECT 1 FROM awards a WHERE a.venue_id=split_part(x,'~',1) AND a.source_id='michelin' AND a.year=2026 AND a.category=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue already has the 2026 row %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(ul,E'\n') x) OR a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',7)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(ul,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 5 THEN RAISE EXCEPTION 'url set %', n; END IF;
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_0bb8796f12', 'walbrzych', 'Wałbrzych', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_d84032f2c9', 'kielce', 'Kielce', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_37d769d5fe', 'lodz', 'Łódź', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_9be7925e9f', 'lublin', 'Lublin', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_856151938c', 'bialystok', 'Białystok', 'Poland', 'PL', 'city', NULL, NULL, NULL, 2);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_60495990c4', 'rzeszow', 'Rzeszów', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_6e62311b9e', 'torun', 'Toruń', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_47b3d4062b', 'olsztyn', 'Olsztyn', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_75e1679ea8', 'skorzewo', 'Skórzewo', 'Poland', 'PL', 'city', NULL, NULL, NULL, 1);
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',7), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 19 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 19 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 19 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=8 WHERE id='ci_7dd3f7a74c' AND venues_count=6; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city krakow'; END IF;
  UPDATE cities SET venues_count=17 WHERE id='ci_d3ee3f1229' AND venues_count=13; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city warsaw'; END IF;
  UPDATE cities SET venues_count=5 WHERE id='ci_527e20892b' AND venues_count=4; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city wroc-aw'; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_5f55488e0a' AND venues_count=3; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city gdansk'; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_eece5a7109' AND venues_count=1; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city katowice'; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),(split_part(x,'~',6),'country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 38 THEN RAISE EXCEPTION 'labels %', n; END IF;
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2026, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 86 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',46,'cleanup:load-michelin-2026-b-2026-11-06 | rule 2.1.1 and 2.1.7: Poland 2026, May 27, 2026, https://guide.michelin.com/pl/en/article/michelin-guide-ceremony/michelin-guide-poland-2026-news | legacy 2025 rows stay, relabel 0, retire 0 | 45 new rows, 19 new venues, 9 new cities, 1 rows labelled 2026 get the card URL | relay sha256 69dca933c4a4070625876a5f28565efe09aa89663a09feb7b63a34d09dbc36d5 | DRAFT, choices not yet given'),
    ('michelin','award',24,'cleanup:load-michelin-2026-b-2026-11-06 | rule 2.1.1 and 2.1.7: Croatia 2026, Jun 25, 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-croatia-2026-is-unveiled | legacy 2025 rows stay, relabel 0, retire 0 | 22 new rows, 2 rows labelled 2026 get the card URL | relay sha256 69dca933c4a4070625876a5f28565efe09aa89663a09feb7b63a34d09dbc36d5 | DRAFT, choices not yet given'),
    ('michelin','award',21,'cleanup:load-michelin-2026-b-2026-11-06 | rule 2.1.1 and 2.1.7: Slovenia 2026, Jun 16, 2026, https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-slovenia-2026-is-out | legacy 2025 rows stay, relabel 0, retire 0 | 19 new rows, 2 rows labelled 2026 get the card URL | relay sha256 69dca933c4a4070625876a5f28565efe09aa89663a09feb7b63a34d09dbc36d5 | DRAFT, choices not yet given'),
    ('michelin','city_label',38,'cleanup:load-michelin-2026-b-2026-11-06 | city labels of 19 new Poland venues | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11513 OR (SELECT count(*) FROM venues WHERE status='closed') <> 318 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 86 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '657d446b46a62392cb579cc62724775f' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> 44 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('PL','HR','SI') GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2025:Bib Gourmand=44,2025:One Star=25,2025:Three Stars=1,2025:Two Stars=3,2026:Bib Gourmand=64,2026:One Star=31,2026:Service Award=2,2026:Sommelier Award=1,2026:Three Stars=1,2026:Two Stars=3' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, u1, u2 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('Three Stars','Two Stars','One Star','Bib Gourmand') AND c.country_iso IN ('PL','HR','SI');
  IF n <> 99 OR u1 <> 99 OR u2 <> 99 THEN RAISE EXCEPTION 'urls after % % %', n, u1, u2; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('PL','HR','SI') GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13775 OR (SELECT count(*) FROM listings) <> 11831 OR (SELECT count(*) FROM city_label_source) <> 25069 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3344 OR (SELECT sum(venues_count) FROM cities) <> 11513 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 309 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134421 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=86,awards:UPDATE=5,cities:INSERT=9,cities:UPDATE=5,city_label_source:INSERT=38,listings:INSERT=19,slugs:INSERT=19,venues:INSERT=19' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
