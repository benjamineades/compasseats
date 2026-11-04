-- load-oad-2026-no-live-venue-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open item 1 of handoff-oad-2026-first-write-done. Ben Nov 3 22:06 ET "1A, 2A, 3A, 4A, 5A, 6A". This file runs only after his "go".
-- 281 new OAD 2026 rows. 258 new venues (255 active, 3 closed and not published). 20 rows on live venues. 2 second rows. 27 new cities. 30 rows held.
-- Evidence: oad-2026-no-live-venue-evidence-2026-11-03.csv. No price, address, geo or blurb.
-- Expected after: venues 11,594 (active 11,297, closed 297); awards 27,399; OAD 2026 2,777; slugs 13,442; listings 11,594; labels 24,595; cities 3,308, sum 11,297; ledger 218 rows; audit_log +1652 (123,642 rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$e|150|Yeni Lokanta|istanbul|a|Istanbul|Turkey
e|174|Agriturismo Ferdy|lenna|a|Lenna|Italy
e|212|Varemottaket|oslo|a|Oslo|Norway
e|241|ELDERS|gent|a|Gent|Belgium
e|263|Ramon Freixa Tradicion|madrid|a|Madrid|Spain
e|265|Lasai|bilbao|a|Bilbao|Spain
e|270|Fraiche|weston-rhyn|a|Owestry|United Kingdom
e|306|Fat Badger|london|a|London|United Kingdom
e|319|Bros Restaurant|martina-franca|a|Lecce|Italy
e|321|Hika|villabona|a|Villabona|Spain
e|360|Porrue|bilbao|a|Bilbao|Spain
e|375|Huset|longyearbyen|a|Longyearbyen|Norway
e|382|Mater|moggiona|a|Moggiona|Italy
e|384|Ristorante L'Aurum|erbusco|a|Erbrusco|Italy
e|398|Shila|tel-aviv|a|Tel Aviv|Israel
e|406|BARE Restaurant|bergen|a|Bergen|Norway
e|407|Rural|madrid|a|Madrid|Spain
e|464|AMÂLIA Restaurant|paris|a|Paris|France
e|472|Brutalisten|stockholm|a|Stockholm|Sweden
e|475|The Pescatarian|copenhagen|a|Copenhagen|Denmark
e|489|Langosteria a Palazzo Fendi|milan|a|Milan|Italy
e|497|Nodaïwa|paris|a|Paris|France
e|502|Ronin|milan|a|Milan|Italy
e|504|Hôtel Costes Restaurant|paris|a|Paris|France
e|515|Fagollaga|hernani|a|Hernani|Spain
e|517|Masaikuta|paris|a|Paris|France
e|528|Urchin|london|c|London|United Kingdom
e|532|Silex|zurich|a|Zürich|Switzerland
e|546|L'Oste Scuro|verona|a|Verona|Italy
e|549|Kokin Restaurant|london|a|London|United Kingdom
e|551|Yoshinobu|milan|a|Milan|Italy
e|559|Cafe Japan|london|a|London|United Kingdom
e|561|El Nuevo Molino|puente-arce|a|Arce|Spain
e|576|Tetsu|madrid|a|Madrid|Spain
e|585|DAV Milano by Da Vittorio|milan|a|Milan|Italy
e|587|Benjamin Schmitt Restaurant|paris|a|Paris|France
e|591|Pellico 3 Milano|milan|a|Milan|Italy
e|614|Bākkō Madrid|madrid|a|Madrid|Spain
e|616|Ichi|kaatsheuvel|a|Kaatsheuvel|Netherlands
e|628|Rimessa Roscioli|rome|a|Rome|Italy
e|630|Shibata|geneva|a|Geneva|Switzerland
e|637|Matsuhisa Paris|paris|a|Paris|France
e|660|Hotel Orania|berlin|a|Berlin|Germany
e|677|JIN|munich|a|Munich|Germany
e|682|Restaurante Cancook|zaragoza|a|Zaragoza|Spain
e|687|L'Alchimia Ristorante & Lounge Bar|milan|a|Milan|Italy
e|706|Soyokaze|stockholm|a|Stockholm|Sweden
e|719|Osaka|madrid|a|Madrid|Spain
e|720|Ristorante Giglio|lucca|a|Lucca|Italy
e|733|Zuara Sushi|madrid|a|Madrid|Spain
e|736|Miyama|madrid|a|Madrid|Spain
e|746|Donabe|london|a|London|United Kingdom
e|749|Persona|stockholm|a|Stockhom|Sweden
e|752|Azabu 10|milan|a|Milan|Italy
e|758|XO Seafood Bar|hamburg|a|Hamburg|Germany
e|760|Escabeche|knokke-heist|a|Knokke-Heist|Belgium
e|761|Nozomi Sushi Bar|valencia|a|València|Spain
e|765|Pauli|copenhagen|a|Copenhagen|Denmark
e|774|Yapa|milan|a|Milan|Italy
a|12|102 House|shanghai|a|Shanghai|China
a|69|SoftBank Private Kitchen|hong-kong|a|Hong Kong|China
a|86|Meet the Bund Skyline|shanghai|a|Shanghai|China
a|123|Chef 1996|beijing|a|Beijing|China
a|136|Nan Xing Yuan|shanghai|a|Shanghai|China
a|152|Raya Restaurant|phuket|a|Bangkok|Thailand
a|211|Jee Hong Kong|hong-kong|a|Hong Kong|Hong Kong
a|232|Trishna|mumbai|a|Mumbai|India
a|242|Sushi Amamoto|taipei|a|Taipei|Taiwan
a|249|La Bourriche 133|shanghai|a|Shanghai|China
a|269|Old tower|beijing|a|Beijing|China
a|277|SEP|hong-kong|a|Hong Kong|Hong Kong
a|280|Silver Cottage|chengdu|a|Chengdu|China
a|302|Birdy Yakitori|taipei|a|Taipei City|Taiwan
a|310|Joongang Haejang|seoul|a|Seoul|South Korea
a|315|Kanesaka Hong Kong|hong-kong|a|Hong Kong|Hong Kong
a|316|Zi Wei Hall|hangzhou|a|Hangzhou|China
a|318|K by Vicky Cheng|bangkok|a|Bangkok|Thailand
a|338|Hidden Place|chengdu|a|Chengdu|China
a|359|Qi 27|taipei|a|Taipei City|Taiwan
a|375|Rark|bangkok|a|Bangkok|Thailand
a|376|Jumbo Seafood - Riverside Point|singapore|a|Singapore|Singapore
a|377|Yu Ting Yuan|bangkok|a|Bangkok|Thailand
a|378|Butcher's Block|singapore|a|Singapore|Singapore
a|387|1929 by Guillaume Galliot|shanghai|a|Shanghai|China
a|407|SHIN YEH|taipei|a|Taipei City|Taiwan
a|409|Beni Kenji Yamanaka|singapore|a|Singapore|Singapore
a|418|Embla|hong-kong|a|Hong Kong|China
a|427|Palmier by Guillaume Galliot|bangkok|a|Bangkok|Thailand
a|429|Censu|hong-kong|a|Hong Kong|China
a|430|Wine RVLT|singapore|c|Singapore|Singapore
a|431|Mōdan|quezon-city|a|Manilla|Philippines
a|435|Trid|seoul|a|Seoul|South Korea
a|441|Quanjude Roast Duck Restaurant|beijing|a|Beijing|China
a|449|Mod Kaew|bangkok|a|Bangkok|Thailand
a|454|Osteria Marzia|hong-kong|a|Hong Kong|China
a|459|REX Wine & Grill|hong-kong|a|Hong Kong|China
a|462|Le Du Kaan|bangkok|a|Bangkok|Thailand
a|475|Medora|hong-kong|a|Hong Kong|China
a|484|Brasserie Astoria Singapore|singapore|a|Singapore|Singapore
a|489|ESA Restaurant|jakarta|a|Jakarta|Indonesia
a|493|Salisterra|hong-kong|a|Hong Kong|China
a|497|Goldfish Sushi & Yakitori|dubai|a|Dubai|United Arab Emirates
a|508|Table - Ingredient Based Cuisine|hong-kong|a|Hong Kong|China
a|526|Nabi|shanghai|a|Shanghai|China
a|528|Ming Pavilion|hong-kong|a|Hong Kong|China
a|532|Hadongkwan|seoul|a|Seoul|South Korea
a|534|Barcino Wine Resto and Bar|taguig|a|Manilla|Philippines
a|538|Moo-lah|hong-kong|a|Hong Kong|China
a|544|Phra Nakhon|bangkok|a|Bangkok|Thailand
a|547|Albergue 1601|macau|a|Macau|China
a|548|Sushi Zo Hong Kong|hong-kong|a|Hong Kong|China
a|550|Buchon Yukhoe|seoul|a|Seoul|South Korea
a|560|PHÉNIX eatery & bar|shanghai|a|Shanghai|China
a|573|BASE HALL 02|hong-kong|a|Hong Kong|China
a|576|Longtail|taipei|a|Taipei City|Taiwan
a|579|Table No 1|shanghai|a|Shanghai|China
a|586|Nobu Doha|doha|a|Doha|United Arab Emirates
a|587|Holt’s Cafe|hong-kong|a|Hong Kong|China
a|589|Sarong Bali|bali|a|Bali|Indonesia
a|590|Chef Man|bangkok|a|Bangkok|Thailand
j|29|Tapas 24|singapore|a|Singapore|Singapore
j|141|Yamagishi|kaga|a|Ishikawa|Japan
j|145|Kisanuki|kanazawa|a|Ishikawa|Japan
j|150|Chisou Sottakuito|hiroshima|a|Hiroshima|Japan
j|196|Yoshii|nagoya|a|Nagoya|Japan
j|207|Villa del Nido|unzen|a|Fukuoka|Japan
j|215|Kaniyoshi|tottori|a|Hiroshima|Japan
j|217|Araki|tokyo|a|Tokyo|Japan
j|220|Kojimachi Nihee|tokyo|a|Tokyo|Japan
j|263|Kiyota Hanare|tokyo|a|Tokyo|Japan
j|293|Isoda|tokyo|a|Tokyo|Japan
j|302|Bouyourou|sakai|a|Fukui|Japan
j|314|Simples|shizuoka|a|Nagoya|Japan
j|328|Xin Rong Ji, Tokyo|tokyo|a|Tokyo|Japan
j|340|Ginza Ugai|tokyo|a|Tokyo|Japan
j|351|Sanwa|tokyo|a|Tokyo|Japan
j|357|Maison Lafite|nakagawa|a|Fukuoka|Japan
j|368|Villa della Pace|nanao|a|Nanao|Japan
j|371|Restaurant Pas Mal|yamagata|a|Yamagata|Japan
j|372|Sushi Riku|tokyo|a|Tokyo|Japan
j|373|Yoichi Sagura|kitahiroshima|a|Yoichi|Japan
j|375|Hagi|iwaki|a|Morioka|Japan
j|380|Hirosawa|kyoto|a|Kyoto|Japan
j|430|Azabu Muroi|tokyo|a|Tokyo|Japan
j|434|Toriyaki-ohana|tokyo|a|Tokyo|Japan
j|446|Sushi Himeshara|sapporo|a|Sapporo|Japan
j|463|Tsushima|tokyo|a|Tokyo|Japan
j|465|Noda|tokyo|a|Tokyo|Japan
j|466|Torisho Ishii Hina|tokyo|a|Tokyo|Japan
j|467|Hiiragiya|kyoto|a|Kyoto|Japan
j|472|Toribayashi|tokyo|a|Tokyo|Japan
j|474|Susukino Sushikin|sapporo|a|Sapporo|Japan
j|476|Salone 2007|yokohama|a|Yokohama|Japan
j|480|Sushi Murayama|tokyo|a|Tokyo|Japan
j|483|Kaoru Hiroo|tokyo|a|Tokyo|Japan
j|496|Ginza Komon|tokyo|a|Tokyo|Japan
j|499|Sottaku Tsukamoto|kyoto|a|Kyoto|Japan
j|504|Malca|tokyo|a|Tokyo|Japan
j|505|Daiichi|kyoto|a|Kyoto|Japan
j|509|ELEZO ESPRIT|toyokoro|a|Sapporo|Japan
j|523|Sushi Fujinaga|tokyo|a|Tokyo|Japan
j|533|Tempura Taku|tokyo|a|Tokyo|Japan
j|539|Sushi Daimon|uozu|a|Toyama|Japan
j|541|Sense|tokyo|a|Tokyo|Japan
j|543|Ippongi Ishibashi|fukuoka|a|Kitakyushu|Japan
j|545|Tempura Matoba|kanazawa|a|Kanazawa|Japan
j|548|Noguchi Taro|osaka|a|Osaka|Japan
j|550|Tom Curiosa|osaka|a|Osaka|Japan
j|552|Unafuji|nagoya|a|Tokyo|Japan
j|554|Furukawa|fukuoka|a|Fukuoka|Japan
j|556|Akiyama|tokyo|a|Tokyo|Japan
j|557|Gibier MIYAMA|kyoto|a|Kyoto|Japan
j|559|L'ETERRE|tokyo|a|Tokyo|Japan
j|562|SECRETO|tokyo|a|Tokyo|Japan
j|566|Miyawaki|tokyo|a|Tokyo|Japan
j|580|Kobikicho Tomoki|tokyo|a|Tokyo|Japan
j|581|Bekk|kitakyushu|a|Fukuoka|Japan
j|582|Gion Rohan|kyoto|a|Kyoto|Japan
j|587|Gion Rakumi|kyoto|a|Kyoto|Japan
j|589|Omino Tsubaki|tokyo|a|Tokyo|Japan
j|592|Goichi|osaka|a|Osaka|Japan
j|593|Kanshin|tokyo|a|Tokyo|Japan
j|604|Sio|tokyo|a|Tokyo|Japan
j|605|Makino|tokyo|a|Tokyo|Japan
j|621|Steak Otsuka|kyoto|a|Kyoto|Japan
j|623|Fukuzushi|tokyo|a|Tokyo|Japan
j|624|Yasaka at Park Hyatt|kyoto|a|Kyoto|Japan
j|631|Araya Totoan|kaga|a|Ishikawa|Japan
j|632|Sansou Murata Ryokan|yufu|a|Oita|Japan
j|635|Tanakada|tokyo|a|Tokyo|Japan
j|636|Hiroyuki|tokyo|a|Tokyo|Japan
j|637|Kizushi|tokyo|a|Tokyo|Japan
j|640|Armani Ristorante|tokyo|a|Tokyo|Japan
j|641|Toraya Kochuan|tokushima|a|Matsumoto|Japan
j|653|Koguma|tokyo|a|Tokyo|Japan
j|658|Setsugekka|tokyo|a|Tokyo|Japan
j|662|Mumyo|chino|a|Nagoya|Japan
j|664|Mizuki|kyoto|a|Kyoto|Japan
j|665|Tobi|kanazawa|a|Kanazawa|Japan
j|668|Sushi En|okayama|a|Hiroshima|Japan
j|670|Nukumi|sapporo|a|Sapporo|Japan
j|674|DepTH brianza|tokyo|a|Tokyo|Japan
j|684|FuFu Kawaguchiko|fujikawaguchiko|a|Fujikawaguchiko|Japan
j|686|Matagi|tokyo|a|Tokyo|Japan
j|691|Restaurant Takatsu|shimonoseki|a|Hiroshima|Japan
j|695|Sushi Shunbi Nishikawa|nagoya|a|Nagoya|Japan
j|698|Tokyo Shiba Tofuya Ukai|tokyo|c|Tokyo|Japan
j|703|Nojima|tokyo|a|Tokyo|Japan
j|704|Akasaka Tan-tei|tokyo|a|Tokyo|Japan
j|707|Kogetsu|tokyo|a|Tokyo|Japan
j|708|TACOS BAR|tokyo|a|Tokyo|Japan
j|709|Yakiniku Sudo Kumamoto|kumamoto|a|Kumamoto|Japan
j|711|Aoyama Sushi Kanesaka|tokyo|a|Tokyo|Japan
j|713|Tempura Abe|tokyo|a|Tokyo|Japan
j|715|Ryoriya Stephan Pantel|kyoto|a|Kyoto|Japan
j|719|Sushi Arima|sapporo|a|Sapporo|Japan
j|720|Sushi Murase|tokyo|a|Tokyo|Japan
j|723|Unagi Tokitou|tokyo|a|Tokyo|Japan
j|726|Sudachi|tokyo|a|Tokyo|Japan
j|730|Comer mar y montana|kanazawa|a|Kanazawa|Japan
j|732|Ichibancho Teruya|tokyo|a|Tokyo|Japan
j|733|TINC GANA|tokyo|a|Tokyo|Japan
j|737|Sushidokoro Tada|osaka|a|Osaka|Japan
j|738|Tempura Endo Yasaka|kyoto|a|Kyoto|Japan
j|739|Sushi Tatsuya|tokyo|a|Tokyo|Japan
j|740|Naruya|kyoto|a|Kyoto|Japan
j|742|Sanda|tokyo|a|Tokyo|Japan
j|744|Fugu Club Miyawaki Bettei|tokyo|a|Tokyo|Japan
j|745|Ginza Ibuki|tokyo|a|Tokyo|Japan
j|747|Restaurant Aladdin|tokyo|a|Tokyo|Japan
j|750|WM BY WAGYUMAFIA|tokyo|a|Tokyo|Japan
j|751|Takoyasu|osaka|a|Osaka|Japan
j|752|L’ Eau|tokyo|a|Tokyo|Japan
j|754|Sushi Tokyo Yoshida|tokyo|a|Tokyo|Japan
j|756|Souka|tokyo|a|Tokyo|Japan
j|757|Sushi Fukumoto|tokyo|a|Tokyo|Japan
j|758|Yosuke Yamaji|kyoto|a|Kyoto|Japan
j|759|Saryo Miyasaka|tokyo|a|Tokyo|Japan
j|762|Muroi Kyoto|kyoto|a|Kyoto|Japan
j|763|Ginza Rokukakutei|tokyo|a|Tokyo|Japan
j|770|Sushi Shiro|fukuoka|a|Fukuoka|Japan
j|771|Sushi Hoseki|tokyo|a|Tokyo|Japan
j|772|Sushi Ishiyama|tokyo|a|Tokyo|Japan
j|774|Unagi Yamanochaya|tokyo|a|Tokyo|Japan
j|776|Akasaka Asada|tokyo|a|Tokyo|Japan
j|777|Kamakura Kitajima|kamakura|a|Kanagawa|Japan
j|779|Arroz|kanazawa|a|Kanazawa|Japan
j|780|Tenko Honten|hiroshima|a|Hiroshima|Japan
j|781|Sushi Kuwano|tokyo|a|Tokyo|Japan
j|783|HOSHINOYA Kyoto|kyoto|a|Kyoto|Japan
j|787|Au Gamin de Tokio|tokyo|a|Tokyo|Japan
j|791|Namaiki|tokyo|a|Tokyo|Japan
j|792|Moritaya Kiyamachi|kyoto|a|Kyoto|Japan
j|793|Shimoyami Tenaeizuru|sapporo|a|Sapporo|Japan
j|794|Sushi Yuden|osaka|a|Osaka|Japan
j|795|Sushi Hanakuruma|nagoya|a|Nagoya|Japan
j|797|Yakitori Koto|fukuoka|a|Fukuoka|Japan
j|799|Pyon|tokyo|a|Tokyo|Japan$plan$;
  cl text := $plan$lenna|Lenna|Italy|IT|1
weston-rhyn|Weston Rhyn|United Kingdom|GB|1
villabona|Villabona|Spain|ES|1
longyearbyen|Longyearbyen|Norway|NO|1
erbusco|Erbusco|Italy|IT|1
hernani|Hernani|Spain|ES|1
puente-arce|Puente Arce|Spain|ES|1
kaatsheuvel|Kaatsheuvel|Netherlands|NL|1
quezon-city|Quezon City|Philippines|PH|1
taguig|Taguig|Philippines|PH|1
kaga|Kaga|Japan|JP|2
unzen|Unzen|Japan|JP|1
tottori|Tottori|Japan|JP|1
sakai|Sakai|Japan|JP|1
nakagawa|Nakagawa|Japan|JP|1
nanao|Nanao|Japan|JP|1
yamagata|Yamagata|Japan|JP|1
kitahiroshima|Kitahiroshima|Japan|JP|1
iwaki|Iwaki|Japan|JP|1
toyokoro|Toyokoro|Japan|JP|1
uozu|Uozu|Japan|JP|1
yufu|Yufu|Japan|JP|1
tokushima|Tokushima|Japan|JP|1
chino|Chino|Japan|JP|1
okayama|Okayama|Japan|JP|1
fujikawaguchiko|Fujikawaguchiko|Japan|JP|1
shimonoseki|Shimonoseki|Japan|JP|1$plan$;
  al text := $plan$a|88|ve_0ad174c768
a|107|ve_269ab60a27
a|317|ve_c9af48a8c5
a|326|ve_21bab3c06d
a|524|ve_73d901a8fe
a|536|ve_217324874a
a|562|ve_0d894398dc
e|301|ve_bfda4f7b82
e|465|ve_94030afaec
e|631|ve_cd4a28a835
e|643|ve_488b989290
e|739|ve_e362728f66
e|751|ve_10446b243a
j|240|ve_893dbeaa44
j|306|ve_fc80e81a1a
j|345|ve_46a97d9db1
j|377|ve_ca7ad6ea1a
j|630|ve_45cd61d911
j|634|ve_491642d330
j|657|ve_ec860811a8
j|669|ve_f0f0978f15
j|682|ve_9a19410ee6
j|692|ve_a17af50aab$plan$;
  p jsonb; n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(nl||E'
#
'||cl||E'
#
'||al) <> '27b1249185865abc4734cc7d53cb5c99' THEN RAISE EXCEPTION 'plan text'; END IF;
  WITH r AS (SELECT split_part(x,'|',1) li, split_part(x,'|',2)::int rk, split_part(x,'|',3) name, split_part(x,'|',4) city_slug, split_part(x,'|',5) st, split_part(x,'|',6) clab, split_part(x,'|',7) colab FROM regexp_split_to_table(nl,E'
') x),
       q AS (SELECT r.*, trim(both '-' from regexp_replace(lower(f_unaccent(r.name)),'[^a-z0-9]+','-','g')) slug FROM r),
       w AS (SELECT q.*, 've_'||left(md5(q.city_slug||':'||q.slug),10) id, coalesce(c.id,'ci_'||left(md5(q.city_slug),10)) city_id, (CASE q.st WHEN 'a' THEN 'active' ELSE 'closed' END) status, c.id IS NULL is_new, (CASE q.li WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END) lst FROM q LEFT JOIN cities c ON c.slug=q.city_slug),
       ca AS (SELECT split_part(x,'|',1) slug, split_part(x,'|',2) display, split_part(x,'|',3) country, split_part(x,'|',4) country_iso, split_part(x,'|',5)::int venues_count FROM regexp_split_to_table(cl,E'
') x),
       aa AS (SELECT split_part(x,'|',3) venue_id, split_part(x,'|',2)::int rank, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' url FROM regexp_split_to_table(al,E'
') x)
  SELECT jsonb_build_object(
    'new',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'status',status,'city_id',city_id,'city_slug',city_slug,'slug',slug)) FROM w),
    'aw',(SELECT jsonb_agg(z) FROM (SELECT id venue_id, rk "rank", 'https://www.oadguides.com/lists/'||lst||'/top-restaurants/2026' url FROM w UNION ALL SELECT venue_id, rank, url FROM aa) z),
    'cities',(SELECT jsonb_agg(jsonb_build_object('id','ci_'||left(md5(slug),10),'slug',slug,'display',display,'country',country,'country_iso',country_iso,'venues_count',venues_count)) FROM ca),
    'upd',(SELECT jsonb_agg(jsonb_build_object('id',city_id,'plus',c)) FROM (SELECT city_id, count(*) c FROM w WHERE status='active' AND NOT is_new GROUP BY 1) y),
    'labels',(SELECT jsonb_agg(jsonb_build_object('venue_id',id,'label',l,'col',col)) FROM (SELECT id, clab l, 'city_display' col FROM w UNION ALL SELECT id, colab, 'country' FROM w) y)) INTO p;
  IF (SELECT md5(string_agg(e->>'id',E'
' ORDER BY e->>'id' COLLATE "C")) FROM jsonb_array_elements(p->'new') e) <> '724b05a50b6dec6afa421454d41066aa' THEN RAISE EXCEPTION 'venue ids'; END IF;
  IF (SELECT md5(string_agg(t,E'
' ORDER BY t COLLATE "C")) FROM (SELECT (e->>'venue_id')||'|'||(e->>'rank')||'|'||(e->>'url') t FROM jsonb_array_elements(p->'aw') e) y) <> 'edd6cbbe7d988540d4e50e3871a65736' THEN RAISE EXCEPTION 'award rows'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN ('ve_0ad174c768','ve_0d894398dc','ve_10446b243a','ve_217324874a','ve_21bab3c06d','ve_269ab60a27','ve_46a97d9db1','ve_488b989290','ve_491642d330','ve_73d901a8fe','ve_893dbeaa44','ve_94030afaec','ve_9a19410ee6','ve_a17af50aab','ve_bfda4f7b82','ve_c9af48a8c5','ve_ca7ad6ea1a','ve_cd4a28a835','ve_e362728f66','ve_ec860811a8','ve_f0f0978f15','ve_fc80e81a1a');
  IF fp IS DISTINCT FROM '3fa2a03e216d8cb5cb460fad6926460d' THEN RAISE EXCEPTION 'live venue fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11336 OR (SELECT count(*) FROM venues WHERE status='active') <> 11042 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27118 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2496 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13184 OR (SELECT count(*) FROM listings) <> 11336 OR (SELECT count(*) FROM city_label_source) <> 24079 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3281 OR (SELECT sum(venues_count) FROM cities) <> 11042 OR (SELECT count(*) FROM source_capture_ledger) <> 214 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 121990 OR aud_max <> 127819 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text) WHERE x.id <> 've_'||left(md5(x.city_slug||':'||x.slug),10) OR trim(both '-' from regexp_replace(lower(f_unaccent(x.name)),'[^a-z0-9]+','-','g')) <> x.slug;
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text, city_id text) WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=x.id OR (v.city_id=x.city_id AND v.norm_key=norm_key(x.name))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.city_slug AND t.slug=x.slug);
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'cities') x(id text, slug text) WHERE x.id <> 'ci_'||left(md5(x.slug),10) OR EXISTS (SELECT 1 FROM cities c WHERE c.id=x.id OR c.slug=x.slug) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.slug AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(city_id text, status text) WHERE NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=x.city_id) AND NOT EXISTS (SELECT 1 FROM jsonb_to_recordset(p->'cities') y(id text) WHERE y.id=x.city_id);
  IF n <> 0 THEN RAISE EXCEPTION 'city missing %', n; END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(p->'upd') x(id text) JOIN cities c ON c.id=x.id) <> 54 THEN RAISE EXCEPTION 'cities to update'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(p->'aw') x(venue_id text, rank int) ON a.venue_id=x.venue_id AND a.source_id='oad' AND a.year=2026 AND a.rank=x.rank) THEN RAISE EXCEPTION 'row exists'; END IF;
  IF (SELECT count(DISTINCT a.venue_id) FROM awards a WHERE a.source_id='oad' AND a.year=2026 AND a.venue_id IN ('ve_0ad174c768','ve_0d894398dc','ve_10446b243a','ve_217324874a','ve_21bab3c06d','ve_269ab60a27','ve_46a97d9db1','ve_488b989290','ve_491642d330','ve_73d901a8fe','ve_893dbeaa44','ve_94030afaec','ve_9a19410ee6','ve_a17af50aab','ve_bfda4f7b82','ve_c9af48a8c5','ve_ca7ad6ea1a','ve_cd4a28a835','ve_e362728f66','ve_ec860811a8','ve_f0f0978f15','ve_fc80e81a1a')) <> 2 THEN RAISE EXCEPTION 'live venues with a 2026 row'; END IF;
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT x.id, x.slug, x.display, x.country, x.country_iso, 'city'::city_kind, NULL, NULL, NULL, x.venues_count FROM jsonb_to_recordset(p->'cities') x(id text, slug text, display text, country text, country_iso text, venues_count int);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 27 THEN RAISE EXCEPTION 'cities %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + x.plus FROM jsonb_to_recordset(p->'upd') x(id text, plus int) WHERE c.id=x.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 54 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT x.id, x.name, 'restaurant'::venue_category, x.city_id, x.status::venue_status FROM jsonb_to_recordset(p->'new') x(id text, name text, city_id text, status text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 258 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT x.id, 'eats', x.status='active' FROM jsonb_to_recordset(p->'new') x(id text, status text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 258 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', x.city_slug, x.slug, x.id, true FROM jsonb_to_recordset(p->'new') x(id text, city_slug text, slug text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 258 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) SELECT x.venue_id, x.label, x.col::label_column_t, 'oad', 'OAD 2026 no live venue' FROM jsonb_to_recordset(p->'labels') x(venue_id text, label text, col text) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 516 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT x.venue_id, 'oad', 2026, x.rank, 'No. '||x.rank, NULL, x.url FROM jsonb_to_recordset(p->'aw') x(venue_id text, rank int, url text) ORDER BY x.url, x.rank;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 281 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', 68, 'cleanup:load-oad-2026-no-live-venue-2026-11-03 | open item 1: OAD 2026 no live venue rows, asia | https://www.oadguides.com/lists/asia/top-restaurants/2026 | Ben Nov 3 22:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'award', 65, 'cleanup:load-oad-2026-no-live-venue-2026-11-03 | open item 1: OAD 2026 no live venue rows, europe | https://www.oadguides.com/lists/europe/top-restaurants/2026 | Ben Nov 3 22:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'award', 148, 'cleanup:load-oad-2026-no-live-venue-2026-11-03 | open item 1: OAD 2026 no live venue rows, japan | https://www.oadguides.com/lists/japan/top-restaurants/2026 | Ben Nov 3 22:06 ET "1A, 2A, 3A, 4A, 5A, 6A"'),
    ('oad', 'city_label', 516, 'cleanup:load-oad-2026-no-live-venue-2026-11-03 | open item 1: city labels of the 258 new venues | Ben Nov 3 22:06 ET "1A, 2A, 3A, 4A, 5A, 6A"');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11594 OR (SELECT count(*) FROM venues WHERE status='active') <> 11297 OR (SELECT count(*) FROM venues WHERE status='closed') <> 297 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27399 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2777 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 281 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13442 OR (SELECT count(*) FROM listings) <> 11594 OR (SELECT count(*) FROM city_label_source) <> 24595 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3308 OR (SELECT sum(venues_count) FROM cities) <> 11297 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 218 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=281,cities:INSERT=27,cities:UPDATE=54,city_label_source:INSERT=516,listings:INSERT=258,slugs:INSERT=258,venues:INSERT=258' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
