# Ingest stage - michelin-2026-hong-kong-macau

Staged 2026-11-01T15:36:22.905Z. **Nothing has been promoted.** This run wrote to
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

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_zh`, `city_label_zh`.

## Verdicts

Population: all 180 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| duplicate | 112 | this exact award already exists; promote skips it |
| new_venue | 65 | promote creates the venue, listing, slug, city labels and the award |
| match | 2 | venue already exists; promote adds the award |
| review_venue | 1 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,300 | 11,365 | +65 |
| awards | 23,362 | 23,429 | +67 |
| listings | 11,300 | 11,365 | +65 |
| slugs | 12,950 | 13,015 | +65 |
| city_label_source | 23,999 | 24,129 | +130 |
| price | 7,731 | 7,731 | +0 |
| source_capture_ledger | 149 | 151 | +2 |

The venue delta is **65**, not the number of `new_venue` rows (65). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,935. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 67 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 3 | new_venue | Forum | hong-kong | michelin 2026 | create ve_510c1455f4 (/hong-kong/forum), listing published=true, + 1 award |
| 8 | new_venue | Tin Lung Heen | hong-kong | michelin 2026 | create ve_2f28e55476 (/hong-kong/tin-lung-heen), listing published=true, + 1 award |
| 9 | new_venue | Lai Ching Heen | hong-kong | michelin 2026 | create ve_403f3ed56b (/hong-kong/lai-ching-heen), listing published=true, + 1 award |
| 13 | new_venue | Tate | hong-kong | michelin 2026 | create ve_838a5f35d0 (/hong-kong/tate), listing published=true, + 1 award |
| 15 | new_venue | Octavium | hong-kong | michelin 2026 | create ve_fed2ff6b6a (/hong-kong/octavium), listing published=true, + 1 award |
| 45 | match | Andō | hong-kong | michelin 2026 | + 1 award on ve_694e8845c1 |
| 130 | match | Putien (Causeway Bay) | hong-kong | michelin 2026 | + 1 award on ve_73d901a8fe |

## Review

**1 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-hong-kong-macau-review.csv` in Sheets, fill the `decision` column, save it as CSV,
and re-run the stage workflow with the same batch key plus the decisions file.

| decision | means |
|---|---|
| `use:ve_xxxxxxxxxx` | this row is that existing venue |
| `new` | create a new venue for it |
| `city:ci_xxxxxxxx` | the city is that one |
| `skip` | leave this row out of the promote |
| `city:ci_x;use:ve_y` | both, in one cell |

| reason | rows |
|---|---|
| `same_key_other_city` | 1 |

## Next

Clear the 1 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 180 rows from fixtures/ingest/michelin-2026-hong-kong-macau.csv |
| 2 | opened the database connection | 0.3s | 0.3s |  |
| 3 | read the source vocabulary | 0.2s | 0.5s | 23 sources |
| 4 | staged the raw rows | 0.2s | 0.8s | batch 19, 180 rows |
| 5 | row checks | 0.0s | 0.8s | 180 of 180 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.9s | 180 rows |
| 7 | normalised the batch | 0.1s | 0.9s | 180 rows, in the database |
| 8 | loaded the candidate cities | 0.2s | 1.1s | 2 cities |
| 9 | loaded the candidate venues | 0.1s | 1.2s | 141 venues |
| 10 | resolved cities | 0.0s | 1.2s | 180 of 180 settled on one city |
| 11 | resolved venues | 0.0s | 1.2s | 114 matched an existing venue |
| 12 | loose-name pass | 0.1s | 1.3s | 65 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.4s |  |
| 14 | built the promote plan | 0.2s | 1.6s | 65 venues, 67 awards |
| 15 | wrote the verdicts | 0.2s | 1.8s | 180 rows |
| 16 | committed | 0.0s | 1.8s |  |
