-- slugs-rename-michelin-2026-germany.sql
-- CompassEats, Oct 8 2026. Open item 1 (Germany cleanup handoff): new canonical slugs for the
-- Germany venues renamed by rename batch 12 (rename-michelin-2026-germany, 215 venues,
-- ledger 94, audit 108,284-108,498).
-- Template: docs/slugs-rename-michelin-2027-chengdu.sql (same method, same checks).
-- Method: gated SQL, one transaction, through the Supabase Write connector.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')),
-- the rule of the Chengdu file and of the Oct 8 German city inserts (grossheubach).
-- It equals scripts/ingest/lib/slug.ts on 212 of the 215 names. The 3 others: Cølbo (colbo),
-- Nußbaumerin (nussbaumerin), Ich weiß ein Haus am See (ich-weiss-ein-haus-am-see, = old slug).
-- 28 of the 215 venues keep their slug (new slug = old slug), so the plan has 187 rows.
-- For each plan venue: the old canonical row becomes non-canonical (old URL stays and points
-- to the same venue), and a new canonical row is inserted. No row is deleted.
-- No ledger row: a slug has no publisher. audit_log (trg_audit_slugs) is the record.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id,
-- joined by newline, only rows where new_slug <> old_slug), read Oct 9 after rename batch 12:
--   55bcb18710dbaf5c1fec07299b17ab82  (187 rows)
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the
-- first UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan        jsonb;
  n_plan      int;
  n_all       int;
  n_same      int;
  fp          text;
  n           int;
  x           int;
  aud_max     bigint;
  aud_n       bigint;
BEGIN
  -- 1. Build the plan from live data
  SELECT count(*), count(*) FILTER (WHERE q.new_slug = q.old_slug)
    INTO n_all, n_same
  FROM (
    SELECT s.slug AS old_slug,
           trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
    FROM rename_rows r
    JOIN venues v ON v.id = r.venue_id
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE r.batch_id = 12
  ) q;
  IF n_all <> 215 THEN RAISE EXCEPTION 'batch 12 venues with a canonical slug % (expected 215)', n_all; END IF;
  IF n_same <> 28 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 28)', n_same; END IF;

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
    WHERE r.batch_id = 12
  ) q
  WHERE q.new_slug <> q.old_slug;

  -- 2. Pre-checks
  IF n_plan <> 187 THEN RAISE EXCEPTION 'plan rows % (expected 187)', n_plan; END IF;
  IF fp <> '55bcb18710dbaf5c1fec07299b17ab82' THEN
    RAISE EXCEPTION 'plan fingerprint % differs from the Oct 9 read', fp; END IF;

  SELECT count(DISTINCT p.venue_id) INTO x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF x <> 187 THEN RAISE EXCEPTION 'distinct venues % (expected 187)', x; END IF;

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

  SELECT count(*) INTO x FROM slugs;                        IF x <> 12322 THEN RAISE EXCEPTION 'slugs before % (expected 12322)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1099 THEN RAISE EXCEPTION 'non-canonical before % (expected 1099)', x; END IF;
  SELECT count(*) INTO x FROM venues;                       IF x <> 11223 THEN RAISE EXCEPTION 'venues before % (expected 11223)', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 22389 THEN RAISE EXCEPTION 'awards before % (expected 22389)', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11223 THEN RAISE EXCEPTION 'listings before % (expected 11223)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;                       IF x <> 142 THEN RAISE EXCEPTION 'blurbs before % (expected 142)', x; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 104690 THEN RAISE EXCEPTION 'audit_log before % (expected 104690)', aud_n; END IF;
  IF aud_max <> 108498 THEN RAISE EXCEPTION 'audit_log last id % (expected 108498)', aud_max; END IF;

  -- 3. Writes
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id
     AND s.city_slug = p.city_slug AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 187 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 187)', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text);
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 187 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 187)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM slugs;                        IF x <> 12509 THEN RAISE EXCEPTION 'slugs after % (expected 12509)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1286 THEN RAISE EXCEPTION 'non-canonical after % (expected 1286)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11223 THEN RAISE EXCEPTION 'canonical after % (expected 11223)', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND NOT s.is_canonical);
  IF x <> 187 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 187)', x; END IF;

  SELECT count(*) INTO x FROM venues;   IF x <> 11223 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;   IF x <> 22389 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings; IF x <> 11223 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;   IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'UPDATE';
  IF x <> 187 THEN RAISE EXCEPTION 'audit slug updates % (expected 187)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'INSERT';
  IF x <> 187 THEN RAISE EXCEPTION 'audit slug inserts % (expected 187)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 374 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 374)', x; END IF;
END
$do$;
COMMIT;
