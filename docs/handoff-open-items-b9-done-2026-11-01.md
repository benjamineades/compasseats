# Handoff: Open items block 9 done (Best Chef held rows + 8 venue names + Guy Savoy). Nov 1, 2026 (08:52 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b8-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the city-move method: `handoff-open-items-b1-done-2026-10-30.md`.
Michelin city rule (D7): `handoff-open-items-b2-done-2026-10-30.md`. Working rules and database notes:
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 1 08:17 "1 & 2" (the 5 held Best Chef rows; the venue name checks). 08:28 "All recommendations".
- 08:34 "Go" (file 1; stopped at a post-check, nothing written). 08:37 "Go" (fixed file 1).
- 08:41 "Try the editor again" (built-in browser: not signed in to Supabase). 08:49 "try again in chrome" (file 2 run by Claude in
  the SQL Editor through Claude in Chrome).

## Decisions (all = recommendation)
- **3453** Flores Raras (Valencia) 2025 2-Knife: keep, URL = 2025 results page. Flores Raras = El Poblet renamed Jan 2026 (same
  address C/ Correus 8, same owner; Michelin card "formerly known as El Poblet"); Best Chef card Luis Valls "El Poblet (former workplace)".
- **15690** Ensue 2025 2-Knife: moved to **Fumée** `ve_38916224da` (the one Shenzhen 2-knife card = Reina Chen, Fumée; Ensue = 1 knife = 15691).
- **15727** 8½ Macau 2025 2-Knife: **held** for the Hong Kong/Macau block (see Open items 1).
- **16190** The Fellas (Shanghai) and **15997** Fo'ao Vaperse Hotel (Guangzhou): deleted with their venues (Sep 28 contamination rule;
  no Best Chef 2024/2025 card or special award names either; The Fellas is an Italian rooftop bar, Vaperse is a hotel).
- **8 names** (rules R1-R5):
  | Venue | Before | After | Rule | Canonical slug |
  |---|---|---|---|---|
  | ve_1727fb4901 | Le Calandrе (Cyrillic е) | Le Calandre | R1 | padua/le-calandre (reused) |
  | ve_98b2c2d46b | Bed & Breakfast - Les Belles Perdrix | Les Belles Perdrix de Troplong Mondot | R2 | saint-emilion/les-belles-perdrix-de-troplong-mondot (reused) |
  | ve_b60189d14c | Home Aribert - Restaurant Gastronomique 2 Étoiles Michelin | Maison Aribert | R1 | uriage-les-bains/maison-aribert (reused) |
  | ve_4e2b60de79 | KOKI - The House of Senses | Hibana by Koki | R5 | hanoi/hibana-by-koki |
  | ve_53b3c4e143 | EDGE for Men - V & A Waterfront | EDGE | R3 | cape-town/edge |
  | ve_ab0ec4c74c | Xiamen | XIA | R3 | xiamen/xia |
  | ve_2922f8b9e6 | The Palash Vann Resort | Palaash | R1 | maharashtra/palaash |
  | ve_83aca60857 | Hotel Cañitas Classic | Cañitas Maite | R4 | casas-ibanez/canitas-maite |
  Old canonical slugs stay as non-canonical (old URLs work). Hibana by Koki keeps the 101 Best Steakhouses row (Koki, parent restaurant).
- **Guy Savoy** (Paris) `ve_f026dbec1c`: added Best Chef 2024 2-Knife (30113) and 2025 2-Knife (30114), URL = results page of each edition.

## Live state (read Nov 1, 13:51:31 UTC, whole tables)
| Table | Count |
|---|---|
| venues | **11,300** (active **10,934**, closed 366) |
| awards | **23,363** |
| price | 7,731 |
| slugs | **12,948** (canonical 11,300, non-canonical **1,648**); venues with other than 1 canonical slug: 0 |
| listings | **11,300** |
| cities / city_aliases / redirects | 3,260 / 266 / 9 |
| city_label_source | **23,999** |
| rename_batches | **19** (last id **34**); rename_rows **1,209** |
| source_capture_ledger | **141** rows, last id **189** |
| audit_log | **115,490** rows, last id **120,802** |
| cities.venues_count | sum **10,934**; cities that differ from the view: 0 |
| best-chef-awards 2024/2025 without URL | **1** (15727) |

## Done in this session
1. Start check 13:18 UTC: all b8 counts matched. Clone `30f084e`.
2. Reads: Best Chef results pages 2024/2025 (text search incl. special awards), chef pages (Le Calandre, El Poblet, Fumée, 8½ HK,
   Palaash, Les Belles Perdrix, Hibana by Koki, Cañitas Maite Gastro, XIA, EDGE, Maison Aribert), Michelin cards (8½ HK Three Stars
   2026, 8½ Macau One Star 2026, Hibana by Koki, Xia, Les Belles Perdrix de Troplong Mondot, Maison Aribert, Le Calandre, Cañitas Maite
   Gastro), sites (alajmo.it, troplong-mondot.com/restaurant, maisonaribert.com, edgerestaurant.africa, wildlifeluxuries.com,
   hotelcanitasmaite.com, lohkahhotel.com), valenciasecreta.com (Flores Raras), therooftopguide.com (The Fellas), Michelin hotel page
   (Vaperse), worldbeststeaks.com (Koki). Not read: capellahotels.com (client error). A Pearl page was fetched by mistake; not used.
3. Build `docs/open-items-b9-build/build_open_items_b9_2026_11_01.py` (relays `relay-file1.txt` sha256 `b73aa3c9…b656`,
   `relay-file2.txt` `2666136e…abd2`; live names md5 `0f9c5a1c…2082`). pglast OK; dry runs passed. Repo `f37a3b5`.
4. **File 1, first run** (Write connector, 13:35 UTC): stopped at post-check `slugs after` (build said non-canonical +8; correct is
   +5 = 8 old canonical out, 3 reused slugs in). Rolled back, nothing written, but ids were used up: ledger 181-184, audit 120,733-120,760.
   Fix: expected 1,648, ledger ids 185-188, new gate on `pg_sequences.last_value` (ledger, audit) in both files. Repo `014de01`.
5. **File 1** (Write connector, 13:39 UTC): rename batch **34** applied (8 rows), slugs 8 UPDATE + 3 reuse + 5 INSERT, awards 3453 URL,
   15690 -> Fumée + URL, 30113/30114 added. Ledger **185** (michelin, name, 4), **186** (best-chef-awards, name, 4), **187**
   (best-chef-awards, award, 2, `pair-fix:`), **188** (best-chef-awards, award, 2, `award-add:`). Audit **120,761-120,788** (28).
6. **File 2** (SQL Editor via Claude in Chrome, 13:51 UTC): file fetched in the page from
   `raw.githubusercontent.com/benjamineades/compasseats/0260629…/docs/cleanup-best-chef-b9-2026-11-01.sql`, sha256 checked in the page,
   set into the editor (Monaco `setValue`), editor content checked again, Run, "Run query" on the destructive-operation warning.
   Result "Success. No rows returned". Ledger **189** (best-chef-awards, award, 2, `cleanup:`). Audit **120,789-120,802** (14:
   city_label_source DELETE 4 (hand), awards 2, slugs 2, listings 2, venues 2 DELETE, cities UPDATE 2). Shanghai 112 -> 111,
   Guangzhou 74 -> 73. Read-back matched every planned value.

## Methods that worked (new)
- **SQL Editor run by Claude (Claude in Chrome, Ben's own sign-in):** project `compass-canonical` = `uucnuktwqrxcgbudgmzf` (org
  compass-network); open `/dashboard/project/uucnuktwqrxcgbudgmzf/sql/new`; fetch the file from the public repo at a fixed commit,
  check sha256 in the page, `monaco.editor.getModels()[0].setValue(text)`, check the editor sha256 (return true/false: the tool hides
  hash text), click Run, confirm "Run query". Read back from the Read connector (the first read can come before the run ends).
  The built-in browser pane is not signed in to Supabase.
- **Rolled-back writes use ids:** a run that fails after an INSERT still moves identity counters. Gate on
  `pg_sequences.last_value` and set expected ledger ids from it.
- **Slug reuse count:** non-canonical change = (old canonical rows) − (reused rows).

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/rename-urls-open-items-b9-2026-11-01.sql` (170 lines) | Run (ledger 185-188, audit 120,761-120,788) | `c83817aa177d84d3029120e4041570253e84ffa9b563466e3b03e5fee482ca8b` |
| `docs/cleanup-best-chef-b9-2026-11-01.sql` (92 lines) | Run in SQL Editor (ledger 189, audit 120,789-120,802) | `a83095e9e6d7a1aa61c73e823a0ac07ad01ac5480feef52b8dabe4c2bb1bfb56` |
| `docs/open-items-b9-build/` (build script, 2 relays, file 2 test copy) | Build | - |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. **8½ Otto e Mezzo pair (do with item 6):** `ve_e17d78f314` Hong Kong is `closed` but its card shows Three Stars 2026 (Alexandra
   House); its slugs are `hong-kong/hong-kong-3bt2d8`, `hong-kong-uc7ud0` (name lost). `ve_6f0b34cc23` Macau (One Star 2026, Galaxy)
   holds Hong Kong awards too (Michelin 2025 Three Stars 15736 next to One Star 6238; Asia's 50 Best 2019-2025; OAD 2025; Asia's 50
   Best Bars 2021 #65 = a bar) and the held Best Chef row 15727; slugs `macau/macau-uc7ud0`, `macau-3bt2d8`. Untangle by publisher.
2. City checks: Le Calandre city Padua, card Rubano (D7); Palaash city "maharashtra" is a state (site: Tipai, near Tipeshwar, Yavatmal).
3. Best Chef entries with no venue: Credo (Trondheim, 2024; our Credo is in Oslo per its Michelin card), Scilla (Shanghai, 2025);
   102 House and Rêver are closed. Ensue holds 2 Asia's 50 Best 2026 rows (#65, #79).
4. 2025 Green Star backfill, all guides (Michelin Green Star rows: 2024 = 2, 2025 = 4, 2026 = 125). Ben decides how far back.
5. Legacy price rows outside Turkey: 2,558 (scope when Ben asks).
6. 2025 Michelin URLs, all guides (3,461 of 3,470 rows without a URL).
7. Hong Kong / Macau Michelin 2026 edition not loaded (HK 1 row 2026 vs 145 in 2025; Macau 0 vs 35). Large block: new chat.
8. Watch: other Beverly Hills venues if a Michelin card puts one in Beverly Hills.
9. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12; Fujian 2027 late
   Nov; Spain 2027 Dec 1 (also Terra Fisterra); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
   Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found; Turkey 2027.
10. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.

Closed in this block: 4 of the 5 held Best Chef rows; the 8 venue names; Guy Savoy Best Chef rows; Fumée 2-Knife.

## Suggested opening prompt
```
Read claude/handoff-open-items-b9-done-2026-11-01.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 189,
audit_log 120,802, venues 11,300, closed venues 366, cities 3,260, slugs 12,948 and cities.venues_count sum 10,934. Then show me
the next-block options in /ste style (the open items, smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
