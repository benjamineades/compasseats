#!/usr/bin/env python3
"""Build the Michelin Philippines 2027 load file and its evidence CSV. Values come from the list read, pairs.tsv and live-read.txt.
Args: approval text, scratch dir."""
import csv, hashlib, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2027-philippines-2026-11-05'
RELAY_SHA = '08b28ab3b5cf1ee81c8e46f4469f3c6b86d18f951783b53aa91a6c5aab502cbc'
L26 = 'https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2026'
L27 = 'https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2027'
CITIES = {'manila': ('ci_198432e80d', 27, 'Manila'), 'cebu': ('ci_91b1fd2bea', 6, 'Cebu'), 'cavite': ('ci_e8e2660d1e', 1, 'Cavite')}
NEWC = {'pampanga': ('Pampanga', 2), 'las-pinas-metro-manila': ('Las Piñas - Metro Manila', 1)}
for s in NEWC: CITIES[s] = ('ci_' + hashlib.md5(s.encode()).hexdigest()[:10], 0, NEWC[s][0])
LOC = {'Makati - Metro Manila': 'manila', 'Manila - Metro Manila': 'manila', 'Cebu': 'cebu', 'Cavite': 'cavite', 'Pampanga': 'pampanga', 'Las Piñas - Metro Manila': 'las-pinas-metro-manila'}
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
def key(n): return re.sub(r'[^a-z0-9]', '', slugify(n.replace(' and ', ' ').replace('&', ' ')))
rel = open('relay-ph-2027-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(rel.encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[0]] = dict(v=p[0], a=p[1], cat=p[2], y=p[3], ci=p[4], cs=p[5], st=p[6], pr=p[7], name='|'.join(p[9:]))
assert len(live) == 34 and all(x['y'] == '2025' and x['st'] == 'active' for x in live.values())
pairs = dict(l.split('\t') for l in open('pairs.tsv', encoding='utf8').read().strip().split('\n'))
assert len(pairs) == 30
cards = []; CC = {}
for line in rel.split('\n'):
    cat, href, name, loc, pr = dec(line).split(' | ')
    path = href.split('/restaurant/')[1]; label = loc.split(', ')[0]
    c = dict(cat=cat, path=path, url='https://guide.michelin.com' + href, name=name, label=label, price=pr.split(' · ')[0], v=pairs.get(path))
    if c['v'] is None:
        cs = LOC[label]; c['cs'] = cs; c['slug'] = slugify(name); c['v'] = 've_' + hashlib.md5(f"{cs}:{c['slug']}".encode()).hexdigest()[:10]; CC[cs] = CC.get(cs, 0) + 1
    else:
        assert live[c['v']]['cat'] == cat, c
    cards.append(c)
assert len(cards) == 41 and len({c['url'] for c in cards}) == 41 and len({c['v'] for c in cards}) == 41
new = sorted([c for c in cards if 'slug' in c], key=lambda c: c['v']); assert len(new) == 11
assert CC == {'manila': 3, 'cebu': 3, 'cavite': 2, 'pampanga': 2, 'las-pinas-metro-manila': 1}
nocard = sorted(set(live) - {c['v'] for c in cards}, key=lambda v: live[v]['name']); assert len(nocard) == 4
RL = '\n'.join(f"{x['a']}|{x['v']}|{x['cat']}" for x in sorted(live.values(), key=lambda x: int(x['a'])))
AW = '\n'.join(f"{c['v']}|{c['cat']}|{c['url']}" for c in sorted(cards, key=lambda c: c['v']))
NW = '\n'.join(f"{c['v']}|{c['slug']}|{c['cs']}|{CITIES[c['cs']][0]}|{c['label']}|{c['name']}" for c in new)
FP = hashlib.md5('\n'.join(sorted(f"{x['a']}|{x['v']}|{x['cat']}|{x['st']}|{x['ci']}|{x['name']}" for x in live.values())).encode()).hexdigest()
RLM, AWM, NWM = (hashlib.md5(t.encode()).hexdigest() for t in (RL, AW, NW))
B = dict(v=11719, va=11407, vc=312, a=28705, last=35876, s=13663, l=11719, lb=24845, ci=3325, sum=11407, led=281, ledm=335, au=127643, aum=133472, pr=7759, rd=35, al=222, m25=4363, m26=7487, m27=131)
nr, na, nv, nl, nu, nc = 34, 41, 11, 22, 3, 2
tot = nr + na + nv * 3 + nl + nu + nc
upd = [s for s in CITIES if s not in NEWC]
cg = ' OR '.join(f"(SELECT venues_count FROM cities WHERE id='{CITIES[s][0]}') <> {CITIES[s][1]}" for s in upd)
cu = '\n'.join(f"  UPDATE cities SET venues_count={CITIES[s][1]+CC[s]} WHERE id='{CITIES[s][0]}' AND venues_count={CITIES[s][1]};\n  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count {s}'; END IF;" for s in upd)
ci = '\n'.join(f"  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('{CITIES[s][0]}', '{s}', '{NEWC[s][0]}', 'Philippines', 'PH', 'city', NULL, NULL, NULL, {NEWC[s][1]});" for s in NEWC)
cc = ' OR '.join(f"EXISTS (SELECT 1 FROM cities WHERE id='{CITIES[s][0]}' OR slug='{s}') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)=lower('{NEWC[s][0]}'))" for s in NEWC)
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 6 2026. Michelin Philippines 2027 and the 2026 label. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.7: the 34 legacy rows hold the 2026 edition, the first Philippine edition (Oct 30, 2025: {L26}). Relabel 2025 -> 2026, source_url = that article. Retire 0.
-- Then 41 new rows, year 2027 (Oct 29, 2026: {L27}): Two Stars 1, One Star 9, Bib Gourmand 31, source_url = the card (/us/en/). 11 new venues, 2 new cities.
-- Source: docs/michelin-2027-philippines-2026-11-05/relay-ph-2027-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']+nc}, sum {B['sum']+nv}; ledger {B['led']+3} rows; Michelin 2025/2026/2027 {B['m25']-nr}/{B['m26']+nr}/{B['m27']+na}; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{RLM}' OR md5(aw) <> '{AWM}' OR md5(nw) <> '{NWM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Philippines' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines') <> {nr} THEN RAISE EXCEPTION 'Philippines Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR {cg} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF {cc} THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x) OR a.source_url='{L26}') THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url='{L26}' WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(rl,E'\\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: new cities, venues, listings, slugs, city counts
{ci}
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
{cu}
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Philippines','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'relabel:{NAME} | rule 2.1.7: Philippines edition live at capture = 2026 (Oct 30, 2025, {L26}) | year 2025 -> 2026, article URL, retire 0 | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | Philippines 2027, Oct 29, 2026, {L27} | Two Stars 1, One Star 9, Bib 31 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues, new cities pampanga, las-pinas-metro-manila | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']+na} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines' AND a.source_url IS NOT NULL GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2026:Bib Gourmand=25,2026:One Star=8,2026:Two Stars=1,2027:Bib Gourmand=31,2027:One Star=9,2027:Two Stars=1' THEN RAISE EXCEPTION 'Philippines after %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines') <> {nr+na} THEN RAISE EXCEPTION 'Philippines rows after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Philippines' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+nc} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+3} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={na},awards:UPDATE={nr},cities:INSERT={nc},cities:UPDATE={nu},city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(NAME + '.sql', 'w', encoding='utf8').write(sql)
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'audit', tot, 'fp', FP)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: relabel')
open(SCRATCH + '/dry.sql', 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
nd = []
with open('michelin-2027-philippines-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n')
    w.writerow(['group', 'category_2027', 'card_name', 'card_city', 'card_price', 'card_url', 'venue_id', 'venue_name', 'venue_city', 'award_id_relabelled', 'category_2026', 'venue_price'])
    for c in sorted(cards, key=lambda c: (c['cat'], c['name'])):
        lv = live.get(c['v'])
        g = 'new venue' if not lv else ('same name' if key(lv['name']) == key(c['name']) else 'name differs')
        if g == 'name differs': nd.append((lv['name'], c['name'], c['v']))
        w.writerow([g, c['cat'], c['name'], c['label'], c['price'], c['url'], c['v'], lv['name'] if lv else c['name'], lv['cs'] if lv else c['cs'], lv['a'] if lv else '', lv['cat'] if lv else '', lv['pr'] if lv else ''])
    for v in nocard:
        lv = live[v]; w.writerow(['no 2027 star or Bib card, 2026 row kept', '', '', '', '', '', v, lv['name'], lv['cs'], lv['a'], lv['cat'], lv['pr']])
print('name differs', len(nd), nd)
print('new', [(c['name'], c['v'], c['slug'], c['cs']) for c in new])
print('new cities', {s: CITIES[s][0] for s in NEWC})
print('nocard', [(live[v]['name'], v) for v in nocard])
print('price symbol count differs', [(live[c['v']]['name'], live[c['v']]['pr'], c['price']) for c in cards if c['v'] in live and len(live[c['v']]['pr']) != len(c['price'])])
