#!/usr/bin/env python3
# Builds docs/fix-placeid-tailor-2026-11-03.sql and the rename fixture. Usage: build_fix_placeid_tailor.py <fingerprint or ->
import sys, csv, hashlib, re, unicodedata, os
FP = sys.argv[1] if len(sys.argv) > 1 else '-'
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
md10 = lambda s: hashlib.md5(s.encode()).hexdigest()[:10]
def slugify(s):
    s = ''.join(c for c in unicodedata.normalize('NFKD', s) if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', s.lower()).strip('-')
q = lambda s: "'" + s.replace("'", "''") + "'"

OAD_N25 = 'https://www.oadguides.com/lists/north-america/top-restaurants/2025'
OAD_N26 = 'https://www.oadguides.com/lists/north-america/top-restaurants/2026'
OAD_J25 = 'https://www.oadguides.com/lists/japan/top-restaurants/2025'
ASIA26 = 'https://www.the50.com/stories/News/asias-50-best-restaurants-2026-the-51-100-list.html'
W50 = 'https://www.the50.com/bars/best-in-the-world/previous-list/2009'
PUNCH = 'https://punchdrink.com/articles/most-influential-failed-bar-tailor-nyc/'
AT_BIB = 'https://guide.michelin.com/at/en/article/michelin-guide-ceremony/43-bib-gourmands-for-austria-guide-michelin'
SG25 = 'https://guide.michelin.com/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025'
FAGN26 = 'https://guide.michelin.com/us/en/trondelag/trondheim/restaurant/fagn-bistro'
FAGN25 = 'https://web.archive.org/web/20250813153751id_/https://guide.michelin.com/en/trondelag/trondheim/restaurant/fagn-bistro'
VYN26 = 'https://guide.michelin.com/is/en/skane/simrishamn_2683288/restaurant/vyn-food-wine-bar'

# A1: (award id, from venue, to venue, source, year, rank, url)
MOVES = [
 (15683,'ve_d6d7a07cee','ve_38916224da','asia-50-best-restaurants',2026,65,ASIA26),
 (16923,'ve_965e0e3908','ve_273774c457','oad',2025,88,OAD_N25),
 (16921,'ve_965e0e3908','ve_273774c457','oad',2026,16,OAD_N26),
 (17153,'ve_1779942f15','ve_842d853e13','oad',2025,509,OAD_N25),
 (17151,'ve_1779942f15','ve_842d853e13','oad',2026,486,OAD_N26),
 (3422,'ve_b6eb74a0a2','ve_175f7d63c2','oad',2025,196,OAD_J25),
]
# B: (name, city id, city slug, city display, country, [(award, from venue, year, url)])
NEW = [
 ('Wörgötter - Wirtshaus','ci_4421c43eb7','ligist','Ligist','Austria',[(5938,'ve_9acf561dcf',2025,AT_BIB)],1,2),
 ('Schlosskeller Wirtshaus','ci_f957c08967','leibnitz','Leibnitz','Austria',[(5898,'ve_fb7dc1ff33',2025,AT_BIB)],1,2),
 ('Tai Wah Pork Noodle','ci_d3197fb64e','singapore','Singapore','Singapore',[(8214,'ve_c2e6c8acfb',2025,SG25)],205,206),
 ('FAGN-Bistro','ci_9bd6842b49','trondheim','Trondheim','Norway',[(12737,'ve_7a967f498b',2026,FAGN26),(12739,'ve_7a967f498b',2025,FAGN25)],2,3),
 ('Vyn Food & Wine Bar','ci_50fc6ffdaf','simrishamn','Simrishamn','Sweden',[(3142,'ve_c5e00877c1',2026,VYN26)],1,2),
]
TOUCH = sorted({'ve_d1e61a315d','ve_732d5cc78a'} | {m[1] for m in MOVES} | {m[2] for m in MOVES} | {a[1] for n in NEW for a in n[5]})
AWARDS = sorted([15336] + [m[0] for m in MOVES] + [a[0] for n in NEW for a in n[5]])
FP_SQL = ("SELECT md5(t) FROM (SELECT "
 "(SELECT string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id) FROM venues v WHERE v.id = ANY (ARRAY[" + ','.join(q(x) for x in TOUCH) + "])) || E'\\n' || "
 "(SELECT string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.rank::text,'')||'|'||coalesce(a.source_url,''), E'\\n' ORDER BY a.id) FROM awards a WHERE a.id = ANY (ARRAY[" + ','.join(map(str,AWARDS)) + "])) || E'\\n' || "
 "(SELECT string_agg(s.city_slug||'|'||s.slug||'|'||s.venue_id||'|'||s.is_canonical, E'\\n' ORDER BY s.city_slug,s.slug) FROM slugs s WHERE s.venue_id IN ('ve_d1e61a315d','ve_732d5cc78a')) AS t) z")
if FP == '-':
    print(FP_SQL); sys.exit(0)

new_cols = []
for n in NEW:
    sl = slugify(n[0]); vid = 've_' + md10(n[2] + ':' + sl)
    new_cols.append((vid, sl) + n)
NF = 'ci_' + md10('naples-fl')
L = []
w = L.append
w("-- fix-placeid-tailor-2026-11-03.sql")
w('-- CompassEats, Nov 3 2026. Open items 1 and 2. Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A". This file runs only after his "go".')
w("-- 1A: The Tailory ve_d1e61a315d becomes Tailor, status closed, published false. New canonical /new-york/tailor. Old slug non-canonical. Award 15336 gets the 50 Best URL. No redirect (Nov 2 rule: a hidden venue URL gives a 404).")
w("-- 2A: 6 award rows move to the venue the publisher names, each with a URL. Asia 2026 No. 65 to Fumee. OAD Joel Robuchon at The Mansion (2), Fiola da Fabio Trabocchi (2), Sukiyabashi Jiro Roppongi (1).")
w("-- 4A: 5 new active venues under the Michelin card names, 6 Bib rows move to them with a URL. Stars stay on the old venues. No price row on a new venue. Old venue names and prices do not change.")
w("-- 5A: new city Naples, Florida (naples-fl). Bleu Provence moves, redirect /naples/bleu-provence. No URL on award 21794 (the page does not print 2026). Kabuki, Carmen, Fiesta: no change.")
w("-- 3B: 12 A2 rows: no change.")
w("-- Expected after: venues 11,325 (active 11,032, closed 293); awards 25,323; Michelin 2025 no URL 3,029; Michelin 2026 no URL 434; slugs 13,173 (non-canonical 1,848); listings 11,325; city labels 24,057;")
w("--   cities 3,280, sum 11,032; redirects 11; price 7,759; rename_batches 33; rename_rows 1,398; ledger 205 rows; audit_log +54 (120,092 rows).")
w("BEGIN;"); w("DO $fix$"); w("DECLARE n bigint; s text; fp text; aud_max bigint; bid bigint; x bigint;"); w("BEGIN")
w("  -- PRE gates")
w("  " + FP_SQL.replace("SELECT md5(t) FROM", "SELECT md5(t) INTO fp FROM", 1) + ";")
w(f"  IF fp IS DISTINCT FROM {q(FP)} THEN RAISE EXCEPTION 'plan fingerprint %', fp; END IF;")
w("  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM venues WHERE status='active') <> 11028 OR (SELECT count(*) FROM venues WHERE status='closed') <> 292 THEN RAISE EXCEPTION 'venues before'; END IF;")
w("  IF (SELECT count(*) FROM awards) <> 25323 THEN RAISE EXCEPTION 'awards before'; END IF;")
w("  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3033 THEN RAISE EXCEPTION '2025 no URL before'; END IF;")
w("  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 436 THEN RAISE EXCEPTION '2026 no URL before'; END IF;")
w("  IF (SELECT count(*) FROM slugs) <> 13167 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1847 OR (SELECT count(*) FROM listings) <> 11320 OR (SELECT count(*) FROM city_label_source) <> 24047 THEN RAISE EXCEPTION 'child tables before'; END IF;")
w("  IF (SELECT count(*) FROM cities) <> 3279 OR (SELECT sum(venues_count) FROM cities) <> 11028 OR (SELECT count(*) FROM redirects) <> 10 OR (SELECT count(*) FROM price) <> 7759 THEN RAISE EXCEPTION 'cities, redirects, price before'; END IF;")
w("  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;")
w("  IF (SELECT count(*) FROM rename_batches) <> 32 OR (SELECT count(*) FROM rename_rows) <> 1397 OR EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='rename-tailor-new-york-2026-11-03') OR EXISTS (SELECT 1 FROM rename_rows WHERE venue_id='ve_d1e61a315d') THEN RAISE EXCEPTION 'rename before'; END IF;")
w("  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;")
w("  IF (SELECT count(*) FROM source_capture_ledger) <> 199 THEN RAISE EXCEPTION 'ledger before'; END IF;")
w("  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 120038 OR aud_max <> 125867 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;")
w(f"  IF {q(NF)} <> 'ci_'||left(md5('naples-fl'),10) THEN RAISE EXCEPTION 'city id rule'; END IF;")
w(f"  IF EXISTS (SELECT 1 FROM cities WHERE id={q(NF)} OR slug='naples-fl') OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='naples-fl') THEN RAISE EXCEPTION 'city clash'; END IF;")
w("  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='new-york' AND slug='tailor') OR EXISTS (SELECT 1 FROM venues WHERE city_id='ci_d44d6be1a3' AND norm_key=norm_key('Tailor')) THEN RAISE EXCEPTION 'tailor clash'; END IF;")
w("  IF EXISTS (SELECT 1 FROM redirects WHERE from_path IN ('/naples/bleu-provence','/naples-fl/bleu-provence') OR to_path LIKE '%bleu-provence%' OR from_path LIKE '/new-york/t%' OR to_path LIKE '%tailor%') THEN RAISE EXCEPTION 'redirect clash'; END IF;")
w("  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id IN ('ve_d1e61a315d','ve_732d5cc78a')) THEN RAISE EXCEPTION 'blurb'; END IF;")
w("  IF EXISTS (SELECT 1 FROM awards WHERE venue_id='ve_38916224da' AND source_id='asia-50-best-restaurants' AND year=2026) OR EXISTS (SELECT 1 FROM awards WHERE venue_id IN ('ve_273774c457','ve_842d853e13','ve_175f7d63c2') AND source_id='oad') THEN RAISE EXCEPTION 'target already holds the row'; END IF;")
for vid, sl, name, cid, cslug, cdisp, country, aw, c0, c1 in new_cols:
    w(f"  IF {q(vid)} <> 've_'||left(md5({q(cslug+':'+sl)}),10) THEN RAISE EXCEPTION 'venue id rule {sl}'; END IF;")
    w(f"  IF trim(both '-' from regexp_replace(lower(f_unaccent({q(name)})),'[^a-z0-9]+','-','g')) <> {q(sl)} THEN RAISE EXCEPTION 'slug rule {sl}'; END IF;")
    w(f"  IF EXISTS (SELECT 1 FROM venues WHERE id={q(vid)} OR (city_id={q(cid)} AND norm_key=norm_key({q(name)}))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug={q(cslug)} AND slug={q(sl)}) THEN RAISE EXCEPTION 'clash {sl}'; END IF;")
    w(f"  IF (SELECT venues_count FROM cities WHERE id={q(cid)} AND slug={q(cslug)}) IS DISTINCT FROM {c0} THEN RAISE EXCEPTION 'count {cslug}'; END IF;")
w("  IF (SELECT venues_count FROM cities WHERE id='ci_d44d6be1a3' AND slug='new-york') IS DISTINCT FROM 346 OR (SELECT venues_count FROM cities WHERE id='ci_d5fc4b0e45' AND slug='naples') IS DISTINCT FROM 9 THEN RAISE EXCEPTION 'count new-york, naples'; END IF;")
w("")
w("  -- WRITE: 1A The Tailory")
note = f'Open item 2; live name is a Google place name of a suit shop; 50 Best prints Tailor, New York, 2009 No. 49; closed Nov 2009 ({PUNCH}); Ben Nov 3 20:14 ET "1A"'
w(f"  INSERT INTO rename_batches (batch_key, status, note) VALUES ('rename-tailor-new-york-2026-11-03', 'staged', {q('Open item 2: The Tailory to Tailor; fixture fixtures/rename/tailor-new-york-2026-11-03.csv; Ben Nov 3 20:14 ET \"1A\"')}) RETURNING id INTO bid;")
w("  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)")
w(f"  SELECT bid, 1, v.id, v.name, 'Tailor', 'worlds-50-best-bars', {q(W50)}, 'rename', jsonb_build_object('note', {q(note)}, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', s.city_slug, 'slug', s.slug)")
w("    FROM venues v JOIN slugs s ON s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical WHERE v.id='ve_d1e61a315d';")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;")
w("  PERFORM set_config('app.allow_rename', 'on', true);")
w("  UPDATE venues SET name='Tailor' WHERE id='ve_d1e61a315d' AND status='active';")
w("  GET DIAGNOSTICS n = ROW_COUNT;")
w("  PERFORM set_config('app.allow_rename', 'off', true);")
w("  IF n <> 1 THEN RAISE EXCEPTION 'renamed %', n; END IF;")
w("  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;")
w("  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND city_slug='new-york' AND slug='the-tailory-new-york-custom-suits-nyc-bespoke-tailor' AND venue_id='ve_d1e61a315d' AND is_canonical;")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', n; END IF;")
w("  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','new-york','tailor','ve_d1e61a315d',true);")
w("  UPDATE venues SET status='closed' WHERE id='ve_d1e61a315d' AND status='active';")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status %', n; END IF;")
w("  UPDATE listings SET published=false WHERE venue_id='ve_d1e61a315d' AND published;")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listing %', n; END IF;")
w("  UPDATE cities SET venues_count=345 WHERE id='ci_d44d6be1a3' AND venues_count=346;")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'new-york %', n; END IF;")
w(f"  UPDATE awards SET source_url={q(W50)} WHERE id=15336 AND venue_id='ve_d1e61a315d' AND source_id='worlds-50-best-bars' AND year=2009 AND rank=49 AND source_url IS NULL;")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '15336 %', n; END IF;")
w("")
w("  -- WRITE: 2A award moves")
for aid, fr, to, src, yr, rk, url in MOVES:
    w(f"  UPDATE awards SET venue_id={q(to)}, source_url={q(url)} WHERE id={aid} AND venue_id={q(fr)} AND source_id={q(src)} AND year={yr} AND rank={rk} AND source_url IS NULL;")
    w(f"  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '{aid} %', n; END IF;")
w("")
w("  -- WRITE: 4A new venues")
for vid, sl, name, cid, cslug, cdisp, country, aw, c0, c1 in new_cols:
    w(f"  INSERT INTO venues (id, name, category, city_id, status) VALUES ({q(vid)}, {q(name)}, 'restaurant', {q(cid)}, 'active');")
    w(f"  INSERT INTO listings (venue_id, property_id, published) VALUES ({q(vid)}, 'eats', true);")
    w(f"  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', {q(cslug)}, {q(sl)}, {q(vid)}, true);")
    w(f"  UPDATE cities SET venues_count={c1} WHERE id={q(cid)} AND venues_count={c0};")
    w(f"  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'count {cslug} %', n; END IF;")
    w("  WITH ins AS (")
    w("    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES")
    w(f"      ({q(vid)}, {q(cdisp)}, 'city_display', 'michelin', {q('Michelin card and list: open item 1, split from a merged venue')}),")
    w(f"      ({q(vid)}, {q(country)}, 'country', 'michelin', {q('Michelin card and list: open item 1, split from a merged venue')})")
    w("    RETURNING *)")
    w("  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;")
    w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;")
    for aid, fr, yr, url in aw:
        w(f"  UPDATE awards SET venue_id={q(vid)}, source_url={q(url)} WHERE id={aid} AND venue_id={q(fr)} AND source_id='michelin' AND year={yr} AND category='Bib Gourmand' AND source_url IS NULL;")
        w(f"  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '{aid} %', n; END IF;")
w("")
w("  -- WRITE: 5A Bleu Provence")
w(f"  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ({q(NF)}, 'naples-fl', 'Naples, Florida', 'United States', 'US', 'city', NULL, NULL, NULL, 1);")
w(f"  UPDATE venues SET city_id={q(NF)} WHERE id='ve_732d5cc78a' AND city_id='ci_d5fc4b0e45';")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'bleu city %', n; END IF;")
w("  UPDATE slugs SET city_slug='naples-fl' WHERE property_id='eats' AND city_slug='naples' AND slug='bleu-provence' AND venue_id='ve_732d5cc78a' AND is_canonical;")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'bleu slug %', n; END IF;")
w("  UPDATE cities SET venues_count=8 WHERE id='ci_d5fc4b0e45' AND venues_count=9;")
w("  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'naples %', n; END IF;")
w("  INSERT INTO redirects (from_path, to_path) VALUES ('/naples/bleu-provence','/naples-fl/bleu-provence');")
w("  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) VALUES ('redirects','/naples/bleu-provence','INSERT',NULL,jsonb_build_object('from_path','/naples/bleu-provence','to_path','/naples-fl/bleu-provence'));")
w("")
w("  -- WRITE: ledger")
BEN = 'Ben Nov 3 20:14 ET "1A, 2A, 3B, 4A, 5A"'
LED = [
 ('worlds-50-best-bars','name',1,f'rename-apply:rename-tailor-new-york-2026-11-03 | gated SQL file docs/fix-placeid-tailor-2026-11-03.sql (Write connector), same writes as the job | {W50} | {BEN}'),
 ('worlds-50-best-bars','award',1,f'cleanup:fix-placeid-tailor-2026-11-03 | open item 2: award 15336 URL; Tailor closed Nov 2009 ({PUNCH}) | {BEN}'),
 ('asia-50-best-restaurants','award',1,f'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: award 15683 Asia 2026 No. 65 moved from Ensue ve_d6d7a07cee to Fumee ve_38916224da | {ASIA26} | {BEN}'),
 ('oad','award',5,f'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: awards 16923, 16921, 17153, 17151, 3422 moved to the venue the OAD list names | {OAD_N25} | {OAD_N26} | {OAD_J25} | {BEN}'),
 ('michelin','award',6,f'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: Bib rows 5938, 5898, 8214, 12737, 12739, 3142 moved to 5 new venues under the Michelin card names, each with a URL | {BEN}'),
 ('michelin','city_label',10,f'cleanup:fix-placeid-tailor-2026-11-03 | open item 1: city labels of the 5 new venues | {BEN}'),
]
w("  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES")
w(",\n".join(f"    ({q(a)}, {q(b)}, {c}, {q(d)})" for a,b,c,d in LED) + ";")
w("")
w("  -- POST gates")
w("  IF (SELECT count(*) FROM venues) <> 11325 OR (SELECT count(*) FROM venues WHERE status='active') <> 11032 OR (SELECT count(*) FROM venues WHERE status='closed') <> 293 THEN RAISE EXCEPTION 'venues after'; END IF;")
w("  IF (SELECT count(*) FROM awards) <> 25323 THEN RAISE EXCEPTION 'awards after'; END IF;")
w("  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3029 THEN RAISE EXCEPTION '2025 no URL after'; END IF;")
w("  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 434 THEN RAISE EXCEPTION '2026 no URL after'; END IF;")
w("  IF (SELECT count(*) FROM slugs) <> 13173 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1848 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11325 OR (SELECT count(*) FROM listings) <> 11325 OR (SELECT count(*) FROM city_label_source) <> 24057 THEN RAISE EXCEPTION 'child tables after'; END IF;")
w("  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF x <> 0 THEN RAISE EXCEPTION 'canonical %', x; END IF;")
w("  IF (SELECT count(*) FROM cities) <> 3280 OR (SELECT sum(venues_count) FROM cities) <> 11032 OR (SELECT count(*) FROM redirects) <> 11 OR (SELECT count(*) FROM price) <> 7759 THEN RAISE EXCEPTION 'cities, redirects, price after'; END IF;")
w("  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;")
w("  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;")
w("  IF (SELECT norm_key FROM venues WHERE id='ve_d1e61a315d') IS DISTINCT FROM 'tailor' THEN RAISE EXCEPTION 'norm key'; END IF;")
w("  IF (SELECT count(*) FROM rename_batches) <> 33 OR (SELECT count(*) FROM rename_rows) <> 1398 THEN RAISE EXCEPTION 'rename after'; END IF;")
w("  IF (SELECT count(*) FROM source_capture_ledger) <> 205 THEN RAISE EXCEPTION 'ledger after'; END IF;")
w("  SELECT count(*) INTO x FROM (SELECT venue_id, year FROM awards WHERE source_id='michelin' AND category IN ('Bib Gourmand','One Star','Two Stars','Three Stars') GROUP BY 1,2 HAVING count(*)>1) z; IF x <> 0 THEN RAISE EXCEPTION 'Bib and star on one venue %', x; END IF;")
w("  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE \"C\", action COLLATE \"C\") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;")
w("  IF s IS DISTINCT FROM 'awards:UPDATE=13,cities:INSERT=1,cities:UPDATE=7,city_label_source:INSERT=10,listings:INSERT=5,listings:UPDATE=1,redirects:INSERT=1,slugs:INSERT=6,slugs:UPDATE=2,venues:INSERT=5,venues:UPDATE=3' THEN RAISE EXCEPTION 'audit: %', s; END IF;")
w("  SELECT count(*) INTO x FROM audit_log a WHERE a.id>aud_max AND a.table_name='venues' AND a.action='UPDATE' AND a.row_pk='ve_d1e61a315d' AND a.new_row->>'name'='Tailor'; IF x <> 2 THEN RAISE EXCEPTION 'audit tailor %', x; END IF;")
w("  RAISE NOTICE 'OK: all gates passed';")
w("END"); w("$fix$;"); w("COMMIT;"); w("SELECT 'OK: all gates passed' AS result;")
out = os.path.join(ROOT, 'docs', 'fix-placeid-tailor-2026-11-03.sql')
open(out, 'w', encoding='utf-8', newline='\n').write("\n".join(L) + "\n")
fx = os.path.join(ROOT, 'fixtures', 'rename', 'tailor-new-york-2026-11-03.csv')
with open(fx, 'w', encoding='utf-8', newline='') as h:
    c = csv.writer(h); c.writerow('batch_key,venue_id,expected_name,new_name,source_id,source_url,note'.split(','))
    c.writerow(['rename-tailor-new-york-2026-11-03','ve_d1e61a315d','The Tailory New York - Custom Suits NYC - Bespoke Tailor®','Tailor','worlds-50-best-bars',W50,note])
for f in (out, fx): print(f, len(open(f,'rb').read()), hashlib.sha256(open(f,'rb').read()).hexdigest())
for v in new_cols: print(v[0], v[1], v[2], v[4])
print(NF)
