import sys
# Candidate file for the dry run. Rebuilt after Ben's choices and a fresh read.
BEN=sys.argv[1] if len(sys.argv)>1 else 'PENDING: Ben has not chosen. This file does not run before his go.'
NAME='status-oad-2026-closed-other-54-2026-11-04'
HK='ve_5126fcd962'; HKC='ci_1b1537ad28'
HEAD=f"""-- {NAME}.sql  CompassEats, Nov 4 2026. Open item 1: closed venues OAD 2026 prints, other 54 of 80.
-- {BEN}
-- Scope: 0 of the 54 change. 1 side finding, outside the 54: Howard's Gourmet Hong Kong {HK}, active to closed, listings.published true to false, Hong Kong count 282 to 281.
-- Evidence: oad-2026-closed-other-54-evidence-2026-11-04.csv and the Dimsum Daily article of Jun 27 2026.
-- Expected after: venues 11,594 (active 11,290, closed 304); cities sum 11,290; closed published 0; active not published 0; slugs 13,535; awards 27,481; price 7,759; redirects 33.
-- No ledger row (status only, as the Oct 10 Texas write). audit_log +3 (venues 1, listings 1, cities 1). Award rows do not change.
"""
DECL=f"""DO $do$
DECLARE
  n bigint; aud bigint; s text;
BEGIN"""
GATES=f"""
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
  SELECT v.id||'|'||v.name||'|'||v.status||'|'||v.city_id INTO s FROM venues v WHERE v.id='{HK}';
  IF s IS DISTINCT FROM $v$ve_5126fcd962|Howard's Gourmet|active|ci_1b1537ad28$v$ THEN RAISE EXCEPTION 'venue %',s; END IF;
  IF (SELECT venues_count FROM cities WHERE id='{HKC}')<>282 THEN RAISE EXCEPTION 'hk count'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id='{HK}' AND published AND property_id='eats')<>1 THEN RAISE EXCEPTION 'listing before'; END IF;"""
WRITE=f"""
  -- WRITE
  UPDATE venues SET status='closed' WHERE id='{HK}' AND status='active'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'status %',n; END IF;
  UPDATE listings SET published=false WHERE venue_id='{HK}' AND published; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'published %',n; END IF;
  UPDATE cities SET venues_count=281 WHERE id='{HKC}' AND venues_count=282; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'city hk %',n; END IF;"""
POST=f"""
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
"""
open(NAME+'.sql','w',encoding='utf-8').write(HEAD+'BEGIN;\n'+DECL+GATES+WRITE+POST+'COMMIT;\n')
open('dry.sql','w',encoding='utf-8').write(DECL+GATES+WRITE+POST)
