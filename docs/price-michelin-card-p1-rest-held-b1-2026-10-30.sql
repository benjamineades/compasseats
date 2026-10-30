-- price-michelin-card-p1-rest-held-b1-2026-10-30.sql
-- Held P1-rest venues, batch 1 of 2 (rows only). Ben Oct 30, 2026, 15:11 ET: "go with your recommendations".
-- Groups: 1 Banshee (price only, Selected card, Bib 2023/2024 rows kept as history, ruling Oct 10);
--   2 Zhu Ji Zhi Mian Pu (price from the Sep 4, 2025 archive card, live card 404);
--   3 California Green Stars: Chez Panisse, Chi Spacca, Monte's, Pomet, Sierra Mar. Award One Star -> Green Star.
--     Proof: California 2026 article (Jun 25, 2026) lists 60 One Star venues, none of these 5; California 2025 article lists
--     Chez Panisse, Chi Spacca, Pomet as Green Stars; live cards: no star, greenstar True. Cause: Green Star icon read as a star.
--   4 Heritage, Long Beach: award Two Stars -> One Star (card One Star in the 2026 guide; 2026 article One Star list);
--     INSERT a 2026 Green Star row (card greenstar True).
--   5 Miura (card Beverly Hills, city stays Los Angeles), Paloma Taqueria (URL + price; city move in batch 2);
--   6 Nam Hin (card Phan Thanh Street; name in the name block); 7 four Da Nang/HCMC Bibs paired on core name + city + Bib +
--     only card; 8 Most Tumski = card "Most" (tasting room in Restauracja Miedzy Mostami, Ksiecia Witolda 1).
-- Ops: green 5, heritage 1, price 2, url 8. Award UPDATE 14, award INSERT 1, price INSERT 16.
-- Price: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL (Zhu Ji: archive URL),
--   symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL, captured_at = read time.
--   Currencies: CNY 1, EUR 1, NZD 1, USD 8, VND 5. Tiers: 1 = 6, 2 = 1, 3 = 4, 4 = 5.
-- Relay sha256 e862aba2a4917e97f3f5243f7dd8994aa164b805640bae0a0adeafa6e203941c (inside this file). Relay fingerprint md5 8287e5e201a415790d5657d88c8e6a76.
-- Guards: price 7714, ledger max 157, audit max 118697, awards 23352; old Michelin rows md5
--   e9ba084eb9fa21006d7fbfabe37cdc62; active star/Bib venues with no price 22; no price row on a relay venue; card URLs not in use.
-- Post-checks: price 7730; awards 23353; ledgers 158 (award) and 159 (price); audit 118698 to 118728:
--   14 awards UPDATE + 1 awards INSERT + 16 price INSERT, nothing else; active star/Bib venues with no price 6.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ve_00d8a2d2b6|21049|url|us/en/lower-silesian/wroclaw_2399695/restaurant/most|€€€|CAT_P03|1 star|False|pl|2026-10-30T19:12:44.404Z
ve_1f12403d25|21117|url|us/en/da-nang-region/da-nang_2984390/restaurant/nam-hien-phan-thanh-street|₫|CAT_P01|bib|False|vn|2026-10-30T19:12:45.754Z
ve_24aeca03f9|27766|price|https://web.archive.org/web/20250904212434id_/https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurant/zhu-ji-zhi-mian-pu|¥|CAT_P01|bib|False|cn|2026-10-30T19:13:12.805Z
ve_2b87774359|21080|green|us/en/california/oakland/restaurant/pomet|$$$|CAT_P03|plate|True|us|2026-10-30T19:12:47.111Z
ve_355d4a675c|21078|green|us/en/california/santa-barbara/restaurant/monte-s|$$$|CAT_P03|plate|True|us|2026-10-30T19:12:48.468Z
ve_362cf33750|21127|url|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/banh-canh-cua-ba-ba|₫|CAT_P01|bib|False|vn|2026-10-30T19:12:49.819Z
ve_3a998c5225|15350|green|us/en/california/berkeley/restaurant/chez-panisse|$$$$|CAT_P04|plate|True|us|2026-10-30T19:12:51.177Z
ve_3fad690140|21210|url|us/en/south-island/wanaka_2306683/restaurant/paloma-taqueria|$$|CAT_P02|bib|False|nz|2026-10-30T19:12:52.506Z
ve_43771d354f|21073|green|us/en/california/us-los-angeles/restaurant/chi-spacca|$$$$|CAT_P04|plate|True|us|2026-10-30T19:12:53.873Z
ve_466f9b5fe9|-|price|us/en/georgia/atlanta_2884144/restaurant/banshee|$$$|CAT_P03|plate|False|us|2026-10-30T19:12:55.230Z
ve_49fd475e56|17831|green|us/en/california/big-sur/restaurant/sierra-mar|$$$$|CAT_P04|plate|True|us|2026-10-30T19:12:56.574Z
ve_95d87f1674|21072|heritage|us/en/california/long-beach/restaurant/heritage-1196790|$$$$|CAT_P04|1 star|True|us|2026-10-30T19:12:57.922Z
ve_afc5cbe328|21118|url|us/en/da-nang-region/da-nang_2984390/restaurant/ba-vui|₫|CAT_P01|bib|False|vn|2026-10-30T19:12:59.273Z
ve_ca50fd9f2e|21077|url|us/en/california/beverly-hills/restaurant/miura-1246958|$$$$|CAT_P04|1 star|False|us|2026-10-30T19:13:00.633Z
ve_dff956ccb3|21120|url|us/en/da-nang-region/da-nang_2984390/restaurant/le-gia-khang-ngu-hanh-son|₫|CAT_P01|bib|False|vn|2026-10-30T19:13:01.996Z
ve_f21ee3afab|21119|url|us/en/da-nang-region/da-nang_2984390/restaurant/banh-beo-banh-%C4%91ap|₫|CAT_P01|bib|False|vn|2026-10-30T19:13:03.346Z$r$;
  rel jsonb;
  v_fp text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> 7714 THEN RAISE EXCEPTION 'price count before is not 7714'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 157 THEN RAISE EXCEPTION 'ledger max before is not 157'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118697 THEN RAISE EXCEPTION 'audit max before is not 118697'; END IF;
  IF (SELECT count(*) FROM awards) <> 23352 THEN RAISE EXCEPTION 'awards count before is not 23352'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> 'e862aba2a4917e97f3f5243f7dd8994aa164b805640bae0a0adeafa6e203941c' THEN RAISE EXCEPTION 'relay sha256'; END IF;

  -- relay line: venue_id|award_id|op|card|symbol|CAT_P0n|distinction|greenstar|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'award_id', f[2], 'op', f[3],
           'url', CASE WHEN f[4] LIKE 'https://web.archive.org/web/%' THEN f[4] ELSE 'https://guide.michelin.com/' || f[4] END,
           'symbol_raw', f[5], 'currency', CASE f[9] WHEN 'us' THEN 'USD' WHEN 'nz' THEN 'NZD' WHEN 'vn' THEN 'VND' WHEN 'pl' THEN 'EUR' WHEN 'cn' THEN 'CNY' END, 'tier', char_length(f[5]), 'captured_at', f[10],
           'old_cat', CASE f[3] WHEN 'url' THEN CASE f[7] WHEN 'bib' THEN 'Bib Gourmand' WHEN '1 star' THEN 'One Star' WHEN '2 star' THEN 'Two Stars' WHEN '3 star' THEN 'Three Stars' END WHEN 'green' THEN 'One Star'
                                WHEN 'heritage' THEN 'Two Stars' ELSE '' END,
           'new_cat', CASE f[3] WHEN 'url' THEN CASE f[7] WHEN 'bib' THEN 'Bib Gourmand' WHEN '1 star' THEN 'One Star' WHEN '2 star' THEN 'Two Stars' WHEN '3 star' THEN 'Three Stars' END WHEN 'green' THEN 'Green Star'
                                WHEN 'heritage' THEN 'One Star' ELSE '' END) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 10 OR f[6] <> 'CAT_P0' || char_length(f[5])
                            OR f[5] <> repeat(left(f[5], 1), char_length(f[5]))
                            OR (f[3] = 'url' AND (f[8] <> 'False' OR f[7] NOT IN ('bib','1 star','2 star','3 star')))
                            OR (f[3] = 'green' AND (f[7] <> 'plate' OR f[8] <> 'True'))
                            OR (f[3] = 'heritage' AND (f[7] <> '1 star' OR f[8] <> 'True'))
                            OR f[3] NOT IN ('url','green','heritage','price'))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> 16 THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text)
              WHERE x.currency IS NULL OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'NZD' THEN '$'
                                              WHEN 'VND' THEN '₫' WHEN 'EUR' THEN '€' WHEN 'CNY' THEN '¥' END)
    THEN RAISE EXCEPTION 'symbol or currency'; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.award_id||'|'||x.op||'|'||x.url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier
                        ||'|'||x.captured_at||'|'||x.old_cat||'|'||x.new_cat, E'\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text);
  IF v_fp <> '8287e5e201a415790d5657d88c8e6a76' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;

  -- rows as read before the build
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_old
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_old IS DISTINCT FROM 'e9ba084eb9fa21006d7fbfabe37cdc62' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;
  IF (SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id)) <> 22
    THEN RAISE EXCEPTION 'active star/Bib venues with no price before'; END IF;
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id)
      OR (x.op <> 'price' AND NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.venue_id
                                            AND a.source_id = 'michelin' AND a.year = 2026 AND a.source_url IS NULL
                                            AND a.category = x.old_cat));
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows changed since the read: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text) ON a.source_url = x.url
              WHERE x.op <> 'price') THEN RAISE EXCEPTION 'a card URL is already in use'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS x(url text) ON p.source_url = x.url)
    THEN RAISE EXCEPTION 'a URL is already in use on a price row'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text) ON a.venue_id = x.venue_id
              WHERE x.op = 'heritage' AND a.category = 'Green Star') THEN RAISE EXCEPTION 'Green Star row exists'; END IF;

  -- awards: source_url and category
  UPDATE awards a SET source_url = x.url, category = x.new_cat
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text)
   WHERE x.op IN ('url','green','heritage') AND a.id = x.award_id::bigint AND a.venue_id = x.venue_id
     AND a.source_id = 'michelin' AND a.year = 2026 AND a.source_url IS NULL AND a.category = x.old_cat;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> 14 THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT x.venue_id, 'michelin', 2026, NULL, 'Green Star', NULL, x.url
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text) WHERE x.op = 'heritage';
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> 1 THEN RAISE EXCEPTION 'award rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 15,
          'relabel:price-michelin-card-p1-rest-held-b1-2026-10-30 | held P1 rest batch 1: 8 source_url NULL -> card URL; 5 One Star -> Green Star '
          || '(California: 2026 article, 2025 article, cards greenstar True); Heritage Long Beach Two Stars -> One Star + '
          || '2026 Green Star row | Ben Oct 30 15:11 ET | relay md5 8287e5e201a415790d5657d88c8e6a76')
  RETURNING id INTO v_lid1;

  -- price
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, x.tier::smallint, x.symbol_raw, x.currency, 'guide_ingest', 'published_symbol', 'michelin',
         x.url, x.captured_at::timestamptz, NULL
    FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text);
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> 16 THEN RAISE EXCEPTION 'price rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', 16,
          'price-card:price-michelin-card-p1-rest-held-b1-2026-10-30 | held P1 rest batch 1: no price row; live card read (Zhu Ji: archive card Sep 4, 2025) | '
          || '16 rows inserted (CNY 1, EUR 1, NZD 1, USD 8, VND 5) | built-in browser | relay md5 8287e5e201a415790d5657d88c8e6a76')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'price count after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23353 THEN RAISE EXCEPTION 'awards count after'; END IF;
  IF v_lid1 <> 158 OR v_lid2 <> 159 THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118697) <> 31 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text) ON a.row_pk = x.award_id
       WHERE a.id > 118697 AND a.table_name = 'awards' AND a.action = 'UPDATE') <> 14
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a WHERE a.id > 118697 AND a.table_name = 'awards' AND a.action = 'INSERT'
         AND a.new_row->>'venue_id' IN (SELECT x.venue_id FROM jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text) WHERE x.op = 'heritage')
         AND a.new_row->>'category' = 'Green Star') <> 1
    THEN RAISE EXCEPTION 'audit awards INSERT rows'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > 118697 AND a.table_name = 'price' AND a.action = 'INSERT') <> 16
    THEN RAISE EXCEPTION 'audit price INSERT rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text)
          ON a.id = x.award_id::bigint AND a.venue_id = x.venue_id AND a.source_url = x.url AND a.category = x.new_cat
         AND a.year = 2026 WHERE x.op <> 'price') <> 14
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text)
          ON a.venue_id = x.venue_id AND a.source_url = x.url AND a.category = 'Green Star' AND a.year = 2026
       WHERE x.op = 'heritage') <> 1
    THEN RAISE EXCEPTION 'Green Star row after'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, captured_at text, old_cat text, new_cat text)
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> 16
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''), E'\n' ORDER BY a.id))
        FROM awards a WHERE a.venue_id = 've_466f9b5fe9') <> md5('21098|2023|Bib Gourmand|' || E'\n' || '21099|2024|Bib Gourmand|')
    THEN RAISE EXCEPTION 'Banshee award rows changed'; END IF;
  IF (SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id)) <> 6
    THEN RAISE EXCEPTION 'active star/Bib venues with no price after'; END IF;
END
$do$;
COMMIT;
