import json,hashlib,collections,sys
P=json.load(open('plan.json'));new=list(P['new'].values());aw=P['aw']
V={v['id']:v for v in json.load(open('venues.json'))};C=json.load(open('cities.json'))['cities'];bys={c['s']:c for c in C}
NAME='load-50-best-spirited-2026-2026-11-05'
APPROVAL=sys.argv[1] if len(sys.argv)>1 else 'DRAFT, choices not yet given'
NL='\n'.join(f"{n['name']}|{n['cs']}|{n['clab']}|{n['colab']}|{n['pub']}" for n in new)
CITY='galle|Galle|Sri Lanka|LK|1'
AL='\n'.join(f"{a['c']}|{a['rank'] or ''}|{'' if a['rank'] else a['cat']}|{a['v'][3:]}" for a in aw)
PM=hashlib.md5((NL+'\n#\n'+CITY+'\n#\n'+AL).encode()).hexdigest()
IDM=hashlib.md5('\n'.join(sorted(n['id'] for n in new)).encode()).hexdigest()
SRC={'wb':'worlds-50-best-bars','ab':'asia-50-best-bars','wr':'worlds-50-best-restaurants','sp':'spirited-awards'}
AWM=hashlib.md5('\n'.join(sorted(f"{a['v']}|{SRC[a['c']]}|{a['rank'] or ''}|{a['cat']}|{a['url']}" for a in aw)).encode()).hexdigest()
live=sorted(set(a['v'] for a in aw)-set(n['id'] for n in new))
fp=hashlib.md5('\n'.join(f"{i}|{V[i]['name']}|{V[i]['st']}|{V[i]['cid']}" for i in live).encode()).hexdigest()
upd=collections.Counter(n['cs'] for n in new if n['cs'] in bys)
ids="','".join(live)
na=len(aw);nv=len(new);nu=len(upd);nl2=nv*2
cnt=collections.Counter(a['c'] for a in aw);lab=collections.Counter(n['pub'] for n in new)
# ledger rows
J=f"cleanup:{NAME}"
led=[]
for c,u in (('wb','https://www.the50.com/bars/best-in-the-world/list/1-50'),('ab','https://www.the50.com/bars/best-in-asia/list/1-50'),('wr','https://www.the50.com/restaurants/best-in-the-world/list/1-50'),('sp','https://talesofthecocktail.org/tales-of-the-cocktail-foundation-announces-2026-spirited-awards-winners/')):
    led.append(f"('{SRC[c]}','award',{cnt[c]},'{J} | 2026 edition, open item 1 | {u} | {APPROVAL}')")
for p,c in lab.items():
    led.append(f"('{p}','city_label',{c*2},'{J} | city labels of {c} new venues | {APPROVAL}')")
nled=len(led)
B=dict(v=11595,va=11292,vc=303,a=27481,s=13539,l=11595,lb=24597,ci=3318,sum=11292,led=243,au=124829,aum=130658,pr=7759,rd=35,al=222)
sql=f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Open item 1 of handoff-launch-list-radar-done-2026-11-05. {APPROVAL}. This file runs only after Ben's "go".
-- {na} new award rows: World's 50 Best Bars 2026 {cnt['wb']}, Asia's 50 Best Bars 2026 {cnt['ab']}, World's 50 Best Restaurants 2026 {cnt['wr']}, Spirited Awards 2026 {cnt['sp']}. {nv} new venues (all bar, active, published). 1 new city (Galle).
-- Evidence: 50-best-spirited-2026-evidence-2026-11-05.csv. No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl2}; cities {B['ci']+1}, sum {B['sum']+nv}; ledger {B['led']+nled} rows; audit_log +{na+1+nu+nv*3+nl2} ({B['au']+na+1+nu+nv*3+nl2} rows).
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
  WITH r AS (SELECT split_part(x,'|',1) name, split_part(x,'|',2) city_slug, split_part(x,'|',3) clab, split_part(x,'|',4) colab, split_part(x,'|',5) pub FROM regexp_split_to_table(nl,E'\\n') x),
       q AS (SELECT r.*, trim(both '-' from regexp_replace(lower(f_unaccent(r.name)),'[^a-z0-9]+','-','g')) slug FROM r),
       w AS (SELECT q.*, 've_'||left(md5(q.city_slug||':'||q.slug),10) id, coalesce(c.id,'ci_'||left(md5(q.city_slug),10)) city_id, c.id IS NULL is_new FROM q LEFT JOIN cities c ON c.slug=q.city_slug),
       ca AS (SELECT split_part(x,'|',1) slug, split_part(x,'|',2) display, split_part(x,'|',3) country, split_part(x,'|',4) country_iso, split_part(x,'|',5)::int venues_count FROM regexp_split_to_table(cl,E'\\n') x),
       a0 AS (SELECT split_part(x,'|',1) c, nullif(split_part(x,'|',2),'')::int rank, split_part(x,'|',3) cat, 've_'||split_part(x,'|',4) venue_id FROM regexp_split_to_table(al,E'\\n') x),
       aa AS (SELECT c, rank, coalesce(nullif(cat,''),'No. '||rank) category, venue_id, CASE c WHEN 'sp' THEN 'https://talesofthecocktail.org/tales-of-the-cocktail-foundation-announces-2026-spirited-awards-winners/' ELSE 'https://www.the50.com/'||(CASE c WHEN 'wb' THEN 'bars/best-in-the-world' WHEN 'ab' THEN 'bars/best-in-asia' ELSE 'restaurants/best-in-the-world' END)||'/list/'||(CASE WHEN rank<=50 THEN '1-50' ELSE '51-100' END) END url FROM a0)
  SELECT jsonb_build_object(
    'new',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'city_id',city_id,'city_slug',city_slug,'slug',slug)) FROM w),
    'aw',(SELECT jsonb_agg(jsonb_build_object('venue_id',venue_id,'source',CASE c WHEN 'wb' THEN 'worlds-50-best-bars' WHEN 'ab' THEN 'asia-50-best-bars' WHEN 'wr' THEN 'worlds-50-best-restaurants' ELSE 'spirited-awards' END,'rank',rank,'category',category,'url',url)) FROM aa),
    'cities',(SELECT jsonb_agg(jsonb_build_object('id','ci_'||left(md5(slug),10),'slug',slug,'display',display,'country',country,'country_iso',country_iso,'venues_count',venues_count)) FROM ca),
    'upd',(SELECT jsonb_agg(jsonb_build_object('id',city_id,'plus',c)) FROM (SELECT city_id, count(*) c FROM w WHERE NOT is_new GROUP BY 1) y),
    'labels',(SELECT jsonb_agg(jsonb_build_object('venue_id',id,'label',l,'col',col,'pub',pub)) FROM (SELECT id, clab l, 'city_display' col, pub FROM w UNION ALL SELECT id, colab, 'country', pub FROM w) y)) INTO p;
  IF (SELECT md5(string_agg(e->>'id',E'\\n' ORDER BY e->>'id' COLLATE "C")) FROM jsonb_array_elements(p->'new') e) <> '{IDM}' THEN RAISE EXCEPTION 'venue ids'; END IF;
  IF (SELECT md5(string_agg(t,E'\\n' ORDER BY t COLLATE "C")) FROM (SELECT (e->>'venue_id')||'|'||(e->>'source')||'|'||coalesce(e->>'rank','')||'|'||(e->>'category')||'|'||(e->>'url') t FROM jsonb_array_elements(p->'aw') e) y) <> '{AWM}' THEN RAISE EXCEPTION 'award rows'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN (SELECT DISTINCT e->>'venue_id' FROM jsonb_array_elements(p->'aw') e);
  IF fp IS DISTINCT FROM '{fp}' THEN RAISE EXCEPTION 'live venue fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id IN ('worlds-50-best-bars','asia-50-best-bars','worlds-50-best-restaurants','spirited-awards')) <> 0 THEN RAISE EXCEPTION '2026 rows exist'; END IF;
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
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'cities %', n; END IF;
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
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) SELECT x.venue_id, x.label, x.col::label_column_t, x.pub, '2026 edition, new venue' FROM jsonb_to_recordset(p->'labels') x(venue_id text, label text, col text, pub text) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl2} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT x.venue_id, x.source, 2026, x.rank, x.category, NULL, x.url FROM jsonb_to_recordset(p->'aw') x(venue_id text, source text, rank int, category text, url text) ORDER BY x.source, x.rank, x.category;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||source_id||'|'||coalesce(rank::text,'')||'|'||category||'|'||source_url,E'\\n' ORDER BY venue_id||'|'||source_id||'|'||coalesce(rank::text,'')||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026) <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id='worlds-50-best-bars') <> {cnt['wb']} OR (SELECT count(*) FROM awards WHERE year=2026 AND source_id='asia-50-best-bars') <> {cnt['ab']} OR (SELECT count(*) FROM awards WHERE year=2026 AND source_id='worlds-50-best-restaurants') <> {cnt['wr']} OR (SELECT count(*) FROM awards WHERE year=2026 AND source_id='spirited-awards') <> {cnt['sp']} THEN RAISE EXCEPTION 'list counts after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl2} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+1} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+nled} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={na},cities:INSERT=1,cities:UPDATE={nu},city_label_source:INSERT={nl2},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
path='/home/claude/compasseats/docs/open-items-50-best-spirited-2026-2026-11-05/'+NAME+'.sql'
open(path,'w').write(sql)
print(hashlib.sha256(sql.encode()).hexdigest(),len(sql),'nu',nu,upd,'led',nled)
import re
do=sql[sql.index('DO $load$'):sql.index('COMMIT;')]
open('dry.sql','w').write(do)
print(len(do))
