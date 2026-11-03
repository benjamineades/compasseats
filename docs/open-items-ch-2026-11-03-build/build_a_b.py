import json,hashlib
from lists import *
SQ=lambda s:"'"+s.replace("'","''")+"'"
arr=lambda L:"ARRAY["+",".join(SQ(x) for x in L)+"]"
A=f"""-- cleanup-city-aliases-2026-11-03.sql
-- CompassEats, Nov 3 2026. Swiss open item 1: worldwide alias check. Population: all 262 rows of city_aliases.
-- Deletes 40 aliases: 8 country names, 9 region or province names, 4 wrong places, 19 separate towns.
-- Rule: Ben's standing rule (alias keys must not hold region or country names) and the Oct 31 precedent (alias only for a place inside the city, none for separate towns).
-- Every deleted alias has 0 city labels and 0 Michelin card segments. No venue, award, slug or city changes. No ledger row (precedent: docs/cities-michelin-2026-switzerland-2026-11-02.sql).
-- city_aliases has no audit trigger: 40 hand audit rows, row_pk = alias, before the delete.
-- Evidence: docs/open-items-ch-2026-11-03-build/alias-check-262.csv
-- Expected after: city_aliases 222; audit_log 119,804 rows, last id 125,633.
BEGIN;
DO $do$
DECLARE
  n int; x bigint; s text; aud_max bigint; aud_n bigint;
  del constant text[] := {arr(DEL)};
BEGIN
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 119764 OR aud_max <> 125593 THEN RAISE EXCEPTION 'audit before % / %', aud_n, aud_max; END IF;
  SELECT count(*), max(id) INTO x, n FROM source_capture_ledger;
  IF x <> 194 OR n <> 248 THEN RAISE EXCEPTION 'ledger before % / %', x, n; END IF;
  IF (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'aliases before'; END IF;
  SELECT md5(string_agg(alias||'|'||city_id, E'\\n' ORDER BY alias COLLATE "C")) INTO s FROM city_aliases;
  IF s IS DISTINCT FROM 'ed6d96c60ee642e0fb8e7e4e68101d29' THEN RAISE EXCEPTION 'all alias fingerprint %', s; END IF;
  SELECT md5(string_agg(alias||'|'||city_id, E'\\n' ORDER BY alias COLLATE "C")) INTO s FROM city_aliases WHERE alias = ANY (del);
  IF s IS DISTINCT FROM 'fedf06e27945b23787387829d4edcc9e' THEN RAISE EXCEPTION 'delete fingerprint %', s; END IF;
  IF (SELECT count(*) FROM city_aliases WHERE alias = ANY (del)) <> 40 THEN RAISE EXCEPTION 'delete rows'; END IF;
  -- No city label uses a deleted alias (importer normLabel, whole label and part before the first comma; country labels excluded)
  SELECT count(*) INTO x FROM city_label_source l
   WHERE l.from_column::text <> 'country'
     AND (btrim(regexp_replace(lower(f_unaccent(l.label)), '[^a-z0-9]+',' ','g')) = ANY (del)
       OR btrim(regexp_replace(lower(f_unaccent(split_part(l.label,',',1))), '[^a-z0-9]+',' ','g')) = ANY (del));
  IF x <> 0 THEN RAISE EXCEPTION 'city labels that use a deleted alias: %', x; END IF;
  -- No Michelin card has a deleted alias as its city segment
  SELECT count(*) INTO x FROM awards a
   WHERE a.source_id='michelin' AND a.source_url LIKE '%/restaurant/%'
     AND regexp_replace(replace(regexp_replace((regexp_match(a.source_url,'/([^/]+)/restaurant/[^/]+/?$'))[1],'[_0-9]+$',''),'-',' '),'\\s+$','') = ANY (del);
  IF x <> 0 THEN RAISE EXCEPTION 'Michelin cards with a deleted alias as city segment: %', x; END IF;

  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'DELETE', to_jsonb(a), NULL FROM city_aliases a WHERE a.alias = ANY (del) ORDER BY a.alias;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 40 THEN RAISE EXCEPTION 'audit rows %', n; END IF;
  DELETE FROM city_aliases WHERE alias = ANY (del);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 40 THEN RAISE EXCEPTION 'deleted %', n; END IF;

  IF (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'aliases after'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max; IF x <> 40 THEN RAISE EXCEPTION 'audit after %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='city_aliases' AND action='DELETE'; IF x <> 40 THEN RAISE EXCEPTION 'audit table %', x; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM cities) <> 3279 OR (SELECT sum(venues_count) FROM cities) <> 11028 OR (SELECT count(*) FROM city_label_source) <> 24047 THEN RAISE EXCEPTION 'other tables changed'; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open('cleanup-city-aliases-2026-11-03.sql','w').write(A)
ids=arr(SLUG_IDS)
FU="trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))"
B=f"""-- slugs-letters-removed-2026-11-03.sql
-- CompassEats, Nov 3 2026. Swiss open item 2: canonical slugs that lost a letter (ø, æ, œ, ß, Đ) under the importer slugify.
-- Population: canonical slugs of venues whose name holds one of these letters (52 venues, 22 differ from the f_unaccent slug). Switzerland: 0 left (Nov 3 slug file).
-- New slug rule as docs/slugs-rename-michelin-2026-switzerland.sql. Old slugs stay as non-canonical and keep working. No row is deleted. No ledger row.
-- Run after cleanup-city-aliases-2026-11-03.sql.
-- Expected after: slugs 13,166, canonical 11,320, non-canonical 1,846; audit +44 (119,848 rows, last id 125,677).
BEGIN;
DO $do$
DECLARE
  plan jsonb; n_plan int; fp text; n int; x bigint; aud_max bigint; aud_n bigint;
  ids constant text[] := {ids};
BEGIN
  SELECT jsonb_agg(jsonb_build_object('venue_id',q.id,'city_slug',q.city_slug,'old_slug',q.slug,'new_slug',q.new_slug) ORDER BY q.id),
         count(*), md5(string_agg(q.id||'|'||q.name||'|'||q.city_slug||'|'||q.slug||'|'||q.new_slug, E'\\n' ORDER BY q.id))
    INTO plan, n_plan, fp
    FROM (SELECT v.id, v.name, s.city_slug, s.slug, {FU} AS new_slug
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
"""
open('slugs-letters-removed-2026-11-03.sql','w').write(B)
