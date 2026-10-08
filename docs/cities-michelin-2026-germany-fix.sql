-- cities-michelin-2026-germany-fix.sql
-- CompassEats, Germany 2026 run-2 preparation, open item 1a (handoff Oct 8, 2026).
--
-- What this file does (one transaction, one DO block):
--   1. Deletes 5 wrong rows from city_aliases (4 named in the Oct 8 handoff + 1 found Oct 8 evening):
--        berghaupten     -> Sonnenbühl ci_5937c0831c           (Berghaupten is its own town)
--        ellwangen       -> Sonnenbühl ci_5937c0831c           (Ellwangen (Jagst) is its own town)
--        gro heubach     -> Freiamt ci_f49503e208              (Großheubach, Bavaria; Freiamt has its own Zur Krone card)
--        starnberg       -> Carmel by the Sea ci_2be3dab26d    (US city; Starnberg is in Bavaria)
--        sulzbach laufen -> Staufen im Breisgau ci_ed87998009  (Sulzbach-Laufen is its own town)
--      city_aliases has no audit trigger, so the file writes 5 hand audit rows first (row_pk = alias).
--   2. Inserts 7 German cities. Display and country come from the staged batch-13 rows
--      (ingest_rows, lines 177, 345, 348, 372, 398, 422, 469), not from typing.
--        slug = trim(both '-' from regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+','-','g'))
--        id   = 'ci_' || left(md5(slug), 10)   (rule of all 3,244 existing cities)
--        country_iso 'DE', kind 'city', region_id NULL, lat/lng NULL, venues_count 0
--        (same form as the Italy, Spain and US city inserts, audit 92001, 100345, 101904).
--      trg_audit_cities writes 7 INSERT audit rows. No alias is needed: each card label
--      matches the new display exactly. No ledger row (a city row has no publisher; same as earlier city inserts).
--
-- Gates (PRE): counts, md5 of the 5 alias rows, md5 of the 7-city plan, no id/slug/display/alias clash,
--              batch 13 still staged with 483 rows.
-- Gates (POST): counts, 12 new audit rows with the right table/action/row_pk, and the stage-job city
--              resolution for 10 card labels gives exactly the expected city.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

DO $fix$
DECLARE
  c_alias_before   constant int    := 263;
  c_cities_before  constant int    := 3244;
  c_alias_after    constant int    := 258;
  c_cities_after   constant int    := 3251;
  c_del_md5        constant text   := '24ba01934e3e0d1670abdef1f3bd5f9d';  -- alias>city_id, sorted, ','
  c_del_rows_md5   constant text   := 'af621400f223555815f1d2ed6417a211';  -- to_jsonb(row), sorted, newline
  c_plan_md5       constant text   := 'db237292281ee12825b86851106cd631';  -- id|slug|display|country|DE, by line, newline
  c_aliases        constant text[] := ARRAY['berghaupten','ellwangen','gro heubach','starnberg','sulzbach laufen'];
  c_lines          constant int[]  := ARRAY[177,345,348,372,398,422,469];
  v_n       int;
  v_txt     text;
  v_audit0  bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO v_n FROM city_aliases;
  IF v_n <> c_alias_before THEN RAISE EXCEPTION 'PRE city_aliases count % <> %', v_n, c_alias_before; END IF;

  SELECT count(*) INTO v_n FROM cities;
  IF v_n <> c_cities_before THEN RAISE EXCEPTION 'PRE cities count % <> %', v_n, c_cities_before; END IF;

  SELECT count(*) INTO v_n FROM ingest_batches WHERE id = 13 AND batch_key = 'michelin-2026-germany' AND status = 'staged';
  IF v_n <> 1 THEN RAISE EXCEPTION 'PRE batch 13 is not michelin-2026-germany / staged'; END IF;
  SELECT count(*) INTO v_n FROM ingest_rows WHERE batch_id = 13;
  IF v_n <> 483 THEN RAISE EXCEPTION 'PRE batch 13 rows % <> 483', v_n; END IF;

  SELECT md5(string_agg(alias || '>' || city_id, ',' ORDER BY alias)) INTO v_txt
    FROM city_aliases WHERE alias = ANY (c_aliases);
  IF v_txt IS DISTINCT FROM c_del_md5 THEN RAISE EXCEPTION 'PRE alias delete-set md5 % <> %', v_txt, c_del_md5; END IF;

  SELECT md5(string_agg(to_jsonb(a)::text, E'\n' ORDER BY alias)) INTO v_txt
    FROM city_aliases a WHERE alias = ANY (c_aliases);
  IF v_txt IS DISTINCT FROM c_del_rows_md5 THEN RAISE EXCEPTION 'PRE alias row md5 % <> %', v_txt, c_del_rows_md5; END IF;

  WITH src AS (
    SELECT (r.validation->>'line')::int AS line, r.raw->>'city_label' AS display, r.raw->>'country_label' AS country
      FROM ingest_rows r
     WHERE r.batch_id = 13 AND (r.validation->>'line')::int = ANY (c_lines)
  ), plan AS (
    SELECT line, display, country,
           trim(both '-' from regexp_replace(lower(f_unaccent(display)), '[^a-z0-9]+', '-', 'g')) AS slug
      FROM src
  )
  SELECT md5(string_agg('ci_' || left(md5(slug), 10) || '|' || slug || '|' || display || '|' || country || '|DE', E'\n' ORDER BY line)),
         count(*)
    INTO v_txt, v_n
    FROM plan;
  IF v_n <> 7 THEN RAISE EXCEPTION 'PRE plan rows % <> 7', v_n; END IF;
  IF v_txt IS DISTINCT FROM c_plan_md5 THEN RAISE EXCEPTION 'PRE plan md5 % <> %', v_txt, c_plan_md5; END IF;

  -- No clash: id, slug, normalised display/slug of any existing city, or an alias other than the 5 to delete.
  WITH src AS (
    SELECT r.raw->>'city_label' AS display FROM ingest_rows r
     WHERE r.batch_id = 13 AND (r.validation->>'line')::int = ANY (c_lines)
  ), plan AS (
    SELECT trim(both '-' from regexp_replace(lower(f_unaccent(display)), '[^a-z0-9]+', '-', 'g')) AS slug,
           btrim(regexp_replace(lower(f_unaccent(display)), '[^a-z0-9]+', ' ', 'g')) AS n_label
      FROM src
  )
  SELECT count(*) INTO v_n FROM plan p
   WHERE EXISTS (SELECT 1 FROM cities c WHERE c.id = 'ci_' || left(md5(p.slug), 10) OR c.slug = p.slug
                    OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = p.n_label
                    OR btrim(regexp_replace(lower(f_unaccent(c.slug)),    '[^a-z0-9]+', ' ', 'g')) = p.n_label)
      OR EXISTS (SELECT 1 FROM city_aliases a WHERE a.alias = p.n_label AND NOT (a.alias = ANY (c_aliases)));
  IF v_n <> 0 THEN RAISE EXCEPTION 'PRE % planned cities clash with an existing city or alias', v_n; END IF;

  SELECT max(id) INTO v_audit0 FROM audit_log;

  ---------------------------------------------------------------- WRITE 1: hand audit rows for the alias deletes
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'DELETE', to_jsonb(a), NULL
    FROM city_aliases a WHERE a.alias = ANY (c_aliases)
   ORDER BY a.alias;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 5 THEN RAISE EXCEPTION 'WRITE hand audit rows % <> 5', v_n; END IF;

  ---------------------------------------------------------------- WRITE 2: delete the 5 aliases
  DELETE FROM city_aliases WHERE alias = ANY (c_aliases);
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 5 THEN RAISE EXCEPTION 'WRITE alias delete % <> 5', v_n; END IF;

  ---------------------------------------------------------------- WRITE 3: insert the 7 cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT 'ci_' || left(md5(p.slug), 10), p.slug, p.display, p.country, 'DE', 'city', NULL, NULL, NULL, 0
    FROM (
      SELECT (r.validation->>'line')::int AS line, r.raw->>'city_label' AS display, r.raw->>'country_label' AS country,
             trim(both '-' from regexp_replace(lower(f_unaccent(r.raw->>'city_label')), '[^a-z0-9]+', '-', 'g')) AS slug
        FROM ingest_rows r
       WHERE r.batch_id = 13 AND (r.validation->>'line')::int = ANY (c_lines)
    ) p
   ORDER BY p.line;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 7 THEN RAISE EXCEPTION 'WRITE city insert % <> 7', v_n; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO v_n FROM city_aliases;
  IF v_n <> c_alias_after THEN RAISE EXCEPTION 'POST city_aliases count % <> %', v_n, c_alias_after; END IF;
  SELECT count(*) INTO v_n FROM cities;
  IF v_n <> c_cities_after THEN RAISE EXCEPTION 'POST cities count % <> %', v_n, c_cities_after; END IF;
  SELECT count(*) INTO v_n FROM city_aliases WHERE alias = ANY (c_aliases);
  IF v_n <> 0 THEN RAISE EXCEPTION 'POST % deleted aliases still present', v_n; END IF;

  -- 12 new audit rows: 5 city_aliases DELETE (row_pk = alias), 7 cities INSERT (row_pk = new id).
  SELECT count(*) INTO v_n FROM audit_log WHERE id > v_audit0;
  IF v_n <> 12 THEN RAISE EXCEPTION 'POST new audit rows % <> 12', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log
   WHERE id > v_audit0 AND table_name = 'city_aliases' AND action = 'DELETE' AND row_pk = ANY (c_aliases) AND new_row IS NULL;
  IF v_n <> 5 THEN RAISE EXCEPTION 'POST alias audit rows % <> 5', v_n; END IF;
  SELECT count(*) INTO v_n FROM audit_log l JOIN cities c ON c.id = l.row_pk
   WHERE l.id > v_audit0 AND l.table_name = 'cities' AND l.action = 'INSERT' AND c.country_iso = 'DE';
  IF v_n <> 7 THEN RAISE EXCEPTION 'POST city audit rows % <> 7', v_n; END IF;

  -- Stage-job city resolution (stageLogic.ts resolveCities: slug, display, alias; country hint) for 10 card labels.
  -- Each label must give exactly one candidate, and it must be the expected city.
  WITH lab AS (
    SELECT (r.validation->>'line')::int AS line,
           btrim(regexp_replace(lower(f_unaccent(r.raw->>'city_label')), '[^a-z0-9]+', ' ', 'g'))                   AS n_full,
           btrim(regexp_replace(lower(f_unaccent(split_part(r.raw->>'city_label', ',', 1))), '[^a-z0-9]+', ' ', 'g')) AS n_head,
           btrim(regexp_replace(lower(f_unaccent(r.raw->>'country_label')), '[^a-z0-9]+', ' ', 'g'))                AS n_country
      FROM ingest_rows r
     WHERE r.batch_id = 13 AND (r.validation->>'line')::int IN (103, 177, 345, 348, 353, 370, 372, 398, 422, 469)
  ), cand AS (
    SELECT h.line, c.id AS city_id FROM lab h JOIN cities c
        ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.line, c.id FROM lab h JOIN cities c
        ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) IN (h.n_full, h.n_head)
    UNION
    SELECT h.line, a.city_id FROM lab h JOIN city_aliases a ON a.alias IN (h.n_full, h.n_head)
  ), got AS (
    SELECT l.line, count(c.city_id) AS n_cand, min(c.city_id) AS city_id,
           bool_and(lower(ci.country_iso) = l.n_country
                    OR btrim(regexp_replace(lower(f_unaccent(ci.country)), '[^a-z0-9]+', ' ', 'g')) = l.n_country) AS de
      FROM lab l LEFT JOIN cand c ON c.line = l.line LEFT JOIN cities ci ON ci.id = c.city_id
     GROUP BY l.line
  ), want(line, city_id) AS (
    VALUES (103, 'ci_5937c0831c'), (177, 'ci_42a8f6b727'), (345, 'ci_fcf8ea41b8'), (348, 'ci_1c4a5ea2e8'),
           (353, 'ci_f49503e208'), (370, 'ci_ed87998009'), (372, 'ci_f3cd8094a9'), (398, 'ci_a790d8481e'),
           (422, 'ci_4e08f1250f'), (469, 'ci_c95b5eec6c')
  )
  SELECT count(*) INTO v_n
    FROM want w LEFT JOIN got g ON g.line = w.line
   WHERE g.n_cand IS DISTINCT FROM 1 OR g.city_id IS DISTINCT FROM w.city_id OR g.de IS NOT TRUE;
  IF v_n <> 0 THEN RAISE EXCEPTION 'POST % card labels do not resolve to exactly the expected German city', v_n; END IF;

  RAISE NOTICE 'OK: 5 aliases deleted, 7 cities inserted, 12 audit rows after id %', v_audit0;
END
$fix$;
