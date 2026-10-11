# Ingest promote - michelin-2026-netherlands

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,233 | 11,254 | 11,254 |
| awards | 22,463 | 22,659 | 22,659 |
| listings | 11,233 | 11,254 | 11,254 |
| slugs | 12,617 | 12,638 | 12,638 |
| city_label_source | 23,870 | 23,912 | 23,912 |
| price | 7,048 | 7,048 | 7,048 |
| source_capture_ledger | 83 | 85 | 85 |

Active venues: 10,866 -> 10,887.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 196 (expected 196) |
| venues delta equals new venues | pass | 21 (expected 21) |
| listings delta equals new venues | pass | 21 (expected 21) |
| slugs delta equals new venues | pass | 21 (expected 21) |
| city_label_source delta equals planned labels | pass | 42 (expected 42) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10866 -> 10887 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_6267d02f02` | SUIS | /schin-op-geul/suis | active | true | 1 |
| `ve_dd68e7cb45` | Azurite | /delft/azurite | active | true | 1 |
| `ve_68d6eacdf5` | Le Epifaan | /veeningen/le-epifaan | active | true | 1 |
| `ve_ac078b1119` | 't Raedthuys | /duiven/t-raedthuys | active | true | 1 |
| `ve_ff06e71af7` | Wild Atelier | /hoog-soeren/wild-atelier | active | true | 1 |
| `ve_e5c8a91032` | Nassau | /groningen/nassau | active | true | 1 |
| `ve_c914e2cfe3` | Ambrozijn | /valkenburg-aan-de-geul/ambrozijn | active | true | 1 |
| `ve_2f893f9438` | De Cuijt | /mierlo/de-cuijt | active | true | 1 |
| `ve_f0d56b4eae` | Bistro de la Mer | /amsterdam/bistro-de-la-mer | active | true | 1 |
| `ve_71312bb8f8` | Bij Sidney | /loenen-aan-de-vecht/bij-sidney | active | true | 1 |
| `ve_12e1dee96f` | Rozewied | /kortgene/rozewied | active | true | 1 |
| `ve_128b8427d0` | Dokjard | /groningen/dokjard | active | true | 1 |
| `ve_c2c0630e58` | Bistro Luux | /weert/bistro-luux | active | true | 1 |
| `ve_6d9803a0e6` | ORA | Taverna & Bar | /breda/ora-taverna-bar | active | true | 1 |
| `ve_09f0bb8b15` | Bistro Toost | /amstelveen/bistro-toost | active | true | 1 |
| `ve_8669f5408d` | Boon & De Koot | /amsterdam/boon-de-koot | active | true | 1 |
| `ve_e7949f46d6` | FuLu Mandarijn | /amsterdam/fulu-mandarijn | active | true | 1 |
| `ve_e515f6353a` | Utage Sake Bar | /amsterdam/utage-sake-bar | active | true | 1 |
| `ve_3be5964407` | Brasserie Bruis | /haarlem/brasserie-bruis | active | true | 1 |
| `ve_b36d4390ac` | Wijn Boer | /zwolle/wijn-boer | active | true | 1 |
| `ve_1e7a896777` | Ramen Kitanoya | /the-hague/ramen-kitanoya | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-netherlands`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 196 |
| michelin | city_label | 42 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-netherlands`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-netherlands`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
