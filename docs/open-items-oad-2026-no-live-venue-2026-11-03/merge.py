import json,collections,glob,re,unicodedata
R=json.load(open('rows311.json'));K={r['key']:r for r in R};S=json.load(open('status_v1.json'))
V=json.load(open('venues.json'));C=json.load(open('cities.json'))
rank={'none':0,'weak':1,'medium':2,'strong':3}
n=0;kept=0
for f in sorted(glob.glob('pass2-*.jsonl')):
    for l in open(f):
        if not l.strip():continue
        o=json.loads(l);p=S[o['key']];n+=1
        # second pass replaces unless it is a no-read and first pass had something
        if o['read_status']=='not_found' and p['read_status']=='open': kept+=1;p['pass2_note']=o['evidence_note'];continue
        if o['read_status']=='not_found' and rank[o.get('strength','none')]<rank[p.get('strength','none')]: kept+=1;continue
        o['pass']=2;S[o['key']]=o
print('pass2 lines',n,'kept prior',kept)
json.dump(S,open('status_v2.json','w'),ensure_ascii=False)
print(collections.Counter(o['read_status'] for o in S.values()))
print(collections.Counter((o['read_status'],o['strength']) for o in S.values()))
def show(o):
    r=K[o['key']]
    print(o['key'],r['printed_name'],'|',r['printed_city'],'|',o['read_status'],o['strength'],o['identity'],'|',o['real_name'],'|',o['real_city'],'|',o['evidence_note'][:150],'|',(o['evidence_url'] or '')[:80],'|',o['other_note'][:120])
print('=== closed etc');[show(o) for o in S.values() if o['read_status'] in('closed','temporarily_closed','conflict','seasonal')]
print('=== same_as_live');[print(o['key'],K[o['key']]['printed_name'],'=>',o['same_as_live_near'],'|',o['evidence_note'][:100]) for o in S.values() if o.get('same_as_live_near')]
