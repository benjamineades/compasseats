#!/usr/bin/env python3
"""Build group D1: Faroe Islands, Iceland, New Zealand. URL only on 2026 rows. One transaction."""
import hashlib, json, re, sys
FP = sys.argv[1]; APPROVAL = sys.argv[2] if len(sys.argv) > 2 else 'DRAFT, choices not yet given'; SCRATCH = sys.argv[3] if len(sys.argv) > 3 else '.'
B = json.load(open('baseline.json')); md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'load-michelin-d1-2026-11-06'; SHA = '401ce717d7acd2459994d913b1fb6649a030fdf8d774ba37dda0d01503336170'; RELAY = 'relay-d1-2026-cards-2026-11-06.txt'
SCOPE = "c.country_iso IN ('FO','IS','NZ')"
NOR = 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards'
NZA = 'https://guide.michelin.com/jp/en/article/michelin-guide-ceremony/michelin-guide-new-zealand-2026-restaurant-selection'
dec = lambda s: re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
rel = open(RELAY, encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == SHA
cards = {}
for line in rel.split('\n'):
    g, cat, href, name, loc, pr, cc, dist, lab, guide, st = dec(line).split(' | ')
    assert lab == '2026' and st == '200'
    cards[href.split('/restaurant/')[1]] = dict(cat=cat, url='https://guide.michelin.com' + href)
pairs = [l.split('\t') for l in open('pairs.tsv').read().strip().split('\n')]
assert len(pairs) == 6 and {p[0] for p in pairs} == set(cards)
rl = sorted((int(a), f"{a}~{v}~{cards[s]['cat']}~{cards[s]['url']}") for s, a, v in pairs)
RL = '\n'.join(x for _, x in rl); N = len(rl)
led = [f"('michelin','award',4,'cleanup:{KEY} | rule 2.1.7: Nordic 2026, Jun 1, 2026, {NOR} | year stays 2026, source_url = the card (/us/en/), card label 2026 read Nov 6 2026, retire 0 | FO 1 (PAZ, card guide Denmark), IS 3 | relay sha256 {SHA} | {APPROVAL}')",
       f"('michelin','award',2,'cleanup:{KEY} | rule 2.1.7: New Zealand 2026, Jun 30, 2026, {NZA} | year stays 2026, source_url = the card (/us/en/), card label 2026 read Nov 6 2026, retire 0 | relay sha256 {SHA} | {APPROVAL}')"]
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group D1: Faroe Islands, Iceland, New Zealand. {APPROVAL}. This file runs only after Ben's "go".
-- 6 rows keep year 2026 and get the card URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: docs/michelin-d1-2026-11-06/{RELAY} sha256 {SHA}.
-- Expected after: awards {B['a']} unchanged; ledger {B['led']+2} rows; audit_log +6.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{md5(RL)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {N} THEN RAISE EXCEPTION 'urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM awards) <> {B['a']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND {SCOPE};
  IF n <> u1 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+2} THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > {B['aum']} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=6' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(KEY + '.sql', 'w', encoding='utf8').write(sql)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]; cut = do.index('  -- WRITE: start')
open(f"{SCRATCH}/dry-d1.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql))
