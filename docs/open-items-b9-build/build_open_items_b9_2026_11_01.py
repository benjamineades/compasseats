"""Open items block 9 (Nov 1 2026): Best Chef held rows + venue name checks.

Builds, from relay.txt (written here; every live value is gated by md5/sha256 inside SQL):
  ../rename-urls-open-items-b9-2026-11-01.sql   file 1, INSERT/UPDATE only (Write connector)
  ../cleanup-best-chef-b9-2026-11-01.sql        file 2, DELETE (SQL Editor)
  cleanup-test-current-counts.sql               file 2 pre-check copy with today's counts (dry run before file 1)

Ben: Nov 1 08:17 ET "1 & 2"; 08:28 ET "All recommendations".
"""
import hashlib, re, sys

U24 = 'https://thebestchefawards.com/events-results/?id=1874'
U25 = 'https://thebestchefawards.com/events-results/?id=2376'
BEN = 'Ben Nov 1 08:28 ET "All recommendations"'

# ---- renames: (venue_id, live name, new name, source_id, source_url, city_slug, old canonical slug, new slug, mode, note)
REN = [
    ('ve_1727fb4901', 'Le Calandrе', 'Le Calandre', 'michelin',
     'https://guide.michelin.com/us/en/veneto/rubano/restaurant/le-calandre', 'padua', 'le-calandr', 'le-calandre', 'reuse',
     'live name ends in Cyrillic U+0435; card h1 "Le Calandre"; site alajmo.it "Le Calandre" (menu, slide, body); Best Chef "Le Calandre"; rule R1'),
    ('ve_98b2c2d46b', 'Bed & Breakfast - Les Belles Perdrix', 'Les Belles Perdrix de Troplong Mondot', 'michelin',
     'https://guide.michelin.com/us/en/nouvelle-aquitaine/saint-milion/restaurant/les-belles-perdrix-de-troplong-mondot',
     'saint-emilion', 'bed-breakfast-les-belles-perdrix', 'les-belles-perdrix-de-troplong-mondot', 'reuse',
     'card h1 "Les Belles Perdrix de Troplong Mondot"; site troplong-mondot.com/restaurant: "Les Belles Perdrix" (title, H1), "Les Belles Perdrix de Troplong Mondot" (body); rule R2'),
    ('ve_b60189d14c', 'Home Aribert - Restaurant Gastronomique 2 Étoiles Michelin', 'Maison Aribert', 'michelin',
     'https://guide.michelin.com/us/en/auvergne-rhone-alpes/uriage-les-bains/restaurant/maison-aribert',
     'uriage-les-bains', 'home-aribert-restaurant-gastronomique-2-etoiles-michelin', 'maison-aribert', 'reuse',
     'card h1 "Maison Aribert"; site maisonaribert.com "Maison Aribert" (title, site name, logo alt); Best Chef "Maison Aribert"; rule R1'),
    ('ve_4e2b60de79', 'KOKI - The House of Senses', 'Hibana by Koki', 'michelin',
     'https://guide.michelin.com/us/en/ha-noi/ha-noi_2974158/restaurant/hibana-by-koki', 'hanoi', 'koki-the-house-of-senses',
     'hibana-by-koki', 'insert',
     'card h1 "Hibana by Koki" (One Star 2026, B1F Capella Hanoi); Best Chef 2024/2025 "Hibana by Koki"; site capellahotels.com not read (client error); rule R5; 101 Best Steakhouses row (Koki, parent restaurant) stays on the venue (Ben D3 = A)'),
    ('ve_53b3c4e143', 'EDGE for Men - V & A Waterfront', 'EDGE', 'best-chef-awards',
     'https://thebestchefawards.com/?post_type=chefs&p=25174', 'cape-town', 'edge-for-men-v-a-waterfront', 'edge', 'insert',
     'live name is a shop name; Best Chef 2025 card "EDGE" (Vusi Ndlovu, Cape Town); site edgerestaurant.africa "EDGE" (title, menu, footer; capitals only); rule R3'),
    ('ve_ab0ec4c74c', 'Xiamen', 'XIA', 'best-chef-awards',
     'https://thebestchefawards.com/?post_type=chefs&p=24980', 'xiamen', 'xiamen', 'xia', 'insert',
     'live name is the city (legacy load lost the name); Best Chef 2025 card "Xia" (Kang Yang); site lohkahhotel.com "XIA RESTAURANT", "XIA Restaurant", "XIA" (capitals only); Michelin card "Xia"; rule R3'),
    ('ve_2922f8b9e6', 'The Palash Vann Resort', 'Palaash', 'best-chef-awards',
     'https://thebestchefawards.com/?post_type=chefs&p=24787', 'maharashtra', 'the-palash-vann-resort', 'palaash', 'insert',
     'Best Chef 2024/2025 card "Palaash" (Amninder Sandhu, Tipai, Yavatmal); site wildlifeluxuries.com "Palaash"; rule R1'),
    ('ve_83aca60857', 'Hotel Cañitas Classic', 'Cañitas Maite', 'best-chef-awards',
     'https://thebestchefawards.com/?post_type=chefs&p=24941', 'casas-ibanez', 'hotel-canitas-classic', 'canitas-maite', 'insert',
     'live name is the hotel; Best Chef 2025 card and Michelin card "Cañitas Maite Gastro" (Tomás Pérez Úbeda 6, the hotel address); site hotelcanitasmaite.com writes "Cañitas Maite", "Restaurante Cañitas Maite", never "Gastro", title "Cañitas Maite"; rule R4'),
]
# ---- award row fixes: (award id, venue before, venue after, url, note)
FIX = [
    (3453, 've_53ec037b5f', 've_53ec037b5f', U25,
     'Flores Raras = El Poblet renamed Jan 2026 (same address C/ Correus 8, same owner; Michelin card "formerly known as El Poblet"); Best Chef 2025 card Luis Valls "El Poblet (former workplace)", 2 knives'),
    (15690, 've_d6d7a07cee', 've_38916224da', U25,
     'moved Ensue -> Fumée: Best Chef 2025 has one Shenzhen 2-knife entry, Reina Chen, Fumée; Ensue (Jeff Wu) is 1 knife = row 15691'),
]
# ---- award inserts: (venue, year, category, url, note)
ADD = [
    ('ve_f026dbec1c', 2024, '2-Knife', U24, 'Guy Savoy (Paris), Best Chef 2024 card 2 knives (chef id 19907)'),
    ('ve_f026dbec1c', 2025, '2-Knife', U25, 'Guy Savoy (Paris), Best Chef 2025 card 2 knives (chef id 19907)'),
]
# ---- file 2 deletes: (venue, name, award id, category, city_id, count before, count after, city_slug/slug, label ids, note)
DEL = [
    ('ve_42dfc9b029', 'The Fellas', 16190, '1-Knife', 'ci_22638a3131', 112, 111, 'shanghai/the-fellas', '15690,15691',
     'Italian rooftop bar (Yan\'an Rd E 7, 7F); no Best Chef 2024/2025 card names it (results pages and special awards read Nov 1)'),
    ('ve_8caa39d442', 'Fo\'ao Vaperse Hotel', 15997, '1-Knife', 'ci_d9d7a94326', 74, 73, 'guangzhou/fo-ao-vaperse-hotel', '15536,15537',
     'Vaperse is a hotel (5 Jinsui Rd); no Best Chef 2024/2025 card names Vaperse or Fo\'ao (results pages and special awards read Nov 1)'),
]
LIVE_MD5 = '0f9c5a1cc4096ddaf4b99e2700de2082'  # live id|name of the 8 venues, read Nov 1 13:28:54 UTC

def md5(s): return hashlib.md5(s.encode('utf-8')).hexdigest()
def sha(s): return hashlib.sha256(s.encode('utf-8')).hexdigest()
def slug(name):
    import unicodedata
    s = unicodedata.normalize('NFD', name.lower())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')

ren_sorted = sorted(REN)
assert md5('\n'.join(f'{r[0]}|{r[1]}' for r in ren_sorted)) == LIVE_MD5, 'live names'
for r in REN:
    assert slug(r[2]) == r[7], (r[2], slug(r[2]))
    assert '|' not in ''.join(map(str, r)), r
NEW_MD5 = md5('\n'.join(f'{r[0]}|{r[2]}' for r in ren_sorted))

lines = []
for i, r in enumerate(REN, 1):
    lines.append('|'.join(['ren', str(i)] + list(r)))
for f in FIX:
    lines.append('|'.join(['fix'] + [str(x) for x in f]))
for a in ADD:
    lines.append('|'.join(['add'] + [str(x) for x in a]))
relay1 = '\n'.join(lines)
relay2 = '\n'.join('|'.join(['del'] + [str(x) for x in d]) for d in DEL)
open('relay-file1.txt', 'w', encoding='utf-8').write(relay1)
open('relay-file2.txt', 'w', encoding='utf-8').write(relay2)
S1, S2 = sha(relay1), sha(relay2)

# counts (live Nov 1 13:28 UTC) and the expected state after file 1
B = dict(venues=11302, active=10936, awards=23363, slugs=12945, noncanon=1643, listings=11302, blurbs=142, rb=18, rr=1201,
         led_n=136, led_max=180, aud_n=115448, aud_max=120732, vc_sum=10936, cls=24003)
A1 = dict(B, awards=B['awards'] + 2, slugs=B['slugs'] + 5, noncanon=B['noncanon'] + 8, rb=B['rb'] + 1, rr=B['rr'] + 8,
          led_n=B['led_n'] + 4, led_max=B['led_max'] + 4, aud_n=B['aud_n'] + 28, aud_max=B['aud_max'] + 28)
A2 = dict(A1, venues=A1['venues'] - 2, active=A1['active'] - 2, awards=A1['awards'] - 2, slugs=A1['slugs'] - 2,
          listings=A1['listings'] - 2, cls=A1['cls'] - 4, led_n=A1['led_n'] + 1, led_max=A1['led_max'] + 1,
          aud_n=A1['aud_n'] + 14, aud_max=A1['aud_max'] + 14, vc_sum=A1['vc_sum'] - 2)

REL = "regexp_split_to_table(rel, E'\\n') l"
def sp(i): return f"split_part(l, '|', {i})"

file1 = f"""-- rename-urls-open-items-b9-2026-11-01.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 9, file 1 of 2. INSERT/UPDATE only: Write connector.
-- Ben: Nov 1 08:17 ET "1 & 2"; 08:28 ET "All recommendations" (held rows A, 8 names A, Hibana A, Guy Savoy A).
-- 1. Rename batch rename-open-items-b9-2026-11-01 (8 venues; rules R1-R5; same writes as scripts/rename/apply.ts):
{chr(10).join(f'--    {r[0]} {r[1]!r} -> {r[2]!r} ({r[3]})' for r in REN)}
-- 2. Slugs: old canonical -> non-canonical (8); reuse an old slug as canonical (3: {', '.join(r[5]+'/'+r[7] for r in REN if r[8]=='reuse')});
--    insert a new canonical slug (5: {', '.join(r[5]+'/'+r[7] for r in REN if r[8]=='insert')}).
-- 3. Best Chef row fixes: 3453 Flores Raras gets the 2025 URL; 15690 moves Ensue -> Fumée (ve_38916224da) with the 2025 URL.
-- 4. Best Chef rows added: Guy Savoy (Paris) 2024 2-Knife and 2025 2-Knife, URL = the results page of each edition.
-- Not in this file: row 15727 (8½ Macau) held for the Hong Kong/Macau block; The Fellas and Fo'ao Vaperse Hotel = file 2.
-- Relay docs/open-items-b9-build/relay-file1.txt sha256 {S1}.
-- Expected: rename_batches {B['rb']} -> {A1['rb']}, rename_rows {B['rr']} -> {A1['rr']}, slugs {B['slugs']} -> {A1['slugs']} (non-canonical {B['noncanon']} -> {A1['noncanon']}),
--   awards {B['awards']} -> {A1['awards']}, ledger {B['led_max']} -> {A1['led_max']} (michelin name 4, best-chef-awards name 4, best-chef-awards award 2 + 2),
--   audit {B['aud_max']} -> {A1['aud_max']} (+28: venues UPDATE 8, slugs UPDATE 11, slugs INSERT 5, awards UPDATE 2, awards INSERT 2).
-- Dry run: send through the Read connector. It stops at the first INSERT with "read-only transaction".
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel${relay1}$rel$, E'\\r', '');
  bid bigint; n int; x int; v_lid bigint;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{S1}' THEN RAISE EXCEPTION 'relay hash'; END IF;
  -- counts before
  IF (SELECT count(*) FROM venues) <> {B['venues']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {B['slugs']} OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {B['noncanon']} THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> {B['listings']} OR (SELECT count(*) FROM blurbs) <> {B['blurbs']} THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> {B['rb']} OR (SELECT count(*) FROM rename_rows) <> {B['rr']} THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led_n']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['led_max']} THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> {B['aud_n']} OR (SELECT max(id) FROM audit_log) <> {B['aud_max']} THEN RAISE EXCEPTION 'audit before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key = 'rename-open-items-b9-2026-11-01') THEN RAISE EXCEPTION 'batch key used'; END IF;

  -- rename gates
  IF (SELECT count(*) FROM {REL} WHERE {sp(1)} = 'ren') <> 8 THEN RAISE EXCEPTION 'ren lines'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id)) FROM venues v JOIN {REL} ON {sp(1)} = 'ren' AND v.id = {sp(3)}
         AND v.name = {sp(4)} AND v.status = 'active') <> '{LIVE_MD5}' THEN RAISE EXCEPTION 'live names differ from the Nov 1 read'; END IF;
  IF (SELECT md5(string_agg({sp(3)}||'|'||{sp(5)}, E'\\n' ORDER BY {sp(3)})) FROM {REL} WHERE {sp(1)} = 'ren') <> '{NEW_MD5}' THEN RAISE EXCEPTION 'new names'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows r JOIN {REL} ON {sp(1)} = 'ren' AND r.venue_id = {sp(3)}) THEN RAISE EXCEPTION 'earlier rename_rows'; END IF;
  IF (SELECT count(*) FROM {REL} WHERE {sp(1)} = 'ren'
        AND trim(both '-' from regexp_replace(lower(f_unaccent({sp(5)})), '[^a-z0-9]+', '-', 'g')) = {sp(10)}) <> 8 THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN {REL} ON {sp(1)} = 'ren' AND s.venue_id = {sp(3)} AND s.property_id = 'eats'
        AND s.is_canonical AND s.city_slug = {sp(8)} AND s.slug = {sp(9)}) <> 8 THEN RAISE EXCEPTION 'old canonical slugs'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN {REL} ON {sp(1)} = 'ren' AND {sp(11)} = 'reuse' AND s.venue_id = {sp(3)}
        AND s.property_id = 'eats' AND NOT s.is_canonical AND s.city_slug = {sp(8)} AND s.slug = {sp(10)}) <> 3 THEN RAISE EXCEPTION 'reuse slugs'; END IF;
  IF EXISTS (SELECT 1 FROM slugs s JOIN {REL} ON {sp(1)} = 'ren' AND {sp(11)} = 'insert' AND s.city_slug = {sp(8)} AND s.slug = {sp(10)})
    THEN RAISE EXCEPTION 'new slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM redirects d JOIN {REL} ON {sp(1)} = 'ren'
        AND d.from_path IN ('/'||{sp(8)}||'/'||{sp(10)}, '/venue/'||{sp(8)}||'/'||{sp(10)})) THEN RAISE EXCEPTION 'new path in redirects'; END IF;
  WITH batch AS (SELECT {sp(3)} AS venue_id, {sp(5)} AS new_name FROM {REL} WHERE {sp(1)} = 'ren'),
       scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
       fin   AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
                   FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id)
  SELECT count(*) INTO x FROM fin a JOIN batch ON batch.venue_id = a.id
    JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id AND norm_key(o.name) = norm_key(a.name);
  IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key collisions %', x; END IF;

  -- fix / add gates
  IF (SELECT count(*) FROM awards a JOIN {REL} ON {sp(1)} = 'fix' AND a.id = {sp(2)}::bigint AND a.venue_id = {sp(3)}
        AND a.source_id = 'best-chef-awards' AND a.year = 2025 AND a.category = '2-Knife' AND a.source_url IS NULL) <> 2 THEN RAISE EXCEPTION 'fix rows'; END IF;
  IF (SELECT count(*) FROM venues WHERE id = 've_38916224da' AND name = 'Fumée' AND status = 'active') <> 1
     OR EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_38916224da' AND source_id = 'best-chef-awards') THEN RAISE EXCEPTION 'Fumée'; END IF;
  IF (SELECT count(*) FROM venues WHERE id = 've_f026dbec1c' AND name = 'Guy Savoy' AND status = 'active') <> 1
     OR EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_f026dbec1c' AND source_id = 'best-chef-awards') THEN RAISE EXCEPTION 'Guy Savoy'; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id = 'best-chef-awards' AND category = '2-Knife') <> 1 THEN RAISE EXCEPTION 'category'; END IF;
  IF (SELECT count(*) FROM award_sources WHERE slug IN ('michelin', 'best-chef-awards')) <> 2 THEN RAISE EXCEPTION 'sources'; END IF;

  -- 1. rename batch
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-open-items-b9-2026-11-01', 'staged', 'Open items block 9 (Nov 1): 8 venue names from the Best Chef pairing check (Cyrillic letter, shop, hotel or city names in place of the restaurant name); rules R1-R5. {BEN}. Gated SQL file, Write connector; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, {sp(2)}::int, {sp(3)}, {sp(4)}, {sp(5)}, {sp(6)}, {sp(7)}, 'rename',
         jsonb_build_object('note', {sp(12)} || ' | {BEN}', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', {sp(8)}, 'slug', {sp(9)})
    FROM {REL} JOIN venues v ON v.id = {sp(3)} WHERE {sp(1)} = 'ren';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = {sp(5)} FROM {REL} WHERE {sp(1)} = 'ren' AND v.id = {sp(3)} AND v.name = {sp(4)};
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 8 THEN RAISE EXCEPTION 'venues renamed %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 4, 'rename-apply:rename-open-items-b9-2026-11-01 | gated SQL file docs/rename-urls-open-items-b9-2026-11-01.sql (Write connector) | 4 names follow the Michelin 2026 card and the venue site, rules R1, R2, R5: Le Calandre (Cyrillic letter removed), Les Belles Perdrix de Troplong Mondot, Maison Aribert, Hibana by Koki | {BEN}')
  RETURNING id INTO v_lid;
  IF v_lid <> {B['led_max'] + 1} THEN RAISE EXCEPTION 'ledger id michelin name %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'name', 4, 'rename-apply:rename-open-items-b9-2026-11-01 | gated SQL file docs/rename-urls-open-items-b9-2026-11-01.sql (Write connector) | 4 names follow the Best Chef card and the venue site, rules R1, R3, R4: EDGE (was a shop name), XIA (was the city), Palaash (was the resort), Cañitas Maite (was the hotel) | {BEN}')
  RETURNING id INTO v_lid;
  IF v_lid <> {B['led_max'] + 2} THEN RAISE EXCEPTION 'ledger id best-chef name %', v_lid; END IF;
  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status'; END IF;

  -- 2. slugs
  UPDATE slugs s SET is_canonical = false FROM {REL}
   WHERE {sp(1)} = 'ren' AND s.property_id = 'eats' AND s.venue_id = {sp(3)} AND s.city_slug = {sp(8)} AND s.slug = {sp(9)} AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'old canonical updated %', n; END IF;
  UPDATE slugs s SET is_canonical = true FROM {REL}
   WHERE {sp(1)} = 'ren' AND {sp(11)} = 'reuse' AND s.property_id = 'eats' AND s.venue_id = {sp(3)} AND s.city_slug = {sp(8)} AND s.slug = {sp(10)} AND NOT s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'reused slugs %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', {sp(8)}, {sp(10)}, {sp(3)}, true FROM {REL} WHERE {sp(1)} = 'ren' AND {sp(11)} = 'insert';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 5 THEN RAISE EXCEPTION 'new slugs %', n; END IF;

  -- 3. award row fixes
  UPDATE awards a SET venue_id = {sp(4)}, source_url = {sp(5)} FROM {REL}
   WHERE {sp(1)} = 'fix' AND a.id = {sp(2)}::bigint AND a.venue_id = {sp(3)} AND a.source_id = 'best-chef-awards' AND a.source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'fixed rows %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2, 'pair-fix:rename-urls-open-items-b9-2026-11-01 | 2 of the 5 rows held on Nov 1 (block 8) get the 2025 results page {U25}: 3453 stays on Flores Raras (El Poblet renamed Jan 2026, same address and owner; card Luis Valls "El Poblet (former workplace)"); 15690 moves Ensue ve_d6d7a07cee -> Fumée ve_38916224da (the one Shenzhen 2-knife card = Reina Chen, Fumée; Ensue is 1 knife = 15691) | 15727 held for the Hong Kong/Macau block | {BEN}')
  RETURNING id INTO v_lid;
  IF v_lid <> {B['led_max'] + 3} THEN RAISE EXCEPTION 'ledger id pair-fix %', v_lid; END IF;

  -- 4. award rows added
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT {sp(2)}, 'best-chef-awards', {sp(3)}::int, NULL, {sp(4)}, NULL, {sp(5)} FROM {REL} WHERE {sp(1)} = 'add';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards added %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2, 'award-add:rename-urls-open-items-b9-2026-11-01 | ve_f026dbec1c Guy Savoy (Paris) 2024 2-Knife ({U24}) and 2025 2-Knife ({U25}); chef card 19907 on both results pages, no row before (pairing check Nov 1) | {BEN}')
  RETURNING id INTO v_lid;
  IF v_lid <> {B['led_max'] + 4} THEN RAISE EXCEPTION 'ledger id award-add %', v_lid; END IF;

  -- post-checks
  IF (SELECT count(*) FROM venues) <> {A1['venues']} OR (SELECT count(*) FROM listings) <> {A1['listings']} OR (SELECT count(*) FROM blurbs) <> {A1['blurbs']} THEN RAISE EXCEPTION 'venues/listings/blurbs after'; END IF;
  IF (SELECT count(*) FROM awards) <> {A1['awards']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {A1['slugs']} OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {A1['noncanon']}
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> {A1['venues']} THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1)
    THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN {REL} ON {sp(1)} = 'ren' AND s.venue_id = {sp(3)} AND s.is_canonical AND s.city_slug = {sp(8)} AND s.slug = {sp(10)}) <> 8
    THEN RAISE EXCEPTION 'new canonical slugs after'; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id)) FROM venues v JOIN {REL} ON {sp(1)} = 'ren' AND v.id = {sp(3)}) <> '{NEW_MD5}'
    THEN RAISE EXCEPTION 'names after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> {A1['rb']} OR (SELECT count(*) FROM rename_rows) <> {A1['rr']} THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {A1['led_n']} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM awards WHERE id IN (3453, 15690) AND source_url = '{U25}' AND venue_id IN ('ve_53ec037b5f', 've_38916224da')) <> 2 THEN RAISE EXCEPTION 'fixed rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_f026dbec1c' AND source_id = 'best-chef-awards') <> 2 THEN RAISE EXCEPTION 'Guy Savoy rows after'; END IF;
  IF (SELECT count(*) FROM audit_log) <> {A1['aud_n']} OR (SELECT count(*) FROM audit_log WHERE id > {B['aud_max']}) <> 28 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN {REL} ON {sp(1)} = 'ren' AND a.row_pk = {sp(3)}
       WHERE a.id > {B['aud_max']} AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.old_row->>'name' = {sp(4)} AND a.new_row->>'name' = {sp(5)}
         AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key')) <> 8 THEN RAISE EXCEPTION 'audit venues (name, norm_key only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {B['aud_max']} AND table_name = 'slugs' AND action = 'UPDATE') <> 11
     OR (SELECT count(*) FROM audit_log WHERE id > {B['aud_max']} AND table_name = 'slugs' AND action = 'INSERT') <> 5 THEN RAISE EXCEPTION 'audit slugs'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {B['aud_max']} AND table_name = 'awards' AND action = 'UPDATE' AND row_pk = '3453'
         AND (old_row - 'source_url') = (new_row - 'source_url')) <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > {B['aud_max']} AND table_name = 'awards' AND action = 'UPDATE' AND row_pk = '15690'
         AND (old_row - 'source_url' - 'venue_id') = (new_row - 'source_url' - 'venue_id') AND new_row->>'venue_id' = 've_38916224da') <> 1
    THEN RAISE EXCEPTION 'audit award updates'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {B['aud_max']} AND table_name = 'awards' AND action = 'INSERT') <> 2 THEN RAISE EXCEPTION 'audit award inserts'; END IF;
END
$do$;
COMMIT;
"""

def file2(C, title, note):
    PF = md5('\n'.join(f'{d[0]}|{d[1]}|{d[2]}|{d[3]}|{d[7]}|{d[8]}' for d in sorted(DEL)))
    return PF, f"""-- {title}
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 9, file 2 of 2. DELETE: run in the Supabase SQL Editor.{note}
-- Ben: Nov 1 08:28 ET "All recommendations" (The Fellas and Fo'ao Vaperse Hotel: A = delete the row and the venue).
-- Sep 28 contamination rule (no provable pairing): each venue holds only one Best Chef 2025 1-Knife row that no Best Chef
-- card proves; the venue has no other award. Chengdu held-7 method: hand audit rows for city_label_source, then delete
-- city_label_source, awards, slugs, listings, venues (no price, address, geo, hours, photo, blurb rows; read Nov 1).
-- Old URLs /shanghai/the-fellas and /guangzhou/fo-ao-vaperse-hotel give a 404 after this; no redirect.
-- cities.venues_count: Shanghai {DEL[0][5]} -> {DEL[0][6]}, Guangzhou {DEL[1][5]} -> {DEL[1][6]} (stored count = view city_venue_counts).
-- Relay docs/open-items-b9-build/relay-file2.txt sha256 {S2}. Plan fingerprint {PF}.
-- Expected: venues {C['venues']} -> {C['venues'] - 2} (active {C['active']} -> {C['active'] - 2}), awards {C['awards']} -> {C['awards'] - 2}, slugs {C['slugs']} -> {C['slugs'] - 2},
--   listings {C['listings']} -> {C['listings'] - 2}, city_label_source {C['cls']} -> {C['cls'] - 4}, venues_count sum {C['vc_sum']} -> {C['vc_sum'] - 2},
--   ledger {C['led_max']} -> {C['led_max'] + 1}, audit {C['aud_max']} -> {C['aud_max'] + 14} (+14: city_label_source DELETE 4 (hand), awards 2, slugs 2, listings 2, venues 2 DELETE, cities UPDATE 2).
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel${relay2}$rel$, E'\\r', '');
  n int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{S2}' THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> {C['venues']} OR (SELECT count(*) FROM venues WHERE status = 'active') <> {C['active']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {C['awards']} OR (SELECT count(*) FROM slugs) <> {C['slugs']} OR (SELECT count(*) FROM listings) <> {C['listings']}
     OR (SELECT count(*) FROM city_label_source) <> {C['cls']} THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {C['led_n']} OR (SELECT max(id) FROM source_capture_ledger) <> {C['led_max']} THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> {C['aud_n']} OR (SELECT max(id) FROM audit_log) <> {C['aud_max']} THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {C['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;

  -- plan fingerprint, read live: venue|name|award|category|canonical path|city label ids
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||a.id||'|'||a.category||'|'||s.city_slug||'/'||s.slug||'|'||
           (SELECT string_agg(c.id::text, ',' ORDER BY c.id) FROM city_label_source c WHERE c.venue_id = v.id), E'\\n' ORDER BY v.id))
    INTO v_txt
    FROM venues v JOIN {REL} ON {sp(1)} = 'del' AND v.id = {sp(2)} AND v.status = 'active'
    JOIN awards a ON a.venue_id = v.id JOIN slugs s ON s.venue_id = v.id AND s.is_canonical;
  IF v_txt IS DISTINCT FROM '{PF}' THEN RAISE EXCEPTION 'plan fingerprint %', v_txt; END IF;
  -- each venue: exactly 1 award, 2 labels, 1 slug, 1 listing, nothing in the other child tables
  IF (SELECT count(*) FROM awards a JOIN {REL} ON {sp(1)} = 'del' AND a.venue_id = {sp(2)}) <> 2
     OR (SELECT count(*) FROM city_label_source c JOIN {REL} ON {sp(1)} = 'del' AND c.venue_id = {sp(2)}) <> 4
     OR (SELECT count(*) FROM slugs s JOIN {REL} ON {sp(1)} = 'del' AND s.venue_id = {sp(2)}) <> 2
     OR (SELECT count(*) FROM listings t JOIN {REL} ON {sp(1)} = 'del' AND t.venue_id = {sp(2)}) <> 2 THEN RAISE EXCEPTION 'child rows'; END IF;
  IF EXISTS (SELECT 1 FROM {REL} WHERE {sp(1)} = 'del' AND (
        EXISTS (SELECT 1 FROM addresses x WHERE x.venue_id = {sp(2)}) OR EXISTS (SELECT 1 FROM blurbs x WHERE x.venue_id = {sp(2)})
     OR EXISTS (SELECT 1 FROM geo x WHERE x.venue_id = {sp(2)}) OR EXISTS (SELECT 1 FROM hours x WHERE x.venue_id = {sp(2)})
     OR EXISTS (SELECT 1 FROM photo_refs x WHERE x.venue_id = {sp(2)}) OR EXISTS (SELECT 1 FROM price x WHERE x.venue_id = {sp(2)})
     OR EXISTS (SELECT 1 FROM rename_rows x WHERE x.venue_id = {sp(2)}))) THEN RAISE EXCEPTION 'other child rows'; END IF;
  IF (SELECT count(*) FROM cities c JOIN {REL} ON {sp(1)} = 'del' AND c.id = {sp(6)} AND c.venues_count = {sp(7)}::int) <> 2 THEN RAISE EXCEPTION 'city counts before'; END IF;

  -- hand audit rows (no trigger on city_label_source), then the deletes
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c JOIN {REL} ON {sp(1)} = 'del' AND c.venue_id = {sp(2)} ORDER BY c.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'hand audit rows %', n; END IF;
  DELETE FROM city_label_source c USING {REL} WHERE {sp(1)} = 'del' AND c.venue_id = {sp(2)};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'labels deleted %', n; END IF;
  DELETE FROM awards a USING {REL} WHERE {sp(1)} = 'del' AND a.venue_id = {sp(2)} AND a.id = {sp(4)}::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards deleted %', n; END IF;
  DELETE FROM slugs s USING {REL} WHERE {sp(1)} = 'del' AND s.venue_id = {sp(2)};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'slugs deleted %', n; END IF;
  DELETE FROM listings t USING {REL} WHERE {sp(1)} = 'del' AND t.venue_id = {sp(2)};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'listings deleted %', n; END IF;
  DELETE FROM venues v USING {REL} WHERE {sp(1)} = 'del' AND v.id = {sp(2)};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'venues deleted %', n; END IF;
  UPDATE cities c SET venues_count = {sp(8)}::int FROM {REL} WHERE {sp(1)} = 'del' AND c.id = {sp(6)} AND c.venues_count = {sp(7)}::int;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'cities updated %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2, 'cleanup:cleanup-best-chef-b9-2026-11-01 | contamination rule (Ben, Sep 28): 2 legacy Best Chef 2025 1-Knife rows with no provable pairing, deleted with their venues | 16190 The Fellas ve_42dfc9b029 (Shanghai, Italian rooftop bar), 15997 Fo''ao Vaperse Hotel ve_8caa39d442 (Guangzhou, a hotel); no Best Chef 2024/2025 card or special award names either (read Nov 1) | old URLs 404, no redirect | {BEN}')
  RETURNING id INTO v_lid;
  IF v_lid <> {C['led_max'] + 1} THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;

  -- post-checks
  IF EXISTS (SELECT 1 FROM {REL} WHERE {sp(1)} = 'del' AND (
        EXISTS (SELECT 1 FROM venues x WHERE x.id = {sp(2)}) OR EXISTS (SELECT 1 FROM awards x WHERE x.venue_id = {sp(2)})
     OR EXISTS (SELECT 1 FROM slugs x WHERE x.venue_id = {sp(2)}) OR EXISTS (SELECT 1 FROM listings x WHERE x.venue_id = {sp(2)})
     OR EXISTS (SELECT 1 FROM city_label_source x WHERE x.venue_id = {sp(2)}))) THEN RAISE EXCEPTION 'rows remain'; END IF;
  IF (SELECT count(*) FROM venues) <> {C['venues'] - 2} OR (SELECT count(*) FROM venues WHERE status = 'active') <> {C['active'] - 2} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {C['awards'] - 2} OR (SELECT count(*) FROM slugs) <> {C['slugs'] - 2} OR (SELECT count(*) FROM listings) <> {C['listings'] - 2}
     OR (SELECT count(*) FROM city_label_source) <> {C['cls'] - 4} THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {C['vc_sum'] - 2} THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) <> 1) THEN RAISE EXCEPTION 'canonical slugs after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C['aud_max']}) <> 14 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C['aud_max']} AND action = 'DELETE' AND table_name = 'city_label_source') <> 4
     OR (SELECT count(*) FROM audit_log WHERE id > {C['aud_max']} AND action = 'DELETE' AND table_name IN ('awards', 'slugs', 'listings', 'venues')) <> 8
     OR (SELECT count(*) FROM audit_log WHERE id > {C['aud_max']} AND action = 'UPDATE' AND table_name = 'cities'
           AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 2 THEN RAISE EXCEPTION 'audit rows by table'; END IF;
END
$do$;
COMMIT;
"""

PF, f2 = file2(A1, 'cleanup-best-chef-b9-2026-11-01.sql', '')
_, f2test = file2(B, 'cleanup-test-current-counts.sql (PRE-CHECK COPY, NOT FOR RUNNING)',
                  '\n-- Test copy: counts of Nov 1 13:28 UTC (before file 1). Dry run only.')
open('../rename-urls-open-items-b9-2026-11-01.sql', 'w', encoding='utf-8').write(file1)
open('../cleanup-best-chef-b9-2026-11-01.sql', 'w', encoding='utf-8').write(f2)
open('cleanup-test-current-counts.sql', 'w', encoding='utf-8').write(f2test)
for p, s in (('file1', file1), ('file2', f2), ('test', f2test)):
    print(p, 'sha256', sha(s), 'lines', s.count('\n'))
print('relay1', S1, 'relay2', S2, 'new names md5', NEW_MD5, 'plan fp', PF)
