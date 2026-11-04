import json,collections,re,unicodedata
from difflib import SequenceMatcher as SM
R=json.load(open('rows311.json'));K={r['key']:r for r in R};S=json.load(open('status_v2.json'))
V=json.load(open('venues.json'));C=json.load(open('cities.json'))
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD',s or '') if not unicodedata.combining(c)).lower()
def k(s): return re.sub(r'[^a-z0-9]','',ua(s))
GEN=r'\b(restaurant|restaurante|ristorante|sushi|sushidokoro|tempura|yakitori|yakiniku|kappo|hotel|the|at|by|bar|japanese|cuisine|ginza|nishiazabu|kyoto|tokyo|osaka)\b'
def k2(s): return re.sub(r'[^a-z0-9]','',re.sub(GEN,' ',re.sub(r'\(.*?\)','',ua(s))))
for v in V: v['k']=k(v['name']);v['k2']=k2(v['name'])
cs=collections.defaultdict(list)
for c in C: cs[k(c['display'])].append(c)
A=[];B=[]
for key,o in S.items():
    r=K[key]
    rc=k(o.get('real_city','').split(',')[0]);pc=k(r['printed_city'])
    if rc!=pc: A.append(key)
    nms={r['printed_name'],o.get('real_name') or ''}
    hit=[]
    for v in V:
        vc=k(v['city'])
        same=(vc==rc or vc==pc)
        for n in nms:
            if not n: continue
            a,b=k(re.sub(r'\(.*?\)','',n)),k2(n)
            if v['k']==a or (b and len(b)>=3 and v['k2']==b): 
                if same: hit.append((v['name'],v['city'],v['status'],v['id']));break
            elif same and b and len(b)>=6 and SM(None,b,v['k2']).ratio()>=.85: hit.append((v['name'],v['city'],v['status'],v['id'],'~'));break
    if hit: B.append((key,hit[:4]))
print('city differs',len(A))
for key in A:
    r=K[key];o=S[key]
    print(key,r['printed_name'],'| printed',r['printed_city'],'| real',o.get('real_city'),o.get('real_country'),'|',o['read_status'],o['strength'],o['identity'],'|',o.get('address_seen','')[:50])
print('match in real city',len(B))
for key,h in B:
    r=K[key];o=S[key]
    print(key,r['printed_name'],'/',o.get('real_name'),'|',r['chef'][:16],'|',o.get('address_seen','')[:40],'=>',h,'| same:',o.get('same_as_live_near',''))
