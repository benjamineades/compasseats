# Ingest stage - first-batch-2026-09

Staged 2026-09-12T23:24:09.858Z. **Nothing has been promoted.** This run wrote to
`ingest_batches` and `ingest_rows` only; every live table is untouched.

## What came in

| field | value |
|---|---|
| batch key | `first-batch-2026-09` |
| batch id | 1 |
| CSV | `fixtures/ingest/first-batch-2026-09.csv` |
| rows in | 10 |
| source(s) | 5 sources: 101-best-steakhouses, asia-50-best-restaurants, latin-america-50-best-restaurants, top-500-bars, worlds-50-best-restaurants |
| list year(s) | 7 years: 2003, 2004, 2005, 2019, 2024, 2025, 2026 |
| batch key check | batch_key column present and equal to "first-batch-2026-09" on every row |

> This batch carries more than one source, so `ingest_batches.source_id` is left
> blank rather than guessing one. Same for `list_year` across 7 years.

## Columns

Every column was already in the canonical shape; nothing was renamed.

## Verdicts

Population: all 10 data rows in the CSV. Grouping key: the row's verdict.

| verdict | rows | what it means |
|---|---|---|
| new_venue | 10 | promote creates the venue, listing, slug, city labels and the award |

## What promote would do to the live tables

Population: whole table. Read now, before anything was promoted.

| table | before | expected after | delta |
|---|---|---|---|
| venues | 10,899 | 10,907 | +8 |
| awards | 21,805 | 21,815 | +10 |
| listings | 10,899 | 10,907 | +8 |
| slugs | 11,156 | 11,164 | +8 |
| city_label_source | 22,082 | 22,098 | +16 |
| price | 7,091 | 7,091 | +0 |
| source_capture_ledger | 0 | 10 | +10 |

The venue delta is **8**, not the number of `new_venue` rows (10). Several award rows can name the same new venue - one venue row, one listing, one slug, several awards.

Open venues now: 10,519. Promote refuses to let that number drop.

### Ranks another venue already holds

A published rank belongs to one venue. These rows claim a rank that is already
on someone else. They promote normally - the job never moves or deletes an award -
but one of the two is wrong and only you can say which.

| line | this row | source / year / rank | already on |
|---|---|---|---|
| 2 | La Cúpula de El Capricho | 101-best-steakhouses 2026 #1 | Bodega El Capricho (`ve_c1cc29d546`, awards.id 19237) |

## Sample - what promote will do, row by row

| line | verdict | venue | city | award | promote does |
|---|---|---|---|---|---|
| 1 | new_venue | Brabo | barcelona | 101-best-steakhouses 2026 #101 | create ve_90010c596c (/barcelona/brabo), listing published=true, + 1 award |
| 2 | new_venue | La Cúpula de El Capricho | jimenez-de-jamuz | 101-best-steakhouses 2026 #1 | create ve_d7eda91bd8 (/jimenez-de-jamuz/la-cupula-de-el-capricho), listing published=true, + 1 award |
| 3 | new_venue | Corner House | singapore | asia-50-best-restaurants 2019 #49 | create ve_6482ecd262 (/singapore/corner-house), listing published=true, + 1 award |
| 4 | new_venue | Malabar | lima | latin-america-50-best-restaurants 2019 #48 | create ve_b4544bd01c (/lima/malabar), listing published=true, + 1 award |
| 5 | new_venue | Ralph's Bar | chengdu | top-500-bars 2024 #417 | create ve_82dd70d831 (/chengdu/ralph-s-bar), listing published=true, + 1 award |

## Review

Nothing needs your eyes. **0 rows in review.**

## Next

Run the **ingest-promote** workflow with:

```
batch_key:    first-batch-2026-09
confirmation: PROMOTE first-batch-2026-09
```

The confirmation has to be exactly that, including the batch key. Anything else stops.
