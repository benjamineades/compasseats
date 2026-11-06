#!/usr/bin/env python3
"""Status file: 4 temporary closures from the Michelin cards. Ben choice 3:A, Nov 6 01:03 ET."""
import hashlib
V=[('ve_05d3c5844a','Smoked Room','ci_3c40d285e6'),('ve_2407cf20a7','Ossiano','ci_3c40d285e6'),('ve_30cb4b84d8','Nolan','ci_8fde6a6592'),('ve_556d69255a','Dinner by Heston Blumenthal','ci_3c40d285e6')]
FP=hashlib.md5('\n'.join(f"{i}|{n}|active|{c}" for i,n,c in V).encode()).hexdigest()
ids=','.join(f"'{i}'" for i,_,_ in V)
sql=f"""-- status-michelin-a1-closures-2026-11-06.sql
-- CompassEats, Nov 6 2026. Ben choice 3:A, Nov 6 01:03 ET. This file runs only after Ben's "go".
-- Temporary closure rule (Sep 28) and closed rule (Nov 2): status closed and published false, same transaction. Award rows stay. Slugs stay. Status fixes write no ledger row.
-- Evidence, Michelin cards read Nov 6, 2026: Smoked Room, Ossiano, Dinner by Heston Blumenthal "This restaurant is temporarily closed". Nolan "Temporarily closed due to relocation".
-- Recheck: Ossiano in December (press: bookings from December). Others no date.
-- Expected after: venues 11795 (active 11479, closed 316); cities sum 11479; Dubai 97 to 94; Athens 35 to 34; audit_log +10.
BEGIN;
DO $load$
DECLARE n bigint; s text; aud_max bigint; ids text[] := ARRAY[{ids}];
BEGIN
  IF (SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) FROM venues v WHERE v.id = ANY(ids)) IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'venue fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = ANY(ids) AND published) <> 4 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11795 OR (SELECT count(*) FROM venues WHERE status='active') <> 11483 OR (SELECT count(*) FROM venues WHERE status='closed') <> 312 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28927 OR (SELECT max(id) FROM awards) <> 36098 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11483 OR (SELECT venues_count FROM cities WHERE id='ci_3c40d285e6') <> 97 OR (SELECT venues_count FROM cities WHERE id='ci_8fde6a6592') <> 35 OR (SELECT count(*) FROM source_capture_ledger) <> 293 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 128316 OR aud_max <> 134145 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- WRITE: start
  UPDATE venues SET status='closed' WHERE id = ANY(ids) AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'closures %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id = ANY(ids) AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'unpublish %', n; END IF;
  UPDATE cities SET venues_count=94 WHERE id='ci_3c40d285e6' AND venues_count=97; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'dubai'; END IF;
  UPDATE cities SET venues_count=34 WHERE id='ci_8fde6a6592' AND venues_count=35; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'athens'; END IF;
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11795 OR (SELECT count(*) FROM venues WHERE status='active') <> 11479 OR (SELECT count(*) FROM venues WHERE status='closed') <> 316 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28927 OR (SELECT count(*) FROM source_capture_ledger) <> 293 THEN RAISE EXCEPTION 'awards, ledger after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11479 THEN RAISE EXCEPTION 'sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=2,listings:UPDATE=4,venues:UPDATE=4' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open('status-michelin-a1-closures-2026-11-06.sql','w',encoding='utf8').write(sql)
print(hashlib.sha256(sql.encode()).hexdigest(),FP)
do=sql[sql.index('DO $load$'):sql.index('  -- WRITE: start')]
print(do+"  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;")
