-- open-items-b2-status-price-url-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 2, file 1 of 2 (items 1-3). Run through the Write connector.
--
-- Ben: Oct 30 21:36 ET "1-4"; 22:14 ET "All recommended" (D1-D9 = A). This file holds D2, D3, D4 and the item 1 URL.
-- D1 (Chay Garden 10486: no 2025-edition card on 6 locale paths), D5 (Efendy stays active), D6 (unknown Turkey Bib)
-- and the Sankai site spam need no write.
--
-- What this file does (one transaction, one DO block):
--   W1 awards source_url NULL -> archive card URL (year and category unchanged):
--      10493 Hu Tieu Hong Phat 2025 Bib = archive card Sep 8, 2025 (vn/en; meta "2025 MICHELIN Guide Vietnam", dateAwarded 2025)
--      10908 Dill 2025 Bib = archive card Aug 5, 2025 (gb/en; meta "2025 MICHELIN Guide United Kingdom", dateAwarded 2025)
--      Ledger 168 (michelin, award, 2).
--   W2 venues status active -> closed (status only; no ledger row, SLOW&LOW / Sankai precedent):
--      ve_fff5bda31e Nadair (Atlanta): Rough Draft Jun 19, 2026, last service Jun 27, 2026; card 404 Oct 31.
--      ve_b3825c7559 Dill (Lewes): The Good Food Guide label "Closed" (read Oct 31); card 404 (left the 2026 list).
--   W3 price from the Michelin card (rule Sep 28: the card price wins over a legacy price with no URL):
--      INSERT ve_f088b7a06a Sankai by Nagaya: TRY 4 (live card read Oct 30 17:59 UTC).
--      UPDATE legacy $$ rows: ve_51ce2088a5 Efendy Istanbul TRY 2 (archive card Jan 6, 2026, read Oct 31 02:15 UTC);
--             ve_f8013e6d34 Lucien Arkas Baglari TRY 2 (LA Mahzen live card, read Oct 30 17:59 UTC).
--      Ledger 169 (michelin, price, 3).
--   Audit rows 118,999-119,005 (7): awards UPDATE 2, venues UPDATE 2, price INSERT 1, price UPDATE 2.
-- Relay: open-items-b2-build/relay-file1.txt, sha256 0ea57841c2b428f06eaf0e93c494c7d696f04091d2d191192c750eca8643657b, md5 66bb32775fbc1c318bc2c73b7e872e82.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  rel_txt constant text := $rel$url|10493|ve_39dc53fd44|Bib Gourmand|https://web.archive.org/web/20250908053336id_/https://guide.michelin.com/vn/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3
url|10908|ve_b3825c7559|Bib Gourmand|https://web.archive.org/web/20250805095033id_/https://guide.michelin.com/gb/en/east-sussex/lewes_1754494/restaurant/dill-1205977
status|ve_b3825c7559|active|closed
status|ve_fff5bda31e|active|closed
price-ins|ve_f088b7a06a|4|₺₺₺₺|TRY|https://guide.michelin.com/us/en/istanbul-province/istanbul/restaurant/sankai-by-nagaya|2026-10-30T17:59:54.848Z
price-upd|ve_51ce2088a5|2|₺₺|TRY|https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy|2026-10-31T02:15:37.451Z
price-upd|ve_f8013e6d34|2|₺₺|TRY|https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen|2026-10-30T17:59:53.599Z$rel$;
  v_n bigint;
  v_lid1 bigint;
  v_lid2 bigint;
  v_t text;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '0ea57841c2b428f06eaf0e93c494c7d696f04091d2d191192c750eca8643657b' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF (SELECT count(*) FROM awards) <> 23358 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'price before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11304 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 367 THEN RAISE EXCEPTION 'closed venues before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 167 THEN RAISE EXCEPTION 'ledger max before is not 167'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118998 THEN RAISE EXCEPTION 'audit max before is not 118998'; END IF;

  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,'-'), E'\n' ORDER BY a.id))
    INTO v_t FROM awards a WHERE a.id IN (10493, 10908);
  IF v_t IS DISTINCT FROM 'caeea260ef28114c53e8eaa9bef472e2' THEN RAISE EXCEPTION 'award rows changed: %', v_t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id))
    INTO v_t FROM venues v WHERE v.id IN ('ve_fff5bda31e', 've_b3825c7559');
  IF v_t IS DISTINCT FROM '178f417744a9d94a60bbe8e4726251da' THEN RAISE EXCEPTION 'status venue rows changed: %', v_t; END IF;
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||p.symbol_raw||'|'||coalesce(p.currency,'-')||'|'||p.source||'|'||p.method||'|'||p.publisher||'|'||coalesce(p.source_url,'-'), E'\n' ORDER BY p.venue_id))
    INTO v_t FROM price p WHERE p.venue_id IN ('ve_51ce2088a5', 've_f8013e6d34', 've_f088b7a06a');
  IF v_t IS DISTINCT FROM 'a185af400de9ce38b305c6fda06380bb' THEN RAISE EXCEPTION 'price rows changed: %', v_t; END IF;
  IF EXISTS (SELECT 1 FROM price WHERE venue_id = 've_f088b7a06a') THEN RAISE EXCEPTION 'Sankai has a price row'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active' AND id IN ('ve_51ce2088a5', 've_f8013e6d34', 've_f088b7a06a')) <> 3
    THEN RAISE EXCEPTION 'a price venue is not active'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN (VALUES
    (10493, 've_39dc53fd44', 'Bib Gourmand', 'https://web.archive.org/web/20250908053336id_/https://guide.michelin.com/vn/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3'),
    (10908, 've_b3825c7559', 'Bib Gourmand', 'https://web.archive.org/web/20250805095033id_/https://guide.michelin.com/gb/en/east-sussex/lewes_1754494/restaurant/dill-1205977')) AS x(award_id, venue_id, category, url) ON a.source_url = x.url)
    THEN RAISE EXCEPTION 'a relay award URL is already in use'; END IF;

  ---------------------------------------------------------------- W1 award URLs
  UPDATE awards a SET source_url = x.url
    FROM (VALUES
    (10493, 've_39dc53fd44', 'Bib Gourmand', 'https://web.archive.org/web/20250908053336id_/https://guide.michelin.com/vn/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3'),
    (10908, 've_b3825c7559', 'Bib Gourmand', 'https://web.archive.org/web/20250805095033id_/https://guide.michelin.com/gb/en/east-sussex/lewes_1754494/restaurant/dill-1205977')) AS x(award_id, venue_id, category, url)
   WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.category = x.category
     AND a.source_id = 'michelin' AND a.year = 2025 AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'award rows updated: %', v_n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 2,
          'source-url:open-items-b2-status-price-url-2026-10-30 | award source_url NULL -> archive card URL, year and category unchanged '
          || '| 10493 Hong Phat (District 3) card Sep 8, 2025 vn/en (2025 MICHELIN Guide Vietnam, dateAwarded 2025); 10908 Dill card '
          || 'Aug 5, 2025 gb/en (2025 MICHELIN Guide United Kingdom, dateAwarded 2025) | Chay Garden 10486 left NULL (no 2025-edition '
          || 'card; Ben D1 A) | Ben "All recommended" Oct 30 22:14 ET | relay md5 66bb32775fbc1c318bc2c73b7e872e82')
  RETURNING id INTO v_lid1;

  ---------------------------------------------------------------- W2 venue status
  UPDATE venues v SET status = 'closed'
    FROM (VALUES
    ('ve_b3825c7559', 'active', 'closed'),
    ('ve_fff5bda31e', 'active', 'closed')) AS x(venue_id, old_status, new_status)
   WHERE v.id = x.venue_id AND v.status::text = x.old_status AND x.old_status = 'active' AND x.new_status = 'closed';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'venue status rows updated: %', v_n; END IF;

  ---------------------------------------------------------------- W3 prices
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, x.tier::smallint, x.symbol_raw, x.currency, 'guide_ingest', 'published_symbol', 'michelin', x.url,
         x.captured_at::timestamptz, NULL
    FROM (VALUES
    ('price-ins', 've_f088b7a06a', 4, '₺₺₺₺', 'TRY', 'https://guide.michelin.com/us/en/istanbul-province/istanbul/restaurant/sankai-by-nagaya', '2026-10-30T17:59:54.848Z'),
    ('price-upd', 've_51ce2088a5', 2, '₺₺', 'TRY', 'https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy', '2026-10-31T02:15:37.451Z'),
    ('price-upd', 've_f8013e6d34', 2, '₺₺', 'TRY', 'https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen', '2026-10-30T17:59:53.599Z')) AS x(op, venue_id, tier, symbol_raw, currency, url, captured_at)
   WHERE x.op = 'price-ins';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'price rows inserted: %', v_n; END IF;
  UPDATE price p
     SET tier = x.tier::smallint, symbol_raw = x.symbol_raw, currency = x.currency, source = 'guide_ingest',
         method = 'published_symbol', publisher = 'michelin', source_url = x.url,
         captured_at = x.captured_at::timestamptz, confidence = NULL
    FROM (VALUES
    ('price-ins', 've_f088b7a06a', 4, '₺₺₺₺', 'TRY', 'https://guide.michelin.com/us/en/istanbul-province/istanbul/restaurant/sankai-by-nagaya', '2026-10-30T17:59:54.848Z'),
    ('price-upd', 've_51ce2088a5', 2, '₺₺', 'TRY', 'https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy', '2026-10-31T02:15:37.451Z'),
    ('price-upd', 've_f8013e6d34', 2, '₺₺', 'TRY', 'https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen', '2026-10-30T17:59:53.599Z')) AS x(op, venue_id, tier, symbol_raw, currency, url, captured_at)
   WHERE x.op = 'price-upd' AND p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL
     AND p.symbol_raw = '$$' AND p.currency IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'price rows updated: %', v_n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', 3,
          'price-card:open-items-b2-status-price-url-2026-10-30 | Turkey follow-ups: Sankai by Nagaya INSERT TRY 4 (live card); '
          || 'Efendy Istanbul legacy $$ -> TRY 2 (archive card Jan 6, 2026, the card left the guide after Jan 28); Lucien Arkas Baglari '
          || 'legacy $$ -> TRY 2 (LA Mahzen live card) | Ben D4 A Oct 30 22:14 ET | relay md5 66bb32775fbc1c318bc2c73b7e872e82')
  RETURNING id INTO v_lid2;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM awards) <> 23358 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM price) <> 7731 THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 369 THEN RAISE EXCEPTION 'closed venues after'; END IF;
  IF v_lid1 <> 168 OR v_lid2 <> 169 OR (SELECT max(id) FROM source_capture_ledger) <> 169
    THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998) <> 7 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'awards' AND action = 'UPDATE'
         AND row_pk IN ('10493', '10908') AND (old_row - 'source_url') = (new_row - 'source_url')
         AND old_row->>'source_url' IS NULL) <> 2
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'venues' AND action = 'UPDATE'
         AND row_pk IN ('ve_fff5bda31e', 've_b3825c7559') AND (old_row - 'status') = (new_row - 'status')
         AND old_row->>'status' = 'active' AND new_row->>'status' = 'closed') <> 2
    THEN RAISE EXCEPTION 'audit venues UPDATE rows (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'price' AND action = 'INSERT' AND row_pk = 've_f088b7a06a') <> 1
    THEN RAISE EXCEPTION 'audit price INSERT row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'price' AND action = 'UPDATE'
         AND row_pk IN ('ve_51ce2088a5', 've_f8013e6d34') AND old_row->>'source' = 'legacy_guide') <> 2
    THEN RAISE EXCEPTION 'audit price UPDATE rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN (VALUES
    (10493, 've_39dc53fd44', 'Bib Gourmand', 'https://web.archive.org/web/20250908053336id_/https://guide.michelin.com/vn/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3'),
    (10908, 've_b3825c7559', 'Bib Gourmand', 'https://web.archive.org/web/20250805095033id_/https://guide.michelin.com/gb/en/east-sussex/lewes_1754494/restaurant/dill-1205977')) AS x(award_id, venue_id, category, url)
        ON a.id = x.award_id AND a.source_url = x.url AND a.year = 2025) <> 2
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p JOIN (VALUES
    ('price-ins', 've_f088b7a06a', 4, '₺₺₺₺', 'TRY', 'https://guide.michelin.com/us/en/istanbul-province/istanbul/restaurant/sankai-by-nagaya', '2026-10-30T17:59:54.848Z'),
    ('price-upd', 've_51ce2088a5', 2, '₺₺', 'TRY', 'https://web.archive.org/web/20260106015516id_/https://guide.michelin.com/en/istanbul-province/istanbul/restaurant/efendy', '2026-10-31T02:15:37.451Z'),
    ('price-upd', 've_f8013e6d34', 2, '₺₺', 'TRY', 'https://guide.michelin.com/us/en/izmir/izmir_2809416/restaurant/la-mahzen', '2026-10-30T17:59:53.599Z')) AS x(op, venue_id, tier, symbol_raw, currency, url, captured_at)
        ON p.venue_id = x.venue_id AND p.tier = x.tier AND p.symbol_raw = x.symbol_raw AND p.currency = x.currency
       AND p.source_url = x.url AND p.captured_at = x.captured_at::timestamptz
     WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin' AND p.confidence IS NULL) <> 3
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 10486 AND source_url IS NULL) <> 1 THEN RAISE EXCEPTION 'Chay Garden 10486 changed'; END IF;
END
$do$;
COMMIT;
