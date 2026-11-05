# Handoff: OAD 2026 hold rows and Summer Palace, write done. Nov 4, 2026 (08:50 Atlanta). Next: Ben chooses.

This file replaces `handoff-oad-2026-read-block-done-2026-11-03.md` for the live state and its open items 1 and 2. `handoff-oad-2026-first-write-done-2026-11-03.md` still holds methods and OAD data limits. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 3 23:37 "1A, 2A, 3A, 4A, 5A". Nov 4 06:58 "Go" (not run: the Write connector prompt was cancelled after 0.7 s). 08:46 "ran": Ben ran the file in the Supabase SQL Editor.

## Live state (read Nov 4, 13:46:47 UTC, whole tables)
Venues **11,587** (active **11,287**, closed **300**). Awards **27,470** (last id **34,641**). OAD 2026 rows **2,848**. OAD 2025 rows 2,437. Slugs **13,435**. Price 7,759. Listings **11,587**. city_label_source **24,581**. city_aliases 222. Redirects 32. Cities **3,318**, `cities.venues_count` sum **11,287**. Ledger **231** rows, last id **285**. audit_log **124,281** rows, last id **130,110**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0. Cities with 0 venues 67.

## Done
`docs/open-items-oad-2026-holds-summer-palace-2026-11-03/cleanup-oad-2026-holds-summer-palace-2026-11-03.sql` (sha256 `a819e56404f315cfd4986b9bb5a2a939e99affa4c75bc911803f067eb9b24b70`). 1 transaction, all gates passed.

Evidence: `oad-2026-holds-summer-palace-evidence-2026-11-03.csv` in the same folder (29 rows, sha256 `6f2ca46e5740a16378f498e15bb13a1f57a632b5235c97387619cd28e5509cfb`). Scripts in run order: `verdicts.py` (hand verdicts), `build.py`, `build_sql.py`. `plan.json` holds the plan data.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

| Item | Change | Ids |
|---|---|---|
| New OAD 2026 rows | 15 (Asia 2, Europe 1, Japan 12) | Awards 34,627-34,641 |
| OAD rows moved | 4: 5562, 18119, 32880 (Summer Palace), 18463 (Pirouette) | |
| New venues | 14 (13 active, 1 closed) | |
| Venue deleted | Le Choubichou `ve_3a0ba9fb7b`. 404, no redirect | |
| New cities | Akaiwa, Ikoma, Yamagata (Gifu) slug `yamagata-gifu`. Region NULL, no lat/lng | |
| Ledger | 280-285 | |
| audit_log | 130,003-130,110 (108) | |

**New venues:** Uran (Otsu), Yakiniku Kousen (Tokyo), Hisada (Akaiwa), Katatsumuri (Yamagata, Gifu), Kimiya (Ikoma), Kappo Yoshida (Fukuoka), Hamagen (Nagoya), Mudai (Tokyo), Seto (Kyoto), Tempura Yokota (Tokyo), Sushi Hachiya (Kanazawa), Bangkok Bold Kitchen (Bangkok), Shangu (Tokyo). Closed, not published: Restaurant Pirouette (Paris, Les Restos Dec 29, 2023: sold, renamed Choubichou). City labels stay as OAD printed them. Names are the OAD spellings.

**Summer Palace (Ben 4A):** Hong Kong `ve_54ab6673c8` holds 2026 rank 259 and 2025 rank 215. Beijing `ve_6a1064e62c` holds 2026 rank 432 and 2025 rank 335. Weak point: Asia 432 prints city Hong Kong and chef Leung Yu King (the Hong Kong chef), and an address at the Shangri-La Hotel. The Shangri-La site shows Summer Palace in Beijing at China World Hotel. This is a best reading, not proof.

**Weakest load:** Shangu (Japan 789). Chef Hiroaki Arishima and name match on Tabelog. OAD phone and address do not match.

**Not checked:** the live site. This session did not read a page or a deploy.

**How the pages were read:** no worker. Most pages through the fetch tool (a small model reads the page and reports). Shangri-La and OAD pages through the browser. The 2026 printed rows from the DOM match the stored list by hash (29 rows).

## Open items
1. **Hold rows, 13 (no write, was 27).** Arnanz (Europe 403), Defune (Europe 534), Tempura Tenon (Asia 283), Gloria Maris (Asia 494), Koide (Japan 460), Tempura Kusunoki Yotsuya (Japan 469), Sushi Ichi (Japan 501), Sushi Ueda Osaka (Japan 561), Kikuzushi Kitakyushu (Japan 611), Miyaba (Japan 647), Meimon (Japan 675), Tsubomi (Japan 712), Sushi Takumi (Japan 755). Reason for each: evidence CSV, `decision` = hold.
2. **Read block, what is left.**
   - **Not proven, no write, 3:** Jing Yaa Tang (Asia 486, on Yatang `ve_84687b6ab6`), Kikuzushi (Japan 180, on Kiku Sushi `ve_515b6a646f`), Omino Kamiyacho (Japan 462, on Omino `ve_ebb1779b86`, live city Yokahama).
   - **2025 row still on the wrong venue, 1 (Ben 3A):** Sushi Ichi 18993 (rank 455) on Ginza Fukuju `ve_7f732a531c`. Ginza Fukuju also holds the old slug `ginza-sushi-ichi-singapore`, not canonical. Cause not read.
3. **Rename batch.** About 40 OAD own spellings on earlier new venues, plus the 14 new venues of this write, where the own name can differ (such as Tori Ryori Seto for Seto), plus 145 name candidates left of 147. Count again.
4. **Status (from the first-write handoff).** Sustanza, Testina, Art di Daniele Sperindio.
5. **44 closed venues OAD 2026 still prints,** plus Restoran Alexander, Chiba Takaoka, Sorrel, Quattro Passi with a new 2026 row. All stay closed. Count again.
6. **New cities, 37.** Region NULL, no lat/lng. Live city `otsu` shows display "otsu" in lower case (read Nov 3, not changed).
7. **From the last handoffs, unchanged.** Carmen Medellín `ve_6cd9c1b505`. Merged venues left as they are (Restaurant Wörgötter, Schlosskeller Südsteiermark, Fagn, Vyn Restaurant). Missing 2025 rows, 22 venues. 26 aliases with a venue under a neighbor city. 48 Swiss 2025 rows with no capture. 3,028 Michelin 2025 rows with no URL. 140 blurbs `needs_rewrite`. New checks on Kioicho Mitani, Yamazaki `ve_61cf53898d`, Sushi of Gari 46, Forbes pages for Masa. 67 cities with 0 venues.

8. **Michelin Kuala Lumpur & Penang 2027, to ingest (Ben, Nov 4 08:50).** Ceremony read: press release dated Nov 4, 2026. In scope 70 rows: Two Stars 1 (Dewakan), One Star 9 (new: Potager), Bib 60 (new: 7 Chai Ipoh Hor Fun, Minji Bak Kut Teh, Lemon Koay Teow Soup, Serabai Istimewa). Selected 89 stays out (rule: nothing below a Bib). Special awards go to the hold register: Young Chef Aidan Low (Akar), Service Mr Nazahar (Potager), Sommelier Joyin Goh (Tangram), Opening of the Year Root House by Gen. Green Star or Mindful Voices: not read. Live rows (Michelin, venues in Malaysia, read Nov 4): 2025 label 66 (Two Stars 1, One Star 8, Bib 57), 0 with a URL. 2026 label 0, 2027 label 0. The 2026 edition (Nov 11, 2025: Two Stars 1, One Star 8, Bib 58) is also not loaded: a label check on the 66 rows is needed first. Live cities: Kuala Lumpur 41 venues, George Town 33, Seberang Perai 5. Status: not started. Release: https://www.prnewswire.com/apac/news-releases/the-michelin-guide-kuala-lumpur--penang-2027-reveals-new-stars-and-dining-discoveries-302929225.html . 2026 article: https://guide.michelin.com/en/article/michelin-guide-ceremony/malaysia-full-selection-2026 . The card pages for 2027 were not read.

## Recheck list (no scheduled task holds these dates)
All items of `handoff-oad-2026-read-block-done-2026-11-03.md`, plus: Uran (Tabelog says new reservations not accepted). Hisada (Tabelog also lists Kiu in Kyoto with reviews that name Hisada). Bangkok Bold Kitchen (OAD Riverside Plaza address may be another restaurant, Michelin shows Central Embassy). Mudai (last visit Jan 2026). Choubichou (not read as open, deleted because it had no award).

## Methods (new)
- **Phone on Tabelog was the best proof in Japan.** 12 of 14 loads have a phone match on an allowed page. A script compares the digits to the OAD phone.
- **Search with `allowed_domains` = tabelog.com and the Japanese name.** Find the name first, then read the phone. A search for the phone number alone found almost nothing.
- **Tabelog host:** `tabelog.com/en/...` opened often through the fetch tool. `ssl.tabelog.com` often gave robots_disallowed. A Tabelog id from an earlier CSV can be wrong: check the name.
- **OAD restaurant pages:** `fetch('/restaurant/<slug>')` from a tab on oadguides.com gives the full HTML. The list pages need the live DOM.
- **Hash check of DOM rows:** compute sha256 in the browser and in Python from the stored list read. Compare.
- **Dry run:** add `RAISE EXCEPTION 'dry stop'` after the pre gates and send through the Read connector.

## Dead ends: do not retry
- Tabelog list search (`rstLst/?sw=`): 403 in the browser, client error in the fetch tool.
- OpenRice: security check in the fetch tool, blank page in the browser.
- `defune.co.uk`: browser denied, fetch robots. `arnanz.world`: browser load failed, fetch robots. `macarfi.com` card redirects to its list.
- The Write connector can cancel in under 1 s. Do not retry. Use the SQL Editor.
- `lastminutejapan.com`: fetch blocked.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-holds-summer-palace-done-2026-11-04.md from the project files, then
claude/handoff-oad-2026-first-write-done-2026-11-03.md for methods and OAD data limits, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 285, audit_log 130,110, venues 11,587 (active 11,287, closed 300), awards 27,470,
OAD 2026 rows 2,848, OAD 2025 rows 2,437, slugs 13,435, price 7,759, city_aliases 222, redirects 32, closed published 0 and
cities.venues_count sum 11,287. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Then ask me which open item is next. No write before my "go".
```

**Repo state:** branch `oad-2026-read-block`, not merged to `main` at the time of writing. `main` holds neither this folder nor `docs/open-items-oad-2026-read-block-2026-11-03/`.
