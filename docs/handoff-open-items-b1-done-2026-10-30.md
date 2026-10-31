# Handoff: Open items block 1 done (Telluride city, Forentum, Les Fresques, Paloma) + city display names. Oct 30, 2026 (20:57 Atlanta). Next: Ben chooses.

This file replaces `handoff-name-diffs-held8-done-2026-10-30.md` for live state and open items. That file still holds the
batch 30 record and the slug-reuse method. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Working rules and database
notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 30, 2026)
- 19:46 ET "Go": items 1-4 of the next-block list as one block.
- 19:50 ET "All recommended": 1 = A (Telleruide -> Telluride, name and slug), 2 = A (Les Fresques), 3 = A (Forentum),
  4 = A (Paloma Taqueria: no write, item closed).
- 20:21 ET "Go" (file 1), 20:36 ET "Go" (file 2), 20:38 ET "Go" (file 3), 20:45 ET "Retry the connector",
  20:48 ET "Ran manually in Supabase" (file 3, SQL Editor).
- 20:53 ET "A": city display names only (Waiheke Island, Wānaka, Đakovo; slugs stay). 20:55 ET "Go".

## Live state (read Oct 31, 00:56:18 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,304 (active 10,937) |
| awards | 23,353 |
| price | 7,730 |
| slugs | **12,915** (canonical 11,304, non-canonical **1,611**) |
| venues with other than 1 canonical slug | 0 |
| listings | 11,304 |
| cities / city_aliases / redirects | 3,263 / **262** / 9 |
| city_label_source | 24,005 |
| blurbs | 142 |
| rename_batches | 17 (last id **31**); rename_rows **1,196** |
| source_capture_ledger | 121 rows, last id **165** |
| audit_log | 113,706 rows, last id **118,990** |

## Done in this session
1. Start check (23:43 UTC): ledger 164, audit 118,975, slugs 12,913 and all counts matched. Repo attached with push access
   (clone `baea1d3`).
2. Reads (WebFetch, Ben approved each): Michelin cards Forentum, Les Fresques (the `/en/` URL gave an empty page; the
   `/us/en/` URL worked), Paloma Taqueria; sites forentum.it, vigiers.com, palomawanaka.co.nz, 221southoak.com.
   Results in `docs/open-items-b1-decisions-2026-10-30.txt`.
3. Fresh read 23:52 UTC (md5 live id|name `84ff07c365ad979620e198f514f27fe3`), pulled from the transcript by
   `docs/open-items-b1-build/grab.py`. Build by script `docs/build_open_items_b1_2026_10_30.py` (build, slug FP, city FPC FPV).
   Read-only check `CHECK31-9b41317f…`: 0 collisions, 0 in use, 0 in redirects, reuse 1 (`lavello/forentum`).
4. pglast: 3 files parse. Rename dry run stopped at the first INSERT. City pre-check test (today's counts) stopped at the
   first INSERT. 0 ids used. Repo commit `bc8e646` (built, not run).
5. **File 1, rename** (Write connector, first try, 00:22:18 UTC): batch **31** `rename-open-items-b1-2026-10-30` applied,
   2 rename_rows, ledger **165** (michelin, name, 2), audit **118,976-118,977** (2 venues UPDATE).
6. **File 2, slugs** (Write connector, first try, ~00:37 UTC): `lavello/forentum` reused as canonical, `monestier/les-fresques`
   inserted; audit **118,978-118,981** (3 UPDATE, 1 INSERT). No ledger row.
7. **File 3, Telluride city**: the Write connector prompt closed by itself twice (0.7 s and 0.5 s; nothing ran, checked by
   read each time). Ben ran the file in the Supabase SQL Editor (00:48:27 UTC). Audit **118,982-118,987**: cities INSERT
   `ci_0e83eaf4c6`, venues UPDATE `ve_b44e9a2762` (city_id only), slugs UPDATE + INSERT, cities DELETE `ci_b8de1219b5`,
   city_aliases INSERT `telleruide` (hand row). No ledger row. Read-back matched every planned value.
8. **City display names** (Ben "A", display only): card reads Mudbrick ("…Oneroa, Waiheke Island, 1971, New Zealand") and
   Bistro Loora ("Ul. Ivana Pavla II 5, Đakovo, 31400, Croatia"); Wānaka from the Paloma card. File
   `docs/cities-display-waiheke-wanaka-dakovo-2026-10-30.sql` (build `docs/open-items-b1-build/build_city_labels.py`),
   dry run passed, Write connector first try (00:56 UTC): `ci_d43edfbc8a` Waiheke -> **Waiheke Island**, `ci_daf6d172be`
   Wanaka -> **Wānaka**, `ci_f568968b3d` Dakovo -> **Đakovo**. Audit **118,988-118,990** (3 cities UPDATE, display only).
   Slugs waiheke / wanaka / dakovo unchanged; old and new labels resolve to the same city. No ledger row.
   Note: Wanaka `venues_count` is 4 but the city has 6 venues (5 active): part of the recount item.

## Results
| Venue | Before | After | Canonical slug now | Old slugs (non-canonical) |
|---|---|---|---|---|
| ve_04c2784726 | Lavello | **Forentum** | lavello/forentum (reused) | lavello/lavello |
| ve_e574aeb7fd | Restaurant Les Fresques une étoile Michelin depuis plus de 10 ans | **Les Fresques** | monestier/les-fresques | monestier/restaurant-les-fresques-une-etoile-michelin-depuis-plus-de-10-ans, monestier/les-fresques-chateau-des-vigiers |
| ve_b44e9a2762 | 221 South Oak, city Telleruide `ci_b8de1219b5` | 221 South Oak, city **Telluride** `ci_0e83eaf4c6` | telluride/221-south-oak | telleruide/telleruide-kzwzua |

- City "Telleruide" `ci_b8de1219b5` deleted (first city delete in the project; full old row in audit 118,986).
  Alias `telleruide` -> `ci_0e83eaf4c6`: an OAD label "Telleruide" now resolves to Telluride. OAD city labels (17154, 17155)
  unchanged (source labels).
- 221 South Oak site: "Closed For Offseason, We Reopen 12/11" (seasonal). Status stays active.
- Paloma Taqueria `ve_3fad690140`: card Bib 2026, no closure; site notice "back open on June 30" is old. **Closed, no write.**
  Card and site both write "Wānaka" (supports the city-label item).

## Methods that worked (new)
- **Empty city after a move:** insert the new city (id = `ci_` + left(md5(slug), 10)), move the venue, old slug
  non-canonical, delete the empty old city (gate: 0 venues, 0 aliases), add an alias for the old spelling with a hand audit
  row. Post-check: stage-job resolution of both labels gives only the new city. Template:
  `docs/cities-telluride-fix-2026-10-30.sql`.
- **City pre-check test before the earlier writes:** a test copy with today's counts in place of the post-file-2 counts,
  sent through the Read connector up to the first write. It finds logic errors before the real dry run.
- **Write connector and DELETE:** the connector prompt for a file with a DELETE closed by itself twice in this session.
  Files with only INSERT/UPDATE ran on the first try. For a file with a DELETE, offer the SQL Editor route first.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/rename-open-items-b1-2026-10-30.sql` (179 lines) | Run (batch 31) | `5e3c40d8f52f731ac0cd4d1baf408eba80b69028e505519773e5459d591f9fea` |
| `docs/slugs-rename-open-items-b1-2026-10-30.sql` (167 lines) | Run (audit 118,978-118,981) | `51a68bb9803d50b5c83c196df5f9da14c0455cafc193c33d17eb91fe0af04fdd` |
| `docs/cities-telluride-fix-2026-10-30.sql` (218 lines) | Run in SQL Editor (audit 118,982-118,987) | `f0b5b254be390416fbfe98541ad14431a8d42a13c2ad01ab8908eb9ab13ee1f2` |
| `fixtures/rename/open-items-b1-2026-10-30.csv` (2 rows) | Input | `11bf8a6c63e3b833c984270f671c3fb9616ff0a9b7558ad4d9bef434c3cd1f15` |
| `docs/open-items-b1-decisions-2026-10-30.txt` | Decisions + reads | `e3237d656af4bdef104b15d11a5b3dc012058a8727b79e06bf990a08842cd16f` |
| `docs/build_open_items_b1_2026_10_30.py` + `docs/open-items-b1-build/` (templates, grab.py, check31.sql) | Build | `70db8071e436d839dde5ad365039300f2c0bbed63661ceebd3792e88da3a8fb7` (script) |
| `docs/cities-display-waiheke-wanaka-dakovo-2026-10-30.sql` (108 lines) | Run (audit 118,988-118,990) | `620f9621bdea47f28a36d5fbda7da8859fa3000d3400d16439eaf9cc6780613f` |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first (carried; items 1-4 of the Oct 30 list and the city display names are closed)
1. Apostrophe policy: 683 names (627 straight U+0027, 56 curly U+2019). A keep the source spelling per venue (recommended,
   no write) / B all straight / C all curly.
2. Missing Green Star and URL rows: 2025 Green Star for Chez Panisse, Chi Spacca, Pomet, Heritage (Long Beach); 2025 rows of
   the 3 sisters (10486, 10493, 10494) without URL; Banshee 2023/2024 Bib rows without URL; American South 2025/2026 check.
3. Turkey follow-ups: Sankai by Nagaya price (₺₺₺₺, CAT_P04, TRY 4); Efendy recheck; one 2026 Turkey Bib unknown (39 vs 38);
   Efendy and Lucien Arkas legacy `$$` rows; Sankai site spam.
4. Turkey card cities that differ from ours (Revithia, Casa Lavanda, Bagarasi, Mandalya, Mezegi, Asma Yaprağı, Mezra Yalıkavak,
   Babayan Evi, Old Greek House) plus KITCHEN by Osman Sezener (card Yalıkavak, ours Bodrum). Ben chooses the city policy.
5. Status checks: Nadair (Atlanta) possibly closed; Dill (Lewes).
6. Held-P2 items: 5 city changes; 15 P2 venues that left the guide.
7. Merge and award cleanup: La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire
   `ve_b5a5b44c26` card moved.
8. `cities.venues_count` recount: 375 cities differ from the live count (read Oct 30, before this block). Ben decides.
9. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
    Fujian 2027 late Nov; Spain 2027 Dec 1; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
    Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found;
    Florida 2026 Green Stars article not found.
10. Write connector prompt closes by itself (now seen on a DELETE file twice); SQL Editor route works.
11. Telluride: 221 South Oak reopens 12/11 (seasonal); no action needed unless the site shows otherwise.

## Suggested opening prompt
```
Read claude/handoff-open-items-b1-done-2026-10-30.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5 and claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and
confirm ledger 165, audit_log 118,990, slugs 12,915 and city_aliases 262. Then show me the next-block options in /ste style
(the open items, smallest first, with what each needs from me) and wait for my choice. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
