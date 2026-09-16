# Ingest promote - michelin-2026-spain

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,034 | 11,042 | 11,042 |
| awards | 21,964 | 22,457 | 22,457 |
| listings | 11,034 | 11,042 | 11,042 |
| slugs | 11,847 | 11,855 | 11,855 |
| city_label_source | 23,464 | 23,480 | 23,480 |
| price | 7,091 | 7,091 | 7,091 |
| source_capture_ledger | 24 | 26 | 26 |

Active venues: 10,666 -> 10,674.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 493 (expected 493) |
| venues delta equals new venues | pass | 8 (expected 8) |
| listings delta equals new venues | pass | 8 (expected 8) |
| slugs delta equals new venues | pass | 8 (expected 8) |
| city_label_source delta equals planned labels | pass | 16 (expected 16) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10666 -> 10674 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_89ca903ac2` | Terra | /fisterra/terra | active | true | 1 |
| `ve_de7750ef83` | Casa Marcelo | /santiago-de-compostela/casa-marcelo | active | true | 1 |
| `ve_8cbf21d12d` | Ola Martín Berasategui | /bilbao/ola-martin-berasategui | active | true | 1 |
| `ve_17475f658b` | Villa Retiro | /xerta/villa-retiro | active | true | 1 |
| `ve_38feaaecd2` | Origen | /carcaixent/origen | active | true | 1 |
| `ve_ceb4224c81` | Casa Nova | /sant-marti-sarroca/casa-nova | active | true | 1 |
| `ve_e79de0a3eb` | Ca l'Enric | /la-vall-de-bianya/ca-l-enric | active | true | 1 |
| `ve_b4df10d4f7` | Origen | /urdaniz/origen | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-spain`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 493 |
| michelin | city_label | 16 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-spain`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-spain`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
