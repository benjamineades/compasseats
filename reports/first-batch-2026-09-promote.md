# Ingest promote - first-batch-2026-09

Committed 2026-09-12T23:28:00.945Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 10,899 | 10,907 | 10,907 |
| awards | 21,805 | 21,815 | 21,815 |
| listings | 10,899 | 10,907 | 10,907 |
| slugs | 11,156 | 11,164 | 11,164 |
| city_label_source | 22,082 | 22,098 | 22,098 |
| price | 7,091 | 7,091 | 7,091 |
| source_capture_ledger | 0 | 10 | 10 |

Active venues: 10,519 -> 10,527.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 10 (expected 10) |
| venues delta equals new venues | pass | 8 (expected 8) |
| listings delta equals new venues | pass | 8 (expected 8) |
| slugs delta equals new venues | pass | 8 (expected 8) |
| city_label_source delta equals planned labels | pass | 16 (expected 16) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 10 (expected 10) |
| active venue count did not drop | pass | 10519 -> 10527 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_90010c596c` | Brabo | /barcelona/brabo | active | true | 1 |
| `ve_d7eda91bd8` | La Cúpula de El Capricho | /jimenez-de-jamuz/la-cupula-de-el-capricho | active | true | 1 |
| `ve_6482ecd262` | Corner House | /singapore/corner-house | active | true | 1 |
| `ve_b4544bd01c` | Malabar | /lima/malabar | active | true | 1 |
| `ve_82dd70d831` | Ralph's Bar | /chengdu/ralph-s-bar | active | true | 1 |
| `ve_ee52b777f2` | REM | /rome/rem | active | true | 1 |
| `ve_8b1b2d3522` | Café Arixi | /mexico-city/cafe-arixi | active | true | 1 |
| `ve_f026dbec1c` | Guy Savoy | /paris/guy-savoy | active | true | 3 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:first-batch-2026-09`.

| publisher | field type | items |
|---|---|---|
| 101-best-steakhouses | award | 2 |
| 101-best-steakhouses | city_label | 4 |
| asia-50-best-restaurants | award | 1 |
| asia-50-best-restaurants | city_label | 2 |
| latin-america-50-best-restaurants | award | 1 |
| latin-america-50-best-restaurants | city_label | 2 |
| top-500-bars | award | 3 |
| top-500-bars | city_label | 6 |
| worlds-50-best-restaurants | award | 3 |
| worlds-50-best-restaurants | city_label | 2 |

## Undo

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `first-batch-2026-09`, and `audit_log` holds
every row with its timestamp. A reversal job is a separate piece of work - there is
no undo button here.
