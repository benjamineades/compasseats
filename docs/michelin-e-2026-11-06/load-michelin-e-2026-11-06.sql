-- load-michelin-e-2026-11-06.sql
-- CompassEats, Nov 6 2026. Michelin group E: Hungary, Saudi Arabia. Ben choices 1-5:A, Nov 6 09:39 ET. This file runs only after Ben's "go".
-- 34 rows keep year 2025 and get a URL: 32 cards, 2 articles (Platan Gourmet, Samia's Dish). Relabel 0. Retire 0. No new rows, no new venues.
-- 1 closure: Platan Gourmet ve_b35292624c, closed Jul 31, 2026 (Portfolio.hu, Jun 4, 2026). Award row stays. Slug stays.
-- Source: docs/michelin-e-2026-11-06/relay-e-2026-list-pages-2026-11-06.txt sha256 9a48f596d2a2eb3e9561f9620b734f1e44cc8929f995c5ff4776aa6a2ac8e831.
-- Expected after: venues 11831 (active 11512, closed 319); awards 29052; cities sum 11512; Tata 1; ledger 311 rows; audit_log +37.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1667~ve_b69e138700~Two Stars~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/stand
3286~ve_b35292624c~Two Stars~https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-hungary-2025-is-out
4330~ve_16a163a96a~One Star~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/babel
4332~ve_db7128646c~One Star~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/borkonyha-winekitchen
4333~ve_9a0fbfdd0a~One Star~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/costes
4336~ve_c77da4a0b3~One Star~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/essencia
4340~ve_fb160af4b5~One Star~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/rumour
4341~ve_023ac41daa~One Star~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/salt-1196768
4982~ve_f5b50b339a~One Star~https://guide.michelin.com/us/en/komarom-esztergom/esztergom/restaurant/42
9151~ve_18905734b5~One Star~https://guide.michelin.com/us/en/vas/oriszentpeter/restaurant/pajta
9241~ve_f1a46ff562~Bib Gourmand~https://guide.michelin.com/us/en/mecca-province/al-ula_2555005/restaurant/joontos
9242~ve_893a2ea0eb~Bib Gourmand~https://guide.michelin.com/us/en/mecca-province/al-ula_2555005/restaurant/tofareya-1242533
9391~ve_aa6a251be4~Bib Gourmand~https://guide.michelin.com/us/en/veszprem-region/balatonfured/restaurant/sparhelt
9392~ve_155c8dc797~Bib Gourmand~https://guide.michelin.com/us/en/somogy/balatonszemes/restaurant/kistucsok
9393~ve_8d8a36f02a~Bib Gourmand~https://guide.michelin.com/us/en/veszprem-region/balatonszolos/restaurant/casa-christa
9632~ve_4ac1aca78d~Bib Gourmand~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/94-konyha-bar
9633~ve_6d7c50f339~Bib Gourmand~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/cabrio
9634~ve_adf09bbbb6~Bib Gourmand~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/goli
9635~ve_eb22c2a5ca~Bib Gourmand~https://guide.michelin.com/us/en/central-hungary/budapest/restaurant/n28-wine-and-kitchen
10144~ve_423d5ab716~Bib Gourmand~https://guide.michelin.com/us/en/heves/eger/restaurant/macok
10158~ve_24feb0706b~Bib Gourmand~https://guide.michelin.com/us/en/borsod-abauj-zemplen/encs/restaurant/anyukam-mondta
10693~ve_b4cb7d747c~Bib Gourmand~https://guide.michelin.com/us/en/article/michelin-guide-ceremony/saudi-arabia-inaugural-michelin-guide-restaurant-selection
10694~ve_71c2e27da3~Bib Gourmand~https://guide.michelin.com/us/en/mecca-province/jeddah_2555048/restaurant/the-lucky-llama
11264~ve_598b64c7d8~Bib Gourmand~https://guide.michelin.com/us/en/borsod-abauj-zemplen/malyinka_1786967/restaurant/iszkor
11760~ve_6061670b0e~Bib Gourmand~https://guide.michelin.com/us/en/baranya/pecs/restaurant/morzsa
11841~ve_c1924998fa~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/em-sherif-cafe
11842~ve_ffbbadc2c4~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/fi-glbak
11843~ve_95db9855ed~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/kayzo
11844~ve_4e4751123e~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/mirzam
11845~ve_ab1be57e8f~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/najd-village
11846~ve_7942fba5be~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/sasani
11847~ve_82b3b976ab~Bib Gourmand~https://guide.michelin.com/us/en/riyadh-province/riyadh_2555317/restaurant/tameesa
12335~ve_9d7145b7d5~Bib Gourmand~https://guide.michelin.com/us/en/bekes/szarvas_1787559/restaurant/ujvaros-bisztro
12541~ve_8b494816dc~Bib Gourmand~https://guide.michelin.com/us/en/komarom-esztergom/tata/restaurant/platan-bisztro$plan$;
  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '72d79b5cf1c1434c0aed8d9f31eb41ba' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('HU','SA')) y;
  IF fp IS DISTINCT FROM '3000774dd7781dee5b56cf0993a592e4' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id) FROM venues v WHERE v.id='ve_b35292624c') IS DISTINCT FROM 'bc9a4af12b2e0da43fb39659cf70c190' THEN RAISE EXCEPTION 'closure fingerprint'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='ve_b35292624c' AND published) <> 1 THEN RAISE EXCEPTION 'listing before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11513 OR (SELECT count(*) FROM venues WHERE status='closed') <> 318 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 OR (SELECT max(id) FROM awards) <> 36223 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3344 OR (SELECT sum(venues_count) FROM cities) <> 11513 OR (SELECT venues_count FROM cities WHERE id='ci_49d02d55ad') <> 2 OR (SELECT count(*) FROM source_capture_ledger) <> 309 OR (SELECT max(id) FROM source_capture_ledger) <> 363 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> 128792 OR u2 <> 134621 THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 34 THEN RAISE EXCEPTION 'urls %', n; END IF;
  UPDATE venues SET status='closed' WHERE id='ve_b35292624c' AND status='active'; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'closure'; END IF;
  UPDATE listings SET published=false WHERE venue_id='ve_b35292624c' AND published; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'unpublish'; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_49d02d55ad' AND venues_count=2; GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'tata'; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',23,'cleanup:load-michelin-e-2026-11-06 | rule 2.1.7: Hungary 2025, Oct 9, 2025, https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-hungary-2025-is-out | year stays 2025, source_url = the card (/us/en/), retire 0 | award 3286 Platan Gourmet: card gone, closed Jul 31 2026, article URL | relay sha256 9a48f596d2a2eb3e9561f9620b734f1e44cc8929f995c5ff4776aa6a2ac8e831 | Ben choices 1-5:A, Nov 6 09:39 ET'),
    ('michelin','award',11,'cleanup:load-michelin-e-2026-11-06 | rule 2.1.7: Saudi Arabia, Dec 15, 2025, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/saudi-arabia-inaugural-michelin-guide-restaurant-selection: article says 2026, cards say 2025, label stays with the card | year stays 2025, source_url = the card (/us/en/), retire 0 | award 10693 Samia Dish: card gone, article URL | relay sha256 9a48f596d2a2eb3e9561f9620b734f1e44cc8929f995c5ff4776aa6a2ac8e831 | Ben choices 1-5:A, Nov 6 09:39 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11831 OR (SELECT count(*) FROM venues WHERE status='active') <> 11512 OR (SELECT count(*) FROM venues WHERE status='closed') <> 319 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 29052 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4179 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 7821 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url), count(DISTINCT a.source_url) INTO n, u1, u2 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country_iso IN ('HU','SA');
  IF n <> 34 OR u1 <> 34 OR u2 <> 34 THEN RAISE EXCEPTION 'urls after % % %', n, u1, u2; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11512 THEN RAISE EXCEPTION 'sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 311 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > 134621 GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=34,cities:UPDATE=1,listings:UPDATE=1,venues:UPDATE=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
