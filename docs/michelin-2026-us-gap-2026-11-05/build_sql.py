#!/usr/bin/env python3
"""Build the Michelin US gap file (California, Florida) from the list read, the venue read and live-pairs-read.txt. No retyped values.
Args: approval text. Writes pairs.tsv, michelin-2026-us-gap-evidence-2026-11-05.csv, the load file and dry.sql."""
import collections, csv, hashlib, re, sys, unicodedata
APPROVAL = sys.argv[1] if len(sys.argv) > 1 else 'DRAFT, choices not yet given'
NAME = 'load-michelin-2026-us-gap-2026-11-05'
LIST_SHA = '9b5fd3ef5b631b5ea92a2c954ff362ca8b54bcb2723a05a26eb5c5d3ca4274e1'
PAGES_SHA = '6bec0b915c33ec7611ae84e71f59a01dc2ded0fc91f4c58130c6f86782ad552c'
LIVE_MD5 = '723b2dabdd68311ab95d424a3717d9df'
G = 'https://guide.michelin.com'
CA_BIB = '/us/en/article/michelin-guide-ceremony/california-s-most-affordable-restaurants-in-2026'
FL_STAR = '/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-florida-for-2026-and-the-year-s-key-trends-copy1'
CA_STAR = '/us/en/article/michelin-guide-ceremony/guide-michelin-california'
# Rows with no card today, on a 2026 Michelin article. Award id, venue, category, article path.
NOCARD = [(6497, 've_33eb6c0862', 'One Star', FL_STAR), (11463, 've_aef9d7ea1a', 'Bib Gourmand', CA_BIB), (11864, 've_05a6b65bbe', 'Bib Gourmand', CA_BIB), (11981, 've_fe98dc34e4', 'Bib Gourmand', CA_BIB)]
UNION = (133, 've_8f950e4488', '21071')
LYNX = 144
# Venue to closed, city count change. Little Fish is net 0 with Lynx in Los Angeles.
CLOSE = ['ve_33eb6c0862', 've_aef9d7ea1a', 've_fe98dc34e4', 've_49a2fc7669']
CITY = [('ci_fee43618da', 63, 62, 'miami'), ('ci_7976af491d', 15, 14, 'oakland'), ('ci_c218492ef0', 77, 76, 'san-francisco')]
TN = {'Thr': 'Three Stars', 'Two': 'Two Stars', 'One': 'One Star', 'Bib': 'Bib Gourmand'}
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s = unicodedata.normalize('NFKD', n.lower().replace('’', "'")); s = ''.join(c for c in s if not unicodedata.combining(c)); return re.sub(r'[^a-z0-9]+', '', s)
rel = open('relay-us-ca-fl-2026-list-pages-2026-11-05.txt', encoding='ascii', newline='').read(); assert hashlib.sha256(rel.encode()).hexdigest() == LIST_SHA
pgt = open('venue-pages-read-2026-11-05.tsv', encoding='ascii', newline='').read(); assert hashlib.sha256(pgt.encode()).hexdigest() == PAGES_SHA
lvt = open('live-pairs-read.txt', encoding='utf8', newline='').read(); assert hashlib.md5(lvt.encode()).hexdigest() == LIVE_MD5
pages = [l.split('\t') for l in pgt.split('\n')]
live = {}
for l in lvt.split('\n'):
    p = l.split('|'); live[int(p[0])] = dict(v=p[1], a=p[2], c=p[3], u=p[4], a25=p[5], c25=p[6], st=p[7], city=p[8], name='|'.join(p[9:]))
UP, AW, OK, PAIRS, EV = [], [], [], [], []; how = collections.Counter(); names = []
for i, line in enumerate(rel.split('\n'), 1):
    x = dec(line).split(' | '); tier, href, loc, pr = x[0], x[1], x[-2], x[-1]; nm = ' | '.join(x[2:-2]); pg = pages[i - 1]
    assert pg[0] == href.split('/restaurant/')[1] and pg[1] == '200' and pg[2] == '2026' and pg[3] == tier[:3], i
    if i == LYNX: PAIRS.append((i, href, 'NEW', '-', 'new venue, new row')); how['new venue'] += 1; AW.append(('NEW', tier, href)); EV.append((i, tier, nm, loc, href, 'NEW', '', '', 'new venue and row', pr, dec(pg[5]), '')); continue
    if i == UNION[0]: lv = dict(v=UNION[1], a=UNION[2], c='Bib', u='u', name='Union Pasadena', city='Pasadena', c25='-', st='active')
    else: lv = live[i]
    if lv['u'] == 'n':
        act = 'url and tier' if lv['c'] != tier[:3] else 'url'; UP.append((int(lv['a']), lv['v'], TN[lv['c']], tier, href))
    elif lv['u'] == 'u': act = 'row is sourced, no write'; OK.append((int(lv['a']), lv['v'], tier, href))
    else: act = 'new row'; AW.append((lv['v'], tier, href))
    how[act] += 1; PAIRS.append((i, href, lv['v'], lv['a'], act))
    nd = '' if key(nm) == key(lv['name']) else 'name differs'
    if nd: names.append((lv['name'], nm))
    EV.append((i, tier, nm, loc, href, lv['v'], lv['a'], TN.get(lv['c'], '-'), act, pr, dec(pg[5]), nd))
for a, v, c, u in NOCARD: UP.append((a, v, c, c, u))
assert len(UP) == 225 and len(AW) == 10 and len(OK) == 36, (len(UP), len(AW), len(OK))
assert len({u[0] for u in UP}) == 225
sl = 'lynx'; lv = 've_' + hashlib.md5(f'los-angeles:{sl}'.encode()).hexdigest()[:10]
NW = f'{lv}|{sl}|los-angeles|ci_2e26eb9108|Los Angeles|Lynx'
UPT = '\n'.join(f'{a}|{v}|{o}|{n}|{u}' for a, v, o, n, u in sorted(UP))
AWT = '\n'.join(sorted(f"{lv if v == 'NEW' else v}|{c}|{u}" for v, c, u in AW))
OKT = '\n'.join(f'{a}|{v}|{c}|{u}' for a, v, c, u in sorted(OK))
UPM, AWM, OKM = (hashlib.md5(t.encode()).hexdigest() for t in (UPT, AWT, OKT))
open('pairs.tsv', 'w', newline='').write('\n'.join('\t'.join(map(str, p)) for p in PAIRS))
with open('michelin-2026-us-gap-evidence-2026-11-05.csv', 'w', encoding='utf8', newline='') as f:
    w = csv.writer(f); w.writerow('line tier card_name card_place card_path venue_id award_id live_tier_2026 action card_price card_address name_note'.split()); w.writerows(EV)
    for a, v, c, u in NOCARD: w.writerow(('', c, '', '', u, v, a, c, 'no card today, article URL', '', '', ''))
HEAD = f"""-- {NAME}.sql
-- CompassEats, Nov 5 2026. Michelin US gap: California and Florida. {APPROVAL}. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7. California: stars June 24, 2026 ({G}{CA_STAR}), Bibs May 28, 2026 ({G}{CA_BIB}). Florida: May 28, 2026 ({G}{FL_STAR}). Site edition 2026, population 267 venue pages. 2027: no edition.
-- Test of named changes: California new tiers 3, new Bibs 7, Florida new stars 2, new Bibs 10: 0 of 22 in the 2025 rows. The 2025 rows hold the 2025 edition. Retire 0, relabel 0.
-- 225 rows labelled 2026 with no URL take a URL: 221 the card, 4 the 2026 article (no card today). 2 of the 221 go Two Stars to One Star (Caruso's 6591, Osteria Mozza 6177).
-- 10 new 2026 rows: 9 on live venues with a 2025 row, Lynx with a new venue. 36 sourced rows: no write.
-- 4 venues to closed and not published: Tambourine Room, Horn Barbecue, Yank Sing (Spear St.), Little Fish Echo Park. Adana and Sea Harbour: status does not change.
-- Sources: docs/michelin-2026-us-gap-2026-11-05/relay-us-ca-fl-2026-list-pages-2026-11-05.txt sha256 {LIST_SHA}. venue-pages-read-2026-11-05.tsv sha256 {PAGES_SHA}.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11717 (active 11405, closed 312); awards 28691; slugs 13661; listings 11717; labels 24841; cities 3325, sum 11405; ledger 277 rows; Michelin 2025/2026/2027 4365/7480/122; audit_log +251.
"""
PRE = f"""DO $load$
DECLARE
  up text := $plan${UPT}$plan$;
  aw text := $plan${AWT}$plan$;
  ok text := $plan${OKT}$plan$;
  nw text := $plan${NW}$plan$;
  cl text[] := ARRAY[{','.join(repr(c) for c in CLOSE)}];
  n bigint; s text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(up) <> '{UPM}' OR md5(aw) <> '{AWM}' OR md5(ok) <> '{OKM}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(up,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL OR a.rank IS NOT NULL OR a.distinction IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'update rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(ok,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2026 OR a.source_url IS DISTINCT FROM '{G}'||split_part(x,'|',4);
  IF n <> 0 THEN RAISE EXCEPTION 'sourced rows %', n; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso='US' AND a.source_url IS NULL) <> 225 THEN RAISE EXCEPTION 'US rows with no URL'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.category IN ('Three Stars','Two Stars','One Star','Bib Gourmand') AND a.source_url IN (SELECT '{G}'||split_part(x,'|',5) FROM regexp_split_to_table(up,E'\\n') x WHERE x NOT LIKE '%/article/%' UNION ALL SELECT '{G}'||split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('Three Stars','Two Stars','One Star','Bib Gourmand') AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\\n') x)) THEN RAISE EXCEPTION 'venue holds a 2026 row'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\\n') x WHERE split_part(x,'|',1) <> split_part(nw,'|',1) AND NOT EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(x,'|',1) AND v.status='active' AND c.country_iso='US');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  IF split_part(nw,'|',1) <> 've_'||left(md5('los-angeles:lynx'),10) THEN RAISE EXCEPTION 'new id'; END IF;
  IF EXISTS (SELECT 1 FROM venues v JOIN cities c ON c.id=v.city_id WHERE v.id=split_part(nw,'|',1) OR (c.country_iso='US' AND v.norm_key=norm_key('Lynx'))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='los-angeles' AND slug='lynx') THEN RAISE EXCEPTION 'venue clash'; END IF;
  SELECT count(*) INTO n FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id = ANY(cl) AND v.status='active' AND l.published; IF n <> 4 THEN RAISE EXCEPTION 'close venues %', n; END IF;
  IF (SELECT status FROM venues WHERE id='ve_500287c739') <> 'closed' OR (SELECT status FROM venues WHERE id='ve_05a6b65bbe') <> 'active' THEN RAISE EXCEPTION 'adana, sea harbour'; END IF;
  IF (SELECT count(*) FROM venues) <> 11716 OR (SELECT count(*) FROM venues WHERE status='active') <> 11408 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28681 OR (SELECT max(id) FROM awards) <> 35852 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4365 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7470 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'OAD before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13660 OR (SELECT count(*) FROM listings) <> 11716 OR (SELECT count(*) FROM city_label_source) <> 24839 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3325 OR (SELECT sum(venues_count) FROM cities) <> 11408 OR (SELECT count(*) FROM source_capture_ledger) <> 274 OR (SELECT max(id) FROM source_capture_ledger) <> 328 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_2e26eb9108') <> 115 THEN RAISE EXCEPTION 'los angeles'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 127360 OR aud_max <> 133189 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  RAISE NOTICE 'pre gates passed';
"""
LJ = f'{NAME} | {APPROVAL}'
WR = f"""  -- WRITE: 225 rows take a URL, 2 of them a new tier
  UPDATE awards a SET source_url='{G}'||split_part(x,'|',5), category=split_part(x,'|',4) FROM regexp_split_to_table(up,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint AND a.source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 225 THEN RAISE EXCEPTION 'update %', n; END IF;
  -- WRITE: new venue
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(nw,'|',1), split_part(nw,'|',6), 'restaurant'::venue_category, split_part(nw,'|',4), 'active'::venue_status;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(nw,'|',1), 'eats', true;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(nw,'|',3), split_part(nw,'|',2), split_part(nw,'|',1), true;
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(nw,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM (VALUES (split_part(nw,'|',5),'city_display'),('United States','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: 10 new rows
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, '{G}'||split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 10 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: status
  UPDATE venues SET status='closed' WHERE id = ANY(cl) AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id = ANY(cl) AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'unpublish %', n; END IF;
""" + ''.join(f"  UPDATE cities SET venues_count={new} WHERE id='{ci}' AND venues_count={old}; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city {sl2} %', n; END IF;\n" for ci, old, new, sl2 in CITY) + f"""  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',225,'cleanup:{NAME} | 225 US rows labelled 2026 take a URL: 221 card, 4 article, 2 tier fixes (6591, 6177) | list sha256 {LIST_SHA} | {APPROVAL}'),
    ('michelin','award',10,'cleanup:{NAME} | 10 new 2026 rows, card URL | list read Nov 5, 2026 | {APPROVAL}'),
    ('michelin','city_label',2,'cleanup:{NAME} | city labels of 1 new venue, Lynx | {APPROVAL}');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11717 OR (SELECT count(*) FROM venues WHERE status='active') <> 11405 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28691 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 10 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4365 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7480 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso='US' AND a.source_url IS NULL) <> 0 THEN RAISE EXCEPTION 'US no URL after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category COLLATE "C") INTO s FROM (SELECT category, count(*) k FROM awards WHERE source_id='michelin' AND year=2026 AND category IN ('Three Stars','Two Stars','One Star','Bib Gourmand') AND (source_url LIKE '{G}/us/en/california/%' OR source_url LIKE '{G}/us/en/florida/%') GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=159,One Star=83,Three Stars=10,Two Stars=15' THEN RAISE EXCEPTION 'card rows %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13661 OR (SELECT count(*) FROM listings) <> 11717 OR (SELECT count(*) FROM city_label_source) <> 24841 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3325 OR (SELECT sum(venues_count) FROM cities) <> 11405 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 277 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=10,awards:UPDATE=225,cities:UPDATE=3,city_label_source:INSERT=2,listings:INSERT=1,listings:UPDATE=4,slugs:INSERT=1,venues:INSERT=1,venues:UPDATE=4' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
"""
FULL = HEAD + 'BEGIN;\n' + PRE + WR + "COMMIT;\nSELECT 'OK: all gates passed' AS result;\n"
open(NAME + '.sql', 'w', encoding='utf8', newline='').write(FULL)
# Dry run: the pre gates, then the first write. The Read connector stops at the write.
FIRST = "  UPDATE awards a SET source_url='" + G + "'||split_part(x,'|',5), category=split_part(x,'|',4) FROM regexp_split_to_table(up,E'\\n') x WHERE a.id=split_part(x,'|',1)::bigint AND a.source_url IS NULL;\nEND\n$load$;\n"
open('dry.sql', 'w', encoding='utf8', newline='').write(PRE + FIRST)
print('how', how); print('names differ', len(names)); print('update', len(UP), 'aw', len(AW), 'ok', len(OK), 'new', NW)
print('md5', UPM, AWM, OKM); print('sha', hashlib.sha256(FULL.encode()).hexdigest(), len(FULL)); print('dry bytes', len((PRE + FIRST).encode()))
open('names-differ.tsv', 'w', encoding='utf8', newline='').write('\n'.join(f'{a}\t{b}' for a, b in names))
