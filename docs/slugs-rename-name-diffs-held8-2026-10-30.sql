-- slugs-rename-name-diffs-held8-2026-10-30.sql
-- CompassEats, Oct 30 2026. New canonical slugs for the 8 venues renamed by rename batch
-- rename-name-diffs-held8-2026-10-30 (docs/rename-name-diffs-held8-2026-10-30.sql). Run only after that batch is applied.
-- Template: docs/slugs-rename-name-diffs-2026-10-30.sql (same method, same checks; the gate finds the batch by its key
-- and checks that the 8 live names equal new_name).
-- Built by script (docs/build_name_diffs_held8_rename.py slug): 23 rules / 23 counted replacements, leftover check.
-- Method: gated SQL, one transaction, through the Supabase Write connector.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')), Ben's option A (Oct 8).
-- 3 of the 8 venues keep their slug (the name changes only in capitals). Plan: 5 rows.
-- For each plan venue: the old canonical row becomes non-canonical (old URL stays and points to the same venue),
-- and a new canonical row is inserted. Reuse (1): La P’tite Patte ve_c4d70b9a92 already has the non-canonical slug
-- cholet/la-p-tite-patte (moved there by the Sep 16 merge of ve_17d83ed8dd, audit 97523); that row becomes canonical
-- again and no row is inserted for it (reuse md5 45e00aab022ead3f70e785f8640109f8). No row is deleted. No ledger row. 0 blurbs.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id, joined by newline,
-- only rows where new_slug <> old_slug), read Oct 30 from the proposed names before the rename:
--   60124224907e2d1c6f478df4bb5afbb5  (5 rows). Checks then: 0 empty, 0 duplicate, 0 in redirects; in use 1 = the reuse row (same venue, non-canonical).
-- Expected before: slugs 12,909 (non-canonical 1,605); audit_log 113,681 rows, last id 118,965 (= after the rename).
-- Expected after: slugs 12,913, non-canonical 1,609, canonical 11,304;
-- audit +10 (6 UPDATE + 4 INSERT).
-- Dry run: send through the Read connector after the rename. All pre-checks run, then the block stops at the
-- first UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan        jsonb;
  n_plan      int;
  n_all       int;
  n_same      int;
  fp          text;
  n_reuse     int;
  fp_reuse    text;
  bid         bigint;
  n           int;
  x           int;
  aud_max     bigint;
  aud_n       bigint;
BEGIN
  -- 1. Build the plan from live data
  SELECT count(*), max(id) INTO x, bid FROM rename_batches WHERE status = 'applied'
     AND batch_key = 'rename-name-diffs-held8-2026-10-30';
  IF x <> 1 THEN RAISE EXCEPTION 'rename batch rename-name-diffs-held8-2026-10-30 applied: % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid;
  IF x <> 8 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 8)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows r JOIN venues v ON v.id = r.venue_id
   WHERE r.batch_id = bid AND v.name IS DISTINCT FROM r.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'batch venues whose live name is not new_name: %', x; END IF;

  SELECT count(*), count(*) FILTER (WHERE q.new_slug = q.old_slug)
    INTO n_all, n_same
  FROM (
    SELECT s.slug AS old_slug,
           trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
    FROM rename_rows r
    JOIN venues v ON v.id = r.venue_id
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE r.batch_id = bid
  ) q;
  IF n_all <> 8 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 8)', n_all; END IF;
  IF n_same <> 3 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 3)', n_same; END IF;

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
    FROM rename_rows r
    JOIN venues v ON v.id = r.venue_id
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE r.batch_id = bid
  ) q
  WHERE q.new_slug <> q.old_slug;

  -- 2. Pre-checks
  IF n_plan <> 5 THEN RAISE EXCEPTION 'plan rows % (expected 5)', n_plan; END IF;
  IF fp <> '60124224907e2d1c6f478df4bb5afbb5' THEN
    RAISE EXCEPTION 'plan fingerprint % differs from the Oct 30 read', fp; END IF;

  SELECT count(DISTINCT p.venue_id) INTO x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF x <> 5 THEN RAISE EXCEPTION 'distinct venues % (expected 5)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(old_slug text, new_slug text)
   WHERE p.new_slug = '' OR p.new_slug = p.old_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'empty or unchanged new slugs: %', x; END IF;

  SELECT count(*) INTO x FROM (
    SELECT p.city_slug, p.new_slug FROM jsonb_to_recordset(plan) p(city_slug text, new_slug text)
    GROUP BY 1, 2 HAVING count(*) > 1) d;
  IF x <> 0 THEN RAISE EXCEPTION 'duplicate new slugs inside the plan: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug
   WHERE s.venue_id <> p.venue_id OR s.is_canonical;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs in use by another venue or as a canonical slug: %', x; END IF;

  -- new slugs that are already a non-canonical slug of the same venue: reuse (made canonical again, no insert)
  SELECT count(*), md5(string_agg(p.venue_id||'|'||p.city_slug||'|'||p.new_slug, E'\n' ORDER BY p.venue_id))
    INTO n_reuse, fp_reuse
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
    JOIN slugs s ON s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = p.city_slug
                AND s.slug = p.new_slug AND NOT s.is_canonical;
  IF n_reuse <> 1 OR fp_reuse <> '45e00aab022ead3f70e785f8640109f8' THEN
    RAISE EXCEPTION 'reuse rows % / % (expected 1 / 45e00aab022ead3f70e785f8640109f8)', n_reuse, fp_reuse; END IF;

  SELECT count(*) INTO x FROM redirects d, jsonb_to_recordset(plan) p(city_slug text, new_slug text)
   WHERE d.from_path IN ('/'||p.city_slug||'/'||p.new_slug, '/venue/'||p.city_slug||'/'||p.new_slug);
  IF x <> 0 THEN RAISE EXCEPTION 'new paths already in redirects: %', x; END IF;

  SELECT count(*) INTO x FROM (
    SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical
    GROUP BY venue_id HAVING count(*) <> 1) m;
  IF x <> 0 THEN RAISE EXCEPTION 'venues with more than 1 canonical slug before: %', x; END IF;

  SELECT count(*) INTO x FROM slugs;                        IF x <> 12909 THEN RAISE EXCEPTION 'slugs before % (expected 12909)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1605 THEN RAISE EXCEPTION 'non-canonical before % (expected 1605)', x; END IF;
  SELECT count(*) INTO x FROM venues;                       IF x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 23353 THEN RAISE EXCEPTION 'awards before % (expected 23353)', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;                       IF x <> 142 THEN RAISE EXCEPTION 'blurbs before % (expected 142)', x; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 113681 THEN RAISE EXCEPTION 'audit_log before % (expected 113681)', aud_n; END IF;
  IF aud_max <> 118965 THEN RAISE EXCEPTION 'audit_log last id % (expected 118965)', aud_max; END IF;

  -- 3. Writes
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id
     AND s.city_slug = p.city_slug AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 5 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 5)', n; END IF;

  UPDATE slugs s SET is_canonical = true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = p.city_slug
     AND s.slug = p.new_slug AND NOT s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'reused rows made canonical % (expected 1)', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   WHERE NOT EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug);
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 4 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 4)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM slugs;                        IF x <> 12913 THEN RAISE EXCEPTION 'slugs after % (expected 12913)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1609 THEN RAISE EXCEPTION 'non-canonical after % (expected 1609)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11304 THEN RAISE EXCEPTION 'canonical after % (expected 11304)', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND NOT s.is_canonical);
  IF x <> 5 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 5)', x; END IF;

  SELECT count(*) INTO x FROM venues;   IF x <> 11304 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;   IF x <> 23353 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings; IF x <> 11304 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;   IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'UPDATE';
  IF x <> 6 THEN RAISE EXCEPTION 'audit slug updates % (expected 6)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'INSERT';
  IF x <> 4 THEN RAISE EXCEPTION 'audit slug inserts % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 10 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 10)', x; END IF;
END
$do$;
COMMIT;
