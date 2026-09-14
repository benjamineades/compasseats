# Ingest stage - michelin-2026-france

Staged 2026-09-14T17:37:41.587Z. **Nothing has been promoted.** This run wrote to
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
| re-stage | decisions re-applied to the existing batch; 515 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 1071 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 719 | venue already exists; promote adds the award |
| new_venue | 351 | promote creates the venue, listing, slug, city labels and the award |
| skipped | 1 | you marked it skip in the review CSV |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 10,907 | 11,258 | +351 |
| awards | 21,814 | 22,884 | +1070 |
| listings | 10,907 | 11,258 | +351 |
| slugs | 11,164 | 11,515 | +351 |
| city_label_source | 22,098 | 22,800 | +702 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 10 | 12 | +2 |

The venue delta is **351**, not the number of `new_venue` rows (351). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,527. Promote refuses to let that number drop.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 10 | new_venue | Alléno Paris au Pavillon Ledoyen | paris | michelin 2026 | create ve_b789ba25d1 (/paris/alleno-paris-au-pavillon-ledoyen), listing published=true, + 1 award |
| 13 | new_venue | Les Prés d'Eugénie - Michel Guérard | eugenie-les-bains | michelin 2026 | create ve_d86ea5a112 (/eugenie-les-bains/les-pres-d-eugenie-michel-guerard), listing published=true, + 1 award |
| 19 | new_venue | Pic | valence | michelin 2026 | create ve_5d75d60685 (/valence/pic), listing published=true, + 1 award |
| 25 | new_venue | Le Petit Nice | marseille | michelin 2026 | create ve_e2d533b42f (/marseille/le-petit-nice), listing published=true, + 1 award |
| 32 | new_venue | Maison Ronan Kervarrec | saint-gregoire | michelin 2026 | create ve_58eb328fae (/saint-gregoire/maison-ronan-kervarrec), listing published=true, + 1 award |
| 1 | match | Le Coquillage | saint-meloir-des-ondes | michelin 2026 | + 1 award on ve_98fdf69141 |
| 2 | match | La Marine | ? | michelin 2026 | + 1 award on ve_07fc048900 |
| 3 | match | Christopher Coutanceau | la-rochelle | michelin 2026 | + 1 award on ve_2d5b8da238 |
| 4 | match | Le Pré Catelan | paris | michelin 2026 | + 1 award on ve_b4d17e56d3 |
| 5 | match | Le Cinq | paris | michelin 2026 | + 1 award on ve_05469dccb6 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-france
confirmation: PROMOTE michelin-2026-france
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 1071 rows from fixtures/ingest/michelin-2026-france.csv |
| 2 | opened the database connection | 0.4s | 0.4s |  |
| 3 | read the source vocabulary | 0.4s | 0.8s | 23 sources |
| 4 | re-read the staged rows | 0.3s | 1.0s | batch 3, 1071 rows |
| 5 | row checks | 0.0s | 1.0s | 1071 of 1071 rows still live |
| 6 | loaded the live rows into the resolver | 0.3s | 1.3s | 1071 rows |
| 7 | normalised the batch | 0.1s | 1.4s | 1071 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.7s | 624 cities |
| 9 | loaded the candidate venues | 0.1s | 1.8s | 602 venues |
| 10 | resolved cities | 0.0s | 1.8s | 1066 of 1071 settled on one city |
| 11 | resolved venues | 0.1s | 1.9s | 556 matched an existing venue |
| 12 | loose-name pass | 0.3s | 2.2s | 497 would-be new venues checked, 156 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.3s | 2.5s |  |
| 14 | built the promote plan | 0.3s | 2.9s | 351 venues, 1070 awards |
| 15 | wrote the verdicts | 0.6s | 3.4s | 1071 rows |
| 16 | committed | 0.1s | 3.5s |  |
