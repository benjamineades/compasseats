-- rename-name-diffs-held8-2026-10-30.sql
-- CompassEats, Oct 30 2026. Rename batch for the 8 "hold" lines of docs/name-diff-evidence-2026-10-30.txt
-- (sha256 751cd15f2cd39c7a7d6fcc00b53e553b7e66b39666f53ac163a9a2e071e1043d, 94 data lines: rename 72 = batch 29, keep 14, hold 8 = this batch).
-- Ben's decisions: Oct 30 19:23 ET "Option 1" (read the 4 sites not read before), 19:25 ET "All recommended".
-- Names, sources and site reads: docs/name-diff-held8-decisions-2026-10-30.txt.
-- Input file (same rows): fixtures/rename/name-diffs-held8-2026-10-30.csv (8 rows; source michelin 5, venue 3).
-- Built by script (docs/build_name_diffs_held8_rename.py) from the evidence file, the decisions file and the fresh
-- read; each michelin name is checked against the card URL, each venue name differs from the live name in capitals only.
-- Method: gated SQL, one transaction, through the Supabase Write connector. Same writes as the rename job
-- (scripts/rename/apply.ts): rename_batches row (staged -> applied), 8 rename_rows (verdict rename, detail = note,
-- live_name, city_id, city_slug, slug), app.allow_rename on for the venues UPDATE only, 1 ledger row for michelin
-- (5); the 3 'venue' rows write no ledger row, as in the job.
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   23a6e30878bab101db515a732999fbd1  (fresh read Oct 30 ~23:3x UTC)
--   id|new_name                 98ba087e1e82ec0e0cfce27c5adec6fb
--   line|id|expected|new|source|url  63138768ba44244d7c9c323eb0a69f4e
--   id|note                     f0d74b158144986a8a2ad5eec6ee5c00
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT
-- with "read-only transaction".
-- Expected after: rename_batches 15 -> 16 (applied), rename_rows 1,186 -> 1,194, ledger +1 (last id 163 -> 164),
-- audit_log +8 (8 venues UPDATE, name and norm_key only). venues, awards, slugs, listings, blurbs unchanged.
-- Slugs follow in docs/slugs-rename-name-diffs-held8-2026-10-30.sql.

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
    (1, 've_c4d70b9a92', 'Maison Patte Noire "1 lieu, 2 restaurants"', 'La P’tite Patte', 'michelin', 'https://guide.michelin.com/us/en/pays-de-la-loire/cholet/restaurant/la-p%E2%80%99tite-patte', 'Name-diff evidence line 2 (G1, held Oct 30 18:35 ET); live "Maison Patte Noire "1 lieu, 2 restaurants""; card h1 "La P’tite Patte" (live card read Oct 30; evidence file had the held-P2 note "La P''tite Patte (held-P2 note; same address has Le Patte Noire, Selected)"); site read: La P’tite Patte (top nav, body H2, footer hours heading; always curly ’); parent site "Maison Patte Noire" has 2 restaurants: Le Patte Noire (gastronomic) and La P’tite Patte (bistro) [https://www.maisonpattenoire.fr]; rule R1 (site = card; the Bib belongs to the bistro, not to Le Patte Noire, which is Selected only); new name = Michelin 2026 card name; Michelin card https://guide.michelin.com/us/en/pays-de-la-loire/cholet/restaurant/la-p%E2%80%99tite-patte; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (2, 've_f3378b4564', 'LULU FUSION BISTRO', 'LULU fusion bistro', 'venue', 'https://lulu-fusion-bistro.eatbu.com/', 'Name-diff evidence line 20 (G3, held Oct 30 18:35 ET); live "LULU FUSION BISTRO"; card h1 "Lulu Fusion Bistro"; site read: LULU fusion bistro (title, header); rule R1 (site has one form; card differs in capitals); new name = venue site spelling (card differs); site = card website link; Michelin card https://guide.michelin.com/us/en/osijek-baranja/osijek/restaurant/lulu-fusion-bistro; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (3, 've_9852cbf26e', 'TURK FATIH TUTAK', 'Turk Fatih Tutak', 'venue', 'https://www.turkft.com/', 'Name-diff evidence line 21 (G3, held Oct 30 18:35 ET); live "TURK FATIH TUTAK"; card h1 "TURK FATİH TUTAK"; site read: Turk Fatih Tutak (title); TURK + Fatih Tutak (nav); rule R1 + R3 (site title in normal case; card TURK FATİH TUTAK is the same in Turkish capitals); new name = venue site spelling (card differs); site = card website link; Michelin card https://guide.michelin.com/us/en/istanbul-province/istanbul/restaurant/turk-fatih-tutak; non-Michelin award on venue (la-liste 2026, oad 2025); Ben Oct 30 18:35 ET decision 2 = A (site + card agreement); Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (4, 've_f1b7fc23a0', 'KITCHEN by Osman Sezener', 'Kitchen by Osman Sezener', 'venue', 'https://www.editionhotels.com/bodrum/restaurants-and-bars/kitchen/', 'Name-diff evidence line 22 (G3, held Oct 30 18:35 ET); live "KITCHEN by Osman Sezener"; card h1 "Kitchen By Osman Sezener"; site read: KITCHEN BY OSMAN SEZENER (H1, H2, nav); Kitchen by Osman Sezener (body); Kitchen (meta description) [The Bodrum EDITION page]; rule R3 + Oct 11 "by <chef>" rule (site uses "by Osman Sezener"; card has "By"); new name = venue site spelling (card differs); site = card website link; Michelin card https://guide.michelin.com/us/en/mugla/bodrum_2806351/restaurant/kitchen-1208228; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (5, 've_b4ab5979c5', 'Arka Ristorente Pizzeria Bodrum', 'Arka Ristorante Pizzeria', 'michelin', 'https://guide.michelin.com/us/en/mugla/bodrum_2806351/restaurant/arka-ristorante-pizzeria', 'Name-diff evidence line 72 (G3, held Oct 30 18:35 ET); live "Arka Ristorente Pizzeria Bodrum"; card h1 "Arka Ristorante Pizzeria"; site read: Arka Pizzaria (title); Arka Pizzeria (footer); rule R5 card (site has 2 forms, Arka Pizzaria / Arka Pizzeria, none = card; our name had the typo Ristorente); new name = Michelin 2026 card name; Michelin card https://guide.michelin.com/us/en/mugla/bodrum_2806351/restaurant/arka-ristorante-pizzeria; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (6, 've_f21ee3afab', 'Bánh Bèo, Bánh Đập, Bánh Ướt', 'Bánh Bèo - Bánh đập', 'michelin', 'https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/banh-beo-banh-%C4%91ap', 'Name-diff evidence line 76 (G3, held Oct 30 18:35 ET); live "Bánh Bèo, Bánh Đập, Bánh Ướt"; card h1 "Bánh Bèo - Bánh đập"; site read: no site; rule R5 card, exact (no site; Michelin is the only publisher; the dash is part of the name, not a suffix); new name = Michelin 2026 card name; Michelin card https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/banh-beo-banh-%C4%91ap; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (7, 've_6d2d60d7ba', 'Andrea Ristorante - Enoteca', 'Andrea', 'michelin', 'https://guide.michelin.com/us/en/sicilia/palazzolo-acreide/restaurant/andrea', 'Name-diff evidence line 93 (G3, held Oct 30 18:35 ET); live "Andrea Ristorante - Enoteca"; card h1 "Andrea" (live card read Oct 30; evidence file had the held-P2 note "Andrea (held-P2 note)"); site read: Ristorante Andrea (title, footer, body); Andrea alone (heading "Le stanze di Andrea", logo link title); never "Enoteca" or a dash [https://www.ristoranteandrea.it/]; rule R2 (site has more than one form; card uses Andrea); new name = Michelin 2026 card name; Michelin card https://guide.michelin.com/us/en/sicilia/palazzolo-acreide/restaurant/andrea; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30'),
    (8, 've_bb69a63e96', 'Vegan Ramen UZU Kyoto', 'UZU Kyoto', 'michelin', 'https://guide.michelin.com/us/en/kyoto-region/kyoto/restaurant/uzu-kyoto', 'Name-diff evidence line 94 (G3, held Oct 30 18:35 ET); live "Vegan Ramen UZU Kyoto"; card h1 "UZU Kyoto" (live card read Oct 30; evidence file had the held-P2 note "UZU Kyoto (held-P2 note)"); site read: UZU Kyoto (nav, store list); Vegan Ramen UZU (title, brand) [https://vegan-uzu.com/]; rule R1 (site = card; "Vegan Ramen UZU" is the brand of the group); new name = Michelin 2026 card name; Michelin card https://guide.michelin.com/us/en/kyoto-region/kyoto/restaurant/uzu-kyoto; Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET ''All recommended''; read Oct 30')
  ) AS t(line, venue_id, expected_name, new_name, source_id, source_url, note);

  SELECT count(*), count(DISTINCT p.venue_id) INTO n, x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF n <> 8 OR x <> 8 THEN RAISE EXCEPTION 'input rows % / distinct venues % (expected 8 / 8)', n, x; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.expected_name, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text)) <> '23a6e30878bab101db515a732999fbd1' THEN
    RAISE EXCEPTION 'input guard id|expected_name failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.new_name, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)) <> '98ba087e1e82ec0e0cfce27c5adec6fb' THEN
    RAISE EXCEPTION 'input guard id|new_name failed'; END IF;
  IF (SELECT md5(string_agg(p.line||'|'||p.venue_id||'|'||p.expected_name||'|'||p.new_name||'|'||p.source_id||'|'||p.source_url,
                            E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text, source_id text, source_url text))
       <> '63138768ba44244d7c9c323eb0a69f4e' THEN
    RAISE EXCEPTION 'input guard rows failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.note, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, note text)) <> 'f0d74b158144986a8a2ad5eec6ee5c00' THEN
    RAISE EXCEPTION 'input guard notes failed'; END IF;

  -- 2. Pre-checks against live data
  SELECT count(*) INTO x FROM rename_batches WHERE batch_key = 'rename-name-diffs-held8-2026-10-30';
  IF x <> 0 THEN RAISE EXCEPTION 'batch key already used: %', x; END IF;

  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '23a6e30878bab101db515a732999fbd1' THEN
    RAISE EXCEPTION 'live names differ from the Oct 30 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> 8 THEN RAISE EXCEPTION 'active venues % (expected 8)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id NOT IN ('michelin', 'venue');
  IF x <> 0 THEN RAISE EXCEPTION 'unexpected source_id: %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id = 'michelin';
  IF x <> 5 THEN RAISE EXCEPTION 'michelin rows % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug = 'michelin';
  IF x <> 1 THEN RAISE EXCEPTION 'michelin not registered in award_sources'; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug = 'venue';
  IF x <> 0 THEN RAISE EXCEPTION 'venue is a registered source (ledger rule changes)'; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_url text)
   WHERE p.source_url !~ '^https://' OR p.source_url ~* '(joinpearl|thebestrestaurantsguide|beliapp)';
  IF x <> 0 THEN RAISE EXCEPTION 'bad source_url: %', x; END IF;

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

  SELECT count(*) INTO x FROM venues;          IF x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> 23353 THEN RAISE EXCEPTION 'awards before % (expected 23353)', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> 12909 THEN RAISE EXCEPTION 'slugs before % (expected 12909)', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> 142 THEN RAISE EXCEPTION 'blurbs before % (expected 142)', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> 15 THEN RAISE EXCEPTION 'rename_batches before % (expected 15)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> 1186 THEN RAISE EXCEPTION 'rename_rows before % (expected 1186)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 119 OR led_max <> 163 THEN RAISE EXCEPTION 'ledger before % rows, last id % (expected 119, 163)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 113673 OR aud_max <> 118957 THEN
    RAISE EXCEPTION 'audit_log before % rows, last id % (expected 113673, 118957)', aud_n, aud_max; END IF;

  -- 3. Writes (same order as the rename job)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-name-diffs-held8-2026-10-30', 'staged', 'Name differences, the 8 venues held on Oct 30 (evidence file name-diff-evidence-2026-10-30.txt, hold lines; decisions file name-diff-held8-decisions-2026-10-30.txt): 4 sites read Oct 30 (Ben Option 1), Ben ''All recommended'' 19:25 ET. Run as a gated SQL file through the Write connector, not the rename job; same writes as scripts/rename/apply.ts.')
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
  IF n <> 8 THEN RAISE EXCEPTION 'rename_rows inserted % (expected 8)', n; END IF;

  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = p.new_name
    FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
   WHERE v.id = p.venue_id AND v.name = p.expected_name;
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 8 THEN RAISE EXCEPTION 'venues renamed % (expected 8)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 5, 'rename-apply:rename-name-diffs-held8-2026-10-30 | gated SQL file docs/rename-name-diffs-held8-2026-10-30.sql (Write connector), same writes as the job | 5 rows follow the Michelin 2026 card; 3 rows follow the venue site (source venue, no ledger row)');

  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'batch status update % (expected 1)', n; END IF;

  -- 4. Post-checks (the job's invariants)
  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text, new_name text) ON p.venue_id = v.id
   WHERE v.name IS DISTINCT FROM p.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'venues whose live name is not new_name: %', x; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '98ba087e1e82ec0e0cfce27c5adec6fb' THEN
    RAISE EXCEPTION 'live id|name after differs from the file'; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> 11304 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> 23353 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> 12909 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> 11304 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> 16 THEN RAISE EXCEPTION 'rename_batches after % (expected 16)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> 1194 THEN RAISE EXCEPTION 'rename_rows after % (expected 1194)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> 8 THEN RAISE EXCEPTION 'rename_rows in this batch % (expected 8)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 120 THEN RAISE EXCEPTION 'ledger after % (expected 120)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'name' AND items = 5 AND job LIKE 'rename-apply:rename-name-diffs-held8-2026-10-30 |%';
  IF x <> 1 THEN RAISE EXCEPTION 'ledger row for this batch % (expected 1)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 8 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 8)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
      ON a.row_pk = p.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.at = transaction_timestamp()
     AND a.old_row->>'name' = p.expected_name AND a.new_row->>'name' = p.new_name
     AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key');
  IF x <> 8 THEN RAISE EXCEPTION 'audit venue renames (name and norm_key only) % (expected 8)', x; END IF;
END
$do$;
COMMIT;
