-- reopen-urls-open-items-b7-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 7, file 1 of 2. INSERT/UPDATE only: Write connector.
-- Ben: Oct 31 02:19 ET "Let's do item 1"; 03:42 ET "All A" (E1-E4 = A; E4 held for one question, not in these files).
-- E2 venues status closed -> active (status only), 4 venues set closed by the Aug 14 sheet load with no closure evidence;
--    each live Michelin card (read Oct 31) shows the 2026 edition, opening hours and no closure note; each got Mindful
--    Voices in Oct 2026: La Galinette (Perpignan), La Tana Gourmet (Asiago), Rolland (Plourhan), Ursus (Tignes).
--    cities.venues_count of the 4 cities +1 (block 5 method: stored count = view city_venue_counts). No ledger row.
-- E3 awards source_url NULL -> source (7 legacy rows, special-awards block "unproven"); distinction = person on 2 rows
--    (21154 Rhianda Smith, 21155 Jada Vidal), as the Oct 29 special-awards rows. Year and category unchanged.
--    Florida 5: Michelin press release Jun 1, 2026 on Visit Florida's media site (no guide.michelin.com page names them).
--    Vietnam 2: Michelin article "full list" Jun 6, 2026. Ledger 176 (michelin, award, 7).
-- Relay docs/open-items-b7-build/relay.txt sha256 f628738a612afc4567ecc103dcef6c780d79465eab800f36690c4f824ad30a52.
-- Expected: closed 370 -> 366, venues_count sum 10933 -> 10937, ledger 175 -> 176,
--   audit 119409 -> 119424 (+15: venues UPDATE 4, cities UPDATE 4, awards UPDATE 7).
BEGIN;
DO $do$
DECLARE
  rel text := replace($r$status|ve_d0b3463bc7|La Galinette|ci_9ba49d57fc|3|4|card https://guide.michelin.com/en/occitanie/perpignan/restaurant/la-galinette One Star, 2026 MICHELIN Guide France, hours Wed-Sat, no closure note (read Oct 31)
status|ve_d89d9e74aa|La Tana Gourmet|ci_e4929e796f|1|2|card https://guide.michelin.com/us/en/veneto/asiago/restaurant/la-tana-gourmet One Star, 2026 MICHELIN Guide Italia, no closure note (read Oct 31)
status|ve_971eedfb86|Rolland|ci_fc6d18576b|0|1|card https://guide.michelin.com/en/bretagne/plourhan_1568608/restaurant/rolland Bib Gourmand, 2026 MICHELIN Guide France, hours Wed-Fri, no closure note (read Oct 31)
status|ve_ef57492a00|Ursus|ci_f28e5f4881|0|1|card https://guide.michelin.com/en/auvergne-rhone-alpes/tignes/restaurant/ursus One Star, 2026 MICHELIN Guide France, hours Tue-Sat, no closure note (read Oct 31)
url|21093|ve_b872d4efd2|Green Star||https://www.visitfloridamedia.com/releases/post/historic-moment-michelin-guide-reveals-first-statewide-restaurant-selection-for-florida/
url|21094|ve_fb0e3f3b24|Green Star||https://www.visitfloridamedia.com/releases/post/historic-moment-michelin-guide-reveals-first-statewide-restaurant-selection-for-florida/
url|21095|ve_64a5a273fc|Green Star||https://www.visitfloridamedia.com/releases/post/historic-moment-michelin-guide-reveals-first-statewide-restaurant-selection-for-florida/
url|21111|ve_230f220397|Green Star||https://guide.michelin.com/vn/en/article/michelin-guide-ceremony/full-list-michelin-stars-michelin-guide-vietnam-2026
url|21113|ve_eba2b712fd|Green Star||https://guide.michelin.com/vn/en/article/michelin-guide-ceremony/full-list-michelin-stars-michelin-guide-vietnam-2026
url|21154|ve_5d8610b754|Exceptional Cocktails Award|Rhianda Smith|https://www.visitfloridamedia.com/releases/post/historic-moment-michelin-guide-reveals-first-statewide-restaurant-selection-for-florida/
url|21155|ve_f3704c5a16|Young Chef Award|Jada Vidal|https://www.visitfloridamedia.com/releases/post/historic-moment-michelin-guide-reveals-first-statewide-restaurant-selection-for-florida/
merge-award|21261|ve_3e461fe576|ve_dd6de25c33|gault-millau|2026|Three Toques · Grand de Demain
merge-award|29699|ve_3e461fe576|ve_dd6de25c33|michelin|2026|Green Star
merge-slug|ve_3e461fe576|ve_dd6de25c33|ardon|la-table-de-christophe-hay-et-lois-bee
merge-label|21695|ve_3e461fe576|ve_dd6de25c33|city_display|Ardon|gault-millau
merge-label|21696|ve_3e461fe576|ve_dd6de25c33|country|France|gault-millau
merge-count|ci_10e2a8b9f3|2|1$r$, E'\r', '');
  v_n int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> 'f628738a612afc4567ecc103dcef6c780d79465eab800f36690c4f824ad30a52' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> 11303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 370 THEN RAISE EXCEPTION 'closed before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 175 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119409 OR (SELECT count(*) FROM audit_log) <> 114125 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10933 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;

  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id)) INTO v_txt
    FROM venues v JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'status' AND v.id = split_part(l, '|', 2);
  IF v_txt IS DISTINCT FROM 'ad6d5f740c4bea104dbfa2ce9e34ebc1' THEN RAISE EXCEPTION 'status venues %', v_txt; END IF;
  SELECT count(*) INTO v_n FROM cities c JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'status'
       AND c.id = split_part(l, '|', 4) AND c.venues_count = split_part(l, '|', 5)::int;
  IF v_n <> 4 THEN RAISE EXCEPTION 'city counts before: %', v_n; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.category||'|'||coalesce(a.distinction,'')||'|'||coalesce(a.source_url,''), E'\n' ORDER BY a.id))
    INTO v_txt FROM awards a JOIN regexp_split_to_table(rel, E'\n') l ON split_part(l, '|', 1) = 'url' AND a.id = split_part(l, '|', 2)::bigint
   WHERE a.source_id = 'michelin' AND a.year = 2026;
  IF v_txt IS DISTINCT FROM '2b0699e112f2cc46bcfae95e9acb47a5' THEN RAISE EXCEPTION 'url rows before %', v_txt; END IF;

  -- E2
  UPDATE venues v SET status = 'active' FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'status' AND v.id = split_part(l, '|', 2) AND v.status = 'closed';
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 4 THEN RAISE EXCEPTION 'venues reopened: %', v_n; END IF;
  UPDATE cities c SET venues_count = split_part(l, '|', 6)::int FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'status' AND c.id = split_part(l, '|', 4) AND c.venues_count = split_part(l, '|', 5)::int;
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 4 THEN RAISE EXCEPTION 'cities updated: %', v_n; END IF;

  -- E3
  UPDATE awards a SET source_url = split_part(l, '|', 6), distinction = nullif(split_part(l, '|', 5), '')
    FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'url' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3)
     AND a.category = split_part(l, '|', 4) AND a.source_id = 'michelin' AND a.year = 2026
     AND a.source_url IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 7 THEN RAISE EXCEPTION 'award rows updated: %', v_n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 7,
          'source-url:reopen-urls-open-items-b7-2026-10-31 | 7 legacy 2026 special-award rows (Oct 29 "unproven") get a source: '
          || 'Florida 21093 Fat Beet, 21094 Kaya, 21095 Krüs Kitchen (Green Star), 21154 The Daytrader (Exceptional Cocktails, Rhianda Smith), '
          || '21155 Kinjo (Young Chef, Jada Vidal) = Michelin press release Jun 1, 2026 on visitfloridamedia.com; Vietnam 21111 Lamai Garden, '
          || '21113 Nén Danang (Green Star) = Michelin full-list article Jun 6, 2026 | Ben "All A" Oct 31 03:42 ET (E3)')
  RETURNING id INTO v_lid;

  -- post-checks
  IF v_lid <> 176 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 366 THEN RAISE EXCEPTION 'closed after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10937 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.category||'|'||coalesce(a.distinction,'')||'|'||coalesce(a.source_url,''), E'\n' ORDER BY a.id))
    INTO v_txt FROM awards a WHERE a.id IN (21093, 21094, 21095, 21111, 21113, 21154, 21155);
  IF v_txt IS DISTINCT FROM 'f2323f93d38363bbc8b095b487a58095' THEN RAISE EXCEPTION 'url rows after %', v_txt; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119409) <> 15 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119409 AND table_name = 'venues' AND action = 'UPDATE'
         AND (old_row - 'status') = (new_row - 'status') AND old_row->>'status' = 'closed' AND new_row->>'status' = 'active') <> 4
    THEN RAISE EXCEPTION 'audit venues (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119409 AND table_name = 'cities' AND action = 'UPDATE'
         AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 4 THEN RAISE EXCEPTION 'audit cities (venues_count only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119409 AND table_name = 'awards' AND action = 'UPDATE'
         AND (old_row - 'source_url' - 'distinction') = (new_row - 'source_url' - 'distinction')) <> 7
    THEN RAISE EXCEPTION 'audit awards (source_url, distinction only)'; END IF;
END
$do$;
COMMIT;
