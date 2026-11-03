# Handoff: Swiss price, 2025 backfill and cleanup done. Nov 3, 2026 (16:55 Atlanta). Next: Swiss open items.

This file replaces `handoff-switzerland-renamed-2026-11-03.md` for the Swiss live state and open items. That file still holds rename batch 46, the name notes and the slug methods. `handoff-switzerland-status-done-2026-11-02.md` holds the status file and the Ô Bois Sauvage read. `handoff-switzerland-decisions-2026-11-02.md` holds decisions 1-10 (decision 5 is replaced; 2 and 4 are now done). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 16:29 "1,2,3". 16:37 "1A, 2A, 3A, 4A": backfill from card captures; merge Trois Rois (row 111 deleted, blurb moved); merge Carlton; merge Magdalena Lucerne.
- 16:38 "Go" (price). 16:39 "Go" (backfill). 16:41 "Go" (cleanup). 16:48 "done" (SQL Editor).

## Live state (read Nov 3, 21:48:38 UTC, whole tables)
Venues **11,320** (active **11,028**, closed **292**). Awards **25,324**. Michelin 2025 **4,997**. Slugs **13,144** (canonical 11,320, non-canonical **1,824**). Price **7,759** (legacy_guide **2,180**). Listings 11,320. city_label_source 24,047. Blurbs 142. Cities 3,279, `cities.venues_count` sum **11,028**, 0 cities differ from `city_venue_counts`. rename_batches 31, rename_rows 1,396. Ledger 194 rows, last id **248**. audit_log 119,764 rows, last id **125,593**. Closed published 0, active not published 0.

## Done
| Write | File (sha256) | How | Audit | Result |
|---|---|---|---|---|
| Price | `docs/price-michelin-card-switzerland-2026.sql` (`cbbccefe...dce6`) | Write connector, first try, 21:38:55 UTC | 125,341-125,565 | 225 venues: 191 UPDATE, 34 INSERT; CHF; ledger 245 (michelin, price, 225) |
| Backfill | `docs/backfill-michelin-2025-switzerland-4.sql` (`c49afee6...3242`) | Write connector, first try, 21:40:12 UTC | 125,566-125,569 | Awards 32491-32494; ledger 246 (michelin, award, 4) |
| Cleanup | `docs/cleanup-michelin-2026-switzerland-list-2026-11-03.sql` (`8fdf004f...a72f`) | Ben, SQL Editor, 21:48:13 UTC (Write connector cancelled in 0.6 s) | 125,570-125,593 | 3 venues merged; ledger 247 (michelin 2), 248 (oad 1) |

Run records: `docs/ch-2026-build/run-price-ch-2026-11-03.txt`, `run-backfill-ch-2026-11-03.txt`, `run-cleanup-list-ch-2026-11-03.txt`.

### Price
Population 225 cards of batch 20. Symbols as printed, currency CHF (decision 4), `€` stored with CHF, Torkel `$$$`. captured_at = batch 20 created_at. Same tier 186. Tier changes 5: Birdy's by Achtien `$$$$` to `€€`, Tosca `$$$$` to `€€€`, Wöschi `$$$` to `€€€€`, Gasthaus Löwen `$$$$` to `€€€`, L'Atelier Robuchon `$$$` to `€€€€`. Legacy prices on After Seven and Colani Bistrot are replaced.

### Backfill
| Award | Venue | Category | Capture |
|---|---|---|---|
| 32491 | Restaurant LA `ve_db48bdeac3` | One Star | 20251115192248 `/en/` |
| 32492 | La Croix d'Or `ve_a3d2920b36` | One Star | 20251110102357 `/en/` |
| 32493 | Bären Schwarzenburg `ve_781166e4b0` | Bib Gourmand | 20260111022911 `/en/` |
| 32494 | Bären Utzenstorf `ve_147506ea77` | Bib Gourmand | 20251206211453 `/ch/de/` |

### Cleanup
| Went | Survivor | Awards | Other |
|---|---|---|---|
| Grand Hotel Les Trois Rois `ve_d159e1bbd3` | Cheval Blanc by Peter Knogl `ve_46e15d96d7` | 111 deleted (copy of 20659) | Blurb moved (needs_rewrite), legacy price and labels 29, 30 deleted |
| Carlton Hotel St. Moritz LHW `ve_7c75b49d07` | Da Vittorio - St. Moritz `ve_dcfa59471a` | 2940 moved | Legacy price deleted, labels 1064, 1065 moved |
| Restaurant Magdalena (Lucerne) `ve_7d4e3b91ec` | Magdalena `ve_1489b03a45` | 18514 moved | Labels 17999, 18000 moved |

Old slugs stay, non-canonical, on the survivors. `lucerne/restaurant-magdalena` now points to a venue in another city (56 such slugs before this file). Limit: the OAD page proves the address, not the 2025 rank No. 498.

## Recheck list
Sonne Scheunenberg `ve_1ff8df1642`: Ben opens the site (card "Sonne"; site body "Mösching’s Sonne"). Ling Ling after Nov 5, 2026; Colani Bistrot Nov 27; After Seven Dec 2; Scalottas Terroir Dec 9; Ô Bois Sauvage and The Grill at Amangani Jan 2027. No scheduled task holds these dates.

## Open items (Swiss)
1. Worldwide alias check (262 aliases; Swiss suspects: `grisons`, `sankt niklausen`, `silvaplana`, `lens`, `sorengo`).
2. Slugs with letters removed outside Switzerland, for example `s-ller-d-kro`, `b-st`, `r-st`, `restaurant-frederiksh-j`. Not counted. Ben decides if and when.
3. The Cheval Blanc blurb is `needs_rewrite`.
4. Michelin 2025 Swiss rows other than the 4 backfilled have no URL (the all-guides 2025 URL item).

## Methods (new)
- **Archive replay pages rewrite `fetch()`.** A tab on a `/web/...` page returned HTML for CDX and hid the capture in `response.url`. Open `https://web.archive.org/robots.txt` first, then run CDX and `id_` fetches from that tab.
- **`/us/en/` captures can be old.** The card can carry the 2024 guide there; `/en/` or `/ch/de/` held the 2025 capture. Loop over the language paths until the meta names the wanted guide.
- **Write connector and DELETE:** 5 of 5 cancelled. Try once, read to prove nothing ran, then give the SQL Editor steps and the file. End the file with `SELECT 'OK: all gates passed' AS result;`.
- **Three files in a row:** build each file with the counts that the file before it leaves. Dry run each one after the file before it.

## Suggested opening prompt
```
Read claude/handoff-switzerland-price-backfill-cleanup-done-2026-11-03.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 248,
audit_log 125,593, venues 11,320 (active 11,028, closed 292), awards 25,324, slugs 13,144, price 7,759, closed published 0 and cities.venues_count sum 11,028.
Then start the open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
