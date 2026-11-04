import json,sys,collections,math,re,unicodedata,hashlib
S=sys.argv[1]; OUT=sys.argv[2]
a=json.load(open(f'{S}/3d56c74.json'))
c={r['slug']:r for r in json.load(open(f'{S}/cities-3d56c74.json'))}
for r in json.load(open(f'{S}/cities-7f3058d.json')): c.setdefault(r['slug'],r)
def hav(a,b,x,y):
    p=math.pi/180; h=math.sin((x-a)*p/2)**2+math.cos(a*p)*math.cos(x*p)*math.sin((y-b)*p/2)**2
    return 2*6371*math.asin(h**.5)
def key(s):
    s=unicodedata.normalize('NFKD',s); s=''.join(ch for ch in s if not unicodedata.combining(ch))
    return re.sub(r'[^0-9a-z]','',s.lower())
by=collections.defaultdict(list)
for r in a: by[r['id']].append(r)
multi={k:v for k,v in by.items() if len({r['city_slug'] for r in v})>1}
recs=[]
for k in sorted(multi):
    for r in multi[k]:
        ci=c[r['city_slug']]; d=hav(r['lat'],r['lng'],ci['lat'],ci['lng'])
        if d>50 and r.get('awards'):
            recs.append(dict(pid=k,name=r['name'],city=r['city_slug'],disp=r['city_display'],country=r['country'],dist=round(d),addr=r.get('address'),lat=ci['lat'],lng=ci['lng'],awards=[(x['source'],x['year'],x['category']) for x in r['awards']]))
srcs=sorted({x[0] for r in recs for x in r['awards']})
sm={s:i for i,s in enumerate(srcs)}
json.dump(dict(recs=recs,srcs=srcs),open(OUT+'/far.json','w'),ensure_ascii=False)
print('rows with awards',len(recs),'awards',sum(len(r['awards']) for r in recs),'keys short',sum(len(key(r['name']))<3 for r in recs))
print(json.dumps(srcs))
lines=[[i,key(r['name']),round(r['lat'],1),round(r['lng'],1),[[sm[x[0]],x[1],x[2]] for x in r['awards']]] for i,r in enumerate(recs)]
n=len(lines); parts=4
for p in range(parts):
    chunk=json.dumps(lines[p*n//parts:(p+1)*n//parts],separators=(',',':'),ensure_ascii=True)
    open(f'{OUT}/part{p}.json','w').write(chunk)
    print(p,len(chunk),hashlib.md5(chunk.encode()).hexdigest())
