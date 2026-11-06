# Handoff: Michelin Austria 2026 label, write done. Nov 5, 2026 (19:40 Atlanta). Next: Singapore now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-thailand-done-2026-11-05.md` for the live state and the open items. That file still holds the Thailand method, decisions and the Thailand 2027 details. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 19:31 "1-8 A". 19:33 "Go".

## Live state (read Nov 6, 00:36:10 UTC, whole tables)
Venues **11,674** (active **11,369**, closed **305**). Awards **28,373** (last id **35,544**). Michelin 2025 / 2026 / 2027 rows **4,596 / 6,931 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,618** (canonical 11,674). Price 7,759. Listings **11,674**. city_label_source **24,755**. city_aliases 222. Redirects 35. Cities 3,321, `cities.venues_count` sum **11,369**. Ledger **261** rows, last id **315**. audit_log **126,585** rows, last id **132,414**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-austria-2026-11-05/load-michelin-2026-austria-2026-11-05.sql` (sha256 `cb72ca9a60d6d98265333b080d38a3b555ac89fcca75a9d0713d0bb28ee98ea4`). Write connector, first try, 1 transaction, 00:35:45 UTC, all gates passed. The text sent left out the header comment lines of the file. The executable text is the same.

| Item | Change |
|---|---|
| Relabel | 156 rows, Michelin Austria, year 2025 to 2026, retire 0 (rules 2.1.1 and 2.1.7). URL: the `/us/en/` card on 155 rows, the star article on row 5897 |
| 2025 history kept | 2 Bib rows, 5938 Wörgötter - Wirtshaus and 5898 Schlosskeller Wirtshaus, with the 2025 article URL |
| New awards | 5 rows, year 2026, ids 35,540-35,544: 35540 One Star Thaller - Restaurant, 35541 Bib Wörgötter - Wirtshaus, 35542 One Star Kirchenwirt on `ve_408dd2d0e2`, 35543 Bib Schlosskeller Wirtshaus (no URL), 35544 One Star TIAN |
| New venue | Thaller - Restaurant `ve_110e46ef2f`, slug `sankt-veit-am-vogau/thaller-restaurant`, restaurant, active, published. No price, address, geo, blurb or chef |
| Closed | Schlosskeller Südsteiermark `ve_fb7dc1ff33` and Schlosskeller Wirtshaus `ve_d3fd2ae165`: status closed, published false. Award rows stay as history. Slugs stay. No ledger row for the closure (D1 precedent) |
| City counts | Leibnitz 2 to 0. Sankt Veit am Vogau 1 to 2 |
| Ledger | 313 relabel, 314 award, 315 city_label |
| audit_log | 132243-132414 (172). awards UPDATE 156, awards INSERT 5, venues INSERT 1, venues UPDATE 2, listings INSERT 1, listings UPDATE 2, slugs 1, cities UPDATE 2, city_label_source 2 (by hand) |

Austria Michelin rows after the write: 2026 labelled 161 (Three Stars 2, Two Stars 19, One Star 79, Bib 61), 160 with a URL. 2025 labelled 2, 2 with a URL. The edition has 162 rows: the difference is OPUS.

**No change to:** names, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-austria-evidence-2026-11-05.csv` (sha256 `fec6a597f2de85e0c67526d25b5f8da44df3be8750bfb7cc261e73d8df44c3dc`). List read: `relay-at-2026-list-pages-2026-11-05.txt` (sha256 `a7a3ea3d880885565f1865c38e9fa15edd5029b329114e3396e31cc5f21b0c80`, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (sha256 `3b498035bb5ff36576f2885e1b97face106dddb75d06baba2d826c6811290d63`). Plan: `pairs.tsv`. Live read: `live-read.txt`. Scripts: `pairs_build.py`, `build_sql.py`, `evidence.py`.

## List check
Population: selection `austria`, `/us/en/`, built-in browser, Nov 5. Site list 159 rows = page banners 2 / 19 / 78 / 60. Edition 162 rows = 2 / 19 / 80 / 61 (selection Mar 18, 2026: https://guide.michelin.com/at/en/article/michelin-guide-ceremony/all-starred-restaurants---michelin-guide-austria-2026, Bib article: https://guide.michelin.com/at/en/article/michelin-guide-ceremony/the-new-bib-gourmands-for-austria-2026---26-times-our-best-value). The 3 edition rows not on the site list: OPUS, Schlosskeller Gourmetstube, Schlosskeller Wirtshaus. All 3 cards give a 404. All 159 venue pages return 200, say "2026 MICHELIN Guide Austria" and agree with the list on tier. 0 pages say closed. Below Bib, not in scope: 267 Selected.

## Label check
Population: Michelin rows on Austria venues, 158 rows, read before the write. 2 / 19 / 76 / 61. The 2025 edition has 2 / 18 / 62 / 43 (article of Jan 21, 2025). The live rows hold the 2026 edition. 4 edition rows were not in the live rows: TIAN, Kirchenwirt (Leogang), Thaller - Restaurant, OPUS.

## Pair check
Population: 159 cards. Same name 60. Name differs, paired 95. Live venue, new row 3. New venue 1. Address test, population 98 live venues whose card does not repeat the live name or that get a new row: same 91, same postcode only 5, different 1 (Aurea), no old address 1.

## Decisions (Ben, all A)
1. Relabel 156 rows, with the card URL on 155 and the star article URL on row 5897. These URLs will repeat when Austria 2027 loads: the `url in use` gate of the 2027 file must allow them.
2. Rows 5938 and 5898 stay as 2025 history. 2026 rows added for each.
3. Aurea Fine Dining `ve_03dda05136` keeps the pair with RAR Fine Dining. Its old address is in Wildschönau, where Michelin lists Aurea as Selected. RAR is at Hochkönigstraße 27, Maria Alm. The name goes first in the rename batch.
4. Thaller - Restaurant is a new venue, card name. Same address as Thaller - Gasthaus (`ve_a70fd42717`, Bib).
5. Both Schlosskeller venues closed, published false. Own site: "Restaurantbetrieb wurde mit 19. Oktober 2026 eingestellt" (https://www.schlosskellersuedsteiermark.at/).
6. OPUS: no venue, no row. On the hold register and the recheck list.
7. One Star rows on live venues TIAN `ve_ef06954a85` and Der Kirchenwirt `ve_408dd2d0e2`.
8. No rename, price change or merge. 96 names go to the rename batch (95 paired + Der Kirchenwirt, evidence CSV: `name differs`). 4 venues with no price go to the price item: TIAN, Der Kirchenwirt, Wörgötter - Wirtshaus, Thaller - Restaurant. 2 price differences go there: Saziani `$$$` to card `€€€€`, Brandstätter `$$$` to card `€€`.

## Hold register (no rows)
OPUS (Vienna): One Star, marked new in the star article. Card 404 on Nov 5, not on the Selected list. My Austria Stay, May 12, 2026: main room closed for renovation (https://www.myaustriastay.com/opus-at-hotel-imperial-earns-a-michelin-star-before-it-even-reopens). The hotel dining page lists only the café and the bar. No closure report found. Green Star list (41, 8 new): not read. Special awards 2026: Young Chef Sebastian Stock (Bergfried - Chef's Table), Service Monika Müller (Die Forelle), Sommelier Christian Zach (Die Weinbank), Opening of the Year Genießerei am Markt.

## Weak points
- The Schlosskeller Wirtshaus 2026 row has no URL. Evidence: the edition total of 61, the legacy capture, and a 2025 article row.
- Row 5897 has the star article as URL, not a card.
- The pair test by address used `data/venues.json` (old site file). Those addresses were not written.
- Card prices are from `/us/en/`. `/at/en/` was not read.
- OPUS status is not settled.
- Austria 2027 date: not read.

## Open items, in order
1. **Rest of the launch list.** Michelin: **Singapore (next available now)**, South Korea, Canada, Portugal, Mexico, US gap. Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Status read of the 45 Top 500 venues.**
3. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. Ah Boy `ve_8170285a94`. New: OPUS (Vienna).
4. **Cervia pair.** See the Top 500 handoff. New same-name pairs in neighbor cities, not merged: Rossbarth (`ve_501866509c` Linz, `ve_48c9f68107` Linz an der Donau), Restaurant GuatzEssen (`ve_084f389fc1` Stumm, `ve_e6eb49f5b1` Stumm im Zillertal). In each pair one venue holds the Michelin row and the other the Gault & Millau row.
5. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff, the 85 of the Thailand handoff and these 96. Fix first: the Top 500 list, Kedai Jual Beli Duit Lama (card Lama), Baan Kun Pra (card Baan Pu Karn), Aurea Fine Dining (card RAR Fine Dining), Wirtshaus `ve_66510fec11` (card Rouge Noir, same address as the Selected Wirtshaus by Stefan Glantschnig), Döllerers Wirtshaus `ve_514ac623be` (card Döllerer, the Two Stars; Döllerers Wirtshaus is a separate Selected card), Wirtshaus Lilli `ve_c988d005ee` (card Lilli Fine Dining; Lilli Wirtshaus is a separate Selected card).
6. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026.
7. **Phase 2 publish job.** Goal Nov 29. Not started.
8. **Phase 3 location pass.** Not started.
9. **Plan v1.31.** Add this write, the Thailand write, the Malaysia write, the Top 500 write and the 50 Best write.
10. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Austria list read:** selection `austria`, slugs `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin` (2 pages), `bib-gourmand` (2 pages), `the-plate-michelin` (6 pages), same-origin `fetch()` plus `DOMParser`. Keep `at` cards with `data-dtm-distinction`. Name and URL from `h3 a`, location and price from the two `.card__menu-footer--score`.
- **Venue page read:** a pause of 2.5 s gave 0 refusals over 2 passes of about 165 pages. Run the loop on `window` from a call that returns at once, and poll. Address: `.data-sheet__block--text`. Edition and tier: the description text, regex ` restaurant in the (20\d\d) MICHELIN Guide`, on the raw HTML.
- **Edition against site list:** compare the article list with the site list row by row. The difference finds closures after the edition. Then read the venue's own site.
- **Sourced 2025 row:** when a row in the gap holds a URL to the 2025 article and the 2025 article names it, keep it as 2025 and add a 2026 row. The relabel gate is `source_url IS NULL`.

## Dead ends: do not retry
- `preview_start` with a tab open: it navigates the same tab and stops any running loop. Use WebFetch for other pages during a loop.
- A `javascript_exec` call with a wait of 45 s: the tool times out. Poll with short calls.
- A regex for the edition on `main` text: the words are only in the description and metadata.
- A foreground `sleep`: blocked. Use a background command.
- `slugs.canonical` (the column is `is_canonical`).
- `data/venues.json` lookup by `ve_` id: its ids are old Google ids. Look up by name.

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-austria-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 315, audit_log 132,414, venues 11,674 (active 11,369, closed 305), awards 28,373,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,618, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,369. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Then tell me which launch list item is next and start it: read the list from the publisher and check first that it is complete.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
