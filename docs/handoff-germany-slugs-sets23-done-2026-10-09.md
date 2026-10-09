# Handoff: CompassEats, Oct 9, 2026 (just after midnight Atlanta). Slug file for Germany rename batches 15 and 16 done (48 venues). Next: Plan v1.30.

This file replaces `claude/handoff-germany-renamed-sets23-2026-10-09.md` for live state, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-germany-renamed-sets23-2026-10-09.md`: set 2 and set 3 record (batches 15 and 16, ledger 98–100, audit 108,932–108,990; dry runs batch 13–14, ledger 95–97, audit 108,873–108,931), sources read, the vote method, Ben's Q1–Q4 A decisions, G&M not readable.
- `claude/handoff-germany-renamed-set1-2026-10-08.md`: set 1 record (batch 12, ledger 94, audit 108,284–108,498), set 1 slug file (audit 108,499–108,872), the slug method and the two A decisions.
- `claude/handoff-germany-cleanup-done-2026-10-08.md`: the cleanup record (ledger 91–92, audit 108,051–108,068), Ben's Q1/Q2 precedent, the lists for Plan v1.30 (its item 2).
- `claude/handoff-germany-promoted-2026-10-08.md`: the promote record.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: Germany source facts.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends; its item 2 lists the Chengdu content for Plan v1.30.
- `claude/handoff-chengdu-renamed-reviewed-2026-09-28.md`, `handoff-plan-v129-done-2026-09-28.md` (plan-edit method), `handoff-michelin-chengdu-2027-done-2026-09-28.md`: methods, dead ends, database notes.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.

## Live state
Population: whole table. Read Oct 9, 04:00 UTC (Oct 9, 00:00 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,223 (active 10,859, closed 364) |
| awards | 22,389 |
| Michelin 2025 / 2026 / 2027 rows | 3,791 / 4,804 / 47 (not read again this session; no award write) |
| listings / slugs | 11,223 / **12,557** (canonical 11,223, non-canonical **1,334**) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,850 |
| price | 7,048 (10 `guide_ingest`) |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | 74 (last id 100) |
| audit_log | **105,219** (last id **109,086**) |
| ingest_batches | 1, 3–13 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16 applied (13, 14 = rolled-back dry runs). rename_rows 825 |

## Done in this session (Oct 9, 03:55–04:02 UTC)

**Start check:** all counts, ledger 100, audit 108,990, slugs 12,509, rename batches 15 and 16 applied matched. Fresh clone (commit `e66ec44`): both real-run reports are in the repo, not dry-run versions: `reports/rename-michelin-2026-germany-dashes-rename.md` ("Committed 2026-10-09T03:50:48.619Z", sha256 `40b7a36f…7c38d75`), `reports/rename-majority-2026-germany-rename.md` ("Committed 2026-10-09T03:52:09.584Z", sha256 `5f383b7d…52717fe`). Ledger counts in the reports (71→72, 72→74) agree with the real runs. Both rename CSVs and the set-1 slug file sha256 correct.

**Slug file (`docs/slugs-rename-michelin-2026-germany-sets23.sql`, 159 lines, sha256 `192bd51f4751acbc55901d26eafe6bb72733e71498fd16fe380a0822ebf09723`, repo commit `1138a75`, checked in a fresh clone).**
- Built by a script from `docs/slugs-rename-michelin-2026-germany.sql` with counted string replacements (each replacement asserted to occur the expected number of times), plus one new gate: rename batches 15 and 16 `applied` and rename_rows 14 and 45.
- Population: the 59 venues of batches 15 and 16. **48 plan rows** (batch 15: 14, batch 16: 34), **11 keep their slug** (Victor's, IKIGAI, Haerlin, Votum, Petit Amour, Gotthardt's, ESPLANADE, Ox & Klee, Ösch Noir, Seven Swans, JAN). Fingerprint `0efb198cfcf990e1cca4dc77f29075f9`.
- Slug rule `f_unaccent` (Ben's A). Equals `slug.ts` on 58 of 59; differs only on Tölzer Schießstätte (`tolzer-schiessstatte`; slug.ts `tolzer-schie-statte`). Apostrophe → dash, as in existing slugs (`christian-s-restaurant`, `bodendorf-s`).
- Read-only checks: 0 empty, 0 duplicate in plan, 0 new slug in use, 0 new or old path in `redirects`, 0 not active. 3 blurbs on the set (Schwarzwaldstube, es:senz, Haerlin) are keyed by `venue_id`, not changed. ESPLANADE has 1 older non-canonical slug (not in plan).
- Dry run: the `DO` block alone through the Read connector; all pre-checks passed, stopped at the first UPDATE ("read-only transaction"). Read after: no change.
- Ben "go". Write connector, first try, committed Oct 9 03:59:46 UTC. All gates passed. slugs 12,509 → 12,557; non-canonical 1,286 → 1,334; canonical 11,223. Audit **108,991–109,086** (48 slugs UPDATE + 48 INSERT, one timestamp, 48 venues, 0 rows on other venues). No ledger row. All 59 batch venues hold a canonical slug equal to the rule.
- Examples: `/baiersbronn/schwarzwaldstube` (was `restaurant-schwarzwaldstube`), `/berlin/tim-raue`, `/hamburg/haebel` (was `h-bel`), `/wackersberg/tolzer-schiessstatte`, `/vreden/am-kring-buschker-s-stuben`, `/grassau/es-senz`, `/sylt/bodendorf-s`.

## Methods that worked (new)
- **Slug file from the previous slug file by script:** replace each number with an asserted occurrence count; a wrong count stops the build (the template had 14 occurrences of "187", not 11). Then show `diff` of non-comment lines.
- **Rule comparison in SQL (no retyping):** slug.ts equivalent = `trim(both '-' from regexp_replace(lower(regexp_replace(normalize(name, NFD), '[̀-ͯ]', '', 'g')), '[^a-z0-9]+', '-', 'g'))`; compare to the `f_unaccent` rule in the same query.
- **Read-back after a slug write:** one query: counts, venues with ≠1 canonical, set venues whose canonical slug = rule, audit rows `id > <last>` grouped by action with `count(distinct at)`, audit rows outside the set.

## Dead ends: do not retry (new)
- `awards.list_year` (no such column on `awards`). Read the Michelin year counts another way (see earlier handoffs) when Plan v1.30 needs them.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/slugs-rename-michelin-2026-germany-sets23.sql` | Run (Write connector), in the repo (`1138a75`), checked | `192bd51f…bf09723` |
| `reports/rename-michelin-2026-germany-dashes-rename.md` | Real run, in the repo (`e66ec44`) | `40b7a36f…7c38d75` |
| `reports/rename-majority-2026-germany-rename.md` | Real run, in the repo (`e66ec44`) | `5f383b7d…52717fe` |
| `fixtures/rename/michelin-2026-germany-dashes.csv`, `fixtures/rename/majority-2026-germany.csv` | Run, in the repo | as in the sets23 handoff |

## Open items, in order
1. **Plan v1.30 (next).** Content: item 2 of `handoff-germany-cleanup-done-2026-10-08.md` (and the Chengdu content in item 2 of `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` if v1.29 does not already hold it), plus from the set-1 handoff: the 280 rename population and three sets, rename batch 12 (ledger 94, audit 108,284–108,498; dry run ledger 93, batch 11, audit 108,069–108,283), the set-1 slug file (audit 108,499–108,872, 187 rows, 28 kept), Ben's two A decisions (7 im/by rows; `f_unaccent` slug rule); from the sets23 handoff: rename batches 15 and 16 (ledger 98–100, audit 108,932–108,990; dry runs batch 13–14, ledger 95–97, audit 108,873–108,931), the vote method, Ben's Q1–Q4 A decisions (first pipe ruling), G&M not readable; from this handoff: the sets 2–3 slug file (audit 108,991–109,086, 48 rows, 11 kept). Plan-edit method (`handoff-plan-v129-done-2026-09-28.md`); read the Version line first (expect 1.29).
2. France slug set (148 venues). Ben decides when.
3. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
4. Price from the Michelin card (population to read again; known differences Rebers Pflug 7906, BOK 6670, Kuultivo 5902; 30 option-A venues and AURA / Starnberg have no price row). Ben chooses the method.
5. Later-ceremony guides, promote only: **Texas (due now)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
6. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
7. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente (name now "Ente Wiesbaden", slug `ente-wiesbaden`; return to the Nassauer Hof later), die burg (venue site did not load), Gault&Millau Germany (re-vote set 3 if the site becomes readable; up to 18 rows could change, and their slugs with them).
8. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs (`wei-enbrunn`, `ma-weiler`, `kirchheim-an-der-weinstra-e`, `wachenheim-an-der-weinstra-e`) vs the `f_unaccent` rule.
9. Project file cleanup, part 2: after the migration is done (list in the staged-run1 handoff, item 11).

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-germany-slugs-sets23-done-2026-10-09.md first, then claude/handoff-germany-renamed-sets23-2026-10-09.md, claude/handoff-germany-renamed-set1-2026-10-08.md and claude/handoff-germany-cleanup-done-2026-10-08.md for the Plan v1.30 content, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules and the Chengdu content, then handoff-plan-v129-done-2026-09-28.md for the plan-edit method. Confirm live counts, ledger id 100, audit_log id 109,086 and slugs 12,557 with a Read query, and check in a fresh clone that docs/slugs-rename-michelin-2026-germany-sets23.sql has sha256 192bd51f…bf09723. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html (expect 1.29). Then start open item 1, Plan v1.30: build it from v1.29 with the plan-edit method, check it, present it in /ste style, and wait for my go before I save it.
```
