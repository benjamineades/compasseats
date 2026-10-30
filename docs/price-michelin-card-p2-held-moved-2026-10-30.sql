-- price-michelin-card-p2-held-moved-2026-10-30.sql
-- Block A, step 2, held pass (9 held P2 venues, card at a new path).
-- Population: held P2 venues (card 404 or redirect in batches 1 to 10) whose card now lives at a new path on
-- guide.michelin.com (redirect, or the same venue in the current city list, matched by address). Ben "agree", Oct 30, 2026.
-- Step 1: 9 UPDATE of awards.source_url (the one Michelin award row of each venue): old card URL -> new card URL.
--         Year, category and all other columns do not change.
-- Step 2: 9 UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
--         source_url = new card URL, symbol_raw = card symbol, currency from card country, tier = symbol count,
--         confidence NULL, captured_at = read time).
-- Card distinction equals the award category on every row (guarded).
-- Currencies: EUR 8, JPY 1. Card tiers: 1 = 1, 2 = 4, 4 = 4. Card distinction: 1 star 2, 2 star 2, bib 5. Award ids: 22682,23079,23083,23258,23350,23588,23667,24729,25629.
-- Relay sha256 dd3a1706feeb9bb34a91d5a1e6944f7ffb9083c6d3f17c3f121f63db60cc5c88 (inside this file).
-- Guards: counts before (price 7582, ledger max 150, audit max 118374); relay fingerprint md5
-- 3c5a25c0299323115b9c5c1a8b600029; venue id md5 eaf1b2affc008c1dae35c02a126adb63; old price rows md5 8cde06932ec1bf5fd884d1b9f0c12e41;
-- old Michelin award rows md5 21639e5b6caae8199b49c8ac779e8c0a; new URLs not in use on any award row.
-- Post-checks: price count 7582 (unchanged); ledgers 151 (award) and 152 (price);
-- audit 118375 to 118392: 9 awards UPDATE + 9 price UPDATE, nothing else; each award and price row matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_448903808c|23350|us/en/campania/telese/restaurant/la-locanda-del-borgo|us/en/campania/telese-terme_1850913/restaurant/la-locanda-del-borgo|€€€€|CAT_P04|1 star|it|2026-10-30T16:57:41.450Z
ve_542c195114|23258|us/en/toscana/prato/restaurant/paca|us/en/toscana/carmignano_1833819/restaurant/paca|€€€€|CAT_P04|1 star|it|2026-10-30T16:57:42.698Z
ve_69e1e106b5|23083|us/en/campania/vico-equense/restaurant/torre-del-saracino|us/en/campania/sorrento/restaurant/torre-del-saracino|€€€€|CAT_P04|2 star|it|2026-10-30T16:57:43.960Z
ve_6d2d60d7ba|23667|us/en/sicilia/palazzolo-acreide/restaurant/andrea-sapori-montani|us/en/sicilia/palazzolo-acreide/restaurant/andrea|€€|CAT_P02|bib|it|2026-10-30T16:57:45.203Z
ve_bb69a63e96|24729|us/en/kyoto-region/kyoto/restaurant/vegan-ramen-uzu|us/en/kyoto-region/kyoto/restaurant/uzu-kyoto|¥¥|CAT_P02|bib|jp|2026-10-30T16:57:46.453Z
ve_c4d70b9a92|22682|en/pays-de-la-loire/cholet/restaurant/la-p'tite-patte|us/en/pays-de-la-loire/cholet/restaurant/la-p%E2%80%99tite-patte|€€|CAT_P02|bib|fr|2026-10-30T16:57:47.701Z
ve_e50adc624d|25629|us/en/canarias/las-caletas/restaurant/el-jardin-de-la-sal|us/en/canarias/fuencaliente-de-la-palma/restaurant/el-jardin-de-la-sal|€|CAT_P01|bib|es|2026-10-30T16:57:48.952Z
ve_eef796a74d|23588|us/en/sardegna/sanluri/restaurant/coxinendi|us/en/sardegna/quartu-sant-elena_1840763/restaurant/coxinendi|€€|CAT_P02|bib|it|2026-10-30T16:57:50.196Z
ve_f558535881|23079|us/en/campania/telese/restaurant/kresios|us/en/campania/telese-terme_1850913/restaurant/kresios|€€€€|CAT_P04|2 star|it|2026-10-30T16:57:51.448Z$r$;
  rel jsonb;
  n_exp int := 9;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count before is not 7582'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 150 THEN RAISE EXCEPTION 'ledger max before is not 150'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118374 THEN RAISE EXCEPTION 'audit max before is not 118374'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> 'dd3a1706feeb9bb34a91d5a1e6944f7ffb9083c6d3f17c3f121f63db60cc5c88' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  -- relay line: venue_id|award_id|old card path|new card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'award_id', f[2]::bigint,
           'old_url', 'https://guide.michelin.com/' || f[3], 'new_url', 'https://guide.michelin.com/' || f[4],
           'symbol_raw', f[5], 'currency', CASE f[8] WHEN 'us' THEN 'USD' WHEN 'cn' THEN 'CNY' WHEN 'tw' THEN 'TWD' WHEN 'jp' THEN 'JPY' WHEN 'kr' THEN 'KRW' WHEN 'gb' THEN 'GBP' WHEN 'fr' THEN 'EUR' WHEN 'de' THEN 'EUR' WHEN 'it' THEN 'EUR' WHEN 'nl' THEN 'EUR' WHEN 'es' THEN 'EUR' WHEN 'be' THEN 'EUR' WHEN 'mc' THEN 'EUR' WHEN 'ie' THEN 'EUR' WHEN 'lu' THEN 'EUR' WHEN 'ad' THEN 'EUR' END,
           'tier', char_length(f[5]), 'captured_at', f[9],
           'category', CASE f[7] WHEN 'bib' THEN 'Bib Gourmand' WHEN '1 star' THEN 'One Star' WHEN '2 star' THEN 'Two Stars' WHEN '3 star' THEN 'Three Stars' END) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 9 OR f[6] <> 'CAT_P0' || char_length(f[5])
                            OR char_length(f[5]) NOT BETWEEN 1 AND 4
                            OR f[5] <> repeat(left(f[5], 1), char_length(f[5])) OR f[3] = f[4])
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
              WHERE x.currency IS NULL OR x.category IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'TWD' THEN '$' WHEN 'CNY' THEN '¥'
                                              WHEN 'JPY' THEN '¥' WHEN 'KRW' THEN '₩' WHEN 'GBP' THEN '£' WHEN 'EUR' THEN '€' END)
    THEN RAISE EXCEPTION 'symbol, currency or distinction'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.award_id||'|'||x.old_url||'|'||x.new_url||'|'||x.symbol_raw||'|'||x.currency
                        ||'|'||x.tier||'|'||x.captured_at||'|'||x.category, E'\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text);
  IF v_fp <> '3c5a25c0299323115b9c5c1a8b600029' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> 'eaf1b2affc008c1dae35c02a126adb63' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '8cde06932ec1bf5fd884d1b9f0c12e41' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||a.source_url,
                        E'\n' ORDER BY a.venue_id COLLATE "C"))
    INTO v_old
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_old IS DISTINCT FROM '21639e5b6caae8199b49c8ac779e8c0a' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;

  -- each row: venue active; legacy price row with no URL; award id = latest Michelin star/Bib card row of the venue,
  -- with the old card URL and the same category as the card distinction
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL)
      OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id AND a.venue_id = x.venue_id
                        AND a.source_url = x.old_url AND a.category = x.category)
      OR x.award_id IS DISTINCT FROM (
           SELECT a.id FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\.michelin\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows outside the held set or changed: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(new_url text) ON a.source_url = x.new_url)
    THEN RAISE EXCEPTION 'a new URL is already in use'; END IF;

  -- step 1: award source_url
  UPDATE awards a SET source_url = x.new_url
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_url = x.old_url;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', n_exp,
          'source-url:price-michelin-card-p2-held-moved-2026-10-30 | block A step 2 held pass (9 held P2 venues, card at a new path): Michelin card moved to a new path; award source_url updated, '
          || 'year and category unchanged | award ids 22682,23079,23083,23258,23350,23588,23667,24729,25629 | live card read, built-in browser | relay md5 3c5a25c0299323115b9c5c1a8b600029')
  RETURNING id INTO v_lid1;

  -- step 2: price (same guard as the batch files: card URL = latest Michelin star/Bib card URL of the venue)
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE x.new_url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\.michelin\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'card URL is not the latest award URL after step 1: %', v_bad; END IF;

  UPDATE price p
     SET tier = x.tier::smallint, symbol_raw = x.symbol_raw, currency = x.currency, source = 'guide_ingest',
         method = 'published_symbol', publisher = 'michelin', source_url = x.new_url,
         captured_at = x.captured_at::timestamptz, confidence = NULL
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
   WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'price rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', n_exp,
          'price-card:price-michelin-card-p2-held-moved-2026-10-30 | block A step 2 held pass (9 held P2 venues, card at a new path): legacy price rows with no URL, card at a new path | '
          || n_exp || ' rows updated from legacy (EUR 8, JPY 1) | live card read, built-in browser | relay md5 3c5a25c0299323115b9c5c1a8b600029')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7582 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> 151 OR v_lid2 <> 152 THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118374) <> 2 * n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(award_id bigint) ON x.award_id::text = a.row_pk
       WHERE a.id > 118374 AND a.table_name = 'awards' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 118374 AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit price UPDATE rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
          ON a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_url = x.new_url AND a.category = x.category) <> n_exp
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, captured_at text, category text)
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.new_url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> n_exp
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
END
$do$;
COMMIT;
