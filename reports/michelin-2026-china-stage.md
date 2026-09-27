# Ingest stage - michelin-2026-china

Staged 2026-09-27T19:54:27.982Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-china` |
| batch id | 9 |
| CSV | `fixtures/ingest/michelin-2026-china.csv` |
| rows in | 469 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-china" on every row |
| re-stage | decisions re-applied to the existing batch; 423 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 469 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 309 | venue already exists; promote adds the award |
| new_venue | 160 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,061 | 11,221 | +160 |
| awards | 22,024 | 22,493 | +469 |
| listings | 11,061 | 11,221 | +160 |
| slugs | 11,874 | 12,034 | +160 |
| city_label_source | 23,518 | 23,838 | +320 |
| price | 7,090 | 7,090 | +0 |
| source_capture_ledger | 32 | 34 | +2 |

The venue delta is **160**, not the number of `new_venue` rows (160). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,699. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 469 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 4 | new_venue | Jingji | beijing | michelin 2026 | create ve_13e93ccbe7 (/beijing/jingji), listing published=true, + 1 award |
| 10 | new_venue | Chao Shang Chao (Xicheng) | beijing | michelin 2026 | create ve_2eeac39d82 (/beijing/chao-shang-chao-xicheng), listing published=true, + 1 award |
| 18 | new_venue | Lu Style (Anding Road) | beijing | michelin 2026 | create ve_9758a288cd (/beijing/lu-style-anding-road), listing published=true, + 1 award |
| 22 | new_venue | Rong Pao | beijing | michelin 2026 | create ve_c1203f68bf (/beijing/rong-pao), listing published=true, + 1 award |
| 23 | new_venue | Seventh Son | beijing | michelin 2026 | create ve_abccb8710d (/beijing/seventh-son), listing published=true, + 1 award |
| 1 | match | Chao Shang Chao (Chaoyang) | beijing | michelin 2026 | + 1 award on ve_f4a69bd8e0 |
| 2 | match | Xin Rong Ji (Xinyuan South Road) | beijing | michelin 2026 | + 1 award on ve_ed8fe96699 |
| 3 | match | Blackswan | beijing | michelin 2026 | + 1 award on ve_b075220a1b |
| 5 | match | King's Joy | beijing | michelin 2026 | + 1 award on ve_e61dc1a188 |
| 6 | match | Lamdre | beijing | michelin 2026 | + 1 award on ve_c95452bfed |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-china
confirmation: PROMOTE michelin-2026-china
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 469 rows from fixtures/ingest/michelin-2026-china.csv |
| 2 | opened the database connection | 0.3s | 0.4s |  |
| 3 | read the source vocabulary | 0.4s | 0.8s | 23 sources |
| 4 | re-read the staged rows | 0.3s | 1.0s | batch 9, 469 rows |
| 5 | row checks | 0.0s | 1.0s | 469 of 469 rows still live |
| 6 | loaded the live rows into the resolver | 0.3s | 1.3s | 469 rows |
| 7 | normalised the batch | 0.1s | 1.4s | 469 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.7s | 15 cities |
| 9 | loaded the candidate venues | 0.1s | 1.8s | 71 venues |
| 10 | resolved cities | 0.0s | 1.8s | 469 of 469 settled on one city |
| 11 | resolved venues | 0.0s | 1.8s | 46 matched an existing venue |
| 12 | loose-name pass | 0.3s | 2.1s | 416 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.3s | 2.4s |  |
| 14 | built the promote plan | 0.3s | 2.7s | 160 venues, 469 awards |
| 15 | wrote the verdicts | 0.5s | 3.2s | 469 rows |
| 16 | committed | 0.1s | 3.2s |  |
