-- cities-display-waiheke-wanaka-dakovo-2026-10-30.sql
-- CompassEats, Oct 30 2026. Open item 1 of handoff-open-items-b1-done-2026-10-30: city display names.
-- Ben: Oct 30 20:53 ET "A" (change the display name only; city slugs and venue slugs stay).
--
-- What this file does (one transaction, one DO block): updates cities.display for 3 cities.
--   ci_d43edfbc8a  Waiheke -> Waiheke Island  (Mudbrick card: "126 Church Bay Road, Oneroa, Waiheke Island, 1971, New Zealand")
--   ci_daf6d172be  Wanaka  -> Wānaka          (Paloma Taqueria card: "28 Helwick Street, Wānaka, 9305, New Zealand"; site also Wānaka)
--   ci_f568968b3d  Dakovo  -> Đakovo          (Bistro Loora card: "Ul. Ivana Pavla II 5, Đakovo, 31400, Croatia")
--   Cards read Oct 30 (WebFetch, Ben approved each). Slugs (waiheke, wanaka, dakovo), ids, regions and venues_count do not
--   change. city_label_source rows (Michelin "Waiheke", "Wanaka", "Dakovo") are source labels and do not change.
--   No ledger row (a city display has no publisher, as in earlier city files). trg_audit_cities writes 3 UPDATE rows.
-- Built by script (docs/open-items-b1-build/build_city_labels.py) from the Oct 31 ~00:55 UTC read; guards: each new
--   display is in its card address line, starts with the old display (lower case, accents off), and matches the card
--   URL city segment.
-- Gates (PRE): counts; md5 of the 3 city rows 490a09e68db3179b890accc4cce2d783 (id|slug|display|country|country_iso|kind|region|venues_count,
--              by id, newline); no other city or alias uses a new display.
-- Gates (POST): counts; md5 of id|display bbe46bb99795b700eef6aece1a07030a; 3 audit rows, display only; stage-job resolution of the
--               old and new labels (with country) gives exactly the same city as before.
-- Expected: audit_log 113,703 -> 113,706 rows, last id 118,987 -> 118,990. cities 3,263, slugs 12,915 unchanged.
-- Dry run: send through the Read connector. It stops at the first UPDATE with "read-only transaction".

BEGIN;
DO $cdn$
DECLARE
  plan     jsonb;
  x        int;
  t        text;
  aud_max  bigint;
BEGIN
  SELECT jsonb_agg(jsonb_build_object('id', v.id, 'old', v.old, 'new', v.new, 'url', v.url) ORDER BY v.id) INTO plan
  FROM (VALUES
    ('ci_d43edfbc8a', 'Waiheke', 'Waiheke Island', 'https://guide.michelin.com/us/en/north-island/waiheke-island_2305319/restaurant/mudbrick'),
    ('ci_daf6d172be', 'Wanaka', 'Wānaka', 'https://guide.michelin.com/us/en/south-island/wanaka_2306683/restaurant/paloma-taqueria'),
    ('ci_f568968b3d', 'Dakovo', 'Đakovo', 'https://guide.michelin.com/us/en/osijek-baranja/dakovo_1784403/restaurant/bistro-loora')
  ) AS v(id, old, new, url);

  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;            IF x <> 3263  THEN RAISE EXCEPTION 'cities before % (expected 3263)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;      IF x <> 262   THEN RAISE EXCEPTION 'city_aliases before % (expected 262)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12915 THEN RAISE EXCEPTION 'slugs before % (expected 12915)', x; END IF;
  SELECT count(*) INTO x FROM venues;            IF x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 24005 THEN RAISE EXCEPTION 'city_label_source before % (expected 24005)', x; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;
  IF x <> 113703 THEN RAISE EXCEPTION 'audit_log before % (expected 113703)', x; END IF;
  IF aud_max <> 118987 THEN RAISE EXCEPTION 'audit_log last id % (expected 118987)', aud_max; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id))
    INTO t FROM cities c JOIN jsonb_to_recordset(plan) p(id text) ON p.id = c.id;
  IF t IS DISTINCT FROM '490a09e68db3179b890accc4cce2d783' THEN RAISE EXCEPTION 'city rows changed since the read: %', t; END IF;

  SELECT count(*) INTO x FROM cities c, jsonb_to_recordset(plan) p(id text, new text)
   WHERE c.id <> p.id AND (c.display = p.new
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = btrim(regexp_replace(lower(f_unaccent(p.new)), '[^a-z0-9]+', ' ', 'g'))
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g'))    = btrim(regexp_replace(lower(f_unaccent(p.new)), '[^a-z0-9]+', ' ', 'g')));
  IF x <> 0 THEN RAISE EXCEPTION 'new display used by % other cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a, jsonb_to_recordset(plan) p(id text, new text)
   WHERE a.city_id <> p.id AND a.alias = btrim(regexp_replace(lower(f_unaccent(p.new)), '[^a-z0-9]+', ' ', 'g'));
  IF x <> 0 THEN RAISE EXCEPTION 'new display is an alias of % other cities', x; END IF;

  ---------------------------------------------------------------- WRITE
  UPDATE cities c SET display = p.new
    FROM jsonb_to_recordset(plan) p(id text, old text, new text)
   WHERE c.id = p.id AND c.display = p.old;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'cities updated % (expected 3)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT md5(string_agg(c.id||'|'||c.display, E'\n' ORDER BY c.id)) INTO t
    FROM cities c JOIN jsonb_to_recordset(plan) p(id text) ON p.id = c.id;
  IF t IS DISTINCT FROM 'bbe46bb99795b700eef6aece1a07030a' THEN RAISE EXCEPTION 'id|display after % differs from the file', t; END IF;

  SELECT count(*) INTO x FROM cities;            IF x <> 3263  THEN RAISE EXCEPTION 'cities changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;      IF x <> 262   THEN RAISE EXCEPTION 'city_aliases changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12915 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM venues;            IF x <> 11304 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 24005 THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 3 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(id text, old text, new text) ON a.row_pk = p.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'UPDATE'
     AND a.old_row->>'display' = p.old AND a.new_row->>'display' = p.new
     AND (a.old_row - 'display') = (a.new_row - 'display');
  IF x <> 3 THEN RAISE EXCEPTION 'audit city updates (display only) % (expected 3)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter): old and new labels each give
  -- exactly the planned city.
  WITH lab(n_full, country, want) AS (VALUES
         ('waiheke', 'new zealand', 'ci_d43edfbc8a'), ('waiheke island', 'new zealand', 'ci_d43edfbc8a'),
         ('wanaka', 'new zealand', 'ci_daf6d172be'), ('dakovo', 'croatia', 'ci_f568968b3d')),
  cand AS (
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, a.city_id FROM lab h JOIN city_aliases a ON a.alias = h.n_full),
  hit AS (
    SELECT h.n_full, h.want, count(ci.id) n, min(ci.id) got
      FROM lab h LEFT JOIN cand c ON c.n_full = h.n_full
      LEFT JOIN cities ci ON ci.id = c.id AND btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = h.country
     GROUP BY h.n_full, h.want)
  SELECT count(*) INTO x FROM hit WHERE n <> 1 OR got IS DISTINCT FROM want;
  IF x <> 0 THEN RAISE EXCEPTION 'label resolution wrong for % labels', x; END IF;

  RAISE NOTICE 'OK: 3 city displays updated, 3 audit rows after id %', aud_max;
END
$cdn$;
COMMIT;
