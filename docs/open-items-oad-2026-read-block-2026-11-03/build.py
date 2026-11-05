import csv,json,collections
base='/home/claude/benjamineades/compasseats/docs/open-items-oad-2026-2026-11-03/oad-2026-europe-asia-japan-evidence-2026-11-03.csv'
r=list(csv.DictReader(open(base,encoding='utf-8')))
R={}
for f in('r1','r2','r3'):
    for l in open(f+'.jsonl',encoding='utf-8'):
        if l.strip():
            x=json.loads(l);R[(x['list'],str(x['rank']))]=x
other={('europe','116'):'ve_8cd307127e OBA-',('asia','48'):'ve_29a960cf7b Xin Rong Ji (Jinrong Street)',('europe','378'):'ve_9b831f5bbc Flore (Amsterdam)',('europe','97'):'ve_ee9dbbdba9 Quattro Passi (closed)'}
out=[]
for x in r:
    k=(x['list'],x['rank']);hold=x['status_group'] in('hold','city disagrees: move question');sits='sits on' in x['note']
    if not(hold or sits):continue
    v=R.get(k,{})
    if hold:
        vd=v['verdict'];pop='hold or move'
        if k in other:a='3 load on another live venue'
        elif k==('asia','259'):a='5 question: Summer Palace rows cross'
        elif k==('japan','433'):a='1 load on live venue'
        elif vd=='same_place':a='1 load on live venue'
        elif vd=='same_place_live_city_wrong':a='2 load on live venue, correct the city'
        elif vd in('live_is_other_place','twin_branch'):a='4 new venue'
        else:a='6 no write, not proven'
    else:
        pop='2025 row on wrong venue'
        if k in(('japan','306'),('japan','377')):a='A no change, row is correct'
        elif k in(('europe','412'),('japan','501'),('japan','515'),('japan','590'),('japan','680')):a='C no correct venue yet'
        else:a='B move 2025 row to venue with 2026 row'
    out.append(dict(population=pop,proposed=a,list=x['list'],rank_2026=x['rank'],printed_name=x['printed_name'],printed_city=x['printed_city'],row_2025_award=x['row_2025_award'],row_2025_rank=x['row_2025_rank'],live_venue_id=x['live_venue_id'],live_name=x['live_name'],live_city=x['live_city'],live_status=x['live_status'],other_live_target=other.get(k,''),read_verdict=v.get('verdict',''),read_strength=v.get('strength',''),real_name=v.get('real_name',''),real_city=v.get('real_city',''),read_status=v.get('status',''),evidence_url=v.get('evidence_url',''),second_url=v.get('second_url',''),read_note=v.get('note',''),csv_note=x['note']))
w=csv.DictWriter(open('oad-2026-separate-read-block-evidence-2026-11-03.csv','w',encoding='utf-8',newline=''),fieldnames=list(out[0]));w.writeheader();w.writerows(out)
print(len(out),collections.Counter((o['population'],o['proposed']) for o in out))
