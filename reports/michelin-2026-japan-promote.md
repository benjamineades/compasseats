# Ingest promote - michelin-2026-japan

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,575 | 11,590 | 11,590 |
| awards | 23,516 | 24,101 | 24,101 |
| listings | 11,575 | 11,590 | 11,590 |
| slugs | 11,832 | 11,847 | 11,847 |
| city_label_source | 23,434 | 23,464 | 23,464 |
| price | 7,091 | 7,091 | 7,091 |
| source_capture_ledger | 16 | 18 | 18 |

Active venues: 11,195 -> 11,210.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 585 (expected 585) |
| venues delta equals new venues | pass | 15 (expected 15) |
| listings delta equals new venues | pass | 15 (expected 15) |
| slugs delta equals new venues | pass | 15 (expected 15) |
| city_label_source delta equals planned labels | pass | 30 (expected 30) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 11195 -> 11210 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_175f7d63c2` | Sukiyabashi Jiro Roppongiten | /tokyo/sukiyabashi-jiro-roppongiten | active | true | 1 |
| `ve_1fa2789470` | JO | /tokyo/jo | active | true | 1 |
| `ve_961188cfbe` | Sassa | /tokyo/sassa | active | true | 1 |
| `ve_f191378d18` | Ukitacho Ima | /osaka/ukitacho-ima | active | true | 1 |
| `ve_6dba6cdecb` | Ñ | /osaka/n | active | true | 1 |
| `ve_f9e52b367f` | Sobakappo Nagano | /tokyo/sobakappo-nagano | active | true | 1 |
| `ve_1e44b6e20e` | YAMATO | /tokyo/yamato | active | true | 1 |
| `ve_22be3b24aa` | Shinrakuki | /tokyo/shinrakuki | active | true | 1 |
| `ve_092565cb65` | Sobakiri Suzuki | /tokyo/sobakiri-suzuki | active | true | 1 |
| `ve_0f8d54f738` | DIALOGUE | /tokyo/dialogue | active | true | 1 |
| `ve_16ecfa59c1` | there is ramen | /tokyo/there-is-ramen | active | true | 1 |
| `ve_a7ae8c5e47` | Shinjiko Shijimi Chukasoba Kohaku | /tokyo/shinjiko-shijimi-chukasoba-kohaku | active | true | 1 |
| `ve_d5004c5cad` | Tan | /kyoto/tan | active | true | 1 |
| `ve_9d8e88772a` | Noto Toto Teuchisoba Tabiki | /nara/noto-toto-teuchisoba-tabiki | active | true | 1 |
| `ve_8b14006ced` | Shuko Osaka Manpukudou | /osaka/shuko-osaka-manpukudou | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-japan`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 585 |
| michelin | city_label | 30 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-japan`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-japan`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
