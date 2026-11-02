"""Build the Spain (with Andorra) 2025 star backfill SQL from the relay and link map (no retyped rows).

Usage:
  python3 -I build_backfill_es_2025.py plan                         -> writes plan-query-es-2025.sql (read-only)
  python3 -I build_backfill_es_2025.py sql <seqvid_md5> <existing_ids_md5> <counts.json>
                                                                    -> writes ../backfill-michelin-2025-spain.sql
Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1" (N1 stars and Green Stars, no Bib; Q1 skip lines with no venue;
R1 source_url = archive id_ URL). Ben, Nov 1 19:35 ET "Y3, Z1, G1": Y3 check the 3 moved/renamed pairs against
the venue's own site first; Z1 use the 3 name-only pairs; G1 stars only (no full Spain 2025 Green Star list found).
Y lines are set by the Y switch below (Ben decides after the Y3 evidence).
"""
import hashlib, json, pathlib, sys

here = pathlib.Path(__file__).parent
relay = (here / "relay-es-2025-archive-20241130.txt").read_text(encoding="ascii")
links = (here / "links-es-2025-archive-20241130.txt").read_text(encoding="ascii")
RELAY_SHA = hashlib.sha256(relay.encode()).hexdigest()
LINKS_SHA = hashlib.sha256(links.encode()).hexdigest()
assert RELAY_SHA == "27850f82436de16518689cbcd617b08c5d4f0ea5f2b56bb945062853155faf67"
assert LINKS_SHA == "99ce36e453f63c917974df38f2b1d4aef250dfe9c50aedf72a3a8a98d8c574b6"

ARCH_S = ("https://web.archive.org/web/20241130022008id_/https://guide.michelin.com/es/es/articulo/"
          "michelin-guide-ceremony/todas-las-estrellas-de-la-guia-michelin-espana-2025")

# V1: the venue holds the 2025 star row now (no URL). The row gets the URL.
V1 = {187: "ve_dffad438e0", 189: "ve_a76b44705a", 255: "ve_5cb5124e0b"}
# Y (Y3 evidence): same restaurant moved or renamed; the venue holds the 2026 Michelin row under its new card.
Y_ALL = {37: "ve_b705060cf6", 150: "ve_c87595d42b", 158: "ve_4ecd793ec3"}
Y_SWITCH = "use"  # "use" = all 3 (recommended); "skip" = none
Y = Y_ALL if Y_SWITCH == "use" else {}
# Z1: name-only pairs used (closed venues, no Michelin row).
Z1 = {76: "ve_27266639a6", 93: "ve_6532e88951", 132: "ve_b1c292cecb"}
USE = {**V1, **Y, **Z1}
# Q1: no venue in the database.
SKIP_Q1 = [47, 88, 133, 172, 203, 214, 244, 262, 263, 289]
SKIP = sorted(SKIP_Q1 + ([] if Y else list(Y_ALL)))
assert len(set(SKIP)) == len(SKIP) and not (set(SKIP) & set(USE))
assert len(USE) == 3 + len(Y) + 3

slug_of, name_of = {}, {}
for ln in links.splitlines():
    seq, slug, path = ln.split("|")
    slug_of[int(seq)] = slug.lower()

def build_plan():
    plan = []
    for ln in relay.splitlines():
        seq, cat, city, name, mark = ln.split("|")
        seq = int(seq)
        name_of[seq] = name
        if seq in SKIP:
            continue
        plan.append([seq, cat, slug_of[seq], USE.get(seq, "")])
    return plan

def md5_plan(plan):
    return hashlib.md5("\n".join(f"{a}|{b}|{c}|{d}" for a, b, c, d in plan).encode("ascii")).hexdigest()

def dec(s):
    return s.encode("ascii").decode("unicode_escape")

RESOLVE = """WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/restaurante?/' AND c.country_iso IN ('ES', 'AD')),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how
        FROM p LEFT JOIN t1 USING (seq))"""

RJ = "(SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e)"

plan = build_plan()
PLAN_MD5 = md5_plan(plan)
N = len(plan)
assert N == 292 - len(SKIP)

if sys.argv[1] == "plan":
    lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
    res = RESOLVE.replace("jsonb_array_elements(pj)", f"jsonb_array_elements('{lit}'::jsonb)")
    q = f"""-- Spain 2025 plan query (read-only).
SELECT '{PLAN_MD5}' plan_md5, {N} n_plan, * FROM (
{res}
SELECT
  (SELECT string_agg(how || ':' || cnt, ',' ORDER BY how) FROM (SELECT how, count(*) cnt FROM r GROUP BY how) h) by_how,
  (SELECT md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq)) FROM r) seqvid_md5,
  (SELECT count(DISTINCT (vid, cat)) FROM r) distinct_vid_cat,
  (SELECT count(DISTINCT vid) FROM r) distinct_vid,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid JOIN cities c ON c.id = v.city_id WHERE c.country_iso IN ('ES', 'AD')) in_es_ad,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_n,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) existing_clean,
  (SELECT md5(string_agg(a.id::text, ',' ORDER BY a.id)) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids_md5,
  (SELECT string_agg(a.id::text, ',' ORDER BY a.id) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids,
  (SELECT string_agg(r.seq || '>' || a.id || ':' || a.category, ',' ORDER BY r.seq) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
     AND a.category <> r.cat AND a.category IN ('Three Stars', 'Two Stars', 'One Star')) star_conflicts,
  (SELECT string_agg(cat || ':' || cnt, ',' ORDER BY cat) FROM (SELECT cat, count(*) cnt FROM r GROUP BY cat) c) by_cat,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid WHERE v.status = 'closed') closed_venues
) q;
"""
    (here / "plan-query-es-2025.sql").write_text(q, encoding="ascii")
    print("plan md5", PLAN_MD5, "rows", N, "Y", Y_SWITCH)
    sys.exit()

# ---------------------------------------------------------------- sql mode
SEQVID_MD5, EXIST_MD5 = sys.argv[2], sys.argv[3]
B = json.loads((here / sys.argv[4]).read_text())  # counts before, read live
EXIST_IDS = [6331, 6335, 7867]
FILL = len(EXIST_IDS)
INS = N - FILL
by_cat = {}
for s, c, sl_, v in plan:
    by_cat[c] = by_cat.get(c, 0) + 1
by_cat_txt = ",".join(f"{k}:{by_cat[k]}" for k in sorted(by_cat))
plan_lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
fmt = lambda d: "; ".join(f"{k} -> {v}" for k, v in sorted(d.items())) or "none"
skip_txt = "; ".join(dec(name_of[s]) for s in sorted(SKIP))
n_card = N - len(USE)

job = ("backfill:michelin-2025-spain-archive | item 4 (Ben, Nov 1 15:50 ET \"N1, P2, Q1, R1, S1\"; 19:35 ET \"Y3, Z1, G1\"): "
       f"Michelin Guide Spain 2025 (with Andorra) stars from web.archive.org | {FILL} existing 2025 star rows get the source_url; "
       f"{INS} rows inserted ({by_cat_txt} in all {N}) | source_url = {ARCH_S} | "
       f"relay docs/es-2025-build/relay-es-2025-archive-20241130.txt sha256 {RELAY_SHA[:8]}...{RELAY_SHA[-6:]}; card links "
       f"links-es-2025-archive-20241130.txt sha256 {LINKS_SHA[:8]}...{LINKS_SHA[-6:]} | counts = article 292 starred (16/33/243, "
       f"One Star 242 Spain + 1 Andorra) | ceremony Murcia, Nov 26 2024 | match: card link = Michelin card of an existing award "
       f"row ({n_card}); venue id, 2025 row: {fmt(V1)}; Y moved/renamed (Michelin card or press evidence): {fmt(Y)}; "
       f"Z1 name-only: {fmt(Z1)} | Q1 skipped: {skip_txt} | G1: 2025 Green Stars not loaded (no full list found; "
       f"las-estrellas-verdes-2025-9-novedades lists 9 new only; selection page archived page 1 only) | "
       f"2025 Bibs: no full list (N1), no change | plan md5 {PLAN_MD5}")
job_lit = job.replace("'", "''")
ex_list = ",".join(map(str, EXIST_IDS))

sql = f"""-- CompassEats, Nov 1 2026. Item 4: Michelin Guide Spain 2025 (with Andorra) stars from the archive.
-- Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"; 19:35 ET "Y3, Z1, G1" (Y3 check 3 moved/renamed pairs; Z1 use the 3
--   name-only pairs; G1 stars only, no full Spain 2025 Green Star list). Y switch in this build: {Y_SWITCH}.
-- Source (read Nov 1 in the built-in browser; status 200; 0 redirects):
--   {ARCH_S}
--   (title "Todas las Estrellas de la Guia MICHELIN Espana 2025"; 292 starred = 16 / 33 / 243; ceremony Murcia, Nov 26 2024)
-- Relay sha256 {RELAY_SHA}; link map sha256 {LINKS_SHA}.
-- Built by docs/es-2025-build/build_backfill_es_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in ES / AD ('card'); else the venue id in the build script ('use').
--   Gates: plan md5 {PLAN_MD5}; seq:venue md5 {SEQVID_MD5}; existing 2025 row ids md5 {EXIST_MD5}.
-- Expected: awards UPDATE {FILL} (source_url) and INSERT {INS} (michelin, 2025); 1 ledger row; {N} audit rows (trigger).
--   awards {B['awards']:,} -> {B['awards'] + INS:,}. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  arch_s   text := '{ARCH_S}';
  plan_txt text := '{plan_lit}';
  job_txt  text := '{job_lit}';
  pj jsonb; rj jsonb;
  cnt int; num int; txt text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  pj := plan_txt::jsonb;

  -- 1. Plan guards
  SELECT md5(string_agg((e->>0) || '|' || (e->>1) || '|' || (e->>2) || '|' || (e->>3), E'\\n' ORDER BY (e->>0)::int)), count(*)
    INTO txt, cnt FROM jsonb_array_elements(pj) e;
  IF txt <> '{PLAN_MD5}' OR cnt <> {N} THEN RAISE EXCEPTION 'plan md5 % / rows % (expected {PLAN_MD5} / {N})', txt, cnt; END IF;

{RESOLVE}
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM {RJ} d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> '{SEQVID_MD5}' THEN RAISE EXCEPTION 'seq:venue md5 % (expected {SEQVID_MD5})', txt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso IN ('ES', 'AD');
  IF cnt <> {N} THEN RAISE EXCEPTION 'venues in ES/AD % (expected {N})', cnt; END IF;
  SELECT count(DISTINCT vid) INTO cnt FROM {RJ} d;
  IF cnt <> {N} THEN RAISE EXCEPTION 'distinct venues % (expected {N})', cnt; END IF;

  SELECT count(*), md5(string_agg(a.id::text, ',' ORDER BY a.id)) INTO cnt, txt FROM {RJ} r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
   WHERE a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  IF cnt <> {FILL} OR txt <> '{EXIST_MD5}' THEN RAISE EXCEPTION 'existing 2025 rows % / ids md5 % (expected {FILL} / {EXIST_MD5})', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat;
  IF cnt <> {FILL} THEN RAISE EXCEPTION 'all existing 2025 rows on the plan % (expected {FILL})', cnt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
   WHERE a.category IN ('Three Stars', 'Two Stars', 'One Star') AND a.category <> r.cat;
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
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('ES', 'AD');
                                                IF cnt <> {B['esad25']} THEN RAISE EXCEPTION 'ES/AD Michelin 2025 before % (expected {B['esad25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> {B['venues']} THEN RAISE EXCEPTION 'venues before % (expected {B['venues']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> {B['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {B['slugs']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> {B['cities']} THEN RAISE EXCEPTION 'cities before % (expected {B['cities']})', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> {B['vc_sum']} THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected {B['vc_sum']})', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {B['led_n']} OR led_max <> {B['led_max']} THEN RAISE EXCEPTION 'ledger before % / max % (expected {B['led_n']} / {B['led_max']})', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {B['aud_n']} OR aud_max <> {B['aud_max']} THEN RAISE EXCEPTION 'audit_log before % / max % (expected {B['aud_n']} / {B['aud_max']})', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = arch_s
    FROM {RJ} r
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> {FILL} THEN RAISE EXCEPTION 'award rows updated % (expected {FILL})', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, arch_s FROM {RJ} r
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
                                                IF cnt <> {B['gs25']} THEN RAISE EXCEPTION 'Green Star 2025 after % (expected {B['gs25']})', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL AND a.source_url = arch_s
     GROUP BY a.category) g;
  IF cnt <> {N} OR txt <> '{by_cat_txt}'
    THEN RAISE EXCEPTION 'Spain Michelin 2025 with the archive URL % / % (expected {N} / {by_cat_txt})', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('ES', 'AD');
                                                IF cnt <> {B['esad25'] + INS} THEN RAISE EXCEPTION 'ES/AD Michelin 2025 after % (expected {B['esad25'] + INS})', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM {RJ} r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url = arch_s;
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
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' = arch_s;
  IF cnt <> {INS} THEN RAISE EXCEPTION 'audit INSERT rows % (expected {INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = arch_s
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> {FILL} THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected {FILL})', cnt; END IF;
END
$do$;
COMMIT;
"""
out = here.parent / "backfill-michelin-2025-spain.sql"
out.write_text(sql, encoding="utf-8")
print("wrote", out, "sha256", hashlib.sha256(sql.encode()).hexdigest(), "plan md5", PLAN_MD5, "fill", FILL, "insert", INS, by_cat_txt)
