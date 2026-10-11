-- cities-michelin-2026-netherlands.sql
-- CompassEats, Netherlands 2026 stage preparation, Step A (chat Oct 11, 2026).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts 7 Dutch cities. The pre-stage simulation (input md5 7318a494...) found no city row,
--      display, slug or alias for these card labels (CSV fixtures/ingest/michelin-2026-netherlands.csv,
--      sha256 aa72b5e6...d7b2, data lines 6, 22, 29, 32, 44, 51, 103):
--        Schin op Geul (SUIS), Veeningen (Le Epifaan), Duiven ('t Raedthuys), Hoog Soeren (Wild Atelier),
--        Valkenburg (Ambrozijn), Mierlo (De Cuijt), Kortgene (Rozewied).
--      The labels are written from the CSV by script as ASCII U&'...' literals. A guard checks their md5
--      against the CSV (31c6f1d0d02bd12074db6f791acb809a).
--        slug = trim(both '-' from regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+','-','g'))
--        id   = 'ci_' || left(md5(slug), 10)   (rule of all 107 NL cities and the Germany insert, audit 107300-107306)
--        country 'Netherlands', country_iso 'NL', kind 'city', region_id NULL, lat/lng NULL, venues_count 0
--      trg_audit_cities writes 7 INSERT audit rows.
--   2. Ben, Oct 11 (Q2 = B): line 44 gets display "Valkenburg aan de Geul" (slug valkenburg-aan-de-geul),
--      plus the alias "valkenburg", so the card label "Valkenburg" resolves to it.
--      city_aliases has no audit trigger, so the file writes 1 hand audit row (row_pk = alias, action INSERT).
--   No ledger row (a city row has no publisher; same as the Germany city insert).
--
-- Gates (PRE): counts (cities 3251, city_aliases 258), source md5, plan md5, no id/slug/display/alias clash,
--              no ingest batch for michelin-2026-netherlands yet.
-- Gates (POST): counts (3258, 259), 8 new audit rows with the right table/action/row_pk, and the stage-job
--               city resolution (slug, display, alias, country hint) for the 7 labels + 4 control labels
--               gives exactly the expected NL city.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

DO $nlcities$
DECLARE
  c_cities_before  constant int  := 3251;
  c_alias_before   constant int  := 258;
  c_cities_after   constant int  := 3258;
  c_alias_after    constant int  := 259;
  c_src_md5        constant text := '31c6f1d0d02bd12074db6f791acb809a';  -- line|city_label|country_label, by line, newline
  c_plan_md5       constant text := '3856e2db396ff76b336cc39885d36fef';  -- id|slug|display|country|NL, by line, newline
  c_line     constant int[]  := ARRAY[6, 22, 29, 32, 44, 51, 103];
  c_label    constant text[] := ARRAY[U&'Schin op Geul', U&'Veeningen', U&'Duiven', U&'Hoog Soeren', U&'Valkenburg', U&'Mierlo', U&'Kortgene'];
  c_country  constant text[] := ARRAY[U&'Netherlands', U&'Netherlands', U&'Netherlands', U&'Netherlands', U&'Netherlands', U&'Netherlands', U&'Netherlands'];
  c_display  constant text[] := ARRAY[U&'Schin op Geul', U&'Veeningen', U&'Duiven', U&'Hoog Soeren', U&'Valkenburg aan de Geul', U&'Mierlo', U&'Kortgene'];
  c_alias    constant text[] := ARRAY[NULL, NULL, NULL, NULL, U&'valkenburg', NULL, NULL];
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

  SELECT count(*) INTO v_n FROM ingest_batches WHERE batch_key = 'michelin-2026-netherlands';
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE a michelin-2026-netherlands batch already exists'; END IF;

  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  SELECT md5(string_agg(line || '|' || label || '|' || country, E'\n' ORDER BY line)), count(*) INTO v_txt, v_n FROM nl_city_plan;
  IF v_n <> 7 THEN RAISE EXCEPTION 'PRE plan rows % <> 7', v_n; END IF;
  IF v_txt IS DISTINCT FROM c_src_md5 THEN RAISE EXCEPTION 'PRE source md5 % <> %', v_txt, c_src_md5; END IF;

  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  SELECT md5(string_agg(id || '|' || slug || '|' || display || '|' || country || '|NL', E'\n' ORDER BY line)) INTO v_txt FROM nl_city_plan;
  IF v_txt IS DISTINCT FROM c_plan_md5 THEN RAISE EXCEPTION 'PRE plan md5 % <> %', v_txt, c_plan_md5; END IF;

  -- No clash: id, slug, normalised display/slug of any existing city, or an existing alias,
  -- for the new display, the card label and the new alias.
  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  SELECT count(*) INTO v_n FROM nl_city_plan p
   WHERE EXISTS (SELECT 1 FROM cities c
                  WHERE c.id = p.id OR c.slug = p.slug
                     OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (p.n_display, btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g')))
                     OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g'))    IN (p.n_display, btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g'))))
      OR EXISTS (SELECT 1 FROM city_aliases a
                  WHERE a.alias IN (p.n_display, btrim(regexp_replace(lower(f_unaccent(p.label)), '[^a-z0-9]+', ' ', 'g')), coalesce(p.alias, '')));
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE % planned cities clash with an existing city or alias', v_n; END IF;

  -- The new alias must be the normalised card label (the form the stage job looks up).
  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  SELECT count(*) INTO v_n FROM nl_city_plan WHERE alias IS NOT NULL AND alias = btrim(regexp_replace(lower(f_unaccent(label)), '[^a-z0-9]+', ' ', 'g'));
  IF v_n <> 1 THEN RAISE EXCEPTION 'PRE alias rows in normalised form % <> 1', v_n; END IF;

  SELECT max(id) INTO v_audit0 FROM audit_log;

  ---------------------------------------------------------------- WRITE 1: insert the 7 cities
  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT p.id, p.slug, p.display, p.country, 'NL', 'city', NULL, NULL, NULL, 0
    FROM nl_city_plan p
   ORDER BY p.line;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 7 THEN RAISE EXCEPTION 'WRITE city insert % <> 7', v_n; END IF;

  ---------------------------------------------------------------- WRITE 2: insert the alias + hand audit row
  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  INSERT INTO city_aliases (alias, city_id)
  SELECT p.alias, p.id FROM nl_city_plan p WHERE p.alias IS NOT NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'WRITE alias insert % <> 1', v_n; END IF;

  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a)
    FROM city_aliases a JOIN nl_city_plan p ON p.alias = a.alias AND p.id = a.city_id;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'WRITE hand audit row % <> 1', v_n; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO v_n FROM cities;
  IF v_n <> c_cities_after THEN RAISE EXCEPTION 'POST cities count % <> %', v_n, c_cities_after; END IF;
  SELECT count(*) INTO v_n FROM city_aliases;
  IF v_n <> c_alias_after THEN RAISE EXCEPTION 'POST city_aliases count % <> %', v_n, c_alias_after; END IF;

  -- 8 new audit rows: 7 cities INSERT (row_pk = new id, trigger), 1 city_aliases INSERT (row_pk = alias, hand).
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0;
  IF v_n <> 8 THEN RAISE EXCEPTION 'POST new audit rows % <> 8', v_n; END IF;
  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  SELECT count(*) INTO v_n FROM audit_log l JOIN nl_city_plan p ON p.id = l.row_pk
   WHERE l.id > v_audit0 AND l.table_name = 'cities' AND l.action = 'INSERT' AND l.old_row IS NULL;
  IF v_n <> 7 THEN RAISE EXCEPTION 'POST city audit rows % <> 7', v_n; END IF;
  WITH nl_city_plan AS (SELECT t.line, t.label, t.country, t.display, t.alias, trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g')) AS slug, 'ci_' || left(md5(trim(both '-' from regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', '-', 'g'))), 10) AS id, btrim(regexp_replace(lower(f_unaccent(t.display)), '[^a-z0-9]+', ' ', 'g')) AS n_display FROM unnest(c_line, c_label, c_country, c_display, c_alias) AS t(line, label, country, display, alias))
  SELECT count(*) INTO v_n FROM audit_log l JOIN nl_city_plan p ON p.alias = l.row_pk
   WHERE l.id > v_audit0 AND l.table_name = 'city_aliases' AND l.action = 'INSERT' AND l.old_row IS NULL;
  IF v_n <> 1 THEN RAISE EXCEPTION 'POST alias audit rows % <> 1', v_n; END IF;

  -- Stage-job city resolution (resolve.ts: slug, display, alias; country hint) for 11 card labels.
  -- Each label must give exactly one candidate, it must be the expected city, and its country must agree.
  WITH lab AS (
    SELECT w.line, w.city_id AS want,
           btrim(regexp_replace(lower(f_unaccent(w.label)), '[^a-z0-9]+', ' ', 'g'))                         AS n_full,
           btrim(regexp_replace(lower(f_unaccent(split_part(w.label, ',', 1))), '[^a-z0-9]+', ' ', 'g'))  AS n_head,
           btrim(regexp_replace(lower(f_unaccent(w.country)), '[^a-z0-9]+', ' ', 'g'))                       AS n_country
      FROM (VALUES
           (6, U&'Schin op Geul', U&'Netherlands', 'ci_a266c0fcb3'),
           (22, U&'Veeningen', U&'Netherlands', 'ci_8ed4b91b42'),
           (29, U&'Duiven', U&'Netherlands', 'ci_c9ac96ac24'),
           (32, U&'Hoog Soeren', U&'Netherlands', 'ci_3017dc985b'),
           (44, U&'Valkenburg', U&'Netherlands', 'ci_5a37103403'),
           (51, U&'Mierlo', U&'Netherlands', 'ci_c986145941'),
           (103, U&'Kortgene', U&'Netherlands', 'ci_4daaa88782'),
           (107, U&'The Hague', U&'Netherlands', 'ci_52d3f80546'),
           (27, U&'Apeldoorn', U&'Netherlands', 'ci_5db4e87eb6'),
           (57, U&'Sint-Oedenrode', U&'Netherlands', 'ci_e44f4fc29a'),
           (34, U&'Groningen', U&'Netherlands', 'ci_c21f057b7d')
      ) AS w(line, label, country, city_id)
  ), cand AS (
    SELECT h.line, c.id AS city_id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.line, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.line, a.city_id FROM lab h JOIN city_aliases a ON a.alias IN (h.n_full, h.n_head)
  ), got AS (
    SELECT l.line, l.want, count(c.city_id) AS n_cand, min(c.city_id) AS city_id,
           bool_and(lower(ci.country_iso) = l.n_country OR btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = l.n_country) AS nl
      FROM lab l LEFT JOIN cand c ON c.line = l.line LEFT JOIN cities ci ON ci.id = c.city_id
     GROUP BY l.line, l.want
  )
  SELECT count(*) FILTER (WHERE n_cand IS DISTINCT FROM 1 OR city_id IS DISTINCT FROM want OR nl IS NOT TRUE),
         count(*)
    INTO v_n, v_m FROM got;
  IF v_m <> 11 THEN RAISE EXCEPTION 'POST resolution rows % <> 11', v_m; END IF;
  IF v_n <> 0 THEN RAISE EXCEPTION 'POST % card labels do not resolve to exactly the expected NL city', v_n; END IF;

  RAISE NOTICE 'OK: 7 cities and 1 alias inserted, 8 audit rows after id %', v_audit0;
END
$nlcities$;
