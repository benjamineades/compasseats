# Ingest stage - michelin-2026-china

Staged 2026-09-26T01:11:35.264Z. **Nothing has been promoted.** This run wrote to
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

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 469 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| new_venue | 416 | promote creates the venue, listing, slug, city labels and the award |
| match | 46 | venue already exists; promote adds the award |
| review_venue | 7 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,061 | 11,477 | +416 |
| awards | 22,024 | 22,486 | +462 |
| listings | 11,061 | 11,477 | +416 |
| slugs | 11,874 | 12,290 | +416 |
| city_label_source | 23,518 | 24,350 | +832 |
| price | 7,090 | 7,090 | +0 |
| source_capture_ledger | 32 | 34 | +2 |

The venue delta is **416**, not the number of `new_venue` rows (416). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,699. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 462 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 1 | new_venue | Chao Shang Chao (Chaoyang) | beijing | michelin 2026 | create ve_987ef64fb5 (/beijing/chao-shang-chao-chaoyang), listing published=true, + 1 award |
| 2 | new_venue | Xin Rong Ji (Xinyuan South Road) | beijing | michelin 2026 | create ve_8498a4a3dc (/beijing/xin-rong-ji-xinyuan-south-road), listing published=true, + 1 award |
| 3 | new_venue | Blackswan | beijing | michelin 2026 | create ve_2913a0ac40 (/beijing/blackswan), listing published=true, + 1 award |
| 4 | new_venue | Jingji | beijing | michelin 2026 | create ve_13e93ccbe7 (/beijing/jingji), listing published=true, + 1 award |
| 6 | new_venue | Lamdre | beijing | michelin 2026 | create ve_0c0be64937 (/beijing/lamdre), listing published=true, + 1 award |
| 5 | match | King's Joy | beijing | michelin 2026 | + 1 award on ve_e61dc1a188 |
| 11 | match | Fu Chun Ju | beijing | michelin 2026 | + 1 award on ve_24de3005f6 |
| 15 | match | Il Ristorante - Niko Romito | beijing | michelin 2026 | + 1 award on ve_d4e5fdbd3e |
| 16 | match | Jing | beijing | michelin 2026 | + 1 award on ve_262d31b59b |
| 28 | match | Trb Hutong | beijing | michelin 2026 | + 1 award on ve_edc7493c3b |

## Review

**7 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-china-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `same_key_other_city` | 7 |

## Next

Clear the 7 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 469 rows from fixtures/ingest/michelin-2026-china.csv |
| 2 | opened the database connection | 0.3s | 0.4s |  |
| 3 | read the source vocabulary | 0.5s | 0.8s | 23 sources |
| 4 | staged the raw rows | 0.6s | 1.5s | batch 9, 469 rows |
| 5 | row checks | 0.0s | 1.5s | 469 of 469 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.7s | 469 rows |
| 7 | normalised the batch | 0.1s | 1.8s | 469 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 2.1s | 15 cities |
| 9 | loaded the candidate venues | 0.1s | 2.2s | 71 venues |
| 10 | resolved cities | 0.0s | 2.2s | 469 of 469 settled on one city |
| 11 | resolved venues | 0.0s | 2.2s | 46 matched an existing venue |
| 12 | loose-name pass | 0.3s | 2.5s | 416 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 2.7s |  |
| 14 | built the promote plan | 0.4s | 3.1s | 416 venues, 462 awards |
| 15 | wrote the verdicts | 0.5s | 3.6s | 469 rows |
| 16 | committed | 0.1s | 3.6s |  |
