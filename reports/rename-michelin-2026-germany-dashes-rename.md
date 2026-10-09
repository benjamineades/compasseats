# Rename apply - rename-michelin-2026-germany-dashes

Committed 2026-10-09T03:50:48.619Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-germany-dashes` |
| CSV | `fixtures/rename/michelin-2026-germany-dashes.csv` |
| rows in the file | 14 |
| renamed | 14 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Germany set 2: spaced dash or pipe, rulings 1 and 2, Ben Q2 A and Q3 A (Oct 9) |

## Verdicts

Population: all 14 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 14 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 14 row(s) this batch would rename, read from the database before a single name changed.

14 of the 14 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_4642412030` | vreden | Büschker's Stuben | Am Kring - Büschker's Stuben | michelin 2 | no | /vreden/buschker-s-stuben |
| `ve_4a64b5f6c8` | aue-bad-schlema | Tausendgüldenstube | Lotters Wirtschaft - Tausendgüldenstube | michelin 2 | no | /aue-bad-schlema/tausendguldenstube |
| `ve_68870e5395` | bischofswiesen | Kulturhof Stanggass | Kulturhof Stanggass - Gasthaus | michelin 2 | no | /bischofswiesen/kulturhof-stanggass |
| `ve_70803bb3f6` | kirchdorf | Christians Restaurant - Christian F. Grainer | Christian's Restaurant | michelin 2 | no | /kirchdorf/christians-restaurant-christian-f-grainer |
| `ve_8a307c9575` | presseck | Berghof Restaurant Ursprung | Gasthof Berghof - Ursprung | michelin 2 | no | /presseck/berghof-restaurant-ursprung |
| `ve_97a6a500a3` | grenzach-wyhlen | Eckert Fine Dining | Eckert | michelin 2 | no | /grenzach-wyhlen/eckert-fine-dining |
| `ve_b2449fc6ee` | bad-neuenahr-ahrweiler | Brogsitter Gasthaus Sanct Peter | Restaurant Brogsitter | michelin 2 | no | /bad-neuenahr-ahrweiler/brogsitter-gasthaus-sanct-peter |
| `ve_b7c3a95507` | eltville-am-rhein | Pfortenhaus Kloster Eberbach | Ente Wiesbaden | michelin 2 | no | /eltville-am-rhein/pfortenhaus-kloster-eberbach |
| `ve_c86214d7a6` | gmund-am-tegernsee | Restaurant Ostiner Stub'n | Hirsch & Jägerstüberl - Ostiner Stub'n | michelin 2 | no | /gmund-am-tegernsee/restaurant-ostiner-stub-n |
| `ve_cd2f7ba3a5` | bietigheim-bissingen | Maerz Restaurant | Maerz - Das Restaurant | michelin 2 | no | /bietigheim-bissingen/maerz-restaurant |
| `ve_ce8789421f` | feldberger-seenlandschaft | Hotel & Restaurant Alte Schule Fürstenhagen - Daniel Schmidthaler | Alte Schule - Klassenzimmer | michelin 2 | no | /feldberger-seenlandschaft/hotel-restaurant-alte-schule-furstenhagen-daniel-schmidthaler |
| `ve_deb007b6bd` | donaueschingen | hotel die burg | die burg | michelin 2 | no | /donaueschingen/hotel-die-burg |
| `ve_e91ff49724` | nuremberg | ZweiSinn Meiers - Bistro "à-la-carte-Restaurant" | ZweiSinn Meiers | michelin 2 | no | /nuremberg/zweisinn-meiers-bistro-a-la-carte-restaurant |
| `ve_f208304e7d` | wackersberg | Tölzer Schießstätte am Buchberg - Michaela Hager | Tölzer Schießstätte | michelin 2 | no | /wackersberg/tolzer-schie-statte-am-buchberg-michaela-hager |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 14 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

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
| source_capture_ledger | 71 | 72 | 72 |
| rename_batches | 6 | 7 | 7 |
| rename_rows | 766 | 780 | 780 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 14 (expected 14) |
| every renamed venue's live name is its new_name | pass | 0 of 14 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 14 (expected 14) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 14 name changes (expected 14), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 14 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_4642412030` | Büschker's Stuben | Am Kring - Büschker's Stuben | michelin | https://guide.michelin.com/us/en/nordrhein-westfalen/vreden/restaurant/buschker-s-stuben |
| `ve_4a64b5f6c8` | Tausendgüldenstube | Lotters Wirtschaft - Tausendgüldenstube | michelin | https://guide.michelin.com/us/en/sachsen/aue/restaurant/lotters-wirtschaft-tausendguldenstube |
| `ve_68870e5395` | Kulturhof Stanggass | Kulturhof Stanggass - Gasthaus | michelin | https://guide.michelin.com/us/en/bayern/bischofswiesen/restaurant/kulturhof-stanggass-gasthaus |
| `ve_70803bb3f6` | Christians Restaurant - Christian F. Grainer | Christian's Restaurant | michelin | https://guide.michelin.com/us/en/bayern/kirchdorf/restaurant/christian-s-restaurant-gasthof-grainer |
| `ve_8a307c9575` | Berghof Restaurant Ursprung | Gasthof Berghof - Ursprung | michelin | https://guide.michelin.com/us/en/bayern/presseck/restaurant/gasthof-berghof-ursprung |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-germany-dashes`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 14 |

Spellings followed: michelin (14).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2026-germany-dashes`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2026-germany-dashes`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
