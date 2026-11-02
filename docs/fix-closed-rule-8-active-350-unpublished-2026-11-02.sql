-- fix-closed-rule-8-active-350-unpublished-2026-11-02.sql
-- CompassEats, Nov 2 2026. Open item 10. Ben: 13:11 ET "1A ... 7A", 13:26 ET "1A, 2A, 3A, 4A". This file runs only after his "go".
-- Rule (Aug 24 ruling, applied now): a closed venue has listings.published = false. An iconic venue stays true by Ben's call per venue. The iconic list is empty today.
-- Temporary closure: closed and false; the reopening file sets status active and published true. Seasonal closure: active (Ben, Nov 2).
--
-- Part 1. 8 venues, status closed to active. All 8 came in closed at the Aug 14 load, and all 8 hold a Michelin 2026 row.
--   ve_47d4b5d515 Atelier (Auckland): Michelin 2026 card lists hours, no closure note.
--   ve_6c7a46653b Muttonbird (Wanaka): Michelin 2026 card lists hours, no closure note.
--   ve_540fbdb0db Ed.Em (Chassagne-Montrachet): own site restaurant-edem.com lists weekly hours and booking.
--   ve_9fd9ef0dbb L'Impertinent (Biarritz): own site l-impertinent.fr lists weekly hours and booking.
--   ve_e998bbe81d Le Saint-James (Bouliac): Bouger a Bordeaux Nov 27 2025, reopening May 14 2026; Relais & Chateaux lists hours and 2027 closing dates.
--   ve_e643c85d2a Alpage (Courchevel): seasonal; courchevel.com lists Dec 11 2026 to Apr 10 2027.
--   ve_a0adf5e745 Le Cin5 (La Clusaz): seasonal; Arts & Gastronomie Dec 27 2025, reopened Dec 12; hotel site has a booking link and no closure note.
--   ve_ec527ff975 Ostaria Tyrol (Moena): seasonal; fassa.com lists next opening Dec 5 2026.
--
-- Part 2. 350 closed venues, listings.published true to false. The 21 already false do not change.
--   Known limit: the at-load closures have no stored evidence. A sample of 16 from 304 confirmed 8 closures only.
--   Some of the 350 can be open. They stay hidden, the same as the live site today, until the sweep. Each venue found open then gets status active and published true in one file.
--   Stay closed, recheck: Divellec, Auberge Pyrenees Cevennes, Udtryk (Dec 1), Adana (conflict). Stay closed: Maison Decoret (fire, no date).
--
-- Award rows, names, slugs and price do not change. No ledger row (status precedent, D1). No site page changes today: no site code reads listings.published.
-- City counts: Auckland 19 to 20, Chassagne-Montrachet 0 to 1, Wanaka 5 to 6, Biarritz 4 to 5, La Clusaz 0 to 1, Courchevel 6 to 7, Bouliac 0 to 1, Moena 3 to 4.
-- Expected after: venues 11,296 (active 10,925, closed 371); cities.venues_count sum 10,925; closed published 0, closed not published 371; audit_log +366 (cities UPDATE 8, listings UPDATE 350, venues UPDATE 8).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text;
  va constant text[] := ARRAY['ve_47d4b5d515','ve_540fbdb0db','ve_6c7a46653b','ve_9fd9ef0dbb','ve_a0adf5e745','ve_e643c85d2a','ve_e998bbe81d','ve_ec527ff975'];
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10917 OR (SELECT count(*) FROM venues WHERE status='closed') <> 379 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10917 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 358 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND NOT l.published) <> 21 THEN RAISE EXCEPTION 'closed not published before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM listings WHERE property_id <> 'eats') <> 0 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13017 OR (SELECT count(*) FROM price) <> 7728 THEN RAISE EXCEPTION 'awards slugs price before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 234 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118242 OR aud_max <> 123756 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (va);
  IF s IS DISTINCT FROM '4be3748f7f09a66537f6476650682fde' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(v.id, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v JOIN listings l ON l.venue_id=v.id WHERE v.status='closed' AND l.published AND NOT v.id = ANY (va);
  IF s IS DISTINCT FROM '0e87a4d1938674120c2bbda1172722f1' THEN RAISE EXCEPTION 'flip list fingerprint %', s; END IF;
  -- WRITE, part 1
  UPDATE venues SET status='active' WHERE id = ANY (va) AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 8 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE cities SET venues_count=20 WHERE id='ci_4665921775' AND venues_count=19;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city auckland %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_8324009b5a' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city chassagne %', n; END IF;
  UPDATE cities SET venues_count=6 WHERE id='ci_daf6d172be' AND venues_count=5;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city wanaka %', n; END IF;
  UPDATE cities SET venues_count=5 WHERE id='ci_156a5a30ee' AND venues_count=4;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city biarritz %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_427a26b183' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city la clusaz %', n; END IF;
  UPDATE cities SET venues_count=7 WHERE id='ci_8a64416c66' AND venues_count=6;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city courchevel %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_554cc5e836' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city bouliac %', n; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_85dcf5b5a9' AND venues_count=3;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city moena %', n; END IF;
  -- WRITE, part 2
  UPDATE listings l SET published=false FROM venues v WHERE v.id=l.venue_id AND v.status='closed' AND l.published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 350 THEN RAISE EXCEPTION 'published %', n; END IF;
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10925 OR (SELECT count(*) FROM venues WHERE status='closed') <> 371 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10925 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND NOT l.published) <> 371 THEN RAISE EXCEPTION 'closed not published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13017 OR (SELECT count(*) FROM price) <> 7728 THEN RAISE EXCEPTION 'awards slugs price after'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 234 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=8,listings:UPDATE=350,venues:UPDATE=8' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (va) AND (old_row-'status')=(new_row-'status') AND old_row->>'status'='closed' AND new_row->>'status'='active') <> 8 THEN RAISE EXCEPTION 'audit status rows'; END IF;
  SELECT md5(string_agg(row_pk, E'\n' ORDER BY row_pk COLLATE "C")) INTO s FROM audit_log WHERE id > aud_max AND table_name='listings' AND (old_row-'published')=(new_row-'published') AND old_row->>'published'='true' AND new_row->>'published'='false';
  IF s IS DISTINCT FROM '0e87a4d1938674120c2bbda1172722f1' THEN RAISE EXCEPTION 'audit flip rows %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
