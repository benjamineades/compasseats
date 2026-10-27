# Handoff: CompassEats, Oct 27, 2026 (16:50 Atlanta). Michelin American South 2026 staged and promoted (batch 18, ledger 135-136). 3 US cities and 2 aliases added (audit 112,652-112,656). Next: American South rename CSV, slugs, status items.

This file replaces `claude/handoff-american-south-brief-2026-10-27.md` for live state, decisions, open items, methods and dead ends. That file still applies for the American South facts, the legacy population (69 rows) and the list of older handoffs. The other files still apply as before:
- `claude/cowork-michelin-2026-american-south.md`: the brief.
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the capture-check, simulation, city insert, pairing, stage and promote record.
- `claude/handoff-texas-done-2026-10-10.md` and `claude/handoff-belgium-luxembourg-renamed-2026-10-10.md`: the rename-CSV method, the tie rule, the slug-file method (the model for the next step).
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, the gated venue-delete method.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9...672216`): rule 2.1.1 (amended Sep 24), rule 2.1.7.

Working rules (unchanged): plain `/ste` replies; populations on every count; one "go" per write batch; read-back after each commit; under-merge over over-merge; no competitor sources; no hand-retyped files; build, examine read-only, present, then ask; the tie rule (vote first; in a tie or doubt the venue's own spelling, Michelin fallback); nothing below a Michelin Bib is tracked; only closure evidence gives `closed`; Ben starting a stage, promote or real rename job is his "go".

## Live state
Population: whole table. Read Oct 27, 20:49 UTC (16:49 Atlanta), after the promote.

| Table | Count |
|---|---|
| venues | **11,307** (active **10,940**, closed 367) |
| awards | **22,922** |
| Michelin 2025 / 2026 / 2027 rows | 3,520 / **5,608** / 47 |
| listings / slugs | **11,307** / **12,832** |
| cities / city_aliases / city_label_source | **3,262** / **261** / **24,011** |
| price / blurbs / redirects | 7,024 / 142 / 9 |
| venues with `name_native` | 203 |
| source_capture_ledger | **93** (last id **136**) |
| audit_log | **107,642** (last id **112,914**) |
| ingest_batches | 1, 3-**18** promoted (no id 2). **18 = `michelin-2026-american-south`** |
| rename_rows | 1,102 |

## Done in this session (Oct 27, 13:11 to 16:49 Atlanta)

**1. Start check.** All counts, ledger 132, audit 112,651 matched the brief handoff.

**2. File checks.** `michelin-2026-american-south.csv` sha256 `109075a5fb349ba9d86dfef3beb41433f27937193b8aa5c4e56c6f25901b07f3` = log; 17,849 bytes; UTF-8, no BOM, LF, 82 lines, 16 fields. Log `docs/michelin-2026-american-south-log.md` sha256 `e186305a25d63818e0e67652e614eb6f69b6d4013743c2ae388a8f5765f7f823`. Full-data hash `a2e18576...81a0` and the Two Stars block hash recomputed from the CSV: match. 1 / 21 / 59 = 81 = brief; 7 state totals = log; 0 duplicate URLs; 0 non-NFC; every URL state slug = `state_label`. Repo: CSV in `fixtures/ingest/` (`26dee25`) and a second, identical copy in `docs/` (`c530e5d`); log in `docs/` (`c530e5d`).

**3. Pre-stage simulation (read-only).** Germany method; stage logic from `resolve.ts`, `stageLogic.ts`, `looseKey.ts`; input guard md5 of `line|name|city|country|cat` = `00af1fae1ee5fc4e41b3d1134cf3611a`.
- Before Step A: 53 match, 19 new_venue, 4 city_not_found (Gay, Carrboro, Bluffton, Knoxville), 4 country_label_disagrees (Birmingham AL rows found only Birmingham GB), 1 same_key_other_city (Mother -> Toronto).
- City state check: Oxford `ci_6aea4728c1` (Snackbar, MS), Durham `ci_e2af7e5615` (Saltbox Seafood Joint, NC), Greenville `ci_6e008b78b8` (Scoundrel, Soby's, SC) are correct. A city "Knoxville, Tennessee" `ci_e154900e69` already existed (The Barn, Forbes rows).
- Jackson `ci_b41779690b` is mixed: Elvie's, Sacred Ground Barbecue, Bully's Soul Food (MS) and The Grill at Amangani `ve_8d69af215c` (Jackson Hole, WY, closed, OAD 2025/2026). That WY venue is the cause of region "Rocky Mountains". Not blocking (no new venue in Jackson).
- Legacy population: 17 legacy 2025 rows unmatched; 8 were pairs (below); 4 Birmingham rows matched after Step A; 5 have no 2026 card.

**4. Ben's decisions (Oct 27, 13:21).** Q1 = A: aliases `birmingham` and `knoxville`. Q2 = A: plain city slugs. Then "Go" for Step A.

**5. Step A: 3 cities + 2 aliases.** File `docs/cities-michelin-2026-american-south.sql` (182 lines, ASCII, sha256 `228ce5bd6777d0a9f57b454424c40e6a10cc7a420a353992b7ab8a871b40375a`, repo `f286d21`/`0cd1e11`). Guards: counts 3,259 / 259, source md5 `ee67d263...44ad`, plan md5 `37e8feec...784d`, no clash, aliases unused, no batch yet; POST: counts 3,262 / 261, 5 audit rows, stage-job resolution with the country filter for 11 card labels + 2 UK controls (Birmingham GB, Oxford GB) gives exactly the expected city. POST gate tested read-only with virtual rows (13 of 13); dry run (Read connector) stopped at the first INSERT; **Write connector committed first time, Oct 27 17:24:14 UTC.** Audit **112,652-112,654** (cities INSERT, trigger), **112,655-112,656** (city_aliases INSERT, hand). No ledger row.
- Note: the comment in that file says "data lines 11, 59, 67". These are file line numbers. The job line numbers are 10, 58, 66.

| Card city | City id | Display | Slug |
|---|---|---|---|
| Gay, GA (Uberto Restaurant) | `ci_6e11873b9d` | Gay | `gay` |
| Carrboro, NC (Tesoro) | `ci_c7f1c6ece1` | Carrboro | `carrboro` |
| Bluffton, SC (Okàn) | `ci_4468453fa6` | Bluffton | `bluffton` |
| Birmingham, AL (4 Bibs) | `ci_bb460cdc18` | Birmingham, Alabama (+ alias `birmingham`) | `birmingham-al` |
| Knoxville, TN (A Dopo) | `ci_e154900e69` | Knoxville, Tennessee (+ alias `knoxville`) | `knoxville-tennessee` |

**6. Decisions file.** `fixtures/ingest/michelin-2026-american-south-decisions.csv`: 9 lines (header + 8), 2,215 bytes, UTF-8, all quoted, CRLF, sha256 `0f5bedb6073af264b808dd8bbec968973a87c9e5f8d49d4a3d42407c443e4e7e`, repo `225cd47`. Built by script from the CSV and an md5-guarded read of the 8 legacy venues (`f4196c87897f07c4d5069a22699318ce`); each line checked against the staged row name in `ingest_rows`.
- A first version (sha256 `9103dae3...68dec`, repo `f286d21`/`0cd1e11`) used file line numbers (one too high). It was caught after run 1 and before run 2, and replaced in `225cd47`. It was never applied.

| Job line | Card | Legacy venue |
|---|---|---|
| 16 | Malagón Mercado y Taperia | Malagón `ve_2b78d5a995` (One Star 2025 #4494) |
| 29 | Bomb Biscuit Co. | Bomb Biscuit Atlanta `ve_9f5cf63b71` |
| 41 | Cochon | Cochon Restaurant `ve_2b170a2ed7` |
| 44 | Dooky Chase | Dooky Chase Restaurant `ve_85577c3e90` |
| 57 | Mother | mother bakery & cafe \| south slope `ve_051574d412` |
| 64 | Mala Pata | Mala Pata Molino + Cocina `ve_ec88e3b3fd` |
| 67 | Leon's Oyster Shop | Leon's `ve_a4b6c65ad1` |
| 81 | Uzbegim | Uzbegim Halal Restaurant `ve_2925ba1328` |

**7. Stage (batch 18).**
- **Run 1** (Ben, 17:48 UTC): 57 match, 23 new_venue, 1 review (Mother). md5 of `line|verdict|coalesce(reason,'')|coalesce(venue_id,'')` = `1552560e875ac02dc967daa2583ae6d6` both sides. Staged URL md5 (sorted, C collation) `77057b55a4d9e5284e1c4202b93cb889` = CSV.
- **Run 2** with decisions (Ben, 17:52 UTC): md5 of `line|verdict|venue_id|decision` = `efca81553c05c8cdb0b8680be55b15e2` both sides. 65 match (1 / 19 / 45) on 65 distinct venues + 16 new_venue (0 / 2 / 14) in 16 groups; 0 review. The batch note still says "run 1".

**8. Promote.**
- **Dry run** (Ben, 20:47 UTC): 11 of 11 invariants pass; rolled back; read after: no change, the 16 report venue ids absent; used ledger 133-134 and audit 112,657-112,785.
- **Real promote** (Ben's run = "go", committed **Oct 27 20:48:30 UTC**): ledger **135** (michelin, award, 81) and **136** (michelin, city_label, 32), job `ingest-promote:michelin-2026-american-south`. Audit **112,786-112,914** (129, all INSERT, one timestamp): venues 16 (112,786-112,801), listings 16 (112,802-112,817), slugs 16 (112,818-112,833), awards 81 (112,834-112,914). Award ids **29,589-29,669**. Report `reports/michelin-2026-american-south-promote.md`.
- Row check: 81 of 81 staged rows have exactly one award; year 2026, category = staged row, no rank, no distinction on 81; 65 of 65 matches on the decided venue; 16 of 16 new venues carry the card name and card city, active, each with 1 award, 1 listing, 1 canonical slug, 2 city labels; the real venue ids = the dry-run ids. The 69 legacy 2025 rows are all still there (amended rule 2.1.1, no retire).

**New venues (16):** So. Fox `ve_b83e690aca` /atlanta/so-fox · Summerland `ve_002bb1220b` /atlanta/summerland · Uberto Restaurant `ve_82f336e11a` /gay/uberto-restaurant · Tipsy Thaiger `ve_9949d04394` /roswell/tipsy-thaiger · Safta's Table `ve_4c77fb33dc` /new-orleans/safta-s-table · Miscellanea Spirit House `ve_be9428c3a0` /oxford-us/miscellanea-spirit-house · Tesoro `ve_53b3b5d3e5` /carrboro/tesoro · The Story of "Mi Cariño" `ve_5fcfaab691` /charlotte/the-story-of-mi-carino · Ideal's `ve_ff8fd903dd` /durham/ideal-s · Ajja `ve_e05c8150b3` /raleigh/ajja · Okàn `ve_154740d5e3` /bluffton/okan · Palmira `ve_0c90f6c0c8` /charleston/palmira · Rivayat Creative Indian `ve_795adb5ebe` /charleston/rivayat-creative-indian · A Dopo `ve_f9a0661361` /knoxville-tennessee/a-dopo · Bao Toan Kitchen & Bar `ve_428a966a61` /memphis/bao-toan-kitchen-bar · Maiz De La Vida `ve_86c535260d` /nashville/maiz-de-la-vida.

**Legacy rows with no 2026 card (5, kept as 2025 history):** Superica `ve_e8d9422b57` (Bib 9329, Selected in 2026, stays active), Table & Main `ve_14c70070dc` (Bib 11869, Selected), Lewis Barbecue Charleston `ve_1e980fa0d5` (Bib 9761, Selected), Masterpiece `ve_5eb01dcd41` (Duluth, Bib 10131, no card, no site result), Rodney Scott's BBQ `ve_73faaf67e5` (Bib 9762, already closed).

## Rename candidates (open item 1)
Population: the 81 batch-18 awards joined by `source_url`; card name differs from `venues.name` on **14** venues. Apply the vote rule and the tie rule (venue's own spelling; Michelin fallback).

| Job line | Card | Database | Venue | Kind |
|---|---|---|---|---|
| 1 | Emeril’s | Emeril's | `ve_d3f02d0ccc` | apostrophe only |
| 15 | Counter | Counter- | `ve_e4be6c2af6` | dash (card has none; check the venue's own site) |
| 16 | Malagón Mercado y Taperia | Malagón | `ve_2b78d5a995` | pair |
| 29 | Bomb Biscuit Co. | Bomb Biscuit Atlanta | `ve_9f5cf63b71` | pair |
| 41 | Cochon | Cochon Restaurant | `ve_2b170a2ed7` | pair |
| 43 | Domilise’s Po-Boy & Bar | Domilise's Po-Boy & Bar | `ve_c578547312` | apostrophe only |
| 44 | Dooky Chase | Dooky Chase Restaurant | `ve_85577c3e90` | pair (also James Beard 2025: vote) |
| 46 | Lufu Nola | LUFU NOLA | `ve_04509480d4` | case only |
| 57 | Mother | mother bakery & cafe \| south slope | `ve_051574d412` | pair |
| 64 | Mala Pata | Mala Pata Molino + Cocina | `ve_ec88e3b3fd` | pair |
| 67 | Leon's Oyster Shop | Leon's | `ve_a4b6c65ad1` | pair |
| 79 | S.S. Gai | SS Gai | `ve_e00ab3eeee` | punctuation |
| 80 | St. Vito Focacceria | St.Vito Focacceria | `ve_c931bd1f24` | spacing |
| 81 | Uzbegim | Uzbegim Halal Restaurant | `ve_2925ba1328` | pair |

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-american-south.csv` | In the repo (`26dee25`); identical copy in `docs/` (`c530e5d`) | `109075a5...b07f3` |
| `docs/michelin-2026-american-south-log.md` | In the repo (`c530e5d`) | `e186305a...f823` |
| `docs/cities-michelin-2026-american-south.sql` | Run (audit 112,652-112,656), in the repo | `228ce5bd...0375a` |
| `fixtures/ingest/michelin-2026-american-south-decisions.csv` | Applied in run 2, in the repo (`225cd47`) | `0f5bedb6...e4e7e` |
| `reports/michelin-2026-american-south-stage.md` / `-review.csv` | Written by the stage job (`9f19121`, `ebffc30`); review CSV holds the run-1 row | - |
| `reports/michelin-2026-american-south-promote.md` | Real run | - |

## Methods that worked (new)
- **Alias to an existing city with a state suffix** ("Birmingham, Alabama", "Knoxville, Tennessee"): add the plain card label as an alias. The stage job's country filter keeps the city whose country agrees, so a UK "Birmingham" or "Oxford" row still resolves to the UK city. The POST gate must apply the same filter and include a control row for the other country.
- **Line numbers:** the stage job numbers rows from the first data row (line 1 = CSV file line 2). `ingest_rows.validation->>'line'` uses that number, and `loadDecisions` (stage.ts) keys decisions by `line` only, with no name check. Build the decisions file with `line = data row number`, and check each line against `ingest_rows.raw->>'venue_name'` read-only before run 2.
- **Run-1 md5:** compute it with `coalesce(reason,'')` and `coalesce(venue_id,'')`, both in SQL and in the prediction.

## Dead ends: do not retry (new)
- Decisions file numbered by CSV file line (one too high). It points each decision at the next card.
- `audit_log.created_at` (no such column; the time column is `at`). `source_capture_ledger.source_id` (no such column; it is `publisher`).

## Open items, in order
1. **American South rename CSV (next, new chat).** The 14 candidates above. Texas / Netherlands method (two md5-guarded inputs, `loadRenameCsv`), vote rule + tie rule. Questions for Ben likely: apostrophe-only rows (Emeril's, Domilise's: the apostrophe character policy is still open), case-only (LUFU NOLA), Counter- (dash: check the venue's own site), Mother (the venue's own name), Malagón (card adds "Mercado y Taperia").
2. **Slugs** for renamed venues (slug-file method, check against `slug.ts`).
3. **American South status items:** Masterpiece (Duluth) `ve_5eb01dcd41`: no card, no site result; read closure evidence (rows stay as history either way). Spring (Marietta) is open (2026 page has hours). Rodney Scott's BBQ is already closed.
4. **Jackson city split:** move The Grill at Amangani `ve_8d69af215c` (Jackson Hole, WY) out of `ci_b41779690b`, then fix the region of Jackson (MS) and of Winter Park `ci_e8c132c240` (Florida venues, region "Rocky Mountains"). Ben decides the method (new WY city or "Jackson Hole").
5. **Hold register (American South):** Mindful Voices 6 (Uberto, Restaurant Constance, Bacchanalia, January, Luminosa, THE CHASTAIN); Counter lost its 2025 Green Star; special awards: Exceptional Cocktails Allison/Ally Bowen, Miscellanea Spirit House `ve_be9428c3a0`; Sommelier William Mellon, manna (Wilmington, Selected, no venue check yet); Outstanding Service Jared Patterson, Little Betty Steak Bar (Mountain Brook, Selected); Young Chef Héctor González-Mora, The Story of "Mi Cariño" `ve_5fcfaab691` -> special-awards batch.
6. Price from the Michelin card (adds the 81 American South `$` cards: `$` 12, `$$` 45, `$$$` 8, `$$$$` 16). Ben chooses the method.
7. Optional repo tidy: delete the second CSV copy `docs/michelin-2026-american-south.csv`.
8. Beijing & Tianjin after the end of October; Switzerland after Nov 2, 2026 (option A, promote only).
9. Carried from the brief handoff: `name_native` backfill (China 469 / Japan 585 / Chengdu 47), gap list, hold registers (Texas, Belgium & Luxembourg, Netherlands, Taiwan), JL STUDIO blurb, site display of `name_native`, rechecks, Ben's decisions list (incl. `cities.venues_count` recount: the 3 new cities have `venues_count` 0), repo `.env` keys, Plan v1.31 (add the Taiwan sessions, the American South brief and this session), options B and C, project cleanup part 2.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-american-south-promoted-2026-10-27.md first, then claude/handoff-netherlands-renamed-2026-10-11.md for the latest rename record, then claude/handoff-texas-done-2026-10-10.md for the rename-CSV, collision-check and slug methods, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 136 and audit_log id 112,914 with a Read query. Then start open item 1: build the American South rename CSV for the 14 venues with the vote rule and the tie rule, examine it read-only, and ask me the questions the rules do not decide. No write before my go.
```
