DO $do$
DECLARE
  n bigint; aud bigint; s text; bid bigint;
  va constant text[] := ARRAY['ve_60a5408dd6','ve_644d124840','ve_d3e2463621'];
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11288 OR (SELECT count(*) FROM venues WHERE status='closed')<>306 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities)<>11288 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0))<>0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published)<>0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM slugs)<>13534 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 OR (SELECT count(*) FROM city_aliases)<>222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026)<>2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025)<>2437 THEN RAISE EXCEPTION 'oad before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger)<>294 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*),max(id) INTO n,aud FROM audit_log; IF n<>124788 OR aud<>130617 THEN RAISE EXCEPTION 'audit before % / %',n,aud; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id,E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id=ANY(va);
  IF s IS DISTINCT FROM 'be333f5113a15e0ae30ce87dbebadadb' THEN RAISE EXCEPTION 'venue fingerprint %',s; END IF;
  SELECT md5(string_agg(c.id||'|'||c.venues_count,E'\n' ORDER BY c.id COLLATE "C")) INTO s FROM cities c WHERE c.id IN ('ci_1b1537ad28','ci_286da19d94','ci_ef0cc10ff4');
  IF s IS DISTINCT FROM 'cb0aa377e789e520f409e5b6595df6e6' THEN RAISE EXCEPTION 'city fingerprint %',s; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.rank,E'\n' ORDER BY a.id)) INTO s FROM awards a WHERE a.venue_id='ve_644d124840';
  IF s IS DISTINCT FROM '6c0773faf5fb6caefd70fe899feb4019' THEN RAISE EXCEPTION 'T3 awards fingerprint %',s; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id=ANY(va) AND NOT published AND property_id='eats')<>3 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id='ve_644d124840')<>1 OR (SELECT count(*) FROM slugs WHERE property_id='eats' AND city_slug='tokyo' AND slug='t3' AND venue_id='ve_644d124840' AND is_canonical)<>1 THEN RAISE EXCEPTION 'T3 slug before'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='tokyo' AND slug='treis') OR EXISTS (SELECT 1 FROM redirects WHERE from_path='/tokyo/treis') THEN RAISE EXCEPTION 'treis slug taken'; END IF;
  IF EXISTS (SELECT 1 FROM venues WHERE id<>'ve_644d124840' AND city_id='ci_ef0cc10ff4' AND lower(name) ~ 'treis|τρε|トレイス') THEN RAISE EXCEPTION 'treis twin'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='status-oad-2026-closed-weakest-2026-11-04') THEN RAISE EXCEPTION 'batch key used'; END IF;
  RAISE EXCEPTION 'dry stop: gates passed, audit %, batch key free',aud;
END $do$;
