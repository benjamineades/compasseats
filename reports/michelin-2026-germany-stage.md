# Ingest stage - michelin-2026-germany

Staged 2026-10-08T23:50:33.865Z. **Nothing has been promoted.** This run wrote to
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
| re-stage | decisions re-applied to the existing batch; 252 decision(s) read |

## Columns

Every column was already in the canonical shape; nothing was renamed.

Present in the file and **not used by this job**: `michelin_guide`, `venue_name_de`, `city_label_de`.

## Verdicts

Population: all 483 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| duplicate | 336 | this exact award already exists; promote skips it |
| match | 128 | venue already exists; promote adds the award |
| new_venue | 19 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 11,205 | 11,224 | +19 |
| awards | 22,249 | 22,396 | +147 |
| listings | 11,205 | 11,224 | +19 |
| slugs | 12,304 | 12,323 | +19 |
| city_label_source | 23,814 | 23,852 | +38 |
| price | 7,049 | 7,049 | +0 |
| source_capture_ledger | 65 | 67 | +2 |

The venue delta is **19**, not the number of `new_venue` rows (19). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,839. Promote refuses to let that number drop.

### Price rows not written

| rows | reason |
|---|---|
| 147 | source michelin is not price_capable |

> No source in `award_sources` has `price_capable = true` today, so the price
> branch writes nothing for any batch. Flipping that flag for a publisher is a
> D10 decision, not something this job does.

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 177 | new_venue | Aubergine | starnberg | michelin 2026 | create ve_660e52c8f5 (/starnberg/aubergine), listing published=true, + 1 award |
| 345 | new_venue | Hirsch | berghaupten | michelin 2026 | create ve_f06df0ad3c (/berghaupten/hirsch), listing published=true, + 1 award |
| 348 | new_venue | Hirsch | ellwangen | michelin 2026 | create ve_9a35ffe0b1 (/ellwangen/hirsch), listing published=true, + 1 award |
| 364 | new_venue | Stube ZWEI.NULL | langenau | michelin 2026 | create ve_8654bf99d5 (/langenau/stube-zwei-null), listing published=true, + 1 award |
| 369 | new_venue | Brasserie Barbara | schluchsee | michelin 2026 | create ve_183605970b (/schluchsee/brasserie-barbara), listing published=true, + 1 award |
| 36 | match | AURA by Alexander Herrmann & Tobias Bätz | wirsberg | michelin 2026 | + 1 award on ve_410be56f8e |
| 339 | match | LAMM | bad-herrenalb | michelin 2026 | + 1 award on ve_fa36943b0a |
| 340 | match | Kamin- und Bauernstube | bad-peterstal-griesbach | michelin 2026 | + 1 award on ve_5cdf75f74e |
| 341 | match | Klösterle Hof | bad-rippoldsau | michelin 2026 | + 1 award on ve_e387ce797a |
| 342 | match | Weinstube zum Engel | baden-baden | michelin 2026 | + 1 award on ve_31e09545ac |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    michelin-2026-germany
confirmation: PROMOTE michelin-2026-germany
```

The confirmation has to be exactly that, including the batch key. Anything else stops.

## Timings

Where this run's wall clock went, phase by phase. The same table is written
to this file as each phase completes, so a run that is cancelled or fails
still says how far it got.

| # | phase | took | elapsed | detail |
|---|---|---|---|---|
| 1 | read the CSV | 0.0s | 0.0s | 483 rows from fixtures/ingest/michelin-2026-germany.csv |
| 2 | opened the database connection | 0.3s | 0.3s |  |
| 3 | read the source vocabulary | 0.5s | 0.8s | 23 sources |
| 4 | re-read the staged rows | 0.3s | 1.0s | batch 13, 483 rows |
| 5 | row checks | 0.0s | 1.0s | 483 of 483 rows still live |
| 6 | loaded the live rows into the resolver | 0.3s | 1.3s | 483 rows |
| 7 | normalised the batch | 0.1s | 1.4s | 483 rows, in the database |
| 8 | loaded the candidate cities | 0.3s | 1.7s | 288 cities |
| 9 | loaded the candidate venues | 0.2s | 1.9s | 268 venues |
| 10 | resolved cities | 0.0s | 1.9s | 483 of 483 settled on one city |
| 11 | resolved venues | 0.0s | 1.9s | 231 matched an existing venue |
| 12 | loose-name pass | 0.3s | 2.2s | 248 would-be new venues checked, 69 sent to review |
| 13 | dedupe, subsume and rank conflicts | 0.3s | 2.5s |  |
| 14 | built the promote plan | 0.4s | 2.9s | 19 venues, 147 awards |
| 15 | wrote the verdicts | 0.6s | 3.5s | 483 rows |
| 16 | committed | 0.1s | 3.6s |  |
