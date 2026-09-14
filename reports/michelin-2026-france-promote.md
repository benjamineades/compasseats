# Ingest promote - michelin-2026-france

Committed 2026-09-14T17:41:24.702Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 10,907 | 11,258 | 11,258 |
| awards | 21,814 | 22,884 | 22,884 |
| listings | 10,907 | 11,258 | 11,258 |
| slugs | 11,164 | 11,515 | 11,515 |
| city_label_source | 22,098 | 22,800 | 22,800 |
| price | 7,091 | 7,091 | 7,091 |
| source_capture_ledger | 10 | 12 | 12 |

Active venues: 10,527 -> 10,878.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 1070 (expected 1070) |
| venues delta equals new venues | pass | 351 (expected 351) |
| listings delta equals new venues | pass | 351 (expected 351) |
| slugs delta equals new venues | pass | 351 (expected 351) |
| city_label_source delta equals planned labels | pass | 702 (expected 702) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10527 -> 10878 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_b789ba25d1` | Alléno Paris au Pavillon Ledoyen | /paris/alleno-paris-au-pavillon-ledoyen | active | true | 1 |
| `ve_d86ea5a112` | Les Prés d'Eugénie - Michel Guérard | /eugenie-les-bains/les-pres-d-eugenie-michel-guerard | active | true | 1 |
| `ve_5d75d60685` | Pic | /valence/pic | active | true | 1 |
| `ve_e2d533b42f` | Le Petit Nice | /marseille/le-petit-nice | active | true | 1 |
| `ve_58eb328fae` | Maison Ronan Kervarrec | /saint-gregoire/maison-ronan-kervarrec | active | true | 1 |
| `ve_af4dc28acc` | Anne de Bretagne | /la-plaine-sur-mer/anne-de-bretagne | active | true | 1 |
| `ve_b82494c044` | La Table de Christophe Dufossé | /busnes/la-table-de-christophe-dufosse | active | true | 1 |
| `ve_0a7f48142d` | La Grand'Vigne - Les Sources de Caudalie | /martillac/la-grand-vigne-les-sources-de-caudalie | active | true | 1 |
| `ve_c96836b1c4` | Lalique | /bommes/lalique | active | true | 1 |
| `ve_81828460ed` | Le Corot | /ville-davray/le-corot | active | true | 1 |
| `ve_bd79647760` | L'Abysse Paris | /paris/l-abysse-paris | active | true | 1 |
| `ve_2919265cc2` | Marsan par Hélène Darroze | /paris/marsan-par-helene-darroze | active | true | 1 |
| `ve_4916c6e0b2` | Le Parc Les Crayères | /reims/le-parc-les-crayeres | active | true | 1 |
| `ve_9b6d110137` | La Côte Saint-Jacques | /joigny/la-cote-saint-jacques | active | true | 1 |
| `ve_1eddcacd3f` | La Côte d'Or | /saulieu/la-cote-d-or | active | true | 1 |
| `ve_498900171c` | Serge Vieira | /chaudes-aigues/serge-vieira | active | true | 1 |
| `ve_a70181d6d0` | La Table de Franck Putelat | /carcassonne/la-table-de-franck-putelat | active | true | 1 |
| `ve_2f02c11729` | Bulle d'Osier | /langres/bulle-d-osier | active | true | 1 |
| `ve_f075d9ec6b` | La Table Lionel Giraud | /narbonne/la-table-lionel-giraud | active | true | 1 |
| `ve_2158912eed` | Georges Blanc | /vonnas/georges-blanc | active | true | 1 |
| `ve_5fdfefc4de` | La Pyramide - Maison Henriroux | /vienne/la-pyramide-maison-henriroux | active | true | 1 |
| `ve_74b1f30546` | La Fourchette des Ducs | /obernai/la-fourchette-des-ducs | active | true | 1 |
| `ve_7484f85f6c` | Michel Kayser - Restaurant Alexandre | /garons/michel-kayser-restaurant-alexandre | active | true | 1 |
| `ve_ed0dd9c1b8` | Maison Benoît Vidal | /annecy/maison-benoit-vidal | active | true | 1 |
| `ve_bfc22336fa` | Jean Sulpice | /talloires-montmin/jean-sulpice | active | true | 1 |
| `ve_22e6d1d656` | Maison Aribert | /uriage-les-bains/maison-aribert | active | true | 1 |
| `ve_eb08c02db3` | La Table des Amis | /bonnieux/la-table-des-amis | active | true | 1 |
| `ve_a454ca5300` | René et Maxime Meilleur | /saint-martin-de-belleville/rene-et-maxime-meilleur | active | true | 1 |
| `ve_5f98076100` | Slalom 1850 | /courchevel/slalom-1850 | active | true | 1 |
| `ve_717fb622b1` | Sylvestre Wahid - Les Grandes Alpes | /courchevel/sylvestre-wahid-les-grandes-alpes | active | true | 1 |
| `ve_fefe169e3f` | La Villa Archange | /le-cannet/la-villa-archange | active | true | 1 |
| `ve_e1ed43edfb` | La Chèvre d'Or | /eze/la-chevre-d-or | active | true | 1 |
| `ve_6f79a75ac7` | Nori | /roscoff/nori | active | true | 1 |
| `ve_fce594d895` | La Pomme d'Api | /saint-pol-de-leon/la-pomme-d-api | active | true | 1 |
| `ve_fcbbb5fea3` | Allium | /quimper/allium | active | true | 1 |
| `ve_bedb176ffc` | Ar Men Du | /nevez/ar-men-du | active | true | 1 |
| `ve_2b314d956d` | Rosmadec Le Moulin | /pont-aven/rosmadec-le-moulin | active | true | 1 |
| `ve_14945f94c2` | Louise | /lorient/louise | active | true | 1 |
| `ve_710d93a747` | Avel Vor | /port-louis/avel-vor | active | true | 1 |
| `ve_0271655e90` | L'Inattendu - Domaine de Locguénolé | /kervignac/l-inattendu-domaine-de-locguenole | active | true | 1 |
| `ve_7cd1b354b2` | La Table d'Asten | /binic/la-table-d-asten | active | true | 1 |
| `ve_86e9c792e4` | Aux Pesked | /saint-brieuc/aux-pesked | active | true | 1 |
| `ve_706bad5d06` | La Table - Domaine du Liziec | /vannes/la-table-domaine-du-liziec | active | true | 1 |
| `ve_35e647c8b7` | Pourquoi Pas | /dinard/pourquoi-pas | active | true | 1 |
| `ve_52b78fb850` | La Table Breizh Café | /cancale/la-table-breizh-cafe | active | true | 1 |
| `ve_85259905e9` | Le Mascaret | /blainville-sur-mer/le-mascaret | active | true | 1 |
| `ve_7980a78f38` | La Mare aux Oiseaux | /saint-joachim/la-mare-aux-oiseaux | active | true | 1 |
| `ve_1096f1b2fb` | Auberge du Pont d'Acigné | /noyal-sur-vilaine/auberge-du-pont-d-acigne | active | true | 1 |
| `ve_7d01661f87` | La Table des Pères - Domaine du Château des Pères | /pire-chance/la-table-des-peres-domaine-du-chateau-des-peres | active | true | 1 |
| `ve_a69a8c4631` | Jean-Marc Pérochon | /bretignolles-sur-mer/jean-marc-perochon | active | true | 1 |
| `ve_9b7cb4f253` | Le 1201 - Abbaye de Villeneuve | /les-sorinieres/le-1201-abbaye-de-villeneuve | active | true | 1 |
| `ve_a96edea225` | L'Éveil des Sens | /mayenne/l-eveil-des-sens | active | true | 1 |
| `ve_85c4f6843f` | Le Manoir du Lys | /bagnoles-de-lorne/le-manoir-du-lys | active | true | 1 |
| `ve_08e3248f33` | L'Essentiel | /deauville/l-essentiel | active | true | 1 |
| `ve_867d7b4d39` | La Renaissance | /argentan/la-renaissance | active | true | 1 |
| `ve_ac634c2879` | La Table de la Bergerie | /bellevigne-en-layon/la-table-de-la-bergerie | active | true | 1 |
| `ve_fff66eea74` | G.a. au Manoir de Rétival | /rives-en-seine/g-a-au-manoir-de-retival | active | true | 1 |
| `ve_ebcc8d4578` | L'Auberge de Bagatelle | /le-mans/l-auberge-de-bagatelle | active | true | 1 |
| `ve_5d3f003ebe` | Fontevraud L'Ermitage | /fontevraud-l-abbaye/fontevraud-l-ermitage | active | true | 1 |
| `ve_58158be0ee` | Nacre | /ares/nacre | active | true | 1 |
| `ve_84ca117fa0` | Le Patio | /arcachon/le-patio | active | true | 1 |
| `ve_fbce4227c5` | Haut Bonheur de la Table | /cassel/haut-bonheur-de-la-table | active | true | 1 |
| `ve_f04af7bc98` | Notes | /cognac/notes | active | true | 1 |
| `ve_e352d403af` | La Table d'Aurélien Largeau | /biarritz/la-table-d-aurelien-largeau | active | true | 1 |
| `ve_5ebc491f42` | Les Frères Ibarboure | /bidart/les-freres-ibarboure | active | true | 1 |
| `ve_d13d2ad337` | Auberge du XIIème Siècle | /sache/auberge-du-xiieme-siecle | active | true | 1 |
| `ve_13f898e47e` | Le Panoramique - Domaine de la Corniche | /rolleboise/le-panoramique-domaine-de-la-corniche | active | true | 1 |
| `ve_811a48504e` | La Table de Cédric Béchade - L'Auberge Basque | /saint-pee-sur-nivelle/la-table-de-cedric-bechade-l-auberge-basque | active | true | 1 |
| `ve_8f2886ad43` | La Ribaudière | /bourg-charente/la-ribaudiere | active | true | 1 |
| `ve_7c49618161` | L'Évidence | /montbazon/l-evidence | active | true | 1 |
| `ve_badee09ed6` | Choko Ona | /espelette/choko-ona | active | true | 1 |
| `ve_9b254dc074` | Ruche | /gambais/ruche | active | true | 1 |
| `ve_58d35257a1` | Le Georges | /chartres/le-georges | active | true | 1 |
| `ve_55ec509f11` | Tentazioni | /bordeaux/tentazioni | active | true | 1 |
| `ve_5e7a9dc5e7` | Le Prince Noir - Vivien Durand | /lormont/le-prince-noir-vivien-durand | active | true | 1 |
| `ve_8c3c033108` | La Table d'Hôtes - Le Quatrième Mur | /bordeaux/la-table-d-hotes-le-quatrieme-mur | active | true | 1 |
| `ve_639a7b2bc2` | Lore Ttipia - Auberge Ostape | /bidarray/lore-ttipia-auberge-ostape | active | true | 1 |
| `ve_0db65739c0` | La Grange de Belle-Église | /belle-eglise/la-grange-de-belle-eglise | active | true | 1 |
| `ve_ddc676eae9` | La Promenade - Maison Dallais | /le-petit-pressigny/la-promenade-maison-dallais | active | true | 1 |
| `ve_8cb095c0f7` | Ducasse au Château de Versailles - Le Grand Contrôle | /versailles/ducasse-au-chateau-de-versailles-le-grand-controle | active | true | 1 |
| `ve_73a09cc154` | Les Belles Perdrix de Troplong Mondot | /saint-emilion/les-belles-perdrix-de-troplong-mondot | active | true | 1 |
| `ve_7133cdc8e6` | Le Favori - Les Sources de Cheverny | /cheverny/le-favori-les-sources-de-cheverny | active | true | 1 |
| `ve_a12c5b1fb7` | Le Verbois | /chantilly/le-verbois | active | true | 1 |
| `ve_97306691b9` | Le Faham | /paris/le-faham | active | true | 1 |
| `ve_773380878f` | Agapé | /paris/agape | active | true | 1 |
| `ve_00240eb1cc` | Onor | /paris/onor | active | true | 1 |
| `ve_723ca2744a` | Don Juan II | /paris/don-juan-ii | active | true | 1 |
| `ve_ab17ada0da` | La Grande Table du Plaza Athénée | /paris/la-grande-table-du-plaza-athenee | active | true | 1 |
| `ve_ec8c545179` | Origines Restaurant | /paris/origines-restaurant | active | true | 1 |
| `ve_e9a28201d5` | Gaya par Pierre Gagnaire | /paris/gaya-par-pierre-gagnaire | active | true | 1 |
| `ve_272b952919` | Pilgrim | /paris/pilgrim | active | true | 1 |
| `ve_686637e7f8` | Anona | /paris/anona | active | true | 1 |
| `ve_b554a2f447` | 114 Faubourg | /paris/114-faubourg | active | true | 1 |
| `ve_c2e7915e76` | Espadon | /paris/espadon | active | true | 1 |
| `ve_4bd9166be0` | Pavyllon Paris | /paris/pavyllon-paris | active | true | 1 |
| `ve_bfda4f7b82` | ES | /paris/es | active | true | 1 |
| `ve_ccc6663c1e` | Pantagruel | /paris/pantagruel | active | true | 1 |
| `ve_a769ebf910` | Nakatani | /paris/nakatani | active | true | 1 |
| `ve_274ff23fe9` | Accents Table Bourse | /paris/accents-table-bourse | active | true | 1 |
| `ve_c4e3758532` | MoSuke | /paris/mosuke | active | true | 1 |
| `ve_f2e88193a2` | Anne | /paris/anne | active | true | 1 |
| `ve_715e96bf5c` | Restaurant H | /paris/restaurant-h | active | true | 1 |
| `ve_a006bf5d2a` | Mavrommatis | /paris/mavrommatis | active | true | 1 |
| `ve_60f08e75a5` | FIEF | /paris/fief | active | true | 1 |
| `ve_4d620e6b59` | Amâlia | /paris/amalia | active | true | 1 |
| `ve_530480e9d5` | La Table Mirasol | /mont-de-marsan/la-table-mirasol | active | true | 1 |
| `ve_c0b980dd51` | Villa9Trois | /montreuil/villa9trois | active | true | 1 |
| `ve_a9d1331ee3` | L'Ours | /vincennes/l-ours | active | true | 1 |
| `ve_dd6de25c33` | La Table - Christophe Hay | /ardon/la-table-christophe-hay | active | true | 1 |
| `ve_c5a5babc62` | L'Orangerie | /eugenie-les-bains/l-orangerie | active | true | 1 |
| `ve_847766af1d` | Les Fresques - Château des Vigiers | /monestier/les-fresques-chateau-des-vigiers | active | true | 1 |
| `ve_982b076b5c` | Auberge de la Grive | /trosly-loire/auberge-de-la-grive | active | true | 1 |
| `ve_7690224530` | L'Axel | /fontainebleau/l-axel | active | true | 1 |
| `ve_9f0d1ad221` | Le Vieux Logis | /tremolat/le-vieux-logis | active | true | 1 |
| `ve_8ff9bd1676` | La Table de Courcelles - Château de Courcelles | /courcelles-sur-vesle/la-table-de-courcelles-chateau-de-courcelles | active | true | 1 |
| `ve_498db571e3` | La Table d'Olivier | /brive-la-gaillarde/la-table-d-olivier | active | true | 1 |
| `ve_1d1607deee` | Alcôve | /vinay/alcove | active | true | 1 |
| `ve_eff7af7883` | Les Jardins | /parnac/les-jardins | active | true | 1 |
| `ve_02df2c6453` | La Chapelle - Château Saint-Jean | /montlucon/la-chapelle-chateau-saint-jean | active | true | 1 |
| `ve_e026e7305c` | Stéphane Tournié - Les Jardins de l'Opéra | /toulouse/stephane-tournie-les-jardins-de-l-opera | active | true | 1 |
| `ve_8ee4bd7119` | Le Valucien - Château de Vault-de-Lugny | /vault-de-lugny/le-valucien-chateau-de-vault-de-lugny | active | true | 1 |
| `ve_deb3577cad` | Le Puy Tilleul | /tournemire/le-puy-tilleul | active | true | 1 |
| `ve_a8d013d6f8` | Jean-Claude Leclerc | /clermont-ferrand/jean-claude-leclerc | active | true | 1 |
| `ve_0de37ec32e` | Émilie & Thomas - Moulin de Cambelong | /conques-en-rouergue/emilie-thomas-moulin-de-cambelong | active | true | 1 |
| `ve_62018d91c0` | Vieux Pont | /belcastel/vieux-pont | active | true | 1 |
| `ve_fe807964aa` | Auberge du Pont | /pont-du-chateau/auberge-du-pont | active | true | 1 |
| `ve_f2d0cb884d` | Château de Courban | /courban/chateau-de-courban | active | true | 1 |
| `ve_14db5c0cd0` | Origines | /le-broc/origines | active | true | 1 |
| `ve_96cb98a9cb` | Le Suquet - Sébastien Bras | /laguiole/le-suquet-sebastien-bras | active | true | 1 |
| `ve_86b4ee5895` | Restaurant de la Loire | /pouilly-sous-charlieu/restaurant-de-la-loire | active | true | 1 |
| `ve_16b203f206` | Le K | /montenach/le-k | active | true | 1 |
| `ve_de5b455b8d` | La Table d'Hôtes - La Rôtisserie du Chambertin | /gevrey-chambertin/la-table-d-hotes-la-rotisserie-du-chambertin | active | true | 1 |
| `ve_33ade9911a` | CIBO | /dijon/cibo | active | true | 1 |
| `ve_baeb6ddc61` | L'Aspérule | /dijon/l-asperule | active | true | 1 |
| `ve_3af1c9c454` | Origine | /dijon/origine | active | true | 1 |
| `ve_4c0b7116b1` | La Maison des Cariatides | /dijon/la-maison-des-cariatides | active | true | 1 |
| `ve_dc8cab89a0` | Table de Levernois | /levernois/table-de-levernois | active | true | 1 |
| `ve_200e7ebf47` | Le Haut-Allier | /alleyras/le-haut-allier | active | true | 1 |
| `ve_4ed40dc0b0` | Burnel | /rouvres-en-xaintois/burnel | active | true | 1 |
| `ve_ff4c8e82d3` | L'Écrin de Yohann Chapuis | /tournus/l-ecrin-de-yohann-chapuis | active | true | 1 |
| `ve_4c7373beac` | Auberge de Clochemerle | /vaux-en-beaujolais/auberge-de-clochemerle | active | true | 1 |
| `ve_de604173ec` | Aux Terrasses | /tournus/aux-terrasses | active | true | 1 |
| `ve_c9f9cfcb15` | Granit - La Mécanique des Frères Bonano | /colombieres-sur-orb/granit-la-mecanique-des-freres-bonano | active | true | 1 |
| `ve_0ddc392c48` | La Table de Chaintré | /chaintre/la-table-de-chaintre | active | true | 1 |
| `ve_1d17c69786` | Château Blanchard | /chazelles-sur-lyon/chateau-blanchard | active | true | 1 |
| `ve_b79b0ca1dc` | La Huchette | /replonges/la-huchette | active | true | 1 |
| `ve_d8b313685c` | Château du Mont Joly | /sampans/chateau-du-mont-joly | active | true | 1 |
| `ve_263c700f0e` | La Chaumière | /dole/la-chaumiere | active | true | 1 |
| `ve_8586270760` | Auberge Saint-Walfrid | /sarreguemines/auberge-saint-walfrid | active | true | 1 |
| `ve_340848ef62` | Les Loges | /lyon/les-loges | active | true | 1 |
| `ve_cdb704e14f` | L'Atelier des Augustins | /lyon/l-atelier-des-augustins | active | true | 1 |
| `ve_c78b41d8e1` | Têtedoie | /lyon/tetedoie | active | true | 1 |
| `ve_b0f8f735f9` | Ombellule | /lyon/ombellule | active | true | 1 |
| `ve_8fd685a196` | Burgundy by Matthieu | /lyon/burgundy-by-matthieu | active | true | 1 |
| `ve_72fc73fcb2` | Rustique | /lyon/rustique | active | true | 1 |
| `ve_d0386cbcf1` | Prairial | /lyon/prairial | active | true | 1 |
| `ve_e65c648cd3` | Miraflores | /lyon/miraflores | active | true | 1 |
| `ve_2568ab0329` | Restaurant De Lauzun | /pezenas/restaurant-de-lauzun | active | true | 1 |
| `ve_fa7e7bc757` | L'Almandin | /saint-cyprien/l-almandin | active | true | 1 |
| `ve_ce0df0624a` | Le Saint Hilaire | /saint-hilaire-de-brethmas/le-saint-hilaire | active | true | 1 |
| `ve_eb5e71de2b` | Auberge de Montfleury | /saint-germain/auberge-de-montfleury | active | true | 1 |
| `ve_ed09a4bc74` | Leclère | /montpellier/leclere | active | true | 1 |
| `ve_c7315c4c57` | La Cheneaudière - Le Feuillage | /colroy-la-roche/la-cheneaudiere-le-feuillage | active | true | 1 |
| `ve_20baa603bb` | Le M - Domaine de Montagne | /ventron/le-m-domaine-de-montagne | active | true | 1 |
| `ve_e1b8f417c6` | La Cachette | /valence/la-cachette | active | true | 1 |
| `ve_d914084fdd` | Le Carré d'Alethius | /charmes-sur-rhone/le-carre-d-alethius | active | true | 1 |
| `ve_4ea2e5317e` | Les Cèdres | /granges-les-beaumont/les-cedres | active | true | 1 |
| `ve_a8a773adff` | La Table d'Uzès | /uzes/la-table-d-uzes | active | true | 1 |
| `ve_0d0e52e950` | Cheval Blanc | /lembach/cheval-blanc | active | true | 1 |
| `ve_3e923051b8` | Auberge Frankenbourg | /la-vancelle/auberge-frankenbourg | active | true | 1 |
| `ve_5577f21b5e` | Le Kléber - La Maison Bonnet | /grane/le-kleber-la-maison-bonnet | active | true | 1 |
| `ve_a4307b564b` | Le Bon Accueil | /malbuisson/le-bon-accueil | active | true | 1 |
| `ve_b9c4d47e1d` | Le Colombier | /malataverne/le-colombier | active | true | 1 |
| `ve_8e9d6aca0b` | Le Pot d'Étain | /danjoutin/le-pot-d-etain | active | true | 1 |
| `ve_ef49e460a8` | Thierry Schwartz - Table Naturelle | /obernai/thierry-schwartz-table-naturelle | active | true | 1 |
| `ve_eb4d113496` | Rouge | /nimes/rouge | active | true | 1 |
| `ve_504e71319d` | Le Cèdre de Montcaud | /sabran/le-cedre-de-montcaud | active | true | 1 |
| `ve_58a21c0118` | Ambroisie | /saint-didier-de-la-tour/ambroisie | active | true | 1 |
| `ve_c7e78b66b3` | Restaurant Julien Binz | /ammerschwihr/restaurant-julien-binz | active | true | 1 |
| `ve_0e38b07eaa` | La Table du Gourmet | /riquewihr/la-table-du-gourmet | active | true | 1 |
| `ve_2a7b4c3286` | Jérôme Nutile | /nimes/jerome-nutile | active | true | 1 |
| `ve_6155d4ebdf` | Lavandin - Château Les Oliviers de Salettes | /charols/lavandin-chateau-les-oliviers-de-salettes | active | true | 1 |
| `ve_462397efb6` | L'Étang du Moulin | /bonnetage/l-etang-du-moulin | active | true | 1 |
| `ve_dd7ac25282` | L'Atelier du Peintre | /colmar/l-atelier-du-peintre | active | true | 1 |
| `ve_7c32023958` | La Belle Vie | /saint-hilaire-dozilhan/la-belle-vie | active | true | 1 |
| `ve_b4aba26cad` | Restaurant Girardin | /colmar/restaurant-girardin | active | true | 1 |
| `ve_7dfc2fd4c0` | Le Clair de la Plume | /grignan/le-clair-de-la-plume | active | true | 1 |
| `ve_e0139f93a9` | Le Jardin Secret | /la-wantzenau/le-jardin-secret | active | true | 1 |
| `ve_5ad6ece817` | Guillaume Scheer - Les Plaisirs Gourmands | /strasbourg/guillaume-scheer-les-plaisirs-gourmands | active | true | 1 |
| `ve_38b570073d` | L'Orchidée | /ensisheim/l-orchidee | active | true | 1 |
| `ve_b522cd3fe4` | Lamartine | /le-bourget-du-lac/lamartine | active | true | 1 |
| `ve_5ee7e8ac6f` | Maison Chenet - Entre Vigne et Garrigue | /pujaut/maison-chenet-entre-vigne-et-garrigue | active | true | 1 |
| `ve_3081a1a5ed` | La Table de L'Incomparable | /tresserve/la-table-de-l-incomparable | active | true | 1 |
| `ve_a95f1b5dc0` | Il Cortile | /mulhouse/il-cortile | active | true | 1 |
| `ve_7a88dddaa0` | Le Prieuré | /villeneuve-les-avignon/le-prieure | active | true | 1 |
| `ve_901edaf0f3` | Asterales | /correncon-en-vercors/asterales | active | true | 1 |
| `ve_024de34d8a` | L'Auberge de Lucinges | /lucinges/l-auberge-de-lucinges | active | true | 1 |
| `ve_e5d90efd1c` | L'Oustalet | /gigondas/l-oustalet | active | true | 1 |
| `ve_b99c2cc8b6` | La Table de Tourrel | /saint-remy/la-table-de-tourrel | active | true | 1 |
| `ve_18c21a728c` | L'Aupiho - Domaine de Manville | /les-baux-de-provence/l-aupiho-domaine-de-manville | active | true | 1 |
| `ve_2fe636bc19` | Auberge Saint-Laurent | /sierentz/auberge-saint-laurent | active | true | 1 |
| `ve_a012f5984b` | Le Vivier | /lisle-sur-la-sorgue/le-vivier | active | true | 1 |
| `ve_f06a1d324b` | Kern | /seytroux/kern | active | true | 1 |
| `ve_ef66f6a438` | Vous | /megeve/vous | active | true | 1 |
| `ve_f47ae97c9d` | Mont Blanc Restaurant & Goûter | /hauteluce/mont-blanc-restaurant-gouter | active | true | 1 |
| `ve_f3c2c47766` | Le Goût du Bonheur - La Fenière | /cadenet/le-gout-du-bonheur-la-feniere | active | true | 1 |
| `ve_ef058dd0af` | L'Oursin | /carry-le-rouet/l-oursin | active | true | 1 |
| `ve_1848cf2373` | L'Ekrin by Laurent Azoulay | /meribel/l-ekrin-by-laurent-azoulay | active | true | 1 |
| `ve_ad205f1354` | Le Chabichou by Stéphane Buron | /courchevel/le-chabichou-by-stephane-buron | active | true | 1 |
| `ve_7de9c388b5` | La Table de l'Orangerie - Château de Fonscolombe | /le-puy-sainte-reparade/la-table-de-l-orangerie-chateau-de-fonscolombe | active | true | 1 |
| `ve_34de15a325` | Les Explorateurs - Hôtel Pashmina | /val-thorens/les-explorateurs-hotel-pashmina | active | true | 1 |
| `ve_658c923ff7` | La Bastide Bourrelly - Mathias Dandine | /calas-cabries/la-bastide-bourrelly-mathias-dandine | active | true | 1 |
| `ve_3c4cad0cd7` | La Magdeleine - Mathias Dandine | /gemenos/la-magdeleine-mathias-dandine | active | true | 1 |
| `ve_bfcde1a0a2` | La Table de Nans | /la-ciotat/la-table-de-nans | active | true | 1 |
| `ve_f544fa7119` | Les Oliviers | /bandol/les-oliviers | active | true | 1 |
| `ve_aa9acb4398` | La Bastide de Moustiers | /moustiers-sainte-marie/la-bastide-de-moustiers | active | true | 1 |
| `ve_079fdd67dd` | Bruno | /lorgues/bruno | active | true | 1 |
| `ve_82c2790b4f` | L'Oursin - Hôtel Les Roches | /le-lavandou/l-oursin-hotel-les-roches | active | true | 1 |
| `ve_9f9096f916` | La Palmeraie - Château de Valmer | /la-croix-valmer/la-palmeraie-chateau-de-valmer | active | true | 1 |
| `ve_0cd1dfaac4` | La Terrasse - Cheval Blanc St-Tropez | /saint-tropez/la-terrasse-cheval-blanc-st-tropez | active | true | 1 |
| `ve_b66d3a8849` | Auberge de la Roche | /valdeblore/auberge-de-la-roche | active | true | 1 |
| `ve_9244198304` | Colette | /saint-tropez/colette | active | true | 1 |
| `ve_f3f08b5418` | Bessem | /mandelieu-la-napoule/bessem | active | true | 1 |
| `ve_30d395e57a` | La Table de Pierre | /saint-paul-de-vence/la-table-de-pierre | active | true | 1 |
| `ve_19a1c230ed` | La Passagère - Hôtel Belles Rives | /juan-les-pins/la-passagere-hotel-belles-rives | active | true | 1 |
| `ve_ece2edc5ed` | Les Pêcheurs | /antibes/les-pecheurs | active | true | 1 |
| `ve_e2e5e930de` | Louroc - Hôtel du Cap-Eden-Roc | /antibes/louroc-hotel-du-cap-eden-roc | active | true | 1 |
| `ve_5d5203048a` | Racines - Bruno Cirino | /nice/racines-bruno-cirino | active | true | 1 |
| `ve_29e40b8469` | L'Aromate | /nice/l-aromate | active | true | 1 |
| `ve_3082807bfc` | Épicentre | /nice/epicentre | active | true | 1 |
| `ve_36e40502bf` | Les Agitateurs | /nice/les-agitateurs | active | true | 1 |
| `ve_2f04f32e25` | La Table du Cap Estel | /eze-bord-de-mer/la-table-du-cap-estel | active | true | 1 |
| `ve_d2a1b30b66` | A Casa di Mà | /lumio/a-casa-di-ma | active | true | 1 |
| `ve_074318a102` | La Table de la Ferme | /sartene/la-table-de-la-ferme | active | true | 1 |
| `ve_227e8a30ec` | Finestra by Italo Bassi | /bonifacio/finestra-by-italo-bassi | active | true | 1 |
| `ve_9d02f770e7` | Ti-Coz | /quimper/ti-coz | active | true | 1 |
| `ve_e344faa976` | Le Biniou | /pleneuf-val-andre/le-biniou | active | true | 1 |
| `ve_9f28f5060a` | Le Comptoir Breizh Café | /saint-malo/le-comptoir-breizh-cafe | active | true | 1 |
| `ve_06be0c1b69` | Breizh Café Cancale | /cancale/breizh-cafe-cancale | active | true | 1 |
| `ve_a6766acd63` | Bistrot de la Maison Tiegezh | /guer/bistrot-de-la-maison-tiegezh | active | true | 1 |
| `ve_5c6ad5c2fd` | Bris'Art Culinaire | /la-baule/bris-art-culinaire | active | true | 1 |
| `ve_6b71904f51` | Auberge de l'Abbaye | /hambye/auberge-de-l-abbaye | active | true | 1 |
| `ve_bae62992fc` | Breizh Café Rennes | /rennes/breizh-cafe-rennes | active | true | 1 |
| `ve_bde62e7a69` | OBBO | /nantes/obbo | active | true | 1 |
| `ve_bebe005c0e` | La Mandale | /nantes/la-mandale | active | true | 1 |
| `ve_eef35efadd` | L'Éden | /houlgate/l-eden | active | true | 1 |
| `ve_c75a5edc51` | L'Atelier | /montaigu/l-atelier | active | true | 1 |
| `ve_3192051f0a` | L'Envers du Décor | /les-herbiers/l-envers-du-decor | active | true | 1 |
| `ve_17d83ed8dd` | La P'tite Patte | /cholet/la-p-tite-patte | active | true | 1 |
| `ve_bfac63290c` | La Plage | /audresselles/la-plage | active | true | 1 |
| `ve_a56c14e274` | La Ferme du Vert | /wierre-effroy/la-ferme-du-vert | active | true | 1 |
| `ve_a485b99ef2` | La Clé des Champs | /favieres/la-cle-des-champs | active | true | 1 |
| `ve_37c7b7913d` | Restaurant du Dauphin | /la-ferte-bernard/restaurant-du-dauphin | active | true | 1 |
| `ve_845b42f8ff` | Renée | /dunkirk/renee | active | true | 1 |
| `ve_7c232f585b` | L'Épine | /azay-le-rideau/l-epine | active | true | 1 |
| `ve_615bd4bcea` | Briket' Bistrot | /guethary/briket-bistrot | active | true | 1 |
| `ve_5d45bba949` | Léonie | /biarritz/leonie | active | true | 1 |
| `ve_dad613f8db` | Auberge Le Centre Poitou | /coulombiers/auberge-le-centre-poitou | active | true | 1 |
| `ve_4faf08e515` | Mets Mots | /bordeaux/mets-mots | active | true | 1 |
| `ve_dc7979e080` | Panaille | /bordeaux/panaille | active | true | 1 |
| `ve_bc0b93afad` | Racines by Daniel Gallacher | /bordeaux/racines-by-daniel-gallacher | active | true | 1 |
| `ve_e3cac515f0` | La Table d'Inomoto | /saint-andre-de-cubzac/la-table-d-inomoto | active | true | 1 |
| `ve_f85d893b1c` | Le Gantxo | /guiche/le-gantxo | active | true | 1 |
| `ve_31207beef1` | Ô en Couleur | /oucques/o-en-couleur | active | true | 1 |
| `ve_76c6822c2b` | Le Mana | /saint-andre-lez-lille/le-mana | active | true | 1 |
| `ve_e4758b41c1` | La Croix Blanche | /veuzain-sur-loire/la-croix-blanche | active | true | 1 |
| `ve_caf40c2040` | Balsamique | /wambrechies/balsamique | active | true | 1 |
| `ve_cc5a9434c6` | Art'zain | /irissarry/art-zain | active | true | 1 |
| `ve_532f8fef0e` | La Bistronomie | /angouleme/la-bistronomie | active | true | 1 |
| `ve_e9d3da211d` | Avarum | /fougeres-sur-bievre/avarum | active | true | 1 |
| `ve_087e0523bc` | Domus | /mont-pres-chambord/domus | active | true | 1 |
| `ve_ebd22d2f9f` | Baca'v - Boulogne | /boulogne-billancourt/baca-v-boulogne | active | true | 1 |
| `ve_1c07c73eab` | La Chatellenie | /availles-limouzine/la-chatellenie | active | true | 1 |
| `ve_561d10edfa` | Charnu | /lamorlaye/charnu | active | true | 1 |
| `ve_4210d49d00` | Rosette | /clichy/rosette | active | true | 1 |
| `ve_091d37de68` | Bistrot des Fables | /paris/bistrot-des-fables | active | true | 1 |
| `ve_d0fe4040f5` | Mova | /paris/mova | active | true | 1 |
| `ve_614a065700` | Le Radis Beurre | /paris/le-radis-beurre | active | true | 1 |
| `ve_8e7d1fbc55` | 20 Eiffel | /paris/20-eiffel | active | true | 1 |
| `ve_2144773974` | BRU | /paris/bru | active | true | 1 |
| `ve_d656f14bd5` | Adami | /paris/adami | active | true | 1 |
| `ve_b870a6b377` | Le CasseNoix | /paris/le-cassenoix | active | true | 1 |
| `ve_139c220d06` | Mandoobar | /paris/mandoobar | active | true | 1 |
| `ve_b5e9669bd6` | Kisin | /paris/kisin | active | true | 1 |
| `ve_e805c4ab47` | L'Antre Amis | /paris/l-antre-amis | active | true | 1 |
| `ve_b89103a46d` | Les Canailles Pigalle | /paris/les-canailles-pigalle | active | true | 1 |
| `ve_6f7de5d30a` | Capsule | /paris/capsule | active | true | 1 |
| `ve_c472d1ece9` | Baca'v par Gilles Choukroun | /paris/baca-v-par-gilles-choukroun | active | true | 1 |
| `ve_d13b846fa0` | Jip | /paris/jip | active | true | 1 |
| `ve_67c140d781` | Etchemaite | /larrau/etchemaite | active | true | 1 |
| `ve_9242a150b5` | Bird | /yerres/bird | active | true | 1 |
| `ve_3ad78a0dcb` | Café Louise | /perigueux/cafe-louise | active | true | 1 |
| `ve_87c1d78fbf` | L'Attanum | /saint-yrieix-la-perche/l-attanum | active | true | 1 |
| `ve_bd25d327e9` | Auberge des Aryelets | /aulon/auberge-des-aryelets | active | true | 1 |
| `ve_0fdc7ff0bf` | Le Bouche à Oreille | /tulle/le-bouche-a-oreille | active | true | 1 |
| `ve_7f0158e663` | L'Ô à la Bouche | /cahors/l-o-a-la-bouche | active | true | 1 |
| `ve_69aea017f4` | Bistrot DuPont | /pont-sainte-marie/bistrot-dupont | active | true | 1 |
| `ve_a8ec573dca` | Le Carré de l'Ange | /saint-lizier/le-carre-de-l-ange | active | true | 1 |
| `ve_4a1145bc38` | Bistrot Saveurs | /castres/bistrot-saveurs | active | true | 1 |
| `ve_8ed4c03790` | Colette - Domaine de la Plagnette | /les-salles/colette-domaine-de-la-plagnette | active | true | 1 |
| `ve_9193e23e82` | Aux 3 Capitaines | /malroy/aux-3-capitaines | active | true | 1 |
| `ve_47fe3be084` | La Gabale | /peyre-en-aubrac/la-gabale | active | true | 1 |
| `ve_e90d28d7f1` | Bistrot Lucien | /gevrey-chambertin/bistrot-lucien | active | true | 1 |
| `ve_9f3130295d` | Spica | /dijon/spica | active | true | 1 |
| `ve_d88b8700f0` | L'Évidence | /dijon/l-evidence | active | true | 1 |
| `ve_52cbdbceef` | L'Alicanta | /le-rozier/l-alicanta | active | true | 1 |
| `ve_17e3795c53` | Hostellerie d'Héloïse | /cluny/hostellerie-d-heloise | active | true | 1 |
| `ve_f7fda8530f` | Le Bouchon Bourguignon | /tournus/le-bouchon-bourguignon | active | true | 1 |
| `ve_11cafb0937` | L'Abbaye Caladoise | /villefranche-sur-saone/l-abbaye-caladoise | active | true | 1 |
| `ve_c139fb95f7` | Bellavista | /prats-de-mollo-la-preste/bellavista | active | true | 1 |
| `ve_05e4608b30` | Le Balcon | /combeaufontaine/le-balcon | active | true | 1 |
| `ve_5a0d60bfdf` | Cave à Vin & à Manger - Maison Saint-Crescent | /narbonne/cave-a-vin-a-manger-maison-saint-crescent | active | true | 1 |
| `ve_f8543180d0` | Agastache | /lyon/agastache | active | true | 1 |
| `ve_8db240d5eb` | La Virée | /lyon/la-viree | active | true | 1 |
| `ve_dea3a938cd` | Lazare Escarguel | /perpignan/lazare-escarguel | active | true | 1 |
| `ve_8d9988540d` | La Meunière | /lyon/la-meuniere | active | true | 1 |
| `ve_3faa32426f` | Danton | /lyon/danton | active | true | 1 |
| `ve_989d6c0045` | Siprès | /lyon/sipres | active | true | 1 |
| `ve_fcbb3edcd2` | Vertfeuille | /arc-et-senans/vertfeuille | active | true | 1 |
| `ve_d1d6794135` | Les Nymphéas | /chasse-sur-rhone/les-nympheas | active | true | 1 |
| `ve_8717a65646` | Bistrot Brioude | /neyrac-les-bains/bistrot-brioude | active | true | 1 |
| `ve_e7c87d0adf` | Le Cottage | /chonas-lamballan/le-cottage | active | true | 1 |
| `ve_07981e680b` | Le Bistronôme | /arbois/le-bistronome | active | true | 1 |
| `ve_b0bc01c9e5` | Le Saisonnier | /roye/le-saisonnier | active | true | 1 |
| `ve_0a19b1d60f` | Julien | /fouday/julien | active | true | 1 |
| `ve_8bc1591959` | Epona | /baix/epona | active | true | 1 |
| `ve_f1623f849b` | La Châtaigneraie - Perle des Vosges | /muhlbach-sur-munster/la-chataigneraie-perle-des-vosges | active | true | 1 |
| `ve_d5841b5c43` | Les Grands Arbres - Verte Vallée | /munster-fr/les-grands-arbres-verte-vallee | active | true | 1 |
| `ve_01fb045ac5` | La Rochette | /labaroche/la-rochette | active | true | 1 |
| `ve_eda4bfb1ca` | Len'K - La Maison Bonnet | /grane/len-k-la-maison-bonnet | active | true | 1 |
| `ve_5dace7ecfd` | La Vieille Forge | /kaysersberg/la-vieille-forge | active | true | 1 |
| `ve_5ab4aa0bc5` | Winstub du Chambard | /kaysersberg/winstub-du-chambard | active | true | 1 |
| `ve_259808cf51` | Le Bistr'AU - Le Mas de Boudan | /nimes/le-bistr-au-le-mas-de-boudan | active | true | 1 |
| `ve_c7295891c6` | L'AO - L'Aigle d'Or | /rimbach-pres-guebwiller/l-ao-l-aigle-d-or | active | true | 1 |
| `ve_32e9314e1a` | Auberge du Pont de la Zorn | /weyersheim/auberge-du-pont-de-la-zorn | active | true | 1 |
| `ve_bf352db59d` | L'Arbre Vert | /berrwiller/l-arbre-vert | active | true | 1 |
| `ve_104670f2a0` | Le Muratore | /evian-les-bains/le-muratore | active | true | 1 |
| `ve_6e32364543` | L'Atelier L'Art des Mets | /taillades/l-atelier-l-art-des-mets | active | true | 1 |
| `ve_32af691419` | La Chartreuse | /le-reposoir/la-chartreuse | active | true | 1 |
| `ve_114fbde327` | Atelier Salone | /salon-de-provence/atelier-salone | active | true | 1 |
| `ve_188998b103` | Le Lodge | /samoens/le-lodge | active | true | 1 |
| `ve_cd702c8e02` | Breizh Café Megève | /megeve/breizh-cafe-megeve | active | true | 1 |
| `ve_ce42cf03c3` | La Table de Pablo | /villars/la-table-de-pablo | active | true | 1 |
| `ve_b2127e43a5` | Simple et Meilleur | /saint-martin-de-belleville/simple-et-meilleur | active | true | 1 |
| `ve_3889ffb4e6` | La Petite Verrière | /le-puy-sainte-reparade/la-petite-verriere | active | true | 1 |
| `ve_6cb8efefd0` | Les Galinas | /aix-en-provence/les-galinas | active | true | 1 |
| `ve_50f4b75193` | Le Pastel | /toulon/le-pastel | active | true | 1 |
| `ve_f1afe62dc9` | La Table | /tourtour/la-table | active | true | 1 |
| `ve_7eb9ed9fbe` | Bistrot des Anges | /le-cannet/bistrot-des-anges | active | true | 1 |
| `ve_4385ea58f7` | L'Alchimie | /nice/l-alchimie | active | true | 1 |
| `ve_57520fbced` | U Licettu | /cuttoli/u-licettu | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-france`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 1070 |
| michelin | city_label | 702 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-france`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-france`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
