# Handoff: CompassEats, Sep 28, 2026. Michelin Great Britain & Ireland 2026 promoted. Next: retire batch.

This file replaces `handoff-plan-v128-done-2026-09-28.md` for live state, decisions and open items. The source-reading methods, dead ends, database notes, key ids and working preferences in `handoff-michelin-chengdu-2027-done-2026-09-28.md` still apply and are not repeated here. Attach this file and the Chengdu file to the next chat.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".

Open item 1 of the Plan v1.28 handoff (Michelin Great Britain & Ireland) is promoted. Its cleanup is open (items 1–3 below).

## Live state
Population: whole table. Read Sep 28 after the promote (the last write of the session).

| Table | Count |
|---|---|
| venues | **11,214** (active **10,853**) |
| awards | **22,623** |
| Michelin 2025 / 2026 / 2027 rows | 4,178 / **4,651** / 47 |
| listings / slugs | **11,214** / **12,295** (canonical 11,214, non-canonical 1,081) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_label_source | 3,244 / **23,832** |
| price | 7,059 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **57** (last id **74**) |
| audit_log | **103,347** (last id **106,700**) |
| ingest_batches | ids 1 and 3–**11** promoted (no id 2) |
| rename_batches | 2, 4, 6, 8 applied. rename_rows 533 |

## Done in this session

**Plan check.** `docs/CompassEats-Rearchitecture-Plan.html` Version line = 1.28, sha256 `b7ddeab7…28e88`. Live counts, ledger id 70 and audit id 105,898 matched the v1.28 handoff.

**Ceremony facts (guide.michelin.com).**
- Great Britain & Ireland 2026 ceremony: Monday, **Feb 9, 2026**, Convention Centre Dublin. Bibs announced Feb 2, 2026. URL: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-stars-news-uk-ireland-2026
- "At a glance": 10 / 28 (2 new) / 192 (20 new) / 168 Bib (37 new), 37 Green Stars (7 new). Ireland (count of the star list): 0 / 5 / 18. No 2027 edition and no 2027 date published.
- Rule 2.1.1: ceremony before May 13, 2026, so the legacy rows hold the 2026 edition. Evidence: the legacy "2025" rows held the 2026 promotions (Bonheur and Row on 5 Two Stars; Forest Avenue, The Pullman, Legado, Kerfield Arms, 1887, FIFTY TWO, Vraic One Star; Sebb's and Shwen Shwen Bib). Path: **retire same-category twins after the promote**.

**Capture (Opus in Cowork, brief `cowork-michelin-2026-great-britain-ireland.md`).**
- 386 rows: UK 10 / 23 / 165 / 146 = 344, Ireland 0 / 5 / 18 / 19 = 42. Each count = site banner = Distinction filter.
- Country slugs: `selection/united-kingdom` (`data-restaurant-country="gb"`), `selection/republic-of-ireland` (`"ie"`).
- Meta description phrases: "2026 MICHELIN Guide United Kingdom" and "2026 MICHELIN Guide Republic of Ireland".
- Currency: UK `£` (344 rows, Channel Islands included), Ireland `€` (42 rows). Symbols identical on `/us/en/`, `/gb/en/`, `/ie/en/` pages. JSON-LD `priceRange` is words (Spare no expense / Special occasion / A moderate spend).
- In-page `fetch()` failed the proof test on GB (different card set, raw distinction values). Cowork read the rendered DOM (14 page loads).
- "mýse" (line 97) uses a combining accent (U+0301). `norm_key` gives `myse` for both forms. It paired to an existing venue, so the form never entered the database.
- Channel Islands cards (Vraic, Bohemia, Alba) have `data-restaurant-country="gb"` and `country_label` United Kingdom.

**Ingest, batch 11, key `michelin-2026-great-britain-ireland`.**
- Pre-stage simulation (Read connector, the job's city and key rules) predicted run 1 exactly: 238 match, 136 new, 10 review_venue, 2 review_city.
- Decisions file: 148 rows (141 `use:`, 2 `city:ci_ba52f6a841;use:`, 5 `new`). Read-only check: 143 of 143 pairs have the named venue, in the resolved city, with a legacy row in the card's category. No venue used twice.
- Run 2: 381 match, 5 new, 0 review. 1 match holds no legacy row: Restaurant Gordon Ramsay High `ve_f8ef3790c5` (exact name, correct).
- Dry run: 11 of 11 invariants pass. Rolled back. It used ledger 71–72 and audit 105,899–106,299.
- **Real promote: Sep 28 18:31 UTC.** Ledger **73** (michelin, award, 386) and **74** (michelin, city_label, 10), job `ingest-promote:michelin-2026-great-britain-ireland`. Audit **106,300–106,700** (401 rows: awards 386, venues 5, listings 5, slugs 5, all INSERT).
- Row check: 386 of 386 awards with a distinct batch URL, source michelin, year 2026, category = staged row, country = card country. 381 of 381 match rows on the staged venue. 0 venues with two Michelin 2026 rows in one category.
- New venues: Corenucopia by Clare Smyth `ve_ce39832bd0`, Pétrus by Gordon Ramsay `ve_61599d9f2f`, 1890 by Gordon Ramsay `ve_fc7016664d`, COR `ve_1ade09cf15`, OTHER `ve_bd55d03429` (Bristol).

## Decisions by Ben, Sep 28
- **Set 1 (Bristol): `new` for COR and OTHER.** The legacy Bib venues "City of Bristol College" `ve_697cd0fcda` and "Bristol" `ve_9065495593` have place names, and no evidence links a card to either. Their rows go to cleanup.
- Claude's pairings (promoted by Ben), notable cases:
  - Line 63 Allium at Askham Hall → "Askham Hall" `ve_5c2f3e1400` (medium, hotel name).
  - Line 302 Upstairs (at Trinity) → "Upstairs" `ve_90e58bb06f` (medium).
  - Line 160 Pétrus by Gordon Ramsay = `new`. London "Pétrus" `ve_b3c0658fd5` holds only W50B 2003 No. 33 (the earlier Pétrus at The Berkeley).
  - Lines 345 dede and 370 Baba'de: city decision `ci_ba52f6a841` ("Baltimore, Ireland"). The label "Baltimore" alone resolves to Baltimore, US `ci_ddb54f32ec`.
  - Price differences noted in the decisions file: lines 96, 123, 313, 371 (card price wins later).

## Cleanup scope after the promote
Population: the 391 legacy Michelin rows (no `source_url`) on venues in GB and IE cities.
- **380 same-category twins** of a sourced 2026 row → retire batch.
- **0** category mismatches.
- **11 orphans** (no sourced Michelin row on the venue):
  - Michelin marks these closed: Endo at the Rotunda `ve_b9d291ce2a`, SOLA `ve_653d7fb4a4`, Simpsons `ve_7cdb1751a2`, Sorrel `ve_f98f790eff`, The Masons Arms `ve_d5ec6cac85`, Mark Poynton at Caistor Hall `ve_3892089530`.
  - Left the Bib list: Hare & Hounds (Aberthin) `ve_6a9c9a2c61`, Dill (Lewes) `ve_b3825c7559`, Cantaloupe (Stockport) `ve_721db33f96`.
  - Contamination: City of Bristol College `ve_697cd0fcda`, Bristol `ve_9065495593`.
- **4 status fixes** (closed, but hold a 2026 card): Glovers Alley `ve_0df9219252`, The Reindeer at Hoveringham `ve_9253764795`, Plaza Khao Gaeng `ve_6bed3a903b`, The Kilberry Inn `ve_0fcfe3088e`.

## Findings for later (not decided)
- Rename candidates (majority rule applies): most of the 143 paired venues carry Google-style names ("Moor Hall Restaurant with Rooms", "64 Goodge Street, Greater", "MAURO COLAGRECO", "Canteen | Notting Hill").
- Special-awards batch gains: GB&I 2026 has 37 Green Stars and 5 special awards (list in the Cowork log).
- `reports/michelin-2026-great-britain-ireland-review.csv` still holds the 12 run-1 rows. The job does not rewrite it when run 2 has 0 review rows. The database holds 0 review rows.
- Legacy prices on these venues are `$` symbols. The card symbols (`£`, `€`) are in the fixture CSV for the price work item.

## Dead ends: do not retry
- Pasting a CSV name into SQL by hand loses a combining accent (NFC change). Put an md5 of the pasted values in the query and compare it with the file.
- `cities.name` (the column is `display`).
- `split('|')` on the pairs list: "Canteen | Notting Hill" has a pipe. Use `split('|', 2)`.
- Expecting `max(id)` to show ids that a rolled-back dry run used.
- Carried: see the Chengdu handoff.

## Artifacts
- `fixtures/ingest/michelin-2026-great-britain-ireland.csv`: in the repo, final. 386 rows, 15 columns, LF, sha256 `6251b45cfd845edd40eb44a621a686c224123d2261b6989a2544970c54de9a3a`.
- `fixtures/ingest/michelin-2026-great-britain-ireland-decisions.csv`: in the repo, final. 148 rows, quoted, CRLF, sha256 `754405406254f1d3d843b7d5ceaddc83125784372a09f305a523a2ff5d487ec5`.
- `reports/michelin-2026-great-britain-ireland-stage.md`, `-promote.md`: in the repo, written by the jobs.
- `michelin-2026-great-britain-ireland-log.md` (Cowork log, with the Green Star and special-award register): chat upload only, not in the repo.
- `cowork-michelin-2026-great-britain-ireland.md` (brief): chat output only, not in the repo.

## Open items, in order
1. **Retire batch `retire-michelin-legacy-gb-ie` (next).** 380 same-category legacy twins, one gated SQL transaction (`DO` block, delete by award id, `ROW_COUNT` check, exception on a wrong count, one ledger row `retire:<key>`). Scope by the GB and IE city ids. Build the file, check it read-only, present it, then one "go".
2. **Status fixes:** the 4 closed venues with a 2026 card, closed → active (same as `bosq-active`: the trigger writes the audit row, no ledger row).
3. **Orphan review:** the 11 legacy rows, one set at a time (closed per Michelin, left the Bib list, Bristol contamination). Apply the free-venue rule with the full venue pre-check.
4. **Plan v1.29:** add a GB&I card (ceremony, capture, batch 11, ledger 73–74, retire, cleanup). Read the `Version` line first (expect 1.28).
5. Then the order from Plan v1.28:
   - Chengdu rename CSV and slug job.
   - Chengdu retire and merge review.
   - France slug set.
   - `name_native` backfill.
   - Price from the Michelin card (Ben chooses the method).
   - Later-ceremony guides: Texas after Oct 8, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
   - Carried items and the Phase 4 and 5 decisions.

## Key ids
Baltimore, Ireland `ci_ba52f6a841` · Baltimore, US `ci_ddb54f32ec` · London `ci_bc180dbc58` · Dublin `ci_71fab71dc7` · Edinburgh `ci_01cdc81c1e` · Glasgow `ci_1c6a6f9423` · City of Bristol `ci_eb6682499e` · Belfast `ci_f1985a8c51`.

## Suggested opening prompt
```
Read the attached handoffs (handoff-michelin-gb-ie-promoted-2026-09-28.md, then handoff-michelin-chengdu-2027-done-2026-09-28.md for methods, dead ends and database notes). Confirm live counts, ledger id 74 and audit_log id 106,700 with a Read query. Then start open item 1: build the gated SQL file for retire-michelin-legacy-gb-ie (380 same-category legacy twins in GB and IE), check it read-only, present it as the record in /ste style, and wait for my go.
```
