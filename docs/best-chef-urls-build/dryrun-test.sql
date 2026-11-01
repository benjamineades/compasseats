DO $do$
DECLARE
  rel text := (SELECT string_agg(id||'|'||year||'|x', E'
' ORDER BY id) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL AND id NOT IN (3453, 15690, 15727, 15997, 16190));
  v_n int; v_lid bigint; v_txt text;
BEGIN
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 178 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119438 OR (SELECT count(*) FROM audit_log) <> 114154 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL) <> 1299
    THEN RAISE EXCEPTION 'best-chef rows without URL before'; END IF;

  -- plan fingerprint: the relay rows, read live (best-chef, same year, no URL)
  SELECT count(*), md5(string_agg(a.id||'|'||a.year||'|'||a.venue_id||'|'||a.category, E'\n' ORDER BY a.id))
    INTO v_n, v_txt
    FROM awards a JOIN regexp_split_to_table(rel, E'\n') l
      ON a.id = split_part(l, '|', 1)::bigint AND a.year = split_part(l, '|', 2)::int
   WHERE a.source_id = 'best-chef-awards' AND a.source_url IS NULL;
  IF v_n <> 1294 OR v_txt IS DISTINCT FROM '4edff41c2c2485ded4824a79ed4b5daa' THEN RAISE EXCEPTION 'plan fingerprint % %', v_n, v_txt; END IF;

  UPDATE awards a SET source_url = CASE a.year WHEN 2024 THEN 'https://thebestchefawards.com/events-results/?id=1874' WHEN 2025 THEN 'https://thebestchefawards.com/events-results/?id=2376' END
    FROM regexp_split_to_table(rel, E'\n') l
   WHERE a.id = split_part(l, '|', 1)::bigint AND a.year = split_part(l, '|', 2)::int
     AND a.source_id = 'best-chef-awards' AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT; IF v_n <> 1294 THEN RAISE EXCEPTION 'award rows updated: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 518,
          'source-url:source-url-best-chef-2024-2025-2026-11-01 | 518 Best Chef Awards 2024 rows get the 2024 results page https://thebestchefawards.com/events-results/?id=1874 '
          || '(Dubai 2024); each row pairs to one knife card of the same knife count (read Nov 1 2026, pairs in docs/best-chef-urls-build/) '
          || '| 15879 keeps the 2024 list PDF URL | Ben "items 1 & 2 first" Nov 1 00:47 ET')
  RETURNING id INTO v_lid;
  IF v_lid <> 179 THEN RAISE EXCEPTION 'ledger id 2024 %', v_lid; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 776,
          'source-url:source-url-best-chef-2024-2025-2026-11-01 | 776 Best Chef Awards 2025 rows get the 2025 results page https://thebestchefawards.com/events-results/?id=2376 '
          || '(Milan 2025); each row pairs to one knife card of the same knife count (read Nov 1 2026) '
          || '| held, no URL: 3453 Flores Raras, 15690 Ensue 2-Knife, 15727 8 1/2 Otto e Mezzo Macau, 15997 Fo''ao Vaperse Hotel, 16190 The Fellas '
          || '| Ben "items 1 & 2 first" Nov 1 00:47 ET')
  RETURNING id INTO v_lid;
  IF v_lid <> 180 THEN RAISE EXCEPTION 'ledger id 2025 %', v_lid; END IF;

  -- post-checks
  IF (SELECT count(*) FROM awards) <> 23363 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL) <> 5
    THEN RAISE EXCEPTION 'best-chef rows without URL after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year IN (2024, 2025) AND source_url IS NULL
         AND id NOT IN (3453, 15690, 15727, 15997, 16190)) <> 0 THEN RAISE EXCEPTION 'held rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year = 2024 AND source_url = 'https://thebestchefawards.com/events-results/?id=1874') <> 518
    THEN RAISE EXCEPTION '2024 URL rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id = 'best-chef-awards' AND year = 2025 AND source_url = 'https://thebestchefawards.com/events-results/?id=2376') <> 776
    THEN RAISE EXCEPTION '2025 URL rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119438) <> 1294 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119438 AND table_name = 'awards' AND action = 'UPDATE'
         AND (old_row - 'source_url') = (new_row - 'source_url') AND old_row->>'source_url' IS NULL
         AND new_row->>'source_url' IN ('https://thebestchefawards.com/events-results/?id=1874', 'https://thebestchefawards.com/events-results/?id=2376')) <> 1294
    THEN RAISE EXCEPTION 'audit awards (source_url only)'; END IF;
END
$do$;