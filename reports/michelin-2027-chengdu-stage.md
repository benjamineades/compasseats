# Ingest stage - michelin-2027-chengdu

Staged 2026-09-28T14:45:49.564Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2027-chengdu` |
| batch id | 10 |
| CSV | `fixtures/ingest/michelin-2027-chengdu.csv` |
| rows in | 47 |
| source(s) | michelin |
| list year(s) | 2027 |
| batch key check | batch_key column present and equal to "michelin-2027-chengdu" on every row |
| re-stage | decisions re-applied to the existing batch; 19 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 47 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| new_venue | 24 | promote creates the venue, listing, slug, city labels and the award |
| match | 23 | venue already exists; promote adds the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,185 | 11,209 | +24 |
| awards | 22,190 | 22,237 | +47 |
| listings | 11,185 | 11,209 | +24 |
| slugs | 12,266 | 12,290 | +24 |
| city_label_source | 23,774 | 23,822 | +48 |
| price | 7,059 | 7,059 | +0 |
| source_capture_ledger | 53 | 55 | +2 |

The venue delta is **24**, not the number of `new_venue` rows (24). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,824. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 47 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 1 | new_venue | Xin Rong Ji | chengdu | michelin 2027 | create ve_b271ef2331 (/chengdu/xin-rong-ji), listing published=true, + 1 award |
| 3 | new_venue | The Hall | chengdu | michelin 2027 | create ve_cec4b19f8b (/chengdu/the-hall), listing published=true, + 1 award |
| 6 | new_venue | Ma's Kitchen (Jinjiang) | chengdu | michelin 2027 | create ve_6ce4e59ddf (/chengdu/ma-s-kitchen-jinjiang), listing published=true, + 1 award |
| 10 | new_venue | Zinan | chengdu | michelin 2027 | create ve_f4300dee32 (/chengdu/zinan), listing published=true, + 1 award |
| 12 | new_venue | Focus by Bill Yue | chengdu | michelin 2027 | create ve_638e8e4893 (/chengdu/focus-by-bill-yue), listing published=true, + 1 award |
| 2 | match | Yu Zhi Lan | chengdu | michelin 2027 | + 1 award on ve_9962046586 |
| 4 | match | Fang Xiang Jing | chengdu | michelin 2027 | + 1 award on ve_e1109450cf |
| 5 | match | Mi Xun Teahouse | chengdu | michelin 2027 | + 1 award on ve_37910677a4 |
| 7 | match | Xu's Cuisine | chengdu | michelin 2027 | + 1 award on ve_36ae4d6bcd |
| 8 | match | Fu Rong Huang | chengdu | michelin 2027 | + 1 award on ve_a3b31ca55d |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2027-chengdu
confirmation: PROMOTE michelin-2027-chengdu
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 47 rows from fixtures/ingest/michelin-2027-chengdu.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.2s | 0.4s | 23 sources |
| 4 | re-read the staged rows | 0.1s | 0.4s | batch 10, 47 rows |
| 5 | row checks | 0.0s | 0.4s | 47 of 47 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.5s | 47 rows |
| 7 | normalised the batch | 0.0s | 0.5s | 47 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.7s | 1 cities |
| 9 | loaded the candidate venues | 0.1s | 0.7s | 9 venues |
| 10 | resolved cities | 0.0s | 0.7s | 47 of 47 settled on one city |
| 11 | resolved venues | 0.0s | 0.7s | 5 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.8s | 40 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.0s |  |
| 14 | built the promote plan | 0.1s | 1.1s | 24 venues, 47 awards |
| 15 | wrote the verdicts | 0.1s | 1.2s | 47 rows |
| 16 | committed | 0.0s | 1.2s |  |
