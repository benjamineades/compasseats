#!/usr/bin/env python3
"""Build batch 2 of the held P1-rest venues (Oct 30, 2026; Ben "go with your recommendations" 15:11 ET, all groups A).

Venue changes, 4 relay lines:
  op merge : held branch venue -> sister venue (same Michelin card). Move the 2026 award row to the sister and set
             source_url NULL -> card URL; sister legacy price row -> card row; held slug -> sister, non-canonical;
             hand audit + DELETE city_label_source of the held venue; DELETE listing; DELETE venue.
  op move  : Paloma Taqueria city Auckland -> Wanaka; old slug non-canonical; INSERT new canonical slug;
             michelin city label (city_display) Auckland -> Wanaka with a hand audit row. Award and price unchanged
             (both already hold the card URL from batch 1).

Usage:
  python3 build_p1_rest_held_b2_sql.py RELAY OUT_SQL KEY OLD_FP

Relay line: op|venue_id|target|award_id|card|symbol|CAT_P0n|distinction|greenstar|country|captured_at|old_slug
(target = sister venue_id for merge, new city_id for move; card = path after "https://guide.michelin.com/";
old_slug = city_slug/slug; sorted by venue_id; no final newline).
OLD_FP = md5 of every row on the 7 venues (venues, awards, price, slugs, listings, city_label_source) as
"table:to_jsonb(row)::text", newline, ordered by table and text (COLLATE "C"), read before the build.
"""
import hashlib
import sys
from collections import Counter

BASE = 'https://guide.michelin.com/'
CUR = {'vn': 'VND', 'nz': 'NZD'}
SYM = {'VND': '₫', 'NZD': '$'}

relay_file, out_sql, key, old_fp = sys.argv[1:5]

# Live state read Oct 30, 2026 (20:5x UTC), whole tables.
PRICE, LEDGER, AUDIT, AWARDS = 7730, 159, 118728, 23353
VENUES, ACTIVE, SLUGS, LISTINGS, CLS = 11307, 10940, 12842, 11307, 24011
NOPRICE = 6
PALOMA_OLD_CITY, PALOMA_CLS_ID = 'ci_4665921775', 21594

txt = open(relay_file, encoding='utf-8').read()
assert not txt.endswith('\n') and '$r$' not in txt and "'" not in txt
sha = hashlib.sha256(txt.encode('utf-8')).hexdigest()
rows = []
for l in txt.split('\n'):
    f = l.split('|')
    assert len(f) == 12, l
    op, vid, tgt, aid, card, sym, cat, dist, gs, cc, at, old = f
    assert op in ('merge', 'move') and vid.startswith('ve_') and len(vid) == 13, l
    assert (op == 'merge' and tgt.startswith('ve_')) or (op == 'move' and tgt.startswith('ci_')), l
    assert aid.isdigit() and card.startswith('us/en/') and '/restaurant/' in card, l
    assert dist == 'bib' and gs == 'False' and cat == 'CAT_P0%d' % len(sym) and sym == sym[0] * len(sym), l
    cur = CUR[cc]
    assert SYM[cur] == sym[0], l
    assert old.count('/') == 1, l
    rows.append(dict(op=op, venue_id=vid, target=tgt, award_id=aid, url=BASE + card, symbol_raw=sym, currency=cur,
                     tier=len(sym), captured_at=at, old_city_slug=old.split('/')[0], old_slug=old.split('/')[1]))
ids = [r['venue_id'] for r in rows]
assert ids == sorted(ids) and len(set(ids)) == len(ids)
ops = Counter(r['op'] for r in rows)
assert ops == Counter(merge=3, move=1)
KEYS = ('op', 'venue_id', 'target', 'award_id', 'url', 'symbol_raw', 'currency', 'tier', 'captured_at',
        'old_city_slug', 'old_slug')
fp = hashlib.md5('\n'.join('|'.join(str(r[k]) for k in KEYS) for r in rows).encode('utf-8')).hexdigest()
merges = [r for r in rows if r['op'] == 'merge']
move = [r for r in rows if r['op'] == 'move'][0]
assert move['old_city_slug'] == 'auckland'
held_ids = ','.join("'%s'" % r['venue_id'] for r in merges)
held_md5 = hashlib.md5(','.join(r['venue_id'] for r in merges).encode()).hexdigest()
tier_counts = Counter(r['tier'] for r in merges)
tier_txt = ', '.join('%d = %d' % (k, tier_counts[k]) for k in sorted(tier_counts))
n_m = len(merges)

L1, L2, L3 = LEDGER + 1, LEDGER + 2, LEDGER + 3
# audit: awards UPD 3, price UPD 3, slugs UPD 3+1, slugs INS 1, cls hand DEL 6, cls hand UPD 1, listings DEL 3,
#        venues DEL 3, venues UPD 1
EXP = {('awards', 'UPDATE'): n_m, ('price', 'UPDATE'): n_m, ('slugs', 'UPDATE'): n_m + 1, ('slugs', 'INSERT'): 1,
       ('city_label_source', 'DELETE'): 2 * n_m, ('city_label_source', 'UPDATE'): 1, ('listings', 'DELETE'): n_m,
       ('venues', 'DELETE'): n_m, ('venues', 'UPDATE'): 1}
N_AUDIT = sum(EXP.values())
A1, A2 = AUDIT + 1, AUDIT + N_AUDIT
exp_case = ' + '.join(
    "(CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN %d AND %d AND table_name = '%s' AND action = '%s') = %d "
    "THEN 0 ELSE 1 END)" % (A1, A2, t, a, n) for (t, a), n in sorted(EXP.items()))
exp_txt = ', '.join('%s %s %d' % (t, a, n) for (t, a), n in sorted(EXP.items()))

REC = ('x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, '
       'captured_at text, old_city_slug text, old_slug text)')
FK = ('addresses', 'awards', 'blurbs', 'city_label_source', 'geo', 'hours', 'listings', 'photo_refs', 'price', 'slugs')
left_check = ' + '.join('(SELECT count(*) FROM %s WHERE venue_id IN (%s))' % (t, held_ids) for t in FK)
OLD_FP_SQL = """SELECT md5(string_agg(t || ':' || j, E'\\n' ORDER BY t COLLATE "C", j COLLATE "C")) FROM (
           SELECT 'venues' AS t, to_jsonb(v)::text AS j FROM venues v WHERE v.id = ANY (ids)
           UNION ALL SELECT 'awards', to_jsonb(a)::text FROM awards a WHERE a.venue_id = ANY (ids)
           UNION ALL SELECT 'price', to_jsonb(p)::text FROM price p WHERE p.venue_id = ANY (ids)
           UNION ALL SELECT 'slugs', to_jsonb(s)::text FROM slugs s WHERE s.venue_id = ANY (ids)
           UNION ALL SELECT 'listings', to_jsonb(l)::text FROM listings l WHERE l.venue_id = ANY (ids)
           UNION ALL SELECT 'cls', to_jsonb(c)::text FROM city_label_source c WHERE c.venue_id = ANY (ids)) s"""
NOPRICE_SQL = """(SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id))"""
BADCANON_SQL = ("(SELECT count(*) FROM venues v WHERE (SELECT count(*) FROM slugs s "
                "WHERE s.venue_id = v.id AND s.is_canonical) <> 1)")

job1 = (f"merge:{key} | held P1 rest batch 2: 3 Vietnam branch merges; 2026 Bib row moved to the sister venue (sister "
        f"holds the 2025 Bib of the same card), source_url NULL -> card URL | 21122 CHAY GARDEN Nguyen Thi Minh Khai "
        f"ve_f97f8ec140 -> CHAY GARDEN Vo Van Tan ve_3195442b2e (card 1201807, 52 Vo Van Tan); 21126 Hong Phat Ben Thanh "
        f"ve_595408ccd8 -> Hu Tieu Hong Phat ve_39dc53fd44 (card 1205566, 389-391 Vo Van Tan = venue site branch 01 Quan 3); "
        f"21121 Man Moi Ben Nghe ve_3a9de72b7b -> Man Moi Thao Dien ve_c1ed9b62ab (card 1211006, 32 D11 An Khanh = manmoi.vn "
        f"Thao Dien 32 St. 11 W. An Khanh; Ben Nghe = 125 Hai Ba Trung) | held venues deleted with their listing and 2 "
        f"city labels each; old slugs kept non-canonical on the sister | Ben A Oct 30 15:11 ET; Man Moi confirmed 17:07 ET | relay md5 {fp}")
job2 = (f"price-card:{key} | held P1 rest batch 2: sister legacy price rows with no URL -> card row | {n_m} rows updated "
        f"from legacy (VND {n_m}; tiers {tier_txt}) | live card read, built-in browser | relay md5 {fp}")
job3 = (f"city-move:{key} | Paloma Taqueria ve_3fad690140: city Auckland {PALOMA_OLD_CITY} -> Wanaka {move['target']} "
        f"(card 1247956: 28 Helwick Street, Wanaka); michelin city label {PALOMA_CLS_ID} Auckland -> Wanaka; slug "
        f"wanaka/paloma-taqueria canonical, auckland/paloma-taqueria kept non-canonical | Ben A Oct 30 15:11 ET; label Wanaka 17:07 ET | "
        f"relay md5 {fp}")
for j in (job1, job2, job3):
    assert j.isascii() and "'" not in j

sql = f"""-- {key}.sql
-- Held P1-rest venues, batch 2 of 2 (venue changes). Ben Oct 30, 2026, 15:11 ET: "go with your recommendations" (all A).
-- Merges (Chengdu delete method): the held branch venue holds only the 2026 Bib of a card whose 2025 Bib sits on a sister
--   venue. Move the award row to the sister (source_url NULL -> card URL); sister legacy price (no URL) -> card row
--   (guide_ingest, VND); held slug -> sister, non-canonical; hand audit + DELETE 2 city labels; DELETE listing; DELETE venue.
--   CHAY GARDEN: card 1201807 "Chay Garden (Xuan Hoa)", 52 Vo Van Tan; sister name holds the street.
--   Hong Phat: card 1205566 "Hong Phat (Ban Co)", 389-391 Vo Van Tan; hutieuhongphat.com branch 01 Quan 3 = 389-391.
--   Man Moi: card 1211006 "Man Moi (An Khanh)", 32 D11 Street, An Khanh Ward; manmoi.vn/en/our-locations: Thao Dien =
--     32 St. 11, W. An Khanh; Ben Nghe = 125 Hai Ba Trung, W. Sai Gon.
-- Move: Paloma Taqueria Auckland -> Wanaka (card 1247956, 28 Helwick Street, Wanaka). Status stays active.
--   Award 21210 and the price row already hold the card URL (batch 1). City label 21594 Auckland -> Wanaka (the 5 other
--   Wanaka venues hold "Wanaka"). cities.venues_count is not changed (open decision).
-- Relay sha256 {sha} (inside this file). Relay fingerprint md5 {fp}. Held venue ids md5 {held_md5}.
-- Guards: price {PRICE}, ledger max {LEDGER}, audit max {AUDIT}, awards {AWARDS}, venues {VENUES} (active {ACTIVE}),
--   slugs {SLUGS}, listings {LISTINGS}, city labels {CLS}; old rows fingerprint {old_fp} (46 rows on the 7 venues);
--   active star/Bib venues with no price {NOPRICE}; venues without exactly 1 canonical slug 0; card URLs not in use.
-- Post-checks: venues {VENUES - n_m} (active {ACTIVE - n_m}); awards {AWARDS}; price {PRICE}; slugs {SLUGS + 1};
--   listings {LISTINGS - n_m}; city labels {CLS - 2 * n_m}; ledgers {L1} (award), {L2} (price), {L3} (city_label);
--   audit {A1} to {A2}: {exp_txt}, nothing else; 0 rows left on the 3 held ids in the 10 FK tables;
--   active star/Bib venues with no price {NOPRICE - n_m}; venues without exactly 1 canonical slug 0.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r${txt}$r$;
  rel jsonb;
  ids text[];
  v_fp text;
  v_bad int;
  v_n int;
BEGIN
  IF (SELECT count(*) FROM price) <> {PRICE} THEN RAISE EXCEPTION 'price count before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {LEDGER} THEN RAISE EXCEPTION 'ledger max before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {AUDIT} THEN RAISE EXCEPTION 'audit max before'; END IF;
  IF (SELECT count(*) FROM awards) <> {AWARDS} THEN RAISE EXCEPTION 'awards count before'; END IF;
  IF (SELECT count(*) FROM venues) <> {VENUES} THEN RAISE EXCEPTION 'venues count before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> {ACTIVE} THEN RAISE EXCEPTION 'active venues before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {SLUGS} THEN RAISE EXCEPTION 'slugs count before'; END IF;
  IF (SELECT count(*) FROM listings) <> {LISTINGS} THEN RAISE EXCEPTION 'listings count before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> {CLS} THEN RAISE EXCEPTION 'city labels count before'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha}' THEN RAISE EXCEPTION 'relay sha256'; END IF;

  -- relay line: op|venue_id|target|award_id|card|symbol|CAT_P0n|distinction|greenstar|country|captured_at|old_slug
  SELECT jsonb_agg(jsonb_build_object(
           'op', f[1], 'venue_id', f[2], 'target', f[3], 'award_id', f[4], 'url', 'https://guide.michelin.com/' || f[5],
           'symbol_raw', f[6], 'currency', CASE f[10] WHEN 'vn' THEN 'VND' WHEN 'nz' THEN 'NZD' END,
           'tier', char_length(f[6]), 'captured_at', f[11],
           'old_city_slug', split_part(f[12], '/', 1), 'old_slug', split_part(f[12], '/', 2)) ORDER BY f[2] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 12 OR f[7] <> 'CAT_P0' || char_length(f[6])
                            OR f[6] <> repeat(left(f[6], 1), char_length(f[6])) OR f[8] <> 'bib' OR f[9] <> 'False'
                            OR f[1] NOT IN ('merge','move') OR f[10] NOT IN ('vn','nz')
                            OR left(f[6], 1) <> CASE f[10] WHEN 'vn' THEN '₫' WHEN 'nz' THEN '$' END)
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> {len(rows)} THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  SELECT md5(string_agg(x.op||'|'||x.venue_id||'|'||x.target||'|'||x.award_id||'|'||x.url||'|'||x.symbol_raw||'|'
                        ||x.currency||'|'||x.tier||'|'||x.captured_at||'|'||x.old_city_slug||'|'||x.old_slug,
                        E'\\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp FROM jsonb_to_recordset(rel) AS {REC};
  IF v_fp <> '{fp}' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  SELECT md5(string_agg(x.venue_id, ',' ORDER BY x.venue_id COLLATE "C")) INTO v_fp
    FROM jsonb_to_recordset(rel) AS {REC} WHERE x.op = 'merge';
  IF v_fp <> '{held_md5}' THEN RAISE EXCEPTION 'held venue ids md5 %', v_fp; END IF;

  -- every row on the 7 venues, as read before the build
  SELECT array_agg(v ORDER BY v COLLATE "C") INTO ids FROM (
    SELECT x.venue_id AS v FROM jsonb_to_recordset(rel) AS {REC}
    UNION SELECT x.target FROM jsonb_to_recordset(rel) AS {REC} WHERE x.op = 'merge') u;
  IF array_length(ids, 1) <> 7 THEN RAISE EXCEPTION 'venue id set'; END IF;
  {OLD_FP_SQL} INTO v_fp;
  IF v_fp IS DISTINCT FROM '{old_fp}' THEN RAISE EXCEPTION 'old rows fingerprint %', v_fp; END IF;
  IF {NOPRICE_SQL} <> {NOPRICE} THEN RAISE EXCEPTION 'active star/Bib venues with no price before'; END IF;
  IF {BADCANON_SQL} <> 0 THEN RAISE EXCEPTION 'canonical slugs before'; END IF;

  -- per-row conditions
  SELECT count(*) INTO v_bad FROM jsonb_to_recordset(rel) AS {REC}
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = x.venue_id AND s.city_slug = x.old_city_slug
                       AND s.slug = x.old_slug AND s.property_id = 'eats' AND s.is_canonical)
      OR (SELECT count(*) FROM slugs s WHERE s.venue_id = x.venue_id) <> 1
      OR (x.op = 'merge' AND (
             NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.venue_id
                           AND a.source_id = 'michelin' AND a.year = 2026 AND a.category = 'Bib Gourmand'
                           AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL)
          OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.venue_id) <> 1
          OR EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id)
          OR NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.target AND v.status = 'active')
          OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.target AND a.source_id = 'michelin' AND a.year = 2025
                AND a.category = 'Bib Gourmand') <> 1
          OR EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = x.target AND a.year = 2026)
          OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.target AND p.source = 'legacy_guide'
                           AND p.source_url IS NULL AND p.currency IS NULL AND p.tier = x.tier)
          OR (SELECT count(*) FROM city_label_source c WHERE c.venue_id = x.venue_id) <> 2
          OR (SELECT count(*) FROM listings l WHERE l.venue_id = x.venue_id) <> 1))
      OR (x.op = 'move' AND (
             NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.city_id = '{PALOMA_OLD_CITY}')
          OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id = x.target AND c.slug = 'wanaka')
          OR EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = 'wanaka' AND s.slug = x.old_slug)
          OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.venue_id
                           AND a.source_url = x.url AND a.year = 2026 AND a.category = 'Bib Gourmand')
          OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source_url = x.url)
          OR NOT EXISTS (SELECT 1 FROM city_label_source c WHERE c.id = {PALOMA_CLS_ID} AND c.venue_id = x.venue_id
                           AND c.label = 'Auckland' AND c.from_column = 'city_display' AND c.publisher = 'michelin')));
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows changed since the read: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS {REC} ON a.source_url = x.url WHERE x.op = 'merge')
    THEN RAISE EXCEPTION 'a card URL is already in use on an award row'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS {REC} ON p.source_url = x.url WHERE x.op = 'merge')
    THEN RAISE EXCEPTION 'a card URL is already in use on a price row'; END IF;

  -- merges: award row -> sister, with the card URL
  UPDATE awards a SET venue_id = x.target, source_url = x.url
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op = 'merge' AND a.id = x.award_id::bigint AND a.venue_id = x.venue_id AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> {n_m} THEN RAISE EXCEPTION 'award rows moved: %', v_n; END IF;
  -- merges: sister legacy price -> card row
  UPDATE price p SET source = 'guide_ingest', method = 'published_symbol', publisher = 'michelin', source_url = x.url,
         symbol_raw = x.symbol_raw, currency = x.currency, tier = x.tier, confidence = NULL,
         captured_at = x.captured_at::timestamptz
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op = 'merge' AND p.venue_id = x.target AND p.source = 'legacy_guide' AND p.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> {n_m} THEN RAISE EXCEPTION 'price rows updated: %', v_n; END IF;
  -- merges: held slug -> sister, non-canonical (old-slug policy)
  UPDATE slugs s SET venue_id = x.target, is_canonical = false
    FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op = 'merge' AND s.venue_id = x.venue_id AND s.city_slug = x.old_city_slug AND s.slug = x.old_slug
     AND s.property_id = 'eats';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> {n_m} THEN RAISE EXCEPTION 'slug rows moved: %', v_n; END IF;
  -- merges: city labels (no trigger: hand audit rows first)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.venue_id IN ({held_ids}) ORDER BY c.id;
  DELETE FROM city_label_source WHERE venue_id IN ({held_ids});
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> {2 * n_m} THEN RAISE EXCEPTION 'city labels deleted: %', v_n; END IF;
  DELETE FROM listings WHERE venue_id IN ({held_ids});
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> {n_m} THEN RAISE EXCEPTION 'listings deleted: %', v_n; END IF;
  DELETE FROM venues WHERE id IN ({held_ids});
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> {n_m} THEN RAISE EXCEPTION 'venues deleted: %', v_n; END IF;

  -- move: Paloma Taqueria Auckland -> Wanaka
  UPDATE venues v SET city_id = x.target FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op = 'move' AND v.id = x.venue_id AND v.city_id = '{PALOMA_OLD_CITY}';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'venue city updated: %', v_n; END IF;
  UPDATE slugs s SET is_canonical = false FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op = 'move' AND s.venue_id = x.venue_id AND s.city_slug = x.old_city_slug AND s.slug = x.old_slug
     AND s.property_id = 'eats' AND s.is_canonical;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'old slug set non-canonical: %', v_n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', 'wanaka', x.old_slug, x.venue_id, true FROM jsonb_to_recordset(rel) AS {REC} WHERE x.op = 'move';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'new slug inserted: %', v_n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'UPDATE', to_jsonb(c), to_jsonb(c) || jsonb_build_object('label', 'Wanaka')
    FROM city_label_source c WHERE c.id = {PALOMA_CLS_ID} AND c.label = 'Auckland';
  UPDATE city_label_source SET label = 'Wanaka' WHERE id = {PALOMA_CLS_ID} AND label = 'Auckland';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'city label updated: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin', 'award', {n_m}, '{job1}'),
    ('michelin', 'price', {n_m}, '{job2}'),
    ('michelin', 'city_label', 1, '{job3}');

  -- post-checks
  IF (SELECT count(*) FROM venues) <> {VENUES - n_m} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> {ACTIVE - n_m} THEN RAISE EXCEPTION 'active after'; END IF;
  IF (SELECT count(*) FROM awards) <> {AWARDS} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM price) <> {PRICE} THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {SLUGS + 1} THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> {LISTINGS - n_m} THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> {CLS - 2 * n_m} THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF (SELECT array_agg(id ORDER BY id) FROM source_capture_ledger WHERE id > {LEDGER}) <> ARRAY[{L1},{L2},{L3}]::bigint[]
    THEN RAISE EXCEPTION 'ledger ids after'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {A2} OR (SELECT count(*) FROM audit_log WHERE id > {AUDIT}) <> {N_AUDIT}
    THEN RAISE EXCEPTION 'audit range after'; END IF;
  IF {exp_case} <> 0 THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
  IF {left_check} <> 0 THEN RAISE EXCEPTION 'rows left on the held venue ids'; END IF;
  IF {NOPRICE_SQL} <> {NOPRICE - n_m} THEN RAISE EXCEPTION 'active star/Bib venues with no price after'; END IF;
  IF {BADCANON_SQL} <> 0 THEN RAISE EXCEPTION 'canonical slugs after'; END IF;
  SELECT count(*) INTO v_bad FROM jsonb_to_recordset(rel) AS {REC}
   WHERE x.op = 'merge' AND (
         NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.target AND a.source_url = x.url)
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.target AND p.source_url = x.url
                       AND p.symbol_raw = x.symbol_raw AND p.currency = 'VND' AND p.source = 'guide_ingest')
      OR NOT EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = x.target AND s.slug = x.old_slug AND NOT s.is_canonical)
      OR (SELECT count(*) FROM slugs s WHERE s.venue_id = x.target AND s.is_canonical) <> 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'sister rows after: %', v_bad; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = '{move['venue_id']}' AND city_id = '{move['target']}' AND status = 'active')
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = '{move['venue_id']}' AND city_slug = 'wanaka' AND is_canonical)
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = '{move['venue_id']}' AND city_slug = 'auckland' AND NOT is_canonical)
    THEN RAISE EXCEPTION 'Paloma rows after'; END IF;
END
$do$;
COMMIT;
"""
open(out_sql, 'w', encoding='utf-8').write(sql)
print('relay sha256', sha)
print('relay fp md5', fp)
print('held ids md5', held_md5)
print('audit', A1, A2, N_AUDIT, exp_txt)
print('sql sha256', hashlib.sha256(sql.encode('utf-8')).hexdigest(), len(sql.encode('utf-8')), 'bytes')
