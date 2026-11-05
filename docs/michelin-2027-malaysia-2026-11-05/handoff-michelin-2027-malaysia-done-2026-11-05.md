# Handoff: Michelin Kuala Lumpur & Penang 2027 and the 2026 label, write done. Nov 5, 2026 (18:05 Atlanta). Next: rest of the launch list.

This file replaces `handoff-top-500-bars-2026-done-2026-11-05.md` for the live state and open item 1. That file still holds the Top 500 method, its decisions and its open items 2 to 9, which are carried below. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 17:59 "1-8:A". 18:01 "Go".

## Live state (read Nov 5, 23:03:46 UTC, whole tables)
Venues **11,672** (active **11,369**, closed 303). Awards **28,366** (last id **35,537**). Michelin 2025 / 2026 / 2027 rows **4,930 / 6,590 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,616** (canonical 11,672). Price 7,759. Listings **11,672**. city_label_source **24,751**. city_aliases 222. Redirects 35. Cities 3,321, `cities.venues_count` sum **11,369**. Ledger **255** rows, last id **309**. audit_log **126,227** rows, last id **132,056**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2027-malaysia-2026-11-05/load-michelin-2027-malaysia-2026-11-05.sql` (sha256 `9f51b7823b366af108c69058b281a4ddc90752769839bebf95786b6aadbf9d01`). Write connector, first try, 1 transaction, 23:03:20 UTC, all gates passed.

| Item | Change |
|---|---|
| Relabel | 66 rows, Michelin Malaysia, year 2025 to 2026, no URL, retire 0 (rule 2.1.7) |
| New awards | 70 rows, year 2027, ids 35,468-35,537: Two Stars 1, One Star 9, Bib Gourmand 60, all with the `/us/en/` card URL |
| New venues | 4, all restaurant, active, published. No price, address, geo, blurb or chef |
| City counts | Kuala Lumpur 44, George Town 34, Seberang Perai 6 |
| Ledger | 307 relabel, 308 award, 309 city_label |
| audit_log | 131,898-132,056 (159). awards UPDATE 66, awards INSERT 70, venues 4, listings 4, slugs 4, cities UPDATE 3, city_label_source 8 (by hand) |

Malaysia Michelin rows after the write: 2026 labelled 66 (Two Stars 1, One Star 8, Bib 57), 0 with a URL. 2027 labelled 70, 70 with a URL.

**New venues:** 7 Chai Ipoh Hor Fun `ve_6fb1e2353b`, Minji Bak Kut Teh `ve_da9da38e39` (Kuala Lumpur). Serabai Istimewa `ve_f8db3067b6` (George Town). Lemon Koay Teow Soup `ve_e515d7f579` (Seberang Perai).

**No change to:** names, status of a live venue, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2027-malaysia-evidence-2026-11-05.csv` (sha256 `4b565b3a98fe4952b63731f78ddf52629f8f43e2303590a5ab4516a4a3da1b00`). List read: `relay-my-2027-list-pages-2026-11-05.txt` (sha256 `f145be1e1f8128f22059cfef8cf700efb4aac9bce039efc9dcc5dd048cb67fb0`, equal to the browser on 3 reads). Plan: `pairs.tsv`. Live read: `live-read.txt`. Script: `build_sql.py`.

## List check
Population: selection `malaysia`, 4 list pages, built-in browser. 70 rows = page banners 1 / 9 / 60 = press release of Nov 4, 2026. With the 89 Selected rows the sum is 159, equal to the page total and the release. All 70 venue pages say "2027 MICHELIN Guide Malaysia" and agree with the list on name, URL and distinction.

## Label check
Population: Michelin rows on Malaysia venues, 66 rows. Edition 2026 ceremony Nov 11, 2025 (https://guide.michelin.com/en/article/michelin-guide-ceremony/malaysia-full-selection-2026). All 7 named new 2026 entries are in the rows with the same category. Archived Bib list: banner 58 on Dec 15, 2025, banner 57 on Feb 12, 2026 (page 1 of each read, 48 cards). All 48 Feb cards are on the live rows. The 1 Dec card not on the live rows is Heun Kee, closed Jan 2026.

## Decisions (Ben, all A)
1. No URL on the 66 relabelled rows now. Archive URLs are a later item.
2. Weak pairs accepted: Lama to `ve_15423d04be` ("Kedai Jual Beli Duit Lama..."), Ghee Lian to `ve_63e0e5b6a4` ("義蓮鱼头米粉 Green Tomyam"), Sifu to `ve_78fd0c5910` ("Sifu Fit").
3. Potager to Potager KL `ve_dc32f76e1a`.
4. 4 new venues active and published.
5. Ah Boy `ve_8170285a94` stays active with its 2026 row. On the recheck list. Michelin card 404, Malay Mail names it as dropped, no closure report found.
6. Heun Kee Claypot Chicken Rice: no venue, no row.
7. No rename or price change. 33 names go to the rename batch (29 + 3 weak + Potager). 5 venues with no price (4 new, Potager) and 2 differences (De. Wan `$$$` to card `$$`, Au Jardin `$$$` to card `$$$$`) go to the price item.
8. One gated SQL file, no ingest batch and no UNDO button. audit_log covers every row.

## Hold register (no rows)
Special awards, 2027: Young Chef Aidan Low (Akar), Service Mr Nazahar (Potager), Sommelier Joyin Goh (Tangram), Opening of the Year Root House by Gēn. Mindful Voices: Darren Teoh of Dewakan is named as the first featured chef (Malay Mail). Green Star list: not read.

## Weak points
- The 66 rows labelled 2026 have no URL. CDX for the 66 paths, incomplete because the archive refused requests: 35 paths have a capture. The content of those captures is not read.
- Only page 1 of each archived Bib list was read.
- Status of the 4 new venues: only the Michelin 2027 cards were read.
- Card prices are from `/us/en/`. `/my/en/` was not read.

## Open items, in order
1. **Rest of the launch list (next).** Editions due: Gault & Millau France and Monaco 2027 (Nov 9), Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Michelin: Thailand, Austria, Singapore, South Korea, Canada, Portugal, Mexico, US gap. Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Status read of the 45 Top 500 venues.**
3. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. New: Ah Boy `ve_8170285a94`.
4. **Cervia pair.** See the Top 500 handoff.
5. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff and these 33 (evidence CSV: `name differs`, `pair, weak name`, `live venue, no earlier Michelin row`). Fix first: the Top 500 list plus "Kedai Jual Beli Duit Lama Central Market, Pasar Seni, Kuala Lumpur." (card Lama).
6. **Archive URLs for the 66 Malaysia rows labelled 2026.** Conditions: plan, history-backfill item.
7. **Phase 2 publish job.** Goal Nov 29. Not started.
8. **Phase 3 location pass.** Not started.
9. **Plan v1.31.** Add this write, the Top 500 write and the 50 Best write.
10. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Malaysia list read:** selection slug `malaysia`, same-origin `fetch()` plus `DOMParser`. Each card appears 4 times under `[data-restaurant-country]`: remove duplicates by href. No 3-star list (404). Bib has 2 pages.
- **Plan text gate:** the md5 gate on the text sent through the connector caught 1 wrong URL in a copy by hand. To find the line, send the text with `split_part(y,'|',1)||':'||length(y)` per line and compare with the file.
- **Archive CDX:** prefix queries from a tab on web.archive.org: use a long pause. Many calls in a row return an HTML page, not JSON.

## Dead ends: do not retry
- `awards.source` (the column is `source_id`). `cities.name` (the column is `display`).
- CDX prefix queries with a 1.5 s pause over 7 locales: a timeout at 45 s, then refused requests.

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2027-malaysia-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 309, audit_log 132,056, venues 11,672 (active 11,369, closed 303), awards 28,366,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,616, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,369. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Then tell me which launch list item is next and start it: read the list from the publisher and check first that it is complete.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
