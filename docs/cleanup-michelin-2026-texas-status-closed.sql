-- cleanup-michelin-2026-texas-status-closed.sql
-- CompassEats, Oct 10 2026. Texas cleanup (open item 3 of handoff-texas-promoted-2026-10-10).
-- Status-only change: 2 Texas venues from 'active' to 'closed'.
-- Rule (Plan v1.30 standing rules, Sep 28): a venue with closure evidence takes status closed.
--   Its award rows stay as history (2025 history rule). Nothing is deleted.
--   ve_59ce7cc401 Olamaie (Austin)
--     Michelin 2026 card page "Restaurant not found" (Cowork capture, Oct 9); not in the
--     2026 Texas star list (Oct 8). Venue site olamaieaustin.com: closed Sunday, July 19
--     (read Oct 10). KUT (Jul 9, 2026): last service July 19, 2026.
--     Awards kept: 3833 Michelin 2025 One Star, 3835 OAD 2025, 3834 OAD 2026.
--   ve_6034ffec5f Killen's (Houston, 101 Heights Blvd.)
--     NOT a twin of Killen's BBQ (Pearland, ve_d9e28a8c8e): a separate Ronnie Killen
--     restaurant in the Heights. Its Michelin page .../texas/houston_2986624/restaurant/killen-s
--     still shows the 2025 Bib Gourmand (read Oct 10); it is not in the 2026 Texas Bib list
--     (54 cards, Cowork, Oct 9). CultureMap Houston (Jun 22, 2026), DiningOut (Jun 26, upd.
--     Jul 8, 2026) and Hoodline (Jun 2026): final service Sunday, July 19, 2026; property sold.
--     Award kept: 10600 Michelin 2025 Bib Gourmand (a real 2025 card, not a duplicate).
-- Precedent: GB&I and Germany status changes (no ledger row, trigger audit only).
-- Guards: venue ids md5 (by id, ',') ac3641317a826cd9b76d092c4eed0820; name, city and status per venue.
-- Expected: 2 venues UPDATE, 2 trigger audit rows, each changes only 'status'. No ledger row.
-- After: active 10,868 -> 10,866, closed 364 -> 366. Nothing else changes.
-- Dry run: send only the DO block through the Read connector. All pre-checks run, then the
--   block stops at the UPDATE with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  vids     text[] := ARRAY['ve_59ce7cc401', 've_6034ffec5f'];
  n        int;
  x        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
BEGIN
  -- 1. Guards
  IF md5(array_to_string(vids, ',')) <> 'ac3641317a826cd9b76d092c4eed0820' THEN
    RAISE EXCEPTION 'venue id list md5 does not match';
  END IF;

  SELECT count(*) INTO x FROM venues WHERE id = ANY (vids) AND status = 'active';
  IF x <> 2 THEN RAISE EXCEPTION 'active venues in plan % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM venues
   WHERE (id = 've_59ce7cc401' AND name = 'Olamaie' AND city_id = 'ci_229979fce5')
      OR (id = 've_6034ffec5f' AND name = 'Killen''s' AND city_id = 'ci_7315ac7ba3');
  IF x <> 2 THEN RAISE EXCEPTION 'venue name or city changed: % of 2 agree', x; END IF;

  -- The award rows stay; check they are the ones read on Oct 10
  SELECT count(*) INTO x FROM awards
   WHERE (id = 3833 AND venue_id = 've_59ce7cc401' AND source_id = 'michelin' AND year = 2025 AND category = 'One Star')
      OR (id = 10600 AND venue_id = 've_6034ffec5f' AND source_id = 'michelin' AND year = 2025 AND category = 'Bib Gourmand');
  IF x <> 2 THEN RAISE EXCEPTION 'Michelin 2025 rows % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = ANY (vids);
  IF x <> 4 THEN RAISE EXCEPTION 'award rows on the plan venues % (expected 4)', x; END IF;

  -- 2. Counts before
  SELECT count(*) INTO x FROM venues;                   IF x <> 11232 THEN RAISE EXCEPTION 'venues before % (expected 11232)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                        IF x <> 10868 THEN RAISE EXCEPTION 'active before % (expected 10868)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                        IF x <> 364 THEN RAISE EXCEPTION 'closed before % (expected 364)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 77 OR led_max <> 106 THEN RAISE EXCEPTION 'ledger before % / max % (expected 77 / 106)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 105355 OR aud_max <> 109340 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 105355 / 109340)', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE venues SET status = 'closed' WHERE id = ANY (vids) AND status = 'active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues updated % (expected 2)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM venues WHERE id = ANY (vids) AND status = 'closed';
  IF x <> 2 THEN RAISE EXCEPTION 'closed venues in plan after % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM venues;                   IF x <> 11232 THEN RAISE EXCEPTION 'venues after % (expected 11232)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                        IF x <> 10866 THEN RAISE EXCEPTION 'active after % (expected 10866)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                        IF x <> 366 THEN RAISE EXCEPTION 'closed after % (expected 366)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = ANY (vids);
  IF x <> 4 THEN RAISE EXCEPTION 'award rows changed: %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;    IF x <> 77 THEN RAISE EXCEPTION 'ledger changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 2 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.row_pk = ANY (vids)
     AND a.old_row->>'status' = 'active' AND a.new_row->>'status' = 'closed'
     AND (SELECT count(*) FROM jsonb_object_keys(a.new_row) k
           WHERE a.old_row->k IS DISTINCT FROM a.new_row->k) = 1;
  IF x <> 2 THEN RAISE EXCEPTION 'status-only audit rows % (expected 2)', x; END IF;
END
$do$;
COMMIT;
