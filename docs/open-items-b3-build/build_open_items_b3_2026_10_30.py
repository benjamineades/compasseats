#!/usr/bin/env python3
"""Build the SQL files of open items block 3 (Oct 30, 2026, Atlanta).

Ben: Oct 30 23:05 ET "Let's do your recommendation" (items 1, 2 and 3 of the b2 handoff list);
23:11 ET "All recommended" (D1 = A merge, D2 = A fix 12 slugs, D3 = B Heritage 2023 + 2024, D4 = A two files).

Inputs (this folder; each relay md5 was matched against a live read of the database before the build):
  relay-slugs.txt     venue_id|city_slug|old_slug|new_slug             (12 lines, by venue_id)
  relay-heritage.txt  ins|venue_id|year|category|archive card URL      (4 lines)
  relay-merge.txt     award|id|from|to|year|category|url, slug|..., label|id|venue|-|column|label|publisher (5 lines)
Outputs:
  ../slugs-heritage-open-items-b3-2026-10-30.sql   file 1, Write connector (INSERT/UPDATE only)
  ../merge-istanbul-turk-2026-10-30.sql            file 2, Supabase SQL Editor (holds DELETE); expects file 1 done
  merge-test-current-counts.sql                    file 2 with today's counts, for the dry run before file 1 runs
"""
import hashlib
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
DOCS = HERE.parent


def relay(name):
    txt = (HERE / name).read_text(encoding="utf-8").rstrip("\n")
    return txt, [l.split("|") for l in txt.split("\n")], hashlib.sha256(txt.encode()).hexdigest(), \
        hashlib.md5(txt.encode()).hexdigest()


def q(s):
    return "'" + s.replace("'", "''") + "'"


ts, rs, sha_s, md5_s = relay("relay-slugs.txt")
th, rh, sha_h, md5_h = relay("relay-heritage.txt")
tm, rm, sha_m, md5_m = relay("relay-merge.txt")

# ---- input checks
assert len(rs) == 12 and [r[0] for r in rs] == sorted(r[0] for r in rs) and len({r[0] for r in rs}) == 12
for vid, city, old, new in rs:
    assert vid.startswith("ve_") and len(vid) == 13 and old != new and new.startswith(old[:3])
assert md5_s == "18352be533faa463b7b29eeb7c1d7e44"  # = live read Oct 31 03:2x UTC (rule of the live name)
assert len(rh) == 4 and all(r[0] == "ins" and r[1] == "ve_95d87f1674" for r in rh)
assert sorted((r[2], r[3]) for r in rh) == [("2023", "Green Star"), ("2023", "One Star"),
                                            ("2024", "Green Star"), ("2024", "One Star")]
for r in rh:
    assert r[4].startswith("https://web.archive.org/web/" + {"2023": "20240206061227", "2024": "20240913163626"}[r[2]]
                           + "id_/https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790")
aw = [r for r in rm if r[0] == "award"]
sl = [r for r in rm if r[0] == "slug"]
lb = [r for r in rm if r[0] == "label"]
assert (len(aw), len(sl), len(lb)) == (2, 1, 2)
assert hashlib.md5("\n".join("|".join(r) for r in aw).encode()).hexdigest() == "918b15c84a13c43375ee177b5546178b"
assert hashlib.md5("\n".join("|".join(r) for r in lb).encode()).hexdigest() == "d29466f94a908c94c457e8a2ff75f8e8"

HELD, TURK = "ve_a19227e5fa", "ve_9852cbf26e"
PDF = "https://thebestchefawards.com/wp-content/uploads/2024/11/List-2024_The-Best-Chef-Awards.pdf"
CARD = "https://guide.michelin.com/us/en/california/long-beach/restaurant/heritage-1196790"
RULE = "trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))"

# ---- live state read Oct 31, 2026 03:05 UTC (whole tables)
NOW = dict(awards=23358, slugs=12924, canon=11304, noncanon=1620, venues=11304, active=10935, listings=11304,
           labels=24005, ledger=169, audit_max=119041, audit_n=113757)
F1_AUDIT = 12 + 12 + 4
AFTER1 = dict(NOW, awards=NOW["awards"] + 4, slugs=NOW["slugs"] + 12, noncanon=NOW["noncanon"] + 12,
              ledger=NOW["ledger"] + 1, audit_max=NOW["audit_max"] + F1_AUDIT, audit_n=NOW["audit_n"] + F1_AUDIT)
F2_AUDIT = 2 + 1 + 2 + 1 + 1

# ================================================================== file 1
F1 = f"""-- slugs-heritage-open-items-b3-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 3, file 1 of 2. Run through the Write connector.
-- Ben: Oct 30 23:05 ET "Let's do your recommendation" (items 1-3); 23:11 ET "All recommended"
--   (D2 = A: fix the 12 slugs; D3 = B: Heritage 2023 and 2024; D4 = A: two files).
--
-- Part S, 12 slugs that dropped the Turkish letter "ı" (old slug rule). The live slug rule
--   {RULE}
--   gives "i". For each venue: the old canonical slug becomes non-canonical (the old URL keeps working), and the
--   slug rule of the live name is inserted as canonical. Names do not change. No new slug is in use or in redirects.
--   Relay relay-slugs.txt md5 {md5_s} = md5 of the live read (venue_id|city_slug|canonical slug|rule of name).
-- Part H, Heritage (Long Beach) ve_95d87f1674, Michelin history rows (the database had 2025 and 2026 only):
--   archive card Feb 6, 2024 (meta "One Star ... in the 2023 MICHELIN Guide USA"; classification One Star +
--     MICHELIN Green Star) -> 2023 One Star, 2023 Green Star;
--   archive card Sep 13, 2024 (meta "One Star ... in the 2024 MICHELIN Guide USA"; dLayer distinction 1 star,
--     greenstar True) -> 2024 One Star, 2024 Green Star. The May 4, 2025 card also gives dateAwarded 2024.
--   source_url = archive card URL (web.archive.org/web/<time>id_/ form). Ledger {NOW['ledger'] + 1} (michelin, award, 4).
--   Relay relay-heritage.txt md5 {md5_h}.
-- Audit rows {NOW['audit_max'] + 1:,}-{AFTER1['audit_max']:,} ({F1_AUDIT}): slugs UPDATE 12, slugs INSERT 12, awards INSERT 4.
-- After: awards {AFTER1['awards']:,}; slugs {AFTER1['slugs']:,} (canonical {AFTER1['canon']:,}, non-canonical {AFTER1['noncanon']:,}).
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $do$
DECLARE
  rel_s text := $r${ts}$r$;
  rel_h text := $r${th}$r$;
  v_n int;
  v_lid bigint;
  v_txt text;
BEGIN
  -- 1. relays and live state
  IF md5(rel_s) <> '{md5_s}' OR encode(sha256(convert_to(rel_s, 'UTF8')), 'hex') <> '{sha_s}'
    THEN RAISE EXCEPTION 'slug relay hash'; END IF;
  IF md5(rel_h) <> '{md5_h}' OR encode(sha256(convert_to(rel_h, 'UTF8')), 'hex') <> '{sha_h}'
    THEN RAISE EXCEPTION 'heritage relay hash'; END IF;
  IF (SELECT count(*) FROM awards) <> {NOW['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {NOW['slugs']} THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {NOW['noncanon']} THEN RAISE EXCEPTION 'non-canonical before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {NOW['ledger']} THEN RAISE EXCEPTION 'ledger max before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {NOW['audit_max']} OR (SELECT count(*) FROM audit_log) <> {NOW['audit_n']}
    THEN RAISE EXCEPTION 'audit_log before'; END IF;
  IF EXISTS (SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical GROUP BY venue_id HAVING count(*) <> 1)
    THEN RAISE EXCEPTION 'canonical slugs before'; END IF;

  -- 2. slug pre-checks: the live read gives the relay exactly (old = canonical now, new = rule of the live name)
  SELECT md5(string_agg(v.id||'|'||s.city_slug||'|'||s.slug||'|'||{RULE}, E'\\n' ORDER BY v.id))
    INTO v_txt
    FROM venues v JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
   WHERE v.id IN (SELECT split_part(l, '|', 1) FROM regexp_split_to_table(rel_s, E'\\n') AS l);
  IF v_txt IS DISTINCT FROM '{md5_s}' THEN RAISE EXCEPTION 'live slug read %', v_txt; END IF;
  IF EXISTS (SELECT 1 FROM slugs s JOIN regexp_split_to_table(rel_s, E'\\n') AS l
               ON s.property_id = 'eats' AND s.city_slug = split_part(l, '|', 2) AND s.slug = split_part(l, '|', 4))
    THEN RAISE EXCEPTION 'a new slug is in use'; END IF;
  IF EXISTS (SELECT 1 FROM redirects d JOIN regexp_split_to_table(rel_s, E'\\n') AS l
               ON d.from_path IN ('/'||split_part(l, '|', 2)||'/'||split_part(l, '|', 4),
                                  '/venue/'||split_part(l, '|', 2)||'/'||split_part(l, '|', 4)))
    THEN RAISE EXCEPTION 'a new path is in redirects'; END IF;

  -- 3. Heritage pre-checks
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_95d87f1674' AND name = 'Heritage' AND status = 'active')
    THEN RAISE EXCEPTION 'Heritage venue'; END IF;
  SELECT string_agg(year||' '||category, ', ' ORDER BY year, category) INTO v_txt
    FROM awards WHERE venue_id = 've_95d87f1674' AND source_id = 'michelin';
  IF v_txt IS DISTINCT FROM '2025 Green Star, 2025 One Star, 2026 Green Star, 2026 One Star'
    THEN RAISE EXCEPTION 'Heritage rows before: %', v_txt; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN
               (SELECT split_part(l, '|', 5) FROM regexp_split_to_table(rel_h, E'\\n') AS l))
    THEN RAISE EXCEPTION 'an archive URL is in use'; END IF;

  -- 4. slug writes (old first, so a venue never has 2 canonical rows)
  UPDATE slugs s SET is_canonical = false
    FROM regexp_split_to_table(rel_s, E'\\n') AS l
   WHERE s.property_id = 'eats' AND s.venue_id = split_part(l, '|', 1) AND s.city_slug = split_part(l, '|', 2)
     AND s.slug = split_part(l, '|', 3) AND s.is_canonical;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 12 THEN RAISE EXCEPTION 'old slugs set non-canonical: %', v_n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', split_part(l, '|', 2), split_part(l, '|', 4), split_part(l, '|', 1), true
    FROM regexp_split_to_table(rel_s, E'\\n') AS l;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 12 THEN RAISE EXCEPTION 'new canonical slugs inserted: %', v_n; END IF;

  -- 5. Heritage history rows
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT split_part(l, '|', 2), 'michelin', split_part(l, '|', 3)::int, NULL, split_part(l, '|', 4), NULL,
         split_part(l, '|', 5)
    FROM regexp_split_to_table(rel_h, E'\\n') AS l
   WHERE split_part(l, '|', 1) = 'ins';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 4 THEN RAISE EXCEPTION 'award rows inserted: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 4,
          'history-backfill:slugs-heritage-open-items-b3-2026-10-30 | Heritage (Long Beach) ve_95d87f1674: 2023 One Star + '
          || 'Green Star (archive card Feb 6, 2024, meta "2023 MICHELIN Guide USA"); 2024 One Star + Green Star (archive card '
          || 'Sep 13, 2024, meta "2024 MICHELIN Guide USA", greenstar True) | source_url = archive card URL | Ben "All '
          || 'recommended" Oct 30 23:11 ET (D3 = B) | relay md5 {md5_h}')
  RETURNING id INTO v_lid;

  -- 6. post-checks
  IF v_lid <> {AFTER1['ledger']} OR (SELECT max(id) FROM source_capture_ledger) <> {AFTER1['ledger']} THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM awards) <> {AFTER1['awards']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {AFTER1['slugs']} THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {AFTER1['noncanon']} THEN RAISE EXCEPTION 'non-canonical after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE is_canonical) <> {AFTER1['canon']} THEN RAISE EXCEPTION 'canonical after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
              GROUP BY v.id HAVING count(s.slug) <> 1)
    THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM regexp_split_to_table(rel_s, E'\\n') AS l
        JOIN slugs n ON n.property_id = 'eats' AND n.venue_id = split_part(l, '|', 1) AND n.city_slug = split_part(l, '|', 2)
                    AND n.slug = split_part(l, '|', 4) AND n.is_canonical
        JOIN slugs o ON o.property_id = 'eats' AND o.venue_id = split_part(l, '|', 1) AND o.city_slug = split_part(l, '|', 2)
                    AND o.slug = split_part(l, '|', 3) AND NOT o.is_canonical) <> 12
    THEN RAISE EXCEPTION 'slug pairs after'; END IF;
  SELECT string_agg(year||' '||category||' '||coalesce(substr(source_url, 29, 14), '-'), ', ' ORDER BY year, category) INTO v_txt
    FROM awards WHERE venue_id = 've_95d87f1674' AND source_id = 'michelin' AND year IN (2023, 2024);
  IF v_txt IS DISTINCT FROM '2023 Green Star 20240206061227, 2023 One Star 20240206061227, 2024 Green Star 20240913163626, 2024 One Star 20240913163626'
    THEN RAISE EXCEPTION 'Heritage rows after: %', v_txt; END IF;
  IF (SELECT max(id) FROM audit_log) <> {AFTER1['audit_max']} OR (SELECT count(*) FROM audit_log WHERE id > {NOW['audit_max']}) <> {F1_AUDIT}
    THEN RAISE EXCEPTION 'audit range after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {NOW['audit_max']} AND table_name = 'slugs' AND action = 'UPDATE') <> 12
     OR (SELECT count(*) FROM audit_log WHERE id > {NOW['audit_max']} AND table_name = 'slugs' AND action = 'INSERT') <> 12
     OR (SELECT count(*) FROM audit_log WHERE id > {NOW['audit_max']} AND table_name = 'awards' AND action = 'INSERT'
           AND row_pk IN (SELECT id::text FROM awards WHERE venue_id = 've_95d87f1674' AND year IN (2023, 2024))) <> 4
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
"""


# ================================================================== file 2
def f2(pre, name, test):
    post = dict(pre, venues=pre["venues"] - 1, active=pre["active"] - 1, listings=pre["listings"] - 1,
                labels=pre["labels"] - 2, canon=pre["canon"] - 1, noncanon=pre["noncanon"] + 1, ledger=pre["ledger"] + 1,
                audit_max=pre["audit_max"] + F2_AUDIT, audit_n=pre["audit_n"] + F2_AUDIT)
    head = ("-- TEST COPY for the dry run only (today's counts, before file 1). Do not run this copy.\n" if test else "")
    return post, head + f"""-- {name}
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 3, file 2 of 2. It holds DELETE: run it in the Supabase SQL Editor
--   (SQL Editor -> New query -> paste the whole file -> Run). Run it only after file 1
--   (slugs-heritage-open-items-b3-2026-10-30.sql); the guards stop it otherwise.
-- Ben: Oct 30 23:11 ET "All recommended" (D1 = A: merge; D4 = A: this file in the SQL Editor).
--
-- Problem: venue {HELD} "Istanbul" (city Istanbul, slug istanbul/istanbul) holds only Best Chef Awards rows
--   15879 (2024, 1-Knife) and 15878 (2025, 1-Knife). The legacy load resolved the restaurant to the city centre
--   ("Istanbul, Istanbul, Turkiye"), so the restaurant name was lost.
-- Evidence: The Best Chef Awards 2024 list (PDF, {PDF})
--   has 4 Turkey entries: Neolokal (2 knives), Macakizi, Apartiman Yenikoy, Fatih Tutak "TURK FATIH TUTAK" Istanbul (1 knife).
--   The database has 4 Turkey rows for 2024: Neolokal, Macakizi, Apartiman Yenikoy and "Istanbul". The Best Chef page of
--   Fatih Tutak (https://thebestchefawards.com/chefs/fatih-tutak/, read Oct 31) gives restaurant TURK, one knife.
--   TURK is {TURK} "Turk Fatih Tutak" (Istanbul; Michelin 2026 Two Stars, La Liste 2026, OAD 2025) with 0 Best Chef rows.
-- What this file does (one transaction):
--   awards 15879 and 15878: venue_id -> {TURK}; 15879 source_url NULL -> the 2024 list PDF; 15878 keeps NULL
--     (no 2025 list was readable).
--   slug istanbul/istanbul -> {TURK}, non-canonical (the old URL keeps working; old-slug policy).
--   city_label_source 15453 ("Istanbul", city_display) and 15454 ("Turkey", country), publisher best-chef-awards: hand audit
--     rows, then DELETE (as the Oct 30 Vietnam merges). TURK keeps its own 2 labels.
--   listings DELETE 1, venues DELETE 1. Name of TURK unchanged (held name item). Ledger {post['ledger']} (best-chef-awards, award, 2).
-- Audit rows {pre['audit_max'] + 1:,}-{post['audit_max']:,} ({F2_AUDIT}): awards UPDATE 2, slugs UPDATE 1, city_label_source DELETE 2 (hand),
--   listings DELETE 1, venues DELETE 1.
-- Relay relay-merge.txt sha256 {sha_m}, md5 {md5_m}.
BEGIN;
DO $do$
DECLARE
  -- replace(): removes CR characters that a copy and paste can add (Oct 30 23:29 ET: first SQL Editor try stopped at
  --   'relay hash'; nothing ran). The hash then checks the exact content.
  rel text := replace($r${tm}$r$, E'\\r', '');
  v_n int;
  v_lid bigint;
  v_txt text;
BEGIN
  -- 1. relay and live state
  IF md5(rel) <> '{md5_m}' OR encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> '{sha_m}'
    THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> {pre['venues']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> {pre['active']} THEN RAISE EXCEPTION 'active before'; END IF;
  IF (SELECT count(*) FROM awards) <> {pre['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> {pre['slugs']} THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {pre['noncanon']} THEN RAISE EXCEPTION 'non-canonical before'; END IF;
  IF (SELECT count(*) FROM listings) <> {pre['listings']} THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> {pre['labels']} THEN RAISE EXCEPTION 'city labels before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {pre['ledger']} THEN RAISE EXCEPTION 'ledger max before (run file 1 first)'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {pre['audit_max']} OR (SELECT count(*) FROM audit_log) <> {pre['audit_n']}
    THEN RAISE EXCEPTION 'audit_log before (run file 1 first)'; END IF;

  -- 2. rows on the held venue, as read before the build
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = '{HELD}' AND name = 'Istanbul' AND status = 'active' AND city_id = 'ci_2609eaea1a')
    THEN RAISE EXCEPTION 'held venue'; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = '{TURK}' AND name = 'Turk Fatih Tutak' AND status = 'active' AND city_id = 'ci_2609eaea1a')
    THEN RAISE EXCEPTION 'target venue'; END IF;
  SELECT md5(string_agg('award|'||a.id||'|'||a.venue_id||'|{TURK}|'||a.year||'|'||a.category||'|'||
                        CASE WHEN a.year = 2024 THEN '{PDF}' ELSE '' END, E'\\n' ORDER BY a.id))
    INTO v_txt FROM awards a WHERE a.venue_id = '{HELD}' AND a.source_id = 'best-chef-awards' AND a.source_url IS NULL
      AND a.rank IS NULL AND a.distinction IS NULL;
  IF v_txt IS DISTINCT FROM '918b15c84a13c43375ee177b5546178b' THEN RAISE EXCEPTION 'held award rows %', v_txt; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = '{HELD}') <> 2 THEN RAISE EXCEPTION 'held award count'; END IF;
  SELECT md5(string_agg('label|'||c.id||'|'||c.venue_id||'|-|'||c.from_column||'|'||c.label||'|'||c.publisher, E'\\n' ORDER BY c.id))
    INTO v_txt FROM city_label_source c WHERE c.venue_id = '{HELD}';
  IF v_txt IS DISTINCT FROM 'd29466f94a908c94c457e8a2ff75f8e8' THEN RAISE EXCEPTION 'held city labels %', v_txt; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = '{HELD}') <> 1
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = '{HELD}' AND property_id = 'eats' AND city_slug = 'istanbul'
                      AND slug = 'istanbul' AND is_canonical)
    THEN RAISE EXCEPTION 'held slug'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = '{HELD}') <> 1 THEN RAISE EXCEPTION 'held listing'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id = '{HELD}') + (SELECT count(*) FROM blurbs WHERE venue_id = '{HELD}')
     + (SELECT count(*) FROM geo WHERE venue_id = '{HELD}') + (SELECT count(*) FROM addresses WHERE venue_id = '{HELD}')
     + (SELECT count(*) FROM hours WHERE venue_id = '{HELD}') + (SELECT count(*) FROM photo_refs WHERE venue_id = '{HELD}')
     + (SELECT count(*) FROM rename_rows WHERE venue_id = '{HELD}') <> 0
    THEN RAISE EXCEPTION 'held venue has other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path LIKE '%istanbul/istanbul%' OR to_path LIKE '%istanbul/istanbul%')
    THEN RAISE EXCEPTION 'redirect on the old path'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id = '{TURK}' AND source_id = 'best-chef-awards')
    THEN RAISE EXCEPTION 'target already has Best Chef rows'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url = '{PDF}') THEN RAISE EXCEPTION 'PDF URL in use'; END IF;

  -- 3. writes
  UPDATE awards a SET venue_id = split_part(l, '|', 4), source_url = nullif(split_part(l, '|', 7), '')
    FROM regexp_split_to_table(rel, E'\\n') AS l
   WHERE split_part(l, '|', 1) = 'award' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3)
     AND a.year = split_part(l, '|', 5)::int AND a.category = split_part(l, '|', 6) AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'award rows moved: %', v_n; END IF;

  UPDATE slugs SET venue_id = '{TURK}', is_canonical = false
   WHERE property_id = 'eats' AND venue_id = '{HELD}' AND city_slug = 'istanbul' AND slug = 'istanbul';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'slug rows moved: %', v_n; END IF;

  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.venue_id = '{HELD}' ORDER BY c.id;
  DELETE FROM city_label_source WHERE venue_id = '{HELD}';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'city labels deleted: %', v_n; END IF;
  DELETE FROM listings WHERE venue_id = '{HELD}';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'listings deleted: %', v_n; END IF;
  DELETE FROM venues WHERE id = '{HELD}';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'venues deleted: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2,
          'merge:merge-istanbul-turk-2026-10-30 | venue {HELD} "Istanbul" (legacy load lost the restaurant name) = TURK FATIH '
          || 'TUTAK (Fatih Tutak, Istanbul, 1 knife): Best Chef 2024 list has 4 Turkey entries = the 4 Turkey 2024 rows | awards '
          || '15879 (2024) and 15878 (2025) -> {TURK}; 15879 source_url = 2024 list PDF; 15878 no URL | old slug istanbul/istanbul '
          || 'non-canonical on TURK; held venue deleted with its listing and 2 city labels | Ben "All recommended" Oct 30 23:11 ET '
          || '(D1 = A) | relay md5 {md5_m}')
  RETURNING id INTO v_lid;

  -- 4. post-checks
  IF v_lid <> {post['ledger']} OR (SELECT max(id) FROM source_capture_ledger) <> {post['ledger']} THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM venues) <> {post['venues']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> {post['active']} THEN RAISE EXCEPTION 'active after'; END IF;
  IF (SELECT count(*) FROM awards) <> {post['awards']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> {post['slugs']} THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE is_canonical) <> {post['canon']} THEN RAISE EXCEPTION 'canonical after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> {post['noncanon']} THEN RAISE EXCEPTION 'non-canonical after'; END IF;
  IF (SELECT count(*) FROM listings) <> {post['listings']} THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> {post['labels']} THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
              GROUP BY v.id HAVING count(s.slug) <> 1)
    THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  SELECT string_agg(id||' '||year||' '||category||' '||coalesce(source_url, '-'), ', ' ORDER BY id) INTO v_txt
    FROM awards WHERE venue_id = '{TURK}' AND source_id = 'best-chef-awards';
  IF v_txt IS DISTINCT FROM '15878 2025 1-Knife -, 15879 2024 1-Knife {PDF}'
    THEN RAISE EXCEPTION 'target Best Chef rows after: %', v_txt; END IF;
  IF NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = '{TURK}' AND city_slug = 'istanbul' AND slug = 'istanbul' AND NOT is_canonical)
    THEN RAISE EXCEPTION 'old slug after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = '{HELD}') + (SELECT count(*) FROM slugs WHERE venue_id = '{HELD}')
     + (SELECT count(*) FROM city_label_source WHERE venue_id = '{HELD}') + (SELECT count(*) FROM listings WHERE venue_id = '{HELD}')
     + (SELECT count(*) FROM venues WHERE id = '{HELD}') <> 0
    THEN RAISE EXCEPTION 'rows left on the held venue id'; END IF;
  IF (SELECT max(id) FROM audit_log) <> {post['audit_max']} OR (SELECT count(*) FROM audit_log WHERE id > {pre['audit_max']}) <> {F2_AUDIT}
    THEN RAISE EXCEPTION 'audit range after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > {pre['audit_max']} AND table_name = 'awards' AND action = 'UPDATE' AND row_pk IN ('15878', '15879')) <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > {pre['audit_max']} AND table_name = 'slugs' AND action = 'UPDATE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > {pre['audit_max']} AND table_name = 'city_label_source' AND action = 'DELETE'
           AND row_pk IN ('15453', '15454')) <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > {pre['audit_max']} AND table_name = 'listings' AND action = 'DELETE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > {pre['audit_max']} AND table_name = 'venues' AND action = 'DELETE'
           AND row_pk = '{HELD}') <> 1
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
"""


(DOCS / "slugs-heritage-open-items-b3-2026-10-30.sql").write_text(F1, encoding="utf-8")
post2, real = f2(AFTER1, "merge-istanbul-turk-2026-10-30.sql", False)
(DOCS / "merge-istanbul-turk-2026-10-30.sql").write_text(real, encoding="utf-8")
_, test = f2(NOW, "merge-test-current-counts.sql", True)
(HERE / "merge-test-current-counts.sql").write_text(test, encoding="utf-8")
print("file 1 after:", AFTER1)
print("file 2 after:", post2)
for p in [DOCS / "slugs-heritage-open-items-b3-2026-10-30.sql", DOCS / "merge-istanbul-turk-2026-10-30.sql",
          HERE / "merge-test-current-counts.sql"]:
    b = p.read_bytes()
    print(p.name, len(b.decode().splitlines()), "lines", hashlib.sha256(b).hexdigest())
