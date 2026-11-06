-- load-michelin-d-norway-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Norway. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 20 rows keep year 2026 and get the card URL. 2 rows get the article URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: relay-no-2026-cards-2026-11-06.txt sha256 51c51361b6be81bed2451afd438ba3185d36934607f5bbbd6c7f6128d4fcff51.
-- Expected after: awards 29052 unchanged; ledger 317 rows; audit_log +22.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$818~ve_50bb7f89d1~Three Stars~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/maaemo-1194933
1153~ve_9638873fdf~Three Stars~https://guide.michelin.com/us/en/rogaland/stavanger/restaurant/re-naa
2787~ve_f1575a63d4~Two Stars~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/kontrast
4137~ve_1b62257733~Two Stars~https://guide.michelin.com/us/en/hordaland/bergen/restaurant/gaptrast
4141~ve_67056a6a74~One Star~https://guide.michelin.com/us/en/hordaland/bergen/restaurant/lysverket
4143~ve_fb5acf5258~One Star~https://guide.michelin.com/us/en/hordaland/bergen/restaurant/omakase-by-sergey-pak
5951~ve_8396af2504~One Star~https://guide.michelin.com/us/en/agder/lindesnes/restaurant/under
7103~ve_085609e1a1~One Star~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/hot-shop
7105~ve_c5baaf18a6~One Star~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/mon-oncle
7107~ve_330b48914b~One Star~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/sabi-omakase-oslo
7112~ve_7afbcf9868~One Star~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/savage-1205580
7114~ve_df569e236f~One Star~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/stallen
7117~ve_5752a1d819~One Star~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/statholdergaarden
8270~ve_759e2f538c~One Star~https://guide.michelin.com/us/en/rogaland/stavanger/restaurant/hermetikken
8272~ve_8f9de8dd51~One Star~https://guide.michelin.com/us/en/rogaland/stavanger/restaurant/k2-1192264
8274~ve_3694bc6c51~One Star~https://guide.michelin.com/us/en/rogaland/stavanger/restaurant/sabi-omakase
8744~ve_a1a41fcb6d~One Star~https://guide.michelin.com/us/en/trondelag/trondheim/restaurant/speilsalen
11587~ve_222ac1bad7~Bib Gourmand~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/frances-1212050
11590~ve_c525c8e67a~Bib Gourmand~https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/the-little-pickle
12738~ve_7a967f498b~One Star~https://guide.michelin.com/us/en/trondelag/trondheim/restaurant/fagn$plan$;
  rl2 text := $plan$7100~ve_6b4eb76969~One Star~https://web.archive.org/web/20260601213429id_/https://guide.michelin.com/no/en/oslo-region/oslo/restaurant/bar-amour
7119~ve_7a1fc079d2~One Star~https://web.archive.org/web/20260601213435id_/https://guide.michelin.com/no/en/oslo-region/oslo/restaurant/a-l-aise$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '4f90088a6544edd6bda73b2189daa114' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso = 'NO') y;
  IF fp IS DISTINCT FROM '73875eef6924d38f7b9b6aaf564d4fa6' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11512 OR (SELECT count(*) FROM venues WHERE status='closed') <> 319 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11512 OR (SELECT count(*) FROM source_capture_ledger) <> 316 OR (SELECT max(id) FROM source_capture_ledger) <> 370 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129033 OR u2 <> 134862 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((12737, 've_754faabbde', 'https://guide.michelin.com/us/en/trondelag/trondheim/restaurant/fagn-bistro'), (21046, 've_8aa02a036f', 'https://guide.michelin.com/us/en/oslo-region/oslo/restaurant/credo-1248105'), (15905, 've_d71553cf5f', 'https://guide.michelin.com/us/en/nordland/kvitnes_7770468/restaurant/kvitnes-gard'), (21047, 've_a19a34aecc', 'https://guide.michelin.com/us/en/vestland/bekkjarvik_7770446/restaurant/mirabelle-by-orjan-johannessen'))) <> 4 THEN RAISE EXCEPTION 'rows with URL'; END IF;
  IF md5(rl2) <> 'd3d017f5f1da0ea4d6b1342b9a6f1072' THEN RAISE EXCEPTION 'article plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl2,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'article plan rows %', n; END IF;
  IF (SELECT count(*) FROM awards WHERE source_url='https://web.archive.org/web/20260601213435id_/https://guide.michelin.com/no/en/oslo-region/oslo/restaurant/a-l-aise') <> 0 THEN RAISE EXCEPTION 'article url rows 7119'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_url='https://web.archive.org/web/20260601213429id_/https://guide.michelin.com/no/en/oslo-region/oslo/restaurant/bar-amour') <> 0 THEN RAISE EXCEPTION 'article url rows 7100'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 20 THEN RAISE EXCEPTION 'urls %', n; END IF;
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl2,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'article urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',22,'cleanup:load-michelin-d-norway-2026-11-06 | rule 2.1.7: Nordic 2026, Jun 1, 2026, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards | year stays 2026, source_url = the card (/us/en/), all 24 card labels 2026 read Nov 6 2026, retire 0 | archive capture URL (card left the site, capture after the ceremony): 7119 À L’aise (Oslo): card a-l-aise 404 on Nov 6 2026, capture no/en Jun 1 2026 21:34 UTC label 2026 One Star, named One Star in the Nordic 2026 full star list; 7100 Bar Amour (Oslo): card bar-amour 404 on Nov 6 2026, capture no/en Jun 1 2026 21:34 UTC label 2026 One Star, full star list marks it Now Closed | relay sha256 51c51361b6be81bed2451afd438ba3185d36934607f5bbbd6c7f6128d4fcff51 | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso = 'NO';
  IF n <> 26 OR u1 <> 26 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 317 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134862 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=22' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
