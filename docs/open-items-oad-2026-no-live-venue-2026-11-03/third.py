import json,collections,re,unicodedata
from difflib import SequenceMatcher as SM
import pykakasi
kks=pykakasi.kakasi()
R=json.load(open('rows311.json'));K={r['key']:r for r in R};S=json.load(open('status_v2.json'))
V=json.load(open('venues.json'))
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD',s or '') if not unicodedata.combining(c)).lower()
def rom(s):
    if re.search(r'[぀-ヿ一-鿿]',s or ''): return ''.join(i['hepburn'] for i in kks.convert(s))
    return s or ''
def k(s): return re.sub(r'[^a-z0-9]','',ua(rom(s)))
GEN=r'\b(restaurant|restaurante|ristorante|sushi|sushidokoro|tempura|yakitori|yakiniku|kappo|hotel|the|at|by|bar|japanese|cuisine|ryokan|ginza|nishiazabu|honten)\b'
def k2(s): return re.sub(r'[^a-z0-9]','',re.sub(GEN,' ',re.sub(r'\(.*?\)','',ua(rom(s)))))
for v in V: v['k']=k(v['name']);v['k2']=k2(v['name'])
byc=collections.defaultdict(list)
for v in V: byc[k(v['city'])].append(v)
glob=collections.defaultdict(list)
for v in V:
    glob[v['k2']].append(v)
out={}
for key,o in S.items():
    r=K[key]
    ns=[r['printed_name'],o.get('real_name'),o.get('native_name')]
    ns=[n for n in ns if n]
    # also parenthetical
    for n in list(ns):
        m=re.search(r'\((.*?)\)',n)
        if m: ns.append(m.group(1))
    keys={k2(n) for n in ns if len(k2(n))>=3}
    cand=[]
    cities={k(re.split(r'[,(]',o.get('real_city') or '')[0]),k(r['printed_city'])}
    pool=[v for c in cities for v in byc.get(c,[])]
    for v in pool:
        best=max((SM(None,a,v['k2']).ratio() for a in keys),default=0)
        if best>=.74: cand.append((round(best,2),v['name'],v['city'],v['status'],v['id']))
    anyw=[]
    for a in keys:
        if len(a)>=4:
            for v in glob.get(a,[]):
                if k(v['city']) not in cities: anyw.append((v['name'],v['city'],v['status'],v['id']))
    out[key]=dict(cand=sorted(set(cand),reverse=True)[:4],any=sorted(set(anyw))[:5])
json.dump(out,open('cands.json','w'),ensure_ascii=False)
ids=sorted({c[4] for x in out.values() for c in x['cand']}|{c[3] for x in out.values() for c in x['any']})
print(len(ids));open('cand_ids.txt','w').write(','.join("'%s'"%i for i in ids))
for key,x in out.items():
    if x['cand'] or x['any']:
        r=K[key];o=S[key]
        print(key,r['printed_name'],'/',o.get('real_name'),'|',r['chef'][:16],'|',o.get('real_city'),'|',(o.get('address_seen') or r['oad_page_address'])[:38],'=>',[c[:4] for c in x['cand']],'ANY',[c[:3] for c in x['any']][:3])
