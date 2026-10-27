# Rename apply - rename-michelin-2026-taiwan-drops

**DRY RUN - rolled back.** Everything below is what would have happened.
Every name in the database is exactly as it was.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-taiwan-drops` |
| CSV | `fixtures/rename/michelin-2026-taiwan-drops-names.csv` |
| rows in the file | 3 |
| renamed | 3 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | (none) |

## Verdicts

Population: all 3 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 3 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 3 row(s) this batch would rename, read from the database before a single name changed.

3 of the 3 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_02b8c23984` | kaohsiung | 賣塩順台菜-正宗台菜 | Mai Yen Shun | michelin 1 | no | /kaohsiung/kaohsiung-wdri98 |
| `ve_96994a1e21` | kaohsiung | 白玉樓經典台菜(夢時代6F) | Pale Jade Pavilion | michelin 1 | no | /kaohsiung/kaohsiung-mmuvp8 |
| `ve_d851917163` | tainan | 筑馨居 | Zhu Xin Ju | michelin 1 | no | /tainan/tainan-nitl0s |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 3 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

**Nothing.** No other table in the database stores any of these names as text, so a rename leaves no stale copy behind.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,291 | 11,291 | 11,291 |
| awards | 22,841 | 22,841 | 22,841 |
| slugs | 12,813 | 12,813 | 12,813 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 90 | 91 | 91 |
| rename_batches | 12 | 13 | 13 |
| rename_rows | 1,099 | 1,102 | 1,102 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 3 (expected 3) |
| every renamed venue's live name is its new_name | pass | 0 of 3 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 3 (expected 3) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 3 name changes (expected 3), 0 other venue updates (expected 0) |

## Sample

The first 3 of the 3 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_02b8c23984` | 賣塩順台菜-正宗台菜 | Mai Yen Shun | michelin | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/mai-yen-shun |
| `ve_96994a1e21` | 白玉樓經典台菜(夢時代6F) | Pale Jade Pavilion | michelin | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/pale-jade-pavilion |
| `ve_d851917163` | 筑馨居 | Zhu Xin Ju | michelin | https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/zhu-xin-ju |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-taiwan-drops`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 3 |

Spellings followed: michelin (3).

## Undo

Nothing to undo: this was a dry run. Untick the box to do it for real.
