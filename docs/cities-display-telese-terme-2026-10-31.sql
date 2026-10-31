-- cities-display-telese-terme-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 5, file 1 of 2 (held-P2 city item: Telese).
-- Ben: Oct 31 00:21 ET "Go with your recommendations" (D2 A: display name only; the slug telese stays, as Waiheke Island).
-- RUN FIRST (Write connector). File 2 expects this file's audit row (last id 119372).
--
-- What this file does (one transaction, one DO block): updates cities.display for 1 city.
--   ci_845e30f4ce  Telese -> Telese Terme
--   Evidence: Michelin cards read Oct 31 (WebFetch): Krèsios "Via San Giovanni 59, Telese Terme, 82037, Italy";
--   La Locanda del Borgo "Località Monte Pugliano 1, Telese Terme, 82037, Italy"; card URL city telese-terme_1850913.
--   The alias "telese terme" already points to ci_845e30f4ce. Slug, id, region and venues_count do not change.
--   city_label_source rows are source labels and do not change. No ledger row. trg_audit_cities writes 1 UPDATE row.
-- Built by script (docs/open-items-b5-build/build_open_items_b5_2026_10_31.py) from relay.txt (sha256 f266ea0ed5133a5f4d95cfec70a94827fab8a130cda791cab5179a08f19742bb).
-- Gates (PRE): counts; md5 of the city row 4d8c7d99db02b55ea043c4e7481e4f13; no other city or alias uses the new display.
-- Gates (POST): counts; md5 of id|display d2715fc9134611a1121804f41ab91c1b; 1 audit row, display only; stage-job resolution of
--               "telese" and "telese terme" (Italy) gives exactly ci_845e30f4ce.
-- Expected: audit_log 114,087 -> 114,088 rows, last id 119,371 -> 119,372.
-- Dry run: send through the Read connector. It stops at the UPDATE with "read-only transaction".

BEGIN;
DO $tt$
DECLARE
  x       bigint;
  t       text;
  aud_max bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;            IF x <> 3259  THEN RAISE EXCEPTION 'cities before % (expected 3259)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;      IF x <> 265   THEN RAISE EXCEPTION 'city_aliases before % (expected 265)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12936 THEN RAISE EXCEPTION 'slugs before % (expected 12936)', x; END IF;
  SELECT count(*) INTO x FROM venues;            IF x <> 11303 THEN RAISE EXCEPTION 'venues before % (expected 11303)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 24003 THEN RAISE EXCEPTION 'city_label_source before % (expected 24003)', x; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;
  IF x <> 114087 THEN RAISE EXCEPTION 'audit_log before % (expected 114087)', x; END IF;
  IF aud_max <> 119371 THEN RAISE EXCEPTION 'audit_log last id % (expected 119371)', aud_max; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.id = 'ci_845e30f4ce';
  IF t IS DISTINCT FROM '4d8c7d99db02b55ea043c4e7481e4f13' THEN RAISE EXCEPTION 'city row changed since the read: %', t; END IF;

  SELECT count(*) INTO x FROM cities c
   WHERE c.id <> 'ci_845e30f4ce' AND (c.display = 'Telese Terme'
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = 'telese terme'
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = 'telese terme');
  IF x <> 0 THEN RAISE EXCEPTION 'new display used by % other cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a WHERE a.city_id <> 'ci_845e30f4ce' AND a.alias = 'telese terme';
  IF x <> 0 THEN RAISE EXCEPTION 'new display is an alias of % other cities', x; END IF;

  ---------------------------------------------------------------- WRITE
  UPDATE cities SET display = 'Telese Terme' WHERE id = 'ci_845e30f4ce' AND slug = 'telese' AND display = 'Telese';
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'cities updated % (expected 1)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT md5(c.id||'|'||c.display) INTO t FROM cities c WHERE c.id = 'ci_845e30f4ce';
  IF t IS DISTINCT FROM 'd2715fc9134611a1121804f41ab91c1b' THEN RAISE EXCEPTION 'id|display after % differs from the file', t; END IF;
  SELECT count(*) INTO x FROM cities;            IF x <> 3259  THEN RAISE EXCEPTION 'cities changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;      IF x <> 265   THEN RAISE EXCEPTION 'city_aliases changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12936 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM venues;            IF x <> 11303 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 24003 THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;   IF x <> 10934 THEN RAISE EXCEPTION 'venues_count sum changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 1 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'UPDATE' AND a.row_pk = 'ci_845e30f4ce'
     AND a.old_row->>'display' = 'Telese' AND a.new_row->>'display' = 'Telese Terme'
     AND (a.old_row - 'display') = (a.new_row - 'display');
  IF x <> 1 THEN RAISE EXCEPTION 'audit city update (display only) % (expected 1)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter IT): each label gives exactly ci_845e30f4ce.
  WITH lab(n_full) AS (VALUES ('telese'), ('telese terme')),
  cand AS (
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, a.city_id FROM lab h JOIN city_aliases a ON a.alias = h.n_full),
  hit AS (
    SELECT h.n_full, count(ci.id) n, min(ci.id) got
      FROM lab h LEFT JOIN cand c ON c.n_full = h.n_full LEFT JOIN cities ci ON ci.id = c.id AND ci.country_iso = 'IT'
     GROUP BY h.n_full)
  SELECT count(*) INTO x FROM hit WHERE n <> 1 OR got IS DISTINCT FROM 'ci_845e30f4ce';
  IF x <> 0 THEN RAISE EXCEPTION 'label resolution wrong for % labels', x; END IF;

  RAISE NOTICE 'OK: 1 city display updated, 1 audit row after id %', aud_max;
END
$tt$;
COMMIT;
