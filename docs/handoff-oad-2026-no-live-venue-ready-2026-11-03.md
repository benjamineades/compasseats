# Handoff: OAD 2026 no live venue. File built, choices made, NOT run. Nov 3, 2026 (22:10 Atlanta). Next: fresh read, Ben's "go", run.

This file replaces `handoff-oad-2026-first-write-done-2026-11-03.md` for open item 1. That file still holds open items 2 to 5, the recheck list, methods and OAD data limits. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 22:06 "1A, 2A, 3A, 4A, 5A, 6A". "Handoff break first". **No "go" yet.** A choice is not a go.

## The choices
1. 1A: 22 rows on live venues as listed.
2. 2A: Sushi Riku and Sushiriku are one venue with two rows (Japan 372, 630). The new venue is `ve_45cd61d911`.
3. 3A: 10 rows with status not read and 8 rows with weak proof are active. They go on the recheck list.
4. 4A: venue city is the city that the source shows. 36 rows differ from the OAD print, or OAD prints none. 27 new cities. Labels keep what OAD printed.
5. 5A: name is the OAD name minus the suffix, plus 10 corrections. About 40 other own spellings wait for a later rename batch.
6. 6A: Urchin is closed and not published until a read shows that it reopened.

## Live state (read Nov 4, 03:07:03 UTC, whole tables)
Same as the first-write handoff. Ledger 268 (214 rows). audit_log 127,819 (121,990 rows). Venues 11,336 (active 11,042, closed 294). Awards 27,118. OAD 2026 rows 2,496. Slugs 13,184. Price 7,759. city_aliases 222. Redirects 13. `cities.venues_count` sum 11,042. Closed published 0, active not published 0 (read 02:33 UTC).

## The file
All files are on **branch `oad-2026-no-live-venue`**, folder `docs/open-items-oad-2026-no-live-venue-2026-11-03/`. Merge to `main` after the run.

| File | sha256 |
|---|---|
| `load-oad-2026-no-live-venue-2026-11-03.sql` (25,874 bytes, carries the 22:06 choices in the ledger text) | `9559760c48cc0a7960c54985b037e0fc648c7210c12488779f1f70123585fdad` |
| `oad-2026-no-live-venue-evidence-2026-11-03.csv` (311 rows) | `0301b2b33711c79070ff8270c83c06ca40a88891cc7510e866838a7360df6b52` |
| `status_v2.json` (merged reads, with 3 hand corrections) | `28f83b5e0246debb909c3a760553de588d2a2414e75d3b8cc6e1e72525ea8b4c` |

Also there: `rows311.json`, `build_second.py`, `cand.py`, `second.py`, `third.py`, `fourth.py`, `merge.py`, `worker-reads/`. `venues.json` and `cities.json` are not in the repo: they are the live read of `venues` and `cities`. A rebuild needs them again. See `cand.py` for the fields.

Plan md5 `27b1249185865abc4734cc7d53cb5c99`. Venue id md5 `724b05a50b6dec6afa421454d41066aa`. Award row md5 `edd6cbbe7d988540d4e50e3871a65736`. Live venue fingerprint `3fa2a03e216d8cb5cb460fad6926460d`.

**Dry run:** Read connector, Nov 4 UTC, the block up to the first write, with a stop line. All pre gates passed. Update sum 227 + 28 in new cities = 255 active. The dry run used the earlier file text. The rebuild changed only the ledger text and the header. pglast syntax check passed on the rebuilt file.

## What the file does
Population: 311 rows with no live venue (`status_group` in the first-write CSV).

| Group (CSV column `group`) | Europe | Asia | Japan | Total |
|---|---|---|---|---|
| new venue: open | 55 | 58 | 132 | 245 |
| new venue: status not read | 3 | 2 | 5 | 10 |
| new venue: closed | 1 | 1 | 1 | 3 |
| live venue | 6 | 6 | 8 | 20 |
| printed twice: second row on live venue | 0 | 1 | 1 | 2 |
| second row, same new venue | 0 | 0 | 1 | 1 |
| hold (no write) | 3 | 3 | 24 | 30 |

| Item | Before | After |
|---|---|---|
| Venues | 11,336 | **11,594** (active **11,297**, closed **297**) |
| Awards / OAD 2026 | 27,118 / 2,496 | **27,399** / **2,777** (+281) |
| Slugs / listings | 13,184 / 11,336 | **13,442** / **11,594** |
| city_label_source | 24,079 | **24,595** (+516) |
| Cities / sum | 3,281 / 11,042 | **3,308** / **11,297** |
| Ledger rows | 214 | **218** |
| audit_log rows | 121,990 | **123,642** (+1,652) |

Audit after: awards INSERT 281, cities INSERT 27, cities UPDATE 54, city_label_source INSERT 516 (hand), listings INSERT 258, slugs INSERT 258, venues INSERT 258. No change to price, redirects, city aliases, 2025 rows.

**New venues:** name, category `restaurant`, city, status. Id `ve_` + first 10 of md5(`citySlug:slug`). No chef, native name, price, address, geo or blurb.

**Closed new venues:** Wine RVLT (Time Out, Dec 2025: last service July 2025), Tokyo Shiba Tofuya Ukai (operator notice: March 31, 2026, permanence not stated), Urchin (own site: on pause until Autumn 2026, no date on the notice).

**Live venues that take a row (20 + 2):** ES, Garena, Zash Ristorante, Pashà, Achilli al Parlamento, Geumdwaeji Sikdang (Gold Pig), A, Palate, LV The Place Bangkok - Gaggan at Louis Vuitton, Fujin Tree (Songshan), HAILI, Ode, Abon, Sumiyaki Sousai Toriya Hitomi, 四ッ谷 みね村, Hongshiki Ryori Koki, Fukutatei Steak, Taichi (was Ichita), Restoran Alexander (stays closed), Chiba Takaoka (stays closed). Second rows: Putien (Causeway Bay), Toritama. CSV `reason` gives the proof for each.

**Name corrections (10):** Yeni Lokanta, Salisterra, Hiiragiya, Gion Rohan, Tokyo Shiba Tofuya Ukai, Ryoriya Stephan Pantel, Tempura Endo Yasaka, Sushi Shunbi Nishikawa, Sushi Hoseki, Qi 27.

**New cities (27):** Lenna, Weston Rhyn, Villabona, Longyearbyen, Erbusco, Hernani, Puente Arce, Kaatsheuvel, Quezon City, Taguig, Kaga, Unzen, Tottori, Sakai, Nakagawa, Nanao, Yamagata, Kitahiroshima, Iwaki, Toyokoro, Uozu, Yufu, Tokushima, Chino, Okayama, Fujikawaguchiko, Shimonoseki. Region NULL, no lat/lng.

## Hold rows (30, no write, list in CSV)
Conflict: Defune, Bangkok Bold Kitchen, Hisada, Kappo Yoshida, Sushi Takumi. Could be a live venue: Tempura Kusunoki Yotsuya, Tempura Yokota. City not proven: Katatsumuri, Kikuzushi. Possibly gone: Pirouette, Gloria Maris. Identity low: Arnanz, Tempura Tenon, Uran, Yakiniku Kousen, Koide, Kimiya, Sushi Ichi, Miyako Zushi, Sushi Ueda, Romantico, Hamagen, Miyaba, Meimon, Arakawa, Mudai, Tsubomi, Seto, Sushi Hachiya, Shangu.

## How strong the read is
- Parallel workers read all 311 rows in two passes. Proof of the 245 open rows: strong 135, medium 102, weak 8.
- By hand: closed and conflict results, name matches against live venues, and pages for Urchin, Ukai, Alexander, Bros, Ramón Freixa, Defune, Pirouette. The pages behind the open rows were not opened by hand.
- One worker result was wrong: Alexander read open, own site says closed. A site pop-up can be missed. "No closure note" is not proof of open. Many Michelin cards have no date.
- Three earlier "other place" verdicts reversed: ES, Taichi, Chiba Takaoka.

## Findings to carry
- **Open item 2 changes:** 2025 row 18833 on Taichi is correct (Ichita is Taichi). 2025 row 18950 on Chiba Takaoka is correct (Sushi Takaoka). 2025 row 18418 sits on ESSE, but ES (Paris) is the correct live venue. 2025 row 18761 sits on Kaiten Sushi Ginza Onodera, but Ode (Tokyo) is the correct live venue.
- **Bad live names:** Toritama `ve_f0f0978f15` holds "Toritama | Yakitori | Michelin | Curated". LV The Place `ve_21bab3c06d` holds a long name.
- **Separate from live venues, on purpose:** Bros Restaurant (new, Martina Franca) and Trattoria BROS' (Michelin has two cards). Ramon Freixa Tradicion and Ramón Freixa Atelier (two restaurants at Velázquez 24). WM BY WAGYUMAFIA and Wagyumafia. DepTH brianza and Brianza. Meet the Bund Skyline and Meet the Bund.
- **Odd OAD rows:** Tapas 24 Singapore on the Japan list. Bros prints Lecce, but it left Lecce in January 2025.

## Recheck list (add to the first-write list)
Urchin (autumn 2026). Tokyo Shiba Tofuya Ukai (permanent or rebuild). Aoyama Sushi Kanesaka (TableCheck: leaves its site on January 2, 2027, new address not announced). Alexander (Pädaste Manor closed, no date). Status not read (10): Brutalisten, Yoshinobu, Pauli, Sushi Zo Hong Kong, Sarong Bali, Yoshii (Tabelog: no new reservations), Isoda, Sushi Fujinaga, Ippongi Ishibashi, Ichibancho Teruya. Weak proof (8): Hôtel Costes Restaurant, Cafe Japan, Azabu 10, Kojimachi Nihee, Tempura Matoba, Hiroyuki, Kizushi, Sushidokoro Tada. No scheduled task holds these.

## Methods (new)
- **Search limit:** web search is shared at about 200 calls for each turn across all workers. Nine workers ran out. Set a cap per worker (35 worked), and expect a second pass. A "not found" in a first pass can be a search gap.
- **After a status read, match again on the real name and real city.** This found 22 live venues that the first match missed.
- **Match the rows against live venues with an OAD 2025 row and no 2026 row** (249 venues).
- **Compact plan text:** rows as `list|rank|name|citySlug|status|cityLabel|countryLabel`. SQL computes slug and id. md5 gates on the text, ids and award rows. A 258-venue file is 26 KB, and the md5 catches a retyping error.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-no-live-venue-ready-2026-11-03.md from the project files, then
claude/handoff-oad-2026-first-write-done-2026-11-03.md for the other open items and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Attach the compasseats repo with push access.
Do a fresh count read and confirm ledger 268, audit_log 127,819, venues 11,336 (active 11,042, closed 294), awards 27,118,
OAD 2026 rows 2,496, slugs 13,184, price 7,759, city_aliases 222, redirects 13, closed published 0 and cities.venues_count sum 11,042.
Fetch branch oad-2026-no-live-venue and check the sha256 of docs/open-items-oad-2026-no-live-venue-2026-11-03/load-oad-2026-no-live-venue-2026-11-03.sql
(expect 9559760c...85fdad). Then wait for my "go". After my go, run the file through the Write connector, read back, merge the branch to main, and write the handoff.
```
