"""Build docs/backfill-michelin-2025-hong-kong-macau.sql from the 2025 archive relay (D8).
Ben, Nov 1 13:22 ET: "A2, B1, C1, D1, E1".
  A2 = Stars, Bib Gourmand and Green Star rows.   B1 = source_url is the archive id_ URL of the 2025 full list.
  C1 = accept the 8 name pairs proved by the 2026 card (plus Din Tai Fung TST = din-tai-fung-silvercord).
  D1 = skip the 3 dropped 2025 Bibs with no venue (Man Yuen, Sun Yuen Hing Kee, What To Eat).
  E1 = row 10529 (Chiu Chow Delicacies, 2025 Bib) gets the source_url only.
Run:
  python3 -I build_backfill_hkmo_2025.py <relay>                       -> writes the read-only plan query, prints plan md5
  python3 -I build_backfill_hkmo_2025.py <relay> <plan_md5> <vid_md5>  -> writes the SQL file
"""
import hashlib, json, pathlib, sys

here = pathlib.Path(__file__).resolve().parent
root = here.parents[1]
relay_path = pathlib.Path(sys.argv[1])
raw = relay_path.read_bytes()
RELAY_SHA = '02bf30b13374118617211cf4973146b8048784e3717366e6aabcff5a9c0ca81b'
assert hashlib.sha256(raw).hexdigest() == RELAY_SHA
ARCH = 'https://web.archive.org/web/20251229115831id_/https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list'

# C1 pairs (seq -> venue id), proved by the 2026 card; seq 156 has 2 name candidates, the card picks one.
USE = {13: 've_a32153f7bc', 56: 've_712b801106', 60: 've_dd9a5ae60b', 151: 've_8a5d5ef4fe',
       190: 've_6fc44f5547', 195: 've_af6cfd76ec', 196: 've_0f96babf05', 198: 've_2020552694',
       156: 've_69f6dd939a'}
SKIP = {178: 'Man Yuen', 192: 'Sun Yuen Hing Kee', 206: 'What To Eat'}  # D1

rows = []
for line in raw.decode('ascii').splitlines():
    seq, region, cat, name, tag = line.split('|')
    seq = int(seq)
    if cat == 'Selected':
        continue
    name = name.encode('ascii').decode('unicode_escape').replace(' ', ' ')
    if seq in SKIP:
        assert SKIP[seq] == name and region == 'Hong Kong' and cat == 'Bib Gourmand', (seq, name)
        continue
    rows.append([seq, region, cat, name, USE.get(seq, '')])
assert len(rows) == 173, len(rows)
assert all(any(r[0] == s for r in rows) for s in USE)
plan_md5 = hashlib.md5('\n'.join('|'.join(map(str, r)) for r in rows).encode('utf-8')).hexdigest()
plan_json = json.dumps(rows, ensure_ascii=True).replace("'", "''")
cnt = {}
for r in rows:
    cnt[r[2]] = cnt.get(r[2], 0) + 1
assert cnt == {'Three Stars': 9, 'Two Stars': 17, 'One Star': 69, 'Green Star': 5, 'Bib Gourmand': 73}, cnt

# Venue resolution, shared by the plan query and the DO block. Input: jsonb pj.
RESOLVE = r"""p AS (SELECT (e->>0)::int seq, e->>1 region, e->>2 cat, e->>3 nm, nullif(e->>4, '') use_vid
        FROM jsonb_array_elements(pj) e),
  c(region, city_id) AS (VALUES ('Hong Kong', 'ci_1b1537ad28'), ('Macau', 'ci_9690a92f29')),
  pk AS (SELECT p.*, c.city_id, norm_key(p.nm) k1,
                norm_key(regexp_replace(p.nm, '\s*\([^)]*\)\s*$', '')) k2
           FROM p JOIN c USING (region)),
  vk AS (SELECT v.id, v.city_id, v.norm_key k1,
                norm_key(regexp_replace(v.name, '\s*\([^)]*\)\s*$', '')) k2
           FROM venues v WHERE v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29')),
  t1 AS (SELECT pk.seq, count(*) n, min(vk.id) vid FROM pk JOIN vk ON vk.city_id = pk.city_id AND vk.k1 = pk.k1 GROUP BY pk.seq),
  t2 AS (SELECT pk.seq, count(*) n, min(vk.id) vid FROM pk JOIN vk ON vk.city_id = pk.city_id AND vk.k2 = pk.k2 GROUP BY pk.seq),
  r AS (SELECT pk.seq, pk.cat, pk.city_id,
          CASE WHEN pk.use_vid IS NOT NULL THEN pk.use_vid
               WHEN t1.n = 1 THEN t1.vid
               WHEN t1.n IS NULL AND t2.n = 1 THEN t2.vid END vid,
          CASE WHEN pk.use_vid IS NOT NULL THEN 'use'
               WHEN t1.n = 1 THEN 't1'
               WHEN t1.n IS NULL AND t2.n = 1 THEN 't2' ELSE 'none' END how
        FROM pk LEFT JOIN t1 USING (seq) LEFT JOIN t2 USING (seq))"""

if len(sys.argv) == 2:
    q = f"""-- D8 plan query (read-only). plan md5 {plan_md5}
WITH pj AS (SELECT '{plan_json}'::jsonb pj),
{RESOLVE.replace('jsonb_array_elements(pj)', 'jsonb_array_elements((SELECT pj FROM pj))')}
SELECT
  (SELECT count(*) FROM r) n,
  (SELECT string_agg(how || ':' || n, ',' ORDER BY how) FROM (SELECT how, count(*) n FROM r GROUP BY how) h) by_how,
  (SELECT md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq)) FROM r) vid_md5,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid AND v.city_id = r.city_id) in_city,
  (SELECT string_agg(v.status::text || ':' || n, ',') FROM (SELECT v.status, count(*) n FROM r JOIN venues v ON v.id = r.vid GROUP BY v.status) v) by_status,
  (SELECT count(DISTINCT (vid, cat)) FROM r) distinct_vid_cat,
  (SELECT string_agg(a.id || ':' || r.seq || ':' || coalesce(a.source_url, 'null'), ',') FROM r JOIN awards a
     ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_2025,
  (SELECT string_agg(r.seq || ':' || r.vid || ':' || v.name, ' ; ' ORDER BY r.seq) FROM r JOIN venues v ON v.id = r.vid WHERE r.how IN ('t2', 'use')) t2_use;
"""
    pathlib.Path(sys.argv[0]).resolve().parent.joinpath('plan-query-hkmo-2025.sql').write_text(q, encoding='ascii')
    print('plan md5', plan_md5, 'rows', len(rows), cnt)
    sys.exit(0)

assert sys.argv[2] == plan_md5, (sys.argv[2], plan_md5)
vid_md5 = sys.argv[3]
script_sha = hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest()
job = ('backfill:michelin-2025-hong-kong-macau-archive | D8 (Ben, Nov 1 13:22 ET "A2, B1, C1, D1, E1"): Michelin Guide '
       'Hong Kong & Macau 2025 history from the web.archive.org capture 20251229115831 of the 2025 full list | 172 award rows '
       'inserted (Three Stars 9, Two Stars 17, One Star 69, Bib Gourmand 72, Green Star 5; Hong Kong 141, Macau 31) and row 10529 '
       'source_url filled (E1) | source_url = ' + ARCH + ' | relay docs/hkmo-2025-build/relay-hkmo-2025-archive-20251229115831.txt '
       'sha256 02bf30b1...0ca81b | C1 pairs by the 2026 card: Noi by Paulo Airaudo -> Noi ve_a32153f7bc; Seventh Son (Wan Chai) -> '
       "ve_712b801106; Sun Tung Lok -> ve_dd9a5ae60b; Cafe Hunan (Western District) -> Prof Chan's ve_8a5d5ef4fe; Sing Kee -> "
       've_6fc44f5547; Tai Woo -> ve_af6cfd76ec; Tak Kee -> ve_0f96babf05; Tasty (Central) -> ve_2020552694; Din Tai Fung '
       '(Tsim Sha Tsui) -> ve_69f6dd939a (card din-tai-fung-silvercord) | D1 skipped, no venue: Man Yuen, Sun Yuen Hing Kee, '
       'What To Eat (Hong Kong 2025 Bib Gourmand) | plan md5 ' + plan_md5)
assert all(ord(ch) < 128 for ch in job)

D8R = "(SELECT (e->>0)::int seq, e->>1 cat, e->>2 city_id, e->>3 vid, e->>4 how FROM jsonb_array_elements(rj) e)"
sql = f"""-- CompassEats, Nov 1 2026. D8: Michelin Guide Hong Kong & Macau 2025 history backfill.
-- Ben, Nov 1 13:22 ET "A2, B1, C1, D1, E1":
--   A2 Stars, Bib Gourmand and Green Star rows. B1 source_url = the archive id_ URL of the 2025 full list.
--   C1 8 name pairs proved by the 2026 card, plus Din Tai Fung (Tsim Sha Tsui) = card din-tai-fung-silvercord.
--   D1 skip Man Yuen, Sun Yuen Hing Kee, What To Eat (no venue). E1 row 10529 gets the source_url only.
-- Source: {ARCH}
--   (read Nov 1 in the built-in browser; status 200, 0 redirects; title "The Full List of the MICHELIN Guide Hong Kong & Macau 2025").
-- Relay: docs/hkmo-2025-build/relay-hkmo-2025-archive-20251229115831.txt sha256 {RELAY_SHA}.
-- Built by docs/hkmo-2025-build/build_backfill_hkmo_2025.py (sha256 {script_sha}) from the relay (no retyped rows).
-- Venue match, inside this transaction: exact norm_key in the city (t1); else norm_key with the trailing "(branch)" removed
--   on both sides, 1 venue only (t2); else the C1 venue id. Gates: plan md5 {plan_md5}; seq:venue md5 {vid_md5}.
-- Expected: awards INSERT 172 (michelin, 2025) and UPDATE 1 (id 10529, source_url); 1 ledger row; 173 audit rows (trigger).
--   awards 23,371 -> 23,543. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '{plan_json}';
  arch     text := '{ARCH}';
  job_txt  text := '{job.replace("'", "''")}';
  pj jsonb; rj jsonb;
  n int; x int; s text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3) || '|' || (e->>4), E'\\n' ORDER BY (e->>0)::int)), count(*)
    INTO s, n FROM jsonb_array_elements(pj) e;
  IF s <> '{plan_md5}' OR n <> 173 THEN RAISE EXCEPTION 'plan md5 % / rows % (expected {plan_md5} / 173)', s, n; END IF;

  -- The resolved plan is kept in rj (jsonb), so the dry run needs no temp table.
  WITH {RESOLVE}
  SELECT jsonb_agg(jsonb_build_array(seq, cat, city_id, vid, how) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO n, s FROM {D8R} d;
  IF n <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', n; END IF;
  IF s <> '{vid_md5}' THEN RAISE EXCEPTION 'seq:venue md5 % (expected {vid_md5})', s; END IF;
  SELECT count(*) INTO x FROM {D8R} r JOIN venues v ON v.id = r.vid AND v.city_id = r.city_id;
  IF x <> 173 THEN RAISE EXCEPTION 'venues in the stated city % (expected 173)', x; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO x FROM {D8R} d;
  IF x <> 173 THEN RAISE EXCEPTION 'distinct venue + category % (expected 173)', x; END IF;

  SELECT count(*), string_agg(a.id::text, ',') INTO x, s FROM {D8R} r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF x <> 1 OR s <> '10529' THEN RAISE EXCEPTION 'existing Michelin 2025 rows on the plan % / ids % (expected 1 / 10529)', x, s; END IF;
  SELECT count(*) INTO x FROM awards WHERE id = 10529 AND venue_id = 've_d7e57d1d84' AND source_id = 'michelin'
     AND year = 2025 AND category = 'Bib Gourmand' AND rank IS NULL AND distinction IS NULL AND source_url IS NULL;
  IF x <> 1 THEN RAISE EXCEPTION 'row 10529 is not as read (Chiu Chow Delicacies, 2025 Bib, no URL)'; END IF;

  -- 2. Counts before (read Nov 1 18:22:38 UTC)
  SELECT count(*), max(id) INTO x, n FROM awards;
  IF x <> 23371 OR n <> 30138 THEN RAISE EXCEPTION 'awards before % / max % (expected 23371 / 30138)', x, n; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9667 THEN RAISE EXCEPTION 'Michelin awards before % (expected 9667)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF x <> 3291 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3291)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF x <> 4 THEN RAISE EXCEPTION 'Green Star 2025 before % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29');
                                                IF x <> 1 THEN RAISE EXCEPTION 'HK/MO Michelin 2025 before % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11299 THEN RAISE EXCEPTION 'venues before % (expected 11299)', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 13002 THEN RAISE EXCEPTION 'slugs before % (expected 13002)', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3260 THEN RAISE EXCEPTION 'cities before % (expected 3260)', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;  IF x <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected 10934)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 159 OR led_max <> 209 THEN RAISE EXCEPTION 'ledger before % / max % (expected 159 / 209)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 116249 OR aud_max <> 121587 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 116249 / 121587)', aud_n, aud_max; END IF;

  -- 3. Write
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, arch FROM {D8R} r
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 172 THEN RAISE EXCEPTION 'award rows inserted % (expected 172)', n; END IF;

  UPDATE awards SET source_url = arch
   WHERE id = 10529 AND venue_id = 've_d7e57d1d84' AND year = 2025 AND category = 'Bib Gourmand' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'row 10529 updated % (expected 1)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 173, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM awards;           IF x <> 23543 THEN RAISE EXCEPTION 'awards after % (expected 23543)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9839 THEN RAISE EXCEPTION 'Michelin awards after % (expected 9839)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF x <> 3463 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3463)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF x <> 9 THEN RAISE EXCEPTION 'Green Star 2025 after % (expected 9)', x; END IF;
  SELECT string_agg(category || ':' || cnt, ',' ORDER BY category), sum(cnt) INTO s, x FROM (
    SELECT a.category, count(*) cnt FROM awards a JOIN venues v ON v.id = a.venue_id
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29')
       AND a.source_url = arch AND a.rank IS NULL AND a.distinction IS NULL GROUP BY a.category) g;
  IF x <> 173 OR s <> 'Bib Gourmand:73,Green Star:5,One Star:69,Three Stars:9,Two Stars:17'
    THEN RAISE EXCEPTION 'HK/MO Michelin 2025 with the archive URL % / % (expected 173)', x, s; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND v.city_id IN ('ci_1b1537ad28', 'ci_9690a92f29');
                                                IF x <> 173 THEN RAISE EXCEPTION 'HK/MO Michelin 2025 after % (expected 173)', x; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO s
    FROM {D8R} r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat AND a.source_url = arch;
  IF s <> '{vid_md5}' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected {vid_md5})', s; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11299 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 13002 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3260 THEN RAISE EXCEPTION 'cities changed: %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;  IF x <> 10934 THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', x; END IF;

  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 160 THEN RAISE EXCEPTION 'ledger after % (expected 160)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 173 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 173 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 173)', x; END IF;
  SELECT count(*) INTO x FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' = arch;
  IF x <> 172 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 172)', x; END IF;
  SELECT count(*) INTO x FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE' AND al.row_pk = '10529'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = arch;
  IF x <> 1 THEN RAISE EXCEPTION 'audit UPDATE row for 10529 % (expected 1)', x; END IF;
END
$do$;
COMMIT;
"""
assert all(ord(ch) < 128 for ch in sql)
out = root / 'docs/backfill-michelin-2025-hong-kong-macau.sql'
out.write_text(sql, encoding='ascii')
print(out, hashlib.sha256(out.read_bytes()).hexdigest(), len(sql.splitlines()), 'lines')
