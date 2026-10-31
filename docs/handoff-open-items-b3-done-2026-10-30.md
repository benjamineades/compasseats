# Handoff: Open items block 3 done (Istanbul -> TURK merge, 12 Turkey slugs, Heritage 2023/2024). Oct 30, 2026 (23:40 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b2-done-2026-10-30.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the Telluride city method: `handoff-open-items-b1-done-2026-10-30.md`.
Turkey city rule (D7, Michelin city) and the block 2 record: `handoff-open-items-b2-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 30, 2026)
- 23:04 ET: fresh count read, next-block options, repo with push access.
- 23:05 ET "Let's do your recommendation": items 1, 2 and 3 of the b2 list as one block.
- 23:11 ET "All recommended": D1 = A (merge "Istanbul" into TURK), D2 = A (fix the 12 slugs), D3 = B (Heritage 2023 and
  2024), D4 = A (file 1 Write connector, file 2 SQL Editor).
- 23:25 ET "Go" (file 1). 23:29 ET file 2 in the SQL Editor stopped at "relay hash" (nothing ran). 23:32 ET "Connector"
  (prompt closed by itself, 0.5 s, nothing ran). 23:34 ET "Ran it" (file 2, fixed, SQL Editor).

## Live state (read Oct 31, 03:34:44 UTC, whole tables)
| Table | Count |
|---|---|
| venues | **11,303** (active **10,934**, closed 369) |
| awards | **23,362** |
| price | 7,731 |
| slugs | **12,936** (canonical **11,303**, non-canonical **1,633**); venues with other than 1 canonical slug: 0 |
| listings | **11,303** |
| cities / city_aliases / redirects | 3,259 / 265 / 9 |
| city_label_source | **24,003** |
| source_capture_ledger | last id **171** |
| audit_log | 113,792 rows, last id **119,076** |

## Done in this session
1. Start check 03:05 UTC: ledger 169, audit 119,041, cities 3,259, city_aliases 265, slugs 12,924; all other counts matched
   the b2 handoff. Repo attached with push access (clone `73a707d`).
2. Reads:
   - Venue `ve_a19227e5fa` "Istanbul": legacy `data/venues.json` row has address "Istanbul, İstanbul, Türkiye" (Google
     resolved the city centre, so the restaurant name was lost). Best Chef 2024 list PDF (WebFetch): 4 Turkey entries =
     Neolokal (2 knives), Maçakızı, Apartıman Yeniköy, Fatih Tutak "TURK FATİH TUTAK" (1 knife). Database had 4 Turkey 2024
     rows: those 3 + "Istanbul". Chef page fatih-tutak: TURK, one knife. 2025 list: the results page (id=2376) shows only part
     of the list; the 2025 press release PDF failed (client error).
   - Heritage (Long Beach): archive index us/en (built-in browser, web.archive.org tab; WebFetch is blocked on
     web.archive.org). Card 20240206061227: meta "2023 MICHELIN Guide USA", classification One Star + MICHELIN Green Star.
     Card 20240913163626: meta "2024 MICHELIN Guide USA", dLayer 1 star, greenstar True. Card 20250504130045: dateAwarded 2024.
   - 12 slugs: live rule `trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g'))`; 0 new slugs
     in use, 0 in redirects.
3. Build by script `docs/open-items-b3-build/build_open_items_b3_2026_10_30.py` from 3 relays. Each relay md5 was matched
   against a live read before the build (slugs `18352be5…`, merge awards `918b15c8…`, merge labels `d29466f9…`).
   pglast OK. Dry runs (Read connector) of file 1 and of a file 2 test copy with today's counts: all guards passed, stopped at
   the first write. Repo commit `1c39ade` (built, not run).
4. **File 1** (Write connector, first try, 03:25:46 UTC): ledger **170** (michelin, award, 4, `history-backfill:`); audit
   **119,042-119,069** (28): slugs UPDATE 12, slugs INSERT 12, awards INSERT 4 (30106 2023 Green Star, 30107 2023 One Star,
   30108 2024 Green Star, 30109 2024 One Star; URL = archive card).
5. **File 2, first SQL Editor try:** stopped at "relay hash" (nothing ran; checked by read). The repo file was correct, so the
   copy and paste changed the relay text (most likely CR line endings). Fix: `rel text := replace($r$…$r$, E'\r', '')`
   before the hash check. Dry run of the fixed file against the live state passed (also a CRLF test). Repo commit `08d364b`.
6. **File 2, Write connector:** prompt closed by itself after 0.5 s (third DELETE file in a row); nothing ran.
7. **File 2** (Ben, SQL Editor, 03:34:22 UTC): ledger **171** (best-chef-awards, award, 2, `merge:`); audit
   **119,070-119,076** (7): awards UPDATE 2, slugs UPDATE 1, city_label_source DELETE 2 (hand), listings DELETE 1,
   venues DELETE 1. Read-back matched every planned value.

## Results
- TURK `ve_9852cbf26e` now holds Best Chef 15878 (2025, 1-Knife, no URL) and 15879 (2024, 1-Knife, URL = 2024 list PDF).
  Slugs: `istanbul/turk-fatih-tutak` canonical, `istanbul/istanbul` non-canonical (old URL still works). Name unchanged.
  Venue `ve_a19227e5fa` deleted with its listing and 2 city labels (full old rows in audit).
- 12 new canonical slugs: istanbul/foxy-nisantasi, apartiman-yenikoy, sade-bes-denizler-mutfagi, mahir-lokantasi,
  ahmet-ustam-ocakbasi, karakoy-lokantasi, yanyali-fehmi-lokantasi, parvus-kalamis, ali-ocakbasi-karakoy;
  izmir/partal-kardesler-balik-restorant, lucien-arkas-baglari; bodrum/otantik-ocakbasi. Old slugs non-canonical.
- Heritage (Long Beach) Michelin rows: 2023, 2024, 2025, 2026 One Star + Green Star (8 rows).

## Methods that worked (new)
- **Relay md5 against a live read before the build:** compute the same text in SQL (`md5(string_agg(…))`) and in Python;
  a match proves that no value depends on hand copying.
- **SQL Editor and relays:** a copy and paste can change line endings. Strip CR inside the file before the hash check:
  `rel text := replace($r$…$r$, E'\r', '')`. Use this in every relay file meant for the SQL Editor.
- **Write connector and DELETE:** the prompt closed by itself again (now 4 times on DELETE files, never on INSERT/UPDATE
  files). Do not offer the connector for a file with a DELETE; go to the SQL Editor at once.
- **Archive reads:** WebFetch returns SITE_BLOCKED for web.archive.org; the built-in browser with `fetch()` from a
  web.archive.org tab works.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/slugs-heritage-open-items-b3-2026-10-30.sql` (141 lines) | Run (ledger 170, audit 119,042-119,069) | `fbb17dcfc2587baa7bd054101de626e01b66e8dcf37063f4270dfed2fd8c0906` |
| `docs/merge-istanbul-turk-2026-10-30.sql` (153 lines) | Run in SQL Editor (ledger 171, audit 119,070-119,076) | `9fc081a4bb197696daf1acdec84457c84c07c82fe2d57ebc41c1fbafa0083547` |
| `docs/open-items-b3-build/` (build script, 3 relays, test copy) | Build | - |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. 36 Turkey legacy price rows (P2 price batch): card reads in the built-in browser, one "go".
2. `cities.venues_count` recount: 375 cities differed (read Oct 30) plus the Turkey moves of block 2 and Istanbul (now 36
   venues). Ben decides: recount once / leave / recount and add an automatic update.
3. Held-P2 items: 5 city changes; 15 P2 venues that left the guide.
4. Merge and award cleanup: La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy; Duddell's (Hong Kong) possible duplicate `ve_a3512f9a51` /
   `ve_f88a5d9dc2`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved.
5. **New: Best Chef source URLs.** 2024: 519 rows, 1 with URL (the 2024 list PDF covers all 2024 rows). 2025: 781 rows,
   0 with URL (the 2025 list was not readable this session). Also a check that every 2024/2025 row pairs to a list entry
   (the "Istanbul" case shows the legacy load can lose names).
6. 2025 Green Star backfill, all guides (California 2025: 13 of 17 still missing). **Also new:** Michelin history before
   2025 is thin (Heritage had no 2023/2024 rows); scope a history backfill only after Ben decides how far back to go.
7. 2025 Michelin URLs, all guides (about 3,461 rows without a URL).
8. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
   Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found;
   Florida 2026 Green Stars article not found; Turkey 2027 edition (check the unknown 2026 Bib then).
9. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.

## Suggested opening prompt
```
Read claude/handoff-open-items-b3-done-2026-10-30.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 171,
audit_log 119,076, venues 11,303, slugs 12,936 and city_label_source 24,003. Then show me the next-block options in /ste
style (the open items, smallest first, with what each needs from me) and wait for my choice. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
