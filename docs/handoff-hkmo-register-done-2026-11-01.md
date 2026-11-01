# Handoff: HK/MO register items done (Xin Rong Ji merge, Mesa Bar, 3 special awards). Nov 1, 2026 (13:12 Atlanta). Next: Ben chooses.

This file replaces `handoff-hkmo-price-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
Special-award rules (Q1-QH): `handoff-special-awards-sql-ready-2026-10-29.md`.

## Ben's input (ET, Nov 1)
- 12:52 open item 1 (HK/MO register items): read each item, examine read-only, show choices; no write before go.
- 12:59 "For all choices go with your recommendation": 1a A (merge Xin Rong Ji), 1b A (keep 2 Mesa records, bar record ->
  "Mesa Bar"), 1c A (Chiu Chow Delicacies: no change), 1d A (Hong Kong Zuicho: no change), 1e A (3 special awards, Sol skipped).
  E1 (Mentor Chef name as printed) was taken by Claude: no recommendation was given. Ben can still ask for "Paul Lau Ping Lui".
- 13:07 "go".

## Live state (read Nov 1, 18:10:06 UTC, whole tables)
| Table | Count |
|---|---|
| venues | **11,299** (active **10,934**, closed 365) |
| awards | **23,371** (last id **30,138**); Michelin **9,667** |
| slugs | **13,002** (canonical **11,299**, non-canonical **1,703**) |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 (legacy_guide 2,380) |
| city_label_source | 23,999 |
| rename_batches / rename_rows | **22** (last id **37**) / **1,278** |
| source_capture_ledger | **159** rows, last id **209** |
| audit_log | **116,249** rows, last id **121,587** |
| cities.venues_count | sum **10,934**; cities that differ from the view: 0; Hong Kong **261** |

## Done in this session
1. Start check 17:52 UTC: ledger 207, audit 121,574, venues 11,300, price 7,733 (legacy 2,380), awards 23,368, slugs 13,001,
   cities sum 10,935 all matched. Repo attached with push access (clone `37ea4f8`).
2. Reads (read-only): see `docs/hkmo-2026-build/run-register-2026-11-01.txt`. Key results:
   - Xin Rong Ji: OAD Asia 2025 No. 14 "Xin Rong Ji Restaurant HK" = China Overseas Building, Lockhart Road = the Michelin card.
   - Mesa: one venue (restaurant + bar) at Grand Lisboa Palace; the bar is "Mesa Bar" on the hotel page and The 50 directory.
   - Chiu Chow Delicacies: Michelin card "Restaurant not found" (browser); OpenRice shows it open (Shop 1, 96 Wharf Road).
   - Hong Kong Zuicho: OpenRice "Closed"; DB already closed; OAD 2025 No. 261 is the Hong Kong Zuicho.
3. File `docs/register-hkmo-2026-11-01.sql` (sha256 `c5296a56...0959b4590`, 206 lines), built by
   `docs/hkmo-2026-build/build_register_hkmo_2026_11_01.py`; commit `47fd8df` (built, not run).
4. Dry run (Read connector, guards-only copy): passed.
5. **Real run** Write connector, first try, 18:09:40 UTC. Ledger **208** (oad, award, 1), **209** (michelin, award, 3).
   Audit **121,575-121,587** (13). Rename batch **37** applied. Awards 30136-30138 (Service Jenny Ye -> The Huaiyang Garden;
   Sommelier Floriane Hureau -> Caprice; Mentor Chef "Lau Ping Lui, Paul" -> Tin Lung Heen).
   `ve_4dc9197f86` merged into `ve_f966b7e0a1` (old URL kept as non-canonical). Bar record `ve_6f0bd256a0` = "Mesa Bar",
   new canonical `macau/mesa-bar`. Run record `docs/hkmo-2026-build/run-register-2026-11-01.txt`.

## Methods that worked (new)
- **One file for small mixed items:** all guards for every part first, then the writes. A guards-only dry-run copy
  (script cut at the first write + `RAISE EXCEPTION 'DRY RUN OK'`) checks every guard in one Read-connector call.
- **Card status in the browser:** `preview_start` + `javascript_tool` reading `document.title` and "not found" text.
- **OAD list in the browser:** one read of `/lists/asia/top-restaurants/2025` gives rank, name and city for many rows;
  the restaurant page `/restaurant/<slug>` gives the address.
- **OpenRice in the browser** gives a reliable open/closed flag ("(Closed)" after the name). WebFetch gets a security page.

## Dead ends: do not retry
- WebFetch of a guide.michelin.com card to test "Restaurant not found": it returned a Bib card for a page that the browser
  shows as not found. Use the browser for card status.
- WebFetch of OpenRice (BytePlus security check page).

## Open items, smallest first
1. D8: HK/MO 2025 history backfill from web.archive.org capture 20251229115831 (with the all-guides 2025 URL item).
   Includes Hong Kong Zuicho 2025 One Star and the source URL of Chiu Chow Delicacies 2025 row 10529.
2. Forum blurb (`needs_rewrite`): rewrite can now use the name "Forum".
3. Apostrophe policy (Hung's Delicacies, Prof Chan's, L'Atelier de Joël Robuchon, Lai's Kitchen: U+0027).
4. `name_native` backfill elsewhere: China 469, Japan 585, Chengdu 47 (same method). Site display of `name_native`: Ben decides.
5. Legacy price rows elsewhere: 2,380 legacy_guide rows remain (read the population by country before a plan).
6. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` at the HK & Macau 2027 guide (March 2027): card gone, 2026
   article names it, OpenRice open. Sol (Hong Kong) has a 2026 Young Chef Award but no venue (Selected only, Q3 A).
7. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); 2025 Green Star backfill; 2025 Michelin URLs all guides; Beverly
   Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov; Spain Dec 1; Northeast Cities
   after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-hkmo-register-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 209,
audit_log 121,587, venues 11,299, awards 23,371, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then start open item 1 (D8, HK/MO 2025 history backfill): read the archive capture, examine read-only, and show me in /ste
style with the choices. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
