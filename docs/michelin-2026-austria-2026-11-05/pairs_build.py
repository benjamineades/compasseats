#!/usr/bin/env python3
"""Make pairs.tsv from the list read and the live read. Hand lines are listed by card path."""
import re,unicodedata
def key(n):
    s=unicodedata.normalize('NFKD',n.lower().replace('ß','ss'));s=''.join(c for c in s if not unicodedata.combining(c));return re.sub(r'[^a-z0-9]+','',s)
STOP={'restaurant','gourmetrestaurant','gourmet','hotel','gasthaus','gasthof','wirtshaus','fine','dining','dine','the','der','die','das','by','chef','chefs','table','gmbh'}
def toks(n):
    s=unicodedata.normalize('NFKD',n.lower().replace('ß','ss'));s=''.join(c for c in s if not unicodedata.combining(c)).replace('’','').replace("'",'')
    return {t for t in re.split(r'[^a-z0-9]+',s) if t and t not in STOP}
live=[l.split('|') for l in open('live-read.txt',encoding='utf8').read().strip().split('\n')]
L={l[0]:l for l in live}
cards=[l.split(' | ') for l in open('relay-at-2026-list-pages-2026-11-05.txt',encoding='utf8').read().split('\n')]
HAND={'dollerer':'ve_514ac623be','ois':'ve_c82967b28d','paznaunerstube':'ve_a3d506a9e2','himmelreich':'ve_d38dd14d87','zeitraum':'ve_cd944f8fec','rar-fine-dining':'ve_03dda05136','rau-nature-based-cuisine':'ve_ba96f056e4','guat-z-essen':'ve_084f389fc1','z-som':'ve_4ab8f316e7','rouge-noir':'ve_66510fec11','jamek':'ve_c8bef9b8e5','tian-bistro-am-spittelberg':'ve_f09cd919e1','kirchenwirt-105648':'ve_a26077c5be','krispels-genusstheater':'ve_fabac56e48','prandtauerhof-gutshofrestaurant':'ve_f59540f8bc','thaller-gasthaus':'ve_a70fd42717','wirtshaus-steirereck-am-pogusch':'ve_5b3af84920'}
NEWROW={'tian':'ve_ef06954a85','kirchenwirt':'ve_408dd2d0e2','worgotter-wirtshaus':'ve_3019edc0d9'}
NEWVENUE={'thaller-restaurant'}
used={};out=[]
for c in cards:
    p=c[1].split('/restaurant/')[1]
    if p in NEWVENUE: out.append((p,'NEW','-','new-venue'));continue
    if p in NEWROW: out.append((p,NEWROW[p],'-','new-row'));continue
    if p in HAND:
        v=HAND[p];assert v not in used,p;used[v]=p;out.append((p,v,L[v][1],'hand'));continue
    city=key(c[3].split(', ')[0]);best=None;bs=0
    for l in live:
        if l[0] in used or l[0] in HAND.values() or l[2]!=c[0]: continue
        cs=key(l[5])
        if not(cs[:4]==city[:4] or (city=='mieming' and cs=='obermieming')):continue
        a,b=toks(c[2]),toks(l[9]);s=len(a&b)/max(1,min(len(a),len(b)))
        if key(c[2])==key(l[9]):s=2
        if s>bs:bs=s;best=l
    assert best,c
    used[best[0]]=p;out.append((p,best[0],best[1],'exact' if bs==2 else 'token'))
left=[l for l in live if l[0] not in used]
print('live not paired',[(l[1],l[9]) for l in left])
for r in out:
    if r[3]=='token':
        c=[x for x in cards if x[1].endswith('/restaurant/'+r[0])][0];print('token',c[2],'<=',L[r[1]][9])
open('pairs.tsv','w').write('\n'.join('\t'.join(r) for r in out))
from collections import Counter;print(Counter(r[3] for r in out),len(out))
