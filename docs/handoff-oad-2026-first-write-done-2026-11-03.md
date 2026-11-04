# Handoff: OAD 2026 Europe, Asia, Japan, first write done. 1,794 new rows. Nov 3, 2026 (21:35 Atlanta). Next: second batch (311 rows), or Ben chooses.

This file replaces `handoff-a2-a3-d-done-2026-11-03.md` for the live state and open items. That file still holds its other open items, listed below. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 21:16 "1A, 2A, 3A, 4A, 5A, 6A". 21:27 "Go".

## Live state (read Nov 4, 02:30:22 UTC, whole tables)
Venues **11,336** (active **11,042**, closed **294**). Awards **27,118** (last id **34,289**). OAD 2026 rows **2,496**. Slugs **13,184**. Price **7,759**. Listings 11,336. city_label_source 24,079. city_aliases 222. Redirects 13. Cities 3,281, `cities.venues_count` sum 11,042. Ledger **214** rows, last id **268**. audit_log **121,990** rows, last id **127,819**. Closed published 0, active not published 0.

## Done
`docs/load-oad-2026-europe-asia-japan-2026-11-03.sql` (sha256 `382809882a63547e362ddf6c28ab1f01cc9b15223768cc8a48a9105f843c1774`). Write connector, first try. Awards 32,496-34,289. Audit 126,026-127,819 (1,794 rows, all awards INSERT). Ledger 266-268.

- **New rows:** Europe 695, Asia 506, Japan 593, on 1,789 venues. Each row: year 2026, rank, category `No. N`, no distinction, list URL.
- **On closed venues (Ben 3A):** 44 rows. The venues stay closed and not published.
- **Two rows on one venue (Ben 5A):** Sushi Saito Hong Kong (Asia 49, 490). Lai Ching Heen (Asia 90, 390). Nihombashi Sonoji (Japan 129, 274). Yakitori Ichimatsu (Japan 352, 394). Sushi Masuda (Japan 257, 337).
- **No change to:** venues, status, cities, slugs, price, redirects, 2025 rows, live pages. The Sheet and the static `data/` files do not hold these rows.

Evidence: `docs/open-items-oad-2026-2026-11-03/oad-2026-europe-asia-japan-evidence-2026-11-03.csv` (2,163 rows, sha256 `f46f2f00f46fe0e6e72fbac03e4920650a2fc28acdea029b9d26942f50917ba8`). List read: `oad-2026-lists-relay-2026-11-03.jsonl` (sha256 `0f4caee4115425434aeb66db1a198ed2846447f4d3bfc9ed8566e07c8b8aec7c`). Scripts in the same folder, in run order: `parse.py`, `match.py`, `m2.py`, `m3.py`, `m4.py`, `final.py`, `build_load.py`. `final.py` holds the hand verdicts.

## Result of all 2,163 rows (CSV column `status_group`)
| Group | Europe | Asia | Japan | Total | State |
|---|---|---|---|---|---|
| matched | 657 | 489 | 572 | 1,718 | Loaded |
| city disagrees: same place | 35 | 17 | 19 | 71 | Loaded |
| city disagrees: twin | 3 | 0 | 2 | 5 | Loaded |
| already loaded (award 32495) | 0 | 0 | 1 | 1 | Loaded before |
| no live venue | 68 | 71 | 172 | 311 | Open item 1 |
| hold | 7 | 13 | 33 | 53 | Open item 2 |
| city disagrees: move question | 4 | 0 | 0 | 4 | Open item 2 |

Proof of the 1,718 matched rows: 1,469 same slug, name and city as a 2025 row. 125 name and city, no 2025 row. 115 read by hand from the OAD page (weakest). 9 same slug and name, OAD prints no city.

## Open items
1. **No live venue, 311 rows (Ben 2A, next).** 217 carry OAD's "New" mark, 94 do not. Method: one new venue and one row each, as in Nov 3. Each new venue needs a status read. Name, city and shared-slug traps below. Sushi Riku and Sushiriku (Japan 372, 630) have the same chef: decide one venue or two. Population also holds 24 rows whose 2025 row sits on another place.
2. **Separate read block (Ben 6A).**
   - **53 hold rows and 4 move rows** (`status_group`). Move rows: Terborght (live Barcelona, OAD Brussels), Motelombroso (live San Sebastián, OAD Milan), Heunisch & Erben (live London, OAD Vienna), Sorrel (live Dorking and closed, OAD London).
   - **34 OAD 2025 rows on the wrong venue** (CSV `note` contains "sits on"). 24 with no correct venue, such as Romantico on Sagano Scenic Railway trolley train, award 19045. 5 with a correct live venue that now holds the 2026 row: Purs, Seventh Son Beijing, Ren Mishina, Nihonryouri Kenya, l'Alchimiste. 5 twins: KOL 18365, Mugaritz 18386, Yamazato 18539, Ryuzu 18772, Masuda 18777.
   - **Bad live names seen:** "Ginza Kojyu - prenotato il 27", "Bali Sarong | #1 Beach Sarong...". Population not counted.
3. **Status (Ben 4A):** OAD prints Sustanza and Testina as closed, Art di Daniele Sperindio as temporarily closed. Live status is active. Rows loaded, status not changed. Added to the recheck list. Howard's Gourmet (Closed) and Quattro Passi (Temporarily Closed) are hold rows.
4. **44 closed venues OAD 2026 still prints.** Ben 3A kept them closed. List: CSV `live_status` = closed.
5. **From the last handoff, unchanged:** Carmen Medellín `ve_6cd9c1b505`. Merged venues left as they are (Restaurant Wörgötter, Schlosskeller Südsteiermark, Fagn, Vyn Restaurant). Missing 2025 rows, 22 venues. 26 aliases with a venue under a neighbor city. 48 Swiss 2025 rows with no capture. 3,028 Michelin 2025 rows with no URL. 140 blurbs `needs_rewrite`. New checks on Kioicho Mitani, Yamazaki `ve_61cf53898d`, Sushi of Gari 46, Forbes pages for Masa.

## Recheck list (plus 3)
Sonne Scheunenberg `ve_1ff8df1642`: Ben opens the site. Ling Ling after Nov 5, 2026. Colani Bistrot Nov 27. After Seven Dec 2. Scalottas Terroir Dec 9. Ô Bois Sauvage and The Grill at Amangani Jan 2027. Mitani, Yakitori Kurosaki status. New: Sustanza, Testina, Art di Daniele Sperindio. No scheduled task holds these dates.

## Methods (new)
- **Large results without retyping:** a tool result too large for the chat is saved to a file, and the error gives the path. Browser JavaScript and SQL results both do this. Return a JSON string with a sha256 first line. Parse it with Python. Check the hash.
- **OAD list rows from the DOM:** `.card-details-details`, with `.card-details-content` (rank), `h3 a` (name, slug), `.cityP`, `.countryP`, `.card-details-actions a` (chef, then cuisine). Far better than `innerText`.
- **A star on a rank means the "(New)" mark.** Example `75*` and "Eliane (New)". Store the number.
- **Slug bridge:** 2026 slug = 2025 slug in the same list, then the 2025 rank finds the live award row. Drop the bridge for "(New)" rows and repeated slugs unless the city is the same.
- **Page loop:** store on `window`, 3 workers, 250 ms pause, about 8 pages each second. Poll. A JavaScript call times out at 45 s.
- **`navigate` can fail with "denied or failed" after some pages.** `preview_start` with the URL works.
- **Romaji and pinyin keys:** `pykakasi` and `pypinyin` compare live CJK names to OAD names.
- **Gated load with large text:** rows as `rank:id` text with md5 gates, 27 KB for 1,794 rows. No temp table: a read-only dry run stops at CREATE, before the gates.

## OAD data limits (new)
- Shared slugs: 21 slugs cover two or more restaurants, such as `jin`, `noor`, `breda`, `il-ristorante-niko-romito`. The page shows one of them.
- Japan addresses are weak: 20 pages print a "1-1-1" address, 9 print 3-8-12 Minamiaoyama. Do not use an address alone as proof in Japan.
- OAD Japan city labels can be wrong in both years. Many live venues sit in another city by earlier work.
- OAD spellings of cities: Taipei City, Taiper City, Kuala LumPor, Manilla, Stockhom. City and region can be swapped ("Modern Indian" as a city on Gaggan at Louis Vuitton).

## Suggested opening prompt
```
Read claude/handoff-oad-2026-first-write-done-2026-11-03.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 268,
audit_log 127,819, venues 11,336 (active 11,042, closed 294), awards 27,118, OAD 2026 rows 2,496, slugs 13,184, price 7,759, city_aliases 222, redirects 13, closed published 0 and cities.venues_count sum 11,042.
Then start open item 1: the 311 OAD 2026 rows with no live venue. Use the evidence CSV in docs/open-items-oad-2026-2026-11-03/. Read the status of each new venue, build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
