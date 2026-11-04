# Handoff: OAD 2026 no live venue, write done. 281 new rows, 258 new venues. Nov 3, 2026 (22:15 Atlanta). Next: Ben chooses.

This file replaces `handoff-oad-2026-no-live-venue-ready-2026-11-03.md` for the live state and open item 1. That file still holds the details of the 311 rows and the methods. `handoff-oad-2026-first-write-done-2026-11-03.md` still holds open items 2 to 5, methods and OAD data limits. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 22:06 "1A, 2A, 3A, 4A, 5A, 6A". 22:10 "Go".

## Live state (read Nov 4, 03:12:16 UTC, whole tables)
Venues **11,594** (active **11,297**, closed **297**). Awards **27,399** (last id **34,570**). OAD 2026 rows **2,777**. OAD 2025 rows 2,437. Slugs **13,442**. Price 7,759. Listings **11,594**. city_label_source **24,595**. city_aliases 222. Redirects 13. Cities **3,308**, `cities.venues_count` sum **11,297**. Ledger **218** rows, last id **272**. audit_log **123,642** rows, last id **129,471**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/open-items-oad-2026-no-live-venue-2026-11-03/load-oad-2026-no-live-venue-2026-11-03.sql` (sha256 `9559760c48cc0a7960c54985b037e0fc648c7210c12488779f1f70123585fdad`). Write connector, first try, 1 transaction, all gates passed. Commit time Nov 4, 03:11:51 UTC.

| Item | Before | After | Ids |
|---|---|---|---|
| Venues | 11,336 | 11,594 | 258 new (255 active and published, 3 closed and not published) |
| Awards / OAD 2026 | 27,118 / 2,496 | 27,399 / 2,777 | Asia 34,290-34,357 (68). Europe 34,358-34,422 (65). Japan 34,423-34,570 (148) |
| Slugs / listings | 13,184 / 11,336 | 13,442 / 11,594 | |
| city_label_source | 24,079 | 24,595 | |
| Cities / sum | 3,281 / 11,042 | 3,308 / 11,297 | 27 new, 54 count updates |
| Ledger rows | 214 | 218 | 269 Asia, 270 Europe, 271 Japan, 272 city labels |
| audit_log rows | 121,990 | 123,642 | 127,820-129,471 (1,652) |

Audit by table: cities INSERT 27 (127,820-127,846). cities UPDATE 54 (127,847-127,900). venues INSERT 258 (127,901-128,158). listings INSERT 258 (128,159-128,416). slugs INSERT 258 (128,417-128,674). city_label_source INSERT 516, by hand (128,675-129,190). awards INSERT 281 (129,191-129,471).

No change to price, redirects, city aliases or OAD 2025 rows.

Sushi Riku `ve_45cd61d911` holds 2 rows: Japan 372 (award 34445), Japan 630 (award 34494).

**Closed new venues, not published:** Wine RVLT `ve_67409605cb`, Urchin `ve_7dbaa865fb`, Tokyo Shiba Tofuya Ukai `ve_4b8fe39a82`.

**Repo:** branch `oad-2026-no-live-venue` merged to `main` by fast-forward at `da51f29`. The branch still exists on GitHub. This handoff is one more commit on `main`.

**Not checked:** the live site. This session did not read a page or a deploy. 255 new venues have `published` = true. They have no price, address, geo, blurb or chef. Ben can open one new venue page to see how the site shows it, for example `tokyo/sushi-riku`.

## Result of the 311 rows
281 rows loaded. 30 rows held, with no write. Evidence: `oad-2026-no-live-venue-evidence-2026-11-03.csv` (311 rows), CSV column `group`.

## Open items
1. **Hold rows, 30 (no write).** Conflict: Defune, Bangkok Bold Kitchen, Hisada, Kappo Yoshida, Sushi Takumi. Could be a live venue: Tempura Kusunoki Yotsuya, Tempura Yokota. City not proven: Katatsumuri, Kikuzushi. Possibly gone: Pirouette, Gloria Maris. Identity low: Arnanz, Tempura Tenon, Uran, Yakiniku Kousen, Koide, Kimiya, Sushi Ichi, Miyako Zushi, Sushi Ueda, Romantico, Hamagen, Miyaba, Meimon, Arakawa, Mudai, Tsubomi, Seto, Sushi Hachiya, Shangu.
2. **Separate read block, from the first-write handoff.** 53 hold rows, 4 move rows, 34 OAD 2025 rows on the wrong venue, bad live names.
   Changes to the 34 rows:
   - 2025 row 18833 on Taichi is correct (Ichita is Taichi).
   - 2025 row 18950 on Chiba Takaoka is correct (Sushi Takaoka).
   - 2025 row 18418 sits on ESSE. ES (Paris) is the correct live venue.
   - 2025 row 18761 sits on Kaiten Sushi Ginza Onodera. Ode (Tokyo) is the correct live venue.
   New bad live names: Toritama `ve_f0f0978f15` holds "Toritama | Yakitori | Michelin | Curated". LV The Place `ve_21bab3c06d` holds a long name.
3. **Rename batch.** About 40 OAD own spellings on the new venues wait for a later rename batch (Ben 5A).
4. **Status (from the first-write handoff).** OAD prints Sustanza and Testina as closed, Art di Daniele Sperindio as temporarily closed. Live status is active.
5. **44 closed venues OAD 2026 still prints.** Ben 3A of the first write kept them closed. Restoran Alexander and Chiba Takaoka now also hold a 2026 row and stay closed.
6. **New cities, 27.** Region NULL, no lat/lng.
7. **From the last handoffs, unchanged.** Carmen Medellín `ve_6cd9c1b505`. Merged venues left as they are (Restaurant Wörgötter, Schlosskeller Südsteiermark, Fagn, Vyn Restaurant). Missing 2025 rows, 22 venues. 26 aliases with a venue under a neighbor city. 48 Swiss 2025 rows with no capture. 3,028 Michelin 2025 rows with no URL. 140 blurbs `needs_rewrite`. New checks on Kioicho Mitani, Yamazaki `ve_61cf53898d`, Sushi of Gari 46, Forbes pages for Masa.

## Recheck list (no scheduled task holds these dates)
From the first write: Sonne Scheunenberg `ve_1ff8df1642` (Ben opens the site). Ling Ling after Nov 5, 2026. Colani Bistrot Nov 27. After Seven Dec 2. Scalottas Terroir Dec 9. Ô Bois Sauvage and The Grill at Amangani Jan 2027. Mitani, Yakitori Kurosaki status. Sustanza, Testina, Art di Daniele Sperindio.

From this write: Urchin (autumn 2026, Ben 6A: closed until a read shows that it reopened). Tokyo Shiba Tofuya Ukai (permanent or rebuild). Aoyama Sushi Kanesaka (TableCheck: leaves its site on January 2, 2027, new address not announced). Alexander (Pädaste Manor closed, no date). Status not read (10): Brutalisten, Yoshinobu, Pauli, Sushi Zo Hong Kong, Sarong Bali, Yoshii (Tabelog: no new reservations), Isoda, Sushi Fujinaga, Ippongi Ishibashi, Ichibancho Teruya. Weak proof (8): Hôtel Costes Restaurant, Cafe Japan, Azabu 10, Kojimachi Nihee, Tempura Matoba, Hiroyuki, Kizushi, Sushidokoro Tada.

## Methods (new)
- **The `ready` handoff gives the file size as 25,874 bytes.** That number is characters. The file has 25,887 bytes. Use the sha256, not the size.
- **Compact plan text with md5 gates went through the Write connector on the first try.** The file holds BEGIN and COMMIT, and the last SELECT gives the result line.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-no-live-venue-done-2026-11-03.md from the project files, then
claude/handoff-oad-2026-first-write-done-2026-11-03.md for open items and OAD data limits, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 272,
audit_log 129,471, venues 11,594 (active 11,297, closed 297), awards 27,399, OAD 2026 rows 2,777, slugs 13,442, price 7,759,
city_aliases 222, redirects 13, closed published 0 and cities.venues_count sum 11,297. Then ask me which open item is next.
No write before my go.
```
