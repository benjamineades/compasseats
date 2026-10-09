# Rename apply - rename-michelin-2026-germany

Committed 2026-10-09T01:51:48.495Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-germany` |
| CSV | `fixtures/rename/michelin-2026-germany-names.csv` |
| rows in the file | 215 |
| renamed | 215 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Germany 2026 set 1: Michelin-only venues, card name (Sep 14 rulings; Ben option A on the 7 im/by rows) |

## Verdicts

Population: all 215 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 215 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 215 row(s) this batch would rename, read from the database before a single name changed.

215 of the 215 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_000416f84a` | regensburg | ONTRA - Tech Square Gastro GmbH | Ontra's Gourmetstube | michelin 2 | no | /regensburg/ontra-tech-square-gastro-gmbh |
| `ve_000789cf23` | munich | 1804 Restaurant | 1804 Hirschau | michelin 2 | no | /munich/munich-fvcnf8 |
| `ve_012c1b1c79` | wilthen | Landidyll Hotel Erbgericht Tautewalde - LET Tautewalde GmbH | Erbgericht Tautewalde | michelin 2 | no | /wilthen/landidyll-hotel-erbgericht-tautewalde-let-tautewalde-gmbh |
| `ve_01cb535157` | neupotz | Gasthof zum Lamm | Zum Lamm | michelin 2 | no | /neupotz/gasthof-zum-lamm |
| `ve_0230b58c5e` | weisenheim-am-berg | Restaurant Admiral Weisenheim am Berg | Admiral | michelin 2 | no | /weisenheim-am-berg/restaurant-admiral-weisenheim-am-berg |
| `ve_033e14a5d8` | bad-teinach-zavelstein | Berlins Krone | Gourmetrestaurant Berlins Krone | michelin 2 | no | /bad-teinach-zavelstein/berlins-krone |
| `ve_035de3407a` | osnabruck | IKO RESTAURANT | IKO | michelin 2 | no | /osnabruck/iko-restaurant |
| `ve_0505d8b2dc` | hayingen | 1950 Bio-Fine-Dining-Restaurant | Restaurant 1950 | michelin 2 | no | /hayingen/hayingen-s3l2lo |
| `ve_05c8496ec5` | sankt-wendel | Restaurant Kunz GmbH | Restaurant Kunz | michelin 2 | no | /sankt-wendel/restaurant-kunz-gmbh |
| `ve_06e7e35a31` | pleiskirchen | Huberwirt | Restaurant Alexander Huber | michelin 2 | no | /pleiskirchen/huberwirt |
| `ve_07ce393508` | baden-baden | Le Jardin de France | Le Jardin de France im Stahlbad | michelin 2 | no | /baden-baden/le-jardin-de-france |
| `ve_0889d3c886` | frasdorf | Michael´s Leitenberg | Michaels Leitenberg | michelin 2 | no | /frasdorf/michael-s-leitenberg |
| `ve_08974e852a` | burgstadt | Hotel Weinhaus Stern | Weinhaus Stern | michelin 2 | no | /burgstadt/hotel-weinhaus-stern |
| `ve_09e5c57dac` | berlin | Matthias Restaurant | Matthias | michelin 2 | no | /berlin/matthias-restaurant |
| `ve_0af95c1d33` | forstinning | Gasthof zum Vaas | Zum Vaas | michelin 2 | no | /forstinning/gasthof-zum-vaas |
| `ve_0c6979f2b4` | todtnau | Waldfrieden | derWaldfrieden | michelin 2 | no | /todtnau/waldfrieden |
| `ve_0efab759e6` | eltville-am-rhein | Restaurant Jean | Jean | michelin 2 | no | /eltville-am-rhein/restaurant-jean |
| `ve_10faa8dd60` | dresden | Rauschenbach deli | DELI | michelin 2 | no | /dresden/rauschenbach-deli |
| `ve_1192ffe93c` | kappelrodeck | Rebstock Waldulm Hotel & Restaurant | Zum Rebstock | michelin 2 | no | /kappelrodeck/rebstock-waldulm-hotel-restaurant |
| `ve_13d1501d81` | mannheim | Dobler's Restaurant | Dobler's | michelin 2 | no | /mannheim/dobler-s-restaurant |
| `ve_13e2ea6366` | deggendorf | edl.eins Restaurant | edl.eins | michelin 2 | no | /deggendorf/edl-eins-restaurant |
| `ve_14268ff151` | dorsten | Restaurant Rosin - Frank Rosin | Rosin | michelin 2 | no | /dorsten/restaurant-rosin-frank-rosin |
| `ve_1506d9a82d` | hohnhorst | Restaurant Mohn * | Restaurant Mohn | michelin 1 | no | /hohnhorst/restaurant-mohn |
| `ve_151f45142c` | dusseldorf | Münstermann Kontor | Münstermanns Kontor | michelin 2 | no | /dusseldorf/munstermann-kontor |
| `ve_17ffd58979` | bad-nenndorf | Romantik Hotel Schmiedegasthaus Gehrke | Das August | michelin 2 | no | /bad-nenndorf/romantik-hotel-schmiedegasthaus-gehrke |
| `ve_18839d2d45` | cologne | Le Moissonnier | Le Moissonnier Bistro | michelin 2 | no | /cologne/le-moissonnier |
| `ve_19e248db68` | nordhausen | Rüdigsdorfer Schweiz - Patricia und Andreas Oberbüchler | Feine Speiseschenke | michelin 2 | no | /nordhausen/rudigsdorfer-schweiz-patricia-und-andreas-oberbuchler |
| `ve_1a0c4aedd2` | dorsten | Restaurant Goldener Anker - Björn Freitag | Goldener Anker | michelin 2 | no | /dorsten/restaurant-goldener-anker-bjorn-freitag |
| `ve_1a40b8cd3a` | bad-kreuznach | Weinstube Im Kittchen | Im Kittchen | michelin 2 | no | /bad-kreuznach/weinstube-im-kittchen |
| `ve_1cd2f9af99` | freiburg-im-breisgau | Restaurant Jacobi | Jacobi | michelin 2 | no | /freiburg-im-breisgau/restaurant-jacobi |
| `ve_1fc31c14da` | furstenfeldbruck | Fürstenfeld | Fürstenfelder | michelin 2 | no | /furstenfeldbruck/furstenfeld |
| `ve_209c49283c` | kirchheim-an-der-weinstra-e | Schwarz Restaurant - Manfred Schwarz | Schwarz Gourmet | michelin 2 | no | /kirchheim-an-der-weinstra-e/schwarz-restaurant-manfred-schwarz |
| `ve_20f25eb7b5` | lindau | KARRisma fine dining | KARRisma | michelin 2 | no | /lindau/karrisma-fine-dining |
| `ve_20f7655e91` | weil-am-rhein | Café Gupi - Weinbar | Café GUPI | michelin 1 | no | /weil-am-rhein/cafe-gupi-weinbar |
| `ve_2114f512c5` | weinstadt | Restaurant Cédric | Cédric | michelin 2 | no | /weinstadt/restaurant-cedric |
| `ve_235d1c2a3b` | volkach | Restaurant Weinstock - "Heimat & Kräuter by Schwane" | Weinstock | michelin 2 | no | /volkach/restaurant-weinstock-heimat-krauter-by-schwane |
| `ve_23ebc4a406` | eggenstein-leopoldshafen | garbo zum Löwen Restaurant und Hotel | Das garbo zum Löwen | michelin 2 | no | /eggenstein-leopoldshafen/garbo-zum-lowen-restaurant-und-hotel |
| `ve_252b9b472a` | blankenhain | Restaurant Masters | Masters | michelin 2 | no | /blankenhain/restaurant-masters |
| `ve_262ce366e3` | uhingen | Restaurant Schloss Filseck | Restaurant auf Schloss Filseck | michelin 2 | no | /uhingen/restaurant-schloss-filseck |
| `ve_26ad467b46` | herleshausen | Restaurant La Vallée Verte | La Vallée Verte | michelin 2 | no | /herleshausen/restaurant-la-vallee-verte |
| `ve_28dead570d` | bad-kissingen | Laudensacks Gourmet-Restaurant | Laudensacks Gourmet Restaurant | michelin 2 | no | /bad-kissingen/laudensacks-gourmet-restaurant |
| `ve_2b6800f4b0` | schwabisch-hall | Rebers Pflug - Hans-Harald Reber | Rebers Pflug | michelin 2 | no | /schwabisch-hall/rebers-pflug-hans-harald-reber |
| `ve_2e68b47c2a` | trittenheim | Wein & Tafelhaus | Wein- und Tafelhaus | michelin 2 | no | /trittenheim/wein-tafelhaus |
| `ve_2f9550d88c` | vohringen | Speisemeisterei Burgthalschenke - Ariane Großhammer | Speisemeisterei Burgthalschenke | michelin 2 | no | /vohringen/speisemeisterei-burgthalschenke-ariane-gro-hammer |
| `ve_2fb0a980e7` | eichstatt | Ståderer Restaurant by IBB Hotel Altmühltal-Eichstätt | Staderer | michelin 1 | no | /eichstatt/staderer-restaurant-by-ibb-hotel-altmuhltal-eichstatt |
| `ve_304f3c804a` | nuremberg | Restaurant Entenstuben | Entenstuben | michelin 2 | no | /nuremberg/restaurant-entenstuben |
| `ve_34517714e2` | seesen | Restaurant Harzfenster | Harzfenster by Johannes Steingrüber | michelin 1 | no | /seesen/restaurant-harzfenster |
| `ve_3624f10e3f` | deidesheim | Gasthaus Zur Kanne | Gasthaus zur Kanne | michelin 2 | no | /deidesheim/gasthaus-zur-kanne |
| `ve_39fa5e2559` | aldersbach | das asam • Restaurant & Hotel in Aldersbach | das asam | michelin 2 | no | /aldersbach/das-asam-restaurant-hotel-in-aldersbach |
| `ve_3ac1072ea6` | aschau-im-chiemgau | Residenz Heinz Winkler | Epicures | michelin 2 | no | /aschau-im-chiemgau/residenz-heinz-winkler |
| `ve_3b016ddca7` | fulda | Christian & Freunde | Christian & Friends, Tastekitchen | michelin 2 | no | /fulda/christian-freunde |
| `ve_3c275ace80` | bischofswiesen | Gourmet Restaurant Solo Du | Solo Du | michelin 2 | no | /bischofswiesen/gourmet-restaurant-solo-du |
| `ve_3e196559c2` | augsburg | Sartory Restaurant | Sartory | michelin 2 | no | /augsburg/sartory-restaurant |
| `ve_4111a67b75` | kleines-wiesental | Hotel-Restaurant Sennhütte | Sennhütte | michelin 2 | no | /kleines-wiesental/hotel-restaurant-sennhutte |
| `ve_41fb4e4838` | dermbach | Restaurant "BjoernsOx" - Bjoern Leist | BjörnsOx | michelin 2 | no | /dermbach/restaurant-bjoernsox-bjoern-leist |
| `ve_442828b0f8` | pirna | Restaurant Felsenbirne | Felsenbirne | michelin 2 | no | /pirna/restaurant-felsenbirne |
| `ve_4476b503cf` | auerbach-in-der-oberpfalz | Restaurant SoulFood | SoulFood | michelin 2 | no | /auerbach-in-der-oberpfalz/restaurant-soulfood |
| `ve_45ce37fe85` | freiburg-im-breisgau | Hawara Restaurant | Hawara | michelin 2 | no | /freiburg-im-breisgau/hawara-restaurant |
| `ve_47ec50d844` | friedrichshafen | Pinus | Pinus im Seegut | michelin 2 | no | /friedrichshafen/pinus |
| `ve_4849e32048` | ulm | Restaurant Seestern Ulm | Seestern | michelin 2 | no | /ulm/restaurant-seestern-ulm |
| `ve_49408434a4` | berlin | Restaurant Bricole | Bricole | michelin 2 | no | /berlin/restaurant-bricole |
| `ve_4ac7b2a0e3` | munster | Restaurant Spitzner | Spitzner | michelin 2 | no | /munster/restaurant-spitzner |
| `ve_4d15de16fe` | prien-am-chiemsee | Zum Fischer Am See | Zum Fischer am See | michelin 2 | no | /prien-am-chiemsee/zum-fischer-am-see |
| `ve_4ec7f5495d` | ma-weiler | Hotel Restaurant Borst - Harry Borst | Borst | michelin 2 | no | /ma-weiler/hotel-restaurant-borst-harry-borst |
| `ve_5335f343cc` | frasdorf | Landgasthof Karner | Restaurant Karner | michelin 2 | no | /frasdorf/landgasthof-karner |
| `ve_55bfc9c07d` | baiersbronn | Restaurant 1789 | 1789 | michelin 2 | no | /baiersbronn/restaurant-1789 |
| `ve_55fda0db7c` | deidesheim | Restaurant Schwarzer Hahn | Schwarzer Hahn | michelin 2 | no | /deidesheim/restaurant-schwarzer-hahn |
| `ve_575f81dc9f` | sankt-ingbert | midi - Restaurant & Markt | midi | michelin 2 | no | /sankt-ingbert/midi-restaurant-markt |
| `ve_59ba780fbf` | koblenz | Restaurant Verbene | Verbene | michelin 2 | no | /koblenz/restaurant-verbene |
| `ve_5c59a008a1` | bad-tolz | Jägerwirt Kirchbichl | Jägerwirt | michelin 2 | no | /bad-tolz/jagerwirt-kirchbichl |
| `ve_5c5cc9fdec` | blankenhain | Restaurant The First | The First | michelin 2 | no | /blankenhain/restaurant-the-first |
| `ve_5cdf75f74e` | bad-peterstal-griesbach | Hotel Dollenberg ·Kaminstube | Kamin- und Bauernstube | michelin 2 | no | /bad-peterstal-griesbach/hotel-dollenberg-kaminstube |
| `ve_5dc3caa0f5` | rheda-wiedenbruck | Hotel Reuter | Reuter | michelin 2 | no | /rheda-wiedenbruck/hotel-reuter |
| `ve_5fad8fbf2d` | gummersbach | Die Mühlenhelle | Mühlenhelle | michelin 2 | no | /gummersbach/die-muhlenhelle |
| `ve_6046196daf` | leipzig | FRIEDA Restaurant | Frieda | michelin 2 | no | /leipzig/frieda-restaurant |
| `ve_6169b6c64c` | weinheim | Restaurant Ziegler | Ziegler | michelin 2 | no | /weinheim/restaurant-ziegler |
| `ve_61d4ac88a4` | norderney | Relais & Châteaux Hotel Seesteg | Seesteg | michelin 2 | no | /norderney/relais-chateaux-hotel-seesteg |
| `ve_61fa83ffc1` | andernach | PURS New Nordic Japanese Cuisine | PURS Nordic Japanese | michelin 2 | no | /andernach/purs-new-nordic-japanese-cuisine |
| `ve_641d63a89a` | cuxhaven | Panorama-Gourmet-Restaurant Sterneck | Sterneck | michelin 2 | no | /cuxhaven/panorama-gourmet-restaurant-sterneck |
| `ve_6572c9ff9b` | wernberg-koblitz | Hotel und Landgasthof Burkhard | Wirtsstube im Hotel Burkhard | michelin 2 | no | /wernberg-koblitz/hotel-und-landgasthof-burkhard |
| `ve_672e9db373` | kernen-im-remstal | Restaurant Malathounis | Malathounis | michelin 2 | no | /kernen-im-remstal/restaurant-malathounis |
| `ve_674a30e184` | pilsach | Country Inn Meier | MEIER | michelin 2 | no | /pilsach/country-inn-meier |
| `ve_67ae1460bd` | frankfurt | Villa Merton | Restaurant Villa Merton | michelin 2 | no | /frankfurt/villa-merton |
| `ve_69b0034cdc` | dusseldorf | Agata's Restaurant | Agata's | michelin 2 | no | /dusseldorf/agata-s-restaurant |
| `ve_6ae3aadc78` | berlin | LOUMI | Loumi | michelin 2 | no | /berlin/loumi |
| `ve_6b6991748e` | harsewinkel | Poppenborg | Poppenborg's Stübchen | michelin 2 | no | /harsewinkel/poppenborg |
| `ve_6e31f3818d` | hauzenberg | Anetseder – Wirtshauskultur in Haag | Anetseder | michelin 2 | no | /hauzenberg/anetseder-wirtshauskultur-in-haag |
| `ve_6ec95ab40c` | stuttgart | Hupperts Restaurant | Hupperts | michelin 2 | no | /stuttgart/hupperts-restaurant |
| `ve_72fba78e99` | cologne | NEOBIOTA | NeoBiota | michelin 1 | no | /cologne/neobiota |
| `ve_7323207168` | schwabisch-hall | Gourmet-Restaurant "Eisenbahn" | Eisenbahn | michelin 2 | no | /schwabisch-hall/gourmet-restaurant-eisenbahn |
| `ve_73f5cc1d61` | augsburg | Restaurant Alte Liebe | Alte Liebe | michelin 2 | no | /augsburg/restaurant-alte-liebe |
| `ve_766b85cde9` | neuhutten | Le Temple | Le temple | michelin 2 | no | /neuhutten/le-temple |
| `ve_784628648e` | salach | fine dining RS | Gourmetrestaurant "fine dining RS" | michelin 2 | no | /salach/fine-dining-rs |
| `ve_788a74bd57` | darscheid | Kucher’s Gourmet Restaurant | Kucher's Gourmet | michelin 2 | no | /darscheid/kucher-s-gourmet-restaurant |
| `ve_78d61f4aa2` | birkweiler | Schockes Laurentiushof & Schockes Küche | Schockes Küche | michelin 2 | no | /birkweiler/schockes-laurentiushof-schockes-kuche |
| `ve_7b432d66a1` | friesoythe | REGIONAL Friesoythe | Regional Friesoythe | michelin 2 | no | /friesoythe/regional-friesoythe |
| `ve_7d292dfd01` | duggendorf | Gourmet Stube & Alter Saal im Gasthaus Hummel - Stefan Hummel | DIE GOURMET STUBE im Gasthaus Hummel | michelin 2 | no | /duggendorf/gourmet-stube-alter-saal-im-gasthaus-hummel-stefan-hummel |
| `ve_7de76e5bb6` | stuttgart | Restaurant Laesâ | Laesâ | michelin 1 | no | /stuttgart/restaurant-laesa |
| `ve_7fdc48486a` | klingenberg-am-main | cølbo Restaurant | Cølbo | michelin 1 | no | /klingenberg-am-main/c-lbo-restaurant |
| `ve_801f5d310a` | sonnenbuhl | Restaurant Hirsch | Hirsch | michelin 2 | no | /sonnenbuhl/restaurant-hirsch |
| `ve_808254fbbe` | ettlingen | Hotel Erbprinz Ettlingen | Erbprinz | michelin 2 | no | /ettlingen/hotel-erbprinz-ettlingen |
| `ve_819326b154` | cologne | HENNE. Weinbar | HENNE.Weinbar | michelin 2 | no | /cologne/henne-weinbar |
| `ve_82e1309127` | hamburg | arc restaurant | Arc Restaurant | michelin 1 | no | /hamburg/arc-restaurant |
| `ve_83964b9c3c` | frammersbach | Hotel-Restaurant Schwarzkopf | Schwarzkopf | michelin 2 | no | /frammersbach/hotel-restaurant-schwarzkopf |
| `ve_86ce1b8e11` | dornum | Hotel Restaurant Fährhaus | Fährhaus | michelin 2 | no | /dornum/hotel-restaurant-fahrhaus |
| `ve_86dc569939` | ostrach | Gasthof Landhotel Hirsch | Landhotel zum Hirsch | michelin 2 | no | /ostrach/gasthof-landhotel-hirsch |
| `ve_884cf7506a` | ubersee | June Restaurant | June | michelin 2 | no | /ubersee/june-restaurant |
| `ve_885eda93f2` | langenau | Restaurant HochZwei im Gasthof zum Bad Langenau | HOCHZWEI | michelin 2 | no | /langenau/restaurant-hochzwei-im-gasthof-zum-bad-langenau |
| `ve_89def3daf3` | blieskastel | Hämmerles Restaurant | Hämmerle's Restaurant | michelin 2 | no | /blieskastel/hammerles-restaurant |
| `ve_8ac4fcb91e` | erkelenz | Restaurant TROYKA | Troyka | michelin 2 | no | /erkelenz/restaurant-troyka |
| `ve_8c386f6988` | saarburg | Dopamin Fine Dining by Erasmus | Dopamin | michelin 1 | no | /saarburg/dopamin-fine-dining-by-erasmus |
| `ve_8cd643ee60` | munster | BOK Restaurant | BOK Restaurant Brust oder Keule | michelin 2 | no | /munster/bok-restaurant |
| `ve_8de68dc19f` | hauzenberg | Naturhotel Gidibauer Hof | Landgasthaus Gidibauer-Hof | michelin 2 | no | /hauzenberg/naturhotel-gidibauer-hof |
| `ve_8ff4e08e8b` | simmershofen | Winzerhof Stahl · Weingut · Fine Dining Restaurant · Gästezimmer · Hochzeitslocation | Winzerhof Stahl | michelin 2 | no | /simmershofen/winzerhof-stahl-weingut-fine-dining-restaurant-gastezimmer-hochzeitslocation |
| `ve_9340b7e3be` | hamburg | Restaurant Nil | Nil | michelin 2 | no | /hamburg/restaurant-nil |
| `ve_9594348590` | endingen-am-kaiserstuhl | Pfarrwirtschaft | Die Pfarrwirtschaft | michelin 2 | no | /endingen-am-kaiserstuhl/pfarrwirtschaft |
| `ve_963db10cb6` | neubeuern | Auers Schlosswirtschaft Neubeuern | Auers Schlosswirtschaft | michelin 2 | no | /neubeuern/auers-schlosswirtschaft-neubeuern |
| `ve_96bf809bbc` | bad-doberan | Gourmet Restaurant Friedrich Franz | Friedrich Franz | michelin 2 | no | /bad-doberan/gourmet-restaurant-friedrich-franz |
| `ve_9768a07e6c` | nuremberg | Wonka Restaurant & Kochwerkstatt | Wonka | michelin 2 | no | /nuremberg/wonka-restaurant-kochwerkstatt |
| `ve_97de402f65` | bad-kotzing | LEOs by Stephan Brandl | Leos by Stephan Brandl | michelin 2 | no | /bad-kotzing/leos-by-stephan-brandl |
| `ve_987a52d071` | munich | Restaurant Gabelspiel | Gabelspiel | michelin 2 | no | /munich/restaurant-gabelspiel |
| `ve_9a402528da` | bonn | Halbedel’s Gasthaus | halbedel's Gasthaus | michelin 2 | no | /bonn/halbedel-s-gasthaus |
| `ve_9a7a71c6be` | waging-am-see | Hotel Restaurant Landhaus Tanner | Landhaus Tanner | michelin 2 | no | /waging-am-see/hotel-restaurant-landhaus-tanner |
| `ve_9b1836a5b6` | mainz | Steins Traube - Mainz | Steins Traube | michelin 2 | no | /mainz/steins-traube-mainz |
| `ve_9bf6eab1ca` | dusseldorf | Jae Restaurant | Jae | michelin 2 | no | /dusseldorf/jae-restaurant |
| `ve_9c222872bc` | teisnach | Oswalds Gourmetstube | Oswald's Gourmetstube | michelin 2 | no | /teisnach/oswalds-gourmetstube |
| `ve_9d78cfee92` | wildberg | Hotel Restaurant Talblick | Talblick | michelin 2 | no | /wildberg/hotel-restaurant-talblick |
| `ve_9f9c2cedfb` | duisburg | MOD - by Sven Nöthel | Mod by Sven Nöthel | michelin 2 | no | /duisburg/mod-by-sven-nothel |
| `ve_a0525f68e4` | elzach | Gasthaus Rössle | Rössle | michelin 2 | no | /elzach/gasthaus-rossle |
| `ve_a05414a3ba` | sommerhausen | Restaurant Philipp | Philipp | michelin 2 | no | /sommerhausen/restaurant-philipp |
| `ve_a1fe39ecf3` | illertissen | Vier Jahreszeiten - Andreas Imhof | Vier Jahreszeiten Restaurant Imhof | michelin 2 | no | /illertissen/vier-jahreszeiten-andreas-imhof |
| `ve_a21e5606ca` | hanover | Restaurant Handwerk | Handwerk | michelin 2 | no | /hanover/restaurant-handwerk |
| `ve_a2b50d1946` | hardert | Restaurant Corona | Restaurant Corona im Hotel zur Post | michelin 2 | no | /hardert/restaurant-corona |
| `ve_a2d6404423` | selzen | Kaupers Kapellenhof | Kaupers Restaurant im Kapellenhof | michelin 2 | no | /selzen/kaupers-kapellenhof |
| `ve_a3b86ce5d4` | baden-baden | Maltes Hidden Kitchen | Maltes hidden kitchen | michelin 2 | no | /baden-baden/maltes-hidden-kitchen |
| `ve_a473e18914` | dierhagen | Gourmetrestaurant Ostseelounge | Ostseelounge | michelin 1 | no | /dierhagen/gourmetrestaurant-ostseelounge |
| `ve_a4b6b633e7` | frankfurt | Yaldy | YALDY | michelin 2 | no | /frankfurt/yaldy |
| `ve_a81a3518f2` | regensburg | Storstad Restaurant - Regensburg | Storstad | michelin 2 | no | /regensburg/storstad-restaurant-regensburg |
| `ve_aa94015613` | berlin | MaMi's Food&Wine | MaMi's | michelin 2 | no | /berlin/mami-s-food-wine |
| `ve_aac721dd2b` | bergisch-gladbach | Restaurant Schote | Schote | michelin 1 | no | /bergisch-gladbach/restaurant-schote |
| `ve_ad3ccee9a1` | essen | Kettner‘s Kamota | Kettner's Kamota | michelin 2 | no | /essen/kettner-s-kamota |
| `ve_b0a68f018a` | baiersbronn | Gourmetrestaurant Schlossberg | Schlossberg | michelin 2 | no | /baiersbronn/gourmetrestaurant-schlossberg |
| `ve_b18b739e75` | waldenbuch | Gasthof Krone - Krone Waldenbuch GmbH | Gasthof Krone | michelin 2 | no | /waldenbuch/gasthof-krone-krone-waldenbuch-gmbh |
| `ve_b1cded444d` | pfronten | Sternerestaurant PAVO | PAVO | michelin 2 | no | /pfronten/sternerestaurant-pavo |
| `ve_b28ff85ca5` | kiel | Ahlmanns im Romantik Hotel Kieler Kaufmann | Ahlmanns | michelin 2 | no | /kiel/ahlmanns-im-romantik-hotel-kieler-kaufmann |
| `ve_b335f4a72c` | langenzenn | KEIDENZELLER HOF | Keidenzeller Hof | michelin 2 | no | /langenzenn/keidenzeller-hof |
| `ve_b34e3be975` | hayingen | Biohotel-Restaurant Rose (Tress Gastronomie GmbH & Co. KG) | ROSE | michelin 2 | no | /hayingen/biohotel-restaurant-rose-tress-gastronomie-gmbh-co-kg |
| `ve_b46cfdebad` | mainz | Favorite Restaurant | FAVORITE restaurant | michelin 2 | no | /mainz/favorite-restaurant |
| `ve_b6edcb22ae` | finning | Zum Staudenwirt - eigenart GmbH | Staudenwirt | michelin 2 | no | /finning/zum-staudenwirt-eigenart-gmbh |
| `ve_b8360de0c5` | hamburg | Restaurant Jellyfish by Stefan Fäth | Jellyfish | michelin 2 | no | /hamburg/restaurant-jellyfish-by-stefan-fath |
| `ve_b89ce05d50` | sankt-margen | Hotel - Gasthaus zum Kreuz | Zum Kreuz | michelin 2 | no | /sankt-margen/hotel-gasthaus-zum-kreuz |
| `ve_ba011b22c7` | elzach | Restaurant Adler | Schäck's Adler | michelin 2 | no | /elzach/restaurant-adler |
| `ve_bc1cf74926` | immenstaad-am-bodensee | Seehof Immenstaad | Seehof | michelin 2 | no | /immenstaad-am-bodensee/seehof-immenstaad |
| `ve_bc488b87cd` | naurath-wald | Rüssels Landhaus - Landhaus St. Urban Hotel Betriebs GmbH | Rüssel's Landhaus | michelin 2 | no | /naurath-wald/russels-landhaus-landhaus-st-urban-hotel-betriebs-gmbh |
| `ve_bd14a03ab7` | rothenburg-ob-der-tauber | Villa Mittermeier | Mittermeier | michelin 2 | no | /rothenburg-ob-der-tauber/villa-mittermeier |
| `ve_bd4c5ae2ef` | isny-im-allgau | Restaurant Allgäuer Stuben | Allgäuer Stuben | michelin 2 | no | /isny-im-allgau/restaurant-allgauer-stuben |
| `ve_bd51e9f45a` | schmallenberg | Gourmetrestaurant Hofstube Deimann | Hofstube Deimann | michelin 2 | no | /schmallenberg/gourmetrestaurant-hofstube-deimann |
| `ve_bf90f025d0` | ofterschwang | Gourmetrestaurant Silberdistel | Silberdistel | michelin 2 | no | /ofterschwang/gourmetrestaurant-silberdistel |
| `ve_bfecf57e4d` | neupotz | Gehrleins Restaurant Hardtwald | Gehrlein's Hardtwald | michelin 2 | no | /neupotz/gehrleins-restaurant-hardtwald |
| `ve_c3dda37111` | berlin | NOVEMBER Brasserie | November Brasserie | michelin 2 | no | /berlin/november-brasserie |
| `ve_c5c5bbf971` | andernach | Ai Pero PURS Authentic Italian Trattoria | Ai Pero | michelin 2 | no | /andernach/ai-pero-purs-authentic-italian-trattoria |
| `ve_c5cc23a894` | saarlouis | Louis Restaurant | LOUIS restaurant | michelin 2 | no | /saarlouis/louis-restaurant |
| `ve_c6c5fa9a8d` | cham | Gasthaus Ödenturm Inh. Ernst Hunger | Gasthaus Ödenturm | michelin 2 | no | /cham/gasthaus-odenturm-inh-ernst-hunger |
| `ve_c79219382e` | schriesheim | Restaurant RARO im Mühlenhof | Raro im Mühlenhof | michelin 2 | no | /schriesheim/restaurant-raro-im-muhlenhof |
| `ve_ca548881df` | lindau | VILLINO - Reiner Fischer | VILLINO | michelin 2 | no | /lindau/villino-reiner-fischer |
| `ve_cae401498e` | dusseldorf | Restaurant Setzkasten Düsseldorf | Setzkasten | michelin 2 | no | /dusseldorf/restaurant-setzkasten-dusseldorf |
| `ve_ced10c4d84` | cologne | Capricorn (i) Aries Brasserie | Capricorn [ i ] Aries Brasserie | michelin 2 | no | /cologne/capricorn-i-aries-brasserie |
| `ve_d01ecc7480` | dresden | Restaurant Genuss-Atelier | Genuss-Atelier | michelin 2 | no | /dresden/restaurant-genuss-atelier |
| `ve_d175f515c7` | schwabisch-hall | Landhaus Rössle - Eventlocation, Restaurant und Hotel | Landhaus Zum Rössle | michelin 2 | no | /schwabisch-hall/landhaus-rossle-eventlocation-restaurant-und-hotel |
| `ve_d44aee72d5` | baiersbronn | Restaurant Schatzhauser | Schatzhauser | michelin 2 | no | /baiersbronn/restaurant-schatzhauser |
| `ve_d46e645158` | nordlingen | Meyers Keller \| Jockl Kaiser | Wirtshaus Meyers Keller | michelin 2 | no | /nordlingen/meyers-keller-jockl-kaiser |
| `ve_d4a3980667` | paderborn | Restaurant Balthasar | Balthasar | michelin 2 | no | /paderborn/restaurant-balthasar |
| `ve_d56ebba332` | essen | CHEFS ATELIER | Chefs Atelier | michelin 2 | no | /essen/chefs-atelier |
| `ve_d6906e8bfb` | tangstedt | Restaurant Gutsküche Wulksfelde | Gutsküche | michelin 2 | no | /tangstedt/restaurant-gutskuche-wulksfelde |
| `ve_d7a5a15a7a` | koblenz | Schiller's Manufaktur & Brasserie | Schiller's Manufaktur | michelin 2 | no | /koblenz/schiller-s-manufaktur-brasserie |
| `ve_d7eb5e2b42` | marktbreit | Restaurant Alter Esel | Alter Esel | michelin 2 | no | /marktbreit/restaurant-alter-esel |
| `ve_d82a735d56` | waiblingen | Restaurant bachofer | Bachofer | michelin 2 | no | /waiblingen/restaurant-bachofer |
| `ve_d94f519644` | rostock | Der Butt | Gourmet-Restaurant Der Butt | michelin 2 | no | /rostock/der-butt |
| `ve_d96516d928` | dietramszell | Landhotel Moarwirt | Moarwirt | michelin 2 | no | /dietramszell/landhotel-moarwirt |
| `ve_d9b9adf960` | stuttgart | ZUR WEINSTEIGE - Hotel • Schlösschen • Gourmetrestaurant | ZUR WEINSTEIGE | michelin 2 | no | /stuttgart/zur-weinsteige-hotel-schlosschen-gourmetrestaurant |
| `ve_dbd4dc38f2` | dresden | Restaurant Heiderand | Heiderand | michelin 2 | no | /dresden/restaurant-heiderand |
| `ve_de56b2c6a7` | cologne | restaurant maximilian lorenz | maximilian lorenz | michelin 2 | no | /cologne/restaurant-maximilian-lorenz |
| `ve_dfbe6bf767` | schwerin | Gourmetrestaurant „1751“ | Gourmetrestaurant "1751" | michelin 1 | no | /schwerin/gourmetrestaurant-1751 |
| `ve_e12f9853d8` | luneburg | Röhms Deli | RÖHMS DELI | michelin 2 | no | /luneburg/rohms-deli |
| `ve_e134f7fdb5` | bad-hersfeld | L’étable | L'étable | michelin 2 | no | /bad-hersfeld/l-etable |
| `ve_e22c5af8dd` | essen | Restaurant Hannappel | Hannappel | michelin 2 | no | /essen/restaurant-hannappel |
| `ve_e23ab31418` | kreuzwertheim | Restaurant la boucherie | La Boucherie | michelin 2 | no | /kreuzwertheim/restaurant-la-boucherie |
| `ve_e277fbbeba` | hamburg | THE LISBETH | LISBETH | michelin 2 | no | /hamburg/the-lisbeth |
| `ve_e387ce797a` | bad-rippoldsau | Klösterle Hof - Markus Klein | Klösterle Hof | michelin 2 | no | /bad-rippoldsau/klosterle-hof-markus-klein |
| `ve_e3c0554021` | dusseldorf | EssBar - fein & pfiffig | EssBar fein & pfiffig | michelin 2 | no | /dusseldorf/essbar-fein-pfiffig |
| `ve_e4b53b0427` | hamburg | Restaurant GLORIE | GLORIE | michelin 2 | no | /hamburg/restaurant-glorie |
| `ve_e52e8e380f` | stuttgart | Restaurant Délice | Délice | michelin 2 | no | /stuttgart/restaurant-delice |
| `ve_e622dc98a4` | staufen-im-breisgau | Hotel-Restaurant Die Krone | Die Krone | michelin 2 | no | /staufen-im-breisgau/hotel-restaurant-die-krone |
| `ve_e7fc83a59b` | wyk | Restaurant Alt Wyk | Alt Wyk | michelin 2 | no | /wyk/restaurant-alt-wyk |
| `ve_e9e7461048` | frickingen | Löwen Altheim | Löwen | michelin 2 | no | /frickingen/lowen-altheim |
| `ve_ea5bdb9697` | schwendi | Esszimmer | Esszimmer im Oberschwäbischen Hof | michelin 2 | no | /schwendi/esszimmer |
| `ve_ec3ac5cc83` | rutesheim | Cafe + Conditorei Philippin | Das Philippin | michelin 1 | no | /rutesheim/cafe-conditorei-philippin |
| `ve_ec6fa906be` | freiburg-im-breisgau | Zirbelstube | Colombi Restaurant Zirbelstube | michelin 2 | no | /freiburg-im-breisgau/zirbelstube |
| `ve_ed4805dc19` | oberstdorf | ESS ATELIER | ESS ATELIER STRAUSS | michelin 2 | no | /oberstdorf/ess-atelier |
| `ve_edddd99863` | frankfurt | Main Tower Restaurant & Lounge | MAIN TOWER Restaurant & Lounge | michelin 2 | no | /frankfurt/main-tower-restaurant-lounge |
| `ve_ee3b423148` | berlin | Restaurant Nußbaumerin | Nußbaumerin | michelin 2 | no | /berlin/restaurant-nu-baumerin |
| `ve_ee92539101` | friedberg | Goldener Stern | Gasthaus Goldener Stern | michelin 2 | no | /friedberg/goldener-stern |
| `ve_f22fa95b1e` | spalt | Gasthof Blumenthal GmbH | Gasthof Blumenthal | michelin 2 | no | /spalt/gasthof-blumenthal-gmbh |
| `ve_f26ba9de94` | bonn | Theodor's Restaurant | Theodor's | michelin 1 | no | /bonn/theodor-s-restaurant |
| `ve_f2eda3d4e2` | krakow-am-see | Ich weiss ein Haus am See | Ich weiß ein Haus am See | michelin 2 | no | /krakow-am-see/ich-weiss-ein-haus-am-see |
| `ve_f32c38bb59` | freiamt | Gasthaus Zur Krone | Zur Krone | michelin 2 | no | /freiamt/gasthaus-zur-krone |
| `ve_f477ae2f2b` | augsburg | Restaurant Nose & Belly | Nose & Belly | michelin 2 | no | /augsburg/restaurant-nose-belly |
| `ve_f589486169` | bad-krozingen | Storchen Schmidhofen - Restaurant Hotel | Storchen | michelin 2 | no | /bad-krozingen/storchen-schmidhofen-restaurant-hotel |
| `ve_f87bb36eb5` | meerfeld | Hotel Zur Post Meerfeld | Poststuben | michelin 2 | no | /meerfeld/hotel-zur-post-meerfeld |
| `ve_f93b620329` | regensburg | Sticky Fingers - Regensburg | Sticky Fingers | michelin 2 | no | /regensburg/sticky-fingers-regensburg |
| `ve_fa36943b0a` | bad-herrenalb | Hotel Restaurant Vinothek LAMM - Hotel LAMM KG | LAMM | michelin 2 | no | /bad-herrenalb/hotel-restaurant-vinothek-lamm-hotel-lamm-kg |
| `ve_fc8534e21e` | velbert | Haus Stemberg | Haus Stemberg ANNO 1864 | michelin 2 | no | /velbert/haus-stemberg |
| `ve_fe0905b89e` | waldkirchen | Restaurant Johanns | Johanns | michelin 2 | no | /waldkirchen/restaurant-johanns |
| `ve_fe66019fc0` | marktbergel | Rotes Ross Marktbergel | Rotes Ross | michelin 2 | no | /marktbergel/rotes-ross-marktbergel |
| `ve_ff9f2ff3ef` | stuttgart | 5 Gourmet Restaurant & Wein Bar | 5 | michelin 2 | no | /stuttgart/stuttgart-mzj0p0 |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 215 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,223 | 11,223 | 11,223 |
| awards | 22,389 | 22,389 | 22,389 |
| slugs | 12,322 | 12,322 | 12,322 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 70 | 71 | 71 |
| rename_batches | 5 | 6 | 6 |
| rename_rows | 551 | 766 | 766 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 215 (expected 215) |
| every renamed venue's live name is its new_name | pass | 0 of 215 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 215 (expected 215) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 215 name changes (expected 215), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 215 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_000416f84a` | ONTRA - Tech Square Gastro GmbH | Ontra's Gourmetstube | michelin | https://guide.michelin.com/us/en/bayern/regensburg/restaurant/ontra-s-gourmetstube |
| `ve_000789cf23` | 1804 Restaurant | 1804 Hirschau | michelin | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/1804-hirschau |
| `ve_012c1b1c79` | Landidyll Hotel Erbgericht Tautewalde - LET Tautewalde GmbH | Erbgericht Tautewalde | michelin | https://guide.michelin.com/us/en/sachsen/wilthen/restaurant/erbgericht-tautewalde |
| `ve_01cb535157` | Gasthof zum Lamm | Zum Lamm | michelin | https://guide.michelin.com/us/en/rheinland-pfalz/neupotz/restaurant/zum-lamm |
| `ve_0230b58c5e` | Restaurant Admiral Weisenheim am Berg | Admiral | michelin | https://guide.michelin.com/us/en/rheinland-pfalz/weisenheim-am-berg/restaurant/admiral |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-germany`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 215 |

Spellings followed: michelin (215).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2026-germany`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2026-germany`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
