import json,re,glob,unicodedata,collections,sys
d='/root/.claude/projects/-home-claude/bac05431-f45f-5734-98ba-00e28029996c/tool-results/'
lt=json.load(open(glob.glob(d+'mcp-remote-devices-Claude_Browser__javascript_tool-*')[0]))
t=lt[0]['text'] if isinstance(lt,list) else lt
t=t[t.index('FR26LIST'):t.index('ENDFR26LIST')]
t=t.replace('\\n','\n')
rows=[l.split('|') for l in t.strip().split('\n')[1:]]
print('list',len(rows),collections.Counter(r[0] for r in rows))
raw=open(glob.glob(d+'mcp-Supabase_Read-execute_sql-*')[0]).read()
try:
    o=json.loads(raw); raw=o['result'] if isinstance(o,dict) else raw
except Exception: pass
s=raw[raw.index('[{"m":"FR26DB"'):raw.rindex(']')+1] if '[{"m":"FR26DB"' in raw else None
if s is None:
    i=raw.index('FR26DB'); raw2=raw.replace('\\"','"'); s=raw2[raw2.index('[{"m":"FR26DB"'):raw2.rindex('}]')+2]
db=json.loads(s)[0]['rows']
print('db',len(db),collections.Counter(r[6] for r in db))
cat={'1':'One Star','2':'Two Stars','3':'Three Stars'}
slug=lambda u:re.sub(r'[?#].*','',u).rstrip('/').split('/')[-1]
dbs=collections.defaultdict(list)
for r in db: dbs[slug(r[7] or '')].append(r)
miss=[];diff=[];seen=set()
for r in rows:
    k=slug(r[3]); m=dbs.get(k)
    if not m: miss.append(r); continue
    seen.add(k)
    if not any(x[6]==cat[r[0]] for x in m): diff.append((r,[(x[2],x[6]) for x in m]))
extra=[r for k,v in dbs.items() if k not in seen for r in v]
print('in list, no db card:',len(miss))
for r in miss: print(' ',r[0],r[1],'|',r[2],'|',r[3],'|',r[4])
print('category differ:',len(diff))
for x in diff: print(' ',x)
print('in db, not in list:',len(extra))
for r in extra: print(' ',r[0],r[1],r[2],r[3],r[4],r[6],(r[7] or '')[-60:])
json.dump(rows,open('list.json','w'),ensure_ascii=False)
