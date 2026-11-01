# Handoff: HK/MO 2026 price from the card done (180 venues). Nov 1, 2026 (12:50 Atlanta). Next: Ben chooses.

This file replaces `handoff-hkmo-native-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
Price block A method (live card read): `handoff-price-card-p2-brief-2026-10-30.md`.

## Ben's input (ET, Nov 1)
- 12:19 open item 1 (HK/MO price from the card): build, examine read-only, show choices; no write before go.
- 12:28 "1A, 2A, 3A": source = ingest_rows batch 19 symbol; captured_at = batch 19 created_at; INSERT the 6 with no row.
- 12:46 "go".

## Live state (read Nov 1, 17:47:23 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,300 (active 10,935, closed 365) |
| venues with `name_native` | 338 |
| awards | 23,368 (last id 30,135) |
| slugs | 13,001 (canonical 11,300) |
| price | **7,733** (legacy_guide **2,380**) |
| source_capture_ledger | last id **207** |
| audit_log | last id **121,574** |
| cities.venues_count | sum 10,935 |

## Done in this session
1. Start check 17:20 UTC: ledger 206, audit 121,394, venues 11,300, name_native 338, awards 23,368, slugs 13,001, cities sum
   10,935 all matched. Repo attached with push access (clone `7811704`).
2. Population: 180 venues of the 2026 Michelin star/Bib rows whose card URL is in ingest batch 19 (HK 146, Macao 34), all active.
   174 legacy rows with no URL (171 same symbol; 3 tier changes: Feuille $$$$ -> $$$, Rùn $$$ -> $$$$, Sun Tung Lok $$ -> $$$).
   6 with no price row: Andō (existing venue) + 5 new (Ăn Chơi, Dragon Inn, Eng Kee Noodle Shop, Eton, Sang Kee Foods (Western
   District)). Lai Ching Heen (the 6th new venue) already held the legacy row moved from Lai Heen.
3. Currency: HK -> HKD, Macao -> MOP (Michelin price-range index: HK$ and MOP$, same 4 bands).
4. File `docs/price-michelin-card-hong-kong-macau-2026.sql` (sha256 `5f5645e1...2d80cd6`, 267 lines, ASCII), built by
   `docs/hkmo-2026-build/build_price_hkmo_2026_11_01.py batch yes`; values read from `ingest_rows` inside the SQL.
   Plan md5 `0525e524...3c7649`; old rows md5 `b8755c53...09ad6e`.
5. Dry run (Read connector, shortened copy of gates 1-4): passed, stopped at the UPDATE.
6. **Real run** Write connector, first try, 17:47:12 UTC. Ledger **207** (michelin, price, 180). Audit **121,395-121,574**
   (174 price UPDATE, 6 price INSERT, 1 timestamp). Audit new-values md5 = plan. Run record
   `docs/hkmo-2026-build/run-price-2026-11-01.txt`.
7. Review list `price-hkmo-2026-review.csv` (180 rows): chat file for Ben, not in the repo.

## Methods that worked (new)
- Price from an ingest batch (no browser): plan from `ingest_rows.raw->>'price_symbol_raw'` joined to the award row by card URL,
  category filter for star/Bib (drops the Green Star twins), currency from `cities.country`. UPDATE and INSERT in one file.
- INSERT ... SELECT into enum columns needs explicit casts (`'guide_ingest'::price_source_t`, `'published_symbol'::price_method_t`):
  an unknown literal in a SELECT list resolves to text. The dry run stops before the INSERT, so it does not catch this.
- Review list from the transcript: the tool result text holds `\"tsv\"` (escaped), so match on a venue id, not `"tsv":"`.

## Open items, smallest first
1. Register: Xin Rong Ji twin `ve_4dc9197f86` (OAD 2025 No. 14) vs `ve_f966b7e0a1`; Mesa (2 Macau venues, Selected only);
   Chiu Chow Delicacies `ve_d7e57d1d84` status (its legacy price row stays); HK Zuicho closed; 4 special awards (Young Chef Sol,
   Service The Huaiyang Garden, Sommelier Caprice, Mentor Chef Tin Lung Heen) -> special-awards batch.
2. D8: HK/MO 2025 history backfill from web.archive.org capture 20251229115831 (with the all-guides 2025 URL item).
3. Forum blurb (`needs_rewrite`): rewrite can now use the name "Forum".
4. Apostrophe policy (Hung's Delicacies, Prof Chan's, L'Atelier de Joël Robuchon, Lai's Kitchen: U+0027).
5. `name_native` backfill elsewhere: China 469, Japan 585, Chengdu 47 (same method). Site display of `name_native`: Ben decides.
6. Legacy price rows elsewhere: 2,380 legacy_guide rows remain (read the population by country before a plan).
7. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); 2025 Green Star backfill; 2025 Michelin URLs all guides; Beverly
   Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov; Spain Dec 1; Northeast Cities
   after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-hkmo-price-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 207,
audit_log 121,574, venues 11,300, price 7,733 (legacy 2,380), awards 23,368, slugs 13,001 and cities.venues_count sum 10,935.
Then start open item 1 (HK/MO register items): read each item, examine read-only, and show me in /ste style with the choices.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
