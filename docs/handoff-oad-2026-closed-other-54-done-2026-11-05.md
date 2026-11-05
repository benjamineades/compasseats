# Handoff: Closed venues, other 54 read, write done (Howard's Gourmet Hong Kong closed). Open item closed. Nov 5, 2026 (02:15 Atlanta). Next: Ben chooses.

This file replaces `handoff-oad-2026-closed-weakest-done-2026-11-04.md` for the live state and its open item 1. That file still holds its open items 2-5, its recheck list and its methods. `handoff-oad-2026-names-done-2026-11-04.md`, `handoff-oad-2026-holds-item1-done-2026-11-04.md`, `handoff-oad-2026-holds-status-done-2026-11-04.md` and `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md` hold other open items, methods, dead ends and rechecks. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 02:10 "1-4:A". 02:11 "Go".
- 1A = SOLA stays closed, recheck after Nov 6. 2A = Endo Chelsea no write, open item. 3A = Howard's Gourmet Hong Kong closed and not published, award rows stay. 4A = other 52 no write, rechecks and leads go here.

## Live state (read Nov 5, 07:11:49 UTC, whole tables)
Venues **11,594** (active **11,290**, closed **304**). Awards **27,481** (last id 34,652). OAD 2026 rows **2,859**. OAD 2025 rows 2,437. Slugs **13,535** (canonical 11,594). Price 7,759. Listings 11,594. city_label_source 24,595. city_aliases 222. Redirects 33. Cities 3,318, `cities.venues_count` sum **11,290**. Ledger **241** rows, last id **295**. audit_log **124,803** rows, last id **130,632**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0. Closed venues that hold an OAD 2026 row: 78 (was 77).

## Done
`docs/open-items-oad-2026-closed-other-54-2026-11-04/status-oad-2026-closed-other-54-2026-11-04.sql` (sha256 `3a249cb17834744bcdbe4848bc2ef2d601eff90a9bb1654df481e33fb555bdd7`). Write connector, first try, applied Nov 5 07:11:40 UTC. 1 transaction, all gates passed. The statements sent were the file from `BEGIN;` to `COMMIT;`, sent as typed text, not by a script.

Evidence: `oad-2026-closed-other-54-evidence-2026-11-04.csv` in the same folder (54 rows, sha256 `da645ee9683426a5f34cc057e1672a2510af6902987a7a278368d7fd0b93ac11`). Scripts: `verdicts_other_54.py` (hand verdicts), `build_other_54.py`, `build_sql_other_54.py`. `dry.sql` is the full block. The dry run sent the pre gates with `RAISE EXCEPTION 'dry stop'`.

| Item | Change |
|---|---|
| Status | Howard's Gourmet `ve_5126fcd962` (Hong Kong), active to closed |
| Listing | Published true to false |
| City count | Hong Kong 282 to 281 |
| Ledger | None (status only, as the Oct 10 Texas write) |
| audit_log | 130,630-130,632 (3): venues, listings, cities, all UPDATE |
| Awards | No change. The venue holds 3 rows, including OAD 2026 No. 439 and La Liste 2026 |

**Weak point:** one source. Dimsum Daily, dateline Jun 28, 2026: "ceased operations on 30th May", 11-year run, new brand takes the CCB Tower premises (Lai Sun confirms). The closure sentence names no year. The Lai Sun venue page shows hours, no note, no date.

**Not checked:** the live site. This session did not read a page or a deploy. The Michelin card test was not run in the browser.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

## Result of the read (population: the 54 venues, 1 row for each venue)
No venue of the 54 has proof that it is open today. No venue of the 54 changed.

| Group | Venues | Who |
|---|---|---|
| A Reopening read, not open yet | 1 | SOLA |
| C Closure supported | 26 | Blue Ribbon Sushi Izakaya, Chez Matsuo, Chila, Cote Dor, Cranes, DDOBAR, Eight Tables, Euphoria, ILIS, OTOKO, Tohqa, Spectrum, The Bazaar Miami, Vetri Cucina Las Vegas, bianc, Testina, Contaminazioni, Miyako Zushi, Olamaie, Pierre Gagnaire Tokyo, Pages, Pirouette, Sorrel, Sustanza, Tofuya Ukai, Wine RVLT |
| D Temporary closure | 14 | Al Muntaha, Aürt, Dulce Patria, Gravitas, Manzil, Alexander, The Shota, Ōre, Art di Daniele Sperindio, Quattro Passi, The Grill at Amangani, Urchin, Yama no Ue, Sushi Hashiri |
| M Moved or successor | 4 | Alma, Endo at the Rotunda, 花小路さわ田, Le Passe Temps |
| E Not settled | 9 | Arnanz, Defune, Aloë, Dining in Space, Terroir, Wagyumafia, Howard's Gourmet Beijing, Mikasa, Sushi Ichi |

Name compare (printed OAD name, Nov 3 CSV, against live name): same 18, differs 21, no printed name 15 (the rows with no URL, not compared). Four differences change the reading: Endo, Alma, Howard's Gourmet, Wagyumafia. Quattro Passi prints the same name, with chef and town of Qafiz.

**Stored lines corrected (5):** Aürt reopens mid-2027, not mid-2026. Amangani is a renovation since Apr 7, 2025, not a season pause. Wine RVLT closed July 2025. Testina and Art "site live" lines are out of date.

## Open items
1. **Endo Chelsea, no venue (Ben 2A).** 8-9 Blacklands Terrace, opened October 2026 (Infatuation, Oct 16; Time Out). OAD 2026 No. 169 prints Endo Chelsea with slug `endo-at-the-rotunda`. Row 33167 stays on Endo at the Rotunda `ve_b9d291ce2a`. Rotunda still closed after a fire.
2. **Howard's Gourmet rows.** Asia 143, row 34573, and 2025 rank 119, row 18060, sit on Howard's Gourmet Beijing `ve_decfdabd1b`. OAD prints "(Closed)", city Beijing, the Hong Kong building, chef Howard Cai. Asia 439 on Hong Kong prints "(New)", chef Howard Yim. The rows may belong the other way. Beijing branch not read.
3. **Leads, no venue:** Tsubotsubo (つぼつぼ, successor of 花小路さわ田, tsubotsubo.com). Terroir Expression (Acmen Complex, Bangkok, no link read). 鮨 石橋正和 (OAD chef of Sushi Ichi). Chez Matsuo new main store (own notice, details to follow). Wagyumafia The Butcher's Kitchen (OAD web link, live venue not read). Trü (Aürt team). Buoy (bianc site). Henrique Sá Pessoa `ve_43ae6e7a39` is the live Alma successor; Alma keeps its OAD rows.
4. **Quattro Passi row.** Row 34582 mixes Quattro Passi and Qafiz (chef Nino Rossi, town). Reading stays weak.
5. **Closed venues of OAD 2026:** 78 now. All have a read. Howard's Gourmet Hong Kong is the new one.
6. **Carried:** open items 2-5 of `handoff-oad-2026-closed-weakest-done-2026-11-04.md`.

## Recheck list (added; no scheduled task holds these dates)
SOLA `ve_653d7fb4a4`: after Nov 6, 115a Westbourne Grove; if open, set active, slug `london/sola` stays. Urchin `ve_7dbaa865fb`: Autumn 2026 date has come. Art di Daniele Sperindio `ve_856c6504e9`: end of 2026, METT. The Grill at Amangani `ve_8d69af215c`: late 2026, one title. Quattro Passi `ve_ee9dbbdba9`: May 1, 2027. Al Muntaha `ve_d35cc76459`: about Oct 2027. Aürt `ve_27266639a6`: mid-2027. Le Passe Temps `ve_c39d819f6d`: Paris opening. Manzil `ve_13325dcc24`: new site. Ōre `ve_1b077db3b8`: renovation. Gravitas `ve_e3cd43f5af`: tax seizure. The Shota `ve_68da95719e`. Sushi Hashiri `ve_c85efa6c10` (Yelp temporary, SF Standard outright). Dulce Patria `ve_d28e7d6c06`. Alexander `ve_cd4a28a835`. Yama no Ue `ve_08699c28d8`. Arnanz `ve_c701fffdf6`. Defune `ve_857b831b9a`. Aloë `ve_1cf5b67c05`. Dining in Space `ve_3b38f0d10c`. Terroir `ve_1eae52885e`. Mikasa `ve_31417deb9e`. Sushi Ichi `ve_e77a92118c`. Howard's Gourmet Hong Kong `ve_5126fcd962`: second source.

## Methods (new)
- **A live venue can be closed while its list row reads as a closed twin.** A search for the Beijing branch found the Hong Kong closure.
- **Read the stored date in a link.** The Time Out path ending 081225 is Aug 12, 2025.
- **Search for the printed name first.** "Endo Chelsea" found the new site. A search on the live name would not.
- **Deal sites can show a later opening than the press.** Soft Launch London gave November when The Sauce gave Sep 9.

## Dead ends: do not retry
- `restaurantemanzil.com`: now a gambling page.
- `www.falstaff.com/en/news/new-restaurants-in-malmoe-led-by-chef-niclas-joensson`, `aloerestaurant.se`, `donrockwell.com`, `exploretock.com/gravitasdc/search`, `singaporebrides.com/featured/art/`, `www.yahoo.com/news/articles/two-austins-top-chefs-forced-173442814.html`, `miaminewtimes.com/food-drink/jose-andres-restaurant-reopening-in-south-beach-22540489/`, Tabelog review pages (`dtlrvwlst`) in the fetch tool: client error.
- `guide.michelin.com/gb/en/greater-london/london/restaurant/sola` in the fetch tool: empty.
- WebSearch with `allowed_domains` of 5 sites: proxy rejected once.
- `solasoho.com`: still shows the Soho text. OpenTable reviews stop at May 28, 2026.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-closed-other-54-done-2026-11-05.md from the project files, then
claude/handoff-oad-2026-closed-weakest-done-2026-11-04.md and claude/handoff-oad-2026-names-done-2026-11-04.md for the other open items and rechecks, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 295, audit_log 130,632, venues 11,594 (active 11,290, closed 304), awards 27,481,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,535, price 7,759, city_aliases 222, redirects 33, closed published 0 and
cities.venues_count sum 11,290. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block. It is not merged to main.
Then ask me which open item is next. No write before my "go".
```
