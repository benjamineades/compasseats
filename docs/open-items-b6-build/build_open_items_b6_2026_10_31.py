#!/usr/bin/env python3
"""Build the 3 SQL files of open items block 6 (Oct 31, 2026) from relay.txt.

Usage: python3 build_open_items_b6_2026_10_31.py <relay.txt> <out_dir> [test]
  test = write pre-check test copies of files 2 and 3 with today's counts (before file 1), for the Read connector.
No name is typed in this script: every name, URL and note comes from relay.txt.
"""
import hashlib, sys, os, re

relay_path, out_dir = sys.argv[1], sys.argv[2]
TEST = len(sys.argv) > 3 and sys.argv[3] == 'test'
raw = open(relay_path, encoding='utf-8').read()
lines = [l for l in raw.split('\n') if l]

def md5(s): return hashlib.md5(s.encode('utf-8')).hexdigest()
def q(s): return "'" + s.replace("'", "''") + "'"

ren = [l.split('|') for l in lines if l.startswith('ren|')]
st  = [l.split('|') for l in lines if l.startswith('status|')]
aw  = [l.split('|') for l in lines if l.startswith('award|')]
ct  = [l.split('|') for l in lines if l.startswith('count|')]
assert len(ren) == 5 and len(st) == 1 and len(aw) == 1 and len(ct) == 1

R = [dict(line=int(r[1]), vid=r[2], exp=r[3], new=r[4], src=r[5], url=r[6], note=r[7]) for r in ren]
byid = sorted(R, key=lambda r: r['vid'])
G_LIVE = md5('\n'.join(f"{r['vid']}|{r['exp']}" for r in byid))
G_NEW  = md5('\n'.join(f"{r['vid']}|{r['new']}" for r in byid))
G_ROWS = md5('\n'.join(f"{r['line']}|{r['vid']}|{r['exp']}|{r['new']}|{r['src']}|{r['url']}" for r in byid))
G_NOTE = md5('\n'.join(f"{r['vid']}|{r['note']}" for r in byid))
RELAY_SHA = hashlib.sha256(raw.encode('utf-8')).hexdigest()

# slug plan: city slug and old canonical slug from the Oct 31 06:01 UTC read
CITY = {'ve_542c195114': ('carmignano', 'paca-ristorante'),
        've_e50adc624d': ('fuencaliente-de-la-palma', 'restaurante-tematico-el-jardin-de-la-sal'),
        've_eef796a74d': ('quartu-sant-elena', 'coxinendi-ristorante'),
        've_f558535881': ('telese', 'kresios'),
        've_f88a5d9dc2': ('hong-kong', 'duddell-s-bar')}
import unicodedata
def slugify(n):
    s = unicodedata.normalize('NFKD', n)
    s = ''.join(ch for ch in s if not unicodedata.combining(ch)).lower()
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')
SP = []
for r in byid:
    city, old = CITY[r['vid']]
    new = slugify(r['new'])
    if new != old:
        SP.append((r['vid'], r['new'], city, old, new))
assert len(SP) == 4, SP
FP_SLUG = md5('\n'.join('|'.join(x) for x in SP))

# ---------- counts (live read Oct 31 06:01:40 UTC) ----------
C0 = dict(venues=11303, awards=23362, slugs=12940, noncanon=1637, listings=11303, blurbs=142, closed=369,
          rb=17, rr=1196, led_n=128, led_max=172, aud_n=114109, aud_max=119393, price=7731, vc_sum=10934)
C1 = dict(C0, rb=18, rr=1201, led_n=130, led_max=174, aud_n=114114, aud_max=119398)       # after file 1
C2 = dict(C1, slugs=12944, noncanon=1641, aud_n=114122, aud_max=119406)                  # after file 2
pre2 = C0 if TEST else C1
pre3 = C0 if TEST else C2

hdr_common = "-- Ben: Oct 31 01:56 ET \"1, 2A, 2B\"; 02:01 ET \"Your recommendation for everything\" (D1-D5 = A).\n"

# ======================= FILE 1: rename =======================
vals = ',\n'.join('    (%d, %s, %s, %s, %s, %s, %s)' % (r['line'], q(r['vid']), q(r['exp']), q(r['new']), q(r['src']), q(r['url']), q(r['note'])) for r in R)
f1 = f"""-- rename-open-items-b6-2026-10-31.sql
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 6, file 1 of 3: rename batch rename-open-items-b6-2026-10-31 (5 venues).
{hdr_common}-- D1: Kresios -> Krèsios (R1), Paca Ristorante -> Paca (R2), Coxinendi - Ristorante -> Coxinendi (R5),
--     Restaurante Temático El Jardín de la Sal -> El Jardín de la Sal (R2 + R3).
-- D2: Duddell's bar ve_f88a5d9dc2 -> The Upper Room at Duddell’s (R2 + R3 + R6; not a duplicate of the restaurant).
-- Built by script docs/open-items-b6-build/build_open_items_b6_2026_10_31.py from docs/open-items-b6-build/relay.txt
-- (sha256 {RELAY_SHA}). Template: docs/rename-open-items-b1-2026-10-30.sql (same writes as scripts/rename/apply.ts).
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   {G_LIVE}  (fresh read 2026-10-31 06:01:40 UTC)
--   id|new_name                 {G_NEW}
--   line|id|expected|new|source|url  {G_ROWS}
--   id|note                     {G_NOTE}
-- Expected after: rename_batches 17 -> 18 (applied, id 32), rename_rows 1196 -> 1201, ledger +2 (172 -> 174: michelin name 4,
-- pinnacle-guide name 1), audit_log +5 (119393 -> 119398; 5 venues UPDATE, name and norm_key only).
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT.

BEGIN;
DO $do$
DECLARE
  plan     jsonb;
  bid      bigint;
  n        int;
  x        int;
  aud_max  bigint;
  aud_n    bigint;
  led_n    bigint;
  led_max  bigint;
BEGIN
  -- 1. Inputs
  SELECT jsonb_agg(jsonb_build_object('line', t.line, 'venue_id', t.venue_id, 'expected_name', t.expected_name,
           'new_name', t.new_name, 'source_id', t.source_id, 'source_url', t.source_url, 'note', t.note) ORDER BY t.line)
    INTO plan
  FROM (VALUES
{vals}
  ) AS t(line, venue_id, expected_name, new_name, source_id, source_url, note);

  SELECT count(*), count(DISTINCT p.venue_id) INTO n, x FROM jsonb_to_recordset(plan) p(venue_id text);
  IF n <> 5 OR x <> 5 THEN RAISE EXCEPTION 'input rows % / distinct venues % (expected 5 / 5)', n, x; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.expected_name, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text)) <> '{G_LIVE}' THEN
    RAISE EXCEPTION 'input guard id|expected_name failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.new_name, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)) <> '{G_NEW}' THEN
    RAISE EXCEPTION 'input guard id|new_name failed'; END IF;
  IF (SELECT md5(string_agg(p.line||'|'||p.venue_id||'|'||p.expected_name||'|'||p.new_name||'|'||p.source_id||'|'||p.source_url,
                            E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text, source_id text, source_url text))
       <> '{G_ROWS}' THEN
    RAISE EXCEPTION 'input guard rows failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.note, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, note text)) <> '{G_NOTE}' THEN
    RAISE EXCEPTION 'input guard notes failed'; END IF;

  -- 2. Pre-checks against live data
  SELECT count(*) INTO x FROM rename_batches WHERE batch_key = 'rename-open-items-b6-2026-10-31';
  IF x <> 0 THEN RAISE EXCEPTION 'batch key already used: %', x; END IF;

  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{G_LIVE}' THEN
    RAISE EXCEPTION 'live names differ from the Oct 31 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> 5 THEN RAISE EXCEPTION 'active venues % (expected 5)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text, source_url text)
   WHERE NOT ((p.source_id = 'michelin' AND p.source_url ~ '^https://guide\\.michelin\\.com/')
           OR (p.source_id = 'pinnacle-guide' AND p.source_url ~ '^https://www\\.thepinnacleguide\\.com/'))
      OR p.source_url ~* '(joinpearl|thebestrestaurantsguide|beliapp)';
  IF x <> 0 THEN RAISE EXCEPTION 'bad source_id or source_url: %', x; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug IN ('michelin', 'pinnacle-guide');
  IF x <> 2 THEN RAISE EXCEPTION 'michelin / pinnacle-guide not registered in award_sources'; END IF;

  SELECT count(*) INTO x FROM rename_rows r JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = r.venue_id;
  IF x <> 0 THEN RAISE EXCEPTION 'earlier rename_rows on these venues: %', x; END IF;

  -- same-city norm_key collisions on the end state (scripts/rename/lib/impact.ts rule)
  WITH batch AS (SELECT p.venue_id, p.new_name FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)),
       scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
       fin   AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
                   FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id)
  SELECT count(*) INTO x FROM fin a JOIN batch ON batch.venue_id = a.id
    JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id
              AND norm_key(a.name) IS NOT NULL AND norm_key(o.name) = norm_key(a.name);
  IF x <> 0 THEN RAISE EXCEPTION 'same-city norm_key collisions: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text)
   WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id = p.venue_id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug: %', x; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> {C0['venues']} THEN RAISE EXCEPTION 'venues before %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {C0['awards']} THEN RAISE EXCEPTION 'awards before %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {C0['slugs']} THEN RAISE EXCEPTION 'slugs before %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {C0['listings']} THEN RAISE EXCEPTION 'listings before %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {C0['blurbs']} THEN RAISE EXCEPTION 'blurbs before %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {C0['rb']} THEN RAISE EXCEPTION 'rename_batches before %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {C0['rr']} THEN RAISE EXCEPTION 'rename_rows before %', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {C0['led_n']} OR led_max <> {C0['led_max']} THEN RAISE EXCEPTION 'ledger before % rows, last id %', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {C0['aud_n']} OR aud_max <> {C0['aud_max']} THEN
    RAISE EXCEPTION 'audit_log before % rows, last id %', aud_n, aud_max; END IF;

  -- 3. Writes (same order as the rename job)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('rename-open-items-b6-2026-10-31', 'staged', 'Open items block 6 (Oct 31): 4 Michelin card name differences (Krèsios, Paca, Coxinendi, El Jardín de la Sal; rules R1-R5) and the Duddell''s bar -> The Upper Room at Duddell’s (site + Pinnacle Guide). Ben "Your recommendation for everything" Oct 31 02:01 ET. Run as a gated SQL file through the Write connector, not the rename job; same writes as scripts/rename/apply.ts.')
  RETURNING id INTO bid;

  INSERT INTO rename_rows (batch_id, line, venue_id, expected_name, new_name, source_id, source_url, verdict, detail)
  SELECT bid, p.line, p.venue_id, p.expected_name, p.new_name, p.source_id, p.source_url, 'rename',
         jsonb_build_object('note', p.note, 'live_name', v.name, 'city_id', v.city_id,
                            'city_slug', s.city_slug, 'slug', s.slug)
    FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text,
                                    source_id text, source_url text, note text)
    JOIN venues v ON v.id = p.venue_id
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 5 THEN RAISE EXCEPTION 'rename_rows inserted % (expected 5)', n; END IF;

  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = p.new_name
    FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
   WHERE v.id = p.venue_id AND v.name = p.expected_name;
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 5 THEN RAISE EXCEPTION 'venues renamed % (expected 5)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 4, 'rename-apply:rename-open-items-b6-2026-10-31 | gated SQL file docs/rename-open-items-b6-2026-10-31.sql (Write connector), same writes as the job | 4 rows follow the Michelin 2026 card and the venue site, rules R1-R5 (Krèsios, Paca, Coxinendi, El Jardín de la Sal)');
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('pinnacle-guide', 'name', 1, 'rename-apply:rename-open-items-b6-2026-10-31 | gated SQL file docs/rename-open-items-b6-2026-10-31.sql (Write connector), same writes as the job | ve_f88a5d9dc2 Duddell''s (bar) -> The Upper Room at Duddell’s: venue site + Pinnacle Guide 2026, rules R2 + R3 + R6');

  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'batch status update % (expected 1)', n; END IF;

  -- 4. Post-checks (the job's invariants)
  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text, new_name text) ON p.venue_id = v.id
   WHERE v.name IS DISTINCT FROM p.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'venues whose live name is not new_name: %', x; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{G_NEW}' THEN
    RAISE EXCEPTION 'live id|name after differs from the file'; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> {C0['venues']} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {C0['awards']} THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {C0['slugs']} THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {C0['listings']} THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {C0['blurbs']} THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {C1['rb']} THEN RAISE EXCEPTION 'rename_batches after %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {C1['rr']} THEN RAISE EXCEPTION 'rename_rows after %', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> 5 THEN RAISE EXCEPTION 'rename_rows in this batch % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> {C1['led_n']} THEN RAISE EXCEPTION 'ledger after %', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND field_type = 'name' AND job LIKE 'rename-apply:rename-open-items-b6-2026-10-31 |%'
     AND ((publisher = 'michelin' AND items = 4) OR (publisher = 'pinnacle-guide' AND items = 1));
  IF x <> 2 THEN RAISE EXCEPTION 'ledger rows for this batch % (expected 2)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 5 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
      ON a.row_pk = p.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.at = transaction_timestamp()
     AND a.old_row->>'name' = p.expected_name AND a.new_row->>'name' = p.new_name
     AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key');
  IF x <> 5 THEN RAISE EXCEPTION 'audit venue renames (name and norm_key only) % (expected 5)', x; END IF;
END
$do$;
COMMIT;
"""

# ======================= FILE 2: slugs =======================
plan_lines = '\n'.join(f"--   {x[0]} {x[1]}: {x[2]}/{x[3]} -> {x[2]}/{x[4]} (insert)" for x in SP)
f2 = f"""-- slugs-rename-open-items-b6-2026-10-31.sql{' (PRE-CHECK TEST COPY: counts before file 1; dry run only)' if TEST else ''}
-- CompassEats, Oct 31 2026. New canonical slugs for the venues renamed by rename-open-items-b6-2026-10-31
-- (docs/rename-open-items-b6-2026-10-31.sql). Run only after that batch is applied. File 2 of 3.
{hdr_common}-- Template: docs/slugs-rename-open-items-b1-2026-10-30.sql. Built by script docs/open-items-b6-build/build_open_items_b6_2026_10_31.py.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')), Ben's option A (Oct 8).
-- Krèsios keeps telese/kresios (the rule gives the same slug). Plan: 4 rows, 0 reuse, 4 inserts.
{plan_lines}
-- Each old canonical row becomes non-canonical (old URL stays and points to the same venue). No delete, no ledger row.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id): {FP_SLUG}
-- Expected before: slugs {pre2['slugs']} (non-canonical {pre2['noncanon']}); audit_log {pre2['aud_n']} rows, last id {pre2['aud_max']}.
-- Expected after: slugs {pre2['slugs']+4}, non-canonical {pre2['noncanon']+4}, canonical 11303; audit +8 (4 UPDATE + 4 INSERT).
-- Dry run: send through the Read connector after the rename. It stops at the first UPDATE.

BEGIN;
DO $do$
DECLARE
  plan        jsonb;
  n_plan      int;
  n_all       int;
  n_same      int;
  fp          text;
  bid         bigint;
  n           int;
  x           int;
  aud_max     bigint;
  aud_n       bigint;
BEGIN
  -- 1. Build the plan from live data
"""
if TEST:
    f2 += """  -- TEST COPY: the plan is built from the relay names (the rename is not applied yet).
  SELECT NULL::bigint INTO bid;
  WITH r(venue_id, new_name) AS (VALUES
""" + ',\n'.join(f"    ({q(r['vid'])}, {q(r['new'])})" for r in byid) + """),
  q AS (SELECT v.id AS venue_id, r.new_name AS name, s.city_slug, s.slug AS old_slug,
               trim(both '-' from regexp_replace(lower(f_unaccent(r.new_name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
          FROM r JOIN venues v ON v.id = r.venue_id
          JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical)
  SELECT count(*), count(*) FILTER (WHERE new_slug = old_slug) INTO n_all, n_same FROM q;
  WITH r(venue_id, new_name) AS (VALUES
""" + ',\n'.join(f"    ({q(r['vid'])}, {q(r['new'])})" for r in byid) + """),
  q AS (SELECT v.id AS venue_id, r.new_name AS name, s.city_slug, s.slug AS old_slug,
               trim(both '-' from regexp_replace(lower(f_unaccent(r.new_name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
          FROM r JOIN venues v ON v.id = r.venue_id
          JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical)
"""
else:
    f2 += """  SELECT count(*), max(id) INTO x, bid FROM rename_batches WHERE status = 'applied' AND batch_key = 'rename-open-items-b6-2026-10-31';
  IF x <> 1 THEN RAISE EXCEPTION 'rename batch rename-open-items-b6-2026-10-31 applied: % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid;
  IF x <> 5 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 5)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows r JOIN venues v ON v.id = r.venue_id
   WHERE r.batch_id = bid AND v.name IS DISTINCT FROM r.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'batch venues whose live name is not new_name: %', x; END IF;

  WITH q AS (SELECT v.id AS venue_id, v.name, s.city_slug, s.slug AS old_slug,
               trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
          FROM rename_rows r JOIN venues v ON v.id = r.venue_id
          JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
         WHERE r.batch_id = bid)
  SELECT count(*), count(*) FILTER (WHERE new_slug = old_slug) INTO n_all, n_same FROM q;
  WITH q AS (SELECT v.id AS venue_id, v.name, s.city_slug, s.slug AS old_slug,
               trim(both '-' from regexp_replace(lower(f_unaccent(v.name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
          FROM rename_rows r JOIN venues v ON v.id = r.venue_id
          JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
         WHERE r.batch_id = bid)
"""
f2 += f"""  SELECT jsonb_agg(jsonb_build_object('venue_id', venue_id, 'city_slug', city_slug, 'old_slug', old_slug, 'new_slug', new_slug)
           ORDER BY venue_id),
         count(*),
         md5(string_agg(venue_id||'|'||name||'|'||city_slug||'|'||old_slug||'|'||new_slug, E'\\n' ORDER BY venue_id))
    INTO plan, n_plan, fp
    FROM q WHERE new_slug <> old_slug;

  -- 2. Pre-checks
  IF n_all <> 5 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 5)', n_all; END IF;
  IF n_same <> 1 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 1, Krèsios)', n_same; END IF;
  IF n_plan <> 4 THEN RAISE EXCEPTION 'plan rows % (expected 4)', n_plan; END IF;
  IF fp <> '{FP_SLUG}' THEN RAISE EXCEPTION 'plan fingerprint % differs from the Oct 31 read', fp; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(old_slug text, new_slug text)
   WHERE p.new_slug = '' OR p.new_slug = p.old_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'empty or unchanged new slugs: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs already in slugs (expected 0, all inserts): %', x; END IF;

  SELECT count(*) INTO x FROM redirects d, jsonb_to_recordset(plan) p(city_slug text, new_slug text)
   WHERE d.from_path IN ('/'||p.city_slug||'/'||p.new_slug, '/venue/'||p.city_slug||'/'||p.new_slug);
  IF x <> 0 THEN RAISE EXCEPTION 'new paths already in redirects: %', x; END IF;

  SELECT count(*) INTO x FROM (
    SELECT venue_id FROM slugs WHERE property_id = 'eats' AND is_canonical
    GROUP BY venue_id HAVING count(*) <> 1) m;
  IF x <> 0 THEN RAISE EXCEPTION 'venues with more than 1 canonical slug before: %', x; END IF;

  SELECT count(*) INTO x FROM slugs;                        IF x <> {pre2['slugs']} THEN RAISE EXCEPTION 'slugs before %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> {pre2['noncanon']} THEN RAISE EXCEPTION 'non-canonical before %', x; END IF;
  SELECT count(*) INTO x FROM venues;                       IF x <> {pre2['venues']} THEN RAISE EXCEPTION 'venues before %', x; END IF;
  SELECT count(*) INTO x FROM awards;                       IF x <> {pre2['awards']} THEN RAISE EXCEPTION 'awards before %', x; END IF;
  SELECT count(*) INTO x FROM listings;                     IF x <> {pre2['listings']} THEN RAISE EXCEPTION 'listings before %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;                       IF x <> {pre2['blurbs']} THEN RAISE EXCEPTION 'blurbs before %', x; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {pre2['aud_n']} THEN RAISE EXCEPTION 'audit_log before %', aud_n; END IF;
  IF aud_max <> {pre2['aud_max']} THEN RAISE EXCEPTION 'audit_log last id %', aud_max; END IF;

  -- 3. Writes
  UPDATE slugs s SET is_canonical = false
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id
     AND s.city_slug = p.city_slug AND s.slug = p.old_slug AND s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 4 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 4)', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text);
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 4 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 4)', n; END IF;

  -- 4. Post-checks
  SELECT count(*) INTO x FROM slugs;                        IF x <> {pre2['slugs']+4} THEN RAISE EXCEPTION 'slugs after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE NOT is_canonical; IF x <> {pre2['noncanon']+4} THEN RAISE EXCEPTION 'non-canonical after %', x; END IF;
  SELECT count(*) INTO x FROM slugs WHERE is_canonical;     IF x <> 11303 THEN RAISE EXCEPTION 'canonical after %', x; END IF;

  SELECT count(*) INTO x FROM venues v WHERE (
    SELECT count(*) FROM slugs s WHERE s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical) <> 1;
  IF x <> 0 THEN RAISE EXCEPTION 'venues without exactly 1 canonical slug after: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, old_slug text, new_slug text)
   WHERE EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.new_slug AND s.is_canonical)
     AND EXISTS (SELECT 1 FROM slugs s WHERE s.property_id='eats' AND s.venue_id=p.venue_id
                   AND s.city_slug=p.city_slug AND s.slug=p.old_slug AND NOT s.is_canonical);
  IF x <> 4 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 4)', x; END IF;

  SELECT count(*) INTO x FROM venues;   IF x <> {pre2['venues']} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;   IF x <> {pre2['awards']} THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings; IF x <> {pre2['listings']} THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;   IF x <> {pre2['blurbs']} THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'UPDATE';
  IF x <> 4 THEN RAISE EXCEPTION 'audit slug updates % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'slugs' AND action = 'INSERT';
  IF x <> 4 THEN RAISE EXCEPTION 'audit slug inserts % (expected 4)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 8 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 8)', x; END IF;
END
$do$;
COMMIT;
"""

# ======================= FILE 3: award + status + count =======================
S = st[0]; A = aw[0]; K = ct[0]
f3 = f"""-- awards-status-open-items-b6-2026-10-31.sql{' (PRE-CHECK TEST COPY: counts before file 1; dry run only)' if TEST else ''}
-- CompassEats, Oct 31 2026 (Atlanta). Open items block 6, file 3 of 3. Run after files 1 and 2. Write connector.
{hdr_common}-- W1 (D3) INSERT awards: {A[1]} Duddell's (3/F) michelin {A[3]} {A[4]}, card {A[5]}
--    ({A[6]}). Ledger +1 (michelin, award, 1).
-- W2 (D4) UPDATE venues status {S[2]} -> {S[3]}: {S[1]} Terra (Fisterra). Status only, no ledger row (Nadair / Dill precedent).
--    Evidence: {S[4]}
--    The 2026 award row 25391 stays as history.
-- W3 UPDATE cities.venues_count {K[1]} Fisterra {K[2]} -> {K[3]} (block 5 method: stored count = view city_venue_counts).
-- D2 no merge (Duddell's), D5 La Torre One Fire: no write.
-- Relay: docs/open-items-b6-build/relay.txt sha256 {RELAY_SHA}.
-- Expected: awards {pre3['awards']} -> {pre3['awards']+1}; closed venues {pre3['closed']} -> {pre3['closed']+1}; ledger last id {pre3['led_max']} -> {pre3['led_max']+1};
-- audit +3 (last id {pre3['aud_max']} -> {pre3['aud_max']+3}: awards INSERT 1, venues UPDATE 1, cities UPDATE 1); venues_count sum {pre3['vc_sum']} -> {pre3['vc_sum']-1}.
-- Dry run: send through the Read connector. It stops at the first write with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  rel_txt constant text := $rel${raw}$rel$;
  v_n bigint;
  v_lid bigint;
  v_aid bigint;
  v_aud bigint;
BEGIN
  ---------------------------------------------------------------- PRE gates
  IF encode(sha256(convert_to(rel_txt, 'UTF8')), 'hex') <> '{RELAY_SHA}' THEN RAISE EXCEPTION 'relay sha256'; END IF;
  IF (SELECT count(*) FROM awards) <> {pre3['awards']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM venues) <> {pre3['venues']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> {pre3['closed']} THEN RAISE EXCEPTION 'closed venues before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> {pre3['led_max']} THEN RAISE EXCEPTION 'ledger max before'; END IF;
  SELECT max(id) INTO v_aud FROM audit_log;
  IF v_aud <> {pre3['aud_max']} THEN RAISE EXCEPTION 'audit max before %', v_aud; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {pre3['vc_sum']} THEN RAISE EXCEPTION 'venues_count sum before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ from the view before'; END IF;

  -- W1 gates: the venue is active, has no michelin {A[3]} row, and the URL is not in use
  IF (SELECT count(*) FROM venues WHERE id = {q(A[1])} AND status = 'active' AND name = 'Duddell''s' AND category = 'restaurant') <> 1
    THEN RAISE EXCEPTION 'Duddell''s restaurant row changed'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE venue_id = {q(A[1])} AND source_id = {q(A[2])} AND year = {A[3]})
    THEN RAISE EXCEPTION 'Duddell''s already has a michelin {A[3]} row'; END IF;
  IF EXISTS (SELECT 1 FROM awards WHERE source_url = {q(A[5])}) THEN RAISE EXCEPTION 'card URL already in use'; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id = {q(A[2])} AND category = {q(A[4])}) <> 1
    THEN RAISE EXCEPTION 'category not registered'; END IF;

  -- W2/W3 gates
  IF (SELECT count(*) FROM venues WHERE id = {q(S[1])} AND status = {q(S[2])} AND name = 'Terra' AND city_id = {q(K[1])}) <> 1
    THEN RAISE EXCEPTION 'Terra row changed'; END IF;
  IF (SELECT venues_count FROM cities WHERE id = {q(K[1])}) <> {K[2]} THEN RAISE EXCEPTION 'Fisterra venues_count before'; END IF;
  IF (SELECT count(*) FROM venues WHERE city_id = {q(K[1])} AND status = 'active') <> {K[2]} THEN RAISE EXCEPTION 'Fisterra active count before'; END IF;

  ---------------------------------------------------------------- W1 award INSERT
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  VALUES ({q(A[1])}, {q(A[2])}, {A[3]}, NULL, {q(A[4])}, NULL, {q(A[5])})
  RETURNING id INTO v_aid;
  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'award', 1,
          'award-add:awards-status-open-items-b6-2026-10-31 | {A[1]} Duddell''s (Hong Kong, 3/F) michelin {A[3]} {A[4]}, live card '
          || '{A[5]} (2026 MICHELIN Guide Hong Kong, read Oct 31) | Ben D3 A Oct 31 02:01 ET '
          || '| note: Hong Kong has 0 michelin 2026 rows (edition not loaded; separate open item)')
  RETURNING id INTO v_lid;

  ---------------------------------------------------------------- W2 venue status
  UPDATE venues SET status = {q(S[3])} WHERE id = {q(S[1])} AND status = {q(S[2])};
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'venue status rows updated: %', v_n; END IF;

  ---------------------------------------------------------------- W3 stored count
  UPDATE cities SET venues_count = {K[3]} WHERE id = {q(K[1])} AND venues_count = {K[2]};
  GET DIAGNOSTICS v_n = ROW_COUNT;
  IF v_n <> 1 THEN RAISE EXCEPTION 'cities rows updated: %', v_n; END IF;

  ---------------------------------------------------------------- POST gates
  IF (SELECT count(*) FROM awards) <> {pre3['awards']+1} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM venues) <> {pre3['venues']} THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM venues WHERE status = 'closed') <> {pre3['closed']+1} THEN RAISE EXCEPTION 'closed venues after'; END IF;
  IF v_lid <> {pre3['led_max']+1} OR (SELECT max(id) FROM source_capture_ledger) <> {pre3['led_max']+1} THEN RAISE EXCEPTION 'ledger id %', v_lid; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {pre3['vc_sum']-1} THEN RAISE EXCEPTION 'venues_count sum after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts v ON v.city_id = c.id
       WHERE c.venues_count IS DISTINCT FROM coalesce(v.active_venues, 0)) <> 0 THEN RAISE EXCEPTION 'cities differ from the view after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud) <> 3 THEN RAISE EXCEPTION 'audit rows after'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'awards' AND action = 'INSERT' AND row_pk = v_aid::text) <> 1
    THEN RAISE EXCEPTION 'audit awards INSERT row'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'venues' AND action = 'UPDATE' AND row_pk = {q(S[1])}
         AND (old_row - 'status') = (new_row - 'status') AND old_row->>'status' = {q(S[2])} AND new_row->>'status' = {q(S[3])}) <> 1
    THEN RAISE EXCEPTION 'audit venues UPDATE row (status only)'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > v_aud AND table_name = 'cities' AND action = 'UPDATE'
         AND (old_row - 'venues_count') = (new_row - 'venues_count')
         AND old_row->>'venues_count' = '{K[2]}' AND new_row->>'venues_count' = '{K[3]}') <> 1
    THEN RAISE EXCEPTION 'audit cities UPDATE row (venues_count only)'; END IF;
  IF (SELECT count(*) FROM awards WHERE id = 25391 AND venue_id = {q(S[1])} AND year = 2026) <> 1 THEN RAISE EXCEPTION 'Terra 2026 row changed'; END IF;
END
$do$;
COMMIT;
"""

os.makedirs(out_dir, exist_ok=True)
sfx = '-TEST' if TEST else ''
if not TEST:
    open(os.path.join(out_dir, 'rename-open-items-b6-2026-10-31.sql'), 'w', encoding='utf-8').write(f1)
open(os.path.join(out_dir, f'slugs-rename-open-items-b6-2026-10-31{sfx}.sql'), 'w', encoding='utf-8').write(f2)
open(os.path.join(out_dir, f'awards-status-open-items-b6-2026-10-31{sfx}.sql'), 'w', encoding='utf-8').write(f3)
print('relay sha256', RELAY_SHA)
print('G_LIVE', G_LIVE, 'G_NEW', G_NEW, 'FP_SLUG', FP_SLUG)
for x in SP: print('slug', x)
