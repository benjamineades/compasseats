import json,re,unicodedata,collections,csv
V=json.load(open('venues.json'));A=json.load(open('awards.json'));C=json.load(open('cities.json'))
L=[x for x in json.load(open('lists-raw.json')) if x['rank']]
S=json.load(open('spirited.json'))
rows=[dict(src=x['src'],rank=int(x['rank']),cat='No. '+x['rank'],name=x['name'],place=x['place'],block=x['block']) for x in L]+[dict(src=x['src'],rank=None,cat=x['cat'],name=x['name'],place=x['place'],block='') for x in S]
def k(s):
    s=unicodedata.normalize('NFKD',s.lower()); s=''.join(c for c in s if not unicodedata.combining(c)).replace('&',' and ')
    return re.sub(r'[^a-z0-9]+',' ',s).strip()
STOP={'the','bar','restaurant','and','cocktail','lounge','at','by','le','la','el'}
def tight(s): return ''.join(w for w in k(s).split())
def loose(s): return ''.join(w for w in k(s).split() if w not in STOP) or tight(s)
vid={v['id']:v for v in V}
by_t=collections.defaultdict(list);by_l=collections.defaultdict(list)
for v in V: by_t[tight(v['name'])].append(v);by_l[loose(v['name'])].append(v)
aw=collections.defaultdict(list)
for a in A: aw[a['v']].append(a)
hist=collections.defaultdict(list)
for a in A: hist[a['s']].append(a)
alias={a['a']:a['c'] for a in C['aliases']}
cid={c['id']:c for c in C['cities']}
def cityids(place):
    kp=k(place); out=set(c['id'] for c in C['cities'] if k(c['d'])==kp or k(c['s'])==kp)
    if kp in alias: out.add(alias[kp])
    return out
res=[]
for r in rows:
    cids=cityids(r['place']); r['cids']=sorted(cids)
    t=tight(r['name']);l=loose(r['name'])
    A1=[v for v in by_t.get(t,[]) if v['cid'] in cids]
    B1=[v for v in by_l.get(l,[]) if v['cid'] in cids]
    # contained names, same city
    D1=[v for v in V if v['cid'] in cids and len(l)>=4 and (l in loose(v['name']) or (len(loose(v['name']))>=4 and loose(v['name']) in l))]
    O=[v for v in by_l.get(l,[]) if v['cid'] not in cids]
    if len(A1)==1: g,c='exact_city',A1
    elif len(A1)>1: g,c='multi_exact',A1
    elif len(B1)==1: g,c='loose_city',B1
    elif len(B1)>1: g,c='multi_loose',B1
    elif D1: g,c='contain_city',D1
    elif O: g,c='other_city',O
    else: g,c='none',[]
    r['group']=g;r['cands']=[(v['id'],v['name'],v['cat'],v['st'],v['cs'],v['aw'],[ (a['s'][:14],a['y'],a['r']) for a in aw[v['id']] if a['s']==r['src']][-3:]) for v in c]
    res.append(r)
json.dump(res,open('match1.json','w'),ensure_ascii=False)
print(collections.Counter((r['src'],r['group']) for r in res))
print('no city id',[ (r['src'],r['name'],r['place']) for r in res if not r['cids']])
for r in res:
    if r['group']!='exact_city':
        print(r['src'][:9],r['rank'] or r['cat'][:20],'|',r['name'],'|',r['place'],'|',r['group'],'|',[c[:6] for c in r['cands']][:4])
