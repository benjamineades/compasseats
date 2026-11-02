import hashlib
K='rename-fr-2026-list-3-2026-11-02'; F='fix-fr-2026-list-11-rows-3-names-2026-11-02.sql'
U='https://guide.michelin.com/fr/fr/article/michelin-guide-ceremony/la-liste-complete-des-etoiles-du-guide-michelin-france-2026'
A=[('ve_492797f355','Two Stars'),('ve_95253d6c9e','Two Stars'),('ve_72f235f057','One Star'),('ve_1fa87032fe','One Star'),('ve_ef978b8a59','One Star'),('ve_e1bffb1188','One Star'),('ve_b2c6b30c6e','One Star'),('ve_68ad93cad4','One Star'),('ve_63aed2ba90','One Star'),('ve_54915423d1','One Star'),('ve_3bb332e0ec','One Star')]
R=[(1,'ve_e1bffb1188','La Flibuste - Restaurant Gastronomique Villeneuve-Loubet','La Flibuste','venue','https://restaurantlaflibuste.fr/','villeneuve-loubet','la-flibuste-restaurant-gastronomique-villeneuve-loubet','la-flibuste','R1: own site writes La Flibuste; Michelin 2026 list La Flibuste, read Nov 2.'),
(2,'ve_68ad93cad4',"La Table de l''Alpaga - Restaurant Gastronomique à Megève","La Table de l''Alpaga",'michelin',U,'megeve','la-table-de-l-alpaga-restaurant-gastronomique-a-megeve','la-table-de-l-alpaga',"R5: own site not read, card gives 404; Michelin 2026 list La Table de l''Alpaga, read Nov 2."),
(3,'ve_95253d6c9e','Sarkara**','Le Sarkara','venue','https://www.lek2palace.com/en/taste/le-sarkara','courchevel','sarkara','le-sarkara','R1: own site writes Le Sarkara; Michelin 2026 list Le Sarkara, read Nov 2.')]
aids="ARRAY["+",".join("'%s'"%a[0] for a in A)+"]"
rids="ARRAY["+",".join("'%s'"%r[1] for r in R)+"]"
avals=",".join("('%s','%s')"%a for a in A)
rvals=",\n".join("    (%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s')"%r for r in R)
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 10:34 ET "3A". This file runs only after his "go".
-- 11 Michelin 2026 star rows for venues on the France 2026 list with no 2026 row. Source: the list article (relay docs/fr-2026-list-read/relay-fr-2026-article-2026-11-02.txt).
--   The cards of all 11 give a 404 (read Nov 2), so the article is the source. Status does not change in this file.
-- Rename batch {K}: La Flibuste, La Table de l''Alpaga, Le Sarkara. Old slugs stay as non-canonical rows.
-- Held: Jean Imbert au Plaza Athénée ve_36022e9b0a (probable twin of ve_ab17ada0da); Pierre and Maison Hache (no venue).
-- Expected after: venues 11,296 (active 10,930); awards 25,092; Michelin 2026 France star rows 666 by venue country FR/MC; slugs 13,016 (non-canonical 1,720);
--   rename_batches 26, rename_rows 1,296; ledger 178 rows; audit_log +20 (awards INSERT 11, venues UPDATE 3, slugs UPDATE 3, slugs INSERT 3).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; bid bigint; n bigint; s text; r record;
  vaw constant text[] := {aids};
  vren constant text[] := {rids};
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10930 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25081 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('One Star','Two Stars','Three Stars') AND c.country_iso IN ('FR','MC')) <> 655 THEN RAISE EXCEPTION 'FR 2026 stars before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13013 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1717 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 25 OR (SELECT count(*) FROM rename_rows) <> 1293 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 176 OR led_max <> 228 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118178 OR aud_max <> 123692 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (vaw);
  IF s IS DISTINCT FROM 'd09b41884deedad366497573be0781a7' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_id='michelin' AND year=2026 AND venue_id = ANY (vaw)) THEN RAISE EXCEPTION '2026 row exists'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='{K}') THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = ANY (vren)) THEN RAISE EXCEPTION 'earlier rename row'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id = ANY (vren)) THEN RAISE EXCEPTION 'blurb on a renamed venue'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE (city_slug,slug) IN (('villeneuve-loubet','la-flibuste'),('megeve','la-table-de-l-alpaga'),('courchevel','le-sarkara'))) THEN RAISE EXCEPTION 'new slug in use'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(la-flibuste|alpaga|sarkara)' OR to_path ~ '(la-flibuste|alpaga|sarkara)') THEN RAISE EXCEPTION 'redirect on a rename path'; END IF;

  ---------------------------------------------------------------- WRITE 1: 11 award rows
  INSERT INTO awards (venue_id, source_id, year, category, source_url)
  SELECT t.vid, 'michelin', 2026, t.cat, '{U}' FROM (VALUES {avals}) t(vid, cat);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 11 THEN RAISE EXCEPTION 'award insert %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 11, 'backfill:michelin-2026-france-list-11 | Ben Nov 2 10:34 ET "3A" | 11 venues on the France 2026 list with no 2026 row; all 11 cards give a 404; source is the list article | relay docs/fr-2026-list-read/relay-fr-2026-article-2026-11-02.txt');

  ---------------------------------------------------------------- WRITE 2: rename batch
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('{K}', 'staged', 'Open item 11, last 3 venues (Ben, Nov 2 10:34 ET "3A"): rules R1, R5. Promotion text removed.') RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  FOR r IN SELECT * FROM (VALUES
{rvals}
  ) t(line, vid, oldn, newn, src, url, cs, olds, news, ev) LOOP
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
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.news, r.vid, true);
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'name', 3, 'rename-apply:{K} | gated SQL file docs/{F} | La Flibuste, La Table de l''Alpaga, Le Sarkara');

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10930 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25092 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('One Star','Two Stars','Three Stars') AND c.country_iso IN ('FR','MC')) <> 666 THEN RAISE EXCEPTION 'FR 2026 stars after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13016 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1720 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11296 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10930 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 26 OR (SELECT count(*) FROM rename_rows) <> 1296 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 178 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical AND sl.property_id='eats' GROUP BY v.id HAVING count(sl.slug) <> 1) THEN RAISE EXCEPTION 'canonical slug count'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=11,slugs:INSERT=3,slugs:UPDATE=3,venues:UPDATE=3' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()))
