# Handoff: Plan v1.33 saved (award record after v1.30, part 1 of 3: Oct 9-31, ledger 103-176). Nov 7, 2026 (06:55 Atlanta). Next: Plan v1.34 (part 2), or Gault & Millau France and Monaco 2027 from Nov 10.

This file adds to `handoff-plan-v132-done-2026-11-07.md` (plan state before v1.33) and `handoff-plan-v131-done-2026-11-06.md` (plan-edit methods and dead ends). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Live state, open items and the Gault & Millau opening prompt: `handoff-michelin-d-dk-vn-done-2026-11-06.md`.

## Ben's input (ET, Nov 7)
- 00:20: opening prompt for Plan v1.33.
- 00:58: "A" = 3 parts by date. Part 1 Oct 9-31 (ledger 103-176), part 2 Nov 1-3 (ledger 177-279), part 3 Nov 4-6 (ledger 280-376).
- 06:51: "Go" (commit).

## Start checks (this chat)
- Date: Nov 7. Gault & Millau is due from Nov 10.
- Count read Nov 7, 05:20:37 UTC, whole tables. All equal the v1.32 handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321, other 0), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Repo: `main` at `214a07f` (PR #15). Plan Version 1.32, sha256 `26fe414a…8b0f`, 290,194 bytes.

## Done
No database write. No change to the live site.

**Plan v1.33 built, checked, saved.**
- Build: `build133.py` (sandbox only). Base sha256 asserted. Anchored `replace` calls, each asserted to match once. 155 lines added, 4 lines changed.
- 4 new cards after the Germany card:
  1. Texas, Belgium & Luxembourg and the Netherlands (Oct 9-11).
  2. Taiwan and the American South (Oct 11-27).
  3. Special awards and the card price, with Turkey 2026 (Oct 29-31).
  4. Name differences and open items blocks 1-7 (Oct 30-31): rules R1-R6, standing decisions of Oct 10-31, the Write-connector fallback, a ledger 103-176 table by job, counts at v1.30 and on Oct 31 06:09 UTC, closed and open items.
- Status box in the price work item. Header (Version, Author, Status, Responds to). Version-history row 1.33.
- Edge row: ledger 176 = open items block 7 file 1 (Oct 31 ET), in part 1. Block 7 files 2-3 ran Nov 1: file 2 = ledger 177-178, file 3 = no ledger row. Both go to part 2.
- Ledger ids that do not exist in 103-176 (rolled-back dry runs): 105, 107-108, 112-114, 118-119, 122, 124-125, 128, 131, 133-134, 137 (16). 74 ids - 16 = 58 rows.

**Sources (population: 52 handoff files for part 1).** 45 from `docs/` on `oad-2026-read-block` (44 dated Oct 10-31, plus `handoff-open-items-b7-done-2026-11-01.md`). 7 only in the project: briefs-texas-belgium (Oct 9), belgium-luxembourg-slugs-done, netherlands-captured, netherlands-slugs-done, taiwan-renamed, american-south-done, special-awards-sql-ready. Correction to the first proposal in this chat: it counted 23 project handoffs only. The branch holds 29 October handoffs that the project does not (price-card P1/P2 batches, Turkey, open items B1-B6 and others).

**Checks** (population: the added and changed lines):
- HTML: `html5lib` 2 errors, the same 2 as v1.32 (line 7, the font link). 0 tag mismatches. 0 unclosed tags.
- Number trace (`trace.py`): 320 numbers, ids and paths. 315 in the sources folder. 5 (American South audit 112,927-112,938, 112,939-112,956, 112,957) checked by hand against the project-only `handoff-american-south-done-2026-10-27.md`.
- Independent read-only agent, about 255 statements: 5 problems and 7 borderline points. All fixed before the save:
  1. "One go per file" was wrong for blocks 4 and 6. Now "after Ben's go".
  2. "Closed: the price method": no handoff records Ben choosing a method, and v1.32 lists it as open. Now: the P1, P2 and P1 rest batches are done, the method decision and the 2,558 legacy rows stay open.
  3. Price status box ledger list: now only price rows (140-150, 152, 154, 156, 159, 161, 169, 172).
  4. Taiwan: 23 of 24 deleted venues had the real Bib on a batch 17 venue (Q1 A). The 24th (Q3 A) had no proven link.
  5. The new-card-path proof rule is Claude's method, not Ben's decision. Now labelled "Method".
  6. Borderline: New Taipei move = Claude's proposal accepted by Ben's go; QF B and QH A named; P2 numbers = rows updated; SQL Editor reason = one `BEGIN; DO; COMMIT;` statement; alias rule exact (a place inside the new city, none for a province, region or separate town); 2 open decisions named (2025 Green Star backfill depth, 2,558 legacy price scope); block 7 file 3 wrote no ledger row.
- Wording: 0 should/could/might/would forms ("May" = month). 0 prose semicolons.
- Agent cost: about 325k tokens for 155 added lines (v1.32: about 142k for 54).

**Save** (Ben "Go", Nov 7 06:51 ET):
- Commit `ab202f6` on `oad-2026-read-block` (Nov 7, 06:52 -0500), 1 file.
- Fresh clone of the branch: sha256 `ee2580955abfd719a7539ae69e92639c2692aec639c2e9446ba7706a7bfb10ab`, 320,753 bytes, Version 1.33.
- Project copy over the same name (`CompassEats-Rearchitecture-Plan.html`): read back, sha256 equal, Version 1.33.
- `main` still holds v1.32. Merge only when Ben asks (PR by REST API, method in the v1.32 handoff).

## Methods (new)
- **Ledger rows to a file without retyping:** a Read query with `repeat('p',120000) as pad, json_agg(t)` saves the result to a tool-results file. Parse with `json.loads`, cut from `[{"pad"` to the last `}]`.
- **Handoff reading at scale:** a filter script keeps only the "Done" and decisions sections (drops Working rules, Live state, Open items, Methods, Dead ends, Artifacts, opening prompts). 52 handoffs: about 610 KB raw, 286 KB filtered.
- **Edge rows:** match each ledger id to its handoff by the job key in `source_capture_ledger.job`. A block can straddle parts (block 7).
- The independent agent ran in the background even with `run_in_background: false`. Wait for its notification.

## Dead ends: do not retry
- Counting part handoffs from the project list only: the branch `docs/` folder holds more. List both and merge by file name.
- Reading the filtered handoff file whole with Read (over 256 KB). Use offset and limit.

## Part 2 (Plan v1.34): sources
- Ledger 177-279 (Nov 1-3 ET, 93 rows). Includes block 7 files 2-3 (ledger 177-178; file 3 no ledger row).
- Handoffs dated Nov 1-3: 44 files. 38 in both the project and the branch, 3 only in the project (`handoff-switzerland-brief-2026-11-02.md`, `handoff-switzerland-decisions-2026-11-02.md`, `handoff-switzerland-waiting-results-2026-11-02.md`), 3 only on the branch (`handoff-open-items-b7-done-2026-11-01.md`, `-b8-`, `-b9-`). Also non-handoff project files of those days (for example `claude/michelin-2026-switzerland-log.md`, `claude/trusted-websites.md`).
- Expect a larger card set than part 1 (Hong Kong & Macau, 2025 backfills of 6 guides, Italy, closed sweep, Switzerland, OAD 2026 start). Consider 2 builds or a handoff break inside part 2.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.33** | Final. On `oad-2026-read-block` (`ab202f6`) and in the project (same name). `main` holds v1.32 | `ee2580955abfd719a7539ae69e92639c2692aec639c2e9446ba7706a7bfb10ab` |
| `build133.py`, `check_html.py`, `trace.py`, `filt.py` | Sandbox only, not in the repo. The file checksum is the record | - |

## Open items, in order
1. **Gault & Millau France and Monaco 2027 from Nov 10** (opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`). Then Michelin Thailand 2027.
2. **Plan v1.34 (part 2, Nov 1-3, ledger 177-279)**, then v1.35 (part 3, Nov 4-6, ledger 280-376).
3. Merge `oad-2026-read-block` to `main` when Ben asks.
4. All other items as in the v1.32 card "Move goals and order of work".

## Suggested opening prompt: Plan v1.34 (if Ben wants it before Nov 10)
```
Read claude/handoff-plan-v133-done-2026-11-07.md from the project files for the plan state and the part 2 source list, then
claude/handoff-plan-v131-done-2026-11-06.md and claude/handoff-plan-v130-done-2026-10-09.md for the plan-edit method, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html on branch
oad-2026-read-block (expect 1.33, sha256 ee258095…10ab) and on main (1.32 unless I merged). Build from the 1.33 file.
Start Plan v1.34, part 2 of the award record after v1.30 (Nov 1-3, ledger 177-279): list the 44 handoffs by date from both the
project and the branch, propose the cards, and ask me before you build. Build it, check it, and present it before you commit.
Keep handoffs on branch oad-2026-read-block.
```

For Gault & Millau from Nov 10, use the opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`.
