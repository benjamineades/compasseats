#!/usr/bin/env python3
# Builds docs/fix-a2-a3-d-2026-11-03.sql. Usage: build_fix_a2_a3_d.py <fingerprint or ->
import sys, hashlib, re, unicodedata, os
FP = sys.argv[1] if len(sys.argv) > 1 else '-'
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
md10 = lambda s: hashlib.md5(s.encode()).hexdigest()[:10]
def slugify(s):
    s = ''.join(c for c in unicodedata.normalize('NFKD', s) if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', s.lower()).strip('-')
q = lambda s: "'" + s.replace("'", "''") + "'"
BEN = 'Ben Nov 3 20:42 ET "1A, 2A, 3A, 4A, 5A, 6A"'
O = 'https://www.oadguides.com/lists/%s/top-restaurants/%d'
NA25, NA26, E25, J25, J26, A25, S25, S26 = O%('north-america',2025), O%('north-america',2026), O%('europe',2025), O%('japan',2025), O%('japan',2026), O%('asia',2025), O%('south-america',2025), O%('south-america',2026)
FG = 'https://www.forbestravelguide.com/restaurants/new-york-city-new-york/masa'
MI = 'https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-to-new-york-city-2025'
W = 'https://www.the50.com/restaurants/best-in-the-world/previous-list/%d'
BM, GA, IL, SE, BU, KM, KU, YZ, SK, ME, SS, TY, KA, CA, FI = 've_fbcb833f0c','ve_6c564637e8','ve_e8097f89e5','ve_e4697958f0','ve_1b2f4308ae','ve_411ead11c6','ve_fe34271323','ve_61cf53898d','ve_26a217eb82','ve_7b02b65595','ve_a248207d2a','ve_5ba6c32664','ve_444325fab9','ve_2935ce649e','ve_6ed52d9126'
C = dict(ny=('ci_d44d6be1a3','new-york','New York','United States'), to=('ci_79cca97018','toronto','Toronto','Canada'), tk=('ci_ef0cc10ff4','tokyo','Tokyo','Japan'), sh=('ci_22638a3131','shanghai','Shanghai','China'), mi=('ci_83227a721a','milan','Milan','Italy'), pr=('ci_'+md10('prato'),'prato','Prato','Italy'))
# name, city key, status, published
NEW = [('Masa','ny','active'),('Da Niko','mi','active'),('MOI Omakase','pr','active'),('Buca Yorkville','to','active'),('Mitani','tk','active'),('Yakitori Kurosaki','tk','active'),('Yamasaki','tk','active'),('Saeki Hanten','tk','active'),('Jean Georges','sh','active'),('Tempura Yamanoue Roppongi','tk','active'),('Yama no Ue','tk','closed')]
V = {}
for n,c,st in NEW: V[n] = 've_'+md10(C[c][1]+':'+slugify(n))
# award id, from venue, to venue (None = stays), source, year, rank or None, url or None
A = [(2668,BM,'Masa','oad',2026,92,NA26),(2670,BM,'Masa','oad',2025,67,NA25)]
A += [(2659,BM,'Masa','forbes-travel-guide',2026,None,FG)]
A += [(i,BM,'Masa','forbes-travel-guide',y,None,None) for i,y in ((2660,2025),(2661,2024),(2662,2023),(2663,2022),(2664,2021),(2665,2020))]
A += [(2666,BM,'Masa','la-liste',2026,None,None),(2667,BM,'Masa','michelin',2025,None,MI),(2672,BM,'Masa','worlds-50-best-restaurants',2009,27,W%2009),(2673,BM,'Masa','worlds-50-best-restaurants',2005,32,W%2005)]
A += [(2669,BM,None,'oad',2026,396,NA26),(2671,BM,None,'oad',2025,387,NA25)]
A += [(18439,IL,'Da Niko','oad',2025,304,E25),(6339,SE,'MOI Omakase','oad',2025,407,E25),(17532,BU,'Buca Yorkville','oad',2025,580,NA25),(18648,KM,'Mitani','oad',2025,28,J25),(18695,KU,'Yakitori Kurosaki','oad',2025,469,J25),(18713,YZ,'Yamasaki','oad',2025,107,J25),(18846,SK,'Saeki Hanten','oad',2025,528,J25),(18127,ME,'Jean Georges','oad',2025,179,A25)]
A += [(17234,GA,None,'oad',2025,254,NA25),(17232,GA,None,'oad',2026,267,NA26),(18027,SS,None,'oad',2025,354,A25)]
A += [(19032,TY,'Tempura Yamanoue Roppongi','oad',2025,498,J25),(19033,TY,'Yama no Ue','oad',2025,590,J25)]
A += [(18573,KA,None,'oad',2025,615,E25),(17958,CA,None,'oad',2025,48,S25),(17957,CA,None,'oad',2026,53,S26),(17913,FI,None,'oad',2025,28,S25),(17912,FI,None,'oad',2026,33,S26)]
assert len(A)==33 and len({a[0] for a in A})==33
TOUCH = sorted({a[1] for a in A})
AWARDS = sorted(a[0] for a in A)
ins = lambda L: ','.join(q(x) for x in L)
FP_SQL = ("SELECT md5(t) FROM (SELECT "
 "(SELECT string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id) FROM venues v WHERE v.id IN (" + ins(TOUCH) + ")) || E'\\n' || "
 "(SELECT string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.rank::text,'')||'|'||coalesce(a.source_url,''), E'\\n' ORDER BY a.id) FROM awards a WHERE a.id IN (" + ','.join(map(str,AWARDS)) + ")) || E'\\n' || "
 "(SELECT string_agg(s.city_slug||'|'||s.slug||'|'||s.venue_id||'|'||s.is_canonical, E'\\n' ORDER BY s.city_slug,s.slug) FROM slugs s WHERE s.venue_id IN ('"+KA+"','"+CA+"')) || E'\\n' || "
 "(SELECT p.venue_id||'|'||p.symbol_raw||'|'||p.source FROM price p WHERE p.venue_id='"+BM+"') AS t) z")
if FP == '-':
    print(FP_SQL); sys.exit(0)
L=[]; w=L.append
d = lambda tag,k=1: f" GET DIAGNOSTICS n = ROW_COUNT; IF n <> {k} THEN RAISE EXCEPTION '{tag} %', n; END IF;"
w("-- fix-a2-a3-d-2026-11-03.sql")
w(f'-- CompassEats, Nov 3 2026. Open items 1, 2, 3. {BEN}. This file runs only after his "go".')
w("-- 1A Masa: new venue, 13 rows and the price leave Bar Masa. 2A: printed-twice rows stay, with a URL (Gari 17234, 17232; Sushi Saito 18027). 3A: Yamasaki. 4A: new row OAD 2026 No. 773 on Tempura Yamanoue Ginza. 5A: Carmen Medellin keeps its name. 6A: Mitani and Yakitori Kurosaki active.")
w("-- New venues 11 (10 active, Yama no Ue closed and not published). New city Prato. Kabuki Madrid moves Milan to Madrid. Carmen moves Lima to Medellin; non-canonical /lima/restaurante-carmen row does not change. City labels of the 2 moved venues do not change (what OAD printed).")
w("-- Expected after: venues 11,336 (active 11,042, closed 294); awards 25,324; Michelin 2025 no URL 3,028; Michelin 2026 no URL 434; slugs 13,184 (non-canonical 1,848); listings 11,336; city labels 24,079;")
w("--   cities 3,281, sum 11,042; redirects 13; price 7,759; rename_batches 33; rename_rows 1,398; ledger 211 rows; audit_log +104 (120,196 rows).")
w("BEGIN;"); w("DO $fix$"); w("DECLARE n bigint; s text; fp text; aud_max bigint; x bigint;"); w("BEGIN")
w("  -- PRE gates")
w("  "+FP_SQL.replace("SELECT md5(t) FROM","SELECT md5(t) INTO fp FROM",1)+";")
w(f"  IF fp IS DISTINCT FROM {q(FP)} THEN RAISE EXCEPTION 'plan fingerprint %', fp; END IF;")
w("  IF (SELECT count(*) FROM venues) <> 11325 OR (SELECT count(*) FROM venues WHERE status='active') <> 11032 OR (SELECT count(*) FROM venues WHERE status='closed') <> 293 THEN RAISE EXCEPTION 'venues before'; END IF;")
w("  IF (SELECT count(*) FROM awards) <> 25323 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3029 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 434 THEN RAISE EXCEPTION 'awards before'; END IF;")
w("  IF (SELECT count(*) FROM slugs) <> 13173 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1848 OR (SELECT count(*) FROM listings) <> 11325 OR (SELECT count(*) FROM city_label_source) <> 24057 THEN RAISE EXCEPTION 'child tables before'; END IF;")
w("  IF (SELECT count(*) FROM cities) <> 3280 OR (SELECT sum(venues_count) FROM cities) <> 11032 OR (SELECT count(*) FROM redirects) <> 11 OR (SELECT count(*) FROM price) <> 7759 THEN RAISE EXCEPTION 'cities, redirects, price before'; END IF;")
w("  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;")
w("  IF (SELECT count(*) FROM rename_batches) <> 33 OR (SELECT count(*) FROM rename_rows) <> 1398 OR (SELECT count(*) FROM source_capture_ledger) <> 205 THEN RAISE EXCEPTION 'rename, ledger before'; END IF;")
w("  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;")
w("  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 120092 OR aud_max <> 125921 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;")
w(f"  IF {q(C['pr'][0])} <> 'ci_'||left(md5('prato'),10) OR EXISTS (SELECT 1 FROM cities WHERE id={q(C['pr'][0])} OR slug='prato') OR EXISTS (SELECT 1 FROM slugs WHERE city_slug='prato' AND (is_canonical OR venue_id<>'ve_542c195114')) THEN RAISE EXCEPTION 'prato'; END IF;")
for n,c,st in NEW:
    sl=slugify(n); vid=V[n]; cid,cs,_,_=C[c]
    w(f"  IF {q(vid)} <> 've_'||left(md5({q(cs+':'+sl)}),10) OR trim(both '-' from regexp_replace(lower(f_unaccent({q(n)})),'[^a-z0-9]+','-','g')) <> {q(sl)} OR EXISTS (SELECT 1 FROM venues WHERE id={q(vid)} OR (city_id={q(cid)} AND norm_key=norm_key({q(n)}))) OR EXISTS (SELECT 1 FROM slugs WHERE city_slug={q(cs)} AND slug={q(sl)}) THEN RAISE EXCEPTION 'clash {sl}'; END IF;")
w("  IF EXISTS (SELECT 1 FROM slugs WHERE (city_slug='madrid' AND slug='kabuki-madrid') OR (city_slug='medellin' AND slug='carmen')) OR EXISTS (SELECT 1 FROM venues WHERE (city_id='ci_ed2539fe89' AND norm_key='kabukimadrid') OR (city_id='ci_4796edd31b' AND norm_key='carmen')) THEN RAISE EXCEPTION 'move clash'; END IF;")
w("  IF EXISTS (SELECT 1 FROM redirects WHERE from_path IN ('/milan/kabuki-madrid','/lima/carmen') OR to_path IN ('/madrid/kabuki-madrid','/medellin/carmen','/milan/kabuki-madrid','/lima/carmen')) THEN RAISE EXCEPTION 'redirect clash'; END IF;")
w("  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id IN ('"+KA+"','"+CA+"','"+BM+"')) THEN RAISE EXCEPTION 'blurb'; END IF;")
w("  IF EXISTS (SELECT 1 FROM awards WHERE venue_id='"+TY+"' AND source_id='oad' AND year=2026) THEN RAISE EXCEPTION 'ginza 2026 exists'; END IF;")
w("  -- WRITE: city")
w(f"  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ({q(C['pr'][0])}, 'prato', 'Prato', 'Italy', 'IT', 'city', NULL, NULL, NULL, 1);")
w("  -- WRITE: new venues")
for n,c,st in NEW:
    sl=slugify(n); vid=V[n]; cid,cs,cd,co=C[c]
    pub='false' if st=='closed' else 'true'
    w(f"  INSERT INTO venues (id, name, category, city_id, status) VALUES ({q(vid)}, {q(n)}, 'restaurant', {q(cid)}, {q(st)});")
    w(f"  INSERT INTO listings (venue_id, property_id, published) VALUES ({q(vid)}, 'eats', {pub});")
    w(f"  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', {q(cs)}, {q(sl)}, {q(vid)}, true);")
    w("  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES "+f"({q(vid)}, {q(cd)}, 'city_display', 'oad', 'open items 1-2 split'), ({q(vid)}, {q(co)}, 'country', 'oad', 'open items 1-2 split') RETURNING *) INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;"+d('labels',2))
w("  -- WRITE: awards")
for aid,fr,to,src,yr,rk,url in A:
    sets=[]
    if to: sets.append(f"venue_id={q(V[to])}")
    if url: sets.append(f"source_url={q(url)}")
    rkc = f"rank={rk}" if rk else "rank IS NULL"
    w(f"  UPDATE awards SET {', '.join(sets)} WHERE id={aid} AND venue_id={q(fr)} AND source_id={q(src)} AND year={yr} AND {rkc} AND source_url IS NULL;"+d(str(aid)))
w(f"  INSERT INTO awards (venue_id, source_id, year, rank, category, source_url) VALUES ('{TY}', 'oad', 2026, 773, 'No. 773', {q(J26)});")
w("  -- WRITE: price")
w(f"  UPDATE price SET venue_id={q(V['Masa'])} WHERE venue_id='{BM}' AND symbol_raw='$$$$' AND source='legacy_guide';"+d('price'))
w("  -- WRITE: moved venues")
w(f"  UPDATE venues SET city_id='ci_ed2539fe89' WHERE id='{KA}' AND city_id='ci_83227a721a';"+d('kabuki'))
w(f"  UPDATE slugs SET city_slug='madrid' WHERE property_id='eats' AND city_slug='milan' AND slug='kabuki-madrid' AND venue_id='{KA}' AND is_canonical;"+d('kabuki slug'))
w(f"  UPDATE venues SET city_id='ci_4796edd31b' WHERE id='{CA}' AND city_id='ci_6742923575';"+d('carmen'))
w(f"  UPDATE slugs SET city_slug='medellin' WHERE property_id='eats' AND city_slug='lima' AND slug='carmen' AND venue_id='{CA}' AND is_canonical;"+d('carmen slug'))
for f,t in (('/milan/kabuki-madrid','/madrid/kabuki-madrid'),('/lima/carmen','/medellin/carmen')):
    w(f"  INSERT INTO redirects (from_path, to_path) VALUES ({q(f)},{q(t)});")
    w(f"  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) VALUES ('redirects',{q(f)},'INSERT',NULL,jsonb_build_object('from_path',{q(f)},'to_path',{q(t)}));")
w("  -- WRITE: city counts")
for cid,a0,a1 in (('ci_d44d6be1a3',345,346),('ci_79cca97018',71,72),('ci_ef0cc10ff4',595,600),('ci_22638a3131',112,113),('ci_ed2539fe89',76,77),('ci_4796edd31b',3,4),('ci_6742923575',31,30)):
    w(f"  UPDATE cities SET venues_count={a1} WHERE id={q(cid)} AND venues_count={a0};"+d(cid))
w("  -- WRITE: ledger")
K='cleanup:fix-a2-a3-d-2026-11-03'
LED=[('oad','award',23,f'{K} | open items 1-3: 22 rows moved or given the list URL, 1 new row 2026 No. 773 on Tempura Yamanoue Ginza | {BEN}'),
('forbes-travel-guide','award',7,f'{K} | open item 1: 2659-2665 moved Bar Masa to Masa; 2659 has the URL; 2020-2025 pages not read | {FG} | {BEN}'),
('la-liste','award',1,f'{K} | open item 1: 2666 moved to Masa; no URL, read from a copy of the list | {BEN}'),
('michelin','award',1,f'{K} | open item 1: 2667 Two Stars moved to Masa | {MI} | {BEN}'),
('worlds-50-best-restaurants','award',2,f'{K} | open item 1: 2672, 2673 moved to Masa | {W%2009} | {W%2005} | {BEN}'),
('oad','city_label',22,f'{K} | open items 1-2: city labels of the 11 new venues; Yama no Ue city from the owner site | {BEN}')]
w("  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES")
w(",\n".join(f"    ({q(a)}, {q(b)}, {c}, {q(e)})" for a,b,c,e in LED)+";")
w("  -- POST gates")
w("  IF (SELECT count(*) FROM venues) <> 11336 OR (SELECT count(*) FROM venues WHERE status='active') <> 11042 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues after'; END IF;")
w("  IF (SELECT count(*) FROM awards) <> 25324 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3028 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 434 THEN RAISE EXCEPTION 'awards after'; END IF;")
w("  IF (SELECT count(*) FROM slugs) <> 13184 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1848 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11336 OR (SELECT count(*) FROM listings) <> 11336 OR (SELECT count(*) FROM city_label_source) <> 24079 THEN RAISE EXCEPTION 'child tables after'; END IF;")
w("  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF x <> 0 THEN RAISE EXCEPTION 'canonical %', x; END IF;")
w("  IF (SELECT count(*) FROM cities) <> 3281 OR (SELECT sum(venues_count) FROM cities) <> 11042 OR (SELECT count(*) FROM redirects) <> 13 OR (SELECT count(*) FROM price) <> 7759 THEN RAISE EXCEPTION 'cities, redirects, price after'; END IF;")
w("  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;")
w("  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;")
w("  IF (SELECT count(*) FROM rename_batches) <> 33 OR (SELECT count(*) FROM rename_rows) <> 1398 OR (SELECT count(*) FROM source_capture_ledger) <> 211 THEN RAISE EXCEPTION 'rename, ledger after'; END IF;")
w(f"  IF (SELECT count(*) FROM awards WHERE venue_id={q(V['Masa'])}) <> 13 OR (SELECT count(*) FROM awards WHERE venue_id='{BM}') <> 2 OR (SELECT count(*) FROM awards WHERE venue_id='{TY}') <> 1 OR EXISTS (SELECT 1 FROM price WHERE venue_id='{BM}') THEN RAISE EXCEPTION 'masa, ginza after'; END IF;")
w("  SELECT count(*) INTO x FROM venues v WHERE v.id IN ("+ins(TOUCH+[V[n] for n,_,_ in NEW])+") AND NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id=v.id); IF x <> 0 THEN RAISE EXCEPTION 'venue with 0 awards %', x; END IF;")
w("  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE \"C\", action COLLATE \"C\") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;")
w("  IF s IS DISTINCT FROM 'awards:INSERT=1,awards:UPDATE=33,cities:INSERT=1,cities:UPDATE=7,city_label_source:INSERT=22,listings:INSERT=11,price:UPDATE=1,redirects:INSERT=2,slugs:INSERT=11,slugs:UPDATE=2,venues:INSERT=11,venues:UPDATE=2' THEN RAISE EXCEPTION 'audit: %', s; END IF;")
w("  RAISE NOTICE 'OK: all gates passed';")
w("END"); w("$fix$;"); w("COMMIT;"); w("SELECT 'OK: all gates passed' AS result;")
out=os.path.join(ROOT,'docs','fix-a2-a3-d-2026-11-03.sql')
open(out,'w',encoding='utf-8',newline='\n').write("\n".join(L)+"\n")
print(out,len(L),hashlib.sha256(open(out,'rb').read()).hexdigest())
for n,c,st in NEW: print(V[n],n,C[c][1],slugify(n),st)
print(C['pr'][0])
