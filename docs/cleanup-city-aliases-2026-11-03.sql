-- cleanup-city-aliases-2026-11-03.sql
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
  del constant text[] := ARRAY['argentina','canada','france','ireland','mexico','united states','us','usa','friuli venezia','gipuzkoa','grisons','huelva','powys','rugen','sicily','south wales','udine','malfa salina','sankt niklausen','vernazza','windermere','blackburn','collingwood','cupar','exmouth','grange over sands','hexham','hythe','iwade','lamporecchio','lens','maidenhead','monmouth','moutfort','nonoichi','ormskirk','sedlec u mikulova','silvaplana','sorengo','suita'];
BEGIN
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 119764 OR aud_max <> 125593 THEN RAISE EXCEPTION 'audit before % / %', aud_n, aud_max; END IF;
  SELECT count(*), max(id) INTO x, n FROM source_capture_ledger;
  IF x <> 194 OR n <> 248 THEN RAISE EXCEPTION 'ledger before % / %', x, n; END IF;
  IF (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'aliases before'; END IF;
  SELECT md5(string_agg(alias||'|'||city_id, E'\n' ORDER BY alias COLLATE "C")) INTO s FROM city_aliases;
  IF s IS DISTINCT FROM 'ed6d96c60ee642e0fb8e7e4e68101d29' THEN RAISE EXCEPTION 'all alias fingerprint %', s; END IF;
  SELECT md5(string_agg(alias||'|'||city_id, E'\n' ORDER BY alias COLLATE "C")) INTO s FROM city_aliases WHERE alias = ANY (del);
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
     AND regexp_replace(replace(regexp_replace((regexp_match(a.source_url,'/([^/]+)/restaurant/[^/]+/?$'))[1],'[_0-9]+$',''),'-',' '),'\s+$','') = ANY (del);
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
