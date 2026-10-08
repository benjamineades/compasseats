# Ingest promote - michelin-2026-germany

Committed 2026-10-08T23:53:29.822Z. One transaction, all of it or none of it.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,205 | 11,224 | 11,224 |
| awards | 22,249 | 22,396 | 22,396 |
| listings | 11,205 | 11,224 | 11,224 |
| slugs | 12,304 | 12,323 | 12,323 |
| city_label_source | 23,814 | 23,852 | 23,852 |
| price | 7,049 | 7,049 | 7,049 |
| source_capture_ledger | 65 | 67 | 67 |

Active venues: 10,839 -> 10,858.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 147 (expected 147) |
| venues delta equals new venues | pass | 19 (expected 19) |
| listings delta equals new venues | pass | 19 (expected 19) |
| slugs delta equals new venues | pass | 19 (expected 19) |
| city_label_source delta equals planned labels | pass | 38 (expected 38) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10839 -> 10858 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_660e52c8f5` | Aubergine | /starnberg/aubergine | active | true | 1 |
| `ve_f06df0ad3c` | Hirsch | /berghaupten/hirsch | active | true | 1 |
| `ve_9a35ffe0b1` | Hirsch | /ellwangen/hirsch | active | true | 1 |
| `ve_8654bf99d5` | Stube ZWEI.NULL | /langenau/stube-zwei-null | active | true | 1 |
| `ve_183605970b` | Brasserie Barbara | /schluchsee/brasserie-barbara | active | true | 1 |
| `ve_043c47cdb3` | Die Krone | /sulzbach-laufen/die-krone | active | true | 1 |
| `ve_5f5a5a4e0a` | Schwingshackl HEIMATKÜCHE | /bernried/schwingshackl-heimatkuche | active | true | 1 |
| `ve_748fb081d6` | Zur Krone | /grossheubach/zur-krone | active | true | 1 |
| `ve_a5e7191926` | mokum | /munich/mokum | active | true | 1 |
| `ve_9b7f264837` | Das Palmberger - hoamART | /spiegelau/das-palmberger-hoamart | active | true | 1 |
| `ve_9c574617dc` | CHEZ NASSIB | /berlin/chez-nassib | active | true | 1 |
| `ve_a91aa70189` | Salhino | /berlin/salhino | active | true | 1 |
| `ve_502cb3df27` | CYN CYN | /hamburg/cyn-cyn | active | true | 1 |
| `ve_e583bec755` | GASSENHAUR | /hamburg/gassenhaur | active | true | 1 |
| `ve_fc5934befb` | LENZ | /hamburg/lenz | active | true | 1 |
| `ve_a0aa7d14ee` | Bornheimer Ratskeller | /frankfurt/bornheimer-ratskeller | active | true | 1 |
| `ve_19bac307ee` | Mühlenhelle - Bistro | /gummersbach/muhlenhelle-bistro | active | true | 1 |
| `ve_dfface2f35` | WEINreich | /freinsheim/weinreich | active | true | 1 |
| `ve_e17b5f1052` | Landgenuss | /blieskastel/landgenuss | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-germany`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 147 |
| michelin | city_label | 38 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-germany`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-germany`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
