-- rename-oad-2026-names-2026-11-04.sql  CompassEats, Nov 4 2026. Open item 2: rename batch. 159 renames with new canonical slugs. Old slugs stay non-canonical.
-- Choices: Ben Nov 4 10:29 ET "A for all 8"
-- Evidence: names-evidence-2026-11-04.csv. Built by build_names.py, build_sql_names.py. One transaction.
BEGIN;
DO $do$
DECLARE
  p text := replace($p$
ve_0046e8758c	Georges Blanc · Restaurant Gastronomique	Georges Blanc	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/vonnas/restaurant/georges-blanc
ve_01982da706	Mantúa | Israel Ramos | Restaurante Jerez de la Frontera	Mantúa	venue	https://www.restaurantemantua.com/
ve_020095097a	Auberge de Clochemerle Hôtel-spa privatif & Restaurant 1 étoile MICHELIN	Auberge de Clochemerle	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/vaux-en-beaujolais/restaurant/auberge-de-clochemerle
ve_02df2db986	Akelarre Restaurant | Pedro Subijana	Akelarre	venue	https://akelarre.net/
ve_0660358e08	Prairial – Restaurant gastronomique étoilé Michelin à Lyon	Prairial	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/lyon/restaurant/prairial
ve_0e2af459d2	Iris | Rosendal	Iris	listing	https://hardangerfjord.com/en/food-and-drinks/iris-expedition-dining-6788333
ve_119d7c8d87	Bardal | Benito Gómez | Restaurante en Ronda	Bardal	venue	https://restaurantebardal.com/
ve_11a0c6820f	The Royal Cocktail Exchange | Tottenham Court Road	The Royal Cocktail Exchange	listing	https://cdn802.pressflex.net/news/fullstory.php/aid/1196/CTC_owners_open_The_Royal_Cocktail_Exchange.html
ve_157591506d	Kaleja | Dani Carnero | Restaurant in Malaga	Kaleja	venue	https://restaurantekaleja.com/
ve_1844ecb32d	Breizh Café Rennes | La Crêpe Autrement	Breizh Café Rennes	michelin	https://guide.michelin.com/en/bretagne/rennes/restaurant/breizh-cafe-rennes
ve_1bb011fe33	Bánh Xèo Tôm Nhảy Cô Ba Michelin	Bánh Xèo Tôm Nhảy Cô Ba	michelin	https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/banh-xeo-tom-nhay-co-ba
ve_1c7406cc48	Old tower	Old Tower	michelin	https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/old-tower
ve_1ce80fa4ef	Canteen | Notting Hill	Canteen	venue	https://www.canteen310.com/
ve_1edcb5d0c0	MICHELIN Guide | Awesome Char Koay Teow (齿刘香炒粿条)	Awesome Char Koay Teow	michelin	https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/awesome-char-koay-teow
ve_1ee766b4e3	Restaurante A Tafona. Menú. Santiago de Compostela.	A Tafona	michelin	https://guide.michelin.com/us/en/galicia/santiago-de-compostela/restaurant/a-tafona
ve_219bc4d332	Shangu	NISHIAZABU SHANGU	venue	https://shangu.jp/
ve_233364b3de	Anima Milano | Enrico Bartolini	Anima	venue	https://www.enricobartolini.net/i-ristoranti/milano-verticale
ve_244a886a56	Hôtel Restaurant Anne de Bretagne | Mathieu Guibert	Anne de Bretagne	michelin	https://guide.michelin.com/en/pays-de-la-loire/la-plaine-sur-mer/restaurant/anne-de-bretagne
ve_247efac0c9	Brikz	BRIKZ	venue	https://restaurantbrikz.com/
ve_264b524873	Flying Dutchmen Cocktails | Cocktail Bar Amsterdam	Flying Dutchmen Cocktails	listing	https://www.theworlds50best.com/discovery/Establishments/Netherlands/Amsterdam/Flying-Dutchmen-Cocktails.html
ve_26c25f8f0d	Toriyaki-ohana	Toriyaki Ohana	michelin	https://guide.michelin.com/us/en/tokyo-region/tokyo/restaurant/toriyaki-ohana
ve_273d8e1a92	L'Orchidee - Hôtel Restaurant gastronomique Ensisheim	L'Orchidée	michelin	https://guide.michelin.com/en/grand-est/ensisheim/restaurant/l-orchidee
ve_278783ec64	CASAS COLGADAS | Restaurante	Casas Colgadas	venue	https://www.restaurantecasascolgadas.com/
ve_2a18117e96	Restaurant Gastronomique L'Oursin	L'Oursin	michelin	https://guide.michelin.com/en/provence-alpes-cote-dazur/carry-le-rouet_1505150/restaurant/l-oursin
ve_2a5d6c2c68	Brasserie Astoria Singapore	Brasserie Astoria	venue	https://www.brasserieastoria.sg/
ve_2b020ceebf	BASE HALL 02	BaseHall 02	venue	https://www.basehall.hk/
ve_2b59b24d2b	Restaurant Gastronomique Jérôme Nutile *	Jérôme Nutile	michelin	https://guide.michelin.com/en/occitanie/nimes/restaurant/jerome-nutile
ve_2df65b448c	Le Carré d'Alethius | Logis Hôtel Restaurant Gastronomique Valence	Le Carré d'Alethius	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/charmes-sur-rhne/restaurant/le-carre-d-alethius
ve_2e21a1be11	Yoichi Sagura	Sagra	venue	https://sagra.jp/access/
ve_2ec41aad11	Restaurant Rincón de Diego | Cambrils	Rincón de Diego	venue	https://www.rincondediego.com/
ve_30b3753169	Hueber der Wirt Gasthof|Restaurant|Hotel	Hueber der Wirt in Bründl	michelin	https://guide.michelin.com/us/en/niederosterreich/sankt-georgen-an-der-leys_1051508/restaurant/hueber-der-wirt-in-brundl
ve_334ad1fa8d	Restaurant Anne - Place des Vosges, le Pavillon de la Reine	Anne	michelin	https://guide.michelin.com/en/ile-de-france/paris/restaurant/anne
ve_391b9761f3	Restaurant Les Cols | Olot	Les Cols	venue	https://www.lescols.com/
ve_3a3e26a2a9	Restaurant gastronomique Jean Sulpice	Jean Sulpice	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/talloires-montmin/restaurant/jean-sulpice
ve_3a422bc890	WM BY WAGYUMAFIA	WM by WAGYUMAFIA	venue	https://wagyumafia.com/pages/reservation
ve_3a5b6f6bd8	Sala de Corte | Steakhouse	Sala de Corte	listing	https://www.visitlisboa.com/pt-pt/locais/sala-de-corte
ve_3bdc8c9cf6	JIN	Jin	michelin	https://guide.michelin.com/us/en/bayern/mnchen/restaurant/jin254149
ve_3de8722614	Tazal - Best Restaurant In Al Qana	Tazal	venue	https://tazal.com/
ve_3ffab4597c	Hika	Hika by Roberto Ruiz	venue	https://www.hikabodega.com/
ve_412056e4a1	Restaurant Lamartine Lac du Bourget, Proche Aix-les-Bains	Lamartine	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/le-bourget-du-lac/restaurant/lamartine
ve_4196474d0c	Ramon Freixa Tradicion	Ramón Freixa Tradición	venue	https://ramonfreixatradicion.com/
ve_44dd0ee127	Galerija okusov, Kulinarični turizem in storitve, d.o.o.	Galerija okusov	michelin	https://guide.michelin.com/us/en/savinja/petrovce/restaurant/galerija-okusov
ve_46493a2426	Restaurante La Vasca en Miranda de Ebro.(Desde 1926).	La Vasca	venue	https://www.restaurantelavasca.com/
ve_46de9f9d98	SHIN YEH	Shin Yeh Taiwanese Cuisine	michelin	https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/shin-yeh-taiwanese-cuisine
ve_48e73db2bc	Komfort | Restaurante Calpe	Komfort	venue	https://www.ar-hotels.com/hotel-the-cookbook
ve_49163ff49f	Table No 1	Table No. 1	venue	https://www.tableno-1.com/
ve_4bddce6b9f	Les Agitateurs - restaurant gastronomique	Les Agitateurs	michelin	https://guide.michelin.com/en/provence-alpes-cote-dazur/nice/restaurant/les-agitateurs
ve_4cb2f1e19a	Ochando Restaurante | Menú degustación | Los Rosales, Sevilla	Ochando	michelin	https://guide.michelin.com/us/en/andalucia/los-rosales_3888074/restaurant/ochando
ve_4e38cb55f7	Lympstone Manor Hotel, Restaurant and Vineyard, Devon	Lympstone Manor	venue	https://lympstonemanor.co.uk/
ve_510f83360e	Mika | Yas Marina	Mika	michelin	https://guide.michelin.com/us/en/abu-dhabi-emirate/abu-dhabi/restaurant/mika
ve_52de2e9ec3	NIKU X | Premium Seafood & A5 Wagyu Steak Buffet	NIKU X	listing	https://www.finedininglovers.com/restaurants/niku-x
ve_54f99788ec	TINC GANA	Tinc gana	michelin	https://guide.michelin.com/us/en/tokyo-region/tokyo/restaurant/tinc-gana
ve_5544dcb0fd	Anna Stuben 1 Stella Michelin	Anna Stuben	michelin	https://guide.michelin.com/us/en/trentino-alto-adige/ortisei/restaurant/anna-stuben
ve_55a06f65ff	SEP	Sếp	venue	https://www.sep-hk.com/
ve_5651dc27bd	SISAPO Restaurant | Fusion Cuisine	Sisapo	venue	https://www.sisapo.es/
ve_5683d1f7b5	De Lauzun : Hôtel et Restaurant Gastronomique à Pézenas	Restaurant De Lauzun	michelin	https://guide.michelin.com/en/occitanie/pzenas/restaurant/restaurant-de-lauzun
ve_579388e6c8	ESPECIARIUM BAR | Barcelona	Especiarium Bar	listing	https://theworlds50best.com/discovery/Establishments/Spain/Barcelona/Especiarium-Bar.html
ve_597637956c	L'Atelier de Joel Robuchon Roppongi Hills Restaurant	L'ATELIER de Joël Robuchon	michelin	https://guide.michelin.com/us/en/tokyo-region/tokyo/restaurant/l-atelier-de-joel-robuchon-1194216
ve_5bc114bba1	La Gaia | Ibiza Gran Hotel	Brula	venue	https://brulaibiza.com/
ve_5d078c2bc3	Agreste de Fabio & Roser | Restaurante gastronómico Barcelona	Agreste de Fabio & Roser	listing	https://ajuntament.barcelona.cat/comerc/en/agreste
ve_5d147987d2	Trid	trid	venue	https://tridseoul.com/
ve_5f270c5c32	L’ Eau	L'EAU	venue	https://leau.tokyo/
ve_60f66dda34	Hisop | Barcelona	Hisop	venue	https://www.hisop.com/
ve_615c14449a	La Catedral Bar | Cócteles y Antojitos	La Catedral Bar	listing	https://www.myswitzerland.com/en/experiences/food-wine/restaurant/la-catedral
ve_649a9081fa	El Rebojo | Bocados de Mar y Vinos	El Rebojo	venue	https://elrebojo.com/
ve_659f81b68a	Austria Stuben - Kulinarik auf 1930m - a Michelin Star Restaurant	Austria Stuben	michelin	https://guide.michelin.com/us/en/tirol/obergurlg_7770324/restaurant/austria-stuben
ve_669f84e512	Carnes Asadas Pancho Lopez, Mexican Food in Los Angeles CA 🇲🇽	Carnes Asadas Pancho Lopez	michelin	https://guide.michelin.com/us/en/california/us-los-angeles/restaurant/carnes-asadas-pancho-lopez
ve_66b4a26949	Akasaka Tan-tei	Akasaka Tantei	venue	https://akasaka-tantei.com/
ve_68e0007daa	Ristorante L'Aurum	L'Aurum	venue	https://www.albereta.it/franciacorta/ristorante-fine-dining/
ve_68e8796030	Frasca | Food & Wine	Frasca Food and Wine	venue	https://www.frascafoodandwine.com/
ve_68ebaf7fa5	Avarum | Restaurant Gastronomique Blois - Fougères-sur-Bièvre	Avarum	michelin	https://guide.michelin.com/en/centre-val-de-loire/fougeres-sur-bievre/restaurant/avarum
ve_6a8fd785e4	L'Oustalet - Gigondas, Restaurant étoilé et Chambres d'hôtes	L'Oustalet	michelin	https://guide.michelin.com/en/provence-alpes-cote-dazur/gigondas/restaurant/l-oustalet
ve_6b9f37768c	Indian Aroma Restaurant- First Michelin Select( former Mumtaz Indian)	Indian Aroma	venue	https://mumtazindianaroma.com/
ve_6bdb39a21d	Jee Hong Kong	JEE	venue	https://www.jeehongkong.hk/
ve_6d9803a0e6	ORA | Taverna & Bar	ORA	venue	https://ora-taverna.nl/home
ve_70045fa97a	Château de Courban & Spa Nuxe - Château Hôtel en Bourgogne	Château de Courban	michelin	https://guide.michelin.com/en/bourgogne-franche-comte/courban/restaurant/chateau-de-courban
ve_7309c55a23	Pavyllon Monte-Carlo, un restaurant de Yannick Alléno	Pavyllon Monte-Carlo	venue	https://www.montecarlosbm.com/fr/restaurant-monaco/pavyllon-monte-carlo-restaurant-yannick-alleno
ve_73b52aca31	Tanakada	Tanakada Nishiazabuten	michelin	https://guide.michelin.com/us/en/tokyo-region/tokyo/restaurant/tanakada-nishiazabuten
ve_74cb737437	Don Juan II | Yachts de Paris	Don Juan II	michelin	https://guide.michelin.com/en/ile-de-france/paris/restaurant/don-juan-ii
ve_756d986d8f	HUPO琥珀 | Best Szechuan Food in LIC	Hupo	michelin	https://guide.michelin.com/us/en/new-york-state/queens/restaurant/hupo
ve_76b68f7dbc	Cleaver- Butchered Meats, Seafood & Classic Cocktails	Cleaver	listing	https://www.lasvegasadvisor.com/restaurants/cleaver/
ve_773a70c33e	Table - Ingredient Based Cuisine	TABLE by Sandy Keung	venue	https://www.tablebysandykeung.com/
ve_7803cd8594	Armani Ristorante	Armani/Ristorante	venue	https://www.armani.com/en/armani-restaurant/experience/armani-ristorante-tokyo-ginza/
ve_7d17e77590	Restaurante Refectorio - Hotel Abadía Retuerta Le Domaine	Refectorio	venue	https://www.abadia-retuerta.com/
ve_7d24cfdc87	La Grange de Belle Église • Restaurant Étoilé	La Grange de Belle-Église	michelin	https://guide.michelin.com/en/hauts-de-france/belle-glise/restaurant/la-grange-de-belle-eglise
ve_84bfcb27c0	Umiko | Restaurante Japonés	Umiko	listing	https://guide.michelin.com/en/comunidad-de-madrid/madrid/restaurant/umiko
ve_85247a0627	Franky's Grill | Powered by Food Labs	Franky's Grill	venue	https://fgfoodlabs.nl/en
ve_86ef47d7cc	Hwa Hae Dang Michelin	Hwa Hae Dang	michelin	https://guide.michelin.com/us/en/seoul-capital-area/kr-seoul/restaurant/hwa-hae-dang
ve_87817d48cc	Blue Elephant Bangkok Sathorn Cooking School & Restaurant	Blue Elephant Bangkok Sathorn	venue	https://blueelephant.com/?p=703
ve_8a7ad46888	Restaurant Simple & Meilleur · Saint-Martin-de-Belleville	Simple et Meilleur	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/saint-martin-de-belleville/restaurant/simple-et-meilleur
ve_8ddefb9764	XO Seafood Bar	XO Seafoodbar	venue	https://www.thisisxo.de/
ve_8e42976446	Maison Nacre - Restaurant gastronomique	Nacre	michelin	https://guide.michelin.com/en/nouvelle-aquitaine/ars/restaurant/nacre
ve_8ee88d1059	Holt’s Cafe	Holt's Café	venue	https://www.rosewoodhotels.com/en/hong-kong/dining/holts-cafe
ve_8f7008ae11	Krone Hittisau - Hotel & Restaurant im Bregenzerwald	Krone Hittisau	michelin	https://guide.michelin.com/us/en/vorarlberg/hittisau_1040905/restaurant/krone-1212356
ve_91143eac6a	Restaurant Les Oliviers - 1* au Guide Michelin	Les Oliviers	michelin	https://guide.michelin.com/en/provence-alpes-cote-dazur/bandol/restaurant/les-oliviers122360
ve_91eceec206	AL MADRIGALE | Nuova Cucina Rurale	Al Madrigale	venue	https://www.almadrigale.it/
ve_9339475308	The Cocktail Trading Co. | Shoreditch	The Cocktail Trading Co.	listing	https://theworlds50best.com/discovery/Establishments/UK/London/The-Cocktail-Trading-Company.html
ve_94ea30c943	CHAR Fuego y Brasas | Steak house	CHAR Fuego y Brasas	listing	https://www.guiarepsol.com/es/fichas/char-fuego-y-brasas-332865/
ve_9519988e02	Bulle d'Osier** - restaurant gastronomique 2 Etoiles Michelin	Bulle d'Osier	michelin	https://guide.michelin.com/en/grand-est/langres/restaurant/bulle-d-osier
ve_9bed3015f8	To-Ricos Kway Chap Old Airport Road - (Blanco Court Food Centre 3rd Storey)	To-Ricos Kway Chap	michelin	https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/to-ricos-guo-shi
ve_9cf6b5fe0a	Zhup Zhup | Prawn noodle | Hokkien Mee | Pao Fan	Zhup Zhup	michelin	https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/zhup-zhup
ve_9f150d6f0f	Restaurant Sardaarji - 4x Michelin Bib Gourmand	Sardaarji	michelin	https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/sardaarji
ve_a1b2c31972	TAG | cocktail bar	TAG	listing	https://www.theworlds50best.com/bars/best-in-europe/the-list/tag.html
ve_a2b1c83c30	Restaurant Gastronomique Christian Tetedoie	Têtedoie	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/lyon/restaurant/tetedoie
ve_a4fa7d8cdd	Yasaka at Park Hyatt	Yasaka	venue	https://www.hyatt.com/park-hyatt/en-US/itmph-park-hyatt-kyoto/dining/yasaka
ve_a9f521f0e3	Restaurant gastronomique 2 étoiles Michelin - Le Corot	Le Corot	michelin	https://guide.michelin.com/en/ile-de-france/ville-d-avray/restaurant/le-corot
ve_ab39ba0870	Hotel Orania	Orania.Berlin	venue	https://orania.berlin/
ve_ab4e53c1d2	Nori - Restaurant gastronomique du Brittany & Spa	Nori	michelin	https://guide.michelin.com/en/bretagne/roscoff/restaurant/nori
ve_ab7d6f746a	Murder Inc. Cocktails | Soho	Murder Inc. Cocktails	listing	https://www.theworlds50best.com/discovery/Establishments/UK/London/Murder-Inc.html
ve_ab8204505e	Saap | Northern Thai Cuisine	Saap	listing	https://www.sevendaysvt.com/food-drink/an-isan-native-cooks-up-exotic-thai-food-at-randolphs-saap-25054416
ve_ae3184649d	Restaurante Simposio | Roger Julián	Simposio	venue	https://rogerjulian.es/
ve_aeb69153c4	Il Colmetto | Ristorante in Franciacorta	Il Colmetto	michelin	https://guide.michelin.com/us/en/lombardia/rodengo-saiano/restaurant/il-colmetto
ve_af04d11e71	Le Jardin Secret [Gilles LEININGER] Restaurant gastronomique - Strasbourg La Wantzenau	Le Jardin Secret	michelin	https://guide.michelin.com/en/grand-est/la-wantzenau/restaurant/le-jardin-secret
ve_b15616bb77	Restaurant Le Hatley | Relais & Châteaux	Restaurant Le Hatley	listing	https://guide.michelin.com/lu/fr/quebec/north-hatley_2434732/restaurant/le-hatley-manoir-hovey
ve_b281762231	L'ETERRE	L'ÉTERRE	michelin	https://guide.michelin.com/us/en/tokyo-region/tokyo/restaurant/l-eterre
ve_b6cd3aef2c	Bākkō Madrid	Bākkō	venue	https://bakkomadrid.es/
ve_b7791eab98	Restaurant Gastronomique Les Pêcheurs Antibes	Les Pêcheurs	michelin	https://guide.michelin.com/en/provence-alpes-cote-dazur/antibes/restaurant/les-pecheurs
ve_b79abf6ec2	La Table Breizh Café (Restaurant Japonais étoilé)	La Table Breizh Café	michelin	https://guide.michelin.com/en/bretagne/cancale/restaurant/la-table-breizh-cafe
ve_bbb5493598	Fat Badger	The Fat Badger	michelin	https://guide.michelin.com/us/en/greater-london/london/restaurant/the-fat-badger
ve_bd080ed182	The Morrison Room at Carton House, A Fairmont Managed Hotel	The Morrison Room	venue	https://www.cartonhouse.com/dining/the-morrison-room
ve_c09886ba92	RIME | Seafood + Steak	RIME	listing	https://parkcityrestaurants.com/restaurants/rime-at-the-st-regis-deer-valley
ve_c0ccaa867a	Notes, restaurant gastronomique	Notes	michelin	https://guide.michelin.com/en/nouvelle-aquitaine/cognac/restaurant/notes
ve_c33b6405c3	PENANG ROAD FAMOUS JIN KOR CHAR KUEY TEOW 檳榔律驰名仁哥炒粿條	Penang Road Famous Jin Kor Char Kuey Teow	michelin	https://guide.michelin.com/us/en/pulau-pinang/my-george-town/restaurant/penang-road-famous-jin-kor-char-kuey-teow
ve_c4d8e44e69	ANONA - Restaurant gastronomique étoilé	Anona	michelin	https://guide.michelin.com/en/ile-de-france/paris/restaurant/anona
ve_c54ccb7f57	Ristorante Giglio	Giglio	venue	https://www.ristorantegiglio.com/
ve_c6a377cdbb	Agapé, Restaurant gastronomique Paris 17ème	Agapé	michelin	https://guide.michelin.com/en/ile-de-france/paris/restaurant/agape
ve_c7f5181cd4	Armatore La Dispensa – Ristorante di Mare | Cetara	La Dispensa di Armatore	venue	https://www.armatorecetara.it/dispensa/
ve_cb064b5372	فنيال | Fenyal	Fenyal	michelin	https://guide.michelin.com/us/en/doha-region/doha_2433318/restaurant/fenyal
ve_cb5e60fa70	Ristorante Campo Del Drago - Rosewood Castiglion del Bosco	Campo del Drago	venue	https://www.rosewoodhotels.com/it/castiglion-del-bosco/dining/ristorante-campo-del-drago
ve_cfa5cda032	Nhà Hàng Chay Ngọc Chi - Vegetarian Restaurant Michelin guide 2025	Ngọc Chi	michelin	https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/ngoc-chi
ve_d503fa30af	Restaurante La Era de los Nogales & Catering La Era de los Nogales	La Era de los Nogales	venue	https://www.laeradelosnogales.com/
ve_d58d2221e4	Andrea Aprea | Ristorante	Andrea Aprea	venue	https://www.andreaaprea.com/
ve_d5d1159488	Bolero | BGC Restaurant	Bolero	michelin	https://guide.michelin.com/us/en/metro-manila/taguig-city_2327686/restaurant/bolero-1217698
ve_d83b4c4ac0	KAVA | Fernando Alcalá | Restaurante en Marbella	KAVA	listing	https://andalucia.org/en/marbella-restaurants-kava-restaurant
ve_d8e4f45e7b	Karma Modern Indian | Karizma Modern Indian	Karizma Modern Indian	michelin	https://guide.michelin.com/us/en/district-of-columbia/washington-dc/restaurant/karizma-modern-indian
ve_e04d45cd19	BAK | Fine dining Restaurant Amsterdam	BAK	venue	https://www.bakrestaurant.nl/
ve_e156e96564	Restaurant Il Cortile | Étoilé Michelin	Il Cortile	michelin	https://guide.michelin.com/en/grand-est/mulhouse/restaurant/il-cortile40020
ve_e27bca251d	Al Khayma Heritage Restaurant | مطعم الخيمة التراثي	Al Khayma Heritage Restaurant	michelin	https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/al-khayma
ve_e2e751c581	Hôtel - Spa La Borie d'Hélipse & Restaurant Le Puy Tilleul	Le Puy Tilleul	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/tournemire/restaurant/le-puy-tilleul
ve_e39777f03c	Tom Curiosa	TOM Curiosa	venue	https://tomcuriosa.com
ve_e58084bdb2	Yosuke Yamaji	Yamaji Yosuke	michelin	https://guide.michelin.com/us/en/kyoto-region/kyoto/restaurant/yamaji-yosuke
ve_e5a81887cb	Mizuki	Tempura Mizuki	venue	https://mizuki.ritzcarltonkyoto.com/tempura-mizuki
ve_e63632e9e1	Bros Restaurant	BROS'	venue	https://www.brosworld.it/bros/
ve_e7a107335e	Revelry | Indian Tapas Bar	Revelry	michelin	https://guide.michelin.com/us/en/dubai-emirate/dubai/restaurant/revelry
ve_e898497b9e	Shamballa Vegetarian, Greenhouse & Rooftop Bar - Da Nang	Shamballa	michelin	https://guide.michelin.com/us/en/da-nang-region/da-nang_2984390/restaurant/shamballa
ve_ea0ac1f83a	Comptoir Breizh Café Saint-Malo | La Crêpe Autrement	Le Comptoir Breizh Café	michelin	https://guide.michelin.com/en/bretagne/saint-malo/restaurant/le-comptoir-breizh-cafe
ve_eb90f4645b	Stella Ristorante Vineria e Locanda	Stella	venue	https://www.stellaperugia.it/
ve_ec5bb0dfdb	Ristorante Arnolfo | 2 Stelle Michelin	Arnolfo	venue	https://www.arnolfo.com/
ve_eeb2006f97	Terrazza Glicine | Seaview Restaurant	Glicine	venue	https://www.hotelsantacaterina.it/ristoranti-e-bar/ristorante-glicine/
ve_ef25cbc6cd	CIBO restaurant gastronomique à Dijon	CIBO	michelin	https://guide.michelin.com/en/bourgogne-franche-comte/dijon/restaurant/cibo
ve_ef6621c8e8	Takibi | Japanese Restaurant	Takibi	venue	https://takibipdx.com
ve_f206c37f46	Breizh Café Megève | La Crêpe Autrement	Breizh Café Megève	michelin	https://guide.michelin.com/en/auvergne-rhone-alpes/megve/restaurant/breizh-cafe-megeve
ve_f457393f4f	Ristorante - Hotel - Sala Ricevimenti "Antica Filanda"	Antica Filanda	venue	https://www.anticafilanda.me/
ve_f6e5763d41	Palodú | Restaurante Centro de Málaga | Menú degustación	Palodú	michelin	https://guide.michelin.com/us/en/andalucia/malaga/restaurant/palodu
ve_f76faf0b7a	Ar Men Du | Hôtel 3 étoiles - Restaurant Gastronomique avec Vue Mer | Névez, Finistère	Ar Men Du	michelin	https://guide.michelin.com/en/bretagne/nevez/restaurant/ar-men-du
ve_f986c56924	Villa9Trois - Restaurant Gastronomique	Villa9Trois	michelin	https://guide.michelin.com/en/ile-de-france/montreuil-ile-de-france/restaurant/villa9trois
ve_fb6905ec77	Restaurant 141 | by Joachim Jaud	Restaurant 141 by Joachim Jaud	venue	https://restaurant-141.at/
ve_fba62b3722	Varvarka 3 | Ресторан & сигарный клуб Китай-город | Винный бар, кафе, банкетный ресторан	Varvarka 3	listing	https://www.restoclub.ru/msk/place/varka-3/opinions
ve_fcc0d286e3	Le Petit Nice Passedat - Hôtel 5 étoiles Relais & Châteaux à Marseille	Le Petit Nice	michelin	https://guide.michelin.com/en/provence-alpes-cote-dazur/marseille/restaurant/le-petit-nice
$p$,E'\r','');
  n int; n2 int; bid bigint; aud bigint; same int; flip int; ch int; r record; msg text; ln int:=0;
BEGIN
  p := trim(both E'\n' from p);
  IF md5(p) <> 'ca34a40be342ff28ccaed9b0405d02a0' THEN RAISE EXCEPTION 'plan md5 %, length %', md5(p), length(p); END IF;
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM venues WHERE status='active')<>11288 OR (SELECT count(*) FROM venues WHERE status='closed')<>306 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM slugs)<>13444 OR (SELECT count(*) FROM price)<>7759 OR (SELECT count(*) FROM redirects)<>33 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger)<>239 OR (SELECT max(id) FROM source_capture_ledger)<>293 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*),max(id) INTO n,aud FROM audit_log; IF n<>124351 OR aud<>130180 THEN RAISE EXCEPTION 'audit before % %',n,aud; END IF;
  IF EXISTS (SELECT 1 FROM rename_batches WHERE batch_key='rename-oad-2026-names-2026-11-04') THEN RAISE EXCEPTION 'batch key used'; END IF;
  WITH q AS (SELECT split_part(x,E'\t',1) id,split_part(x,E'\t',2) oldn FROM regexp_split_to_table(p,E'\n') x)
    SELECT count(*) INTO n FROM q JOIN venues v ON v.id=q.id AND v.name=q.oldn; IF n<>159 THEN RAISE EXCEPTION 'names moved, % of 159',n; END IF;
  -- same new name twice in one city, or an equal key on another venue in the city
  WITH q AS (SELECT split_part(x,E'\t',1) id,split_part(x,E'\t',3) newn FROM regexp_split_to_table(p,E'\n') x), w AS (SELECT q.id,q.newn,v.city_id,norm_key(q.newn) k FROM q JOIN venues v ON v.id=q.id)
    SELECT string_agg(w.newn||' / '||o.name||' '||o.id,'; ') INTO msg FROM w JOIN venues o ON o.city_id=w.city_id AND o.id<>w.id AND o.norm_key=w.k AND o.id NOT IN (SELECT id FROM q) WHERE w.k IS NOT NULL;
  IF msg IS NOT NULL THEN RAISE EXCEPTION 'name key clash: %',msg; END IF;
  WITH q AS (SELECT split_part(x,E'\t',1) id,split_part(x,E'\t',3) newn FROM regexp_split_to_table(p,E'\n') x),
    w AS (SELECT q.id,q.newn,s.city_slug cs,trim(both '-' from regexp_replace(lower(f_unaccent(q.newn)),'[^a-z0-9]+','-','g')) ns,s.slug os FROM q JOIN slugs s ON s.venue_id=q.id AND s.is_canonical AND s.property_id='eats')
    SELECT string_agg(w.newn||' -> '||w.cs||'/'||w.ns||' held by '||t.venue_id,'; ') INTO msg FROM w JOIN slugs t ON t.property_id='eats' AND t.city_slug=w.cs AND t.slug=w.ns AND t.venue_id<>w.id;
  IF msg IS NOT NULL THEN RAISE EXCEPTION 'slug clash: %',msg; END IF;
  WITH q AS (SELECT split_part(x,E'\t',1) id,split_part(x,E'\t',3) newn FROM regexp_split_to_table(p,E'\n') x),
    w AS (SELECT trim(both '-' from regexp_replace(lower(f_unaccent(q.newn)),'[^a-z0-9]+','-','g')) ns,s.city_slug cs,s.slug os,q.id FROM q JOIN slugs s ON s.venue_id=q.id AND s.is_canonical AND s.property_id='eats')
    SELECT count(*) FILTER (WHERE ns=os), count(*) FILTER (WHERE ns<>os AND EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=w.cs AND t.slug=w.ns AND t.venue_id=w.id)), count(*) FILTER (WHERE ns='') INTO same,flip,n FROM w;
  IF n<>0 THEN RAISE EXCEPTION 'empty slug %',n; END IF;
  WITH q AS (SELECT split_part(x,E'\t',1) id,split_part(x,E'\t',3) newn FROM regexp_split_to_table(p,E'\n') x)
    SELECT count(*) INTO n FROM redirects rd JOIN slugs s ON s.venue_id IN (SELECT id FROM q) AND s.is_canonical JOIN q ON q.id=s.venue_id WHERE rd.from_path='/'||s.city_slug||'/'||trim(both '-' from regexp_replace(lower(f_unaccent(q.newn)),'[^a-z0-9]+','-','g'));
  IF n<>0 THEN RAISE EXCEPTION 'redirect clash %',n; END IF;
  SELECT count(*) INTO n2 FROM blurbs WHERE venue_id IN (SELECT split_part(x,E'\t',1) FROM regexp_split_to_table(p,E'\n') x);

  -- WRITE
  INSERT INTO rename_batches (batch_key,status,note) VALUES ('rename-oad-2026-names-2026-11-04','staged',$n$Open item 2: Ben Nov 4 10:29 ET "A for all 8"$n$) RETURNING id INTO bid;
  PERFORM set_config('app.allow_rename','on',true);
  ch:=0;
  FOR r IN SELECT split_part(x,E'\t',1) vid,split_part(x,E'\t',2) oldn,split_part(x,E'\t',3) newn,split_part(x,E'\t',4) src,split_part(x,E'\t',5) url FROM regexp_split_to_table(p,E'\n') x LOOP
    ln:=ln+1;
    INSERT INTO rename_rows (batch_id,line,venue_id,expected_name,new_name,source_id,source_url,verdict,detail)
      SELECT bid,ln,v.id,v.name,r.newn,r.src,r.url,'rename',jsonb_build_object('live_name',v.name,'city_id',v.city_id) FROM venues v WHERE v.id=r.vid AND v.name=r.oldn;
    GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename row %',r.vid; END IF;
    UPDATE venues SET name=r.newn WHERE id=r.vid AND name=r.oldn; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'rename %',r.vid; END IF;
    DECLARE cs text; os text; ns text := trim(both '-' from regexp_replace(lower(f_unaccent(r.newn)),'[^a-z0-9]+','-','g')); BEGIN
      SELECT city_slug,slug INTO cs,os FROM slugs WHERE property_id='eats' AND venue_id=r.vid AND is_canonical;
      IF ns<>os THEN
        ch:=ch+1;
        UPDATE slugs SET is_canonical=false WHERE property_id='eats' AND venue_id=r.vid AND city_slug=cs AND slug=os AND is_canonical;
        INSERT INTO slugs (property_id,city_slug,slug,venue_id,is_canonical) VALUES ('eats',cs,ns,r.vid,true)
          ON CONFLICT (property_id,city_slug,slug) DO UPDATE SET is_canonical=true WHERE slugs.venue_id=EXCLUDED.venue_id;
        GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'slug %',r.vid; END IF;
      END IF;
    END;
  END LOOP;
  PERFORM set_config('app.allow_rename','off',true);
  UPDATE rename_batches SET status='applied',applied_at=now() WHERE id=bid AND status='staged'; GET DIAGNOSTICS n=ROW_COUNT; IF n<>1 THEN RAISE EXCEPTION 'batch %',n; END IF;
  INSERT INTO source_capture_ledger (publisher,field_type,items,job) VALUES ('michelin','name',76,$j$rename-apply:rename-oad-2026-names-2026-11-04 | Michelin card names, read Nov 4 | Ben Nov 4 10:29 ET "A for all 8"$j$);
  -- POST
  IF ch<>159-same THEN RAISE EXCEPTION 'slug change % same %',ch,same; END IF;
  IF (SELECT count(*) FROM venues)<>11594 OR (SELECT count(*) FROM awards)<>27481 OR (SELECT count(*) FROM price)<>7759 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM slugs)<>13444+ch-flip THEN RAISE EXCEPTION 'slugs after'; END IF;
  IF EXISTS (SELECT 1 FROM venues v LEFT JOIN slugs s ON s.venue_id=v.id AND s.is_canonical GROUP BY v.id HAVING count(s.slug)<>1) THEN RAISE EXCEPTION 'canonical slugs'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id>aud AND table_name='venues' AND action='UPDATE')<>159 THEN RAISE EXCEPTION 'audit venues'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published)<>0 THEN RAISE EXCEPTION 'closed published'; END IF;
  RAISE NOTICE 'done: batch %, renames 159, slug changes %',bid,ch;
END $do$;
COMMIT;
