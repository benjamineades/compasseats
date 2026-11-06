#!/usr/bin/env python3
"""Build the Michelin Canada 2026 load file from the list read, pairs.tsv and live-read.txt. No retyped values.
Args: approval text, scratch dir."""
import hashlib, os, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[2] if len(sys.argv) > 2 else '.'
NAME = 'load-michelin-2026-canada-2026-11-05'
RELAY_SHA = 'cddbbd98fa74dab4268d4cacb4e0a6d9858ad894a9d5eee5259b022b60adafa3'
QC = 'https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-quebec-for-2026-and-the-year-s-key-trends'
TO = 'https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-toronto-region-for-2026'
VA = 'https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-vancouver-for-2026'
FABLE_SRC = 'https://dailyhive.com/vancouver/fable-kitchen-vancouver-2026'
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
rel = open('relay-ca-2026-list-pages-2026-11-05.txt', encoding='ascii').read()
assert hashlib.sha256(rel.encode()).hexdigest() == RELAY_SHA
live = {}
for l in open('live-read.txt', encoding='utf8').read().strip().split('\n'):
    p = l.split('|'); live[p[1]] = dict(v=p[0], a=p[1], cat=p[2], y=p[3], ci=p[4], st=p[6], url=p[9], name='|'.join(p[10:]))
assert len(live) == 106
pairs = {l.split('\t')[0]: l.split('\t') for l in open('pairs.tsv').read().split('\n')}
CITY = {'Toronto': ('toronto', 'ci_79cca97018', 'Toronto'), 'Vancouver': ('vancouver', 'ci_2ad52028d6', 'Vancouver'), 'St. Catharines': ('saint-catharines', 'ci_7dfcecf2b4', 'Saint Catharines'), 'Jordan': ('lincoln', 'ci_aa45997477', 'Lincoln')}
RLL, AWL, NWL = [], [], []
for line in rel.split('\n'):
    cat, href, name, loc, _pr = dec(line).split(' | '); path = href.split('/restaurant/')[1]; _, v, a, how, guide = pairs[path]; url = 'https://guide.michelin.com' + href
    if guide == 'quebec':
        lv = live[a]; assert lv['v'] == v and lv['cat'] == cat and lv['y'] == '2025' and lv['st'] == 'active' and lv['url'] == ''
        RLL.append(f"{a}|{v}|{cat}|{url}")
    else:
        if v == 'NEW':
            cs, ci, cd = CITY[loc.split(', ')[0]]; sl = slugify(name); v = 've_' + hashlib.md5(f"{cs}:{sl}".encode()).hexdigest()[:10]
            NWL.append(f"{v}|{sl}|{cs}|{ci}|{cd}|{loc.split(', ')[0]}|{name}")
        else:
            lv = live[a]; assert lv['v'] == v and lv['y'] == '2025' and lv['st'] == 'active' and lv['url'] == ''
        AWL.append(f"{v}|{cat}|{url}")
assert len(RLL) == 36 and len(AWL) == 73 and len(NWL) == 7
RL = '\n'.join(sorted(RLL, key=lambda r: int(r.split('|')[0]))); AW = '\n'.join(sorted(AWL)); NW = '\n'.join(sorted(NWL))
CL = 've_3160c0aec9|Fable Kitchen|active|ci_2ad52028d6'
FP = hashlib.md5('\n'.join(sorted((f"{a['a']}|{a['v']}|{a['cat']}|{a['st']}|{a['ci']}|{a['name']}" for a in live.values()), key=lambda s: s.encode())).encode()).hexdigest()
RLM, AWM, NWM = (hashlib.md5(x.encode()).hexdigest() for x in (RL, AW, NW))
B = dict(v=11691, va=11384, vc=307, a=28519, last=35690, s=13635, l=11691, lb=24789, ci=3321, sum=11384, led=265, ledm=319, au=126938, aum=132767, pr=7759, rd=35, al=222, m25=4483, m26=7190, m27=122)
nr, na, nv, nc, nl = 36, 73, 7, 1, 14
CC = {'ci_79cca97018': (72, 75), 'ci_2ad52028d6': (45, 46), 'ci_7dfcecf2b4': (1, 2), 'ci_aa45997477': (1, 2)}
tot = nr + na + nv + nv + nv + nl + nc + nc + len(CC)
aud = f"awards:INSERT={na},awards:UPDATE={nr},cities:UPDATE={len(CC)},city_label_source:INSERT={nl},listings:INSERT={nv},listings:UPDATE={nc},slugs:INSERT={nv},venues:INSERT={nv},venues:UPDATE={nc}"
cg = ' OR '.join(f"(SELECT venues_count FROM cities WHERE id='{k}') <> {v[0]}" for k, v in sorted(CC.items()))
cu = '\n'.join(f"  UPDATE cities SET venues_count={v[1]} WHERE id='{k}' AND venues_count={v[0]};\n  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city {k} %', n; END IF;" for k, v in sorted(CC.items()))
sql = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin Canada, 3 guides. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7, per guide:
-- Quebec: ceremony May 6, 2026, before the capture window ({QC}). The 36 legacy rows hold the 2026 edition. Relabel 36 rows 2025 -> 2026, source_url = the card (/us/en/). Retire 0.
-- Toronto & Region: ceremony Sep 22, 2026, after June 1 ({TO}). The 43 legacy rows hold the 2025 edition and stay as 2025. 46 new rows, year 2026.
-- Vancouver: ceremony Oct 6, 2026, after June 1 ({VA}). The 27 legacy rows hold the 2025 edition and stay as 2025. 27 new rows, year 2026.
-- {nv} new venues, card name, restaurant, active, published. RPM Bakehouse (card city Jordan) goes in Lincoln, as the alias "jordan station" does. Les Incompetents (card city St. Catharines) goes in Saint Catharines.
-- Closed: Fable Kitchen, status closed, published false ({FABLE_SRC}). Award row and slug stay.
-- Source: docs/michelin-2026-canada-2026-11-05/relay-ca-2026-list-pages-2026-11-05.txt sha256 {RELAY_SHA}.
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
  IF md5(rl) <> '{RLM}' OR md5(aw) <> '{AWM}' OR md5(nw) <> '{NWM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'live fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada') <> 106 THEN RAISE EXCEPTION 'Canada Michelin rows'; END IF;
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
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) AND v.status='active' AND c.country='Canada');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x UNION ALL SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x UNION ALL SELECT split_part(x,'|',2) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'venue holds Michelin 2026'; END IF;
  SELECT v.id||'|'||v.name||'|'||v.status||'|'||v.city_id INTO s FROM venues v WHERE v.id=split_part(cl,'|',1);
  IF s IS DISTINCT FROM cl THEN RAISE EXCEPTION 'closure %', s; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id=split_part(cl,'|',1) AND published) <> 1 THEN RAISE EXCEPTION 'closure listing'; END IF;
  -- New venues
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) OR (c.country='Canada' AND v.norm_key=norm_key(split_part(x,'|',7)))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5) AND c.country='Canada');
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel Quebec
  UPDATE awards a SET year=2026, source_url=split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
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
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',6),'city_display'),('Canada','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nl} THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {na} THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: closure
  UPDATE venues SET status='closed' WHERE id=split_part(cl,'|',1) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nc} THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id=split_part(cl,'|',1) AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nc} THEN RAISE EXCEPTION 'published %', n; END IF;
{cu}
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',{nr},'relabel:{NAME} | rule 2.1.7: Quebec edition live at capture = 2026 (ceremony May 6, 2026, {QC}) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','award',{na},'cleanup:{NAME} | rule 2.1.1 and 2.1.7: Toronto & Region ceremony Sep 22, 2026 ({TO}), Vancouver ceremony Oct 6, 2026 ({VA}), legacy rows hold the 2025 edition, relabel 0, retire 0 | list read Nov 5, 2026 | relay sha256 {RELAY_SHA} | {APPROVAL}'),
    ('michelin','city_label',{nl},'cleanup:{NAME} | city labels of {nv} new venues | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv-nc} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']+nc} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> {na} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\\n' ORDER BY venue_id||'|'||category||'|'||source_url COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> md5((SELECT string_agg(x, E'\\n' ORDER BY x COLLATE "C") FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']-nr} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']+nr+na} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=70,One Star=36,Two Stars=3' THEN RAISE EXCEPTION 'Canada 2026 %', s; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2025 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=41,One Star=28,Two Stars=1' THEN RAISE EXCEPTION 'Canada 2025 %', s; END IF;
  IF (SELECT count(DISTINCT a.source_url) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' AND a.year=2026 AND a.source_url LIKE 'https://guide.michelin.com/us/en/%') <> 109 THEN RAISE EXCEPTION 'URLs after'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Canada' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv-nc} THEN RAISE EXCEPTION 'cities after'; END IF;
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
print('sql sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'audit', tot, 'fp', FP)
print(NW)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]
cut = do.index('  -- WRITE: relabel Quebec')
open(os.path.join(SCRATCH, 'dry.sql'), 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
