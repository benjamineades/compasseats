#!/usr/bin/env python3
"""Build one load file for the A1 Michelin guides: greece, south-australia, dubai.
Args: guide, fingerprint md5 of the scope rows, approval text, scratch dir. Baseline counts come from baseline.json."""
import hashlib, json, re, sys, unicodedata
GUIDE, FP = sys.argv[1], sys.argv[2]
APPROVAL = sys.argv[3] if len(sys.argv) > 3 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[4] if len(sys.argv) > 4 else '.'
B = json.load(open('baseline.json'))
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
CFG = {
 'greece': dict(year=2027, relay='relay-greece-2027-list-pages-2026-11-06.txt', sha='8976dd6d36b4e0886c5b7655cd6b9357c5ce02b0a5f3b16a5bb343986bc67982', name='Greece 2027', date='Oct 20, 2026',
   article='https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-athens-thessaloniki-santorini-2027-marks-a-milestone-for-greek-gastronomy',
   country='Greece', iso='GR', scope="c.country_iso='GR'", pre=17, closed=[], counts=(0,1,19,10),
   cities={'athens':('ci_8fde6a6592',29),'santorini':('ci_a949f33046',1),'thessaloniki':('ci_29833ab42f',2)}, newc={}, loc={'Athens':'athens','Santorini':'santorini','Thessalonica':'thessaloniki'},
   relabel=dict(file='relabel-greece.txt', to=2024, url='https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-athens-2024-is-out', note='Athens edition live at capture = 2024 (Dec 18, 2024); no Athens selection in 2025 (https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-expands-in-greece-for-2026)'),
   post={2024:(0,1,11,5),2027:(0,1,19,10)}),
 'south-australia': dict(year=2027, relay='relay-south-australia-2027-list-pages-2026-11-06.txt', sha='de4c2f370b6bc608e9afe3d65114b16bc1c93c874695939f18498d8c86899829', name='South Australia 2027', date='Oct 14, 2026',
   article='https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-south-australia-restaurant-selection-2027',
   country='Australia', iso='AU', scope="c.country_iso='AU'", pre=0, closed=[], counts=(0,1,10,16),
   cities={'adelaide':('ci_851819adaa',5),'seppeltsfield':('ci_37a1f5075f',1)},
   newc={'stirling':'Stirling','mclaren-vale':'McLaren Vale','sevenhill':'Sevenhill','kangarilla':'Kangarilla','woodside-au':'Woodside','clare':'Clare','kingscote':'Kingscote'},
   loc={'Adelaide':'adelaide','Seppeltsfield':'seppeltsfield','Stirling':'stirling','McLaren Vale':'mclaren-vale','Sevenhill':'sevenhill','Kangarilla':'kangarilla','Woodside':'woodside-au','Clare':'clare','Kingscote':'kingscote'},
   relabel=None, post={2027:(0,1,10,16)}),
 'dubai': dict(year=2026, relay='relay-dubai-2026-list-pages-2026-11-06.txt', sha='3e6f66b26d45a2acd424754394020703afcf878329ca717b3e6788146dbbb351', name='Dubai 2026', date='Oct 6, 2026',
   article='https://guide.michelin.com/ae-du/en/article/michelin-guide-ceremony/full-list-michelin-guide-dubai-selection',
   country='United Arab Emirates', iso='AE', scope="c.id='ci_3c40d285e6'", pre=38, closed=['ve_d35cc76459'], counts=(2,4,14,22),
   cities={'dubai':('ci_3c40d285e6',93)}, newc={}, loc={'Dubai':'dubai'}, relabel=None, post={2025:(2,3,14,19),2026:(2,4,14,22)}),
}
C = CFG[GUIDE]; Y = C['year']; KEY = f"load-michelin-{Y}-{GUIDE}-2026-11-06"
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
rel = open(C['relay'], encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == C['sha']
pairs = {p[1]: p[2] for p in (l.split('\t') for l in open('pairs.tsv').read().strip().split('\n')) if p[0] == GUIDE}
cities = dict(C['cities']); 
for s in C['newc']: cities[s] = ('ci_' + md5(s)[:10], 0)
cards, CC = [], {}
for line in rel.split('\n'):
    cat, href, name, loc, pr = dec(line).split(' | ')
    assert '~' not in name
    path = href.split('/restaurant/')[1]; label = loc.split(', ')[0]; v = pairs.get(path)
    c = dict(cat=cat, url='https://guide.michelin.com' + href, name=name, label=label, v=v, path=path)
    if v is None:
        cs = C['loc'][label]; c.update(cs=cs, slug=slugify(name)); c['v'] = 've_' + md5(f"{cs}:{c['slug']}")[:10]; CC[cs] = CC.get(cs, 0) + 1
    cards.append(c)
order = ['Three Stars', 'Two Stars', 'One Star', 'Bib Gourmand']
assert tuple(sum(c['cat'] == k for c in cards) for k in order) == C['counts']
assert len({c['url'] for c in cards}) == len(cards) == len({c['v'] for c in cards}) and set(pairs) <= {c['path'] for c in cards}
new = sorted([c for c in cards if 'slug' in c], key=lambda c: c['v'])
AW = '\n'.join(f"{c['v']}~{c['cat']}~{c['url']}" for c in sorted(cards, key=lambda c: c['v']))
NW = '\n'.join(f"{c['v']}~{c['slug']}~{c['cs']}~{cities[c['cs']][0]}~{c['label']}~{c['name']}" for c in new) 
R = C['relabel']; RL = open(R['file']).read().strip() if R else ''
nr = len(RL.split('\n')) if R else 0; na, nv = len(cards), len(new); nl = nv * 2; nc = len(C['newc']); upd = [s for s in C['cities'] if s in CC]; nu = len(upd)
ml = 3 if R and nv else (2 if (R or nv) else 1)
tot = nr + na + nv * 3 + nl + nu + nc
yc = {y: B[f"m{str(y)[2:]}"] for y in (2024, 2025, 2026, 2027)}
ya = dict(yc); ya[Y] += na
if R: ya[2025] -= nr; ya[R['to']] += nr
cg = ' OR '.join(f"(SELECT venues_count FROM cities WHERE id='{cities[s][0]}') <> {cities[s][1]}" for s in upd) or 'false'
cu = '\n'.join(f"  UPDATE cities SET venues_count={cities[s][1]+CC[s]} WHERE id='{cities[s][0]}' AND venues_count={cities[s][1]};\n  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count {s}'; END IF;" for s in upd)
ci = '\n'.join(f"  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('{cities[s][0]}', '{s}', '{C['newc'][s]}', '{C['country']}', '{C['iso']}', 'city', NULL, NULL, NULL, {CC[s]});" for s in C['newc'])
cc = ' OR '.join(f"EXISTS (SELECT 1 FROM cities WHERE id='{cities[s][0]}' OR slug='{s}') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('{C['newc'][s]}'))" for s in C['newc']) or 'false'
closed = ','.join(f"'{v}'" for v in C['closed']) or "''"
ag = ','.join(sorted(f"{a}={n}" for a, n in [])) 
parts = [('awards:INSERT', na), ('awards:UPDATE', nr), ('cities:INSERT', nc), ('cities:UPDATE', nu), ('city_label_source:INSERT', nl), ('listings:INSERT', nv), ('slugs:INSERT', nv), ('venues:INSERT', nv)]
AUD = ','.join(f"{k}={n}" for k, n in parts if n)
postS = ','.join(f"{y}:{k}={n}" for y in sorted(C['post']) for k, n in sorted(zip(order, C['post'][y])) if n)
relabel_pre = f"""  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url='{R['url']}') THEN RAISE EXCEPTION 'relabel url in use'; END IF;""" if R else ''
relabel_w = f"""  UPDATE awards a SET year={R['to']}, source_url='{R['url']}' WHERE a.id IN (SELECT split_part(x,'~',1)::bigint FROM regexp_split_to_table(rl,E'\\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;""" if R else ''
new_w = f"""  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',6), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
{cu}
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '{Y} edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),('{C['country']}','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;""" if nv else ''
led = []
if R: led.append(f"('michelin','award',{nr},'relabel:{KEY} | rule 2.1.7: {R['note']} | {R['url']} | year 2025 -> {R['to']}, article URL, retire 0 | {APPROVAL}')")
led.append(f"('michelin','award',{na},'cleanup:{KEY} | {C['name']}, {C['date']}, {C['article']} | Three Stars {C['counts'][0]}, Two Stars {C['counts'][1]}, One Star {C['counts'][2]}, Bib {C['counts'][3]} | relay sha256 {C['sha']} | {APPROVAL}')")
if nv: led.append(f"('michelin','city_label',{nl},'cleanup:{KEY} | city labels of {nv} new venues{', new cities ' + ', '.join(C['newc']) if nc else ''} | {APPROVAL}')")
assert len(led) == ml
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin {C['name']}. {APPROVAL}. This file runs only after Ben's "go".
-- {na} new rows, year {Y} ({C['date']}: {C['article']}), source_url = the card (/us/en/). {nv} new venues, {nc} new cities.{f" Relabel {nr} rows 2025 -> {R['to']}: {R['note']}." if R else ' Relabel 0.'} Retire 0.
-- Source: docs/michelin-a1-2026-11-06/{C['relay']} sha256 {C['sha']}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']+nc}, sum {B['sum']+nv}; ledger {B['led']+ml} rows; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{md5(RL)}' OR md5(aw) <> '{md5(AW)}' OR md5(nw) <> '{md5(NW)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(coalesce(string_agg(t, E'\\n' ORDER BY t COLLATE "C"),'')) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND {C['scope']}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {C['scope']}) <> {C['pre']} THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {yc[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {yc[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {yc[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {yc[2027]} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR {cg} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF {cc} THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
{relabel_pre}
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND (v.status='active' OR v.id IN ({closed})));
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE x<>'' AND (split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',6))),'[^a-z0-9]+','-','g')));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE x<>'' AND (EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',6)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2)));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
{relabel_w}
{ci}
{new_w}
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', {Y}, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year={Y} AND source_id='michelin') <> '{md5(AW)}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {ya[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {ya[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {ya[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {ya[2027]} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {C['scope']} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '{postS}' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {C['scope']} GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+nc} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+ml} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '{AUD}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(KEY + '.sql', 'w', encoding='utf8').write(sql)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: start')
open(f"{SCRATCH}/dry-{GUIDE}.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'cards', na, 'paired', na - nv, 'new', nv, 'newcities', nc, 'cityupd', {s: CC[s] for s in upd}, 'relabel', nr, 'audit', tot, 'ledger', ml)
print([ (c['name'], c['slug'], c['cs'], c['v']) for c in new])
