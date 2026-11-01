# Ingest promote - michelin-2026-hong-kong-macau

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,300 | 11,306 | 11,306 |
| awards | 23,362 | 23,370 | 23,370 |
| listings | 11,300 | 11,306 | 11,306 |
| slugs | 12,950 | 12,956 | 12,956 |
| city_label_source | 23,999 | 24,011 | 24,011 |
| price | 7,731 | 7,731 | 7,731 |
| source_capture_ledger | 149 | 151 | 151 |

Active venues: 10,935 -> 10,941.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 8 (expected 8) |
| venues delta equals new venues | pass | 6 (expected 6) |
| listings delta equals new venues | pass | 6 (expected 6) |
| slugs delta equals new venues | pass | 6 (expected 6) |
| city_label_source delta equals planned labels | pass | 12 (expected 12) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10935 -> 10941 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_403f3ed56b` | Lai Ching Heen | /hong-kong/lai-ching-heen | active | true | 1 |
| `ve_e49568f69f` | Dragon Inn | /hong-kong/dragon-inn | active | true | 1 |
| `ve_35baee2d3a` | Eton | /hong-kong/eton | active | true | 1 |
| `ve_01b130259b` | Eng Kee Noodle Shop | /hong-kong/eng-kee-noodle-shop | active | true | 1 |
| `ve_b02a3e951b` | Sang Kee Foods (Western District) | /hong-kong/sang-kee-foods-western-district | active | true | 1 |
| `ve_85e880a028` | Ăn Chơi | /hong-kong/an-choi | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-hong-kong-macau`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 8 |
| michelin | city_label | 12 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-hong-kong-macau`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-hong-kong-macau`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
