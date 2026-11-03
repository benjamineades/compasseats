-- rewrite-blurb-cheval-blanc-v2.sql
-- CompassEats, Nov 3 2026. Swiss open item 3. Blurb of Cheval Blanc by Peter Knogl ve_46e15d96d7: version 2, status rewritten, 3 source URLs (Forum precedent).
-- Run after source-url-michelin-2025-switzerland-cards.sql. Database only: Sheet, ImportOptionB.gs and venues.chef do not change. No ledger row (Forum precedent).
-- Expected after: blurbs 142 (rewritten 2, needs_rewrite 140); audit +1 (120026 rows, last id 125855).
BEGIN;
DO $do$
DECLARE s text; x bigint; n int;
BEGIN
  IF (SELECT count(*) FROM audit_log) <> 120025 OR (SELECT max(id) FROM audit_log) <> 125854 THEN RAISE EXCEPTION 'audit before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 249 THEN RAISE EXCEPTION 'ledger before'; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM blurbs WHERE status='rewritten') <> 1 THEN RAISE EXCEPTION 'blurbs before'; END IF;
  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||coalesce(sources::text,'NULL')) INTO s FROM blurbs WHERE venue_id='ve_46e15d96d7';
  IF s IS DISTINCT FROM '378f706f785ca52a94de31fd95536a47' THEN RAISE EXCEPTION 'old row md5 %', s; END IF;

  UPDATE blurbs SET short='3 Michelin stars, a Rhine view and a spoon just for the sauce. Chef Peter Knogl cooks French classics here, inside Basel''s 300-year-old Grand Hotel Les Trois Rois.',
    long='Switzerland''s tourism board calls Chef Peter Knogl the "sauce king," and the table backs it up: you get a sauce spoon, and you use it to finish every drop. His cooking starts from French classics and brings in Asian and Mediterranean flavors. He''s known for red mullet with crisped scales, in a saffron sauce with tomato vinaigrette and black garlic. His fish comes only from France. Cheval Blanc holds 3 Michelin stars and sits inside the Grand Hotel Les Trois Rois, a hotel more than 300 years old, with round tables and a view of the Rhine. A small window lets you watch the kitchen, and the team works very quietly. Ask for a table with the view.',
    version=2, status='rewritten', sources='["https://guide.michelin.com/us/en/basel-stadt/basel/restaurant/cheval-blanc-by-peter-knogl", "https://www.myswitzerland.com/en-ca/experiences/food-wine/restaurant/cheval-blanc-by-peter-knogl/", "https://www.swissdeluxehotels.com/stories/gourmet/spoons-full-of-happyness/"]'::jsonb
   WHERE venue_id='ve_46e15d96d7';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'updated %', n; END IF;

  SELECT md5(short||'|'||long||'|'||method||'|'||version||'|'||status||'|'||sources::text) INTO s FROM blurbs WHERE venue_id='ve_46e15d96d7';
  IF s IS DISTINCT FROM '426de6cac631b6bf757c481b46f48033' THEN RAISE EXCEPTION 'new row md5 %', s; END IF;
  IF (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM blurbs WHERE status='rewritten') <> 2 THEN RAISE EXCEPTION 'blurbs after'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>125854 AND table_name='blurbs' AND action='UPDATE' AND row_pk='ve_46e15d96d7'; IF x <> 1 THEN RAISE EXCEPTION 'audit %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>125854; IF x <> 1 THEN RAISE EXCEPTION 'audit total %', x; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
