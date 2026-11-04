import json,math,collections,sys,re
S=sys.argv[1]
d=json.load(open(S+'/far.json'));recs=d['recs']
c={r['slug']:r for r in json.load(open(S+'/snap/cities-3d56c74.json'))}
for r in json.load(open(S+'/snap/cities-7f3058d.json')): c.setdefault(r['slug'],r)
def hav(a,b,x,y):
    p=math.pi/180; h=math.sin((x-a)*p/2)**2+math.cos(a*p)*math.cos(x*p)*math.sin((y-b)*p/2)**2
    return 2*6371*math.asin(h**.5)
out=[];cnt=collections.Counter();unk=set()
for l in open(S+'/relay.txt'):
    p=l.split()
    i,j=map(int,p[0].split('.')); kind=p[1]; r=recs[i]; a=r['awards'][j-1]
    cands=[tuple(x.split(':')) for x in p[2].split(',')] if len(p)>2 else []
    near=[];far=[]
    for v,s in cands:
        ci=c.get(s)
        if not ci: unk.add(s); far.append((v,s,None)); continue
        dk=hav(r['lat'],r['lng'],ci['lat'],ci['lng'])
        (near if dk<=50 else far).append((v,s,round(dk)))
    if kind=='N': cl='near' if near else 'far'
    elif kind=='R': cl='near_rank' if (near and len(cands)==1) else 'rank_single_far' if len(cands)==1 else 'none'
    else: cl='none'
    cnt[cl]+=1
    out.append(dict(i=i,j=j,cl=cl,name=r['name'],city=r['city'],country=r['country'],award=a,addr=r['addr'],near=near,far=far))
print(sum(cnt.values()),cnt,'unknown slugs',unk)
json.dump(out,open(S+'/classified.json','w'),ensure_ascii=False)
rows=collections.defaultdict(list)
for o in out:
    if o['cl'] in('far','rank_single_far'): rows[(o['name'],o['city'],o['country'])].append(o)
print('far rows',len(rows))
for k,v in rows.items():
    print(k[0],'|',k[1],k[2],'|',[ (x['award'][0][:12],x['award'][1],x['award'][2]) for x in v][:4],'->',sorted({f[1] for x in v for f in x['far']}))
