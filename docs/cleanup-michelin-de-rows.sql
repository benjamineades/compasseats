-- cleanup-michelin-de-rows.sql
-- CompassEats, Oct 8 2026. Germany cleanup, items a, c and d (batch 2 of the cleanup).
-- Run AFTER cleanup-michelin-de-status-active.sql (batch 1). The count gates expect batch 1 done.
-- Ben, Oct 8, question 1: option A. Rows 3577 and 1697 MOVE to the venue Michelin's own pages
--   name. The other 7 rows are deleted.
--
-- Rows moved (2, Michelin 2025, no source_url):
--   3577 Two Stars: Posthotel Alexander Herrmann ve_36e30ddd9f -> AURA by Alexander Herrmann &
--     Tobias Bätz ve_410be56f8e (same city, Wirsberg). Evidence: the AURA card URL is
--     .../wirsberg/restaurant/alexander-herrmann-by-tobias-batz (award 27915, Two Stars 2026),
--     so AURA is the restaurant the legacy hotel-name venue stood for.
--   1697 One Star: Aubergine, Carmel ve_1ba19d6d0f -> Aubergine, Starnberg ve_660e52c8f5.
--     Evidence: the wrong alias starnberg -> Carmel (deleted Oct 8, file cities-michelin-2026-
--     germany-fix.sql) put Starnberg's rows on Carmel; the Carmel card is Two Stars; the
--     Michelin 2026 Germany star list names "Starnberg - Aubergine" with no "NEU" mark, so it
--     held One Star in 2025.
-- Rows deleted (7, all Michelin, no source_url):
--   a. 3578 Michelin 2026 Two Stars on Posthotel: a move makes a same-category twin of AURA's
--      card row 27915. After both changes Posthotel holds no award and is deleted with its rows
--      (method of ledger 79 / 85). Old URL /wirsberg/posthotel-alexander-herrmann gives a 404,
--      no redirect. Its $$$$ legacy price is deleted, not moved (Upper House precedent).
--   c. Second category rule (Plan v1.29), the 5 Germany venues with a 2025 One Star and a 2025
--      Bib row: 5242 Die Mühlenhelle, 4228 Hämmerles Restaurant, 4189 Schwingshackl ESSKULTUR,
--      5865 Restaurant HochZwei im Gasthof zum Bad Langenau, 8250 Restaurant Hirsch (Sonnenbühl).
--      No source shows which restaurant held each 2025 Bib, so no move is proven.
--      Each venue keeps its One Star rows (2025 legacy, 2026 sourced card).
--   d. 1695 Michelin 2026 One Star on Carmel: Starnberg's row; a move makes a same-category twin
--      of Starnberg's card row 27916. The Carmel card (read Oct 8, guide.michelin.com/us/en/
--      california/carmel-by-the-sea/restaurant/aubergine) says Two Stars, 2026 MICHELIN Guide USA,
--      "Spare no expense" (= legacy $$$$). Two Stars rows 1694 (2026) and 1696 (2025) stay.
--      The Carmel venue and its other 11 rows (Forbes, OAD, La Liste, Best Chef) do not change.
--
-- Pre-check (read Oct 8, all 10 venue_id foreign-key tables + redirects, rename_rows, ingest_rows):
--   Posthotel: awards 2 (3577, 3578), price 1 ($$$$ legacy_guide, publisher michelin),
--     city_label_source 2 (1335 Wirsberg, 1336 Germany, michelin), listings 1, slugs 1
--     (wirsberg/posthotel-alexander-herrmann, canonical), blurbs / addresses / geo / hours /
--     photo_refs 0, redirects 0, rename_rows 0, ingest_rows 0.
--   Targets: AURA holds Michelin 2026 Two Stars only; Starnberg holds Michelin 2026 One Star only.
--     So neither move makes a twin or a second category.
--   No table has a foreign key to awards or to city_label_source.
-- Guards:
--   all 9 award ids md5 (by id, ',')              7de98a8c8ff496e4b4e9342b232e0053
--   9-row plan fingerprint (md5 of id|venue_id|source_id|year|category|source_url or '',
--     by id, newline)                             dd6b573fbd0de1daf9500a6cc5a6e67a
--   deleted award ids md5 (by id, ',')            69ee991d051036a7e6ead07c53ad25ae (7)
--   moves md5 ('award_id|target', by id, ',')     3403fa0d585041a4840bb845906fb747 (2)
--   Posthotel city label ids md5 (by id, ',')     7a374027737995509c3b6cbe99d19126 (1335,1336)
-- Write order: 2 hand audit rows, delete city_label_source 2, move awards 2 (UPDATE venue_id),
--   delete awards 7, price 1, slugs 1, listings 1, venues 1, then 1 ledger row (items 9).
-- Expected audit rows: 15 (2 hand + 13 from triggers: awards UPDATE 2, awards DELETE 7,
--   price 1, slugs 1, listings 1, venues 1).
-- After: awards 22,396 -> 22,389. Michelin 2025 3,796 -> 3,791, Michelin 2026 4,806 -> 4,804.
--   Germany Michelin 2026 rows 485 -> 484 (unsourced 1: 7349 Gasthaus Jakob).
--   Germany Michelin 2025 rows 468 -> 464 (- 5 Bib, + 1697 now on a DE venue; 3577 stays in DE).
--   Venue-years with two Michelin categories 25 -> 18 (0 in Germany, 0 on Carmel).
-- Dry run: send only the DO block through the Read connector. All pre-checks run, then the
--   block stops at the first INSERT with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  aids     bigint[] := ARRAY[1695,1697,3577,3578,4189,4228,5242,5865,8250]::bigint[];
  dids     bigint[] := ARRAY[1695,3578,4189,4228,5242,5865,8250]::bigint[];
  vid      text     := 've_36e30ddd9f';
  aura     text     := 've_410be56f8e';
  starn    text     := 've_660e52c8f5';
  carmel   text     := 've_1ba19d6d0f';
  clsids   bigint[];
  fp       text;
  n        int;
  x        int;
  y        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
  job_txt  text := 'cleanup:cleanup-michelin-de-rows | Germany cleanup items a, c, d (Ben, Oct 8, question 1 option A) | moved 2: 3577 Michelin 2025 Two Stars Posthotel -> AURA ve_410be56f8e (card slug alexander-herrmann-by-tobias-batz), 1697 Michelin 2025 One Star Carmel -> Aubergine Starnberg ve_660e52c8f5 (wrong alias, star list without NEU) | deleted 7: 3578 (twin of AURA card 27915), 1695 (twin of Starnberg card 27916), second category rule 4189,4228,5242,5865,8250 | Carmel card Two Stars 2026 | venue ve_36e30ddd9f Posthotel Alexander Herrmann deleted, old URL 404, no redirect';
BEGIN
  -- 1. Guards
  IF md5(array_to_string(aids, ',')) <> '7de98a8c8ff496e4b4e9342b232e0053' THEN
    RAISE EXCEPTION 'award id list md5 does not match';
  END IF;
  IF md5(array_to_string(dids, ',')) <> '69ee991d051036a7e6ead07c53ad25ae' THEN
    RAISE EXCEPTION 'deleted award id list md5 does not match';
  END IF;
  IF md5('1697|' || starn || ',3577|' || aura) <> '3403fa0d585041a4840bb845906fb747' THEN
    RAISE EXCEPTION 'move list md5 does not match';
  END IF;
  SELECT count(*), md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                                   E'\n' ORDER BY a.id))
    INTO n, fp FROM awards a WHERE a.id = ANY (aids);
  IF n <> 9 THEN RAISE EXCEPTION 'award rows in plan % (expected 9)', n; END IF;
  IF fp <> 'dd6b573fbd0de1daf9500a6cc5a6e67a' THEN RAISE EXCEPTION 'award plan fingerprint changed: %', fp; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id = ANY (aids) AND source_id = 'michelin' AND source_url IS NULL AND rank IS NULL AND distinction IS NULL;
  IF x <> 9 THEN RAISE EXCEPTION 'plan rows that are unsourced Michelin rows % (expected 9)', x; END IF;

  SELECT array_agg(id ORDER BY id) INTO clsids FROM city_label_source WHERE venue_id = vid;
  IF md5(array_to_string(clsids, ',')) <> '7a374027737995509c3b6cbe99d19126' THEN
    RAISE EXCEPTION 'Posthotel city label id list md5 does not match';
  END IF;

  -- 2. Pre-checks
  -- 2a. Posthotel (full venue pre-check)
  SELECT count(*) INTO x FROM venues
   WHERE id = vid AND name = 'Posthotel Alexander Herrmann' AND status = 'active' AND city_id = 'ci_d45c8ed633';
  IF x <> 1 THEN RAISE EXCEPTION 'Posthotel venue row changed'; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = vid;
  IF x <> 2 THEN RAISE EXCEPTION 'Posthotel award rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = vid AND id IN (3577, 3578);
  IF x <> 2 THEN RAISE EXCEPTION 'Posthotel awards are not 3577 and 3578'; END IF;
  SELECT count(*) INTO x FROM price
   WHERE venue_id = vid AND source::text = 'legacy_guide' AND symbol_raw = '$$$$' AND source_url IS NULL;
  SELECT count(*) INTO y FROM price WHERE venue_id = vid;
  IF x <> 1 OR y <> 1 THEN RAISE EXCEPTION 'Posthotel price rows % / legacy $$$$ % (expected 1 / 1)', y, x; END IF;
  SELECT count(*) INTO x FROM city_label_source WHERE venue_id = vid AND publisher = 'michelin';
  IF x <> 2 THEN RAISE EXCEPTION 'Posthotel Michelin city labels % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM listings WHERE venue_id = vid;
  IF x <> 1 THEN RAISE EXCEPTION 'Posthotel listings % (expected 1)', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE is_canonical AND city_slug = 'wirsberg' AND slug = 'posthotel-alexander-herrmann')
    INTO x, y FROM slugs WHERE venue_id = vid;
  IF x <> 1 OR y <> 1 THEN RAISE EXCEPTION 'Posthotel slugs % / canonical % (expected 1 / 1)', x, y; END IF;
  SELECT count(*) INTO x FROM blurbs     WHERE venue_id = vid; IF x <> 0 THEN RAISE EXCEPTION 'Posthotel blurbs %', x; END IF;
  SELECT count(*) INTO x FROM addresses  WHERE venue_id = vid; IF x <> 0 THEN RAISE EXCEPTION 'Posthotel addresses %', x; END IF;
  SELECT count(*) INTO x FROM geo        WHERE venue_id = vid; IF x <> 0 THEN RAISE EXCEPTION 'Posthotel geo %', x; END IF;
  SELECT count(*) INTO x FROM hours      WHERE venue_id = vid; IF x <> 0 THEN RAISE EXCEPTION 'Posthotel hours %', x; END IF;
  SELECT count(*) INTO x FROM photo_refs WHERE venue_id = vid; IF x <> 0 THEN RAISE EXCEPTION 'Posthotel photo_refs %', x; END IF;
  SELECT count(*) INTO x FROM redirects
   WHERE from_path LIKE '%posthotel-alexander-herrmann%' OR to_path LIKE '%posthotel-alexander-herrmann%';
  IF x <> 0 THEN RAISE EXCEPTION 'redirects that name the Posthotel path: %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows rr WHERE rr::text LIKE '%' || vid || '%';
  IF x <> 0 THEN RAISE EXCEPTION 'rename_rows that name the Posthotel venue: %', x; END IF;
  SELECT count(*) INTO x FROM ingest_rows ir WHERE ir.validation::text LIKE '%' || vid || '%' OR ir.raw::text LIKE '%' || vid || '%';
  IF x <> 0 THEN RAISE EXCEPTION 'ingest_rows that name the Posthotel venue: %', x; END IF;

  -- 2b. Move targets: each holds exactly one Michelin row, the sourced 2026 card
  SELECT count(*) INTO x FROM venues WHERE id = aura AND status = 'active' AND city_id = 'ci_d45c8ed633';
  IF x <> 1 THEN RAISE EXCEPTION 'AURA venue not active in Wirsberg'; END IF;
  SELECT count(*) INTO x FROM venues v JOIN cities c ON c.id = v.city_id
   WHERE v.id = starn AND v.status = 'active' AND c.country_iso = 'DE';
  IF x <> 1 THEN RAISE EXCEPTION 'Starnberg venue not active in DE'; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = aura AND source_id = 'michelin';
  IF x <> 1 THEN RAISE EXCEPTION 'AURA Michelin rows % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id = 27915 AND venue_id = aura AND source_id = 'michelin' AND year = 2026 AND category = 'Two Stars'
     AND source_url = 'https://guide.michelin.com/us/en/bayern/wirsberg/restaurant/alexander-herrmann-by-tobias-batz';
  IF x <> 1 THEN RAISE EXCEPTION 'AURA card row 27915 not found'; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = starn AND source_id = 'michelin';
  IF x <> 1 THEN RAISE EXCEPTION 'Starnberg Michelin rows % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id = 27916 AND venue_id = starn AND source_id = 'michelin' AND year = 2026 AND category = 'One Star'
     AND source_url = 'https://guide.michelin.com/us/en/bayern/starnberg/restaurant/aubergine388304';
  IF x <> 1 THEN RAISE EXCEPTION 'Aubergine Starnberg card row 27916 not found'; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE (id = 3577 AND venue_id = vid AND year = 2025 AND category = 'Two Stars')
      OR (id = 1697 AND venue_id = carmel AND year = 2025 AND category = 'One Star');
  IF x <> 2 THEN RAISE EXCEPTION 'rows to move not in the expected state: % of 2', x; END IF;

  -- 2c. The rows that stay (keepers) are present
  SELECT count(*) INTO x FROM awards
   WHERE venue_id = carmel AND source_id = 'michelin' AND category = 'Two Stars'
     AND ((id = 1694 AND year = 2026) OR (id = 1696 AND year = 2025));
  IF x <> 2 THEN RAISE EXCEPTION 'Carmel Two Stars rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = carmel;
  IF x <> 15 THEN RAISE EXCEPTION 'Carmel award rows % (expected 15)', x; END IF;
  -- each second-category venue keeps a 2025 One Star and a sourced 2026 One Star
  SELECT count(*) INTO x FROM awards
   WHERE source_id = 'michelin' AND category = 'One Star'
     AND id IN (5241,5240, 4227,4226, 4188,4187, 5864,5863, 8249,8251)
     AND venue_id IN ('ve_5fad8fbf2d','ve_89def3daf3','ve_b2b57e491b','ve_885eda93f2','ve_801f5d310a');
  IF x <> 10 THEN RAISE EXCEPTION 'One Star rows that stay % (expected 10)', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id IN (5240,4226,4187,5863,8251) AND year = 2026 AND source_url LIKE 'https://guide.michelin.com/us/en/%';
  IF x <> 5 THEN RAISE EXCEPTION 'sourced 2026 One Star rows that stay % (expected 5)', x; END IF;

  -- 3. Counts before (batch 1 done)
  SELECT count(*) INTO x FROM venues;                 IF x <> 11224 THEN RAISE EXCEPTION 'venues before % (expected 11224)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                      IF x <> 10860 THEN RAISE EXCEPTION 'active before % (expected 10860; run batch 1 first)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                      IF x <> 364 THEN RAISE EXCEPTION 'closed before % (expected 364)', x; END IF;
  SELECT count(*) INTO x FROM awards;                 IF x <> 22396 THEN RAISE EXCEPTION 'awards before % (expected 22396)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                      IF x <> 3796 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3796)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                      IF x <> 4806 THEN RAISE EXCEPTION 'Michelin 2026 before % (expected 4806)', x; END IF;
  SELECT count(*) INTO x FROM listings;               IF x <> 11224 THEN RAISE EXCEPTION 'listings before % (expected 11224)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                  IF x <> 12323 THEN RAISE EXCEPTION 'slugs before % (expected 12323)', x; END IF;
  SELECT count(*) INTO x FROM price;                  IF x <> 7049 THEN RAISE EXCEPTION 'price before % (expected 7049)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;      IF x <> 23852 THEN RAISE EXCEPTION 'city labels before % (expected 23852)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 68 OR led_max <> 90 THEN RAISE EXCEPTION 'ledger before % / max % (expected 68 / 90)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 104459 OR aud_max <> 108052 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 104459 / 108052; run batch 1 first)', aud_n, aud_max; END IF;

  -- 4. Write
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.id = ANY (clsids) ORDER BY c.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'hand audit rows % (expected 2)', n; END IF;

  DELETE FROM city_label_source WHERE id = ANY (clsids) AND venue_id = vid;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'city labels deleted % (expected 2)', n; END IF;

  UPDATE awards SET venue_id = aura
   WHERE id = 3577 AND venue_id = vid AND source_id = 'michelin' AND year = 2025 AND category = 'Two Stars' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 3577 moved % (expected 1)', n; END IF;
  UPDATE awards SET venue_id = starn
   WHERE id = 1697 AND venue_id = carmel AND source_id = 'michelin' AND year = 2025 AND category = 'One Star' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'award 1697 moved % (expected 1)', n; END IF;

  DELETE FROM awards WHERE id = ANY (dids) AND source_id = 'michelin' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'awards deleted % (expected 7)', n; END IF;

  DELETE FROM price WHERE venue_id = vid;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price deleted % (expected 1)', n; END IF;

  DELETE FROM slugs WHERE venue_id = vid;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slugs deleted % (expected 1)', n; END IF;

  DELETE FROM listings WHERE venue_id = vid;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings deleted % (expected 1)', n; END IF;

  DELETE FROM venues WHERE id = vid AND city_id = 'ci_d45c8ed633';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues deleted % (expected 1)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 9, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 5. Post-checks
  SELECT count(*) INTO x FROM awards WHERE id = ANY (dids);
  IF x <> 0 THEN RAISE EXCEPTION 'deleted award rows left: %', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE (id = 3577 AND venue_id = aura AND year = 2025 AND category = 'Two Stars' AND source_url IS NULL)
      OR (id = 1697 AND venue_id = starn AND year = 2025 AND category = 'One Star' AND source_url IS NULL);
  IF x <> 2 THEN RAISE EXCEPTION 'moved rows on their targets % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = aura AND source_id = 'michelin';
  IF x <> 2 THEN RAISE EXCEPTION 'AURA Michelin rows after % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = starn AND source_id = 'michelin';
  IF x <> 2 THEN RAISE EXCEPTION 'Starnberg Michelin rows after % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = carmel;
  IF x <> 13 THEN RAISE EXCEPTION 'Carmel award rows after % (expected 13)', x; END IF;
  SELECT (SELECT count(*) FROM venues            WHERE id = vid)
       + (SELECT count(*) FROM awards            WHERE venue_id = vid)
       + (SELECT count(*) FROM price             WHERE venue_id = vid)
       + (SELECT count(*) FROM city_label_source WHERE venue_id = vid)
       + (SELECT count(*) FROM slugs             WHERE venue_id = vid)
       + (SELECT count(*) FROM listings          WHERE venue_id = vid)
       + (SELECT count(*) FROM blurbs            WHERE venue_id = vid)
       + (SELECT count(*) FROM addresses         WHERE venue_id = vid)
       + (SELECT count(*) FROM geo               WHERE venue_id = vid)
       + (SELECT count(*) FROM hours             WHERE venue_id = vid)
       + (SELECT count(*) FROM photo_refs        WHERE venue_id = vid)
    INTO x;
  IF x <> 0 THEN RAISE EXCEPTION 'rows left on the Posthotel venue: %', x; END IF;

  SELECT count(*) INTO x FROM venues;            IF x <> 11223 THEN RAISE EXCEPTION 'venues after % (expected 11223)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                 IF x <> 10859 THEN RAISE EXCEPTION 'active after % (expected 10859)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                 IF x <> 364 THEN RAISE EXCEPTION 'closed after % (expected 364)', x; END IF;
  SELECT count(*) INTO x FROM awards;            IF x <> 22389 THEN RAISE EXCEPTION 'awards after % (expected 22389)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                 IF x <> 3791 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3791)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                 IF x <> 4804 THEN RAISE EXCEPTION 'Michelin 2026 after % (expected 4804)', x; END IF;
  SELECT count(*) INTO x FROM listings;          IF x <> 11223 THEN RAISE EXCEPTION 'listings after % (expected 11223)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12322 THEN RAISE EXCEPTION 'slugs after % (expected 12322)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;
                                                 IF x <> 11223 THEN RAISE EXCEPTION 'canonical slugs after % (expected 11223)', x; END IF;
  SELECT count(*) INTO x FROM (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical
                               GROUP BY v.id HAVING count(s.slug) <> 1) d;
                                                 IF x <> 0 THEN RAISE EXCEPTION 'venues with more or less than 1 canonical slug: %', x; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id, year, category FROM awards WHERE source_id = 'michelin'
                               GROUP BY 1, 2, 3 HAVING count(*) > 1) d;
                                                 IF x <> 0 THEN RAISE EXCEPTION 'venues with two Michelin rows of one year and category: %', x; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id, year FROM awards WHERE source_id = 'michelin'
                               GROUP BY 1, 2 HAVING count(DISTINCT category) > 1) d;
                                                 IF x <> 18 THEN RAISE EXCEPTION 'venue-years with two Michelin categories after % (expected 18)', x; END IF;
  SELECT count(*) INTO x FROM (SELECT a.venue_id, a.year FROM awards a JOIN venues v ON v.id = a.venue_id
                               JOIN cities c ON c.id = v.city_id
                               WHERE a.source_id = 'michelin' AND (c.country_iso = 'DE' OR a.venue_id = carmel)
                               GROUP BY 1, 2 HAVING count(DISTINCT a.category) > 1) d;
                                                 IF x <> 0 THEN RAISE EXCEPTION 'Germany or Carmel venue-years with two categories: %', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE a.source_url IS NULL) INTO x, y
    FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2026 AND c.country_iso = 'DE';
  IF x <> 484 OR y <> 1 THEN RAISE EXCEPTION 'Germany 2026 rows % / unsourced % (expected 484 / 1)', x, y; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso = 'DE';
  IF x <> 464 THEN RAISE EXCEPTION 'Germany 2025 rows after % (expected 464)', x; END IF;
  SELECT count(*) INTO x FROM price;             IF x <> 7048 THEN RAISE EXCEPTION 'price after % (expected 7048)', x; END IF;
  SELECT count(*) INTO x FROM price WHERE source::text = 'guide_ingest';
                                                 IF x <> 10 THEN RAISE EXCEPTION 'guide_ingest price after % (expected 10)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 23850 THEN RAISE EXCEPTION 'city labels after % (expected 23850)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;            IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM redirects;         IF x <> 9 THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;

  -- 5a. Ledger and audit
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 69 THEN RAISE EXCEPTION 'ledger after % (expected 69)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 9 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 15 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 15)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND action = 'DELETE' AND new_row IS NULL AND (
         (table_name = 'city_label_source' AND row_pk = ANY (SELECT unnest(clsids)::text))
      OR (table_name = 'awards'            AND row_pk = ANY (SELECT unnest(dids)::text))
      OR (table_name IN ('price','slugs','listings','venues') AND row_pk = vid));
  IF x <> 13 THEN RAISE EXCEPTION 'DELETE audit rows that match the plan % (expected 13)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'awards' AND a.action = 'UPDATE'
     AND ((a.row_pk = '3577' AND a.old_row->>'venue_id' = vid AND a.new_row->>'venue_id' = aura)
       OR (a.row_pk = '1697' AND a.old_row->>'venue_id' = carmel AND a.new_row->>'venue_id' = starn))
     AND (SELECT count(*) FROM jsonb_object_keys(a.new_row) k WHERE a.old_row->k IS DISTINCT FROM a.new_row->k) = 1;
  IF x <> 2 THEN RAISE EXCEPTION 'venue_id-only UPDATE audit rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND table_name = 'city_label_source' AND old_row->>'venue_id' = vid;
  IF x <> 2 THEN RAISE EXCEPTION 'hand audit rows with the deleted city label % (expected 2)', x; END IF;
END
$do$;
COMMIT;
