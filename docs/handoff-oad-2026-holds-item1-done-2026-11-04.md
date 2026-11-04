# Handoff: OAD 2026 hold rows (third pass), write done. Rename and closed-venue populations counted. Nov 4, 2026 (09:45 Atlanta). Next: items 2 and 3.

This file replaces `handoff-oad-2026-holds-status-done-2026-11-04.md` for the live state and its open items 1, 2 and 3. That file still holds the recheck list and its methods. `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md` holds methods, dead ends and open items 7 and 8. `handoff-oad-2026-first-write-done-2026-11-03.md` holds OAD data limits. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 4)
- 09:34 "choices 1-5 = A". 09:43 "go".
- 1A = rank 469 second row on Kusunoki. 2A = rank 755 new venue Sushi Takumi, Tokyo, active. 3A = the other 5 rows stay open. 4A = item 3 reads the 26 weakest venues only. 5A = item 1 write, then a handoff break before items 2 and 3.

## Live state (read Nov 4, 14:44:10 UTC, whole tables)
Venues **11,594** (active **11,288**, closed **306**). Awards **27,481** (last id **34,652**). OAD 2026 rows **2,859**. OAD 2025 rows 2,437. Slugs **13,444**. Price 7,759. Listings **11,594**. city_label_source **24,595**. city_aliases 222. Redirects 33. Cities 3,318, `cities.venues_count` sum **11,288**. Ledger **239** rows, last id **293**. audit_log **124,351** rows, last id **130,180**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0. Cities with 0 venues 67.

## Done
`docs/open-items-oad-2026-holds-names-closed-2026-11-04/cleanup-oad-2026-holds-item1-2026-11-04.sql` (sha256 `d181ab1c53072468f029a4af337f9e8b58de7903f755950fd473ecf033cbeda2`). Write connector, first try, Nov 4 about 14:44 UTC. 1 transaction, all gates passed.

Evidence: `oad-2026-holds-item1-evidence-2026-11-04.csv` in the same folder (7 rows). Script: `build_item1.py`.

| Item | Change | Ids |
|---|---|---|
| New OAD 2026 rows | 2 (Japan) | Awards 34,651 (rank 469), 34,652 (rank 755) |
| Second row | Kusunoki `ve_a1fee2bf94` now holds Japan 26 and 469 | |
| New venue | Sushi Takumi `ve_60b541e3e7`, Tokyo, active, published, slug `tokyo/sushi-takumi` | |
| Tokyo count | 673 to 674 | |
| Ledger | 292-293 | |
| audit_log | 130,173-130,180 (8) | |

**Weak points:**
- Rank 469: OAD and Omakase prove the house. The phone was not found. Tabelog Magazine (Mar 2025) says Hashimoto moved to the Nakameguro shop, so the printed row can be stale.
- Rank 755: name and chef match the own site, Ikyu and Tabelog at 2-20-3 Higashi-Azabu. OAD address is Sushi Sho Yotsuya. OAD phone not found. A second Sushi Takumi (すし卓海, Kagurazaka, 03-5946-8499) exists, chef not read.

**Not checked:** the live site. This session did not read a page or a deploy.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

## Open items
1. **Hold rows, 5 (no write; Ben 3A).** Sushi Ueda Osaka (Japan 561), Kikuzushi Kitakyushu (Japan 611), Miyaba (Japan 647), Meimon (Japan 675), Tsubomi (Japan 712). Reason for each: the evidence CSV. Do not read these again without a new route.
2. **Rename batch (next).** Population read Nov 4 from live tables: `rename-population-2026-11-04.csv`, 266 venues, no venue in 2 groups. Count again first and show the count before the reads.

| Group | Venues | Earlier read |
|---|---|---|
| 1 Own spelling on the Nov 3 no-live-venue write (of 258 new venues) | 83 | 58 words differ, 25 case or marks only |
| 2 New venues of the Nov 3 read-block write | 22 | 10 words differ, 6 same, 6 no read |
| 3 New venues of the last 2 writes before this one (14 + 6) | 20 | 6 words differ, 2 case or marks only, 6 same, 6 no read |
| 4 Name candidates | 141 | Not read. 89 hold only Michelin rows. 85 hold a Michelin row with a URL |

   - The earlier handoffs said "about 40" for group 1 and "145" for group 4. The "about 40" has no recorded test. Group 1 here is every earlier read name that differs from the live name.
   - Group 4 test (same as Nov 3): `name LIKE '%|%' OR length(name)>50 OR name ~* '(michelin|étoilé|stell[ae] |prenotato|best restaurant|menú degust|restaurante? (gastronomique|gastronómico))'`. Result: "|" 70, words 44, over 50 characters 59. 2 are closed.
   - Sushi Takumi was not added to the file: it holds its own spelling.
   - Rulings: memory `learnings.md`, Sep 14 and Oct 10. Publisher suffix never joins the name. Majority of publishers sets the spelling (Google has no vote). A 1-1 tie goes to the own site, else the name stays and the pair comes to Ben. A single publisher sets the name minus any suffix. When in doubt, favor the venue's own spelling, with Michelin as the fallback. Never cut at a dash automatically: confirm against the own site.
   - **Note:** earlier read names came from reads for status, not for spelling. Many are descriptive ("Quanjude Roast Duck (Shuaifuyuan, Wangfujing branch)"). They are leads, not proposals.
3. **Closed venues OAD 2026 prints.** Evidence: `oad-2026-closed-venues-evidence-2026-11-04.csv`, 80 rows on 80 venues. List: Europe 24, Asia 22, Japan 16, no URL 18. The earlier count (44 + 10) left out 8 closed new venues of later writes and the 18 rows with no URL. All stay closed (Ben's earlier choice). Read only for a status change.
   - **Ben 4A: read the 26 weakest:** sweep groups `7 Card or listing only` (13), `9 Conflict` (8), `11 Not found` (5). Filter the CSV on `sweep_group`.
   - Other groups: Closed 19, Temporary closure 8, Undated site 2, Ended or moved 2, Possible twin 1, Status problem 1, Moved 1, not in the sweep 20. For the 20 not in the sweep, the stored evidence line is a best match from repo files: check it first.
   - Quattro Passi, Restaurant Pages, Contaminazioni are closed and also hold a Michelin 2026 row.
4. **New cities, 37.** Region NULL, no lat/lng. Live city `otsu` shows display "otsu". `yokahama` (misspelled) keeps 1 active venue (read Nov 4).
5. **From the last handoffs, unchanged.** Item 7 of `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md`.
6. **Michelin Kuala Lumpur & Penang 2027, to ingest.** Item 8 of the same file. Not started.

## Recheck list (no scheduled task holds these dates)
All items of `handoff-oad-2026-holds-status-done-2026-11-04.md`, plus: Sushi Takumi (OAD phone and address differ). Kiku Sushi `ve_515b6a646f`: OAD chef Yusuke Seguchi, Tabelog places him in Kasuga, Fukuoka; rank 611 prints Yusuke Saguchi; 菊鮨 in Yahatanishi, Kitakyushu is another shop with no chef named. Sushi Dokoro Miyaba: Tabelog title says Closed, reviews Feb 2026.

## Methods (new)
- **OAD chef and cuisine can be copied from another row.** Miyaba, Meimon and Tsubomi print the chef of a live venue. Do not treat the OAD chef on these rows as proof.
- **Compare OAD pages of a near name.** `fetch('/restaurant/<slug>')` from a tab on oadguides.com for 9 pages in one call. The same Arakicho address on Kusunoki and Kusunoki Yotsuya (Hashimoto) settled rank 469.
- **Own domain search.** A search on the chef name in Latin letters found `sushitakumitokyo.com`. Then Ikyu gave the Japanese chef name.
- **Omakase English page** opens in the fetch tool. The `/ja/` page gives a client error.
- **Group 4 Michelin names can come in bulk.** 85 candidates hold a Michelin URL. Not tried: `fetch(path)` from a tab on guide.michelin.com, as in the card test.
- **A result too large for the chat is saved to a file.** Add a padding column to force this when a script needs the rows without retyping.
- **Evidence from the repo by id:** a regex of the venue ids over `docs/` found the sweep rows for 60 of 80 venues.

## Dead ends: do not retry
- `miyaba.jp` in the built-in browser: load failed. `sushidokoro-miyaba.com` and `kusunoki-official.co.jp/gallery/193` in the fetch tool: client error. `omakase.in/ja/...` in the fetch tool: client error. `map.yahoo.co.jp` in the fetch tool: robots.
- A web search for a phone number in quotes: unrelated results.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-holds-item1-done-2026-11-04.md from the project files, then
claude/handoff-oad-2026-holds-status-done-2026-11-04.md and claude/handoff-oad-2026-holds-summer-palace-done-2026-11-04.md for methods, dead ends and the recheck list,
claude/handoff-oad-2026-first-write-done-2026-11-03.md for OAD data limits, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 293, audit_log 130,180, venues 11,594 (active 11,288, closed 306), awards 27,481,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,444, price 7,759, city_aliases 222, redirects 33, closed published 0 and
cities.venues_count sum 11,288. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block. It is not merged to main.
Then work on open items 2 and 3 of the handoff, in this order:
2. Rename batch: count the 4 groups again from rename-population-2026-11-04.csv and live tables, and show me the count by group before you read each name. Apply the name rulings of Sep 14 and Oct 10.
3. Closed venues: read the 26 weakest venues only (Ben 4A), only for a status change.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go". Use a separate file and a separate "go" for each item.
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
