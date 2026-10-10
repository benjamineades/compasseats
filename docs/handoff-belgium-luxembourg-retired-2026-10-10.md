# Handoff: CompassEats, Oct 10, 2026 (16:50 Atlanta). Belgium & Luxembourg 2026 captured, staged, promoted (batch 15) and retired. Next: orphans, rename, slugs.

This file replaces `claude/handoff-texas-done-2026-10-10.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-texas-done-2026-10-10.md`: the Texas rename (batch 18), slugs and cleanup record; the rename-CSV method (two md5-guarded inputs, `loadRenameCsv`), the collision check, the sequence read after a dry run, the Michelin card award from the rendered page (dataLayer `distinction`), the status-only file method.
- `claude/handoff-texas-promoted-2026-10-10.md`: the Texas capture, stage and promote record, the hidden-pair method.
- `claude/handoff-briefs-texas-belgium-2026-10-09.md`: the Belgium & Luxembourg and Switzerland facts per guide, Ben's Oct 9 decisions.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit, the staged-row check, the stage dead ends.
- `claude/handoff-germany-renamed-sets23-2026-10-09.md` and `claude/handoff-germany-slugs-sets23-done-2026-10-09.md`: the vote method, the Q1-Q4 rulings, the slug-file method.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`, checked Oct 10): rule 2.1.1 (amended Sep 24), rule 2.1.7, the Sep 28 standing rules (temporary closure, conflicting evidence, Michelin-closed venue, contamination with no pairing).

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
Population: whole table. Read Oct 10, 20:44 UTC (16:44 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | **11,233** (active **10,867**, closed 366) |
| awards | **22,463** |
| Michelin 2025 / 2026 / 2027 rows | **3,545** / **5,124** / 47 |
| Michelin rows with `source_url` | **4,583** |
| listings / slugs | **11,233** / **12,576** (canonical **11,233**, non-canonical 1,343) |
| venues with more or less than 1 canonical slug | 0 |
| venues with two Michelin rows of one year and category | 0 |
| venue-years with two Michelin categories | 18 (unchanged) |
| cities / city_aliases / city_label_source | 3,251 / 258 / **23,870** |
| price | 7,048 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **80** (last id **111**) |
| audit_log | **105,853** (last id **110,088**) |
| ingest_batches | 1, 3-**15** promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18 applied. rename_rows 843. Sequence last value 18. |
| Belgium & Luxembourg Michelin rows | **250**: 247 sourced 2026 card rows (batch 15) + 3 unsourced orphans (1443, 3711, 5195) |

## Done in this session (Oct 10, 12:36 to 16:50 Atlanta)

**Start check:** all counts, ledger 106 and audit 109,342 matched the Texas-done handoff.

**1. Capture check.** Cowork (Opus, Chrome extension) delivered `michelin-2026-belgium-luxembourg.csv` and `-log.md` under brief `claude/cowork-michelin-2026-belgium-luxembourg.md`.
- CSV sha256 `4163c11dd56eba2a658a201890bab252810abbb068f7ecafe905c19ef2dbf9db`, 62,370 bytes = log. Header = brief. UTF-8, no BOM, LF. 247 rows.
- Belgium 2 / 19 / 103 / 108 = 232; Luxembourg 0 / 2 / 10 / 3 = 15. Rows = banner = filter.
- Stars 136 vs 139 in the star list article (-3, inside 10%): La Paix (Anderlecht, Two Stars), Kommilfoo (Antwerpen, One Star), La Table de Manon (Grandhan, One Star) all show "Restaurant not found".
- All 5 named 2026 changes present (Cuines 33 card city "Knokke", The Jane, Bloesem, La Table-Lasne by Alain Bianchin, Le Lys).
- 0 duplicate URLs/keys, all `€`, all `/us/en/`. Dutch and French passes 247/247 joined; 14 rows have a different city between languages (Brussels/Bruxelles 9, Saint Vith/Sankt Vith/Saint-Vith 2, De Panne/La Panne, Oudenaarde/Audenarde, Mechelen/Malines).
- One non-NFC name: "Grünewald Chef’s Table" (u + U+0308, U+2019). `norm_key` still matched it to `ve_d444bd9ab6`.
- Legacy rows before the promote = brief: Belgium 2 / 20 / 104 / 108 = 234; Luxembourg 0 / 2 / 10 / 3 = 15; all 2025, 0 sourced; 1 closed (La Paix).

**2. Pre-stage simulation (read-only).** Germany method, input md5 `e1e3944b423293fb62a75562ab193180` (line|name|city|country|cat). Predicted run 1: 205 match, 26 new_venue, 14 loose-key review, 2 same-key-other-city review, 0 duplicate, 0 review_city. All 169 card cities resolved in BE/LU (alias routes: Brussels communes Anderlecht/Ixelles/Uccle/Woluwe-Saint-Pierre → Brussels; Antwerpen → Antwerp; Brugge and Sint-Kruis → Bruges; Knokke and Heist → Knokke-Heist; Our → Paliseul). All 205 matches held exactly one legacy 2025 row in the same category and nothing else.

**3. Pairing and decisions.** 41 of the 42 non-match rows paired to legacy venues (same city, same category, only candidate; 14 = the job's loose-key candidate). Zur Post (Saint Vith) is new: no legacy row anywhere; the only other "Zur Post" is Odenthal, DE (`ve_e884f4d630`, its own 2026 card).
- **Ben's decisions (Oct 10), both A:** Q1 line 118 Sense (Waasmunster) → `ve_b54394ce22`, whose name "Hangzhou at West Lake Four Seasons Hotel Chinese Food Restaurant" is contamination (award 8957; the real Hangzhou Sense is `ve_55f5752b45`). Q2 line 195 Brasserie N4 (Martelange) → `ve_3f0a04e9d0` "Le Vertige des Saveurs Hotel" (award 11137; Tripadvisor hotel `d637197` shows "Vertige des Saveurs" then "Hotel Brasserie N4"; restaurant site brasserie-n4.com, Rue Roche Percée).
- Notable pairs: Hertog Jan at Botanic → Hertog Jan `ve_471f1bca0c` (Antwerp); Bozar Restaurant → "Karen Torosyan | Bozar Restaurant" `ve_5c5efedaa3`.
- File `fixtures/ingest/michelin-2026-belgium-luxembourg-decisions.csv`: 42 lines (41 `use:`, 1 `new`), quoted, CRLF, built by script from the simulation and an md5-guarded legacy read (`28dac82785a09415db2d403b82c5bb67`). sha256 `bef1f7738b0ab395343bd247b1318f69f61717944aabbbdca8315b10496ee4dc`, repo commit `1f1c367`.

**4. Stage (batch 15).** Run 1 (17:20 UTC, Ben "go") = prediction on every line (md5 of line|verdict|reason|venue `a9e90bcb1073e05faa067277fd874710` both sides; staged URL md5 `d8fa39eaf7ba2692a476f722e6371999` = CSV). Run 2 with decisions (17:22 UTC, Ben "go"): 246 match (2 / 21 / 112 / 111) + 1 new_venue; md5 with decisions `e0faa77e5fdb88f9ad38bd48749df350` both sides; 246 distinct venues.

**5. Promote.** Dry run (Ben, 20:34 UTC): 11 of 11 invariants pass; rolled back; used ledger 107-108 and audit up to 109,592. **Real promote (Ben "go", Oct 10 20:36:03 UTC):** ledger **109** (michelin, award, 247) and **110** (michelin, city_label, 2), job `ingest-promote:michelin-2026-belgium-luxembourg`. Audit **109,593-109,842** (250: awards 247, venues 1, listings 1, slugs 1; one timestamp). Row check: 247 distinct URLs, year 2026, category = staged row, country = card; 246 on the decided venue. New venue **Zur Post `ve_9916c47b98`**, Saint Vith `ci_fda6818ee5`, `/saint-vith/zur-post`, published, 2 city labels.

**6. Retire (`retire-michelin-legacy-be-lu`).** Population: Michelin rows on BE/LU venues; 249 legacy, 247 sourced. 246 twins on 246 venues (2 / 21 / 112 / 111), 0 category mismatches. File `docs/retire-michelin-legacy-be-lu.sql` (174 lines, ASCII), guards: id md5 `5f7f7ea1f2ac10ebecbe05a92369fd65`, plan fingerprint `1cade4a519545e4bd51a3b17f079fa80`, each row has exactly one batch 15 card twin, exact before/after counts. Parser check passed; dry run (Read connector) stopped at the DELETE, no id used.
- Ben "go". **Write connector returned "cancelled" twice** (reads after each: no change, no id used). Ben ran the file in the Supabase SQL Editor: committed Oct 10 **20:44:10 UTC**. Ledger **111** (michelin, award, 246). Audit **109,843-110,088** (246 awards DELETE, one timestamp; audit row_pk md5 = plan id md5). sha256 `63c6b080d18572d244f6b92c3ad8c970a8790a4fa2f3c74ceb943fe32f1d480d`, repo commit `5ad2193`.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/ingest/michelin-2026-belgium-luxembourg.csv` | In the repo (`69cf212`) | `4163c11d…f9dbf9db` |
| `docs/michelin-2026-belgium-luxembourg-log.md` | In the repo (`037d606`) | `b7d53844…2ca5d69` |
| `fixtures/ingest/michelin-2026-belgium-luxembourg-decisions.csv` | In the repo (`1f1c367`), applied in run 2 | `bef1f773…496ee4dc` |
| `reports/michelin-2026-belgium-luxembourg-stage.md` / `-review.csv` | Written by the stage job (`3da5dda`) | `40c4222b…` / `e62c3ba1…` (review CSV still holds the 16 run-1 rows) |
| `reports/michelin-2026-belgium-luxembourg-promote.md` | Real run (`d829a34`) | `55d4dd51…19b6dd` |
| `docs/retire-michelin-legacy-be-lu.sql` | Run (ledger 111), in the repo (`5ad2193`) | `63c6b080…2f1d480d` |

## Key ids
Saint Vith `ci_fda6818ee5` · Brussels `ci_954918891f` · Antwerp `ci_0a4783b7b2` · Bruges `ci_9710c01109` · Luxembourg `ci_068b83b083` · Zur Post `ve_9916c47b98` · Sense (contaminated name) `ve_b54394ce22` · Brasserie N4 (legacy hotel name) `ve_3f0a04e9d0` · La Paix `ve_54dcd1ca27` (closed) · Kommilfoo `ve_697073dab3` · La Table de Manon `ve_a5ee6f10f9` · Grünewald Chef's Table `ve_d444bd9ab6`.

## Hold register (Belgium & Luxembourg, from the Cowork log)
- Green Star: none shown (no filter, no list article). The ceremony article names Instroom by Seppe Nobels, Màloma and Nova as "gastronomy of tomorrow"; all three are Selected. Màloma and Nova carry a "MINDFUL VOICES" block. No rows.
- Special awards 2026 → special-awards batch: Young Chef Abel Demeestere (EST, Heverlee, One Star); Sommelier Nicolas Campus (Les Gribaumonts, Mons, Selected); Service Viviane Plaquet and Gitte Geunes (Zilte, Three Stars); Opening of the Year La Villa Lorraine (Brussels, Selected).

## Methods that worked (new)
- **ASCII-only simulation input:** write every string in the `VALUES` list as `U&'…'` with `\XXXX` escapes for non-ASCII. The query stays plain ASCII and keeps combining marks exactly; the in-SQL md5 guard matched the file.
- **Large Read results:** when the connector result is too big, it is saved to a file; parse it with Python (`json.loads(outer)['result']`, then the `[{…}]` slice).
- **Stage run checks by line md5:** run 1 = md5 of `line|verdict|reason|venue_id`; run 2 = md5 of `line|verdict|venue_id|decision` (validation keys `venue_id`, `decision`; `raw->>'_line'`), compared with the same md5 built from the simulation and the decisions file.
- **Retire guard "exactly one batch card twin":** each deleted row's venue must hold exactly one sourced 2026 row in the same category whose URL is in `ingest_rows` of the batch. After the commit, the md5 of the audit `row_pk` list = the plan id md5.
- **Rename population read:** batch 15 rows joined to the awards by `source_url`; card name vs `venues.name`.

## Dead ends: do not retry (new)
- Write connector on the 246-row retire `DO` block (about 11.8 KB): "cancelled" twice, no change. The SQL Editor run worked first time.
- Pasting a 247-row simulation result inline: the result (82,650 characters) exceeds the tool output limit; use the saved file.

## Open items, in order
1. **Belgium & Luxembourg cleanup (next).**
   a. **3 orphans:** read closure evidence (venue site, press; Michelin shows only "Restaurant not found"), then apply the standing rules. La Paix `ve_54dcd1ca27` is already `closed` (Two Stars 1443; article lists it at Two Stars, card gone). Kommilfoo `ve_697073dab3` (`active`, One Star 3711, OAD 2025 row 3712). La Table de Manon `ve_a5ee6f10f9` (`active`, One Star 5195). Rows stay as history under the Michelin-closed rule; conflicting evidence → no change, recheck list.
   b. **Rename CSV** (`fixtures/rename/michelin-2026-belgium-luxembourg-names.csv`, Texas method). Population: the 247 batch 15 award rows; card name ≠ `venues.name` on **99** venues: 39 case-only, 58 with the same `norm_key` (case and punctuation), 41 paired. 0 earlier rename rows; **2 blurbs** on these venues (read their text). Questions for Ben: case-only rows (France/Germany/Texas precedent: keep), the non-NFC "Grünewald Chef’s Table" (store the card form or NFC), names with emoji or stray marks in the stored name ("Mona Lisa 🇮🇹", "Le Tournant ️", "Le Grand Verre *"), Sense, Brasserie N4, Hertog Jan at Botanic. OAD/other publishers on the same venue: vote rule.
   c. **Slugs** for renamed venues (Texas slug-file method).
2. **Switzerland after Nov 2, 2026** (option A, promote only).
3. **Hold registers:** Texas (Barley Swine 2026 Service Award; Mindful Voices on Dai Due, Emmer & Rye, Nixta Taqueria, Isidore) and Belgium & Luxembourg (above) → special-awards batch.
4. Price from the Michelin card (4,225 venues + Texas cards + 247 BE/LU `€` cards: € 3, €€ 107, €€€ 53, €€€€ 84). Ben chooses the method. `price_capable` is false for Michelin.
5. France slug set (148 venues). Ben decides when.
6. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
7. Later-ceremony guides, promote only: American South after Oct 21; Beijing & Tianjin after the end of October; Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
8. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
9. Rechecks, no date: Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
10. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes (Auderghem, Jette, Saint-Gilles, Schaerbeek, Watermael-Boitsfort, Woluwe-Saint-Lambert have their own city rows; Anderlecht, Ixelles, Uccle, Woluwe-Saint-Pierre are aliases of Brussels).
11. **New: repo `.env`.** The public repo tracks `.env` with two browser keys (`VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_BROWSER_KEY`, `VITE_MAPTILER_KEY`). They ship to the browser by design, but Ben should check that both keys are restricted by HTTP referrer (Google Cloud console and MapTiler account) to compasseats.com and the preview domain.
12. Plan v1.31: the Oct 9 decisions, the Texas result, the 66-row correction, the Killen's correction, and this Belgium & Luxembourg record (batch 15, ledger 109-111, retire, Q1/Q2).
13. Project file cleanup, part 2: after the migration is done.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-belgium-luxembourg-retired-2026-10-10.md first, then claude/handoff-texas-done-2026-10-10.md for the rename-CSV, collision-check and slug methods, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 111 and audit_log id 110,088 with a Read query. Then start open item 1a: read the closure evidence for the 3 Belgium orphans (La Paix, Kommilfoo, La Table de Manon) and tell me in /ste style what the standing rules give for each. Then start 1b: build the Belgium & Luxembourg rename CSV for the 99 venues with the Texas method, examine it read-only, and ask me the questions the rules do not decide. No write before my go.
```
