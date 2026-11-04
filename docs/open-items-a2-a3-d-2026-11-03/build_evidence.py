import csv,hashlib
O='https://www.oadguides.com/lists/%s/top-restaurants/%d'
D='https://www.oadguides.com/restaurant/'
NA25,NA26=O%('north-america',2025),O%('north-america',2026)
E25,J25,A25=O%('europe',2025),O%('japan',2025),O%('asia',2025)
S25,S26=O%('south-america',2025),O%('south-america',2026)
J26=O%('japan',2026)
MS='ve_fbcb833f0c';MM='New venue Masa, New York'
FG='https://www.forbestravelguide.com/restaurants/new-york-city-new-york/masa'
MI='https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-to-new-york-city-2025'
LL='https://culinaryagents.com/resources/2026-la-liste-award-winners-us'
W50='https://www.the50.com/restaurants/best-in-the-world/previous-list/%d'
R=[]
def a(item,aid,vid,src,yr,rk,prints,action,status,url,url2=''):
    R.append(dict(item=item,award_id=aid,live_venue_id=vid,source=src,year=yr,rank=rk,publisher_prints=prints,proposed_action=action,status_evidence=status,evidence_url=url,second_url=url2))
ST_MASA='Forbes 2026 page; Michelin Nov 2025 list; Resy Mar 2026 says Bar Masa is next to Masa; own site masanyc.com'
for aid,yr,rk,u in ((2670,2025,67,NA25),(2668,2026,92,NA26)):
    a('1 A2',aid,MS,'oad',yr,rk,'Masa, New York, Masayoshi Takayama',MM,ST_MASA,u,D+'masa')
for aid,yr,cat in ((2659,2026,''),(2660,2025,''),(2661,2024,''),(2662,2023,''),(2663,2022,''),(2664,2021,''),(2665,2020,'')):
    a('1 Masa extra',aid,MS,'forbes-travel-guide',yr,'','Masa (2026 page); earlier years not read',MM,ST_MASA,FG if yr==2026 else '')
a('1 Masa extra',2666,MS,'la-liste',2026,'','Masa (New York, NY) Score - 83.5; second-hand copy of La Liste',MM,ST_MASA,'',LL)
a('1 Masa extra',2667,MS,'michelin',2025,'','Masa, Two Stars; Bar Masa not on the page',MM,ST_MASA,MI)
a('1 Masa extra',2672,MS,'worlds-50-best-restaurants',2009,27,'Masa, New York, No. 27',MM,ST_MASA,W50%2009)
a('1 Masa extra',2673,MS,'worlds-50-best-restaurants',2005,32,'Masa, New York, No. 32',MM,ST_MASA,W50%2005)
a('1 stays',2671,MS,'oad',2025,387,'Bar Masa, New York, Masa Takayama','Stay on Bar Masa, add URL','Resy Mar 2026: open',NA25,D+'bar-masa')
a('1 stays',2669,MS,'oad',2026,396,'Bar Masa, New York, Masa Takayama','Stay on Bar Masa, add URL','Resy Mar 2026: open',NA26,D+'bar-masa')
G='Publisher duplicate: OAD pages gari and sushi-of-gari print the same address 347 W 46th St and phone 212-957-0046'
a('1 Gari',17234,'ve_6c564637e8','oad',2025,254,'Gari, New York, Mastoshi Gari Sugio','No new venue. Ben decides keep or remove',G,NA25,D+'gari')
a('1 Gari',17232,'ve_6c564637e8','oad',2026,267,'Gari, New York, Mastoshi Gari Sugio','No new venue. Ben decides keep or remove',G,NA26,D+'gari')
a('1 A2',18439,'ve_e8097f89e5','oad',2025,304,'Da Niko, Milan, Italy, Davide Capucchio (OAD link: il-ristorante-niko-romito)','New venue Da Niko, Milan','Dissapore Aug 31 2026: opened Sep 1 2026 in place of Il Ristorante at Bvlgari Milano; hotel page offers booking',E25,'https://www.dissapore.com/notizie/cosa-si-mangera-e-quanto-si-spendera-nel-nuovo-ristorante-di-niko-romito-a-milano/')
a('1 A2',6339,'ve_e4697958f0','oad',2025,407,'Moi Omakase, Prato, Italy, Daniel Ochoa (own site names Francesco Preite)','New venue MOI Omakase, new city Prato','Michelin card (2026 guide, no award, not closed); own site shows hours',E25,'https://guide.michelin.com/en/toscana/prato/restaurant/moi-omakase')
a('1 A2',17532,'ve_1b2f4308ae','oad',2025,580,'Buca Yorkville, Toronto, Justin Friedlich','New venue Buca Yorkville, Toronto','OpenTable takes bookings Nov 3 2026, 53 Scollard St; not on OAD 2026',NA25,'https://opentable.com/buca-yorkville')
a('1 A2',18648,'ve_411ead11c6','oad',2025,28,'Mitani, Tokyo, Yasuhiko Mitani, 1-22 Yotsuya','New venue Mitani, Tokyo','OAD 2026 No. 25; Goethe Dec 2021 and Oct 2022 say hard to book. No read after 2022. Kioicho Mitani is a 2016 branch (Takano)',J25,D+'mitani')
a('1 A2',18695,'ve_fe34271323','oad',2025,469,'Yakitori Kurosaki, Tokyo, Yu Kurosaki, 3-8-12 Minamiaoyama','New venue Yakitori Kurosaki, Tokyo','OAD 2026 No. 440. Tabelog: yakitori Kurosaki 5-13-25 Shirokanedai, regular hours. Address differs from OAD. Link not proven',J25,'https://tabelog.com/en/tokyo/A1316/A131602/13305458/')
a('1 A2',18713,'ve_61cf53898d','oad',2025,107,'Yamasaki, Tokyo, Shiro Yamasaki, 2-11-3 Nishi-Azabu, site yamazaki0823.com','New venue, name question (Yamasaki or Yamazaki)','OAD 2026 No. 123; Tabelog Yamasaki 1-15-3 Nishi-Azabu not closed; live Yamazaki is Koji Yamazaki (Toyama, Tokyo)',J25,'https://tabelog.com/en/tokyo/A1307/A130701/13225691/')
a('1 A2',18846,'ve_26a217eb82','oad',2025,528,'Saeki Hanten, Tokyo, Yutaro Saeki, Chinese','New venue Saeki Hanten, Tokyo','OAD 2026 No. 620; Tabelog 2-10-30 Mita Meguro, reservations available',J25,'https://ssl.tabelog.com/en/tokyo/A1316/A131601/13233311/')
a('1 A2',18127,'ve_7b02b65595','oad',2025,179,'Jean Georges, Shanghai, Nikolai Grigorov','New venue Jean Georges, Shanghai','OAD 2026 No. 230; jean-georges.com lists 4F Three on the Bund, no closure notice',A25,'https://www.jean-georges.com/restaurants/china/shanghai/jean-georges')
a('2 A3',18027,'ve_a248207d2a','oad',2025,354,'Sushi Saito, Hong Kong, Nawate Ryosuke (also at No. 21; 2026 No. 49 and No. 490; both rows link to one OAD page)','Same venue. Ben decides keep or remove','Publisher duplicate in both years',A25,D+'sushi-saito')
a('2 A3',19032,'ve_5ba6c32664','oad',2025,498,'Tempura Yamanoure, Tokyo, Junichi Yabuki, phone 03-5413-3577','New venue Tempura Yamanoue Roppongi, Tokyo','Own site: Roppongi open, same phone 03-5413-3577, Tokyo Midtown',J25,'https://www.yamanoue-hotel.co.jp/tempurayamanoue/roppongi/map.html')
a('2 A3',19033,'ve_5ba6c32664','oad',2025,590,'Yama no Ue, Masanori Teraoka, 1-1 Kanda Surugadai','New venue Yama no Ue, Tokyo, closed, not published','Own site: main shop and Hilltop Hotel currently closed, no date',J25,'https://yamanoue-hotel.co.jp/tempurayamanoue/en')
a('2 A3 new row','(new)','ve_5ba6c32664','oad',2026,773,'Tempura Yamanoue, Tokyo, Various, Ginza Core 5F','New row on Tempura Yamanoue Ginza. Otherwise this venue holds 0 awards','Own site: Ginza open',J26,D+'tempura-yamanoue')
a('3 D',18573,'ve_444325fab9','oad',2025,615,'Kabuki, Milan, Spain, Ricardo Sanz; OAD page: Calle de Lagasca 38, +34 915, No. 37 in Madrid','Move venue to Madrid, redirect /milan/kabuki-madrid, add URL','Michelin card Lagasca 38 Madrid, no closure notice; grupokabuki.com: opened Oct 2023',E25,'https://guide.michelin.com/us/en/comunidad-de-madrid/madrid/restaurant/kabuki-madrid')
for aid,yr,rk,u in ((17958,2025,48,S25),(17957,2026,53,S26)):
    a('3 D',aid,'ve_2935ce649e','oad',yr,rk,'Carmen, Lima, Colombia, Carmen Angel, Colombian; OAD page has no address','Move venue to Medellín, redirect /lima/carmen, add URL','OpenTable Carmen, Cra. 36 #10a-27 Medellín, takes bookings; Reporter Gourmet: founded by Carmen Angel; no Lima venue found',u,'https://www.opentable.com/r/carmen-medellin')
for aid,yr,rk,u in ((17913,2025,28,S25),(17912,2026,33,S26)):
    a('3 D',aid,'ve_6ed52d9126','oad',yr,rk,'Fiesta, Lima, Argentina, Germán Sitz & Pedro Peña; OAD page: Av. Reducto 1278 Miraflores Peru, +51, No. 13 in Peru','Venue stays in Lima. Add URL','OAD own page proves Peru. Own site blocked to the reader. No closure notice read',u,D+'fiesta')
F='item award_id live_venue_id source year rank publisher_prints proposed_action status_evidence evidence_url second_url'.split()
p='a2-a3-d-evidence-2026-11-03.csv'
with open(p,'w',newline='',encoding='utf-8') as f:
    w=csv.DictWriter(f,F);w.writeheader();w.writerows(R)
print(len(R),hashlib.sha256(open(p,'rb').read()).hexdigest())
K=sorted((r for r in R if r['award_id']!='(new)'),key=lambda r:r['award_id'])
s='\n'.join(f"{r['award_id']}|{r['live_venue_id']}|{r['source']}|{r['year']}|{r['rank']}" for r in K)
print(len(K),hashlib.md5(s.encode()).hexdigest())
print(','.join(str(r['award_id']) for r in K))
