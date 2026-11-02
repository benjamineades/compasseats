#!/usr/bin/env python3
"""Build docs/fix-michelin-2026-italy-status-gap.sql. Ben, Nov 2 2026, 07:22 ET: "S1, G1, V2".
Checks the relay lines before it writes the file."""
import hashlib, os
HERE = os.path.dirname(os.path.abspath(__file__))
R26 = os.path.join(HERE, 'relay-it-2026-archive-20251123.txt')
OUT = os.path.join(HERE, '..', 'fix-michelin-2026-italy-status-gap.sql')
raw = open(R26, 'rb').read()
sha26 = hashlib.sha256(raw).hexdigest()
assert sha26 == 'd754b751b817de4a56b2f83d0033eaf92fc38606ac0bfabb9a3e6c724777d073', sha26
rows = {l.split('|')[0]: l.split('|') for l in raw.decode().rstrip('\n').split('\n')[1:]}
assert rows['294'][1:] == ['1', 'TOSCANA', 'Arezzo', 'Octavin', '/it/it/toscana/arezzo/ristorante/octavin']
assert rows['332'][1:] == ['1', 'TOSCANA', 'Vinci', 'Atman', '/it/it/toscana/vinci_1839587/ristorante/atman']
assert rows['389'][1:] == ['1', 'VENETO', 'Venezia', 'Agli Amici Dopolavoro', '/it/it/veneto/venezia/ristorante/dopolavoro']
V_NEW = 've_' + hashlib.md5(b'venice:agli-amici-dopolavoro').hexdigest()[:10]
assert V_NEW == 've_5025ee0810'
ART = 'https://web.archive.org/web/20251123134344id_/https://guide.michelin.com/it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia-2026'
JOB = ('fix:michelin-2026-italy-status-gap | open items 2-3 (Ben, Nov 2 07:22 ET "S1, G1, V2"): 3 One Star 2026 rows from the ceremony article: '
       'Octavin ve_df6d5db906 (line 294), Atman ve_48fe5153e8 (line 332), Agli Amici Dopolavoro new venue ve_5025ee0810 (line 389) | '
       f'article {ART} | relay docs/it-2026-build/relay-it-2026-archive-20251123.txt sha256 {sha26} | '
       'status only, no ledger count: active -> closed Octavin, Atman; closed -> active Atelier, La Stua de Michil, La Trattoria, Stube Hermitage, Suinsom | '
       'stay closed, recheck: Wood, Peter Brunel, Quattro Passi | '
       'V2: 7 closed or paused restaurants get no venue (San Barbato, Il Circolino, Sedicesimo Secolo, Gabbiano 3.0, Castello di Fighine, Palais Royal, Matteo Grandi in Basilica); article 341, database 334')
assert "'" not in JOB
FP = '03b8690373ca8de65980973f3f14d17e'
AFP = '5792786a3c02add3dd7ab867951d6c6e'
SQL = f"""-- fix-michelin-2026-italy-status-gap.sql
-- CompassEats, Nov 2 2026. Open items 2 and 3 of handoff-it-2026-fixes-done-2026-11-02.md.
-- Ben: Nov 2 07:22 ET "S1, G1, V2". This file runs only after his "go".
--
-- S1, status only:
--   closed -> active (live card with the 2026 star, hours, no closure note, read Nov 2):
--     Atelier ve_41b4987ce8 (own site capture 20260622182923), La Stua de Michil ve_4397691f95 (own site booking link),
--     La Trattoria ve_28f49a1d8b (own site capture 20260611043346: May to September),
--     Stube Hermitage ve_f19d2083ac (own site capture 20260618075823), Suinsom ve_52ff3a77a0 (tyrolhotel.it hours, booking).
--   active -> closed:
--     Octavin ve_df6d5db906: closed Jun 30 2026, https://www3.saturnonotizie.it/news/read/208312/octavin-arezzo.html ; card 404.
--     Atman ve_48fe5153e8: closed, https://www.ilforchettiere.it/chiude-atman-marco-cahssai-enoteca-baldovino-pistoia/ ; card 404.
--   No change, recheck (temporary-closure rule, Sep 28): Wood ve_b935a2a19a, Peter Brunel ve_dbe27febdc, Quattro Passi ve_ee9dbbdba9.
-- G1: 2026 One Star rows for Octavin (relay line 294) and Atman (line 332), article URL.
-- V2: new venue Agli Amici Dopolavoro (line 389), Venice, active, with a 2026 One Star row and 2 city labels. Card 404 on Nov 2.
--   Open by press: https://travelandretreat.com/2026/08/22/jw-marriott-venice-resort-spa-the-island-hospital-that-turned-into-venices-most-private-address/
--   Name from the own site: https://www.agliamici.it/ . No price row (no live card). No 2025 row (first star Nov 2025).
-- Awards keep history. Nothing is deleted.
BEGIN;
DO $fix$
DECLARE
  v_new    constant text := '{V_NEW}';
  v_oct    constant text := 've_df6d5db906';
  v_atm    constant text := 've_48fe5153e8';
  c_venice constant text := 'ci_fbf968d5fc';
  u_art    constant text := '{ART}';
  aud_max  bigint;
  led_max  bigint;
  x        bigint;
  t        text;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM venues;                       IF x <> 11300 THEN RAISE EXCEPTION 'venues before %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='active'; IF x <> 10934 THEN RAISE EXCEPTION 'active before %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='closed'; IF x <> 366   THEN RAISE EXCEPTION 'closed before %', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 25082 THEN RAISE EXCEPTION 'awards before %', x; END IF;
  SELECT max(id) INTO x FROM awards;                        IF x <> 32021 THEN RAISE EXCEPTION 'awards max before %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin'; IF x <> 11378 THEN RAISE EXCEPTION 'michelin before %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2026; IF x <> 6280 THEN RAISE EXCEPTION 'michelin 2026 before %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11300 THEN RAISE EXCEPTION 'canonical before %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1704  THEN RAISE EXCEPTION 'non-canonical before %', x; END IF;
  SELECT count(*) INTO x FROM price;                        IF x <> 7734  THEN RAISE EXCEPTION 'price before %', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11300 THEN RAISE EXCEPTION 'listings before %', x; END IF;
  SELECT count(*) INTO x FROM cities;                       IF x <> 3262  THEN RAISE EXCEPTION 'cities before %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                 IF x <> 266   THEN RAISE EXCEPTION 'aliases before %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;            IF x <> 23999 THEN RAISE EXCEPTION 'labels before %', x; END IF;
  SELECT count(*) INTO x FROM redirects;                    IF x <> 9     THEN RAISE EXCEPTION 'redirects before %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;              IF x <> 10934 THEN RAISE EXCEPTION 'venues_count sum before %', x; END IF;
  SELECT count(*), max(id) INTO x, led_max FROM source_capture_ledger; IF x <> 168 OR led_max <> 220 THEN RAISE EXCEPTION 'ledger before % / %', x, led_max; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;  IF x <> 118040 OR aud_max <> 123554 THEN RAISE EXCEPTION 'audit before % / %', x, aud_max; END IF;

  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
   WHERE a.source_id='michelin' AND a.year=2026 AND c.country='Italy' AND a.category='One Star';
  IF x <> 331 THEN RAISE EXCEPTION 'IT 2026 One Star before %', x; END IF;

  -- Plan fingerprint: the 7 venues with status, city and city count, read Nov 2 12:23 UTC.
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||c.venues_count, E'\\n' ORDER BY v.id)) INTO t
    FROM venues v JOIN cities c ON c.id=v.city_id
   WHERE v.id IN ('ve_41b4987ce8','ve_4397691f95','ve_28f49a1d8b','ve_f19d2083ac','ve_52ff3a77a0',v_oct,v_atm);
  IF t IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'plan fingerprint %', t; END IF;
  SELECT md5(string_agg(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category, ',' ORDER BY a.id)) INTO t FROM awards a WHERE a.venue_id IN (v_oct,v_atm);
  IF t IS DISTINCT FROM '{AFP}' THEN RAISE EXCEPTION 'award fingerprint %', t; END IF;
  SELECT venues_count INTO x FROM cities WHERE id=c_venice; IF x <> 13 THEN RAISE EXCEPTION 'Venice count %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE id=v_new OR norm_key LIKE '%dopolavoro%'; IF x <> 0 THEN RAISE EXCEPTION 'new venue clash %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE city_slug='venice' AND slug='agli-amici-dopolavoro'; IF x <> 0 THEN RAISE EXCEPTION 'slug clash %', x; END IF;
  SELECT count(*) INTO x FROM redirects WHERE from_path LIKE '/venice/agli-amici%' OR to_path LIKE '/venice/agli-amici%'; IF x <> 0 THEN RAISE EXCEPTION 'redirect clash %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_url=u_art; IF x <> 1 THEN RAISE EXCEPTION 'article rows before %', x; END IF;
  IF v_new <> 've_'||left(md5('venice:agli-amici-dopolavoro'),10) THEN RAISE EXCEPTION 'venue id rule'; END IF;

  ---------------------------------------------------------------- WRITE 1: status closed -> active (5)
  UPDATE venues SET status='active' WHERE status='closed'
     AND id IN ('ve_41b4987ce8','ve_4397691f95','ve_28f49a1d8b','ve_f19d2083ac','ve_52ff3a77a0');
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 5 THEN RAISE EXCEPTION 'to active %', x; END IF;

  ---------------------------------------------------------------- WRITE 2: status active -> closed (2)
  UPDATE venues SET status='closed' WHERE status='active' AND id IN (v_oct,v_atm);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'to closed %', x; END IF;

  ---------------------------------------------------------------- WRITE 3: new venue, listing, slug
  INSERT INTO venues (id, name, category, city_id, status) VALUES (v_new, 'Agli Amici Dopolavoro', 'restaurant', c_venice, 'active');
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'venue insert %', x; END IF;
  INSERT INTO listings (venue_id, property_id, published) VALUES (v_new, 'eats', true);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'listing insert %', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'venice', 'agli-amici-dopolavoro', v_new, true);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'slug insert %', x; END IF;

  ---------------------------------------------------------------- WRITE 4: 2 city labels, hand audit (no trigger on this table)
  WITH ins AS (
    INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) VALUES
      (v_new, 'Venezia', 'city_display', 'michelin', 'michelin-2026-italy'),
      (v_new, 'Italy',   'country',      'michelin', 'michelin-2026-italy')
    RETURNING *)
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'label insert %', x; END IF;

  ---------------------------------------------------------------- WRITE 5: 3 awards
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
    (v_oct, 'michelin', 2026, NULL, 'One Star', NULL, u_art),
    (v_atm, 'michelin', 2026, NULL, 'One Star', NULL, u_art),
    (v_new, 'michelin', 2026, NULL, 'One Star', NULL, u_art);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 3 THEN RAISE EXCEPTION 'award insert %', x; END IF;

  ---------------------------------------------------------------- WRITE 6: city counts
  UPDATE cities SET venues_count = venues_count + 1 WHERE id IN ('ci_d0c089ba83','ci_fa946ae620','ci_19af4dde89','ci_477381c712','ci_97edd4ae8f',c_venice);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 6 THEN RAISE EXCEPTION 'count up %', x; END IF;
  UPDATE cities SET venues_count = venues_count - 1 WHERE id IN ('ci_0f689ae1dc','ci_7d93cd2d91') AND venues_count = 1;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'count down %', x; END IF;

  ---------------------------------------------------------------- WRITE 7: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 3, '{JOB}');
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'ledger insert %', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM venues;                       IF x <> 11301 THEN RAISE EXCEPTION 'venues after %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='active'; IF x <> 10938 THEN RAISE EXCEPTION 'active after %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='closed'; IF x <> 363   THEN RAISE EXCEPTION 'closed after %', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 25085 THEN RAISE EXCEPTION 'awards after %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin'; IF x <> 11381 THEN RAISE EXCEPTION 'michelin after %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2026; IF x <> 6283 THEN RAISE EXCEPTION 'michelin 2026 after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11301 THEN RAISE EXCEPTION 'canonical after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1704  THEN RAISE EXCEPTION 'non-canonical after %', x; END IF;
  SELECT count(*) INTO x FROM price;                        IF x <> 7734  THEN RAISE EXCEPTION 'price after %', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11301 THEN RAISE EXCEPTION 'listings after %', x; END IF;
  SELECT count(*) INTO x FROM cities;                       IF x <> 3262  THEN RAISE EXCEPTION 'cities after %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                 IF x <> 266   THEN RAISE EXCEPTION 'aliases after %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;            IF x <> 24001 THEN RAISE EXCEPTION 'labels after %', x; END IF;
  SELECT count(*) INTO x FROM redirects;                    IF x <> 9     THEN RAISE EXCEPTION 'redirects after %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;              IF x <> 10938 THEN RAISE EXCEPTION 'venues_count sum after %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;        IF x <> 169   THEN RAISE EXCEPTION 'ledger after %', x; END IF;

  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
   WHERE a.source_id='michelin' AND a.year=2026 AND c.country='Italy' AND a.category='One Star';
  IF x <> 334 THEN RAISE EXCEPTION 'IT 2026 One Star after %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_url=u_art; IF x <> 4 THEN RAISE EXCEPTION 'article rows after %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without 1 canonical slug: %', x; END IF;
  SELECT count(*) INTO x FROM (SELECT c.id FROM cities c LEFT JOIN venues v ON v.city_id=c.id AND v.status='active'
     WHERE c.id IN ('ci_d0c089ba83','ci_fa946ae620','ci_19af4dde89','ci_477381c712','ci_97edd4ae8f','ci_0f689ae1dc','ci_7d93cd2d91',c_venice)
     GROUP BY c.id, c.venues_count HAVING count(v.id) <> c.venues_count) q;
  IF x <> 0 THEN RAISE EXCEPTION 'city counts differ from active venues: %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE id IN ('ve_b935a2a19a','ve_dbe27febdc','ve_ee9dbbdba9') AND status='closed';
  IF x <> 3 THEN RAISE EXCEPTION 'recheck 3 changed %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max; IF x <> 23 THEN RAISE EXCEPTION 'audit rows %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='venues'; IF x <> 8 THEN RAISE EXCEPTION 'audit venues %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='cities'; IF x <> 8 THEN RAISE EXCEPTION 'audit cities %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='awards'; IF x <> 3 THEN RAISE EXCEPTION 'audit awards %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='listings'; IF x <> 1 THEN RAISE EXCEPTION 'audit listings %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='slugs'; IF x <> 1 THEN RAISE EXCEPTION 'audit slugs %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='city_label_source'; IF x <> 2 THEN RAISE EXCEPTION 'audit labels %', x; END IF;
  -- Each status update changed status and nothing else.
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='venues' AND action='UPDATE'
     AND (old_row-'status')=(new_row-'status') AND old_row->>'status' <> new_row->>'status';
  IF x <> 7 THEN RAISE EXCEPTION 'audit status-only updates %', x; END IF;

  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
"""
assert all(ord(c) < 128 for c in SQL)
open(OUT, 'w').write(SQL)
print(hashlib.sha256(SQL.encode()).hexdigest(), SQL.count('\n'))
