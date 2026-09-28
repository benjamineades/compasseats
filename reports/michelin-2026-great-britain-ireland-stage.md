# Ingest stage - michelin-2026-great-britain-ireland

Staged 2026-09-28T18:01:17.624Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-great-britain-ireland` |
| batch id | 11 |
| CSV | `fixtures/ingest/michelin-2026-great-britain-ireland.csv` |
| rows in | 386 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-great-britain-ireland" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`.

## Verdicts

Population: all 386 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 238 | venue already exists; promote adds the award |
| new_venue | 136 | promote creates the venue, listing, slug, city labels and the award |
| review_venue | 10 | more than one candidate, or a same-name venue elsewhere; no auto-merge |
| review_city | 2 | the city could not be resolved to exactly one row |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,209 | 11,345 | +136 |
| awards | 22,237 | 22,611 | +374 |
| listings | 11,209 | 11,345 | +136 |
| slugs | 12,290 | 12,426 | +136 |
| city_label_source | 23,822 | 24,094 | +272 |
| price | 7,059 | 7,059 | +0 |
| source_capture_ledger | 55 | 57 | +2 |

The venue delta is **136**, not the number of `new_venue` rows (136). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,848. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 374 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 2 | new_venue | Moor Hall | aughton | michelin 2026 | create ve_199691f15f (/aughton/moor-hall), listing published=true, + 1 award |
| 3 | new_venue | Waterside Inn | bray | michelin 2026 | create ve_1c2cd0860e (/bray/waterside-inn), listing published=true, + 1 award |
| 9 | new_venue | Sketch, The Lecture Room and Library | london | michelin 2026 | create ve_dd48b518b5 (/london/sketch-the-lecture-room-and-library), listing published=true, + 1 award |
| 11 | new_venue | The Glenturret Lalique | crieff | michelin 2026 | create ve_deb8733e79 (/crieff/the-glenturret-lalique), listing published=true, + 1 award |
| 13 | new_venue | Ynyshir | machynlleth | michelin 2026 | create ve_e36ef3677a (/machynlleth/ynyshir), listing published=true, + 1 award |
| 1 | match | L'Enclume | cartmel | michelin 2026 | + 1 award on ve_cfab22c6e2 |
| 4 | match | The Fat Duck | bray | michelin 2026 | + 1 award on ve_8d4b2e9406 |
| 5 | match | The Ledbury | london | michelin 2026 | + 1 award on ve_78e41a2703 |
| 6 | match | CORE by Clare Smyth | london | michelin 2026 | + 1 award on ve_9771a66bad |
| 7 | match | Alain Ducasse at The Dorchester | london | michelin 2026 | + 1 award on ve_9c1eaf6823 |

## Review

**12 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-great-britain-ireland-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `country_label_disagrees` | 2 |
| `norm_key_too_short` | 1 |

## Next

Clear the 12 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 386 rows from fixtures/ingest/michelin-2026-great-britain-ireland.csv |
| 2 | opened the database connection | 0.1s | 0.2s |  |
| 3 | read the source vocabulary | 0.1s | 0.3s | 23 sources |
| 4 | staged the raw rows | 0.2s | 0.5s | batch 11, 386 rows |
| 5 | row checks | 0.0s | 0.5s | 386 of 386 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.5s | 386 rows |
| 7 | normalised the batch | 0.0s | 0.6s | 386 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.7s | 159 cities |
| 9 | loaded the candidate venues | 0.0s | 0.7s | 270 venues |
| 10 | resolved cities | 0.0s | 0.7s | 384 of 386 settled on one city |
| 11 | resolved venues | 0.0s | 0.7s | 238 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.8s | 140 would-be new venues checked, 4 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.9s |  |
| 14 | built the promote plan | 0.1s | 1.0s | 136 venues, 374 awards |
| 15 | wrote the verdicts | 0.2s | 1.2s | 386 rows |
| 16 | committed | 0.0s | 1.2s |  |
