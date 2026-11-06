# Handoff: Michelin Thailand 2026 label, write done. Nov 5, 2026 (19:00 Atlanta). Next: Thailand 2027 after Nov 10, or Austria now.

This file replaces `handoff-michelin-2027-malaysia-done-2026-11-05.md` for the live state and open item 1. That file still holds the Malaysia method, decisions, hold register and weak points. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 18:56 "1-6 A". 18:57 "Go".

## Live state (read Nov 5, 23:59:51 UTC, whole tables)
Venues **11,673** (active **11,370**, closed 303). Awards **28,368** (last id **35,539**). Michelin 2025 / 2026 / 2027 rows **4,752 / 6,770 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,617** (canonical 11,673). Price 7,759. Listings **11,673**. city_label_source **24,753**. city_aliases 222. Redirects 35. Cities 3,321, `cities.venues_count` sum **11,370**. Ledger **258** rows, last id **312**. audit_log **126,413** rows, last id **132,242**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-thailand-2026-11-05/load-michelin-2026-thailand-2026-11-05.sql` (sha256 `45ce55f36ec40de80e540c5a12b5dabe61d7e1c28d408b381721f5b61cc9a85b`). Write connector, first try, 1 transaction, all gates passed. The text sent left out 4 header comment lines of the file. The executable text is the same.

| Item | Change |
|---|---|
| Relabel | 178 rows, Michelin Thailand, year 2025 to 2026, no URL, retire 0 (rules 2.1.1 and 2.1.7) |
| New awards | 2 rows, year 2026, with the `/us/en/` card URL: 35538 One Star Aksorn `ve_4e1280a372`, 35539 Bib Gourmand Krua Apsorn (Dusit) `ve_b877b4ed0e` |
| New venue | Krua Apsorn (Dusit) `ve_b877b4ed0e`, slug `bangkok/krua-apsorn-dusit`, restaurant, active, published. No price, address, geo, blurb or chef |
| City counts | Bangkok 132 |
| Ledger | 310 relabel, 311 award, 312 city_label |
| audit_log | 132057-132242 (186). awards UPDATE 178, awards INSERT 2, venues 1, listings 1, slugs 1, cities UPDATE 1, city_label_source 2 (by hand) |

Thailand Michelin rows after the write: 2026 labelled 180 (Three Stars 2, Two Stars 8, One Star 33, Bib 137), 2 with a URL. Other years 0.

**No change to:** names, status of a live venue, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-thailand-evidence-2026-11-05.csv`. List read: `relay-th-2026-list-pages-2026-11-05.txt` (sha256 `4baab2de66eb6211ef805d7cb4f86ab7beee02af8cbfd63848b5d1acb2cdaff3`, equal to the browser). Plan: `pairs.tsv`. Live read: `live-read.txt`. Script: `build_sql.py`.

## List check
Population: selection `thailand`, `/us/en/`, built-in browser, Nov 5. 180 rows = page banners 2 / 8 / 33 / 137 = article of Nov 27, 2025 (https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-thailand-2026). All 180 venue pages return 200 and say "2026 MICHELIN Guide". 0 pages say closed. Below Bib, not in scope: the page shows 338 Selected and 518 in total, the article says 288 and 468.

## Label check
Population: Michelin rows on Thailand venues, 178 rows. All pair to a card with the same category and city. Sühring is Three Stars, Anne-Sophie Pic and INDDEE are Two Stars, all 7 named new One Stars are in the rows.

## Decisions (Ben, all A)
1. Run the 2026 step now. Load 2027 as a separate batch after Nov 10.
2. No URL on the 178 relabelled rows. Archive URLs are a later item.
3. Card URL on the 2 new rows. These 2 URLs will repeat on the 2027 rows. Before this batch, 0 Michelin URLs repeat across years. The `url in use` gate of the 2027 file must allow these 2.
4. The 6 weak pairs stay as pairs, and the names go to the rename batch, Baan Pu Karn first: Baan Kun Pra `ve_3a39e62568`, Chai on Sam Chai Alley `ve_52c9ed849e`, Sanae on Sanae' Hotel Nimman `ve_77af594dd0`, So Jeng on `ve_2967137c6f` (the live name names another branch), Jun Hom on Chan Hom Seafood `ve_cf75147034`, Prasit on Pricha Prasit Road `ve_0bea31301b`. Each held 1 award and 0 blurbs.
5. Krua Apsorn (Dusit): new venue, card name, active and published.
6. No rename or price change. 85 names go to the rename batch (79 + the 6 weak). The new venue (card ฿฿) goes to the price item. Population 178 pairs: 0 differ in tier between the legacy symbol and the card.

## Hold register (no rows)
Thailand Green Star list (article says 5): not read. Special awards: not read.

## Weak points
- The 178 rows labelled 2026 have no URL.
- The pair test by address used `data/venues.json` (old site file). Those addresses were not written.
- Card prices are from `/us/en/`. `/th/en/` was not read.

## Open items, in order
1. **Thailand 2027 (after Nov 10).** Stars and special awards on Nov 10, 2026 (https://guide.michelin.com/th/en/article/michelin-guide-ceremony/save-the-date-the-michelin-guide-thailand-2027). Bib 2027 list of 151 with 26 new, Nov 3 (https://guide.michelin.com/th/en/article/michelin-guide-ceremony/bib-gourmand-thailand-2027). On Nov 5 the site list still showed 137. Read the list after the page changes. Reuse `pairs.tsv`.
2. **Rest of the launch list.** Gault & Millau France and Monaco 2027 (Nov 9), Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Michelin: Austria (next available now), Singapore, South Korea, Canada, Portugal, Mexico, US gap. Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. Ah Boy `ve_8170285a94`.
5. **Cervia pair.** See the Top 500 handoff.
6. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff and these 85 (evidence CSV: `name differs`, `pair, weak`). Fix first: the Top 500 list, Kedai Jual Beli Duit Lama (card Lama), Baan Kun Pra (card Baan Pu Karn).
7. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started.
10. **Plan v1.31.** Add this write, the Malaysia write, the Top 500 write and the 50 Best write.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Thailand list read:** slugs `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`, same-origin `fetch()` plus `DOMParser`, `.card__menu`. Each page also holds cards with `data-restaurant-country="us"` and no distinction: keep only `th` cards with `data-dtm-distinction`. Bib has 3 pages.
- **Venue page read:** a pause of 0.6 s returns status 202 with an empty page after about 45 pages. A pause of 2.5 s with a longer pause after a 202 reads all 180 in about 15 minutes.
- **Pair test by address:** `data/venues.json` holds an old address per venue. Compare it with the card for each pair where the name differs.

## Dead ends: do not retry
- A list check by page text regex `restaurants? -`: use `\d+ restaurants?` on the HTML with the tags removed.
- A 2027 date from web search only: the ceremony articles page `/th/en/articles/michelin-guide-ceremony` lists it, the search results did not.

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-thailand-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 312, audit_log 132,242, venues 11,673 (active 11,370, closed 303), awards 28,368,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,617, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,370. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Then tell me which launch list item is next and start it: read the list from the publisher and check first that it is complete.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
