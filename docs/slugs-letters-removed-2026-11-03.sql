-- slugs-letters-removed-2026-11-03.sql
-- CompassEats, Nov 3 2026. Swiss open item 2: canonical slugs that lost a letter (ø, æ, œ, ß, Đ) under the importer slugify.
-- Population: canonical slugs of venues whose name holds one of these letters (52 venues, 22 differ from the f_unaccent slug). Switzerland: 0 left (Nov 3 slug file).
-- New slug rule as docs/slugs-rename-michelin-2026-switzerland.sql. Old slugs stay as non-canonical and keep working. No row is deleted. No ledger row.
-- Run after cleanup-city-aliases-2026-11-03.sql.
-- Expected after: slugs 13,166, canonical 11,320, non-canonical 1,846; audit +44 (119,848 rows, last id 125,677).
BEGIN;
DO $do$
DECLARE
  plan jsonb; n_plan int; fp text; n int; x bigint; aud_max bigint; aud_n bigint;
  ids constant text[] := ARRAY['ve_a94f2f6ed8','ve_919a374540','ve_0c96433ef6','ve_11f934752e','ve_f2481e3a83','ve_412e1716a6','ve_45799580db','ve_a135a5ab21','ve_5687d452d7','ve_4cd4d4f10c','ve_942665156f','ve_2cceeaa14d','ve_7a698e2407','ve_45c8f2ca58','ve_b304753456','ve_a19a34aecc','ve_668891bdf1','ve_78cf71c1a8','ve_efa1111ae7','ve_6f0a0de9e3','ve_e505f66f71','ve_25fc60c8fe'];
BEGIN
  SELECT jsonb_agg(jsonb_build_object('venue_id',q.id,'city_slug',q.city_slug,'old_slug',q.slug,'new_slug',q.new_slug) ORDER BY q.id),
         count(*), md5(string_agg(q.id||'|'||q.name||'|'||q.city_slug||'|'||q.slug||'|'||q.new_slug, E'\n' ORDER BY q.id))
    INTO plan, n_plan, fp
    FROM (SELECT v.id, v.name, s.city_slug, s.slug, trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
            FROM venues v JOIN slugs s ON s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical
           WHERE v.id = ANY (ids)) q;
  IF n_plan <> 22 THEN RAISE EXCEPTION 'plan rows %', n_plan; END IF;
  IF fp <> 'c77a79adb222999da543b20e43d3bbf5' THEN RAISE EXCEPTION 'plan fingerprint %', fp; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(old_slug text,new_slug text) WHERE p.new_slug='' OR p.new_slug=p.old_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'empty or unchanged %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(city_slug text,new_slug text) JOIN slugs s ON s.property_id='eats' AND s.city_slug=p.city_slug AND s.slug=p.new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs in use %', x; END IF;
  SELECT count(*) INTO x FROM redirects d, jsonb_to_recordset(plan) p(city_slug text,new_slug text) WHERE d.from_path IN ('/'||p.city_slug||'/'||p.new_slug,'/venue/'||p.city_slug||'/'||p.new_slug);
  IF x <> 0 THEN RAISE EXCEPTION 'redirects %', x; END IF;
  IF (SELECT count(*) FROM slugs) <> 13144 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1824 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM awards) <> 25324 OR (SELECT count(*) FROM listings) <> 11320 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'aliases: run the alias file first'; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 119804 OR aud_max <> 125633 THEN RAISE EXCEPTION 'audit before % / %', aud_n, aud_max; END IF;

  UPDATE slugs s SET is_canonical=false FROM jsonb_to_recordset(plan) p(venue_id text,city_slug text,old_slug text)
   WHERE s.property_id='eats' AND s.venue_id=p.venue_id AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 22 THEN RAISE EXCEPTION 'updated %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true FROM jsonb_to_recordset(plan) p(venue_id text,city_slug text,new_slug text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 22 THEN RAISE EXCEPTION 'inserted %', n; END IF;

  IF (SELECT count(*) FROM slugs) <> 13166 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1846 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11320 THEN RAISE EXCEPTION 'slugs after'; END IF;
  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without 1 canonical %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max AND table_name='slugs' AND action='UPDATE'; IF x <> 22 THEN RAISE EXCEPTION 'audit update %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max AND table_name='slugs' AND action='INSERT'; IF x <> 22 THEN RAISE EXCEPTION 'audit insert %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max; IF x <> 44 THEN RAISE EXCEPTION 'audit %', x; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
