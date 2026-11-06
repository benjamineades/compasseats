-- load-michelin-2027-beijing-tianjin-2026-11-05.sql
-- CompassEats, Nov 6 2026. Michelin Beijing & Tianjin 2027. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Rule 2.1.7, Tokyo row of the table: the 58 Beijing tier rows are sourced 2026 rows (Oct 2025 edition). They stay as history. Relabel 0, retire 0.
-- 82 new rows, year 2027 (Oct 26-27, 2026: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-beijing-tianjin-2027): Three Stars 2, Two Stars 5, One Star 27, Bib Gourmand 48, source_url = the card (/us/en/). 24 new venues, new city Tianjin.
-- 56 of the card URLs repeat on the 2026 row of the same venue. This is expected.
-- Source: docs/michelin-2027-beijing-tianjin-2026-11-05/relay-bj-tj-2027-list-pages-2026-11-05.txt sha256 f1e9d7ed6382d85cd75b17195953747a6938b9bce3d4be548b1aee28ec84b608.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11754 (active 11442, closed 312); awards 28828; slugs 13698; listings 11754; labels 24915; cities 3328, sum 11442; ledger 286 rows; Michelin 2025/2026/2027 4329/7521/254; audit_log +204.
BEGIN;
DO $load$
DECLARE
  aw text := $plan$ve_025cd433e8|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/xiang-bin-xuan-huayuan-road
ve_0907d6d8e8|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/xin-rong-ji-jianguomenwai-street
ve_0b0173ebae|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/qiantang-garden
ve_11145845a4|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/zhiguan
ve_13e93ccbe7|Two Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/jingji
ve_1488ed42ea|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/hong-fan-qie-yuyuantan-south-road
ve_17bfc37566|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/chen-ji-lu-zhu-xiao-chang
ve_17db39274b|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/fragrant-kitchen-chaoyang
ve_1af2a4131e|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/mansion-cuisine-by-jingyan
ve_1c7406cc48|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/old-tower
ve_2179a15d9d|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/pan-zhi-hua-yin-xiang
ve_24de3005f6|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/fu-chun-ju
ve_29a960cf7b|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/xin-rong-ji-jinrong-street
ve_2b7c417eb0|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/lao-chuan-ban
ve_2eeac39d82|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/chao-shang-chao-xicheng
ve_343a90895d|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/zijin-mansion
ve_37e45dcee3|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/wan-hong-lu-yang-tang-shao-bing-dian
ve_39d22a063e|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/the-beijing-kitchen
ve_40083176bc|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/the-georg
ve_4473c30ea7|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/mo-jasmine
ve_450c5c9eb7|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/xiang-lin-tian-xia
ve_47fb87d3b0|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/niujie-halal-man-heng-ji
ve_481ef02fff|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/re-hai-fan-zhuang
ve_4df4b772c7|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/story-of-dumpling
ve_4fb3596a23|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/no-69-fangzhuanchang-zhajiangmian
ve_567d9f103c|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/giada-garden
ve_5e63250f43|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/bi-dian-hai-xian-%E2%80%A7-tou-deng-cang
ve_62826119e6|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/zhe-xian-xiao-chu-chaoyang
ve_643f7f9a62|Two Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/lu-shang-lu
ve_666e159253|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/xiao-yu
ve_6672d45c44|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/gastro-esthetics-dadong
ve_683d3eef6c|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/bao-bao-hao
ve_698ccbbbbc|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/zhao-da-gu-jin-wei-fang
ve_6cfe07bfb2|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/qing-lang-xuan-shui-jiao-hongqiao
ve_6f82b3520a|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/pang-mei-noodles
ve_70c8a2417b|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/fujian-yu-shan-tang
ve_74763ed659|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/furong
ve_7b3fa587f4|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/fujian-cuisine-dongsanhuan-north-road
ve_7f487f1022|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/louyau
ve_88553fb416|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/poetry%E2%80%A7wine
ve_8d3df5c8d7|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/jin-lu-restaurant-nankai
ve_8db1436125|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/sheng-yong-xing-chaoyang
ve_90f9af305b|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/rao-shi-fu-da-xian-shui-jiao
ve_93ac411612|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/nine-river-house-liwan-road
ve_9758a288cd|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/lu-style
ve_9f82378176|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/ba-jiu-bu-li-shi
ve_a119bb8427|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/mingyuan-restaurant
ve_ab4ae66796|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/hua-sheng-feng-dongsanhuan-south-road
ve_ab89dbb319|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/yibin
ve_abccb8710d|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/seventh-son-1186794
ve_abd6c983fc|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/tianchumiaoxiang-vegetarian-chaoyang
ve_aff1c67ff4|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/zhong
ve_b075220a1b|Two Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/blackswan
ve_b1fb2079f7|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/qu-kou-zhou-jia-rou-bing
ve_ba3d9e0f78|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/huibincanting
ve_bc244843c4|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/my-soup
ve_bc52d20cb1|One Star|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/china-banquet
ve_bc7ea4dff4|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/tong-he-ju-yuetan-south-street
ve_beb0308747|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/ember-1252248
ve_bf3adf5226|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/cai-yi-xuan
ve_c1203f68bf|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/rong-pao
ve_c89d460a41|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/jing-hua-lou
ve_c90b07f1bf|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/the-house-of-dynasties
ve_c93f199c6e|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/liu-ma-ma-dumplings-chaoyang
ve_c95452bfed|Two Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/lamdre
ve_cafb98b169|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/rong-cuisine-baiziwan-south-er-road
ve_d4e5fdbd3e|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/il-ristorante-niko-romito-1186723
ve_d63a09c977|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/lake-yard-shuishanggongyuan-east-road
ve_d87c05688e|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/yu-quan-fan-zhuang
ve_e08de51373|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/yu-hua-tai-xicheng
ve_e61dc1a188|Two Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/king-s-joy
ve_ed8fe96699|Three Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/xin-rong-ji-xinyuan-south-road
ve_edc5ed438c|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/shanghai-cuisine
ve_edc7493c3b|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/trb-hutong
ve_eeb6efed57|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/tan-1218718
ve_eeddf12653|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/chef-1996
ve_f45b2bb7ce|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/bao-yuan
ve_f4a69bd8e0|Three Stars|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/chao-shang-chao
ve_f9a80a0cc1|One Star|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/lei-garden-jinbao-tower
ve_fb2d8a30a9|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/jingyi
ve_fbae621312|Bib Gourmand|https://guide.michelin.com/us/en/tianjin-municipality/tianjin_1031352/restaurant/zheng-wei-zhai
ve_fbbf6d56c4|Bib Gourmand|https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/bao-du-jin-sheng-long$plan$;
  nw text := $plan$ve_17bfc37566|chen-ji-lu-zhu-xiao-chang|beijing|ci_0420a206ae|Beijing|Chen Ji Lu Zhu Xiao Chang
ve_17db39274b|fragrant-kitchen-chaoyang|beijing|ci_0420a206ae|Beijing|Fragrant Kitchen (Chaoyang)
ve_2179a15d9d|pan-zhi-hua-yin-xiang|beijing|ci_0420a206ae|Beijing|Pan Zhi Hua Yin Xiang
ve_37e45dcee3|wan-hong-lu-yang-tang-shao-bing-dian|beijing|ci_0420a206ae|Beijing|Wan Hong Lu Yang Tang Shao Bing Dian
ve_481ef02fff|re-hai-fan-zhuang|tianjin|ci_a1a3f433ce|Tianjin|Re Hai Fan Zhuang
ve_4df4b772c7|story-of-dumpling|tianjin|ci_a1a3f433ce|Tianjin|Story Of Dumpling
ve_5e63250f43|bi-dian-hai-xian-tou-deng-cang|tianjin|ci_a1a3f433ce|Tianjin|Bi Dian Hai Xian ‧ Tou Deng Cang
ve_62826119e6|zhe-xian-xiao-chu-chaoyang|beijing|ci_0420a206ae|Beijing|Zhe Xian Xiao Chu (Chaoyang)
ve_666e159253|xiao-yu|tianjin|ci_a1a3f433ce|Tianjin|Xiao Yu
ve_698ccbbbbc|zhao-da-gu-jin-wei-fang|tianjin|ci_a1a3f433ce|Tianjin|Zhao Da Gu Jin Wei Fang
ve_6cfe07bfb2|qing-lang-xuan-shui-jiao-hongqiao|tianjin|ci_a1a3f433ce|Tianjin|Qing Lang Xuan Shui Jiao (Hongqiao)
ve_70c8a2417b|fujian-yu-shan-tang|beijing|ci_0420a206ae|Beijing|Fujian Yu Shan Tang
ve_7f487f1022|louyau|beijing|ci_0420a206ae|Beijing|Louyau
ve_8d3df5c8d7|jin-lu-restaurant-nankai|tianjin|ci_a1a3f433ce|Tianjin|Jin Lu Restaurant (Nankai)
ve_90f9af305b|rao-shi-fu-da-xian-shui-jiao|tianjin|ci_a1a3f433ce|Tianjin|Rao Shi Fu Da Xian Shui Jiao
ve_93ac411612|nine-river-house-liwan-road|tianjin|ci_a1a3f433ce|Tianjin|Nine River House (Liwan Road)
ve_9f82378176|ba-jiu-bu-li-shi|tianjin|ci_a1a3f433ce|Tianjin|Ba Jiu Bu Li Shi
ve_b1fb2079f7|qu-kou-zhou-jia-rou-bing|tianjin|ci_a1a3f433ce|Tianjin|Qu Kou Zhou Jia Rou Bing
ve_ba3d9e0f78|huibincanting|tianjin|ci_a1a3f433ce|Tianjin|Huibincanting
ve_bc52d20cb1|china-banquet|tianjin|ci_a1a3f433ce|Tianjin|China Banquet
ve_beb0308747|ember|tianjin|ci_a1a3f433ce|Tianjin|Ember
ve_d63a09c977|lake-yard-shuishanggongyuan-east-road|tianjin|ci_a1a3f433ce|Tianjin|Lake Yard (Shuishanggongyuan East Road)
ve_d87c05688e|yu-quan-fan-zhuang|tianjin|ci_a1a3f433ce|Tianjin|Yu Quan Fan Zhuang
ve_fbae621312|zheng-wei-zhai|tianjin|ci_a1a3f433ce|Tianjin|Zheng Wei Zhai$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(aw) <> '306bb1868c99bad516658b0216d39f67' OR md5(nw) <> '74e28b74cb143bfca47b81ba5f41e086' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.name||'|'||a.source_url t
    FROM awards a JOIN venues v ON v.id=a.venue_id
    WHERE a.source_id='michelin' AND v.city_id='ci_0420a206ae' AND a.year=2026 AND a.category IN ('Three Stars','Two Stars','One Star','Bib Gourmand')) y;
  IF fp IS DISTINCT FROM '2f2bf41fc129ab6fd894818228d1c3fb' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id WHERE a.source_id='michelin' AND v.city_id='ci_0420a206ae' AND a.year<>2026) <> 0 THEN RAISE EXCEPTION 'Beijing rows of another year'; END IF;
  IF (SELECT count(*) FROM venues) <> 11730 OR (SELECT count(*) FROM venues WHERE status='active') <> 11418 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28746 OR (SELECT max(id) FROM awards) <> 35917 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 172 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13674 OR (SELECT count(*) FROM listings) <> 11730 OR (SELECT count(*) FROM city_label_source) <> 24867 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3327 OR (SELECT sum(venues_count) FROM cities) <> 11418 OR (SELECT venues_count FROM cities WHERE id='ci_0420a206ae') <> 80 OR (SELECT count(*) FROM source_capture_ledger) <> 284 OR (SELECT max(id) FROM source_capture_ledger) <> 338 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='ci_a1a3f433ce' OR slug='tianjin') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)='tianjin') THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127778 OR aud_max <> 133607 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active' AND v.city_id='ci_0420a206ae');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN regexp_split_to_table(aw,E'\n') x ON a.source_url=split_part(x,'|',3) WHERE NOT (a.venue_id=split_part(x,'|',1) AND a.year=2026)) THEN RAISE EXCEPTION 'url in use by another venue or year'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2027 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION '2027 row exists'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: new city, venues, listings, slugs, city count
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('ci_a1a3f433ce', 'tianjin', 'Tianjin', 'China', 'CN', 'city', NULL, NULL, NULL, 17);
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count=87 WHERE id='ci_0420a206ae' AND venues_count=80;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count beijing'; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('China','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 48 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 82 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',82,'cleanup:load-michelin-2027-beijing-tianjin-2026-11-05 | Beijing & Tianjin 2027, https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-beijing-tianjin-2027 | Three Stars 2, Two Stars 5, One Star 27, Bib 48 | rule 2.1.7: 2026 rows stay, relabel 0, retire 0 | relay sha256 f1e9d7ed6382d85cd75b17195953747a6938b9bce3d4be548b1aee28ec84b608 | DRAFT, choices not yet given'),
    ('michelin','city_label',48,'cleanup:load-michelin-2027-beijing-tianjin-2026-11-05 | city labels of 24 new venues, new city tianjin | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11754 OR (SELECT count(*) FROM venues WHERE status='active') <> 11442 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28828 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 82 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '306bb1868c99bad516658b0216d39f67' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4329 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7521 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 254 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(c.slug||':'||a.category||'='||k, ',' ORDER BY c.slug, a.category) INTO s FROM (SELECT v.city_id, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id WHERE a.source_id='michelin' AND a.year=2027 AND v.city_id IN ('ci_0420a206ae','ci_a1a3f433ce') GROUP BY 1,2) a JOIN cities c ON c.id=a.city_id;
  IF s IS DISTINCT FROM 'beijing:Bib Gourmand=32,beijing:One Star=26,beijing:Three Stars=2,beijing:Two Stars=5,tianjin:Bib Gourmand=16,tianjin:One Star=1' THEN RAISE EXCEPTION 'after %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id WHERE a.source_id='michelin' AND v.city_id IN ('ci_0420a206ae','ci_a1a3f433ce') GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13698 OR (SELECT count(*) FROM listings) <> 11754 OR (SELECT count(*) FROM city_label_source) <> 24915 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3328 OR (SELECT sum(venues_count) FROM cities) <> 11442 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 286 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=82,cities:INSERT=1,cities:UPDATE=1,city_label_source:INSERT=48,listings:INSERT=24,slugs:INSERT=24,venues:INSERT=24' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
