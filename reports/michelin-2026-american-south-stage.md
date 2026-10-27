# Ingest stage - michelin-2026-american-south

Staged 2026-10-27T17:48:22.642Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-american-south` |
| batch id | 18 |
| CSV | `fixtures/ingest/michelin-2026-american-south.csv` |
| rows in | 81 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-american-south" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `state_label`.

## Verdicts

Population: all 81 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 57 | venue already exists; promote adds the award |
| new_venue | 23 | promote creates the venue, listing, slug, city labels and the award |
| review_venue | 1 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,291 | 11,314 | +23 |
| awards | 22,841 | 22,921 | +80 |
| listings | 11,291 | 11,314 | +23 |
| slugs | 12,816 | 12,839 | +23 |
| city_label_source | 23,979 | 24,025 | +46 |
| price | 7,024 | 7,024 | +0 |
| source_capture_ledger | 91 | 93 | +2 |

The venue delta is **23**, not the number of `new_venue` rows (23). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,924. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 80 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 9 | new_venue | So. Fox | atlanta | michelin 2026 | create ve_b83e690aca (/atlanta/so-fox), listing published=true, + 1 award |
| 10 | new_venue | Uberto Restaurant | gay | michelin 2026 | create ve_82f336e11a (/gay/uberto-restaurant), listing published=true, + 1 award |
| 16 | new_venue | Malagón Mercado y Taperia | charleston | michelin 2026 | create ve_d884a295e9 (/charleston/malagon-mercado-y-taperia), listing published=true, + 1 award |
| 29 | new_venue | Bomb Biscuit Co. | atlanta | michelin 2026 | create ve_c47c8166b1 (/atlanta/bomb-biscuit-co), listing published=true, + 1 award |
| 35 | new_venue | Summerland | atlanta | michelin 2026 | create ve_002bb1220b (/atlanta/summerland), listing published=true, + 1 award |
| 1 | match | Emeril’s | new-orleans | michelin 2026 | + 1 award on ve_d3f02d0ccc |
| 2 | match | Atlas | atlanta | michelin 2026 | + 1 award on ve_4e51697d5a |
| 3 | match | Bacchanalia | atlanta | michelin 2026 | + 1 award on ve_0a2ed5219a |
| 4 | match | Hayakawa | atlanta | michelin 2026 | + 1 award on ve_6683b09d8e |
| 5 | match | Lazy Betty | atlanta | michelin 2026 | + 1 award on ve_df22614e29 |

## Review

**1 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-american-south-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| 1 | read the CSV | 0.0s | 0.0s | 81 rows from fixtures/ingest/michelin-2026-american-south.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.2s | 0.4s | 23 sources |
| 4 | staged the raw rows | 0.1s | 0.5s | batch 18, 81 rows |
| 5 | row checks | 0.0s | 0.5s | 81 of 81 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.6s | 81 rows |
| 7 | normalised the batch | 0.0s | 0.6s | 81 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.7s | 25 cities |
| 9 | loaded the candidate venues | 0.0s | 0.8s | 61 venues |
| 10 | resolved cities | 0.0s | 0.8s | 81 of 81 settled on one city |
| 11 | resolved venues | 0.0s | 0.8s | 57 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.9s | 23 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.9s |  |
| 14 | built the promote plan | 0.1s | 1.0s | 23 venues, 80 awards |
| 15 | wrote the verdicts | 0.1s | 1.1s | 81 rows |
| 16 | committed | 0.0s | 1.1s |  |
