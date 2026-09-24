# Ingest stage - michelin-2026-colorado-southwest

Staged 2026-09-24T18:30:40.957Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-colorado-southwest` |
| batch id | 8 |
| CSV | `fixtures/ingest/michelin-2026-colorado-southwest.csv` |
| rows in | 46 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-colorado-southwest" on every row |
| re-stage | decisions re-applied to the existing batch; 8 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 46 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 26 | venue already exists; promote adds the award |
| new_venue | 20 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,041 | 11,061 | +20 |
| awards | 21,978 | 22,024 | +46 |
| listings | 11,041 | 11,061 | +20 |
| slugs | 11,854 | 11,874 | +20 |
| city_label_source | 23,478 | 23,518 | +40 |
| price | 7,090 | 7,090 | +0 |
| source_capture_ledger | 29 | 31 | +2 |

The venue delta is **20**, not the number of `new_venue` rows (20). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,678. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 46 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 10 | new_venue | Milpero | denver | michelin 2026 | create ve_ae2045d603 (/denver/milpero), listing published=true, + 1 award |
| 11 | new_venue | Pig and Tiger | denver | michelin 2026 | create ve_e13bd5c2c2 (/denver/pig-and-tiger), listing published=true, + 1 award |
| 17 | new_venue | Rougarou | denver | michelin 2026 | create ve_64c540d88e (/denver/rougarou), listing published=true, + 1 award |
| 25 | new_venue | Monte | south-salt-lake | michelin 2026 | create ve_8e41aa3f13 (/south-salt-lake/monte), listing published=true, + 1 award |
| 29 | new_venue | Huarachis Taqueria | phoenix | michelin 2026 | create ve_febc96b2d2 (/phoenix/huarachis-taqueria), listing published=true, + 1 award |
| 1 | match | The Wolf's Tailor | denver | michelin 2026 | + 1 award on ve_edfbed50ed |
| 2 | match | Brutø | denver | michelin 2026 | + 1 award on ve_059ad5aef5 |
| 3 | match | Kizaki | denver | michelin 2026 | + 1 award on ve_0a702c2a37 |
| 4 | match | Mezcaleria Alma | denver | michelin 2026 | + 1 award on ve_7976a1ce68 |
| 5 | match | Alma Fonda Fina | denver | michelin 2026 | + 1 award on ve_c57906eb91 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-colorado-southwest
confirmation: PROMOTE michelin-2026-colorado-southwest
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 46 rows from fixtures/ingest/michelin-2026-colorado-southwest.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.2s | 0.4s | 23 sources |
| 4 | re-read the staged rows | 0.1s | 0.4s | batch 8, 46 rows |
| 5 | row checks | 0.0s | 0.4s | 46 of 46 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.5s | 46 rows |
| 7 | normalised the batch | 0.0s | 0.5s | 46 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.7s | 12 cities |
| 9 | loaded the candidate venues | 0.1s | 0.7s | 25 venues |
| 10 | resolved cities | 0.0s | 0.7s | 46 of 46 settled on one city |
| 11 | resolved venues | 0.0s | 0.7s | 20 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.9s | 24 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.0s |  |
| 14 | built the promote plan | 0.1s | 1.1s | 20 venues, 46 awards |
| 15 | wrote the verdicts | 0.1s | 1.2s | 46 rows |
| 16 | committed | 0.0s | 1.3s |  |
