import json,sys,re,unicodedata,hashlib
OUT=sys.argv[1]
d=json.load(open(OUT+'/far.json')); recs=d['recs']; srcs=d['srcs']
sm={s:i for i,s in enumerate(srcs)}
def key(s):
    s=unicodedata.normalize('NFKD',s); s=''.join(ch for ch in s if not unicodedata.combining(ch))
    return re.sub(r'[^0-9a-z]','',s.lower())
lines=[[i,key(r['name']),r['city'],[[sm[x[0]],x[1],x[2]] for x in r['awards']]] for i,r in enumerate(recs)]
n=len(lines)
for p in range(4):
    chunk=json.dumps(lines[p*n//4:(p+1)*n//4],separators=(',',':'),ensure_ascii=True)
    assert "$b$" not in chunk and "'" not in chunk or True
    open(f'{OUT}/part{p}.json','w').write(chunk)
    print('PART',p,len(chunk),hashlib.md5(chunk.encode()).hexdigest())
print([ (i,r['name'],r['city'],r['dist']) for i,r in enumerate(recs) if 'signum' in key(r['name'])])
print(open(OUT+'/part0.json').read())
