# Ingest stage - michelin-2026-belgium-luxembourg

Staged 2026-10-10T17:20:38.465Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-belgium-luxembourg` |
| batch id | 15 |
| CSV | `fixtures/ingest/michelin-2026-belgium-luxembourg.csv` |
| rows in | 247 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-belgium-luxembourg" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_nl`, `city_label_nl`, `venue_name_fr`, `city_label_fr`.

## Verdicts

Population: all 247 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 205 | venue already exists; promote adds the award |
| new_venue | 26 | promote creates the venue, listing, slug, city labels and the award |
| review_venue | 16 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,232 | 11,258 | +26 |
| awards | 22,462 | 22,693 | +231 |
| listings | 11,232 | 11,258 | +26 |
| slugs | 12,575 | 12,601 | +26 |
| city_label_source | 23,868 | 23,920 | +52 |
| price | 7,048 | 7,048 | +0 |
| source_capture_ledger | 77 | 79 | +2 |

The venue delta is **26**, not the number of `new_venue` rows (26). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,866. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 231 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 3 | new_venue | Hertog Jan at Botanic | antwerp | michelin 2026 | create ve_38d0a8b95d (/antwerp/hertog-jan-at-botanic), listing published=true, + 1 award |
| 8 | new_venue | Bozar Restaurant | brussels | michelin 2026 | create ve_413b7228da (/brussels/bozar-restaurant), listing published=true, + 1 award |
| 41 | new_venue | Zet'Joe by Geert Van Hecke | bruges | michelin 2026 | create ve_1da08808f4 (/bruges/zet-joe-by-geert-van-hecke), listing published=true, + 1 award |
| 52 | new_venue | Hostellerie St-Nicolas | elverdinge | michelin 2026 | create ve_2acef13a52 (/elverdinge/hostellerie-st-nicolas), listing published=true, + 1 award |
| 55 | new_venue | Le Roannay | francorchamps | michelin 2026 | create ve_8bc3765b4d (/francorchamps/le-roannay), listing published=true, + 1 award |
| 1 | match | Zilte | antwerp | michelin 2026 | + 1 award on ve_947c965427 |
| 2 | match | Boury | roeselare | michelin 2026 | + 1 award on ve_16bb8da666 |
| 4 | match | The Jane | antwerp | michelin 2026 | + 1 award on ve_44d34eda5e |
| 5 | match | L'Eau Vive | arbre | michelin 2026 | + 1 award on ve_5dcdd5c3f3 |
| 6 | match | d'Eugénie à Emilie | baudour | michelin 2026 | + 1 award on ve_3ce93cd19f |

## Review

**16 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-belgium-luxembourg-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `loose_key_candidate_in_city` | 14 |
| `same_key_other_city` | 2 |

## Next

Clear the 16 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 247 rows from fixtures/ingest/michelin-2026-belgium-luxembourg.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.1s | 0.2s | 23 sources |
| 4 | staged the raw rows | 0.1s | 0.3s | batch 15, 247 rows |
| 5 | row checks | 0.0s | 0.3s | 247 of 247 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.3s | 247 rows |
| 7 | normalised the batch | 0.0s | 0.4s | 247 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.5s | 162 cities |
| 9 | loaded the candidate venues | 0.0s | 0.5s | 219 venues |
| 10 | resolved cities | 0.0s | 0.5s | 247 of 247 settled on one city |
| 11 | resolved venues | 0.0s | 0.5s | 205 matched an existing venue |
| 12 | loose-name pass | 0.1s | 0.5s | 40 would-be new venues checked, 14 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.6s |  |
| 14 | built the promote plan | 0.1s | 0.6s | 26 venues, 231 awards |
| 15 | wrote the verdicts | 0.1s | 0.7s | 247 rows |
| 16 | committed | 0.0s | 0.7s |  |
