-- merge-istanbul-turk-2026-10-30.sql
-- CompassEats, Oct 30 2026 (Atlanta). Open items block 3, file 2 of 2. It holds DELETE: run it in the Supabase SQL Editor
--   (SQL Editor -> New query -> paste the whole file -> Run). Run it only after file 1
--   (slugs-heritage-open-items-b3-2026-10-30.sql); the guards stop it otherwise.
-- Ben: Oct 30 23:11 ET "All recommended" (D1 = A: merge; D4 = A: this file in the SQL Editor).
--
-- Problem: venue ve_a19227e5fa "Istanbul" (city Istanbul, slug istanbul/istanbul) holds only Best Chef Awards rows
--   15879 (2024, 1-Knife) and 15878 (2025, 1-Knife). The legacy load resolved the restaurant to the city centre
--   ("Istanbul, Istanbul, Turkiye"), so the restaurant name was lost.
-- Evidence: The Best Chef Awards 2024 list (PDF, https://thebestchefawards.com/wp-content/uploads/2024/11/List-2024_The-Best-Chef-Awards.pdf)
--   has 4 Turkey entries: Neolokal (2 knives), Macakizi, Apartiman Yenikoy, Fatih Tutak "TURK FATIH TUTAK" Istanbul (1 knife).
--   The database has 4 Turkey rows for 2024: Neolokal, Macakizi, Apartiman Yenikoy and "Istanbul". The Best Chef page of
--   Fatih Tutak (https://thebestchefawards.com/chefs/fatih-tutak/, read Oct 31) gives restaurant TURK, one knife.
--   TURK is ve_9852cbf26e "Turk Fatih Tutak" (Istanbul; Michelin 2026 Two Stars, La Liste 2026, OAD 2025) with 0 Best Chef rows.
-- What this file does (one transaction):
--   awards 15879 and 15878: venue_id -> ve_9852cbf26e; 15879 source_url NULL -> the 2024 list PDF; 15878 keeps NULL
--     (no 2025 list was readable).
--   slug istanbul/istanbul -> ve_9852cbf26e, non-canonical (the old URL keeps working; old-slug policy).
--   city_label_source 15453 ("Istanbul", city_display) and 15454 ("Turkey", country), publisher best-chef-awards: hand audit
--     rows, then DELETE (as the Oct 30 Vietnam merges). TURK keeps its own 2 labels.
--   listings DELETE 1, venues DELETE 1. Name of TURK unchanged (held name item). Ledger 171 (best-chef-awards, award, 2).
-- Audit rows 119,070-119,076 (7): awards UPDATE 2, slugs UPDATE 1, city_label_source DELETE 2 (hand),
--   listings DELETE 1, venues DELETE 1.
-- Relay relay-merge.txt sha256 ca32f3c151a4bd15b7f3259deaa44ba5268f5c915106b376895cc8531be45a57, md5 b74285c834fdd5e4bc342eaed2b3b87c.
BEGIN;
DO $do$
DECLARE
  rel text := $r$award|15878|ve_a19227e5fa|ve_9852cbf26e|2025|1-Knife|
award|15879|ve_a19227e5fa|ve_9852cbf26e|2024|1-Knife|https://thebestchefawards.com/wp-content/uploads/2024/11/List-2024_The-Best-Chef-Awards.pdf
slug|-|ve_a19227e5fa|ve_9852cbf26e|istanbul|istanbul|
label|15453|ve_a19227e5fa|-|city_display|Istanbul|best-chef-awards
label|15454|ve_a19227e5fa|-|country|Turkey|best-chef-awards$r$;
  v_n int;
  v_lid bigint;
  v_txt text;
BEGIN
  -- 1. relay and live state
  IF md5(rel) <> 'b74285c834fdd5e4bc342eaed2b3b87c' OR encode(sha256(convert_to(rel, 'UTF8')), 'hex') <> 'ca32f3c151a4bd15b7f3259deaa44ba5268f5c915106b376895cc8531be45a57'
    THEN RAISE EXCEPTION 'relay hash'; END IF;
  IF (SELECT count(*) FROM venues) <> 11304 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10935 THEN RAISE EXCEPTION 'active before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23362 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12936 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1632 THEN RAISE EXCEPTION 'non-canonical before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11304 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24005 THEN RAISE EXCEPTION 'city labels before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 170 THEN RAISE EXCEPTION 'ledger max before (run file 1 first)'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119069 OR (SELECT count(*) FROM audit_log) <> 113785
    THEN RAISE EXCEPTION 'audit_log before (run file 1 first)'; END IF;

  -- 2. rows on the held venue, as read before the build
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_a19227e5fa' AND name = 'Istanbul' AND status = 'active' AND city_id = 'ci_2609eaea1a')
    THEN RAISE EXCEPTION 'held venue'; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_9852cbf26e' AND name = 'Turk Fatih Tutak' AND status = 'active' AND city_id = 'ci_2609eaea1a')
    THEN RAISE EXCEPTION 'target venue'; END IF;
  SELECT md5(string_agg('award|'||a.id||'|'||a.venue_id||'|ve_9852cbf26e|'||a.year||'|'||a.category||'|'||
                        CASE WHEN a.year = 2024 THEN 'https://thebestchefawards.com/wp-content/uploads/2024/11/List-2024_The-Best-Chef-Awards.pdf' ELSE '' END, E'\n' ORDER BY a.id))
    INTO v_txt FROM awards a WHERE a.venue_id = 've_a19227e5fa' AND a.source_id = 'best-chef-awards' AND a.source_url IS NULL
      AND a.rank IS NULL AND a.distinction IS NULL;
  IF v_txt IS DISTINCT FROM '918b15c84a13c43375ee177b5546178b' THEN RAISE EXCEPTION 'held award rows %', v_txt; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_a19227e5fa') <> 2 THEN RAISE EXCEPTION 'held award count'; END IF;
  SELECT md5(string_agg('label|'||c.id||'|'||c.venue_id||'|-|'||c.from_column||'|'||c.label||'|'||c.publisher, E'\n' ORDER BY c.id))
    INTO v_txt FROM city_label_source c WHERE c.venue_id = 've_a19227e5fa';
  IF v_txt IS DISTINCT FROM 'd29466f94a908c94c457e8a2ff75f8e8' THEN RAISE EXCEPTION 'held city labels %', v_txt; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id = 've_a19227e5fa') <> 1
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = 've_a19227e5fa' AND property_id = 'eats' AND city_slug = 'istanbul'
                      AND slug = 'istanbul' AND is_canonical)
    THEN RAISE EXCEPTION 'held slug'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id = 've_a19227e5fa') <> 1 THEN RAISE EXCEPTION 'held listing'; END IF;
  IF (SELECT count(*) FROM price WHERE venue_id = 've_a19227e5fa') + (SELECT count(*) FROM blurbs WHERE venue_id = 've_a19227e5fa')
     + (SELECT count(*) FROM geo WHERE venue_id = 've_a19227e5fa') + (SELECT count(*) FROM addresses WHERE venue_id = 've_a19227e5fa')
     + (SELECT count(*) FROM hours WHERE venue_id = 've_a19227e5fa') + (SELECT count(*) FROM photo_refs WHERE venue_id = 've_a19227e5fa')
     + (SELECT count(*) FROM rename_rows WHERE venue_id = 've_a19227e5fa') <> 0
    THEN RAISE EXCEPTION 'held venue has other child rows'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path LIKE '%istanbul/istanbul%' OR to_path LIKE '%istanbul/istanbul%')
    THEN RAISE EXCEPTION 'redirect on the old path'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id = 've_9852cbf26e' AND source_id = 'best-chef-awards')
    THEN RAISE EXCEPTION 'target already has Best Chef rows'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url = 'https://thebestchefawards.com/wp-content/uploads/2024/11/List-2024_The-Best-Chef-Awards.pdf') THEN RAISE EXCEPTION 'PDF URL in use'; END IF;

  -- 3. writes
  UPDATE awards a SET venue_id = split_part(l, '|', 4), source_url = nullif(split_part(l, '|', 7), '')
    FROM regexp_split_to_table(rel, E'\n') AS l
   WHERE split_part(l, '|', 1) = 'award' AND a.id = split_part(l, '|', 2)::bigint AND a.venue_id = split_part(l, '|', 3)
     AND a.year = split_part(l, '|', 5)::int AND a.category = split_part(l, '|', 6) AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'award rows moved: %', v_n; END IF;

  UPDATE slugs SET venue_id = 've_9852cbf26e', is_canonical = false
   WHERE property_id = 'eats' AND venue_id = 've_a19227e5fa' AND city_slug = 'istanbul' AND slug = 'istanbul';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'slug rows moved: %', v_n; END IF;

  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.venue_id = 've_a19227e5fa' ORDER BY c.id;
  DELETE FROM city_label_source WHERE venue_id = 've_a19227e5fa';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 2 THEN RAISE EXCEPTION 'city labels deleted: %', v_n; END IF;
  DELETE FROM listings WHERE venue_id = 've_a19227e5fa';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'listings deleted: %', v_n; END IF;
  DELETE FROM venues WHERE id = 've_a19227e5fa';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'venues deleted: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('best-chef-awards', 'award', 2,
          'merge:merge-istanbul-turk-2026-10-30 | venue ve_a19227e5fa "Istanbul" (legacy load lost the restaurant name) = TURK FATIH '
          || 'TUTAK (Fatih Tutak, Istanbul, 1 knife): Best Chef 2024 list has 4 Turkey entries = the 4 Turkey 2024 rows | awards '
          || '15879 (2024) and 15878 (2025) -> ve_9852cbf26e; 15879 source_url = 2024 list PDF; 15878 no URL | old slug istanbul/istanbul '
          || 'non-canonical on TURK; held venue deleted with its listing and 2 city labels | Ben "All recommended" Oct 30 23:11 ET '
          || '(D1 = A) | relay md5 b74285c834fdd5e4bc342eaed2b3b87c')
  RETURNING id INTO v_lid;

  -- 4. post-checks
  IF v_lid <> 171 OR (SELECT max(id) FROM source_capture_ledger) <> 171 THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT count(*) FROM venues) <> 11303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10934 THEN RAISE EXCEPTION 'active after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23362 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12936 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE is_canonical) <> 11303 THEN RAISE EXCEPTION 'canonical after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1633 THEN RAISE EXCEPTION 'non-canonical after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11303 THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24003 THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical AND s.property_id = 'eats'
              GROUP BY v.id HAVING count(s.slug) <> 1)
    THEN RAISE EXCEPTION 'a venue has other than 1 canonical slug'; END IF;
  SELECT string_agg(id||' '||year||' '||category||' '||coalesce(source_url, '-'), ', ' ORDER BY id) INTO v_txt
    FROM awards WHERE venue_id = 've_9852cbf26e' AND source_id = 'best-chef-awards';
  IF v_txt IS DISTINCT FROM '15878 2025 1-Knife -, 15879 2024 1-Knife https://thebestchefawards.com/wp-content/uploads/2024/11/List-2024_The-Best-Chef-Awards.pdf'
    THEN RAISE EXCEPTION 'target Best Chef rows after: %', v_txt; END IF;
  IF NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = 've_9852cbf26e' AND city_slug = 'istanbul' AND slug = 'istanbul' AND NOT is_canonical)
    THEN RAISE EXCEPTION 'old slug after'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id = 've_a19227e5fa') + (SELECT count(*) FROM slugs WHERE venue_id = 've_a19227e5fa')
     + (SELECT count(*) FROM city_label_source WHERE venue_id = 've_a19227e5fa') + (SELECT count(*) FROM listings WHERE venue_id = 've_a19227e5fa')
     + (SELECT count(*) FROM venues WHERE id = 've_a19227e5fa') <> 0
    THEN RAISE EXCEPTION 'rows left on the held venue id'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 119076 OR (SELECT count(*) FROM audit_log WHERE id > 119069) <> 7
    THEN RAISE EXCEPTION 'audit range after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > 119069 AND table_name = 'awards' AND action = 'UPDATE' AND row_pk IN ('15878', '15879')) <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > 119069 AND table_name = 'slugs' AND action = 'UPDATE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > 119069 AND table_name = 'city_label_source' AND action = 'DELETE'
           AND row_pk IN ('15453', '15454')) <> 2
     OR (SELECT count(*) FROM audit_log WHERE id > 119069 AND table_name = 'listings' AND action = 'DELETE') <> 1
     OR (SELECT count(*) FROM audit_log WHERE id > 119069 AND table_name = 'venues' AND action = 'DELETE'
           AND row_pk = 've_a19227e5fa') <> 1
    THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
END
$do$;
COMMIT;
