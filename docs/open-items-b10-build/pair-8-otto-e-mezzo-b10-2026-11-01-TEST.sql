-- TEST COPY with live counts: send through the Read connector only. Not for a real run.
-- pair-8-otto-e-mezzo-b10-2026-11-01.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 10, file 1 of 2. INSERT/UPDATE only: Write connector.
-- Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5" + "Chrome ok". Open item 1: the 8 1/2 Otto e Mezzo Bombana pair (Hong Kong ve_e17d78f314, Macau ve_6f0b34cc23).
-- 1. Status: Hong Kong closed -> active (D1; card Three Stars 2026, no closure note). cities.venues_count hong-kong 261 -> 262.
-- 2. Rename batch rename-open-items-b10-2026-11-01 (D2; rules R2 + R3):
--    ve_e17d78f314 '8 1/2 Otto E Mezzo Bombana' -> '8 1/2 Otto e Mezzo Bombana'
--    ve_6f0b34cc23 '8½ Otto e Mezzo BOMBANA' -> '8 1/2 Otto e Mezzo Bombana'
-- 3. Slugs (D3): hong-kong/hong-kong-3bt2d8 and macau/macau-uc7ud0 -> non-canonical; insert hong-kong/8-1-2-otto-e-mezzo-bombana and macau/8-1-2-otto-e-mezzo-bombana.
-- 4. Awards (D4), 10 rows moved by publisher, each with the URL that proves the branch:
--    to Hong Kong: 15727 Best Chef 2025 2-Knife, 15728 OAD 2025 No. 91, 15729 Asia's 50 Best Bars 2021 No. 65,
--      15730-15734 Asia's 50 Best Restaurants 2019 No. 12 / 2021 No. 33 / 2022 No. 48 / 2023 No. 70 / 2025 No. 94, 15735 La Liste 2026 95/100;
--    to Macau: 20742 La Liste 2026 85.5/100.
-- Not in this file: 15736 (Michelin 2025 Three Stars on Macau, copy of 391) = file 2 (DELETE, SQL Editor). Forbes 6234-6237 and Michelin 6238 stay on Macau.
-- Relay docs/open-items-b10-build/relay-file1.txt sha256 d401d8265cf3b836d6ba5789deb2ee14e393e69095122af1c24df69985470940.
-- Expected: closed 366 -> 365 (active 10934 -> 10935), venues_count sum 10934 -> 10935, rename_batches 19 -> 20, rename_rows 1209 -> 1211,
--   slugs 12948 -> 12950 (non-canonical 1648 -> 1650), awards 23363 (no change), ledger last id 189 -> 195 (ids 190-195),
--   audit last id 120802 -> 120820 (+18: venues UPDATE 3, cities UPDATE 1, slugs UPDATE 2, slugs INSERT 2, awards UPDATE 10).
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel$ren|1|ve_e17d78f314|8 1/2 Otto E Mezzo Bombana|8 1/2 Otto e Mezzo Bombana|michelin|https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/8%C2%BD-otto-e-mezzo-bombana|hong-kong|hong-kong-3bt2d8|8-1-2-otto-e-mezzo-bombana|insert|card h1 "8 1/2 Otto e Mezzo - Bombana" (Three Stars 2026, Alexandra House); site ottoemezzobombana.com title "8 1/2 Otto E Mezzo Bombana", body "8½ Otto e Mezzo BOMBANA"; rule R2 (site title form the card also uses) + R3 (capitals: body writes "Otto e Mezzo"); same name as the Shanghai branch ve_524cd4f57d
ren|2|ve_6f0b34cc23|8½ Otto e Mezzo BOMBANA|8 1/2 Otto e Mezzo Bombana|michelin|https://guide.michelin.com/en/macau-region/macau/restaurant/8-1-2-otto-e-mezzo-bombana|macau|macau-uc7ud0|8-1-2-otto-e-mezzo-bombana|insert|card h1 "8 1/2 Otto e Mezzo - Bombana" (One Star 2026, Galaxy Cotai); same brand as Hong Kong; rule R2 + R3; one name for the 3 branches (Ben D2 = A)
status|ve_e17d78f314|8 1/2 Otto E Mezzo Bombana|ci_1b1537ad28|261|262|card https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/8%C2%BD-otto-e-mezzo-bombana Three Stars, 2026 MICHELIN Guide Hong Kong, Shop 202 2F Alexandra House 18 Chater Road, no closure note (read Nov 1); set closed by the Aug 14 sheet load with no closure evidence
mv|15727|ve_6f0b34cc23|ve_e17d78f314|best-chef-awards|2025||2-Knife|https://thebestchefawards.com/events-results/?id=2376|chef card Umberto Bombana: "8 1/2 Otto e Mezzo – Bombana", Hong Kong, China, two knives; held row from block 9
mv|15728|ve_6f0b34cc23|ve_e17d78f314|oad|2025|91|No. 91|https://www.oadguides.com/lists/asia/top-restaurants/2025|OAD Top Restaurants in Asia 2025 No. 91 "8 1/2 Otto E Mezzo Bombana", Hong Kong, Umberto Bombana (read in Chrome Nov 1)
mv|15729|ve_6f0b34cc23|ve_e17d78f314|asia-50-best-bars|2021|65|No. 65|https://www.theworlds50best.com/stories/News/asias-50-best-bars-2021-51-100-list-in-pictures.html|Asia's 50 Best Bars 2021 51-100: No. 65 "8 1/2 Otto e Mezzo Bombana", Hong Kong (the 50 Best lists the restaurant as a bar too)
mv|15730|ve_6f0b34cc23|ve_e17d78f314|asia-50-best-restaurants|2019|12|No. 12|https://www.the50.com/stories/News/asias-50-best-restaurants-2019-list-in-pictures.html|Asia's 50 Best Restaurants 2019 No. 12, Hong Kong, China (also Art of Hospitality Award 2019)
mv|15731|ve_6f0b34cc23|ve_e17d78f314|asia-50-best-restaurants|2021|33|No. 33|https://www.the50.com/stories/News/asias-50-best-restaurants-2021-the-list-in-pictures.html|Asia's 50 Best Restaurants 2021 No. 33, Hong Kong (also The 50 Discovery page, Hong Kong)
mv|15732|ve_6f0b34cc23|ve_e17d78f314|asia-50-best-restaurants|2022|48|No. 48|https://www.the50.com/stories/News/asias-50-best-restaurants-2022-list-in-pictures.html|Asia's 50 Best Restaurants 2022 No. 48, Hong Kong
mv|15733|ve_6f0b34cc23|ve_e17d78f314|asia-50-best-restaurants|2023|70|No. 70|https://www.theworlds50best.com/stories/News/asia-50-best-restaurants-2023-51-100-list.html|Asia's 50 Best Restaurants 2023 51-100: No. 70, Hong Kong
mv|15734|ve_6f0b34cc23|ve_e17d78f314|asia-50-best-restaurants|2025|94|No. 94|https://www.the50.com/stories/News/asias-50-best-restaurants-2025-the-51-100-list.html|Asia's 50 Best Restaurants 2025 51-100: No. 94 "8 1/2 Otto e Mezzo Bombana – RE-ENTRY", Hong Kong
mv|15735|ve_6f0b34cc23|ve_e17d78f314|la-liste|2026||95/100|https://www.laliste.com/places/8-12-otto-e-mezzo-bombana-hongkong-cn|La Liste Hong Kong place page: 95.0 Top 1000 Restaurants 2026, Shop 202, 18 Chater Rd (read in Chrome Nov 1)
mv|20742|ve_e17d78f314|ve_6f0b34cc23|la-liste|2026||85.5/100|https://www.laliste.com/places/8-otto-e-mezzo-bombana-macau-mo|La Liste Macau place page: 85.5 Top 1000 Restaurants 2026, 1/F 1031 Galaxy Resort Macau$rel$, E'\r', '');
  bid bigint; n int; x int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> 'd401d8265cf3b836d6ba5789deb2ee14e393e69095122af1c24df69985470940' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> 11300 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10934
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 366 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12948 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1648 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11300 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 19 OR (SELECT count(*) FROM rename_rows) <> 1209 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 141 OR (SELECT max(id) FROM source_capture_ledger) <> 189 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115490 OR (SELECT max(id) FROM audit_log) <> 120802 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'source_capture_ledger_id_seq') <> 189
     OR (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'audit_log_id_seq') <> 120802 THEN RAISE EXCEPTION 'id counters before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10934 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key = 'rename-open-items-b10-2026-11-01') THEN RAISE EXCEPTION 'batch key used'; END IF;

  -- pair gates (fresh read Nov 1 14:16 UTC)
  IF (SELECT md5(string_agg(id||'|'||name||'|'||status||'|'||city_id, E'\n' ORDER BY id)) FROM venues WHERE id IN ('ve_e17d78f314', 've_6f0b34cc23')) <> '20b7894ddb068a7ae020339c30db587f'
    THEN RAISE EXCEPTION 'pair venues differ from the Nov 1 read'; END IF;
  IF (SELECT md5(string_agg(id||'|'||venue_id||'|'||source_id||'|'||year||'|'||coalesce(rank::text, '')||'|'||category||'|'||coalesce(source_url, ''), E'\n' ORDER BY id))
        FROM awards WHERE venue_id IN ('ve_e17d78f314', 've_6f0b34cc23')) <> '93282d409b3ba11a5334dacec6fece65' THEN RAISE EXCEPTION 'pair awards differ from the Nov 1 read'; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||coalesce(a.rank::text, '')||'|'||a.category, E'\n' ORDER BY a.id))
        FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'mv' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3) AND a.source_id = split_part(l, '|', 5) AND a.year = split_part(l, '|', 6)::int
         AND coalesce(a.rank::text, '') = split_part(l, '|', 7) AND a.category = split_part(l, '|', 8) AND a.source_url IS NULL) <> '60ff178f989b67d1be720c6a94559188' THEN RAISE EXCEPTION 'move rows'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'mv' AND a.venue_id = split_part(l, '|', 4) AND a.source_id = split_part(l, '|', 5) AND a.year = split_part(l, '|', 6)::int
         AND a.rank IS NOT DISTINCT FROM nullif(split_part(l, '|', 7), '')::int AND a.category = split_part(l, '|', 8) AND a.distinction IS NULL) THEN RAISE EXCEPTION 'target already holds the row'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id IN ('ve_e17d78f314', 've_6f0b34cc23')) THEN RAISE EXCEPTION 'earlier rename_rows'; END IF;
  IF (SELECT count(*) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren'
        AND trim(both '-' from regexp_replace(lower(f_unaccent(split_part(l, '|', 5))), '[^a-z0-9]+', '-', 'g')) = split_part(l, '|', 10)) <> 2 THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND s.venue_id = split_part(l, '|', 3) AND s.property_id = 'eats'
        AND s.is_canonical AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 9)) <> 2 THEN RAISE EXCEPTION 'old canonical slugs'; END IF;
  IF EXISTS (SELECT 1 FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 10)) THEN RAISE EXCEPTION 'new slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM redirects d JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren'
        AND d.from_path IN ('/'||split_part(l, '|', 8)||'/'||split_part(l, '|', 10), '/venue/'||split_part(l, '|', 8)||'/'||split_part(l, '|', 10))) THEN RAISE EXCEPTION 'new path in redirects'; END IF;
  WITH batch AS (SELECT split_part(l, '|', 3) AS venue_id, split_part(l, '|', 5) AS new_name FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren'),
       scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
       fin   AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
                   FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id)
  SELECT count(*) INTO x FROM fin a JOIN batch ON batch.venue_id = a.id
    JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id AND norm_key(o.name) = norm_key(a.name);
  IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key collisions %', x; END IF;
  IF (SELECT count(*) FROM cities c JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'status' AND c.id = split_part(l, '|', 4) AND c.venues_count = split_part(l, '|', 5)::int) <> 1 THEN RAISE EXCEPTION 'city count before'; END IF;
  IF (SELECT count(*) FROM award_sources WHERE slug IN ('michelin', 'best-chef-awards', 'oad', 'asia-50-best-bars', 'asia-50-best-restaurants', 'la-liste')) <> 6 THEN RAISE EXCEPTION 'sources'; END IF;

  -- 1. status (status only; block 7 method, no ledger row)
  UPDATE venues v SET status = 'active' FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'status' AND v.id = split_part(l, '|', 2) AND v.name = split_part(l, '|', 3) AND v.status = 'closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status updated %', n; END IF;
  UPDATE cities c SET venues_count = split_part(l, '|', 6)::int FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'status' AND c.id = split_part(l, '|', 4) AND c.venues_count = split_part(l, '|', 5)::int;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count updated %', n; END IF;

  -- 2. rename batch
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-open-items-b10-2026-11-01', 'staged', 'Open items block 10 (Nov 1): the 8 1/2 Otto e Mezzo Bombana pair, Hong Kong and Macau get one name (rules R2 + R3). Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5". Gated SQL file, Write connector; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, split_part(l, '|', 2)::int, split_part(l, '|', 3), split_part(l, '|', 4), split_part(l, '|', 5), split_part(l, '|', 6), split_part(l, '|', 7), 'rename',
         jsonb_build_object('note', split_part(l, '|', 12) || ' | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', split_part(l, '|', 8), 'slug', split_part(l, '|', 9))
    FROM regexp_split_to_table(rel, E'\n') l JOIN venues v ON v.id = split_part(l, '|', 3) WHERE split_part(l, '|', 1) = 'ren';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = split_part(l, '|', 5) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren' AND v.id = split_part(l, '|', 3) AND v.name = split_part(l, '|', 4) AND v.status = 'active';
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 2 THEN RAISE EXCEPTION 'venues renamed %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 2, 'rename-apply:rename-open-items-b10-2026-11-01 | gated SQL file docs/pair-8-otto-e-mezzo-b10-2026-11-01.sql (Write connector) | Hong Kong ve_e17d78f314 "8 1/2 Otto E Mezzo Bombana" and Macau ve_6f0b34cc23 "8½ Otto e Mezzo BOMBANA" -> "8 1/2 Otto e Mezzo Bombana": Michelin 2026 cards (h1 "8 1/2 Otto e Mezzo - Bombana") and ottoemezzobombana.com title, rules R2 + R3; Hong Kong also set active (card Three Stars 2026, no closure note) | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 190 THEN RAISE EXCEPTION 'ledger id michelin name %', v_lid; END IF;
  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status'; END IF;

  -- 3. slugs
  UPDATE slugs s SET is_canonical = false FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'ren' AND s.property_id = 'eats' AND s.venue_id = split_part(l, '|', 3) AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 9) AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'old canonical updated %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', split_part(l, '|', 8), split_part(l, '|', 10), split_part(l, '|', 3), true FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren' AND split_part(l, '|', 11) = 'insert';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'new slugs %', n; END IF;

  -- 4. award moves with URL
  UPDATE awards a SET venue_id = split_part(l, '|', 4), source_url = split_part(l, '|', 9) FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'mv' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3) AND a.source_id = split_part(l, '|', 5) AND a.source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 10 THEN RAISE EXCEPTION 'awards moved %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('asia-50-best-restaurants', 'award', 5, 'pair-fix:pair-8-otto-e-mezzo-b10-2026-11-01 | 8 1/2 Otto e Mezzo Bombana pair split by publisher (open item 1): 15730 2019 No. 12 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (Asia''s 50 Best Restaurants 2019 No. 12, Hong Kong, China (also Art of Hospitality Award 2019)) url https://www.the50.com/stories/News/asias-50-best-restaurants-2019-list-in-pictures.html; 15731 2021 No. 33 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (Asia''s 50 Best Restaurants 2021 No. 33, Hong Kong (also The 50 Discovery page, Hong Kong)) url https://www.the50.com/stories/News/asias-50-best-restaurants-2021-the-list-in-pictures.html; 15732 2022 No. 48 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (Asia''s 50 Best Restaurants 2022 No. 48, Hong Kong) url https://www.the50.com/stories/News/asias-50-best-restaurants-2022-list-in-pictures.html; 15733 2023 No. 70 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (Asia''s 50 Best Restaurants 2023 51-100: No. 70, Hong Kong) url https://www.theworlds50best.com/stories/News/asia-50-best-restaurants-2023-51-100-list.html; 15734 2025 No. 94 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (Asia''s 50 Best Restaurants 2025 51-100: No. 94 "8 1/2 Otto e Mezzo Bombana – RE-ENTRY", Hong Kong) url https://www.the50.com/stories/News/asias-50-best-restaurants-2025-the-51-100-list.html | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 191 THEN RAISE EXCEPTION 'ledger id asia-50-best-restaurants award %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('asia-50-best-bars', 'award', 1, 'pair-fix:pair-8-otto-e-mezzo-b10-2026-11-01 | 8 1/2 Otto e Mezzo Bombana pair split by publisher (open item 1): 15729 2021 No. 65 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (Asia''s 50 Best Bars 2021 51-100: No. 65 "8 1/2 Otto e Mezzo Bombana", Hong Kong (the 50 Best lists the restaurant as a bar too)) url https://www.theworlds50best.com/stories/News/asias-50-best-bars-2021-51-100-list-in-pictures.html | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 192 THEN RAISE EXCEPTION 'ledger id asia-50-best-bars award %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 1, 'pair-fix:pair-8-otto-e-mezzo-b10-2026-11-01 | 8 1/2 Otto e Mezzo Bombana pair split by publisher (open item 1): 15727 2025 2-Knife Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (chef card Umberto Bombana: "8 1/2 Otto e Mezzo – Bombana", Hong Kong, China, two knives; held row from block 9) url https://thebestchefawards.com/events-results/?id=2376 | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 193 THEN RAISE EXCEPTION 'ledger id best-chef-awards award %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('oad', 'award', 1, 'pair-fix:pair-8-otto-e-mezzo-b10-2026-11-01 | 8 1/2 Otto e Mezzo Bombana pair split by publisher (open item 1): 15728 2025 No. 91 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (OAD Top Restaurants in Asia 2025 No. 91 "8 1/2 Otto E Mezzo Bombana", Hong Kong, Umberto Bombana (read in Chrome Nov 1)) url https://www.oadguides.com/lists/asia/top-restaurants/2025 | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 194 THEN RAISE EXCEPTION 'ledger id oad award %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('la-liste', 'award', 2, 'pair-fix:pair-8-otto-e-mezzo-b10-2026-11-01 | 8 1/2 Otto e Mezzo Bombana pair split by publisher (open item 1): 15735 2026 95/100 Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314 (La Liste Hong Kong place page: 95.0 Top 1000 Restaurants 2026, Shop 202, 18 Chater Rd (read in Chrome Nov 1)) url https://www.laliste.com/places/8-12-otto-e-mezzo-bombana-hongkong-cn; 20742 2026 85.5/100 Hong Kong ve_e17d78f314 -> Macau ve_6f0b34cc23 (La Liste Macau place page: 85.5 Top 1000 Restaurants 2026, 1/F 1031 Galaxy Resort Macau) url https://www.laliste.com/places/8-otto-e-mezzo-bombana-macau-mo | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 195 THEN RAISE EXCEPTION 'ledger id la-liste award %', v_lid; END IF;

  -- post-checks
  IF (SELECT count(*) FROM venues) <> 11300 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10935
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 365 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 OR (SELECT count(*) FROM listings) <> 11300 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'awards/listings/blurbs after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12950 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1650
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11300 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1)
    THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND s.venue_id = split_part(l, '|', 3) AND s.is_canonical AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 10)) <> 2
    THEN RAISE EXCEPTION 'new canonical slugs after'; END IF;
  IF (SELECT md5(string_agg(id||'|'||name, E'\n' ORDER BY id)) FROM venues WHERE id IN ('ve_e17d78f314', 've_6f0b34cc23') AND status = 'active') <> '8e7d27a76c735a476c204254b407c8e4'
    THEN RAISE EXCEPTION 'names after'; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_url, E'\n' ORDER BY a.id)) FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'mv' AND a.id = split_part(l, '|', 2)::bigint) <> '9fbe7473d95849112e0d59c2affb6b4b'
    THEN RAISE EXCEPTION 'moved rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_e17d78f314') <> 11 OR (SELECT count(*) FROM awards WHERE venue_id = 've_6f0b34cc23') <> 7 THEN RAISE EXCEPTION 'awards per venue after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 20 OR (SELECT count(*) FROM rename_rows) <> 1211 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 147 OR (SELECT max(id) FROM source_capture_ledger) <> 195 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10935 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115508 OR (SELECT count(*) FROM audit_log WHERE id > 120802) <> 18 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120802 AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = 've_e17d78f314'
         AND (old_row - 'status') = (new_row - 'status') AND old_row->>'status' = 'closed' AND new_row->>'status' = 'active') <> 1
    THEN RAISE EXCEPTION 'audit venues (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND a.row_pk = split_part(l, '|', 3)
       WHERE a.id > 120802 AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.old_row->>'name' = split_part(l, '|', 4) AND a.new_row->>'name' = split_part(l, '|', 5)
         AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key')) <> 2 THEN RAISE EXCEPTION 'audit venues (name, norm_key only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120802 AND table_name = 'cities' AND action = 'UPDATE'
         AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 1 THEN RAISE EXCEPTION 'audit cities (venues_count only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120802 AND table_name = 'slugs' AND action = 'UPDATE') <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > 120802 AND table_name = 'slugs' AND action = 'INSERT') <> 2 THEN RAISE EXCEPTION 'audit slugs'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'mv' AND a.row_pk = split_part(l, '|', 2)
       WHERE a.id > 120802 AND a.table_name = 'awards' AND a.action = 'UPDATE'
         AND (a.old_row - 'venue_id' - 'source_url') = (a.new_row - 'venue_id' - 'source_url') AND a.new_row->>'venue_id' = split_part(l, '|', 4)) <> 10
    THEN RAISE EXCEPTION 'audit award moves'; END IF;
END
$do$;
COMMIT;
