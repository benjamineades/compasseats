#!/usr/bin/env python3
"""Build the Michelin Austria 2026 label load file and its evidence CSV. No retyped values.
Args: approval text, scratch dir, url|nourl (card URL on relabelled rows)."""
import csv, hashlib, json, os, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
RL_URL = (sys.argv[3] != 'nourl') if len(sys.argv) > 3 else True
NAME = 'load-michelin-2026-austria-2026-11-05'
RELAY_SHA = 'a7a3ea3d880885565f1865c38e9fa15edd5029b329114e3396e31cc5f21b0c80'
STARS = 'https://guide.michelin.com/at/en/article/michelin-guide-ceremony/all-starred-restaurants---michelin-guide-austria-2026'
BIBS = 'https://guide.michelin.com/at/en/article/michelin-guide-ceremony/the-new-bib-gourmands-for-austria-2026---26-times-our-best-value'
OWN = 'https://www.schlosskellersuedsteiermark.at/'
relay = open('relay-at-2026-list-pages-2026-11-05.txt', encoding='utf8').read().split('\n')
assert hashlib.sha256('\n'.join(relay).encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|')
    live[p[0]] = dict(id=p[0], award=p[1], cat=p[2], year=p[3], city_id=p[4], city=p[5], status=p[6], price=p[7], nk=p[8], name='|'.join(p[9:]))
pairs = {}
for l in open('pairs.tsv').read().strip().split('\n'):
    k, v, a, how = l.split('\t')
    pairs[k] = (v, a, how)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
cards = []
for l in relay:
    cat, href, name, loc, pr, cc, dist = l.split(' | ')
    assert cc == 'at' and loc.endswith(', Austria')
    path = href.split('/restaurant/')[1]
    v, a, how = pairs[path]
    cards.append(dict(cat=cat, path=path, url='https://guide.michelin.com' + href, name=name, city=loc.split(', ')[0], sym=pr.split(' · ')[0], cuisine=pr.split(' · ')[1], venue=v, award=a, how=how))
assert len(cards) == 159 and len({c['url'] for c in cards}) == 159
new = [c for c in cards if c['venue'] == 'NEW']
assert len(new) == 1 and new[0]['path'] == 'thaller-restaurant'
nv0 = new[0]
SV = ('sankt-veit-am-vogau', 'ci_1dd325947d')
nv0['slug'] = slugify(nv0['name']); nv0['venue'] = 've_' + hashlib.md5(f"{SV[0]}:{nv0['slug']}".encode()).hexdigest()[:10]
rl = [c for c in cards if c['award'] != '-']
assert len(rl) == 155
for c in rl:
    lv = live[c['venue']]
    assert lv['award'] == c['award'] and lv['cat'] == c['cat'] and lv['year'] == '2025' and lv['status'] == 'active', c
SK1, SK2, WG = 've_fb7dc1ff33', 've_d3fd2ae165', 've_3019edc0d9'
assert live[SK1]['award'] == '5897' and live[SK2]['award'] == '5898' and live[WG]['award'] == '5938'
RLL = [f"{c['award']}|{c['venue']}|{c['cat']}|{c['url'] if RL_URL else ''}" for c in rl] + [f"5897|{SK1}|One Star|{STARS if RL_URL else ''}"]
RLL.sort(key=lambda x: int(x.split('|')[0]))
assert len(RLL) == 156
RL = '\n'.join(RLL)
add = [c for c in cards if c['award'] == '-']
assert len(add) == 4
AWL = [f"{c['venue']}|{c['cat']}|{c['url']}" for c in add] + [f"{SK2}|Bib Gourmand|"]
AWL.sort()
AW = '\n'.join(AWL)
NW = f"{nv0['venue']}|{nv0['slug']}|{SV[0]}|{SV[1]}|Sankt Veit am Vogau|{nv0['name']}"
FP = hashlib.md5('\n'.join(sorted((f"{x.split('|')[0]}|{x.split('|')[1]}|{x.split('|')[2]}|active|{live[x.split('|')[1]]['city_id']}|{live[x.split('|')[1]]['name']}" for x in RLL))).encode()).hexdigest()
CL = f"{SK1}|Schlosskeller Südsteiermark|active|ci_f957c08967\n{SK2}|Schlosskeller Wirtshaus|active|ci_f957c08967"
RLM, AWM, NWM, CLM = (hashlib.md5(x.encode()).hexdigest() for x in (RL, AW, NW, CL))
B = dict(v=11673, va=11370, vc=303, a=28368, last=35539, s=13617, l=11673, lb=24753, ci=3321, sum=11370, led=258, ledm=312, au=126413, aum=132242, pr=7759, rd=35, al=222, m25=4752, m26=6770, m27=122)
nv, na, nr, nl, nc = 1, 5, 156, 2, 2
tot = nr + na + nv + nc + nv + nc + nv + 2 + nl
URLNOTE = 'source_url = the card (/us/en/), the star article for 5897' if RL_URL else 'no source_url'
J = f"relabel:{NAME}"
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin Austria: the 2026 label. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the legacy rows hold the 2026 edition (selection Mar 18, 2026: {STARS}). Relabel 156 rows 2025 -> 2026, {URLNOTE}. Retire 0.
-- 2 sourced 2025 Bib rows (5898, 5938, URL = the 2025 Bib article) stay as 2025 history.
-- 5 new rows, year 2026: One Star TIAN, One Star Kirchenwirt (Leogang), One Star Thaller - Restaurant (new venue), Bib Wörgötter - Wirtshaus, all with the card URL. Bib Schlosskeller Wirtshaus, no URL (card gone).
-- 2 venues to closed, published false: Schlosskeller Südsteiermark, Schlosskeller Wirtshaus. Own site: "Restaurantbetrieb wurde mit 19. Oktober 2026 eingestellt" ({OWN}).
-- Source: docs/michelin-2026-austria-2026-11-05/relay-at-2026-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
-- OPUS (Vienna): on the star article, card 404 on Nov 5. No venue, no row in this file.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv-nc}, closed {B['vc']+nc}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']}, sum {B['sum']+nv-nc}; ledger {B['led']+3} rows; Michelin 2025/2026/2027 {B['m25']-nr}/{B['m26']+nr+na}/{B['m27']}; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  cl text := $plan${CL}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{RLM}' OR md5(aw) <> '{AWM}' OR md5(nw) <> '{NWM}' OR md5(cl) <> '{CLM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Austria' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria') <> 158 THEN RAISE EXCEPTION 'Austria Michelin rows'; END IF;
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
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT nullif(split_part(x,'|',3),'') FROM regexp_split_to_table(aw,E'\\n') x) OR a.source_url IN (SELECT nullif(split_part(x,'|',4),'') FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'new row venue holds Michelin 2026'; END IF;
  -- Closures
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x);
  IF s IS DISTINCT FROM (SELECT md5(string_agg(x, E'\\n' ORDER BY x COLLATE "C")) FROM regexp_split_to_table(cl,E'\\n') x) THEN RAISE EXCEPTION 'closure fingerprint %', s; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_f957c08967') <> 2 OR (SELECT venues_count FROM cities WHERE id='{SV[1]}') <> 1 THEN RAISE EXCEPTION 'city counts before'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x) AND published) <> 2 THEN RAISE EXCEPTION 'closure listings'; END IF;
  -- New venue
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=nullif(split_part(x,'|',4),'') FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venue, listing, slug
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nv} THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Austria','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, nullif(split_part(x,'|',3),'') FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: closures and city counts
  UPDATE venues SET status='closed' WHERE id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nc} THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\\n') x) AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nc} THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=0 WHERE id='ci_f957c08967' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city leibnitz %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='{SV[1]}' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city sankt veit %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'{J} | rule 2.1.7: Austria edition live at capture = 2026 (selection Mar 18, 2026, {STARS}) | year 2025 -> 2026, {URLNOTE}, retire 0 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | Austria 2026 rows not in the legacy rows: One Star TIAN, Kirchenwirt (Leogang), Thaller - Restaurant; Bib Wörgötter - Wirtshaus, Schlosskeller Wirtshaus | list read Nov 5, 2026 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venue | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv-nc} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']+nc} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||coalesce(source_url,''), E'\\n' ORDER BY venue_id||'|'||category||'|'||coalesce(source_url,'') COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '{AWM}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr+na} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=61,One Star=79,Three Stars=2,Two Stars=19' THEN RAISE EXCEPTION 'Austria 2026 %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria' AND a.year=2025) <> 2 THEN RAISE EXCEPTION 'Austria 2025'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv-nc} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+3} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT={na},awards:UPDATE={nr},cities:UPDATE=2,city_label_source:INSERT={nl},listings:INSERT={nv},listings:UPDATE={nc},slugs:INSERT={nv},venues:INSERT={nv},venues:UPDATE={nc}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
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
open(os.path.join(SCRATCH, 'dry.sql'), 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
json.dump(cards, open(os.path.join(SCRATCH, 'cards.json'), 'w'), ensure_ascii=False)
