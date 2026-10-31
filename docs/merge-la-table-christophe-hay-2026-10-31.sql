-- merge-la-table-christophe-hay-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 7, file 2 of 2. It holds DELETE: run it in the Supabase SQL Editor
--   (SQL Editor -> New query -> paste the whole file -> Run). Run it only after file 1; the guards stop it otherwise.
-- Ben: Oct 31 02:19 ET "Let's do item 1"; 03:42 ET "All A" (E1-E4 = A; E4 held for one question, not in these files).
-- E1 merge: ve_3e461fe576 "La Table de Christophe Hay et Loïs Bée" (Ardon) into ve_dd6de25c33 "La Table - Christophe Hay" (Ardon).
--   Same restaurant: same town, same site (latabledacote.fr -> latable-orleans.com, title "Restaurant La Table - Christophe Hay
--   à Orléans", address 200 allée des 4 vents, Ardon); Michelin card la-table-christophe-hay (One Star 2026, read Oct 31);
--   the fr card la-table-christophe-hay-et-lois-bee gives an error. Survivor name unchanged (R2: card form is in the site title).
-- Writes (one transaction):
--   awards 21261 (gault-millau 2026) and 29699 (michelin 2026 Green Star): venue_id -> survivor.
--   slug ardon/la-table-de-christophe-hay-et-lois-bee -> survivor, non-canonical (the old URL keeps working).
--   city_label_source 21695, 21696 (gault-millau): venue_id -> survivor, with hand audit rows (Sep 28 Hangzhou precedent).
--   listings DELETE 1, venues DELETE 1; cities Ardon venues_count 2 -> 1.
--   Ledger 177 (michelin, award, 1) and 178 (gault-millau, award, 1).
-- Audit +8: awards UPDATE 2, slugs UPDATE 1, city_label_source UPDATE 2 (hand), listings DELETE 1, venues DELETE 1, cities UPDATE 1.
-- Relay docs/open-items-b7-build/relay.txt sha256 f628738a612afc4567ecc103dcef6c780d79465eab800f36690c4f824ad30a52.
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
  v_n int; v_lid1 bigint; v_lid2 bigint; v_txt text; v_aud bigint;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> 'f628738a612afc4567ecc103dcef6c780d79465eab800f36690c4f824ad30a52' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> 11303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10937 THEN RAISE EXCEPTION 'active before (run file 1 first)'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12944 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1641 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11303 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24003 THEN RAISE EXCEPTION 'city labels before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 176 THEN RAISE EXCEPTION 'ledger before (run file 1 first)'; END IF;
  SELECT max(id) INTO v_aud FROM audit_log;
  IF v_aud <> 119424 OR (SELECT count(*) FROM audit_log) <> 114140 THEN RAISE EXCEPTION 'audit before (run file 1 first)'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10937 THEN RAISE EXCEPTION 'venues_count sum before'; END IF;

  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_3e461fe576' AND name = 'La Table de Christophe Hay et Loïs Bée' AND status = 'active' AND city_id = 'ci_10e2a8b9f3')
    THEN RAISE EXCEPTION 'merged venue'; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_dd6de25c33' AND name = 'La Table - Christophe Hay' AND status = 'active' AND city_id = 'ci_10e2a8b9f3')
    THEN RAISE EXCEPTION 'survivor venue'; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\n' ORDER BY a.id)) INTO v_txt
    FROM awards a WHERE a.venue_id = 've_3e461fe576';
  IF v_txt IS DISTINCT FROM '627a5240d46d77a40d5550fceaa45ab9' THEN RAISE EXCEPTION 'merged award rows %', v_txt; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN awards b ON b.venue_id = 've_3e461fe576' AND a.source_id = b.source_id AND a.year = b.year AND a.category = b.category
              WHERE a.venue_id = 've_dd6de25c33') THEN RAISE EXCEPTION 'survivor already has one of the awards'; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||l.publisher, E'\n' ORDER BY l.id)) INTO v_txt
    FROM city_label_source l WHERE l.venue_id = 've_3e461fe576';
  IF v_txt IS DISTINCT FROM 'a2bc6a8e5840f9244e133687134b3ef6' THEN RAISE EXCEPTION 'merged city labels %', v_txt; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = 've_3e461fe576') <> 1
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = 've_3e461fe576' AND property_id = 'eats' AND city_slug = 'ardon' AND slug = 'la-table-de-christophe-hay-et-lois-bee' AND is_canonical)
    THEN RAISE EXCEPTION 'merged slug'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = 've_3e461fe576') <> 1 THEN RAISE EXCEPTION 'merged listing'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM blurbs WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM geo WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM addresses WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM hours WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM photo_refs WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM rename_rows WHERE venue_id = 've_3e461fe576') <> 0
    THEN RAISE EXCEPTION 'merged venue has other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path LIKE '%la-table-de-christophe-hay-et-lois-bee%' OR to_path LIKE '%la-table-de-christophe-hay-et-lois-bee%') THEN RAISE EXCEPTION 'redirect on the old path'; END IF;
  IF (SELECT venues_count FROM cities WHERE id = 'ci_10e2a8b9f3') <> 2 THEN RAISE EXCEPTION 'Ardon count before'; END IF;

  -- writes
  UPDATE awards a SET venue_id = split_part(l, '|', 4) FROM regexp_split_to_table(rel, E'\n') l
   WHERE split_part(l, '|', 1) = 'merge-award' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3)
     AND a.source_id = split_part(l, '|', 5) AND a.year = split_part(l, '|', 6)::int AND a.category = split_part(l, '|', 7);
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 2 THEN RAISE EXCEPTION 'award rows moved: %', v_n; END IF;

  UPDATE slugs SET venue_id = 've_dd6de25c33', is_canonical = false
   WHERE property_id = 'eats' AND venue_id = 've_3e461fe576' AND city_slug = 'ardon' AND slug = 'la-table-de-christophe-hay-et-lois-bee';
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 1 THEN RAISE EXCEPTION 'slug rows moved: %', v_n; END IF;

  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'UPDATE', to_jsonb(l), to_jsonb(l) || jsonb_build_object('venue_id', 've_dd6de25c33')
    FROM city_label_source l WHERE l.venue_id = 've_3e461fe576' ORDER BY l.id;
  UPDATE city_label_source SET venue_id = 've_dd6de25c33' WHERE venue_id = 've_3e461fe576';
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 2 THEN RAISE EXCEPTION 'city labels moved: %', v_n; END IF;

  DELETE FROM listings WHERE venue_id = 've_3e461fe576';
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 1 THEN RAISE EXCEPTION 'listings deleted: %', v_n; END IF;
  DELETE FROM venues WHERE id = 've_3e461fe576';
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 1 THEN RAISE EXCEPTION 'venues deleted: %', v_n; END IF;
  UPDATE cities SET venues_count = 1 WHERE id = 'ci_10e2a8b9f3' AND venues_count = 2;
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 1 THEN RAISE EXCEPTION 'Ardon count updated: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 1, 'merge:merge-la-table-christophe-hay-2026-10-31 | ve_3e461fe576 "La Table de Christophe Hay et Loïs Bée" = '
          || 've_dd6de25c33 "La Table - Christophe Hay" (Ardon; same site latable-orleans.com; Michelin card la-table-christophe-hay) | award 29699 '
          || '(2026 Green Star) -> ve_dd6de25c33 | old slug non-canonical; 2 gault-millau city labels moved; listing and venue deleted | Ben "All A" Oct 31 03:42 ET (E1)')
  RETURNING id INTO v_lid1;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('gault-millau', 'award', 1, 'merge:merge-la-table-christophe-hay-2026-10-31 | award 21261 (2026 Three Toques · Grand de Demain) '
          || 've_3e461fe576 -> ve_dd6de25c33 (same restaurant, see the michelin ledger row of this merge) | Ben "All A" Oct 31 03:42 ET (E1)')
  RETURNING id INTO v_lid2;

  -- post-checks
  IF v_lid1 <> 177 OR v_lid2 <> 178 THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM venues) <> 11302 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10936 THEN RAISE EXCEPTION 'active after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12944 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1642
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11302 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11302 THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24003 THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10936 THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
              GROUP BY v.id HAVING count(s.slug) <> 1) THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  SELECT string_agg(id||' '||source_id||' '||category, ', ' ORDER BY id) INTO v_txt FROM awards WHERE venue_id = 've_dd6de25c33';
  IF v_txt IS DISTINCT FROM '21261 gault-millau Three Toques · Grand de Demain, 22311 michelin One Star, 29699 michelin Green Star, 29936 michelin Mindful Voices'
    THEN RAISE EXCEPTION 'survivor awards after: %', v_txt; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM slugs WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM city_label_source WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM listings WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM venues WHERE id = 've_3e461fe576') <> 0 THEN RAISE EXCEPTION 'rows left on the merged venue id'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud) <> 8 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'awards' AND action = 'UPDATE' AND row_pk IN ('21261', '29699')) <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'slugs' AND action = 'UPDATE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'city_label_source' AND action = 'UPDATE' AND row_pk IN ('21695', '21696')) <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'listings' AND action = 'DELETE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'venues' AND action = 'DELETE' AND row_pk = 've_3e461fe576') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'cities' AND action = 'UPDATE' AND row_pk = 'ci_10e2a8b9f3') <> 1
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
