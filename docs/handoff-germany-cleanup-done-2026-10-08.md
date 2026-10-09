# Handoff: CompassEats, Oct 8, 2026 (night). Germany cleanup done (ledger 91–92). Next: the Germany rename CSV.

This file replaces `claude/handoff-germany-option-a-done-2026-10-08.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-germany-staged-run1-2026-10-08.md`: Germany source facts (ceremony URLs, capture counts, status register, legacy-row profile).
- `claude/handoff-germany-promoted-2026-10-08.md`: the promote record (1a city fix, decisions file, Wirsberg, new venue ids, the 13 medium pairings).
- `claude/handoff-germany-option-a-done-2026-10-08.md`: the option-A record (ledger 90, audit 107,715–108,050, price differences).
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- `claude/handoff-chengdu-renamed-reviewed-2026-09-28.md`: the Sep 28 ruling and Ben's decisions.
- `handoff-plan-v129-done-2026-09-28.md` and `handoff-michelin-chengdu-2027-done-2026-09-28.md`: methods, dead ends, database notes.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor (click steps below). Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.

## Live state
Population: whole table. Read Oct 9, 00:54 UTC (Oct 8, 20:54 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | **11,223** (active **10,859**, closed **364**) |
| awards | **22,389** |
| Michelin 2025 / 2026 / 2027 rows | **3,791** / **4,804** / 47 |
| listings / slugs | **11,223** / **12,322** (canonical **11,223**) |
| venues with more or less than 1 canonical slug | 0 |
| venues with two Michelin rows of the same year and category | 0 |
| venue-years with two Michelin categories | **18** (was 25; 0 in Germany, 0 on Carmel; the rest: CH 10, AT 2, SE 2, MO, NO, SG, VN) |
| cities / city_aliases / city_label_source | 3,251 / 258 / **23,850** |
| price | **7,048** (10 `guide_ingest`) |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **70** (last id **92**) |
| audit_log | **104,475** (last id **108,068**) |
| ingest_batches | 1, 3–13 promoted (no id 2). 13 = `michelin-2026-germany` |
| Germany Michelin 2026 rows (venue city `country_iso` DE) | **484, 0 unsourced**, 484 distinct URLs (483 venue cards on `guide.michelin.com/us/en`, 1 star list article for 7349) |
| Germany Michelin 2025 rows | **464**, all without `source_url` (history, rule 2.1.1) |

## Done in this session (Oct 8 night)

**Start check:** all counts, ledger 90, audit 108,050, Germany 2026 sourced 483 / unsourced 2 (3578, 7349) matched. Repo commit `c00c24e`: option-A file `5ee19094…b40026c0`, fixture `424ab62f…000bff`, decisions file `2e14fe2f…a419684` correct. Plan Version 1.29.

**Pre-check.** Population: 24 venues (all cleanup venues plus targets and keepers). All 10 `venue_id` foreign-key tables (from `pg_constraint`, all ON DELETE no action) plus `redirects`, `rename_rows`, `ingest_rows`. No blurbs, addresses, geo, hours or photo rows on any of them. No foreign key points to `awards` or `city_label_source`.

**Evidence read (built-in browser pane and web, Oct 8):**
- Michelin 2026 Germany star list article (`guide.michelin.com/de/de/article/michelin-guide-ceremony/alle-sternerestaurants---michelin-guide-deutschland-2026`): blocks of 60 (12 Three + 48 Two) and 279 (One). AURA in the Two Stars block. Gasthaus Jakob, Aubergine Starnberg, Gasthof Alex, Ente in the One Star block. The 7 "no 2025 row" venues are all listed with no "NEU" mark. 25 lines end in "NEU".
- Carmel card `guide.michelin.com/us/en/california/carmel-by-the-sea/restaurant/aubergine`: Two Stars, "2026 MICHELIN Guide USA", "Spare no expense" (= legacy `$$$$`).
- Gasthaus Jakob card: still "Restaurant not found".
- AURA card slug `alexander-herrmann-by-tobias-batz` = the restaurant of the legacy hotel-name venue.
- Gasthof Alex: own site (gasthofalex.de) lists regular hours, no closure notice; Falstaff page has hours.
- Ente: Falstaff (Mar 13, 2026): Ente at Kloster Eberbach from Mar 18, 2026 during the Nassauer Hof renovation ("vorübergehend", no end date); kloster-eberbach.de ENTE page lists hours.
- The 2025 star list article at the same slug with `2025` gives "Seite nicht gefunden".

**Batch 1, item e (`cleanup-michelin-de-status-active.sql`, 91 lines, sha256 `ee21e9b575a444c0133a6cfd47f41b03ed83ee201ea429df2aeb243e5653cf3b`).** Ben "go". Write connector, committed Oct 9 00:47:37 UTC.
- Gasthof Alex `ve_2c3da34a8d` and Pfortenhaus Kloster Eberbach (Ente) `ve_b7c3a95507`: `closed` → `active`. Both `closed` values came from the legacy import (audit 6713, 4532, Aug 14).
- Audit **108,051–108,052** (venues UPDATE, status-only gate). No ledger row (GB&I precedent, audit 107,081–107,083).

**Batch 2, items a, c, d (`cleanup-michelin-de-rows.sql`, 326 lines, sha256 `29018b7c664dc8097da4b8ec368e731cd882857aa545ab3c5465fc7364fe6297`).** Ben: question 1 option A, then "go". Write connector returned "cancelled" twice (read-back proved no change each time). Ben ran the file in the SQL Editor; committed Oct 9 00:52:57 UTC. All gates passed.
- Moved 2 (Michelin 2025, no URL): **3577** Two Stars Posthotel `ve_36e30ddd9f` → AURA `ve_410be56f8e`; **1697** One Star Carmel `ve_1ba19d6d0f` → Aubergine Starnberg `ve_660e52c8f5`.
- Deleted 7: 3578 (2026 Two Stars, twin of AURA card 27915), 1695 (2026 One Star, twin of Starnberg card 27916), second category rule 4189 ESSKULTUR, 4228 Hämmerles, 5242 Die Mühlenhelle, 5865 HochZwei, 8250 Hirsch Sonnenbühl (all 2025 Bib).
- Deleted the Posthotel venue: city labels 1335, 1336 (2 hand audit rows), price `$$$$` (not moved, Upper House precedent), slug `wirsberg/posthotel-alexander-herrmann`, listing, venue. Old URL 404, no redirect.
- Carmel keeps 1694 (2026) and 1696 (2025) Two Stars and its 11 other-publisher rows (13 rows).
- Guards: 9-id md5 `7de98a8c8ff496e4b4e9342b232e0053`; plan fingerprint `dd6b573fbd0de1daf9500a6cc5a6e67a` (md5 of `id|venue_id|source_id|year|category|source_url or ''`, by id, newline); deleted 7 md5 `69ee991d051036a7e6ead07c53ad25ae`; moves md5 `3403fa0d585041a4840bb845906fb747` (`'1697|ve_660e52c8f5,3577|ve_410be56f8e'`); Posthotel city labels md5 `7a374027737995509c3b6cbe99d19126`.
- Ledger **91** (michelin, award, 9, `cleanup:cleanup-michelin-de-rows | …`).
- Audit **108,053–108,067** (15): city_label_source DELETE 2 (hand), awards UPDATE 2 (venue_id-only gate), awards DELETE 7, price, slugs, listings, venues DELETE 1 each.

**Batch 3, item b (`source-url-michelin-2026-germany-jakob.sql`, 75 lines, sha256 `4fccd8fe47a525c8dac93a4adc760eb2c25a3f2b4ea036c6495f47240d3923b4`).** Ben: question 2 option A, then "go". Write connector, committed Oct 9 00:54:22 UTC.
- 7349 Gasthaus Jakob (2026 One Star) `source_url` = the star list article URL (list-page form of ruling condition 7). Status unchanged (`active`, conflicting evidence).
- Ledger **92** (michelin, award, 1, `source-url:michelin-2026-germany-jakob | …`). Audit **108,068** (awards UPDATE, source_url-only).

**Items with no write (rules decide):**
- f. Aqua `ve_0092621ee8`: closed, no 2026 card, keeps 2025 Three Stars and 12 other rows.
- g. Tantris `ve_287d52920c`, Ox&Klee `ve_840175e4a2`, Atelier `ve_d79face9ac`, Speisemeisterei `ve_c6cc29e19d`, August `ve_999fa337ae`, Lorenz Adlon Esszimmer `ve_c0e31003c5`, Nagaya `ve_ae36d47f80`: each holds 1 sourced 2026 card row and no 2025 row (none misfiled on another venue, all countries). On the 2026 star list with no "NEU", so each held a star in 2025. A gap stays a gap → history-backfill list.

## Decisions by Ben (this session)
- Q1 option A: rows 3577 and 1697 move to the venue Michelin's own pages name (AURA by card URL slug; Starnberg by the wrong-alias finding and the star list without "NEU"), instead of the written "2025 history" rule default (delete). Precedent for future cleanups: a direct Michelin page link to an existing venue can stand in for a decisions-file line.
- Q2 option A: 7349 takes the 2026 star list article URL (list page, condition 7 form).

## Lists for Plan v1.30
- Recheck: Gasthaus Jakob (card page removed, on the 2026 star list); Ente / Pfortenhaus (temporary move; return to Nassauer Hof, Wiesbaden, later).
- History backfill: the 7 venues of item g (2025 rows missing). The 2025 Germany star list article is not at the 2026 slug pattern.
- Remaining two-category venue-years (18, outside Germany): CH 10, AT 2, SE 2 (one 2026), MO, NO (2026), SG, VN (2026, Green Star + Service award, not a conflict). For their own guide cleanups.
- Carmel 1694 (2026 Two Stars) is still unsourced: California work (plan v1.25), not in the order.

## Methods that worked (new)
- **Star list article as evidence:** in the browser pane, split `document.body.innerText` into lines, keep runs of `City - Name` lines; run lengths give the category blocks (here 60 = Three + Two, 279 = One). "NEU" at the line end = new in this edition, so its absence proves a star in the previous edition.
- **Michelin card URL slug as identity evidence:** the slug keeps the old name after a rename (AURA = `alexander-herrmann-by-tobias-batz`).
- **Move + delete in one gated batch:** separate md5 guards for the full id list, the delete list and the move list (`'id|target'`); audit gate for moves = awards UPDATE with only `venue_id` changed; post-check that each target holds no twin and no second category.
- **Batch chain with fixed count gates:** batch N+1 gates on the exact counts and last ids after batch N. Its dry run before batch N stops at the first count gate, which still proves the guards and pre-checks; repeat the full dry run after batch N commits.
- **SQL Editor fallback:** Ben downloads the file, opens it in a plain text editor, pastes into Supabase → compass-canonical → SQL Editor → New query, clicks Run once, replies "done". Worked first time.

## Dead ends: do not retry (new)
- A `python3 -c` script that reads files inside the fresh repo clone: blocked by the auto-mode classifier ("Code from External"). Use the Grep and Read tools on the clone instead; keep own scripts in the scratchpad and run with `python3 -I`.
- 2025 star list article at `…/alle-sternerestaurants---michelin-guide-deutschland-2025` ("Seite nicht gefunden").
- More than one Write-connector retry after "cancelled" (2 calls, both cancelled again).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `cleanup-michelin-de-status-active.sql` | Run (Write connector). Chat file. **Ben to upload to `docs/`** (check at next start) | `ee21e9b5…53cf3b` |
| `cleanup-michelin-de-rows.sql` (326-line version) | Run (SQL Editor). Chat file. **Ben to upload to `docs/`** | `29018b7c…4fe6297` |
| `source-url-michelin-2026-germany-jakob.sql` | Run (Write connector). Chat file. **Ben to upload to `docs/`** | `4fccd8fe…d3923b4` |
| `docs/source-url-michelin-2026-germany-legacy.sql` | Run, in the repo (`8bec7b3`) | `5ee19094…b40026c0` |
| `fixtures/ingest/michelin-2026-germany.csv` / `-decisions.csv` | In the repo | `424ab62f…000bff` / `2e14fe2f…a419684` |

## Open items, in order
1. **Germany rename CSV (next)** (majority rule, Sep 14 ruling on suffixes) for the paired venues whose legacy name differs from the card: for example Cafe + Conditorei Philippin → Das Philippin, Huberwirt → Restaurant Alexander Huber, Residenz Heinz Winkler → Epicures, ONTRA → Ontra's Gourmetstube, Christian & Freunde, BjoernsOx, Münstermann Kontor, Gehrleins Restaurant Hardtwald, Hotel Dollenberg ·Kaminstube, Romantik Hotel Schmiedegasthaus Gehrke, Hotel Zur Post Meerfeld, Rüdigsdorfer Schweiz, Alte Schule Fürstenhagen; also Pfortenhaus Kloster Eberbach (card "Ente Wiesbaden - Pfortenhaus Kloster Eberbach": check the suffix rule), Hämmerles Restaurant (card slug `hammerle-s-restaurant-barrique`), HochZwei, Ammolite. Read other publishers' rows on each venue first. Names from the fixture, never retyped. Build, examine read-only, present, one "go"; then the slug SQL file, second "go".
2. **Plan v1.30** (content as item 2 of the Oct 4 handoff, plus Germany: ceremony, capture, 1a with the 5th alias, stage runs 1–2, the 13 medium pairings, Wirsberg, promote ledger 88–89 / audit 107,511–107,714, option A ledger 90 / audit 107,715–108,050, cleanup ledger 91–92 / audit 108,051–108,068, Ben's Q1/Q2 precedent, the lists above, the Write-connector fallback). Plan-edit method; read the Version line first (expect 1.29).
3. France slug set (148 venues). Ben decides when.
4. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
5. Price from the Michelin card (population to read again; Germany now 484 sourced `€` rows; known differences: Rebers Pflug 7906, BOK 6670, Kuultivo 5902 legacy `$$$` vs card `€€€€`; 30 option-A venues and AURA / Starnberg have no price row). Ben chooses the method.
6. Later-ceremony guides, promote only: **Texas (due now)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
7. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4: Service Karin Weißer, Young Chef Axel Boesen, Sommelier Noris F. Conrad, Opening of the Year THE CLOUD by Käfer); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
8. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, **Gasthaus Jakob, Ente**.
9. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`.
10. Project file cleanup, part 2: after the migration is done (list in the staged-run1 handoff, item 11).

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-germany-cleanup-done-2026-10-08.md first, then claude/handoff-germany-promoted-2026-10-08.md and claude/handoff-germany-staged-run1-2026-10-08.md for the Germany facts, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, the venue-delete method, methods and dead ends, then claude/handoff-chengdu-renamed-reviewed-2026-09-28.md, handoff-plan-v129-done-2026-09-28.md and handoff-michelin-chengdu-2027-done-2026-09-28.md. Confirm live counts, ledger id 92, audit_log id 108,068 and Germany 2026 sourced 484 / unsourced 0 with a Read query, and check that the three cleanup SQL files are in the repo docs/ folder with the sha256 values in the handoff (tell me if any is missing). Then start open item 1, the Germany rename CSV: for each paired venue whose legacy name differs from its 2026 card, read the other publishers' rows, apply the majority rule and the suffix ruling, and tell me in /ste style which names change. Ask me about any row the rules do not decide. Then build the rename CSV from the fixture file, examine it read-only, and wait for my go.
```
