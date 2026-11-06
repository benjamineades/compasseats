# Handoff: Michelin group D Thailand, Finland, Lithuania written, Nov 6, 2026 (14:40 Atlanta). Next: group D Norway (new chat), then Sweden, Denmark, Vietnam.

This file replaces `handoff-michelin-d1-done-2026-11-06.md` for the live state, group D and the open items. That file still holds the D1 record and the card label table. `handoff-michelin-a2-a3-b-e-done-2026-11-06.md` still holds the A2, A3, B, E record, the hold register, the methods and the dead ends. `handoff-michelin-2026-thailand-done-2026-11-05.md` holds the Thailand pairs and the 6 weak pairs. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 6)
- Thailand: 11:53 "1-4:A". 11:54 "Go".
- Finland: 12:09 "Go" (taken as choice 1A, run as built; choices 2-3 were not given then). 14:34 "For LT & FI let's go with what you recommend" (FI 2-3: A).
- Lithuania: 14:34 LT 1-3: A. 14:35 "Go".
- 14:37 "Handoff for new chat".

## Live state (read Nov 6, 19:36 UTC, after the last write, whole tables)
Venues **11,831** (active **11,512**, closed **319**). Awards **29,052** (last id **36,223**). Michelin 2025 / 2026 / 2027 rows **4,179 / 7,821 / 311**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,775**. Price 7,759. city_aliases 222. Redirects 35. `cities.venues_count` sum **11,512**. Ledger **316** rows, last id **370**. audit_log **129,033** rows, last id **134,862**. Closed published 0, active not published 0.

## Done
All through the Write connector, 1 transaction each, first try, all gates passed. The text sent was the whole file, header comments included.

| Write | Change | Ledger | audit_log |
|---|---|---|---|
| Thailand (16:56 UTC) | 178 rows labelled 2026 get the `/us/en/` card URL. Year unchanged | 368 | 134,665-134,842: awards UPDATE 178 |
| Finland (about 17:08 UTC) | 10 rows labelled 2026 get the card URL | 369 | 134,843-134,852: awards UPDATE 10 |
| Lithuania (about 19:36 UTC) | 9 rows get the card URL. Demo row 8930 gets the 2026 article URL | 370 | 134,853-134,862: awards UPDATE 10 |

**Not changed:** names, year, status, price, venues, slugs, cities, redirects, city aliases. The live site does not read Supabase, so no live page changed.

Population: Michelin rows labelled 2026 on venues in each country, rows / with a URL, read after each write. TH 180 / 180 (Three Stars 2/2, Two Stars 8/8, One Star 33/33, Bib 137/137). FI 11 / 11. LT 15 / 15 (Bib 8, One Star 5, special 2).

## Files
| File | sha256 |
|---|---|
| `docs/michelin-d-thailand-2026-11-06/load-michelin-d-thailand-2026-11-06.sql` (ran) | `f73f29cdb620f766a2ba865f6dafd0e7adbf6b77262d7c719228f22222163de4` |
| `.../relay-th-2026-cards-2026-11-06.txt` (equal to the browser) | `1524f063b5abdcc2807d0b2f3031aea064e93eb6af8bb2e0171b0f8366d23c89` |
| `.../michelin-d-thailand-evidence-2026-11-06.csv` | `a64f5d7e49eef5e8be8ce7163c490ca43beaf9fce36860448cb840d32dd9186a` |
| `docs/michelin-d-finland-2026-11-06/load-michelin-d-finland-2026-11-06.sql` (ran) | `bf723e34382e1f42a7ac3534bf197a7c89a9a271190a374b0a7f70573204b051` |
| `.../relay-fi-2026-cards-2026-11-06.txt` (equal to the browser) | `c1c962cfbc0c3ec86b2466db334e863b910e2774d28bea226d5cc2c5981da94b` |
| `.../michelin-d-finland-2026-11-06-evidence.csv` | `93f291be8b2f38e928e0e0de98b319a2e5735c06aa6e8a2d984fb46757718c3f` |
| `docs/michelin-d-lithuania-2026-11-06/load-michelin-d-lithuania-2026-11-06.sql` (ran) | `358a53f33062db6eed2705115c8936559e84b768bf05639e7cf60f4c76f807f8` |
| `.../relay-lt-2026-cards-2026-11-06.txt` (equal to the browser) | `cacd419a5076318467a151e95a03811d58786d6994c9141b2f7b71cf25429883` |
| `.../michelin-d-lithuania-2026-11-06-evidence.csv` | `9ac00756362b94e0ddc3c0775ba84a0448e458377b025c57bc4e2ccb06f716aa` |
| `docs/michelin-d-shared/build_d_url.py` (shared build script) | `9d0afb433b975af4daab68863ea12bcfd88cc84bd5bbf92c2cec8c0ef94a6752` |

Each country folder also holds `baseline.json`, `pairs.tsv`, `config.json` (FI, LT) and `relay.sha256`. Thailand uses its own `build_sql.py` and the Nov 5 `pairs.tsv`.

## Decisions (Ben, Nov 6)
**Thailand (1-4: A):**
1. Run before Nov 10 (178 rows).
2. The 6 weak pairs of Nov 5 got the card URL too.
3. The 178 URLs will repeat on the Thailand 2027 rows. The `url in use` gate of the 2027 file must allow all 180 Thailand card URLs.
4. No name or price change. The 85 names stay on the rename batch.

**Finland (1: Go, 2-3: A):** 2. 9 names go to the rename batch (the live names add "Ravintola" or "Restaurant": Ravintola 305, Restaurant Bona Fide, Ravintola Nolla, Ravintola Finnjävel SALONKI, Restaurant Olo, Restaurant VÅR, Restaurant Kaskis, Ravintola Palace, Restaurant Grön; card names 305, Bona Fide, Nolla, Finnjävel Salonki, Olo, VÅR, Kaskis, Palace, Grön). 3. Restaurant Plein `ve_86ddfb9773` (2025 Bib only, not on the 2026 list) goes to the recheck list.

**Lithuania (1-3: A):**
1. Run 9 card URLs plus the Demo article URL (rule of the A2-E handoff: a card that left the site and has no capture takes the article that names the venue).
2. Demo (Vilnius) `ve_87f2380c44` goes to the recheck list.
3. 2 names go to the rename batch: "BARN bistro ( B’ARN )" to card "B'ARN Bistro", "Gaspars" to card "Gaspar's". Restoranas Kristoforas `ve_5704c34d40` (2025 Bib only, not on the 2026 list) goes to the recheck list.

## Evidence notes
- **Thailand cards (Nov 6, 16:29-16:42 UTC):** population 180 cards. Status 200 on 180, label "2026 MICHELIN Guide Thailand" on 180, 0 closure notes, 0 redirects, 0 refusals at a 3.5 s pause in blocks of 40 with 30 s between blocks. Card URL, tier, name, city and price equal the Nov 5 list read on all 180. Bib list still 137 (not the 2027 list of 151) at 16:53 UTC.
- **Finland:** list 0 / 2 / 6 / 3 = 11 = the 11 rows labelled 2026. All 11 cards 2026.
- **Lithuania:** list 0 / 0 / 4 / 8 = 12. All 12 cards 2026. Demo: Michelin article "The MICHELIN Guide Lithuania 2026 Has Been Unveiled!" (Jun 5, 2026, `https://guide.michelin.com/lt/en/article/michelin-guide-ceremony/all-the-winners-michelin-guide-lithuania-2026-has-been-unveiled-new-stars-bib-gourmands-special-awards`) names Demo as keeping its One Star and links the card `demo-1210016`. govilnius.lt (Jun 10, 2026) and Falstaff say the same. Card `/us/en/vilnius-region/vilnius_1985479/restaurant/demo-1210016`: 404 on Nov 6 (17:16 and 19:34 UTC). The slug `.../restaurant/demo` redirects to the Helsinki Demo card. Wayback CDX (exact URL, 9 locales): us/en, lt/en, gb/en, de/de, fr/fr, tw/en Sep 7, 2024 only; `/en/` last Nov 8, 2025 (label "2025 MICHELIN Guide Lithuania"); lt/lt and qa/en none. 0 captures after the ceremony. No closure report found (2 web searches). The venue is `active`. The article URL is now on 3 rows (8930, 21162, 21163).
- **Fujian 2027:** not out. Jing Li card "2026 MICHELIN Guide Fuzhou" at 16:28, 16:53, 17:00, 17:10, 19:34 UTC.

## Group D: still open (re-read first)
Population: Michelin rows labelled 2026 with no URL, from the D1 handoff (read Nov 6 before D1).

| Order | Country | Rows | Note (D1 card label read) |
|---|---|---|---|
| 1 | **Norway** | 22 | Next. Site 2 / 2 / 17 / 3; DB One Star 19 (+2). Expect 2 cards that left the site: apply the A2-E rule (capture, else article, else no URL) |
| 2 | Sweden | 34 | Site 1 / 4 / 18 / 14; DB Bib 15 (+1) |
| 3 | Denmark | 56 | Site 3 / 7 / 32 / 27; PAZ sits in the Denmark list but is FO in the DB (already has its URL). DB Two Stars 6 + 1 other |
| 4 | Vietnam | 66 | Site 0 / 0 / 11 / 70; DB Bib 71 (+1), +5 other |
| – | Malaysia | 66 | Archive URL item (Ben 6A) |
| – | Austria | 1 | 35543, archive URL item (Ben 2A) |

2025 rows with no URL stay out of group D: DK 57, SE 34, NO 22, FI 11, LT 11, IS 3, FO 1, VN 68.

## Hold register
- No new rows. All entries of the D1 and A2-E handoffs stay (Earl, Christchurch, and the special awards lists).

## Weak points
- Thailand and Lithuania SQL text sent to the Write connector was copied from the file printout, not hashed against the file. The md5 plan gates cover the plan text.
- Finland "Go" came before choices 2-3; Ben confirmed them at 14:34. The Finland ledger text says "choices 2-3 open".
- Demo: the reason the card left the site is not known. The article URL proves the 2026 edition, not the venue status today.
- Pairs for FI and LT were written by hand from a live read (10 and 9 lines). The gates check venue, category, year and a null URL on every plan row.

## Open items, in order
1. **Group D Norway (next, new chat).** Then Sweden, Denmark, Vietnam, one at a time.
2. **Gault & Millau France and Monaco 2027 (after Nov 9). Thailand 2027 (after Nov 10).** The Thailand 2027 file must allow the 180 Thailand card URLs in its `url in use` gate. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. Price item adds Atelier and Muttonbird.
3. Status read of the 45 Top 500 venues.
4. **Rechecks:** as in the A2-E handoff, plus Restaurant Plein `ve_86ddfb9773`, Restoranas Kristoforas `ve_5704c34d40`, Demo (Vilnius) `ve_87f2380c44`.
5. Same-name pairs: as before.
6. **Rename batch:** as in the D1 handoff, plus the 9 Finland names and the 2 Lithuania names above.
7. Archive URLs: as in the D1 handoff (Schlosskeller Wirtshaus 35543, Malaysia 66 rows labelled 2026, and the rest). Thailand 178 rows: no longer needed (now card URLs).
8. Phase 2 publish job (goal Nov 29), Phase 3 location pass, history backfill: as before.
9. Plan v1.31: add D1, Thailand (ledger 368), Finland (369), Lithuania (370), Ben's 5A, 6A and these choices.
10. Research result (after Nov 7): see the radar handoff.

## Methods (new)
- **Shared build script:** `docs/michelin-d-shared/build_d_url.py`. Run from the country folder: `python3 ../michelin-d-shared/build_d_url.py config.json <scope_fp> '<approval>' <scratch>`. Inputs: `config.json` (key, iso, guide, label, year, rule text, relay, `have_url` rows that already hold their card URL, `rows_after`, optional `article` rows), `baseline.json`, `pairs.tsv` (slug, venue_id, award_id), relay and `relay.sha256`. It writes the SQL, the dry-run file (`<scratch>/dry-<iso>.sql`) and the evidence CSV. It rebuilds the Finland file byte for byte.
- **Scope fingerprint:** `md5(string_agg(a.id|v.id|category|year|status|city_id|v.name|coalesce(source_url,'-')))` over the country's Michelin rows. Read it read-only, then pass it to the script.
- **Browser reader:** `window.readSel(selection_slug, key)` in a guide.michelin.com tab (Chrome connector). It reads the Fujian card, the 4 tier lists (3.5 s pause, pages until the `h1` total), then every card (3.5 s pause), and builds the escaped, sorted relay and its sha256 on `window[key]`. Poll with a 43 s wait. Then write the relay into `<article><pre>` and read it with `get_page_text`. The function lives only in that tab; paste it again in a new chat (see the Lithuania session in the chat or rebuild from this description).
- **Relay save:** the Write tool decodes `\uXXXX`. Save, then re-escape non-ASCII by script, then compare the sha256 with the browser.
- **Card that left the site:** probe the card URL, search guide.michelin.com for the card slug (Demo was `demo-1210016`), CDX per locale with the exact URL (a wildcard in the middle of the path returns nothing), read the label of the last capture, then read the Michelin edition article in the tab and search it for the venue name.
- **Long JS output:** returning more than about 2 KB of JSON came back "[TRUNCATED]". Use the `<pre>` relay.

## Dead ends: do not retry
- CDX with `restaurant*` in the middle of the URL: 0 results. Use the exact URL.
- `cities.name` (columns are `display`, `slug`, `country`, `country_iso`, `region_id`, `kind`, `lat`, `lng`).
- All dead ends of the D1 and A2-E handoffs stay.

**Repo:** branch `oad-2026-read-block` holds the 3 country folders, `michelin-d-shared/` and this handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt: group D Norway
```
Read claude/handoff-michelin-d-th-fi-lt-done-2026-11-06.md from the project files, then
claude/handoff-michelin-d1-done-2026-11-06.md for the card label table,
claude/handoff-michelin-a2-a3-b-e-done-2026-11-06.md for methods, the hold register, the card-left-the-site rule and dead ends,
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 370, audit_log 134,862, venues 11,831 (active 11,512, closed 319), awards 29,052,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,512. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block. Use docs/michelin-d-shared/build_d_url.py.
Before each group, read again whether Fujian 2027 is out. If it is, tell me and ask where it goes in the order.
Do group D, smallest first: Norway, then Sweden, Denmark, Vietnam, one at a time. For each: read the list and all cards slowly (3.5 s between cards), pair the rows, and treat any card that left the site with the card-left-the-site rule.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
