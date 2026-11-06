# Handoff: Michelin South Korea 2026 label, write done. Nov 5, 2026 (21:10 Atlanta). Next: Canada now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-singapore-done-2026-11-05.md` for the live state and the open items. That file still holds the Singapore method, decisions and hold register. The Austria handoff holds the relabel method. The Thailand handoff holds the Thailand 2027 details. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 21:08 "1-6 A, go". The choices and the "go" came in one message. The fresh read came next, then the write.

## Live state (read Nov 6, 02:10:10 UTC, whole tables)
Venues **11,691** (active **11,384**, closed **307**). Awards **28,519** (last id **35,690**). Michelin 2025 / 2026 / 2027 rows **4,483 / 7,190 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,635** (canonical 11,691). Price 7,759. Listings **11,691**. city_label_source **24,789**. city_aliases 222. Redirects 35. Cities 3,321, `cities.venues_count` sum **11,384**. Ledger **265** rows, last id **319**. audit_log **126,938** rows, last id **132,767**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-south-korea-2026-11-05/load-michelin-2026-south-korea-2026-11-05.sql` (sha256 `adf7feea3a4cc9ea09bcbddcd4129ffc86a3dfaf80b63494662f3ca6d24ee93b`). Write connector, first try, 1 transaction, 02:10:03 UTC, all gates passed. The text sent left out the header comment lines of the file. The executable text is the same.

| Item | Change |
|---|---|
| Relabel | 117 rows, Michelin South Korea, year 2025 to 2026, retire 0 (rules 2.1.1 and 2.1.7). URL: the `/us/en/` card on all 117 rows. Row 4389 (ARP) changed from the `/kr/en/` card URL |
| Ledger | 319 award |
| audit_log | 132651-132767 (117). awards UPDATE 117 |

South Korea Michelin rows after the write: 2026 labelled 117 (Three Stars 1, Two Stars 10, One Star 35, Bib 71), 117 with a distinct URL. 2025 labelled 0.

**No change to:** venues, names, price, status, slugs, redirects, city aliases, `award_categories`. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-south-korea-evidence-2026-11-05.csv` (sha256 `941c67295b52bcc3292827e91d4665f332f271c8df2bc211e4d151fee83f5ed1`). List read: `relay-kr-2026-list-pages-2026-11-05.txt` (sha256 `6f43f5825ab792cd64a0a62e1f504004a6a670047ab536d446c337217efdf8a4`, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (sha256 `39c674d20d812a4952df4630cc72256790ae72d8e1b68aa1bb5c91ab52703876`, equal to the browser). Plan: `pairs.tsv`. Live read: `live-read.txt` (sha256 `ee70edd86831c8cce7efdc26598e7d60fd0ead0ce156320cdf6e53111f4e9871`, equal to the database). Scripts: `pairs_build.py`, `build_sql.py`, `evidence.py`.

## List check
Population: selection `south-korea`, `/us/en/`, built-in browser, Nov 5. Site list 117 rows = page banners 1 / 10 / 35 / 71 = articles of Mar 5, 2026 (https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-michelin-guide-seoul-busan-2026) and Feb 25, 2026 (https://guide.michelin.com/en/article/michelin-guide-ceremony/korea-bib-gourmand-2026). All 46 star names in the article are on the site list. The Bib article gives 8 new names as text and the full list of 71 as an image. All 117 venue pages return 200, say "2026 MICHELIN Guide" and agree on tier. 0 pages say closed. Below Bib, not in scope: 120 Selected (browser hash `1d1ad6f4917d8fbb406affdb309fccf410970045621477afd37709fecd9459d4`, file not saved).

## Label check
Edition on the site today: 2026, ceremony Mar 5, 2026 (https://guide.michelin.com/kr/en/article/michelin-guide-ceremony/2026-save-the-date), before the capture window. 2027: not out. Article of Aug 20, 2026 (https://guide.michelin.com/kr/en/article/dining-out/2027-pre-release-6-new-restaurants-join-michelin-guide-seoul-busan) names 6 new Selected and says "next spring". Population: Michelin rows on South Korea venues, 117 rows, read before the write: 1 / 10 / 35 / 71, 0 rows labelled 2026. The 2025 edition has 1 / 9 / 30 / 77 (articles of Feb 26, 2025 and Feb 20, 2025). The live rows hold all 10 new or promoted stars and all 8 new Bibs of 2026.

## Pair check
Population: 117 cards. Same name 81. Name differs 36. New venue 0. New row 0. Tier change 0. Row order test, population 101 rows (Busan Bib 19, Seoul Bib 51, Seoul One Star 31): the row ids follow the alphabetical order of the card names, 0 rows out of order. Address test, population 117 cards: same street and number 89, same street and other number 1, same place in another address form 8, old lot address not provable 6, other street 8, area only 1, no old address 4.

## Decisions (Ben, all A)
1. Relabel 117 rows, retire 0, `/us/en/` card URL. These URLs will repeat when South Korea 2027 loads: the `url in use` gate of the 2027 file must allow them.
2. Row 4389 (ARP) takes the `/us/en/` card URL.
3. 5 weak pairs stay: 서울컬리지(Seoul College) `ve_eb42674bb6` row 7932 (card Collage), Oncheonjip `ve_5c2458b538` row 9657 (card Songheonjip), 안목해변 `ve_b21afea084` row 9642 (card Anmok), Hapjeong-dong `ve_c7bc08d362` row 12092 (card Hapjeongok), Gaeseong Mandu Koong Yeonhui branch `ve_7ef4ee5e45` row 12085 (card Gaeseong Mandu Koong, Insadong). Names go first in the rename batch.
4. Hakusi, Fiotto, Muni, Okdolhyunok stay paired: name and tier agree, the old address is on another street.
5. No 2025 history rows now. South Korea holds 0 rows labelled 2025. The 2025 edition goes to the history backfill.
6. No rename, price or status change. 36 names go to the rename batch (evidence CSV: `name differs`). 6 price differences go to the price item: L'Amitié, Légume, Palate, Youhan, Ggupdang, Jaha Son Mandu, all with a lower live tier than the card.

## Hold register (no rows)
Green Stars 2026 (4): Gosari Express, Gigas, Mitou, Fiotto. Special awards 2026 (4): Sommelier Jung-in Lee (GiwaKang), Service Il-woo Kim (Gucci Osteria da Massimo Bottura), Young Chef Chang-uk Kim (Le DORER), Opening of the Year An Lee (IAán).

## Weak points
- The 5 weak pairs rest on the row order test and the counts, not on an address or a name.
- 63 of the 71 Bib names have no article text: the full list is an image. Evidence: the total of 71 and the site list.
- Article text came through the WebFetch summary. The list and venue pages came from the browser.
- 116 of the 117 live prices use `$`. The tier test compares length only. Card prices are from `/us/en/`. `/kr/en/` was not read.
- The pair test by address used `data/venues.json` (old site file). Those addresses were not written.
- South Korea 2027 date: "next spring", no date read.

## Open items, in order
1. **Rest of the launch list.** Michelin: **Canada (next available now, 3 guides)**, Portugal, Mexico, US gap. Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Michelin Latvia 2027 (Ben, Nov 5).** Out as of Nov 5. Not started. The launch list holds Latvia on the "if time remains" list with 7 rows and no 2026 rows (read Nov 5).
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. Ah Boy `ve_8170285a94`. OPUS (Vienna). Alma `ve_8b5854c9bd` (reopening), Eminent Frog `ve_3c60e6d1a2`, Soon Huat `ve_d6a6b6aac1`. Not read closely: The Peak (2025) names Oshino `ve_d783347096` and Shinji by Kanesaka, Bras Basah Road `ve_645ec68d75` as closed; both are active.
5. **Cervia pair.** See the Top 500 handoff. Same-name pairs in neighbor cities, not merged: Rossbarth (`ve_501866509c`, `ve_48c9f68107`), Restaurant GuatzEssen (`ve_084f389fc1`, `ve_e6eb49f5b1`).
6. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff, the 85 of the Thailand handoff, the 96 of the Austria handoff, the 36 of the Singapore handoff and these 36. Fix first: the Top 500 list, Kedai Jual Beli Duit Lama (card Lama), Baan Kun Pra (card Baan Pu Karn), Aurea Fine Dining (card RAR Fine Dining), Wirtshaus `ve_66510fec11` (card Rouge Noir), Döllerers Wirtshaus `ve_514ac623be` (card Döllerer), Wirtshaus Lilli `ve_c988d005ee` (card Lilli Fine Dining), Heng Watch, Soon Huat Goldsmith Pte Ltd (card Soon Huat), Du Du Cooked Food (#01-10), Thai Seng Fish Soup, Jian Bo Shui Kueh, Newton Authentic Song Kee Teochew Fish Porridge, and from this batch: the 5 weak pairs, 강민철 레스토랑, 가겐 by 최준호, 안덕, 마포옥 한우양지설렁탕, 유한. Slugs to fix with these names: `seoul/seoul-college`, `busan/oncheonjip`, `busan/busan-o8vmuu`, `seoul/hapjeong-dong`, `seoul/seoul-kgy9nk`, `seoul/seoul-uclbsy`, `seoul/seoul-mdnsui`.
7. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026, and the 125 Singapore rows labelled 2025.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started.
10. **Plan v1.31.** Add this write, the Singapore write, the Austria write, the Thailand write, the Malaysia write, the Top 500 write and the 50 Best write.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **South Korea list read:** selection `south-korea`, slugs `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`, with `/page/N`. Same-origin `fetch()` plus `DOMParser`. Keep `.card__menu` whose first `.card__menu-footer--score` ends with `South Korea`: the page also holds US cards.
- **Row order test:** sort the legacy rows by award id, by city and tier. Put the paired card name next to each id. The legacy rows were loaded in alphabetical order of the source names, so a wrong map name shows its source name by its position. This is good proof for a weak pair. Script: the last loop of `evidence.py`.
- **Live read hash:** `encode(sha256(convert_to(string_agg(...),'UTF8')),'hex')` in the Read connector. Compare with the saved file.
- **Saving a relay by Bash heredoc:** the tool input also turns `\uXXXX` into the character. Save a `.raw` file, escape again with a script, compare the hash, and only then delete the `.raw` file.
- **Address test text:** many old addresses are in Korean or lot form, so the script reports them as "different place". Read that list by eye.

## Dead ends: do not retry
- `cities.name` (the column is `display`).
- Opening `.raw` with `encoding='ascii'` after a heredoc: the tool already turned the escapes into characters.
- `guide.michelin.com/kr/en/busan-region/busan_1025838/restaurant/oncheonjip` with WebFetch: client error, no page.
- `enprimeurclub.com`: ignore it in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-south-korea-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 319, audit_log 132,767, venues 11,691 (active 11,384, closed 307), awards 28,519,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,635, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,384. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Michelin Canada (3 guides): read the lists from the publisher and check first that each is complete. Find the edition on the site today and the edition that the live rows hold, per guide, from a guide.michelin.com URL, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
