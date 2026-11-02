import re,unicodedata
def nk(s):
    s=unicodedata.normalize('NFKD',s.lower());s=''.join(c for c in s if not unicodedata.combining(c));return set(w for w in re.findall(r'[a-z0-9]+',s) if len(w)>2 and w not in('restaurant','hotel','les','the','maison','table','chateau','une','des','par','aux'))
L=[];D=[];m=None
for l in open('out.txt'):
    if l.startswith('in list'):m='L';continue
    if l.startswith('category'):m=None;continue
    if l.startswith('in db'):m='D';continue
    if m=='L': p=l.strip().split(' | ');c=p[0].split(' ',1);L.append((c[0],c[1],p[1],p[2]))
    if m=='D':
        x=l.strip().split(' ');D.append(l.strip())
un=[]
used=set()
for c,city,name,path in L:
    cs=path.split('/')[1]
    cand=[]
    for d in D:
        if d in used: continue
        url=d.split(' ')[-1]
        w=nk(name)|nk(path.split('/')[-1].replace('-',' '))
        score=len(w & nk(d.rsplit(' ',1)[0]+' '+url.replace('-',' ').split('/')[-1]))
        c2=nk(city.split(' ')[0])
        same=bool(c2 & nk(d))
        if same: cand.append((score,d))
    cand.sort(key=lambda z:-z[0])
    if cand and cand[0][0]>=2: used.add(cand[0][1]);print('PAIR',c,city,'|',name,'=>',cand[0][1][:110])
    else: un.append((c,city,name,path,[z[1][:80] for z in cand[:3]]))
print('UNPAIRED LIST',len(un))
for u in un: print(' ',u)
print('UNUSED DB')
for d in D:
    if d not in used: print(' ',d[:130])
