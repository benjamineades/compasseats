-- closure-michelin-d-sweden-jh-matbar-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Sweden, step 2. Ben SE 3: A, Nov 6 2026 15:55 ET. This file runs only after Ben's "go".
-- 1 closure: JH matbar ve_7c9cd89dc7 (Ystad). Status closed, listing unpublished, Ystad venues_count 1 to 0. Recheck May 2027 (Malmo reopening).
-- Award rows 13006 and 13007 stay. Slug stays. Price stays. No redirect.
-- Evidence: own site jhmatbar.se: leaves Ystad after five years, Malmo, reopening May 2027; card 404 Nov 6 2026.
-- Expected after: venues 11831 (active 11510, closed 321); awards 29052; cities sum 11510; Ystad 0; ledger 320 rows; audit_log +3.
BEGIN;
DO $load$
DECLARE
  n bigint; s text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id) FROM venues v WHERE v.id='ve_7c9cd89dc7') IS DISTINCT FROM '04238af57c14d4215b7f06032c935336' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='ve_7c9cd89dc7') <> 1 OR (SELECT count(*) FROM listings WHERE venue_id='ve_7c9cd89dc7' AND published) <> 1 THEN RAISE EXCEPTION 'listing before'; END IF;
  IF (SELECT string_agg(id||'|'||source_id||'|'||year||'|'||category||'|'||coalesce(source_url,'-'), ',' ORDER BY id) FROM awards WHERE venue_id='ve_7c9cd89dc7')
     IS DISTINCT FROM '13006|michelin|2025|Bib Gourmand|-,13007|michelin|2026|Bib Gourmand|https://guide.michelin.com/fi/en/article/michelin-guide-ceremony/new-good-value-bib-gourmand-restaurants-nordic-countries-denmark-finland-iceland-norway-sweden' THEN RAISE EXCEPTION 'awards of venue'; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11511 OR (SELECT count(*) FROM venues WHERE status='closed') <> 320 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3344 OR (SELECT sum(venues_count) FROM cities) <> 11511 OR (SELECT venues_count FROM cities WHERE id='ci_d5e7c73654') <> 1 OR (SELECT count(*) FROM source_capture_ledger) <> 319 OR (SELECT max(id) FROM source_capture_ledger) <> 373 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129093 OR u2 <> 134922 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  -- WRITE: start
  UPDATE venues SET status='closed' WHERE id='ve_7c9cd89dc7' AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'closure'; END IF;
  UPDATE listings SET published=false WHERE venue_id='ve_7c9cd89dc7' AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'unpublish'; END IF;
  UPDATE cities SET venues_count=0 WHERE id='ci_d5e7c73654' AND venues_count=1; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ystad'; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',1,'closure:closure-michelin-d-sweden-jh-matbar-2026-11-06 | venue ve_7c9cd89dc7 JH matbar (Ystad) closed: own site (https://jhmatbar.se/) thanks Ystad for five years, moves to Malmo, reopening May 2027, no closing date given; card jh-matbar 404 on Nov 6 2026; Nordic 2026 Bib article lists it | same treatment as Lasai (closure with a reopening date): recheck May 2027 | awards 13006 (2025) and 13007 (2026, article URL, ledger 373) stay, slug stays, no redirect | Ystad venues_count 1 to 0 | Ben SE 3: A, Nov 6 2026 15:55 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11510 OR (SELECT count(*) FROM venues WHERE status='closed') <> 321 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11510 OR (SELECT venues_count FROM cities WHERE id='ci_d5e7c73654') <> 0 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 320 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134922 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=1,listings:UPDATE=1,venues:UPDATE=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
