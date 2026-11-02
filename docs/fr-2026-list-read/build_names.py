import hashlib,sys
K='rename-open-items-names-2-2026-11-02'
F='fix-open-items-names-native-2026-11-02.sql'
M=lambda p:'https://guide.michelin.com/en/'+p
rows=[
(1,'ve_7b865a33b7','Le Manoir aux Quat’Saisons, A Belmond Hotel, Oxfordshire','Le Manoir aux Quat’Saisons','venue','https://www.belmond.com/en/hotels/europe/uk/le-manoir-aux-quat-saisons-oxfordshire','oxford','le-manoir-aux-quat-saisons-a-belmond-hotel-oxfordshire','le-manoir-aux-quat-saisons',False,'R4: own site h1 and title write Le Manoir aux Quat’Saisons (U+2019), read Nov 2. City stays Oxford (Ben 2A). Status stays closed (D1).'),
(2,'ve_d1cccaafdf','Château de Valmer','La Palmeraie','venue','https://www.chateauvalmer.com','la-croix-valmer','chateau-de-valmer','la-palmeraie',False,'R1: own site writes restaurant La Palmeraie; card h1 La Palmeraie - Château de Valmer, read Nov 2.'),
(3,'ve_7963871c91','Château Saint-Jean','La Chapelle','venue','https://www.chateau-saint-jean.com/restaurants-bar/restaurant-la-chapelle/','montlucon','chateau-saint-jean','la-chapelle',False,'R1: own site writes La Chapelle; card h1 La Chapelle - Château Saint-Jean, read Nov 2.'),
(4,'ve_ee898a4ee3','Hotel Belles Rives','La Passagère','venue','https://la-passagere.com/','juan-les-pins','hotel-belles-rives','la-passagere',False,'R1: own site writes La Passagère; card h1 La Passagère - Hôtel Belles Rives, read Nov 2.'),
(5,'ve_a8d9697131','Hotel La Bouitte','René et Maxime Meilleur','michelin',M('auvergne-rhone-alpes/saint-martin-de-belleville/restaurant/rene-et-maxime-meilleur'),'saint-martin-de-belleville','hotel-la-bouitte','rene-et-maxime-meilleur',True,'R2: own site writes René & Maxime Meilleur and René et Maxime; card h1 René et Maxime Meilleur, read Nov 2.'),
(6,'ve_eb0dbfc986','Hôtel Pashmina','Les Explorateurs','venue','https://www.hotelpashmina.com/','val-thorens','hotel-pashmina','les-explorateurs',False,'R1: own site writes Les Explorateurs; card h1 Les Explorateurs - Hôtel Pashmina, read Nov 2.'),
(7,'ve_2e35f20ae1','Le Relais Bernard Loiseau',"La Côte d''Or",'michelin',M('bourgogne-franche-comte/saulieu/restaurant/la-cote-d-or'),'saulieu','le-relais-bernard-loiseau','la-cote-d-or',True,"R3: own site writes LA CÔTE D''OR and la Côte d''Or; card h1 La Côte d''Or (U+0027), read Nov 2."),
(8,'ve_634228e9d5','Restaurant Girardin - 1 étoile Michelin','Restaurant Girardin','venue','https://www.maisondestetes.com/fr/restaurant-girardin.html','colmar','restaurant-girardin-1-etoile-michelin','restaurant-girardin',True,'R1: own site title writes Restaurant Girardin; card h1 Restaurant Girardin, read Nov 2.'),
]
ids=[r[1] for r in rows]; arr="ARRAY["+",".join("'%s'"%i for i in ids)+"]"
vals=",\n".join("    (%d,'%s','%s','%s','%s','%s','%s','%s','%s',%s,'%s')"%(r[0],r[1],r[2].replace("'","''") if "''" not in r[2] else r[2],r[3],r[4],r[5],r[6],r[7],r[8],'true' if r[9] else 'false',r[10]) for r in rows)
pairs=",".join("('%s','%s')"%(r[6],r[8]) for r in rows if not r[9])
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 10:21 ET "2A, 3A, 4A". This file runs only after his "go".
-- 2A + 3A rename batch {K}: Le Manoir (open item 2) and 7 French venues named after a hotel or with promotion text (open item 11).
--    Old slugs stay as non-canonical rows. 3 new slugs already exist as non-canonical rows of the same venue and change to canonical. 5 new slugs are new rows.
--    Held from open item 11: La Flibuste, La Table de l'Alpaga, Sarkara (no 2026 row, see the France 2026 list read of Nov 2).
-- 4A name_native: Naramachi Kuko ve_c0eba7ae71 = 奈良町 枸杞 (U+0020 between the words). Own site https://kuko-nara.jp title, read Nov 2. No ledger row (China Sep 27 precedent).
-- Expected after: venues 11,296 (active 10,930, closed 366); name_native 339; awards 25,081; slugs 13,013 (canonical 11,296, non-canonical 1,717);
--   listings 11,296; blurbs 142; price 7,729; city_label_source 23,993; cities 3,263, venues_count sum 10,930; city_aliases 266; redirects 9;
--   rename_batches 25, rename_rows 1,293; ledger 176 rows; audit_log +25 (venues UPDATE 9, slugs UPDATE 11, slugs INSERT 5).
-- Gate on the last audit id 123,667 and ledger 227: any other write first makes this file fail. RLS DDL adds no audit row, so the RLS file can run first.
-- Dry run: send the DO block through the Read connector. It stops at the first INSERT with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; bid bigint; n bigint; s text; r record;
  vren constant text[] := {arr};
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 15:10 UTC and after)
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10930 OR (SELECT count(*) FROM venues WHERE status='closed') <> 366 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(name_native) FROM venues) <> 338 THEN RAISE EXCEPTION 'name_native before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25081 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13008 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1712 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7729 THEN RAISE EXCEPTION 'listings/blurbs/price before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23993 OR (SELECT count(*) FROM city_aliases) <> 266 OR (SELECT count(*) FROM redirects) <> 9 THEN RAISE EXCEPTION 'labels/aliases/redirects before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3263 OR (SELECT sum(venues_count) FROM cities) <> 10930 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 24 OR (SELECT count(*) FROM rename_rows) <> 1285 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 175 OR led_max <> 227 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118153 OR aud_max <> 123667 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v
   WHERE v.id = ANY (vren) OR v.id='ve_c0eba7ae71';
  IF s IS DISTINCT FROM '174a7075d38bdfba3e2e8fe798dace67' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='{K}') THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = ANY (vren)) THEN RAISE EXCEPTION 'earlier rename row'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id = ANY (vren)) THEN RAISE EXCEPTION 'blurb on a renamed venue'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE (city_slug,slug) IN ({pairs})) THEN RAISE EXCEPTION 'new slug in use'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = ANY (vren) AND NOT is_canonical AND (city_slug,slug) IN (('saint-martin-de-belleville','rene-et-maxime-meilleur'),('saulieu','la-cote-d-or'),('colmar','restaurant-girardin'))) <> 3 THEN RAISE EXCEPTION 'existing slugs'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(a-belmond-hotel|chateau-de-valmer|chateau-saint-jean|hotel-belles-rives|hotel-la-bouitte|hotel-pashmina|relais-bernard-loiseau|1-etoile-michelin)' OR to_path ~ '(a-belmond-hotel|chateau-de-valmer|chateau-saint-jean|hotel-belles-rives|hotel-la-bouitte|hotel-pashmina|relais-bernard-loiseau|1-etoile-michelin)') THEN RAISE EXCEPTION 'redirect on a rename path'; END IF;
  IF (SELECT name_native FROM venues WHERE id='ve_c0eba7ae71') IS NOT NULL OR (SELECT name FROM venues WHERE id='ve_c0eba7ae71') <> 'Naramachi Kuko' THEN RAISE EXCEPTION 'Naramachi before'; END IF;

  ---------------------------------------------------------------- WRITE 1 (2A, 3A): rename batch
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('{K}', 'staged', 'Open items 2 and 11 (Ben, Nov 2 10:21 ET "2A, 3A"): rules R1-R4. Hotel names and promotion text replaced by the restaurant name. 8 venues.') RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  FOR r IN SELECT * FROM (VALUES
{vals}
  ) t(line, vid, oldn, newn, src, url, cs, olds, news, slug_exists, ev) LOOP
    IF norm_key(r.newn) IN (SELECT v.norm_key FROM venues v JOIN venues w ON w.id=r.vid AND v.city_id=w.city_id) THEN RAISE EXCEPTION 'norm_key collision %', r.vid; END IF;
    INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
    SELECT bid, r.line, v.id, v.name, r.newn, r.src, r.url, 'rename',
           jsonb_build_object('note', r.ev, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', r.cs, 'slug', r.olds)
      FROM venues v WHERE v.id=r.vid AND v.name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename row %', r.vid; END IF;
    UPDATE venues SET name=r.newn WHERE id=r.vid AND name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename %', r.vid; END IF;
    IF trim(both '-' from regexp_replace(lower(f_unaccent(r.newn)),'[^a-z0-9]+','-','g')) <> r.news THEN RAISE EXCEPTION 'slug rule %', r.vid; END IF;
    UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug=r.cs AND slug=r.olds AND is_canonical;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', r.vid; END IF;
    IF r.slug_exists THEN
      UPDATE slugs SET is_canonical=true WHERE property_id='eats' AND venue_id=r.vid AND city_slug=r.cs AND slug=r.news AND NOT is_canonical;
      GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'existing slug %', r.vid; END IF;
    ELSE
      INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.news, r.vid, true);
    END IF;
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'name', 8, 'rename-apply:{K} | gated SQL file docs/{F} | 8 names follow own site and Michelin card, R1-R4: Le Manoir aux Quat''Saisons, La Palmeraie, La Chapelle, La Passagère, René et Maxime Meilleur, Les Explorateurs, La Côte d''Or, Restaurant Girardin');

  ---------------------------------------------------------------- WRITE 2 (4A): name_native
  UPDATE venues SET name_native='奈良町 枸杞' WHERE id='ve_c0eba7ae71' AND name_native IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'name_native %', n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10930 OR (SELECT count(*) FROM venues WHERE status='closed') <> 366 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(name_native) FROM venues) <> 339 THEN RAISE EXCEPTION 'name_native after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25081 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13013 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1717 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11296 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7729 THEN RAISE EXCEPTION 'listings/blurbs/price after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3263 OR (SELECT sum(venues_count) FROM cities) <> 10930 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 25 OR (SELECT count(*) FROM rename_rows) <> 1293 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 176 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical AND sl.property_id='eats' GROUP BY v.id HAVING count(sl.slug) <> 1) THEN RAISE EXCEPTION 'canonical slug count'; END IF;
  IF (SELECT status::text FROM venues WHERE id='ve_7b865a33b7') <> 'closed' THEN RAISE EXCEPTION 'Le Manoir status'; END IF;
  SELECT string_agg(v.name||' '||sl.city_slug||'/'||sl.slug, ', ' ORDER BY v.id COLLATE "C") INTO s FROM venues v JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical WHERE v.id = ANY (vren);
  IF s IS DISTINCT FROM 'La Côte d''Or saulieu/la-cote-d-or, Restaurant Girardin colmar/restaurant-girardin, La Chapelle montlucon/la-chapelle, Le Manoir aux Quat’Saisons oxford/le-manoir-aux-quat-saisons, René et Maxime Meilleur saint-martin-de-belleville/rene-et-maxime-meilleur, La Palmeraie la-croix-valmer/la-palmeraie, Les Explorateurs val-thorens/les-explorateurs, La Passagère juan-les-pins/la-passagere' THEN RAISE EXCEPTION 'names after: %', s; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'slugs:INSERT=5,slugs:UPDATE=11,venues:UPDATE=9' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND action='UPDATE' AND row_pk = ANY (vren) AND (old_row-'name'-'norm_key')=(new_row-'name'-'norm_key')) <> 8 THEN RAISE EXCEPTION 'rename audit'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk='ve_c0eba7ae71' AND (old_row-'name_native')=(new_row-'name_native') AND new_row->>'name_native'='奈良町 枸杞') <> 1 THEN RAISE EXCEPTION 'native audit'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()))
