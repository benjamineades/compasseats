# Ingest stage - michelin-2026-japan

Staged 2026-09-15T13:08:33.648Z. **Nothing has been promoted.** This run wrote to
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

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 585 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 421 | venue already exists; promote adds the award |
| new_venue | 152 | promote creates the venue, listing, slug, city labels and the award |
| review_venue | 12 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,575 | 11,727 | +152 |
| awards | 23,516 | 24,089 | +573 |
| listings | 11,575 | 11,727 | +152 |
| slugs | 11,832 | 11,984 | +152 |
| city_label_source | 23,434 | 23,738 | +304 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 16 | 18 | +2 |

The venue delta is **152**, not the number of `new_venue` rows (152). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 11,195. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 573 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 4 | new_venue | RyuGin | tokyo | michelin 2026 | create ve_75b6bf4c50 (/tokyo/ryugin), listing published=true, + 1 award |
| 5 | new_venue | Harutaka | tokyo | michelin 2026 | create ve_aa8484ed66 (/tokyo/harutaka), listing published=true, + 1 award |
| 7 | new_venue | Myojaku | tokyo | michelin 2026 | create ve_b024abe0d1 (/tokyo/myojaku), listing published=true, + 1 award |
| 12 | new_venue | Miyamaso | kyoto | michelin 2026 | create ve_0422dc8fe7 (/kyoto/miyamaso), listing published=true, + 1 award |
| 15 | new_venue | Isshisoden Nakamura | kyoto | michelin 2026 | create ve_3731203710 (/kyoto/isshisoden-nakamura), listing published=true, + 1 award |
| 1 | match | Kagurazaka Ishikawa | tokyo | michelin 2026 | + 1 award on ve_1228812987 |
| 2 | match | Kanda | tokyo | michelin 2026 | + 1 award on ve_df282c7523 |
| 3 | match | L'OSIER | tokyo | michelin 2026 | + 1 award on ve_2e8a0ddae8 |
| 6 | match | Azabu Kadowaki | tokyo | michelin 2026 | + 1 award on ve_709ab5055e |
| 8 | match | L'Effervescence | tokyo | michelin 2026 | + 1 award on ve_16444df23a |

## Review

**12 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-japan-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `same_key_other_city` | 5 |
| `loose_key_candidate_in_city` | 4 |
| `norm_key_too_short` | 3 |

## Next

Clear the 12 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 585 rows from fixtures/ingest/michelin-2026-japan.csv |
| 2 | opened the database connection | 0.3s | 0.3s |  |
| 3 | read the source vocabulary | 0.4s | 0.6s | 23 sources |
| 4 | staged the raw rows | 0.5s | 1.1s | batch 5, 585 rows |
| 5 | row checks | 0.0s | 1.1s | 585 of 585 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.3s | 585 rows |
| 7 | normalised the batch | 0.1s | 1.4s | 585 rows, in the database |
| 8 | loaded the candidate cities | 0.2s | 1.6s | 4 cities |
| 9 | loaded the candidate venues | 0.1s | 1.7s | 458 venues |
| 10 | resolved cities | 0.0s | 1.7s | 585 of 585 settled on one city |
| 11 | resolved venues | 0.0s | 1.7s | 421 matched an existing venue |
| 12 | loose-name pass | 0.3s | 2.0s | 156 would-be new venues checked, 4 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 2.1s |  |
| 14 | built the promote plan | 0.3s | 2.4s | 152 venues, 573 awards |
| 15 | wrote the verdicts | 0.4s | 2.8s | 585 rows |
| 16 | committed | 0.1s | 2.8s |  |
