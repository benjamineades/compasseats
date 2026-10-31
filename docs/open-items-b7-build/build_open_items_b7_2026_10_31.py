#!/usr/bin/env python3
"""Build the 2 SQL files of open items block 7 (Oct 31, 2026) from relay.txt.

Usage: python3 build_open_items_b7_2026_10_31.py <relay.txt> <out_dir> [test]
  test = write a pre-check test copy of file 2 with today's counts (before file 1), for the Read connector.
File 1 (Write connector): E2 reopen 4 venues + their city counts; E3 source URL (and person) on 7 legacy special-award rows.
File 2 (SQL Editor, has DELETE): E1 merge ve_3e461fe576 into ve_dd6de25c33 (La Table - Christophe Hay, Ardon).
"""
import hashlib, sys, os

relay_path, out_dir = sys.argv[1], sys.argv[2]
TEST = len(sys.argv) > 3 and sys.argv[3] == 'test'
raw = open(relay_path, encoding='utf-8').read()
L = [l.split('|') for l in raw.split('\n') if l]
md5 = lambda s: hashlib.md5(s.encode('utf-8')).hexdigest()
sha = hashlib.sha256(raw.encode('utf-8')).hexdigest()
q = lambda s: "'" + s.replace("'", "''") + "'"

ST = [x for x in L if x[0] == 'status']
UR = [x for x in L if x[0] == 'url']
MA = [x for x in L if x[0] == 'merge-award']
MS = [x for x in L if x[0] == 'merge-slug'][0]
ML = [x for x in L if x[0] == 'merge-label']
MC = [x for x in L if x[0] == 'merge-count'][0]
assert len(ST) == 4 and len(UR) == 7 and len(MA) == 2 and len(ML) == 2

# live md5 values read Oct 31 07:5x UTC (the build stops if the relay does not give the same value)
G_STATUS = md5('\n'.join(f"{x[1]}|{x[2]}|closed|{x[3]}" for x in sorted(ST, key=lambda x: x[1])))
G_URL = md5('\n'.join(f"{x[1]}|{x[2]}|{x[3]}||" for x in sorted(UR, key=lambda x: int(x[1]))))
G_MAW = md5('\n'.join(f"{x[1]}|{x[2]}|{x[4]}|{x[5]}|{x[6]}" for x in sorted(MA, key=lambda x: int(x[1]))))
G_LAB = md5('\n'.join(f"{x[1]}|{x[2]}|{x[4]}|{x[5]}|{x[6]}" for x in sorted(ML, key=lambda x: int(x[1]))))
assert G_STATUS == 'ad6d5f740c4bea104dbfa2ce9e34ebc1', G_STATUS
assert G_URL == '2b0699e112f2cc46bcfae95e9acb47a5', G_URL
assert G_MAW == '627a5240d46d77a40d5550fceaa45ab9', G_MAW
assert G_LAB == 'a2bc6a8e5840f9244e133687134b3ef6', G_LAB
G_URL_AFTER = md5('\n'.join(f"{x[1]}|{x[2]}|{x[3]}|{x[4]}|{x[5]}" for x in sorted(UR, key=lambda x: int(x[1]))))

C0 = dict(venues=11303, active=10933, closed=370, awards=23363, slugs=12944, noncanon=1641, listings=11303, cls=24003,
          vc_sum=10933, led=175, aud=119409, aud_n=114125)
C1 = dict(C0, active=10937, closed=366, vc_sum=10937, led=176, aud=119424, aud_n=114140)   # after file 1
P2 = C0 if TEST else C1
REL = f"replace($r${raw}$r$, E'\\r', '')"
HDR = "-- Ben: Oct 31 02:19 ET \"Let's do item 1\"; 03:42 ET \"All A\" (E1-E4 = A; E4 held for one question, not in these files).\n"

# ---------------- FILE 1 ----------------
f1 = f"""-- reopen-urls-open-items-b7-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 7, file 1 of 2. INSERT/UPDATE only: Write connector.
{HDR}-- E2 venues status closed -> active (status only), 4 venues set closed by the Aug 14 sheet load with no closure evidence;
--    each live Michelin card (read Oct 31) shows the 2026 edition, opening hours and no closure note; each got Mindful
--    Voices in Oct 2026: La Galinette (Perpignan), La Tana Gourmet (Asiago), Rolland (Plourhan), Ursus (Tignes).
--    cities.venues_count of the 4 cities +1 (block 5 method: stored count = view city_venue_counts). No ledger row.
-- E3 awards source_url NULL -> source (7 legacy rows, special-awards block "unproven"); distinction = person on 2 rows
--    (21154 Rhianda Smith, 21155 Jada Vidal), as the Oct 29 special-awards rows. Year and category unchanged.
--    Florida 5: Michelin press release Jun 1, 2026 on Visit Florida's media site (no guide.michelin.com page names them).
--    Vietnam 2: Michelin article "full list" Jun 6, 2026. Ledger 176 (michelin, award, 7).
-- Relay docs/open-items-b7-build/relay.txt sha256 {sha}.
-- Expected: closed 370 -> 366, venues_count sum 10933 -> 10937, ledger 175 -> 176,
--   audit 119409 -> 119424 (+15: venues UPDATE 4, cities UPDATE 4, awards UPDATE 7).
BEGIN;
DO $do$
DECLARE
  rel text := {REL};
  v_n int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> {C0['venues']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> {C0['closed']} THEN RAISE EXCEPTION 'closed before'; END IF;
  IF (SELECT count(*) FROM awards) <> {C0['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {C0['led']} THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {C0['aud']} OR (SELECT count(*) FROM audit_log) <> {C0['aud_n']} THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {C0['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;

  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id)) INTO v_txt
    FROM venues v JOIN regexp_split_to_table(rel, E'\\n') l ON split_part(l, '|', 1) = 'status' AND v.id = split_part(l, '|', 2);
  IF v_txt IS DISTINCT FROM '{G_STATUS}' THEN RAISE EXCEPTION 'status venues %', v_txt; END IF;
  SELECT count(*) INTO v_n FROM cities c JOIN regexp_split_to_table(rel, E'\\n') l ON split_part(l, '|', 1) = 'status'
       AND c.id = split_part(l, '|', 4) AND c.venues_count = split_part(l, '|', 5)::int;
  IF v_n <> 4 THEN RAISE EXCEPTION 'city counts before: %', v_n; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.category||'|'||coalesce(a.distinction,'')||'|'||coalesce(a.source_url,''), E'\\n' ORDER BY a.id))
    INTO v_txt FROM awards a JOIN regexp_split_to_table(rel, E'\\n') l ON split_part(l, '|', 1) = 'url' AND a.id = split_part(l, '|', 2)::bigint
   WHERE a.source_id = 'michelin' AND a.year = 2026;
  IF v_txt IS DISTINCT FROM '{G_URL}' THEN RAISE EXCEPTION 'url rows before %', v_txt; END IF;

  -- E2
  UPDATE venues v SET status = 'active' FROM regexp_split_to_table(rel, E'\\n') l
   WHERE split_part(l, '|', 1) = 'status' AND v.id = split_part(l, '|', 2) AND v.status = 'closed';
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 4 THEN RAISE EXCEPTION 'venues reopened: %', v_n; END IF;
  UPDATE cities c SET venues_count = split_part(l, '|', 6)::int FROM regexp_split_to_table(rel, E'\\n') l
   WHERE split_part(l, '|', 1) = 'status' AND c.id = split_part(l, '|', 4) AND c.venues_count = split_part(l, '|', 5)::int;
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 4 THEN RAISE EXCEPTION 'cities updated: %', v_n; END IF;

  -- E3
  UPDATE awards a SET source_url = split_part(l, '|', 6), distinction = nullif(split_part(l, '|', 5), '')
    FROM regexp_split_to_table(rel, E'\\n') l
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
  IF v_lid <> {C0['led']+1} THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> {C1['closed']} THEN RAISE EXCEPTION 'closed after'; END IF;
  IF (SELECT count(*) FROM awards) <> {C0['awards']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {C1['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.category||'|'||coalesce(a.distinction,'')||'|'||coalesce(a.source_url,''), E'\\n' ORDER BY a.id))
    INTO v_txt FROM awards a WHERE a.id IN ({', '.join(x[1] for x in sorted(UR, key=lambda x: int(x[1])))});
  IF v_txt IS DISTINCT FROM '{G_URL_AFTER}' THEN RAISE EXCEPTION 'url rows after %', v_txt; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud']}) <> 15 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud']} AND table_name = 'venues' AND action = 'UPDATE'
         AND (old_row - 'status') = (new_row - 'status') AND old_row->>'status' = 'closed' AND new_row->>'status' = 'active') <> 4
    THEN RAISE EXCEPTION 'audit venues (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud']} AND table_name = 'cities' AND action = 'UPDATE'
         AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 4 THEN RAISE EXCEPTION 'audit cities (venues_count only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud']} AND table_name = 'awards' AND action = 'UPDATE'
         AND (old_row - 'source_url' - 'distinction') = (new_row - 'source_url' - 'distinction')) <> 7
    THEN RAISE EXCEPTION 'audit awards (source_url, distinction only)'; END IF;
END
$do$;
COMMIT;
"""

# ---------------- FILE 2 ----------------
A, S = MA, MS
f2 = f"""-- merge-la-table-christophe-hay-2026-10-31.sql{' (PRE-CHECK TEST COPY: counts before file 1; dry run only)' if TEST else ''}
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 7, file 2 of 2. It holds DELETE: run it in the Supabase SQL Editor
--   (SQL Editor -> New query -> paste the whole file -> Run). Run it only after file 1; the guards stop it otherwise.
{HDR}-- E1 merge: ve_3e461fe576 "La Table de Christophe Hay et Loïs Bée" (Ardon) into ve_dd6de25c33 "La Table - Christophe Hay" (Ardon).
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
-- Relay docs/open-items-b7-build/relay.txt sha256 {sha}.
BEGIN;
DO $do$
DECLARE
  rel text := {REL};
  v_n int; v_lid1 bigint; v_lid2 bigint; v_txt text; v_aud bigint;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> {P2['venues']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> {P2['active']} THEN RAISE EXCEPTION 'active before (run file 1 first)'; END IF;
  IF (SELECT count(*) FROM awards) <> {P2['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {P2['slugs']} OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {P2['noncanon']} THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> {P2['listings']} THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> {P2['cls']} THEN RAISE EXCEPTION 'city labels before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {P2['led']} THEN RAISE EXCEPTION 'ledger before (run file 1 first)'; END IF;
  SELECT max(id) INTO v_aud FROM audit_log;
  IF v_aud <> {P2['aud']} OR (SELECT count(*) FROM audit_log) <> {P2['aud_n']} THEN RAISE EXCEPTION 'audit before (run file 1 first)'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {P2['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum before'; END IF;

  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_3e461fe576' AND name = 'La Table de Christophe Hay et Loïs Bée' AND status = 'active' AND city_id = '{MC[1]}')
    THEN RAISE EXCEPTION 'merged venue'; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_dd6de25c33' AND name = 'La Table - Christophe Hay' AND status = 'active' AND city_id = '{MC[1]}')
    THEN RAISE EXCEPTION 'survivor venue'; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\\n' ORDER BY a.id)) INTO v_txt
    FROM awards a WHERE a.venue_id = 've_3e461fe576';
  IF v_txt IS DISTINCT FROM '{G_MAW}' THEN RAISE EXCEPTION 'merged award rows %', v_txt; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN awards b ON b.venue_id = 've_3e461fe576' AND a.source_id = b.source_id AND a.year = b.year AND a.category = b.category
              WHERE a.venue_id = 've_dd6de25c33') THEN RAISE EXCEPTION 'survivor already has one of the awards'; END IF;
  SELECT md5(string_agg(l.id||'|'||l.venue_id||'|'||l.from_column||'|'||l.label||'|'||l.publisher, E'\\n' ORDER BY l.id)) INTO v_txt
    FROM city_label_source l WHERE l.venue_id = 've_3e461fe576';
  IF v_txt IS DISTINCT FROM '{G_LAB}' THEN RAISE EXCEPTION 'merged city labels %', v_txt; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = 've_3e461fe576') <> 1
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = 've_3e461fe576' AND property_id = 'eats' AND city_slug = '{S[3]}' AND slug = '{S[4]}' AND is_canonical)
    THEN RAISE EXCEPTION 'merged slug'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = 've_3e461fe576') <> 1 THEN RAISE EXCEPTION 'merged listing'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM blurbs WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM geo WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM addresses WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM hours WHERE venue_id = 've_3e461fe576') + (SELECT count(*) FROM photo_refs WHERE venue_id = 've_3e461fe576')
     + (SELECT count(*) FROM rename_rows WHERE venue_id = 've_3e461fe576') <> 0
    THEN RAISE EXCEPTION 'merged venue has other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path LIKE '%{S[4]}%' OR to_path LIKE '%{S[4]}%') THEN RAISE EXCEPTION 'redirect on the old path'; END IF;
  IF (SELECT venues_count FROM cities WHERE id = '{MC[1]}') <> {MC[2]} THEN RAISE EXCEPTION 'Ardon count before'; END IF;

  -- writes
  UPDATE awards a SET venue_id = split_part(l, '|', 4) FROM regexp_split_to_table(rel, E'\\n') l
   WHERE split_part(l, '|', 1) = 'merge-award' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3)
     AND a.source_id = split_part(l, '|', 5) AND a.year = split_part(l, '|', 6)::int AND a.category = split_part(l, '|', 7);
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 2 THEN RAISE EXCEPTION 'award rows moved: %', v_n; END IF;

  UPDATE slugs SET venue_id = 've_dd6de25c33', is_canonical = false
   WHERE property_id = 'eats' AND venue_id = 've_3e461fe576' AND city_slug = '{S[3]}' AND slug = '{S[4]}';
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
  UPDATE cities SET venues_count = {MC[3]} WHERE id = '{MC[1]}' AND venues_count = {MC[2]};
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
  IF v_lid1 <> {P2['led']+1} OR v_lid2 <> {P2['led']+2} THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM venues) <> {P2['venues']-1} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> {P2['active']-1} THEN RAISE EXCEPTION 'active after'; END IF;
  IF (SELECT count(*) FROM awards) <> {P2['awards']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {P2['slugs']} OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {P2['noncanon']+1}
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> {P2['venues']-1} THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> {P2['listings']-1} THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> {P2['cls']} THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {P2['vc_sum']-1} THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
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
     OR (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'cities' AND action = 'UPDATE' AND row_pk = '{MC[1]}') <> 1
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
"""

os.makedirs(out_dir, exist_ok=True)
if not TEST:
    open(os.path.join(out_dir, 'reopen-urls-open-items-b7-2026-10-31.sql'), 'w', encoding='utf-8').write(f1)
    open(os.path.join(out_dir, 'merge-la-table-christophe-hay-2026-10-31.sql'), 'w', encoding='utf-8').write(f2)
else:
    open(os.path.join(out_dir, 'merge-la-table-christophe-hay-2026-10-31-TEST.sql'), 'w', encoding='utf-8').write(f2)
print('relay sha256', sha)
