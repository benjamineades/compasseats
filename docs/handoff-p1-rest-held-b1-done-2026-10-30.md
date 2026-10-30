# Handoff: Held P1-rest batch 1 done (16 venues: card price, URLs, California Green Star fix). Oct 30, 2026. Next: batch 2.

This file replaces `handoff-turkey-followups-done-2026-10-30.md` for live state and next steps. That file still holds the
Turkey follow-up results. `handoff-price-card-p1-rest-done-2026-10-30.md` holds the original held list.
`handoff-price-card-p1-done-2026-10-30.md` holds the card-read method. The working rules in
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule (Claude commits files to the repo itself)
still apply.

## Ben's decisions (Oct 30, 2026)
- 15:11 ET "Let's go with your recommendations" for all 8 groups of the 19 held venues (1A 2A 3A 4A 5A/A 6A 7A 8A).
  Mặn Mòi (group 6) taken as A; Claude flagged it as the weakest proof (confirm again before batch 2 "go").
- 15:16 ET "Go" for batch 1.
- 15:26 ET "B": handoff break before batch 2.

## Live state (read Oct 30, 19:18 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,730** |
| venues | 11,307 (active 10,940, closed 367) |
| awards | **23,353** (max id **30,100**) |
| source_capture_ledger (max id) | **159** |
| audit_log (max id) | **118,728** |
| Active Michelin star/Bib venues with no price row | **6** (3 branch venues below + Terra, La Torre One Fire, Sankai by Nagaya) |

## Done in this session
1. Start check (18:52 UTC): price 7,714, ledger 157, audit 118,697. All matched. Repo attached with push access, clone at
   `df237a9`.
2. Evidence reads: built-in browser. Country/state lists (Vietnam 189, California 514, New Zealand 110, Poland 196, Georgia 64,
   Florida 196), 21 card pages, Michelin California 2026 and 2025 articles, venue sites. See
   `p1-rest-held-b1-evidence-2026-10-30.txt`.
3. Key findings:
   - **California Green Star defect:** Chez Panisse, Chi Spacca, Monte's, Pomet, Sierra Mar held "2026 One Star" rows. The
     2026 article (Jun 25, 2026) has none of them in its star lists; the 2025 article lists Chez Panisse, Chi Spacca, Pomet
     as Green Stars; all 5 live cards show no star and `dLayer['greenstar'] = 'True'`. Heritage (Long Beach) held "Two
     Stars": card = One Star + Green Star. Cause: Green Star icon read as a star in the Aug 14 sheet load (award block
     21061–21082; the other One Stars in that block are real).
   - **Branch split:** 3 held Vietnam venues have a sister venue that holds the 2025 Bib of the same card plus a legacy price.
4. File `price-michelin-card-p1-rest-held-b1-2026-10-30.sql` (17,145 bytes, sha256
   `92eb701df27da5a7e35b291560f0208c3f5fa570041766600efbe1c4c767faea`). Relay 16 lines, sha256
   `e862aba2a4917e97f3f5243f7dd8994aa164b805640bae0a0adeafa6e203941c` (browser = file, two parts), fingerprint md5
   `8287e5e201a415790d5657d88c8e6a76`. Builder `build_p1_rest_held_b1_sql.py` (new). pglast 8.7 syntax check passed; dry
   run (Read connector, forced stop before the first write) passed. Write 19:17:43 UTC, Write connector, one transaction,
   all guards and post-checks passed:
   - 8 award UPDATE source_url NULL -> card URL (Most Tumski 21049, Nam Hin 21117, Crab noodle Ba ba 21127, Bà Vui 21118,
     Lê Gia Khang 21120, Bánh Bèo 21119, Paloma Taqueria 21210, Miura 21077).
   - 5 award UPDATE One Star -> Green Star + card URL (Chez Panisse 15350, Chi Spacca 21073, Monte's 21078, Pomet 21080,
     Sierra Mar 17831).
   - Heritage Long Beach 21072 Two Stars -> One Star + card URL; new award **30100** 2026 Green Star (card URL).
   - Ledger **158**: michelin, award, 15.
   - 16 price INSERT (the 14 above + Banshee $$$ USD from the Selected card + Zhu Ji ¥ CNY from the Sep 4, 2025 archive
     card). Currencies USD 8, VND 5, CNY 1, EUR 1, NZD 1. Tiers 1 = 6, 2 = 1, 3 = 4, 4 = 5. Ledger **159**: michelin, price, 16.
   - Audit **118,698–118,728**: awards UPDATE 14, awards INSERT 1, price INSERT 16.
   - Banshee award rows (Bib 2023 21098, Bib 2024 21099) not changed (ruling Oct 10).
5. Commit `43227b5` (repo `docs/`), fresh clone sha256 = file sha256 for all 4 files; same 4 files in project `claude/`.

## Batch 2 (next): venue changes, 4 venues. Ben chose A for each; no file built yet.
Pre-check read (Oct 30, 19:20 UTC): FK tables to `venues` = addresses, awards, blurbs, city_label_source, geo, hours,
listings, photo_refs, price, slugs. Each held branch venue: 1 award, 0 price, 1 slug, 1 listing, 2 city_label_source;
0 blurbs/addresses/geo/hours/photo_refs/redirects/rename_rows/ingest_rows. No non-Michelin award on a venue to delete.

| Held venue (delete) | 2026 award (move) | Sister venue (keep) | Sister 2025 row | Card | Card price |
|---|---|---|---|---|---|
| CHAY GARDEN Nguyễn Thị Minh Khai `ve_f97f8ec140` | 21122 | CHAY GARDEN Võ Văn Tần `ve_3195442b2e` | 10486 | 1201807 `/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/chay-garden`, 52 Vo Van Tan | ₫ CAT_P01 |
| Hủ Tiếu Hồng Phát (Hồng Phát Bến Thành) `ve_595408ccd8` | 21126 | Hủ Tiếu Hồng Phát `ve_39dc53fd44` | 10493 | 1205566 `/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/hong-phat-district-3`, 389-391 Vo Van Tan | ₫ CAT_P01 |
| Mặn Mòi, Bến Nghé `ve_3a9de72b7b` | 21121 | Mặn Mòi, Thảo Điền `ve_c1ed9b62ab` | 10494 | 1211006 `/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/man-moi-thu-duc-city`, 32 D11 Street, An Khanh | ₫₫ CAT_P02 |

Proof: Chay Garden: sister name holds the card street; only Chay Garden card in Vietnam. Hồng Phát: venue site
hutieuhongphat.com branch 01 "Hồng Phát Quận 3" = 389-391 Võ Văn Tần; Bến Thành is another branch. Mặn Mòi (weaker):
card slug `thu-duc-city` and earlier card name "(Thu Duc City)"; Thảo Điền is in Thủ Đức, Bến Nghé in District 1; manmoi.vn
shows no addresses. Sister price rows are legacy (`$`, `$`, `$$`, no currency, no URL).

Plan per merge (Chengdu delete method): re-read the card for price and captured_at; UPDATE award venue_id -> sister and
source_url -> card URL (sister has 2025 only, so `awards_no_dupes` is safe); UPDATE sister price to the card row
(guide_ingest, VND); slug of the held venue -> sister as non-canonical (old-slug policy); hand audit rows + DELETE
city_label_source (2 each); DELETE listings; DELETE venue; ledger rows; post-check 0 rows left on the 3 ids.

Paloma Taqueria `ve_3fad690140`: city Auckland `ci_4665921775` -> Wanaka `ci_daf6d172be`; new canonical slug
`wanaka/paloma-taqueria`, old `auckland/paloma-taqueria` kept non-canonical. Examine its 2 city_label_source rows first
(they likely say Auckland). Status stays active (site: "Closed for Refurbishment").

After batch 2: active star/Bib venues with no price = 3 (Terra, La Torre One Fire, Sankai).

## Method notes from this session
- List cards: `div.card__menu` holds only `data-id`, `data-lat`, `data-lng`. Name, city, distinction, price are on the child
  div with `data-restaurant-name` (use the one that also has `data-distinction`). Pages give 52 nodes (48 + 4 featured).
- Card Green Star: `dLayer['greenstar'] = 'True'`. Card distinction for Selected: `plate`.
- Archive (2025) card layout: the "Price:" regex does not match; the price is in the `.data-sheet__block--text` that holds
  " · " (for example "¥ · Noodles").
- `javascript_tool` with no `tabId` runs in the active tab: always pass `tabId` when two tabs are open.
- WebFetch of web.archive.org gives SITE_BLOCKED; use a browser tab on web.archive.org. chaygarden.com did not load.
- No Beverly Hills city row exists (Beverly Hills venues sit under Los Angeles).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p1-rest-held-b1-2026-10-30.sql` | `92eb701d…c767faea` | project `claude/`, repo `docs/` |
| `p1-rest-held-b1-relay-2026-10-30.txt` (16 lines, no final newline) | `e862aba2…6e203941c` | project `claude/`, repo `docs/` |
| `p1-rest-held-b1-evidence-2026-10-30.txt` | `cf8f5bbf…7e8e14c36f` | project `claude/`, repo `docs/` |
| `build_p1_rest_held_b1_sql.py` (new) | `51cb0454…47f7dcc28` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Open items
- **Next (Ben's order):**
  1. Batch 2 above (Paloma city move, 3 branch merges). Confirm Mặn Mòi before "go".
  2. The name differences: 45 from P1 rest, 24 Turkey, Efendy, Lucien Arkas (our name stays), plus from this session:
     Nam Hin ("Han Market" is the wrong branch; card "Nam Hìn (Phan Thanh Street)"), Crab noodle Ba ba (card Bánh Canh Cua
     Bà Ba), Xôi, Bún măng gà bà Vui (card Bà Vui), Bún Bò Huế - Lê Gia Khang (card Lê Gia Khang (Ngũ Hành Sơn)), Bánh Bèo,
     Bánh Đập, Bánh Ướt (card Bánh Bèo - Bánh đập), Most Tumski (card and site "Most"), and the sister names after the
     merges (Chay Garden, Hồng Phát, Mặn Mòi carry Google-style long names).
- New from this session:
  - 2025 Green Star rows missing for Chez Panisse, Chi Spacca, Pomet, Heritage (Long Beach) (2025 California article).
  - Green-Star-as-star defect: check other guides from the Aug 14 sheet load for the same error (star rows with no URL on
    venues whose card shows `greenstar True` and no star).
  - 2025 rows of the 3 sisters (10486, 10493, 10494) have no URL (archive search later).
  - Banshee: 2023/2024 Bib rows have no URL; American South 2025/2026 edition check.
  - Miura: card city Beverly Hills; city policy for Beverly Hills (no city row; venues under Los Angeles).
  - Paloma Taqueria: closed for refurbishment; recheck.
- Carried from the Turkey follow-ups handoff: Sankai by Nagaya price (card ₺₺₺₺, CAT_P04, TRY 4) with the next price batch;
  Efendy recheck (card removed after Jan 28, 2026); one 2026 Turkey Bib unknown (39 vs 38); Efendy and Lucien Arkas legacy
  `$$` rows (P2 with the 36 Turkey legacy rows); Sankai site spam; Turkey card cities that differ from ours (Revithia, Casa
  Lavanda, Bagarasi, Mandalya, Mezegi, Asma Yaprağı, Mezra Yalıkavak, Babayan Evi, Old Greek House).
- Carried from the P1-rest handoff: city labels Waiheke → Waiheke Island, Wanaka → Wānaka, Dakovo → Đakovo; held-P2 items
  (5 city changes, 3 name differences, rechecks Café Spice Namasté and Unforgettable after Nov 12, 15 P2 venues that left
  the guide); Lavello `ve_04c2784726`; Les Fresques `ve_e574aeb7fd`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre
  One Fire `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov); Switzerland after Nov 2; Italy 2027 edition Nov 12
  (rule 2.1.7); Spain 2027 edition Dec 1; Germany 2027 and GB&I 2027 edition dates not found; Northeast Cities after Dec 14;
  Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027); American Great Lakes first
  edition Apr 21, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes) status; Florida
  2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows;
  5 new awards on closed venues.
- The "California 2026 One Star rows with no star on the current list" item is closed (Green Star relabel, ledger 158).

## Suggested opening prompt
```
Read claude/handoff-p1-rest-held-b1-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules and the venue-delete method. Do a fresh count
read and confirm price 7,730, ledger 159 and audit_log 118,728. Then build batch 2 of the held P1-rest venues (Paloma
Taqueria city move, and the 3 Vietnam branch merges: Chay Garden, Hồng Phát, Mặn Mòi), examine it read-only with a dry
run, and show it to me in /ste style. Ask me to confirm Mặn Mòi. No write before my go. Attach the compasseats repo with
push access for the commit after any write.
```
