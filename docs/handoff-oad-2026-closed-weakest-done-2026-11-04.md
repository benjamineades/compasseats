# Handoff: Closed venues, 26 weakest read, write done (3 active, 1 renamed). Open item closed. Nov 4, 2026 (18:55 Atlanta). Next: Ben chooses.

This file replaces `handoff-oad-2026-names-done-2026-11-04.md` for the live state and its open item 2. That file still holds open items 1, 3, 4, 5, its recheck list and its methods. `handoff-oad-2026-holds-item1-done-2026-11-04.md`, `handoff-oad-2026-holds-status-done-2026-11-04.md` and `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md` hold methods, dead ends and rechecks. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 4)
- 18:49 "1-5: A". 18:50 "Go".
- 1A = Mandarin Grill + Bar and Kawaki active. 2A = T3 renamed Treis, new slug, active. 3A = Agreste stays closed, recheck. 4A = other 22 no write, rechecks. 5A = Kawaki city stays Fukui, open item.

## Live state (read Nov 4, 23:51:38 UTC, whole tables)
Venues **11,594** (active **11,291**, closed **303**). Awards **27,481** (last id 34,652). OAD 2026 rows **2,859**. OAD 2025 rows 2,437. Slugs **13,535** (canonical 11,594). Price 7,759. Listings 11,594. city_label_source 24,595. city_aliases 222. Redirects 33. Cities 3,318, `cities.venues_count` sum **11,291**. Ledger **241** rows, last id **295**. audit_log **124,800** rows, last id **130,629**. Rename batch last id **52**, rename_rows 1,562. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0. Closed venues that hold an OAD 2026 row: 77 (was 80).

## Done
`docs/open-items-oad-2026-closed-weakest-2026-11-04/status-oad-2026-closed-weakest-2026-11-04.sql` (sha256 `a7a2ac48935c80855f2427dea1b77cc6b9bba764abc72f502fc7a023906ef396`). Write connector, first try, applied Nov 4 23:51:17 UTC. 1 transaction, all gates passed.

Evidence: `closed-weakest-evidence-2026-11-04.csv` in the same folder (26 rows). Scripts: `verdicts_closed_weakest.py` (hand verdicts), `build_closed_weakest.py`, `build_sql_closed_weakest.py`. `dry.sql` is the dry run.

| Item | Change | Ids |
|---|---|---|
| Set active and published | Mandarin Grill + Bar `ve_d3e2463621`, Kawaki `ve_60a5408dd6`, Treis `ve_644d124840` | |
| Rename | T3 (ティースリー) to Treis, source `oad` | Batch 52 |
| Slug | `tokyo/treis` new canonical, `tokyo/t3` non-canonical. No redirect row | |
| City counts | Hong Kong 282, Fukui 2, Tokyo 675 | |
| Ledger | 295 (oad, name, 1) | |
| audit_log | 130,618-130,629 (12): venues UPDATE 4, listings UPDATE 3, cities UPDATE 3, slugs UPDATE 1, slugs INSERT 1 | |

**Finding, T3:** the database name was wrong. OAD 2026 No. 90 and OAD 2025 No. 119 both print Treis - τρεῖς, chef Hideaki Kawashima. Restaurant T3 (Azabudai, Tabelog permanently closed) is another restaurant, with no award row here. The earlier "not found" came from the wrong name.

**Weak points:**
- Mandarin Grill + Bar: the hotel page has no date.
- Kawaki: real place is Sakai (Mikuni), database city is Fukui. OAD prints a Katamachi, Fukui address and the correct phone.
- Treis: members-only. Tabelog does not show the address. OAD prints 3-18-12 Nishi-Azabu. Tabelog read through the fetch tool. `name_native` not set.
- Many reads are short fetch reports. The CSV `method` column gives the method for each venue.

**Not checked:** the live site. This session did not read a page or a deploy.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

## Result of the read (population: the 26 venues, sweep groups 7, 9, 11)
| Group | Venues | Result |
|---|---|---|
| A Open, strong | 2 | Active |
| B Open, wrong name | 1 | Active, renamed |
| C Closure evidence | 12 | Closed: DIM Dining, Le Restaurant OKUDA, Yakiniku Futago Soho, Torno Subito, Golden Flower, Tempura Uchitsu, Sushi Tsujita, Canvas, L'Impression, Setsugekka Nagoya, SOWER, SUSHI Nagai |
| D Temporary closure or move | 3 | Closed, recheck: Zuicho, Chiba Takaoka, Agreste de Fabio & Roser |
| E Not settled | 8 | Closed, recheck: Breda, TIRPSE, ICHU Hong Kong, Sushi Sase, J'AIME, Kojima, Tsuroku, Pepita's Kitchen |

## Open items
1. **Closed venues OAD 2026 prints, other 54 of 80 (Ben 4A: not read).** Groups in `oad-2026-closed-venues-evidence-2026-11-04.csv`. The 20 not in the sweep hold a best-match evidence line from repo files: check it first if this is ever read.
2. **Kawaki city (Ben 5A, new).** Sakai (Mikuni) or Fukui. Live slug `fukui/kawaki`. `fukui` holds 2 venues.
3. **Setsugekka Tanaka Satoru, lead, no venue.** Sakae, Nagoya, Tabelog open (visit Jul 2026). Affiliate of the closed Nikuya Setsugekka NAGOYA. OAD prints the closed one. No write.
4. **SOWER:** the hotel restaurant is now Lacs by Tokuyama. Hotel closed Apr 11, 2026.
5. **Carried:** open items 1, 3, 4, 5 of `handoff-oad-2026-names-done-2026-11-04.md`.

## Recheck list (added; no scheduled task holds these dates)
Zuicho `ve_39b34a092b` (new address; last day June 30, no year). Chiba Takaoka `ve_ca7ad6ea1a` (reopening). Agreste `ve_5d078c2bc3` (a blog says new site not before Sep 2026; look for a dated reopening; Agreste Mar at Hotel Serras is separate). Breda `ve_b2d722cfdf`. TIRPSE `ve_d4f88bfa68`. ICHU Hong Kong `ve_6283b33f1c`. Sushi Sase `ve_327f03bdaf`. J'AIME `ve_549250a06b`. Kojima `ve_588a02f12f`. Tsuroku `ve_2dac0ec8c2`. Pepita's Kitchen `ve_e46ce3137f`. SUSHI Nagai `ve_8f264b2b86` (search titles only).

## Methods (new)
- **Read the OAD page before a name search.** The Nov 3 evidence CSV holds the printed OAD name. A live name can differ from it.
- **Michelin card test with a control between each card.** `fetch(path)` from a tab, control DiverXO, pause 1.5 s. 12 of 12 cards gave a 404 with the control at 200. A 404 can mean only that the guide dropped the venue.
- **Michelin search can return 404 in a run.** 5 of 16 searches did, with the control at 200 at the end.
- **Time Out HK has no value as an open signal.** Zuicho shows no closed label while its own site says it is leaving.
- **Yelp title with no CLOSED is not proof.** OKUDA has none, and its owner confirms the closure.
- **Hotel news pages show dated closures.** `lhotel-du-lac.com/news/`, read with a loop over the links from a tab.

## Dead ends: do not retry
- `tsujita-sushi.com` in the browser: certificate invalid. `canvasbangkok.com`: Website Expired.
- `spot.ph`, `esquiremag.ph`: fetch client error, browser security check.
- `opentable.co.uk` in the browser: Access Denied. `opentable.com` opens in the fetch tool.
- `serrasbarcelona.com/ca/gastronomia/agreste-mar/`: 404. `hqueens.com.hk/en/tenants`: 404. `k11musea.com/en/dining/`: page not found. `ichu.com.hk`: a recipe blog, not the restaurant.
- `bredagroup-amsterdam.com` in the browser: 503 on Nov 4. Fetch of the home page: robots.
- `autoreserve.com`, `siksinhot.com`, `seoultourism.org`: fetch client error.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-closed-weakest-done-2026-11-04.md from the project files, then
claude/handoff-oad-2026-names-done-2026-11-04.md for the other open items and rechecks, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 295, audit_log 130,629, venues 11,594 (active 11,291, closed 303), awards 27,481,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,535, price 7,759, city_aliases 222, redirects 33, closed published 0 and
cities.venues_count sum 11,291. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block. It is not merged to main.
Then ask me which open item is next. No write before my "go".
```
