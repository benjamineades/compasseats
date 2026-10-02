# Ingest promote - michelin-2026-chengdu

Committed 2026-10-02T21:27:57.985Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,211 | 11,212 | 11,212 |
| awards | 22,241 | 22,256 | 22,256 |
| listings | 11,211 | 11,212 | 11,212 |
| slugs | 12,310 | 12,311 | 12,311 |
| city_label_source | 23,826 | 23,828 | 23,828 |
| price | 7,056 | 7,056 | 7,056 |
| source_capture_ledger | 61 | 63 | 63 |

Active venues: 10,845 -> 10,846.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 15 (expected 15) |
| venues delta equals new venues | pass | 1 (expected 1) |
| listings delta equals new venues | pass | 1 (expected 1) |
| slugs delta equals new venues | pass | 1 (expected 1) |
| city_label_source delta equals planned labels | pass | 2 (expected 2) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10845 -> 10846 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_24aeca03f9` | Zhu Ji Zhi Mian Pu (Jinjiang) | /chengdu/zhu-ji-zhi-mian-pu-jinjiang | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-chengdu`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 15 |
| michelin | city_label | 2 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-chengdu`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-chengdu`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
