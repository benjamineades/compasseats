#!/usr/bin/env python3
"""Build docs/fix-michelin-2026-italy-san-martino-gaps.sql from the two relay files.
Ben, Nov 2 2026, 06:25 ET: "S1, G1, C1, X1". Checks the relay lines before it writes the file."""
import hashlib
import os

HERE = os.path.dirname(os.path.abspath(__file__))
R26 = os.path.join(HERE, 'relay-it-2026-archive-20251123.txt')
R25 = os.path.join(HERE, '..', 'it-2025-build', 'relay-it-2025-archive-20241105.txt')
OUT = os.path.join(HERE, '..', 'fix-michelin-2026-italy-san-martino-gaps.sql')

raw = open(R26, 'rb').read()
sha26 = hashlib.sha256(raw).hexdigest()
assert sha26 == 'd754b751b817de4a56b2f83d0033eaf92fc38606ac0bfabb9a3e6c724777d073', sha26
rows = [l.split('|') for l in raw.decode().rstrip('\n').split('\n')[1:]]
assert len(rows) == 394
assert [sum(r[1] == s for r in rows) for s in '321'] == [15, 38, 341]
by_n = {r[0]: r for r in rows}
assert by_n['96'][3:] == ['Somma Vesuviana', 'Contaminazioni Restaurant', '/it/it/campania/somma-vesuviana/ristorante/contaminazioni-restaurant']
assert by_n['184'][3:] == ['Fasano del Garda', 'Lido 84', '/it/it/lombardia/fasano-del-garda/ristorante/lido-84']
assert by_n['223'][3:] == ['Treviglio', 'San Martino', '/it/it/lombardia/treviglio/ristorante/san-martino155366']
assert by_n['385'][3:] == ['Scorz\\u00e8', 'San Martino', '/it/it/veneto/scorz/ristorante/san-martino']
assert all(by_n[n][1] == '1' for n in ('96', '184', '223', '385'))

r25 = {l.split('|')[0]: l.rstrip('\n') for l in open(R25, encoding='utf8')}
assert r25['218'] == '218|1|LOMBARDIA|Treviglio|San Martino|0|0|/it/it/lombardia/treviglio/ristorante/san-martino155366', r25['218']

ART26 = 'https://web.archive.org/web/20251123134344id_/https://guide.michelin.com/it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia-2026'
ART25 = 'https://web.archive.org/web/20241105213726id_/https://guide.michelin.com/it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia'
LIDO = 'https://web.archive.org/web/20260207070145id_/https://guide.michelin.com/it/it/lombardia/fasano-del-garda/ristorante/lido-84'
TREV = 'https://guide.michelin.com/us/en/lombardia/treviglio/restaurant/san-martino155366'
SCOR = 'https://guide.michelin.com/us/en/veneto/scorz/restaurant/san-martino'

JOB_AWARD = (
    'fix:michelin-2026-italy-san-martino-gaps | open items 2-3 (Ben, Nov 2 06:25 ET "S1, G1, C1, X1"): '
    'award 23163 (Treviglio card) moved from ve_74d392b2d5 (Scorze) to the new venue ve_2ed5af2056 (Treviglio); '
    '4 rows inserted: Treviglio 2025 One Star (2025 relay line 218, archive article), Scorze 2026 One Star (live card, read Nov 2), '
    'Contaminazioni ve_48a3d8cc5d 2026 One Star (archive article, line 96), Lido 84 ve_e16ffafc83 2026 One Star (archive card 20260207070145, line 184) | '
    'cause: alias treviglio -> Scorze sent fixture line 128 to Scorze; line 214 then failed as duplicate_in_batch | '
    f'article {ART26} | relay docs/it-2026-build/relay-it-2026-archive-20251123.txt sha256 {sha26} | '
    'counts 15/38/341 = ceremony counts | ceremony Nov 19 2025, capture Nov 23 2025 | '
    'Contaminazioni and Lido 84 closed after the ceremony; their cards now give 404 | '
    'X1: Octavin, Atman and 8 restaurants with no venue stay open (article 341, database 331)'
)
JOB_PRICE = (
    'fix:michelin-2026-italy-san-martino-gaps | price from the live cards, built-in browser, Nov 2: '
    f'new row ve_2ed5af2056 EUR tier 3 from {TREV}; ve_74d392b2d5 source_url changed from the Treviglio card to {SCOR} (value unchanged, EUR tier 3)'
)
for j in (JOB_AWARD, JOB_PRICE):
    assert "'" not in j

SQL = f"""-- fix-michelin-2026-italy-san-martino-gaps.sql
-- CompassEats, Nov 2 2026. Open items 2, 3 and 4 of handoff-it-2025-backfill-done-2026-11-02.md.
-- Ben: Nov 2 06:25 ET "S1, G1, C1, X1". This file runs only after his "go".
--
-- Evidence:
--   Article: {ART26}
--     394 lines = 15 / 38 / 341 = ceremony counts. Relay docs/it-2026-build/relay-it-2026-archive-20251123.txt
--     sha256 {sha26} (browser = disk). Lines: 96 Contaminazioni, 184 Lido 84, 223 Treviglio, 385 Scorze.
--   Live cards read Nov 2 (built-in browser), both 2026 One Star and EUR tier 3:
--     Treviglio: Viale Cesare Battisti 3, +39 0363 49075, {TREV}
--     Scorze: Piazza Cappelletto 1, +39 041 584 0648, {SCOR}
--   Lido 84 archive card {LIDO} names the 2026 guide.
--   Contaminazioni: card = via San Sossio 2, Somma Vesuviana. Italia a Tavola, Mar 17 2026: closes from May. Live card: 404.
--     Michelin-closed rule (Sep 28): status closed, nothing deleted.
--
-- What this file does (1 transaction, 1 DO block):
--   1. Inserts city Treviglio ci_50a360bb5d (venues_count 1) and city Somma Vesuviana ci_ff2387962a (venues_count 0).
--   2. Inserts venue San Martino ve_2ed5af2056 (Treviglio, active), its listing and slug treviglio/san-martino.
--   3. Moves award 23163 (2026 One Star, Treviglio card) to the new venue. Its id and URL do not change.
--   4. Inserts 4 awards: Treviglio 2025, Scorze 2026, Contaminazioni 2026, Lido 84 2026.
--   5. Inserts the Treviglio price row. Changes the Scorze price source to the Scorze card (value unchanged).
--   6. Moves city labels 22976 and 22977 to the new venue (2 hand audit rows).
--   7. Points alias treviglio to the new city (1 hand audit row).
--   8. Contaminazioni: moves it to Somma Vesuviana, status closed. Old slug naples/contaminazioni-restaurant becomes
--      non-canonical (the old URL keeps working). New canonical slug somma-vesuviana/contaminazioni-restaurant.
--      Naples venues_count 10 -> 9.
--   9. Inserts 2 ledger rows.
-- Not changed: Lido 84 city and status, slug scorze/san-martino (non-canonical, stays on Scorze), redirects.
-- Audit rows: cities 3, venues 2, listings 1, slugs 3, awards 5, price 2, hand 3 = 19.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $fix$
DECLARE
  c_trev   constant text := 'ci_50a360bb5d';
  c_somma  constant text := 'ci_ff2387962a';
  c_scorze constant text := 'ci_8507395851';
  c_naples constant text := 'ci_d5fc4b0e45';
  v_trev   constant text := 've_2ed5af2056';
  v_scorze constant text := 've_74d392b2d5';
  v_cont   constant text := 've_48a3d8cc5d';
  v_lido   constant text := 've_e16ffafc83';
  u_art26  constant text := '{ART26}';
  u_art25  constant text := '{ART25}';
  u_lido   constant text := '{LIDO}';
  u_trev   constant text := '{TREV}';
  u_scor   constant text := '{SCOR}';
  x        bigint;
  t        text;
  t2       text;
  aud_max  bigint;
  led_max  bigint;
  aw_max   bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  SELECT count(*) INTO x FROM venues;                       IF x <> 11299 THEN RAISE EXCEPTION 'venues before %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='active'; IF x <> 10934 THEN RAISE EXCEPTION 'active before %', x; END IF;
  SELECT count(*), max(id) INTO x, aw_max FROM awards;      IF x <> 25078 OR aw_max <> 32017 THEN RAISE EXCEPTION 'awards before % / %', x, aw_max; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin'; IF x <> 11374 THEN RAISE EXCEPTION 'michelin before %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2025; IF x <> 4998 THEN RAISE EXCEPTION 'michelin 2025 before %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                        IF x <> 13002 THEN RAISE EXCEPTION 'slugs before %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1703  THEN RAISE EXCEPTION 'non-canonical before %', x; END IF;
  SELECT count(*) INTO x FROM price;                        IF x <> 7733  THEN RAISE EXCEPTION 'price before %', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11299 THEN RAISE EXCEPTION 'listings before %', x; END IF;
  SELECT count(*) INTO x FROM cities;                       IF x <> 3260  THEN RAISE EXCEPTION 'cities before %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                 IF x <> 266   THEN RAISE EXCEPTION 'aliases before %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;            IF x <> 23999 THEN RAISE EXCEPTION 'labels before %', x; END IF;
  SELECT count(*) INTO x FROM redirects;                    IF x <> 9     THEN RAISE EXCEPTION 'redirects before %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;              IF x <> 10934 THEN RAISE EXCEPTION 'venues_count sum before %', x; END IF;
  SELECT count(*), max(id) INTO x, led_max FROM source_capture_ledger; IF x <> 166 OR led_max <> 218 THEN RAISE EXCEPTION 'ledger before % / %', x, led_max; END IF;
  SELECT count(*), max(id) INTO x, aud_max FROM audit_log;  IF x <> 118021 OR aud_max <> 123533 THEN RAISE EXCEPTION 'audit before % / %', x, aud_max; END IF;

  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
   WHERE a.source_id='michelin' AND a.year=2026 AND c.country='Italy' AND a.category='One Star';
  IF x <> 328 THEN RAISE EXCEPTION 'IT 2026 One Star before %', x; END IF;

  IF c_trev <> 'ci_'||left(md5('treviglio'),10) OR c_somma <> 'ci_'||left(md5('somma-vesuviana'),10) THEN RAISE EXCEPTION 'city id rule'; END IF;
  IF v_trev <> 've_'||left(md5('treviglio:san-martino'),10) THEN RAISE EXCEPTION 'venue id rule'; END IF;

  SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key) INTO t FROM venues v WHERE id=v_cont;
  IF t IS DISTINCT FROM '0004e1e2ea4bb5682e1dd29885714e79' THEN RAISE EXCEPTION 'Contaminazioni row changed: %', t; END IF;
  SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key) INTO t FROM venues v WHERE id=v_scorze;
  IF t IS DISTINCT FROM '840786890bf6d1900b2bab2ea8b936cb' THEN RAISE EXCEPTION 'Scorze row changed: %', t; END IF;
  SELECT md5(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id||'|'||v.norm_key) INTO t FROM venues v WHERE id=v_lido;
  IF t IS DISTINCT FROM 'a66c3fc7ad2c2d350c2c86e22b230600' THEN RAISE EXCEPTION 'Lido 84 row changed: %', t; END IF;
  SELECT md5(a.id||'|'||a.venue_id||'|'||a.year||'|'||a.category||'|'||a.source_url) INTO t FROM awards a WHERE id=23163;
  IF t IS DISTINCT FROM '6a62285edc431cd8617abfa5bc23bec8' THEN RAISE EXCEPTION 'award 23163 changed: %', t; END IF;
  SELECT md5(p.tier||'|'||p.symbol_raw||'|'||p.source||'|'||p.source_url) INTO t FROM price p WHERE venue_id=v_scorze;
  IF t IS DISTINCT FROM 'a71cb85fbcb21525e4e61150be28bf7c' THEN RAISE EXCEPTION 'Scorze price changed: %', t; END IF;
  SELECT md5(string_agg(c.id||'|'||c.venue_id||'|'||c.label||'|'||c.from_column,',' ORDER BY id)) INTO t FROM city_label_source c WHERE id IN (22976,22977);
  IF t IS DISTINCT FROM '348e0f5ddf71ab758ac977319dcbed69' THEN RAISE EXCEPTION 'labels changed: %', t; END IF;
  SELECT city_id INTO t FROM city_aliases WHERE alias='treviglio';
  IF t IS DISTINCT FROM c_scorze THEN RAISE EXCEPTION 'alias treviglio points to %', t; END IF;
  SELECT venues_count INTO x FROM cities WHERE id=c_naples; IF x <> 10 THEN RAISE EXCEPTION 'Naples count %', x; END IF;

  SELECT count(*) INTO x FROM cities WHERE id IN (c_trev,c_somma) OR slug IN ('treviglio','somma-vesuviana')
     OR btrim(regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+',' ','g')) IN ('treviglio','somma vesuviana');
  IF x <> 0 THEN RAISE EXCEPTION 'new city clash %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases WHERE alias='somma vesuviana'; IF x <> 0 THEN RAISE EXCEPTION 'alias somma clash'; END IF;
  SELECT count(*) INTO x FROM venues WHERE id=v_trev OR norm_key='sanmartino'; IF x <> 0 THEN RAISE EXCEPTION 'new venue clash %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE city_slug IN ('treviglio','somma-vesuviana'); IF x <> 0 THEN RAISE EXCEPTION 'slug clash %', x; END IF;
  SELECT count(*) INTO x FROM redirects WHERE from_path LIKE '/treviglio/%' OR from_path LIKE '/somma-vesuviana/%' OR from_path LIKE '/naples/contaminazioni%' OR to_path LIKE '/naples/contaminazioni%';
  IF x <> 0 THEN RAISE EXCEPTION 'redirect clash %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id=v_cont; IF x <> 1 THEN RAISE EXCEPTION 'Contaminazioni slugs %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id=v_cont AND property_id='eats' AND city_slug='naples' AND slug='contaminazioni-restaurant' AND is_canonical;
  IF x <> 1 THEN RAISE EXCEPTION 'Contaminazioni canonical slug not found'; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2026 AND venue_id IN (v_cont,v_lido); IF x <> 0 THEN RAISE EXCEPTION 'gap rows exist %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_url = u_scor OR source_url = u_art26 OR source_url = u_lido; IF x <> 0 THEN RAISE EXCEPTION 'URLs already used %', x; END IF;
  IF 'contaminazioni-restaurant' <> (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(name)),'[^a-z0-9]+','-','g')) FROM venues WHERE id=v_cont) THEN RAISE EXCEPTION 'slug rule'; END IF;

  ---------------------------------------------------------------- WRITE 1: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count) VALUES
    (c_trev,  'treviglio',       'Treviglio',       'Italy', 'IT', 'city', NULL, NULL, NULL, 1),
    (c_somma, 'somma-vesuviana', 'Somma Vesuviana', 'Italy', 'IT', 'city', NULL, NULL, NULL, 0);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'city insert %', x; END IF;

  ---------------------------------------------------------------- WRITE 2: Treviglio venue, listing, slug
  INSERT INTO venues (id, name, category, city_id, status) VALUES (v_trev, 'San Martino', 'restaurant', c_trev, 'active');
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'venue insert %', x; END IF;
  INSERT INTO listings (venue_id, property_id, published) VALUES (v_trev, 'eats', true);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'listing insert %', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'treviglio', 'san-martino', v_trev, true);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'slug insert %', x; END IF;

  ---------------------------------------------------------------- WRITE 3: move award 23163
  UPDATE awards SET venue_id = v_trev WHERE id = 23163 AND venue_id = v_scorze AND source_url = u_trev;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'award move %', x; END IF;

  ---------------------------------------------------------------- WRITE 4: 4 new awards
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url) VALUES
    (v_trev,   'michelin', 2025, NULL, 'One Star', NULL, u_art25),
    (v_scorze, 'michelin', 2026, NULL, 'One Star', NULL, u_scor),
    (v_cont,   'michelin', 2026, NULL, 'One Star', NULL, u_art26),
    (v_lido,   'michelin', 2026, NULL, 'One Star', NULL, u_lido);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 4 THEN RAISE EXCEPTION 'award insert %', x; END IF;

  ---------------------------------------------------------------- WRITE 5: price
  INSERT INTO price (venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at)
  VALUES (v_trev, 3, '€€€', 'EUR', 'guide_ingest', 'published_symbol', 'michelin', u_trev, now());
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'price insert %', x; END IF;
  UPDATE price SET source_url = u_scor, captured_at = now() WHERE venue_id = v_scorze AND source_url = u_trev AND tier = 3 AND symbol_raw = '€€€';
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'price update %', x; END IF;

  ---------------------------------------------------------------- WRITE 6: city labels, hand audit
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_label_source', c.id::text, 'UPDATE', to_jsonb(c), jsonb_set(to_jsonb(c), '{{venue_id}}', to_jsonb(v_trev))
    FROM city_label_source c WHERE c.id IN (22976,22977) AND c.venue_id = v_scorze ORDER BY c.id;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'label audit %', x; END IF;
  UPDATE city_label_source SET venue_id = v_trev WHERE id IN (22976,22977) AND venue_id = v_scorze;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'label move %', x; END IF;

  ---------------------------------------------------------------- WRITE 7: alias, hand audit
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row)
  SELECT 'city_aliases', a.alias, 'UPDATE', to_jsonb(a), jsonb_set(to_jsonb(a), '{{city_id}}', to_jsonb(c_trev))
    FROM city_aliases a WHERE a.alias = 'treviglio' AND a.city_id = c_scorze;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'alias audit %', x; END IF;
  UPDATE city_aliases SET city_id = c_trev WHERE alias = 'treviglio' AND city_id = c_scorze;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'alias update %', x; END IF;

  ---------------------------------------------------------------- WRITE 8: Contaminazioni
  UPDATE venues SET city_id = c_somma, status = 'closed' WHERE id = v_cont AND city_id = c_naples AND status = 'active';
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'Contaminazioni update %', x; END IF;
  UPDATE slugs SET is_canonical = false WHERE venue_id = v_cont AND property_id = 'eats' AND city_slug = 'naples' AND slug = 'contaminazioni-restaurant' AND is_canonical;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'old slug %', x; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats', 'somma-vesuviana', 'contaminazioni-restaurant', v_cont, true);
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'new slug %', x; END IF;
  UPDATE cities SET venues_count = 9 WHERE id = c_naples AND venues_count = 10;
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 1 THEN RAISE EXCEPTION 'Naples count %', x; END IF;

  ---------------------------------------------------------------- WRITE 9: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin', 'award', 5, '{JOB_AWARD}'),
    ('michelin', 'price', 2, '{JOB_PRICE}');
  GET DIAGNOSTICS x = ROW_COUNT; IF x <> 2 THEN RAISE EXCEPTION 'ledger insert %', x; END IF;

  ---------------------------------------------------------------- POST gates
  SELECT count(*) INTO x FROM venues;                       IF x <> 11300 THEN RAISE EXCEPTION 'venues after %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE status='active'; IF x <> 10934 THEN RAISE EXCEPTION 'active after %', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> 25082 THEN RAISE EXCEPTION 'awards after %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin'; IF x <> 11378 THEN RAISE EXCEPTION 'michelin after %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND year=2025; IF x <> 4999 THEN RAISE EXCEPTION 'michelin 2025 after %', x; END IF;
  SELECT count(*) INTO x FROM slugs;                        IF x <> 13004 THEN RAISE EXCEPTION 'slugs after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> 1704  THEN RAISE EXCEPTION 'non-canonical after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11300 THEN RAISE EXCEPTION 'canonical after %', x; END IF;
  SELECT count(*) INTO x FROM price;                        IF x <> 7734  THEN RAISE EXCEPTION 'price after %', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> 11300 THEN RAISE EXCEPTION 'listings after %', x; END IF;
  SELECT count(*) INTO x FROM cities;                       IF x <> 3262  THEN RAISE EXCEPTION 'cities after %', x; END IF;
  SELECT count(*) INTO x FROM city_aliases;                 IF x <> 266   THEN RAISE EXCEPTION 'aliases after %', x; END IF;
  SELECT count(*) INTO x FROM city_label_source;            IF x <> 23999 THEN RAISE EXCEPTION 'labels after %', x; END IF;
  SELECT count(*) INTO x FROM redirects;                    IF x <> 9     THEN RAISE EXCEPTION 'redirects after %', x; END IF;
  SELECT sum(venues_count) INTO x FROM cities;              IF x <> 10934 THEN RAISE EXCEPTION 'venues_count sum after %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;        IF x <> 168   THEN RAISE EXCEPTION 'ledger after %', x; END IF;

  SELECT count(*) INTO x FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
   WHERE a.source_id='michelin' AND a.year=2026 AND c.country='Italy' AND a.category='One Star';
  IF x <> 331 THEN RAISE EXCEPTION 'IT 2026 One Star after %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without 1 canonical slug: %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND venue_id=v_scorze AND ((year=2025 AND source_url=u_art25) OR (year=2026 AND source_url=u_scor)) AND category='One Star';
  IF x <> 2 THEN RAISE EXCEPTION 'Scorze rows %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE venue_id=v_scorze; IF x <> 2 THEN RAISE EXCEPTION 'Scorze total rows %', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id='michelin' AND venue_id=v_trev AND category='One Star' AND ((year=2025 AND source_url=u_art25) OR (id=23163 AND year=2026 AND source_url=u_trev));
  IF x <> 2 THEN RAISE EXCEPTION 'Treviglio rows %', x; END IF;
  SELECT count(*) INTO x FROM venues WHERE id=v_cont AND city_id=c_somma AND status='closed' AND name='Contaminazioni Restaurant'; IF x <> 1 THEN RAISE EXCEPTION 'Contaminazioni state'; END IF;
  SELECT count(*) INTO x FROM venues WHERE id=v_lido AND status='closed'; IF x <> 1 THEN RAISE EXCEPTION 'Lido state'; END IF;
  SELECT count(*) INTO x FROM venues WHERE id=v_trev AND norm_key='sanmartino'; IF x <> 1 THEN RAISE EXCEPTION 'Treviglio norm_key'; END IF;
  SELECT count(*) INTO x FROM slugs WHERE venue_id=v_scorze AND city_slug='scorze' AND slug='ristorante-san-martino' AND is_canonical; IF x <> 1 THEN RAISE EXCEPTION 'Scorze canonical'; END IF;
  SELECT count(*) INTO x FROM price WHERE venue_id=v_scorze AND source_url=u_scor AND tier=3; IF x <> 1 THEN RAISE EXCEPTION 'Scorze price'; END IF;
  SELECT count(*) INTO x FROM (SELECT c.id FROM cities c LEFT JOIN venues v ON v.city_id=c.id AND v.status='active' WHERE c.id IN (c_trev,c_somma,c_naples,c_scorze) GROUP BY c.id, c.venues_count HAVING count(v.id) <> c.venues_count) q;
  IF x <> 0 THEN RAISE EXCEPTION 'city counts differ from active venues: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max; IF x <> 19 THEN RAISE EXCEPTION 'audit rows %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='cities'; IF x <> 3 THEN RAISE EXCEPTION 'audit cities %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='venues'; IF x <> 2 THEN RAISE EXCEPTION 'audit venues %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='listings'; IF x <> 1 THEN RAISE EXCEPTION 'audit listings %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='slugs'; IF x <> 3 THEN RAISE EXCEPTION 'audit slugs %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='awards'; IF x <> 5 THEN RAISE EXCEPTION 'audit awards %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='price'; IF x <> 2 THEN RAISE EXCEPTION 'audit price %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='venues' AND action='UPDATE' AND row_pk=v_cont
     AND (old_row-'city_id'-'status')=(new_row-'city_id'-'status') AND old_row->>'status'='active' AND new_row->>'status'='closed' AND new_row->>'city_id'=c_somma;
  IF x <> 1 THEN RAISE EXCEPTION 'audit Contaminazioni update %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name='awards' AND action='UPDATE' AND row_pk='23163'
     AND (old_row-'venue_id')=(new_row-'venue_id') AND new_row->>'venue_id'=v_trev;
  IF x <> 1 THEN RAISE EXCEPTION 'audit award move %', x; END IF;

  -- Stage-job city resolution (resolve.ts: slug, display, alias; then the country): each label must give only the new city.
  WITH lab AS (SELECT * FROM (VALUES ('treviglio'),('somma vesuviana')) v(n_full)),
  cand AS (
    SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.slug)),'[^a-z0-9]+',' ','g'))=h.n_full
    UNION SELECT h.n_full, c.id FROM lab h JOIN cities c ON btrim(regexp_replace(lower(f_unaccent(c.display)),'[^a-z0-9]+',' ','g'))=h.n_full
    UNION SELECT h.n_full, a.city_id FROM lab h JOIN city_aliases a ON a.alias=h.n_full)
  SELECT count(*), min(id), max(id) INTO x, t, t2 FROM cand;
  IF x <> 2 OR t IS DISTINCT FROM c_trev OR t2 IS DISTINCT FROM c_somma THEN RAISE EXCEPTION 'city resolution % / % / %', x, t, t2; END IF;

  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
"""
open(OUT, 'w', encoding='utf8', newline='\n').write(SQL)
print(hashlib.sha256(SQL.encode()).hexdigest(), len(SQL.splitlines()), 'lines')
