-- cleanup-oad-2026-holds-item1-2026-11-04.sql
-- CompassEats, Nov 4 2026. Open item 1 of handoff-oad-2026-holds-status-done. PENDING: Ben has not chosen. This file runs only after his "go".
-- 2 new OAD 2026 rows: Japan 469 on Kusunoki ve_a1fee2bf94 (second row), Japan 755 on new venue Sushi Takumi ve_60b541e3e7 (Tokyo, active). No price, address, geo or blurb.
-- Expected after: venues 11,594 (active 11,288, closed 306); awards 27,481; OAD 2026 2,859; OAD 2025 2,437; slugs 13,444; listings 11,594; labels 24,595; price 7,759; redirects 33; aliases 222; cities 3,318, sum 11,288; ledger 239 rows; audit_log +8.
BEGIN;
DO $load$
DECLARE
  n bigint; s text; aud_max bigint;
BEGIN
  IF (SELECT count(*) FROM venues) <> 11593 OR (SELECT count(*) FROM venues WHERE status='active') <> 11287 OR (SELECT count(*) FROM venues WHERE status='closed') <> 306 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27479 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2857 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13443 OR (SELECT count(*) FROM listings) <> 11593 OR (SELECT count(*) FROM city_label_source) <> 24593 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 33 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11287 OR (SELECT count(*) FROM source_capture_ledger) <> 237 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 124343 OR aud_max <> 130172 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  IF (SELECT count(*) FROM venues WHERE id='ve_a1fee2bf94' AND name='Kusunoki' AND status='active' AND city_id='ci_ef0cc10ff4') <> 1 THEN RAISE EXCEPTION 'Kusunoki as read'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='tokyo' AND slug='sushi-takumi') OR EXISTS (SELECT 1 FROM venues WHERE id='ve_60b541e3e7') OR EXISTS (SELECT 1 FROM venues WHERE city_id='ci_ef0cc10ff4' AND norm_key=norm_key('Sushi Takumi')) THEN RAISE EXCEPTION 'new venue clash'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_id='oad' AND year=2026 AND source_url='https://www.oadguides.com/lists/japan/top-restaurants/2026' AND rank IN (469,755)) THEN RAISE EXCEPTION 'rank taken'; END IF;
  INSERT INTO venues (id, name, category, city_id, status) VALUES ('ve_60b541e3e7', 'Sushi Takumi', 'restaurant'::venue_category, 'ci_ef0cc10ff4', 'active'::venue_status);
  INSERT INTO listings (venue_id, property_id, published) VALUES ('ve_60b541e3e7', 'eats', true);
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'tokyo', 'sushi-takumi', 've_60b541e3e7', true);
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES ('ve_60b541e3e7', 'Tokyo', 'city_display'::label_column_t, 'oad', 'OAD 2026 holds item 1, Nov 4'), ('ve_60b541e3e7', 'Japan', 'country'::label_column_t, 'oad', 'OAD 2026 holds item 1, Nov 4') RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
    ('ve_a1fee2bf94', 'oad', 2026, 469, 'No. 469', NULL, 'https://www.oadguides.com/lists/japan/top-restaurants/2026'),
    ('ve_60b541e3e7', 'oad', 2026, 755, 'No. 755', NULL, 'https://www.oadguides.com/lists/japan/top-restaurants/2026');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards %', n; END IF;
  UPDATE cities c SET venues_count=coalesce(k.active_venues,0) FROM cities d LEFT JOIN city_venue_counts k ON k.city_id=d.id WHERE d.id=c.id AND c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('oad', 'award', 2, 'cleanup:cleanup-oad-2026-holds-item1-2026-11-04 | OAD 2026 hold rows, japan 469 and 755 | https://www.oadguides.com/lists/japan/top-restaurants/2026 | PENDING: Ben has not chosen'),
    ('oad', 'city_label', 2, 'cleanup:cleanup-oad-2026-holds-item1-2026-11-04 | city labels of Sushi Takumi | PENDING: Ben has not chosen');
  IF (SELECT count(*) FROM venues) <> 11594 OR (SELECT count(*) FROM venues WHERE status='active') <> 11288 OR (SELECT count(*) FROM venues WHERE status='closed') <> 306 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 27481 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026) <> 2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025) <> 2437 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13444 OR (SELECT count(*) FROM listings) <> 11594 OR (SELECT count(*) FROM city_label_source) <> 24595 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 33 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3318 OR (SELECT sum(venues_count) FROM cities) <> 11288 OR (SELECT count(*) FROM source_capture_ledger) <> 239 THEN RAISE EXCEPTION 'cities, ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=2,cities:UPDATE=1,city_label_source:INSERT=2,listings:INSERT=1,slugs:INSERT=1,venues:INSERT=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
