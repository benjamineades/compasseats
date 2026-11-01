"""Build docs/source-url-best-chef-2024-2025-2026-11-01.sql from pairs.tsv (output of pair_best_chef.py).

Usage: python3 build_best_chef_urls_2026_11_01.py [test]
  test = pre-check copy (same file; used for the read-only dry run, which stops at the first write).
"""
import hashlib, sys

URL_2024 = 'https://thebestchefawards.com/events-results/?id=1874'   # D1 = A (results page, Dubai 2024)
URL_2025 = 'https://thebestchefawards.com/events-results/?id=2376'   # results page, Milan 2025
EXPECT = dict(awards=23363, ledger=178, audit_max=119438, audit_n=114154,
              fp_all='4edff41c2c2485ded4824a79ed4b5daa', ids_all='e57cc85d02f7c8e00a196a389e3c94e9',
              n24=518, n25=776)
HOLD = (3453, 15690, 15727, 15997, 16190)
ALREADY = (15879,)  # 2024 row with the 2024 list PDF URL (Oct 30, ledger 171); unchanged

rows = [l.rstrip('\n').split('\t') for l in open('pairs.tsv', encoding='utf-8')][1:]
rel = []
for o in rows:
    aid, yr, lvl = int(o[0]), int(o[1]), o[3]
    if lvl == 'HOLD' or aid in ALREADY:
        continue
    assert lvl in ('L1', 'L2', 'L3', 'MANUAL'), o
    rel.append((aid, yr, o[7]))
rel.sort()
n24 = sum(1 for r in rel if r[1] == 2024); n25 = sum(1 for r in rel if r[1] == 2025)
assert (n24, n25) == (EXPECT['n24'], EXPECT['n25']), (n24, n25)
ids_md5 = hashlib.md5('\n'.join(str(r[0]) for r in rel).encode()).hexdigest()
assert ids_md5 == EXPECT['ids_all'], ids_md5
relay = '\n'.join(f'{a}|{y}|{c}' for a, y, c in rel)
relay_sha = hashlib.sha256(relay.encode('utf-8')).hexdigest()
open('relay.txt', 'w', encoding='utf-8').write(relay)

sql = f"""-- source-url-best-chef-2024-2025-2026-11-01.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 8 (Best Chef source URLs, items 1 + 2). UPDATE/INSERT only: Write connector.
-- Ben: Nov 1 00:47 ET "items 1 & 2 first".
-- awards.source_url NULL -> the Best Chef Awards results page of the edition (source_url only; year, category, venue unchanged).
--   2024: {URL_2024} (Dubai 2024, 536 knife cards)
--   2025: {URL_2025} (Milan 2025, 796 knife cards)
-- Pairing (docs/best-chef-urls-build/pair_best_chef.py, read Nov 1 2026): each row pairs to one list entry of its year with the
--   same knife count (L1 name+city, L2 name, L3 city + name contains, MANUAL 56 rows by hand). No list entry pairs to 2 rows.
-- Not changed: 15879 (2024, has the 2024 list PDF URL); 5 held 2025 rows with no proving entry: {', '.join(map(str, HOLD))}.
-- Relay docs/best-chef-urls-build/relay.txt ({len(rel)} lines, award_id|year|chef_id) sha256 {relay_sha}.
-- Expected: awards {EXPECT['awards']} (unchanged), best-chef 2024/2025 rows without URL 1299 -> 5, ledger {EXPECT['ledger']} -> {EXPECT['ledger']+2},
--   audit {EXPECT['audit_max']} -> {EXPECT['audit_max']+len(rel)} (+{len(rel)}: awards UPDATE, source_url only).
BEGIN;
DO $do$
DECLARE
  rel text := replace($r${relay}$r$, E'\\r', '');
  v_n int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{relay_sha}' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM awards) <> {EXPECT['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {EXPECT['ledger']} THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {EXPECT['audit_max']} OR (SELECT count(*) FROM audit_log) <> {EXPECT['audit_n']} THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL) <> 1299
    THEN RAISE EXCEPTION 'best-chef rows without URL before'; END IF;

  -- plan fingerprint: the relay rows, read live (best-chef, same year, no URL)
  SELECT count(*), md5(string_agg(a.id||'|'||a.year||'|'||a.venue_id||'|'||a.category, E'\\n' ORDER BY a.id))
    INTO v_n, v_txt
    FROM awards a JOIN regexp_split_to_table(rel, E'\\n') l
      ON a.id = split_part(l, '|', 1)::bigint AND a.year = split_part(l, '|', 2)::int
   WHERE a.source_id = 'best-chef-awards' AND a.source_url IS NULL;
  IF v_n <> {len(rel)} OR v_txt IS DISTINCT FROM '{EXPECT['fp_all']}' THEN RAISE EXCEPTION 'plan fingerprint % %', v_n, v_txt; END IF;

  UPDATE awards a SET source_url = CASE a.year WHEN 2024 THEN '{URL_2024}' WHEN 2025 THEN '{URL_2025}' END
    FROM regexp_split_to_table(rel, E'\\n') l
   WHERE a.id = split_part(l, '|', 1)::bigint AND a.year = split_part(l, '|', 2)::int
     AND a.source_id = 'best-chef-awards' AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> {len(rel)} THEN RAISE EXCEPTION 'award rows updated: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', {n24},
          'source-url:source-url-best-chef-2024-2025-2026-11-01 | {n24} Best Chef Awards 2024 rows get the 2024 results page {URL_2024} '
          || '(Dubai 2024); each row pairs to one knife card of the same knife count (read Nov 1 2026, pairs in docs/best-chef-urls-build/) '
          || '| 15879 keeps the 2024 list PDF URL | Ben "items 1 & 2 first" Nov 1 00:47 ET')
  RETURNING id INTO v_lid;
  IF v_lid <> {EXPECT['ledger']+1} THEN RAISE EXCEPTION 'ledger id 2024 %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', {n25},
          'source-url:source-url-best-chef-2024-2025-2026-11-01 | {n25} Best Chef Awards 2025 rows get the 2025 results page {URL_2025} '
          || '(Milan 2025); each row pairs to one knife card of the same knife count (read Nov 1 2026) '
          || '| held, no URL: 3453 Flores Raras, 15690 Ensue 2-Knife, 15727 8 1/2 Otto e Mezzo Macau, 15997 Fo''ao Vaperse Hotel, 16190 The Fellas '
          || '| Ben "items 1 & 2 first" Nov 1 00:47 ET')
  RETURNING id INTO v_lid;
  IF v_lid <> {EXPECT['ledger']+2} THEN RAISE EXCEPTION 'ledger id 2025 %', v_lid; END IF;

  -- post-checks
  IF (SELECT count(*) FROM awards) <> {EXPECT['awards']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL) <> 5
    THEN RAISE EXCEPTION 'best-chef rows without URL after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL
         AND id NOT IN ({', '.join(map(str, HOLD))})) <> 0 THEN RAISE EXCEPTION 'held rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year = 2024 AND source_url = '{URL_2024}') <> {n24}
    THEN RAISE EXCEPTION '2024 URL rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year = 2025 AND source_url = '{URL_2025}') <> {n25}
    THEN RAISE EXCEPTION '2025 URL rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {EXPECT['audit_max']}) <> {len(rel)} THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {EXPECT['audit_max']} AND table_name = 'awards' AND action = 'UPDATE'
         AND (old_row - 'source_url') = (new_row - 'source_url') AND old_row->>'source_url' IS NULL
         AND new_row->>'source_url' IN ('{URL_2024}', '{URL_2025}')) <> {len(rel)}
    THEN RAISE EXCEPTION 'audit awards (source_url only)'; END IF;
END
$do$;
COMMIT;
"""
open('../source-url-best-chef-2024-2025-2026-11-01.sql', 'w', encoding='utf-8').write(sql)
print('rows', len(rel), '2024', n24, '2025', n25, 'relay sha256', relay_sha)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), 'lines', sql.count('\n'))
