# Rename apply - rename-michelin-2026-american-south

**DRY RUN - rolled back.** Everything below is what would have happened.
Every name in the database is exactly as it was.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-american-south` |
| CSV | `fixtures/rename/michelin-2026-american-south-names.csv` |
| rows in the file | 12 |
| renamed | 12 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | (none) |

## Verdicts

Population: all 12 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 12 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 12 row(s) this batch would rename, read from the database before a single name changed.

12 of the 12 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_2b78d5a995` | charleston | Malagón | Malagón Mercado y Taperia | michelin 2 | no | /charleston/malagon |
| `ve_9f5cf63b71` | atlanta | Bomb Biscuit Atlanta | Bomb Biscuit Co. | michelin 4 | no | /atlanta/bomb-biscuit-atlanta |
| `ve_2b170a2ed7` | new-orleans | Cochon Restaurant | Cochon | michelin 2 | no | /new-orleans/cochon-restaurant |
| `ve_c578547312` | new-orleans | Domilise's Po-Boy & Bar | Domilise’s Po-Boy & Bar | michelin 2 | no | /new-orleans/domilise-s-po-boy-bar |
| `ve_85577c3e90` | new-orleans | Dooky Chase Restaurant | Dooky Chase | michelin 2, james-beard 1 | no | /new-orleans/dooky-chase-restaurant |
| `ve_04509480d4` | new-orleans | LUFU NOLA | Lufu Nola | michelin 2 | no | /new-orleans/lufu-nola |
| `ve_051574d412` | asheville | mother bakery & cafe \| south slope | Mother | michelin 2 | no | /asheville/mother-bakery-cafe-south-slope |
| `ve_ec88e3b3fd` | raleigh | Mala Pata Molino + Cocina | Mala Pata | michelin 2 | no | /raleigh/mala-pata-molino-cocina |
| `ve_a4b6c65ad1` | charleston | Leon's | Leon's Oyster Shop | michelin 2 | no | /charleston/leon-s |
| `ve_e00ab3eeee` | nashville | SS Gai | S.S. Gai | michelin 2 | no | /nashville/ss-gai |
| `ve_c931bd1f24` | nashville | St.Vito Focacceria | St. Vito Focacceria | michelin 2 | no | /nashville/st-vito-focacceria |
| `ve_2925ba1328` | nashville | Uzbegim Halal Restaurant | Uzbegim | michelin 2 | no | /nashville/uzbegim-halal-restaurant |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 12 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,307 | 11,307 | 11,307 |
| awards | 22,922 | 22,922 | 22,922 |
| slugs | 12,832 | 12,832 | 12,832 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 93 | 94 | 94 |
| rename_batches | 13 | 14 | 14 |
| rename_rows | 1,102 | 1,114 | 1,114 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 12 (expected 12) |
| every renamed venue's live name is its new_name | pass | 0 of 12 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 12 (expected 12) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 12 name changes (expected 12), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 12 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_2b78d5a995` | Malagón | Malagón Mercado y Taperia | michelin | https://guide.michelin.com/us/en/south-carolina/charleston_2952029/restaurant/malagon-mercado-y-taperia |
| `ve_9f5cf63b71` | Bomb Biscuit Atlanta | Bomb Biscuit Co. | michelin | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/bomb-biscuit-co |
| `ve_2b170a2ed7` | Cochon Restaurant | Cochon | michelin | https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/cochon |
| `ve_c578547312` | Domilise's Po-Boy & Bar | Domilise’s Po-Boy & Bar | michelin | https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/domilise-s-po-boy-bar |
| `ve_85577c3e90` | Dooky Chase Restaurant | Dooky Chase | michelin | https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/dooky-chase |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-american-south`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 12 |

Spellings followed: michelin (12).

## Undo

Nothing to undo: this was a dry run. Untick the box to do it for real.
