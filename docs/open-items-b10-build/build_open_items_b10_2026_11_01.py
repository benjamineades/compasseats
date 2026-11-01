#!/usr/bin/env python3
"""Open items block 10 (Nov 1 2026): untangle the 8 1/2 Otto e Mezzo Bombana pair (Hong Kong / Macau).

Ben, Nov 1 09:12 ET: "All recommendations are ok for D1-D5. Chrome ok."
  D1 = A  Hong Kong ve_e17d78f314 closed -> active (card Three Stars 2026, no closure note)
  D2 = A  both branches named "8 1/2 Otto e Mezzo Bombana" (R2 site title form that the card also uses; R3 lowercase "e")
  D3 = A  new canonical slugs hong-kong/ and macau/8-1-2-otto-e-mezzo-bombana; old hash slugs stay non-canonical
  D4 = A  award rows split by publisher (10 moves here, 15736 delete in file 2)
  D5 = A  Michelin 2026 rows for both venues come with the item 7 load

Writes:
  docs/open-items-b10-build/relay-file1.txt, relay-file2.txt
  docs/pair-8-otto-e-mezzo-b10-2026-11-01.sql          (file 1, INSERT/UPDATE only: Write connector)
  docs/cleanup-8-otto-e-mezzo-b10-2026-11-01.sql       (file 2, DELETE: SQL Editor)
Run: python3 -I docs/open-items-b10-build/build_open_items_b10_2026_11_01.py [--test]
  --test writes file 1 with live counts for the read-only pre-check (same file, different header line only).
"""
import hashlib, os, re, sys, unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
DOCS = os.path.dirname(HERE)
TEST = '--test' in sys.argv

def md5(s): return hashlib.md5(s.encode('utf-8')).hexdigest()
def sha(s): return hashlib.sha256(s.encode('utf-8')).hexdigest()

HK, MO = 've_e17d78f314', 've_6f0b34cc23'
HK_CARD = 'https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/8%C2%BD-otto-e-mezzo-bombana'
MO_CARD = 'https://guide.michelin.com/en/macau-region/macau/restaurant/8-1-2-otto-e-mezzo-bombana'
NEW = '8 1/2 Otto e Mezzo Bombana'
BEN = 'Ben Nov 1 09:12 ET "All recommendations are ok for D1-D5"'

# ---------- fresh read Nov 1 14:16:19 UTC ----------
LIVE = {HK: ('8 1/2 Otto E Mezzo Bombana', 'closed', 'ci_1b1537ad28'),
        MO: ('8½ Otto e Mezzo BOMBANA', 'active', 'ci_9690a92f29')}
LIVE_VFP = '20b7894ddb068a7ae020339c30db587f'   # md5 id|name|status|city_id by id
LIVE_AFP = '93282d409b3ba11a5334dacec6fece65'   # md5 id|venue|source|year|rank|category|url by id, 18 rows
assert md5('\n'.join(f'{k}|{v[0]}|{v[1]}|{v[2]}' for k, v in sorted(LIVE.items()))) == LIVE_VFP

def slugify(n):
    s = unicodedata.normalize('NFKD', n)
    s = ''.join(ch for ch in s if not unicodedata.combining(ch)).lower()
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
NEWSLUG = slugify(NEW)
assert NEWSLUG == '8-1-2-otto-e-mezzo-bombana'

REN = [
    ('ren', '1', HK, LIVE[HK][0], NEW, 'michelin', HK_CARD, 'hong-kong', 'hong-kong-3bt2d8', NEWSLUG, 'insert',
     'card h1 "8 1/2 Otto e Mezzo - Bombana" (Three Stars 2026, Alexandra House); site ottoemezzobombana.com title "8 1/2 Otto E Mezzo Bombana", body "8½ Otto e Mezzo BOMBANA"; rule R2 (site title form the card also uses) + R3 (capitals: body writes "Otto e Mezzo"); same name as the Shanghai branch ve_524cd4f57d'),
    ('ren', '2', MO, LIVE[MO][0], NEW, 'michelin', MO_CARD, 'macau', 'macau-uc7ud0', NEWSLUG, 'insert',
     'card h1 "8 1/2 Otto e Mezzo - Bombana" (One Star 2026, Galaxy Cotai); same brand as Hong Kong; rule R2 + R3; one name for the 3 branches (Ben D2 = A)'),
]
STATUS = [('status', HK, LIVE[HK][0], 'ci_1b1537ad28', '261', '262',
           f'card {HK_CARD} Three Stars, 2026 MICHELIN Guide Hong Kong, Shop 202 2F Alexandra House 18 Chater Road, no closure note (read Nov 1); set closed by the Aug 14 sheet load with no closure evidence')]

A50 = 'asia-50-best-restaurants'
MV = [  # award id, from, to, source, year, rank, category, url, note
    ('15727', MO, HK, 'best-chef-awards', '2025', '', '2-Knife', 'https://thebestchefawards.com/events-results/?id=2376',
     'chef card Umberto Bombana: "8 1/2 Otto e Mezzo – Bombana", Hong Kong, China, two knives; held row from block 9'),
    ('15728', MO, HK, 'oad', '2025', '91', 'No. 91', 'https://www.oadguides.com/lists/asia/top-restaurants/2025',
     'OAD Top Restaurants in Asia 2025 No. 91 "8 1/2 Otto E Mezzo Bombana", Hong Kong, Umberto Bombana (read in Chrome Nov 1)'),
    ('15729', MO, HK, 'asia-50-best-bars', '2021', '65', 'No. 65', 'https://www.theworlds50best.com/stories/News/asias-50-best-bars-2021-51-100-list-in-pictures.html',
     'Asia\'s 50 Best Bars 2021 51-100: No. 65 "8 1/2 Otto e Mezzo Bombana", Hong Kong (the 50 Best lists the restaurant as a bar too)'),
    ('15730', MO, HK, A50, '2019', '12', 'No. 12', 'https://www.the50.com/stories/News/asias-50-best-restaurants-2019-list-in-pictures.html',
     'Asia\'s 50 Best Restaurants 2019 No. 12, Hong Kong, China (also Art of Hospitality Award 2019)'),
    ('15731', MO, HK, A50, '2021', '33', 'No. 33', 'https://www.the50.com/stories/News/asias-50-best-restaurants-2021-the-list-in-pictures.html',
     'Asia\'s 50 Best Restaurants 2021 No. 33, Hong Kong (also The 50 Discovery page, Hong Kong)'),
    ('15732', MO, HK, A50, '2022', '48', 'No. 48', 'https://www.the50.com/stories/News/asias-50-best-restaurants-2022-list-in-pictures.html',
     'Asia\'s 50 Best Restaurants 2022 No. 48, Hong Kong'),
    ('15733', MO, HK, A50, '2023', '70', 'No. 70', 'https://www.theworlds50best.com/stories/News/asia-50-best-restaurants-2023-51-100-list.html',
     'Asia\'s 50 Best Restaurants 2023 51-100: No. 70, Hong Kong'),
    ('15734', MO, HK, A50, '2025', '94', 'No. 94', 'https://www.the50.com/stories/News/asias-50-best-restaurants-2025-the-51-100-list.html',
     'Asia\'s 50 Best Restaurants 2025 51-100: No. 94 "8 1/2 Otto e Mezzo Bombana – RE-ENTRY", Hong Kong'),
    ('15735', MO, HK, 'la-liste', '2026', '', '95/100', 'https://www.laliste.com/places/8-12-otto-e-mezzo-bombana-hongkong-cn',
     'La Liste Hong Kong place page: 95.0 Top 1000 Restaurants 2026, Shop 202, 18 Chater Rd (read in Chrome Nov 1)'),
    ('20742', HK, MO, 'la-liste', '2026', '', '85.5/100', 'https://www.laliste.com/places/8-otto-e-mezzo-bombana-macau-mo',
     'La Liste Macau place page: 85.5 Top 1000 Restaurants 2026, 1/F 1031 Galaxy Resort Macau'),
]
DEL = [('del', '15736', MO, 'michelin', '2025', 'Three Stars',
        'copy of 391 on Hong Kong: Michelin 2025 article (Mar 13, 2025) names 8 1/2 Otto e Mezzo - Bombana Three Stars in Hong Kong only; Macau card is One Star (row 6238 stays)')]

rel1 = '\n'.join('|'.join(r) for r in REN + STATUS) + '\n' + '\n'.join('mv|' + '|'.join(r) for r in MV)
rel2 = '\n'.join('|'.join(r) for r in DEL)
for t in (rel1, rel2):
    assert '\r' not in t and '$rel$' not in t
    for line in t.split('\n'):
        assert line.count('|') == {'ren': 11, 'status': 6, 'mv': 9, 'del': 6}[line.split('|')[0]], line
open(os.path.join(HERE, 'relay-file1.txt'), 'w', encoding='utf-8', newline='\n').write(rel1)
open(os.path.join(HERE, 'relay-file2.txt'), 'w', encoding='utf-8', newline='\n').write(rel2)
R1, R2 = sha(rel1), sha(rel2)
NEW_NAMES_MD5 = md5('\n'.join(f'{k}|{NEW}' for k in sorted([HK, MO])))
MV_FP = md5('\n'.join(f'{m[0]}|{m[1]}|{m[3]}|{m[4]}|{m[5]}|{m[6]}' for m in sorted(MV, key=lambda m: int(m[0]))))
AFTER_FP = md5('\n'.join(f'{m[0]}|{m[2]}|{m[7]}' for m in sorted(MV, key=lambda m: int(m[0]))))

# ---------- counts (live read Nov 1 14:00:47 / 14:16:19 UTC) ----------
C0 = dict(venues=11300, active=10934, closed=366, awards=23363, slugs=12948, noncanon=1648, listings=11300, blurbs=142,
          rb=19, rr=1209, led_n=141, led_max=189, aud_n=115490, aud_max=120802, vc_sum=10934, hk_vc=261)
# file 1: venues UPDATE 3 (2 names, 1 status), cities UPDATE 1, slugs UPDATE 2 + INSERT 2, awards UPDATE 10 = 18 audit rows; ledger 190-195
C1 = dict(C0, active=10935, closed=365, slugs=12950, noncanon=1650, rb=20, rr=1211, led_n=147, led_max=195,
          aud_n=C0['aud_n'] + 18, aud_max=C0['aud_max'] + 18, vc_sum=10935, hk_vc=262)
# file 2: awards DELETE 1 = 1 audit row; ledger 196
C2 = dict(C1, awards=23362, led_n=148, led_max=196, aud_n=C1['aud_n'] + 1, aud_max=C1['aud_max'] + 1)
L = dict(name=190, a50=191, bars=192, chef=193, oad=194, liste=195, cleanup=196)
SPLIT = "regexp_split_to_table(rel, E'\\n') l"
def p(i): return f"split_part(l, '|', {i})"

def gates_before(c, seq_led, seq_aud):
    return f"""  IF (SELECT count(*) FROM venues) <> {c['venues']} OR (SELECT count(*) FROM venues WHERE status = 'active') <> {c['active']}
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> {c['closed']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {c['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {c['slugs']} OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {c['noncanon']} THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> {c['listings']} OR (SELECT count(*) FROM blurbs) <> {c['blurbs']} THEN RAISE EXCEPTION 'listings/blurbs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> {c['rb']} OR (SELECT count(*) FROM rename_rows) <> {c['rr']} THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {c['led_n']} OR (SELECT max(id) FROM source_capture_ledger) <> {c['led_max']} THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM audit_log) <> {c['aud_n']} OR (SELECT max(id) FROM audit_log) <> {c['aud_max']} THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'source_capture_ledger_id_seq') <> {seq_led}
     OR (SELECT last_value FROM pg_sequences WHERE schemaname = 'public' AND sequencename = 'audit_log_id_seq') <> {seq_aud} THEN RAISE EXCEPTION 'id counters before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {c['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;"""

def ledger(pub, field, items, job, lid):
    job = job.replace("'", "''")
    return f"""  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('{pub}', '{field}', {items}, '{job}')
  RETURNING id INTO v_lid;
  IF v_lid <> {lid} THEN RAISE EXCEPTION 'ledger id {pub} {field} %', v_lid; END IF;"""

F1 = 'pair-8-otto-e-mezzo-b10-2026-11-01'
F2 = 'cleanup-8-otto-e-mezzo-b10-2026-11-01'
mvids = ','.join(m[0] for m in MV)
def mvjob(kind, ids):
    rows = [m for m in MV if m[0] in ids]
    return f"pair-fix:{F1} | 8 1/2 Otto e Mezzo Bombana pair split by publisher (open item 1): " + '; '.join(
        f"{m[0]} {m[4]} {m[6]} {'Macau ve_6f0b34cc23 -> Hong Kong ve_e17d78f314' if m[2] == HK else 'Hong Kong ve_e17d78f314 -> Macau ve_6f0b34cc23'} ({m[8]}) url {m[7]}" for m in rows) + f' | {BEN}'

C = C0
hdr = ('-- TEST COPY with live counts: send through the Read connector only. Not for a real run.\n' if TEST else '')
sql1 = f"""{hdr}-- {F1}.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 10, file 1 of 2. INSERT/UPDATE only: Write connector.
-- {BEN} + "Chrome ok". Open item 1: the 8 1/2 Otto e Mezzo Bombana pair (Hong Kong ve_e17d78f314, Macau ve_6f0b34cc23).
-- 1. Status: Hong Kong closed -> active (D1; card Three Stars 2026, no closure note). cities.venues_count hong-kong 261 -> 262.
-- 2. Rename batch rename-open-items-b10-2026-11-01 (D2; rules R2 + R3):
--    ve_e17d78f314 '8 1/2 Otto E Mezzo Bombana' -> '{NEW}'
--    ve_6f0b34cc23 '8½ Otto e Mezzo BOMBANA' -> '{NEW}'
-- 3. Slugs (D3): hong-kong/hong-kong-3bt2d8 and macau/macau-uc7ud0 -> non-canonical; insert hong-kong/{NEWSLUG} and macau/{NEWSLUG}.
-- 4. Awards (D4), 10 rows moved by publisher, each with the URL that proves the branch:
--    to Hong Kong: 15727 Best Chef 2025 2-Knife, 15728 OAD 2025 No. 91, 15729 Asia's 50 Best Bars 2021 No. 65,
--      15730-15734 Asia's 50 Best Restaurants 2019 No. 12 / 2021 No. 33 / 2022 No. 48 / 2023 No. 70 / 2025 No. 94, 15735 La Liste 2026 95/100;
--    to Macau: 20742 La Liste 2026 85.5/100.
-- Not in this file: 15736 (Michelin 2025 Three Stars on Macau, copy of 391) = file 2 (DELETE, SQL Editor). Forbes 6234-6237 and Michelin 6238 stay on Macau.
-- Relay docs/open-items-b10-build/relay-file1.txt sha256 {R1}.
-- Expected: closed 366 -> 365 (active 10934 -> 10935), venues_count sum 10934 -> 10935, rename_batches 19 -> 20, rename_rows 1209 -> 1211,
--   slugs 12948 -> 12950 (non-canonical 1648 -> 1650), awards 23363 (no change), ledger last id 189 -> 195 (ids 190-195),
--   audit last id 120802 -> 120820 (+18: venues UPDATE 3, cities UPDATE 1, slugs UPDATE 2, slugs INSERT 2, awards UPDATE 10).
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel${rel1}$rel$, E'\\r', '');
  bid bigint; n int; x int; v_lid bigint; v_txt text;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{R1}' THEN RAISE EXCEPTION 'relay hash'; END IF;
{gates_before(C0, C0['led_max'], C0['aud_max'])}
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key = 'rename-open-items-b10-2026-11-01') THEN RAISE EXCEPTION 'batch key used'; END IF;

  -- pair gates (fresh read Nov 1 14:16 UTC)
  IF (SELECT md5(string_agg(id||'|'||name||'|'||status||'|'||city_id, E'\\n' ORDER BY id)) FROM venues WHERE id IN ('{HK}', '{MO}')) <> '{LIVE_VFP}'
    THEN RAISE EXCEPTION 'pair venues differ from the Nov 1 read'; END IF;
  IF (SELECT md5(string_agg(id||'|'||venue_id||'|'||source_id||'|'||year||'|'||coalesce(rank::text, '')||'|'||category||'|'||coalesce(source_url, ''), E'\\n' ORDER BY id))
        FROM awards WHERE venue_id IN ('{HK}', '{MO}')) <> '{LIVE_AFP}' THEN RAISE EXCEPTION 'pair awards differ from the Nov 1 read'; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||coalesce(a.rank::text, '')||'|'||a.category, E'\\n' ORDER BY a.id))
        FROM awards a JOIN {SPLIT} ON {p(1)} = 'mv' AND a.id = {p(2)}::bigint AND a.venue_id = {p(3)} AND a.source_id = {p(5)} AND a.year = {p(6)}::int
         AND coalesce(a.rank::text, '') = {p(7)} AND a.category = {p(8)} AND a.source_url IS NULL) <> '{MV_FP}' THEN RAISE EXCEPTION 'move rows'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN {SPLIT} ON {p(1)} = 'mv' AND a.venue_id = {p(4)} AND a.source_id = {p(5)} AND a.year = {p(6)}::int
         AND a.rank IS NOT DISTINCT FROM nullif({p(7)}, '')::int AND a.category = {p(8)} AND a.distinction IS NULL) THEN RAISE EXCEPTION 'target already holds the row'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id IN ('{HK}', '{MO}')) THEN RAISE EXCEPTION 'earlier rename_rows'; END IF;
  IF (SELECT count(*) FROM {SPLIT} WHERE {p(1)} = 'ren'
        AND trim(both '-' from regexp_replace(lower(f_unaccent({p(5)})), '[^a-z0-9]+', '-', 'g')) = {p(10)}) <> 2 THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN {SPLIT} ON {p(1)} = 'ren' AND s.venue_id = {p(3)} AND s.property_id = 'eats'
        AND s.is_canonical AND s.city_slug = {p(8)} AND s.slug = {p(9)}) <> 2 THEN RAISE EXCEPTION 'old canonical slugs'; END IF;
  IF EXISTS (SELECT 1 FROM slugs s JOIN {SPLIT} ON {p(1)} = 'ren' AND s.city_slug = {p(8)} AND s.slug = {p(10)}) THEN RAISE EXCEPTION 'new slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM redirects d JOIN {SPLIT} ON {p(1)} = 'ren'
        AND d.from_path IN ('/'||{p(8)}||'/'||{p(10)}, '/venue/'||{p(8)}||'/'||{p(10)})) THEN RAISE EXCEPTION 'new path in redirects'; END IF;
  WITH batch AS (SELECT {p(3)} AS venue_id, {p(5)} AS new_name FROM {SPLIT} WHERE {p(1)} = 'ren'),
       scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
       fin   AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
                   FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id)
  SELECT count(*) INTO x FROM fin a JOIN batch ON batch.venue_id = a.id
    JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id AND norm_key(o.name) = norm_key(a.name);
  IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key collisions %', x; END IF;
  IF (SELECT count(*) FROM cities c JOIN {SPLIT} ON {p(1)} = 'status' AND c.id = {p(4)} AND c.venues_count = {p(5)}::int) <> 1 THEN RAISE EXCEPTION 'city count before'; END IF;
  IF (SELECT count(*) FROM award_sources WHERE slug IN ('michelin', 'best-chef-awards', 'oad', 'asia-50-best-bars', '{A50}', 'la-liste')) <> 6 THEN RAISE EXCEPTION 'sources'; END IF;

  -- 1. status (status only; block 7 method, no ledger row)
  UPDATE venues v SET status = 'active' FROM {SPLIT} WHERE {p(1)} = 'status' AND v.id = {p(2)} AND v.name = {p(3)} AND v.status = 'closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status updated %', n; END IF;
  UPDATE cities c SET venues_count = {p(6)}::int FROM {SPLIT} WHERE {p(1)} = 'status' AND c.id = {p(4)} AND c.venues_count = {p(5)}::int;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city count updated %', n; END IF;

  -- 2. rename batch
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-open-items-b10-2026-11-01', 'staged', 'Open items block 10 (Nov 1): the 8 1/2 Otto e Mezzo Bombana pair, Hong Kong and Macau get one name (rules R2 + R3). {BEN.replace(chr(39), chr(39)*2)}. Gated SQL file, Write connector; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, {p(2)}::int, {p(3)}, {p(4)}, {p(5)}, {p(6)}, {p(7)}, 'rename',
         jsonb_build_object('note', {p(12)} || ' | {BEN.replace(chr(39), chr(39)*2)}', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', {p(8)}, 'slug', {p(9)})
    FROM {SPLIT} JOIN venues v ON v.id = {p(3)} WHERE {p(1)} = 'ren';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = {p(5)} FROM {SPLIT} WHERE {p(1)} = 'ren' AND v.id = {p(3)} AND v.name = {p(4)} AND v.status = 'active';
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 2 THEN RAISE EXCEPTION 'venues renamed %', n; END IF;
{ledger('michelin', 'name', 2, f'rename-apply:rename-open-items-b10-2026-11-01 | gated SQL file docs/{F1}.sql (Write connector) | Hong Kong ve_e17d78f314 "8 1/2 Otto E Mezzo Bombana" and Macau ve_6f0b34cc23 "8½ Otto e Mezzo BOMBANA" -> "{NEW}": Michelin 2026 cards (h1 "8 1/2 Otto e Mezzo - Bombana") and ottoemezzobombana.com title, rules R2 + R3; Hong Kong also set active (card Three Stars 2026, no closure note) | {BEN}', L['name'])}
  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status'; END IF;

  -- 3. slugs
  UPDATE slugs s SET is_canonical = false FROM {SPLIT}
   WHERE {p(1)} = 'ren' AND s.property_id = 'eats' AND s.venue_id = {p(3)} AND s.city_slug = {p(8)} AND s.slug = {p(9)} AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'old canonical updated %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', {p(8)}, {p(10)}, {p(3)}, true FROM {SPLIT} WHERE {p(1)} = 'ren' AND {p(11)} = 'insert';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'new slugs %', n; END IF;

  -- 4. award moves with URL
  UPDATE awards a SET venue_id = {p(4)}, source_url = {p(9)} FROM {SPLIT}
   WHERE {p(1)} = 'mv' AND a.id = {p(2)}::bigint AND a.venue_id = {p(3)} AND a.source_id = {p(5)} AND a.source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 10 THEN RAISE EXCEPTION 'awards moved %', n; END IF;
{ledger(A50, 'award', 5, mvjob('a50', {'15730','15731','15732','15733','15734'}), L['a50'])}
{ledger('asia-50-best-bars', 'award', 1, mvjob('bars', {'15729'}), L['bars'])}
{ledger('best-chef-awards', 'award', 1, mvjob('chef', {'15727'}), L['chef'])}
{ledger('oad', 'award', 1, mvjob('oad', {'15728'}), L['oad'])}
{ledger('la-liste', 'award', 2, mvjob('liste', {'15735','20742'}), L['liste'])}

  -- post-checks
  IF (SELECT count(*) FROM venues) <> {C1['venues']} OR (SELECT count(*) FROM venues WHERE status = 'active') <> {C1['active']}
     OR (SELECT count(*) FROM venues WHERE status = 'closed') <> {C1['closed']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> {C1['awards']} OR (SELECT count(*) FROM listings) <> {C1['listings']} OR (SELECT count(*) FROM blurbs) <> {C1['blurbs']} THEN RAISE EXCEPTION 'awards/listings/blurbs after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {C1['slugs']} OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {C1['noncanon']}
     OR (SELECT count(*) FROM slugs WHERE is_canonical) <> {C1['venues']} THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1)
    THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM slugs s JOIN {SPLIT} ON {p(1)} = 'ren' AND s.venue_id = {p(3)} AND s.is_canonical AND s.city_slug = {p(8)} AND s.slug = {p(10)}) <> 2
    THEN RAISE EXCEPTION 'new canonical slugs after'; END IF;
  IF (SELECT md5(string_agg(id||'|'||name, E'\\n' ORDER BY id)) FROM venues WHERE id IN ('{HK}', '{MO}') AND status = 'active') <> '{NEW_NAMES_MD5}'
    THEN RAISE EXCEPTION 'names after'; END IF;
  IF (SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_url, E'\\n' ORDER BY a.id)) FROM awards a JOIN {SPLIT} ON {p(1)} = 'mv' AND a.id = {p(2)}::bigint) <> '{AFTER_FP}'
    THEN RAISE EXCEPTION 'moved rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = '{HK}') <> 11 OR (SELECT count(*) FROM awards WHERE venue_id = '{MO}') <> 7 THEN RAISE EXCEPTION 'awards per venue after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> {C1['rb']} OR (SELECT count(*) FROM rename_rows) <> {C1['rr']} THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {C1['led_n']} OR (SELECT max(id) FROM source_capture_ledger) <> {C1['led_max']} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {C1['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF (SELECT count(*) FROM audit_log) <> {C1['aud_n']} OR (SELECT count(*) FROM audit_log WHERE id > {C0['aud_max']}) <> 18 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud_max']} AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = '{HK}'
         AND (old_row - 'status') = (new_row - 'status') AND old_row->>'status' = 'closed' AND new_row->>'status' = 'active') <> 1
    THEN RAISE EXCEPTION 'audit venues (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN {SPLIT} ON {p(1)} = 'ren' AND a.row_pk = {p(3)}
       WHERE a.id > {C0['aud_max']} AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.old_row->>'name' = {p(4)} AND a.new_row->>'name' = {p(5)}
         AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key')) <> 2 THEN RAISE EXCEPTION 'audit venues (name, norm_key only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud_max']} AND table_name = 'cities' AND action = 'UPDATE'
         AND (old_row - 'venues_count') = (new_row - 'venues_count')) <> 1 THEN RAISE EXCEPTION 'audit cities (venues_count only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {C0['aud_max']} AND table_name = 'slugs' AND action = 'UPDATE') <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > {C0['aud_max']} AND table_name = 'slugs' AND action = 'INSERT') <> 2 THEN RAISE EXCEPTION 'audit slugs'; END IF;
  IF (SELECT count(*) FROM audit_log a JOIN {SPLIT} ON {p(1)} = 'mv' AND a.row_pk = {p(2)}
       WHERE a.id > {C0['aud_max']} AND a.table_name = 'awards' AND a.action = 'UPDATE'
         AND (a.old_row - 'venue_id' - 'source_url') = (a.new_row - 'venue_id' - 'source_url') AND a.new_row->>'venue_id' = {p(4)}) <> 10
    THEN RAISE EXCEPTION 'audit award moves'; END IF;
END
$do$;
COMMIT;
"""

F1RUN = f"""  IF (SELECT count(*) FROM venues WHERE id = '{HK}' AND name = '{NEW}' AND status = 'active') <> 1
     OR (SELECT count(*) FROM venues WHERE id = '{MO}' AND name = '{NEW}' AND status = 'active') <> 1 THEN RAISE EXCEPTION 'file 1 not run'; END IF;"""
sql2 = f"""{hdr}-- {F2}.sql
-- CompassEats, Nov 1 2026 (Atlanta). Open items block 10, file 2 of 2. DELETE: run in the Supabase SQL Editor.
-- {BEN} (D4 = A). Run after file 1.
-- Award 15736 (michelin 2025 Three Stars on Macau ve_6f0b34cc23, no URL) is a copy of 391 (michelin 2025 Three Stars on Hong Kong
-- ve_e17d78f314): the Michelin 2025 article (Mar 13, 2025) names 8 1/2 Otto e Mezzo - Bombana Three Stars in Hong Kong only;
-- the Macau card is One Star (6238 stays). Trigger audit row only (no hand rows needed).
-- Relay docs/open-items-b10-build/relay-file2.txt sha256 {R2}.
-- Expected: awards 23363 -> 23362, ledger last id 195 -> 196, audit last id 120820 -> 120821 (+1: awards DELETE 1).
BEGIN;
DO $do$
DECLARE
  rel text := replace($rel${rel2}$rel$, E'\\r', '');
  n int; v_lid bigint;
BEGIN
  IF encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{R2}' THEN RAISE EXCEPTION 'relay hash'; END IF;
{gates_before(C0, C0['led_max'], C0['aud_max']) if TEST else gates_before(C1, C1['led_max'], C1['aud_max'])}
{'' if TEST else F1RUN}
  IF (SELECT count(*) FROM awards a JOIN {SPLIT} ON {p(1)} = 'del' AND a.id = {p(2)}::bigint AND a.venue_id = {p(3)} AND a.source_id = {p(4)}
        AND a.year = {p(5)}::int AND a.category = {p(6)} AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url IS NULL) <> 1 THEN RAISE EXCEPTION 'row 15736'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 391 AND venue_id = '{HK}' AND source_id = 'michelin' AND year = 2025 AND category = 'Three Stars') <> 1 THEN RAISE EXCEPTION 'row 391'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 6238 AND venue_id = '{MO}' AND source_id = 'michelin' AND year = 2025 AND category = 'One Star') <> 1 THEN RAISE EXCEPTION 'row 6238'; END IF;

  DELETE FROM awards a USING {SPLIT} WHERE {p(1)} = 'del' AND a.id = {p(2)}::bigint AND a.venue_id = {p(3)};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'awards deleted %', n; END IF;
{ledger('michelin', 'award', 1, f'cleanup:{F2} | 15736 michelin 2025 Three Stars on Macau ve_6f0b34cc23 deleted: copy of 391 on Hong Kong ve_e17d78f314; Michelin 2025 article https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2025 names 8 1/2 Otto e Mezzo - Bombana Three Stars in Hong Kong only; Macau card One Star (6238 stays) | {BEN}', L['cleanup'])}

  -- post-checks
  IF (SELECT count(*) FROM awards) <> {C2['awards']} OR EXISTS (SELECT 1 FROM awards WHERE id = 15736) THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = '{HK}') <> 11 OR (SELECT count(*) FROM awards WHERE venue_id = '{MO}') <> 6 THEN RAISE EXCEPTION 'awards per venue after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {C2['led_n']} OR (SELECT max(id) FROM source_capture_ledger) <> {C2['led_max']} THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM audit_log) <> {C2['aud_n']} OR (SELECT max(id) FROM audit_log) <> {C2['aud_max']}
     OR (SELECT count(*) FROM audit_log WHERE id > {C1['aud_max']} AND table_name = 'awards' AND action = 'DELETE' AND row_pk = '15736'
           AND old_row->>'venue_id' = '{MO}' AND old_row->>'category' = 'Three Stars') <> 1 THEN RAISE EXCEPTION 'audit after'; END IF;
END
$do$;
COMMIT;
"""

out1 = os.path.join(DOCS, f'{F1}.sql' if not TEST else f'open-items-b10-build/{F1}-TEST.sql')
open(out1, 'w', encoding='utf-8', newline='\n').write(sql1)
out2 = os.path.join(DOCS, f'{F2}.sql' if not TEST else f'open-items-b10-build/{F2}-TEST.sql')
open(out2, 'w', encoding='utf-8', newline='\n').write(sql2)
print('relay1', R1); print('relay2', R2)
print('file1', out1, sha(sql1), sql1.count('\n'), 'lines')
print('file2', out2, sha(sql2), sql2.count('\n'), 'lines')
print('mv_fp', MV_FP, 'after_fp', AFTER_FP, 'new_names', NEW_NAMES_MD5)
