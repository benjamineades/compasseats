# Handoff: Held P1-rest batch 2 done (3 Vietnam branch merges, Paloma Taqueria city move). Oct 30, 2026. Next: name differences.

This file replaces `handoff-p1-rest-held-b1-done-2026-10-30.md` for live state and next steps. That file still holds the
batch 1 results and method notes. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method. The working rules
and venue-delete method in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule (Claude commits
files to the repo itself) still apply.

## Ben's decisions (Oct 30, 2026)
- 15:11 ET "go with your recommendations" (all A), from the batch 1 session.
- 17:07 ET: Mặn Mòi merge confirmed; Paloma city label 21594 "Auckland" -> "Wanaka".
- 17:08 ET "Go"; 17:23 ET "Go"; 17:30 ET "Try to write again". Write connector failed 3 times (see below).
- 17:34 ET: Ben ran the file himself in the Supabase SQL Editor.

## Live state (read Oct 30, 21:35 UTC, whole tables, after the write)
| Table | Count |
|---|---|
| venues | **11,304** (active **10,937**) |
| awards | 23,353 (max id 30,100) |
| price | 7,730 |
| slugs | **12,843** |
| listings | **11,304** |
| city_label_source | **24,005** |
| source_capture_ledger (max id) | **162** |
| audit_log (max id) | **118,753** |
| Active Michelin star/Bib venues with no price row | **3** (Terra `ve_89ca903ac2`, La Torre One Fire `ve_b5a5b44c26`, Sankai by Nagaya `ve_f088b7a06a`) |
| Venues without exactly 1 canonical slug | 0 |

## Done in this session
1. Start check: price 7,730, ledger 159, audit 118,728. All matched. Repo attached with push access, clone at `a69dd4d`.
2. Read of all rows on the 7 venues (4 held + 3 sisters): 46 rows (venues 7, awards 7, price 4, slugs 7, listings 7,
   city labels 14). Other FK tables, redirects, rename_rows, ingest_rows: 0. Fingerprint md5
   `1f810ecb01106604d517f8bef7edcabe`.
3. Card re-read (built-in browser, fetch of live cards). All Bib, no Green Star, no redirect. Cards now carry new ward
   names: "Chay Garden (Xuan Hoa)", "Hồng Phát (Bàn Cờ)", "Mặn Mòi (An Khánh)". Paloma card city "Wānaka".
4. **Mặn Mòi proof (now strong):** manmoi.vn/en/our-locations lists Thảo Điền = 32 St. 11, W. An Khanh (= card address
   32 D11 Street, An Khanh Ward); Bến Nghé = 125 Hai Bà Trưng, W. Sài Gòn. manmoi.vn/man-moi-thao-dien-q2: 32 Đường 11,
   P. An Khánh.
5. Precedent for a city move: audit 112958–112960 (venue city UPDATE, old slug non-canonical, new canonical slug INSERT).
6. File `p1-rest-held-b2-2026-10-30.sql` (23,923 bytes, sha256 `54d79d32c8393d66786792af2ec8ac19a4464884d05c0b7b271e1847cbb8ec5a`).
   Relay 4 lines, sha256 `d23c77cf2805be3242df19cf6477f2074eecf808fbb902ca3fec9ce05c7f527a` (browser = file), fingerprint
   md5 `2b4e083aeb9008d9bd2e69d4af979a87`. Builder `build_p1_rest_held_b2_sql.py` (new). pglast check passed; dry run
   (Read connector, block up to the first write) passed.
7. Write committed Oct 30, 21:34:04 UTC (SQL Editor, Ben), one transaction, all guards and post-checks passed:
   - Awards 21122 -> CHAY GARDEN Võ Văn Tần `ve_3195442b2e`; 21126 -> Hủ Tiếu Hồng Phát `ve_39dc53fd44`; 21121 -> Mặn Mòi,
     Thảo Điền `ve_c1ed9b62ab`; each with its card URL.
   - Sister price rows legacy -> card (guide_ingest, VND): ₫ tier 1, ₫ tier 1, ₫₫ tier 2.
   - Held slugs moved to the sisters as non-canonical. Held venues `ve_f97f8ec140`, `ve_595408ccd8`, `ve_3a9de72b7b`
     deleted with their listing and 2 city labels each (hand audit rows). 0 rows left on the 3 ids.
   - Paloma Taqueria `ve_3fad690140`: city `ci_4665921775` (Auckland) -> `ci_daf6d172be` (Wanaka); slug
     `wanaka/paloma-taqueria` canonical, `auckland/paloma-taqueria` non-canonical; city label 21594 -> "Wanaka". Status
     stays active.
   - Ledgers **160** (michelin, award, 3, `merge:`), **161** (michelin, price, 3, `price-card:`), **162** (michelin,
     city_label, 1, `city-move:`). Job text md5 `a442cb1b121f89c7354861dae0011a56` = file.
   - Audit **118,729–118,753** (25): awards UPDATE 3, city_label_source DELETE 6 + UPDATE 1 (hand), listings DELETE 3,
     price UPDATE 3, slugs INSERT 1 + UPDATE 4, venues DELETE 3 + UPDATE 1.
   - `cities.venues_count` not changed (open decision).

## Write connector problem (new)
Three Write-connector calls (17:08, 17:23, 17:30 ET) each returned "client cancelled this confirmation 0.6 s after it was
sent. Nothing was run." Ben was on the phone app. A read after each try showed no change. Fallback that worked: Ben ran
the SQL file in the Supabase SQL Editor (the file is one `BEGIN; DO … ; COMMIT;` statement, so the editor is safe).
Next session: if the Write prompt closes by itself again, offer the SQL Editor route at once, or ask Ben to approve from
a computer. Check the Supabase Write `execute_sql` permission in claude.ai connector settings.

## Method notes from this session
- Card address: first `.data-sheet__block--text` of the card page (DOMParser over the fetched HTML); JSON-LD
  `PostalAddress` holds the same. Card name: `h1`.
- Relay save: the tool turns `\uXXXX` escapes into real characters inside a heredoc; use a plain-text placeholder
  (for example `DONG`) and replace it with `chr(0x20ab)` in Python, then compare the hash.
- Old-rows fingerprint for a merge: md5 of `table:to_jsonb(row)::text`, newline, ordered by table and text (COLLATE "C"),
  over venues, awards, price, slugs, listings, city_label_source of every venue in the batch. TimeZone is UTC on both
  connectors, so timestamp text matches.
- Hand audit row for a city_label_source UPDATE: `old_row = to_jsonb(c)`, `new_row = to_jsonb(c) || jsonb_build_object('label', …)`.
- `source_capture_ledger.field_type` values in use: award, name, price, city_label (no check constraint).

## Files
| File | sha256 | Where |
|---|---|---|
| `p1-rest-held-b2-2026-10-30.sql` | `54d79d32…cbb8ec5a` | project `claude/`, repo `docs/` |
| `p1-rest-held-b2-relay-2026-10-30.txt` (4 lines, no final newline) | `d23c77cf…5c7f527a` | project `claude/`, repo `docs/` |
| `p1-rest-held-b2-evidence-2026-10-30.txt` | (see repo commit) | project `claude/`, repo `docs/` |
| `build_p1_rest_held_b2_sql.py` (new) | `a00170ad…7c55c8` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Open items
- **Next (Ben's order):** the name differences: 45 from P1 rest, 24 Turkey, Efendy, Lucien Arkas (our name stays), plus
  Nam Hin ("Han Market" is the wrong branch; card "Nam Hìn (Phan Thanh Street)"), Crab noodle Ba ba (card Bánh Canh Cua
  Bà Ba), Xôi, Bún măng gà bà Vui (card Bà Vui), Bún Bò Huế - Lê Gia Khang (card Lê Gia Khang (Ngũ Hành Sơn)), Bánh Bèo,
  Bánh Đập, Bánh Ướt (card Bánh Bèo - Bánh đập), Most Tumski (card and site "Most"), and the 3 merged sisters (long
  Google-style names; cards now "Chay Garden (Xuan Hoa)", "Hồng Phát (Bàn Cờ)", "Mặn Mòi (An Khánh)"; venue site names
  "Mặn Mòi, Thảo Điền", "Hồng Phát Quận 3").
- New from this session:
  - Vietnam cards moved to the post-2025 ward names (Xuân Hòa, Bàn Cờ, An Khánh). Card names with a ward suffix give way to
    the venue's own spelling (ruling Oct 10).
  - Write connector prompt closes by itself (see above).
  - Paloma Taqueria: closed for refurbishment; recheck. City label now "Wanaka"; card spells "Wānaka" (carried item).
- Carried from batch 1: 2025 Green Star rows missing for Chez Panisse, Chi Spacca, Pomet, Heritage (Long Beach);
  Green-Star-as-star check on other guides from the Aug 14 sheet load; 2025 rows of the 3 sisters (10486, 10493, 10494)
  have no URL (archive search later); Banshee 2023/2024 Bib rows with no URL and American South 2025/2026 edition check;
  Miura / Beverly Hills city policy.
- Carried from the Turkey follow-ups handoff: Sankai by Nagaya price (card ₺₺₺₺, CAT_P04, TRY 4) with the next price batch;
  Efendy recheck; one 2026 Turkey Bib unknown (39 vs 38); Efendy and Lucien Arkas legacy `$$` rows; Sankai site spam;
  Turkey card cities that differ from ours (Revithia, Casa Lavanda, Bagarasi, Mandalya, Mezegi, Asma Yaprağı, Mezra
  Yalıkavak, Babayan Evi, Old Greek House).
- Carried from the P1-rest handoff: city labels Waiheke → Waiheke Island, Wanaka → Wānaka, Dakovo → Đakovo; held-P2 items
  (5 city changes, 3 name differences, rechecks Café Spice Namasté and Unforgettable after Nov 12, 15 P2 venues that left
  the guide); Lavello `ve_04c2784726`; Les Fresques `ve_e574aeb7fd`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre
  One Fire `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov); Switzerland after Nov 2; Italy 2027 edition Nov 12
  (rule 2.1.7); Spain 2027 edition Dec 1; Germany 2027 and GB&I 2027 edition dates not found; Northeast Cities after Dec 14;
  Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027); American Great Lakes first
  edition Apr 21, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes) status; Florida
  2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows;
  5 new awards on closed venues; `cities.venues_count` recount (Ben decides).

## Suggested opening prompt
```
Read claude/handoff-p1-rest-held-b2-done-2026-10-30.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
ledger 162 and audit_log 118,753. Then list the name differences in the open items, grouped by kind (wrong branch,
card name with a ward or branch suffix, venue's own spelling differs), with the venue's own site spelling where it can
be found. Show them to me in /ste style with a recommendation per group. No write before my go. Attach the compasseats
repo with push access for the commit after any write.
```
