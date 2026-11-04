import json,csv,re,unicodedata,collections
from difflib import SequenceMatcher as SM
V=json.load(open('venues.json'));C=json.load(open('cities.json'))
R=[x for x in csv.DictReader(open('/home/claude/compasseats/docs/open-items-oad-2026-2026-11-03/oad-2026-europe-asia-japan-evidence-2026-11-03.csv')) if x['status_group']=='no live venue']
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD',s) if not unicodedata.combining(c)).lower()
def k(s): return re.sub(r'[^a-z0-9]','',ua(s))
STOP=r'\b(restaurant|restaurante|ristorante|sushi|tempura|yakitori|yakiniku|ginza|hotel|the|de|la|le|at|by|bar|kyoto|tokyo|osaka|hong kong|singapore|madrid|paris|milan|milano)\b'
def k2(s): return re.sub(r'[^a-z0-9]','',re.sub(STOP,' ',re.sub(r'\(.*?\)','',ua(s))))
for v in V: v['k']=k(v['name']);v['k2']=k2(v['name'])
cs={k(c['display']):c for c in C}
out=[]
for x in R:
    nm=x['printed_name'].replace(' (New)','')
    a,b=k(re.sub(r'\(.*?\)','',nm)),k2(nm)
    pc=k(x['printed_city'])
    hits=[]
    for v in V:
        s=0
        if v['k']==a: s=3
        elif b and v['k2']==b and len(b)>=4: s=2
        elif len(a)>=5 and (a in v['k'] or v['k'] in a) and len(v['k'])>=5: s=1
        elif b and len(b)>=6 and SM(None,b,v['k2']).ratio()>=.86: s=1
        if s and (k(v['city'])==pc or s>=2): hits.append((s,k(v['city'])==pc,v['name'],v['city'],v['status'],v['id']))
    hits.sort(key=lambda h:(-h[1],-h[0]))
    x['hits']=hits[:5]
    out.append(x)
same=[x for x in out if any(h[1] for h in x['hits'])]
print('with a same-city hit',len(same))
for x in same: print(x['list'][0]+x['rank'],x['printed_name'],'|',x['printed_city'],'|',x['chef'][:18],'|',x['oad_page_address'][:32],'=>',[(h[0],h[2],h[3],h[4],h[5]) for h in x['hits'] if h[1]][:3])
print('---- other-city exact')
for x in out:
    if x not in same and any(h[0]==3 for h in x['hits']): print(x['list'][0]+x['rank'],x['printed_name'],'|',x['printed_city'],'=>',[(h[2],h[3],h[4]) for h in x['hits'] if h[0]==3][:4])
print('---- city map')
miss=collections.Counter()
for x in R:
    c=x['printed_city']
    if k(c) not in cs: miss[(c,x['printed_country'],x['list'])]+=1
print(miss)
dup=collections.defaultdict(list)
for c in C: dup[k(c['display'])].append(c['slug']+'/'+str(c['cc']))
print({k_:v for k_,v in dup.items() if len(v)>1 and k_ in {k(x['printed_city']) for x in R}})
rows=[]
for x in out:
    near=[f"{h[2]} ({h[3]}, {h[4]})" for h in x['hits'] if h[1] or h[0]==3][:4]
    rows.append(dict(key=x['list'][0]+x['rank'],list=x['list'],rank=int(x['rank']),printed_name=x['printed_name'].replace(' (New)',''),new_mark=x['new_mark']=='True',printed_city=x['printed_city'],printed_country=x['printed_country'],chef=x['chef'],cuisine=x['cuisine'],oad_slug=x['oad_slug'],oad_page_address=x['oad_page_address'],oad_page_phone=x['oad_page_phone'],oad_page_web=x['oad_page_web'],live_near=near))
json.dump(rows,open('rows311.json','w'),ensure_ascii=False)
import math
E_=[r for r in rows if r['list']=='europe'];A=[r for r in rows if r['list']=='asia'];J=[r for r in rows if r['list']=='japan']
J.sort(key=lambda r:(0 if r['oad_slug'] in('sushi-riku','sushiriku') else 1,r['rank']))
b=[E_[:34],E_[34:],A[:35],A[35:]]+[J[i:i+35] for i in range(0,len(J),35)]
for i,c in enumerate(b,1):
    json.dump(c,open(f'batch-{i}.json','w'),ensure_ascii=False,indent=0)
    print(i,len(c),c[0]['key'],c[-1]['key'])
