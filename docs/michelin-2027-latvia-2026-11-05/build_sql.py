#!/usr/bin/env python3
"""Build the Michelin Latvia 2027 load file and its evidence CSV. Values come from the list read, pairs.tsv and live-read.txt.
Args: approval text, scratch dir."""
import csv, hashlib, re, sys
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2027-latvia-2026-11-05'
RELAY_SHA = '4b49d822714d5c80072e5f4c493c74819d705a8bd936eb09a034886ac860e164'
A27 = 'https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2027-winners-michelin-guide-ceremony'
A26 = 'https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2026-winners-michelin-guide-ceremony'
A25 = 'https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2025-winners-michelin-guide-ceremony'
HIST = {'ve_4e6e00fcea', 've_c8293fb725', 've_fc08eea783', 've_a79704e992', 've_99bd11222f'}
RIGA = ('riga', 'ci_922f13fdf0', 'Riga')
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
rel = open('relay-lv-2027-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(rel.encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[0]] = dict(v=p[0], a=p[1], cat=p[2], y=p[3], ci=p[4], cs=p[5], st=p[6], pr=p[7], name='|'.join(p[9:]))
assert len(live) == 7 and all(x['y'] == '2025' and x['st'] == 'active' for x in live.values())
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv', encoding='utf8').read().strip().split('\n')}
slugs = {'Baltā Kaza': 'balta-kaza', 'Café Mimosa': 'cafe-mimosa'}
cards = []
for line in rel.split('\n'):
    cat, href, name, loc, pr = dec(line).split(' | ')
    path = href.split('/restaurant/')[1]; _, v, a, how = pairs[path]
    c = dict(cat=cat, url='https://guide.michelin.com' + href, name=name, city=loc.split(', ')[0], price=pr.split(' · ')[0], how=how, v=v, a=a)
    if v == 'NEW':
        assert c['city'] == 'Riga'
        c['slug'] = slugs[name]; c['v'] = 've_' + hashlib.md5(f"riga:{c['slug']}".encode()).hexdigest()[:10]
    else:
        lv = live[v]; assert lv['a'] == a and lv['cat'] == cat
    cards.append(c)
assert len(cards) == 9 and len({c['url'] for c in cards}) == 9 and len({c['v'] for c in cards}) == 9
assert {c['v'] for c in cards if c['a'] != '-'} == set(live)
new = sorted([c for c in cards if c['a'] == '-'], key=lambda c: c['v']); assert len(new) == 2
RL = '\n'.join(f"{x['a']}|{x['v']}|{x['cat']}" for x in sorted(live.values(), key=lambda x: int(x['a'])))
AW = '\n'.join(f"{c['v']}|{c['cat']}|{c['url']}" for c in sorted(cards, key=lambda c: c['v']))
HI = '\n'.join(f"{v}|{live[v]['cat']}" for v in sorted(HIST))
NW = '\n'.join(f"{c['v']}|{c['slug']}|{RIGA[0]}|{RIGA[1]}|{RIGA[2]}|{c['name']}" for c in new)
FP = hashlib.md5('\n'.join(sorted(f"{x['a']}|{x['v']}|{x['cat']}|{x['st']}|{x['ci']}|{x['name']}" for x in live.values())).encode()).hexdigest()
RLM, AWM, HIM, NWM = (hashlib.md5(t.encode()).hexdigest() for t in (RL, AW, HI, NW))
B = dict(v=11717, va=11405, vc=312, a=28691, last=35862, s=13661, l=11717, lb=24841, ci=3325, sum=11405, riga=7, led=277, ledm=331, au=127611, aum=133440, pr=7759, rd=35, al=222, m25=4365, m26=7480, m27=122)
nr, na, nh, nv, nl = 7, 9, 5, 2, 4
ni = na + nh
tot = nr + ni + nv * 3 + nl + 1
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 6 2026. Michelin Latvia 2027 and the 2026 label. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.7: the 7 legacy rows hold the 2026 edition (Oct 22, 2025: {A26}). Relabel 2025 -> 2026, source_url = that article. Retire 0.
-- Then 9 new rows, year 2027 (Nov 5, 2026: {A27}): One Star 2, Bib Gourmand 7, source_url = the card (/us/en/). 2 new venues.
-- Then 5 history rows, year 2025, source_url = {A25}: One Star 2, Bib Gourmand 3.
-- Source: docs/michelin-2027-latvia-2026-11-05/relay-lv-2027-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+ni}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']}, sum {B['sum']+nv}; ledger {B['led']+4} rows; Michelin 2025/2026/2027 {B['m25']-nr+nh}/{B['m26']+nr}/{B['m27']+na}; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  aw text := $plan${AW}$plan$;
  hi text := $plan${HI}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{RLM}' OR md5(aw) <> '{AWM}' OR md5(hi) <> '{HIM}' OR md5(nw) <> '{NWM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Latvia' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia') <> {nr} THEN RAISE EXCEPTION 'Latvia Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT venues_count FROM cities WHERE id='{RIGA[1]}') <> {B['riga']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
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
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x) OR a.source_url IN ('{A25}','{A26}','{A27}')) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url='{A26}' WHERE a.id IN (SELECT split_part(x,'|',1)::bigint FROM regexp_split_to_table(rl,E'\\n') x);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venues, listings, slugs, city count
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities SET venues_count={B['riga']+nv} WHERE id='{RIGA[1]}' AND venues_count={B['riga']};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2027 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Latvia','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2027, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards 2027 %', n; END IF;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2025, NULL, split_part(x,'|',2), NULL, '{A25}' FROM regexp_split_to_table(hi,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nh} THEN RAISE EXCEPTION 'awards 2025 %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'relabel:{NAME} | rule 2.1.7: Latvia edition live at capture = 2026 (Oct 22, 2025, {A26}) | year 2025 -> 2026, article URL, retire 0 | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | Latvia 2027, Nov 5, 2026, {A27} | One Star 2, Bib 7 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','award',{nh},'cleanup:{NAME} | Latvia 2025 history, {A25} | One Star 2, Bib 3 | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+ni} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {ni} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2027 AND source_id='michelin') <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr+nh} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']+na} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia' AND a.source_url IS NOT NULL GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '2025:Bib Gourmand=3,2025:One Star=2,2026:Bib Gourmand=5,2026:One Star=2,2027:Bib Gourmand=7,2027:One Star=2' THEN RAISE EXCEPTION 'Latvia after %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia') <> {nr+ni} THEN RAISE EXCEPTION 'Latvia rows after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Latvia' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+4} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={ni},awards:UPDATE={nr},cities:UPDATE=1,city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
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
with open('michelin-2027-latvia-evidence-2026-11-05.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f, lineterminator='\n')
    w.writerow(['group', 'category_2027', 'card_name', 'card_city', 'card_price', 'card_url', 'venue_id', 'venue_name', 'award_id_relabelled', 'category_2026', 'new_2025_row', 'venue_price'])
    for c in sorted(cards, key=lambda c: (c['cat'], c['name'])):
        lv = live.get(c['v'])
        g = 'new venue' if not lv else c['how']
        w.writerow([g, c['cat'], c['name'], c['city'], c['price'], c['url'], c['v'], lv['name'] if lv else c['name'], lv['a'] if lv else '', lv['cat'] if lv else '', lv['cat'] if c['v'] in HIST else '', lv['pr'] if lv else ''])
print('new', [(c['name'], c['v'], c['slug']) for c in new])
for k in ('RL','AW','HI','NW'): print(k, eval(k+'M'))
