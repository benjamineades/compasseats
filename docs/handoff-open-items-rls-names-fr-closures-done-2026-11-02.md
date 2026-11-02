# Handoff: RLS on, 8+3 names, Naramachi native, France 2026 gap, 9 closures done. Nov 2, 2026 (11:30 Atlanta).

This file replaces `handoff-open-items-g1-h1-done-2026-11-02.md` for live state and open items. That handoff still holds the G1 and H1 results and evidence gaps.
Earlier chain: `handoff-open-items-a1-d1-done-2026-11-02.md`. Italy status and name evidence: `handoff-it-status-names-done-2026-11-02.md`. Italy live-list notes and the 7 restaurants with no venue: `handoff-it-2026-status-done-2026-11-02.md`. Italy 2025 methods: `handoff-it-2025-backfill-done-2026-11-02.md`. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`. Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md`. France article layout: `handoff-fr-2025-backfill-done-2026-11-01.md`.

## Ben's input (ET, Nov 2)
- 10:21 "1A, 2A, 3A, 4A, 5A": 1A = RLS on; 2A = Le Manoir new name, city stays Oxford; 3A = rename the France 7; 4A = Naramachi native; 5A = read the 12 French venues, read-only.
- 10:34 "Go RLS, Go both. 3A": 3A here = add 11 missing 2026 rows, rename the 3 held venues, hold Pierre and Maison Hache.
- 11:12 "S1, Go France": S1 = close 9 venues, Galanga and La Table de l'Alpaga stay active with a recheck.
- 11:27 "Go".

## Live state (read Nov 2, 16:28:17 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,296 (active **10,921**, closed **375**) |
| venues with `name_native` | **339** |
| awards | **25,092** (last id **32,035**); Michelin **11,388** |
| France and Monaco Michelin 2026 star rows | **666** (Michelin list 668) |
| slugs | **13,016** (canonical 11,296, non-canonical **1,720**) |
| listings / blurbs | 11,296 / 142 |
| price | 7,729 (legacy_guide 2,375) |
| rename_batches / rename_rows | **26** (last id **41**) / **1,296** |
| source_capture_ledger | **178** rows, last id **230** |
| audit_log | **118,214** rows, last id **123,728** |
| cities / venues_count | 3,263 / sum **10,921** (0 cities differ from the view) |
| city_aliases / city_label_source | 266 / 23,993 |
| redirects | 9 |
| closed venues with `listings.published` | true **354**, false 21 |
| public tables with RLS | on **24**, off 0; policies 0 |

## Done in this session (all Write connector, first try; run record `docs/run-rls-names-native-2026-11-02.txt`)
1. **RLS** `docs/rls-three-tables-2026-11-02.sql` (sha256 `ac158e83...4589d4`). On for `award_categories`, `rename_batches`, `rename_rows`. No policy. No audit row. `postgres` and `supabase_read_only_user` bypass RLS. Open item 19 closed. The file is in `docs/`, not in `supabase/migrations`: a rebuild from migrations does not hold this change.
2. **Names and native** `docs/fix-open-items-names-native-2026-11-02.sql` (sha256 `661dc83e...fd19`). Batch 40, ledger 228, audit 123,668-123,692.
   Le Manoir aux Quat’Saisons `ve_7b865a33b7` (U+2019, Belmond h1; Oxford, closed); La Palmeraie `ve_d1cccaafdf`; La Chapelle `ve_7963871c91`; La Passagère `ve_ee898a4ee3`; René et Maxime Meilleur `ve_a8d9697131`; Les Explorateurs `ve_eb0dbfc986`; La Côte d'Or `ve_2e35f20ae1`; Restaurant Girardin `ve_634228e9d5`. Naramachi Kuko `ve_c0eba7ae71` native 奈良町 枸杞.
3. **France 2026 list read** relay `docs/fr-2026-list-read/relay-fr-2026-article-2026-11-02.txt` (sha256 `7e8935fa...346f`): 668 lines (31 / 84 / 553). Database had 655. 603 pair by card link, 52 by city and name. 13 lines had no row.
4. **France rows and names** `docs/fix-fr-2026-list-11-rows-3-names-2026-11-02.sql` (sha256 `f492885a...d23a`). 11 Michelin 2026 rows (ids to 32,035; source = the list article), ledger 229. Batch 41, ledger 230: La Flibuste `ve_e1bffb1188`, La Table de l'Alpaga `ve_68ad93cad4`, Le Sarkara `ve_95253d6c9e`. Audit 123,693-123,712.
5. **9 closures** `docs/fix-status-fr-closed-9-2026-11-02.sql` (sha256 `bb8a9370...6603`). Status only, 7 city counts, no ledger row. Audit 123,713-123,728.
   L'Observatoire du Gabriel `ve_492797f355`, Le Sarkara `ve_95253d6c9e`, La Scene Theleme `ve_b2c6b30c6e`, Maison Dubois `ve_54915423d1`, Restaurant Pages `ve_3bb332e0ec`, Jean-Luc Tartarin `ve_ef978b8a59`, Les Voiles d'Or `ve_63aed2ba90`, Ivan Vautier `ve_1fa87032fe`, La Flibuste `ve_e1bffb1188`. Evidence is in the file header.

## Evidence gaps to keep in mind
- Le Sarkara: press says "Fermeture définitive"; the K2 site still shows hours. La Scene Theleme: press does not say "permanent". Bouillantes text behind a paywall (intro only).
- 3 of these venues keep a legacy name: Galanga par Monsieur George (list: Galanga), La Scene Theleme (list: La Scène Thélème), Restaurant Pages (list: Pages). No rename made.
- Caen, Villeneuve-Loubet and Oxford now have 0 active venues.

## Methods and notes (new)
- **A Michelin card 404 is a closure signal.** 13 of the 13 lines with no row give a 404 in `fr/fr`, `us/en` and `en`; control cards give 200. A guide file built from cards can miss a restaurant that closed before the capture. Compare the full list article to the database, not only the cards.
- **Same-origin fetch for cards:** from a tab on guide.michelin.com, `fetch('/en/...')` plus `DOMParser`. `h1` gives the exact letters, with code points for apostrophes. `a[data-event*=website]` now gives a TheFork link, so filter external links for the own site.
- A large browser result is saved to `tool-results/`. Parse that file by script (`docs/fr-2026-list-read/cmp.py`); line breaks in it are the text `\n`.
- **Python trap:** `'La Côte d''Or'` in Python joins 2 strings and gives `La Côte dOr`. Use double quotes round SQL text that holds `''`. The check found this before the dry run; keep a `grep` for the broken form.
- A slug row can already exist as non-canonical on the same venue: update it to canonical, do not insert.
- `cities` updates write audit rows (`cities:UPDATE`). Keep them in the audit gate.
- The Write connector worked 3 of 3 today after the morning fault. The cause of the fault is still not known.
- `chateauvalmer.com` was refused in the built-in browser; WebFetch opened it. Bouillantes and `lek2palace.com` open through WebFetch.

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **France 2026, 2 lines with no venue:** Pierre (Mâcon) and Maison Hache (Eygalières), One Star, cards give a 404, no city row. Read for closures first. Maison Hache is in the 2025 relay too.
3. **Jean Imbert au Plaza Athénée** `ve_36022e9b0a` (Michelin 2025 One Star, Gault-Millau 2023): probable twin of La Grande Table du Plaza Athénée `ve_ab17ada0da` (Michelin 2026 One Star). Michelin list line: Jean Imbert au Plaza Athénée. Merge question for Ben.
4. **Recheck:** Galanga `ve_72f235f057` and La Table de l'Alpaga `ve_68ad93cad4`: cards give a 404, no closure found.
5. **Same gap in other guides?** No other guide was compared to its full list in this way. Candidate check before Nov 12: venues with a 2025 star and no 2026 row, by guide. Population not read.
6. Le Manoir: status recheck in summer 2027 (D1). City stays Oxford (Ben 2A).
7. **Italy rechecks (status), after Nov 12 with the Italy 2027 list:** Wood `ve_b935a2a19a`, Peter Brunel `ve_dbe27febdc`, Quattro Passi `ve_ee9dbbdba9`, Santa Elisabetta `ve_e1339c5391`, Unforgettable `ve_a006de1bf7` (hold, U1), Impronte `ve_6c4d801f2f`, Il Circolino (no venue). Details in the Italy status-names handoff.
8. Agli Amici Dopolavoro `ve_5025ee0810`: open by press, card 404. Check the 2027 list.
9. Awards 23050 (Quattro Passi) and 23198 (Peter Brunel) hold card URLs that gave 404. No change made.
10. Closed venues with `listings.published = true`: 354 published, 21 not (whole table). F1: no change before Nov 12. Ben to choose one rule later.
11. **Japan 2025 missing sets (J1):** as in the Japan handoff item 2.
12. Japan legacy 2025 rows (6 with no URL): Sukiyabashi Jiro Two Stars, Kabi and Bini One Star, DIALOGUE, Konjiki Hototogisu and Soba-dokoro Kitahara Bib.
13. **2025 Green Stars:** Spain (G1 of the Spain handoff), France (U3), Italy. No full list. Try new captures later.
14. Moved restaurants (Y pairs, Spain): no action unless Ben wants a "previous location" note.
15. Other France legacy names: Les Fresques `ve_e574aeb7fd`, Restaurant Les Oliviers - 1* au Guide Michelin `ve_91143eac6a`, Galanga, La Scene Theleme, Restaurant Pages. Not read in this session.
16. 2026 Green Star gap: Germany and the Netherlands 0 rows; France 11, Italy 2, Ireland 0; Japan 25 vs 33.
17. 2025 Green Star + URL backfill: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
18. Legacy price rows: 2,375 legacy_guide rows remain.
19. `name_native` backfill: China 469, Japan 585, Chengdu 47 (figures not read again; Naramachi Kuko done).
20. Blurb rewrites: 141 `needs_rewrite`.
21. **Switzerland:** Michelin says "Am 2. November ... Restaurantauswahl für das Jahr 2026" (Andermatt), so the edition label is 2026. Results not found in the Nov 2 read. Database: 243 Swiss venues, 226 Michelin rows, all labeled 2025 with no URL. Full guide block: new session.
22. Rechecks and date gates: as in the Spain handoff items 16-17 (Italy 2027 after Nov 12; Tokyo etc. after Feb 16, 2027).

## Suggested opening prompt
```
Read claude/handoff-open-items-rls-names-fr-closures-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 230,
audit_log 123,728, venues 11,296 (active 10,921), awards 25,092, slugs 13,016, price 7,729 and cities.venues_count sum 10,921.
Then start Switzerland (open item 21): find the 2026 results from guide.michelin.com, read the Swiss legacy rows, and tell me
in /ste style which rules apply and what the promote and cleanup will need. Ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
