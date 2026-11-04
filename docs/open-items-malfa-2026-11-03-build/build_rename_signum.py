#!/usr/bin/env python3
# Builds the fixture and ../rename-signum-molnlycke-2026-11-03.sql. Card URL and name come from the relay, not from typing.
import json, hashlib, pathlib, csv, io
here = pathlib.Path(__file__).parent; root = here.parent.parent
raw = (here/'relay-signum-2026-11-03.txt').read_bytes(); sha = hashlib.sha256(raw).hexdigest()
R = {r['row']: r for r in map(json.loads, raw.decode().splitlines())}
card, new = R[2563]['read_url'], R[2563]['name']
assert new == 'Signum'
key, vid, old = 'rename-signum-molnlycke-2026-11-03', 've_a6a92ff828', 'Restaurang Signum'
note = f'Open item 1; live "{old}" (Google place name); Michelin card name "{new}"; venue page "Restaurant Signum", menu "Menu Signum"; after award 2562 moves, Michelin is the only publisher (Sep 14 ruling); relay sha256 {sha}; Ben Nov 3 19:05 ET "1A, 2A"'
b = io.StringIO(); w = csv.writer(b, lineterminator='\n')
w.writerow(['batch_key','venue_id','expected_name','new_name','source_id','source_url','note']); w.writerow([key,vid,old,new,'michelin',card,note])
(root/'fixtures/rename/signum-molnlycke-2026-11-03.csv').write_text(b.getvalue(), encoding='utf8')
q = lambda s: "'"+s.replace("'","''")+"'"
batch_note = f'Open item 1, Signum Molnlycke: {old} to {new}; relay docs/open-items-malfa-2026-11-03-build/relay-signum-2026-11-03.txt; Ben Nov 3 19:05 ET "1A, 2A"'
job = f'rename-apply:{key} | gated SQL file docs/rename-signum-molnlycke-2026-11-03.sql (Write connector), same writes as the job | {card} | Ben Nov 3 19:05 ET "1A, 2A"'
sql = f"""-- rename-signum-molnlycke-2026-11-03.sql
-- CompassEats, Nov 3 2026. Open item 1, Ben choice 1A. Population: 1 venue, ve_a6a92ff828.
-- Run ONLY after docs/cleanup-city-malfa-signum-2026-11-03.sql. Its end state is the guard here.
-- Name "{old}" becomes "{new}". New canonical slug /molnlycke/signum. Old slug /molnlycke/restaurang-signum stays non-canonical and keeps working.
-- Redirect /malfa/restaurang-signum now points to /molnlycke/signum (no second hop). Same writes as scripts/rename/apply.ts plus the slug step.
-- Expected after: rename_batches 32; rename_rows 1397; slugs 13167 (non-canonical 1847); ledger 199; audit +4 (120038 rows).
BEGIN;
DO $do$
DECLARE bid bigint; n int; x bigint; aud_max bigint; aud_n bigint; led_n bigint; led_max bigint;
BEGIN
  IF (SELECT count(*) FROM rename_batches WHERE batch_key={q(key)}) <> 0 THEN RAISE EXCEPTION 'batch key used'; END IF;
  IF (SELECT count(*) FROM rename_rows WHERE venue_id={q(vid)}) <> 0 THEN RAISE EXCEPTION 'earlier rename rows'; END IF;
  IF (SELECT count(*) FROM venues WHERE id={q(vid)} AND name={q(old)} AND status='active' AND city_id='ci_ef76cfb9a4') <> 1 THEN RAISE EXCEPTION 'venue before'; END IF;
  IF (SELECT count(*) FROM cities WHERE id='ci_ef76cfb9a4' AND slug='molnlycke') <> 1 THEN RAISE EXCEPTION 'run the cleanup file first'; END IF;
  IF (SELECT count(*) FROM slugs WHERE venue_id={q(vid)}) <> 1 OR (SELECT count(*) FROM slugs WHERE venue_id={q(vid)} AND city_slug='molnlycke' AND slug='restaurang-signum' AND is_canonical) <> 1 THEN RAISE EXCEPTION 'slug before'; END IF;
  IF (SELECT count(*) FROM slugs WHERE property_id='eats' AND city_slug='molnlycke' AND slug='signum') <> 0 THEN RAISE EXCEPTION 'new slug in use'; END IF;
  IF (SELECT count(*) FROM redirects WHERE from_path='/malfa/restaurang-signum' AND to_path='/molnlycke/restaurang-signum') <> 1 THEN RAISE EXCEPTION 'redirect before'; END IF;
  IF (SELECT count(*) FROM redirects WHERE from_path IN ('/molnlycke/signum','/molnlycke/restaurang-signum')) <> 0 THEN RAISE EXCEPTION 'redirect loop'; END IF;
  IF (SELECT count(*) FROM blurbs WHERE venue_id={q(vid)}) <> 0 THEN RAISE EXCEPTION 'blurb'; END IF;
  IF (SELECT count(*) FROM awards WHERE venue_id={q(vid)} AND source_id<>'michelin') <> 0 OR (SELECT count(*) FROM awards WHERE venue_id={q(vid)}) <> 2 THEN RAISE EXCEPTION 'publishers on the venue'; END IF;
  SELECT count(*) INTO x FROM venues o WHERE o.city_id='ci_ef76cfb9a4' AND o.id<>{q(vid)} AND norm_key(o.name)=norm_key({q(new)}); IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key %', x; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM awards) <> 25323 OR (SELECT count(*) FROM listings) <> 11320 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 10 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13166 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1846 THEN RAISE EXCEPTION 'slugs before'; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 31 OR (SELECT count(*) FROM rename_rows) <> 1396 THEN RAISE EXCEPTION 'rename before'; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger; IF led_n <> 198 THEN RAISE EXCEPTION 'ledger before %', led_n; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log; IF aud_n <> 120034 THEN RAISE EXCEPTION 'audit before %', aud_n; END IF;

  INSERT INTO rename_batches (batch_key, status, note) VALUES ({q(key)}, 'staged', {q(batch_note)}) RETURNING id INTO bid;
  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, 1, v.id, {q(old)}, {q(new)}, 'michelin', {q(card)}, 'rename',
         jsonb_build_object('note', {q(note)}, 'live_name', v.name, 'city_id', v.city_id, 'city_slug', s.city_slug, 'slug', s.slug)
    FROM venues v JOIN slugs s ON s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical WHERE v.id={q(vid)};
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'rename_rows %', n; END IF;
  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues SET name={q(new)} WHERE id={q(vid)} AND name={q(old)};
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 1 THEN RAISE EXCEPTION 'renamed %', n; END IF;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin','name',1,{q(job)});
  UPDATE rename_batches SET status='applied', applied_at=now() WHERE id=bid AND status='staged';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'batch status %', n; END IF;

  UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND city_slug='molnlycke' AND slug='restaurang-signum' AND venue_id={q(vid)} AND is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'old slug %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) VALUES ('eats','molnlycke','signum',{q(vid)},true);
  INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) VALUES ('redirects','/malfa/restaurang-signum','UPDATE',
    jsonb_build_object('from_path','/malfa/restaurang-signum','to_path','/molnlycke/restaurang-signum'), jsonb_build_object('from_path','/malfa/restaurang-signum','to_path','/molnlycke/signum'));
  UPDATE redirects SET to_path='/molnlycke/signum' WHERE from_path='/malfa/restaurang-signum' AND to_path='/molnlycke/restaurang-signum';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'redirect %', n; END IF;

  IF (SELECT count(*) FROM venues WHERE id={q(vid)} AND name={q(new)} AND norm_key='signum') <> 1 THEN RAISE EXCEPTION 'name after'; END IF;
  IF (SELECT count(*) FROM venues) <> 11320 OR (SELECT count(*) FROM awards) <> 25323 OR (SELECT count(*) FROM listings) <> 11320 OR (SELECT count(*) FROM blurbs) <> 142 OR (SELECT count(*) FROM redirects) <> 10 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13167 OR (SELECT count(*) FROM slugs WHERE NOT is_canonical) <> 1847 OR (SELECT count(*) FROM slugs WHERE is_canonical) <> 11320 THEN RAISE EXCEPTION 'slugs after'; END IF;
  SELECT count(*) INTO x FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF x <> 0 THEN RAISE EXCEPTION 'canonical %', x; END IF;
  IF (SELECT count(*) FROM rename_batches) <> 32 OR (SELECT count(*) FROM rename_rows) <> 1397 THEN RAISE EXCEPTION 'rename after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 199 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id>aud_max; IF x <> 4 THEN RAISE EXCEPTION 'audit %', x; END IF;
  SELECT count(*) INTO x FROM audit_log a WHERE a.id>aud_max AND a.table_name='venues' AND a.action='UPDATE' AND a.row_pk={q(vid)} AND a.old_row->>'name'={q(old)} AND a.new_row->>'name'={q(new)} AND (a.old_row-'name'-'norm_key')=(a.new_row-'name'-'norm_key');
  IF x <> 1 THEN RAISE EXCEPTION 'audit rename %', x; END IF;
END
$do$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
(here.parent/'rename-signum-molnlycke-2026-11-03.sql').write_text(sql, encoding='utf8')
