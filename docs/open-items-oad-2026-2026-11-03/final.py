import json,re,collections,csv,hashlib,unicodedata
O=json.load(open('l26_step4.json'));VL=json.load(open('venues.json'));V={v['id']:v for v in VL}
AW=json.load(open('oadrows.json'))
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD',s) if not unicodedata.combining(c)).lower()
def find(name,city):
    r=[v for v in VL if v['name']==name and v['city']==city]
    assert len(r)==1,(name,city,len(r));return r[0]['id']
K=lambda x:x['list'][0]+x['rank'].rstrip('*')
WRONG25="e270 e301 e321 e406 e412 e682 a69 a409 a430 a548 a560 a589 j240 j306 j373 j377 j501 j505 j515 j541 j590 j604 j658 j680".split()
HOLD="e116 e445 a48 a68 a170 a254 a327 a383 a486 a569 a575 a588 j180 j241 j353 j356 j459 j528 j558 e97 e378 e573 e304 e711 a143 a259 a389 j6 j27 j62 j191 j243 j339 j378 j395 j404 j422 j433 j462 j518 j524 j540 j610 j626 j677 j696 j438 j398 j425 j484 j287 j397 j700".split()
NONE="e319 e464 e504 e532 e677 a86 a508 a538 j372 j630 j463 j469 j480 j533 j561 j566 j674 j682 j711 j720 j750 j755 j759 j771 j792".split()
CITYFIX="e396 e716 e741 e541".split()
TO={'e433':('PURS Nordic Japanese',None),'j385':('Ren Mishina','Tokyo'),'j679':(None,'Tokyo'),'j435':('Kenya','Kyoto'),'a522':('Seventh Son','Beijing'),'a505':('Nhà hàng Gia','Hanoi'),'a100':('Chao Shang Chao (Chaoyang)','Beijing'),'e95':('KOL','London'),'e109':('Mugaritz','San Sebastián'),'e621':('Yamazato','Amsterdam'),'j203':('Ryuzu','Tokyo'),'j257':('Sushi Masuda','Tokyo')}
SAME="e20 e67 e156 e182 e197 e201 e233 e250 e256 e277 e284 e287 e289 e355 e362 e438 e467 e479 e511 e572 e612 e641 e656 e668 a22 a50 a91 a176 a290 a300 a363 a391 a394 a507 a549 a556 j11 j20 j60 j79 j112 j144 j156 j177 j221 j226 j317 j409 j498 j503 j510 j654 j690 e236 e302 e365 e420 e461 e518 e557 e627 e728 e756 a122 a253 a400 a464 a471 e680 j290 j569".split()
OTHER=dict.fromkeys("e236 e302 e365 e420 e461 e518 e557 e627 e728 e756 a122 a253 a400 a464 a471 e680 j290 j569".split())
res=[];un=collections.Counter()
for x in O:
    k=K(x);mv=x.get('mv');v=None;b25=x['b_rows'][0] if x['b_rows'] else None;note=''
    aw25=b25['aw'] if b25 else ''
    t=x['t']
    if k=='j773':
        c='already loaded';vi=find('Tempura Yamanoue Ginza','Tokyo');note='Award 32495 holds this row'
    elif k in WRONG25: c='no live venue';vi='';note=f"2025 row {aw25} sits on {V[b25['v']]['name']} ({V[b25['v']]['city']}): other place" if b25 else 'name match is another place'
    elif k in NONE: c='no live venue';vi='';note='name near a live venue, read as another place'
    elif k in HOLD: c='hold';vi=mv or '';note='Two readings possible. Not assigned'
    elif k in CITYFIX: c='city disagrees: move question';vi=mv;note='Live city is wrong on the OAD page address'
    elif k in TO:
        n,cc=TO[k]
        if k=='j679': cand=[v for v in VL if v['city']=='Tokyo' and 'lchimiste' in v['name']];assert len(cand)==1;vi=cand[0]['id']
        elif k=='e433': cand=[v for v in VL if v['name'].startswith('PURS') and v['city']=='Andernach'];assert len(cand)==1;vi=cand[0]['id']
        else:
            cand=[v for v in VL if v['name']==n and v['city']==cc]
            assert len(cand)==1,(k,n,cc,len(cand));vi=cand[0]['id']
        if k in('e95','e109','e621','j203','j257'): c='city disagrees: twin';note=f"Live venue in OAD city exists. 2025 row {aw25} sits on {V[b25['v']]['name']} ({V[b25['v']]['city']})"
        else: c='matched';note=f"2025 row {aw25} sits on {V[b25['v']]['name']}" if b25 and b25['v']!=vi else ''
    elif k in SAME:
        c='city disagrees: same place'
        vi=mv
        if k in OTHER:
            s=x['cand_any']; assert len(s)>=1,k; vi=s[0]
        note='OAD city is a neighbor, region or spelling. Venue stays'
    elif t.startswith('C:'): c='hold';vi=mv or '';note='Live city differs. Not assigned'
    elif t.startswith('N'): c='no live venue';vi=''
    elif t.startswith('M') or t.startswith('D'):
        c='matched';vi=mv
        if not vi: c='hold';vi='';note='No single venue'
    else: un[t]+=1;c='?';vi=''
    v=V.get(vi)
    method={'M:slug+name+city':'2025 row with same OAD slug, name and city','M:slug,name,no-city':'2025 row with same OAD slug and name; OAD prints no city','M:name+city':'Name and city; no 2025 row'}.get(t,'Read by hand from the OAD page' if t[0]=='D' else '')
    res.append(dict(list=x['list'],rank=x['rank_n'],new_mark=x['rank'].endswith('*'),printed_name=x['name'],printed_city=x['city'],printed_country=x['country'],chef=x['chef'],cuisine=x['cuisine'],oad_slug=x['slug'],status_group=c,live_venue_id=vi,live_name=v['name'] if v else '',live_city=v['city'] if v else '',live_status=v['status'] if v else '',method=method,row_2025_award=aw25,row_2025_rank=b25['rank'] if b25 else '',oad_page_address=x['addr'],oad_page_phone=x['phone'],oad_page_web=x['web'],note=note))
print(un)
# twice
bv=collections.defaultdict(list)
for r in res:
    if r['live_venue_id'] and r['status_group'] not in('hold',): bv[r['live_venue_id']].append(r)
tw=[(V[k]['name'],V[k]['city'],[(r['list'],r['rank'],r['printed_name'],r['printed_city'],r['status_group']) for r in rs]) for k,rs in bv.items() if len(rs)>1]
print(len(tw));[print(t) for t in tw]
slugkey=collections.defaultdict(list)
for r in res: slugkey[(ua(r['printed_name']).replace(' (new)',''),r['printed_city'])].append(r)
print([(k,[(r['list'],r['rank']) for r in v]) for k,v in slugkey.items() if len(v)>1])
for r in res:
    k=r['live_venue_id']
    r['printed_twice']= 'yes' if (k and len(bv.get(k,[]))>1) or r['oad_slug'] in('sushi-riku','sushiriku') else ''
c=collections.Counter(r['status_group'] for r in res);print(c,sum(c.values()))
print(collections.Counter((r['list'],r['status_group']) for r in res))
print('closed live among matched',sum(1 for r in res if r['live_status']=='closed' and r['status_group'] not in('hold',)),[(r['printed_name'],r['list'],r['rank'],r['live_city']) for r in res if r['live_status']=='closed' and r['status_group'] not in('hold',)])
print('W25 matched w/ other 2025',sum(1 for r in res if 'sits on' in r['note']))
print('oad closed marks',[(r['printed_name'],r['list'],r['rank'],r['live_name'],r['live_status'],r['status_group']) for r in res if re.search('closed',r['printed_name'],re.I)])
pg=json.load(open('pages.json'));ad=collections.Counter(p.get('address','') for p in pg.values())
print('pages',len(pg),'no addr',ad[''],'placeholder 1-1-1',sum(n for a,n in ad.items() if a.startswith('1-1-1') or '1-1-1 ' in a[:12]),'3-8-12 Minamiaoyama',ad['3-8-12 Minamiaoyama, Tokyo, Japan'])
print('2025 rows on live with no list row: bridge misses', 9)
F=list(res[0].keys())
with open('oad-2026-europe-asia-japan-evidence-2026-11-03.csv','w',newline='',encoding='utf-8') as f:
    w=csv.DictWriter(f,F);w.writeheader();w.writerows(res)
print(hashlib.sha256(open('oad-2026-europe-asia-japan-evidence-2026-11-03.csv','rb').read()).hexdigest())
json.dump(res,open('final.json','w'),ensure_ascii=True)
