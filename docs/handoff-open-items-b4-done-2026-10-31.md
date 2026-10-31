# Handoff: Open items block 4 done (36 Turkey card prices, cities.venues_count recount, city_venue_counts view). Oct 31, 2026 (00:14 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b3-done-2026-10-30.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the Telluride city method: `handoff-open-items-b1-done-2026-10-30.md`.
Turkey city rule (D7, Michelin city): `handoff-open-items-b2-done-2026-10-30.md`. Block 3 record (Istanbul -> TURK merge,
12 Turkey slugs, Heritage 2023/2024): `handoff-open-items-b3-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 30-31, 2026, ET)
- Oct 30 23:37: fresh count read, next-block options, repo with push access.
- Oct 30 23:43 "Let's do your recommendation": items 1 (36 Turkey prices) and 2 (venues_count) as one block.
- Oct 31 00:09 "1. go, 2. b": run the price file; venues_count = **B** (recount once + a live-count view).
- Oct 31 00:12 "Go": run the recount file and the view migration.

## Live state (read Oct 31, 04:13:31 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,303 (active 10,934, closed 369) |
| awards | 23,362 |
| price | 7,731 (legacy_guide **2,558**; Turkey legacy 0) |
| slugs | 12,936 (canonical 11,303); venues with other than 1 canonical slug: 0 |
| listings | 11,303 |
| cities / city_aliases / redirects | 3,259 / 265 / 9 |
| city_label_source | 24,003 |
| source_capture_ledger | last id **172** |
| audit_log | 114,087 rows, last id **119,371** |
| cities.venues_count | sum **10,934**; cities that differ from the live active count: **0** |
| view `city_venue_counts` | 3,259 rows; active 10,934; all 11,303; 0 differ from the column |

## Done in this session
1. Start check 03:37 UTC: ledger 171, audit 119,076, venues 11,303, slugs 12,936, city_label_source 24,003; all other
   counts matched the b3 handoff. Repo attached with push access (clone `272dd4e`).
2. **Item 1, Turkey prices.** Population: Turkey (`cities.country_iso = 'TR'`) price rows with source legacy_guide and no
   source_url: 36, all active, all with a Michelin star/Bib card URL (ids md5 `10358d7d…41ce78`, list sha256
   `a1a8788c…7547a3`, checked in the browser). Card read: built-in browser, one guide.michelin.com tab, `fetch()` loop,
   1.2 s pause, 03:44:39-03:45:26 UTC. 36 read, 36 clean (status 200, 0 redirects, ₺ symbol, CAT_P0n = symbol count,
   country tr). Distinction: 1 star 9, 2 star 1, bib 26 (= our award rows). Relay sha256 `57c835b7…3c7f49` (browser =
   file). Diff: 31 same tier; 5 down one step (Asma Yaprağı 3→2, Araka 4→3, Mahir Lokantası 2→1, Yanyalı Fehmi Lokantası
   2→1, OD Urla 4→3); 0 up; 0 bigger. Builder: copy of `build_price_update_sql.py` with tr → TRY, ₺ added
   (`docs/open-items-b4-build/build_price_turkey_b4_2026_10_30.py`). pglast OK. Dry run (Read connector) passed.
   **Run** (Write connector, first try, 04:10:41 UTC): ledger **172** (michelin, price, 36); audit **119,077-119,112**
   (36 price UPDATE). Read-back: Mikla ₺₺₺₺ TRY 4, Turk Fatih Tutak ₺₺₺₺ 4, Araka ₺₺₺ 3, OD Urla ₺₺₺ 3, Pandeli ₺₺ 2,
   Mahir Lokantası ₺ 1. Card tiers: 1 = 10, 2 = 16, 3 = 2, 4 = 8.
3. **Item 2, venues_count.** Findings before the build:
   - The live site does not read `cities.venues_count`. It reads `data/cities.json` (Google Sheet sync,
     `scripts/sync-sheet.ts`) and also counts active venues live (`src/lib/venues.ts`).
   - No refresh job exists in the database (no function uses the column; 0 audit rows ever changed it). The text in
     `scripts/ingest/undo.ts` ("maintained by its own refresh job") is wrong.
   - Definition: active venues only (as `docs/cities-jackson-wy-split.sql`). 259 cities differed (212 too low, 47 too
     high; 84 at 0 with active venues). Biggest: Shenzhen 3→30, Chengdu 36→54, Hangzhou 31→49, New Taipei City 0→18.
   - A trigger (option C) would add a cities audit row to every venue move or closure and break the exact audit counts
     in the file templates. Ben chose B.
   - **File 1** `docs/cities-venues-count-recount-2026-10-31.sql`: plan md5 `a31795e2…2edd4` (id|old|new, 259 rows),
     all-cities md5 `0b65621e…f8cf8f`. First build used a temp table; the Read connector refused it (read-only); the plan
     now sits in a jsonb variable. pglast OK; dry run passed. **Run** (Write connector, first try, 04:13:12 UTC):
     audit **119,113-119,371** (259 cities UPDATE, venues_count only). No ledger row. Post-checks passed.
   - **File 2** migration `supabase/migrations/20261031000100_city_venue_counts_view.sql` (applied as version
     `20261031041319` `city_venue_counts_view`): view `public.city_venue_counts` (city_id, slug, display, country_iso,
     active_venues, all_venues), `security_invoker = true`. RLS on cities and venues is on with no policies, so anon
     readers see 0 rows (same as the tables). No data change, no audit rows.
   - Read-back: 0 cities differ; view = column for all 3,259; samples Bodrum 8, Istanbul 34, New Taipei City 18,
     Paris 217, Shenzhen 30, Wānaka 5.

## Methods that worked (new)
- **Read-only dry run and temp tables:** the Read connector refuses `CREATE TEMP TABLE` (read-only transaction). Hold a
  plan in a `jsonb` variable and use `jsonb_to_recordset` instead.
- **Card relay copy-out:** the file tool writes `\uXXXX` text as the real character. Write the relay with the real
  characters, then compare the sha256 with the browser hash.
- **cities audit rows:** `row_pk` = city id.

## Standing note
- `cities.venues_count` is a stored copy. Each later venue move, closure or delete makes it stale again. Use the view
  `city_venue_counts` for correct counts. A later file can recount the column with the same file pattern if needed.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/price-michelin-card-turkey-b4-2026-10-30.sql` | Run (ledger 172, audit 119,077-119,112) | `3c9e85552b44e071c87e496999d9ff05a64529015455d5ffdffc669677c320fb` |
| `docs/open-items-b4-build/relay-price.txt` (36 lines, no final newline) | Input | `57c835b7a261f8c486e4279982ae44fc58951987b61e9bdb3e9849e7b83c7f49` |
| `docs/open-items-b4-build/build_price_turkey_b4_2026_10_30.py` | Build | `a9d75bad4660845fccbc5641879e3d5da2bb67c7d052474a844d58a99225c2d4` |
| `docs/cities-venues-count-recount-2026-10-31.sql` | Run (audit 119,113-119,371) | `95174e1c1cd9071e5e49b67cb6f42beed1f4df3f503b8f5217306ade34fdbaae` |
| `supabase/migrations/20261031000100_city_venue_counts_view.sql` | Applied (version 20261031041319) | `9080eead95eb3854e7dbdd1ccd939bdc5993013f9fa7cdc5eef6b1af21ec946c` |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. Held-P2 items: 5 city changes; 15 P2 venues that left the guide.
2. Merge and award cleanup: La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy; Duddell's (Hong Kong) possible duplicate `ve_a3512f9a51` /
   `ve_f88a5d9dc2`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved.
3. Best Chef source URLs: 2024 519 rows (1 with URL; the 2024 list PDF covers all); 2025 781 rows (0 with URL; the 2025
   list was not readable). Also check that each 2024/2025 row pairs to a list entry.
4. 2025 Green Star backfill, all guides (California 2025: 13 of 17 missing). Michelin history before 2025 is thin; Ben
   decides how far back before a history backfill is scoped.
5. 2025 Michelin URLs, all guides (about 3,461 rows without a URL).
6. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
   Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found;
   Florida 2026 Green Stars article not found; Turkey 2027 edition (check the unknown 2026 Bib then).
7. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.
8. Small fix, no data: the wrong "refresh job" text in `scripts/ingest/undo.ts` (point to the view instead).
9. Legacy price rows outside Turkey: 2,558 (the P1/P2 batches covered venues with a card URL; scope the rest when Ben asks).

## Suggested opening prompt
```
Read claude/handoff-open-items-b4-done-2026-10-31.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 172,
audit_log 119,371, price 7,731 (legacy 2,558), venues 11,303 and cities.venues_count sum 10,934. Then show me the
next-block options in /ste style (the open items, smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
