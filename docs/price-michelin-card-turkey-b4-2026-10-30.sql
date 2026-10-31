-- price-michelin-card-turkey-b4-2026-10-30.sql
-- Block A, step 2, open items block 4 (Turkey, 36 venues).
-- Population P2: active venues with a Michelin One Star, Two Stars, Three Stars or Bib Gourmand row whose source_url is
-- a guide.michelin.com card URL (latest by year desc, id desc), and a price row with source legacy_guide and no source_url.
-- Source: the live Michelin card page (Price: line, data-sheet), read in the built-in browser.
-- Rows: 36 UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
-- source_url = card URL, symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
-- captured_at = read time). Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026).
-- Cards that show Selected only are also updated; award rows do not change (Ben, Oct 30, 2026; Oct 10 ruling).
-- Currencies: TRY 36. Card tiers: 1 = 10, 2 = 16, 3 = 2, 4 = 8. Card distinction: 1 star 9, 2 star 1, bib 26.
-- Relay sha256 57c835b7a261f8c486e4279982ae44fc58951987b61e9bdb3e9849e7b83c7f49 (inside this file).
-- Guards: counts before (price 7731, ledger max 171, audit max 119076); relay fingerprint md5
-- 321054c9b7e58b1ccf3ef62edaab7f79; venue id md5 10358d7db30c4a7d0dcb325eec41ce78; old price rows md5 9fb45d053370043e81752bab7ac598a4;
-- each row in P2 now with the same card URL.
-- Post-checks: price count 7731 (unchanged); ledger 172; audit 36 price UPDATE rows, nothing else;
-- each price row now matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_027c7055e4|us/en/istanbul-province/istanbul/restaurant/foxy-nisantas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:39.155Z
ve_0bed98d6f5|us/en/izmir/izmir_2809416/restaurant/asl%C4%B1nda-meyhane|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:40.493Z
ve_0d51fc7213|us/en/izmir/izmir_2809416/restaurant/asma%C2%A0yaprag%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:41.846Z
ve_1368ed47bc|us/en/izmir/izmir_2809416/restaurant/aysa-bosnak-borekcisi|₺|CAT_P01|bib|tr|2026-10-31T03:44:43.183Z
ve_136db1bad1|us/en/istanbul-province/istanbul/restaurant/nicole|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:44:44.545Z
ve_1a1bbea864|us/en/istanbul-province/istanbul/restaurant/pandeli|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:45.950Z
ve_349b73a7ad|us/en/izmir/izmir_2809416/restaurant/adil-muftuoglu|₺|CAT_P01|bib|tr|2026-10-31T03:44:47.289Z
ve_35e19380c8|us/en/istanbul-province/istanbul/restaurant/mikla|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:44:48.693Z
ve_36abe24a4c|us/en/istanbul-province/istanbul/restaurant/araka|₺₺₺|CAT_P03|1 star|tr|2026-10-31T03:44:50.137Z
ve_37474fb40a|us/en/istanbul-province/istanbul/restaurant/tatbak|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:51.408Z
ve_385a5536af|us/en/nigde/nigde-merkez_2821454/restaurant/tabal-gastronomi-evi|₺|CAT_P01|bib|tr|2026-10-31T03:44:52.762Z
ve_3c28ea50a0|us/en/mugla/bodrum_2806351/restaurant/otantik-ocakbas%C4%B1|₺|CAT_P01|bib|tr|2026-10-31T03:44:54.120Z
ve_400c27e18a|us/en/istanbul-province/istanbul/restaurant/cuma|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:55.485Z
ve_420e6f5990|us/en/izmir/izmir_2809416/restaurant/tavac%C4%B1-recep-usta|₺₺|CAT_P02|bib|tr|2026-10-31T03:44:56.805Z
ve_465ee2066b|us/en/istanbul-province/istanbul/restaurant/tershane|₺|CAT_P01|bib|tr|2026-10-31T03:44:58.162Z
ve_467cda6952|us/en/istanbul-province/istanbul/restaurant/neolokal|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:44:59.578Z
ve_5ed9e3ba91|us/en/istanbul-province/istanbul/restaurant/sade-bes-denizler-mutfag%C4%B1|₺|CAT_P01|bib|tr|2026-10-31T03:45:00.931Z
ve_639a9f06bc|us/en/istanbul-province/istanbul/restaurant/mahir-lokantas%C4%B1|₺|CAT_P01|bib|tr|2026-10-31T03:45:02.312Z
ve_6946477934|us/en/istanbul-province/istanbul/restaurant/arkestra|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:45:03.669Z
ve_6ad5ac3d8e|us/en/istanbul-province/istanbul/restaurant/nazende-cadde|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:05.033Z
ve_6b845b4191|us/en/istanbul-province/istanbul/restaurant/ahmet-ustam-ocakbas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:06.396Z
ve_90cec22abd|us/en/izmir/izmir_2809416/restaurant/begendik-abi|₺|CAT_P01|bib|tr|2026-10-31T03:45:07.739Z
ve_9821c9bb73|us/en/mugla/bodrum_2806351/restaurant/beynel|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:09.114Z
ve_9852cbf26e|us/en/istanbul-province/istanbul/restaurant/turk-fatih-tutak|₺₺₺₺|CAT_P04|2 star|tr|2026-10-31T03:45:10.471Z
ve_9b55bcbafd|us/en/istanbul-province/istanbul/restaurant/tavac%C4%B1-recep-usta-bostanc%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:11.805Z
ve_a2b0e7bf15|us/en/istanbul-province/istanbul/restaurant/karakoy-lokantas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:13.207Z
ve_aab61fc860|us/en/istanbul-province/istanbul/restaurant/yanyal%C4%B1-fehmi-lokantas%C4%B1|₺|CAT_P01|bib|tr|2026-10-31T03:45:14.546Z
ve_abf8e67998|us/en/istanbul-province/istanbul/restaurant/mutfakkoz|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:15.951Z
ve_bda466a347|us/en/nevsehir/nevsehir-merkez_2821449/restaurant/happena|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:17.297Z
ve_c98ccae6d0|us/en/nevsehir/urgup_2827493/restaurant/revithia|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:45:18.630Z
ve_d6b1548b2d|us/en/mugla/milas_2807963/restaurant/agora-pansiyon|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:20.021Z
ve_de05509e50|us/en/mugla/bodrum_2806351/restaurant/mezra-yal%C4%B1kavak|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:45:21.389Z
ve_e2939f7812|us/en/nevsehir/urgup_2827493/restaurant/aravan-evi|₺|CAT_P01|bib|tr|2026-10-31T03:45:22.741Z
ve_e611b7d736|us/en/istanbul-province/istanbul/restaurant/parvus-kalam%C4%B1s|₺₺|CAT_P02|bib|tr|2026-10-31T03:45:24.065Z
ve_efa4c69e8f|us/en/izmir/izmir_2809416/restaurant/od-urla|₺₺₺|CAT_P03|1 star|tr|2026-10-31T03:45:25.412Z
ve_f1b7fc23a0|us/en/mugla/bodrum_2806351/restaurant/kitchen-1208228|₺₺₺₺|CAT_P04|1 star|tr|2026-10-31T03:45:26.837Z$r$;
  rel jsonb;
  n_exp int := 36;
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7731 THEN RAISE EXCEPTION 'price count before is not 7731'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 171 THEN RAISE EXCEPTION 'ledger max before is not 171'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119076 THEN RAISE EXCEPTION 'audit max before is not 119076'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '57c835b7a261f8c486e4279982ae44fc58951987b61e9bdb3e9849e7b83c7f49' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  -- relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'source_url', 'https://guide.michelin.com/' || f[2], 'symbol_raw', f[3],
           'currency', CASE f[6] WHEN 'us' THEN 'USD' WHEN 'cn' THEN 'CNY' WHEN 'tw' THEN 'TWD' WHEN 'jp' THEN 'JPY' WHEN 'kr' THEN 'KRW' WHEN 'gb' THEN 'GBP' WHEN 'fr' THEN 'EUR' WHEN 'de' THEN 'EUR' WHEN 'it' THEN 'EUR' WHEN 'nl' THEN 'EUR' WHEN 'es' THEN 'EUR' WHEN 'be' THEN 'EUR' WHEN 'mc' THEN 'EUR' WHEN 'ie' THEN 'EUR' WHEN 'lu' THEN 'EUR' WHEN 'ad' THEN 'EUR' WHEN 'tr' THEN 'TRY' END,
           'tier', char_length(f[3]), 'captured_at', f[7]) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 7 OR f[4] <> 'CAT_P0' || char_length(f[3])
                            OR char_length(f[3]) NOT BETWEEN 1 AND 4
                            OR f[3] <> repeat(left(f[3], 1), char_length(f[3])))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(symbol_raw text, currency text)
              WHERE x.currency IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'TWD' THEN '$' WHEN 'CNY' THEN '¥'
                                              WHEN 'JPY' THEN '¥' WHEN 'KRW' THEN '₩' WHEN 'GBP' THEN '£' WHEN 'EUR' THEN '€' WHEN 'TRY' THEN '₺' END)
    THEN RAISE EXCEPTION 'symbol does not match currency'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.source_url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier||'|'||x.captured_at,
                        E'\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text);
  IF v_fp <> '321054c9b7e58b1ccf3ef62edaab7f79' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '10358d7db30c4a7d0dcb325eec41ce78' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows: the legacy price rows of the relay venues, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '9fb45d053370043e81752bab7ac598a4' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;

  -- each row: venue active; legacy price row with no URL; card URL = latest Michelin star/Bib card URL of the venue
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL)
      OR x.source_url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\.michelin\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows outside P2 or URL changed: %', v_bad; END IF;

  UPDATE price p
     SET tier = x.tier::smallint, symbol_raw = x.symbol_raw, currency = x.currency, source = 'guide_ingest',
         method = 'published_symbol', publisher = 'michelin', source_url = x.source_url,
         captured_at = x.captured_at::timestamptz, confidence = NULL
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text)
   WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', n_exp,
          'price-card:price-michelin-card-turkey-b4-2026-10-30 | block A step 2 open items block 4 (Turkey, 36 venues): legacy price rows with no URL, active Michelin star/Bib venues with a card URL | '
          || n_exp || ' rows updated from legacy (TRY 36) | live card read, built-in browser | relay md5 321054c9b7e58b1ccf3ef62edaab7f79')
  RETURNING id INTO v_lid;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7731 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid <> 172 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119076) <> n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 119076 AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit price UPDATE rows'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text)
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.source_url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> n_exp
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
END
$do$;
COMMIT;
