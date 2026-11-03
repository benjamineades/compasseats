-- slugs-rename-michelin-2026-switzerland.sql
-- CompassEats, Nov 2 2026. New canonical slugs for the 94 venues of rename batch rename-michelin-2026-switzerland,
-- plus Njørd café ve_6cedf32a8c (item 4: slug only, no rename). Run only after the batch is applied.
-- Template: docs/slugs-rename-michelin-2026-hong-kong-macau.sql. Slug rule as in that file.
-- 4 of the 95 venues keep their slug. Plan: 91 rows, fingerprint e36d1be94c7996fb8c528a8bb83c8bc0.
-- Old slugs stay as non-canonical and keep working. No row is deleted. No ledger row.
-- Expected after: slugs 13,144, non-canonical 1,821, canonical 11,323; audit +182.

BEGIN;
DO $do$
DECLARE
  plan        jsonb;
  n_plan      int;
  n_all       int;
  n_same      int;
  fp          text;
  bid         bigint;
  n           int;
  x           int;
  aud_max     bigint;
  aud_n       bigint;
BEGIN
  -- 1. Build the plan from live data
  SELECT count(*), max(id) INTO x, bid FROM rename_batches WHERE status = 'applied'
     AND batch_key = 'rename-michelin-2026-switzerland';
  IF x <> 1 THEN RAISE EXCEPTION 'rename batch rename-michelin-2026-switzerland applied: % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid;
  IF x <> 94 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 94)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows r JOIN venues v ON v.id = r.venue_id
   WHERE r.batch_id = bid AND v.name IS DISTINCT FROM r.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'batch venues whose live name is not new_name: %', x; END IF;

  SELECT count(*), count(*) FILTER (WHERE q.new_slug = q.old_slug)
    INTO n_all, n_same
  FROM (
    SELECT s.slug AS old_slug,
           trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
    FROM venues v
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE v.id IN (SELECT r.venue_id FROM rename_rows r WHERE r.batch_id = bid) OR v.id = 've_6cedf32a8c'
  ) q;
  IF n_all <> 95 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 95)', n_all; END IF;
  IF n_same <> 4 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 4)', n_same; END IF;

  SELECT jsonb_agg(jsonb_build_object(
           'venue_id', q.venue_id, 'city_slug', q.city_slug,
           'old_slug', q.old_slug, 'new_slug', q.new_slug) ORDER BY q.venue_id),
         count(*),
         md5(string_agg(q.venue_id||'|'||q.name||'|'||q.city_slug||'|'||q.old_slug||'|'||q.new_slug,
                        E'\n' ORDER BY q.venue_id))
    INTO plan, n_plan, fp
  FROM (
    SELECT v.id AS venue_id, v.name, s.city_slug, s.slug AS old_slug,
           trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
    FROM venues v
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE v.id IN (SELECT r.venue_id FROM rename_rows r WHERE r.batch_id = bid) OR v.id = 've_6cedf32a8c'
  ) q
  WHERE q.new_slug <> q.old_slug;

  -- 2. Pre-checks
  IF n_plan <> 91 THEN RAISE EXCEPTION 'plan rows % (expected 91)', n_plan; END IF;
  IF fp <> 'e36d1be94c7996fb8c528a8bb83c8bc0' THEN
    RAISE EXCEPTION 'plan fingerprint % differs from the Nov 3 read', fp; END IF;

  SELECT count(DISTINCT p.venue_id) INTO x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF x <> 91 THEN RAISE EXCEPTION 'distinct venues % (expected 91)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(old_slug text, new_slug text)
   WHERE p.new_slug = '' OR p.new_slug = p.old_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'empty or unchanged new slugs: %', x; END IF;

  SELECT count(*) INTO x FROM (
    SELECT p.city_slug, p.new_slug FROM jsonb_to_recordset(plan) p(city_slug text, new_slug text)
    GROUP BY 1, 2 HAVING count(*) > 1) d;
  IF x <> 0 THEN RAISE EXCEPTION 'duplicate new slugs inside the plan: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(city_slug text, new_slug text)
   JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs already in use: %', x; END IF;

  SELECT count(*) INTO x FROM redirects d, jsonb_to_recordset(plan) p(city_slug text, new_slug text)
   WHERE d.from_path IN ('/'||p.city_slug||'/'||p.new_slug, '/venue/'||p.city_slug||'/'||p.new_slug);
  IF x <> 0 THEN RAISE EXCEPTION 'new paths already in redirects: %', x; END IF;

  SELECT count(*) INTO x FROM (
    SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical
    GROUP BY venue_id HAVING count(*) <> 1) m;
  IF x <> 0 THEN RAISE EXCEPTION 'venues with more than 1 canonical slug before: %', x; END IF;

  SELECT count(*) INTO x FROM slugs;                        IF x <> 13053 THEN RAISE EXCEPTION 'slugs before % (expected 13053)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1730 THEN RAISE EXCEPTION 'non-canonical before % (expected 1730)', x; END IF;
  SELECT count(*) INTO x FROM venues;                       IF x <> 11323 THEN RAISE EXCEPTION 'venues before % (expected 11323)', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 25321 THEN RAISE EXCEPTION 'awards before % (expected 25321)', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11323 THEN RAISE EXCEPTION 'listings before % (expected 11323)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;                       IF x <> 142 THEN RAISE EXCEPTION 'blurbs before % (expected 142)', x; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 119329 THEN RAISE EXCEPTION 'audit_log before % (expected 119329)', aud_n; END IF;
  IF aud_max <> 125158 THEN RAISE EXCEPTION 'audit_log last id % (expected 125158)', aud_max; END IF;

  -- 3. Writes
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id
     AND s.city_slug = p.city_slug AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 91 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 91)', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text);
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 91 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 91)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM slugs;                        IF x <> 13144 THEN RAISE EXCEPTION 'slugs after % (expected 13144)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1821 THEN RAISE EXCEPTION 'non-canonical after % (expected 1821)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11323 THEN RAISE EXCEPTION 'canonical after % (expected 11323)', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND NOT s.is_canonical);
  IF x <> 91 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 91)', x; END IF;

  SELECT count(*) INTO x FROM venues;   IF x <> 11323 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;   IF x <> 25321 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings; IF x <> 11323 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;   IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'UPDATE';
  IF x <> 91 THEN RAISE EXCEPTION 'audit slug updates % (expected 91)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'INSERT';
  IF x <> 91 THEN RAISE EXCEPTION 'audit slug inserts % (expected 91)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 182 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 182)', x; END IF;
END
$do$;
COMMIT;
