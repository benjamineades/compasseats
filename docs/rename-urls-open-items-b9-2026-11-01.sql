-- rename-urls-open-items-b9-2026-11-01.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 9, file 1 of 2. INSERT/UPDATE only: Write connector.
-- Ben: Nov 1 08:17 ET "1 & 2"; 08:28 ET "All recommendations" (held rows A, 8 names A, Hibana A, Guy Savoy A).
-- 1. Rename batch rename-open-items-b9-2026-11-01 (8 venues; rules R1-R5; same writes as scripts/rename/apply.ts):
--    ve_1727fb4901 'Le Calandrе' -> 'Le Calandre' (michelin)
--    ve_98b2c2d46b 'Bed & Breakfast - Les Belles Perdrix' -> 'Les Belles Perdrix de Troplong Mondot' (michelin)
--    ve_b60189d14c 'Home Aribert - Restaurant Gastronomique 2 Étoiles Michelin' -> 'Maison Aribert' (michelin)
--    ve_4e2b60de79 'KOKI - The House of Senses' -> 'Hibana by Koki' (michelin)
--    ve_53b3c4e143 'EDGE for Men - V & A Waterfront' -> 'EDGE' (best-chef-awards)
--    ve_ab0ec4c74c 'Xiamen' -> 'XIA' (best-chef-awards)
--    ve_2922f8b9e6 'The Palash Vann Resort' -> 'Palaash' (best-chef-awards)
--    ve_83aca60857 'Hotel Cañitas Classic' -> 'Cañitas Maite' (best-chef-awards)
-- 2. Slugs: old canonical -> non-canonical (8); reuse an old slug as canonical (3: padua/le-calandre, saint-emilion/les-belles-perdrix-de-troplong-mondot, uriage-les-bains/maison-aribert);
--    insert a new canonical slug (5: hanoi/hibana-by-koki, cape-town/edge, xiamen/xia, maharashtra/palaash, casas-ibanez/canitas-maite).
-- 3. Best Chef row fixes: 3453 Flores Raras gets the 2025 URL; 15690 moves Ensue -> Fumée (ve_38916224da) with the 2025 URL.
-- 4. Best Chef rows added: Guy Savoy (Paris) 2024 2-Knife and 2025 2-Knife, URL = the results page of each edition.
-- Not in this file: row 15727 (8½ Macau) held for the Hong Kong/Macau block; The Fellas and Fo'ao Vaperse Hotel = file 2.
-- Relay docs/open-items-b9-build/relay-file1.txt sha256 b73aa3c9caaed36d49f3eb654ae94987550da1c1bf7f7d64feec09ea9067b656.
-- Expected: rename_batches 18 -> 19, rename_rows 1201 -> 1209, slugs 12945 -> 12950 (non-canonical 1643 -> 1651),
--   awards 23363 -> 23365, ledger 180 -> 184 (michelin name 4, best-chef-awards name 4, best-chef-awards award 2 + 2),
--   audit 120732 -> 120760 (+28: venues UPDATE 8, slugs UPDATE 11, slugs INSERT 5, awards UPDATE 2, awards INSERT 2).
-- Dry run: send through the Read connector. It stops at the first INSERT with "read-only transaction".
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel$ren|1|ve_1727fb4901|Le Calandrе|Le Calandre|michelin|https://guide.michelin.com/us/en/veneto/rubano/restaurant/le-calandre|padua|le-calandr|le-calandre|reuse|live name ends in Cyrillic U+0435; card h1 "Le Calandre"; site alajmo.it "Le Calandre" (menu, slide, body); Best Chef "Le Calandre"; rule R1
ren|2|ve_98b2c2d46b|Bed & Breakfast - Les Belles Perdrix|Les Belles Perdrix de Troplong Mondot|michelin|https://guide.michelin.com/us/en/nouvelle-aquitaine/saint-milion/restaurant/les-belles-perdrix-de-troplong-mondot|saint-emilion|bed-breakfast-les-belles-perdrix|les-belles-perdrix-de-troplong-mondot|reuse|card h1 "Les Belles Perdrix de Troplong Mondot"; site troplong-mondot.com/restaurant: "Les Belles Perdrix" (title, H1), "Les Belles Perdrix de Troplong Mondot" (body); rule R2
ren|3|ve_b60189d14c|Home Aribert - Restaurant Gastronomique 2 Étoiles Michelin|Maison Aribert|michelin|https://guide.michelin.com/us/en/auvergne-rhone-alpes/uriage-les-bains/restaurant/maison-aribert|uriage-les-bains|home-aribert-restaurant-gastronomique-2-etoiles-michelin|maison-aribert|reuse|card h1 "Maison Aribert"; site maisonaribert.com "Maison Aribert" (title, site name, logo alt); Best Chef "Maison Aribert"; rule R1
ren|4|ve_4e2b60de79|KOKI - The House of Senses|Hibana by Koki|michelin|https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/hibana-by-koki|hanoi|koki-the-house-of-senses|hibana-by-koki|insert|card h1 "Hibana by Koki" (One Star 2026, B1F Capella Hanoi); Best Chef 2024/2025 "Hibana by Koki"; site capellahotels.com not read (client error); rule R5; 101 Best Steakhouses row (Koki, parent restaurant) stays on the venue (Ben D3 = A)
ren|5|ve_53b3c4e143|EDGE for Men - V & A Waterfront|EDGE|best-chef-awards|https://thebestchefawards.com/?post_type=chefs&p=25174|cape-town|edge-for-men-v-a-waterfront|edge|insert|live name is a shop name; Best Chef 2025 card "EDGE" (Vusi Ndlovu, Cape Town); site edgerestaurant.africa "EDGE" (title, menu, footer; capitals only); rule R3
ren|6|ve_ab0ec4c74c|Xiamen|XIA|best-chef-awards|https://thebestchefawards.com/?post_type=chefs&p=24980|xiamen|xiamen|xia|insert|live name is the city (legacy load lost the name); Best Chef 2025 card "Xia" (Kang Yang); site lohkahhotel.com "XIA RESTAURANT", "XIA Restaurant", "XIA" (capitals only); Michelin card "Xia"; rule R3
ren|7|ve_2922f8b9e6|The Palash Vann Resort|Palaash|best-chef-awards|https://thebestchefawards.com/?post_type=chefs&p=24787|maharashtra|the-palash-vann-resort|palaash|insert|Best Chef 2024/2025 card "Palaash" (Amninder Sandhu, Tipai, Yavatmal); site wildlifeluxuries.com "Palaash"; rule R1
ren|8|ve_83aca60857|Hotel Cañitas Classic|Cañitas Maite|best-chef-awards|https://thebestchefawards.com/?post_type=chefs&p=24941|casas-ibanez|hotel-canitas-classic|canitas-maite|insert|live name is the hotel; Best Chef 2025 card and Michelin card "Cañitas Maite Gastro" (Tomás Pérez Úbeda 6, the hotel address); site hotelcanitasmaite.com writes "Cañitas Maite", "Restaurante Cañitas Maite", never "Gastro", title "Cañitas Maite"; rule R4
fix|3453|ve_53ec037b5f|ve_53ec037b5f|https://thebestchefawards.com/events-results/?id=2376|Flores Raras = El Poblet renamed Jan 2026 (same address C/ Correus 8, same owner; Michelin card "formerly known as El Poblet"); Best Chef 2025 card Luis Valls "El Poblet (former workplace)", 2 knives
fix|15690|ve_d6d7a07cee|ve_38916224da|https://thebestchefawards.com/events-results/?id=2376|moved Ensue -> Fumée: Best Chef 2025 has one Shenzhen 2-knife entry, Reina Chen, Fumée; Ensue (Jeff Wu) is 1 knife = row 15691
add|ve_f026dbec1c|2024|2-Knife|https://thebestchefawards.com/events-results/?id=1874|Guy Savoy (Paris), Best Chef 2024 card 2 knives (chef id 19907)
add|ve_f026dbec1c|2025|2-Knife|https://thebestchefawards.com/events-results/?id=2376|Guy Savoy (Paris), Best Chef 2025 card 2 knives (chef id 19907)$rel$, E'\r', '');
  bid bigint; n int; x int; v_lid bigint;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> 'b73aa3c9caaed36d49f3eb654ae94987550da1c1bf7f7d64feec09ea9067b656' THEN RAISE EXCEPTION 'relay hash'; END IF;
  -- counts before
  IF (SELECT count(*) FROM venues) <> 11302 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12945 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1643 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11302 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 18 OR (SELECT count(*) FROM rename_rows) <> 1201 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 136 OR (SELECT max(id) FROM source_capture_ledger) <> 180 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115448 OR (SELECT max(id) FROM audit_log) <> 120732 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key = 'rename-open-items-b9-2026-11-01') THEN RAISE EXCEPTION 'batch key used'; END IF;

  -- rename gates
  IF (SELECT count(*) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren') <> 8 THEN RAISE EXCEPTION 'ren lines'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id)) FROM venues v JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND v.id = split_part(l, '|', 3)
         AND v.name = split_part(l, '|', 4) AND v.status = 'active') <> '0f9c5a1cc4096ddaf4b99e2700de2082' THEN RAISE EXCEPTION 'live names differ from the Nov 1 read'; END IF;
  IF (SELECT md5(string_agg(split_part(l, '|', 3)||'|'||split_part(l, '|', 5), E'\n' ORDER BY split_part(l, '|', 3))) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren') <> '98adaa471aa0de64fb8aaf4f3a54e9e7' THEN RAISE EXCEPTION 'new names'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows r JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND r.venue_id = split_part(l, '|', 3)) THEN RAISE EXCEPTION 'earlier rename_rows'; END IF;
  IF (SELECT count(*) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren'
        AND trim(both '-' from regexp_replace(lower(f_unaccent(split_part(l, '|', 5))), '[^a-z0-9]+', '-', 'g')) = split_part(l, '|', 10)) <> 8 THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND s.venue_id = split_part(l, '|', 3) AND s.property_id = 'eats'
        AND s.is_canonical AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 9)) <> 8 THEN RAISE EXCEPTION 'old canonical slugs'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND split_part(l, '|', 11) = 'reuse' AND s.venue_id = split_part(l, '|', 3)
        AND s.property_id = 'eats' AND NOT s.is_canonical AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 10)) <> 3 THEN RAISE EXCEPTION 'reuse slugs'; END IF;
  IF EXISTS (SELECT 1 FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND split_part(l, '|', 11) = 'insert' AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 10))
    THEN RAISE EXCEPTION 'new slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM redirects d JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren'
        AND d.from_path IN ('/'||split_part(l, '|', 8)||'/'||split_part(l, '|', 10), '/venue/'||split_part(l, '|', 8)||'/'||split_part(l, '|', 10))) THEN RAISE EXCEPTION 'new path in redirects'; END IF;
  WITH batch AS (SELECT split_part(l, '|', 3) AS venue_id, split_part(l, '|', 5) AS new_name FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren'),
       scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
       fin   AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
                   FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id)
  SELECT count(*) INTO x FROM fin a JOIN batch ON batch.venue_id = a.id
    JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id AND norm_key(o.name) = norm_key(a.name);
  IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key collisions %', x; END IF;

  -- fix / add gates
  IF (SELECT count(*) FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'fix' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3)
        AND a.source_id = 'best-chef-awards' AND a.year = 2025 AND a.category = '2-Knife' AND a.source_url IS NULL) <> 2 THEN RAISE EXCEPTION 'fix rows'; END IF;
  IF (SELECT count(*) FROM venues WHERE id = 've_38916224da' AND name = 'Fumée' AND status = 'active') <> 1
     OR EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_38916224da' AND source_id = 'best-chef-awards') THEN RAISE EXCEPTION 'Fumée'; END IF;
  IF (SELECT count(*) FROM venues WHERE id = 've_f026dbec1c' AND name = 'Guy Savoy' AND status = 'active') <> 1
     OR EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_f026dbec1c' AND source_id = 'best-chef-awards') THEN RAISE EXCEPTION 'Guy Savoy'; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id = 'best-chef-awards' AND category = '2-Knife') <> 1 THEN RAISE EXCEPTION 'category'; END IF;
  IF (SELECT count(*) FROM award_sources WHERE slug IN ('michelin', 'best-chef-awards')) <> 2 THEN RAISE EXCEPTION 'sources'; END IF;

  -- 1. rename batch
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-open-items-b9-2026-11-01', 'staged', 'Open items block 9 (Nov 1): 8 venue names from the Best Chef pairing check (Cyrillic letter, shop, hotel or city names in place of the restaurant name); rules R1-R5. Ben Nov 1 08:28 ET "All recommendations". Gated SQL file, Write connector; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, split_part(l, '|', 2)::int, split_part(l, '|', 3), split_part(l, '|', 4), split_part(l, '|', 5), split_part(l, '|', 6), split_part(l, '|', 7), 'rename',
         jsonb_build_object('note', split_part(l, '|', 12) || ' | Ben Nov 1 08:28 ET "All recommendations"', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', split_part(l, '|', 8), 'slug', split_part(l, '|', 9))
    FROM regexp_split_to_table(rel, E'\n') l JOIN venues v ON v.id = split_part(l, '|', 3) WHERE split_part(l, '|', 1) = 'ren';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = split_part(l, '|', 5) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren' AND v.id = split_part(l, '|', 3) AND v.name = split_part(l, '|', 4);
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 8 THEN RAISE EXCEPTION 'venues renamed %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 4, 'rename-apply:rename-open-items-b9-2026-11-01 | gated SQL file docs/rename-urls-open-items-b9-2026-11-01.sql (Write connector) | 4 names follow the Michelin 2026 card and the venue site, rules R1, R2, R5: Le Calandre (Cyrillic letter removed), Les Belles Perdrix de Troplong Mondot, Maison Aribert, Hibana by Koki | Ben Nov 1 08:28 ET "All recommendations"')
  RETURNING id INTO v_lid;
  IF v_lid <> 181 THEN RAISE EXCEPTION 'ledger id michelin name %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'name', 4, 'rename-apply:rename-open-items-b9-2026-11-01 | gated SQL file docs/rename-urls-open-items-b9-2026-11-01.sql (Write connector) | 4 names follow the Best Chef card and the venue site, rules R1, R3, R4: EDGE (was a shop name), XIA (was the city), Palaash (was the resort), Cañitas Maite (was the hotel) | Ben Nov 1 08:28 ET "All recommendations"')
  RETURNING id INTO v_lid;
  IF v_lid <> 182 THEN RAISE EXCEPTION 'ledger id best-chef name %', v_lid; END IF;
  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status'; END IF;

  -- 2. slugs
  UPDATE slugs s SET is_canonical = false FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'ren' AND s.property_id = 'eats' AND s.venue_id = split_part(l, '|', 3) AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 9) AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'old canonical updated %', n; END IF;
  UPDATE slugs s SET is_canonical = true FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'ren' AND split_part(l, '|', 11) = 'reuse' AND s.property_id = 'eats' AND s.venue_id = split_part(l, '|', 3) AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 10) AND NOT s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'reused slugs %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', split_part(l, '|', 8), split_part(l, '|', 10), split_part(l, '|', 3), true FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'ren' AND split_part(l, '|', 11) = 'insert';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 5 THEN RAISE EXCEPTION 'new slugs %', n; END IF;

  -- 3. award row fixes
  UPDATE awards a SET venue_id = split_part(l, '|', 4), source_url = split_part(l, '|', 5) FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'fix' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3) AND a.source_id = 'best-chef-awards' AND a.source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'fixed rows %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2, 'pair-fix:rename-urls-open-items-b9-2026-11-01 | 2 of the 5 rows held on Nov 1 (block 8) get the 2025 results page https://thebestchefawards.com/events-results/?id=2376: 3453 stays on Flores Raras (El Poblet renamed Jan 2026, same address and owner; card Luis Valls "El Poblet (former workplace)"); 15690 moves Ensue ve_d6d7a07cee -> Fumée ve_38916224da (the one Shenzhen 2-knife card = Reina Chen, Fumée; Ensue is 1 knife = 15691) | 15727 held for the Hong Kong/Macau block | Ben Nov 1 08:28 ET "All recommendations"')
  RETURNING id INTO v_lid;
  IF v_lid <> 183 THEN RAISE EXCEPTION 'ledger id pair-fix %', v_lid; END IF;

  -- 4. award rows added
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT split_part(l, '|', 2), 'best-chef-awards', split_part(l, '|', 3)::int, NULL, split_part(l, '|', 4), NULL, split_part(l, '|', 5) FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'add';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards added %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2, 'award-add:rename-urls-open-items-b9-2026-11-01 | ve_f026dbec1c Guy Savoy (Paris) 2024 2-Knife (https://thebestchefawards.com/events-results/?id=1874) and 2025 2-Knife (https://thebestchefawards.com/events-results/?id=2376); chef card 19907 on both results pages, no row before (pairing check Nov 1) | Ben Nov 1 08:28 ET "All recommendations"')
  RETURNING id INTO v_lid;
  IF v_lid <> 184 THEN RAISE EXCEPTION 'ledger id award-add %', v_lid; END IF;

  -- post-checks
  IF (SELECT count(*) FROM venues) <> 11302 OR (SELECT count(*) FROM listings) <> 11302 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'venues/listings/blurbs after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23365 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12950 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1651
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11302 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1)
    THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND s.venue_id = split_part(l, '|', 3) AND s.is_canonical AND s.city_slug = split_part(l, '|', 8) AND s.slug = split_part(l, '|', 10)) <> 8
    THEN RAISE EXCEPTION 'new canonical slugs after'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id)) FROM venues v JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND v.id = split_part(l, '|', 3)) <> '98adaa471aa0de64fb8aaf4f3a54e9e7'
    THEN RAISE EXCEPTION 'names after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 19 OR (SELECT count(*) FROM rename_rows) <> 1209 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 140 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM awards WHERE id IN (3453, 15690) AND source_url = 'https://thebestchefawards.com/events-results/?id=2376' AND venue_id IN ('ve_53ec037b5f', 've_38916224da')) <> 2 THEN RAISE EXCEPTION 'fixed rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_f026dbec1c' AND source_id = 'best-chef-awards') <> 2 THEN RAISE EXCEPTION 'Guy Savoy rows after'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115476 OR (SELECT count(*) FROM audit_log WHERE id > 120732) <> 28 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'ren' AND a.row_pk = split_part(l, '|', 3)
       WHERE a.id > 120732 AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.old_row->>'name' = split_part(l, '|', 4) AND a.new_row->>'name' = split_part(l, '|', 5)
         AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key')) <> 8 THEN RAISE EXCEPTION 'audit venues (name, norm_key only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120732 AND table_name = 'slugs' AND action = 'UPDATE') <> 11
     OR (SELECT count(*) FROM audit_log WHERE id > 120732 AND table_name = 'slugs' AND action = 'INSERT') <> 5 THEN RAISE EXCEPTION 'audit slugs'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120732 AND table_name = 'awards' AND action = 'UPDATE' AND row_pk = '3453'
         AND (old_row - 'source_url') = (new_row - 'source_url')) <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > 120732 AND table_name = 'awards' AND action = 'UPDATE' AND row_pk = '15690'
         AND (old_row - 'source_url' - 'venue_id') = (new_row - 'source_url' - 'venue_id') AND new_row->>'venue_id' = 've_38916224da') <> 1
    THEN RAISE EXCEPTION 'audit award updates'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120732 AND table_name = 'awards' AND action = 'INSERT') <> 2 THEN RAISE EXCEPTION 'audit award inserts'; END IF;
END
$do$;
COMMIT;
