-- load-michelin-d-denmark-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group D Denmark. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- 56 rows keep year 2026 and get the card URL. 1 card(s) on a venue outside the scope: no write. Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: relay-dk-2026-cards-2026-11-06.txt sha256 617efae6682002db090f052ebc71c72225c4414a4776d55d22cfef9579d8c89b.
-- Expected after: awards 29052 unchanged; ledger 321 rows; audit_log +56.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$203~ve_ad6b213f39~Three Stars~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/geranium
329~ve_412e1716a6~Three Stars~https://guide.michelin.com/us/en/capital-region/gentofte_1373269/restaurant/jordnaer
1414~ve_11f934752e~Two Stars~https://guide.michelin.com/us/en/central-denmark/aarhus/restaurant/frederikshoj
1793~ve_768a440eb6~Two Stars~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/alchemist
1795~ve_bc8db0ea43~Two Stars~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/a%E2%80%9Ao%E2%80%9Ac
1801~ve_0887d3b2c0~Three Stars~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/kadeau-copenhagen
1810~ve_8bab1ac2d2~Two Stars~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/koan
1815~ve_89f1fbd175~Two Stars~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/kong-hans-kaelder
2038~ve_301702feaf~Two Stars~https://guide.michelin.com/us/en/southern-denmark/henne/restaurant/henne-kirkeby-kro
3603~ve_3ec90acf92~One Star~https://guide.michelin.com/us/en/north-denmark/aalborg/restaurant/alimentum
3609~ve_13ac37e7bf~One Star~https://guide.michelin.com/us/en/central-denmark/aarhus/restaurant/domestic
3611~ve_d38e799d9e~One Star~https://guide.michelin.com/us/en/central-denmark/aarhus/restaurant/gastrome
3613~ve_a86117b663~One Star~https://guide.michelin.com/us/en/central-denmark/aarhus/restaurant/substans
3632~ve_5289e4d2d3~One Star~https://guide.michelin.com/us/en/north-denmark/agger/restaurant/tri-1203718
4614~ve_ba625143b9~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/alouette
4618~ve_f2d62f12bb~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/restaurant-aure
4621~ve_a616ef7c7b~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/formel-b
4626~ve_f2c7f002e3~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/jatak
4630~ve_3ced870b52~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/marchal
4635~ve_71f30ba3cb~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/sushi-anaba
4639~ve_5687d452d7~One Star~https://guide.michelin.com/us/en/capital-region/holte_1374367/restaurant/sollerod-kro
4641~ve_f5f4d7600d~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/texture-1215658
4643~ve_357709fdf3~One Star~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/udtryk
5073~ve_f2425cd9f2~One Star~https://guide.michelin.com/us/en/southern-denmark/fredericia/restaurant/ti-trin-ned
5340~ve_2e7fda413e~One Star~https://guide.michelin.com/us/en/capital-region/hellerup_7770408/restaurant/parsley-salon
5342~ve_d3d4cf6ce0~One Star~https://guide.michelin.com/us/en/capital-region/hellerup_7770408/restaurant/the-samuel
5361~ve_a135a5ab21~One Star~https://guide.michelin.com/us/en/central-denmark/herning/restaurant/domaene
5616~ve_23805c8501~One Star~https://guide.michelin.com/us/en/zealand/horve/restaurant/dragsholm-slot-gourmet
5712~ve_494b644efe~One Star~https://guide.michelin.com/us/en/southern-denmark/krusa_1375755/restaurant/pearl-by-paul-proffitt
6218~ve_dd313fea0a~One Star~https://guide.michelin.com/us/en/north-denmark/lonstrup/restaurant/villa-vest
6960~ve_f7e4cd5116~One Star~https://guide.michelin.com/us/en/zealand/nykobing-sjaelland/restaurant/mota
6981~ve_778f64e5e0~One Star~https://guide.michelin.com/us/en/southern-denmark/odense/restaurant/aro
7481~ve_68a2c8e847~One Star~https://guide.michelin.com/us/en/zealand/praesto/restaurant/frederiksminde
8385~ve_3a5ba34dfc~One Star~https://guide.michelin.com/us/en/southern-denmark/sonderborg/restaurant/syttende
8866~ve_14e0034dcf~One Star~https://guide.michelin.com/us/en/southern-denmark/vejle/restaurant/lyst
9142~ve_fa21e78242~One Star~https://guide.michelin.com/us/en/capital-region/kirkeby/restaurant/kadeau-bornholm
9191~ve_57c5fa0b04~Bib Gourmand~https://guide.michelin.com/us/en/central-denmark/aarhus/restaurant/pondus
9193~ve_d91bfddd92~Bib Gourmand~https://guide.michelin.com/us/en/central-denmark/aarhus/restaurant/restaurant-et
9899~ve_881711ecb6~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/anarki
9901~ve_139ad2f863~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/bistro-lupa
9903~ve_276e542f4a~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/bobe
9905~ve_fb79a8eace~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/calma
9907~ve_0276d61b4a~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/enomania
9909~ve_aa3f42de9e~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/gabrielle
9911~ve_e4c139d124~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/koefoed
9913~ve_3bd9eff797~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/marv-ben
9915~ve_7fb3fca348~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/melee
9916~ve_b57e9acfed~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/no-2
9920~ve_26dc1f9397~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/norrlyst
9922~ve_b98e131aca~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/paesano
9924~ve_f56f883efe~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/pluto
9926~ve_bb98cc4449~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/radio
9928~ve_ece120d51e~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/rebel
9930~ve_b33d9e8790~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/nordhavn_7770461/restaurant/restaurant-vie
9932~ve_d433e2742e~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/selma
9934~ve_d670875f46~Bib Gourmand~https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/silberbauers-bistro$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '7b42bf5e19008aa3edfb10658ed637f8' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso = 'DK') y;
  IF fp IS DISTINCT FROM 'd12eb5e4e9376afd5bb8ec0ae71ce981' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11510 OR (SELECT count(*) FROM venues WHERE status='closed') <> 321 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 311 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11510 OR (SELECT count(*) FROM source_capture_ledger) <> 320 OR (SELECT max(id) FROM source_capture_ledger) <> 374 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 129096 OR u2 <> 134925 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2026 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ((21103, 've_a4cdd65b30', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/botschaft'), (21107, 've_bc652b214e', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/frank569608'), (21104, 've_3471cf5525', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/graziano'), (21105, 've_29e2076287', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/levi'), (21106, 've_0b7f3ea5fb', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/petra-bar-restaurant'), (21108, 've_cbcc1f0329', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/sanchez'), (21109, 've_e288def142', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/uformel'), (21041, 've_cea5c87389', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/akme'), (18417, 've_d506cb62f8', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/esse'), (21043, 've_fe3bb3204c', 'https://guide.michelin.com/us/en/capital-region/copenhagen/restaurant/lille-molle'), (21042, 've_cd005d1e4d', 'https://guide.michelin.com/us/en/north-denmark/aalborg/restaurant/bach-nurup'), (21044, 've_dcdc654c7b', 'https://guide.michelin.com/us/en/north-denmark/skagen/restaurant/oke'))) <> 12 THEN RAISE EXCEPTION 'rows with URL'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE (a.id, a.venue_id, a.source_url, c.country_iso) IN ((3444, 've_42a5f4e1d3', 'https://guide.michelin.com/us/en/faroe-islands/torshavn/restaurant/paz', 'FO'))) <> 1 THEN RAISE EXCEPTION 'rows outside scope'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 56 THEN RAISE EXCEPTION 'urls %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',56,'cleanup:load-michelin-d-denmark-2026-11-06 | rule 2.1.7: Nordic 2026, Jun 1, 2026, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards | year stays 2026, source_url = the card (/us/en/), all 69 card labels 2026 read Nov 6 2026, retire 0 | outside scope, no write: 3444 PAZ (Torshavn, Faroe Islands): card sits in the Denmark list, card guide Denmark; row already holds this card URL (D1, ledger 366) | card closure note, url set: udtryk card says temporarily closed and set to reopen in December; venue status stays closed | relay sha256 617efae6682002db090f052ebc71c72225c4414a4776d55d22cfef9579d8c89b | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND c.country_iso = 'DK';
  IF n <> 69 OR u1 <> 69 THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 321 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134925 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=56' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
