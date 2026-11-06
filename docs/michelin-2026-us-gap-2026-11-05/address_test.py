#!/usr/bin/env python3
"""Address test, population: cards paired to a live venue. Old addresses are from data/venues.json and are not written."""
import json,re,unicodedata,collections
def dec(s): return re.sub(r'\\u([0-9a-f]{4})', lambda m: chr(int(m.group(1), 16)), s)
def key(n):
    s=unicodedata.normalize('NFKD',n.lower().replace('’',"'"));s=''.join(c for c in s if not unicodedata.combining(c));return re.sub(r'[^a-z0-9]+','',s)
L=open('relay-us-ca-fl-2026-list-pages-2026-11-05.txt',encoding='ascii').read().split('\n')
pg=[l.split('\t') for l in open('venue-pages-read-2026-11-05.tsv',encoding='ascii').read().split('\n')]
live={}
for l in open('live-pairs-read.txt',encoding='utf8').read().split('\n'):
    p=l.split('|');live[int(p[0])]=dict(v=p[1],city=p[8],name='|'.join(p[9:]))
old=collections.defaultdict(list)
for v in json.load(open('../../data/venues.json',encoding='utf8')):
    if v.get('country') in('United States','USA','US'):old[key(v['name'])].append(v)
res=collections.Counter();diff=[]
for i,(l,pgx) in enumerate(zip(L,pg),1):
    if i not in live or i==133:continue
    addr=dec(pgx[5]);zipc=addr.rsplit(', ',1)[-1];num=re.search(r'\b\d+',addr);lv=live[i]
    c=[o for o in old[key(lv['name'])] if key(o.get('city_display',''))==key(lv['city'])] or old[key(lv['name'])]
    if not c or not c[0].get('address'):res['no old']+=1;continue
    oa=c[0]['address']
    if zipc in oa:res['same zip']+=1
    elif num and re.search(r'\b'+num.group()+r'\b',oa):res['same number']+=1
    else:res['different']+=1;diff.append((i,lv['name'],lv['city'],oa,addr))
print(res,sum(res.values()));[print(d) for d in diff]
