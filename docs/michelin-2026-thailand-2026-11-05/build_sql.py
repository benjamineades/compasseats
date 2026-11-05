#!/usr/bin/env python3
"""Build the Michelin Thailand 2026 label load file and its evidence CSV. No retyped values."""
import csv, hashlib, json, re, sys, os, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
RL_URL = (sys.argv[3] == 'url') if len(sys.argv) > 3 else False
NAME = 'load-michelin-2026-thailand-2026-11-05'
RELAY_SHA = '4baab2de66eb6211ef805d7cb4f86ab7beee02af8cbfd63848b5d1acb2cdaff3'
CEREMONY = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-thailand-2026'
relay = open('relay-th-2026-list-pages-2026-11-05.txt', encoding='utf8').read().split('\n')
assert hashlib.sha256('\n'.join(relay).encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().split('\n'):
    p = l.split('|')
    live[p[0]] = dict(id=p[0], award=p[1], cat=p[2], year=p[3], city_id=p[4], city=p[5], status=p[6], price=p[7], nk=p[8], name='|'.join(p[9:]))
pairs = {}
for l in open('pairs.tsv').read().strip().split('\n'):
    k, v, a, how = l.split('\t')
    pairs[k] = (v, a, how)
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
    assert cc == 'th' and loc.endswith(', Thailand')
    path = href.split('/restaurant/')[1]
    v, a, how = pairs[path]
    cards.append(dict(cat=cat, path=path, url='https://guide.michelin.com' + href, name=name, city=loc.split(', ')[0], sym=pr.split(' · ')[0], cuisine=pr.split(' · ')[1], venue=v, award=a, how=how))
assert len(cards) == 180 and len({c['url'] for c in cards}) == 180
new = [c for c in cards if c['venue'] == 'NEW']
assert len(new) == 1 and new[0]['city'] == 'Bangkok'
nv0 = new[0]
nv0['slug'] = slugify(nv0['name']); nv0['venue'] = 've_' + hashlib.md5(f"bangkok:{nv0['slug']}".encode()).hexdigest()[:10]
BK = ('bangkok', 'ci_b90bbd2b87')
rows = [c for c in cards if c['award'] != '-']
assert len(rows) == 178 and len(live) == 178 and {c['venue'] for c in rows} == set(live)
for c in rows:
    lv = live[c['venue']]
    assert lv['award'] == c['award'] and lv['cat'] == c['cat'] and lv['year'] == '2025' and lv['status'] == 'active', c
add = [c for c in cards if c['award'] == '-']
assert len(add) == 2
rows.sort(key=lambda c: int(c['award']))
RL = '\n'.join(f"{c['award']}|{c['venue']}|{c['cat']}|{c['url']}" for c in rows)
AW = '\n'.join(f"{c['venue']}|{c['cat']}|{c['url']}" for c in sorted(add, key=lambda c: c['venue']))
NW = f"{nv0['venue']}|{nv0['slug']}|{BK[0]}|{BK[1]}|Bangkok|{nv0['name']}"
FP = hashlib.md5('\n'.join(sorted(f"{live[c['venue']]['award']}|{c['venue']}|{c['cat']}|active|{live[c['venue']]['city_id']}|{live[c['venue']]['name']}" for c in rows)).encode()).hexdigest()
RLM, AWM, NWM = (hashlib.md5(x.encode()).hexdigest() for x in (RL, AW, NW))
B = dict(v=11672, va=11369, vc=303, a=28366, last=35537, s=13616, l=11672, lb=24751, ci=3321, sum=11369, led=255, ledm=309, au=126227, aum=132056, pr=7759, rd=35, al=222, m25=4930, m26=6590, m27=122, oa=2859, ob=2437)
nv, na, nr, nl, nu = 1, 2, 178, 2, 1
tot = nv * 3 + na + nr + nl + nu
SET = "year=2026, source_url=split_part(x,'|',4)" if RL_URL else "year=2026"
URLNOTE = 'source_url = the card (/us/en/)' if RL_URL else 'no source_url'
J = f"relabel:{NAME}"
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin Thailand: the 2026 label. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the 178 legacy rows hold the 2026 edition (ceremony Nov 27, 2025: {CEREMONY}). Relabel 2025 -> 2026, {URLNOTE}. Retire 0.
-- Then 2 new rows, year 2026, source_url = the card (/us/en/): One Star Aksorn (live venue), Bib Gourmand Krua Apsorn (Dusit) (new venue).
-- Source: docs/michelin-2026-thailand-2026-11-05/relay-th-2026-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']}, sum {B['sum']+nv}; ledger {B['led']+3} rows; Michelin 2025/2026/2027 {B['m25']-nr}/{B['m26']+nr+na}/{B['m27']}; audit_log +{tot}.
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
    WHERE a.source_id='michelin' AND c.country='Thailand' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand') <> {nr} THEN RAISE EXCEPTION 'Thailand Michelin rows'; END IF;
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
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x) OR a.source_url IN (SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'new row venue holds Michelin'; END IF;
  -- New venue
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET {SET} FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venue, listing, slug, city count
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
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Thailand','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'{J} | rule 2.1.7: Thailand edition live at capture = 2026 (ceremony Nov 27, 2025, {CEREMONY}) | year 2025 -> 2026, {URLNOTE}, retire 0 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | Thailand 2026 rows not in the legacy rows: One Star Aksorn, Bib Gourmand Krua Apsorn (Dusit), list read Nov 5, 2026 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venue | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr+na} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=137,One Star=33,Three Stars=2,Two Stars=8' THEN RAISE EXCEPTION 'Thailand 2026 %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand' AND a.year<>2026) THEN RAISE EXCEPTION 'Thailand other year'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
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
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'audit', tot, 'fp', FP, 'url', RL_URL)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: relabel')
open(SCRATCH + '/dry.sql', 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
n = {}; pd = []
sym = {'$': '฿', '$$': '฿฿', '$$$': '฿฿฿', '$$$$': '฿฿฿฿'}
for c in cards:
    lv = live.get(c['venue'])
    g = 'new venue' if c['how'] == 'new-venue' else 'live venue, no Michelin row' if c['how'] == 'new-row' else 'same name' if key(c['name']) == key(lv['name']) else 'name differs'
    n[g] = n.get(g, 0) + 1
    c['g'] = g
    if lv and lv['price'] and sym.get(lv['price']) != c['sym']: pd.append((c['name'], lv['price'], c['sym']))
print(n); print('price differs', len(pd), pd[:60])
json.dump(cards, open(SCRATCH + '/cards.json', 'w'), ensure_ascii=False)
# Evidence CSV
WEAK = {'baan-pu-karn': 'card 15 Mu 5, Wat Tum; old site 48 Thanon Uthong: different place name and address',
        'chai-phochana': 'card 4 Soi Samakkhi 38, Tha Sai; old site Soi Sam Chai, Bang Kraso: different address',
        'sanae-thai-cuisine': "card 68 Soi Ban Khang Wat Ram Poeng, Suthep; old site 8/1 Suk Kasame Rd, Su Thep: different address, a hotel name",
        'so-jeng': 'card 599/3-4 Mu 2, Ban Phai; old site 484 Mu 14, Nai Mueang: same name, other branch',
        'jun-hom': 'card 8/3 Mu 5, Mae Nam; old site 7/3, Mae Nam: same district, number differs',
        'prasit-pochana': 'card 44/4 Ammart Road; old site Pricha Prasit Rd, Nai Mueang: a road name, no number'}
with open('michelin-2026-thailand-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n')
    w.writerow(['group', 'category', 'card_name', 'card_city', 'card_price', 'card_url', 'venue_id', 'venue_name', 'award_id_relabelled', 'venue_price', 'note'])
    for c in sorted(cards, key=lambda c: (c['cat'], c['city'], c['name'])):
        lv = live.get(c['venue'])
        g = 'pair, weak' if c['path'] in WEAK else c['g']
        w.writerow([g, c['cat'], c['name'], c['city'], c['sym'], c['url'], c['venue'], lv['name'] if lv else c['name'], c['award'] if c['award'] != '-' else '', lv['price'] if lv else '', WEAK.get(c['path'], '')])
