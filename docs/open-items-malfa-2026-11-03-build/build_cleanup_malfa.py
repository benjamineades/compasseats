#!/usr/bin/env python3
# Builds ../cleanup-city-malfa-signum-2026-11-03.sql from the relay. URLs, symbol and read time come from the relay, not from typing.
import json, hashlib, pathlib
here = pathlib.Path(__file__).parent
raw = (here/'relay-signum-2026-11-03.txt').read_bytes()
sha = hashlib.sha256(raw).hexdigest()
R = {r['row']: r for r in map(json.loads, raw.decode().splitlines())}
u2560, u2563, u2562 = R[2560]['read_url'], R[2563]['read_url'], R[2562]['read_url']
sym, read_at = R[2563]['price_symbol'], R[2563]['read_at']
assert R[2560]['year']=='2025' and R[2560]['award'].startswith('Two Stars') and '2025 MICHELIN Guide Sweden' in R[2560]['meta']
assert R[2563]['year']=='2026' and R[2563]['award'].startswith('Two Stars') and '2026 MICHELIN Guide Sweden' in R[2563]['meta']
assert R[2562]['rank']==673 and R[2562]['place']=='Malfa Salina, Italy' and R[2562]['signum_lines']==1 and sym=='€€€€'
FP='4195b47e50998c15fce9f0acaad50e99'
J1=f"cleanup:cleanup-city-malfa-signum-2026-11-03 | open item 1: Michelin rows of Signum Molnlycke ve_a6a92ff828 | award 2560 URL archive capture 20251215153620 (window Jun 16 2025 to Jun 1 2026) | award 2563 URL live card | award 2561 deleted: One Star 2025 of Signum Malfa, copy of 31915 on ve_69b7b57435 (repo snapshot 3d56c74, Jun 7 2026, labels it Malfa, Italy) | relay docs/open-items-malfa-2026-11-03-build/relay-signum-2026-11-03.txt sha256 {sha}"
J2=f"cleanup:cleanup-city-malfa-signum-2026-11-03 | open item 1: OAD Europe 2025 No. 673 moved from ve_a6a92ff828 to Signum Malfa ve_69b7b57435 | list prints Signum, Malfa Salina, Italy, Martina Caruso | {u2562} | relay sha256 {sha}"
J3=f"price-card:cleanup-city-malfa-signum-2026-11-03 | open item 1: ve_a6a92ff828 legacy $$$$ replaced by the 2026 card {sym} (Sep 28 ruling) | {u2563} | relay sha256 {sha}"
q=lambda s:"'"+s.replace("'","''")+"'"
sql=f"""-- cleanup-city-malfa-signum-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open item 1. Population: city ci_ef76cfb9a4, venue ve_a6a92ff828 (4 awards, 1 slug, 1 price), plus venue ve_69b7b57435 (receives 1 award).
-- City slug malfa becomes molnlycke. Old URL gets a redirect (Sep 14 slug-split form). Venue name does not change in this file.
-- Awards: 2560 and 2563 get a URL. 2561 is deleted (copy of 31915). 2562 moves to the Italian Signum with a URL. Price: card replaces legacy.
-- Expected after: awards 25323; Michelin 2025 no URL 3033; Michelin 2026 no URL 436; redirects 10; price 7759 (legacy_guide 2179); ledger 198 rows; audit +8 (120034 rows).
BEGIN;
DO $do$
DECLARE n int; x bigint; fp text; aud_max bigint; aud_n bigint;
BEGIN
  SELECT md5(t) INTO fp FROM (SELECT
    (SELECT c.id||'|'||c.slug||'|'||c.display||'|'||c.country_iso FROM cities c WHERE c.id='ci_ef76cfb9a4') || E'\\n' ||
    (SELECT string_agg(a.id||'|'||a.venue_id||'|'||a.source_id||'|'||a.year||'|'||a.category||'|'||coalesce(a.rank::text,'')||'|'||coalesce(a.source_url,''), E'\\n' ORDER BY a.id) FROM awards a WHERE a.venue_id='ve_a6a92ff828') || E'\\n' ||
    (SELECT s.city_slug||'|'||s.slug||'|'||s.venue_id||'|'||s.is_canonical FROM slugs s WHERE s.venue_id='ve_a6a92ff828') || E'\\n' ||
    (SELECT p.venue_id||'|'||p.tier||'|'||p.symbol_raw||'|'||p.source FROM price p WHERE p.venue_id='ve_a6a92ff828') AS t) q;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'plan fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM cities WHERE slug='molnlycke') <> 0 THEN RAISE EXCEPTION 'molnlycke in use'; END IF;
  IF (SELECT count(*) FROM slugs WHERE city_slug='molnlycke') <> 0 THEN RAISE EXCEPTION 'molnlycke slugs in use'; END IF;
  IF (SELECT count(*) FROM slugs WHERE city_slug='malfa') <> 1 THEN RAISE EXCEPTION 'malfa slugs'; END IF;
  IF (SELECT count(*) FROM redirects WHERE from_path='/malfa/restaurang-signum' OR to_path LIKE '/malfa/%') <> 0 THEN RAISE EXCEPTION 'redirect in use'; END IF;
  IF (SELECT count(*) FROM awards WHERE id=31915 AND venue_id='ve_69b7b57435' AND source_id='michelin' AND year=2025 AND category='One Star' AND source_url LIKE 'https://web.archive.org/%') <> 1 THEN RAISE EXCEPTION 'twin 31915'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id='ve_69b7b57435' AND source_id='oad') <> 0 THEN RAISE EXCEPTION 'Italian Signum has an OAD row'; END IF;
  IF (SELECT count(*) FROM awards) <> 25324 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3035 THEN RAISE EXCEPTION '2025 no URL before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 437 THEN RAISE EXCEPTION '2026 no URL before'; END IF;
  IF (SELECT count(*) FROM redirects) <> 9 THEN RAISE EXCEPTION 'redirects before'; END IF;
  IF (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM price WHERE source='legacy_guide') <> 2180 THEN RAISE EXCEPTION 'price before'; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM slugs) <> 13166 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 195 OR (SELECT max(id) FROM source_capture_ledger) <> 249 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 120026 OR aud_max <> 125855 THEN RAISE EXCEPTION 'audit before % / %', aud_n, aud_max; END IF;

  UPDATE cities SET slug='molnlycke' WHERE id='ci_ef76cfb9a4' AND slug='malfa';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city %', n; END IF;
  UPDATE slugs SET city_slug='molnlycke' WHERE property_id='eats' AND city_slug='malfa' AND slug='restaurang-signum' AND venue_id='ve_a6a92ff828' AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slug %', n; END IF;
  INSERT INTO redirects (from_path, to_path) VALUES ('/malfa/restaurang-signum','/molnlycke/restaurang-signum');
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) VALUES ('redirects','/malfa/restaurang-signum','INSERT',NULL,jsonb_build_object('from_path','/malfa/restaurang-signum','to_path','/molnlycke/restaurang-signum'));

  UPDATE awards SET source_url={q(u2560)} WHERE id=2560 AND venue_id='ve_a6a92ff828' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '2560 %', n; END IF;
  UPDATE awards SET source_url={q(u2563)} WHERE id=2563 AND venue_id='ve_a6a92ff828' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '2563 %', n; END IF;
  DELETE FROM awards WHERE id=2561 AND venue_id='ve_a6a92ff828' AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '2561 %', n; END IF;
  UPDATE awards SET venue_id='ve_69b7b57435', source_url={q(u2562)} WHERE id=2562 AND venue_id='ve_a6a92ff828' AND source_id='oad' AND rank=673 AND source_url IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION '2562 %', n; END IF;
  UPDATE price SET symbol_raw={q(sym)}, currency='EUR', source='guide_ingest', publisher='michelin', source_url={q(u2563)}, captured_at={q(read_at)}::timestamptz
   WHERE venue_id='ve_a6a92ff828' AND source='legacy_guide' AND tier=4;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'price %', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',3,{q(J1)}),
    ('oad','award',1,{q(J2)}),
    ('michelin','price',1,{q(J3)});

  IF (SELECT count(*) FROM awards) <> 25323 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025 AND source_url IS NULL) <> 3033 THEN RAISE EXCEPTION '2025 no URL after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026 AND source_url IS NULL) <> 436 THEN RAISE EXCEPTION '2026 no URL after'; END IF;
  IF (SELECT count(*) FROM redirects) <> 10 THEN RAISE EXCEPTION 'redirects after'; END IF;
  IF (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM price WHERE source='legacy_guide') <> 2179 THEN RAISE EXCEPTION 'price after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM slugs) <> 13166 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11320 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM slugs WHERE city_slug='malfa') <> 0 THEN RAISE EXCEPTION 'malfa slugs after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 11028 THEN RAISE EXCEPTION 'venues_count after'; END IF;
  SELECT count(*) INTO x FROM cities c JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM k.active_venues; IF x <> 0 THEN RAISE EXCEPTION 'cities differ %', x; END IF;
  SELECT count(*) INTO x FROM awards a WHERE a.venue_id='ve_a6a92ff828'; IF x <> 2 THEN RAISE EXCEPTION 'Swedish awards %', x; END IF;
  SELECT count(*) INTO x FROM awards a WHERE a.venue_id='ve_69b7b57435'; IF x <> 4 THEN RAISE EXCEPTION 'Italian awards %', x; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 198 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max; IF x <> 8 THEN RAISE EXCEPTION 'audit %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max AND table_name='awards' AND action='UPDATE'; IF x <> 3 THEN RAISE EXCEPTION 'audit award update %', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max AND table_name='awards' AND action='DELETE' AND row_pk='2561'; IF x <> 1 THEN RAISE EXCEPTION 'audit award delete %', x; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
(here.parent/'cleanup-city-malfa-signum-2026-11-03.sql').write_text(sql,encoding='utf8')
print(sha)
