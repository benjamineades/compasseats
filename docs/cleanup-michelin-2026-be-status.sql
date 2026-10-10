-- cleanup-michelin-2026-be-status.sql
-- CompassEats, Oct 10 2026. Belgium & Luxembourg cleanup, open item 1a of
-- handoff-belgium-luxembourg-retired-2026-10-10. Status-only change on 2 venues.
-- Population: the 3 legacy Michelin rows with no 2026 card (La Paix, Kommilfoo,
--   La Table de Manon). Michelin pages give 404 "Restaurant not found" (read Oct 10).
--   ve_54dcd1ca27 La Paix (Brussels): 'closed' -> 'active'. Ben Q1 B (Oct 10).
--     The Anderlecht site closed July 3, 2026 (BX1). The restaurant reopened Sep 15, 2026
--     at the Corinthia Grand Hotel Astoria, 103 rue Royale, Brussels: same name, same
--     chef (David Martin), same city (Elle Belgium, Sep 28, 2026; La Libre, Jun 20, 2026).
--     The standing rules do not cover a relocation in the same city; Ben decided: same business.
--     Awards kept: 1443 Michelin 2025 Two Stars, 1444 Best Chef 2025, 1445 OAD 2025, 1446 La Liste 2026.
--   ve_a5ee6f10f9 La Table de Manon (Grandhan): 'active' -> 'closed'.
--     Paris Match (Sep 23, 2026): the venue site announced a permanent closure.
--     Paris Match (Oct 5, 2026) refers to the same closure. Michelin card gone.
--     Rule: the evidence agrees -> closed (Olamaie precedent). Award kept: 5195 Michelin 2025 One Star.
--   Not in this file: Kommilfoo ve_697073dab3 stays 'active' (conflicting evidence: card gone,
--     2026 star article lists it, venue site live). Recheck list.
-- Precedent: Texas and Germany status changes (no ledger row, trigger audit only).
-- Guards: venue ids md5 (by id, ',') e1da375e1fb84b9cfa9f47cef0175c20; name, city and status per venue; award rows.
-- Expected: 2 venues UPDATE, 2 trigger audit rows, each changes only 'status'. No ledger row.
-- After: active 10,867 -> 10,867, closed 366 -> 366 (one each way). Nothing else changes.
-- Dry run: send only the DO block through the Read connector. All pre-checks run, then the
--   block stops at the first UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  vids     text[] := ARRAY['ve_54dcd1ca27', 've_a5ee6f10f9'];
  n        int;
  x        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
BEGIN
  -- 1. Guards
  IF md5(array_to_string(vids, ',')) <> 'e1da375e1fb84b9cfa9f47cef0175c20' THEN
    RAISE EXCEPTION 'venue id list md5 does not match';
  END IF;

  SELECT count(*) INTO x FROM venues
   WHERE (id = 've_54dcd1ca27' AND name = 'La Paix' AND city_id = 'ci_954918891f' AND status = 'closed')
      OR (id = 've_a5ee6f10f9' AND name = 'La Table de Manon' AND city_id = 'ci_ad48068d44' AND status = 'active');
  IF x <> 2 THEN RAISE EXCEPTION 'venue name, city or status changed: % of 2 agree', x; END IF;

  -- The award rows stay; check they are the ones read on Oct 10
  SELECT count(*) INTO x FROM awards
   WHERE (id = 1443 AND venue_id = 've_54dcd1ca27' AND source_id = 'michelin' AND year = 2025 AND category = 'Two Stars')
      OR (id = 5195 AND venue_id = 've_a5ee6f10f9' AND source_id = 'michelin' AND year = 2025 AND category = 'One Star');
  IF x <> 2 THEN RAISE EXCEPTION 'Michelin 2025 rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = ANY (vids);
  IF x <> 5 THEN RAISE EXCEPTION 'award rows on the plan venues % (expected 5)', x; END IF;

  -- 2. Counts before
  SELECT count(*) INTO x FROM venues;                   IF x <> 11233 THEN RAISE EXCEPTION 'venues before % (expected 11233)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                        IF x <> 10867 THEN RAISE EXCEPTION 'active before % (expected 10867)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                        IF x <> 366 THEN RAISE EXCEPTION 'closed before % (expected 366)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 80 OR led_max <> 111 THEN RAISE EXCEPTION 'ledger before % / max % (expected 80 / 111)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 105853 OR aud_max <> 110088 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 105853 / 110088)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE venues SET status = 'active' WHERE id = 've_54dcd1ca27' AND status = 'closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'La Paix updated % (expected 1)', n; END IF;
  UPDATE venues SET status = 'closed' WHERE id = 've_a5ee6f10f9' AND status = 'active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'La Table de Manon updated % (expected 1)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM venues
   WHERE (id = 've_54dcd1ca27' AND status = 'active') OR (id = 've_a5ee6f10f9' AND status = 'closed');
  IF x <> 2 THEN RAISE EXCEPTION 'plan venues in end state % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM venues;                   IF x <> 11233 THEN RAISE EXCEPTION 'venues after % (expected 11233)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                        IF x <> 10867 THEN RAISE EXCEPTION 'active after % (expected 10867)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                        IF x <> 366 THEN RAISE EXCEPTION 'closed after % (expected 366)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = ANY (vids);
  IF x <> 5 THEN RAISE EXCEPTION 'award rows changed: %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;    IF x <> 80 THEN RAISE EXCEPTION 'ledger changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 2 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.row_pk = ANY (vids)
     AND ((a.row_pk = 've_54dcd1ca27' AND a.old_row->>'status' = 'closed' AND a.new_row->>'status' = 'active')
       OR (a.row_pk = 've_a5ee6f10f9' AND a.old_row->>'status' = 'active' AND a.new_row->>'status' = 'closed'))
     AND (SELECT count(*) FROM jsonb_object_keys(a.new_row) k
           WHERE a.old_row->k IS DISTINCT FROM a.new_row->k) = 1;
  IF x <> 2 THEN RAISE EXCEPTION 'status-only audit rows % (expected 2)', x; END IF;
END
$do$;
COMMIT;
