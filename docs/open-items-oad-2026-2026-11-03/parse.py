import json,hashlib,re,collections
B='/root/.claude/projects/-home-claude/5a08f972-258d-53b8-b0cf-dd5d1dc7e41d/tool-results/'
J=B+'mcp-remote-devices-Claude_Browser__javascript_tool-%s.txt'
files={('europe',2026):'1793757542102',('asia',2026):'1793757561826',('japan',2026):'1793757566349',('europe',2025):'1793757648387',('asia',2025):'1793757662387',('japan',2025):'1793757675899'}
out=[];man={}
for (k,y),f in files.items():
    d=json.load(open(J%f)); t=d[0]['text']
    s,_=json.JSONDecoder().raw_decode(t)
    h,body=s.split('\n',1)
    ok=hashlib.sha256(body.encode()).hexdigest()==h[7:]
    obj=json.loads(body)
    r=obj['rows']
    assert obj['list']==f'/lists/{k}/top-restaurants/{y}',obj['list']
    print(k,y,obj['count'],obj['header'],obj['read_at'],'hash ok',ok)
    odd=[x['rank'] for x in r if not x['rank'].isdigit()]
    nums=[int(re.sub(r'\D','',x['rank'])) for x in r]
    print('  odd ranks',len(odd),odd[:12],'| min',min(nums),'max',max(nums),'distinct',len(set(nums)),'gaps',sorted(set(range(1,max(nums)+1))-set(nums))[:12])
    print('  blank city',sum(not x['city'] for x in r),'blank country',sum(not x['country'] for x in r),'blank slug',sum(not x['slug'] for x in r),'name!=title',sum(x['name']!=x['title'] for x in r))
    if y==2026: print('  ',collections.Counter(x['country'] for x in r).most_common(50))
    for x in r: x['list']=k;x['year']=y;x['rank_n']=int(re.sub(r'\D','',x['rank']));x['slug']=x['slug'].replace('/restaurant/','')
    out+=r; man[f'{k}-{y}']=dict(sha256=h[7:],count=obj['count'],read_at=obj['read_at'])
json.dump(out,open('lists.json','w'),ensure_ascii=True)
json.dump(man,open('manifest.json','w'),indent=1)
def db(f):
    s=open(B+f'mcp-Supabase_Read-execute_sql-{f}.txt').read()
    try:
        o=json.loads(s); s=o['result'] if isinstance(o,dict) else o[0]['text']
        if isinstance(json.loads(json.dumps(s)),str) and s.startswith('{'): s=json.loads(s)['result']
    except Exception as e: print('e',e)
    i=s.index('[{'); return json.JSONDecoder().raw_decode(s[i:])[0]
for n,f in dict(oadrows='1793757583237',venues='1793757583087',labels='1793757582826',aliases='1793757629284',cities='1793757621634',slugs='1793757622206').items():
    r=db(f); print(n,len(r),list(r[0].keys())); json.dump(r,open(n+'.json','w'),ensure_ascii=True)
