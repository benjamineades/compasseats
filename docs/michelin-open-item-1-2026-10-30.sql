-- michelin-open-item-1-2026-10-30.sql
-- Open item 1 (missing Green Star and URL rows). Ben Oct 30, 2026: 21:05 ET "A for both" (scope = item 1 rows only;
--   URL = archive card URL in the guide year, else edition article URL); 21:14 ET "I agree" (hold Chay Garden 10486 and
--   Hong Phat 10493 for a later archive retry).
-- Evidence (built-in browser, Oct 31 ~01:05-01:15 UTC):
--   California 2025 article (published 25 June 2025):
--   https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-california-stars-green-stars
--     Green Stars list has Chez Panisse, Chi Spacca, Heritage (Long Beach), Pomet; One Star list has "Heritage, Long Beach".
--   Archive cards inside the 2025 California edition (Jun 25, 2025 to Jun 25, 2026):
--     Chez Panisse 2025-08-09, Chi Spacca 2025-07-26, Pomet 2025-09-14: dLayer distinction plate, greenstar True.
--     Heritage 2025-09-12: dLayer 1 star, greenstar True, meta "One Star ... in the 2025 MICHELIN Guide USA", dateAwarded 2025.
--   Banshee archive cards: 2023-12-19 meta "Bib Gourmand ... in the 2023 MICHELIN Guide USA"; 2025-04-14 Bib, dateAwarded 2024.
--   Banshee 2025: American South 2025 Bib article (published 2025-11-04) lists 10 Atlanta Bibs, no Banshee; archive card
--     2026-04-08 plate. No 2025 row (not in this file).
--   Man Moi 10494: no 2025-edition archive card; Vietnam 2025 article (published 2025-06-05) names "Bib Gourmand restaurant
--     Man Moi" (Service Award, Nha Huynh): https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-vietnam-2025
-- Ops: 5 awards INSERT (year 2025: 4 Green Star, 1 One Star), 3 awards UPDATE (source_url only). No DELETE.
-- Relay sha256 3d575a838a721f1132eb68cfb9d7b36f4d801976b42868c9a9e75bac3586271a, md5 1cad30725415d117d7ce7581721001e4 (inside this file).
-- Guards: awards 23353, ledger max 165, audit max 118990; Michelin rows on the 6 venues md5 3a33a3837b31e2c88df67d705f3fd075
--   (9 rows); no 2025 Michelin row of the new category on an insert venue; relay URLs not in use.
-- Post-checks: awards 23358; ledgers 166 (history-backfill, 5) and 167 (source-url, 3); audit 118991 to 118998:
--   5 awards INSERT + 3 awards UPDATE, nothing else; Michelin rows on the 6 venues = 14.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$ins|ve_2b87774359|-|Green Star|https://web.archive.org/web/20250914051229id_/https://guide.michelin.com/us/en/california/oakland/restaurant/pomet
ins|ve_3a998c5225|-|Green Star|https://web.archive.org/web/20250809160635id_/https://guide.michelin.com/us/en/california/berkeley/restaurant/chez-panisse
ins|ve_43771d354f|-|Green Star|https://web.archive.org/web/20250726005340id_/https://guide.michelin.com/us/en/california/us-los-angeles/restaurant/chi-spacca
ins|ve_95d87f1674|-|Green Star|https://web.archive.org/web/20250912123304id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790
ins|ve_95d87f1674|-|One Star|https://web.archive.org/web/20250912123304id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790
url|ve_466f9b5fe9|21098|Bib Gourmand|https://web.archive.org/web/20231219192142id_/https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/banshee
url|ve_466f9b5fe9|21099|Bib Gourmand|https://web.archive.org/web/20250414230834id_/https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/banshee
url|ve_c1ed9b62ab|10494|Bib Gourmand|https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-vietnam-2025$r$;
  v_old text;
  v_n int;
  v_lid1 bigint;
  v_lid2 bigint;
BEGIN
  IF (SELECT count(*) FROM awards) <> 23353 THEN RAISE EXCEPTION 'awards count before is not 23353'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 165 THEN RAISE EXCEPTION 'ledger max before is not 165'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118990 THEN RAISE EXCEPTION 'audit max before is not 118990'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '3d575a838a721f1132eb68cfb9d7b36f4d801976b42868c9a9e75bac3586271a' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF md5(rel_txt) <> '1cad30725415d117d7ce7581721001e4' THEN RAISE EXCEPTION 'relay md5'; END IF;

  -- rows as read before the build
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,''),
                        E'\n' ORDER BY a.venue_id COLLATE "C", a.id))
    INTO v_old
    FROM awards a
   WHERE a.source_id = 'michelin'
     AND a.venue_id IN (SELECT DISTINCT split_part(l, '|', 2) FROM regexp_split_to_table(rel_txt, E'\n') AS l);
  IF v_old IS DISTINCT FROM '3a33a3837b31e2c88df67d705f3fd075' THEN RAISE EXCEPTION 'old award rows md5 %', v_old; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active'
       AND id IN (SELECT DISTINCT split_part(l, '|', 2) FROM regexp_split_to_table(rel_txt, E'\n') AS l)) <> 6
    THEN RAISE EXCEPTION 'a relay venue is not active'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN regexp_split_to_table(rel_txt, E'\n') AS l
               ON split_part(l, '|', 1) = 'ins' AND a.venue_id = split_part(l, '|', 2)
              AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = split_part(l, '|', 4))
    THEN RAISE EXCEPTION 'a 2025 row of that category exists'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN
               (SELECT split_part(l, '|', 5) FROM regexp_split_to_table(rel_txt, E'\n') AS l))
    THEN RAISE EXCEPTION 'a relay URL is already in use'; END IF;

  -- 5 history rows (year 2025)
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT split_part(l, '|', 2), 'michelin', 2025, NULL, split_part(l, '|', 4), NULL, split_part(l, '|', 5)
    FROM regexp_split_to_table(rel_txt, E'\n') AS l
   WHERE split_part(l, '|', 1) = 'ins';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 5 THEN RAISE EXCEPTION 'award rows inserted: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 5,
          'history-backfill:michelin-open-item-1-2026-10-30 | 2025 California rows: Green Star for Chez Panisse, Chi Spacca, Pomet, '
          || 'Heritage (Long Beach); One Star for Heritage | California 2025 article (Jun 25, 2025) + archive cards in the 2025 edition '
          || '(greenstar True; Heritage dateAwarded 2025) | source_url = archive card URL | Ben "A for both" Oct 30 21:05 ET, '
          || '"I agree" 21:14 ET | relay md5 1cad30725415d117d7ce7581721001e4')
  RETURNING id INTO v_lid1;

  -- 3 URL rows (source_url NULL -> URL; year and category unchanged)
  UPDATE awards a SET source_url = split_part(l, '|', 5)
    FROM regexp_split_to_table(rel_txt, E'\n') AS l
   WHERE split_part(l, '|', 1) = 'url' AND a.id = split_part(l, '|', 3)::bigint AND a.venue_id = split_part(l, '|', 2)
     AND a.source_id = 'michelin' AND a.source_url IS NULL AND a.category = split_part(l, '|', 4);
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'award rows updated: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 3,
          'source-url:michelin-open-item-1-2026-10-30 | award source_url NULL -> URL, year and category unchanged | Banshee 21098 '
          || '(archive card Dec 19, 2023, 2023 guide) and 21099 (archive card Apr 14, 2025, dateAwarded 2024); Man Moi 10494 = Vietnam '
          || '2025 article (names it a Bib Gourmand restaurant) | Chay Garden 10486 and Hong Phat 10493 held (no 2025-edition card) '
          || '| relay md5 1cad30725415d117d7ce7581721001e4')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF (SELECT count(*) FROM awards) <> 23358 THEN RAISE EXCEPTION 'awards count after'; END IF;
  IF v_lid1 <> 166 OR v_lid2 <> 167 OR (SELECT max(id) FROM source_capture_ledger) <> 167
    THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118990) <> 8 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118990 AND table_name = 'awards' AND action = 'INSERT'
         AND new_row->>'year' = '2025' AND new_row->>'source_id' = 'michelin') <> 5
    THEN RAISE EXCEPTION 'audit awards INSERT rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118990 AND table_name = 'awards' AND action = 'UPDATE'
         AND row_pk IN ('21098', '21099', '10494')
         AND (old_row - 'source_url') = (new_row - 'source_url') AND old_row->>'source_url' IS NULL) <> 3
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN regexp_split_to_table(rel_txt, E'\n') AS l
        ON a.venue_id = split_part(l, '|', 2) AND a.category = split_part(l, '|', 4) AND a.source_url = split_part(l, '|', 5)
       AND a.source_id = 'michelin'
       AND ((split_part(l, '|', 1) = 'ins' AND a.year = 2025)
         OR (split_part(l, '|', 1) = 'url' AND a.id = split_part(l, '|', 3)::bigint))) <> 8
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'michelin'
       AND venue_id IN (SELECT DISTINCT split_part(l, '|', 2) FROM regexp_split_to_table(rel_txt, E'\n') AS l)) <> 14
    THEN RAISE EXCEPTION 'Michelin rows on relay venues after'; END IF;
  IF (SELECT count(*) FROM awards WHERE id IN (10486, 10493) AND source_url IS NULL) <> 2
    THEN RAISE EXCEPTION 'held rows changed'; END IF;
END
$do$;
COMMIT;
