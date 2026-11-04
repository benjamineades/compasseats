import json,csv,re,collections,unicodedata,sys
W=sys.argv[1]; D='..'
R=json.load(open(W+'/closed80.json')); EV=json.load(open(W+'/closed80_ev.json'))
sw={r['venue_id']:r for r in csv.DictReader(open(D+'/closed-sweep-2026-11-02/closed-sweep-201-evidence-2026-11-02.csv',encoding='utf-8-sig'))}
out=[]
for r in R:
    s=sw.get(r['id'])
    if s: g,st,dt,e,u=s['group'],s['strength'],s['latest_date'],s['evidence'],s['urls']
    else:
        lines=[x for x in EV.get(r['id'],[]) if re.search('clos|ferm|chius',x[1],re.I)] or EV.get(r['id'],[])
        g,st,dt,e,u='not in sweep: closed by a later or earlier write','','',(lines[0][1] if lines else ''),(lines[0][0] if lines else '')
    out.append([r['list'],r['rank'],r['award_id'],r['id'],r['name'],r['city'],r['country'],r['michelin_2026'],g,st,dt,e,u])
out.sort(key=lambda x:(x[8],x[4]))
csv.writer(open('oad-2026-closed-venues-evidence-2026-11-04.csv','w',newline='',encoding='utf-8')).writerows([['list','rank_2026','award_id','venue_id','name','city','country','michelin_rows_2026_up','sweep_group','strength','latest_date','stored_evidence','stored_source']]+out)
print(collections.Counter(x[8] for x in out))
print(collections.Counter((x[8],x[0]) for x in out if x[0]=='no url'))
N=json.load(open(W+'/newv.json')); C=json.load(open(W+'/cand.json'))
def k(s): return ''.join(c for c in unicodedata.normalize('NFKD',s.lower()) if c.isalnum())
rows=[]
A=list(csv.DictReader(open(D+'/open-items-oad-2026-no-live-venue-2026-11-03/oad-2026-no-live-venue-evidence-2026-11-03.csv')))
B=list(csv.DictReader(open(D+'/open-items-oad-2026-read-block-2026-11-03/oad-2026-separate-read-block-evidence-2026-11-03.csv')))
Cc=list(csv.DictReader(open(D+'/open-items-oad-2026-holds-summer-palace-2026-11-03/oad-2026-holds-summer-palace-evidence-2026-11-03.csv')))
live={n['id']:n for n in N}
seen=set()
for r in A:
    v=live.get(r['target_venue_id'])
    if v and v['w'].startswith('A') and r['real_name'] and r['real_name']!=v['live_name'] and v['id'] not in seen:
        seen.add(v['id']); rows.append(['1 own spelling, Nov 3 write',v['id'],v['live_name'],v['city'],r['real_name'],'case or mark only' if k(r['real_name'])==k(v['live_name']) else 'words differ',r['evidence_url']])
byname={}
for n in N:
    if n['w'][0] in 'BCD': byname.setdefault((n['w'][0],n['live_name']),n)
for r in B:
    if r['real_name'] and r['live_name']!=r['real_name']:pass
for n in N:
    if n['w'][0]=='B':
        m=[r for r in B if r['real_name'] and re.sub(r'\s*\(New\)','',r['printed_name'])==n['first_name']]
        rn=m[0]['real_name'] if m else ''
        rows.append(['2 new venue, Nov 3 read-block',n['id'],n['live_name'],n['city'],rn,'' if not rn else ('same' if rn==n['live_name'] else ('case or mark only' if k(rn)==k(n['live_name']) else 'words differ')),m[0]['evidence_url'] if m else ''])
    if n['w'][0] in 'CD':
        m=[r for r in Cc if r['printed_name']==n['first_name'] and r['real_name']]
        rn=m[0]['real_name'] if m else ''
        rows.append(['3 new venue, last 2 writes',n['id'],n['live_name'],n['city'],rn,'' if not rn else ('same' if rn==n['live_name'] else ('case or mark only' if k(rn)==k(n['live_name']) else 'words differ')),m[0]['evidence_url'] if m else ''])
for c in C:
    rows.append(['4 name candidate',c['id'],c['name'],c['city'],'',('P' if c['pipe'] else '')+('L' if c['over50'] else '')+('W' if c['promo'] else ''),''])
csv.writer(open('rename-population-2026-11-04.csv','w',newline='',encoding='utf-8')).writerows([['group','venue_id','live_name','city','earlier_read_name','test','earlier_url']]+rows)
print(collections.Counter((x[0],x[5]) for x in rows)); print(collections.Counter(x[0] for x in rows))
print('own by src cand',collections.Counter(s for c in C for s in {a['s'] for a in c['aw'] or []} if s=='michelin'), 'michelin url', sum(any(a['s']=='michelin' and a['u'] for a in c['aw'] or []) for c in C), 'only michelin', sum({a['s'] for a in c['aw'] or []}=={'michelin'} for c in C))
