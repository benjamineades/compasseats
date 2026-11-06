# Handoff: Michelin gap search; Greece 2027, South Australia 2027, Dubai 2026 and 4 closures written. Nov 6, 2026 (01:15 Atlanta). Next: Gault & Millau France and Monaco 2027 after the Nov 9 gala.

This file replaces `handoff-michelin-2027-philippines-beijing-tianjin-done-2026-11-06.md` for the live state and the open items. That file still holds the Philippines and Beijing & Tianjin method and hold register. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 6 00:45 "a1" (from the gap report). 01:03 "1-6:A". Greece "Go" 01:03. South Australia "Go" 01:06. Dubai "Go" 01:10. Closures "Go" 01:13.

## Live state (read Nov 6 after the last write, whole tables)
Venues **11,795** (active **11,479**, closed **316**). Awards **28,927** (last id **36,098**). Michelin 2024 / 2025 / 2026 / 2027 rows **44 / 4,312 / 7,563 / 311**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,739** (canonical 11,795). Price 7,759. Listings **11,795**. city_label_source **24,997**. city_aliases 222. Redirects 35. Cities **3,335**, `cities.venues_count` sum **11,479**. Ledger **293** rows, last id **347**. audit_log **128,326** rows, last id **134,155**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
All through the Write connector, 1 transaction each, first try, all gates passed.

| Write | Awards | New venues | Other | Ledger | audit_log |
|---|---|---|---|---|---|
| Greece 2027 | 30 rows, ids 36,000-36,029 (0/1/19/10) | 14 | 17 rows relabelled 2025 to 2024, article URL. City counts Athens 35, Santorini 4, Thessaloniki 7 | 341-343 | 133,812-133,931 |
| South Australia 2027 | 27 rows, ids 36,030-36,056 (0/1/10/16) | 23 | 7 new cities. Adelaide 19, Seppeltsfield 2 | 344-345 | 133,932-134,082 |
| Dubai 2026 | 42 rows, ids 36,057-36,098 (2/4/14/22) | 4 | Dubai 97. Al Muntaha stays closed and holds its row. 38 rows labelled 2025 unchanged, no URL | 346-347 | 134,083-134,145 |
| 4 closures | 0 | 0 | Closed and unpublished: Dinner by Heston Blumenthal `ve_556d69255a`, Ossiano `ve_2407cf20a7`, Smoked Room `ve_05d3c5844a`, Nolan `ve_30cb4b84d8`. Dubai 94, Athens 34. No ledger row | none | 134,146-134,155 |

Tier format: Three Stars / Two Stars / One Star / Bib. New venues have no price, address, geo, blurb or chef. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Files: `docs/michelin-a1-2026-11-06/`. `load-michelin-2027-greece-2026-11-06.sql` (sha256 `2c1c502fad4029c4ea0b983daf159ca903d7d3263488aee6acebcb85d865f4ff`), `load-michelin-2027-south-australia-2026-11-06.sql` (`43c8bd82c6a89d01719f0584f4644555f835e76dae631fdc0079803964a805ac`), `load-michelin-2026-dubai-2026-11-06.sql` (`bf7526a8906a693353f7545737744ea96df5ae1e4fb8cc0ab79a292d7546a0d4`), `status-michelin-a1-closures-2026-11-06.sql` (`d72621c69b75359720536a650a0796bd76df865e1fb926af09c74a32464168d2`). Also `michelin-a1-evidence-2026-11-06.csv` (99 cards), `pairs.tsv`, `relabel-greece.txt`, 3 relay files, `build_sql.py`, `build_status.py`.

Relay sha256, 2 reads equal: Greece `8976dd6d36b4e0886c5b7655cd6b9357c5ce02b0a5f3b16a5bb343986bc67982`, South Australia `de4c2f370b6bc608e9afe3d65114b16bc1c93c874695939f18498d8c86899829`, Dubai `3e6f66b26d45a2acd424754394020703afcf878329ca717b3e6788146dbbb351`.

**Decisions (Ben, 1-6 A).** 1. Greece 17 rows relabelled to 2024. 2. Penfolds Magill Estate Cellar Door `ve_f6bc917177` pairs with the card Magill Estate Restaurant. 3. The 4 temporary closures closed. 4. No-card venues stay active, earlier rows stay. 5. 41 new venues, 7 new cities, `woodside-au`, Thessalonica cards to `thessaloniki`. 6. No rename, holds as below.

**Label checks.** Athens: the 2024 article (Dec 18, 2024) names all 17 live rows at the same tier, and Michelin says there was no 2025 selection. Dubai: the live rows hold the 2025 edition (May 22, 2025). The full-list URL now shows 2026, so it is not a source for 2025.

## Michelin gaps still open (gap report, Nov 6)
Population: star and Bib list-page banners on `/us/en/`, against live rows by the venue's city country. Re-read first.

| Group | Guides | Note |
|---|---|---|
| A2 | Brazil 2026 (Apr 13, 2026), Malta 2026 (Feb 17), Qatar 2026 (Dec 9, 2025), Serbia 2026 (Dec 10, 2025) | Live tier counts equal the site. Label check first. 66 / 12 / 11 / 5 rows |
| A3 | Argentina 2026 (Jul 13, 2026, site 25, live 10), Abu Dhabi 2026 (Oct 23, 2025, site 12, live 12), Czechia (Dec 11, 2025, article says 2025, card says 2026, site 26, live 27), Estonia 2026 (May 19, 2026, site 11, live 9) | |
| B | Poland 2026 (May 27, 2026, site 49, live 4), Croatia 2026 (Jun 25, site 28, live 6), Slovenia 2026 (Jun 16, site 22, live 3) | Only part loaded |
| C | Thailand 2027 | Bib out Nov 3, stars Nov 10 |
| D | 449 rows with no URL: Thailand 178, Vietnam 66, Malaysia 66, Denmark 56, Sweden 34, Norway 22, Finland 10, Lithuania 10, Iceland 3, New Zealand 2, Faroe Islands 1, Austria 1 | |
| E | Hungary 2025 (23 rows), Saudi Arabia 2025 (11 rows) | Latest edition held, no URL |
| F | United States: 690 rows labelled 2025, 684 no URL, 305 on venues with no 2026 row | After Northeast Cities, Dec 14 |

Not out on Nov 6: Fujian 2027 (card reads 2026, last edition Nov 21, 2025), Tokyo / Kyoto-Osaka / Nara 2027 (Feb 16, 2027), Abu Dhabi 2027. Limits: Hong Kong, Macau, Taiwan, Japan, United States and mainland China list pages were not read in the gap search. A guide with a slug not tried can still be missing.

## Gault & Millau France and Monaco 2027: not out
- The gala is Mon Nov 9, 2026, Carrousel du Louvre, Paris. The page says results are not published yet: https://fr.my.gaultmillau.com/en/news/gala-2026-gault-millau
- Regional 2027 tour lists are out, each about 12 regional prizes, not the national list. Example: https://fr.gaultmillau.com/en/news/gaultmillau-tour-grand-est-2027-palmares (Oct 19, 2026), and Hauts-de-France https://fr.gaultmillau.com/en/news/gaultmillau-tour-hauts-de-france-2027-palmares . Not counted, not loaded.
- **Edition the live rows hold:** label 2026 = Guide France 2026, gala Nov 17, 2025. Test: Troisgros holds Four Toques, Chef of the Year 2026, and the 2026 press kit names Cesar Troisgros at 4 toques as Cuisinier de l'Annee 2026.
- **Live rows.** Population: gault-millau rows on FR and MC venues, 0 with a URL. FR 2026: Five Toques 9, Four Toques 13, Four Toques Chef of the Year 1, Three Toques Grand de Demain 1, Three Toques Pastry Chef 1, Young Talent 1 = 26. MC 2026: Five Toques 1. All countries by year: 2018 14, 2019 8, 2020 21, 2021 25, 2022 19, 2023 27, 2024 47, 2025 94, 2026 123. `category` is free text with a `·` join: read `award_categories` for gault-millau first.
- Scope from the July build: 3+ toques and major annual awards, no service-side awards. Ben to confirm at the list read.

## Hold register (no rows)
- **Greece 2027 special awards, population 4:** named in the article; read Young Chef Theodoros Kaloidis (To Manitari), Service Christian Potelle (Spondi); the other 2 not read.
- **South Australia 2027 special awards, population 3:** Young Chef, Service, Sommelier; names not read.
- **Dubai 2026 special awards:** not counted. Exceptional Cocktails Zahra Erfanian Azmoodeh (Carbone) and Young Chef Remy Marquignon (Ossiano) from the press.
- **Green Stars:** not read for any of the 3 guides. The Athens 2024 article names 3 (Delta, Patio, Soil), no rows.
- **Athens 2024 Bib Cerdo Negro 1985:** no venue, skipped. It is Selected in 2027.
- **Dubai 2025:** 3 Bib rows missing (article 22, live 19). 38 rows have no URL.

## Weak points
- Greece label: the Athens card pages of the 2025 period were not read (web.archive.org refused WebFetch). The basis is the 2024 article and the Dec 17, 2025 Michelin article.
- Penfolds pair: same address, 78 Penfold Road. The La Liste page was not read. Magill Estate Kitchen is a separate Selected card on the same estate. Goldfish Sushi & Yakitori `ve_210bcd7f88`: name and web name only, no address in the repo.
- The address test was by eye and only on part of the pairs.
- Card closure notes are text matches on the 99 star and Bib cards. Status of the other new venues: not read.
- The Ossiano December date is one press line.
- 7 paired venues have a price symbol count that differs from the card, by eye (Hytra, 21grams, 3Fils, Al Khayma, Kinoya, Sufret Maryam, REIF Dar Wasl). Not changed.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.
- South Australia and Dubai dry runs: the count gates ran on fresh counts, and the plan gates ran earlier on the same rows.

## Open items, in order
1. **Gault & Millau France and Monaco 2027 (after Nov 9, next, new chat).** **Thailand 2027 (after Nov 10).** Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Michelin gap groups above: Ben chooses. Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. New for the price item: 41 venues with no price (14 Greece, 23 South Australia, 4 Dubai), plus Selene Restaurant, Restaurant Botanic, Penfolds, arkhé, Hentley Farm, Birch Restaurant, THREE BROS, Goldfish if they hold none.
2. **Status read of the 45 Top 500 venues.**
3. **Rechecks.** All from the Philippines handoff, plus Ossiano `ve_2407cf20a7` (December), Dinner by Heston Blumenthal, Smoked Room, Nolan (relocation), Jerár `ve_a726b58f0e`, La Dame de Pic - One Za'abeel `ve_43736eeb52`, Indya by Vineet `ve_f9fab9fc19`, Teible `ve_a3dcd4d0cd` (no 2026 or 2027 card, guessed URLs 404, active). Al Muntaha: card says refurbishment until late 2027. Fine Mess Smokehouse: Selected, no action.
4. **Same-name pairs.** All from the Philippines handoff.
5. **Rename batch.** All from the Philippines handoff, plus 27 names. Greece: Patio at The Margi (Patio), Botrini's Restaurant Athens (Botrini's), Makris Athens Fine Dining Restaurant (Makris Athens), Soil restaurant (Soil), Herve Restaurant (Hervé), Selene Restaurant (Selene), Delta Restaurant (Delta), Spondi Restaurant (Spondi), Hytra Restaurant & Bar (Hytra). South Australia: Restaurant Botanic (Botanic), Penfolds Magill Estate Cellar Door (Magill Estate Restaurant). Dubai: ORFALI BROS RESTAURANT (Orfali Bros), Tresind Studio (Trèsind Studio), Stay Restaurant by Yannick Alleno (STAY by Yannick Alléno), Avatara Restaurant (avatāra), Moonrise (moonrise), Tasca (Tasca by José Avillez), Birch Restaurant (Birch), Hawkerboi - The Park JLT (Hawkerboi), 21grams Urban Balkan Bistro (21 Grams), Bait Maryam - Dubai (Bait Maryam), DUO Gastrobar Creek Harbour (DUO Gastrobar-Creek Harbour), DUO Gastrobar Dubai Hills (DUO Gastrobar-Dubai Hills), Shabestan Restaurant (Shabestan), Konjiki Hototogisu - Mall of the Emirates (Konjiki Hototogisu), Goldfish Sushi & Yakitori (Goldfish), THREE BROS (Three Bros).
6. **Archive URLs.** As in the Mexico handoff, plus Dubai 2025 rows.
7. **Phase 2 publish job.** Goal Nov 29. Not started.
8. **Phase 3 location pass.** Not started. New: 7 South Australia cities with no region. Thessalonica label on 5 Thessaloniki venues.
9. **History backfill.** As in the US gap handoff.
10. **Plan v1.31.** Add these 4 writes and those listed in the Philippines handoff.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Article list:** `/en/articles/michelin-guide-ceremony` with `/page/N` (20 pages). `.card-post__title a`. It does not list every guide.
- **List slugs:** `/us/en/selection/<country>/restaurants`. Czechia `czech-republic`, Türkiye `turkey`, Ireland `republic-of-ireland`, UAE by emirate `/us/en/dubai-emirate/restaurants`, `/us/en/abu-dhabi-emirate/restaurants`, South Australia `/us/en/south-australia/restaurants`, Fujian `/us/en/fujian-province/restaurants`.
- **Pace:** about 1 fetch every 2 seconds gave 0 refusals over about 300 pages. Without a pause the site gave 202, then 403.
- **Closure notes:** the card text says "This restaurant is temporarily closed", "closed for refurbishment until", "Temporarily closed due to relocation". Search `description` in the raw HTML.
- **A name with `|`:** see|ds. The plan text now uses `~` as the separator.
- **Chained batches:** `build_sql.py` reads `baseline.json`. Read the counts after each write, rewrite the file and rebuild the next guide. The earlier baselines are kept as `baseline-before-*.json`.
- **A heredoc turns `\uXXXX` in tool text into the character.** Re-encode with Python, then compare the sha256 with the browser.
- **Multi-statement read:** the Read connector returns only the last statement.

## Dead ends: do not retry
- `/us/en/article/michelin-guide-ceremony`: 404. `/sitemap/static/us-en.xml`: 404.
- `/us/en/selection/czechia`, `turkiye`, `united-arab-emirates`, `taiwan`, `hong-kong-sar-china`, `macau-sar-china`, `faroe-islands`: 404.
- WebFetch of `web.archive.org`: refused.
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds this folder and this handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-a1-greece-south-australia-dubai-done-2026-11-06.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 347, audit_log 134,155, venues 11,795 (active 11,479, closed 316), awards 28,927,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,739, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,479. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Gault & Millau France and Monaco 2027: check first that the gala results of Nov 9 are out. Read the live rows again first, then read the list from the publisher and check first that it is complete. The live rows hold the 2026 edition (gala Nov 17, 2025).
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
