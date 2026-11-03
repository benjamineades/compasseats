#!/usr/bin/env python3
"""Build the Swiss rename batch and slug file from the evidence CSV. CompassEats, Nov 2 2026.
Templates: docs/rename-michelin-2026-hong-kong-macau.sql, docs/slugs-rename-michelin-2026-hong-kong-macau.sql.
Usage (repo root): python3 -I docs/ch-2026-build/build_rename_ch_2026_11_02.py <live md5> <slug fingerprint> <plan rows> <keep rows>"""
import csv,hashlib,re,sys
LIVE,FP,NP,NKEEP=sys.argv[1],sys.argv[2],int(sys.argv[3]),int(sys.argv[4])
EV='docs/ch-2026-build/name-diff-evidence-ch-2026-11-02.csv'
KEY='rename-michelin-2026-switzerland'; DEC='Ben Nov 2 23:04 ET "1&4", 23:25 ET "A"'
ALLROWS=list(csv.DictReader(open(EV,encoding='utf-8')))
rows=[r for r in ALLROWS if r['action']=='rename']
N=len(rows);NM=sum(r['source_id']=='michelin' for r in rows);NV=N-NM
rows.sort(key=lambda r:int(r['line']))
for i,r in enumerate(rows,1):
    r['L']=i
    r['note']=f'CH name-diff evidence line {r["line"]}; live "{r["live_name"]}"; card h1 "{r["card_name"]}"; site read: {r["site_read"]}; rule {r["rule"]}; Michelin card {r["card_url"]}; {DEC}'
md5=lambda s:hashlib.md5(s.encode('utf-8')).hexdigest()
by=sorted(rows,key=lambda r:r['venue_id'])
M1=md5('\n'.join(f"{r['venue_id']}|{r['live_name']}" for r in by)); assert M1==LIVE,(M1,LIVE)
M2=md5('\n'.join(f"{r['venue_id']}|{r['new_name']}" for r in by))
M3=md5('\n'.join(f"{r['L']}|{r['venue_id']}|{r['live_name']}|{r['new_name']}|{r['source_id']}|{r['source_url']}" for r in by))
M4=md5('\n'.join(f"{r['venue_id']}|{r['note']}" for r in by))
q=lambda s:"'"+s.replace("'","''")+"'"
vals=',\n'.join(f"    ({r['L']}, {q(r['venue_id'])}, {q(r['live_name'])}, {q(r['new_name'])}, {q(r['source_id'])}, {q(r['source_url'])}, {q(r['note'])})" for r in rows)
# fixture
hk=open('fixtures/rename/michelin-2026-hong-kong-macau.csv',encoding='utf-8',newline='').readline().strip()
cols=[c.strip('"') for c in hk.split(',')]
w=csv.writer(open('fixtures/rename/michelin-2026-switzerland.csv','w',encoding='utf-8',newline=''),lineterminator='\n');w.writerow(cols)
for r in rows:
    d=dict(batch_key=KEY,venue_id=r['venue_id'],expected_name=r['live_name'],new_name=r['new_name'],source_id=r['source_id'],source_url=r['source_url'],note=r['note'])
    assert set(cols)<=set(d),cols
    w.writerow([d[c] for c in cols])
# counts read Nov 3 04:29 UTC
V,A,S,NC,LI,B,RB,RR,LN,LM,AN,AM=11323,25321,13053,1730,11323,142,30,1302,189,243,119235,125064
t=open('docs/rename-michelin-2026-hong-kong-macau.sql',encoding='utf-8').read()
body=t[t.index('BEGIN;\n'):]
body,c=re.subn(r"FROM \(VALUES\n.*?\n  \) AS t\(line",lambda m:'FROM (VALUES\n'+vals+'\n  ) AS t(line',body,flags=re.S);assert c==1
note=f"Swiss 2026 name differences (Michelin 2026 card read and venue-site read Nov 2 2026, evidence file {EV}): {N} of 107 rename, 12 keep, 1 hold; item 1 of the Swiss open items; {DEC}"
body,c=re.subn(r"VALUES \('rename-michelin-2026-hong-kong-macau', 'staged', '.*?'\)\n",lambda m:f"VALUES ({q(KEY)}, 'staged', {q(note)})\n",body,flags=re.S);assert c==1
job=f"rename-apply:{KEY} | gated SQL file docs/{KEY}.sql (Write connector), same writes as the job | {NM} rows source michelin, {NV} rows source venue write no ledger row | {DEC}"
body,c=re.subn(r"VALUES \('michelin', 'name', 62, '.*?'\);",lambda m:f"VALUES ('michelin', 'name', {NM}, {q(job)});",body,flags=re.S);assert c==1
reps=[('4f152108531406dbd60d0a236c35ea50',M1),('54a197ce00838a8281751082dea80d20',M2),('d6facabcce56b9ad49bd56e4f532387f',M3),('61829128e7d7502e06c4c283fd9973f8',M4),
('rename-michelin-2026-hong-kong-macau',KEY),('differ from the Nov 1 read','differ from the Nov 3 04:29 UTC read'),
("IF x <> 1 THEN RAISE EXCEPTION 'blurbs on batch venues % (expected 1, Forum)', x; END IF;","IF x <> 0 THEN RAISE EXCEPTION 'blurbs on batch venues % (expected 0)', x; END IF;"),
("n <> 66 OR x <> 66","n <> %d OR x <> %d"%(N,N)),("(expected 66 / 66)","(expected %d / %d)"%(N,N)),
("x <> 62 THEN RAISE EXCEPTION 'michelin rows % (expected 62)'",f"x <> {NM} THEN RAISE EXCEPTION 'michelin rows % (expected {NM})'"),
("items = 62",f"items = {NM}"),
("x <> 11300","x <> %d"%V),("(expected 11300)","(expected %d)"%V),("x <> 23368","x <> %d"%A),("(expected 23368)","(expected %d)"%A),
("x <> 12952","x <> %d"%S),("(expected 12952)","(expected %d)"%S),("x <> 142","x <> %d"%B),
("x <> 20 THEN RAISE EXCEPTION 'rename_batches before % (expected 20)'",f"x <> {RB} THEN RAISE EXCEPTION 'rename_batches before % (expected {RB})'"),
("x <> 1211 THEN RAISE EXCEPTION 'rename_rows before % (expected 1211)'",f"x <> {RR} THEN RAISE EXCEPTION 'rename_rows before % (expected {RR})'"),
("led_n <> 155 OR led_max <> 205",f"led_n <> {LN} OR led_max <> {LM}"),("(expected 155, 205)",f"(expected {LN}, {LM})"),
("aud_n <> 115757 OR aud_max <> 121095",f"aud_n <> {AN} OR aud_max <> {AM}"),("(expected 115757, 121095)",f"(expected {AN}, {AM})"),
("x <> 21 THEN RAISE EXCEPTION 'rename_batches after % (expected 21)'",f"x <> {RB+1} THEN RAISE EXCEPTION 'rename_batches after % (expected {RB+1})'"),
("x <> 1277 THEN RAISE EXCEPTION 'rename_rows after % (expected 1277)'",f"x <> {RR+N} THEN RAISE EXCEPTION 'rename_rows after % (expected {RR+N})'"),
("x <> 156 THEN RAISE EXCEPTION 'ledger after % (expected 156)'",f"x <> {LN+1} THEN RAISE EXCEPTION 'ledger after % (expected {LN+1})'"),
]
for a,b in reps:
    assert a in body,a; body=body.replace(a,b)
body=re.sub(r"(<> )66( THEN RAISE EXCEPTION '[^']*\(expected )66\)",lambda m:f"{m[1]}{N}{m[2]}{N})",body)
head=f"""-- {KEY}.sql
-- CompassEats, Nov 2 2026. Rename batch for the {N} "rename" lines of {EV}
-- (107 data lines: rename {N}, keep 12, hold 1). Rules R1-R5 (Oct 30). {DEC}.
-- Fixture: fixtures/rename/michelin-2026-switzerland.csv ({N} rows; source michelin {NM}, venue {NV}).
-- Built by docs/ch-2026-build/build_rename_ch_2026_11_02.py; no hand-typed names in this step.
-- Method: gated SQL, one transaction, Supabase Write connector; same writes as scripts/rename/apply.ts.
-- Guards: live id|name {M1}; id|new {M2}; rows {M3}; notes {M4}.
-- Expected after: rename_batches {RB} -> {RB+1}, rename_rows {RR} -> {RR+N}, ledger {LN} -> {LN+1} (last id {LM} -> {LM+1}),
-- audit_log +{N} (venues UPDATE, name and norm_key only). Slugs follow in docs/slugs-{KEY}.sql.

"""
out=head+body
for bad in ['hong-kong','HK/MO','11300','23368','12952','115757','121095']:
    assert bad not in out,bad
left=re.findall(r".*\b(?:66|62)\b.*",body.split('AS t(line')[1])
print('leftover 66/62 lines',left)
open(f'docs/{KEY}.sql','w',encoding='utf-8',newline='\n').write(out)
# slugs
t=open('docs/slugs-rename-michelin-2026-hong-kong-macau.sql',encoding='utf-8').read()
b=t[t.index('BEGIN;\n'):]
NJ="ve_6cedf32a8c"
old="""    FROM rename_rows r
    JOIN venues v ON v.id = r.venue_id
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE r.batch_id = bid"""
new=f"""    FROM venues v
    JOIN slugs  s ON s.venue_id = v.id AND s.property_id = 'eats' AND s.is_canonical
    WHERE v.id IN (SELECT r.venue_id FROM rename_rows r WHERE r.batch_id = bid) OR v.id = '{NJ}'"""
assert b.count(old)==2; b=b.replace(old,new)
SA,NCA=S+NP,NC+NP
sr=[('rename-michelin-2026-hong-kong-macau',KEY),('9e682a117c541d0747eb52c43ebe9966',FP),('differs from the Nov 1 read','differs from the Nov 3 read'),
("IF x <> 66 THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected 66)'",f"IF x <> {N} THEN RAISE EXCEPTION 'rename_rows of the batch: % (expected {N})'"),
("n_all <> 66",f"n_all <> {N+1}"),("(expected 66)'",f"(expected {N+1})'"),("n_same <> 17",f"n_same <> {NKEEP}"),("(expected 17)",f"(expected {NKEEP})"),
("x <> 12952","x <> %d"%S),("(expected 12952)","(expected %d)"%S),("x <> 1652","x <> %d"%NC),("(expected 1652)","(expected %d)"%NC),
("x <> 11300","x <> %d"%V),("(expected 11300)","(expected %d)"%V),("x <> 23368","x <> %d"%A),("(expected 23368)","(expected %d)"%A),
("x <> 11300","x <> %d"%V),("aud_n <> 115823",f"aud_n <> {AN+N}"),("(expected 115823)",f"(expected {AN+N})"),("aud_max <> 121161",f"aud_max <> {AM+N}"),("(expected 121161)",f"(expected {AM+N})"),
("x <> 13001","x <> %d"%SA),("(expected 13001)","(expected %d)"%SA),("x <> 1701","x <> %d"%NCA),("(expected 1701)","(expected %d)"%NCA),
("<> 49","<> %d"%NP),("(expected 49)","(expected %d)"%NP),("x <> 98","x <> %d"%(2*NP)),("(expected 98)","(expected %d)"%(2*NP)),]
for a,c2 in sr:
    if a=="x <> 11300" and a not in b: continue
    assert a in b,a; b=b.replace(a,c2)
sh=f"""-- slugs-{KEY}.sql
-- CompassEats, Nov 2 2026. New canonical slugs for the {N} venues of rename batch {KEY},
-- plus Njørd café {NJ} (item 4: slug only, no rename). Run only after the batch is applied.
-- Template: docs/slugs-rename-michelin-2026-hong-kong-macau.sql. Slug rule as in that file.
-- {NKEEP} of the {N+1} venues keep their slug. Plan: {NP} rows, fingerprint {FP}.
-- Old slugs stay as non-canonical and keep working. No row is deleted. No ledger row.
-- Expected after: slugs {SA:,}, non-canonical {NCA:,}, canonical {V:,}; audit +{2*NP}.

"""
for bad in ['hong-kong','12952','1652','121161','115823','9e682a11']:
    assert bad not in b,bad
print('slug leftovers',re.findall(r".*\b(?:66|49|98|17)\b.*",b))
open(f'docs/slugs-{KEY}.sql','w',encoding='utf-8',newline='\n').write(sh+b)
print(N,NM,NV,M2,M3,M4)
