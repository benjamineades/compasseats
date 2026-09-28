-- slugs-rename-michelin-2027-chengdu.sql
-- CompassEats, Sep 28 2026. Open item 1 (Plan v1.29): new canonical slugs for the 18
-- Chengdu venues renamed by rename batch 10 (rename-michelin-2027-chengdu).
-- Template: docs/slugs-rename-michelin-2026-china.sql (same method, same checks).
-- Method: gated SQL, one transaction, through the Supabase Write connector.
-- Slug rule: same as scripts/ingest/lib/slug.ts (slugify). 18 of 18 new slugs were
-- compared with slug.ts on Sep 28: 18 of 18 match. No name needs the CJK fallback.
-- For each venue: the old canonical row becomes non-canonical (old URL stays and
-- points to the same venue), and a new canonical row is inserted. No row is deleted.
-- No ledger row: a slug has no publisher. audit_log (trg_audit_slugs) is the record.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by
-- venue_id, joined by newline), read Sep 28 after rename batch 10:
--   dddd1ec271c0602ba6e4162856fe7c47  (18 rows)
-- Dry run: send through the Read connector. All pre-checks run, then the block
-- stops at the first UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan        jsonb;
  n_plan      int;
  fp          text;
  n           int;
  x           int;
  aud_max     bigint;
  aud_n       bigint;
BEGIN
  -- 1. Build the plan from live data
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
    WHERE r.batch_id = 10
  ) q;

  -- 2. Pre-checks
  IF n_plan <> 18 THEN RAISE EXCEPTION 'plan rows % (expected 18)', n_plan; END IF;
  IF fp <> 'dddd1ec271c0602ba6e4162856fe7c47' THEN
    RAISE EXCEPTION 'plan fingerprint % differs from the Sep 28 read', fp; END IF;

  SELECT count(DISTINCT p.venue_id) INTO x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF x <> 18 THEN RAISE EXCEPTION 'distinct venues % (expected 18)', x; END IF;

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

  SELECT count(*) INTO x FROM slugs;                      IF x <> 12293 THEN RAISE EXCEPTION 'slugs before % (expected 12293)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1081 THEN RAISE EXCEPTION 'non-canonical before % (expected 1081)', x; END IF;
  SELECT count(*) INTO x FROM venues;                     IF x <> 11212 THEN RAISE EXCEPTION 'venues before % (expected 11212)', x; END IF;
  SELECT count(*) INTO x FROM awards;                     IF x <> 22241 THEN RAISE EXCEPTION 'awards before % (expected 22241)', x; END IF;
  SELECT count(*) INTO x FROM listings;                   IF x <> 11212 THEN RAISE EXCEPTION 'listings before % (expected 11212)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;                     IF x <> 142 THEN RAISE EXCEPTION 'blurbs before % (expected 142)', x; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 103770 THEN RAISE EXCEPTION 'audit_log before % (expected 103770)', aud_n; END IF;

  -- 3. Writes
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id
     AND s.city_slug = p.city_slug AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 18 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 18)', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text);
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 18 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 18)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM slugs;                        IF x <> 12311 THEN RAISE EXCEPTION 'slugs after % (expected 12311)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;   IF x <> 1099 THEN RAISE EXCEPTION 'non-canonical after % (expected 1099)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;       IF x <> 11212 THEN RAISE EXCEPTION 'canonical after % (expected 11212)', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND NOT s.is_canonical);
  IF x <> 18 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 18)', x; END IF;

  SELECT count(*) INTO x FROM venues;   IF x <> 11212 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;   IF x <> 22241 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings; IF x <> 11212 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;   IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'UPDATE';
  IF x <> 18 THEN RAISE EXCEPTION 'audit slug updates % (expected 18)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'INSERT';
  IF x <> 18 THEN RAISE EXCEPTION 'audit slug inserts % (expected 18)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 36 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 36)', x; END IF;
END
$do$;
COMMIT;
