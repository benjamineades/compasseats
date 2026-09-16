# Ingest stage - michelin-2026-spain

Staged 2026-09-16T21:11:36.084Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-spain` |
| batch id | 6 |
| CSV | `fixtures/ingest/michelin-2026-spain.csv` |
| rows in | 493 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-spain" on every row |
| re-stage | decisions re-applied to the existing batch; 304 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 493 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 485 | venue already exists; promote adds the award |
| new_venue | 8 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,034 | 11,042 | +8 |
| awards | 21,964 | 22,457 | +493 |
| listings | 11,034 | 11,042 | +8 |
| slugs | 11,847 | 11,855 | +8 |
| city_label_source | 23,464 | 23,480 | +16 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 24 | 26 | +2 |

The venue delta is **8**, not the number of `new_venue` rows (8). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,666. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 493 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 61 | new_venue | Terra | fisterra | michelin 2026 | create ve_89ca903ac2 (/fisterra/terra), listing published=true, + 1 award |
| 68 | new_venue | Casa Marcelo | santiago-de-compostela | michelin 2026 | create ve_de7750ef83 (/santiago-de-compostela/casa-marcelo), listing published=true, + 1 award |
| 115 | new_venue | Ola Martín Berasategui | bilbao | michelin 2026 | create ve_8cbf21d12d (/bilbao/ola-martin-berasategui), listing published=true, + 1 award |
| 225 | new_venue | Villa Retiro | xerta | michelin 2026 | create ve_17475f658b (/xerta/villa-retiro), listing published=true, + 1 award |
| 232 | new_venue | Origen | carcaixent | michelin 2026 | create ve_38feaaecd2 (/carcaixent/origen), listing published=true, + 1 award |
| 1 | match | Casa Marcial | arriondas | michelin 2026 | + 1 award on ve_4d8c220a0a |
| 2 | match | Atrio | caceres | michelin 2026 | + 1 award on ve_ed5d30f034 |
| 3 | match | Cenador de Amós | villaverde-de-pontones | michelin 2026 | + 1 award on ve_fcf0e4d0d8 |
| 4 | match | Azurmendi | larrabetzu | michelin 2026 | + 1 award on ve_f79e9512dd |
| 5 | match | Aponiente | cadiz | michelin 2026 | + 1 award on ve_d0ed7ab726 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-spain
confirmation: PROMOTE michelin-2026-spain
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 493 rows from fixtures/ingest/michelin-2026-spain.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.0s | 0.2s | 23 sources |
| 4 | re-read the staged rows | 0.0s | 0.2s | batch 6, 493 rows |
| 5 | row checks | 0.0s | 0.2s | 493 of 493 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.2s | 493 rows |
| 7 | normalised the batch | 0.0s | 0.3s | 493 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.4s | 272 cities |
| 9 | loaded the candidate venues | 0.0s | 0.4s | 215 venues |
| 10 | resolved cities | 0.0s | 0.4s | 493 of 493 settled on one city |
| 11 | resolved venues | 0.0s | 0.4s | 189 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.4s | 295 would-be new venues checked, 32 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.5s |  |
| 14 | built the promote plan | 0.1s | 0.5s | 8 venues, 493 awards |
| 15 | wrote the verdicts | 0.1s | 0.7s | 493 rows |
| 16 | committed | 0.0s | 0.7s |  |
