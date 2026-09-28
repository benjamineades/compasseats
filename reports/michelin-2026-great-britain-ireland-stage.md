# Ingest stage - michelin-2026-great-britain-ireland

Staged 2026-09-28T18:28:07.402Z. **Nothing has been promoted.** This run wrote to
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
| re-stage | decisions re-applied to the existing batch; 148 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`.

## Verdicts

Population: all 386 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 381 | venue already exists; promote adds the award |
| new_venue | 5 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,209 | 11,214 | +5 |
| awards | 22,237 | 22,623 | +386 |
| listings | 11,209 | 11,214 | +5 |
| slugs | 12,290 | 12,295 | +5 |
| city_label_source | 23,822 | 23,832 | +10 |
| price | 7,059 | 7,059 | +0 |
| source_capture_ledger | 55 | 57 | +2 |

The venue delta is **5**, not the number of `new_venue` rows (5). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,848. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 386 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 148 | new_venue | Corenucopia by Clare Smyth | london | michelin 2026 | create ve_ce39832bd0 (/london/corenucopia-by-clare-smyth), listing published=true, + 1 award |
| 160 | new_venue | Pétrus by Gordon Ramsay | london | michelin 2026 | create ve_61599d9f2f (/london/petrus-by-gordon-ramsay), listing published=true, + 1 award |
| 172 | new_venue | 1890 by Gordon Ramsay | london | michelin 2026 | create ve_fc7016664d (/london/1890-by-gordon-ramsay), listing published=true, + 1 award |
| 251 | new_venue | COR | city-of-bristol | michelin 2026 | create ve_1ade09cf15 (/city-of-bristol/cor), listing published=true, + 1 award |
| 254 | new_venue | OTHER | city-of-bristol | michelin 2026 | create ve_bd55d03429 (/city-of-bristol/other), listing published=true, + 1 award |
| 1 | match | L'Enclume | cartmel | michelin 2026 | + 1 award on ve_cfab22c6e2 |
| 2 | match | Moor Hall | aughton | michelin 2026 | + 1 award on ve_2e7a477d83 |
| 3 | match | Waterside Inn | bray | michelin 2026 | + 1 award on ve_6660008ead |
| 4 | match | The Fat Duck | bray | michelin 2026 | + 1 award on ve_8d4b2e9406 |
| 5 | match | The Ledbury | london | michelin 2026 | + 1 award on ve_78e41a2703 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-great-britain-ireland
confirmation: PROMOTE michelin-2026-great-britain-ireland
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 386 rows from fixtures/ingest/michelin-2026-great-britain-ireland.csv |
| 2 | opened the database connection | 0.1s | 0.1s |  |
| 3 | read the source vocabulary | 0.0s | 0.2s | 23 sources |
| 4 | re-read the staged rows | 0.0s | 0.2s | batch 11, 386 rows |
| 5 | row checks | 0.0s | 0.2s | 386 of 386 rows still live |
| 6 | loaded the live rows into the resolver | 0.0s | 0.2s | 386 rows |
| 7 | normalised the batch | 0.0s | 0.3s | 386 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.3s | 159 cities |
| 9 | loaded the candidate venues | 0.0s | 0.3s | 270 venues |
| 10 | resolved cities | 0.0s | 0.3s | 384 of 386 settled on one city |
| 11 | resolved venues | 0.0s | 0.3s | 239 matched an existing venue |
| 12 | loose-name pass | 0.0s | 0.4s | 141 would-be new venues checked, 4 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.0s | 0.4s |  |
| 14 | built the promote plan | 0.0s | 0.4s | 5 venues, 386 awards |
| 15 | wrote the verdicts | 0.1s | 0.5s | 386 rows |
| 16 | committed | 0.0s | 0.5s |  |
