# Handoff: CompassEats, Oct 8, 2026. Germany 2026 captured and staged (run 1, batch 13). Next: alias/city fix, then the decisions file.

This file replaces `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` for live state, decisions and open items. The working rules, database notes, methods and dead ends in that file still apply and are not repeated here, except where this file adds to them. The Sep 28 ruling and Ben's decisions are in `handoff-chengdu-renamed-reviewed-2026-09-28.md`. Methods and dead ends in `handoff-plan-v129-done-2026-09-28.md` and `handoff-michelin-chengdu-2027-done-2026-09-28.md` still apply. All five files are in the project (Oct 8); the next chat reads them with the Projects tool.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.

## Live state
Population: whole table. Read Oct 8 after stage run 1. **No live table changed since Oct 4** (the stage job writes only `ingest_batches` and `ingest_rows`).

| Table | Count |
|---|---|
| venues | 11,205 (active 10,839, closed 366) |
| awards | 22,249 |
| Michelin 2025 / 2026 / 2027 rows | 3,796 / 4,659 / 47 |
| listings / slugs | 11,205 / 12,304 (canonical 11,205) |
| cities / city_aliases / city_label_source | 3,244 / **263** / 23,814 |
| price | 7,049 (10 `guide_ingest`) |
| source_capture_ledger | 65 (last id **85**) |
| audit_log | 103,905 (last id **107,294**) |
| ingest_batches | 1, 3–12 promoted. **13 = `michelin-2026-germany`, status `staged`**, created Oct 8 21:43 UTC |
| ingest_rows, batch 13 | 483 (ids 4836–5318). Staged `source_url` md5 (sorted, C collation, `\n`) `2b6026d4d8a7cda34d5e5ad0383bf6f5` = the CSV |
| Germany Michelin rows (venue city `country_iso` DE) | 806, all without `source_url`: 468 labelled 2025, 338 labelled 2026 |

## Done in this session (Oct 4 to Oct 8)
**Start check (Oct 4):** all counts, ledger 85, audit 107,294 matched. `docs/cleanup-michelin-cn-chengdu-held-7.sql` in the repo: sha256 `afeb8302…7745fb585` (correct). Plan Version 1.29, sha256 `73e43c4d…6e016de0`.

**Germany ceremony dates (guide.michelin.com):**
- 2025: 17 June 2025, 12 / 47 / 282 / 156. `https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-germany-2025-is-out`
- 2026: 23 June 2026, Frankfurt (Palmengarten), 12 / 48 / 279 / 147 = 486. `https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-germany-2026-is-out`
- 2027: not published. Live venue pages say "2026 MICHELIN Guide Germany".

**Germany legacy rows (Oct 4).** Population: 806 Michelin rows on DE-city venues.
- Labelled 2025: 12 / 40 / 268 / 148 = 468. Labelled 2026: 12 / 48 / 278 / 0 = 338.
- Label check passes on both labels. 2025 rows hold L.A. Jordan Two Stars (2025 edition). 2026 rows hold L.A. Jordan Three Stars, Mühle Two Stars, the new Two Stars and all 20 new One Stars, and no Bib.
- 493 venues: 308 hold both labels (2 category changes: L.A. Jordan, Mühle), 155 only 2025 (143 Bib, 11 One Star, Aqua Three Stars closed), 30 only 2026.
- 5 venues hold a 2025 Bib row and a 2025 One Star row (second restaurant in the same building): Schwingshackl ESSKULTUR, Hämmerles Restaurant, Die Mühlenhelle, Restaurant HochZwei im Gasthof zum Bad, Restaurant Hirsch (Sonnenbühl).
- 5 venues `closed`, 2 with a 2026 One Star row: Gasthof Alex `ve_2c3da34a8d`, Pfortenhaus Kloster Eberbach `ve_b7c3a95507`.
- Price: 463 venues `legacy_guide` ($ 8, $$ 133, $$$ 49, $$$$ 273), 30 none.

**Rules that apply (from Plan v1.29):** amended rule 2.1.1: the 2026 ceremony is after June 1, 2026, so all 468 rows labelled 2025 stay as history; expected retire count 0; no retire batch. Rule 2.1.7: the 2025 label differs from the incoming 2026 batch. Sep 15 ruling: never relabel a venue with a 2026 row. Cleanup standing rules (Sep 28) apply. Scope: stars and Bib only.

**Cowork capture (Oct 4, Opus, Chrome extension).** Brief `cowork-michelin-2026-germany.md` (sha256 `8e22f833…a20017`). Result: 483 rows, 12 / 48 / 278 / 145.
- Banner and filter differences 0 in every category. 0 duplicate URLs. All `€` (`€€€€` 294, `€€` 136, `€€€` 43, `€` 10).
- 486 − 483: Gasthaus Jakob (Perasdorf), page "Restaurant not found"; 2 Bib not nameable (no full Bib list).
- Star list article (German only): `https://guide.michelin.com/de/de/article/michelin-guide-ceremony/alle-sternerestaurants---michelin-guide-deutschland-2026` (339 entries, none marked closed).
- German pass: 483 of 483 joined; names identical; 59 cities differ (Munich/München 17, Frankfurt on the Main/Frankfurt am Main 13, Cologne/Köln 13, Nuremberg/Nürnberg 8, Hanover/Hannover 4, Aue - Bad Schlema/Aue 2, Constance/Konstanz 1, Bürgstadt/Burgstädt 1).
- Status register: **Gasthof Alex has a live One Star card** (`/bayern/weissenbrunn/restaurant/gasthof-alex`). **Pfortenhaus Kloster Eberbach = card "Ente Wiesbaden - Pfortenhaus Kloster Eberbach"**, One Star, with online booking (`/hessen/eltville-am-rhein/restaurant/ente`). Aqua: no card.
- Second-restaurant Bibs (same address as the star): Schwingshackl HEIMATKÜCHE (Bernried), Landgenuss (Blieskastel), Mühlenhelle - Bistro (Gummersbach), Stube ZWEI.NULL (Langenau). Sonnenbühl: no Bib card (see finding 2).
- Renames seen: "ammolite - The Lighthouse Restaurant" → card "Ammolite - House of Light"; "BYBLOS" → card "CHEZ NASSIB" (Berlin Bib); Hochzwei → card "HOCHZWEI".
- Special awards (hold register): Service Karin Weißer (Sankt Benedikt, Aachen); Young Chef Axel Boesen (Dopamin, Saarburg); Sommelier Noris F. Conrad (Tantris, Munich); Opening of the Year THE CLOUD by Käfer (Munich). No Green Star shown for Germany 2026.

**Repo (commit `2c8d8e9`, Oct 8 21:43 UTC, stage report):**
- `fixtures/ingest/michelin-2026-germany.csv` sha256 `424ab62fea6b2812f1ac67ac4bff9ca13a256c2ebe8c4e9522b2ded283000bff` (= Cowork log).
- `docs/michelin-2026-germany-log.md` sha256 `c5b18e3656c0228606dd2c63e53340877e91a024cdca21d4c773326437589e30`.
- `reports/michelin-2026-germany-review.csv` (80 review rows) sha256 `4592345d…4d12a5353`; `reports/michelin-2026-germany-stage.md`.
- `docs/cowork-michelin-2026-germany.md`: uploaded by Ben Oct 8, sha256 `8e22f833…a20017` (checked in a fresh clone, commit `5bf2064`).

**Stage run 1 (batch 13) = the read-only prediction, cell for cell.** Population: 483 rows.

| Verdict | 3★ | 2★ | 1★ | Bib | Total |
|---|---|---|---|---|---|
| `duplicate` (`duplicate_of_existing_award`, legacy 2026 twin) | 8 | 34 | 129 | 0 | 171 |
| `match` | 0 | 1 | 0 | 59 | 60 |
| `new_venue` | 1 | 7 | 100 | 64 | 172 |
| `review_venue` `loose_key_candidate_in_city` | 3 | 6 | 45 | 18 | 72 |
| `review_venue` `norm_key_too_short` ("5" Stuttgart, "OX" Darmstadt) | | | 2 | | 2 |
| `review_venue` `same_key_other_city` ("June" Übersee → Vancouver; "Löwen" Frickingen → Menzingen) | | | 1 | 1 | 2 |
| `review_city` `city_not_found` (Großheubach, Spiegelau, Freinsheim) | | | | 3 | 3 |
| `review_city` `country_label_disagrees` (Aubergine, Starnberg → Carmel alias) | | | 1 | | 1 |

## Decisions by Ben (this session)
- **Q1 (Oct 4): option A.** A Germany legacy 2026 row that a 2026 card confirms (stage verdict `duplicate`) gets `source_url` set in place after the promote. One gated `UPDATE`, per-row test (staged venue and category agree), one transaction, trigger audit rows, one ledger row, unchanged `awards` count. Same method as the Chengdu 25-row update (ledger 84).

## Findings for the next session
1. **172 `new_venue` rows hide existing venues.** The exact `norm_key` misses many legacy names (for example "Theodor's Restaurant" vs card "Theodor's"; "Landhaus Mühle Schluchsee" vs "Mühle"; Hochzwei vs "Restaurant HochZwei im Gasthof zum Bad"). These rows are NOT in the review CSV, because `new_venue` needs no decision. Before run 2, find the pairing for each one against the 493 DE Michelin venues (standing pairing rules: rule 6b, name wins, token link, rule 12; under-merge) and give it a `use:ve_…` line in the decisions file. Otherwise the promote makes twin venues.
2. **4 wrong city aliases** (table `city_aliases`, 263 rows): `berghaupten` → Sonnenbühl `ci_5937c0831c`; `ellwangen` → Sonnenbühl `ci_5937c0831c`; `sulzbach laufen` → Staufen im Breisgau `ci_ed87998009`; `starnberg` → Carmel by the Sea `ci_2be3dab26d` (US).
3. **Misfiled awards behind the aliases:**
   - Restaurant Hirsch, Sonnenbühl `ve_801f5d310a`: 2025 Bib row id 8250 belongs to Hirsch in Berghaupten or in Ellwangen (no evidence which). One Star rows 8249 (2025) and 8251 (2026) are Sonnenbühl's own (card `/sonnenbhl/restaurant/hirsch77747`).
   - Aubergine, Carmel `ve_1ba19d6d0f`: Michelin 2025 One Star 1697 + Two Stars 1696, 2026 One Star 1695 + Two Stars 1694. One pair can belong to Aubergine Starnberg. The Carmel Michelin card decides this in the cleanup (California rows have no URL, plan v1.25).
   - Die Krone, Staufen `ve_e622dc98a4` (2025 Bib 12283): label is Michelin's own "Staufen im Breisgau". Venue is correct; only the alias is wrong. Note: the card list has "Die Krone" in both Staufen im Breisgau (line 370) and Sulzbach-Laufen (line 372).
   - No `geo` rows for these venues.
4. **7 cities need a city row before run 2:** Großheubach, Spiegelau, Freinsheim (not found); Berghaupten, Ellwangen, Sulzbach-Laufen, Starnberg (only wrong aliases). Check the `cities` columns and an existing DE city row as the model first.

## Methods that worked (new)
- **Read-only pre-stage simulation in one query.** A Python script writes `VALUES (line, name, city, cat)` from the fixture with an md5 guard (`md5(string_agg(line||'|'||name||'|'||city||'|'||cat, E'\n' ORDER BY line))`; Germany = `0743d0d6220dc774dafda156d3d29812`). The query copies the job: `normLabel` = `btrim(regexp_replace(lower(f_unaccent(x)), '[^a-z0-9]+', ' ', 'g'))` on `n_full`/`n_head`; candidates by city slug, display and `city_aliases.alias`; country filter with three-valued logic; exact `norm_key` in the resolved city; loose key (`looseKey.ts`) only on `new` rows; dedupe = same venue, `source_id`, year, `rank IS NULL`, category, `distinction IS NULL`. It matched stage run 1 exactly.
- **City-label audit:** the 287 distinct card cities through the same candidate logic, listing any candidate whose display differs from the label or whose `country_iso` is not DE. This found the 4 wrong aliases.
- **Staged-row check:** `ingest_rows` columns are `id, batch_id, raw (jsonb), validation (jsonb), verdict`. Reason = `validation->>'reason'`; category = `raw->>'category'`.

## Dead ends: do not retry (new)
- `ingest_batches.row_count` (no such column; columns: id, batch_key, source_id, list_year, status, note, created_at, approved_at, undone_at).
- In SQL sent through the connector, write the loose-key regex as `\s+` (one backslash). `\\s+` matches a literal backslash and strips nothing (standard_conforming_strings is on). `looseKey.ts` writes `\\\\s` because it is inside a JS template.
- `cities.country` alone for the country test: use `lower(country_iso)` too (the job checks both).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-germany.csv` | In the repo | `424ab62f…000bff` |
| `docs/michelin-2026-germany-log.md` | In the repo | `c5b18e36…589e30` |
| `docs/cowork-michelin-2026-germany.md` | In the repo (Oct 8) | `8e22f833…a20017` |
| `reports/michelin-2026-germany-review.csv` / `-stage.md` | Written by the stage job | `4592345d…4d12a5353` / – |

## Open items, in order
1. **Germany, run 2 preparation (next).**
   a. Alias and city fix: one gated SQL file (delete the 4 wrong aliases; insert the 7 cities with their aliases if any). Build, examine read-only, present, one "go".
   b. Pairing of the 172 `new_venue` rows and the 80 review rows. Build `fixtures/ingest/michelin-2026-germany-decisions.csv` from the review CSV and the pairing query, never retyped. Ask Ben about any row the rules do not decide (for example Hirsch Berghaupten/Ellwangen vs Sonnenbühl's Bib row; Aubergine; "June"; "Löwen"; "5"; "OX").
   c. Stage run 2 with the decisions file, then dry-run promote, then a separate "go" for the real promote.
2. **Germany after the promote:** the option-A `source_url` update on the confirmed legacy 2026 rows; the cleanup (legacy 2026 rows with no card or a different category; the 5 second-restaurant Bib rows; Gasthof Alex and Ente/Pfortenhaus status: both have live 2026 cards, so the standing rules point to `active`; Aqua stays closed with its 2025 row; Gasthaus Jakob row; the Hirsch Bib row 8250; Aubergine). Also check the 7 venues with 2026 stars and no 2025 row (Tantris, Ox&Klee, Atelier, Speisemeisterei, August, Lorenz Adlon Esszimmer, Nagaya).
3. **Plan v1.30** (content as item 2 of the Oct 4 handoff, plus this Germany work). Plan-edit method; read the Version line first (expect 1.29).
4. France slug set (148 venues). Ben decides when.
5. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
6. Price from the Michelin card (population to read again; Germany adds 483 `€` cards). Ben chooses the method.
7. Later-ceremony guides, promote only: **Texas after Oct 8 (now due)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
8. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4 special awards); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
9. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu.
10. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`.
11. **Project file cleanup, part 2: after the migration is done (Ben, Oct 8).** Part 1 is done (Oct 8): 14 old plan copies and 13 old handoffs that are in the repo were deleted from the project; the project holds 1 plan copy (v1.29, written from the repo over the last copy). Left for later: (C) 13 project files not in the repo: make a zip, Ben uploads them to the repo `docs/` folder, then delete them from the project (`handoff-chengdu-2026-archive-promoted-2026-10-02.md`, `handoff-michelin-gb-ie-cleanup-done-2026-09-28.md`, `handoff-michelin-china-1c-done-2026-09-28.md`, `handoff-michelin-china-promoted-2026-09-27.md`, `handoff-michelin-china-group2-done-2026-09-28.md`, `handoff-michelin-china-cleanup-2026-09-28.md`, `handoff-michelin-china-shanghai-paired-2026-09-25.md`, `claude/handoff-michelin-spain-batch-2026-09-16.md`, `claude/handoff-michelin-italy-batch-2026-09-15.md`, `claude/handoff-michelin-france-batch-2026-09-13.md`, `claude/handoff-phase2-ingest-2026-09-11.md`, `cleanup-lal-2026-cn-hangzhou-house.sql`, `claude/cowork-michelin-2026-china-log.md`); (D) older copies of `CompassEats-Design-System.html`, `CompassEats-Guide-Descriptions.md`, `CompassEats-Sister-Project-Backlog.html`, `CompassEats-Places-Photo-Worker-Spec.md`, `runorder.html`; (E) out-of-date `CompassEats-Punch-List.html`, `runorder.html`, `compass-schema-v1.sql`. **Method note:** `project_delete` on a name with several copies removes the NEWEST copy first. Delete until 1 copy is left, then `project_write` the current file from the repo over that path (it replaces in place), then read it back. From now on Claude saves new plan versions and handoffs to the project over the same name, so no duplicates build up.

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-germany-staged-run1-2026-10-08.md first, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends, then claude/handoff-chengdu-renamed-reviewed-2026-09-28.md, handoff-plan-v129-done-2026-09-28.md and handoff-michelin-chengdu-2027-done-2026-09-28.md. Confirm live counts, ledger id 85, audit_log id 107,294, city_aliases 263 and batch 13 (michelin-2026-germany, staged, 483 rows) with a Read query. Then start open item 1a: build the gated SQL file that deletes the 4 wrong city aliases and adds the 7 missing German cities, examine it read-only, and present it in /ste style. Then start 1b: pair the 172 new_venue rows and the 80 review rows against the Germany legacy venues, and ask me about any row the rules do not decide. No write before my go.
```
