#!/usr/bin/env python3
"""Build the gated file for the Turkey 2026 relabel (rule 2.1.7) and the Turkey card price (block A, held Turkey 16).

Ben's decisions (Oct 30, 2026, 13:57 ET, "A" for all):
  D1 a: the 53 Turkey Michelin rows that match a current 2026 card: year 2025 -> 2026, source_url NULL -> card URL.
  D2 a: Efendy Istanbul and Lucien Arkas Baglari (not on the current list): hold, archive check next.
  D3 a: Sankai by Nagaya: award row relabelled with D1; venue status (closed) not changed; no price row.
  D4 a: LA Mahzen (card only): hold for a separate promote batch.
  D5 a: 16 price INSERT (active, no price row), currency TRY; legacy price rows not changed.

Usage:
  python3 build_turkey_2026_sql.py DB_FILE CARD_READ_FILE PAIRS_FILE RELAY_OUT SQL_OUT KEY \
      PRICE_BEFORE LEDGER_MAX_BEFORE AUDIT_MAX_BEFORE

DB line (md5 e8cf313c73b478c68b9cbce8d8495350 = the read of all 55 Turkey Michelin rows):
  award_id|venue_id|name|status|city|year|category|source_url|price_rows
Card read line (sha256 ba0e1d34...022c9425, browser = file): card_id|card path|symbol|CAT_P0n|distinction|country|read time
Pairs line (pair_turkey.py): venue_id|award_id|card_id|match class|db name|card name
Relay line (built here): venue_id|award_id|card path|symbol|CAT_P0n|distinction|country|read time|P (1 = price INSERT)
"""
import hashlib
import sys
from collections import Counter

DIST = {'bib': 'Bib Gourmand', '1 star': 'One Star', '2 star': 'Two Stars', '3 star': 'Three Stars'}
DB_MD5 = 'e8cf313c73b478c68b9cbce8d8495350'
CARD_SHA = 'ba0e1d3404176a44692aa93cfafc1c88653504a78a1f55ee74247502022c9425'

db_file, card_file, pairs_file, relay_out, sql_out, key = sys.argv[1:7]
price_before, ledger_before, audit_before = (int(x) for x in sys.argv[7:10])

dbt = open(db_file, encoding='utf-8').read()
assert hashlib.md5(dbt.encode('utf-8')).hexdigest() == DB_MD5, 'db file md5'
db = {f[1]: f for f in (l.split('|') for l in dbt.split('\n'))}
assert len(db) == 55
ct = open(card_file, encoding='utf-8').read()
assert hashlib.sha256(ct.encode('utf-8')).hexdigest() == CARD_SHA, 'card file sha256'
cards = {f[0]: f for f in (l.split('|') for l in ct.split('\n'))}
assert len(cards) == 54
pairs = [l.split('|') for l in open(pairs_file, encoding='utf-8').read().split('\n')]
assert len(pairs) == 53 and len({p[2] for p in pairs}) == 53

lines = []
for vid, aid, cid, cls, dbname, cname in pairs:
    d = db[vid]; c = cards[cid]
    assert d[0] == aid and d[5] == '2025' and d[7] == '' and DIST[c[4]] == d[6], (vid, cid)
    assert c[5] == 'tr' and c[2] == '₺' * len(c[2]) and c[3] == 'CAT_P0%d' % len(c[2]), cid
    p = '1' if (d[3] == 'active' and d[8] == '0') else '0'
    lines.append('|'.join([vid, aid, c[1], c[2], c[3], c[4], c[5], c[6], p]))
lines.sort()
txt = '\n'.join(lines)
assert '$r$' not in txt
open(relay_out, 'w', encoding='utf-8').write(txt)
sha = hashlib.sha256(txt.encode('utf-8')).hexdigest()
rows = [l.split('|') for l in lines]
n = len(rows)
np_ = sum(1 for r in rows if r[8] == '1')
assert n == 53 and np_ == 16, (n, np_)

fp = hashlib.md5(txt.encode('utf-8')).hexdigest()
ids_md5 = hashlib.md5('\n'.join(r[0] for r in rows).encode('utf-8')).hexdigest()
# old award rows of the relay venues: id|venue_id|year|category|source_url, by venue_id (C), id
old_md5 = hashlib.md5('\n'.join('%s|%s|%s|%s|%s' % (db[r[0]][0], r[0], db[r[0]][5], db[r[0]][6], db[r[0]][7])
                                for r in rows).encode('utf-8')).hexdigest()
dist_c = Counter(r[5] for r in rows)
tier_p = Counter(len(r[3]) for r in rows if r[8] == '1')
dist_txt = ', '.join('%s %d' % (k, dist_c[k]) for k in sorted(dist_c))
tier_txt = ', '.join('%d = %d' % (k, tier_p[k]) for k in sorted(tier_p))
l_award, l_price = ledger_before + 1, ledger_before + 2
a_first, a_last = audit_before + 1, audit_before + n + np_
price_after = price_before + np_
dist_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in DIST.items())
REC = ('x(venue_id text, award_id bigint, url text, symbol_raw text, cat text, category text, cc text, '
       'captured_at text, p int)')

sql = f"""-- {key}.sql
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
-- Step 1: {n} UPDATE of awards: year 2025 -> 2026, source_url NULL -> card URL. Category and rank do not change.
--         Card distinction equals the award category on every row (guarded). Distinctions: {dist_txt}.
-- Step 2: {np_} INSERT into price (active venues with no price row): source guide_ingest, method published_symbol,
--         publisher michelin, source_url = card URL, symbol_raw = card symbol, currency TRY, tier = symbol count,
--         confidence NULL, captured_at = read time. Tiers: {tier_txt}. Legacy price rows are not changed.
-- Relay sha256 {sha} (inside this file).
-- Guards: counts before (price {price_before}, ledger max {ledger_before}, audit max {audit_before}); relay md5 {fp};
-- venue id md5 {ids_md5}; old Michelin award rows md5 {old_md5}; venues in Turkey; no 2026 Michelin row on any relay
-- venue; card URLs not in use; price flag = (active and no price row).
-- Post-checks: price count {price_after}; ledgers {l_award} (award) and {l_price} (price);
-- audit {a_first} to {a_last}: {n} awards UPDATE + {np_} price INSERT, nothing else; rows match the relay;
-- Turkey Michelin rows after: 2026 = {n}, 2025 = 2 (Efendy Istanbul, Lucien Arkas Baglari).
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r${txt}$r$;
  rel jsonb;
  n_exp int := {n};
  np_exp int := {np_};
  v_txt text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> {price_before} THEN RAISE EXCEPTION 'price count before is not {price_before}'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {ledger_before} THEN RAISE EXCEPTION 'ledger max before is not {ledger_before}'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {audit_before} THEN RAISE EXCEPTION 'audit max before is not {audit_before}'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF md5(rel_txt) <> '{fp}' THEN RAISE EXCEPTION 'relay md5'; END IF;
  -- relay line: venue_id|award_id|card path|symbol|CAT_P0n|distinction|country|read time|P
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'award_id', f[2]::bigint, 'url', 'https://guide.michelin.com/' || f[3],
           'symbol_raw', f[4], 'cat', f[5], 'category', CASE f[6] {dist_case} END, 'cc', f[7],
           'captured_at', f[8], 'p', f[9]::int) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 9 OR f[5] <> 'CAT_P0' || char_length(f[4])
                            OR char_length(f[4]) NOT BETWEEN 1 AND 4 OR f[4] <> repeat('₺', char_length(f[4]))
                            OR f[7] <> 'tr' OR f[9] NOT IN ('0', '1') OR f[3] !~ '^us/en/.+/restaurant/')
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(rel) AS {REC} WHERE x.p = 1) <> np_exp THEN RAISE EXCEPTION 'price flags'; END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS {REC} WHERE x.category IS NULL) THEN RAISE EXCEPTION 'distinction'; END IF;
  SELECT md5(string_agg(x.venue_id, E'\\n' ORDER BY x.venue_id COLLATE "C")) INTO v_txt FROM jsonb_to_recordset(rel) AS {REC};
  IF v_txt <> '{ids_md5}' THEN RAISE EXCEPTION 'venue id md5 %', v_txt; END IF;

  -- old rows, as read before the build (all Michelin rows of the relay venues)
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_txt
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_txt IS DISTINCT FROM '{old_md5}' THEN RAISE EXCEPTION 'old award rows md5 %', v_txt; END IF;

  -- each row: venue in Turkey; exactly one Michelin row = award_id, 2025, source_url NULL, category = card;
  -- price flag 1 = active and no price row; price flag 0 = has a price row or not active
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS {REC}
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
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_id = 'michelin' AND a.year = 2025
     AND a.source_url IS NULL AND a.category = x.category;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', n_exp,
          'relabel:{key} | rule 2.1.7: Turkey Michelin rows hold the 2026 selection (published Dec 4, 2025); year 2025 -> '
          || '2026, source_url NULL -> card URL, category unchanged | Ben D1-D5 "A" Oct 30 13:57 ET | held: Efendy Istanbul, '
          || 'Lucien Arkas Baglari (not on current list), LA Mahzen (not in db) | live list + card read, built-in browser '
          || '| relay md5 {fp}')
  RETURNING id INTO v_lid1;

  -- step 2: price for active venues with no price row
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, char_length(x.symbol_raw)::smallint, x.symbol_raw, 'TRY', 'guide_ingest', 'published_symbol', 'michelin',
         x.url, x.captured_at::timestamptz, NULL
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.p = 1;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> np_exp THEN RAISE EXCEPTION 'price rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', np_exp,
          'price-card:{key} | block A, held Turkey venues: no price row, card URL from the 2026 relabel | '
          || np_exp || ' rows inserted (TRY {np_}; tiers {tier_txt}) | live card read, built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> {price_after} THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> {l_award} OR v_lid2 <> {l_price} THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {audit_before}) <> n_exp + np_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS {REC} ON a.row_pk = x.award_id::text
       WHERE a.id > {audit_before} AND a.table_name = 'awards' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS {REC} ON a.row_pk = x.venue_id
       WHERE a.id > {audit_before} AND a.table_name = 'price' AND a.action = 'INSERT' AND x.p = 1) <> np_exp
    THEN RAISE EXCEPTION 'audit price INSERT rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS {REC}
          ON a.id = x.award_id AND a.year = 2026 AND a.source_url = x.url AND a.category = x.category) <> n_exp
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p JOIN jsonb_to_recordset(rel) AS {REC}
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
"""
open(sql_out, 'w', encoding='utf-8').write(sql)
print('rows', n, '| price', np_, '| relay sha256', sha, '| relay md5', fp, '| ids md5', ids_md5, '| old md5', old_md5)
print('dist:', dist_txt, '| price tiers:', tier_txt)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), '| bytes', len(sql.encode('utf-8')))
