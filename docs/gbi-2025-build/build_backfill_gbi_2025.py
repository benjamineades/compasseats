"""Build the Great Britain & Ireland 2025 backfill SQL from the relay and link map (no retyped rows).

Usage:
  python3 -I build_backfill_gbi_2025.py plan                       -> writes plan-query-gbi-2025.sql (read-only)
  python3 -I build_backfill_gbi_2025.py sql <ask> <seqvid_md5> <existing_ids_md5> <counts.json>
                                                                  -> writes ../backfill-michelin-2025-great-britain-ireland.sql
  <ask> = "use" (Ben pairs the 6 name-only lines) or "skip" (Q1 skip for them).
Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1".
"""
import hashlib, json, pathlib, sys

here = pathlib.Path(__file__).parent
relay = (here / "relay-gbi-2025-archive-20250211.txt").read_text(encoding="ascii")
links = (here / "links-gbi-2025-archive-20250211.txt").read_text(encoding="ascii")
RELAY_SHA = hashlib.sha256(relay.encode()).hexdigest()
LINKS_SHA = hashlib.sha256(links.encode()).hexdigest()
assert RELAY_SHA == "003ae95ec6c1031f558f503be6f8d35f6f0d930bb10f2ee0e7991985b87536e0"
assert LINKS_SHA == "60d35e7df6077a30e0d5991bc96e29bea9d7a741e4994e9d8f0554030d80bdc1"

ARCH_S = ("https://web.archive.org/web/20250211084823id_/https://guide.michelin.com/gb/en/article/"
          "michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland")
ARCH_G = ("https://web.archive.org/web/20250211223426id_/https://guide.michelin.com/gb/en/article/"
          "michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new")

# Pairs not made by card link. Evidence: the venue already holds a Michelin row (2025 or 2026) under this name.
USE = {
    24: ("ve_11e25b87c1", "Kitchen Table = Kitchen Table, London (Michelin 2026 Two Stars, card kitchen-table)"),
    90: ("ve_b9d291ce2a", "Endo at The Rotunda = Endo at the Rotunda, London (closed; Michelin 2025 One Star, no URL)"),
    134: ("ve_3892089530", "Mark Poynton at Caistor Hall (closed; Michelin 2025 One Star, no URL)"),
    136: ("ve_d5ec6cac85", "Masons Arms = The Masons Arms, Knowstone (closed; Michelin 2025 One Star, no URL)"),
    173: ("ve_7cdb1751a2", "Simpsons = Simpsons Restaurant, Birmingham (closed; Michelin 2025 One Star, no URL)"),
    175: ("ve_653d7fb4a4", "SO|LA = SOLA, London (closed; Michelin 2025 One Star, no URL)"),
    179: ("ve_f98f790eff", "Sorrel, Dorking (closed; Michelin 2025 One Star, no URL)"),
    224: ("ve_60f0332fb7", "Coombeshead Farm, Lewannick (Michelin 2026 Green Star)"),
    232: ("ve_21f3f34844", "Jericho = Restaurant Jericho, Plungar (Michelin 2026 Green Star)"),
    248: ("ve_15b2f1594e", "Where The Light Gets In, Stockport (Michelin 2026 Green Star)"),
    251: ("ve_6875e82e76", "Inver = Inver Restaurant & Rooms, Cairndow (Strachur card) (Michelin 2026 Green Star)"),
    252: ("ve_16395a9c38", "ANNWN = Annwn, Narberth (Michelin 2026 Green Star)"),
}
# Name-only pairs: the venue holds no Michelin row. Ben decides (use or skip).
ASK = {
    26: ("ve_7b865a33b7", "Le Manoir aux Quat' Saisons (Two Stars) = 'Le Manoir aux Quat'Saisons, A Belmond Hotel, Oxfordshire', city Oxford"),
    233: ("ve_7b865a33b7", "Le Manoir aux Quat' Saisons (Green Star) = same venue"),
    109: ("ve_c905b58267", "Hjem, Wall = Restaurant Hjem, Wall"),
    131: ("ve_d8accd5787", "Lyle's, London = Lyle's, London (closed)"),
    188: ("ve_4789a4e337", "Taku, London = Taku, London"),
    244: ("ve_85eaf781c4", "Silo, London (Green Star) = Silo London (closed)"),
}
# Q1: no venue in the database (no card-link match, no name match). Skipped.
SKIP = {15: "Claude Bosi at Bibendum", 25: "La Dame de Pic London", 65: "Bridge Arms", 76: "Club Gascon",
        80: "Crocadon (One Star)", 86: "DOSA", 92: "Five Fields", 114: "Humo", 152: "Outlaw's New Road",
        221: "Angela's (GS)", 222: "Apricity (GS)", 225: "Crocadon (GS)", 226: "CULTURE (GS)",
        227: "Daylesford Organic Farm (GS)", 228: "Exmoor Forest Inn (GS)", 230: "Homestead Kitchen (GS)",
        235: "Marle (GS)", 237: "Native (GS)", 238: "Oak (GS)", 240: "Petersham Nurseries Cafe (GS)",
        246: "The Small Holding (GS)", 247: "Tillingham (GS)", 249: "Wild Shropshire (GS)", 253: "CHAPTERS (GS)",
        254: "Henry Robertson (GS)", 256: "Kai Restaurant (GS)"}
assert not (set(USE) & set(ASK)) and not (set(USE) & set(SKIP)) and not (set(ASK) & set(SKIP))

slug_of = {}
for ln in links.splitlines():
    seq, slug, path = ln.split("|")
    slug_of[int(seq)] = slug.lower()

def build_plan(ask_mode):
    plan = []
    for ln in relay.splitlines():
        seq, cat, city, name, mark = ln.split("|")
        seq = int(seq)
        if seq in SKIP or (seq in ASK and ask_mode == "skip"):
            continue
        vid = USE.get(seq, ASK.get(seq, ("", "")))[0] if (seq in USE or seq in ASK) else ""
        plan.append([seq, cat, slug_of[seq], vid])
    return plan

def md5_plan(plan):
    return hashlib.md5("\n".join(f"{a}|{b}|{c}|{d}" for a, b, c, d in plan).encode("ascii")).hexdigest()

RESOLVE = """WITH p AS (SELECT (e->>0)::int seq, e->>1 cat, e->>2 slug, nullif(e->>3, '') use_vid FROM jsonb_array_elements(pj) e),
  sl AS (SELECT DISTINCT lower(substring(split_part(a.source_url, '?', 1) from '/restaurant/([^/]+)/?$')) slug, a.venue_id
           FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
          WHERE a.source_id = 'michelin' AND a.source_url ~ '/restaurant/' AND c.country_iso IN ('GB', 'IE', 'JE')),
  t1 AS (SELECT p.seq, count(*) n, min(sl.venue_id) vid FROM p JOIN sl ON sl.slug = p.slug GROUP BY p.seq),
  r AS (SELECT p.seq, p.cat,
          CASE WHEN p.use_vid IS NOT NULL THEN p.use_vid WHEN t1.n = 1 THEN t1.vid END vid,
          CASE WHEN p.use_vid IS NOT NULL THEN 'use' WHEN t1.n = 1 THEN 'card' WHEN t1.n > 1 THEN 'multi' ELSE 'none' END how,
          CASE WHEN p.cat = 'Green Star' THEN 'G' ELSE 'S' END src
        FROM p LEFT JOIN t1 USING (seq))"""

RJ = "(SELECT (e->>0)::int seq, e->>1 cat, e->>2 vid, e->>3 how, e->>4 src FROM jsonb_array_elements(rj) e)"

if sys.argv[1] == "plan":
    blocks = []
    for mode in ("use", "skip"):
        plan = build_plan(mode)
        lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
        res = RESOLVE.replace("jsonb_array_elements(pj)", f"jsonb_array_elements('{lit}'::jsonb)")
        blocks.append(f"""SELECT '{mode}' ask, '{md5_plan(plan)}' plan_md5, {len(plan)} n_plan, * FROM (
{res}
SELECT
  (SELECT string_agg(how || ':' || cnt, ',' ORDER BY how) FROM (SELECT how, count(*) cnt FROM r GROUP BY how) h) by_how,
  (SELECT md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq)) FROM r) seqvid_md5,
  (SELECT count(DISTINCT (vid, cat)) FROM r) distinct_vid_cat,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_n,
  (SELECT count(*) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) existing_clean,
  (SELECT md5(string_agg(a.id::text, ',' ORDER BY a.id)) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_ids_md5,
  (SELECT string_agg(r.seq || '>' || a.id || ':' || coalesce(left(a.source_url, 30), 'null'), ',' ORDER BY r.seq) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat) existing_list,
  (SELECT string_agg(r.seq || '>' || a.id || ':' || a.category, ',' ORDER BY r.seq) FROM r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025
     AND a.category <> r.cat AND a.category IN ('Three Stars', 'Two Stars', 'One Star') AND r.cat <> 'Green Star') star_conflicts,
  (SELECT string_agg(cat || ':' || cnt, ',' ORDER BY cat) FROM (SELECT cat, count(*) cnt FROM r GROUP BY cat) c) by_cat,
  (SELECT count(*) FROM r JOIN venues v ON v.id = r.vid WHERE v.status = 'closed') closed_venues
) q""")
    q = "-- GB&I 2025 plan query (read-only), two modes for the 6 name-only lines.\n" + "\nUNION ALL\n".join(blocks) + ";\n"
    (here / "plan-query-gbi-2025.sql").write_text(q, encoding="ascii")
    for mode in ("use", "skip"):
        print(mode, "plan md5", md5_plan(build_plan(mode)), "rows", len(build_plan(mode)))
    sys.exit()

# ---------------------------------------------------------------- sql mode
ASK_MODE, SEQVID_MD5, EXIST_MD5 = sys.argv[2], sys.argv[3], sys.argv[4]
assert ASK_MODE in ("use", "skip")
B = json.loads((here / sys.argv[5]).read_text())  # counts before, read live
plan = build_plan(ASK_MODE)
PLAN_MD5 = md5_plan(plan)
N = len(plan)
EXIST_IDS = [6036, 4403, 5696, 4216, 6090, 4778]  # 2025 One Star rows, no URL (seq 90, 134, 136, 173, 175, 179)
FILL = len(EXIST_IDS)
INS = N - FILL
by_cat = {}
for s, c, sl_, v in plan:
    by_cat[c] = by_cat.get(c, 0) + 1
gs_n = by_cat.get("Green Star", 0)
star_n = N - gs_n
by_cat_txt = ",".join(f"{k}:{by_cat[k]}" for k in sorted(by_cat))
plan_lit = json.dumps(plan, ensure_ascii=True).replace("'", "''")
skipped = dict(SKIP)
if ASK_MODE == "skip":
    skipped.update({k: v[1] for k, v in ASK.items()})
use_txt = "; ".join(f"{k} -> {v[0]}" for k, v in sorted(USE.items()))
ask_txt = "; ".join(f"{k} -> {v[0]}" for k, v in sorted(ASK.items())) if ASK_MODE == "use" else "skipped"

job = ("backfill:michelin-2025-great-britain-ireland-archive | item 4 (Ben, Nov 1 15:50 ET \"N1, P2, Q1, R1, S1\"): "
       f"Michelin Guide Great Britain & Ireland 2025 stars and Green Stars from web.archive.org | {FILL} existing 2025 star rows "
       f"get the source_url; {INS} rows inserted ({by_cat_txt} in all {N}) | stars source_url = {ARCH_S} | Green Star source_url = "
       f"{ARCH_G} | relay docs/gbi-2025-build/relay-gbi-2025-archive-20250211.txt sha256 {RELAY_SHA[:8]}...{RELAY_SHA[-6:]}; "
       f"card links links-gbi-2025-archive-20250211.txt sha256 {LINKS_SHA[:8]}...{LINKS_SHA[-6:]} | counts = ceremony "
       "'at a Glance' 10/29/181/36 | match: card link = Michelin card of an existing award row (212); use by venue id: "
       f"{use_txt} | name-only pairs ({ASK_MODE}): {ask_txt} | Q1 skipped, no venue: " + "; ".join(skipped.values()) +
       " | 2025 Bibs: no full list (N1), no change | plan md5 " + PLAN_MD5)
job_lit = job.replace("'", "''")

RES = RESOLVE.replace(chr(10), chr(10) + "  ")
sql = f"""-- CompassEats, Nov 1 2026. Item 4: Michelin Guide Great Britain & Ireland 2025 stars and Green Stars from the archive.
-- Ben, Nov 1 15:50 ET "N1, P2, Q1, R1, S1": N1 stars and Green Star only (no Bib); R1 source_url = the archive id_ URL;
--   Q1 skip lines with no venue. Name-only pairs (6 lines): {ASK_MODE}.
-- Sources (read Nov 1 in the built-in browser; status 200; 0 redirects):
--   stars  {ARCH_S}
--          (title "Every MICHELIN-Star Restaurant in Great Britain & Ireland 2025"; 10 / 29 / 181)
--   green  {ARCH_G}
--          (title "5 New Green Stars for Great Britain & Ireland 2025"; full list 36)
--   Counts = the Feb 10, 2025 ceremony article "at a Glance": 10 / 29 / 181 / 36 Green Stars.
-- Relay sha256 {RELAY_SHA}; link map sha256 {LINKS_SHA}.
-- Built by docs/gbi-2025-build/build_backfill_gbi_2025.py (no retyped rows).
-- Venue match, inside this transaction: the line's Michelin card slug = the card slug of an existing Michelin award row of
--   exactly 1 venue in GB / IE / JE ('card'); else the venue id in the build script ('use').
--   Gates: plan md5 {PLAN_MD5}; seq:venue md5 {SEQVID_MD5}; existing 2025 row ids md5 {EXIST_MD5}.
-- Expected: awards UPDATE {FILL} (source_url) and INSERT {INS} (michelin, 2025); 1 ledger row; {N} audit rows (trigger).
--   awards {B['awards']:,} -> {B['awards'] + INS:,}. Venues, slugs, cities, listings and price do not change.
-- Dry run: send the DO block through the Read connector. All pre-checks run, then the block stops at the
--   first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  arch_s   text := '{ARCH_S}';
  arch_g   text := '{ARCH_G}';
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

  {RES}
  SELECT jsonb_agg(jsonb_build_array(seq, cat, vid, how, src) ORDER BY seq) INTO rj FROM r;

  SELECT count(*) FILTER (WHERE vid IS NULL), md5(string_agg(seq || ':' || coalesce(vid, '-'), ',' ORDER BY seq))
    INTO cnt, txt FROM {RJ} d;
  IF cnt <> 0 THEN RAISE EXCEPTION 'rows with no venue: %', cnt; END IF;
  IF txt <> '{SEQVID_MD5}' THEN RAISE EXCEPTION 'seq:venue md5 % (expected {SEQVID_MD5})', txt; END IF;
  SELECT count(*) INTO cnt FROM {RJ} d JOIN venues v ON v.id = d.vid JOIN cities c ON c.id = v.city_id
   WHERE c.country_iso IN ('GB', 'IE', 'JE');
  IF cnt <> {N} THEN RAISE EXCEPTION 'venues in GB/IE/JE % (expected {N})', cnt; END IF;
  SELECT count(DISTINCT (vid, cat)) INTO cnt FROM {RJ} d;
  IF cnt <> {N} THEN RAISE EXCEPTION 'distinct venue + category % (expected {N})', cnt; END IF;

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

  -- 2. Counts before (read Nov 1 20:59:53 UTC)
  SELECT count(*), max(id) INTO cnt, num FROM awards;
  IF cnt <> {B['awards']} OR num <> {B['awards_max']} THEN RAISE EXCEPTION 'awards before % / max % (expected {B['awards']} / {B['awards_max']})', cnt, num; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin';
                                                IF cnt <> {B['mich']} THEN RAISE EXCEPTION 'Michelin awards before % (expected {B['mich']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                IF cnt <> {B['m25']} THEN RAISE EXCEPTION 'Michelin 2025 before % (expected {B['m25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> {B['m25_nourl']} THEN RAISE EXCEPTION 'Michelin 2025 no URL before % (expected {B['m25_nourl']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> {B['gs25']} THEN RAISE EXCEPTION 'Green Star 2025 before % (expected {B['gs25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('GB', 'IE', 'JE');
                                                IF cnt <> {B['gbi25']} THEN RAISE EXCEPTION 'GB/IE/JE Michelin 2025 before % (expected {B['gbi25']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> {B['venues']} THEN RAISE EXCEPTION 'venues before % (expected {B['venues']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> {B['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {B['slugs']})', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> {B['cities']} THEN RAISE EXCEPTION 'cities before % (expected {B['cities']})', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> {B['vcsum']} THEN RAISE EXCEPTION 'cities.venues_count sum before % (expected {B['vcsum']})', cnt; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {B['led_n']} OR led_max <> {B['led_max']} THEN RAISE EXCEPTION 'ledger before % / max % (expected {B['led_n']} / {B['led_max']})', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {B['aud_n']} OR aud_max <> {B['aud_max']} THEN RAISE EXCEPTION 'audit_log before % / max % (expected {B['aud_n']} / {B['aud_max']})', aud_n, aud_max; END IF;

  -- 3. Write
  UPDATE awards a SET source_url = CASE WHEN r.src = 'G' THEN arch_g ELSE arch_s END
    FROM {RJ} r
   WHERE a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS cnt = ROW_COUNT; IF cnt <> {FILL} THEN RAISE EXCEPTION 'award rows updated % (expected {FILL})', cnt; END IF;

  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT r.vid, 'michelin', 2025, NULL, r.cat, NULL, CASE WHEN r.src = 'G' THEN arch_g ELSE arch_s END FROM {RJ} r
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
                                                IF cnt <> {B['m25'] + INS} THEN RAISE EXCEPTION 'Michelin 2025 after % (expected {B['m25'] + INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
                                                IF cnt <> {B['m25_nourl'] - FILL} THEN RAISE EXCEPTION 'Michelin 2025 no URL after % (expected {B['m25_nourl'] - FILL})', cnt; END IF;
  SELECT count(*) INTO cnt FROM awards WHERE source_id = 'michelin' AND year = 2025 AND category = 'Green Star';
                                                IF cnt <> {B['gs25'] + gs_n} THEN RAISE EXCEPTION 'Green Star 2025 after % (expected {B['gs25'] + gs_n})', cnt; END IF;
  SELECT string_agg(category || ':' || num_cat, ',' ORDER BY category), sum(num_cat) INTO txt, cnt FROM (
    SELECT a.category, count(*) num_cat FROM awards a
     WHERE a.source_id = 'michelin' AND a.year = 2025 AND a.rank IS NULL AND a.distinction IS NULL
       AND ((a.category = 'Green Star' AND a.source_url = arch_g) OR (a.category <> 'Green Star' AND a.source_url = arch_s))
     GROUP BY a.category) g;
  IF cnt <> {N} OR txt <> '{by_cat_txt}'
    THEN RAISE EXCEPTION 'GB&I Michelin 2025 with the archive URLs % / % (expected {N} / {by_cat_txt})', cnt, txt; END IF;
  SELECT count(*) INTO cnt FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE a.source_id = 'michelin' AND a.year = 2025 AND c.country_iso IN ('GB', 'IE', 'JE');
                                                IF cnt <> {B['gbi25'] + INS} THEN RAISE EXCEPTION 'GB/IE/JE Michelin 2025 after % (expected {B['gbi25'] + INS})', cnt; END IF;
  SELECT md5(string_agg(r.seq || ':' || a.venue_id, ',' ORDER BY r.seq)) INTO txt
    FROM {RJ} r JOIN awards a ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = r.cat
     AND a.source_url = CASE WHEN r.src = 'G' THEN arch_g ELSE arch_s END;
  IF txt <> '{SEQVID_MD5}' THEN RAISE EXCEPTION 'seq:venue md5 after % (expected {SEQVID_MD5})', txt; END IF;
  SELECT count(*) INTO cnt FROM venues;         IF cnt <> {B['venues']} THEN RAISE EXCEPTION 'venues changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM slugs;          IF cnt <> {B['slugs']} THEN RAISE EXCEPTION 'slugs changed: %', cnt; END IF;
  SELECT count(*) INTO cnt FROM cities;         IF cnt <> {B['cities']} THEN RAISE EXCEPTION 'cities changed: %', cnt; END IF;
  SELECT sum(venues_count) INTO cnt FROM cities; IF cnt <> {B['vcsum']} THEN RAISE EXCEPTION 'cities.venues_count sum changed: %', cnt; END IF;

  SELECT count(*) INTO cnt FROM source_capture_ledger;
  IF cnt <> {B['led_n'] + 1} THEN RAISE EXCEPTION 'ledger after % (expected {B['led_n'] + 1})', cnt; END IF;
  SELECT count(*) INTO cnt FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = {N} AND job = job_txt;
  IF cnt <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO cnt FROM audit_log WHERE id > aud_max;
  IF cnt <> {N} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {N})', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND al.old_row IS NULL
     AND a.source_id = 'michelin' AND a.year = 2025 AND al.new_row->>'source_url' IN (arch_s, arch_g);
  IF cnt <> {INS} THEN RAISE EXCEPTION 'audit INSERT rows % (expected {INS})', cnt; END IF;
  SELECT count(*) INTO cnt FROM audit_log al
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE'
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' IN (arch_s, arch_g)
     AND (al.old_row - 'source_url') = (al.new_row - 'source_url');
  IF cnt <> {FILL} THEN RAISE EXCEPTION 'audit UPDATE rows (source_url only) % (expected {FILL})', cnt; END IF;
END
$do$;
COMMIT;
"""
out = here.parent / "backfill-michelin-2025-great-britain-ireland.sql"
out.write_text(sql, encoding="ascii")
print("mode", ASK_MODE, "plan md5", PLAN_MD5, "rows", N, "fill", FILL, "insert", INS, by_cat_txt,
      "sha256", hashlib.sha256(sql.encode()).hexdigest(), "lines", sql.count("\n"))
