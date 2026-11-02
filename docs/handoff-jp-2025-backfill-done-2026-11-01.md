# Handoff: Japan 2025 backfill done (item 4, guide 4 of 5, complete sets only). Nov 1, 2026 (21:56 Atlanta). Next: Italy 2025.

This file replaces `handoff-es-2025-backfill-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`. Working rules and database
notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md` (Methods section). Spain methods: the Spain handoff.

## Ben's input (ET, Nov 1)
- 21:50 "J1 & K1": J1 = load the complete page sets only (Green Stars of all 4 guides, Three Stars Tokyo / Kyoto / Osaka,
  Two Stars Kyoto / Osaka); the other sets wait. K1 = check Chugokusai Naramachi Kuko against its own site and the
  Michelin card first.
- 21:55 "Go" (committed).

## Live state (read Nov 2, 02:56:34 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | **24,713** (last id **31,652**); Michelin **11,009**; Michelin 2025 **4,633** (no URL **3,220**); Green Star 2025 **55** |
| JP Michelin 2025 | **81** (71 with an archive URL: Green Star 24, Three Stars 20, Two Stars 27; 10 legacy rows unchanged) |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 |
| source_capture_ledger | **165** rows, last id **217** |
| audit_log | **117,654** rows, last id **123,166** |
| cities / venues_count | 3,260 / sum 10,934 |

## Done in this session
1. Start check 02:13 UTC: all counts = the Spain handoff. Repo attached with push access (clone `c9e25f8`).
2. Archive search (built-in browser). The jp/ja article path word is `article` (same as English). The 3 Japan 2025
   ceremony articles list new and promoted restaurants only; they give the totals:
   Tokyo 2025 (Oct 17, 2024) 12 / 26 / 132, Green 12; Kyoto 2025 (Mar 27, 2025) 5 / 16 / 72, Green 10;
   Osaka 2025 (same date) 3 / 11 / 65, Green 3; Nara 2025 (May 14, 2025) 0 / 4 / 18, Green 7.
   Press releases (news.michelin.co.jp, prtimes.jp, michelin.com PDF): counts and new names only.
3. Region selection pages (20 cards per page). Complete sets (page total = article total): see
   `docs/jp-2025-build/sources-jp-2025-archive.txt`. Not found in 10 locales: Tokyo 2* and 1*, Nara 2* and 1*, Kyoto and
   Osaka 1* pages 2-4. Relay `docs/jp-2025-build/relay-jp-2025-archive-partial.txt` (119 lines incl. 40 One Star page-1
   lines, sha256 `ceab8dba...db99e1`).
4. K1: both Michelin cards (2025 `chugokusai-naramachi-kuko`, Kideracho; 2026 `naramachi-kuko`, Narukawacho) link
   `kuko-nara.jp`; the own site says Green Star 2022-2025. Paired to `ve_c0eba7ae71` (wrong name "Naramachi Historic
   District").
5. **Run** committed (Write connector, first try): awards 31583-31652 (70 INSERT), 1 URL fill (1291 SEZANNE).
   Ledger **217**. Audit **123,096-123,166**. File `docs/backfill-michelin-2025-japan.sql` (sha256 `167b13b5...01362b21`).
   Run record `docs/jp-2025-build/run-backfill-jp-2025-2026-11-02.txt`.
   Q1 skipped 8 (no venue): Noeud. TOKYO, ristorante DONO, Vegan Ramen UZU, Unkaku, AWA Naramachiten, Sanjuhachi,
   Kuramoto Ryori Maruto Shoyu, Kiyosuminosato AWA.

## Methods and notes (new)
- **Selection-page method** (when no full list article exists): CDX prefix per locale and per path
  (`<loc>/<r>-region/restaurants/` and `<loc>/<r>-region/<r>/restaurants/`). Real results are in
  `.js-restaurant__list_items`; `.js-restaurants__empty_items` holds 4 suggestion cards (ignore). The header
  (`Kyoto : 1-20 of 72 restaurants`) gives the page total. A set is complete only when page total = published total.
- Domain-wide CDX queries (`matchType=domain` with a regex filter) give 503 every time. Use many small prefix queries,
  one at a time, stored on `window`, polled (about 1 path per minute in a slow period).
- The workspace shell cannot reach web.archive.org (allowlist). All archive reads go through the browser.
- **Heredoc trap:** the tool layer turns `\uXXXX` text into real characters. After saving a relay, re-escape non-ASCII
  with Python and compare the hash with the browser hash.
- Japan 2026 card slugs: 585 slugs on 585 venues (1 venue per slug); a card match is safe.
- Archive confirms: Kohaku 2025 Three Stars (2026 Two Stars); Miyamaso 2025 Two Stars (2026 Three Stars); Muromachi Yui
  2025 One Star (2026 Two Stars).

## Item 4 progress (2025 history, N1, order P2)
| Guide | State | Source |
|---|---|---|
| Great Britain & Ireland | **Done** (230 rows) | GB&I handoff |
| France (with Monaco) | **Done, stars** (593 rows). Green Stars wait (U3). | France handoff |
| Spain (with Andorra) | **Done, stars** (282 rows). Green Stars wait (G1). | Spain handoff |
| Japan | **Done, complete sets** (71 rows). Tokyo 2*/1*, Nara 2*/1*, Kyoto/Osaka 1* wait (J1). | see above |
| Italy | Next. Source not found yet | gb/en has `the-michelin-guide-italy-2025-70th-anniversary-new-three-star`. Try it/it with `articolo`, then the selection-page method. |

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Japan 2025 missing sets (J1):** Tokyo Two Stars (26) and One Star (132), Nara Two Stars (4) and One Star (18), Kyoto
   One Star (72), Osaka One Star (65). One Star page 1 of Kyoto and Osaka is in the relay (40 lines: 37 card, Jiki Miyazawa
   `ve_381c397bd7` name-only, Gion Mamma and MUNI ALAIN DUCASSE no venue). Try again later (new captures) or other locales.
3. Japan legacy 2025 rows (10 left, no URL): Sukiyabashi Jiro Two Stars, Kabi and Bini One Star, 5 junk venues ("Tokyo",
   "Shinjuku City", "Tokyo Ramen Street", "Dialog in the Dark Japan", "Daimaru Shinsaibashi"), Konjiki Hototogisu and
   Soba-dokoro Kitahara Bib. Cleanup list.
4. `ve_c0eba7ae71` "Naramachi Historic District" = Naramachi Kuko (moved Kideracho -> Narukawacho). Rename check.
5. **Spain 2025 Green Stars (G1)** and **France 2025 Green Stars (U3):** no full list. Try the selection-page method.
6. Spain venue names that are a city name: BACK -> "Marbella" `ve_f29878f198`; Europa -> "Pamplona" `ve_c18fc53635`.
7. Spain card-paired venues with status closed but a 2026 One Star: SLOW&LOW `ve_18248f03f5`, Terra `ve_89ca903ac2`.
8. Moved restaurants (Y pairs, Spain): no action unless Ben wants a "previous location" note.
9. `ve_4e77c0295c` L'Auberge de Saint-Remy: database city "Saint-Remy"; Michelin Saint-Remy-de-Provence.
10. Venues named after a hotel (France card pairs): France handoff item 4.
11. 2026 Green Star gap: Germany and the Netherlands 0 rows for 2026; France 11, Italy 2, Ireland 0 (read Nov 1).
    Japan 2026 Green Star rows 25 vs the 2026 article totals (Tokyo 13, Kyoto 10, Osaka 3, Nara 7 = 33).
12. **Item 4 continued:** Italy next. One guide per session (S1).
13. 2025 Green Star + URL backfill: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
14. Le Manoir `ve_7b865a33b7`: hotel suffix in the name, city Oxford (Michelin: Great Milton).
15. Legacy price rows: 2,380 legacy_guide rows remain.
16. `name_native` backfill: China 469, Japan 585, Chengdu 47.
17. Blurb rewrites: 141 `needs_rewrite`.
18. Rechecks and date gates: as in the Spain handoff items 16-17 (Italy 2027 after Nov 12; Tokyo etc. after Feb 16, 2027).

## Suggested opening prompt
```
Read claude/handoff-jp-2025-backfill-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 217,
audit_log 123,166, venues 11,299, awards 24,713, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then continue item 4 with Italy 2025 (stars and Green Stars, card-link match): find a full 2025 list in the archive first
(it/it uses `articolo`; if no full article, use the selection-page method), examine read-only and show me in /ste style.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
