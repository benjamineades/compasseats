-- cleanup-michelin-cn-chengdu-held-7.sql
-- CompassEats, Oct 2 2026. Open item 1 of handoff-chengdu-2026-sourced-25-2026-10-02:
-- Chengdu archive method test 1, step 3 of 3. Delete the 7 held legacy venues under the
-- standing contamination rule (Ben, Sep 28): a legacy venue with a place name and no provable
-- link to a card is deleted with its rows (method of ledger 52 / 76). Old URL gives a 404,
-- no redirect.
-- Held list (Sep 28): none is a 2026 Bib on the archived 2026 edition; price leaves 6
--   candidates per row, so no pairing is provable.
--   ve_ff8d4998fc Shudaxia Hot Pot Luomashi Branch      award 9774  $$
--   ve_27c721b197 Zhongshuijiao                         award 9775  $
--   ve_a63b7965ed Jincheng Fengqiwu Freshwater Fishes R. award 9778  $$
--   ve_c2e875e4a0 Shuyanfu                              award 9779  $
--   ve_8593c366aa Ma Wang Zi Chuan Restaurant           award 9783  $
--   ve_29c8d7a57b Citadines South Chengdu               award 9785  $$
--   ve_51c6534d14 Tivano                                award 9789  $$ (2027 Selected only)
-- Pre-check (read Oct 2): each venue holds 1 award (Michelin 2026 Bib Gourmand, no
--   source_url, no other publisher), 1 price (legacy_guide), 2 city labels (Chengdu, China),
--   1 listing, 1 canonical slug, 0 blurbs, 0 addresses, 0 geo, 0 hours, 0 photo_refs,
--   0 rename_rows, 0 ingest_rows, 0 redirects.
-- Guards (read Oct 2):
--   venue ids md5 (by id, ',')          31285f27f58b1afd957f57af75578557
--   award ids md5 (by id, ',')          bcc44f12bc65c96bb5bed543ecdb668b (= held list md5)
--   city label ids md5 (by id, ',')     507a33fb2a5f4e9a1eb296b449f9e8c1 (14 rows)
--   plan fingerprint (md5 of venue_id|name|award_id|category|symbol_raw|price_source|
--     city_slug/slug|city label ids, by venue_id, newline): bfca2dfd2f940e704c2f9aba94570da3
-- Write order (as ledger 76): 14 hand audit rows for city_label_source, then delete
--   city_label_source 14, awards 7, price 7, slugs 7, listings 7, venues 7, then 1 ledger row.
-- Expected audit rows: 49 (14 hand + 35 from triggers).
-- After: Chengdu Michelin 2026 = 40 rows (Two Stars 2, One Star 11, Bib 27), 0 unsourced.
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
  job_txt  text := 'cleanup:cleanup-michelin-cn-chengdu-held-7 | contamination rule (Ben, Sep 28): 7 legacy Michelin 2026 Chengdu Bib rows with no provable pairing, deleted with their venues | award ids 9774,9775,9778,9779,9783,9785,9789 | old URLs 404, no redirect | archive method test 1, step 3 of 3';
BEGIN
  -- 1. The plan, read live, and its guards
  vids := ARRAY['ve_27c721b197','ve_29c8d7a57b','ve_51c6534d14','ve_8593c366aa',
                've_a63b7965ed','ve_c2e875e4a0','ve_ff8d4998fc'];
  IF md5(array_to_string(vids, ',')) <> '31285f27f58b1afd957f57af75578557' THEN
    RAISE EXCEPTION 'venue id list md5 does not match';
  END IF;

  SELECT jsonb_agg(jsonb_build_object('venue_id', p.vid, 'award_id', p.aid, 'path', p.path) ORDER BY p.vid),
         count(*),
         md5(string_agg(p.vid||'|'||p.name||'|'||p.aid||'|'||p.category||'|'||p.symbol_raw||'|'||p.psrc||'|'||p.path||'|'||p.cls_ids,
                        E'\n' ORDER BY p.vid))
    INTO plan, n, fp
  FROM (
    SELECT v.id vid, v.name, a.id aid, a.category, pr.symbol_raw, pr.source::text psrc,
           s.city_slug||'/'||s.slug path,
           (SELECT string_agg(c.id::text, ',' ORDER BY c.id) FROM city_label_source c WHERE c.venue_id = v.id) cls_ids
      FROM venues v
      JOIN awards a  ON a.venue_id = v.id
      JOIN price pr  ON pr.venue_id = v.id
      JOIN slugs s   ON s.venue_id = v.id
     WHERE v.id = ANY (vids)) p;
  IF n <> 7 THEN RAISE EXCEPTION 'plan rows % (expected 7)', n; END IF;
  IF fp <> 'bfca2dfd2f940e704c2f9aba94570da3' THEN RAISE EXCEPTION 'plan fingerprint changed: %', fp; END IF;

  SELECT array_agg(id ORDER BY id) INTO aids FROM awards WHERE venue_id = ANY (vids);
  IF md5(array_to_string(aids, ',')) <> 'bcc44f12bc65c96bb5bed543ecdb668b' THEN
    RAISE EXCEPTION 'award id list md5 does not match';
  END IF;
  SELECT array_agg(id ORDER BY id) INTO clsids FROM city_label_source WHERE venue_id = ANY (vids);
  IF md5(array_to_string(clsids, ',')) <> '507a33fb2a5f4e9a1eb296b449f9e8c1' THEN
    RAISE EXCEPTION 'city label id list md5 does not match';
  END IF;

  -- 2. Pre-checks on each venue (full venue pre-check)
  SELECT count(*) INTO x FROM venues
   WHERE id = ANY (vids) AND status = 'active' AND city_id = 'ci_354b500e3a';
  IF x <> 7 THEN RAISE EXCEPTION 'active Chengdu venues in plan % (expected 7)', x; END IF;

  SELECT count(*) INTO x FROM awards WHERE venue_id = ANY (vids);
  IF x <> 7 THEN RAISE EXCEPTION 'award rows on the 7 venues % (expected 7)', x; END IF;
  SELECT count(*) INTO x FROM awards
   WHERE venue_id = ANY (vids) AND source_id = 'michelin' AND year = 2026
     AND category = 'Bib Gourmand' AND source_url IS NULL;
  IF x <> 7 THEN RAISE EXCEPTION 'unsourced Michelin 2026 Bib rows % (expected 7)', x; END IF;
  SELECT count(*) INTO x FROM (SELECT venue_id FROM awards WHERE venue_id = ANY (vids)
                               GROUP BY venue_id HAVING count(*) <> 1) d;
  IF x <> 0 THEN RAISE EXCEPTION 'venues with more or less than 1 award: %', x; END IF;

  SELECT count(*) INTO x FROM price WHERE venue_id = ANY (vids) AND source::text = 'legacy_guide';
  SELECT count(*) INTO y FROM price WHERE venue_id = ANY (vids);
  IF x <> 7 OR y <> 7 THEN RAISE EXCEPTION 'price rows % / legacy_guide % (expected 7 / 7)', y, x; END IF;

  SELECT count(*) INTO x FROM city_label_source WHERE venue_id = ANY (vids) AND publisher = 'michelin';
  IF x <> 14 THEN RAISE EXCEPTION 'Michelin city labels % (expected 14)', x; END IF;

  SELECT count(*) INTO x FROM listings WHERE venue_id = ANY (vids);
  IF x <> 7 THEN RAISE EXCEPTION 'listings % (expected 7)', x; END IF;
  SELECT count(*), count(*) FILTER (WHERE is_canonical AND city_slug = 'chengdu') INTO x, y
    FROM slugs WHERE venue_id = ANY (vids);
  IF x <> 7 OR y <> 7 THEN RAISE EXCEPTION 'slugs % / canonical chengdu % (expected 7 / 7)', x, y; END IF;

  SELECT count(*) INTO x FROM blurbs     WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'blurbs %', x; END IF;
  SELECT count(*) INTO x FROM addresses  WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'addresses %', x; END IF;
  SELECT count(*) INTO x FROM geo        WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'geo %', x; END IF;
  SELECT count(*) INTO x FROM hours      WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'hours %', x; END IF;
  SELECT count(*) INTO x FROM photo_refs WHERE venue_id = ANY (vids); IF x <> 0 THEN RAISE EXCEPTION 'photo_refs %', x; END IF;

  SELECT count(*) INTO x FROM redirects r, jsonb_to_recordset(plan) q(path text)
   WHERE r.from_path LIKE '%' || q.path || '%' OR r.to_path LIKE '%' || q.path || '%';
  IF x <> 0 THEN RAISE EXCEPTION 'redirects that name a planned path: %', x; END IF;

  -- 3. Counts before
  SELECT count(*) INTO x FROM venues;                 IF x <> 11212 THEN RAISE EXCEPTION 'venues before % (expected 11212)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                      IF x <> 10846 THEN RAISE EXCEPTION 'active before % (expected 10846)', x; END IF;
  SELECT count(*) INTO x FROM awards;                 IF x <> 22256 THEN RAISE EXCEPTION 'awards before % (expected 22256)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                      IF x <> 4666 THEN RAISE EXCEPTION 'Michelin 2026 before % (expected 4666)', x; END IF;
  SELECT count(*) INTO x FROM listings;               IF x <> 11212 THEN RAISE EXCEPTION 'listings before % (expected 11212)', x; END IF;
  SELECT count(*) INTO x FROM slugs;                  IF x <> 12311 THEN RAISE EXCEPTION 'slugs before % (expected 12311)', x; END IF;
  SELECT count(*) INTO x FROM price;                  IF x <> 7056 THEN RAISE EXCEPTION 'price before % (expected 7056)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;      IF x <> 23828 THEN RAISE EXCEPTION 'city labels before % (expected 23828)', x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE v.city_id = 'ci_354b500e3a' AND a.source_id = 'michelin' AND a.year = 2026;
                                                      IF x <> 47 THEN RAISE EXCEPTION 'Chengdu 2026 rows before % (expected 47)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 64 OR led_max <> 84 THEN RAISE EXCEPTION 'ledger before % / max % (expected 64 / 84)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 103856 OR aud_max <> 107245 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 103856 / 107245)', aud_n, aud_max; END IF;

  -- 4. Write
  -- 4a. Hand audit rows for city_label_source (no trigger on that table)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'DELETE', to_jsonb(c), NULL
    FROM city_label_source c WHERE c.id = ANY (clsids) ORDER BY c.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'hand audit rows % (expected 14)', n; END IF;

  DELETE FROM city_label_source WHERE id = ANY (clsids) AND venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 14 THEN RAISE EXCEPTION 'city labels deleted % (expected 14)', n; END IF;

  DELETE FROM awards WHERE id = ANY (aids) AND venue_id = ANY (vids)
     AND source_id = 'michelin' AND year = 2026 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'awards deleted % (expected 7)', n; END IF;

  DELETE FROM price WHERE venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'price deleted % (expected 7)', n; END IF;

  DELETE FROM slugs WHERE venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'slugs deleted % (expected 7)', n; END IF;

  DELETE FROM listings WHERE venue_id = ANY (vids);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'listings deleted % (expected 7)', n; END IF;

  DELETE FROM venues WHERE id = ANY (vids) AND city_id = 'ci_354b500e3a';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 7 THEN RAISE EXCEPTION 'venues deleted % (expected 7)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 7, job_txt);
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
  IF x <> 0 THEN RAISE EXCEPTION 'rows left on the 7 venues: %', x; END IF;

  SELECT count(*) INTO x FROM venues;            IF x <> 11205 THEN RAISE EXCEPTION 'venues after % (expected 11205)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'active';
                                                 IF x <> 10839 THEN RAISE EXCEPTION 'active after % (expected 10839)', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status = 'closed';
                                                 IF x <> 366 THEN RAISE EXCEPTION 'closed after % (expected 366)', x; END IF;
  SELECT count(*) INTO x FROM awards;            IF x <> 22249 THEN RAISE EXCEPTION 'awards after % (expected 22249)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND year = 2026;
                                                 IF x <> 4659 THEN RAISE EXCEPTION 'Michelin 2026 after % (expected 4659)', x; END IF;
  SELECT count(*) INTO x FROM listings;          IF x <> 11205 THEN RAISE EXCEPTION 'listings after % (expected 11205)', x; END IF;
  SELECT count(*) INTO x FROM slugs;             IF x <> 12304 THEN RAISE EXCEPTION 'slugs after % (expected 12304)', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;
                                                 IF x <> 11205 THEN RAISE EXCEPTION 'canonical slugs after % (expected 11205)', x; END IF;
  SELECT count(*) INTO x FROM (SELECT v.id FROM venues v LEFT JOIN slugs s ON s.venue_id = v.id AND s.is_canonical
                               GROUP BY v.id HAVING count(s.slug) <> 1) d;
                                                 IF x <> 0 THEN RAISE EXCEPTION 'venues with more or less than 1 canonical slug: %', x; END IF;
  SELECT count(*) INTO x FROM price;             IF x <> 7049 THEN RAISE EXCEPTION 'price after % (expected 7049)', x; END IF;
  SELECT count(*) INTO x FROM price WHERE source::text = 'guide_ingest';
                                                 IF x <> 10 THEN RAISE EXCEPTION 'guide_ingest price after % (expected 10)', x; END IF;
  SELECT count(*) INTO x FROM city_label_source; IF x <> 23814 THEN RAISE EXCEPTION 'city labels after % (expected 23814)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;            IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM redirects;         IF x <> 9 THEN RAISE EXCEPTION 'redirects changed: %', x; END IF;

  -- 5a. Chengdu: rule 6 read and condition 5 count
  SELECT count(*) INTO x FROM venues WHERE city_id = 'ci_354b500e3a';
  IF x <> 54 THEN RAISE EXCEPTION 'Chengdu venues after % (expected 54)', x; END IF;
  SELECT count(*) INTO x FROM slugs s JOIN venues v ON v.id = s.venue_id WHERE v.city_id = 'ci_354b500e3a';
  IF x <> 73 THEN RAISE EXCEPTION 'Chengdu slug rows after % (expected 73)', x; END IF;
  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE v.city_id = 'ci_354b500e3a' AND a.source_id = 'michelin' AND a.year = 2026 AND a.source_url IS NULL;
  IF x <> 0 THEN RAISE EXCEPTION 'Chengdu 2026 unsourced after % (expected 0)', x; END IF;
  SELECT count(*), count(DISTINCT a.source_url),
         count(*) FILTER (WHERE a.category = 'Two Stars') * 10000
       + count(*) FILTER (WHERE a.category = 'One Star') * 100
       + count(*) FILTER (WHERE a.category = 'Bib Gourmand')
    INTO x, y, n
    FROM awards a JOIN venues v ON v.id = a.venue_id
   WHERE v.city_id = 'ci_354b500e3a' AND a.source_id = 'michelin' AND a.year = 2026
     AND a.source_url ~ '^https://web\.archive\.org/web/\d{14}id_/https://guide\.michelin\.com/';
  IF x <> 40 OR y <> 40 OR n <> 21127 THEN
    RAISE EXCEPTION 'Chengdu 2026 archive rows % / distinct URLs % / category code % (expected 40 / 40 / 21127 = 2 Two Stars, 11 One Star, 27 Bib)', x, y, n;
  END IF;

  -- 5b. Ledger and audit
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 65 THEN RAISE EXCEPTION 'ledger after % (expected 65)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 7 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 49 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 49)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND action = 'DELETE' AND new_row IS NULL AND (
         (table_name = 'city_label_source' AND row_pk = ANY (SELECT unnest(clsids)::text))
      OR (table_name = 'awards'            AND row_pk = ANY (SELECT unnest(aids)::text))
      OR (table_name IN ('price','slugs','listings','venues') AND row_pk = ANY (vids)));
  IF x <> 49 THEN RAISE EXCEPTION 'audit rows that match the plan % (expected 49)', x; END IF;
  SELECT count(*) INTO x FROM audit_log
   WHERE id > aud_max AND table_name = 'city_label_source' AND old_row->>'venue_id' = ANY (vids);
  IF x <> 14 THEN RAISE EXCEPTION 'hand audit rows with the deleted city label % (expected 14)', x; END IF;
END
$do$;
COMMIT;
