# Rename apply - rename-majority-2026-germany

Committed 2026-10-09T03:52:09.584Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-majority-2026-germany` |
| CSV | `fixtures/rename/majority-2026-germany.csv` |
| rows in the file | 45 |
| renamed | 45 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Germany set 3: majority rule, G&M does not vote (Q1 A), Q4 A Michelin spelling (Oct 9) |

## Verdicts

Population: all 45 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 45 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 45 row(s) this batch would rename, read from the database before a single name changed.

45 of the 45 hold at least one award. 3 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_07c3761513` | munich | RESTAURANT TANTRIS DNA | Tantris DNA | michelin 2, la-liste 1 | no | /munich/restaurant-tantris-dna |
| `ve_088567d150` | wernigerode | Restaurant Pietsch | Pietsch | michelin 2, gault-millau 1, la-liste 1 | no | /wernigerode/restaurant-pietsch |
| `ve_0d5b0c077c` | frankfurt | Relais & Châteaux Restaurant Lafleur | Lafleur | gault-millau 2, michelin 2, la-liste 1 | no | /frankfurt/relais-chateaux-restaurant-lafleur |
| `ve_23bb4d35e7` | perl | Victor’s Fine Dining by Christian Bau | Victor's Fine Dining by Christian Bau | gault-millau 4, best-chef-awards 2, michelin 2, la-liste 1 | no | /perl/victor-s-fine-dining-by-christian-bau |
| `ve_3e88f531ea` | krun | IKIGAI ** | IKIGAI | gault-millau 2, michelin 2, la-liste 1 | no | /krun/ikigai |
| `ve_42dc793e5d` | hamburg | HAERLIN | Haerlin | gault-millau 2, michelin 2, best-chef-awards 1, la-liste 1 | yes | /hamburg/haerlin |
| `ve_46a88e85fa` | heidelberg | Oben Restaurant | Oben | michelin 2, oad 1 | no | /heidelberg/oben-restaurant |
| `ve_46b86c736a` | baiersbronn | Restaurant Schwarzwaldstube | Schwarzwaldstube | worlds-50-best-restaurants 5, gault-millau 4, michelin 2, best-chef-awards 1, la-liste 1 | yes | /baiersbronn/restaurant-schwarzwaldstube |
| `ve_4a2f3e3575` | bad-neuenahr-ahrweiler | Steinheuers Landgasthof Poststuben | Steinheuers Restaurant | gault-millau 2, michelin 2, la-liste 1 | no | /bad-neuenahr-ahrweiler/steinheuers-landgasthof-poststuben |
| `ve_4a5030d511` | hamburg | Koer Kulinarik & Bar | Koer | michelin 2, gault-millau 1 | no | /hamburg/koer-kulinarik-bar |
| `ve_4a8dad246a` | grassau | Restaurant ES:SENZ | es:senz | best-chef-awards 2, michelin 2, gault-millau 1, la-liste 1 | yes | /grassau/restaurant-es-senz |
| `ve_4ea2da3ad7` | munich | Restaurant Alois - Dallmayr Fine Dining | Alois - Dallmayr Fine Dining | michelin 2, best-chef-awards 1, gault-millau 1, la-liste 1 | no | /munich/restaurant-alois-dallmayr-fine-dining |
| `ve_4feabd098d` | sylt | Bodendorfs im Landhaus Stricker | BODENDORF'S | gault-millau 2, michelin 2, la-liste 1 | no | /sylt/bodendorfs-im-landhaus-stricker |
| `ve_5620195654` | karlsruhe | restaurant sein ** | sein | michelin 2, la-liste 1 | no | /karlsruhe/restaurant-sein |
| `ve_5f55eb3fb2` | hamburg | Restaurant Piment | Piment | michelin 2, gault-millau 1 | no | /hamburg/restaurant-piment |
| `ve_6036462df1` | munich | Restaurant Sparkling Bistro | Sparkling Bistro | michelin 2, oad 1 | no | /munich/restaurant-sparkling-bistro |
| `ve_606583641e` | pulheim | Restaurant Gut Lärchenhof Köln-Pulheim | Gut Lärchenhof | michelin 2, la-liste 1 | no | /pulheim/restaurant-gut-larchenhof-koln-pulheim |
| `ve_6c889649ae` | hamburg | Restaurant Zeik | Zeik | michelin 2, oad 1 | no | /hamburg/restaurant-zeik |
| `ve_6f937f16f3` | leipzig | Stadtpfeiffer Restaurant im Gewandhaus | Stadtpfeiffer | michelin 2, gault-millau 1, la-liste 1 | no | /leipzig/stadtpfeiffer-restaurant-im-gewandhaus |
| `ve_746d8b48a8` | hanover | VOTUM | Votum | michelin 2, gault-millau 1, la-liste 1 | no | /hanover/votum |
| `ve_757e354c50` | hamburg | Petit Amour * | Petit Amour | michelin 2, gault-millau 1 | no | /hamburg/petit-amour |
| `ve_7b61b769fd` | koblenz | GOTTHARDT'S by Yannick Noack | Gotthardt's by Yannick Noack | michelin 2, la-liste 1 | no | /koblenz/gotthardt-s-by-yannick-noack |
| `ve_7d7276d37a` | saarbrucken | Esplanade | ESPLANADE | michelin 2, gault-millau 1, la-liste 1 | no | /saarbrucken/esplanade |
| `ve_7f35ac70b7` | constance | Gourmetrestaurant OPHELIA** | Ophelia | michelin 2, la-liste 1 | no | /constance/gourmetrestaurant-ophelia |
| `ve_81c0fbac28` | cologne | Restaurant La Société Köln | La Société | michelin 2, la-liste 1 | no | /cologne/restaurant-la-societe-koln |
| `ve_840175e4a2` | cologne | Ox&Klee | Ox & Klee | best-chef-awards 2, gault-millau 2, la-liste 1, michelin 1 | no | /cologne/ox-klee |
| `ve_8420b51edf` | berchtesgaden | Gourmet Restaurant PUR | PUR | michelin 2, la-liste 1 | no | /berchtesgaden/gourmet-restaurant-pur |
| `ve_9e5c4b5555` | wachenheim-an-der-weinstra-e | Restaurant Intense | Intense | michelin 2, gault-millau 1, la-liste 1, oad 1 | no | /wachenheim-an-der-weinstra-e/restaurant-intense |
| `ve_9e878421ec` | vaihingen-an-der-enz | Hotel Restaurant Lamm Rosswag | Lamm Rosswag | michelin 2, la-liste 1 | no | /vaihingen-an-der-enz/hotel-restaurant-lamm-rosswag |
| `ve_a4c05fac5d` | berlin | Restaurant Tim Raue | Tim Raue | worlds-50-best-restaurants 8, gault-millau 4, best-chef-awards 2, michelin 2, la-liste 1, oad 1 | no | /berlin/restaurant-tim-raue |
| `ve_ab9eb80120` | munich | Brothers Restaurant | Brothers | michelin 2, la-liste 1, oad 1 | no | /munich/brothers-restaurant |
| `ve_aeba0a7456` | donaueschingen | ÖSCH NOIR | Ösch Noir | michelin 2, la-liste 1 | no | /donaueschingen/osch-noir |
| `ve_b6778cce32` | berlin | Hallmann und Klee | hallmann & klee | michelin 2, gault-millau 1 | no | /berlin/hallmann-und-klee |
| `ve_b7cbf06c68` | freiburg-im-breisgau | Restaurant Eichhalde | Eichhalde | michelin 2, oad 1 | no | /freiburg-im-breisgau/restaurant-eichhalde |
| `ve_bc805069c7` | hamburg | hæbel | HAEBEL | michelin 2, gault-millau 1 | no | /hamburg/h-bel |
| `ve_c0720f338d` | freiburg-im-breisgau | Wolfshöhle | Zur Wolfshöhle | michelin 2, la-liste 1 | no | /freiburg-im-breisgau/wolfshohle |
| `ve_c400f8c12c` | sulzburg | Hotel Restaurant Hirschen - Douce Steiner | Hirschen | michelin 2, gault-millau 1, la-liste 1 | no | /sulzburg/hotel-restaurant-hirschen-douce-steiner |
| `ve_c45d948825` | frankfurt | SOMMERFELD Restaurant | Sommerfeld | michelin 2, gault-millau 1 | no | /frankfurt/sommerfeld-restaurant |
| `ve_caf8559280` | wurzburg | MiZAR Fine Dining | MiZAR | michelin 2, gault-millau 1 | no | /wurzburg/mizar-fine-dining |
| `ve_ce76dfd046` | frankfurt | SEVEN SWANS | Seven Swans | michelin 2, gault-millau 1 | no | /frankfurt/seven-swans |
| `ve_d778d7e03c` | ravensburg | Restaurant Kaisersaal | Kaisersaal | michelin 2, gault-millau 1 | no | /ravensburg/restaurant-kaisersaal |
| `ve_de2b6590e5` | glucksburg | Restaurant Meierei Dirk Luther | Meierei Dirk Luther | gault-millau 3, michelin 2, la-liste 1 | no | /glucksburg/restaurant-meierei-dirk-luther |
| `ve_e7df93eca0` | schluchsee | Landhaus Mühle Schluchsee | Mühle | michelin 2, la-liste 1 | no | /schluchsee/landhaus-muhle-schluchsee |
| `ve_ecf8981481` | berlin | Restaurant Facil | FACIL | gault-millau 3, michelin 2, la-liste 1 | no | /berlin/restaurant-facil |
| `ve_fb89a8302d` | munich | Jan | JAN | best-chef-awards 2, gault-millau 2, michelin 2, la-liste 1, oad 1, worlds-50-best-restaurants 1 | no | /munich/jan |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 45 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,223 | 11,223 | 11,223 |
| awards | 22,389 | 22,389 | 22,389 |
| slugs | 12,509 | 12,509 | 12,509 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 72 | 74 | 74 |
| rename_batches | 7 | 8 | 8 |
| rename_rows | 780 | 825 | 825 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 45 (expected 45) |
| every renamed venue's live name is its new_name | pass | 0 of 45 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 2 (expected 2) |
| rename_rows written equals the rows in the file | pass | 45 (expected 45) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 45 name changes (expected 45), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 45 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_07c3761513` | RESTAURANT TANTRIS DNA | Tantris DNA | michelin | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/tantris-dna |
| `ve_088567d150` | Restaurant Pietsch | Pietsch | michelin | https://guide.michelin.com/us/en/sachsen-anhalt/wernigerode/restaurant/pietsch |
| `ve_0d5b0c077c` | Relais & Châteaux Restaurant Lafleur | Lafleur | michelin | https://guide.michelin.com/us/en/hessen/frankfurt-am-main/restaurant/lafleur |
| `ve_23bb4d35e7` | Victor’s Fine Dining by Christian Bau | Victor's Fine Dining by Christian Bau | la-liste | https://www.laliste.com/places/victors-fine-dining-by-christian-bau-perl-de |
| `ve_3e88f531ea` | IKIGAI ** | IKIGAI | michelin | https://guide.michelin.com/us/en/bayern/krn/restaurant/ikigai-122205 |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-majority-2026-germany`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| la-liste | name | 2 |
| michelin | name | 43 |

Spellings followed: michelin (43), la-liste (2).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-majority-2026-germany`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-majority-2026-germany`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
