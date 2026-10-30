"""Build rename batch 30 (the 8 held name-diff venues) and its slug file.
Run from a work folder that holds fresh8.json (the Oct 30 fresh read, pulled from the session transcript by grab.py).

  python3 build_name_diffs_held8_rename.py build          -> CSV, check.sql, rename SQL
  python3 build_name_diffs_held8_rename.py slug FP NPLAN NSAME  -> slug SQL (after the read-only check gives FP)

Inputs (all guarded):
  1. docs/name-diff-evidence-2026-10-30.txt   (sha256 below; the 8 lines whose action starts with 'hold')
  2. docs/name-diff-held8-decisions-2026-10-30.txt  (Ben's 19:25 ET decisions; new names, sources, site reads)
  3. fresh8.json  (Read connector, Oct 30 ~23:3x UTC; md5 of live id|name = evidence column 3)
Name guards (no hand-typed name gets through unchecked):
  - michelin rows: the new name, lower case, accents removed except d-stroke, spaces to '-', equals the last part of
    the live Michelin 2026 card URL (URL-decoded). Where the evidence file gives the card h1, the new name equals it.
  - venue rows: the new name differs from the live name in capitals only (casefold equal).
"""
import json, hashlib, csv, io, re, sys, unicodedata, urllib.parse
REPO = '/home/claude/compasseats'
EV = REPO + '/docs/name-diff-evidence-2026-10-30.txt'
EV_SHA = '751cd15f2cd39c7a7d6fcc00b53e553b7e66b39666f53ac163a9a2e071e1043d'
DEC = REPO + '/docs/name-diff-held8-decisions-2026-10-30.txt'
KEY = 'rename-name-diffs-held8-2026-10-30'
LIVE_MD5 = '23a6e30878bab101db515a732999fbd1'
N = 8
# live counts before (read Oct 30 23:21 UTC)
BEFORE = dict(venues=11304, awards=23353, slugs=12909, noncanon=1605, listings=11304, blurbs=142,
              rb=15, rr=1186, led_n=119, led_max=163, aud_n=113673, aud_max=118957)
BEN = "Ben Oct 30 19:23 ET Option 1 (read the 4 sites), 19:25 ET 'All recommended'"


def md5(s): return hashlib.md5(s.encode()).hexdigest()
def q(s): return "'" + s.replace("'", "''") + "'"


def url_key(name):
    s = unicodedata.normalize('NFD', name.lower())
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    return re.sub(r'\s*-\s*|\s+', '-', s)


def load():
    raw = open(EV, 'rb').read()
    assert hashlib.sha256(raw).hexdigest() == EV_SHA
    held = []; dataline = 0
    for l in raw.decode('utf-8').split('\n'):
        if not l or l.startswith('#'): continue
        dataline += 1
        f = l.split('|'); assert len(f) == 7
        if f[5].startswith('hold'):
            held.append(dict(evline=dataline, vid=f[0], group=f[1], ours=f[2], card=f[3], site=f[4], action=f[5]))
    assert dataline == 94 and len(held) == N
    dec = {}
    for l in open(DEC, encoding='utf-8'):
        if not l.strip() or l.startswith('#'): continue
        f = l.rstrip('\n').split('|'); assert len(f) == 6, l
        new = f[1]
        assert new == unicodedata.normalize('NFC', new), new
        dec[f[0]] = dict(new=new, src=f[2], url=f[3], rule=f[4], site=f[5])
    assert len(dec) == N and set(dec) == {h['vid'] for h in held}
    fresh = json.load(open('fresh8.json', encoding='utf-8'))[0]
    assert fresh['md5_id_name'] == LIVE_MD5 and fresh['n_found'] == N
    live = {r['id']: r for r in fresh['rows']}
    assert md5('\n'.join(f"{i}|{live[i]['name']}" for i in sorted(live))) == LIVE_MD5
    rows = []
    for i, h in enumerate(held, 1):
        v = live[h['vid']]; d = dec[h['vid']]
        dag = h['ours'].endswith('†')
        exp = h['ours'][:-1] if dag else h['ours']
        assert v['name'] == exp, (h['vid'], v['name'], exp)
        assert v['status'] == 'active' and v['blurbs'] == 0 and v['prior_rr'] == 0 and len(v['canon']) == 1
        new = d['new']
        assert new != exp and new == new.strip() and '  ' not in new
        urls = [u['u'] for u in v['mich_urls'] if u['y'] == 2026 and u['u']]
        assert len(urls) == 1
        card_url = urls[0]
        card_minus = re.sub(r'\s*\([^()]*\)\s*$', '', h['card'])
        if d['src'] == 'michelin':
            assert d['url'] == ''
            last = urllib.parse.unquote(card_url.rstrip('/').rsplit('/', 1)[1])
            assert url_key(new) == last, (new, url_key(new), last)
            if not h['card'].endswith('note)') and not h['card'].startswith('La P'):
                assert new == card_minus, (new, card_minus)
            url = card_url
            basis = 'new name = Michelin 2026 card name'
        else:
            assert d['src'] == 'venue' and d['url'].startswith('https://')
            assert new.casefold() == exp.casefold(), (new, exp)
            url = d['url']
            basis = 'new name = venue site spelling (card differs); site = card website link'
        ev_card = re.sub(r'\s*\(held-P2 note[^()]*\)$', '', h['card'])
        card_txt = (f'card h1 "{ev_card}"' if ev_card == h['card'] else
                    f'card h1 "{new if d["src"] == "michelin" else ev_card}" (live card read Oct 30; evidence file had the held-P2 note "{h["card"]}")')
        note = (f'Name-diff evidence line {h["evline"]} ({h["group"]}, held Oct 30 18:35 ET); live "{exp}"; '
                f'{card_txt}; site read: {d["site"]}; '
                f'rule {d["rule"]}; {basis}; Michelin card {card_url}'
                + (f'; non-Michelin award on venue ({v["other"]}); Ben Oct 30 18:35 ET decision 2 = A (site + card agreement)' if dag else '')
                + f'; {BEN}; read Oct 30')
        rows.append(dict(line=i, batch_key=KEY, venue_id=h['vid'], expected_name=exp, new_name=new,
                         source_id=d['src'], source_url=url, note=note, dag=dag, city_id=v['city_id'],
                         city_slug=v['city_slug'], old_slug=v['canon'][0]))
    return rows


def build():
    rows = load()
    n_mich = sum(r['source_id'] == 'michelin' for r in rows)
    assert n_mich == 5 and sum(r['dag'] for r in rows) == 1
    buf = io.StringIO(newline='')
    w = csv.writer(buf, lineterminator='\n')
    cols = ['batch_key', 'venue_id', 'expected_name', 'new_name', 'source_id', 'source_url', 'note']
    w.writerow(cols)
    for r in rows: w.writerow([r[c] for c in cols])
    open(REPO + '/fixtures/rename/name-diffs-held8-2026-10-30.csv', 'w', encoding='utf-8', newline='').write(buf.getvalue())
    by = sorted(rows, key=lambda r: r['venue_id'])
    M_EXP = md5('\n'.join(f"{r['venue_id']}|{r['expected_name']}" for r in by))
    M_NEW = md5('\n'.join(f"{r['venue_id']}|{r['new_name']}" for r in by))
    M_ALL = md5('\n'.join('|'.join(str(r[c]) for c in ['line', 'venue_id', 'expected_name', 'new_name', 'source_id', 'source_url']) for r in by))
    M_NOTE = md5('\n'.join(f"{r['venue_id']}|{r['note']}" for r in by))
    assert M_EXP == LIVE_MD5
    json.dump(dict(M_EXP=M_EXP, M_NEW=M_NEW, M_ALL=M_ALL, M_NOTE=M_NOTE), open('md5.json', 'w'))
    print('md5 expected', M_EXP, 'new', M_NEW, 'rows', M_ALL, 'note', M_NOTE)

    # read-only check: collisions, norm_key, slug plan + fingerprint (from the proposed names)
    cv = ',\n'.join(f"  ({q(r['venue_id'])}, {q(r['new_name'])})" for r in rows)
    check = f"""-- check (read-only), batch {KEY}
WITH batch(venue_id, new_name) AS (VALUES
{cv}
),
scope AS (SELECT DISTINCT v.city_id FROM venues v JOIN batch b ON b.venue_id = v.id),
fin AS (SELECT v.id, v.city_id, coalesce(b.new_name, v.name) AS name
          FROM venues v JOIN scope s ON s.city_id = v.city_id LEFT JOIN batch b ON b.venue_id = v.id),
plan AS (SELECT v.id AS venue_id, b.new_name AS name, s.city_slug, s.slug AS old_slug,
                trim(both '-' from regexp_replace(lower(f_unaccent(b.new_name)), '[^a-z0-9]+', '-', 'g')) AS new_slug
           FROM batch b JOIN venues v ON v.id = b.venue_id
           JOIN slugs s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical),
pc AS (SELECT * FROM plan WHERE new_slug <> old_slug)
SELECT 'CHECK30-' || md5((SELECT string_agg(venue_id||'|'||new_name, E'\\n' ORDER BY venue_id) FROM batch)) AS marker,
  (SELECT count(*) FROM batch) n_batch,
  (SELECT count(*) FROM fin a JOIN batch ON batch.venue_id = a.id JOIN fin o ON o.city_id = a.city_id AND o.id <> a.id
     AND norm_key(a.name) IS NOT NULL AND norm_key(o.name) = norm_key(a.name)) same_city_normkey_collisions,
  (SELECT count(*) FROM batch WHERE norm_key(new_name) IS NULL) null_normkey,
  (SELECT count(*) FROM batch b JOIN venues v ON v.id = b.venue_id WHERE norm_key(b.new_name) = v.norm_key) normkey_same,
  (SELECT jsonb_agg(jsonb_build_object('id', venue_id, 'old', v_old, 'new', v_new) ORDER BY venue_id)
     FROM (SELECT b.venue_id, v.norm_key v_old, norm_key(b.new_name) v_new FROM batch b JOIN venues v ON v.id = b.venue_id) z) normkeys,
  (SELECT count(*) FROM plan) n_all, (SELECT count(*) FROM plan WHERE new_slug = old_slug) n_same, (SELECT count(*) FROM pc) n_plan,
  (SELECT md5(string_agg(venue_id||'|'||name||'|'||city_slug||'|'||old_slug||'|'||new_slug, E'\\n' ORDER BY venue_id)) FROM pc) fp,
  (SELECT jsonb_agg(jsonb_build_object('id', venue_id, 'city', city_slug, 'old', old_slug, 'new', new_slug) ORDER BY venue_id) FROM plan) slugs,
  (SELECT count(*) FROM pc WHERE new_slug = '') empty_slugs,
  (SELECT count(*) FROM (SELECT city_slug, new_slug FROM pc GROUP BY 1, 2 HAVING count(*) > 1) d) dup_in_plan,
  (SELECT count(*) FROM pc JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = pc.city_slug AND s.slug = pc.new_slug) in_use,
  (SELECT count(*) FROM redirects d, pc WHERE d.from_path IN ('/'||pc.city_slug||'/'||pc.new_slug, '/venue/'||pc.city_slug||'/'||pc.new_slug)) in_redirects,
  (SELECT count(*) FROM award_sources WHERE slug = 'michelin') michelin_registered,
  (SELECT count(*) FROM award_sources WHERE slug = 'venue') venue_registered;
"""
    open('check.sql', 'w', encoding='utf-8').write(check)
    print('check marker CHECK30-' + M_NEW)

    vals = ',\n'.join(f"    ({r['line']}, {q(r['venue_id'])}, {q(r['expected_name'])}, {q(r['new_name'])}, {q(r['source_id'])}, {q(r['source_url'])}, {q(r['note'])})" for r in rows)
    B = BEFORE
    BNOTE = ("Name differences, the 8 venues held on Oct 30 (evidence file name-diff-evidence-2026-10-30.txt, hold lines; "
             "decisions file name-diff-held8-decisions-2026-10-30.txt): 4 sites read Oct 30 (Ben Option 1), Ben 'All "
             "recommended' 19:25 ET. Run as a gated SQL file through the Write connector, not the rename job; same writes "
             "as scripts/rename/apply.ts.")
    JOB = (f"rename-apply:{KEY} | gated SQL file docs/rename-name-diffs-held8-2026-10-30.sql (Write connector), same writes "
           f"as the job | {n_mich} rows follow the Michelin 2026 card; {N - n_mich} rows follow the venue site (source venue, no ledger row)")
    sql = f"""-- rename-name-diffs-held8-2026-10-30.sql
-- CompassEats, Oct 30 2026. Rename batch for the 8 "hold" lines of docs/name-diff-evidence-2026-10-30.txt
-- (sha256 {EV_SHA}, 94 data lines: rename 72 = batch 29, keep 14, hold 8 = this batch).
-- Ben's decisions: Oct 30 19:23 ET "Option 1" (read the 4 sites not read before), 19:25 ET "All recommended".
-- Names, sources and site reads: docs/name-diff-held8-decisions-2026-10-30.txt.
-- Input file (same rows): fixtures/rename/name-diffs-held8-2026-10-30.csv ({N} rows; source michelin {n_mich}, venue {N - n_mich}).
-- Built by script (docs/build_name_diffs_held8_rename.py) from the evidence file, the decisions file and the fresh
-- read; each michelin name is checked against the card URL, each venue name differs from the live name in capitals only.
-- Method: gated SQL, one transaction, through the Supabase Write connector. Same writes as the rename job
-- (scripts/rename/apply.ts): rename_batches row (staged -> applied), {N} rename_rows (verdict rename, detail = note,
-- live_name, city_id, city_slug, slug), app.allow_rename on for the venues UPDATE only, 1 ledger row for michelin
-- ({n_mich}); the {N - n_mich} 'venue' rows write no ledger row, as in the job.
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   {M_EXP}  (fresh read Oct 30 ~23:3x UTC)
--   id|new_name                 {M_NEW}
--   line|id|expected|new|source|url  {M_ALL}
--   id|note                     {M_NOTE}
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT
-- with "read-only transaction".
-- Expected after: rename_batches {B['rb']} -> {B['rb'] + 1} (applied), rename_rows {B['rr']:,} -> {B['rr'] + N:,}, ledger +1 (last id {B['led_max']} -> {B['led_max'] + 1}),
-- audit_log +{N} ({N} venues UPDATE, name and norm_key only). venues, awards, slugs, listings, blurbs unchanged.
-- Slugs follow in docs/slugs-rename-name-diffs-held8-2026-10-30.sql.

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
    RAISE EXCEPTION 'live names differ from the Oct 30 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> {N} THEN RAISE EXCEPTION 'active venues % (expected {N})', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id NOT IN ('michelin', 'venue');
  IF x <> 0 THEN RAISE EXCEPTION 'unexpected source_id: %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id = 'michelin';
  IF x <> {n_mich} THEN RAISE EXCEPTION 'michelin rows % (expected {n_mich})', x; END IF;
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

  SELECT count(*) INTO x FROM venues;          IF x <> {B['venues']} THEN RAISE EXCEPTION 'venues before % (expected {B['venues']})', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {B['awards']} THEN RAISE EXCEPTION 'awards before % (expected {B['awards']})', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {B['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {B['slugs']})', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {B['listings']} THEN RAISE EXCEPTION 'listings before % (expected {B['listings']})', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {B['blurbs']} THEN RAISE EXCEPTION 'blurbs before % (expected {B['blurbs']})', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {B['rb']} THEN RAISE EXCEPTION 'rename_batches before % (expected {B['rb']})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {B['rr']} THEN RAISE EXCEPTION 'rename_rows before % (expected {B['rr']})', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> {B['led_n']} OR led_max <> {B['led_max']} THEN RAISE EXCEPTION 'ledger before % rows, last id % (expected {B['led_n']}, {B['led_max']})', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> {B['aud_n']} OR aud_max <> {B['aud_max']} THEN
    RAISE EXCEPTION 'audit_log before % rows, last id % (expected {B['aud_n']}, {B['aud_max']})', aud_n, aud_max; END IF;

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
  VALUES ('michelin', 'name', {n_mich}, {q(JOB)});

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

  SELECT count(*) INTO x FROM venues;          IF x <> {B['venues']} THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> {B['awards']} THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> {B['slugs']} THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> {B['listings']} THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> {B['blurbs']} THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> {B['rb'] + 1} THEN RAISE EXCEPTION 'rename_batches after % (expected {B['rb'] + 1})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> {B['rr'] + N} THEN RAISE EXCEPTION 'rename_rows after % (expected {B['rr'] + N})', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> {N} THEN RAISE EXCEPTION 'rename_rows in this batch % (expected {N})', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> {B['led_n'] + 1} THEN RAISE EXCEPTION 'ledger after % (expected {B['led_n'] + 1})', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'name' AND items = {n_mich} AND job LIKE 'rename-apply:{KEY} |%';
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
    open(REPO + '/docs/rename-name-diffs-held8-2026-10-30.sql', 'w', encoding='utf-8', newline='\n').write(sql)
    print('rename sql', len(sql.encode()), 'bytes', sql.count('\n'), 'lines; rows', N, 'michelin', n_mich, 'venue', N - n_mich)


# Slug reuse (found by the Oct 30 check): the new slug of La P’tite Patte is already a NON-canonical slug of the
# same venue (moved there by the Sep 16 merge of ve_17d83ed8dd, audit 97523). That row becomes canonical again;
# no new row is inserted for it. Any other use of a new slug still stops the block.
REUSE = [('ve_c4d70b9a92', 'cholet', 'la-p-tite-patte')]


def slug(fp, n_plan, n_same):
    n_plan, n_same = int(n_plan), int(n_same)
    assert re.fullmatch(r'[0-9a-f]{32}', fp) and n_plan + n_same == N
    n_reuse = len(REUSE)
    fp_reuse = md5('\n'.join('|'.join(t) for t in sorted(REUSE)))
    n_ins = n_plan - n_reuse
    rows = load()
    B = BEFORE
    aud_n2, aud_max2 = B['aud_n'] + N, B['aud_max'] + N          # after the rename
    T = open(REPO + '/docs/slugs-rename-name-diffs-2026-10-30.sql', encoding='utf-8').read()
    body = T[T.index('BEGIN;\nDO $do$'):]
    OLD = 'rename-name-diffs-2026-10-30'
    reps = [
        (f"batch_key = '{OLD}';", f"batch_key = '{KEY}';"),
        (f"'rename batch {OLD} applied:", f"'rename batch {KEY} applied:"),
        ("IF x <> 72 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 72)'", f"IF x <> {N} THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected {N})'"),
        ("n_all <> 72 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 72)'", f"n_all <> {N} THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected {N})'"),
        ("n_same <> 6 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 6)'", f"n_same <> {n_same} THEN RAISE EXCEPTION 'venues that keep their slug % (expected {n_same})'"),
        ("n_plan <> 66 THEN RAISE EXCEPTION 'plan rows % (expected 66)'", f"n_plan <> {n_plan} THEN RAISE EXCEPTION 'plan rows % (expected {n_plan})'"),
        ("fp <> '3b871e7ea11cc1349e060b33b2672bb1' THEN", f"fp <> '{fp}' THEN"),
        ("IF x <> 66 THEN RAISE EXCEPTION 'distinct venues % (expected 66)'", f"IF x <> {n_plan} THEN RAISE EXCEPTION 'distinct venues % (expected {n_plan})'"),
        ("x <> 12843 THEN RAISE EXCEPTION 'slugs before % (expected 12843)'", f"x <> {B['slugs']} THEN RAISE EXCEPTION 'slugs before % (expected {B['slugs']})'"),
        ("x <> 1539 THEN RAISE EXCEPTION 'non-canonical before % (expected 1539)'", f"x <> {B['noncanon']} THEN RAISE EXCEPTION 'non-canonical before % (expected {B['noncanon']})'"),
        ("aud_n <> 113541 THEN RAISE EXCEPTION 'audit_log before % (expected 113541)'", f"aud_n <> {aud_n2} THEN RAISE EXCEPTION 'audit_log before % (expected {aud_n2})'"),
        ("aud_max <> 118825 THEN RAISE EXCEPTION 'audit_log last id % (expected 118825)'", f"aud_max <> {aud_max2} THEN RAISE EXCEPTION 'audit_log last id % (expected {aud_max2})'"),
        ("IF n <> 66 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 66)'", f"IF n <> {n_plan} THEN RAISE EXCEPTION 'old canonical rows updated % (expected {n_plan})'"),
        ("IF n <> 66 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 66)'", f"IF n <> {n_ins} THEN RAISE EXCEPTION 'new canonical rows inserted % (expected {n_ins})'"),
        ("x <> 12909 THEN RAISE EXCEPTION 'slugs after % (expected 12909)'", f"x <> {B['slugs'] + n_ins} THEN RAISE EXCEPTION 'slugs after % (expected {B['slugs'] + n_ins})'"),
        ("x <> 1605 THEN RAISE EXCEPTION 'non-canonical after % (expected 1605)'", f"x <> {B['noncanon'] + n_ins} THEN RAISE EXCEPTION 'non-canonical after % (expected {B['noncanon'] + n_ins})'"),
        ("IF x <> 66 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 66)'", f"IF x <> {n_plan} THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected {n_plan})'"),
        ("IF x <> 66 THEN RAISE EXCEPTION 'audit slug updates % (expected 66)'", f"IF x <> {n_plan + n_reuse} THEN RAISE EXCEPTION 'audit slug updates % (expected {n_plan + n_reuse})'"),
        ("IF x <> 66 THEN RAISE EXCEPTION 'audit slug inserts % (expected 66)'", f"IF x <> {n_ins} THEN RAISE EXCEPTION 'audit slug inserts % (expected {n_ins})'"),
        ("  fp          text;\n", "  fp          text;\n  n_reuse     int;\n  fp_reuse    text;\n"),
        ("""  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(city_slug text, new_slug text)
   JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs already in use: %', x; END IF;""",
         f"""  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   JOIN slugs s ON s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug
   WHERE s.venue_id <> p.venue_id OR s.is_canonical;
  IF x <> 0 THEN RAISE EXCEPTION 'new slugs in use by another venue or as a canonical slug: %', x; END IF;

  -- new slugs that are already a non-canonical slug of the same venue: reuse (made canonical again, no insert)
  SELECT count(*), md5(string_agg(p.venue_id||'|'||p.city_slug||'|'||p.new_slug, E'\\n' ORDER BY p.venue_id))
    INTO n_reuse, fp_reuse
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
    JOIN slugs s ON s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = p.city_slug
                AND s.slug = p.new_slug AND NOT s.is_canonical;
  IF n_reuse <> {n_reuse} OR fp_reuse <> '{fp_reuse}' THEN
    RAISE EXCEPTION 'reuse rows % / % (expected {n_reuse} / {fp_reuse})', n_reuse, fp_reuse; END IF;"""),
        ("""  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text);""",
         f"""  UPDATE slugs s SET is_canonical = true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   WHERE s.property_id = 'eats' AND s.venue_id = p.venue_id AND s.city_slug = p.city_slug
     AND s.slug = p.new_slug AND NOT s.is_canonical;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> {n_reuse} THEN RAISE EXCEPTION 'reused rows made canonical % (expected {n_reuse})', n; END IF;

  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical)
  SELECT 'eats', p.city_slug, p.new_slug, p.venue_id, true
    FROM jsonb_to_recordset(plan) p(venue_id text, city_slug text, new_slug text)
   WHERE NOT EXISTS (SELECT 1 FROM slugs s WHERE s.property_id = 'eats' AND s.city_slug = p.city_slug AND s.slug = p.new_slug);"""),
        ("IF x <> 132 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 132)'", f"IF x <> {2 * n_plan} THEN RAISE EXCEPTION 'audit rows this transaction % (expected {2 * n_plan})'"),
    ]
    k = 0
    for a, b in reps:
        c = body.count(a)
        assert c >= 1, (a[:70], c)
        k += c; body = body.replace(a, b)
    for bad in [OLD + "'", '3b871e7e', '12843', '1539', '113541', '118825', '132', r'\(expected 72\)', r'\(expected 66\)', r'n_same <> 6 ']:
        assert not re.search(bad, body), bad
    plan_rows = [r for r in rows]  # names for the header only
    head = f"""-- slugs-rename-name-diffs-held8-2026-10-30.sql
-- CompassEats, Oct 30 2026. New canonical slugs for the {N} venues renamed by rename batch
-- {KEY} (docs/rename-name-diffs-held8-2026-10-30.sql). Run only after that batch is applied.
-- Template: docs/slugs-rename-name-diffs-2026-10-30.sql (same method, same checks; the gate finds the batch by its key
-- and checks that the {N} live names equal new_name).
-- Built by script (docs/build_name_diffs_held8_rename.py slug): {len(reps)} rules / {k} counted replacements, leftover check.
-- Method: gated SQL, one transaction, through the Supabase Write connector.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')), Ben's option A (Oct 8).
-- {n_same} of the {N} venues keep their slug (the name changes only in capitals). Plan: {n_plan} rows.
-- For each plan venue: the old canonical row becomes non-canonical (old URL stays and points to the same venue),
-- and a new canonical row is inserted. Reuse ({n_reuse}): La P’tite Patte ve_c4d70b9a92 already has the non-canonical slug
-- cholet/la-p-tite-patte (moved there by the Sep 16 merge of ve_17d83ed8dd, audit 97523); that row becomes canonical
-- again and no row is inserted for it (reuse md5 {fp_reuse}). No row is deleted. No ledger row. 0 blurbs.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id, joined by newline,
-- only rows where new_slug <> old_slug), read Oct 30 from the proposed names before the rename:
--   {fp}  ({n_plan} rows). Checks then: 0 empty, 0 duplicate, 0 in redirects; in use 1 = the reuse row (same venue, non-canonical).
-- Expected before: slugs {B['slugs']:,} (non-canonical {B['noncanon']:,}); audit_log {aud_n2:,} rows, last id {aud_max2:,} (= after the rename).
-- Expected after: slugs {B['slugs'] + n_ins:,}, non-canonical {B['noncanon'] + n_ins:,}, canonical {B['venues']:,};
-- audit +{2 * n_plan} ({n_plan + n_reuse} UPDATE + {n_ins} INSERT).
-- Dry run: send through the Read connector after the rename. All pre-checks run, then the block stops at the
-- first UPDATE with "read-only transaction".

"""
    open(REPO + '/docs/slugs-rename-name-diffs-held8-2026-10-30.sql', 'w', encoding='utf-8', newline='\n').write(head + body)
    print('slug sql: rules', len(reps), 'replacements', k)


if __name__ == '__main__':
    if sys.argv[1] == 'build': build()
    elif sys.argv[1] == 'slug': slug(*sys.argv[2:5])
