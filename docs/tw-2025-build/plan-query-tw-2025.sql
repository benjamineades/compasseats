-- Taiwan 2025 plan query (read-only). plan md5 bc336e431b4fe6b4ebd2d8870d650357
WITH pj0 AS (SELECT '[[1, "Taipei", "Three Stars", "Le Palais", ""], [2, "Taipei", "Three Stars", "Ta\u00efrroir", ""], [3, "Taichung", "Three Stars", "JL Studio", ""], [4, "Taipei", "Two Stars", "A", "ve_269ab60a27"], [5, "Taipei", "Two Stars", "Eika", ""], [6, "Taipei", "Two Stars", "L''Atelier de Jo\u00ebl Robuchon", ""], [7, "Taipei", "Two Stars", "logy", ""], [8, "Taipei", "Two Stars", "Molino de Urd\u00e1niz", ""], [9, "Taipei", "Two Stars", "Mudan", "ve_da97d58bf1"], [10, "Taipei", "Two Stars", "Yu Kapo", ""], [11, "Taipei", "One Star", "A Cut", ""], [12, "Taipei", "One Star", "Ad Astra", ""], [13, "Taipei", "One Star", "aMaze", ""], [14, "Taipei", "One Star", "Ban Bo", ""], [15, "Taipei", "One Star", "Chuan Ya", ""], [16, "Taipei", "One Star", "Circum-", ""], [17, "Taipei", "One Star", "de nuit", ""], [18, "Taipei", "One Star", "FRASSI", ""], [19, "Taipei", "One Star", "Fujin Tree Taiwanese Cuisine & Champagne (Songshan)", ""], [20, "Taipei", "One Star", "Golden Formosa", ""], [21, "Taipei", "One Star", "Hosu", ""], [22, "Taipei", "One Star", "Impromptu by Paul Lee", ""], [23, "Taipei", "One Star", "INITA", ""], [24, "Taipei", "One Star", "Ken Anhe", ""], [25, "Taipei", "One Star", "Kitcho", ""], [26, "Taipei", "One Star", "La Vie by Thomas B\u00fchner", ""], [27, "Taipei", "One Star", "Ming Fu", ""], [28, "Taipei", "One Star", "Mipon", ""], [29, "Taipei", "One Star", "Motoichi", ""], [30, "Taipei", "One Star", "Mountain and Sea House", ""], [31, "Taipei", "One Star", "NOBUO", ""], [33, "Taipei", "One Star", "Sens", ""], [34, "Taipei", "One Star", "Shin Yeh Taiwanese Signature", ""], [35, "Taipei", "One Star", "Sushi Akira", ""], [36, "Taipei", "One Star", "Sushi Kajin", ""], [37, "Taipei", "One Star", "Sushi Ryu", ""], [38, "Taipei", "One Star", "Sushiyoshi", ""], [39, "Taipei", "One Star", "T+T", "ve_f2f22f4cec"], [40, "Taipei", "One Star", "The Guest House", ""], [41, "Taipei", "One Star", "Tien Hsiang Lo", ""], [42, "Taipei", "One Star", "Wok by O''BOND", ""], [43, "Taipei", "One Star", "Ya Ge", ""], [44, "Taipei", "One Star", "ZEA", ""], [45, "Taichung", "One Star", "Fleur de Sel", ""], [46, "Taichung", "One Star", "L''Atelier par Yao", ""], [47, "Taichung", "One Star", "Oretachi No Nikuya", ""], [48, "Taichung", "One Star", "Sur-", ""], [49, "Taichung", "One Star", "YUENJI", ""], [50, "Kaohsiung", "One Star", "GEN", ""], [51, "Kaohsiung", "One Star", "HAILI", ""], [52, "Kaohsiung", "One Star", "Sho", ""], [53, "Kaohsiung", "One Star", "the FRONT HOUSE", ""], [55, "Taipei", "Green Star", "Hosu", ""], [56, "Taipei", "Green Star", "Little Tree Food (Da''an Road)", ""], [57, "Taipei", "Green Star", "Mountain and Sea House", ""]]'::jsonb pj),
res AS (SELECT * FROM (SELECT 1) z, LATERAL (
WITH p AS (SELECT (e->>0)::int seq, e->>1 city, e->>2 cat, e->>3 nm, nullif(e->>4, '') use_vid
        FROM jsonb_array_elements((SELECT pj FROM pj0)) e),
  c(city, city_id) AS (VALUES ('Taipei', 'ci_39139f000b'), ('Taichung', 'ci_6d39e9b076'), ('Kaohsiung', 'ci_c65258d965')),
  pk AS (SELECT p.*, c.city_id, norm_key(p.nm) k1,
                norm_key(regexp_replace(p.nm, '\s*\([^)]*\)\s*$', '')) k2
           FROM p JOIN c USING (city)),
  vk AS (SELECT v.id, v.city_id, v.norm_key k1,
                norm_key(regexp_replace(v.name, '\s*\([^)]*\)\s*$', '')) k2
           FROM venues v WHERE v.city_id IN ('ci_39139f000b', 'ci_6d39e9b076', 'ci_c65258d965')),
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
SELECT * FROM r) q)
SELECT
  (SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3) || '|' || (e->>4), E'\n' ORDER BY (e->>0)::int)) FROM jsonb_array_elements((SELECT pj FROM pj0)) e) plan_md5_db,
  (SELECT count(*) FROM res) n,
  (SELECT string_agg(how || ':' || cnt, ',' ORDER BY how) FROM (SELECT how, count(*) cnt FROM res GROUP BY how) h) by_how,
  (SELECT md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq)) FROM res) seqvid_md5,
  (SELECT count(*) FROM res JOIN venues v ON v.id = res.vid AND v.city_id = res.city_id) in_city,
  (SELECT count(DISTINCT (vid, cat)) FROM res) distinct_vid_cat,
  (SELECT count(*) FROM res JOIN awards a ON a.venue_id = res.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = res.cat) existing_n,
  (SELECT count(*) FROM res JOIN awards a ON a.venue_id = res.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = res.cat AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) existing_clean,
  (SELECT md5(string_agg(a.id::text, ',' ORDER BY a.id)) FROM res JOIN awards a ON a.venue_id = res.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = res.cat) existing_ids_md5,
  (SELECT string_agg(a.id::text, ',' ORDER BY a.id) FROM res JOIN awards a ON a.venue_id = res.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = res.cat) existing_ids;
