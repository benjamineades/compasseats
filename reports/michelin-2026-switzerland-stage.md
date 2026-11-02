# Ingest stage - michelin-2026-switzerland

Staged 2026-11-02T23:34:19.423Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-switzerland` |
| batch id | 20 |
| CSV | `fixtures/ingest/michelin-2026-switzerland.csv` |
| rows in | 225 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-switzerland" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_de`, `city_label_de`.

## Verdicts

Population: all 225 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 96 | venue already exists; promote adds the award |
| new_venue | 88 | promote creates the venue, listing, slug, city labels and the award |
| review_venue | 41 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,293 | 11,381 | +88 |
| awards | 25,097 | 25,281 | +184 |
| listings | 11,293 | 11,381 | +88 |
| slugs | 13,022 | 13,110 | +88 |
| city_label_source | 23,989 | 24,165 | +176 |
| price | 7,727 | 7,727 | +0 |
| source_capture_ledger | 186 | 188 | +2 |

The venue delta is **88**, not the number of `new_venue` rows (88). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,999. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 184 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 5 | new_venue | Restaurant de l'Hôtel de Ville | crissier | michelin 2026 | create ve_10f5594d01 (/crissier/restaurant-de-l-hotel-de-ville), listing published=true, + 1 award |
| 8 | new_venue | Pic Beau-Rivage Palace | lausanne | michelin 2026 | create ve_e18b445fae (/lausanne/pic-beau-rivage-palace), listing published=true, + 1 award |
| 13 | new_venue | Ecco St. Moritz | saint-moritz | michelin 2026 | create ve_2df4a1c272 (/saint-moritz/ecco-st-moritz), listing published=true, + 1 award |
| 15 | new_venue | 7132 Silver | vals | michelin 2026 | create ve_0df5e830b1 (/vals/7132-silver), listing published=true, + 1 award |
| 16 | new_venue | Ecco | ascona | michelin 2026 | create ve_2247eba7e3 (/ascona/ecco), listing published=true, + 1 award |
| 1 | match | Cheval Blanc by Peter Knogl | basel | michelin 2026 | + 1 award on ve_46e15d96d7 |
| 2 | match | Schloss Schauenstein | furstenau | michelin 2026 | + 1 award on ve_6ce9f52552 |
| 3 | match | The Japanese Restaurant | andermatt | michelin 2026 | + 1 award on ve_f337673106 |
| 4 | match | Sven Wassmer Memories | bad-ragaz | michelin 2026 | + 1 award on ve_034adbb581 |
| 6 | match | L'Atelier Robuchon | geneva | michelin 2026 | + 1 award on ve_f85f455848 |

## Review

**41 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-switzerland-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `loose_key_candidate_in_city` | 38 |
| `norm_key_too_short` | 1 |
| `same_key_other_city` | 1 |
| `venue_ambiguous_in_city` | 1 |

## Next

Clear the 41 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 225 rows from fixtures/ingest/michelin-2026-switzerland.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.0s | 0.2s | 23 sources |
| 4 | staged the raw rows | 0.0s | 0.2s | batch 20, 225 rows |
| 5 | row checks | 0.0s | 0.2s | 225 of 225 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.3s | 225 rows |
| 7 | normalised the batch | 0.0s | 0.3s | 225 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.3s | 132 cities |
| 9 | loaded the candidate venues | 0.0s | 0.3s | 112 venues |
| 10 | resolved cities | 0.0s | 0.3s | 225 of 225 settled on one city |
| 11 | resolved venues | 0.0s | 0.3s | 96 matched an existing venue |
| 12 | loose-name pass | 0.0s | 0.4s | 126 would-be new venues checked, 38 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.4s |  |
| 14 | built the promote plan | 0.0s | 0.4s | 88 venues, 184 awards |
| 15 | wrote the verdicts | 0.0s | 0.5s | 225 rows |
| 16 | committed | 0.0s | 0.5s |  |
