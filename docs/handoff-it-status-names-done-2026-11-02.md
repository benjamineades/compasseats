# Handoff: Italy status and name pairs done (open items 3 and 6). Nov 2, 2026 (08:20 Atlanta).

This file replaces `handoff-it-2026-status-done-2026-11-02.md` for live state and open items. That handoff still holds the live-list method notes and the evidence for the 7 restaurants with no venue.
Italy 2025 methods: `handoff-it-2025-backfill-done-2026-11-02.md`. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md`. Selection-page method and heredoc trap: the Japan handoff.

## Ben's input (ET, Nov 2)
- 07:50 "Let's do 3&6".
- 08:06 "E1, U1, N1": E1 = Santa Elisabetta closed; U1 = Unforgettable holds until after Nov 12; N1 = rename 4 venues, Assonica keeps its name.
- 08:15 "Go". Committed.

## Live state (read Nov 2, 13:16:58 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,301 (active **10,937**, closed **364**) |
| awards | 25,085 (last id 32,024); Michelin 11,381 |
| IT Michelin One Star 2026 | 334 (article 341, gap 7 by decision) |
| slugs | **13,006** (non-canonical **1,705**) |
| listings / blurbs | 11,301 / 142 |
| price | 7,734 |
| rename_batches / rename_rows | **23** (last id **38**) / **1,282** |
| source_capture_ledger | **170** rows, last id **222** |
| audit_log | **118,077** rows, last id **123,591** |
| cities / venues_count | 3,262 / sum **10,937** |
| city_aliases / city_label_source | 266 / 24,001 |

## Done in this session
1. Start check: all counts = the status handoff.
2. **Run:** `docs/fix-michelin-2026-italy-status-names.sql` (sha256 `7f90e044...7a4cc783`). Santa Elisabetta `ve_e1339c5391` closed, status only (own site: "temporarily close Santa Elisabetta as it is today"; Florence 27). Rename batch 38 `rename-michelin-2026-italy-name-pairs-2026-11-02`: Il Desco `ve_b24b1c1085`, Iris Ristorante `ve_acdfd2daf5`, San Martino `ve_74d392b2d5` (R2), Atman `ve_48fe5153e8` (R5). Old slugs non-canonical; `vinci/atman` new. Ledger **222**. Audit **123,578-123,591**. Run record `docs/it-2026-build/run-fix-it-2026-status-names-2026-11-02.txt`.
3. No write: Assonica (site and card agree), Unforgettable (U1), Impronte (no closure evidence).

## Methods and notes (new)
- A guessed own-site domain can be another business: `ristoranteimpronte.it` is a restaurant in Piacenza. Take the site link from the card (`a[data-event*=website]`), or check the town.
- An archive card with a booking widget gives a TheFork link in the website selector, not the own site.
- Same slug on the same venue as a non-canonical row: flip it (old false first, then new true). No new row.

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Italy rechecks (status), after Nov 12 with the Italy 2027 list:** Wood `ve_b935a2a19a` (card "temporarily closed"), Peter Brunel `ve_dbe27febdc` (car crash May 2026, reopening planned September, card 404), Quattro Passi `ve_ee9dbbdba9` (new site late 2026 to spring 2027), Santa Elisabetta `ve_e1339c5391` (own site: temporarily closed), Unforgettable `ve_a006de1bf7` (active, closed since September, owners say November; hold, U1), Impronte `ve_6c4d801f2f` (active, card 404, no closure evidence), Il Circolino (no venue).
3. Agli Amici Dopolavoro `ve_5025ee0810`: open by press, card 404. Check the 2027 list.
4. Awards 23050 (Quattro Passi) and 23198 (Peter Brunel) hold card URLs that now give 404. No change made.
5. Closed venues with `listings.published = true`: all Italy closed venues are published, incl. Contaminazioni, Lido 84, Octavin, Atman, Santa Elisabetta. No change made. Ben to decide if needed.
6. Lido 84 city: database Gardone Riviera (own site, press); card Fasano del Garda. No change made.
7. **Japan 2025 missing sets (J1):** as in the Japan handoff item 2.
8. Japan legacy 2025 rows (10 left, no URL): cleanup list (Japan handoff item 3).
9. `ve_c0eba7ae71` "Naramachi Historic District" = Naramachi Kuko. Rename check.
10. **2025 Green Stars:** Spain (G1), France (U3), Italy (G1). No full list. Try new captures later.
11. Spain venue names that are a city name: BACK -> "Marbella" `ve_f29878f198`; Europa -> "Pamplona" `ve_c18fc53635`.
12. Spain card-paired venues with status closed but a 2026 One Star: SLOW&LOW `ve_18248f03f5`, Terra `ve_89ca903ac2`.
13. Moved restaurants (Y pairs, Spain): no action unless Ben wants a "previous location" note.
14. `ve_4e77c0295c` L'Auberge de Saint-Remy: city "Saint-Remy"; Michelin Saint-Remy-de-Provence.
15. Venues named after a hotel (France card pairs): France handoff item 4.
16. 2026 Green Star gap: Germany and the Netherlands 0 rows; France 11, Italy 2, Ireland 0; Japan 25 vs 33.
17. 2025 Green Star + URL backfill: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
18. Le Manoir `ve_7b865a33b7`: hotel suffix in the name, city Oxford (Michelin: Great Milton).
19. Legacy price rows: 2,380 legacy_guide rows remain.
20. `name_native` backfill: China 469, Japan 585, Chengdu 47.
21. Blurb rewrites: 141 `needs_rewrite`.
22. Rechecks and date gates: as in the Spain handoff items 16-17 (Italy 2027 after Nov 12; Tokyo etc. after Feb 16, 2027).

## Suggested opening prompt
```
Read claude/handoff-it-status-names-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 222,
audit_log 123,591, venues 11,301, awards 25,085, slugs 13,006, price 7,734 and cities.venues_count sum 10,937.
Then tell me in /ste style which small open items are ready to work before the Italy 2027 ceremony on Nov 12. Examine read-only.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
