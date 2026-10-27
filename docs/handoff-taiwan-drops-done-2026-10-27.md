# Handoff: CompassEats, Oct 27, 2026 (12:30 Atlanta). Taiwan true drops done: 5 card checks (all stay active), rename batch 26 (3 venues, ledger 132, audit 112,458-112,460), slug file (audit 112,461-112,466). Next: `name_native` for Taiwan.

This file replaces `claude/handoff-taiwan-contamination-done-2026-10-13.md` for live state, decisions, open items, methods and dead ends. That file still applies for the contamination cleanup record (ledger 130, audit 112,279-112,454, the 24 deleted venues, Da-Wan, the UDN 2025 Bib list method, the SQL Editor fallback). The other files still apply as before:
- `claude/handoff-taiwan-renamed-2026-10-11.md`: JL STUDIO status (audit 112,008), rename batch 24 (ledger 129, audit 112,084-112,158), slug file (audit 112,159-112,278).
- `claude/handoff-taiwan-promoted-2026-10-11.md`: Taiwan stage and promote (batch 17, ledger 126-127), New Taipei City, the 36 legacy rows with no 2026 card.
- `claude/handoff-taiwan-brief-2026-10-11.md`: the Taiwan facts, city ids, URLs.
- `claude/handoff-netherlands-renamed-2026-10-11.md`: working rules, the vote and tie rules, the chef-suffix-before-vote method, the "by" rule.
- `claude/handoff-netherlands-status-done-2026-10-11.md`: the status-only file method, the Michelin card status method.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: database notes, the gated venue-delete method.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9...672216`, checked Oct 27).

Working rules (unchanged): plain `/ste` replies; populations on every count; one "go" per write batch; read-back after each commit; under-merge over over-merge; no competitor sources; no hand-retyped files; build, examine read-only, present, then ask; the tie rule (vote first; in a tie or doubt the venue's own spelling, Michelin fallback); nothing below a Michelin Bib is tracked; only closure evidence gives `closed`; Ben starting a stage, promote or real rename job is his "go".

## Live state
Population: whole table. Read Oct 27, 16:27 UTC (12:27 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,291 (active 10,924, closed 367) |
| awards | 22,841 |
| Michelin 2025 / 2026 / 2027 rows | 3,520 / 5,527 / 47 |
| listings / slugs | 11,291 / **12,816** (canonical 11,291, non-canonical **1,525**) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,259 / 259 / 23,979 |
| price / blurbs / redirects | 7,024 / 142 / 9 |
| venues with `name_native` | 18 |
| source_capture_ledger | **91** (last id **132**) |
| audit_log | **107,323** (last id **112,466**) |
| ingest_batches | 1, 3-17 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, 22, 24, **26** applied (25 = rolled-back dry run). rename_rows **1,102**. Sequence last value 26. |

## Done in this session (Oct 27, 12:08 to 12:30 Atlanta)

**Start check:** all counts, ledger 130, audit 112,454, slugs 12,813 matched the Oct 13 handoff. Ben moved `cleanup-michelin-tw-2025-contamination.sql` to `docs/` (commit `3716fd5`, Oct 27 12:07); sha256 `0cbee3c9...7043f20` correct. Old open item 2 is closed. Ben also uploaded the Oct 13 handoff to the repo (`8abb90f`).

**1. Live Michelin cards of the 5 true drops (built-in browser, Oct 27).** Method: same-origin `fetch` + DOMParser of the `/tw/en/` and `/tw/zh_TW/` cards (status, h1, badge count, meta), plus the rendered `window.dataLayer` `distinction`.

| Award | Venue | Card today | Result |
|---|---|---|---|
| 10704 | `ve_6025c41938` Cheng Tsung Duck Rice | 200, 0 badges, `plate` (Michelin id 142762) | Selected |
| 10716 | `ve_02b8c23984` (now Mai Yen Shun) | 200 "Mai Yen Shun" / "賣塩順", 0 badges, `plate` (142969) | Selected |
| 12463 | `ve_d851917163` (now Zhu Xin Ju) | 200 "Zhu Xin Ju" / "筑馨居", 0 badges, `plate` (142790) | Selected |
| 10718 | `ve_96994a1e21` (now Pale Jade Pavilion) | 404 "Restaurant not found" (en, zh, `/us/en/`) | not in the 2026 guide |
| 12444 | `ve_7eb5839370` Dong Shang Taiwanese Seafood | 404 "Restaurant not found" (en, zh, `/us/en/`) | not in the 2026 guide |

- None holds a 2026 Bib card: no batch-17 capture gap. All 5 are true drops.
- Michelin site search (`/tw/en/restaurants?q=` and `/tw/zh_TW/restaurants?q=`; "Pale Jade", 白玉樓, 東香, "Dong Shang"): no Taiwan card for either 404 venue.
- No closure evidence found for either 404 venue (web search, Chinese and English). Blog posts show them open in 2024-2025 (angelala.tw Nov 2024 for 白玉樓 Dream Mall 6F; bigmouthblog, ifoodie for 東香). 白玉樓經典台菜 also has a Taipei branch (統一時代百貨 7F, bunnyann.tw Jun 2026); not our venue.
- Rule (Plan v1.30 Sep 28 standing rules + Oct 10 ruling, Dill precedent): a 404 card is not "Michelin marks closed"; no closure evidence → **all 5 stay `active`**, 2025 Bib rows stay as history. No status write.

**2. Rename (batch 26, key `rename-michelin-2026-taiwan-drops`).**
- Population: the 3 true drops with Chinese live names (handoff open item 1). Michelin is the only publisher on all 3 → card name; English card name by Ben Q3 A (Oct 11) precedent.
- **Ben Q1 A (Oct 27):** 白玉樓經典台菜(夢時代6F) → **"Pale Jade Pavilion"** (Michelin 2025 English name from the card URL slug; card now 404; venue prints only 白玉樓經典台菜 on its Facebook page `facebook.com/profile.php?id=61564943219061`). B (venue Chinese name) and C (no rename) not chosen.
- File `fixtures/rename/michelin-2026-taiwan-drops-names.csv`: 3 rows, UTF-8, LF, sha256 `9f4ef8585cd4389812bbcc032154e2a55153c5072ddb5e8bb9603d474d32530d`, repo commit `93b5125`. Built by script (`build_tw_drops.py`): card names from a browser read with SHA-256 guard `39b365ee...d9d74b`; live names from a Read query (hex) with md5 guard `7d2c4296d670a7d11fb716f728969638`; Pale Jade name = title case of the card URL slug words. `loadRenameCsv`: 3 rows, 3 venues, 0 blank. md5 new (`vid\tname`) `b00f4d2d2c72a0a02963a819b035cf5b`.
- Read-only checks: 0 same-city or any-city `norm_key` collisions, 0 blurbs, 0 earlier rename rows, 0 non-canonical slugs. The 3 had `norm_key` null before (CJK names).
- Dry run (report `6f1a130`): 3 rename, 0 reject, 0 review, 10 of 10 invariants; downstream pairs md5 `e77007d3acf2f246398361a98c9513ac` = file. Used batch 25, ledger 131, audit 112,455-112,457 (rolled back).
- **Real run (Ben, Oct 27 16:20:16 UTC):** batch **26** `applied`; ledger **132** (michelin, name, 3, job `rename-apply:rename-michelin-2026-taiwan-drops`); audit **112,458-112,460** (3 `venues` UPDATE, name and norm_key only). Audit pairs md5 = file. Report commit `29c40e4`, sha256 `5b04b6ae904720b32716ff032363ce230b43f91e932f8480260be936cccba49b`.
- Live names now: Mai Yen Shun (`maiyenshun`), Pale Jade Pavilion (`palejadepavilion`), Zhu Xin Ju (`zhuxinju`).

**3. Slugs (`docs/slugs-rename-michelin-2026-taiwan-drops.sql`).**
- Built by script (`build_slugs_tw_drops.py`) from `docs/slugs-rename-michelin-2026-taiwan.sql` (hash checked): 30 rules, 31 counted replacements, new header, leftover check clean (regex literal removed first). 160 lines, ASCII, LF, sha256 `2991db54427a4fc7bd36108814f814431596126e3119b07da99b0e5747f28030`. pglast: 3 statements, body parses.
- Population: the 3 venues of batch 26; 0 keep, 3 plan rows; fingerprint `cfdd750c497dd12773c5c2471811e613`. Rule = `slug.ts` (sha256 `f22bf699...`) on 3 of 3.
- Checks: 0 empty, 0 duplicate, 0 in use, 0 in `redirects`, 0 older non-canonical. Dry run (Read connector, whole `DO` block) stopped at the first UPDATE.
- Ben "go" (12:24). Write connector, first try, **Oct 27 16:25:01 UTC**. slugs 12,813 → 12,816; non-canonical 1,522 → 1,525. Audit **112,461-112,466** (3 UPDATE + 3 INSERT, 1 timestamp, 0 rows on other venues). Audit pairs md5 `a43d157739adfd24517f0873c038a09a` = plan = live. No ledger row.
- New: `/kaohsiung/mai-yen-shun`, `/kaohsiung/pale-jade-pavilion`, `/tainan/zhu-xin-ju`. Old CJK fallback slugs (`kaohsiung-wdri98`, `kaohsiung-mmuvp8`, `tainan-nitl0s`) stay as non-canonical rows.
- Uploaded: repo commit `ebbb8f1` (Oct 27 12:27), sha256 correct.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/rename/michelin-2026-taiwan-drops-names.csv` | Run (batch 26), in the repo (`93b5125`) | `9f4ef858...d32530d` |
| `reports/rename-michelin-2026-taiwan-drops-rename.md` | Real-run report (`29c40e4`) | `5b04b6ae...f28c49b` |
| `docs/slugs-rename-michelin-2026-taiwan-drops.sql` | Run (audit 112,461-112,466), in the repo (`ebbb8f1`) | `2991db54...7f28030` |
| `docs/cleanup-michelin-tw-2025-contamination.sql` | Run (ledger 130), moved to `docs/` (`3716fd5`) | `0cbee3c9...7043f20` |

## Methods that worked (new)
- **Michelin site search for a 404 card:** `guide.michelin.com/tw/<lang>/restaurants?q=<name>` in the built-in browser, wait 3 s, read `.card__menu-content--title a`. The last few cards on the page are site-wide suggestions, not hits; check the count text ("1-1 of 1 Restaurants", or "沒有精選餐廳" = 0).
- **Card names with a browser hash guard:** one JS call fetches each card (en + zh), builds `vid\tstatus\th1\tstatus\th1\turl` lines, returns the text, base64 and SHA-256 (`crypto.subtle`). The build script decodes the base64 and checks the SHA-256 before use.
- **Name for a card that is gone:** title case of the card URL slug words, flagged in the CSV note, and only after Ben's choice.

## Dead ends: do not retry (new)
- `web.archive.org` through WebFetch: blocked ("SITE_BLOCKED"). Do not route around it.
- `audit_log` columns are `id, table_name, row_pk, action, old_row, new_row, at` (not `op`, not `changed_at`). `venues.status` is an enum: cast `status::text` before `string_agg`. `award_categories` has no `id` (`source_id, category`); filter Michelin rows by `awards.source_id`.

## Open items, in order
1. **`name_native` for Taiwan** from `venue_name_zh` (Ben Q3 A, Oct 11). Population first: Taiwan venues with a 2026 card; the 29 renamed Chinese-only venues of batch 24 are the priority. Add the 3 batch-26 venues from their live zh card names (賣塩順, 白玉樓 for Pale Jade from the 2025 list, 筑馨居): Ben decides the source for Pale Jade (no live card). Also the China 469 / Japan 585 / Chengdu 47 backfill.
2. **American South (after Oct 21; now due)**, promote only. Then Beijing & Tianjin after the end of October.
3. **Switzerland after Nov 2, 2026** (option A, promote only).
4. **Gap list after Taiwan:** promote-only Singapore; retire-path Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; Thailand after its 2027 edition; Canada as three guides.
5. Hold registers: Texas, Belgium & Luxembourg, Netherlands, Taiwan (9 Green Stars; four special awards) → special-awards batch.
6. Price from the Michelin card (Taiwan `$` cards: $ 86, $$ 64, $$$ 20, $$$$ 37; the Oct 27 cards show Mai Yen Shun $$, Zhu Xin Ju $$, Cheng Tsung $). Ben chooses the method.
7. JL STUDIO blurb (`needs_rewrite`): rewrite through the Option B runbook when blurbs come up.
8. **Rechecks, no date (added):** Pale Jade Pavilion `ve_96994a1e21` and Dong Shang Taiwanese Seafood `ve_7eb5839370` (Michelin card 404 Oct 27, no closure evidence). Carried: Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
9. Carried from the promoted handoff item 11 (France slugs, later-ceremony guides, carried rename CSVs, Ben's decisions list incl. `cities.venues_count` recount, repo `.env` keys, Plan v1.31 (add the Taiwan sessions, incl. the Oct 13 cleanup and this session), options B and C, project cleanup part 2).

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-taiwan-drops-done-2026-10-27.md first, then claude/handoff-taiwan-renamed-2026-10-11.md for the batch 24 record, then claude/handoff-taiwan-promoted-2026-10-11.md for the batch 17 record, then claude/handoff-netherlands-renamed-2026-10-11.md for the working rules. Confirm live counts, ledger id 132, audit_log id 112,466 and slugs 12,816 with a Read query. Then start open item 1, name_native for Taiwan: read the population (Taiwan venues with a 2026 card, the 29 Chinese-only venues of rename batch 24 first, plus the 3 venues of batch 26), compare the batch-17 venue_name_zh with the live name_native, build the gated file, examine it read-only, and ask me the questions the rules do not decide. No write before my go.
```
