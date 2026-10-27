# Handoff: CompassEats, Oct 27, 2026 (12:50 Atlanta). American South 2026 capture brief saved (project and repo `36509e3`). Taiwan `name_native` SQL file checked in the repo. Next: American South capture in Cowork, then capture check and simulation.

This file replaces `claude/handoff-taiwan-native-done-2026-10-27.md` for live state, decisions, open items, methods and dead ends. That file still applies for the Taiwan `name_native` record (audit 112,467-112,651) and the list of older handoffs. The other files still apply as before:
- `claude/cowork-michelin-2026-american-south.md`: the brief (this session).
- `claude/handoff-briefs-texas-belgium-2026-10-09.md` and `claude/cowork-michelin-2026-texas.md`: the Cowork capture brief method and the US model brief.
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the capture-check, simulation, city insert, pairing, stage and promote record (model for a promote-only guide). **Read it before the American South stage.**
- `claude/handoff-texas-promoted-2026-10-10.md` and `claude/handoff-texas-done-2026-10-10.md`: the Texas stage, promote, rename-CSV and slug record (the last US guide).
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, the gated venue-delete method.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9...672216`): rule 2.1.1 (amended Sep 24), rule 2.1.7.

Working rules (unchanged): plain `/ste` replies; populations on every count; one "go" per write batch; read-back after each commit; under-merge over over-merge; no competitor sources; no hand-retyped files; build, examine read-only, present, then ask; the tie rule (vote first; in a tie or doubt the venue's own spelling, Michelin fallback); nothing below a Michelin Bib is tracked; only closure evidence gives `closed`; Ben starting a stage, promote or real rename job is his "go".

## Live state
Population: whole table. Read Oct 27, 16:42 UTC (12:42 Atlanta). **No database table changed in this session.** Fresh read at 16:48 UTC: audit last id still 112,651.

| Table | Count |
|---|---|
| venues | 11,291 (active 10,924, closed 367) |
| awards | 22,841 |
| Michelin 2025 / 2026 / 2027 rows | 3,520 / 5,527 / 47 |
| listings / slugs | 11,291 / 12,816 (canonical 11,291) |
| cities / city_aliases / city_label_source | 3,259 / 259 / 23,979 |
| price / blurbs / redirects | 7,024 / 142 / 9 |
| venues with `name_native` | 203 |
| source_capture_ledger | 91 (last id 132) |
| audit_log | 107,508 (last id 112,651) |
| ingest_batches | 1, 3-17 promoted (no id 2) |
| rename_rows | 1,102 |

## Done in this session (Oct 27, 12:41 to 12:50 Atlanta)

**1. Start check.** All counts, ledger 132, audit 112,651, slugs 12,816 matched the Taiwan native handoff.

**2. Taiwan file in the repo (open item 1 closed).** `docs/name-native-michelin-2026-taiwan.sql` at commit `b749468` (Oct 27, 12:41 -0400): sha256 `dfb9ddf2ffaf280d7fc9c79d01cecd28c9559f97b31dc41ea459e9909e94a8f2`, 190 lines, ASCII. Correct.

**3. American South 2026 facts.**
- Ceremony **Oct 21, 2026**, The Pinnacle, Nashville. Second edition (the 2025 edition was revealed in Greenville, SC; Michelin article Nov 3, 2025).
- States (Michelin territory selector): Alabama, Georgia, Louisiana, Mississippi, North Carolina, South Carolina, Tennessee.
- Counts (Michelin press release): 0 / 1 / 21 stars, 59 Bib (14 new), 6 Mindful Voices. Selection total 266 and Recommended 185 (32 new) in the michelin.com copy; 265 and 184 in the travelprnews.com copy. The brief tells Cowork to read the true totals from the site filter.
- New One Stars: So. Fox (Atlanta), Uberto Restaurant (Gay, GA), Dakar NOLA (New Orleans). Emeril's keeps Two Stars.
- Special awards (press release): Exceptional Cocktails Ally Bowen (Miscellanea Spirit House); Sommelier William Mellon (manna); Outstanding Service Jared Patterson (Little Betty Steak Bar); Young Chef / Culinary Professional Héctor González-Mora (The Story of "Mi Cariño").
- Press reports for Georgia Bibs (to be verified by Cowork): Superica and Table & Main moved to Recommended; Masterpiece (Duluth) left the guide.
- **Path:** ceremony after June 1, 2026 → amended rule 2.1.1: promote only; the legacy rows stay as 2025 history; no retire batch (Texas and Colorado precedent). "Mindful Voices", not Green Star.
- URLs: https://www.michelin.com/en/publications/products-and-services/new-michelin-starred-restaurants-shine-across-the-american-south ; https://guide.michelin.com/us/en/event/the-michelin-guide-heads-to-nashville-for-2026-american-south ; https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-to-the-american-south . The guide.michelin.com 2026 star list article was not found by web search; Cowork looks for it.

**4. Legacy American South rows.** Population: Michelin rows labelled 2025 on venues in 18 cities found by name (US cities have no state field). **69 rows on 69 venues, 0 sourced: Two Stars 1, One Star 18, Bib 50.** 1 closed venue (Rodney Scott's BBQ `ve_73faaf67e5`, Bib 9762). No American South row carries 2026.

| State | City (One Star / Bib) | 2* | 1* | Bib | Rows |
|---|---|---|---|---|---|
| GA | Atlanta `ci_57c6cbff0d` 7 / 10, Marietta `ci_12c4d55589` 1 / 0, Avondale Estates `ci_33d06340a7` 0 / 1, Duluth `ci_f2d776a7b5` 0 / 1, Roswell `ci_1ea404bf5d` 0 / 1 | 0 | 8 | 13 | 21 |
| LA | New Orleans `ci_a38cc7fdd4` 2 / 11 | 1 | 2 | 11 | 14 |
| TN | Nashville `ci_67a4834671` 3 / 7, Memphis `ci_a9cbff02c8` 0 / 1, Chattanooga `ci_04de75d707` 0 / 1 | 0 | 3 | 9 | 12 |
| NC | Charlotte `ci_a6008231fa` 1 / 1, Asheville `ci_d0dc498d53` 0 / 3, Raleigh `ci_c6c7caba9c` 0 / 2, Knightdale `ci_f1f4ea138a` 0 / 1 | 0 | 1 | 7 | 8 |
| SC | Charleston `ci_735e973aa8` 3 / 3, Greenville `ci_6e008b78b8` 1 / 0 | 0 | 4 | 3 | 7 |
| AL | "Birmingham, Alabama" `ci_bb460cdc18` 0 / 4, Mobile `ci_532c28d541` 0 / 1 | 0 | 0 | 5 | 5 |
| MS (card city to confirm) | "Jackson" `ci_b41779690b` 0 / 2 (Elvie's, Sacred Ground Barbecue) | 0 | 0 | 2 | 2 |
| **Total** | | **1** | **18** | **50** | **69** |

- **Label check passes:** the rows hold all 4 new 2025 stars (Counter- `ve_e4be6c2af6`, Wild Common `ve_e7242c6433`, Scoundrel `ve_4b4567b1e3`, Locust `ve_c9b0592d46`). The 3 new 2026 stars have no Michelin row. So the 69 rows are the real 2025 edition.
- **Older editions, not touched:** 43 Atlanta-guide rows from 2023 (18) and 2024 (25) on Atlanta, Avondale Estates, Duluth, Marietta and Roswell (incl. Green Star, Exceptional Cocktails, Outstanding Service, Sommelier rows).
- Excluded as not American South (checked by venue): Albany (China Village, CA), Fairfax (Village Sake, CA), Glendale (Adana, CA), Aurora (Annette, CO).

**5. Items for the capture check and simulation (no decision yet).**
- Card cities with no `cities` row (by display name, country US): Gay, Carrboro, Knoxville, Bluffton, Franklin, Travelers Rest (and any other the capture lists) → a city insert step before the stage (Netherlands Step A method).
- Existing US city rows that the new cards can hit: Durham `ci_e2af7e5615`, Oxford `ci_6aea4728c1`, Decatur `ci_4b24557682`, Columbia `ci_9ceb595da6`, Savannah `ci_be5d95a4f1`. Check each against the card `state_label` before the stage (same-name cities in other states).
- City `Jackson` `ci_b41779690b` has region `rg_50e244d435` "Rocky Mountains"; Winter Park `ci_e8c132c240` has the same region. Probably wrong. Read and ask Ben.
- City display "Birmingham, Alabama": a card "Birmingham" can need an alias (Valkenburg precedent).
- Dakar NOLA exists as a venue (James Beard and North America 50 Best rows, no Michelin row) → pair. So. Fox and Uberto have no venue → new venues. THE CHASTAIN - Restaurant (Atlanta) holds only Green Star 2023/2024.
- Name items for the rename CSV later: "Malagón" (press "Malagón Mercado y Taperia"), "Counter-", "mother bakery & cafe | south slope", "Bomb Biscuit Atlanta", "The Busy Bee", "Lewis Barbecue Charleston", "Cochon Restaurant".
- Status items: Rodney Scott's BBQ (closed, Bib 2025); Spring, Marietta ("temporarily closed" in the 2025 article).

**6. Ben's decisions (Oct 27, 12:48).**
- **Q1 A:** the CSV gets a second extra column, `state_label` (two-letter code from the card footer). The importer ignores extra columns and names them in its report (`scripts/ingest/lib/columns.ts`); the value stays in `ingest_rows.raw` for the city checks.
- **Q2 go:** brief saved to the project.

**7. Brief saved.** `claude/cowork-michelin-2026-american-south.md` (project) = `docs/cowork-michelin-2026-american-south.md` (repo, commit `36509e3`, Oct 27, 12:49 -0400, 1 file): 166 lines, 15,806 bytes, UTF-8, NFC, LF, sha256 `3bb655f7f7bc0a567dbc83bf7df356e0d465f395f4aef23510a8ad5e7dc59307`. Same section layout as the Texas brief. Changes from Texas: seven states (region slug or seven state lists, per-state count table), `state_label` column, footer check for AL/GA/LA/MS/NC/SC/TN, blocks of 12 rows or fewer (Texas log finding), six venue-page spot checks, the name and city register above, the hold register (6 Mindful Voices, 5 Green Stars of 2025, 4 special awards).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/cowork-michelin-2026-american-south.md` | In the repo (`36509e3`) and the project | `3bb655f7...5dc59307` |
| `docs/name-native-michelin-2026-taiwan.sql` | Run (audit 112,467-112,651), in the repo (`b749468`) | `dfb9ddf2...9e94a8f2` |

## Methods that worked (new)
- **Population of a US multi-state guide without a state field:** read all US cities with Michelin rows (whole result to disk, parsed by script), choose the cities by name, then read the venue names of every ambiguous city (Albany, Fairfax, Glendale, Duluth, Jackson, Greenville) to place it in a state.
- **States of a US regional guide:** the Michelin territory selector ("USA - <State> (American South)") on any guide.michelin.com page, read with WebFetch.
- **Extra CSV columns:** the importer accepts any number of extra columns and reports them; they land in `ingest_rows.raw`.

## Dead ends: do not retry (new)
- `atlantamagazine.com` with WebFetch (client error). Use the AJC article or Michelin sources.

## Open items, in order
1. **American South capture (next).** Ben opens a new Cowork session (Opus, Chrome extension) with the opening message below. Cowork delivers `michelin-2026-american-south.csv` and `michelin-2026-american-south-log.md`.
2. **American South capture check, simulation, stage and promote (new chat).** Ben uploads the CSV to `fixtures/ingest/` and the log to `docs/`. Then: hash check; counts against the brief (1 / 21 / 59); city check with `state_label` (part 5 items); city insert if needed; pairing and decisions file; stage; dry-run promote; promote. No retire. Then the rename CSV, slugs and status items. Then Beijing & Tianjin after the end of October.
3. **Switzerland after Nov 2, 2026** (option A, promote only).
4. **`name_native` backfill:** China 469 / Japan 585 / Chengdu 47 (Taiwan method). China Line 128 (Lucky Zhang's) and lines 317, 355 from the China renamed handoff.
5. **Gap list:** promote-only Singapore; retire-path Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; Thailand after its 2027 edition; Canada as three guides.
6. Hold registers: Texas, Belgium & Luxembourg, Netherlands, Taiwan, American South (after capture) → special-awards batch.
7. Price from the Michelin card (Taiwan `$` cards: $ 86, $$ 64, $$$ 20, $$$$ 37; Oct 27 cards: Mai Yen Shun $$, Zhu Xin Ju $$, Cheng Tsung $). Ben chooses the method.
8. JL STUDIO blurb (`needs_rewrite`): rewrite through the Option B runbook when blurbs come up.
9. Site display of `name_native` (no date). Ben decides if and where. Lovable prompt when the time comes.
10. Rechecks, no date: Pale Jade Pavilion `ve_96994a1e21`, Dong Shang Taiwanese Seafood `ve_7eb5839370`, Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
11. Carried from the Taiwan native handoff item 11 (France slugs, later-ceremony guides, carried rename CSVs, Ben's decisions list incl. `cities.venues_count` recount, repo `.env` keys, Plan v1.31 (add the Taiwan sessions and this session), options B and C, project cleanup part 2). New for Ben's decisions list: the region of Jackson and Winter Park ("Rocky Mountains").

## Opening message for the American South Cowork session
```
Read the brief claude/cowork-michelin-2026-american-south.md from the project files with the Projects tool (the same file is docs/cowork-michelin-2026-american-south.md in the GitHub repo, sha256 3bb655f7…5dc59307). Follow it exactly. Use the Chrome extension for guide.michelin.com. Do not touch the database or the repo. Deliver michelin-2026-american-south.csv and michelin-2026-american-south-log.md in this chat, then stop and wait for me.
```

## Suggested opening prompt for the next chat (after the capture)
```
Read these handoffs from the project files with the Projects tool: claude/handoff-american-south-brief-2026-10-27.md first, then claude/cowork-michelin-2026-american-south.md (the brief), then claude/handoff-netherlands-promoted-2026-10-11.md for the capture-check, simulation, city insert, pairing, stage and promote record, then claude/handoff-texas-promoted-2026-10-10.md for the last US guide. Confirm live counts, ledger id 132 and audit_log id 112,651 with a Read query. I attached michelin-2026-american-south.csv and michelin-2026-american-south-log.md from the Cowork capture. Check the CSV hash against the log, check the counts against the brief, then run the read-only pre-stage simulation (use state_label for the city checks) and tell me what the stage and promote will need. Give me click steps to upload the two files to the repo. No write before my go.
```
