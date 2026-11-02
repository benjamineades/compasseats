import hashlib
F='fix-status-closed-3-nideggen-hjem-taku-2026-11-02.sql'
arr="ARRAY['ve_3fede02a60','ve_4789a4e337','ve_c905b58267']"
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 12:18 ET "1A, 2A". This file runs only after his "go".
-- 3 venues to closed, status only. No ledger row (D1 precedent).
--   ve_3fede02a60 Burgrestaurant Nideggen: Falstaff Aug 6 2026, "dauerhaft geschlossen"; card 404.
--   ve_c905b58267 Restaurant Hjem: Harden's Jul 10 2026, Wall site shut end of 2025, residency ends Aug 16, founders leave the industry.
--   ve_4789a4e337 Taku: Hot Dinners Feb 20 2026, relaunched as Sushi Amamoto, same site and team, Taku listing removed. Rule: Michelin-closed venue; new business is not the award holder.
-- Award rows stay as history. listings.published does not change (F1). Names, slugs and awards do not change.
-- Nideggen and Wall fall to 0 active venues; London 248 to 247.
-- Expected after: venues 11,296 (active 10,917, closed 379); cities.venues_count sum 10,917; closed venues published 358; audit_log +6 (venues UPDATE 3, cities UPDATE 3).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text;
  vc constant text[] := {arr};
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10920 OR (SELECT count(*) FROM venues WHERE status='closed') <> 376 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10920 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 355 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25096 THEN RAISE EXCEPTION 'awards before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118220 OR aud_max <> 123734 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (vc);
  IF s IS DISTINCT FROM 'd4c6afa6b52f218a95353bc3bb8ccdd9' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  -- WRITE
  UPDATE venues SET status='closed' WHERE id = ANY (vc) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 3 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE cities SET venues_count=0 WHERE id='ci_4a768bbdd7' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city nideggen %', n; END IF;
  UPDATE cities SET venues_count=0 WHERE id='ci_2d86bdac01' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city wall %', n; END IF;
  UPDATE cities SET venues_count=247 WHERE id='ci_bc180dbc58' AND venues_count=248;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city london %', n; END IF;
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10917 OR (SELECT count(*) FROM venues WHERE status='closed') <> 379 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10917 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 358 THEN RAISE EXCEPTION 'closed published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=3,venues:UPDATE=3' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (vc) AND (old_row-'status')=(new_row-'status') AND new_row->>'status'='closed') <> 3 THEN RAISE EXCEPTION 'audit status rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()))
