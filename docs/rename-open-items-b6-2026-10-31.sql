-- rename-open-items-b6-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 6, file 1 of 3: rename batch rename-open-items-b6-2026-10-31 (5 venues).
-- Ben: Oct 31 01:56 ET "1, 2A, 2B"; 02:01 ET "Your recommendation for everything" (D1-D5 = A).
-- D1: Kresios -> Krèsios (R1), Paca Ristorante -> Paca (R2), Coxinendi - Ristorante -> Coxinendi (R5),
--     Restaurante Temático El Jardín de la Sal -> El Jardín de la Sal (R2 + R3).
-- D2: Duddell's bar ve_f88a5d9dc2 -> The Upper Room at Duddell’s (R2 + R3 + R6; not a duplicate of the restaurant).
-- Built by script docs/open-items-b6-build/build_open_items_b6_2026_10_31.py from docs/open-items-b6-build/relay.txt
-- (sha256 a56c3d89a09c8463128b32100f401191790d5445e44ac5ec8414c4fe536707c5). Template: docs/rename-open-items-b1-2026-10-30.sql (same writes as scripts/rename/apply.ts).
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   80fe23d7e2d4b7f6c79ef49e6484611c  (fresh read 2026-10-31 06:01:40 UTC)
--   id|new_name                 40f57f53e81722d2d30bcd29e7dec226
--   line|id|expected|new|source|url  b1e97e5fd098d62ed4b621e0b01d655f
--   id|note                     540f256ef44de2722d75efa47dd3e1c6
-- Expected after: rename_batches 17 -> 18 (applied, id 32), rename_rows 1196 -> 1201, ledger +2 (172 -> 174: michelin name 4,
-- pinnacle-guide name 1), audit_log +5 (119393 -> 119398; 5 venues UPDATE, name and norm_key only).
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT.

BEGIN;
DO $do$
DECLARE
  plan     jsonb;
  bid      bigint;
  n        int;
  x        int;
  aud_max  bigint;
  aud_n    bigint;
  led_n    bigint;
  led_max  bigint;
BEGIN
  -- 1. Inputs
  SELECT jsonb_agg(jsonb_build_object('line', t.line, 'venue_id', t.venue_id, 'expected_name', t.expected_name,
           'new_name', t.new_name, 'source_id', t.source_id, 'source_url', t.source_url, 'note', t.note) ORDER BY t.line)
    INTO plan
  FROM (VALUES
    (1, 've_542c195114', 'Paca Ristorante', 'Paca', 'michelin', 'https://guide.michelin.com/us/en/toscana/carmignano_1833819/restaurant/paca', 'Open items block 6 (2026-10-31); live "Paca Ristorante"; card h1 "Paca"; site read: "Ristorante Paca - Tenuta Ceri" (title), "PACA TENUTA CERI" (H1), "Paca Tenuta Ceri" (menu), "Paca" (body) [https://www.tenutaceri.it/ristorante-paca/]; rule R2 (site writes more than one form; card form "Paca" is one of them); Ben Oct 31 01:56 ET "1, 2A, 2B", 02:01 ET "Your recommendation for everything" (D1 = A)'),
    (2, 've_e50adc624d', 'Restaurante Temático El Jardín de la Sal', 'El Jardín de la Sal', 'michelin', 'https://guide.michelin.com/us/en/canarias/fuencaliente-de-la-palma/restaurant/el-jardin-de-la-sal', 'Open items block 6 (2026-10-31); live "Restaurante Temático El Jardín de la Sal"; card h1 "El Jardín de la Sal"; site read: "Restaurante El Jardín de la Sal" (menu), "EL JARDÍN DE LA SAL" (footer heading) [https://www.salinasdefuencaliente.es]; rule R2 + R3 (card form = the heading form); "Temático" is a site descriptor, not the name; Ben Oct 31 02:01 ET (D1 = A)'),
    (3, 've_eef796a74d', 'Coxinendi - Ristorante', 'Coxinendi', 'michelin', 'https://guide.michelin.com/us/en/sardegna/quartu-sant-elena_1840763/restaurant/coxinendi', 'Open items block 6 (2026-10-31); live "Coxinendi - Ristorante"; card h1 "Coxinendi"; site not read (https://www.coxinendi.com robots_disallowed); rule R5 (card name minus suffix); Ben Oct 31 02:01 ET (D1 = A)'),
    (4, 've_f558535881', 'Kresios', 'Krèsios', 'michelin', 'https://guide.michelin.com/us/en/campania/telese-terme_1850913/restaurant/kresios', 'Open items block 6 (2026-10-31); live "Kresios"; card h1 "Krèsios"; site read: "Krèsios" (title "Krèsios - Giuseppe Iannotti Chef", og:site_name, og:title); "Kresios" only in URLs and file names [https://www.kresios.com/]; rule R1; other publishers best-chef-awards, la-liste, oad (spelling not stored); slug kresios unchanged; Ben Oct 31 02:01 ET (D1 = A)'),
    (5, 've_f88a5d9dc2', 'Duddell''s', 'The Upper Room at Duddell’s', 'pinnacle-guide', 'https://www.thepinnacleguide.com/the-upper-room-at-duddells/', 'Open items block 6 (2026-10-31); live "Duddell''s" (category bar; same norm_key as the restaurant ve_a3512f9a51); Pinnacle Guide heading "The Upper Room At Duddell''s" (4/F, part of Duddell''s); site read: "The Upper Room at Duddell’s" (opening hours), "The Upper Room" (section heading); 3/F is "Main Dining Room" [https://duddells.co/pages/venue-interior-design]; rule R2 + R3, apostrophe as the site writes it (R6); not a duplicate, no merge; Ben Oct 31 02:01 ET (D2 = A)')
  ) AS t(line, venue_id, expected_name, new_name, source_id, source_url, note);

  SELECT count(*), count(DISTINCT p.venue_id) INTO n, x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF n <> 5 OR x <> 5 THEN RAISE EXCEPTION 'input rows % / distinct venues % (expected 5 / 5)', n, x; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.expected_name, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text)) <> '80fe23d7e2d4b7f6c79ef49e6484611c' THEN
    RAISE EXCEPTION 'input guard id|expected_name failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.new_name, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)) <> '40f57f53e81722d2d30bcd29e7dec226' THEN
    RAISE EXCEPTION 'input guard id|new_name failed'; END IF;
  IF (SELECT md5(string_agg(p.line||'|'||p.venue_id||'|'||p.expected_name||'|'||p.new_name||'|'||p.source_id||'|'||p.source_url,
                            E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text, source_id text, source_url text))
       <> 'b1e97e5fd098d62ed4b621e0b01d655f' THEN
    RAISE EXCEPTION 'input guard rows failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.note, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, note text)) <> '540f256ef44de2722d75efa47dd3e1c6' THEN
    RAISE EXCEPTION 'input guard notes failed'; END IF;

  -- 2. Pre-checks against live data
  SELECT count(*) INTO x FROM rename_batches WHERE batch_key = 'rename-open-items-b6-2026-10-31';
  IF x <> 0 THEN RAISE EXCEPTION 'batch key already used: %', x; END IF;

  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '80fe23d7e2d4b7f6c79ef49e6484611c' THEN
    RAISE EXCEPTION 'live names differ from the Oct 31 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> 5 THEN RAISE EXCEPTION 'active venues % (expected 5)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text, source_url text)
   WHERE NOT ((p.source_id = 'michelin' AND p.source_url ~ '^https://guide\.michelin\.com/')
           OR (p.source_id = 'pinnacle-guide' AND p.source_url ~ '^https://www\.thepinnacleguide\.com/'))
      OR p.source_url ~* '(joinpearl|thebestrestaurantsguide|beliapp)';
  IF x <> 0 THEN RAISE EXCEPTION 'bad source_id or source_url: %', x; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug IN ('michelin', 'pinnacle-guide');
  IF x <> 2 THEN RAISE EXCEPTION 'michelin / pinnacle-guide not registered in award_sources'; END IF;

  SELECT count(*) INTO x FROM rename_rows r JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = r.venue_id;
  IF x <> 0 THEN RAISE EXCEPTION 'earlier rename_rows on these venues: %', x; END IF;

  -- same-city norm_key collisions on the end state (scripts/rename/lib/impact.ts rule)
  WITH batch AS (SELECT p.venue_id, p.new_name FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)),
       scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
       fin   AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
                   FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id)
  SELECT count(*) INTO x FROM fin a JOIN batch ON batch.venue_id = a.id
    JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id
              AND norm_key(a.name) IS NOT NULL AND norm_key(o.name) = norm_key(a.name);
  IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key collisions: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text)
   WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = p.venue_id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug: %', x; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> 11303 THEN RAISE EXCEPTION 'venues before %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> 23362 THEN RAISE EXCEPTION 'awards before %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> 12940 THEN RAISE EXCEPTION 'slugs before %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> 11303 THEN RAISE EXCEPTION 'listings before %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> 142 THEN RAISE EXCEPTION 'blurbs before %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> 17 THEN RAISE EXCEPTION 'rename_batches before %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> 1196 THEN RAISE EXCEPTION 'rename_rows before %', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 128 OR led_max <> 172 THEN RAISE EXCEPTION 'ledger before % rows, last id %', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 114109 OR aud_max <> 119393 THEN
    RAISE EXCEPTION 'audit_log before % rows, last id %', aud_n, aud_max; END IF;

  -- 3. Writes (same order as the rename job)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-open-items-b6-2026-10-31', 'staged', 'Open items block 6 (Oct 31): 4 Michelin card name differences (Krèsios, Paca, Coxinendi, El Jardín de la Sal; rules R1-R5) and the Duddell''s bar -> The Upper Room at Duddell’s (site + Pinnacle Guide). Ben "Your recommendation for everything" Oct 31 02:01 ET. Run as a gated SQL file through the Write connector, not the rename job; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;

  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, p.line, p.venue_id, p.expected_name, p.new_name, p.source_id, p.source_url, 'rename',
         jsonb_build_object('note', p.note, 'live_name', v.name, 'city_id', v.city_id,
                            'city_slug', s.city_slug, 'slug', s.slug)
    FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text,
                                    source_id text, source_url text, note text)
    JOIN venues v ON v.id = p.venue_id
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 5 THEN RAISE EXCEPTION 'rename_rows inserted % (expected 5)', n; END IF;

  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = p.new_name
    FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
   WHERE v.id = p.venue_id AND v.name = p.expected_name;
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 5 THEN RAISE EXCEPTION 'venues renamed % (expected 5)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 4, 'rename-apply:rename-open-items-b6-2026-10-31 | gated SQL file docs/rename-open-items-b6-2026-10-31.sql (Write connector), same writes as the job | 4 rows follow the Michelin 2026 card and the venue site, rules R1-R5 (Krèsios, Paca, Coxinendi, El Jardín de la Sal)');
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('pinnacle-guide', 'name', 1, 'rename-apply:rename-open-items-b6-2026-10-31 | gated SQL file docs/rename-open-items-b6-2026-10-31.sql (Write connector), same writes as the job | ve_f88a5d9dc2 Duddell''s (bar) -> The Upper Room at Duddell’s: venue site + Pinnacle Guide 2026, rules R2 + R3 + R6');

  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'batch status update % (expected 1)', n; END IF;

  -- 4. Post-checks (the job's invariants)
  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text, new_name text) ON p.venue_id = v.id
   WHERE v.name IS DISTINCT FROM p.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'venues whose live name is not new_name: %', x; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '40f57f53e81722d2d30bcd29e7dec226' THEN
    RAISE EXCEPTION 'live id|name after differs from the file'; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> 11303 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> 23362 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> 12940 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> 11303 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> 18 THEN RAISE EXCEPTION 'rename_batches after %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> 1201 THEN RAISE EXCEPTION 'rename_rows after %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> 5 THEN RAISE EXCEPTION 'rename_rows in this batch % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 130 THEN RAISE EXCEPTION 'ledger after %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND field_type = 'name' AND job LIKE 'rename-apply:rename-open-items-b6-2026-10-31 |%'
     AND ((publisher = 'michelin' AND items = 4) OR (publisher = 'pinnacle-guide' AND items = 1));
  IF x <> 2 THEN RAISE EXCEPTION 'ledger rows for this batch % (expected 2)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 5 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
      ON a.row_pk = p.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.at = transaction_timestamp()
     AND a.old_row->>'name' = p.expected_name AND a.new_row->>'name' = p.new_name
     AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key');
  IF x <> 5 THEN RAISE EXCEPTION 'audit venue renames (name and norm_key only) % (expected 5)', x; END IF;
END
$do$;
COMMIT;
