# Handoff: Michelin Canada 2026 (3 guides), write done. Nov 5, 2026 (21:50 Atlanta). Next: Portugal now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-south-korea-done-2026-11-05.md` for the live state and the open items. That file still holds the South Korea method, decisions and hold register. The Singapore handoff holds the "edition after the capture window" method. The Austria handoff holds the relabel method. The Thailand handoff holds the Thailand 2027 details. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 21:32 "1-8 A". 21:42 "Go".

## Live state (read Nov 6, 02:44:46 UTC, whole tables)
Venues **11,698** (active **11,390**, closed **308**). Awards **28,592** (last id **35,763**). Michelin 2025 / 2026 / 2027 rows **4,447 / 7,299 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,642** (canonical 11,698). Price 7,759. Listings **11,698**. city_label_source **24,803**. city_aliases 222. Redirects 35. Cities 3,321, `cities.venues_count` sum **11,390**. Ledger **268** rows, last id **322**. audit_log **127,088** rows, last id **132,917**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-canada-2026-11-05/load-michelin-2026-canada-2026-11-05.sql` (sha256 `534d39045bb44ac58d6256b92aa5b6d28c96116c561cc27487f8c173906da063`). Write connector, first try, 1 transaction, 02:44:17 UTC, all gates passed. The text sent left out the header comment lines of the file. The executable text was copied from the file, and the plan text gates (md5) passed.

| Item | Change |
|---|---|
| Relabel | 36 rows, Québec guide, year 2025 to 2026, `/us/en/` card URL, retire 0 (rules 2.1.1 and 2.1.7) |
| 2025 rows kept | 70 rows, Toronto & Region 43, Vancouver 27. Label 2025, no URL |
| New awards, 2026 | 73 rows, ids 35,691-35,763, `/us/en/` card URL: Toronto & Region 46 (1 / 14 / 31), Vancouver 27 (1 / 10 / 16) |
| New venues | 7, card name, restaurant, active, published. No price, address, geo, blurb or chef: Antylia `ve_9787e80ff3`, Golden Horseshoe Barbecue `ve_868be43e83`, The Lunch Lady of Saigon `ve_60557aefdd` (Toronto), Chef's Choice Seafood Restaurant `ve_142644bcab`, Kavita `ve_38b45e4f9e` (Vancouver), Les Incompetents `ve_98262d7ccb` (Saint Catharines, card St. Catharines), RPM Bakehouse `ve_5604e900a5` (Lincoln, card Jordan) |
| Closed | Fable Kitchen `ve_3160c0aec9`: status closed, published false. Award row and slug stay. No ledger row for the closure |
| City counts | Vancouver 45 to 46. Toronto 72 to 75. Saint Catharines 1 to 2. Lincoln 1 to 2 |
| Ledger | 320 award (relabel), 321 award, 322 city_label |
| audit_log | 132768-132917 (150). awards UPDATE 36, awards INSERT 73, venues INSERT 7, venues UPDATE 1, listings INSERT 7, listings UPDATE 1, slugs INSERT 7, cities UPDATE 4, city_label_source INSERT 14 (by hand) |

Canada Michelin rows after the write: 2026 labelled 109 (Two Stars 3, One Star 36, Bib 70), 109 with a URL. 2025 labelled 70 (Two Stars 1, One Star 28, Bib 41), 0 with a URL.

**No change to:** names, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-canada-evidence-2026-11-05.csv`. List read: `relay-ca-2026-list-pages-2026-11-05.txt` (sha256 `cddbbd98fa74dab4268d4cacb4e0a6d9858ad894a9d5eee5259b022b60adafa3`, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (the browser hash is of the escaped form, `30cee71f6ada64d75420d96dcaf5711e64285830825bd7307e31acb8998919fb`). Plan: `pairs.tsv`. Live read: `live-read.txt` (sha256 `0ccbf0a4f5a6401f5b9e774a5d412087145302fd4c315519d0f105e20f1d0f16`, equal to the database). Scripts: `pairs_build.py`, `build_sql.py`, `evidence.py`.

## List check
Population: selection `canada`, `/us/en/`, built-in browser, Nov 5. Site list 109 rows = page banners 3 / 36 / 70. Per guide (Two Stars / One Star / Bib): Québec 1 / 12 / 23 = 36, Toronto & Region 1 / 14 / 31 = 46, Vancouver 1 / 10 / 16 = 27. These equal the star and Bib articles of each guide. All 109 venue pages return 200 and say "2026 MICHELIN Guide". 0 pages say closed. Below Bib, not in scope: 194 Selected (browser hash `c5d97cf09683426dc70b68c06aacc234926044a80949a531403ed9064bbe776d`, file not saved).

Articles: Québec stars https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-quebec-for-2026-and-the-year-s-key-trends, Québec Bib https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/quebec-s-most-affordable-restaurants-in-2026, Toronto stars https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-toronto-region-for-2026, Toronto Bib https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/the-most-affordable-restaurants-in-toronto-and-region-for-2026, Vancouver stars https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-vancouver-for-2026, Vancouver Bib https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-most-affordable-restaurants-in-vancouver-for-2026.

## Label check
Population: Michelin rows on Canada venues, 106 rows, read before the write. All labelled 2025, 0 with a URL. Capture window: May 13 to June 1, 2026.
- **Québec:** ceremony May 6, 2026, before the window. 36 live rows, 1 / 12 / 23. They hold all 4 new stars and all 7 new Bibs of 2026. The 2025 edition (May 15, 2025) has 1 / 8 / 17.
- **Toronto & Region:** ceremony Sep 22, 2026, after the window. 43 live rows, 1 / 16 / 26 = 2025 edition (articles of Sep 2025: https://guide.michelin.com/ca/en/article/michelin-guide-ceremony/the-best-restaurants-in-toronto-for-2025, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-best-budget-friendly-restaurants-in-the-toronto-region).
- **Vancouver:** ceremony Oct 6, 2026, after the window. 27 live rows, 0 / 12 / 15 = 2025 edition (articles of Oct 2, 2025: https://guide.michelin.com/en/article/michelin-guide-ceremony/all-the-stars-from-the-michelin-guide-vancouver-2025, https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-most-affordable-restaurants-in-vancouver).
- **2027:** no edition found for any of the 3 guides. No Québec 2027 date found.

## Pair check
Population: 109 cards. Same name 72. Name differs 30. New venue 7. Tier change 1 (AnnaLena, One Star to Two Stars). Address test, population 102 live venues: same postcode 94, same street number 6, same address with a one-character postcode typo in the old file 1 (The Ace), no old address 1 (Sundays). Weak pairs 0.

## Decisions (Ben, all A)
1. Québec: relabel 36 rows with the card URL, retire 0. These URLs will repeat when Québec 2027 loads: the `url in use` gate of the 2027 file must allow them.
2. Toronto and Vancouver: 70 rows stay as 2025, 73 rows added as 2026. These URLs will repeat when the 2027 editions load: the same applies.
3. 7 new venues, card name.
4. RPM Bakehouse goes in Lincoln: the alias `jordan station` already points there, and "Jordan" is also a country. The city label holds the card city Jordan.
5. Fable Kitchen closed, published false. Daily Hive, Sep 2, 2026: closes Sep 20 (https://dailyhive.com/vancouver/fable-kitchen-vancouver-2026). Absent from the guide because closed (https://dailyhive.com/vancouver/michelin-guide-vancouver-dropped-restaurants). The owner said "This isn't the end of Fable", with a food truck and collaborations under study.
6. Aburi Hana `ve_7b26d42de5` and Barbara `ve_8d50ba8fd5`: active, the 2025 rows stay, no 2026 row. Barbara is on the Selected list (Oct 10 ruling). Aburi Hana: card 404, closed nearly a year, reopened Sep 17, 2026 with a new concept (https://streetsoftoronto.com/food/restaurants/zero-new-stars-and-a-major-loss-everything-that-went-down-at-torontos-2026-michelin-ceremony/). Hexagon `ve_14deab4c46` stays closed, row 6969 stays as 2025.
7. No Québec 2025 rows now. Québec holds 0 rows labelled 2025. The 2025 edition goes to the history backfill. L'Express (Bib 2025, Selected now, no venue) goes there too.
8. No rename, price or merge. 30 names go to the rename batch (evidence CSV: `name differs`). 8 price items: Mastard `$$$` to card `$$$$`, and the 7 new venues with no price. Pair list, not merged: Restaurant 20 Victoria `ve_fbf2d9f536` (Michelin) and 20 Victoria St `ve_27302ae41b` (Best Chef, La Liste, OAD).

## Hold register (no rows)
Special awards 2026, Toronto & Region: Young Chef Andrew Golden (Golden Horseshoe BBQ), Exceptional Cocktails Sharon Chan (156 ONEFIVESIX), Service Eric Roell (LORE), Sommelier Toni Weber (Restaurant 20 Victoria). Vancouver: Young Chef Vish Mayekar (Elem), Service Yash Shah (Kavita), Sommelier Mark Taylor (Bacchus), Exceptional Cocktails Chris Enns (Peya). Not read: Québec special awards 2026, Green Star lists 2026 of all 3 guides.

## Weak points
- The 70 rows labelled 2025 have no URL.
- I compared the article lists with the site list and the live rows by eye and by count, not by script.
- The Vancouver 2025 lists came through the WebFetch summary, because the browser fetch gave a 404. That read did not give the star level per row. The 2025 Two Star count of 0 rests on the live rows and on the press (CBC, Vancouver Is Awesome: AnnaLena is the first Two Stars in the city; headlines only, pages not opened).
- The tier came from the list page, not from each venue page. The articles agree for stars and Bibs.
- Aburi Hana and Fable Kitchen rest on press only. The main Fable Kitchen source is from before the closing date.
- Card prices are from `/us/en/`. `/ca/en/` was not read. The price test compares the symbols only.
- The pair test by address used `data/venues.json` (old site file). Those addresses were not written.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.

## Open items, in order
1. **Rest of the launch list.** Michelin: **Portugal (next available now)**, Mexico, US gap. Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Michelin Latvia 2027 (Ben, Nov 5).** Out as of Nov 5. Not started. The launch list holds Latvia on the "if time remains" list with 7 rows and no 2026 rows (read Nov 5).
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. Ah Boy `ve_8170285a94`. OPUS (Vienna). Alma `ve_8b5854c9bd` (reopening), Eminent Frog `ve_3c60e6d1a2`, Soon Huat `ve_d6a6b6aac1`. New: Aburi Hana `ve_7b26d42de5` (new concept). Not read closely: The Peak (2025) names Oshino `ve_d783347096` and Shinji by Kanesaka, Bras Basah Road `ve_645ec68d75` as closed; both are active.
5. **Cervia pair.** See the Top 500 handoff. Same-name pairs in neighbor cities, not merged: Rossbarth (`ve_501866509c`, `ve_48c9f68107`), Restaurant GuatzEssen (`ve_084f389fc1`, `ve_e6eb49f5b1`). New: Restaurant 20 Victoria `ve_fbf2d9f536` and 20 Victoria St `ve_27302ae41b`, same city.
6. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff, the 85 of the Thailand handoff, the 96 of the Austria handoff, the 36 of the Singapore handoff, the 36 of the South Korea handoff and these 30. "Fix first" list: see the South Korea handoff.
7. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026, the 125 Singapore rows labelled 2025, and the 70 Canada rows labelled 2025 (new).
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started.
10. **Plan v1.31.** Add this write, the South Korea write, the Singapore write, the Austria write, the Thailand write, the Malaysia write, the Top 500 write and the 50 Best write.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **A country with several guides:** read one selection (`canada`), then group the cards by the province part of the card path. Ceremony date per guide decides the action per guide: relabel for one guide, new rows for another, in one file.
- **Canada list read:** selection `canada`, slugs `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`, with `/page/N`. The `3-stars-michelin` slug gives a 404 because Canada has none. Same-origin `fetch()` plus `DOMParser`. Keep `.card__menu` whose first `.card__menu-footer--score` ends with `Canada`: each page also holds 4 US cards.
- **Article list read on new articles:** read `h2, h3, a[href*="/restaurant/"]` from the whole document in order and stop at "Related". Reading `.detail-page__content` alone returns only the intro text. Text sections before the list can name other restaurants, and the star sections can hold stray links to US cards, so read from the tier heading.
- **City for a new venue:** check `city_aliases` first. The alias `jordan station` gave the Lincoln answer for the card city Jordan.
- **Saving a relay with the Write tool:** write the real characters, escape again by a script, compare the hash with the browser, then delete the `.raw` file.

## Dead ends: do not retry
- `/en/article/michelin-guide-ceremony/all-the-stars-from-the-michelin-guide-vancouver-2025` and `/us/en/article/michelin-guide-ceremony/the-most-affordable-restaurants-in-vancouver` with a browser `fetch()`: 404. WebFetch of the same URLs works.
- The regex for the tier on a Canada venue page: it returns nothing. The edition regex works.
- `foodserviceandhospitality.com` with WebFetch: client error. `yelp.com` with WebFetch: refused.
- `enprimeurclub.com`: ignore it in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-canada-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 322, audit_log 132,917, venues 11,698 (active 11,390, closed 308), awards 28,592,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,642, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,390. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Michelin Portugal: read the list from the publisher and check first that it is complete. Find the edition on the site today and the edition that the live rows hold, from a guide.michelin.com URL, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
