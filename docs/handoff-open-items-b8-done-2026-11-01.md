# Handoff: Open items block 8 done (Best Chef 2024 + 2025 source URLs). Nov 1, 2026 (01:06 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b7-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the city-move method: `handoff-open-items-b1-done-2026-10-30.md`.
Michelin city rule (D7): `handoff-open-items-b2-done-2026-10-30.md`. Working rules and database notes:
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 1 00:44: fresh count read, next-block options. 00:47 "items 1 & 2 first" (Best Chef source URLs 2024 and 2025).
- Nov 1 01:03 "Go" (= D1 A, D2 A as offered: 2024 URL = results page; 5 rows held).

## Decisions
- **D1 = A** 2024 rows get the 2024 results page `https://thebestchefawards.com/events-results/?id=1874` (Dubai 2024),
  read and paired in this session. Row 15879 keeps the 2024 list PDF URL (Oct 30).
- 2025 rows get the 2025 results page `https://thebestchefawards.com/events-results/?id=2376` (Milan 2025). The full list is
  readable now (796 cards); the Oct 30 note "2025 list not readable" no longer applies.
- **D2 = A** 5 rows held (no URL), see Open items 1.

## Live state (read Nov 1, 05:05:19 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,302 (active 10,936, closed 366) |
| awards | 23,363 |
| price | 7,731 (legacy_guide 2,558) |
| slugs | 12,945 (canonical 11,302) |
| listings | 11,302 |
| cities / city_aliases / redirects | 3,260 / 266 / 9 |
| city_label_source | 24,003 |
| source_capture_ledger | 136 rows, last id **180** |
| audit_log | **115,448** rows, last id **120,732** |
| cities.venues_count | sum 10,936 |
| best-chef-awards 2024/2025 without URL | **5** (3453, 15690, 15727, 15997, 16190) |

## Done in this session
1. Start check Nov 1 04:45 UTC: all b7 counts matched. Repo attached with push access (clone `0e74686`).
2. Reads (built-in browser, results pages, `.chef-card` elements with `data-knives`, `data-chef-id`, `.chef-restaurant`,
   `.chef-location`): 2024 536 knife cards (523 different entries), 2025 796 (783). Key per entry =
   `year|knives|restaurant key|city key|chef id` (key: drop `(…)`, lower, ı→i ł→l đ/ð→d œ→oe ø→o æ→ae ß→ss, strip marks,
   keep a-z0-9). Files `docs/best-chef-urls-build/list-2024.txt` (sha256 `7f7dd039…b2fec5`) and `list-2025.txt`
   (`a5063648…a919`), each hash = the browser hash.
3. Pairing by script (`pair_best_chef.py`, input `db-rows.txt` from a live read): L1 name+city+knives 796, L2 name+knives 56,
   L3 city+knives+name contains 387, MANUAL 56, HOLD 5. Each row has the same knife count as its entry; no entry pairs to 2 rows.
   Chef pages read for the holds (Luis Valls, Umberto Bombana, Julien Xu, Xu Jingye, Stefano Bacchelli).
4. Build `build_best_chef_urls_2026_11_01.py` -> relay (1,294 lines, sha256 `e893f2f4…bb274`) and the SQL file. Ids md5
   `e57cc85d…94e9` = live read. pglast OK. Dry run (test copy: relay built in SQL, same fingerprint; relay hash checked by
   script) passed all gates and stopped at the first write. Repo `555e22b` (built, not run).
5. **Write connector, first try, Nov 1 05:05 UTC:** 1,294 awards source_url NULL -> results page (2024: 518, 2025: 776).
   Ledger **179** (best-chef-awards, award, 518), **180** (best-chef-awards, award, 776). Audit **119,439-120,732**
   (1,294 awards UPDATE, source_url only). Read-back matched every planned value.

## Methods that worked (new)
- **Best Chef results page:** `.chef-card` data attributes give the full list in one DOM read (no PDF needed). The page has
  duplicate cards; use a set. `innerText` reads give only part of the list (cause of the Oct 30 "not readable").
- **Large read results:** a read result over the tool limit is saved to a file; parse it by script instead of paging.
- **Dry run of a large relay file:** test copy with the relay built inside SQL from the same live rows; the fingerprint gate
  proves the same set. The relay hash is checked by script against the repo file.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/source-url-best-chef-2024-2025-2026-11-01.sql` (1,366 lines) | Run (audit 119,439-120,732, ledger 179-180) | `bb1a8a5c20fa9e5d8bcbe01292d627f427500c3e383c1e89d76d7801711328a7` |
| `docs/best-chef-urls-build/` (lists, db-rows, pair script, pairs.tsv, relay, build, dry-run test copy) | Build + evidence | - |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. **New: 5 held Best Chef 2025 rows** (no URL): 3453 Flores Raras (Valencia, 2-Knife; nearest entry Luis Valls, El Poblet
   "former workplace"); 15690 Ensue 2-Knife (Ensue is 1 knife = 15691; Shenzhen 2-knife entry = Fumée, Reina Chen, no row);
   15727 8½ Otto e Mezzo BOMBANA, Macau (entry = Hong Kong, Alexandra House); 15997 Fo'ao Vaperse Hotel (Guangzhou; unused
   entry Rêver, Julien Xu, closed Sep 2025); 16190 The Fellas (Shanghai; unused entries 102 House (closed), Scilla).
2. **New: venue name checks:** "Le Calandrе" (Cyrillic е); names that show a hotel or another business: EDGE for Men
   (Cape Town, entry Edge), Xiamen (entry Xia), Bed & Breakfast - Les Belles Perdrix, KOKI - The House of Senses (entry
   Hibana by Koki), The Palash Vann Resort (entry Palaash), Hotel Cañitas Classic (entry Cañitas Maite), Home Aribert.
   Guy Savoy is on both lists with no Best Chef row; Fumée and Hong Kong 8½ (2025) have no row.
3. 2025 Green Star backfill, all guides (2024 = 2, 2025 = 4, 2026 = 125 Michelin Green Star rows). Ben decides how far back.
4. Legacy price rows outside Turkey: 2,558 (scope when Ben asks).
5. 2025 Michelin URLs, all guides (3,461 of 3,470 rows without a URL).
6. Hong Kong / Macau Michelin 2026 edition not loaded (HK 1 row 2026 vs 145 in 2025; Macau 0 vs 35). Large block: new chat.
7. Watch: other Beverly Hills venues if a Michelin card puts one in Beverly Hills.
8. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1 (also Terra Fisterra); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara
   2027 after Feb 16, 2027; Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and
   GB&I 2027 dates not found; Turkey 2027 edition.
9. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.

Closed in this block: Best Chef source URLs 2024 and 2025 (pairing check done).

## Suggested opening prompt
```
Read claude/handoff-open-items-b8-done-2026-11-01.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 180,
audit_log 120,732, venues 11,302, closed venues 366, cities 3,260, slugs 12,945, cities.venues_count sum 10,936 and
5 Best Chef 2024/2025 rows without a URL. Then show me the next-block options in /ste style (the open items, smallest first,
with what each needs from me) and wait for my choice. No write before my go. Attach the compasseats repo with push access
for the commit after any write.
```
