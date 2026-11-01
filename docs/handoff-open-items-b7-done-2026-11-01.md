# Handoff: Open items block 7 done (La Table merge, 4 venues reopened, 7 special-award sources, Miura -> Beverly Hills). Nov 1, 2026 (00:45 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b6-done-2026-10-31.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the city-move method: `handoff-open-items-b1-done-2026-10-30.md`.
Michelin city rule (D7 = the city in the card URL): `handoff-open-items-b2-done-2026-10-30.md`, block 5 (D3) and this block (E4).
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Oct 31 02:17: fresh count read, next-block options. 02:19 "Let's do item 1" (merge and award cleanup, 4 parts).
- Oct 31 03:42 "All A" (E1-E4 = A). 04:03 "1. go" (file 1) and "3. A1" (E4, after the alias finding).
- Nov 1 00:42 "ran it" (file 2, SQL Editor).

## Decisions
- **E1 = A** merge `ve_3e461fe576` "La Table de Christophe Hay et Loïs Bée" into `ve_dd6de25c33` "La Table - Christophe Hay" (Ardon).
  Evidence: same town and site (latabledacote.fr -> latable-orleans.com, title "Restaurant La Table - Christophe Hay à Orléans",
  200 allée des 4 vents, Ardon); Michelin card la-table-christophe-hay (One Star 2026); the fr card for the long name gives an
  error. Survivor name unchanged (R2: the card form is in the site title). Note: the site says "Loïs Bée" only in URL slugs.
- **E2 = A** status closed -> active: La Galinette (Perpignan), La Tana Gourmet (Asiago), Rolland (Plourhan), Ursus (Tignes).
  All 4 were set closed by the Aug 14 sheet load with no closure evidence; each live card (read Oct 31) shows the 2026 edition,
  opening hours and no closure note.
- **E3 = A** the 7 Oct 29 "unproven" legacy special-award rows get a source. Florida (5): Michelin press release Jun 1, 2026 on
  visitfloridamedia.com (no guide.michelin.com page names the Florida winners: 3 articles and 3 cards checked). Vietnam (2): Michelin
  full-list article Jun 6, 2026. Person on 2 rows: 21154 The Daytrader = Rhianda Smith; 21155 Kinjo = Jada Vidal.
- **E4 = A1** Miura -> new city **Beverly Hills** (D7: card URL and address "218 N. Rodeo Dr., Beverly Hills, CA 90210").
  The alias `beverly hills` moved from Los Angeles to Beverly Hills, so a label "Beverly Hills" resolves to 1 city
  (`scripts/ingest/lib/resolve.ts` matches display + alias; with the old alias it would give 2 candidates).
  **Not moved:** 9 other venues with an OAD / Wine Spectator "Beverly Hills" neighborhood label stay in Los Angeles: Spago,
  E Baldi, IMA, Marea Beverly Hills, Matu, Polo Lounge, Wally's Beverly Hills, Wolfgang Puck at Hotel Bel-Air (Bel Air), Nusr-Et (closed).
  A later Michelin card in Beverly Hills for one of them gets the same move.

## Live state (read Nov 1, 04:43:30 UTC, whole tables)
| Table | Count |
|---|---|
| venues | **11,302** (active **10,936**, closed **366**) |
| awards | 23,363 |
| price | 7,731 (legacy_guide 2,558) |
| slugs | **12,945** (canonical 11,302, non-canonical **1,643**); venues with other than 1 canonical slug: 0 |
| listings | **11,302** |
| cities / city_aliases / redirects | **3,260** / 266 / 9 |
| city_label_source | 24,003 |
| rename_batches | 18 (last id 32); rename_rows 1,201 |
| source_capture_ledger | **134** rows, last id **178** |
| audit_log | **114,154** rows, last id **119,438** |
| cities.venues_count | sum **10,936**; cities that differ from the view: **0** |

## Done in this session
1. Start check Oct 31 06:17 UTC: all b6 counts matched. Repo attached with push access.
2. Reads (WebFetch): cards La Table - Christophe Hay, La Galinette, La Tana Gourmet, Rolland, Ursus, Miura, Kinjo, Daytrader, Fat Beet;
   Florida Green Star list (us/en, gb/en); Michelin Florida and Vietnam 2026 articles; Fox 13; visitfloridamedia.com release;
   latable-orleans.com. Not read: michelinmedia.com (robots), fr card of the long La Table name (error), vn Green Star list (error).
3. Fresh read Oct 31 07:43 UTC; build by script from `relay.txt` (4 md5 checks of the relay against live rows). pglast OK.
   File 1 dry run and file 2 / file 3 pre-check tests stopped at the first write. Repo `d275b29` (files 1-2 built), `f94eae6` (file 3).
4. **File 1** (Write connector, first try, Oct 31 08:04 UTC): 4 venues reopened, 4 city counts +1, 7 award rows source_url (+2 person),
   ledger **176** (michelin, award, 7). Audit **119,410-119,424** (venues UPDATE 4, cities UPDATE 4, awards UPDATE 7).
5. **File 2** (Ben, SQL Editor, before Nov 1 04:42 UTC): awards 21261 + 29699 moved, old slug non-canonical on the survivor,
   2 gault-millau city labels moved (hand audit), listing + venue `ve_3e461fe576` deleted, Ardon count 2 -> 1. Ledger **177**
   (michelin, award, 1), **178** (gault-millau, award, 1). Audit **119,425-119,432**.
6. **File 3** (Write connector, first try, Nov 1 04:43 UTC): city **Beverly Hills `ci_a7d1756bcb`** inserted (copied from Los Angeles,
   lat/lng NULL, count 1); Miura moved; `los-angeles/miura` non-canonical, `beverly-hills/miura` canonical; Los Angeles count
   115 -> 114; alias `beverly hills` -> Beverly Hills (hand audit). No ledger row. Audit **119,433-119,438**.

## Results
- La Table - Christophe Hay `ve_dd6de25c33`: awards 21261 Gault-Millau 2026 Three Toques · Grand de Demain, 22311 Michelin One Star,
  29699 Green Star, 29936 Mindful Voices; slugs `ardon/la-table-christophe-hay` (canonical), `ardon/la-table-de-christophe-hay-et-lois-bee`; 4 city labels.
- Miura `ve_ca50fd9f2e`: Beverly Hills; slugs `beverly-hills/miura` (canonical), `los-angeles/miura`, `los-angeles/miura-hotel`.

## Methods that worked (new)
- **Merge with a city-label move:** UPDATE `city_label_source.venue_id` with a hand audit row (old_row, new_row) before the update
  (no trigger on that table), in place of a DELETE.
- **Alias that would clash with a new city:** move the alias to the new city (UPDATE + hand audit row), and gate after on
  "display route + alias route give 1 city".
- **Reopen + stored count:** status UPDATE and `cities.venues_count` +1 in one file; gate 0 cities differ from the view.
- Write connector ran both INSERT/UPDATE files on the first try; the DELETE file went to the SQL Editor (Ben).

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/reopen-urls-open-items-b7-2026-10-31.sql` (102 lines) | Run (audit 119,410-119,424) | `d472af0a99aceed0b3665176fe3d6a0e5d3c589e9fbe396ca2089cf054eab9b8` |
| `docs/merge-la-table-christophe-hay-2026-10-31.sql` (138 lines) | Run in SQL Editor (audit 119,425-119,432) | `91d0bdf0c6f6a4e8fde8d63c6cbf1ec6f8e853106d78835fc8ee59d1cd2d3a90` |
| `docs/cities-beverly-hills-miura-2026-10-31.sql` (125 lines) | Run (audit 119,433-119,438) | `bfe7b193320cc6d89a1f6ffae88a376590bccdf250688e96187db0059aaccd0f` |
| `docs/open-items-b7-build/relay.txt` (17 lines, no final newline) | Input (files 1-2) | `f628738a612afc4567ecc103dcef6c780d79465eab800f36690c4f824ad30a52` |
| `docs/open-items-b7-build/build_open_items_b7_2026_10_31.py` | Build (files 1-2; `test` arg = pre-check copy) | `0463d4cf47bb9bddc716819b4a8804e5015e42dc17931b1406b091fd23429ffa` |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. **Hong Kong Michelin 2026 edition not loaded.** Hong Kong has 0 michelin 2026 rows (Duddell's 30110 added by hand) and 145 michelin
   2025 rows. Also check Macau and the other cities of the guide. Large block: start in a new chat.
2. Best Chef source URLs: 2024 519 rows (1 with URL; the 2024 list PDF covers all); 2025 781 rows (0 with URL; the 2025 list was not
   readable). Also check that each 2024/2025 row pairs to a list entry.
3. 2025 Green Star backfill, all guides (California 2025: 13 of 17 missing). Ben decides how far back.
4. 2025 Michelin URLs, all guides (about 3,461 rows without a URL).
5. Legacy price rows outside Turkey: 2,558 (scope when Ben asks).
6. Watch: other Beverly Hills venues (above) if a Michelin card puts one in Beverly Hills.
7. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1 (also confirm Terra Fisterra is gone); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka /
   Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027
   dates not found; Turkey 2027 edition (check the unknown 2026 Bib then).
8. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.

Closed in this block: La Table merge; 5 new awards on closed venues (4 venues reopened); 7 unproven special-award rows; Miura / Beverly
Hills city policy; Florida 2026 Green Stars source (now found: the Jun 1 release).

## Suggested opening prompt
```
Read claude/handoff-open-items-b7-done-2026-11-01.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 178,
audit_log 119,438, venues 11,302, closed venues 366, cities 3,260, slugs 12,945 and cities.venues_count sum 10,936. Then show me
the next-block options in /ste style (the open items, smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
