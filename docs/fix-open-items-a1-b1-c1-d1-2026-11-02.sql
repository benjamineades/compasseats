-- fix-open-items-a1-b1-c1-d1-2026-11-02.sql
-- CompassEats, Nov 2 2026. Open items 9, 11, 8 (part), 14 and 18 (status) of handoff-it-status-names-done-2026-11-02.md.
-- Ben: Nov 2 08:31 ET "A1 and B1, then close item 12. C1, D1, F1". This file runs only after his "go".
-- A1 rename batch rename-open-items-names-2026-11-02 (R2, own site and card read Nov 2). Old slugs stay as non-canonical rows.
--    ve_c0eba7ae71 Naramachi Historic District -> Naramachi Kuko (nara)
--    ve_f29878f198 Marbella -> BACK (marbella)
--    ve_c18fc53635 Pamplona -> Europa (pamplona)
-- B1 delete 4 junk venues under the contamination rule (Ben, Sep 28). Each has 1 Michelin 2025 row with no URL, no other award. Old URLs 404, no redirect.
--    ve_060efda1ae Tokyo (12689), ve_7b85d0d345 Shinjuku City (12648), ve_2593b20be1 Tokyo Ramen Street (12673), ve_d8c9373112 Daimaru Shinsaibashi (7091).
--    Held: ve_02074ec7f9 Dialog in the Dark Japan (also has a Forbes 2020 row).
-- C1 city split. ci_76107a3a0c "Saint-Rémy" holds 2 towns. New city ci_931967f233 Saint-Rémy-de-Provence (region Provence) gets
--    L'Auberge de Saint-Rémy ve_4e77c0295c, La Table de Tourrel ve_b99c2cc8b6 (card URLs saint-rmy-de-provence) and
--    Fanny rey et jonathan wahid ve_77657c7bbf (labels). The alias "saint remy de provence" moves to the new city.
--    Cédric Burtin ve_023efa5fc2 stays in ci_76107a3a0c (card URL bourgogne-franche-comte/saint-rmy). That city moves to region Burgundy.
--    Duplicate question (Fanny rey et jonathan wahid = L'Auberge) holds. City source labels do not change. No ledger row (Telluride precedent).
-- D1 Le Manoir ve_7b865a33b7 to closed, status only. Own site belmond.com (read Nov 2): "now closed for redevelopment and will reopen in 2027";
--    "closed until summer 2027". Sep 28 temporary-closure rule, E1 precedent. Name and city do not change. Recheck summer 2027. No ledger row.
-- Item 12 and F1: no write.
-- Expected after: venues 11,297 (active 10,932, closed 365); awards 25,081; slugs 13,008 (canonical 11,297, non-canonical 1,711);
--   listings 11,297; blurbs 142; price 7,730; city_label_source 23,993; cities 3,263, venues_count sum 10,932; city_aliases 266;
--   rename_batches 24, rename_rows 1,285; ledger 172 rows, last id 224; audit_log +53.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; bid bigint; n bigint; s text; r record;
  c_new constant text := 'ci_931967f233';
  c_old constant text := 'ci_76107a3a0c';
  rg_prov constant text := 'rg_a15db730ad';
  rg_burg constant text := 'rg_a8bba0ac99';
  vdel constant text[] := ARRAY['ve_060efda1ae','ve_7b85d0d345','ve_2593b20be1','ve_d8c9373112'];
  adel constant bigint[] := ARRAY[12689,12648,12673,7091];
  ldel constant bigint[] := ARRAY[13716,13717,13648,13649,13686,13687,5054,5055];
  vmov constant text[] := ARRAY['ve_4e77c0295c','ve_77657c7bbf','ve_b99c2cc8b6'];
  vren constant text[] := ARRAY['ve_c0eba7ae71','ve_f29878f198','ve_c18fc53635'];
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 13:32 UTC)
  IF (SELECT count(*) FROM venues) <> 11301 OR (SELECT count(*) FROM venues WHERE status='active') <> 10937 OR (SELECT count(*) FROM venues WHERE status='closed') <> 364 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25085 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13006 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1705 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11301 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7734 THEN RAISE EXCEPTION 'listings/blurbs/price before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24001 OR (SELECT count(*) FROM city_aliases) <> 266 OR (SELECT count(*) FROM redirects) <> 9 THEN RAISE EXCEPTION 'labels/aliases/redirects before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3262 OR (SELECT sum(venues_count) FROM cities) <> 10937 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 23 OR (SELECT count(*) FROM rename_rows) <> 1282 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 170 OR led_max <> 222 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118077 OR aud_max <> 123591 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;

  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v
   WHERE v.id IN ('ve_c0eba7ae71','ve_f29878f198','ve_c18fc53635','ve_060efda1ae','ve_7b85d0d345','ve_2593b20be1','ve_d8c9373112','ve_023efa5fc2','ve_77657c7bbf','ve_4e77c0295c','ve_b99c2cc8b6','ve_7b865a33b7');
  IF s IS DISTINCT FROM 'e8beefed8bcbd73af1a83298e0c8ca0e' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;

  -- A1 gates
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='rename-open-items-names-2026-11-02') THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = ANY (vren)) THEN RAISE EXCEPTION 'earlier rename row'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id = ANY (vren)) THEN RAISE EXCEPTION 'blurb on a renamed venue'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE (city_slug,slug) IN (('nara','naramachi-kuko'),('marbella','back'),('pamplona','europa'))) THEN RAISE EXCEPTION 'new slug in use'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE (city_id='ci_bb8b20c99f' AND norm_key='naramachikuko') OR (city_id='ci_83c2964a8f' AND norm_key='back') OR (city_id='ci_1fda8dfc8e' AND norm_key='europa')) THEN RAISE EXCEPTION 'norm_key collision'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '/(nara|marbella|pamplona)/' OR to_path ~ '/(nara|marbella|pamplona)/') THEN RAISE EXCEPTION 'redirect on a rename path'; END IF;

  -- B1 gates: full venue pre-check, all 10 foreign key tables
  SELECT md5(string_agg(p.t, E'\n' ORDER BY p.vid COLLATE "C")), count(*) INTO s, n FROM (
    SELECT v.id vid, v.id||'|'||v.name||'|'||a.id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||pr.symbol_raw||'|'||pr.source::text||'|'||sl.city_slug||'/'||sl.slug||'|'||(SELECT string_agg(c.id::text||':'||c.label||':'||c.publisher, ',' ORDER BY c.id) FROM city_label_source c WHERE c.venue_id=v.id) t
      FROM venues v JOIN awards a ON a.venue_id=v.id JOIN price pr ON pr.venue_id=v.id JOIN slugs sl ON sl.venue_id=v.id
     WHERE v.id = ANY (vdel)) p;
  IF n <> 4 OR s IS DISTINCT FROM '5024550244e52db007906e0e2d26c42f' THEN RAISE EXCEPTION 'delete plan fingerprint % rows %', s, n; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = ANY (vdel)) <> 4 THEN RAISE EXCEPTION 'awards on junk venues'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = ANY (adel) AND venue_id = ANY (vdel) AND source_id='michelin' AND year=2025 AND source_url IS NULL) <> 4 THEN RAISE EXCEPTION 'award rows not as planned'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id = ANY (vdel) AND source::text='legacy_guide') <> 4 OR (SELECT count(*) FROM price WHERE venue_id = ANY (vdel)) <> 4 THEN RAISE EXCEPTION 'price on junk venues'; END IF;
  IF (SELECT count(*) FROM city_label_source WHERE venue_id = ANY (vdel)) <> 8 OR (SELECT count(*) FROM city_label_source WHERE id = ANY (ldel) AND venue_id = ANY (vdel) AND publisher='michelin') <> 8 THEN RAISE EXCEPTION 'labels on junk venues'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = ANY (vdel)) <> 4 THEN RAISE EXCEPTION 'listings on junk venues'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = ANY (vdel)) <> 4 OR (SELECT count(*) FROM slugs WHERE venue_id = ANY (vdel) AND is_canonical) <> 4 THEN RAISE EXCEPTION 'slugs on junk venues'; END IF;
  IF (SELECT count(*) FROM blurbs WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM addresses WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM geo WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM hours WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM photo_refs WHERE venue_id = ANY (vdel)) <> 0 THEN RAISE EXCEPTION 'other child rows on junk venues'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = ANY (vdel)) THEN RAISE EXCEPTION 'rename row on a junk venue'; END IF;
  IF EXISTS (SELECT 1 FROM ingest_rows WHERE raw::text ~ '(ve_060efda1ae|ve_7b85d0d345|ve_2593b20be1|ve_d8c9373112)') THEN RAISE EXCEPTION 'ingest row on a junk venue'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '/(tokyo/tokyo|tokyo/shinjuku-city|tokyo/tokyo-ramen-street|osaka/daimaru-shinsaibashi)' OR to_path ~ '/(tokyo/tokyo|tokyo/shinjuku-city|tokyo/tokyo-ramen-street|osaka/daimaru-shinsaibashi)') THEN RAISE EXCEPTION 'redirect on a junk path'; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_ef0cc10ff4') <> 595 OR (SELECT venues_count FROM cities WHERE id='ci_d76028f421') <> 157 THEN RAISE EXCEPTION 'Tokyo / Osaka count'; END IF;

  -- C1 gates
  IF c_new <> 'ci_'||left(md5('saint-remy-de-provence'),10) THEN RAISE EXCEPTION 'new city id rule'; END IF;
  SELECT md5(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||coalesce(c.lat::text,'-')||'|'||coalesce(c.lng::text,'-')||'|'||c.venues_count) INTO s FROM cities c WHERE c.id=c_old;
  IF s IS DISTINCT FROM '0af1fb2a2236a860d54a08d04a34f76e' THEN RAISE EXCEPTION 'old city fingerprint %', s; END IF;
  IF (SELECT count(*) FROM venues WHERE city_id=c_old) <> 4 THEN RAISE EXCEPTION 'venues in old city'; END IF;
  IF EXISTS (SELECT 1 FROM cities c WHERE c.id=c_new OR c.slug='saint-remy-de-provence' OR btrim(regexp_replace(lower(f_unaccent(c.display)),'[^a-z0-9]+',' ','g'))='saint remy de provence') THEN RAISE EXCEPTION 'new city clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='saint-remy-de-provence') THEN RAISE EXCEPTION 'slugs under new city'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ 'saint-remy' OR to_path ~ 'saint-remy') THEN RAISE EXCEPTION 'redirect on saint-remy'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = ANY (vmov)) <> 3 OR (SELECT count(*) FROM slugs WHERE venue_id = ANY (vmov) AND city_slug='saint-remy' AND is_canonical AND property_id='eats') <> 3 THEN RAISE EXCEPTION 'slugs on moved venues'; END IF;
  IF (SELECT count(*) FROM city_aliases WHERE city_id=c_old) <> 1 OR (SELECT count(*) FROM city_aliases WHERE alias='saint remy de provence' AND city_id=c_old) <> 1 THEN RAISE EXCEPTION 'aliases on old city'; END IF;
  IF (SELECT count(*) FROM regions WHERE (id=rg_prov AND slug='provence') OR (id=rg_burg AND slug='burgundy')) <> 2 THEN RAISE EXCEPTION 'regions'; END IF;
  IF (SELECT count(*) FROM cities WHERE region_id=rg_prov) <> 44 OR (SELECT count(*) FROM cities WHERE region_id=rg_burg) <> 28 THEN RAISE EXCEPTION 'region city counts before'; END IF;

  -- D1 gates
  IF (SELECT venues_count FROM cities WHERE id='ci_aa4eceb101' AND slug='oxford') <> 1 THEN RAISE EXCEPTION 'Oxford count'; END IF;

  ---------------------------------------------------------------- WRITE 1 (A1): rename batch
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('rename-open-items-names-2026-11-02', 'staged', 'Open items 9 and 11 (Ben, Nov 2 08:31 ET "A1"): rule R2. Legacy place names replaced by the restaurant name.') RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  FOR r IN SELECT * FROM (VALUES
    (1,'ve_c0eba7ae71','Naramachi Historic District','Naramachi Kuko','https://guide.michelin.com/us/en/nara-region/nara/restaurant/naramachi-kuko','nara','naramachi-historic-district','naramachi-kuko','R2: own site https://kuko-nara.jp writes 奈良町 枸杞 and Kuko naramachi; card h1 Naramachi Kuko, read Nov 2'),
    (2,'ve_f29878f198','Marbella','BACK','https://guide.michelin.com/us/en/andalucia/marbella/restaurant/back','marbella','marbella','back','R2: own site https://backrestaurante.com writes Back Restaurante, Back and BACK over RESTAURANTE; card h1 BACK, read Nov 2'),
    (3,'ve_c18fc53635','Pamplona','Europa','https://guide.michelin.com/us/en/comunidad-foral-de-navarra/pamplona/restaurant/europa','pamplona','pamplona','europa','R2: site https://www.hoteleuropapamplona.com/en/restaurant-europa.html writes Restaurant Europa and Europa restaurant; card h1 Europa, read Nov 2; hreuropa.com did not open')
  ) t(line, vid, oldn, newn, url, cs, olds, news, ev) LOOP
    INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
    SELECT bid, r.line, v.id, v.name, r.newn, 'michelin', r.url, 'rename',
           jsonb_build_object('note', r.ev, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', r.cs, 'slug', r.olds)
      FROM venues v WHERE v.id=r.vid AND v.name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename row %', r.vid; END IF;
    UPDATE venues SET name=r.newn WHERE id=r.vid AND name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename %', r.vid; END IF;
    IF trim(both '-' from regexp_replace(lower(f_unaccent(r.newn)),'[^a-z0-9]+','-','g')) <> r.news THEN RAISE EXCEPTION 'slug rule %', r.vid; END IF;
    UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug=r.cs AND slug=r.olds AND is_canonical;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', r.vid; END IF;
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.news, r.vid, true);
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'name', 3, 'rename-apply:rename-open-items-names-2026-11-02 | gated SQL file docs/fix-open-items-a1-b1-c1-d1-2026-11-02.sql | 3 legacy place names follow the Michelin card name, R2: Naramachi Kuko, BACK, Europa');

  ---------------------------------------------------------------- WRITE 2 (B1): delete 4 junk venues
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL FROM city_label_source c WHERE c.id = ANY (ldel) ORDER BY c.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'hand audit labels %', n; END IF;
  DELETE FROM city_label_source WHERE id = ANY (ldel) AND venue_id = ANY (vdel);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'labels deleted %', n; END IF;
  DELETE FROM awards WHERE id = ANY (adel) AND venue_id = ANY (vdel) AND source_id='michelin' AND year=2025 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'awards deleted %', n; END IF;
  DELETE FROM price WHERE venue_id = ANY (vdel);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'price deleted %', n; END IF;
  DELETE FROM slugs WHERE venue_id = ANY (vdel);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'slugs deleted %', n; END IF;
  DELETE FROM listings WHERE venue_id = ANY (vdel);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'listings deleted %', n; END IF;
  DELETE FROM venues WHERE id = ANY (vdel);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'venues deleted %', n; END IF;
  UPDATE cities SET venues_count=592 WHERE id='ci_ef0cc10ff4' AND venues_count=595;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Tokyo %', n; END IF;
  UPDATE cities SET venues_count=156 WHERE id='ci_d76028f421' AND venues_count=157;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Osaka %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 4, 'cleanup:cleanup-michelin-jp-2025-junk-4 | contamination rule (Ben, Sep 28; Nov 2 08:31 ET "B1"): 4 legacy Michelin 2025 Japan rows on place-name venues with no provable pairing, deleted with their venues | award ids 7091,12648,12673,12689 | old URLs 404, no redirect | Dialog in the Dark Japan holds (Forbes row)');

  ---------------------------------------------------------------- WRITE 3 (C1): city split
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  SELECT c_new, 'saint-remy-de-provence', 'Saint-Rémy-de-Provence', c.country, c.country_iso, c.kind, rg_prov, c.lat, c.lng, 3 FROM cities c WHERE c.id=c_old;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city insert %', n; END IF;
  UPDATE cities SET venues_count=1, region_id=rg_burg WHERE id=c_old AND venues_count=4 AND region_id=rg_prov;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old city update %', n; END IF;
  UPDATE venues SET city_id=c_new WHERE id = ANY (vmov) AND city_id=c_old;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'venue move %', n; END IF;
  FOR r IN SELECT * FROM (VALUES ('ve_4e77c0295c','l-auberge-de-saint-remy'),('ve_77657c7bbf','fanny-rey-et-jonathan-wahid'),('ve_b99c2cc8b6','la-table-de-tourrel')) t(vid, sl) LOOP
    IF r.sl <> (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(v.name)),'[^a-z0-9]+','-','g')) FROM venues v WHERE v.id=r.vid) THEN RAISE EXCEPTION 'slug rule %', r.vid; END IF;
    UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug='saint-remy' AND slug=r.sl AND is_canonical;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', r.vid; END IF;
    INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','saint-remy-de-provence',r.sl,r.vid,true);
  END LOOP;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'UPDATE', to_jsonb(a), jsonb_set(to_jsonb(a),'{city_id}',to_jsonb(c_new)) FROM city_aliases a WHERE a.alias='saint remy de provence' AND a.city_id=c_old;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'alias hand audit %', n; END IF;
  UPDATE city_aliases SET city_id=c_new WHERE alias='saint remy de provence' AND city_id=c_old;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'alias %', n; END IF;

  ---------------------------------------------------------------- WRITE 4 (D1): Le Manoir, status only
  UPDATE venues SET status='closed' WHERE id='ve_7b865a33b7' AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE cities SET venues_count=0 WHERE id='ci_aa4eceb101' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Oxford %', n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11297 OR (SELECT count(*) FROM venues WHERE status='active') <> 10932 OR (SELECT count(*) FROM venues WHERE status='closed') <> 365 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25081 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13008 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1711 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11297 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11297 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'listings/blurbs/price after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 23993 OR (SELECT count(*) FROM city_aliases) <> 266 OR (SELECT count(*) FROM redirects) <> 9 THEN RAISE EXCEPTION 'labels/aliases/redirects after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3263 OR (SELECT sum(venues_count) FROM cities) <> 10932 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF (SELECT count(*) FROM cities WHERE region_id=rg_prov) <> 44 OR (SELECT count(*) FROM cities WHERE region_id=rg_burg) <> 29 THEN RAISE EXCEPTION 'region city counts after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 24 OR (SELECT count(*) FROM rename_rows) <> 1285 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 172 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical AND sl.property_id='eats' GROUP BY v.id HAVING count(sl.slug) <> 1) THEN RAISE EXCEPTION 'canonical slug count'; END IF;
  IF (SELECT count(*) FROM venues WHERE id = ANY (vdel)) + (SELECT count(*) FROM awards WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM price WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM city_label_source WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM slugs WHERE venue_id = ANY (vdel)) + (SELECT count(*) FROM listings WHERE venue_id = ANY (vdel)) <> 0 THEN RAISE EXCEPTION 'rows remain on deleted venues'; END IF;
  SELECT string_agg(v.name||' '||sl.city_slug||'/'||sl.slug, ', ' ORDER BY v.id COLLATE "C") INTO s FROM venues v JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical
   WHERE v.id IN ('ve_c0eba7ae71','ve_f29878f198','ve_c18fc53635','ve_023efa5fc2','ve_4e77c0295c','ve_77657c7bbf','ve_b99c2cc8b6');
  IF s IS DISTINCT FROM 'Cédric Burtin saint-remy/restaurant-cedric-burtin, L''Auberge de Saint-Rémy saint-remy-de-provence/l-auberge-de-saint-remy, Fanny rey et jonathan wahid saint-remy-de-provence/fanny-rey-et-jonathan-wahid, La Table de Tourrel saint-remy-de-provence/la-table-de-tourrel, Naramachi Kuko nara/naramachi-kuko, Europa pamplona/europa, BACK marbella/back' THEN RAISE EXCEPTION 'names after: %', s; END IF;
  IF (SELECT count(*) FROM venues WHERE id='ve_023efa5fc2' AND city_id=c_old AND status='active') <> 1 THEN RAISE EXCEPTION 'Burtin moved'; END IF;
  -- The labels must resolve as resolve.ts does (slug, display, alias, then country): each label gives exactly 1 French city.
  WITH lab AS (SELECT * FROM (VALUES ('saint remy de provence', c_new), ('saint remy', c_old)) v(n_full, want)),
  cand AS (
    SELECT h.n_full, h.want, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)),'[^a-z0-9]+',' ','g'))=h.n_full
    UNION SELECT h.n_full, h.want, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)),'[^a-z0-9]+',' ','g'))=h.n_full
    UNION SELECT h.n_full, h.want, a.city_id FROM lab h JOIN city_aliases a ON a.alias=h.n_full)
  SELECT count(*), count(*) FILTER (WHERE c.id=c.want) INTO n, bid FROM cand c JOIN cities ci ON ci.id=c.id WHERE lower(ci.country_iso)='fr';
  IF n <> 2 OR bid <> 2 THEN RAISE EXCEPTION 'label resolution % / %', n, bid; END IF;
  -- Audit
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:DELETE=4,cities:INSERT=1,cities:UPDATE=4,city_aliases:UPDATE=1,city_label_source:DELETE=8,listings:DELETE=4,price:DELETE=4,slugs:DELETE=4,slugs:INSERT=6,slugs:UPDATE=6,venues:DELETE=4,venues:UPDATE=7' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND action='UPDATE' AND row_pk='ve_7b865a33b7' AND (old_row-'status')=(new_row-'status') AND new_row->>'status'='closed') <> 1 THEN RAISE EXCEPTION 'status audit'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND action='UPDATE' AND row_pk = ANY (vmov) AND (old_row-'city_id')=(new_row-'city_id') AND new_row->>'city_id'=c_new) <> 3 THEN RAISE EXCEPTION 'move audit'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND action='UPDATE' AND row_pk = ANY (vren) AND (old_row-'name'-'norm_key')=(new_row-'name'-'norm_key')) <> 3 THEN RAISE EXCEPTION 'rename audit'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
