# Handoff: CompassEats, Oct 13, 2026 (12:35 Atlanta). Taiwan contamination register done: 24 venues deleted, Da-Wan Michelin row deleted, 5 true drops kept (ledger 130, audit 112,279-112,454). Next: rename and status check of the true drops, then `name_native` for Taiwan.

This file replaces `claude/handoff-taiwan-renamed-2026-10-11.md` for live state, decisions, open items, methods and dead ends. That file still applies for the JL STUDIO status record (audit 112,008), the rename batch 24 record (ledger 129, audit 112,084-112,158) and the slug file record (audit 112,159-112,278). The other files still apply as before:
- `claude/handoff-taiwan-promoted-2026-10-11.md`: the Taiwan stage and promote record (batch 17, ledger 126-127), the New Taipei City record, the 36 legacy rows with no 2026 card.
- `claude/handoff-taiwan-brief-2026-10-11.md`: the Taiwan facts (2025 and 2026 editions), city ids, URLs.
- `claude/handoff-netherlands-renamed-2026-10-11.md`: working rules, the chef-suffix-before-vote method, the "by" rule.
- `claude/handoff-netherlands-status-done-2026-10-11.md`: the status-only file method, the Michelin card status method.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: database notes, the gated venue-delete method.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9...672216`).

Working rules (unchanged): plain `/ste` replies; populations on every count; one "go" per write batch; read-back after each commit; under-merge over over-merge; no competitor sources; no hand-retyped files; build, examine read-only, present, then ask; the tie rule (vote first; in a tie or doubt the venue's own spelling, Michelin fallback); nothing below a Michelin Bib is tracked; Ben starting a stage, promote or real rename job is his "go".

## Live state
Population: whole table. Read Oct 13, 16:31 UTC (12:31 Atlanta), after the cleanup.

| Table | Count |
|---|---|
| venues | **11,291** (active **10,924**, closed 367) |
| awards | **22,841** |
| Michelin 2025 / 2026 / 2027 rows | **3,520** / 5,527 / 47 |
| Taiwan Michelin rows | **150** legacy 2025 (history) + 207 sourced 2026 (batch 17) |
| listings / slugs | **11,291** / **12,813** (canonical **11,291**, non-canonical 1,522) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,259 / 259 / **23,979** |
| price / blurbs / redirects | **7,024** / 142 / 9 |
| source_capture_ledger | **90** (last id **130**) |
| audit_log | **107,314** (last id **112,454**) |
| ingest_batches | 1, 3-17 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, 22, 24 applied (23 = rolled-back dry run). rename_rows 1,099. |

## Done in this session (Oct 13, 00:34 to 12:35 Atlanta)

**Start check:** all counts, ledger 129, audit 112,278, slugs 12,837 matched the renamed handoff. `docs/slugs-rename-michelin-2026-taiwan.sql` is in the repo, sha256 `58691392...5b84c3` (correct). Old open item 1 is closed.

**1. Evidence (read-only).**
- 2025 Bib article (Michelin, Aug 12, 2025, `/tw/en/` and `/tw/zh_TW/`): 144 Bibs = Taipei 37, Taichung 23, Tainan 30, Kaohsiung 24, New Taipei City 15, Hsinchu County 8, Hsinchu City 7. The article names only some new Bibs, not the full list.
- Full 2025 list: UDN reprint of the Michelin list images (https://udn.com/news/amp/story/7266/8933484, Aug 12, 2025; "圖／台灣米其林指南提供"). Chinese names by city.
- Compared with the 2026 card names (`ingest_rows.raw->>'venue_name_zh'`, batch 17, joined by `source_url`). 2025 Bibs not in 2026: Kaohsiung 正宗鴨肉飯, 賣塩順, 白玉樓; Tainan 麥謎食驗室 (Bue mi .Lab, not in the register), 東香台菜海味料理, 筑馨居; Taichung 木公麥面; Hsinchu City, Hsinchu County, New Taipei City none. Counts close in every city.
- Per-venue pre-check on the 30 register venues: each held 1 award (Michelin 2025 Bib, no `source_url`), 1 `legacy_guide` price, 2 or 3 city labels, 1 listing, 1 canonical slug, 0 non-canonical slugs, 0 blurbs, addresses, geo, hours, photo_refs, rename_rows, redirects, ingest_rows. Only Da-Wan held another award (OAD 2025 No. 419, award 11353).

**2. Ben's decisions (Oct 13, 00:45 Atlanta): Q1 A, Q2 A, Q3 A, Q4 A.**
- Q1 A: delete the 23 contamination venues with all their rows (stored name is another business; the real 2025 Bib sits on a 2026 batch-17 venue).
- Q2 A: Da-Wan `ve_1972d080fc` keeps the venue, OAD award 11353, price, labels 11291 and 11292. Delete Michelin award 11352 and label 11293 ("New Taipei", neighborhood).
- Q3 A: delete 佑建興製麵廠 `ve_6593c6d776` (award 12426; by count the 2025 Bib of 木公麥面, on another business; no address or geo to prove a link).
- Q4 A: keep the 5 true drops (active, 2025 row as history). Follow-ups: rename 3, slugs, live-card status check of all 5 (open item 1 below).

**3. The write (`cleanup-michelin-tw-2025-contamination.sql`).**
- Built by script from `docs/cleanup-michelin-cn-chengdu-held-7.sql`. 288 lines, ASCII, LF, sha256 `0cbee3c917c6bc7d1cf01c5a5f7adab44d2eb00dad3bc8d2fee0b398f7043f20`. pglast: 3 statements, body parses.
- Guards: venue ids md5 `b1e53b6d1a18c244152940d7510572c6` (24); award ids md5 `d475f15695b43b76b359997caedd8dbd` (25 = 24 + 11352); city label ids md5 `f2299f32ae33dbc6478aa54389481107` (55 = 54 + 11293); plan fingerprint (md5 of `venue_id|name|city_id|award_id|category|year|symbol_raw|price_source|city_slug/slug|city label ids`, by venue_id, newline) `95124cd445f48cb08c22693063f2f06d`. Id lists came from a live read, saved to a file, md5 checked; not typed.
- Dry run (Read connector): all pre-checks passed, stopped at the first INSERT; no id used.
- Ben "go" (12:25, again 12:27). Write connector returned `{"status":"cancelled"}` two times, before any SQL ran (read after each: no change). **Ben ran the file in the Supabase SQL Editor: "Success. No rows returned", committed Oct 13 16:29:55 UTC.**
- Ledger **130**: michelin, award, 25, job `cleanup:cleanup-michelin-tw-2025-contamination | contamination register (Ben, Oct 13): ... | award ids ... | 5 true drops kept: 10704,10716,10718,12444,12463 | old URLs 404, no redirect`.
- Audit **112,279-112,454** (176, all DELETE, `new_row` null): city_label_source 55 (hand), awards 25, price 24, slugs 24, listings 24, venues 24. Trigger rows: 1 timestamp.
- Read-back: as in Live state. 0 rows left on the 24 venue ids. Da-Wan active, awards = 11353 (OAD) only, labels 11291 and 11292. The 5 true drops active.
- Deleted (award id, venue id, stored name):
  - Hsinchu City: 10618 `ve_565d8cb24a` 北歐森林貓舍 Norest Cattery...; 10619 `ve_bcc0cd9ac9` Hsinchu Dongmen Market; 10621 `ve_c5bdb04069` Lakeshore Hotel Hsinchu Metropolis; 10623 `ve_ff2c645a20` HoChu Yuan.
  - Hsinchu County: 10627 `ve_6a29f13cd7` CHIN HUNG FOUNDRY MACHINERY; 10628 `ve_d82cc20325` 深山裡柴燒蘿蔔糕; 10632 `ve_bbb0563a6a` Din Tai Fung.
  - Kaohsiung: 10706 `ve_370aa54da0` Qixian Duck Rice; 10708 `ve_e929296edb` Din Tai Fung Kaohsiung Branch; 10709 `ve_ff77e7b352` Duck Zhen; 10715 `ve_0bf4310fe5` 米卡希達 Mi Casita 墨西哥餐廳; 10722 `ve_6f7474caab` Yung-an Salt Evaporator Area.
  - Taichung: 12426 `ve_6593c6d776` 佑建興製麵廠.
  - Tainan: 12442 `ve_e57f049689` Du Hsiao Yueh Restaurant Tainan Chung Cheng Flagship Store; 12449 `ve_120732362b` Chou's Shrimp Rolls; 12453 `ve_9249a1737a` Wu Ming Mutton Soup; 12457 `ve_9bb7b57e39` Ji Pin Shrimp Rice; 12459 `ve_49791827ea` 慶平海產.
  - Taipei ("New Taipei" label): 11357 `ve_9372d12543` 臻品實業股份有限公司; 11358 `ve_e25c8026ee` KANG Artisan Bakery; 11359 `ve_e8331a52a7` Fon-Cé; 11363 `ve_26371de8b1` Di Yi Beef Noodle Restaurant; 11364 `ve_ac1ee79102` Chen Tung Pork Ribs Medicinal Herbs Soup; 11365 `ve_91f8ccee47` Yong He Soya Milk King (Da'an).
- Repo: Ben uploaded the file (`692d859`, Oct 13 12:32 -0400). sha256 correct. **It is in the repo root, not `docs/`** (open item 2).

## The 5 kept true drops (Q4 A)
| Award | Venue | City | Stored name | Michelin card name (2025) | Card URL |
|---|---|---|---|---|---|
| 10704 | `ve_6025c41938` | Kaohsiung | Cheng Tsung Duck Rice | Cheng Tsung Duck Rice (正宗鴨肉飯) | https://guide.michelin.com/tw/zh_TW/kaohsiung-region/kaohsiung/restaurant/cheng-tsung-duck-rice |
| 10716 | `ve_02b8c23984` | Kaohsiung | 賣塩順台菜-正宗台菜 | Mai Yen Shun (賣塩順) | https://guide.michelin.com/tw/zh_TW/kaohsiung-region/kaohsiung/restaurant/mai-yen-shun |
| 10718 | `ve_96994a1e21` | Kaohsiung | 白玉樓經典台菜(夢時代6F) | Pale Jade Pavilion (白玉樓) | https://guide.michelin.com/tw/en/kaohsiung-region/kaohsiung/restaurant/pale-jade-pavilion |
| 12444 | `ve_7eb5839370` | Tainan | Dong Shang Taiwanese Seafood | Dong Shang Taiwanese Seafood (東香台菜海味料理) | https://guide.michelin.com/tw/zh_TW/tainan-region/tainan/restaurant/dong-shang-taiwanese-seafood |
| 12463 | `ve_d851917163` | Tainan | 筑馨居 | Zhu Xin Ju (筑馨居) | https://guide.michelin.com/tw/zh_TW/tainan-region/tainan/restaurant/zhu-xin-ju |

Note: web-search snippets (Oct 13) still show "Bib Gourmand" text on the Cheng Tsung, Dong Shang and Zhu Xin Ju cards, and the Kaohsiung zh_TW list page shows 正宗鴨肉飯, 賣塩順 and 白玉樓. Snippet age is unknown. The live card decides (open item 1). If a live card shows a 2026 Bib, the venue is a capture gap in batch 17, not a drop.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `cleanup-michelin-tw-2025-contamination.sql` | Run (ledger 130, audit 112,279-112,454). In the repo **root** (`692d859`) | `0cbee3c9...7043f20` |
| `docs/slugs-rename-michelin-2026-taiwan.sql` | Run (audit 112,159-112,278), in the repo | `58691392...5b84c3` |
| `docs/status-active-jl-studio-taichung.sql` | Run (audit 112,008), in the repo | `853a9699...80f931` |
| `fixtures/rename/michelin-2026-taiwan-names.csv` | Run (batch 24), in the repo | `4117b57e...3a8218` |

## Methods that worked (new)
- **2025 Bib list by Chinese name:** the UDN reprint of the Michelin list gives all 144 names by city. Compare with `venue_name_zh` from the batch-17 `ingest_rows` (join awards 29,301-29,507 by `source_url`). A 2025 name with no 2026 card = true drop; a 2026 Bib venue with no legacy row whose name is on the 2025 list = the real home of a register row.
- **Cleanup file with an extra award-only delete:** add the row (award 11352, label 11293) to the id lists with `OR id = ...`, gate it in its own pre-check block (2a), and post-check the kept venue (5a: venue active, remaining award ids, remaining label ids, price/listing/slug code 111).
- **SQL Editor fallback:** when the Write connector cancels, Ben pastes the whole file (BEGIN, DO block, COMMIT) into Supabase SQL Editor, New query, Run. The in-block guards and post-checks give the same protection. "Success. No rows returned" = committed; then do the read-back.

## Dead ends: do not retry (new)
- The Michelin 2025 Taiwan Bib article as a full name list (it names only some new Bibs; counts only).
- Sending the same write to the Write connector after a `{"status":"cancelled"}` result (cancelled two times in a row on Oct 13; no SQL ran). Read the database, then use the SQL Editor fallback or ask Ben.

## Open items, in order
1. **The 5 true drops (Q4 A):** live-card status check of all 5 (Michelin card status method; a live 2026 Bib card means a batch-17 capture gap, not a drop). Then a rename CSV for 3 (賣塩順台菜-正宗台菜 -> Mai Yen Shun; 白玉樓經典台菜(夢時代6F) -> Pale Jade Pavilion; 筑馨居 -> Zhu Xin Ju), vote and tie rule, then their slugs (the 3 have CJK fallback slugs `kaohsiung/kaohsiung-wdri98`, `kaohsiung/kaohsiung-mmuvp8`, `tainan/tainan-nitl0s`).
2. **Ben:** move `cleanup-michelin-tw-2025-contamination.sql` from the repo root to `docs/` (open the file on GitHub, pencil icon, change the name box to `docs/cleanup-michelin-tw-2025-contamination.sql`, Commit changes).
3. **`name_native` for Taiwan** from `venue_name_zh` (Ben Q3 A, Oct 11). Population first: Taiwan venues with a 2026 card; the 29 renamed Chinese-only venues are the priority. Also the China 469 / Japan 585 / Chengdu 47 backfill.
4. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
5. **Switzerland after Nov 2, 2026** (option A, promote only).
6. **Gap list after Taiwan:** promote-only Singapore; retire-path Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; Thailand after its 2027 edition; Canada as three guides.
7. Hold registers: Texas, Belgium & Luxembourg, Netherlands, Taiwan (9 Green Stars; four special awards) -> special-awards batch.
8. Price from the Michelin card (Taiwan `$` cards: $ 86, $$ 64, $$$ 20, $$$$ 37). Ben chooses the method.
9. JL STUDIO blurb (`needs_rewrite`): rewrite through the Option B runbook when blurbs come up.
10. Carried from the promoted handoff item 11 (France slugs, later-ceremony guides, carried rename CSVs, rechecks, Ben's decisions list incl. `cities.venues_count` recount, repo `.env` keys, Plan v1.31 (add the Taiwan sessions, incl. this cleanup), options B and C, project cleanup part 2).

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-taiwan-contamination-done-2026-10-13.md first, then claude/handoff-netherlands-status-done-2026-10-11.md for the Michelin card status method, then claude/handoff-texas-done-2026-10-10.md for the rename-CSV and slug methods, then claude/handoff-netherlands-renamed-2026-10-11.md for the working rules and the vote and tie rules. Confirm live counts, ledger id 130, audit_log id 112,454 and slugs 12,813 with a Read query, and check that cleanup-michelin-tw-2025-contamination.sql is in docs/ in the repo with sha256 0cbee3c9...7043f20 (tell me if it is still in the root). Then start open item 1: check the live Michelin cards of the 5 Taiwan true drops, then build the rename CSV for the 3 renames with the vote and tie rules, examine it read-only, and ask me the questions the rules do not decide. No write before my go.
```
