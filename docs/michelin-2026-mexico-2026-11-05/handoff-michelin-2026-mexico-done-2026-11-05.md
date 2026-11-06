# Handoff: Michelin Mexico 2026, write done. Nov 5, 2026 (22:35 Atlanta). Next: US gap now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-portugal-done-2026-11-05.md` for the live state and the open items. That file still holds the Portugal method, decisions and hold register. The Canada handoff holds the "several guides" method. The South Korea handoff holds its method and "fix first" list. The Singapore handoff holds the "edition after the capture window" method. The Austria handoff holds the relabel method. The Thailand handoff holds the Thailand 2027 details. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 22:25 "1-5:A". 22:30 "Go".

## Live state (read Nov 6, 03:32:48 UTC, whole tables)
Venues **11,716** (active **11,408**, closed 308). Awards **28,681** (last id **35,852**). Michelin 2025 / 2026 / 2027 rows **4,365 / 7,470 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,660** (canonical 11,716). Price 7,759. Listings **11,716**. city_label_source **24,839**. city_aliases 222. Redirects 35. Cities **3,325**, `cities.venues_count` sum **11,408**. Ledger **274** rows, last id **328**. audit_log **127,360** rows, last id **133,189**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-mexico-2026-11-05/load-michelin-2026-mexico-2026-11-05.sql` (sha256 `2578a10be9d8fcc41cbf9bd19bd5a76e9e9987fbd95a7a56100d3fae084283d1`). Write connector, first try, 1 transaction, 03:32:24 UTC, all gates passed. The text sent left out the header comment lines and the `--` section comments of the file. The executable text was copied from the file, and the plan text gates (md5) passed.

| Item | Change |
|---|---|
| Relabel | 6 star rows, year 2025 to 2026, `/us/en/` card URL: Alcalde 9159, Xokol 9171, Gaba 9174, La Once Mil 9175, Huniik 9181, Ixi'im 9185 |
| Rows that stay 2025 | 70 rows, no URL: Two Stars 2, One Star 20, Bib 48. Retire 0 |
| New awards, 2026 | 86 rows in ids 35,765-35,852: 85 with a `/us/en/` card URL, Pink Rambo with the Bib article URL |
| New awards, 2025 | 2 rows in ids 35,765-35,852, article URL: Em One Star, Gaba Bib Gourmand |
| New venues | 17, card name, restaurant, active, published. No price, address, geo, blurb or chef: La Barra de Huniik `ve_5342363b44`, Pancho Maiz `ve_d61f94b915`, Taquerias Kisin `ve_19e5819f1f` (Merida); palReal `ve_9b01479b3e`, Tacos Y Gorditas Elvira `ve_5b8e0c0e3f` (Guadalajara); Cultivo `ve_900970374a`, El Guero Marinero `ve_7e165504c0`, Jacinto y Yo `ve_bd35996e14`, Los Camellos `ve_b34ba0e04d`, Moyuelo `ve_0e1e215fee`, Restaurante Casareyna `ve_831ed1f088`, Semitas "Beto" `ve_c1e10388c1` (Heroica Puebla); El Bambis Cafe `ve_46932b468d` (Monterrey, card San Pedro Garza Garcia); Molino El Pujol `ve_bd6fe7945c` (Mexico City, card Cuauhtemoc); ICU `ve_f89d409530`, Vica Cocina de un Valle `ve_42f5c25058`, Pueblo Pibil `ve_7c4ad70c5a` (new cities) |
| New cities | Atlixco `ci_be6c3d6ac7`, Puerto Vallarta `ci_602b473fc7`, Tixkokob `ci_f92002cdbf`, each `venues_count` 1 |
| City counts | Guadalajara 5 to 7. Heroica Puebla 1 to 8. Merida 3 to 6. Mexico City 68 to 69. Monterrey 5 to 6 |
| Ledger | 326 award (relabel, 6), 327 award (88), 328 city_label (34) |
| audit_log | 133003-133189 (187). awards INSERT 88, awards UPDATE 6, cities INSERT 3, cities UPDATE 5, city_label_source INSERT 34 (by hand), listings INSERT 17, slugs INSERT 17, venues INSERT 17 |

Mexico Michelin rows after the write, read back: 2026 labelled 92 (Two Stars 2, One Star 27, Bib 63), 92 with a URL, 92 distinct URLs, 1 of them an article URL. 2025 labelled 72 (Two Stars 2, One Star 21, Bib 49), 2 with a URL.

**No change to:** names, price, redirects, city aliases, `award_categories`, venue status. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-mexico-evidence-2026-11-05.csv` (95 rows). List read: `relay-mx-2026-list-pages-2026-11-05.txt` (sha256 `eaa8b76fce43958a96549ce20537c6f5871a1fb48ca997be71617c08cd03b549`, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (sha256 `c6badf5efa5dffd8667f862dac2e7fcf11503475ea7c4631d8ee0c84b0998a75`, equal to the browser). Plan: `pairs.tsv`. Live read: `live-read.txt` (md5 of the sorted lines `a644da869a5c0f0cc19d8c9f999b61c4`, equal to the database). Scripts: `pairs_build.py`, `build_sql.py`, `evidence.py`.

## List check
Population: selection `mexico`, `/us/en/`, built-in browser, Nov 5. Site list 91 rows = page banners 2 / 27 / 62, read again at 22:26 ET. Star article 29 of 29 paths on the site list, and the site list has no other star. Bib article 63 paths (16 new): 62 on the site list, Pink Rambo not. All 91 venue pages return 200, say "2026 MICHELIN Guide" and agree on tier. The closed test found 0, and that test is a text match written for this run. The `3-stars-michelin` slug gives a 404 because Mexico has none. Below Bib, not in scope: 133 Selected (browser hash `e3b090da721be0b99aa9d5b08104d8361b2bdf3f5f6d9d2df31d02b6f4cc5cda`, file not saved).

Sources: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-mexico-for-2026-and-the-year-s-key-trends and https://guide.michelin.com/us/en/article/michelin-guide-ceremony/mexico-s-most-affordable-restaurants-in-2026 (both May 20, 2026).

## Label check
Population: Michelin rows on Mexico venues, 76 rows, read before the write. All labelled 2025, 0 with a URL: Two Stars 2, One Star 26, Bib 48. Capture window: May 13 to June 1, 2026. The ceremony of May 20, 2026 is **inside the window**, so rule 2.1.1 requires the named promotion test.
- **New stars 2026, population 7:** 6 in the live rows at One Star. La Barra de Huniik absent.
- **New Bibs 2026, population 16:** 0 in the live rows at Bib. Fauna is a live venue with no Michelin row.
- **Result: mixed.** The test does not put Mexico in one row of the rule table. Ben chose a decision per row.
- **2025 edition:** 2 / 21 / 50. Stars: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-mexico-stars-green-stars (June 3, 2025). Bib banner: https://web.archive.org/web/20250615000512/https://guide.michelin.com/us/en/selection/mexico/restaurants/bib-gourmand. New Bibs: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-mexico-bib-gourmand-2025.
- The live Bib rows = the 50 of Wikipedia, minus Gaba (One Star in the live rows) and Molino El Pujol (absent): https://en.wikipedia.org/wiki/List_of_Michelin_Bib_Gourmand_restaurants_in_Mexico.
- **2027:** no edition found. Not from a dated Michelin URL.

## Pair check
Population: 91 cards. Paired to a live row 72 (same name 51, name differs 21). Live venue with no Michelin row 2 (Em, Fauna). New venue 17. Tier change 0. Live rows with no card on the list: 4 (El Califa de Leon, Alfonsina, Voraz, Pink Rambo). Address test, population 72: same postcode 63, same street number 5, no old address 1, different 3 (Damiana: old address is wrong, Mexico City. HA': old address holds only the city. Plonk: the street differs, possibly moved).

## Decisions (Ben, all A)
1. Relabel only the 6 rows that cannot be 2025. 70 rows stay 2025. Add 85 card rows for 2026. Retire 0. These URLs will repeat when Mexico 2027 loads: the `url in use` gate of the 2027 file must allow them.
2. Pink Rambo `ve_55222b26b4`: 2026 Bib row with the article URL. Row 9966 stays 2025. Active, on the recheck list. Card 404, not on the Selected list, 0 CDX captures in 2026, no closure source found.
3. El Califa de Leon `ve_914842591c` and Alfonsina `ve_1d246aac4c`: active, 2025 rows stay (Oct 10 ruling, both on the Selected list). Voraz `ve_4bbcc58a9b`: active, row stays 2025, on the recheck list. Card 404, not on the Selected list.
4. 2 sourced 2025 rows added: Em One Star, Gaba Bib. Molino El Pujol 2025 goes to the history backfill.
5. 17 new venues, 3 new cities. No rename, price or city change. 21 names go to the rename batch (evidence CSV: `name differs`). Price items: Xokol `$$$$` to card `$$$`, and 19 venues with no price (17 new, Em, Fauna). City items for Phase 3: Le Chique `ve_da655a493a` is in Puerto Morelos, card Playa del Carmen. Lunario `ve_27c9173de4` is in Guadalupe, card El Porvenir. Benito Juarez and Tlalpan are separate cities, not Mexico City.

## Hold register (no rows)
Green Stars 2026 and special awards 2026: not read. The 2025 edition holds 8 Green Stars (article above).

## Weak points
- The reason that the live rows mix 2 editions is not known. The `audit_log` shows only the load of Aug 14, 2026.
- Only page 1 of the June 2025 archive capture was read: 20 of 50 names, and all 20 are in the live rows. The full match rests on Wikipedia.
- The 2 sourced 2025 rows use `/en/` article URLs, read through a WebFetch summary.
- The Voraz and Pink Rambo status reads are search result lists only. The pages were not opened.
- The tier came from the list page and agrees with each venue page. The article lists were typed into `evidence.py` from the browser read.
- The address test used `data/venues.json` (old site file). Those addresses were not written.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.

## Open items, in order
1. **Rest of the launch list.** Michelin: **US gap (next available now)**: 225 of 490 2026 rows had no URL, read again first. Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Michelin Latvia 2027 (Ben, Nov 5).** Out as of Nov 5. Not started. The launch list holds Latvia on the "if time remains" list with 7 rows and no 2026 rows (read Nov 5).
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayer + Elementary. Ah Boy `ve_8170285a94`. OPUS (Vienna). Alma `ve_8b5854c9bd` (reopening), Eminent Frog `ve_3c60e6d1a2`, Soon Huat `ve_d6a6b6aac1`, Aburi Hana `ve_7b26d42de5` (new concept). O Tipico `ve_eb0e147299` (card 404). New: Pink Rambo `ve_55222b26b4`, Voraz `ve_4bbcc58a9b` (cards 404). Plonk `ve_4311d111a0` (possibly moved). Not read closely: The Peak (2025) names Oshino `ve_d783347096` and Shinji by Kanesaka, Bras Basah Road `ve_645ec68d75` as closed; both are active.
5. **Cervia pair.** See the Top 500 handoff. Same-name pairs in neighbor cities, not merged: Rossbarth (`ve_501866509c`, `ve_48c9f68107`), Restaurant GuatzEssen (`ve_084f389fc1`, `ve_e6eb49f5b1`). Restaurant 20 Victoria `ve_fbf2d9f536` and 20 Victoria St `ve_27302ae41b`, same city.
6. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff, the 85 of the Thailand handoff, the 96 of the Austria handoff, the 36 of the Singapore handoff, the 36 of the South Korea handoff, the 30 of the Canada handoff, the 30 of the Portugal handoff and these 21. "Fix first" list: see the South Korea handoff.
7. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026, the 125 Singapore rows labelled 2025, the 70 Canada rows labelled 2025, and the 70 Mexico rows labelled 2025.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started. New: the 2 Mexico venues and 2 borough cities above.
10. **Plan v1.31.** Add this write, the Portugal write, the Canada write, the South Korea write, the Singapore write, the Austria write, the Thailand write, the Malaysia write, the Top 500 write and the 50 Best write. Add the mixed result of the named promotion test: the rule table holds no row for it.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Ceremony inside the capture window:** test new stars and new Bibs separately, by tier. One tier can hold the new edition and another tier the old edition.
- **Mixed result, decision per row:** relabel only rows that the earlier edition proves cannot carry the old label. Keep rows that are true of the old edition, and add new rows with the card URL. Compare the kept rows with the earlier edition to find missing history rows.
- **Mexico list read:** selection `mexico`, slugs `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`, with `/page/N`. Same-origin `fetch()` plus `DOMParser`. Keep `.card__menu` whose first `.card__menu-footer--score` ends with `Mexico`: each page also holds 4 US cards.
- **Mexico boroughs:** card cities Cuauhtemoc, Miguel Hidalgo (site spelling "Miguel Hildalgo") and Alvaro Obregon go to Mexico City by alias. San Pedro Garza Garcia goes to Monterrey, Valle de Guadalupe to Guadalupe, by alias.
- **Tier regex on a venue page:** ` restaurant in the (20\d\d) MICHELIN Guide` with up to 60 characters before it holds "a One Star" or "a Bib Gourmand". Test with a substring.
- **Archived list page:** the banner of a page 1 capture gives the total of an old edition, when page 2 has no capture.

## Dead ends: do not retry
- `/us/en/ciudad-de-mexico/cuauhtemoc_1995126/restaurant/pink-rambo` and `.../voraz`: 404.
- CDX in 2026 for the Pink Rambo card, population 23 locale and path forms: 0 captures. The `/us/en/` card has a capture of Nov 5, 2025 only (2025 edition).
- CDX for `/selection/mexico/restaurants/bib-gourmand/page/2` and `/1-star-michelin`: 0 captures. `/restaurants` has a capture of Aug 1, 2026 (not read).
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-mexico-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 328, audit_log 133,189, venues 11,716 (active 11,408, closed 308), awards 28,681,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,660, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,408. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start the Michelin US gap: read the live rows again first, then read the list from the publisher and check first that it is complete. Find the edition on the site today and the edition that the live rows hold, from a guide.michelin.com URL, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
