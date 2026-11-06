#!/usr/bin/env python3
"""Build the Michelin Beijing & Tianjin 2027 load file and its evidence CSV. Values come from the list read and live-read.txt.
Args: approval text, scratch dir."""
import csv, hashlib, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2027-beijing-tianjin-2026-11-05'
RELAY_SHA = 'f1e9d7ed6382d85cd75b17195953747a6938b9bce3d4be548b1aee28ec84b608'
A27 = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-beijing-tianjin-2027'
HAND = {'chef-1996': 've_eeddf12653', 'old-tower': 've_1c7406cc48'}
BJ = 'ci_0420a206ae'; TJ = 'ci_' + hashlib.md5(b'tianjin').hexdigest()[:10]
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
def key(n): return re.sub(r'[^a-z0-9]', '', slugify(n))
rel = open('relay-bj-tj-2027-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(rel.encode()).hexdigest() == RELAY_SHA
live = {}; byurl = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); x = dict(v=p[0], a=p[1], cat=p[2], y=p[3], ci=p[4], st=p[6], pr=p[7], name=p[9], url=p[10]); live[p[0]] = x; byurl[p[10]] = x
assert len(live) == 58 and all(x['y'] == '2026' and x['st'] == 'active' and x['ci'] == BJ for x in live.values())
cards = []; 
for line in rel.split('\n'):
    cat, href, name, loc, pr = dec(line).split(' | ')
    path = href.split('/restaurant/')[1]; city = loc.split(', ')[0]; assert city in ('Beijing', 'Tianjin')
    c = dict(cat=cat, path=path, url='https://guide.michelin.com' + href, name=name, city=city, price=pr.split(' · ')[0])
    if href in byurl:
        c['v'] = byurl[href]['v']; c['g'] = 'paired by card URL'
    elif path in HAND:
        c['v'] = HAND[path]; c['g'] = 'live venue, first Michelin row'
    else:
        cs = city.lower(); c['slug'] = slugify(name); c['cs'] = cs; c['ci'] = BJ if city == 'Beijing' else TJ; c['v'] = 've_' + hashlib.md5(f"{cs}:{c['slug']}".encode()).hexdigest()[:10]; c['g'] = 'new venue'
    cards.append(c)
assert len(cards) == 82 and len({c['url'] for c in cards}) == 82 and len({c['v'] for c in cards}) == 82
new = sorted([c for c in cards if c['g'] == 'new venue'], key=lambda c: c['v'])
assert len(new) == 24 and sum(c['city'] == 'Beijing' for c in new) == 7 and sum(c['city'] == 'Tianjin' for c in new) == 17
nocard = sorted(set(live) - {c['v'] for c in cards}, key=lambda v: live[v]['name']); assert [live[v]['name'] for v in nocard] == ['Jing', 'Ladychai']
AW = '\n'.join(f"{c['v']}|{c['cat']}|{c['url']}" for c in sorted(cards, key=lambda c: c['v']))
NW = '\n'.join(f"{c['v']}|{c['slug']}|{c['cs']}|{c['ci']}|{c['city']}|{c['name']}" for c in new)
HA = '\n'.join(f"{v}|{p}" for p, v in sorted(HAND.items()))
FP = hashlib.md5('\n'.join(sorted(f"{x['a']}|{x['v']}|{x['cat']}|{x['st']}|{x['name']}|https://guide.michelin.com{x['url']}" for x in live.values())).encode()).hexdigest()
AWM, NWM = (hashlib.md5(t.encode()).hexdigest() for t in (AW, NW))
B = dict(v=11730, va=11418, vc=312, a=28746, last=35917, s=13674, l=11730, lb=24867, ci=3327, sum=11418, bj=80, led=284, ledm=338, au=127778, aum=133607, pr=7759, rd=35, al=222, m25=4329, m26=7521, m27=172)
na, nv, nl = 82, 24, 48
tot = na + nv * 3 + nl + 2
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 6 2026. Michelin Beijing & Tianjin 2027. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.7, Tokyo row of the table: the 58 Beijing tier rows are sourced 2026 rows (Oct 2025 edition). They stay as history. Relabel 0, retire 0.
-- 82 new rows, year 2027 (Oct 26-27, 2026: {A27}): Three Stars 2, Two Stars 5, One Star 27, Bib Gourmand 48, source_url = the card (/us/en/). 24 new venues, new city Tianjin.
-- 56 of the card URLs repeat on the 2026 row of the same venue. This is expected.
-- Source: docs/michelin-2027-beijing-tianjin-2026-11-05/relay-bj-tj-2027-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']+1}, sum {B['sum']+nv}; ledger {B['led']+2} rows; Michelin 2025/2026/2027 {B['m25']}/{B['m26']}/{B['m27']+na}; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(aw) <> '{AWM}' OR md5(nw) <> '{NWM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.name||'|'||a.source_url t
    FROM awards a JOIN venues v ON v.id=a.venue_id
    WHERE a.source_id='michelin' AND v.city_id='{BJ}' AND a.year=2026 AND a.category IN ('Three Stars','Two Stars','One Star','Bib Gourmand')) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id WHERE a.source_id='michelin' AND v.city_id='{BJ}' AND a.year<>2026) <> 0 THEN RAISE EXCEPTION 'Beijing rows of another year'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT venues_count FROM cities WHERE id='{BJ}') <> {B['bj']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='{TJ}' OR slug='tianjin') OR EXISTS (SELECT 1 FROM city_aliases WHERE lower(alias)='tianjin') THEN RAISE EXCEPTION 'city clash'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active' AND v.city_id='{BJ}');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN regexp_split_to_table(aw,E'\\n') x ON a.source_url=split_part(x,'|',3) WHERE NOT (a.venue_id=split_part(x,'|',1) AND a.year=2026)) THEN RAISE EXCEPTION 'url in use by another venue or year'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2027 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION '2027 row exists'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: new city, venues, listings, slugs, city count
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('{TJ}', 'tianjin', 'Tianjin', 'China', 'CN', 'city', NULL, NULL, NULL, 17);
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count={B['bj']+7} WHERE id='{BJ}' AND venues_count={B['bj']};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count beijing'; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('China','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{na},'cleanup:{NAME} | Beijing & Tianjin 2027, {A27} | Three Stars 2, Two Stars 5, One Star 27, Bib 48 | rule 2.1.7: 2026 rows stay, relabel 0, retire 0 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues, new city tianjin | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']+na} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(c.slug||':'||a.category||'='||k, ',' ORDER BY c.slug, a.category) INTO s FROM (SELECT v.city_id, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id WHERE a.source_id='michelin' AND a.year=2027 AND v.city_id IN ('{BJ}','{TJ}') GROUP BY 1,2) a JOIN cities c ON c.id=a.city_id;
  IF s IS DISTINCT FROM 'beijing:Bib Gourmand=32,beijing:One Star=26,beijing:Three Stars=2,beijing:Two Stars=5,tianjin:Bib Gourmand=16,tianjin:One Star=1' THEN RAISE EXCEPTION 'after %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id WHERE a.source_id='michelin' AND v.city_id IN ('{BJ}','{TJ}') GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+1} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+2} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={na},cities:INSERT=1,cities:UPDATE=1,city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(NAME + '.sql', 'w', encoding='utf8').write(sql)
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'audit', tot, 'fp', FP, 'TJ', TJ)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: new city')
open(SCRATCH + '/dry.sql', 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
nd = []; tier = []; prd = []
with open('michelin-2027-beijing-tianjin-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n')
    w.writerow(['group', 'category_2027', 'card_name', 'card_city', 'card_price', 'card_url', 'venue_id', 'venue_name', 'award_id_2026', 'category_2026', 'venue_price'])
    for c in sorted(cards, key=lambda c: (c['city'], c['cat'], c['name'])):
        lv = live.get(c['v'])
        if lv:
            if key(lv['name']) != key(c['name']): nd.append((lv['name'], c['name'], c['v']))
            if lv['cat'] != c['cat']: tier.append((lv['name'], lv['cat'], c['cat']))
            if lv['pr'] != c['price']: prd.append((lv['name'], lv['pr'], c['price']))
        w.writerow([c['g'], c['cat'], c['name'], c['city'], c['price'], c['url'], c['v'], lv['name'] if lv else c['name'], lv['a'] if lv else '', lv['cat'] if lv else '', lv['pr'] if lv else ''])
    for v in nocard:
        lv = live[v]; w.writerow(['no 2027 card, 2026 row kept', '', '', '', '', 'https://guide.michelin.com' + lv['url'], v, lv['name'], lv['a'], lv['cat'], lv['pr']])
print('name differs', nd); print('tier', tier); print('price', prd)
print('new', [(c['name'], c['v'], c['slug'], c['cs']) for c in new])
print('paired', sum(c['g'].startswith('paired') for c in cards), 'hand', sum(c['g'].startswith('live') for c in cards))
