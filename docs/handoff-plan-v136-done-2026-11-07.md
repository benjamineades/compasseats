# Handoff: Plan v1.36 saved (award record after v1.30, part 3, cards 1-4: Nov 4-6, ledger 280-319). Nov 7, 2026 (09:45 Atlanta). Next: Plan v1.37 (part 3, cards 5-8), or Gault & Millau France and Monaco 2027 from Nov 10.

This file adds to `handoff-plan-v135-done-2026-11-07.md` (plan state before v1.36), `handoff-plan-v134-done-2026-11-07.md` and `handoff-plan-v131-done-2026-11-06.md` (plan-edit methods and dead ends). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Live state, open items and the Gault & Millau opening prompt: `handoff-michelin-d-dk-vn-done-2026-11-06.md`.

## Ben's input (ET, Nov 7)
- 08:05: opening prompt for Plan v1.36.
- 08:07 "1-2:A": 1 A = part 3 in 8 cards (list below). 2 A = 2 builds (v1.36 cards 1-4, v1.37 cards 5-8), each with its own check, a handoff between them.
- 09:39 "go" (commit build 1).

## Start checks (this chat)
- Date: Nov 7. Gault & Millau is due from Nov 10.
- Count read Nov 7, 13:05:38 UTC, whole tables. All equal the v1.35 handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321, other 0), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Repo: `main` at `214a07f`, Plan 1.32 (sha256 `26fe414a…8b0f`, 290,194 bytes). `oad-2026-read-block` at `21ccd80`, Plan 1.35 (sha256 `31f06f25…2746`, 391,638 bytes).

## Part 3 sources (population: handoff files dated Nov 4-6)
- Project 31, branch 29, both 29. Project only 2: `handoff-oad-2026-small-fixes-done-2026-11-05.md`, `handoff-launch-list-radar-done-2026-11-05.md`. Branch only 0.
- **Correction to the v1.35 handoff** ("branch 14, project only 17"): that count read only the top level of `docs/`. 15 handoffs sit in the run folders on the branch (for example `docs/michelin-2026-austria-2026-11-05/`). List them with `git ls-tree -r --name-only origin/oad-2026-read-block docs/ | grep -E '/handoff-[^/]*2026-11-0[4-6]\.md$'`.
- Award handoffs: 28 (31 minus phase2-publish-design, phase2-publish-job-pr, plan-v131).
- Ledger 280-376: 97 rows, 0 ids missing.

## The 8 cards (Ben 1 A)
| # | Card | Handoffs | Ledger rows | Version |
|---|---|---|---|---|
| 1 | OAD 2026 hold rows, Summer Palace, Sushi Ichi, rename batch 51 (Nov 4) | holds-summer-palace, holds-status, holds-item1, names (4) | 15 (280-294) | v1.36 |
| 2 | OAD 2026 closed venues (26 weakest, other 54), small fixes, live-site finding (Nov 4-5) | closed-weakest, closed-other-54, small-fixes (P) (3) | 3 (295-297) | v1.36 |
| 3 | Launch list, radar, 50 Best and Spirited 2026, Top 500 Bars 2026, status read of the 45 (Nov 5-6) | launch-list-radar (P), 50-best-spirited, top-500-bars, top-500-status (4) | 9 (298-306) | v1.36 |
| 4 | Michelin Kuala Lumpur & Penang 2027, Thailand, Austria, Singapore, South Korea 2026 (Nov 5) | 5 guide handoffs | 13 (307-319) | v1.36 |
| 5 | Michelin Canada, Portugal, Mexico, US gap 2026, Latvia 2027 (Nov 5) | canada, portugal, mexico, us-gap, latvia (5) | 16 (320-335) | v1.37 |
| 6 | Michelin 2027 Philippines, Beijing-Tianjin, group A1: Greece, South Australia, Dubai (Nov 5-6) | philippines-beijing-tianjin, a1 (2) | 12 (336-347) | v1.37 |
| 7 | Michelin group A2, A3, B, E (Nov 6) | a2-a3-b-e (1) | 18 (348-365) | v1.37 |
| 8 | Michelin group D: D1, Thailand cards, Finland, Lithuania, Norway, Sweden, Denmark, Vietnam, 2 closures (Nov 6) | d1, d-th-fi-lt, d-no-se, d-dk-vn (4) | 11 (366-376) | v1.37 |

(P) = project only. Build 2: 12 handoffs, all on the branch, 0 project-only. Paths on the branch: `docs/michelin-2026-{canada,portugal,mexico,us-gap}-2026-11-05/`, `docs/michelin-2027-latvia-2026-11-05/`, `docs/michelin-2027-beijing-tianjin-2026-11-05/` (holds the philippines-beijing-tianjin handoff), `docs/michelin-a1-2026-11-06/`, `docs/michelin-a2-2026-11-06/` (holds the a2-a3-b-e handoff; A3, B, E have own folders), and the 4 group D handoffs at the top of `docs/`. Run folders: `docs/michelin-2027-philippines-2026-11-05/`, `docs/michelin-{a3,b,e,d1}-2026-11-06/`, `docs/michelin-d-{thailand,finland,lithuania,norway,sweden,denmark,vietnam}-2026-11-06/`.

## Done
No database write. No change to the live site.

**Plan v1.36 built, checked, saved.**
- Build: `build136a.py` (sandbox only). Base sha256 asserted. Anchored `replace` calls, each asserted to match once. 222 lines added, 4 lines changed.
- 4 new cards (1-4 above) after the v1.35 card "OAD 2026 — Europe, Asia and Japan loaded", before the Phase 2 record card. Card 1 opens part 3 with the intro sentence. Card 4 holds the Write-connector note for Nov 4-5, the ledger 280-319 table (40 rows, 17 job groups, built by script from the live rows) and the counts after ledger 319 (Nov 6, 02:10:10 UTC, from the South Korea handoff).
- Status boxes: "Status, Nov 4–5 (v1.36)" in the price work item (no price write; price-item additions of the 5 Michelin files; price 7,759 after ledger 319). "Status, Nov 5 (v1.36)" in the history-backfill work item (Singapore 4 sourced 2025 rows, Austria rows 5938 and 5898, rows with no URL: Malaysia 66, Thailand 178, Singapore 125; South Korea 2025 edition to the backfill).
- Header (Version, Author, Status, Responds to). Version-history row 1.36.

**Sources:** the 14 branch handoffs and their run folders, the 2 project-only handoffs and `claude/launch-list-2026-11-05.md` (by `project_read`), and the live ledger rows 280-319.

**Checks** (population: the 222 added and 4 changed lines):
- HTML: `html5lib` 2 errors, the same 2 as v1.35 (line 7, the font link). 0 tag mismatches. 0 unclosed tags.
- Number trace (`trace.py`): 417 numbers, 51 ids and paths. Not on disk: 7 items from the project-only small-fixes handoff (`ae1939c`, `data/cities.json`, the small-fixes SQL path, 8,991, 1,532, 2,299, 130,633), checked by hand. The rest are version numbers.
- sha256 of the 14 write files on the branch = the sha256 in their handoffs (14 of 14).
- Independent read-only agent, about 280 statements, about 225k tokens, about 24 minutes: 3 problems and 8 borderline points. 3 problems and 7 borderline points fixed before the save:
  1. Le Choubichou "gives a 404": no read. Now "No redirect row was added. Nobody read the live site."
  2. "The Read connector hashed the live reads": South Korea only. Fixed.
  3. "Open on Nov 5 at 21:10 ET" left out Latin America's 50 Best, La Liste, Northeast Cities, the foundation items, the research result, Oshino and Shinji by Kanesaka. Added.
  4. Borderline fixed: "no new read without a new route" is from the handoff, not Ben's 3A · 4A = the 26 weakest only · DELETE note: the sources do not give the cause of the cancel · Malaysia CDX read incomplete · cards 1-4 dated Nov 4-6 (card 3 holds the Nov 6 status read) · pair check also marks new venues · Singapore edition wording · rule 2.1.7 for all 5 guides, 2.1.1 for 4.
  5. Kept: Austria "url in use" line names the 156 relabelled rows (decision 1). The agent's addition of the 4 new rows was its own reading.
- Wording: 0 should, could, would, might or may forms. 0 prose semicolons. -ing words are nouns or adjectives (needing in the phase-meta labels, listing, finding, spelling, reading).

**Save** (Ben "go", Nov 7 09:39 ET):
- Commit `df77949` on `oad-2026-read-block` (Nov 7, 09:39 -0500), 1 file.
- Fresh clone of the branch: sha256 `6d994d5691c38ba0575e776a7c1a1644884645ebcb8c53b7f6a2d3bd23d441fd`, 432,399 bytes, Version 1.36.
- Project copy over the same name (`CompassEats-Rearchitecture-Plan.html`): read back as `local_file`, sha256 equal, Version 1.36.
- `main` still holds v1.32. Merge only when Ben asks.

## Anchors for v1.37
- Card placement: same anchor as v1.34-v1.36, `  <div class="card">\n    <h3>Phase 2 record — publish job designed`.
- Card 1 intro (part 3): `Cards 5–8 (Nov 5–6, ledger 320–376) are not in v1.36.` Change to say they came in v1.37.
- Header status: `cards 1–4 (Nov 4–6, ledger 280–319) recorded in v1.36, cards 5–8 (Nov 5–6, ledger 320–376) not yet in this plan`.
- Version-history anchor: the end of the 1.36 row, `Part 3 cards 5–8 (Nov 5–6, ledger 320–376) are not in this version.</td></tr>`.
- Status boxes for v1.37 go after the v1.36 boxes: price box starts `<b>Status, Nov 4–5 (v1.36).</b>`, history-backfill box starts `<b>Status, Nov 5 (v1.36).</b>`.
- Card 4 lines that point to build 2, keep them true: "New open item (Ben, Nov 5): Michelin Latvia 2027 is out. It is in card 5 (v1.37)." and "Next in this record: part 3 cards 5–8 (Nov 5–6, ledger 320–376), v1.37."
- "Responds to" already names v1.37. Author line: `v1.25–1.36 by Claude Opus 5.5`.

## Methods (new)
- **Ledger rows to a file through this connector:** a `json_agg` query plus `repeat('x',60000) AS pad` makes the Read connector save the result to a `tool-results/*.txt` file. The file is JSON with a `result` string. Cut from `[{\"` to the last `}]`, then `.encode('utf-8').decode('unicode_escape').encode('latin-1').decode('utf-8')`, then `raw_decode`. Script: `parse_ledger.py` (sandbox). Names with accents came out correctly (ledger 314).
- **DELETE check:** `git show origin/oad-2026-read-block:<file> | grep -c -i 'DELETE FROM'` on each write file. This answers the Write-connector note without a guess.
- **Project upload:** copy the file to a new folder in the working directory (not the scratchpad), `project_write` with `local_path`, then remove the folder.

## Dead ends: do not retry
- A trace run with the plan or the diff inside the sources folder: every token matches (0 missing is then false). Keep the trace sources and the agent folder apart.
- Counting branch handoffs at the top of `docs/` only (see the correction above).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.36** | Final. On `oad-2026-read-block` (`df77949`) and in the project (same name). `main` holds v1.32 | `6d994d5691c38ba0575e776a7c1a1644884645ebcb8c53b7f6a2d3bd23d441fd` |
| `build136a.py`, `check_html.py`, `trace.py`, `parse_ledger.py`, `ledger280_376.json` | Sandbox only, not in the repo. The file checksum is the record | - |

## Open items, in order
1. **Gault & Millau France and Monaco 2027 from Nov 10** (opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`). Then Michelin Thailand 2027.
2. **Plan v1.37 (part 3 cards 5-8, Nov 5-6, ledger 320-376).** Card list above.
3. Merge `oad-2026-read-block` to `main` when Ben asks.
4. All other items as in the v1.32 card "Move goals and order of work".

## Suggested opening prompt: Plan v1.37 (if Ben wants it before Nov 10)
```
Read claude/handoff-plan-v136-done-2026-11-07.md from the project files for the plan state and the build 2 card list, then
claude/handoff-plan-v134-done-2026-11-07.md and claude/handoff-plan-v131-done-2026-11-06.md for the plan-edit method, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html on branch
oad-2026-read-block (expect 1.36, sha256 6d994d56…41fd) and on main (1.32 unless I merged). Build from the 1.36 file.
Build Plan v1.37, part 3 cards 5-8 (Nov 5-6, ledger 320-376), as listed in the handoff. Build it, check it, and present it before you commit.
Keep handoffs on branch oad-2026-read-block.
```

For Gault & Millau from Nov 10, use the opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`.
