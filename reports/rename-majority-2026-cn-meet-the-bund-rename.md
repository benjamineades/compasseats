# Rename apply - rename-majority-2026-cn-meet-the-bund

Committed 2026-09-28T14:09:56.860Z. One transaction, all of it or none of it.

| field | value |
|---|---|
| batch key | `rename-majority-2026-cn-meet-the-bund` |
| CSV | `fixtures/rename/majority-2026-cn-meet-the-bund.csv` |
| rows in the file | 1 |
| renamed | 1 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Sep 14 majority rule, 4 of 5 publishers |

## Verdicts

Population: all 1 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 1 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 1 row(s) this batch would rename, read from the database before a single name changed.

1 of the 1 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_78e5d38e3e` | shanghai | Meet the Bund (Zhongshan Dong Er Road) | Meet the Bund | asia-50-best-restaurants 4, best-chef-awards 2, la-liste 1, michelin 1, oad 1 | no | /shanghai/m-on-the-bund |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 1 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

| table.column | rows holding one of these names |
|---|---|
| `rename_rows.new_name` | 1 |

Those are copies this job does **not** rewrite. It changes `venues.name` and nothing else; anything above is for your list.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,185 | 11,185 | 11,185 |
| awards | 22,190 | 22,190 | 22,190 |
| slugs | 12,003 | 12,003 | 12,003 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 52 | 53 | 53 |
| rename_batches | 3 | 4 | 4 |
| rename_rows | 532 | 533 | 533 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 1 (expected 1) |
| every renamed venue's live name is its new_name | pass | 0 of 1 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 1 (expected 1) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 1 name changes (expected 1), 0 other venue updates (expected 0) |

## Sample

The first 1 of the 1 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_78e5d38e3e` | Meet the Bund (Zhongshan Dong Er Road) | Meet the Bund | la-liste | https://www.laliste.com/places/meet-the-bund-shanghai-cn |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-majority-2026-cn-meet-the-bund`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| la-liste | name | 1 |

Spellings followed: la-liste (1).

## Undo

Reversible with one button: **Rename - undo**, with the confirmation
`UNDO-RENAME rename-majority-2026-cn-meet-the-bund`. Dry-run it first - that box starts ticked.

The undo puts every name in this batch back to its `expected_name` and removes the ledger rows tagged `rename-apply:rename-majority-2026-cn-meet-the-bund`. It refuses, rather than adapts, if a venue has been renamed again since. It runs once.
