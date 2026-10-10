# Ingest stage - michelin-2026-texas

Staged 2026-10-10T14:19:07.121Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-texas` |
| batch id | 14 |
| CSV | `fixtures/ingest/michelin-2026-texas.csv` |
| rows in | 73 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-texas" on every row |
| re-stage | decisions re-applied to the existing batch; 10 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`.

## Verdicts

Population: all 73 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 64 | venue already exists; promote adds the award |
| new_venue | 9 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,223 | 11,232 | +9 |
| awards | 22,389 | 22,462 | +73 |
| listings | 11,223 | 11,232 | +9 |
| slugs | 12,557 | 12,566 | +9 |
| city_label_source | 23,850 | 23,868 | +18 |
| price | 7,048 | 7,048 | +0 |
| source_capture_ledger | 74 | 76 | +2 |

The venue delta is **9**, not the number of `new_venue` rows (9). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,859. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 73 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 14 | new_venue | Kappo Kappo | austin | michelin 2026 | create ve_a195aa4251 (/austin/kappo-kappo), listing published=true, + 1 award |
| 15 | new_venue | Fabrik | austin | michelin 2026 | create ve_89a19471a1 (/austin/fabrik), listing published=true, + 1 award |
| 16 | new_venue | LeRoy and Lewis Barbecue | austin | michelin 2026 | create ve_b8f74cf2b7 (/austin/leroy-and-lewis-barbecue), listing published=true, + 1 award |
| 24 | new_venue | Khói Barbecue | houston | michelin 2026 | create ve_19487f4036 (/houston/khoi-barbecue), listing published=true, + 1 award |
| 30 | new_venue | Kitchen Rumors | houston | michelin 2026 | create ve_c28c3793ac (/houston/kitchen-rumors), listing published=true, + 1 award |
| 1 | match | CorkScrew BBQ | spring | michelin 2026 | + 1 award on ve_149603bb4c |
| 2 | match | Le Jardinier Houston | houston | michelin 2026 | + 1 award on ve_2d80e6f1be |
| 3 | match | March | houston | michelin 2026 | + 1 award on ve_3c782ed879 |
| 4 | match | BCN Taste & Tradition | houston | michelin 2026 | + 1 award on ve_80632217e6 |
| 5 | match | Tatemó | houston | michelin 2026 | + 1 award on ve_c50bc40f8a |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-texas
confirmation: PROMOTE michelin-2026-texas
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 73 rows from fixtures/ingest/michelin-2026-texas.csv |
| 2 | opened the database connection | 0.4s | 0.4s |  |
| 3 | read the source vocabulary | 0.4s | 0.8s | 23 sources |
| 4 | re-read the staged rows | 0.1s | 1.0s | batch 14, 73 rows |
| 5 | row checks | 0.0s | 1.0s | 73 of 73 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.2s | 73 rows |
| 7 | normalised the batch | 0.1s | 1.2s | 73 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.5s | 11 cities |
| 9 | loaded the candidate venues | 0.1s | 1.6s | 57 venues |
| 10 | resolved cities | 0.0s | 1.6s | 73 of 73 settled on one city |
| 11 | resolved venues | 0.0s | 1.6s | 54 matched an existing venue |
| 12 | loose-name pass | 0.3s | 1.9s | 17 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.3s | 2.2s |  |
| 14 | built the promote plan | 0.3s | 2.5s | 9 venues, 73 awards |
| 15 | wrote the verdicts | 0.3s | 2.8s | 73 rows |
| 16 | committed | 0.1s | 2.9s |  |
