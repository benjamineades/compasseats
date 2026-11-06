-- load-michelin-d-lithuania-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Lithuania. Ben LT 1-3: A, FI 2-3: A, Nov 6 2026 14:34 ET. This file runs only after Ben's "go".
-- 9 rows keep year 2026 and get the card URL. 1 rows get the article URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: relay-lt-2026-cards-2026-11-06.txt sha256 cacd419a5076318467a151e95a03811d58786d6994c9141b2f7b71cf25429883.
-- Expected after: awards 29052 unchanged; ledger 316 rows; audit_log +10.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$8934~ve_c576098456~One Star~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/dziaugsmas
8937~ve_abd926cf7d~One Star~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/nineteen18
10726~ve_f8906e99b1~Bib Gourmand~https://guide.michelin.com/us/en/kaunas-region/kaunas_1976586/restaurant/numan
12853~ve_3bf46450e2~Bib Gourmand~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/14horses
12855~ve_64b1007090~Bib Gourmand~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/augustin
12857~ve_f5338cfe5c~Bib Gourmand~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/b-arn-bistro
12859~ve_46640fd4c8~Bib Gourmand~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/el-gato-negro-1219046
12862~ve_20dadd95d6~Bib Gourmand~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/gaspar-s
12865~ve_3afc27c04f~Bib Gourmand~https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/le-travi$plan$;
  rl2 text := $plan$8930~ve_87f2380c44~One Star~https://guide.michelin.com/lt/en/article/michelin-guide-ceremony/all-the-winners-michelin-guide-lithuania-2026-has-been-unveiled-new-stars-bib-gourmands-special-awards$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> 'd7f312ad4689df4f8a0a1210df73dc4e' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso = 'LT') y;
  IF fp IS DISTINCT FROM '1ee3c020de4e842f5fffa292dbb68dfd' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11512 OR (SELECT count(*) FROM venues WHERE status='closed') <> 319 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11512 OR (SELECT count(*) FROM source_capture_ledger) <> 315 OR (SELECT max(id) FROM source_capture_ledger) <> 369 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129023 OR u2 <> 134852 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((21130, 've_c6c4bba54c', 'https://guide.michelin.com/us/en/kaunas-region/birstonas_1972842/restaurant/pievos'), (21129, 've_7a0520c296', 'https://guide.michelin.com/us/en/vilnius-region/radiskis_7770291/restaurant/red-brick'), (21128, 've_7483bad22f', 'https://guide.michelin.com/us/en/vilnius-region/vilnius_1985479/restaurant/deep-roots'))) <> 3 THEN RAISE EXCEPTION 'rows with URL'; END IF;
  IF md5(rl2) <> '2915dca34ffd7f109c5afebd82fb975d' THEN RAISE EXCEPTION 'article plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl2,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'article plan rows %', n; END IF;
  IF (SELECT count(*) FROM awards WHERE source_url='https://guide.michelin.com/lt/en/article/michelin-guide-ceremony/all-the-winners-michelin-guide-lithuania-2026-has-been-unveiled-new-stars-bib-gourmands-special-awards') <> 2 THEN RAISE EXCEPTION 'article url rows 8930'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 9 THEN RAISE EXCEPTION 'urls %', n; END IF;
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl2,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'article urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',10,'cleanup:load-michelin-d-lithuania-2026-11-06 | rule 2.1.7: Lithuania 2026, Jun 5, 2026, https://guide.michelin.com/lt/en/article/michelin-guide-ceremony/all-the-winners-michelin-guide-lithuania-2026-has-been-unveiled-new-stars-bib-gourmands-special-awards | year stays 2026, source_url = the card (/us/en/), all 12 card labels 2026 read Nov 6 2026, retire 0 | article URL (card left the site, no capture after the ceremony): 8930 Demo (Vilnius): article Jun 5 2026 names it One Star, card demo-1210016 404 on Nov 6 2026, Wayback last capture Nov 8 2025 (label 2025) | relay sha256 cacd419a5076318467a151e95a03811d58786d6994c9141b2f7b71cf25429883 | Ben LT 1-3: A, FI 2-3: A, Nov 6 2026 14:34 ET');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso = 'LT';
  IF n <> 15 OR u1 <> 15 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 316 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134852 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=10' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
