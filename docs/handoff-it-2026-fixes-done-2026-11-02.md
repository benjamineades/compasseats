# Handoff: Italy 2026 fixes done (open items 2-4). Nov 2, 2026 (06:50 Atlanta).

This file replaces `handoff-it-2025-backfill-done-2026-11-02.md` for live state and open items. That handoff still holds the
Italy 2025 methods. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md`. Selection-page method and heredoc trap: the Japan handoff.

## Ben's input (ET, Nov 2)
- 06:25 "S1, G1, C1, X1": S1 = new Treviglio venue, award 23163 moves to it, new Scorze row; G1 = add 2026 rows for Contaminazioni and Lido 84;
  C1 = Contaminazioni to Somma Vesuviana, status closed; X1 = the other 10 article-only restaurants stay open (item 2 below).
- 06:45 "Go". Committed.

## Live state (read Nov 2, 11:48:41 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,300 (active 10,934) |
| awards | **25,082** (last id **32,021**); Michelin **11,378**; Michelin 2025 **4,999** |
| IT Michelin One Star | 2026 **331** (article 341); 2025 **316** |
| slugs | 13,004 (non-canonical 1,704) |
| listings / blurbs | 11,300 / 142 |
| price | 7,734 |
| source_capture_ledger | **168** rows, last id **220** |
| audit_log | **118,040** rows, last id **123,554** |
| cities / venues_count | 3,262 / sum 10,934 |
| city_aliases / city_label_source | 266 / 23,999 |

## Done in this session
1. Start check: all counts = the Italy 2025 handoff. Repo attached with push access (clone `ac1fe69`).
2. Article `it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia-2026`, capture **20251123134344**. 394 lines = 15 / 38 / 341 = ceremony counts.
   Relay `docs/it-2026-build/relay-it-2026-archive-20251123.txt` (sha256 `d754b751...777d073`). 3 links point to another card (Impronte, Prezioso, La Torre). 2 empty repeat links dropped (Il Convivio Troiani, Acqua).
3. **San Martino cause:** alias `treviglio` -> Scorze sent fixture line 128 to Scorze; line 214 failed as `duplicate_in_batch`; the Sep 16 merge moved award 23163 to `ve_74d392b2d5`. Origin of the alias not found.
4. **Run:** new cities Treviglio `ci_50a360bb5d`, Somma Vesuviana `ci_ff2387962a`. New venue San Martino `ve_2ed5af2056`. Award 23163 moved. New awards 32018 (Treviglio 2025), 32019 (Scorze 2026), 32020 (Contaminazioni 2026, article URL), 32021 (Lido 84 2026, card capture 20260207070145). Treviglio price row; Scorze price source changed. Labels 22976, 22977 moved. Alias `treviglio` -> new city. Contaminazioni `ve_48a3d8cc5d` moved to Somma Vesuviana, closed; old slug non-canonical. Naples count 9.
   Ledger **219** (award, 5), **220** (price, 2). Audit **123,536-123,554**. File `docs/fix-michelin-2026-italy-san-martino-gaps.sql` (sha256 `a57c8c81...da27d3f`). Run record `docs/it-2026-build/run-fix-it-2026-2026-11-02.txt`.

## Methods and notes (new)
- `venues.norm_key` is a generated column. Do not name it in an INSERT. The dry run stops before this error can show, so run 1 failed and rolled back.
- A failed transaction still uses audit ids (123,534-123,535 have no rows). Gate on the count and on ids above the max, not on a fixed id range.
- `Response.url` is rewritten by the archive script on a normal archive page. Fetch from `web.archive.org/robots.txt` (a 404 page with no script) to see the real timestamp URL.
- Article parse: read the text node before each link. Do not strip a leading N: Napoli, Noli, Nola, Noto and Norcia lost a letter in a first attempt. Escape `|` in names. The region header `VALLE D’AOSTA` has a curly apostrophe.
- Same heredoc trap with the Write tool: `\u007c` became `|`. Re-escape and compare the hash, or compare per-line hashes with the browser.
- A closed restaurant leaves the live Michelin list, so a capture made later than the ceremony (the Sep 2026 fixture) misses it. The ceremony article shows the full edition.

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Italy 2026 One Star gap of 10 (X1):** article 341, database 331. Octavin `ve_df6d5db906` and Atman `ve_48fe5153e8`: 2025 row only, venue active, live card 404, so a status check and a 2026 row. Agli Amici Dopolavoro and 7 from the Q1 skip list have no venue: Don Alfonso 1890 San Barbato, Il Circolino, Sedicesimo Secolo, Gabbiano 3.0, Castello di Fighine, Palais Royal Restaurant, Matteo Grandi in Basilica. Decide on new venues. Article URL: the ledger 219 job.
3. Italy card-paired venues with status closed but a 2026 star (8, incl. Quattro Passi `ve_ee9dbbdba9` Three Stars). Status check. Contaminazioni and Lido 84 now also hold a 2026 star and are correctly closed (population 10).
4. Italy name pairs with a different spelling: Assonica (Osteria degli Assonica), Ristorante Il Desco, Iris Ristorante a Palazzo Soave, Ristorante San Martino, Ristorante Atman. Rename check under the Sep 14 / Oct 10 rulings.
5. Closed venues Contaminazioni and Lido 84 have `listings.published = true`. No change made. Ben to decide if needed.
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
Read claude/handoff-it-2026-fixes-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 220,
audit_log 123,554, venues 11,300, awards 25,082, slugs 13,004, price 7,734 and cities.venues_count sum 10,934.
Then work open items 2-3 (the Italy 2026 One Star gap of 10, and the 8 closed Italy venues with a 2026 star). Examine read-only and
show me in /ste style. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
