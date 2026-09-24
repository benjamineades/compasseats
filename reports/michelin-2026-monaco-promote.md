# Ingest promote - michelin-2026-monaco

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,041 | 11,041 | 11,041 |
| awards | 21,977 | 21,986 | 21,986 |
| listings | 11,041 | 11,041 | 11,041 |
| slugs | 11,854 | 11,854 | 11,854 |
| city_label_source | 23,478 | 23,478 | 23,478 |
| price | 7,090 | 7,090 | 7,090 |
| source_capture_ledger | 27 | 28 | 28 |

Active venues: 10,678 -> 10,678.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 9 (expected 9) |
| venues delta equals new venues | pass | 0 (expected 0) |
| listings delta equals new venues | pass | 0 (expected 0) |
| slugs delta equals new venues | pass | 0 (expected 0) |
| city_label_source delta equals planned labels | pass | 0 (expected 0) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 1 (expected 1) |
| active venue count did not drop | pass | 10678 -> 10678 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-monaco`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 9 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-monaco`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-monaco`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
