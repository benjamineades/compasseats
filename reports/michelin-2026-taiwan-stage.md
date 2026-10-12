# Ingest stage - michelin-2026-taiwan

Staged 2026-10-12T00:48:02.699Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-taiwan` |
| batch id | 17 |
| CSV | `fixtures/ingest/michelin-2026-taiwan.csv` |
| rows in | 207 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-taiwan" on every row |
| re-stage | decisions re-applied to the existing batch; 117 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_zh`, `city_label_zh`.

## Verdicts

Population: all 207 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 146 | venue already exists; promote adds the award |
| new_venue | 61 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,254 | 11,315 | +61 |
| awards | 22,659 | 22,866 | +207 |
| listings | 11,254 | 11,315 | +61 |
| slugs | 12,716 | 12,777 | +61 |
| city_label_source | 23,912 | 24,034 | +122 |
| price | 7,048 | 7,048 | +0 |
| source_capture_ledger | 86 | 88 | +2 |

The venue delta is **61**, not the number of `new_venue` rows (61). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,886. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 207 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 8 | new_venue | Mizue | taipei | michelin 2026 | create ve_5559e9180c (/taipei/mizue), listing published=true, + 1 award |
| 9 | new_venue | Molino de Urdániz | taipei | michelin 2026 | create ve_46199fee65 (/taipei/molino-de-urdaniz), listing published=true, + 1 award |
| 13 | new_venue | A Cut | taipei | michelin 2026 | create ve_7fb7d7c34d (/taipei/a-cut), listing published=true, + 1 award |
| 14 | new_venue | Ad Astra | taipei | michelin 2026 | create ve_b017ac2790 (/taipei/ad-astra), listing published=true, + 1 award |
| 15 | new_venue | aMaze | taipei | michelin 2026 | create ve_b3f74363c9 (/taipei/amaze), listing published=true, + 1 award |
| 1 | match | JL STUDIO | taichung | michelin 2026 | + 1 award on ve_506425696b |
| 2 | match | Le Palais | taipei | michelin 2026 | + 1 award on ve_be6f09d00f |
| 3 | match | Taïrroir | taipei | michelin 2026 | + 1 award on ve_87a1c45c26 |
| 4 | match | A | taipei | michelin 2026 | + 1 award on ve_269ab60a27 |
| 5 | match | Eika | taipei | michelin 2026 | + 1 award on ve_8010044864 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-taiwan
confirmation: PROMOTE michelin-2026-taiwan
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 207 rows from fixtures/ingest/michelin-2026-taiwan.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.1s | 0.2s | 23 sources |
| 4 | re-read the staged rows | 0.0s | 0.2s | batch 17, 207 rows |
| 5 | row checks | 0.0s | 0.2s | 207 of 207 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.2s | 207 rows |
| 7 | normalised the batch | 0.0s | 0.2s | 207 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.3s | 7 cities |
| 9 | loaded the candidate venues | 0.0s | 0.3s | 97 venues |
| 10 | resolved cities | 0.0s | 0.3s | 207 of 207 settled on one city |
| 11 | resolved venues | 0.0s | 0.3s | 90 matched an existing venue |
| 12 | loose-name pass | 0.0s | 0.4s | 114 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.4s |  |
| 14 | built the promote plan | 0.1s | 0.5s | 61 venues, 207 awards |
| 15 | wrote the verdicts | 0.1s | 0.6s | 207 rows |
| 16 | committed | 0.0s | 0.6s |  |
