-- awards-status-open-items-b6-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 6, file 3 of 3. Run after files 1 and 2. Write connector.
-- Ben: Oct 31 01:56 ET "1, 2A, 2B"; 02:01 ET "Your recommendation for everything" (D1-D5 = A).
-- W1 (D3) INSERT awards: ve_a3512f9a51 Duddell's (3/F) michelin 2026 One Star, card https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s
--    (Duddell's 3/F: card h1 "Duddell's", One Star, 2026 MICHELIN Guide Hong Kong (live card read Oct 31); Ben Oct 31 02:01 ET (D3 = A)). Ledger +1 (michelin, award, 1).
-- W2 (D4) UPDATE venues status active -> closed: ve_89ca903ac2 Terra (Fisterra). Status only, no ledger row (Nadair / Dill precedent).
--    Evidence: Terra (Fisterra): site notice "Este 27 de septiembre será nuestro último servicio" (no year) [https://terrafisterra.com/]; us/en card 404; Michelin Fisterra list (read Oct 31) shows no Terra; Ben Oct 31 02:01 ET (D4 = A)
--    The 2026 award row 25391 stays as history.
-- W3 UPDATE cities.venues_count ci_1f2c831b43 Fisterra 1 -> 0 (block 5 method: stored count = view city_venue_counts).
-- D2 no merge (Duddell's), D5 La Torre One Fire: no write.
-- Relay: docs/open-items-b6-build/relay.txt sha256 a56c3d89a09c8463128b32100f401191790d5445e44ac5ec8414c4fe536707c5.
-- Expected: awards 23362 -> 23363; closed venues 369 -> 370; ledger last id 174 -> 175;
-- audit +3 (last id 119406 -> 119409: awards INSERT 1, venues UPDATE 1, cities UPDATE 1); venues_count sum 10934 -> 10933.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  rel_txt constant text := $rel$ren|1|ve_542c195114|Paca Ristorante|Paca|michelin|https://guide.michelin.com/us/en/toscana/carmignano_1833819/restaurant/paca|Open items block 6 (2026-10-31); live "Paca Ristorante"; card h1 "Paca"; site read: "Ristorante Paca - Tenuta Ceri" (title), "PACA TENUTA CERI" (H1), "Paca Tenuta Ceri" (menu), "Paca" (body) [https://www.tenutaceri.it/ristorante-paca/]; rule R2 (site writes more than one form; card form "Paca" is one of them); Ben Oct 31 01:56 ET "1, 2A, 2B", 02:01 ET "Your recommendation for everything" (D1 = A)
ren|2|ve_e50adc624d|Restaurante Temático El Jardín de la Sal|El Jardín de la Sal|michelin|https://guide.michelin.com/us/en/canarias/fuencaliente-de-la-palma/restaurant/el-jardin-de-la-sal|Open items block 6 (2026-10-31); live "Restaurante Temático El Jardín de la Sal"; card h1 "El Jardín de la Sal"; site read: "Restaurante El Jardín de la Sal" (menu), "EL JARDÍN DE LA SAL" (footer heading) [https://www.salinasdefuencaliente.es]; rule R2 + R3 (card form = the heading form); "Temático" is a site descriptor, not the name; Ben Oct 31 02:01 ET (D1 = A)
ren|3|ve_eef796a74d|Coxinendi - Ristorante|Coxinendi|michelin|https://guide.michelin.com/us/en/sardegna/quartu-sant-elena_1840763/restaurant/coxinendi|Open items block 6 (2026-10-31); live "Coxinendi - Ristorante"; card h1 "Coxinendi"; site not read (https://www.coxinendi.com robots_disallowed); rule R5 (card name minus suffix); Ben Oct 31 02:01 ET (D1 = A)
ren|4|ve_f558535881|Kresios|Krèsios|michelin|https://guide.michelin.com/us/en/campania/telese-terme_1850913/restaurant/kresios|Open items block 6 (2026-10-31); live "Kresios"; card h1 "Krèsios"; site read: "Krèsios" (title "Krèsios - Giuseppe Iannotti Chef", og:site_name, og:title); "Kresios" only in URLs and file names [https://www.kresios.com/]; rule R1; other publishers best-chef-awards, la-liste, oad (spelling not stored); slug kresios unchanged; Ben Oct 31 02:01 ET (D1 = A)
ren|5|ve_f88a5d9dc2|Duddell's|The Upper Room at Duddell’s|pinnacle-guide|https://www.thepinnacleguide.com/the-upper-room-at-duddells/|Open items block 6 (2026-10-31); live "Duddell's" (category bar; same norm_key as the restaurant ve_a3512f9a51); Pinnacle Guide heading "The Upper Room At Duddell's" (4/F, part of Duddell's); site read: "The Upper Room at Duddell’s" (opening hours), "The Upper Room" (section heading); 3/F is "Main Dining Room" [https://duddells.co/pages/venue-interior-design]; rule R2 + R3, apostrophe as the site writes it (R6); not a duplicate, no merge; Ben Oct 31 02:01 ET (D2 = A)
status|ve_89ca903ac2|active|closed|Terra (Fisterra): site notice "Este 27 de septiembre será nuestro último servicio" (no year) [https://terrafisterra.com/]; us/en card 404; Michelin Fisterra list (read Oct 31) shows no Terra; Ben Oct 31 02:01 ET (D4 = A)
award|ve_a3512f9a51|michelin|2026|One Star|https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s|Duddell's 3/F: card h1 "Duddell's", One Star, 2026 MICHELIN Guide Hong Kong (live card read Oct 31); Ben Oct 31 02:01 ET (D3 = A)
count|ci_1f2c831b43|1|0|Fisterra venues_count after the Terra closure (= view city_venue_counts.active_venues)$rel$;
  v_n bigint;
  v_lid bigint;
  v_aid bigint;
  v_aud bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> 'a56c3d89a09c8463128b32100f401191790d5445e44ac5ec8414c4fe536707c5' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF (SELECT count(*) FROM awards) <> 23362 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 369 THEN RAISE EXCEPTION 'closed venues before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 174 THEN RAISE EXCEPTION 'ledger max before'; END IF;
  SELECT max(id) INTO v_aud FROM audit_log;
  IF v_aud <> 119406 THEN RAISE EXCEPTION 'audit max before %', v_aud; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10934 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ from the view before'; END IF;

  -- W1 gates: the venue is active, has no michelin 2026 row, and the URL is not in use
  IF (SELECT count(*) FROM venues WHERE id = 've_a3512f9a51' AND status = 'active' AND name = 'Duddell''s' AND category = 'restaurant') <> 1
    THEN RAISE EXCEPTION 'Duddell''s restaurant row changed'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_a3512f9a51' AND source_id = 'michelin' AND year = 2026)
    THEN RAISE EXCEPTION 'Duddell''s already has a michelin 2026 row'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url = 'https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s') THEN RAISE EXCEPTION 'card URL already in use'; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id = 'michelin' AND category = 'One Star') <> 1
    THEN RAISE EXCEPTION 'category not registered'; END IF;

  -- W2/W3 gates
  IF (SELECT count(*) FROM venues WHERE id = 've_89ca903ac2' AND status = 'active' AND name = 'Terra' AND city_id = 'ci_1f2c831b43') <> 1
    THEN RAISE EXCEPTION 'Terra row changed'; END IF;
  IF (SELECT venues_count FROM cities WHERE id = 'ci_1f2c831b43') <> 1 THEN RAISE EXCEPTION 'Fisterra venues_count before'; END IF;
  IF (SELECT count(*) FROM venues WHERE city_id = 'ci_1f2c831b43' AND status = 'active') <> 1 THEN RAISE EXCEPTION 'Fisterra active count before'; END IF;

  ---------------------------------------------------------------- W1 award INSERT
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  VALUES ('ve_a3512f9a51', 'michelin', 2026, NULL, 'One Star', NULL, 'https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s')
  RETURNING id INTO v_aid;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 1,
          'award-add:awards-status-open-items-b6-2026-10-31 | ve_a3512f9a51 Duddell''s (Hong Kong, 3/F) michelin 2026 One Star, live card '
          || 'https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s (2026 MICHELIN Guide Hong Kong, read Oct 31) | Ben D3 A Oct 31 02:01 ET '
          || '| note: Hong Kong has 0 michelin 2026 rows (edition not loaded; separate open item)')
  RETURNING id INTO v_lid;

  ---------------------------------------------------------------- W2 venue status
  UPDATE venues SET status = 'closed' WHERE id = 've_89ca903ac2' AND status = 'active';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'venue status rows updated: %', v_n; END IF;

  ---------------------------------------------------------------- W3 stored count
  UPDATE cities SET venues_count = 0 WHERE id = 'ci_1f2c831b43' AND venues_count = 1;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'cities rows updated: %', v_n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 370 THEN RAISE EXCEPTION 'closed venues after'; END IF;
  IF v_lid <> 175 OR (SELECT max(id) FROM source_capture_ledger) <> 175 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10933 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ from the view after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud) <> 3 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'awards' AND action = 'INSERT' AND row_pk = v_aid::text) <> 1
    THEN RAISE EXCEPTION 'audit awards INSERT row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = 've_89ca903ac2'
         AND (old_row - 'status') = (new_row - 'status') AND old_row->>'status' = 'active' AND new_row->>'status' = 'closed') <> 1
    THEN RAISE EXCEPTION 'audit venues UPDATE row (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'cities' AND action = 'UPDATE'
         AND (old_row - 'venues_count') = (new_row - 'venues_count')
         AND old_row->>'venues_count' = '1' AND new_row->>'venues_count' = '0') <> 1
    THEN RAISE EXCEPTION 'audit cities UPDATE row (venues_count only)'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 25391 AND venue_id = 've_89ca903ac2' AND year = 2026) <> 1 THEN RAISE EXCEPTION 'Terra 2026 row changed'; END IF;
END
$do$;
COMMIT;
