-- cities-michelin-2026-taiwan.sql
-- CompassEats, Taiwan 2026 stage preparation, Step A (chat Oct 11, 2026).
--
-- Ben, Oct 11 20:31 Atlanta: New Taipei City = option B (a separate city before the stage);
-- the 31 open Bib lines = option A (new venues; the old rows go to a contamination register).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts the city "New Taipei City":
--        slug    = trim(both '-' from regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+','-','g')) = new-taipei-city
--        id      = 'ci_' || left(md5(slug), 10) = ci_dc8224da29 (same rule as the NL and Germany city inserts)
--        country 'Taiwan', country_iso 'TW', kind 'city', region_id NULL, lat/lng NULL, venues_count 0
--      The Michelin card prints "New Taipei"; Michelin's articles and URL path say "New Taipei City"
--      (northern-taiwan/new-taipei-city_2853082). Same pattern as Valkenburg aan de Geul + alias.
--      trg_audit_cities writes 1 INSERT audit row.
--   2. Points the existing alias "new taipei" (today -> Taipei ci_39139f000b, from the first data load,
--      no audit row) to the new city. city_aliases has no audit trigger, so the file writes
--      1 hand audit row (row_pk = alias, action UPDATE, old and new row).
--   3. Moves 7 venues from Taipei to New Taipei City (venues.city_id). trg_audit_venues writes 7 UPDATE rows.
--      These are the 7 Taipei venues that carry the Michelin label "New Taipei" AND that a 2026 New Taipei
--      card confirms (CSV fixtures/ingest/michelin-2026-taiwan.csv, sha256 835d3cc2...b046):
--        exact-key match: GARDENh (line 104), San Tung (163), Shang Hao (166), Song Jhao (179)
--        Chinese-name pair: ve_8c951102be (66), ve_ea349b8773 (93), ve_14ca1bc485 (106)
--      The other 7 venues with the "New Taipei" label stay in Taipei: their stored names belong to other
--      businesses (Da-Wan, ve_9372d12543, KANG Artisan Bakery, Fon-Ce, Di Yi Beef Noodle Restaurant,
--      Chen Tung Pork Ribs Medicinal Herbs Soup, Yong He Soya Milk King (Da'an)). Under Ben's option A
--      they go to the contamination register, not to a guessed city.
--   4. Slugs for the 7 moved venues (slug-file method): the old canonical /taipei/<slug> row becomes
--      non-canonical (the old URL keeps working), and a new canonical /new-taipei-city/<slug> row is inserted.
--      New slug = the f_unaccent rule on the name; a name with no Latin letters uses the slug.ts fallback
--      'new-taipei-city-' || left(md5('new-taipei-city:' || name), 6) (equal to slug.ts on all 7 names).
--      trg_audit_slugs writes 7 UPDATE + 7 INSERT rows.
--   No ledger row (no publisher). No row is deleted. city_label_source is not changed (source record).
--
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, by venue_id, newline), read
-- Oct 11 after Ben's choices: e99095f737a6712ac2d10572794a711e (7 rows).
--
-- Gates (PRE): counts (cities 3258, city_aliases 259, venues 11254, slugs 12709 / non-canonical 1455,
--              awards 22659, listings 11254, audit_log 106529 / last id 111204), plan fingerprint,
--              alias "new taipei" -> Taipei, no clash for the new city id/slug/display, no slug clash,
--              no redirect clash, no michelin-2026-taiwan batch yet, each plan venue in Taipei with the label.
-- Gates (POST): counts (cities 3259, city_aliases 259, slugs 12716 / non-canonical 1462 / canonical 11254),
--               7 venues in the new city, 101 venues left in Taipei, exactly 1 canonical slug per venue,
--               23 new audit rows by table and action, and the stage-job city resolution:
--               "New Taipei" and "New Taipei City" -> ci_dc8224da29, "Taipei" -> ci_39139f000b.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

DO $twcity$
DECLARE
  c_new_id      constant text := 'ci_dc8224da29';
  c_new_slug    constant text := 'new-taipei-city';
  c_new_display constant text := 'New Taipei City';
  c_taipei_id   constant text := 'ci_39139f000b';
  c_fp          constant text := 'e99095f737a6712ac2d10572794a711e';
  c_venues      constant text[] := ARRAY['ve_14ca1bc485','ve_1db6f458ea','ve_6d9c2d924e','ve_6ee0642103','ve_76907429c5','ve_8c951102be','ve_ea349b8773'];
  plan     jsonb;
  v_fp     text;
  v_n      int;
  v_m      int;
  v_audit0 bigint;
  v_alias_old jsonb;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO v_n FROM cities;        IF v_n <> 3258  THEN RAISE EXCEPTION 'PRE cities % <> 3258', v_n; END IF;
  SELECT count(*) INTO v_n FROM city_aliases;  IF v_n <> 259   THEN RAISE EXCEPTION 'PRE city_aliases % <> 259', v_n; END IF;
  SELECT count(*) INTO v_n FROM venues;        IF v_n <> 11254 THEN RAISE EXCEPTION 'PRE venues % <> 11254', v_n; END IF;
  SELECT count(*) INTO v_n FROM awards;        IF v_n <> 22659 THEN RAISE EXCEPTION 'PRE awards % <> 22659', v_n; END IF;
  SELECT count(*) INTO v_n FROM listings;      IF v_n <> 11254 THEN RAISE EXCEPTION 'PRE listings % <> 11254', v_n; END IF;
  SELECT count(*) INTO v_n FROM slugs;         IF v_n <> 12709 THEN RAISE EXCEPTION 'PRE slugs % <> 12709', v_n; END IF;
  SELECT count(*) INTO v_n FROM slugs WHERE NOT is_canonical; IF v_n <> 1455 THEN RAISE EXCEPTION 'PRE non-canonical % <> 1455', v_n; END IF;
  SELECT count(*), max(id) INTO v_n, v_audit0 FROM audit_log;
  IF v_n <> 106529 THEN RAISE EXCEPTION 'PRE audit_log rows % <> 106529', v_n; END IF;
  IF v_audit0 <> 111204 THEN RAISE EXCEPTION 'PRE audit_log last id % <> 111204', v_audit0; END IF;

  SELECT count(*) INTO v_n FROM ingest_batches WHERE batch_key = 'michelin-2026-taiwan';
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE a michelin-2026-taiwan batch already exists'; END IF;

  SELECT count(*) INTO v_n FROM city_aliases WHERE alias = 'new taipei' AND city_id = c_taipei_id;
  IF v_n <> 1 THEN RAISE EXCEPTION 'PRE alias new taipei -> Taipei rows % <> 1', v_n; END IF;
  SELECT count(*) INTO v_n FROM city_aliases WHERE alias = 'new taipei city';
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE alias new taipei city already exists'; END IF;

  -- Slug and id of the new city follow the rule; no clash with any city id, slug or normalised display/slug.
  IF trim(both '-' from regexp_replace(lower(f_unaccent(c_new_display)), '[^a-z0-9]+', '-', 'g')) <> c_new_slug
     OR 'ci_' || left(md5(c_new_slug), 10) <> c_new_id THEN
    RAISE EXCEPTION 'PRE new city slug or id does not follow the rule';
  END IF;
  SELECT count(*) INTO v_n FROM cities c
   WHERE c.id = c_new_id OR c.slug = c_new_slug
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN ('new taipei', 'new taipei city')
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)),    '[^a-z0-9]+', ' ', 'g')) IN ('new taipei', 'new taipei city');
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE % cities clash with New Taipei City', v_n; END IF;

  -- The plan, read live.
  SELECT jsonb_agg(jsonb_build_object('venue_id', q.venue_id, 'old_slug', q.old_slug, 'new_slug', q.new_slug) ORDER BY q.venue_id),
         md5(string_agg(q.venue_id || '|' || q.name || '|' || q.city_slug || '|' || q.old_slug || '|' || q.new_slug, E'\n' ORDER BY q.venue_id)),
         count(*)
    INTO plan, v_fp, v_n
  FROM (
    SELECT v.id AS venue_id, v.name, c.slug AS city_slug, s.slug AS old_slug,
           coalesce(nullif(trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')), ''),
                    c_new_slug || '-' || left(md5(c_new_slug || ':' || v.name), 6)) AS new_slug
      FROM unnest(c_venues) AS u(venue_id)
      JOIN venues v ON v.id = u.venue_id
      JOIN cities c ON c.id = v.city_id
      JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
  ) q;
  IF v_n <> 7 THEN RAISE EXCEPTION 'PRE plan rows % <> 7', v_n; END IF;
  IF v_fp IS DISTINCT FROM c_fp THEN RAISE EXCEPTION 'PRE plan fingerprint % <> %', v_fp, c_fp; END IF;

  SELECT count(*) INTO v_n FROM venues v
   WHERE v.id = ANY (c_venues) AND v.city_id = c_taipei_id
     AND EXISTS (SELECT 1 FROM city_label_source l WHERE l.venue_id = v.id AND l.label = 'New Taipei');
  IF v_n <> 7 THEN RAISE EXCEPTION 'PRE plan venues in Taipei with the New Taipei label % <> 7', v_n; END IF;

  SELECT count(*) INTO v_n FROM jsonb_to_recordset(plan) p(new_slug text)
    JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = c_new_slug AND s.slug = p.new_slug;
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE new slugs already in use: %', v_n; END IF;
  SELECT count(*) INTO v_n FROM (SELECT p.new_slug FROM jsonb_to_recordset(plan) p(new_slug text) GROUP BY 1 HAVING count(*) > 1) d;
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE duplicate new slugs inside the plan: %', v_n; END IF;
  SELECT count(*) INTO v_n FROM redirects WHERE from_path LIKE '/' || c_new_slug || '%' OR from_path LIKE '/venue/' || c_new_slug || '%';
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE redirects already use the new city path: %', v_n; END IF;

  SELECT count(*) INTO v_n FROM (SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical GROUP BY venue_id HAVING count(*) <> 1) m;
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE venues with more than 1 canonical slug: %', v_n; END IF;
  SELECT count(*) INTO v_n FROM venues WHERE city_id = c_taipei_id;
  IF v_n <> 108 THEN RAISE EXCEPTION 'PRE Taipei venues % <> 108', v_n; END IF;

  ---------------------------------------------------------------- WRITE 1: the city
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  VALUES (c_new_id, c_new_slug, c_new_display, 'Taiwan', 'TW', 'city', NULL, NULL, NULL, 0);
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'WRITE city insert % <> 1', v_n; END IF;

  ---------------------------------------------------------------- WRITE 2: the alias + hand audit row
  SELECT to_jsonb(a) INTO v_alias_old FROM city_aliases a WHERE a.alias = 'new taipei';
  UPDATE city_aliases SET city_id = c_new_id WHERE alias = 'new taipei' AND city_id = c_taipei_id;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'WRITE alias update % <> 1', v_n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'UPDATE', v_alias_old, to_jsonb(a) FROM city_aliases a WHERE a.alias = 'new taipei';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'WRITE hand audit row % <> 1', v_n; END IF;

  ---------------------------------------------------------------- WRITE 3: move the 7 venues
  UPDATE venues SET city_id = c_new_id WHERE id = ANY (c_venues) AND city_id = c_taipei_id;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 7 THEN RAISE EXCEPTION 'WRITE venue move % <> 7', v_n; END IF;

  ---------------------------------------------------------------- WRITE 4: slugs
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = 'taipei' AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 7 THEN RAISE EXCEPTION 'WRITE old canonical rows updated % <> 7', v_n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', c_new_slug, p.new_slug, p.venue_id, true FROM jsonb_to_recordset(plan) p(venue_id text, new_slug text);
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 7 THEN RAISE EXCEPTION 'WRITE new canonical rows inserted % <> 7', v_n; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO v_n FROM cities;        IF v_n <> 3259  THEN RAISE EXCEPTION 'POST cities % <> 3259', v_n; END IF;
  SELECT count(*) INTO v_n FROM city_aliases;  IF v_n <> 259   THEN RAISE EXCEPTION 'POST city_aliases % <> 259', v_n; END IF;
  SELECT count(*) INTO v_n FROM venues;        IF v_n <> 11254 THEN RAISE EXCEPTION 'POST venues % <> 11254', v_n; END IF;
  SELECT count(*) INTO v_n FROM awards;        IF v_n <> 22659 THEN RAISE EXCEPTION 'POST awards % <> 22659', v_n; END IF;
  SELECT count(*) INTO v_n FROM listings;      IF v_n <> 11254 THEN RAISE EXCEPTION 'POST listings % <> 11254', v_n; END IF;
  SELECT count(*) INTO v_n FROM slugs;         IF v_n <> 12716 THEN RAISE EXCEPTION 'POST slugs % <> 12716', v_n; END IF;
  SELECT count(*) INTO v_n FROM slugs WHERE NOT is_canonical; IF v_n <> 1462  THEN RAISE EXCEPTION 'POST non-canonical % <> 1462', v_n; END IF;
  SELECT count(*) INTO v_n FROM slugs WHERE is_canonical;     IF v_n <> 11254 THEN RAISE EXCEPTION 'POST canonical % <> 11254', v_n; END IF;

  SELECT count(*) INTO v_n FROM venues WHERE city_id = c_new_id;    IF v_n <> 7   THEN RAISE EXCEPTION 'POST New Taipei City venues % <> 7', v_n; END IF;
  SELECT count(*) INTO v_n FROM venues WHERE city_id = c_taipei_id; IF v_n <> 101 THEN RAISE EXCEPTION 'POST Taipei venues % <> 101', v_n; END IF;

  SELECT count(*) INTO v_n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF v_n <> 0 THEN RAISE EXCEPTION 'POST venues without exactly 1 canonical slug: %', v_n; END IF;
  SELECT count(*) INTO v_n FROM jsonb_to_recordset(plan) p(venue_id text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = c_new_slug AND s.slug = p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = 'taipei' AND s.slug = p.old_slug AND NOT s.is_canonical);
  IF v_n <> 7 THEN RAISE EXCEPTION 'POST venues with new canonical and old non-canonical % <> 7', v_n; END IF;

  -- 23 new audit rows: cities INSERT 1, city_aliases UPDATE 1 (hand), venues UPDATE 7, slugs UPDATE 7, slugs INSERT 7.
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0;
  IF v_n <> 23 THEN RAISE EXCEPTION 'POST new audit rows % <> 23', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0 AND table_name = 'cities' AND action = 'INSERT' AND row_pk = c_new_id;
  IF v_n <> 1 THEN RAISE EXCEPTION 'POST city audit rows % <> 1', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0 AND table_name = 'city_aliases' AND action = 'UPDATE' AND row_pk = 'new taipei';
  IF v_n <> 1 THEN RAISE EXCEPTION 'POST alias audit rows % <> 1', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0 AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = ANY (c_venues)
     AND old_row->>'city_id' = c_taipei_id AND new_row->>'city_id' = c_new_id AND old_row->>'name' = new_row->>'name';
  IF v_n <> 7 THEN RAISE EXCEPTION 'POST venue audit rows % <> 7', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0 AND table_name = 'slugs' AND action = 'UPDATE' AND row_pk = ANY (c_venues);
  IF v_n <> 7 THEN RAISE EXCEPTION 'POST slug update audit rows % <> 7', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0 AND table_name = 'slugs' AND action = 'INSERT' AND row_pk = ANY (c_venues);
  IF v_n <> 7 THEN RAISE EXCEPTION 'POST slug insert audit rows % <> 7', v_n; END IF;

  -- Stage-job city resolution (resolve.ts: slug, display, alias; country hint "Taiwan").
  WITH lab AS (
    SELECT w.k, w.want,
           btrim(regexp_replace(lower(f_unaccent(w.label)), '[^a-z0-9]+', ' ', 'g'))                        AS n_full,
           btrim(regexp_replace(lower(f_unaccent(split_part(w.label, ',', 1))), '[^a-z0-9]+', ' ', 'g')) AS n_head,
           'taiwan'::text AS n_country
      FROM (VALUES (1, 'New Taipei', c_new_id), (2, 'New Taipei City', c_new_id), (3, 'Taipei', c_taipei_id)) AS w(k, label, want)
  ), cand AS (
    SELECT h.k, c.id AS city_id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.k, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.k, a.city_id FROM lab h JOIN city_aliases a ON a.alias IN (h.n_full, h.n_head)
  ), got AS (
    SELECT l.k, l.want, count(c.city_id) AS n_cand, min(c.city_id) AS city_id,
           bool_and(lower(ci.country_iso) = l.n_country OR btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = l.n_country) AS tw
      FROM lab l LEFT JOIN cand c ON c.k = l.k LEFT JOIN cities ci ON ci.id = c.city_id
     GROUP BY l.k, l.want
  )
  SELECT count(*) FILTER (WHERE n_cand IS DISTINCT FROM 1 OR city_id IS DISTINCT FROM want OR tw IS NOT TRUE), count(*)
    INTO v_n, v_m FROM got;
  IF v_m <> 3 THEN RAISE EXCEPTION 'POST resolution rows % <> 3', v_m; END IF;
  IF v_n <> 0 THEN RAISE EXCEPTION 'POST % labels do not resolve to exactly the expected city', v_n; END IF;

  RAISE NOTICE 'OK: New Taipei City added, alias repointed, 7 venues moved, 14 slug rows, 23 audit rows after id %', v_audit0;
END
$twcity$;
