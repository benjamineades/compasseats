"""Build the Italy 2025 star backfill SQL from the relay (no retyped rows).

Usage:
  python3 -I build_backfill_it_2025.py plan                         -> writes plan-query-it-2025.sql (read-only)
  python3 -I build_backfill_it_2025.py sql <seqvid_md5> <existing_ids_md5> <counts.json>
                                                                    -> writes ../backfill-michelin-2025-italy.sql
Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1" (N1 stars and Green Stars, no Bib; Q1 skip lines with no venue;
R1 source_url = archive id_ URL). Ben, Nov 2 05:44 ET "Z2, H2, G1": Z2 check the 5 name-only pairs against the venue's
own site first; H2 examine both San Martino Michelin cards first; G1 stars only (no full Italy 2025 Green Star list).
Switches below hold the choices after the Z2 / H2 evidence (Ben decides).
"""
import hashlib, json, pathlib, sys

here = pathlib.Path(__file__).parent
relay = (here / "relay-it-2025-archive-20241105.txt").read_text(encoding="ascii")
RELAY_SHA = hashlib.sha256(relay.encode()).hexdigest()
assert RELAY_SHA == "d5c2a9ebda5f251167ad8460c457a30ca133cd2ff4c0747e9f128f1a29b25b39", RELAY_SHA

ARCH_S = ("https://web.archive.org/web/20241105213726id_/https://guide.michelin.com/it/it/notizia/"
          "michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia")
CAT = {"3": "Three Stars", "2": "Two Stars", "1": "One Star"}

# V1: the venue holds the 2025 star row now (no URL). The row gets the URL.
V1 = {293: "ve_df6d5db906", 330: "ve_48fe5153e8"}            # Octavin (3729), Atman (8939)
# N: name pairs; the venue holds a 2026 Michelin card in the same town (renamed card or broken article link).
NP = {214: "ve_62d9bf3a36",                                   # Osteria degli Assonica -> card 'assonica', Sorisole
      391: "ve_b24b1c1085",                                   # Il Desco (article link points to Wisteria) -> card 'il-desco'
      392: "ve_acdfd2daf5"}                                   # Iris Ristorante (article link points to Wisteria)
# Z (Z2 evidence): name-only pairs, venue has no Michelin row.
Z_SITE = {169: "ve_13f18c5fed",   # Balzi Rossi: own site (capture Sep 9 2026) + card via Balzi Rossi 2, Ventimiglia
          183: "ve_e16ffafc83",   # Lido 84: own site (Jul 13 2026) Gardone Riviera; card corso Zanardelli 196, Fasano del Garda
          355: "ve_c61d257fcf",   # Zum Loewen: own site (Sep 9 2026) Tisens; card via Tirolo 25, Tisens
          356: "ve_bcb1504177"}   # Casa Vissani: own site address = card address (S.S. 448 km 6.600, Baschi)
Z_PRESS = {97: "ve_48a3d8cc5d"}   # Contaminazioni: no own site; Scatti di Gusto Mar 17 2026 (Molaro, Somma Vesuviana)
C_SWITCH = "use"                   # "use" = pair Contaminazioni (recommended); "skip" = Q1 skip
Z = {**Z_SITE, **(Z_PRESS if C_SWITCH == "use" else {})}
# H (H2 evidence): Michelin 2026 lists both San Martino (Treviglio) and San Martino (Scorze). The database has only the
# Scorze venue ve_74d392b2d5, and its 2026 row holds the Treviglio card URL. Line 385 (Scorze) pairs by name + town.
# Line 218 (Treviglio) has no venue: skip; the card match would put it on the Scorze venue.
H_SWITCH = "a"                     # "a" = 385 -> ve_74d392b2d5, 218 skip (recommended); "hold" = skip both
H = {385: "ve_74d392b2d5"} if H_SWITCH == "a" else {}
USE = {**V1, **NP, **Z, **H}
# Q1: no venue in the database (393 Matteo Grandi in Basilica: article link points to Wisteria, no venue).
SKIP_Q1 = [57, 59, 61, 85, 91, 94, 104, 124, 157, 165, 194, 203, 208, 226, 252, 261, 264, 283, 294, 316, 323,
           360, 375, 388, 393]
SKIP_H = [218] + ([] if H else [385])
SKIP = sorted(SKIP_Q1 + SKIP_H + ([] if C_SWITCH == "use" else [97]))
assert len(SKIP_Q1) == 25 and len(set(SKIP)) == len(SKIP) and not (set(SKIP) & set(USE))

rows, name_of = [], {}
for ln in relay.splitlines()[1:]:
    n, stars, region, city, name, new, moved, path = ln.split("|")
    rows.append((int(n), CAT[stars], path.rsplit("/ristorante/", 1)[1].lower()))
    name_of[int(n)] = name
assert len(rows) == 393

def build_plan():
    return [[s, c, sl, USE.get(s, "")] for s, c, sl in rows if s not in SKIP]

def md5_plan(plan):
    return hashlib.md5("\n".join(f"{a}|{b}|{c}|{d}" for a, b, c, d in plan).encode("ascii")).hexdigest()

def dec(s):
    return s.encode("ascii").decode("unicode_escape")

RESOLVE = """WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(a.source_url from '/(?:restaurant|restaurante|ristorante)/([^/?#]+)')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/(restaurant|restaurante|ristorante)/' AND c.country_iso IN ('IT', 'SM')),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how
        FROM p LEFT JOIN t1 USING (seq))"""

RJ = "(SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how FROM jsonb_array_elements(rj) e)"

plan = build_plan()
PLAN_MD5 = md5_plan(plan)
N = len(plan)
assert N == 393 - len(SKIP)

if sys.argv[1] == "plan":
    lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
    res = RESOLVE.replace("jsonb_array_elements(pj)", f"jsonb_array_elements('{lit}'::jsonb)")
    q = f"""-- Italy 2025 plan query (read-only).
SELECT '{PLAN_MD5}' plan_md5, {N} n_plan, * FROM (
{res}
SELECT
  (SELECT string_agg(how || ':' || cnt, ',' ORDER BY how) FROM (SELECT how, count(*) cnt FROM r GROUP BY how) h) by_how,
  (SELECT md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq)) FROM r) seqvid_md5,
  (SELECT count(DISTINCT (vid, cat)) FROM r) distinct_vid_cat,
  (SELECT count(DISTINCT vid) FROM r) distinct_vid,
  (SELECT string_agg(vid, ',') FROM (SELECT vid FROM r GROUP BY vid HAVING count(*) > 1) d) dup_vids,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid JOIN cities c ON c.id = v.city_id WHERE c.country_iso IN ('IT', 'SM')) in_it_sm,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_n,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) existing_clean,
  (SELECT md5(string_agg(a.id::text, ',' ORDER BY a.id)) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids_md5,
  (SELECT string_agg(a.id::text, ',' ORDER BY a.id) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids,
  (SELECT string_agg(r.seq || '>' || a.id || ':' || a.category, ',' ORDER BY r.seq) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
     AND a.category <> r.cat AND a.category IN ('Three Stars', 'Two Stars', 'One Star')) star_conflicts,
  (SELECT string_agg(cat || ':' || cnt, ',' ORDER BY cat) FROM (SELECT cat, count(*) cnt FROM r GROUP BY cat) c) by_cat,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid WHERE v.status = 'closed') closed_venues,
  (SELECT string_agg(r.seq || ':' || v.name, '; ' ORDER BY r.seq) FROM r JOIN venues v ON v.id = r.vid WHERE r.how = 'use') use_names
) q;
"""
    (here / "plan-query-it-2025.sql").write_text(q, encoding="ascii")
    print("plan md5", PLAN_MD5, "rows", N, "C", C_SWITCH, "H", H_SWITCH, "skip", len(SKIP))
    sys.exit()

# ---------------------------------------------------------------- sql mode
SEQVID_MD5, EXIST_MD5 = sys.argv[2], sys.argv[3]
B = json.loads((here / sys.argv[4]).read_text())  # counts before, read live
EXIST_IDS = [3729, 8939]
FILL = len(EXIST_IDS)
INS = N - FILL
by_cat = {}
for s, c, sl_, v in plan:
    by_cat[c] = by_cat.get(c, 0) + 1
by_cat_txt = ",".join(f"{k}:{by_cat[k]}" for k in sorted(by_cat))
plan_lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
fmt = lambda d: "; ".join(f"{k} -> {v}" for k, v in sorted(d.items())) or "none"
skip_q1_txt = "; ".join(dec(name_of[s]) for s in sorted(SKIP_Q1 + ([] if C_SWITCH == "use" else [97])))
n_card = N - len(USE)

job = ("backfill:michelin-2025-italy-archive | item 4 (Ben, Nov 1 15:50 ET \"N1, P2, Q1, R1, S1\"; Nov 2 05:44 ET \"Z2, H2, G1\"): "
       f"Michelin Guide Italy 2025 stars from web.archive.org | {FILL} existing 2025 star rows get the source_url; "
       f"{INS} rows inserted ({by_cat_txt} in all {N}) | source_url = {ARCH_S} | "
       f"relay docs/it-2025-build/relay-it-2025-archive-20241105.txt sha256 {RELAY_SHA[:8]}...{RELAY_SHA[-6:]} | "
       f"counts = article 393 starred (14/38/341) = ceremony article total 393 | ceremony Parma, Nov 5 2024 | "
       f"match: card link = Michelin card of an existing award row ({n_card}); venue id, 2025 row: {fmt(V1)}; "
       f"name pair, 2026 card same town: {fmt(NP)} (391, 392: article links point to the Wisteria card); "
       f"Z2 name-only (own site or press): {fmt(Z)}; H2: {fmt(H)} (San Martino Scorze; Michelin 2026 lists Scorze and "
       f"Treviglio; 218 Treviglio skipped, no venue; the Scorze venue 2026 row holds the Treviglio card) | "
       f"Q1 skipped: {skip_q1_txt} | G1: 2025 Green Stars not loaded (total 69; guida-michelin-italia-2025-11-nuove-stelle-verdi "
       f"lists 11 new only; selection page archived page 1 only, 48 of 68) | 2025 Bibs: no full list (N1), no change | "
       f"plan md5 {PLAN_MD5}")
job_lit = job.replace("'", "''")
ex_list = ",".join(map(str, EXIST_IDS))

sql = f"""-- CompassEats, Nov 2 2026. Item 4: Michelin Guide Italy 2025 stars from the archive.
-- Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1"; Nov 2 05:44 ET "Z2, H2, G1" (Z2 check 5 name-only pairs against the venue's
--   own site; H2 examine both San Martino cards; G1 stars only, no full Italy 2025 Green Star list).
--   Switches in this build: Contaminazioni {C_SWITCH}; San Martino {H_SWITCH}.
-- Source (read Nov 1 in the built-in browser; status 200; 0 redirects):
--   {ARCH_S}
--   (title "Tutte le stelle della Guida MICHELIN Italia 2025!"; 393 starred = 14 / 38 / 341; ceremony Parma, Nov 5 2024)
-- Relay sha256 {RELAY_SHA}.
-- Built by docs/it-2025-build/build_backfill_it_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in IT / SM ('card'); else the venue id in the build script ('use').
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
   WHERE c.country_iso IN ('IT', 'SM');
  IF cnt <> {N} THEN RAISE EXCEPTION 'venues in IT/SM % (expected {N})', cnt; END IF;
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
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('IT', 'SM');
                                                IF cnt <> {B['itsm25']} THEN RAISE EXCEPTION 'IT/SM Michelin 2025 before % (expected {B['itsm25']})', cnt; END IF;
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
    THEN RAISE EXCEPTION 'Italy Michelin 2025 with the archive URL % / % (expected {N} / {by_cat_txt})', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('IT', 'SM');
                                                IF cnt <> {B['itsm25'] + INS} THEN RAISE EXCEPTION 'IT/SM Michelin 2025 after % (expected {B['itsm25'] + INS})', cnt; END IF;
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
out = here.parent / "backfill-michelin-2025-italy.sql"
out.write_text(sql, encoding="utf-8")
print("wrote", out, "sha256", hashlib.sha256(sql.encode()).hexdigest(), "plan md5", PLAN_MD5, "fill", FILL, "insert", INS, by_cat_txt)
