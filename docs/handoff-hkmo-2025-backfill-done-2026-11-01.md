# Handoff: D8 done (HK/MO Michelin 2025 history backfill). Nov 1, 2026 (13:46 Atlanta). Next: Ben chooses.

This file replaces `handoff-hkmo-register-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
Special-award rules (Q1-QH): `handoff-special-awards-sql-ready-2026-10-29.md`.

## Ben's input (ET, Nov 1)
- 13:12 open item 1 (D8): read the archive capture, examine read-only, show choices; no write before go.
- 13:22 "A2, B1, C1, D1, E1": A2 = Stars, Bib and Green Star rows; B1 = source_url is the archive id_ URL of the 2025 full list;
  C1 = accept 8 name pairs proved by the 2026 card (+ Din Tai Fung TST by card `din-tai-fung-silvercord`); D1 = skip the 3
  dropped 2025 Bibs with no venue (Man Yuen, Sun Yuen Hing Kee, What To Eat); E1 = row 10529 gets the source_url only.
- 13:41 "go" (run 1 rolled back at a post-check, see below). 13:43 "Go" (run 2, committed).

## Live state (read Nov 1, 18:45:32 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934, closed 365) |
| awards | **23,543** (last id **30,482**); Michelin **9,839**; Michelin 2025 **3,463** (no URL **3,281**) |
| HK/MO Michelin 2025 | **173** (Hong Kong 142, Macau 31), all with the archive URL |
| slugs | 13,002 (canonical 11,299, non-canonical 1,703) |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 (legacy_guide 2,380) |
| source_capture_ledger | **160** rows, last id **211** (id 210 used by the rolled-back run 1, no row) |
| audit_log | **116,422** rows, last id **121,933** |
| cities.venues_count | sum 10,934; Hong Kong 261 |

## Done in this session
1. Start check 18:12:20 UTC: all counts = the register handoff. Repo attached with push access (clone `d233e6f`).
2. Archive read (built-in browser): capture 20251229115831, status 200, 0 redirects. 12 of 12 section counts = heading numbers.
   Relay `docs/hkmo-2025-build/relay-hkmo-2025-archive-20251229115831.txt` (265 lines, sha256 `02bf30b1...0ca81b`), commit `9731f21`.
3. Match: 176 rows in scope; 173 paired (exact 145, without branch 19, C1 card pairs 9); 3 no venue (D1).
4. File `docs/backfill-michelin-2025-hong-kong-macau.sql` (sha256 `437ce587...27100`, 150 lines), built by
   `docs/hkmo-2025-build/build_backfill_hkmo_2025.py`; commits `e59af9f` (first build) and `1a7db4c` (post-check fix).
5. Run 1 (18:42 UTC) rolled back at a post-check: "column reference n is ambiguous". Nothing written. Fix: alias `cnt`.
6. **Run 2** Write connector, committed 18:45:21 UTC. Awards **30311-30482** (172). Row 10529 source_url filled. Ledger **211**
   (michelin, award, 173). Audit **121,761-121,933** (172 INSERT + 1 UPDATE). Run record
   `docs/hkmo-2025-build/run-backfill-2025-2026-11-01.txt`.

## Methods that worked (new)
- **Archive list relay in one tab:** read the rendered capture, cut lines by section heading ("N One-MICHELIN-Starred
  Restaurants", "N Bib Gourmands"...), check each section count against the heading number, escape non-ASCII as `\uXXXX`.
- **Heredoc caution:** the shell tool turns `ù` typed in a heredoc into the real character. Re-escape the saved file with
  Python, then compare the hash with the browser hash.
- **Match tiers in SQL:** `norm_key` exact in the city; else `norm_key` with a trailing `(branch)` removed on both sides, 1 venue
  only; else an explicit venue id from the decisions. Gate on md5 of `seq:venue_id`.
- **Dry run with no temp table:** the Read connector refuses `CREATE TEMP TABLE`. Keep the resolved plan in a `jsonb` variable.
- **Post-check variable names:** never use a PL/pgSQL variable name (`n`, `x`, `s`) as a column alias. Test a new post-check
  alone through the Read connector (a DO block that ends with `RAISE EXCEPTION 'TEST OK'`).

## Dead ends: do not retry
- curl of web.archive.org from the workspace (proxy refuses the host). Use the built-in browser.
- `CREATE TEMP TABLE` inside a dry run (read-only transaction).

## Open items, smallest first
1. Forum blurb (`needs_rewrite`): rewrite can now use the name "Forum".
2. Apostrophe policy (Hung's Delicacies, Prof Chan's, L'Atelier de Joel Robuchon, Lai's Kitchen: U+0027).
3. `name_native` backfill elsewhere: China 469, Japan 585, Chengdu 47 (same method). Site display of `name_native`: Ben decides.
4. Legacy price rows elsewhere: 2,380 legacy_guide rows remain (read the population by country before a plan).
5. 2025 Michelin URLs, other guides: 3,281 Michelin 2025 rows have no source_url (HK/MO done). Same archive method per guide.
6. 2025 Green Star backfill, other guides (HK/MO done: 5 rows).
7. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` at the HK & Macau 2027 guide (March 2027). Sol (Hong Kong)
   2026 Young Chef Award, no venue. The 3 D1 Bibs (Man Yuen, Sun Yuen Hing Kee, What To Eat) have no venue and no 2025 row.
8. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); Beverly Hills watch; date gates (Switzerland after Nov 2; Italy
   2027 after Nov 12; Fujian late Nov; Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau
   2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-hkmo-2025-backfill-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 211,
audit_log 121,933, venues 11,299, awards 23,543, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then start open item 1 (Forum blurb): read the current blurb and the runbook, examine read-only, and show me in /ste style.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
