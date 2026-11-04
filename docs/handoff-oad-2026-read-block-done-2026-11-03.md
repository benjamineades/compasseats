# Handoff: OAD 2026 separate read block (open item 2), write done. Nov 3, 2026 (23:05 Atlanta). Next: 27 hold rows and Summer Palace.

This file replaces `handoff-oad-2026-no-live-venue-done-2026-11-03.md` for the live state and open items 1 and 2. `handoff-oad-2026-first-write-done-2026-11-03.md` still holds methods and OAD data limits. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 22:29 "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A". 22:46 "A, go" (not run: connector prompt got no answer). 22:53 "B, go" (Kitafuku: move the row, delete Azabu-Juban). 23:00 "Ran": Ben ran the file in the Supabase SQL Editor. 23:03 "Commit".

## Live state (read Nov 4, 04:00:46 UTC, whole tables)
Venues **11,574** (active **11,275**, closed **299**). Awards **27,455** (last id **34,626**). OAD 2026 rows **2,833**. OAD 2025 rows 2,437. Slugs **13,422**. Price 7,759. Listings **11,574**. city_label_source **24,555**. city_aliases 222. Redirects **32**. Cities **3,315**, `cities.venues_count` sum **11,275**. Ledger **225** rows, last id **279**. audit_log **124,173** rows, last id **130,002**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0. Cities with 0 venues 67.

## Done
`docs/open-items-oad-2026-read-block-2026-11-03/cleanup-oad-2026-read-block-2026-11-03.sql` (sha256 `e44af7ef61f0514fc94051fdeb28142543ffdf494d22712613a4aaebae23f391`). 1 transaction, all gates passed.

Evidence: `oad-2026-separate-read-block-evidence-2026-11-03.csv` in the same folder (91 rows, sha256 `49c1f0be2ab741f53f89d4906b4f619808bb4b54e893d800fba4969bf3e0d789`). This CSV was built before the 22:53 choice, so it does not show the Kitafuku move. Web reads: `worker-reads/` (62 rows). Scripts in run order: `build.py`, `build_load.py`, `build_sql.py`. `plan.json` holds the plan data.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

| Item | Change | Ids |
|---|---|---|
| New OAD 2026 rows | 56 (Asia 11, Europe 11, Japan 34) | Awards 34,571-34,626 |
| OAD 2025 rows moved | 49 | Printed names read from the 2025 lists, Nov 4 |
| New venues | 22 (18 active, 4 closed) | |
| Venues deleted | 42 (no award after the move) | 5 twins redirect, others 404 |
| City moves | 14, with redirects | City labels stay as OAD printed them |
| Al Mahara `ve_d2c67e7d3d` | Closed to active and published | Ben 7A |
| Renames | Ginza Kojyu, Toritama. Old slugs stay non-canonical | rename batch `rename-oad-2026-read-block-2026-11-03` |
| New cities | Kuwana, Kawasaki, Tatebayashi, Karatsu, Utsunomiya, Hamamatsu, Nishinomiya. Region NULL, no lat/lng | Beersel got country Belgium |
| Ledger | 273-279 | |
| audit_log | 129,472-130,002 (531) | |

**Closed new venues, not published:** Pierre Gagnaire (Tokyo), Mikasa (Kawasaki, sources conflict), Howard's Gourmet Beijing (OAD prints Closed), Miyako Zushi.

**Real restaurants deleted with a 404:** they had no award after the move, such as Sushi Ueda (Kobe), MO's (Vienna), Sushi Masa Black, Azabu-Juban Kitafuku. `tokyo/katsukani-ryori-akasaka-kitafuku` was an old slug of Azabu-Juban Kitafuku. It now gives a 404. No redirect (not decided).

**Not checked:** the live site. This session did not read a page or a deploy. The shell cannot reach compasseats.com.

## Open items
1. **Hold rows, 27 (no write, was 30).** Romantico, Arakawa, Miyako Zushi loaded. Left: Arnanz, Restaurant Pirouette, Defune, Tempura Tenon, Bangkok Bold Kitchen, Gloria Maris, Uran, Yakiniku Kousen, Hisada, Katatsumuri, Koide, Tempura Kusunoki Yotsuya, Kimiya, Sushi Ichi, Sushi Ueda (Osaka, Japan 561), Kappo Yoshida, Kikuzushi (Kitakyushu, Japan 611), Hamagen, Miyaba, Meimon, Mudai, Tsubomi, Seto, Sushi Takumi, Tempura Yokota, Sushi Hachiya, Shangu. Evidence: `docs/open-items-oad-2026-no-live-venue-2026-11-03/oad-2026-no-live-venue-evidence-2026-11-03.csv`, rows with `group` = hold (30 rows, 3 of them now loaded).
2. **Read block, what is left.**
   - **Not proven, no write, 3:** Jing Yaa Tang (Asia 486, on Yatang `ve_84687b6ab6`), Kikuzushi (Japan 180, on Kiku Sushi `ve_515b6a646f`), Omino Kamiyacho (Japan 462, on Omino `ve_ebb1779b86`, live city Yokahama).
   - **Summer Palace (Ben 5A), 1 row and 1 cross:** Asia 259 prints Summer Palace (Hong Kong), not loaded. Its 2025 row 18119 (rank 215) sits on Beijing `ve_6a1064e62c`. Asia 432 prints Summer Palace (Beijing) with city Hong Kong, chef Leung Yu King, live on Hong Kong `ve_54ab6673c8`, with 2025 rank 335.
   - **2025 rows still on the wrong venue, 2:** Pirouette 18463 on Le Choubichou `ve_3a0ba9fb7b` (same address, business sold end 2023). Sushi Ichi 18993 on Ginza Fukuju `ve_7f732a531c`.
3. **Rename batch.** About 40 OAD own spellings on the new venues (Ben 5A of the last write), plus 145 name candidates left of 147 (test: "|", promotion words, over 50 characters; candidates, not confirmed; read Nov 3). Some were deleted in this write: count again.
4. **Status (from the first-write handoff).** Sustanza, Testina, Art di Daniele Sperindio.
5. **44 closed venues OAD 2026 still prints,** plus Restoran Alexander, Chiba Takaoka, Sorrel, Quattro Passi with a new 2026 row. All stay closed. Count again.
6. **New cities, 34.** 27 from the last write, 7 from this one. Region NULL, no lat/lng.
7. **From the last handoffs, unchanged.** Carmen Medellín `ve_6cd9c1b505`. Merged venues left as they are (Restaurant Wörgötter, Schlosskeller Südsteiermark, Fagn, Vyn Restaurant). Missing 2025 rows, 22 venues. 26 aliases with a venue under a neighbor city. 48 Swiss 2025 rows with no capture. 3,028 Michelin 2025 rows with no URL. 140 blurbs `needs_rewrite`. New checks on Kioicho Mitani, Yamazaki `ve_61cf53898d`, Sushi of Gari 46, Forbes pages for Masa. New: 67 cities with 0 venues.

## Recheck list (no scheduled task holds these dates)
All items of `handoff-oad-2026-no-live-venue-done-2026-11-03.md`, plus: status not read: Ling Long Beijing, Kawada, Rokkan, Kitafuku Akasaka. Mikasa (Ekiten closed, Tabelog unconfirmed). Weak identity: Uemura, Meizan Kimiya, Seirin (chef differs), Terborght and Heunisch & Erben (OAD chef is at another restaurant).

## Methods (new)
- **Phone area code on the OAD Japan page** was the best proof of the real city. OAD city labels and addresses were wrong on many rows.
- **The 2025 list reads in the built-in browser:** the list is client-rendered, so a `fetch` of the page gives 0 rows. Open the page, then read `.card-details-details` from the live DOM.
- **Search live names for the real restaurant before a new venue.** It found OBA-, Xin Rong Ji (Jinrong Street), Flore (Amsterdam), Quattro Passi.
- **The Write connector can ask for a confirmation.** If no answer comes, it times out at 230 s, or the client cancels it. Nothing runs. Ben can run the file in the Supabase SQL Editor.
- **A paste can change the plan text.** The first SQL Editor run stopped at the md5 gate. The next version removed CR from the plan variables before the gate, and the gate error prints the lengths. It passed. Cause not proven.

## Dead ends: do not retry
- `slugs.canonical` (column is `is_canonical`). `cities.name` (column is `display`).
- WebFetch on an OAD list page (no rows).
