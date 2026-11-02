# Ingest stage - michelin-2026-switzerland

Staged 2026-11-02T23:57:25.719Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-switzerland` |
| batch id | 20 |
| CSV | `fixtures/ingest/michelin-2026-switzerland.csv` |
| rows in | 225 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-switzerland" on every row |
| re-stage | decisions re-applied to the existing batch; 129 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_de`, `city_label_de`.

## Verdicts

Population: all 225 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 195 | venue already exists; promote adds the award |
| new_venue | 30 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,293 | 11,323 | +30 |
| awards | 25,097 | 25,322 | +225 |
| listings | 11,293 | 11,323 | +30 |
| slugs | 13,022 | 13,052 | +30 |
| city_label_source | 23,989 | 24,049 | +60 |
| price | 7,727 | 7,727 | +0 |
| source_capture_ledger | 186 | 188 | +2 |

The venue delta is **30**, not the number of `new_venue` rows (30). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,999. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 225 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 31 | new_venue | Restaurant de l'Hôtel de Ville | ollon | michelin 2026 | create ve_b76744c249 (/ollon/restaurant-de-l-hotel-de-ville), listing published=true, + 1 award |
| 34 | new_venue | Restaurant LA | basel | michelin 2026 | create ve_db48bdeac3 (/basel/restaurant-la), listing published=true, + 1 award |
| 39 | new_venue | La Croix d'Or | ballaigues | michelin 2026 | create ve_a3d2920b36 (/ballaigues/la-croix-d-or), listing published=true, + 1 award |
| 78 | new_venue | Ristorante con enoteca Origini | morbio-inferiore | michelin 2026 | create ve_b28565111d (/morbio-inferiore/ristorante-con-enoteca-origini), listing published=true, + 1 award |
| 79 | new_venue | Bärenstobe | gonten | michelin 2026 | create ve_256ad43e81 (/gonten/barenstobe), listing published=true, + 1 award |
| 1 | match | Cheval Blanc by Peter Knogl | basel | michelin 2026 | + 1 award on ve_46e15d96d7 |
| 2 | match | Schloss Schauenstein | furstenau | michelin 2026 | + 1 award on ve_6ce9f52552 |
| 3 | match | The Japanese Restaurant | andermatt | michelin 2026 | + 1 award on ve_f337673106 |
| 4 | match | Sven Wassmer Memories | bad-ragaz | michelin 2026 | + 1 award on ve_034adbb581 |
| 5 | match | Restaurant de l'Hôtel de Ville | crissier | michelin 2026 | + 1 award on ve_a024c1df89 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-switzerland
confirmation: PROMOTE michelin-2026-switzerland
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 225 rows from fixtures/ingest/michelin-2026-switzerland.csv |
| 2 | opened the database connection | 0.4s | 0.4s |  |
| 3 | read the source vocabulary | 0.4s | 0.8s | 23 sources |
| 4 | re-read the staged rows | 0.2s | 0.9s | batch 20, 225 rows |
| 5 | row checks | 0.0s | 0.9s | 225 of 225 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.2s | 225 rows |
| 7 | normalised the batch | 0.1s | 1.2s | 225 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.5s | 132 cities |
| 9 | loaded the candidate venues | 0.1s | 1.6s | 112 venues |
| 10 | resolved cities | 0.0s | 1.6s | 225 of 225 settled on one city |
| 11 | resolved venues | 0.0s | 1.6s | 96 matched an existing venue |
| 12 | loose-name pass | 0.2s | 1.8s | 126 would-be new venues checked, 38 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.2s | 2.1s |  |
| 14 | built the promote plan | 0.3s | 2.4s | 30 venues, 225 awards |
| 15 | wrote the verdicts | 0.3s | 2.7s | 225 rows |
| 16 | committed | 0.1s | 2.8s |  |
