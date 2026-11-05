import json,hashlib,sys
P=json.load(open('plan.json'))
NAME='cleanup-oad-2026-holds-summer-palace-2026-11-03'
BEN=sys.argv[1] if len(sys.argv)>1 else 'PENDING: Ben has not chosen'
nl='\n'.join(P['nl']);al='\n'.join(P['al']);mv='\n'.join(f"{a}|{o}|{n}" for a,o,n in P['mv']);cl='\n'.join(f"{s}|{d}" for s,d in P['newc']);dv='\n'.join(P['ids'])
m=hashlib.md5('\n#\n'.join([nl,al,mv,cl,dv]).encode()).hexdigest()
ct={l:sum(1 for x in P['nl']+P['al'] if x.startswith(l+'|')) for l in 'eaj'}
N=len(P['nl']);NA=sum(1 for x in P['nl'] if x.split('|')[4]=='a');NC=N-NA;AW=N+len(P['al']);MV=len(P['mv']);D=len(P['ids']);CN=len(P['newc'])
V0,A0,C0,AW0,O26,O25,S0,L0,LB0,CI0,SUM0,LG0,AUD0,AUDM=11574,11275,299,27455,2833,2437,13422,11574,24555,3315,11275,225,124173,130002
V1=V0+N-D;A1=A0+NA-D;C1=C0+NC;AW1=AW0+AW;S1=S0+N-1;L1=L0+N-D;LB1=LB0+2*N-2;CI1=CI0+CN;SUM1=A1
cities=set(x.split('|')[3] for x in P['nl'] if x.split('|')[4]=='a')|{'paris'}
UPD=len(cities)
AUDN=AW+MV+CN+UPD+2+2*N+D+N+D+N+D+N
LG1=LG0+6
url="'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026'"
SLUG="trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',3))),'[^a-z0-9]+','-','g'))"
T=f"""-- {NAME}.sql
-- CompassEats, Nov 4 2026. Open items 1 and 2 of handoff-oad-2026-read-block-done. {BEN}. This file runs only after his "go".
-- {AW} new OAD 2026 rows ({N} on new venues, 1 Summer Palace on Hong Kong). {MV} OAD rows moved (Summer Palace 3, Pirouette 1). {N} new venues ({NA} active, {NC} closed). {D} venue deleted (Le Choubichou, 404, no redirect). {CN} new cities.
-- Evidence: oad-2026-holds-summer-palace-evidence-2026-11-03.csv. No price, address, geo or blurb.
-- Expected after: venues {V1:,} (active {A1:,}, closed {C1}); awards {AW1:,}; OAD 2026 {O26+AW:,}; OAD 2025 {O25:,}; slugs {S1:,}; listings {L1:,}; labels {LB1:,}; price 7,759; redirects 32; aliases 222; cities {CI1:,}, sum {SUM1:,}; ledger {LG1} rows; audit_log +{AUDN} ({AUD0+AUDN:,} rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$%%nl%%$plan$;
  al text := $plan$%%al%%$plan$;
  mv text := $plan$%%mv%%$plan$;
  cl text := $plan$%%cl%%$plan$;
  dv text := $plan$%%dv%%$plan$;
  n bigint; s text; aud_max bigint; first_award bigint; dl text[]; r record;
BEGIN
  -- PRE gates. A paste can turn line ends into CR LF, so remove CR before the check. The error gives the lengths.
  nl:=replace(nl,E'\\r',''); al:=replace(al,E'\\r',''); mv:=replace(mv,E'\\r',''); cl:=replace(cl,E'\\r',''); dv:=replace(dv,E'\\r','');
  IF md5(nl||E'\\n#\\n'||al||E'\\n#\\n'||mv||E'\\n#\\n'||cl||E'\\n#\\n'||dv) <> '{m}' THEN RAISE EXCEPTION 'plan text: lengths %, %, %, %, %', length(nl), length(al), length(mv), length(cl), length(dv); END IF;
  dl := regexp_split_to_array(dv,E'\\n');
  IF (SELECT count(*) FROM venues) <> {V0} OR (SELECT count(*) FROM venues WHERE status='active') <> {A0} OR (SELECT count(*) FROM venues WHERE status='closed') <> {C0} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {AW0} OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> {O26} OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> {O25} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {S0} OR (SELECT count(*) FROM listings) <> {L0} OR (SELECT count(*) FROM city_label_source) <> {LB0} OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 32 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {CI0} OR (SELECT sum(venues_count) FROM cities) <> {SUM0} OR (SELECT count(*) FROM source_capture_ledger) <> {LG0} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {AUD0} OR aud_max <> {AUDM} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.rank, E'\\n' ORDER BY a.id)) FROM awards a WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(mv,E'\\n') x)) <> '78cc39447db7e6a72e0c56d7bcd3190d' THEN RAISE EXCEPTION 'moved rows fingerprint'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id IN ('ve_54ab6673c8','ve_6a1064e62c','ve_3a0ba9fb7b')) <> 'b262339b21f292ecf386adc4ba4a8df8' THEN RAISE EXCEPTION 'live venues fingerprint'; END IF;
  -- Children of the deleted venue: 1 award through the moved row, 2 labels, 1 slug, 1 listing, nothing else.
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY(dl)) <> 1 OR (SELECT count(*) FROM city_label_source WHERE venue_id = ANY(dl)) <> 2 OR (SELECT count(*) FROM slugs WHERE venue_id = ANY(dl)) <> 1 OR (SELECT count(*) FROM listings WHERE venue_id = ANY(dl)) <> 1 THEN RAISE EXCEPTION 'children of deleted'; END IF;
  IF (SELECT (SELECT count(*) FROM price WHERE venue_id = ANY(dl))+(SELECT count(*) FROM addresses WHERE venue_id = ANY(dl))+(SELECT count(*) FROM geo WHERE venue_id = ANY(dl))+(SELECT count(*) FROM hours WHERE venue_id = ANY(dl))+(SELECT count(*) FROM photo_refs WHERE venue_id = ANY(dl))+(SELECT count(*) FROM blurbs WHERE venue_id = ANY(dl))+(SELECT count(*) FROM rename_rows WHERE venue_id = ANY(dl))) <> 0 THEN RAISE EXCEPTION 'other children of deleted'; END IF;
  IF EXISTS (SELECT 1 FROM redirects x JOIN slugs t ON t.venue_id = ANY(dl) AND x.to_path='/'||t.city_slug||'/'||t.slug) THEN RAISE EXCEPTION 'redirect points at a deleted venue'; END IF;
  -- New venue id, slug and clash rules
  SELECT count(*) INTO n FROM regexp_split_to_table(nl,E'\\n') x, LATERAL (SELECT {SLUG} sl) y WHERE EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',4) AND t.slug=y.sl) OR EXISTS (SELECT 1 FROM venues v WHERE v.id='ve_'||left(md5(split_part(x,'|',4)||':'||y.sl),10)) OR EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE c.slug=split_part(x,'|',4) AND v.norm_key=norm_key(split_part(x,'|',3)) AND NOT v.id = ANY(dl));
  IF n <> 0 THEN RAISE EXCEPTION 'new venue clash %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(cl,E'\\n') x WHERE EXISTS (SELECT 1 FROM cities c WHERE c.slug=split_part(x,'|',1) OR c.id='ci_'||left(md5(split_part(x,'|',1)),10)) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',1) AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  -- 2026 ranks free in each list
  SELECT count(*) INTO n FROM (SELECT split_part(x,'|',1) l, split_part(x,'|',2)::int rk FROM regexp_split_to_table(nl||E'\\n'||al,E'\\n') x) q JOIN awards a ON a.source_id='oad' AND a.year=2026 AND a.rank=q.rk AND a.source_url='https://www.oadguides.com/lists/'||(CASE q.l WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026';
  IF n <> 0 THEN RAISE EXCEPTION 'rank taken %', n; END IF;
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT 'ci_'||left(md5(split_part(x,'|',1)),10), split_part(x,'|',1), split_part(x,'|',2), 'Japan', 'JP', 'city'::city_kind, NULL, NULL, NULL, 0 FROM regexp_split_to_table(cl,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {CN} THEN RAISE EXCEPTION 'cities %', n; END IF;
  -- WRITE: new venues, listings, slugs, labels
  FOR r IN SELECT split_part(x,'|',3) name, split_part(x,'|',4) cs, split_part(x,'|',5) st, split_part(x,'|',6) clab, split_part(x,'|',7) colab, {SLUG} sl FROM regexp_split_to_table(nl,E'\\n') x LOOP
    INSERT INTO venues (id, name, category, city_id, status) SELECT 've_'||left(md5(r.cs||':'||r.sl),10), r.name, 'restaurant'::venue_category, c.id, (CASE r.st WHEN 'a' THEN 'active' ELSE 'closed' END)::venue_status FROM cities c WHERE c.slug=r.cs;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue % %', r.name, n; END IF;
    INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), 'eats', r.st='a');
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.sl, 've_'||left(md5(r.cs||':'||r.sl),10), true);
    WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES ('ve_'||left(md5(r.cs||':'||r.sl),10), r.clab, 'city_display'::label_column_t, 'oad', 'OAD 2026 holds'), ('ve_'||left(md5(r.cs||':'||r.sl),10), r.colab, 'country'::label_column_t, 'oad', 'OAD 2026 holds') RETURNING *)
      INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  END LOOP;
  -- WRITE: new OAD 2026 rows
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT q.vid, 'oad', 2026, q.rk, 'No. '||q.rk, NULL, q.url FROM (
      SELECT 've_'||left(md5(split_part(x,'|',4)||':'||{SLUG}),10) vid, split_part(x,'|',2)::int rk, {url} url FROM regexp_split_to_table(nl,E'\\n') x
      UNION ALL SELECT split_part(x,'|',3), split_part(x,'|',2)::int, {url} FROM regexp_split_to_table(al,E'\\n') x) q ORDER BY q.url, q.rk;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {AW} THEN RAISE EXCEPTION 'new awards %', n; END IF;
  -- WRITE: move OAD rows
  UPDATE awards a SET venue_id=y.n FROM (SELECT split_part(x,'|',1)::bigint id, split_part(x,'|',2) o, split_part(x,'|',3) n FROM regexp_split_to_table(mv,E'\\n') x) y WHERE a.id=y.id AND a.venue_id=y.o AND a.source_id='oad';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {MV} THEN RAISE EXCEPTION 'moved awards %', n; END IF;
  -- WRITE: delete the venue with no award left
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY(dl)) <> 0 THEN RAISE EXCEPTION 'award left on deleted'; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL FROM city_label_source c WHERE c.venue_id = ANY(dl);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'label audit %', n; END IF;
  DELETE FROM city_label_source WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  DELETE FROM slugs WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  DELETE FROM listings WHERE venue_id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings %', n; END IF;
  DELETE FROM venues WHERE id = ANY(dl); GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues %', n; END IF;
  -- WRITE: city counts
  UPDATE cities c SET venues_count=coalesce(k.active_venues,0) FROM cities d LEFT JOIN city_venue_counts k ON k.city_id=d.id WHERE d.id=c.id AND c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {UPD} THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', {ct['a']}, 'cleanup:{NAME} | OAD 2026 hold rows and Summer Palace, asia | https://www.oadguides.com/lists/asia/top-restaurants/2026 | {BEN}'),
    ('oad', 'award', {ct['e']}, 'cleanup:{NAME} | OAD 2026 hold rows, europe | https://www.oadguides.com/lists/europe/top-restaurants/2026 | {BEN}'),
    ('oad', 'award', {ct['j']}, 'cleanup:{NAME} | OAD 2026 hold rows, japan | https://www.oadguides.com/lists/japan/top-restaurants/2026 | {BEN}'),
    ('oad', 'award', {MV}, 'cleanup:{NAME} | {MV} OAD rows moved to the printed restaurant: Summer Palace 5562, 18119, 32880, Pirouette 18463 | {BEN}'),
    ('oad', 'award', {D}, 'cleanup:{NAME} | contamination rule (Ben, Sep 28): Le Choubichou ve_3a0ba9fb7b deleted, no award after the move, 404, no redirect | {BEN}'),
    ('oad', 'city_label', {2*N}, 'cleanup:{NAME} | city labels of the {N} new venues | {BEN}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {V1} OR (SELECT count(*) FROM venues WHERE status='active') <> {A1} OR (SELECT count(*) FROM venues WHERE status='closed') <> {C1} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {AW1} OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> {O26+AW} OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> {O25} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {AW} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {S1} OR (SELECT count(*) FROM listings) <> {L1} OR (SELECT count(*) FROM city_label_source) <> {LB1} OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 32 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {CI1} OR (SELECT sum(venues_count) FROM cities) <> {SUM1} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {LG1} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={AW},awards:UPDATE={MV},cities:INSERT={CN},cities:UPDATE={UPD},city_label_source:DELETE=2,city_label_source:INSERT={2*N},listings:DELETE={D},listings:INSERT={N},slugs:DELETE={D},slugs:INSERT={N},venues:DELETE={D},venues:INSERT={N}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
for k,v in dict(nl=nl,al=al,mv=mv,cl=cl,dv=dv).items(): T=T.replace('%%'+k+'%%',v)
open(NAME+'.sql','w',encoding='utf-8',newline='\n').write(T)
print(dict(V1=V1,A1=A1,C1=C1,AW1=AW1,O26=O26+AW,S1=S1,L1=L1,LB1=LB1,CI1=CI1,SUM1=SUM1,LG1=LG1,AUDN=AUDN,UPD=UPD,ct=ct,bytes=len(T.encode())))
