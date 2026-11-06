-- load-michelin-d-sweden-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Sweden. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 33 rows keep year 2026 and get the card URL. 1 rows get the article URL. 1 rows have another URL of their card replaced by the /us/en/ card URL. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: relay-se-2026-cards-2026-11-06.txt sha256 3dd27529f076c8b86f1e0faa967b504322b78b027257915eb2c2e69bdb1e4d2c.
-- Expected after: awards 29052 unchanged; ledger 319 rows; audit_log +35.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1159~ve_cc5d387fb5~Three Stars~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/frantzen
2457~ve_899dd87c17~Two Stars~https://guide.michelin.com/us/en/skane/malmo/restaurant/vollmers
3141~ve_c5e00877c1~Two Stars~https://guide.michelin.com/us/en/skane/simrishamn_2683288/restaurant/vyn
3212~ve_1c4a51a054~Two Stars~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/aira
5180~ve_19f12ae14f~One Star~https://guide.michelin.com/us/en/vastra-gotaland/gothenburg/restaurant/28
5183~ve_4ced79de61~One Star~https://guide.michelin.com/us/en/vastra-gotaland/gothenburg/restaurant/hoze
5185~ve_2c621234fb~One Star~https://guide.michelin.com/us/en/vastra-gotaland/gothenburg/restaurant/koka
5187~ve_84a6e09224~One Star~https://guide.michelin.com/us/en/vastra-gotaland/gothenburg/restaurant/project
5189~ve_9640b4aefd~One Star~https://guide.michelin.com/us/en/vastra-gotaland/gothenburg/restaurant/sk-mat-manniskor
7664~ve_59af1b3e61~One Star~https://guide.michelin.com/us/en/hallands/rydobruk/restaurant/knystaforsen
8283~ve_e41cb218a9~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/celeste-1209889
8285~ve_3a4845a035~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/dashi
8291~ve_48547cb639~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/ekstedt
8293~ve_badc270938~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/ergo
8296~ve_57cbca74eb~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/etoile
8301~ve_67369ef3d4~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/nour
8306~ve_673145b8e0~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/operakallaren
8308~ve_5b80556748~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/seafood-gastro
8311~ve_503c4833b9~One Star~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/sushi-sho
8768~ve_8f8a5f2bd2~One Star~https://guide.michelin.com/us/en/hallands/tvaaker/restaurant/ang
8953~ve_1a4edd1512~One Star~https://guide.michelin.com/us/en/kronoberg/vaxjo/restaurant/pm-vanner
10314~ve_a0109a0718~Bib Gourmand~https://guide.michelin.com/us/en/vastra-gotaland/gothenburg/restaurant/familjen
11111~ve_51d17152ae~Bib Gourmand~https://guide.michelin.com/us/en/skane/malmo/restaurant/mutantur
11113~ve_47ecaf6869~Bib Gourmand~https://guide.michelin.com/us/en/skane/malmo/restaurant/namu
11115~ve_b7296f7c2a~Bib Gourmand~https://guide.michelin.com/us/en/skane/malmo/restaurant/ruths
11117~ve_70ff6d423b~Bib Gourmand~https://guide.michelin.com/us/en/skane/malmo/restaurant/vastergatan
12286~ve_851379a2dc~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/allegrine
12288~ve_e2917d530b~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/babette
12290~ve_55e39efdb6~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/bar-agrikultur
12292~ve_db7d99abdc~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/lilla-ego
12293~ve_f31128ce8f~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/matbaren
12299~ve_75fb74fc55~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/triton
12301~ve_e6b135e179~Bib Gourmand~https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/arla$plan$;
  rl2 text := $plan$13007~ve_7c9cd89dc7~Bib Gourmand~https://guide.michelin.com/fi/en/article/michelin-guide-ceremony/new-good-value-bib-gourmand-restaurants-nordic-countries-denmark-finland-iceland-norway-sweden$plan$;
  rl3 text := $plan$3142~ve_431ae3ca78~Bib Gourmand~https://guide.michelin.com/is/en/skane/simrishamn_2683288/restaurant/vyn-food-wine-bar~https://guide.michelin.com/us/en/skane/simrishamn_2683288/restaurant/vyn-food-wine-bar$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '0198f09e857f98104f049c088eba9b05' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso = 'SE') y;
  IF fp IS DISTINCT FROM '6e41cc3f1a513580b6982c172e439930' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11511 OR (SELECT count(*) FROM venues WHERE status='closed') <> 320 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11511 OR (SELECT count(*) FROM source_capture_ledger) <> 318 OR (SELECT max(id) FROM source_capture_ledger) <> 372 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129058 OR u2 <> 134887 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((21110, 've_f22e145872', 'https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/rolfs-kok'), (18378, 've_bae620298b', 'https://guide.michelin.com/us/en/stockholm-region/stockholm/restaurant/adam-albin'), (2563, 've_a6a92ff828', 'https://guide.michelin.com/us/en/vastra-gotaland/molnlycke_2675596/restaurant/signum-1205585'))) <> 3 THEN RAISE EXCEPTION 'rows with URL'; END IF;
  IF md5(rl3) <> 'acf4e9011c700d5858b288b34910dfee' THEN RAISE EXCEPTION 'replace plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl3,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS DISTINCT FROM split_part(x,'~',4);
  IF n <> 0 THEN RAISE EXCEPTION 'replace plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',5) FROM regexp_split_to_table(rl3,E'\n') x)) THEN RAISE EXCEPTION 'replace url in use'; END IF;
  IF md5(rl2) <> '185ad2a800f8009f28426bcc3ec62c32' THEN RAISE EXCEPTION 'article plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl2,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'article plan rows %', n; END IF;
  IF (SELECT count(*) FROM awards WHERE source_url='https://guide.michelin.com/fi/en/article/michelin-guide-ceremony/new-good-value-bib-gourmand-restaurants-nordic-countries-denmark-finland-iceland-norway-sweden') <> 0 THEN RAISE EXCEPTION 'article url rows 13007'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 33 THEN RAISE EXCEPTION 'urls %', n; END IF;
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl2,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'article urls %', n; END IF;
  UPDATE awards a SET source_url=split_part(x,'~',5) FROM regexp_split_to_table(rl3,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'replaced urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',35,'cleanup:load-michelin-d-sweden-2026-11-06 | rule 2.1.7: Nordic 2026, Jun 1, 2026, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards | year stays 2026, source_url = the card (/us/en/), all 37 card labels 2026 read Nov 6 2026, retire 0 | article URL (card left the site, no capture after the ceremony): 13007 JH matbar (Ystad): Nordic 2026 Bib article Jun 1 2026 lists it for Sweden, card jh-matbar 404 on Nov 6 2026, Wayback last capture May 27 2024 (10 locales), own site says moving to Malmo, reopening May 2027 | other card URL: 3142 replaced https://guide.michelin.com/is/en/skane/simrishamn_2683288/restaurant/vyn-food-wine-bar | relay sha256 3dd27529f076c8b86f1e0faa967b504322b78b027257915eb2c2e69bdb1e4d2c | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso = 'SE';
  IF n <> 38 OR u1 <> 38 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 319 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134887 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=35' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
