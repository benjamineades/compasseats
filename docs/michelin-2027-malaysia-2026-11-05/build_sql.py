#!/usr/bin/env python3
"""Build the Michelin Kuala Lumpur & Penang 2027 load file and its evidence CSV. No retyped values."""
import csv, hashlib, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2027-malaysia-2026-11-05'
relay = open('relay-my-2027-list-pages-2026-11-05.txt', encoding='utf8').read().split('\n')
assert hashlib.sha256('\n'.join(relay).encode()).hexdigest() == 'f145be1e1f8128f22059cfef8cf700efb4aac9bce039efc9dcc5dd048cb67fb0'
live_txt = open('live-read.txt', encoding='utf8').read()
assert hashlib.md5(live_txt.encode()).hexdigest() == '245d878ced4124c2fd6320f4d16bb980'
live = {}
for l in live_txt.split('\n'):
    p = l.split('|')
    live[p[0]] = dict(id=p[0], award=p[1], cat=p[2], year=p[3], city_id=p[4], city=p[5], status=p[6], price=p[7], nk=p[8], name='|'.join(p[9:]))
pairs = {}
for l in open('pairs.tsv').read().strip().split('\n'):
    k, v, a, _ = l.split('\t')
    pairs[k] = (v, a)
CITY = {'Kuala Lumpur': ('kuala-lumpur', 'ci_3531a466fc'), 'George Town': ('george-town', 'ci_021dfa5a5a'), 'Seberang Perai': ('seberang-perai', 'ci_1ba468de61')}
def key(n):
    s = unicodedata.normalize('NFKD', n.lower().replace('’', "'"))
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '', s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
cards = []
for l in relay:
    cat, href, name, loc, pr, cc, dist = l.split(' | ')
    cityl, country = loc.split(', ')
    assert cc == 'my' and country == 'Malaysia'
    path = href.split('/restaurant/')[1]
    v, a = pairs[path]
    sym = pr.split(' · ')[0]
    cuisine = pr.split(' · ')[1]
    cards.append(dict(cat=cat, path=path, url='https://guide.michelin.com' + href, name=name, city=cityl, sym=sym, cuisine=cuisine, venue=v, award=a))
assert len(cards) == 70 and len({c['url'] for c in cards}) == 70
new = [c for c in cards if c['venue'] == 'NEW']
assert len(new) == 4
for c in new:
    cs = CITY[c['city']][0]
    c['slug'] = slugify(c['name'])
    c['venue'] = 've_' + hashlib.md5(f"{cs}:{c['slug']}".encode()).hexdigest()[:10]
for c in cards:
    if c['award'] != '-':
        lv = live[c['venue']]
        assert lv['award'] == c['award'] and lv['cat'] == c['cat'], c
        assert lv['city_id'] == CITY[c['city']][1], c
assert len({c['venue'] for c in cards}) == 70
relabel = sorted((v for v in live.values() if v['award'] != '-'), key=lambda v: int(v['award']))
assert len(relabel) == 66
RL = '\n'.join(f"{v['award']}|{v['id']}|{v['cat']}" for v in relabel)
AW = '\n'.join(f"{c['venue']}|{c['cat']}|{c['url']}" for c in sorted(cards, key=lambda c: c['venue']))
NW = '\n'.join(f"{c['venue']}|{c['slug']}|{CITY[c['city']][0]}|{CITY[c['city']][1]}|{c['city']}|{c['name']}" for c in new)
ids = ','.join(v['award'] for v in relabel)
FP = hashlib.md5('\n'.join(sorted(f"{v['award']}|{v['id']}|{v['cat']}|{v['status']}|{v['city_id']}|{v['name']}" for v in relabel)).encode()).hexdigest()
AWM = hashlib.md5(AW.encode()).hexdigest()
RLM = hashlib.md5(RL.encode()).hexdigest()
NWM = hashlib.md5(NW.encode()).hexdigest()
B = dict(v=11668, va=11365, vc=303, a=28296, last=35467, s=13612, l=11668, lb=24743, ci=3321, sum=11365, led=252, ledm=306, au=126068, aum=131897, pr=7759, rd=35, al=222, m25=4996, m26=6524, m27=52, oa=2859, ob=2437)
nv, na, nr, nl, nu = 4, 70, 66, 8, 3
tot = nv * 3 + na + nr + nl + nu
J = f"relabel:{NAME}"
CEREMONY26 = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/malaysia-full-selection-2026'
RELAY_SHA = 'f145be1e1f8128f22059cfef8cf700efb4aac9bce039efc9dcc5dd048cb67fb0'
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin Kuala Lumpur & Penang 2027 and the 2026 label. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.7: the 66 legacy rows hold the 2026 edition (ceremony Nov 11, 2025: {CEREMONY26}). Relabel 2025 -> 2026. No source_url. Retire 0.
-- Then 70 new rows, year 2027: Two Stars 1, One Star 9, Bib Gourmand 60, source_url = the card (/us/en/). 4 new venues.
-- Source: docs/michelin-2027-malaysia-2026-11-05/relay-my-2027-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']}, sum {B['sum']+nv}; ledger {B['led']+3} rows; Michelin 2025/2026/2027 {B['m25']-nr}/{B['m26']+nr}/{B['m27']+na}; audit_log +{tot}.
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
    WHERE a.source_id='michelin' AND c.country='Malaysia' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia') <> {nr} THEN RAISE EXCEPTION 'Malaysia Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
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
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026 WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(rl,E'\\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venues, listings, slugs, city counts
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + y.k FROM (SELECT split_part(x,'|',4) id, count(*)::int k FROM regexp_split_to_table(nw,E'\\n') x GROUP BY 1) y WHERE c.id=y.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nu} THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Malaysia','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'{J} | rule 2.1.7: Kuala Lumpur & Penang edition live at capture = 2026 (ceremony Nov 11, 2025, {CEREMONY26}) | year 2025 -> 2026, no per-row URL, retire 0 | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | Kuala Lumpur & Penang 2027, ceremony Nov 4, 2026 | Two Stars 1, One Star 9, Bib 60 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']+na} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia' AND a.year=2027 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=60,One Star=9,Two Stars=1' THEN RAISE EXCEPTION 'Malaysia 2027 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=57,One Star=8,Two Stars=1' THEN RAISE EXCEPTION 'Malaysia 2026 %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Malaysia' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+3} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={na},awards:UPDATE={nr},cities:UPDATE={nu},city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
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
# Evidence
with open('michelin-2027-malaysia-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n')
    w.writerow(['group', 'category_2027', 'card_name', 'card_city', 'card_price', 'card_url', 'venue_id', 'venue_name', 'award_id_relabelled', 'category_2026_label', 'venue_price', 'price_differs'])
    n = {}
    for c in sorted(cards, key=lambda c: (c['cat'], c['city'], c['name'])):
        lv = live.get(c['venue'])
        if c['path'] in ('lama', 'ghee-lian', 'sifu'): g = 'pair, weak name'
        elif lv is None: g = 'new venue'
        elif c['award'] == '-': g = 'live venue, no earlier Michelin row'
        elif key(c['name']) == key(lv['name']): g = 'same name'
        else: g = 'name differs'
        n[g] = n.get(g, 0) + 1
        d = '' if not lv or not lv['price'] else ('yes' if lv['price'] != c['sym'] else 'no')
        w.writerow([g, c['cat'], c['name'], c['city'], c['sym'], c['url'], c['venue'], lv['name'] if lv else c['name'], c['award'] if c['award'] != '-' else '', lv['cat'] if lv and lv['cat'] != '-' else '', lv['price'] if lv else '', d])
    a = live['ve_8170285a94']
    w.writerow(['left the list, 2026 row kept', '', '', '', '', '', a['id'], a['name'], a['award'], a['cat'], a['price'], ''])
print(n)
pd = [(c['name'], live[c['venue']]['price'], c['sym']) for c in cards if c['venue'] in live and live[c['venue']]['price'] and live[c['venue']]['price'] != c['sym']]
print('price differs', len(pd), pd)
print('new', [(c['name'], c['venue'], c['slug'], c['city'], c['sym']) for c in new])
