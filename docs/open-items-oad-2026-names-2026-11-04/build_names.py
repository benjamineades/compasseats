import json,re,hashlib,csv,collections,sys,unicodedata
from verdicts_names import S
W='/tmp/claude-0/-home-claude/f987d52a-384f-5823-be87-7e85ce32e371/scratchpad/w/'
F="/root/.claude/projects/-home-claude/f987d52a-384f-5823-be87-7e85ce32e371/tool-results/mcp-remote-devices-Claude_Browser__javascript_tool-1793804963868.txt"
try:
    a=json.load(open(F));t=a[0]['text']
    t=json.JSONDecoder().raw_decode(t)[0] if t.startswith('"') else t
    m=re.search(r'([0-9a-f]{64})\n(\[.*\])\n(x+)',t,re.S)
    assert m.group(1)==hashlib.sha256(m.group(2).encode()).hexdigest()
    C=json.loads(m.group(2)); json.dump(C,open('cards-read-2026-11-04.json','w'),ensure_ascii=False,indent=0); print('hash ok',len(C))
except FileNotFoundError:
    C=json.load(open('cards-read-2026-11-04.json'))
card={c['id']:c for c in C}
for x in ('2dbb60d900','3c305428b3','a65b4cfbbe'): card.pop(x,None)  # another shop or not the OAD name
P=json.load(open(W+'pop.json'))
pop={x['venue_id'][3:]:x for x in csv.DictReader(open('../open-items-oad-2026-holds-names-closed-2026-11-04/rename-population-2026-11-04.csv'))}
rows=[]
OWN={json.loads(l)['id']:json.loads(l)['url'] for l in open('own-site-read-30-2026-11-04.jsonl')}
for r in P:
    i=r['id'][3:]; live=r['name']; c=card.get(i); lead=pop[i]['earlier_read_name']; lurl=pop[i]['earlier_url']
    v=S.get(i)
    if not v:
        if c and c['st']==200 and c['h1']: v=('C','card','','')
        elif lead and lead!=live: v=('K2','',lurl,'lead only: '+lead)
        else: v=('K','','','no other name read')
    cl,new,url,note=v
    if cl=='X' and OWN.get(i): url=OWN[i]
    if new=='card': new=c['h1']
    if cl in('C','SC') and not url: url=(c and 'https://guide.michelin.com'+('' if c['path'].startswith('/') else '/')+c['path']) or ''
    murl=('https://guide.michelin.com'+('' if c['path'].startswith('/') else '/')+c['path']) if c else ''
    if cl in ('K','K2'): new=''
    if new==live and cl not in('H',): cl,new='K','' ; note=(note+' read name same as live').strip()
    rows.append(dict(group=r['g'],venue_id=r['id'],status=r['status'],live_name=live,city=r['city'],country=r['country'],canon=r['canon'],sources=','.join(sorted({a['s'] for a in r['aw']})),cls=cl,new_name=new,card_name=(c or {}).get('h1') or '',card_url=murl,site_or_lead_url=url,note=note,earlier_lead=lead))
json.dump(rows,open(W+'rows.json','w'),ensure_ascii=False)
csv.writer(open('names-evidence-2026-11-04.csv','w',newline='',encoding='utf-8')).writerows([list(rows[0].keys())]+[list(x.values()) for x in rows])
ct=collections.Counter((x['group'],x['cls']) for x in rows)
for g in '1234': print(g,{c:ct[(g,c)] for c in('S','SC','C','X','H','K','K2')})
print(collections.Counter(x['cls'] for x in rows))
print('rename-class closed:',[ (x['live_name'],x['cls']) for x in rows if x['status']=='closed' and x['new_name']])
print('case only',sum(1 for x in rows if x['new_name'] and x['cls'] in('S','SC','C','X') and unicodedata.normalize('NFKD',x['new_name']).casefold()==unicodedata.normalize('NFKD',x['live_name']).casefold()))
if len(sys.argv)>1:
  for x in rows:
    if x['group']=='4' and x['cls'] in('C',): print(x['live_name'],'=>',x['new_name'])
