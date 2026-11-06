#!/usr/bin/env python3
"""Pair test by address, price compare, tier test, row order test, evidence CSV. Old addresses are from data/venues.json and are not written."""
import csv,json,re,unicodedata,collections
def key(n):
    s=unicodedata.normalize('NFKD',n.lower());s=''.join(c for c in s if not unicodedata.combining(c));return re.sub(r'[^a-z0-9]+','',s)
un=lambda s:re.sub(r'\\u([0-9a-f]{4})',lambda m:chr(int(m.group(1),16)),s)
live={}
for l in open('live-read.txt',encoding='utf8').read().split('\n'):
    p=l.split('|');live[p[0]]=dict(v=p[0],a=p[1],cat=p[2],city=p[5],price=p[7],url=p[9],name='|'.join(p[10:]))
pg={l.split('\t')[0]:l.split('\t')[1:] for l in open('venue-pages-read-2026-11-05.tsv',encoding='utf8').read().split('\n')}
pairs={l.split('\t')[0]:l.split('\t') for l in open('pairs.tsv').read().split('\n')}
old=json.load(open('../../data/venues.json',encoding='utf8'));oldn={}
for v in old:
    if v.get('country') in('South Korea','Korea'):oldn.setdefault(v['name'],[]).append(v)
cards=[]
for l in open('relay-kr-2026-list-pages-2026-11-05.txt',encoding='ascii').read().split('\n'):
    x=[un(y) for y in l.split(' | ')];cards.append(dict(cat=x[0],href=x[1],name=x[2],loc=x[3],pr=x[4].split(' · ')[0],cui=x[4].split(' · ')[1],path=x[1].split('/restaurant/')[1]))
T={'Three Stars':'Three Stars','Two Stars':'Two Stars','One Star':'One Star','Bib Gourmand':'Gourmand'}
W=csv.writer(open('michelin-2026-south-korea-evidence-2026-11-05.csv','w',encoding='utf8',newline=''))
W.writerow('card_tier,card_name,card_url,card_address,card_price,award_id,venue_id,live_name,live_price,pair_group,address_test,price_test,page_status'.split(','))
gr=collections.Counter();ad=collections.Counter();pr=collections.Counter();pd=[];badaddr=[];stat=collections.Counter();tier=0
for c in cards:
    _,v,a,how=pairs[c['path']];l=live[v];p=pg[c['path']]
    stat[p[0]]+=1;assert p[0]=='200' and p[2]=='' ;assert '2026 MICHELIN Guide South Kor' in p[3] and T[c['cat']] in p[3],c
    tier+=1
    g='same name' if how=='same name' else 'name differs';gr[g]+=1
    o=oldn.get(l['name'],[]);at='no old address'
    if o:
        oa=o[0].get('address') or ''
        pc=re.search(r', (\d{5}), South Korea',p[1]).group(1)
        st=p[1].split(', Seoul')[0].split(', Busan')[0]
        road=[t for t in re.split(r',\s*',st) if re.search(r'-(ro|gil|daero)|(ro|gil|daero)\b',t)]
        rn=road[-1] if road else st
        rk=key(re.sub(r'^[#\d\-]+\s*','',rn));num=re.match(r'[\d\-]+',rn)
        oak=key(oa)
        if num and num.group() in oa and rk and rk in oak: at='same street and number'
        elif rk and rk in oak: at='same street, number differs'
        elif pc in oa: at='same postcode'
        else: at='different place';badaddr.append((c['name'],l['name'],oa,p[1]))
    if g!='same name':ad[at]+=1
    else:ad['same name: '+at]+=1
    lt=len(l['price']);ct=len(c['pr'])
    pt='same tier' if lt==ct else 'differs';pr[pt]+=1
    if pt=='differs':pd.append((c['name'],l['name'],l['price'],c['pr']))
    W.writerow([c['cat'],c['name'],'https://guide.michelin.com'+c['href'],p[1],c['pr'],a,v,l['name'],l['price'],g,at,pt,p[0]])
print('pair',gr);print('addr',ad);print('price',pr);print('status',stat,'tier ok',tier)
print('price diffs',*pd,sep='\n ');print('different place',*badaddr,sep='\n ')
# Row order test: id order of the legacy rows against the alphabetical card order, by city and tier
byp={c['path']:c for c in cards}
for city,cat in [('busan','Bib Gourmand'),('seoul','Bib Gourmand'),('seoul','One Star')]:
    rows=sorted([l for l in live.values() if l['city']==city and l['cat']==cat],key=lambda l:int(l['a']))
    rev={v[1]:k for k,v in pairs.items()}
    names=[byp[rev[l['v']]]['name'] for l in rows]
    print(city,cat,[f"{l['a']}:{n}" for l,n in zip(rows,names)])
print('sum',sum(gr.values()))
