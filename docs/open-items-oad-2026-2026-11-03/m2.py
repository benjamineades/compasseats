import json,difflib,re,collections
exec(open('match.py').read().split('# 2026 classification')[0].replace("print(","(lambda *a,**k:None)("))
def clean(n): return re.sub(r'\((closed|temporarily closed|chef change|moved|relocated|new)[^)]*\)','',n,flags=re.I).strip()
def toks(s): return [t for t in re.sub(r'[^a-z0-9]+',' ',ua(turn(s))).split() if t not in {'the','restaurant','restaurante','ristorante','restaurang','le','la','les','l','el','il','de','di','du','des','da','at','by','and','bar','hotel','a','an','in','y','et','e','und','of'}]
def level(n,m):
    n=clean(n)
    a,b=alnum(turn(n)),alnum(turn(m))
    if not a or not b: return 'none'
    if a==b: return 'exact'
    la,lb=loose(n),loose(m)
    if la and la==lb: return 'loose'
    ta,tb=toks(n.split(' - ')[0]),toks(m)
    sa,sb=set(ta),set(tb)
    if sa and sb and (sa<=sb or sb<=sa) and max(len(''.join(sa)),len(''.join(sb)))>=3 and min(len(''.join(sa)),len(''.join(sb)))>=3: return 'tokens'
    if len(a)>=5 and len(b)>=5 and (a in b or b in a): return 'contain'
    r=difflib.SequenceMatcher(None,la or a,lb or b).ratio()
    if r>=.84: return 'fuzzy'
    return 'none'
RANK={'exact':5,'loose':4,'tokens':3,'contain':2,'fuzzy':1,'none':0}
# per-city venue index
bc=collections.defaultdict(list)
for v in V: bc[v['cid']].append(v)
def city_ok(x,v):
    k=ck(x['city'])
    if not k: return None
    if v['cid'] in cby.get(k,()):return 'city'
    if k in lab[v['id']]:return 'label'
    return False
def city_ids(x):
    return cby.get(ck(x['city']),set())
for x in L25:
    if x.get('v25'):x['nl25']=level(x['name'],vid[x['v25']]['name'])
print('2025 bridge name level',collections.Counter(x.get('nl25') for x in L25))
print('non-New paren names 26',[ (x['list'],x['rank'],x['name'],x['city']) for x in L if x['year']==2026 and re.search(r'\(|closed',x['name'],re.I) and not re.search(r'\(New\)',x['name'])])
print('New count',collections.Counter(x['list'] for x in L if x['year']==2026 and '(New)' in x['name']), 'star',collections.Counter(x['list'] for x in L if x['year']==2026 and x['rank'].endswith('*')))
#print('blank city',[(x['list'],x['rank'],x['name'],x['slug']) for x in L if x['year']==2026 and not x['city']])
#print('name!=title',[(x['name'],x['title'],x['slug']) for x in L if x['year']==2026 and x['name']!=x['title']])
out=[]
for x in L26:
    x['clean']=clean(x['name'])
    # candidates in city
    cands=[]
    for ci in city_ids(x):
        for v in bc[ci]:
            l=level(x['name'],v['name'])
            if RANK[l]: cands.append((RANK[l],l,v['id']))
    # label-city candidates
    for v in V:
        pass
    cands.sort(reverse=True)
    x['cand_city']=cands[:6]
    bridge=[b for b in br.get(x['slug'],[]) if b['list']==x['list']]
    x['b_rows']=[dict(rank=b['rank'],name=b['name'],city=b['city'],v=b['v25'],aw=b['aw25'],nl=b['nl25']) for b in bridge]
    out.append(x)
# label city candidates index
lv=collections.defaultdict(list)
for vidd,s in lab.items():
    for k in s: lv[k].append(vid[vidd])
for x in out:
    for v in lv.get(ck(x['city']),[]):
        l=level(x['name'],v['name'])
        if RANK[l] and v['id'] not in [c[2] for c in x['cand_city']]: x['cand_city'].append((RANK[l],l,v['id']))
    x['cand_city'].sort(reverse=True)
    # anywhere strict/loose in region
    x['cand_any']=[v['id'] for v in (by_s.get(strict(x['clean']),[])+by_l.get(loose(x['clean']) or '~',[])) if in_list(x['list'],v) and v['id'] not in [c[2] for c in x['cand_city']]]
    x['cand_any']=sorted(set(x['cand_any']))
def cls(x):
    bs=x['b_rows'];bv={b['v'] for b in bs}
    top=x['cand_city'][0] if x['cand_city'] else None
    if len(bv)>1:return 'D:slug-2-venues',None
    if len(bv)==1:
        vi=next(iter(bv));v=vid[vi];b=bs[0]
        nl=level(x['name'],v['name']);nl25=b['nl']
        ok=city_ok(x,v)
        nameok=RANK[nl]>=2 or RANK[nl25]>=2
        if top and top[2]!=vi and top[0]>=4 and not nameok: return 'D:slug-vs-name',vi
        if top and top[2]!=vi and top[0]>=5 and RANK[nl]<5: return 'D:slug-vs-name',vi
        if not ck(x['city']):
            return ('M:slug,name,no-city' if nameok else 'D:slug,name-weak,no-city'),vi
        if ok:
            return ('M:slug+name+city' if nameok else 'D:slug+city,name-weak'),vi
        if ck(b['city'])==ck(x['city']):
            return ('C:known' if nameok else 'D:slug,name-weak,city-off'),vi
        return ('C:new' if nameok else 'D:slug,name-weak,city-off'),vi
    # no 2025 row
    strong=[c for c in x['cand_city'] if c[0]>=4]
    if len(strong)==1:return 'M:name+city',strong[0][2]
    if len(strong)>1:return 'D:name-2-venues',None
    if x['cand_city']:return 'D:weak-name-in-city',x['cand_city'][0][2]
    if x['cand_any']:return 'C:name-other-city',None
    return 'N:none',None
for x in out: x['t'],x['mv']=cls(x)
c=collections.Counter(x['t'] for x in out);print(c,sum(c.values()))
print(collections.Counter((x['list'],x['t'][0]) for x in out))
json.dump(out,open('l26_step2.json','w'),ensure_ascii=True)
# printed twice
sl=collections.defaultdict(list);nm=collections.defaultdict(list);vm=collections.defaultdict(list)
for x in out:
    sl[x['slug']].append(x);nm[(ck(x['city']),strict(x['clean']))].append(x)
    if x['mv']:vm[x['mv']].append(x)
tw=[('slug',k,[(y['list'],y['rank'],y['name'],y['city']) for y in v]) for k,v in sl.items() if len(v)>1]
tw2=[('name',k,[(y['list'],y['rank'],y['name'],y['slug']) for y in v]) for k,v in nm.items() if len(v)>1 and len({y['slug'] for y in v})>1]
tw3=[('venue',vid[k]['name'],[(y['list'],y['rank'],y['name'],y['city'],y['t']) for y in v]) for k,v in vm.items() if len(v)>1]
print(len(tw),len(tw2),len(tw3))
for t in tw+tw2+tw3: print(t)
