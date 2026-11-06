#!/usr/bin/env python3
"""Build the Michelin South Korea 2026 label load file. No retyped values.
Args: approval text, scratch dir."""
import hashlib, os, re, sys
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2026-south-korea-2026-11-05'
RELAY_SHA = '6f43f5825ab792cd64a0a62e1f504004a6a670047ab536d446c337217efdf8a4'
STARS = 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-michelin-guide-seoul-busan-2026'
DATE = 'https://guide.michelin.com/kr/en/article/michelin-guide-ceremony/2026-save-the-date'
rel = open('relay-kr-2026-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(rel.encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().split('\n'):
    p = l.split('|'); live[p[1]] = dict(v=p[0], a=p[1], cat=p[2], y=p[3], ci=p[4], st=p[6], url=p[9], name='|'.join(p[10:]))
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv').read().split('\n')}
RLL = []; seen = set()
for l in rel.split('\n'):
    x = l.split(' | '); path = x[1].split('/restaurant/')[1]; _, v, a, _h = pairs[path]; lv = live[a]
    assert lv['v'] == v and lv['cat'] == x[0] and lv['y'] == '2025' and lv['st'] == 'active'
    RLL.append(f"{a}|{v}|{x[0]}|https://guide.michelin.com{x[1]}"); seen.add(a)
assert len(RLL) == 117 and seen == set(live)
RLL.sort(key=lambda r: int(r.split('|')[0])); RL = '\n'.join(RLL)
FPT = sorted(f"{a['a']}|{a['v']}|{a['cat']}|active|{a['ci']}|{a['url']}|{a['name']}" for a in live.values())
FP = hashlib.md5('\n'.join(sorted(FPT, key=lambda s: s.encode())).encode()).hexdigest()
RLM = hashlib.md5(RL.encode()).hexdigest()
B = dict(v=11691, va=11384, vc=307, a=28519, last=35690, s=13635, l=11691, lb=24789, ci=3321, sum=11384, led=264, ledm=318, au=126821, aum=132650, pr=7759, rd=35, al=222, m25=4600, m26=7073, m27=122)
nr = 117
J = f"relabel:{NAME}"
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin South Korea: the 2026 label. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the legacy rows hold the 2026 edition (ceremony Mar 5, 2026: {DATE}; stars: {STARS}). Relabel 117 rows 2025 -> 2026, source_url = the card (/us/en/). Retire 0.
-- Row 4389 (ARP) holds the /kr/en/ card URL today: it takes the /us/en/ card URL.
-- Source: docs/michelin-2026-south-korea-2026-11-05/relay-kr-2026-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No venue, rename, price, status, slug, address, geo or blurb change. No new row.
-- Expected after: awards {B['a']} (no new row); Michelin 2025/2026/2027 {B['m25']-nr}/{B['m26']+nr}/{B['m27']}; ledger {B['led']+1} rows; audit_log +{nr}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  n bigint; s text; fp text; aud_max bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{RLM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||coalesce(a.source_url,'')||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea') <> 117 THEN RAISE EXCEPTION 'South Korea Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows. Only row 4389 holds a URL.
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR (a.source_url IS NOT NULL AND a.id<>4389);
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  IF (SELECT source_url FROM awards WHERE id=4389) IS DISTINCT FROM 'https://guide.michelin.com/kr/en/busan-region/busan_1025838/restaurant/arp' THEN RAISE EXCEPTION 'row 4389 URL'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'{J} | rule 2.1.7: South Korea edition live at capture = 2026 (ceremony Mar 5, 2026, {DATE}) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 {RELAY_SHA} | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=71,One Star=35,Three Stars=1,Two Stars=10' THEN RAISE EXCEPTION 'South Korea 2026 %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2025) <> 0 THEN RAISE EXCEPTION 'South Korea 2025'; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='South Korea' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 117 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} THEN RAISE EXCEPTION 'venues, cities after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+1} THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE={nr}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(NAME + '.sql', 'w', encoding='utf8').write(sql)
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'fp', FP)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: relabel')
open(os.path.join(SCRATCH, 'dry.sql'), 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
