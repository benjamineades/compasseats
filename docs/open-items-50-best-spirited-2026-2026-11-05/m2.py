import json,re,unicodedata,collections,difflib
exec(open('match.py').read().split("res=[]")[0])
R=json.load(open('match1.json'))
ALLK=[(loose(v['name']),tight(v['name']),v) for v in V]
def fz(name,place,cids):
    l=loose(name);t=tight(name);out=[]
    toks=[w for w in k(name).split() if w not in STOP and len(w)>=3]
    for lv,tv,v in ALLK:
        s=difflib.SequenceMatcher(None,l,lv).ratio() if abs(len(l)-len(lv))<=8 else 0
        cont=len(l)>=4 and (l in lv or (len(lv)>=4 and lv in l))
        tok=any(w in k(v['name']).split() for w in toks) and v['cid'] in cids
        if s>=0.8 or cont or tok:
            out.append((round(s,2),v['id'],v['name'],v['cat'],v['st'],v['cs'],v['aw'],[(a['s'][:12],a['y'],a['r']) for a in aw[v['id']] if a['s'] in ('worlds-50-best-bars','asia-50-best-bars','top-500-bars','worlds-50-best-restaurants','spirited-awards')][-2:]))
    out.sort(key=lambda x:(-(x[5] in [cid[c]['s'] for c in cids]),-x[0]))
    return out[:6]
print('--- none rows, wide search')
seen=set()
for r in R:
    if r['group'] in('none','other_city') and (r['name'],r['place']) not in seen:
        seen.add((r['name'],r['place']))
        print(r['src'][:6],r['rank'] or '',r['name'],'|',r['place'],r['cids'][:2]);
        for c in fz(r['name'],r['place'],r['cids']): print('    ',c)
print('--- exact rows: cat mismatch, closed')
want={'worlds-50-best-bars':'bar','asia-50-best-bars':'bar','worlds-50-best-restaurants':'restaurant','spirited-awards':'bar'}
for r in R:
    for c in r['cands'][:1]:
        if r['group'] in('exact_city','loose_city','contain_city') and (c[2]!=want[r['src']] or c[3]!='active'):
            print(r['src'][:6],r['rank'],r['name'],r['place'],c[:6])
print('--- exact rows: no earlier row in this source')
for r in R:
    if r['group'] in ('exact_city',) and not r['cands'][0][6]:
        c=r['cands'][0];print(r['src'][:6],r['rank'] or r['cat'][:18],r['name'],r['place'],c[0],c[1],c[2],c[4],'aw',c[5],[ (a['s'][:12],a['y']) for a in aw[c[0]]][:3])
