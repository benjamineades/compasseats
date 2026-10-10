# Handoff: CompassEats, Oct 10, 2026 (10:25 Atlanta). Michelin Texas 2026 promoted (batch 14). Next: Texas rename CSV, then slugs and cleanup.

This file replaces `claude/handoff-briefs-texas-belgium-2026-10-09.md` for live state, decisions and open items. The other files still apply as before:
- `claude/handoff-briefs-texas-belgium-2026-10-09.md`: the Belgium & Luxembourg and Switzerland facts per guide, Ben's Oct 9 decisions (order, Switzerland option A, Luxembourg in the Belgium batch), the France slug-set read.
- `claude/handoff-plan-v130-done-2026-10-09.md`: the Plan v1.30 record, the plan-edit and fact-check methods.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit, the staged-row check, the stage dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`): the Sep 14 name rulings, rule 2.1.1 (amended Sep 24), rule 2.1.7.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.
- Plan versions, briefs and handoffs are saved to the project over the same name (`project_write` with `local_path`).

## Live state
Population: whole table. Read Oct 10, 14:23 UTC (10:23 Atlanta), after the promote.

| Table | Count |
|---|---|
| venues | **11,232** (active **10,868**, closed 364) |
| awards | **22,462** |
| Michelin 2025 / 2026 / 2027 rows | 3,791 / **4,877** / 47 |
| Michelin rows with `source_url` | **4,336** |
| listings / slugs | **11,232** / **12,566** (canonical **11,232**, non-canonical 1,334) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,251 / 258 / **23,868** |
| price | 7,048 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **76** (last id **104**) |
| audit_log | last id **109,286** |
| ingest_batches | 1, 3–14 promoted (no id 2). **14 = `michelin-2026-texas`, promoted Oct 10 14:21:59 UTC** |
| rename_rows | 825 |

## Done in this session (Oct 9 01:10 to Oct 10 10:23, Atlanta)

**Start check (Oct 9):** all counts, ledger 100, audit 109,086 matched the briefs handoff. Brief `docs/cowork-michelin-2026-texas.md` sha256 `9bad2438…14cce186` (correct).

**Cowork capture (Texas 2026), in the repo:**
- `fixtures/ingest/michelin-2026-texas.csv` (74 lines) sha256 `018083df425fcc30338b09dd2997f7f6caa1393fac547389617dbb64ecd4c728` = the hash in the log. Commit `24f5c7e`.
- `docs/michelin-2026-texas-log.md` (211 lines) sha256 `a3f2d435f1989acd2919f4da661d0b2d12fb5caf410d93183722bb3decf5ef24`. Commit `655bb96`.
- 73 rows: One Star 19 (Austin 7, Houston 5, San Antonio 3, Dallas 2, Fort Worth 1, Spring 1), Bib 54 (filter 54). Banner and filter differences 0. 73 distinct URLs, all `/us/en/texas/`. Block hashes and full-data hash `5dabb8d0…707cda` recomputed from the CSV: match. Prices `$` 8, `$$` 40, `$$$` 10, `$$$$` 15. Region slug `texas`. Selection total 149 (19 + 54 + 76 Selected).
- 2025 → 2026 stars: out la Barbecue (page live, now Selected) and Olamaie (page "Restaurant not found"); in Fabrik, Kappo Kappo, Goldee's. 18 − 2 + 3 = 19.
- Bib article lists 55; the extra one is **Lucia** (Dallas), page shows no award (`plate`), not in the site list or filter. Cowork followed the site (54). Ben to decide (open item).
- Card cities outside the 9 brief cities: **Pearland** (Killen's BBQ), **Seguin** (Burnt Bean Co.). Both exist in `cities`.

**Correction to the briefs handoff:** the Texas legacy population is **66 rows on 66 venues** (One Star 16, Bib 50), not 63. Three Bib rows are in cities the brief did not list: Pearland (Killen's Barbecue `ve_d9e28a8c8e`), Seguin (Burnt Bean Company `ve_07202716ee`), West University Place (Maximo `ve_a278b8a6da`, city `ci_d494b26f25`). Checked against every US city with a Michelin row.

**Read-only pre-stage simulation** (Germany method; md5 guard `68531250a53f197e911609df325eef16`): all 11 card cities resolve to one US city. Prediction 54 `match` / 17 `new_venue` / 2 `review_venue` `same_key_other_city` (Annam → An Nam Hong Kong; Maximo → Máximo Mexico City and Maximo West University Place). **Stage run 1 = the prediction, 73 of 73 rows (verdict and venue id).**

**Hidden pairs found** (8 of the 17 `new_venue` rows hide a legacy venue): Le Jardinier, Goldee's, Rosemeyer, Killen's (Pearland), nonna, Micklethwait, Veracruz, Burnt Bean. Plus the 2 review rows (Annam, Maximo). The other 9 rows are truly new (whole-table name search: no Texas venue).

**Ben's decisions (Oct 9):**
1. Maximo: **option A**, `use:ve_a278b8a6da`; the venue stays in West University Place.
2. nonna → "Nonna | Tabu" `ve_45bf3594ba`: **yes**.
3. Killen's BBQ → Pearland `ve_d9e28a8c8e`: **yes**; the Houston "Killen's" `ve_6034ffec5f` (Bib 2025, award **10600**) goes on the cleanup list.

**Decisions file** `fixtures/ingest/michelin-2026-texas-decisions.csv`: 11 lines (10 `use:` rows: lines 2, 9, 20, 34, 36, 41, 50, 53, 55, 68), built by script with a CSV hash guard, sha256 `e681e810b8d8aea3e7766e2e968569ffc5648b67a476abeb39655df99b673d94`. Uploaded by Ben, commit `5c83455`; checked byte-for-byte in a fresh clone.

**Stage run 2** (Oct 10 14:19 UTC): 64 `match`, 9 `new_venue`, 0 review, 0 duplicate = prediction, 73 of 73 rows. Staged `source_url` md5 `87900ea05bf784ed735bde41a3367bab` = the CSV.

**Dry-run promote** (Oct 10 14:21 UTC): all 11 invariants pass; rolled back; read after: no change. It used up ledger ids 101–102 and audit ids 109,087–109,186.

**Promote** (Ben ran the job, Oct 10 14:21:59 UTC):
- awards +73 (ids **28135–28207**), venues +9, listings +9, slugs +9, city_label_source +18, price 0, ledger +2.
- Ledger **103** (michelin, award, 73) and **104** (michelin, city_label, 18), job `ingest-promote:michelin-2026-texas`.
- Audit **109,187–109,286** (100 rows: awards 73, venues 9, listings 9, slugs 9; INSERT).
- Read-back: 73 rows, 73 URLs = staged rows; category = card on 73; rank and distinction null on 73; 64 on the planned existing venues, 9 on the new venues.
- New venues (each active, published, 1 listing, 1 canonical slug, 2 city labels): Kappo Kappo `ve_a195aa4251`, Fabrik `ve_89a19471a1`, LeRoy and Lewis Barbecue `ve_b8f74cf2b7` (Austin); Khói Barbecue `ve_19487f4036`, Kitchen Rumors `ve_c28c3793ac`, Xolo `ve_e33e161b48`, Bar Buena `ve_99ef79d850`, Murray's Pizza & Wine `ve_efdb19e12c` (Houston); Resident Taqueria `ve_06fd2951bb` (Dallas).
- Goldee's: 2025 Bib 10202 + 2026 One Star 28143. Maximo: 2025 Bib 10602 + 2026 Bib 28175.
- All 66 legacy 2025 rows stay as 2025 history (amended rule 2.1.1). No retire batch.

## Rename candidates (for open item 1)
Population: the 64 `match` rows of batch 14. 18 venues where the card name ≠ `venues.name`. Apply the Sep 14 rulings (majority of publishers; no publisher suffix; confirm dashes; one-vs-one tie → venue's own site).

| Line | Card | Database | Venue |
|---|---|---|---|
| 2 | Le Jardinier Houston | Le Jardinier | `ve_2d80e6f1be` (card adds the city: likely keep the DB name) |
| 9 | Goldee’s Bar-B•Q | Goldee's Barbecue | `ve_643b43e09f` |
| 12 | InterStellar BBQ | Interstellar BBQ | `ve_0ef83029cf` |
| 17 | Nicōsi | Nicosi | `ve_f61163430a` |
| 20 | Rosemeyer Bar-B-Q | Rosemeyer Bar-B-Q (Food Truck) | `ve_cca4f35717` |
| 28 | Casaema | CasaEma | `ve_87f46d270a` |
| 29 | da Gama Canteen | da Gama canteen | `ve_abdb64f6ae` |
| 34 | Killen's BBQ | Killen's Barbecue | `ve_d9e28a8c8e` |
| 36 | Annam | Annam Vietnamese Restaurant | `ve_ad96e779fa` |
| 37 | nobie's | Nobie's | `ve_3c2ad8d111` |
| 42 | Blood Bros BBQ | Blood Bros. BBQ | `ve_cac24c5056` |
| 47 | Một Hai Ba | Mot Hai Ba | `ve_3ceab91f49` |
| 50 | nonna | Nonna \| Tabu | `ve_45bf3594ba` |
| 53 | Micklethwait Craft Meats | Micklethwait Barbecue | `ve_940cdef65f` |
| 55 | Veracruz Fonda & Bar | Veracruz Fonda and Bar | `ve_3fbb33695d` |
| 58 | Kemuri Tatsu-ya | Kemuri Tatsu-Ya | `ve_4c0b829f4f` |
| 68 | Burnt Bean Co. | Burnt Bean Company | `ve_07202716ee` |
| 70 | Cullum's Attaboy | Cullum’s Attaboy | `ve_8dbf8709c5` (apostrophe only) |

Several are case-only or punctuation-only (12, 28, 29, 37, 58, 70): ask Ben whether case/apostrophe differences go in the CSV. Le Jardinier and Annam likely need a ruling (city added; shortened name).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-texas.csv` | In the repo | `018083df425fcc30338b09dd2997f7f6caa1393fac547389617dbb64ecd4c728` |
| `docs/michelin-2026-texas-log.md` | In the repo | `a3f2d435…decf5ef24` |
| `fixtures/ingest/michelin-2026-texas-decisions.csv` | In the repo | `e681e810…9b673d94` |
| `reports/michelin-2026-texas-stage.md` | Written by the job (run 2) | `068c4bf6…4e66fb` |
| `reports/michelin-2026-texas-review.csv` | Written by run 1 only (2 rows); run 2 did not rewrite it | `0a2380fb…43439e` |
| `reports/michelin-2026-texas-promote.md` | Written by the job (real promote, commit `f3a153b`) | `e3faffd4…af40f72` |

## Methods that worked (new)
- **Simulation + legacy population in one pass:** after the simulation, list every venue in the card cities (and every US city with a Michelin row) that holds a Michelin row and is not matched. That gave all 8 hidden pairs and the 3 unpaired legacy venues in one query.
- **Row-level stage check:** a `VALUES (line, verdict, venue_id)` list of the prediction, `full join` to `ingest_rows` on `(validation->>'line')::int`, count agreements and list differences.
- **Dry-run proof:** read counts, ledger max and audit max after the dry run, plus a check that the report's new venue ids do not exist.

## Dead ends: do not retry (new)
- Expecting price rows from a Michelin promote: `award_sources.michelin.price_capable` is false, so the job writes 0 price rows (stage report says so). Price from the card stays open item 7.
- `ingest_rows.raw->>'line'` (null). The line is `validation->>'line'`; the venue is `validation->>'venue_id'`; the decision is `validation->>'decision'`.
- Reading `reports/<batch>-review.csv` after a decisions run: the job does not rewrite it when 0 rows are in review. Read `ingest_rows` instead.
- Expecting consecutive ledger/audit ids after a dry run: the rolled-back transaction uses them up.

## Open items, in order
1. **Texas rename CSV (next).** The 18 candidates above. Build the rename CSV by script (rename job format; read a recent rename CSV in the repo as the model, e.g. the Germany majority set), examine it read-only, present it, ask Ben about case-only rows, Le Jardinier and Annam. Then `rename-apply` (dry run, then "go").
2. **Texas slugs** for the renamed venues (Germany slug handoff method; old slugs stay non-canonical).
3. **Texas cleanup batch** (one gated SQL file, one "go"):
   a. Olamaie `ve_59ce7cc401`: card page "Restaurant not found"; status `active`; One Star 2025 row 3833 stays as history. Standing rules point to `closed` only with closure evidence; check first.
   b. Houston "Killen's" `ve_6034ffec5f` (Bib 2025 row 10600): likely twin of Pearland `ve_d9e28a8c8e` (Ben, Oct 9, Q3). Venue-delete pre-check, award move or delete, old slug as redirect or non-canonical.
   c. Lucia `ve_0c81b77dfc` (Bib 2025 row 10029): article yes, site no. Ben decides (no change, or a note).
   d. la Barbecue (Austin): now Michelin Selected; check whether a venue exists (none found by name).
4. **Hold register (Texas):** Barley Swine 2026 Service Award (Stefan Davis) → special-awards batch. Mindful Voices on Dai Due, Emmer & Rye, Nixta Taqueria, Isidore → hold (no column).
5. **Belgium & Luxembourg capture** (brief `docs/cowork-michelin-2026-belgium-luxembourg.md`, sha256 `888df1f3…71e99`; opening Cowork message as in the briefs handoff, with the file name changed), then stage, promote, retire the same-category twins (Great Britain & Ireland path), La Paix status, rename, slugs.
6. **Switzerland after Nov 2, 2026** (option A, promote only).
7. Price from the Michelin card (4,225 venues + Texas cards). Ben chooses the method. Note `price_capable` is false for Michelin.
8. France slug set (148 venues). Ben decides when.
9. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
10. Later-ceremony guides, promote only: American South after Oct 21; Beijing & Tianjin after the end of October; Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
11. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
12. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
13. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city (option C later, if wanted).
14. Plan v1.31: the Oct 9 decisions (Switzerland option A, Luxembourg in the Belgium batch, the order), the Texas result (this file), the 66-row correction.
15. Project file cleanup, part 2: after the migration is done.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-texas-promoted-2026-10-10.md first, then claude/handoff-briefs-texas-belgium-2026-10-09.md for the Belgium and Switzerland facts, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 104, audit_log id 109,286 and batch 14 (michelin-2026-texas, promoted) with a Read query. Then start open item 1: build the Texas rename CSV for the 18 candidates by script, using a recent rename CSV in the repo as the model and the Sep 14 name rulings, examine it read-only, and present it in /ste style. Ask me about the case-only rows, Le Jardinier and Annam. No write before my go.
```
