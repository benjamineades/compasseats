-- cleanup-michelin-tw-2025-contamination.sql
-- CompassEats, Oct 13 2026. Open item 2 of handoff-taiwan-renamed-2026-10-11:
-- the Taiwan contamination register (30 legacy Michelin 2025 Bib rows, no 2026 card).
-- Evidence: the 2025 Bib list (Michelin article counts; full list in the UDN reprint of the
--   Michelin list, Aug 12 2025) against the 2026 card names (venue_name_zh, batch 17).
-- Ben's decisions (Oct 13, 00:45 Atlanta): Q1 A, Q2 A, Q3 A, Q4 A.
--   Q1 A + Q3 A: delete 24 venues with all their rows (Chengdu held-7 method).
--     23 contamination venues (stored name is another business; the real 2025 Bib sits on a
--     2026 batch-17 venue) + ve_6593c6d776 (award 12426, the 2025 Bib of the dropped
--     Taichung Bib, on another business). Old URLs give a 404, no redirect.
--   Q2 A: Da-Wan ve_1972d080fc keeps the venue (OAD 2025 No. 419, award 11353), price,
--     labels 11291 and 11292. Delete Michelin award 11352 and label 11293 ("New Taipei",
--     neighborhood, no publisher).
--   Q4 A: keep the 5 true drops (awards 10704, 10716, 10718, 12444, 12463).
-- Venues deleted (24): ve_0bf4310fe5, ve_120732362b, ve_26371de8b1, ve_370aa54da0,
--   ve_49791827ea, ve_565d8cb24a, ve_6593c6d776, ve_6a29f13cd7,
--   ve_6f7474caab, ve_91f8ccee47, ve_9249a1737a, ve_9372d12543,
--   ve_9bb7b57e39, ve_ac1ee79102, ve_bbb0563a6a, ve_bcc0cd9ac9,
--   ve_c5bdb04069, ve_d82cc20325, ve_e25c8026ee, ve_e57f049689,
--   ve_e8331a52a7, ve_e929296edb, ve_ff2c645a20, ve_ff77e7b352
-- Pre-check (read Oct 13): each of the 24 venues holds 1 award (Michelin 2025 Bib Gourmand,
--   no source_url), 1 price (legacy_guide), 2 or 3 Michelin city labels, 1 listing,
--   1 canonical slug, 0 non-canonical slugs, 0 blurbs, 0 addresses, 0 geo, 0 hours,
--   0 photo_refs, 0 rename_rows, 0 ingest_rows, 0 redirects.
-- Guards (read Oct 13):
--   venue ids md5 (by id, ',')         b1e53b6d1a18c244152940d7510572c6 (24)
--   award ids md5 (by id, ',')         d475f15695b43b76b359997caedd8dbd (25 = 24 + 11352)
--   city label ids md5 (by id, ',')    f2299f32ae33dbc6478aa54389481107 (55 = 54 + 11293)
--   plan fingerprint (md5 of venue_id|name|city_id|award_id|category|year|symbol_raw|
--     price_source|city_slug/slug|city label ids, by venue_id, newline): 95124cd445f48cb08c22693063f2f06d
-- Write order (as ledger 85): 55 hand audit rows for city_label_source, then delete
--   city_label_source 55, awards 25, price 24, slugs 24, listings 24, venues 24, then 1 ledger row.
-- Expected audit rows: 176 (55 hand + 121 from triggers).
-- Dry run: send only the DO block through the Read connector. All pre-checks run, then the
--   block stops at the first INSERT with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan     jsonb;
  vids     text[];
  aids     bigint[];
  clsids   bigint[];
  fp       text;
  n        int;
  x        int;
  y        int;
  aud_max  bigint;
  aud_n    bigint;
  led_max  bigint;
  led_n    bigint;
  job_txt  text := 'cleanup:cleanup-michelin-tw-2025-contamination | contamination register (Ben, Oct 13): 24 legacy Michelin 2025 Taiwan Bib rows on another business, deleted with their venues; Da-Wan Michelin row 11352 and label 11293 deleted, venue kept (OAD) | award ids 10618,10619,10621,10623,10627,10628,10632,10706,10708,10709,10715,10722,11352,11357,11358,11359,11363,11364,11365,12426,12442,12449,12453,12457,12459 | 5 true drops kept: 10704,10716,10718,12444,12463 | old URLs 404, no redirect';
BEGIN
  -- 1. The plan, read live, and its guards
  vids := ARRAY['ve_0bf4310fe5', 've_120732362b', 've_26371de8b1', 've_370aa54da0',
                've_49791827ea', 've_565d8cb24a', 've_6593c6d776', 've_6a29f13cd7',
                've_6f7474caab', 've_91f8ccee47', 've_9249a1737a', 've_9372d12543',
                've_9bb7b57e39', 've_ac1ee79102', 've_bbb0563a6a', 've_bcc0cd9ac9',
                've_c5bdb04069', 've_d82cc20325', 've_e25c8026ee', 've_e57f049689',
                've_e8331a52a7', 've_e929296edb', 've_ff2c645a20', 've_ff77e7b352'];
  IF md5(array_to_string(vids, ',')) <> 'b1e53b6d1a18c244152940d7510572c6' THEN
    RAISE EXCEPTION 'venue id list md5 does not match';
  END IF;

  SELECT jsonb_agg(jsonb_build_object('venue_id', p.vid, 'award_id', p.aid, 'path', p.path) ORDER BY p.vid),
         count(*),
         md5(string_agg(p.vid||'|'||p.name||'|'||p.city_id||'|'||p.aid||'|'||p.category||'|'||p.year||'|'||p.symbol_raw||'|'||p.psrc||'|'||p.path||'|'||p.cls_ids,
                        E'\n' ORDER BY p.vid))
    INTO plan, n, fp
  FROM (
    SELECT v.id vid, v.name, v.city_id, a.id aid, a.category, a.year, pr.symbol_raw, pr.source::text psrc,
           s.city_slug||'/'||s.slug path,
           (SELECT string_agg(c.id::text, ',' ORDER BY c.id) FROM city_label_source c WHERE c.venue_id = v.id) cls_ids
      FROM venues v
      JOIN awards a  ON a.venue_id = v.id
      JOIN price pr  ON pr.venue_id = v.id
      JOIN slugs s   ON s.venue_id = v.id
     WHERE v.id = ANY (vids)) p;
  IF n <> 24 THEN RAISE EXCEPTION 'plan rows % (expected 24)', n; END IF;
  IF fp <> '95124cd445f48cb08c22693063f2f06d' THEN RAISE EXCEPTION 'plan fingerprint changed: %', fp; END IF;

  SELECT array_agg(id ORDER BY id) INTO aids FROM awards WHERE venue_id = ANY (vids) OR id = 11352;
  IF md5(array_to_string(aids, ',')) <> 'd475f15695b43b76b359997caedd8dbd' THEN
    RAISE EXCEPTION 'award id list md5 does not match';
  END IF;
  SELECT array_agg(id ORDER BY id) INTO clsids FROM city_label_source WHERE venue_id = ANY (vids) OR id = 11293;
  IF md5(array_to_string(clsids, ',')) <> 'f2299f32ae33dbc6478aa54389481107' THEN
    RAISE EXCEPTION 'city label id list md5 does not match';
  END IF;

  -- 2. Pre-checks on each venue (full venue pre-check)
  SELECT count(*) INTO x FROM venues v JOIN cities c ON c.id = v.city_id
   WHERE v.id = ANY (vids) AND v.status = 'active' AND c.country = 'Taiwan';
  IF x <> 24 THEN RAISE EXCEPTION 'active Taiwan venues in plan % (expected 24)', x; END IF;

  SELECT count(*) INTO x FROM awards WHERE venue_id = ANY (vids);
  IF x <> 24 THEN RAISE EXCEPTION 'award rows on the 24 venues % (expected 24)', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE id = ANY (aids) AND source_id = 'michelin' AND year = 2025
     AND category = 'Bib Gourmand' AND source_url IS NULL;
  IF x <> 25 THEN RAISE EXCEPTION 'unsourced Michelin 2025 Bib rows % (expected 25)', x; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id FROM awards WHERE venue_id = ANY (vids)
                               GROUP BY venue_id HAVING count(*) <> 1) d;
  IF x <> 0 THEN RAISE EXCEPTION 'venues with more or less than 1 award: %', x; END IF;

  SELECT count(*) INTO x FROM price WHERE venue_id = ANY (vids) AND source::text = 'legacy_guide';
  SELECT count(*) INTO y FROM price WHERE venue_id = ANY (vids);
  IF x <> 24 OR y <> 24 THEN RAISE EXCEPTION 'price rows % / legacy_guide % (expected 24 / 24)', y, x; END IF;

  SELECT count(*) INTO x FROM city_label_source WHERE venue_id = ANY (vids) AND publisher = 'michelin';
  IF x <> 54 THEN RAISE EXCEPTION 'Michelin city labels % (expected 54)', x; END IF;

  SELECT count(*) INTO x FROM listings WHERE venue_id = ANY (vids);
  IF x <> 24 THEN RAISE EXCEPTION 'listings % (expected 24)', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE is_canonical) INTO x, y
    FROM slugs WHERE venue_id = ANY (vids);
  IF x <> 24 OR y <> 24 THEN RAISE EXCEPTION 'slugs % / canonical % (expected 24 / 24)', x, y; END IF;

  SELECT count(*) INTO x FROM blurbs     WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'blurbs %', x; END IF;
  SELECT count(*) INTO x FROM addresses  WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'addresses %', x; END IF;
  SELECT count(*) INTO x FROM geo        WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'geo %', x; END IF;
  SELECT count(*) INTO x FROM hours      WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'hours %', x; END IF;
  SELECT count(*) INTO x FROM photo_refs WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'photo_refs %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'rename_rows %', x; END IF;

  SELECT count(*) INTO x FROM redirects r, jsonb_to_recordset(plan) q(path text)
   WHERE r.from_path LIKE '%' || q.path || '%' OR r.to_path LIKE '%' || q.path || '%';
  IF x <> 0 THEN RAISE EXCEPTION 'redirects that name a planned path: %', x; END IF;

  -- 2a. Da-Wan (Q2 A): award 11352 is its only Michelin row; label 11293 is "New Taipei"
  SELECT count(*) INTO x FROM awards
   WHERE id = 11352 AND venue_id = 've_1972d080fc' AND source_id = 'michelin' AND year = 2025
     AND category = 'Bib Gourmand' AND source_url IS NULL;
  IF x <> 1 THEN RAISE EXCEPTION 'Da-Wan award 11352 not as planned'; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = 've_1972d080fc';
  SELECT count(*) INTO y FROM awards WHERE venue_id = 've_1972d080fc' AND id = 11353 AND source_id = 'oad';
  IF x <> 2 OR y <> 1 THEN RAISE EXCEPTION 'Da-Wan awards % / OAD 11353 % (expected 2 / 1)', x, y; END IF;
  SELECT count(*) INTO x FROM city_label_source
   WHERE id = 11293 AND venue_id = 've_1972d080fc' AND label = 'New Taipei' AND from_column::text = 'neighborhood';
  IF x <> 1 THEN RAISE EXCEPTION 'Da-Wan label 11293 not as planned'; END IF;
  SELECT count(*) INTO x FROM city_label_source WHERE venue_id = 've_1972d080fc';
  IF x <> 3 THEN RAISE EXCEPTION 'Da-Wan labels % (expected 3)', x; END IF;

  -- 2b. The 5 kept true drops (Q4 A): each active with 1 Michelin 2025 Bib row
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.id IN (10704, 10716, 10718, 12444, 12463) AND v.status = 'active'
     AND a.source_id = 'michelin' AND a.year = 2025 AND a.category = 'Bib Gourmand'
     AND NOT (v.id = ANY (vids));
  IF x <> 5 THEN RAISE EXCEPTION 'kept true drops % (expected 5)', x; END IF;

  -- 3. Counts before
  SELECT count(*) INTO x FROM venues;                 IF x <> 11315 THEN RAISE EXCEPTION 'venues before % (expected 11315)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                      IF x <> 10948 THEN RAISE EXCEPTION 'active before % (expected 10948)', x; END IF;
  SELECT count(*) INTO x FROM awards;                 IF x <> 22866 THEN RAISE EXCEPTION 'awards before % (expected 22866)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                      IF x <> 3545 THEN RAISE EXCEPTION 'Michelin 2025 before % (expected 3545)', x; END IF;
  SELECT count(*) INTO x FROM listings;               IF x <> 11315 THEN RAISE EXCEPTION 'listings before % (expected 11315)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                  IF x <> 12837 THEN RAISE EXCEPTION 'slugs before % (expected 12837)', x; END IF;
  SELECT count(*) INTO x FROM price;                  IF x <> 7048 THEN RAISE EXCEPTION 'price before % (expected 7048)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;      IF x <> 24034 THEN RAISE EXCEPTION 'city labels before % (expected 24034)', x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE c.country = 'Taiwan' AND a.source_id = 'michelin' AND a.year = 2025;
                                                      IF x <> 175 THEN RAISE EXCEPTION 'Taiwan Michelin 2025 before % (expected 175)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 89 OR led_max <> 129 THEN RAISE EXCEPTION 'ledger before % / max % (expected 89 / 129)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 107138 OR aud_max <> 112278 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 107138 / 112278)', aud_n, aud_max; END IF;

  -- 4. Write
  -- 4a. Hand audit rows for city_label_source (no trigger on that table)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.id = ANY (clsids) ORDER BY c.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 55 THEN RAISE EXCEPTION 'hand audit rows % (expected 55)', n; END IF;

  DELETE FROM city_label_source WHERE id = ANY (clsids) AND (venue_id = ANY (vids) OR (id = 11293 AND venue_id = 've_1972d080fc'));
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 55 THEN RAISE EXCEPTION 'city labels deleted % (expected 55)', n; END IF;

  DELETE FROM awards WHERE id = ANY (aids) AND (venue_id = ANY (vids) OR (id = 11352 AND venue_id = 've_1972d080fc'))
     AND source_id = 'michelin' AND year = 2025 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 25 THEN RAISE EXCEPTION 'awards deleted % (expected 25)', n; END IF;

  DELETE FROM price WHERE venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'price deleted % (expected 24)', n; END IF;

  DELETE FROM slugs WHERE venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'slugs deleted % (expected 24)', n; END IF;

  DELETE FROM listings WHERE venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'listings deleted % (expected 24)', n; END IF;

  DELETE FROM venues WHERE id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 24 THEN RAISE EXCEPTION 'venues deleted % (expected 24)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 25, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 5. Post-checks
  SELECT (SELECT count(*) FROM venues            WHERE id = ANY (vids))
       + (SELECT count(*) FROM awards            WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM price             WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM city_label_source WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM slugs             WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM listings          WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM blurbs            WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM addresses         WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM geo               WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM hours             WHERE venue_id = ANY (vids))
       + (SELECT count(*) FROM photo_refs        WHERE venue_id = ANY (vids))
    INTO x;
  IF x <> 0 THEN RAISE EXCEPTION 'rows left on the 24 venues: %', x; END IF;

  -- 5a. Da-Wan after: venue active, OAD 11353 only, labels 11291 and 11292, 1 price, 1 listing, 1 canonical slug
  SELECT count(*) INTO x FROM venues WHERE id = 've_1972d080fc' AND status = 'active';
  IF x <> 1 THEN RAISE EXCEPTION 'Da-Wan venue missing or not active'; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id = 've_1972d080fc';
  SELECT count(*) INTO y FROM awards WHERE venue_id = 've_1972d080fc' AND id = 11353;
  IF x <> 1 OR y <> 1 THEN RAISE EXCEPTION 'Da-Wan awards after % / 11353 % (expected 1 / 1)', x, y; END IF;
  SELECT count(*) INTO x FROM city_label_source WHERE venue_id = 've_1972d080fc' AND id IN (11291, 11292);
  SELECT count(*) INTO y FROM city_label_source WHERE venue_id = 've_1972d080fc';
  IF x <> 2 OR y <> 2 THEN RAISE EXCEPTION 'Da-Wan labels after % / % (expected 2 / 2)', x, y; END IF;
  SELECT (SELECT count(*) FROM price WHERE venue_id = 've_1972d080fc')*100
       + (SELECT count(*) FROM listings WHERE venue_id = 've_1972d080fc')*10
       + (SELECT count(*) FROM slugs WHERE venue_id = 've_1972d080fc' AND is_canonical)
    INTO x;
  IF x <> 111 THEN RAISE EXCEPTION 'Da-Wan price/listing/slug code % (expected 111)', x; END IF;

  -- 5b. The 5 kept true drops are untouched
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE a.id IN (10704, 10716, 10718, 12444, 12463) AND v.status = 'active';
  IF x <> 5 THEN RAISE EXCEPTION 'kept true drops after % (expected 5)', x; END IF;

  -- 5c. Table counts after
  SELECT count(*) INTO x FROM venues;            IF x <> 11291 THEN RAISE EXCEPTION 'venues after % (expected 11291)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                 IF x <> 10924 THEN RAISE EXCEPTION 'active after % (expected 10924)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                 IF x <> 367 THEN RAISE EXCEPTION 'closed after % (expected 367)', x; END IF;
  SELECT count(*) INTO x FROM awards;            IF x <> 22841 THEN RAISE EXCEPTION 'awards after % (expected 22841)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2025;
                                                 IF x <> 3520 THEN RAISE EXCEPTION 'Michelin 2025 after % (expected 3520)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                 IF x <> 5527 THEN RAISE EXCEPTION 'Michelin 2026 changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2027;
                                                 IF x <> 47 THEN RAISE EXCEPTION 'Michelin 2027 changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id JOIN cities c ON c.id = v.city_id
   WHERE c.country = 'Taiwan' AND a.source_id = 'michelin' AND a.year = 2025;
                                                 IF x <> 150 THEN RAISE EXCEPTION 'Taiwan Michelin 2025 after % (expected 150)', x; END IF;
  SELECT count(*) INTO x FROM listings;          IF x <> 11291 THEN RAISE EXCEPTION 'listings after % (expected 11291)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12813 THEN RAISE EXCEPTION 'slugs after % (expected 12813)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;
                                                 IF x <> 11291 THEN RAISE EXCEPTION 'canonical slugs after % (expected 11291)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical;
                                                 IF x <> 1522 THEN RAISE EXCEPTION 'non-canonical slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical
                               GROUP BY v.id HAVING count(s.slug) <> 1) d;
                                                 IF x <> 0 THEN RAISE EXCEPTION 'venues with more or less than 1 canonical slug: %', x; END IF;
  SELECT count(*) INTO x FROM price;             IF x <> 7024 THEN RAISE EXCEPTION 'price after % (expected 7024)', x; END IF;
  SELECT count(*) INTO x FROM price WHERE source::text = 'guide_ingest';
                                                 IF x <> 10 THEN RAISE EXCEPTION 'guide_ingest price changed: %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 23979 THEN RAISE EXCEPTION 'city labels after % (expected 23979)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;            IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM redirects;         IF x <> 9 THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;

  -- 5d. Ledger and audit
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 90 THEN RAISE EXCEPTION 'ledger after % (expected 90)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 25 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 176 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 176)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND action = 'DELETE' AND new_row IS NULL AND (
         (table_name = 'city_label_source' AND row_pk = ANY (SELECT unnest(clsids)::text))
      OR (table_name = 'awards'            AND row_pk = ANY (SELECT unnest(aids)::text))
      OR (table_name IN ('price','slugs','listings','venues') AND row_pk = ANY (vids)));
  IF x <> 176 THEN RAISE EXCEPTION 'audit rows that match the plan % (expected 176)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND table_name = 'city_label_source'
     AND (old_row->>'venue_id' = ANY (vids) OR (row_pk = '11293' AND old_row->>'venue_id' = 've_1972d080fc'));
  IF x <> 55 THEN RAISE EXCEPTION 'hand audit rows with the deleted city label % (expected 55)', x; END IF;
END
$do$;
COMMIT;
