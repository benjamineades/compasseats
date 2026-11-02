-- fix-closed-sweep-item3-2026-11-02.sql
-- CompassEats, Nov 2 2026. Closed-venue sweep item 3, the 4 venue problems. One transaction.
-- Ben: Nov 2 16:25 ET "1A, 2A, 3A, 4A, 5A". This file runs only after his "go".
-- Population: the 4 venues of Group 5 of the 201. This file changes 3. The Grill at Amangani ve_8d69af215c stays closed and not published (Ben 4A, recheck Jan 2027).
-- Evidence for all 4: docs/closed-sweep-2026-11-02/closed-sweep-item3-evidence-2026-11-02.csv.
--
-- 1A Scalottas Terroir ve_fae8dcb6f0: closed to active, published. City stays Lenzerheide (the Nov 2 Scharans match was wrong). Lenzerheide 0 to 1.
--    Rule: a seasonal closure is active. Own site scalottas-terroir.ch, Voa Principala 29: closes end of October, back "ab dem 9. Dezember" (post has no year).
--    Limit: no dated page shows 2026 service.
-- 2A Suetomi ve_779a1ac27f: closed to active, published. City stays Tokyo. Tokyo 594 to 595.
--    TABLEALL https://www.tableall.com/restaurant/220 (course available from Nov 10, 2026). Tabelog newest visit August 2026, no closed label (status read only).
-- 3A tsushimi フレンチ ve_001296abf4: closed to active, published. New city Nirasaki ci_1890364073 (= 'ci_' || left(md5('nirasaki'), 10)), no region, no coordinates, count 1.
--    Name to Tsushimi, as OAD prints it (batch rename-closed-sweep-item3-2026-11-02, same writes as scripts/rename/apply.ts).
--    Slug: /tokyo/tsushimi stays, non-canonical. /nirasaki/tsushimi becomes canonical. Tokyo count does not lose this venue: it was closed and not counted.
--    Omakase https://omakase.in/r/ts821956 (Nirasaki, bookings to Dec 31, 2026). Gault&Millau https://jp.gaultmillau.com/en/restaurants/tsushimi (Nirasaki, 2026).
--    Limit: OAD still prints Tokyo. city_label_source keeps the OAD label "Tokyo". Award row 19067 does not change.
--
-- No change: awards, price, city labels, blurbs, redirects, aliases. No ledger row (status precedent; a city, a slug and a venue-name rename have no capture). No live page changes: the live site reads the Sheet.
-- Expected after: venues 11,293 (active 10,999, closed 294); awards 25,097; slugs 13,022 (canonical 11,293, non-canonical 1,729); price 7,727; listings 11,293;
--   cities 3,265, sum 10,999; city labels 23,989; closed published 0; closed not published 294; active not published 0; rename_batches 29; rename_rows 1,301; ledger 186 rows, last id 238;
--   audit_log +13 (118,857 rows): cities INSERT 1 and UPDATE 2, listings UPDATE 3, slugs INSERT 1 and UPDATE 1, venues UPDATE 5.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text; bid bigint;
  va constant text[] := ARRAY['ve_001296abf4','ve_779a1ac27f','ve_fae8dcb6f0'];
  v_ts constant text := 've_001296abf4';  -- tsushimi フレンチ
  v_su constant text := 've_779a1ac27f';  -- Suetomi
  v_sc constant text := 've_fae8dcb6f0';  -- Scalottas Terroir
  v_gr constant text := 've_8d69af215c';  -- The Grill at Amangani, no change
  c_tokyo constant text := 'ci_ef0cc10ff4';
  c_lenz  constant text := 'ci_3177e7ddb9';
  c_nira  constant text := 'ci_1890364073';
  c_key   constant text := 'rename-closed-sweep-item3-2026-11-02';
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 21:25 UTC)
  IF (SELECT count(*) FROM venues) <> 11293 OR (SELECT count(*) FROM venues WHERE status='active') <> 10996 OR (SELECT count(*) FROM venues WHERE status='closed') <> 297 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13021 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11293 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1728 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11293 OR (SELECT count(*) FROM city_label_source) <> 23989 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3264 OR (SELECT count(*) FROM city_aliases) <> 266 THEN RAISE EXCEPTION 'blurbs redirects cities aliases before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10996 THEN RAISE EXCEPTION 'cities sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 28 OR (SELECT count(*) FROM rename_rows) <> 1300 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key=c_key) THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = ANY (va)) THEN RAISE EXCEPTION 'rename rows on the venues'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM source_capture_ledger; IF n <> 186 OR aud_max <> 238 THEN RAISE EXCEPTION 'ledger before % / %', n, aud_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118844 OR aud_max <> 124358 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Fingerprints: venues, cities, slugs, awards
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (va);
  IF s IS DISTINCT FROM '66ef6c383ccf09ea723149ba44a27366' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id COLLATE "C")) INTO s FROM cities c WHERE c.id IN (c_lenz, c_tokyo);
  IF s IS DISTINCT FROM '11a0e0b5578bda0e2d356ca311d2a87b' THEN RAISE EXCEPTION 'city fingerprint %', s; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.city_slug||'|'||x.slug||'|'||x.is_canonical, E'\n' ORDER BY x.venue_id COLLATE "C", x.slug COLLATE "C")) INTO s FROM slugs x WHERE x.venue_id = ANY (va);
  IF s IS DISTINCT FROM '56ad8962d749363b9bf635eacb877c8e' THEN RAISE EXCEPTION 'slug fingerprint %', s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id = ANY (va);
  IF s IS DISTINCT FROM '9881f9051280f5a63af2e816855d18df' THEN RAISE EXCEPTION 'award fingerprint %', s; END IF;
  -- The new city and path are free
  IF c_nira <> 'ci_' || left(md5('nirasaki'), 10) THEN RAISE EXCEPTION 'new city id rule'; END IF;
  IF EXISTS (SELECT 1 FROM cities c WHERE c.id=c_nira OR c.slug='nirasaki' OR btrim(regexp_replace(lower(f_unaccent(c.display)),'[^a-z0-9]+',' ','g'))='nirasaki') THEN RAISE EXCEPTION 'city clash'; END IF;
  IF EXISTS (SELECT 1 FROM city_aliases WHERE alias ILIKE '%nirasaki%') THEN RAISE EXCEPTION 'alias clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='nirasaki') THEN RAISE EXCEPTION 'slug clash'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(nirasaki|tsushimi|suetomi|scalottas)' OR to_path ~ '(nirasaki|tsushimi|suetomi|scalottas)') THEN RAISE EXCEPTION 'redirect'; END IF;
  IF norm_key('Tsushimi') <> 'tsushimi' THEN RAISE EXCEPTION 'norm_key of the new name'; END IF;
  -- The fourth venue is as read
  IF (SELECT count(*) FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id=v_gr AND v.status='closed' AND NOT l.published) <> 1 THEN RAISE EXCEPTION 'grill before'; END IF;

  ---------------------------------------------------------------- 1. Rename (same writes as scripts/rename/apply.ts)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES (c_key, 'staged', 'Closed-venue sweep item 3 (Ben, Nov 2 16:25 ET "3A"): tsushimi フレンチ is Tsushimi, as OAD prints it. Run as a gated SQL file, not the rename job; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, 1, v.id, v.name, 'Tsushimi', 'oad', 'https://www.oadguides.com/restaurant/tsushimi', 'rename',
         jsonb_build_object('note', 'Closed-venue sweep item 3, Nov 2 2026; OAD prints Tsushimi; Gault&Millau, Tabelog and Omakase print TSUSHIMI; Ben Nov 2 16:25 ET 3A', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', x.city_slug, 'slug', x.slug)
    FROM venues v JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical
   WHERE v.id=v_ts AND v.name='tsushimi フレンチ';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name='Tsushimi' WHERE id=v_ts AND name='tsushimi フレンチ';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename %', n; END IF;
  PERFORM set_config('app.allow_rename', 'off', true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;

  ---------------------------------------------------------------- 2. New city, venue moves, slugs
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
  VALUES (c_nira, 'nirasaki', 'Nirasaki', 'Japan', 'JP', 'city', NULL, NULL, NULL, 1);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city insert %', n; END IF;
  UPDATE venues SET city_id=c_nira WHERE id=v_ts AND city_id=c_tokyo;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue move %', n; END IF;
  UPDATE slugs SET is_canonical=false WHERE venue_id=v_ts AND property_id='eats' AND city_slug='tokyo' AND slug='tsushimi' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','nirasaki','tsushimi',v_ts,true);

  ---------------------------------------------------------------- 3. Status, published, city counts
  UPDATE venues SET status='active' WHERE id = ANY (va) AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=true WHERE venue_id = ANY (va) AND NOT published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=595 WHERE id=c_tokyo AND venues_count=594;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'tokyo %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id=c_lenz AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'lenzerheide %', n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11293 OR (SELECT count(*) FROM venues WHERE status='active') <> 10999 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 THEN RAISE EXCEPTION 'awards after'; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category, E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id = ANY (va);
  IF s IS DISTINCT FROM '9881f9051280f5a63af2e816855d18df' THEN RAISE EXCEPTION 'award fingerprint after %', s; END IF;
  IF (SELECT count(*) FROM slugs) <> 13022 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11293 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1729 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical GROUP BY v.id HAVING count(x.slug) <> 1) THEN RAISE EXCEPTION 'venue without 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id=v_ts AND city_slug='nirasaki' AND slug='tsushimi' AND is_canonical) <> 1 OR (SELECT count(*) FROM slugs WHERE venue_id=v_ts AND city_slug='tokyo' AND slug='tsushimi' AND NOT is_canonical) <> 1 THEN RAISE EXCEPTION 'tsushimi slugs after'; END IF;
  IF (SELECT count(*) FROM venues WHERE id=v_ts AND name='Tsushimi' AND norm_key='tsushimi' AND city_id=c_nira AND status='active') <> 1 THEN RAISE EXCEPTION 'tsushimi after'; END IF;
  IF (SELECT count(*) FROM venues WHERE id=v_su AND name='Suetomi' AND city_id=c_tokyo AND status='active') <> 1 OR (SELECT count(*) FROM venues WHERE id=v_sc AND name='Scalottas Terroir' AND city_id=c_lenz AND status='active') <> 1 THEN RAISE EXCEPTION 'suetomi scalottas after'; END IF;
  IF (SELECT count(*) FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id=v_gr AND v.status='closed' AND NOT l.published) <> 1 THEN RAISE EXCEPTION 'grill after'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11293 OR (SELECT count(*) FROM city_label_source) <> 23989 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3265 OR (SELECT count(*) FROM city_aliases) <> 266 THEN RAISE EXCEPTION 'blurbs redirects cities aliases after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10999 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND NOT l.published) <> 294 THEN RAISE EXCEPTION 'closed not published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 29 OR (SELECT count(*) FROM rename_rows) <> 1301 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 186 OR (SELECT max(id) FROM source_capture_ledger) <> 238 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:INSERT=1,cities:UPDATE=2,listings:UPDATE=3,slugs:INSERT=1,slugs:UPDATE=1,venues:UPDATE=5' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log) <> 118857 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (va) AND (old_row-'status')=(new_row-'status') AND old_row->>'status'='closed' AND new_row->>'status'='active') <> 3 THEN RAISE EXCEPTION 'audit status rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk=v_ts AND (old_row-'city_id')=(new_row-'city_id') AND old_row->>'city_id'=c_tokyo AND new_row->>'city_id'=c_nira) <> 1 THEN RAISE EXCEPTION 'audit city row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk=v_ts AND (old_row-'name')=(new_row-'name') AND new_row->>'name'='Tsushimi') <> 1 THEN RAISE EXCEPTION 'audit name row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='listings' AND row_pk = ANY (va) AND (old_row-'published')=(new_row-'published') AND old_row->>'published'='false' AND new_row->>'published'='true') <> 3 THEN RAISE EXCEPTION 'audit publish rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
