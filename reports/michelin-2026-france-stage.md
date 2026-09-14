# Ingest stage - michelin-2026-france

Staged 2026-09-14T14:38:02.410Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-france` |
| batch id | 3 |
| CSV | `fixtures/ingest/michelin-2026-france.csv` |
| rows in | 1071 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-france" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 1071 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 556 | venue already exists; promote adds the award |
| new_venue | 458 | promote creates the venue, listing, slug, city labels and the award |
| review_city | 45 | the city could not be resolved to exactly one row |
| review_venue | 12 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 10,907 | 11,365 | +458 |
| awards | 21,814 | 22,828 | +1014 |
| listings | 10,907 | 11,365 | +458 |
| slugs | 11,164 | 11,622 | +458 |
| city_label_source | 22,098 | 23,014 | +916 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 10 | 12 | +2 |

The venue delta is **458**, not the number of `new_venue` rows (458). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,527. Promote refuses to let that number drop.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 8 | new_venue | Le Gabriel - La Réserve Paris | paris | michelin 2026 | create ve_18b42b6b70 (/paris/le-gabriel-la-reserve-paris), listing published=true, + 1 award |
| 10 | new_venue | Alléno Paris au Pavillon Ledoyen | paris | michelin 2026 | create ve_b789ba25d1 (/paris/alleno-paris-au-pavillon-ledoyen), listing published=true, + 1 award |
| 11 | new_venue | Kei | paris | michelin 2026 | create ve_eac912bbdc (/paris/kei), listing published=true, + 1 award |
| 12 | new_venue | Plénitude - Cheval Blanc Paris | paris | michelin 2026 | create ve_7834f348a7 (/paris/plenitude-cheval-blanc-paris), listing published=true, + 1 award |
| 13 | new_venue | Les Prés d'Eugénie - Michel Guérard | eugenie-les-bains | michelin 2026 | create ve_d86ea5a112 (/eugenie-les-bains/les-pres-d-eugenie-michel-guerard), listing published=true, + 1 award |
| 1 | match | Le Coquillage | saint-meloir-des-ondes | michelin 2026 | + 1 award on ve_98fdf69141 |
| 3 | match | Christopher Coutanceau | la-rochelle | michelin 2026 | + 1 award on ve_2d5b8da238 |
| 4 | match | Le Pré Catelan | paris | michelin 2026 | + 1 award on ve_b4d17e56d3 |
| 5 | match | Le Cinq | paris | michelin 2026 | + 1 award on ve_05469dccb6 |
| 6 | match | Pierre Gagnaire | paris | michelin 2026 | + 1 award on ve_7b51bfe39a |

## Review

**57 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-france-review.csv` in Sheets, fill the `decision` column, save it as CSV,
and re-run the stage workflow with the same batch key plus the decisions file.

| decision | means |
|---|---|
| `use:ve_xxxxxxxxxx` | this row is that existing venue |
| `new` | create a new venue for it |
| `city:ci_xxxxxxxx` | the city is that one |
| `skip` | leave this row out of the promote |
| `city:ci_x;use:ve_y` | both, in one cell |

| reason | rows |
|---|---|
| `city_not_found` | 43 |
| `same_key_other_city` | 9 |
| `norm_key_too_short` | 3 |
| `country_label_disagrees` | 2 |

## Next

Clear the 57 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 1071 rows from fixtures/ingest/michelin-2026-france.csv |
| 2 | opened the database connection | 0.3s | 0.3s |  |
| 3 | read the source vocabulary | 0.4s | 0.6s | 23 sources |
| 4 | staged the raw rows | 0.6s | 1.3s | batch 3, 1071 rows |
| 5 | row checks | 0.0s | 1.3s | 1071 of 1071 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.5s | 1071 rows |
| 7 | normalised the batch | 0.1s | 1.6s | 1071 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.9s | 584 cities |
| 9 | loaded the candidate venues | 0.2s | 2.0s | 602 venues |
| 10 | resolved cities | 0.0s | 2.0s | 1026 of 1071 settled on one city |
| 11 | resolved venues | 0.0s | 2.0s | 556 matched an existing venue |
| 12 | dedupe, subsume and rank conflicts | 0.3s | 2.4s |  |
| 13 | built the promote plan | 0.5s | 2.8s | 458 venues, 1014 awards |
| 14 | wrote the verdicts | 0.7s | 3.5s | 1071 rows |
| 15 | committed | 0.1s | 3.5s |  |
