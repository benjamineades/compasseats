# Handoff: Michelin US gap (California, Florida), write done. Nov 5, 2026 (23:18 Atlanta). Next: Michelin Latvia 2027 or a Ben choice now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-mexico-done-2026-11-05.md` for the live state and the open items. That file still holds the Mexico method, decisions and hold register. The Portugal, Canada, South Korea, Singapore, Austria and Thailand handoffs hold their methods. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 23:06 "1-6, A". 23:15 "Go".

## Live state (read Nov 6, 04:18:34 UTC, whole tables)
Venues **11,717** (active **11,405**, closed **312**). Awards **28,691** (last id **35,862**). Michelin 2025 / 2026 / 2027 rows 4,365 / **7,480** / 122. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,661** (canonical 11,717). Price 7,759. Listings **11,717**. city_label_source **24,841**. city_aliases 222. Redirects 35. Cities 3,325, `cities.venues_count` sum **11,405**. Ledger **277** rows, last id **331**. audit_log **127,611** rows, last id **133,440**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0. US Michelin rows labelled 2026: 500, with no URL **0**.

## Done
`docs/michelin-2026-us-gap-2026-11-05/load-michelin-2026-us-gap-2026-11-05.sql` (sha256 `6e92d228a861c0993bb9774913d5f5f7e23a7ae24a625b3af53b1c5b03783580`). Write connector, first try, 1 transaction, 04:18:01 UTC, all gates passed. The text sent left out the header comment lines and the `--` section comments of the file. The executable text was copied from the file, and the plan text gates (md5) passed.

| Item | Change |
|---|---|
| URL on rows labelled 2026 | 225 rows: 221 the `/us/en/` card, 4 the 2026 article |
| Tier | 2 of the 225, Two Stars to One Star: Caruso's 6591 `ve_9dfa8d8f4e`, Osteria Mozza 6177 `ve_3fa3c370d9` |
| Article URL, no card today | Tambourine Room 6497 (Florida star article). Horn Barbecue 11463, Sea Harbour 11864, Yank Sing (Spear St.) 11981 (California Bib article) |
| New awards, 2026 | 10 rows in ids 35,853-35,862, card URL, all Bib: Luscious Dumplings, Maligne, Luna Mexican Kitchen, Mabel's Gone Fishing, Mae Malai, Lunasia, Mariscos Jalisco, MAMA Oakland, Maccheroni Republic, Lynx |
| New venue | Lynx `ve_626864f925`, Los Angeles, restaurant, active, published. No price, address, geo, blurb or chef |
| To closed, not published | Tambourine Room `ve_33eb6c0862`, Horn Barbecue `ve_aef9d7ea1a`, Yank Sing (Spear St.) `ve_fe98dc34e4`, Little Fish Echo Park `ve_49a2fc7669`. Award rows stay |
| City counts | Miami 63 to 62. Oakland 15 to 14. San Francisco 77 to 76. Los Angeles stays 115 (Lynx +1, Little Fish -1) |
| Rows labelled 2025 | No write. Retire 0, relabel 0 |
| Sourced rows | 36 rows already held the card URL. No write |
| Ledger | 329 award (225), 330 award (10), 331 city_label (2) |
| audit_log | 133190-133440 (251). awards UPDATE 225, awards INSERT 10, cities UPDATE 3, city_label_source INSERT 2 (by hand), listings INSERT 1, listings UPDATE 4, slugs INSERT 1, venues INSERT 1, venues UPDATE 4 |

Read back, 2026 rows with a `/us/en/california/` or `/us/en/florida/` URL: Three Stars 10, Two Stars 15, One Star 83, Bib 159 = 267, equal to the list.

**No change to:** names, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-us-gap-evidence-2026-11-05.csv` (271 rows). List read: `relay-us-ca-fl-2026-list-pages-2026-11-05.txt` (sha256 `9b5fd3ef5b631b5ea92a2c954ff362ca8b54bcb2723a05a26eb5c5d3ca4274e1`, 3 reads, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (sha256 `6bec0b915c33ec7611ae84e71f59a01dc2ded0fc91f4c58130c6f86782ad552c`, equal to the browser). Live read: `live-pairs-read.txt` (md5 `723b2dabdd68311ab95d424a3717d9df`, equal to the database; line 133 is a false key match to Chicago, and `build_sql.py` overrides it). Plan: `pairs.tsv`, `hand_map.tsv`. Names: `names-differ.tsv` (52). Scripts: `build_sql.py`, `address_test.py`. Dry run: `dry.sql`.

## List check
Population: `/us/en/` list pages, built-in browser, Nov 5. California 10 / 13 / 60 / 114 = 197. Florida 0 / 2 / 23 / 45 = 70. Sum 267 = page banners. All 267 venue pages return 200, say "2026 MICHELIN Guide" and agree on tier.
- California star article 83 = the list. Florida Bib article 45 = the list.
- Florida star article 26, list 25: Tambourine Room has no card. California Bib article 117, list 114: Horn Barbecue, Sea Harbour, Yank Sing have no card. Pho Momma is on the list with no link in the article.
- Below Bib, not in scope: California 315, Florida 126 (banners).

Sources: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/guide-michelin-california (June 24, 2026), https://guide.michelin.com/us/en/article/michelin-guide-ceremony/california-s-most-affordable-restaurants-in-2026 (May 28, 2026), https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-florida-for-2026-and-the-year-s-key-trends-copy1 (page date May 6, text says May 28, 2026), https://guide.michelin.com/en/article/michelin-guide-ceremony/florida-s-most-affordable-restaurants-in-2026-copy1 (May 28, 2026).

## Label check
Capture window May 13 to June 1, 2026. California stars June 24 (after). California Bibs and all of Florida May 28 (inside), so the named test applies, by tier.
- **Population 22:** California new tiers 3 (Californios, Enclos, Kato), California new Bibs 7 (Joodooboo, Kitchen Istanbul, Lapaba, Little Fish Melrose Hill, Lugya'h, Lynx, Sonoratown), Florida new stars 2 (Mutra, Emelina), Florida new Bibs 10.
- **Rows labelled 2025:** 0 of 22 hold the change. They hold the 2025 edition. **Rows labelled 2026:** 21 of 22 (Lynx absent).
- **2027:** no edition. Northeast Cities: a New York page says 2025; edition after Dec 14.

## Pair check
Population: 267 cards. Live row with no URL, same tier 219. Tier differs 2. Sourced 36. Live venue with a 2025 row and no 2026 row 9. New venue 1. Live 2026 rows with no card: 4. Address test, population 265: same postcode 249, same street number 2, no old address 10, different 4 (Pine & Crane, Phở 79, Ghee, Taste of Chengdu: card address is another site or branch; the pairs stay).

## Decisions (Ben, all A)
1. 225 rows take a URL: 221 card, 4 article.
2. Caruso's and Osteria Mozza go to One Star, card URL.
3. 9 rows on live venues, plus Lynx with a new venue.
4. Close Tambourine Room, Horn Barbecue, Yank Sing (Spear St.), Little Fish Echo Park. Sea Harbour stays active, Adana stays closed, both on the recheck list.
5. Caruso's: no merge. `ve_9dfa8d8f4e` (Santa Barbara, holds Michelin) and `ve_d948511dfe` (Montecito, holds the Grand Award) go to the same-name pairs item.
6. Rows labelled 2025: no write. 27 of the 36 rows read that have no 2026 row and are outside the Northeast Cities list stay as history.

Status sources: Tambourine Room https://www.miaminewtimes.com/food-drink/miami-beach-hit-with-two-surprising-restaurant-closures-40588952/ . Horn Barbecue https://oaklandside.org/2026/08/07/matt-horn-bbq-oakland-closes-wage-theft/ . Yank Sing https://sfstandard.com/2026/09/14/yank-sing-rincon-center-closes-dim-sum/ (49 Stevenson St. stays open and is not a live venue row read here). Little Fish: card note "Temporarily closed", temporary closure rule; https://www.yelp.com/biz/little-fish-echo-park-los-angeles-3 . Sea Harbour conflict: https://www.foodtalkcentral.com/t/sea-harbour-down-for-the-count/20222 .

## Hold register (no rows)
Green Stars, Mindful Voices and special awards for California and Florida 2026: not read in this batch.

## Weak points
- The reason for the 2 wrong tiers is not known. The `audit_log` shows only the load of Aug 14, 2026.
- The reason for the 9 missing 2026 rows is not known. All 9 names start with L or M.
- The Florida 2025 articles were not opened. The 2025 test rests on the 2026 changes.
- The closed test is a text match written for this run. It found 1 (Little Fish).
- Little Fish: no reopening read. The Yelp and Sea Harbour listing reads are search result titles only.
- Price compare not run. The card price is in the evidence CSV.
- The first venue read returned 184 of 267 with status 202 (too fast, and the list read ran at the same time). The slower second read returned 267 of 267 with status 200.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.
- The address test used `data/venues.json` (old site file). Those addresses were not written.

## Open items, in order
1. **Rest of the launch list.** Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Michelin Latvia 2027 (Ben, Nov 5).** Out as of Nov 5. Not started. 7 rows, no 2026 rows (read Nov 5).
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** All from the Mexico handoff, plus new: Sea Harbour `ve_05a6b65bbe` (conflict), Adana `ve_500287c739` (conflict, card live), Little Fish `ve_49a2fc7669` (reopening).
5. **Same-name pairs.** All from the Mexico handoff, plus Caruso's `ve_9dfa8d8f4e` and `ve_d948511dfe`.
6. **Rename batch.** All from the Mexico handoff, plus these 52 (`names-differ.tsv`). Pine and Crane DTLA and Ghee - Wynwood name a branch that is not the card address.
7. **Archive URLs.** As in the Mexico handoff.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started. New, population 14: Somni (West Hollywood), Caruso's (Montecito), Nozawa Bar (Beverly Hills), Selby's (Atherton), Phở 79 (Westminster), The Surf Club (Surfside), Shingo, Zitz Sum, Tinta y Cafe (Coral Gables), Stubborn Seed, Lucali (Miami Beach), and 3 Carmel-by-the-Sea spellings.
10. **History backfill.** Sourced 2026 rows with no 2025 row can be missing history, for example Chengdu Taste. Not counted.
11. **Plan v1.31.** Add this write and the writes listed in the Mexico handoff.
12. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **US state list read:** selection `california`, `florida`, slugs `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, with `/page/N`. Keep `.card__menu` whose first `.card__menu-footer--score` ends with `, CA, USA` or `, FL, USA`. Each page also holds cards from AL, GA and SC, so US-wide state counts from these pages are wrong.
- **Pacing:** same-origin `fetch()` needs 1.6 seconds between venue pages, and only 1 loop at a time. Status 202 is the block. A `navigate` in the tab clears the block and also clears `window` state.
- **Tool limit:** one browser script call stops at 45 seconds. Start the loop without `await`, then poll.
- **A result over the size limit is saved to a file:** take it from there, with no retyping.
- **Write tool:** it turns the text `·` into the character. Check the hash after a write, and convert back with Python.
- **Plan size:** keep URLs as paths and join the host in SQL.
- **False key match:** compare the card city with the live city. "Union" matched Chicago, not Pasadena.

## Dead ends: do not retry
- `/us/en/article/michelin-guide-ceremony`: 404. Use web search for the article URL.
- WebFetch of miaminewtimes.com, yahoo.com, wfla.com, oaklandside.org: refused. Use a second browser tab.
- Card URLs of Tambourine Room, Horn Barbecue, Sea Harbour, Yank Sing: 404.
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-us-gap-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 331, audit_log 133,440, venues 11,717 (active 11,405, closed 312), awards 28,691,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,661, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,405. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Michelin Latvia 2027: read the live rows again first, then read the list from the publisher and check first that it is complete. Find the edition on the site today and the edition that the live rows hold, from a guide.michelin.com URL, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
