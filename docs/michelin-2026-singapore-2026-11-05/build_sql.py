#!/usr/bin/env python3
"""Build the Michelin Singapore 2026 load file from the list read, pairs.tsv and live-read.txt. No retyped values.
Args: approval text, scratch dir, close|noclose (Alma, Esora), a25|noa25 (4 One Star rows of the 2025 edition)."""
import hashlib, json, os, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
CLOSE = (sys.argv[3] == 'close') if len(sys.argv) > 3 else True
A25 = (sys.argv[4] == 'a25') if len(sys.argv) > 4 else True
NAME = 'load-michelin-2026-singapore-2026-11-05'
RELAY_SHA = 'd6df72b17a315fd238ee56d19edadabdcbd073c1ae51cab391dad330b1605d8c'
ART26 = 'https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2026'
ART25 = 'https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025'
CI = 'ci_d3197fb64e'
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
raw = open('relay-sg-2026-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(raw.encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|')
    live[p[0]] = dict(id=p[0], award=p[1], cat=p[2], year=p[3], city_id=p[4], status=p[6], price=p[7], url=p[9], name='|'.join(p[12:]))
assert len(live) == 126
pairs = {}
for l in open('pairs.tsv', encoding='utf8').read().strip().split('\n'):
    k, v, a, how = l.split('\t'); pairs[k] = (v, a, how)
cards = []
for l in raw.split('\n'):
    cat, href, name, loc, pr, dist, mid, lat, lng = dec(l).split(' | ')
    assert loc == 'Singapore' and href.startswith('/us/en/singapore-region/singapore/restaurant/')
    path = href.split('/restaurant/')[1]
    v, a, how = pairs[path]
    c = dict(cat=cat, path=path, url='https://guide.michelin.com' + href, name=name, sym=pr.split(' · ')[0], cuisine=pr.split(' · ')[1], venue=v, award=a, how=how)
    if v == 'NEW':
        c['slug'] = slugify(name); c['venue'] = 've_' + hashlib.md5(f"singapore:{c['slug']}".encode()).hexdigest()[:10]
    cards.append(c)
assert len(cards) == 142 and len({c['url'] for c in cards}) == 142 and len({c['venue'] for c in cards}) == 142
new = [c for c in cards if c['how'] == 'new-venue']
assert len(new) == 17 and len({c['slug'] for c in new}) == 17
for c in cards:
    if c['award'] != '-':
        lv = live[c['venue']]; assert lv['award'] == c['award'] and lv['status'] == 'active' and lv['year'] == '2025', c
AWL = sorted(f"{c['venue']}|{c['cat']}|{c['url']}" for c in cards); AW = '\n'.join(AWL)
NW = '\n'.join(sorted(f"{c['venue']}|{c['slug']}|singapore|{CI}|Singapore|{c['name']}" for c in new))
LIVEFP = hashlib.md5('\n'.join(sorted(f"{a['award']}|{a['id']}|{a['cat']}|active|{a['city_id']}|{a['name']}" for a in live.values())).encode()).hexdigest()
A25L = [("ve_719d6d86e0", "Euphoria", "closed"), ("ve_72e993e4a4", "Esora", "active"), ("ve_8b5854c9bd", "Alma by Juan Amador", "active"), ("ve_bf2230cf37", "Imperial Treasure Fine Teochew Cuisine", "active")]
AY = '\n'.join(f"{v}|One Star|{ART25}" for v, _, _ in sorted(A25L))
AYV = '\n'.join(f"{v}|{n}|{s}" for v, n, s in sorted(A25L))
CL = "ve_72e993e4a4|Esora|active|" + CI + "\nve_8b5854c9bd|Alma by Juan Amador|active|" + CI
AWM, NWM, AYM, AYVM, CLM = (hashlib.md5(x.encode()).hexdigest() for x in (AW, NW, AY, AYV, CL))
B = dict(v=11674, va=11369, vc=305, a=28373, last=35544, s=13618, l=11674, lb=24755, ci=3321, sum=11369, led=261, ledm=315, au=126585, aum=132414, pr=7759, rd=35, al=222, m25=4596, m26=6931, m27=122, city=210)
nv, na, nl = 17, 142, 34
ny = 4 if A25 else 0
nc = 2 if CLOSE else 0
led = 2 + (1 if A25 else 0)
tot = na + ny + nv + nc + nv + nc + nv + nl + 1
aud = ','.join(x for x in [f"awards:INSERT={na+ny}", "cities:UPDATE=1", f"city_label_source:INSERT={nl}", f"listings:INSERT={nv}", f"listings:UPDATE={nc}" if nc else '', f"slugs:INSERT={nv}", f"venues:INSERT={nv}", f"venues:UPDATE={nc}" if nc else ''] if x)
s25 = f"Bib Gourmand=89,One Star={27+ny},Three Stars=3,Two Stars=7"
city_after = B['city'] + nv - nc
J = f"cleanup:{NAME}"
ayw = "" if not A25 else f"""
  -- WRITE: 2025 edition rows absent from the live rows
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2025, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(ay,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {ny} THEN RAISE EXCEPTION 'awards 2025 %', n; END IF;"""
clw = "" if not CLOSE else f"""
  -- WRITE: closures
  UPDATE venues SET status='closed' WHERE id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nc} THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x) AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nc} THEN RAISE EXCEPTION 'published %', n; END IF;"""
ayg = "" if not A25 else f"""
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(ay,E'\\n') x);
  IF s IS DISTINCT FROM '{AYVM}' THEN RAISE EXCEPTION '2025 venues %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(ay,E'\\n') x)) THEN RAISE EXCEPTION '2025 venue holds Michelin'; END IF;"""
clg = "" if not CLOSE else """
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x);
  IF s IS DISTINCT FROM (SELECT md5(string_agg(x, E'\\n' ORDER BY x COLLATE "C")) FROM regexp_split_to_table(cl,E'\\n') x) THEN RAISE EXCEPTION 'closure fingerprint %', s; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x) AND published) <> 2 THEN RAISE EXCEPTION 'closure listings'; END IF;"""
ledy = "" if not A25 else f"""
    ('michelin','award',{ny},'cleanup:{NAME} | 2025 edition One Star rows absent from the live rows: Alma, Esora, Euphoria, Imperial Treasure Fine Teochew Cuisine | Chaleur has no venue | {ART25} | {APPROVAL}'),"""
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin Singapore 2026 edition. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the ceremony was Aug 4, 2026, after June 1, so the 126 legacy rows hold the 2025 edition (article of Jul 24, 2025: {ART25}). They stay as 2025 history. Relabel 0, retire 0.
-- {na} new rows, year 2026, with the /us/en/ card URL: Three Stars 3, Two Stars 9, One Star 33, Bib Gourmand 97 ({ART26}).
-- {nv} new venues, card name, restaurant, active, published.
-- 2025 edition rows added: {ny}. Closures: {nc}.
-- Source: docs/michelin-2026-singapore-2026-11-05/relay-sg-2026-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv-nc}, closed {B['vc']+nc}); awards {B['a']+na+ny}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']}, sum {B['sum']+nv-nc}; ledger {B['led']+led} rows; Michelin 2025/2026/2027 {B['m25']+ny}/{B['m26']+na}/{B['m27']}; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  ay text := $plan${AY}$plan$;
  cl text := $plan${CL}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(aw) <> '{AWM}' OR md5(nw) <> '{NWM}' OR md5(ay) <> '{AYM}' OR md5(cl) <> '{CLM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Singapore' AND a.year=2025) y;
  IF fp IS DISTINCT FROM '{LIVEFP}' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore') <> 126 THEN RAISE EXCEPTION 'Singapore Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='{CI}') <> {B['city']} THEN RAISE EXCEPTION 'Singapore count before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active' AND v.city_id='{CI}');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;{ayg}{clg}
  -- New venues. The norm_key test is inside the city: Yong Fu in Hong Kong is another restaurant.
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR (v.city_id=split_part(x,'|',4) AND v.norm_key=norm_key(split_part(x,'|',6)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Singapore','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;{ayw}{clw}
  UPDATE cities SET venues_count={city_after} WHERE id='{CI}' AND venues_count={B['city']};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{na},'{J} | rule 2.1.1 and 2.1.7: ceremony Aug 4, 2026 ({ART26}), legacy rows hold the 2025 edition, relabel 0, retire 0 | list read Nov 5, 2026 | relay sha256 {RELAY_SHA} | {APPROVAL}'),{ledy}
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv-nc} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']+nc} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na+ny} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na+ny} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> md5((SELECT string_agg(x, E'\\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']+ny} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+na} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=97,One Star=33,Three Stars=3,Two Stars=9' THEN RAISE EXCEPTION 'Singapore 2026 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore' AND a.year=2025 GROUP BY 1) z;
  IF s IS DISTINCT FROM '{s25}' THEN RAISE EXCEPTION 'Singapore 2025 %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Singapore' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv-nc} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+led} THEN RAISE EXCEPTION 'ledger after'; END IF;
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
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'audit', tot, 'livefp', LIVEFP, 'close', CLOSE, 'a25', A25, 'city after', city_after)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: venues, listings, slugs')
open(os.path.join(SCRATCH, 'dry.sql'), 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
json.dump(cards, open(os.path.join(SCRATCH, 'cards.json'), 'w'), ensure_ascii=False)
