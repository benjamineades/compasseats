# Handoff: CompassEats, Sep 28, 2026. Plan v1.29 saved. Next: Chengdu rename CSV.

This file replaces `handoff-michelin-gb-ie-cleanup-done-2026-09-28.md` for live state, decisions and open items. The source-reading methods, dead ends, database notes, key ids and working preferences in `handoff-michelin-chengdu-2027-done-2026-09-28.md` still apply and are not repeated here. The methods and dead ends that the Chengdu file does not hold are in this file. Attach this file and the Chengdu file to the next chat.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".

Open item 1 of the GB&I cleanup handoff (Plan v1.29) is closed.

## Live state
Population: whole table. Read Sep 28 at the start and again before the plan build. No database table changed in this session.

| Table | Count |
|---|---|
| venues | 11,212 (active 10,846, closed 366) |
| awards | 22,241 |
| Michelin 2025 / 2026 / 2027 rows | 3,796 / 4,651 / 47 |
| listings / slugs | 11,212 / 12,293 (canonical 11,212, non-canonical 1,081) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_label_source | 3,244 / 23,828 |
| price | 7,057 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | 59 (last id **76**) |
| audit_log | 103,752 (last id **107,105**) |
| ingest_batches | ids 1 and 3–11 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8 applied. rename_rows 533 |
| GB/IE legacy Michelin rows (no `source_url`) | 9 (8 closed venues and Dill) |

## Done in this session
- **Start check:** all counts, ledger id 76 and audit id 107,105 matched the GB&I cleanup handoff. Ledger 75 = `retire:retire-michelin-legacy-gb-ie` (380). Ledger 76 = `cleanup:cleanup-michelin-gb-bristol-contamination` (2).
- **Plan v1.29 built and saved.** Base: v1.28, sha256 `b7ddeab7…28e88` (read in a fresh clone). Build script: 6 anchored edits, each matched once. HTML check: 0 new errors (the 2 parser notes on line 7, the font link, are also in v1.28). Diff: 6 lines changed, 77 lines added.
- **Read-back after Ben's save:** repo commit `5931467` (Sep 28 16:09 -0400) and the project copy both have sha256 `73e43c4d3d0091129f3bf387f6e44dae28d1969b3a818ffbb6a0e8a95e016de0` and Version 1.29. The repo holds 1 plan file.

**v1.29 adds:**
- A card "Michelin 2026 — Great Britain & Ireland promoted, retired and cleaned · standing rules · order restated" after the Chengdu card. It holds the ceremony and rule 2.1.1 path, the capture (386 rows; the difference of 12 from the ceremony total of 398), batch 11 (ledger 73–74), the 5 cleanup batches (ledger 75–76, audit 106,701–107,105), the status evidence, Kilberry Inn and Dill, the result, 4 new standing rules, a gap-list table, a new order of work, a GB&I cleanup list and live counts.
- Header: Version 1.29, author "v1.25–1.29 by Claude Opus 5.5", Status "Great Britain & Ireland promoted and closed · Germany next after the Chengdu items".
- Price work item population: 3,739 venues (v1.28 read 3,353 before the GB&I promote). 3,336 hold a legacy price, 10 a card price, 393 no price, 0 more than one. GB `£`, IE `€`; legacy GB/IE prices are `$`.
- Phase 4 note: GB&I removed from the October ingest list; "then Germany" added; dates kept under review.
- Version history row 1.29.

## Decisions by Ben, Sep 28 (this session)
- **Q1: Germany is #8 in the gap list,** item 3 in the order, after the two Chengdu items. Reason: the largest gap with 0 sourced rows.
- **Q2: the four Sep 28 GB&I decisions are standing rules** for every guide. They are a new table in the GB&I card. The Chengdu card's table stays unchanged as history.
  - Temporary closure: a venue that is temporarily closed with no reopening date stays closed, even with a current card.
  - Conflicting evidence: the status does not change; the venue goes on the recheck list.
  - Michelin-closed venue: status `closed`; the legacy row stays as history (2025 history rule); nothing is deleted; a new business on the same site is not the award holder.
  - Contamination, no pairing: delete the venue with its rows (method of ledger 52); the old URL gives a 404, no redirect.
- **Q3: Phase 4 and 5 dates stay "under review".**

## Gap list after GB&I (recorded in v1.29)
Population: Michelin award rows by the country of the venue's city, whole table, read Sep 28. First 8 countries with legacy rows (no `source_url`).

| Country | Legacy rows | Sourced rows |
|---|---|---|
| US | 1,003 | 46 |
| Germany | 806 (468 labelled 2025, 338 labelled 2026) | 0 |
| Belgium | 234 | 0 |
| Switzerland | 226 | 0 |
| Netherlands | 185 | 0 |
| Thailand | 178 | 0 |
| Taiwan | 175 | 0 |
| Austria | 158 | 0 |

US: Texas, American South and Northeast Cities are in the order. California and Florida hold 274 older 2026 rows with no URL (plan v1.25). They are not in the order.

## Methods that worked (not in the Chengdu file)
- **Plan edit:** fresh `git clone --depth 1`, read the `Version` line and sha256, then a Python script with anchored `replace` calls that stop when an anchor count is not 1. Check with `html5lib` (compare the error count with the base) and a tag-balance parser. Diff against the base.
- **New plan card, not an edit of an old card:** new standing rules and a new order list go in the new card ("replaces the list in the <previous> card"). Old cards stay as history.
- **Read-only check of a gated file:** run the same `DO` block through the Read connector. It fails at the first write with "read-only transaction", which proves every PRE gate passed.
- **Status-only change gate:** `(SELECT count(*) FROM jsonb_object_keys(new_row) k WHERE old_row->k IS DISTINCT FROM new_row->k) = 1`.
- **Id-list guard:** md5 of the id list (ids joined with `,` in id order), checked inside the `DO` block.
- **Michelin venue page in Chrome:** navigate to the card URL, read `document.title`. "Restaurant not found" = page removed.

## Dead ends: do not retry (not in the Chengdu file)
- Trusting a handoff's plan version. Always read the `Version` line first (v1.24 and v1.27 were lost this way).
- Bash process substitution `<( )` in the sandbox ("Syntax error"). Write to temp files.
- `price.id` (no such column; key by `venue_id`). `audit_log.created_at` (the column is `at`). `cities.name` (the column is `display`).
- `coalesce(city_label_source.from_column, '')`: enum `label_column_t`. Cast to text first.
- `web_fetch` of a guide.michelin.com venue page (refused or 404). Use Chrome.
- A "temporarily closed" status: `venues.status` has only `active` and `closed`.
- Pasting a CSV name into SQL by hand (a combining accent changes). Put an md5 of the pasted values in the query.
- `split('|')` on a pairs list ("Canteen | Notting Hill"). Use `split('|', 2)`.
- Expecting `max(id)` to show ids that a rolled-back dry run used.

## Artifacts
- `docs/CompassEats-Rearchitecture-Plan.html` **v1.29**: final, in the repo (commit `5931467`) and the project. sha256 `73e43c4d3d0091129f3bf387f6e44dae28d1969b3a818ffbb6a0e8a95e016de0`.
- `build129.py`: sandbox only, not in the repo. The file checksum is the record.
- GB&I SQL files, fixture, decisions file and reports: as listed in the GB&I cleanup handoff.

## Open items, in order (Plan v1.29, "Order of the remaining work")
1. **Chengdu rename CSV (next).** The 18 paired legacy venues (list in the Chengdu handoff, "Decisions file"). Majority rule (Sep 14): read La Liste, OAD, 50 Best and Best Chef rows on each venue before each row. `ve_41a4101cbd` → "Co-" (3 of 3 publishers). Names come from `fixtures/ingest/michelin-2027-chengdu.csv`, never retyped. Method: `docs/rename-job.md`. Build the CSV, examine it read-only, present it, one "go"; Ben runs the rename job. Then the slug SQL file (template `docs/slugs-rename-michelin-2026-china.sql`), examine read-only, a second "go". Every slug write keeps 1 canonical row per venue.
2. Chengdu retire and merge review: Upper House Chengdu and 8 legacy Bib venues with no 2027 card.
3. Germany, #8 (806 legacy / 0 sourced): ceremony date from a guide.michelin.com URL, 2027 edition check (rule 2.1.7), label check on the 338 rows labelled 2026, then promote and cleanup under amended rule 2.1.1.
4. France slug set (148 venues). Ben decides when.
5. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
6. Price from the Michelin card (3,739 venues). Ben chooses the method.
7. Later-ceremony guides, promote only: Texas after Oct 8, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
8. Carried: rename CSVs for Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest and GB&I (143 paired venues; Glovers Alley by Andy McFadden → by Adam Nevin); special-awards batch (GB&I adds 37 Green Stars, 5 special awards); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs.
9. Rechecks, no date: Dill (status), Kilberry Inn (reopening date), Endo at the Rotunda (reopening), Hare & Hounds (reopening after the fire).
10. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows` (no RLS before access policies exist).

## Suggested opening prompt
```
Read the attached handoffs (handoff-plan-v129-done-2026-09-28.md, then handoff-michelin-chengdu-2027-done-2026-09-28.md for methods, dead ends and database notes). Confirm live counts, ledger id 76 and audit_log id 107,105 with a Read query, and read the Version line of docs/CompassEats-Rearchitecture-Plan.html (expect 1.29). Then start open item 1, the Chengdu rename CSV: for each of the 18 paired venues, read the other publishers' rows, apply the majority rule, and tell me in /ste style which names change. Ask me about any row the rule does not decide. Then build the rename CSV from the fixture file, examine it read-only, and wait for my go.
```
