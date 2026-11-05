# Handoff: 2026 editions of 50 Best and Spirited, write done. 315 rows, 28 new venues. Nov 5, 2026 (16:30 Atlanta). Next: Top 500 Bars 2026.

This file replaces `handoff-launch-list-radar-done-2026-11-05.md` for the live state and open item 1 (first four guides). That file still holds the radar, the research run, its other open items and its findings. Launch list: `launch-list-2026-11-05.md`. Live-site finding and goals: `handoff-oad-2026-small-fixes-done-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 16:23 "1A, 2A, 3A, 4A, 5A". 16:25 "Go".

## Live state (read Nov 5, 21:27:50 UTC, whole tables)
Venues **11,623** (active **11,320**, closed 303). Awards **27,796** (last id **34,967**). OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,567** (canonical 11,623). Price 7,759. Listings **11,623**. city_label_source **24,653**. city_aliases 222. Redirects 35. Cities **3,319**, `cities.venues_count` sum **11,320**. Ledger **250** rows, last id **304**. audit_log **125,306** rows, last id **131,135**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/open-items-50-best-spirited-2026-2026-11-05/load-50-best-spirited-2026-2026-11-05.sql` (sha256 `a849bb910cf7a9081212b4c700d2573040ff922f70e60c92d7d4c39f430f7e7e`). Write connector, first try, 1 transaction, all gates passed.

The file on the branch is the text that ran. The version shown to Ben before "go" (sha256 `30a827ee...34d8d`) listed the 250 live venue ids in the fingerprint gate. The text that ran reads the same ids from the plan rows, and the md5 result is the same. No other line differs.

| List, year 2026 | Rows | Award ids | Rows with rank |
|---|---|---|---|
| asia-50-best-bars | 100 | 34,653-34,752 | 100 |
| spirited-awards | 15 | 34,753-34,767 | 0 |
| worlds-50-best-bars | 100 | 34,768-34,867 | 100 |
| worlds-50-best-restaurants | 100 | 34,868-34,967 | 100 |

Population: 315 rows, all with `source_url`. Form: `No. N` and rank for 50 Best, category with no rank for Spirited.

| Item | Change |
|---|---|
| New venues | 28, all bar, active, published. No price, address, geo, blurb or chef |
| New city | Galle (Sri Lanka). Region NULL, no lat/lng |
| Cities updated | 21 count updates |
| Ledger | 298-301 award, 302-304 city_label |
| audit_log | 130,659-131,135 (477). cities INSERT 1, cities UPDATE 21, venues 28, listings 28, slugs 28, city_label_source 56 (by hand), awards 315 |

**New venues:** Montana, Mius (Hong Kong). G.O.D, Aqua Bar (Bangkok). Bar Gabriel (Istanbul). Naked (Athens). Otro Bar (San José, Costa Rica). Three Horses (Melbourne). La Borracha (Accra). Obsidian Bar (Shenzhen). Pony Up (Shanghai). CMYK (Changsha). M+MS Bar (Seoul). Problem Child, The Spirits Library (under `manila`, label Makati). Tiao, Bar Long Fong (Beijing). BOP, Bar Bon Funk (Singapore). Cabinet 8 (Kuala Lumpur). Between the Sips, Hats Bar (Jakarta). The Bar at the Ritz-Carlton Tokyo (Tokyo). Aabbcc (New Delhi). Chimney (Hangzhou). Ropewalk (Galle). Cobra (Columbus). Bryant's Cocktail Lounge (Milwaukee).

**No change to:** names, status of a live venue, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `50-best-spirited-2026-evidence-2026-11-05.csv` (315 rows, sha256 `a173451c93c69e933cb3482e2a1f7ff020831549aa9fb63f728d74a1631202cf`). List read: `lists-raw.json`. Scripts in run order: `spirited.py`, `match.py`, `m2.py`, `m3.py`, `m5.py`, `build.py`, `build_sql.py`.

## Decisions (Ben, all A)
1. 28 new venues, active and published, 1 new city.
2. `source_url` = publisher list page or article. The the50.com list pages can show the 2027 list next year. Earlier lists sit at `.../previous-list/<year>`.
3. No rename now. 63 publisher names differ from the live name in more than case or spacing: CSV, `publisher_name` and `live_name`. Later rename batch.
4. Left out: 14 Spirited categories for people, books, brands and media, and the 36 entries of the 50 Best "Individual Awards" pages.
5. Hand matches accepted: Connaught Bar to The Connaught Bar. Moebius Milano to the bar venue. Bar Carmen to Carmen Medellín `ve_6cd9c1b505`. MO Bar Shenzhen. Coa (Shanghai). Mil to MIL Centro (Moray). FZN. ViceVersa. Readings: Stay Gold Flamingo on Stay Gold. The Enigma Mansion on Enigma. Bar Bon Funk is new, not Le Bon Funk.

## Weak points
- Status of the 28 new venues: search results, 1 page opened in full. Own sites not opened. CMYK, Obsidian Bar, Chimney, Naked have list coverage only.
- Arca `ve_2a90808d57`: category bar, now also holds World's 50 Best Restaurants No. 87.
- Names to fix first in the rename batch: Hope (Hope & Sesame), The Han-Jia Pairing Dinner 酣呷餐酒, Carmen Medellín (publisher: Bar Carmen).
- `award_categories` has no `No. 51` to `No. 100` for `worlds-50-best-restaurants`. The ingest rule allows an exact `No. N` echo.

## Open items, in order
1. **Top 500 Bars 2026 (next).** About 500 rows. Time Out headline Nov 4 not opened. Check first that 1-100 is complete. Read top500bars.com. Same method.
2. **Rest of the launch list.** See the older handoff, item 2.
3. **Phase 2 publish job.** Goal Nov 29. Not started.
4. **Phase 3 location pass.** Not started.
5. **Plan v1.31.** Add this write.
6. **Research result (after Nov 7).** See the older handoff.
7. **Rename batch.** See decision 3.

## Methods (new)
- **the50.com list read:** open a list page in the built-in browser, `fetch` the path, parse with `DOMParser`. `[data-list]` blocks hold 1-50, 51-100 and Individual-Awards in one page. Each `.list-item` has `.rank`, `h2`, `.item-bottom p`. Asia path is `/bars/best-in-asia/`, not `/bars/asia/` (redirect).
- **theworlds50best.com:** WebFetch stops at the redirect or a block. Use www.the50.com.
- **Compact plan text:** `code|rank|category|venue id without ve_`, with the URL computed in SQL. 300 rows fit in about 8 KB.
- **Fingerprint gate:** read the ids from the plan rows, not a long literal list.

## Dead ends: do not retry
- `awards.source_slug`, `awards.list_year` (columns are `source_id`, `year`).
- curl from the workspace to the50.com or talesofthecocktail.org (blocked).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-50-best-spirited-2026-done-2026-11-05.md from the project files, then
claude/handoff-launch-list-radar-done-2026-11-05.md, claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 304, audit_log 131,135, venues 11,623 (active 11,320, closed 303), awards 27,796,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,567, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,320. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Then work on Top 500 Bars 2026. Read the list from the publisher and check first that it is complete.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
