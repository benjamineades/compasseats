# Handoff: Open items block 6 done (4 name differences, Duddell's, Terra, La Torre One Fire). Oct 31, 2026 (02:10 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b5-done-2026-10-31.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the city-move method: `handoff-open-items-b1-done-2026-10-30.md`.
Michelin city rule (D7 = the city in the card URL): `handoff-open-items-b2-done-2026-10-30.md` and block 5 (D3).
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 31, 2026, ET)
- 00:56: fresh count read, next-block options, repo with push access.
- 01:55 "What do you recommend?" -> item 1 + 2a + 2b. 01:56 "1, 2A, 2B".
- 02:01 "Your recommendation for everything": D1-D5 = A (see Decisions).
- 02:06 "Go" (all 3 files, Write connector, in order).

## Decisions (Ben, Oct 31 02:01 ET, all A)
- D1 Rename the 4 card name differences: Kresios -> **Krèsios** (R1), Paca Ristorante -> **Paca** (R2), Coxinendi - Ristorante ->
  **Coxinendi** (R5, site blocks robots), Restaurante Temático El Jardín de la Sal -> **El Jardín de la Sal** (R2 + R3).
- D2 Duddell's (Hong Kong): **not a duplicate, no merge.** `ve_a3512f9a51` = 3/F Main Dining Room (Michelin, OAD);
  `ve_f88a5d9dc2` = 4/F bar, renamed **The Upper Room at Duddell’s** (site "The Upper Room at Duddell’s" / "The Upper Room";
  Pinnacle "The Upper Room At Duddell's"; R2 + R3, curly apostrophe as the site writes it, R6).
- D3 Add the missing Duddell's Michelin 2026 One Star row with the live card URL.
- D4 Terra (Fisterra) `ve_89ca903ac2` -> **closed**. Evidence: terrafisterra.com notice "Este 27 de septiembre será nuestro último
  servicio" (no year); us/en card 404; Michelin Fisterra list shows no Terra; an old /en/ card copy still shows One Star. 2026 award
  row 25391 stays as history.
- D5 La Torre One Fire `ve_b5a5b44c26`: **no write, item closed.** The stored card URL opens again (Bib 2026, "Piazzetta Annunziata 7,
  Annunziata, 80061"); our city Annunziata agrees with D7. (80061 is Massa Lubrense; Michelin's URL region says "piemonte" in error.)

## Live state (read Oct 31, 06:09:17 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,303 (active **10,933**, closed **370**) |
| awards | **23,363** |
| price | 7,731 (legacy_guide 2,558) |
| slugs | **12,944** (canonical 11,303, non-canonical **1,641**); venues with other than 1 canonical slug: 0 |
| listings | 11,303 |
| cities / city_aliases / redirects | 3,259 / 266 / 9 |
| city_label_source | 24,003 |
| rename_batches | 18 (last id **32**); rename_rows **1,201** |
| source_capture_ledger | 131 rows, last id **175** |
| audit_log | **114,125** rows, last id **119,409** |
| cities.venues_count | sum **10,933**; cities that differ from the view: **0** |

## Done in this session
1. Start check 04:56 UTC: all b5 counts matched (ledger 172, audit 119,393, cities 3,259, aliases 266, slugs 12,940, venues_count
   sum 10,934, 0 differ). Repo attached with push access (clone `daed397`).
2. Reads (WebFetch, Oct 31 ~05:57-06:00 UTC): Michelin cards Krèsios, Paca, Coxinendi, El Jardín de la Sal, Duddell's, Terra (/us/en/
   404, /en/ copy), Fisterra list, La Torre One Fire; sites kresios.com, tenutaceri.it/ristorante-paca, salinasdefuencaliente.es,
   duddells.co (home and venue-interior-design), terrafisterra.com; Pinnacle Guide page. coxinendi.com: robots_disallowed.
3. Fresh read 06:01:40 UTC (md5 live id|name `80fe23d7e2d4b7f6c79ef49e6484611c`). Build by script from `relay.txt`. pglast OK (5 files).
   File 1 dry run stopped at the first INSERT; pre-check tests of files 2 and 3 (today's counts) stopped at the first write.
   Read after: no id used. Repo commit `acb4897` (built, not run).
4. **File 1** (Write connector, first try, 06:07:40 UTC): rename batch **32** `rename-open-items-b6-2026-10-31` applied, 5 rename_rows,
   ledger **173** (michelin, name, 4) and **174** (pinnacle-guide, name, 1), audit **119,394-119,398** (5 venues UPDATE).
5. **File 2** (Write connector, first try, ~06:08 UTC): 4 old canonical slugs -> non-canonical, 4 new canonical slugs inserted;
   audit **119,399-119,406** (4 UPDATE, 4 INSERT). No ledger row. Krèsios keeps `telese/kresios`.
6. **File 3** (Write connector, first try, ~06:09 UTC): award **30110** (Duddell's michelin 2026 One Star), ledger **175** (michelin,
   award, 1), Terra -> closed, Fisterra `venues_count` 1 -> 0. Audit **119,407-119,409** (awards INSERT, venues UPDATE status only,
   cities UPDATE venues_count only). Read-back matched every planned value.

## Results
| Venue | Name now | Canonical slug now | Old slugs (non-canonical) |
|---|---|---|---|
| ve_f558535881 | Krèsios | telese/kresios (unchanged) | - |
| ve_542c195114 | Paca | carmignano/paca | carmignano/paca-ristorante, prato/paca, prato/paca-ristorante |
| ve_eef796a74d | Coxinendi | quartu-sant-elena/coxinendi | quartu-sant-elena/coxinendi-ristorante, sanluri/coxinendi, sanluri/coxinendi-ristorante |
| ve_e50adc624d | El Jardín de la Sal | fuencaliente-de-la-palma/el-jardin-de-la-sal | fuencaliente-de-la-palma/restaurante-tematico-el-jardin-de-la-sal, las-caletas/restaurante-tematico-el-jardin-de-la-sal |
| ve_f88a5d9dc2 | The Upper Room at Duddell’s | hong-kong/the-upper-room-at-duddell-s | hong-kong/duddell-s-bar |

- Duddell's restaurant `ve_a3512f9a51`: awards now Michelin 2025 One Star (no URL), **2026 One Star (30110, card URL)**, OAD 2025 No. 120.
- Terra `ve_89ca903ac2`: closed. Fisterra city kept (1 venue, 0 active).

## Methods that worked (new)
- **Rename with 2 publishers in one batch:** one ledger row per publisher (michelin 4, pinnacle-guide 1); the source check allows
  each publisher's own URL pattern.
- **Slug file where one renamed venue keeps its slug:** gate n_same = 1 and plan rows = 4 (Krèsios: the slug rule removes the accent).
- **Status change + stored count in one file:** close the venue and update `cities.venues_count` in the same transaction
  (gate: 0 cities differ from `city_venue_counts` before and after).
- Write connector ran all 3 files on the first try (no DELETE in any file).

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/rename-open-items-b6-2026-10-31.sql` (180 lines) | Run (batch 32, audit 119,394-119,398) | `f8b41d8ea9a63c113074b76ea6e1db3f320158d3c70832f3a9c3f81b3cf5ae88` |
| `docs/slugs-rename-open-items-b6-2026-10-31.sql` (135 lines) | Run (audit 119,399-119,406) | `b08fdca05c1cc613eb40ef2aef4d7be47268bf7baada4b478f5f388705c1769b` |
| `docs/awards-status-open-items-b6-2026-10-31.sql` (101 lines) | Run (audit 119,407-119,409) | `0217d6edb6f87a87946edcb0d470557605bfdc21e89b395fb52913d6fdf22d84` |
| `docs/open-items-b6-build/relay.txt` (8 lines, no final newline) | Input | `a56c3d89a09c8463128b32100f401191790d5445e44ac5ec8414c4fe536707c5` |
| `docs/open-items-b6-build/build_open_items_b6_2026_10_31.py` | Build (`test` arg writes pre-check test copies) | `9f92cbcad6fc31c082bf08075f4280cae59ebeb3b8c612a39716b9381ca0afd4` |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. Merge and award cleanup (rest): La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy.
2. **New: Hong Kong Michelin 2026 edition not loaded.** Hong Kong city has 0 michelin 2026 rows and 145 michelin 2025 rows (read Oct 31).
   Duddell's 2026 row added by hand (30110). Also check Macau and the other cities of the Hong Kong & Macau guide. Large block:
   handoff break first.
3. Best Chef source URLs: 2024 519 rows (1 with URL; the 2024 list PDF covers all); 2025 781 rows (0 with URL; the 2025 list was not
   readable). Also check that each 2024/2025 row pairs to a list entry.
4. 2025 Green Star backfill, all guides (California 2025: 13 of 17 missing). Ben decides how far back.
5. 2025 Michelin URLs, all guides (about 3,461 rows without a URL; includes Duddell's 2025 row 5409).
6. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1 (also confirm Terra Fisterra is gone); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka /
   Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027
   dates not found; Florida 2026 Green Stars article not found; Turkey 2027 edition (check the unknown 2026 Bib then).
7. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.
8. Legacy price rows outside Turkey: 2,558 (scope when Ben asks).

## Suggested opening prompt
```
Read claude/handoff-open-items-b6-done-2026-10-31.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 175,
audit_log 119,409, awards 23,363, slugs 12,944, closed venues 370 and cities.venues_count sum 10,933. Then show me the
next-block options in /ste style (the open items, smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
