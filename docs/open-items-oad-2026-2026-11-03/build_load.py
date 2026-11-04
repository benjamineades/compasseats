import json,re,hashlib,collections
R=json.load(open('final.json'))
B='/root/.claude/projects/-home-claude/5a08f972-258d-53b8-b0cf-dd5d1dc7e41d/tool-results/mcp-Supabase_Read-execute_sql-1793758654414.txt'
s=open(B).read();o=json.loads(s);s=o['result'] if isinstance(o,dict) else o[0]['text']
if s.startswith('{'): s=json.loads(s)['result']
L=json.JSONDecoder().raw_decode(s[s.index('[{'):])[0]
V={v['id']:v for v in L};print('live',len(L))
G=('matched','city disagrees: same place','city disagrees: twin')
rows=[r for r in R if r['status_group'] in G]
assert len(rows)==1794
assert all(re.fullmatch(r've_[a-z0-9]{10}',r['live_venue_id']) for r in rows)
assert all(r['live_venue_id'] in V for r in rows)
old=json.load(open('venues.json'));ov={v['id']:v for v in old}
print('name/status changed since first read',[i for i in {r['live_venue_id'] for r in rows} if V[i]['name']!=ov[i]['name'] or V[i]['status']!=ov[i]['status']])
print('batch venues with an OAD 2026 row now',[(i,V[i]['name'],V[i]['oad26']) for i in {r['live_venue_id'] for r in rows} if V[i]['oad26']])
ids=sorted({r['live_venue_id'] for r in rows});print('distinct',len(ids))
LIT={}
for l in('europe','asia','japan'):
    rr=sorted([r for r in rows if r['list']==l],key=lambda r:r['rank'])
    LIT[l]=','.join(f"{r['rank']}:{r['live_venue_id'][3:]}" for r in rr)
    print(l,len(rr),len(LIT[l]),hashlib.md5(LIT[l].encode()).hexdigest())
fp=hashlib.md5('\n'.join(f"{i}|{V[i]['name']}|{V[i]['status']}|{V[i]['city_id']}" for i in ids).encode()).hexdigest();print('fp',fp)
nc=sum(1 for r in rows if V[r['live_venue_id']]['status']=='closed');print('closed rows',nc,'closed venues',len({r['live_venue_id'] for r in rows if V[r['live_venue_id']]['status']=='closed'}))
rowfp=hashlib.md5('\n'.join(sorted(f"{r['live_venue_id']}|{r['rank']}|https://www.oadguides.com/lists/{r['list']}/top-restaurants/2026" for r in rows)).encode()).hexdigest();print('rowfp',rowfp)
U='https://www.oadguides.com/lists/%s/top-restaurants/2026'
C={l:sum(1 for r in rows if r['list']==l) for l in LIT}
GO='Ben Nov 3 21:16 ET "1A, 2A, 3A, 4A, 5A, 6A"'
P="(SELECT 've_'||split_part(x,':',2) AS venue_id, split_part(x,':',1)::int AS rank, 'https://www.oadguides.com/lists/'||l||'/top-restaurants/2026' AS url FROM (SELECT 'europe' l, unnest(string_to_array(e,',')) x UNION ALL SELECT 'asia', unnest(string_to_array(a,',')) UNION ALL SELECT 'japan', unnest(string_to_array(j,','))) z) p"
sql=f"""-- load-oad-2026-europe-asia-japan-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open item 1, first write. {GO}. This file runs only after his "go".
-- 1,794 new OAD 2026 award rows on 1,789 live venues: Europe {C['europe']}, Asia {C['asia']}, Japan {C['japan']}. Each row: rank, category "No. N", list URL. No venue, status, city, slug or 2025 row changes.
-- 44 rows sit on closed venues (3A, stay closed and not published). 5 venues hold 2 rows (5A). Left out: 311 no live venue, 53 hold, 4 live city wrong, 1 already loaded (award 32495).
-- Evidence: oad-2026-europe-asia-japan-evidence-2026-11-03.csv. Row form in each list: rank:venue id without "ve_".
-- Expected after: awards 27,118; OAD 2026 rows 2,496; venues 11,336; ledger 214 rows; audit_log +1,794 (121,990 rows).
BEGIN;
DO $load$
DECLARE
  e text := '{LIT['europe']}';
  a text := '{LIT['asia']}';
  j text := '{LIT['japan']}';
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates: list text
  IF md5(e) <> '{hashlib.md5(LIT['europe'].encode()).hexdigest()}' OR md5(a) <> '{hashlib.md5(LIT['asia'].encode()).hexdigest()}' OR md5(j) <> '{hashlib.md5(LIT['japan'].encode()).hexdigest()}' THEN RAISE EXCEPTION 'list text'; END IF;
  IF (SELECT count(*) FROM _oad26) <> 1794 OR (SELECT count(DISTINCT venue_id) FROM _oad26) <> 1789 THEN RAISE EXCEPTION 'plan rows'; END IF;
  SELECT md5(string_agg(venue_id||'|'||rank||'|'||url, E'\\n' ORDER BY venue_id||'|'||rank||'|'||url COLLATE "C")) INTO fp FROM _oad26;
  IF fp <> '{rowfp}' THEN RAISE EXCEPTION 'row fingerprint %', fp; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN (SELECT venue_id FROM _oad26);
  IF fp IS DISTINCT FROM '{fp}' THEN RAISE EXCEPTION 'venue fingerprint %', fp; END IF;
  -- PRE gates: live state
  IF (SELECT count(*) FROM venues) <> 11336 OR (SELECT count(*) FROM venues WHERE status='active') <> 11042 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25324 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 702 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13184 OR (SELECT count(*) FROM listings) <> 11336 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM city_aliases) <> 222 OR (SELECT sum(venues_count) FROM cities) <> 11042 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 211 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 120196 OR aud_max <> 126025 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT count(*) FROM _oad26 o JOIN venues v ON v.id=o.venue_id WHERE v.status='closed') <> {nc} THEN RAISE EXCEPTION 'closed rows'; END IF;
  IF EXISTS (SELECT 1 FROM awards aw JOIN _oad26 o ON o.venue_id=aw.venue_id WHERE aw.source_id='oad' AND aw.year=2026) THEN RAISE EXCEPTION 'row exists'; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT venue_id, 'oad', 2026, rank, 'No. '||rank, NULL, url FROM _oad26 ORDER BY url, rank;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1794 THEN RAISE EXCEPTION 'insert %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', {C['europe']}, 'cleanup:load-oad-2026-europe-asia-japan-2026-11-03 | open item 1: new OAD 2026 rows, list prints 774 | {U%'europe'} | {GO}'),
    ('oad', 'award', {C['asia']}, 'cleanup:load-oad-2026-europe-asia-japan-2026-11-03 | open item 1: new OAD 2026 rows, list prints 590 | {U%'asia'} | {GO}'),
    ('oad', 'award', {C['japan']}, 'cleanup:load-oad-2026-europe-asia-japan-2026-11-03 | open item 1: new OAD 2026 rows, list prints 799; No. 773 already award 32495 | {U%'japan'} | {GO}');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 27118 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2496 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 1794 THEN RAISE EXCEPTION 'awards after'; END IF;
  SELECT md5(string_agg(venue_id||'|'||rank||'|'||source_url, E'\\n' ORDER BY venue_id||'|'||rank||'|'||source_url COLLATE "C")) INTO fp FROM awards WHERE id > first_award AND source_id='oad' AND year=2026 AND category='No. '||rank AND distinction IS NULL;
  IF fp <> '{rowfp}' THEN RAISE EXCEPTION 'rows after %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11336 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 OR (SELECT count(*) FROM slugs) <> 13184 OR (SELECT count(*) FROM listings) <> 11336 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT sum(venues_count) FROM cities) <> 11042 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 214 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=1794' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
sql=sql.replace("_oad26 o",P.replace(") p",") o")).replace("_oad26",P)
open('load-oad-2026-europe-asia-japan-2026-11-03.sql','w').write(sql)
print(len(sql),hashlib.sha256(sql.encode()).hexdigest())
