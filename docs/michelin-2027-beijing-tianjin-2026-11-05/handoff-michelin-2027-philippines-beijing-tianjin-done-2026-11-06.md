# Handoff: Michelin Philippines 2027 and Beijing & Tianjin 2027, writes done. Nov 6, 2026 (00:10 Atlanta). Next: Gault & Millau France and Monaco after Nov 9, Thailand 2027 after Nov 10.

This file replaces `handoff-michelin-2027-latvia-done-2026-11-05.md` for the live state and the open items. That file still holds the Latvia method, decisions and hold register. The US gap, Mexico, Portugal, Canada, South Korea, Singapore, Austria, Thailand and Malaysia handoffs hold their methods. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 5 23:38 "Let's do the last two Michelin guides before moving on to G&M in a new chat". Read as Philippines and Beijing & Tianjin.
- Philippines: 23:54 "1-6:A". 23:56 "Go".
- Beijing & Tianjin: Nov 6 00:04 "1-6:A". 00:06 "Go".

## Live state (read Nov 6, 05:08:26 UTC, whole tables)
Venues **11,754** (active **11,442**, closed 312). Awards **28,828** (last id **35,999**). Michelin 2025 / 2026 / 2027 rows **4,329 / 7,521 / 254**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,698** (canonical 11,754). Price 7,759. Listings **11,754**. city_label_source **24,915**. city_aliases 222. Redirects 35. Cities **3,328**, `cities.venues_count` sum **11,442**. Ledger **286** rows, last id **340**. audit_log **127,982** rows, last id **133,811**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done: Philippines
`docs/michelin-2027-philippines-2026-11-05/load-michelin-2027-philippines-2026-11-05.sql` (sha256 `bf97333f8eb41f20275dca8d1ba497e52c53ceff419631ac2fdc86277e4f6c79`). Write connector, first try, 1 transaction, all gates passed.

| Item | Change |
|---|---|
| Relabel | 34 rows, year 2025 to 2026, full-list article URL. Retire 0 |
| New awards, 2027 | 41 rows, ids 35,877-35,917, `/us/en/` card URL: Two Stars 1, One Star 9, Bib 31 |
| New venues | 11, restaurant, active, published. No price, address, geo, blurb or chef. Manila: FLOW `ve_deef23b63c`, C.H.E. Bacolod Chicken House Express `ve_b9ea4035d8`, Azela (Manila) `ve_cff657d2a8`. Cebu: ATO-AH `ve_b3687c0a99`, Kalipay! `ve_9457d9b2b1`, Tatang's Lechon `ve_6a8ae6b0b4`. Cavite: Balay Dako `ve_d9f34de123`, Bawai's Vietnamese Kitchen `ve_b4f59db272`. Pampanga: Apag Marangle `ve_3bcb8dc268`, Tito Boy `ve_f04279e210`. Las Piñas - Metro Manila: BUTCHER BOY `ve_02e1325d23` |
| New cities | Pampanga `ci_d6ce481bcf` (2), Las Piñas - Metro Manila `ci_a338350536` (1) |
| City counts | Manila 27 to 30. Cebu 6 to 9. Cavite 1 to 3 |
| Ledger | 336 award (relabel, 34), 337 award (41), 338 city_label (22) |
| audit_log | 133473-133607 (135). awards INSERT 41, awards UPDATE 34, cities INSERT 2, cities UPDATE 3, city_label_source INSERT 22 (by hand), listings INSERT 11, slugs INSERT 11, venues INSERT 11 |

Read back, population Michelin rows on Philippine venues, 75 rows, 75 with a URL: 2026 Two Stars 1, One Star 8, Bib 25. 2027 Two Stars 1, One Star 9, Bib 31.

**List check.** Population: selection `philippines`, `/us/en/`, built-in browser. Banners 1 / 9 / 31 / Selected 86 = 127, equal to the site banner and the article. All 41 venue pages return 200, say "2027 MICHELIN Guide" and agree on tier. The 2027 full-list article names the same 41. The closed test found 0, and that test is a text match.

**Label check.** The 2026 edition (Oct 30, 2025) is the first Philippine edition, so a 2025 label cannot be correct. The 2026 full-list article names all 34 rows at the same tier. Rule 2.1.7: relabel, then load 2027, retire 0.

**Pair check.** Population: 41 cards. Paired 30. New 11. Name and slug clashes 0. Address test by eye against `data/venues.json`, population 30: same place 26, no street to compare 2 (Lasa, Bolero), differs 2 (Cabel: same street, 1147 and 1153. Taquería Franco: Salcedo Village, different street). Prices: the live symbol count equals the card for all 30.

**Live rows with no 2027 star or Bib card, population 4:** Hálong `ve_9ef43ea0c6`, Your Local `ve_acb0fd2749` (both Selected; Oct 10 ruling, active, 2026 row stays). CUR8 `ve_fe597436c3`, Pares Batchoy Food House `ve_6f47f1c8ed` (not in the guide, cards 404, no closure report found; active, 2026 row stays, recheck list).

**Decisions (Ben, all A).** 1. 34 rows take the 2026 full-list article URL. 2. CUR8 and Pares Batchoy stay active, recheck. 3. Add 11 venues. 4. Makati cards go to Manila by alias, Azela to Manila, 2 new cities, the rest of the Metro Manila split to Phase 3. 5. No rename, 11 names to the rename batch. 6. Hold register.

**Evidence:** `michelin-2027-philippines-evidence-2026-11-05.csv` (45 rows). List read: `relay-ph-2027-list-pages-2026-11-05.txt` (sha256 `08b28ab3b5cf1ee81c8e46f4469f3c6b86d18f951783b53aa91a6c5aab502cbc`, 2 reads, equal to the browser). Plan: `pairs.tsv`. Live read: `live-read.txt`. Script: `build_sql.py`.

**Sources:** https://guide.michelin.com/en/article/michelin-guide-ceremony/philippines-full-selection-2027 , https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2027 , https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/philippines-bib-gourmand-2027 , https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/full-list-michelin-guide-ph-2026 , https://guide.michelin.com/ph/en/article/michelin-guide-ceremony/philippines-full-selection-2026 , https://www.sunstar.com.ph/cebu/list-michelin-guide-2027-awardees-in-cebu .

## Done: Beijing & Tianjin
`docs/michelin-2027-beijing-tianjin-2026-11-05/load-michelin-2027-beijing-tianjin-2026-11-05.sql` (sha256 `6888b8866f77d2589eac7451094fb13846176c63b2876780021d6ea77042faa3`). Write connector, first try, 1 transaction, 05:07:59 UTC, all gates passed.

| Item | Change |
|---|---|
| Relabel, retire | 0. The 58 Beijing star and Bib rows labelled 2026 stay as history (rule 2.1.7, Tokyo row of the table) |
| New awards, 2027 | 82 rows, ids 35,918-35,999, `/us/en/` card URL: Three Stars 2, Two Stars 5, One Star 27, Bib 48 |
| New venues | 24, restaurant, active, published. No price, address, geo, blurb or chef. Beijing 7 Bib. Tianjin 17 (China Banquet One Star, 16 Bib). Ids in the evidence CSV |
| New city | Tianjin `ci_a1a3f433ce` (17), no region or coordinates |
| City count | Beijing 80 to 87 |
| Ledger | 339 award (82), 340 city_label (48) |
| audit_log | 133608-133811 (204). awards INSERT 82, cities INSERT 1, cities UPDATE 1, city_label_source INSERT 48 (by hand), listings INSERT 24, slugs INSERT 24, venues INSERT 24 |

Read back, Michelin star and Bib rows, each with a URL. Beijing 2026: Three Stars 2, Two Stars 6, One Star 24, Bib 26 = 58. Beijing 2027: 2 / 5 / 26 / 32 = 65. Tianjin 2027: 0 / 0 / 1 / 16 = 17.

**List check.** Population: `/us/en/beijing-municipality/restaurants` and `/us/en/tianjin-municipality/restaurants` with the tier slugs, built-in browser. Beijing 2 / 5 / 26 / 32 / Selected 42 = 107. Tianjin 1 / 16 / Selected 10 = 27. Sum 134, equal to the article. All 82 venue pages return 200, say "2027 MICHELIN Guide" and agree on tier. The closed test found 0, and that test is a text match.

**Label check.** The 2026 edition article page is dated Oct 28, 2025. The rows hold sourced 2026 card URLs. Label correct. Tianjin has no earlier edition. The 2027 article page says Oct 26, 2026; `datePublished` says Oct 27.

**Pair check.** Population: 82 cards. Same card URL on the 2026 row 56. Live venue with no Michelin row 2. New venue 24. Tier change 1: Shanghai Cuisine `ve_edc5ed438c`, Two Stars 2026, One Star 2027. Price symbols equal on the 56. Name and slug clashes 0.

**Live rows with no 2027 card, population 2:** Jing `ve_262d31b59b` (One Star), Ladychai `ve_8a5b0b0df3` (Bib). Cards 404, not on the Selected list, no closure report in one search. Active, 2026 rows stay, recheck list.

**Decisions (Ben, all A).** 1. Chef 1996 to `ve_eeddf12653`, Old Tower to `ve_1c7406cc48` (both live from OAD). "Beijing 1996" `ve_a7f98c2d12` stays separate, same-name pairs item. 2. Jing and Ladychai stay active, recheck. 3. Add 24 venues. 4. New city Tianjin. 5. No rename, 2 names to the rename batch: Lao Chuan Ban (card Lao Chuan Ban (Dongcheng)), Fuchunju (card Fu Chun Ju). TRB Hutong stays. 6. Hold register.

**Evidence:** `michelin-2027-beijing-tianjin-evidence-2026-11-05.csv` (84 rows). List read: `relay-bj-tj-2027-list-pages-2026-11-05.txt` (sha256 `f1e9d7ed6382d85cd75b17195953747a6938b9bce3d4be548b1aee28ec84b608`, 2 reads, equal to the browser). Live read: `live-read.txt`. Script: `build_sql.py`.

**Sources:** https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-beijing-tianjin-2027 , https://guide.michelin.com/en/article/news-and-views/michelin-guide-beijing-2026 , https://guide.michelin.com/us/en/beijing-municipality/restaurants , https://guide.michelin.com/us/en/tianjin-municipality/restaurants .

**No change to, both writes:** names, price, redirects, city aliases, `award_categories`, status of a live venue. The live site does not read Supabase, so no live page changed. Not checked: a live page.

## Hold register (no rows)
- **Philippines 2027 special awards, population 4:** Opening of the Year Frances Tariga (Tadhanà), Young Chef Francis Lacson (Digámo), Service Clyde Joshua Zafra (Tito Boy), Exceptional Cocktails Ron Job Sanchez (Automat). The article names no Green Star.
- **Beijing & Tianjin 2027 special awards, population 4:** Mentor Chef Jun Dai (Lamdre), Young Chef Yunjia Zhang (Under Clouds Green), Service Wei Qiao (Re Hai Fan Zhuang), Sommelier Andrea Amadio (Monsieur Dior by Anne-Sophie Pic). The article has a Mindful Voices section; the names were not read. A text search found no Green Star. The Beijing 2026 special rows are in the table, so the 2027 ones differ only by this hold.

## Weak points
- The cause of the wrong 2025 label on the Philippine rows is not known.
- The Philippine address test was by eye.
- The status reads of CUR8, Pares Batchoy, Jing and Ladychai are search result titles and one Cebu list.
- Chef 1996 and Old Tower pair by exact name only. `data/venues.json` has no address for them.
- Status of the 35 new venues: only the Michelin cards and articles were read.
- The text sent to the Write connector was copied, not hashed against the file. The md5 gates cover the plan text only.
- Other 2027 editions were not searched in this session, for example Fujian (plan table).

## Open items, in order
1. **Rest of the launch list.** **Gault & Millau France and Monaco 2027 (Nov 9, next, new chat).** **Thailand 2027 (after Nov 10)**: see the Thailand handoff. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. New for the price item: 35 venues with no price (11 Philippines, 24 Beijing & Tianjin), and Chef 1996, Old Tower if they hold none.
2. **Status read of the 45 Top 500 venues.**
3. **Rechecks.** All from the US gap handoff, plus CUR8 `ve_fe597436c3`, Pares Batchoy `ve_6f47f1c8ed`, Jing `ve_262d31b59b`, Ladychai `ve_8a5b0b0df3`, Cabel `ve_42732bab00` and Taquería Franco `ve_be4b78a978` (address).
4. **Same-name pairs.** All from the US gap handoff, plus Beijing 1996 `ve_a7f98c2d12` and Chef 1996 `ve_eeddf12653`.
5. **Rename batch.** All from the US gap handoff, plus the 2 Latvia names, these 11 Philippine names (Helm by Josh Boutwood, Linamnam MNL, COCHI by Marvin Agustin, Em Ha Noi - Em Hà Nội Restaurant BGC, Esmen Carinderia, LaPita, LASA BUSAY Modern Filipino Food, Los Tacos MNL, Palm Grill: Authentic Southern Mindanaon Cuisine, SOME THAI, Sarsá Kitchen + Bar), and Lao Chuan Ban, Fuchunju.
6. **Archive URLs.** As in the Mexico handoff.
7. **Phase 2 publish job.** Goal Nov 29. Not started.
8. **Phase 3 location pass.** Not started. New: Metro Manila split (manila, manila-metro-manila, taguig, taguig-metro-manila, quezon-city, quezon-metro-manila, paranaque-metro-manila). Balay Dako: card city Cavite, address Tagaytay.
9. **History backfill.** As in the US gap handoff.
10. **Plan v1.31.** Add these 2 writes, the Latvia write, the US gap write and the writes listed in the Mexico handoff.
11. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **Metropolitan list pages:** `/us/en/<region>-municipality/restaurants/<tier slug>`. Same trailing cards as Latvia: keep the first N, from the banner.
- **Article URLs by pattern:** `philippines-full-selection-<year>`, `full-list-michelin-guide-ph-<year>`, `philippines-bib-gourmand-<year>` all return 200.
- **Links on an article page:** the related links name other new editions. This found both guides of this file.
- **URL gate when a card repeats:** allow a repeat only on the same venue and the earlier year.
- **Browser script limit:** a call with a wait loop stopped at 45 seconds. The loop kept running in the page. Start it, return, then poll.

## Dead ends: do not retry
- `/en/article/michelin-guide-ceremony/michelin-guide-philippines-2026`: 404.
- Card URLs of Pares Batchoy, CUR8, Jing, Ladychai: 404.
- WebFetch of cebudailynews.inquirer.net: refused.
- `enprimeurclub.com` and `joinpearl.co`: ignore them in web search results (working rule).

**Repo:** branch `oad-2026-read-block` holds these folders and this handoff (in the Beijing & Tianjin folder). Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-michelin-2027-philippines-beijing-tianjin-done-2026-11-06.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 340, audit_log 133,811, venues 11,754 (active 11,442, closed 312), awards 28,828,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,698, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,442. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
First search for gaps in the Michelin guides: compare the editions on guide.michelin.com (guide, latest edition, date, URL) with the live rows by guide and year, including 2027 editions such as Fujian. Report each gap with a population on every count, then stop and ask me which to do. No file or write for a gap before my choice.
Then start Gault & Millau France and Monaco 2027: check first that the edition is out (due Nov 9). Read the live rows again first, then read the list from the publisher and check first that it is complete. Find the edition that the live rows hold.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
