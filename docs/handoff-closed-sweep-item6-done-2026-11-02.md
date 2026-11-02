# Handoff: closed-venue sweep item 6 done. 6 venues active, Goh merged, 2 renames. Nov 2, 2026 (15:40 Atlanta).

This file replaces `handoff-closed-sweep-twins-renames-done-2026-11-02.md` for live state. That file and `handoff-closed-sweep-201-done-2026-11-02.md` still hold items 3, 4, 5 and 7. The closed rule and the older recheck list are in `handoff-closed-rule-done-2026-11-02.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 15:22 "1A, 2A, 3A, 4A, 5A".
  - 1A = Group 2 active (4 venues).
  - 2A = Double Deuce Lounge stays closed, recheck after Dec 5.
  - 3A = read the Goh pair for a merge question. Joo Ok (Seoul) stays closed, no merge, the city is different.
  - 4A = status first with the current names, rename read in a separate file.
  - 5A = no more reads of Group 10 now.
- 15:24 "Go".
- 15:29 "1A, 2A, 3A": 1A = D.F. Cantina by Barbary Coast back to closed, recheck, rename Barbary Coast; 2A = merge La Maison de la Nature Goh into Goh; 3A = rename Union Trading Company, same file.
- 15:32 "Go". 15:36 "Ran" (SQL Editor).

## Live state (read Nov 2, 20:37:00 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,293 (active **10,996**, closed **297**) |
| closed venues published / not published | **0 / 297** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs | 13,021 (canonical 11,293, non-canonical 1,728) |
| price | 7,727 |
| listings / cities | 11,293 / 3,264 |
| city_label_source | 23,989 |
| cities.venues_count | sum **10,996**; 0 cities differ from the view |
| rename_batches / rename_rows | 28 (last id 43) / 1,300 |
| source_capture_ledger | 186 rows, last id **238** |
| audit_log | **118,844** rows, last id **124,358** |

## Done
`docs/fix-status-sweep-7-active-2026-11-02.sql` (sha256 `e690675f...0396a5`). Write connector, first try, 20:25:18 UTC. Audit 124,321-124,341 (cities 7, listings 7, venues 7). No ledger row. Run record `docs/closed-sweep-2026-11-02/run-sweep-7-active-2026-11-02.txt`. The file header has one evidence line for each of the 7.
Evidence for all 124: `docs/closed-sweep-2026-11-02/closed-sweep-item6-evidence-2026-11-02.csv`.
Active: Chez Vrony `ve_62570bae63`, Talavera `ve_4aa5923e99`, The Union Trading Company Bar `ve_c71805d8dd` (Group 1); D.F. Cantina by Barbary Coast `ve_e5e9d66f60`, Drink `ve_e1e3a5810d`, Floreria Atlantico Barcelona `ve_5b37d2dbd7`, Sherry Butt `ve_d9cd4fd552` (Group 2).

Second file: `docs/fix-closed-sweep-goh-barbary-union-2026-11-02.sql` (sha256 `806a9a6c...f4d2e295`). One transaction. Write connector cancelled 2 calls in 0.5 s (nothing ran). Ben ran the file in the SQL Editor, 20:36:34 UTC. Ledger 238, audit 124,342-124,358. Rename batch 43 `rename-closed-sweep-item6-2-2026-11-02`. Run record `docs/closed-sweep-2026-11-02/run-goh-barbary-union-2026-11-02.txt`. The file header holds the evidence.
- D.F. Cantina by Barbary Coast `ve_e5e9d66f60`: now Barbary Coast, closed, not published. Singapore 205. Slug `singapore/barbary-coast`. So the first file nets 6 venues active.
- The Union Trading Company Bar `ve_c71805d8dd`: now Union Trading Company, active. Slug `shanghai/union-trading-company`.
- La Maison de la Nature Goh `ve_61f0698a02` merged into Goh `ve_ce25175db1`. Awards 20322-20324 and labels 20429-20430 moved. Goh holds 9 awards. Old slug non-canonical.
Known limit: Barbary Coast rows 19517 and 19518 have no URL; the bar they name is not proved. Goh: 50 Best calls it "a new concept"; Ben chose the merge.

## Population and result
The 124 = the 21 closed venues the Nov 2 flip did not change (audit 89,129-89,149, Sep 10 load, md5 `a0a93228...e5b5d`) + the 103 with last award before 2025 (md5 `7821d157...aa709`).

| Group | 21 | 103 | Result |
|---|---|---|---|
| 1 Dated 2026 or own site with season or booking | 0 | 3 | Active |
| 2 Undated or 2025 evidence | 0 | 4 | Active (Ben 1A); Barbary Coast went back to closed in the second file |
| 3 Residency: Double Deuce Lounge | 1 | 0 | Closed, recheck after Dec 5 |
| 4 Moved, twin: Joo Ok (Seoul), La Maison de la Nature Goh | 0 | 2 | Closed |
| 5 Listing only | 0 | 6 | Closed, recheck |
| 6 Sources disagree | 1 | 5 | Closed, recheck |
| 7 Temporary closure | 0 | 7 | Closed, recheck |
| 8 No usable evidence | 0 | 7 | Closed, recheck |
| 9 Closure on undated listings only | 1 | 9 | Closed, recheck |
| 10 Closure evidence (61 strong, 17 medium) | 18 | 60 | Closed |

Second read: all 15 rated open, the 2 seasonal and the 4 with a 2025 award. 6 verdicts changed (ernst, Imperial Cocktail Bar, Buddha Bar Dubai, Olam, Double Deuce Lounge, Hacha Agaveria). Group 10 was not read again except these, so it can hold missed moves or residencies (Ben 5A).

## Found, no change made
- **Barbary Coast `ve_e5e9d66f60`:** barbarycoastsg.com/deadfallcantina redirects to an unrelated lottery page. Time Out shows hours for Barbary Coast and Deadfall Cantina, updated Aug 6 and Aug 8, 2026. No dated source shows either trading. Recheck. Deadfall Cantina has no venue row.
- **Possible contamination:** Milk and Honey London, Grillz `ve_13328f95af` (World's 50 Best Bars 2009 No. 1), London Academy `ve_20273fd0d3` (2010 No. 10), 50 Kalò `ve_25d81bb44e` (2009 No. 16). Active, no URL.
- **Names on closed venues:** Susar (Susur), BlueFrog Media Pvt. Ltd. (blueFROG), Pekin Cafe and Lounge Inc. (Pekin Noodle Parlor), Re - (Re).
- Chez Vrony: 50 Best 2002 page writes "Chez Vroney". Agent note: a Michelin card exists; no Michelin row. Check in the Swiss batch.

## Rechecks added (no write)
- Barbary Coast `ve_e5e9d66f60`: listing only, own site gone.
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
From the sweep: item 3, item 4, item 5, item 7 (numbers in `handoff-closed-sweep-201-done-2026-11-02.md`). Item 6 is closed. Switzerland still waits for Ben's "results live".

## Methods (new)
- **Batches:** 6 batches of up to 23 venues with at most 2 searches per venue. Round 1 of 4, then round 2 of 2. The limit held.
- **Second read finds what batches miss.** Search for "closed" and for "reopen" or "new site" separately. Closure read stops at the first closure article, so it misses a later residency.
- **Wanderlog closed flags can come from a move** (Union Trading Company).
- **Read the award rows against the evidence before a rename.** A Google-derived name can sit on rows of another bar.
- **Write connector:** the Goh file with DELETE was cancelled in 0.5 s, 2 calls. Same pattern as the Tannenhof file. The SQL Editor ran it unchanged.
- **Keep work files in the scratchpad until the run.** No untracked repo file, so no stop check before the go.

## Suggested opening prompt
```
Read claude/handoff-closed-sweep-item6-done-2026-11-02.md from the project files, then
claude/handoff-closed-sweep-201-done-2026-11-02.md for items 3, 4, 5 and 7,
claude/handoff-closed-rule-done-2026-11-02.md for the closed rule and recheck list and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 238,
audit_log 124,358, venues 11,293 (active 10,996, closed 297), awards 25,097, slugs 13,021, price 7,727, closed published 0 and cities.venues_count sum 10,996.
Then start item 7, the 17 temporary closures on the recheck list, or the next open item I name. Show me in /ste style the evidence and ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
