# Handoff: Small open items A1, B1, C1, D1 done. Nov 2, 2026 (08:55 Atlanta).

This file replaces `handoff-it-status-names-done-2026-11-02.md` for live state and open items. That handoff still holds the Italy status and name evidence.
Italy live-list notes and the 7 restaurants with no venue: `handoff-it-2026-status-done-2026-11-02.md`. Italy 2025 methods: `handoff-it-2025-backfill-done-2026-11-02.md`. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md`. Selection-page method and heredoc trap: `handoff-jp-2025-backfill-done-2026-11-01.md`. City-split template: `docs/cities-telluride-fix-2026-10-30.sql`.

## Ben's input (ET, Nov 2)
- 08:31 "A1 and B1, then close item 12. C1, D1, F1".
- 08:37 "Go". 08:42 "Try again" (Write connector). 08:51 "Ran" (SQL Editor).
- A1 = Naramachi Kuko, BACK, Europa. B1 = delete 4 junk venues, hold Dialog in the Dark Japan. C1 = split Saint-Rémy, hold the duplicate question. D1 = Le Manoir closed, recheck in 2027. F1 = closed venues stay as they are before Nov 12.

## Live state (read Nov 2, 13:51:27 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,297 (active **10,932**, closed **365**) |
| awards | 25,081 (last id 32,024); Michelin 11,377; Michelin 2025 4,995 (no URL 3,214) |
| slugs | **13,008** (canonical 11,297, non-canonical **1,711**) |
| listings / blurbs | 11,297 / 142 |
| price | 7,730 |
| rename_batches / rename_rows | **24** (last id **39**) / **1,285** |
| source_capture_ledger | **172** rows, last id **224** |
| audit_log | **118,130** rows, last id **123,644** |
| cities / venues_count | 3,263 / sum **10,932** |
| city_aliases / city_label_source | 266 / 23,993 |
| redirects | 9 |

## Done in this session
1. Start check: all counts = the Italy status-names handoff.
2. **Run:** `docs/fix-open-items-a1-b1-c1-d1-2026-11-02.sql` (sha256 `5aa2a7b1...0bf82863f`). Ben, SQL Editor, 13:50:53 UTC. Ledger **223-224**. Audit **123,592-123,644** (53). Run record `docs/run-fix-open-items-a1-b1-c1-d1-2026-11-02.txt`.
   - A1, batch 39: Naramachi Kuko `ve_c0eba7ae71`, BACK `ve_f29878f198`, Europa `ve_c18fc53635` (R2). Old slugs non-canonical.
   - B1: deleted Tokyo `ve_060efda1ae`, Shinjuku City `ve_7b85d0d345`, Tokyo Ramen Street `ve_2593b20be1`, Daimaru Shinsaibashi `ve_d8c9373112`. Award ids 12689, 12648, 12673, 7091. Old URLs give a 404.
   - C1: new city `ci_931967f233` Saint-Rémy-de-Provence (region Provence, 3 venues). `ci_76107a3a0c` Saint-Rémy now has region Burgundy and 1 venue, Cédric Burtin. The alias moved.
   - D1: Le Manoir `ve_7b865a33b7` closed, status only. Oxford count 0.
3. No write: item 12 closed (SLOW&LOW by press; Terra by own site, "Este 27 de septiembre será nuestro último servicio", no year on the page). F1: closed venues published 344, not published 21.

## Methods and notes (new)
- **Write connector fault:** 3 calls with this file returned "client cancelled this confirmation" after 0.7-0.8 s. `SELECT 1` through the same connector returned a result. Do not split or change a file to avoid the confirmation. Offer the SQL Editor route after the second failure. Oct 30 had the same fault.
- A city row can hold 2 towns. Before a change to a city display name, read the card URL of each venue in the city. Check the region too: a split can leave the old row in the wrong region.
- Keep `city_venue_counts` equal to `cities.venues_count` in a venue delete, a move and a status change. The file gates on this before and after.
- `guide.michelin.com` cards opened through WebFetch on Nov 2. A cached card can be old: the Le Manoir card still showed Two Stars. Check the current edition with another source.
- `hreuropa.com` gives a verification page. `hoteleuropapamplona.com` opens.

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Duplicate question (C1):** "Fanny rey et jonathan wahid" `ve_77657c7bbf` (1 Gault-Millau 2021 row, Grand de Demain) and L'Auberge de Saint-Rémy `ve_4e77c0295c`. The card slug of L'Auberge has the same chef names. Ben decides.
3. **Dialog in the Dark Japan** `ve_02074ec7f9`: Michelin 2025 Bib (no URL) and Forbes 2020 Five-Star (no URL). Held in B1. Ben decides.
4. **Le Manoir** `ve_7b865a33b7`: name (hotel suffix; own site "Le Manoir aux Quat'Saisons") and city (Oxford; Michelin Great Milton, no city row). Status recheck in summer 2027 (D1).
5. **Italy rechecks (status), after Nov 12 with the Italy 2027 list:** Wood `ve_b935a2a19a`, Peter Brunel `ve_dbe27febdc`, Quattro Passi `ve_ee9dbbdba9`, Santa Elisabetta `ve_e1339c5391`, Unforgettable `ve_a006de1bf7` (hold, U1), Impronte `ve_6c4d801f2f`, Il Circolino (no venue). Details in the Italy status-names handoff.
6. Agli Amici Dopolavoro `ve_5025ee0810`: open by press, card 404. Check the 2027 list.
7. Awards 23050 (Quattro Passi) and 23198 (Peter Brunel) hold card URLs that gave 404. No change made.
8. Closed venues with `listings.published = true`: 344 published, 21 not (whole table). F1: no change before Nov 12. Ben to choose one rule later.
9. Lido 84 city: database Gardone Riviera (own site, press); card Fasano del Garda. Proposed: keep, no write. Ben has not confirmed.
10. **Japan 2025 missing sets (J1):** as in the Japan handoff item 2.
11. Japan legacy 2025 rows (6 left, no URL): Sukiyabashi Jiro Two Stars, Kabi and Bini One Star, Dialog in the Dark Japan, Konjiki Hototogisu and Soba-dokoro Kitahara Bib. Do not delete: these are not place-name venues, except Dialog (item 3).
12. **2025 Green Stars:** Spain (G1), France (U3), Italy (G1). No full list. Try new captures later.
13. Moved restaurants (Y pairs, Spain): no action unless Ben wants a "previous location" note.
14. Venues named after a hotel or with promotion text (France card pairs, 10 venues): France handoff item 4. Needs a read of the own sites, then a rename batch.
15. 2026 Green Star gap: Germany and the Netherlands 0 rows; France 11, Italy 2, Ireland 0; Japan 25 vs 33.
16. 2025 Green Star + URL backfill: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
17. Legacy price rows: 2,380 legacy_guide rows before B1 (4 deleted; read again).
18. `name_native` backfill: China 469, Japan 585, Chengdu 47. Naramachi Kuko: own site 奈良町 枸杞.
19. Blurb rewrites: 141 `needs_rewrite`.
20. **Switzerland:** Michelin press (Oct 5, 2026) puts the ceremony on Nov 2, 2026 and says "für das Jahr 2026". The date gate opens now. Check the edition label (rule 2.1.7). Full guide block: new session.
21. Rechecks and date gates: as in the Spain handoff items 16-17 (Italy 2027 after Nov 12; Tokyo etc. after Feb 16, 2027).
22. RLS: Supabase reports no RLS on `award_categories`, `rename_batches`, `rename_rows`. Ben's open decision.

## Suggested opening prompt
```
Read claude/handoff-open-items-a1-d1-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 224,
audit_log 123,644, venues 11,297, awards 25,081, slugs 13,008, price 7,730 and cities.venues_count sum 10,932.
Then tell me in /ste style which small open items are ready to work before the Italy 2027 ceremony on Nov 12. Examine read-only.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
