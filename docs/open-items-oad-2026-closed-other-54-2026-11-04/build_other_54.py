import csv,collections,hashlib
from verdicts_other_54 import V,SIDE
SRC='../open-items-oad-2026-holds-names-closed-2026-11-04/oad-2026-closed-venues-evidence-2026-11-04.csv'
NOV3='../open-items-oad-2026-2026-11-03/oad-2026-europe-asia-japan-evidence-2026-11-03.csv'
src={r['venue_id']:r for r in csv.DictReader(open(SRC,encoding='utf-8')) if r['sweep_group'].split(' ')[0] not in('7','9','11')}
assert len(src)==54
ids=[v[0] for v in V]
assert len(ids)==len(set(ids)),[i for i,c in collections.Counter(ids).items() if c>1]
print('missing',[src[k]['name'] for k in set(src)-set(ids)],'extra',set(ids)-set(src))
assert set(ids)==set(src)
pr={(r['list'],r['rank']):r for r in csv.DictReader(open(NOV3,encoding='utf-8'))}
G={'A':'Reopening read, not open on the read date','C':'Closure supported','D':'Temporary closure','M':'Moved or successor under another name','E':'Not settled'}
out='oad-2026-closed-other-54-evidence-2026-11-04.csv'
rows=[]
with open(out,'w',newline='',encoding='utf-8') as f:
    c=csv.writer(f)
    c.writerow('group group_name proposal strength latest_date venue_id live_name city country list rank_2026 award_id sweep_group printed_name printed_city printed_chef name_compare evidence method sources stored_line_check stored_evidence_nov4'.split())
    for v in sorted(V,key=lambda v:('ACDME'.index(v[1]),src[v[0]]['name'])):
        r=src[v[0]]; p=pr.get((r['list'],r['rank_2026']))
        cmp_='no printed name in the Nov 3 CSV' if not p else ('same' if p['printed_name'].lower()==r['name'].lower() else 'differs')
        c.writerow([v[1],G[v[1]],v[2],v[3],v[4],v[0],r['name'],r['city'],r['country'],r['list'],r['rank_2026'],r['award_id'],r['sweep_group'],p['printed_name'] if p else '',p['printed_city'] if p else '',p['chef'] if p else '',cmp_,v[5],v[6],v[7],v[8],r['stored_evidence']])
        rows.append((v[1],cmp_))
print(collections.Counter(x[0] for x in rows))
print(collections.Counter(x[1] for x in rows))
print(collections.Counter(v[3] for v in V))
print(hashlib.sha256(open(out,'rb').read()).hexdigest())
