# Ingest stage - michelin-2026-netherlands

Staged 2026-10-11T15:57:12.970Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `michelin-2026-netherlands` |
| batch id | 16 |
| CSV | `fixtures/ingest/michelin-2026-netherlands.csv` |
| rows in | 196 |
| source(s) | michelin |
| list year(s) | 2026 |
| batch key check | batch_key column present and equal to "michelin-2026-netherlands" on every row |
| re-stage | decisions re-applied to the existing batch; 97 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_nl`, `city_label_nl`.

## Verdicts

Population: all 196 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| match | 175 | venue already exists; promote adds the award |
| new_venue | 21 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,233 | 11,254 | +21 |
| awards | 22,463 | 22,659 | +196 |
| listings | 11,233 | 11,254 | +21 |
| slugs | 12,617 | 12,638 | +21 |
| city_label_source | 23,870 | 23,912 | +42 |
| price | 7,048 | 7,048 | +0 |
| source_capture_ledger | 83 | 85 | +2 |

The venue delta is **21**, not the number of `new_venue` rows (21). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,866. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 196 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 6 | new_venue | SUIS | schin-op-geul | michelin 2026 | create ve_6267d02f02 (/schin-op-geul/suis), listing published=true, + 1 award |
| 18 | new_venue | Azurite | delft | michelin 2026 | create ve_dd68e7cb45 (/delft/azurite), listing published=true, + 1 award |
| 22 | new_venue | Le Epifaan | veeningen | michelin 2026 | create ve_68d6eacdf5 (/veeningen/le-epifaan), listing published=true, + 1 award |
| 29 | new_venue | 't Raedthuys | duiven | michelin 2026 | create ve_ac078b1119 (/duiven/t-raedthuys), listing published=true, + 1 award |
| 32 | new_venue | Wild Atelier | hoog-soeren | michelin 2026 | create ve_ff06e71af7 (/hoog-soeren/wild-atelier), listing published=true, + 1 award |
| 1 | match | De Librije | zwolle | michelin 2026 | + 1 award on ve_5f52cd46f6 |
| 2 | match | 't Nonnetje | harderwijk | michelin 2026 | + 1 award on ve_f321850bef |
| 3 | match | De Nieuwe Winkel | nijmegen | michelin 2026 | + 1 award on ve_b24eaf6c99 |
| 4 | match | Create by Guido Braeken | eijsden | michelin 2026 | + 1 award on ve_cf262729c2 |
| 5 | match | Brut172 | reijmerstok | michelin 2026 | + 1 award on ve_face3f9c07 |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-netherlands
confirmation: PROMOTE michelin-2026-netherlands
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 196 rows from fixtures/ingest/michelin-2026-netherlands.csv |
| 2 | opened the database connection | 0.2s | 0.2s |  |
| 3 | read the source vocabulary | 0.2s | 0.4s | 23 sources |
| 4 | re-read the staged rows | 0.1s | 0.5s | batch 16, 196 rows |
| 5 | row checks | 0.0s | 0.5s | 196 of 196 rows still live |
| 6 | loaded the live rows into the resolver | 0.1s | 0.6s | 196 rows |
| 7 | normalised the batch | 0.0s | 0.6s | 196 rows, in the database |
| 8 | loaded the candidate cities | 0.1s | 0.8s | 105 cities |
| 9 | loaded the candidate venues | 0.1s | 0.8s | 119 venues |
| 10 | resolved cities | 0.0s | 0.8s | 196 of 196 settled on one city |
| 11 | resolved venues | 0.0s | 0.8s | 99 matched an existing venue |
| 12 | loose-name pass | 0.1s | 1.0s | 94 would-be new venues checked, 42 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.1s | 1.1s |  |
| 14 | built the promote plan | 0.2s | 1.2s | 21 venues, 196 awards |
| 15 | wrote the verdicts | 0.2s | 1.4s | 196 rows |
| 16 | committed | 0.0s | 1.4s |  |
