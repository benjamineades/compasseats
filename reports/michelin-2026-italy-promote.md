# Ingest promote - michelin-2026-italy

Committed 2026-09-15T03:57:34.875Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,258 | 11,575 | 11,575 |
| awards | 22,884 | 23,516 | 23,516 |
| listings | 11,258 | 11,575 | 11,575 |
| slugs | 11,515 | 11,832 | 11,832 |
| city_label_source | 22,800 | 23,434 | 23,434 |
| price | 7,091 | 7,091 | 7,091 |
| source_capture_ledger | 14 | 16 | 16 |

Active venues: 10,878 -> 11,195.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 632 (expected 632) |
| venues delta equals new venues | pass | 317 (expected 317) |
| listings delta equals new venues | pass | 317 (expected 317) |
| slugs delta equals new venues | pass | 317 (expected 317) |
| city_label_source delta equals planned labels | pass | 634 (expected 634) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10878 -> 11195 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_d10be85fe0` | Dal Pescatore Santini | /canneto-sulloglio/dal-pescatore-santini | active | true | 1 |
| `ve_d4db682529` | Le Calandre | /padua/le-calandre | active | true | 1 |
| `ve_4cd1c6b52d` | Reale | /castel-di-sangro/reale | active | true | 1 |
| `ve_74cd41b387` | Antica Corona Reale | /cervere/antica-corona-reale | active | true | 1 |
| `ve_f4e864c4b6` | Locanda Sant'Uffizio Enrico Bartolini | /cioccaro-di-penango/locanda-sant-uffizio-enrico-bartolini | active | true | 1 |
| `ve_362f8ecf91` | Andrea Aprea | /milan/andrea-aprea | active | true | 1 |
| `ve_ac011da0b7` | Verso Capitaneo | /milan/verso-capitaneo | active | true | 1 |
| `ve_ae9fe2766d` | Villa Feltrinelli | /gargnano/villa-feltrinelli | active | true | 1 |
| `ve_1a08c4cece` | Famiglia Rana | /oppeano/famiglia-rana | active | true | 1 |
| `ve_782861d4aa` | Glam Enrico Bartolini | /venice/glam-enrico-bartolini | active | true | 1 |
| `ve_5263416672` | Santa Elisabetta | /florence/santa-elisabetta | active | true | 1 |
| `ve_11423aa956` | Arnolfo | /colle-di-val-delsa/arnolfo | active | true | 1 |
| `ve_0335fa26c1` | Agli Amici | /godia/agli-amici | active | true | 1 |
| `ve_6b2f0a92df` | Campo del Drago | /montalcino/campo-del-drago | active | true | 1 |
| `ve_40a461563b` | Magnolia | /longiano/magnolia | active | true | 1 |
| `ve_a6225229ce` | Caino | /montemerano/caino | active | true | 1 |
| `ve_c85f34549f` | L'Olivo | /anacapri/l-olivo | active | true | 1 |
| `ve_3860471c98` | I Tenerumi | /vulcanello/i-tenerumi | active | true | 1 |
| `ve_2aabb4e3ca` | La Madia | /licata/la-madia | active | true | 1 |
| `ve_215d38f159` | St. George by Heinz Beck | /taormina/st-george-by-heinz-beck | active | true | 1 |
| `ve_ee365ac625` | Duomo | /ragusa/duomo | active | true | 1 |
| `ve_1b074885e1` | Vecchio Ristoro | /aosta/vecchio-ristoro | active | true | 1 |
| `ve_4eb5d31b82` | Le Petit Bellevue | /cogne/le-petit-bellevue | active | true | 1 |
| `ve_69180d2d51` | Dolce Stil Novo alla Reggia | /venaria-reale/dolce-stil-novo-alla-reggia | active | true | 1 |
| `ve_e5d82820b1` | Piano35 | /turin/piano35 | active | true | 1 |
| `ve_6544317e29` | Del Cambio | /turin/del-cambio | active | true | 1 |
| `ve_3d1cda8ab7` | Condividere | /turin/condividere | active | true | 1 |
| `ve_a55d27a6ec` | Andrea Larossa | /turin/andrea-larossa | active | true | 1 |
| `ve_3429fe4c40` | Cannavacciuolo Bistrot | /turin/cannavacciuolo-bistrot | active | true | 1 |
| `ve_3d9cab4b86` | Andrea Monesi - Locanda di Orta | /orta-san-giulio/andrea-monesi-locanda-di-orta | active | true | 1 |
| `ve_85020a53ff` | Nazionale | /vernante/nazionale | active | true | 1 |
| `ve_21281dfe7f` | Ca' Vittoria | /tigliole/ca-vittoria | active | true | 1 |
| `ve_c48f5ae3b2` | All'Enoteca | /canale/all-enoteca | active | true | 1 |
| `ve_741ea4e062` | 21.9 | /piobesi-dalba/21-9 | active | true | 1 |
| `ve_c1ba01929e` | Il Centro | /priocca/il-centro | active | true | 1 |
| `ve_da9a1ba760` | Massimo Camia | /novello/massimo-camia | active | true | 1 |
| `ve_9ae0244c54` | Borgo Sant'Anna | /monforte-dalba/borgo-sant-anna | active | true | 1 |
| `ve_bbb0109bf0` | Il Cantinone e Sport Hotel Alpina | /madesimo/il-cantinone-e-sport-hotel-alpina | active | true | 1 |
| `ve_7c469c8c9d` | Il Ristorante di Guido da Costigliole | /santo-stefano-belbo/il-ristorante-di-guido-da-costigliole | active | true | 1 |
| `ve_cfe03c3b52` | Acqua | /olgiate-olona/acqua | active | true | 1 |
| `ve_c4ee21de98` | Materia | /cernobbio/materia | active | true | 1 |
| `ve_f216fb701f` | Il Sereno Al Lago | /torno/il-sereno-al-lago | active | true | 1 |
| `ve_55440e6e9d` | Olio | /origgio/olio | active | true | 1 |
| `ve_eb838ee463` | Paolo e Barbara | /san-remo/paolo-e-barbara | active | true | 1 |
| `ve_58f3d63f9d` | La Preséf | /mantello/la-presef | active | true | 1 |
| `ve_f1f57fbb65` | I Castagni | /vigevano/i-castagni | active | true | 1 |
| `ve_d51d9dd934` | Olmo | /milan/olmo | active | true | 1 |
| `ve_25ceae9c30` | Equilibrio | /dolcedo/equilibrio | active | true | 1 |
| `ve_4bb4b75cdb` | Abba | /milan/abba | active | true | 1 |
| `ve_086cbe64f2` | Il Luogo Aimo e Nadia | /milan/il-luogo-aimo-e-nadia | active | true | 1 |
| `ve_45e8f51329` | Sarri | /imperia/sarri | active | true | 1 |
| `ve_6df8495da7` | Anima | /milan/anima | active | true | 1 |
| `ve_7ff84aabf5` | Procaccini | /milan/procaccini | active | true | 1 |
| `ve_23b258472d` | Berton | /milan/berton | active | true | 1 |
| `ve_ce02b752b9` | Sadler | /milan/sadler | active | true | 1 |
| `ve_fc2ea62d19` | Cracco in Galleria | /milan/cracco-in-galleria | active | true | 1 |
| `ve_f1cbb69116` | Moebius Sperimentale | /milan/moebius-sperimentale | active | true | 1 |
| `ve_f28c0d21b2` | Vignamare | /andora/vignamare | active | true | 1 |
| `ve_b3c9ae4cb8` | Nove | /alassio/nove | active | true | 1 |
| `ve_c51975014c` | Vescovado | /noli/vescovado | active | true | 1 |
| `ve_da77bb9bcf` | Villa Naj | /torrazza-coste/villa-naj | active | true | 1 |
| `ve_35c8d565e6` | San Martino | /scorze/san-martino | active | true | 1 |
| `ve_d371719674` | Il Saraceno | /cavernago/il-saraceno | active | true | 1 |
| `ve_d1b2afd302` | LoRo | /trescore-balneario/loro | active | true | 1 |
| `ve_00782073e4` | San Giorgio | /genoa/san-giorgio | active | true | 1 |
| `ve_b8d0d58000` | Cracco Portofino | /portofino/cracco-portofino | active | true | 1 |
| `ve_f86bbb90fb` | Luisl Stube | /algund/luisl-stube | active | true | 1 |
| `ve_2b7904fc89` | Dolomieu | /madonna-di-campiglio/dolomieu | active | true | 1 |
| `ve_70168c0bea` | Il Gallo Cedrone | /madonna-di-campiglio/il-gallo-cedrone | active | true | 1 |
| `ve_cd533e3224` | Grual | /pinzolo/grual | active | true | 1 |
| `ve_048afe2ee3` | Rezzano Cucina e Vino | /sestri-levante/rezzano-cucina-e-vino | active | true | 1 |
| `ve_bc773cb1ca` | In Viaggio - Claudio Melis | /merano/in-viaggio-claudio-melis | active | true | 1 |
| `ve_85c76921f6` | Prezioso | /merano/prezioso | active | true | 1 |
| `ve_5b5c4f827e` | Leon d'Oro | /pralboino/leon-d-oro | active | true | 1 |
| `ve_f80d4fd8b2` | Antica Corte Pallavicina | /polesine-parmense/antica-corte-pallavicina | active | true | 1 |
| `ve_cc68a1f3b5` | Casa Leali | /puegnago-sul-garda/casa-leali | active | true | 1 |
| `ve_7a780193f5` | Il Fagiano | /fasano-del-garda/il-fagiano | active | true | 1 |
| `ve_5c28a3fd74` | Capriccio | /manerba-del-garda/capriccio | active | true | 1 |
| `ve_33975b3dd3` | La Tortuga | /gargnano/la-tortuga | active | true | 1 |
| `ve_63377c835c` | Senso Lake Garda Alfio Ghezzi | /limone-sul-garda/senso-lake-garda-alfio-ghezzi | active | true | 1 |
| `ve_7203635278` | Tancredi | /sirmione/tancredi | active | true | 1 |
| `ve_3818ead299` | Nin | /brenzone-sul-garda/nin | active | true | 1 |
| `ve_872c8e5ff8` | Vecchia Malcesine | /malcesine/vecchia-malcesine | active | true | 1 |
| `ve_24ee4dbae5` | Oseleta | /cavaion-veronese/oseleta | active | true | 1 |
| `ve_302f801252` | Inkiostro | /parma/inkiostro | active | true | 1 |
| `ve_67a0072fc9` | Anna Stuben | /ortisei/anna-stuben | active | true | 1 |
| `ve_0c2b6ab83d` | El Molin | /cavalese/el-molin | active | true | 1 |
| `ve_26c2f1fe46` | Amistà | /corrubbio/amista | active | true | 1 |
| `ve_3e105d0c5f` | Alpenroyal Gourmet | /selva-di-val-gardena/alpenroyal-gourmet | active | true | 1 |
| `ve_bb0b252a8f` | Malga Panna | /moena/malga-panna | active | true | 1 |
| `ve_a1a29f0a3b` | Porcino | /badia/porcino | active | true | 1 |
| `ve_11b775a307` | Iris Ristorante | /verona/iris-ristorante | active | true | 1 |
| `ve_f84e239729` | Il Desco | /verona/il-desco | active | true | 1 |
| `ve_0a27e35453` | Spinechile | /schio/spinechile | active | true | 1 |
| `ve_9c29fa01e4` | Casin del Gamba | /altissimo/casin-del-gamba | active | true | 1 |
| `ve_f05b9e5141` | Tilia | /toblach/tilia | active | true | 1 |
| `ve_c0a91a26c2` | Tivoli | /cortina-dampezzo/tivoli | active | true | 1 |
| `ve_cb4482d122` | La Favellina | /malo/la-favellina | active | true | 1 |
| `ve_3194b2de28` | La Magnolia | /forte-dei-marmi/la-magnolia | active | true | 1 |
| `ve_bc6f9d6c42` | Sciabola | /forte-dei-marmi/sciabola | active | true | 1 |
| `ve_7d934851f2` | Lux Lucis | /forte-dei-marmi/lux-lucis | active | true | 1 |
| `ve_aab551e951` | Bistrot | /forte-dei-marmi/bistrot | active | true | 1 |
| `ve_0ffda6106c` | Lorenzo | /forte-dei-marmi/lorenzo | active | true | 1 |
| `ve_cc0fde132a` | Lunasia | /viareggio/lunasia | active | true | 1 |
| `ve_25cdd11fb6` | Romano | /viareggio/romano | active | true | 1 |
| `ve_66c95394b5` | Cavallino | /maranello/cavallino | active | true | 1 |
| `ve_72a0ac631b` | Butterfly | /marlia/butterfly | active | true | 1 |
| `ve_e445d40fee` | Laite | /sappada/laite | active | true | 1 |
| `ve_6aae3c8d64` | Locanda San Lorenzo | /puos-d-alpago/locanda-san-lorenzo | active | true | 1 |
| `ve_69d51bf1fc` | Storie d'Amore | /borgoricco/storie-d-amore | active | true | 1 |
| `ve_41ac43bb73` | Iacobucci | /castel-maggiore/iacobucci | active | true | 1 |
| `ve_4814393604` | Cannavacciuolo Vineyard | /casanova-di-terricciola/cannavacciuolo-vineyard | active | true | 1 |
| `ve_a2ab9c0b48` | Gellivs | /oderzo/gellivs | active | true | 1 |
| `ve_0737b9ccc6` | Wistèria | /venice/wisteria | active | true | 1 |
| `ve_baaebcb2f8` | Paca | /prato/paca | active | true | 1 |
| `ve_6317483fef` | Quadri | /venice/quadri | active | true | 1 |
| `ve_ae5c3a3e14` | Local | /venice/local | active | true | 1 |
| `ve_06fe5cbaa4` | Borgo San Jacopo | /florence/borgo-san-jacopo | active | true | 1 |
| `ve_37523466e7` | Gucci Osteria da Massimo Bottura | /florence/gucci-osteria-da-massimo-bottura | active | true | 1 |
| `ve_9a7a4820e5` | Serrae Villa Fiesole | /fiesole/serrae-villa-fiesole | active | true | 1 |
| `ve_b863067f06` | Linfa | /san-gimignano/linfa | active | true | 1 |
| `ve_c0cb138ec8` | La Torre | /tavarnelle-val-di-pesa/la-torre | active | true | 1 |
| `ve_5925c4752e` | La Zanzara | /codigoro/la-zanzara | active | true | 1 |
| `ve_003e879c86` | Capogiro | /baia-sardinia/capogiro | active | true | 1 |
| `ve_0d77b889b4` | Il Fuoco Sacro | /san-pantaleo/il-fuoco-sacro | active | true | 1 |
| `ve_515e774f23` | Italo Bassi Confusion Restaurant | /porto-cervo/italo-bassi-confusion-restaurant | active | true | 1 |
| `ve_85df296a9b` | Saporium | /chiusdino/saporium | active | true | 1 |
| `ve_96d8114cd4` | Il Pievano | /gaiole-in-chianti/il-pievano | active | true | 1 |
| `ve_c58f3317b6` | Trattoria al Cacciatore - La Subida | /cormons/trattoria-al-cacciatore-la-subida | active | true | 1 |
| `ve_93a04fe425` | L'Asinello | /castelnuovo-berardenga/l-asinello | active | true | 1 |
| `ve_3240f2710d` | Gusto by Sadler | /san-teodoro/gusto-by-sadler | active | true | 1 |
| `ve_3d3a546bfb` | Ancòra | /cesenatico/ancora | active | true | 1 |
| `ve_3b4dc38f36` | Il Piastrino | /pennabilli/il-piastrino | active | true | 1 |
| `ve_944de1b55d` | Il Falconiere | /cortona/il-falconiere | active | true | 1 |
| `ve_9e7ab4dcb6` | Fradis Minoris | /pula/fradis-minoris | active | true | 1 |
| `ve_eb026cbf9d` | Ada | /perugia/ada | active | true | 1 |
| `ve_6027fd0a24` | Elementi | /torgiano/elementi | active | true | 1 |
| `ve_328d4c3636` | Une | /capodacqua/une | active | true | 1 |
| `ve_4dfdd6f6d6` | Casa Bertini | /recanati/casa-bertini | active | true | 1 |
| `ve_6f8b1202d9` | La Trota | /rivodutri/la-trota | active | true | 1 |
| `ve_5806b0318c` | Il Tino | /fiumicino/il-tino | active | true | 1 |
| `ve_eb9d851cc7` | Vespasia | /norcia/vespasia | active | true | 1 |
| `ve_cf577c1bdf` | Andreina | /loreto/andreina | active | true | 1 |
| `ve_d675a9e1c4` | Pulejo | /rome/pulejo | active | true | 1 |
| `ve_86f18a2ceb` | All'Oro | /rome/all-oro | active | true | 1 |
| `ve_47483380fa` | Achilli al Parlamento | /rome/achilli-al-parlamento | active | true | 1 |
| `ve_ed6a6bfff6` | INEO | /rome/ineo | active | true | 1 |
| `ve_2a710ab58b` | Zia | /rome/zia | active | true | 1 |
| `ve_e8571e5e10` | Aroma | /rome/aroma | active | true | 1 |
| `ve_7e7c0f8e32` | Marco Martini Restaurant | /rome/marco-martini-restaurant | active | true | 1 |
| `ve_b0afa03932` | Sintesi | /ariccia/sintesi | active | true | 1 |
| `ve_16f690d515` | Antonello Colonna Labico | /labico/antonello-colonna-labico | active | true | 1 |
| `ve_fd739bff8d` | Zunica 1880 a Villa Corallo | /sant-omero/zunica-1880-a-villa-corallo | active | true | 1 |
| `ve_d24f412173` | D.one Ristorante Diffuso | /montepagano/d-one-ristorante-diffuso | active | true | 1 |
| `ve_6fdda208af` | Mater1apr1ma | /pontinia/mater1apr1ma | active | true | 1 |
| `ve_9ddcffa00b` | La Bandiera | /civitella-casanova/la-bandiera | active | true | 1 |
| `ve_561ec4bc6f` | Villa Maiella | /guardiagrele/villa-maiella | active | true | 1 |
| `ve_c94cfc8ce2` | Indaco | /lacco-ameno/indaco | active | true | 1 |
| `ve_8fa3270e6d` | Caracol | /bacoli/caracol | active | true | 1 |
| `ve_bbde6d166e` | Marotta | /squille/marotta | active | true | 1 |
| `ve_d8d231a412` | Veritas | /naples/veritas | active | true | 1 |
| `ve_e7cc49646c` | Lorelei | /sorrento/lorelei | active | true | 1 |
| `ve_ab68846364` | Antica Osteria Nonna Rosa | /vico-equense/antica-osteria-nonna-rosa | active | true | 1 |
| `ve_a62c2c4a5e` | Don Geppi | /sant-agnello/don-geppi | active | true | 1 |
| `ve_32ee12dfe3` | President | /pompei/president | active | true | 1 |
| `ve_cedc4a2117` | Cannavacciuolo Countryside | /ticciano/cannavacciuolo-countryside | active | true | 1 |
| `ve_703229c7eb` | Bluh Furore | /furore/bluh-furore | active | true | 1 |
| `ve_4776254443` | Glicine | /amalfi/glicine | active | true | 1 |
| `ve_14ce5d2000` | Alici | /amalfi/alici | active | true | 1 |
| `ve_7acd66dd22` | La Caravella dal 1959 | /amalfi/la-caravella-dal-1959 | active | true | 1 |
| `ve_38686dfb45` | Sensi | /amalfi/sensi | active | true | 1 |
| `ve_050524f985` | Volta del Fuenti by Michele De Blasio | /vietri-sul-mare/volta-del-fuenti-by-michele-de-blasio | active | true | 1 |
| `ve_d32edd43d0` | Oasis - Sapori Antichi | /vallesaccarda/oasis-sapori-antichi | active | true | 1 |
| `ve_f01cedffab` | Tre Olivi | /paestum/tre-olivi | active | true | 1 |
| `ve_94e280abc1` | Le Trabe | /paestum/le-trabe | active | true | 1 |
| `ve_068994716a` | Līmū | /bagheria/limu | active | true | 1 |
| `ve_a7197bfee2` | Casa Sgarra | /trani/casa-sgarra | active | true | 1 |
| `ve_69b7b57435` | Signum | /malfa-it/signum | active | true | 1 |
| `ve_83c44f7e72` | Vitantonio Lombardo | /matera/vitantonio-lombardo | active | true | 1 |
| `ve_6f7a35564e` | Il Cappero | /vulcanello/il-cappero | active | true | 1 |
| `ve_ff33d6739f` | Pashà | /polignano-a-mare/pasha | active | true | 1 |
| `ve_e9c47885f4` | Angelo Sabatelli | /putignano/angelo-sabatelli | active | true | 1 |
| `ve_80c795c589` | Shalai | /linguaglossa/shalai | active | true | 1 |
| `ve_9860e73d1c` | Otto Geleng | /taormina/otto-geleng | active | true | 1 |
| `ve_30d3ed0320` | Dissapore di Andrea Catalano | /carovigno/dissapore-di-andrea-catalano | active | true | 1 |
| `ve_538939ca42` | Zash | /archi/zash | active | true | 1 |
| `ve_721d5c8d25` | Coria | /catania/coria | active | true | 1 |
| `ve_b1d0a7e318` | Votavota | /marina-di-ragusa/votavota | active | true | 1 |
| `ve_eadf4a939e` | Hyle | /san-giovanni-in-fiore/hyle | active | true | 1 |
| `ve_69b71769a0` | Casamatta | /manduria/casamatta | active | true | 1 |
| `ve_d4a305a499` | Locanda Don Serafino | /ragusa/locanda-don-serafino | active | true | 1 |
| `ve_686c910a23` | Crocifisso | /noto/crocifisso | active | true | 1 |
| `ve_fb335d87e4` | Dattilo | /strongoli/dattilo | active | true | 1 |
| `ve_e684b8e293` | Gambero Rosso | /marina-di-gioiosa-ionica/gambero-rosso | active | true | 1 |
| `ve_1c6b07f65d` | Laghetto | /brusson/laghetto | active | true | 1 |
| `ve_ca31f11c54` | Le Miniere | /traversella/le-miniere | active | true | 1 |
| `ve_42c4388acc` | Edelweiss | /viceno/edelweiss | active | true | 1 |
| `ve_386fb0ef13` | Scannabue Caffè Restaurant | /turin/scannabue-caffe-restaurant | active | true | 1 |
| `ve_9926dfb465` | Consorzio | /turin/consorzio | active | true | 1 |
| `ve_aae6903bf0` | La Pineta | /sant-anna/la-pineta | active | true | 1 |
| `ve_7d2ec43385` | Italia | /quarona/italia | active | true | 1 |
| `ve_0ba5c4f9ec` | Castagneto | /montrigiasco/castagneto | active | true | 1 |
| `ve_c09921a88c` | Condividere | /arona/condividere | active | true | 1 |
| `ve_4835b009bc` | Battaglino | /bra/battaglino | active | true | 1 |
| `ve_e02ff6ed99` | Vascello d'Oro | /carru/vascello-d-oro | active | true | 1 |
| `ve_889939b62e` | Terme | /pigna/terme | active | true | 1 |
| `ve_cb05f5cd40` | Violetta | /calamandrana/violetta | active | true | 1 |
| `ve_4d9a4e55e9` | Del Belbo - Da Bardon | /san-marzano-oliveto/del-belbo-da-bardon | active | true | 1 |
| `ve_c69b17715e` | Mezzolitro Vini e Cucina | /rho/mezzolitro-vini-e-cucina | active | true | 1 |
| `ve_6a30df3b91` | Da Fausto | /cavatore/da-fausto | active | true | 1 |
| `ve_e53e5c069b` | Cacciatori | /cartosio/cacciatori | active | true | 1 |
| `ve_14dde23193` | Trippa | /milan/trippa | active | true | 1 |
| `ve_9038f00592` | La Civetta | /urbe/la-civetta | active | true | 1 |
| `ve_254ad8394d` | Rimulas | /voghera/rimulas | active | true | 1 |
| `ve_aa7039a78b` | Fracia | /teglio/fracia | active | true | 1 |
| `ve_ac9e56bd72` | Altavilla | /bianzone/altavilla | active | true | 1 |
| `ve_aa7b1bd5dc` | Buscone | /varzi/buscone | active | true | 1 |
| `ve_13a4412504` | Roma | /montoggio/roma | active | true | 1 |
| `ve_a027377475` | Bruxaboschi | /san-desiderio/bruxaboschi | active | true | 1 |
| `ve_999bef458c` | Ai Burattini | /adrara-san-martino/ai-burattini | active | true | 1 |
| `ve_cfcfc33ff1` | Enoteca San Nicola | /bobbio/enoteca-san-nicola | active | true | 1 |
| `ve_ab4be64dac` | Da Sapì | /esine/da-sapi | active | true | 1 |
| `ve_9712a30490` | Locanda Cacciatori | /ponte-dellolio/locanda-cacciatori | active | true | 1 |
| `ve_8e2969acaf` | Gabbiano 1983 | /corte-de-cortesi/gabbiano-1983 | active | true | 1 |
| `ve_727bd5f9f8` | Trattoria Porteri | /brescia/trattoria-porteri | active | true | 1 |
| `ve_90a0538675` | Antica Trattoria Cattivelli | /monticelli-dongina/antica-trattoria-cattivelli | active | true | 1 |
| `ve_ca3006c29c` | La Brinca | /ne/la-brinca | active | true | 1 |
| `ve_b6c34ddd1c` | Raieü | /cavi-di-lavagna/raieu | active | true | 1 |
| `ve_209fdd1f07` | Nerina | /romeno/nerina | active | true | 1 |
| `ve_654623d855` | Apollonia | /nals/apollonia | active | true | 1 |
| `ve_91c617ef4b` | Locanda al Cervo - zum Hirschen | /san-genesio-atesino/locanda-al-cervo-zum-hirschen | active | true | 1 |
| `ve_e49ee08841` | Osteria Platzegg | /san-michele/osteria-platzegg | active | true | 1 |
| `ve_9dc30edacd` | Vögele | /bolzano/vogele | active | true | 1 |
| `ve_c29d125703` | Dell'Alba | /piadena/dell-alba | active | true | 1 |
| `ve_ce70a58d4e` | Krone | /aldino/krone | active | true | 1 |
| `ve_2e684db862` | Romani | /vicomero-di-torrile/romani | active | true | 1 |
| `ve_87aa915b46` | Dalla Rosa Alda | /san-giorgio-di-valpolicella/dalla-rosa-alda | active | true | 1 |
| `ve_dbbafd1921` | Gassenwirt | /kiens/gassenwirt | active | true | 1 |
| `ve_40e61874fc` | I Tri Siochètt | /parma/i-tri-siochett | active | true | 1 |
| `ve_721bb5c35c` | Locanda Mariella | /calestano/locanda-mariella | active | true | 1 |
| `ve_681b1ea0c3` | Boivin | /levico-terme/boivin | active | true | 1 |
| `ve_d049fe99d0` | 13 Comuni | /velo-veronese/13-comuni | active | true | 1 |
| `ve_6528ab21c3` | Al Bersagliere | /verona/al-bersagliere | active | true | 1 |
| `ve_70ecca2d0c` | Durnwald | /gsies/durnwald | active | true | 1 |
| `ve_e52eea3a39` | Trattoria da Probo | /bagnolo-in-piano/trattoria-da-probo | active | true | 1 |
| `ve_50a9eef90e` | Molin Vecio | /caldogno/molin-vecio | active | true | 1 |
| `ve_b8765fd91c` | Magnagallo | /campogalliano/magnagallo | active | true | 1 |
| `ve_e2ae736d52` | Trattoria da Zamboni | /lapio/trattoria-da-zamboni | active | true | 1 |
| `ve_f1d383b476` | Vecchia Lama | /lama-mocogno/vecchia-lama | active | true | 1 |
| `ve_113197c5fa` | Al Palazzon | /galliera-veneta/al-palazzon | active | true | 1 |
| `ve_10c2901950` | Dalla Libera | /sernaglia-della-battaglia/dalla-libera | active | true | 1 |
| `ve_e6dbed3c4e` | Alla Pace | /sauris/alla-pace | active | true | 1 |
| `ve_5d58186dc5` | L'800 | /argelato/l-800 | active | true | 1 |
| `ve_77f7b52a72` | Antica Trattoria la Grotta dal 1918 | /sasso-marconi/antica-trattoria-la-grotta-dal-1918 | active | true | 1 |
| `ve_10bc2972f2` | Trattoria da Paeto | /pianiga/trattoria-da-paeto | active | true | 1 |
| `ve_733a6ee3c2` | Da Flavio e Fabrizio "Al Teatro" | /mirano/da-flavio-e-fabrizio-al-teatro | active | true | 1 |
| `ve_c39f65ff21` | Al Cambio | /bologna/al-cambio | active | true | 1 |
| `ve_08338f4a91` | Il Sogno | /vetrego/il-sogno | active | true | 1 |
| `ve_d0e6893124` | Ca' d'Frara | /ferrara/ca-d-frara | active | true | 1 |
| `ve_fe78421365` | Osteria Borsò Gambrinus | /san-polo-di-piave/osteria-borso-gambrinus | active | true | 1 |
| `ve_8bdcf2ed56` | Trattoria Lanzagallo | /gaibana/trattoria-lanzagallo | active | true | 1 |
| `ve_3faf2fe366` | Da Burde | /florence/da-burde | active | true | 1 |
| `ve_f7c8ef7bf0` | Trattoria Cibrèo - Il Cibrèino | /florence/trattoria-cibreo-il-cibreino | active | true | 1 |
| `ve_8e0fed5853` | Da Pode | /san-gimignano/da-pode | active | true | 1 |
| `ve_1f5871dd5e` | Antica Trattoria da Miculan | /tricesimo/antica-trattoria-da-miculan | active | true | 1 |
| `ve_f568148b65` | La Baita | /faenza/la-baita | active | true | 1 |
| `ve_031a3333be` | Futura Osteria | /monteriggioni/futura-osteria | active | true | 1 |
| `ve_26bde38dca` | La Cucoma | /san-pancrazio/la-cucoma | active | true | 1 |
| `ve_6c925ea7b2` | Osteria del Mare già il "Votapentole" | /castiglione-della-pescaia/osteria-del-mare-gia-il-votapentole | active | true | 1 |
| `ve_358a138a4e` | Ronchi Rò | /dolegna-del-collio/ronchi-ro | active | true | 1 |
| `ve_6f0cb6f91b` | La Campanara | /galeata/la-campanara | active | true | 1 |
| `ve_499618d3a1` | Al Piave | /mariano-del-friuli/al-piave | active | true | 1 |
| `ve_db8b6655db` | Il Cedro | /moggiona/il-cedro | active | true | 1 |
| `ve_51361bd502` | Lokanda Devetak | /savogna-disonzo/lokanda-devetak | active | true | 1 |
| `ve_9daa7d3da1` | Osteria Bartolini | /milano-marittima/osteria-bartolini | active | true | 1 |
| `ve_e6ecc54a2c` | Dei Cantoni | /longiano/dei-cantoni | active | true | 1 |
| `ve_56476eb257` | Su Gologone | /oliena/su-gologone | active | true | 1 |
| `ve_f6bb615a56` | Da Marchesi | /novafeltria/da-marchesi | active | true | 1 |
| `ve_22c16564ee` | La Bucaccia | /cortona/la-bucaccia | active | true | 1 |
| `ve_2257537765` | Old Friend | /cagliari/old-friend | active | true | 1 |
| `ve_9ce620c2cf` | L'Acquario | /castiglione-del-lago/l-acquario | active | true | 1 |
| `ve_0eb9a4a236` | Osteria dell'Accademia | /montegridolfo/osteria-dell-accademia | active | true | 1 |
| `ve_c97e6d9b8d` | Coxinendi | /sanluri/coxinendi | active | true | 1 |
| `ve_d3f2ceb7f1` | La Gioconda | /cagli/la-gioconda | active | true | 1 |
| `ve_b236cd7ecf` | Da Gregorio | /morrano-nuovo/da-gregorio | active | true | 1 |
| `ve_9ab08aef56` | Stella | /casaglia/stella | active | true | 1 |
| `ve_34c5b2dc43` | Camiano Piccolo | /montefalco/camiano-piccolo | active | true | 1 |
| `ve_6f364f1f70` | Il Casolare dei Segreti | /treia/il-casolare-dei-segreti | active | true | 1 |
| `ve_3760b5881f` | Sot'Ajarchi | /ancona/sot-ajarchi | active | true | 1 |
| `ve_12f75a1b84` | Osteria dei Segreti | /appignano/osteria-dei-segreti | active | true | 1 |
| `ve_fd0d22f8bf` | QuarantunoDodici | /fiumicino/quarantunododici | active | true | 1 |
| `ve_7c26ca4795` | Granaro del Monte | /norcia/granaro-del-monte | active | true | 1 |
| `ve_2736d35d0e` | Trattoria della Fortuna | /monterotondo/trattoria-della-fortuna | active | true | 1 |
| `ve_e7fb43b6d7` | Domenico dal 1968 | /rome/domenico-dal-1968 | active | true | 1 |
| `ve_2596ece7ba` | Li Somari | /tivoli/li-somari | active | true | 1 |
| `ve_9617429319` | Oishi | /teramo/oishi | active | true | 1 |
| `ve_675e55129c` | Nole | /pescara/nole | active | true | 1 |
| `ve_592a0dd388` | Mingone | /carnello/mingone | active | true | 1 |
| `ve_3c1d0edb92` | Clemente | /sulmona/clemente | active | true | 1 |
| `ve_2edfe9ff73` | Taverna dei Caldora | /pacentro/taverna-dei-caldora | active | true | 1 |
| `ve_eb2c5a2e39` | Da Giocondo | /rivisondoli/da-giocondo | active | true | 1 |
| `ve_b5a5b44c26` | La Torre One Fire | /annunziata/la-torre-one-fire | active | true | 1 |
| `ve_31705bfb65` | Al Convento - Casa Torrente | /cetara/al-convento-casa-torrente | active | true | 1 |
| `ve_ff11b31bf9` | La Dispensa di Armatore | /cetara/la-dispensa-di-armatore | active | true | 1 |
| `ve_754a838647` | Forentum | /lavello/forentum | active | true | 1 |
| `ve_c568819f84` | La Chioccia d'Oro | /vallo-della-lucania/la-chioccia-d-oro | active | true | 1 |
| `ve_64f7464dfb` | Angiolina | /pisciotta/angiolina | active | true | 1 |
| `ve_1848057edc` | Antichi Sapori | /montegrosso/antichi-sapori | active | true | 1 |
| `ve_cad5f05561` | Upepidde | /ruvo-di-puglia/upepidde | active | true | 1 |
| `ve_82868136d8` | Al Becco della Civetta | /castelmezzano/al-becco-della-civetta | active | true | 1 |
| `ve_e9e60657cf` | Nangalarruni | /castelbuono/nangalarruni | active | true | 1 |
| `ve_bf9b47dd0b` | Palazzaccio | /castelbuono/palazzaccio | active | true | 1 |
| `ve_d20b22c5c2` | Luna Rossa | /terranova-di-pollino/luna-rossa | active | true | 1 |
| `ve_f5e2259beb` | Antica Filanda | /capri-leone/antica-filanda | active | true | 1 |
| `ve_da34f6a735` | Veneziano | /randazzo/veneziano | active | true | 1 |
| `ve_671458d82c` | Bros' Trattoria | /martina-franca/bros-trattoria | active | true | 1 |
| `ve_60db2c18b1` | Andrea - Sapori Montani | /palazzolo-acreide/andrea-sapori-montani | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-italy`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 632 |
| michelin | city_label | 634 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-italy`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-italy`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
