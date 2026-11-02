import hashlib
F='fix-es-2026-list-4-rows-simpar-closed-2026-11-02.sql'
U='https://guide.michelin.com/es/es/articulo/michelin-guide-ceremony/todos-los-restaurantes-con-estrellas-michelin-en-espana-2026'
V=['ve_dffad438e0','ve_a76b44705a','ve_5cb5124e0b','ve_6532e88951']
arr="ARRAY["+",".join("'%s'"%v for v in V)+"]"
vals=",".join("('%s')"%v for v in V)
sql=f'''-- {F}
-- CompassEats, Nov 2 2026. Ben: Nov 2 12:10 ET "1A, 2A, 3A". This file runs only after his "go".
-- 1A: 4 Michelin 2026 One Star rows for venues on the Spain 2026 list (article Nov 25, 2025) with no 2026 row. Source: the list article
--   (relay docs/list-compare-2026-11-02/relay-star-list-articles-2026-11-02.txt). The 4 are not on the live Spain One Star list (read Nov 2). France method (ledger 229).
--   ve_dffad438e0 Ricardo Sanz Wellington; ve_a76b44705a Santerra Restaurante; ve_5cb5124e0b Restaurante Simpar; ve_6532e88951 Teatro kitchen & bar.
-- 2A: held, no venue: SCAPAR (Barcelona), Erre de Roca (Miranda de Ebro), Bens d'Avall (Soller), NM (Oviedo).
-- 3A: Restaurante Simpar ve_5cb5124e0b to closed, status only. Evidence read Nov 2: own site restaurantesimpar.com "Simpar ha cerrado sus puertas", effective July 19;
--   El Correo Gallego (URL date 2026/06/20), owners announce a final closure on July 19.
-- listings.published does not change (F1). Names and slugs do not change.
-- Expected after: awards 25,096; Michelin 11,392; Spain + Andorra Michelin 2026 star rows 303; venues 11,296 (active 10,920, closed 376);
--   cities.venues_count sum 10,920 (Santiago de Compostela 11 to 10); closed venues published 355; ledger 179 rows; audit_log +6 (awards INSERT 4, venues UPDATE 1, cities UPDATE 1).
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; n bigint; s text;
  vaw constant text[] := {arr};
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10921 OR (SELECT count(*) FROM venues WHERE status='closed') <> 375 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25092 OR (SELECT count(*) FROM awards WHERE source_id='michelin') <> 11388 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('One Star','Two Stars','Three Stars') AND c.country_iso IN ('ES','AD')) <> 299 THEN RAISE EXCEPTION 'Spain rows before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10921 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 354 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 178 OR led_max <> 230 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118214 OR aud_max <> 123728 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key, E'\\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (vaw);
  IF s IS DISTINCT FROM '0f452ad90c2e7c0330dbd53ad2945187' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_id='michelin' AND year=2026 AND venue_id = ANY (vaw)) THEN RAISE EXCEPTION '2026 row exists'; END IF;
  -- WRITE 1: 4 award rows
  INSERT INTO awards (venue_id, source_id, year, category, source_url)
  SELECT t.vid, 'michelin', 2026, 'One Star', '{U}' FROM (VALUES {vals}) t(vid);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 4 THEN RAISE EXCEPTION 'award insert %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 4, 'backfill:michelin-2026-spain-list-4 | Ben Nov 2 12:10 ET "1A" | source: list article, venues with no 2026 row, not on the live list | relay docs/list-compare-2026-11-02/relay-star-list-articles-2026-11-02.txt');
  -- WRITE 2: Simpar closed, status only
  UPDATE venues SET status='closed' WHERE id='ve_5cb5124e0b' AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE cities SET venues_count=10 WHERE id='ci_f070e9055c' AND venues_count=11;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city %', n; END IF;
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10920 OR (SELECT count(*) FROM venues WHERE status='closed') <> 376 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25096 OR (SELECT count(*) FROM awards WHERE source_id='michelin') <> 11392 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year=2026 AND a.category IN ('One Star','Two Stars','Three Stars') AND c.country_iso IN ('ES','AD')) <> 303 THEN RAISE EXCEPTION 'Spain rows after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10920 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 355 THEN RAISE EXCEPTION 'closed published after'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 179 OR led_max <> 231 THEN RAISE EXCEPTION 'ledger after % / %', n, led_max; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=4,cities:UPDATE=1,venues:UPDATE=1' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk='ve_5cb5124e0b' AND (old_row-'status')=(new_row-'status') AND new_row->>'status'='closed') <> 1 THEN RAISE EXCEPTION 'audit status row'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
'''
open(F,'w',encoding='utf-8',newline='\n').write(sql)
print(F,hashlib.sha256(sql.encode()).hexdigest(),len(sql.splitlines()))
