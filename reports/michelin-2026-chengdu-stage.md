# Ingest stage - michelin-2026-chengdu

Staged 2026-09-29T21:44:14.246Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-chengdu` |
| batch id | 12 |
| CSV | `fixtures/ingest/michelin-2026-chengdu.csv` |
| rows in | 15 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-chengdu" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 15 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 13 | venue already exists; promote adds the award |
| new_venue | 2 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,211 | 11,213 | +2 |
| awards | 22,241 | 22,256 | +15 |
| listings | 11,211 | 11,213 | +2 |
| slugs | 12,310 | 12,312 | +2 |
| city_label_source | 23,826 | 23,830 | +4 |
| price | 7,056 | 7,056 | +0 |
| source_capture_ledger | 61 | 63 | +2 |

The venue delta is **2**, not the number of `new_venue` rows (2). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,845. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 15 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 14 | new_venue | Zhu Ji Zhi Mian Pu (Jinjiang) | chengdu | michelin 2026 | create ve_24aeca03f9 (/chengdu/zhu-ji-zhi-mian-pu-jinjiang), listing published=true, + 1 award |
| 15 | new_venue | Zhuan Zhuan Hui (Lianhua South Road) | chengdu | michelin 2026 | create ve_3dbd0079f8 (/chengdu/zhuan-zhuan-hui-lianhua-south-road), listing published=true, + 1 award |
| 1 | match | Xin Rong Ji | chengdu | michelin 2026 | + 1 award on ve_b271ef2331 |
| 2 | match | Hokkien Cuisine | chengdu | michelin 2026 | + 1 award on ve_aa87491e3a |
| 3 | match | Ma's Kitchen (Jinjiang) | chengdu | michelin 2026 | + 1 award on ve_6ce4e59ddf |
| 4 | match | Cuo Xia | chengdu | michelin 2026 | + 1 award on ve_f099074ae1 |
| 5 | match | Dumpling & Drinks (Lancao Road) | chengdu | michelin 2026 | + 1 award on ve_63d293449b |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-chengdu
confirmation: PROMOTE michelin-2026-chengdu
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 15 rows from fixtures/ingest/michelin-2026-chengdu.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.0s | 0.1s | 23 sources |
| 4 | staged the raw rows | 0.0s | 0.2s | batch 12, 15 rows |
| 5 | row checks | 0.0s | 0.2s | 15 of 15 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.2s | 15 rows |
| 7 | normalised the batch | 0.0s | 0.2s | 15 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.2s | 1 cities |
| 9 | loaded the candidate venues | 0.0s | 0.2s | 16 venues |
| 10 | resolved cities | 0.0s | 0.3s | 15 of 15 settled on one city |
| 11 | resolved venues | 0.0s | 0.3s | 13 matched an existing venue |
| 12 | loose-name pass | 0.0s | 0.3s | 2 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.3s |  |
| 14 | built the promote plan | 0.0s | 0.3s | 2 venues, 15 awards |
| 15 | wrote the verdicts | 0.0s | 0.3s | 15 rows |
| 16 | committed | 0.0s | 0.3s |  |
