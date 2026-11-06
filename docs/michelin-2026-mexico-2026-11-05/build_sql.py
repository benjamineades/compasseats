#!/usr/bin/env python3
"""Build the Michelin Mexico 2026 load file from the list read, pairs.tsv and live-read.txt. No retyped values.
Args: approval text, scratch dir."""
import collections, hashlib, os, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2026-mexico-2026-11-05'
RELAY_SHA = 'eaa8b76fce43958a96549ce20537c6f5871a1fb48ca997be71617c08cd03b549'
ST = 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-mexico-for-2026-and-the-year-s-key-trends'
BI = 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/mexico-s-most-affordable-restaurants-in-2026'
ST25 = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-mexico-stars-green-stars'
BI25 = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-mexico-bib-gourmand-2025'
RELABEL = {'alcalde-1243800', 'xokol', 'gaba', 'la-once-mil', 'huniik', 'ixi-im'}
PINK = 've_55222b26b4'
HIST = [('ve_4e1b67f3e8', 'One Star', ST25), ('ve_ab5a360f69', 'Bib Gourmand', BI25)]
CITY = {'La Barra de Huniik': 'merida', 'Vica Cocina de un Valle': 'atlixco', 'ICÚ': 'puerto-vallarta', 'Cultivo': 'heroica-puebla-de-zaragoza', 'Pueblo Pibil': 'tixkokob', 'Taquerías Kisín': 'merida',
 'Tacos Y Gorditas Elvira': 'guadalajara', 'Semitas "Beto"': 'heroica-puebla-de-zaragoza', 'palReal': 'guadalajara', 'Los Camellos': 'heroica-puebla-de-zaragoza', 'Moyuelo': 'heroica-puebla-de-zaragoza',
 'Jacinto y Yo': 'heroica-puebla-de-zaragoza', 'El Bambis Café': 'monterrey', 'El Güero Marinero': 'heroica-puebla-de-zaragoza', 'Molino El Pujol': 'mexico-city', 'Restaurante Casareyna': 'heroica-puebla-de-zaragoza', 'Pancho Maiz': 'merida'}
CID = {'merida': ('ci_f020927946', 3, 'Mérida'), 'guadalajara': ('ci_1431b98607', 5, 'Guadalajara'), 'heroica-puebla-de-zaragoza': ('ci_5bc399fd77', 1, 'Heroica Puebla de Zaragoza'), 'monterrey': ('ci_4e9eaa94e2', 5, 'Monterrey'), 'mexico-city': ('ci_002aaa1d1e', 68, 'Mexico City')}
NEWC = {'atlixco': 'Atlixco', 'puerto-vallarta': 'Puerto Vallarta', 'tixkokob': 'Tixkokob'}
for s in NEWC: CID[s] = ('ci_' + hashlib.md5(s.encode()).hexdigest()[:10], 0, NEWC[s])
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
rel = open('relay-mx-2026-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(rel.encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[1]] = dict(v=p[0], a=p[1], cat=p[2], y=p[3], ci=p[4], st=p[6], url=p[9], name='|'.join(p[10:]))
assert len(live) == 76
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv').read().split('\n')}
RLL, AWL, NWL = [], [], []; CC = collections.Counter()
for line in rel.split('\n'):
    cat, href, name, loc, _pr = dec(line).split(' | '); path = href.split('/restaurant/')[1]; _, v, a, how = pairs[path]; url = 'https://guide.michelin.com' + href
    if v == 'NEW':
        cs = CITY[name]; ci, _, cd = CID[cs]; sl = slugify(name); v = 've_' + hashlib.md5(f"{cs}:{sl}".encode()).hexdigest()[:10]; assert '|' not in name
        NWL.append(f"{v}|{sl}|{cs}|{ci}|{cd}|{loc.split(', ')[0]}|{name}"); AWL.append(f"{v}|{cat}|{url}|2026"); CC[cs] += 1
    elif path in RELABEL:
        lv = live[a]; assert lv['v'] == v and lv['cat'] == cat and lv['y'] == '2025' and lv['st'] == 'active' and lv['url'] == ''
        RLL.append(f"{a}|{v}|{cat}|{url}")
    else:
        AWL.append(f"{v}|{cat}|{url}|2026")
AWL.append(f"{PINK}|Bib Gourmand|{BI}|2026")
for v, c, u in HIST: AWL.append(f"{v}|{c}|{u}|2025")
assert len(RLL) == 6 and len(NWL) == 17 and len(AWL) == 88
RL = '\n'.join(sorted(RLL, key=lambda r: int(r.split('|')[0]))); AW = '\n'.join(sorted(AWL)); NW = '\n'.join(sorted(NWL))
FP = hashlib.md5('\n'.join(sorted((f"{a['a']}|{a['v']}|{a['cat']}|{a['st']}|{a['ci']}|{a['name']}" for a in live.values()), key=lambda s: s.encode())).encode()).hexdigest()
RLM, AWM, NWM = (hashlib.md5(x.encode()).hexdigest() for x in (RL, AW, NW))
B = dict(v=11699, va=11391, vc=308, a=28593, last=35764, s=13643, l=11699, lb=24805, ci=3322, sum=11391, led=271, ledm=325, au=127173, aum=133002, pr=7759, rd=35, al=222, m25=4369, m26=7378, m27=122)
nr, na, nv, nl, ncn = len(RLL), len(AWL), len(NWL), 2 * len(NWL), len(NEWC)
nh = len(HIST); n26 = na - nh
UPD = {k: v for k, v in CC.items() if k not in NEWC}
tot = nr + na + nv * 3 + nl + ncn + len(UPD)
aud = f"awards:INSERT={na},awards:UPDATE={nr},cities:INSERT={ncn},cities:UPDATE={len(UPD)},city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}"
cg = ' OR '.join(f"(SELECT venues_count FROM cities WHERE id='{CID[k][0]}') <> {CID[k][1]}" for k in sorted(UPD))
cu = '\n'.join(f"  UPDATE cities SET venues_count={CID[k][1] + UPD[k]} WHERE id='{CID[k][0]}' AND venues_count={CID[k][1]};\n  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city {k} %', n; END IF;" for k in sorted(UPD))
ci_ins = '\n'.join(f"  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('{CID[s][0]}', '{s}', '{NEWC[s]}', 'Mexico', 'MX', 'city', NULL, NULL, NULL, {CC[s]});" for s in sorted(NEWC))
ci_gate = ' OR '.join(f"EXISTS (SELECT 1 FROM cities WHERE id='{CID[s][0]}' OR slug='{s}') OR EXISTS (SELECT 1 FROM city_aliases WHERE alias='{NEWC[s].lower()}')" for s in sorted(NEWC))
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin Mexico 2026. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: ceremony May 20, 2026, inside the capture window ({ST}). Test of named promotions: 6 of 7 new stars are in the live rows, 0 of 16 new Bibs. Result: mixed.
-- Relabel 6 rows 2025 -> 2026, card URL: the 6 new stars, which cannot be 2025 rows. The other 70 rows stay 2025, no URL. Retire 0.
-- New awards: {n26} rows 2026 (card URL; Pink Rambo = Bib article URL, card 404). {nh} rows 2025 (Em One Star, Gaba Bib Gourmand), article URL.
-- New venues: {nv}, card name, restaurant, active, published. New cities: {ncn}. No price, address, geo, blurb or chef.
-- Source: docs/michelin-2026-mexico-2026-11-05/relay-mx-2026-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']+ncn}, sum {B['sum']+nv}; ledger {B['led']+3} rows; Michelin 2025/2026/2027 {B['m25']-nr+nh}/{B['m26']+nr+n26}/{B['m27']}; audit_log +{tot}.
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
    WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX') <> 76 THEN RAISE EXCEPTION 'Mexico Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF {cg} THEN RAISE EXCEPTION 'city counts before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) AND v.status='active' AND c.country_iso='MX');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x UNION ALL SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x UNION ALL SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  -- New cities and venues
  IF {ci_gate} THEN RAISE EXCEPTION 'city clash'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',7))),'[^a-z0-9]+','-','g')) OR split_part(x,'|',4) <> 'ci_'||left(md5(split_part(x,'|',3)),10) AND split_part(x,'|',3) NOT IN (SELECT slug FROM cities);
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) OR (c.country_iso='MX' AND v.norm_key=norm_key(split_part(x,'|',7)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: cities
{ci_ins}
{cu}
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',7), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows. The label is the card city.
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',6),'city_display'),('Mexico','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', split_part(x,'|',4)::int, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'relabel:{NAME} | rule 2.1.7: ceremony May 20, 2026 ({ST}), inside the capture window, test mixed | 6 new stars, year 2025 -> 2026, source_url = the card (/us/en/), 70 rows stay 2025, retire 0 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | {n26} rows 2026, card URL, Pink Rambo = article URL ({BI}) | {nh} rows 2025, article URL | list read Nov 5, 2026 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues, new cities atlixco, puerto-vallarta, tixkokob | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) FROM (SELECT venue_id||'|'||category||'|'||source_url||'|'||year t FROM awards WHERE id > first_award AND source_id='michelin') z) <> md5((SELECT string_agg(x, E'\\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr+nh} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr+n26} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=63,One Star=27,Two Stars=2' THEN RAISE EXCEPTION 'Mexico 2026 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2025 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=49,One Star=21,Two Stars=2' THEN RAISE EXCEPTION 'Mexico 2025 %', s; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 92 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso='MX' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']+ncn} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+3} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '{aud}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(NAME + '.sql', 'w', encoding='utf8').write(sql)
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'audit', tot, 'fp', FP, 'upd', dict(UPD), 'city ids', {s: CID[s][0] for s in NEWC})
print(NW)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: relabel')
open(os.path.join(SCRATCH, 'dry.sql'), 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
