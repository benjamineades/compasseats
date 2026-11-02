# Handoff: Dialog in the Dark and Fanny rey merges done (G1, H1). Nov 2, 2026 (10:10 Atlanta).

This file replaces `handoff-open-items-a1-d1-done-2026-11-02.md` for live state and open items. That handoff still holds the A1, B1, C1, D1 results and the method notes.
Italy status and name evidence: `handoff-it-status-names-done-2026-11-02.md`. Italy live-list notes and the 7 restaurants with no venue: `handoff-it-2026-status-done-2026-11-02.md`. Italy 2025 methods: `handoff-it-2025-backfill-done-2026-11-02.md`. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md`. Selection-page method and heredoc trap: `handoff-jp-2025-backfill-done-2026-11-01.md`. Merge template: `docs/merge-dialogue-fanny-g1-h1-2026-11-02.sql`.

## Ben's input (ET, Nov 2)
- 09:09 "Fanny rey et jonathan wahid is the hotel that L'Auberge is at. Keep Gardone Riviera."
- 09:48 "G1, H1". 10:05 "Go". 10:08 "Ran" (SQL Editor).

## Live state (read Nov 2, 15:08:15 UTC, whole tables)
| Table | Count |
|---|---|
| venues | **11,296** (active **10,930**, closed **366**) |
| awards | 25,081 (last id 32,024); Michelin 11,377 |
| slugs | 13,008 (canonical 11,296, non-canonical **1,712**) |
| listings / blurbs | 11,296 / 142 |
| price | **7,729** (legacy_guide 2,375) |
| rename_batches / rename_rows | 24 (last id 39) / 1,285 |
| source_capture_ledger | **175** rows, last id **227** |
| audit_log | **118,153** rows, last id **123,667** |
| cities / venues_count | 3,263 / sum **10,930** |
| city_aliases / city_label_source | 266 / 23,993 |
| redirects | 9 |

## Done in this session
1. **Run:** `docs/merge-dialogue-fanny-g1-h1-2026-11-02.sql` (sha256 `4b34b7c5...156fc53a`). Ben, SQL Editor, 15:07:50 UTC. Ledger **225-227**. Audit **123,645-123,667** (23). Run record `docs/run-merge-dialogue-fanny-g1-h1-2026-11-02.txt`.
   - G1: deleted Dialog in the Dark Japan `ve_02074ec7f9` (a museum). Award 21913 (Michelin 2025 Bib, no URL) -> DIALOGUE `ve_0f8d54f738`. Award 21914 (Forbes 2020 Five-Star, no URL) -> new closed venue Dialogue `ve_1ceb1a3042`, `santa-monica/dialogue`.
   - H1: merged Fanny rey et jonathan wahid `ve_77657c7bbf` into L'Auberge de Saint-Rémy `ve_4e77c0295c`. Award 21248, 2 slugs (non-canonical) and 3 gault-millau labels moved.
2. No write: Lido 84 keeps Gardone Riviera (open item closed).

## Evidence gaps to keep in mind
- Award 21913: legacy row and card agree (Tokyo, French, Bib Gourmand, price level 2). No 2025 list found that names DIALOGUE. Check when the Tokyo 2025 Bib set is found.
- Award 21914: the Forbes 2019 list names Dialogue, Santa Monica, Five-Star. No 2020 list found that names it. Closed Nov 7, 2020 (Wikipedia).
- New venue Dialogue has no Michelin rows, although Wikipedia calls it Michelin-starred. Not in scope of this file.

## Methods and notes (new)
- **Write connector fault:** 4 calls today with a write file returned "client cancelled this confirmation" after 0.6-0.8 s. `SELECT 1` through the same connector returned a result. Do not change a file to avoid the confirmation. Go to the SQL Editor after a failure. Ben can check the Supabase Write `execute_sql` permission in the connector settings; the cause is not known.
- A string gate with `COLLATE "C"`: `saint-remy` sorts before `saint-remy-de-provence`. Read the value live before you write the expected text.
- Old legacy rows with one Google place in 2 cities can hide 2 restaurants. Read `docs/triage-final.csv` and `data/venues.json` first. `data/venues.json` holds the legacy award per city.

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Le Manoir** `ve_7b865a33b7`: name (hotel suffix; own site "Le Manoir aux Quat'Saisons") and city (Oxford; Michelin Great Milton, no city row). Status recheck in summer 2027 (D1).
3. **Italy rechecks (status), after Nov 12 with the Italy 2027 list:** Wood `ve_b935a2a19a`, Peter Brunel `ve_dbe27febdc`, Quattro Passi `ve_ee9dbbdba9`, Santa Elisabetta `ve_e1339c5391`, Unforgettable `ve_a006de1bf7` (hold, U1), Impronte `ve_6c4d801f2f`, Il Circolino (no venue). Details in the Italy status-names handoff.
4. Agli Amici Dopolavoro `ve_5025ee0810`: open by press, card 404. Check the 2027 list.
5. Awards 23050 (Quattro Passi) and 23198 (Peter Brunel) hold card URLs that gave 404. No change made.
6. Closed venues with `listings.published = true`: 345 published, 21 not (whole table). F1: no change before Nov 12. Ben to choose one rule later.
7. **Japan 2025 missing sets (J1):** as in the Japan handoff item 2.
8. Japan legacy 2025 rows (6 with no URL): Sukiyabashi Jiro Two Stars, Kabi and Bini One Star, DIALOGUE, Konjiki Hototogisu and Soba-dokoro Kitahara Bib.
9. **2025 Green Stars:** Spain (G1 of the Spain handoff), France (U3), Italy. No full list. Try new captures later.
10. Moved restaurants (Y pairs, Spain): no action unless Ben wants a "previous location" note.
11. Venues named after a hotel or with promotion text (France card pairs, 10 venues): France handoff item 4. Needs a read of the own sites, then a rename batch.
12. 2026 Green Star gap: Germany and the Netherlands 0 rows; France 11, Italy 2, Ireland 0; Japan 25 vs 33.
13. 2025 Green Star + URL backfill: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
14. Legacy price rows: 2,375 legacy_guide rows remain.
15. `name_native` backfill: China 469, Japan 585, Chengdu 47. Naramachi Kuko: own site 奈良町 枸杞.
16. Blurb rewrites: 141 `needs_rewrite`.
17. **Switzerland:** Michelin press (Oct 5, 2026) puts the ceremony on Nov 2, 2026 and says "für das Jahr 2026". The date gate opens now. Check the edition label (rule 2.1.7). Full guide block: new session.
18. Rechecks and date gates: as in the Spain handoff items 16-17 (Italy 2027 after Nov 12; Tokyo etc. after Feb 16, 2027).
19. RLS: Supabase reports no RLS on `award_categories`, `rename_batches`, `rename_rows`. Ben's open decision.

## Suggested opening prompt
```
Read claude/handoff-open-items-g1-h1-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 227,
audit_log 123,667, venues 11,296, awards 25,081, slugs 13,008, price 7,729 and cities.venues_count sum 10,930.
Then tell me in /ste style which small open items are ready to work before the Italy 2027 ceremony on Nov 12. Examine read-only.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
