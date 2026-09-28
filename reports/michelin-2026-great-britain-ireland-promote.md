# Ingest promote - michelin-2026-great-britain-ireland

Committed 2026-09-28T18:31:50.721Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,209 | 11,214 | 11,214 |
| awards | 22,237 | 22,623 | 22,623 |
| listings | 11,209 | 11,214 | 11,214 |
| slugs | 12,290 | 12,295 | 12,295 |
| city_label_source | 23,822 | 23,832 | 23,832 |
| price | 7,059 | 7,059 | 7,059 |
| source_capture_ledger | 55 | 57 | 57 |

Active venues: 10,848 -> 10,853.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 386 (expected 386) |
| venues delta equals new venues | pass | 5 (expected 5) |
| listings delta equals new venues | pass | 5 (expected 5) |
| slugs delta equals new venues | pass | 5 (expected 5) |
| city_label_source delta equals planned labels | pass | 10 (expected 10) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10848 -> 10853 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_ce39832bd0` | Corenucopia by Clare Smyth | /london/corenucopia-by-clare-smyth | active | true | 1 |
| `ve_61599d9f2f` | Pétrus by Gordon Ramsay | /london/petrus-by-gordon-ramsay | active | true | 1 |
| `ve_fc7016664d` | 1890 by Gordon Ramsay | /london/1890-by-gordon-ramsay | active | true | 1 |
| `ve_1ade09cf15` | COR | /city-of-bristol/cor | active | true | 1 |
| `ve_bd55d03429` | OTHER | /city-of-bristol/other | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-great-britain-ireland`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 386 |
| michelin | city_label | 10 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-great-britain-ireland`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-great-britain-ireland`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
