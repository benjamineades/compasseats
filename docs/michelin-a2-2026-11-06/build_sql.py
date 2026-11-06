#!/usr/bin/env python3
"""Build the A2 file: Brazil, Malta, Qatar, Serbia 2026. One transaction.
Args: fingerprint, approval text, scratch dir. Baseline from baseline.json. Choices in CHOICES."""
import hashlib, json, re, sys, unicodedata
FP = sys.argv[1]
APPROVAL = sys.argv[2] if len(sys.argv) > 2 else 'DRAFT, choices not yet given'
SCRATCH = sys.argv[3] if len(sys.argv) > 3 else '.'
B = json.load(open('baseline.json'))
md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY = 'load-michelin-2026-a2-2026-11-06'
SHA = '6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796'
RELAY = 'relay-a2-2026-list-pages-2026-11-06.txt'
ISOS = "c.country_iso IN ('BR','MT','QA','RS')"
G = {
 'brazil': dict(n=66, name='Brazil (Rio de Janeiro & Sao Paulo)', date='Apr 13, 2026', url='https://guide.michelin.com/en/article/michelin-guide-ceremony/brazil-restaurants-three-michelin-stars'),
 'malta': dict(n=12, name='Malta', date='Feb 17, 2026', url='https://guide.michelin.com/mt/en/article/michelin-guide-ceremony/the-michelin-guide-malta-2026-is-launched-today'),
 'qatar': dict(n=11, name='Qatar (Doha)', date='Dec 9, 2025', url='https://guide.michelin.com/qa/en/article/michelin-guide-ceremony/full-list-michelin-guide-doha-selection'),
 'serbia': dict(n=5, name='Serbia (Belgrade)', date='Dec 10, 2025', url='https://guide.michelin.com/rs/en/article/michelin-guide-ceremony/michelin-guide-belgrade-2026-celebrates-growth-and-culinary-excellence'),
}
NOCARD = {  # award id: (venue, category, url)
 '11833': ('ve_99f41235da', 'Bib Gourmand', 'https://web.archive.org/web/20260712091053id_/https://guide.michelin.com/es/es/rio-de-janeiro-region/rio-de-janeiro/restaurante/didier'),
 '12397': ('ve_195c01f75c', 'Bib Gourmand', ''),
}
CLOSE = [('ve_99f41235da', 'Didier Restaurante', 'ci_a7418b493c'), ('ve_dfa308c00a', 'Lasai', 'ci_a7418b493c')]
SP, RIO = ('ci_7d2b023f60', 71), ('ci_a7418b493c', 22)
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def slugify(n):
    s = unicodedata.normalize('NFKD', n.lower()); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
rel = open(RELAY, encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == SHA
cards = {}
for line in rel.split('\n'):
    g, cat, href, name, loc, pr, cc, dist, note = dec(line).split(' | ')
    assert '~' not in name
    cards[href.split('/restaurant/')[1]] = dict(g=g, cat=cat, url='https://guide.michelin.com' + href, name=name, loc=loc)
pairs = [l.split('\t') for l in open('pairs.tsv').read().strip().split('\n')]
rl = []
for slug, aid, vid in pairs:
    c = cards[slug]; rl.append((int(aid), f"{aid}~{vid}~{c['cat']}~{c['url']}"))
for aid, (vid, cat, url) in NOCARD.items(): rl.append((int(aid), f"{aid}~{vid}~{cat}~{url}"))
rl.sort(); RL = '\n'.join(x for _, x in rl)
paired = {p[0] for p in pairs}
new = []
for slug, c in cards.items():
    if slug in paired: continue
    s = slugify(c['name']); new.append(dict(c, slug=s, v='ve_' + md5('sao-paulo:' + s)[:10]))
new.sort(key=lambda c: c['v'])
assert len(new) == 2 and all(c['loc'] == 'São Paulo, Brazil' and c['cat'] == 'Bib Gourmand' for c in new)
NW = '\n'.join(f"{c['v']}~{c['slug']}~sao-paulo~{SP[0]}~São Paulo~{c['name']}" for c in new)
AW = '\n'.join(f"{c['v']}~{c['cat']}~{c['url']}" for c in new)
nr, na, nv = len(rl), 2, 2
assert nr == 94
tot = nr + na + nv * 3 + 4 + 2 + 2 + 2
ids = ','.join(f"'{v}'" for v, _, _ in sorted(CLOSE))
CF = md5('\n'.join(f"{v}|{n}|active|{c}" for v, n, c in sorted(CLOSE)))
led = []
for g, d in G.items():
    extra = ' | award 11833 Didier: archive capture Jul 12, 2026, card gone, 12397 Piu Higienopolis: no 2026 capture, no URL, named in the 2026 list by CNN Brasil Apr 14, 2026' if g == 'brazil' else ''
    led.append(f"('michelin','award',{d['n']},'relabel:{KEY} | rule 2.1.7: {d['name']} edition live at capture = 2026 ({d['date']}, {d['url']}) | year 2025 -> 2026, source_url = the card (/us/en/), retire 0{extra} | relay sha256 {SHA} | {APPROVAL}')")
led.append(f"('michelin','award',2,'cleanup:{KEY} | Brazil 2026, Apr 13, 2026 | Bib 2 missing from the capture: Taboa Cozinha Artesanal, Peti no MAM (Peti Gastronomia in the 2026 list) | 2 new venues | {APPROVAL}')")
led.append(f"('michelin','city_label',4,'cleanup:{KEY} | city labels of 2 new venues, Sao Paulo | {APPROVAL}')")
ml = len(led)
yc = {y: B[f"m{str(y)[2:]}"] for y in (2024, 2025, 2026, 2027)}
ya = dict(yc); ya[2025] -= nr; ya[2026] += nr + na
AUD = 'awards:INSERT=2,awards:UPDATE=94,cities:UPDATE=2,city_label_source:INSERT=4,listings:INSERT=2,listings:UPDATE=2,slugs:INSERT=2,venues:INSERT=2,venues:UPDATE=2'
POST = '2026:Bib Gourmand=60,2026:One Star=30,2026:Three Stars=2,2026:Two Stars=4'
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin A2: Brazil, Malta, Qatar, Serbia 2026. {APPROVAL}. This file runs only after Ben's "go".
-- Relabel 94 rows 2025 -> 2026 (rule 2.1.7), 92 with the /us/en/ card URL, 1 archive URL (Didier), 1 no URL (Piu Higienopolis). Retire 0.
-- 2 new Bib rows and 2 new venues in Sao Paulo: Taboa Cozinha Artesanal, Peti no MAM.
-- 2 closures: Didier (press, closed Jun 28, 2026), Lasai (card: temporarily closed, relocation; reopening December 2026, recheck). Award rows stay. Slugs stay.
-- Source: docs/michelin-a2-2026-11-06/{RELAY} sha256 {SHA}.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues {B['v']+nv} (active {B['va']+nv-2}, closed {B['vc']+2}); awards {B['a']+na}; slugs {B['s']+nv}; listings {B['l']+nv}; labels {B['lb']+4}; cities {B['ci']}, sum {B['sum']+nv-2}; ledger {B['led']+ml} rows; audit_log +{tot}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
  aw text := $plan${AW}$plan$;
  nw text := $plan${NW}$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint; ids text[] := ARRAY[{ids}];
BEGIN
  -- PRE gates
  IF md5(rl) <> '{md5(RL)}' OR md5(aw) <> '{md5(AW)}' OR md5(nw) <> '{md5(NW)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND {ISOS}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {ISOS}) <> 94 THEN RAISE EXCEPTION 'scope rows'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id = ANY(ids)) IS DISTINCT FROM '{CF}' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = ANY(ids) AND published) <> 2 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {yc[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {yc[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {yc[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {yc[2027]} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']} OR (SELECT count(*) FROM listings) <> {B['l']} OR (SELECT count(*) FROM city_label_source) <> {B['lb']} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT venues_count FROM cities WHERE id='{SP[0]}') <> {SP[1]} OR (SELECT venues_count FROM cities WHERE id='{RIO[0]}') <> {RIO[1]} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> {B['au']} OR aud_max <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'~',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE split_part(x,'~',4)<>'') OR a.source_url IN (SELECT split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE split_part(x,'~',1) <> 've_'||left(md5(split_part(x,'~',3)||':'||split_part(x,'~',2)),10) OR split_part(x,'~',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'~',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'~',1) OR (v.norm_key=norm_key(split_part(x,'~',6)) AND v.city_id=split_part(x,'~',4))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'~',3) AND t.slug=split_part(x,'~',2));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: start
  UPDATE awards a SET year=2026, source_url=NULLIF(split_part(x,'~',4),'') FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 94 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'~',1), split_part(x,'~',6), 'restaurant'::venue_category, split_part(x,'~',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'~',1), 'eats', true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'~',3), split_part(x,'~',2), split_part(x,'~',1), true FROM regexp_split_to_table(nw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'~',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'~',5),'city_display'),('Brazil','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'labels %', n; END IF;
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'~',1), 'michelin', 2026, NULL, split_part(x,'~',2), NULL, split_part(x,'~',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: closures
  UPDATE venues SET status='closed' WHERE id = ANY(ids) AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'closures %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id = ANY(ids) AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'unpublish %', n; END IF;
  UPDATE cities SET venues_count={SP[1]+2} WHERE id='{SP[0]}' AND venues_count={SP[1]}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'sao paulo'; END IF;
  UPDATE cities SET venues_count={RIO[1]-2} WHERE id='{RIO[0]}' AND venues_count={RIO[1]}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rio'; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {(','+chr(10)+'    ').join(led)};
  -- POST gates
  IF (SELECT count(*) FROM venues) <> {B['v']+nv} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']+nv-2} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']+2} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']+na} OR (SELECT count(*) FROM awards WHERE id > first_award) <> 2 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'~'||category||'~'||source_url, E'\\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> '{md5(AW)}' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2024) <> {ya[2024]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {ya[2025]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {ya[2026]} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {ya[2027]} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(year||':'||category||'='||k, ',' ORDER BY year, category) INTO s FROM (SELECT a.year, a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {ISOS} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM '{POST}' THEN RAISE EXCEPTION 'scope after %', s; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, first_award, aud_max FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {ISOS};
  IF n <> 96 OR first_award <> 95 OR aud_max <> 95 THEN RAISE EXCEPTION 'urls after % % %', n, first_award, aud_max; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['s']+nv} OR (SELECT count(*) FROM listings) <> {B['l']+nv} OR (SELECT count(*) FROM city_label_source) <> {B['lb']+4} OR (SELECT count(*) FROM price) <> {B['pr']} OR (SELECT count(*) FROM redirects) <> {B['rd']} OR (SELECT count(*) FROM city_aliases) <> {B['al']} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> {B['ci']} OR (SELECT sum(venues_count) FROM cities) <> {B['sum']+nv-2} THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+ml} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT max(id) INTO aud_max FROM audit_log;
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
open(f"{SCRATCH}/dry-a2.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'relabel', nr, 'audit', tot, 'ledger', ml)
print([(c['name'], c['slug'], c['v']) for c in new])
