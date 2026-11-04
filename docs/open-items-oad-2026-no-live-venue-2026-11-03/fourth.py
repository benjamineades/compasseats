import json,re,csv,unicodedata,collections
R=json.load(open('rows311.json'));K={r['key']:r for r in R};S=json.load(open('status_v2.json'));V=json.load(open('venues.json'));C=json.load(open('cities.json'))
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD',s or '') if not unicodedata.combining(c)).lower()
def k(s): return re.sub(r'[^a-z0-9]','',ua(s))
byc=collections.defaultdict(list)
for v in V: byc[k(v['city'])].append(v)
G=set('restaurant restaurante ristorante sushi tempura yakitori yakiniku hotel kappo cuisine taiwanese japanese wine seafood chinese kitchen roast japan private'.split())
print('--- token same-city')
for key,o in S.items():
    r=K[key]
    t={w for n in (r['printed_name'],o.get('real_name')) for w in re.findall(r'[a-z]{4,}',ua(n or '')) if w not in G and k(w)!=k(r['printed_city'])}
    cs={k(re.split(r'[,(]',o.get('real_city') or '')[0]),k(r['printed_city'])}
    hit=[(v['name'],v['city'],v['status']) for c in cs for v in byc.get(c,[]) if any(w in ua(v['name']) for w in t)]
    if hit: print(key,r['printed_name'],'=>',hit[:4])
print('--- bros etc')
for v in V:
    if re.search(r"\bbros\b|bros'|albereta|aurum|padaste|pädaste|costes|alchimia|langosteria|cancook|fraiche|fraîche",ua(v['name'])): print(v['name'],v['city'],v['status'],v['id'])
print('--- csv ranks')
c=list(csv.DictReader(open('/home/claude/compasseats/docs/open-items-oad-2026-2026-11-03/oad-2026-europe-asia-japan-evidence-2026-11-03.csv')))
for l,rk in [('japan','678'),('japan','26'),('asia','438'),('japan','176')]:
    for x in c:
        if x['list']==l and x['rank']==rk: print(l,rk,x['printed_name'],x['chef'],x['printed_city'],x['oad_page_address'],x['oad_page_web'],x['live_name'])
print('--- review')
sm=lambda a,b:k(a)==k(b)
for key,o in S.items():
    r=K[key];rc=re.split(r'[,(]',o.get('real_city') or '')[0]
    diff=not sm(rc,r['printed_city'])
    if (o['read_status']=='not_found') or o['strength']=='weak' or o['identity']=='low' or (diff and o['identity']!='high'):
        print(key,r['printed_name'],'|',r['printed_city'],'>',o.get('real_city'),'|',r['chef'][:18],'|',o['read_status'],o['strength'],o['identity'],'|',o.get('address_seen','')[:45],'|',o['evidence_note'][:130],'|',(o['evidence_url'] or '')[:70])
