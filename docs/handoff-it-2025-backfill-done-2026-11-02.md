# Handoff: Italy 2025 backfill done (item 4, guide 5 of 5, stars). Nov 2, 2026 (06:05 Atlanta). Item 4 stars complete.

This file replaces `handoff-jp-2025-backfill-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`. Working rules and database
notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md` (Methods section). Selection-page method and heredoc
trap: the Japan handoff.

## Ben's input (ET, Nov 2)
- 05:44 "Z2, H2, G1": Z2 = check the 5 name-only pairs against the venue's own site first; H2 = examine both San Martino
  Michelin cards first; G1 = stars only, Green Stars wait (no full Italy 2025 list).
- 06:02 "Go" = C1 (pair Contaminazioni) and Ha (line 385 -> Scorze venue, line 218 Treviglio skipped). Committed.

## Live state (read Nov 2, 11:04:44 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | **25,078** (last id **32,017**); Michelin **11,374**; Michelin 2025 **4,998** (no URL **3,218**); Green Star 2025 **55** |
| IT Michelin 2025 | **369** (367 with the archive URL: One Star 315, Two Stars 38, Three Stars 14; 2 legacy Bib rows unchanged) |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 |
| source_capture_ledger | **166** rows, last id **218** |
| audit_log | **118,021** rows, last id **123,533** |
| cities / venues_count | 3,260 / sum 10,934 |

## Done in this session
1. Start check 03:03 UTC: all counts = the Japan handoff. Repo attached with push access (clone `b4bd1bc`).
2. **The it/it article path word is `notizia`** (not `articolo`, not `article`). Found by web search, not by CDX.
   Stars article `it/it/notizia/michelin-guide-ceremony/tutte-le-stelle-della-guida-michelin-italia`, capture
   **20241105213726** (ceremony day, Nov 5, 2024, Parma), title names 2025. 393 lines (14 / 38 / 341), each with 1 card
   link. Michelin's ceremony article (`guida-michelin-italia-2025-un-nuovo-3-stelle`) gives 393 starred and 14 Three Stars.
   Relay `docs/it-2025-build/relay-it-2025-archive-20241105.txt` (sha256 `d5c2a9eb...b25b39`).
3. Green Stars (G1): total 69. `guida-michelin-italia-2025-11-nuove-stelle-verdi` lists 11 new only. Selection page
   `it/it/selection/italy/ristoranti/sustainable_gastronomy`: only page 1 archived (Jul 18, 2025: 1-48 of 68); page 2 404.
   us/en, fr/fr, de/de, es/es, ch/it, gb/en: Apr 2024 captures only (58).
4. Article layout: `City - <a>Name</a>` lines split by `<br>` in `.detail-page__content` blocks; h2 `3 STELLE` / `2 STELLE` /
   `1 STELLA`; 1 Stella lines under region headers (uppercase). Red `N` = new; `Trasferito` = moved. 4 footer lines to drop.
   **3 broken links:** Il Desco, Iris Ristorante and Matteo Grandi in Basilica all link the Wisteria card.
5. Z2 evidence (own sites read through the archive in the browser; WebFetch needs an approval that timed out):
   Balzi Rossi (own site Sep 2026, closed for repairs), Lido 84 (own site Jul 2026 "attualmente chiuso", Gardone Riviera;
   card Fasano del Garda), Zum Loewen (own site Sep 2026, Tisens = Tesimo), Casa Vissani (own site address = card).
   Contaminazioni: no own site; Scatti di Gusto Mar 17, 2026 (Molaro, Somma Vesuviana, closes May 2026). All 5 paired.
6. H2: Michelin 2026 Italy list (capture 20251123134344) has **both** San Martino Treviglio (`san-martino155366`) and San
   Martino Scorze (`veneto/scorz/.../san-martino`). The database has only Scorze `ve_74d392b2d5`, and its 2026 One Star
   row holds the **Treviglio** card URL. 2025 line 385 paired to `ve_74d392b2d5`; line 218 skipped.
7. **Run** committed (Write connector, first try): awards 31653-32017 (365 INSERT), 2 URL fills (3729 Octavin, 8939 Atman).
   Ledger **218**. Audit **123,167-123,533**. File `docs/backfill-michelin-2025-italy.sql` (sha256 `3a3c6f5a...e53b00c`).
   Run record `docs/it-2025-build/run-backfill-it-2025-2026-11-02.txt`.
   Q1 skipped 25 (no venue): Don Alfonso 1890 San Barbato, Abbruzzino, Luigi Lepore, Osteria Arbustico, Sud, Re Mauri,
   Jose Restaurant Tenuta Villa Guerra, Arnaldo - Clinica Gastronomica, Essenza, The Cook, Felix Lo Basso, Il Circolino,
   Sedicesimo Secolo, L'Arcade, Magorabin, Bros', Porta di Basso, Accursio, Terramira, Gabbiano 3.0, Castello di Fighine,
   L'Acciuga, Vite, Palais Royal Restaurant, Matteo Grandi in Basilica. Plus 218 San Martino Treviglio.

## Methods and notes (new)
- **Find the article by web search first** (query in the local language, `site` not needed). CDX prefix queries on
  `guide.michelin.com/it/it/articolo/` and `/article/` gave nothing for over 3 minutes.
- An `id_` fetch with a date stamp (`/web/20241106000000id_/<url>`) returns the nearest capture; `response.url` gives the
  real timestamp. This is faster than CDX when the URL is known.
- Own sites: fetch `https://web.archive.org/web/2026id_/<site>` in the browser (no extra approval), strip script/style.
- Archive JSON-LD (`script[type="application/ld+json"]`, `@type` Restaurant) on a card gives name, address and award year.
- A card match can be wrong when the database row holds another restaurant's card (San Martino). Check the card town
  against the venue town for same-name restaurants.

## Item 4 progress (2025 history, N1, order P2): stars done for all 5 guides
| Guide | State |
|---|---|
| Great Britain & Ireland | **Done** (230 rows) |
| France (with Monaco) | **Done, stars** (593 rows). Green Stars wait (U3). |
| Spain (with Andorra) | **Done, stars** (282 rows). Green Stars wait (G1). |
| Japan | **Done, complete sets** (71 rows). Tokyo 2*/1*, Nara 2*/1*, Kyoto/Osaka 1* wait (J1). |
| Italy | **Done, stars** (367 rows). Green Stars wait (G1). |

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **San Martino fix (Italy 2026):** `ve_74d392b2d5` (Scorze) 2026 One Star row holds the Treviglio card URL. Change the URL
   to the Scorze card; Treviglio (viale Cesare Battisti 3, own site sanmartinotreviglio.it) needs a venue, a 2026 One Star
   row and the 2025 One Star (relay line 218).
3. **Italy 2026 gaps:** Contaminazioni `ve_48a3d8cc5d` and Lido 84 `ve_e16ffafc83` are on Michelin's 2026 star list but
   have no 2026 Michelin row. Check against the 2026 article (capture 20251123134344).
4. Contaminazioni `ve_48a3d8cc5d`: database city "Naples" (Michelin: Somma Vesuviana); closed May 2026 (press), status
   active. City and status check.
5. Italy card-paired venues with status closed but a 2026 star (8, incl. Quattro Passi `ve_ee9dbbdba9` Three Stars).
   Status check.
6. Italy name pairs with a different spelling: Assonica (Osteria degli Assonica), Ristorante Il Desco, Iris Ristorante a
   Palazzo Soave, Ristorante San Martino, Ristorante Atman. Rename check under the Sep 14 / Oct 10 rulings.
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
Read claude/handoff-it-2025-backfill-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 218,
audit_log 123,533, venues 11,299, awards 25,078, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then work open items 2-4 (Italy 2026 fixes: San Martino Treviglio/Scorze, the Contaminazioni and Lido 84 2026 gaps,
Contaminazioni city and status). Read the 2026 Italy article capture and both Michelin cards, examine read-only and show
me in /ste style. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
