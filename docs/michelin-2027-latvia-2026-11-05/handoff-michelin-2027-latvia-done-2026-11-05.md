# Handoff: Michelin Latvia 2027 and the 2026 label, write done. Nov 5, 2026 (23:36 Atlanta). Next: a Ben choice now, Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2026-us-gap-done-2026-11-05.md` for the live state and the open items. That file still holds the US gap method, decisions and hold register. The Mexico, Portugal, Canada, South Korea, Singapore, Austria, Thailand and Malaysia handoffs hold their methods. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 23:33 "1-5, A". 23:34 "Go".

## Live state (read Nov 6, 04:35:39 UTC, whole tables)
Venues **11,719** (active **11,407**, closed 312). Awards **28,705** (last id **35,876**). Michelin 2025 / 2026 / 2027 rows **4,363 / 7,487 / 131**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,663** (canonical 11,719). Price 7,759. Listings **11,719**. city_label_source **24,845**. city_aliases 222. Redirects 35. Cities 3,325, `cities.venues_count` sum **11,407**. Ledger **281** rows, last id **335**. audit_log **127,643** rows, last id **133,472**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/michelin-2027-latvia-2026-11-05/load-michelin-2027-latvia-2026-11-05.sql` (sha256 `cd4ce8718dff774fb98ba39a472ef10db4d5aa273798a81e4d03c5929eb8a179`). Write connector, first try, 1 transaction, 04:35:15 UTC, all gates passed. The text sent left out the header comment lines and the `--` section comments of the file. The executable text was copied from the file, and the plan text gates (md5) passed.

| Item | Change |
|---|---|
| Relabel | 7 rows, year 2025 to 2026, 2026 article URL: John Chef's Hall 7557, Max Cekot Kitchen 7559, H.E. Vanadzins 9985, Milda 11823, Shoyu 11824, SMOR Modern Bistro 11825, Snatch 11826. Retire 0 |
| New awards, 2027 | 9 rows in ids 35,863-35,871, `/us/en/` card URL: One Star 2, Bib 7 |
| New awards, 2025 | 5 rows, ids 35,872-35,876, 2025 article URL: John Chef's Hall and Max Cekot Kitchen One Star, Snatch, Shoyu and Milda Bib |
| New venues | 2, Riga, restaurant, active, published. No price, address, geo, blurb or chef: Baltā Kaza `ve_eb67a13d26`, Café Mimosa `ve_6b3fda5d22` |
| City count | Riga 7 to 9 |
| Ledger | 332 award (relabel, 7), 333 award (9), 334 award (5), 335 city_label (4) |
| audit_log | 133441-133472 (32). awards UPDATE 7, awards INSERT 14, cities UPDATE 1, city_label_source INSERT 4 (by hand), listings INSERT 2, slugs INSERT 2, venues INSERT 2 |

Latvia Michelin rows after the write, read back, population 21 rows, 21 with a URL: 2025 One Star 2, Bib 3. 2026 One Star 2, Bib 5. 2027 One Star 2, Bib 7.

**No change to:** names, price, redirects, city aliases, `award_categories`, status of a live venue. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `michelin-2027-latvia-evidence-2026-11-05.csv` (9 rows). List read: `relay-lv-2027-list-pages-2026-11-05.txt` (sha256 `4b49d822714d5c80072e5f4c493c74819d705a8bd936eb09a034886ac860e164`, 4 reads, equal to the browser). Live read: `live-read.txt`. Plan: `pairs.tsv`. Address test: `address-test.tsv`. Script: `build_sql.py`.

## List check
Population: selection `latvia`, built-in browser, Nov 5 ET. Banners: One Star 2, Bib 7, Selected 26, total 35. 2 + 7 + 26 = 35, equal to the 2027 article. Two Stars and Three Stars pages: 404. `/us/en/` and `/lv/en/` lists agree. All 9 venue pages return 200 on both locales, say "2027 MICHELIN Guide" and agree on tier. The closed test found 0, and that test is a text match.

Sources: https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2027-winners-michelin-guide-ceremony (Nov 5, 2026), https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2026-winners-michelin-guide-ceremony (Oct 22, 2025), https://guide.michelin.com/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-2025-winners-michelin-guide-ceremony (Oct 24, 2024), https://guide.michelin.com/lv/en/selection/latvia/restaurants , https://eng.lsm.lv/article/culture/food-drink/05.11.2026-latvias-2027-michelin-guide-has-35-restaurants.a670314/ .

## Label check
Population: Michelin rows on Latvia venues, 7 rows, all labelled 2025, 0 with a URL. The 2026 edition is dated Oct 22, 2025, before the capture window, so it was live at capture. The incoming label is 2027. Rule 2.1.7: relabel to 2026, then load 2027, retire nothing.
- **Named changes in 2026, population 2:** SMØR Bistro (new Bib), H.E. Vanadziņš (promoted to Bib). Both are in the live rows at Bib.
- **Proof against 2025:** the 2025 article puts H.E. Vanadziņš in the Main Selection and does not name SMØR as a Bib.
- The 2026 article names all 7 rows at the same tier. The 2025 article names 5 of them at the same tier.

## Pair check
Population: 9 cards. Paired to a live row at the same tier 7. Address test, population 7: same street, number and postcode 7. New venue 2 (the 2027 article says both are new to the guide). Live rows with no card 0. Prices: the 7 live prices have the same symbol count as the cards.

## Decisions (Ben, all A)
1. The 7 relabelled rows take the 2026 article URL.
2. Add the 5 sourced 2025 rows.
3. Add Baltā Kaza and Café Mimosa, active and published.
4. No rename. 2 names go to the rename batch: SMOR Modern Bistro (card SMØR Bistro), H.E. Vanadziņš. Ziemeļu restorāns (card H.E. Vanadziņš).
5. Hold register, below.

## Hold register (no rows)
Special awards 2027, population 4: Young Chef Dmytro Voloshyn (Māsa), Service Maksims Cekots (Kice), Sommelier Juris Semjonovs (Pavāru māja), Opening of the Year Veko Tsukhishvili (Sakhli). Mindful Voices: Ēriks Dreibants (Pavāru māja). The 2027 article names no Green Star. Special awards 2026 are in the 2026 article.

## Weak points
- The rule 5 test asks for 3 named changes. Latvia 2026 has only 2 at a tier that we track.
- The old addresses come from `data/venues.json` (old site file). Those addresses were not written.
- Status of the 2 new venues: only the Michelin cards and the article were read.
- The own sites of SMØR Bistro and H.E. Vanadziņš were not read.
- The Snatch row in the 2025 article rests on the article's link list and a page summary. That passage was not read directly.
- The cause of the wrong 2025 label is not known. The `audit_log` shows only the load of Aug 14, 2026.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.

## Open items, in order
1. **Rest of the launch list.** Gault & Millau France and Monaco 2027 (Nov 9). **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. New for the price item: 2 Latvia venues with no price.
2. **Michelin 2027 articles seen, not read.** Links on a Michelin page on Nov 5: `/en/article/michelin-guide-ceremony/philippines-full-selection-2027` and `/en/article/michelin-guide-ceremony/michelin-guide-beijing-tianjin-2027`. Read the database and the articles before a batch.
3. **Status read of the 45 Top 500 venues.**
4. **Rechecks.** All from the US gap handoff.
5. **Same-name pairs.** All from the US gap handoff.
6. **Rename batch.** All from the US gap handoff, plus the 2 Latvia names above.
7. **Archive URLs.** As in the Mexico handoff.
8. **Phase 2 publish job.** Goal Nov 29. Not started.
9. **Phase 3 location pass.** Not started. As in the US gap handoff.
10. **History backfill.** As in the US gap handoff.
11. **Plan v1.31.** Add this write, the US gap write and the writes listed in the Mexico handoff.
12. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Latvia list read:** selection `latvia`, slugs `1-star-michelin`, `bib-gourmand`, `the-plate-michelin`. Same-origin `fetch()` plus `DOMParser`. Each page holds 4 more cards after the list, from other tiers: keep only the first N cards, where N comes from the banner.
- **Article URL by pattern:** `/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-riga-<year>-winners-michelin-guide-ceremony` gave the 2027 article before web search listed it.
- **Publish date:** `datePublished` in the `ld+json` script of the article.
- **Write tool:** the text `\uXXXX` in a relay file became the character, and the hash failed. Convert back with Python, then compare the hash. The hash then equalled the browser.

## Dead ends: do not retry
- `/en/article/michelin-guide-ceremony/latvia-2027` and `/lv/en/article/michelin-guide-ceremony/the-michelin-guide-latvia-2027-winners-michelin-guide-ceremony`: 404.
- `/selection/latvia/restaurants/sustainable_gastronomy`: redirects to the world list (19,994 rows).
- WebFetch of `michelin.com/en/publications/...`: refused.
- `price.source` joined with text in `coalesce(source,'')`: enum error. Cast to `::text`.
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2027-latvia-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 335, audit_log 133,472, venues 11,719 (active 11,407, closed 312), awards 28,705,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,663, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,407. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Then tell me which launch list item is next and start it: read the live rows again first, then read the list from the publisher and check first that it is complete. Find the edition on the site today and the edition that the live rows hold, from a guide.michelin.com URL where it applies, and apply rules 2.1.1 and 2.1.7.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
