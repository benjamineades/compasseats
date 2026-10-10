# Ingest stage - michelin-2026-belgium-luxembourg

Staged 2026-10-10T17:22:15.603Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-belgium-luxembourg` |
| batch id | 15 |
| CSV | `fixtures/ingest/michelin-2026-belgium-luxembourg.csv` |
| rows in | 247 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-belgium-luxembourg" on every row |
| re-stage | decisions re-applied to the existing batch; 42 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_nl`, `city_label_nl`, `venue_name_fr`, `city_label_fr`.

## Verdicts

Population: all 247 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 246 | venue already exists; promote adds the award |
| new_venue | 1 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,232 | 11,233 | +1 |
| awards | 22,462 | 22,709 | +247 |
| listings | 11,232 | 11,233 | +1 |
| slugs | 12,575 | 12,576 | +1 |
| city_label_source | 23,868 | 23,870 | +2 |
| price | 7,048 | 7,048 | +0 |
| source_capture_ledger | 77 | 79 | +2 |

The venue delta is **1**, not the number of `new_venue` rows (1). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,866. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 247 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 100 | new_venue | Zur Post | saint-vith | michelin 2026 | create ve_9916c47b98 (/saint-vith/zur-post), listing published=true, + 1 award |
| 1 | match | Zilte | antwerp | michelin 2026 | + 1 award on ve_947c965427 |
| 2 | match | Boury | roeselare | michelin 2026 | + 1 award on ve_16bb8da666 |
| 3 | match | Hertog Jan at Botanic | antwerp | michelin 2026 | + 1 award on ve_471f1bca0c |
| 4 | match | The Jane | antwerp | michelin 2026 | + 1 award on ve_44d34eda5e |
| 5 | match | L'Eau Vive | arbre | michelin 2026 | + 1 award on ve_5dcdd5c3f3 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-belgium-luxembourg
confirmation: PROMOTE michelin-2026-belgium-luxembourg
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 247 rows from fixtures/ingest/michelin-2026-belgium-luxembourg.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.1s | 0.1s | 23 sources |
| 4 | re-read the staged rows | 0.0s | 0.2s | batch 15, 247 rows |
| 5 | row checks | 0.0s | 0.2s | 247 of 247 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.2s | 247 rows |
| 7 | normalised the batch | 0.0s | 0.2s | 247 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.3s | 162 cities |
| 9 | loaded the candidate venues | 0.0s | 0.3s | 219 venues |
| 10 | resolved cities | 0.0s | 0.3s | 247 of 247 settled on one city |
| 11 | resolved venues | 0.0s | 0.3s | 205 matched an existing venue |
| 12 | loose-name pass | 0.0s | 0.4s | 40 would-be new venues checked, 14 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.4s |  |
| 14 | built the promote plan | 0.1s | 0.5s | 1 venues, 247 awards |
| 15 | wrote the verdicts | 0.1s | 0.6s | 247 rows |
| 16 | committed | 0.0s | 0.6s |  |
