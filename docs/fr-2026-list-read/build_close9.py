import hashlib
F='fix-status-fr-closed-9-2026-11-02.sql'
V=['ve_492797f355','ve_1fa87032fe','ve_95253d6c9e','ve_63aed2ba90','ve_ef978b8a59','ve_3bb332e0ec','ve_54915423d1','ve_b2c6b30c6e','ve_e1bffb1188']
C=[('ci_3a4a6b99ab',20,1),('ci_80cf57d284',1,1),('ci_8a64416c66',7,1),('ci_e23d77adcb',2,1),('ci_3840268f34',3,1),('ci_ccbee73cd8',217,3),('ci_aebee95dfb',1,1)]
arr="ARRAY["+",".join(f"'{v}'" for v in V)+"]"
ups="\n".join(f"  UPDATE cities SET venues_count={n-d} WHERE id='{c}' AND venues_count={n};\n  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city {c} %', n; END IF;" for c,n,d in C)
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 11:12 ET "S1". This file runs only after his "go".
-- 9 French venues to closed, status only. All 9 cards give a 404 (read Nov 2). Press or own site, read Nov 2:
--   ve_492797f355 L'Observatoire du Gabriel, Le Bonbon Jun 4 2026 "Fermé définitivement"
--   ve_95253d6c9e Le Sarkara, Bouillantes Aug 24 2026 "Fermeture définitive"
--   ve_b2c6b30c6e La Scene Theleme, Bouillantes Aug 25 2026, will not reopen after the summer break, lost the lease
--   ve_54915423d1 Maison Dubois, Bouillantes Sep 1 2026 "ferme définitivement"
--   ve_3bb332e0ec Restaurant Pages, Bouillantes Aug 31 2026, will not reopen in Paris
--   ve_ef978b8a59 Jean-Luc Tartarin, Bouillantes Apr 4 2026, closes for good May 16
--   ve_63aed2ba90 Les Voiles d'Or, press Oct 11 2026, Le Vané took the site, opened Oct 17
--   ve_1fa87032fe Ivan Vautier, Tendance Ouest Jul 21 2026, last starred meal Aug 22
--   ve_e1bffb1188 La Flibuste, own site "a fermé ses portes", passes to restaurant SAM
-- Held active with a recheck: Galanga ve_72f235f057, La Table de l'Alpaga ve_68ad93cad4 (card 404, no closure found).
-- listings.published does not change (F1). Names, slugs and awards do not change. No ledger row (D1 precedent).
-- Expected after: venues 11,296 (active 10,921, closed 375); cities.venues_count sum 10,921; closed venues published 354; audit_log +16 (venues UPDATE 9, cities UPDATE 7).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text;
  vc constant text[] := {arr};
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10930 OR (SELECT count(*) FROM venues WHERE status='closed') <> 366 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10930 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 345 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118198 OR aud_max <> 123712 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (vc);
  IF s IS DISTINCT FROM '9d7029db66268fd67ff42f595c3c795f' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  -- WRITE
  UPDATE venues SET status='closed' WHERE id = ANY (vc) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 9 THEN RAISE EXCEPTION 'status %', n; END IF;
{ups}
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10921 OR (SELECT count(*) FROM venues WHERE status='closed') <> 375 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10921 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 354 THEN RAISE EXCEPTION 'closed published after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=7,venues:UPDATE=9' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (vc) AND (old_row-'status')=(new_row-'status') AND new_row->>'status'='closed') <> 9 THEN RAISE EXCEPTION 'status audit'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()))
