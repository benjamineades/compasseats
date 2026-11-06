#!/usr/bin/env python3
"""Build the group E file: Hungary, Saudi Arabia. URLs on the latest edition rows, 1 closure. One transaction."""
import hashlib, json, re, sys
FP = sys.argv[1]; APPROVAL = sys.argv[2] if len(sys.argv) > 2 else 'DRAFT, choices not yet given'; SCRATCH = sys.argv[3] if len(sys.argv) > 3 else '.'
B = json.load(open('baseline.json')); md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'load-michelin-e-2026-11-06'; SHA = '9a48f596d2a2eb3e9561f9620b734f1e44cc8929f995c5ff4776aa6a2ac8e831'; RELAY = 'relay-e-2026-list-pages-2026-11-06.txt'
SCOPE = "c.country_iso IN ('HU','SA')"
HU = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-hungary-2025-is-out'
SA = 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/saudi-arabia-inaugural-michelin-guide-restaurant-selection'
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
rel = open(RELAY, encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == SHA
cards = {}
for line in rel.split('\n'):
    g, cat, href, name, loc, pr, cc, dist = dec(line).split(' | ')
    cards[href.split('/restaurant/')[1]] = dict(g=g, cat=cat, url='https://guide.michelin.com' + href)
pairs = [l.split('\t') for l in open('pairs.tsv').read().strip().split('\n')]
assert len(pairs) == 32 and {p[0] for p in pairs} == set(cards)
rl = [(int(a), f"{a}~{v}~{cards[s]['cat']}~{cards[s]['url']}") for s, a, v in pairs]
rl += [(3286, f"3286~ve_b35292624c~Two Stars~{HU}"), (10693, f"10693~ve_b4cb7d747c~Bib Gourmand~{SA}")]
rl.sort(); RL = '\n'.join(x for _, x in rl); nr = len(rl); assert nr == 34
V = 've_b35292624c'; TATA = 'ci_49d02d55ad'
CF = md5(f"{V}|Platán Gourmet Restaurant|active|{TATA}")
led = [f"('michelin','award',23,'cleanup:{KEY} | rule 2.1.7: Hungary 2025, Oct 9, 2025, {HU} | year stays 2025, source_url = the card (/us/en/), retire 0 | award 3286 Platan Gourmet: card gone, closed Jul 31 2026, article URL | relay sha256 {SHA} | {APPROVAL}')",
 f"('michelin','award',11,'cleanup:{KEY} | rule 2.1.7: Saudi Arabia, Dec 15, 2025, {SA}: article says 2026, cards say 2025, label stays with the card | year stays 2025, source_url = the card (/us/en/), retire 0 | award 10693 Samia Dish: card gone, article URL | relay sha256 {SHA} | {APPROVAL}')"]
AUD = 'awards:UPDATE=34,cities:UPDATE=1,listings:UPDATE=1,venues:UPDATE=1'
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group E: Hungary, Saudi Arabia. {APPROVAL}. This file runs only after Ben's "go".
-- 34 rows keep year 2025 and get a URL: 32 cards, 2 articles (Platan Gourmet, Samia's Dish). Relabel 0. Retire 0. No new rows, no new venues.
-- 1 closure: Platan Gourmet {V}, closed Jul 31, 2026 (Portfolio.hu, Jun 4, 2026). Award row stays. Slug stays.
-- Source: docs/michelin-e-2026-11-06/{RELAY} sha256 {SHA}.
-- Expected after: venues {B['v']} (active {B['va']-1}, closed {B['vc']+1}); awards {B['a']}; cities sum {B['sum']-1}; Tata 1; ledger {B['led']+2} rows; audit_log +37.
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
  IF (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id) FROM venues v WHERE v.id='{V}') IS DISTINCT FROM '{CF}' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='{V}' AND published) <> 1 THEN RAISE EXCEPTION 'listing before'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT venues_count FROM cities WHERE id='{TATA}') <> 2 OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 34 THEN RAISE EXCEPTION 'urls %', n; END IF;
  UPDATE venues SET status='closed' WHERE id='{V}' AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'closure'; END IF;
  UPDATE listings SET published=false WHERE venue_id='{V}' AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'unpublish'; END IF;
  UPDATE cities SET venues_count=1 WHERE id='{TATA}' AND venues_count=2; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'tata'; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']-1} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']+1} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, u1, u2 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE};
  IF n <> 34 OR u1 <> 34 OR u2 <> 34 THEN RAISE EXCEPTION 'urls after % % %', n, u1, u2; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {B['sum']-1} THEN RAISE EXCEPTION 'sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+2} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > {B['aum']} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '{AUD}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(KEY + '.sql', 'w', encoding='utf8').write(sql)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]; cut = do.index('  -- WRITE: start')
open(f"{SCRATCH}/dry-e.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql))
