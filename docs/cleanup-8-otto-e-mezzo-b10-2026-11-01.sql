-- cleanup-8-otto-e-mezzo-b10-2026-11-01.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 10, file 2 of 2. DELETE: run in the Supabase SQL Editor.
-- Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5" (D4 = A). Run after file 1.
-- Award 15736 (michelin 2025 Three Stars on Macau ve_6f0b34cc23, no URL) is a copy of 391 (michelin 2025 Three Stars on Hong Kong
-- ve_e17d78f314): the Michelin 2025 article (Mar 13, 2025) names 8 1/2 Otto e Mezzo - Bombana Three Stars in Hong Kong only;
-- the Macau card is One Star (6238 stays). Trigger audit row only (no hand rows needed).
-- Relay docs/open-items-b10-build/relay-file2.txt sha256 8ef2dd54af8d2fce753cdd76114f2e0ae8559358b5b77df5d3ac6bbb89a14a83.
-- Expected: awards 23363 -> 23362, ledger last id 195 -> 196, audit last id 120820 -> 120821 (+1: awards DELETE 1).
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel$del|15736|ve_6f0b34cc23|michelin|2025|Three Stars|copy of 391 on Hong Kong: Michelin 2025 article (Mar 13, 2025) names 8 1/2 Otto e Mezzo - Bombana Three Stars in Hong Kong only; Macau card is One Star (row 6238 stays)$rel$, E'\r', '');
  n int; v_lid bigint;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '8ef2dd54af8d2fce753cdd76114f2e0ae8559358b5b77df5d3ac6bbb89a14a83' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> 11300 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10935
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> 365 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12950 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1650 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11300 OR (SELECT count(*) FROM blurbs) <> 142 THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 20 OR (SELECT count(*) FROM rename_rows) <> 1211 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 147 OR (SELECT max(id) FROM source_capture_ledger) <> 195 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115508 OR (SELECT max(id) FROM audit_log) <> 120820 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'source_capture_ledger_id_seq') <> 195
     OR (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'audit_log_id_seq') <> 120820 THEN RAISE EXCEPTION 'id counters before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10935 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF (SELECT count(*) FROM venues WHERE id = 've_e17d78f314' AND name = '8 1/2 Otto e Mezzo Bombana' AND status = 'active') <> 1
     OR (SELECT count(*) FROM venues WHERE id = 've_6f0b34cc23' AND name = '8 1/2 Otto e Mezzo Bombana' AND status = 'active') <> 1 THEN RAISE EXCEPTION 'file 1 not run'; END IF;
  IF (SELECT count(*) FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3) AND a.source_id = split_part(l, '|', 4)
        AND a.year = split_part(l, '|', 5)::int AND a.category = split_part(l, '|', 6) AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) <> 1 THEN RAISE EXCEPTION 'row 15736'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 391 AND venue_id = 've_e17d78f314' AND source_id = 'michelin' AND year = 2025 AND category = 'Three Stars') <> 1 THEN RAISE EXCEPTION 'row 391'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 6238 AND venue_id = 've_6f0b34cc23' AND source_id = 'michelin' AND year = 2025 AND category = 'One Star') <> 1 THEN RAISE EXCEPTION 'row 6238'; END IF;

  DELETE FROM awards a USING regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'awards deleted %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 1, 'cleanup:cleanup-8-otto-e-mezzo-b10-2026-11-01 | 15736 michelin 2025 Three Stars on Macau ve_6f0b34cc23 deleted: copy of 391 on Hong Kong ve_e17d78f314; Michelin 2025 article https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2025 names 8 1/2 Otto e Mezzo - Bombana Three Stars in Hong Kong only; Macau card One Star (6238 stays) | Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"')
  RETURNING id INTO v_lid;
  IF v_lid <> 196 THEN RAISE EXCEPTION 'ledger id michelin award %', v_lid; END IF;

  -- post-checks
  IF (SELECT count(*) FROM awards) <> 23362 OR EXISTS (SELECT 1 FROM awards WHERE id = 15736) THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_e17d78f314') <> 11 OR (SELECT count(*) FROM awards WHERE venue_id = 've_6f0b34cc23') <> 6 THEN RAISE EXCEPTION 'awards per venue after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 148 OR (SELECT max(id) FROM source_capture_ledger) <> 196 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115509 OR (SELECT max(id) FROM audit_log) <> 120821
     OR (SELECT count(*) FROM audit_log WHERE id > 120820 AND table_name = 'awards' AND action = 'DELETE' AND row_pk = '15736'
           AND old_row->>'venue_id' = 've_6f0b34cc23' AND old_row->>'category' = 'Three Stars') <> 1 THEN RAISE EXCEPTION 'audit after'; END IF;
END
$do$;
COMMIT;
