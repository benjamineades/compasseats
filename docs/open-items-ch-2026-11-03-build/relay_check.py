import json,re,hashlib,collections,sys
raw=json.load(open(sys.argv[1]))
t=[x['text'] for x in raw if x['type']=='text'][0]
d=json.loads(t[:t.rindex('}')+1]) if t.lstrip().startswith('{') else None
if d is None:
    d=json.loads(re.search(r'\{.*\}',t,re.S).group(0))
s=d['relay']
print('hash browser',d['h'],'local',hashlib.sha256(s.encode()).hexdigest()==d['h'])
open('relay/relay-ch-2025-cards-archive.txt','w',encoding='utf-8',newline='').write(s)
print({k:d.get(k) for k in ['k2fin','k2i','c503','ok2','n','extra']}); print('NONE',len(d['none']),d['none'])
rows={str(x['id']):x for x in json.load(open('ch2025p.json'))}
CAT={'3':['Three Stars','Drei Sterne','Trois étoiles','Tre Stelle'],'2':['Two Stars','Zwei Sterne','Deux étoiles','Due Stelle'],'1':['One Star','Ein Stern','Une étoile','Una Stella'],'B':['Bib Gourmand']}
bad=[];loc=collections.Counter();cats=collections.Counter()
for l in s.strip().split('\n'):
    id,c,ts,o,h1,m=l.split('|',5)
    m2=m.encode().decode('unicode_escape') if '\\u' in m else m
    m2=re.sub(r'\\u([0-9a-f]{4})',lambda x:chr(int(x.group(1),16)),m)
    hit=[k for k,v in CAT.items() if any(w.lower() in m2.lower() for w in v)]
    e=bool(re.search(r'2025',m2))
    if hit!=[c] or not e or not('20251020'<=ts[:8]<='20261022'): bad.append((id,c,hit,ts,m2[:90]))
    loc[re.sub(r'https://guide.michelin.com/([a-z]{2}(/[a-z]{2})?)/.*',r'\1',o)]+=1;cats[c]+=1
    p=rows[id].get('path')
    from urllib.parse import unquote
    if not o.endswith(p): bad.append((id,'path',o,p))
print('bad',bad);print(loc,cats)
