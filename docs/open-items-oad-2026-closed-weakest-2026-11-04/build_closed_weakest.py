import csv,sys,hashlib,collections
from verdicts_closed_weakest import V
SRC='../open-items-oad-2026-holds-names-closed-2026-11-04/oad-2026-closed-venues-evidence-2026-11-04.csv'
src={r['venue_id']:r for r in csv.DictReader(open(SRC,encoding='utf-8'))}
w={k for k,r in src.items() if r['sweep_group'].split(' ')[0] in('7','9','11')}
ids=[v[0] for v in V]
assert len(ids)==26==len(set(ids)) and set(ids)==w, set(ids)^w
G={'A':'Set active','B':'Set active with rename','C':'Closure evidence','D':'Temporary closure or move','E':'Not settled'}
with open('closed-weakest-evidence-2026-11-04.csv','w',newline='',encoding='utf-8') as f:
    c=csv.writer(f); c.writerow('group group_name proposal strength latest_date venue_id name city country list rank_2026 award_id sweep_group evidence method sources stored_evidence_nov2'.split())
    for v in sorted(V,key=lambda v:(v[1],src[v[0]]['name'])):
        r=src[v[0]]; c.writerow([v[1],G[v[1]],v[2],v[3],v[4],v[0],r['name'],r['city'],r['country'],r['list'],r['rank_2026'],r['award_id'],r['sweep_group'],v[5],v[6],v[7],r['stored_evidence']])
print(collections.Counter(v[1] for v in V))
for v in V:
    for wd in ('$p$',): assert wd not in v[5]
