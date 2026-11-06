-- load-michelin-2026-mexico-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Mexico 2026. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: ceremony May 20, 2026, inside the capture window (https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-mexico-for-2026-and-the-year-s-key-trends). Test of named promotions: 6 of 7 new stars are in the live rows, 0 of 16 new Bibs. Result: mixed.
-- Relabel 6 rows 2025 -> 2026, card URL: the 6 new stars, which cannot be 2025 rows. The other 70 rows stay 2025, no URL. Retire 0.
-- New awards: 86 rows 2026 (card URL; Pink Rambo = Bib article URL, card 404). 2 rows 2025 (Em One Star, Gaba Bib Gourmand), article URL.
-- New venues: 17, card name, restaurant, active, published. New cities: 3. No price, address, geo, blurb or chef.
-- Source: docs/michelin-2026-mexico-2026-11-05/relay-mx-2026-list-pages-2026-11-05.txt sha256 eaa8b76fce43958a96549ce20537c6f5871a1fb48ca997be71617c08cd03b549.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11716 (active 11408, closed 308); awards 28681; slugs 13660; listings 11716; labels 24839; cities 3325, sum 11408; ledger 274 rows; Michelin 2025/2026/2027 4365/7470/122; audit_log +187.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$9159|ve_a7517b2452|One Star|https://guide.michelin.com/us/en/jalisco/guadalajara_2011748/restaurant/alcalde-1243800
9171|ve_fc009181ef|One Star|https://guide.michelin.com/us/en/jalisco/guadalajara_2011748/restaurant/xokol
9174|ve_ab5a360f69|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/gaba
9175|ve_6eaa2b6f54|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/la-once-mil
9181|ve_8a9d405170|One Star|https://guide.michelin.com/us/en/yucatan/merida_2068208/restaurant/huniik
9185|ve_f5762ac8d8|One Star|https://guide.michelin.com/us/en/yucatan/chochola_2067346/restaurant/ixi-im$plan$;
  aw text := $plan$ve_0e1e215fee|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/moyuelo|2026
ve_1274a0d10d|Bib Gourmand|https://guide.michelin.com/us/en/quintana-roo/tulum_2069429/restaurant/cetli|2026
ve_1689c2e3f7|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/raiz-1208231|2026
ve_18576be506|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/el-porvenir_2059721/restaurant/la-cocina-de-dona-esthela|2026
ve_19e5819f1f|Bib Gourmand|https://guide.michelin.com/us/en/yucatan/merida_2068208/restaurant/taquerias-kisin|2026
ve_1e4eda692b|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/galea|2026
ve_1fa0951701|Two Stars|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/pujol|2026
ve_256cac295c|One Star|https://guide.michelin.com/us/en/baja-california/valle-de-guadalupe_7770290/restaurant/animalon|2026
ve_27c9173de4|One Star|https://guide.michelin.com/us/en/baja-california/el-porvenir_2059721/restaurant/lunario|2026
ve_29005d67b2|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/tlalpan_2003036/restaurant/tacos-charly|2026
ve_2c1f062cbf|One Star|https://guide.michelin.com/us/en/baja-california-sur/cabo-san-lucas_2059129/restaurant/cocina-de-autor-los-cabos|2026
ve_2e42ae66e2|Bib Gourmand|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/tierra-del-sol|2026
ve_339a2999a4|One Star|https://guide.michelin.com/us/en/nuevo-leon/san-pedro-garza-garcia_2042888/restaurant/pangea|2026
ve_384a06a422|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/benito-juarez_1994163/restaurant/los-consentidos-del-barrio|2026
ve_3b13f66e6f|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/benito-juarez_1994163/restaurant/el-vilsito|2026
ve_3c7521e2eb|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/ultramarinos-demar|2026
ve_3f286d0a0b|Bib Gourmand|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/la-olla|2026
ve_42f5c25058|Bib Gourmand|https://guide.michelin.com/us/en/puebla/atlixco_2014458/restaurant/vica|2026
ve_4311d111a0|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/plonk|2026
ve_46932b468d|Bib Gourmand|https://guide.michelin.com/us/en/nuevo-leon/san-pedro-garza-garcia_2042888/restaurant/el-bambis-cafe|2026
ve_49a063d694|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/vigneron|2026
ve_4b376309e6|Bib Gourmand|https://guide.michelin.com/us/en/quintana-roo/tulum_2069429/restaurant/mestixa|2026
ve_4e1b67f3e8|One Star|https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-mexico-stars-green-stars|2025
ve_4e1b67f3e8|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/em|2026
ve_525fed72b2|One Star|https://guide.michelin.com/us/en/baja-california/valle-de-guadalupe_7770290/restaurant/conchas-de-piedra|2026
ve_5342363b44|One Star|https://guide.michelin.com/us/en/yucatan/merida_2068208/restaurant/la-barra-de-huniik|2026
ve_54e2f05c38|One Star|https://guide.michelin.com/us/en/baja-california/ensenada_2059847/restaurant/olivea-farm-to-table|2026
ve_55222b26b4|Bib Gourmand|https://guide.michelin.com/us/en/article/michelin-guide-ceremony/mexico-s-most-affordable-restaurants-in-2026|2026
ve_592f7ff1e3|Bib Gourmand|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/las-quince-letras|2026
ve_5a8c26383a|Two Stars|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/quintonil|2026
ve_5b8e0c0e3f|Bib Gourmand|https://guide.michelin.com/us/en/jalisco/guadalajara_2011748/restaurant/tacos-y-gorditas-elvira|2026
ve_5e31828544|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/maximo|2026
ve_5e8a3f0335|Bib Gourmand|https://guide.michelin.com/us/en/nuevo-leon/monterrey_2041973/restaurant/tacos-dona-mary-la-gritona|2026
ve_6222c0a0c3|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/tijuana_2061688/restaurant/carmelita-molino-y-cocina|2026
ve_649178d372|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/valle-de-guadalupe_7770290/restaurant/fauna-1208366|2026
ve_64baed52ac|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/villa-de-juarez_2061842/restaurant/villa-torel|2026
ve_68d244ee06|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/comedor-jacinta|2026
ve_6994b16144|Bib Gourmand|https://guide.michelin.com/us/en/quintana-roo/puerto-morelos_2068420/restaurant/punta-corcho|2026
ve_6d38330897|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/caracol-de-mar|2026
ve_703961ccfa|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/rosetta|2026
ve_7572d3c920|Bib Gourmand|https://guide.michelin.com/us/en/baja-california-sur/san-jose-del-cabo_2061454/restaurant/flora-s-field-kitchen|2026
ve_762b2ed65f|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/galanga-thai-house|2026
ve_767ca1996d|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/alvaro-obregon_2003790/restaurant/taqueria-los-milanesos|2026
ve_78b33b708e|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/tacos-del-valle|2026
ve_78c05a0f6c|Bib Gourmand|https://guide.michelin.com/us/en/quintana-roo/playa-del-carmen_2068368/restaurant/axiote-cocina-de-mexico|2026
ve_7c4ad70c5a|Bib Gourmand|https://guide.michelin.com/us/en/yucatan/tixkokob_2069405/restaurant/pueblo-pibil|2026
ve_7e165504c0|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/el-guero-marinero|2026
ve_831ed1f088|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/restaurante-casareyna|2026
ve_900970374a|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/cultivo|2026
ve_942f6db974|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/jowong|2026
ve_9476a4dcc4|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/pargot|2026
ve_971bd359c7|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/fugaz|2026
ve_9b01479b3e|Bib Gourmand|https://guide.michelin.com/us/en/jalisco/guadalajara_2011748/restaurant/palreal|2026
ve_9cc7566b9d|Bib Gourmand|https://guide.michelin.com/us/en/baja-california-sur/cabo-san-lucas_2059129/restaurant/metate|2026
ve_9d3a359168|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/contramar|2026
ve_a630ec0502|Bib Gourmand|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/labo-fermento|2026
ve_ab5a360f69|Bib Gourmand|https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-mexico-bib-gourmand-2025|2025
ve_add42a2b2e|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/aleli-rooftop|2026
ve_b04067d16f|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/ensenada_2059847/restaurant/sabina|2026
ve_b34ba0e04d|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/los-camellos|2026
ve_b52256698b|One Star|https://guide.michelin.com/us/en/baja-california/valle-de-guadalupe_7770290/restaurant/damiana|2026
ve_bb91783d56|Bib Gourmand|https://guide.michelin.com/us/en/baja-california-sur/el-pescadero_2059712/restaurant/cocina-de-campo-by-agricole|2026
ve_bd35996e14|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/jacinto-y-yo|2026
ve_bd6fe7945c|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/molino-el-pujol|2026
ve_bdf75c92d6|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/ensenada_2059847/restaurant/casa-marcelo-1210913|2026
ve_c043328b53|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/taqueria-el-jarocho|2026
ve_c1e10388c1|Bib Gourmand|https://guide.michelin.com/us/en/puebla/heroica-puebla-de-zaragoza_2015740/restaurant/semitas-beto|2026
ve_c375ed5540|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/taqueria-los-cocuyos|2026
ve_c4aed50388|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/expendio-de-maiz|2026
ve_c6ddc99d2f|One Star|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/levadura-de-olla-restaurante|2026
ve_ca7c0fada5|One Star|https://guide.michelin.com/us/en/quintana-roo/playa-del-carmen_2068368/restaurant/cocina-de-autor-riviera-maya|2026
ve_cef04ba178|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/alvaro-obregon_2003790/restaurant/sud-777|2026
ve_d61f94b915|Bib Gourmand|https://guide.michelin.com/us/en/yucatan/merida_2068208/restaurant/pancho-maiz|2026
ve_da655a493a|One Star|https://guide.michelin.com/us/en/quintana-roo/playa-del-carmen_2068368/restaurant/le-chique|2026
ve_dc4c12b269|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/esquina-comun|2026
ve_e71b270074|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/ensenada_2059847/restaurant/humo-y-sal|2026
ve_ea74d4e504|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/la-89|2026
ve_eb15d83731|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/siembra-tortilleria|2026
ve_ef14273320|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/miguel-hidalgo_1999281/restaurant/comal-oculto|2026
ve_eff6507e88|Bib Gourmand|https://guide.michelin.com/us/en/baja-california/ensenada_2059847/restaurant/la-concheria|2026
ve_f1a3b8b43c|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/tacos-los-alexis|2026
ve_f28f78f215|One Star|https://guide.michelin.com/us/en/nuevo-leon/monterrey_2041973/restaurant/koli-cocina-de-origen|2026
ve_f2b54d4b2a|One Star|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/masala-y-maiz|2026
ve_f4b194a867|Bib Gourmand|https://guide.michelin.com/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/filigrana|2026
ve_f5d6f5d521|One Star|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/los-danzantes-oaxaca|2026
ve_f81f010a30|One Star|https://guide.michelin.com/us/en/quintana-roo/playa-del-carmen_2068368/restaurant/ha-1208266|2026
ve_f89d409530|Bib Gourmand|https://guide.michelin.com/us/en/jalisco/puerto-vallarta_2013264/restaurant/icu|2026
ve_ff8faa396a|Bib Gourmand|https://guide.michelin.com/us/en/oaxaca/oaxaca-de-juarez_2056768/restaurant/xaok|2026$plan$;
  nw text := $plan$ve_0e1e215fee|moyuelo|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|Moyuelo
ve_19e5819f1f|taquerias-kisin|merida|ci_f020927946|Mérida|Mérida|Taquerías Kisín
ve_42f5c25058|vica-cocina-de-un-valle|atlixco|ci_be6c3d6ac7|Atlixco|Atlixco|Vica Cocina de un Valle
ve_46932b468d|el-bambis-cafe|monterrey|ci_4e9eaa94e2|Monterrey|San Pedro Garza García|El Bambis Café
ve_5342363b44|la-barra-de-huniik|merida|ci_f020927946|Mérida|Mérida|La Barra de Huniik
ve_5b8e0c0e3f|tacos-y-gorditas-elvira|guadalajara|ci_1431b98607|Guadalajara|Guadalajara|Tacos Y Gorditas Elvira
ve_7c4ad70c5a|pueblo-pibil|tixkokob|ci_f92002cdbf|Tixkokob|Tixkokob|Pueblo Pibil
ve_7e165504c0|el-guero-marinero|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|El Güero Marinero
ve_831ed1f088|restaurante-casareyna|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|Restaurante Casareyna
ve_900970374a|cultivo|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|Cultivo
ve_9b01479b3e|palreal|guadalajara|ci_1431b98607|Guadalajara|Guadalajara|palReal
ve_b34ba0e04d|los-camellos|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|Los Camellos
ve_bd35996e14|jacinto-y-yo|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|Jacinto y Yo
ve_bd6fe7945c|molino-el-pujol|mexico-city|ci_002aaa1d1e|Mexico City|Cuauhtémoc|Molino El Pujol
ve_c1e10388c1|semitas-beto|heroica-puebla-de-zaragoza|ci_5bc399fd77|Heroica Puebla de Zaragoza|Heróica Puebla de Zaragoza|Semitas "Beto"
ve_d61f94b915|pancho-maiz|merida|ci_f020927946|Mérida|Mérida|Pancho Maiz
ve_f89d409530|icu|puerto-vallarta|ci_602b473fc7|Puerto Vallarta|Puerto Vallarta|ICÚ$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '1d8850b588d4ae7ed60ff728b2d7be03' OR md5(aw) <> 'c55b07652b845e75cb43f28fdf954f82' OR md5(nw) <> '49652f1694b3abba109025c46117d2a2' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) y;
  IF fp IS DISTINCT FROM 'fae7ea2698d24a80e1849a34bccec87c' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX') <> 76 THEN RAISE EXCEPTION 'Mexico Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11699 OR (SELECT count(*) FROM venues WHERE status='active') <> 11391 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28593 OR (SELECT max(id) FROM awards) <> 35764 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4369 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7378 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13643 OR (SELECT count(*) FROM listings) <> 11699 OR (SELECT count(*) FROM city_label_source) <> 24805 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3322 OR (SELECT sum(venues_count) FROM cities) <> 11391 OR (SELECT count(*) FROM source_capture_ledger) <> 271 OR (SELECT max(id) FROM source_capture_ledger) <> 325 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_1431b98607') <> 5 OR (SELECT venues_count FROM cities WHERE id='ci_5bc399fd77') <> 1 OR (SELECT venues_count FROM cities WHERE id='ci_f020927946') <> 3 OR (SELECT venues_count FROM cities WHERE id='ci_002aaa1d1e') <> 68 OR (SELECT venues_count FROM cities WHERE id='ci_4e9eaa94e2') <> 5 THEN RAISE EXCEPTION 'city counts before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127173 OR aud_max <> 133002 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) AND v.status='active' AND c.country_iso='MX');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x UNION ALL SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\n') x UNION ALL SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  -- New cities and venues
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_be6c3d6ac7' OR slug='atlixco') OR EXISTS (SELECT 1 FROM city_aliases WHERE alias='atlixco') OR EXISTS (SELECT 1 FROM cities WHERE id='ci_602b473fc7' OR slug='puerto-vallarta') OR EXISTS (SELECT 1 FROM city_aliases WHERE alias='puerto vallarta') OR EXISTS (SELECT 1 FROM cities WHERE id='ci_f92002cdbf' OR slug='tixkokob') OR EXISTS (SELECT 1 FROM city_aliases WHERE alias='tixkokob') THEN RAISE EXCEPTION 'city clash'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',7))),'[^a-z0-9]+','-','g')) OR split_part(x,'|',4) <> 'ci_'||left(md5(split_part(x,'|',3)),10) AND split_part(x,'|',3) NOT IN (SELECT slug FROM cities);
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) OR (c.country_iso='MX' AND v.norm_key=norm_key(split_part(x,'|',7)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 6 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_be6c3d6ac7', 'atlixco', 'Atlixco', 'Mexico', 'MX', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_602b473fc7', 'puerto-vallarta', 'Puerto Vallarta', 'Mexico', 'MX', 'city', NULL, NULL, NULL, 1);
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_f92002cdbf', 'tixkokob', 'Tixkokob', 'Mexico', 'MX', 'city', NULL, NULL, NULL, 1);
  UPDATE cities SET venues_count=7 WHERE id='ci_1431b98607' AND venues_count=5;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city guadalajara %', n; END IF;
  UPDATE cities SET venues_count=8 WHERE id='ci_5bc399fd77' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city heroica-puebla-de-zaragoza %', n; END IF;
  UPDATE cities SET venues_count=6 WHERE id='ci_f020927946' AND venues_count=3;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city merida %', n; END IF;
  UPDATE cities SET venues_count=69 WHERE id='ci_002aaa1d1e' AND venues_count=68;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city mexico-city %', n; END IF;
  UPDATE cities SET venues_count=6 WHERE id='ci_4e9eaa94e2' AND venues_count=5;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city monterrey %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',7), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 17 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows. The label is the card city.
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',6),'city_display'),('Mexico','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 34 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', split_part(x,'|',4)::int, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 88 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',6,'relabel:load-michelin-2026-mexico-2026-11-05 | rule 2.1.7: ceremony May 20, 2026 (https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-mexico-for-2026-and-the-year-s-key-trends), inside the capture window, test mixed | 6 new stars, year 2025 -> 2026, source_url = the card (/us/en/), 70 rows stay 2025, retire 0 | relay sha256 eaa8b76fce43958a96549ce20537c6f5871a1fb48ca997be71617c08cd03b549 | DRAFT, choices not yet given'),
    ('michelin','award',88,'cleanup:load-michelin-2026-mexico-2026-11-05 | 86 rows 2026, card URL, Pink Rambo = article URL (https://guide.michelin.com/us/en/article/michelin-guide-ceremony/mexico-s-most-affordable-restaurants-in-2026) | 2 rows 2025, article URL | list read Nov 5, 2026 | relay sha256 eaa8b76fce43958a96549ce20537c6f5871a1fb48ca997be71617c08cd03b549 | DRAFT, choices not yet given'),
    ('michelin','city_label',34,'cleanup:load-michelin-2026-mexico-2026-11-05 | city labels of 17 new venues, new cities atlixco, puerto-vallarta, tixkokob | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11716 OR (SELECT count(*) FROM venues WHERE status='active') <> 11408 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28681 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 88 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) FROM (SELECT venue_id||'|'||category||'|'||source_url||'|'||year t FROM awards WHERE id > first_award AND source_id='michelin') z) <> md5((SELECT string_agg(x, E'\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4365 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7470 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=63,One Star=27,Two Stars=2' THEN RAISE EXCEPTION 'Mexico 2026 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2025 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=49,One Star=21,Two Stars=2' THEN RAISE EXCEPTION 'Mexico 2025 %', s; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 92 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13660 OR (SELECT count(*) FROM listings) <> 11716 OR (SELECT count(*) FROM city_label_source) <> 24839 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3325 OR (SELECT sum(venues_count) FROM cities) <> 11408 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 274 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=88,awards:UPDATE=6,cities:INSERT=3,cities:UPDATE=5,city_label_source:INSERT=34,listings:INSERT=17,slugs:INSERT=17,venues:INSERT=17' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
