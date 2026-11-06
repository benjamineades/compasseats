-- load-michelin-d-finland-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Finland. Ben go, Nov 6 2026 12:09 ET (run as built; choices 2-3 open). This file runs only after Ben's "go".
-- 10 rows keep year 2026 and get the card URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: relay-fi-2026-cards-2026-11-06.txt sha256 c1c962cfbc0c3ec86b2466db334e863b910e2774d28bea226d5cc2c5981da94b.
-- Expected after: awards 29052 unchanged; ledger 315 rows; audit_log +10.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$2034~ve_991822a867~Two Stars~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/palace
5344~ve_8d97c80bbf~One Star~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/demo
5346~ve_f2681f7074~One Star~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/finnjavel-salonki
5350~ve_efedd2c161~Two Stars~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/gron
5353~ve_90bbc92525~One Star~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/olo
7456~ve_9713413b6e~One Star~https://guide.michelin.com/us/en/uusimaa/porvoo_1627402/restaurant/var-1198201
8761~ve_1a3cc51995~One Star~https://guide.michelin.com/us/en/southwest-finland/turku/restaurant/kaskis
10458~ve_84bbfb78f5~Bib Gourmand~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/305
10460~ve_4b5f962e61~Bib Gourmand~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/bona-fide
10463~ve_a1a7185073~Bib Gourmand~https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/nolla$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '5d7c1cd4e3d1160411734c843655f8b5' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso = 'FI') y;
  IF fp IS DISTINCT FROM '798fd0c84a8d32a8cabddb543da7ccee' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11512 OR (SELECT count(*) FROM venues WHERE status='closed') <> 319 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11512 OR (SELECT count(*) FROM source_capture_ledger) <> 314 OR (SELECT max(id) FROM source_capture_ledger) <> 368 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129013 OR u2 <> 134842 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((21045, 've_27ca9196d7', 'https://guide.michelin.com/us/en/uusimaa/helsinki/restaurant/boreal'))) <> 1 THEN RAISE EXCEPTION 'rows with URL'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 10 THEN RAISE EXCEPTION 'urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',10,'cleanup:load-michelin-d-finland-2026-11-06 | rule 2.1.7: Nordic 2026, Jun 1, 2026, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards | year stays 2026, source_url = the card (/us/en/), all 11 card labels 2026 read Nov 6 2026, retire 0 | relay sha256 c1c962cfbc0c3ec86b2466db334e863b910e2774d28bea226d5cc2c5981da94b | Ben go, Nov 6 2026 12:09 ET (run as built; choices 2-3 open)');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso = 'FI';
  IF n <> 11 OR u1 <> 11 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 315 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134842 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=10' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
