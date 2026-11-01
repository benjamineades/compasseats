-- CompassEats, Nov 1 2026. D8: Michelin Guide Hong Kong & Macau 2025 history backfill.
-- Ben, Nov 1 13:22 ET "A2, B1, C1, D1, E1":
--   A2 Stars, Bib Gourmand and Green Star rows. B1 source_url = the archive id_ URL of the 2025 full list.
--   C1 8 name pairs proved by the 2026 card, plus Din Tai Fung (Tsim Sha Tsui) = card din-tai-fung-silvercord.
--   D1 skip Man Yuen, Sun Yuen Hing Kee, What To Eat (no venue). E1 row 10529 gets the source_url only.
-- Source: https://web.archive.org/web/20251229115831id_/https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list
--   (read Nov 1 in the built-in browser; status 200, 0 redirects; title "The Full List of the MICHELIN Guide Hong Kong & Macau 2025").
-- Relay: docs/hkmo-2025-build/relay-hkmo-2025-archive-20251229115831.txt sha256 02bf30b13374118617211cf4973146b8048784e3717366e6aabcff5a9c0ca81b.
-- Built by docs/hkmo-2025-build/build_backfill_hkmo_2025.py (sha256 dde11dc5c093314e17b7f27c4a85c28872f9a1f95846d54ba33c24e36602da3a) from the relay (no retyped rows).
-- Venue match, inside this transaction: exact norm_key in the city (t1); else norm_key with the trailing "(branch)" removed
--   on both sides, 1 venue only (t2); else the C1 venue id. Gates: plan md5 21797d76c3053f1fc992cf5e07d6fda1; seq:venue md5 25d612df6b72c2fe467b5db320cf07cb.
-- Expected: awards INSERT 172 (michelin, 2025) and UPDATE 1 (id 10529, source_url); 1 ledger row; 173 audit rows (trigger).
--   awards 23,371 -> 23,543. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '[[1, "Hong Kong", "Three Stars", "8 1/2 Otto e Mezzo - Bombana", ""], [2, "Hong Kong", "Three Stars", "Amber", ""], [3, "Hong Kong", "Three Stars", "Caprice", ""], [4, "Hong Kong", "Three Stars", "Forum", ""], [5, "Hong Kong", "Three Stars", "Sushi Shikon", ""], [6, "Hong Kong", "Three Stars", "Ta Vie", ""], [7, "Hong Kong", "Three Stars", "T''ang Court", ""], [8, "Hong Kong", "Two Stars", "Arbor", ""], [9, "Hong Kong", "Two Stars", "Bo Innovation", ""], [10, "Hong Kong", "Two Stars", "Lai Ching Heen", ""], [11, "Hong Kong", "Two Stars", "L''Envol", ""], [12, "Hong Kong", "Two Stars", "Lung King Heen", ""], [13, "Hong Kong", "Two Stars", "Noi by Paulo Airaudo", "ve_a32153f7bc"], [14, "Hong Kong", "Two Stars", "Octavium", ""], [15, "Hong Kong", "Two Stars", "R\u00f9n", ""], [16, "Hong Kong", "Two Stars", "Tate", ""], [17, "Hong Kong", "Two Stars", "Tin Lung Heen", ""], [18, "Hong Kong", "Two Stars", "Ying Jee Club", ""], [19, "Hong Kong", "One Star", "Ami", ""], [20, "Hong Kong", "One Star", "And\u014d", ""], [21, "Hong Kong", "One Star", "Arcane", ""], [22, "Hong Kong", "One Star", "Beefbar", ""], [23, "Hong Kong", "One Star", "Belon", ""], [24, "Hong Kong", "One Star", "Chaat", ""], [25, "Hong Kong", "One Star", "Cristal Room by Anne-Sophie Pic", ""], [26, "Hong Kong", "One Star", "Duddell''s", ""], [27, "Hong Kong", "One Star", "\u00c9pure", ""], [28, "Hong Kong", "One Star", "Estro", ""], [29, "Hong Kong", "One Star", "Feuille", ""], [30, "Hong Kong", "One Star", "Fook Lam Moon (Wan Chai)", ""], [31, "Hong Kong", "One Star", "Fu Ho", ""], [32, "Hong Kong", "One Star", "Gaddi''s", ""], [33, "Hong Kong", "One Star", "Godenya", ""], [34, "Hong Kong", "One Star", "Hansik Goo", ""], [35, "Hong Kong", "One Star", "Ho Hung Kee (Causeway Bay)", ""], [36, "Hong Kong", "One Star", "I M Teppanyaki & Wine", ""], [37, "Hong Kong", "One Star", "Imperial Treasure Fine Chinese Cuisine (Tsim Sha Tsui)", ""], [38, "Hong Kong", "One Star", "Kam''s Roast Goose", ""], [39, "Hong Kong", "One Star", "Kappo Rin", ""], [40, "Hong Kong", "One Star", "Liu Yuan Pavilion", ""], [41, "Hong Kong", "One Star", "Loaf On", ""], [42, "Hong Kong", "One Star", "Louise", ""], [43, "Hong Kong", "One Star", "Man Ho (Admiralty)", ""], [44, "Hong Kong", "One Star", "Man Wah", ""], [45, "Hong Kong", "One Star", "Mono", ""], [46, "Hong Kong", "One Star", "Mora", ""], [47, "Hong Kong", "One Star", "Nagamoto", ""], [48, "Hong Kong", "One Star", "Neighborhood", ""], [49, "Hong Kong", "One Star", "New Punjab Club", ""], [50, "Hong Kong", "One Star", "Pang''s Kitchen", ""], [51, "Hong Kong", "One Star", "Petrus", ""], [52, "Hong Kong", "One Star", "Plaisance by Mauro Colagreco", ""], [53, "Hong Kong", "One Star", "Racines", ""], [54, "Hong Kong", "One Star", "Roganic", ""], [55, "Hong Kong", "One Star", "Ryota Kappou Modern", ""], [56, "Hong Kong", "One Star", "Seventh Son (Wan Chai)", "ve_712b801106"], [57, "Hong Kong", "One Star", "Shang Palace", ""], [58, "Hong Kong", "One Star", "Spring Moon", ""], [59, "Hong Kong", "One Star", "Summer Palace", ""], [60, "Hong Kong", "One Star", "Sun Tung Lok", "ve_dd9a5ae60b"], [61, "Hong Kong", "One Star", "Sushi Saito", ""], [62, "Hong Kong", "One Star", "Sushi Wadatsumi", ""], [63, "Hong Kong", "One Star", "The Chairman", ""], [64, "Hong Kong", "One Star", "The Legacy House", ""], [65, "Hong Kong", "One Star", "Tosca di Angelo", ""], [66, "Hong Kong", "One Star", "Tuber Umberto Bombana", ""], [67, "Hong Kong", "One Star", "Vea", ""], [68, "Hong Kong", "One Star", "Whey", ""], [69, "Hong Kong", "One Star", "Xin Rong Ji", ""], [70, "Hong Kong", "One Star", "Yardbird", ""], [71, "Hong Kong", "One Star", "Yat Lok (Central)", ""], [72, "Hong Kong", "One Star", "Yat Tung Heen", ""], [73, "Hong Kong", "One Star", "Y\u00e8 Shanghai (Tsim Sha Tsui)", ""], [74, "Hong Kong", "One Star", "Yong Fu", ""], [75, "Hong Kong", "One Star", "Zhejiang Heen", ""], [76, "Hong Kong", "One Star", "Zuicho", ""], [142, "Hong Kong", "Green Star", "Amber", ""], [143, "Hong Kong", "Green Star", "Feuille", ""], [144, "Hong Kong", "Green Star", "Mora", ""], [145, "Hong Kong", "Green Star", "Roganic", ""], [146, "Hong Kong", "Bib Gourmand", "Ah Chun Shandong Dumpling", ""], [147, "Hong Kong", "Bib Gourmand", "\u0102n Ch\u01a1i", ""], [148, "Hong Kong", "Bib Gourmand", "Art & Taste", ""], [149, "Hong Kong", "Bib Gourmand", "Ba Yi", ""], [150, "Hong Kong", "Bib Gourmand", "Banana Boy", ""], [151, "Hong Kong", "Bib Gourmand", "Caf\u00e9 Hunan (Western District)", "ve_8a5d5ef4fe"], [152, "Hong Kong", "Bib Gourmand", "Cheung Hing Kee (Tsim Sha Tsui)", ""], [153, "Hong Kong", "Bib Gourmand", "Chiu Ka Banquet", ""], [154, "Hong Kong", "Bib Gourmand", "Chiuchow Delicacies", ""], [155, "Hong Kong", "Bib Gourmand", "Din Tai Fung (Causeway Bay)", ""], [156, "Hong Kong", "Bib Gourmand", "Din Tai Fung (Tsim Sha Tsui)", "ve_69f6dd939a"], [157, "Hong Kong", "Bib Gourmand", "Dragon Inn", ""], [158, "Hong Kong", "Bib Gourmand", "Eng Kee Noodle Shop", ""], [159, "Hong Kong", "Bib Gourmand", "Eton", ""], [160, "Hong Kong", "Bib Gourmand", "Fisholic (North Point)", ""], [161, "Hong Kong", "Bib Gourmand", "Fung Shing (North Point)", ""], [162, "Hong Kong", "Bib Gourmand", "Glorious Cuisine", ""], [163, "Hong Kong", "Bib Gourmand", "Hao Tang Hao Mian (Tai Wai)", ""], [164, "Hong Kong", "Bib Gourmand", "Heartwarming (Prince Edward)", ""], [165, "Hong Kong", "Bib Gourmand", "Ho To Tai", ""], [166, "Hong Kong", "Bib Gourmand", "Ju Xing Home", ""], [167, "Hong Kong", "Bib Gourmand", "Juno", ""], [168, "Hong Kong", "Bib Gourmand", "Kai Kai (Jordan)", ""], [169, "Hong Kong", "Bib Gourmand", "Kau Kee", ""], [170, "Hong Kong", "Bib Gourmand", "Keung Kee", ""], [171, "Hong Kong", "Bib Gourmand", "Kung Wo Beancurd Factory", ""], [172, "Hong Kong", "Bib Gourmand", "Kwan Kee Bamboo Noodles", ""], [173, "Hong Kong", "Bib Gourmand", "Kwan Kee Clay Pot Rice (Queen''s Road West)", ""], [174, "Hong Kong", "Bib Gourmand", "Lau Sum Kee (Fuk Wing Street)", ""], [175, "Hong Kong", "Bib Gourmand", "Little Napoli", ""], [176, "Hong Kong", "Bib Gourmand", "Lucky Indonesia", ""], [177, "Hong Kong", "Bib Gourmand", "Mak Man Kee", ""], [179, "Hong Kong", "Bib Gourmand", "Megan''s Kitchen", ""], [180, "Hong Kong", "Bib Gourmand", "Po Kee", ""], [181, "Hong Kong", "Bib Gourmand", "Putien (Causeway Bay)", ""], [182, "Hong Kong", "Bib Gourmand", "Samsen (Wan Chai)", ""], [183, "Hong Kong", "Bib Gourmand", "Sang Kee", ""], [184, "Hong Kong", "Bib Gourmand", "Sang Kee Foods (Western District)", ""], [185, "Hong Kong", "Bib Gourmand", "Saya", ""], [186, "Hong Kong", "Bib Gourmand", "She Wong Leung", ""], [187, "Hong Kong", "Bib Gourmand", "Shek Kee Kitchen", ""], [188, "Hong Kong", "Bib Gourmand", "Ship Kee", ""], [189, "Hong Kong", "Bib Gourmand", "Shugetsu Ramen (Central)", ""], [190, "Hong Kong", "Bib Gourmand", "Sing Kee", "ve_6fc44f5547"], [191, "Hong Kong", "Bib Gourmand", "Sister Wah", ""], [193, "Hong Kong", "Bib Gourmand", "Tai Wai Dining Room (Tai Wai)", ""], [194, "Hong Kong", "Bib Gourmand", "Tai Wing Wah", ""], [195, "Hong Kong", "Bib Gourmand", "Tai Woo", "ve_af6cfd76ec"], [196, "Hong Kong", "Bib Gourmand", "Tak Kee", "ve_0f96babf05"], [197, "Hong Kong", "Bib Gourmand", "Takeya", ""], [198, "Hong Kong", "Bib Gourmand", "Tasty (Central)", "ve_2020552694"], [199, "Hong Kong", "Bib Gourmand", "Thai Pai Dong", ""], [200, "Hong Kong", "Bib Gourmand", "Tim Ho Wan (Sham Shui Po)", ""], [201, "Hong Kong", "Bib Gourmand", "Tin Hung", ""], [202, "Hong Kong", "Bib Gourmand", "Trusty Congee King (Wan Chai)", ""], [203, "Hong Kong", "Bib Gourmand", "Tsim Chai Kee (Wellington Street)", ""], [204, "Hong Kong", "Bib Gourmand", "Twins Liangpi Limited (Mong Kok)", ""], [205, "Hong Kong", "Bib Gourmand", "Wang Fu", ""], [207, "Hong Kong", "Bib Gourmand", "Wing Lai Yuen", ""], [208, "Hong Kong", "Bib Gourmand", "Yi Jia", ""], [209, "Hong Kong", "Bib Gourmand", "Yuan is Here (Western District)", ""], [210, "Hong Kong", "Bib Gourmand", "Yue Kee", ""], [211, "Macau", "Three Stars", "Jade Dragon", ""], [212, "Macau", "Three Stars", "Robuchon au D\u00f4me", ""], [213, "Macau", "Two Stars", "Alain Ducasse at Morpheus", ""], [214, "Macau", "Two Stars", "Chef Tam''s Seasons", ""], [215, "Macau", "Two Stars", "Feng Wei Ju", ""], [216, "Macau", "Two Stars", "The Eight", ""], [217, "Macau", "Two Stars", "The Huaiyang Garden", ""], [218, "Macau", "Two Stars", "Wing Lei", ""], [219, "Macau", "One Star", "8 1/2 Otto e Mezzo - Bombana", ""], [220, "Macau", "One Star", "Aji", ""], [221, "Macau", "One Star", "Five Foot Road", ""], [222, "Macau", "One Star", "Lai Heen", ""], [223, "Macau", "One Star", "Mizumi", ""], [224, "Macau", "One Star", "Pearl Dragon", ""], [225, "Macau", "One Star", "Sushi Kinetsu", ""], [226, "Macau", "One Star", "Sushi Kissho by Miyakawa", ""], [227, "Macau", "One Star", "Ying", ""], [228, "Macau", "One Star", "Zi Yat Heen", ""], [229, "Macau", "One Star", "Zuicho", ""], [254, "Macau", "Green Star", "UTM Educational Restaurant", ""], [255, "Macau", "Bib Gourmand", "Chan Seng Kei", ""], [256, "Macau", "Bib Gourmand", "Cheong Kei", ""], [257, "Macau", "Bib Gourmand", "Din Tai Fung (COD)", ""], [258, "Macau", "Bib Gourmand", "Justindia", ""], [259, "Macau", "Bib Gourmand", "Kapok", ""], [260, "Macau", "Bib Gourmand", "Lok Kei Noodles (Patane)", ""], [261, "Macau", "Bib Gourmand", "Lou Kei", ""], [262, "Macau", "Bib Gourmand", "O Casti\u00e7o", ""], [263, "Macau", "Bib Gourmand", "Restaurante Litoral (Taipa)", ""], [264, "Macau", "Bib Gourmand", "Son Tak Kong", ""], [265, "Macau", "Bib Gourmand", "UTM Educational Restaurant", ""]]';
  arch     text := 'https://web.archive.org/web/20251229115831id_/https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list';
  job_txt  text := 'backfill:michelin-2025-hong-kong-macau-archive | D8 (Ben, Nov 1 13:22 ET "A2, B1, C1, D1, E1"): Michelin Guide Hong Kong & Macau 2025 history from the web.archive.org capture 20251229115831 of the 2025 full list | 172 award rows inserted (Three Stars 9, Two Stars 17, One Star 69, Bib Gourmand 72, Green Star 5; Hong Kong 141, Macau 31) and row 10529 source_url filled (E1) | source_url = https://web.archive.org/web/20251229115831id_/https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list | relay docs/hkmo-2025-build/relay-hkmo-2025-archive-20251229115831.txt sha256 02bf30b1...0ca81b | C1 pairs by the 2026 card: Noi by Paulo Airaudo -> Noi ve_a32153f7bc; Seventh Son (Wan Chai) -> ve_712b801106; Sun Tung Lok -> ve_dd9a5ae60b; Cafe Hunan (Western District) -> Prof Chan''s ve_8a5d5ef4fe; Sing Kee -> ve_6fc44f5547; Tai Woo -> ve_af6cfd76ec; Tak Kee -> ve_0f96babf05; Tasty (Central) -> ve_2020552694; Din Tai Fung (Tsim Sha Tsui) -> ve_69f6dd939a (card din-tai-fung-silvercord) | D1 skipped, no venue: Man Yuen, Sun Yuen Hing Kee, What To Eat (Hong Kong 2025 Bib Gourmand) | plan md5 21797d76c3053f1fc992cf5e07d6fda1';
  pj jsonb; rj jsonb;
  n int; x int; s text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3) || '|' || (e->>4), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO s, n FROM jsonb_array_elements(pj) e;
  IF s <> '21797d76c3053f1fc992cf5e07d6fda1' OR n <> 173 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected 21797d76c3053f1fc992cf5e07d6fda1 / 173)', s, n; END IF;

  -- The resolved plan is kept in rj (jsonb), so the dry run needs no temp table.
  WITH p AS (SELECT (e->>0)::int seq, e->>1 region, e->>2 cat, e->>3 nm, nullif(e->>4, '') use_vid
        FROM jsonb_array_elements(pj) e),
  c(region, city_id) AS (VALUES ('Hong Kong', 'ci_1b1537ad28'), ('Macau', 'ci_9690a92f29')),
  pk AS (SELECT p.*, c.city_id, norm_key(p.nm) k1,
                norm_key(regexp_replace(p.nm, '\s*\([^)]*\)\s*$', '')) k2
           FROM p JOIN c USING (region)),
  vk AS (SELECT v.id, v.city_id, v.norm_key k1,
                norm_key(regexp_replace(v.name, '\s*\([^)]*\)\s*$', '')) k2
           FROM venues v WHERE v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29')),
  t1 AS (SELECT pk.seq, count(*) n, min(vk.id) vid FROM pk JOIN vk ON vk.city_id = pk.city_id AND vk.k1 = pk.k1 GROUP BY pk.seq),
  t2 AS (SELECT pk.seq, count(*) n, min(vk.id) vid FROM pk JOIN vk ON vk.city_id = pk.city_id AND vk.k2 = pk.k2 GROUP BY pk.seq),
  r AS (SELECT pk.seq, pk.cat, pk.city_id,
          CASE WHEN pk.use_vid IS NOT NULL THEN pk.use_vid
               WHEN t1.n = 1 THEN t1.vid
               WHEN t1.n IS NULL AND t2.n = 1 THEN t2.vid END vid,
          CASE WHEN pk.use_vid IS NOT NULL THEN 'use'
               WHEN t1.n = 1 THEN 't1'
               WHEN t1.n IS NULL AND t2.n = 1 THEN 't2' ELSE 'none' END how
        FROM pk LEFT JOIN t1 USING (seq) LEFT JOIN t2 USING (seq))
  SELECT jsonb_agg(jsonb_build_array(seq, cat, city_id, vid, how) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO n, s FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) d;
  IF n <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', n; END IF;
  IF s <> '25d612df6b72c2fe467b5db320cf07cb' THEN RAISE EXCEPTION 'seq:venue md5 % (expected 25d612df6b72c2fe467b5db320cf07cb)', s; END IF;
  SELECT count(*) INTO x FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN venues v ON v.id = r.vid AND v.city_id = r.city_id;
  IF x <> 173 THEN RAISE EXCEPTION 'venues in the stated city % (expected 173)', x; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO x FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) d;
  IF x <> 173 THEN RAISE EXCEPTION 'distinct venue + category % (expected 173)', x; END IF;

  SELECT count(*), string_agg(a.id::text, ',') INTO x, s FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF x <> 1 OR s <> '10529' THEN RAISE EXCEPTION 'existing Michelin 2025 rows on the plan % / ids % (expected 1 / 10529)', x, s; END IF;
  SELECT count(*) INTO x FROM awards WHERE id = 10529 AND venue_id = 've_d7e57d1d84' AND source_id = 'michelin'
     AND year = 2025 AND category = 'Bib Gourmand' AND rank IS NULL AND distinction IS NULL AND source_url IS NULL;
  IF x <> 1 THEN RAISE EXCEPTION 'row 10529 is not as read (Chiu Chow Delicacies, 2025 Bib, no URL)'; END IF;

  -- 2. Counts before (read Nov 1 18:22:38 UTC)
  SELECT count(*), max(id) INTO x, n FROM awards;
  IF x <> 23371 OR n <> 30138 THEN RAISE EXCEPTION 'awards before % / max % (expected 23371 / 30138)', x, n; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9667 THEN RAISE EXCEPTION 'Michelin awards before % (expected 9667)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF x <> 3291 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3291)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF x <> 4 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29');
                                                IF x <> 1 THEN RAISE EXCEPTION 'HK/MO Michelin 2025 before % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;  IF x <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 159 OR led_max <> 209 THEN RAISE EXCEPTION 'ledger before % / max % (expected 159 / 209)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 116249 OR aud_max <> 121587 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 116249 / 121587)', aud_n, aud_max; END IF;

  -- 3. Write
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, arch FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 172 THEN RAISE EXCEPTION 'award rows inserted % (expected 172)', n; END IF;

  UPDATE awards SET source_url = arch
   WHERE id = 10529 AND venue_id = 've_d7e57d1d84' AND year = 2025 AND category = 'Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'row 10529 updated % (expected 1)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 173, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM awards;           IF x <> 23543 THEN RAISE EXCEPTION 'awards after % (expected 23543)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9839 THEN RAISE EXCEPTION 'Michelin awards after % (expected 9839)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF x <> 3463 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3463)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF x <> 9 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 9)', x; END IF;
  SELECT string_agg(category || ':' || n, ',' ORDER BY category), sum(n) INTO s, x FROM (
    SELECT a.category, count(*) n FROM awards a JOIN venues v ON v.id = a.venue_id
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29')
       AND a.source_url = arch AND a.rank IS NULL AND a.distinction IS NULL GROUP BY a.category) g;
  IF x <> 173 OR s <> 'Bib Gourmand:73,Green Star:5,One Star:69,Three Stars:9,Two Stars:17'
    THEN RAISE EXCEPTION 'HK/MO Michelin 2025 with the archive URL % / % (expected 173)', x, s; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29');
                                                IF x <> 173 THEN RAISE EXCEPTION 'HK/MO Michelin 2025 after % (expected 173)', x; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO s
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat AND a.source_url = arch;
  IF s <> '25d612df6b72c2fe467b5db320cf07cb' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected 25d612df6b72c2fe467b5db320cf07cb)', s; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11299 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3260 THEN RAISE EXCEPTION 'cities changed: %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;  IF x <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', x; END IF;

  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 160 THEN RAISE EXCEPTION 'ledger after % (expected 160)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 173 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 173 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 173)', x; END IF;
  SELECT count(*) INTO x FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' = arch;
  IF x <> 172 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 172)', x; END IF;
  SELECT count(*) INTO x FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE' AND al.row_pk = '10529'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = arch;
  IF x <> 1 THEN RAISE EXCEPTION 'audit UPDATE row for 10529 % (expected 1)', x; END IF;
END
$do$;
COMMIT;
