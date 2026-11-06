-- load-michelin-2026-south-korea-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin South Korea: the 2026 label. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the legacy rows hold the 2026 edition (ceremony Mar 5, 2026: https://guide.michelin.com/kr/en/article/michelin-guide-ceremony/2026-save-the-date; stars: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-michelin-guide-seoul-busan-2026). Relabel 117 rows 2025 -> 2026, source_url = the card (/us/en/). Retire 0.
-- Row 4389 (ARP) holds the /kr/en/ card URL today: it takes the /us/en/ card URL.
-- Source: docs/michelin-2026-south-korea-2026-11-05/relay-kr-2026-list-pages-2026-11-05.txt sha256 6f43f5825ab792cd64a0a62e1f504004a6a670047ab536d446c337217efdf8a4.
-- No venue, rename, price, status, slug, address, geo or blurb change. No new row.
-- Expected after: awards 28519 (no new row); Michelin 2025/2026/2027 4483/7190/122; ledger 265 rows; audit_log +117.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1083|ve_5fef4bc011|Three Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mingles
3045|ve_a72e34207b|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/alla-prima
3053|ve_2de9844798|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/evett
3057|ve_2df092b83e|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/jungsik511965
3066|ve_36bed76026|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/kwonsooksoo
3068|ve_6329aa16ee|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/la-yeon
3071|ve_b86883fa4e|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mitou
3082|ve_409a1b7b21|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mosu
3087|ve_77663cdf3a|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/restaurant-allen
3088|ve_24ff9a8dc6|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/soigne
3095|ve_6a003b57d0|Two Stars|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/sosuheon
4384|ve_619850c8ef|One Star|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/fiotto
4386|ve_e15481fb29|One Star|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/le-dorer
4387|ve_af5c03d4b5|One Star|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/mori
4388|ve_c9af48a8c5|One Star|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/palate
4389|ve_e256bfa97a|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/arp
7928|ve_94df4751a1|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/7th-door
7930|ve_15c8610538|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/bicena
7932|ve_eb42674bb6|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/collage
7940|ve_2721e3f85e|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/eatanic-garden
7942|ve_ab25086d3d|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/escondido
7943|ve_4983bed6eb|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/exquisine
7944|ve_1cc086d414|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/gaggen
7945|ve_289ad9e58a|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/gigas
7946|ve_60883b3d6f|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/giwakang
7947|ve_9c2c005fc3|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/goryori-ken
7949|ve_3205d5e257|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/hakusi
7950|ve_29b1e26fac|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/restaurant-jueun
7953|ve_048097aebf|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/kang-minchul-restaurant
7954|ve_ab8c5b1170|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/l-amant-secret
7956|ve_2df65d77df|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/l-amitie
7958|ve_210754946b|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/legume
7960|ve_6f2380e2db|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/muni
7961|ve_c70dc33645|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/muoki
7972|ve_315c71f2a5|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/onjium
7974|ve_bc8ab70b1a|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/san
7976|ve_4083a94fc2|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/solbam
7984|ve_1befb17911|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/soseoul-hannam
7986|ve_52cdb713a8|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/soul-dining
7988|ve_377775a42c|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/sushi-kanesaka-1244365
7989|ve_cafc3272b9|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/sushi-matsumoto-1195338
7990|ve_ce10187719|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/tutoiement
7991|ve_f7d1ee972c|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/vinho
7994|ve_6b14d09415|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/y-east
7995|ve_0eb99be129|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/yu-yuan
7996|ve_6ad69f644e|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/yun
7997|ve_d2eabc088e|One Star|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/zero-complex
9641|ve_271bf5946e|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/100-1-pyeongnaeng
9642|ve_b21afea084|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/anmok
9643|ve_1fda244067|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/bao-haus
9644|ve_db6fb47135|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/bibijae
9645|ve_0d175ee7ad|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/buda-myeonoak
9646|ve_964e3d265d|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/cor-pasta-bar
9647|ve_4838a3ba4f|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/haemok
9648|ve_2de0f377b9|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/hanwolgwan
9649|ve_0d9516314c|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/hapcheon-gukbapjip
9650|ve_85d749fa41|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/jeongjitgan
9651|ve_48830d7142|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/moemiljip
9652|ve_492a42554e|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/nagahama-mangetsu
9653|ve_4a7f0e9def|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/niurou-mian-guan-zi
9654|ve_e8e0abffeb|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/pili-pili
9655|ve_f9d95b1a76|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/pyeongyangjip
9656|ve_13a1cd3ab4|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/shunsai-kubo
9657|ve_5c2458b538|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/songheonjip
9658|ve_d639dda0e3|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/tokyo-babsang
9659|ve_4bec88c490|Bib Gourmand|https://guide.michelin.com/us/en/busan-region/busan_1025838/restaurant/yakitori-onjung
12078|ve_7df12f5e42|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/3rd-samgyetang
12079|ve_c1f6d927dc|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/alt-a
12080|ve_96963040c4|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/anam
12081|ve_6e8e63dfdf|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/andeok
12082|ve_319b3b47e6|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/base-is-nice
12083|ve_e717d1ee4a|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/daesungjip
12084|ve_aff1b56e3d|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/damtaek
12085|ve_7ef4ee5e45|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/gaeseong-mandu-koong
12086|ve_2736b702b4|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/gebang-sikdang
12087|ve_0ad174c768|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/geumdwaeji-sikdang
12088|ve_039aac15f6|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/ggupdang
12089|ve_2bbc3172b7|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/gomtang-lab
12090|ve_fb5282c7d5|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/gosari-express
12091|ve_c3ecb03dda|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/halmaejip
12092|ve_c7bc08d362|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/hapjeongok
12093|ve_3dcd7b0d94|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/horapa
12094|ve_86ef47d7cc|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/hwa-hae-dang
12095|ve_376b9f68d2|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/hwanggeum-kongbat
12096|ve_1f2b2f681e|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/hwangsaengga-kalguksu
12097|ve_b56d4fc3d3|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/jaha-son-mandu
12098|ve_c14a29648d|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/jeongmyeon
12099|ve_aa454b8a71|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/jin-jin
12100|ve_5b61a9ac66|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/jungin-myeonok
12101|ve_11f6908a41|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/kyewol-gomtang
12102|ve_4ed13d68fe|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/kyodaiya
12103|ve_04815c33ca|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/limbyungjoo-sandong-kalguksu
12104|ve_ee788cda6f|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mandujip
12105|ve_8972868130|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mapo-ok
12106|ve_a1159e62c1|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mattdol
12107|ve_cb68c52ed9|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mijin
12108|ve_cc26f5a9e9|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/mipildam
12109|ve_18871a5a03|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/myeon-seoul
12110|ve_d8f0073553|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/neungdong-minari
12111|ve_2964e04585|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/nishimuramen
12112|ve_10fda1a3a7|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/oilje
12113|ve_ef7ebed55a|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/okdol-heyonok
12114|ve_ae2afe4b27|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/okdongsik
12115|ve_802cd56471|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/oreno-ramen
12116|ve_12c2f1634d|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/pildong-myeonok
12117|ve_878a82744d|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/samcheongdong-sujebi
12118|ve_98ea6e12ef|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/sarukame
12119|ve_261ce335c5|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/seokyonanmyunbang
12120|ve_6416005ffe|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/seoryung
12121|ve_1e70b81516|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/sobakeeri-suzu
12122|ve_81e62be186|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/subaru
12123|ve_13c79ffc4d|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/woo-lae-oak
12125|ve_91aa4399c4|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/yangyang-memil-makguksu
12126|ve_2e60b7c290|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/yonggeumok
12127|ve_e88f43639b|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/youhan
12128|ve_3785339543|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/yukjeon-hoekwan
12129|ve_56eae432ed|Bib Gourmand|https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/yurimmyeon$plan$;
  n bigint; s text; fp text; aud_max bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'a2fd93065f182092957e61c0e7eed539' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||coalesce(a.source_url,'')||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '9e0437daae84945f031a907fa0636493' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea') <> 117 THEN RAISE EXCEPTION 'South Korea Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11691 OR (SELECT count(*) FROM venues WHERE status='active') <> 11384 OR (SELECT count(*) FROM venues WHERE status='closed') <> 307 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28519 OR (SELECT max(id) FROM awards) <> 35690 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4600 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7073 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13635 OR (SELECT count(*) FROM listings) <> 11691 OR (SELECT count(*) FROM city_label_source) <> 24789 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11384 OR (SELECT count(*) FROM source_capture_ledger) <> 264 OR (SELECT max(id) FROM source_capture_ledger) <> 318 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 126821 OR aud_max <> 132650 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows. Only row 4389 holds a URL.
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR (a.source_url IS NOT NULL AND a.id<>4389);
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  IF (SELECT source_url FROM awards WHERE id=4389) IS DISTINCT FROM 'https://guide.michelin.com/kr/en/busan-region/busan_1025838/restaurant/arp' THEN RAISE EXCEPTION 'row 4389 URL'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 117 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',117,'relabel:load-michelin-2026-south-korea-2026-11-05 | rule 2.1.7: South Korea edition live at capture = 2026 (ceremony Mar 5, 2026, https://guide.michelin.com/kr/en/article/michelin-guide-ceremony/2026-save-the-date) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 6f43f5825ab792cd64a0a62e1f504004a6a670047ab536d446c337217efdf8a4 | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 28519 OR (SELECT max(id) FROM awards) <> 35690 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4483 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7190 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=71,One Star=35,Three Stars=1,Two Stars=10' THEN RAISE EXCEPTION 'South Korea 2026 %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2025) <> 0 THEN RAISE EXCEPTION 'South Korea 2025'; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 117 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13635 OR (SELECT count(*) FROM listings) <> 11691 OR (SELECT count(*) FROM city_label_source) <> 24789 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11691 OR (SELECT count(*) FROM venues WHERE status='active') <> 11384 OR (SELECT sum(venues_count) FROM cities) <> 11384 THEN RAISE EXCEPTION 'venues, cities after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 265 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=117' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
