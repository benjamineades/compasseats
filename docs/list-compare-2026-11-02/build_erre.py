import hashlib
F='add-es-2026-erre-de-roca-2026-11-02.sql'
U='https://guide.michelin.com/es/es/articulo/michelin-guide-ceremony/todos-los-restaurantes-con-estrellas-michelin-en-espana-2026'
V='ve_'+hashlib.md5(b'condado-de-trevino:erre-de-roca').hexdigest()[:10]
C='ci_'+hashlib.md5(b'condado-de-trevino').hexdigest()[:10]
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 12:34 ET "1A, 2A". This file runs only after his "go".
-- New active venue Erre de Roca {V} in new city Condado de Treviño {C}, with Michelin 2026 One Star. Source: the Spain list article (line "Miranda de Ebro – Erre de Roca").
-- The restaurant moved from Miranda de Ebro to Ventas de Armentia, Condado de Treviño: Gasteiz Hoy Jan 13 2026; own site errederoca.com (read Nov 2) shows that address and takes bookings.
-- No Michelin card found, so the Michelin city rule cannot apply. City label keeps what Michelin printed (Miranda de Ebro). No price row, no card price.
-- 1A: Pierre, Maison Hache, NM, Bens d'Avall, SCAPAR: closed, no venue made.
-- Expected after: venues 11,296 (active 10,917, closed 379); awards 25,097; Spain + Andorra Michelin 2026 star rows 304; slugs 13,017; listings 11,296; city labels 23,993;
--   cities 3,264, sum 10,917; ledger 182 rows, last id 234; audit_log +7 (cities, venues, listings, slugs, awards INSERT 1 each, city_label_source INSERT 2 by hand).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text;
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11295 OR (SELECT count(*) FROM venues WHERE status='active') <> 10916 OR (SELECT count(*) FROM venues WHERE status='closed') <> 379 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25096 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('One Star','Two Stars','Three Stars') AND c.country_iso IN ('ES','AD')) <> 303 THEN RAISE EXCEPTION 'Spain rows before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13016 OR (SELECT count(*) FROM listings) <> 11295 OR (SELECT count(*) FROM city_label_source) <> 23991 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3263 OR (SELECT sum(venues_count) FROM cities) <> 10916 THEN RAISE EXCEPTION 'cities before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 180 OR led_max <> 232 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118235 OR aud_max <> 123749 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF '{V}' <> 've_'||left(md5('condado-de-trevino:erre-de-roca'),10) THEN RAISE EXCEPTION 'venue id rule'; END IF;
  IF '{C}' <> 'ci_'||left(md5('condado-de-trevino'),10) THEN RAISE EXCEPTION 'city id rule'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('Condado de Treviño')),'[^a-z0-9]+','-','g')) <> 'condado-de-trevino' THEN RAISE EXCEPTION 'city slug rule'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent('Erre de Roca')),'[^a-z0-9]+','-','g')) <> 'erre-de-roca' THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF EXISTS (SELECT 1 FROM cities WHERE id='{C}' OR slug='condado-de-trevino') THEN RAISE EXCEPTION 'city clash'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id='{V}' OR norm_key='errederoca') THEN RAISE EXCEPTION 'venue clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE slug='erre-de-roca') THEN RAISE EXCEPTION 'slug clash'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path LIKE '%erre-de-roca%' OR to_path LIKE '%erre-de-roca%') THEN RAISE EXCEPTION 'redirect clash'; END IF;
  -- WRITE
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES ('{C}', 'condado-de-trevino', 'Condado de Treviño', 'Spain', 'ES', 'city', NULL, NULL, NULL, 1);
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('{V}', 'Erre de Roca', 'restaurant', '{C}', 'active');
  INSERT INTO listings (venue_id, property_id, published) VALUES ('{V}', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'condado-de-trevino', 'erre-de-roca', '{V}', true);
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      ('{V}', 'Miranda de Ebro', 'city_display', 'michelin', 'michelin-2026-spain list article; moved to Condado de Treviño'),
      ('{V}', 'Spain', 'country', 'michelin', 'michelin-2026-spain list article')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  INSERT INTO awards (venue_id, source_id, year, category, source_url) VALUES ('{V}', 'michelin', 2026, 'One Star', '{U}');
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin', 'award', 1, 'backfill:michelin-2026-spain-erre-de-roca | Ben Nov 2 12:34 ET "2A" | source: list article, moved venue, no card found'),
    ('michelin', 'city_label', 2, 'backfill:michelin-2026-spain-erre-de-roca | city labels');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10917 OR (SELECT count(*) FROM venues WHERE status='closed') <> 379 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT norm_key FROM venues WHERE id='{V}') IS DISTINCT FROM 'errederoca' THEN RAISE EXCEPTION 'norm key'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('One Star','Two Stars','Three Stars') AND c.country_iso IN ('ES','AD')) <> 304 THEN RAISE EXCEPTION 'Spain rows after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13017 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11296 OR (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM city_label_source) <> 23993 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3264 OR (SELECT sum(venues_count) FROM cities) <> 10917 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 182 OR led_max <> 234 THEN RAISE EXCEPTION 'ledger after % / %', n, led_max; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=1,cities:INSERT=1,city_label_source:INSERT=2,listings:INSERT=1,slugs:INSERT=1,venues:INSERT=1' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()),V,C)
