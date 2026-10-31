#!/usr/bin/env python3
"""Build the two SQL files of open items block 2 (Oct 30, 2026).

Inputs: relay-file1.txt and relay-file2.txt in this folder (values from the tool reads of Oct 30-31, 2026).
Outputs: ../open-items-b2-status-price-url-2026-10-30.sql (file 1, Write connector)
         ../cities-turkey-michelin-city-2026-10-30.sql      (file 2, Supabase SQL Editor: it holds DELETE)
"""
import hashlib, pathlib

HERE = pathlib.Path(__file__).resolve().parent
DOCS = HERE.parent


def q(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def relay(name):
    txt = (HERE / name).read_text(encoding="utf-8").rstrip("\n")
    rows = [l.split("|") for l in txt.split("\n")]
    return txt, rows, hashlib.sha256(txt.encode()).hexdigest(), hashlib.md5(txt.encode()).hexdigest()


# ------------------------------------------------------------------ file 1
t1, r1, sha1, md51 = relay("relay-file1.txt")
url = [r for r in r1 if r[0] == "url"]
sts = [r for r in r1 if r[0] == "status"]
pin = [r for r in r1 if r[0] == "price-ins"]
pup = [r for r in r1 if r[0] == "price-upd"]
assert (len(url), len(sts), len(pin), len(pup)) == (2, 2, 1, 2), (len(url), len(sts), len(pin), len(pup))

url_vals = ",\n    ".join(f"({r[1]}, {q(r[2])}, {q(r[3])}, {q(r[4])})" for r in url)
sts_vals = ",\n    ".join(f"({q(r[1])}, {q(r[2])}, {q(r[3])})" for r in sts)
pr_vals = ",\n    ".join(
    f"({q(r[0])}, {q(r[1])}, {int(r[2])}, {q(r[3])}, {q(r[4])}, {q(r[5])}, {q(r[6])})" for r in pin + pup)

F1 = f"""-- open-items-b2-status-price-url-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 2, file 1 of 2 (items 1-3). Run through the Write connector.
--
-- Ben: Oct 30 21:36 ET "1-4"; 22:14 ET "All recommended" (D1-D9 = A). This file holds D2, D3, D4 and the item 1 URL.
-- D1 (Chay Garden 10486: no 2025-edition card on 6 locale paths), D5 (Efendy stays active), D6 (unknown Turkey Bib)
-- and the Sankai site spam need no write.
--
-- What this file does (one transaction, one DO block):
--   W1 awards source_url NULL -> archive card URL (year and category unchanged):
--      10493 Hu Tieu Hong Phat 2025 Bib = archive card Sep 8, 2025 (vn/en; meta "2025 MICHELIN Guide Vietnam", dateAwarded 2025)
--      10908 Dill 2025 Bib = archive card Aug 5, 2025 (gb/en; meta "2025 MICHELIN Guide United Kingdom", dateAwarded 2025)
--      Ledger 168 (michelin, award, 2).
--   W2 venues status active -> closed (status only; no ledger row, SLOW&LOW / Sankai precedent):
--      ve_fff5bda31e Nadair (Atlanta): Rough Draft Jun 19, 2026, last service Jun 27, 2026; card 404 Oct 31.
--      ve_b3825c7559 Dill (Lewes): The Good Food Guide label "Closed" (read Oct 31); card 404 (left the 2026 list).
--   W3 price from the Michelin card (rule Sep 28: the card price wins over a legacy price with no URL):
--      INSERT ve_f088b7a06a Sankai by Nagaya: TRY 4 (live card read Oct 30 17:59 UTC).
--      UPDATE legacy $$ rows: ve_51ce2088a5 Efendy Istanbul TRY 2 (archive card Jan 6, 2026, read Oct 31 02:15 UTC);
--             ve_f8013e6d34 Lucien Arkas Baglari TRY 2 (LA Mahzen live card, read Oct 30 17:59 UTC).
--      Ledger 169 (michelin, price, 3).
--   Audit rows 118,999-119,005 (7): awards UPDATE 2, venues UPDATE 2, price INSERT 1, price UPDATE 2.
-- Relay: open-items-b2-build/relay-file1.txt, sha256 {sha1}, md5 {md51}.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  rel_txt constant text := $rel${t1}$rel$;
  v_n bigint;
  v_lid1 bigint;
  v_lid2 bigint;
  v_t text;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha1}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF (SELECT count(*) FROM awards) <> 23358 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'price before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11304 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 367 THEN RAISE EXCEPTION 'closed venues before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 167 THEN RAISE EXCEPTION 'ledger max before is not 167'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118998 THEN RAISE EXCEPTION 'audit max before is not 118998'; END IF;

  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,'-'), E'\\n' ORDER BY a.id))
    INTO v_t FROM awards a WHERE a.id IN (10493, 10908);
  IF v_t IS DISTINCT FROM 'caeea260ef28114c53e8eaa9bef472e2' THEN RAISE EXCEPTION 'award rows changed: %', v_t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id))
    INTO v_t FROM venues v WHERE v.id IN ('ve_fff5bda31e', 've_b3825c7559');
  IF v_t IS DISTINCT FROM '178f417744a9d94a60bbe8e4726251da' THEN RAISE EXCEPTION 'status venue rows changed: %', v_t; END IF;
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||p.symbol_raw||'|'||coalesce(p.currency,'-')||'|'||p.source||'|'||p.method||'|'||p.publisher||'|'||coalesce(p.source_url,'-'), E'\\n' ORDER BY p.venue_id))
    INTO v_t FROM price p WHERE p.venue_id IN ('ve_51ce2088a5', 've_f8013e6d34', 've_f088b7a06a');
  IF v_t IS DISTINCT FROM 'a185af400de9ce38b305c6fda06380bb' THEN RAISE EXCEPTION 'price rows changed: %', v_t; END IF;
  IF EXISTS (SELECT 1 FROM price WHERE venue_id = 've_f088b7a06a') THEN RAISE EXCEPTION 'Sankai has a price row'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active' AND id IN ('ve_51ce2088a5', 've_f8013e6d34', 've_f088b7a06a')) <> 3
    THEN RAISE EXCEPTION 'a price venue is not active'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN (VALUES
    {url_vals}) AS x(award_id, venue_id, category, url) ON a.source_url = x.url)
    THEN RAISE EXCEPTION 'a relay award URL is already in use'; END IF;

  ---------------------------------------------------------------- W1 award URLs
  UPDATE awards a SET source_url = x.url
    FROM (VALUES
    {url_vals}) AS x(award_id, venue_id, category, url)
   WHERE a.id = x.award_id AND a.venue_id = x.venue_id AND a.category = x.category
     AND a.source_id = 'michelin' AND a.year = 2025 AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'award rows updated: %', v_n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 2,
          'source-url:open-items-b2-status-price-url-2026-10-30 | award source_url NULL -> archive card URL, year and category unchanged '
          || '| 10493 Hong Phat (District 3) card Sep 8, 2025 vn/en (2025 MICHELIN Guide Vietnam, dateAwarded 2025); 10908 Dill card '
          || 'Aug 5, 2025 gb/en (2025 MICHELIN Guide United Kingdom, dateAwarded 2025) | Chay Garden 10486 left NULL (no 2025-edition '
          || 'card; Ben D1 A) | Ben "All recommended" Oct 30 22:14 ET | relay md5 {md51}')
  RETURNING id INTO v_lid1;

  ---------------------------------------------------------------- W2 venue status
  UPDATE venues v SET status = 'closed'
    FROM (VALUES
    {sts_vals}) AS x(venue_id, old_status, new_status)
   WHERE v.id = x.venue_id AND v.status::text = x.old_status AND x.old_status = 'active' AND x.new_status = 'closed';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'venue status rows updated: %', v_n; END IF;

  ---------------------------------------------------------------- W3 prices
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT x.venue_id, x.tier::smallint, x.symbol_raw, x.currency, 'guide_ingest', 'published_symbol', 'michelin', x.url,
         x.captured_at::timestamptz, NULL
    FROM (VALUES
    {pr_vals}) AS x(op, venue_id, tier, symbol_raw, currency, url, captured_at)
   WHERE x.op = 'price-ins';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'price rows inserted: %', v_n; END IF;
  UPDATE price p
     SET tier = x.tier::smallint, symbol_raw = x.symbol_raw, currency = x.currency, source = 'guide_ingest',
         method = 'published_symbol', publisher = 'michelin', source_url = x.url,
         captured_at = x.captured_at::timestamptz, confidence = NULL
    FROM (VALUES
    {pr_vals}) AS x(op, venue_id, tier, symbol_raw, currency, url, captured_at)
   WHERE x.op = 'price-upd' AND p.venue_id = x.venue_id AND p.source = 'legacy_guide' AND p.source_url IS NULL
     AND p.symbol_raw = '$$' AND p.currency IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'price rows updated: %', v_n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', 3,
          'price-card:open-items-b2-status-price-url-2026-10-30 | Turkey follow-ups: Sankai by Nagaya INSERT TRY 4 (live card); '
          || 'Efendy Istanbul legacy $$ -> TRY 2 (archive card Jan 6, 2026, the card left the guide after Jan 28); Lucien Arkas Baglari '
          || 'legacy $$ -> TRY 2 (LA Mahzen live card) | Ben D4 A Oct 30 22:14 ET | relay md5 {md51}')
  RETURNING id INTO v_lid2;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM awards) <> 23358 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM price) <> 7731 THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> 369 THEN RAISE EXCEPTION 'closed venues after'; END IF;
  IF v_lid1 <> 168 OR v_lid2 <> 169 OR (SELECT max(id) FROM source_capture_ledger) <> 169
    THEN RAISE EXCEPTION 'ledger ids % %', v_lid1, v_lid2; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998) <> 7 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'awards' AND action = 'UPDATE'
         AND row_pk IN ('10493', '10908') AND (old_row - 'source_url') = (new_row - 'source_url')
         AND old_row->>'source_url' IS NULL) <> 2
    THEN RAISE EXCEPTION 'audit awards UPDATE rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'venues' AND action = 'UPDATE'
         AND row_pk IN ('ve_fff5bda31e', 've_b3825c7559') AND (old_row - 'status') = (new_row - 'status')
         AND old_row->>'status' = 'active' AND new_row->>'status' = 'closed') <> 2
    THEN RAISE EXCEPTION 'audit venues UPDATE rows (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'price' AND action = 'INSERT' AND row_pk = 've_f088b7a06a') <> 1
    THEN RAISE EXCEPTION 'audit price INSERT row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 118998 AND table_name = 'price' AND action = 'UPDATE'
         AND row_pk IN ('ve_51ce2088a5', 've_f8013e6d34') AND old_row->>'source' = 'legacy_guide') <> 2
    THEN RAISE EXCEPTION 'audit price UPDATE rows'; END IF;
  IF (SELECT count(*) FROM awards a JOIN (VALUES
    {url_vals}) AS x(award_id, venue_id, category, url)
        ON a.id = x.award_id AND a.source_url = x.url AND a.year = 2025) <> 2
    THEN RAISE EXCEPTION 'award rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM price p JOIN (VALUES
    {pr_vals}) AS x(op, venue_id, tier, symbol_raw, currency, url, captured_at)
        ON p.venue_id = x.venue_id AND p.tier = x.tier AND p.symbol_raw = x.symbol_raw AND p.currency = x.currency
       AND p.source_url = x.url AND p.captured_at = x.captured_at::timestamptz
     WHERE p.source = 'guide_ingest' AND p.method = 'published_symbol' AND p.publisher = 'michelin' AND p.confidence IS NULL) <> 3
    THEN RAISE EXCEPTION 'price rows after do not match relay'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 10486 AND source_url IS NULL) <> 1 THEN RAISE EXCEPTION 'Chay Garden 10486 changed'; END IF;
END
$do$;
COMMIT;
"""

# ------------------------------------------------------------------ file 2
t2, r2, sha2, md52 = relay("relay-file2.txt")
mv = [r for r in r2 if r[0] == "move"]
nc = [r for r in r2 if r[0] == "newcity"]
dl = [r for r in r2 if r[0] == "delcity"]
al = [r for r in r2 if r[0] == "alias"]
rs = [r for r in r2 if r[0] == "resolve"]
assert (len(mv), len(nc), len(dl), len(al)) == (9, 1, 5, 3)
n_audit = 1 + len(mv) + 2 * len(mv) + len(dl) + len(al)

mv_vals = ",\n    ".join(
    f"({q(r[1])}, {q(r[2])}, {q(r[3])}, {q(r[4])}, {q(r[5])}, {q(r[6])}, {q(r[7])})" for r in mv)
MV = f"(VALUES\n    {mv_vals}) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug)"
dl_vals = ", ".join(f"({q(r[1])}, {q(r[2])})" for r in dl)
DL = f"(VALUES {dl_vals}) AS d(city_id, city_slug)"
al_vals = ", ".join(f"({q(r[1])}, {q(r[2])})" for r in al)
AL = f"(VALUES {al_vals}) AS ax(alias, city_id)"
rs_vals = ", ".join(f"({q(r[1])}, {q(r[2])})" for r in rs)
RS = f"(VALUES {rs_vals}) AS h(n_full, exp_city)"
c = nc[0]  # newcity|id|slug|display|copy_from

F2 = f"""-- cities-turkey-michelin-city-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 2, file 2 of 2 (item 4: Turkey city policy).
-- RUN IN THE SUPABASE SQL EDITOR (the file holds DELETE statements; the Write connector prompt closes by itself on those).
-- Run file 1 (open-items-b2-status-price-url-2026-10-30.sql) first: the audit gate expects its 7 rows (last id 119005).
--
-- Ben: Oct 30 22:14 ET "All recommended": D7 A (Michelin city = the city in the card URL, as the Urla -> Izmir rule),
--   D8 A (aliases for the town names only; no alias for the province Mugla or the region Cappadocia), D9 A (two files).
-- Evidence: live Michelin cards read Oct 31 (address lines) and Oct 30 (card URL city); see the handoff.
--
-- What this file does (one transaction, one DO block):
--   1. Inserts city {c[1]} (= 'ci_' || left(md5('{c[2]}'), 10)), slug {c[2]}, display "{c[3]}", copied from {c[4]} (Mugla:
--      Turkey / TR, kind city, region aegean-coast), venues_count 1.
--   2. Moves 9 venues (venues.city_id only):
--      Bagarasi, Mandalya (Mugla) and Mezra Yalikavak (Yalikavak) -> Bodrum; Mezegi (Mugla) -> Fethiye;
--      Revithia (Cappadocia), Babayan Evi Restaurant and Old Greek House (Nevsehir) -> Urgup;
--      Asma Yapragi (Alacati) -> Izmir; Casa Lavanda (Sile) -> Istanbul. Kitchen by Osman Sezener stays in Bodrum.
--   3. Slugs: each old canonical row becomes non-canonical (old URL keeps working); the new canonical row is
--      <target city slug>/<slug rule of the live name>. Old non-canonical rows stay. No row is deleted.
--   4. Deletes the 5 empty cities: Alacati, Sile, Mugla, Cappadocia, Yalikavak (gate: 0 venues, 0 aliases).
--      Nevsehir stays (Happena). Region rows do not change.
--   5. Inserts 3 aliases with hand audit rows: alacati -> Izmir, yalikavak -> Bodrum, sile -> Istanbul.
--   cities.venues_count of the target cities is not changed (open item: the venues_count recount, Ben decides).
--   city_label_source rows are source labels and do not change. No redirect row. No ledger row.
--   Audit rows: cities 1 INSERT + 5 DELETE, venues 9 UPDATE, slugs 9 UPDATE + 9 INSERT, city_aliases 3 INSERT (hand) = {n_audit}.
-- Relay: open-items-b2-build/relay-file2.txt, sha256 {sha2}, md5 {md52}.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $tr$
DECLARE
  rel_txt constant text := $rel${t2}$rel$;
  x       bigint;
  x2      bigint;
  t       text;
  aud_max bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{sha2}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  SELECT count(*) INTO x FROM cities;                        IF x <> 3263  THEN RAISE EXCEPTION 'cities before % (expected 3263)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 262   THEN RAISE EXCEPTION 'city_aliases before % (expected 262)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects before % (expected 9)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12915 THEN RAISE EXCEPTION 'slugs before % (expected 12915)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1611  THEN RAISE EXCEPTION 'non-canonical before % (expected 1611)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 23358 THEN RAISE EXCEPTION 'awards before % (expected 23358)', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24005 THEN RAISE EXCEPTION 'city_label_source before % (expected 24005)', x; END IF;
  SELECT max(id) INTO aud_max FROM audit_log;
  IF aud_max <> 119005 THEN RAISE EXCEPTION 'audit_log last id % (expected 119005; run file 1 first)', aud_max; END IF;

  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count, E'\\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.country_iso = 'TR';
  IF t IS DISTINCT FROM '1227ad8ac810839e5a04af257fe9e232' THEN RAISE EXCEPTION 'Turkey city rows changed: %', t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id))
    INTO t FROM venues v WHERE v.id IN (SELECT m.venue_id FROM {MV});
  IF t IS DISTINCT FROM '06b880db3910f4f06866df938cb0dd8d' THEN RAISE EXCEPTION 'venue rows changed: %', t; END IF;
  SELECT md5(string_agg(s.venue_id||'|'||s.property_id||'|'||s.city_slug||'|'||s.slug||'|'||s.is_canonical, E'\\n' ORDER BY s.venue_id, s.city_slug, s.slug))
    INTO t FROM slugs s WHERE s.venue_id IN (SELECT m.venue_id FROM {MV});
  IF t IS DISTINCT FROM 'bea73603d88386860afb56cab877d805' THEN RAISE EXCEPTION 'slug rows changed: %', t; END IF;

  IF {q(c[1])} <> 'ci_' || left(md5({q(c[2])}), 10) THEN RAISE EXCEPTION 'new city id rule'; END IF;
  SELECT count(*) INTO x FROM cities WHERE id = {q(c[1])} OR slug = {q(c[2])};
  IF x <> 0 THEN RAISE EXCEPTION 'new city clashes with % cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a WHERE a.alias IN ({q(c[2])}) OR a.alias IN (SELECT ax.alias FROM {AL});
  IF x <> 0 THEN RAISE EXCEPTION 'aliases already present: %', x; END IF;

  -- each move: venue in the from city, exactly 1 canonical slug = the old slug, new slug = slug rule of the live name, free
  SELECT count(*) INTO x FROM {MV}
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.from_city AND v.status = 'active'
    JOIN cities cf ON cf.id = m.from_city AND cf.slug = m.old_city_slug
   WHERE (EXISTS (SELECT 1 FROM cities ct WHERE ct.id = m.to_city AND ct.slug = m.to_city_slug AND ct.country_iso = 'TR')
          OR (m.to_city = {q(c[1])} AND m.to_city_slug = {q(c[2])}))
     AND m.new_slug = trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))
     AND (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) = 1
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
                    AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug)
     AND NOT EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug);
  IF x <> 9 THEN RAISE EXCEPTION 'move rows that pass the pre-check: % (expected 9)', x; END IF;

  -- each city to delete holds only venues that move, and no alias
  SELECT count(*) INTO x FROM {DL}
   WHERE EXISTS (SELECT 1 FROM cities c WHERE c.id = d.city_id AND c.slug = d.city_slug)
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = d.city_id AND v.id NOT IN (SELECT m.venue_id FROM {MV}))
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = d.city_id);
  IF x <> 5 THEN RAISE EXCEPTION 'cities to delete that pass the pre-check: % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM redirects r, {DL}
   WHERE r.from_path LIKE '/'||d.city_slug||'/%' OR r.to_path LIKE '/'||d.city_slug||'/%';
  IF x <> 0 THEN RAISE EXCEPTION 'city paths in redirects: %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = 'rg_fbbde783f7'; IF x <> 6 THEN RAISE EXCEPTION 'aegean-coast cities before %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = 'rg_341c9da864'; IF x <> 4 THEN RAISE EXCEPTION 'cappadocia cities before %', x; END IF;

  ---------------------------------------------------------------- WRITE 1: new city
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT {q(c[1])}, {q(c[2])}, {q(c[3])}, c.country, c.country_iso, c.kind, c.region_id, NULL, NULL, 1
    FROM cities c WHERE c.id = {q(c[4])};
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'city insert % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 2: move the venues
  UPDATE venues v SET city_id = m.to_city FROM {MV}
   WHERE v.id = m.venue_id AND v.city_id = m.from_city;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 9 THEN RAISE EXCEPTION 'venue moves % (expected 9)', x; END IF;

  ---------------------------------------------------------------- WRITE 3: slugs
  UPDATE slugs s SET is_canonical = false FROM {MV}
   WHERE s.venue_id = m.venue_id AND s.property_id = 'eats' AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND s.is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 9 THEN RAISE EXCEPTION 'old canonical slug updates % (expected 9)', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', m.to_city_slug, m.new_slug, m.venue_id, true FROM {MV};
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 9 THEN RAISE EXCEPTION 'new canonical slug inserts % (expected 9)', x; END IF;

  ---------------------------------------------------------------- WRITE 4: delete the empty cities
  DELETE FROM cities c USING {DL}
   WHERE c.id = d.city_id AND c.slug = d.city_slug
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = c.id)
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = c.id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 5 THEN RAISE EXCEPTION 'city deletes % (expected 5)', x; END IF;

  ---------------------------------------------------------------- WRITE 5: aliases, with hand audit rows
  INSERT INTO city_aliases (alias, city_id) SELECT ax.alias, ax.city_id FROM {AL};
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'alias inserts % (expected 3)', x; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a) FROM city_aliases a
   WHERE a.alias IN (SELECT ax.alias FROM {AL}) ORDER BY a.alias;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'alias hand audit rows % (expected 3)', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM cities;                        IF x <> 3259  THEN RAISE EXCEPTION 'cities after % (expected 3259)', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                  IF x <> 265   THEN RAISE EXCEPTION 'city_aliases after % (expected 265)', x; END IF;
  SELECT count(*) INTO x FROM redirects;                     IF x <> 9     THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                         IF x <> 12924 THEN RAISE EXCEPTION 'slugs after % (expected 12924)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;  IF x <> 1620  THEN RAISE EXCEPTION 'non-canonical after % (expected 1620)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;      IF x <> 11304 THEN RAISE EXCEPTION 'canonical after % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM venues;                        IF x <> 11304 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;                        IF x <> 23358 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;                      IF x <> 11304 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;             IF x <> 24005 THEN RAISE EXCEPTION 'city_label_source changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE country_iso = 'TR'; IF x <> 9 THEN RAISE EXCEPTION 'Turkey cities after % (expected 9)', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = 'rg_fbbde783f7'; IF x <> 4 THEN RAISE EXCEPTION 'aegean-coast cities after %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = 'rg_341c9da864'; IF x <> 3 THEN RAISE EXCEPTION 'cappadocia cities after %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;
  SELECT count(*) INTO x FROM {MV}
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.to_city
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND NOT s.is_canonical);
  IF x <> 9 THEN RAISE EXCEPTION 'moved venues as planned after: % (expected 9)', x; END IF;
  SELECT count(*) INTO x FROM cities c JOIN {DL} ON c.id = d.city_id;
  IF x <> 0 THEN RAISE EXCEPTION 'deleted cities still present: %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE city_id = 'ci_315bed8de9';
  IF x <> 1 THEN RAISE EXCEPTION 'Nevsehir venues after % (expected 1, Happena)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> {n_audit} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {n_audit})', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'cities' AND action = 'INSERT' AND row_pk = {q(c[1])};
  IF x <> 1 THEN RAISE EXCEPTION 'audit city insert %', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {DL} ON a.row_pk = d.city_id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'DELETE' AND a.new_row IS NULL AND a.old_row->>'slug' = d.city_slug;
  IF x <> 5 THEN RAISE EXCEPTION 'audit city deletes % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {MV} ON a.row_pk = m.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE'
     AND (a.old_row - 'city_id') = (a.new_row - 'city_id') AND a.old_row->>'city_id' = m.from_city AND a.new_row->>'city_id' = m.to_city;
  IF x <> 9 THEN RAISE EXCEPTION 'audit venue updates % (expected 9, city_id only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a WHERE a.id > aud_max AND a.table_name = 'slugs'
     AND a.row_pk IN (SELECT m.venue_id FROM {MV});
  IF x <> 18 THEN RAISE EXCEPTION 'audit slug rows % (expected 18)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN {AL} ON a.row_pk = ax.alias
   WHERE a.id > aud_max AND a.table_name = 'city_aliases' AND a.action = 'INSERT' AND a.old_row IS NULL AND a.new_row->>'city_id' = ax.city_id;
  IF x <> 3 THEN RAISE EXCEPTION 'audit alias inserts % (expected 3)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter TR): each label gives exactly the expected city;
  -- the labels of the province Mugla and the region Cappadocia give no city (no alias, by the alias rule).
  WITH cand AS (
    SELECT h.n_full, h.exp_city, c.id FROM {RS} JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, h.exp_city, c.id FROM {RS} JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, h.exp_city, a.city_id FROM {RS} JOIN city_aliases a ON a.alias = h.n_full)
  SELECT count(*) FILTER (WHERE ci.id = cand.exp_city), count(*) FILTER (WHERE ci.id IS DISTINCT FROM cand.exp_city)
    INTO x, x2
    FROM cand JOIN cities ci ON ci.id = cand.id AND ci.country_iso = 'TR';
  IF x <> {sum(1 for r in rs if r[2] != '-')} OR x2 <> 0 THEN RAISE EXCEPTION 'label resolution: % expected hits, % other hits', x, x2; END IF;

  RAISE NOTICE 'OK: 1 city inserted, 9 venues moved, 18 slug rows, 5 cities deleted, 3 aliases, {n_audit} audit rows';
END
$tr$;
COMMIT;
"""

(DOCS / "open-items-b2-status-price-url-2026-10-30.sql").write_text(F1, encoding="utf-8")
(DOCS / "cities-turkey-michelin-city-2026-10-30.sql").write_text(F2, encoding="utf-8")
print("file1 relay sha256", sha1, "md5", md51)
print("file2 relay sha256", sha2, "md5", md52)
