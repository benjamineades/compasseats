# Ingest promote - michelin-2026-belgium-luxembourg

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,232 | 11,233 | 11,233 |
| awards | 22,462 | 22,709 | 22,709 |
| listings | 11,232 | 11,233 | 11,233 |
| slugs | 12,575 | 12,576 | 12,576 |
| city_label_source | 23,868 | 23,870 | 23,870 |
| price | 7,048 | 7,048 | 7,048 |
| source_capture_ledger | 77 | 79 | 79 |

Active venues: 10,866 -> 10,867.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 247 (expected 247) |
| venues delta equals new venues | pass | 1 (expected 1) |
| listings delta equals new venues | pass | 1 (expected 1) |
| slugs delta equals new venues | pass | 1 (expected 1) |
| city_label_source delta equals planned labels | pass | 2 (expected 2) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10866 -> 10867 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_9916c47b98` | Zur Post | /saint-vith/zur-post | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-belgium-luxembourg`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 247 |
| michelin | city_label | 2 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-belgium-luxembourg`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-belgium-luxembourg`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
