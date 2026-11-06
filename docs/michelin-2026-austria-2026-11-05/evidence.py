#!/usr/bin/env python3
"""Pair test by address, price compare, evidence CSV. Old addresses come from data/venues.json and are not written."""
import csv,json,re,unicodedata,collections
def key(n):
    s=unicodedata.normalize('NFKD',n.lower().replace('ß','ss'));s=''.join(c for c in s if not unicodedata.combining(c));return re.sub(r'[^a-z0-9]+','',s)
S='/tmp/claude-0/-home-claude/fa30d792-7921-51a3-a825-9022f873ee6e/scratchpad/'
cards=json.load(open(S+'cards.json'))
pg={l.split('\t')[0]:l.split('\t')[1:] for l in open('venue-pages-read-2026-11-05.tsv',encoding='utf8').read().strip().split('\n')}
assert len(pg)==159
live={}
for l in open('live-read.txt',encoding='utf8').read().strip().split('\n'):
    p=l.split('|');live[p[0]]=dict(award=p[1],cat=p[2],city=p[5],price=p[7],name='|'.join(p[9:]))
old=[v for v in json.load(open('../../data/venues.json',encoding='utf8')) if v.get('country')=='Austria']
oldby={}
for v in old: oldby.setdefault(key(v['name']),[]).append(v)
EXTRA={'ve_ef06954a85':('TIAN','','$$$$?'),'ve_408dd2d0e2':('Der Kirchenwirt seit 1326 - Gourmetwirtshaus & Hotel','','')}
sym={'€':'$','€€':'$$','€€€':'$$$','€€€€':'$$$$'}
rows=[];pd=[];nop=[];gr=collections.Counter();addr=collections.Counter();mis=[]
for c in cards:
    a=pg[c['path']];assert a[1]==c['cat']+' 2026',c
    lv=live.get(c['venue'])
    nm=lv['name'] if lv else EXTRA.get(c['venue'],(c['name'],))[0]
    if c['how']=='new-venue': g='new venue'
    elif c['how']=='new-row': g='live venue, new row'
    else: g='same name' if key(c['name'])==key(lv['name']) else 'name differs'
    gr[g]+=1
    note=''
    if g!='same name' and c['how']!='new-venue':
        o=oldby.get(key(nm),[])
        pc=re.search(r', (\d{4}),',a[0]).group(1)
        num=re.findall(r'\d+',a[0].split(',')[0])
        if not o: addr['no old address']+=1;note='no old address'
        else:
            oa=o[0].get('address') or ''
            okp=pc in oa; okn=(not num) or num[0] in re.findall(r'\d+',oa.split(',')[0])
            r='same' if okp and okn else 'postcode only' if okp else 'differs'
            addr[r]+=1
            if r!='same': mis.append((c['name'],nm,a[0],oa,r))
            note=f'old address {oa}: {r}'
    p=lv['price'] if lv else ''
    if lv and p and sym[c['sym']]!=p: pd.append((c['name'],p,c['sym']))
    if lv and not p: nop.append(c['name'])
    rows.append([g,c['cat'],c['name'],c['city'],c['sym'],c['url'],a[0],c['venue'],nm,c['award'] if c['award']!='-' else '',p,note])
print(gr,addr);print('mismatch');[print(' ',m) for m in mis]
print('price differs',len(pd),pd);print('live no price',nop)
extra=[['no card, edition list','One Star','Schlosskeller Gourmetstube','Leibnitz','','','','ve_fb7dc1ff33','Schlosskeller Südsteiermark','5897','$$$$','own site: closed Oct 19, 2026; card 404'],
['no card, edition total','Bib Gourmand','Schlosskeller Wirtshaus','Leibnitz','','','','ve_d3fd2ae165','Schlosskeller Wirtshaus','','','own site: closed Oct 19, 2026; card 404; 2025 row 5898 stays'],
['no card, edition list, no venue','One Star','OPUS','Vienna','','','','','','','','star article NEW; card 404; not on the Selected list; status not settled']]
with open('michelin-2026-austria-evidence-2026-11-05.csv','w',newline='',encoding='utf8') as f:
    w=csv.writer(f,lineterminator='\n');w.writerow(['group','category','card_name','card_city','card_price','card_url','card_address','venue_id','venue_name','award_id_relabelled','venue_price','note'])
    for r in sorted(rows,key=lambda r:(r[1],r[3],r[2]))+extra: w.writerow(r)
