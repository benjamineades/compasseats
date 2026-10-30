-- cities-telluride-fix-2026-10-30.sql
-- CompassEats, Oct 30 2026. Open items block 1, item 1: the city spelling "Telleruide".
--
-- Problem: city ci_b8de1219b5 "Telleruide" (slug telleruide, region rocky-mountains) holds 1 venue, 221 South Oak
--   ve_b44e9a2762 (OAD 2026 No. 606, no URL). The OAD load wrote the town as "Telleruide". The venue slug is
--   telleruide/telleruide-kzwzua. No "Telluride" city or alias exists.
-- Evidence: the venue site (https://www.221southoak.com/, read Oct 30) gives "221 South Oak Street, Telluride,
--   Colorado" and the title "221 South Oak | Telluride Restaurant". The site says "Closed For Offseason, We Reopen
--   12/11": a seasonal closure, so the status stays active.
-- Ben: Oct 30 19:46 ET "Go" (items 1-4), 19:50 ET "All recommended" (item 1 = A: change the city to Telluride,
--   name and slug; the venue gets the slug telluride/221-south-oak; the old URL keeps working).
-- Template: docs/cities-jackson-wy-split.sql (new city, venue move, old slug non-canonical).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts city ci_0e83eaf4c6 (= 'ci_' || left(md5('telluride'), 10)), slug telluride, display "Telluride",
--      United States / US, kind city, region rocky-mountains (rg_50e244d435), lat/lng NULL (as the old row),
--      venues_count 1 (as the old row; the venue is active).
--   2. Moves ve_b44e9a2762 to the new city (venues.city_id). Name, status and awards do not change.
--   3. Slugs: the old canonical row telleruide/telleruide-kzwzua becomes non-canonical (old URL stays and points to the
--      same venue), and telluride/221-south-oak is inserted as canonical (slug rule on the venue name). No row is deleted.
--   4. Deletes the empty city row ci_b8de1219b5 (0 venues and 0 aliases after step 2). trg_audit_cities writes the
--      DELETE audit row with the full old row.
--   5. Inserts the alias 'telleruide' -> ci_0e83eaf4c6, so a later OAD load that prints "Telleruide" resolves to
--      Telluride. city_aliases has no audit trigger, so the file writes 1 hand audit row (row_pk = alias, as the
--      Oct 11 and Oct 27 alias inserts).
--   city_label_source rows (OAD "Telleruide", "United States") are source labels and do not change.
--   No redirect row (the old venue path stays in slugs as non-canonical, as in the Jackson move).
--   No ledger row (a city, a city_id, an alias and a slug have no publisher).
--   Audit rows: cities 1 INSERT + 1 DELETE, venues 1 UPDATE, slugs 1 UPDATE + 1 INSERT, city_aliases 1 INSERT (hand) = 6.
--
-- Gates (PRE): table counts; old city fingerprint 90e1228e40bf218ea81a2f1105600f67 (md5 of id|slug|display|country|country_iso|kind|region|
--              lat|lng|venues_count); venue fingerprint 4163b6760750b4aba8f65f15ffd42893 (md5 of id|name|status|city_id|norm_key); the venue
--              is the only venue in the old city, with exactly 1 slug row; the new id, slug and display clash with no
--              city or alias; no slug row under telluride; no redirect on either city path.
-- Gates (POST): counts; the venue is in the new city with exactly 1 canonical slug; the old slug is non-canonical;
--               the old city row is gone; 6 audit rows of the right table, action and row_pk; the venues audit row
--               changes only city_id; stage-job resolution of the labels "Telleruide" and "Telluride" (United States)
--               gives exactly ci_0e83eaf4c6.
-- Run order: after docs/rename-open-items-b1-2026-10-30.sql and docs/slugs-rename-open-items-b1-2026-10-30.sql
-- (the audit gate expects their rows: audit_log 113697 rows, last id 118981).
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $tel$
DECLARE
  c_new_id     constant text := 'ci_0e83eaf4c6';
  c_new_slug   constant text := 'telluride';
  c_new_disp   constant text := 'Telluride';
  c_old_id     constant text := 'ci_b8de1219b5';
  c_rocky      constant text := 'rg_50e244d435';
  c_venue      constant text := 've_b44e9a2762';
  c_vslug      constant text := '221-south-oak';
  c_old_vslug  constant text := 'telleruide-kzwzua';
  c_alias      constant text := 'telleruide';
  x        int;
  x2       int;
  t        text;
  t2       text;
  aud_max  bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3263  THEN RAISE EXCEPTION 'cities before % (expected 3263)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 261   THEN RAISE EXCEPTION 'city_aliases before % (expected 261)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects before % (expected 9)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12914 THEN RAISE EXCEPTION 'slugs before % (expected 12914)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1610  THEN RAISE EXCEPTION 'non-canonical before % (expected 1610)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 23353 THEN RAISE EXCEPTION 'awards before % (expected 23353)', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24005 THEN RAISE EXCEPTION 'city_label_source before % (expected 24005)', x; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;
  IF x <> 113697 THEN RAISE EXCEPTION 'audit_log before % (expected 113697; run the rename and slug files first)', x; END IF;
  IF aud_max <> 118981 THEN RAISE EXCEPTION 'audit_log last id % (expected 118981)', aud_max; END IF;

  IF c_new_id <> 'ci_' || left(md5(c_new_slug), 10) THEN RAISE EXCEPTION 'new city id rule'; END IF;

  SELECT md5(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count)
    INTO t FROM cities c WHERE c.id = c_old_id;
  IF t IS DISTINCT FROM '90e1228e40bf218ea81a2f1105600f67' THEN RAISE EXCEPTION 'old city row changed: %', t; END IF;
  SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key) INTO t FROM venues v WHERE v.id = c_venue;
  IF t IS DISTINCT FROM '4163b6760750b4aba8f65f15ffd42893' THEN RAISE EXCEPTION 'venue row changed: %', t; END IF;

  SELECT count(*) INTO x FROM venues WHERE city_id = c_old_id;
  IF x <> 1 THEN RAISE EXCEPTION 'venues in the old city % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases WHERE city_id = c_old_id;
  IF x <> 0 THEN RAISE EXCEPTION 'aliases on the old city % (expected 0)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue;
  IF x <> 1 THEN RAISE EXCEPTION 'slug rows on the venue % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue AND property_id = 'eats' AND city_slug = 'telleruide' AND slug = c_old_vslug AND is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'canonical /telleruide/% not found', c_old_vslug; END IF;
  IF c_vslug <> (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) FROM venues v WHERE v.id = c_venue) THEN
    RAISE EXCEPTION 'new venue slug is not the slug rule of the live name'; END IF;

  SELECT count(*) INTO x FROM regions WHERE id = c_rocky AND slug = 'rocky-mountains';
  IF x <> 1 THEN RAISE EXCEPTION 'region rocky-mountains not found'; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = c_rocky;
  IF x <> 6 THEN RAISE EXCEPTION 'rocky-mountains cities before % (expected 6)', x; END IF;

  SELECT count(*) INTO x FROM cities c
   WHERE c.id = c_new_id OR c.slug = c_new_slug
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = 'telluride'
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g'))    = 'telluride';
  IF x <> 0 THEN RAISE EXCEPTION 'new city clashes with % existing cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases WHERE alias IN ('telluride', c_alias);
  IF x <> 0 THEN RAISE EXCEPTION 'new city or alias clashes with % aliases', x; END IF;

  SELECT count(*) INTO x FROM slugs WHERE city_slug = c_new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'slug rows already under % : %', c_new_slug, x; END IF;
  SELECT count(*) INTO x FROM redirects
   WHERE from_path LIKE '/'||c_new_slug||'/%' OR from_path LIKE '/telleruide/%' OR to_path LIKE '/telleruide/%'
      OR from_path LIKE '/venue/'||c_new_slug||'/%' OR from_path LIKE '/venue/telleruide/%';
  IF x <> 0 THEN RAISE EXCEPTION 'city paths already in redirects: %', x; END IF;

  ---------------------------------------------------------------- WRITE 1: the new city
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT c_new_id, c_new_slug, c_new_disp, c.country, c.country_iso, c.kind, c.region_id, c.lat, c.lng, c.venues_count
    FROM cities c WHERE c.id = c_old_id;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'city insert % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 2: move the venue
  UPDATE venues SET city_id = c_new_id WHERE id = c_venue AND city_id = c_old_id;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'venue move % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 3: slugs
  UPDATE slugs SET is_canonical = false
   WHERE venue_id = c_venue AND property_id = 'eats' AND city_slug = 'telleruide' AND slug = c_old_vslug AND is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'old canonical slug update % (expected 1)', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  VALUES ('eats', c_new_slug, c_vslug, c_venue, true);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'new canonical slug insert % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 4: delete the empty old city
  DELETE FROM cities c WHERE c.id = c_old_id AND c.slug = 'telleruide'
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = c.id)
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = c.id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'old city delete % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 5: alias for the old spelling, with hand audit row
  INSERT INTO city_aliases (alias, city_id) VALUES (c_alias, c_new_id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'alias insert % (expected 1)', x; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a) FROM city_aliases a WHERE a.alias = c_alias;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'alias hand audit row % (expected 1)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3263  THEN RAISE EXCEPTION 'cities after % (expected 3263)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 262   THEN RAISE EXCEPTION 'city_aliases after % (expected 262)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12915 THEN RAISE EXCEPTION 'slugs after % (expected 12915)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1611  THEN RAISE EXCEPTION 'non-canonical after % (expected 1611)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;      IF x <> 11304 THEN RAISE EXCEPTION 'canonical after % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11304 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 23353 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11304 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24005 THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM venues WHERE id = c_venue AND city_id = c_new_id AND status = 'active' AND name = '221 South Oak';
  IF x <> 1 THEN RAISE EXCEPTION 'venue not in the new city'; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue AND city_slug = c_new_slug AND slug = c_vslug AND is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'new canonical slug missing'; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue AND city_slug = 'telleruide' AND slug = c_old_vslug AND NOT is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'old slug is not non-canonical'; END IF;
  SELECT count(*) INTO x FROM cities WHERE id = c_old_id OR slug = 'telleruide';
  IF x <> 0 THEN RAISE EXCEPTION 'old city row still present'; END IF;
  SELECT count(*) INTO x FROM cities WHERE id = c_new_id AND region_id = c_rocky AND slug = c_new_slug AND display = c_new_disp
     AND country = 'United States' AND country_iso = 'US' AND kind = 'city' AND venues_count = 1;
  IF x <> 1 THEN RAISE EXCEPTION 'new city row not as planned'; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = c_rocky;
  IF x <> 6 THEN RAISE EXCEPTION 'rocky-mountains cities after % (expected 6)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 6 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 6)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'cities' AND action = 'INSERT' AND row_pk = c_new_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit city insert %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'cities' AND action = 'DELETE' AND row_pk = c_old_id
     AND new_row IS NULL AND old_row->>'slug' = 'telleruide' AND (old_row - 'id' - 'slug' - 'display') = (
       SELECT to_jsonb(c) - 'id' - 'slug' - 'display' FROM cities c WHERE c.id = c_new_id);
  IF x <> 1 THEN RAISE EXCEPTION 'audit city delete % (expected 1, same row as the new city except id, slug, display)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = c_venue
     AND (old_row - 'city_id') = (new_row - 'city_id') AND old_row->>'city_id' = c_old_id AND new_row->>'city_id' = c_new_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit venue update % (expected 1, city_id only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND row_pk = c_venue;
  IF x <> 2 THEN RAISE EXCEPTION 'audit slug rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'city_aliases' AND action = 'INSERT' AND row_pk = c_alias
     AND old_row IS NULL AND new_row->>'city_id' = c_new_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit alias insert %', x; END IF;

  -- Stage-job city resolution (resolve.ts: slug, display, alias; then the country filter): the labels "Telleruide"
  -- and "Telluride" with country "United States" must each give exactly the new city.
  WITH lab AS (SELECT * FROM (VALUES ('telleruide'), ('telluride')) v(n_full)),
  cand AS (
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, a.city_id FROM lab h JOIN city_aliases a ON a.alias = h.n_full)
  SELECT count(*), count(DISTINCT c.n_full), min(ci.id), max(ci.id) INTO x, x2, t, t2
    FROM cand c JOIN cities ci ON ci.id = c.id
   WHERE lower(ci.country_iso) = 'us';
  IF x <> 2 OR x2 <> 2 OR t IS DISTINCT FROM c_new_id OR t2 IS DISTINCT FROM c_new_id THEN
    RAISE EXCEPTION 'labels Telleruide / Telluride (US) resolve to % rows, % labels, % .. %', x, x2, t, t2; END IF;

  RAISE NOTICE 'OK: city % inserted, venue moved, 2 slug rows, old city deleted, alias added, 6 audit rows', c_new_id;
END
$tel$;
COMMIT;
