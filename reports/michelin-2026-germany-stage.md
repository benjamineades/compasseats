# Ingest stage - michelin-2026-germany

Staged 2026-10-08T21:43:22.465Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-germany` |
| batch id | 13 |
| CSV | `fixtures/ingest/michelin-2026-germany.csv` |
| rows in | 483 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-germany" on every row |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_de`, `city_label_de`.

## Verdicts

Population: all 483 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| new_venue | 172 | promote creates the venue, listing, slug, city labels and the award |
| duplicate | 171 | this exact award already exists; promote skips it |
| review_venue | 76 | more than one candidate, or a same-name venue elsewhere; no auto-merge |
| match | 60 | venue already exists; promote adds the award |
| review_city | 4 | the city could not be resolved to exactly one row |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,205 | 11,377 | +172 |
| awards | 22,249 | 22,481 | +232 |
| listings | 11,205 | 11,377 | +172 |
| slugs | 12,304 | 12,476 | +172 |
| city_label_source | 23,814 | 24,158 | +344 |
| price | 7,049 | 7,049 | +0 |
| source_capture_ledger | 65 | 67 | +2 |

The venue delta is **172**, not the number of `new_venue` rows (172). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,839. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 232 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 8 | new_venue | The Table Kevin Fehling | hamburg | michelin 2026 | create ve_64567c2d92 (/hamburg/the-table-kevin-fehling), listing published=true, + 1 award |
| 16 | new_venue | Ophelia | constance | michelin 2026 | create ve_14e254e028 (/constance/ophelia), listing published=true, + 1 award |
| 19 | new_venue | Mühle | schluchsee | michelin 2026 | create ve_bfc1646987 (/schluchsee/muhle), listing published=true, + 1 award |
| 21 | new_venue | Hirschen | sulzburg | michelin 2026 | create ve_7ba7a4e4eb (/sulzburg/hirschen), listing published=true, + 1 award |
| 24 | new_venue | PUR | berchtesgaden | michelin 2026 | create ve_c7117b6f02 (/berchtesgaden/pur), listing published=true, + 1 award |
| 36 | match | AURA by Alexander Herrmann & Tobias Bätz | wirsberg | michelin 2026 | + 1 award on ve_410be56f8e |
| 342 | match | Weinstube zum Engel | baden-baden | michelin 2026 | + 1 award on ve_31e09545ac |
| 343 | match | Dorfstuben | baiersbronn | michelin 2026 | + 1 award on ve_eea5593c6a |
| 346 | match | Sommerau | bonndorf-im-schwarzwald | michelin 2026 | + 1 award on ve_5d63b9c31d |
| 352 | match | Dutters Stube | endingen-am-kaiserstuhl | michelin 2026 | + 1 award on ve_64436827e9 |

## Review

**80 row(s) need a decision** before this batch can promote.

Open `reports/michelin-2026-germany-review.csv` in Sheets, fill the `decision` column, save it as CSV,
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
| `loose_key_candidate_in_city` | 72 |
| `city_not_found` | 3 |
| `norm_key_too_short` | 2 |
| `same_key_other_city` | 2 |
| `country_label_disagrees` | 1 |

## Next

Clear the 80 review row(s) first. Promote refuses to run while any remain.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 483 rows from fixtures/ingest/michelin-2026-germany.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.2s | 0.4s | 23 sources |
| 4 | staged the raw rows | 0.3s | 0.8s | batch 13, 483 rows |
| 5 | row checks | 0.0s | 0.8s | 483 of 483 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.9s | 483 rows |
| 7 | normalised the batch | 0.1s | 1.0s | 483 rows, in the database |
| 8 | loaded the candidate cities | 0.2s | 1.1s | 282 cities |
| 9 | loaded the candidate venues | 0.1s | 1.3s | 268 venues |
| 10 | resolved cities | 0.0s | 1.3s | 479 of 483 settled on one city |
| 11 | resolved venues | 0.0s | 1.3s | 231 matched an existing venue |
| 12 | loose-name pass | 0.2s | 1.4s | 244 would-be new venues checked, 72 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.6s |  |
| 14 | built the promote plan | 0.4s | 2.0s | 172 venues, 232 awards |
| 15 | wrote the verdicts | 0.3s | 2.3s | 483 rows |
| 16 | committed | 0.0s | 2.3s |  |
