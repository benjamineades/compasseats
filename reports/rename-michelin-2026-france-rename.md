# Rename apply - rename-michelin-2026-france

Committed 2026-09-15T03:27:51.622Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-france` |
| CSV | `fixtures/rename/michelin-2026-france-names.csv` |
| rows in the file | 252 |
| renamed | 252 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | French names, Michelin 2026, 252 rows |

## Verdicts

Population: all 252 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 252 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 252 row(s) this batch would rename, read from the database before a single name changed.

252 of the 252 hold at least one award. 5 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_01ff2b098d` | rouen | L'ODAS | L'Odas | michelin 2 | no | /rouen/l-odas |
| `ve_023efa5fc2` | saint-remy | Restaurant Cédric Burtin | Cédric Burtin | michelin 2, la-liste 1 | no | /saint-remy/restaurant-cedric-burtin |
| `ve_0320deb2e1` | saint-langis-les-mortagne | Restaurant "Les Pieds dans l’eau" | Les Pieds Dans l'Eau | michelin 2 | no | /saint-langis-les-mortagne/restaurant-les-pieds-dans-l-eau |
| `ve_03cccc1eff` | chasselay | Restaurant Guy Lassausaie | Guy Lassausaie | michelin 2 | no | /chasselay/restaurant-guy-lassausaie |
| `ve_049080c2ad` | irouleguy | Restaurant Jarapea | Jarapea | michelin 2 | no | /irouleguy/restaurant-jarapea |
| `ve_054f1f59a0` | paris | NHOME | Nhome | michelin 2 | no | /paris/nhome |
| `ve_05c971ee12` | palavas-les-flots | Restaurant Le Saint Georges | Le Saint-Georges | michelin 2 | no | /palavas-les-flots/restaurant-le-saint-georges |
| `ve_082c5146d3` | romorantin-lanthenay | Grand Hôtel du Lion D'Or | Grand Hôtel du Lion d'Or | michelin 2 | no | /romorantin-lanthenay/grand-hotel-du-lion-d-or |
| `ve_0b3b6ae541` | langon | l'Atelier Flavien Valère | L'Atelier Flavien Valère | michelin 2 | no | /langon/l-atelier-flavien-valere |
| `ve_0b86351c11` | rueil-malmaison | Restaurant Ochre | Ochre | michelin 2 | no | /rueil-malmaison/restaurant-ochre |
| `ve_0c4e0915ee` | plomodiern | Auberge des Glazicks | L'Auberge des Glazicks | gault-millau 1, la-liste 1, michelin 1 | no | /plomodiern/auberge-des-glazicks |
| `ve_0cb1664757` | seignosse | Hotel-Restaurant Villa de l'Etang Blanc | Villa de l'Étang Blanc | michelin 2 | no | /seignosse/hotel-restaurant-villa-de-l-etang-blanc |
| `ve_0dbdcc762c` | les-baux-de-provence | Restaurant L'Oustau de Baumanière*** | L'Oustau de Baumanière | best-chef-awards 2, michelin 2, gault-millau 1, la-liste 1 | no | /les-baux-de-provence/restaurant-l-oustau-de-baumaniere |
| `ve_0e67db9894` | montpellier | Jardin Des Sens | Jardin des Sens | michelin 2, worlds-50-best-restaurants 2 | no | /montpellier/jardin-des-sens |
| `ve_0eba909fa4` | chalons-en-champagne | Restaurant Jérôme Feck | Jérôme Feck | michelin 2 | no | /chalons-en-champagne/restaurant-jerome-feck |
| `ve_101f57b1dc` | issigeac | Restaurant L'Atelier | L'Atelier | michelin 2 | no | /issigeac/restaurant-l-atelier |
| `ve_10b8eaf5ef` | charolles | Restaurant Frédéric Doucet | Frédéric Doucet | michelin 2 | no | /charolles/restaurant-frederic-doucet |
| `ve_10e5b8d3d7` | lille | Restaurant PURETÉ | Pureté | michelin 2 | no | /lille/restaurant-purete |
| `ve_11cfd04600` | douvaine | O Flaveurs | Ô Flaveurs | michelin 2 | no | /douvaine/o-flaveurs |
| `ve_120e307eb0` | munster-fr | Restaurant L'Olivier | L'Olivier | michelin 2 | no | /munster-fr/restaurant-l-olivier |
| `ve_13f86693b1` | saint-alban-de-roche | Restaurant l'émulsion | L'Émulsion | michelin 2 | no | /saint-alban-de-roche/restaurant-l-emulsion |
| `ve_152fb62579` | chamonix-mont-blanc | Restaurant Akashon | Akashon | michelin 2 | no | /chamonix-mont-blanc/restaurant-akashon |
| `ve_156553c418` | belleville-en-beaujolais | Restaurant Le Beaujolais | Le Beaujolais | michelin 2 | no | /belleville-en-beaujolais/restaurant-le-beaujolais |
| `ve_1577ca7b7e` | rochefort-en-terre | Restaurant Maison Cachée | Maison Cachée | michelin 2 | no | /rochefort-en-terre/restaurant-maison-cachee |
| `ve_16bdd233b0` | la-wantzenau | Hôtel-Restaurant Le Relais de la Poste | Le Relais de la Poste | michelin 2 | no | /la-wantzenau/hotel-restaurant-le-relais-de-la-poste |
| `ve_1986da12de` | dijon | SO | So | michelin 2 | no | /dijon/so |
| `ve_1990fd1147` | gundershoffen | Restaurant Le Cygne | Le Cygne | michelin 2 | no | /gundershoffen/restaurant-le-cygne |
| `ve_1a6bd9c48e` | nanterre | CABANE | Cabane | michelin 2 | no | /nanterre/cabane |
| `ve_1cc58df978` | saint-nazaire | Restaurant TOPAZE | Topaze | michelin 2 | no | /saint-nazaire/restaurant-topaze |
| `ve_1ced33e109` | saint-malo | FIDELIS | Fidelis | michelin 2 | no | /saint-malo/fidelis |
| `ve_1d45b90d41` | paris | Restaurant Alan Geaam | Alan Geaam | michelin 2 | no | /paris/restaurant-alan-geaam |
| `ve_1e0a5a501f` | courchevel | Restaurant le Farçon | Le Farçon | michelin 2 | no | /courchevel/restaurant-le-farcon |
| `ve_1e4cfc0414` | veyras | LA BÒRIA | La Bòria | michelin 2, gault-millau 1 | no | /veyras/la-boria |
| `ve_1f9d04e96f` | quint-fonsegrives | Restaurant En Pleine Nature | En Pleine Nature | michelin 2 | no | /quint-fonsegrives/restaurant-en-pleine-nature |
| `ve_20ef8a2874` | alvignac | Le Voyage D'Ernestine | Le Voyage d'Ernestine | michelin 2 | no | /alvignac/le-voyage-d-ernestine |
| `ve_21529fc55c` | paris | Neige d'été | Neige d'Été | michelin 2, oad 1 | no | /paris/neige-d-ete |
| `ve_21cd5c1365` | lyon | Restaurant Circle | Circle | michelin 2 | no | /lyon/restaurant-circle |
| `ve_22548593ff` | puylausic | La maison Despouès | La Maison Despouès | michelin 2 | no | /puylausic/la-maison-despoues |
| `ve_2332f48c17` | lyon | Restaurant Paul Bocuse | Paul Bocuse | worlds-50-best-restaurants 3, michelin 2, gault-millau 1, la-liste 1 | no | /lyon/restaurant-paul-bocuse |
| `ve_238989dcec` | ventabren | Restaurant Dan B. | Dan B. | michelin 2 | no | /ventabren/restaurant-dan-b |
| `ve_25fc60c8fe` | saintes | Restaurant l'IØDE | L'IØDE | michelin 2 | no | /saintes/restaurant-l-i-de |
| `ve_27bf87983c` | ecouviez | Les Epices Curiens | Les Épices Curiens | michelin 2 | no | /ecouviez/les-epices-curiens |
| `ve_2a8ec4ed1a` | paris | Episodes | Épisodes | michelin 2 | no | /paris/episodes |
| `ve_2b515ada6c` | puymoyen | AUMI | Aumì | michelin 2 | no | /puymoyen/aumi |
| `ve_2cd490ae81` | angers | LAIT THYM SEL | Lait Thym Sel | michelin 2 | no | /angers/lait-thym-sel |
| `ve_2dca11e0ed` | marcoles | OXALIS | Oxalis | michelin 2 | no | /marcoles/oxalis |
| `ve_2e985904ad` | paris | Fleur de pavé | Fleur de Pavé | michelin 2, oad 1 | no | /paris/fleur-de-pave |
| `ve_2f2b83b250` | malling | Restaurant Alexis Baudin | Alexis Baudin | michelin 2 | no | /malling/restaurant-alexis-baudin |
| `ve_305db3beb3` | baerenthal | l'Arnsbourg | L'Arnsbourg | michelin 2 | no | /baerenthal/l-arnsbourg |
| `ve_307af7ab89` | nieul | La Chapelle Saint Martin | La Chapelle Saint-Martin | michelin 2 | no | /nieul/la-chapelle-saint-martin |
| `ve_31fc6f58b0` | chassy | Jk Restaurant | JK Restaurant | michelin 2 | no | /chassy/jk-restaurant |
| `ve_33a1b4d4fc` | paris | JIN | Jin | michelin 2, oad 1 | no | /paris/jin |
| `ve_35ccab770a` | angers | L' Ardoise | L'Ardoise | michelin 2 | no | /angers/l-ardoise |
| `ve_35d4ecca12` | annecy | Le Clos Des Sens | Le Clos des Sens | gault-millau 3, michelin 2, la-liste 1 | yes | /annecy/le-clos-des-sens |
| `ve_3755ee4117` | steige | Auberge chez Guth | Auberge Chez Guth | michelin 2 | no | /steige/auberge-chez-guth |
| `ve_379053fb48` | bordeaux | Restaurant Madame B | Madame B | michelin 2 | no | /bordeaux/restaurant-madame-b |
| `ve_384b63bd3a` | tarbes | L'empreinte | L'Empreinte | michelin 2 | no | /tarbes/l-empreinte |
| `ve_38a2036e3d` | cairanne | Côteaux et Fourchettes | Coteaux et Fourchettes | michelin 2 | no | /cairanne/coteaux-et-fourchettes |
| `ve_38c864a72f` | paris | Table de MEE | La Table de Mee | michelin 2 | no | /paris/table-de-mee |
| `ve_39ac1adc6c` | porto-vecchio | Hôtel Casadelmar | Casadelmar | michelin 2, la-liste 1 | no | /porto-vecchio/hotel-casadelmar |
| `ve_3b1fb8d8f2` | beaufort | Les 9 Névés | Les 9 névés | michelin 2 | no | /beaufort/les-9-neves |
| `ve_3c84380295` | nice | Olive&Artichaut | Olive & Artichaut | michelin 2 | no | /nice/olive-artichaut |
| `ve_3cb99fd3d6` | bordeaux | Restaurant Soléna | Soléna | michelin 2, gault-millau 1 | no | /bordeaux/restaurant-solena |
| `ve_3d9ae68450` | strasbourg | Restaurant Au Pont Corbeau | Au Pont Corbeau | michelin 2 | no | /strasbourg/restaurant-au-pont-corbeau |
| `ve_40366c0dda` | malataverne | Restaurant Le Bistrot 270 | Le Bistrot 270 | michelin 2 | no | /malataverne/restaurant-le-bistrot-270 |
| `ve_41ab1bd7bd` | curis-au-mont-dor | L'épicurieux chez Luc | L'Épicurieux chez Luc | michelin 2 | no | /curis-au-mont-dor/l-epicurieux-chez-luc |
| `ve_42a5fc32bc` | avignon | Restaurant Pollen | Pollen | michelin 2 | no | /avignon/restaurant-pollen |
| `ve_47aea93e3a` | boeschepe | Auberge Du Vert Mont | Auberge du Vert Mont | michelin 2, best-chef-awards 1 | no | /boeschepe/auberge-du-vert-mont |
| `ve_4813cef5a6` | hasparren | La Maison De Pierre | La Maison de Pierre | michelin 2 | no | /hasparren/la-maison-de-pierre |
| `ve_488f806834` | massignac | Dyades Au Domaine Des Etangs | Dyades au Domaine des Étangs | michelin 2 | no | /massignac/dyades-au-domaine-des-etangs |
| `ve_48912b20f9` | paris | Restaurant David Toutain | David Toutain | best-chef-awards 2, michelin 2, la-liste 1, oad 1 | no | /paris/restaurant-david-toutain |
| `ve_48fb509454` | saint-bonnet-le-froid | Bistrot La Coulemelle | Bistrot la Coulemelle | michelin 2 | no | /saint-bonnet-le-froid/bistrot-la-coulemelle |
| `ve_493998ebb3` | saint-jean-de-luz | Le Kaiku | Le Kaïku | michelin 2 | no | /saint-jean-de-luz/le-kaiku |
| `ve_4a55e63127` | auray | Restaurant La Chebaudière | La Chebaudière | michelin 2 | no | /auray/restaurant-la-chebaudiere |
| `ve_4b86bdb91b` | saint-robert | Restaurant monsieur Robert | Monsieur Robert | michelin 2 | no | /saint-robert/restaurant-monsieur-robert |
| `ve_4c2452517e` | pont-de-vaux | LE RAISIN | Le Raisin | michelin 2 | no | /pont-de-vaux/le-raisin |
| `ve_4d144afb56` | luneville | Château d'Adomenil | Château d'Adoménil | michelin 2 | no | /luneville/chateau-d-adomenil |
| `ve_4d254317ea` | saint-malo | Saint-Placide | Le Saint Placide | michelin 2 | no | /saint-malo/saint-placide |
| `ve_4e73948e8f` | pezenas | Restaurant Pré Saint Jean | Le Pré Saint Jean | michelin 2 | no | /pezenas/restaurant-pre-saint-jean |
| `ve_4ef700d74a` | brest | Peck & co. | Peck & Co | michelin 2 | no | /brest/peck-co |
| `ve_503267190f` | dieppe | Le Bistrot du Pollet | Bistrot du Pollet | michelin 2 | no | /dieppe/le-bistrot-du-pollet |
| `ve_50f7dc8e41` | bage-le-chatel | La Table Bagésienne | La Table Bâgésienne | michelin 2 | no | /bage-le-chatel/la-table-bagesienne |
| `ve_5185174abe` | honfleur | Restaurant SaQuaNa | SaQuaNa | michelin 2 | no | /honfleur/restaurant-saquana |
| `ve_53f4614426` | toulouse | Restaurant Une Table à Deux | Une Table à Deux | michelin 2 | no | /toulouse/restaurant-une-table-a-deux |
| `ve_540fbdb0db` | chassagne-montrachet | Restaurant Ed.Em | Ed.Em | michelin 2 | no | /chassagne-montrachet/restaurant-ed-em |
| `ve_541100d8fa` | trebeurden | Manoir de Lan Kerellec | Manoir de Lan-Kerellec | michelin 2 | no | /trebeurden/manoir-de-lan-kerellec |
| `ve_54654daa96` | toulouse | AGAPES | Agapes | michelin 2 | no | /toulouse/agapes |
| `ve_55d4d282cc` | chamalieres | Hôtel Radio | Radio | michelin 2 | no | /chamalieres/hotel-radio |
| `ve_5968472196` | chamalieres | LE WELCOME | Le Welcome | michelin 2 | no | /chamalieres/le-welcome |
| `ve_598810e8fe` | paris | Restaurant Divellec | Divellec | michelin 2 | no | /paris/restaurant-divellec |
| `ve_59baf7ce7f` | paris | Epicure | Épicure | michelin 2, best-chef-awards 1, la-liste 1, wine-spectator 1 | yes | /paris/epicure |
| `ve_5a2faf7397` | menton | Restaurant Mirazur | Mirazur | worlds-50-best-restaurants 9, best-chef-awards 2, michelin 2, gault-millau 1, la-liste 1, oad 1 | yes | /menton/restaurant-mirazur |
| `ve_5a67e55a7a` | reims | Hôtel L' Assiette Champenoise | Assiette Champenoise | best-chef-awards 2, michelin 2, gault-millau 1, la-liste 1 | yes | /reims/hotel-l-assiette-champenoise |
| `ve_5ab33e0684` | pont-croix | GLAZ | Glaz | michelin 2 | no | /pont-croix/glaz |
| `ve_5b1ab313d4` | paris | A l'Improviste | À L'Improviste | michelin 2 | no | /paris/a-l-improviste |
| `ve_5b5ae98066` | paris | Restaurant le Meurice Alain Ducasse | Restaurant Le Meurice Alain Ducasse | best-chef-awards 2, gault-millau 2, michelin 2, la-liste 1 | no | /paris/restaurant-le-meurice-alain-ducasse |
| `ve_5c38471ed5` | plougasnou | Restaurant La Maison de Kerdiès | La Maison de Kerdiès | michelin 2 | no | /plougasnou/restaurant-la-maison-de-kerdies |
| `ve_5cb59144d7` | noirmoutier-en-lile | L'Assiette au jardin | L'Assiette au Jardin | michelin 2 | no | /noirmoutier-en-lile/l-assiette-au-jardin |
| `ve_5d0a495512` | rennes | Restaurant La Petite Ourse | La Petite Ourse | michelin 2 | no | /rennes/restaurant-la-petite-ourse |
| `ve_603d4413f2` | collioure | Restaurant La Balette | La Balette | michelin 2 | no | /collioure/restaurant-la-balette |
| `ve_629548d961` | manosque | CHEZ BASTIEN | Chez Bastien | michelin 2 | no | /manosque/chez-bastien |
| `ve_63beffdf34` | pailherols | Auberge des Montagnes | L'Auberge des Montagnes | michelin 2 | no | /pailherols/auberge-des-montagnes |
| `ve_6522e4fb4b` | paris | La Tour d'Argent | Tour d'Argent | michelin 2, wine-spectator 1, worlds-50-best-restaurants 1 | no | /paris/la-tour-d-argent |
| `ve_65591e378b` | saint-tropez | Restaurant Arnaud Donckele & Maxime Frédéric at Louis Vuitton | Arnaud Donckele & Maxime Frédéric at Louis Vuitton | michelin 2 | no | /saint-tropez/restaurant-arnaud-donckele-maxime-frederic-at-louis-vuitton |
| `ve_69934b07bd` | tourrettes | Restaurant Le FAVENTIA | Faventia | michelin 2 | no | /tourrettes/restaurant-le-faventia |
| `ve_6a4bcbfb3b` | plougonvelin | Hostellerie De la Pointe Saint Mathieu | Hostellerie de la Pointe Saint-Mathieu | michelin 2 | no | /plougonvelin/hostellerie-de-la-pointe-saint-mathieu |
| `ve_6a9bd70b49` | vannes | Restaurant Boma | Boma | michelin 2 | no | /vannes/restaurant-boma |
| `ve_6ad9c595f7` | monswiller | Restaurant Kasbur | Kasbür | michelin 2 | no | /monswiller/restaurant-kasbur |
| `ve_6ba1197b41` | beziers | L' ALTER-NATIVE ⭐ | L'Alter-Native | michelin 2 | no | /beziers/l-alter-native |
| `ve_6ba4dc026f` | la-flotte | L'Ecailler | L'Écailler | michelin 2 | no | /la-flotte/l-ecailler |
| `ve_6d59eb76a1` | pontivy | Restaurant Hyacinthe & Robert | Hyacinthe & Robert | michelin 2 | no | /pontivy/restaurant-hyacinthe-robert |
| `ve_6db828084a` | lattes | Temps d'Aime | Le Temps d'Aime | michelin 2 | no | /lattes/temps-d-aime |
| `ve_6ecf974e14` | saint-malo | La fourchette à droite | La Fourchette à Droite | michelin 2 | no | /saint-malo/la-fourchette-a-droite |
| `ve_71187198ea` | biarritz | Ahpe | AHPĒ | michelin 2 | no | /biarritz/ahpe |
| `ve_726a22f45a` | lyon | RESTAURANT Takao Takano | Takao Takano | michelin 2, la-liste 1 | no | /lyon/restaurant-takao-takano |
| `ve_72bc10551e` | cannes | Restaurant La Palme d'Or | La Palme d'Or | michelin 2 | no | /cannes/restaurant-la-palme-d-or |
| `ve_74cd6eb343` | trebeurden | VIVACE | Vivace | michelin 2 | no | /trebeurden/vivace |
| `ve_76c4bce6a9` | flayosc | Le Jardin De Berne | Le Jardin de Berne | michelin 2 | no | /flayosc/le-jardin-de-berne |
| `ve_76d0e682fb` | lyon | Restaurant Bergamote | Bergamote | michelin 2 | no | /lyon/restaurant-bergamote |
| `ve_76f8401643` | lalbenc | BISTROT LOUISE | Bistrot Louise | michelin 2 | no | /lalbenc/bistrot-louise |
| `ve_78e2ebdb64` | nantes | Le Manoir De La Régate | Le Manoir de la Régate | best-chef-awards 2, michelin 2, gault-millau 1 | no | /nantes/le-manoir-de-la-regate |
| `ve_7c2090b77f` | valloux | Auberge des Chenêts | Auberge des Chenets | michelin 2 | no | /valloux/auberge-des-chenets |
| `ve_7c2f54f0ab` | paris | Restaurant Akrame | Akrame | michelin 2, la-liste 1 | no | /paris/restaurant-akrame |
| `ve_7c32575d62` | deauville | Restaurant Maximin Hellio | Maximin Hellio | michelin 2 | no | /deauville/restaurant-maximin-hellio |
| `ve_7e93feef0e` | chaudes-aigues | Hôtel & Restaurant Sodade | Sodade | michelin 2 | no | /chaudes-aigues/hotel-restaurant-sodade |
| `ve_8123692ae2` | saint-genis-laval | l'Etape Dorée | L'Étape Dorée | michelin 2 | no | /saint-genis-laval/l-etape-doree |
| `ve_8294ea6255` | carhaix-plouguer | Restaurant Erasmo | Erasmo | michelin 2 | no | /carhaix-plouguer/restaurant-erasmo |
| `ve_829f7fd32b` | paris | Restaurant Omar Dhiab | Omar Dhiab | michelin 2, oad 1 | no | /paris/restaurant-omar-dhiab |
| `ve_8457b128d6` | beaune | Restaurant Le Carmin | Le Carmin | michelin 2 | no | /beaune/restaurant-le-carmin |
| `ve_846788b091` | reims | ARBANE | Arbane | michelin 2, gault-millau 1 | no | /reims/arbane |
| `ve_8484ecb3b0` | toulouse | L' Air de Famille | L'Air de Famille | michelin 2 | no | /toulouse/l-air-de-famille |
| `ve_867311bd99` | mareuil-sur-lay-dissais | Restaurant Maison Desamy | Maison Desamy | michelin 2 | no | /mareuil-sur-lay-dissais/restaurant-maison-desamy |
| `ve_87ca1da3d6` | espaly-saint-marcel | restaurant l'Ermitage | L'Ermitage | michelin 2 | no | /espaly-saint-marcel/restaurant-l-ermitage |
| `ve_8859261736` | magescq | Relais De La Poste | Relais de la Poste | michelin 2, la-liste 1 | no | /magescq/relais-de-la-poste |
| `ve_890ec43950` | marcq-en-bar-ul | ROZO | Rozó | michelin 2, gault-millau 1, la-liste 1 | no | /marcq-en-bar-ul/rozo |
| `ve_8976cb64df` | nancy | La _ Maison dans le Parc | La Maison dans le Parc | michelin 2 | no | /nancy/la-maison-dans-le-parc |
| `ve_8b0411fd68` | saint-medard | Restaurant Le Gindreau | Le Gindreau | michelin 2 | no | /saint-medard/restaurant-le-gindreau |
| `ve_8c25148528` | kaysersberg | L'Alchémille | Alchémille | michelin 2 | no | /kaysersberg/l-alchemille |
| `ve_8c4a5d6040` | beaulieu-sous-la-roche | Restaurant Le Café des Arts | Le Café des Arts | michelin 2 | no | /beaulieu-sous-la-roche/restaurant-le-cafe-des-arts |
| `ve_8d0beae410` | la-vacquerie-et-saint-martin-de-castries | Restaurant l'ogustin | L'Ogustin | michelin 2 | no | /la-vacquerie-et-saint-martin-de-castries/restaurant-l-ogustin |
| `ve_8e0adfebb4` | nantes | Restaurant Omija | Omija | michelin 2 | no | /nantes/restaurant-omija |
| `ve_900c668573` | notre-dame-de-bellecombe | Restaurant La Ferme de Victorine | La Ferme de Victorine | michelin 2 | no | /notre-dame-de-bellecombe/restaurant-la-ferme-de-victorine |
| `ve_9282ea441c` | colombey-les-deux-eglises | Hostellerie La Montagne | Hostellerie la Montagne | michelin 2 | no | /colombey-les-deux-eglises/hostellerie-la-montagne |
| `ve_95f52c5e5a` | laubach | Restaurant La Merise | La Merise | michelin 2, la-liste 1 | no | /laubach/restaurant-la-merise |
| `ve_974d97d7f9` | paris | Restaurant Frederic Simonin | Frédéric Simonin | michelin 2 | no | /paris/restaurant-frederic-simonin |
| `ve_9a31afe9f5` | chamonix-mont-blanc | Restaurant Albert 1er | Albert 1er | michelin 2 | no | /chamonix-mont-blanc/restaurant-albert-1er |
| `ve_9aa71bbec8` | barbentane | Restaurant Ineffable | Ineffable | michelin 2 | no | /barbentane/restaurant-ineffable |
| `ve_9b272faa8a` | paris | Restaurant Trente-Trois | Trente-Trois | michelin 2 | no | /paris/restaurant-trente-trois |
| `ve_9c40a9dbe3` | bagneres-de-bigorre | Restaurant La Table du Cinq | La Table du Cinq | michelin 2 | no | /bagneres-de-bigorre/restaurant-la-table-du-cinq |
| `ve_9c646fdf2a` | biot | Restaurant Les Terraillers | Les Terraillers | michelin 2 | no | /biot/restaurant-les-terraillers |
| `ve_9d0c701035` | payrin-augmontel | VILLA PINEWOOD | Villa Pinewood | michelin 2 | no | /payrin-augmontel/villa-pinewood |
| `ve_9e18c5ab0b` | floressas | Restaurant Holodeck | Holodeck | michelin 2 | no | /floressas/restaurant-holodeck |
| `ve_9e5a1fe04b` | peyre-en-aubrac | Restaurant Cyril Attrazic | Cyril Attrazic | michelin 2, best-chef-awards 1, la-liste 1 | no | /peyre-en-aubrac/restaurant-cyril-attrazic |
| `ve_9e77c9e379` | saint-jean-de-blaignac | Auberge Saint Jean | L'Auberge Saint Jean | michelin 2 | no | /saint-jean-de-blaignac/auberge-saint-jean |
| `ve_9fd9ef0dbb` | biarritz | Restaurant L'Impertinent | L'Impertinent | michelin 2 | no | /biarritz/restaurant-l-impertinent |
| `ve_a4aa7cb9ba` | vailly | Restaurant Frédéric Molina à Forêt Ivre | Frédéric Molina à Forêt Ivre | best-chef-awards 2, michelin 2 | no | /vailly/restaurant-frederic-molina-a-foret-ivre |
| `ve_a54bfe1aef` | paris | NOMICOS | Nomicos | michelin 2 | no | /paris/nomicos |
| `ve_a55d6b03c5` | argeles-gazost | Au Fond Du Gosier | Au Fond du Gosier | michelin 2 | no | /argeles-gazost/au-fond-du-gosier |
| `ve_a58543d5a3` | alby-sur-cheran | Restaurant Le Bourgeon | Le Bourgeon | michelin 2 | no | /alby-sur-cheran/restaurant-le-bourgeon |
| `ve_a6069ae1c4` | blois | ASSA | Assa | michelin 2 | no | /blois/assa |
| `ve_a654b345f2` | beziers | Pica-Pica | Pica Pica | michelin 2 | no | /beziers/pica-pica |
| `ve_a6861367dd` | barneville-carteret | Hôtel des Isles | Le Restaurant des Isles | michelin 2 | no | /barneville-carteret/hotel-des-isles |
| `ve_a71d3afafa` | ouistreham | La table d'hôtes | La Table d'Hôtes | michelin 2 | no | /ouistreham/la-table-d-hotes |
| `ve_a74e9ee3a3` | saint-omer | Restaurant Bacôve | Bacôve | michelin 2 | no | /saint-omer/restaurant-bacove |
| `ve_a7e2024015` | paris | Qui plume la lune | Qui Plume la Lune | michelin 2 | no | /paris/qui-plume-la-lune |
| `ve_a8213a9418` | strasbourg | Restaurant DEJA | de:ja | michelin 2 | no | /strasbourg/restaurant-deja |
| `ve_a86b721c0e` | montanges | Auberge du pont des pierres | L'Auberge du Pont des Pierres | michelin 2 | no | /montanges/auberge-du-pont-des-pierres |
| `ve_a960a3181f` | le-coteau | L’Atelier Locavore | L'Atelier Locavore | michelin 2 | no | /le-coteau/l-atelier-locavore |
| `ve_aa7b4e7c78` | sancerre | Restaurant La Pomme d'Or | La Pomme d'Or | michelin 2 | no | /sancerre/restaurant-la-pomme-d-or |
| `ve_aa93720dd2` | lyon | Restaurant Accentué | Accentué | michelin 2 | no | /lyon/restaurant-accentue |
| `ve_aab4a0fb96` | bracieux | Le Rendez-vous Des Gourmets | Le Rendez-vous des Gourmets | michelin 2 | no | /bracieux/le-rendez-vous-des-gourmets |
| `ve_ab0d143fef` | naucelle | L’Obélias | L'Obélias | michelin 2 | no | /naucelle/l-obelias |
| `ve_ade26d34b5` | paris | Sushi-B | Sushi B | michelin 2, oad 1 | no | /paris/sushi-b |
| `ve_b2691cae1e` | le-villars | Auberge des Gourmets | L'Auberge des Gourmets | michelin 2 | no | /le-villars/auberge-des-gourmets |
| `ve_b279522a5e` | machilly | REFUGE DES GOURMETS | Le Refuge des Gourmets | michelin 2 | no | /machilly/refuge-des-gourmets |
| `ve_b2c8a6b932` | boudes | Restaurant "Le Boudes La Vigne" | Le Boudes La Vigne | michelin 2 | no | /boudes/restaurant-le-boudes-la-vigne |
| `ve_b4398b9cc3` | calais | HISTOIRE ANCIENNE | Histoire Ancienne | michelin 2 | no | /calais/histoire-ancienne |
| `ve_b45598fed5` | olmeto | La Verriere | La Verrière | michelin 2 | no | /olmeto/la-verriere |
| `ve_b4babd7276` | la-colle-sur-loup | Restaurant @ Alain llorca | Alain Llorca | michelin 2 | no | /la-colle-sur-loup/restaurant-alain-llorca |
| `ve_b4e1d36194` | toulon | Restaurant Le Saint Gabriel | Le Saint Gabriel | michelin 2 | no | /toulon/restaurant-le-saint-gabriel |
| `ve_b56c9cc152` | correncon-en-vercors | Palégrié chez l'Henri | Palégrié Chez l'Henri | michelin 2, oad 1 | no | /correncon-en-vercors/palegrie-chez-l-henri |
| `ve_b6574b3362` | montcy-notre-dame | l'auberge du laminak | L'Auberge du Laminak | michelin 2 | no | /montcy-notre-dame/l-auberge-du-laminak |
| `ve_b93b8941db` | jongieux | Restaurant Les Morainières | Les Morainières | michelin 2, la-liste 1 | no | /jongieux/restaurant-les-morainieres |
| `ve_b9609849ac` | moirax | L'Auberge le Prieuré | Auberge Le Prieuré | michelin 2 | no | /moirax/l-auberge-le-prieure |
| `ve_ba565e3a5e` | saint-denis-doleron | Jour Du Poisson | Le Jour du Poisson | michelin 2 | no | /saint-denis-doleron/jour-du-poisson |
| `ve_baeae630ab` | paris | Jules Verne | Le Jules Verne | michelin 2, la-liste 1 | no | /paris/jules-verne |
| `ve_bbb2e26803` | la-roche-sur-yon | Restaurant les Reflets | Les Reflets | michelin 2 | no | /la-roche-sur-yon/restaurant-les-reflets |
| `ve_be3607ecc5` | veuil | Auberge Saint-Fiacre | Auberge Saint Fiacre | michelin 2 | no | /veuil/auberge-saint-fiacre |
| `ve_be663c0406` | dole | Restaurant Grain de Sel | Grain de Sel | michelin 2 | no | /dole/restaurant-grain-de-sel |
| `ve_c01f73b4c9` | pau | jumo&co | Jumo & Co | michelin 2 | no | /pau/jumo-co |
| `ve_c0a013f8c2` | marseille | Une Table au Sud | Une Table, au Sud | michelin 2, gault-millau 1 | no | /marseille/une-table-au-sud |
| `ve_c199298031` | montrouge | Restaurant Farouche | Farouche | michelin 2 | no | /montrouge/restaurant-farouche |
| `ve_c1ed640f1b` | senas | LE BON TEMPS | Le Bon Temps | michelin 2 | no | /senas/le-bon-temps |
| `ve_c240b986ce` | courchevel | Restaurant L'Altitude* | L'Altitude | michelin 2 | no | /courchevel/restaurant-l-altitude |
| `ve_c29125ac38` | guer | Hôtel Restaurant Maison Tiegezh | Maison Tiegezh | michelin 3, gault-millau 1 | no | /guer/hotel-restaurant-maison-tiegezh |
| `ve_c41cfe5100` | vaudevant | LA RECRE | La Récré | michelin 2 | no | /vaudevant/la-recre |
| `ve_c4d2d655db` | lavalette | L'Auberge de la Forge | Auberge de la Forge | michelin 2 | no | /lavalette/l-auberge-de-la-forge |
| `ve_c5a935d49e` | nice | Restaurant Chez Davia | Chez Davia | michelin 2 | no | /nice/restaurant-chez-davia |
| `ve_c5c9e9cfed` | sailly-sur-la-lys | Restaurant La Conciergerie | La Conciergerie | michelin 2 | no | /sailly-sur-la-lys/restaurant-la-conciergerie |
| `ve_c9006ee0d1` | bordeaux | Restaurant Kedem | Kedem | michelin 2 | no | /bordeaux/restaurant-kedem |
| `ve_c9111fcc21` | marcq-en-bar-ul | Repu | Rēpu | michelin 2 | no | /marcq-en-bar-ul/repu |
| `ve_cb6c037c7c` | vannes | Restaurant La Tête en l'air | La Tête en l'air | michelin 2 | no | /vannes/restaurant-la-tete-en-l-air |
| `ve_cbb2a08129` | montpellier | L'artichaut | L'Artichaut | michelin 2 | no | /montpellier/l-artichaut |
| `ve_cc226ff607` | saint-etienne-du-vauvray | La ferme de la Haute Crémonville | La Ferme de la Haute Crémonville | michelin 2 | no | /saint-etienne-du-vauvray/la-ferme-de-la-haute-cremonville |
| `ve_cc24331b57` | strasbourg | Restaurant 1741 | 1741 | michelin 2 | no | /strasbourg/restaurant-1741 |
| `ve_ccea7da354` | sainte-foy-la-grande | Restaurant Côté Bastide | Côté Bastide | michelin 2 | no | /sainte-foy-la-grande/restaurant-cote-bastide |
| `ve_cdbc14778f` | ingersheim | Taverne Alsacienne | La Taverne Alsacienne | michelin 2 | no | /ingersheim/taverne-alsacienne |
| `ve_d1b2803295` | saint-lo | INTUITION | Intuition | michelin 2 | no | /saint-lo/intuition |
| `ve_d2820ac4f5` | lyon | La Mère Brazier | Mère Brazier | la-liste 1, michelin 1 | no | /lyon/la-mere-brazier |
| `ve_d2e2276a25` | annecy | Anto | ANTO | michelin 2 | no | /annecy/anto |
| `ve_d472175bc2` | beziers | Calice ⭐ | Calice | michelin 2 | no | /beziers/calice |
| `ve_d491fe827c` | pontoise | L'Or Q'Idée | L'Or Q'idée | michelin 2 | no | /pontoise/l-or-q-idee |
| `ve_d4a55fa97b` | annecy | COZNA | Cozna | michelin 2 | no | /annecy/cozna |
| `ve_d6372fa061` | saint-ave | Restaurant Le Pressoir | Le Pressoir | michelin 2 | no | /saint-ave/restaurant-le-pressoir |
| `ve_d688622905` | lyon | Le Cochon Qui Boit | Le Cochon qui Boit | michelin 2 | no | /lyon/le-cochon-qui-boit |
| `ve_d6a5b3bf3b` | sierentz | Winstub À Côté... | Winstub À Côté | michelin 2 | no | /sierentz/winstub-a-cote |
| `ve_d6cfed208f` | chassy | Restaurant ERRE | Erre | michelin 2 | no | /chassy/restaurant-erre |
| `ve_d6d6aa4c8d` | nimes | DUENDE | Duende | michelin 2, la-liste 1 | no | /nimes/duende |
| `ve_d715e3118a` | saint-martin-du-tertre | le Martin Bel Air | Le Martin Bel Air | michelin 2 | no | /saint-martin-du-tertre/le-martin-bel-air |
| `ve_d8f2845af8` | bry | Restaurant Le Camélia | Le Camélia | michelin 2 | no | /bry/restaurant-le-camelia |
| `ve_dec741f3ba` | pujaudran | Le Puits Saint-Jacques | Le Puits Saint Jacques | michelin 2 | no | /pujaudran/le-puits-saint-jacques |
| `ve_dfdfc1808c` | uriage-les-bains | CAFÉ A | Café A | michelin 2 | no | /uriage-les-bains/cafe-a |
| `ve_e02e3a30a6` | paris | Ortensia | Ōrtensia | michelin 2 | no | /paris/ortensia |
| `ve_e4010e1996` | santenay | Hôtel-Restaurant l'Ouillette | L'Ouillette | michelin 2 | no | /santenay/hotel-restaurant-l-ouillette |
| `ve_e643c85d2a` | courchevel | Restaurant Alpage | Alpage | michelin 2 | no | /courchevel/restaurant-alpage |
| `ve_e75d63b3fb` | amboise | Restaurant Les Arpents | Les Arpents | michelin 2 | no | /amboise/restaurant-les-arpents |
| `ve_e7707fd2c5` | santa-reparata-di-balagna | L'AGHJALLE | L'Aghjalle | michelin 2 | no | /santa-reparata-di-balagna/l-aghjalle |
| `ve_e7a099765d` | auzouville-sur-saane | Auberge de la Mère Duval | Auberge de La Mère Duval | michelin 2 | no | /auzouville-sur-saane/auberge-de-la-mere-duval |
| `ve_e83ea265c3` | lyon | Restaurant Le Kitchen | Le Kitchen | michelin 2 | no | /lyon/restaurant-le-kitchen |
| `ve_e998bbe81d` | bouliac | Hôtel & Restaurant Le Saint-James | Le Saint-James | michelin 2 | no | /bouliac/hotel-restaurant-le-saint-james |
| `ve_ebba65aabe` | la-haye | Le Petit Nor’Cat | Le Petit Nor'Cat | michelin 2 | no | /la-haye/le-petit-nor-cat |
| `ve_ebd63723cc` | toulouse | Restaurant Michel Sarran | Michel Sarran | michelin 2 | no | /toulouse/restaurant-michel-sarran |
| `ve_ede8b18173` | saint-pierre-doleron | Restaurant Sillage | Sillage | michelin 2 | no | /saint-pierre-doleron/restaurant-sillage |
| `ve_eeded0c3ef` | paris | Restaurant Kei | Kei | best-chef-awards 2, michelin 2, la-liste 1 | no | /paris/restaurant-kei |
| `ve_ef57492a00` | tignes | Restaurant URSUS | Ursus | michelin 2 | no | /tignes/restaurant-ursus |
| `ve_f04dc487c2` | la-teste-de-buch | l'Aillet | L'Aillet | michelin 2 | no | /la-teste-de-buch/l-aillet |
| `ve_f259061491` | briancon | Au plaisir ambré | Au Plaisir Ambré | michelin 2 | no | /briancon/au-plaisir-ambre |
| `ve_f49862e401` | ecully | Restaurant Saisons | Saisons | michelin 2 | no | /ecully/restaurant-saisons |
| `ve_f6015d7ea0` | agen | La Table De Michel Dussau | La Table de Michel Dussau | michelin 2 | no | /agen/la-table-de-michel-dussau |
| `ve_f667ce2a30` | nimes | Restaurant Skab | Skab | michelin 2 | no | /nimes/restaurant-skab |
| `ve_f6fce4aa8d` | barr | ENFIN | Enfin | michelin 2 | no | /barr/enfin |
| `ve_f74a315a56` | ainhoa | Restaurant Ithurria | Ithurria | michelin 2 | no | /ainhoa/restaurant-ithurria |
| `ve_f7569cf3a6` | marseille | PROSPER | Prosper | michelin 2 | no | /marseille/prosper |
| `ve_f952760b96` | bordeaux | Le Cent 33 | Cent33 | michelin 2 | no | /bordeaux/le-cent-33 |
| `ve_f95e4099ce` | lyon | Le zeste gourmand | Le Zeste Gourmand | michelin 2 | no | /lyon/le-zeste-gourmand |
| `ve_f9e34945bd` | strasbourg | Restaurant Umami | Umami | michelin 2 | no | /strasbourg/restaurant-umami |
| `ve_fb7c6d6400` | le-castellet | La Table du Castellet*** | La Table du Castellet | michelin 2, best-chef-awards 1, gault-millau 1, la-liste 1 | yes | /le-castellet/la-table-du-castellet |
| `ve_fc320835af` | joucas | La Table de Xavier MATHIEU | La Table de Xavier Mathieu | michelin 2 | no | /joucas/la-table-de-xavier-mathieu |
| `ve_fd036675b1` | puy-en-velay | L'émotion | L'Émotion | michelin 2 | no | /puy-en-velay/l-emotion |
| `ve_fd4687ea75` | paris | Restaurant OXTE | Oxte | michelin 2 | no | /paris/restaurant-oxte |
| `ve_fd6cd0318d` | baden | Restaurant Le Gavrinis | Le Gavrinis | michelin 2 | no | /baden/restaurant-le-gavrinis |
| `ve_feac5d24f0` | colmar | JY's | JY'S | michelin 2, la-liste 1 | no | /colmar/jy-s |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 252 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,258 | 11,258 | 11,258 |
| awards | 22,884 | 22,884 | 22,884 |
| slugs | 11,515 | 11,515 | 11,515 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 12 | 13 | 13 |
| rename_batches | 0 | 1 | 1 |
| rename_rows | 0 | 252 | 252 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 252 (expected 252) |
| every renamed venue's live name is its new_name | pass | 0 of 252 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 252 (expected 252) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 252 name changes (expected 252), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 252 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_01ff2b098d` | L'ODAS | L'Odas | michelin | https://guide.michelin.com/en/normandie/rouen/restaurant/l-odas |
| `ve_023efa5fc2` | Restaurant Cédric Burtin | Cédric Burtin | michelin | https://guide.michelin.com/en/bourgogne-franche-comte/saint-rmy/restaurant/cedric-burtin |
| `ve_0320deb2e1` | Restaurant "Les Pieds dans l’eau" | Les Pieds Dans l'Eau | michelin | https://guide.michelin.com/en/normandie/saint-langis-les-mortagne/restaurant/les-pieds-dans-l-eau |
| `ve_03cccc1eff` | Restaurant Guy Lassausaie | Guy Lassausaie | michelin | https://guide.michelin.com/en/auvergne-rhone-alpes/chasselay/restaurant/guy-lassausaie |
| `ve_049080c2ad` | Restaurant Jarapea | Jarapea | michelin | https://guide.michelin.com/en/nouvelle-aquitaine/irouleguy/restaurant/jarapea |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-france`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 252 |

Spellings followed: michelin (252).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2026-france`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2026-france`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
