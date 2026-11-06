#!/usr/bin/env python3
"""Group D Sweden, step 2: closure of JH matbar (Ystad), moving to Malmo. Model: docs/michelin-e-2026-11-06/build_sql.py (closure part). One transaction.
Run from this folder: python3 build_closure.py [approval] [scratch]"""
import hashlib, sys
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'; SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'closure-michelin-d-sweden-jh-matbar-2026-11-06'
V = 've_7c9cd89dc7'; OSLO = 'ci_d5e7c73654'; CAP = 'https://guide.michelin.com/fi/en/article/michelin-guide-ceremony/new-good-value-bib-gourmand-restaurants-nordic-countries-denmark-finland-iceland-norway-sweden'
SITE = 'https://jhmatbar.se/'
CF = md5(f"{V}|JH matbar|active|{OSLO}")
B = dict(v=11831, va=11511, vc=320, a=29052, last=36223, sum=11511, ci=3344, oslo=1, led=319, ledm=373, au=129093, aum=134922)
AUD = 'cities:UPDATE=1,listings:UPDATE=1,venues:UPDATE=1'
led = (f"('michelin','award',1,'closure:{KEY} | venue {V} JH matbar (Ystad) closed: own site ({SITE}) thanks Ystad for five years, moves to Malmo, reopening May 2027, no closing date given; "
       f"card jh-matbar 404 on Nov 6 2026; Nordic 2026 Bib article lists it | same treatment as Lasai (closure with a reopening date): recheck May 2027 | "
       f"awards 13006 (2025) and 13007 (2026, article URL, ledger 373) stay, slug stays, no redirect | Ystad venues_count 1 to 0 | {APPROVAL}')")
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group D Sweden, step 2. {APPROVAL}. This file runs only after Ben's "go".
-- 1 closure: JH matbar {V} (Ystad). Status closed, listing unpublished, Ystad venues_count 1 to 0. Recheck May 2027 (Malmo reopening).
-- Award rows 13006 and 13007 stay. Slug stays. Price stays. No redirect.
-- Evidence: own site jhmatbar.se: leaves Ystad after five years, Malmo, reopening May 2027; card 404 Nov 6 2026.
-- Expected after: venues {B['v']} (active {B['va']-1}, closed {B['vc']+1}); awards {B['a']}; cities sum {B['sum']-1}; Ystad {B['oslo']-1}; ledger {B['led']+1} rows; audit_log +3.
BEGIN;
DO $load$
DECLARE
  n bigint; s text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id) FROM venues v WHERE v.id='{V}') IS DISTINCT FROM '{CF}' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='{V}') <> 1 OR (SELECT count(*) FROM listings WHERE venue_id='{V}' AND published) <> 1 THEN RAISE EXCEPTION 'listing before'; END IF;
  IF (SELECT string_agg(id||'|'||source_id||'|'||year||'|'||category||'|'||coalesce(source_url,'-'), ',' ORDER BY id) FROM awards WHERE venue_id='{V}')
     IS DISTINCT FROM '13006|michelin|2025|Bib Gourmand|-,13007|michelin|2026|Bib Gourmand|{CAP}' THEN RAISE EXCEPTION 'awards of venue'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT venues_count FROM cities WHERE id='{OSLO}') <> {B['oslo']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- WRITE: start
  UPDATE venues SET status='closed' WHERE id='{V}' AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'closure'; END IF;
  UPDATE listings SET published=false WHERE venue_id='{V}' AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'unpublish'; END IF;
  UPDATE cities SET venues_count={B['oslo']-1} WHERE id='{OSLO}' AND venues_count={B['oslo']}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ystad'; END IF;
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
open(f"{SCRATCH}/dry-se-closure.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'venue fp', CF)
