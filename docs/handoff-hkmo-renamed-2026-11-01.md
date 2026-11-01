# Handoff: HK/MO 2026 rename batch done (batch 36, 66 venues) and slugs done. Nov 1, 2026 (11:37 Atlanta). Next: Ben chooses.

This file replaces `handoff-michelin-2026-hong-kong-macau-loaded-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rename method: `handoff-name-diffs-renamed-2026-10-30.md` (batch 29). Working rules and
database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 1)
- 11:06 open item 2 (HK/MO rename, R1-R5): build, examine read-only, show choices; no write before go.
- 11:25 "D1-D6: A": D1 Man Ho keep; D2 MONO keep; D3 Seventh Son Restaurant keep; D4 Tai Woo Restaurant keep;
  D5 Ye Shanghai (Tsim Sha Tsui) -> Yè Shanghai (Tsim Sha Tsui); D6 the 65 evidence lines as written.
- 11:31 "go" (rename file). 11:36 "go" (slug file).

## Live state (read Nov 1, 16:36:53 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,300 (active 10,935, closed 365) |
| awards | 23,368 (last id 30,135) |
| slugs | **13,001** (canonical 11,300, non-canonical **1,701**); venues with other than 1 canonical slug: 0 |
| listings / blurbs | 11,300 / 142 |
| rename_batches / rename_rows | **21** (last id **36**) / **1,277** |
| source_capture_ledger | **156** rows, last id **206** |
| audit_log | **115,921** rows, last id **121,259** |
| cities.venues_count | sum 10,935 |

## Done in this session
1. Start check 16:06 UTC: ledger 205, audit 121,095, venues 11,300, awards 23,368, slugs 12,952, cities sum 10,935 all matched.
   Repo attached with push access (clone `089c6fe`).
2. Population: 180 HK/MO 2026 cards = 180 venues; name differs on 86 (handoff said 87; the cleanup deleted one paired venue).
   8½ Otto e Mezzo HK + Macau excluded (named in batch 35 this morning). **84 venues.**
3. Card read (built-in browser, `fetch()` per card, 16:12 UTC): 84/84 status 200; h1 = Cowork capture name on 84; 49 cards have
   a website link, 35 none. File `docs/hkmo-2026-build/cards84-2026-11-01.tsv`.
4. Site read (WebFetch, 16:20-16:45 UTC): 43 of 49 read. Not read: chkspb.com, octavium.com.hk, octavo.com.hk (site error),
   chinatang.hk, instagram.com/shipkeehk (robots). New reading of R5: site in Chinese only = no English form = R5.
5. Evidence file `docs/hkmo-2026-build/name-diff-evidence-hkmo-2026-11-01.txt` (84 lines; after D1-D6: rename 66, keep 18).
6. Checks (read-only): 0 same-city norm_key collisions, 0 NULL keys, 0 slug in use, 0 redirect. Forum `ve_fe4ae32eec` has 1 blurb
   (status needs_rewrite); its text does not use the venue name.
7. **Rename** `docs/rename-michelin-2026-hong-kong-macau.sql` (sha256 `3cb5dc7a...e7ae7`): Write connector, first try, 16:34:02 UTC.
   Batch **36** `rename-michelin-2026-hong-kong-macau` applied; 66 rows (michelin 62, venue 4: lulu BAOBAO, Noi, Tasty Congee &
   Noodle Wantun Shop, VEA). Ledger **206** (michelin, name, 62). Audit **121,096-121,161**. Live id|name md5 = file new
   `54a197ce...0d20`.
8. **Slugs** `docs/slugs-rename-michelin-2026-hong-kong-macau.sql` (sha256 `c7078d97...5021`): Write connector, first try,
   ~16:36:40 UTC. 49 new canonical slugs, 17 keep. Audit **121,162-121,259** (49 UPDATE + 49 INSERT). Read-back fingerprint =
   plan `9e682a11...9966`. Old URLs still work (old slugs non-canonical).
9. Repo: `1d7fe12` (evidence), `970a373` (files built, not run), `125d750` (rename run record), plus this commit (slug run, handoff).
   Run record `docs/hkmo-2026-build/run-rename-2026-11-01.txt`. Build script `docs/hkmo-2026-build/build_rename_hkmo_2026_11_01.py`.

## Name notes
- Kept in capitals (R3, sites in capitals only): BELON, CHAAT, ÉPURE, MONO. Kept normal case where the site writes capitals only
  and our name was normal case: Din Tai Fung (HK), Sun Tung Lok Chinese Cuisine, Sushi Wadatsumi.
- 4 names follow the site, not the card: Noi (card "Noi by Paulo Airaudo"), VEA (card "Vea"), lulu BAOBAO, Tasty Congee & Noodle
  Wantun Shop (card "Tasty (Central)").
- Café Hunan -> Prof Chan's (card name; no site). Joël Robuchon -> L'Atelier de Joël Robuchon (straight apostrophe, site + card).
- Hung's Delicacies: U+2019 -> U+0027 (card, site). Part of the open apostrophe policy.

## Methods that worked (new)
- **Card website links in bulk:** one tab on guide.michelin.com, `fetch()` loop with `a[data-event*=website]`, 1.2 s pause;
  84 cards in about 4 minutes. Pull the result from the session transcript (`grab2.py` pattern: match the tool result by a marker).
- **Shorter rename dry run:** for a big VALUES block, a script copy of sections 1-2 without the note text (note guard off) and a
  final `RAISE EXCEPTION 'DRY RUN OK...'`. The full file is pasted only once, at the write.
- Leftover check in the slug build: a check word like "expected 66" can be legal when the new batch size is also 66; count it.

## Open items, smallest first
1. HK/MO name_native from `venue_name_zh` (180 rows; 0 HK/MO venues have name_native).
2. HK/MO price from the card (170 agree; differ: Rùn, Sun Tung Lok, Feuille; none: Ando, 6 new venues). With item 4.
3. Register: Xin Rong Ji twin `ve_4dc9197f86` (OAD 2025 No. 14) vs `ve_f966b7e0a1`; Mesa (2 Macau venues, Selected only);
   Chiu Chow Delicacies `ve_d7e57d1d84` status; HK Zuicho closed; 4 special awards (Young Chef Sol, Service The Huaiyang Garden,
   Sommelier Caprice, Mentor Chef Tin Lung Heen) -> special-awards batch.
4. D8: HK/MO 2025 history backfill from web.archive.org capture 20251229115831 (with the all-guides 2025 URL item).
5. Forum blurb (`needs_rewrite`): rewrite can now use the name "Forum".
6. Apostrophe policy (now also Hung's Delicacies, Prof Chan's, L'Atelier de Joël Robuchon, Lai's Kitchen: U+0027).
7. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); 2025 Green Star backfill; legacy price rows outside Turkey; 2025
   Michelin URLs all guides; Beverly Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov;
   Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-hkmo-renamed-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 206,
audit_log 121,259, venues 11,300, awards 23,368, slugs 13,001 and cities.venues_count sum 10,935. Then start open item 1
(HK/MO name_native from venue_name_zh): build the file, examine it read-only, and show me in /ste style with the choices.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
