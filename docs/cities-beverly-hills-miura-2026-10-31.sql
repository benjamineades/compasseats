-- cities-beverly-hills-miura-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 7, file 3 of 3 (E4). INSERT/UPDATE only: Write connector.
--   Run it only after file 2 (merge-la-table-christophe-hay-2026-10-31.sql); the guards stop it otherwise.
-- Ben: Oct 31 03:42 ET "All A"; 04:03 ET "3. A1" (E4 = A1).
-- Rule D3 (Michelin city = the city in the card URL; Oct 31 block 5: applies outside Turkey too).
-- Miura ve_ca50fd9f2e: card https://guide.michelin.com/us/en/california/beverly-hills/restaurant/miura-1246958
--   "218 N. Rodeo Dr., Beverly Hills, CA, 90210, USA", One Star, 2026 MICHELIN Guide USA (read Oct 31). Ours: Los Angeles.
-- Writes (one transaction):
--   cities INSERT ci_a7d1756bcb (= 'ci_' + left(md5('beverly-hills'), 10)) slug beverly-hills, display Beverly Hills;
--     country, country_iso, kind, region_id copied from Los Angeles; lat/lng NULL; venues_count 1.
--   venues UPDATE Miura city_id -> ci_a7d1756bcb (city_id only).
--   slugs: los-angeles/miura -> non-canonical (old URL keeps working); INSERT beverly-hills/miura canonical.
--     los-angeles/miura-hotel stays non-canonical.
--   cities UPDATE Los Angeles venues_count 115 -> 114 (stored count = view city_venue_counts).
--   city_aliases UPDATE 'beverly hills': Los Angeles -> Beverly Hills, with a hand audit row (no trigger on city_aliases).
--     Reason: with the alias left on Los Angeles, a label "Beverly Hills" matches 2 cities in the ingest resolver
--     (scripts/ingest/lib/resolve.ts: display route + alias route).
--   The 9 other venues with a "Beverly Hills" neighborhood label stay in Los Angeles (A1). No ledger row (block 5 precedent).
-- Expected: cities 3259 -> 3260; city_aliases 266 (unchanged); slugs 12944 -> 12945 (non-canonical 1642 -> 1643);
--   venues_count sum 10936 (unchanged); audit 119432 -> 119438 (+6: cities INSERT 1, venues UPDATE 1, slugs UPDATE 1 + INSERT 1,
--   cities UPDATE 1, city_aliases UPDATE 1 hand).
BEGIN;
DO $do$
DECLARE
  c_new_id   constant text := 'ci_a7d1756bcb';
  c_new_slug constant text := 'beverly-hills';
  c_new_disp constant text := 'Beverly Hills';
  c_old_id   constant text := 'ci_2e26eb9108';
  c_venue    constant text := 've_ca50fd9f2e';
  c_vslug    constant text := 'miura';
  c_alias    constant text := 'beverly hills';
  x int; v_aud bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF c_new_id <> 'ci_' || left(md5(c_new_slug), 10) THEN RAISE EXCEPTION 'new city id'; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11302 THEN RAISE EXCEPTION 'venues before % (run file 2 first)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active'; IF x <> 10936 THEN RAISE EXCEPTION 'active before %', x; END IF;
  SELECT count(*) INTO x FROM cities;                        IF x <> 3259  THEN RAISE EXCEPTION 'cities before %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 266   THEN RAISE EXCEPTION 'city_aliases before %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12944 THEN RAISE EXCEPTION 'slugs before %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1642  THEN RAISE EXCEPTION 'non-canonical before % (run file 2 first)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects before %', x; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 178 THEN RAISE EXCEPTION 'ledger before (run file 2 first)'; END IF;
  SELECT max(id) INTO v_aud FROM audit_log;
  IF v_aud <> 119432 OR (SELECT count(*) FROM audit_log) <> 114148 THEN RAISE EXCEPTION 'audit before % (run file 2 first)', v_aud; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10936 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;

  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = c_venue AND name = 'Miura' AND status = 'active' AND city_id = c_old_id)
    THEN RAISE EXCEPTION 'Miura row'; END IF;
  IF NOT EXISTS (SELECT 1 FROM awards WHERE venue_id = c_venue AND id = 21077 AND source_id = 'michelin' AND year = 2026
                   AND source_url = 'https://guide.michelin.com/us/en/california/beverly-hills/restaurant/miura-1246958')
    THEN RAISE EXCEPTION 'Miura card URL'; END IF;
  IF NOT EXISTS (SELECT 1 FROM cities WHERE id = c_old_id AND slug = 'los-angeles' AND venues_count = 115) THEN RAISE EXCEPTION 'Los Angeles row'; END IF;
  SELECT count(*) INTO x FROM cities c
   WHERE c.id = c_new_id OR c.slug = c_new_slug
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = c_alias
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g'))    = c_alias;
  IF x <> 0 THEN RAISE EXCEPTION 'new city clashes with % existing cities', x; END IF;
  IF (SELECT count(*) FROM city_aliases WHERE alias = c_alias AND city_id = c_old_id) <> 1 THEN RAISE EXCEPTION 'alias row'; END IF;
  SELECT count(*) INTO x FROM slugs WHERE city_slug = c_new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'slug rows already under %: %', c_new_slug, x; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = c_venue) <> 2
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = c_venue AND property_id = 'eats' AND city_slug = 'los-angeles' AND slug = c_vslug AND is_canonical)
    THEN RAISE EXCEPTION 'Miura slugs'; END IF;
  SELECT count(*) INTO x FROM redirects WHERE from_path LIKE '%' || c_new_slug || '/%' OR to_path LIKE '%' || c_new_slug || '/%'
      OR from_path LIKE '%los-angeles/' || c_vslug || '%' OR to_path LIKE '%los-angeles/' || c_vslug || '%';
  IF x <> 0 THEN RAISE EXCEPTION 'paths already in redirects: %', x; END IF;

  ---------------------------------------------------------------- writes
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT c_new_id, c_new_slug, c_new_disp, c.country, c.country_iso, c.kind, c.region_id, NULL, NULL, 1
    FROM cities c WHERE c.id = c_old_id;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'city insert %', x; END IF;

  UPDATE venues SET city_id = c_new_id WHERE id = c_venue AND city_id = c_old_id;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'venue move %', x; END IF;

  UPDATE slugs SET is_canonical = false
   WHERE venue_id = c_venue AND property_id = 'eats' AND city_slug = 'los-angeles' AND slug = c_vslug AND is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'old canonical slug update %', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', c_new_slug, c_vslug, c_venue, true);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'new canonical slug insert %', x; END IF;

  UPDATE cities SET venues_count = 114 WHERE id = c_old_id AND venues_count = 115;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'Los Angeles count update %', x; END IF;

  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'UPDATE', to_jsonb(a), to_jsonb(a) || jsonb_build_object('city_id', c_new_id)
    FROM city_aliases a WHERE a.alias = c_alias AND a.city_id = c_old_id;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'alias hand audit row %', x; END IF;
  UPDATE city_aliases SET city_id = c_new_id WHERE alias = c_alias AND city_id = c_old_id;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'alias update %', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3260  THEN RAISE EXCEPTION 'cities after %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 266   THEN RAISE EXCEPTION 'city_aliases after %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12945 THEN RAISE EXCEPTION 'slugs after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1643  THEN RAISE EXCEPTION 'non-canonical after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;      IF x <> 11302 THEN RAISE EXCEPTION 'canonical after %', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11302 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
              GROUP BY v.id HAVING count(s.slug) <> 1) THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10936 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  -- a label "Beverly Hills" now finds only the new city (display route and alias route)
  SELECT count(DISTINCT id) INTO x FROM (
    SELECT c.id FROM cities c WHERE btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = c_alias
    UNION SELECT a.city_id FROM city_aliases a WHERE a.alias = c_alias) r;
  IF x <> 1 OR NOT EXISTS (SELECT 1 FROM city_aliases WHERE alias = c_alias AND city_id = c_new_id) THEN RAISE EXCEPTION 'label resolution after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud) <> 6 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'cities' AND action = 'INSERT' AND row_pk = c_new_id) <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = c_venue
           AND (old_row - 'city_id') = (new_row - 'city_id')) <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'slugs' AND action = 'UPDATE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'slugs' AND action = 'INSERT') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'cities' AND action = 'UPDATE' AND row_pk = c_old_id
           AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'city_aliases' AND action = 'UPDATE' AND row_pk = c_alias) <> 1
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
