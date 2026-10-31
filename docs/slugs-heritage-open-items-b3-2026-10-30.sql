-- slugs-heritage-open-items-b3-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 3, file 1 of 2. Run through the Write connector.
-- Ben: Oct 30 23:05 ET "Let's do your recommendation" (items 1-3); 23:11 ET "All recommended"
--   (D2 = A: fix the 12 slugs; D3 = B: Heritage 2023 and 2024; D4 = A: two files).
--
-- Part S, 12 slugs that dropped the Turkish letter "ı" (old slug rule). The live slug rule
--   trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))
--   gives "i". For each venue: the old canonical slug becomes non-canonical (the old URL keeps working), and the
--   slug rule of the live name is inserted as canonical. Names do not change. No new slug is in use or in redirects.
--   Relay relay-slugs.txt md5 18352be533faa463b7b29eeb7c1d7e44 = md5 of the live read (venue_id|city_slug|canonical slug|rule of name).
-- Part H, Heritage (Long Beach) ve_95d87f1674, Michelin history rows (the database had 2025 and 2026 only):
--   archive card Feb 6, 2024 (meta "One Star ... in the 2023 MICHELIN Guide USA"; classification One Star +
--     MICHELIN Green Star) -> 2023 One Star, 2023 Green Star;
--   archive card Sep 13, 2024 (meta "One Star ... in the 2024 MICHELIN Guide USA"; dLayer distinction 1 star,
--     greenstar True) -> 2024 One Star, 2024 Green Star. The May 4, 2025 card also gives dateAwarded 2024.
--   source_url = archive card URL (web.archive.org/web/<time>id_/ form). Ledger 170 (michelin, award, 4).
--   Relay relay-heritage.txt md5 c8bdde58b1bb7506d0f040784f22bc65.
-- Audit rows 119,042-119,069 (28): slugs UPDATE 12, slugs INSERT 12, awards INSERT 4.
-- After: awards 23,362; slugs 12,936 (canonical 11,304, non-canonical 1,632).
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $do$
DECLARE
  rel_s text := $r$ve_027c7055e4|istanbul|foxy-nisantas|foxy-nisantasi
ve_2f0a1cc318|istanbul|apart-man-yenikoy|apartiman-yenikoy
ve_3858b8c38e|izmir|partal-kardesler-bal-k-restorant|partal-kardesler-balik-restorant
ve_3c28ea50a0|bodrum|otantik-ocakbas|otantik-ocakbasi
ve_5ed9e3ba91|istanbul|sade-bes-denizler-mutfag|sade-bes-denizler-mutfagi
ve_639a9f06bc|istanbul|mahir-lokantas|mahir-lokantasi
ve_6b845b4191|istanbul|ahmet-ustam-ocakbas|ahmet-ustam-ocakbasi
ve_a2b0e7bf15|istanbul|karakoy-lokantas|karakoy-lokantasi
ve_aab61fc860|istanbul|yanyal-fehmi-lokantas|yanyali-fehmi-lokantasi
ve_e611b7d736|istanbul|parvus-kalam-s|parvus-kalamis
ve_f8013e6d34|izmir|lucien-arkas-baglar|lucien-arkas-baglari
ve_f9cfd37334|istanbul|ali-ocakbas-karakoy|ali-ocakbasi-karakoy$r$;
  rel_h text := $r$ins|ve_95d87f1674|2023|Green Star|https://web.archive.org/web/20240206061227id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790
ins|ve_95d87f1674|2023|One Star|https://web.archive.org/web/20240206061227id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790
ins|ve_95d87f1674|2024|Green Star|https://web.archive.org/web/20240913163626id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790
ins|ve_95d87f1674|2024|One Star|https://web.archive.org/web/20240913163626id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790$r$;
  v_n int;
  v_lid bigint;
  v_txt text;
BEGIN
  -- 1. relays and live state
  IF md5(rel_s) <> '18352be533faa463b7b29eeb7c1d7e44' OR encode(sha256(convert_to(rel_s, 'UTF8')), 'hex') <> '56af6e528555b2354eceff7ffe4dbba5e2b7708c2ac5e4343e8e64b07ea6b065'
    THEN RAISE EXCEPTION 'slug relay hash'; END IF;
  IF md5(rel_h) <> 'c8bdde58b1bb7506d0f040784f22bc65' OR encode(sha256(convert_to(rel_h, 'UTF8')), 'hex') <> '195a86497e010afb78259fc68b0b6632d143e36c25f452e3fc851d0077f426ef'
    THEN RAISE EXCEPTION 'heritage relay hash'; END IF;
  IF (SELECT count(*) FROM awards) <> 23358 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12924 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1620 THEN RAISE EXCEPTION 'non-canonical before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 169 THEN RAISE EXCEPTION 'ledger max before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119041 OR (SELECT count(*) FROM audit_log) <> 113757
    THEN RAISE EXCEPTION 'audit_log before'; END IF;
  IF EXISTS (SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical GROUP BY venue_id HAVING count(*) <> 1)
    THEN RAISE EXCEPTION 'canonical slugs before'; END IF;

  -- 2. slug pre-checks: the live read gives the relay exactly (old = canonical now, new = rule of the live name)
  SELECT md5(string_agg(v.id||'|'||s.city_slug||'|'||s.slug||'|'||trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')), E'\n' ORDER BY v.id))
    INTO v_txt
    FROM venues v JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
   WHERE v.id IN (SELECT split_part(l, '|', 1) FROM regexp_split_to_table(rel_s, E'\n') AS l);
  IF v_txt IS DISTINCT FROM '18352be533faa463b7b29eeb7c1d7e44' THEN RAISE EXCEPTION 'live slug read %', v_txt; END IF;
  IF EXISTS (SELECT 1 FROM slugs s JOIN regexp_split_to_table(rel_s, E'\n') AS l
               ON s.property_id = 'eats' AND s.city_slug = split_part(l, '|', 2) AND s.slug = split_part(l, '|', 4))
    THEN RAISE EXCEPTION 'a new slug is in use'; END IF;
  IF EXISTS (SELECT 1 FROM redirects d JOIN regexp_split_to_table(rel_s, E'\n') AS l
               ON d.from_path IN ('/'||split_part(l, '|', 2)||'/'||split_part(l, '|', 4),
                                  '/venue/'||split_part(l, '|', 2)||'/'||split_part(l, '|', 4)))
    THEN RAISE EXCEPTION 'a new path is in redirects'; END IF;

  -- 3. Heritage pre-checks
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_95d87f1674' AND name = 'Heritage' AND status = 'active')
    THEN RAISE EXCEPTION 'Heritage venue'; END IF;
  SELECT string_agg(year||' '||category, ', ' ORDER BY year, category) INTO v_txt
    FROM awards WHERE venue_id = 've_95d87f1674' AND source_id = 'michelin';
  IF v_txt IS DISTINCT FROM '2025 Green Star, 2025 One Star, 2026 Green Star, 2026 One Star'
    THEN RAISE EXCEPTION 'Heritage rows before: %', v_txt; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN
               (SELECT split_part(l, '|', 5) FROM regexp_split_to_table(rel_h, E'\n') AS l))
    THEN RAISE EXCEPTION 'an archive URL is in use'; END IF;

  -- 4. slug writes (old first, so a venue never has 2 canonical rows)
  UPDATE slugs s SET is_canonical = false
    FROM regexp_split_to_table(rel_s, E'\n') AS l
   WHERE s.property_id = 'eats' AND s.venue_id = split_part(l, '|', 1) AND s.city_slug = split_part(l, '|', 2)
     AND s.slug = split_part(l, '|', 3) AND s.is_canonical;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 12 THEN RAISE EXCEPTION 'old slugs set non-canonical: %', v_n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', split_part(l, '|', 2), split_part(l, '|', 4), split_part(l, '|', 1), true
    FROM regexp_split_to_table(rel_s, E'\n') AS l;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 12 THEN RAISE EXCEPTION 'new canonical slugs inserted: %', v_n; END IF;

  -- 5. Heritage history rows
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT split_part(l, '|', 2), 'michelin', split_part(l, '|', 3)::int, NULL, split_part(l, '|', 4), NULL,
         split_part(l, '|', 5)
    FROM regexp_split_to_table(rel_h, E'\n') AS l
   WHERE split_part(l, '|', 1) = 'ins';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 4 THEN RAISE EXCEPTION 'award rows inserted: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 4,
          'history-backfill:slugs-heritage-open-items-b3-2026-10-30 | Heritage (Long Beach) ve_95d87f1674: 2023 One Star + '
          || 'Green Star (archive card Feb 6, 2024, meta "2023 MICHELIN Guide USA"); 2024 One Star + Green Star (archive card '
          || 'Sep 13, 2024, meta "2024 MICHELIN Guide USA", greenstar True) | source_url = archive card URL | Ben "All '
          || 'recommended" Oct 30 23:11 ET (D3 = B) | relay md5 c8bdde58b1bb7506d0f040784f22bc65')
  RETURNING id INTO v_lid;

  -- 6. post-checks
  IF v_lid <> 170 OR (SELECT max(id) FROM source_capture_ledger) <> 170 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM awards) <> 23362 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12936 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1632 THEN RAISE EXCEPTION 'non-canonical after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE is_canonical) <> 11304 THEN RAISE EXCEPTION 'canonical after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
              GROUP BY v.id HAVING count(s.slug) <> 1)
    THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM regexp_split_to_table(rel_s, E'\n') AS l
        JOIN slugs n ON n.property_id = 'eats' AND n.venue_id = split_part(l, '|', 1) AND n.city_slug = split_part(l, '|', 2)
                    AND n.slug = split_part(l, '|', 4) AND n.is_canonical
        JOIN slugs o ON o.property_id = 'eats' AND o.venue_id = split_part(l, '|', 1) AND o.city_slug = split_part(l, '|', 2)
                    AND o.slug = split_part(l, '|', 3) AND NOT o.is_canonical) <> 12
    THEN RAISE EXCEPTION 'slug pairs after'; END IF;
  SELECT string_agg(year||' '||category||' '||coalesce(substr(source_url, 29, 14), '-'), ', ' ORDER BY year, category) INTO v_txt
    FROM awards WHERE venue_id = 've_95d87f1674' AND source_id = 'michelin' AND year IN (2023, 2024);
  IF v_txt IS DISTINCT FROM '2023 Green Star 20240206061227, 2023 One Star 20240206061227, 2024 Green Star 20240913163626, 2024 One Star 20240913163626'
    THEN RAISE EXCEPTION 'Heritage rows after: %', v_txt; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119069 OR (SELECT count(*) FROM audit_log WHERE id > 119041) <> 28
    THEN RAISE EXCEPTION 'audit range after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119041 AND table_name = 'slugs' AND action = 'UPDATE') <> 12
     OR (SELECT count(*) FROM audit_log WHERE id > 119041 AND table_name = 'slugs' AND action = 'INSERT') <> 12
     OR (SELECT count(*) FROM audit_log WHERE id > 119041 AND table_name = 'awards' AND action = 'INSERT'
           AND row_pk IN (SELECT id::text FROM awards WHERE venue_id = 've_95d87f1674' AND year IN (2023, 2024))) <> 4
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
