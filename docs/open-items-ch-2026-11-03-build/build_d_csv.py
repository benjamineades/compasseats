import json,csv,re
from lists import *
r=json.load(open('../alias.json'))
def cls(x):
    a=x['alias']
    if a in COUNTRY: return 'DELETE country'
    if a in REGION: return 'DELETE region or province'
    if a in WRONG: return 'DELETE wrong place'
    if a in TOWN: return 'DELETE separate town'
    if a in NEIGHBOUR: return 'KEEP in use, venue filed under a neighbor city'
    if x['label_rows']>0: return 'KEEP in use'
    if x['self_match']: return 'KEEP same as city name'
    return 'KEEP no use: spelling, or place inside the city or its municipality'
w=csv.writer(open('alias-check-262.csv','w',newline=''))
w.writerow('alias,target_slug,target_display,target_country,target_venues_count,class,label_rows,venues_in_target,venues_elsewhere,other_city_same_name,labels'.split(','))
import collections;c=collections.Counter()
for x in sorted(r,key=lambda x:x['alias']):
    k=cls(x);c[k]+=1
    w.writerow([x['alias'],x['target_slug'],x['target_display'],x['target_country'],x['venues_count'],k,x['label_rows'],x['venues_in_target'],x['venues_elsewhere'],x['other_cities'] or '',x['labels'] or ''])
print(c,sum(c.values()))
assert all(x['label_rows']==0 for x in r if x['alias'] in DEL)
