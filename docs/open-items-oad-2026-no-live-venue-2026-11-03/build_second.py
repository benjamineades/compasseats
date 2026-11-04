#!/usr/bin/env python3
# Builds the OAD 2026 "no live venue" load file and the evidence CSV from status_v2.json.
import json, re, csv, hashlib, unicodedata, collections, sys
GO = sys.argv[1] if len(sys.argv) > 1 else 'NOT APPROVED'
R = json.load(open('rows311.json')); K = {r['key']: r for r in R}
S = json.load(open('status_v2.json')); V = json.load(open('venues.json')); C = json.load(open('cities.json'))
VI = {v['id']: v for v in V}
U = 'https://www.oadguides.com/lists/%s/top-restaurants/2026'
# Row goes on a live venue (no 2026 row there yet).
ATTACH = dict(e301='ve_bfda4f7b82', e465='ve_94030afaec', e643='ve_488b989290', e751='ve_10446b243a', e739='ve_e362728f66',
              a88='ve_0ad174c768', a107='ve_269ab60a27', a317='ve_c9af48a8c5', a326='ve_21bab3c06d', a536='ve_217324874a',
              a562='ve_0d894398dc', j240='ve_893dbeaa44', j345='ve_46a97d9db1', j634='ve_491642d330', j657='ve_ec860811a8',
              j692='ve_a17af50aab', j682='ve_9a19410ee6', j306='ve_fc80e81a1a', e631='ve_cd4a28a835', j377='ve_ca7ad6ea1a')
WHY = dict(e301='Michelin card: chef Takayuki Honjo, 91 rue de Grenelle (OAD page address)', e465='Own site Dima; OAD address is the same street', e643='Michelin card: chef Giuseppe Raciti, Archi', e751='Phone on own site = OAD page phone', e739='OAD site names Achilli; Via dei Prefetti 15',
           a88='Gold Pig is Geumdwaeji Sikdang (press, Jun 2026)', a107='Michelin card: chef Alain Huang, same address', a317='Michelin card Palate: chef Kim Jae-hoon', a326='Same name in the live name; Bangkok', a536='Same name; OAD postal code 105 is Songshan',
           a562='Michelin card HAILI, same street in Kaohsiung', j240='Own site at Hiroo (OAD page also prints Hiroo). OAD city Kyoto is wrong', j345='Abon holds OAD 2025; Tabelog Ashiya, Hyogo; OAD site link is the same Tabelog page', j634='Phone on Michelin card = OAD page phone', j657='Michelin card Yotsuya Minemura, Arakicho',
           j692='Michelin card, chef Tommy', j682='Fukutatei Steak holds OAD 2025; same name, Osaka', j306='Renamed Ichita to Taichi, chef Taichi Sato. Live Taichi holds the 2025 row of the slug ichita', e631='OWN SITE: Padaste Manor closed. Venue stays closed', j377='Phone on the mall page = OAD page phone. Mall page: currently closed. Venue stays closed')
# Same restaurant printed twice, second row on the live venue (Ben 5A, Nov 3).
SECOND = dict(a524='ve_73d901a8fe', j669='ve_f0f0978f15')
HOLD_WHY = dict(e534='Conflict: Hardens page prints both closed and open hours', a325='Conflict: address may now be another restaurant', j318='Conflict: Akaiwa or a move to Kyoto', j609='Conflict: move, reopening not confirmed', j755='OAD address is another restaurant; chef not found',
                e412='One 2023 directory says renamed Choubichou; no later read', j313='Identity low', j638='Identity low', j789='Identity low: Michelin Nishiazabu, OAD Tamagawa', j469='Could be a branch of live Kusunoki (No. 26)', j769='Could be live Ten Yokota (No. 678); different sites', a494='Possibly rebranded after a 2020 takeover', j448='City not proven (OAD Nagoya, one 2023 log Gifu)', j611='City not proven (OAD Kitakyushu, Tabelog Kasuga)')
CLOSED = {'a430', 'j698', 'e528'}
NAMEFIX = dict(e150='Yeni Lokanta', a493='Salisterra', j467='Hiiragiya', j582='Gion Rohan', j698='Tokyo Shiba Tofuya Ukai', j715='Ryoriya Stephan Pantel', j738='Tempura Endo Yasaka', j695='Sushi Shunbi Nishikawa', j771='Sushi Hoseki', a359='Qi 27', j372='Sushi Riku')
MERGE = {'j630': 'j372'}  # Sushiriku row goes on the Sushi Riku venue (one restaurant, Ben's question).
CITYFIX = {'berlin kreuzberg': 'Berlin', 'ghent': 'Gent', 'puente arce arce': 'Puente Arce', 'sakai mikuni awara area fukui': 'Sakai', 'weston rhyn near oswestry': 'Weston Rhyn', 'kaohsiung': 'Kaohsiung'}
ISO = {'Japan': 'JP', 'Italy': 'IT', 'Spain': 'ES', 'Norway': 'NO', 'Netherlands': 'NL', 'Philippines': 'PH', 'Indonesia': 'ID', 'United Kingdom': 'GB', 'Belgium': 'BE'}
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD', s or '') if not unicodedata.combining(c))
def k(s): return re.sub(r'[^a-z0-9]', '', ua(s).lower())
def slugify(s): return re.sub(r'[^a-z0-9]+', '-', ua(s).lower().replace('ß', 'ss')).strip('-')
def md(s, n=10): return hashlib.md5(s.encode()).hexdigest()[:n]
cs = collections.defaultdict(list)
for c in C: cs[k(c['display'])].append(c)
cslug = {c['slug']: c for c in C}
newcity = {}; rows = []
def city_for(key, r, o):
    rc = o.get('real_city') or ''
    d = CITYFIX.get(re.sub(r'[^a-z ]', '', ua(rc).lower()).strip(), re.split(r'[,(]', rc)[0].strip())
    if key == 'a589': d = r['printed_city']  # Sarong: weak read, keep the printed city.
    cc = ISO.get(o.get('real_country')) or None
    live = cs.get(k(d), [])
    if cc: live = [c for c in live if c['cc'] == cc] or ([] if d in ('San Juan',) else live)
    if live: return live[0]
    assert cc, (key, d, o.get('real_country'))
    s = slugify(d); assert s not in cslug, (s, key)
    if s not in newcity: newcity[s] = dict(id='ci_' + md(s), slug=s, display=d, country=o['real_country'], country_iso=cc, kind='city', venues_count=0)
    return newcity[s]
group = {}
for key, o in S.items():
    r = K[key]
    if key in MERGE: group[key] = 'second row, same new venue'; continue
    if key in ATTACH: group[key] = 'live venue' ; continue
    if key in SECOND: group[key] = 'printed twice: second row on live venue'; continue
    if key in HOLD_WHY or o['identity'] == 'low': group[key] = 'hold'; continue
    group[key] = 'new venue: closed' if key in CLOSED else ('new venue: status not read' if o['read_status'] == 'not_found' else 'new venue: open')
new = []; seen = {}; lab = []
for r in R:
    key = r['key']; o = S[key]; g = group[key]
    if not g.startswith('new venue'): continue
    name = NAMEFIX.get(key) or re.sub(r'\s*\(.*?\)\s*$', '', r['printed_name']).strip()
    c = city_for(key, r, o); s = slugify(name); assert s, key
    vid = 've_' + md(c['slug'] + ':' + s)
    assert (c['slug'], s) not in seen, (key, seen[(c['slug'], s)]); seen[(c['slug'], s)] = key
    st = 'closed' if key in CLOSED else 'active'
    new.append(dict(key=key, id=vid, name=name, status=st, city_id=c['id'], city_slug=c['slug'], city=c['display'], slug=s, list=r['list'], rank=r['rank']))
    pc = r['printed_city'] if r['printed_city'] not in ('', 'Modern Indian') else c['display']
    PR = {'Chūbu', 'Chugoku', 'Chūgoku', 'Tohoku', 'Hokkaido', 'Kantō', 'Kyushu', 'Kansai', ''}
    co = r['printed_country'] if r['printed_country'] not in PR else (o.get('real_country') or c.get('country'))
    lab.append((vid, pc, 'city_display')); lab.append((vid, co, 'country'))
    if st == 'active':
        if c['slug'] in newcity: newcity[c['slug']]['venues_count'] += 1
aw = [dict(venue_id=n['id'], rank=n['rank'], url=U % n['list']) for n in new]
idx = {n['key']: n for n in new}
for key, tkey in MERGE.items():
    if group[key].startswith('second') and tkey in idx: aw.append(dict(venue_id=idx[tkey]['id'], rank=K[key]['rank'], url=U % K[key]['list']))
for key, vid in {**ATTACH, **SECOND}.items(): aw.append(dict(venue_id=vid, rank=K[key]['rank'], url=U % K[key]['list']))
aw.sort(key=lambda a: (a['url'], a['rank']))
assert len({(a['url'], a['rank']) for a in aw}) == len(aw)
live_ids = sorted(set(ATTACH.values()) | set(SECOND.values()))
for i in live_ids: assert i in VI, i
upd = collections.Counter()
for n in new:
    if n['status'] == 'active' and n['city_slug'] not in newcity: upd[cslug[n['city_slug']]['id']] += 1
print('groups', collections.Counter(group.values()))
print('by list', collections.Counter((K[k_]['list'], g) for k_, g in group.items()))
print('new', len(new), 'active', sum(n['status'] == 'active' for n in new), 'closed', sum(n['status'] == 'closed' for n in new), 'awards', len(aw), 'new cities', len(newcity), 'updated cities', len(upd), 'labels', len(lab))
print('new cities', [(c['display'], c['country_iso'], c['venues_count']) for c in newcity.values()])
print('moved city', [(n['key'], n['name'], K[n['key']]['printed_city'], n['city']) for n in new if k(K[n['key']]['printed_city']) != k(n['city'])])
A = len(new); ACT = sum(n['status'] == 'active' for n in new); CL = A - ACT; AW = len(aw); LB = len(lab); NC = len(newcity); UC = len(upd)
L = collections.Counter(a['url'].split('/')[4] for a in aw)
T = dict(venues=11336 + A, active=11042 + ACT, closed=294 + CL, awards=27118 + AW, oad26=2496 + AW, slugs=13184 + A, listings=11336 + A, labels=24079 + LB, cities=3281 + NC, vsum=11042 + ACT, ledger=214 + len(L) + 1)
AUD = A + A + A + AW + NC + UC + LB
SEP = '|'
for n in new: assert SEP not in n['name'] and "$" not in n['name']
lab_by = collections.defaultdict(dict)
for a_, b_, c_ in lab: lab_by[a_][c_] = b_
for v_ in lab_by.values():
    assert SEP not in v_['city_display'] and SEP not in v_['country']
NL = '\n'.join(SEP.join([n['list'][0], str(n['rank']), n['name'], n['city_slug'], n['status'][0], lab_by[n['id']]['city_display'], lab_by[n['id']]['country']]) for n in new)
CL_ = '\n'.join(SEP.join([c['slug'], c['display'], c['country'], c['country_iso'], str(c['venues_count'])]) for c in newcity.values())
AL = '\n'.join(SEP.join([a['url'].split('/')[4][0], str(a['rank']), a['venue_id']]) for a in aw if a['venue_id'] not in {n['id'] for n in new} or (a['venue_id'], a['rank']) not in {(n['id'], n['rank']) for n in new})
PM = hashlib.md5((NL + '\n#\n' + CL_ + '\n#\n' + AL).encode()).hexdigest()
IDM = hashlib.md5('\n'.join(sorted(n['id'] for n in new)).encode()).hexdigest()
AWM = hashlib.md5('\n'.join(sorted(f"{a['venue_id']}|{a['rank']}|{a['url']}" for a in aw)).encode()).hexdigest()
fp = hashlib.md5('\n'.join(f"{i}|{VI[i]['name']}|{VI[i]['status']}|{VI[i]['city_id']}" for i in sorted(live_ids)).encode()).hexdigest()
ids = "','".join(live_ids)
TAG = 'cleanup:load-oad-2026-no-live-venue-2026-11-03'
J = lambda t: f"{TAG} | {t} | {GO}".replace("'", "''")
led = ',\n    '.join(f"('oad', 'award', {n}, '{J(f'open item 1: OAD 2026 no live venue rows, {l} | {U % l}')}')" for l, n in sorted(L.items()))
sql = f"""-- load-oad-2026-no-live-venue-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open item 1 of handoff-oad-2026-first-write-done. {GO}. This file runs only after his "go".
-- {AW} new OAD 2026 rows. {A} new venues ({ACT} active, {CL} closed and not published). {len(ATTACH)} rows on live venues. {len(SECOND)} second rows. {NC} new cities. {sum(1 for g in group.values() if g=='hold')} rows held.
-- Evidence: oad-2026-no-live-venue-evidence-2026-11-03.csv. No price, address, geo or blurb.
-- Expected after: venues {T['venues']:,} (active {T['active']:,}, closed {T['closed']:,}); awards {T['awards']:,}; OAD 2026 {T['oad26']:,}; slugs {T['slugs']:,}; listings {T['listings']:,}; labels {T['labels']:,}; cities {T['cities']:,}, sum {T['vsum']:,}; ledger {T['ledger']} rows; audit_log +{AUD} ({121990+AUD:,} rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan${NL}$plan$;
  cl text := $plan${CL_}$plan$;
  al text := $plan${AL}$plan$;
  p jsonb; n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(nl||E'\n#\n'||cl||E'\n#\n'||al) <> '{PM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  WITH r AS (SELECT split_part(x,'|',1) li, split_part(x,'|',2)::int rk, split_part(x,'|',3) name, split_part(x,'|',4) city_slug, split_part(x,'|',5) st, split_part(x,'|',6) clab, split_part(x,'|',7) colab FROM regexp_split_to_table(nl,E'\n') x),
       q AS (SELECT r.*, trim(both '-' from regexp_replace(lower(f_unaccent(r.name)),'[^a-z0-9]+','-','g')) slug FROM r),
       w AS (SELECT q.*, 've_'||left(md5(q.city_slug||':'||q.slug),10) id, coalesce(c.id,'ci_'||left(md5(q.city_slug),10)) city_id, (CASE q.st WHEN 'a' THEN 'active' ELSE 'closed' END) status, c.id IS NULL is_new, (CASE q.li WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END) lst FROM q LEFT JOIN cities c ON c.slug=q.city_slug),
       ca AS (SELECT split_part(x,'|',1) slug, split_part(x,'|',2) display, split_part(x,'|',3) country, split_part(x,'|',4) country_iso, split_part(x,'|',5)::int venues_count FROM regexp_split_to_table(cl,E'\n') x),
       aa AS (SELECT split_part(x,'|',3) venue_id, split_part(x,'|',2)::int rank, 'https://www.oadguides.com/lists/'||(CASE split_part(x,'|',1) WHEN 'e' THEN 'europe' WHEN 'a' THEN 'asia' ELSE 'japan' END)||'/top-restaurants/2026' url FROM regexp_split_to_table(al,E'\n') x)
  SELECT jsonb_build_object(
    'new',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'status',status,'city_id',city_id,'city_slug',city_slug,'slug',slug)) FROM w),
    'aw',(SELECT jsonb_agg(z) FROM (SELECT id venue_id, rk "rank", 'https://www.oadguides.com/lists/'||lst||'/top-restaurants/2026' url FROM w UNION ALL SELECT venue_id, rank, url FROM aa) z),
    'cities',(SELECT jsonb_agg(jsonb_build_object('id','ci_'||left(md5(slug),10),'slug',slug,'display',display,'country',country,'country_iso',country_iso,'venues_count',venues_count)) FROM ca),
    'upd',(SELECT jsonb_agg(jsonb_build_object('id',city_id,'plus',c)) FROM (SELECT city_id, count(*) c FROM w WHERE status='active' AND NOT is_new GROUP BY 1) y),
    'labels',(SELECT jsonb_agg(jsonb_build_object('venue_id',id,'label',l,'col',col)) FROM (SELECT id, clab l, 'city_display' col FROM w UNION ALL SELECT id, colab, 'country' FROM w) y)) INTO p;
  IF (SELECT md5(string_agg(e->>'id',E'\n' ORDER BY e->>'id' COLLATE "C")) FROM jsonb_array_elements(p->'new') e) <> '{IDM}' THEN RAISE EXCEPTION 'venue ids'; END IF;
  IF (SELECT md5(string_agg(t,E'\n' ORDER BY t COLLATE "C")) FROM (SELECT (e->>'venue_id')||'|'||(e->>'rank')||'|'||(e->>'url') t FROM jsonb_array_elements(p->'aw') e) y) <> '{AWM}' THEN RAISE EXCEPTION 'award rows'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN ('{ids}');
  IF fp IS DISTINCT FROM '{fp}' THEN RAISE EXCEPTION 'live venue fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11336 OR (SELECT count(*) FROM venues WHERE status='active') <> 11042 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27118 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2496 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13184 OR (SELECT count(*) FROM listings) <> 11336 OR (SELECT count(*) FROM city_label_source) <> 24079 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3281 OR (SELECT sum(venues_count) FROM cities) <> 11042 OR (SELECT count(*) FROM source_capture_ledger) <> 214 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 121990 OR aud_max <> 127819 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text) WHERE x.id <> 've_'||left(md5(x.city_slug||':'||x.slug),10) OR trim(both '-' from regexp_replace(lower(f_unaccent(x.name)),'[^a-z0-9]+','-','g')) <> x.slug;
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text, city_id text) WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=x.id OR (v.city_id=x.city_id AND v.norm_key=norm_key(x.name))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.city_slug AND t.slug=x.slug);
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'cities') x(id text, slug text) WHERE x.id <> 'ci_'||left(md5(x.slug),10) OR EXISTS (SELECT 1 FROM cities c WHERE c.id=x.id OR c.slug=x.slug) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.slug AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(city_id text, status text) WHERE NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=x.city_id) AND NOT EXISTS (SELECT 1 FROM jsonb_to_recordset(p->'cities') y(id text) WHERE y.id=x.city_id);
  IF n <> 0 THEN RAISE EXCEPTION 'city missing %', n; END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(p->'upd') x(id text) JOIN cities c ON c.id=x.id) <> {UC} THEN RAISE EXCEPTION 'cities to update'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(p->'aw') x(venue_id text, rank int) ON a.venue_id=x.venue_id AND a.source_id='oad' AND a.year=2026 AND a.rank=x.rank) THEN RAISE EXCEPTION 'row exists'; END IF;
  IF (SELECT count(DISTINCT a.venue_id) FROM awards a WHERE a.source_id='oad' AND a.year=2026 AND a.venue_id IN ('{ids}')) <> {len(SECOND)} THEN RAISE EXCEPTION 'live venues with a 2026 row'; END IF;
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT x.id, x.slug, x.display, x.country, x.country_iso, 'city'::city_kind, NULL, NULL, NULL, x.venues_count FROM jsonb_to_recordset(p->'cities') x(id text, slug text, display text, country text, country_iso text, venues_count int);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {NC} THEN RAISE EXCEPTION 'cities %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + x.plus FROM jsonb_to_recordset(p->'upd') x(id text, plus int) WHERE c.id=x.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {UC} THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT x.id, x.name, 'restaurant'::venue_category, x.city_id, x.status::venue_status FROM jsonb_to_recordset(p->'new') x(id text, name text, city_id text, status text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {A} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT x.id, 'eats', x.status='active' FROM jsonb_to_recordset(p->'new') x(id text, status text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {A} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', x.city_slug, x.slug, x.id, true FROM jsonb_to_recordset(p->'new') x(id text, city_slug text, slug text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {A} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) SELECT x.venue_id, x.label, x.col::label_column_t, 'oad', 'OAD 2026 no live venue' FROM jsonb_to_recordset(p->'labels') x(venue_id text, label text, col text) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {LB} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT x.venue_id, 'oad', 2026, x.rank, 'No. '||x.rank, NULL, x.url FROM jsonb_to_recordset(p->'aw') x(venue_id text, rank int, url text) ORDER BY x.url, x.rank;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {AW} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {led},
    ('oad', 'city_label', {LB}, '{J(f'open item 1: city labels of the {A} new venues')}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {T['venues']} OR (SELECT count(*) FROM venues WHERE status='active') <> {T['active']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {T['closed']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {T['awards']} OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> {T['oad26']} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {AW} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {T['slugs']} OR (SELECT count(*) FROM listings) <> {T['listings']} OR (SELECT count(*) FROM city_label_source) <> {T['labels']} OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {T['cities']} OR (SELECT sum(venues_count) FROM cities) <> {T['vsum']} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {T['ledger']} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={AW},cities:INSERT={NC},cities:UPDATE={UC},city_label_source:INSERT={LB},listings:INSERT={A},slugs:INSERT={A},venues:INSERT={A}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open('load-oad-2026-no-live-venue-2026-11-03.sql', 'w').write(sql)
print('sql', len(sql), hashlib.sha256(sql.encode()).hexdigest(), 'audit+', AUD, T)
# evidence CSV
F = ['list', 'rank', 'new_mark', 'printed_name', 'printed_city', 'printed_country', 'chef', 'oad_slug', 'oad_page_address', 'oad_page_web', 'group', 'target_venue_id', 'target_name', 'target_city', 'target_status', 'read_status', 'strength', 'identity', 'evidence_url', 'second_url', 'evidence_note', 'real_name', 'real_city', 'address_seen', 'oad_page_is_other_place', 'other_note', 'reason']
with open('oad-2026-no-live-venue-evidence-2026-11-03.csv', 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, F); w.writeheader()
    for r in R:
        key = r['key']; o = S[key]; g = group[key]
        t = idx.get(key) or (idx.get(MERGE.get(key)) if key in MERGE else None)
        lv = VI.get(ATTACH.get(key) or SECOND.get(key))
        reason = WHY.get(key) or HOLD_WHY.get(key) or ('Identity low' if g == 'hold' else '')
        w.writerow(dict(list=r['list'], rank=r['rank'], new_mark=r['new_mark'], printed_name=r['printed_name'], printed_city=r['printed_city'], printed_country=r['printed_country'], chef=r['chef'], oad_slug=r['oad_slug'], oad_page_address=r['oad_page_address'], oad_page_web=r['oad_page_web'], group=g, target_venue_id=(t or {}).get('id') or (lv or {}).get('id', ''), target_name=(t or {}).get('name') or (lv or {}).get('name', ''), target_city=(t or {}).get('city') or (lv or {}).get('city', ''), target_status=(t or {}).get('status') or (lv or {}).get('status', ''), read_status=o['read_status'], strength=o['strength'], identity=o['identity'], evidence_url=o.get('evidence_url', ''), second_url=o.get('second_url', ''), evidence_note=o.get('evidence_note', ''), real_name=o.get('real_name', ''), real_city=o.get('real_city', ''), address_seen=o.get('address_seen', ''), oad_page_is_other_place=o.get('oad_page_is_other_place', ''), other_note=o.get('other_note', ''), reason=reason))
print('csv', hashlib.sha256(open('oad-2026-no-live-venue-evidence-2026-11-03.csv', 'rb').read()).hexdigest())
print('HOLD', [(k_, K[k_]['printed_name']) for k_, g in group.items() if g == 'hold'])
print('UNREAD', [(n['key'], n['name'], n['city']) for n in new if S[n['key']]['read_status'] == 'not_found'])
print('WEAK', [(n['key'], n['name']) for n in new if S[n['key']]['strength'] == 'weak' and S[n['key']]['read_status'] == 'open'])
print('LEN', len(R), sum(1 for g in group.values()))
