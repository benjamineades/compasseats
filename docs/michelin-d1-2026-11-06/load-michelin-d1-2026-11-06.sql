-- load-michelin-d1-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D1: Faroe Islands, Iceland, New Zealand. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 6 rows keep year 2026 and get the card URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: docs/michelin-d1-2026-11-06/relay-d1-2026-cards-2026-11-06.txt sha256 401ce717d7acd2459994d913b1fb6649a030fdf8d774ba37dda0d01503336170.
-- Expected after: awards 29052 unchanged; ledger 313 rows; audit_log +6.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$3444~ve_42a5f4e1d3~Two Stars~https://guide.michelin.com/us/en/faroe-islands/torshavn/restaurant/paz
5212~ve_84b5f7966e~One Star~https://guide.michelin.com/us/en/southern-peninsula/grindavik/restaurant/moss
7547~ve_9ee24299b1~One Star~https://guide.michelin.com/us/en/capital-region-iceland/reykjavik/restaurant/dill1186101
7550~ve_b77b9b1c1c~One Star~https://guide.michelin.com/us/en/capital-region-iceland/reykjavik/restaurant/ox
21191~ve_47d4b5d515~Bib Gourmand~https://guide.michelin.com/us/en/north-island/auckland_2302926/restaurant/atelier-1247986
21207~ve_6c7a46653b~Bib Gourmand~https://guide.michelin.com/us/en/south-island/wanaka_2306683/restaurant/muttonbird$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'df2f4c1b152ffdf08b2844126e27d444' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('FO','IS','NZ')) y;
  IF fp IS DISTINCT FROM 'f24cfda8d939dcd5823168e5b91ec9ce' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11512 OR (SELECT count(*) FROM venues WHERE status='closed') <> 319 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11512 OR (SELECT count(*) FROM source_capture_ledger) <> 311 OR (SELECT max(id) FROM source_capture_ledger) <> 365 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 128829 OR u2 <> 134658 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 6 THEN RAISE EXCEPTION 'urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',4,'cleanup:load-michelin-d1-2026-11-06 | rule 2.1.7: Nordic 2026, Jun 1, 2026, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards | year stays 2026, source_url = the card (/us/en/), card label 2026 read Nov 6 2026, retire 0 | FO 1 (PAZ, card guide Denmark), IS 3 | relay sha256 401ce717d7acd2459994d913b1fb6649a030fdf8d774ba37dda0d01503336170 | DRAFT, choices not yet given'),
    ('michelin','award',2,'cleanup:load-michelin-d1-2026-11-06 | rule 2.1.7: New Zealand 2026, Jun 30, 2026, https://guide.michelin.com/jp/en/article/michelin-guide-ceremony/michelin-guide-new-zealand-2026-restaurant-selection | year stays 2026, source_url = the card (/us/en/), card label 2026 read Nov 6 2026, retire 0 | relay sha256 401ce717d7acd2459994d913b1fb6649a030fdf8d774ba37dda0d01503336170 | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso IN ('FO','IS','NZ');
  IF n <> u1 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 313 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134658 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=6' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
