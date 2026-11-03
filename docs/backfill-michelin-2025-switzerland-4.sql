-- backfill-michelin-2025-switzerland-4.sql
-- CompassEats, Nov 3 2026. Swiss open item: 2025 Michelin rows for the 4 venues that have no 2025 row. Run after the price file.
-- Ben: Nov 3 16:29 ET "1,2,3". Evidence: each row = web.archive.org capture of the venue's own card (id_ URL, read in the built-in browser Nov 3 2026);
-- the card meta and JSON-LD name the category and the 2025 guide. The Nov 2 morning list read (claude/ch-live-list-pre-update-2026-11-02.txt) has the same 4 cards in the same categories.
-- Expected after: awards 25,325; Michelin 2025 4,998 (no URL still 3,213); ledger 246; audit +4 (to 125,569). No other table changes.
BEGIN;
DO $do$
DECLARE n int; x bigint; aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
  job_txt constant text := 'backfill:michelin-2025-switzerland-4 | Swiss open item (Ben Nov 3 16:29 ET "1,2,3"): 2025 rows for 4 venues with none | source_url = web.archive.org capture of the card, meta names the 2025 guide | ve_db48bdeac3, ve_a3d2920b36, ve_781166e4b0, ve_147506ea77';
BEGIN
  SELECT count(*) INTO x FROM awards; IF x <> 25321 THEN RAISE EXCEPTION 'awards before %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2025; IF x <> 4994 THEN RAISE EXCEPTION 'Michelin 2025 before %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE year=2025 AND venue_id IN ('ve_db48bdeac3','ve_a3d2920b36','ve_781166e4b0','ve_147506ea77'); IF x <> 0 THEN RAISE EXCEPTION '2025 rows on the 4 venues %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='active' AND
    ((id='ve_db48bdeac3' AND name='Restaurant LA') OR (id='ve_a3d2920b36' AND name='La Croix d''Or') OR (id='ve_781166e4b0' AND name='Bären') OR (id='ve_147506ea77' AND name='Bären'));
  IF x <> 4 THEN RAISE EXCEPTION 'venues %', x; END IF;
  SELECT count(*) INTO x FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND (a.venue_id,a.category) IN (('ve_db48bdeac3','One Star'),('ve_a3d2920b36','One Star'),('ve_781166e4b0','Bib Gourmand'),('ve_147506ea77','Bib Gourmand'));
  IF x <> 4 THEN RAISE EXCEPTION '2026 rows %', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger; IF led_n <> 191 OR led_max <> 245 THEN RAISE EXCEPTION 'ledger before % / %', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log; IF aud_n <> 119736 OR aud_max <> 125565 THEN RAISE EXCEPTION 'audit before % / %', aud_n, aud_max; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
    ('ve_db48bdeac3','michelin',2025,NULL,'One Star',NULL,'https://web.archive.org/web/20251115192248id_/https://guide.michelin.com/en/basel-stadt/basel/restaurant/restaurant-la'),
    ('ve_a3d2920b36','michelin',2025,NULL,'One Star',NULL,'https://web.archive.org/web/20251110102357id_/https://guide.michelin.com/en/vaud/ballaigues/restaurant/la-croix-d-or-1202971'),
    ('ve_781166e4b0','michelin',2025,NULL,'Bib Gourmand',NULL,'https://web.archive.org/web/20260111022911id_/https://guide.michelin.com/en/bern-region/schwarzenburg/restaurant/baren-182932'),
    ('ve_147506ea77','michelin',2025,NULL,'Bib Gourmand',NULL,'https://web.archive.org/web/20251206211453id_/https://guide.michelin.com/ch/de/bern-region/utzenstorf/restaurant/baren180243');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'inserted %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin','award',4,job_txt);

  SELECT count(*) INTO x FROM awards; IF x <> 25325 THEN RAISE EXCEPTION 'awards after %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2025; IF x <> 4998 THEN RAISE EXCEPTION 'Michelin 2025 after %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger; IF x <> 192 THEN RAISE EXCEPTION 'ledger after %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max; IF x <> 4 THEN RAISE EXCEPTION 'audit rows %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max AND table_name='awards' AND action='INSERT' AND new_row->>'source_url' LIKE 'https://web.archive.org/web/%id_/https://guide.michelin.com/%'; IF x <> 4 THEN RAISE EXCEPTION 'audit awards %', x; END IF;
END
$do$;
COMMIT;
