-- status-michelin-2026-switzerland-2026-11-02.sql
-- CompassEats, Nov 2 2026. Swiss status file, decision 10. One transaction. No DELETE.
-- Ben: Nov 2 17:26 ET "1A" (Colani Bistrot), 17:57 ET "Keep After Seven listed as open". This file runs only after his "go".
-- Population: 2 venues. Both are closed and not published, and both hold a Michelin 2026 row.
-- Evidence: docs/ch-2026-build/status-evidence-ch-2026-11-02.csv.
--
-- After Seven ve_7077280426: closed to active, published. Zermatt 6 to 7. Slug stays /zermatt/after-seven.
--   Rule: a seasonal closure is active. Zermatt Tourismus: closed 13 Apr 2026 - 1 Dec 2026, open from 2 Dec 2026. Michelin One Star 2026, no closure note.
-- Chesa Stüva Colani - Ristorante ve_8f85789bec: closed to active, published, name to Colani Bistrot. Madulain 1 to 2.
--   Rule: a seasonal closure is active. Own site: BISTROT winter 27.11.2026 to 03.04.2027. Michelin Bib Gourmand 2026 prints Colani Bistrot.
--   Limit: the own site prints BISTROT and Pontresina Tourismus prints Bistro Bar Restaurant Colani. Ben chose Colani Bistrot.
--   Slug: /madulain/chesa-stuva-colani-ristorante stays, non-canonical. /madulain/colani-bistrot becomes canonical (rule of Oct 8, as Kitafuku and Revolution, Nov 2).
--
-- No change: awards, price, city labels, blurbs, redirects, aliases, Chesa Stuva Colani ve_388aeca5ca. No ledger row (precedent: docs/fix-closed-sweep-item3-2026-11-02.sql).
-- Expected after: venues 11,323 (active 11,031, closed 292); awards 25,321; slugs 13,053 (canonical 11,323, non-canonical 1,730); price 7,727; listings 11,323;
--   cities 3,279, sum 11,031; city labels 24,049; closed published 0; closed not published 292; active not published 0; rename_batches 30; rename_rows 1,302; ledger 189 rows, last id 243;
--   audit_log +9 (119,235 rows): cities UPDATE 2, listings UPDATE 2, slugs INSERT 1 and UPDATE 1, venues UPDATE 3.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text; bid bigint;
  va constant text[] := ARRAY['ve_7077280426','ve_8f85789bec'];
  v_as constant text := 've_7077280426';  -- After Seven
  v_co constant text := 've_8f85789bec';  -- Chesa Stüva Colani - Ristorante
  v_st constant text := 've_388aeca5ca';  -- Chesa Stuva Colani, One Star, no change
  c_zer constant text := 'ci_8012e949be';
  c_mad constant text := 'ci_dcb1dcae08';
  c_key constant text := 'rename-status-michelin-2026-switzerland-2026-11-02';
  c_new constant text := 'Colani Bistrot';
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 3 00:52 UTC)
  IF (SELECT count(*) FROM venues) <> 11323 OR (SELECT count(*) FROM venues WHERE status='active') <> 11029 OR (SELECT count(*) FROM venues WHERE status='closed') <> 294 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25321 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13052 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11323 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1729 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11323 OR (SELECT count(*) FROM city_label_source) <> 24049 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3279 OR (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'blurbs redirects cities aliases before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11029 THEN RAISE EXCEPTION 'cities sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 29 OR (SELECT count(*) FROM rename_rows) <> 1301 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key=c_key) THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id = ANY (va)) THEN RAISE EXCEPTION 'rename rows on the venues'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM source_capture_ledger; IF n <> 189 OR aud_max <> 243 THEN RAISE EXCEPTION 'ledger before % / %', n, aud_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 119226 OR aud_max <> 125055 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Fingerprints: venues, cities, slugs, awards, price
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (va);
  IF s IS DISTINCT FROM 'e003b53ca9ad325a9050d65a0fe1b8d1' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(c.id||'|'||c.slug||'|'||c.display||'|'||c.country||'|'||c.country_iso||'|'||c.kind||'|'||coalesce(c.region_id,'-')||'|'||c.venues_count, E'\n' ORDER BY c.id COLLATE "C")) INTO s FROM cities c WHERE c.id IN (c_zer, c_mad);
  IF s IS DISTINCT FROM '62df1ca0c63df496c24cbc039e0b2d28' THEN RAISE EXCEPTION 'city fingerprint %', s; END IF;
  SELECT md5(string_agg(x.venue_id||'|'||x.city_slug||'|'||x.slug||'|'||x.is_canonical, E'\n' ORDER BY x.venue_id COLLATE "C", x.slug COLLATE "C")) INTO s FROM slugs x WHERE x.venue_id = ANY (va);
  IF s IS DISTINCT FROM 'a1bb8d8e2ba5b53e027449670ec1b4fa' THEN RAISE EXCEPTION 'slug fingerprint %', s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,'-'), E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id = ANY (va);
  IF s IS DISTINCT FROM '937d1d8340bf1529b1673c1a12dc8bed' THEN RAISE EXCEPTION 'award fingerprint %', s; END IF;
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||p.symbol_raw||'|'||p.source, E'\n' ORDER BY p.venue_id COLLATE "C")) INTO s FROM price p WHERE p.venue_id = ANY (va);
  IF s IS DISTINCT FROM '7e314ef96ffac1b27f1ed742a8e5dc39' THEN RAISE EXCEPTION 'price fingerprint %', s; END IF;
  -- The new name and path are free
  IF norm_key(c_new) <> 'colanibistrot' THEN RAISE EXCEPTION 'norm_key of the new name'; END IF;
  IF trim(both '-' from regexp_replace(lower(f_unaccent(c_new)), '[^a-z0-9]+', '-', 'g')) <> 'colani-bistrot' THEN RAISE EXCEPTION 'slug rule'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE norm_key='colanibistrot') THEN RAISE EXCEPTION 'name clash'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='madulain' AND slug='colani-bistrot') THEN RAISE EXCEPTION 'slug clash'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '(colani|after-seven)' OR to_path ~ '(colani|after-seven)') THEN RAISE EXCEPTION 'redirect'; END IF;
  -- The One Star venue is as read
  IF (SELECT count(*) FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id=v_st AND v.name='Chesa Stuva Colani' AND v.status='active' AND l.published) <> 1 THEN RAISE EXCEPTION 'one star before'; END IF;

  ---------------------------------------------------------------- 1. Rename (same writes as scripts/rename/apply.ts)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES (c_key, 'staged', 'Swiss status file (Ben, Nov 2 17:26 ET "1A"): Chesa Stüva Colani - Ristorante is Colani Bistrot, as the Michelin 2026 card prints it. Run as a gated SQL file, not the rename job; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, 1, v.id, v.name, c_new, 'michelin', 'https://guide.michelin.com/us/en/graubunden/madulain/restaurant/colani-bistrot', 'rename',
         jsonb_build_object('note', 'Swiss status file, Nov 2 2026; Michelin 2026 prints Colani Bistrot; own site prints BISTROT; Pontresina Tourismus prints Bistro Bar Restaurant Colani; Ben Nov 2 17:26 ET 1A', 'live_name', v.name, 'city_id', v.city_id, 'city_slug', x.city_slug, 'slug', x.slug)
    FROM venues v JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical
   WHERE v.id=v_co AND v.name='Chesa Stüva Colani - Ristorante';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name=c_new WHERE id=v_co AND name='Chesa Stüva Colani - Ristorante';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename %', n; END IF;
  PERFORM set_config('app.allow_rename', 'off', true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;

  ---------------------------------------------------------------- 2. Slugs
  UPDATE slugs SET is_canonical=false WHERE venue_id=v_co AND property_id='eats' AND city_slug='madulain' AND slug='chesa-stuva-colani-ristorante' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','madulain','colani-bistrot',v_co,true);

  ---------------------------------------------------------------- 3. Status, published, city counts
  UPDATE venues SET status='active' WHERE id = ANY (va) AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=true WHERE venue_id = ANY (va) AND NOT published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=7 WHERE id=c_zer AND venues_count=6;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'zermatt %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id=c_mad AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'madulain %', n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11323 OR (SELECT count(*) FROM venues WHERE status='active') <> 11031 OR (SELECT count(*) FROM venues WHERE status='closed') <> 292 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25321 THEN RAISE EXCEPTION 'awards after'; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.source_url,'-'), E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id = ANY (va);
  IF s IS DISTINCT FROM '937d1d8340bf1529b1673c1a12dc8bed' THEN RAISE EXCEPTION 'award fingerprint after %', s; END IF;
  SELECT md5(string_agg(p.venue_id||'|'||p.tier||'|'||p.symbol_raw||'|'||p.source, E'\n' ORDER BY p.venue_id COLLATE "C")) INTO s FROM price p WHERE p.venue_id = ANY (va);
  IF s IS DISTINCT FROM '7e314ef96ffac1b27f1ed742a8e5dc39' THEN RAISE EXCEPTION 'price fingerprint after %', s; END IF;
  IF (SELECT count(*) FROM slugs) <> 13053 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11323 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1730 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs x ON x.venue_id=v.id AND x.property_id='eats' AND x.is_canonical GROUP BY v.id HAVING count(x.slug) <> 1) THEN RAISE EXCEPTION 'venue without 1 canonical slug'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id=v_co AND city_slug='madulain' AND slug='colani-bistrot' AND is_canonical) <> 1 OR (SELECT count(*) FROM slugs WHERE venue_id=v_co AND city_slug='madulain' AND slug='chesa-stuva-colani-ristorante' AND NOT is_canonical) <> 1 THEN RAISE EXCEPTION 'colani slugs after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id=v_as AND city_slug='zermatt' AND slug='after-seven' AND is_canonical) <> 1 THEN RAISE EXCEPTION 'after seven slug after'; END IF;
  IF (SELECT count(*) FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id=v_co AND v.name=c_new AND v.norm_key='colanibistrot' AND v.city_id=c_mad AND v.status='active' AND l.published) <> 1 THEN RAISE EXCEPTION 'colani after'; END IF;
  IF (SELECT count(*) FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id=v_as AND v.name='After Seven' AND v.city_id=c_zer AND v.status='active' AND l.published) <> 1 THEN RAISE EXCEPTION 'after seven after'; END IF;
  IF (SELECT count(*) FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.id=v_st AND v.name='Chesa Stuva Colani' AND v.status='active' AND l.published) <> 1 THEN RAISE EXCEPTION 'one star after'; END IF;
  IF (SELECT count(*) FROM price) <> 7727 OR (SELECT count(*) FROM listings) <> 11323 OR (SELECT count(*) FROM city_label_source) <> 24049 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 9 OR (SELECT count(*) FROM cities) <> 3279 OR (SELECT count(*) FROM city_aliases) <> 262 THEN RAISE EXCEPTION 'blurbs redirects cities aliases after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11031 THEN RAISE EXCEPTION 'cities sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND NOT l.published) <> 292 THEN RAISE EXCEPTION 'closed not published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 30 OR (SELECT count(*) FROM rename_rows) <> 1302 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 189 OR (SELECT max(id) FROM source_capture_ledger) <> 243 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=2,listings:UPDATE=2,slugs:INSERT=1,slugs:UPDATE=1,venues:UPDATE=3' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log) <> 119235 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (va) AND (old_row-'status')=(new_row-'status') AND old_row->>'status'='closed' AND new_row->>'status'='active') <> 2 THEN RAISE EXCEPTION 'audit status rows'; END IF;
  -- norm_key is a generated column, so a rename changes it too
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk=v_co AND (old_row-'name'-'norm_key')=(new_row-'name'-'norm_key') AND new_row->>'name'=c_new) <> 1 THEN RAISE EXCEPTION 'audit name row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='listings' AND row_pk = ANY (va) AND (old_row-'published')=(new_row-'published') AND old_row->>'published'='false' AND new_row->>'published'='true') <> 2 THEN RAISE EXCEPTION 'audit publish rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
