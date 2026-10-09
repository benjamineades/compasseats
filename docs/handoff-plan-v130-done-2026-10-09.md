# Handoff: CompassEats, Oct 9, 2026 (00:20 Atlanta). Plan v1.30 saved. Next: Ben chooses the next work block.

This file replaces `claude/handoff-germany-slugs-sets23-done-2026-10-09.md` for live state, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-germany-slugs-sets23-done-2026-10-09.md`: the sets 2–3 slug file record (audit 108,991–109,086), the slug-file-by-script method.
- `claude/handoff-germany-renamed-sets23-2026-10-09.md`: set 2 and set 3 record (batches 15 and 16), sources read, the vote method, Ben's Q1–Q4 A decisions, G&M not readable.
- `claude/handoff-germany-renamed-set1-2026-10-08.md`: set 1 record (batch 12), set 1 slug file, the slug method and the two A decisions.
- `claude/handoff-germany-cleanup-done-2026-10-08.md`: the cleanup record (ledger 91–92), Ben's Q1/Q2 precedent.
- `claude/handoff-germany-promoted-2026-10-08.md`, `claude/handoff-germany-option-a-done-2026-10-08.md`, `claude/handoff-germany-staged-run1-2026-10-08.md`: the Germany promote, option A and source facts.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- `claude/handoff-chengdu-renamed-reviewed-2026-09-28.md`, `handoff-plan-v129-done-2026-09-28.md`, `handoff-michelin-chengdu-2027-done-2026-09-28.md`: methods, dead ends, database notes.

Plan v1.30 now holds the whole Chengdu (Sep 28 – Oct 5) and Germany (Oct 4–9) record, so a new chat can read the plan's last two cards instead of the eight Germany and Chengdu handoffs when it only needs the facts. The handoffs keep the methods and dead ends.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.
- Plan versions and handoffs are saved to the project over the same name (`project_write` with `local_path`), so no duplicate copies build up.

## Live state
Population: whole table. Read Oct 9, 04:05 UTC (Oct 9, 00:05 Atlanta). **No database table changed in this session.**

| Table | Count |
|---|---|
| venues | 11,223 (active 10,859, closed 364) |
| awards | 22,389 |
| Michelin 2025 / 2026 / 2027 rows | 3,791 / 4,804 / 47 |
| Michelin rows with / without `source_url` | 4,263 / 4,422 |
| listings / slugs | 11,223 / 12,557 (canonical 11,223, non-canonical 1,334) |
| venues with more or less than 1 canonical slug | 0 |
| venues with two Michelin rows of the same year and category | 0 |
| venue-years with two Michelin categories | 18 (CH 10, AT 2, SE 2, MO, NO, SG, VN; 0 in Germany) |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,850 |
| price | 7,048 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | 74 (last id 100) |
| audit_log | 105,219 (last id 109,086) |
| ingest_batches | 1, 3–13 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16 applied (13, 14 = rolled-back dry runs). rename_rows 825 |
| Germany Michelin 2026 / 2025 rows (DE city) | 484 (0 unsourced) / 464 (all unsourced, history) |
| Chengdu `ci_354b500e3a` | 54 venues; Michelin 2026 rows 40, 0 unsourced |

## Done in this session (Oct 9, 04:04–04:17 UTC)

**Start check:** all counts, ledger 100, audit 109,086, slugs 12,557 matched. Fresh clone (commit `4fc4d2c`): `docs/slugs-rename-michelin-2026-germany-sets23.sql` sha256 `192bd51f…bf09723` (correct). Plan Version 1.29, sha256 `73e43c4d…6e016de0`.

**Plan v1.30 built, checked, saved.**
- Base: v1.29 (sha256 asserted in the script). Build script `build130.py` (sandbox only): 13 anchored `replace` calls, each asserted to match exactly once. Two new cards after the GB&I card; four edits to existing text; one version-history row.
- HTML check: html5lib 2 errors, the same 2 as v1.29 (line 7, the font link); 0 tag mismatches; 0 unclosed tags. Diff against v1.29: 6 lines changed, 144 lines added. 0 stray `&`.
- A separate agent (no edit rights) compared every added statement with the 10 handoffs, the repo file hashes and the Oct 9 database reads: 0 wrong ids, ledger numbers, audit ranges or hash prefixes; 5 wording problems, all fixed before the save (Chengdu read dates; "59 city labels differ only by language" → "differ between the two locales"; "484 venues, all cards €" → 483 cards, Gasthaus Jakob has no card; the Germany rollback sentence → only the cleanup moved a row onto a promoted venue; "Ben took option A" → "Ben's go ran the file as built, with option A"). The agent's borderline notes were left as written: "14-digit timestamp" in archive rule 7 (from the Sep 28 rebuild requirement), "the undo job refuses on drift" (plan v1.18).
- Ben "go". Project copy written over the same name (`project_write`, `local_path`), read back: Version 1.30. Repo: Ben uploaded through the GitHub web page, commit `fa9f36a` (Oct 9, 00:16 -0400). Fresh clone: sha256 **`748defe9be3f54ecf581f374fcee74dd2024f8ea0eaf5925c89468161c672216`**, 259,669 bytes, Version 1.30. The repo holds 1 plan file.

**v1.30 adds:**
- Header: Version 1.30, October 9, 2026; Status "… Great Britain & Ireland, Chengdu (archive) and Germany promoted and closed · Chengdu 2027 promoted · Texas due now …".
- Card "Michelin 2026 and 2027 — Chengdu renamed · archive method test 1 complete (Sep 28 – Oct 5)": rename batch 10 (ledger 78), slug file, Upper House cleanup (ledger 79), the archive ruling with the 15-row count, Ben's three decisions, steps 1–3 (ledger 82–85, the 4516 / 9788 option A basis), the ledger note form, result 40 of 40 sourced.
- Card "Michelin 2026 — Germany promoted, sourced, cleaned and renamed · standing decisions · order restated (Oct 4–9)": ceremonies, legacy profile, capture, stage run 1, city fix, decisions file (13 medium pairings, Wirsberg), promote (ledger 88–89), option A (ledger 90), cleanup table (status fix, ledger 91, 92), no-write items, rename population (280 = 215 + 15 + 50), rename batch table (12, 15, 16), slug file table (187 + 48), vote method, a table of 8 standing decisions (Oct 8 Q1/Q2; "im/by" names; the `f_unaccent` slug rule; Oct 9 Q1–Q4), the Write-connector fallback, result (484 / 464), gap list after Germany (10 countries, read Oct 9), order of the remaining work (6 items), cleanup list, live counts.
- Price work item: population read again Oct 9: 4,225 venues; 3,781 with one price row (3,771 legacy, 10 card), 444 none, 0 more than one; Germany 484 venues (483 cards), 50 with no price row.
- History-backfill work item: the 8 archive conditions as rules (a flag box), "archive method test 1 … is not the pilot", known items (the 7 German venues), the Italy 4 / Spain 6 leftover rows after launch, the Italy/Spain small-read table.
- Phase 4 note: Germany promoted and closed; dates still under review, no new dates.
- Version history row 1.30.

## Gap list after Germany (in v1.30; read Oct 9)
Population: Michelin award rows by the country of the venue's city. Rows with no `source_url` / sourced: US 1,001 / 46 · DE 464 / 484 (all 2025 history; closed) · BE 234 / 0 · CH 226 / 0 · NL 185 / 0 · TH 178 / 0 · TW 175 / 0 · AT 158 / 0 · VN 156 / 1 · HK 145 / 0. No handoff or plan line sets the order of the next countries; Ben decides.

## Methods that worked (new)
- **Plan edit, as in the v1.29 handoff, plus:** read the base cards and the version-history row first with `sed -n` ranges; keep the whole build in one script with the base sha256 asserted; run `html5lib` and a tag-balance parser on base and result and compare the error counts; `diff | grep -c '^>'` for the added-line count.
- **Independent fact check of a plan diff:** write the diff to a file, give a read-only agent the diff, the handoff paths (Projects tool) and the live database facts, and ask for a list of statements that a source does not support. Fix the wording in the build script (asserted replacements), rebuild, recheck. Cost: about 190k agent tokens for 144 added lines.
- **Project copy from disk:** `project_write` with `local_path` (the file never passes through the chat), then `project_read` to confirm the Version line. The read gives text, not bytes, so the hash check is on the repo copy.
- **Repo save by Ben through the GitHub web upload:** same file name in `docs/` replaces the old copy in one commit ("Add files via upload").

## Dead ends: do not retry (new)
- `awards.list_year` (no such column; the year column is `year`). The Michelin year counts: `count(*) FROM awards WHERE source_id='michelin' AND year=…`.
- Hashing the project copy: `project_read` returns the text inline, so a byte hash of the project copy is not available. Check the repo copy.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.30** | Final, in the repo (`fa9f36a`) and the project (same name) | `748defe9…672216` |
| `build130.py` | Sandbox only, not in the repo. The file checksum is the record. | – |
| `docs/slugs-rename-michelin-2026-germany-sets23.sql` | Run, in the repo, checked | `192bd51f…bf09723` |

## Open items, in order (Plan v1.30, "Order of the remaining work")
1. **Ben decides the next work block.** Candidates: (a) the next country from the gap list (Belgium 234 or Switzerland 226, both 0 sourced; each needs its 2026 ceremony date from a guide.michelin.com URL first, then the amended rule 2.1.1 path); (b) **Texas (due now)**, promote only; (c) France slug set (148 venues); (d) the price method. A new country or Texas starts with a Cowork capture brief (model: `docs/cowork-michelin-2026-germany.md`), so suggest a handoff break and a fresh Cowork session for it.
2. France slug set (148 venues). Ben decides when.
3. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
4. Price from the Michelin card (4,225 venues, read Oct 9; known differences Rebers Pflug 7906, BOK 6670, Kuultivo 5902; 444 venues with no price row, 50 of them in Germany; The Hall ¥¥¥¥). Ben chooses the method.
5. Later-ceremony guides, promote only: **Texas (due now)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
6. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
7. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente (return to the Nassauer Hof later), die burg, Gault&Millau Germany (re-vote set 3 if readable; up to 18 rows and their slugs).
8. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs vs the `f_unaccent` rule.
9. Project file cleanup, part 2: after the migration is done (list in the staged-run1 handoff, item 11). Note: the 8 Germany and Chengdu handoffs of Oct 2–9 are now also in the repo `docs/` (checked in the Oct 9 clone), so they qualify for part 2 (C) when it runs.

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-plan-v130-done-2026-10-09.md first, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Read the last two cards of docs/CompassEats-Rearchitecture-Plan.html (expect Version 1.30, sha256 748defe9…672216) for the Chengdu and Germany record. Confirm live counts, ledger id 100 and audit_log id 109,086 with a Read query. Then tell me in /ste style what the next work block needs for each of these choices: Belgium, Switzerland, Texas, the France slug set, the price method. Ask me which one to start. No write before my go.
```
