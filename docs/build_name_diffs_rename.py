"""Build the name-diffs rename batch (72 venues) from the evidence file and the fresh read.
Inputs (all guarded):
  1. docs/name-diff-evidence-2026-10-30.txt  (sha256 below; the 72 lines whose action starts with 'rename')
  2. fresh72.json  (Read connector, Oct 30 22:36 UTC; md5 of live id|name = file column 3)
  3. SITE_URL: card 'website' link for the 6 rows whose new name follows the venue site, not the card
     (WebFetch of each live Michelin card, Oct 30, ~22:45 UTC).
Outputs: fixtures/rename/name-diffs-2026-10-30.csv, check.sql (read-only), docs/rename-name-diffs-2026-10-30.sql
"""
import json, hashlib, csv, io, re, sys
REPO='/home/claude/compasseats'
EV=REPO+'/docs/name-diff-evidence-2026-10-30.txt'
EV_SHA='751cd15f2cd39c7a7d6fcc00b53e553b7e66b39666f53ac163a9a2e071e1043d'
KEY='rename-name-diffs-2026-10-30'
LIVE_MD5='5ed99ac0a1b92ddf3c7f3887681597ca'
SITE_URL={
 've_8f950e4488':'https://www.unionpasadena.com/',
 've_edecaf0478':'https://www.harryspiccoloporec.com/',
 've_5628da600d':'https://narimorurla.com/fine-dining',
 've_349b73a7ad':'https://adilmuftuoglu.com.tr',
 've_420e6f5990':'https://tavacirecepusta.com.tr',
 've_9b55bcbafd':'https://tavacirecepusta.com.tr/',
}
DAGGER_DECISION="Ben Oct 30 18:35 ET decision 2 = A: rename on site + card agreement (Oct 10 ruling)"
raw=open(EV,'rb').read()
assert hashlib.sha256(raw).hexdigest()==EV_SHA
ren=[]; dataline=0
for l in raw.decode('utf-8').split('\n'):
    if not l or l.startswith('#'): continue
    dataline+=1
    f=l.split('|'); assert len(f)==7
    if f[5].startswith('rename'): ren.append(dict(evline=dataline,vid=f[0],group=f[1],ours=f[2],card=f[3],site=f[4],action=f[5],new=f[6]))
assert dataline==94 and len(ren)==72
fresh=json.load(open('fresh72.json',encoding='utf-8'))[0]
assert fresh['md5_id_name']==LIVE_MD5 and fresh['n_found']==72
live={r['id']:r for r in fresh['rows']}
rows=[]
for i,r in enumerate(ren,1):
    v=live[r['vid']]
    dag=r['ours'].endswith('†')
    exp=r['ours'][:-1] if dag else r['ours']
    assert v['name']==exp, (r['vid'],v['name'],exp)
    assert v['status']=='active' and v['blurbs']==0 and v['prior_rr']==0
    assert r['new']!=exp and r['new']!='-' and r['new']==r['new'].strip()
    card_minus=re.sub(r'\s*\([^()]*\)\s*$','',r['card'])
    urls=[u['u'] for u in v['mich_urls'] if u['y']==2026 and u['u']]
    assert len(urls)==1
    rule=r['action'].replace('rename ','')
    if r['new']==card_minus:
        src,url='michelin',urls[0]
        basis=f'new name = Michelin 2026 card name' + (' minus its branch/ward suffix' if card_minus!=r['card'] else '')
        assert r['vid'] not in SITE_URL
    else:
        src,url='venue',SITE_URL[r['vid']]
        basis=f'new name = venue site spelling (card differs); site = card website link'
    note=(f'Name-diff evidence line {r["evline"]} ({r["group"]}); live "{exp}"; card h1 "{r["card"]}"; '
          f'site read: {r["site"]}; rule {rule}; {basis}; Michelin card {urls[0]}'
          + (f'; non-Michelin award on venue ({v["other"]}); {DAGGER_DECISION}' if dag else '')
          + '; Ben Oct 30 18:35 ET decision 1 = A (rules R1-R5); read Oct 30')
    rows.append(dict(line=i,batch_key=KEY,venue_id=r['vid'],expected_name=exp,new_name=r['new'],
                     source_id=src,source_url=url,note=note,dag=dag,city_id=v['city_id']))
assert sum(r['source_id']=='venue' for r in rows)==6 and sum(r['dag'] for r in rows)==9
# CSV (same columns and quoting as earlier rename fixtures)
buf=io.StringIO(newline='')
w=csv.writer(buf,lineterminator='\n')
cols=['batch_key','venue_id','expected_name','new_name','source_id','source_url','note']
w.writerow(cols)
for r in rows: w.writerow([r[c] for c in cols])
open(REPO+'/fixtures/rename/name-diffs-2026-10-30.csv','w',encoding='utf-8',newline='').write(buf.getvalue())
json.dump(rows,open('rows.json','w',encoding='utf-8'),ensure_ascii=False)
def md5(s): return hashlib.md5(s.encode()).hexdigest()
by=sorted(rows,key=lambda r:r['venue_id'])
M_EXP=md5('\n'.join(f"{r['venue_id']}|{r['expected_name']}" for r in by))
M_NEW=md5('\n'.join(f"{r['venue_id']}|{r['new_name']}" for r in by))
M_ALL=md5('\n'.join('|'.join(str(r[c]) for c in ['line','venue_id','expected_name','new_name','source_id','source_url']) for r in by))
assert M_EXP==LIVE_MD5
print('md5 expected',M_EXP,'new',M_NEW,'rows',M_ALL)
json.dump(dict(M_EXP=M_EXP,M_NEW=M_NEW,M_ALL=M_ALL),open('md5.json','w'))
def q(s): return "'"+s.replace("'","''")+"'"
values=',\n'.join(f"  ({r['line']}, {q(r['venue_id'])}, {q(r['expected_name'])}, {q(r['new_name'])}, {q(r['source_id'])}, {q(r['source_url'])}, {q(r['note'])})" for r in rows)
open('values.sql','w',encoding='utf-8').write(values)
print('ok', len(rows), 'rows; venue', sum(r['source_id']=='venue' for r in rows), 'michelin', sum(r['source_id']=='michelin' for r in rows))
import json, hashlib
rows=json.load(open('rows.json',encoding='utf-8')); m=json.load(open('md5.json'))
KEY='rename-name-diffs-2026-10-30'
def md5(s): return hashlib.md5(s.encode()).hexdigest()
by=sorted(rows,key=lambda r:r['venue_id'])
M_NOTE=md5('\n'.join(f"{r['venue_id']}|{r['note']}" for r in by))
q=lambda s:"'"+s.replace("'","''")+"'"
vals=',\n'.join(f"    ({r['line']}, {q(r['venue_id'])}, {q(r['expected_name'])}, {q(r['new_name'])}, {q(r['source_id'])}, {q(r['source_url'])}, {q(r['note'])})" for r in rows)
BNOTE=("Name differences, card + venue-site read Oct 30 2026 (handoff-name-diffs-read-2026-10-30, evidence file "
       "name-diff-evidence-2026-10-30.txt): 72 of 94 renamed; rules R1-R5 (Ben 1 = A), 9 dagger venues on site + card "
       "agreement (Ben 2 = A); 14 keep, 8 held for a later batch. Run as a gated SQL file through the Write connector, "
       "not the rename job; same writes as scripts/rename/apply.ts.")
JOB=(f"rename-apply:{KEY} | gated SQL file docs/rename-name-diffs-2026-10-30.sql (Write connector), same writes as the job "
     "| 66 rows follow the Michelin 2026 card; 6 rows follow the venue site (source venue, no ledger row)")
sql=f"""-- rename-name-diffs-2026-10-30.sql
-- CompassEats, Oct 30 2026. Rename batch for the 72 "rename" lines of docs/name-diff-evidence-2026-10-30.txt
-- (sha256 751cd15f2cd39c7a7d6fcc00b53e553b7e66b39666f53ac163a9a2e071e1043d, 94 data lines: rename 72, keep 14, hold 8).
-- Ben's decisions (Oct 30 18:35 ET): 1 = A (rules R1-R5), 2 = A (rename the 9 dagger venues on site + card
-- agreement), 3 = the 8 held venues go to a later batch.
-- Input file (same rows): fixtures/rename/name-diffs-2026-10-30.csv (72 rows; source michelin 66, venue 6).
-- Built by script (build.py + mksql.py) from the evidence file and the fresh read; no hand-typed names.
-- Method: gated SQL, one transaction, through the Supabase Write connector. The writes are the same as the
-- rename job (scripts/rename/apply.ts): rename_batches row (staged -> applied), 72 rename_rows (verdict rename,
-- detail = note, live_name, city_id, city_slug, slug), app.allow_rename on for the venues UPDATE only, 1 ledger
-- row per registered publisher (michelin 66; the 6 'venue' rows write no ledger row, as in the job).
-- Guards (md5, ordered by venue_id, joined by newline):
--   live and expected id|name   {m['M_EXP']}  (fresh read Oct 30 22:36 UTC)
--   id|new_name                 {m['M_NEW']}
--   line|id|expected|new|source|url  {m['M_ALL']}
--   id|note                     {M_NOTE}
-- Checks read Oct 30 (read-only): 72 active, 0 blurbs, 0 earlier rename_rows, 0 same-city norm_key collisions
-- on the end state (job's rule), 0 NULL norm_key; norm_key unchanged on 7.
-- Dry run: send through the Read connector. All pre-checks run, then the block stops at the first INSERT
-- with "read-only transaction".
-- Expected after: rename_batches +1 (applied), rename_rows 1,114 -> 1,186, ledger +1, audit_log +72
-- (72 venues UPDATE, name and norm_key only). venues, awards, slugs, listings, blurbs unchanged.
-- Slugs follow in docs/slugs-rename-name-diffs-2026-10-30.sql (66 plan rows, 6 keep).

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
  IF n <> 72 OR x <> 72 THEN RAISE EXCEPTION 'input rows % / distinct venues % (expected 72 / 72)', n, x; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.expected_name, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text)) <> '{m['M_EXP']}' THEN
    RAISE EXCEPTION 'input guard id|expected_name failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.new_name, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, new_name text)) <> '{m['M_NEW']}' THEN
    RAISE EXCEPTION 'input guard id|new_name failed'; END IF;
  IF (SELECT md5(string_agg(p.line||'|'||p.venue_id||'|'||p.expected_name||'|'||p.new_name||'|'||p.source_id||'|'||p.source_url,
                            E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(line int, venue_id text, expected_name text, new_name text, source_id text, source_url text))
       <> '{m['M_ALL']}' THEN
    RAISE EXCEPTION 'input guard rows failed'; END IF;
  IF (SELECT md5(string_agg(p.venue_id||'|'||p.note, E'\\n' ORDER BY p.venue_id))
        FROM jsonb_to_recordset(plan) p(venue_id text, note text)) <> '{M_NOTE}' THEN
    RAISE EXCEPTION 'input guard notes failed'; END IF;

  -- 2. Pre-checks against live data
  SELECT count(*) INTO x FROM rename_batches WHERE batch_key = '{KEY}';
  IF x <> 0 THEN RAISE EXCEPTION 'batch key already used: %', x; END IF;

  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{m['M_EXP']}' THEN
    RAISE EXCEPTION 'live names differ from the Oct 30 read (a name moved)'; END IF;

  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id
   WHERE v.status = 'active';
  IF x <> 72 THEN RAISE EXCEPTION 'active venues % (expected 72)', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(new_name text, expected_name text)
   WHERE btrim(p.new_name) = '' OR p.new_name <> btrim(p.new_name) OR p.new_name = p.expected_name;
  IF x <> 0 THEN RAISE EXCEPTION 'empty, untrimmed or unchanged new names: %', x; END IF;

  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id NOT IN ('michelin', 'venue');
  IF x <> 0 THEN RAISE EXCEPTION 'unexpected source_id: %', x; END IF;
  SELECT count(*) INTO x FROM jsonb_to_recordset(plan) p(source_id text) WHERE p.source_id = 'michelin';
  IF x <> 66 THEN RAISE EXCEPTION 'michelin rows % (expected 66)', x; END IF;
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

  SELECT count(*) INTO x FROM venues;          IF x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> 23353 THEN RAISE EXCEPTION 'awards before % (expected 23353)', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> 12843 THEN RAISE EXCEPTION 'slugs before % (expected 12843)', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> 142 THEN RAISE EXCEPTION 'blurbs before % (expected 142)', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> 14 THEN RAISE EXCEPTION 'rename_batches before % (expected 14)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> 1114 THEN RAISE EXCEPTION 'rename_rows before % (expected 1114)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 118 OR led_max <> 162 THEN RAISE EXCEPTION 'ledger before % rows, last id % (expected 118, 162)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 113469 OR aud_max <> 118753 THEN
    RAISE EXCEPTION 'audit_log before % rows, last id % (expected 113469, 118753)', aud_n, aud_max; END IF;

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
  IF n <> 72 THEN RAISE EXCEPTION 'rename_rows inserted % (expected 72)', n; END IF;

  PERFORM set_config('app.allow_rename', 'on', true);
  UPDATE venues v SET name = p.new_name
    FROM jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
   WHERE v.id = p.venue_id AND v.name = p.expected_name;
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM set_config('app.allow_rename', 'off', true);
  IF n <> 72 THEN RAISE EXCEPTION 'venues renamed % (expected 72)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job)
  VALUES ('michelin', 'name', 66, {q(JOB)});

  UPDATE rename_batches SET status = 'applied', applied_at = now() WHERE id = bid AND status = 'staged';
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'batch status update % (expected 1)', n; END IF;

  -- 4. Post-checks (the job's invariants)
  SELECT count(*) INTO x FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text, new_name text) ON p.venue_id = v.id
   WHERE v.name IS DISTINCT FROM p.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'venues whose live name is not new_name: %', x; END IF;
  IF (SELECT md5(string_agg(v.id||'|'||v.name, E'\\n' ORDER BY v.id))
        FROM venues v JOIN jsonb_to_recordset(plan) p(venue_id text) ON p.venue_id = v.id) <> '{m['M_NEW']}' THEN
    RAISE EXCEPTION 'live id|name after differs from the file'; END IF;

  SELECT count(*) INTO x FROM venues;          IF x <> 11304 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM awards;          IF x <> 23353 THEN RAISE EXCEPTION 'awards changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;           IF x <> 12843 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM listings;        IF x <> 11304 THEN RAISE EXCEPTION 'listings changed: %', x; END IF;
  SELECT count(*) INTO x FROM blurbs;          IF x <> 142 THEN RAISE EXCEPTION 'blurbs changed: %', x; END IF;
  SELECT count(*) INTO x FROM rename_batches;  IF x <> 15 THEN RAISE EXCEPTION 'rename_batches after % (expected 15)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows;     IF x <> 1186 THEN RAISE EXCEPTION 'rename_rows after % (expected 1186)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid AND verdict = 'rename';
  IF x <> 72 THEN RAISE EXCEPTION 'rename_rows in this batch % (expected 72)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 119 THEN RAISE EXCEPTION 'ledger after % (expected 119)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'name' AND items = 66 AND job LIKE 'rename-apply:{KEY} |%';
  IF x <> 1 THEN RAISE EXCEPTION 'ledger row for this batch % (expected 1)', x; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 72 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 72)', x; END IF;
  SELECT count(*) INTO x FROM audit_log a JOIN jsonb_to_recordset(plan) p(venue_id text, expected_name text, new_name text)
      ON a.row_pk = p.venue_id
   WHERE a.id > aud_max AND a.table_name = 'venues' AND a.action = 'UPDATE' AND a.at = transaction_timestamp()
     AND a.old_row->>'name' = p.expected_name AND a.new_row->>'name' = p.new_name
     AND (a.old_row - 'name' - 'norm_key') = (a.new_row - 'name' - 'norm_key');
  IF x <> 72 THEN RAISE EXCEPTION 'audit venue renames (name and norm_key only) % (expected 72)', x; END IF;
END
$do$;
COMMIT;
"""
open('/home/claude/compasseats/docs/rename-name-diffs-2026-10-30.sql','w',encoding='utf-8',newline='\n').write(sql)
json.dump(dict(M_NOTE=M_NOTE),open('md5_note.json','w'))
print('written', len(sql.encode()), 'bytes', sql.count('\n'), 'lines')
import re
T=open('/home/claude/compasseats/docs/slugs-rename-michelin-2026-american-south.sql',encoding='utf-8').read()
body=T[T.index('BEGIN;\nDO $do$'):]
KEY='rename-name-diffs-2026-10-30'
reps=[
 ("  fp          text;\n", "  fp          text;\n  bid         bigint;\n"),
 ("""  SELECT count(*) INTO x FROM rename_batches WHERE id = 28 AND status = 'applied'
     AND batch_key = 'rename-michelin-2026-american-south';
  IF x <> 1 THEN RAISE EXCEPTION 'rename batch 28 applied: % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = 28;
  IF x <> 12 THEN RAISE EXCEPTION 'rename_rows batch 28: % (expected 12)', x; END IF;""",
  f"""  SELECT count(*), max(id) INTO x, bid FROM rename_batches WHERE status = 'applied'
     AND batch_key = '{KEY}';
  IF x <> 1 THEN RAISE EXCEPTION 'rename batch {KEY} applied: % (expected 1)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows WHERE batch_id = bid;
  IF x <> 72 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 72)', x; END IF;
  SELECT count(*) INTO x FROM rename_rows r JOIN venues v ON v.id = r.venue_id
   WHERE r.batch_id = bid AND v.name IS DISTINCT FROM r.new_name;
  IF x <> 0 THEN RAISE EXCEPTION 'batch venues whose live name is not new_name: %', x; END IF;"""),
 ("WHERE r.batch_id = 28", "WHERE r.batch_id = bid"),
 ("n_all <> 12 THEN RAISE EXCEPTION 'batch 28 venues with a canonical slug % (expected 12)'", "n_all <> 72 THEN RAISE EXCEPTION 'batch venues with a canonical slug % (expected 72)'"),
 ("n_same <> 3 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 3)'", "n_same <> 6 THEN RAISE EXCEPTION 'venues that keep their slug % (expected 6)'"),
 ("n_plan <> 9 THEN RAISE EXCEPTION 'plan rows % (expected 9)'", "n_plan <> 66 THEN RAISE EXCEPTION 'plan rows % (expected 66)'"),
 ("fp <> 'c21800ea49ef95c5096a8a31f4498299' THEN\n    RAISE EXCEPTION 'plan fingerprint % differs from the Oct 27 read', fp;",
  "fp <> '3b871e7ea11cc1349e060b33b2672bb1' THEN\n    RAISE EXCEPTION 'plan fingerprint % differs from the Oct 30 read', fp;"),
 ("IF x <> 9 THEN RAISE EXCEPTION 'distinct venues % (expected 9)'", "IF x <> 66 THEN RAISE EXCEPTION 'distinct venues % (expected 66)'"),
 ("x <> 12832 THEN RAISE EXCEPTION 'slugs before % (expected 12832)'", "x <> 12843 THEN RAISE EXCEPTION 'slugs before % (expected 12843)'"),
 ("x <> 1525 THEN RAISE EXCEPTION 'non-canonical before % (expected 1525)'", "x <> 1539 THEN RAISE EXCEPTION 'non-canonical before % (expected 1539)'"),
 ("x <> 11307 THEN RAISE EXCEPTION 'venues before % (expected 11307)'", "x <> 11304 THEN RAISE EXCEPTION 'venues before % (expected 11304)'"),
 ("x <> 22922 THEN RAISE EXCEPTION 'awards before % (expected 22922)'", "x <> 23353 THEN RAISE EXCEPTION 'awards before % (expected 23353)'"),
 ("x <> 11307 THEN RAISE EXCEPTION 'listings before % (expected 11307)'", "x <> 11304 THEN RAISE EXCEPTION 'listings before % (expected 11304)'"),
 ("aud_n <> 107654 THEN RAISE EXCEPTION 'audit_log before % (expected 107654)'", "aud_n <> 113541 THEN RAISE EXCEPTION 'audit_log before % (expected 113541)'"),
 ("aud_max <> 112938 THEN RAISE EXCEPTION 'audit_log last id % (expected 112938)'", "aud_max <> 118825 THEN RAISE EXCEPTION 'audit_log last id % (expected 118825)'"),
 ("IF n <> 9 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 9)'", "IF n <> 66 THEN RAISE EXCEPTION 'old canonical rows updated % (expected 66)'"),
 ("IF n <> 9 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 9)'", "IF n <> 66 THEN RAISE EXCEPTION 'new canonical rows inserted % (expected 66)'"),
 ("x <> 12841 THEN RAISE EXCEPTION 'slugs after % (expected 12841)'", "x <> 12909 THEN RAISE EXCEPTION 'slugs after % (expected 12909)'"),
 ("x <> 1534 THEN RAISE EXCEPTION 'non-canonical after % (expected 1534)'", "x <> 1605 THEN RAISE EXCEPTION 'non-canonical after % (expected 1605)'"),
 ("x <> 11307 THEN RAISE EXCEPTION 'canonical after % (expected 11307)'", "x <> 11304 THEN RAISE EXCEPTION 'canonical after % (expected 11304)'"),
 ("IF x <> 9 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 9)'", "IF x <> 66 THEN RAISE EXCEPTION 'venues with new canonical and old non-canonical: % (expected 66)'"),
 ("x <> 11307 THEN RAISE EXCEPTION 'venues changed: %'", "x <> 11304 THEN RAISE EXCEPTION 'venues changed: %'"),
 ("x <> 22922 THEN RAISE EXCEPTION 'awards changed: %'", "x <> 23353 THEN RAISE EXCEPTION 'awards changed: %'"),
 ("x <> 11307 THEN RAISE EXCEPTION 'listings changed: %'", "x <> 11304 THEN RAISE EXCEPTION 'listings changed: %'"),
 ("IF x <> 9 THEN RAISE EXCEPTION 'audit slug updates % (expected 9)'", "IF x <> 66 THEN RAISE EXCEPTION 'audit slug updates % (expected 66)'"),
 ("IF x <> 9 THEN RAISE EXCEPTION 'audit slug inserts % (expected 9)'", "IF x <> 66 THEN RAISE EXCEPTION 'audit slug inserts % (expected 66)'"),
 ("IF x <> 18 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 18)'", "IF x <> 132 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 132)'"),
]
n=0
for a,b in reps:
    c=body.count(a)
    assert c>=1,(a[:60],c)
    n+=c; body=body.replace(a,b)
# leftover check: no old numbers or batch 28 remain
for bad in ['28','12832','1525','11307','22922','107654','112938','12841','1534','c21800ea','Oct 27']:
    assert not re.search(r'\b'+re.escape(bad)+r'\b',body),bad
head=f"""-- slugs-rename-name-diffs-2026-10-30.sql
-- CompassEats, Oct 30 2026. New canonical slugs for the 72 venues renamed by rename batch
-- {KEY} (docs/rename-name-diffs-2026-10-30.sql). Run only after that batch is applied.
-- Template: docs/slugs-rename-michelin-2026-american-south.sql (same method, same checks; the gate now finds the
-- batch by its key, checks that the 72 live names equal new_name, and 6 venues keep their slug).
-- Built by script (mkslug.py): {len(reps)} rules / {n} counted replacements, leftover check.
-- Method: gated SQL, one transaction, through the Supabase Write connector.
-- Slug rule: trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g')),
-- Ben's option A (Oct 8).
-- 6 of the 72 venues keep their slug (Seline, Boda, Bar Citra, Soichi, Gostilna Francl, Teruar Urla). Plan: 66 rows.
-- The 2 venues named Tavacı Recep Usta are in different cities (izmir, istanbul): no clash.
-- For each plan venue: the old canonical row becomes non-canonical (old URL stays and points to the same venue),
-- and a new canonical row is inserted. No row is deleted. No ledger row. 0 blurbs on these venues.
-- Plan fingerprint (md5 of venue_id|name|city_slug|old_slug|new_slug, ordered by venue_id, joined by newline,
-- only rows where new_slug <> old_slug), read Oct 30 from the proposed names before the rename:
--   3b871e7ea11cc1349e060b33b2672bb1  (66 rows). Checks then: 0 empty, 0 duplicate, 0 in use, 0 in redirects.
-- Expected before: slugs 12,843 (non-canonical 1,539); audit_log 113,541 rows, last id 118,825 (= after the rename).
-- Expected after: slugs 12,909, non-canonical 1,605, canonical 11,304; audit +132 (66 UPDATE + 66 INSERT).
-- Dry run: send through the Read connector after the rename. All pre-checks run, then the block stops at the
-- first UPDATE with "read-only transaction".

"""
open('/home/claude/compasseats/docs/slugs-rename-name-diffs-2026-10-30.sql','w',encoding='utf-8',newline='\n').write(head+body)
print('rules',len(reps),'replacements',n)
