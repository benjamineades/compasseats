# Ingest promote - michelin-2026-american-south

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,291 | 11,307 | 11,307 |
| awards | 22,841 | 22,922 | 22,922 |
| listings | 11,291 | 11,307 | 11,307 |
| slugs | 12,816 | 12,832 | 12,832 |
| city_label_source | 23,979 | 24,011 | 24,011 |
| price | 7,024 | 7,024 | 7,024 |
| source_capture_ledger | 91 | 93 | 93 |

Active venues: 10,924 -> 10,940.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 81 (expected 81) |
| venues delta equals new venues | pass | 16 (expected 16) |
| listings delta equals new venues | pass | 16 (expected 16) |
| slugs delta equals new venues | pass | 16 (expected 16) |
| city_label_source delta equals planned labels | pass | 32 (expected 32) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10924 -> 10940 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_b83e690aca` | So. Fox | /atlanta/so-fox | active | true | 1 |
| `ve_82f336e11a` | Uberto Restaurant | /gay/uberto-restaurant | active | true | 1 |
| `ve_002bb1220b` | Summerland | /atlanta/summerland | active | true | 1 |
| `ve_9949d04394` | Tipsy Thaiger | /roswell/tipsy-thaiger | active | true | 1 |
| `ve_4c77fb33dc` | Safta's Table | /new-orleans/safta-s-table | active | true | 1 |
| `ve_be9428c3a0` | Miscellanea Spirit House | /oxford-us/miscellanea-spirit-house | active | true | 1 |
| `ve_53b3b5d3e5` | Tesoro | /carrboro/tesoro | active | true | 1 |
| `ve_5fcfaab691` | The Story of "Mi Cariño" | /charlotte/the-story-of-mi-carino | active | true | 1 |
| `ve_ff8fd903dd` | Ideal's | /durham/ideal-s | active | true | 1 |
| `ve_e05c8150b3` | Ajja | /raleigh/ajja | active | true | 1 |
| `ve_154740d5e3` | Okàn | /bluffton/okan | active | true | 1 |
| `ve_0c90f6c0c8` | Palmira | /charleston/palmira | active | true | 1 |
| `ve_795adb5ebe` | Rivayat Creative Indian | /charleston/rivayat-creative-indian | active | true | 1 |
| `ve_f9a0661361` | A Dopo | /knoxville-tennessee/a-dopo | active | true | 1 |
| `ve_428a966a61` | Bao Toan Kitchen & Bar | /memphis/bao-toan-kitchen-bar | active | true | 1 |
| `ve_86c535260d` | Maiz De La Vida | /nashville/maiz-de-la-vida | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-american-south`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 81 |
| michelin | city_label | 32 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-american-south`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-american-south`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
