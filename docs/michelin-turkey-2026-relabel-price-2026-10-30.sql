-- michelin-turkey-2026-relabel-price-2026-10-30.sql
-- Block A, Turkey: 2026 edition relabel (rule 2.1.7) and Michelin card price for the held Turkey venues.
-- Edition: The MICHELIN Guide Turkiye 2026 selection, published Dec 4, 2025:
-- https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-michelin-guide-turkiye-reveals-its-2026-restaurant-selection
-- Population: all 55 Turkey Michelin award rows (55 venues, 1 row each), all labelled 2025, all source_url NULL, loaded
-- Aug 14, 2026. The rows hold 2026 content (Vino Locale Two Stars, Revithia, Araf, Mezra Yalikavak, Cappadocia venues).
-- Live list read Oct 30, 2026 (guide.michelin.com/us/en/selection/turkey/restaurants, 4 pages, 159 cards; star/Bib 54:
-- Two Stars 2, One Star 15, Bib 37). Each of the 54 cards read (status 200, no redirect, symbol TRY, country tr).
-- Paired 53 (name + distinction; 50 by loose key, 3 by name subset, 1 by spelling: Tersane Istanbul = Tershane, the
-- only Istanbul Bib card left, venue site uses both spellings, address Tersane Cd. No:24).
-- Ben's decisions (Oct 30, 13:57 ET, "A" for all): D1 relabel the 53; D2 hold Efendy Istanbul and Lucien Arkas Baglari;
-- D3 Sankai by Nagaya relabelled, venue status closed not changed, no price; D4 hold LA Mahzen; D5 16 price INSERT.
-- Step 1: 53 UPDATE of awards: year 2025 -> 2026, source_url NULL -> card URL. Category and rank do not change.
--         Card distinction equals the award category on every row (guarded). Distinctions: 1 star 15, 2 star 2, bib 36.
-- Step 2: 16 INSERT into price (active venues with no price row): source guide_ingest, method published_symbol,
--         publisher michelin, source_url = card URL, symbol_raw = card symbol, currency TRY, tier = symbol count,
--         confidence NULL, captured_at = read time. Tiers: 1 = 3, 2 = 8, 4 = 5. Legacy price rows are not changed.
-- Relay sha256 9ffe52567c572c77af040d2159bcb6894b3dcba2e48148f47187accd0afd5378 (inside this file).
-- Guards: counts before (price 7698, ledger max 154, audit max 118625); relay md5 ee517b3dd883960b3cd1e7b8aed45098;
-- venue id md5 ab08772d1eb2a587f763439ca8b902db; old Michelin award rows md5 7aaa9cf330c06e606fbd94fd94d3f58c; venues in Turkey; no 2026 Michelin row on any relay
-- venue; card URLs not in use; price flag = (active and no price row).
-- Post-checks: price count 7714; ledgers 155 (award) and 156 (price);
-- audit 118626 to 118694: 53 awards UPDATE + 16 price INSERT, nothing else; rows match the relay;
-- Turkey Michelin rows after: 2026 = 53, 2025 = 2 (Efendy Istanbul, Lucien Arkas Baglari).
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_027c7055e4|10664|us/en/istanbul-province/istanbul/restaurant/foxy-nisantas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:57.543Z|0
ve_0b63b424aa|11334|us/en/nevsehir/urgup_2827493/restaurant/babayan-evi-restaurant|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:26.779Z|1
ve_0bed98d6f5|10682|us/en/izmir/izmir_2809416/restaurant/asl%C4%B1nda-meyhane|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:13.511Z|0
ve_0d51fc7213|9221|us/en/izmir/izmir_2809416/restaurant/asma%C2%A0yaprag%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:00.184Z|0
ve_0e1a18ca2d|11263|us/en/mugla/fethiye_2806867/restaurant/mezegi|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:33.366Z|1
ve_1368ed47bc|10683|us/en/izmir/izmir_2809416/restaurant/aysa-bosnak-borekcisi|₺|CAT_P01|bib|tr|2026-10-30T17:59:43.159Z|0
ve_136db1bad1|5646|us/en/istanbul-province/istanbul/restaurant/nicole|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:36.527Z|0
ve_18edcac317|11262|us/en/mugla/bodrum_2806351/restaurant/mandalya|₺|CAT_P01|bib|tr|2026-10-30T18:00:34.672Z|1
ve_1a1bbea864|10669|us/en/istanbul-province/istanbul/restaurant/pandeli|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:25.946Z|0
ve_1cb00fa293|11261|us/en/mugla/bodrum_2806351/restaurant/bagaras%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:58.868Z|1
ve_349b73a7ad|10681|us/en/izmir/izmir_2809416/restaurant/adil-muftuoglu|₺|CAT_P01|bib|tr|2026-10-30T18:00:01.515Z|0
ve_35e19380c8|5638|us/en/istanbul-province/istanbul/restaurant/mikla|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:33.840Z|0
ve_36abe24a4c|5634|us/en/istanbul-province/istanbul/restaurant/araka|₺₺₺|CAT_P03|1 star|tr|2026-10-30T17:59:29.844Z|0
ve_37474fb40a|10672|us/en/istanbul-province/istanbul/restaurant/tatbak|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:40.475Z|0
ve_3858b8c38e|10687|us/en/izmir/izmir_2809416/restaurant/partal-kardesler-bal%C4%B1k-restorant|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:32.065Z|1
ve_385a5536af|11437|us/en/nigde/nigde-merkez_2821454/restaurant/tabal-gastronomi-evi|₺|CAT_P01|bib|tr|2026-10-30T18:00:35.995Z|0
ve_3aba3f840e|10685|us/en/izmir/izmir_2809416/restaurant/kemal-in-yeri-mulkiyeliler-birligi|₺|CAT_P01|bib|tr|2026-10-30T18:00:30.757Z|1
ve_3c28ea50a0|9541|us/en/mugla/bodrum_2806351/restaurant/otantik-ocakbas%C4%B1|₺|CAT_P01|bib|tr|2026-10-30T17:59:45.794Z|0
ve_400c27e18a|10662|us/en/istanbul-province/istanbul/restaurant/cuma|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:31.180Z|0
ve_420e6f5990|10688|us/en/izmir/izmir_2809416/restaurant/tavac%C4%B1-recep-usta|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:41.799Z|0
ve_465ee2066b|10674|us/en/istanbul-province/istanbul/restaurant/tershane|₺|CAT_P01|bib|tr|2026-10-30T17:59:28.518Z|0
ve_467cda6952|5641|us/en/istanbul-province/istanbul/restaurant/neolokal|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:35.191Z|0
ve_5410da4251|9152|us/en/istanbul-province/istanbul/restaurant/casa-lavanda|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:39.120Z|1
ve_5628da600d|8782|us/en/izmir/izmir_2809416/restaurant/nar%C4%B1mor|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T18:00:05.497Z|1
ve_5ed9e3ba91|10671|us/en/istanbul-province/istanbul/restaurant/sade-bes-denizler-mutfag%C4%B1|₺|CAT_P01|bib|tr|2026-10-30T17:59:27.272Z|0
ve_639a9f06bc|10666|us/en/istanbul-province/istanbul/restaurant/mahir-lokantas%C4%B1|₺|CAT_P01|bib|tr|2026-10-30T18:00:24.122Z|0
ve_6734eae626|11336|us/en/nevsehir/urgup_2827493/restaurant/old-greek-house|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:28.096Z|1
ve_68b10737c1|4232|us/en/mugla/bodrum_2806351/restaurant/macak%C4%B1z%C4%B1|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:48.440Z|1
ve_6946477934|5635|us/en/istanbul-province/istanbul/restaurant/arkestra|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:56.204Z|0
ve_6ad5ac3d8e|10668|us/en/istanbul-province/istanbul/restaurant/nazende-cadde|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:08.205Z|0
ve_6b845b4191|10659|us/en/istanbul-province/istanbul/restaurant/ahmet-ustam-ocakbas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:17.503Z|0
ve_85cac1bf09|8787|us/en/izmir/izmir_2809416/restaurant/teruar-urla|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:47.109Z|1
ve_90cec22abd|10684|us/en/izmir/izmir_2809416/restaurant/begendik-abi|₺|CAT_P01|bib|tr|2026-10-30T18:00:02.855Z|0
ve_9821c9bb73|9540|us/en/mugla/bodrum_2806351/restaurant/beynel|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:21.487Z|0
ve_9852cbf26e|2131|us/en/istanbul-province/istanbul/restaurant/turk-fatih-tutak|₺₺₺₺|CAT_P04|2 star|tr|2026-10-30T17:59:37.873Z|0
ve_9b55bcbafd|10673|us/en/istanbul-province/istanbul/restaurant/tavac%C4%B1-recep-usta-bostanc%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:52.349Z|0
ve_a2b0e7bf15|10665|us/en/istanbul-province/istanbul/restaurant/karakoy-lokantas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T17:59:32.506Z|0
ve_a59287b6fe|10661|us/en/istanbul-province/istanbul/restaurant/casius-antioch-kitchen|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:25.449Z|1
ve_a731e2441c|3451|us/en/izmir/izmir_2809416/restaurant/vino-locale|₺₺₺₺|CAT_P04|2 star|tr|2026-10-30T17:59:51.016Z|1
ve_aab61fc860|10675|us/en/istanbul-province/istanbul/restaurant/yanyal%C4%B1-fehmi-lokantas%C4%B1|₺|CAT_P01|bib|tr|2026-10-30T18:00:16.165Z|0
ve_abf8e67998|10667|us/en/istanbul-province/istanbul/restaurant/mutfakkoz|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:10.878Z|0
ve_b4ab5979c5|9539|us/en/mugla/bodrum_2806351/restaurant/arka-ristorante-pizzeria|₺|CAT_P01|bib|tr|2026-10-30T18:00:18.840Z|1
ve_bda466a347|11335|us/en/nevsehir/nevsehir-merkez_2821449/restaurant/happena|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:29.431Z|0
ve_c42df0ddef|5633|us/en/istanbul-province/istanbul/restaurant/araf-istanbul|₺₺|CAT_P02|1 star|tr|2026-10-30T18:00:04.182Z|1
ve_c98ccae6d0|4427|us/en/nevsehir/urgup_2827493/restaurant/revithia|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T18:00:12.194Z|0
ve_d6b1548b2d|11195|us/en/mugla/milas_2807963/restaurant/agora-pansiyon|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:22.800Z|0
ve_de05509e50|9094|us/en/mugla/bodrum_2806351/restaurant/mezra-yal%C4%B1kavak|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T18:00:09.535Z|0
ve_e2939f7812|13037|us/en/nevsehir/urgup_2827493/restaurant/aravan-evi|₺|CAT_P01|bib|tr|2026-10-30T18:00:14.833Z|0
ve_e611b7d736|10670|us/en/istanbul-province/istanbul/restaurant/parvus-kalam%C4%B1s|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:20.168Z|0
ve_efa4c69e8f|8783|us/en/izmir/izmir_2809416/restaurant/od-urla|₺₺₺|CAT_P03|1 star|tr|2026-10-30T17:59:44.472Z|0
ve_f088b7a06a|5648|us/en/istanbul-province/istanbul/restaurant/sankai-by-nagaya|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:54.848Z|0
ve_f1b7fc23a0|4231|us/en/mugla/bodrum_2806351/restaurant/kitchen-1208228|₺₺₺₺|CAT_P04|1 star|tr|2026-10-30T17:59:49.768Z|0
ve_f9cfd37334|10660|us/en/istanbul-province/istanbul/restaurant/ali-ocakbas%C4%B1|₺₺|CAT_P02|bib|tr|2026-10-30T18:00:06.837Z|1$r$;
  rel jsonb;
  n_exp int := 53;
  np_exp int := 16;
  v_txt text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7698 THEN RAISE EXCEPTION 'price count before is not 7698'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 154 THEN RAISE EXCEPTION 'ledger max before is not 154'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118625 THEN RAISE EXCEPTION 'audit max before is not 118625'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '9ffe52567c572c77af040d2159bcb6894b3dcba2e48148f47187accd0afd5378' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF md5(rel_txt) <> 'ee517b3dd883960b3cd1e7b8aed45098' THEN RAISE EXCEPTION 'relay md5'; END IF;
  -- relay line: venue_id|award_id|card path|symbol|CAT_P0n|distinction|country|read time|P
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'award_id', f[2]::bigint, 'url', 'https://guide.michelin.com/' || f[3],
           'symbol_raw', f[4], 'cat', f[5], 'category', CASE f[6] WHEN 'bib' THEN 'Bib Gourmand' WHEN '1 star' THEN 'One Star' WHEN '2 star' THEN 'Two Stars' WHEN '3 star' THEN 'Three Stars' END, 'cc', f[7],
           'captured_at', f[8], 'p', f[9]::int) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 9 OR f[5] <> 'CAT_P0' || char_length(f[4])
                            OR char_length(f[4]) NOT BETWEEN 1 AND 4 OR f[4] <> repeat('₺', char_length(f[4]))
                            OR f[7] <> 'tr' OR f[9] NOT IN ('0', '1') OR f[3] !~ '^us/en/.+/restaurant/')
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int) WHERE x.p = 1) <> np_exp THEN RAISE EXCEPTION 'price flags'; END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int) WHERE x.category IS NULL) THEN RAISE EXCEPTION 'distinction'; END IF;
  SELECT md5(string_agg(x.venue_id, E'\n' ORDER BY x.venue_id COLLATE "C")) INTO v_txt FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int);
  IF v_txt <> 'ab08772d1eb2a587f763439ca8b902db' THEN RAISE EXCEPTION 'venue id md5 %', v_txt; END IF;

  -- old rows, as read before the build (all Michelin rows of the relay venues)
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_txt
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_txt IS DISTINCT FROM '7aaa9cf330c06e606fbd94fd94d3f58c' THEN RAISE EXCEPTION 'old award rows md5 %', v_txt; END IF;

  -- each row: venue in Turkey; exactly one Michelin row = award_id, 2025, source_url NULL, category = card;
  -- price flag 1 = active and no price row; price flag 0 = has a price row or not active
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int)
   WHERE NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id = v.city_id WHERE v.id = x.venue_id AND c.country_iso = 'TR')
      OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin') <> 1
      OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_id = 'michelin'
                        AND a.year = 2025 AND a.source_url IS NULL AND a.category = x.category)
      OR (x.p = 1) IS DISTINCT FROM (EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
                                     AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id));
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows changed since the read: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(url text) ON a.source_url = x.url)
    THEN RAISE EXCEPTION 'a card URL is already in use'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS x(url text) ON p.source_url = x.url)
    THEN RAISE EXCEPTION 'a card URL is already in use on a price row'; END IF;

  -- step 1: relabel to the 2026 edition and add the card URL
  UPDATE awards a SET year = 2026, source_url = x.url
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int)
   WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_id = 'michelin' AND a.year = 2025
     AND a.source_url IS NULL AND a.category = x.category;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', n_exp,
          'relabel:michelin-turkey-2026-relabel-price-2026-10-30 | rule 2.1.7: Turkey Michelin rows hold the 2026 selection (published Dec 4, 2025); year 2025 -> '
          || '2026, source_url NULL -> card URL, category unchanged | Ben D1-D5 "A" Oct 30 13:57 ET | held: Efendy Istanbul, '
          || 'Lucien Arkas Baglari (not on current list), LA Mahzen (not in db) | live list + card read, built-in browser '
          || '| relay md5 ee517b3dd883960b3cd1e7b8aed45098')
  RETURNING id INTO v_lid1;

  -- step 2: price for active venues with no price row
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, char_length(x.symbol_raw)::smallint, x.symbol_raw, 'TRY', 'guide_ingest', 'published_symbol', 'michelin',
         x.url, x.captured_at::timestamptz, NULL
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int)
   WHERE x.p = 1;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> np_exp THEN RAISE EXCEPTION 'price rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', np_exp,
          'price-card:michelin-turkey-2026-relabel-price-2026-10-30 | block A, held Turkey venues: no price row, card URL from the 2026 relabel | '
          || np_exp || ' rows inserted (TRY 16; tiers 1 = 3, 2 = 8, 4 = 5) | live card read, built-in browser | relay md5 ee517b3dd883960b3cd1e7b8aed45098')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7714 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> 155 OR v_lid2 <> 156 THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118625) <> n_exp + np_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int) ON a.row_pk = x.award_id::text
       WHERE a.id > 118625 AND a.table_name = 'awards' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int) ON a.row_pk = x.venue_id
       WHERE a.id > 118625 AND a.table_name = 'price' AND a.action = 'INSERT' AND x.p = 1) <> np_exp
    THEN RAISE EXCEPTION 'audit price INSERT rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int)
          ON a.id = x.award_id AND a.year = 2026 AND a.source_url = x.url AND a.category = x.category) <> n_exp
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, captured_at text, p int)
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.url = p.source_url AND p.currency = 'TRY'
         AND p.tier = char_length(x.symbol_raw) AND x.captured_at::timestamptz = p.captured_at
       WHERE x.p = 1 AND p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> np_exp
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
  IF (SELECT count(*) FILTER (WHERE a.year = 2026) * 1000 + count(*) FILTER (WHERE a.year = 2025)
        FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
       WHERE a.source_id = 'michelin' AND c.country_iso = 'TR') <> n_exp * 1000 + 2
    THEN RAISE EXCEPTION 'Turkey Michelin rows by year after'; END IF;
END
$do$;
COMMIT;
