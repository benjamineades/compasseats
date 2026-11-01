-- price-michelin-card-hong-kong-macau-2026.sql
-- Purpose: Hong Kong and Macau price from the 2026 Michelin card (open item 1, handoff-hkmo-native-done-2026-11-01).
-- Rule: the Michelin card price wins over a legacy price with no URL, for every guide (Ben, Sep 28, 2026).
--   Rows where the card tier equals the legacy tier are also updated (Ben, Oct 30, 2026): they get the card symbol,
--   currency, publisher michelin and the card URL.
-- Population: venues of the 2026 Michelin One/Two/Three Stars or Bib Gourmand rows whose source_url = a card in
--   ingest_rows batch 19 (michelin-2026-hong-kong-macau): 180 cards = 180 venues (Hong Kong 146, Macao 34), all active.
--   The 5 Green Star rows share a card URL with a star row; the category filter and DISTINCT give 1 row per venue.
-- Source: ingest_rows batch 19 price_symbol_raw (card symbol as printed; Cowork capture Nov 1, 2026; 4 venue pages
--   checked against the card; 0 differences between the English and Chinese cards). Read inside this file.
-- Currency: Hong Kong -> HKD, Macao -> MOP (Michelin price-range index: HK$ and MOP$). tier = symbol count.
-- Rows: 174 UPDATE of the legacy price row + 6 INSERT (Ando ve_694e8845c1 had no price row;
--   5 venues are new from the Nov 1 promote: An Choi, Dragon Inn, Eng Kee Noodle Shop, Eton,
--   Sang Kee Foods (Western District)).
-- Card vs legacy on the 174 rows: 171 same symbol, 3 differ (Feuille $$$$ -> $$$, Run $$$ -> $$$$,
--   Sun Tung Lok Chinese Cuisine $$ -> $$$).
-- Written values: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
--   confidence NULL, captured_at = ingest batch 19 created_at 2026-11-01 15:36:21.487926+00 (the capture rows entered the database; the Cowork capture ran earlier on Nov 1).
-- Currencies: HKD 146, MOP 34. Ledger row 207 (michelin, price, 180).
-- Gates: whole-table counts, last ledger id and last audit id before (single-use file); batch 19 created_at;
--   plan count and md5 (vid|url|symbol|currency|tier by vid): 0525e524d5b56b1bf77caa6e9f3c7649;
--   every target active, card URL = latest Michelin star/Bib card URL of the venue, country label = city country,
--   existing rows legacy_guide with no URL; old price rows md5 b8755c53352a292a6cebb360c009ad6e;
--   counts after; ledger id; exactly 180 audit rows on price (174 UPDATE, 6 INSERT), new values md5 = plan;
--   every price row now matches the plan.
-- Built by docs/hkmo-2026-build/build_price_hkmo_2026_11_01.py batch yes.
-- Dry run: send the whole DO block through the Read connector. It stops at the UPDATE with "read-only transaction".

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
  t_b19       timestamptz;
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
  -- Gate 1: whole-table counts, last ledger id and last audit id before; batch 19 created_at.
  SELECT count(*) INTO n_venues FROM venues;
  SELECT count(*) INTO n_awards FROM awards;
  SELECT count(*) INTO n_slugs FROM slugs;
  SELECT count(*), count(*) FILTER (WHERE source::text = 'legacy_guide') INTO n_price, n_legacy FROM price;
  SELECT coalesce(max(id), 0) INTO l_max_pre FROM source_capture_ledger;
  SELECT coalesce(max(id), 0) INTO a_max_pre FROM audit_log;
  SELECT created_at INTO t_b19 FROM ingest_batches WHERE id = 19 AND batch_key = 'michelin-2026-hong-kong-macau';
  IF (n_venues, n_awards, n_slugs, n_price, n_legacy, l_max_pre, a_max_pre)
     IS DISTINCT FROM (11300::bigint, 23368::bigint, 13001::bigint, 7727::bigint, 2554::bigint,
                       206::bigint, 121394::bigint)
     OR t_b19 IS DISTINCT FROM '2026-11-01 15:36:21.487926+00'::timestamptz THEN
    RAISE EXCEPTION 'Gate 1 failed: venues/awards/slugs/price/legacy/ledger max/audit max = %/%/%/%/%/%/%, batch 19 %',
      n_venues, n_awards, n_slugs, n_price, n_legacy, l_max_pre, a_max_pre, t_b19;
  END IF;

  -- Gate 2: the plan, read from ingest_rows batch 19.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 19
    )
  SELECT count(*), count(DISTINCT vid), count(*) FILTER (WHERE has_row),
         md5(string_agg(vid || '|' || url || '|' || sym || '|' || cur || '|' || tier, E'\n' ORDER BY vid)),
         md5(string_agg(vid || '|' || url || '|' || sym || '|' || cur || '|' || tier, E'\n' ORDER BY vid) FILTER (WHERE has_row)),
         md5(string_agg(vid || '|' || url || '|' || sym || '|' || cur || '|' || tier, E'\n' ORDER BY vid) FILTER (WHERE NOT has_row))
    INTO n_plan, n_dist, n_has, m_plan, m_upd, m_ins FROM plan;
  IF n_plan <> 180 OR n_dist <> 180 OR n_has <> 174
     OR m_plan IS DISTINCT FROM '0525e524d5b56b1bf77caa6e9f3c7649' OR m_upd IS DISTINCT FROM '0f4b0bf3cbcb77c7bfe4a228c36d4726' OR m_ins IS DISTINCT FROM '8e5d0ad861aada04db406cd1d88c512d' THEN
    RAISE EXCEPTION 'Gate 2 failed: plan rows %, distinct %, with price row %, md5 % / % / %', n_plan, n_dist, n_has, m_plan, m_upd, m_ins;
  END IF;

  -- Gate 3: every target is active; symbol is 1-4 "$"; currency known; country label = city country;
  --         card URL = the latest Michelin star/Bib card URL of the venue; an existing row is legacy_guide with no URL.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 19
    )
  SELECT count(*) INTO n_bad
    FROM plan p
    JOIN venues v ON v.id = p.vid
    LEFT JOIN price pr ON pr.venue_id = p.vid
   WHERE v.status::text <> 'active'
      OR p.sym !~ '^[$]{1,4}$' OR p.cur IS NULL OR p.cl IS DISTINCT FROM p.ctry
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

  -- Gate 4: the old price rows are exactly as read on Nov 1, 2026.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 19
    )
  SELECT md5(string_agg(md5(to_jsonb(pr)::text), '' ORDER BY pr.venue_id)) INTO m_old
    FROM price pr WHERE pr.venue_id IN (SELECT vid FROM plan);
  IF m_old IS DISTINCT FROM 'b8755c53352a292a6cebb360c009ad6e' THEN
    RAISE EXCEPTION 'Gate 4 failed: old price rows md5 %, expected b8755c53352a292a6cebb360c009ad6e', m_old;
  END IF;

  -- The change, part 1: UPDATE the 174 legacy price rows.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 19
    )
  UPDATE price pr
     SET tier = p.tier::smallint, symbol_raw = p.sym, currency = p.cur, source = 'guide_ingest'::price_source_t,
         method = 'published_symbol'::price_method_t, publisher = 'michelin', source_url = p.url,
         captured_at = '2026-11-01 15:36:21.487926+00'::timestamptz, confidence = NULL
    FROM plan p
   WHERE pr.venue_id = p.vid AND p.has_row AND pr.source::text = 'legacy_guide' AND pr.source_url IS NULL;
  GET DIAGNOSTICS n_upd = ROW_COUNT;
  IF n_upd <> 174 THEN
    RAISE EXCEPTION 'Update failed: % rows, expected 174', n_upd;
  END IF;

  -- The change, part 2: INSERT a price row for the 6 venues with none.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 19
    )
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at, confidence)
  SELECT p.vid, p.tier::smallint, p.sym, p.cur, 'guide_ingest'::price_source_t, 'published_symbol'::price_method_t,
         'michelin', p.url, '2026-11-01 15:36:21.487926+00'::timestamptz, NULL::real
    FROM plan p WHERE NOT p.has_row;
  GET DIAGNOSTICS n_ins = ROW_COUNT;
  IF n_ins <> 6 THEN
    RAISE EXCEPTION 'Insert failed: % rows, expected 6', n_ins;
  END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'price', 180,
          'price-card:price-michelin-card-hong-kong-macau-2026 | open item 1 (handoff-hkmo-native-done-2026-11-01): Hong Kong and Macau price from the 2026 card | '
          || '174 updated from legacy, 6 inserted (HKD 146, MOP 34) | source ingest_rows batch 19 price_symbol_raw '
          || '(Cowork capture Nov 1, 2026) | plan md5 0525e524d5b56b1bf77caa6e9f3c7649')
  RETURNING id INTO v_lid;
  IF v_lid <> 207 THEN
    RAISE EXCEPTION 'Ledger id %, expected 207', v_lid;
  END IF;

  -- Gate 5: whole-table counts after.
  SELECT count(*) INTO n_venues FROM venues;
  SELECT count(*) INTO n_awards FROM awards;
  SELECT count(*) INTO n_slugs FROM slugs;
  SELECT count(*), count(*) FILTER (WHERE source::text = 'legacy_guide') INTO n_price, n_legacy FROM price;
  IF (n_venues, n_awards, n_slugs, n_price, n_legacy)
     IS DISTINCT FROM (11300::bigint, 23368::bigint, 13001::bigint, 7733::bigint, 2380::bigint) THEN
    RAISE EXCEPTION 'Gate 5 failed: venues/awards/slugs/price/legacy = %/%/%/%/%, expected 11300/23368/13001/7733/2380',
      n_venues, n_awards, n_slugs, n_price, n_legacy;
  END IF;

  -- Gate 6: exactly 180 new audit rows, all on price (174 UPDATE, 6 INSERT), and the new values md5 = the plan md5.
  SELECT count(*) INTO n_audit FROM audit_log WHERE id > a_max_pre;
  SELECT count(*) INTO n_badaudit FROM audit_log
   WHERE id > a_max_pre AND NOT (table_name = 'price' AND action IN ('UPDATE', 'INSERT'));
  SELECT md5(string_agg(row_pk || '|' || (new_row->>'source_url') || '|' || (new_row->>'symbol_raw') || '|'
                        || (new_row->>'currency') || '|' || (new_row->>'tier'), E'\n' ORDER BY row_pk))
    INTO m_audit FROM audit_log WHERE id > a_max_pre;
  IF n_audit <> 180 OR n_badaudit <> 0 OR m_audit IS DISTINCT FROM '0525e524d5b56b1bf77caa6e9f3c7649'
     OR (SELECT count(*) FROM audit_log WHERE id > a_max_pre AND action = 'UPDATE') <> 174
     OR (SELECT count(*) FROM audit_log WHERE id > a_max_pre AND action = 'INSERT') <> 6 THEN
    RAISE EXCEPTION 'Gate 6 failed: % audit rows (expected 180), % not price UPDATE/INSERT, md5 %', n_audit, n_badaudit, m_audit;
  END IF;

  -- Gate 7: every plan row now matches its price row.
  WITH plan AS (
      SELECT DISTINCT a.venue_id AS vid, r.raw->>'source_url' AS url, r.raw->>'price_symbol_raw' AS sym,
             CASE c.country WHEN 'Hong Kong' THEN 'HKD' WHEN 'Macao' THEN 'MOP' END AS cur,
             char_length(r.raw->>'price_symbol_raw') AS tier,
             r.raw->>'country_label' AS cl, c.country AS ctry,
             EXISTS (SELECT 1 FROM price p0 WHERE p0.venue_id = a.venue_id) AS has_row
        FROM ingest_rows r
        JOIN awards a ON a.source_id = 'michelin' AND a.year = 2026 AND a.source_url = r.raw->>'source_url'
         AND a.category IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
        JOIN venues v ON v.id = a.venue_id
        JOIN cities c ON c.id = v.city_id
       WHERE r.batch_id = 19
    )
  SELECT count(*) INTO n_bad
    FROM plan p
    LEFT JOIN price pr ON pr.venue_id = p.vid
   WHERE (p.has_row OR true)
     AND (pr.venue_id IS NULL OR pr.tier <> p.tier OR pr.symbol_raw IS DISTINCT FROM p.sym
          OR pr.currency IS DISTINCT FROM p.cur OR pr.source::text <> 'guide_ingest'
          OR pr.method::text <> 'published_symbol' OR pr.publisher IS DISTINCT FROM 'michelin'
          OR pr.source_url IS DISTINCT FROM p.url OR pr.confidence IS NOT NULL
          OR pr.captured_at IS DISTINCT FROM '2026-11-01 15:36:21.487926+00'::timestamptz);
  IF n_bad <> 0 THEN
    RAISE EXCEPTION 'Gate 7 failed: % price rows do not match the plan', n_bad;
  END IF;

  RAISE NOTICE 'OK: % price rows updated, % inserted. Ledger %. Audit ids % to %.',
    n_upd, n_ins, v_lid, a_max_pre + 1, a_max_pre + n_audit;
END
$$;

COMMIT;

-- Read-back (run after the commit):
-- SELECT count(*), count(*) FILTER (WHERE source = 'legacy_guide') FROM price;  -- expect 7733 / 2380
-- SELECT c.country, p.currency, p.tier, count(*) FROM price p JOIN venues v ON v.id = p.venue_id
--   JOIN cities c ON c.id = v.city_id WHERE c.country IN ('Hong Kong', 'Macao') GROUP BY 1, 2, 3 ORDER BY 1, 2, 3;
