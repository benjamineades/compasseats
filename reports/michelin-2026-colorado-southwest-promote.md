# Ingest promote - michelin-2026-colorado-southwest

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,041 | 11,061 | 11,061 |
| awards | 21,978 | 22,024 | 22,024 |
| listings | 11,041 | 11,061 | 11,061 |
| slugs | 11,854 | 11,874 | 11,874 |
| city_label_source | 23,478 | 23,518 | 23,518 |
| price | 7,090 | 7,090 | 7,090 |
| source_capture_ledger | 29 | 31 | 31 |

Active venues: 10,678 -> 10,698.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 46 (expected 46) |
| venues delta equals new venues | pass | 20 (expected 20) |
| listings delta equals new venues | pass | 20 (expected 20) |
| slugs delta equals new venues | pass | 20 (expected 20) |
| city_label_source delta equals planned labels | pass | 40 (expected 40) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10678 -> 10698 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_ae2045d603` | Milpero | /denver/milpero | active | true | 1 |
| `ve_e13bd5c2c2` | Pig and Tiger | /denver/pig-and-tiger | active | true | 1 |
| `ve_64c540d88e` | Rougarou | /denver/rougarou | active | true | 1 |
| `ve_8e41aa3f13` | Monte | /south-salt-lake/monte | active | true | 1 |
| `ve_febc96b2d2` | Huarachis Taqueria | /phoenix/huarachis-taqueria | active | true | 1 |
| `ve_5934ca89a5` | kid sister | /phoenix/kid-sister | active | true | 1 |
| `ve_92b3a99385` | Esther's Kitchen | /las-vegas/esther-s-kitchen | active | true | 1 |
| `ve_cfe688ea98` | Valentine | /phoenix/valentine | active | true | 1 |
| `ve_f0abb402c3` | China Poblano | /las-vegas/china-poblano | active | true | 1 |
| `ve_49d7f4be37` | Feldman's Deli | /salt-lake-city/feldman-s-deli | active | true | 1 |
| `ve_b89369c406` | Paper Dosa | /santa-fe/paper-dosa | active | true | 1 |
| `ve_1c69e31580` | La Choza | /santa-fe/la-choza | active | true | 1 |
| `ve_5236dd8a92` | Pizzeria Bianco | /phoenix/pizzeria-bianco | active | true | 1 |
| `ve_5a6400a60d` | Phở 777 | /west-valley-city/pho-777 | active | true | 1 |
| `ve_940eb2f957` | One More Noodle House | /south-salt-lake/one-more-noodle-house | active | true | 1 |
| `ve_ccdf63d0e0` | Little Miss BBQ | /phoenix/little-miss-bbq | active | true | 1 |
| `ve_26086996f8` | Jambo Cafe | /santa-fe/jambo-cafe | active | true | 1 |
| `ve_f1086e1d3a` | YEN Viet Kitchen | /las-vegas/yen-viet-kitchen | active | true | 1 |
| `ve_0a95c84359` | Frontier | /albuquerque/frontier | active | true | 1 |
| `ve_221a7b3549` | Tia Sophia's | /santa-fe/tia-sophia-s | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-colorado-southwest`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 46 |
| michelin | city_label | 40 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-colorado-southwest`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-colorado-southwest`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
