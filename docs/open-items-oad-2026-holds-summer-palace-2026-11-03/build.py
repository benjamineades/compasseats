import json,csv,re,hashlib
from verdicts import *
R='../open-items-oad-2026-2026-11-03/oad-2026-lists-relay-2026-11-03.jsonl'
assert hashlib.sha256(open(R,'rb').read()).hexdigest()=='0f4caee4115425434aeb66db1a198ed2846447f4d3bfc9ed8566e07c8b8aec7c'
L={'e':'europe','a':'asia','j':'japan'}
relay={(r['list'][0],r['rank_n']):r for r in map(json.loads,open(R))}
page={r['key']:r for r in json.load(open('../open-items-oad-2026-no-live-venue-2026-11-03/rows311.json'))}
ev={x['list'][0]+x['rank']:x for x in csv.DictReader(open('../open-items-oad-2026-no-live-venue-2026-11-03/oad-2026-no-live-venue-evidence-2026-11-03.csv',encoding='utf-8'))}
holds=[k for k,x in ev.items() if x['group']=='hold' and x['printed_name'] not in('Romantico','Arakawa (Kyoto)','Miyako Zushi')]
assert len(holds)==27 and set(holds)==set(LOAD)|set(HOLD),set(holds)^(set(LOAD)|set(HOLD))
dig=lambda s:re.sub(r'\D','',s)
def sl(s): return s
out=[];nl=[]
for k in holds+['a259','a432']:
    l,rk=k[0],int(k[1:]);r=relay[(l,rk)];p=page.get(k,{});nm=re.sub(r'\s*\(New\)$','',r['name'])
    row=dict(list=L[l],rank=rk,new_mark='*' in r['rank'],printed_name=nm,printed_city=r['city'],printed_country=r['country'],chef=r['chef'],oad_slug=r['slug'],oad_address=p.get('oad_page_address',''),oad_phone=p.get('oad_page_phone',''),oad_web=p.get('oad_page_web',''))
    if k in LOAD:
        v=LOAD[k];m=''
        if v['phone']:
            a,b=dig(v['phone']),dig(row['oad_phone']);b=b[2:] if b.startswith('81') else b;b=b[2:] if b.startswith('66') and a.startswith('66') and 0 else b
            m=a.lstrip('0')==b.lstrip('0') or a==dig(row['oad_phone']);assert m,(k,a,b)
        row.update(decision='new venue, '+('open' if v['st']=='a' else 'closed'),target=v['cs'],real_name=v['real'],native=v['native'],real_city=v['real_city'],evidence_url=v['url'],second_url=v.get('second',''),phone_seen=v['phone'],phone_match=m,last_seen=v['seen'],read_by=v['read'],note=v['note'])
        cy=r['city'];co={'j':'Japan','a':'Thailand','e':'France'}[l];nl.append(f"{l}|{rk}|{nm}|{v['cs']}|{v['st']}|{cy}|{co}")
    elif k in HOLD:
        row.update(decision='hold',note=HOLD[k][0],evidence_url=HOLD[k][1],read_by='fetch')
    else:
        v=SUMMER[k];row.update(decision='cross fix' ,note=v['note'],evidence_url=v['url'],read_by='fetch' if k=='a259' else 'browser')
    out.append(row)
cols=['list','rank','new_mark','printed_name','printed_city','printed_country','chef','oad_slug','oad_address','oad_phone','oad_web','decision','target','real_name','native','real_city','evidence_url','second_url','phone_seen','phone_match','last_seen','read_by','note']
with open('oad-2026-holds-summer-palace-evidence-2026-11-03.csv','w',newline='',encoding='utf-8') as f:
    w=csv.DictWriter(f,cols);w.writeheader();w.writerows(sorted(out,key=lambda x:(x['list'],x['rank'])))
piro='ve_'+hashlib.md5(b'paris:restaurant-pirouette').hexdigest()[:10]
mv=[[a,o,piro if n=='PIROUETTE' else n] for a,o,n in MOVES]
nl=sorted(nl,key=lambda x:(x.split('|')[0],int(x.split('|')[1])))
P=dict(nl=nl,al=['a|259|ve_54ab6673c8'],mv=sorted(mv),newc=NEWC,ids=DELETE,piro=piro)
json.dump(P,open('plan.json','w'),ensure_ascii=False,indent=1)
print(len(out),len(nl),[x['decision'] for x in out].count('hold'),P['al'],P['mv']);print('\n'.join(nl))
import collections;print(collections.Counter(x['phone_match'] for x in out if 'phone_match' in x))
