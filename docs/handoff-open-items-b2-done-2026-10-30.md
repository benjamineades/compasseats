# Handoff: Open items block 2 done (held URLs, status checks, Turkey follow-ups, Turkey city policy). Oct 30, 2026 (23:00 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-item-1-done-2026-10-30.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the Telluride city method: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 30, 2026)
- 21:24 ET: fresh count read, next-block options, repo with push access.
- 21:36 ET "1-4": items 1-4 of the list as one block.
- 22:14 ET "All recommended": D1-D9 = A (see Decisions).
- 22:37 ET "Go" (file 1, Write connector). 23:00 ET "Ran it" (file 2, Supabase SQL Editor).

## Live state (read Oct 31, 03:00 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,304 (closed **369**) |
| awards | 23,358 |
| price | **7,731** |
| slugs | **12,924** (canonical 11,304, non-canonical **1,620**); venues with other than 1 canonical slug: 0 |
| listings | 11,304 |
| cities / city_aliases / redirects | **3,259** / **265** / 9 |
| city_label_source | 24,005 |
| source_capture_ledger | last id **169** |
| audit_log | 113,757 rows, last id **119,041** |

## Decisions (Ben, Oct 30 22:14 ET, all A)
- D1 Chay Garden 10486: leave the 2025 URL empty, item closed (no 2025-edition card on vn/en, jp/en, sg/en, vn/vi, en,
  us/en; slug `chay-garden-xuan-hoa` has no captures; the Vietnam 2025 article names only new Bibs).
- D2 Nadair (Atlanta) `ve_fff5bda31e`: closed.
- D3 Dill (Lewes) `ve_b3825c7559`: closed, and archive URL on 2025 Bib row 10908.
- D4 Prices: Sankai INSERT TRY 4; Efendy and Lucien Arkas legacy `$$` -> TRY 2.
- D5 Efendy `ve_51ce2088a5`: stays active, recheck item closed (card removed after Jan 28, 2026; no closure news).
- D6 Unknown 2026 Turkey Bib (39 vs 38): item closed; check again with the 2027 Turkey edition. The archive holds no copy of
  the Turkey list in the 2026 window (only Jul 16, 2025).
- D7 Turkey city rule = **Michelin city (the city in the card URL)**, as the earlier Urla -> Izmir rule.
- D8 Aliases for town names only (alacati, yalikavak, sile); none for the province Mugla or the region Cappadocia.
- D9 Two files: file 1 Write connector, file 2 SQL Editor (DELETE).
- Sankai site spam: no website column in the database; no write; do not link to sankai.com.tr.

## Done in this session
1. Start check 01:25 UTC: ledger 167, audit 118,998, awards 23,358, slugs 12,915, city_aliases 262; all matched. Repo
   attached with push access (clone `42827fc`).
2. Reads: Michelin cards by WebFetch (10 Turkey cards, address lines) and by the built-in browser (`fetch()` in a
   guide.michelin.com tab: Nadair, Dill, Efendy 404; Turkey 2026 article). Archive index per card (19 calls, 1.2 s pause) and
   archive cards in a web.archive.org tab. Web: Rough Draft (Nadair, Jun 19, 2026), The Good Food Guide (Dill "Closed").
   Note: Chrome and the built-in browser were offline at first; WebFetch worked; the built-in browser came back later.
3. Build by script `docs/open-items-b2-build/build_open_items_b2_2026_10_30.py` from `relay-file1.txt` and
   `relay-file2.txt`. pglast parse OK. File 1 dry run (Read connector) stopped at the first write. File 2 pre-check test
   (today's audit id) found a logic error (the new city Fethiye was not yet present for the move check); fixed; second test
   passed. Repo commit `6484c55` (built, not run).
4. **File 1** (Write connector, first try, 02:38 UTC): ledger **168** (michelin, award, 2), **169** (michelin, price, 3);
   audit **118,999-119,005**: awards UPDATE 10493, 10908 (source_url only); venues UPDATE `ve_b3825c7559`, `ve_fff5bda31e`
   (status only); price INSERT `ve_f088b7a06a`; price UPDATE `ve_51ce2088a5`, `ve_f8013e6d34`.
5. **File 2** (Ben, SQL Editor, 02:59:50 UTC): audit **119,006-119,041** (36): cities INSERT 1 (`ci_99beff72d5` Fethiye,
   region aegean-coast), venues UPDATE 9 (city_id only), slugs UPDATE 9 + INSERT 9, cities DELETE 5, city_aliases INSERT 3
   (hand rows). No ledger row. Read-back matched every planned value.

## Results
| Venue | City before | City now | Canonical slug now |
|---|---|---|---|
| Bağarası `ve_1cb00fa293` | Muğla | Bodrum | bodrum/bagarasi |
| Mandalya `ve_18edcac317` | Muğla | Bodrum | bodrum/mandalya |
| Mezra Yalıkavak `ve_de05509e50` | Yalıkavak | Bodrum | bodrum/mezra-yalikavak |
| Mezegi `ve_0e1a18ca2d` | Muğla | Fethiye (new) | fethiye/mezegi |
| Revithia `ve_c98ccae6d0` | Cappadocia | Ürgüp | urgup/revithia |
| Babayan Evi Restaurant `ve_0b63b424aa` | Nevşehir | Ürgüp | urgup/babayan-evi-restaurant |
| Old Greek House `ve_6734eae626` | Nevşehir | Ürgüp | urgup/old-greek-house |
| Asma Yaprağı `ve_0d51fc7213` | Alaçatı | İzmir | izmir/asma-yapragi |
| Casa Lavanda `ve_5410da4251` | Şile | Istanbul | istanbul/casa-lavanda |

- Old slugs stay as non-canonical rows. Deleted cities: Alaçatı `ci_f0cc6ecedc`, Şile `ci_e28a7ec482`, Muğla
  `ci_b74d2bda8d`, Cappadocia `ci_341c9da864`, Yalıkavak `ci_cd59e06736` (full old rows in audit). Nevşehir keeps Happena.
- Aliases: alacati -> İzmir, yalikavak -> Bodrum, sile -> Istanbul. Labels "Muğla" and "Cappadocia" now resolve to no city.
- Kitchen by Osman Sezener stays in Bodrum (card: "Yalıkavak, Bodrum").
- Turkey now has 9 cities: Antalya, Bodrum 8, Fethiye 1, Istanbul 37, İzmir 13, Milas, Nevşehir 1, Niğde, Ürgüp 4.

## Evidence (card address lines, read Oct 31)
Kitchen by Osman Sezener "…Yalıkavak, Bodrum, 48400"; Mezra Yalıkavak "…Bodrum, 48990"; Bağarası "Bitez…, Bodrum";
Mandalya "Güvercinlik, Bodrum"; Mezegi "Göcek, Fethiye"; Revithia "…Ürgüp"; Babayan Evi "İbrahimpaşa, Ürgüp"; Old Greek
House "Mustafapaşa, Ürgüp"; Casa Lavanda "…Şile, Istanbul" (card URL city istanbul); Asma Yaprağı "Alaçatı…, Çeşme, Izmir"
(card URL city izmir). Archive cards: Hồng Phát (District 3) 20250908053336 vn/en (2025 Vietnam, dateAwarded 2025); Dill
20250805095033 gb/en (2025 UK, dateAwarded 2025); Efendy 20260106015516 en (₺₺, CAT_P02); Nadair last card 20251212 ("a
MICHELIN restaurant").

## Methods that worked (new)
- **Pre-check test before a city move into a new city:** allow the target city by its planned id and slug, because the city
  row is created later in the same file.
- **WebFetch for card address lines** when no browser is reachable (one approval per site).

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/open-items-b2-status-price-url-2026-10-30.sql` (158 lines) | Run (ledger 168-169, audit 118,999-119,005) | `16ecd3ade1b4f532b01a1b1a5f334b2f69c94aa3c5915c225fe90123332ebd5a` |
| `docs/cities-turkey-michelin-city-2026-10-30.sql` (313 lines) | Run in SQL Editor (audit 119,006-119,041) | `1a5d5b3c7bd636ea1e066271907d0e758c922d24b359d5d7dfb494f0961c8269` |
| `docs/open-items-b2-build/relay-file1.txt` | Input | `0ea57841c2b428f06eaf0e93c494c7d696f04091d2d191192c750eca8643657b` |
| `docs/open-items-b2-build/relay-file2.txt` | Input | `5b0c1f6d0dce18aadda81437b6033a03c29ff6e0eff208a00f4e86b06c2a33dc` |
| `docs/open-items-b2-build/build_open_items_b2_2026_10_30.py` | Build | (see repo commit) |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. **New: venue named "Istanbul"** `ve_a19227e5fa` (Istanbul): only Best Chef Awards 2024 and 2025 1-Knife rows, slug
   istanbul/istanbul. Probably a chef or restaurant name lost in the load. Read the Best Chef source and name it or merge it.
2. **New: slugs that drop the letter ı.** 12 venues (all Turkey) have a canonical slug made by the old rule, which dropped
   "ı" (for example istanbul/karakoy-lokantas, istanbul/parvus-kalam-s, bodrum/otantik-ocakbas). The live slug rule now gives
   "i". Population: 316 venues in all have a canonical slug that is not the slug rule of the live name (many are kept on
   purpose, for example the Oct 30 reuse cases). Ben decides: fix the 12 (new canonical, old non-canonical) or leave.
3. Held-P2 items: 5 city changes; 15 P2 venues that left the guide.
4. Merge and award cleanup: La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy; Duddell's (Hong Kong) possible duplicate `ve_a3512f9a51` /
   `ve_f88a5d9dc2`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved.
5. `cities.venues_count` recount: 375 cities differed (read Oct 30). After this block also: Bodrum 5 vs 8, Istanbul 33 vs 37,
   İzmir 12 vs 13, Nevşehir 3 vs 1, Ürgüp 1 vs 4. Ben decides.
6. 2025 Green Star backfill, all guides (California 2025: 13 of 17 still missing).
7. 2025 Michelin URLs, all guides (about 3,461 rows without a URL).
8. Heritage (Long Beach) 2024 One Star + Green Star (archive card, dateAwarded 2024); no 2024 rows.
9. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
   Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found;
   Florida 2026 Green Stars article not found; Turkey 2027 edition (check the unknown 2026 Bib then).
10. Write connector prompt closes by itself on DELETE files; SQL Editor route works (again this session).
11. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.
12. 38 Turkey legacy price rows -> now 36 (Efendy and Lucien Arkas done); P2 price batch.

## Suggested opening prompt
```
Read claude/handoff-open-items-b2-done-2026-10-30.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 169,
audit_log 119,041, cities 3,259, city_aliases 265 and slugs 12,924. Then show me the next-block options in /ste style
(the open items, smallest first, with what each needs from me) and wait for my choice. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
