-- cleanup-michelin-de-status-active.sql
-- CompassEats, Oct 8 2026. Germany cleanup, item e (batch 1 of the cleanup).
-- Status-only change: 2 Germany venues from 'closed' to 'active'.
-- Rule: the venue holds a live 2026 Michelin card and current evidence shows it open.
--   The temporary-closure rule does not apply (no closure notice). No evidence conflicts.
--   ve_2c3da34a8d Gasthof Alex (Weissenbrunn)
--     live card .../bayern/weissenbrunn/restaurant/gasthof-alex (award 9046, One Star 2026);
--     2026 star list article (One Star block); gasthofalex.de lists regular hours (read Oct 8).
--   ve_b7c3a95507 Pfortenhaus Kloster Eberbach (Eltville am Rhein)
--     live card "Ente Wiesbaden - Pfortenhaus Kloster Eberbach" .../hessen/eltville-am-rhein/restaurant/ente
--     (award 4950, One Star 2026); 2026 star list article (One Star block);
--     kloster-eberbach.de ENTE page lists regular hours; Falstaff (Mar 13, 2026): Ente open at
--     Kloster Eberbach from Mar 18, 2026 during the Nassauer Hof renovation.
-- Both 'closed' values came from the legacy import (audit 6713 and 4532, Aug 14).
-- Precedent: GB&I status changes Sep 28 (audit 107,081-107,083): no ledger row, trigger audit only.
-- Guards: venue ids md5 (by id, ',') be4a762868c9607f462875d86d318af1.
-- Expected: 2 venues UPDATE, 2 trigger audit rows, each changes only 'status'. No ledger row.
-- After: active 10,858 -> 10,860, closed 366 -> 364. Nothing else changes.
-- Dry run: send only the DO block through the Read connector. All pre-checks run, then the
--   block stops at the UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  vids     text[] := ARRAY['ve_2c3da34a8d','ve_b7c3a95507'];
  n        int;
  x        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
BEGIN
  -- 1. Guards
  IF md5(array_to_string(vids, ',')) <> 'be4a762868c9607f462875d86d318af1' THEN
    RAISE EXCEPTION 'venue id list md5 does not match';
  END IF;

  SELECT count(*) INTO x FROM venues WHERE id = ANY (vids) AND status = 'closed';
  IF x <> 2 THEN RAISE EXCEPTION 'closed venues in plan % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM venues
   WHERE (id = 've_2c3da34a8d' AND name = 'Gasthof Alex' AND city_id = 'ci_93dc200b01')
      OR (id = 've_b7c3a95507' AND name = 'Pfortenhaus Kloster Eberbach' AND city_id = 'ci_750700c179');
  IF x <> 2 THEN RAISE EXCEPTION 'venue name or city changed: % of 2 agree', x; END IF;

  -- Each venue holds its live 2026 card
  SELECT count(*) INTO x FROM awards
   WHERE (id = 9046 AND venue_id = 've_2c3da34a8d'
          AND source_url = 'https://guide.michelin.com/us/en/bayern/weissenbrunn/restaurant/gasthof-alex')
      OR (id = 4950 AND venue_id = 've_b7c3a95507'
          AND source_url = 'https://guide.michelin.com/us/en/hessen/eltville-am-rhein/restaurant/ente');
  IF x <> 2 THEN RAISE EXCEPTION 'live card rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id IN (9046, 4950) AND source_id = 'michelin' AND year = 2026 AND category = 'One Star';
  IF x <> 2 THEN RAISE EXCEPTION 'card rows are not Michelin 2026 One Star: % of 2', x; END IF;

  -- 2. Counts before
  SELECT count(*) INTO x FROM venues;                   IF x <> 11224 THEN RAISE EXCEPTION 'venues before % (expected 11224)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                        IF x <> 10858 THEN RAISE EXCEPTION 'active before % (expected 10858)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                        IF x <> 366 THEN RAISE EXCEPTION 'closed before % (expected 366)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 68 OR led_max <> 90 THEN RAISE EXCEPTION 'ledger before % / max % (expected 68 / 90)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 104457 OR aud_max <> 108050 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 104457 / 108050)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE venues SET status = 'active' WHERE id = ANY (vids) AND status = 'closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues updated % (expected 2)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM venues WHERE id = ANY (vids) AND status = 'active';
  IF x <> 2 THEN RAISE EXCEPTION 'active venues in plan after % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM venues;                   IF x <> 11224 THEN RAISE EXCEPTION 'venues after % (expected 11224)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                        IF x <> 10860 THEN RAISE EXCEPTION 'active after % (expected 10860)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                        IF x <> 364 THEN RAISE EXCEPTION 'closed after % (expected 364)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;    IF x <> 68 THEN RAISE EXCEPTION 'ledger changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 2 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.row_pk = ANY (vids)
     AND a.old_row->>'status' = 'closed' AND a.new_row->>'status' = 'active'
     AND (SELECT count(*) FROM jsonb_object_keys(a.new_row) k
           WHERE a.old_row->k IS DISTINCT FROM a.new_row->k) = 1;
  IF x <> 2 THEN RAISE EXCEPTION 'status-only audit rows % (expected 2)', x; END IF;
END
$do$;
COMMIT;
