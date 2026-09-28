# Ingest stage - michelin-2027-chengdu

Staged 2026-09-28T14:43:59.960Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2027-chengdu` |
| batch id | 10 |
| CSV | `fixtures/ingest/michelin-2027-chengdu.csv` |
| rows in | 47 |
| source(s) | michelin |
| list year(s) | 2027 |
| batch key check | batch_key column present and equal to "michelin-2027-chengdu" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `name_native_michelin`.

## Verdicts

Population: all 47 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| new_venue | 40 | promote creates the venue, listing, slug, city labels and the award |
| match | 5 | venue already exists; promote adds the award |
| review_venue | 2 | more than one candidate, or a same-name venue elsewhere; no auto-merge |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,185 | 11,225 | +40 |
| awards | 22,190 | 22,235 | +45 |
| listings | 11,185 | 11,225 | +40 |
| slugs | 12,266 | 12,306 | +40 |
| city_label_source | 23,774 | 23,854 | +80 |
| price | 7,059 | 7,059 | +0 |
| source_capture_ledger | 53 | 55 | +2 |

The venue delta is **40**, not the number of `new_venue` rows (40). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,824. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 45 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 3 | new_venue | The Hall | chengdu | michelin 2027 | create ve_cec4b19f8b (/chengdu/the-hall), listing published=true, + 1 award |
| 4 | new_venue | Fang Xiang Jing | chengdu | michelin 2027 | create ve_e85b9504a4 (/chengdu/fang-xiang-jing), listing published=true, + 1 award |
| 5 | new_venue | Mi Xun Teahouse | chengdu | michelin 2027 | create ve_4debb3fcef (/chengdu/mi-xun-teahouse), listing published=true, + 1 award |
| 6 | new_venue | Ma's Kitchen (Jinjiang) | chengdu | michelin 2027 | create ve_6ce4e59ddf (/chengdu/ma-s-kitchen-jinjiang), listing published=true, + 1 award |
| 7 | new_venue | Xu's Cuisine | chengdu | michelin 2027 | create ve_6edf13f654 (/chengdu/xu-s-cuisine), listing published=true, + 1 award |
| 2 | match | Yu Zhi Lan | chengdu | michelin 2027 | + 1 award on ve_9962046586 |
| 19 | match | Rongrong Beida Pugaimian | chengdu | michelin 2027 | + 1 award on ve_208a1abe67 |
| 29 | match | Wu Ji Guai Wei Mian | chengdu | michelin 2027 | + 1 award on ve_4500db80db |
| 37 | match | Yongle Restaurant | chengdu | michelin 2027 | + 1 award on ve_e573ea7e30 |
| 38 | match | Zeng Niu Rou | chengdu | michelin 2027 | + 1 award on ve_fa5e39740d |

## Review

**2 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2027-chengdu-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `norm_key_too_short` | 1 |
| `same_key_other_city` | 1 |

## Next

Clear the 2 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 47 rows from fixtures/ingest/michelin-2027-chengdu.csv |
| 2 | opened the database connection | 0.3s | 0.3s |  |
| 3 | read the source vocabulary | 0.5s | 0.8s | 23 sources |
| 4 | staged the raw rows | 0.3s | 1.1s | batch 10, 47 rows |
| 5 | row checks | 0.0s | 1.1s | 47 of 47 rows still live |
| 6 | loaded the live rows into the resolver | 0.2s | 1.3s | 47 rows |
| 7 | normalised the batch | 0.1s | 1.4s | 47 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.7s | 1 cities |
| 9 | loaded the candidate venues | 0.1s | 1.9s | 9 venues |
| 10 | resolved cities | 0.0s | 1.9s | 47 of 47 settled on one city |
| 11 | resolved venues | 0.0s | 1.9s | 5 matched an existing venue |
| 12 | loose-name pass | 0.3s | 2.1s | 40 would-be new venues checked, 0 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 2.3s |  |
| 14 | built the promote plan | 0.4s | 2.6s | 40 venues, 45 awards |
| 15 | wrote the verdicts | 0.2s | 2.9s | 47 rows |
| 16 | committed | 0.1s | 2.9s |  |
