-- p1-rest-held-b2-2026-10-30.sql
-- Held P1-rest venues, batch 2 of 2 (venue changes). Ben Oct 30, 2026, 15:11 ET: "go with your recommendations" (all A).
-- Merges (Chengdu delete method): the held branch venue holds only the 2026 Bib of a card whose 2025 Bib sits on a sister
--   venue. Move the award row to the sister (source_url NULL -> card URL); sister legacy price (no URL) -> card row
--   (guide_ingest, VND); held slug -> sister, non-canonical; hand audit + DELETE 2 city labels; DELETE listing; DELETE venue.
--   CHAY GARDEN: card 1201807 "Chay Garden (Xuan Hoa)", 52 Vo Van Tan; sister name holds the street.
--   Hong Phat: card 1205566 "Hong Phat (Ban Co)", 389-391 Vo Van Tan; hutieuhongphat.com branch 01 Quan 3 = 389-391.
--   Man Moi: card 1211006 "Man Moi (An Khanh)", 32 D11 Street, An Khanh Ward; manmoi.vn/en/our-locations: Thao Dien =
--     32 St. 11, W. An Khanh; Ben Nghe = 125 Hai Ba Trung, W. Sai Gon.
-- Move: Paloma Taqueria Auckland -> Wanaka (card 1247956, 28 Helwick Street, Wanaka). Status stays active.
--   Award 21210 and the price row already hold the card URL (batch 1). City label 21594 Auckland -> Wanaka (the 5 other
--   Wanaka venues hold "Wanaka"). cities.venues_count is not changed (open decision).
-- Relay sha256 d23c77cf2805be3242df19cf6477f2074eecf808fbb902ca3fec9ce05c7f527a (inside this file). Relay fingerprint md5 2b4e083aeb9008d9bd2e69d4af979a87. Held venue ids md5 bf94e9bcc04f5d9855a9b4f2d86a4b68.
-- Guards: price 7730, ledger max 159, audit max 118728, awards 23353, venues 11307 (active 10940),
--   slugs 12842, listings 11307, city labels 24011; old rows fingerprint 1f810ecb01106604d517f8bef7edcabe (46 rows on the 7 venues);
--   active star/Bib venues with no price 6; venues without exactly 1 canonical slug 0; card URLs not in use.
-- Post-checks: venues 11304 (active 10937); awards 23353; price 7730; slugs 12843;
--   listings 11304; city labels 24005; ledgers 160 (award), 161 (price), 162 (city_label);
--   audit 118729 to 118753: awards UPDATE 3, city_label_source DELETE 6, city_label_source UPDATE 1, listings DELETE 3, price UPDATE 3, slugs INSERT 1, slugs UPDATE 4, venues DELETE 3, venues UPDATE 1, nothing else; 0 rows left on the 3 held ids in the 10 FK tables;
--   active star/Bib venues with no price 3; venues without exactly 1 canonical slug 0.
BEGIN;
DO $do$
DECLARE
  rel_txt text := $r$merge|ve_3a9de72b7b|ve_c1ed9b62ab|21121|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/man-moi-thu-duc-city|₫₫|CAT_P02|bib|False|vn|2026-10-30T20:56:08.410Z|ho-chi-minh-city/man-moi-ben-nghe-homey-authentic-vietnamese-cuisine
move|ve_3fad690140|ci_daf6d172be|21210|us/en/south-island/wanaka_2306683/restaurant/paloma-taqueria|$$|CAT_P02|bib|False|nz|2026-10-30T20:56:09.665Z|auckland/paloma-taqueria
merge|ve_595408ccd8|ve_39dc53fd44|21126|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3|₫|CAT_P01|bib|False|vn|2026-10-30T20:56:10.921Z|ho-chi-minh-city/hu-tieu-hong-phat-hong-phat-ben-thanh
merge|ve_f97f8ec140|ve_3195442b2e|21122|us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/chay-garden|₫|CAT_P01|bib|False|vn|2026-10-30T20:56:12.178Z|ho-chi-minh-city/chay-garden-nguyen-thi-minh-khai-vegetarian-restaurant-space$r$;
  rel jsonb;
  ids text[];
  v_fp text;
  v_bad int;
  v_n int;
BEGIN
  IF (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'price count before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 159 THEN RAISE EXCEPTION 'ledger max before'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118728 THEN RAISE EXCEPTION 'audit max before'; END IF;
  IF (SELECT count(*) FROM awards) <> 23353 THEN RAISE EXCEPTION 'awards count before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11307 THEN RAISE EXCEPTION 'venues count before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10940 THEN RAISE EXCEPTION 'active venues before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12842 THEN RAISE EXCEPTION 'slugs count before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11307 THEN RAISE EXCEPTION 'listings count before'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24011 THEN RAISE EXCEPTION 'city labels count before'; END IF;
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> 'd23c77cf2805be3242df19cf6477f2074eecf808fbb902ca3fec9ce05c7f527a' THEN RAISE EXCEPTION 'relay sha256'; END IF;

  -- relay line: op|venue_id|target|award_id|card|symbol|CAT_P0n|distinction|greenstar|country|captured_at|old_slug
  SELECT jsonb_agg(jsonb_build_object(
           'op', f[1], 'venue_id', f[2], 'target', f[3], 'award_id', f[4], 'url', 'https://guide.michelin.com/' || f[5],
           'symbol_raw', f[6], 'currency', CASE f[10] WHEN 'vn' THEN 'VND' WHEN 'nz' THEN 'NZD' END,
           'tier', char_length(f[6]), 'captured_at', f[11],
           'old_city_slug', split_part(f[12], '/', 1), 'old_slug', split_part(f[12], '/', 2)) ORDER BY f[2] COLLATE "C"),
         count(*) FILTER (WHERE array_length(f, 1) <> 12 OR f[7] <> 'CAT_P0' || char_length(f[6])
                            OR f[6] <> repeat(left(f[6], 1), char_length(f[6])) OR f[8] <> 'bib' OR f[9] <> 'False'
                            OR f[1] NOT IN ('merge','move') OR f[10] NOT IN ('vn','nz')
                            OR left(f[6], 1) <> CASE f[10] WHEN 'vn' THEN '₫' WHEN 'nz' THEN '$' END)
    INTO rel, v_bad
    FROM (SELECT string_to_array(l, '|') AS f FROM regexp_split_to_table(rel_txt, E'\n') AS l) s;
  IF v_bad <> 0 THEN RAISE EXCEPTION 'relay lines malformed: %', v_bad; END IF;
  IF jsonb_array_length(rel) <> 4 THEN RAISE EXCEPTION 'relay rows: %', jsonb_array_length(rel); END IF;
  SELECT md5(string_agg(x.op||'|'||x.venue_id||'|'||x.target||'|'||x.award_id||'|'||x.url||'|'||x.symbol_raw||'|'
                        ||x.currency||'|'||x.tier||'|'||x.captured_at||'|'||x.old_city_slug||'|'||x.old_slug,
                        E'\n' ORDER BY x.venue_id COLLATE "C"))
    INTO v_fp FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text);
  IF v_fp <> '2b4e083aeb9008d9bd2e69d4af979a87' THEN RAISE EXCEPTION 'relay fingerprint %', v_fp; END IF;
  SELECT md5(string_agg(x.venue_id, ',' ORDER BY x.venue_id COLLATE "C")) INTO v_fp
    FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text) WHERE x.op = 'merge';
  IF v_fp <> 'bf94e9bcc04f5d9855a9b4f2d86a4b68' THEN RAISE EXCEPTION 'held venue ids md5 %', v_fp; END IF;

  -- every row on the 7 venues, as read before the build
  SELECT array_agg(v ORDER BY v COLLATE "C") INTO ids FROM (
    SELECT x.venue_id AS v FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
    UNION SELECT x.target FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text) WHERE x.op = 'merge') u;
  IF array_length(ids, 1) <> 7 THEN RAISE EXCEPTION 'venue id set'; END IF;
  SELECT md5(string_agg(t || ':' || j, E'\n' ORDER BY t COLLATE "C", j COLLATE "C")) FROM (
           SELECT 'venues' AS t, to_jsonb(v)::text AS j FROM venues v WHERE v.id = ANY (ids)
           UNION ALL SELECT 'awards', to_jsonb(a)::text FROM awards a WHERE a.venue_id = ANY (ids)
           UNION ALL SELECT 'price', to_jsonb(p)::text FROM price p WHERE p.venue_id = ANY (ids)
           UNION ALL SELECT 'slugs', to_jsonb(s)::text FROM slugs s WHERE s.venue_id = ANY (ids)
           UNION ALL SELECT 'listings', to_jsonb(l)::text FROM listings l WHERE l.venue_id = ANY (ids)
           UNION ALL SELECT 'cls', to_jsonb(c)::text FROM city_label_source c WHERE c.venue_id = ANY (ids)) s INTO v_fp;
  IF v_fp IS DISTINCT FROM '1f810ecb01106604d517f8bef7edcabe' THEN RAISE EXCEPTION 'old rows fingerprint %', v_fp; END IF;
  IF (SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id)) <> 6 THEN RAISE EXCEPTION 'active star/Bib venues with no price before'; END IF;
  IF (SELECT count(*) FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) <> 1) <> 0 THEN RAISE EXCEPTION 'canonical slugs before'; END IF;

  -- per-row conditions
  SELECT count(*) INTO v_bad FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.status = 'active')
      OR NOT EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = x.venue_id AND s.city_slug = x.old_city_slug
                       AND s.slug = x.old_slug AND s.property_id = 'eats' AND s.is_canonical)
      OR (SELECT count(*) FROM slugs s WHERE s.venue_id = x.venue_id) <> 1
      OR (x.op = 'merge' AND (
             NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.venue_id
                           AND a.source_id = 'michelin' AND a.year = 2026 AND a.category = 'Bib Gourmand'
                           AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL)
          OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.venue_id) <> 1
          OR EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id)
          OR NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.target AND v.status = 'active')
          OR (SELECT count(*) FROM awards a WHERE a.venue_id = x.target AND a.source_id = 'michelin' AND a.year = 2025
                AND a.category = 'Bib Gourmand') <> 1
          OR EXISTS (SELECT 1 FROM awards a WHERE a.venue_id = x.target AND a.year = 2026)
          OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.target AND p.source = 'legacy_guide'
                           AND p.source_url IS NULL AND p.currency IS NULL AND p.tier = x.tier)
          OR (SELECT count(*) FROM city_label_source c WHERE c.venue_id = x.venue_id) <> 2
          OR (SELECT count(*) FROM listings l WHERE l.venue_id = x.venue_id) <> 1))
      OR (x.op = 'move' AND (
             NOT EXISTS (SELECT 1 FROM venues v WHERE v.id = x.venue_id AND v.city_id = 'ci_4665921775')
          OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id = x.target AND c.slug = 'wanaka')
          OR EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = 'wanaka' AND s.slug = x.old_slug)
          OR NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.venue_id
                           AND a.source_url = x.url AND a.year = 2026 AND a.category = 'Bib Gourmand')
          OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.venue_id AND p.source_url = x.url)
          OR NOT EXISTS (SELECT 1 FROM city_label_source c WHERE c.id = 21594 AND c.venue_id = x.venue_id
                           AND c.label = 'Auckland' AND c.from_column = 'city_display' AND c.publisher = 'michelin')));
  IF v_bad <> 0 THEN RAISE EXCEPTION 'rows changed since the read: %', v_bad; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text) ON a.source_url = x.url WHERE x.op = 'merge')
    THEN RAISE EXCEPTION 'a card URL is already in use on an award row'; END IF;
  IF EXISTS (SELECT 1 FROM price p JOIN jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text) ON p.source_url = x.url WHERE x.op = 'merge')
    THEN RAISE EXCEPTION 'a card URL is already in use on a price row'; END IF;

  -- merges: award row -> sister, with the card URL
  UPDATE awards a SET venue_id = x.target, source_url = x.url
    FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE x.op = 'merge' AND a.id = x.award_id::bigint AND a.venue_id = x.venue_id AND a.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'award rows moved: %', v_n; END IF;
  -- merges: sister legacy price -> card row
  UPDATE price p SET source = 'guide_ingest', method = 'published_symbol', publisher = 'michelin', source_url = x.url,
         symbol_raw = x.symbol_raw, currency = x.currency, tier = x.tier, confidence = NULL,
         captured_at = x.captured_at::timestamptz
    FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE x.op = 'merge' AND p.venue_id = x.target AND p.source = 'legacy_guide' AND p.source_url IS NULL;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'price rows updated: %', v_n; END IF;
  -- merges: held slug -> sister, non-canonical (old-slug policy)
  UPDATE slugs s SET venue_id = x.target, is_canonical = false
    FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE x.op = 'merge' AND s.venue_id = x.venue_id AND s.city_slug = x.old_city_slug AND s.slug = x.old_slug
     AND s.property_id = 'eats';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'slug rows moved: %', v_n; END IF;
  -- merges: city labels (no trigger: hand audit rows first)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140') ORDER BY c.id;
  DELETE FROM city_label_source WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140');
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 6 THEN RAISE EXCEPTION 'city labels deleted: %', v_n; END IF;
  DELETE FROM listings WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140');
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'listings deleted: %', v_n; END IF;
  DELETE FROM venues WHERE id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140');
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 3 THEN RAISE EXCEPTION 'venues deleted: %', v_n; END IF;

  -- move: Paloma Taqueria Auckland -> Wanaka
  UPDATE venues v SET city_id = x.target FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE x.op = 'move' AND v.id = x.venue_id AND v.city_id = 'ci_4665921775';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'venue city updated: %', v_n; END IF;
  UPDATE slugs s SET is_canonical = false FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE x.op = 'move' AND s.venue_id = x.venue_id AND s.city_slug = x.old_city_slug AND s.slug = x.old_slug
     AND s.property_id = 'eats' AND s.is_canonical;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'old slug set non-canonical: %', v_n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', 'wanaka', x.old_slug, x.venue_id, true FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text) WHERE x.op = 'move';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'new slug inserted: %', v_n; END IF;
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'UPDATE', to_jsonb(c), to_jsonb(c) || jsonb_build_object('label', 'Wanaka')
    FROM city_label_source c WHERE c.id = 21594 AND c.label = 'Auckland';
  UPDATE city_label_source SET label = 'Wanaka' WHERE id = 21594 AND label = 'Auckland';
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'city label updated: %', v_n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin', 'award', 3, 'merge:p1-rest-held-b2-2026-10-30 | held P1 rest batch 2: 3 Vietnam branch merges; 2026 Bib row moved to the sister venue (sister holds the 2025 Bib of the same card), source_url NULL -> card URL | 21122 CHAY GARDEN Nguyen Thi Minh Khai ve_f97f8ec140 -> CHAY GARDEN Vo Van Tan ve_3195442b2e (card 1201807, 52 Vo Van Tan); 21126 Hong Phat Ben Thanh ve_595408ccd8 -> Hu Tieu Hong Phat ve_39dc53fd44 (card 1205566, 389-391 Vo Van Tan = venue site branch 01 Quan 3); 21121 Man Moi Ben Nghe ve_3a9de72b7b -> Man Moi Thao Dien ve_c1ed9b62ab (card 1211006, 32 D11 An Khanh = manmoi.vn Thao Dien 32 St. 11 W. An Khanh; Ben Nghe = 125 Hai Ba Trung) | held venues deleted with their listing and 2 city labels each; old slugs kept non-canonical on the sister | Ben A Oct 30 15:11 ET; Man Moi confirmed 17:07 ET | relay md5 2b4e083aeb9008d9bd2e69d4af979a87'),
    ('michelin', 'price', 3, 'price-card:p1-rest-held-b2-2026-10-30 | held P1 rest batch 2: sister legacy price rows with no URL -> card row | 3 rows updated from legacy (VND 3; tiers 1 = 2, 2 = 1) | live card read, built-in browser | relay md5 2b4e083aeb9008d9bd2e69d4af979a87'),
    ('michelin', 'city_label', 1, 'city-move:p1-rest-held-b2-2026-10-30 | Paloma Taqueria ve_3fad690140: city Auckland ci_4665921775 -> Wanaka ci_daf6d172be (card 1247956: 28 Helwick Street, Wanaka); michelin city label 21594 Auckland -> Wanaka; slug wanaka/paloma-taqueria canonical, auckland/paloma-taqueria kept non-canonical | Ben A Oct 30 15:11 ET; label Wanaka 17:07 ET | relay md5 2b4e083aeb9008d9bd2e69d4af979a87');

  -- post-checks
  IF (SELECT count(*) FROM venues) <> 11304 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'active') <> 10937 THEN RAISE EXCEPTION 'active after'; END IF;
  IF (SELECT count(*) FROM awards) <> 23353 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM price) <> 7730 THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 12843 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11304 THEN RAISE EXCEPTION 'listings after'; END IF;
  IF (SELECT count(*) FROM city_label_source) <> 24005 THEN RAISE EXCEPTION 'city labels after'; END IF;
  IF (SELECT array_agg(id ORDER BY id) FROM source_capture_ledger WHERE id > 159) <> ARRAY[160,161,162]::bigint[]
    THEN RAISE EXCEPTION 'ledger ids after'; END IF;
  IF (SELECT max(id) FROM audit_log) <> 118753 OR (SELECT count(*) FROM audit_log WHERE id > 118728) <> 25
    THEN RAISE EXCEPTION 'audit range after'; END IF;
  IF (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'awards' AND action = 'UPDATE') = 3 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'city_label_source' AND action = 'DELETE') = 6 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'city_label_source' AND action = 'UPDATE') = 1 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'listings' AND action = 'DELETE') = 3 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'price' AND action = 'UPDATE') = 3 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'slugs' AND action = 'INSERT') = 1 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'slugs' AND action = 'UPDATE') = 4 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'venues' AND action = 'DELETE') = 3 THEN 0 ELSE 1 END) + (CASE WHEN (SELECT count(*) FROM audit_log WHERE id BETWEEN 118729 AND 118753 AND table_name = 'venues' AND action = 'UPDATE') = 1 THEN 0 ELSE 1 END) <> 0 THEN RAISE EXCEPTION 'audit rows by table and action'; END IF;
  IF (SELECT count(*) FROM addresses WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM awards WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM blurbs WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM city_label_source WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM geo WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM hours WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM listings WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM photo_refs WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM price WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) + (SELECT count(*) FROM slugs WHERE venue_id IN ('ve_3a9de72b7b','ve_595408ccd8','ve_f97f8ec140')) <> 0 THEN RAISE EXCEPTION 'rows left on the held venue ids'; END IF;
  IF (SELECT count(DISTINCT v.id) FROM venues v JOIN awards a ON a.venue_id = v.id
       WHERE v.status = 'active' AND a.source_id = 'michelin'
         AND a.category IN ('One Star','Two Stars','Three Stars','Bib Gourmand')
         AND NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = v.id)) <> 3 THEN RAISE EXCEPTION 'active star/Bib venues with no price after'; END IF;
  IF (SELECT count(*) FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.is_canonical) <> 1) <> 0 THEN RAISE EXCEPTION 'canonical slugs after'; END IF;
  SELECT count(*) INTO v_bad FROM jsonb_to_recordset(rel) AS x(op text, venue_id text, target text, award_id text, url text, symbol_raw text, currency text, tier int, captured_at text, old_city_slug text, old_slug text)
   WHERE x.op = 'merge' AND (
         NOT EXISTS (SELECT 1 FROM awards a WHERE a.id = x.award_id::bigint AND a.venue_id = x.target AND a.source_url = x.url)
      OR NOT EXISTS (SELECT 1 FROM price p WHERE p.venue_id = x.target AND p.source_url = x.url
                       AND p.symbol_raw = x.symbol_raw AND p.currency = 'VND' AND p.source = 'guide_ingest')
      OR NOT EXISTS (SELECT 1 FROM slugs s WHERE s.venue_id = x.target AND s.slug = x.old_slug AND NOT s.is_canonical)
      OR (SELECT count(*) FROM slugs s WHERE s.venue_id = x.target AND s.is_canonical) <> 1);
  IF v_bad <> 0 THEN RAISE EXCEPTION 'sister rows after: %', v_bad; END IF;
  IF NOT EXISTS (SELECT 1 FROM venues WHERE id = 've_3fad690140' AND city_id = 'ci_daf6d172be' AND status = 'active')
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = 've_3fad690140' AND city_slug = 'wanaka' AND is_canonical)
     OR NOT EXISTS (SELECT 1 FROM slugs WHERE venue_id = 've_3fad690140' AND city_slug = 'auckland' AND NOT is_canonical)
    THEN RAISE EXCEPTION 'Paloma rows after'; END IF;
END
$do$;
COMMIT;
