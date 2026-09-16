# Ingest stage - michelin-2026-spain

Staged 2026-09-16T21:07:52.438Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-spain` |
| batch id | 6 |
| CSV | `fixtures/ingest/michelin-2026-spain.csv` |
| rows in | 493 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-spain" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 493 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| new_venue | 263 | promote creates the venue, listing, slug, city labels and the award |
| match | 189 | venue already exists; promote adds the award |
| review_venue | 41 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,034 | 11,297 | +263 |
| awards | 21,964 | 22,416 | +452 |
| listings | 11,034 | 11,297 | +263 |
| slugs | 11,847 | 12,110 | +263 |
| city_label_source | 23,464 | 23,990 | +526 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 24 | 26 | +2 |

The venue delta is **263**, not the number of `new_venue` rows (263). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,666. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 452 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 2 | new_venue | Atrio | caceres | michelin 2026 | create ve_30e8353571 (/caceres/atrio), listing published=true, + 1 award |
| 4 | new_venue | Azurmendi | larrabetzu | michelin 2026 | create ve_28b120f9ca (/larrabetzu/azurmendi), listing published=true, + 1 award |
| 7 | new_venue | Akelaŕe | san-sebastian | michelin 2026 | create ve_2e0a3ccc46 (/san-sebastian/akelare), listing published=true, + 1 award |
| 18 | new_venue | El Rincón de Juan Carlos | adeje | michelin 2026 | create ve_146a576563 (/adeje/el-rincon-de-juan-carlos), listing published=true, + 1 award |
| 21 | new_venue | Pepe Vieira | poio | michelin 2026 | create ve_dc6958e4c8 (/poio/pepe-vieira), listing published=true, + 1 award |
| 1 | match | Casa Marcial | arriondas | michelin 2026 | + 1 award on ve_4d8c220a0a |
| 3 | match | Cenador de Amós | villaverde-de-pontones | michelin 2026 | + 1 award on ve_fcf0e4d0d8 |
| 5 | match | Aponiente | cadiz | michelin 2026 | + 1 award on ve_d0ed7ab726 |
| 6 | match | DiverXO | madrid | michelin 2026 | + 1 award on ve_ad0e407c44 |
| 8 | match | Martín Berasategui | san-sebastian | michelin 2026 | + 1 award on ve_cb306c569d |

## Review

**41 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-spain-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `loose_key_candidate_in_city` | 32 |
| `same_key_other_city` | 7 |
| `norm_key_too_short` | 2 |

## Next

Clear the 41 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 493 rows from fixtures/ingest/michelin-2026-spain.csv |
| 2 | opened the database connection | 0.3s | 0.4s |  |
| 3 | read the source vocabulary | 0.5s | 0.8s | 23 sources |
| 4 | staged the raw rows | 0.6s | 1.4s | batch 6, 493 rows |
| 5 | row checks | 0.0s | 1.4s | 493 of 493 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.6s | 493 rows |
| 7 | normalised the batch | 0.1s | 1.7s | 493 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 2.0s | 272 cities |
| 9 | loaded the candidate venues | 0.1s | 2.2s | 215 venues |
| 10 | resolved cities | 0.0s | 2.2s | 493 of 493 settled on one city |
| 11 | resolved venues | 0.0s | 2.2s | 189 matched an existing venue |
| 12 | loose-name pass | 0.4s | 2.5s | 295 would-be new venues checked, 32 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 2.7s |  |
| 14 | built the promote plan | 0.4s | 3.0s | 263 venues, 452 awards |
| 15 | wrote the verdicts | 0.5s | 3.5s | 493 rows |
| 16 | committed | 0.1s | 3.6s |  |
