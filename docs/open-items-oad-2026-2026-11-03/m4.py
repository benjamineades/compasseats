import json,re,collections
src=open('m3.py').read().split("c=collections.Counter(x['t'] for x in out)")[0].replace("print(","(lambda *a,**k:None)(")
exec(src)
d=json.load(open('/root/.claude/projects/-home-claude/5a08f972-258d-53b8-b0cf-dd5d1dc7e41d/tool-results/mcp-remote-devices-Claude_Browser__javascript_tool-1793758328945.txt'))
s,_=json.JSONDecoder().raw_decode(d[0]['text']);h,body=s.split('\n',1);PG=json.loads(body)
import builtins
builtins.print(h)
json.dump(PG,open('pages.json','w'),ensure_ascii=True)
# address -> city ids (any comma part or word sequence that is a city key)
def addr_cities(a):
    ids=set()
    parts=[p.strip() for p in re.split(r',|\s-\s',a) if p.strip()]
    for p in parts:
        p2=re.sub(r'\b\d[\d\-]*\b','',p).strip()
        k=ck(p2)
        if k in cby: ids|=cby[k]
        for w in p2.split():
            if len(w)>=5 and ck(w) in cby: ids|=cby[ck(w)]
    return ids
for x in out:
    p=PG.get(x['slug'],{})
    x['addr']=p.get('address','');x['web']=p.get('web','');x['phone']=p.get('phone','')
    x['p_rank']=(re.match(r'Ranking\s+(\S+)',p.get('rank','')) or [None,''])[1]
    x['acities']=addr_cities(x['addr'])
    # page rank test: same slug shows the row of this list? 
    nc=[]
    for ci in x['acities']:
        for v in bc[ci]:
            l=level(x['name'],v['name'])
            if RANK[l]: nc.append((RANK[l],l,v['id']))
            elif v.get('rom') and core(x['clean']) and len(core(x['clean']))>=3 and (v['rom']==core(x['clean']) or (len(core(x['clean']))>=5 and (core(x['clean']) in v['rom'] or v['rom'] in core(x['clean'])))): nc.append((2,'romaji',v['id']))
    x['cand_addr']=sorted(set(nc),reverse=True)
    if x['t'].startswith('D:slug') or x['t'].startswith('C:'):
        v=vid.get(x['mv']) if x['mv'] else None
        x['addr_city_ok']=bool(v and v['cid'] in x['acities'])
    x['acities']=sorted(x['acities'])
def row(x):
    v=vid.get(x['mv']) if x['mv'] else None
    return f"{x['list'][0]}{x['rank']}|{x['clean']}|{x['city']}|{x['slug']}|{x['chef'][:18]}|ADDR {x['addr'][:70]}|WEB {x['web'][:30]}|->"+(f"{v['name'][:32]} [{v['city']}] {v['status'][0]}" if v else '-')+f"|{x['b_rows'][0]['name'][:20]+'#'+x['b_rows'][0]['rank'] if x['b_rows'] else ''}|ca={[ (c[1],vid[c[2]]['name'][:22],vid[c[2]]['city'][:10]) for c in (x['cand_addr'] or x['cand_city'])[:3]]}"
json.dump(out,open('l26_step4.json','w'),ensure_ascii=True,default=list)
import sys
g=sys.argv[1]
for x in out:
    if x['t'].startswith(g): builtins.print(x['t'][2:8],row(x))
