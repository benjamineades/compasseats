-- awards-michelin-2026-special-awards.sql
-- CompassEats, Oct 29 2026. Michelin special awards, Green Stars and Mindful Voices (block B).
-- Source: guide.michelin.com only (ceremony and award articles, venue pages), read in the
--   built-in browser Oct 29; checked copy relay.txt sha256 fe17ce67eb78250082bb4c89499f757f9b0bd217c2a54daf5d1bb9431b88243f.
-- Batch file: michelin-2026-special-awards.csv (489 rows + header) sha256
--   09cf8dc4b7bfb04bd90077f96f694a5275a7b2eabf9abf9bbee9b21d0d3e5665. 430 rows to insert, 59 skipped (how = skip).
-- Ben's rulings Oct 29: Q1 A scope; Q2 A person in distinction; Q3 A only venues already in the DB;
--   Q4 A new category Mentor Chef Award; Q5 A legacy rows: add source_url where proven, no delete;
--   QA A Green Star only where a 2026 source names the venue, Mindful Voices from the venue page block;
--   QB A France "gastronomie engagee" and Belgium "gastronomy of tomorrow" = Green Star; QC A partial lists:
--   named venues only; QD A one spelling "Service Award"; QE A two winners -> one row "A & B";
--   QF B Pierre Gagnaire Mentor Chef -> ve_7b51bfe39a; QG A 21 Japan green-mark pages = Green Star 2026,
--   source = venue page; QH A name matches Inver, Bacanora PHX, La Table de Christophe Hay et Lois Bee accepted.
-- Venue match: by Michelin page path (locale removed) against existing Michelin award source_url rows,
--   inside this transaction; 9 rows by venue id (name match). Each row must match exactly one venue.
-- Guards: expanded rows md5 55ccab86e479b45c03005a10a007c64f (line|category|year|person|source_url|page key|venue id);
--   line:venue md5 077b151a8b0f3036a3e5197abdaf61b6 (362 venues); no row may already exist for the
--   venue + category + year.
-- Expected: 2 award_categories rows; 430 awards INSERT; 18 awards UPDATE; 1 ledger row; 448 audit rows.
--   awards 22,922 -> 23,352. Nothing is deleted.
-- Dry run: send this file through the Read connector. All pre-checks run, then the block stops at the
--   first INSERT with "read-only transaction".

BEGIN;
DO $do$
DECLARE
  plan_txt text := '{"a":[
"us/en/article/michelin-guide-ceremony/miscellanea-spirit-house-oxford-michelin-guide-cocktails-award",
"us/en/article/michelin-guide-ceremony/michelin-stars-news-uk-ireland-2026",
"en/article/news-and-views/michelin-guide-beijing-2026",
"en/article/michelin-guide-ceremony/michelin-stars-chengdu-2027",
"fr/fr/article/michelin-guide-ceremony/le-palmares-du-guide-michelin-france-et-monaco-2026",
"gb/en/article/michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new",
"it/it/notizia/michelin-guide-ceremony/guida-michelin-italia-2026-5-nuove-stelle-verdi",
"jp/en/article/michelin-guide-ceremony/michelin-guide-kyoto-osaka-2026-stars-reveal",
"es/es/articulo/michelin-guide-ceremony/restaurantes-con-estrella-verde-2026-5-novedades-en-espana",
"tw/en/article/michelin-guide-ceremony/taiwan-full-list",
"jp/en/article/michelin-guide-ceremony/michelin-guide-tokyo-2026-stars-reveal",
"fr/fr/article/michelin-guide-ceremony/prix-chef-mentor-guide-michelin-2026-pierre-gagnaire-france",
"en/article/news-and-views/michelin-guide-fujian-2026",
"en/article/michelin-guide-ceremony/michelin-stars-guangzhou-shenzhen-2026",
"it/it/notizia/michelin-guide-ceremony/il-maestro-heinz-beck-conquista-il-premio-michelin-chef-mentor",
"en/article/michelin-guide-ceremony/michelin-guide-shanghai-jiangsu-zhejiang",
"es/es/articulo/michelin-guide-ceremony/quique-dacosta-premio-michelin-al-chef-mentor-2026",
"en/article/michelin-guide-ceremony/cuines-33-and-the-jane-awarded-two-stars-in-the-michelin-guide-belgium-and-luxembourg-2026",
"de/de/article/michelin-guide-ceremony/die-michelin-awards-2026",
"it/it/notizia/michelin-guide-ceremony/al-madrigale-di-gian-marco-bianchi-conquista-la-stella-ed-il-michelin-opening-of-the-year",
"tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026",
"us/en/article/michelin-guide-ceremony/penrose-room-colorado-springs-michelin-guide-service-award",
"fr/fr/article/michelin-guide-ceremony/prix-service-guide-michelin-2026-virtus-monte-carlo-restaurants",
"en/article/michelin-guide-ceremony/azurite-and-suis-awarded-two-michelin-stars-each-in-the-2026-netherlands-michelin-guide",
"us/en/article/michelin-guide-ceremony/restaurant-joel-robuchon-mgm-grand-las-vegas-michelin-guide-service-award",
"es/es/articulo/michelin-guide-ceremony/todo-sobre-la-guia-michelin-espana-andorra-2026",
"us/en/article/michelin-guide-ceremony/barley-swine-texas-michelin-guide-service-award",
"fr/fr/article/michelin-guide-ceremony/prix-sommellerie-guide-michelin-2026-deux-passeurs-deux-terroirs",
"it/it/notizia/michelin-guide-ceremony/michelin-sommelier-award-a-ivana-capraro-del-castel-fine-dining",
"es/es/articulo/michelin-guide-ceremony/luis-baselga-premio-michelin-al-sommelier-2026",
"us/en/article/michelin-guide-ceremony/the-story-of-mi-carino-charlotte-michelin-guide-young-chef-award",
"fr/fr/article/michelin-guide-ceremony/prix-jeune-chef-2026-guide-michelin-quentin-pellestor-veyrier-occitanie",
"it/it/notizia/michelin-guide-ceremony/lo-young-chef-award-incorona-le-brillanti-prospettive-di-mattia-pecis-giovane-stella-di-cracco-portofino",
"us/en/article/michelin-guide-ceremony/rene-andrade-bacanora-huarachis-phoenix-young-chef-award-michelin-guide",
"es/es/articulo/michelin-guide-ceremony/juan-carlos-garcia-premio-michelin-al-joven-chef-2026"],
"r":[
[1,"C",2026,"mississippi/oxford_2919729/restaurant/miscellanea-spirit-house","","Allison Bowen",0],
[2,"C",2026,"glasgow-city/glasgow/restaurant/sebb-s","","Alasdair Shaw",1],
[3,"G",2026,"us/en/tokyo-region/tokyo/restaurant/crony-1194937","","",-1],
[4,"G",2026,"us/en/nara-region/nara/restaurant/da-terra-1197086","","",-1],
[5,"G",2026,"us/en/tokyo-region/tokyo/restaurant/daigo","","",-1],
[6,"G",2026,"us/en/tokyo-region/tokyo/restaurant/den","","",-1],
[7,"G",2026,"us/en/tokyo-region/tokyo/restaurant/faro-1194154","","",-1],
[8,"G",2026,"us/en/tokyo-region/tokyo/restaurant/florilege","","",-1],
[9,"G",2026,"us/en/kyoto-region/kyoto/restaurant/juu-go","","",-1],
[10,"G",2026,"us/en/tokyo-region/tokyo/restaurant/l-effervescence","","",-1],
[11,"G",2026,"us/en/tokyo-region/tokyo/restaurant/lature","","",-1],
[12,"G",2026,"us/en/tokyo-region/tokyo/restaurant/la-paix-1194221","","",-1],
[13,"G",2026,"us/en/kyoto-region/kyoto/restaurant/muromachi-wakuden","","",-1],
[14,"G",2026,"us/en/tokyo-region/tokyo/restaurant/narisawa","","",-1],
[15,"G",2026,"us/en/nara-region/nara/restaurant/naramachi-kuko","","",-1],
[16,"G",2026,"us/en/kyoto-region/kyoto/restaurant/shigetsu","","",-1],
[17,"G",2026,"us/en/tokyo-region/tokyo/restaurant/sincere","","",-1],
[18,"G",2026,"us/en/kyoto-region/kyoto/restaurant/sojiki-nakahigashi","","",-1],
[19,"G",2026,"us/en/nara-region/nara/restaurant/sen-1218506","","",-1],
[20,"G",2026,"us/en/kyoto-region/kyoto/restaurant/tan","","",-1],
[21,"G",2026,"us/en/osaka-region/osaka/restaurant/terada","","",-1],
[22,"G",2026,"us/en/kyoto-region/kyoto/restaurant/la-buche","","",-1],
[23,"G",2026,"us/en/tokyo-region/tokyo/restaurant/nol","","",-1],
[24,"G",2026,"beijing-municipality/beijing/restaurant/king-s-joy","","",2],
[25,"G",2027,"chengdu-municipality/chengdu/restaurant/mi-xun-teahouse","","",3],
[26,"G",2026,"grand-est/langres/restaurant/bulle-d-osier","","",4],
[27,"G",2026,"bourgogne-franche-comte/dijon/restaurant/cibo","","",4],
[28,"G",2026,"provence-alpes-cote-dazur/flassans-sur-issole_1505557/restaurant/chez-jeannette","","",4],
[29,"G",2026,"ile-de-france/paris/restaurant/datil","","",4],
[30,"G",2026,"","ve_3e461fe576","",4],
[31,"G",2026,"nouvelle-aquitaine/saint-denis-d-olron/restaurant/le-jour-du-poisson","","",4],
[32,"G",2026,"auvergne-rhone-alpes/saint-theoffrey_1515526/restaurant/maltacina","","",4],
[33,"G",2026,"auvergne-rhone-alpes/alixan_1509150/restaurant/mandibule","","",4],
[34,"G",2026,"auvergne-rhone-alpes/le-broc/restaurant/origines","","",4],
[35,"G",2026,"nouvelle-aquitaine/bordeaux/restaurant/ressources","","",4],
[36,"G",2026,"bretagne/plourhan_1568608/restaurant/rolland","","",4],
[37,"G",2026,"highland/torridon/restaurant/1887","","",5],
[38,"G",2026,"","ve_16395a9c38","",5],
[39,"G",2026,"north-yorkshire/oldstead/restaurant/black-swan","","",5],
[40,"G",2026,"","ve_60f0332fb7","",5],
[41,"G",2026,"cumbria/grasmere/restaurant/forest-side","","",5],
[42,"G",2026,"north-yorkshire/middleton-tyas/restaurant/forge-1190154","","",5],
[43,"G",2026,"west-sussex/lower-beeding/restaurant/interlude","","",5],
[44,"G",2026,"","ve_6875e82e76","",5],
[45,"G",2026,"","ve_21f3f34844","",5],
[46,"G",2026,"cumbria/cartmel/restaurant/l-enclume","","",5],
[47,"G",2026,"lancashire/aughton/restaurant/moor-hall","","",5],
[48,"G",2026,"somerset/bruton/restaurant/osip","","",5],
[49,"G",2026,"northumberland/east-wallhouses/restaurant/pine","","",5],
[50,"G",2026,"wiltshire/tisbury/restaurant/pythouse-kitchen-garden","","",5],
[51,"G",2026,"nottingham-region/nottingham/restaurant/restaurant-sat-bains","","",5],
[52,"G",2026,"greater-london/london/restaurant/st-barts","","",5],
[53,"G",2026,"monmouthshire/whitebrook/restaurant/the-whitebrook","","",5],
[54,"G",2026,"city-of-edinburgh/edinburgh/restaurant/timberyard","","",5],
[55,"G",2026,"","ve_15b2f1594e","",5],
[56,"G",2026,"south-gloucestershire/bristol/restaurant/wilsons","","",5],
[57,"G",2026,"emilia-romagna/rubbianino/restaurant/ca-matilde","","",6],
[58,"G",2026,"umbria/capodacqua/restaurant/une","","",6],
[59,"G",2026,"osaka-region/osaka/restaurant/kashiwaya-osaka-senriyama","","",7],
[60,"G",2026,"kyoto-region/kyoto/restaurant/kodaiji-wakuden","","",7],
[61,"G",2026,"kyoto-region/kyoto/restaurant/miyamaso","","",7],
[62,"G",2026,"pais-vasco/santa-cruz-de-campezo/restaurant/arrea","","",8],
[63,"G",2026,"pais-vasco/tolosa/restaurant/ama","","",8],
[64,"G",2026,"castilla-y-leon/penafiel/restaurant/ambivium","","",8],
[65,"G",2026,"islas-baleares/llucmajor/restaurant/andreu-genestra-1208507","","",8],
[66,"G",2026,"andalucia/el-puerto-de-santa-maria/restaurant/aponiente","","",8],
[67,"G",2026,"pais-vasco/larrabetzu/restaurant/azurmendi","","",8],
[68,"G",2026,"pais-vasco/mungia_1403141/restaurant/bakea","","",8],
[69,"G",2026,"castilla-y-leon/avila/restaurant/barro","","",8],
[70,"G",2026,"catalunya/castello-d-empuries/restaurant/bistrot-1965","","",8],
[71,"G",2026,"catalunya/ulldecona/restaurant/espacio-amunt","","",8],
[72,"G",2026,"comunidad-valenciana/vall-d-alba/restaurant/cal-paradis","","",8],
[73,"G",2026,"principado-de-asturias/arriondas/restaurant/casa-marcial","","",8],
[74,"G",2026,"catalunya/sant-marti-sarroca/restaurant/casa-nova","","",8],
[75,"G",2026,"cantabria/santander/restaurant/casona-del-judio","","",8],
[76,"G",2026,"cantabria/villaverde-de-pontones/restaurant/cenador-de-amos","","",8],
[77,"G",2026,"catalunya/barcelona/restaurant/cocina-hermanos-torres","","",8],
[78,"G",2026,"comunidad-de-madrid/madrid/restaurant/coque","","",8],
[79,"G",2026,"galicia/o-grove/restaurant/culler-de-pau","","",8],
[80,"G",2026,"comunidad-de-madrid/madrid/restaurant/dstage","","",8],
[81,"G",2026,"catalunya/girona/restaurant/el-celler-de-can-roca","","",8],
[82,"G",2026,"comunidad-de-madrid/madrid/restaurant/el-invernadero","","",8],
[83,"G",2026,"castilla-la-mancha/siguenza/restaurant/el-molino-de-alcuneza","","",8],
[84,"G",2026,"catalunya/sagas/restaurant/els-casals","","",8],
[85,"G",2026,"catalunya/castello-d-empuries/restaurant/emporium","","",8],
[86,"G",2026,"pais-vasco/larrabetzu/restaurant/eneko","","",8],
[87,"G",2026,"andalucia/aljaraque/restaurant/finca-alfoliz","","",8],
[88,"G",2026,"pais-vasco/dima/restaurant/garena","","",8],
[89,"G",2026,"catalunya/amposta/restaurant/l-algadir","","",8],
[90,"G",2026,"catalunya/ulldecona/restaurant/l-antic-moli","","",8],
[91,"G",2026,"catalunya/bellvis/restaurant/la-boscana","","",8],
[92,"G",2026,"castilla-y-leon/matapozuelos/restaurant/la-botica","","",8],
[93,"G",2026,"castilla-y-leon/castroverde-de-campos/restaurant/lera","","",8],
[94,"G",2026,"catalunya/olot/restaurant/les-cols","","",8],
[95,"G",2026,"catalunya/ulldecona/restaurant/les-moles","","",8],
[96,"G",2026,"catalunya/santa-coloma-de-gramenet/restaurant/lluerna","","",8],
[97,"G",2026,"islas-baleares/port-d-alcdia/restaurant/maca-de-castro","","",8],
[98,"G",2026,"comunidad-foral-de-navarra/lekunberri/restaurant/maskarada","","",8],
[99,"G",2026,"comunidad-foral-de-navarra/urdaitz/restaurant/el-molino-de-urdaniz","","",8],
[100,"G",2026,"principado-de-asturias/san-feliz/restaurant/monte-1190765","","",8],
[101,"G",2026,"canarias/las-palmas-de-gran-canaria/restaurant/muxgo","","",8],
[102,"G",2026,"castilla-la-mancha/casas-ibanez/restaurant/oba","","",8],
[103,"G",2026,"galicia/raxo-(san-gregorio)_1412090/restaurant/pepe-vieira","","",8],
[104,"G",2026,"castilla-y-leon/sardon-de-duero/restaurant/refectorio","","",8],
[105,"G",2026,"comunidad-valenciana/valencia/restaurant/ricard-camarena","","",8],
[106,"G",2026,"andalucia/fuengirola/restaurant/sollo","","",8],
[107,"G",2026,"catalunya/igualada/restaurant/somiatruites","","",8],
[108,"G",2026,"castilla-y-leon/quintanilla-de-onesimo/restaurant/taller","","",8],
[109,"G",2026,"la-rioja/daroca-de-rioja/restaurant/venta-moncalvillo","","",8],
[110,"G",2026,"taipei-region/taipei/restaurant/hosu","","",9],
[111,"G",2026,"taipei-region/taipei/restaurant/little-tree-food-da-an-road","","",9],
[112,"G",2026,"taipei-region/taipei/restaurant/mountain-and-sea-house","","",9],
[113,"G",2026,"taichung-region/taichung/restaurant/sur","","",9],
[114,"G",2026,"tainan-region/tainan/restaurant/yu-dao","","",9],
[115,"G",2026,"tokyo-region/tokyo/restaurant/trois-visages","","",10],
[116,"T",2026,"beijing-municipality/beijing/restaurant/chao-shang-chao","","Yat Fung CHEUNG",2],
[117,"T",2027,"chengdu-municipality/chengdu/restaurant/yu-zhi-lan-1196150","","Guijun LAN",3],
[118,"T",2026,"ile-de-france/paris/restaurant/pierre-gagnaire6112","","Pierre Gagnaire",11],
[119,"T",2026,"fujian-province/xiamen_1031934/restaurant/yanyu-jiahe-road","","WU Rong",12],
[120,"T",2026,"guangdong-province/guangzhou/restaurant/jiang-by-chef-fei","","Jinghui HUANG",13],
[121,"T",2026,"lazio/roma/restaurant/la-pergola69016","","Heinz Beck",14],
[122,"T",2026,"osaka-region/osaka/restaurant/kashiwaya-osaka-senriyama","","Hideaki Matsuo",7],
[123,"T",2026,"zhe-jiang/hangzhou_1027184/restaurant/jie-xiang-lou","","Bin Yu",15],
[124,"T",2026,"comunidad-valenciana/dnia/restaurant/quique-dacosta","","Quique Dacosta",16],
[125,"T",2026,"tokyo-region/tokyo/restaurant/nodaiwa-azabu-iikura-honten-1194124","","Kenjiro Kanemoto",10],
[126,"M",2026,"us/en/hamburg-region/hamburg/restaurant/100-200","","Thomas Alfons Imbusch",-1],
[127,"M",2026,"us/en/bayern/mnchen/restaurant/1804-hirschau","","Lukas Adebahr",-1],
[128,"M",2026,"us/en/pais-vasco/santa-cruz-de-campezo/restaurant/arrea","","Edorta Lamo Garc\u00eda de Arbizu",-1],
[129,"M",2026,"us/en/bayern/wirsberg/restaurant/alexander-herrmann-by-tobias-batz","","Alexander Herrmann Tobias B\u00e4tz",-1],
[130,"M",2026,"us/en/trentino-alto-adige/moena/restaurant/agritur-el-mas","","Stefano Croce",-1],
[131,"M",2026,"us/en/emilia-romagna/bologna/restaurant/ahime","","Lorenzo Vecchia",-1],
[132,"M",2026,"us/en/emilia-romagna/modena/restaurant/al-gatto-verde","","Jessica Rosval",-1],
[133,"M",2026,"en/grand-est/kaysersberg/restaurant/l-alchemille","","J\u00e9r\u00f4me Jaegle",-1],
[134,"M",2026,"us/en/mecklenburg-vorpommern/feldberger-seenlandschaft/restaurant/alte-schule-klassenzimmer","","Daniel Schmidthaler",-1],
[135,"M",2026,"us/en/brandenburg/werder/restaurant/alte-uberfahrt","","Thomas H\u00fcbner",-1],
[136,"M",2026,"us/en/pais-vasco/tolosa/restaurant/ama","","Gorka Rico Javier Rivero",-1],
[137,"M",2026,"us/en/castilla-y-leon/penafiel/restaurant/ambivium","","Crist\u00f3bal Mu\u00f1oz Ortega",-1],
[138,"M",2026,"us/en/islas-baleares/llucmajor/restaurant/andreu-genestra-1208507","","Andreu Genestra Garcia",-1],
[139,"M",2026,"en/ile-de-france/paris/restaurant/anona","","Thibaut Spiwack",-1],
[140,"M",2026,"us/en/andalucia/el-puerto-de-santa-maria/restaurant/aponiente","","\u00c1ngel Le\u00f3n Gonz\u00e1lez",-1],
[141,"M",2026,"en/bretagne/nevez/restaurant/ar-men-du","","J\u00e9r\u00f4me Gourmelen",-1],
[142,"M",2026,"us/en/hamburg-region/hamburg/restaurant/arc-restaurant","","Joshua Feldkircher, Julian Rickert, Franz Kirsch",-1],
[143,"M",2026,"en/ile-de-france/paris/restaurant/arpege","","Alain Passard",-1],
[144,"M",2026,"en/nouvelle-aquitaine/irissarry/restaurant/art-zain","","Henri Amestoy",-1],
[145,"M",2026,"en/centre-val-de-loire/blois/restaurant/assa","","Anthony Maubert Fumiko Maubert",-1],
[146,"M",2026,"us/en/trentino-alto-adige/brunico/restaurant/atelier-moessmer-norbert-niederkofler","","Norbert Niederkofler Mauro Siega",-1],
[147,"M",2026,"en/auvergne-rhone-alpes/le-bourget-du-lac/restaurant/atmospheres","","Alain Perrillat-Mercerot",-1],
[148,"M",2026,"en/grand-est/rhinau/restaurant/au-vieux-couvent","","Alexis Albrecht",-1],
[149,"M",2026,"en/grand-est/la-vancelle/restaurant/auberge-frankenbourg","","S\u00e9bastien Buecher",-1],
[150,"M",2026,"en/normandie/servon/restaurant/auberge-sauvage","","Thomas Benady",-1],
[151,"M",2026,"en/hauts-de-france/boeschepe/restaurant/auberge-du-vert-mont","","Florent Ladeyn",-1],
[152,"M",2026,"us/en/bayern/neubeuern/restaurant/auers-schlosswirtschaft","","Astrid Hilse",-1],
[153,"M",2026,"en/bourgogne-franche-comte/tournus/restaurant/aux-terrasses","","Jean-Michel Carrette",-1],
[154,"M",2026,"us/en/pais-vasco/larrabetzu/restaurant/azurmendi","","Eneko Atxa Azurmendi",-1],
[155,"M",2026,"us/en/georgia/atlanta_2884144/restaurant/bacchanalia-1196004","","Anne Quatrano",-1],
[156,"M",2026,"us/en/pais-vasco/mungia_1403141/restaurant/bakea","","Alatz Bilbao Ter\u00e1n",-1],
[157,"M",2026,"us/en/berlin-region/berlin/restaurant/bandol-sur-mer","","Andreas Saul",-1],
[158,"M",2026,"us/en/castilla-y-leon/avila/restaurant/barro","","Carlos Casillas Hern\u00e1ndez",-1],
[159,"M",2026,"en/ile-de-france/paris/restaurant/bellefeuille-saint-james-paris","","Gr\u00e9gory Garimbay",-1],
[160,"M",2026,"us/en/noord-holland/den-hoorn/restaurant/bij-jef","","Jef Schuur",-1],
[161,"M",2026,"us/en/toscana/forte-dei-marmi/restaurant/bistrot","","Andrea Mattei",-1],
[162,"M",2026,"us/en/catalunya/castello-d-empuries/restaurant/bistrot-1965","","Joan Jord\u00e0 i Gir\u00f3 M\u00e0rius Jord\u00e0 i Gir\u00f3",-1],
[163,"M",2026,"us/en/catalunya/ulldecona/restaurant/espacio-amunt","","Vicent Guimer\u00e0 Sales",-1],
[164,"M",2026,"us/en/thuringen/dermbach/restaurant/bjornsox","","Bj\u00f6rn Leist",-1],
[165,"M",2026,"us/en/noord-holland/amsterdam/restaurant/bolenius","","Luc Kusters",-1],
[166,"M",2026,"us/en/berlin-region/berlin/restaurant/bonvivant-1197308","","Nikodemus Berger",-1],
[167,"M",2026,"us/en/hessen/frankfurt-am-main/restaurant/bornheimer-ratskeller","","Mario Furlanello",-1],
[168,"M",2026,"us/en/colorado/denver_1261491/restaurant/bruto","","Kelly Whitaker",-1],
[169,"M",2026,"en/grand-est/langres/restaurant/bulle-d-osier","","Valentin Loison",-1],
[170,"M",2026,"en/bourgogne-franche-comte/dijon/restaurant/cibo","","Angelo Ferrigno",-1],
[171,"M",2026,"us/en/emilia-romagna/rubbianino/restaurant/ca-matilde","","Andrea Incerti Vezzani",-1],
[172,"M",2026,"us/en/lombardia/isola-dovarese/restaurant/caffe-la-crepa","","Federico Malinverno",-1],
[173,"M",2026,"us/en/comunidad-valenciana/vall-d-alba/restaurant/cal-paradis","","Miguel Barrera Barrachina",-1],
[174,"M",2026,"us/en/principado-de-asturias/arriondas/restaurant/casa-marcial","","Nacho Manzano S\u00e1nchez Esther Manzano S\u00e1nchez",-1],
[175,"M",2026,"us/en/catalunya/sant-marti-sarroca/restaurant/casa-nova","","Andr\u00e9s Torres Argudo",-1],
[176,"M",2026,"us/en/puglia/manduria/restaurant/casamatta","","Pietro Penna",-1],
[177,"M",2026,"us/en/cantabria/santander/restaurant/casona-del-judio","","Sergio Bastard",-1],
[178,"M",2026,"us/en/cantabria/villaverde-de-pontones/restaurant/cenador-de-amos","","Jes\u00fas S\u00e1nchez S\u00e1inz",-1],
[179,"M",2026,"en/provence-alpes-cote-dazur/flassans-sur-issole_1505557/restaurant/chez-jeannette","","Benjamin Le Balch",-1],
[180,"M",2026,"en/nouvelle-aquitaine/espelette/restaurant/choko-ona","","Cl\u00e9ment Guillemot",-1],
[181,"M",2026,"en/centre-val-de-loire/blois/restaurant/christophe-hay-fleur-de-loire","","Christophe Hay",-1],
[182,"M",2026,"en/nouvelle-aquitaine/la-rochelle/restaurant/christopher-coutanceau","","Christopher Coutanceau",-1],
[183,"M",2026,"us/en/catalunya/barcelona/restaurant/cocina-hermanos-torres","","Javier Torres Mart\u00ednez Sergio Torres Mart\u00ednez",-1],
[184,"M",2026,"us/en/lombardia/oltressenda-alta/restaurant/contrada-bricconi","","Michele Lazzarini",-1],
[185,"M",2026,"us/en/comunidad-de-madrid/madrid/restaurant/coque","","Mario Sandoval",-1],
[186,"M",2026,"us/en/galicia/o-grove/restaurant/culler-de-pau","","Javier Olleros Rodr\u00edguez",-1],
[187,"M",2026,"en/occitanie/aumont-aubrac/restaurant/cyril-attrazic","","Cyril Attrazic",-1],
[188,"M",2026,"us/en/lombardia/cornaredo/restaurant/d-o","","Davide Oldani Alessandro Procopio",-1],
[189,"M",2026,"us/en/abruzzo/montepagano/restaurant/d-one-restaurant-diffuso","","Davide Pezzuto",-1],
[190,"M",2026,"us/en/comunidad-de-madrid/madrid/restaurant/dstage","","Diego Guerrero",-1],
[191,"M",2026,"us/en/texas/austin_2958315/restaurant/dai-due","","Jesse Griffiths",-1],
[192,"M",2026,"us/en/lombardia/runate/restaurant/dal-pescatore","","Nadia Santini Giovanni Santini",-1],
[193,"M",2026,"us/en/marche/gabicce-monte/restaurant/dalla-gioconda","","Davide Di Fabio",-1],
[194,"M",2026,"us/en/schleswig-holstein/flensburg/restaurant/das-grace","","Quirin Brundobler",-1],
[195,"M",2026,"en/ile-de-france/paris/restaurant/datil","","Manon Fleury Laur\u00e8ne Barjhoux",-1],
[196,"M",2026,"us/en/calabria/strongoli/restaurant/dattilo","","Caterina Ceraudo",-1],
[197,"M",2026,"us/en/overijssel/zwolle/restaurant/de-librije","","Nelson Tanate",-1],
[198,"M",2026,"us/en/gelderland/nijmegen/restaurant/de-nieuwe-winkel","","Emile van der Staak",-1],
[199,"M",2026,"us/en/campania/sant--agata-sui-due-golfi/restaurant/don-alfonso-1890-151521","","Ernesto Iaccarino",-1],
[200,"M",2026,"us/en/catalunya/girona/restaurant/el-celler-de-can-roca","","Joan Roca i Fontan\u00e9",-1],
[201,"M",2026,"us/en/comunidad-de-madrid/madrid/restaurant/el-invernadero","","Rodrigo de la Calle",-1],
[202,"M",2026,"us/en/trentino-alto-adige/cavalese/restaurant/el-molin","","Alessandro Gilmozzi",-1],
[203,"M",2026,"us/en/castilla-la-mancha/siguenza/restaurant/el-molino-de-alcuneza","","Samuel Moreno",-1],
[204,"M",2026,"us/en/catalunya/sagas/restaurant/els-casals","","Oriol Rovira Prat",-1],
[205,"M",2026,"us/en/texas/austin_2958315/restaurant/emmer-rye","","Kevin Fink",-1],
[206,"M",2026,"us/en/catalunya/castello-d-empuries/restaurant/emporium","","Joan Jord\u00e0 i Gir\u00f3 M\u00e0rius Jord\u00e0 i Gir\u00f3",-1],
[207,"M",2026,"en/occitanie/quint-fonsegrives/restaurant/en-pleine-nature","","Sylvain Joffre",-1],
[208,"M",2026,"us/en/pais-vasco/larrabetzu/restaurant/eneko","","Eneko Atxa Azurmendi",-1],
[209,"M",2026,"us/en/bayern/nurnberg/restaurant/essigbratlein","","Andree K\u00f6the Yves Ollech",-1],
[210,"M",2026,"en/ile-de-france/paris/restaurant/fief","","Victor Mercier",-1],
[211,"M",2026,"us/en/andalucia/aljaraque/restaurant/finca-alfoliz","","Xanty El\u00edas Fern\u00e1ndez V\u00e1zquez",-1],
[212,"M",2026,"us/en/noord-holland/amsterdam/restaurant/flore","","Bas van Kranen",-1],
[213,"M",2026,"us/en/arizona/scottsdale_2875755/restaurant/fnb","","Charleen Badman",-1],
[214,"M",2026,"us/en/cumbria/grasmere/restaurant/forest-side","","Paul Leonard",-1],
[215,"M",2026,"us/en/sardegna/pula/restaurant/fradis-minoris","","Francesco Stara",-1],
[216,"M",2026,"en/auvergne-rhone-alpes/vailly/restaurant/frederic-molina-a-foret-ivre","","Fr\u00e9d\u00e9ric Molina",-1],
[217,"M",2026,"us/en/bayern/frstenfeldbruck/restaurant/furstenfelder","","Andreas Wagner Christian Ottwaska",-1],
[218,"M",2026,"en/normandie/rives-en-seine_7770403/restaurant/g-a-au-manoir-de-retival","","David Goerne",-1],
[219,"M",2026,"us/en/hamburg-region/hamburg/restaurant/glorie","","Thomas Alfons Imbusch",-1],
[220,"M",2026,"us/en/pais-vasco/dima/restaurant/garena","","Julen Baz",-1],
[221,"M",2026,"us/en/bayern/friedberg/restaurant/gasthaus-goldener-stern","","Stefan Fu\u00df",-1],
[222,"M",2026,"us/en/baden-wurttemberg/sthlingen/restaurant/gasthaus-schwanen77903","","Markus Wekerle",-1],
[223,"M",2026,"us/en/bayern/spalt/restaurant/gasthof-blumenthal","","Elias Pirner Josef Kocher",-1],
[224,"M",2026,"us/en/lombardia/albiate/restaurant/grow-restaurant","","Matteo Vergine",-1],
[225,"M",2026,"us/en/bayern/kirchlauter/restaurant/gutshof-andres","","Bernd Andres",-1],
[226,"M",2026,"us/en/schleswig-holstein/tangstedt/restaurant/gutskuche","","Matthias Gfr\u00f6rer",-1],
[227,"M",2026,"us/en/baden-wurttemberg/freiburg-im-breisgau/restaurant/hawara","","Yannik Spielmann Nicolai Heuer",-1],
[228,"M",2026,"us/en/hamburg-region/hamburg/restaurant/heimatjuwel","","Marcel G\u00f6rke",-1],
[229,"M",2026,"us/en/groningen/aduard/restaurant/herberg-onder-de-linden","","Steven Klein Nijenhuis",-1],
[230,"M",2026,"us/en/baden-wurttemberg/ellwangen-(jagst)_1313960/restaurant/hirsch-1207191","","Dennis Wiche",-1],
[231,"M",2026,"us/en/lombardia/milano/restaurant/horto-1204821","","Alessandro Pinton",-1],
[232,"M",2026,"us/en/berlin-region/berlin/restaurant/horvath","","Sebastian Frank",-1],
[233,"M",2026,"us/en/calabria/san-giovanni-in-fiore/restaurant/hyle","","Antonio Biafora",-1],
[234,"M",2026,"us/en/sicilia/isola-vulcano/restaurant/i-tenerumi","","Davide Guidara",-1],
[235,"M",2026,"us/en/lombardia/madesimo/restaurant/il-cantinone-e-sport-hotel-alpina","","Stefano Masanti",-1],
[236,"M",2026,"us/en/sicilia/isola-vulcano/restaurant/il-cappero","","Domenico Perna",-1],
[237,"M",2026,"us/en/emilia-romagna/pennabilli/restaurant/il-piastrino","","Riccardo Agostini",-1],
[238,"M",2026,"us/en/marche/montemonaco/restaurant/il-tiglio","","Enrico Mazzaroni",-1],
[239,"M",2026,"en/bretagne/rennes/restaurant/ima","","Julien Lemari\u00e9",-1],
[240,"M",2026,"us/en/texas/san-antonio_2958156/restaurant/isidore","","Ian Lanphear",-1],
[241,"M",2026,"us/en/baden-wurttemberg/freiburg-im-breisgau/restaurant/jacobi","","Christoph Kaiser",-1],
[242,"M",2026,"en/auvergne-rhone-alpes/talloires-montmin/restaurant/jean-sulpice","","Jean Sulpice",-1],
[243,"M",2026,"us/en/lombardia/milano/restaurant/joia","","Sauro Ricci Raffaele Minghini",-1],
[244,"M",2026,"us/en/bayern/ubersee_1280400/restaurant/june-1213481","","Rico Birndt",-1],
[245,"M",2026,"us/en/bayern/bad-tlz/restaurant/jagerwirt","","Martin Rank",-1],
[246,"M",2026,"us/en/beijing-municipality/beijing/restaurant/king-s-joy","","Gary Yin",-1],
[247,"M",2026,"us/en/catalunya/amposta/restaurant/l-algadir","","Joan Capilla Pepiol",-1],
[248,"M",2026,"us/en/catalunya/ulldecona/restaurant/l-antic-moli","","Vicent Guimer\u00e0 Sales",-1],
[249,"M",2026,"en/auvergne-rhone-alpes/talloires-montmin/restaurant/l-auberge-de-montmin","","Florian Favario",-1],
[250,"M",2026,"en/provence-alpes-cote-dazur/gigondas/restaurant/l-oustalet","","Thomas Boirel",-1],
[251,"M",2026,"en/provence-alpes-cote-dazur/les-baux-de-provence/restaurant/l-oustau-de-baumaniere","","Glenn Viel",-1],
[252,"M",2026,"us/en/namur/liernu/restaurant/l-air-du-temps371956","","Sang Hoon Degeimbre",-1],
[253,"M",2026,"us/en/abruzzo/civitella-casanova/restaurant/la-bandiera","","Marcello Spadone Mattia Spadone",-1],
[254,"M",2026,"en/provence-alpes-cote-dazur/moustiers-sainte-marie/restaurant/la-bastide-de-moustiers","","Valentin Fuchs",-1],
[255,"M",2026,"us/en/catalunya/bellvis/restaurant/la-boscana","","Joel Casta\u00f1\u00e9 Daniel",-1],
[256,"M",2026,"us/en/castilla-y-leon/matapozuelos/restaurant/la-botica","","Miguel \u00c1ngel de la Cruz Garc\u00eda",-1],
[257,"M",2026,"en/auvergne-rhone-alpes/veyras/restaurant/la-boria-1200901","","Florian Descours",-1],
[258,"M",2026,"en/provence-alpes-cote-dazur/arles/restaurant/la-chassagnette","","Armand Arnal",-1],
[259,"M",2026,"en/hauts-de-france/bermicourt/restaurant/la-cour-de-remi","","S\u00e9bastien de La Borde",-1],
[260,"M",2026,"en/bourgogne-franche-comte/joigny/restaurant/la-cote-saint-jacques","","Alexandre Bondoux Jean-Michel Lorain",-1],
[261,"M",2026,"en/occitanie/perpignan/restaurant/la-galinette","","Christophe Comes",-1],
[262,"M",2026,"us/en/be-luxembourg/arlon/restaurant/la-grappe-d-or-1203424","","Cl\u00e9ment Petitjean",-1],
[263,"M",2026,"en/hauts-de-france/la-madelaine-sous-montreuil/restaurant/la-grenouillere","","Alexandre Gauthier",-1],
[264,"M",2026,"en/pays-de-la-loire/l-herbaudire/restaurant/la-marine3780","","Alexandre Couillon",-1],
[265,"M",2026,"us/en/veneto/lonigo/restaurant/la-peca","","Nicola Portinari",-1],
[266,"M",2026,"us/en/lombardia/mantello/restaurant/la-presef","","Gianni Tarabini",-1],
[267,"M",2026,"en/centre-val-de-loire/ardon/restaurant/la-table-christophe-hay","","Christophe Hay",-1],
[268,"M",2026,"en/bourgogne-franche-comte/gevrey-chambertin/restaurant/la-table-dhotes-la-rotisserie-du-chambertin","","Thomas Collomb",-1],
[269,"M",2026,"en/hauts-de-france/busnes/restaurant/la-table-de-christophe-dufoss\u00e9","","Christophe Dufoss\u00e9",-1],
[270,"M",2026,"en/bretagne/plouider/restaurant/la-table-de-la-butte","","Nicolas Conraux",-1],
[271,"M",2026,"en/auvergne-rhone-alpes/veyrier-du-lac/restaurant/la-table-de-yoann-conte","","Yoann Conte",-1],
[272,"M",2026,"en/grand-est/riquewihr/restaurant/la-table-du-gourmet","","Jean-Luc Brendel",-1],
[273,"M",2026,"us/en/veneto/asiago/restaurant/la-tana-gourmet","","Alessandro Dal Degan",-1],
[274,"M",2026,"en/pays-de-la-loire/angers/restaurant/lait-thym-sel","","Ga\u00ebtan Morvan Fanny Morvan",-1],
[275,"M",2026,"us/en/beijing-municipality/beijing/restaurant/lamdre","","Jun Dai",-1],
[276,"M",2026,"us/en/hessen/freiensteinau/restaurant/landgasthof-zur-post","","Sebastian Heil Katharina Koros",-1],
[277,"M",2026,"us/en/hamburg-region/hamburg/restaurant/landhaus-scherrer","","Heinz Otto Wehmann",-1],
[278,"M",2026,"us/en/bayern/waging-am-see/restaurant/landhaus-tanner","","Franz Tanner",-1],
[279,"M",2026,"us/en/bayern/adelshofen/restaurant/zum-falken","","Lars Zwick",-1],
[280,"M",2026,"us/en/lombardia/villa-di-chiavenna/restaurant/lanterna-verde","","Roberto Tonola",-1],
[281,"M",2026,"en/auvergne-rhone-alpes/grignan/restaurant/le-clair-de-la-plume","","Benjamin Reilhes",-1],
[282,"M",2026,"en/auvergne-rhone-alpes/annecy/restaurant/le-clos-des-sens","","Franck Derouet",-1],
[283,"M",2026,"en/bretagne/saint-mloir-des-ondes/restaurant/le-coquillage","","Hugo Roellinger",-1],
[284,"M",2026,"en/provence-alpes-cote-dazur/cadenet/restaurant/le-gout-du-bonheur-la-feniere","","Nadia Sammut",-1],
[285,"M",2026,"en/provence-alpes-cote-dazur/flayosc/restaurant/le-jardin-de-berne","","Louis Rameau",-1],
[286,"M",2026,"en/nouvelle-aquitaine/saint-denis-d-olron/restaurant/le-jour-du-poisson","","Th\u00e9o Fran\u00e7ois",-1],
[287,"M",2026,"en/pays-de-la-loire/nantes/restaurant/manoir-de-la-regate","","Mathieu P\u00e9rou",-1],
[288,"M",2026,"en/nouvelle-aquitaine/lormont/restaurant/le-prince-noir-vivien-durand","","Vivien Durand",-1],
[289,"M",2026,"en/occitanie/saint-hilaire-de-brethmas_3915683/restaurant/le-saint-hilaire-1208787","","S\u00e9bastien Rath",-1],
[290,"M",2026,"us/en/campania/paestum/restaurant/le-trabe","","Marco Rispo",-1],
[291,"M",2026,"us/en/castilla-y-leon/castroverde-de-campos/restaurant/lera","","Luis Alberto Lera Collantes",-1],
[292,"M",2026,"us/en/trentino-alto-adige/san-lorenzo-di-sebato/restaurant/lerchner-s-in-runggen","","Johann Lerchner",-1],
[293,"M",2026,"en/nouvelle-aquitaine/saint-milion/restaurant/les-belles-perdrix-de-troplong-mondot","","David Charrier",-1],
[294,"M",2026,"us/en/catalunya/olot/restaurant/les-cols","","Fina Puigdevall Nogareda Martina Puigvert Puigdevall",-1],
[295,"M",2026,"us/en/catalunya/ulldecona/restaurant/les-moles","","Jeroni Castell Vidal",-1],
[296,"M",2026,"en/auvergne-rhone-alpes/les-vans/restaurant/likoke","","Guido Alfredo Ni\u00f1o Torres",-1],
[297,"M",2026,"us/en/catalunya/santa-coloma-de-gramenet/restaurant/lluerna","","V\u00edctor Quintill\u00e0 Imbernon",-1],
[298,"M",2026,"us/en/trentino-alto-adige/san-genesio-atesino/restaurant/antica-locanda-al-cervo-landgasthof-zum-hirschen","","Daniele Alessandro Cavaliere",-1],
[299,"M",2026,"us/en/friuli-venezia-giulia/savogna-d-isonzo/restaurant/lokanda-devetak","","Gabriella Cottali",-1],
[300,"M",2026,"us/en/north-carolina/asheville_2147494/restaurant/luminosa","","Graham House",-1],
[301,"M",2026,"us/en/bayern/pilsach/restaurant/landgasthof-meier","","Domenico Gigliotti",-1],
[302,"M",2026,"us/en/islas-baleares/port-d-alcdia/restaurant/maca-de-castro","","Macarena De Castro Mart\u00edn",-1],
[303,"M",2026,"en/auvergne-rhone-alpes/uriage-les-bains/restaurant/maison-aribert","","Christophe Aribert",-1],
[304,"M",2026,"en/normandie/valmont/restaurant/maison-caillet","","Pierre Caillet",-1],
[305,"M",2026,"en/bretagne/guer/restaurant/maison-tiegezh","","Baptiste Denieul",-1],
[306,"M",2026,"en/auvergne-rhone-alpes/saint-theoffrey_1515526/restaurant/maltacina","","Kevin Mangione, Lunis Cha\u00efb, Th\u00e9o Doumecq",-1],
[307,"M",2026,"en/auvergne-rhone-alpes/alixan_1509150/restaurant/mandibule","","Maxime Szczepaniak",-1],
[308,"M",2026,"us/en/lazio/genazzano/restaurant/aminta-resort","","Marco Bottega",-1],
[309,"M",2026,"us/en/comunidad-foral-de-navarra/lekunberri/restaurant/maskarada","","Jos\u00e9 Ignacio Jauregui",-1],
[310,"M",2026,"en/provence-alpes-cote-dazur/menton/restaurant/mirazur","","Mauro Colagreco",-1],
[311,"M",2026,"us/en/bayern/dietramszell/restaurant/moarwirt","","Sebastian Miller",-1],
[312,"M",2026,"us/en/comunidad-foral-de-navarra/urdaitz/restaurant/el-molino-de-urdaniz","","David Y\u00e1rnoz Mart\u00edn",-1],
[313,"M",2026,"us/en/principado-de-asturias/san-feliz/restaurant/monte-1190765","","Xune Andrade",-1],
[314,"M",2026,"us/en/lancashire/aughton/restaurant/moor-hall","","Mark Birchall",-1],
[315,"M",2026,"us/en/canarias/las-palmas-de-gran-canaria/restaurant/muxgo","","Borja Marrero",-1],
[316,"M",2026,"us/en/nordrhein-westfalen/koln/restaurant/neobiota","","Sonja Baumann Erik Scheffler",-1],
[317,"M",2026,"us/en/texas/austin_2958315/restaurant/nixta-taqueria","","Edgar Rico Sara Mardanbigi",-1],
[318,"M",2026,"us/en/berlin-region/berlin/restaurant/nobelhart-schmutzig","","Micha Sch\u00e4fer Billy Wagner",-1],
[319,"M",2026,"us/en/limburg/roermond/restaurant/one","","Edwin Soumang",-1],
[320,"M",2026,"us/en/campania/vallesaccarda/restaurant/oasis-sapori-antichi","","Michelina Fischetti Serena Falco",-1],
[321,"M",2026,"us/en/castilla-la-mancha/casas-ibanez/restaurant/oba","","Javier Sanz Juan Sahuquillo",-1],
[322,"M",2026,"us/en/baden-wurttemberg/heidelberg/restaurant/oben","","Robert R\u00e4del",-1],
[323,"M",2026,"en/auvergne-rhone-alpes/le-broc/restaurant/origines","","Adrien Descouls",-1],
[324,"M",2026,"us/en/veneto/san-polo-di-piave/restaurant/osteria-enoteca-gambrinus","","Pierchristian Zanotto",-1],
[325,"M",2026,"us/en/emilia-romagna/modena/restaurant/osteria-francescana","","Massimo Bottura",-1],
[326,"M",2026,"us/en/emilia-romagna/rubiera/restaurant/osteria-del-viandante","","Jacopo Malpeli",-1],
[327,"M",2026,"en/auvergne-rhone-alpes/autrans/restaurant/palegrie-chez-l-henri","","Guillaume Monjur\u00e9",-1],
[328,"M",2026,"us/en/galicia/raxo-(san-gregorio)_1412090/restaurant/pepe-vieira","","Xos\u00e9 Torres Cannas",-1],
[329,"M",2026,"us/en/piemonte/alba/restaurant/piazza-duomo","","Enrico Crippa",-1],
[330,"M",2026,"us/en/toscana/castelnuovo-berardenga/restaurant/poggio-rosso","","Stelios Sakalis",-1],
[331,"M",2026,"en/auvergne-rhone-alpes/lyon/restaurant/prairial","","Ga\u00ebtan Gentil",-1],
[332,"M",2026,"us/en/trentino-alto-adige/merano/restaurant/prezioso","","Egon Heiss",-1],
[333,"M",2026,"us/en/baden-wurttemberg/hayingen/restaurant/rose","","Simon Tress",-1],
[334,"M",2026,"us/en/baden-wurttemberg/schriesheim/restaurant/raro-im-muhlenhof","","Tobias Schumacher",-1],
[335,"M",2026,"us/en/castilla-y-leon/sardon-de-duero/restaurant/refectorio","","Marc Segarra Saun\u00e9",-1],
[336,"M",2026,"en/occitanie/montpellier/restaurant/reflet-d-obione","","Laurent Cherchi",-1],
[337,"M",2026,"us/en/niedersachsen/friesoythe_1344188/restaurant/regional-friesoythe","","Timo Plenter",-1],
[338,"M",2026,"en/nouvelle-aquitaine/bordeaux/restaurant/ressources","","Tanguy Laviale",-1],
[339,"M",2026,"us/en/baden-wurttemberg/hayingen/restaurant/restaurant-1950","","Simon Tress",-1],
[340,"M",2026,"us/en/noord-holland/amsterdam/restaurant/de-kas","","Wim de Beer Jos Timmer",-1],
[341,"M",2026,"en/auvergne-rhone-alpes/saint-bonnet-le-froid/restaurant/restaurant-marcon","","R\u00e9gis Marcon, Jacques Marcon, Paul Marcon",-1],
[342,"M",2026,"en/auvergne-rhone-alpes/pouilly-sous-charlieu/restaurant/restaurant-de-la-loire","","Fabien Raux",-1],
[343,"M",2026,"us/en/comunidad-valenciana/valencia/restaurant/ricard-camarena","","Ricard Camarena Ivars",-1],
[344,"M",2026,"en/bretagne/plourhan_1568608/restaurant/rolland","","Pierre Bonnefont",-1],
[345,"M",2026,"us/en/friuli-venezia-giulia/dolegna-del-collio/restaurant/ronchi-ro","","Fares Issa",-1],
[346,"M",2026,"us/en/zuid-holland/rotterdam/restaurant/rotonde","","Jord Coree",-1],
[347,"M",2026,"en/ile-de-france/gambais/restaurant/ruche","","Cyb\u00e8le Idelot",-1],
[348,"M",2026,"us/en/berlin-region/berlin/restaurant/rutz","","Marco M\u00fcller",-1],
[349,"M",2026,"us/en/veneto/cortina-d-ampezzo/restaurant/sanbrite","","Riccardo Gaspari",-1],
[350,"M",2026,"us/en/toscana/chiusdino/restaurant/saporium","","Ariel Hagen Luca Ottogalli",-1],
[351,"M",2026,"us/en/toscana/firenze/restaurant/saporium-firenze","","Ariel Hagen",-1],
[352,"M",2026,"us/en/baden-wurttemberg/kleines-wiesental/restaurant/sennhutte","","Maximilian Grether J\u00fcrgen Grether",-1],
[353,"M",2026,"en/ile-de-france/paris/restaurant/septime","","Th\u00e9ophile Pourriat",-1],
[354,"M",2026,"en/auvergne-rhone-alpes/chaudes-aigues/restaurant/serge-vieira","","Aur\u00e9lien Gransagne",-1],
[355,"M",2026,"us/en/hessen/frankfurt-am-main/restaurant/seven-swans","","Ricky Saward",-1],
[356,"M",2026,"us/en/sicilia/malfa/restaurant/signum","","Martina Caruso",-1],
[357,"M",2026,"us/en/andalucia/fuengirola/restaurant/sollo","","Diego Gallegos de Souza Campos",-1],
[358,"M",2026,"us/en/catalunya/igualada/restaurant/somiatruites","","David Andr\u00e9s Morera",-1],
[359,"M",2026,"us/en/baden-wurttemberg/bonndorf-im-schwarzwald/restaurant/sommerau","","Wolfram Hegar Karen Hegar-Udsching",-1],
[360,"M",2026,"us/en/castilla-y-leon/quintanilla-de-onesimo/restaurant/taller","","Sara Ferreres",-1],
[361,"M",2026,"us/en/trentino-alto-adige/sarentino/restaurant/terra151934","","Heinrich Schneider",-1],
[362,"M",2026,"us/en/colorado/denver_1261491/restaurant/the-wolf-s-tailor","","Kelly Whitaker",-1],
[363,"M",2026,"en/grand-est/obernai/restaurant/thierry-schwartz-table-naturelle","","Thierry Schwartz",-1],
[364,"M",2026,"en/grand-est/faulquemont/restaurant/toya","","Lo\u00efc Villemin",-1],
[365,"M",2026,"us/en/baden-wurttemberg/efringen-kirchen/restaurant/traube1181496","","Brian Wawryk",-1],
[366,"M",2026,"us/en/zuid-holland/wateringen/restaurant/triptyque","","Niven van Bronckhorst-Kunz Virginie van Bronckhorst-Kunz",-1],
[367,"M",2026,"en/auvergne-rhone-alpes/ouches/restaurant/troisgros-le-bois-sans-feuilles","","C\u00e9sar Troisgros",-1],
[368,"M",2026,"us/en/georgia/guy_7770503/restaurant/uberto-restaurant","","Ryan Smith",-1],
[369,"M",2026,"us/en/umbria/capodacqua/restaurant/une","","Giulio Gigli",-1],
[370,"M",2026,"us/en/baden-wurttemberg/knigsbronn/restaurant/ursprung","","Andreas Widmann",-1],
[371,"M",2026,"en/auvergne-rhone-alpes/tignes/restaurant/ursus","","Cl\u00e9ment Bouvier",-1],
[372,"M",2026,"us/en/bayern/nurnberg/restaurant/veles","","Vadim Karasev",-1],
[373,"M",2026,"us/en/veneto/mazzorbo/restaurant/venissa","","Chiara Pavan Francesco Brutto",-1],
[374,"M",2026,"us/en/la-rioja/daroca-de-rioja/restaurant/venta-moncalvillo","","Ignacio Echapresto Garc\u00eda",-1],
[375,"M",2026,"us/en/umbria/norcia/restaurant/vespasia","","Fabio Cappiello",-1],
[376,"M",2026,"us/en/liguria/andora/restaurant/vignamare","","Luca Bertora Claudio Aliperti",-1],
[377,"M",2026,"us/en/abruzzo/guardiagrele/restaurant/villa-maiella","","Arcangelo Tinari",-1],
[378,"M",2026,"en/occitanie/payrin-augmontel/restaurant/villa-pinewood","","Thomas Cabrol",-1],
[379,"M",2026,"us/en/brandenburg/neuzelle_1322193/restaurant/wilde-klosterkuche","","Christian Bauer",-1],
[380,"M",2026,"us/en/guangdong-province/guangzhou/restaurant/yong","","Ricky, Wingkai Li Qilong Luo",-1],
[381,"M",2026,"us/en/nordrhein-westfalen/dusseldorf/restaurant/zwanzig23-by-lukas-jakobi","","Lukas Jakobi",-1],
[382,"M",2026,"en/grand-est/strasbourg/restaurant/de-ja","","Jeanne Satori David Degoursy",-1],
[383,"M",2026,"us/en/baden-wurttemberg/todtnau/restaurant/derwaldfrieden","","Volker Hupfer",-1],
[384,"M",2026,"us/en/bayern/nurnberg/restaurant/etz","","Felix Schneider",-1],
[385,"M",2026,"us/en/liege/liege/restaurant/toma","","Thomas Troupin",-1],
[386,"O",2026,"","ve_d78d5920ac","",17],
[387,"O",2026,"bayern/mnchen/restaurant/the-cloud-by-kafer","","",18],
[388,"O",2026,"kent/sevenoaks_1755352/restaurant/shwen-shwen","","Maria Bradford",1],
[389,"O",2026,"lazio/tivoli/restaurant/al-madrigale","","Gian Marco Bianchi",19],
[390,"O",2026,"tainan-region/tainan/restaurant/yu-dao","","",20],
[391,"S",2026,"beijing-municipality/beijing/restaurant/rong-pao","","Wei WEI",2],
[392,"S",2026,"antwerpen/be-antwerpen/restaurant/t-zilte","","Viviane Plaquet & Gitte Geunes",17],
[393,"S",2027,"chengdu-municipality/chengdu/restaurant/mi-xun-teahouse","","Karen LI",3],
[394,"S",2026,"","ve_8b1e9568c9","Joseph Freyre",21],
[395,"S",2026,"monaco-region/monaco/restaurant/les-ambassadeurs-by-christophe-cussac","","Marco Tognon",22],
[396,"S",2026,"ile-de-france/paris/restaurant/virtus","","Camille Gouyer",22],
[397,"S",2026,"fujian-province/quanzhou_1030272/restaurant/antstory","","Mengqing MAO",12],
[398,"S",2026,"nordrhein-westfalen/aachen/restaurant/sankt-benedikt","","Karin Wei\u00dfer",18],
[399,"S",2026,"cork/kinsale/restaurant/saint-francis-provisions","","Barbara Nealon",1],
[400,"S",2026,"kyoto-region/kyoto/restaurant/kodaiji-wakuden","","Yuko Kuwamura",7],
[401,"S",2026,"limburg/maastricht/restaurant/chateau-neercanne","","",23],
[402,"S",2026,"shanghai-municipality/shanghai/restaurant/bao-li-xuan","","Beryl GUO",15],
[403,"S",2026,"nevada/las-vegas_2935077/restaurant/restaurant-de-joel-robuchon","","Sean Christopher",24],
[404,"S",2026,"comunidad-de-madrid/madrid/restaurant/desde-1911","","Abel Valverde",25],
[405,"S",2026,"taipei-region/taipei/restaurant/circum","","Cindy TSAI",20],
[406,"S",2026,"texas/austin_2958315/restaurant/barley-swine","","Stefan Davis",26],
[407,"S",2026,"tokyo-region/tokyo/restaurant/piao-xiang","","Yasuyo Kumagae",10],
[408,"W",2026,"beijing-municipality/beijing/restaurant/blackswan","","Tyler CHEN",2],
[409,"W",2027,"chengdu-municipality/chengdu/restaurant/focus-by-bill-yue","","Sam LIU",3],
[410,"W",2026,"grand-est/riquewihr/restaurant/la-table-du-gourmet","","Anne Humbrecht",27],
[411,"W",2026,"auvergne-rhone-alpes/valence/restaurant/pic","","Edmond Gasser",27],
[412,"W",2026,"bayern/mnchen/restaurant/tantris-75719","","Noris F. Conrad",18],
[413,"W",2026,"greater-london/london/restaurant/row-on-5","","Roxane Dupuy",1],
[414,"W",2026,"trentino-alto-adige/tirolo/restaurant/castel-fine-dining","","Ivana Capraro",28],
[415,"W",2026,"limburg/reijmerstok/restaurant/brut172","","Matthijs Vranken & Nouri Haj Romdhane",23],
[416,"W",2026,"jiang-su/nanjing_1029511/restaurant/meng-du-hui-1216395","","Mario WANG",15],
[417,"W",2026,"comunidad-de-madrid/madrid/restaurant/smoked-room","","Luis Baselga",29],
[418,"W",2026,"tokyo-region/tokyo/restaurant/manoir","","Tsuyoshi Nakamura",10],
[419,"Y",2026,"north-carolina/charlotte_2987283/restaurant/the-story-of-mi-carino","","H\u00e9ctor Gonz\u00e1lez-Mora",30],
[420,"Y",2026,"vlaams-brabant/heverlee/restaurant/est-1242817","","Abel Demeestere",17],
[421,"Y",2027,"chengdu-municipality/chengdu/restaurant/yongle-restaurant-wuhou","","Sicong YIN",3],
[422,"Y",2026,"occitanie/colomiers/restaurant/maison-pellestor-veyrier","","Quentin Pellestor-Veyrier",31],
[423,"Y",2026,"fujian-province/fuzhou_1026814/restaurant/jiangnan-wok%e2%80%a7rong","","Xupeng MA",12],
[424,"Y",2026,"rheinland-pfalz/saarburg_1332732/restaurant/dopamin","","Axel Boesen",18],
[425,"Y",2026,"saint-helier/saint-helier/restaurant/bohemia","","Tom Earnshaw",1],
[426,"Y",2026,"liguria/portofino/restaurant/cracco-portofino","","Mattia Pecis",32],
[427,"Y",2026,"zeeland/kortgene_2215334/restaurant/rozewied","","No\u00ebmie Haentjens & Ferdy van Rijswijk",23],
[428,"Y",2026,"","ve_55736db86d","Ren\u00e9 Andrade",33],
[429,"Y",2026,"andalucia/baeza/restaurant/vandelvira","","Juan Carlos Garc\u00eda",34],
[430,"Y",2026,"northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an","","Liu An HSU",20]]}';
  leg_txt  text := '[
{"id":7652,"u":"https://guide.michelin.com/hr/en/article/michelin-guide-ceremony/the-michelin-guide-croatia-2026-is-unveiled","d":null,"cn":null},
{"id":9156,"u":"https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-slovenia-2026-is-out","d":"Nejc Far\u010dnik","cn":null},
{"id":10072,"u":"https://guide.michelin.com/en/article/news-and-views/the-michelin-guide-slovenia-2026-is-out","d":"Peter Patajac","cn":null},
{"id":16471,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/neal-mccarthy--miller-union-service-award-michelin-star-guide-ceremony-atlanta","d":"Neal McCarthy","cn":"Service Award"},
{"id":20954,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/at-salt-on-amelia-island-exceptional-service-starts-long-before-guests-arrive","d":"Christopher Tegreeny","cn":"Service Award"},
{"id":20962,"u":"https://guide.michelin.com/jp/en/article/michelin-guide-ceremony/michelin-guide-new-zealand-2026-restaurant-selection","d":"Matthew Aitchison","cn":null},
{"id":21096,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-stars-atlanta-ceremony-green-sustainable-gastronomy","d":null,"cn":null},
{"id":21097,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-atlanta-stars-green-stars-sustainability","d":null,"cn":null},
{"id":21153,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/maria-isabel-san-francisco-michelin-guide-cocktail-award","d":"Evan Williams","cn":null},
{"id":21156,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/miles-macquarrie-kimball-house-cocktail-award-michelin-star-guide-ceremony-atlanta","d":"Miles Macquarrie","cn":null},
{"id":21157,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/ashleigh-mcfadden-nadair-sommelier-award-michelin-star-guide-ceremony-atlanta","d":"Ashleigh McFadden","cn":null},
{"id":21158,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/boccalupo-cocktail-award-michelin-star-guide-ceremony-atlanta","d":"Jason Furst","cn":null},
{"id":21159,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nordic-denmark-finland-iceland-norway-sweden-2026-new-stars-bib-gourmands-special-awards","d":"Andreas Ring Kjeldsholm Hansen","cn":null},
{"id":21160,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-vietnam-2026","d":"Ph\u01b0\u1edbc H\u1eadu Tr\u1ea7n","cn":null},
{"id":21161,"u":"https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-vietnam-2026","d":"Thanh V\u00e2n Nguy\u1ec5n","cn":"Service Award"},
{"id":21162,"u":"https://guide.michelin.com/lt/en/article/michelin-guide-ceremony/all-the-winners-michelin-guide-lithuania-2026-has-been-unveiled-new-stars-bib-gourmands-special-awards","d":"Ignatij Semionov","cn":null},
{"id":21163,"u":"https://guide.michelin.com/lt/en/article/michelin-guide-ceremony/all-the-winners-michelin-guide-lithuania-2026-has-been-unveiled-new-stars-bib-gourmands-special-awards","d":"Rokas Vasiliauskas","cn":null},
{"id":21221,"u":"https://guide.michelin.com/jp/en/article/michelin-guide-ceremony/michelin-guide-new-zealand-2026-restaurant-selection","d":"Stina Persen","cn":null}]';
  job_txt  text := 'special-awards:michelin-2026-special-awards | 430 rows inserted (Mindful Voices 260, Green Star 113, Service Award 17, Young Chef Award 12, Sommelier Award 11, Mentor Chef Award 10, Opening of the Year Award 5, Exceptional Cocktails Award 2); 59 skipped, venue not in DB (Q3 A); 18 legacy rows get source_url, 15 get the person (Q5 A, Q2 A); 3 Outstanding Service Award rows -> Service Award (QD A); new categories Mentor Chef Award, Mindful Voices (Q4 A); 21 Japan Green Stars from the venue page mark (QG A); source relay sha256 fe17ce67...88243f, file sha256 09cf8dc4...3e5665';
  pj jsonb; lj jsonb;
  n int; x int; s text;
  aud_max bigint; aud_n bigint; led_max bigint; led_n bigint;
BEGIN
  -- 1. Plan guards
  pj := plan_txt::jsonb; lj := leg_txt::jsonb;
  SELECT md5(string_agg(q.id || '|' || q.u || '|' || coalesce(q.d, '') || '|' || coalesce(q.cn, ''), E'\n' ORDER BY q.id)), count(*)
    INTO s, n FROM jsonb_to_recordset(lj) q(id bigint, u text, d text, cn text);
  IF s <> 'eafc864b1c5cdf08431bbb571b7e2494' OR n <> 18 THEN RAISE EXCEPTION 'legacy plan md5 % / rows % do not match', s, n; END IF;


  WITH p AS (
    SELECT (e->>0)::int l,
      CASE e->>1 WHEN 'G' THEN 'Green Star' WHEN 'M' THEN 'Mindful Voices' WHEN 'S' THEN 'Service Award' WHEN 'W' THEN 'Sommelier Award'
        WHEN 'Y' THEN 'Young Chef Award' WHEN 'T' THEN 'Mentor Chef Award' WHEN 'O' THEN 'Opening of the Year Award' WHEN 'C' THEN 'Exceptional Cocktails Award' END c,
      (e->>2)::int y,
      CASE WHEN (e->>6)::int < 0 THEN lower(regexp_replace(regexp_replace(e->>3, '^([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) ELSE e->>3 END k,
      e->>4 v, nullif(e->>5, '') d,
      'https://guide.michelin.com/' || CASE WHEN (e->>6)::int < 0 THEN e->>3 ELSE pj->'a'->>((e->>6)::int) END u
    FROM jsonb_array_elements(pj->'r') e),
  m AS (SELECT DISTINCT a.venue_id, lower(regexp_replace(regexp_replace(split_part(a.source_url, '?', 1), '^https?://guide\.michelin\.com/([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) k
    FROM awards a WHERE a.source_id = 'michelin' AND a.source_url LIKE 'https://guide.michelin.com/%'),
  r AS (SELECT p.*,
      CASE WHEN p.v <> '' THEN (SELECT id FROM venues WHERE id = p.v) ELSE (SELECT min(m.venue_id) FROM m WHERE m.k = p.k) END vid,
      CASE WHEN p.v <> '' THEN (SELECT count(*) FROM venues WHERE id = p.v) ELSE (SELECT count(DISTINCT m.venue_id) FROM m WHERE m.k = p.k) END nv
    FROM p)
  SELECT count(*), count(*) FILTER (WHERE nv = 1 AND vid IS NOT NULL),
         md5(string_agg(l || '|' || c || '|' || y || '|' || coalesce(d, '') || '|' || u || '|' || k || '|' || v, E'\n' ORDER BY l))
    INTO n, x, s FROM r;
  IF n <> 430 THEN RAISE EXCEPTION 'plan rows % (expected 430)', n; END IF;
  IF x <> 430 THEN RAISE EXCEPTION 'rows matching exactly one venue % (expected 430)', x; END IF;
  IF s <> '55ccab86e479b45c03005a10a007c64f' THEN
    WITH p AS (
      SELECT (e->>0)::int l,
        CASE e->>1 WHEN 'G' THEN 'Green Star' WHEN 'M' THEN 'Mindful Voices' WHEN 'S' THEN 'Service Award' WHEN 'W' THEN 'Sommelier Award'
          WHEN 'Y' THEN 'Young Chef Award' WHEN 'T' THEN 'Mentor Chef Award' WHEN 'O' THEN 'Opening of the Year Award' WHEN 'C' THEN 'Exceptional Cocktails Award' END c,
        (e->>2)::int y,
        CASE WHEN (e->>6)::int < 0 THEN lower(regexp_replace(regexp_replace(e->>3, '^([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) ELSE e->>3 END k,
        e->>4 v, nullif(e->>5, '') d,
        'https://guide.michelin.com/' || CASE WHEN (e->>6)::int < 0 THEN e->>3 ELSE pj->'a'->>((e->>6)::int) END u
      FROM jsonb_array_elements(pj->'r') e)
    SELECT string_agg(l || ':' || left(md5(c || '|' || y || '|' || coalesce(d, '') || '|' || u || '|' || k || '|' || v), 5), ' ' ORDER BY l) INTO s FROM p;
    RAISE EXCEPTION 'expanded rows do not match; per-row check: %', s;
  END IF;
  WITH p AS (
    SELECT (e->>0)::int l,
      CASE e->>1 WHEN 'G' THEN 'Green Star' WHEN 'M' THEN 'Mindful Voices' WHEN 'S' THEN 'Service Award' WHEN 'W' THEN 'Sommelier Award'
        WHEN 'Y' THEN 'Young Chef Award' WHEN 'T' THEN 'Mentor Chef Award' WHEN 'O' THEN 'Opening of the Year Award' WHEN 'C' THEN 'Exceptional Cocktails Award' END c,
      (e->>2)::int y,
      CASE WHEN (e->>6)::int < 0 THEN lower(regexp_replace(regexp_replace(e->>3, '^([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) ELSE e->>3 END k,
      e->>4 v, nullif(e->>5, '') d,
      'https://guide.michelin.com/' || CASE WHEN (e->>6)::int < 0 THEN e->>3 ELSE pj->'a'->>((e->>6)::int) END u
    FROM jsonb_array_elements(pj->'r') e),
  m AS (SELECT DISTINCT a.venue_id, lower(regexp_replace(regexp_replace(split_part(a.source_url, '?', 1), '^https?://guide\.michelin\.com/([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) k
    FROM awards a WHERE a.source_id = 'michelin' AND a.source_url LIKE 'https://guide.michelin.com/%'),
  r AS (SELECT p.*,
      CASE WHEN p.v <> '' THEN (SELECT id FROM venues WHERE id = p.v) ELSE (SELECT min(m.venue_id) FROM m WHERE m.k = p.k) END vid,
      CASE WHEN p.v <> '' THEN (SELECT count(*) FROM venues WHERE id = p.v) ELSE (SELECT count(DISTINCT m.venue_id) FROM m WHERE m.k = p.k) END nv
    FROM p)
  SELECT md5(string_agg(l || ':' || vid, ',' ORDER BY l)), count(DISTINCT vid) INTO s, x FROM r;
  IF s <> '077b151a8b0f3036a3e5197abdaf61b6' OR x <> 362 THEN RAISE EXCEPTION 'venue match md5 % / venues % (expected 077b151a8b0f3036a3e5197abdaf61b6 / 362)', s, x; END IF;
  WITH p AS (
    SELECT (e->>0)::int l,
      CASE e->>1 WHEN 'G' THEN 'Green Star' WHEN 'M' THEN 'Mindful Voices' WHEN 'S' THEN 'Service Award' WHEN 'W' THEN 'Sommelier Award'
        WHEN 'Y' THEN 'Young Chef Award' WHEN 'T' THEN 'Mentor Chef Award' WHEN 'O' THEN 'Opening of the Year Award' WHEN 'C' THEN 'Exceptional Cocktails Award' END c,
      (e->>2)::int y,
      CASE WHEN (e->>6)::int < 0 THEN lower(regexp_replace(regexp_replace(e->>3, '^([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) ELSE e->>3 END k,
      e->>4 v, nullif(e->>5, '') d,
      'https://guide.michelin.com/' || CASE WHEN (e->>6)::int < 0 THEN e->>3 ELSE pj->'a'->>((e->>6)::int) END u
    FROM jsonb_array_elements(pj->'r') e),
  m AS (SELECT DISTINCT a.venue_id, lower(regexp_replace(regexp_replace(split_part(a.source_url, '?', 1), '^https?://guide\.michelin\.com/([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) k
    FROM awards a WHERE a.source_id = 'michelin' AND a.source_url LIKE 'https://guide.michelin.com/%'),
  r AS (SELECT p.*,
      CASE WHEN p.v <> '' THEN (SELECT id FROM venues WHERE id = p.v) ELSE (SELECT min(m.venue_id) FROM m WHERE m.k = p.k) END vid,
      CASE WHEN p.v <> '' THEN (SELECT count(*) FROM venues WHERE id = p.v) ELSE (SELECT count(DISTINCT m.venue_id) FROM m WHERE m.k = p.k) END nv
    FROM p)
  SELECT count(*), string_agg(r.l || '>' || a.id, ' ') INTO x, s FROM r JOIN awards a
    ON a.venue_id = r.vid AND a.source_id = 'michelin' AND a.year = r.y
   AND (a.category = r.c OR (r.c = 'Service Award' AND a.category = 'Outstanding Service Award'));
  IF x <> 0 THEN RAISE EXCEPTION 'rows already present for venue + category + year: %', s; END IF;

  -- 2. Legacy rows as read Oct 29 (Q5 A): no source_url, no distinction, category as read
  SELECT count(*) INTO x FROM awards a JOIN jsonb_to_recordset(lj) q(id bigint, u text, d text, cn text) ON a.id = q.id
   WHERE a.source_id = 'michelin' AND a.source_url IS NULL AND a.distinction IS NULL
     AND (q.cn IS NOT NULL) = (a.category = 'Outstanding Service Award');
  IF x <> 18 THEN RAISE EXCEPTION 'legacy rows in the read state % (expected 18)', x; END IF;
  SELECT count(*) INTO x FROM award_categories WHERE source_id = 'michelin' AND category IN ('Mentor Chef Award', 'Mindful Voices');
  IF x <> 0 THEN RAISE EXCEPTION 'new categories already present: %', x; END IF;

  -- 3. Counts before
  SELECT count(*) INTO x FROM awards;           IF x <> 22922 THEN RAISE EXCEPTION 'awards before % (expected 22922)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9218 THEN RAISE EXCEPTION 'Michelin awards before % (expected 9218)', x; END IF;
  SELECT count(*) INTO x FROM award_categories; IF x <> 2141 THEN RAISE EXCEPTION 'award_categories before % (expected 2141)', x; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11307 THEN RAISE EXCEPTION 'venues before % (expected 11307)', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 12842 THEN RAISE EXCEPTION 'slugs before % (expected 12842)', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3263 THEN RAISE EXCEPTION 'cities before % (expected 3263)', x; END IF;
  SELECT count(*), max(id) INTO led_n, led_max FROM source_capture_ledger;
  IF led_n <> 94 OR led_max <> 138 THEN RAISE EXCEPTION 'ledger before % / max % (expected 94 / 138)', led_n, led_max; END IF;
  SELECT count(*), max(id) INTO aud_n, aud_max FROM audit_log;
  IF aud_n <> 107678 OR aud_max <> 112962 THEN RAISE EXCEPTION 'audit_log before % / max % (expected 107678 / 112962)', aud_n, aud_max; END IF;

  -- 4. Write
  INSERT INTO award_categories (source_id, category) VALUES ('michelin', 'Mentor Chef Award'), ('michelin', 'Mindful Voices');
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'categories inserted % (expected 2)', n; END IF;

  UPDATE awards a SET source_url = q.u,
         distinction = coalesce(q.d, a.distinction),
         category = coalesce(q.cn, a.category)
    FROM jsonb_to_recordset(lj) q(id bigint, u text, d text, cn text)
   WHERE a.id = q.id AND a.source_id = 'michelin' AND a.source_url IS NULL AND a.distinction IS NULL;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 18 THEN RAISE EXCEPTION 'legacy rows updated % (expected 18)', n; END IF;

  WITH p AS (
    SELECT (e->>0)::int l,
      CASE e->>1 WHEN 'G' THEN 'Green Star' WHEN 'M' THEN 'Mindful Voices' WHEN 'S' THEN 'Service Award' WHEN 'W' THEN 'Sommelier Award'
        WHEN 'Y' THEN 'Young Chef Award' WHEN 'T' THEN 'Mentor Chef Award' WHEN 'O' THEN 'Opening of the Year Award' WHEN 'C' THEN 'Exceptional Cocktails Award' END c,
      (e->>2)::int y,
      CASE WHEN (e->>6)::int < 0 THEN lower(regexp_replace(regexp_replace(e->>3, '^([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) ELSE e->>3 END k,
      e->>4 v, nullif(e->>5, '') d,
      'https://guide.michelin.com/' || CASE WHEN (e->>6)::int < 0 THEN e->>3 ELSE pj->'a'->>((e->>6)::int) END u
    FROM jsonb_array_elements(pj->'r') e),
  m AS (SELECT DISTINCT a.venue_id, lower(regexp_replace(regexp_replace(split_part(a.source_url, '?', 1), '^https?://guide\.michelin\.com/([a-z]{2}/[a-z]{2}(_[A-Z]{2})?/|[a-z]{2}/)', ''), '/(restaurante|ristorante)/', '/restaurant/')) k
    FROM awards a WHERE a.source_id = 'michelin' AND a.source_url LIKE 'https://guide.michelin.com/%'),
  r AS (SELECT p.*,
      CASE WHEN p.v <> '' THEN (SELECT id FROM venues WHERE id = p.v) ELSE (SELECT min(m.venue_id) FROM m WHERE m.k = p.k) END vid,
      CASE WHEN p.v <> '' THEN (SELECT count(*) FROM venues WHERE id = p.v) ELSE (SELECT count(DISTINCT m.venue_id) FROM m WHERE m.k = p.k) END nv
    FROM p)
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
  SELECT vid, 'michelin', y, NULL, c, d, u FROM r ORDER BY l;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 430 THEN RAISE EXCEPTION 'award rows inserted % (expected 430)', n; END IF;

  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES ('michelin', 'award', 430, job_txt);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'ledger rows inserted % (expected 1)', n; END IF;

  -- 5. Post-checks
  SELECT count(*) INTO x FROM awards;           IF x <> 23352 THEN RAISE EXCEPTION 'awards after % (expected 23352)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin';
                                                IF x <> 9648 THEN RAISE EXCEPTION 'Michelin awards after % (expected 9648)', x; END IF;
  SELECT count(*) INTO x FROM award_categories; IF x <> 2143 THEN RAISE EXCEPTION 'award_categories after % (expected 2143)', x; END IF;
  SELECT count(*) INTO x FROM awards WHERE source_id = 'michelin' AND category = 'Outstanding Service Award';
  IF x <> 0 THEN RAISE EXCEPTION 'Outstanding Service Award rows left: %', x; END IF;
  SELECT string_agg(category || '=' || cnt, ' ' ORDER BY category) INTO s FROM (
    SELECT a.category, count(*) cnt FROM audit_log al JOIN awards a ON a.id::text = al.row_pk
     WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'INSERT' AND a.source_id = 'michelin'
     GROUP BY a.category) z;
  IF s <> 'Exceptional Cocktails Award=2 Green Star=113 Mentor Chef Award=10 Mindful Voices=260 Opening of the Year Award=5 Service Award=17 Sommelier Award=11 Young Chef Award=12' THEN
    RAISE EXCEPTION 'inserted rows by category: %', s; END IF;
  SELECT count(*) INTO x FROM (SELECT 1 FROM awards WHERE source_id = 'michelin' AND category NOT IN ('One Star', 'Two Stars', 'Three Stars', 'Bib Gourmand')
                               GROUP BY venue_id, category, year HAVING count(*) > 1) d;
  IF x <> 0 THEN RAISE EXCEPTION 'venue + special category + year twice after: %', x; END IF;
  SELECT count(*) INTO x FROM venues;           IF x <> 11307 THEN RAISE EXCEPTION 'venues changed: %', x; END IF;
  SELECT count(*) INTO x FROM slugs;            IF x <> 12842 THEN RAISE EXCEPTION 'slugs changed: %', x; END IF;
  SELECT count(*) INTO x FROM cities;           IF x <> 3263 THEN RAISE EXCEPTION 'cities changed: %', x; END IF;

  SELECT count(*) INTO x FROM source_capture_ledger;
  IF x <> 95 THEN RAISE EXCEPTION 'ledger after % (expected 95)', x; END IF;
  SELECT count(*) INTO x FROM source_capture_ledger
   WHERE id > led_max AND publisher = 'michelin' AND field_type = 'award' AND items = 430 AND job = job_txt;
  IF x <> 1 THEN RAISE EXCEPTION 'new ledger row not found'; END IF;

  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max;
  IF x <> 448 THEN RAISE EXCEPTION 'audit rows this transaction % (expected 448)', x; END IF;
  SELECT count(*) INTO x FROM audit_log WHERE id > aud_max AND table_name = 'awards' AND action = 'INSERT';
  IF x <> 430 THEN RAISE EXCEPTION 'audit INSERT rows % (expected 430)', x; END IF;
  SELECT count(*) INTO x FROM audit_log al, jsonb_to_recordset(lj) q(id bigint, u text, d text, cn text)
   WHERE al.id > aud_max AND al.table_name = 'awards' AND al.action = 'UPDATE' AND al.row_pk = q.id::text
     AND al.old_row->>'source_url' IS NULL AND al.new_row->>'source_url' = q.u
     AND (SELECT count(*) FROM jsonb_object_keys(al.new_row) k WHERE al.old_row->k IS DISTINCT FROM al.new_row->k)
         = 1 + (q.d IS NOT NULL)::int + (q.cn IS NOT NULL)::int;
  IF x <> 18 THEN RAISE EXCEPTION 'audit UPDATE rows that change only the planned fields % (expected 18)', x; END IF;
END
$do$;
COMMIT;
