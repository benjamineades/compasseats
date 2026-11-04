import csv,hashlib,json,collections
ev=list(csv.DictReader(open('oad-2026-separate-read-block-evidence-2026-11-03.csv',encoding='utf-8')))
rel={(x['list'],int(x['rank_n'])):x for x in (json.loads(l) for l in open('/home/claude/benjamineades/compasseats/docs/open-items-oad-2026-2026-11-03/oad-2026-lists-relay-2026-11-03.jsonl',encoding='utf-8') if l.strip().startswith('{'))}
def nid(cs,s): return 've_'+hashlib.md5(f'{cs}:{s}'.encode()).hexdigest()[:10]
import re,unicodedata
def slug(n):
    t=''.join(c for c in unicodedata.normalize('NFKD',n) if not unicodedata.combining(c)).lower()
    return re.sub(r'[^a-z0-9]+','-',t).strip('-')
C={'berlin':'ci_d35a02eb49','desenzano-del-garda':'ci_3c7e34aba1','munich':'ci_c1fd4f351f','beijing':'ci_0420a206ae','taipei':'ci_39139f000b','kyoto':'ci_e27d6ba3c4','nagoya':'ci_44e7d2f2c0','fukuoka':'ci_bd7396e9f8','tokyo':'ci_ef0cc10ff4','copenhagen':'ci_12fff1be2f','beersel':'ci_1edbcd420e','milan':'ci_83227a721a','vienna':'ci_2f7515e8c5','kitakyushu':'ci_bc54b43bf0','gifu':'ci_a70bda71cc','dubai':'ci_3c40d285e6'}
newc=[('kuwana','Kuwana'),('kawasaki','Kawasaki'),('tatebayashi','Tatebayashi'),('karatsu','Karatsu'),('utsunomiya','Utsunomiya'),('hamamatsu','Hamamatsu'),('nishinomiya','Nishinomiya')]
for s,_ in newc: C[s]='ci_'+hashlib.md5(s.encode()).hexdigest()[:10]
# group 4 and C: list, rank, name, city slug, status, country, award to move, old venue
N=[('e',445,'Brikz','berlin','a','Germany',18602,'ve_62e4b855de'),('e',573,'Mos','desenzano-del-garda','a','Italy',18570,'ve_1c5f2c33e9'),('e',711,'Mural','munich','a','Germany',18581,'ve_51fccb143f'),
('a',254,'Ling Long Beijing','beijing','a','China',None,None),('a',327,'Country Kitchen','beijing','a','China',18157,'ve_10b312a8c3'),('a',389,'Orchid','taipei','a','Taiwan',18185,'ve_5be4142ef6'),
('j',241,'Saika','kyoto','a','Japan',18732,'ve_5667947ced'),('j',243,'Pierre Gagnaire','tokyo','c','Japan',7070,'ve_cf1874968b'),('j',353,'Hinode','kuwana','a','Japan',18891,'ve_445ca5a848'),('j',356,'Kyo Seika','kyoto','a','Japan',5772,'ve_7ba5a45715'),('j',378,'Mikasa','kawasaki','c','Japan',18889,'ve_49fdf50eda'),('j',404,'Sushi Ueda','nagoya','a','Japan',18873,'ve_1b66998fec'),('j',524,'Tsugumi','fukuoka','a','Japan',18972,'ve_7ff0bac8d5'),('j',528,'Kawada','tokyo','a','Japan',19088,'ve_7ff2913e10'),('j',558,'Rokkan','tokyo','a','Japan',18999,'ve_5f3035e6f8'),
('a',143,"Howard's Gourmet Beijing",'beijing','c','China',18060,'ve_5126fcd962'),('a',170,'1949 Duck de Chine','beijing','a','China',18084,'ve_7797bd66bd'),('e',304,'Punk Royale Copenhagen','copenhagen','a','Denmark',None,None),('j',459,'Kitafuku Akasaka','tokyo','a','Japan',18952,'ve_af6c894a24'),
('j',590,'Romantico','tokyo','a','Japan',19045,'ve_4565df5d21'),('j',680,'Arakawa','kyoto','a','Japan',19110,'ve_311a84938e'),('j',515,'Miyako Zushi','tokyo','c','Japan',18941,'ve_cf2ad8356c')]
L={'e':'europe','a':'asia','j':'japan'}; LI={v:k for k,v in L.items()}
nl=[];mv=[]
for l,r,n,cs,st,co,aw,ov in N:
    p=rel[(L[l],r)]
    nl.append(f"{l}|{r}|{n}|{cs}|{st}|{p['city'] or cs.title()}|{co}")
    if aw: mv.append((aw,ov,nid(cs,slug(n))))
# group B moves, from the live read
B={18051:('ve_2ead0176c8','ve_1b85694549'),18110:('ve_2760d564fe','ve_1af6a9c4c4'),18232:('ve_7e3068bc36','ve_67409605cb'),18293:('ve_a73796bf14','ve_abccb8710d'),18306:('ve_ff1c2fe6e6','ve_e4f54dd59b'),18307:('ve_6f6e265236','ve_934b1cb36a'),18352:('ve_04d463f18a','ve_4d0167e3ff'),18365:('ve_9ac925a36e','ve_57517b6560'),18386:('ve_383d531c0a','ve_cbb6307531'),18408:('ve_9159a30107','ve_5073942728'),18418:('ve_d506cb62f8','ve_bfda4f7b82'),18431:('ve_fea80d77c8','ve_3ffab4597c'),18457:('ve_6318a102be','ve_969a2eb301'),18478:('ve_5ded6b173b','ve_61fa83ffc1'),18539:('ve_0a68920747','ve_292dd0b5e7'),18560:('ve_bafcec17d6','ve_b6934408cf'),18772:('ve_e3c60e040c','ve_1613162f00'),18761:('ve_f40bce7d13','ve_893dbeaa44'),18777:('ve_96292e1874','ve_7169692a4c'),18909:('ve_034bdfaa6b','ve_2e21a1be11'),18886:('ve_e67359bf24','ve_b129b5c20e'),18938:('ve_c26eac7c0d','ve_418d1e9238'),19085:('ve_55101794e8','ve_2c881f6f4f'),19044:('ve_5669aef5b4','ve_ce398e568f'),19014:('ve_ad9f275625','ve_2dbb60d900'),19060:('ve_b5a03ee530','ve_fbc1526c55'),19076:('ve_01ed923bb7','ve_38014b33f3')}
for a,(o,n) in B.items(): mv.append((a,o,n))
mv+= [(15965,'ve_83aca60857','ve_8cd307127e'),(20377,'ve_ed8fe96699','ve_29a960cf7b')]
assert len(mv)==49
# awards on live venues: groups 1,2,3
al=[]
g3={('europe','116'):'ve_8cd307127e',('asia','48'):'ve_29a960cf7b',('europe','378'):'ve_9b831f5bbc',('europe','97'):'ve_ee9dbbdba9'}
for x in ev:
    if x['proposed'][0] in '12': al.append(f"{LI[x['list']]}|{x['rank_2026']}|{x['live_venue_id']}")
    if x['proposed'][0]=='3': al.append(f"{LI[x['list']]}|{x['rank_2026']}|{g3[(x['list'],x['rank_2026'])]}")
assert len(al)==34
# group 2
G=[('ve_d1d544cb55','barcelona','ci_dea56e47f1','beersel','terborght-restaurant'),('ve_fc37e08929','san-sebastian','ci_453d152d6b','milan','motelombroso'),('ve_53659a02aa','london','ci_bc180dbc58','vienna','heunisch-erben'),('ve_b48f87e3df','gunma','ci_682f64ae58','tatebayashi','sushi-obana'),('ve_867747314e','saga','ci_e0145e19f4','karatsu','tsukuta'),('ve_314eb75a52','tokyo','ci_ef0cc10ff4','utsunomiya','otowa-restaurant'),('ve_38c4c03bad','sugawara','ci_1dc5713332','kitakyushu','teruzushi'),('ve_049a332738','saga','ci_e0145e19f4','karatsu','amegen'),('ve_9f8a4d46c3','shizuoka','ci_ce90100a18','hamamatsu','rin'),('ve_d47d2ce7dd','tokyo','ci_ef0cc10ff4','gifu','kaikatei'),('ve_74eb3c7820','shizuoka','ci_ce90100a18','tokyo','seika-kobayashi'),('ve_234bc5fd17','kobe','ci_2357e8fb99','nishinomiya','komago'),('ve_a6dc74a321','shizuoka','ci_ce90100a18','hamamatsu','seirin'),('ve_9bef9d816c','kyoto','ci_e27d6ba3c4','tokyo','grill-ukai-marunouchi')]
gl=[f"{v}|{ocs}|{oc}|{ncs}|{C[ncs]}|{s}" for v,ocs,oc,ncs,s in G]
rd=[f"/{ocs}/{s}|/{ncs}/{s}" for v,ocs,oc,ncs,s in G]+["/torshavn/kol|/london/kol","/munich/mugaritz|/san-sebastian/mugaritz","/paris/yamazato|/amsterdam/yamazato","/kyoto/ryuzu|/tokyo/ryuzu","/kyoto/masuda|/tokyo/sushi-masuda"]
# deleted venues with city id; es.TABLE is closed
DV={'ve_af6c894a24':'ci_ef0cc10ff4','ve_01ed923bb7':'ci_c40ee849d3','ve_034bdfaa6b':'ci_632346833d','ve_04d463f18a':'ci_24d545382b','ve_0a68920747':'ci_ccbee73cd8','ve_10b312a8c3':'ci_0420a206ae','ve_1b66998fec':'ci_2357e8fb99','ve_1c5f2c33e9':'ci_2f7515e8c5','ve_2760d564fe':'ci_d3197fb64e','ve_2ead0176c8':'ci_1b1537ad28','ve_311a84938e':'ci_ef0cc10ff4','ve_383d531c0a':'ci_c1fd4f351f','ve_445ca5a848':'ci_49f3fe6cf6','ve_4565df5d21':'ci_e27d6ba3c4','ve_49fdf50eda':'ci_5eca04ba01','ve_51fccb143f':'ci_2609eaea1a','ve_55101794e8':'ci_e27d6ba3c4','ve_5667947ced':'ci_e27d6ba3c4','ve_5669aef5b4':'ci_ef0cc10ff4','ve_5be4142ef6':'ci_39139f000b','ve_5ded6b173b':'ci_edcd259e0a','ve_5f3035e6f8':'ci_ef0cc10ff4','ve_62e4b855de':'ci_d35a02eb49','ve_6318a102be':'ci_a28019996b','ve_6f6e265236':'ci_22638a3131','ve_7e3068bc36':'ci_d3197fb64e','ve_7ff0bac8d5':'ci_bd7396e9f8','ve_7ff2913e10':'ci_ef0cc10ff4','ve_9159a30107':'ci_3478655335','ve_96292e1874':'ci_e27d6ba3c4','ve_9ac925a36e':'ci_9218eb7cfd','ve_a73796bf14':'ci_0420a206ae','ve_ad9f275625':'ci_e27d6ba3c4','ve_b5a03ee530':'ci_2357e8fb99','ve_bafcec17d6':None,'ve_c26eac7c0d':'ci_e27d6ba3c4','ve_cf2ad8356c':'ci_ef0cc10ff4','ve_e3c60e040c':'ci_e27d6ba3c4','ve_e67359bf24':'ci_498e4a67c7','ve_f40bce7d13':'ci_e27d6ba3c4','ve_fea80d77c8':'ci_fbf7f09c90','ve_ff1c2fe6e6':'ci_1b1537ad28'}
assert len(DV)==42
# every moved-from venue that keeps nothing is deleted; check
keep={'ve_d506cb62f8','ve_83aca60857','ve_ed8fe96699','ve_cf1874968b','ve_7ba5a45715','ve_5126fcd962','ve_7797bd66bd'}
assert {o for a,o,n in mv}==set(DV)|keep, ({o for a,o,n in mv}^(set(DV)|keep))
d=collections.Counter()
for n in N:
    if n[4]=='a': d[C[n[3]]]+=1
for v,ocs,oc,ncs,s in G: d[oc]-=1; d[C[ncs]]+=1
d[C['dubai']]+=1
for v,c in DV.items():
    if c: d[c]-=1
d={k:v for k,v in d.items() if v}
assert sum(d.values())==-22,sum(d.values())
upd=len(d)
print('city rows to update',upd,'of which new',sum(1 for s,_ in newc if C[s] in d))
ids=sorted(DV)
nv=[nid(n[3],slug(n[2])) for n in N]
nv_s=sorted(nv)
json.dump(dict(nl=nl,al=al,mv=mv,gl=gl,rd=rd,ids=ids,upd=upd,nv=nv_s,newc=newc),open('plan.json','w'),ensure_ascii=False,indent=0)
print('\n'.join(nl)); print(rel.get(('japan',0)))
for k,v in rel.items():
    if any(t in v['name'] for t in('Kojyu','Toritama','Kojyū','Kojyu')): print(k,v['name'],v['city'])
qm=",".join(str(a) for a,o,n in sorted(mv))
print('MV',qm)
print('DEL',",".join("'"+i+"'" for i in ids))
print('LIVE',",".join("'"+i+"'" for i in sorted({a.split('|')[2] for a in al}|{g[0] for g in G}|{n for _,_,n in mv if n not in nv}|keep|{'ve_d2c67e7d3d','ve_fdea70bea1','ve_f0f0978f15'})))
