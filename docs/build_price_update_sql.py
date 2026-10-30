#!/usr/bin/env python3
"""Build a gated UPDATE file for block A step 2 (Michelin card price over legacy price rows).

Usage:
  python3 build_price_update_sql.py RELAY_FILE OUT_SQL FILE_KEY BATCH_LABEL \
      PRICE_BEFORE LEDGER_MAX_BEFORE AUDIT_MAX_BEFORE OLD_ROWS_MD5

Relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
(card path has no leading "https://guide.michelin.com/"; lines sorted by venue_id, no final newline).
OLD_ROWS_MD5 = md5 of "venue_id|tier|symbol_raw|coalesce(publisher,'')" lines of the relay venues,
ordered by venue_id COLLATE "C", read from the database before the build.
"""
import hashlib
import sys
from collections import Counter

CUR = {'us': 'USD', 'cn': 'CNY', 'tw': 'TWD', 'jp': 'JPY', 'kr': 'KRW', 'gb': 'GBP',
       'fr': 'EUR', 'de': 'EUR', 'it': 'EUR', 'nl': 'EUR', 'es': 'EUR', 'be': 'EUR',
       'mc': 'EUR', 'ie': 'EUR', 'lu': 'EUR', 'ad': 'EUR'}
SYM = {'USD': '$', 'TWD': '$', 'CNY': '¥', 'JPY': '¥', 'KRW': '₩', 'GBP': '£', 'EUR': '€'}

relay_file, out_sql, key, label = sys.argv[1:5]
price_before, ledger_before, audit_before = (int(x) for x in sys.argv[5:8])
old_md5 = sys.argv[8]

txt = open(relay_file, encoding='utf-8').read()
assert not txt.endswith('\n'), 'relay must have no final newline'
assert '$r$' not in txt
sha = hashlib.sha256(txt.encode('utf-8')).hexdigest()
lines = txt.split('\n')
rows = []
for l in lines:
    f = l.split('|')
    assert len(f) == 7, l
    vid, path, sym, cat, dist, cc, at = f
    assert vid.startswith('ve_') and len(vid) == 13, l
    assert not path.startswith('/') and '/restaurant/' in path, l
    assert 1 <= len(sym) <= 4 and sym == sym[0] * len(sym), l
    assert cat == 'CAT_P0%d' % len(sym), l
    cur = CUR[cc]
    assert SYM[cur] == sym[0], l
    rows.append(dict(venue_id=vid, source_url='https://guide.michelin.com/' + path, symbol_raw=sym,
                     currency=cur, tier=len(sym), captured_at=at, dist=dist))
ids = [r['venue_id'] for r in rows]
assert ids == sorted(ids) and len(set(ids)) == len(ids), 'relay not sorted or has duplicates'
n = len(rows)

fp = hashlib.md5('\n'.join('%s|%s|%s|%s|%d|%s' % (r['venue_id'], r['source_url'], r['symbol_raw'], r['currency'],
                                                  r['tier'], r['captured_at']) for r in rows).encode('utf-8')).hexdigest()
ids_md5 = hashlib.md5('\n'.join(ids).encode('utf-8')).hexdigest()
cur_counts = Counter(r['currency'] for r in rows)
tier_counts = Counter(r['tier'] for r in rows)
dist_counts = Counter(r['dist'] for r in rows)
cur_txt = ', '.join('%s %d' % (k, cur_counts[k]) for k in sorted(cur_counts))
tier_txt = ', '.join('%d = %d' % (k, tier_counts[k]) for k in sorted(tier_counts))
dist_txt = ', '.join('%s %d' % (k or 'none', dist_counts[k]) for k in sorted(dist_counts))
ledger_exp = ledger_before + 1

cur_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in CUR.items())

sql = f"""-- {key}.sql
-- Block A, step 2, {label}.
-- Population P2: active venues with a Michelin One Star, Two Stars, Three Stars or Bib Gourmand row whose source_url is
-- a guide.michelin.com card URL (latest by year desc, id desc), and a price row with source legacy_guide and no source_url.
-- Source: the live Michelin card page (Price: line, data-sheet), read in the built-in browser.
-- Rows: {n} UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
-- source_url = card URL, symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL,
-- captured_at = read time). Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026).
-- Cards that show Selected only are also updated; award rows do not change (Ben, Oct 30, 2026; Oct 10 ruling).
-- Currencies: {cur_txt}. Card tiers: {tier_txt}. Card distinction: {dist_txt}.
-- Relay sha256 {sha} (inside this file).
-- Guards: counts before (price {price_before}, ledger max {ledger_before}, audit max {audit_before}); relay fingerprint md5
-- {fp}; venue id md5 {ids_md5}; old price rows md5 {old_md5};
-- each row in P2 now with the same card URL.
-- Post-checks: price count {price_before} (unchanged); ledger {ledger_exp}; audit {n} price UPDATE rows, nothing else;
-- each price row now matches the relay.
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
  v_lid bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> {price_before} THEN RAISE EXCEPTION 'price count before is not {price_before}'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {ledger_before} THEN RAISE EXCEPTION 'ledger max before is not {ledger_before}'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {audit_before} THEN RAISE EXCEPTION 'audit max before is not {audit_before}'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  -- relay line: venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'source_url', 'https://guide.michelin.com/' || f[2], 'symbol_raw', f[3],
           'currency', CASE f[6] {cur_case} END,
           'tier', char_length(f[3]), 'captured_at', f[7]) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 7 OR f[4] <> 'CAT_P0' || char_length(f[3])
                            OR char_length(f[3]) NOT BETWEEN 1 AND 4
                            OR f[3] <> repeat(left(f[3], 1), char_length(f[3])))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS x(symbol_raw text, currency text)
              WHERE x.currency IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'TWD' THEN '$' WHEN 'CNY' THEN '¥'
                                              WHEN 'JPY' THEN '¥' WHEN 'KRW' THEN '₩' WHEN 'GBP' THEN '£' WHEN 'EUR' THEN '€' END)
    THEN RAISE EXCEPTION 'symbol does not match currency'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.source_url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier||'|'||x.captured_at,
                        E'\\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text, symbol_raw text, currency text, tier int, captured_at text);
  IF v_fp <> '{fp}' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '{ids_md5}' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows: the legacy price rows of the relay venues, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '{old_md5}' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;

  -- each row: venue active; legacy price row with no URL; card URL = latest Michelin star/Bib card URL of the venue
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS x(venue_id text, source_url text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL)
      OR x.source_url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\\.michelin\\.com/.*/restaurant/'
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
          'price-card:{key} | block A step 2 {label}: legacy price rows with no URL, active Michelin star/Bib venues with a card URL | '
          || n_exp || ' rows updated from legacy ({cur_txt}) | live card read, built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid;

  -- post-checks
  IF (SELECT count(*) FROM price) <> {price_before} THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid <> {ledger_exp} THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {audit_before}) <> n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > {audit_before} AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
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
"""
open(out_sql, 'w', encoding='utf-8').write(sql)
print('rows', n, '| relay sha256', sha, '| fp', fp, '| ids md5', ids_md5)
print('currencies:', cur_txt, '| tiers:', tier_txt, '| dist:', dist_txt)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), '| bytes', len(sql.encode('utf-8')))
