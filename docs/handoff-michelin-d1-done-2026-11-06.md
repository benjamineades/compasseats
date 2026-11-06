# Handoff: Michelin group D1 (Faroe Islands, Iceland, New Zealand, Austria) written, Nov 6, 2026 (11:25 Atlanta). Next: group D Thailand (new chat), before Nov 10.

This file replaces `handoff-michelin-a2-a3-b-e-done-2026-11-06.md` for the live state, group D and the open items. That file still holds the A2, A3, B, E record, the hold register, the methods and the dead ends. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 6)
- 11:20 "1-6: A". 11:22 "Go". 11:24 "Let's do a new chat" (handoff before Thailand).

## Live state (read Nov 6, 16:23 UTC, after the write, whole tables)
Venues **11,831** (active **11,512**, closed **319**). Awards **29,052** (last id **36,223**). Michelin 2025 / 2026 / 2027 rows **4,179 / 7,821 / 311**. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,775**. Price 7,759. city_aliases 222. Redirects 35. `cities.venues_count` sum **11,512**. Ledger **313** rows, last id **367**. audit_log **128,835** rows, last id **134,664**. Closed published 0, active not published 0.

## Done
`docs/michelin-d1-2026-11-06/load-michelin-d1-2026-11-06.sql`, Write connector, 1 transaction, first try, 16:23 UTC, all gates passed. The text sent was the whole file, header comments included.

| Item | Change |
|---|---|
| Card URL on rows labelled 2026 | 6: 3444 PAZ (Two Stars), 5212 Moss, 7547 DILL, 7550 ÓX (One Star), 21191 Atelier, 21207 Muttonbird (Bib). Year and category unchanged |
| Ledger | 366 (Nordic, 4), 367 (New Zealand, 2) |
| audit_log | 134,659-134,664: awards UPDATE 6 |

**Not changed:** names, status, price, venues, slugs, cities, redirects, city aliases. The live site does not read Supabase, so no live page changed.

Population: Michelin rows on venues in each country, rows / with a URL, read after the write.
- 2026: FO 1 / 1, IS 3 / 3, NZ 51 / 51, AT 161 / 160 (the one with no URL is 35543 Schlosskeller Wirtshaus).
- 2025: FO 1 / 0, IS 3 / 0, AT 2 / 2.

## Files
Folder `docs/michelin-d1-2026-11-06/`: SQL, `baseline.json`, `pairs.tsv`, relay, `build_sql.py`, evidence CSV.

| File | sha256 |
|---|---|
| `load-michelin-d1-2026-11-06.sql` (ran) | `4726c2af24207aeefe60872f3bb369afc039df58a9a7a13b7fa14ad78b87921e` |
| `relay-d1-2026-cards-2026-11-06.txt` (equal to the browser) | `401ce717d7acd2459994d913b1fb6649a030fdf8d774ba37dda0d01503336170` |
| `michelin-d1-evidence-2026-11-06.csv` | `2db9e26bf51c06d92ef8ac8f3e89bea578f1899788a8cae01e2298385a7a3c02` |

## Decisions (Ben, Nov 6 11:20, all A)
1. Card URLs on the 6 rows.
2. Schlosskeller Wirtshaus row 35543 (closed venue `ve_d3fd2ae165`): no URL now. It goes to the archive URL item. Card 404. Wayback: 0 captures of the `/us/en/` card (all time) and 0 in 8 locales from Mar 2026. The 2026 Bib article does not name it. The only naming article is Jun 2, 2025.
3. Earl (Christchurch) goes to the hold register.
4. No name or price change. Rename batch: paz to card "PAZ", Moss Restaurant to card "Moss". Price item: Atelier and Muttonbird have no price (card `$$` each).
5. **Thailand is the next group, before Nov 10:** card URLs on the 178 rows labelled 2026, after a full card read. This replaces Nov 5 decision 2 ("no URL now, archive later").
6. **Malaysia:** no write in group D. The 66 rows labelled 2026 stay on the archive URL item (cards show 2027).

## Card label read (Nov 6, `/us/en/`, Chrome connector, in-page fetch)
Population: list pages of each selection, by tier (Three / Two / One / Bib), and a sample of card pages. Label = the year in the meta description `in the (\d{4}) MICHELIN Guide`.

| Selection | Site list | DB rows labelled 2026, by tier | Cards read | Label |
|---|---|---|---|---|
| iceland | 0 / 0 / 3 / 0 | 0 / 0 / 3 / 0 | 3 | 2026 |
| new-zealand | 0 / 1 / 14 / 35 | 0 / 1 / 14 / 34 (+2 special) | 7 | 2026 |
| austria | 2 / 19 / 78 / 60 | 161 rows, 2 closed | 11 | 2026 |
| finland | 0 / 2 / 6 / 3 | 0 / 2 / 6 / 3 | 8 | 2026 |
| lithuania | 0 / 0 / 4 / 8 | 0 / 0 / 5 / 8 (+2 special) | 6 | 2026 |
| norway | 2 / 2 / 17 / 3 | 2 / 2 / 19 / 3 | 10 | 2026 |
| sweden | 1 / 4 / 18 / 14 | 1 / 4 / 18 / 15 | 10 | 2026 |
| denmark | 3 / 7 / 32 / 27 (PAZ in Two Stars) | 3 / 6 / 32 / 27 (+1 other); PAZ is FO in DB | 12 | 2026 |
| vietnam | 0 / 0 / 11 / 70 | 0 / 0 / 11 / 71 (+5 other) | 6 | 2026 |
| malaysia | 0 / 1 / 9 / 60 | 2027 rows 70; 2026 rows 66 | 7 | **2027** |
| thailand | 2 / 8 / 33 / 137 | 2 / 8 / 33 / 137 | 68 of 180 | 2026 |
| faroe-islands | empty (all 4 tiers) | – | – | – |

Differences to test in each group (site vs DB): LT One Star +1 in DB, NO One Star +2, SE Bib +1, VN Bib +1, NZ Bib -1 (Earl). These are the likely cards that left the site or rows that hold an older edition.

## Group D: still open (re-read first)
Population: Michelin rows labelled 2026 with no URL, read Nov 6 before D1.

| Order | Country | Rows | Note |
|---|---|---|---|
| 1 | **Thailand** | 178 | Next. Before Nov 10 (stars change then). See below |
| 2 | Finland | 10 | Smallest first after Thailand |
| 3 | Lithuania | 10 | DB has 5 One Stars, site 4 |
| 4 | Norway | 22 | DB One Star +2 |
| 5 | Sweden | 34 | DB Bib +1 |
| 6 | Denmark | 56 | |
| 7 | Vietnam | 66 | DB Bib +1 |
| – | Malaysia | 66 | Archive URL item (Ben 6A) |
| – | Austria | 1 | 35543, archive URL item (Ben 2A) |

2025 rows with no URL stay out of group D: DK 57, SE 34, NO 22, FI 11, LT 11, IS 3, FO 1, VN 68.

**Thailand plan.**
- Reuse `docs/michelin-2026-thailand-2026-11-05/pairs.tsv` (178 pairs, all to a card with the same category and city). 2 rows already have a card URL: 35538 Aksorn, 35539 Krua Apsorn (Dusit).
- Read all 180 cards first. On Nov 6 the site gave an empty answer (status 202, length 0) after 68 card fetches at a 0.9 s pause. All 68 said 2026 (Three 2, Two 8, One 33, Bib 25). Use a pause of 3 s or more, in blocks of about 40, and test 1 card before each block. If 202 comes back, stop and wait before a retry.
- Model: `docs/michelin-e-2026-11-06/build_sql.py` or `docs/michelin-d1-2026-11-06/build_sql.py` (URL only). Year stays 2026.
- The 178 card URLs will repeat on the Thailand 2027 rows. The `url in use` gate of the 2027 file must allow them (as for Austria and the 2 Thailand rows).
- Thailand 2027: Bib list of 151 out Nov 3, stars Nov 10. On Nov 6 the site list still showed 137 Bibs and the Bib cards still said 2026.

## Hold register (new, no rows)
- **Earl**, Christchurch, New Zealand: Bib Gourmand on the site list, card `https://guide.michelin.com/us/en/south-island/christchurch_2307083/restaurant/earl`, label "2026 MICHELIN Guide New Zealand". No venue, no row. Not read: status, the New Zealand 2026 article for Earl.
- All entries of the A2-E handoff stay.

## Weak points
- Card labels after D1 are from a sample, not all cards.
- Thailand: 112 of 180 cards not read.
- Wayback 0 captures for Schlosskeller is not proof that no capture exists.
- The SQL text sent to the Write connector was copied from the file printout, not hashed against the file.
- List pages were read by in-page `fetch()` + `DOMParser`, not the rendered DOM. Banner totals matched card counts on every list.

## Open items, in order
1. **Group D Thailand (next, new chat, before Nov 10).** Then Finland, Lithuania, Norway, Sweden, Denmark, Vietnam.
2. **Gault & Millau France and Monaco 2027 (after Nov 9). Thailand 2027 (after Nov 10).** Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. Price item adds Atelier and Muttonbird.
3. Status read of the 45 Top 500 venues.
4. Rechecks: as in the A2-E handoff.
5. Same-name pairs: as before.
6. Rename batch: as in the A2-E handoff, plus paz to PAZ, Moss Restaurant to Moss.
7. Archive URLs: as before, plus Schlosskeller Wirtshaus 35543 and Malaysia 66 rows labelled 2026.
8. Phase 2 publish job (goal Nov 29), Phase 3 location pass, history backfill: as before.
9. Plan v1.31: add D1 (ledger 366-367, audit 134,659-134,664), Ben's 5A (Thailand reversal of Nov 5 decision 2) and 6A.
10. Research result (after Nov 7): see the radar handoff.

## Methods (new)
- **Selection slugs:** `faroe-islands` (empty list; PAZ sits in `denmark`, card guide "Denmark"), `iceland`, `new-zealand`, `austria`, `finland`, `lithuania`, `norway`, `sweden`, `denmark`, `vietnam`, `malaysia`, `thailand`. Faroe slug from Michelin's own map in the page HTML (`"fo":{"cname":"faroe-islands"}`).
- **List read:** in-page `fetch('/us/en/selection/<slug>/restaurants/<tier>[/page/N]')`, `DOMParser`, cards inside `.row.restaurant__list-row.js-restaurant__list_items`, stop when the card count reaches the `h1` total. 1.5 s pause. 48 lists read with no refusal.
- **Relay save:** text from `get_page_text` arrives decoded (UTF-8). Re-escape non-ASCII to `\uXXXX` by script before the hash; then the sha256 equals the browser.
- **Fujian check:** card `/us/en/fujian-province/fuzhou_1026814/restaurant/jing-li`, read the label. Nov 6 10:52 and 11:21 ET: "2026 MICHELIN Guide Fuzhou" (not out).

## Dead ends: do not retry
- Card fetches at a 0.9 s pause past about 68 cards: status 202 with an empty body.
- `slugs.canonical` (column is `is_canonical`). `addresses.formatted` (columns: `raw`, `street`, `postal_code`, `locality`, ...).
- Wayback CDX for `schlosskeller-wirtshaus` in us/en, at/en, at/de, en, de/de, de/en, hu/en, it/it: 0.
- All dead ends of the A2-E handoff stay.

**Repo:** branch `oad-2026-read-block` holds `docs/michelin-d1-2026-11-06/` and this handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt: group D Thailand
```
Read claude/handoff-michelin-d1-done-2026-11-06.md from the project files, then
claude/handoff-michelin-a2-a3-b-e-done-2026-11-06.md for methods, the hold register and dead ends,
claude/handoff-michelin-2026-thailand-done-2026-11-05.md for the Thailand pairs and decisions,
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 367, audit_log 134,664, venues 11,831 (active 11,512, closed 319), awards 29,052,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,512. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Before each group, read again whether Fujian 2027 is out. If it is, tell me and ask where it goes in the order.
Do group D Thailand: card URLs on the 178 rows labelled 2026 (my choice 5A of Nov 6). Check first that the Thailand cards still say 2026. Read all 180 cards slowly (3 s or more between cards, in blocks); the site refused fast reads on Nov 6.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
After Thailand, continue group D smallest first: Finland, Lithuania, Norway, Sweden, Denmark, Vietnam, one at a time with the same steps.
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
