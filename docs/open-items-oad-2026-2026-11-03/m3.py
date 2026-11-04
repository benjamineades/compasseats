import json,re,collections
src=open('m2.py').read().split("def cls(x):")[0].replace("print(","(lambda *a,**k:None)(")
exec(src)
import pykakasi,pypinyin
kks=pykakasi.kakasi()
CJK=re.compile(r'[぀-ヿ㐀-鿿]')
def rom(s):
    if not CJK.search(s): return None
    jp=''.join(i['hepburn'] for i in kks.convert(s))
    return re.sub(r'[^a-z0-9]','',ua(jp))
def pin(s):
    if not CJK.search(s): return None
    return re.sub(r'[^a-z0-9]','',''.join(pypinyin.lazy_pinyin(s)).lower())
for v in V:
    v['rom']=rom(v['name']) if v['country']=='Japan' else (pin(v['name']) if v['country'] in('China','Taiwan','Hong Kong','Macao') else None)
    if v.get('name_native') and not v['rom']:
        v['rom']=rom(v['name_native']) if v['country']=='Japan' else pin(v['name_native'])
slug_by_city=collections.defaultdict(lambda:collections.defaultdict(set))
for s in S: slug_by_city[s['city_slug']][alnum(s['slug'])].add(s['venue_id'])
def core(n):
    n=re.sub(r'\(.*?\)|（.*?）','',n);return alnum(turn(n))
def csl(x):
    out=[]
    for ci in city_ids(x):
        cs=[c['slug'] for c in C if c['id']==ci]
    return out
cslug={c['id']:c['slug'] for c in C}
sl_list=collections.Counter((x['list'],x['slug']) for x in out)
for x in out:
    x['clean']=clean(x['name'])
    k=core(x['clean'])
    # extra candidates: live slug equal to OAD slug in same city; romanized CJK name
    ex=[]
    for ci in city_ids(x):
        for vi in slug_by_city[cslug[ci]].get(alnum(x['slug']),()): ex.append(('slug',vi))
        for v in bc[ci]:
            if v.get('rom') and k and len(k)>=3 and (v['rom']==k or (len(k)>=5 and (k in v['rom'] or v['rom'] in k))):
                ex.append(('romaji',v['id']))
            ch=v.get('chef') or ''
            if x['chef'] and ch and alnum(x['chef'])==alnum(ch): ex.append(('chef',v['id']))
    x['extra']=sorted(set(ex))
    # bridge fix
    bs=x['b_rows']
    same=[b for b in bs if ck(b['city'])==ck(x['city'])]
    dup=sl_list[(x['list'],x['slug'])]>1
    x['b_note']=''
    if dup or '(New)' in x['name']:
        if same: bs=same
        else:
            if bs: x['b_note']='bridge dropped: '+str([(b['rank'],b['city']) for b in bs])
            bs=[]
    x['b_rows']=bs
def cls(x):
    bs=x['b_rows'];bv={b['v'] for b in bs}
    top=x['cand_city'][0] if x['cand_city'] else None
    if len(bv)>1:return 'D:slug-2-venues',None
    if len(bv)==1:
        vi=next(iter(bv));v=vid[vi];b=bs[0]
        nl=level(x['name'],v['name']);nl25=b['nl']
        ok=city_ok(x,v)
        nameok=RANK[nl]>=2 or RANK[nl25]>=2 or any(e[1]==vi and e[0] in('slug','romaji') for e in x['extra'])
        if top and top[2]!=vi and top[0]>=4 and not nameok: return 'D:slug-vs-name',vi
        if top and top[2]!=vi and top[0]>=5 and RANK[nl]<5: return 'D:slug-vs-name',vi
        if not ck(x['city']): return ('M:slug,name,no-city' if nameok else 'D:slug,name-weak,no-city'),vi
        if ok: return ('M:slug+name+city' if nameok else 'D:slug+city,name-weak'),vi
        if ck(b['city'])==ck(x['city']): return ('C:known' if nameok else 'D:slug,name-weak,city-off'),vi
        return ('C:new' if nameok else 'D:slug,name-weak,city-off'),vi
    strong=[c for c in x['cand_city'] if c[0]>=4]
    if len(strong)==1:return 'M:name+city',strong[0][2]
    if len(strong)>1:return 'D:name-2-venues',None
    exv=sorted({e[1] for e in x['extra']})
    if len(exv)==1 and any(e[0]=='slug' for e in x['extra']):return 'M:name+city',exv[0]
    if exv:return 'D:weak-name-in-city',exv[0]
    if x['cand_city']:return 'D:weak-name-in-city',x['cand_city'][0][2]
    if x['cand_any']:return 'C:name-other-city',None
    return 'N:none',None
for x in out: x['t'],x['mv']=cls(x)
c=collections.Counter(x['t'] for x in out);print(c,sum(c.values()))
json.dump(out,open('l26_step3.json','w'),ensure_ascii=True)
dv={ (x['slug']) for x in out if not x['t'].startswith('M')}
sh={x['slug'] for x in out if sl_list[(x['list'],x['slug'])]>1}
need=sorted(dv|sh);print(len(need))
json.dump(need,open('need_slugs.json','w'))
print(','.join(need))
