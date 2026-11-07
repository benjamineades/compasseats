#!/usr/bin/env python3
"""Group D Norway, step 2: closure of Bar Amour (Oslo). Model: docs/michelin-e-2026-11-06/build_sql.py (closure part). One transaction.
Run from this folder: python3 build_closure.py [approval] [scratch]"""
import hashlib, sys
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'; SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'closure-michelin-d-norway-bar-amour-2026-11-06'
V = 've_6b4eb76969'; OSLO = 'ci_8cfbfaefa5'; CAP = 'https://web.archive.org/web/20260601213429id_/https://guide.michelin.com/no/en/oslo-region/oslo/restaurant/bar-amour'
LIST = 'https://guide.michelin.com/fi/en/article/michelin-guide-ceremony/full-list-of-michelin-star-restaurants-in-the-nordic-countries'
SNL = 'https://snl.no/Bar_Amour'
CF = md5(f"{V}|Bar Amour|active|{OSLO}")
B = dict(v=11831, va=11512, vc=319, a=29052, last=36223, sum=11512, ci=3344, oslo=20, led=317, ledm=371, au=129055, aum=134884)
AUD = 'cities:UPDATE=1,listings:UPDATE=1,venues:UPDATE=1'
led = (f"('michelin','award',1,'closure:{KEY} | venue {V} Bar Amour (Oslo) closed: Michelin Nordic 2026 full star list marks it Now Closed ({LIST}); "
       f"Store norske leksikon (edited Aug 8 2026) says closed in the first half of 2026 ({SNL}); card bar-amour 404 on Nov 6 2026 | "
       f"awards 7099 (2025) and 7100 (2026, capture URL, ledger 371) stay, slug stays, no redirect | Oslo venues_count 20 to 19 | {APPROVAL}')")
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group D Norway, step 2. {APPROVAL}. This file runs only after Ben's "go".
-- 1 closure: Bar Amour {V} (Oslo). Status closed, listing unpublished, Oslo venues_count 20 to 19.
-- Award rows 7099 and 7100 stay. Slug stays. Price stays. No redirect.
-- Evidence: Michelin Nordic 2026 full star list "(Update: Now Closed)"; Store norske leksikon (Aug 8 2026): closed first half of 2026; card 404 Nov 6 2026.
-- Expected after: venues {B['v']} (active {B['va']-1}, closed {B['vc']+1}); awards {B['a']}; cities sum {B['sum']-1}; Oslo {B['oslo']-1}; ledger {B['led']+1} rows; audit_log +3.
BEGIN;
DO $load$
DECLARE
  n bigint; s text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id) FROM venues v WHERE v.id='{V}') IS DISTINCT FROM '{CF}' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='{V}') <> 1 OR (SELECT count(*) FROM listings WHERE venue_id='{V}' AND published) <> 1 THEN RAISE EXCEPTION 'listing before'; END IF;
  IF (SELECT string_agg(id||'|'||source_id||'|'||year||'|'||category||'|'||coalesce(source_url,'-'), ',' ORDER BY id) FROM awards WHERE venue_id='{V}')
     IS DISTINCT FROM '7099|michelin|2025|One Star|-,7100|michelin|2026|One Star|{CAP}' THEN RAISE EXCEPTION 'awards of venue'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT venues_count FROM cities WHERE id='{OSLO}') <> {B['oslo']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- WRITE: start
  UPDATE venues SET status='closed' WHERE id='{V}' AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'closure'; END IF;
  UPDATE listings SET published=false WHERE venue_id='{V}' AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'unpublish'; END IF;
  UPDATE cities SET venues_count={B['oslo']-1} WHERE id='{OSLO}' AND venues_count={B['oslo']}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'oslo'; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {led};
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']-1} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']+1} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {B['sum']-1} OR (SELECT venues_count FROM cities WHERE id='{OSLO}') <> {B['oslo']-1} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+1} THEN RAISE EXCEPTION 'ledger after'; END IF;
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
open(f"{SCRATCH}/dry-no-closure.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'venue fp', CF)
