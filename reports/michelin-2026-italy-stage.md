# Ingest stage - michelin-2026-italy

Staged 2026-09-15T03:40:31.389Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-italy` |
| batch id | 4 |
| CSV | `fixtures/ingest/michelin-2026-italy.csv` |
| rows in | 633 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-italy" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 633 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 304 | venue already exists; promote adds the award |
| new_venue | 303 | promote creates the venue, listing, slug, city labels and the award |
| review_venue | 13 | more than one candidate, or a same-name venue elsewhere; no auto-merge |
| review_city | 12 | the city could not be resolved to exactly one row |
| duplicate | 1 | this exact award already exists; promote skips it |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,258 | 11,561 | +303 |
| awards | 22,884 | 23,491 | +607 |
| listings | 11,258 | 11,561 | +303 |
| slugs | 11,515 | 11,818 | +303 |
| city_label_source | 22,800 | 23,406 | +606 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 14 | 16 | +2 |

The venue delta is **303**, not the number of `new_venue` rows (303). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,878. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 607 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 6 | new_venue | Dal Pescatore Santini | canneto-sulloglio | michelin 2026 | create ve_d10be85fe0 (/canneto-sulloglio/dal-pescatore-santini), listing published=true, + 1 award |
| 10 | new_venue | Le Calandre | padua | michelin 2026 | create ve_d4db682529 (/padua/le-calandre), listing published=true, + 1 award |
| 14 | new_venue | Reale | castel-di-sangro | michelin 2026 | create ve_4cd1c6b52d (/castel-di-sangro/reale), listing published=true, + 1 award |
| 16 | new_venue | Antica Corona Reale | cervere | michelin 2026 | create ve_74cd41b387 (/cervere/antica-corona-reale), listing published=true, + 1 award |
| 17 | new_venue | Locanda Sant'Uffizio Enrico Bartolini | cioccaro-di-penango | michelin 2026 | create ve_f4e864c4b6 (/cioccaro-di-penango/locanda-sant-uffizio-enrico-bartolini), listing published=true, + 1 award |
| 1 | match | Villa Crespi | orta-san-giulio | michelin 2026 | + 1 award on ve_09946e039b |
| 2 | match | Piazza Duomo | alba | michelin 2026 | + 1 award on ve_76865f818b |
| 3 | match | La Rei Natura by Michelangelo Mammoliti | serralunga-dalba | michelin 2026 | + 1 award on ve_83988eebc1 |
| 4 | match | Enrico Bartolini al Mudec | milan | michelin 2026 | + 1 award on ve_46c7681a0e |
| 5 | match | Da Vittorio | brusaporto | michelin 2026 | + 1 award on ve_7e7bcc1f40 |

## Review

**25 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-italy-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `city_not_found` | 11 |
| `loose_key_candidate_in_city` | 8 |
| `same_key_other_city` | 4 |
| `country_label_disagrees` | 1 |
| `norm_key_too_short` | 1 |

## Next

Clear the 25 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 633 rows from fixtures/ingest/michelin-2026-italy.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.0s | 0.1s | 23 sources |
| 4 | staged the raw rows | 0.1s | 0.2s | batch 4, 633 rows |
| 5 | row checks | 0.0s | 0.2s | 633 of 633 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.2s | 633 rows |
| 7 | normalised the batch | 0.0s | 0.2s | 633 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.3s | 439 cities |
| 9 | loaded the candidate venues | 0.0s | 0.3s | 329 venues |
| 10 | resolved cities | 0.0s | 0.3s | 621 of 633 settled on one city |
| 11 | resolved venues | 0.0s | 0.3s | 304 matched an existing venue |
| 12 | loose-name pass | 0.0s | 0.3s | 312 would-be new venues checked, 8 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.4s |  |
| 14 | built the promote plan | 0.1s | 0.4s | 303 venues, 607 awards |
| 15 | wrote the verdicts | 0.1s | 0.5s | 633 rows |
| 16 | committed | 0.0s | 0.5s |  |
