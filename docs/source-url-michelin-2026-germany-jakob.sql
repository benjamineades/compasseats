-- source-url-michelin-2026-germany-jakob.sql
-- CompassEats, Oct 8 2026. Germany cleanup, item b (batch 3 of the cleanup). Ben chose
--   option A on question 2 (Oct 8). Run after batch 2.
-- Row: 7349, Gasthaus Jakob ve_1c7dc6f4de (Perasdorf), Michelin 2026 One Star, no source_url.
-- Evidence (read Oct 8 in the browser pane):
--   Michelin's own 2026 star list article for Germany names "Perasdorf - Gasthaus Jakob" in the
--   One Star block (279 entries = the ceremony count). The article names the edition
--   ("MICHELIN Guide Deutschland 2026"). The venue card page gives "Restaurant not found".
-- Method: the list-page form of ruling condition 7 (Sep 28): when no venue page exists, the row
--   takes the list page URL. Only this row uses the article URL.
-- Status: no change (venue stays 'active'). A removed card page and a current star list conflict,
--   so the conflicting-evidence rule keeps the status and puts the venue on the recheck list.
-- Expected: 1 awards UPDATE (trigger audit row, only source_url changes), 1 ledger row.
-- After: Germany Michelin 2026 rows 484, unsourced 0 (batch 2 done first).
-- Dry run: send only the DO block through the Read connector; it stops at the UPDATE.

BEGIN;
DO $do$
DECLARE
  url      text := 'https://guide.michelin.com/de/de/article/michelin-guide-ceremony/alle-sternerestaurants---michelin-guide-deutschland-2026';
  n        int;
  x        int;
  y        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
  job_txt  text := 'source-url:michelin-2026-germany-jakob | Germany cleanup item b (Ben, Oct 8): award 7349 Gasthaus Jakob (Perasdorf), One Star 2026, venue card removed ("Restaurant not found"); the Michelin 2026 Germany star list article names it in the One Star block | list page URL, condition 7 form';
BEGIN
  IF md5(url) <> md5('https://guide.michelin.com/de/de/article/michelin-guide-ceremony/alle-sternerestaurants---michelin-guide-deutschland-2026') THEN
    RAISE EXCEPTION 'url changed';
  END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id = 7349 AND venue_id = 've_1c7dc6f4de' AND source_id = 'michelin' AND year = 2026
     AND category = 'One Star' AND source_url IS NULL AND rank IS NULL AND distinction IS NULL;
  IF x <> 1 THEN RAISE EXCEPTION 'row 7349 not in the expected state'; END IF;
  SELECT count(*) INTO x FROM venues WHERE id = 've_1c7dc6f4de' AND name = 'Gasthaus Jakob' AND status = 'active';
  IF x <> 1 THEN RAISE EXCEPTION 'Gasthaus Jakob venue row changed'; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_url = url;
  IF x <> 0 THEN RAISE EXCEPTION 'article URL already used by % rows', x; END IF;

  SELECT count(*), count(*) FILTER (WHERE a.source_url IS NULL) INTO x, y
    FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2026 AND c.country_iso = 'DE';
  IF x <> 484 OR y <> 1 THEN RAISE EXCEPTION 'Germany 2026 rows % / unsourced % (expected 484 / 1; run batch 2 first)', x, y; END IF;
  SELECT count(*) INTO x FROM awards;            IF x <> 22389 THEN RAISE EXCEPTION 'awards before % (expected 22389)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 69 OR led_max <> 91 THEN RAISE EXCEPTION 'ledger before % / max % (expected 69 / 91)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 104474 OR aud_max <> 108067 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 104474 / 108067)', aud_n, aud_max; END IF;

  UPDATE awards SET source_url = url WHERE id = 7349 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'awards updated % (expected 1)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 1, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  SELECT count(*) INTO x FROM awards;            IF x <> 22389 THEN RAISE EXCEPTION 'awards after % (expected 22389)', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE a.source_url IS NULL) INTO x, y
    FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2026 AND c.country_iso = 'DE';
  IF x <> 484 OR y <> 0 THEN RAISE EXCEPTION 'Germany 2026 rows % / unsourced % (expected 484 / 0)', x, y; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 1 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 1 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'awards' AND a.action = 'UPDATE' AND a.row_pk = '7349'
     AND a.new_row->>'source_url' = url
     AND (SELECT count(*) FROM jsonb_object_keys(a.new_row) k WHERE a.old_row->k IS DISTINCT FROM a.new_row->k) = 1;
  IF x <> 1 THEN RAISE EXCEPTION 'source_url-only audit row not found'; END IF;
END
$do$;
COMMIT;
