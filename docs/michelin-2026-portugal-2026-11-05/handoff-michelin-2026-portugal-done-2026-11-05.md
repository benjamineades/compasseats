# Handoff: Michelin Portugal 2026, write done. Nov 5, 2026 (22:05 Atlanta). Next: Mexico now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-canada-done-2026-11-05.md` for the live state and the open items. That file still holds the Canada method, decisions and hold register, and the "several guides" method. The South Korea handoff holds its method and "fix first" list. The Singapore handoff holds the "edition after the capture window" method. The Austria handoff holds the relabel method. The Thailand handoff holds the Thailand 2027 details. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 22:02 "1-5: A". 22:03 "Go".

## Live state (read Nov 6, 03:05:13 UTC, whole tables)
Venues **11,699** (active **11,391**, closed 308). Awards **28,593** (last id **35,764**). Michelin 2025 / 2026 / 2027 rows **4,369 / 7,378 / 122**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,643** (canonical 11,699). Price 7,759. Listings **11,699**. city_label_source **24,805**. city_aliases 222. Redirects 35. Cities **3,322**, `cities.venues_count` sum **11,391**. Ledger **271** rows, last id **325**. audit_log **127,173** rows, last id **133,002**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2026-portugal-2026-11-05/load-michelin-2026-portugal-2026-11-05.sql` (sha256 `ff5e6c42cf5ab1d04651f2d608d9a64385bebac12e0989d85b269201955507f4`). Write connector, first try, 1 transaction, 03:04:46 UTC, all gates passed. The text sent left out the header comment lines of the file. The executable text was copied from the file, and the plan text gates (md5) passed.

| Item | Change |
|---|---|
| Relabel | 78 rows, year 2025 to 2026, retire 0 (rules 2.1.1 and 2.1.7). 77 rows get the `/us/en/` card URL. O Tipico `ve_eb0e147299` (award 13031) gets the archive URL of June 1, 2026 |
| New award, 2026 | 1 row, id 35,764: A Cozinha do Paço, One Star, `/us/en/` card URL |
| New venue | A Cozinha do Paço `ve_ce7726880f`, card name, restaurant, active, published. No price, address, geo, blurb or chef |
| New city | Évora `ci_4b3712949e`, slug `evora`, Portugal, PT, `venues_count` 1 |
| Ledger | 323 award (relabel, 78), 324 award (1), 325 city_label (2) |
| audit_log | 132918-133002 (85). awards UPDATE 78, awards INSERT 1, venues INSERT 1, listings INSERT 1, slugs INSERT 1, cities INSERT 1, city_label_source INSERT 2 (by hand) |

Portugal Michelin rows after the write: 2026 labelled 79 (Two Stars 9, One Star 44, Bib 26), 79 with a URL, 79 distinct URLs. 2025 labelled 0.

**No change to:** names, price, redirects, city aliases, `award_categories`, O Tipico status. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2026-portugal-evidence-2026-11-05.csv` (sha256 `ce34a46859198ce2f35d228fb619859fa2fd6041e15c750a4481f39400169709`, 79 rows). List read: `relay-pt-2026-list-pages-2026-11-05.txt` (sha256 `717227e03a4005fdfa8c522424f834d74c6bfa7452f892e8b2b1442accc9882a`, equal to the browser). Venue pages: `venue-pages-read-2026-11-05.tsv` (sha256 `b402c9b3c019ea9e2b3a55f37b2aa63f6ed0c0f3cb76b9c0231d09e20a32101e`, equal to the browser). Plan: `pairs.tsv`. Live read: `live-read.txt` (md5 of the sorted lines `20a67bb2cdd9fa7218fbadc0884e6c56`, equal to the database). Scripts: `pairs_build.py`, `build_sql.py`, `evidence.py`.

## List check
Population: selection `portugal`, `/us/en/`, built-in browser, Nov 5. Site list 78 rows = page banners 9 / 44 / 25, read again at 22:02 ET. Ceremony counts 9 / 44 / 26 = 79. All 53 star names of the article are on the site list, and the site list has no other star names. All 78 venue pages return 200 and say "2026 MICHELIN Guide". 0 pages say closed. The `3-stars-michelin` slug gives a 404 because Portugal has none. Below Bib, not in scope: 123 Selected on the site (browser hash `105d83f05fa74bf46ac14f2251d3d243384e9b31cbe547fd50358790639ca300`, file not saved), 131 in the press release.

Sources: https://guide.michelin.com/en/article/michelin-guide-ceremony/All%20About%20the%20MICHELIN%20Guide%20Portugal%202026 (ceremony March 10, 2026, Savoy Palace, Funchal; 210 restaurants), https://guide.michelin.com/en/article/michelin-guide-ceremony/All%20MICHELIN-Starred%20Restaurants%20in%20Portugal%202026, https://espacioprensa.michelin.es/wp-content/uploads/2026/03/CP_Guia-MICHELIN-Portugal-2026_EN.pdf.

## Label check
Population: Michelin rows on Portugal venues, 78 rows, read before the write. All labelled 2025, 0 with a URL: Two Stars 9, One Star 43, Bib 26. Capture window: May 13 to June 1, 2026. The 2026 ceremony is before the window. The 2025 edition (Feb 25, 2025) has 8 / 38 / 28.
- Change test, population 13 new names of 2026 (1 Two Stars, 10 One Star, 2 Bib): 12 are in the live rows at the correct tier. A Cozinha do Paço is absent.
- Arkhe (One Star 2025) is not in the live rows and not on the site list.
- **2027:** no edition found. Press release of Sep 15, 2026 gives March 2027, Coimbra (https://www.sabado.pt/comunicados-imprensa/detalhe/centro-de-portugal-cria-roteiro-rumo-a-gala-michelin-2027). Not from a Michelin URL.

## Pair check
Population: 78 cards. Same name 47. Name differs 30. New venue 1. Tier change 0. Live rows with no card: 1 (O Tipico). Address test, population 77 paired venues: same postcode 60, same street number 7, same first 4 postcode digits 6, no old address 2 (Alameda, Kappo), address differs 2 (O Javali shows "KM 5" in both; old MAPA address is a map code in the same city). Carnal has a different street in the old file, and possibly moved.

## Decisions (Ben, all A)
1. 77 rows with a card: relabel to 2026 with the card URL, retire 0. These URLs will repeat when Portugal 2027 loads: the `url in use` gate of the 2027 file must allow them.
2. O Tipico row 13031: relabel to 2026 with the archive URL https://web.archive.org/web/20260601200735id_/https://guide.michelin.com/pt/pt_PT/aveiro-region/gueda/restaurant/o-tipico. The capture says "2026 MICHELIN Guide" and Bib Gourmand.
3. O Tipico stays active and goes on the recheck list. Card 404 on Nov 5. Not on the Selected list. Notícias de Águeda, Apr 4, 2026: Bib renewal (https://noticiasdeagueda.sapo.pt/o-tipico-renova-distincao-bib-gourmand-e-mantem-reconhecimento-do-guia-michelin-ha-mais-de-uma-decada/). TripAdvisor shows it open, and 1 visitor found it closed on Sep 28, 2026. No source says it closed permanently.
4. A Cozinha do Paço: new venue, card name, new city Évora.
5. No rename, price or city change. 30 names go to the rename batch (evidence CSV: `name differs`). 6 price items: O Javali `$$` to card `€`, Casa Chef Victor Felisberto `$` to `€€`, Camelo `$` to `€€`, Encanto `$$$` to `€€€€`, Kanazawa `$$$$` to `€€€`, YŌSO `$$$` to `€€€€`, plus A Cozinha do Paço with no price. 2 city items for Phase 3: Vinha `ve_06c15a6bb1` and The Yeatman `ve_63b7b5b6e1` are in Porto, cards say Vila Nova de Gaia. That city does not exist in the database.

## Hold register (no rows)
Special awards 2026: Young Chef Francisco Quintas (Largo do Paço), Service Adácio Ribeiro (Vila Foz), Sommelier Carlos Monteiro (Casa de Chá da Boa Nova), Opening of the Year JNĉQUOI Table. Green Star 2026: A Cozinha do Paço is the new one. The other 6 are not read.

## Weak points
- No full Bib list was found in an article. The 25 Bibs rest on the site list and the banner. The total of 26 rests on the press release.
- The tier came from the list page, not from each venue page.
- The archive URL is the `pt_PT` card, because no `/us/en/` capture exists. The capture read was in the browser, and is not saved as a file.
- The Michelin articles came through a WebFetch summary. The star names in `evidence.py` were typed from that summary.
- The address test used `data/venues.json` (old site file). Those addresses were not written.
- The 8 Selected cards and the O Tipico card left the site after the ceremony. The reason was not read.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.

## Open items, in order
1. **Rest of the launch list.** Michelin: **Mexico (next available now)**, US gap. Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Michelin Latvia 2027 (Ben, Nov 5).** Out as of Nov 5. Not started. The launch list holds Latvia on the "if time remains" list with 7 rows and no 2026 rows (read Nov 5).
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** Dram Bar `ve_9cdafd245d`. Everson Royce Bar: read after Dec 20, 2026, then close. Tayēr + Elementary. Ah Boy `ve_8170285a94`. OPUS (Vienna). Alma `ve_8b5854c9bd` (reopening), Eminent Frog `ve_3c60e6d1a2`, Soon Huat `ve_d6a6b6aac1`, Aburi Hana `ve_7b26d42de5` (new concept). New: O Tipico `ve_eb0e147299` (card 404). Not read closely: The Peak (2025) names Oshino `ve_d783347096` and Shinji by Kanesaka, Bras Basah Road `ve_645ec68d75` as closed; both are active.
5. **Cervia pair.** See the Top 500 handoff. Same-name pairs in neighbor cities, not merged: Rossbarth (`ve_501866509c`, `ve_48c9f68107`), Restaurant GuatzEssen (`ve_084f389fc1`, `ve_e6eb49f5b1`). Restaurant 20 Victoria `ve_fbf2d9f536` and 20 Victoria St `ve_27302ae41b`, same city.
6. **Rename batch.** The 63 names of the 50 Best handoff, the 114 of the Top 500 handoff, the 33 of the Malaysia handoff, the 85 of the Thailand handoff, the 96 of the Austria handoff, the 36 of the Singapore handoff, the 36 of the South Korea handoff, the 30 of the Canada handoff and these 30. "Fix first" list: see the South Korea handoff.
7. **Archive URLs** for the 66 Malaysia rows and the 178 Thailand rows labelled 2026, the 125 Singapore rows labelled 2025, and the 70 Canada rows labelled 2025.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started. New: the 2 Vila Nova de Gaia venues.
10. **Plan v1.31.** Add this write, the Canada write, the South Korea write, the Singapore write, the Austria write, the Thailand write, the Malaysia write, the Top 500 write and the 50 Best write.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Portugal list read:** selection `portugal`, slugs `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`, with `/page/N`. Same-origin `fetch()` plus `DOMParser`. Keep `.card__menu` whose first `.card__menu-footer--score` ends with `Portugal`: each page also holds 4 US cards.
- **A Michelin card that left the site after the ceremony:** read CDX per locale on `web.archive.org`, in that tab. `fetch()` of 5 URLs, store on `window`, read the result in a second call with a pause, because a single wait over 45 s times out the browser tool. The `pt/pt_PT` card had a capture of June 1, 2026.
- **Card path of a city with an accent:** Michelin drops the accented letter from the path: `gueda` for Águeda, `vora` for Évora, `guimares` for Guimarães. Find the real path from a web search before you call a card a 404.
- **Michelin rate limit:** after the 78 venue pages, `fetch()` returned 202 with an empty body. A `navigate` of the tab, then a short wait, cleared it. Treat a 202 as no read, not as a result.
- **Saving a relay in a heredoc or the Write tool:** the tool turns `\uXXXX` into real characters. Escape the file again by a script, then compare the hash with the browser. For tabs, write a placeholder and replace it by a script.

## Dead ends: do not retry
- `/us/en/aveiro-region/agueda/restaurant/o-tipico` and `agueda_2422095`: wrong paths.
- `guide.michelin.com` venue card with WebFetch: client error. Use the browser.
- `restaurantguru.com` with WebFetch: server error.
- `web.archive.org` CDX with `/*` in the path, or with `matchType=domain`: empty or a timeout.
- `.detail-page__content`-style reads are not needed on Portugal articles: WebFetch reads them.
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule). `foodle.pro` is a list-order source only.

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-portugal-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 325, audit_log 133,002, venues 11,699 (active 11,391, closed 308), awards 28,593,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,643, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,391. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Michelin Mexico: read the list from the publisher and check first that it is complete. Find the edition on the site today and the edition that the live rows hold, from a guide.michelin.com URL, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
