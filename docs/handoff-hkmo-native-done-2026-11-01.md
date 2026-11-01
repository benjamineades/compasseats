# Handoff: HK/MO 2026 name_native done (135 venues). Nov 1, 2026 (12:02 Atlanta). Next: Ben chooses.

This file replaces `handoff-hkmo-renamed-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
`name_native` method: `handoff-taiwan-native-done-2026-10-27.md`.

## Ben's input (ET, Nov 1)
- 11:53 open item 1 (HK/MO name_native): build, examine read-only, show choices; no write before go.
- 11:59 "1A, 2A": branch part " (...)" kept as on the card; 45 Latin-only cards skipped.
- 12:00 "go".

## Live state (read Nov 1, 17:00:53 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,300 (active 10,935, closed 365) |
| venues with `name_native` | **338** (Taiwan 185, HK/MO **135**, China 17, France 1) |
| awards | 23,368 (last id 30,135) |
| slugs | 13,001 (canonical 11,300, non-canonical 1,701) |
| rename_batches / rename_rows | 21 (last id 36) / 1,277 |
| source_capture_ledger | 156 rows, last id **206** (no new row) |
| audit_log | **116,056** rows, last id **121,394** |
| cities.venues_count | sum 10,935 |

## Done in this session
1. Start check 16:54 UTC: ledger 206, audit 121,259, venues 11,300, awards 23,368, slugs 13,001, cities sum 10,935 all matched.
   Repo attached with push access (clone `2977e70`).
2. Population: 180 cards of ingest batch 19 = 180 venues (HK 146, Macau 34), all active, 0 `name_native`. 135 cards hold Chinese
   script (HK 103, Macau 32). 45 Latin-only (= card English name on all 45) skipped. 0 duplicate Chinese names. The 5 Green Star
   rows (30131-30135) share a card URL with a star row; DISTINCT gives 1 row per venue.
3. Branch part: 32 Chinese names carry " (...)"; on 23 the live English name has none (rename batch 36). Option A keep (0 dup),
   B drop on the 23 (0 same-city dup), C drop all (1 same-city dup: 2 HK Din Tai Fung = 鼎泰豐). Ben: A.
4. File `docs/name-native-michelin-2026-hong-kong-macau.sql` (sha256 `c235423a...68d1b4a`, 149 lines, ASCII), built by
   `docs/hkmo-2026-build/build_name_native_hkmo_2026_11_01.py A`; values read from `ingest_rows` inside the SQL. Commit `9880ff2`
   (built, not run). Plan md5 `8823c995...d545ac` (database = script); target rows md5 `6dcc4631...968b76`.
5. Dry run 16:57 UTC (Read connector): gates 1-4 passed, stopped at the UPDATE.
6. **Real run** Write connector, first try, 17:00:45 UTC. Audit **121,260-121,394** (135 venues UPDATE, 1 timestamp, only
   `name_native` changed). Audit md5 = live md5 = plan. No ledger row (precedent). Run record
   `docs/hkmo-2026-build/run-name-native-2026-11-01.txt`.
7. Review list `name-native-hkmo-2026-review.csv` (180 rows): chat file for Ben, not in the repo.

## Methods that worked (new)
- Plan from `ingest_rows` by card URL: `SELECT DISTINCT a.venue_id, r.raw->>'venue_name_zh' FROM ingest_rows r JOIN awards a ON
  a.source_id='michelin' AND a.year=2026 AND a.source_url = r.raw->>'source_url' WHERE r.batch_id = <batch>` plus the CJK regex.
  DISTINCT handles Green Star rows that share a card URL. No award id range needed.
- Gate 1 includes the last audit id. The file is then single-use: any other write first makes it fail.
- Grab from the session transcript: match the tool result string that starts with `{"result"` and holds the marker; unwrap
  `json.loads(...)['result']`; cut from `[{"m":"MARKER` to `</untrusted-data`. Do not match the tool input or own Bash text.

## Open items, smallest first
1. HK/MO price from the card (170 agree; differ: Rùn, Sun Tung Lok, Feuille; none: Ando, 6 new venues). With item 3.
2. Register: Xin Rong Ji twin `ve_4dc9197f86` (OAD 2025 No. 14) vs `ve_f966b7e0a1`; Mesa (2 Macau venues, Selected only);
   Chiu Chow Delicacies `ve_d7e57d1d84` status; HK Zuicho closed; 4 special awards (Young Chef Sol, Service The Huaiyang Garden,
   Sommelier Caprice, Mentor Chef Tin Lung Heen) -> special-awards batch.
3. D8: HK/MO 2025 history backfill from web.archive.org capture 20251229115831 (with the all-guides 2025 URL item).
4. Forum blurb (`needs_rewrite`): rewrite can now use the name "Forum".
5. Apostrophe policy (Hung's Delicacies, Prof Chan's, L'Atelier de Joël Robuchon, Lai's Kitchen: U+0027).
6. `name_native` backfill elsewhere: China 469, Japan 585, Chengdu 47 (same method). Site display of `name_native`: the site does
   not show it yet; Ben decides if and where (venue page subtitle, search).
7. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); 2025 Green Star backfill; legacy price rows outside Turkey; 2025
   Michelin URLs all guides; Beverly Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov;
   Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-hkmo-native-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 206,
audit_log 121,394, venues 11,300, name_native 338, awards 23,368, slugs 13,001 and cities.venues_count sum 10,935. Then start
open item 1 (HK/MO price from the card): build the file, examine it read-only, and show me in /ste style with the choices.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
