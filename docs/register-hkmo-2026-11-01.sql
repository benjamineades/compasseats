-- register-hkmo-2026-11-01.sql
-- CompassEats, Nov 1 2026 (Atlanta). HK/MO open item 1 (register items). Built by
--   docs/hkmo-2026-build/build_register_hkmo_2026_11_01.py (special-award rows from the log, card URLs from the ingest CSV).
-- Ben, Nov 1 12:59 ET: "For all choices go with your recommendation" = 1a A, 1b A, 1c A, 1d A, 1e A (E1).
--   1c Chiu Chow Delicacies (North Point) and 1d Hong Kong Zuicho: no write (status stays; recheck at the 2027 guide / D8).
-- Reads (Nov 1):
--   1a OAD Top Restaurants in Asia 2025 https://www.oadguides.com/lists/asia/top-restaurants/2025 (built-in browser): No. 14 "Xin Rong Ji Restaurant HK", Hong Kong;
--      OAD page /restaurant/xin-rong-ji-restaurant-hk: "China Overseas Building, No.138 Lockhart Road". Michelin card
--      /hong-kong-region/hong-kong/restaurant/xin-rong-ji: "GF & 1F, China Overseas Building, 139 Lockhart Road, Wan Chai".
--      Also on the list: No. 261 "Zuicho", Hong Kong (item 1d, row 18155 stays on the closed Hong Kong record).
--   1b Hotel page https://www.grandlisboapalace.com/en/restaurants-n-bars/mesa: "About Mesa Bar", "The Mesa Bar Menu", body "Mesa Bar". The 50 directory: "Mesa Bar",
--      Grand Lisboa Palace, Level 3. Asia's 50 Best Bars 2022 51-100: No. 82 "Mesa", Macau.
--   1e Ceremony article https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026 (log part 13).
-- Writes (one transaction; all guards run before the first write, so the dry run checks every guard):
--   A. Merge ve_4dc9197f86 "Xin Rong Ji Restaurant" into ve_f966b7e0a1 "Xin Rong Ji" (Oct 31 La Table method):
--      award 18019 (OAD 2025 No. 14) venue + source_url; slug hong-kong/xin-rong-ji-restaurant -> survivor, non-canonical
--      (old URL keeps working); city labels 17265, 17266 (oad) -> survivor with hand audit rows; listing and venue DELETE;
--      cities Hong Kong venues_count 262 -> 261. Ledger: oad, award, 1.
--   B. Rename batch rename-hkmo-register-mesa-bar-2026-11-01: ve_6f0bd256a0 "Mesa by José Avillez" -> "Mesa Bar" (source venue,
--      no ledger row); slug macau/mesa-by-jose-avillez-bar -> non-canonical, macau/mesa-bar INSERT canonical.
--   C. 3 awards INSERT (Michelin 2026 special awards, distinction = person, source_url = ceremony article). Ledger: michelin, award, 3.
--      Skipped (Q3 A): Young Chef Award | Kim GwanJu | Sol (Hong Kong) | no star/Bib card in the 2026 capture (Selected only) | Q3 A: skipped
-- Expected after: venues 11,300 -> 11,299 (active 10,934, closed 365); awards 23,368 -> 23,371 (Michelin 9,664 -> 9,667);
--   slugs 13,001 -> 13,002 (canonical 11,299, non-canonical 1,703); listings 11,299; price 7,733; city labels 23,999;
--   cities.venues_count sum 10,934 (0 cities differ from the view); rename_batches 22, rename_rows 1,278;
--   ledger 157 -> 159 rows (last id 207 -> 209); audit_log +13: awards INSERT 3 + UPDATE 1, cities UPDATE 1,
--   city_label_source UPDATE 2 (hand), listings DELETE 1, slugs INSERT 1 + UPDATE 2, venues DELETE 1 + UPDATE 1.
-- Guards: plan md5 5045c979c1077c563e5e6a5af1648d1e (line|category|person|venue|card URL|card category); line:venue md5 5f2399e3bbcafb21905f182986c06dc9;
--   venues af31f5492e60e0ea5789c06e9582bd16; awards b0877845ea0c949cd022bcf80d45bde0; city labels 56679a2b96554263092be26d8aef2a21; slugs 4b8c73a772ce558539b4aac0b7e73078.
-- Dry run: send the file through the Read connector. It stops at the first UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '[[1, "Service Award", "Jenny Ye", "The Huaiyang Garden", "https://guide.michelin.com/us/en/macau-region/macau/restaurant/the-huaiyang-garden", "Two Stars"], [2, "Sommelier Award", "Floriane Hureau", "Caprice", "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/caprice", "Three Stars"], [3, "Mentor Chef Award", "Lau Ping Lui, Paul", "Tin Lung Heen", "https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/tin-lung-heen", "Two Stars"]]';
  job_oad  text := 'merge:register-hkmo-2026-11-01 | item 1a (Ben, Nov 1 12:59 ET "go with your recommendation"): ve_4dc9197f86 "Xin Rong Ji Restaurant" = ve_f966b7e0a1 "Xin Rong Ji" (Hong Kong; OAD page /restaurant/xin-rong-ji-restaurant-hk address China Overseas Building, No.138 Lockhart Road = Michelin card address China Overseas Building, Lockhart Road, Wan Chai; one Xin Rong Ji in Hong Kong) | award 18019 OAD Top Restaurants in Asia 2025 No. 14 "Xin Rong Ji Restaurant HK" -> ve_f966b7e0a1, source_url https://www.oadguides.com/lists/asia/top-restaurants/2025 (read Nov 1, built-in browser) | old slug hong-kong/xin-rong-ji-restaurant non-canonical; 2 oad city labels moved; listing and venue deleted; Hong Kong venues_count 262 -> 261';
  job_mic  text := 'special-awards:register-hkmo-2026-11-01 | item 1e (Ben, Nov 1 12:59 ET "go with your recommendation", E1 = names as printed): 3 Michelin 2026 special awards, distinction = person, source_url = ceremony article https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026 | Service Award Jenny Ye -> The Huaiyang Garden ve_f7fd2a6231; Sommelier Award Floriane Hureau -> Caprice ve_c3b5b8becf; Mentor Chef Award Lau Ping Lui, Paul -> Tin Lung Heen ve_7db92e090b | skipped (Q3 A, Oct 29): Young Chef Award Kim GwanJu, Sol (Hong Kong), Selected only, no venue | log part 13 sha256 8ddf6780...39df';
  note_ren text := 'HK/MO register item 1b (Ben, Nov 1 12:59 ET "go with your recommendation"): bar record of Mesa by Jose Avillez, Macau, renamed to the bar name. Hotel page https://www.grandlisboapalace.com/en/restaurants-n-bars/mesa (read Nov 1, built-in browser): heading "About Mesa Bar", body "Mesa Bar sets the stage..."; The 50 directory names it "Mesa Bar", Grand Lisboa Palace, Level 3. Asia''s 50 Best Bars 2022 No. 82 "Mesa", Macau. Restaurant record ve_a2a7ed787d keeps its name (Caprice / Caprice Bar pattern). Source venue: no ledger row.';
  pj jsonb; n int; x int; s text; bid bigint; l1 bigint; l2 bigint;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  ---------------------------------------------------------------- 0. Counts before (read Nov 1 17:52 UTC)
  IF (SELECT count(*) FROM venues) <> 11300 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10935
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 365 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23368 OR (SELECT count(*) FROM awards WHERE source_id = 'michelin') <> 9664 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13001 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1701 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11300 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7733 THEN RAISE EXCEPTION 'price before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23999 THEN RAISE EXCEPTION 'city labels before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3260 OR (SELECT sum(venues_count) FROM cities) <> 10935 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 21 OR (SELECT count(*) FROM rename_rows) <> 1277 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 157 OR led_max <> 207 THEN RAISE EXCEPTION 'ledger before % / %', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 116236 OR aud_max <> 121574 THEN RAISE EXCEPTION 'audit_log before % / %', aud_n, aud_max; END IF;

  ---------------------------------------------------------------- 1. Row fingerprints
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.category, E'\n' ORDER BY v.id)) INTO s
    FROM venues v WHERE v.id IN ('ve_4dc9197f86','ve_f966b7e0a1','ve_6f0bd256a0','ve_a2a7ed787d');
  IF s IS DISTINCT FROM 'af31f5492e60e0ea5789c06e9582bd16' THEN RAISE EXCEPTION 'venue rows %', s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||coalesce(a.rank::text,'')||'|'||a.category||'|'||coalesce(a.distinction,'')||'|'||coalesce(a.source_url,''), E'\n' ORDER BY a.id)) INTO s
    FROM awards a WHERE a.venue_id IN ('ve_4dc9197f86','ve_f966b7e0a1','ve_6f0bd256a0');
  IF s IS DISTINCT FROM 'b0877845ea0c949cd022bcf80d45bde0' THEN RAISE EXCEPTION 'award rows %', s; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||coalesce(l.publisher,''), E'\n' ORDER BY l.id)) INTO s
    FROM city_label_source l WHERE l.venue_id IN ('ve_4dc9197f86','ve_f966b7e0a1','ve_6f0bd256a0');
  IF s IS DISTINCT FROM '56679a2b96554263092be26d8aef2a21' THEN RAISE EXCEPTION 'city label rows %', s; END IF;
  SELECT md5(string_agg(sl.venue_id||'|'||sl.property_id||'|'||sl.city_slug||'|'||sl.slug||'|'||sl.is_canonical, E'\n' ORDER BY sl.venue_id, sl.slug)) INTO s
    FROM slugs sl WHERE sl.venue_id IN ('ve_4dc9197f86','ve_f966b7e0a1','ve_6f0bd256a0');
  IF s IS DISTINCT FROM '4b8c73a772ce558539b4aac0b7e73078' THEN RAISE EXCEPTION 'slug rows %', s; END IF;

  ---------------------------------------------------------------- 2. Guards A (merge)
  IF (SELECT count(*) FROM listings WHERE venue_id = 've_4dc9197f86') <> 1 THEN RAISE EXCEPTION 'merged listing'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id = 've_4dc9197f86') + (SELECT count(*) FROM blurbs WHERE venue_id = 've_4dc9197f86')
     + (SELECT count(*) FROM geo WHERE venue_id = 've_4dc9197f86') + (SELECT count(*) FROM addresses WHERE venue_id = 've_4dc9197f86')
     + (SELECT count(*) FROM hours WHERE venue_id = 've_4dc9197f86') + (SELECT count(*) FROM photo_refs WHERE venue_id = 've_4dc9197f86')
     + (SELECT count(*) FROM rename_rows WHERE venue_id = 've_4dc9197f86') <> 0 THEN RAISE EXCEPTION 'merged venue has other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path LIKE '%xin-rong-ji-restaurant%' OR to_path LIKE '%xin-rong-ji-restaurant%') THEN RAISE EXCEPTION 'redirect on the old path'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_f966b7e0a1' AND source_id = 'oad') THEN RAISE EXCEPTION 'survivor already has an OAD row'; END IF;
  IF (SELECT venues_count FROM cities WHERE id = 'ci_1b1537ad28') <> 262 THEN RAISE EXCEPTION 'Hong Kong count before'; END IF;

  ---------------------------------------------------------------- 3. Guards B (Mesa Bar)
  IF (SELECT trim(both '-' from regexp_replace(lower(f_unaccent('Mesa Bar')), '[^a-z0-9]+', '-', 'g'))) <> 'mesa-bar' THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE property_id = 'eats' AND city_slug = 'macau' AND slug = 'mesa-bar') THEN RAISE EXCEPTION 'macau/mesa-bar in use'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path IN ('/macau/mesa-bar', '/venue/macau/mesa-bar')) THEN RAISE EXCEPTION 'macau/mesa-bar in redirects'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE city_id = 'ci_9690a92f29' AND id <> 've_6f0bd256a0' AND norm_key = norm_key('Mesa Bar')) THEN RAISE EXCEPTION 'norm_key collision'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key = 'rename-hkmo-register-mesa-bar-2026-11-01') THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = 've_6f0bd256a0') OR EXISTS (SELECT 1 FROM blurbs WHERE venue_id = 've_6f0bd256a0')
    THEN RAISE EXCEPTION 'earlier rename row or blurb on the bar record'; END IF;
  IF EXISTS (SELECT 1 FROM award_sources WHERE slug = 'venue') THEN RAISE EXCEPTION 'venue is a registered source (ledger rule changes)'; END IF;

  ---------------------------------------------------------------- 4. Guards C (special awards)
  SELECT md5(string_agg((e->>0)||'|'||(e->>1)||'|'||(e->>2)||'|'||(e->>3)||'|'||(e->>4)||'|'||(e->>5), E'\n' ORDER BY (e->>0)::int)), count(*)
    INTO s, n FROM jsonb_array_elements(pj) e;
  IF s <> '5045c979c1077c563e5e6a5af1648d1e' OR n <> 3 THEN RAISE EXCEPTION 'plan md5 % / rows %', s, n; END IF;
  WITH p AS (SELECT (e->>0)::int l, e->>4 u, e->>5 c FROM jsonb_array_elements(pj) e),
  r AS (SELECT p.l,
      (SELECT min(a.venue_id) FROM awards a JOIN venues v ON v.id = a.venue_id
        WHERE a.source_id = 'michelin' AND a.year = 2026 AND a.category = p.c AND a.source_url = p.u AND v.status = 'active') vid,
      (SELECT count(*) FROM awards a WHERE a.source_id = 'michelin' AND a.source_url = p.u) nu FROM p)
  SELECT count(*) FILTER (WHERE vid IS NOT NULL AND nu = 1), count(DISTINCT vid), md5(string_agg(l||':'||coalesce(vid,'-'), E'\n' ORDER BY l))
    INTO n, x, s FROM r;
  IF n <> 3 OR x <> 3 OR s <> '5f2399e3bbcafb21905f182986c06dc9' THEN RAISE EXCEPTION 'card match % / % / %', n, x, s; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id = 'michelin' AND category IN (SELECT e->>1 FROM jsonb_array_elements(pj) e)) <> 3
    THEN RAISE EXCEPTION 'categories missing'; END IF;
  WITH p AS (SELECT e->>1 c, e->>4 u FROM jsonb_array_elements(pj) e)
  SELECT count(*) INTO x FROM p JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = p.u
    JOIN awards g ON g.venue_id = a.venue_id AND g.source_id = 'michelin' AND g.year = 2026 AND g.category = p.c;
  IF x <> 0 THEN RAISE EXCEPTION 'special award already on a venue: %', x; END IF;

  ---------------------------------------------------------------- 5. Writes A (merge)
  UPDATE awards SET venue_id = 've_f966b7e0a1', source_url = 'https://www.oadguides.com/lists/asia/top-restaurants/2025'
   WHERE id = 18019 AND venue_id = 've_4dc9197f86' AND source_id = 'oad' AND year = 2025 AND rank = 14 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 18019 %', n; END IF;
  UPDATE slugs SET venue_id = 've_f966b7e0a1', is_canonical = false
   WHERE property_id = 'eats' AND venue_id = 've_4dc9197f86' AND city_slug = 'hong-kong' AND slug = 'xin-rong-ji-restaurant' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug moved %', n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'UPDATE', to_jsonb(l), to_jsonb(l) || jsonb_build_object('venue_id', 've_f966b7e0a1')
    FROM city_label_source l WHERE l.venue_id = 've_4dc9197f86' ORDER BY l.id;
  UPDATE city_label_source SET venue_id = 've_f966b7e0a1' WHERE venue_id = 've_4dc9197f86' AND id IN (17265, 17266);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'city labels moved %', n; END IF;
  DELETE FROM listings WHERE venue_id = 've_4dc9197f86';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings deleted %', n; END IF;
  DELETE FROM venues WHERE id = 've_4dc9197f86';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues deleted %', n; END IF;
  UPDATE cities SET venues_count = 261 WHERE id = 'ci_1b1537ad28' AND venues_count = 262;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Hong Kong count %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('oad', 'award', 1, job_oad) RETURNING id INTO l1;

  ---------------------------------------------------------------- 6. Writes B (Mesa Bar)
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('rename-hkmo-register-mesa-bar-2026-11-01', 'staged', note_ren) RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, 1, v.id, v.name, 'Mesa Bar', 'venue', 'https://www.grandlisboapalace.com/en/restaurants-n-bars/mesa', 'rename',
         jsonb_build_object('note', note_ren, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', sl.city_slug, 'slug', sl.slug)
    FROM venues v JOIN slugs sl ON sl.venue_id = v.id AND sl.property_id = 'eats' AND sl.is_canonical
   WHERE v.id = 've_6f0bd256a0' AND v.name = 'Mesa by José Avillez';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename_rows inserted %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name = 'Mesa Bar' WHERE id = 've_6f0bd256a0' AND name = 'Mesa by José Avillez';
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 1 THEN RAISE EXCEPTION 'venue renamed %', n; END IF;
  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;
  UPDATE slugs SET is_canonical = false
   WHERE property_id = 'eats' AND venue_id = 've_6f0bd256a0' AND city_slug = 'macau' AND slug = 'mesa-by-jose-avillez-bar' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old Mesa slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'macau', 'mesa-bar', 've_6f0bd256a0', true);

  ---------------------------------------------------------------- 7. Writes C (special awards)
  WITH p AS (SELECT (e->>0)::int l, e->>1 cat, e->>2 person, e->>4 u, e->>5 c FROM jsonb_array_elements(pj) e),
  r AS (SELECT p.*, (SELECT min(a.venue_id) FROM awards a WHERE a.source_id = 'michelin' AND a.year = 2026 AND a.category = p.c AND a.source_url = p.u) vid FROM p)
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT vid, 'michelin', 2026, NULL, cat, person, 'https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026' FROM r ORDER BY l;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'special awards inserted %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 3, job_mic) RETURNING id INTO l2;

  ---------------------------------------------------------------- 8. Post-checks
  IF l1 <> led_max + 1 OR l2 <> l1 + 1 THEN RAISE EXCEPTION 'ledger ids % %', l1, l2; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 159 THEN RAISE EXCEPTION 'ledger rows after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11299 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10934
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 365 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23371 OR (SELECT count(*) FROM awards WHERE source_id = 'michelin') <> 9667 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13002 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1703
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11299 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11299 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'listings/blurbs after'; END IF;
  IF (SELECT count(*) FROM price) <> 7733 THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23999 THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10934 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs sl ON sl.venue_id = v.id AND sl.is_canonical AND sl.property_id = 'eats'
              GROUP BY v.id HAVING count(sl.slug) <> 1) THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 22 OR (SELECT count(*) FROM rename_rows) <> 1278 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  -- A
  SELECT string_agg(id||' '||source_id||' '||year||' '||category, ', ' ORDER BY id) INTO s FROM awards WHERE venue_id = 've_f966b7e0a1';
  IF s IS DISTINCT FROM '5573 michelin 2026 One Star, 5574 asia-50-best-restaurants 2023 No. 99, 5575 asia-50-best-restaurants 2024 No. 52, 5576 asia-50-best-restaurants 2025 No. 56, 18019 oad 2025 No. 14'
    THEN RAISE EXCEPTION 'Xin Rong Ji awards after: %', s; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_4dc9197f86') + (SELECT count(*) FROM slugs WHERE venue_id = 've_4dc9197f86')
     + (SELECT count(*) FROM city_label_source WHERE venue_id = 've_4dc9197f86') + (SELECT count(*) FROM listings WHERE venue_id = 've_4dc9197f86')
     + (SELECT count(*) FROM venues WHERE id = 've_4dc9197f86') <> 0 THEN RAISE EXCEPTION 'rows left on the merged venue id'; END IF;
  -- B
  SELECT string_agg(v.name||' '||sl.city_slug||'/'||sl.slug||' '||sl.is_canonical, ', ' ORDER BY sl.slug) INTO s
    FROM venues v JOIN slugs sl ON sl.venue_id = v.id WHERE v.id = 've_6f0bd256a0';
  IF s IS DISTINCT FROM 'Mesa Bar macau/mesa-bar true, Mesa Bar macau/mesa-by-jose-avillez-bar false' THEN RAISE EXCEPTION 'Mesa Bar after: %', s; END IF;
  IF (SELECT name FROM venues WHERE id = 've_a2a7ed787d') <> 'Mesa by José Avillez' THEN RAISE EXCEPTION 'Mesa restaurant name changed'; END IF;
  -- C
  SELECT string_agg(a.venue_id||'|'||a.category||'|'||a.distinction, E'\n' ORDER BY a.venue_id) INTO s FROM awards a
   WHERE a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026' AND a.rank IS NULL;
  IF s IS DISTINCT FROM E've_7db92e090b|Mentor Chef Award|Lau Ping Lui, Paul\nve_c3b5b8becf|Sommelier Award|Floriane Hureau\nve_f7fd2a6231|Service Award|Jenny Ye' THEN RAISE EXCEPTION 'special award rows after: %', s; END IF;
  -- audit
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max) <> 13 THEN RAISE EXCEPTION 'audit rows after %', (SELECT count(*) FROM audit_log WHERE id > aud_max); END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name, action) INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1, 2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=3,awards:UPDATE=1,cities:UPDATE=1,city_label_source:UPDATE=2,listings:DELETE=1,slugs:INSERT=1,slugs:UPDATE=2,venues:DELETE=1,venues:UPDATE=1'
    THEN RAISE EXCEPTION 'audit rows by table and action: %', s; END IF;
  IF NOT EXISTS (SELECT 1 FROM audit_log WHERE id > aud_max AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = 've_6f0bd256a0'
                  AND old_row->>'name' = 'Mesa by José Avillez' AND new_row->>'name' = 'Mesa Bar'
                  AND (old_row - 'name' - 'norm_key') = (new_row - 'name' - 'norm_key')) THEN RAISE EXCEPTION 'Mesa rename audit row'; END IF;
END
$do$;
COMMIT;
