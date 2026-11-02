-- CompassEats, Nov 1 2026. Item 4: Michelin Guide Japan 2025 (Tokyo, Kyoto Osaka, Nara), complete page sets only.
-- Ben, Nov 1 21:50 ET "J1 & K1" (J1 = complete sets only: Green Stars of all 4 guides, Three Stars Tokyo / Kyoto / Osaka,
--   Two Stars Kyoto / Osaka; K1 = Naramachi Kuko pair after the own-site check).
-- Sources (read Nov 1-2 in the built-in browser; status 200; 0 redirects). Page total = the 2025 article total:
--   T|green  https://web.archive.org/web/20250712063411id_/https://guide.michelin.com/jp/ja/tokyo-region/restaurants/sustainable_gastronomy  (12)
--   T|3      https://web.archive.org/web/20250122140437id_/https://guide.michelin.com/jp/ja/tokyo-region/restaurants/3-stars-michelin  (12)
--   K|green  https://web.archive.org/web/20250401023911id_/https://guide.michelin.com/jp/en/kyoto-region/restaurants/sustainable_gastronomy  (10)
--   K|3      https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/kyoto-region/restaurants/3-stars-michelin  (5)
--   K|2      https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/kyoto-region/restaurants/2-stars-michelin  (16)
--   O|green  https://web.archive.org/web/20250401023911id_/https://guide.michelin.com/jp/en/osaka-region/restaurants/sustainable_gastronomy  (3)
--   O|3      https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/osaka-region/restaurants/3-stars-michelin  (3)
--   O|2      https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/osaka-region/restaurants/2-stars-michelin  (11)
--   N|green  https://web.archive.org/web/20250714130145id_/https://guide.michelin.com/jp/en/nara-region/restaurants/sustainable_gastronomy  (7)
-- Relay sha256 ceab8dbaf2ffabb7f2ddab92ca72ac2ed99a19db45a1a5d6b76d60afa5db99e1; URL map md5 1a3b6ca0e06507fedaa5e182ee510e27.
-- Built by docs/jp-2025-build/build_backfill_jp_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in JP ('card'); else the venue id in the build script ('use': SEZANNE V1, Naramachi Kuko K1).
--   Gates: plan md5 136fb83c77f027186f2e3e107d6122f0; seq:venue md5 e9c2152fd28a3a28c9d04c184dcea0a6; existing 2025 row ids md5 71f6278d140af599e06ad9bf1ba03cb0.
-- Expected: awards UPDATE 1 (source_url) and INSERT 70 (michelin, 2025); 1 ledger row; 71 audit rows (trigger).
--   awards 24,643 -> 24,713. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '[[1, "Green Star", "la-paix-1194221", "", "T|green"], [2, "Green Star", "faro-1194154", "", "T|green"], [4, "Green Star", "florilege", "", "T|green"], [5, "Green Star", "daigo", "", "T|green"], [6, "Green Star", "den", "", "T|green"], [7, "Green Star", "crony-1194937", "", "T|green"], [8, "Green Star", "sincere", "", "T|green"], [9, "Green Star", "narisawa", "", "T|green"], [10, "Green Star", "l-effervescence", "", "T|green"], [11, "Green Star", "lature", "", "T|green"], [12, "Green Star", "nol", "", "T|green"], [13, "Three Stars", "kanda", "", "T|3"], [14, "Three Stars", "azabu-kadowaki", "", "T|3"], [15, "Three Stars", "kohaku", "", "T|3"], [16, "Three Stars", "sezanne", "ve_05c8533123", "T|3"], [17, "Three Stars", "harutaka", "", "T|3"], [18, "Three Stars", "l-osier", "", "T|3"], [19, "Three Stars", "kagurazaka-ishikawa", "", "T|3"], [20, "Three Stars", "ryugin-1194232", "", "T|3"], [21, "Three Stars", "l-effervescence", "", "T|3"], [22, "Three Stars", "joel-robuchon-1193981", "", "T|3"], [23, "Three Stars", "quintessence-1193907", "", "T|3"], [24, "Three Stars", "sazenka", "", "T|3"], [26, "Green Star", "shigetsu", "", "K|green"], [27, "Green Star", "la-buche", "", "K|green"], [29, "Green Star", "miyamaso", "", "K|green"], [30, "Green Star", "juu-go", "", "K|green"], [31, "Green Star", "tan", "", "K|green"], [32, "Green Star", "kodaiji-wakuden", "", "K|green"], [33, "Green Star", "muromachi-wakuden", "", "K|green"], [34, "Green Star", "sojiki-nakahigashi", "", "K|green"], [35, "Three Stars", "mizai", "", "K|3"], [36, "Three Stars", "gion-sasaki", "", "K|3"], [37, "Three Stars", "isshisoden-nakamura", "", "K|3"], [38, "Three Stars", "hyotei", "", "K|3"], [39, "Three Stars", "kikunoi-honten", "", "K|3"], [40, "Two Stars", "yusokuryori-mankamero", "", "K|2"], [41, "Two Stars", "sanso-kyoyamato", "", "K|2"], [42, "Two Stars", "ogata", "", "K|2"], [43, "Two Stars", "kyokaiseki-kichisen", "", "K|2"], [44, "Two Stars", "gion-nishikawa", "", "K|2"], [45, "Two Stars", "otagi", "", "K|2"], [46, "Two Stars", "miyamaso", "", "K|2"], [47, "Two Stars", "sumibi-kappo-ifuki", "", "K|2"], [48, "Two Stars", "kenninji-gion-maruyama", "", "K|2"], [49, "Two Stars", "kodaiji-wakuden", "", "K|2"], [50, "Two Stars", "kikunoi-roan", "", "K|2"], [51, "Two Stars", "sojiki-nakahigashi", "", "K|2"], [52, "Two Stars", "kodaiji-jugyuan", "", "K|2"], [53, "Two Stars", "gion-matayoshi", "", "K|2"], [54, "Two Stars", "gion-maruyama", "", "K|2"], [55, "Two Stars", "ryo-sho", "", "K|2"], [76, "Green Star", "terada", "", "O|green"], [77, "Green Star", "kashiwaya-osaka-senriyama", "", "O|green"], [79, "Three Stars", "hajime", "", "O|3"], [80, "Three Stars", "taian", "", "O|3"], [81, "Three Stars", "kashiwaya-osaka-senriyama", "", "O|3"], [82, "Two Stars", "la-cime", "", "O|2"], [83, "Two Stars", "miyamoto", "", "O|2"], [84, "Two Stars", "fujiya-1935", "", "O|2"], [85, "Two Stars", "koryu", "", "O|2"], [86, "Two Stars", "yugen-1193266", "", "O|2"], [87, "Two Stars", "shunsaiten-tsuchiya", "", "O|2"], [88, "Two Stars", "sushi-harasho", "", "O|2"], [89, "Two Stars", "numata", "", "O|2"], [90, "Two Stars", "kahala", "", "O|2"], [91, "Two Stars", "oimatsu-hisano", "", "O|2"], [92, "Two Stars", "tenjimbashi-aoki", "", "O|2"], [113, "Green Star", "da-terra-1197086", "", "N|green"], [114, "Green Star", "sen-1218506", "", "N|green"], [119, "Green Star", "chugokusai-naramachi-kuko", "ve_c0eba7ae71", "N|green"]]';
  url_txt  text := '{"T|green": "https://web.archive.org/web/20250712063411id_/https://guide.michelin.com/jp/ja/tokyo-region/restaurants/sustainable_gastronomy", "T|3": "https://web.archive.org/web/20250122140437id_/https://guide.michelin.com/jp/ja/tokyo-region/restaurants/3-stars-michelin", "K|green": "https://web.archive.org/web/20250401023911id_/https://guide.michelin.com/jp/en/kyoto-region/restaurants/sustainable_gastronomy", "K|3": "https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/kyoto-region/restaurants/3-stars-michelin", "K|2": "https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/kyoto-region/restaurants/2-stars-michelin", "O|green": "https://web.archive.org/web/20250401023911id_/https://guide.michelin.com/jp/en/osaka-region/restaurants/sustainable_gastronomy", "O|3": "https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/osaka-region/restaurants/3-stars-michelin", "O|2": "https://web.archive.org/web/20250401023910id_/https://guide.michelin.com/jp/en/osaka-region/restaurants/2-stars-michelin", "N|green": "https://web.archive.org/web/20250714130145id_/https://guide.michelin.com/jp/en/nara-region/restaurants/sustainable_gastronomy"}';
  job_txt  text := 'backfill:michelin-2025-japan-archive | item 4 (Ben, Nov 1 21:50 ET "J1 & K1"): Michelin Guide Tokyo 2025 (Oct 17 2024), Kyoto Osaka 2025 (Mar 27 2025) and Nara 2025 (May 14 2025) from web.archive.org, complete page sets only | 1 existing 2025 row gets the source_url; 70 rows inserted (Green Star:24,Three Stars:20,Two Stars:27 in all 71) | source_url = the archive id_ URL of the region selection page that lists the line: T|green 20250712063411 jp/ja/tokyo-region/restaurants/sustainable_gastronomy (12); T|3 20250122140437 jp/ja/tokyo-region/restaurants/3-stars-michelin (12); K|green 20250401023911 jp/en/kyoto-region/restaurants/sustainable_gastronomy (10); K|3 20250401023910 jp/en/kyoto-region/restaurants/3-stars-michelin (5); K|2 20250401023910 jp/en/kyoto-region/restaurants/2-stars-michelin (16); O|green 20250401023911 jp/en/osaka-region/restaurants/sustainable_gastronomy (3); O|3 20250401023910 jp/en/osaka-region/restaurants/3-stars-michelin (3); O|2 20250401023910 jp/en/osaka-region/restaurants/2-stars-michelin (11); N|green 20250714130145 jp/en/nara-region/restaurants/sustainable_gastronomy (7) | relay docs/jp-2025-build/relay-jp-2025-archive-partial.txt sha256 ceab8dba...db99e1 | page totals = the 2025 jp/ja ceremony article totals | match: card link = Michelin card of an existing award row (69); V1 2025 row: 16 -> ve_05c8533123; K1 (own site kuko-nara.jp + both Michelin cards): 119 -> ve_c0eba7ae71 | Q1 skipped (no venue): Nœud. TOKYO; ristorante DONO; Vegan Ramen UZU; Unkaku; AWA Naramachiten; Sanjuhachi; Kuramoto Ryori Maruto Shoyu; Kiyosuminosato AWA | J1: not loaded (no full list found in the archive): Tokyo Two Stars and One Star, Nara Two Stars and One Star, Kyoto and Osaka One Star (page 1 of 4 only); 2025 Bibs no change | plan md5 136fb83c77f027186f2e3e107d6122f0';
  pj jsonb; rj jsonb; uj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;
  uj := url_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3) || '|' || (e->>4), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> '136fb83c77f027186f2e3e107d6122f0' OR cnt <> 71 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected 136fb83c77f027186f2e3e107d6122f0 / 71)', txt, cnt; END IF;
  SELECT md5(string_agg(skey || '|' || url, E'\n' ORDER BY skey)), count(*) INTO txt, cnt FROM (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u;
  IF txt <> '1a3b6ca0e06507fedaa5e182ee510e27' OR cnt <> 9 THEN RAISE EXCEPTION 'URL map md5 % / % (expected 1a3b6ca0e06507fedaa5e182ee510e27 / 9)', txt, cnt; END IF;

WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid, e->>4 skey FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/restaurante?/' AND c.country_iso = 'JP'),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat, p.skey,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how
        FROM p LEFT JOIN t1 USING (seq))
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how, skey) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> 'e9c2152fd28a3a28c9d04c184dcea0a6' THEN RAISE EXCEPTION 'seq:venue md5 % (expected e9c2152fd28a3a28c9d04c184dcea0a6)', txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso = 'JP';
  IF cnt <> 71 THEN RAISE EXCEPTION 'venues in JP % (expected 71)', cnt; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) d;
  IF cnt <> 71 THEN RAISE EXCEPTION 'distinct venue+category % (expected 71)', cnt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) d LEFT JOIN (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u USING (skey) WHERE u.url IS NULL;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no source URL: %', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> 1 OR txt <> '71f6278d140af599e06ad9bf1ba03cb0' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected 1 / 71f6278d140af599e06ad9bf1ba03cb0)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> 1 THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected 1)', cnt; END IF;
  SELECT count(*) INTO cnt FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
   WHERE r.cat <> 'Green Star' AND a.category IN ('Three Stars', 'Two Stars', 'One Star') AND a.category <> r.cat;
  IF cnt <> 0 THEN RAISE EXCEPTION 'venues with a different 2025 star row: %', cnt; END IF;
  SELECT md5(string_agg(id::text, ',' ORDER BY id)) INTO txt FROM awards WHERE id IN (1291);
  IF txt <> '71f6278d140af599e06ad9bf1ba03cb0' THEN RAISE EXCEPTION 'existing id list md5 % (expected 71f6278d140af599e06ad9bf1ba03cb0)', txt; END IF;

  -- 2. Counts before (read 2026-11-02 02:53:05 UTC)
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> 24643 OR num <> 31582 THEN RAISE EXCEPTION 'awards before % / max % (expected 24643 / 31582)', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 10939 THEN RAISE EXCEPTION 'Michelin awards before % (expected 10939)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 4563 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 4563)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3221 THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected 3221)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 31 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 31)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso = 'JP';
                                                IF cnt <> 11 THEN RAISE EXCEPTION 'JP Michelin 2025 before % (expected 11)', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 164 OR led_max <> 216 THEN RAISE EXCEPTION 'ledger before % / max % (expected 164 / 216)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 117583 OR aud_max <> 123095 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 117583 / 123095)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = u.url
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) r JOIN (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u USING (skey)
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'award rows updated % (expected 1)', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, u.url FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) r JOIN (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u USING (skey)
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 70 THEN RAISE EXCEPTION 'award rows inserted % (expected 70)', cnt; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 71, job_txt);
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', cnt; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO cnt FROM awards;         IF cnt <> 24713 THEN RAISE EXCEPTION 'awards after % (expected 24713)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> 11009 THEN RAISE EXCEPTION 'Michelin awards after % (expected 11009)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> 4633 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 4633)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> 3220 THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected 3220)', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> 55 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 55)', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a JOIN (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u ON u.url = a.source_url
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL
     GROUP BY a.category) g;
  IF cnt <> 71 OR txt <> 'Green Star:24,Three Stars:20,Two Stars:27'
    THEN RAISE EXCEPTION 'Japan Michelin 2025 with an archive URL % / % (expected 71 / Green Star:24,Three Stars:20,Two Stars:27)', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso = 'JP';
                                                IF cnt <> 81 THEN RAISE EXCEPTION 'JP Michelin 2025 after % (expected 81)', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM (SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e) r JOIN (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u USING (skey) JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
     AND a.category = r.cat AND a.source_url = u.url;
  IF txt <> 'e9c2152fd28a3a28c9d04c184dcea0a6' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected e9c2152fd28a3a28c9d04c184dcea0a6)', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> 11299 THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> 3260 THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> 165 THEN RAISE EXCEPTION 'ledger after % (expected 165)', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 71 AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> 71 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 71)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' IN (SELECT url FROM (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u);
  IF cnt <> 70 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 70)', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' IN (SELECT url FROM (SELECT key skey, value #>> '{}' url FROM jsonb_each(uj)) u)
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> 1 THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected 1)', cnt; END IF;
END
$do$;
COMMIT;
