#!/usr/bin/env python3
"""Build the A3 file: Argentina, Abu Dhabi, Czechia, Estonia 2026. One transaction.
Args: fingerprint, approval text, scratch dir. Baseline from baseline.json."""
import hashlib, json, re, sys, unicodedata
FP = sys.argv[1]
APPROVAL = sys.argv[2] if len(sys.argv) > 2 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[3] if len(sys.argv) > 3 else '.'
B = json.load(open('baseline.json'))
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'load-michelin-2026-a3-2026-11-06'
SHA = 'f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45'
RELAY = 'relay-a3-2026-list-pages-2026-11-06.txt'
SCOPE = "(c.country_iso IN ('AR','CZ','EE') OR c.id='ci_e1cf943b49')"
AD_ART = 'https://guide.michelin.com/ae-az/en/article/michelin-guide-ceremony/just-unveiled-the-michelin-guide-abu-dhabi-2026'
CZ_ART = 'https://guide.michelin.com/cz/en/article/michelin-guide-ceremony/czechia-the-full-list-of-michelin-starred-restaurants'
AR_ART = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-newly-starred-restaurants-in-buenos-aires-and-mendoza'
EE_ART = 'https://guide.michelin.com/ee/en/article/michelin-guide-ceremony/all-the-winners-in-the-michelin-guide-estonia-2026-new-stars-bib-gourmands-special-awards'
NOCARD = {  # award id: (venue, category, url)
 '9205': ('ve_85088316db', 'Bib Gourmand', AD_ART),
 '13039': ('ve_fe70f07ca7', 'Bib Gourmand', 'https://web.archive.org/web/20251221005857id_/https://guide.michelin.com/us/en/olomoucky/sumperk_1280119/restaurant/perk-restaurant'),
}
CITY = {'Buenos Aires': ('buenos-aires', 'ci_087a90256e', 43, 'Argentina'), 'Mendoza': ('mendoza', 'ci_cfcd7931ab', 8, 'Argentina'), 'Tallinn': ('tallinn', 'ci_5b3f332b80', 11, 'Estonia')}
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
rl, ins, used = [], [], set()
for kind, slug, aid, vid in pairs:
    c = cards[slug]; used.add(slug)
    if kind == 'R': rl.append((int(aid), f"{aid}~{vid}~{c['cat']}~{c['url']}"))
    else: ins.append((vid, c['cat'], c['url'], c['g']))
for aid, (vid, cat, url) in NOCARD.items(): rl.append((int(aid), f"{aid}~{vid}~{cat}~{url}"))
rl.sort(); RL = '\n'.join(x for _, x in rl)
new = []
for slug, c in cards.items():
    if slug in used: continue
    label = c['loc'].split(', ')[0]; cs, cid, _, country = CITY[label]; s = slugify(c['name'])
    new.append(dict(c, slug=s, label=label, cs=cs, cid=cid, country=country, v='ve_' + md5(f"{cs}:{s}")[:10]))
new.sort(key=lambda c: c['v'])
NW = '\n'.join(f"{c['v']}~{c['slug']}~{c['cs']}~{c['cid']}~{c['label']}~{c['country']}~{c['name']}" for c in new)
aw = sorted([(v, cat, url) for v, cat, url, g in ins] + [(c['v'], c['cat'], c['url']) for c in new])
AW = '\n'.join('~'.join(x) for x in aw)
nr, na, nv = len(rl), len(aw), len(new); nl = nv * 2
assert (nr, na, nv) == (39, 37, 15), (nr, na, nv)
CC = {}
for c in new: CC[c['label']] = CC.get(c['label'], 0) + 1
assert CC == {'Buenos Aires': 10, 'Mendoza': 3, 'Tallinn': 2}, CC
gc = {}
for v, cat, url, g in ins: gc[g] = gc.get(g, 0) + 1
for c in new: gc[c['g']] = gc.get(c['g'], 0) + 1
assert gc == {'abu-dhabi': 1, 'estonia': 11, 'argentina': 25}, gc
tot = nr + na + nv * 3 + nl + 3
led = [
 f"('michelin','award',12,'relabel:{KEY} | rule 2.1.7: Abu Dhabi edition live at capture = 2026 (Oct 23, 2025, {AD_ART}) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | award 9205 Goldfish: card gone, no capture, article URL names it | relay sha256 {SHA} | {APPROVAL}')",
 f"('michelin','award',27,'relabel:{KEY} | rule 2.1.7: Czechia edition live at capture (Dec 11, 2025, {CZ_ART}): article says 2025, cards say 2026, label set to the card | year 2025 -> 2026, source_url = the card (/us/en/), retire 0 | award 13039 Perk: card gone, archive capture Dec 21, 2025 | relay sha256 {SHA} | {APPROVAL}')",
 f"('michelin','award',1,'cleanup:{KEY} | Abu Dhabi 2026, Oct 23, 2025, {AD_ART} | One Star Hakkasan, missing from the capture, venue exists | {APPROVAL}')",
 f"('michelin','award',11,'cleanup:{KEY} | rule 2.1.1 and 2.1.7: Estonia 2026, May 19, 2026, {EE_ART} | capture holds the 2025 edition (Jun 19, 2025), 2025 rows stay, relabel 0 | Two Stars 1, One Star 1, Bib 9 | relay sha256 {SHA} | {APPROVAL}')",
 f"('michelin','award',25,'cleanup:{KEY} | rule 2.1.1 and 2.1.7: Argentina 2026, Jul 13, 2026, {AR_ART} | after the capture window, 2025 rows stay, relabel 0 | Two Stars 1, One Star 13, Bib 11 | relay sha256 {SHA} | {APPROVAL}')",
 f"('michelin','city_label',{nl},'cleanup:{KEY} | city labels of {nv} new venues (Buenos Aires 10, Mendoza 3, Tallinn 2) | {APPROVAL}')",
]
ml = len(led)
yc = {y: B[f"m{str(y)[2:]}"] for y in (2024, 2025, 2026, 2027)}
ya = dict(yc); ya[2025] -= nr; ya[2026] += nr + na
AUD = f'awards:INSERT={na},awards:UPDATE={nr},cities:UPDATE=3,city_label_source:INSERT={nl},listings:INSERT={nv},slugs:INSERT={nv},venues:INSERT={nv}'
POST = '2025:Bib Gourmand=7,2025:One Star=10,2025:Two Stars=2,2026:Bib Gourmand=48,2026:One Star=25,2026:Two Stars=3'
cg = ' OR '.join(f"(SELECT venues_count FROM cities WHERE id='{CITY[k][1]}') <> {CITY[k][2]}" for k in CC)
cu = '\n'.join(f"  UPDATE cities SET venues_count={CITY[k][2]+CC[k]} WHERE id='{CITY[k][1]}' AND venues_count={CITY[k][2]}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city {CITY[k][0]}'; END IF;" for k in CC)
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin A3: Argentina, Abu Dhabi, Czechia, Estonia 2026. {APPROVAL}. This file runs only after Ben's "go".
-- Relabel {nr} rows 2025 -> 2026 (rule 2.1.7): Abu Dhabi 12, Czechia 27. 37 with the /us/en/ card URL, Goldfish the article URL, Perk an archive URL. Retire 0.
-- {na} new 2026 rows: Abu Dhabi 1, Estonia 11, Argentina 25. {nv} new venues: Buenos Aires 10, Mendoza 3, Tallinn 2. Argentina and Estonia 2025 rows stay.
-- Source: docs/michelin-a3-2026-11-06/{RELAY} sha256 {SHA}.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv}, closed {B['vc']}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+nl}; cities {B['ci']}, sum {B['sum']+nv}; ledger {B['led']+ml} rows; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; first_award bigint; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{md5(RL)}' OR md5(aw) <> '{md5(AW)}' OR md5(nw) <> '{md5(NW)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND {SCOPE}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE}) <> 58 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {yc[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {yc[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {yc[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {yc[2027]} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR {cg} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',1) NOT IN (SELECT split_part(y,'~',1) FROM regexp_split_to_table(nw,E'\\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE EXISTS (SELECT 1 FROM awards a WHERE a.venue_id=split_part(x,'~',1) AND a.source_id='michelin' AND a.year=2026);
  IF n <> 0 THEN RAISE EXCEPTION 'venue already has 2026 %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x) OR a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',7))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',7)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
  UPDATE awards a SET year=2026, source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {nr} THEN RAISE EXCEPTION 'relabel %', n; END IF;
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
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, u1, u2 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND {SCOPE};
  IF n <> 76 OR u1 <> 76 OR u2 <> 76 THEN RAISE EXCEPTION 'urls after % % %', n, u1, u2; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE} GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+nl} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv} THEN RAISE EXCEPTION 'cities after'; END IF;
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
open(f"{SCRATCH}/dry-a3.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'relabel', nr, 'rows', na, 'new', nv, 'audit', tot, 'ledger', ml)
print([(c['name'], c['slug'], c['cs'], c['v']) for c in new])
