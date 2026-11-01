# Ingest stage - michelin-2026-hong-kong-macau

Staged 2026-11-01T15:38:20.561Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-hong-kong-macau` |
| batch id | 19 |
| CSV | `fixtures/ingest/michelin-2026-hong-kong-macau.csv` |
| rows in | 180 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-hong-kong-macau" on every row |
| re-stage | decisions re-applied to the existing batch; 66 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_zh`, `city_label_zh`.

## Verdicts

Population: all 180 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| duplicate | 172 | this exact award already exists; promote skips it |
| new_venue | 6 | promote creates the venue, listing, slug, city labels and the award |
| match | 2 | venue already exists; promote adds the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,300 | 11,306 | +6 |
| awards | 23,362 | 23,370 | +8 |
| listings | 11,300 | 11,306 | +6 |
| slugs | 12,950 | 12,956 | +6 |
| city_label_source | 23,999 | 24,011 | +12 |
| price | 7,731 | 7,731 | +0 |
| source_capture_ledger | 149 | 151 | +2 |

The venue delta is **6**, not the number of `new_venue` rows (6). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,935. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 8 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 9 | new_venue | Lai Ching Heen | hong-kong | michelin 2026 | create ve_403f3ed56b (/hong-kong/lai-ching-heen), listing published=true, + 1 award |
| 92 | new_venue | Dragon Inn | hong-kong | michelin 2026 | create ve_e49568f69f (/hong-kong/dragon-inn), listing published=true, + 1 award |
| 95 | new_venue | Eton | hong-kong | michelin 2026 | create ve_35baee2d3a (/hong-kong/eton), listing published=true, + 1 award |
| 122 | new_venue | Eng Kee Noodle Shop | hong-kong | michelin 2026 | create ve_01b130259b (/hong-kong/eng-kee-noodle-shop), listing published=true, + 1 award |
| 128 | new_venue | Sang Kee Foods (Western District) | hong-kong | michelin 2026 | create ve_b02a3e951b (/hong-kong/sang-kee-foods-western-district), listing published=true, + 1 award |
| 45 | match | Andō | hong-kong | michelin 2026 | + 1 award on ve_694e8845c1 |
| 130 | match | Putien (Causeway Bay) | hong-kong | michelin 2026 | + 1 award on ve_73d901a8fe |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-hong-kong-macau
confirmation: PROMOTE michelin-2026-hong-kong-macau
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 180 rows from fixtures/ingest/michelin-2026-hong-kong-macau.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.2s | 0.4s | 23 sources |
| 4 | re-read the staged rows | 0.1s | 0.5s | batch 19, 180 rows |
| 5 | row checks | 0.0s | 0.5s | 180 of 180 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.5s | 180 rows |
| 7 | normalised the batch | 0.0s | 0.6s | 180 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.7s | 2 cities |
| 9 | loaded the candidate venues | 0.1s | 0.8s | 141 venues |
| 10 | resolved cities | 0.0s | 0.8s | 180 of 180 settled on one city |
| 11 | resolved venues | 0.0s | 0.8s | 114 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.9s | 65 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.0s |  |
| 14 | built the promote plan | 0.1s | 1.1s | 6 venues, 8 awards |
| 15 | wrote the verdicts | 0.2s | 1.3s | 180 rows |
| 16 | committed | 0.0s | 1.3s |  |
