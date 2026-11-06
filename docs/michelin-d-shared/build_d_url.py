#!/usr/bin/env python3
"""Group D, shared: set the /us/en/ card URL on Michelin rows of the latest label that have none. URL only. One transaction.
Run from the country folder: python3 ../michelin-d-shared/build_d_url.py config.json <scope_fp> [approval] [scratch]
Folder inputs: config.json, baseline.json, pairs.tsv (slug, venue_id, award_id), relay file + relay.sha256.
config.json keys: key, iso, guide, label, year, rule (ledger text: edition, date, article URL), relay,
  have_url: [[award_id, venue_id, slug], ...] rows that already hold their card URL, rows_after: rows of that year in scope.
  article: optional [[award_id, venue_id, category, url, rows_already_on_url, note], ...] for a card that left the site (rule of the A2-E handoff).
  art_kind: optional, 'article' (default) or 'capture' (archive capture URL); sets the ledger and evidence wording only.
  other_url: optional [[award_id, venue_id, slug, current_url, 'keep'|'replace'], ...] rows that hold another URL for the card (for example another locale).
    keep: gate that the row still holds current_url. replace: gate current_url, then set the /us/en/ card URL."""
import csv, hashlib, json, re, sys
C = json.load(open(sys.argv[1])); FP = sys.argv[2]
APPROVAL = sys.argv[3] if len(sys.argv) > 3 else 'DRAFT, choices not yet given'; SCRATCH = sys.argv[4] if len(sys.argv) > 4 else '.'
B = json.load(open('baseline.json')); md5 = lambda t: hashlib.md5(t.encode()).hexdigest()
KEY, ISO, Y, RELAY = C['key'], C['iso'], C['year'], C['relay']
SHA = open('relay.sha256').read().split()[0]
SCOPE = f"c.country_iso = '{ISO}'"
dec = lambda s: re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
rel = open(RELAY, encoding='ascii').read(); assert hashlib.sha256(rel.encode()).hexdigest() == SHA
cards = {}
for line in rel.split('\n'):
    cat, href, name, loc, pr, lab, guide, st, final, closed = dec(line).split(' | ')
    assert lab == C['label'] and guide == C['guide'] and st == '200' and final == href and closed == '-', line
    cards[href.split('/restaurant/')[1]] = dict(cat=cat, url='https://guide.michelin.com' + href, name=name, loc=loc, pr=pr)
pairs = [l.split('\t') for l in open('pairs.tsv', encoding='utf8').read().strip().split('\n')]
have = {s: (a, v) for a, v, s in C['have_url']}
OTH = C.get('other_url', []); oth = {s: (a, v, u, k) for a, v, s, u, k in OTH}; assert all(k in ('keep', 'replace') for *_, k in OTH)
sets = [{p[0] for p in pairs}, set(have), set(oth)]
assert set().union(*sets) == set(cards) and sum(map(len, sets)) == len(cards), 'pairs + have_url + other_url must cover the cards once'
assert len({p[2] for p in pairs}) == len(pairs)
rl = sorted((int(a), f"{a}~{v}~{cards[s]['cat']}~{cards[s]['url']}") for s, v, a in pairs)
RL = '\n'.join(x for _, x in rl); N = len(rl); RA = C['rows_after']
ART = C.get('article', []); NA = len(ART)
REPL = sorted((int(a), f"{a}~{v}~{cards[s]['cat']}~{u}~{cards[s]['url']}") for a, v, s, u, k in OTH if k == 'replace'); NR = len(REPL); RL3 = '\n'.join(x for _, x in REPL)
KEEP = [(a, v, u) for a, v, s, u, k in OTH if k == 'keep']
AK = C.get('art_kind', 'article'); ART_TXT = {'article': ('article URL (card left the site, no capture after the ceremony)', ' (article)', 'article url set: '), 'capture': ('archive capture URL (card left the site, capture after the ceremony)', ' (archive capture)', 'capture url set: ')}[AK]
RL2 = '\n'.join(f"{a}~{v}~{c}~{u}" for a, v, c, u, k, note in sorted(ART))
art_gate = ''.join(f"  IF (SELECT count(*) FROM awards WHERE source_url='{u}') <> {k} THEN RAISE EXCEPTION 'article url rows {a}'; END IF;\n" for a, v, c, u, k, note in ART)
art_pre = (f"""  IF md5(rl2) <> '{md5(RL2)}' THEN RAISE EXCEPTION 'article plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl2,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>{Y} OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'article plan rows %', n; END IF;
""" + art_gate) if ART else ''
art_write = (f"""  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl2,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {NA} THEN RAISE EXCEPTION 'article urls %', n; END IF;
""") if ART else ''
art_line = f" {NA} rows get the {'article' if AK == 'article' else 'archive capture'} URL." if ART else ''
rl2_decl = f"  rl2 text := $plan${RL2}$plan$;\n" if ART else ''
art_note = (' | ' + ART_TXT[0] + ': ' + '; '.join(f"{a} {note}" for a, v, c, u, k, note in ART)) if ART else ''
KV = ', '.join(f"({a}, '{v}', '{u}')" for a, v, u in KEEP)
oth_pre = (f"  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ({KV})) <> {len(KEEP)} THEN RAISE EXCEPTION 'rows kept'; END IF;\n" if KEEP else '') + (f"""  IF md5(rl3) <> '{md5(RL3)}' THEN RAISE EXCEPTION 'replace plan text'; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl3,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>{Y} OR a.source_id<>'michelin' OR a.source_url IS DISTINCT FROM split_part(x,'~',4);
  IF n <> 0 THEN RAISE EXCEPTION 'replace plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',5) FROM regexp_split_to_table(rl3,E'\\n') x)) THEN RAISE EXCEPTION 'replace url in use'; END IF;
""" if REPL else '')
oth_write = (f"""  UPDATE awards a SET source_url=split_part(x,'~',5) FROM regexp_split_to_table(rl3,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {NR} THEN RAISE EXCEPTION 'replaced urls %', n; END IF;
""") if REPL else ''
rl3_decl = f"  rl3 text := $plan${RL3}$plan$;\n" if REPL else ''
oth_note = (' | other card URL: ' + '; '.join(f"{a} {'kept' if k == 'keep' else 'replaced'} {u}" for a, v, s, u, k in OTH)) if OTH else ''
oth_line = (f' {len(KEEP)} rows keep another URL of their card.' if KEEP else '') + (f' {NR} rows have another URL of their card replaced by the /us/en/ card URL.' if REPL else '')
HV = ', '.join(f"({a}, '{v}', '{cards[s]['url']}')" for a, v, s in C['have_url'])
have_gate = (f"  IF (SELECT count(*) FROM awards WHERE (id, venue_id, source_url) IN ({HV})) <> {len(have)} THEN RAISE EXCEPTION 'rows with URL'; END IF;\n") if have else ''
led = f"('michelin','award',{N+NA+NR},'cleanup:{KEY} | {C['rule']} | year stays {Y}, source_url = the card (/us/en/), all {len(cards)} card labels {C['label']} read Nov 6 2026, retire 0{art_note}{oth_note} | relay sha256 {SHA} | {APPROVAL}')"
sql = f"""-- {KEY}.sql
-- CompassEats, Nov 6 2026. Michelin group D {C['guide']}. {APPROVAL}. This file runs only after Ben's "go".
-- {N} rows keep year {Y} and get the card URL.{art_line}{oth_line} Relabel 0. Retire 0. No new rows, no new venues, no closures.
-- Source: {RELAY} sha256 {SHA}.
-- Expected after: awards {B['a']} unchanged; ledger {B['led']+1} rows; audit_log +{N+NA+NR}.
BEGIN;
DO $load$
DECLARE
  rl text := $plan${RL}$plan$;
{rl2_decl}{rl3_decl}  n bigint; s text; fp text; u1 bigint; u2 bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '{md5(RL)}' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||a.year||'|'||v.status||'|'||v.city_id||'|'||v.name||'|'||coalesce(a.source_url,'-') t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND {SCOPE}) y;
  IF fp IS DISTINCT FROM '{FP}' THEN RAISE EXCEPTION 'scope fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> {B['v']} OR (SELECT count(*) FROM venues WHERE status='active') <> {B['va']} OR (SELECT count(*) FROM venues WHERE status='closed') <> {B['vc']} THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> {B['a']} OR (SELECT max(id) FROM awards) <> {B['last']} THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> {B['m25']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> {B['m27']} THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> {B['sum']} OR (SELECT count(*) FROM source_capture_ledger) <> {B['led']} OR (SELECT max(id) FROM source_capture_ledger) <> {B['ledm']} THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  SELECT count(*), max(id) INTO u1, u2 FROM audit_log; IF u1 <> {B['au']} OR u2 <> {B['aum']} THEN RAISE EXCEPTION 'audit before % / %', u1, u2; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\\n') x LEFT JOIN awards a ON a.id=split_part(x,'~',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'~',2) OR a.category<>split_part(x,'~',3) OR a.year<>{Y} OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'plan rows %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
{have_gate}{oth_pre}{art_pre}  -- WRITE: start
  UPDATE awards a SET source_url=split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x WHERE a.id=split_part(x,'~',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> {N} THEN RAISE EXCEPTION 'urls %', n; END IF;
{art_write}{oth_write}  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    {led};
  -- POST gates
  IF (SELECT count(*) FROM awards) <> {B['a']} THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> {B['m26']} THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT count(*), count(a.source_url) INTO n, u1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND a.year={Y} AND {SCOPE};
  IF n <> {RA} OR u1 <> {RA} THEN RAISE EXCEPTION 'urls after % %', n, u1; END IF;
  SELECT count(*) INTO n FROM (SELECT source_url FROM awards WHERE source_id='michelin' AND source_url IS NOT NULL GROUP BY 1 HAVING count(*) > 1) d
    WHERE source_url IN (SELECT split_part(x,'~',4) FROM regexp_split_to_table(rl,E'\\n') x);
  IF n <> 0 THEN RAISE EXCEPTION 'url repeats %', n; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> {B['led']+1} THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > {B['aum']} GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:UPDATE={N+NA+NR}' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
"""
open(KEY + '.sql', 'w', encoding='utf8').write(sql)
do = sql[sql.index('DO $load$'):sql.index('COMMIT;')]; cut = do.index('  -- WRITE: start')
open(f"{SCRATCH}/dry-{ISO.lower()}.sql", 'w', encoding='utf8').write(do[:cut] + "  UPDATE awards SET year=2026 WHERE id=-1;\nEND\n$load$;\n")
with open(KEY.replace('load-', '') + '-evidence.csv', 'w', newline='', encoding='utf8') as f:
    w = csv.writer(f); w.writerow(['card_slug', 'card_category', 'card_name', 'card_city', 'card_price', 'card_url', 'card_label', 'venue_id', 'award_id', 'action'])
    for s in sorted(cards):
        c = cards[s]; p = next((p for p in pairs if p[0] == s), None)
        if p: v, a, act = p[1], p[2], 'url set'
        elif s in have: v, a, act = have[s][1], have[s][0], 'url already set'
        else: a, v, u, k = oth[s]; act = ('url kept: ' if k == 'keep' else 'url replaced, was: ') + u
        w.writerow([s, c['cat'], c['name'], c['loc'].split(', ')[0], c['pr'].split(' · ')[0], c['url'], C['label'], v, a, act])
if ART:
    with open(KEY.replace('load-', '') + '-evidence.csv', 'a', newline='', encoding='utf8') as f:
        w = csv.writer(f)
        for a, v, c, u, k, note in ART: w.writerow(['(card left the site)', c, '', '', '', u, C['label'] + ART_TXT[1], v, a, ART_TXT[2] + note])
print(KEY, 'sha256', hashlib.sha256(sql.encode()).hexdigest(), 'chars', len(sql), 'rows', N, 'plan md5', md5(RL))
