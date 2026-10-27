-- cities-jackson-wy-split.sql
-- CompassEats, Oct 27 2026. Open item 4 (handoff-american-south-promoted-2026-10-27): Jackson city split.
--
-- Problem: city ci_b41779690b "Jackson" (slug jackson, region rocky-mountains) holds 3 Mississippi venues
--   (Bully's Soul Food Restaurant, Elvie's, Sacred Ground Barbecue) and 1 Wyoming venue, The Grill at Amangani
--   ve_8d69af215c (closed; OAD 2025 No. 243 and OAD 2026 No. 259). The Wyoming venue is the cause of the region.
--   City ci_e8c132c240 "Winter Park" holds 3 Florida venues (Omo by Jont, Soseki Omakase, The Ravenous Pig) and
--   also carries region rocky-mountains.
-- Evidence: OAD North America 2026 list (read Oct 27 in the built-in browser) prints No. 259 "Amangani Grill",
--   city "Jackson, Wyoming".
-- Ben Q4 A (Oct 27): new city "Jackson, Wyoming", slug jackson-wy (pattern of "Birmingham, Alabama" / birmingham-al).
-- Ben Q5 A (Oct 27): remove the region from Jackson and Winter Park (other Southern and Florida cities have none).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts city ci_c700a26ce3 (= 'ci_' || left(md5('jackson-wy'), 10)), slug jackson-wy, display
--      "Jackson, Wyoming", United States / US, kind city, region rocky-mountains (rg_50e244d435), lat/lng NULL,
--      venues_count 0 (the only venue is closed; Jackson's venues_count 3 also counts only active venues).
--   2. Moves ve_8d69af215c to the new city (venues.city_id). Name, status and awards do not change.
--   3. Slugs: the old canonical row /jackson/the-grill-at-amangani becomes non-canonical (old URL stays and points
--      to the same venue), and /jackson-wy/the-grill-at-amangani is inserted as canonical. No row is deleted.
--   4. Sets region_id NULL on ci_b41779690b (Jackson) and ci_e8c132c240 (Winter Park).
--   city_label_source rows (OAD "Jackson", "United States") are source labels and do not change.
--   No ledger row (a city, a city_id and a slug have no publisher). Triggers write the audit rows:
--   cities 1 INSERT + 2 UPDATE, venues 1 UPDATE, slugs 1 UPDATE + 1 INSERT = 6 rows.
--
-- Gates (PRE): table counts; city and venue fingerprints; the venue is closed, in Jackson, with 1 canonical slug
--              and no other slug row; the new id, slug and display do not clash with any city or alias; the new
--              path is not in use and not in redirects; region rg_50e244d435 is rocky-mountains with 7 cities.
-- Gates (POST): counts; the venue is in the new city with exactly 1 canonical slug; the old slug is non-canonical;
--               Jackson holds exactly the 3 Mississippi venues; regions; the venues audit row changes only city_id;
--               6 audit rows; stage-job resolution of the label "Jackson" (United States) still gives only
--               ci_b41779690b.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $jwy$
DECLARE
  c_new_id     constant text := 'ci_c700a26ce3';
  c_new_slug   constant text := 'jackson-wy';
  c_new_disp   constant text := 'Jackson, Wyoming';
  c_jackson    constant text := 'ci_b41779690b';
  c_wpark      constant text := 'ci_e8c132c240';
  c_rocky      constant text := 'rg_50e244d435';
  c_venue      constant text := 've_8d69af215c';
  c_vslug      constant text := 'the-grill-at-amangani';
  x        int;
  t        text;
  aud_max  bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3262  THEN RAISE EXCEPTION 'cities before % (expected 3262)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 261   THEN RAISE EXCEPTION 'city_aliases before % (expected 261)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12841 THEN RAISE EXCEPTION 'slugs before % (expected 12841)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1534  THEN RAISE EXCEPTION 'non-canonical before % (expected 1534)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11307 THEN RAISE EXCEPTION 'venues before % (expected 11307)', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 22922 THEN RAISE EXCEPTION 'awards before % (expected 22922)', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11307 THEN RAISE EXCEPTION 'listings before % (expected 11307)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24011 THEN RAISE EXCEPTION 'city_label_source before % (expected 24011)', x; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;
  IF x <> 107672 THEN RAISE EXCEPTION 'audit_log before % (expected 107672)', x; END IF;
  IF aud_max <> 112956 THEN RAISE EXCEPTION 'audit_log last id % (expected 112956)', aud_max; END IF;

  IF c_new_id <> 'ci_' || left(md5(c_new_slug), 10) THEN RAISE EXCEPTION 'new city id rule'; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.id IN (c_jackson, c_wpark);
  IF t IS DISTINCT FROM '1d87d4b065b811ce90e3bfa742574795' THEN RAISE EXCEPTION 'Jackson / Winter Park city rows changed: %', t; END IF;

  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status, E'\n' ORDER BY v.id)), count(*) INTO t, x FROM venues v WHERE v.city_id = c_jackson;
  IF x <> 4 OR t IS DISTINCT FROM '768afe4f3ca9d7936ff04cec49f01aa2' THEN RAISE EXCEPTION 'Jackson venues % / % changed', x, t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status, E'\n' ORDER BY v.id)), count(*) INTO t, x FROM venues v WHERE v.city_id = c_wpark;
  IF x <> 3 OR t IS DISTINCT FROM '1378d472570657082d4269b2351784ff' THEN RAISE EXCEPTION 'Winter Park venues % / % changed', x, t; END IF;

  SELECT count(*) INTO x FROM venues WHERE id = c_venue AND city_id = c_jackson AND status = 'closed' AND name = 'The Grill at Amangani';
  IF x <> 1 THEN RAISE EXCEPTION 'venue % not as read (closed, in Jackson)', c_venue; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue;
  IF x <> 1 THEN RAISE EXCEPTION 'slug rows on the venue % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue AND property_id = 'eats' AND city_slug = 'jackson' AND slug = c_vslug AND is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'canonical /jackson/% not found', c_vslug; END IF;

  SELECT count(*) INTO x FROM regions WHERE id = c_rocky AND slug = 'rocky-mountains';
  IF x <> 1 THEN RAISE EXCEPTION 'region rocky-mountains not found'; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = c_rocky;
  IF x <> 7 THEN RAISE EXCEPTION 'rocky-mountains cities before % (expected 7)', x; END IF;

  SELECT count(*) INTO x FROM cities c
   WHERE c.id = c_new_id OR c.slug = c_new_slug
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN ('jackson wyoming', 'jackson wy')
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g'))    IN ('jackson wyoming', 'jackson wy');
  IF x <> 0 THEN RAISE EXCEPTION 'new city clashes with % existing cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases WHERE alias IN ('jackson wyoming', 'jackson wy');
  IF x <> 0 THEN RAISE EXCEPTION 'new city clashes with % aliases', x; END IF;

  SELECT count(*) INTO x FROM slugs WHERE city_slug = c_new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'slug rows already under % : %', c_new_slug, x; END IF;
  SELECT count(*) INTO x FROM redirects
   WHERE from_path IN ('/'||c_new_slug||'/'||c_vslug, '/venue/'||c_new_slug||'/'||c_vslug) OR from_path LIKE '/'||c_new_slug||'/%';
  IF x <> 0 THEN RAISE EXCEPTION 'new paths already in redirects: %', x; END IF;

  ---------------------------------------------------------------- WRITE 1: the new city
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  VALUES (c_new_id, c_new_slug, c_new_disp, 'United States', 'US', 'city', c_rocky, NULL, NULL, 0);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'city insert % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 2: move the venue
  UPDATE venues SET city_id = c_new_id WHERE id = c_venue AND city_id = c_jackson;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'venue move % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 3: slugs
  UPDATE slugs SET is_canonical = false
   WHERE venue_id = c_venue AND property_id = 'eats' AND city_slug = 'jackson' AND slug = c_vslug AND is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'old canonical slug update % (expected 1)', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  VALUES ('eats', c_new_slug, c_vslug, c_venue, true);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'new canonical slug insert % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 4: regions
  UPDATE cities SET region_id = NULL WHERE id IN (c_jackson, c_wpark) AND region_id = c_rocky;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 2 THEN RAISE EXCEPTION 'region updates % (expected 2)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3263  THEN RAISE EXCEPTION 'cities after % (expected 3263)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 261   THEN RAISE EXCEPTION 'city_aliases changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12842 THEN RAISE EXCEPTION 'slugs after % (expected 12842)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1535  THEN RAISE EXCEPTION 'non-canonical after % (expected 1535)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;      IF x <> 11307 THEN RAISE EXCEPTION 'canonical after % (expected 11307)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11307 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 22922 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11307 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24011 THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM venues WHERE id = c_venue AND city_id = c_new_id AND status = 'closed' AND name = 'The Grill at Amangani';
  IF x <> 1 THEN RAISE EXCEPTION 'venue not in the new city'; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue AND city_slug = c_new_slug AND slug = c_vslug AND is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'new canonical slug missing'; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id = c_venue AND city_slug = 'jackson' AND slug = c_vslug AND NOT is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'old slug is not non-canonical'; END IF;

  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status, E'\n' ORDER BY v.id)), count(*) INTO t, x FROM venues v WHERE v.city_id = c_jackson;
  IF x <> 3 OR t IS DISTINCT FROM 'cc73c5e1503f4b3e27a4ceb59113637f' THEN RAISE EXCEPTION 'Jackson after: % venues, %', x, t; END IF;
  SELECT count(*) INTO x FROM venues WHERE city_id = c_wpark;
  IF x <> 3 THEN RAISE EXCEPTION 'Winter Park venues changed: %', x; END IF;

  SELECT count(*) INTO x FROM cities WHERE id IN (c_jackson, c_wpark) AND region_id IS NULL;
  IF x <> 2 THEN RAISE EXCEPTION 'regions not removed: % of 2', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE id = c_new_id AND region_id = c_rocky AND slug = c_new_slug AND display = c_new_disp;
  IF x <> 1 THEN RAISE EXCEPTION 'new city row not as planned'; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = c_rocky;
  IF x <> 6 THEN RAISE EXCEPTION 'rocky-mountains cities after % (expected 6)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 6 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 6)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'cities' AND action = 'INSERT' AND row_pk = c_new_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit city insert %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'cities' AND action = 'UPDATE' AND row_pk IN (c_jackson, c_wpark)
     AND (old_row - 'region_id') = (new_row - 'region_id');
  IF x <> 2 THEN RAISE EXCEPTION 'audit city region updates % (expected 2, region only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = c_venue
     AND (old_row - 'city_id') = (new_row - 'city_id') AND old_row->>'city_id' = c_jackson AND new_row->>'city_id' = c_new_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit venue update % (expected 1, city_id only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND row_pk = c_venue;
  IF x <> 2 THEN RAISE EXCEPTION 'audit slug rows % (expected 2)', x; END IF;

  -- Stage-job city resolution (resolve.ts: slug, display, alias; then the country filter): the label "Jackson"
  -- with country "United States" must still give exactly ci_b41779690b.
  WITH lab AS (SELECT 'jackson'::text AS n_full, 'jackson'::text AS n_head, 'united states'::text AS n_country),
  cand AS (
    SELECT c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT a.city_id FROM lab h JOIN city_aliases a ON a.alias IN (h.n_full, h.n_head))
  SELECT count(*), min(ci.id) INTO x, t FROM cand c JOIN cities ci ON ci.id = c.id, lab l
   WHERE lower(ci.country_iso) = 'us' OR btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = l.n_country;
  IF x <> 1 OR t IS DISTINCT FROM c_jackson THEN RAISE EXCEPTION 'label Jackson (US) resolves to % cities (%)', x, t; END IF;

  RAISE NOTICE 'OK: city %, venue moved, 2 slug rows, 2 regions removed, 6 audit rows after id %', c_new_id, aud_max;
END
$jwy$;
COMMIT;
