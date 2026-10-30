#!/usr/bin/env python3
"""Build the gated file for P1 rest (block A step 3): active Michelin star/Bib venues with no price row and no card URL.

For each relay venue (card found by a name search in the Michelin country/state lists, Ben "agree" Oct 30, 2026):
  step 1: UPDATE the one Michelin award row (latest star/Bib row, source_url NULL): source_url = card URL.
  step 2: INSERT a price row from the live card (source guide_ingest, method published_symbol, publisher michelin).

Usage:
  python3 build_price_p1_rest_sql.py RELAY_FILE OUT_SQL FILE_KEY LABEL \
      PRICE_BEFORE LEDGER_MAX_BEFORE AUDIT_MAX_BEFORE OLD_AWARD_MD5 LATEST_MD5

Relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
(card path has no leading "https://guide.michelin.com/"; lines sorted by venue_id; no final newline).
OLD_AWARD_MD5 = md5 of "id|venue_id|year|category|coalesce(source_url,'')" lines of all Michelin award rows of the
relay venues (venue_id COLLATE "C", id). LATEST_MD5 = md5 of "venue_id|award id" of the latest Michelin star/Bib row
of each relay venue (venue_id COLLATE "C").
"""
import hashlib
import sys
from collections import Counter

CUR = {'us': 'USD', 'nz': 'NZD', 'vn': 'VND',
       'dk': 'EUR', 'no': 'EUR', 'pl': 'EUR', 'se': 'EUR', 'fi': 'EUR', 'hr': 'EUR', 'lt': 'EUR', 'si': 'EUR'}
SYM = {'USD': '$', 'NZD': '$', 'VND': '₫', 'EUR': '€'}
DIST = {'bib': 'Bib Gourmand', '1 star': 'One Star', '2 star': 'Two Stars', '3 star': 'Three Stars'}
BASE = 'https://guide.michelin.com/'

relay_file, out_sql, key, label = sys.argv[1:5]
price_before, ledger_before, audit_before = (int(x) for x in sys.argv[5:8])
old_award_md5, latest_md5 = sys.argv[8:10]

txt = open(relay_file, encoding='utf-8').read()
assert not txt.endswith('\n'), 'relay must have no final newline'
assert '$r$' not in txt
sha = hashlib.sha256(txt.encode('utf-8')).hexdigest()
rows = []
for l in txt.split('\n'):
    f = l.split('|')
    assert len(f) == 7, l
    vid, path, sym, cat, dist, cc, at = f
    assert vid.startswith('ve_') and len(vid) == 13, l
    assert not path.startswith('/') and path.startswith('us/en/') and '/restaurant/' in path, l
    assert 1 <= len(sym) <= 4 and sym == sym[0] * len(sym), l
    assert cat == 'CAT_P0%d' % len(sym), l
    assert dist in DIST, l
    cur = CUR[cc]
    assert SYM[cur] == sym[0], l
    rows.append(dict(venue_id=vid, url=BASE + path, symbol_raw=sym, currency=cur, tier=len(sym), captured_at=at,
                     category=DIST[dist], dist=dist))
ids = [r['venue_id'] for r in rows]
assert ids == sorted(ids) and len(set(ids)) == len(ids), 'relay not sorted or has duplicates'
assert len(set(r['url'] for r in rows)) == len(rows)
n = len(rows)

fp = hashlib.md5('\n'.join('%s|%s|%s|%s|%d|%s|%s' % (
    r['venue_id'], r['url'], r['symbol_raw'], r['currency'], r['tier'], r['captured_at'], r['category'])
    for r in rows).encode('utf-8')).hexdigest()
ids_md5 = hashlib.md5('\n'.join(ids).encode('utf-8')).hexdigest()
cur_counts = Counter(r['currency'] for r in rows)
tier_counts = Counter(r['tier'] for r in rows)
dist_counts = Counter(r['dist'] for r in rows)
cc_counts = Counter(l.split('|')[5] for l in txt.split('\n'))
cur_txt = ', '.join('%s %d' % (k, cur_counts[k]) for k in sorted(cur_counts))
tier_txt = ', '.join('%d = %d' % (k, tier_counts[k]) for k in sorted(tier_counts))
dist_txt = ', '.join('%s %d' % (k, dist_counts[k]) for k in sorted(dist_counts))
cc_txt = ', '.join('%s %d' % (k, cc_counts[k]) for k in sorted(cc_counts))
l_award, l_price = ledger_before + 1, ledger_before + 2
a_first, a_last = audit_before + 1, audit_before + 2 * n
price_after = price_before + n

cur_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in CUR.items())
dist_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in DIST.items())
REC = 'x(venue_id text, url text, symbol_raw text, currency text, tier int, captured_at text, category text)'

sql = f"""-- {key}.sql
-- Block A, {label}.
-- Population: active venues with a Michelin star/Bib award row, no price row and no card URL (P1 rest, 151 on
-- Oct 30, 2026). Held before the search: Turkey 16 (2025 rows only), Banshee (2024), Zhu Ji Zhi Mian Pu (archive URL).
-- Card found by name in the full Michelin lists (DK, FI, HR, LT, NO, PL, SE, SI, NZ, VN, California, Florida):
-- class A exact name + city 71; class C1 generic words only, same city, same distinction 33 (Ben "agree" 13:32 ET);
-- class C2 address proof on the venue's own website 12. Held after the search: 17 (see handoff).
-- Each relay venue has exactly one Michelin award row: 2026, star or Bib, source_url NULL (guarded).
-- Step 1: {n} UPDATE of awards.source_url (NULL -> card URL). Year, category and all other columns do not change.
-- Step 2: {n} INSERT into price (source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
--         symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
--         captured_at = read time). DK, NO, PL, SE cards show EUR symbols: stored as EUR (Ben "agree" 13:32 ET).
-- Card distinction equals the award category on every row (guarded).
-- Card countries: {cc_txt}. Currencies: {cur_txt}. Card tiers: {tier_txt}. Card distinction: {dist_txt}.
-- Relay sha256 {sha} (inside this file).
-- Guards: counts before (price {price_before}, ledger max {ledger_before}, audit max {audit_before}); relay fingerprint md5
-- {fp}; venue id md5 {ids_md5}; old Michelin award rows md5 {old_award_md5};
-- latest award id md5 {latest_md5}; no price row on any relay venue; card URLs not in use on any award row.
-- Post-checks: price count {price_after}; ledgers {l_award} (award) and {l_price} (price);
-- audit {a_first} to {a_last}: {n} awards UPDATE + {n} price INSERT, nothing else; each award and price row matches the relay.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r${txt}$r$;
  rel jsonb;
  n_exp int := {n};
  v_fp text;
  v_ids text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> {price_before} THEN RAISE EXCEPTION 'price count before is not {price_before}'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {ledger_before} THEN RAISE EXCEPTION 'ledger max before is not {ledger_before}'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {audit_before} THEN RAISE EXCEPTION 'audit max before is not {audit_before}'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  -- relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'url', 'https://guide.michelin.com/' || f[2],
           'symbol_raw', f[3], 'currency', CASE f[6] {cur_case} END,
           'tier', char_length(f[3]), 'captured_at', f[7],
           'category', CASE f[5] {dist_case} END) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 7 OR f[4] <> 'CAT_P0' || char_length(f[3])
                            OR char_length(f[3]) NOT BETWEEN 1 AND 4
                            OR f[3] <> repeat(left(f[3], 1), char_length(f[3])))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS {REC}
              WHERE x.currency IS NULL OR x.category IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'NZD' THEN '$' WHEN 'VND' THEN '₫'
                                              WHEN 'EUR' THEN '€' END)
    THEN RAISE EXCEPTION 'symbol, currency or distinction'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier||'|'||x.captured_at
                        ||'|'||x.category, E'\\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS {REC};
  IF v_fp <> '{fp}' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '{ids_md5}' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows, as read before the build
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_old
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_old IS DISTINCT FROM '{old_award_md5}' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;
  SELECT md5(string_agg(l.venue_id||'|'||l.id, E'\\n' ORDER BY l.venue_id COLLATE "C"))
    INTO v_old
    FROM (SELECT DISTINCT ON (a.venue_id) a.venue_id, a.id
            FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
           WHERE a.source_id = 'michelin' AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
           ORDER BY a.venue_id, a.year DESC, a.id DESC) l;
  IF v_old IS DISTINCT FROM '{latest_md5}' THEN RAISE EXCEPTION 'latest award id md5 %', v_old; END IF;

  -- each row: venue active; no price row; exactly one Michelin award row, source_url NULL, category = card distinction
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id)
      OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin') <> 1
      OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
                        AND a.source_url IS NULL AND a.category = x.category);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows outside P1 rest or changed: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(url text) ON a.source_url = x.url)
    THEN RAISE EXCEPTION 'a card URL is already in use'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS x(url text) ON p.source_url = x.url)
    THEN RAISE EXCEPTION 'a card URL is already in use on a price row'; END IF;

  -- step 1: award source_url
  UPDATE awards a SET source_url = x.url
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin' AND a.source_url IS NULL AND a.category = x.category;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', n_exp,
          'source-url:{key} | block A {label}: card found by name search in the Michelin lists; award source_url '
          || 'NULL -> card URL, year and category unchanged | live card read, built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid1;

  -- step 2: price (guard: card URL = latest Michelin star/Bib card URL of the venue)
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\\.michelin\\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'card URL is not the latest award URL after step 1: %', v_bad; END IF;

  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, x.tier::smallint, x.symbol_raw, x.currency, 'guide_ingest', 'published_symbol', 'michelin',
         x.url, x.captured_at::timestamptz, NULL
    FROM jsonb_to_recordset(rel) AS {REC};
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'price rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', n_exp,
          'price-card:{key} | block A {label}: no price row, card found by name search | '
          || n_exp || ' rows inserted ({cur_txt}) | live card read, built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> {price_after} THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> {l_award} OR v_lid2 <> {l_price} THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {audit_before}) <> 2 * n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN awards w ON w.id::text = a.row_pk
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = w.venue_id
       WHERE a.id > {audit_before} AND a.table_name = 'awards' AND a.action = 'UPDATE' AND w.source_id = 'michelin') <> n_exp
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > {audit_before} AND a.table_name = 'price' AND a.action = 'INSERT') <> n_exp
    THEN RAISE EXCEPTION 'audit price INSERT rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS {REC}
          ON a.venue_id = x.venue_id AND a.source_id = 'michelin' AND a.source_url = x.url AND a.category = x.category) <> n_exp
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS {REC}
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> n_exp
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
END
$do$;
COMMIT;
"""
open(out_sql, 'w', encoding='utf-8').write(sql)
print('rows', n, '| relay sha256', sha, '| fp', fp, '| ids md5', ids_md5)
print('countries:', cc_txt, '| currencies:', cur_txt, '| tiers:', tier_txt, '| dist:', dist_txt)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), '| bytes', len(sql.encode('utf-8')))
