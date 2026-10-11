# Rename apply - rename-michelin-2026-netherlands

**DRY RUN - rolled back.** Everything below is what would have happened.
Every name in the database is exactly as it was.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-netherlands` |
| CSV | `fixtures/rename/michelin-2026-netherlands-names.csv` |
| rows in the file | 83 |
| renamed | 83 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | (none) |

## Verdicts

Population: all 83 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 83 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 83 row(s) this batch would rename, read from the database before a single name changed.

83 of the 83 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_f321850bef` | harderwijk | t Nonnetje | 't Nonnetje | michelin 2, la-liste 1 | no | /harderwijk/t-nonnetje |
| `ve_b24eaf6c99` | nijmegen | Restaurant De Nieuwe Winkel | De Nieuwe Winkel | michelin 2, best-chef-awards 1, la-liste 1, oad 1 | no | /nijmegen/restaurant-de-nieuwe-winkel |
| `ve_face3f9c07` | reijmerstok | Brut172 by Hans van Wolde | Brut172 | michelin 2, best-chef-awards 1, la-liste 1, oad 1 | no | /reijmerstok/brut172-by-hans-van-wolde |
| `ve_7bc851dd3c` | gemert | Restaurant GEM. | GEM. | best-chef-awards 2, michelin 2 | no | /gemert/restaurant-gem |
| `ve_9b831f5bbc` | amsterdam | Restaurant Flore | Flore | michelin 2 | no | /amsterdam/restaurant-flore |
| `ve_7224a4542b` | rotterdam | François Geurds FG Restaurant | François Geurds (FG) Restaurant | michelin 2 | no | /rotterdam/francois-geurds-fg-restaurant |
| `ve_1f8f963b4f` | apeldoorn | Restaurant Zenith Apeldoorn | Zenith | michelin 2 | no | /apeldoorn/restaurant-zenith-apeldoorn |
| `ve_13d1c74cc0` | doornenburg | Restaurant Rijnzicht | Rijnzicht | michelin 2 | no | /doornenburg/restaurant-rijnzicht |
| `ve_b1ceb3d235` | harderwijk | Restaurant Basiliek | Basiliek | michelin 2 | no | /harderwijk/restaurant-basiliek |
| `ve_bda8db9d57` | heelsum | Restaurant De Kromme Dissel | De Kromme Dissel | michelin 2 | no | /heelsum/restaurant-de-kromme-dissel |
| `ve_9a1ba82b9f` | gulpen | Restaurant Atelier* | Restaurant Atelier | michelin 2 | no | /gulpen/restaurant-atelier |
| `ve_8e2aeaade5` | maastricht | Au Coin | Au Coin des Bons Enfants | michelin 2 | no | /maastricht/au-coin |
| `ve_df2327ee2f` | maastricht | Château Neercanne | Restaurant Château Neercanne | michelin 2 | no | /maastricht/chateau-neercanne |
| `ve_96c8ee2308` | maastricht | Restaurant Tout à Fait | Tout à Fait | michelin 2 | no | /maastricht/restaurant-tout-a-fait |
| `ve_f2462deed0` | roermond | Restaurant ONE | ONE | michelin 2 | no | /roermond/restaurant-one |
| `ve_2b6f989ad6` | weert | Restaurant MARREES | Marrees | michelin 2 | no | /weert/restaurant-marrees |
| `ve_e8decd292e` | cromvoirt | Noble Kitchen | Nami | michelin 2 | no | /cromvoirt/noble-kitchen |
| `ve_59174e9976` | eindhoven | Restaurant Wiesen | Wiesen | michelin 2 | no | /eindhoven/restaurant-wiesen |
| `ve_b4e4ea5891` | leende | Restaurant Sabero | Sabero | michelin 2 | no | /leende/restaurant-sabero |
| `ve_a4deafeacb` | oosterhout | Restaurant Zout & Citroen | Zout & Citroen | michelin 2 | no | /oosterhout/restaurant-zout-citroen |
| `ve_5b4e040477` | ravenstein | Restaurant Versaen | Versaen | michelin 2 | no | /ravenstein/restaurant-versaen |
| `ve_aa32c5eb35` | tilburg | Restaurant Monarh | Monarh | michelin 2 | no | /tilburg/restaurant-monarh |
| `ve_3d15d10757` | amsterdam | Restaurant Bougainville | Bougainville | best-chef-awards 2, michelin 2 | no | /amsterdam/restaurant-bougainville |
| `ve_00d0fd700d` | amsterdam | CUE- Bar Restaurant Amsterdam | CUE | michelin 2 | no | /amsterdam/cue-bar-restaurant-amsterdam |
| `ve_5b8c51a028` | amsterdam | De Kas | Restaurant De Kas | michelin 2 | no | /amsterdam/de-kas |
| `ve_2c9dedb1ab` | amsterdam | Rijks | RIJKS | best-chef-awards 2, michelin 2 | no | /amsterdam/rijks |
| `ve_f195955a11` | amsterdam | Restaurant The White Room by Jacob Jan Boerma | The White Room by Jacob Jan Boerma | michelin 2 | no | /amsterdam/restaurant-the-white-room-by-jacob-jan-boerma |
| `ve_40a12813d1` | amsterdam | Restaurant Wils | Wils | michelin 1, oad 1 | no | /amsterdam/restaurant-wils |
| `ve_30ce551052` | castricum | Restaurant Apicius | Apicius | michelin 2 | no | /castricum/restaurant-apicius |
| `ve_555263f67a` | den-hoorn | Bij Jef Restaurant & Hotel | Bij Jef | michelin 2 | no | /den-hoorn/bij-jef-restaurant-hotel |
| `ve_ca8780e097` | haarlem | Hotel ML | ML | michelin 2 | no | /haarlem/hotel-ml |
| `ve_5d24eedf45` | schoorl | Restaurant Hotel Merlet | Merlet | michelin 2 | no | /schoorl/restaurant-hotel-merlet |
| `ve_a88ddc65af` | blokzijl | Restaurant and Residence Kaatje bij de Sluis | Kaatje bij de Sluis | michelin 2 | no | /blokzijl/restaurant-and-residence-kaatje-bij-de-sluis |
| `ve_c43663f716` | enschede | Restaurant Joann * | Joann | michelin 2 | no | /enschede/restaurant-joann |
| `ve_b79b41fc90` | hengelo | t Lansink (Hotel - Restaurant) | 't Lansink | michelin 2 | no | /hengelo/t-lansink-hotel-restaurant |
| `ve_a772160160` | linschoten | Burgemeester | Restaurant De Burgemeester | michelin 2 | no | /linschoten/burgemeester |
| `ve_22b1bffaf9` | loenen-aan-de-vecht | t Amsterdammertje | 't Amsterdammertje | michelin 2 | no | /loenen-aan-de-vecht/t-amsterdammertje |
| `ve_97fcea6748` | utrecht | Grand Hotel Karel V | Karel 5 | michelin 2 | no | /utrecht/grand-hotel-karel-v |
| `ve_ba3fdffef4` | utrecht | Restaurant Maeve | Maeve | michelin 2 | no | /utrecht/restaurant-maeve |
| `ve_a77dcd0a75` | vreeland | Restaurant en Boutique hotel De Nederlanden | De Nederlanden | michelin 2 | no | /vreeland/restaurant-en-boutique-hotel-de-nederlanden |
| `ve_4b6d80064f` | wijk-bij-duurstede | Restaurant Lutum | Lutum | michelin 2 | no | /wijk-bij-duurstede/restaurant-lutum |
| `ve_1459a779b0` | bergambacht | Pieters Restaurant* | Pieters Restaurant | michelin 2 | no | /bergambacht/pieters-restaurant |
| `ve_b8992c91b9` | capelle-aan-den-ijssel | Restaurant Perceel | Perceel | michelin 2, oad 1 | no | /capelle-aan-den-ijssel/restaurant-perceel |
| `ve_83486b3c8f` | delft | Novaela Delft | Novaela | michelin 2 | no | /delft/novaela-delft |
| `ve_6783425187` | gouda | Restaurant LIZZ* | LIZZ | michelin 2 | no | /gouda/restaurant-lizz |
| `ve_edf2240d7a` | rijswijk | `t Ganzenest | 't Ganzenest | michelin 2 | no | /rijswijk/t-ganzenest |
| `ve_6d8d52eedd` | rotterdam | Restaurant The Millèn | The Millèn | michelin 2 | no | /rotterdam/restaurant-the-millen |
| `ve_b914824fca` | voorburg | Relais & Chateaux - Central Park Voorburg | Central Park | michelin 2 | no | /voorburg/relais-chateaux-central-park-voorburg |
| `ve_f4ff77e92f` | warmond | Mulberry Restaurant | De Moerbei | michelin 2 | no | /warmond/mulberry-restaurant |
| `ve_e99b14f627` | doetinchem | Eterij & Tapperij 't Raedthuys | Raedthuys | michelin 2 | no | /doetinchem/eterij-tapperij-t-raedthuys |
| `ve_632cb3448f` | hattem | Restaurant de Voorburcht | De Voorburcht | michelin 2 | no | /hattem/restaurant-de-voorburcht |
| `ve_17558691e6` | winterswijk | LEV. by Mike | LEV by Mike | michelin 2 | no | /winterswijk/lev-by-mike |
| `ve_8841853403` | groningen | Restaurant Niemeijer | Niemeijer | michelin 2 | no | /groningen/restaurant-niemeijer |
| `ve_7c77e49360` | beek | De Lindeboom | De Lindeboom New Style | michelin 2 | no | /beek/de-lindeboom |
| `ve_b686768fb7` | de-mortel | Restaurant de Wilg | De Wilg | michelin 2 | no | /de-mortel/restaurant-de-wilg |
| `ve_ff90d8abe8` | eersel | Restaurant Promessa - Gastronomisch food atelier | Promessa | michelin 2 | no | /eersel/restaurant-promessa-gastronomisch-food-atelier |
| `ve_e094424894` | eindhoven | NEV Restaurant | NEV | michelin 2 | no | /eindhoven/nev-restaurant |
| `ve_2f0323b2a7` | hapert | Divino | DiVino | michelin 2 | no | /hapert/divino |
| `ve_bedf5be74d` | hoeven | Restaurant Pouwe | Pouwe | michelin 2 | no | /hoeven/restaurant-pouwe |
| `ve_b85a78427d` | oirschot | Restaurant La Fleurie | La Fleurie | michelin 2 | no | /oirschot/restaurant-la-fleurie |
| `ve_b31bc94cb2` | tilburg | Kok Verhoeven Brasserij & Restaurant, Tilburg | Kok Verhoeven | michelin 2 | no | /tilburg/kok-verhoeven-brasserij-restaurant-tilburg |
| `ve_86b5dbeb5f` | tilburg | Te Koop in Tilburg,- | Te Koop in Tilburg | michelin 2 | no | /tilburg/te-koop-in-tilburg |
| `ve_e71da1928d` | vessem | MOUT&HOUT | MOUT & HOUT | michelin 2 | no | /vessem/mout-hout |
| `ve_3a6bad88c8` | amsterdam | A-Fusion Food & Drinks | A-Fusion | michelin 2 | no | /amsterdam/a-fusion-food-drinks |
| `ve_1da0211e1b` | amsterdam | Sea Palace Restaurant | Sea Palace | michelin 2 | no | /amsterdam/sea-palace-restaurant |
| `ve_ff245f22ed` | amsterdam | Serre | Serre Restaurant | michelin 2 | no | /amsterdam/serre |
| `ve_436d945a64` | hilversum | Restaurant Chef aan de Werf | Chef aan de Werf | michelin 2 | no | /hilversum/restaurant-chef-aan-de-werf |
| `ve_0c753febae` | hellendoorn | Landgoed De Uitkijk | De Uitkijk | michelin 2 | no | /hellendoorn/landgoed-de-uitkijk |
| `ve_a309b31aa5` | lattrop | Landgoed De Holtweijde | Landgoed de Holtweijde | michelin 2 | no | /lattrop/landgoed-de-holtweijde |
| `ve_fa7a0c8453` | steenwijk | Bovenmeester diner & lounge | Bovenmeester | michelin 2 | no | /steenwijk/bovenmeester-diner-lounge |
| `ve_a06ad7b6fa` | amersfoort | Restaurant de Aubergerie | De Aubergerie | michelin 2 | no | /amersfoort/restaurant-de-aubergerie |
| `ve_a9503b0aeb` | linschoten | Restaurant Bij Mette | Bij Mette | michelin 2 | no | /linschoten/restaurant-bij-mette |
| `ve_8e65e2b9f6` | maartensdijk | Restaurant Zilt & Zoet | Zilt & Zoet | michelin 2 | no | /maartensdijk/restaurant-zilt-zoet |
| `ve_363c8af067` | montfoort | de Schans by Mike en Wes | De Schans by Mike & Wes | michelin 2 | no | /montfoort/de-schans-by-mike-en-wes |
| `ve_b0d7eda923` | goes | Restaurant Karel V | Karel V | michelin 2 | no | /goes/restaurant-karel-v |
| `ve_ac16258354` | delft | Restaurant Le Vieux Jean | Le Vieux Jean | michelin 2 | no | /delft/restaurant-le-vieux-jean |
| `ve_6e52e4314d` | the-hague | Restaurant Basaal | Basaal | michelin 2 | no | /the-hague/restaurant-basaal |
| `ve_517aafe885` | the-hague | Resumé by 6&24 ( wijnbar & restaurant ) | Resumé by 6&24 | michelin 2 | no | /the-hague/resume-by-6-24-wijnbar-restaurant |
| `ve_20c3a1a968` | leidschendam | Restaurant Bij Erik | Bij Erik | michelin 2 | no | /leidschendam/restaurant-bij-erik |
| `ve_836694345a` | noorden | Hotel Restaurant "De Watergeus" | De Watergeus | michelin 2 | no | /noorden/hotel-restaurant-de-watergeus |
| `ve_a095cdd0ca` | papendrecht | De Ertepeller | Bistro De Ertepeller | michelin 2 | no | /papendrecht/de-ertepeller |
| `ve_405054cfee` | rotterdam | Restaurant Rotonde | Rotonde | michelin 2 | no | /rotterdam/restaurant-rotonde |
| `ve_d52c8144a9` | rotterdam | VINEUM (wine)restaurant | Vineum | michelin 2 | no | /rotterdam/vineum-wine-restaurant |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 83 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,254 | 11,254 | 11,254 |
| awards | 22,659 | 22,659 | 22,659 |
| slugs | 12,638 | 12,638 | 12,638 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 85 | 86 | 86 |
| rename_batches | 10 | 11 | 11 |
| rename_rows | 941 | 1,024 | 1,024 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 83 (expected 83) |
| every renamed venue's live name is its new_name | pass | 0 of 83 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 83 (expected 83) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 83 name changes (expected 83), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 83 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_f321850bef` | t Nonnetje | 't Nonnetje | michelin | https://guide.michelin.com/us/en/gelderland/harderwijk/restaurant/t-nonnetje |
| `ve_b24eaf6c99` | Restaurant De Nieuwe Winkel | De Nieuwe Winkel | michelin | https://guide.michelin.com/us/en/gelderland/nijmegen/restaurant/de-nieuwe-winkel |
| `ve_face3f9c07` | Brut172 by Hans van Wolde | Brut172 | michelin | https://guide.michelin.com/us/en/limburg/reijmerstok/restaurant/brut172 |
| `ve_7bc851dd3c` | Restaurant GEM. | GEM. | michelin | https://guide.michelin.com/us/en/noord-brabant/gemert/restaurant/gem-by-soenil-bahadoer |
| `ve_9b831f5bbc` | Restaurant Flore | Flore | michelin | https://guide.michelin.com/us/en/noord-holland/amsterdam/restaurant/flore |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-netherlands`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 82 |

1 row(s) name `venue` as their source - the venue's own website settled the spelling. The venue is not a publisher and holds no row in `award_sources`, which `source_capture_ledger.publisher` points at, so those rows are not in the ledger. They are in `rename_rows` with their URL, like every other row.

Spellings followed: michelin (82), venue (1).

## Undo

Nothing to undo: this was a dry run. Untick the box to do it for real.
