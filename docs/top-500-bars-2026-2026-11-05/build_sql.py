import hashlib,sys,collections
APPROVAL=sys.argv[1] if len(sys.argv)>1 else 'DRAFT, choices not yet given'
FP=sys.argv[2] if len(sys.argv)>2 else 'FP_NOT_SET'
NAME='load-top-500-bars-2026-2026-11-05'
live=[l.split() for l in open('plan_live.txt').read().strip().split('\n')]
new=[l.split('|') for l in open('plan_new.txt',encoding='utf8').read().strip().split('\n')]
NEWC={'antigua':('Antigua','Guatemala','GT'),'katowice':('Katowice','Poland','PL')}
ids={}
def slugify(n):
    import re,unicodedata
    s=unicodedata.normalize('NFKD',n.lower());s=''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+','-',s).strip('-')
for r,n,cs,lab,co in new:
    ids[int(r)]=hashlib.md5(f"{cs}:{slugify(n)}".encode()).hexdigest()[:10]
NL='\n'.join(f"{r}|{n}|{cs}|{lab}|{co}" for r,n,cs,lab,co in new)
ccount=collections.Counter(x[2] for x in new)
CITY='\n'.join(f"{s}|{d}|{c}|{i}|{ccount[s]}" for s,(d,c,i) in sorted(NEWC.items()))
AL='\n'.join(f"{r}|{v}" for r,v in live)
PM=hashlib.md5((NL+'\n#\n'+CITY+'\n#\n'+AL).encode()).hexdigest()
allr={int(r):v for r,v in live};allr.update(ids)
assert sorted(allr)==list(range(1,501)); assert len(set(allr.values()))==500
def page(r):
    for lo,hi,p in [(1,25,'1-25-2026'),(26,50,'26-50-2026'),(51,75,'51-75-2026'),(76,100,'76-100-2026'),(101,150,'150-101-2026'),(151,200,'200-151-2026'),(201,250,'copie-de-300-251-2026'),(251,300,'300-251-2026'),(301,350,'301-350-2026'),(351,400,'351-400-2026'),(401,450,'401-450-2026'),(451,500,'451-500-2026')]:
        if lo<=r<=hi: return p
URLCASE=" ".join(f"WHEN r<={h} THEN '{p}'" for h,p in [(25,'1-25-2026'),(50,'26-50-2026'),(75,'51-75-2026'),(100,'76-100-2026'),(150,'150-101-2026'),(200,'200-151-2026'),(250,'copie-de-300-251-2026'),(300,'300-251-2026'),(350,'301-350-2026'),(400,'351-400-2026'),(450,'401-450-2026'),(500,'451-500-2026')])
AWM=hashlib.md5('\n'.join(sorted(f"ve_{allr[r]}|{r}|No. {r}|https://www.top500bars.com/{page(r)}" for r in allr)).encode()).hexdigest()
IDM=hashlib.md5('\n'.join(sorted('ve_'+i for i in ids.values())).encode()).hexdigest()
nv=len(new);na=500;nl2=nv*2;ncn=len(NEWC)
nu=len([c for c in ccount if c not in NEWC])
B=dict(v=11623,va=11320,vc=303,a=27796,s=13567,l=11623,lb=24653,ci=3319,sum=11320,led=250,au=125306,aum=131135,pr=7759,rd=35,al=222,last=34967)
J=f"cleanup:{NAME}"
nled=2
tot=na+ncn+nu+nv*3+nl2
sql=f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Top 500 Bars 2026. {APPROVAL}. This file runs only after Ben's "go".
-- {na} new award rows, ranks 1-500, source_url = the publisher block page. {nv} new venues (all bar, active, published). {ncn} new cities (Antigua, Katowice).
-- Evidence: top-500-bars-2026-evidence-2026-11-05.csv. No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl2}; cities {B['ci']+ncn}, sum {B['sum']+nv}; ledger {B['led']+nled} rows; audit_log +{tot} ({B['au']+tot} rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan${NL}$plan$;
  cl text := $plan${CITY}$plan$;
  al text := $plan${AL}$plan$;
  p jsonb; n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(nl||E'\\n#\\n'||cl||E'\\n#\\n'||al) <> '{PM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  WITH r AS (SELECT split_part(x,'|',1)::int r, split_part(x,'|',2) name, split_part(x,'|',3) city_slug, split_part(x,'|',4) clab, split_part(x,'|',5) colab FROM regexp_split_to_table(nl,E'\\n') x),
       q AS (SELECT r.*, trim(both '-' from regexp_replace(lower(f_unaccent(r.name)),'[^a-z0-9]+','-','g')) slug FROM r),
       w AS (SELECT q.*, 've_'||left(md5(q.city_slug||':'||q.slug),10) id, coalesce(c.id,'ci_'||left(md5(q.city_slug),10)) city_id, c.id IS NULL is_new FROM q LEFT JOIN cities c ON c.slug=q.city_slug),
       ca AS (SELECT split_part(x,'|',1) slug, split_part(x,'|',2) display, split_part(x,'|',3) country, split_part(x,'|',4) country_iso, split_part(x,'|',5)::int venues_count FROM regexp_split_to_table(cl,E'\\n') x),
       a0 AS (SELECT split_part(x,'|',1)::int r, 've_'||split_part(x,'|',2) venue_id FROM regexp_split_to_table(al,E'\\n') x UNION ALL SELECT r, id FROM w),
       aa AS (SELECT r, venue_id, 'No. '||r category, 'https://www.top500bars.com/'||(CASE {URLCASE} END) url FROM a0)
  SELECT jsonb_build_object(
    'new',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'city_id',city_id,'city_slug',city_slug,'slug',slug)) FROM w),
    'aw',(SELECT jsonb_agg(jsonb_build_object('venue_id',venue_id,'rank',r,'category',category,'url',url)) FROM aa),
    'cities',(SELECT jsonb_agg(jsonb_build_object('id','ci_'||left(md5(slug),10),'slug',slug,'display',display,'country',country,'country_iso',country_iso,'venues_count',venues_count)) FROM ca),
    'upd',(SELECT jsonb_agg(jsonb_build_object('id',city_id,'plus',c)) FROM (SELECT city_id, count(*) c FROM w WHERE NOT is_new GROUP BY 1) y),
    'labels',(SELECT jsonb_agg(jsonb_build_object('venue_id',id,'label',l,'col',col)) FROM (SELECT id, clab l, 'city_display' col FROM w UNION ALL SELECT id, colab, 'country' FROM w) y)) INTO p;
  IF (SELECT md5(string_agg(e->>'id',E'\\n' ORDER BY e->>'id' COLLATE "C")) FROM jsonb_array_elements(p->'new') e) <> '{IDM}' THEN RAISE EXCEPTION 'venue ids'; END IF;
  IF (SELECT md5(string_agg(t,E'\\n' ORDER BY t COLLATE "C")) FROM (SELECT (e->>'venue_id')||'|'||(e->>'rank')||'|'||(e->>'category')||'|'||(e->>'url') t FROM jsonb_array_elements(p->'aw') e) y) <> '{AWM}' THEN RAISE EXCEPTION 'award rows'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN (SELECT 've_'||split_part(x,'|',2) FROM regexp_split_to_table(al,E'\\n') x);
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'live venue fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id='top-500-bars') <> 0 THEN RAISE EXCEPTION '2026 rows exist'; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id='top-500-bars' AND category IN (SELECT 'No. '||g FROM generate_series(1,500) g)) <> 500 THEN RAISE EXCEPTION 'categories'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text) WHERE x.id <> 've_'||left(md5(x.city_slug||':'||x.slug),10) OR trim(both '-' from regexp_replace(lower(f_unaccent(x.name)),'[^a-z0-9]+','-','g')) <> x.slug;
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text, city_id text) WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=x.id OR (v.city_id=x.city_id AND v.norm_key=norm_key(x.name))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.city_slug AND t.slug=x.slug);
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'cities') x(id text, slug text) WHERE x.id <> 'ci_'||left(md5(x.slug),10) OR EXISTS (SELECT 1 FROM cities c WHERE c.id=x.id OR c.slug=x.slug) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.slug AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(p->'upd') x(id text) JOIN cities c ON c.id=x.id) <> {nu} THEN RAISE EXCEPTION 'cities to update'; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT x.id, x.slug, x.display, x.country, x.country_iso, 'city'::city_kind, NULL, NULL, NULL, x.venues_count FROM jsonb_to_recordset(p->'cities') x(id text, slug text, display text, country text, country_iso text, venues_count int);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {ncn} THEN RAISE EXCEPTION 'cities %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + x.plus FROM jsonb_to_recordset(p->'upd') x(id text, plus int) WHERE c.id=x.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nu} THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT x.id, x.name, 'bar'::venue_category, x.city_id, 'active'::venue_status FROM jsonb_to_recordset(p->'new') x(id text, name text, city_id text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT x.id, 'eats', true FROM jsonb_to_recordset(p->'new') x(id text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', x.city_slug, x.slug, x.id, true FROM jsonb_to_recordset(p->'new') x(id text, city_slug text, slug text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) SELECT x.venue_id, x.label, x.col::label_column_t, 'top-500-bars', '2026 edition, new venue' FROM jsonb_to_recordset(p->'labels') x(venue_id text, label text, col text) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl2} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT x.venue_id, 'top-500-bars', 2026, x.rank, x.category, NULL, x.url FROM jsonb_to_recordset(p->'aw') x(venue_id text, rank int, category text, url text) ORDER BY x.rank;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('top-500-bars','award',{na},'{J} | 2026 edition, ranks 1-500 | https://www.top500bars.com/1-100-2026 | {APPROVAL}'),
    ('top-500-bars','city_label',{nl2},'{J} | city labels of {nv} new venues; country label from the cities table where the publisher gives a city only | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(t,E'\\n' ORDER BY t COLLATE "C")) FROM (SELECT venue_id||'|'||rank||'|'||category||'|'||source_url t FROM awards WHERE id > first_award AND year=2026 AND source_id='top-500-bars') y) <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id='top-500-bars') <> {na} OR (SELECT count(DISTINCT rank) FROM awards WHERE year=2026 AND source_id='top-500-bars') <> {na} THEN RAISE EXCEPTION 'list counts after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl2} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+ncn} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+nled} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={na},cities:INSERT={ncn},cities:UPDATE={nu},city_label_source:INSERT={nl2},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(NAME+'.sql','w',encoding='utf8').write(sql)
print('sha',hashlib.sha256(sql.encode()).hexdigest(),'len',len(sql),'nv',nv,'nu',nu,'audit',tot)
do=sql[sql.index('DO $load$'):sql.index('COMMIT;')]
# dry part ends just before first write
cut=do.index('  -- WRITE: cities')
dry=do[:cut]+"  INSERT INTO cities (id, slug, display, kind, venues_count) SELECT 'x','x','x','city'::city_kind,0;\nEND\n$load$;\n"
open('/tmp/claude-0/-home-claude/927f8974-94fb-5e1d-8e69-33b881817a09/scratchpad/dry.sql','w',encoding='utf8').write(dry)
print('dry len',len(dry))
