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
  RAISE EXCEPTION 'dry stop';
END
$load$;
