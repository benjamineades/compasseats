# Handoff: Michelin group D Norway and Sweden written, 2 closures, Nov 6, 2026 (16:40 Atlanta). Next: group D Denmark (new chat), then Vietnam.

This file replaces `handoff-michelin-d-th-fi-lt-done-2026-11-06.md` for the live state, group D and the open items. That file still holds the Thailand, Finland and Lithuania record. `handoff-michelin-d1-done-2026-11-06.md` holds the D1 record and the card label table. `handoff-michelin-a2-a3-b-e-done-2026-11-06.md` holds the hold register, the card-left-the-site rule, the methods and the dead ends. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 6)
- Norway: 15:17 "1-5:A". 15:19 "Go" (URL load). 15:42 "Go" (Bar Amour closure).
- Sweden: 15:55 "1-4:A". 16:25 "Go" (URL load). 16:35 "Go" (JH matbar closure).
- 16:25 I suggested a handoff before Denmark. Ben did not answer it. I stopped here, as the working rule says.

## Live state (read Nov 6, 21:36 UTC, after the last write, whole tables)
Venues **11,831** (active **11,510**, closed **321**). Awards **29,052** (last id 36,223). Michelin 2025 / 2026 / 2027 rows 4,179 / 7,821 / 311. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs 13,775. Price 7,759. city_aliases 222. Redirects 35. `cities.venues_count` sum **11,510**. Cities that differ from `city_venue_counts` 0. Ledger **320** rows, last id **374**. audit_log **129,096** rows, last id **134,925**. Closed published 0, active not published 0.

## Done
All through the Write connector, 1 transaction each, first try, all gates passed. The text sent was the whole file, header comments included.

| Write | Change | Ledger | audit_log |
|---|---|---|---|
| Norway URLs (20:20 UTC) | 20 card URLs; 2 archive capture URLs: 7119 À L'aise, 7100 Bar Amour. Year unchanged | 371 | 134,863-134,884: awards UPDATE 22 |
| Bar Amour closure (about 20:43 UTC) | `ve_6b4eb76969` closed, listing unpublished, Oslo `ci_8cfbfaefa5` 20 to 19 | 372 | 134,885-134,887: cities, listings, venues UPDATE 1 each |
| Sweden URLs (about 21:26 UTC) | 33 card URLs; 13007 JH matbar gets the Nordic 2026 Bib article URL; 3142 Vyn Food & Wine Bar `is/en` URL replaced by the `/us/en/` card | 373 | 134,888-134,922: awards UPDATE 35 |
| JH matbar closure (about 21:36 UTC) | `ve_7c9cd89dc7` closed, listing unpublished, Ystad `ci_d5e7c73654` 1 to 0 | 374 | 134,923-134,925: cities, listings, venues UPDATE 1 each |

**Not changed:** names, year, price, slugs, redirects, city aliases, award rows of the 2 closed venues. The live site does not read Supabase, so no live page changed.

Population: Michelin rows labelled 2026 on venues in each country, rows / with a URL, read after each write. NO 26 / 26 (Three 2, Two 2, One 19, Bib 3). SE 38 / 38 (Three 1, Two 4, One 18, Bib 15).

## Files (branch `oad-2026-read-block`)
| File | sha256 |
|---|---|
| `docs/michelin-d-norway-2026-11-06/load-michelin-d-norway-2026-11-06.sql` (ran) | `70a87ef6336fb03809bf214ed1f42cfae1923d23bd089f498b0a8c33ff7794c0` |
| `.../relay-no-2026-cards-2026-11-06.txt` (equal to the browser) | `51c51361b6be81bed2451afd438ba3185d36934607f5bbbd6c7f6128d4fcff51` |
| `.../michelin-d-norway-2026-11-06-evidence.csv` | `d6b8f1358285f659c060929005746db742c4d7636a973a1d57d1009f87b5e996` |
| `.../closure-michelin-d-norway-bar-amour-2026-11-06.sql` (ran) | `fa9397577340cc0ed12f7878c0c5b2c15bd7eb7a67489b171c21221cf7c9588a` |
| `.../build_closure.py` (Norway) | `389d0c1369119a92079dbb3700ef41c59270a109fb3aeadd13b70439619b5930` |
| `docs/michelin-d-sweden-2026-11-06/load-michelin-d-sweden-2026-11-06.sql` (ran) | `30165635c6dd512f058d7d904cc159dbe3413b71ed649549b06389f1e596b347` |
| `.../relay-se-2026-cards-2026-11-06.txt` (equal to the browser) | `3dd27529f076c8b86f1e0faa967b504322b78b027257915eb2c2e69bdb1e4d2c` |
| `.../michelin-d-sweden-2026-11-06-evidence.csv` | `46a9f0c9a19544160c155eabe09f5fb407e4b05c0ac312f36042c601ecf9b9d4` |
| `.../closure-michelin-d-sweden-jh-matbar-2026-11-06.sql` (ran) | `6c585a4dfa24c5330d55d959d9f278afca866b8739a04e46d4c65e29ebacbaf5` |
| `.../build_closure.py` (Sweden) | `6e7a08474f2d420529db4184291abc3a4ccc40f5777dc484cec52854396cedd1` |
| `docs/michelin-d-shared/build_d_url.py` (changed, see Methods) | `5d7029803e743fad9a723122fd083d291c671fda1a117b301e5ba828bc062eb1` |
| `docs/michelin-d-shared/readSel.js` (new) | `0c373f466635b9f57763d58dec46415b3320b49fc988c8aad5505fba95775dcb` |

Each country folder also holds `baseline.json`, `pairs.tsv`, `config.json` and `relay.sha256`.

## Decisions (Ben, Nov 6)
**Norway (1-5: A):**
1. Run as built: 20 card URLs, 2 archive capture URLs.
2. Bar Amour `ve_6b4eb76969`: separate closure file (ran, ledger 372).
3. À L'aise `ve_7a1fc079d2`: recheck list (card left the site, reason not known).
4. Rename batch, 10 names: Frances Vin- og kaffebar to Frances Vinbar; Under Lindesnes to Under; Restaurant Hot Shop to Hot Shop; Hermetikken Restaurant to Hermetikken; Restaurant K2 to K2; Sabi Omakase to Sabi Omakase Stavanger; Restaurant Kontrast to Kontrast; Savage to SAVAGE; Fagn to FAGN; Re-naa to RE-NAA.
5. Smalhans `ve_96f3cf62b7` (2025 Bib only, not on the 2026 list): recheck list.

**Sweden (1-4: A):**
1. Run as built.
2. Vyn Food & Wine Bar 3142: `is/en` URL replaced by the `/us/en/` card.
3. JH matbar `ve_7c9cd89dc7`: closure file (ran, ledger 374), same treatment as Lasai. Recheck May 2027 (Malmö reopening).
4. Rename batch, 11 names: Restaurang Allegrine to Allegrine; Restaurang Ärla to ÄRLA; Matbaren Mathias Dahlgren to Matbaren; Restaurang Triton to Triton; HOZE Sushiya to HOZE; PM & Vänner to PM & Vänner Restaurant; Restaurang & Vinbaren 28+ to 28+; Restaurang Äng to ÄNG; Restaurant Ekstedt to Ekstedt; Restaurant Operakällaren to Operakällaren; Vyn Restaurant to VYN.

## Evidence notes
- **Norway cards (19:57-19:59 UTC):** list 2 / 2 / 17 / 3 = 24. All 24 cards: status 200, label "2026 MICHELIN Guide Norway", 0 redirects, 0 closure notes. Michelin Nordic 2026 full star list (`/fi/en/article/michelin-guide-ceremony/full-list-of-michelin-star-restaurants-in-the-nordic-countries`, Jun 1, 2026) names 19 Norway One Stars, including À L'aise and Bar Amour, and marks Bar Amour "(Update: Now Closed)". Cards `a-l-aise` and `bar-amour` 404. Wayback: 1 capture each after the ceremony, `no/en`, Jun 1, 2026 21:34 UTC, label 2026, One Star (10 locales read). Store norske leksikon (edited Aug 8, 2026): Bar Amour closed in the first half of 2026. À L'aise: no closure found (2 searches); Falstaff (edited Sep 4, 2026) shows opening hours.
- **Sweden cards (20:43-20:46 UTC):** list 1 / 4 / 18 / 14 = 37. All 37 cards: status 200, label "2026 MICHELIN Guide Sweden", 0 redirects, 0 closure notes. Nordic 2026 Bib article (`/fi/en/article/michelin-guide-ceremony/new-good-value-bib-gourmand-restaurants-nordic-countries-denmark-finland-iceland-norway-sweden`, Jun 1, 2026) lists 15 Sweden Bibs including JH Matbar, Ystad. Card `/skane/ystad_2694134/restaurant/jh-matbar` 404 in us/en, en, se/en. Wayback: last capture May 27, 2024, 0 after the ceremony (10 locales). jhmatbar.se: leaves Ystad after five years, Malmö, "Reopening may 2027" (read through WebFetch summary).
- No Sweden venue has a 2025 Michelin row without a 2026 row.
- **Fujian 2027:** not out. Jing Li "2026 MICHELIN Guide Fuzhou" at 19:56 and 20:43 UTC.
- The us/en paths of the Nordic full star list and the Bib article give 404. The fi/en, se/en and dk/en paths give 200. The us/en "All the Winners" article (Jun 1, 2026) does not name the 2 Oslo venues or JH matbar.

## Group D: still open (re-read first)
Population: Michelin rows labelled 2026 with no URL, from the D1 handoff (read Nov 6 before D1).

| Order | Country | Rows | Note (D1 card label read) |
|---|---|---|---|
| 1 | **Denmark** | 56 | Next. Site 3 / 7 / 32 / 27; PAZ sits in the Denmark list but is FO in the DB (already has its URL, `have_url` will not see it: the scope is `country_iso = 'DK'`, so PAZ must be left out of `pairs.tsv` and the coverage check needs it handled, see Methods). DB Two Stars 6 + 1 other |
| 2 | Vietnam | 66 | Site 0 / 0 / 11 / 70; DB Bib 71 (+1), +5 other |
| – | Malaysia | 66 | Archive URL item (Ben 6A) |
| – | Austria | 1 | 35543, archive URL item (Ben 2A) |

2025 rows with no URL stay out of group D: DK 57, SE 34, NO 22, FI 11, LT 11, IS 3, FO 1, VN 68.

## Hold register
- No new rows. All entries of the D1 and A2-E handoffs stay.

## Weak points
- The SQL text sent to the Write connector (4 files) and the dry-run text were copied from the file printout, not hashed against the file. The md5 plan gates cover the plan text.
- JH matbar move rests on the restaurant's own site through a summary tool; no closing date is known.
- Bar Amour closure rests on the Michelin article note and 1 encyclopedia page.
- Pairs for NO and SE were written by hand from the live read (20 and 33 lines). The gates check venue, category, year and a null URL on every plan row.
- The relay saved by heredoc from `get_page_text` output; the hash equals the browser on both.

## Open items, in order
1. **Group D Denmark (next, new chat).** Then Vietnam.
2. **Gault & Millau France and Monaco 2027 (after Nov 9). Thailand 2027 (after Nov 10).** The Thailand 2027 file must allow the 180 Thailand card URLs in its `url in use` gate. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. Price item adds Atelier and Muttonbird.
3. Status read of the 45 Top 500 venues.
4. **Rechecks:** as in the A2-E and D-TH-FI-LT handoffs, plus À L'aise `ve_7a1fc079d2`, Smalhans `ve_96f3cf62b7`, JH matbar `ve_7c9cd89dc7` (May 2027, Malmö reopening: new city, the venue is closed now).
5. Same-name pairs: as before.
6. **Rename batch:** as before, plus the 10 Norway names and the 11 Sweden names above.
7. Archive URLs: as in the D1 handoff.
8. Phase 2 publish job (goal Nov 29), Phase 3 location pass, history backfill: as before.
9. Plan v1.31: add D1, Thailand (368), Finland (369), Lithuania (370), Norway (371, 372), Sweden (373, 374), Ben's 5A, 6A and all group D choices.
10. Research result (after Nov 7): see the radar handoff.

## Methods (new)
- **Browser reader in the repo:** `docs/michelin-d-shared/readSel.js`. Paste it into a guide.michelin.com tab with `javascript_tool`, then `window.readSel('<slug>','<KEY>')`. Poll with a 40-43 s wait. Norway 24 cards took 106 s, Sweden 37 cards 184 s, 0 refusals.
- **`build_d_url.py` options (new, all optional, Finland, Lithuania and Norway rebuild byte for byte):**
  - `art_kind`: `article` (default) or `capture`. It changes only the header, ledger and evidence wording for the `article` rows.
  - `other_url`: `[[award_id, venue_id, slug, current_url, 'keep'|'replace']]` for a card row that holds another URL (for example another locale). `keep` gates the current URL. `replace` gates the current URL, then sets the `/us/en/` card URL and adds the rows to the audit and ledger counts.
  - Coverage rule: `pairs` + `have_url` + `other_url` must cover the relay cards once each. For PAZ in Denmark (a card in the Denmark list on an FO venue), a new option or a relay filter is needed; decide in the Denmark session.
- **Closure file:** `build_closure.py` in the Norway and Sweden folders (model: `michelin-e`). Gates: venue fingerprint `md5(id|name|status|city_id)`, 1 published listing, the venue's award rows as a string, all counts, the city count, city view 0 differences, audit last id. Writes: venue status, listing published, city `venues_count`, 1 ledger row (`closure:` prefix, field type `award`). Audit: cities, listings, venues UPDATE 1 each.
- **A quote in a ledger note** breaks the SQL string. Use the typographic apostrophe (’).
- **Archive capture URL form:** `https://web.archive.org/web/<ts>id_/https://guide.michelin.com/<locale>/...`.

## Dead ends: do not retry
- `/us/en/article/michelin-guide-ceremony/full-list-of-michelin-star-restaurants-in-the-nordic-countries` and `/us/en/article/.../all-new-michelin-one-two-three-star-restaurants-list-nordic-countries-...`: 404. Use `/fi/en/`.
- Nordic article body in `.detail-page__content`: only a summary of about 580 characters. Read the raw HTML or `doc.body`.
- Card slug guesses `a-l-aise-1194935`: 404.
- All dead ends of the D1, A2-E and D-TH-FI-LT handoffs stay.

**Repo:** branch `oad-2026-read-block` holds the Norway and Sweden folders, the changed shared script and this handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt: group D Denmark
```
Read claude/handoff-michelin-d-no-se-done-2026-11-06.md from the project files, then
claude/handoff-michelin-d-th-fi-lt-done-2026-11-06.md,
claude/handoff-michelin-d1-done-2026-11-06.md for the card label table,
claude/handoff-michelin-a2-a3-b-e-done-2026-11-06.md for methods, the hold register, the card-left-the-site rule and dead ends,
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 374, audit_log 134,925, venues 11,831 (active 11,510, closed 321), awards 29,052,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block. Use docs/michelin-d-shared/build_d_url.py and docs/michelin-d-shared/readSel.js.
Before each group, read again whether Fujian 2027 is out. If it is, tell me and ask where it goes in the order.
Do group D Denmark, then Vietnam, one at a time. For each: read the list and all cards slowly (3.5 s between cards), pair the rows, and treat any card that left the site with the card-left-the-site rule. Denmark: PAZ sits in the Denmark list but is a Faroe Islands venue; handle it without a write to its row.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
