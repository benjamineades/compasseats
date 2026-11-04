# Handoff: Open items 1, 2, 3 done. A2, A3, Group D. 11 new venues, new city Prato. Nov 3, 2026 (20:55 Atlanta). Next: Ben chooses.

This file replaces `handoff-placeid-tailory-done-2026-11-03.md` for the live state and open items. That file still holds the merge tests and their methods. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 20:28 "1, 2, 3". 20:42 "1A, 2A, 3A, 4A, 5A, 6A". 20:50 "go".

## Live state (read Nov 4, 01:53:43 UTC, whole tables)
Venues **11,336** (active **11,042**, closed **294**). Awards **25,324** (last id 32,495). Michelin 2025 4,996, no URL **3,028**. Michelin 2026 6,524, no URL 434. Slugs **13,184** (canonical 11,336, non-canonical 1,848). Price 7,759 (legacy_guide 2,179). Listings 11,336. city_label_source **24,079**. city_aliases 222. Redirects **13**. Blurbs 142. Cities **3,281**, `cities.venues_count` sum **11,042**, 0 cities differ from `city_venue_counts`. rename_batches 33, rename_rows 1,398. Ledger **211** rows, last id **265**. audit_log **120,196** rows, last id **126,025**. Closed published 0, active not published 0.

## Done
`docs/fix-a2-a3-d-2026-11-03.sql` (sha256 `3054e7787402c2b5e1d8e6710c64f495c9e58afb96b4db5135d6110fbf211615`). Write connector, first try. Audit 125,922-126,025 (104 rows). Ledger 260-265. Fresh clone hash correct.

- **Masa `ve_3246b2089c` (new), New York:** 13 rows and the `$$$$` price left Bar Masa `ve_fbcb833f0c`. OAD 2668, 2670. Forbes 2659-2665. La Liste 2666. Michelin 2667. 50 Best 2672, 2673. No URL on 2660-2665 and 2666. Bar Masa keeps OAD 2669, 2671, with URLs, and has no price row.
- **New venues, 1 OAD 2025 row each, with the list URL:** Da Niko `ve_6ea1945f41` Milan (18439). MOI Omakase `ve_72a5d50fb1` Prato (6339). Buca Yorkville `ve_980121454e` Toronto (17532). Mitani `ve_432649ae04` Tokyo (18648). Yakitori Kurosaki `ve_1223ebdf9d` Tokyo (18695). Yamasaki `ve_310705d6ad` Tokyo (18713). Saeki Hanten `ve_993ab4e428` Tokyo (18846). Jean Georges `ve_6d0cf8a747` Shanghai (18127). Tempura Yamanoue Roppongi `ve_bd0b5ff4e0` Tokyo (19032). Yama no Ue `ve_08699c28d8` Tokyo (19033), **closed, not published**.
- **New city:** Prato `ci_c02c36007b`, region NULL, no lat/lng. Two old non-canonical slug rows of Paca `ve_542c195114` (Carmignano) use city slug `prato`. No clash.
- **Tempura Yamanoue Ginza `ve_5ba6c32664`:** new row 32495, OAD 2026 No. 773, with URL. It is the only OAD 2026 Japan row in the database.
- **Moved venues:** Kabuki Madrid `ve_444325fab9` Milan to Madrid (18573 URL), redirect `/milan/kabuki-madrid`. Carmen `ve_2935ce649e` Lima to Medellín (17958, 17957 URL), redirect `/lima/carmen`. Non-canonical `/lima/restaurante-carmen` row stays. City labels of both stay as OAD printed them.
- **URL only:** Fiesta `ve_6ed52d9126` stays in Lima (17913, 17912). Printed-twice rows stay (Ben 2A): Gari 17234, 17232 on Sushi of Gari 46; Sushi Saito Hong Kong 18027.

Evidence: `docs/open-items-a2-a3-d-2026-11-03/a2-a3-d-evidence-2026-11-03.csv` (34 rows, sha256 `b03aaa17...63c5`), with `build_evidence.py` and `build_fix_a2_a3_d.py`.

## How the proof reads
- **Strong:** Kabuki (OAD page address, Madrid phone, No. 37 in Madrid; Michelin card). Fiesta (OAD page address in Miraflores, Peru). Roppongi (phone match on the owner's site). Masa (Forbes, Michelin and 50 Best print Masa, not Bar Masa).
- **Weak:** Carmen (OAD page has no address; proof is the chef's name and no Lima venue found). Yakitori Kurosaki (Tabelog address differs from OAD; link not proven). Mitani (no status read after 2022; OAD 2026 still lists it; OAD address is Yotsuya). Ben 6A: active.
- Yama no Ue: the owner's site says "Currently closed", no date. Nov 2 rule: closed and not published.

## Open items
1. **OAD 2026 Europe, Asia and Japan not loaded (new).** Population: 701 live OAD 2026 rows before this write, grouped by venue country: all 14 countries are in the Americas. The lists print 774, 590 and 799 restaurants. New venues hold only a 2025 row.
2. **Carmen Medellín `ve_6cd9c1b505` (Ben 5A, held):** bar awards under a restaurant name. 50 Best prints "Bar Carmen". Top 500 Bars name not read. It now sits beside moved Carmen.
3. **Merged venues left as they are:** Restaurant Wörgötter, Schlosskeller Südsteiermark, Fagn, Vyn Restaurant (see last handoff).
4. **Missing 2025 rows:** 22 venues (list in last handoff). Same family as item 6.
5. 26 aliases with a venue filed under a neighbor city: Ben decides if any city split is wanted.
6. 48 Swiss 2025 rows with no capture; **3,028** Michelin 2025 rows with no URL across all guides.
7. 140 blurbs `needs_rewrite`.
8. **New checks not done:** Kioicho Mitani holds La Liste 92/100, not read for which Mitani. Live Yamazaki `ve_61cf53898d` is Koji Yamazaki: OAD prints 7-3-5 Ginza, own site prints Kyobashi. "Sushi of Gari 46" is not the name OAD prints. Forbes 2020-2025 pages for Masa not read.

## Recheck list (unchanged, plus 2)
Sonne Scheunenberg `ve_1ff8df1642`: Ben opens the site. Ling Ling after Nov 5, 2026; Colani Bistrot Nov 27; After Seven Dec 2; Scalottas Terroir Dec 9; Ô Bois Sauvage and The Grill at Amangani Jan 2027. New: Mitani, Yakitori Kurosaki status. No scheduled task holds these dates.

## Limits
- The Sheet and the static `data/` files still hold the old rows. No live page changed.
- New venues have no price, address, geo or blurb (Masa has the price).
- City labels of the new venues use publisher `oad`. Yama no Ue: OAD prints no city; the city comes from the owner's site.

## Methods (new)
- **OAD restaurant pages:** each list row links to `/restaurant/<slug>`. In the rendered list, read `a[href*="/restaurant/"]`. `fetch('/restaurant/<slug>')` from an OAD tab returns the page without a browser render: address, phone, website, rank in city and country. Regex on text: `Address:`, `Telephone:`, `Website:`, `Ranking`. **Use this first for any OAD row in doubt.**
- **OAD page limits:** the page shows the current year only. Two restaurants can share one slug: `sushi-saito` shows Tokyo for the Hong Kong rows; `il-ristorante-niko-romito` shows Beijing for Da Niko. A slug can keep an old name, and a list can show a new name on an old year. A page can be empty (`carmen`).
- **List pages through `fetch` have no rows** (client render). Navigate, then read `innerText`.
- **Do not parse OAD rows with a next-rank counter:** ranks like `59*` stop it (it found 36 of 75). Use a regex over lines with context.
- A city slug can exist on non-canonical rows with no city row (`prato`). The gate needs `is_canonical`. Population: 56 non-canonical rows sit under a city other than the venue's city.
- **Check the award list of the venue, not only the row:** Bar Masa held 11 other Masa rows.
- **Branch before a go:** the stop hook asks for a push of untracked files. Use a branch, merge after the run. Its "no remote branch" message can be stale: check with `git ls-remote`.

## Suggested opening prompt
```
Read claude/handoff-a2-a3-d-done-2026-11-03.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 265,
audit_log 126,025, venues 11,336 (active 11,042, closed 294), awards 25,324, slugs 13,184, price 7,759, city_aliases 222, redirects 13, closed published 0 and cities.venues_count sum 11,042.
Then start the open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
