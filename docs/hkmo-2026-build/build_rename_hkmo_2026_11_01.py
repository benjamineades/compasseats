#!/usr/bin/env python3
"""Build the HK/MO 2026 rename batch (66 venues) and its slug file. CompassEats, Nov 1 2026.

Ben, Nov 1 11:25 ET: "D1-D6: A" (rules R1-R5 as in the evidence file; Man Ho, MONO, Seventh Son Restaurant,
Tai Woo Restaurant keep; Ye Shanghai (Tsim Sha Tsui) -> Yè Shanghai (Tsim Sha Tsui); the 65 lines as written).

Inputs (all hash-guarded, no hand-typed names):
  docs/hkmo-2026-build/name-diff-evidence-hkmo-2026-11-01.txt  (84 lines: rename 66, keep 18)
  docs/hkmo-2026-build/cards84-2026-11-01.tsv                  (live card read, 16:12 UTC: line, path, status, h1, website)
  docs/hkmo-2026-build/fresh66-2026-11-01.json                 (Read connector, 16:25 UTC: live id|name md5 + table counts)
Outputs:
  fixtures/rename/michelin-2026-hong-kong-macau.csv
  docs/rename-michelin-2026-hong-kong-macau.sql
  docs/slugs-rename-michelin-2026-hong-kong-macau.sql   (needs the plan fingerprint: argv[2])
Usage: python3 -I build_rename_hkmo_2026_11_01.py <repo root> [slug plan fingerprint]
"""
import csv, hashlib, io, json, os, re, sys

root = sys.argv[1]
FP = sys.argv[2] if len(sys.argv) > 2 else None
B = os.path.join(root, 'docs/hkmo-2026-build')
EV = os.path.join(B, 'name-diff-evidence-hkmo-2026-11-01.txt')
CARDS = os.path.join(B, 'cards84-2026-11-01.tsv')
FRESH = os.path.join(B, 'fresh66-2026-11-01.json')
SHA = {EV: 'cf3016189b9439d49c0c4a8b04f7cbfd88910aad173fc342ebbc5da01c0349eb',
       CARDS: 'fb960d4ac2a499d2bbaeab7a9aa493b2c3bd5ce8e6ee4f95511c6e37ba389b6b',
       FRESH: '7224cf8ed0495c1d1264b780c11c0d175a995bb9fa19ecb3434685d60081ed56'}
for p, h in SHA.items():
    assert hashlib.sha256(open(p, 'rb').read()).hexdigest() == h, p
KEY = 'rename-michelin-2026-hong-kong-macau'
LIVE_MD5 = '4f152108531406dbd60d0a236c35ea50'

# counts read 16:25 UTC (fresh66 json); after = derived
C = json.load(open(FRESH, encoding='utf-8'))['counts']
assert (C['venues'], C['awards'], C['slugs'], C['noncanon'], C['listings'], C['blurbs'], C['rb'], C['rr'],
        C['led_n'], C['led_max'], C['aud_n'], C['aud_max']) == \
       (11300, 23368, 12952, 1652, 11300, 142, 20, 1211, 155, 205, 115757, 121095)
fresh = json.load(open(FRESH, encoding='utf-8'))['fresh66']
assert fresh['md5_id_name'] == LIVE_MD5 and fresh['n_found'] == 66
live = {r['id']: r for r in fresh['rows']}

cards = [l.split('\t') for l in open(CARDS, encoding='utf-8').read().splitlines()]
assert len(cards) == 84 and all(c[2] == '200' for c in cards)
ev = [l.split('|') for l in open(EV, encoding='utf-8').read().splitlines() if l and not l.startswith('#')]
assert len(ev) == 84
DEC = 'Ben Nov 1 11:25 ET "D1-D6: A" (rules R1-R5; evidence file name-diff-evidence-hkmo-2026-11-01.txt)'

rows = []
for f in ev:
    line, vid, ours, card, site, rule, act, new = f
    if act != 'rename':
        assert act == 'keep' and new == '-'
        continue
    c = cards[int(line) - 1]
    assert c[0] == line and c[3] == card
    v = live[vid]
    exp = ours.replace('¦', '|')                      # line 62 note in the evidence header
    assert v['name'] == exp, (vid, v['name'], exp)
    assert v['status'] == 'active' and v['prior_rr'] == 0 and v['canon'] == 1
    assert v['blurbs'] == (1 if vid == 've_fe4ae32eec' else 0)
    assert new != exp and new == new.strip() and new not in ('', '-')
    urls = sorted({u['u'] for u in v['mich_urls'] if u['y'] == 2026 and u['u']})
    assert len(urls) == 1 and urls[0].endswith('/' + c[1])
    card_minus = re.sub(r'\s*\([^()]*\)\s*$', '', card)
    if new in (card, card_minus):
        src, url = 'michelin', urls[0]
        basis = 'new name = Michelin 2026 card name' + (' minus its branch suffix' if new != card else '')
    else:
        assert c[4].startswith('https://'), (vid, 'site row without website link')
        src, url = 'venue', c[4]
        basis = 'new name = venue site spelling (card differs); site = card website link'
    note = (f'HK/MO name-diff evidence line {line}; live "{exp}"; card h1 "{card}"; site read: {site}; rule {rule}; '
            f'{basis}; Michelin card {urls[0]}; {DEC}; read Nov 1')
    rows.append(dict(line=len(rows) + 1, ev=int(line), batch_key=KEY, venue_id=vid, expected_name=exp,
                     new_name=new, source_id=src, source_url=url, note=note))
N = len(rows)
NM = sum(r['source_id'] == 'michelin' for r in rows)
NV = N - NM
assert (N, NM, NV) == (66, 62, 4), (N, NM, NV)

# CSV (same columns and quoting as earlier rename fixtures)
buf = io.StringIO(newline='')
w = csv.writer(buf, lineterminator='\n')
cols = ['batch_key', 'venue_id', 'expected_name', 'new_name', 'source_id', 'source_url', 'note']
w.writerow(cols)
for r in rows:
    w.writerow([r[c] for c in cols])
os.makedirs(os.path.join(root, 'fixtures/rename'), exist_ok=True)
open(os.path.join(root, 'fixtures/rename/michelin-2026-hong-kong-macau.csv'), 'w', encoding='utf-8',
     newline='').write(buf.getvalue())


def md5(s):
    return hashlib.md5(s.encode()).hexdigest()


by = sorted(rows, key=lambda r: r['venue_id'])
M_EXP = md5('\n'.join(f"{r['venue_id']}|{r['expected_name']}" for r in by))
M_NEW = md5('\n'.join(f"{r['venue_id']}|{r['new_name']}" for r in by))
M_ALL = md5('\n'.join('|'.join(str(r[c]) for c in ['line', 'venue_id', 'expected_name', 'new_name', 'source_id',
                                                    'source_url']) for r in by))
M_NOTE = md5('\n'.join(f"{r['venue_id']}|{r['note']}" for r in by))
assert M_EXP == LIVE_MD5


def q(s):
    return "'" + s.replace("'", "''") + "'"


vals = ',\n'.join(f"    ({r['line']}, {q(r['venue_id'])}, {q(r['expected_name'])}, {q(r['new_name'])}, "
                  f"{q(r['source_id'])}, {q(r['source_url'])}, {q(r['note'])})" for r in rows)
RB0, RR0, LED0, LEDMAX, AUD0, AUDMAX = C['rb'], C['rr'], C['led_n'], C['led_max'], C['aud_n'], C['aud_max']
BNOTE = (f"HK/MO 2026 name differences (Michelin 2026 card read + venue-site read Nov 1 2026, evidence file "
         f"docs/hkmo-2026-build/name-diff-evidence-hkmo-2026-11-01.txt): {N} of 84 renamed, 18 keep; rules R1-R5; "
         f"{DEC}. Run as a gated SQL file through the Write connector, not the rename job; same writes as "
         f"scripts/rename/apply.ts.")
JOB = (f"rename-apply:{KEY} | gated SQL file docs/rename-michelin-2026-hong-kong-macau.sql (Write connector), same "
       f"writes as the job | {NM} rows follow the Michelin 2026 card; {NV} rows follow the venue site (source venue, "
       f"no ledger row)")
sql = f"""-- rename-michelin-2026-hong-kong-macau.sql
-- CompassEats, Nov 1 2026. Rename batch for the {N} "rename" lines of
-- docs/hkmo-2026-build/name-diff-evidence-hkmo-2026-11-01.txt (sha256 {SHA[EV]};
-- 84 data lines: rename {N}, keep 18).
-- Ben's decisions: rules R1-R5 (Oct 30); Nov 1 11:25 ET "D1-D6: A".
-- Input file (same rows): fixtures/rename/michelin-2026-hong-kong-macau.csv ({N} rows; source michelin {NM}, venue {NV}).
-- Built by script (docs/hkmo-2026-build/build_rename_hkmo_2026_11_01.py); no hand-typed names.
-- Method: gated SQL, one transaction, through the Supabase Write connector. The writes are the same as the
-- rename job (scripts/rename/apply.ts): rename_batches row (staged -> applied), {N} rename_rows (verdict rename,
-- detail = note, live_name, city_id, city_slug, slug), app.allow_rename on for the venues UPDATE only, 1 ledger
-- row for the registered publisher (michelin {NM}; the {NV} 'venue' rows write no ledger row, as in the job).
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   {M_EXP}  (fresh read Nov 1 16:25 UTC)
--   id|new_name                 {M_NEW}
--   line|id|expected|new|source|url  {M_ALL}
--   id|note                     {M_NOTE}
-- Checks read Nov 1 (read-only): {N} active, 0 earlier rename_rows, 1 canonical slug each, 0 same-city norm_key
-- collisions on the end state (job's rule), 0 NULL norm_key. Blurbs: 1 (Forum ve_fe4ae32eec, status needs_rewrite;
-- its text does not use the venue name, so the rename does not touch it).
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT
-- with "read-only transaction".
-- Expected after: rename_batches {RB0} -> {RB0 + 1} (applied), rename_rows {RR0:,} -> {RR0 + N:,}, ledger {LED0} -> {LED0 + 1}
-- (last id {LEDMAX} -> {LEDMAX + 1}), audit_log +{N} ({N} venues UPDATE, name and norm_key only). venues, awards, slugs,
-- listings, blurbs unchanged.
-- Slugs follow in docs/slugs-rename-michelin-2026-hong-kong-macau.sql.

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
  IF n <> {N} OR x <> {N} THEN RAISE EXCEPTION 'input rows % / distinct venues % (expected {N} / {N})', n, x; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.expected_name, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text)) <> '{M_EXP}' THEN
    RAISE EXCEPTION 'input guard id|expected_name failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.new_name, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)) <> '{M_NEW}' THEN
    RAISE EXCEPTION 'input guard id|new_name failed'; END IF;
  IF (SELECT md5(string_agg(p.line||'|'||p.venue_id||'|'||p.expected_name||'|'||p.new_name||'|'||p.source_id||'|'||p.source_url,
                            E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text, source_id text, source_url text))
       <> '{M_ALL}' THEN
    RAISE EXCEPTION 'input guard rows failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.note, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, note text)) <> '{M_NOTE}' THEN
    RAISE EXCEPTION 'input guard notes failed'; END IF;

  -- 2. Pre-checks against live data
  SELECT count(*) INTO x FROM rename_batches WHERE batch_key = '{KEY}';
  IF x <> 0 THEN RAISE EXCEPTION 'batch key already used: %', x; END IF;

  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{M_EXP}' THEN
    RAISE EXCEPTION 'live names differ from the Nov 1 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> {N} THEN RAISE EXCEPTION 'active venues % (expected {N})', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id NOT IN ('michelin', 'venue');
  IF x <> 0 THEN RAISE EXCEPTION 'unexpected source_id: %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id = 'michelin';
  IF x <> {NM} THEN RAISE EXCEPTION 'michelin rows % (expected {NM})', x; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug = 'michelin';
  IF x <> 1 THEN RAISE EXCEPTION 'michelin not registered in award_sources'; END IF;
  SELECT count(*) INTO x FROM award_sources WHERE slug = 'venue';
  IF x <> 0 THEN RAISE EXCEPTION 'venue is a registered source (ledger rule changes)'; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_url text)
   WHERE p.source_url !~ '^https://' OR p.source_url ~* '(joinpearl|thebestrestaurantsguide|beliapp)';
  IF x <> 0 THEN RAISE EXCEPTION 'bad source_url: %', x; END IF;

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

  SELECT count(*) INTO x FROM blurbs b JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = b.venue_id;
  IF x <> 1 THEN RAISE EXCEPTION 'blurbs on batch venues % (expected 1, Forum)', x; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> {C['venues']} THEN RAISE EXCEPTION 'venues before % (expected {C['venues']})', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {C['awards']} THEN RAISE EXCEPTION 'awards before % (expected {C['awards']})', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {C['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {C['slugs']})', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {C['listings']} THEN RAISE EXCEPTION 'listings before % (expected {C['listings']})', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {C['blurbs']} THEN RAISE EXCEPTION 'blurbs before % (expected {C['blurbs']})', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {RB0} THEN RAISE EXCEPTION 'rename_batches before % (expected {RB0})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {RR0} THEN RAISE EXCEPTION 'rename_rows before % (expected {RR0})', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {LED0} OR led_max <> {LEDMAX} THEN RAISE EXCEPTION 'ledger before % rows, last id % (expected {LED0}, {LEDMAX})', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {AUD0} OR aud_max <> {AUDMAX} THEN
    RAISE EXCEPTION 'audit_log before % rows, last id % (expected {AUD0}, {AUDMAX})', aud_n, aud_max; END IF;

  -- 3. Writes (same order as the rename job)
  INSERT INTO rename_batches (batch_key, status, note)
  VALUES ('{KEY}', 'staged', {q(BNOTE)})
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
  IF n <> {N} THEN RAISE EXCEPTION 'rename_rows inserted % (expected {N})', n; END IF;

  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = p.new_name
    FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
   WHERE v.id = p.venue_id AND v.name = p.expected_name;
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> {N} THEN RAISE EXCEPTION 'venues renamed % (expected {N})', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', {NM}, {q(JOB)});

  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'batch status update % (expected 1)', n; END IF;

  -- 4. Post-checks (the job's invariants)
  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text, new_name text) ON p.venue_id = v.id
   WHERE v.name IS DISTINCT FROM p.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'venues whose live name is not new_name: %', x; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{M_NEW}' THEN
    RAISE EXCEPTION 'live id|name after differs from the file'; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> {C['venues']} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {C['awards']} THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {C['slugs']} THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {C['listings']} THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {C['blurbs']} THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {RB0 + 1} THEN RAISE EXCEPTION 'rename_batches after % (expected {RB0 + 1})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {RR0 + N} THEN RAISE EXCEPTION 'rename_rows after % (expected {RR0 + N})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> {N} THEN RAISE EXCEPTION 'rename_rows in this batch % (expected {N})', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> {LED0 + 1} THEN RAISE EXCEPTION 'ledger after % (expected {LED0 + 1})', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'name' AND items = {NM} AND job LIKE 'rename-apply:{KEY} |%';
  IF x <> 1 THEN RAISE EXCEPTION 'ledger row for this batch % (expected 1)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> {N} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {N})', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
      ON a.row_pk = p.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.at = transaction_timestamp()
     AND a.old_row->>'name' = p.expected_name AND a.new_row->>'name' = p.new_name
     AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key');
  IF x <> {N} THEN RAISE EXCEPTION 'audit venue renames (name and norm_key only) % (expected {N})', x; END IF;
END
$do$;
COMMIT;
"""
open(os.path.join(root, 'docs/rename-michelin-2026-hong-kong-macau.sql'), 'w', encoding='utf-8', newline='\n').write(sql)
json.dump(dict(M_EXP=M_EXP, M_NEW=M_NEW, M_ALL=M_ALL, M_NOTE=M_NOTE, N=N, NM=NM, NV=NV),
          open(os.path.join(B, 'rename-md5-2026-11-01.json'), 'w'), indent=1)
json.dump([dict(venue_id=r['venue_id'], new_name=r['new_name']) for r in by],
          open(os.path.join(B, 'rename-new-names-2026-11-01.json'), 'w', encoding='utf-8'), ensure_ascii=False)
print('rename:', N, 'rows; michelin', NM, 'venue', NV, '| new md5', M_NEW)

# ---------- slug file (built from the batch-29 slug file as template) ----------
if FP is None:
    print('slug file not built: pass the plan fingerprint')
    sys.exit(0)
NP, NSAME = 49, 17
AUD1, AUDMAX1 = AUD0 + N, AUDMAX + N          # audit after the rename
SL0, NC0 = C['slugs'], C['noncanon']
T = open(os.path.join(root, 'docs/slugs-rename-name-diffs-2026-10-30.sql'), encoding='utf-8').read()
body = T[T.index('BEGIN;\nDO $do$'):]
OLDKEY = 'rename-name-diffs-2026-10-30'
reps = [
    (OLDKEY, KEY),
    ("IF x <> 72 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 72)'",
     f"IF x <> {N} THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected {N})'"),
    ("n_all <> 72 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 72)'",
     f"n_all <> {N} THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected {N})'"),
    ("n_same <> 6 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 6)'",
     f"n_same <> {NSAME} THEN RAISE EXCEPTION 'venues that keep their slug % (expected {NSAME})'"),
    ("n_plan <> 66 THEN RAISE EXCEPTION 'plan rows % (expected 66)'",
     f"n_plan <> {NP} THEN RAISE EXCEPTION 'plan rows % (expected {NP})'"),
    ("fp <> '3b871e7ea11cc1349e060b33b2672bb1' THEN\n    RAISE EXCEPTION 'plan fingerprint % differs from the Oct 30 read', fp;",
     f"fp <> '{FP}' THEN\n    RAISE EXCEPTION 'plan fingerprint % differs from the Nov 1 read', fp;"),
    ("IF x <> 66 THEN RAISE EXCEPTION 'distinct venues % (expected 66)'",
     f"IF x <> {NP} THEN RAISE EXCEPTION 'distinct venues % (expected {NP})'"),
    ("x <> 12843 THEN RAISE EXCEPTION 'slugs before % (expected 12843)'",
     f"x <> {SL0} THEN RAISE EXCEPTION 'slugs before % (expected {SL0})'"),
    ("x <> 1539 THEN RAISE EXCEPTION 'non-canonical before % (expected 1539)'",
     f"x <> {NC0} THEN RAISE EXCEPTION 'non-canonical before % (expected {NC0})'"),
    ("x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)'",
     f"x <> {C['venues']} THEN RAISE EXCEPTION 'venues before % (expected {C['venues']})'"),
    ("x <> 23353 THEN RAISE EXCEPTION 'awards before % (expected 23353)'",
     f"x <> {C['awards']} THEN RAISE EXCEPTION 'awards before % (expected {C['awards']})'"),
    ("x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)'",
     f"x <> {C['listings']} THEN RAISE EXCEPTION 'listings before % (expected {C['listings']})'"),
    ("aud_n <> 113541 THEN RAISE EXCEPTION 'audit_log before % (expected 113541)'",
     f"aud_n <> {AUD1} THEN RAISE EXCEPTION 'audit_log before % (expected {AUD1})'"),
    ("aud_max <> 118825 THEN RAISE EXCEPTION 'audit_log last id % (expected 118825)'",
     f"aud_max <> {AUDMAX1} THEN RAISE EXCEPTION 'audit_log last id % (expected {AUDMAX1})'"),
    ("IF n <> 66 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 66)'",
     f"IF n <> {NP} THEN RAISE EXCEPTION 'old canonical rows updated % (expected {NP})'"),
    ("IF n <> 66 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 66)'",
     f"IF n <> {NP} THEN RAISE EXCEPTION 'new canonical rows inserted % (expected {NP})'"),
    ("x <> 12909 THEN RAISE EXCEPTION 'slugs after % (expected 12909)'",
     f"x <> {SL0 + NP} THEN RAISE EXCEPTION 'slugs after % (expected {SL0 + NP})'"),
    ("x <> 1605 THEN RAISE EXCEPTION 'non-canonical after % (expected 1605)'",
     f"x <> {NC0 + NP} THEN RAISE EXCEPTION 'non-canonical after % (expected {NC0 + NP})'"),
    ("x <> 11304 THEN RAISE EXCEPTION 'canonical after % (expected 11304)'",
     f"x <> {C['venues']} THEN RAISE EXCEPTION 'canonical after % (expected {C['venues']})'"),
    ("IF x <> 66 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 66)'",
     f"IF x <> {NP} THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected {NP})'"),
    ("x <> 11304 THEN RAISE EXCEPTION 'venues changed: %'", f"x <> {C['venues']} THEN RAISE EXCEPTION 'venues changed: %'"),
    ("x <> 23353 THEN RAISE EXCEPTION 'awards changed: %'", f"x <> {C['awards']} THEN RAISE EXCEPTION 'awards changed: %'"),
    ("x <> 11304 THEN RAISE EXCEPTION 'listings changed: %'", f"x <> {C['listings']} THEN RAISE EXCEPTION 'listings changed: %'"),
    ("IF x <> 66 THEN RAISE EXCEPTION 'audit slug updates % (expected 66)'",
     f"IF x <> {NP} THEN RAISE EXCEPTION 'audit slug updates % (expected {NP})'"),
    ("IF x <> 66 THEN RAISE EXCEPTION 'audit slug inserts % (expected 66)'",
     f"IF x <> {NP} THEN RAISE EXCEPTION 'audit slug inserts % (expected {NP})'"),
    ("IF x <> 132 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 132)'",
     f"IF x <> {2 * NP} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {2 * NP})'"),
]
cnt = 0
for a, b in reps:
    c = body.count(a)
    assert c >= 1, (a[:70], c)
    cnt += c
    body = body.replace(a, b)
for bad in [OLDKEY, '12843', '1539', '11304', '23353', '113541', '118825', '12909', '1605', '3b871e7e', 'Oct 30',
            "expected 72", "expected 132"]:      # "expected 66" is legal here: N = 66 (old 66 lines all have own rules)
    assert bad not in body, bad
assert body.count('expected 66') == 2, body.count('expected 66')   # rename_rows of the batch; batch venues with a canonical slug
head = f"""-- slugs-rename-michelin-2026-hong-kong-macau.sql
-- CompassEats, Nov 1 2026. New canonical slugs for the {N} venues renamed by rename batch
-- {KEY} (docs/rename-michelin-2026-hong-kong-macau.sql). Run only after that batch is applied.
-- Template: docs/slugs-rename-name-diffs-2026-10-30.sql (same method, same checks; the gate finds the batch by its key
-- and checks that the {N} live names equal new_name).
-- Built by script (docs/hkmo-2026-build/build_rename_hkmo_2026_11_01.py): {len(reps)} rules / {cnt} counted replacements,
-- leftover check.
-- Method: gated SQL, one transaction, through the Supabase Write connector.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')), Ben's option A (Oct 8).
-- {NSAME} of the {N} venues keep their slug (the new name gives the same slug). Plan: {NP} rows.
-- For each plan venue: the old canonical row becomes non-canonical (old URL stays and points to the same venue),
-- and a new canonical row is inserted. No row is deleted. No ledger row.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id, joined by newline,
-- only rows where new_slug <> old_slug), read Nov 1 from the proposed names before the rename:
--   {FP}  ({NP} rows). Checks then: 0 empty, 0 duplicate, 0 in use, 0 in redirects.
-- Expected before: slugs {SL0:,} (non-canonical {NC0:,}); audit_log {AUD1:,} rows, last id {AUDMAX1:,} (= after the rename).
-- Expected after: slugs {SL0 + NP:,}, non-canonical {NC0 + NP:,}, canonical {C['venues']:,}; audit +{2 * NP} ({NP} UPDATE + {NP} INSERT).
-- Dry run: send through the Read connector after the rename. All pre-checks run, then the block stops at the
-- first UPDATE with "read-only transaction".

"""
open(os.path.join(root, 'docs/slugs-rename-michelin-2026-hong-kong-macau.sql'), 'w', encoding='utf-8',
     newline='\n').write(head + body)
print('slugs: rules', len(reps), 'replacements', cnt, 'plan', NP, 'keep', NSAME)
