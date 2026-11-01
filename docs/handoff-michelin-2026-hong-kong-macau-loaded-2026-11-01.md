# Handoff: Hong Kong / Macau Michelin 2026 loaded (relabel, stage, promote, cleanup). Nov 1, 2026 (11:00 Atlanta). Next: D9 Green Star file, then Ben chooses.

This file replaces `handoff-open-items-b10-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Michelin city rule (D7): `handoff-open-items-b2-done-2026-10-30.md`. Promote method:
`docs/handoff-germany-promoted-2026-10-08.md`, `docs/handoff-taiwan-promoted-2026-10-11.md`. Working rules and database notes:
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 1)
- 10:02 open item 1 (HK/Macau 2026): file check, match test, label question, decisions; no write before go.
- 10:14 "D1-9 all recommended": D1 = A (relabel legacy rows in place), D2 = A (Lai Ching Heen new venue), D3 = A (4 Bib cards
  new, 3 legacy rows to contamination), D4 = B (Dragon Inn new), D5 = A (Putien pair: card row on ve_73d901a8fe, legacy venue to
  cleanup), D6 = delete Duddell's 5409, D7 = keep Chiu Chow Delicacies 10529 as 2025 history, D8 = 2025 backfill later,
  D9 = A (5 Green Star 2026 rows in a small file after the promote; NOT DONE YET).
- 10:27 "Go" (relabel). 10:35 "Can you run that in chrome?" (stage). 10:43 "Go" (promote). 10:47 "start cleanup". 10:55 "go" (cleanup).

## Live state (read Nov 1, 15:57:16 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,300 (active **10,935**, closed **365**) |
| awards | **23,363** |
| price | **7,727** |
| slugs | **12,952** (canonical 11,300, non-canonical **1,652**); venues with other than 1 canonical slug: 0 |
| listings | 11,300 |
| city_label_source | **23,999** |
| source_capture_ledger | **154** rows, last id **204** |
| audit_log | **115,752** rows, last id **121,090** |
| cities.venues_count | sum **10,935**; cities that differ from the view: 0 |
| ingest_batches | batch **19** `michelin-2026-hong-kong-macau` promoted |
| Michelin 2025 / 2026 rows | 3,291 / 6,269 |
| HK/MO Michelin 2026 | **180** rows, 180 with card URL; HK/MO Michelin 2025 left: 10529 only |

## Done in this session
1. Start check: all b10 counts matched. Repo attached with push access. CSV sha256 `32d9839c...adbb` = log; 180 rows (HK 7/13/57/69,
   Macau 2/6/13/13); 0 duplicate URLs; 0 non-NFC. Missing vs article: HK Bib "Chiuchow Delicacies" (no card, "Restaurant not found").
2. Match test: 114 exact-key, 61 pairs, 5 none. **173 of 179 legacy rows (all labelled 2025) sat on a venue with a 2026 card of the
   same category** (Cristal Room Two Stars, China Tang / Sushi Takeshi One Star, the 2026 new Bibs): the label was wrong.
   File: `match-test-hkmo-2026-11-01.csv` (chat).
3. **Relabel** `docs/relabel-michelin-2026-hong-kong-macau-legacy.sql` (sha256 `d8490db8...445c`, commit `85568bd`): Write connector,
   first try, 15:29:35 UTC. 171 rows year 2025 -> 2026 + card URL. Ledger **197**; audit **120,822-120,992** (171).
4. **Stage** batch 19: run 1 (#39, Chrome) duplicate 112 / match 2 / new_venue 65 / review 1 = prediction. Decisions file
   `fixtures/ingest/michelin-2026-hong-kong-macau-decisions.csv` (66 lines: 60 use:, 6 new; sha256 `6c744582...7876`). Run 2 (#40)
   duplicate 172 / match 2 / new_venue 6 = prediction.
5. **Promote** (#42, 15:43:35 UTC; dry run #41 passed 11/11): awards +8 (30123-30130), venues +6, ledger **200-201**, audit
   **121,019-121,044**. New venues: Lai Ching Heen `ve_403f3ed56b`, Dragon Inn `ve_e49568f69f`, Eton `ve_35baee2d3a`, Eng Kee
   Noodle Shop `ve_01b130259b`, Sang Kee Foods (Western District) `ve_b02a3e951b`, An Choi `ve_85e880a028`.
6. Reads for the cleanup: Putien card address "Lee Theatre Plaza, 99 Percival Street, Causeway Bay" (WebFetch); OAD Asia 2025
   (Chrome): No. 79 Lai Ching Heen HK, No. 352 "Lai Heen" (OAD page address Ritz-Carlton Macau); La Liste "Lai Ching Heen (Yan Toh
   Heen)" 92.5, Top 1000 2026 (Chrome).
7. **Cleanup** `docs/cleanup-michelin-2026-hong-kong-macau.sql` (sha256 `5d5c440a...34dd`, commit `ac3822b`): Write connector, first
   try (DELETE accepted), 15:57:01 UTC. Ledger **202** (michelin 7), **203** (oad 2), **204** (la-liste 1); audit
   **121,045-121,090** (46). Deleted Michelin rows 5409, 10532, 10534, 10535, 10562, 10591, 18227; venues 3D Inn, Eaton HK,
   Ocean Park, Ying Kee Noodle deleted (old URLs 404); merged Putien (Lee Theatre Plaza) -> ve_73d901a8fe and HK "Lai Heen"
   -> Lai Ching Heen (old slugs non-canonical; price rows moved); OAD 79 + La Liste 92.5 -> Lai Ching Heen; OAD 352 -> Macau
   Lai Heen `ve_cdd31cd894`.

## Methods that worked (new)
- **Label test before a promote:** compare each legacy row's category with the 2026 card on the same venue; 100% agreement with 2026
  (and disagreement with the 2025 article) = wrong label -> relabel in place (year + URL), then stage gives `duplicate`.
- **Stage via GitHub CLI:** `gh workflow run ingest-stage.yml -f csv_path=... -f batch_key=... -f decisions_path=...` and
  `gh workflow run ingest-promote.yml -f batch_key=... -f "confirmation=PROMOTE <key>" -f dry_run=true|false`, then
  `gh run view <id> --log`. The Chrome form for the workflow lost typed values twice (panel re-render); CLI is reliable.
- **OAD restaurant page** `https://www.oadguides.com/restaurant/<slug>` gives the address behind a list entry.

## Open items, smallest first
1. **D9 Green Star 2026 (approved, not done):** 5 rows, URL = venue page: Amber `ve_8278ead889`, Feuille `ve_17e6e908f5`, Mora
   `ve_59d40bfdec`, Roganic `ve_65d8ce2624`, UTM Educational Restaurant `ve_4ec07a8222` (log part 13). Small gated INSERT file.
2. HK/MO rename batch (R1-R5, site reads): 87 paired names differed from the card on Nov 1 (for example "Tin Lung Heen | The
   Ritz-Carlton, Hong Kong", "Cafe Hunan" -> Prof Chan's (Western District), "Joel Robuchon" -> L'Atelier de Joel Robuchon).
3. HK/MO name_native from `venue_name_zh` (180 rows; 0 HK/MO venues have name_native).
4. HK/MO price from the card (170 agree; differ: Run, Sun Tung Lok, Feuille; none: Ando, 6 new venues). With open item 6 below.
5. Register: Xin Rong Ji twin `ve_4dc9197f86` (OAD 2025 No. 14) vs `ve_f966b7e0a1`; Mesa (2 Macau venues, Selected only);
   Chiu Chow Delicacies `ve_d7e57d1d84` status ("Restaurant not found", 2026 article still names it); HK Zuicho closed; 4 special
   awards (Young Chef Sol, Service The Huaiyang Garden, Sommelier Caprice, Mentor Chef Tin Lung Heen) -> special-awards batch.
6. D8: HK/MO 2025 history backfill from web.archive.org capture 20251229115831 (with all-guides 2025 URL item).
7. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash
   slugs with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); 2025 Green Star backfill; legacy price rows outside Turkey;
   2025 Michelin URLs all guides; Beverly Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late
   Nov; Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Files
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-hong-kong-macau.csv` / `docs/michelin-2026-hong-kong-macau-log.md` | Input | `32d9839c...adbb` / `8ddf6780...9df` |
| `docs/relabel-michelin-2026-hong-kong-macau-legacy.sql` | Run (ledger 197) | `d8490db8...445c` |
| `fixtures/ingest/michelin-2026-hong-kong-macau-decisions.csv` | Applied (stage run 2) | `6c744582...7876` |
| `docs/cleanup-michelin-2026-hong-kong-macau.sql` | Run (ledger 202-204) | `5d5c440a...34dd` |
| `docs/hkmo-2026-build/` (relays, build scripts, run records) | Build | - |

## Suggested opening prompt
```
Read claude/handoff-michelin-2026-hong-kong-macau-loaded-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 204,
audit_log 121,090, venues 11,300, awards 23,363, slugs 12,952 and cities.venues_count sum 10,935. Then build open item 1
(the 5 Hong Kong / Macau Green Star 2026 rows, D9 = A), dry run it, and show me in /ste style. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
