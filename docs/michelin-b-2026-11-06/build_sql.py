#!/usr/bin/env python3
"""Build the group B file: Poland, Croatia, Slovenia 2026. One transaction.
Args: fingerprint, approval text, scratch dir. Baseline from baseline.json."""
import hashlib, json, re, sys, unicodedata
FP = sys.argv[1]
APPROVAL = sys.argv[2] if len(sys.argv) > 2 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[3] if len(sys.argv) > 3 else '.'
B = json.load(open('baseline.json'))
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'load-michelin-2026-b-2026-11-06'
SHA = '69dca933c4a4070625876a5f28565efe09aa89663a09feb7b63a34d09dbc36d5'
RELAY = 'relay-b-2026-list-pages-2026-11-06.txt'
SCOPE = "c.country_iso IN ('PL','HR','SI')"
ART = {'poland': ('Poland 2026, May 27, 2026', 'https://guide.michelin.com/pl/en/article/michelin-guide-ceremony/michelin-guide-poland-2026-news'),
 'croatia': ('Croatia 2026, Jun 25, 2026', 'https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-croatia-2026-is-unveiled'),
 'slovenia': ('Slovenia 2026, Jun 16, 2026', 'https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-slovenia-2026-is-out')}
CITY = {'Kraków': ('krakow','ci_7dd3f7a74c',6), 'Warsaw': ('warsaw','ci_d3ee3f1229',13), 'Wrocław': ('wroc-aw','ci_527e20892b',4), 'Gdańsk': ('gdansk','ci_5f55488e0a',3), 'Katowice': ('katowice','ci_eece5a7109',1)}
NEWC = {'Wałbrzych':'walbrzych','Kielce':'kielce','Łódź':'lodz','Lublin':'lublin','Białystok':'bialystok','Rzeszów':'rzeszow','Toruń':'torun','Olsztyn':'olsztyn','Skórzewo':'skorzewo'}
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
rel = open(RELAY, encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == SHA
cards = {}
for line in rel.split('\n'):
    g, cat, href, name, loc, pr, cc, dist = dec(line).split(' | ')
    assert '~' not in name
    cards[href.split('/restaurant/')[1]] = dict(g=g, cat=cat, url='https://guide.michelin.com' + href, name=name, loc=loc)
pairs = [l.split('\t') for l in open('pairs.tsv').read().strip('\n').split('\n')]
ul, xl, ins, used = [], [], [], set()
for kind, slug, aid, vid in pairs:
    c = cards[slug]; assert slug not in used; used.add(slug)
    if kind == 'U': ul.append((int(aid), f"{aid}~{vid}~{c['cat']}~{c['url']}"))
    elif kind == 'X': xl.append((int(aid), f"{aid}~{vid}~{c['cat']}~{c['url']}"))
    else: ins.append((vid, c['cat'], c['url'], c['g']))
ul.sort(); xl.sort(); UL = '\n'.join(x for _, x in ul); XL = '\n'.join(x for _, x in xl)
cities = {k: v[1] for k, v in CITY.items()}
for k, s in NEWC.items(): cities[k] = 'ci_' + md5(s)[:10]
slugs = {k: v[0] for k, v in CITY.items()}; slugs.update(NEWC)
new = []
for slug, c in cards.items():
    if slug in used: continue
    assert c['g'] == 'poland' and c['cat'] == 'Bib Gourmand', slug
    label = c['loc'].split(', ')[0]; cs = slugs[label]; s = slugify(c['name'])
    new.append(dict(c, slug=s, label=label, cs=cs, cid=cities[label], v='ve_' + md5(f"{cs}:{s}")[:10]))
new.sort(key=lambda c: c['v'])
NW = '\n'.join(f"{c['v']}~{c['slug']}~{c['cs']}~{c['cid']}~{c['label']}~Poland~{c['name']}" for c in new)
aw = sorted([(v, cat, url) for v, cat, url, g in ins] + [(c['v'], c['cat'], c['url']) for c in new])
AW = '\n'.join('~'.join(x) for x in aw)
nu, nx, na, nv = len(ul), len(xl), len(aw), len(new); nl = nv * 2
assert (nu, nx, na, nv) == (5, 8, 86, 19), (nu, nx, na, nv)
CC = {}
for c in new: CC[c['label']] = CC.get(c['label'], 0) + 1
assert sum(CC.values()) == 19
nc = len(NEWC); assert all(k in CC for k in NEWC)
upd = [k for k in CITY if k in CC]; assert len(upd) == 5
gi = {}
for v, cat, url, g in ins: gi[g] = gi.get(g, 0) + 1
assert gi == {'croatia': 22, 'slovenia': 19, 'poland': 26}, gi
tot = nu + na + nv * 3 + nl + nc + len(upd)
led = []
for g, n, ups, extra in (('poland', 45, 1, ', 19 new venues, 9 new cities'), ('croatia', 22, 2, ''), ('slovenia', 19, 2, '')):
    nm, url = ART[g]
    led.append(f"('michelin','award',{n+ups},'cleanup:{KEY} | rule 2.1.1 and 2.1.7: {nm}, {url} | legacy 2025 rows stay, relabel 0, retire 0 | {n} new rows{extra}, {ups} rows labelled 2026 get the card URL | relay sha256 {SHA} | {APPROVAL}')")
led.append(f"('michelin','city_label',{nl},'cleanup:{KEY} | city labels of {nv} new Poland venues | {APPROVAL}')")
ml = len(led)
yc = {y: B[f"m{str(y)[2:]}"] for y in (2024, 2025, 2026, 2027)}
ya = dict(yc); ya[2026] += na
AUD = f'awards:INSERT={na},awards:UPDATE={nu},cities:INSERT={nc},cities:UPDATE={len(upd)},city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}'
POST = '2025:Bib Gourmand=44,2025:One Star=25,2025:Three Stars=1,2025:Two Stars=3,2026:Bib Gourmand=64,2026:One Star=31,2026:Service Award=2,2026:Sommelier Award=1,2026:Three Stars=1,2026:Two Stars=3'
cg = ' OR '.join(f"(SELECT venues_count FROM cities WHERE id='{CITY[k][1]}') <> {CITY[k][2]}" for k in upd)
cu = '\n'.join(f"  UPDATE cities SET venues_count={CITY[k][2]+CC[k]} WHERE id='{CITY[k][1]}' AND venues_count={CITY[k][2]}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city {CITY[k][0]}'; END IF;" for k in upd)
ci = '\n'.join(f"  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('{cities[k]}', '{s}', '{k}', 'Poland', 'PL', 'city', NULL, NULL, NULL, {CC[k]});" for k, s in NEWC.items())
cc = ' OR '.join(f"EXISTS (SELECT 1 FROM cities WHERE id='{cities[k]}' OR slug='{s}') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('{k}'))" for k, s in NEWC.items())
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group B: Poland, Croatia, Slovenia 2026. {APPROVAL}. This file runs only after Ben's "go".
-- {na} new 2026 rows (Poland 45, Croatia 22, Slovenia 19), /us/en/ card URL. {nu} rows already labelled 2026 get the card URL. {nx} sourced rows checked, no change. Legacy 2025 rows stay. Relabel 0. Retire 0.
-- {nv} new venues and {nc} new cities, all Poland.
-- Source: docs/michelin-b-2026-11-06/{RELAY} sha256 {SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']+nc}, sum {B['sum']+nv}; ledger {B['led']+ml} rows; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  ul text := $plan${UL}$plan$;
  xl text := $plan${XL}$plan$;
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; first_award bigint; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(ul) <> '{md5(UL)}' OR md5(xl) <> '{md5(XL)}' OR md5(aw) <> '{md5(AW)}' OR md5(nw) <> '{md5(NW)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND {SCOPE}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE}) <> 89 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {yc[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {yc[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {yc[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {yc[2027]} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR {cg} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF {cc} THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(ul,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'url rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(xl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS DISTINCT FROM split_part(x,'~',4);
  IF n <> 0 THEN RAISE EXCEPTION 'sourced rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE EXISTS (SELECT 1 FROM awards a WHERE a.venue_id=split_part(x,'~',1) AND a.source_id='michelin' AND a.year=2026 AND a.category=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue already has the 2026 row %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(ul,E'\\n') x) OR a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',7)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(ul,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nu} THEN RAISE EXCEPTION 'url set %', n; END IF;
{ci}
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',7), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
{cu}
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),(split_part(x,'~',6),'country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2026, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '{md5(AW)}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {ya[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {ya[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {ya[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {ya[2027]} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '{POST}' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, u1, u2 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('Three Stars','Two Stars','One Star','Bib Gourmand') AND {SCOPE};
  IF n <> 99 OR u1 <> 99 OR u2 <> 99 THEN RAISE EXCEPTION 'urls after % % %', n, u1, u2; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE} GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+nc} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+ml} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > {B['aum']} GROUP BY 1,2) z;
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
open(f"{SCRATCH}/dry-b.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'url', nu, 'rows', na, 'new', nv, 'cities', nc, 'audit', tot, 'ledger', ml)
