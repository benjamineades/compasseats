-- cities-michelin-2026-american-south.sql
-- CompassEats, American South 2026 stage preparation, Step A (chat Oct 27, 2026).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts 3 US cities. The pre-stage simulation (input md5 00af1fae1ee5fc4e41b3d1134cf3611a) found no
--      city row, display, slug or alias for these card labels (CSV fixtures/ingest/michelin-2026-american-south.csv,
--      sha256 109075a5...b07f3, data lines 11, 59, 67):
--        Gay, GA (Uberto Restaurant), Carrboro, NC (Tesoro), Bluffton, SC (Okan).
--      Labels are written from the CSV by script as ASCII U&'...' literals. A guard checks their md5 against the CSV.
--        slug = trim(both '-' from regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+','-','g'))   (Ben Q2 = A: plain slugs)
--        id   = 'ci_' || left(md5(slug), 10)   (rule of the Netherlands and Germany inserts)
--        country 'United States', country_iso 'US', kind 'city', region_id NULL, lat/lng NULL, venues_count 0
--      trg_audit_cities writes 3 INSERT audit rows.
--   2. Ben Q1 = A: 2 aliases to existing cities, so the card labels resolve:
--        "birmingham" -> ci_bb460cdc18 "Birmingham, Alabama" (card lines 24-27)
--        "knoxville"  -> ci_e154900e69 "Knoxville, Tennessee" (card line 72)
--      A UK row "Birmingham" still resolves to ci_441fd9b294: the stage job keeps only the candidate whose
--      country agrees with the row's country_label. city_aliases has no audit trigger, so the file writes
--      2 hand audit rows (row_pk = alias, action INSERT).
--   No ledger row (a city row has no publisher).
--
-- Gates (PRE): counts (cities 3259, city_aliases 259), source md5, plan md5, no id/slug/display/alias clash for the
--              new cities, the 2 aliases do not exist, their target cities exist and are US, no other US city
--              already answers to the alias, no ingest batch for michelin-2026-american-south yet.
-- Gates (POST): counts (3262, 261), 5 new audit rows with the right table/action/row_pk, and the stage-job city
--               resolution (slug, display, alias, then the country filter) for 11 card labels + 2 UK controls gives
--               exactly the expected city.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

DO $ascities$
DECLARE
  c_cities_before  constant int  := 3259;
  c_alias_before   constant int  := 259;
  c_cities_after   constant int  := 3262;
  c_alias_after    constant int  := 261;
  c_src_md5        constant text := 'ee67d263d24c1f7d6dc1f6cd697b44ad';  -- line|city_label|country_label|state_label, lines 11,24,59,67,72, newline
  c_plan_md5       constant text := '37e8feec37056262d2d9ff1e536c784d';  -- id|slug|display|country|US, by line, newline
  c_line     constant int[]  := ARRAY[11, 59, 67];
  c_label    constant text[] := ARRAY[U&'Gay', U&'Carrboro', U&'Bluffton'];
  c_country  constant text[] := ARRAY[U&'United States', U&'United States', U&'United States'];
  c_display  constant text[] := ARRAY[U&'Gay', U&'Carrboro', U&'Bluffton'];
  c_state    constant text[] := ARRAY[U&'GA', U&'NC', U&'SC'];
  a_line     constant int[]  := ARRAY[24, 72];
  a_label    constant text[] := ARRAY[U&'Birmingham', U&'Knoxville'];
  a_alias    constant text[] := ARRAY[U&'birmingham', U&'knoxville'];
  a_city     constant text[] := ARRAY[U&'ci_bb460cdc18', U&'ci_e154900e69'];
  a_state    constant text[] := ARRAY[U&'AL', U&'TN'];
  v_n      int;
  v_m      int;
  v_txt    text;
  v_audit0 bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO v_n FROM cities;
  IF v_n <> c_cities_before THEN RAISE EXCEPTION 'PRE cities count % <> %', v_n, c_cities_before; END IF;
  SELECT count(*) INTO v_n FROM city_aliases;
  IF v_n <> c_alias_before THEN RAISE EXCEPTION 'PRE city_aliases count % <> %', v_n, c_alias_before; END IF;

  SELECT count(*) INTO v_n FROM ingest_batches WHERE batch_key = 'michelin-2026-american-south';
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE a michelin-2026-american-south batch already exists'; END IF;

  SELECT md5(string_agg(s.line || '|' || s.label || '|United States|' || s.st, E'\n' ORDER BY s.line)), count(*) INTO v_txt, v_n
    FROM (SELECT * FROM unnest(c_line, c_label, c_state) AS t(line, label, st)
          UNION ALL SELECT * FROM unnest(a_line, a_label, a_state) AS t(line, label, st)) s;
  IF v_n <> 5 THEN RAISE EXCEPTION 'PRE source rows % <> 5', v_n; END IF;
  IF v_txt IS DISTINCT FROM c_src_md5 THEN RAISE EXCEPTION 'PRE source md5 % <> %', v_txt, c_src_md5; END IF;

  WITH as_city_plan AS (SELECT t.line, t.label, t.country, t.display, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display) AS t(line, label, country, display))
  SELECT md5(string_agg(id || '|' || slug || '|' || display || '|' || country || '|US', E'\n' ORDER BY line)), count(*) INTO v_txt, v_n FROM as_city_plan;
  IF v_n <> 3 THEN RAISE EXCEPTION 'PRE plan rows % <> 3', v_n; END IF;
  IF v_txt IS DISTINCT FROM c_plan_md5 THEN RAISE EXCEPTION 'PRE plan md5 % <> %', v_txt, c_plan_md5; END IF;

  -- New cities: no clash on id, slug, normalised display/slug of any existing city, or an existing alias.
  WITH as_city_plan AS (SELECT t.line, t.label, t.country, t.display, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display) AS t(line, label, country, display))
  SELECT count(*) INTO v_n FROM as_city_plan p
   WHERE EXISTS (SELECT 1 FROM cities c
                  WHERE c.id = p.id OR c.slug = p.slug
                     OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (p.n_display, btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g')))
                     OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g'))    IN (p.n_display, btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g'))))
      OR EXISTS (SELECT 1 FROM city_aliases a WHERE a.alias IN (p.n_display, btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g'))));
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE % planned cities clash with an existing city or alias', v_n; END IF;

  -- Aliases: normalised form of the card label, not yet used, target city exists and is US,
  -- and no US city already answers to the alias by slug or display.
  WITH as_alias_plan AS (SELECT t.line, t.label, t.alias, t.city_id FROM unnest(a_line, a_label, a_alias, a_city) AS t(line, label, alias, city_id))
  SELECT count(*) INTO v_n FROM as_alias_plan p
   WHERE p.alias = btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g'))
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.alias = p.alias)
     AND EXISTS (SELECT 1 FROM cities c WHERE c.id = p.city_id AND c.country_iso = 'US')
     AND NOT EXISTS (SELECT 1 FROM cities c WHERE c.country_iso = 'US' AND (btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = p.alias OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = p.alias));
  IF v_n <> 2 THEN RAISE EXCEPTION 'PRE alias rows that pass % <> 2', v_n; END IF;

  SELECT max(id) INTO v_audit0 FROM audit_log;

  ---------------------------------------------------------------- WRITE 1: insert the 3 cities
  WITH as_city_plan AS (SELECT t.line, t.label, t.country, t.display, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display) AS t(line, label, country, display))
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT p.id, p.slug, p.display, p.country, 'US', 'city', NULL, NULL, NULL, 0
    FROM as_city_plan p
   ORDER BY p.line;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'WRITE city insert % <> 3', v_n; END IF;

  ---------------------------------------------------------------- WRITE 2: insert the 2 aliases + hand audit rows
  WITH as_alias_plan AS (SELECT t.line, t.label, t.alias, t.city_id FROM unnest(a_line, a_label, a_alias, a_city) AS t(line, label, alias, city_id))
  INSERT INTO city_aliases (alias, city_id)
  SELECT p.alias, p.city_id FROM as_alias_plan p ORDER BY p.line;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'WRITE alias insert % <> 2', v_n; END IF;

  WITH as_alias_plan AS (SELECT t.line, t.label, t.alias, t.city_id FROM unnest(a_line, a_label, a_alias, a_city) AS t(line, label, alias, city_id))
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a)
    FROM city_aliases a JOIN as_alias_plan p ON p.alias = a.alias AND p.city_id = a.city_id
   ORDER BY p.line;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'WRITE hand audit rows % <> 2', v_n; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO v_n FROM cities;
  IF v_n <> c_cities_after THEN RAISE EXCEPTION 'POST cities count % <> %', v_n, c_cities_after; END IF;
  SELECT count(*) INTO v_n FROM city_aliases;
  IF v_n <> c_alias_after THEN RAISE EXCEPTION 'POST city_aliases count % <> %', v_n, c_alias_after; END IF;

  -- 5 new audit rows: 3 cities INSERT (row_pk = new id, trigger), 2 city_aliases INSERT (row_pk = alias, hand).
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0;
  IF v_n <> 5 THEN RAISE EXCEPTION 'POST new audit rows % <> 5', v_n; END IF;
  WITH as_city_plan AS (SELECT t.line, t.label, t.country, t.display, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display) AS t(line, label, country, display))
  SELECT count(*) INTO v_n FROM audit_log l JOIN as_city_plan p ON p.id = l.row_pk
   WHERE l.id > v_audit0 AND l.table_name = 'cities' AND l.action = 'INSERT' AND l.old_row IS NULL;
  IF v_n <> 3 THEN RAISE EXCEPTION 'POST city audit rows % <> 3', v_n; END IF;
  WITH as_alias_plan AS (SELECT t.line, t.label, t.alias, t.city_id FROM unnest(a_line, a_label, a_alias, a_city) AS t(line, label, alias, city_id))
  SELECT count(*) INTO v_n FROM audit_log l JOIN as_alias_plan p ON p.alias = l.row_pk
   WHERE l.id > v_audit0 AND l.table_name = 'city_aliases' AND l.action = 'INSERT' AND l.old_row IS NULL;
  IF v_n <> 2 THEN RAISE EXCEPTION 'POST alias audit rows % <> 2', v_n; END IF;

  -- Stage-job city resolution (resolve.ts: slug, display, alias; then keep the candidates whose country agrees
  -- with the row's country_label). Each label must keep exactly one candidate, the expected city, and no
  -- candidate may lack a country (that would change the job's three-valued filter).
  WITH lab AS (
    SELECT w.line, w.city_id AS want,
           btrim(regexp_replace(lower(f_unaccent(w.label)), '[^a-z0-9]+', ' ', 'g'))                       AS n_full,
           btrim(regexp_replace(lower(f_unaccent(split_part(w.label, ',', 1))), '[^a-z0-9]+', ' ', 'g'))  AS n_head,
           btrim(regexp_replace(lower(f_unaccent(w.country)), '[^a-z0-9]+', ' ', 'g'))                     AS n_country
      FROM (VALUES
           (24, U&'Birmingham', U&'United States', 'ci_bb460cdc18'),
           (25, U&'Birmingham', U&'United States', 'ci_bb460cdc18'),
           (72, U&'Knoxville', U&'United States', 'ci_e154900e69'),
           (11, U&'Gay', U&'United States', 'ci_6e11873b9d'),
           (59, U&'Carrboro', U&'United States', 'ci_c7f1c6ece1'),
           (67, U&'Bluffton', U&'United States', 'ci_4468453fa6'),
           (55, U&'Oxford', U&'United States', 'ci_6aea4728c1'),
           (53, U&'Jackson', U&'United States', 'ci_b41779690b'),
           (20, U&'Greenville', U&'United States', 'ci_6e008b78b8'),
           (62, U&'Durham', U&'United States', 'ci_e2af7e5615'),
           (3, U&'Atlanta', U&'United States', 'ci_57c6cbff0d'),
           (9001, U&'Birmingham', U&'United Kingdom', 'ci_441fd9b294'),
           (9002, U&'Oxford', U&'United Kingdom', 'ci_aa4eceb101')
      ) AS w(line, label, country, city_id)
  ), cand AS (
    SELECT h.line, c.id AS city_id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.line, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.line, a.city_id FROM lab h JOIN city_aliases a ON a.alias IN (h.n_full, h.n_head)
  ), got AS (
    SELECT l.line, l.want,
           count(c.city_id) FILTER (WHERE lower(ci.country_iso) = l.n_country OR btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = l.n_country) AS n_keep,
           min(c.city_id)   FILTER (WHERE lower(ci.country_iso) = l.n_country OR btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = l.n_country) AS city_id,
           count(c.city_id) FILTER (WHERE ci.country IS NULL AND ci.country_iso IS NULL) AS n_nocountry
      FROM lab l LEFT JOIN cand c ON c.line = l.line LEFT JOIN cities ci ON ci.id = c.city_id
     GROUP BY l.line, l.want
  )
  SELECT count(*) FILTER (WHERE n_keep IS DISTINCT FROM 1 OR city_id IS DISTINCT FROM want OR n_nocountry <> 0),
         count(*)
    INTO v_n, v_m FROM got;
  IF v_m <> 13 THEN RAISE EXCEPTION 'POST resolution rows % <> 13', v_m; END IF;
  IF v_n <> 0 THEN RAISE EXCEPTION 'POST % card labels do not resolve to exactly the expected city', v_n; END IF;

  RAISE NOTICE 'OK: 3 cities and 2 aliases inserted, 5 audit rows after id %', v_audit0;
END
$ascities$;
