# Ingest promote - michelin-2026-switzerland

**Dry run - rolled back.** Everything below is what would have happened.
The live tables are exactly as they were.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,293 | 11,323 | 11,323 |
| awards | 25,097 | 25,322 | 25,322 |
| listings | 11,293 | 11,323 | 11,323 |
| slugs | 13,022 | 13,052 | 13,052 |
| city_label_source | 23,989 | 24,049 | 24,049 |
| price | 7,727 | 7,727 | 7,727 |
| source_capture_ledger | 186 | 188 | 188 |

Active venues: 10,999 -> 11,029.

## Invariants

| check | result | detail |
|---|---|---|
| awards delta equals promoted award rows | pass | 225 (expected 225) |
| venues delta equals new venues | pass | 30 (expected 30) |
| listings delta equals new venues | pass | 30 (expected 30) |
| slugs delta equals new venues | pass | 30 (expected 30) |
| city_label_source delta equals planned labels | pass | 60 (expected 60) |
| price delta equals planned price rows | pass | 0 (expected 0) |
| ledger delta equals planned ledger rows | pass | 2 (expected 2) |
| active venue count did not drop | pass | 10999 -> 11029 |
| every inserted award carries a source_url | pass | 0 without one |
| every inserted award names a registered source | pass | 0 unregistered |
| no google value anywhere in what was written | pass | clean |

## Venues created

| venue id | name | url | status | published | awards |
|---|---|---|---|---|---|
| `ve_b76744c249` | Restaurant de l'Hôtel de Ville | /ollon/restaurant-de-l-hotel-de-ville | active | true | 1 |
| `ve_db48bdeac3` | Restaurant LA | /basel/restaurant-la | active | true | 1 |
| `ve_a3d2920b36` | La Croix d'Or | /ballaigues/la-croix-d-or | active | true | 1 |
| `ve_b28565111d` | Ristorante con enoteca Origini | /morbio-inferiore/ristorante-con-enoteca-origini | active | true | 1 |
| `ve_256ad43e81` | Bärenstobe | /gonten/barenstobe | active | true | 1 |
| `ve_ea5087dab9` | ad lib | /zermatt/ad-lib | active | true | 1 |
| `ve_e8334e9d06` | MYLE | /berne/myle | active | true | 1 |
| `ve_88dfc72e74` | Schlüssel | /oberwil/schlussel | active | true | 1 |
| `ve_2bd5d47d13` | rémy | /zurich/remy | active | true | 1 |
| `ve_d84ee8e403` | Birdy's by Achtien - The Nest | /brunnen/birdy-s-by-achtien-the-nest | active | true | 1 |
| `ve_6cedf32a8c` | Njørd café | /aubonne/nj-rd-cafe | active | true | 1 |
| `ve_5cfb05e1b5` | Löwen Messen - Die Land Brasserie | /messen/lowen-messen-die-land-brasserie | active | true | 1 |
| `ve_2a76b77e16` | Panorama - Bistro | /steffisburg/panorama-bistro | active | true | 1 |
| `ve_ce26d67bea` | Neri Cantina & Cucina | /zurich/neri-cantina-cucina | active | true | 1 |
| `ve_8dc0b0af40` | Capet - Neo-Bistro | /zurich/capet-neo-bistro | active | true | 1 |
| `ve_23d02b90c1` | Löwenstobe | /gonten/lowenstobe | active | true | 1 |
| `ve_99e8b1dff6` | Ya Mama by Moses Ceylan | /celerina/ya-mama-by-moses-ceylan | active | true | 1 |
| `ve_2e35fec011` | Klostergasthaus Löwen - Gaststube | /pfaffnau/klostergasthaus-lowen-gaststube | active | true | 1 |
| `ve_14834ad233` | Culinarium Alpinum | /stans/culinarium-alpinum | active | true | 1 |
| `ve_ca3735774b` | Gasthaus Traube - Die Braustube | /buchs/gasthaus-traube-die-braustube | active | true | 1 |
| `ve_529d0a2c9c` | Ristorante della Stazione da YanElo | /intragna/ristorante-della-stazione-da-yanelo | active | true | 1 |
| `ve_01a6ce04fe` | Soï 28 by Stefan Heilemann | /zurich/soi-28-by-stefan-heilemann | active | true | 1 |
| `ve_781166e4b0` | Bären | /schwarzenburg/baren | active | true | 1 |
| `ve_08fb4a4859` | Wiesner Mysterion – Werkstatt Kost | /romoos/wiesner-mysterion-werkstatt-kost | active | true | 1 |
| `ve_4766480819` | Château Attisholz - Brasserie la Source | /riedholz/chateau-attisholz-brasserie-la-source | active | true | 1 |
| `ve_147506ea77` | Bären | /utzenstorf/baren | active | true | 1 |
| `ve_9abb181f7c` | Dorfhus Gupf | /rehetobel/dorfhus-gupf | active | true | 1 |
| `ve_858eea062b` | Alpenblick - Bistro | /adelboden/alpenblick-bistro | active | true | 1 |
| `ve_b9da8d6de9` | Restaurant Schlüssel - Schlüsselstube | /mels/restaurant-schlussel-schlusselstube | active | true | 1 |
| `ve_bcb98826f3` | Sonne | /ebersecken/sonne | active | true | 1 |

## Exposure ledger

One row per publisher and field type, job `ingest-promote:michelin-2026-switzerland`.

| publisher | field type | items |
|---|---|---|
| michelin | award | 225 |
| michelin | city_label | 60 |

## Undo

Reversible with one button: **Ingest - undo**, with the confirmation
`UNDO michelin-2026-switzerland`. Dry-run it first - that box starts ticked.

This batch is keyed everywhere it wrote: `city_label_source.note` and
`source_capture_ledger.job` both carry `michelin-2026-switzerland`, and `audit_log` holds
every row this transaction wrote under one timestamp. The undo reads all three and
refuses unless they agree. See docs/ingest-job.md, "Button three".
