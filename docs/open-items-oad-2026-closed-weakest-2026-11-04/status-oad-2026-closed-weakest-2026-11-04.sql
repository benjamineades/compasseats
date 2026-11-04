-- status-oad-2026-closed-weakest-2026-11-04.sql  CompassEats, Nov 4 2026. Item 3: closed venues OAD 2026 prints, 26 weakest (Ben 4A).
-- PENDING: Ben has not chosen. This file does not run before his go.
-- Scope: 3 of 26 venues, closed to active, listings.published false to true, city counts. 1 of the 3 renamed, with a new slug. Other 23: no change.
-- Evidence for all 26: closed-weakest-evidence-2026-11-04.csv.
--   ve_d3e2463621 Mandarin Grill + Bar: Own hotel page offers Book Table, hours and a new chef, Junior Nadje. Michelin card returns 200 with review date 2026-03-19. Forbes 2026 lists it Four-Star. Database holds La Liste 2026.
--   ve_60a5408dd6 Kawaki: Own site news dated 2026-11-02 (booking form back), 2026-09-11 and 2026-08-17 (2026 calendar). Tabelog Bronze 2026. Phone 0776-82-1313 on own site, Tabelog and OAD. Real place: Sakai (Mikuni), database city Fukui.
--   ve_644d124840 T3 to Treis: OAD 2026 No. 90 and OAD 2025 No. 119 both print Treis - τρεῖς, chef Hideaki Kawashima. Tabelog: open, Silver 2026, visits Aug 2026, same chef. T3 is another restaurant: Tabelog says Restaurant T3 (Azabudai) is permanently closed. Venue holds only these 2 rows.
-- Expected after: venues 11,594 (active 11,291, closed 303); cities sum 11,291; closed published 0; active not published 0; slugs 13,535 (canonical 11,594);
-- awards 27,481; price 7,759; redirects 33; ledger +1; rename batch +1; audit_log +12 (venues 4, listings 3, cities 3, slugs 2).
-- Old slug tokyo/t3 stays non-canonical. No redirect row. Award rows do not change. No live page changes: the live site reads the Sheet.
BEGIN;
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
  -- WRITE
  INSERT INTO rename_batches (batch_key,status,note) VALUES ('status-oad-2026-closed-weakest-2026-11-04','staged',$n$Item 3, T3 to Treis: PENDING: Ben has not chosen. This file does not run before his go.$n$) RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  INSERT INTO rename_rows (batch_id,line,venue_id,expected_name,new_name,source_id,source_url,verdict,detail)
    SELECT bid,1,v.id,v.name,'Treis','oad','https://www.oadguides.com/restaurant/treis-t-e','rename',jsonb_build_object('live_name',v.name,'city_id',v.city_id) FROM venues v WHERE v.id='ve_644d124840' AND v.name='T3 (ティースリー)';
  GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename row %',n; END IF;
  UPDATE venues SET name='Treis' WHERE id='ve_644d124840' AND name='T3 (ティースリー)'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename %',n; END IF;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id='ve_644d124840' AND city_slug='tokyo' AND slug='t3' AND is_canonical; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'old slug %',n; END IF;
  INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats','tokyo','treis','ve_644d124840',true);
  UPDATE rename_batches SET status='applied',applied_at=now() WHERE id=bid AND status='staged'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'batch %',n; END IF;
  UPDATE venues SET status='active' WHERE id=ANY(va) AND status='closed'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>3 THEN RAISE EXCEPTION 'status %',n; END IF;
  UPDATE listings SET published=true WHERE venue_id=ANY(va) AND NOT published; GET DIAGNOSTICS n=ROW_COUNT; IF n<>3 THEN RAISE EXCEPTION 'published %',n; END IF;
  UPDATE cities SET venues_count=282 WHERE id='ci_1b1537ad28' AND venues_count=281; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'city hk %',n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_286da19d94' AND venues_count=1; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'city fukui %',n; END IF;
  UPDATE cities SET venues_count=675 WHERE id='ci_ef0cc10ff4' AND venues_count=674; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'city tokyo %',n; END IF;
  INSERT INTO source_capture_ledger (publisher,field_type,items,job) VALUES ('oad','name',1,$j$rename-apply:status-oad-2026-closed-weakest-2026-11-04 | OAD name Treis for ve_644d124840, read Nov 4 | PENDING: Ben has not chosen. This file does not run before his go.$j$);
  -- POST
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11291 OR (SELECT count(*) FROM venues WHERE status='closed')<>303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities)<>11291 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0))<>0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published)<>0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM slugs)<>13535 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs s ON s.venue_id=v.id AND s.is_canonical GROUP BY v.id HAVING count(s.slug)<>1) THEN RAISE EXCEPTION 'canonical slugs'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id>aud)<>12 THEN RAISE EXCEPTION 'audit total %',(SELECT count(*) FROM audit_log WHERE id>aud); END IF;
  IF (SELECT count(*) FROM audit_log WHERE id>aud AND table_name='venues')<>4 OR (SELECT count(*) FROM audit_log WHERE id>aud AND table_name='listings')<>3 OR (SELECT count(*) FROM audit_log WHERE id>aud AND table_name='cities')<>3 OR (SELECT count(*) FROM audit_log WHERE id>aud AND table_name='slugs')<>2 THEN RAISE EXCEPTION 'audit tables'; END IF;
  RAISE NOTICE 'done: batch %',bid;
END $do$;
COMMIT;
