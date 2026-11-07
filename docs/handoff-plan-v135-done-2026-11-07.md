# Handoff: Plan v1.35 saved (award record after v1.30, part 2, cards 5-8: Nov 2-3, ledger 235-279). Nov 7, 2026 (08:05 Atlanta). Next: Plan v1.36 (part 3), or Gault & Millau France and Monaco 2027 from Nov 10.

This file adds to `handoff-plan-v134-done-2026-11-07.md` (plan state before v1.35, part 2 card list and methods), `handoff-plan-v133-done-2026-11-07.md` and `handoff-plan-v131-done-2026-11-06.md` (plan-edit methods and dead ends). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Live state, open items and the Gault & Millau opening prompt: `handoff-michelin-d-dk-vn-done-2026-11-06.md`.

## Ben's input (ET, Nov 7)
- 07:36: opening prompt for Plan v1.35 (build 2 of part 2).
- 08:01 "Go" (commit).

## Start checks (this chat)
- Date: Nov 7. Gault & Millau is due from Nov 10.
- Count read Nov 7, 12:37:03 UTC, whole tables. All equal the v1.34 handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321, other 0), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Repo: `main` at `214a07f`, Plan 1.32 (sha256 `26fe414a…8b0f`). `oad-2026-read-block` at `a6b9cae`, Plan 1.34 (sha256 `ab5b627f…5f12`, 349,979 bytes).

## Done
No database write. No change to the live site.

**Plan v1.35 built, checked, saved.**
- Build: `build135a.py` (sandbox only). Base sha256 asserted. Anchored `replace` calls, each asserted to match once. 223 lines added, 5 lines changed.
- 4 new cards after card 4 of v1.34, before the Phase 2 record card:
  5. Closed-venue rule and closed-venue sweep (Nov 2, ledger 235-238).
  6. Michelin 2026 Switzerland & Liechtenstein (Nov 2-3, ledger 241-249), with a table of 14 writes.
  7. Signum and the city `malfa`, merged place ids and Tailor, OAD rows A2, A3 and Group D (Nov 3, ledger 250-265).
  8. OAD 2026 Europe, Asia and Japan, 280 new venues (258 + 22), the separate read block (Nov 3, ledger 266-279). Also: the Write-connector note for Nov 2-3, the ledger 235-279 table (43 rows, 19 job groups, built by script from the live rows), the counts after ledger 279 (Nov 4, 04:00:46 UTC, from `handoff-oad-2026-read-block-done-2026-11-03.md`).
- Status boxes "Status, Nov 2-3 (v1.35)" in the price work item (ledger 245, 252, 3 merge deletions, Masa row) and the history-backfill work item (ledger 246, 249, 250, 258).
- Card 1 intro sentence, header (Version, Author, Status, Responds to), version-history row 1.35.

**Sources** (population: 20 handoffs for cards 5-8). 17 from `docs/` on the branch, 3 project-only (`handoff-switzerland-waiting-results-2026-11-02.md`, `-brief-`, `-decisions-`). Plus the run records, the Swiss Cowork log and brief, `handoff-open-items-rls-names-fr-closures-done-2026-11-02.md`, and the live ledger rows 235-279.

**Checks** (population: the 223 added and 5 changed lines):
- HTML: `html5lib` 2 errors, the same 2 as v1.34 (line 7, the font link). 0 tag mismatches. 0 unclosed tags.
- Number trace (`trace.py`): 359 numbers, 69 ids and paths. Not found on disk: 3 items in the project-only Swiss handoffs (`ve_3b12809d9f`, `ve_6784aa9f52`, Action 41546434498), checked by hand. The Cowork brief path (copied by base name). The rest are version numbers and id parts.
- Independent read-only agent, about 360 statements, about 243k tokens: 4 problems and 15 borderline points. 4 problems and 14 borderline points fixed before the save:
  1. "Group 10" was not defined in the plan. Now "the 78 venues with closure evidence" (item 6 numbering).
  2. Carmen is not on a recheck list. Only Mitani and Yakitori Kurosaki.
  3. "No live page changed" was not proven for the second OAD write and the read block. Now: nobody read the live site or a deploy after them.
  4. The Green Star brief line is Claude's method, not Ben's decision. Now "Method (Claude)".
  5. Borderline fixed: "can give" wrong list pages, search cap only in the later batches, "Database times" (not commit times), condition 5 of the Sep 28 archive ruling, "temporary closure confirmed", Soleil d'Or card prints "by David", alias place-class limit, 145 candidates to count again, decision 5 named as Ben's 18:09 5A, Magdalena card in Schwyz and venue in Rickenbach, card 8 title (280 new venues, ledger 266-279 and the 235-279 table), Wine RVLT note, FAGN-Bistro in the backfill box.
  6. Kept: the Rollback row names the undo job for the batch 20 promote (same form as the v1.34 Hong Kong card).
- Wording: 0 should, could, would, might or may forms ("May 18" = month). 0 prose semicolons. 0 -ing verbs (2 fixed).

**Save** (Ben "Go", Nov 7 08:01 ET):
- Commit `c33e507` on `oad-2026-read-block` (Nov 7, 08:02 -0500), 1 file.
- Fresh clone of the branch: sha256 `31f06f2584c7bfcc50589be1f3609c60d195ef1b567ee8f2751b3e35587e2746`, 391,638 bytes, Version 1.35.
- Project copy over the same name (`CompassEats-Rearchitecture-Plan.html`): read back as `local_file`, sha256 equal, Version 1.35.
- `main` still holds v1.32. Merge only when Ben asks.

## Methods (new)
- **Project upload:** `project_write` with `local_path` needs a file inside the working directory. A scratchpad path is refused. Copy the file to the working directory first, then remove the copy.
- **Agent with project-only sources:** give the agent the 3 project paths by name and tell it to use `project_read` for those only. It worked.
- **Checkout of the handoff branch:** `git checkout -b oad-2026-read-block origin/oad-2026-read-block` works. `git branch --set-upstream-to` fails on a ref made by refspec fetch ("not a branch"). The push still worked.

## Part 3 (Plan v1.36): sources
- Ledger 280-376 (Nov 4-6 ET): 97 rows, 0 ids missing (322 rows in all, minus 225 rows to id 279).
- Handoffs dated Nov 4-6: project 31, branch 14, both 14, project only 17, branch only 0.
  - Nov 4 (5): oad-2026-holds-summer-palace, -holds-status, -holds-item1, -names, -closed-weakest.
  - Nov 5 (15): oad-2026-closed-other-54, oad-2026-small-fixes, launch-list-radar, 50-best-spirited-2026, top-500-bars-2026, michelin-2027-malaysia, michelin-2026-thailand, -austria, -singapore, -south-korea, -canada, -portugal, -mexico, -us-gap, michelin-2027-latvia.
  - Nov 6 (11): michelin-2027-philippines-beijing-tianjin, michelin-a1-greece-south-australia-dubai, -a2-a3-b-e, -d1, -d-th-fi-lt, -d-no-se, -d-dk-vn, top-500-status, phase2-publish-design, phase2-publish-job-pr, plan-v131.
  - Project only (17): all Nov 5 handoffs except oad-2026-closed-other-54 and 50-best-spirited-2026, plus michelin-2027-philippines-beijing-tianjin, michelin-a1-greece-south-australia-dubai, michelin-a2-a3-b-e and top-500-status.
- The phase2 publish handoffs and plan-v131 are already recorded in v1.31 and v1.32. Part 3 is the award work only.
- Non-handoff sources: `claude/launch-list-2026-11-05.md`, the run folders on the branch for Nov 4-6, and the Cowork briefs and logs of those guides.
- Expect a large part (about 28 award handoffs, many guides). Consider 2 builds, as for part 2. The project-only count is high: copy them by `project_read` (`local_file` for large docs) or give the agent the Projects tool for those paths.
- Version-history anchor for v1.36: the end of the 1.35 row, text `Part 3 (Nov 4–6, ledger 280–376) is not in this version.</td></tr>`.
- Header anchor for v1.36: status text `part 2 (Nov 1–3, ledger 177–279) recorded in v1.34 (cards 1–4) and v1.35 (cards 5–8), part 3 (Nov 4–6, ledger 280–376) not yet in this plan`.
- Card placement: same anchor as v1.34 and v1.35, `  <div class="card">\n    <h3>Phase 2 record — publish job designed`.
- Status boxes for v1.36 go after the v1.35 boxes, text start `<b>Status, Nov 2–3 (v1.35).</b>`.
- Card 8 "Open" line ends with "Next in this record: part 3 (Nov 4–6, ledger 280–376), v1.36." Keep it true.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.35** | Final. On `oad-2026-read-block` (`c33e507`) and in the project (same name). `main` holds v1.32 | `31f06f2584c7bfcc50589be1f3609c60d195ef1b567ee8f2751b3e35587e2746` |
| `build135a.py`, `check_html.py`, `trace.py`, `ledger_table.py`, `parse_ledger.py`, `ledger235_279.json` | Sandbox only, not in the repo. The file checksum is the record | - |

## Open items, in order
1. **Gault & Millau France and Monaco 2027 from Nov 10** (opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`). Then Michelin Thailand 2027.
2. **Plan v1.36 (part 3, Nov 4-6, ledger 280-376).** Ask Ben for the card list first.
3. Merge `oad-2026-read-block` to `main` when Ben asks.
4. All other items as in the v1.32 card "Move goals and order of work".

## Suggested opening prompt: Plan v1.36 (if Ben wants it before Nov 10)
```
Read claude/handoff-plan-v135-done-2026-11-07.md from the project files for the plan state and the part 3 source list, then
claude/handoff-plan-v134-done-2026-11-07.md and claude/handoff-plan-v131-done-2026-11-06.md for the plan-edit method, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html on branch
oad-2026-read-block (expect 1.35, sha256 31f06f25…2746) and on main (1.32 unless I merged). Build from the 1.35 file.
Start Plan v1.36, part 3 of the award record after v1.30 (Nov 4-6, ledger 280-376): list the handoffs by date from both the
project and the branch, propose the cards and the number of builds, and ask me before you build. Build it, check it, and present it before you commit.
Keep handoffs on branch oad-2026-read-block.
```

For Gault & Millau from Nov 10, use the opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`.
