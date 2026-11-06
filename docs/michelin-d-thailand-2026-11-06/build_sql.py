#!/usr/bin/env python3
"""Build group D Thailand: card URL on the 178 Michelin rows labelled 2026. URL only. One transaction.
Usage: python3 build_sql.py <scope_fp> [approval] [scratch]
Inputs: baseline.json, relay-th-2026-cards-2026-11-06.txt (card read), ../michelin-2026-thailand-2026-11-05/pairs.tsv (Nov 5 plan)."""
import hashlib, json, re, sys
FP = sys.argv[1]; APPROVAL = sys.argv[2] if len(sys.argv) > 2 else 'DRAFT, choices not yet given'; SCRATCH = sys.argv[3] if len(sys.argv) > 3 else '.'
B = json.load(open('baseline.json')); md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'load-michelin-d-thailand-2026-11-06'; RELAY = 'relay-th-2026-cards-2026-11-06.txt'
SHA = open('relay.sha256').read().split()[0]
SCOPE = "c.country_iso = 'TH'"
CER = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-thailand-2026'
dec = lambda s: re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
rel = open(RELAY, encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == SHA
cards = {}
for line in rel.split('\n'):
    cat, href, name, loc, pr, lab, guide, st, final, closed = dec(line).split(' | ')
    assert lab == '2026' and guide == 'Thailand' and st == '200' and final == href and closed == '-', line
    cards[href.split('/restaurant/')[1]] = dict(cat=cat, url='https://guide.michelin.com' + href, name=name)
assert len(cards) == 180
pairs = [l.split('\t') for l in open('../michelin-2026-thailand-2026-11-05/pairs.tsv', encoding='utf8').read().strip().split('\n')]
assert len(pairs) == 180 and {p[0] for p in pairs} == set(cards)
use = [p for p in pairs if p[3] in ('exact', 'hand')]
assert len(use) == 178 and len({p[2] for p in use}) == 178
rl = sorted((int(a), f"{a}~{v}~{cards[s]['cat']}~{cards[s]['url']}") for s, v, a, how in use)
RL = '\n'.join(x for _, x in rl); N = len(rl)
led = [f"('michelin','award',{N},'cleanup:{KEY} | rule 2.1.7: Thailand 2026, ceremony Nov 27, 2025, {CER} | year stays 2026, source_url = the card (/us/en/), all 180 card labels 2026 read Nov 6 2026, retire 0 | Ben 5A Nov 6 (replaces Nov 5 decision 2) | relay sha256 {SHA} | {APPROVAL}')"]
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group D Thailand. {APPROVAL}. This file runs only after Ben's "go".
-- {N} rows keep year 2026 and get the card URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: docs/michelin-d-thailand-2026-11-06/{RELAY} sha256 {SHA}.
-- Expected after: awards {B['a']} unchanged; ledger {B['led']+1} rows; audit_log +{N}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{md5(RL)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((35538, 've_4e1280a372', '{cards['aksorn']['url']}'), (35539, 've_b877b4ed0e', '{cards['krua-apsorn-sam-sen']['url']}'))) <> 2 THEN RAISE EXCEPTION 'Nov 5 new rows'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {N} THEN RAISE EXCEPTION 'urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM awards) <> {B['a']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND {SCOPE};
  IF n <> 180 OR u1 <> 180 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+1} THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > {B['aum']} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE={N}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(KEY + '.sql', 'w', encoding='utf8').write(sql)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]; cut = do.index('  -- WRITE: start')
open(f"{SCRATCH}/dry-th.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
# evidence CSV: one line per card
import csv
liv = {}
with open('michelin-d-thailand-evidence-2026-11-06.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f); w.writerow(['card_slug', 'card_category', 'card_name', 'card_url', 'card_label', 'venue_id', 'award_id', 'pair_method', 'action'])
    NEWROWS = {'aksorn': ('ve_4e1280a372', '35538'), 'krua-apsorn-sam-sen': ('ve_b877b4ed0e', '35539')}  # Nov 5 write, ledger 311
    for s, v, a, how in sorted(pairs, key=lambda p: p[0]):
        if s in NEWROWS: v, a = NEWROWS[s]
        c = cards[s]; act = 'url set' if how in ('exact', 'hand') else 'url already set (Nov 5 new row)'
        w.writerow([s, c['cat'], c['name'], c['url'], '2026', v, a, how, act])
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'rows', N, 'plan md5', md5(RL))
