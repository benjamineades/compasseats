-- closure-michelin-d-norway-bar-amour-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Norway, step 2. Ben NO 2: A, Nov 6 2026 15:17 ET, go 15:42 ET. This file runs only after Ben's "go".
-- 1 closure: Bar Amour ve_6b4eb76969 (Oslo). Status closed, listing unpublished, Oslo venues_count 20 to 19.
-- Award rows 7099 and 7100 stay. Slug stays. Price stays. No redirect.
-- Evidence: Michelin Nordic 2026 full star list "(Update: Now Closed)"; Store norske leksikon (Aug 8 2026): closed first half of 2026; card 404 Nov 6 2026.
-- Expected after: venues 11831 (active 11511, closed 320); awards 29052; cities sum 11511; Oslo 19; ledger 318 rows; audit_log +3.
BEGIN;
DO $load$
DECLARE
  n bigint; s text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id) FROM venues v WHERE v.id='ve_6b4eb76969') IS DISTINCT FROM 'ffa8821cb5e638cd3cc3428ae3881a04' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='ve_6b4eb76969') <> 1 OR (SELECT count(*) FROM listings WHERE venue_id='ve_6b4eb76969' AND published) <> 1 THEN RAISE EXCEPTION 'listing before'; END IF;
  IF (SELECT string_agg(id||'|'||source_id||'|'||year||'|'||category||'|'||coalesce(source_url,'-'), ',' ORDER BY id) FROM awards WHERE venue_id='ve_6b4eb76969')
     IS DISTINCT FROM '7099|michelin|2025|One Star|-,7100|michelin|2026|One Star|https://web.archive.org/web/20260601213429id_/https://guide.michelin.com/no/en/oslo-region/oslo/restaurant/bar-amour' THEN RAISE EXCEPTION 'awards of venue'; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11512 OR (SELECT count(*) FROM venues WHERE status='closed') <> 319 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3344 OR (SELECT sum(venues_count) FROM cities) <> 11512 OR (SELECT venues_count FROM cities WHERE id='ci_8cfbfaefa5') <> 20 OR (SELECT count(*) FROM source_capture_ledger) <> 317 OR (SELECT max(id) FROM source_capture_ledger) <> 371 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129055 OR u2 <> 134884 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- WRITE: start
  UPDATE venues SET status='closed' WHERE id='ve_6b4eb76969' AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'closure'; END IF;
  UPDATE listings SET published=false WHERE venue_id='ve_6b4eb76969' AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'unpublish'; END IF;
  UPDATE cities SET venues_count=19 WHERE id='ci_8cfbfaefa5' AND venues_count=20; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'oslo'; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',1,'closure:closure-michelin-d-norway-bar-amour-2026-11-06 | venue ve_6b4eb76969 Bar Amour (Oslo) closed: Michelin Nordic 2026 full star list marks it Now Closed (https://guide.michelin.com/fi/en/article/michelin-guide-ceremony/full-list-of-michelin-star-restaurants-in-the-nordic-countries); Store norske leksikon (edited Aug 8 2026) says closed in the first half of 2026 (https://snl.no/Bar_Amour); card bar-amour 404 on Nov 6 2026 | awards 7099 (2025) and 7100 (2026, capture URL, ledger 371) stay, slug stays, no redirect | Oslo venues_count 20 to 19 | Ben NO 2: A, Nov 6 2026 15:17 ET, go 15:42 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11511 OR (SELECT count(*) FROM venues WHERE status='closed') <> 320 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11511 OR (SELECT venues_count FROM cities WHERE id='ci_8cfbfaefa5') <> 19 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 318 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134884 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=1,listings:UPDATE=1,venues:UPDATE=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
