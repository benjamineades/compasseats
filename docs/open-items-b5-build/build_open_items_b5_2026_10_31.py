#!/usr/bin/env python3
"""Build the two SQL files of open items block 5 (held-P2 city items) from relay.txt.

Ben, Oct 31 2026 00:21 ET "Go with your recommendations": D2 A (Telese -> Telese Terme, display only),
D3 A (Michelin city rule for 4 venues, 3 new cities, 3 empty cities deleted, alias las caletas only,
venues_count kept equal to the view), D4 A (15 venues that left the guide: no write).

Fingerprints (PRE_*) are md5 values read from the live database on Oct 31 04:2x UTC (Read connector).
Usage: python3 -I build_open_items_b5_2026_10_31.py <relay.txt> <out_dir>
"""
import hashlib
import json
import sys

RELAY_SHA256 = "f266ea0ed5133a5f4d95cfec70a94827fab8a130cda791cab5179a08f19742bb"
PRE_TELESE = "4d8c7d99db02b55ea043c4e7481e4f13"   # cities row ci_845e30f4ce (full format, lat/lng)
PRE_CITY5 = "78a8625ec26770109a25b8cbe3d5b459"    # 5 city rows: Prato, Vico Equense, Sanluri, Las Caletas, Sorrento
PRE_VENUE4 = "7a1055b5e3d0017299d8e384aaca6422"   # id|name|status|city_id|norm_key of the 4 venues
PRE_SLUG4 = "e855c7f979fe90c8ce6a83b9b111c9ac"    # slug rows of the 4 venues

# Live counts at the read (Oct 31 04:22 UTC)
C = dict(cities=3259, aliases=265, slugs=12936, noncanon=1633, venues=11303, awards=23362, listings=11303,
         cls=24003, redirects=9, audit_rows=114087, audit_max=119371, it_cities=483, es_cities=286, vc_sum=10934)


def norm(s: str) -> str:
    import re
    import unicodedata
    s = unicodedata.normalize("NFKD", s.lower())
    s = "".join(ch for ch in s if not unicodedata.combining(ch))
    return re.sub(r"[^a-z0-9]+", " ", s).strip()


def main() -> None:
    relay_path, out_dir = sys.argv[1], sys.argv[2]
    raw = open(relay_path, "rb").read()
    if hashlib.sha256(raw).hexdigest() != RELAY_SHA256:
        sys.exit("relay sha256 mismatch")
    rel = raw.decode("utf-8")
    rows = [l.split("|") for l in rel.split("\n")]
    disp = [r for r in rows if r[0] == "display"]
    newc = [dict(id=r[1], slug=r[2], display=r[3], copy_from=r[4]) for r in rows if r[0] == "newcity"]
    mv = [dict(venue_id=r[1], from_city=r[2], to_city=r[3], old_city_slug=r[4], old_slug=r[5],
               to_city_slug=r[6], new_slug=r[7]) for r in rows if r[0] == "move"]
    cnt = [dict(id=r[1], old=int(r[2]), new=int(r[3])) for r in rows if r[0] == "count"]
    dc = [dict(id=r[1], slug=r[2]) for r in rows if r[0] == "delcity"]
    al = [dict(alias=r[1], city_id=r[2]) for r in rows if r[0] == "alias"]
    res = [dict(n=r[1], iso=r[2], want=r[3]) for r in rows if r[0] == "resolve"]
    assert len(disp) == 1 and len(newc) == 3 and len(mv) == 4 and len(cnt) == 2 and len(dc) == 3 and len(al) == 1
    assert len(res) == 10

    # build-time checks
    for c in newc:
        assert c["id"] == "ci_" + hashlib.md5(c["slug"].encode()).hexdigest()[:10], c
        assert norm(c["display"]) == norm(c["slug"].replace("-", " ")), c
    assert {m["to_city"] for m in mv} >= {c["id"] for c in newc}
    assert {m["from_city"] for m in mv} >= {d["id"] for d in dc}
    for a in al:
        assert a["alias"] == norm(a["alias"])

    def lit(obj) -> str:
        s = json.dumps(obj, ensure_ascii=False, sort_keys=True)
        assert "$j$" not in s
        return "$j$" + s + "$j$::jsonb"

    # ------------------------------------------------------------------ file 1: Telese display
    _, did, dslug, dold, dnew, durl = disp[0]
    post1 = hashlib.md5(f"{did}|{dnew}".encode()).hexdigest()
    f1 = f"""-- cities-display-telese-terme-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 5, file 1 of 2 (held-P2 city item: Telese).
-- Ben: Oct 31 00:21 ET "Go with your recommendations" (D2 A: display name only; the slug telese stays, as Waiheke Island).
-- RUN FIRST (Write connector). File 2 expects this file's audit row (last id {C['audit_max'] + 1}).
--
-- What this file does (one transaction, one DO block): updates cities.display for 1 city.
--   {did}  {dold} -> {dnew}
--   Evidence: Michelin cards read Oct 31 (WebFetch): Krèsios "Via San Giovanni 59, Telese Terme, 82037, Italy";
--   La Locanda del Borgo "Località Monte Pugliano 1, Telese Terme, 82037, Italy"; card URL city telese-terme_1850913.
--   The alias "telese terme" already points to {did}. Slug, id, region and venues_count do not change.
--   city_label_source rows are source labels and do not change. No ledger row. trg_audit_cities writes 1 UPDATE row.
-- Built by script (docs/open-items-b5-build/build_open_items_b5_2026_10_31.py) from relay.txt (sha256 {RELAY_SHA256}).
-- Gates (PRE): counts; md5 of the city row {PRE_TELESE}; no other city or alias uses the new display.
-- Gates (POST): counts; md5 of id|display {post1}; 1 audit row, display only; stage-job resolution of
--               "telese" and "telese terme" (Italy) gives exactly {did}.
-- Expected: audit_log {C['audit_rows']:,} -> {C['audit_rows'] + 1:,} rows, last id {C['audit_max']:,} -> {C['audit_max'] + 1:,}.
-- Dry run: send through the Read connector. It stops at the UPDATE with "read-only transaction".

BEGIN;
DO $tt$
DECLARE
  x       bigint;
  t       text;
  aud_max bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;            IF x <> {C['cities']}  THEN RAISE EXCEPTION 'cities before % (expected {C['cities']})', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;      IF x <> {C['aliases']}   THEN RAISE EXCEPTION 'city_aliases before % (expected {C['aliases']})', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> {C['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {C['slugs']})', x; END IF;
  SELECT count(*) INTO x FROM venues;            IF x <> {C['venues']} THEN RAISE EXCEPTION 'venues before % (expected {C['venues']})', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> {C['cls']} THEN RAISE EXCEPTION 'city_label_source before % (expected {C['cls']})', x; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;
  IF x <> {C['audit_rows']} THEN RAISE EXCEPTION 'audit_log before % (expected {C['audit_rows']})', x; END IF;
  IF aud_max <> {C['audit_max']} THEN RAISE EXCEPTION 'audit_log last id % (expected {C['audit_max']})', aud_max; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count, E'\\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.id = '{did}';
  IF t IS DISTINCT FROM '{PRE_TELESE}' THEN RAISE EXCEPTION 'city row changed since the read: %', t; END IF;

  SELECT count(*) INTO x FROM cities c
   WHERE c.id <> '{did}' AND (c.display = '{dnew}'
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = '{norm(dnew)}'
      OR btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = '{norm(dnew)}');
  IF x <> 0 THEN RAISE EXCEPTION 'new display used by % other cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a WHERE a.city_id <> '{did}' AND a.alias = '{norm(dnew)}';
  IF x <> 0 THEN RAISE EXCEPTION 'new display is an alias of % other cities', x; END IF;

  ---------------------------------------------------------------- WRITE
  UPDATE cities SET display = '{dnew}' WHERE id = '{did}' AND slug = '{dslug}' AND display = '{dold}';
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'cities updated % (expected 1)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT md5(c.id||'|'||c.display) INTO t FROM cities c WHERE c.id = '{did}';
  IF t IS DISTINCT FROM '{post1}' THEN RAISE EXCEPTION 'id|display after % differs from the file', t; END IF;
  SELECT count(*) INTO x FROM cities;            IF x <> {C['cities']}  THEN RAISE EXCEPTION 'cities changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;      IF x <> {C['aliases']}   THEN RAISE EXCEPTION 'city_aliases changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> {C['slugs']} THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM venues;            IF x <> {C['venues']} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> {C['cls']} THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;   IF x <> {C['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 1 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'UPDATE' AND a.row_pk = '{did}'
     AND a.old_row->>'display' = '{dold}' AND a.new_row->>'display' = '{dnew}'
     AND (a.old_row - 'display') = (a.new_row - 'display');
  IF x <> 1 THEN RAISE EXCEPTION 'audit city update (display only) % (expected 1)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter IT): each label gives exactly {did}.
  WITH lab(n_full) AS (VALUES ('telese'), ('telese terme')),
  cand AS (
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, a.city_id FROM lab h JOIN city_aliases a ON a.alias = h.n_full),
  hit AS (
    SELECT h.n_full, count(ci.id) n, min(ci.id) got
      FROM lab h LEFT JOIN cand c ON c.n_full = h.n_full LEFT JOIN cities ci ON ci.id = c.id AND ci.country_iso = 'IT'
     GROUP BY h.n_full)
  SELECT count(*) INTO x FROM hit WHERE n <> 1 OR got IS DISTINCT FROM '{did}';
  IF x <> 0 THEN RAISE EXCEPTION 'label resolution wrong for % labels', x; END IF;

  RAISE NOTICE 'OK: 1 city display updated, 1 audit row after id %', aud_max;
END
$tt$;
COMMIT;
"""

    # ------------------------------------------------------------------ file 2: 4 moves
    a0 = C["audit_max"] + 1           # after file 1
    n_audit = len(newc) + len(mv) + 2 * len(mv) + len(cnt) + len(dc) + len(al)
    post_vc = "\n".join(f"{c['id']}|{c['new']}" for c in sorted(cnt, key=lambda c: c["id"]))
    post_vc_md5 = hashlib.md5(post_vc.encode()).hexdigest()
    new_rows = "\n".join(f"{c['id']}|{c['slug']}|{c['display']}|1" for c in sorted(newc, key=lambda c: c["id"]))
    new_rows_md5 = hashlib.md5(new_rows.encode("utf-8")).hexdigest()
    MV, NC, CN, DC, AL, RS = lit(mv), lit(newc), lit(cnt), lit(dc), lit(al), lit(res[:8])
    mvt = "jsonb_to_recordset(mv) m(venue_id text, from_city text, to_city text, old_city_slug text, old_slug text, to_city_slug text, new_slug text)"
    nct = "jsonb_to_recordset(nc) n(id text, slug text, display text, copy_from text)"
    cnt_t = "jsonb_to_recordset(cn) k(id text, old int, new int)"
    dct = "jsonb_to_recordset(dc) d(id text, slug text)"
    alt = "jsonb_to_recordset(al) ax(alias text, city_id text)"
    f2 = f"""-- cities-held-p2-michelin-city-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 5, file 2 of 2 (held-P2 city changes).
-- RUN IN THE SUPABASE SQL EDITOR (the file holds DELETE statements; the Write connector prompt closes by itself on those).
-- Run file 1 (cities-display-telese-terme-2026-10-31.sql) first: the audit gate expects its row (last id {a0}).
--
-- Ben: Oct 31 00:21 ET "Go with your recommendations": D3 A (the Michelin city rule D7 = the city in the card URL, now also
--   outside Turkey; 3 new cities; delete the 3 empty cities; alias only for las caletas, a place inside Fuencaliente;
--   no alias for Prato or Sanluri, separate towns; venues_count kept equal to the view city_venue_counts).
-- Evidence: live Michelin cards read Oct 31 (WebFetch), address lines:
--   Paca "Via delle Ginestre 45, Carmignano, 59015, Italy" (2026 One Star);
--   Torre del Saracino "Piazza della Vittoria 5, Sorrento, 80067, Italy" (2026 Two Stars);
--   Coxinendi "Viale del Golfo di Quartu 25, Quartu sant'Elena, 09045, Italy" (2026 Bib Gourmand);
--   El Jardín de la Sal "Carretera La Costa-El Faro 5, Fuencaliente de la Palma, 38740, Spain" (2026 Bib Gourmand).
--
-- What this file does (one transaction, one DO block):
--   1. Inserts 3 cities (id = 'ci_' || left(md5(slug), 10)); country, kind and region copied from the old city;
--      lat/lng NULL (as Fethiye); venues_count 1:
--      ci_6480e34f4d carmignano "Carmignano" (from Prato); ci_cef88d0e62 quartu-sant-elena "Quartu Sant'Elena" (from Sanluri);
--      ci_06496b916c fuencaliente-de-la-palma "Fuencaliente de la Palma" (from Las Caletas).
--   2. Moves 4 venues (venues.city_id only): Paca Ristorante Prato -> Carmignano; Torre del Saracino Vico Equense -> Sorrento;
--      Coxinendi - Ristorante Sanluri -> Quartu Sant'Elena; Restaurante Temático El Jardín de la Sal Las Caletas -> Fuencaliente de la Palma.
--   3. Slugs: each old canonical row becomes non-canonical (old URL keeps working); the new canonical row is
--      <target city slug>/<same slug> (= slug rule of the live name). Old non-canonical rows (prato/paca, sanluri/coxinendi) stay.
--   4. venues_count: Sorrento 5 -> 6, Vico Equense 2 -> 1 (Antica Osteria Nonna Rosa stays). Telese unchanged.
--   5. Deletes the 3 empty cities: Prato ci_c02c36007b, Sanluri ci_d59e7dd97f, Las Caletas ci_b52d606d20 (gate: 0 venues,
--      0 aliases). Region rows do not change.
--   6. Inserts 1 alias with a hand audit row: las caletas -> ci_06496b916c.
--   city_label_source rows are source labels and do not change. No redirect row. No ledger row.
--   Audit rows: cities 3 INSERT + 2 UPDATE (venues_count) + 3 DELETE, venues 4 UPDATE, slugs 4 UPDATE + 4 INSERT,
--   city_aliases 1 INSERT (hand) = {n_audit} (ids {a0 + 1:,}-{a0 + n_audit:,}).
-- Built by script (docs/open-items-b5-build/build_open_items_b5_2026_10_31.py) from relay.txt (sha256 {RELAY_SHA256}).
-- Dry run: send through the Read connector. It stops at the first INSERT with "read-only transaction".

BEGIN;
DO $hp$
DECLARE
  mv      constant jsonb := {MV};
  nc      constant jsonb := {NC};
  cn      constant jsonb := {CN};
  dc      constant jsonb := {DC};
  al      constant jsonb := {AL};
  rs      constant jsonb := {RS};
  x       bigint;
  x2      bigint;
  t       text;
  aud_max bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM cities;                        IF x <> {C['cities']}  THEN RAISE EXCEPTION 'cities before % (expected {C['cities']})', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> {C['aliases']}   THEN RAISE EXCEPTION 'city_aliases before % (expected {C['aliases']})', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> {C['redirects']}     THEN RAISE EXCEPTION 'redirects before % (expected {C['redirects']})', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> {C['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {C['slugs']})', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> {C['noncanon']}  THEN RAISE EXCEPTION 'non-canonical before % (expected {C['noncanon']})', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> {C['venues']} THEN RAISE EXCEPTION 'venues before % (expected {C['venues']})', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> {C['awards']} THEN RAISE EXCEPTION 'awards before % (expected {C['awards']})', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> {C['listings']} THEN RAISE EXCEPTION 'listings before % (expected {C['listings']})', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> {C['cls']} THEN RAISE EXCEPTION 'city_label_source before % (expected {C['cls']})', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;               IF x <> {C['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum before % (expected {C['vc_sum']})', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'IT'; IF x <> {C['it_cities']} THEN RAISE EXCEPTION 'Italy cities before %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'ES'; IF x <> {C['es_cities']} THEN RAISE EXCEPTION 'Spain cities before %', x; END IF;
  SELECT max(id) INTO aud_max FROM audit_log;
  IF aud_max <> {a0} THEN RAISE EXCEPTION 'audit_log last id % (expected {a0}; run file 1 first)', aud_max; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count, E'\\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.id IN ('ci_c02c36007b', 'ci_84cafc2357', 'ci_d59e7dd97f', 'ci_b52d606d20', 'ci_25a0f29d02');
  IF t IS DISTINCT FROM '{PRE_CITY5}' THEN RAISE EXCEPTION 'city rows changed since the read: %', t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id))
    INTO t FROM venues v WHERE v.id IN (SELECT m.venue_id FROM {mvt});
  IF t IS DISTINCT FROM '{PRE_VENUE4}' THEN RAISE EXCEPTION 'venue rows changed: %', t; END IF;
  SELECT md5(string_agg(s.venue_id||'|'||s.property_id||'|'||s.city_slug||'|'||s.slug||'|'||s.is_canonical, E'\\n' ORDER BY s.venue_id, s.city_slug, s.slug))
    INTO t FROM slugs s WHERE s.venue_id IN (SELECT m.venue_id FROM {mvt});
  IF t IS DISTINCT FROM '{PRE_SLUG4}' THEN RAISE EXCEPTION 'slug rows changed: %', t; END IF;

  -- new cities: id rule, no clash by id, slug, display or alias
  SELECT count(*) INTO x FROM {nct} WHERE n.id <> 'ci_' || left(md5(n.slug), 10);
  IF x <> 0 THEN RAISE EXCEPTION 'new city id rule fails for %', x; END IF;
  SELECT count(*) INTO x FROM cities c, {nct}
   WHERE c.id = n.id OR c.slug = n.slug
      OR btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = btrim(regexp_replace(lower(f_unaccent(n.display)), '[^a-z0-9]+', ' ', 'g'));
  IF x <> 0 THEN RAISE EXCEPTION 'new cities clash with % cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a
   WHERE a.alias IN (SELECT btrim(regexp_replace(lower(f_unaccent(n.display)), '[^a-z0-9]+', ' ', 'g')) FROM {nct})
      OR a.alias IN (SELECT ax.alias FROM {alt});
  IF x <> 0 THEN RAISE EXCEPTION 'aliases already present: %', x; END IF;
  SELECT count(*) INTO x FROM {nct} JOIN cities c ON c.id = n.copy_from;
  IF x <> 3 THEN RAISE EXCEPTION 'copy-from cities present % (expected 3)', x; END IF;

  -- each move: active venue in the from city, exactly 1 canonical slug = the old slug, new slug = slug rule of the live name, free
  SELECT count(*) INTO x FROM {mvt}
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.from_city AND v.status = 'active'
    JOIN cities cf ON cf.id = m.from_city AND cf.slug = m.old_city_slug
   WHERE (EXISTS (SELECT 1 FROM cities ct WHERE ct.id = m.to_city AND ct.slug = m.to_city_slug)
          OR EXISTS (SELECT 1 FROM {nct} WHERE n.id = m.to_city AND n.slug = m.to_city_slug))
     AND m.new_slug = trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))
     AND (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) = 1
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
                    AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug)
     AND NOT EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug);
  IF x <> 4 THEN RAISE EXCEPTION 'move rows that pass the pre-check: % (expected 4)', x; END IF;

  -- each city to delete holds only venues that move, and no alias; no redirect uses its path
  SELECT count(*) INTO x FROM {dct}
   WHERE EXISTS (SELECT 1 FROM cities c WHERE c.id = d.id AND c.slug = d.slug)
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = d.id AND v.id NOT IN (SELECT m.venue_id FROM {mvt}))
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = d.id);
  IF x <> 3 THEN RAISE EXCEPTION 'cities to delete that pass the pre-check: % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM redirects r, {dct}
   WHERE r.from_path LIKE '/'||d.slug||'/%' OR r.to_path LIKE '/'||d.slug||'/%';
  IF x <> 0 THEN RAISE EXCEPTION 'city paths in redirects: %', x; END IF;

  -- venues_count plan: each old value = the live active count now (the POST gates check the new values against the view)
  SELECT count(*) INTO x FROM {cnt_t} JOIN cities c ON c.id = k.id AND c.venues_count = k.old
   WHERE k.old = (SELECT count(*) FROM venues v WHERE v.city_id = k.id AND v.status = 'active');
  IF x <> 2 THEN RAISE EXCEPTION 'venues_count old values that match % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM city_venue_counts w JOIN cities c ON c.id = w.city_id WHERE c.venues_count <> w.active_venues;
  IF x <> 0 THEN RAISE EXCEPTION 'cities that differ from the view before: %', x; END IF;

  ---------------------------------------------------------------- WRITE 1: new cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT n.id, n.slug, n.display, c.country, c.country_iso, c.kind, c.region_id, NULL, NULL, 1
    FROM {nct} JOIN cities c ON c.id = n.copy_from ORDER BY n.id;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'city inserts % (expected 3)', x; END IF;

  ---------------------------------------------------------------- WRITE 2: move the venues
  UPDATE venues v SET city_id = m.to_city FROM {mvt}
   WHERE v.id = m.venue_id AND v.city_id = m.from_city;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 4 THEN RAISE EXCEPTION 'venue moves % (expected 4)', x; END IF;

  ---------------------------------------------------------------- WRITE 3: slugs
  UPDATE slugs s SET is_canonical = false FROM {mvt}
   WHERE s.venue_id = m.venue_id AND s.property_id = 'eats' AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND s.is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 4 THEN RAISE EXCEPTION 'old canonical slug updates % (expected 4)', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', m.to_city_slug, m.new_slug, m.venue_id, true FROM {mvt} ORDER BY m.venue_id;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 4 THEN RAISE EXCEPTION 'new canonical slug inserts % (expected 4)', x; END IF;

  ---------------------------------------------------------------- WRITE 4: venues_count of the existing cities
  UPDATE cities c SET venues_count = k.new FROM {cnt_t}
   WHERE c.id = k.id AND c.venues_count = k.old;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 2 THEN RAISE EXCEPTION 'venues_count updates % (expected 2)', x; END IF;

  ---------------------------------------------------------------- WRITE 5: delete the empty cities
  DELETE FROM cities c USING {dct}
   WHERE c.id = d.id AND c.slug = d.slug
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = c.id)
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = c.id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'city deletes % (expected 3)', x; END IF;

  ---------------------------------------------------------------- WRITE 6: alias, with a hand audit row
  INSERT INTO city_aliases (alias, city_id) SELECT ax.alias, ax.city_id FROM {alt};
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'alias inserts % (expected 1)', x; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a) FROM city_aliases a
   WHERE a.alias IN (SELECT ax.alias FROM {alt}) ORDER BY a.alias;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'alias hand audit rows % (expected 1)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM cities;                        IF x <> {C['cities']}  THEN RAISE EXCEPTION 'cities after % (expected {C['cities']})', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> {C['aliases'] + 1}   THEN RAISE EXCEPTION 'city_aliases after % (expected {C['aliases'] + 1})', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> {C['redirects']}     THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> {C['slugs'] + 4} THEN RAISE EXCEPTION 'slugs after % (expected {C['slugs'] + 4})', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> {C['noncanon'] + 4}  THEN RAISE EXCEPTION 'non-canonical after % (expected {C['noncanon'] + 4})', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;      IF x <> {C['venues']} THEN RAISE EXCEPTION 'canonical after % (expected {C['venues']})', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> {C['venues']} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> {C['awards']} THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> {C['listings']} THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> {C['cls']} THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'IT'; IF x <> {C['it_cities']} THEN RAISE EXCEPTION 'Italy cities after %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'ES'; IF x <> {C['es_cities']} THEN RAISE EXCEPTION 'Spain cities after %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;               IF x <> {C['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum after % (expected {C['vc_sum']})', x; END IF;
  SELECT count(*) INTO x FROM city_venue_counts w JOIN cities c ON c.id = w.city_id WHERE c.venues_count <> w.active_venues;
  IF x <> 0 THEN RAISE EXCEPTION 'cities that differ from the view after: %', x; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.venues_count, E'\\n' ORDER BY c.id)) INTO t
    FROM cities c WHERE c.id IN (SELECT n.id FROM {nct});
  IF t IS DISTINCT FROM '{new_rows_md5}' THEN RAISE EXCEPTION 'new city rows after %', t; END IF;
  SELECT md5(string_agg(c.id||'|'||c.venues_count, E'\\n' ORDER BY c.id)) INTO t FROM cities c WHERE c.id IN (SELECT k.id FROM {cnt_t});
  IF t IS DISTINCT FROM '{post_vc_md5}' THEN RAISE EXCEPTION 'venues_count after %', t; END IF;
  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;
  SELECT count(*) INTO x FROM {mvt}
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.to_city
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND NOT s.is_canonical);
  IF x <> 4 THEN RAISE EXCEPTION 'moved venues as planned after: % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM cities c JOIN {dct} ON c.id = d.id;
  IF x <> 0 THEN RAISE EXCEPTION 'deleted cities still present: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> {n_audit} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {n_audit})', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {nct} ON a.row_pk = n.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'INSERT' AND a.old_row IS NULL;
  IF x <> 3 THEN RAISE EXCEPTION 'audit city inserts % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {cnt_t} ON a.row_pk = k.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'UPDATE'
     AND (a.old_row->>'venues_count')::int = k.old AND (a.new_row->>'venues_count')::int = k.new
     AND (a.old_row - 'venues_count') = (a.new_row - 'venues_count');
  IF x <> 2 THEN RAISE EXCEPTION 'audit venues_count updates % (expected 2, venues_count only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {dct} ON a.row_pk = d.id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'DELETE' AND a.new_row IS NULL AND a.old_row->>'slug' = d.slug;
  IF x <> 3 THEN RAISE EXCEPTION 'audit city deletes % (expected 3)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {mvt} ON a.row_pk = m.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE'
     AND (a.old_row - 'city_id') = (a.new_row - 'city_id') AND a.old_row->>'city_id' = m.from_city AND a.new_row->>'city_id' = m.to_city;
  IF x <> 4 THEN RAISE EXCEPTION 'audit venue updates % (expected 4, city_id only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a WHERE a.id > aud_max AND a.table_name = 'slugs'
     AND a.row_pk IN (SELECT m.venue_id FROM {mvt});
  IF x <> 8 THEN RAISE EXCEPTION 'audit slug rows % (expected 8)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {alt} ON a.row_pk = ax.alias
   WHERE a.id > aud_max AND a.table_name = 'city_aliases' AND a.action = 'INSERT' AND a.old_row IS NULL AND a.new_row->>'city_id' = ax.city_id;
  IF x <> 1 THEN RAISE EXCEPTION 'audit alias insert % (expected 1)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter): each label gives exactly the expected city;
  -- the labels Prato and Sanluri give no city (separate towns, no alias).
  WITH lab AS (SELECT * FROM jsonb_to_recordset(rs) r(n text, iso text, want text)),
  cand AS (
    SELECT h.n, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n
    UNION
    SELECT h.n, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n
    UNION
    SELECT h.n, a.city_id FROM lab h JOIN city_aliases a ON a.alias = h.n),
  hit AS (
    SELECT h.n, h.want, count(ci.id) k, min(ci.id) got
      FROM lab h LEFT JOIN cand c ON c.n = h.n LEFT JOIN cities ci ON ci.id = c.id AND ci.country_iso = h.iso
     GROUP BY h.n, h.want)
  SELECT count(*) FILTER (WHERE (want = '-' AND k = 0) OR (want <> '-' AND k = 1 AND got = want)), count(*)
    INTO x, x2 FROM hit;
  IF x <> 8 OR x2 <> 8 THEN RAISE EXCEPTION 'label resolution: % of % labels as planned', x, x2; END IF;

  RAISE NOTICE 'OK: 3 cities inserted, 4 venues moved, 8 slug rows, 2 venues_count, 3 cities deleted, 1 alias, {n_audit} audit rows after id %', aud_max;
END
$hp$;
COMMIT;
"""
    for name, body in (("cities-display-telese-terme-2026-10-31.sql", f1),
                       ("cities-held-p2-michelin-city-2026-10-31.sql", f2)):
        p = f"{out_dir}/{name}"
        open(p, "w", encoding="utf-8").write(body)
        print(name, hashlib.sha256(body.encode("utf-8")).hexdigest(), body.count("\n"), "lines")
    print("planned audit: file 1 id", a0, "; file 2 ids", a0 + 1, "-", a0 + n_audit)


if __name__ == "__main__":
    main()
