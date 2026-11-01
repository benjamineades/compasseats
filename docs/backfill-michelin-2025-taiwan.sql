-- CompassEats, Nov 1 2026. Item 2 (H1): Michelin Guide Taiwan 2025 stars and Green Stars from the archive.
-- Ben, Nov 1 15:07 ET "J1, K1, L1, M1":
--   J1 fill source_url on the 38 existing 2025 star rows, insert 14 missing 2025 star rows and 3 Green Star rows.
--   K1 source_url = the archive id_ URL of the 2025 full list. L1 pairs A, Mudan (MUDAN TEMPURA), T+T by venue id.
--   M1 skip 5 lines with no venue (Paris 1930 de Hideki Takayama; EMBERS, Yangming Spring (Shilin), Tu Pang, Thomas Chien).
-- Source: https://web.archive.org/web/20251115192102id_/https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list
--   (read Nov 1 in the built-in browser; status 200; title "The Full List of the MICHELIN Guide Taiwan 2025").
-- Relay: docs/tw-2025-build/relay-tw-2025-archive-20251115192102.txt sha256 947c8ebe58654a2bc9df273a8b6c2d0a0d811293806d2503c57b4bf14c342e0a.
-- Built by docs/tw-2025-build/build_backfill_tw_2025.py from the relay (no retyped rows).
-- Venue match, inside this transaction: exact norm_key in the city (t1); else norm_key with the trailing "(branch)" removed
--   on both sides, 1 venue only (t2); else the L1 venue id. Gates: plan md5 bc336e431b4fe6b4ebd2d8870d650357; seq:venue md5 e3020258a28f9601f00f5db51552e3c1;
--   existing 2025 row ids md5 534c450601f38396bcd9a767182ddaa4.
-- Expected: awards UPDATE 38 (source_url) and INSERT 17 (michelin, 2025); 1 ledger row; 55 audit rows (trigger).
--   awards 23,543 -> 23,560. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  arch     text := 'https://web.archive.org/web/20251115192102id_/https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list';
  plan_txt text := '[[1, "Taipei", "Three Stars", "Le Palais", ""], [2, "Taipei", "Three Stars", "Ta\u00efrroir", ""], [3, "Taichung", "Three Stars", "JL Studio", ""], [4, "Taipei", "Two Stars", "A", "ve_269ab60a27"], [5, "Taipei", "Two Stars", "Eika", ""], [6, "Taipei", "Two Stars", "L''Atelier de Jo\u00ebl Robuchon", ""], [7, "Taipei", "Two Stars", "logy", ""], [8, "Taipei", "Two Stars", "Molino de Urd\u00e1niz", ""], [9, "Taipei", "Two Stars", "Mudan", "ve_da97d58bf1"], [10, "Taipei", "Two Stars", "Yu Kapo", ""], [11, "Taipei", "One Star", "A Cut", ""], [12, "Taipei", "One Star", "Ad Astra", ""], [13, "Taipei", "One Star", "aMaze", ""], [14, "Taipei", "One Star", "Ban Bo", ""], [15, "Taipei", "One Star", "Chuan Ya", ""], [16, "Taipei", "One Star", "Circum-", ""], [17, "Taipei", "One Star", "de nuit", ""], [18, "Taipei", "One Star", "FRASSI", ""], [19, "Taipei", "One Star", "Fujin Tree Taiwanese Cuisine & Champagne (Songshan)", ""], [20, "Taipei", "One Star", "Golden Formosa", ""], [21, "Taipei", "One Star", "Hosu", ""], [22, "Taipei", "One Star", "Impromptu by Paul Lee", ""], [23, "Taipei", "One Star", "INITA", ""], [24, "Taipei", "One Star", "Ken Anhe", ""], [25, "Taipei", "One Star", "Kitcho", ""], [26, "Taipei", "One Star", "La Vie by Thomas B\u00fchner", ""], [27, "Taipei", "One Star", "Ming Fu", ""], [28, "Taipei", "One Star", "Mipon", ""], [29, "Taipei", "One Star", "Motoichi", ""], [30, "Taipei", "One Star", "Mountain and Sea House", ""], [31, "Taipei", "One Star", "NOBUO", ""], [33, "Taipei", "One Star", "Sens", ""], [34, "Taipei", "One Star", "Shin Yeh Taiwanese Signature", ""], [35, "Taipei", "One Star", "Sushi Akira", ""], [36, "Taipei", "One Star", "Sushi Kajin", ""], [37, "Taipei", "One Star", "Sushi Ryu", ""], [38, "Taipei", "One Star", "Sushiyoshi", ""], [39, "Taipei", "One Star", "T+T", "ve_f2f22f4cec"], [40, "Taipei", "One Star", "The Guest House", ""], [41, "Taipei", "One Star", "Tien Hsiang Lo", ""], [42, "Taipei", "One Star", "Wok by O''BOND", ""], [43, "Taipei", "One Star", "Ya Ge", ""], [44, "Taipei", "One Star", "ZEA", ""], [45, "Taichung", "One Star", "Fleur de Sel", ""], [46, "Taichung", "One Star", "L''Atelier par Yao", ""], [47, "Taichung", "One Star", "Oretachi No Nikuya", ""], [48, "Taichung", "One Star", "Sur-", ""], [49, "Taichung", "One Star", "YUENJI", ""], [50, "Kaohsiung", "One Star", "GEN", ""], [51, "Kaohsiung", "One Star", "HAILI", ""], [52, "Kaohsiung", "One Star", "Sho", ""], [53, "Kaohsiung", "One Star", "the FRONT HOUSE", ""], [55, "Taipei", "Green Star", "Hosu", ""], [56, "Taipei", "Green Star", "Little Tree Food (Da''an Road)", ""], [57, "Taipei", "Green Star", "Mountain and Sea House", ""]]';
  job_txt  text := 'backfill:michelin-2025-taiwan-archive | item 2 H1 (Ben, Nov 1 15:07 ET "J1, K1, L1, M1"): Michelin Guide Taiwan 2025 stars and Green Stars from the web.archive.org capture 20251115192102 of the 2025 full list | 38 existing 2025 star rows get the source_url; 17 rows inserted (One Star 13, Two Stars 1, Green Star 3) | source_url = https://web.archive.org/web/20251115192102id_/https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list | relay docs/tw-2025-build/relay-tw-2025-archive-20251115192102.txt sha256 947c8ebe...342e0a | Green Star heading says 6, list and the Aug 19, 2025 ceremony article name 7 | L1 pairs: A -> ve_269ab60a27; Mudan -> MUDAN TEMPURA ve_da97d58bf1; T+T -> ve_f2f22f4cec (norm_key NULL for A and T+T) | M1 skipped, no venue: Paris 1930 de Hideki Takayama (One Star 2025, Selected 2026); EMBERS (Green Star only); Yangming Spring (Shilin) (Green Star only); Tu Pang (Green Star only); Thomas Chien (Green Star only) | 2025 Bibs: no archive full list (Bib article 20250812045317 names only some), no change | plan md5 bc336e431b4fe6b4ebd2d8870d650357';
  pj jsonb; rj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3) || '|' || (e->>4), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> 'bc336e431b4fe6b4ebd2d8870d650357' OR cnt <> 55 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected bc336e431b4fe6b4ebd2d8870d650357 / 55)', txt, cnt; END IF;

  WITH p AS (SELECT (e->>0)::int seq, e->>1 city, e->>2 cat, e->>3 nm, nullif(e->>4, '') use_vid
          FROM jsonb_array_elements(pj) e),
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
  SELECT jsonb_agg(jsonb_build_array(seq, cat, city_id, vid, how) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> 'e3020258a28f9601f00f5db51552e3c1' THEN RAISE EXCEPTION 'seq:venue md5 % (expected e3020258a28f9601f00f5db51552e3c1)', txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN venues v ON v.id = r.vid AND v.city_id = r.city_id;
  IF cnt <> 55 THEN RAISE EXCEPTION 'venues in the stated city % (expected 55)', cnt; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 55 THEN RAISE EXCEPTION 'distinct venue + category % (expected 55)', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> 38 OR txt <> '534c450601f38396bcd9a767182ddaa4' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected 38 / 534c450601f38396bcd9a767182ddaa4)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> 38 THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected 38)', cnt; END IF;

  -- 2. Counts before (read Nov 1 20:08:14 UTC)
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> 23543 OR num <> 30482 THEN RAISE EXCEPTION 'awards before % / max % (expected 23543 / 30482)', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 9839 THEN RAISE EXCEPTION 'Michelin awards before % (expected 9839)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 3463 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3463)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3281 THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected 3281)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 9 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 9)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_39139f000b', 'ci_6d39e9b076', 'ci_c65258d965');
                                                IF cnt <> 112 THEN RAISE EXCEPTION 'Taipei/Taichung/Kaohsiung Michelin 2025 before % (expected 112)', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 160 OR led_max <> 211 THEN RAISE EXCEPTION 'ledger before % / max % (expected 160 / 211)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 116423 OR aud_max <> 121935 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 116423 / 121935)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = arch
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 38 THEN RAISE EXCEPTION 'award rows updated % (expected 38)', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, arch FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 17 THEN RAISE EXCEPTION 'award rows inserted % (expected 17)', cnt; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 55, job_txt);
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', cnt; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO cnt FROM awards;         IF cnt <> 23560 THEN RAISE EXCEPTION 'awards after % (expected 23560)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 9856 THEN RAISE EXCEPTION 'Michelin awards after % (expected 9856)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 3480 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3480)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3243 THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected 3243)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 12 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 12)', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a JOIN venues v ON v.id = a.venue_id
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_39139f000b', 'ci_6d39e9b076', 'ci_c65258d965')
       AND a.source_url = arch AND a.rank IS NULL AND a.distinction IS NULL GROUP BY a.category) g;
  IF cnt <> 55 OR txt <> 'Green Star:3,One Star:42,Three Stars:3,Two Stars:7'
    THEN RAISE EXCEPTION 'Taiwan Michelin 2025 with the archive URL % / % (expected 55)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_39139f000b', 'ci_6d39e9b076', 'ci_c65258d965');
                                                IF cnt <> 129 THEN RAISE EXCEPTION 'Taipei/Taichung/Kaohsiung Michelin 2025 after % (expected 129)', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat AND a.source_url = arch;
  IF txt <> 'e3020258a28f9601f00f5db51552e3c1' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected e3020258a28f9601f00f5db51552e3c1)', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> 161 THEN RAISE EXCEPTION 'ledger after % (expected 161)', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 55 AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> 55 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 55)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' = arch;
  IF cnt <> 17 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 17)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = arch
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> 38 THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected 38)', cnt; END IF;
END
$do$;
COMMIT;
