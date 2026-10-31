-- cities-turkey-michelin-city-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 2, file 2 of 2 (item 4: Turkey city policy).
-- RUN IN THE SUPABASE SQL EDITOR (the file holds DELETE statements; the Write connector prompt closes by itself on those).
-- Run file 1 (open-items-b2-status-price-url-2026-10-30.sql) first: the audit gate expects its 7 rows (last id 119005).
--
-- Ben: Oct 30 22:14 ET "All recommended": D7 A (Michelin city = the city in the card URL, as the Urla -> Izmir rule),
--   D8 A (aliases for the town names only; no alias for the province Mugla or the region Cappadocia), D9 A (two files).
-- Evidence: live Michelin cards read Oct 31 (address lines) and Oct 30 (card URL city); see the handoff.
--
-- What this file does (one transaction, one DO block):
--   1. Inserts city ci_99beff72d5 (= 'ci_' || left(md5('fethiye'), 10)), slug fethiye, display "Fethiye", copied from ci_b74d2bda8d (Mugla:
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
--   Audit rows: cities 1 INSERT + 5 DELETE, venues 9 UPDATE, slugs 9 UPDATE + 9 INSERT, city_aliases 3 INSERT (hand) = 36.
-- Relay: open-items-b2-build/relay-file2.txt, sha256 5b0c1f6d0dce18aadda81437b6033a03c29ff6e0eff208a00f4e86b06c2a33dc, md5 bf44b227baceeb8d57469d8348c83fe9.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $tr$
DECLARE
  rel_txt constant text := $rel$newcity|ci_99beff72d5|fethiye|Fethiye|ci_b74d2bda8d
move|ve_0b63b424aa|ci_315bed8de9|ci_72be27252e|nevsehir|babayan-evi-restaurant|urgup|babayan-evi-restaurant
move|ve_0d51fc7213|ci_f0cc6ecedc|ci_c841114b89|alacat|asma-yaprag|izmir|asma-yapragi
move|ve_0e1a18ca2d|ci_b74d2bda8d|ci_99beff72d5|mugla|mezegi|fethiye|mezegi
move|ve_18edcac317|ci_b74d2bda8d|ci_026a2ee396|mugla|mandalya|bodrum|mandalya
move|ve_1cb00fa293|ci_b74d2bda8d|ci_026a2ee396|mugla|bagarasi|bodrum|bagarasi
move|ve_5410da4251|ci_e28a7ec482|ci_2609eaea1a|sile|casa-lavanda|istanbul|casa-lavanda
move|ve_6734eae626|ci_315bed8de9|ci_72be27252e|nevsehir|old-greek-house|urgup|old-greek-house
move|ve_c98ccae6d0|ci_341c9da864|ci_72be27252e|cappadocia|revithia|urgup|revithia
move|ve_de05509e50|ci_cd59e06736|ci_026a2ee396|yal-kavak|mezra-yal-kavak|bodrum|mezra-yalikavak
delcity|ci_f0cc6ecedc|alacat
delcity|ci_e28a7ec482|sile
delcity|ci_b74d2bda8d|mugla
delcity|ci_341c9da864|cappadocia
delcity|ci_cd59e06736|yal-kavak
alias|alacati|ci_c841114b89
alias|sile|ci_2609eaea1a
alias|yalikavak|ci_026a2ee396
resolve|alacati|ci_c841114b89
resolve|yalikavak|ci_026a2ee396
resolve|sile|ci_2609eaea1a
resolve|fethiye|ci_99beff72d5
resolve|bodrum|ci_026a2ee396
resolve|urgup|ci_72be27252e
resolve|izmir|ci_c841114b89
resolve|istanbul|ci_2609eaea1a
resolve|nevsehir|ci_315bed8de9
resolve|mugla|-
resolve|cappadocia|-$rel$;
  x       bigint;
  x2      bigint;
  t       text;
  aud_max bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '5b0c1f6d0dce18aadda81437b6033a03c29ff6e0eff208a00f4e86b06c2a33dc' THEN RAISE EXCEPTION 'relay sha256'; END IF;
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
             ||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id))
    INTO t FROM cities c WHERE c.country_iso = 'TR';
  IF t IS DISTINCT FROM '1227ad8ac810839e5a04af257fe9e232' THEN RAISE EXCEPTION 'Turkey city rows changed: %', t; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id))
    INTO t FROM venues v WHERE v.id IN (SELECT m.venue_id FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug));
  IF t IS DISTINCT FROM '06b880db3910f4f06866df938cb0dd8d' THEN RAISE EXCEPTION 'venue rows changed: %', t; END IF;
  SELECT md5(string_agg(s.venue_id||'|'||s.property_id||'|'||s.city_slug||'|'||s.slug||'|'||s.is_canonical, E'\n' ORDER BY s.venue_id, s.city_slug, s.slug))
    INTO t FROM slugs s WHERE s.venue_id IN (SELECT m.venue_id FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug));
  IF t IS DISTINCT FROM 'bea73603d88386860afb56cab877d805' THEN RAISE EXCEPTION 'slug rows changed: %', t; END IF;

  IF 'ci_99beff72d5' <> 'ci_' || left(md5('fethiye'), 10) THEN RAISE EXCEPTION 'new city id rule'; END IF;
  SELECT count(*) INTO x FROM cities WHERE id = 'ci_99beff72d5' OR slug = 'fethiye';
  IF x <> 0 THEN RAISE EXCEPTION 'new city clashes with % cities', x; END IF;
  SELECT count(*) INTO x FROM city_aliases a WHERE a.alias IN ('fethiye') OR a.alias IN (SELECT ax.alias FROM (VALUES ('alacati', 'ci_c841114b89'), ('sile', 'ci_2609eaea1a'), ('yalikavak', 'ci_026a2ee396')) AS ax(alias, city_id));
  IF x <> 0 THEN RAISE EXCEPTION 'aliases already present: %', x; END IF;

  -- each move: venue in the from city, exactly 1 canonical slug = the old slug, new slug = slug rule of the live name, free
  SELECT count(*) INTO x FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug)
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.from_city AND v.status = 'active'
    JOIN cities cf ON cf.id = m.from_city AND cf.slug = m.old_city_slug
   WHERE (EXISTS (SELECT 1 FROM cities ct WHERE ct.id = m.to_city AND ct.slug = m.to_city_slug AND ct.country_iso = 'TR')
          OR (m.to_city = 'ci_99beff72d5' AND m.to_city_slug = 'fethiye'))
     AND m.new_slug = trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g'))
     AND (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) = 1
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
                    AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug)
     AND NOT EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug);
  IF x <> 9 THEN RAISE EXCEPTION 'move rows that pass the pre-check: % (expected 9)', x; END IF;

  -- each city to delete holds only venues that move, and no alias
  SELECT count(*) INTO x FROM (VALUES ('ci_f0cc6ecedc', 'alacat'), ('ci_e28a7ec482', 'sile'), ('ci_b74d2bda8d', 'mugla'), ('ci_341c9da864', 'cappadocia'), ('ci_cd59e06736', 'yal-kavak')) AS d(city_id, city_slug)
   WHERE EXISTS (SELECT 1 FROM cities c WHERE c.id = d.city_id AND c.slug = d.city_slug)
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = d.city_id AND v.id NOT IN (SELECT m.venue_id FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug)))
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = d.city_id);
  IF x <> 5 THEN RAISE EXCEPTION 'cities to delete that pass the pre-check: % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM redirects r, (VALUES ('ci_f0cc6ecedc', 'alacat'), ('ci_e28a7ec482', 'sile'), ('ci_b74d2bda8d', 'mugla'), ('ci_341c9da864', 'cappadocia'), ('ci_cd59e06736', 'yal-kavak')) AS d(city_id, city_slug)
   WHERE r.from_path LIKE '/'||d.city_slug||'/%' OR r.to_path LIKE '/'||d.city_slug||'/%';
  IF x <> 0 THEN RAISE EXCEPTION 'city paths in redirects: %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = 'rg_fbbde783f7'; IF x <> 6 THEN RAISE EXCEPTION 'aegean-coast cities before %', x; END IF;
  SELECT count(*) INTO x FROM cities WHERE region_id = 'rg_341c9da864'; IF x <> 4 THEN RAISE EXCEPTION 'cappadocia cities before %', x; END IF;

  ---------------------------------------------------------------- WRITE 1: new city
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT 'ci_99beff72d5', 'fethiye', 'Fethiye', c.country, c.country_iso, c.kind, c.region_id, NULL, NULL, 1
    FROM cities c WHERE c.id = 'ci_b74d2bda8d';
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 1 THEN RAISE EXCEPTION 'city insert % (expected 1)', x; END IF;

  ---------------------------------------------------------------- WRITE 2: move the venues
  UPDATE venues v SET city_id = m.to_city FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug)
   WHERE v.id = m.venue_id AND v.city_id = m.from_city;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 9 THEN RAISE EXCEPTION 'venue moves % (expected 9)', x; END IF;

  ---------------------------------------------------------------- WRITE 3: slugs
  UPDATE slugs s SET is_canonical = false FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug)
   WHERE s.venue_id = m.venue_id AND s.property_id = 'eats' AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND s.is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 9 THEN RAISE EXCEPTION 'old canonical slug updates % (expected 9)', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', m.to_city_slug, m.new_slug, m.venue_id, true FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 9 THEN RAISE EXCEPTION 'new canonical slug inserts % (expected 9)', x; END IF;

  ---------------------------------------------------------------- WRITE 4: delete the empty cities
  DELETE FROM cities c USING (VALUES ('ci_f0cc6ecedc', 'alacat'), ('ci_e28a7ec482', 'sile'), ('ci_b74d2bda8d', 'mugla'), ('ci_341c9da864', 'cappadocia'), ('ci_cd59e06736', 'yal-kavak')) AS d(city_id, city_slug)
   WHERE c.id = d.city_id AND c.slug = d.city_slug
     AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.city_id = c.id)
     AND NOT EXISTS (SELECT 1 FROM city_aliases a WHERE a.city_id = c.id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 5 THEN RAISE EXCEPTION 'city deletes % (expected 5)', x; END IF;

  ---------------------------------------------------------------- WRITE 5: aliases, with hand audit rows
  INSERT INTO city_aliases (alias, city_id) SELECT ax.alias, ax.city_id FROM (VALUES ('alacati', 'ci_c841114b89'), ('sile', 'ci_2609eaea1a'), ('yalikavak', 'ci_026a2ee396')) AS ax(alias, city_id);
  GET DIAGNOSTICS x = ROW_COUNT;
  IF x <> 3 THEN RAISE EXCEPTION 'alias inserts % (expected 3)', x; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'INSERT', NULL, to_jsonb(a) FROM city_aliases a
   WHERE a.alias IN (SELECT ax.alias FROM (VALUES ('alacati', 'ci_c841114b89'), ('sile', 'ci_2609eaea1a'), ('yalikavak', 'ci_026a2ee396')) AS ax(alias, city_id)) ORDER BY a.alias;
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
  SELECT count(*) INTO x FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug)
    JOIN venues v ON v.id = m.venue_id AND v.city_id = m.to_city
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.to_city_slug AND s.slug = m.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = m.venue_id AND s.city_slug = m.old_city_slug AND s.slug = m.old_slug AND NOT s.is_canonical);
  IF x <> 9 THEN RAISE EXCEPTION 'moved venues as planned after: % (expected 9)', x; END IF;
  SELECT count(*) INTO x FROM cities c JOIN (VALUES ('ci_f0cc6ecedc', 'alacat'), ('ci_e28a7ec482', 'sile'), ('ci_b74d2bda8d', 'mugla'), ('ci_341c9da864', 'cappadocia'), ('ci_cd59e06736', 'yal-kavak')) AS d(city_id, city_slug) ON c.id = d.city_id;
  IF x <> 0 THEN RAISE EXCEPTION 'deleted cities still present: %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE city_id = 'ci_315bed8de9';
  IF x <> 1 THEN RAISE EXCEPTION 'Nevsehir venues after % (expected 1, Happena)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 36 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 36)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'cities' AND action = 'INSERT' AND row_pk = 'ci_99beff72d5';
  IF x <> 1 THEN RAISE EXCEPTION 'audit city insert %', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN (VALUES ('ci_f0cc6ecedc', 'alacat'), ('ci_e28a7ec482', 'sile'), ('ci_b74d2bda8d', 'mugla'), ('ci_341c9da864', 'cappadocia'), ('ci_cd59e06736', 'yal-kavak')) AS d(city_id, city_slug) ON a.row_pk = d.city_id
   WHERE a.id > aud_max AND a.table_name = 'cities' AND a.action = 'DELETE' AND a.new_row IS NULL AND a.old_row->>'slug' = d.city_slug;
  IF x <> 5 THEN RAISE EXCEPTION 'audit city deletes % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug) ON a.row_pk = m.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE'
     AND (a.old_row - 'city_id') = (a.new_row - 'city_id') AND a.old_row->>'city_id' = m.from_city AND a.new_row->>'city_id' = m.to_city;
  IF x <> 9 THEN RAISE EXCEPTION 'audit venue updates % (expected 9, city_id only)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a WHERE a.id > aud_max AND a.table_name = 'slugs'
     AND a.row_pk IN (SELECT m.venue_id FROM (VALUES
    ('ve_0b63b424aa', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'babayan-evi-restaurant', 'urgup', 'babayan-evi-restaurant'),
    ('ve_0d51fc7213', 'ci_f0cc6ecedc', 'ci_c841114b89', 'alacat', 'asma-yaprag', 'izmir', 'asma-yapragi'),
    ('ve_0e1a18ca2d', 'ci_b74d2bda8d', 'ci_99beff72d5', 'mugla', 'mezegi', 'fethiye', 'mezegi'),
    ('ve_18edcac317', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'mandalya', 'bodrum', 'mandalya'),
    ('ve_1cb00fa293', 'ci_b74d2bda8d', 'ci_026a2ee396', 'mugla', 'bagarasi', 'bodrum', 'bagarasi'),
    ('ve_5410da4251', 'ci_e28a7ec482', 'ci_2609eaea1a', 'sile', 'casa-lavanda', 'istanbul', 'casa-lavanda'),
    ('ve_6734eae626', 'ci_315bed8de9', 'ci_72be27252e', 'nevsehir', 'old-greek-house', 'urgup', 'old-greek-house'),
    ('ve_c98ccae6d0', 'ci_341c9da864', 'ci_72be27252e', 'cappadocia', 'revithia', 'urgup', 'revithia'),
    ('ve_de05509e50', 'ci_cd59e06736', 'ci_026a2ee396', 'yal-kavak', 'mezra-yal-kavak', 'bodrum', 'mezra-yalikavak')) AS m(venue_id, from_city, to_city, old_city_slug, old_slug, to_city_slug, new_slug));
  IF x <> 18 THEN RAISE EXCEPTION 'audit slug rows % (expected 18)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN (VALUES ('alacati', 'ci_c841114b89'), ('sile', 'ci_2609eaea1a'), ('yalikavak', 'ci_026a2ee396')) AS ax(alias, city_id) ON a.row_pk = ax.alias
   WHERE a.id > aud_max AND a.table_name = 'city_aliases' AND a.action = 'INSERT' AND a.old_row IS NULL AND a.new_row->>'city_id' = ax.city_id;
  IF x <> 3 THEN RAISE EXCEPTION 'audit alias inserts % (expected 3)', x; END IF;

  -- Stage-job city resolution (slug, display, alias; then the country filter TR): each label gives exactly the expected city;
  -- the labels of the province Mugla and the region Cappadocia give no city (no alias, by the alias rule).
  WITH cand AS (
    SELECT h.n_full, h.exp_city, c.id FROM (VALUES ('alacati', 'ci_c841114b89'), ('yalikavak', 'ci_026a2ee396'), ('sile', 'ci_2609eaea1a'), ('fethiye', 'ci_99beff72d5'), ('bodrum', 'ci_026a2ee396'), ('urgup', 'ci_72be27252e'), ('izmir', 'ci_c841114b89'), ('istanbul', 'ci_2609eaea1a'), ('nevsehir', 'ci_315bed8de9'), ('mugla', '-'), ('cappadocia', '-')) AS h(n_full, exp_city) JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, h.exp_city, c.id FROM (VALUES ('alacati', 'ci_c841114b89'), ('yalikavak', 'ci_026a2ee396'), ('sile', 'ci_2609eaea1a'), ('fethiye', 'ci_99beff72d5'), ('bodrum', 'ci_026a2ee396'), ('urgup', 'ci_72be27252e'), ('izmir', 'ci_c841114b89'), ('istanbul', 'ci_2609eaea1a'), ('nevsehir', 'ci_315bed8de9'), ('mugla', '-'), ('cappadocia', '-')) AS h(n_full, exp_city) JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)), '[^a-z0-9]+', ' ', 'g')) = h.n_full
    UNION
    SELECT h.n_full, h.exp_city, a.city_id FROM (VALUES ('alacati', 'ci_c841114b89'), ('yalikavak', 'ci_026a2ee396'), ('sile', 'ci_2609eaea1a'), ('fethiye', 'ci_99beff72d5'), ('bodrum', 'ci_026a2ee396'), ('urgup', 'ci_72be27252e'), ('izmir', 'ci_c841114b89'), ('istanbul', 'ci_2609eaea1a'), ('nevsehir', 'ci_315bed8de9'), ('mugla', '-'), ('cappadocia', '-')) AS h(n_full, exp_city) JOIN city_aliases a ON a.alias = h.n_full)
  SELECT count(*) FILTER (WHERE ci.id = cand.exp_city), count(*) FILTER (WHERE ci.id IS DISTINCT FROM cand.exp_city)
    INTO x, x2
    FROM cand JOIN cities ci ON ci.id = cand.id AND ci.country_iso = 'TR';
  IF x <> 9 OR x2 <> 0 THEN RAISE EXCEPTION 'label resolution: % expected hits, % other hits', x, x2; END IF;

  RAISE NOTICE 'OK: 1 city inserted, 9 venues moved, 18 slug rows, 5 cities deleted, 3 aliases, 36 audit rows';
END
$tr$;
COMMIT;
