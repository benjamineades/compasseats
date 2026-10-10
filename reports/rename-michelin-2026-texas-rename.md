# Rename apply - rename-michelin-2026-texas

Committed 2026-10-10T14:35:05.671Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-texas` |
| CSV | `fixtures/rename/michelin-2026-texas-names.csv` |
| rows in the file | 18 |
| renamed | 18 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Texas 2026 card names, Sep 14 rule; Ben Oct 10: Q-A, Q-B, Q-C all A |

## Verdicts

Population: all 18 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 18 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 18 row(s) this batch would rename, read from the database before a single name changed.

18 of the 18 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_2d80e6f1be` | houston | Le Jardinier | Le Jardinier Houston | michelin 2, oad 2 | no | /houston/le-jardinier |
| `ve_643b43e09f` | fort-worth | Goldee's Barbecue | Goldee’s Bar-B•Q | michelin 2 | no | /fort-worth/goldee-s-barbecue |
| `ve_0ef83029cf` | austin | Interstellar BBQ | InterStellar BBQ | michelin 2 | no | /austin/interstellar-bbq |
| `ve_f61163430a` | san-antonio | Nicosi | Nicōsi | michelin 2 | no | /san-antonio/nicosi |
| `ve_cca4f35717` | spring | Rosemeyer Bar-B-Q (Food Truck) | Rosemeyer Bar-B-Q | michelin 2 | no | /spring/rosemeyer-bar-b-q-food-truck |
| `ve_87f46d270a` | houston | CasaEma | Casaema | michelin 2 | no | /houston/casaema |
| `ve_abdb64f6ae` | houston | da Gama canteen | da Gama Canteen | michelin 2 | no | /houston/da-gama-canteen |
| `ve_d9e28a8c8e` | pearland | Killen's Barbecue | Killen's BBQ | michelin 2 | no | /pearland/killen-s-barbecue |
| `ve_ad96e779fa` | houston | Annam Vietnamese Restaurant | Annam | michelin 2 | no | /houston/annam-vietnamese-restaurant |
| `ve_3c2ad8d111` | houston | Nobie's | nobie's | michelin 2 | no | /houston/nobie-s |
| `ve_cac24c5056` | bellaire | Blood Bros. BBQ | Blood Bros BBQ | michelin 2 | no | /bellaire/blood-bros-bbq |
| `ve_3ceab91f49` | dallas | Mot Hai Ba | Một Hai Ba | michelin 2 | no | /dallas/mot-hai-ba |
| `ve_45bf3594ba` | dallas | Nonna \| Tabu | nonna | michelin 2 | no | /dallas/nonna-tabu |
| `ve_940cdef65f` | austin | Micklethwait Barbecue | Micklethwait Craft Meats | michelin 2 | no | /austin/micklethwait-barbecue |
| `ve_3fbb33695d` | austin | Veracruz Fonda and Bar | Veracruz Fonda & Bar | michelin 2 | no | /austin/veracruz-fonda-and-bar |
| `ve_4c0b829f4f` | austin | Kemuri Tatsu-Ya | Kemuri Tatsu-ya | michelin 2 | no | /austin/kemuri-tatsu-ya |
| `ve_07202716ee` | seguin | Burnt Bean Company | Burnt Bean Co. | michelin 2 | no | /seguin/burnt-bean-company |
| `ve_8dbf8709c5` | san-antonio | Cullum’s Attaboy | Cullum's Attaboy | michelin 2 | no | /san-antonio/cullum-s-attaboy |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 18 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,232 | 11,232 | 11,232 |
| awards | 22,462 | 22,462 | 22,462 |
| slugs | 12,566 | 12,566 | 12,566 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 76 | 77 | 77 |
| rename_batches | 8 | 9 | 9 |
| rename_rows | 825 | 843 | 843 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 18 (expected 18) |
| every renamed venue's live name is its new_name | pass | 0 of 18 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 18 (expected 18) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 18 name changes (expected 18), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 18 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_2d80e6f1be` | Le Jardinier | Le Jardinier Houston | michelin | https://guide.michelin.com/us/en/texas/houston_2986624/restaurant/le-jardinier-houston |
| `ve_643b43e09f` | Goldee's Barbecue | Goldee’s Bar-B•Q | michelin | https://guide.michelin.com/us/en/texas/fort-worth_2954653/restaurant/goldee-s |
| `ve_0ef83029cf` | Interstellar BBQ | InterStellar BBQ | michelin | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/interstellar-bbq |
| `ve_f61163430a` | Nicosi | Nicōsi | michelin | https://guide.michelin.com/us/en/texas/san-antonio_2958156/restaurant/nicosi |
| `ve_cca4f35717` | Rosemeyer Bar-B-Q (Food Truck) | Rosemeyer Bar-B-Q | michelin | https://guide.michelin.com/us/en/texas/spring_2986734/restaurant/rosemeyer-bar-b-q |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-texas`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 18 |

Spellings followed: michelin (18).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-michelin-2026-texas`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-michelin-2026-texas`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
