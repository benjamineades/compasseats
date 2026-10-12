# Handoff: CompassEats, Oct 11, 2026 (20:55 Atlanta). Taiwan 2026 staged and promoted (batch 17, ledger 126-127). New Taipei City added, 7 venues moved (audit 111,205-111,227). Next: JL STUDIO status, Taiwan rename CSV, slugs, contamination register.

This file replaces `claude/handoff-taiwan-brief-2026-10-11.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-taiwan-brief-2026-10-11.md`: the Taiwan facts (2025 and 2026 editions), label check, name items, city ids, URLs.
- `claude/handoff-netherlands-renamed-2026-10-11.md`: the rename record (batch 22), working rules, the chef-suffix-before-vote method, the "by" rule.
- `claude/handoff-netherlands-slugs-done-2026-10-11.md`: the slug file method (model for the Taiwan slug file).
- `claude/handoff-netherlands-status-done-2026-10-11.md`: the status-only file method (model for JL STUDIO).
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the capture-check, simulation, pairing, stage and promote record.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, the gated venue-delete method (model for the contamination cleanup).
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9...672216`): rule 2.1.1 (amended Sep 24), rule 2.1.7.

Working rules (unchanged): plain `/ste` replies; populations on every count; one "go" per write batch; read-back after each commit; under-merge over over-merge; no competitor sources; no hand-retyped files; build, examine read-only, present, then ask; the tie rule; nothing below a Michelin Bib is tracked; Ben starting a stage or real promote job is his "go".

## Live state
Population: whole table. Read Oct 12, about 00:52 UTC (Oct 11, 20:52 Atlanta), after the promote.

| Table | Count |
|---|---|
| venues | **11,315** (active **10,947**, closed 368) |
| awards | **22,866** |
| Michelin 2025 / 2026 / 2027 rows | 3,545 / **5,527** / 47 |
| listings / slugs | **11,315** / **12,777** (canonical 11,315, non-canonical 1,462) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | **3,259** / 259 / **24,034** |
| price / blurbs / redirects | 7,048 / 142 / 9 |
| source_capture_ledger | **88** (last id **127**) |
| audit_log | **106,942** (last id **112,007**) |
| ingest_batches | 1, 3-**17** promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, 22 applied. rename_rows 1,024. |
| Taiwan Michelin rows | 175 legacy 2025 (kept as history) + 207 sourced 2026 card rows (batch 17) |

## Done in this session (Oct 11, 18:05 to 20:55 Atlanta)

**1. Start check.** All counts, ledger 123, audit 111,204, slugs 12,709 matched the brief handoff.

**2. File checks.** `michelin-2026-taiwan.csv` sha256 `835d3cc256b4ca4b6977a65680d154e72884c7a0eadc554567cc1b9f2f8bb046` = log; 208 lines, 17 columns, UTF-8, no BOM, LF; 3 / 9 / 49 / 146 = 207 = brief, every city cell = brief; 0 duplicate URLs, 0 non-NFC. Log sha256 `1ecfbc8187a5f6f4c4c80c7da283466a1437edf17af9d9f42b3255704c98964e`. Both in the repo (`b4ccf32`, `3c6614c`), checked in a fresh clone. Brief `docs/cowork-michelin-2026-taiwan.md` sha256 `b2ba863c...da1c5` (correct).

**3. Pre-stage simulation.** Germany method, ASCII `U&'...'` input, guard md5 of `line|name|city|country|cat` = `322532608a62af6f0d2157be03355f3c`. Result 90 match, 114 new_venue, 3 review_venue (A and T+T `norm_key_too_short`; Sushi Akira `same_key_other_city`, twin in Tokyo `ve_b7caedad34`). Run-1 md5 (`line|verdict|reason|venue_id`, blanks for null) `4a275bb132587d0e19d0c0835b76501d`. Legacy list md5 (`award_id|venue_id|category|year`) `a621843cf0631efc8f5ba1367ad5bef5` (175 rows).
- **Finding:** an alias `new taipei` -> Taipei existed (first data load, no audit row). The brief handoff did not see it. 14 Taipei venues carried the Michelin label "New Taipei" (neighborhood).

**4. Ben's decisions (Oct 11, 20:31).**
- **Q1 = B:** New Taipei City is a separate city, added before the stage.
- **Q2 = A:** the 31 open Bib lines whose only candidate was a venue with another business name become `new`; the legacy rows go to a contamination register.
- Claude's call inside Q1 (stated in the file, Ben's "go" accepted it): move only the 7 venues that a 2026 New Taipei card confirms. The other 7 "New Taipei" label venues stay in Taipei (their names are other businesses; some are Taipei places, for example Da-Wan yakiniku, Yong He Soya Milk King (Da'an)).

**5. Step A: New Taipei City (Ben "go" 20:37).** File `docs/cities-michelin-2026-taiwan.sql` (222 lines, ASCII, sha256 `f99325c1fc409cfe29f6030ea03e484be6999108468d3e2a04b866bede382b6a`, repo `7ebbe6f`/`00309b2`). Plan fingerprint (`venue_id|name|city_slug|old_slug|new_slug`) `e99095f737a6712ac2d10572794a711e`. Dry run (Read connector) passed all PRE gates and stopped at the first INSERT; POST resolution tested read-only with virtual rows (6 of 6 labels). **Write connector committed first time, Oct 12 00:38:33 UTC.** Audit **111,205-111,227** (23): cities INSERT 1, city_aliases UPDATE 1 (hand), venues UPDATE 7, slugs UPDATE 7 + INSERT 7. No ledger row.
- City `ci_dc8224da29`, display "New Taipei City", slug `new-taipei-city`, Taiwan, TW, kind city. Alias `new taipei` now -> `ci_dc8224da29`.
- Moved: GARDENh `ve_6ee0642103`, San Tung `ve_76907429c5`, Shang Hao `ve_6d9c2d924e`, Song Jhao `ve_1db6f458ea` (new slugs = old slug text), 阿爸の芋圓 樂華店 `ve_8c951102be` (`new-taipei-city-29a714`), 店小二魯肉飯 `ve_ea349b8773` (`new-taipei-city-a39aba`), 光興腿庫 `ve_14ca1bc485` (`new-taipei-city-842841`). Old `/taipei/...` slugs are non-canonical.
- Re-simulation: only the 18 New Taipei lines changed (city now New Taipei City via alias); every verdict and the run-1 md5 unchanged.

**6. Decisions file.** `fixtures/ingest/michelin-2026-taiwan-decisions.csv`: 118 lines (header + 117), all quoted, CRLF, sha256 `c9943b9e433c231f81b1a8fa587b60ec6e9257e6099564e4c3c6951024244f15`, repo `00309b2`/`7ebbe6f`. Built by script.
- 56 `use:`: same Chinese name 27 (the card's `venue_name_zh` against the stored name, bracket part removed), same English name 17, Chinese name start 2, URL tail 1 (T+T), other 9 (A -> "Taipei" `ve_269ab60a27`; Yu Kapo -> Yu Kappo; Mountain and Sea House -> OAD venue `ve_0fcffab802`; romanization pairs Huang Chi Lu Rou Fan, Jen Ho Yuan, Hao Nung Chia Migao, Hsi Lo Tien Beef Soup, Po Jen Tang, Shang Hao Chih Beef Soup). Golden Formosa -> OAD venue `ve_ecaf898f47`. Live check: 56 of 56 active, same city, use-list md5 `e9b735b4b37d4e7c5191534ccfbef540`.
- 61 `new`: 21 newcomers, 9 legacy gaps (A Cut, Ad Astra, aMaze, Ban Bo, Fujin Tree, Molino de Urdániz, Sushi Akira, Sushi Kajin, Tien Hsiang Lo), 31 by Q2 = A.

**7. Stage (batch 17).**
- **Run 1** (Ben, Oct 12 00:45:56 UTC): = prediction (md5 `4a275bb1...501d` both sides; staged URL md5 `dcce489a457f8b242c7200ab1e31ccc0` = CSV). Review CSV 3 rows.
- **Run 2** with decisions (Ben, 00:48 UTC): md5 of `line|verdict|venue_id|decision` = `6a853414d04582ff23a6b59e0f553755` both sides. 146 match (3 / 7 / 34 / 102) on 146 venues + 61 new_venue (0 / 2 / 15 / 44) in 61 groups; 0 other.

**8. Promote.**
- **Dry run** (Ben, 00:49 UTC): 11 of 11 invariants pass; rolled back; used ledger 124-125 and audit 111,228-111,617.
- **Real promote** (Ben's run = "go", committed **Oct 12 00:49:54 UTC**): ledger **126** (michelin, award, 207) and **127** (michelin, city_label, 122), job `ingest-promote:michelin-2026-taiwan`. Audit **111,618-112,007** (390, all INSERT, one timestamp): venues 61, listings 61, slugs 61, awards 207. Award ids **29,301-29,507**.
- Row check: 207 of 207 rows have exactly one award; 207 distinct URLs; category = staged row, no rank, no distinction; all TW; 146 of 146 matches on the decided venue; 61 of 61 new venues carry the card name and card city, each with 1 award, 1 listing, 1 canonical slug, 2 city labels, all active; new venue ids = dry-run ids. The 175 legacy 2025 TW rows are all still there. 1 award sits on a closed venue: JL STUDIO (open item 1).
- New venues by city: Taipei 16, New Taipei City 11, Tainan 11, Kaohsiung 9, Hsinchu County 6, Hsinchu City 4, Taichung 4. New Taipei City now holds 18 venues. Report `reports/michelin-2026-taiwan-promote.md` lists every new venue id and URL.

## Legacy rows with no 2026 card (36, kept as 2025 history)
- **Dropped from the guide (6):** Fleur de Sel 8393 `ve_3fe7f73a2c` (One Star, now Selected, stays active); Bue mi .Lab 12440 `ve_066411c152` (closed, page "Restaurant not found"); Taipei Bibs 好朋友涼麵 12469 `ve_cf3cd8e9b7`, Mao Yuan Restaurant 12481 `ve_2403133c13`, Shin Yeh Shiao Ju (Nangang) 12486 `ve_61332f7e56`, Xiao Ping Kitchen 12498 `ve_2cf8e5b121`.
- **Contamination register (30 Bib rows; stored name is another business or not provable):**
  - Hsinchu City: Norest Cattery 10618 `ve_565d8cb24a`, Hsinchu Dongmen Market 10619 `ve_bcc0cd9ac9`, Lakeshore Hotel Hsinchu Metropolis 10621 `ve_c5bdb04069`, HoChu Yuan 10623 `ve_ff2c645a20`.
  - Hsinchu County: CHIN HUNG FOUNDRY MACHINERY 10627 `ve_6a29f13cd7`, 深山裡柴燒蘿蔔糕 10628 `ve_d82cc20325`, Din Tai Fung 10632 `ve_bbb0563a6a`.
  - Kaohsiung: Cheng Tsung Duck Rice 10704 `ve_6025c41938`, Qixian Duck Rice 10706 `ve_370aa54da0`, Din Tai Fung Kaohsiung Branch 10708 `ve_e929296edb`, Duck Zhen 10709 `ve_ff77e7b352`, Mi Casita 10715 `ve_0bf4310fe5`, 賣塩順台菜 10716 `ve_02b8c23984`, 白玉樓經典台菜 10718 `ve_96994a1e21`, Yung-an Salt Evaporator Area 10722 `ve_6f7474caab`.
  - Taichung: 佑建興製麵廠 12426 `ve_6593c6d776`.
  - Tainan: Du Hsiao Yueh Restaurant 12442 `ve_e57f049689`, Dong Shang Taiwanese Seafood 12444 `ve_7eb5839370`, Chou's Shrimp Rolls 12449 `ve_120732362b`, Wu Ming Mutton Soup 12453 `ve_9249a1737a`, Ji Pin Shrimp Rice 12457 `ve_9bb7b57e39`, 慶平海產 12459 `ve_49791827ea`, 筑馨居 12463 `ve_d851917163`.
  - Taipei, "New Taipei" label: Da-Wan 11352 `ve_1972d080fc` (OAD 2025 No. 419; Taipei yakiniku), 臻品實業股份有限公司 11357 `ve_9372d12543`, KANG Artisan Bakery 11358 `ve_e25c8026ee`, Fon-Cé 11359 `ve_e8331a52a7`, Di Yi Beef Noodle Restaurant 11363 `ve_26371de8b1`, Chen Tung Pork Ribs Medicinal Herbs Soup 11364 `ve_ac1ee79102`, Yong He Soya Milk King (Da'an) 11365 `ve_91f8ccee47`.
  - Count logic (2025 vs 2026 articles): Hsinchu City and Hsinchu County and New Taipei dropped 0 Bibs, so their register rows are real 2025 Bibs on wrong venues; Kaohsiung dropped 3, Tainan 3 (incl. Bue mi .Lab), Taichung 1, so some register rows there can be true drops. Da-Wan has another publisher (OAD): delete only the Michelin row, not the venue.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-taiwan.csv` | In the repo | `835d3cc2...b046` |
| `docs/michelin-2026-taiwan-log.md` | In the repo | `1ecfbc81...964e` |
| `docs/cities-michelin-2026-taiwan.sql` | Run (audit 111,205-111,227), in the repo | `f99325c1...2b6a` |
| `fixtures/ingest/michelin-2026-taiwan-decisions.csv` | Applied in run 2, in the repo | `c9943b9e...4f15` |
| `reports/michelin-2026-taiwan-stage.md` / `-review.csv` | Written by the stage job (`70438c7`, `32a016b`) | - |
| `reports/michelin-2026-taiwan-promote.md` | Real run | - |

## Methods that worked (new)
- **Chinese-name pairing:** compare the card's `venue_name_zh` (bracket part removed) with the CJK characters of the stored name: substring either way, or a shared start of 3 or more characters. 29 of the 56 pairs came from this.
- **Count logic per city bucket:** 2025 article count minus legacy rows = missing rows; 2026 cards minus newcomers = continuing; a bucket with 0 drops means every legacy row is a real 2025 Bib (useful for the register).
- **Large result to disk on purpose:** add a padding column (`repeat('p',300)`) so the Read result is saved to a file; then parse it with md5 guards.
- **City move with slugs:** venues.city_id UPDATE (the rename guard fires on name only), old canonical slug -> non-canonical, new canonical slug in the new city; CJK names use the `slug.ts` fallback `<city>-<md5(city:name)[:6]>`.

## Dead ends: do not retry (new)
- Elimination pairing onto a venue whose stored name is another business (for example Da One Gone Lamb -> Da-Wan): it merges two real venues.
- A column alias named `year` in a UNION header row (syntax error); use `yr`.

## Open items, in order
1. **JL STUDIO status** `ve_506425696b` (Taichung): `closed` in the database, but a live 2026 Three Stars card (award on batch 17), no closure note on the page. Standing rules -> `active`. Status-only file (Netherlands status method).
2. **Taiwan rename CSV** (Texas / Netherlands method, vote + tie rule; population: batch-17 awards joined by `source_url`, card name <> `venues.name`). Includes "Taipei" -> A `ve_269ab60a27`, EIKA 盈科, Yu Kappo, Mudan, Motoichi, Ming Fu, Ken Anho, Sho, the FRONT HOUSE, Sur-, WOK by obond, Impromptu by Paul Lee (with an address in the name), the Chinese-name venues (Liang Chia Pig Knuckle, NIU LAO DA and others), A-Mei Restaurant, Garden.V Restaurant, Golden Formosa Taiwanese Cuisine, Mountain & Sea House Restaurant, MUME, HOSU. Chef-suffix and "by" rules apply (Impromptu by Paul Lee, Tableau by Craig Yang, La Vie by Thomas Bühner).
3. **Taiwan slugs** for the renamed venues (slug-file method), incl. the 3 `new-taipei-city-xxxxxx` and the other CJK fallback slugs.
4. **Taiwan contamination register** (30 rows above): per row, Ben decides (Chengdu held-7 method; delete the Michelin row, and the venue only when it holds nothing else). Read the 2025 Taiwan Bib article first for the Kaohsiung/Tainan/Taichung true drops.
5. `name_native` for Taiwan from `venue_name_zh` (part of item 9 of the brief handoff list).
6. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
7. **Switzerland after Nov 2, 2026** (option A, promote only).
8. **Gap list after Taiwan:** promote-only Singapore; retire-path Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; Thailand after its 2027 edition; Canada as three guides.
9. Hold registers: Texas, Belgium & Luxembourg, Netherlands, Taiwan (9 Green Stars; Service Cindy Tsai (Circum-), Sommelier Bonnie Chiou (Li.nu, Selected, no venue), Young Chef Liu An Hsu (Sushi An `ve_fd14ae57be`), Opening of the Year Yu Dao `ve_ab005c1886`) -> special-awards batch.
10. Price from the Michelin card (adds the 207 Taiwan `$` cards: $ 86, $$ 64, $$$ 20, $$$$ 37). Ben chooses the method.
11. Carried from the brief handoff: items 8-17 (France slugs, name_native backfill, later-ceremony guides, carried rename CSVs, rechecks, Ben's decisions list incl. `cities.venues_count` recount (New Taipei City shows 0), repo `.env` keys, Plan v1.31 (add this session), options B and C, project cleanup part 2).

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-taiwan-promoted-2026-10-11.md first, then claude/handoff-netherlands-status-done-2026-10-11.md for the status-only file method, then claude/handoff-netherlands-renamed-2026-10-11.md for the rename record and working rules, then claude/handoff-texas-done-2026-10-10.md for the rename-CSV and slug methods. Confirm live counts, ledger id 127, audit_log id 112,007 and slugs 12,777 with a Read query. Then start open item 1 (JL STUDIO status file) and open item 2 (the Taiwan rename CSV with the vote and tie rules): build both, examine them read-only, and ask me the questions the rules do not decide. No write before my go.
```
