# Rename apply - rename-michelin-2026-belgium-luxembourg

Committed 2026-10-10T21:17:52.703Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-belgium-luxembourg` |
| CSV | `fixtures/rename/michelin-2026-belgium-luxembourg-names.csv` |
| rows in the file | 98 |
| renamed | 98 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | (none) |

## Verdicts

Population: all 98 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 98 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 98 row(s) this batch would rename, read from the database before a single name changed.

98 of the 98 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_471f1bca0c` | antwerp | Hertog Jan | Hertog Jan at Botanic | best-chef-awards 2, la-liste 1, michelin 1, oad 1 | no | /antwerp/hertog-jan |
| `ve_5c5efedaa3` | brussels | Karen Torosyan \| Bozar Restaurant | Bozar Restaurant | michelin 1 | no | /brussels/karen-torosyan-bozar-restaurant |
| `ve_c4905d26e1` | gent | Restaurant Vrijmoed | Vrijmoed | la-liste 1, michelin 1, oad 1 | no | /gent/restaurant-vrijmoed |
| `ve_e7a553ee2d` | liernu | L’air du temps | L'Air du Temps | best-chef-awards 2, la-liste 1, michelin 1, oad 1 | no | /liernu/l-air-du-temps |
| `ve_f37b4ad551` | antwerp | t Fornuis | 't Fornuis | michelin 1 | no | /antwerp/t-fornuis |
| `ve_dd03d8b240` | antwerp | Bistrot Du Nord | Bistrot du Nord | michelin 1 | no | /antwerp/bistrot-du-nord |
| `ve_b670ec376b` | antwerp | NATHAN | Nathan | michelin 1 | no | /antwerp/nathan |
| `ve_8b36632223` | antwerp | The Butcher's Son | The Butcher's son | michelin 1 | no | /antwerp/the-butcher-s-son |
| `ve_ae9aa91a95` | blaregnies | LES GOURMANDS | Les Gourmands | michelin 1 | no | /blaregnies/les-gourmands |
| `ve_468a30c972` | braine-lalleud | Restaurant Philippe Meyers | Philippe Meyers | michelin 1 | no | /braine-lalleud/restaurant-philippe-meyers |
| `ve_fdae8759e8` | bruges | Zet'joe | Zet'Joe by Geert Van Hecke | michelin 1 | no | /bruges/zet-joe |
| `ve_d032778a48` | comblain-au-pont | Un Max De Goût | Un Max de Goût | michelin 1 | no | /comblain-au-pont/un-max-de-gout |
| `ve_09efee41a4` | durbuy | Le Grand Verre * | Le Grand Verre | michelin 1 | no | /durbuy/le-grand-verre |
| `ve_66537da4ec` | elverdinge | Hostellerie Saint Nicolas | Hostellerie St-Nicolas | michelin 1 | no | /elverdinge/hostellerie-saint-nicolas |
| `ve_4f24cc4292` | emptinne | La Grange D'Hamois | La Grange d'Hamois | michelin 1 | no | /emptinne/la-grange-d-hamois |
| `ve_9800fc3d45` | francorchamps | Le Roannay - Hôtel & Restaurant gastronomique | Le Roannay | michelin 1 | no | /francorchamps/le-roannay-hotel-restaurant-gastronomique |
| `ve_575318c985` | gent | Oak | Oak Gent | michelin 1, oad 1 | no | /gent/oak |
| `ve_1afd049bdc` | gentbrugge | Moscou by Danny Horseele | Moscou By Danny Horseele | michelin 1 | no | /gentbrugge/moscou-by-danny-horseele |
| `ve_06b64a074c` | brussels | Humus x Hortense | humus x hortense | best-chef-awards 2, michelin 1, oad 1 | no | /brussels/humus-x-hortense |
| `ve_d77a753ab2` | jodoigne | Aux Petits Oignons | Aux petits oignons | michelin 1 | no | /jodoigne/aux-petits-oignons |
| `ve_52e96b573b` | lier | Neon Restaurant | Neon | michelin 1 | no | /lier/neon-restaurant |
| `ve_05384958c9` | lotenhulle | LE JULIEN | Le Julien | michelin 1 | no | /lotenhulle/le-julien |
| `ve_618825ea94` | modave | La Roseraie | La Roseraie Modave | michelin 1 | no | /modave/la-roseraie |
| `ve_bcc10d2527` | namur | Attablez Vous | Attablez-vous | michelin 1 | no | /namur/attablez-vous |
| `ve_f8affe6239` | nieuwkerken-waas | t Korennaer | 't Korennaer | michelin 1 | no | /nieuwkerken-waas/t-korennaer |
| `ve_324cd596a2` | ohain | La Table Lasne by Alain Bianchin | La Table-Lasne by Alain Bianchin | michelin 1 | no | /ohain/la-table-lasne-by-alain-bianchin |
| `ve_d75a5042da` | oostende | Haut | HAUT | michelin 1 | no | /oostende/haut |
| `ve_30dbd3a2c3` | ouwegem | Benoit & Bernard Dewitte | Benoit Dewitte | best-chef-awards 1, michelin 1, oad 1 | no | /ouwegem/benoit-bernard-dewitte |
| `ve_4638cb79fa` | paliseul | Le Gastronome - Jean Vrijdaghs et Sébastien Hankard | Le Gastronome | michelin 1 | no | /paliseul/le-gastronome-jean-vrijdaghs-et-sebastien-hankard |
| `ve_9d15e85330` | quevy-le-grand | L'Impératif d'Eole | l'Impératif d'Éole | michelin 1 | no | /quevy-le-grand/l-imperatif-d-eole |
| `ve_4c23346b8d` | roucourt | Vicomté ( au Domaine d'Arondeau) | Vicomté | michelin 1 | no | /roucourt/vicomte-au-domaine-d-arondeau |
| `ve_384f9e83db` | saint-vith | Restaurant Quadras | Quadras | michelin 1 | no | /saint-vith/restaurant-quadras |
| `ve_6ba7a99d9f` | saint-georges-sur-meuse | RESTAURANT PHILIPPE FAUCHET | Philippe Fauchet | michelin 1 | no | /saint-georges-sur-meuse/restaurant-philippe-fauchet |
| `ve_c49d63e28b` | sint-denijs-westrem | Sensum | Sensum Gent | michelin 1 | no | /sint-denijs-westrem/sensum |
| `ve_2060afb5e5` | sint-idesbald | Carcasse Sint-Idesbald | Carcasse | 101-best-steakhouses 2, michelin 1 | no | /sint-idesbald/carcasse-sint-idesbald |
| `ve_9ad260ce0b` | bruges | GOFFIN | Goffin | michelin 1 | no | /bruges/goffin |
| `ve_86522b697f` | soheit-tinlot | Le Coq Aux Champs | Le Coq aux Champs | michelin 1 | no | /soheit-tinlot/le-coq-aux-champs |
| `ve_f6f79735ba` | st-martens-voeren | Hoeve de Bies | Hoeve De Bies | michelin 1 | no | /st-martens-voeren/hoeve-de-bies |
| `ve_ca124b940a` | strombeek-bever | Restaurant 't Stoveke by Daniel Antuna | 't Stoveke | michelin 1 | no | /strombeek-bever/restaurant-t-stoveke-by-daniel-antuna |
| `ve_fa0a74ade5` | temploux | L'Essentiel | l'Essentiel | michelin 1 | no | /temploux/l-essentiel |
| `ve_8950855ba4` | tongeren | ALTER | Alter | michelin 1 | no | /tongeren/alter |
| `ve_b54394ce22` | waasmunster | Hangzhou at West Lake Four Seasons Hotel Chinese Food Restaurant | Sense | michelin 1 | no | /waasmunster/hangzhou-at-west-lake-four-seasons-hotel-chinese-food-restaurant |
| `ve_b97f8e03f2` | wommelgem | KOMAF | Komaf | michelin 1 | no | /wommelgem/komaf |
| `ve_846bc23e55` | achet | Au Gré des Saisons | Au gré des Saisons | michelin 1 | no | /achet/au-gre-des-saisons |
| `ve_35c65305ff` | antwerp | Ko'uzi Sushi | Ko'uzi | michelin 1 | no | /antwerp/ko-uzi-sushi |
| `ve_a4c13c0895` | antwerp | NI SHIFU | Ni Shifu | michelin 1 | no | /antwerp/ni-shifu |
| `ve_11508fdf29` | arquennes | Il Était Une Fois Toi et Moi | il était une fois toi et moi | michelin 1 | no | /arquennes/il-etait-une-fois-toi-et-moi |
| `ve_df55827b2e` | auderghem | Restaurant Maza'j | Maza'j | michelin 1 | no | /auderghem/restaurant-maza-j |
| `ve_4cfcb0b1f8` | bois-de-villers | Au Phil des Saveurs Restaurant | Au Phil des Saveurs | michelin 1 | no | /bois-de-villers/au-phil-des-saveurs-restaurant |
| `ve_aa3d5b7bfe` | bornem | H-eat | Biestro H-eat | michelin 1 | no | /bornem/h-eat |
| `ve_2bacf674bb` | bourlers | Ferme des 4 Saisons | Ferme des 4 saisons | michelin 1 | no | /bourlers/ferme-des-4-saisons |
| `ve_e23d66227e` | braine-lalleud | MAÏNOÏ | Maïnoï | michelin 1 | no | /braine-lalleud/mainoi |
| `ve_5b184ff3d4` | bruges | JACOBIN | Jacobin | michelin 1 | no | /bruges/jacobin |
| `ve_794b5553a6` | bruges | ONSLOW | Onslow | michelin 1 | no | /bruges/onslow |
| `ve_e3e4a01189` | bruges | Quatre vins | Quatre Vins | michelin 1 | no | /bruges/quatre-vins |
| `ve_c9865ca374` | bruges | TouGou Fijnproeverij | Tou.Gou | michelin 1 | no | /bruges/tougou-fijnproeverij |
| `ve_8f0cd9bb7e` | brussels | Alley mian | Alley Mian | michelin 1 | no | /brussels/alley-mian |
| `ve_28f9ddc338` | brussels | Kline Brussels | Kline | michelin 1 | no | /brussels/kline-brussels |
| `ve_fc7dffdafa` | brussels | Le Selecto | Selecto | michelin 1 | no | /brussels/le-selecto |
| `ve_7174ba7f2a` | charleroi | Restaurant Vilain | Vilain | michelin 1 | no | /charleroi/restaurant-vilain |
| `ve_04aa85aa06` | corbion | Logis Hôtel des Ardennes | Des Ardennes | michelin 1 | no | /corbion/logis-hotel-des-ardennes |
| `ve_50b6008dd6` | emblem | ChingChing by Dong & Winston | Ching Ching | michelin 1 | no | /emblem/chingching-by-dong-winston |
| `ve_a918784a19` | erpent | Le comptoir de l’eau vive | Comptoir de l'Eau Vive | michelin 1 | no | /erpent/le-comptoir-de-l-eau-vive |
| `ve_6ecac78f7c` | falaen | Restaurant La Fermette | La Fermette | michelin 1 | no | /falaen/restaurant-la-fermette |
| `ve_2e4c00544b` | floriffoux | Emulsion | Émulsion | michelin 1 | no | /floriffoux/emulsion |
| `ve_c085e3ec55` | gent | Le Baan Thai | Le Baan Thaï | michelin 1 | no | /gent/le-baan-thai |
| `ve_9654d07896` | grivegnee | LA CANTINETTA | la cantinetta | michelin 1 | no | /grivegnee/la-cantinetta |
| `ve_37738a3338` | herve | L'Epicurien | l'Epicurien | michelin 1 | no | /herve/l-epicurien |
| `ve_bb565ec969` | hollain | Sel et Poivre® | Sel et Poivre | michelin 1 | no | /hollain/sel-et-poivre |
| `ve_878728fc53` | brussels | car bon | Car Bon | michelin 1 | no | /brussels/car-bon |
| `ve_b9f3f52ba0` | brussels | Le Tournant ️ | Le Tournant | michelin 1 | no | /brussels/le-tournant |
| `ve_26b0d9e3de` | brussels | ONGBA | ÔNGBÀ | michelin 1 | no | /brussels/ongba |
| `ve_f2271abe3d` | lacuisine | Au Coeur de Lacuisine | Au Cœur de Lacuisine | michelin 1 | no | /lacuisine/au-coeur-de-lacuisine |
| `ve_f1a31693c8` | liege | la cuisine de yannick | La Cuisine de Yannick | michelin 1 | no | /liege/la-cuisine-de-yannick |
| `ve_4d36b5869e` | liege | Le Bistrot d’En Face | Le Bistrot d'en Face | michelin 1 | no | /liege/le-bistrot-d-en-face |
| `ve_f58010aad4` | marche-en-famenne | Restaurant Les 4 Saisons | Les 4 Saisons | michelin 1 | no | /marche-en-famenne/restaurant-les-4-saisons |
| `ve_3f0a04e9d0` | martelange | Le Vertige des Saveurs Hotel | Brasserie N4 | michelin 1 | no | /martelange/le-vertige-des-saveurs-hotel |
| `ve_37b56f18ee` | namur | L'Espieglerie | L'Espièglerie | michelin 1 | no | /namur/l-espieglerie |
| `ve_7f6c8e75d9` | orchimont | JEUX DE GOÛTS | Jeux de Goûts | michelin 1 | no | /orchimont/jeux-de-gouts |
| `ve_e6616640db` | oudenaarde | THE FOX | The FOX | michelin 1 | no | /oudenaarde/the-fox |
| `ve_43cdff8b79` | ouffet | LA MAISON THAI | La Maison Thai | michelin 1 | no | /ouffet/la-maison-thai |
| `ve_723ca88058` | schaerbeek | YokaTomo | Yoka Tomo | michelin 1 | no | /schaerbeek/yokatomo |
| `ve_7f14eb6bd4` | snaaskerke | Plat Préféré | Plat préféré | michelin 1 | no | /snaaskerke/plat-prefere |
| `ve_3aa3af0e19` | thuillies | La Petite GAYOLE | La Petite Gayole | michelin 1 | no | /thuillies/la-petite-gayole |
| `ve_51eb55ca3a` | thuin | Bagú | Bagù | michelin 1 | no | /thuin/bagu |
| `ve_3832c8b08b` | brussels | Au Repos de la Montagne | Au repos de la montagne | michelin 1 | no | /brussels/au-repos-de-la-montagne |
| `ve_18344fd208` | vosselaar | DE FARMASIE | De Farmasie | michelin 1 | no | /vosselaar/de-farmasie |
| `ve_80ec01173a` | ways | Dis moi où? | dis-moi où ? | michelin 1 | no | /ways/dis-moi-ou |
| `ve_9251733083` | yvoir | Mona Lisa 🇮🇹 | Mona Lisa | michelin 1 | no | /yvoir/mona-lisa |
| `ve_38ce7e4899` | frisange | Restaurant Louis Linster | Louis Linster | la-liste 1, michelin 1 | no | /frisange/restaurant-louis-linster |
| `ve_1288c5e852` | findel | Fields Restaurant | Fields | la-liste 1, michelin 1 | no | /findel/fields-restaurant |
| `ve_ed8f44761d` | lauterborn | Archibald De Prince - Table & Chambres | Archibald De Prince | michelin 1 | no | /lauterborn/archibald-de-prince-table-chambres |
| `ve_d444bd9ab6` | luxembourg | Grünewald Chef's Table | Grünewald Chef’s Table | michelin 1 | no | /luxembourg/grunewald-chef-s-table |
| `ve_0f8bc2c2ee` | luxembourg | Restaurant Le Lys | Le Lys | michelin 1 | no | /luxembourg/restaurant-le-lys |
| `ve_b80193ad37` | luxembourg | Restaurant Ryodo | Ryôdô | michelin 1 | no | /luxembourg/restaurant-ryodo |
| `ve_af82c7b8b5` | roeser | RISTORANTE FANI | Fani | michelin 1 | no | /roeser/ristorante-fani |
| `ve_a09c3624d8` | schouweiler | Guillou Campagne schouweiler dippach | Guillou Campagne | michelin 1 | no | /schouweiler/guillou-campagne-schouweiler-dippach |
| `ve_fd611ed9c6` | huldange | K Restaurant | K restaurant | michelin 1 | no | /huldange/k-restaurant |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 98 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,233 | 11,233 | 11,233 |
| awards | 22,463 | 22,463 | 22,463 |
| slugs | 12,576 | 12,576 | 12,576 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 80 | 83 | 83 |
| rename_batches | 9 | 10 | 10 |
| rename_rows | 843 | 941 | 941 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 98 (expected 98) |
| every renamed venue's live name is its new_name | pass | 0 of 98 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 3 (expected 3) |
| rename_rows written equals the rows in the file | pass | 98 (expected 98) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 98 name changes (expected 98), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 98 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_471f1bca0c` | Hertog Jan | Hertog Jan at Botanic | michelin | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/hertog-jan-at-botanic |
| `ve_5c5efedaa3` | Karen Torosyan \| Bozar Restaurant | Bozar Restaurant | michelin | https://guide.michelin.com/us/en/bruxelles-capitale/bruxelles/restaurant/bozar-restaurant |
| `ve_c4905d26e1` | Restaurant Vrijmoed | Vrijmoed | michelin | https://guide.michelin.com/us/en/oost-vlaanderen/gent/restaurant/vrijmoed |
| `ve_e7a553ee2d` | L’air du temps | L'Air du Temps | la-liste | https://www.laliste.com/places/lair-du-temps-eghezee-be |
| `ve_f37b4ad551` | t Fornuis | 't Fornuis | michelin | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/t-fornuis |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-belgium-luxembourg`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| la-liste | name | 2 |
| michelin | name | 94 |
| oad | name | 1 |

1 row(s) name `venue` as their source - the venue's own website settled the spelling. The venue is not a publisher and holds no row in `award_sources`, which `source_capture_ledger.publisher` points at, so those rows are not in the ledger. They are in `rename_rows` with their URL, like every other row.

Spellings followed: michelin (94), la-liste (2), oad (1), venue (1).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2026-belgium-luxembourg`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2026-belgium-luxembourg`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
