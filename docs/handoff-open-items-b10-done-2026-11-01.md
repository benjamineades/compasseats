# Handoff: Open items block 10 done (8½ Otto e Mezzo pair untangled) + Hong Kong / Macau 2026 load scoped and briefed. Nov 1, 2026 (09:40 Atlanta). Next: Ben runs the Cowork brief, or chooses another item.

This file replaces `handoff-open-items-b9-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the city-move method: `handoff-open-items-b1-done-2026-10-30.md`.
Michelin city rule (D7): `handoff-open-items-b2-done-2026-10-30.md`. Working rules and database notes:
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 1 09:00: open items 1 and 7 as one block; read cards and lists first; no write before go.
- 09:12 "All recommendations are ok for D1-D5. Chrome ok."
  D1 = A (Hong Kong closed -> active), D2 = A (both named "8 1/2 Otto e Mezzo Bombana"), D3 = A (new canonical slugs, Shanghai
  branch slug not in this block), D4 = A (awards split by publisher), D5 = A (Michelin 2026 rows for both venues come with the load).
- 09:29 "Go for both" (file 1 and file 2).

## Live state (read Nov 1, 14:32:36 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,300 (active **10,935**, closed **365**) |
| awards | **23,362** |
| price | 7,731 |
| slugs | **12,950** (canonical 11,300, non-canonical **1,650**); venues with other than 1 canonical slug: 0 |
| listings | 11,300 |
| cities / city_aliases / redirects | 3,260 / 266 / 9 |
| city_label_source | 23,999 |
| rename_batches | **20** (last id **35**); rename_rows **1,211** |
| source_capture_ledger | **148** rows, last id **196** |
| audit_log | **115,509** rows, last id **120,821** |
| cities.venues_count | sum **10,935**; cities that differ from the view: 0 |
| best-chef-awards 2024/2025 without URL | **0** |

## Done in this session
1. Start check 14:00 UTC: all b9 counts matched. Repo attached with push access, clone `e145b9f`.
2. Reads (WebFetch): Michelin cards 8½ Hong Kong (Three Stars 2026, Shop 202 2F Alexandra House) and Macau (One Star 2026, Galaxy
   Cotai), both h1 "8 1/2 Otto e Mezzo - Bombana"; Michelin HK&Macau 2026 ceremony article, 2026 full list, 2026 Bib article,
   2025 ceremony article; ottoemezzobombana.com (title "8 1/2 Otto E Mezzo Bombana", body "8½ Otto e Mezzo BOMBANA"; branches
   Hong Kong, Macau, Shanghai); Best Chef card Umberto Bombana (Hong Kong, two knives); Asia's 50 Best 2019, 2021, 2022,
   2023 51-100, 2025 51-100 (all Hong Kong); Asia's 50 Best Bars 2021 51-100 (No. 65 = 8½ Hong Kong); The 50 Discovery page;
   La Liste Macau page (85.5, 2026); Galaxy Macau Forbes 2026 page (8½ Macau Five-Star, fourth consecutive year).
3. Reads (Claude in Chrome): La Liste Hong Kong page `laliste.com/places/8-12-otto-e-mezzo-bombana-hongkong-cn` (95.0, Top 1000
   2026; found with the site search `laliste.com/search?q=...`); OAD Top Restaurants in Asia 2025
   `oadguides.com/lists/asia/top-restaurants/2025` (No. 91 = 8½ Hong Kong; No. 79 = Lai Ching Heen, Hong Kong; No. 261 Zuicho,
   Hong Kong; No. 352 Lai Heen, Hong Kong). opinionatedaboutdining.com redirects to oadguides.com.
4. Build `docs/open-items-b10-build/build_open_items_b10_2026_11_01.py` (relays `relay-file1.txt` sha256 `d401d826…0940`,
   `relay-file2.txt` `8ef2dd54…4a83`; live pair md5 `20b7894d…587f`, award md5 `93282d40…ce65`). pglast OK. File 1 dry run
   passed (stopped at the first UPDATE). File 2 test: the Read connector gave "Bad Gateway" on every call for a short time
   (also on a one-line count); no id used; not retried after the outage. Repo `b1f9ef0` (built, not run).
5. **File 1** (Write connector, 14:30 UTC, first try): Hong Kong `ve_e17d78f314` closed -> active, cities hong-kong 261 -> 262;
   rename batch **35** `rename-open-items-b10-2026-11-01` (2 rows); slugs 2 UPDATE + 2 INSERT; awards 10 moved with URL.
   Ledger **190** (michelin, name, 2), **191** (asia-50-best-restaurants, award, 5), **192** (asia-50-best-bars, award, 1),
   **193** (best-chef-awards, award, 1), **194** (oad, award, 1), **195** (la-liste, award, 2). Audit **120,803-120,820** (18:
   venues UPDATE 3, cities UPDATE 1, slugs UPDATE 2, slugs INSERT 2, awards UPDATE 10). Read-back matched.
6. **File 2** (SQL Editor via Claude in Chrome, 14:32 UTC): file fetched in the page from
   `raw.githubusercontent.com/benjamineades/compasseats/b1f9ef0…/docs/cleanup-8-otto-e-mezzo-b10-2026-11-01.sql`, sha256 checked
   in the page and again in the editor, Run, "Run query" on the destructive-operation warning. "Success. No rows returned".
   Ledger **196** (michelin, award, 1, `cleanup:`). Audit **120,821** (awards DELETE 15736). Read-back matched.
7. Item 7 brief written: `docs/cowork-michelin-2026-hong-kong-macau.md` (Taiwan model; Pass 1 English, Pass 2 Traditional Chinese).

## Results: the 8½ pair
| Venue | Before | After |
|---|---|---|
| ve_e17d78f314 (Hong Kong) | "8 1/2 Otto E Mezzo Bombana", closed, slug hong-kong/hong-kong-3bt2d8, 3 awards | "8 1/2 Otto e Mezzo Bombana", active, slug **hong-kong/8-1-2-otto-e-mezzo-bombana**, **11** awards |
| ve_6f0b34cc23 (Macau) | "8½ Otto e Mezzo BOMBANA", slug macau/macau-uc7ud0, 15 awards | "8 1/2 Otto e Mezzo Bombana", slug **macau/8-1-2-otto-e-mezzo-bombana**, **6** awards |

- To Hong Kong (URL added): 15727 Best Chef 2025 2-Knife; 15728 OAD 2025 No. 91; 15729 Asia's 50 Best Bars 2021 No. 65;
  15730-15734 Asia's 50 Best Restaurants 2019 No. 12, 2021 No. 33, 2022 No. 48, 2023 No. 70, 2025 No. 94; 15735 La Liste 2026 95/100.
- To Macau (URL added): 20742 La Liste 2026 85.5/100.
- Deleted: 15736 Michelin 2025 Three Stars on Macau (copy of 391; 2025 article: Hong Kong only).
- Stay on Macau: Forbes 6234-6237 (2023-2026 Five-Star), Michelin 6238 (2025 One Star). Stay on Hong Kong: 391, 392.
- Old hash slugs (and the cross slugs hong-kong/hong-kong-uc7ud0, macau/macau-3bt2d8) stay non-canonical: old URLs work.
- The Shanghai branch `ve_524cd4f57d` already had the name "8 1/2 Otto e Mezzo Bombana"; its slug is still `shanghai/shanghai-ugqvxy`.

## Hong Kong / Macau 2026 scope (item 7)
- 18th edition: Bib article Mar 12, 2026; ceremony and full list Mar 19, 2026.
- Published: Hong Kong 7 / 13 / 57 / 70 Bib = 147; Macau 2 / 6 / 13 / 13 Bib = 34; Selected 72 + 25. 2025 article: Hong Kong
  7 / 11 / 58, Macau 2 / 6 / 11.
- Our legacy Michelin rows (labelled 2025, 0 with URL) now: Hong Kong 7 / 13 / 56 / 69 = 145; Macau 2 / 6 / 13 / 13 = 34.
  **They match 2026 better than 2025** (Hong Kong 2 Stars 13 incl. Cristal Room, a 2026 promotion; Sushi Takeshi, a 2026
  newcomer, holds a One Star row; Ho Ho Chak, a 2026 new Bib, holds a Bib row; Macau One Star 13). Probably a label problem,
  as in Germany. Ben decides the label method after the Cowork output.
- Full list article: Macau One Star heading 13, 11 names. The 8½ Macau card (One Star 2026) is probably one of the 2.
- Register for the load: Hong Kong "Lai Heen" `ve_d970e6b8ab` holds Michelin 2025 Two Stars 18227, OAD 2025 No. 79 and No. 352,
  La Liste 92.5. OAD No. 79 = Lai Ching Heen (Hong Kong). The 2026 list has Lai Heen only in Macau. Likely contamination.
  Same-name pairs: Zuicho (Hong Kong `ve_39b34a092b` closed, OAD 2025 No. 261 "Hong Kong"; Macau `ve_a5fe7b9138` One Star),
  Mesa (2 Macau venues `ve_a2a7ed787d`, `ve_6f0bd256a0`), Lobster Bar and Grill (2 Hong Kong venues, no Michelin).
  Tin Lung Heen is in the database as "Tin Lung Heen | The Ritz-Carlton, Hong Kong" (Two Stars). 12 names hold CJK characters.
  City "Sheung Wan" (country China) holds 1 venue, ALWAYS JOY (La Liste only).

## Methods that worked (new)
- **La Liste place page:** the site search `https://www.laliste.com/search?q=<words>` lists `/places/<slug>` links; read the place
  page text in Chrome (`innerText`, the score line "LA LISTE 95.0 Top 1000 Restaurants 2026"). Guessed slugs gave 404.
- **OAD lists:** `https://www.oadguides.com/lists/<region>/top-restaurants/<year>`, read `document.body.innerText` lines in Chrome.
- **Tool output filter:** a javascript_tool call whose code text contains `?q=` can come back "[BLOCKED: Cookie/query string data]".
  Navigate the tab to the URL instead and read the DOM.
- **Read connector outage:** "Bad Gateway" on every call for a few minutes; it came back without change. Check ledger and audit
  max id after a failed call before any retry.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/pair-8-otto-e-mezzo-b10-2026-11-01.sql` (178 lines) | Run (ledger 190-195, audit 120,803-120,820) | `ddf6f5cd3c1cff2fbcbca2deb15c8cfc4dfd57fd995ef199b4db60b39066b6af` |
| `docs/cleanup-8-otto-e-mezzo-b10-2026-11-01.sql` (52 lines) | Run in SQL Editor (ledger 196, audit 120,821) | `3b2c5c2863ba2a8a41859ac668216507b8bdcbec38bbf6ce1b64c197295d68c8` |
| `docs/open-items-b10-build/` (build script, 2 relays, 2 test copies) | Build | - |
| `docs/cowork-michelin-2026-hong-kong-macau.md` | Brief for Cowork (item 7) | - |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. **Hong Kong / Macau Michelin 2026 load (item 7):** run `docs/cowork-michelin-2026-hong-kong-macau.md` in a new Cowork session
   (Fable or Opus). Bring the CSV and log to a new chat. Then: match test, label decision for the 179 legacy rows, promote,
   cleanup (Germany method), the Lai Heen / Zuicho / Mesa register, Michelin 2026 rows for both 8½ venues.
2. City checks: Le Calandre city Padua, card Rubano (D7); Palaash city "maharashtra" is a state (site: Tipai, near Tipeshwar, Yavatmal).
3. Best Chef entries with no venue: Credo (Trondheim, 2024; our Credo is in Oslo per its Michelin card), Scilla (Shanghai, 2025);
   102 House and Rêver are closed. Ensue holds 2 Asia's 50 Best 2026 rows (#65, #79).
4. Hash slugs with no name (digit-leading names): Shanghai 8½ `ve_524cd4f57d` (shanghai/shanghai-ugqvxy), 100/200 Kitchen
   (hamburg/hamburg-vmcxeo), 80/20 Eighty Twenty (bangkok/bangkok-cy1bxm). Small slug batch when Ben asks.
5. 2025 Green Star backfill, all guides (Michelin Green Star rows: 2024 = 2, 2025 = 4, 2026 = 125). Ben decides how far back.
6. Legacy price rows outside Turkey: 2,558 (scope when Ben asks).
7. 2025 Michelin URLs, all guides (3,461 of 3,470 rows without a URL; Hong Kong / Macau ones go with item 1).
8. Watch: other Beverly Hills venues if a Michelin card puts one in Beverly Hills.
9. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12; Fujian 2027 late
   Nov; Spain 2027 Dec 1 (also Terra Fisterra); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
   Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found; Turkey 2027;
   Hong Kong & Macau 2027 (expect March 2027).
10. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.

Closed in this block: open item 1 of b9 (8½ pair), the last held Best Chef row (15727).

## Suggested opening prompt (after the Cowork run)
```
Read claude/handoff-open-items-b10-done-2026-11-01.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b2-done-2026-10-30.md for the Michelin city rule D7, docs/handoff-germany-promoted-2026-10-08.md
and docs/handoff-taiwan-promoted-2026-10-11.md for the promote method, and claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md
for working rules. Do a fresh count read and confirm ledger 196, audit_log 120,821, venues 11,300, closed 365, awards 23,362,
slugs 12,950 and cities.venues_count sum 10,935. I attach michelin-2026-hong-kong-macau.csv and its log from Cowork. Check the
files, run the match test against our Hong Kong and Macau venues, and show me in /ste style the label question for the legacy
rows and every decision the files raise. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
