import json,re,unicodedata,collections,csv
L=json.load(open('lists.json'));V=json.load(open('venues.json'));R=json.load(open('oadrows.json'));LB=json.load(open('labels.json'));AL=json.load(open('aliases.json'));C=json.load(open('cities.json'));S=json.load(open('slugs.json'))
def ua(s):
    s=s.replace('ß','ss').replace('ø','o').replace('Ø','O').replace('æ','ae').replace('œ','oe').replace('ł','l').replace('đ','d').replace('ı','i').replace('’',"'")
    return ''.join(c for c in unicodedata.normalize('NFKD',s) if not unicodedata.combining(c)).lower()
def alnum(s): return re.sub(r'[^a-z0-9]','',ua(s))
STOP=r'^((restaurant|restaurante|ristorante|restaurang|le|la|les|l|el|il|the|hotel|osteria|trattoria)\s+)+'
def turn(n):
    m=re.match(r'^(.*),\s*(the|le|la|les|l\'|el|il|de|het)\s*$',n,re.I)
    return m.group(2)+' '+m.group(1) if m else n
def strict(n): return alnum(turn(n))
def loose(n):
    t=re.sub(r'[^a-z0-9]+',' ',ua(turn(n).split(' - ')[0])).strip()
    t=re.sub(STOP,'',t); t=re.sub(r'\s+(restaurant|restaurante|ristorante)$','',t)
    k=t.replace(' ','');return k if len(k)>=3 else None
ck=lambda s:re.sub(r'[^a-z0-9]','',ua(s))
# city keys -> set of city ids
cby=collections.defaultdict(set)
for c in C:
    cby[ck(c['display'])].add(c['id']);cby[ck(c['slug'])].add(c['id'])
for a in AL: cby[ck(a['alias'])].add(a['city_id'])
cid={ (c['slug']):c['id'] for c in C}
ctry=collections.defaultdict(set)
for c in C: ctry[c['id']]
for v in V: v['cid']=cid[v['city_slug']]; v['strict']=strict(v['name']); v['loose']=loose(v['name'])
vid={v['id']:v for v in V}
by_s=collections.defaultdict(list);by_l=collections.defaultdict(list)
for v in V:
    by_s[v['strict']].append(v)
    if v['loose']: by_l[v['loose']].append(v)
# native name keys no
lab=collections.defaultdict(set)
for x in LB:
    if x['from_column'] in('city_display','neighborhood'): lab[x['venue_id']].add(ck(x['label']))
JP={'Japan'}
def in_list(lst,v):
    c=v['country'] or ''
    if lst=='japan': return c=='Japan'
    if lst=='asia': return c in {'China','Hong Kong','Macao','Macau','Singapore','Thailand','South Korea','Taiwan','United Arab Emirates','India','Philippines','Indonesia','Vietnam','Malaysia','Cambodia','Sri Lanka','Qatar','Australia','New Zealand','Saudi Arabia','Oman','Bahrain','Kuwait','Maldives','Nepal','Laos','Myanmar','Pakistan','Lebanon','Jordan','Mongolia','Bhutan','Fiji','Kazakhstan','Georgia','Uzbekistan'}
    return c not in {'Japan','China','Hong Kong','Macao','Macau','Singapore','Thailand','South Korea','Taiwan','United Arab Emirates','India','Philippines','Indonesia','Vietnam','Malaysia','Cambodia','Sri Lanka','Qatar','Australia','New Zealand','United States','Canada','Mexico','Brazil','Argentina','Peru','Chile','Colombia'}
# 2025 bridge: list+rank -> award rows
r25=collections.defaultdict(list)
for a in R:
    if a['year']==2025: r25[a['rank']].append(a)
L25=[x for x in L if x['year']==2025];L26=[x for x in L if x['year']==2026]
br=collections.defaultdict(list) # (slug) -> [(venue,list25row,award)]
bstat=collections.Counter();bprob=[]
for x in L25:
    cands=[a for a in r25.get(x['rank_n'],[]) if in_list(x['list'],vid[a['venue_id']])]
    k=strict(x['name']);lk=loose(x['name'])
    named=[a for a in cands if vid[a['venue_id']]['strict']==k or (lk and vid[a['venue_id']]['loose']==lk)]
    if len(cands)==1:
        a=cands[0];x['aw25']=a['award_id'];x['v25']=a['venue_id'];x['b']='one' if named else 'one-nameDiff';bstat[x['b']]+=1
    elif len(named)==1:
        a=named[0];x['aw25']=a['award_id'];x['v25']=a['venue_id'];x['b']='named';bstat['named']+=1
    else:
        x['b']='none' if not cands else 'ambig';bstat[x['list']+':'+x['b']]+=1;bprob.append((x['list'],x['rank'],x['name'],x['city'],[(vid[a['venue_id']]['name'],a['award_id']) for a in cands]))
    if x.get('v25'): br[x['slug']].append(x)
print('2025 bridge',dict(bstat));
for p in bprob[:40]: print(' ',p)
tot25={l:sum(1 for x in L25 if x['list']==l) for l in('europe','asia','japan')};print(tot25)
used=collections.Counter(a['award_id'] for a in R if a['year']==2025)
json.dump(L25,open('l25.json','w'))
# 2026 classification
def city_ok(x,v):
    k=ck(x['city'])
    if not k: return None
    if v['cid'] in cby.get(k,()):return 'city'
    if k in lab[v['id']]:return 'label'
    return False
out=[]
names25=collections.defaultdict(list)
for x in L25: names25[(x['list'],strict(x['name']))].append(x)
for x in L26:
    k,lk=strict(x['name']),loose(x['name'])
    bridge=[b for b in br.get(x['slug'],[]) if b['list']==x['list']]
    bv={b['v25'] for b in bridge}
    bridge_nameok=[b for b in bridge if strict(b['name'])==k]
    ex=[v for v in by_s.get(k,[])]
    lo=[v for v in by_l.get(lk,[])] if lk else []
    ex_city=[v for v in ex if city_ok(x,v)]
    lo_city=[v for v in lo if city_ok(x,v)]
    x['bridge_v']=sorted(bv);x['bridge_n']=[(b['name'],b['city'],b['rank']) for b in bridge]
    x['ex_city']=[v['id'] for v in ex_city];x['lo_city']=[v['id'] for v in lo_city]
    x['ex_other']=[v['id'] for v in ex if not city_ok(x,v) and in_list(x['list'],v)]
    x['lo_other']=[v['id'] for v in lo if not city_ok(x,v) and in_list(x['list'],v)]
    t=None;mv=None
    named_city=set(x['ex_city'])|set(x['lo_city'])
    if len(bv)==1:
        v=vid[next(iter(bv))];co=city_ok(x,v);bb=bridge[0]
        same_city25=ck(bb['city'])==ck(x['city'])
        if named_city and v['id'] not in named_city: t='conflict';mv=v['id']
        elif co: t='slug+city';mv=v['id']
        elif not ck(x['city']): t='slug,no-city';mv=v['id']
        elif same_city25: t='city-disagree-known';mv=v['id']
        else: t='city-disagree-new';mv=v['id']
    elif len(bv)>1: t='slug-2-venues'
    else:
        if len(named_city)==1:
            mv=next(iter(named_city));t='name+city'
        elif len(named_city)>1: t='name-2-venues'
        elif x['ex_other'] or x['lo_other']: t='name-other-city'
        else: t='none'
    x['t']=t;x['mv']=mv
    out.append(x)
c=collections.Counter((x['list'],x['t']) for x in out)
for k2 in sorted(c): print(k2,c[k2])
print(collections.Counter(x['t'] for x in out))
json.dump(out,open('l26_step1.json','w'),ensure_ascii=True)
