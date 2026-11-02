# Handoff: closed-venue sweep item 3 done. 3 venues active, 1 stays closed. Nov 2, 2026 (16:35 Atlanta).

This file replaces `handoff-closed-sweep-item7-done-2026-11-02.md` for live state. That file still holds the recheck list of item 7, which starts with **Ling Ling after Nov 5, 2026**. `handoff-closed-sweep-item6-done-2026-11-02.md` holds the older recheck groups. `handoff-closed-sweep-twins-renames-done-2026-11-02.md` holds the rechecks from items 1 and 2. `handoff-closed-sweep-201-done-2026-11-02.md` holds items 4 and 5. The closed rule and the oldest recheck list are in `handoff-closed-rule-done-2026-11-02.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Trusted sources: `trusted-websites.md`.

## Ben's input (ET, Nov 2)
- 16:25 "1A, 2A, 3A, 4A, 5A".
  - 1A = Scalottas Terroir active now.
  - 2A = Suetomi active now.
  - 3A = tsushimi active, new city Nirasaki with no region and no coordinates, name `Tsushimi` as OAD prints it.
  - 4A = The Grill at Amangani stays closed, recheck Jan 2027.
  - 5A = new open item: read a sample of 10 of the 34 Group 3 venues again.
- 16:29 "Go".

## Live state (read Nov 2, 21:30:45 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,293 (active **10,999**, closed **294**) |
| closed venues published / not published | **0 / 294** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs | **13,022** (canonical 11,293, non-canonical 1,729) |
| price | 7,727 |
| listings / cities | 11,293 / **3,265** |
| city labels | 23,989 |
| cities.venues_count | sum **10,999**; 0 cities differ from the view |
| rename_batches / rename_rows | **29 / 1,301** (last batch id 44) |
| source_capture_ledger | 186 rows, last id **238** |
| audit_log | **118,857** rows, last id **124,371** |

## Done
`docs/fix-closed-sweep-item3-2026-11-02.sql` (sha256 `0bf27a93...200805`). Write connector, first try, 21:30:26 UTC. Audit 124,359-124,371 (cities INSERT 1 and UPDATE 2, listings UPDATE 3, slugs INSERT 1 and UPDATE 1, venues UPDATE 5). No ledger row. Run record `docs/closed-sweep-2026-11-02/run-sweep-item3-2026-11-02.txt`.
Evidence for all 4: `docs/closed-sweep-2026-11-02/closed-sweep-item3-evidence-2026-11-02.csv` (sha256 `87ff1d68...fb340d`).

## Result
| Venue | Id | Result | Main evidence |
|---|---|---|---|
| Scalottas Terroir | `ve_fae8dcb6f0` | Active, Lenzerheide (0 to 1) | Own site: Voa Principala 29, closes end of October, back "ab dem 9. Dezember" (no year). Seasonal closure is active. The Nov 2 Scharans match was wrong: that page is Stiftung Scalottas, a different restaurant |
| Suetomi | `ve_779a1ac27f` | Active, Tokyo (594 to 595) | TABLEALL course from Nov 10, 2026. Tabelog newest visit August 2026 |
| Tsushimi | `ve_001296abf4` | Active, new city Nirasaki `ci_1890364073` (count 1), renamed from `tsushimi フレンチ`, batch `rename-closed-sweep-item3-2026-11-02` | Omakase and Gault&Millau 2026: Nirasaki, Yamanashi. Bookings to Dec 31, 2026 |
| The Grill at Amangani | `ve_8d69af215c` | Closed (no write) | Aman: "currently closed while it undergoes an extensive refurbishment". About Travel (Oct 29, 2026) and TTN (Nov 2026): reopening 2027. The Nov 2 seasonal read was wrong |

## Recheck list from item 3
| Venue | Id | Recheck after |
|---|---|---|
| Scalottas Terroir | `ve_fae8dcb6f0` | **Dec 9, 2026.** The reopening post has no year. Claude added this date; Ben has not objected |
| The Grill at Amangani | `ve_8d69af215c` | **Jan 2027.** Name can change, because the renovation renews the dining venues |

No scheduled task holds these dates. Read this table and the item 7 table at each start.

## Limits
- The page reads came through the web-fetch tool, as short reports, not raw pages.
- Scalottas Terroir: no dated page shows 2026 service. The 2026 and 2027 strings are in image file names only. The hotel season dates fit 2026 and also 2020.
- Suetomi: the OAD page for this venue was not opened. The Mita address is on one Foodle page only. 膳処末富 (Azabu-Juban, closed, chef 末富信) is a different venue.
- Tsushimi: OAD prints Tokyo, rank 633 with no year. The database row is No. 538 for 2025. `city_label_source` keeps "Tokyo".
- Dry run: a shorter copy with the start gates and one test insert. End gates ran only in the real transaction, and they passed.

## Found, no change made
- **Tsushimi and later OAD loads:** a load that labels this venue Tokyo can fail to pair by city and can make a duplicate. Read this before the next OAD Japan load.
- **OAD Japan 2026:** the database holds 616 OAD rows for Japan, all from 2025. It holds 701 OAD 2026 rows in total. None are in Japan, Korea, China, Thailand, Singapore or Hong Kong. Foodle shows Suetomi at No. 51 for 2026, but Foodle is not an award source.
- **Green Star:** the Arosa Lenzerheide page says Scalottas Terroir holds one, with no year. The Michelin card read showed no distinction. The venue has no Michelin row. Add it to the Swiss Green Star file list.
- **Native names:** Suetomi `末冨` (Tabelog, TABLEALL; Foodle also uses 末富). Tsushimi `ツシミ`. `name_native` not written.

## Open items
1. **Group 3 sample (Ben 5A):** read 10 of the 34 Group 3 venues again. Population and evidence: Group 3 of `closed-sweep-201-evidence-2026-11-02.csv`. Reason: 2 of the 4 Group 5 reads were wrong. Group 3 has the weakest evidence of the 63. Those 2 errors do not prove an error in Group 3. Set a seed and record it.
2. **Item 4:** possible missing Michelin rows (Hakusi, Schlossherrnstube, Flora, CUR8, Kinship, Mural Farmhouse). Details in `handoff-closed-sweep-201-done-2026-11-02.md`.
3. **Item 5:** names (Paznauerstube, Eat and Cook - Best Fine Dining KL, Amal Restaurant Armani Hotel - Burj khalifa, Flora (Food & Wine), Restavracija Lesnika).
4. **OAD Japan 2026:** read whether the list exists and is missing. Ben decides when.
5. Switzerland still waits for Ben's "results live".

Items 1, 2, 3, 6 and 7 of the sweep are closed.

## Methods (new)
- **Same-name trap:** a page with a shared word in the name can be a different venue. Open the page and match the address, the chef and the town.
- **Resort page:** read the resort home page as well as the dining page. The Amangani dining pages still describe service, and the home page states the closure.
- **Before the "go":** the repo stop check asks for a commit of new files. Branch `closed-sweep-item3-pre-go` held them, and it was merged after the run.
- **Column names:** `cities` has `display`, not `name`. `city_kind` needs a cast to text in a UNION.
- **Rename trigger:** `trg_venue_rename` only blocks a name change unless `app.allow_rename` is on. `norm_key` is a generated column.
- **Slug rule on a city move:** old slug stays non-canonical, new slug is canonical.

## Suggested opening prompt
```
Read claude/handoff-closed-sweep-item3-done-2026-11-02.md from the project files, then
claude/handoff-closed-sweep-item7-done-2026-11-02.md for the recheck list,
claude/handoff-closed-sweep-201-done-2026-11-02.md for items 4 and 5, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 238,
audit_log 124,371, venues 11,293 (active 10,999, closed 294), awards 25,097, slugs 13,022, price 7,727, closed published 0 and cities.venues_count sum 10,999.
Then start the Group 3 sample of 10, or the next open item I name. Show me in /ste style the evidence and ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
