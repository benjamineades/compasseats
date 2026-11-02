# Handoff: closed-venue sweep item 6 read. 7 venues active. Nov 2, 2026 (15:35 Atlanta).

This file replaces `handoff-closed-sweep-twins-renames-done-2026-11-02.md` for live state. That file and `handoff-closed-sweep-201-done-2026-11-02.md` still hold items 3, 4, 5 and 7. The closed rule and the older recheck list are in `handoff-closed-rule-done-2026-11-02.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 15:22 "1A, 2A, 3A, 4A, 5A".
  - 1A = Group 2 active (4 venues).
  - 2A = Double Deuce Lounge stays closed, recheck after Dec 5.
  - 3A = read the Goh pair for a merge question. Joo Ok (Seoul) stays closed, no merge, the city is different.
  - 4A = status first with the current names, rename read in a separate file.
  - 5A = no more reads of Group 10 now.
- 15:24 "Go".

## Live state (read Nov 2, 20:25:24 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,294 (active **10,997**, closed **297**) |
| closed venues published / not published | **0 / 297** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs | 13,019 (canonical 11,294) |
| price | 7,727 |
| listings / cities | 11,294 / 3,264 |
| city_label_source | 23,989 |
| cities.venues_count | sum **10,997**; 0 cities differ from the view |
| source_capture_ledger | 185 rows, last id 237 |
| audit_log | **118,827** rows, last id **124,341** |

## Done
`docs/fix-status-sweep-7-active-2026-11-02.sql` (sha256 `e690675f...0396a5`). Write connector, first try, 20:25:18 UTC. Audit 124,321-124,341 (cities 7, listings 7, venues 7). No ledger row. Run record `docs/closed-sweep-2026-11-02/run-sweep-7-active-2026-11-02.txt`. The file header has one evidence line for each of the 7.
Evidence for all 124: `docs/closed-sweep-2026-11-02/closed-sweep-item6-evidence-2026-11-02.csv`.
Active: Chez Vrony `ve_62570bae63`, Talavera `ve_4aa5923e99`, The Union Trading Company Bar `ve_c71805d8dd` (Group 1); D.F. Cantina by Barbary Coast `ve_e5e9d66f60`, Drink `ve_e1e3a5810d`, Floreria Atlantico Barcelona `ve_5b37d2dbd7`, Sherry Butt `ve_d9cd4fd552` (Group 2).

## Population and result
The 124 = the 21 closed venues the Nov 2 flip did not change (audit 89,129-89,149, Sep 10 load, md5 `a0a93228...e5b5d`) + the 103 with last award before 2025 (md5 `7821d157...aa709`).

| Group | 21 | 103 | Result |
|---|---|---|---|
| 1 Dated 2026 or own site with season or booking | 0 | 3 | Active |
| 2 Undated or 2025 evidence | 0 | 4 | Active (Ben 1A) |
| 3 Residency: Double Deuce Lounge | 1 | 0 | Closed, recheck after Dec 5 |
| 4 Moved, twin: Joo Ok (Seoul), La Maison de la Nature Goh | 0 | 2 | Closed |
| 5 Listing only | 0 | 6 | Closed, recheck |
| 6 Sources disagree | 1 | 5 | Closed, recheck |
| 7 Temporary closure | 0 | 7 | Closed, recheck |
| 8 No usable evidence | 0 | 7 | Closed, recheck |
| 9 Closure on undated listings only | 1 | 9 | Closed, recheck |
| 10 Closure evidence (61 strong, 17 medium) | 18 | 60 | Closed |

Second read: all 15 rated open, the 2 seasonal and the 4 with a 2025 award. 6 verdicts changed (ernst, Imperial Cocktail Bar, Buddha Bar Dubai, Olam, Double Deuce Lounge, Hacha Agaveria). Group 10 was not read again except these, so it can hold missed moves or residencies (Ben 5A).

## Found after the write (no change made)
- **D.F. Cantina by Barbary Coast `ve_e5e9d66f60` is weaker than shown at the go.** barbarycoastsg.com/deadfallcantina now redirects to luxuryhospitalitymgm.com/about-us, an unrelated lottery page, so the own site is gone. The rows Asia's 50 Best Bars 2021 No. 29 and 2022 No. 95 fit Barbary Coast: 88bamboo gives Barbary Coast as No. 29 in 2021. So the rename target is Barbary Coast, not Deadfall Cantina. Barbary Coast and Deadfall Cantina are separate bars at 16 North Canal Rd (Time Out). Time Out shows hours for both, updated Aug 6 and Aug 8, 2026. No dated source shows either trading. Same standard as The Old Man: listing only. No venue named Barbary Coast is in the database.
- **Goh pair:** same chef (Takeshi Fukuyama), same city. Hitosara: closed Oct 2022 for relocation. Tatler (Sep 7, 2023): "It's a new Goh." 50 Best: shuttered Oct 2022, reopened 2023 in the 010 Building with Goh, "a new concept". Closed venue: awards 20322-20324 (2019, 2021, 2022), 2 labels, 1 slug, no price. Active Goh: awards 2024-2026, 2 labels, 1 slug, no price. No year overlap. Merge would have a DELETE, so expect the SQL Editor.
- **Union Trading Company:** 50 Best gives name Union Trading Company, 306 Hengshan Rd. The Spirits Business uses the same name.
- **Possible contamination:** Milk and Honey London, Grillz `ve_13328f95af` (World's 50 Best Bars 2009 No. 1), London Academy `ve_20273fd0d3` (2010 No. 10), 50 Kalò `ve_25d81bb44e` (2009 No. 16). Active, no URL.
- **Names on closed venues:** Susar (Susur), BlueFrog Media Pvt. Ltd. (blueFROG), Pekin Cafe and Lounge Inc. (Pekin Noodle Parlor), Re - (Re).
- Chez Vrony: 50 Best 2002 page writes "Chez Vroney". Agent note: a Michelin card exists; no Michelin row. Check in the Swiss batch.

## Rechecks added (no write)
- Double Deuce Lounge `ve_0b0952a21c`: residency 137 Oxford St to Dec 5, 2026.
- Hacha Agaveria `ve_7befe189f3`: residency ended Aug 31, 2026; seeks a site.
- Buddha Bar Dubai `ve_527607b114`: closed Apr 2026, reopening Jul 16 not confirmed.
- Rose Bar `ve_eb41966748`: Gramercy Park Hotel, fall 2026 target.
- Group 5: Junior The Pocket Bar, The Liquor Store Cocktail Bar, Marismo (summer season), 40 Thieves, The Old Man (Singapore), F Bar & Lounge.
- Group 6: Papa Doble, Blue Bar, Circus Cocktail Bar, Olam Restaurante, Tales & Spirits, Tawlet.
- Group 7 rest: Ristorante Hotel Cipriani, The Restaurant at Meadowood, Highlands Bar & Grill, Lebensstern, Skyview Bar (about Oct 2027).
- Group 8: Laboratorio Folkloristico, Tesouro, The Portico, Conservatory at Blantyre, De Patio Restaurante, Electric Bing Sutt, Il Canto.
- Group 9: Shoun RyuGin, Animar, Contrast, Noon, White Plate, AHA Saloon, Le Forvm, The Parlour, Buddha-bar (Kyiv), Neos.
- Possible new sites: blueFROG (Ballard Pier, Mumbai), Biko, Operation Dagger (DAGGER), Changa (MuzedeChanga).

## Open items
Open questions to Ben at this handoff: D.F. Cantina status and name, Goh merge, Union Trading Company rename.
From the sweep: item 3, item 4, item 5, item 7 (numbers in `handoff-closed-sweep-201-done-2026-11-02.md`). Item 6 is closed apart from the questions above. Switzerland still waits for Ben's "results live".

## Methods (new)
- **Batches:** 6 batches of up to 23 venues with at most 2 searches per venue. Round 1 of 4, then round 2 of 2. The limit held.
- **Second read finds what batches miss.** Search for "closed" and for "reopen" or "new site" separately. Closure read stops at the first closure article, so it misses a later residency.
- **Wanderlog closed flags can come from a move** (Union Trading Company).
- **Read the award rows against the evidence before a rename.** A Google-derived name can sit on rows of another bar.
- **Keep work files in the scratchpad until the run.** No untracked repo file, so no stop check before the go.

## Suggested opening prompt
```
Read claude/handoff-closed-sweep-item6-done-2026-11-02.md from the project files, then
claude/handoff-closed-sweep-201-done-2026-11-02.md for items 3, 4, 5 and 7,
claude/handoff-closed-rule-done-2026-11-02.md for the closed rule and recheck list and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 237,
audit_log 124,341, venues 11,294 (active 10,997, closed 297), awards 25,097, slugs 13,019, price 7,727, closed published 0 and cities.venues_count sum 10,997.
Then take my answers on D.F. Cantina, the Goh merge and the Union Trading Company rename, and start the next open item. Show me in /ste style the evidence and ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
