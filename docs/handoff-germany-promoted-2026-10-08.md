# Handoff: CompassEats, Oct 8, 2026 (evening). Germany 2026 promoted (batch 13). Next: option-A source_url update, then the Germany cleanup.

This file replaces `claude/handoff-germany-staged-run1-2026-10-08.md` for live state, decisions, open items, methods and dead ends. The working rules, database notes, methods and dead ends in `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md` still apply. The Sep 28 ruling and Ben's decisions are in `claude/handoff-chengdu-renamed-reviewed-2026-09-28.md`. Methods and dead ends in `handoff-plan-v129-done-2026-09-28.md` and `handoff-michelin-chengdu-2027-done-2026-09-28.md` still apply. The staged-run1 handoff keeps the Germany source facts (ceremony URLs, capture counts, status register, legacy-row profile); read it for those.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", Ben runs the same file in the Supabase SQL Editor (see Dead ends). Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.

## Live state
Population: whole table. Read Oct 8, 23:54 UTC, after the promote.

| Table | Count |
|---|---|
| venues | **11,224** (active **10,858**, closed 366) |
| awards | **22,396** |
| Michelin 2025 / 2026 / 2027 rows | 3,796 / **4,806** / 47 |
| listings / slugs | **11,224** / **12,323** (canonical **11,224**) |
| venues with more or less than 1 canonical slug | 0 |
| venues with two Michelin rows of the same year and category | 0 |
| cities / city_aliases / city_label_source | **3,251** / **258** / **23,852** |
| price | 7,049 (10 `guide_ingest`) |
| source_capture_ledger | **67** (last id **89**) |
| audit_log | **104,121** (last id **107,714**) |
| ingest_batches | 1, 3–**13** promoted (no id 2). 13 = `michelin-2026-germany`, promoted Oct 8 23:53:27 UTC |

## Done in this session (Oct 8 evening)

**Start check:** all counts, ledger 85, audit 107,294, city_aliases 263, batch 13 staged with 483 rows (ids 4836–5318, source_url md5 `2b6026d4…f5`) matched. Repo fixture and review CSV sha256 correct.

**1a. Alias and city fix (`docs/cities-michelin-2026-germany-fix.sql`, sha256 `cc50f7d9b0e7143f539bb3b549921030eb9b98ae262a6a889cb5b528adf25a48`, 175 lines).** Ben "go". The Write connector returned "cancelled" 3 times (nothing ran; read-back each time proved no change). Ben ran the file in the Supabase SQL Editor, one run, committed Oct 8 23:47:20 UTC. All gates passed.
- Deleted 5 aliases (263 → 258): `berghaupten` → Sonnenbühl, `ellwangen` → Sonnenbühl, `sulzbach laufen` → Staufen im Breisgau, `starnberg` → Carmel by the Sea, and a **5th found this session: `gro heubach` → Freiamt `ci_f49503e208`** (Ben: delete all 5).
- Inserted 7 cities (3,244 → 3,251), display and country from the staged batch-13 rows: Starnberg `ci_42a8f6b727`, Berghaupten `ci_fcf8ea41b8`, Ellwangen `ci_1c4a5ea2e8`, Sulzbach-Laufen `ci_f3cd8094a9`, Großheubach `ci_a790d8481e` (slug `grossheubach`), Spiegelau `ci_4e08f1250f`, Freinsheim `ci_c95b5eec6c`. All `DE`, kind `city`, region NULL, no alias.
- Audit 107,295–107,299 (city_aliases DELETE, hand rows, `row_pk` = alias, `old_row` md5 = the PRE row md5 `af621400…`), 107,300–107,306 (cities INSERT, trigger). No ledger row (same as earlier city inserts).
- Rules used: city id = `'ci_' || left(md5(slug),10)` (true for all cities); slug = `trim(both '-' from regexp_replace(lower(f_unaccent(display)),'[^a-z0-9]+','-','g'))`; region NULL (148 of 303 DE cities have none; card gives only the state).

**1b. Pairing and decisions file (`fixtures/ingest/michelin-2026-germany-decisions.csv`, sha256 `2e14fe2fadb20661fdf9712f36d69fba3d047a6e787454cdbe687fae1a419684`, 252 rows, quoted, CRLF).** Population: the 172 `new_venue` + 80 review rows. Pool: 531 DE venues (493 with Michelin rows); a venue used by a match/duplicate row is not free.
- 233 `use:` (high 220, medium 13), 19 `new`. new_venue rows: 160 use / 12 new. Review rows: 73 use / 7 new.
- Loose-key review rows: pairing = the job's own candidate on 69 of 72; the other 3 (Hirsch Berghaupten, Hirsch Ellwangen, Die Krone Sulzbach-Laufen) had a wrong city through a wrong alias → `new`.
- Decided by the rules: "5" Stuttgart → `ve_ff9f2ff3ef`; "OX" Darmstadt → `ve_766914b040`; "June" Übersee → `ve_884cf7506a`; "Löwen" Frickingen → `ve_e9e7461048` (Löwen Altheim); Ente/Pfortenhaus → `ve_b7c3a95507` (closed today); Aubergine Starnberg, both Hirsch, Die Krone Sulzbach-Laufen → `new`; second restaurants Stube ZWEI.NULL, Schwingshackl HEIMATKÜCHE, Mühlenhelle - Bistro, Landgenuss → `new`; CHEZ NASSIB and Salhino → `new` (two cards, one free Berlin Bib slot, no token link).
- Medium (13). Rule 6b: Epicures → Residenz Heinz Winkler; Restaurant Alexander Huber → Huberwirt; Kamin- und Bauernstube → Hotel Dollenberg ·Kaminstube; Das August → Romantik Hotel Schmiedegasthaus Gehrke; Poststuben → Hotel Zur Post Meerfeld; Feine Speiseschenke → Rüdigsdorfer Schweiz. Name variant: Das Philippin → Cafe + Conditorei Philippin; Ontra's Gourmetstube → ONTRA; Christian & Friends → Christian & Freunde; Alte Schule - Klassenzimmer → Alte Schule Fürstenhagen; BjörnsOx → BjoernsOx; Münstermanns Kontor → Münstermann Kontor; Gehrlein's Hardtwald → Gehrleins Restaurant Hardtwald.
- Price differs on 2 pairs only: Rebers Pflug, BOK (legacy `$$$`, card `€€€€`).

**Wirsberg finding (Ben: AURA venue).** Line 36 "AURA by Alexander Herrmann & Tobias Bätz" (Two Stars) matched `ve_410be56f8e` by exact key (no Michelin row; La Liste 2026, Best Chef 2025). The legacy Michelin rows (2025 Two Stars 3577, 2026 Two Stars 3578) are on `ve_36e30ddd9f` "Posthotel Alexander Herrmann", same city. Ben kept the card on AURA; Posthotel and its 2 rows go to the cleanup. No line in the decisions file.

**Stage run 2 (Ben, commit `2145e16`, report sha256 `abe62f7e…ffa`).** 252 decisions read. duplicate 336, match 128, new_venue 19, review 0, reject 0 = the prediction. Row-by-row fingerprint md5 of `line|verdict|venue_id|city_id` (comma-joined, by line) = `b12707287e46942f4d5603d98001a4e3` for both prediction and staged rows.

**Promote dry run (commit `41e2539`).** 11 of 11 invariants pass. Used ledger 86–87 and audit 107,307–107,510 (rolled back).

**Real promote (Ben, Oct 8 23:53:27 UTC, report commit `fadc62a`, `reports/michelin-2026-germany-promote.md` sha256 `e82277d4…a12cf`).**
- awards +147 (128 match, 19 new), venues / listings / slugs +19 each, city_label_source +38 (note `michelin-2026-germany`), price +0, active venues 10,839 → 10,858.
- Ledger **88** (michelin, award, 147) and **89** (michelin, city_label, 38), job `ingest-promote:michelin-2026-germany`.
- Audit **107,511–107,714** (204 rows, one timestamp): awards INSERT 147, venues 19, listings 19, slugs 19.
- Row checks: 147 of 147 URLs on guide.michelin.com/us/en, all distinct; venue and category agree with the staged row 147 of 147; the 19 new venues = the dry-run ids.
- New venues: Aubergine `ve_660e52c8f5` (/starnberg/aubergine), Hirsch `ve_f06df0ad3c` (/berghaupten/hirsch), Hirsch `ve_9a35ffe0b1` (/ellwangen/hirsch), Stube ZWEI.NULL `ve_8654bf99d5`, Brasserie Barbara `ve_183605970b`, Die Krone `ve_043c47cdb3` (/sulzbach-laufen/die-krone), Schwingshackl HEIMATKÜCHE `ve_5f5a5a4e0a`, Zur Krone `ve_748fb081d6` (/grossheubach/zur-krone), mokum `ve_a5e7191926`, Das Palmberger - hoamART `ve_9b7f264837`, CHEZ NASSIB `ve_9c574617dc`, Salhino `ve_a91aa70189`, CYN CYN `ve_502cb3df27`, GASSENHAUR `ve_e583bec755`, LENZ `ve_fc5934befb`, Bornheimer Ratskeller `ve_a0aa7d14ee`, Mühlenhelle - Bistro `ve_19bac307ee`, WEINreich `ve_dfface2f35`, Landgenuss `ve_e17b5f1052`.

## Decisions by Ben (this session)
- 1a: delete all 5 aliases (the 4 named + `gro heubach`).
- Wirsberg: the AURA card stays on `ve_410be56f8e`. Posthotel `ve_36e30ddd9f` with rows 3577 and 3578 goes to the cleanup.

## Findings for the next session
1. **Option-A population:** 336 legacy Michelin 2026 rows on DE venues now have a confirming card (stage verdict `duplicate`). 2 legacy 2026 rows have no card: Gasthaus Jakob `ve_1c7dc6f4de` (7349, One Star) and Posthotel Alexander Herrmann `ve_36e30ddd9f` (3578, Two Stars).
2. **Legacy DE Michelin venues used by no card:** 30 of 493. 28 hold only 2025 rows (history, Aqua `ve_0092621ee8` included). The other 2 are Gasthaus Jakob and Posthotel.
3. **Second-category Bib rows (cleanup, second category rule):** 2025 Bib rows on HochZwei `ve_885eda93f2` (5865), Die Mühlenhelle `ve_5fad8fbf2d`, Schwingshackl ESSKULTUR `ve_b2b57e491b`, Hämmerles Restaurant (Blieskastel), and Hirsch Sonnenbühl `ve_801f5d310a` (8250, no evidence which Hirsch owns it, so it does not move).
4. **Aubergine:** the Carmel venue `ve_1ba19d6d0f` holds Michelin 2025 One Star 1697 + Two Stars 1696 and 2026 One Star 1695 + Two Stars 1694. The Starnberg card is now its own venue `ve_660e52c8f5`. The Carmel Michelin card decides which rows stay.
5. **Status:** Gasthof Alex `ve_2c3da34a8d` and Ente/Pfortenhaus `ve_b7c3a95507` are `closed` but have live 2026 cards (standing rules point to `active`).
6. Legacy ß city slugs use `-` (`wei-enbrunn`, `ma-weiler`, `kirchheim-an-der-weinstra-e`, `wachenheim-an-der-weinstra-e`); new cities use the `f_unaccent` rule (`grossheubach`). Not changed; note for the slug work.

## Methods that worked (new)
- **Pairing script (sandbox, not in the repo):** load the staged rows (line, verdict, venue_id, city_id, category, price, names, job candidates) and the DE venue pool (id, name, city, status, price, all awards) as TSV through the Read connector (big results land in a tool-results file; parse the JSON from it). Name score on accent-folded tokens without generic words (restaurant, gasthof, hotel, landhaus, weinstube, stube, im/am/zum/zur …): 4 = same core tokens, 3 = subset or compact containment (≥4 chars), 2 = a shared token of ≥4 chars. Candidates = free venues with a Michelin row in the same (post-fix) city. Flags: twin 2026 row, other 2026/2025 category, more than one row per year, price length, status, another card scoring the same venue. Then a separate pass for taken venues that also score, and for unused legacy venues (this found Wirsberg).
- **Decisions file from data, not typing:** venue_name and city_label from the fixture by line (assert equal to the staged row), decision from the pairing, reason text generated. Assert each target venue is used once and is not used by a match/duplicate row.
- **Run-2 prediction:** `use:` → `duplicate` when the venue holds a Michelin 2026 row of the same category, else `match`. Compare by md5 of `line|verdict|venue_id|city_id`.
- **City-alias audit:** list every alias on a DE city, and every alias equal to a normalised card label. This found `gro heubach`.
- **Simulation of a city fix:** CTE with cities ∪ planned cities and aliases − deleted aliases, run the stage resolution on all staged rows with `MATERIALIZED` CTEs (a plain join on `f_unaccent` per row gave a 502).

## Dead ends: do not retry (new)
- **Write connector "cancelled":** 3 calls in a row returned `{"status":"cancelled"}` with no change; Ben saw no approval box. Do not retry more than once. Fall back: Ben downloads the file, opens it in a plain text editor, pastes it into Supabase → compass-canonical → SQL Editor → New query, Run once, and replies "done"; then read back. The gated `DO` block makes this safe.
- The pool query and the staged-row query exceed the tool output limit; do not try to print them inline. Use the saved tool-results file.
- A `cities` × `ingest_rows` join with `f_unaccent` on both sides without materializing (502 Bad Gateway).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/cities-michelin-2026-germany-fix.sql` | Run (SQL Editor), in the repo | `cc50f7d9…adf25a48` |
| `fixtures/ingest/michelin-2026-germany-decisions.csv` | Final, in the repo | `2e14fe2f…a419684` |
| `reports/michelin-2026-germany-stage.md` (run 2) | Written by the job | `abe62f7e…ffa` |
| `reports/michelin-2026-germany-promote.md` | Written by the job | `e82277d4…a12cf` |
| `fixtures/ingest/michelin-2026-germany.csv` | In the repo | `424ab62f…000bff` |

## Open items, in order
1. **Germany option-A update (next).** Set `source_url` in place on the 336 legacy 2026 rows that a card confirms. Per-row test: staged row verdict `duplicate`, `collides_with` award id = the row, venue and category agree; md5 guard of the award id list. One `UPDATE`, one transaction, trigger audit rows (336), one ledger row (job `source-url:michelin-2026-germany-legacy | …`), `awards` count unchanged. Model: `docs/source-url-michelin-2026-chengdu-legacy.sql` (ledger 84). Build, examine read-only, present, one "go".
2. **Germany cleanup** (standing rules, full venue pre-check before any delete, one "go" per batch): Posthotel `ve_36e30ddd9f` (3577, 3578) after the Wirsberg choice; Gasthaus Jakob (7349, page "Restaurant not found"); the 5 second-category Bib rows (finding 3); Aubergine Carmel rows (Carmel card decides); status of Gasthof Alex and Ente/Pfortenhaus → `active`; Aqua stays closed with its 2025 row. Also the 7 venues with 2026 stars and no 2025 row (Tantris, Ox&Klee, Atelier, Speisemeisterei, August, Lorenz Adlon Esszimmer, Nagaya).
3. **Germany rename CSV** (majority rule) for the paired venues whose legacy name differs from the card (for example Cafe + Conditorei Philippin, Huberwirt, Residenz Heinz Winkler), then the slug job.
4. **Plan v1.30** (content as item 2 of the Oct 4 handoff, plus Germany: ceremony, capture, 1a with the 5th alias, stage runs 1–2, the 13 medium pairings, Wirsberg, promote ledger 88–89 / audit 107,511–107,714, the Write-connector fallback). Plan-edit method; read the Version line first (expect 1.29).
5. France slug set (148 venues). Ben decides when.
6. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
7. Price from the Michelin card (population to read again; Germany adds 147 sourced `€` rows, plus the 336 after option A). Ben chooses the method.
8. Later-ceremony guides, promote only: **Texas (due now)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
9. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4: Service Karin Weißer, Young Chef Axel Boesen, Sommelier Noris F. Conrad, Opening of the Year THE CLOUD by Käfer); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
10. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu.
11. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`.
12. Project file cleanup, part 2: after the migration is done (list in the staged-run1 handoff, item 11).

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-germany-promoted-2026-10-08.md first, then claude/handoff-germany-staged-run1-2026-10-08.md for the Germany source facts, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends, then claude/handoff-chengdu-renamed-reviewed-2026-09-28.md, handoff-plan-v129-done-2026-09-28.md and handoff-michelin-chengdu-2027-done-2026-09-28.md. Confirm live counts, ledger id 89, audit_log id 107,714, city_aliases 258 and batch 13 (michelin-2026-germany, promoted) with a Read query. Then start open item 1, the Germany option-A update: build the gated SQL file that sets source_url on the 336 legacy 2026 rows that a 2026 card confirms (model: docs/source-url-michelin-2026-chengdu-legacy.sql), examine it read-only, and present it in /ste style. No write before my go.
```
