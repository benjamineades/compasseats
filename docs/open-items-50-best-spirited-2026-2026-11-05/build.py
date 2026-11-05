import json,re,unicodedata,collections,csv,hashlib,sys
exec(open('match.py').read().split("res=[]")[0])
R=json.load(open('match1.json'))
OUT='/home/claude/compasseats/docs/open-items-50-best-spirited-2026-2026-11-05/'
HAND={('Connaught Bar','London'):'ve_be4d971102',('Moebius Milano','Milan'):'ve_fde05d62a1',('Bar Carmen','Medellín'):'ve_6cd9c1b505',('MO Bar Shenzhen','Shenzhen'):'ve_0a2d39e6bd',('Coa (Shanghai)','Shanghai'):'ve_0d6a554162',('Mil','Cusco'):'ve_4d40a80629',('FZN','Dubai'):'ve_81e21905a6',('ViceVersa at the Elser Hotel','Miami'):'ve_ee59820013'}
HN={'ve_be4d971102':'Two live venues; this one is the bar and holds the earlier rows','ve_fde05d62a1':'Two live venues; this one is the bar and holds the earlier rows','ve_6cd9c1b505':'2025 No. 100 sits here. Live name is Carmen Medellín, publisher prints Bar Carmen','ve_0a2d39e6bd':'Asia 2025 No. 21 sits here','ve_0d6a554162':'Same name, same city. Top 500 2025 sits here','ve_4d40a80629':'Live name MIL Centro, city Moray. Publisher prints Mil, Cusco. Latin America rows sit here','ve_81e21905a6':'Live name FZN by Björn Frantzén. MENA 2026 sits here','ve_ee59820013':'North America 2026 No. 46 sits here'}
# new venue: (publisher name, place) -> (stored name, city slug, status url, read)
NEW={('Montana','Hong Kong'):('Montana','hong-kong','https://www.sassyhongkong.com/asias-50-best-bars-hong-kong-best-bars-eat-drink/'),
('La Borracha','Accra'):('La Borracha','accra','https://www.laborrachaghana.com/'),
('G.O.D','Bangkok'):('G.O.D','bangkok','https://www.theinfatuation.com/bangkok/reviews/g-o-d'),
('Three Horses','Melbourne'):('Three Horses','melbourne','https://australianbartender.com.au/2026/10/08/50-best-bars-caretakers-cottage-retains-australasia-title-three-horses-named-one-to-watch/'),
('Otro Bar','San José'):('Otro Bar','san-jose','https://ticosland.com/otro-bar-enters-global-elite-with-spot-on-prestigious-50-best-discovery-list/'),
('Mius','Hong Kong'):('Mius','hong-kong','https://100toptables.scmp.com/restaurants-profile-2026/mius'),
('Naked','Athens'):('Naked','athens','https://en.athinorama.gr/clubbing/3078117/the-worlds-50-best-bars-2026-lista-51-100/'),
('Bar Gabriel','Istanbul'):('Bar Gabriel','istanbul','https://barmagazine.com/bars/bar-gabriel-istanbul'),
('Tiao','Beijing'):('Tiao','beijing','https://danamic.org/2026/10/26/beijings-tiao-takes-over-bar-kap-on-31-october-cocktails-one-aged-in-clay/'),
('Aqua Bar','Bangkok'):('Aqua Bar','bangkok','https://www.aquabangkok.com/'),
('Problem Child','Makati'):('Problem Child','manila','https://mb.com.ph/2026/06/30/one-tokyo-night-at-problem-child'),
('M+MS Bar','Seoul'):('M+MS Bar','seoul','https://www.hapskorea.com/eight-seoul-bars-earn-spots-on-asias-best-bars-list/'),
('CMYK','Changsha'):('CMYK','changsha','https://www.spiritedasia.com/2026/07/asias-50-best-bars-2026/'),
('Pony Up','Shanghai'):('Pony Up','shanghai','https://rachelgouk.com/asias-50-best-bars-2026-hope-sesame-no-1-shanghais-pony-up-rises/'),
('Obsidian Bar','Shenzhen'):('Obsidian Bar','shenzhen','https://www.spiritedasia.com/2026/07/asias-50-best-bars-2026/'),
('The Spirits Library','Makati'):('The Spirits Library','manila','https://www.wheninmanila.com/bar-makati-asia-50-best-bars-extended-list-2026/'),
('Bar Long Fong','Beijing'):('Bar Long Fong','beijing','https://barmagazine.com/bars/bar-long-fong'),
('Ropewalk','Galle'):('Ropewalk','galle','https://www.theworlds50best.com/discovery/Establishments/Sri-Lanka/Galle/Ropewalk.html'),
('Chimney','Hangzhou'):('Chimney','hangzhou','https://www.the50.com/stories/News/asias-50-best-bars-2026-the-51-100-list-revealed.html'),
('Aabbcc','New Delhi'):('Aabbcc','new-delhi','https://www.timeout.com/delhi/bars-and-pubs/aabbcc'),
('Hats Bar','Jakarta'):('Hats Bar','jakarta','https://foodies.id/jakarta-bars-named-on-2026-asias-50-best-bars-extended-list/'),
('The Bar at the Ritz-Carlton Tokyo','Tokyo'):('The Bar at the Ritz-Carlton Tokyo','tokyo','https://www.spiritedasia.com/2026/10/the-bar-at-the-ritz-carlton-tokyo-origami/'),
('Between the Sips','Jakarta'):('Between the Sips','jakarta','https://foodies.id/jakarta-bars-named-on-2026-asias-50-best-bars-extended-list/'),
('Cabinet 8','Kuala Lumpur'):('Cabinet 8','kuala-lumpur','https://www.tatlerasia.com/dining/cabinet-8'),
('BOP','Singapore'):('BOP','singapore','https://www.drinkcollectiv.com/2026/08/02/jigger-pony-bop-pop-city-singapore/'),
('Bar Bon Funk','Singapore'):('Bar Bon Funk','singapore','https://www.the50.com/stories/News/asias-50-best-bars-2026-the-51-100-list-revealed.html'),
('Cobra','Columbus'):('Cobra','columbus','https://614now.com/2026/food-drink/local-bar-tapped-as-best-u-s-restaurant-bar-by-prestigious-industry-awards'),
('Bryant’s Cocktail Lounge','Milwaukee'):("Bryant's Cocktail Lounge",'milwaukee','https://urbanmilwaukee.com/2026/07/07/bryants-cocktail-lounge-wins-timeless-award/')}
def ua(s): return ''.join(c for c in unicodedata.normalize('NFKD',s) if not unicodedata.combining(c))
def slugify(s): return re.sub(r'[^a-z0-9]+','-',ua(s).lower()).strip('-')
def md(s): return hashlib.md5(s.encode()).hexdigest()[:10]
bys={c['s']:c for c in C['cities']}
URL={'worlds-50-best-bars':'https://www.the50.com/bars/best-in-the-world/list/','asia-50-best-bars':'https://www.the50.com/bars/best-in-asia/list/','worlds-50-best-restaurants':'https://www.the50.com/restaurants/best-in-the-world/list/'}
SP='https://talesofthecocktail.org/tales-of-the-cocktail-foundation-announces-2026-spirited-awards-winners/'
CODE={'worlds-50-best-bars':'wb','asia-50-best-bars':'ab','worlds-50-best-restaurants':'wr','spirited-awards':'sp'}
ORDER=['worlds-50-best-bars','asia-50-best-bars','worlds-50-best-restaurants','spirited-awards']
new={};ev=[];aw_rows=[]
for r in sorted(R,key=lambda x:(ORDER.index(x['src']),x['rank'] or 0)):
    key=(r['name'],r['place']);note='';proof=''
    if key in NEW:
        nm,cs,st=NEW[key];sl=slugify(nm);vid_='ve_'+md(cs+':'+sl)
        if vid_ not in new: new[vid_]=dict(id=vid_,name=nm,cs=cs,sl=sl,clab=r['place'] if r['place']!='Washington, D.C.' else r['place'],colab=(bys[cs]['co'] if cs in bys else 'Sri Lanka'),pub=r['src'],st=st)
        group='new venue';vn=nm;vcat='bar';vst='active';vcs=cs;proof='no live venue found by name in any city';note='status read: '+st
    else:
        if key in HAND: i=HAND[key];group='matched by hand';note=HN[i]
        else:
            assert len(r['cands'])==1,key; i=r['cands'][0][0];group={'exact_city':'same name same city','loose_city':'same name after removing bar or restaurant','contain_city':'publisher name inside live name'}[r['group']]
        v=vid[i];vid_=i;vn=v['name'];vcat=v['cat'];vst=v['st'];vcs=v['cs']
        pr=[a for a in aw[i] if a['s']==r['src'] and a['y']<2026]
        oth=[a for a in aw[i] if a['s'] in('worlds-50-best-bars','asia-50-best-bars','top-500-bars','north-america-50-best-bars','europe-50-best-bars','spirited-awards','asia-50-best-restaurants','latin-america-50-best-restaurants','mena-50-best-restaurants','north-america-50-best-restaurants','worlds-50-best-restaurants')]
        proof=('earlier row same list: '+str(max(pr,key=lambda a:a['y'])['y'])) if pr else (f"other list rows {len(oth)}" if oth else f"other award rows {v['aw']}")
    url=(URL[r['src']]+r['block']) if r['rank'] else SP
    aw_rows.append(dict(c=CODE[r['src']],rank=r['rank'],cat=r['cat'],v=vid_,url=url))
    ev.append(dict(source=r['src'],rank=r['rank'] or '',category=r['cat'],publisher_name=r['name'],publisher_place=r['place'],venue_id=vid_,live_name=vn,live_category=vcat,live_status=vst,live_city=vcs,group=group,proof=proof,note=note,source_url=url))
print(len(ev),len(new),collections.Counter(e['group'] for e in ev))
with open(OUT+'50-best-spirited-2026-evidence-2026-11-05.csv','w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(ev[0].keys()));w.writeheader();w.writerows(ev)
json.dump(dict(ev=ev,new=new,aw=aw_rows),open('plan.json','w'),ensure_ascii=False,indent=0)
# checks
print('venue twice same source',[(k,c) for k,c in collections.Counter((e['source'],e['venue_id']) for e in ev if e['source']!='spirited-awards').items() if c>1])
print('closed',[e['publisher_name'] for e in ev if e['live_status']!='active'])
print('cat diff',[(e['source'][:6],e['publisher_name'],e['live_category']) for e in ev if e['live_category']!=('restaurant' if e['source']=='worlds-50-best-restaurants' else 'bar')])
print('proof weak',[(e['source'][:6],e['rank'],e['publisher_name'],e['live_name'],e['proof']) for e in ev if e['group']!='new venue' and e['proof'].startswith('other award')][:40])
print('city differs',[(e['publisher_name'],e['publisher_place'],e['live_city']) for e in ev if e['group']!='new venue' and k(e['publisher_place']).replace(' ','-')!=e['live_city'] and k(e['publisher_place'])!=k(e['live_city'])])
print('name differs n',sum(1 for e in ev if e['group']!='new venue' and k(e['publisher_name'])!=k(e['live_name'])))
print('name differs',sorted(set((e['publisher_name'],e['live_name']) for e in ev if e['group']!='new venue' and tight(e['publisher_name'])!=tight(e['live_name']))))
