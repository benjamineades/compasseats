# Handoff: Michelin Singapore 2026, write done. Nov 5, 2026 (20:55 Atlanta). Next: South Korea now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-austria-done-2026-11-05.md` for the live state and the open items. That file still holds the Austria method, decisions and hold register. The Thailand handoff holds the Thailand 2027 details. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- New open item: Michelin Latvia 2027 is out as of Nov 5. Not started (open item 2).
- 20:49 "1-8 A". 20:50 "Go".

## Live state (read Nov 6, 01:53:03 UTC, whole tables)
Venues **11,691** (active **11,384**, closed **307**). Awards **28,519** (last id **35,690**). Michelin 2025 / 2026 / 2027 rows **4,600 / 7,073 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,635** (canonical 11,691). Price 7,759. Listings **11,691**. city_label_source **24,789**. city_aliases 222. Redirects 35. Cities 3,321, `cities.venues_count` sum **11,384**. Ledger **264** rows, last id **318**. audit_log **126,821** rows, last id **132,650**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-singapore-2026-11-05/load-michelin-2026-singapore-2026-11-05.sql` (sha256 `c5d4da5df99ff742cfd55d6b50d34705e7821688d56e88726f71642dc7244519`). Write connector, first try, 1 transaction, 01:52:41 UTC, all gates passed. The text sent left out the header comment lines of the file. The executable text is the same.

| Item | Change |
|---|---|
| Relabel, retire | 0 and 0. The 126 live rows stay as 2025 (rules 2.1.1 and 2.1.7) |
| New awards, 2026 | 142 rows, ids 35,545-35,686, with the `/us/en/` card URL: Three Stars 3, Two Stars 9, One Star 33, Bib 97 |
| New awards, 2025 | 4 One Star rows, ids 35,687-35,690, with the 2025 article URL: Alma, Esora, Euphoria, Imperial Treasure Fine Teochew Cuisine |
| New venues | 17, card name, restaurant, active, published. No price, address, geo, blurb or chef. One Star or higher: 1887 by André `ve_6150431a62`, Cherry Garden by Chef Fei `ve_c18e6698bd`, Jin Ting Wan `ve_002141a22b`, Loca Niru `ve_6236dcb2f6`, Sushi Kimura + `ve_a1cc871e3a`, Tenshima `ve_e4eee7c600`, Yong Fu `ve_ba6c7780ca`. Bib: Boon Keng Road Fish Head Bee Hoon `ve_ec2a970f84`, Hup Kee Fried Oyster Omelette `ve_8d2be7d991`, Jia Xiang `ve_9919c621d4`, King of Laksa `ve_bd4c24ab20`, Rajarani Thosai `ve_a2766aaafd`, Seng Kee Black Chicken Herbal Soup `ve_ad804b758b`, Tian Nan Xing Minced Pork Noodle `ve_deac5b49eb`, Xiangyee `ve_9d087c1721`, Xiu Ji Ikan Bilis Yong Tau Fu `ve_48d50a4e4b`, Yi Pin Wei Braised Duck．Kway Chap `ve_8dbfa11f3a` |
| Closed | Alma by Juan Amador `ve_8b5854c9bd`, Esora `ve_72e993e4a4`: status closed, published false. Award rows and slugs stay |
| City count | Singapore 210 to 225 |
| Ledger | 316 award, 317 award, 318 city_label |
| audit_log | 132415-132650 (236). venues INSERT 17, listings INSERT 17, slugs 17, city_label_source 34 (by hand), awards INSERT 146, venues UPDATE 2, listings UPDATE 2, cities UPDATE 1 |

Singapore Michelin rows after the write: 2026 labelled 142 (3 / 9 / 33 / 97), 142 with a URL. 2025 labelled 130 (3 / 7 / 31 / 89), 5 with a URL.

**No change to:** names, price, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-singapore-evidence-2026-11-05.csv`. List read: `relay-sg-2026-list-pages-2026-11-05.txt` (sha256 `d6df72b17a315fd238ee56d19edadabdcbd073c1ae51cab391dad330b1605d8c`, equal to the browser). Selected list: `relay-sg-2026-selected-2026-11-05.txt` (sha256 `4700f6bc739a4c878481fbf0d57c81cf9dfca0fe1ed8f3e015c15fbeac41925b`, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (the browser hash is of the escaped form, `14fa9497dbf15900561ee80a74fe111f524aa6de6f6177a01aab3daa4d517966`). Plan: `pairs.tsv`. Live read: `live-read.txt`. Scripts: `pairs_build.py`, `build_sql.py`, `evidence.py`.

## List check
Population: selection `singapore`, `/us/en/`, built-in browser, Nov 5. Site list 142 rows = page banners 3 / 9 / 33 / 97 = article of Aug 4, 2026 (https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2026). All 142 article names are on the site list. All 142 venue pages return 200, say "2026 MICHELIN Guide" and agree on tier. 0 pages say closed. Below Bib, not in scope: 165 Selected.

## Label check
Ceremony Aug 4, 2026 (https://guide.michelin.com/sg/en/event/save-the-date-michelin-guide-singapore-2026), after June 1, so the legacy rows hold the 2025 edition. Population: Michelin rows on Singapore venues, 126 rows, read before the write: 3 / 7 / 27 / 89. The 2025 article (Jul 24, 2025, https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/full-list-michelin-guide-sg-2025) has 3 / 7 / 32 / 89. The 5 edition rows not in the live rows: Alma, Chaleur, Esora, Euphoria, Imperial Treasure Fine Teochew Cuisine.

## Pair check
Population: 142 cards. Same name 89. Name differs, paired 35. Live venue, new row 1. New venue 17. Address test, population 36 live venues: same postcode 29, same street number and another postcode 3 (CUT, Kok Sen, Song Fa), different place 4 (weak pairs below). Tier change, population 124 paired rows: 1 (Seroja, One Star to Two Stars).

## Decisions (Ben, all A)
1. 142 rows, year 2026, card URL. 126 rows stay as 2025. These URLs will repeat when Singapore 2027 loads: the `url in use` gate of the 2027 file must allow them.
2. 17 new venues. The new-venue clash test by `norm_key` runs inside the city, because Yong Fu in Hong Kong `ve_c5547a4f38` is another restaurant.
3. 4 weak pairs stay, and the tier decides: Heng Watch `ve_4deb0c2986` (card Heng), Du Du Cooked Food (#01-10) `ve_2c4893da5a` (card Dudu Cooked Food), Thai Seng Fish Soup `ve_67c75dd2eb` (card Tai Seng Fish Soup), Jian Bo Shui Kueh `ve_e2325ed446` (Bib card Jian Bo Tiong Bahru Shui Kueh, Jurong West; a separate Selected card Jian Bo Shui Kueh matches the old address). Names go first in the rename batch.
4. Imperial Treasure 2026 One Star on live venue `ve_bf2230cf37`.
5. Alma and Esora closed, published false. Alma goes on the recheck list.
6. 4 sourced 2025 One Star rows added. Chaleur: no venue, hold register.
7. Eminent Frog Porridge `ve_3c60e6d1a2` (row 12186) and Soon Huat `ve_d6a6b6aac1` (row 12240): rows stay as 2025 history, status active.
8. No rename or price change. 36 names go to the rename batch (evidence CSV: `name differs`, plus Imperial Treasure). 19 venues with no price go to the price item (17 new, Imperial Treasure, Tai Wah Pork Noodle). 1 price difference goes there: Shisen Hanten `$$` to card `$$$`.

## Hold register (no rows)
Chaleur: One Star 2025, card 404, closed in 2025 per VnExpress, Aug 5, 2026. Green Stars 2026 (2): Fiz, Seroja. Special awards 2026: Service Maryjoy Lim (Jag), Sommelier Joe Yang (Jin Ting Wan), Young Chef Shusuke Kubota (Loca Niru), Opening of the Year 1887 by André.

## Weak points
- Alma: a new concept was announced in 2025 and I did not find a reopening. It holds an OAD 2026 row.
- Chaleur: one press source.
- Eminent Frog and Soon Huat: card 404, not on the Selected list, no closure report. No evidence shows that they are open today.
- 125 of the 130 Singapore rows labelled 2025 have no URL.
- Card prices are from `/us/en/`. `/sg/en/` was not read.
- The pair test by address used `data/venues.json` (old site file). Those addresses were not written.
- Singapore 2027 date: not read.

## Open items, in order
1. **Rest of the launch list.** Michelin: **South Korea (next available now)**, Canada, Portugal, Mexico, US gap. Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Michelin Latvia 2027 (new, Ben, Nov 5).** Out as of Nov 5. Not started. The launch list holds Latvia on the "if time remains" list with 7 rows and no 2026 rows (read Nov 5).
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. Ah Boy `ve_8170285a94`. OPUS (Vienna). New: Alma `ve_8b5854c9bd` (reopening), Eminent Frog `ve_3c60e6d1a2`, Soon Huat `ve_d6a6b6aac1`. New, not read closely: The Peak (2025) names Oshino `ve_d783347096` and Shinji by Kanesaka, Bras Basah Road `ve_645ec68d75` as closed; both are active.
5. **Cervia pair.** See the Top 500 handoff. Same-name pairs in neighbor cities, not merged: Rossbarth (`ve_501866509c`, `ve_48c9f68107`), Restaurant GuatzEssen (`ve_084f389fc1`, `ve_e6eb49f5b1`).
6. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff, the 85 of the Thailand handoff, the 96 of the Austria handoff and these 36. Fix first: the Top 500 list, Kedai Jual Beli Duit Lama (card Lama), Baan Kun Pra (card Baan Pu Karn), Aurea Fine Dining (card RAR Fine Dining), Wirtshaus `ve_66510fec11` (card Rouge Noir), Döllerers Wirtshaus `ve_514ac623be` (card Döllerer), Wirtshaus Lilli `ve_c988d005ee` (card Lilli Fine Dining), and from this batch: Heng Watch, Soon Huat Goldsmith Pte Ltd (card Soon Huat), Du Du Cooked Food (#01-10), Thai Seng Fish Soup, Jian Bo Shui Kueh, Newton Authentic Song Kee Teochew Fish Porridge.
7. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026. New: 125 Singapore rows labelled 2025.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started.
10. **Plan v1.31.** Add this write, the Austria write, the Thailand write, the Malaysia write, the Top 500 write and the 50 Best write.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Singapore list read:** selection `singapore`, slugs `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`, with `/page/N`. Same-origin `fetch()` plus `DOMParser`. Keep `.card__menu` whose `h3 a` href holds `/singapore-region/`: the page also holds US cards. Distinction: `[data-dtm-distinction]` inside the card.
- **Article list read:** names and card links are `a` tags inside `h3` tags, one `h3` per tier. A plain `li` or `p` read returns nothing.
- **Edition after the capture window:** when the ceremony is after June 1, 2026, add new rows and keep the legacy rows. Compare the legacy rows with the earlier edition article too: this finds missing history rows.
- **Cards that left the guide:** the old card slugs are in the links of the earlier article. Fetch them for a 404.
- **Saving a relay:** the Write tool turns `\uXXXX` into the character. Escape again with a script, then compare the hash.

## Dead ends: do not retry
- Selecting cards by `data-restaurant-country` or by `data-dtm-distinction` on the card itself: on this page the card has neither. See the method above.
- `pglast` is not installed by default: `pip install pglast --break-system-packages`.
- `awards.source_slug` (the column is `source_id`).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-singapore-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 318, audit_log 132,650, venues 11,691 (active 11,384, closed 307), awards 28,519,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,635, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,384. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Michelin South Korea: read the list from the publisher and check first that it is complete. Find the edition on the site today and the edition that the live rows hold, from a guide.michelin.com URL, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
