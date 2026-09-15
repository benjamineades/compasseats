# Ingest stage - michelin-2026-japan

Staged 2026-09-15T13:20:31.418Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-japan` |
| batch id | 5 |
| CSV | `fixtures/ingest/michelin-2026-japan.csv` |
| rows in | 585 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-japan" on every row |
| re-stage | decisions re-applied to the existing batch; 164 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 585 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 570 | venue already exists; promote adds the award |
| new_venue | 15 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,575 | 11,590 | +15 |
| awards | 23,516 | 24,101 | +585 |
| listings | 11,575 | 11,590 | +15 |
| slugs | 11,832 | 11,847 | +15 |
| city_label_source | 23,434 | 23,464 | +30 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 16 | 18 | +2 |

The venue delta is **15**, not the number of `new_venue` rows (15). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 11,195. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 585 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 44 | new_venue | Sukiyabashi Jiro Roppongiten | tokyo | michelin 2026 | create ve_175f7d63c2 (/tokyo/sukiyabashi-jiro-roppongiten), listing published=true, + 1 award |
| 170 | new_venue | JO | tokyo | michelin 2026 | create ve_1fa2789470 (/tokyo/jo), listing published=true, + 1 award |
| 177 | new_venue | Sassa | tokyo | michelin 2026 | create ve_961188cfbe (/tokyo/sassa), listing published=true, + 1 award |
| 290 | new_venue | Ukitacho Ima | osaka | michelin 2026 | create ve_f191378d18 (/osaka/ukitacho-ima), listing published=true, + 1 award |
| 328 | new_venue | Ñ | osaka | michelin 2026 | create ve_6dba6cdecb (/osaka/n), listing published=true, + 1 award |
| 1 | match | Kagurazaka Ishikawa | tokyo | michelin 2026 | + 1 award on ve_1228812987 |
| 2 | match | Kanda | tokyo | michelin 2026 | + 1 award on ve_df282c7523 |
| 3 | match | L'OSIER | tokyo | michelin 2026 | + 1 award on ve_2e8a0ddae8 |
| 4 | match | RyuGin | tokyo | michelin 2026 | + 1 award on ve_b3a910372f |
| 5 | match | Harutaka | tokyo | michelin 2026 | + 1 award on ve_b3fa3db8ee |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-japan
confirmation: PROMOTE michelin-2026-japan
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 585 rows from fixtures/ingest/michelin-2026-japan.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.2s | 0.3s | 23 sources |
| 4 | re-read the staged rows | 0.1s | 0.4s | batch 5, 585 rows |
| 5 | row checks | 0.0s | 0.4s | 585 of 585 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.5s | 585 rows |
| 7 | normalised the batch | 0.1s | 0.6s | 585 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.7s | 4 cities |
| 9 | loaded the candidate venues | 0.1s | 0.7s | 458 venues |
| 10 | resolved cities | 0.0s | 0.7s | 585 of 585 settled on one city |
| 11 | resolved venues | 0.0s | 0.7s | 421 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.8s | 156 would-be new venues checked, 4 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 0.9s |  |
| 14 | built the promote plan | 0.1s | 1.1s | 15 venues, 585 awards |
| 15 | wrote the verdicts | 0.2s | 1.3s | 585 rows |
| 16 | committed | 0.0s | 1.3s |  |
