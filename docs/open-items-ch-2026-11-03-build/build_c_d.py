import json,re,hashlib,csv
SQ=lambda s:"'"+s.replace("'","''")+"'"
rel=open('relay/relay-ch-2025-cards-archive.txt',encoding='utf-8').read().splitlines()
st="1550|2|20261004031851|https://guide.michelin.com/en/basel-stadt/basel/restaurant/stucki-tanja-grandits|Stucki - Tanja Grandits|Stucki - Tanja Grandits \\u2013 a Two Stars: Excellent cooking restaurant in the 2025 MICHELIN Guide Switzerland. The MICHELIN inspectors\\u2019 point of view, informatio"
assert not any(l.startswith('1550|') for l in rel)
rel.append(st); rel.sort(key=lambda l:int(l.split('|')[0]))
s='\n'.join(rel)+'\n'; open('relay/relay-ch-2025-cards-archive.txt','w',encoding='utf-8',newline='').write(s)
RH=hashlib.sha256(s.encode()).hexdigest()
rows={str(x['id']):x for x in json.load(open('ch2025p.json'))}
CATN={'3':'Three Stars','2':'Two Stars','1':'One Star','B':'Bib Gourmand'}
V=[];E=[]
got=set()
for l in rel:
    id,c,ts,o,h1,m=l.split('|',5); got.add(id)
    url=f"https://web.archive.org/web/{ts}id_/{o}"
    assert rows[id]['category']==CATN[c]
    V.append((int(id),rows[id]['venue_id'],CATN[c],url))
    E.append([id,rows[id]['venue_id'],rows[id]['name'],rows[id]['display'],CATN[c],'CAPTURE',ts,url,re.sub(r'\\u([0-9a-f]{4})',lambda x:chr(int(x.group(1),16)),h1)])
for id,x in rows.items():
    if id not in got: E.append([id,x['venue_id'],x['name'],x['display'],x['category'],'NO CAPTURE','','',x.get('path') or 'no card path'])
E.sort(key=lambda r:int(r[0]))
w=csv.writer(open('url-evidence-ch-2025.csv','w',newline='',encoding='utf-8'));w.writerow('award_id,venue_id,venue,city,category,result,capture_ts,source_url,card_name_or_path'.split(','));w.writerows(E)
N=len(V); FP=hashlib.md5('\n'.join(f"{a}|{b}|{c}|{d}" for a,b,c,d in V).encode()).hexdigest()
assert len({v[3] for v in V})==N
print(N,FP,RH, sum(1 for e in E if e[5]=='NO CAPTURE'))
vals=",\n    ".join(f"({a},{SQ(b)},{SQ(c)},{SQ(d)})" for a,b,c,d in V)
job=f"url:michelin-2025-switzerland-cards | Swiss open item 4: source_url on {N} legacy Michelin 2025 rows (CH and LI) from web.archive.org captures of the venue cards | window Oct 20 2025 (ceremony) to Oct 22 2026 (before the 2026 Bib list) | meta of each capture names the 2025 guide and the row category | relay docs/open-items-ch-2026-11-03-build/relay-ch-2025-cards-archive.txt sha256 {RH} | no capture for {225-N} rows, gap stays"
C=f"""-- source-url-michelin-2025-switzerland-cards.sql
-- CompassEats, Nov 3 2026. Swiss open item 4. Population: 225 Michelin 2025 rows on CH and LI venues with no source_url.
-- {N} rows get the archive id_ URL of their own card. {225-N} rows have no capture in the window and stay blank.
-- Run after slugs-letters-removed-2026-11-03.sql. Awards count does not change.
-- Expected after: Michelin 2025 no URL {3212-N}; ledger 195 rows, last id 249; audit +{N} ({119848+N} rows, last id {125677+N}).
BEGIN;
DO $do$
DECLARE n int; x bigint; s text; aud_max bigint; aud_n bigint; led_n bigint; led_max bigint;
BEGIN
  IF (SELECT count(*) FROM awards) <> 25324 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3212 THEN RAISE EXCEPTION 'no URL before'; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger; IF led_n <> 194 OR led_max <> 248 THEN RAISE EXCEPTION 'ledger before % / %', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log; IF aud_n <> 119848 OR aud_max <> 125677 THEN RAISE EXCEPTION 'audit before % / %', aud_n, aud_max; END IF;
  SELECT md5(string_agg(t.id||'|'||t.vid||'|'||t.cat||'|'||t.url, E'\\n' ORDER BY t.id)), count(*) INTO s, x FROM (VALUES
    {vals}
  ) t(id,vid,cat,url);
  IF s <> '{FP}' OR x <> {N} THEN RAISE EXCEPTION 'plan fingerprint % / %', s, x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN (VALUES
    {vals}
  ) t(id,vid,cat,url) ON a.id=t.id AND a.venue_id=t.vid AND a.category=t.cat AND a.source_id='michelin' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF x <> {N} THEN RAISE EXCEPTION 'rows that match the plan %', x; END IF;

  UPDATE awards a SET source_url=t.url FROM (VALUES
    {vals}
  ) t(id,vid,cat,url) WHERE a.id=t.id AND a.venue_id=t.vid AND a.category=t.cat AND a.source_id='michelin' AND a.year=2025 AND a.source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {N} THEN RAISE EXCEPTION 'updated %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin','award',{N},{SQ(job)});

  IF (SELECT count(*) FROM awards) <> 25324 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> {3212-N} THEN RAISE EXCEPTION 'no URL after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 195 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max; IF x <> {N} THEN RAISE EXCEPTION 'audit %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max AND table_name='awards' AND action='UPDATE' AND old_row->>'source_url' IS NULL AND new_row->>'source_url' LIKE 'https://web.archive.org/web/%id_/https://guide.michelin.com/%' AND (old_row-'source_url')=(new_row-'source_url');
  IF x <> {N} THEN RAISE EXCEPTION 'audit only source_url %', x; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open('build/source-url-michelin-2025-switzerland-cards.sql','w',encoding='utf-8').write(C)
d=open('build/draft-cheval-blanc-blurb-v2.txt',encoding='utf-8').read()
sh=re.search(r'^short: (.*)$',d,re.M).group(1); lo=re.search(r'^long: (.*)$',d,re.M).group(1)
src=["https://guide.michelin.com/us/en/basel-stadt/basel/restaurant/cheval-blanc-by-peter-knogl","https://www.myswitzerland.com/en-ca/experiences/food-wine/restaurant/cheval-blanc-by-peter-knogl/","https://www.swissdeluxehotels.com/stories/gourmet/spoons-full-of-happyness/"]
stext=json.dumps(src)
newmd5=hashlib.md5(f"{sh}|{lo}|option_b|2|rewritten|{stext}".encode()).hexdigest()
ab=119848+N; am=125677+N
D=f"""-- rewrite-blurb-cheval-blanc-v2.sql
-- CompassEats, Nov 3 2026. Swiss open item 3. Blurb of Cheval Blanc by Peter Knogl ve_46e15d96d7: version 2, status rewritten, 3 source URLs (Forum precedent).
-- Run after source-url-michelin-2025-switzerland-cards.sql. Database only: Sheet, ImportOptionB.gs and venues.chef do not change. No ledger row (Forum precedent).
-- Expected after: blurbs 142 (rewritten 2, needs_rewrite 140); audit +1 ({ab+1} rows, last id {am+1}).
BEGIN;
DO $do$
DECLARE s text; x bigint; n int;
BEGIN
  IF (SELECT count(*) FROM audit_log) <> {ab} OR (SELECT max(id) FROM audit_log) <> {am} THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 249 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM blurbs WHERE status='rewritten') <> 1 THEN RAISE EXCEPTION 'blurbs before'; END IF;
  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||coalesce(sources::text,'NULL')) INTO s FROM blurbs WHERE venue_id='ve_46e15d96d7';
  IF s IS DISTINCT FROM '378f706f785ca52a94de31fd95536a47' THEN RAISE EXCEPTION 'old row md5 %', s; END IF;

  UPDATE blurbs SET short={SQ(sh)},
    long={SQ(lo)},
    version=2, status='rewritten', sources={SQ(stext)}::jsonb
   WHERE venue_id='ve_46e15d96d7';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'updated %', n; END IF;

  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||sources::text) INTO s FROM blurbs WHERE venue_id='ve_46e15d96d7';
  IF s IS DISTINCT FROM '{newmd5}' THEN RAISE EXCEPTION 'new row md5 %', s; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM blurbs WHERE status='rewritten') <> 2 THEN RAISE EXCEPTION 'blurbs after'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>{am} AND table_name='blurbs' AND action='UPDATE' AND row_pk='ve_46e15d96d7'; IF x <> 1 THEN RAISE EXCEPTION 'audit %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>{am}; IF x <> 1 THEN RAISE EXCEPTION 'audit total %', x; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open('build/rewrite-blurb-cheval-blanc-v2.sql','w',encoding='utf-8').write(D)
# dry run text for C with current counts: first SELECT-part only
pre=C[C.index('DO $do$'):C.index('  UPDATE awards a SET')]
pre=pre.replace("aud_n <> 119848 OR aud_max <> 125677","aud_n <> 119764 OR aud_max <> 125593")
open('build/dryC.sql','w',encoding='utf-8').write(pre+"  UPDATE awards a SET source_url=NULL WHERE a.id=-1;\nEND\n$do$;")
print(len(pre))
