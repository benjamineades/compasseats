#!/usr/bin/env python3
"""Build a gated file for held P2 cards that have a new card path (block A step 2, held pass).

For each relay venue: UPDATE the latest Michelin star/Bib award row source_url (old card URL -> new card URL),
then UPDATE the legacy price row from the live card (same method as build_price_update_sql.py).

Usage:
  python3 build_price_moved_card_sql.py RELAY_FILE OUT_SQL FILE_KEY LABEL \
      PRICE_BEFORE LEDGER_MAX_BEFORE AUDIT_MAX_BEFORE OLD_PRICE_MD5 OLD_AWARD_MD5

Relay line: venue_id|award_id|old card path|new card path|symbol|CAT_P0n|distinction|country|captured_at
(card paths have no leading "https://guide.michelin.com/"; lines sorted by venue_id; no final newline).
OLD_PRICE_MD5 = md5 of "venue_id|tier|symbol_raw|coalesce(publisher,'')" lines (relay venues, venue_id COLLATE "C").
OLD_AWARD_MD5 = md5 of "id|venue_id|year|category|source_url" lines of all Michelin award rows of the relay venues
(venue_id COLLATE "C").
"""
import hashlib
import sys
from collections import Counter

CUR = {'us': 'USD', 'cn': 'CNY', 'tw': 'TWD', 'jp': 'JPY', 'kr': 'KRW', 'gb': 'GBP',
       'fr': 'EUR', 'de': 'EUR', 'it': 'EUR', 'nl': 'EUR', 'es': 'EUR', 'be': 'EUR',
       'mc': 'EUR', 'ie': 'EUR', 'lu': 'EUR', 'ad': 'EUR'}
SYM = {'USD': '$', 'TWD': '$', 'CNY': '¥', 'JPY': '¥', 'KRW': '₩', 'GBP': '£', 'EUR': '€'}
DIST = {'bib': 'Bib Gourmand', '1 star': 'One Star', '2 star': 'Two Stars', '3 star': 'Three Stars'}
BASE = 'https://guide.michelin.com/'

relay_file, out_sql, key, label = sys.argv[1:5]
price_before, ledger_before, audit_before = (int(x) for x in sys.argv[5:8])
old_price_md5, old_award_md5 = sys.argv[8:10]

txt = open(relay_file, encoding='utf-8').read()
assert not txt.endswith('\n'), 'relay must have no final newline'
assert '$r$' not in txt
sha = hashlib.sha256(txt.encode('utf-8')).hexdigest()
rows = []
for l in txt.split('\n'):
    f = l.split('|')
    assert len(f) == 9, l
    vid, aid, oldp, newp, sym, cat, dist, cc, at = f
    assert vid.startswith('ve_') and len(vid) == 13, l
    assert aid.isdigit(), l
    for p in (oldp, newp):
        assert not p.startswith('/') and '/restaurant/' in p, l
    assert oldp != newp, l
    assert 1 <= len(sym) <= 4 and sym == sym[0] * len(sym), l
    assert cat == 'CAT_P0%d' % len(sym), l
    assert dist in DIST, l
    cur = CUR[cc]
    assert SYM[cur] == sym[0], l
    rows.append(dict(venue_id=vid, award_id=int(aid), old_url=BASE + oldp, new_url=BASE + newp, symbol_raw=sym,
                     currency=cur, tier=len(sym), captured_at=at, category=DIST[dist], dist=dist))
ids = [r['venue_id'] for r in rows]
assert ids == sorted(ids) and len(set(ids)) == len(ids), 'relay not sorted or has duplicates'
assert len(set(r['award_id'] for r in rows)) == len(rows)
assert len(set(r['new_url'] for r in rows)) == len(rows)
n = len(rows)

fp = hashlib.md5('\n'.join('%s|%d|%s|%s|%s|%s|%d|%s|%s' % (
    r['venue_id'], r['award_id'], r['old_url'], r['new_url'], r['symbol_raw'], r['currency'], r['tier'],
    r['captured_at'], r['category']) for r in rows).encode('utf-8')).hexdigest()
ids_md5 = hashlib.md5('\n'.join(ids).encode('utf-8')).hexdigest()
cur_counts = Counter(r['currency'] for r in rows)
tier_counts = Counter(r['tier'] for r in rows)
dist_counts = Counter(r['dist'] for r in rows)
cur_txt = ', '.join('%s %d' % (k, cur_counts[k]) for k in sorted(cur_counts))
tier_txt = ', '.join('%d = %d' % (k, tier_counts[k]) for k in sorted(tier_counts))
dist_txt = ', '.join('%s %d' % (k, dist_counts[k]) for k in sorted(dist_counts))
award_ids_txt = ','.join(str(r['award_id']) for r in sorted(rows, key=lambda r: r['award_id']))
l_award, l_price = ledger_before + 1, ledger_before + 2
a_first, a_last = audit_before + 1, audit_before + 2 * n

cur_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in CUR.items())
dist_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in DIST.items())
REC = ('x(venue_id text, award_id bigint, old_url text, new_url text, symbol_raw text, currency text, tier int, '
       'captured_at text, category text)')

sql = f"""-- {key}.sql
-- Block A, step 2, {label}.
-- Population: held P2 venues (card 404 or redirect in batches 1 to 10) whose card now lives at a new path on
-- guide.michelin.com (redirect, or the same venue in the current city list, matched by address). Ben "agree", Oct 30, 2026.
-- Step 1: {n} UPDATE of awards.source_url (the one Michelin award row of each venue): old card URL -> new card URL.
--         Year, category and all other columns do not change.
-- Step 2: {n} UPDATE of the legacy price row (source guide_ingest, method published_symbol, publisher michelin,
--         source_url = new card URL, symbol_raw = card symbol, currency from card country, tier = symbol count,
--         confidence NULL, captured_at = read time).
-- Card distinction equals the award category on every row (guarded).
-- Currencies: {cur_txt}. Card tiers: {tier_txt}. Card distinction: {dist_txt}. Award ids: {award_ids_txt}.
-- Relay sha256 {sha} (inside this file).
-- Guards: counts before (price {price_before}, ledger max {ledger_before}, audit max {audit_before}); relay fingerprint md5
-- {fp}; venue id md5 {ids_md5}; old price rows md5 {old_price_md5};
-- old Michelin award rows md5 {old_award_md5}; new URLs not in use on any award row.
-- Post-checks: price count {price_before} (unchanged); ledgers {l_award} (award) and {l_price} (price);
-- audit {a_first} to {a_last}: {n} awards UPDATE + {n} price UPDATE, nothing else; each award and price row matches the relay.
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
  -- relay line: venue_id|award_id|old card path|new card path|symbol|CAT_P0n|distinction|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'award_id', f[2]::bigint,
           'old_url', 'https://guide.michelin.com/' || f[3], 'new_url', 'https://guide.michelin.com/' || f[4],
           'symbol_raw', f[5], 'currency', CASE f[8] {cur_case} END,
           'tier', char_length(f[5]), 'captured_at', f[9],
           'category', CASE f[7] {dist_case} END) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 9 OR f[6] <> 'CAT_P0' || char_length(f[5])
                            OR char_length(f[5]) NOT BETWEEN 1 AND 4
                            OR f[5] <> repeat(left(f[5], 1), char_length(f[5])) OR f[3] = f[4])
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> n_exp THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS {REC}
              WHERE x.currency IS NULL OR x.category IS NULL
                 OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'TWD' THEN '$' WHEN 'CNY' THEN '¥'
                                              WHEN 'JPY' THEN '¥' WHEN 'KRW' THEN '₩' WHEN 'GBP' THEN '£' WHEN 'EUR' THEN '€' END)
    THEN RAISE EXCEPTION 'symbol, currency or distinction'; END IF;

  SELECT md5(string_agg(x.venue_id||'|'||x.award_id||'|'||x.old_url||'|'||x.new_url||'|'||x.symbol_raw||'|'||x.currency
                        ||'|'||x.tier||'|'||x.captured_at||'|'||x.category, E'\\n' ORDER BY x.venue_id COLLATE "C")),
         md5(string_agg(x.venue_id, E'\\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp, v_ids
    FROM jsonb_to_recordset(rel) AS {REC};
  IF v_fp <> '{fp}' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  IF v_ids <> '{ids_md5}' THEN RAISE EXCEPTION 'venue id md5 %', v_ids; END IF;

  -- old rows, as read before the build
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||coalesce(p.symbol_raw,'')||'|'||coalesce(p.publisher,''),
                        E'\\n' ORDER BY p.venue_id COLLATE "C"))
    INTO v_old
    FROM price p JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = p.venue_id;
  IF v_old IS DISTINCT FROM '{old_price_md5}' THEN RAISE EXCEPTION 'old price rows md5 %', v_old; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||a.source_url,
                        E'\\n' ORDER BY a.venue_id COLLATE "C"))
    INTO v_old
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_old IS DISTINCT FROM '{old_award_md5}' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;

  -- each row: venue active; legacy price row with no URL; award id = latest Michelin star/Bib card row of the venue,
  -- with the old card URL and the same category as the card distinction
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL)
      OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id AND a.venue_id = x.venue_id
                        AND a.source_url = x.old_url AND a.category = x.category)
      OR x.award_id IS DISTINCT FROM (
           SELECT a.id FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\\.michelin\\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows outside the held set or changed: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(new_url text) ON a.source_url = x.new_url)
    THEN RAISE EXCEPTION 'a new URL is already in use'; END IF;

  -- step 1: award source_url
  UPDATE awards a SET source_url = x.new_url
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_url = x.old_url;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', n_exp,
          'source-url:{key} | block A step 2 {label}: Michelin card moved to a new path; award source_url updated, '
          || 'year and category unchanged | award ids {award_ids_txt} | live card read, built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid1;

  -- step 2: price (same guard as the batch files: card URL = latest Michelin star/Bib card URL of the venue)
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.new_url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = x.venue_id AND a.source_id = 'michelin'
              AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
              AND a.source_url ~ '^https://guide\\.michelin\\.com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'card URL is not the latest award URL after step 1: %', v_bad; END IF;

  UPDATE price p
     SET tier = x.tier::smallint, symbol_raw = x.symbol_raw, currency = x.currency, source = 'guide_ingest',
         method = 'published_symbol', publisher = 'michelin', source_url = x.new_url,
         captured_at = x.captured_at::timestamptz, confidence = NULL
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> n_exp THEN RAISE EXCEPTION 'price rows updated: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', n_exp,
          'price-card:{key} | block A step 2 {label}: legacy price rows with no URL, card at a new path | '
          || n_exp || ' rows updated from legacy ({cur_txt}) | live card read, built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> {price_before} THEN RAISE EXCEPTION 'price count after'; END IF;
  IF v_lid1 <> {l_award} OR v_lid2 <> {l_price} THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {audit_before}) <> 2 * n_exp THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(award_id bigint) ON x.award_id::text = a.row_pk
       WHERE a.id > {audit_before} AND a.table_name = 'awards' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a
        JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > {audit_before} AND a.table_name = 'price' AND a.action = 'UPDATE') <> n_exp
    THEN RAISE EXCEPTION 'audit price UPDATE rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS {REC}
          ON a.id = x.award_id AND a.venue_id = x.venue_id AND a.source_url = x.new_url AND a.category = x.category) <> n_exp
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS {REC}
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.new_url = p.source_url
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
print('currencies:', cur_txt, '| tiers:', tier_txt, '| dist:', dist_txt, '| award ids:', award_ids_txt)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), '| bytes', len(sql.encode('utf-8')))
