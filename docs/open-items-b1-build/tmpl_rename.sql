-- rename-open-items-b1-2026-10-30.sql
-- CompassEats, Oct 30 2026. Rename batch for open items block 1, items 2 and 3 (handoff-name-diffs-held8-done-2026-10-30,
-- carried open items): Lavello ve_04c2784726 -> Forentum, Les Fresques ve_e574aeb7fd (tagline removed) -> Les Fresques.
-- Ben's decisions: Oct 30 19:46 ET "Go" (items 1-4), 19:50 ET "All recommended" (2 = A, 3 = A).
-- Card h1 and site reads: docs/open-items-b1-decisions-2026-10-30.txt.
-- Input file (same rows): fixtures/rename/open-items-b1-2026-10-30.csv (2 rows; source michelin 2).
-- Built by script (docs/build_open_items_b1_2026_10_30.py) from the fresh read ({{READ}}); each new name
-- equals the last part of its Michelin 2026 card URL (lower case, accents off, spaces to '-').
-- Method: gated SQL, one transaction, through the Supabase Write connector. Same writes as the rename job
-- (scripts/rename/apply.ts): rename_batches row (staged -> applied), 2 rename_rows (verdict rename, detail = note,
-- live_name, city_id, city_slug, slug), app.allow_rename on for the venues UPDATE only, 1 ledger row for michelin (2).
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   {{EXP}}  (fresh read {{READ}})
--   id|new_name                 {{NEW}}
--   line|id|expected|new|source|url  {{ROWS}}
--   id|note                     {{NOTES}}
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT
-- with "read-only transaction".
-- Expected after: rename_batches {{RB}} -> {{RB2}} (applied), rename_rows {{RR}} -> {{RR2}}, ledger +1 (last id {{LEDMAX}} -> {{LEDMAX2}}),
-- audit_log +2 (last id {{AUDMAX}} -> {{AUDMAX2}}; 2 venues UPDATE, name and norm_key only). venues, awards, slugs, listings,
-- blurbs unchanged. Slugs follow in docs/slugs-rename-open-items-b1-2026-10-30.sql.

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
{{VALUES}}
  ) AS t(line, venue_id, expected_name, new_name, source_id, source_url, note);

  SELECT count(*), count(DISTINCT p.venue_id) INTO n, x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF n <> 2 OR x <> 2 THEN RAISE EXCEPTION 'input rows % / distinct venues % (expected 2 / 2)', n, x; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.expected_name, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text)) <> '{{EXP}}' THEN
    RAISE EXCEPTION 'input guard id|expected_name failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.new_name, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)) <> '{{NEW}}' THEN
    RAISE EXCEPTION 'input guard id|new_name failed'; END IF;
  IF (SELECT md5(string_agg(p.line||'|'||p.venue_id||'|'||p.expected_name||'|'||p.new_name||'|'||p.source_id||'|'||p.source_url,
                            E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text, source_id text, source_url text))
       <> '{{ROWS}}' THEN
    RAISE EXCEPTION 'input guard rows failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.note, E'\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, note text)) <> '{{NOTES}}' THEN
    RAISE EXCEPTION 'input guard notes failed'; END IF;

  -- 2. Pre-checks against live data
  SELECT count(*) INTO x FROM rename_batches WHERE batch_key = '{{KEY}}';
  IF x <> 0 THEN RAISE EXCEPTION 'batch key already used: %', x; END IF;

  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{{EXP}}' THEN
    RAISE EXCEPTION 'live names differ from the Oct 30 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> 2 THEN RAISE EXCEPTION 'active venues % (expected 2)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id <> 'michelin';
  IF x <> 0 THEN RAISE EXCEPTION 'unexpected source_id: %', x; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug = 'michelin';
  IF x <> 1 THEN RAISE EXCEPTION 'michelin not registered in award_sources'; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_url text)
   WHERE p.source_url !~ '^https://guide\.michelin\.com/' OR p.source_url ~* '(joinpearl|thebestrestaurantsguide|beliapp)';
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

  SELECT count(*) INTO x FROM venues;          IF x <> {{VEN}} THEN RAISE EXCEPTION 'venues before % (expected {{VEN}})', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {{AWD}} THEN RAISE EXCEPTION 'awards before % (expected {{AWD}})', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {{SLG}} THEN RAISE EXCEPTION 'slugs before % (expected {{SLG}})', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {{LST}} THEN RAISE EXCEPTION 'listings before % (expected {{LST}})', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {{BLB}} THEN RAISE EXCEPTION 'blurbs before % (expected {{BLB}})', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {{RB}} THEN RAISE EXCEPTION 'rename_batches before % (expected {{RB}})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {{RR}} THEN RAISE EXCEPTION 'rename_rows before % (expected {{RR}})', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {{LEDN}} OR led_max <> {{LEDMAX}} THEN RAISE EXCEPTION 'ledger before % rows, last id % (expected {{LEDN}}, {{LEDMAX}})', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {{AUDN}} OR aud_max <> {{AUDMAX}} THEN
    RAISE EXCEPTION 'audit_log before % rows, last id % (expected {{AUDN}}, {{AUDMAX}})', aud_n, aud_max; END IF;

  -- 3. Writes (same order as the rename job)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('{{KEY}}', 'staged', 'Open items block 1 (Oct 30): Lavello -> Forentum, Les Fresques tagline removed. Card and site reads Oct 30 (decisions file open-items-b1-decisions-2026-10-30.txt), Ben ''All recommended'' 19:50 ET. Run as a gated SQL file through the Write connector, not the rename job; same writes as scripts/rename/apply.ts.')
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
  IF n <> 2 THEN RAISE EXCEPTION 'rename_rows inserted % (expected 2)', n; END IF;

  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = p.new_name
    FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
   WHERE v.id = p.venue_id AND v.name = p.expected_name;
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 2 THEN RAISE EXCEPTION 'venues renamed % (expected 2)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 2, 'rename-apply:{{KEY}} | gated SQL file docs/rename-open-items-b1-2026-10-30.sql (Write connector), same writes as the job | 2 rows follow the Michelin 2026 card and the venue site (Forentum, Les Fresques)');

  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'batch status update % (expected 1)', n; END IF;

  -- 4. Post-checks (the job's invariants)
  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text, new_name text) ON p.venue_id = v.id
   WHERE v.name IS DISTINCT FROM p.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'venues whose live name is not new_name: %', x; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{{NEW}}' THEN
    RAISE EXCEPTION 'live id|name after differs from the file'; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> {{VEN}} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {{AWD}} THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {{SLG}} THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {{LST}} THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {{BLB}} THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {{RB2}} THEN RAISE EXCEPTION 'rename_batches after % (expected {{RB2}})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {{RR2}} THEN RAISE EXCEPTION 'rename_rows after % (expected {{RR2}})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> 2 THEN RAISE EXCEPTION 'rename_rows in this batch % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> {{LEDN2}} THEN RAISE EXCEPTION 'ledger after % (expected {{LEDN2}})', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'name' AND items = 2 AND job LIKE 'rename-apply:{{KEY}} |%';
  IF x <> 1 THEN RAISE EXCEPTION 'ledger row for this batch % (expected 1)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 2 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 2)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
      ON a.row_pk = p.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.at = transaction_timestamp()
     AND a.old_row->>'name' = p.expected_name AND a.new_row->>'name' = p.new_name
     AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key');
  IF x <> 2 THEN RAISE EXCEPTION 'audit venue renames (name and norm_key only) % (expected 2)', x; END IF;
END
$do$;
COMMIT;
