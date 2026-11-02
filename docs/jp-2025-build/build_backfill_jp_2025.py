"""Build the Japan 2025 backfill SQL (complete page sets only) from the relay (no retyped rows).

Usage:
  python3 -I build_backfill_jp_2025.py plan                         -> writes plan-query-jp-2025.sql (read-only)
  python3 -I build_backfill_jp_2025.py sql <seqvid_md5> <existing_ids_md5> <counts.json>
                                                                    -> writes ../backfill-michelin-2025-japan.sql
Ben, Nov 1 21:50 ET "J1 & K1": J1 = load the complete sets only (Green Stars of all 4 guides, Three Stars of
Tokyo / Kyoto / Osaka, Two Stars of Kyoto / Osaka); One Star and the other sets wait (no full list found).
K1 = check Chugokusai Naramachi Kuko against the venue's own site and the Michelin card first.
Q1 (Nov 1 15:50): skip lines with no venue. R1: source_url = the archive id_ URL of the page that lists the line.
"""
import hashlib, json, pathlib, sys

here = pathlib.Path(__file__).parent
relay = (here / "relay-jp-2025-archive-partial.txt").read_text(encoding="ascii")
RELAY_SHA = hashlib.sha256(relay.encode()).hexdigest()
assert RELAY_SHA == "ceab8dbaf2ffabb7f2ddab92ca72ac2ed99a19db45a1a5d6b76d60afa5db99e1"

W = "https://web.archive.org/web/"
G = "https://guide.michelin.com/"
# One archive page per set (page total = published 2025 total; read Nov 1-2 in the built-in browser, status 200, 0 redirects).
SETS = {
    "T|green": ("20250712063411", "jp/ja/tokyo-region/restaurants/sustainable_gastronomy", "Green Star", 12),
    "T|3":     ("20250122140437", "jp/ja/tokyo-region/restaurants/3-stars-michelin", "Three Stars", 12),
    "K|green": ("20250401023911", "jp/en/kyoto-region/restaurants/sustainable_gastronomy", "Green Star", 10),
    "K|3":     ("20250401023910", "jp/en/kyoto-region/restaurants/3-stars-michelin", "Three Stars", 5),
    "K|2":     ("20250401023910", "jp/en/kyoto-region/restaurants/2-stars-michelin", "Two Stars", 16),
    "O|green": ("20250401023911", "jp/en/osaka-region/restaurants/sustainable_gastronomy", "Green Star", 3),
    "O|3":     ("20250401023910", "jp/en/osaka-region/restaurants/3-stars-michelin", "Three Stars", 3),
    "O|2":     ("20250401023910", "jp/en/osaka-region/restaurants/2-stars-michelin", "Two Stars", 11),
    "N|green": ("20250714130145", "jp/en/nara-region/restaurants/sustainable_gastronomy", "Green Star", 7),
}
URL = {k: f"{W}{ts}id_/{G}{p}" for k, (ts, p, c, n) in SETS.items()}
CAT = {k: v[2] for k, v in SETS.items()}

# V1: the venue holds the 2025 star row now (no URL). The row gets the URL.
V1 = {16: "ve_05c8533123"}            # SEZANNE, award 1291 (Three Stars, no URL)
# K1 (venue's own site kuko-nara.jp: Green Star 2022-2025; both Michelin cards link it; card moved
# chugokusai-naramachi-kuko -> naramachi-kuko, address Kideracho -> Narukawacho).
K1 = {119: "ve_c0eba7ae71"}
USE = {**V1, **K1}
# Q1: no venue in the database.
SKIP_Q1 = {3: "n%C5%93ud-tokyo", 25: "ristorante-dono", 28: "vegan-ramen-uzu", 78: "unkaku",
           115: "awa-naramachiten", 116: "sanjuhachi", 117: "kuramoto-ryori-maruto-shoyu", 118: "kiyosuminosato-awa"}
assert not (set(SKIP_Q1) & set(USE))

lines = relay.splitlines()
assert len(lines) == 119
name_of = {}
plan, set_count = [], {}
for i, ln in enumerate(lines, 1):
    g, c, slug, region, name = ln.split("|")
    key = f"{g}|{c}"
    name_of[i] = name
    if key not in SETS:
        assert c == "1p1"
        continue
    set_count[key] = set_count.get(key, 0) + 1
    if i in SKIP_Q1:
        assert SKIP_Q1[i] == slug, (i, slug)
        continue
    plan.append([i, CAT[key], slug.lower(), USE.get(i, ""), key])
for k, v in SETS.items():
    assert set_count[k] == v[3], (k, set_count[k], v[3])
assert lines[15].split("|")[2] == "sezanne" and lines[118].split("|")[2] == "chugokusai-naramachi-kuko"

N = len(plan)
assert N == 79 - len(SKIP_Q1) == 71
PLAN_MD5 = hashlib.md5("\n".join(f"{a}|{b}|{c}|{d}|{e}" for a, b, c, d, e in plan).encode("ascii")).hexdigest()

def dec(s):
    return s.encode("ascii").decode("unicode_escape")

RESOLVE = """WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid, e->>4 skey FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/restaurante?/' AND c.country_iso = 'JP'),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat, p.skey,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how
        FROM p LEFT JOIN t1 USING (seq))"""

RJ = "(SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 skey FROM jsonb_array_elements(rj) e)"
URLMAP = "(SELECT key skey, value #>> '{}' url FROM jsonb_each(uj))"

if sys.argv[1] == "plan":
    lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
    res = RESOLVE.replace("jsonb_array_elements(pj)", f"jsonb_array_elements('{lit}'::jsonb)")
    q = f"""-- Japan 2025 plan query (read-only).
SELECT '{PLAN_MD5}' plan_md5, {N} n_plan, * FROM (
{res}
SELECT
  (SELECT string_agg(how || ':' || cnt, ',' ORDER BY how) FROM (SELECT how, count(*) cnt FROM r GROUP BY how) h) by_how,
  (SELECT md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq)) FROM r) seqvid_md5,
  (SELECT count(DISTINCT (vid, cat)) FROM r) distinct_vid_cat,
  (SELECT count(DISTINCT vid) FROM r) distinct_vid,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid JOIN cities c ON c.id = v.city_id WHERE c.country_iso = 'JP') in_jp,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_n,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) existing_clean,
  (SELECT md5(string_agg(a.id::text, ',' ORDER BY a.id)) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids_md5,
  (SELECT string_agg(a.id::text, ',' ORDER BY a.id) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids,
  (SELECT string_agg(r.seq || '>' || a.id || ':' || a.category, ',' ORDER BY r.seq) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
     AND a.category <> r.cat AND a.category IN ('Three Stars', 'Two Stars', 'One Star') AND r.cat <> 'Green Star') star_conflicts,
  (SELECT string_agg(cat || ':' || cnt, ',' ORDER BY cat) FROM (SELECT cat, count(*) cnt FROM r GROUP BY cat) c) by_cat,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid WHERE v.status = 'closed') closed_venues,
  (SELECT string_agg(r.seq || ':' || v.name || ':' || c.display, ' ; ' ORDER BY r.seq) FROM r JOIN venues v ON v.id = r.vid JOIN cities c ON c.id = v.city_id WHERE r.how = 'use') use_rows
) q;
"""
    (here / "plan-query-jp-2025.sql").write_text(q, encoding="ascii")
    print("plan md5", PLAN_MD5, "rows", N)
    sys.exit()

# ---------------------------------------------------------------- sql mode
SEQVID_MD5, EXIST_MD5 = sys.argv[2], sys.argv[3]
B = json.loads((here / sys.argv[4]).read_text())
EXIST_IDS = [1291]
FILL = len(EXIST_IDS)
INS = N - FILL
by_cat = {}
for s, c, sl_, v, k in plan:
    by_cat[c] = by_cat.get(c, 0) + 1
by_cat_txt = ",".join(f"{k}:{by_cat[k]}" for k in sorted(by_cat))
GS_NEW = by_cat["Green Star"]
plan_lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
url_lit = json.dumps(URL, ensure_ascii=True).replace("'", "''")
URL_MD5 = hashlib.md5("\n".join(f"{k}|{URL[k]}" for k in sorted(URL)).encode("ascii")).hexdigest()
fmt = lambda d: "; ".join(f"{k} -> {v}" for k, v in sorted(d.items())) or "none"
skip_txt = "; ".join(dec(name_of[s]).split("／")[-1] for s in sorted(SKIP_Q1))
n_card = N - len(USE)
sets_txt = "; ".join(f"{k} {SETS[k][0]} {SETS[k][1]} ({SETS[k][3]})" for k in SETS)

job = ("backfill:michelin-2025-japan-archive | item 4 (Ben, Nov 1 21:50 ET \"J1 & K1\"): Michelin Guide Tokyo 2025 "
       "(Oct 17 2024), Kyoto Osaka 2025 (Mar 27 2025) and Nara 2025 (May 14 2025) from web.archive.org, complete page sets only "
       f"| {FILL} existing 2025 row gets the source_url; {INS} rows inserted ({by_cat_txt} in all {N}) "
       f"| source_url = the archive id_ URL of the region selection page that lists the line: {sets_txt} "
       f"| relay docs/jp-2025-build/relay-jp-2025-archive-partial.txt sha256 {RELAY_SHA[:8]}...{RELAY_SHA[-6:]} "
       "| page totals = the 2025 jp/ja ceremony article totals | match: card link = Michelin card of an existing award row "
       f"({n_card}); V1 2025 row: {fmt(V1)}; K1 (own site kuko-nara.jp + both Michelin cards): {fmt(K1)} "
       f"| Q1 skipped (no venue): {skip_txt} | J1: not loaded (no full list found in the archive): Tokyo Two Stars and One Star, "
       "Nara Two Stars and One Star, Kyoto and Osaka One Star (page 1 of 4 only); 2025 Bibs no change | plan md5 " + PLAN_MD5)
job_lit = job.replace("'", "''")
ex_list = ",".join(map(str, EXIST_IDS))

sql = f"""-- CompassEats, Nov 1 2026. Item 4: Michelin Guide Japan 2025 (Tokyo, Kyoto Osaka, Nara), complete page sets only.
-- Ben, Nov 1 21:50 ET "J1 & K1" (J1 = complete sets only: Green Stars of all 4 guides, Three Stars Tokyo / Kyoto / Osaka,
--   Two Stars Kyoto / Osaka; K1 = Naramachi Kuko pair after the own-site check).
-- Sources (read Nov 1-2 in the built-in browser; status 200; 0 redirects). Page total = the 2025 article total:
""" + "".join(f"--   {k:8} {URL[k]}  ({SETS[k][3]})\n" for k in SETS) + f"""-- Relay sha256 {RELAY_SHA}; URL map md5 {URL_MD5}.
-- Built by docs/jp-2025-build/build_backfill_jp_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in JP ('card'); else the venue id in the build script ('use': SEZANNE V1, Naramachi Kuko K1).
--   Gates: plan md5 {PLAN_MD5}; seq:venue md5 {SEQVID_MD5}; existing 2025 row ids md5 {EXIST_MD5}.
-- Expected: awards UPDATE {FILL} (source_url) and INSERT {INS} (michelin, 2025); 1 ledger row; {N} audit rows (trigger).
--   awards {B['awards']:,} -> {B['awards'] + INS:,}. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '{plan_lit}';
  url_txt  text := '{url_lit}';
  job_txt  text := '{job_lit}';
  pj jsonb; rj jsonb; uj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;
  uj := url_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3) || '|' || (e->>4), E'\\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> '{PLAN_MD5}' OR cnt <> {N} THEN RAISE EXCEPTION 'plan md5 % / rows % (expected {PLAN_MD5} / {N})', txt, cnt; END IF;
  SELECT md5(string_agg(skey || '|' || url, E'\\n' ORDER BY skey)), count(*) INTO txt, cnt FROM {URLMAP} u;
  IF txt <> '{URL_MD5}' OR cnt <> {len(URL)} THEN RAISE EXCEPTION 'URL map md5 % / % (expected {URL_MD5} / {len(URL)})', txt, cnt; END IF;

{RESOLVE}
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how, skey) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM {RJ} d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> '{SEQVID_MD5}' THEN RAISE EXCEPTION 'seq:venue md5 % (expected {SEQVID_MD5})', txt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso = 'JP';
  IF cnt <> {N} THEN RAISE EXCEPTION 'venues in JP % (expected {N})', cnt; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO cnt FROM {RJ} d;
  IF cnt <> {N} THEN RAISE EXCEPTION 'distinct venue+category % (expected {N})', cnt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} d LEFT JOIN {URLMAP} u USING (skey) WHERE u.url IS NULL;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no source URL: %', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM {RJ} r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> {FILL} OR txt <> '{EXIST_MD5}' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected {FILL} / {EXIST_MD5})', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> {FILL} THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected {FILL})', cnt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
   WHERE r.cat <> 'Green Star' AND a.category IN ('Three Stars', 'Two Stars', 'One Star') AND a.category <> r.cat;
  IF cnt <> 0 THEN RAISE EXCEPTION 'venues with a different 2025 star row: %', cnt; END IF;
  SELECT md5(string_agg(id::text, ',' ORDER BY id)) INTO txt FROM awards WHERE id IN ({ex_list});
  IF txt <> '{EXIST_MD5}' THEN RAISE EXCEPTION 'existing id list md5 % (expected {EXIST_MD5})', txt; END IF;

  -- 2. Counts before (read {B['read_at']})
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> {B['awards']} OR num <> {B['awards_max']} THEN RAISE EXCEPTION 'awards before % / max % (expected {B['awards']} / {B['awards_max']})', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> {B['mich']} THEN RAISE EXCEPTION 'Michelin awards before % (expected {B['mich']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> {B['mich25']} THEN RAISE EXCEPTION 'Michelin 2025 before % (expected {B['mich25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> {B['mich25_nourl']} THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected {B['mich25_nourl']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> {B['gs25']} THEN RAISE EXCEPTION 'Green Star 2025 before % (expected {B['gs25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso = 'JP';
                                                IF cnt <> {B['jp25']} THEN RAISE EXCEPTION 'JP Michelin 2025 before % (expected {B['jp25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> {B['venues']} THEN RAISE EXCEPTION 'venues before % (expected {B['venues']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> {B['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {B['slugs']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> {B['cities']} THEN RAISE EXCEPTION 'cities before % (expected {B['cities']})', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> {B['vc_sum']} THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected {B['vc_sum']})', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {B['led_n']} OR led_max <> {B['led_max']} THEN RAISE EXCEPTION 'ledger before % / max % (expected {B['led_n']} / {B['led_max']})', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {B['aud_n']} OR aud_max <> {B['aud_max']} THEN RAISE EXCEPTION 'audit_log before % / max % (expected {B['aud_n']} / {B['aud_max']})', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = u.url
    FROM {RJ} r JOIN {URLMAP} u USING (skey)
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> {FILL} THEN RAISE EXCEPTION 'award rows updated % (expected {FILL})', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, u.url FROM {RJ} r JOIN {URLMAP} u USING (skey)
   WHERE NOT EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat)
   ORDER BY r.seq;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> {INS} THEN RAISE EXCEPTION 'award rows inserted % (expected {INS})', cnt; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', {N}, job_txt);
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', cnt; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO cnt FROM awards;         IF cnt <> {B['awards'] + INS} THEN RAISE EXCEPTION 'awards after % (expected {B['awards'] + INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> {B['mich'] + INS} THEN RAISE EXCEPTION 'Michelin awards after % (expected {B['mich'] + INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> {B['mich25'] + INS} THEN RAISE EXCEPTION 'Michelin 2025 after % (expected {B['mich25'] + INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> {B['mich25_nourl'] - FILL} THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected {B['mich25_nourl'] - FILL})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> {B['gs25'] + GS_NEW} THEN RAISE EXCEPTION 'Green Star 2025 after % (expected {B['gs25'] + GS_NEW})', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a JOIN {URLMAP} u ON u.url = a.source_url
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL
     GROUP BY a.category) g;
  IF cnt <> {N} OR txt <> '{by_cat_txt}'
    THEN RAISE EXCEPTION 'Japan Michelin 2025 with an archive URL % / % (expected {N} / {by_cat_txt})', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso = 'JP';
                                                IF cnt <> {B['jp25'] + INS} THEN RAISE EXCEPTION 'JP Michelin 2025 after % (expected {B['jp25'] + INS})', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM {RJ} r JOIN {URLMAP} u USING (skey) JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
     AND a.category = r.cat AND a.source_url = u.url;
  IF txt <> '{SEQVID_MD5}' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected {SEQVID_MD5})', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> {B['venues']} THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> {B['slugs']} THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> {B['cities']} THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> {B['vc_sum']} THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> {B['led_n'] + 1} THEN RAISE EXCEPTION 'ledger after % (expected {B['led_n'] + 1})', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = {N} AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> {N} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {N})', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' IN (SELECT url FROM {URLMAP} u);
  IF cnt <> {INS} THEN RAISE EXCEPTION 'audit INSERT rows % (expected {INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' IN (SELECT url FROM {URLMAP} u)
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> {FILL} THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected {FILL})', cnt; END IF;
END
$do$;
COMMIT;
"""
out = here.parent / "backfill-michelin-2025-japan.sql"
out.write_text(sql, encoding="utf-8")
print("wrote", out, "sha256", hashlib.sha256(sql.encode()).hexdigest(), "plan md5", PLAN_MD5, "fill", FILL, "insert", INS, by_cat_txt)
