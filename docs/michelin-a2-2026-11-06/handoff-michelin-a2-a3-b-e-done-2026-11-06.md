# Handoff: Michelin gap groups A2, A3, B and E written, Nov 6, 2026 (10:15 Atlanta). Next: group D (new chat). Gault & Millau France and Monaco 2027 after the Nov 9 gala. Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-a1-greece-south-australia-dubai-done-2026-11-06.md` for the live state, the gap table and the open items. That file still holds the A1 method and hold register. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 6)
- A2: 01:35 "1-7: A". 01:39 "Go".
- A3: 08:43 "1-9: A". 09:11 "Go".
- B: 09:22 "1-5: A". 09:24 "Go".
- E: 09:39 "1-5:A". 09:59 "Go".
- Ben did not answer my suggestion of a handoff before D. I stopped here, as the working rule says.

## Live state (read Nov 6 after the last write, whole tables)
Venues **11,831** (active **11,512**, closed **319**). Awards **29,052** (last id **36,223**). Michelin 2024 / 2025 / 2026 / 2027 rows **44 / 4,179 / 7,821 / 311**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,775** (canonical 11,831). Price 7,759. Listings **11,831**. city_label_source **25,069**. city_aliases 222. Redirects 35. Cities **3,344**, `cities.venues_count` sum **11,512**. Ledger **311** rows, last id **365**. audit_log **128,829** rows, last id **134,658**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
All through the Write connector, 1 transaction each, first try, all gates passed.

| Write | Relabel 2025 to 2026 | New rows (ids) | New venues | Other | Ledger | audit_log |
|---|---|---|---|---|---|---|
| A2: Brazil, Malta, Qatar, Serbia | 94 (BR 66, MT 12, QA 11, RS 5) | 2 (36,099-36,100) | 2 (Tabōa Cozinha Artesanal, Petí no MAM) | 2 closures: Didier `ve_99f41235da`, Lasai `ve_dfa308c00a`. São Paulo 73, Rio de Janeiro 20 | 348-353 | 134,156-134,267 |
| A3: Abu Dhabi, Czechia, Estonia, Argentina | 39 (Abu Dhabi 12, CZ 27) | 37 (36,101-36,137): Abu Dhabi 1, EE 11, AR 25 | 15 (Buenos Aires 10, Mendoza 3, Tallinn 2) | EE 9 and AR 10 rows stay 2025. Buenos Aires 53, Mendoza 11, Tallinn 13 | 354-359 | 134,268-134,421 |
| B: Poland, Croatia, Slovenia | 0 | 86 (36,138-36,223): PL 45, HR 22, SI 19 | 19 (Poland) | 9 new cities. 5 rows labelled 2026 got the card URL. 73 rows stay 2025 | 360-363 | 134,422-134,621 |
| E: Hungary, Saudi Arabia | 0 | 0 | 0 | 34 rows keep 2025 and got a URL. 1 closure: Platán Gourmet `ve_b35292624c`. Tata 1 | 364-365 | 134,622-134,658 |

**Not changed:** names, price rows, addresses, geo, blurbs, redirects, city aliases, `award_categories`. New venues have no price, address, geo, blurb or chef. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Population: Michelin rows on venues in each scope, read after each write.
- 2026 rows / with URL: BR 68 / 67, MT 12 / 12, QA 11 / 11, RS 5 / 5, Abu Dhabi 13 / 13, CZ 27 / 27, AR 25 / 25, EE 11 / 11. Stars and Bib only: PL 49 / 49, HR 28 / 28, SI 22 / 22.
- 2025 rows / with URL: AR 10 / 0, EE 9 / 0, HU 23 / 23, SA 11 / 11.

## Files
Each folder holds the SQL, `baseline.json`, `pairs.tsv`, the relay, `build_sql.py` and an evidence CSV.

| Folder in `docs/` | SQL sha256 | Relay sha256 (equal to the browser) | Evidence CSV sha256 |
|---|---|---|---|
| `michelin-a2-2026-11-06/` | `a2764d12e8e79d766e59d4015fa9b24959c9bcf520297dff03bb65c9988419aa` | `6411a0cca806607d31981b86e189e61db660823bf79abd68b80947103c371796` | `aee962f06a375f805c1ce2c1f4e130484451d360a87c8bd505114bec9f3d6e73` |
| `michelin-a3-2026-11-06/` | `3f42388116b521ff44de0559f6b82b720954900796493edaad5d7fc3b90cb199` | `f8896b7ca1f72f6a793a1bd3737122c6be48467cbd288a2f25c7e10464508d45` | `358a40413f53afd9379f2b9d5dd2e2be60e70e09250bf4b19f10e138147304b0` |
| `michelin-b-2026-11-06/` | `bff54cad1fd349fa2ebfae925ae4a20799f318d40bc57f58ce592dd0d3bbeb9a` | `69dca933c4a4070625876a5f28565efe09aa89663a09feb7b63a34d09dbc36d5` | `767867bfbb2dd7f41718bf487e8d4608cb52170c0c3d19af9ed2233dd4dd53fa` |
| `michelin-e-2026-11-06/` | `1cf76f71211d5ab99e21b2686c0488d3bada110b68f1a241a7b23bd088619cb8` | `9a48f596d2a2eb3e9561f9620b734f1e44cc8929f995c5ff4776aa6a2ac8e831` | `5deb8d2f2aca56fdf141ed1f096e9c6b874a5cae7983f47f3535d8345e7f6d24` |

## Decisions (Ben, all A)
- **Label rule (new, Ben's choices 3 of A3 and 2 of E):** when a Michelin article and the cards disagree on the edition label, the row takes the card label. Czechia: article 2025, cards 2026, rows 2026. Saudi Arabia: article 2026, cards 2025, rows 2025.
- **A card that left the site:** archive capture if one exists (Didier, Perk), else the article that names the venue (Goldfish, Samia's Dish, Platán Gourmet). No capture and no naming article: no URL (Più Higienópolis).
- **Lasai:** closed and unpublished, recheck in December. The written temporary closure rule covers only closures with no reopening date. Press gives December 2026. Ben chose the same treatment as Ossiano and Nolan.
- **Pairs with a different name, accepted:** Casa Vigil Palmares = Casa Vigil, Riccitelli Wines = Riccitelli Bistró, Dvorec Zemono = Gostilna Pri Lojzetu, Molam Thai = MOLÁM.
- **New venue names:** card names. "Cal - Gastronomía Viva" goes to the rename batch: the article calls it Cal.

## Label evidence
- **Brazil:** Evvai and Tuju hold Three Stars in the live rows; the 2025 article gives Two Stars. Article totals 2 / 3 / 19 / 44. Site 2 / 3 / 19 / 42. CNN Brasil (Apr 14, 2026) names all 44. Didier and Più Higienópolis left the site after the ceremony. Tabōa and Petí were missing from the capture.
- **Malta, Qatar, Serbia:** new names of the 2026 articles are in the live rows (Verbena; Alba, Fenyal, Baron, Berenjak, Mila; Bela Reka).
- **Abu Dhabi:** the 3 new Bibs are in the live rows; 99 Sushi Bar (One Star 2025) is not. Hakkasan was missing from the capture.
- **Estonia:** ceremony May 19, 2026, inside the capture window, but the rows match the 2025 article (Jun 19, 2025).
- **Poland:** ceremony May 27, 2026, inside the window, but the rows hold BABA as a Bib and none of the 19 new Bibs.
- **Croatia:** rows equal the 2025 list 1 / 12 / 12. **Slovenia:** stars equal the 2025 article; rows hold 11 of 12 Bibs of that article.
- **Argentina:** ceremony Jul 13, 2026, after the window. The 10 Bibs of 2025 are not in the live rows.

## Michelin gaps still open (Nov 6)
Re-read first.

| Group | Guides | Note |
|---|---|---|
| C | Thailand 2027 | Bib out Nov 3, stars Nov 10 |
| D | 449 rows with no URL on the latest edition: Thailand 178, Vietnam 66, Malaysia 66, Denmark 56, Sweden 34, Norway 22, Finland 10, Lithuania 10, Iceland 3, New Zealand 2, Faroe Islands 1, Austria 1 | See below |
| F | United States: 690 rows labelled 2025, 684 no URL, 305 on venues with no 2026 row | After Northeast Cities, Dec 14 |

**Group D, read Nov 6.** Population: Michelin rows on venues in the 12 countries, rows / with a URL.
- Latest label: TH 2026 180 / 2. VN 2026 82 / 16. MY 2026 66 / 0. DK 2026 68 / 12. SE 2026 38 / 4. NO 2026 26 / 4. FI 2026 11 / 1. LT 2026 13 / 3. IS 2026 3 / 0. NZ 2026 Bib 34 / 32. FO 2026 1 / 0. AT 2026 Bib 61 / 60.
- 2025 rows with no URL (not in the 449): DK 57, SE 34, NO 22, FI 11, LT 11, IS 3, FO 1, VN 68.
- **Trap for D:** Malaysia cards now show 2027, and Thailand cards show 2027 after Nov 10. A live card is then not the source for a 2026 row. The Portugal and Malaysia handoffs put these rows on the archive URL item. Read each guide's card label first. Consider doing Thailand after the 2027 load, or leaving Thailand and Malaysia to the archive item, and ask Ben.
- Each country needs the card label test first, because the Nordic edition may have changed.

**Not out on Nov 6:** Fujian 2027 (card reads 2026, read at 10:05 ET), Tokyo / Kyoto-Osaka / Nara 2027 (Feb 16, 2027), Abu Dhabi 2027. Hungary 2026: none found (1 web search).

## Hold register (no rows)
- **Brazil 2026 special awards, 4:** Young Chef Pedro Coronha (Koral), Sommelier Robério de Sousa Queiroz (Maní), Service Raphael Zanon (Casa 201), Exceptional Cocktails Anderson Oliveira (D.O.M.). Green Stars 3.
- **Qatar 2026 special awards, 3:** Opening of the Year Koo Madame, Service Shanghai Me Doha, Exceptional Cocktail yūn.
- **Estonia 2026 special awards, 4:** Young Chef Gerli Travkin (Fotografiska), Service Karl-Friedrich Kuusk (Vesta), Sommelier Aleksei Pogrebnoi (NOA Chef's Hall), Opening of the Year Heinrich Liis (FUME). Green Stars 3.
- **Czechia special awards:** Young Chef Taro, Sommelier Marie B, Service Field. Green Stars 4.
- **Poland 2026 special awards, 4:** Opening WANDAL, Young Chef Ida Malec (Nat Bistro), Service Babinicz, Sommelier Dawid Kurlus (Maremma). Green Star Eliksir.
- **Croatia 2026 special awards:** Young Chef Marin Pleše (Vila Rova), Sommelier Branimir Vukšić (Pelegrini), Opening Nuré. Monte Service is loaded.
- **Slovenia 2026:** Young Chef Marko Magajne (Galerija okusov), Opening Gostilna Francl. Ruj Service and Grič Sommelier are loaded.
- **Hungary Green Stars 6.** Saudi special awards 3 (press).
- **Argentina 2025 Bibs (10), Slovenia 2025 Bib (1 missing), Malta, Serbia Green Stars:** not read or not loaded.

## Weak points
- Articles came through a WebFetch summary.
- The tier came from the list page and the page description, not the page body.
- Casa Vigil, Riccitelli, Dvorec Zemono: no address test.
- The Didier capture is the Spanish page. Perk capture is `/us/en/`, Dec 21, 2025.
- Didier closure rests on 1 press article and a card that left. Platán Gourmet rests on the press and a card that left; I did not read its site. Portfolio.hu says "in its current form" and a new function for the room.
- Goldfish and Samia's Dish: card gone, reason not read.
- Group B dry run left out 6 count gates in the text sent. A fresh read covered those values, and the real file ran them.
- Fresh reads after the choices did not repeat the dry run. Plan text was unchanged; only the ledger text changed.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only, and the sent text left out the header comments.
- Evidence CSV live names for A3, B, E: copied from a read, not hashed. 1 name (Goldie) was added after a check.

## Open items, in order
1. **Group D (next, new chat).** Then **Gault & Millau France and Monaco 2027 (after Nov 9). Thailand 2027 (after Nov 10).** Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. New for the price item: 36 venues with no price (Tabōa, Petí, 15 of A3, 19 of B), plus Fotografiska, Hakkasan, Anafe, Mengano if they hold none. 15 price differences by symbol count, by script: A2 AE! Cozinha, Jacó, Kazuo, AYU, Jamavar, Iva. A3 Erth, Výčep. B Konoba Mate, K.užina, Krug, Klinec, Hiša Denk, Galerija okusov, Hiša Linhart.
2. **Status read of the 45 Top 500 venues.**
3. **Rechecks.** All from the A1 handoff, plus Lasai `ve_dfa308c00a` (December, Ipanema), Goldfish Abu Dhabi `ve_85088316db`, Perk `ve_fe70f07ca7`, Samia's Dish `ve_b4cb7d747c`, Tač `ve_904c7edf73` (2025 Bib, not on the 2026 list), Platán Gourmet `ve_b35292624c` (new function).
4. **Same-name pairs.** As before.
5. **Rename batch.** All from the A1 handoff, plus 104 names of `name_check = differs` in the evidence files: A2 34, A3 26, B 33, E 11. Plus Cal - Gastronomía Viva.
6. **Archive URLs.** As before, plus 19 EE and AR 2025 rows, 73 PL, HR, SI 2025 rows, and Più Higienópolis 12397.
7. **Phase 2 publish job.** Goal Nov 29. Not started.
8. **Phase 3 location pass.** Not started. New: 9 Poland cities with no region. Grič is in Horjul, the card says Šentjošt nad Horjulom.
9. **History backfill.** As before.
10. **Plan v1.31.** Add these 4 writes, the label rule and those in the A1 handoff.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Reader:** one `window` script in a guide.michelin.com tab: lists by tier with a 2-second pause, then each card page. Store on `window`. Read the description with `/in the (\d{4}) MICHELIN Guide ([^.]*)\./`. Search the raw HTML for closure notes. 0 refusals over about 330 pages.
- **A browser call stops at 45 seconds.** Start the job, return, then read the result in a later call.
- **Relay:** write the sorted lines into `<article><pre>` and read them with `get_page_text`. It strips trailing spaces. Save, re-escape `\uXXXX` by script, compare the sha256.
- **JS output hits a filter:** a bare hex string came back "[BLOCKED: Base64 encoded data]". Return JSON, or put `:` between the bytes.
- **CDX:** per locale, `fetch` in a tab on web.archive.org. Use the local word for the path: `restaurante` (es), `ristorante` (it). A long loop must run in the background: a single wait over 45 seconds times out the tab.
- **Empty tier:** a 404 with "no selected restaurants" is a count of 0, not a failure.
- **A card slug can differ from the name:** Più Higienópolis = `piu-iguatemi`, Dvorec Zemono = `pri-lojzetu`. Find it with a web search limited to guide.michelin.com.
- **Group build scripts:** `docs/michelin-b-2026-11-06/build_sql.py` is the best model: URL set on existing rows, a checked list, new rows, new venues, new cities. `michelin-e` is the model for URL only plus closure.

## Dead ends: do not retry
- `curl` to guide.michelin.com from the shell: refused by the proxy. WebFetch reads list pages and articles, but through a summary. Use the Chrome connector for exact data.
- `/us/en/rio-de-janeiro-region/rio-de-janeiro/restaurant/didier`, `.../piu-higienopolis`, `.../piu-iguatemi`, `.../abu-dhabi/restaurant/goldfish-sushi-yakitori`, `.../sumperk_1280119/restaurant/perk-restaurant`, `.../tata/restaurant/platan-gourmet`, `.../jeddah_2555048/restaurant/samia-s-dish`: 404.
- `sources` table: none. `awards.source_id` is text, for example `michelin`, `oad`.
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds these folders and this handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt: group D
```
Read claude/handoff-michelin-a2-a3-b-e-done-2026-11-06.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 365, audit_log 134,658, venues 11,831 (active 11,512, closed 319), awards 29,052,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,512. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Do group D of the handoff: rows with no URL on the latest edition. Read the card label of each country first, and tell me the plan for Thailand and Malaysia, whose cards show 2027 or will after Nov 10. Do one country or small group at a time, smallest first.
For each one: build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
Before each group, read again whether Fujian 2027 is out. If it is, tell me and ask where it goes in the order.
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```

## Suggested opening prompt: Gault & Millau (after Nov 9)
```
Read claude/handoff-michelin-a2-a3-b-e-done-2026-11-06.md from the project files, then
claude/handoff-michelin-a1-greece-south-australia-dubai-done-2026-11-06.md for the Gault & Millau notes,
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm the counts of the latest handoff. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Start Gault & Millau France and Monaco 2027: check first that the gala results of Nov 9 are out. Read the live rows again first, then read the list from the publisher and check first that it is complete. The live rows hold the 2026 edition (gala Nov 17, 2025).
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
