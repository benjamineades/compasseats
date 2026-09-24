# Ingest stage - michelin-2026-monaco

Staged 2026-09-24T14:44:41.201Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-monaco` |
| batch id | 7 |
| CSV | `fixtures/ingest/michelin-2026-monaco.csv` |
| rows in | 9 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-monaco" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 9 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 8 | venue already exists; promote adds the award |
| new_venue | 1 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,041 | 11,042 | +1 |
| awards | 21,977 | 21,986 | +9 |
| listings | 11,041 | 11,042 | +1 |
| slugs | 11,854 | 11,855 | +1 |
| city_label_source | 23,478 | 23,480 | +2 |
| price | 7,090 | 7,090 | +0 |
| source_capture_ledger | 27 | 29 | +2 |

The venue delta is **1**, not the number of `new_venue` rows (1). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,678. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 9 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 5 | new_venue | La Table d'Antonio Salvatore au Rampoldi | monaco | michelin 2026 | create ve_e315c56118 (/monaco/la-table-d-antonio-salvatore-au-rampoldi), listing published=true, + 1 award |
| 1 | match | Le Louis XV - Alain Ducasse à l'Hôtel de Paris | monaco | michelin 2026 | + 1 award on ve_885707af72 |
| 2 | match | Les Ambassadeurs by Christophe Cussac | monaco | michelin 2026 | + 1 award on ve_5443ffc0a6 |
| 3 | match | L'Abysse Monte-Carlo | monaco | michelin 2026 | + 1 award on ve_fe843196fd |
| 4 | match | Blue Bay Marcel Ravin | monaco | michelin 2026 | + 1 award on ve_5f2aaf2e90 |
| 6 | match | Le Grill | monaco | michelin 2026 | + 1 award on ve_4643c4153d |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-monaco
confirmation: PROMOTE michelin-2026-monaco
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 9 rows from fixtures/ingest/michelin-2026-monaco.csv |
| 2 | opened the database connection | 0.3s | 0.3s |  |
| 3 | read the source vocabulary | 0.3s | 0.6s | 23 sources |
| 4 | staged the raw rows | 0.2s | 0.8s | batch 7, 9 rows |
| 5 | row checks | 0.0s | 0.8s | 9 of 9 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.0s | 9 rows |
| 7 | normalised the batch | 0.1s | 1.1s | 9 rows, in the database |
| 8 | loaded the candidate cities | 0.2s | 1.3s | 1 cities |
| 9 | loaded the candidate venues | 0.1s | 1.4s | 8 venues |
| 10 | resolved cities | 0.0s | 1.4s | 9 of 9 settled on one city |
| 11 | resolved venues | 0.0s | 1.4s | 8 matched an existing venue |
| 12 | loose-name pass | 0.2s | 1.6s | 1 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.7s |  |
| 14 | built the promote plan | 0.4s | 2.1s | 1 venues, 9 awards |
| 15 | wrote the verdicts | 0.2s | 2.3s | 9 rows |
| 16 | committed | 0.1s | 2.3s |  |
