# Handoff: OAD 2026 hold rows (second pass), read block, status of 3 venues, write done. Nov 4, 2026 (09:15 Atlanta). Next: Ben chooses.

This file replaces `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md` for the live state and its open items 1, 2 and 4. That file still holds its methods, dead ends and recheck list. `handoff-oad-2026-first-write-done-2026-11-03.md` still holds methods and OAD data limits. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 4)
- 08:54 "1,2, 4" (open items). 09:06 "1A, 2A, 3A, 4A, 5A, 6A". 09:07 "Go".
- 1A = Arnanz and Defune load as closed, conflict rule. 2A = new closed venue Sushi Ichi takes rows 501 and 18993 and the old slug. 3A = rename Yatang and Omino, move Omino to Tokyo. 4A = Japan 180 loads on Kiku Sushi, name and city stay. 5A = Gloria Maris under Manila. 6A = the other 7 rows stay open.

## Live state (read Nov 4, 14:09:17 UTC, whole tables)
Venues **11,593** (active **11,287**, closed **306**). Awards **27,479** (last id **34,650**). OAD 2026 rows **2,857**. OAD 2025 rows 2,437. Slugs **13,443**. Price 7,759. Listings **11,593**. city_label_source **24,593**. city_aliases 222. Redirects **33**. Cities 3,318, `cities.venues_count` sum 11,287. Ledger **237** rows, last id **291**. audit_log **124,343** rows, last id **130,172**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0. Cities with 0 venues 67.

## Done
`docs/open-items-oad-2026-holds-status-2026-11-04/cleanup-oad-2026-holds-status-2026-11-04.sql` (sha256 `7f46307eafe8d6e40a77a9bf8df5c07050f584f14743d40310402b1736e13ba2`). Write connector, first try, committed Nov 4 14:08:50 UTC. 1 transaction, all gates passed.

Evidence: `oad-2026-holds-status-evidence-2026-11-04.csv` in the same folder (19 rows, sha256 `e996a5191419783a6abf39221099e353f450116953196aa34c89ee729219891e`). Scripts: `evidence.py`, `build_sql.py`.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

| Item | Change | Ids |
|---|---|---|
| New OAD 2026 rows | 9 (Asia 3, Europe 2, Japan 4) | Awards 34,642-34,650 |
| OAD 2025 row moved | 18993, Ginza Fukuju to Sushi Ichi | |
| New venues | 6 (3 active, 3 closed) | See below |
| Closures | Testina, Art di Daniele Sperindio, Sustanza. Closed and not published | |
| Renames | Yatang to Jing Yaa Tang, Omino to Omino Kamiyacho. Old slugs stay non-canonical | Batch 50 |
| City move | Omino Kamiyacho, Yokahama to Tokyo | Redirect `/yokahama/omino` to `/tokyo/omino-kamiyacho` |
| Slug moved | `tokyo/ginza-sushi-ichi-singapore`, non-canonical, Ginza Fukuju to Sushi Ichi | |
| Ledger | 286-291 | |
| audit_log | 130,111-130,172 (62) | |

**New venues:**
- Active: Tempura Tenon `ve_d95cfc1527` (Hong Kong, Asia 283). Gloria Maris Shark's Fin Restaurant `ve_c95a515c56` (Manila, Asia 494, real place Greenhills, San Juan). Koide `ve_7718ced788` (Kanazawa, Japan 460).
- Closed, not published: Arnanz `ve_c701fffdf6` (Madrid, Europe 403). Defune `ve_857b831b9a` (London, Europe 534). Sushi Ichi `ve_e77a92118c` (Tokyo, Japan 501 and 2025 rank 455).

**Rows on live venues:** Jing Yaa Tang `ve_84687b6ab6` (Asia 486). Omino Kamiyacho `ve_ebb1779b86` (Japan 462). Kiku Sushi `ve_515b6a646f` (Japan 180).

**Finding:** the OAD 2025 lists print the same name, chef and slug as the 2026 rows for all 3 "not proven" rows. Omino rank 518 and Yatang rank 384 had Sheet names. This proves the award, not always the place.

**Cause of row 18993:** Sep 9 merge. Duplicate venue `ve_08b33b0bd9` "Ginza Sushi Ichi Singapore" in Tokyo went into Ginza Fukuju (audit 85322, 85363, 85380). The same transaction moved 25 awards and 21 slugs and deleted 20 venues (audit 85,298-85,383). The other 24 awards were not read.

**Weak points:**
- Sushi Ichi: phone and address not found. Tabelog Ginza Sushi Ichi Honten is on hold and also says relocated and resumed. OAD chef Ishibashi went independent in 2017.
- Kiku Sushi: OAD prints Nagoya. OAD phone is Iizuna, Nagano. Tabelog names chef Yusuke Seguchi at Kikuzushi in Kasuga, Fukuoka. Live city stays Nagano.
- Gloria Maris: no dated 2026 read.
- Koide: phone match only, address differs, chef not named.

**Not checked:** the live site. This session did not read a page or a deploy.

## Open items
1. **Hold rows, 7 (no write, was 13; Ben 6A).** Tempura Kusunoki Yotsuya (Japan 469), Sushi Ueda Osaka (Japan 561), Kikuzushi Kitakyushu (Japan 611), Miyaba (Japan 647), Meimon (Japan 675), Tsubomi (Japan 712), Sushi Takumi (Japan 755). Reason for each: evidence CSV.
2. **Rename batch.** From the last handoff. Count again.
3. **44 closed venues OAD 2026 still prints,** plus Restoran Alexander, Chiba Takaoka, Sorrel, Quattro Passi. Count again. Sustanza, Testina, Art di Daniele Sperindio, Arnanz, Defune, Sushi Ichi now also hold a 2026 row and are closed.
4. **New cities, 37.** Region NULL, no lat/lng. Live city `otsu` shows display "otsu". `yokahama` (misspelled) keeps 1 active venue.
5. **From the last handoffs, unchanged.** Item 7 of `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md`.
6. **Michelin Kuala Lumpur & Penang 2027, to ingest.** Item 8 of the same file. Not started.

## Recheck list (no scheduled task holds these dates)
All items of the last handoff, less Sustanza, Testina, Art di Daniele Sperindio as open status questions, plus:
- Art di Daniele Sperindio: Jan 2027. Spirited, Sep 21, 2026: reopens at METT Singapore at the end of this year. New address 11 Canning Walk.
- Arnanz: Michelin `us/en` card 404, control DiverXO 200. Added by Michelin about Sep 2025. No closure report found. Own site did not load.
- Defune: Harden's prints closed and open hours. Own site not reachable.
- Sushi Ichi, Kiku Sushi place, Gloria Maris (as above).
- Jing Yaa Tang: Michelin `us/en` card 404, own hotel page read as open on Nov 3.

## Methods (new)
- **Search the chef in Japanese.** 瀬口 祐介 found Kikuzushi in Kasuga when the phone and address did not.
- **Compare the OAD chef with other rows in the list.** Miyaba, Meimon and Tsubomi print the chef of a live venue in the same list.
- **`spiritedasia.com` loops in the fetch tool.** The built-in browser reads it.
- **Michelin card test:** `fetch(path)` from a tab on guide.michelin.com, with a control card. Use `us/en`. `es/es` gave a 404 for the control too. A fetch tool read of a card can show an old copy: Testina showed live in the fetch tool and 404 in the browser.
- **The Write connector worked first try** with a file of about 17 KB.

## Dead ends: do not retry
- `www.arnanz.world` in the built-in browser: load failed.
- Bloomberg, Yelp, Facebook, Falstaff, Rappler in the fetch tool: refused.
- `openrice.com` `/menus` path: security check, as before.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-holds-status-done-2026-11-04.md from the project files, then
claude/handoff-oad-2026-holds-summer-palace-done-2026-11-04.md for the other open items and methods,
claude/handoff-oad-2026-first-write-done-2026-11-03.md for OAD data limits, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 291, audit_log 130,172, venues 11,593 (active 11,287, closed 306), awards 27,479,
OAD 2026 rows 2,857, OAD 2025 rows 2,437, slugs 13,443, price 7,759, city_aliases 222, redirects 33, closed published 0 and
cities.venues_count sum 11,287. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Then ask me which open item is next. No write before my "go".
```
