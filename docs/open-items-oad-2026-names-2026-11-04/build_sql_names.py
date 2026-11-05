import json,hashlib,sys
W='/tmp/claude-0/-home-claude/f987d52a-384f-5823-be87-7e85ce32e371/scratchpad/w/'
rows=json.load(open(W+'rows.json'))
BEN=sys.argv[1] if len(sys.argv)>1 else 'PENDING: Ben has not chosen'
NAME='rename-oad-2026-names-2026-11-04'
SRC={'S':'venue','SC':'venue','C':'michelin','X':'listing'}
R=sorted([r for r in rows if r['cls'] in SRC],key=lambda r:r['venue_id'])
for r in R:
    assert r['new_name'] and r['site_or_lead_url'], r
    for k in('live_name','new_name','site_or_lead_url'): assert '\t' not in r[k] and '\n' not in r[k] and '$p$' not in r[k]
T='\n'.join('\t'.join([r['venue_id'],r['live_name'],r['new_name'],SRC[r['cls']],r['site_or_lead_url']]) for r in R)
m=hashlib.md5(T.encode()).hexdigest(); N=len(R); MI=sum(r['cls']=='C' for r in R)
SL="trim(both '-' from regexp_replace(lower(f_unaccent(%s)),'[^a-z0-9]+','-','g'))"
HEAD=f"""-- {NAME}.sql  CompassEats, Nov 4 2026. Open item 2: rename batch. {N} renames with new canonical slugs. Old slugs stay non-canonical.
-- Choices: {BEN}
-- Evidence: names-evidence-2026-11-04.csv. Built by build_names.py, build_sql_names.py. One transaction.
"""
BODY=f"""DO $do$
DECLARE
  p text := replace($p$
{T}
$p$,E'\\r','');
  n int; n2 int; bid bigint; aud bigint; same int; flip int; r record; msg text;
BEGIN
  p := trim(both E'\\n' from p);
  IF md5(p) <> '{m}' THEN RAISE EXCEPTION 'plan md5 %, length %', md5(p), length(p); END IF;
  CREATE TEMP TABLE IF NOT EXISTS _x_never (i int) ON COMMIT DROP;
END $do$;
"""
GATES=f"""
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11288 OR (SELECT count(*) FROM venues WHERE status='closed')<>306 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM slugs)<>13444 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger)<>239 OR (SELECT max(id) FROM source_capture_ledger)<>293 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*),max(id) INTO n,aud FROM audit_log; IF n<>124351 OR aud<>130180 THEN RAISE EXCEPTION 'audit before % %',n,aud; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='{NAME}') THEN RAISE EXCEPTION 'batch key used'; END IF;
  WITH q AS (SELECT split_part(x,E'\\t',1) id,split_part(x,E'\\t',2) oldn FROM regexp_split_to_table(p,E'\\n') x)
    SELECT count(*) INTO n FROM q JOIN venues v ON v.id=q.id AND v.name=q.oldn; IF n<>{N} THEN RAISE EXCEPTION 'names moved, % of {N}',n; END IF;
  -- same new name twice in one city, or an equal key on another venue in the city
  WITH q AS (SELECT split_part(x,E'\\t',1) id,split_part(x,E'\\t',3) newn FROM regexp_split_to_table(p,E'\\n') x), w AS (SELECT q.id,q.newn,v.city_id,norm_key(q.newn) k FROM q JOIN venues v ON v.id=q.id)
    SELECT string_agg(w.newn||' / '||o.name||' '||o.id,'; ') INTO msg FROM w JOIN venues o ON o.city_id=w.city_id AND o.id<>w.id AND o.norm_key=w.k AND o.id NOT IN (SELECT id FROM q) WHERE w.k IS NOT NULL;
  IF msg IS NOT NULL THEN RAISE EXCEPTION 'name key clash: %',msg; END IF;
  WITH q AS (SELECT split_part(x,E'\\t',1) id,split_part(x,E'\\t',3) newn FROM regexp_split_to_table(p,E'\\n') x),
    w AS (SELECT q.id,q.newn,s.city_slug cs,{SL%'q.newn'} ns,s.slug os FROM q JOIN slugs s ON s.venue_id=q.id AND s.is_canonical AND s.property_id='eats')
    SELECT string_agg(w.newn||' -> '||w.cs||'/'||w.ns||' held by '||t.venue_id,'; ') INTO msg FROM w JOIN slugs t ON t.property_id='eats' AND t.city_slug=w.cs AND t.slug=w.ns AND t.venue_id<>w.id;
  IF msg IS NOT NULL THEN RAISE EXCEPTION 'slug clash: %',msg; END IF;
  WITH q AS (SELECT split_part(x,E'\\t',1) id,split_part(x,E'\\t',3) newn FROM regexp_split_to_table(p,E'\\n') x),
    w AS (SELECT {SL%'q.newn'} ns,s.city_slug cs,s.slug os,q.id FROM q JOIN slugs s ON s.venue_id=q.id AND s.is_canonical AND s.property_id='eats')
    SELECT count(*) FILTER (WHERE ns=os), count(*) FILTER (WHERE ns<>os AND EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=w.cs AND t.slug=w.ns AND t.venue_id=w.id)), count(*) FILTER (WHERE ns='') INTO same,flip,n FROM w;
  IF n<>0 THEN RAISE EXCEPTION 'empty slug %',n; END IF;
  WITH q AS (SELECT split_part(x,E'\\t',1) id,split_part(x,E'\\t',3) newn FROM regexp_split_to_table(p,E'\\n') x)
    SELECT count(*) INTO n FROM redirects rd JOIN slugs s ON s.venue_id IN (SELECT id FROM q) AND s.is_canonical JOIN q ON q.id=s.venue_id WHERE rd.from_path='/'||s.city_slug||'/'||{SL%'q.newn'};
  IF n<>0 THEN RAISE EXCEPTION 'redirect clash %',n; END IF;
  SELECT count(*) INTO n2 FROM blurbs WHERE venue_id IN (SELECT split_part(x,E'\\t',1) FROM regexp_split_to_table(p,E'\\n') x);
"""
DECL=f"""DO $do$
DECLARE
  p text := replace($p$
{T}
$p$,E'\\r','');
  n int; n2 int; bid bigint; aud bigint; same int; flip int; ch int; r record; msg text; ln int:=0;
BEGIN
  p := trim(both E'\\n' from p);
  IF md5(p) <> '{m}' THEN RAISE EXCEPTION 'plan md5 %, length %', md5(p), length(p); END IF;"""
WRITE=f"""
  -- WRITE
  INSERT INTO rename_batches (batch_key,status,note) VALUES ('{NAME}','staged',$n$Open item 2: {BEN}$n$) RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  ch:=0;
  FOR r IN SELECT split_part(x,E'\\t',1) vid,split_part(x,E'\\t',2) oldn,split_part(x,E'\\t',3) newn,split_part(x,E'\\t',4) src,split_part(x,E'\\t',5) url FROM regexp_split_to_table(p,E'\\n') x LOOP
    ln:=ln+1;
    INSERT INTO rename_rows (batch_id,line,venue_id,expected_name,new_name,source_id,source_url,verdict,detail)
      SELECT bid,ln,v.id,v.name,r.newn,r.src,r.url,'rename',jsonb_build_object('live_name',v.name,'city_id',v.city_id) FROM venues v WHERE v.id=r.vid AND v.name=r.oldn;
    GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename row %',r.vid; END IF;
    UPDATE venues SET name=r.newn WHERE id=r.vid AND name=r.oldn; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename %',r.vid; END IF;
    DECLARE cs text; os text; ns text := {SL%'r.newn'}; BEGIN
      SELECT city_slug,slug INTO cs,os FROM slugs WHERE property_id='eats' AND venue_id=r.vid AND is_canonical;
      IF ns<>os THEN
        ch:=ch+1;
        UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug=cs AND slug=os AND is_canonical;
        INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats',cs,ns,r.vid,true)
          ON CONFLICT (property_id,city_slug,slug) DO UPDATE SET is_canonical=true WHERE slugs.venue_id=EXCLUDED.venue_id;
        GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'slug %',r.vid; END IF;
      END IF;
    END;
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied',applied_at=now() WHERE id=bid AND status='staged'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'batch %',n; END IF;
  INSERT INTO source_capture_ledger (publisher,field_type,items,job) VALUES ('michelin','name',{MI},$j$rename-apply:{NAME} | Michelin card names, read Nov 4 | {BEN}$j$);
  -- POST
  IF ch<>{N}-same THEN RAISE EXCEPTION 'slug change % same %',ch,same; END IF;
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM price)<>7759 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM slugs)<>13444+ch-flip THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs s ON s.venue_id=v.id AND s.is_canonical GROUP BY v.id HAVING count(s.slug)<>1) THEN RAISE EXCEPTION 'canonical slugs'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id>aud AND table_name='venues' AND action='UPDATE')<>{N} THEN RAISE EXCEPTION 'audit venues'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 THEN RAISE EXCEPTION 'closed published'; END IF;
  RAISE NOTICE 'done: batch %, renames {N}, slug changes %',bid,ch;
END $do$;
"""
open(NAME+'.sql','w',encoding='utf-8').write(HEAD+'BEGIN;\n'+DECL+GATES+WRITE+'COMMIT;\n')
DRY=DECL+GATES+f"  RAISE EXCEPTION 'dry stop: rows {N}, slug same %, flip %, blurbs %',same,flip,n2;\nEND $do$;\n"
open(W+'dry_names.sql','w',encoding='utf-8').write(DRY)
print(N,MI,m,len(DRY))
