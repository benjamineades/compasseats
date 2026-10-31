-- cities-held-p2-michelin-city-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 5, file 2 of 2 (held-P2 city changes).
-- RUN IN THE SUPABASE SQL EDITOR (the file holds DELETE statements; the Write connector prompt closes by itself on those).
-- Run file 1 (cities-display-telese-terme-2026-10-31.sql) first: the audit gate expects its row (last id 119372).
--
-- Ben: Oct 31 00:21 ET "Go with your recommendations": D3 A (the Michelin city rule D7 = the city in the card URL, now also
--   outside Turkey; 3 new cities; delete the 3 empty cities; alias only for las caletas, a place inside Fuencaliente;
--   no alias for Prato or Sanluri, separate towns; venues_count kept equal to the view city_venue_counts).
-- Evidence: live Michelin cards read Oct 31 (WebFetch), address lines:
--   Paca "Via delle Ginestre 45, Carmignano, 59015, Italy" (2026 One Star);
--   Torre del Saracino "Piazza della Vittoria 5, Sorrento, 80067, Italy" (2026 Two Stars);
--   Coxinendi "Viale del Golfo di Quartu 25, Quartu sant'Elena, 09045, Italy" (2026 Bib Gourmand);
--   El Jardín de la Sal "Carretera La Costa-El Faro 5, Fuencaliente de la Palma, 38740, Spain" (2026 Bib Gourmand).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts 3 cities (id = 'ci_' || left(md5(slug), 10)); country, kind and region copied from the old city;
--      lat/lng NULL (as Fethiye); venues_count 1:
--      ci_6480e34f4d carmignano "Carmignano" (from Prato); ci_cef88d0e62 quartu-sant-elena "Quartu Sant'Elena" (from Sanluri);
--      ci_06496b916c fuencaliente-de-la-palma "Fuencaliente de la Palma" (from Las Caletas).
--   2. Moves 4 venues (venues.city_id only): Paca Ristorante Prato -> Carmignano; Torre del Saracino Vico Equense -> Sorrento;
--      Coxinendi - Ristorante Sanluri -> Quartu Sant'Elena; Restaurante Temático El Jardín de la Sal Las Caletas -> Fuencaliente de la Palma.
--   3. Slugs: each old canonical row becomes non-canonical (old URL keeps working); the new canonical row is
--      <target city slug>/<same slug> (= slug rule of the live name). Old non-canonical rows (prato/paca, sanluri/coxinendi) stay.
--   4. venues_count: Sorrento 5 -> 6, Vico Equense 2 -> 1 (Antica Osteria Nonna Rosa stays). Telese unchanged.
--   5. Deletes the 3 empty cities: Prato ci_c02c36007b, Sanluri ci_d59e7dd97f, Las Caletas ci_b52d606d20 (gate: 0 venues,
--      0 aliases). Region rows do not change.
--   6. Inserts 1 alias with a hand audit row: las caletas -> ci_06496b916c.
--   city_label_source rows are source labels and do not change. No redirect row. No ledger row.
--   Audit rows: cities 3 INSERT + 2 UPDATE (venues_count) + 3 DELETE, venues 4 UPDATE, slugs 4 UPDATE + 4 INSERT,
--   city_aliases 1 INSERT (hand) = 21 (ids 119,373-119,393).
-- Built by script (docs/open-items-b5-build/build_open_items_b5_2026_10_31.py) from relay.txt (sha256 f266ea0ed5133a5f4d95cfec70a94827fab8a130cda791cab5179a08f19742bb).
-- Dry run: send through the Read connector. It stops at the first INSERT with "read-only transaction".

BEGIN;
DO $hp$
DECLARE
  mv      constant jsonb := $j$[{"from_city": "ci_c02c36007b", "new_slug": "paca-ristorante", "old_city_slug": "prato", "old_slug": "paca-ristorante", "to_city": "ci_6480e34f4d", "to_city_slug": "carmignano", "venue_id": "ve_542c195114"}, {"from_city": "ci_84cafc2357", "new_slug": "torre-del-saracino", "old_city_slug": "vico-equense", "old_slug": "torre-del-saracino", "to_city": "ci_25a0f29d02", "to_city_slug": "sorrento", "venue_id": "ve_69e1e106b5"}, {"from_city": "ci_b52d606d20", "new_slug": "restaurante-tematico-el-jardin-de-la-sal", "old_city_slug": "las-caletas", "old_slug": "restaurante-tematico-el-jardin-de-la-sal", "to_city": "ci_06496b916c", "to_city_slug": "fuencaliente-de-la-palma", "venue_id": "ve_e50adc624d"}, {"from_city": "ci_d59e7dd97f", "new_slug": "coxinendi-ristorante", "old_city_slug": "sanluri", "old_slug": "coxinendi-ristorante", "to_city": "ci_cef88d0e62", "to_city_slug": "quartu-sant-elena", "venue_id": "ve_eef796a74d"}]$j$::jsonb;
  nc      constant jsonb := $j$[{"copy_from": "ci_c02c36007b", "display": "Carmignano", "id": "ci_6480e34f4d", "slug": "carmignano"}, {"copy_from": "ci_d59e7dd97f", "display": "Quartu Sant'Elena", "id": "ci_cef88d0e62", "slug": "quartu-sant-elena"}, {"copy_from": "ci_b52d606d20", "display": "Fuencaliente de la Palma", "id": "ci_06496b916c", "slug": "fuencaliente-de-la-palma"}]$j$::jsonb;
  cn      constant jsonb := $j$[{"id": "ci_25a0f29d02", "new": 6, "old": 5}, {"id": "ci_84cafc2357", "new": 1, "old": 2}]$j$::jsonb;
  dc      constant jsonb := $j$[{"id": "ci_c02c36007b", "slug": "prato"}, {"id": "ci_d59e7dd97f", "slug": "sanluri"}, {"id": "ci_b52d606d20", "slug": "las-caletas"}]$j$::jsonb;
  al      constant jsonb := $j$[{"alias": "las caletas", "city_id": "ci_06496b916c"}]$j$::jsonb;
  rs      constant jsonb := $j$[{"iso": "IT", "n": "carmignano", "want": "ci_6480e34f4d"}, {"iso": "IT", "n": "quartu sant elena", "want": "ci_cef88d0e62"}, {"iso": "ES", "n": "fuencaliente de la palma", "want": "ci_06496b916c"}, {"iso": "ES", "n": "las caletas", "want": "ci_06496b916c"}, {"iso": "IT", "n": "sorrento", "want": "ci_25a0f29d02"}, {"iso": "IT", "n": "vico equense", "want": "ci_84cafc2357"}, {"iso": "IT", "n": "prato", "want": "-"}, {"iso": "IT", "n": "sanluri", "want": "-"}]$j$::jsonb;
  x       bigint;
  x2      bigint;
  t       text;
  aud_max bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3259  THEN RAISE EXCEPTION 'cities before % (expected 3259)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 265   THEN RAISE EXCEPTION 'city_aliases before % (expected 265)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects before % (expected 9)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12936 THEN RAISE EXCEPTION 'slugs before % (expected 12936)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1633  THEN RAISE EXCEPTION 'non-canonical before % (expected 1633)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11303 THEN RAISE EXCEPTION 'venues before % (expected 11303)', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 23362 THEN RAISE EXCEPTION 'awards before % (expected 23362)', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11303 THEN RAISE EXCEPTION 'listings before % (expected 11303)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24003 THEN RAISE EXCEPTION 'city_label_source before % (expected 24003)', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;               IF x <> 10934 THEN RAISE EXCEPTION 'venues_count sum before % (expected 10934)', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'IT'; IF x <> 483 THEN RAISE EXCEPTION 'Italy cities before %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'ES'; IF x <> 286 THEN RAISE EXCEPTION 'Spain cities before %', x; END IF;
  SELECT max(id) INTO aud_max FROM audit_log;
  IF aud_max <> 119372 THEN RAISE EXCEPTION 'audit_log last id % (expected 119372; run file 1 first)', aud_max; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.id IN ('ci_c02c36007b', 'ci_84cafc2357', 'ci_d59e7dd97f', 'ci_b52d606d20', 'ci_25a0f29d02');
  IF t IS DISTINCT FROM '78a8625ec26770109a25b8cbe3d5b459' THEN RAISE EXCEPTION 'city rows changed since the read: %', t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id))
    INTO t FROM venues v WHERE v.id IN (SELECT m.venue_id FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text));
  IF t IS DISTINCT FROM '7a1055b5e3d0017299d8e384aaca6422' THEN RAISE EXCEPTION 'venue rows changed: %', t; END IF;
  SELECT md5(string_agg(s.venue_id||'|'||s.property_id||'|'||s.city_slug||'|'||s.slug||'|'||s.is_canonical, E'\n' ORDER BY s.venue_id, s.city_slug, s.slug))
    INTO t FROM slugs s WHERE s.venue_id IN (SELECT m.venue_id FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text));
  IF t IS DISTINCT FROM 'e855c7f979fe90c8ce6a83b9b111c9ac' THEN RAISE EXCEPTION 'slug rows changed: %', t; END IF;

  -- new cities: id rule, no clash by id, slug, display or alias
  SELECT count(*) INTO x FROM jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text) WHERE n.id <> 'ci_' || left(md5(n.slug), 10);
  IF x <> 0 THEN RAISE EXCEPTION 'new city id rule fails for %', x; END IF;
  SELECT count(*) INTO x FROM cities c, jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text)
   WHERE c.id = n.id OR c.slug = n.slug
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = btrim(regexp_replace(lower(f_unaccent(n.display)), '[^a-z0-9]+', ' ', 'g'));
  IF x <> 0 THEN RAISE EXCEPTION 'new cities clash with % cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a
   WHERE a.alias IN (SELECT btrim(regexp_replace(lower(f_unaccent(n.display)), '[^a-z0-9]+', ' ', 'g')) FROM jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text))
      OR a.alias IN (SELECT ax.alias FROM jsonb_to_recordset(al) ax(alias text, city_id text));
  IF x <> 0 THEN RAISE EXCEPTION 'aliases already present: %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text) JOIN cities c ON c.id = n.copy_from;
  IF x <> 3 THEN RAISE EXCEPTION 'copy-from cities present % (expected 3)', x; END IF;

  -- each move: active venue in the from city, exactly 1 canonical slug = the old slug, new slug = slug rule of the live name, free
  SELECT count(*) INTO x FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text)
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.from_city AND v.status = 'active'
    JOIN cities cf ON cf.id = m.from_city AND cf.slug = m.old_city_slug
   WHERE (EXISTS (SELECT 1 FROM cities ct WHERE ct.id = m.to_city AND ct.slug = m.to_city_slug)
          OR EXISTS (SELECT 1 FROM jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text) WHERE n.id = m.to_city AND n.slug = m.to_city_slug))
     AND m.new_slug = trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))
     AND (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) = 1
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
                    AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug)
     AND NOT EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug);
  IF x <> 4 THEN RAISE EXCEPTION 'move rows that pass the pre-check: % (expected 4)', x; END IF;

  -- each city to delete holds only venues that move, and no alias; no redirect uses its path
  SELECT count(*) INTO x FROM jsonb_to_recordset(dc) d(id text, slug text)
   WHERE EXISTS (SELECT 1 FROM cities c WHERE c.id = d.id AND c.slug = d.slug)
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = d.id AND v.id NOT IN (SELECT m.venue_id FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text)))
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = d.id);
  IF x <> 3 THEN RAISE EXCEPTION 'cities to delete that pass the pre-check: % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM redirects r, jsonb_to_recordset(dc) d(id text, slug text)
   WHERE r.from_path LIKE '/'||d.slug||'/%' OR r.to_path LIKE '/'||d.slug||'/%';
  IF x <> 0 THEN RAISE EXCEPTION 'city paths in redirects: %', x; END IF;

  -- venues_count plan: each old value = the live active count now (the POST gates check the new values against the view)
  SELECT count(*) INTO x FROM jsonb_to_recordset(cn) k(id text, old int, new int) JOIN cities c ON c.id = k.id AND c.venues_count = k.old
   WHERE k.old = (SELECT count(*) FROM venues v WHERE v.city_id = k.id AND v.status = 'active');
  IF x <> 2 THEN RAISE EXCEPTION 'venues_count old values that match % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM city_venue_counts w JOIN cities c ON c.id = w.city_id WHERE c.venues_count <> w.active_venues;
  IF x <> 0 THEN RAISE EXCEPTION 'cities that differ from the view before: %', x; END IF;

  ---------------------------------------------------------------- WRITE 1: new cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT n.id, n.slug, n.display, c.country, c.country_iso, c.kind, c.region_id, NULL, NULL, 1
    FROM jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text) JOIN cities c ON c.id = n.copy_from ORDER BY n.id;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'city inserts % (expected 3)', x; END IF;

  ---------------------------------------------------------------- WRITE 2: move the venues
  UPDATE venues v SET city_id = m.to_city FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text)
   WHERE v.id = m.venue_id AND v.city_id = m.from_city;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 4 THEN RAISE EXCEPTION 'venue moves % (expected 4)', x; END IF;

  ---------------------------------------------------------------- WRITE 3: slugs
  UPDATE slugs s SET is_canonical = false FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text)
   WHERE s.venue_id = m.venue_id AND s.property_id = 'eats' AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND s.is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 4 THEN RAISE EXCEPTION 'old canonical slug updates % (expected 4)', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', m.to_city_slug, m.new_slug, m.venue_id, true FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text) ORDER BY m.venue_id;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 4 THEN RAISE EXCEPTION 'new canonical slug inserts % (expected 4)', x; END IF;

  ---------------------------------------------------------------- WRITE 4: venues_count of the existing cities
  UPDATE cities c SET venues_count = k.new FROM jsonb_to_recordset(cn) k(id text, old int, new int)
   WHERE c.id = k.id AND c.venues_count = k.old;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 2 THEN RAISE EXCEPTION 'venues_count updates % (expected 2)', x; END IF;

  ---------------------------------------------------------------- WRITE 5: delete the empty cities
  DELETE FROM cities c USING jsonb_to_recordset(dc) d(id text, slug text)
   WHERE c.id = d.id AND c.slug = d.slug
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = c.id)
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = c.id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'city deletes % (expected 3)', x; END IF;

  ---------------------------------------------------------------- WRITE 6: alias, with a hand audit row
  INSERT INTO city_aliases (alias, city_id) SELECT ax.alias, ax.city_id FROM jsonb_to_recordset(al) ax(alias text, city_id text);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'alias inserts % (expected 1)', x; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a) FROM city_aliases a
   WHERE a.alias IN (SELECT ax.alias FROM jsonb_to_recordset(al) ax(alias text, city_id text)) ORDER BY a.alias;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'alias hand audit rows % (expected 1)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3259  THEN RAISE EXCEPTION 'cities after % (expected 3259)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 266   THEN RAISE EXCEPTION 'city_aliases after % (expected 266)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12940 THEN RAISE EXCEPTION 'slugs after % (expected 12940)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1637  THEN RAISE EXCEPTION 'non-canonical after % (expected 1637)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;      IF x <> 11303 THEN RAISE EXCEPTION 'canonical after % (expected 11303)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11303 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 23362 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11303 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24003 THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'IT'; IF x <> 483 THEN RAISE EXCEPTION 'Italy cities after %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'ES'; IF x <> 286 THEN RAISE EXCEPTION 'Spain cities after %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;               IF x <> 10934 THEN RAISE EXCEPTION 'venues_count sum after % (expected 10934)', x; END IF;
  SELECT count(*) INTO x FROM city_venue_counts w JOIN cities c ON c.id = w.city_id WHERE c.venues_count <> w.active_venues;
  IF x <> 0 THEN RAISE EXCEPTION 'cities that differ from the view after: %', x; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.venues_count, E'\n' ORDER BY c.id)) INTO t
    FROM cities c WHERE c.id IN (SELECT n.id FROM jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text));
  IF t IS DISTINCT FROM 'fc3671e0a086f029e549dfc67025fc56' THEN RAISE EXCEPTION 'new city rows after %', t; END IF;
  SELECT md5(string_agg(c.id||'|'||c.venues_count, E'\n' ORDER BY c.id)) INTO t FROM cities c WHERE c.id IN (SELECT k.id FROM jsonb_to_recordset(cn) k(id text, old int, new int));
  IF t IS DISTINCT FROM '9659ce7d87e57139120a768dd3fae25d' THEN RAISE EXCEPTION 'venues_count after %', t; END IF;
  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text)
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.to_city
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND NOT s.is_canonical);
  IF x <> 4 THEN RAISE EXCEPTION 'moved venues as planned after: % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM cities c JOIN jsonb_to_recordset(dc) d(id text, slug text) ON c.id = d.id;
  IF x <> 0 THEN RAISE EXCEPTION 'deleted cities still present: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 21 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 21)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text) ON a.row_pk = n.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'INSERT' AND a.old_row IS NULL;
  IF x <> 3 THEN RAISE EXCEPTION 'audit city inserts % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(cn) k(id text, old int, new int) ON a.row_pk = k.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'UPDATE'
     AND (a.old_row->>'venues_count')::int = k.old AND (a.new_row->>'venues_count')::int = k.new
     AND (a.old_row - 'venues_count') = (a.new_row - 'venues_count');
  IF x <> 2 THEN RAISE EXCEPTION 'audit venues_count updates % (expected 2, venues_count only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(dc) d(id text, slug text) ON a.row_pk = d.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'DELETE' AND a.new_row IS NULL AND a.old_row->>'slug' = d.slug;
  IF x <> 3 THEN RAISE EXCEPTION 'audit city deletes % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text) ON a.row_pk = m.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE'
     AND (a.old_row - 'city_id') = (a.new_row - 'city_id') AND a.old_row->>'city_id' = m.from_city AND a.new_row->>'city_id' = m.to_city;
  IF x <> 4 THEN RAISE EXCEPTION 'audit venue updates % (expected 4, city_id only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a WHERE a.id > aud_max AND a.table_name = 'slugs'
     AND a.row_pk IN (SELECT m.venue_id FROM jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text));
  IF x <> 8 THEN RAISE EXCEPTION 'audit slug rows % (expected 8)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(al) ax(alias text, city_id text) ON a.row_pk = ax.alias
   WHERE a.id > aud_max AND a.table_name = 'city_aliases' AND a.action = 'INSERT' AND a.old_row IS NULL AND a.new_row->>'city_id' = ax.city_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit alias insert % (expected 1)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter): each label gives exactly the expected city;
  -- the labels Prato and Sanluri give no city (separate towns, no alias).
  WITH lab AS (SELECT * FROM jsonb_to_recordset(rs) r(n text, iso text, want text)),
  cand AS (
    SELECT h.n, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n
    UNION
    SELECT h.n, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n
    UNION
    SELECT h.n, a.city_id FROM lab h JOIN city_aliases a ON a.alias = h.n),
  hit AS (
    SELECT h.n, h.want, count(ci.id) k, min(ci.id) got
      FROM lab h LEFT JOIN cand c ON c.n = h.n LEFT JOIN cities ci ON ci.id = c.id AND ci.country_iso = h.iso
     GROUP BY h.n, h.want)
  SELECT count(*) FILTER (WHERE (want = '-' AND k = 0) OR (want <> '-' AND k = 1 AND got = want)), count(*)
    INTO x, x2 FROM hit;
  IF x <> 8 OR x2 <> 8 THEN RAISE EXCEPTION 'label resolution: % of % labels as planned', x, x2; END IF;

  RAISE NOTICE 'OK: 3 cities inserted, 4 venues moved, 8 slug rows, 2 venues_count, 3 cities deleted, 1 alias, 21 audit rows after id %', aud_max;
END
$hp$;
COMMIT;
