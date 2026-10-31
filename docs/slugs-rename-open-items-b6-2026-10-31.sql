-- slugs-rename-open-items-b6-2026-10-31.sql
-- CompassEats, Oct 31 2026. New canonical slugs for the venues renamed by rename-open-items-b6-2026-10-31
-- (docs/rename-open-items-b6-2026-10-31.sql). Run only after that batch is applied. File 2 of 3.
-- Ben: Oct 31 01:56 ET "1, 2A, 2B"; 02:01 ET "Your recommendation for everything" (D1-D5 = A).
-- Template: docs/slugs-rename-open-items-b1-2026-10-30.sql. Built by script docs/open-items-b6-build/build_open_items_b6_2026_10_31.py.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')), Ben's option A (Oct 8).
-- Krèsios keeps telese/kresios (the rule gives the same slug). Plan: 4 rows, 0 reuse, 4 inserts.
--   ve_542c195114 Paca: carmignano/paca-ristorante -> carmignano/paca (insert)
--   ve_e50adc624d El Jardín de la Sal: fuencaliente-de-la-palma/restaurante-tematico-el-jardin-de-la-sal -> fuencaliente-de-la-palma/el-jardin-de-la-sal (insert)
--   ve_eef796a74d Coxinendi: quartu-sant-elena/coxinendi-ristorante -> quartu-sant-elena/coxinendi (insert)
--   ve_f88a5d9dc2 The Upper Room at Duddell’s: hong-kong/duddell-s-bar -> hong-kong/the-upper-room-at-duddell-s (insert)
-- Each old canonical row becomes non-canonical (old URL stays and points to the same venue). No delete, no ledger row.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id): 1ce2957cceeea12fa4e2e0c511fb2e98
-- Expected before: slugs 12940 (non-canonical 1637); audit_log 114114 rows, last id 119398.
-- Expected after: slugs 12944, non-canonical 1641, canonical 11303; audit +8 (4 UPDATE + 4 INSERT).
-- Dry run: send through the Read connector after the rename. It stops at the first UPDATE.

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
  SELECT count(*), max(id) INTO x, bid FROM rename_batches WHERE status = 'applied' AND batch_key = 'rename-open-items-b6-2026-10-31';
  IF x <> 1 THEN RAISE EXCEPTION 'rename batch rename-open-items-b6-2026-10-31 applied: % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid;
  IF x <> 5 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows r JOIN venues v ON v.id = r.venue_id
   WHERE r.batch_id = bid AND v.name IS DISTINCT FROM r.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'batch venues whose live name is not new_name: %', x; END IF;

  WITH q AS (SELECT v.id AS venue_id, v.name, s.city_slug, s.slug AS old_slug,
               trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
          FROM rename_rows r JOIN venues v ON v.id = r.venue_id
          JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
         WHERE r.batch_id = bid)
  SELECT count(*), count(*) FILTER (WHERE new_slug = old_slug) INTO n_all, n_same FROM q;
  WITH q AS (SELECT v.id AS venue_id, v.name, s.city_slug, s.slug AS old_slug,
               trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
          FROM rename_rows r JOIN venues v ON v.id = r.venue_id
          JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
         WHERE r.batch_id = bid)
  SELECT jsonb_agg(jsonb_build_object('venue_id', venue_id, 'city_slug', city_slug, 'old_slug', old_slug, 'new_slug', new_slug)
           ORDER BY venue_id),
         count(*),
         md5(string_agg(venue_id||'|'||name||'|'||city_slug||'|'||old_slug||'|'||new_slug, E'\n' ORDER BY venue_id))
    INTO plan, n_plan, fp
    FROM q WHERE new_slug <> old_slug;

  -- 2. Pre-checks
  IF n_all <> 5 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 5)', n_all; END IF;
  IF n_same <> 1 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 1, Krèsios)', n_same; END IF;
  IF n_plan <> 4 THEN RAISE EXCEPTION 'plan rows % (expected 4)', n_plan; END IF;
  IF fp <> '1ce2957cceeea12fa4e2e0c511fb2e98' THEN RAISE EXCEPTION 'plan fingerprint % differs from the Oct 31 read', fp; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(old_slug text, new_slug text)
   WHERE p.new_slug = '' OR p.new_slug = p.old_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'empty or unchanged new slugs: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs already in slugs (expected 0, all inserts): %', x; END IF;

  SELECT count(*) INTO x FROM redirects d, jsonb_to_recordset(plan) p(city_slug text, new_slug text)
   WHERE d.from_path IN ('/'||p.city_slug||'/'||p.new_slug, '/venue/'||p.city_slug||'/'||p.new_slug);
  IF x <> 0 THEN RAISE EXCEPTION 'new paths already in redirects: %', x; END IF;

  SELECT count(*) INTO x FROM (
    SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical
    GROUP BY venue_id HAVING count(*) <> 1) m;
  IF x <> 0 THEN RAISE EXCEPTION 'venues with more than 1 canonical slug before: %', x; END IF;

  SELECT count(*) INTO x FROM slugs;                        IF x <> 12940 THEN RAISE EXCEPTION 'slugs before %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1637 THEN RAISE EXCEPTION 'non-canonical before %', x; END IF;
  SELECT count(*) INTO x FROM venues;                       IF x <> 11303 THEN RAISE EXCEPTION 'venues before %', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 23362 THEN RAISE EXCEPTION 'awards before %', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11303 THEN RAISE EXCEPTION 'listings before %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;                       IF x <> 142 THEN RAISE EXCEPTION 'blurbs before %', x; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 114114 THEN RAISE EXCEPTION 'audit_log before %', aud_n; END IF;
  IF aud_max <> 119398 THEN RAISE EXCEPTION 'audit_log last id %', aud_max; END IF;

  -- 3. Writes
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id
     AND s.city_slug = p.city_slug AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 4 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 4)', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text);
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 4 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 4)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM slugs;                        IF x <> 12944 THEN RAISE EXCEPTION 'slugs after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1641 THEN RAISE EXCEPTION 'non-canonical after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11303 THEN RAISE EXCEPTION 'canonical after %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND NOT s.is_canonical);
  IF x <> 4 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 4)', x; END IF;

  SELECT count(*) INTO x FROM venues;   IF x <> 11303 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;   IF x <> 23362 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings; IF x <> 11303 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;   IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'UPDATE';
  IF x <> 4 THEN RAISE EXCEPTION 'audit slug updates % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'INSERT';
  IF x <> 4 THEN RAISE EXCEPTION 'audit slug inserts % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 8 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 8)', x; END IF;
END
$do$;
COMMIT;
