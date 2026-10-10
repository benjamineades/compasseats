# Ingest promote - michelin-2026-texas

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,223 | 11,232 | 11,232 |
| awards | 22,389 | 22,462 | 22,462 |
| listings | 11,223 | 11,232 | 11,232 |
| slugs | 12,557 | 12,566 | 12,566 |
| city_label_source | 23,850 | 23,868 | 23,868 |
| price | 7,048 | 7,048 | 7,048 |
| source_capture_ledger | 74 | 76 | 76 |

Active venues: 10,859 -> 10,868.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 73 (expected 73) |
| venues delta equals new venues | pass | 9 (expected 9) |
| listings delta equals new venues | pass | 9 (expected 9) |
| slugs delta equals new venues | pass | 9 (expected 9) |
| city_label_source delta equals planned labels | pass | 18 (expected 18) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10859 -> 10868 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_a195aa4251` | Kappo Kappo | /austin/kappo-kappo | active | true | 1 |
| `ve_89a19471a1` | Fabrik | /austin/fabrik | active | true | 1 |
| `ve_b8f74cf2b7` | LeRoy and Lewis Barbecue | /austin/leroy-and-lewis-barbecue | active | true | 1 |
| `ve_19487f4036` | Khói Barbecue | /houston/khoi-barbecue | active | true | 1 |
| `ve_c28c3793ac` | Kitchen Rumors | /houston/kitchen-rumors | active | true | 1 |
| `ve_e33e161b48` | Xolo | /houston/xolo | active | true | 1 |
| `ve_99ef79d850` | Bar Buena | /houston/bar-buena | active | true | 1 |
| `ve_efdb19e12c` | Murray's Pizza & Wine | /houston/murray-s-pizza-wine | active | true | 1 |
| `ve_06fd2951bb` | Resident Taqueria | /dallas/resident-taqueria | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-texas`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 73 |
| michelin | city_label | 18 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-texas`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-texas`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
