-- cleanup-test-current-counts.sql (PRE-CHECK COPY, NOT FOR RUNNING)
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 9, file 2 of 2. DELETE: run in the Supabase SQL Editor.
-- Test copy: counts of Nov 1 13:28 UTC (before file 1). Dry run only.
-- Ben: Nov 1 08:28 ET "All recommendations" (The Fellas and Fo'ao Vaperse Hotel: A = delete the row and the venue).
-- Sep 28 contamination rule (no provable pairing): each venue holds only one Best Chef 2025 1-Knife row that no Best Chef
-- card proves; the venue has no other award. Chengdu held-7 method: hand audit rows for city_label_source, then delete
-- city_label_source, awards, slugs, listings, venues (no price, address, geo, hours, photo, blurb rows; read Nov 1).
-- Old URLs /shanghai/the-fellas and /guangzhou/fo-ao-vaperse-hotel give a 404 after this; no redirect.
-- cities.venues_count: Shanghai 112 -> 111, Guangzhou 74 -> 73 (stored count = view city_venue_counts).
-- Relay docs/open-items-b9-build/relay-file2.txt sha256 2666136e38603fe4b4a44783e2533d8848402988201048ae91eef3f3ffffabd2. Plan fingerprint 8e1c516a11818c2614c882358a71130f.
-- Expected: venues 11302 -> 11300 (active 10936 -> 10934), awards 23363 -> 23361, slugs 12945 -> 12943,
--   listings 11302 -> 11300, city_label_source 24003 -> 23999, venues_count sum 10936 -> 10934,
--   ledger last id 180 -> 185, audit last id 120732 -> 120774 (+14: city_label_source DELETE 4 (hand), awards 2, slugs 2, listings 2, venues 2 DELETE, cities UPDATE 2).
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel$del|ve_42dfc9b029|The Fellas|16190|1-Knife|ci_22638a3131|112|111|shanghai/the-fellas|15690,15691|Italian rooftop bar (Yan'an Rd E 7, 7F); no Best Chef 2024/2025 card names it (results pages and special awards read Nov 1)
del|ve_8caa39d442|Fo'ao Vaperse Hotel|15997|1-Knife|ci_d9d7a94326|74|73|guangzhou/fo-ao-vaperse-hotel|15536,15537|Vaperse is a hotel (5 Jinsui Rd); no Best Chef 2024/2025 card names Vaperse or Fo'ao (results pages and special awards read Nov 1)$rel$, E'\r', '');
  n int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '2666136e38603fe4b4a44783e2533d8848402988201048ae91eef3f3ffffabd2' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> 11302 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10936 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 OR (SELECT count(*) FROM slugs) <> 12945 OR (SELECT count(*) FROM listings) <> 11302
     OR (SELECT count(*) FROM city_label_source) <> 24003 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 136 OR (SELECT max(id) FROM source_capture_ledger) <> 180 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> 115448 OR (SELECT max(id) FROM audit_log) <> 120732 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10936 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'source_capture_ledger_id_seq') <> 184
     OR (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'audit_log_id_seq') <> 120760 THEN RAISE EXCEPTION 'id counters before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;

  -- plan fingerprint, read live: venue|name|award|category|canonical path|city label ids
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||a.id||'|'||a.category||'|'||s.city_slug||'/'||s.slug||'|'||
           (SELECT string_agg(c.id::text, ',' ORDER BY c.id) FROM city_label_source c WHERE c.venue_id = v.id), E'\n' ORDER BY v.id))
    INTO v_txt
    FROM venues v JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND v.id = split_part(l, '|', 2) AND v.status = 'active'
    JOIN awards a ON a.venue_id = v.id JOIN slugs s ON s.venue_id = v.id AND s.is_canonical;
  IF v_txt IS DISTINCT FROM '8e1c516a11818c2614c882358a71130f' THEN RAISE EXCEPTION 'plan fingerprint %', v_txt; END IF;
  -- each venue: exactly 1 award, 2 labels, 1 slug, 1 listing, nothing in the other child tables
  IF (SELECT count(*) FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND a.venue_id = split_part(l, '|', 2)) <> 2
     OR (SELECT count(*) FROM city_label_source c JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND c.venue_id = split_part(l, '|', 2)) <> 4
     OR (SELECT count(*) FROM slugs s JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND s.venue_id = split_part(l, '|', 2)) <> 2
     OR (SELECT count(*) FROM listings t JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND t.venue_id = split_part(l, '|', 2)) <> 2 THEN RAISE EXCEPTION 'child rows'; END IF;
  IF EXISTS (SELECT 1 FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND (
        EXISTS (SELECT 1 FROM addresses x WHERE x.venue_id = split_part(l, '|', 2)) OR EXISTS (SELECT 1 FROM blurbs x WHERE x.venue_id = split_part(l, '|', 2))
     OR EXISTS (SELECT 1 FROM geo x WHERE x.venue_id = split_part(l, '|', 2)) OR EXISTS (SELECT 1 FROM hours x WHERE x.venue_id = split_part(l, '|', 2))
     OR EXISTS (SELECT 1 FROM photo_refs x WHERE x.venue_id = split_part(l, '|', 2)) OR EXISTS (SELECT 1 FROM price x WHERE x.venue_id = split_part(l, '|', 2))
     OR EXISTS (SELECT 1 FROM rename_rows x WHERE x.venue_id = split_part(l, '|', 2)))) THEN RAISE EXCEPTION 'other child rows'; END IF;
  IF (SELECT count(*) FROM cities c JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND c.id = split_part(l, '|', 6) AND c.venues_count = split_part(l, '|', 7)::int) <> 2 THEN RAISE EXCEPTION 'city counts before'; END IF;

  -- hand audit rows (no trigger on city_label_source), then the deletes
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'del' AND c.venue_id = split_part(l, '|', 2) ORDER BY c.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'hand audit rows %', n; END IF;
  DELETE FROM city_label_source c USING regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND c.venue_id = split_part(l, '|', 2);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'labels deleted %', n; END IF;
  DELETE FROM awards a USING regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND a.venue_id = split_part(l, '|', 2) AND a.id = split_part(l, '|', 4)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards deleted %', n; END IF;
  DELETE FROM slugs s USING regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND s.venue_id = split_part(l, '|', 2);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'slugs deleted %', n; END IF;
  DELETE FROM listings t USING regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND t.venue_id = split_part(l, '|', 2);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'listings deleted %', n; END IF;
  DELETE FROM venues v USING regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND v.id = split_part(l, '|', 2);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues deleted %', n; END IF;
  UPDATE cities c SET venues_count = split_part(l, '|', 8)::int FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND c.id = split_part(l, '|', 6) AND c.venues_count = split_part(l, '|', 7)::int;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'cities updated %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2, 'cleanup:cleanup-best-chef-b9-2026-11-01 | contamination rule (Ben, Sep 28): 2 legacy Best Chef 2025 1-Knife rows with no provable pairing, deleted with their venues | 16190 The Fellas ve_42dfc9b029 (Shanghai, Italian rooftop bar), 15997 Fo''ao Vaperse Hotel ve_8caa39d442 (Guangzhou, a hotel); no Best Chef 2024/2025 card or special award names either (read Nov 1) | old URLs 404, no redirect | Ben Nov 1 08:28 ET "All recommendations"')
  RETURNING id INTO v_lid;
  IF v_lid <> 185 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;

  -- post-checks
  IF EXISTS (SELECT 1 FROM regexp_split_to_table(rel, E'\n') l WHERE split_part(l, '|', 1) = 'del' AND (
        EXISTS (SELECT 1 FROM venues x WHERE x.id = split_part(l, '|', 2)) OR EXISTS (SELECT 1 FROM awards x WHERE x.venue_id = split_part(l, '|', 2))
     OR EXISTS (SELECT 1 FROM slugs x WHERE x.venue_id = split_part(l, '|', 2)) OR EXISTS (SELECT 1 FROM listings x WHERE x.venue_id = split_part(l, '|', 2))
     OR EXISTS (SELECT 1 FROM city_label_source x WHERE x.venue_id = split_part(l, '|', 2)))) THEN RAISE EXCEPTION 'rows remain'; END IF;
  IF (SELECT count(*) FROM venues) <> 11300 OR (SELECT count(*) FROM venues WHERE status = 'active') <> 10934 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23361 OR (SELECT count(*) FROM slugs) <> 12943 OR (SELECT count(*) FROM listings) <> 11300
     OR (SELECT count(*) FROM city_label_source) <> 23999 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10934 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) <> 1) THEN RAISE EXCEPTION 'canonical slugs after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120732) <> 14 OR (SELECT max(id) FROM audit_log) <> 120774 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 120732 AND action = 'DELETE' AND table_name = 'city_label_source') <> 4
     OR (SELECT count(*) FROM audit_log WHERE id > 120732 AND action = 'DELETE' AND table_name IN ('awards', 'slugs', 'listings', 'venues')) <> 8
     OR (SELECT count(*) FROM audit_log WHERE id > 120732 AND action = 'UPDATE' AND table_name = 'cities'
           AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 2 THEN RAISE EXCEPTION 'audit rows by table'; END IF;
END
$do$;
COMMIT;
