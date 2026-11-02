#!/usr/bin/env python3
"""Build docs/fix-michelin-2026-italy-status-names.sql. Ben, Nov 2 2026, 08:06 ET: "E1, U1, N1"."""
import hashlib, os, re
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', 'fix-michelin-2026-italy-status-names.sql')
A = 'https://guide.michelin.com/us/en/'
ATM = 'https://web.archive.org/web/20260116191322id_/https://guide.michelin.com/it/it/toscana/vinci_1839587/ristorante/atman'
# line, venue, old name, new name, source url, city slug, old slug, new slug, new slug exists, evidence
R = [
 (1, 've_b24b1c1085', 'Ristorante Il Desco', 'Il Desco', A+'veneto/verona/restaurant/il-desco', 'verona', 'ristorante-il-desco', 'il-desco', True,
  'R2: own site capture 20260203020004 writes Ristorante Il Desco and Il Desco; card h1 Il Desco, read Nov 2'),
 (2, 've_acdfd2daf5', 'Iris Ristorante a Palazzo Soave', 'Iris Ristorante', A+'veneto/verona/restaurant/iris-ristorante', 'verona', 'iris-ristorante-a-palazzo-soave', 'iris-ristorante', True,
  'R2: own site capture 20260321011800 writes IRIS Ristorante a Palazzo Soave, Iris Ristorante, IRIS; card h1 Iris Ristorante, read Nov 2'),
 (3, 've_74d392b2d5', 'Ristorante San Martino', 'San Martino', A+'veneto/scorz/restaurant/san-martino', 'scorze', 'ristorante-san-martino', 'san-martino', True,
  'R2: own site capture 20251014104413 writes Ristorante San Martino and San Martino; card h1 San Martino, read Nov 2'),
 (4, 've_48fe5153e8', 'Ristorante Atman', 'Atman', ATM, 'vinci', 'ristorante-atman', 'atman', False,
  'R5: no website found; Facebook Ristorante Atman a Vinci; archive card h1 Atman, capture 20260116191322; live card 404; venue closed'),
]
for r in R:
    assert re.sub(r'[^a-z0-9]+', '-', r[3].lower()).strip('-') == r[7]
KEY = 'rename-michelin-2026-italy-name-pairs-2026-11-02'
NOTE = 'Italy open item 6 (Ben, Nov 2 08:06 ET "E1, U1, N1"): rules R1-R5 and the Oct 10 ruling. Assonica ve_62d9bf3a36 keeps its name (own site and card agree).'
JOB = f'rename-apply:{KEY} | gated SQL file docs/fix-michelin-2026-italy-status-names.sql | 4 rows follow the Michelin card name: Il Desco, Iris Ristorante, San Martino (R2), Atman (R5) | Assonica keeps its name'
assert "'" not in JOB + NOTE
FP = 'e404d299fa741cfed019bb5764a5f36b'
vals = ',\n'.join("    (%d,'%s','%s','%s','%s','%s','%s','%s',%s,'%s')" % (r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], 'true' if r[8] else 'false', r[9]) for r in R)
SQL = f"""-- fix-michelin-2026-italy-status-names.sql
-- CompassEats, Nov 2 2026. Open items 3 and 6 of handoff-it-2026-status-done-2026-11-02.md.
-- Ben: Nov 2 08:06 ET "E1, U1, N1". This file runs only after his "go".
-- E1: Santa Elisabetta ve_e1339c5391 to closed, status only. Own site https://www.ristorantesantaelisabetta.it/ (read Nov 2; capture 20260618101839):
--     "temporarily close Santa Elisabetta as it is today"; no reopening date; card 404. Sep 28 temporary-closure rule. Awards stay.
-- U1: Unforgettable ve_a006de1bf7 holds, recheck after Nov 12. Impronte ve_6c4d801f2f stays active, recheck after Nov 12. No write.
-- N1: rename batch {KEY}: 4 venues, new name = Michelin card name. Old slugs stay as non-canonical rows.
-- Expected after: venues 11,301 (active 10,937, closed 364); slugs 13,006 (canonical 11,301, non-canonical 1,705);
--   cities.venues_count sum 10,937 (Florence 27); rename_batches 23, rename_rows 1,282; ledger 170 rows, last id 222;
--   audit_log +14: venues UPDATE 5, cities UPDATE 1, slugs UPDATE 7, slugs INSERT 1.
-- Dry run: send the DO block through the Read connector. It stops at the first write with "read-only transaction".
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; led_max bigint; bid bigint; n bigint; s text; r record;
BEGIN
  ---------------------------------------------------------------- PRE gates (read Nov 2 13:06 UTC)
  IF (SELECT count(*) FROM venues) <> 11301 OR (SELECT count(*) FROM venues WHERE status='active') <> 10938 OR (SELECT count(*) FROM venues WHERE status='closed') <> 363 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25085 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13005 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1704 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11301 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7734 THEN RAISE EXCEPTION 'listings/blurbs/price before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3262 OR (SELECT sum(venues_count) FROM cities) <> 10938 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 22 OR (SELECT count(*) FROM rename_rows) <> 1278 THEN RAISE EXCEPTION 'rename tables before'; END IF;
  SELECT count(*), max(id) INTO n, led_max FROM source_capture_ledger; IF n <> 169 OR led_max <> 221 THEN RAISE EXCEPTION 'ledger before % / %', n, led_max; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118063 OR aud_max <> 123577 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\\n' ORDER BY v.id)) INTO s FROM venues v
   WHERE v.id IN ('ve_b24b1c1085','ve_acdfd2daf5','ve_74d392b2d5','ve_48fe5153e8','ve_e1339c5391');
  IF s IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'plan fingerprint %', s; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_062c148454') <> 28 THEN RAISE EXCEPTION 'Florence count'; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='{KEY}') THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF EXISTS (SELECT 1 FROM rename_rows WHERE venue_id IN ('ve_b24b1c1085','ve_acdfd2daf5','ve_74d392b2d5','ve_48fe5153e8')) THEN RAISE EXCEPTION 'earlier rename row'; END IF;
  IF EXISTS (SELECT 1 FROM blurbs WHERE venue_id IN ('ve_b24b1c1085','ve_acdfd2daf5','ve_74d392b2d5','ve_48fe5153e8')) THEN RAISE EXCEPTION 'blurb on a renamed venue'; END IF;
  IF EXISTS (SELECT 1 FROM slugs WHERE city_slug='vinci' AND slug='atman') THEN RAISE EXCEPTION 'vinci/atman in use'; END IF;
  IF EXISTS (SELECT 1 FROM redirects WHERE from_path ~ '/(verona|scorze|vinci)/' OR to_path ~ '/(verona|scorze|vinci)/') THEN RAISE EXCEPTION 'redirect on a path'; END IF;
  IF EXISTS (SELECT 1 FROM venues a JOIN venues b ON b.city_id=a.city_id AND b.id<>a.id AND b.norm_key IN ('ildesco','irisristorante','sanmartino','atman')
     WHERE a.id IN ('ve_b24b1c1085','ve_acdfd2daf5','ve_74d392b2d5','ve_48fe5153e8')) THEN RAISE EXCEPTION 'norm_key collision in a city'; END IF;

  ---------------------------------------------------------------- WRITE 1: Santa Elisabetta, status only
  UPDATE venues SET status='closed' WHERE id='ve_e1339c5391' AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE cities SET venues_count=27 WHERE id='ci_062c148454' AND venues_count=28;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'Florence %', n; END IF;

  ---------------------------------------------------------------- WRITE 2: rename batch
  INSERT INTO rename_batches (batch_key, status, note) VALUES ('{KEY}', 'staged', '{NOTE}') RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  FOR r IN SELECT * FROM (VALUES
{vals}
  ) t(line, vid, oldn, newn, url, cs, olds, news, ex, ev) LOOP
    INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
    SELECT bid, r.line, v.id, v.name, r.newn, 'michelin', r.url, 'rename',
           jsonb_build_object('note', r.ev, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', r.cs, 'slug', r.olds)
      FROM venues v WHERE v.id=r.vid AND v.name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename row %', r.vid; END IF;
    UPDATE venues SET name=r.newn WHERE id=r.vid AND name=r.oldn;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename %', r.vid; END IF;
    IF trim(both '-' from regexp_replace(lower(f_unaccent(r.newn)),'[^a-z0-9]+','-','g')) <> r.news THEN RAISE EXCEPTION 'slug rule %', r.vid; END IF;
    UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug=r.cs AND slug=r.olds AND is_canonical;
    GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', r.vid; END IF;
    IF r.ex THEN
      UPDATE slugs SET is_canonical=true WHERE property_id='eats' AND venue_id=r.vid AND city_slug=r.cs AND slug=r.news AND NOT is_canonical;
      GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'new slug %', r.vid; END IF;
    ELSE
      INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', r.cs, r.news, r.vid, true);
    END IF;
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;

  ---------------------------------------------------------------- WRITE 3: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'name', 4, '{JOB}');

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM venues) <> 11301 OR (SELECT count(*) FROM venues WHERE status='active') <> 10937 OR (SELECT count(*) FROM venues WHERE status='closed') <> 364 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25085 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13006 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1705 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11301 THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF (SELECT count(*) FROM listings) <> 11301 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM price) <> 7734 THEN RAISE EXCEPTION 'listings/blurbs/price after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10937 THEN RAISE EXCEPTION 'sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'cities differ after'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 23 OR (SELECT count(*) FROM rename_rows) <> 1282 THEN RAISE EXCEPTION 'rename tables after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 170 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF EXISTS (SELECT v.id FROM venues v LEFT JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical AND sl.property_id='eats' GROUP BY v.id HAVING count(sl.slug) <> 1) THEN RAISE EXCEPTION 'canonical slug count'; END IF;
  SELECT string_agg(v.name||' '||sl.city_slug||'/'||sl.slug, ', ' ORDER BY v.name) INTO s FROM venues v JOIN slugs sl ON sl.venue_id=v.id AND sl.is_canonical
   WHERE v.id IN ('ve_b24b1c1085','ve_acdfd2daf5','ve_74d392b2d5','ve_48fe5153e8');
  IF s IS DISTINCT FROM 'Atman vinci/atman, Il Desco verona/il-desco, Iris Ristorante verona/iris-ristorante, San Martino scorze/san-martino' THEN RAISE EXCEPTION 'names after: %', s; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name, action) INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=1,slugs:INSERT=1,slugs:UPDATE=7,venues:UPDATE=5' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk='ve_e1339c5391' AND (old_row-'status')=(new_row-'status') AND new_row->>'status'='closed') <> 1 THEN RAISE EXCEPTION 'status audit'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk<>'ve_e1339c5391' AND (old_row-'name'-'norm_key')=(new_row-'name'-'norm_key')) <> 4 THEN RAISE EXCEPTION 'rename audit'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
"""
assert all(ord(c) < 128 for c in SQL)
open(OUT, 'w').write(SQL)
print(hashlib.sha256(SQL.encode()).hexdigest(), SQL.count('\n'))
