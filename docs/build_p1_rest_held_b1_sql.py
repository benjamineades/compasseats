#!/usr/bin/env python3
"""Build batch 1 of the held P1-rest venues (Oct 30, 2026; Ben "go with your recommendations" 15:11 ET).

Rows only, no venue change. 16 relay venues:
  op url      : award source_url NULL -> card URL, category unchanged (card distinction = award category).
  op green    : award One Star -> Green Star, source_url NULL -> card URL (card: no star, greenstar True).
  op heritage : award Two Stars -> One Star, source_url NULL -> card URL; INSERT a 2026 Green Star row (card URL).
  op price    : no award change (Banshee: Selected only; Zhu Ji: archive URL already on the award row).
  Every relay venue: INSERT a price row from the card (source guide_ingest, method published_symbol, publisher michelin).

Usage:
  python3 build_p1_rest_held_b1_sql.py RELAY OUT_SQL KEY PRICE_BEFORE LEDGER_BEFORE AUDIT_BEFORE AWARDS_BEFORE \
      OLD_AWARD_MD5 NOPRICE_BEFORE

Relay line: venue_id|award_id|op|card|symbol|CAT_P0n|distinction|greenstar|country|captured_at
(card = path without "https://guide.michelin.com/", or a full web.archive.org URL; sorted by venue_id; no final newline).
OLD_AWARD_MD5 = md5 of "id|venue_id|year|category|coalesce(source_url,'')" of all Michelin rows of the relay venues
(venue_id COLLATE "C", id).
"""
import hashlib
import sys
from collections import Counter

CUR = {'us': 'USD', 'nz': 'NZD', 'vn': 'VND', 'pl': 'EUR', 'cn': 'CNY'}
SYM = {'USD': '$', 'NZD': '$', 'VND': '₫', 'EUR': '€', 'CNY': '¥'}
DIST = {'bib': 'Bib Gourmand', '1 star': 'One Star', '2 star': 'Two Stars', '3 star': 'Three Stars'}
BASE = 'https://guide.michelin.com/'
ARCH = 'https://web.archive.org/web/'
# op -> (old category, new category, expected card distinction, expected greenstar)
OPS = {'url': (None, None, None, 'False'), 'green': ('One Star', 'Green Star', 'plate', 'True'),
       'heritage': ('Two Stars', 'One Star', '1 star', 'True'), 'price': (None, None, None, None)}

relay_file, out_sql, key = sys.argv[1:4]
price_before, ledger_before, audit_before, awards_before = (int(x) for x in sys.argv[4:8])
old_award_md5 = sys.argv[8]
noprice_before = int(sys.argv[9])

txt = open(relay_file, encoding='utf-8').read()
assert not txt.endswith('\n') and '$r$' not in txt
sha = hashlib.sha256(txt.encode('utf-8')).hexdigest()
rows = []
for l in txt.split('\n'):
    f = l.split('|')
    assert len(f) == 10, l
    vid, aid, op, card, sym, cat, dist, gs, cc, at = f
    assert vid.startswith('ve_') and len(vid) == 13, l
    assert op in OPS, l
    url = card if card.startswith(ARCH) else BASE + card
    assert card.startswith(ARCH) or (card.startswith('us/en/') and '/restaurant/' in card), l
    assert 1 <= len(sym) <= 4 and sym == sym[0] * len(sym) and cat == 'CAT_P0%d' % len(sym), l
    cur = CUR[cc]
    assert SYM[cur] == sym[0], l
    old_c, new_c, exp_dist, exp_gs = OPS[op]
    if op == 'url':
        assert dist in DIST and gs == 'False', l
        old_c = new_c = DIST[dist]
    elif op in ('green', 'heritage'):
        assert dist == exp_dist and gs == exp_gs, l
    if op == 'price':
        assert aid == '-' or card.startswith(ARCH), l
    else:
        assert aid.isdigit() and not card.startswith(ARCH), l
    rows.append(dict(venue_id=vid, award_id=aid, op=op, url=url, symbol_raw=sym, currency=cur, tier=len(sym),
                     captured_at=at, old_cat=old_c or '', new_cat=new_c or ''))
ids = [r['venue_id'] for r in rows]
assert ids == sorted(ids) and len(set(ids)) == len(ids)
n = len(rows)
ops = Counter(r['op'] for r in rows)
n_upd = ops['url'] + ops['green'] + ops['heritage']
n_ins = ops['heritage']
fp = hashlib.md5('\n'.join('|'.join(str(r[k]) for k in (
    'venue_id', 'award_id', 'op', 'url', 'symbol_raw', 'currency', 'tier', 'captured_at', 'old_cat', 'new_cat'))
    for r in rows).encode('utf-8')).hexdigest()
cur_counts = Counter(r['currency'] for r in rows)
tier_counts = Counter(r['tier'] for r in rows)
cur_txt = ', '.join('%s %d' % (k, cur_counts[k]) for k in sorted(cur_counts))
tier_txt = ', '.join('%d = %d' % (k, tier_counts[k]) for k in sorted(tier_counts))
ops_txt = ', '.join('%s %d' % (k, ops[k]) for k in sorted(ops))
l_award, l_price = ledger_before + 1, ledger_before + 2
n_audit = n_upd + n_ins + n
a_first, a_last = audit_before + 1, audit_before + n_audit
price_after, awards_after = price_before + n, awards_before + n_ins
noprice_after = noprice_before - n

cur_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in CUR.items())
dist_case = ' '.join("WHEN '%s' THEN '%s'" % (k, v) for k, v in DIST.items())
REC = ('x(venue_id text, award_id text, op text, url text, symbol_raw text, currency text, tier int, '
       'captured_at text, old_cat text, new_cat text)')

sql = f"""-- {key}.sql
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
-- Ops: {ops_txt}. Award UPDATE {n_upd}, award INSERT {n_ins}, price INSERT {n}.
-- Price: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL (Zhu Ji: archive URL),
--   symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL, captured_at = read time.
--   Currencies: {cur_txt}. Tiers: {tier_txt}.
-- Relay sha256 {sha} (inside this file). Relay fingerprint md5 {fp}.
-- Guards: price {price_before}, ledger max {ledger_before}, audit max {audit_before}, awards {awards_before}; old Michelin rows md5
--   {old_award_md5}; active star/Bib venues with no price {noprice_before}; no price row on a relay venue; card URLs not in use.
-- Post-checks: price {price_after}; awards {awards_after}; ledgers {l_award} (award) and {l_price} (price); audit {a_first} to {a_last}:
--   {n_upd} awards UPDATE + {n_ins} awards INSERT + {n} price INSERT, nothing else; active star/Bib venues with no price {noprice_after}.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r${txt}$r$;
  rel jsonb;
  v_fp text;
  v_old text;
  v_bad int;
  v_upd int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM price) <> {price_before} THEN RAISE EXCEPTION 'price count before is not {price_before}'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {ledger_before} THEN RAISE EXCEPTION 'ledger max before is not {ledger_before}'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {audit_before} THEN RAISE EXCEPTION 'audit max before is not {audit_before}'; END IF;
  IF (SELECT count(*) FROM awards) <> {awards_before} THEN RAISE EXCEPTION 'awards count before is not {awards_before}'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay sha256'; END IF;

  -- relay line: venue_id|award_id|op|card|symbol|CAT_P0n|distinction|greenstar|country|captured_at
  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', f[1], 'award_id', f[2], 'op', f[3],
           'url', CASE WHEN f[4] LIKE 'https://web.archive.org/web/%' THEN f[4] ELSE 'https://guide.michelin.com/' || f[4] END,
           'symbol_raw', f[5], 'currency', CASE f[9] {cur_case} END, 'tier', char_length(f[5]), 'captured_at', f[10],
           'old_cat', CASE f[3] WHEN 'url' THEN CASE f[7] {dist_case} END WHEN 'green' THEN 'One Star'
                                WHEN 'heritage' THEN 'Two Stars' ELSE '' END,
           'new_cat', CASE f[3] WHEN 'url' THEN CASE f[7] {dist_case} END WHEN 'green' THEN 'Green Star'
                                WHEN 'heritage' THEN 'One Star' ELSE '' END) ORDER BY f[1] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 10 OR f[6] <> 'CAT_P0' || char_length(f[5])
                            OR f[5] <> repeat(left(f[5], 1), char_length(f[5]))
                            OR (f[3] = 'url' AND (f[8] <> 'False' OR f[7] NOT IN ('bib','1 star','2 star','3 star')))
                            OR (f[3] = 'green' AND (f[7] <> 'plate' OR f[8] <> 'True'))
                            OR (f[3] = 'heritage' AND (f[7] <> '1 star' OR f[8] <> 'True'))
                            OR f[3] NOT IN ('url','green','heritage','price'))
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> {n} THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  IF EXISTS (SELECT 1 FROM jsonb_to_recordset(rel) AS {REC}
              WHERE x.currency IS NULL OR left(x.symbol_raw, 1) <> CASE x.currency WHEN 'USD' THEN '$' WHEN 'NZD' THEN '$'
                                              WHEN 'VND' THEN '₫' WHEN 'EUR' THEN '€' WHEN 'CNY' THEN '¥' END)
    THEN RAISE EXCEPTION 'symbol or currency'; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.award_id||'|'||x.op||'|'||x.url||'|'||x.symbol_raw||'|'||x.currency||'|'||x.tier
                        ||'|'||x.captured_at||'|'||x.old_cat||'|'||x.new_cat, E'\\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp FROM jsonb_to_recordset(rel) AS {REC};
  IF v_fp <> '{fp}' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;

  -- rows as read before the build
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_old
    FROM awards a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.venue_id
   WHERE a.source_id = 'michelin';
  IF v_old IS DISTINCT FROM '{old_award_md5}' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;
  IF (SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id)) <> {noprice_before}
    THEN RAISE EXCEPTION 'active star/Bib venues with no price before'; END IF;
  SELECT count(*) INTO v_bad
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id)
      OR (x.op <> 'price' AND NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.venue_id
                                            AND a.source_id = 'michelin' AND a.year = 2026 AND a.source_url IS NULL
                                            AND a.category = x.old_cat));
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows changed since the read: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS {REC} ON a.source_url = x.url
              WHERE x.op <> 'price') THEN RAISE EXCEPTION 'a card URL is already in use'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS x(url text) ON p.source_url = x.url)
    THEN RAISE EXCEPTION 'a URL is already in use on a price row'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS {REC} ON a.venue_id = x.venue_id
              WHERE x.op = 'heritage' AND a.category = 'Green Star') THEN RAISE EXCEPTION 'Green Star row exists'; END IF;

  -- awards: source_url and category
  UPDATE awards a SET source_url = x.url, category = x.new_cat
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op IN ('url','green','heritage') AND a.id = x.award_id::bigint AND a.venue_id = x.venue_id
     AND a.source_id = 'michelin' AND a.year = 2026 AND a.source_url IS NULL AND a.category = x.old_cat;
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> {n_upd} THEN RAISE EXCEPTION 'award rows updated: %', v_upd; END IF;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT x.venue_id, 'michelin', 2026, NULL, 'Green Star', NULL, x.url
    FROM jsonb_to_recordset(rel) AS {REC} WHERE x.op = 'heritage';
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> {n_ins} THEN RAISE EXCEPTION 'award rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', {n_upd + n_ins},
          'relabel:{key} | held P1 rest batch 1: {ops["url"]} source_url NULL -> card URL; {ops["green"]} One Star -> Green Star '
          || '(California: 2026 article, 2025 article, cards greenstar True); Heritage Long Beach Two Stars -> One Star + '
          || '2026 Green Star row | Ben Oct 30 15:11 ET | relay md5 {fp}')
  RETURNING id INTO v_lid1;

  -- price
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, x.tier::smallint, x.symbol_raw, x.currency, 'guide_ingest', 'published_symbol', 'michelin',
         x.url, x.captured_at::timestamptz, NULL
    FROM jsonb_to_recordset(rel) AS {REC};
  GET DIAGNOSTICS v_upd = ROW_COUNT;
  IF v_upd <> {n} THEN RAISE EXCEPTION 'price rows inserted: %', v_upd; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', {n},
          'price-card:{key} | held P1 rest batch 1: no price row; live card read (Zhu Ji: archive card Sep 4, 2025) | '
          || '{n} rows inserted ({cur_txt}) | built-in browser | relay md5 {fp}')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM price) <> {price_after} THEN RAISE EXCEPTION 'price count after'; END IF;
  IF (SELECT count(*) FROM awards) <> {awards_after} THEN RAISE EXCEPTION 'awards count after'; END IF;
  IF v_lid1 <> {l_award} OR v_lid2 <> {l_price} THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {audit_before}) <> {n_audit} THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS {REC} ON a.row_pk = x.award_id
       WHERE a.id > {audit_before} AND a.table_name = 'awards' AND a.action = 'UPDATE') <> {n_upd}
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log a WHERE a.id > {audit_before} AND a.table_name = 'awards' AND a.action = 'INSERT'
         AND a.new_row->>'venue_id' IN (SELECT x.venue_id FROM jsonb_to_recordset(rel) AS {REC} WHERE x.op = 'heritage')
         AND a.new_row->>'category' = 'Green Star') <> {n_ins}
    THEN RAISE EXCEPTION 'audit awards INSERT rows'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN jsonb_to_recordset(rel) AS x(venue_id text) ON x.venue_id = a.row_pk
       WHERE a.id > {audit_before} AND a.table_name = 'price' AND a.action = 'INSERT') <> {n}
    THEN RAISE EXCEPTION 'audit price INSERT rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS {REC}
          ON a.id = x.award_id::bigint AND a.venue_id = x.venue_id AND a.source_url = x.url AND a.category = x.new_cat
         AND a.year = 2026 WHERE x.op <> 'price') <> {n_upd}
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM awards a JOIN jsonb_to_recordset(rel) AS {REC}
          ON a.venue_id = x.venue_id AND a.source_url = x.url AND a.category = 'Green Star' AND a.year = 2026
       WHERE x.op = 'heritage') <> {n_ins}
    THEN RAISE EXCEPTION 'Green Star row after'; END IF;
  IF (SELECT count(*) FROM price p
        JOIN jsonb_to_recordset(rel) AS {REC}
          ON x.venue_id = p.venue_id AND x.symbol_raw = p.symbol_raw AND x.url = p.source_url
         AND x.currency = p.currency AND x.tier = p.tier AND x.captured_at::timestamptz = p.captured_at
       WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin'
         AND p.confidence IS NULL) <> {n}
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''), E'\\n' ORDER BY a.id))
        FROM awards a WHERE a.venue_id = 've_466f9b5fe9') <> md5('21098|2023|Bib Gourmand|' || E'\\n' || '21099|2024|Bib Gourmand|')
    THEN RAISE EXCEPTION 'Banshee award rows changed'; END IF;
  IF (SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id)) <> {noprice_after}
    THEN RAISE EXCEPTION 'active star/Bib venues with no price after'; END IF;
END
$do$;
COMMIT;
"""
open(out_sql, 'w', encoding='utf-8').write(sql)
print('rows', n, '| ops', ops_txt, '| relay sha256', sha, '| fp', fp)
print('currencies:', cur_txt, '| tiers:', tier_txt)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), '| bytes', len(sql.encode('utf-8')))
