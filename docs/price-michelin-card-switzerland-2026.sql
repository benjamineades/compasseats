-- price-michelin-card-switzerland-2026.sql
-- Purpose: Switzerland and Liechtenstein price from the 2026 Michelin card (Swiss open item, decision 4).
-- Rule: the Michelin card price wins over a legacy price with no URL (Ben Sep 28, Oct 30, 2026).
-- Population: 225 cards in ingest_rows batch 20 = 225 venues (Switzerland 224, Liechtenstein 1), all active.
-- Rows: 191 UPDATE of the legacy row, 34 INSERT. Same tier 186, tier change 5: Birdy's by Achtien $$$$ -> €€, Tosca $$$$ -> €€€,
--   Wöschi $$$ -> €€€€, Gasthaus Löwen $$$$ -> €€€, L'Atelier Robuchon $$$ -> €€€€.
-- Values: symbol as printed, currency CHF on all 225 (Ben 4A), Torkel $$$ included. tier = symbol count. source guide_ingest,
--   method published_symbol, publisher michelin, source_url = card URL, confidence NULL, captured_at = batch 20 created_at.
-- Expected after: price 7,761 (legacy_guide 2,182), ledger 245, audit +225 (to 125,565).
-- Built by docs/ch-2026-build/build_price_ch_2026_11_03.py from docs/price-michelin-card-hong-kong-macau-2026.sql.

BEGIN;

DO $$
DECLARE
  n_venues    bigint;
  n_awards    bigint;
  n_slugs     bigint;
  n_price     bigint;
  n_legacy    bigint;
  l_max_pre   bigint;
  a_max_pre   bigint;
  t_b20       timestamptz;
  n_plan      bigint;
  n_dist      bigint;
  n_has       bigint;
  m_plan      text;
  m_upd       text;
  m_ins       text;
  m_old       text;
  n_bad       bigint;
  n_upd       bigint;
  n_ins       bigint;
  v_lid       bigint;
  n_audit     bigint;
  n_badaudit  bigint;
  m_audit     text;
BEGIN
  -- Gate 1: whole-table counts, last ledger id and last audit id before; batch 20 created_at.
  SELECT count(*) INTO n_venues FROM venues;
  SELECT count(*) INTO n_awards FROM awards;
  SELECT count(*) INTO n_slugs FROM slugs;
  SELECT count(*), count(*) FILTER (WHERE source::text = 'legacy_guide') INTO n_price, n_legacy FROM price;
  SELECT coalesce(max(id), 0) INTO l_max_pre FROM source_capture_ledger;
  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;
  SELECT created_at INTO t_b20 FROM ingest_batches WHERE id = 20 AND batch_key = 'michelin-2026-switzerland';
  IF (n_venues, n_awards, n_slugs, n_price, n_legacy, l_max_pre, a_max_pre)
     IS DISTINCT FROM (11323::bigint, 25321::bigint, 13144::bigint, 7727::bigint, 2373::bigint,
                       244::bigint, 125340::bigint)
     OR t_b20 IS DISTINCT FROM '2026-11-02 23:34:19.10987+00'::timestamptz THEN
    RAISE EXCEPTION 'Gate 1 failed: venues/awards/slugs/price/legacy/ledger max/audit max = %/%/%/%/%/%/%, batch 20 %',
      n_venues, n_awards, n_slugs, n_price, n_legacy, l_max_pre, a_max_pre, t_b20;
  END IF;

  -- Gate 2: the plan, read from ingest_rows batch 20.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             'CHF'::text AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 20
    )
  SELECT count(*), count(DISTINCT vid), count(*) FILTER (WHERE has_row),
         md5(string_agg(vid || '|' || url || '|' || sym || '|' || cur || '|' || tier, E'\n' ORDER BY vid)),
         md5(string_agg(vid || '|' || url || '|' || sym || '|' || cur || '|' || tier, E'\n' ORDER BY vid) FILTER (WHERE has_row)),
         md5(string_agg(vid || '|' || url || '|' || sym || '|' || cur || '|' || tier, E'\n' ORDER BY vid) FILTER (WHERE NOT has_row))
    INTO n_plan, n_dist, n_has, m_plan, m_upd, m_ins FROM plan;
  IF n_plan <> 225 OR n_dist <> 225 OR n_has <> 191
     OR m_plan IS DISTINCT FROM '88b231838dc59fadf1614b4fe61e1072' OR m_upd IS DISTINCT FROM 'ed4945a679c844cdca8181c04f0a2423' OR m_ins IS DISTINCT FROM '6701d521c54c32b70d9376095fb8f4d0' THEN
    RAISE EXCEPTION 'Gate 2 failed: plan rows %, distinct %, with price row %, md5 % / % / %', n_plan, n_dist, n_has, m_plan, m_upd, m_ins;
  END IF;

  -- Gate 3: every target is active; symbol is 1-4 of $ or €; currency known; country label = city country;
  --         card URL = the latest Michelin star/Bib card URL of the venue; an existing row is legacy_guide with no URL.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             'CHF'::text AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 20
    )
  SELECT count(*) INTO n_bad
    FROM plan p
    JOIN venues v ON v.id = p.vid
    LEFT JOIN price pr ON pr.venue_id = p.vid
   WHERE v.status::text <> 'active'
      OR p.sym !~ '^([$]{1,4}|€{1,4})$' OR p.cur IS NULL OR p.cl IS DISTINCT FROM p.ctry
      OR p.url IS DISTINCT FROM (
           SELECT a.source_url FROM awards a
            WHERE a.venue_id = p.vid AND a.source_id = 'michelin'
              AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
              AND a.source_url ~ '^https://guide[.]michelin[.]com/.*/restaurant/'
            ORDER BY a.year DESC, a.id DESC LIMIT 1)
      OR (pr.venue_id IS NOT NULL AND (pr.source::text <> 'legacy_guide' OR pr.source_url IS NOT NULL));
  IF n_bad <> 0 THEN
    RAISE EXCEPTION 'Gate 3 failed: % target rows fail the row checks', n_bad;
  END IF;

  -- Gate 4: the old price rows are exactly as read on Nov 3, 2026.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             'CHF'::text AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 20
    )
  SELECT md5(string_agg(md5(to_jsonb(pr)::text), '' ORDER BY pr.venue_id)) INTO m_old
    FROM price pr WHERE pr.venue_id IN (SELECT vid FROM plan);
  IF m_old IS DISTINCT FROM 'b6345e68cba18fcae310923ac157bd61' THEN
    RAISE EXCEPTION 'Gate 4 failed: old price rows md5 %, expected b6345e68cba18fcae310923ac157bd61', m_old;
  END IF;

  -- The change, part 1: UPDATE the 191 legacy price rows.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             'CHF'::text AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 20
    )
  UPDATE price pr
     SET tier = p.tier::smallint, symbol_raw = p.sym, currency = p.cur, source = 'guide_ingest'::price_source_t,
         method = 'published_symbol'::price_method_t, publisher = 'michelin', source_url = p.url,
         captured_at = '2026-11-02 23:34:19.10987+00'::timestamptz, confidence = NULL
    FROM plan p
   WHERE pr.venue_id = p.vid AND p.has_row AND pr.source::text = 'legacy_guide' AND pr.source_url IS NULL;
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 191 THEN
    RAISE EXCEPTION 'Update failed: % rows, expected 191', n_upd;
  END IF;

  -- The change, part 2: INSERT a price row for the 34 venues with none.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             'CHF'::text AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 20
    )
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT p.vid, p.tier::smallint, p.sym, p.cur, 'guide_ingest'::price_source_t, 'published_symbol'::price_method_t,
         'michelin', p.url, '2026-11-02 23:34:19.10987+00'::timestamptz, NULL::real
    FROM plan p WHERE NOT p.has_row;
  GET DIAGNOSTICS n_ins = ROW_COUNT;
  IF n_ins <> 34 THEN
    RAISE EXCEPTION 'Insert failed: % rows, expected 34', n_ins;
  END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', 225,
          'price-card:price-michelin-card-switzerland-2026 | Swiss decision 4 (Ben Nov 2 18:09 ET 4A), go Nov 3: Switzerland and Liechtenstein price from the 2026 card | '
          || '191 updated from legacy, 34 inserted (CHF 225, symbols as printed) | source ingest_rows batch 20 price_symbol_raw '
          || '(Cowork capture Nov 2, 2026) | plan md5 88b231838dc59fadf1614b4fe61e1072')
  RETURNING id INTO v_lid;
  IF v_lid <> 245 THEN
    RAISE EXCEPTION 'Ledger id %, expected 245', v_lid;
  END IF;

  -- Gate 5: whole-table counts after.
  SELECT count(*) INTO n_venues FROM venues;
  SELECT count(*) INTO n_awards FROM awards;
  SELECT count(*) INTO n_slugs FROM slugs;
  SELECT count(*), count(*) FILTER (WHERE source::text = 'legacy_guide') INTO n_price, n_legacy FROM price;
  IF (n_venues, n_awards, n_slugs, n_price, n_legacy)
     IS DISTINCT FROM (11323::bigint, 25321::bigint, 13144::bigint, 7761::bigint, 2182::bigint) THEN
    RAISE EXCEPTION 'Gate 5 failed: venues/awards/slugs/price/legacy = %/%/%/%/%, expected 11323/25321/13144/7761/2182',
      n_venues, n_awards, n_slugs, n_price, n_legacy;
  END IF;

  -- Gate 6: exactly 225 new audit rows, all on price (191 UPDATE, 34 INSERT), and the new values md5 = the plan md5.
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre AND NOT (table_name = 'price' AND action IN ('UPDATE', 'INSERT'));
  SELECT md5(string_agg(row_pk || '|' || (new_row->>'source_url') || '|' || (new_row->>'symbol_raw') || '|'
                        || (new_row->>'currency') || '|' || (new_row->>'tier'), E'\n' ORDER BY row_pk))
    INTO m_audit FROM audit_log WHERE id > a_max_pre;
  IF n_audit <> 225 OR n_badaudit <> 0 OR m_audit IS DISTINCT FROM '88b231838dc59fadf1614b4fe61e1072'
     OR (SELECT count(*) FROM audit_log WHERE id > a_max_pre AND action = 'UPDATE') <> 191
     OR (SELECT count(*) FROM audit_log WHERE id > a_max_pre AND action = 'INSERT') <> 34 THEN
    RAISE EXCEPTION 'Gate 6 failed: % audit rows (expected 225), % not price UPDATE/INSERT, md5 %', n_audit, n_badaudit, m_audit;
  END IF;

  -- Gate 7: every plan row now matches its price row.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             'CHF'::text AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 20
    )
  SELECT count(*) INTO n_bad
    FROM plan p
    LEFT JOIN price pr ON pr.venue_id = p.vid
   WHERE (p.has_row OR true)
     AND (pr.venue_id IS NULL OR pr.tier <> p.tier OR pr.symbol_raw IS DISTINCT FROM p.sym
          OR pr.currency IS DISTINCT FROM p.cur OR pr.source::text <> 'guide_ingest'
          OR pr.method::text <> 'published_symbol' OR pr.publisher IS DISTINCT FROM 'michelin'
          OR pr.source_url IS DISTINCT FROM p.url OR pr.confidence IS NOT NULL
          OR pr.captured_at IS DISTINCT FROM '2026-11-02 23:34:19.10987+00'::timestamptz);
  IF n_bad <> 0 THEN
    RAISE EXCEPTION 'Gate 7 failed: % price rows do not match the plan', n_bad;
  END IF;

  RAISE NOTICE 'OK: % price rows updated, % inserted. Ledger %. Audit ids % to %.',
    n_upd, n_ins, v_lid, a_max_pre + 1, a_max_pre + n_audit;
END
$$;

COMMIT;
