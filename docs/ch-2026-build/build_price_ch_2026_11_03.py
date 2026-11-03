#!/usr/bin/env python3
"""Build docs/price-michelin-card-switzerland-2026.sql from the HK/MO price file (same gates, same writes).
Swiss open item: decision 4 (Ben Nov 2 18:09 ET "4A"): printed symbols, currency CHF on all 225 rows, Torkel $$$ included.
Precedent (Ben Nov 1 12:28 ET "1A, 2A, 3A"): source = ingest batch symbol, captured_at = batch created_at, INSERT venues with no row.
Values read Nov 3 2026 about 21:35 UTC, whole tables."""
t=open('docs/price-michelin-card-hong-kong-macau-2026.sql',encoding='utf-8').read()
b=t[t.index('BEGIN;\n'):]
R=[("CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur","'CHF'::text AS cur"),
("r.batch_id = 19","r.batch_id = 20"),("t_b19","t_b20"),("batch 19","batch 20"),
("id = 19 AND batch_key = 'michelin-2026-hong-kong-macau'","id = 20 AND batch_key = 'michelin-2026-switzerland'"),
("11300::bigint, 23368::bigint, 13001::bigint, 7727::bigint, 2554::bigint,","11323::bigint, 25321::bigint, 13144::bigint, 7727::bigint, 2373::bigint,"),
("206::bigint, 121394::bigint","244::bigint, 125340::bigint"),
("'2026-11-01 15:36:21.487926+00'::timestamptz","'2026-11-02 23:34:19.10987+00'::timestamptz"),
("n_plan <> 180 OR n_dist <> 180 OR n_has <> 174","n_plan <> 225 OR n_dist <> 225 OR n_has <> 191"),
("0525e524d5b56b1bf77caa6e9f3c7649","88b231838dc59fadf1614b4fe61e1072"),("0f4b0bf3cbcb77c7bfe4a228c36d4726","ed4945a679c844cdca8181c04f0a2423"),
("8e5d0ad861aada04db406cd1d88c512d","6701d521c54c32b70d9376095fb8f4d0"),("b8755c53352a292a6cebb360c009ad6e","b6345e68cba18fcae310923ac157bd61"),
("p.sym !~ '^[$]{1,4}$'","p.sym !~ '^([$]{1,4}|€{1,4})$'"),
("symbol is 1-4 \"$\"","symbol is 1-4 of $ or €"),("as read on Nov 1, 2026","as read on Nov 3, 2026"),
("UPDATE the 174 legacy","UPDATE the 191 legacy"),("n_upd <> 174","n_upd <> 191"),("expected 174","expected 191"),
("for the 6 venues","for the 34 venues"),("n_ins <> 6","n_ins <> 34"),("rows, expected 6","rows, expected 34"),
("VALUES ('michelin', 'price', 180,","VALUES ('michelin', 'price', 225,"),
("'price-card:price-michelin-card-hong-kong-macau-2026 | open item 1 (handoff-hkmo-native-done-2026-11-01): Hong Kong and Macau price from the 2026 card | '","'price-card:price-michelin-card-switzerland-2026 | Swiss decision 4 (Ben Nov 2 18:09 ET 4A), go Nov 3: Switzerland and Liechtenstein price from the 2026 card | '"),
("'174 updated from legacy, 6 inserted (HKD 146, MOP 34) | source ingest_rows batch 20 price_symbol_raw '","'191 updated from legacy, 34 inserted (CHF 225, symbols as printed) | source ingest_rows batch 20 price_symbol_raw '"),
("'(Cowork capture Nov 1, 2026) | plan md5","'(Cowork capture Nov 2, 2026) | plan md5"),
("v_lid <> 207","v_lid <> 245"),("expected 207","expected 245"),
("(11300::bigint, 23368::bigint, 13001::bigint, 7733::bigint, 2380::bigint)","(11323::bigint, 25321::bigint, 13144::bigint, 7761::bigint, 2182::bigint)"),
("expected 11300/23368/13001/7733/2380","expected 11323/25321/13144/7761/2182"),
("exactly 180 new audit rows, all on price (174 UPDATE, 6 INSERT)","exactly 225 new audit rows, all on price (191 UPDATE, 34 INSERT)"),
("n_audit <> 180","n_audit <> 225"),("(expected 180)","(expected 225)"),("action = 'UPDATE') <> 174","action = 'UPDATE') <> 191"),("action = 'INSERT') <> 6","action = 'INSERT') <> 34"),
]
for a,c in R:
    assert a in b,a; b=b.replace(a,c)
b=b[:b.index('-- Read-back')].rstrip()+'\n'
for bad in ['Hong Kong','HKD','MOP','hong-kong','11300','23368','7733','121394','Nov 1']:
    assert bad not in b,bad
import re; print('left',re.findall(r'.*\b(180|174)\b.*',b))
h="""-- price-michelin-card-switzerland-2026.sql
-- Purpose: Switzerland and Liechtenstein price from the 2026 Michelin card (Swiss open item, decision 4).
-- Rule: the Michelin card price wins over a legacy price with no URL (Ben Sep 28, Oct 30, 2026).
-- Population: 225 cards in ingest_rows batch 20 = 225 venues (Switzerland 224, Liechtenstein 1), all active.
-- Rows: 191 UPDATE of the legacy row, 34 INSERT. Same tier 186, tier change 5: Birdy's by Achtien $$$$ -> €€, Tosca $$$$ -> €€€,
--   Wöschi $$$ -> €€€€, Gasthaus Löwen $$$$ -> €€€, L'Atelier Robuchon $$$ -> €€€€.
-- Values: symbol as printed, currency CHF on all 225 (Ben 4A), Torkel $$$ included. tier = symbol count. source guide_ingest,
--   method published_symbol, publisher michelin, source_url = card URL, confidence NULL, captured_at = batch 20 created_at.
-- Expected after: price 7,761 (legacy_guide 2,182), ledger 245, audit +225 (to 125,565).
-- Built by docs/ch-2026-build/build_price_ch_2026_11_03.py from docs/price-michelin-card-hong-kong-macau-2026.sql.

"""
open('docs/price-michelin-card-switzerland-2026.sql','w',encoding='utf-8',newline='\n').write(h+b)
