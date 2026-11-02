import hashlib
F='merge-fr-plaza-athenee-2026-11-02.sql'
O,S='ve_36022e9b0a','ve_ab17ada0da'
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 12:24 ET "A". This file runs only after his "go".
-- Merge Jean Imbert au Plaza Athénée {O} into La Grande Table du Plaza Athénée {S}: one restaurant, new name.
-- Evidence read Nov 2: Yonder Sep 15 2026 (named after Jean Imbert, now La Grande Table du Plaza Athénée; kitchen and dining room teams unchanged; Jocelyn Herland leads);
--   Michelin card la-grande-du-plaza-athenee live, 25 avenue Montaigne, One Star; card jean-imbert-au-plaza-athenee 404.
-- Moves awards 7233 (Michelin 2025 One Star) and 7234 (Gault-Millau 2023 Four Toques). Old slug stays as a non-canonical row on the survivor.
-- Deletes the legacy price ($$$$, no URL; Sep 28 ruling), 2 city labels, the old listing and the old venue. Alain Ducasse au Plaza Athénée ve_5b69a13297 does not change.
-- Expected after: venues 11,295 (active 10,916, closed 379); awards 25,096; slugs 13,016 (canonical 11,295, non-canonical 1,721); price 7,728; listings 11,295;
--   city labels 23,991; Paris 214 to 213; cities sum 10,916; closed published 358; ledger 180 rows;
--   audit_log +9 (city_label_source DELETE 2 by hand, awards UPDATE 2, price DELETE 1, slugs UPDATE 1, listings DELETE 1, venues DELETE 1, cities UPDATE 1).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text;
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10917 OR (SELECT count(*) FROM venues WHERE status='closed') <> 379 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25096 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13016 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11296 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM price) <> 7729 OR (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM city_label_source) <> 23993 THEN RAISE EXCEPTION 'child tables before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10917 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 358 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 179 OR led_max <> 231 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118226 OR aud_max <> 123740 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN ('{O}','{S}');
  IF s IS DISTINCT FROM '0e940b68a72bd5ef9608db25a0bb992e' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id='{O}') <> 2 OR (SELECT count(*) FROM awards WHERE id IN (7233,7234) AND venue_id='{O}') <> 2 THEN RAISE EXCEPTION 'old awards'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id='{S}' AND (source_id,year) IN (('michelin',2025),('gault-millau',2023))) THEN RAISE EXCEPTION 'award clash'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id='{O}') OR EXISTS (SELECT 1 FROM geo WHERE venue_id='{O}') OR EXISTS (SELECT 1 FROM addresses WHERE venue_id='{O}') OR EXISTS (SELECT 1 FROM hours WHERE venue_id='{O}') OR EXISTS (SELECT 1 FROM photo_refs WHERE venue_id='{O}') OR EXISTS (SELECT 1 FROM rename_rows WHERE venue_id='{O}') THEN RAISE EXCEPTION 'unexpected child row'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ILIKE '%jean-imbert%' OR to_path ILIKE '%jean-imbert%') THEN RAISE EXCEPTION 'redirect'; END IF;
  -- 1. City labels: hand audit rows, then delete
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', l.id::text, 'DELETE', to_jsonb(l), NULL FROM city_label_source l WHERE l.venue_id='{O}' AND l.id IN (5212,5213);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'label audit %', n; END IF;
  DELETE FROM city_label_source WHERE venue_id='{O}';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- 2. Awards move
  UPDATE awards SET venue_id='{S}' WHERE id IN (7233,7234) AND venue_id='{O}';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- 3. Legacy price
  DELETE FROM price WHERE venue_id='{O}' AND source='legacy_guide' AND symbol_raw='$$$$' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price %', n; END IF;
  -- 4. Old slug stays, non-canonical, on the survivor
  UPDATE slugs SET venue_id='{S}', is_canonical=false WHERE venue_id='{O}' AND city_slug='paris' AND slug='jean-imbert-au-plaza-athenee' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug %', n; END IF;
  -- 5. Listing and venue
  DELETE FROM listings WHERE venue_id='{O}';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listing %', n; END IF;
  DELETE FROM venues WHERE id='{O}';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venue %', n; END IF;
  -- 6. Paris count
  UPDATE cities SET venues_count=213 WHERE id='ci_ccbee73cd8' AND venues_count=214;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city %', n; END IF;
  -- 7. Ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 2, 'cleanup:merge-fr-plaza-athenee | Ben Nov 2 12:24 ET "A" | {O} merged into {S}, awards 7233 and 7234 moved, old slug kept non-canonical, legacy price deleted');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11295 OR (SELECT count(*) FROM venues WHERE status='active') <> 10916 OR (SELECT count(*) FROM venues WHERE status='closed') <> 379 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25096 OR (SELECT count(*) FROM awards WHERE venue_id='{S}') <> 3 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13016 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11295 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1721 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id='{S}' AND is_canonical) <> 1 THEN RAISE EXCEPTION 'survivor canonical'; END IF;
  IF (SELECT count(*) FROM price) <> 7728 OR (SELECT count(*) FROM listings) <> 11295 OR (SELECT count(*) FROM city_label_source) <> 23991 THEN RAISE EXCEPTION 'child tables after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10916 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 358 THEN RAISE EXCEPTION 'closed published after'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 180 OR led_max <> 232 THEN RAISE EXCEPTION 'ledger after % / %', n, led_max; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE=2,cities:UPDATE=1,city_label_source:DELETE=2,listings:DELETE=1,price:DELETE=1,slugs:UPDATE=1,venues:DELETE=1' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()))
