"""Build docs/cities-michelin-2026-switzerland-2026-11-02.sql.

Population: the 14 city labels of the Cowork CSV michelin-2026-switzerland (sha256 b8a1a2f4...6444)
that the importer label rule resolves to no city or to a wrong city through an alias.
Ben, Nov 2 2026: 18:09 ET "1A ... 6B", 18:17 ET "1B, 2A" (1B = travel region only where a nearby town has one,
no coordinates; 2A = row 9048 follows the 1A rule).

Run: python3 -I build_cities_ch_2026_11_02.py <csv> <out.sql>
"""
import csv
import hashlib
import sys
import unicodedata
import re

CSV_SHA = "b8a1a2f469df551273a74c73238a0be94d0f4f04aeaf6abb6911c22685ea6444"
csv_path, out_path = sys.argv[1], sys.argv[2]
raw = open(csv_path, "rb").read()
assert hashlib.sha256(raw).hexdigest() == CSV_SHA, "CSV hash"
rows = list(csv.DictReader(open(csv_path, encoding="utf-8", newline="")))
assert len(rows) == 225

R_ALPS = "rg_add0d36148"   # swiss-alps
R_LAKES = "rg_9d60346f2e"  # italian-lakes
REGION = {"Celerina": R_ALPS, "Intragna": R_LAKES, "Morbio Inferiore": R_LAKES}
NEW = ["Ballaigues", "Buchs", "Celerina", "Ebersecken", "Gonten", "Intragna", "Messen",
       "Morbio Inferiore", "Oberwil", "Ollon", "Pfaffnau", "Schwarzenburg", "Stans", "Utzenstorf"]
ALIASES = [("ebersecken", "ci_f92aa3aecf"), ("ollon", "ci_85e646c6b1"),
           ("schwarzenburg", "ci_2d67513835"), ("utzenstorf", "ci_2d67513835")]
ALIAS_FP = hashlib.md5("\n".join(f"{a}|{c}" for a, c in sorted(ALIASES)).encode()).hexdigest()
assert ALIAS_FP == "1597599b1cc3cd1280a24b134895db63", ALIAS_FP


def norm(s):
    s = unicodedata.normalize("NFKD", s.lower())
    s = "".join(ch for ch in s if not unicodedata.combining(ch))
    return re.sub(r"[^a-z0-9]+", " ", s).strip()


def slug(s):
    return norm(s).replace(" ", "-")


labels = {r["city_label"] for r in rows if r["country_label"] == "Switzerland"}
cards = {c: sum(1 for r in rows if r["city_label"] == c) for c in NEW}
for c in NEW:
    assert c in labels, c
assert sum(cards.values()) == 15, cards

cities = []
for c in NEW:
    s = slug(c)
    cid = "ci_" + hashlib.md5(s.encode()).hexdigest()[:10]
    cities.append((cid, s, c, REGION.get(c)))
cities.sort()
CITY_FP = hashlib.md5("\n".join(
    f"{i}|{s}|{d}|Switzerland|CH|city|{r or '-'}|0" for i, s, d, r in cities).encode("utf-8")).hexdigest()


def q(s):
    return "'" + s.replace("'", "''") + "'"


ids = ",".join(q(i) for i, *_ in cities)
slugs = ",".join(q(s) for _, s, _, _ in cities)
norms = ",".join(q(norm(d)) for _, _, d, _ in cities)
values = ",\n    ".join(
    f"({q(i)}, {q(s)}, {q(d)}, 'Switzerland', 'CH', 'city', {q(r) if r else 'NULL'}, NULL, NULL, 0)"
    for i, s, d, r in cities)
alias_in = ",".join(q(a) for a, _ in ALIASES)
table = "\n".join(f"--   {i}  {s:<18} {d:<18} {('region ' + r) if r else 'no region'}  ({cards[d]} card{'s' if cards[d] > 1 else ''})"
                  for i, s, d, r in cities)

sql = f"""-- cities-michelin-2026-switzerland-2026-11-02.sql
-- CompassEats, Nov 2 2026. Michelin Switzerland 2026, write 1 of the plan: city rows before the stage. One transaction.
-- Ben: Nov 2 18:09 ET "1A, 2A, 3A, 4A, 5A, 6B", 18:17 ET "1B, 2A". This file runs only after his "go".
-- Built by docs/ch-2026-build/build_cities_ch_2026_11_02.py from the Cowork CSV (sha256 {CSV_SHA}).
-- Population: the 14 city labels of the CSV that the importer label rule (normLabel on cities.slug, cities.display, city_aliases)
--   resolves to no city (10) or to a wrong city through an alias (4). 15 CSV rows use them.
--
-- 1. Delete 4 wrong aliases (fingerprint {ALIAS_FP}). Each sends a 2026 card to another town:
--      ollon -> Crissier ci_85e646c6b1; ebersecken -> Wengi bei Büren ci_f92aa3aecf; schwarzenburg, utzenstorf -> Grub ci_2d67513835.
--    Evidence (web.archive.org captures of guide.michelin.com /en/ venue pages):
--      Ollon 20260128201135: Restaurant de l'Hôtel de Ville, Place de l'Hôtel-de-Ville 3, Ollon, One Star 2025.
--      Ebersecken 20251208045545: Sonne, Dorf 2, Ebersecken, Bib Gourmand 2025. Wengi bei Büren 20260713032210: Sonne, Scheunenberg 70, One Star 2025.
--      Schwarzenburg 20260111022911: Bären, Dorfplatz 4, Schwarzenburg, Bib Gourmand 2025. Utzenstorf: 2026 card (no /en/ capture).
--    city_aliases has no audit trigger: 4 hand audit rows (row_pk = alias) before the delete.
-- 2. Insert 14 cities. Id rule 'ci_' || left(md5(slug), 10) (as Nirasaki). Display = the /us/en/ card city. Count 0 (venues come with the promote).
--    Region (Ben 1B): only where a nearby town already has one. No coordinates (0 of 3,265 cities have any).
{table}
--
-- No change: venues, awards, slugs, listings, price, city labels, regions, ledger. Rows 231 and 9048 move in the cleanup after the promote.
-- Expected after: cities 3,279, sum 10,999, view difference 0; city_aliases 262; audit_log +18 (cities:INSERT=14, city_aliases:DELETE=4), 118,875 rows.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text;
  new_ids constant text[] := ARRAY[{ids}];
  new_slugs constant text[] := ARRAY[{slugs}];
  new_norms constant text[] := ARRAY[{norms}];
  old_alias constant text[] := ARRAY[{alias_in}];
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 23:10 UTC)
  IF (SELECT count(*) FROM venues) <> 11293 OR (SELECT count(*) FROM venues WHERE status='active') <> 10999 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13022 OR (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11293 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23989 OR (SELECT count(*) FROM cities) <> 3265 OR (SELECT count(*) FROM city_aliases) <> 266 THEN RAISE EXCEPTION 'cities aliases before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10999 THEN RAISE EXCEPTION 'cities sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT max(id) FROM ingest_batches) <> 19 THEN RAISE EXCEPTION 'ingest batches before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM source_capture_ledger; IF n <> 186 OR aud_max <> 238 THEN RAISE EXCEPTION 'ledger before % / %', n, aud_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118857 OR aud_max <> 124371 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(alias||'|'||city_id, E'\\n' ORDER BY alias COLLATE "C")) INTO s FROM city_aliases WHERE alias = ANY (old_alias);
  IF s IS DISTINCT FROM '{ALIAS_FP}' THEN RAISE EXCEPTION 'alias fingerprint %', s; END IF;
  IF (SELECT count(*) FROM regions WHERE id IN ('{R_ALPS}','{R_LAKES}')) <> 2 THEN RAISE EXCEPTION 'regions'; END IF;
  -- The new cities are free (id, slug, display, alias other than the 4 that go)
  IF EXISTS (SELECT 1 FROM cities WHERE id = ANY (new_ids) OR slug = ANY (new_slugs)
             OR btrim(regexp_replace(lower(f_unaccent(slug)),'[^a-z0-9]+',' ','g')) = ANY (new_norms)
             OR btrim(regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+',' ','g')) = ANY (new_norms)) THEN RAISE EXCEPTION 'city clash'; END IF;
  IF EXISTS (SELECT 1 FROM city_aliases WHERE alias = ANY (new_norms) AND NOT alias = ANY (old_alias)) THEN RAISE EXCEPTION 'alias clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug = ANY (new_slugs)) THEN RAISE EXCEPTION 'slug clash'; END IF;

  ---------------------------------------------------------------- 1. Wrong aliases
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'DELETE', to_jsonb(a), NULL FROM city_aliases a WHERE a.alias = ANY (old_alias) ORDER BY a.alias;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'alias audit %', n; END IF;
  DELETE FROM city_aliases WHERE alias = ANY (old_alias);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'alias delete %', n; END IF;

  ---------------------------------------------------------------- 2. New cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES
    {values};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'city insert %', n; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||c.venues_count, E'\\n' ORDER BY c.id COLLATE "C")) INTO s FROM cities c WHERE c.id = ANY (new_ids);
  IF s IS DISTINCT FROM '{CITY_FP}' THEN RAISE EXCEPTION 'new city fingerprint %', s; END IF;
  -- Each new label now resolves to exactly 1 city, the new one (the importer rule)
  IF (SELECT count(*) FROM unnest(new_norms) WITH ORDINALITY u(nl, i)
       WHERE (SELECT count(DISTINCT c.id) FROM cities c
               WHERE btrim(regexp_replace(lower(f_unaccent(c.slug)),'[^a-z0-9]+',' ','g'))=u.nl
                  OR btrim(regexp_replace(lower(f_unaccent(c.display)),'[^a-z0-9]+',' ','g'))=u.nl
                  OR c.id IN (SELECT city_id FROM city_aliases a WHERE a.alias=u.nl)) = 1
         AND EXISTS (SELECT 1 FROM cities c WHERE c.id = new_ids[u.i] AND btrim(regexp_replace(lower(f_unaccent(c.display)),'[^a-z0-9]+',' ','g'))=u.nl)) <> 14
  THEN RAISE EXCEPTION 'label resolution after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3279 OR (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'cities aliases after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10999 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11293 OR (SELECT count(*) FROM venues WHERE status='active') <> 10999 OR (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13022 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11293 OR (SELECT count(*) FROM city_label_source) <> 23989 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 186 OR (SELECT max(id) FROM source_capture_ledger) <> 238 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:INSERT=14,city_aliases:DELETE=4' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log) <> 118875 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='cities' AND row_pk = ANY (new_ids)) <> 14 THEN RAISE EXCEPTION 'audit city rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
"""
open(out_path, "w", encoding="utf-8", newline="\n").write(sql)
print("cities", len(cities), "city fp", CITY_FP, "alias fp", ALIAS_FP)
