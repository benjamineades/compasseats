DO $do$
DECLARE
  n bigint; aud bigint; s text;
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11291 OR (SELECT count(*) FROM venues WHERE status='closed')<>303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities)<>11291 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0))<>0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published)<>0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM slugs)<>13535 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 OR (SELECT count(*) FROM city_aliases)<>222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2026)<>2859 OR (SELECT count(*) FROM awards WHERE source_id='oad' AND year=2025)<>2437 THEN RAISE EXCEPTION 'oad before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger)<>295 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*),max(id) INTO n,aud FROM audit_log; IF n<>124800 OR aud<>130629 THEN RAISE EXCEPTION 'audit before % / %',n,aud; END IF;
  SELECT v.id||'|'||v.name||'|'||v.status||'|'||v.city_id INTO s FROM venues v WHERE v.id='ve_5126fcd962';
  IF s IS DISTINCT FROM $v$ve_5126fcd962|Howard's Gourmet|active|ci_1b1537ad28$v$ THEN RAISE EXCEPTION 'venue %',s; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_1b1537ad28')<>282 THEN RAISE EXCEPTION 'hk count'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='ve_5126fcd962' AND published AND property_id='eats')<>1 THEN RAISE EXCEPTION 'listing before'; END IF;
  -- WRITE
  UPDATE venues SET status='closed' WHERE id='ve_5126fcd962' AND status='active'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'status %',n; END IF;
  UPDATE listings SET published=false WHERE venue_id='ve_5126fcd962' AND published; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'published %',n; END IF;
  UPDATE cities SET venues_count=281 WHERE id='ci_1b1537ad28' AND venues_count=282; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'city hk %',n; END IF;
  -- POST
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11290 OR (SELECT count(*) FROM venues WHERE status='closed')<>304 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities)<>11290 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0))<>0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published)<>0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM slugs)<>13535 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger)<>295 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id>aud)<>3 THEN RAISE EXCEPTION 'audit total %',(SELECT count(*) FROM audit_log WHERE id>aud); END IF;
  RAISE NOTICE 'done';
END $do$;
