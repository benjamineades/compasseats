import json,re,unicodedata,difflib,collections
s=open('relay.txt',encoding='utf8').read().split('\n')
G={};g=None
for l in s:
    if l.startswith('@@'): g=l.split()[0][2:];G[g]=[];continue
    G[g].append(l)
def nk(x):
    x=unicodedata.normalize('NFKD',x.lower().replace('ø','o').replace('ß','ss'));x=''.join(c for c in x if not unicodedata.combining(c));return re.sub(r'[^a-z0-9]','',x)
C3,C2,C1='Three Stars','Two Stars','One Star'
LK=re.compile(r'([^<>]*?)\s*<<([^>]*)>>')
L=[]
def lnk(ls,cat,g):
    for l in ls:
        l=re.sub(r'^#H\d ?','',l)
        for nm,u in LK.findall(l):
            nm=nm.strip(' ,;·').strip()
            L.append(dict(g=g,cat=cat,raw=nm,name=nm.split(' - ',1)[1] if g=='DE' and ' - ' in nm else nm,slug=u.split('?')[0].rstrip('/').split('/')[-1],city=''))
SK={'Taipei','Taichung','Tainan','Kaohsiung','New Taipei City','Hsinchu County','Hsinchu City',''}
def pln(ls,cat,g):
    for l in ls:
        if l.startswith('#H'): continue
        m=LK.search(l); slug=m.group(2).split('?')[0].rstrip('/').split('/')[-1] if m else ''
        n=re.sub(r'<<[^>]*>>','',l); n=re.sub(r'\s*\((?:new|promoted)\)\s*$','',n,flags=re.I).strip()
        if n in SK: continue
        if n=='ZEA Ya Ge':
            for q in ['ZEA','Ya Ge']: L.append(dict(g=g,cat=cat,raw=q,name=q,slug='',city=''))
            continue
        L.append(dict(g=g,cat=cat,raw=l[:70],name=n,slug=slug,city=''))
d=G['DE'];lnk(d[3:17],C3,'DE');lnk(d[18:73],C2,'DE');lnk(d[74:355],C1,'DE')
d=G['NL'];lnk(d[6:8],C3,'NL');lnk(d[8:29],C2,'NL');lnk(d[29:129],C1,'NL')
d=G['TW'];pln(d[6:11],C3,'TW');pln(d[12:23],C2,'TW');pln(d[24:75],C1,'TW')
d=G['GB'];lnk(d[14:28],C3,'GB');lnk(d[28:65],C2,'GB');lnk(d[65:],C1,'GB')
d=G['HK'];pln(d[11:19],C3,'HK');pln(d[19:33],C2,'HK');pln(d[33:91],C1,'HK');pln(d[242:245],C3,'MO');pln(d[245:252],C2,'MO');pln(d[252:264],C1,'MO')
d=G['ES']
for a,b,c in [(23,41,C3),(42,81,C2),(82,344,C1)]:
    for l in d[a:b]:
        if l.startswith('#H') or re.match(r'\d+ restaurantes|Leer tamb|Todo sobre|Nuevos Bib|Los 5 nuevos',l) or not l.strip(): continue
        n=re.sub(r'\s*[–-]\s*NOVEDAD\s*$','',l); p=n.split(' – ',1)
        L.append(dict(g='ES',cat=c,raw=l,name=p[1] if len(p)>1 else n,slug='',city=p[0] if len(p)>1 else ''))
cnt=collections.Counter((x['g'],x['cat']) for x in L)
db=json.load(open('db.json'))
gm={'DE':['DE'],'NL':['NL'],'TW':['TW'],'GB':['GB','IE'],'HK':['HK'],'MO':['MO'],'ES':['ES','AD']}
sl=lambda u:(u or '').split('?')[0].rstrip('/').split('/')[-1]
cm={'donostiasansebastian':'sansebastian','valencia':'valencia','cordoba':'cordoba'}
report={}
for g,cs in gm.items():
    R=[r for r in db if r['c'] in cs and r['y']==2026]; A=[r for r in db if r['c'] in cs]
    ls=[x for x in L if x['g']==g]; used=set(); miss=[];diff=[];ok=0;dup=[]
    def score(x,r):
        a=nk(x['name']);b=nk(r['n']);c=nk(sl(r['u']))
        if x['slug'] and x['slug']==sl(r['u']): return 3
        if a==b or a==c: return 2
        v=max(difflib.SequenceMatcher(None,a,b).ratio(),difflib.SequenceMatcher(None,a,c).ratio())
        if len(a)>=4 and (a in b or a in c or b in a or c in a): v=max(v,.9)
        if x['city'] and nk(x['city']).replace('donostiasansebastian','sansebastian')==nk(r['city']): v+=.25
        return v
    # exact first
    for x in sorted(ls,key=lambda x:-max([score(x,r) for r in R] or [0])):
        cand=sorted([r for r in R if r['aid'] not in used],key=lambda r:-(score(x,r)+(.05 if r['cat']==x['cat'] else 0)))
        if cand and score(x,cand[0])>=.8:
            r=cand[0];used.add(r['aid']);x['m']=r
            if r['cat']==x['cat']: ok+=1
            else: diff.append((x,r))
        else: miss.append(x)
    extra=[r for r in R if r['aid'] not in used]
    report[g]=dict(list=len(ls),db=len(R),same=ok,diff=[(x['raw'],x['cat'],r['n'],r['cat']) for x,r in diff],
      miss=[(x['cat'],x['raw'],x['slug'],[(p['n'],p['y'],p['cat'],p['st'],p['vid'],p['aid']) for p in sorted(A,key=lambda r:-score(x,r))[:2]]) for x in miss],
      extra=[(r['cat'],r['n'],r['city'],r['st'],r['vid'],r['aid'],sl(r['u'])) for r in extra])
    print('\n==',g,'list',len(ls),{k[1]:v for k,v in cnt.items() if k[0]==g},'db',len(R),'same',ok,'diff',len(diff),'miss',len(miss),'extra',len(extra))
    for z in report[g]['diff']: print(' DIFF',z)
    for z in report[g]['miss']: print(' MISS',z[0],'|',z[1],'|',z[2],'|',z[3])
    for z in report[g]['extra']: print(' EXTRA',z)
json.dump(report,open('report.json','w'),ensure_ascii=False,indent=0)
