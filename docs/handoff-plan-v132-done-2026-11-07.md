# Handoff: Plan v1.32 saved (move goals, order of work, Phase 4-6 dates). Nov 7, 2026 (00:15 Atlanta). Next: Gault & Millau France and Monaco 2027 from Nov 10, or Plan v1.33.

This file adds to `handoff-plan-v131-done-2026-11-06.md` (plan-edit methods and dead ends) and `handoff-michelin-d-dk-vn-done-2026-11-06.md` (live state, open items, Gault & Millau opening prompt). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 6, 23:57: opening prompt for Plan v1.32.
- Nov 7, 00:12: "You can change it to after the move" (Phase 6 tag).
- Nov 7, 00:13: "Go".

## Start checks (this chat)
- Date: Nov 6 ET at the start. Gault & Millau is due from Nov 10.
- Count read Nov 7, 04:57:58 UTC, whole tables. All equal the v1.31 handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321, other 0), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Slug read Nov 7, 04:59 UTC: canonical 11,831, non-canonical 1,944 (population: 13,775 slugs).
- Repo: Ben merged PR #14 (`6c7c1b0`, Nov 6 23:55:52 -0500). `main` held v1.31, sha256 `f69452fe…52fe` (as expected).

## Done
No database write. No change to the live site.

**Plan v1.32 built, checked, saved.**
- Build: `build132.py` (sandbox only). Base sha256 asserted. Anchored `replace` calls, each asserted to match once. 57 lines added, 9 lines changed.
- New card after the publish-job card: "Move goals and order of work" (Nov 5-7). Goals table with a state column, launch list v1 summary, order of work in 10 items (combined from the Nov 6 handoffs in their order), after-cutoff and after-move lists, repo note, open decisions, live counts.
- Phase 4 tag: "Goal: Jan 9 - Feb 6, 2027". The "Dates under review" box is replaced by a "Dates set as goals" box.
- Phase 5 tag: "Goal: Feb 27-28, 2027". New "Dates set as goals" box: address check Feb 21, move Feb 27-28 (unpromoted), Lovable off about Mar 29, address-check sizes (Nov 5 goal table 1,941 and 1,532; Nov 6 live compare 1,523; Nov 7 read 1,944 non-canonical slugs).
- Phase 6 tag: "After the move" (Ben, Nov 7). Was "Nov onward".
- Header (Version, Updated, Author, Status, Responds to) and version-history row 1.32.
- Older cards that say "dates under review" stay as dated history.

**Checks** (population: the added and changed lines):
- HTML: `html5lib` 2 errors, the same 2 as v1.31 (line 7, the font link). 0 tag mismatches. 0 unclosed tags.
- Number trace (`trace.py`): 92 numbers, ids and paths. All in a source file.
- Independent read-only agent, about 95 statements: 3 problems and 10 borderline points. All fixed before the save:
  1. "Tabelog first" was stated as fact. Now "Tabelog is the recommended first".
  2. The order of work was regrouped. Now it follows the source order (v1.31 handoff items 2, 3, 5, then the DK-VN list with the Top 500 changes).
  3. "Research result (after Nov 7)" was missing. Added.
  4. Borderline fixes: "Ben accepted" the goals; the pace read (8 batches Oct 8 - Nov 2, about 14 fit before Dec 20); "Not started (Nov 5 read)"; the merge stated without "by hand"; the address-check numbers split by source, plus the Nov 6 compare (1,523); rechecks placed once; the full list of open decisions; Ben's "A" quoted with its meaning; the slug split marked as new; the project path `claude/launch-list-2026-11-05.md`.
- Wording: 0 should/could/may forms. 1 prose semicolon removed.
- Sources for the check: the Nov 5 launch list and a goals excerpt of the Nov 5 small-fixes handoff were copied from `project_read` into the sandbox (they are not in the repo).

**Save** (Ben "Go", Nov 7 00:13 ET):
- Commit `10ca899` on `oad-2026-read-block` (Nov 7, 00:13 -0500), 1 file.
- Fresh clone of the branch: sha256 `26fe414a345f9f424aa7306df07b37f57265a59e014b38e0cd1b5486858b8b0f`, 290,194 bytes, Version 1.32.
- Project copy over the same name (`CompassEats-Rearchitecture-Plan.html`): read back, sha256 equal, Version 1.32.
- **Merged to `main`** (Ben asked, Nov 7 00:16 ET): PR #15 opened and merged by Claude through the GitHub REST API (`gh api`, merge commit `214a07f`, Nov 7 00:17:14 -0500). Fresh clone of `main`: plan sha256 `26fe414a…8b0f`, Version 1.32, this handoff present.

## Methods (new)
- **Merge by REST API:** `gh pr create` fails (GraphQL 403 in this session). Use `gh api repos/<o>/<r>/pulls -X POST -f base=main -f head=<b> ...`, then `gh api repos/<o>/<r>/pulls/<n>/merge -X PUT -f merge_method=merge -f sha=<head sha>`. Ben asked for this merge in the chat; the Nov 5 dead end was a direct push to `main`, not a PR merge.
- A shallow clone gives "no merge base" for `git diff main...branch`: fetch `--depth=50` with refspecs first.
- `project_write` with `local_path` needs a file inside the working directory (`/home/claude/...`). A scratchpad path is refused.
- The independent check cost about 142k agent tokens for 54 added lines.

## Dead ends: do not retry
- A Python fix list with a placeholder entry: the assert stops the whole run before the write. Remove test entries first.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.32** | Final. On `main` (`214a07f`, PR #15), on `oad-2026-read-block` (`10ca899`) and in the project (same name) | `26fe414a345f9f424aa7306df07b37f57265a59e014b38e0cd1b5486858b8b0f` |
| `build132.py`, `check_html.py`, `trace.py` | Sandbox only, not in the repo. The file checksum is the record | - |

## Open items, in order (as in the v1.32 card "Move goals and order of work")
1. **Gault & Millau France and Monaco 2027 from Nov 10** (opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`). Then Michelin Thailand 2027 (after Nov 10).
2. **Plan v1.33 and later:** the award record after v1.30 (Oct 9 - Nov 6, ledger 103-376), in 2 or 3 parts by date.
3. Publish-job open items (v1.31 card).
4. Editions due before the cutoff; foundation (price method, Madame Vo, Hotel de Paris Monte-Carlo).
5. Rechecks, same-name pairs, rename batch, archive URLs, Phase 3 location pass, research result: as in the v1.32 card.
6. Done: PR #15 merged Nov 7 (`214a07f`). Only this merge-note edit of the handoff is on the branch after it.

## Suggested opening prompt: Plan v1.33 (if Ben wants it before Nov 10)
```
Read claude/handoff-plan-v132-done-2026-11-07.md from the project files for the plan state, then
claude/handoff-plan-v131-done-2026-11-06.md and claude/handoff-plan-v130-done-2026-10-09.md for the plan-edit method, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html on branch
oad-2026-read-block (expect 1.32, sha256 26fe414a…8b0f) and on main (expect 1.32, merged Nov 7 in PR #15). Build from the 1.32 file.
Start Plan v1.33, part 1 of the award record after v1.30: list the handoffs from Oct 9 on by date, propose how to split ledger 103-376
into 2 or 3 parts, and ask me to choose before you build. Build it, check it, and present it before you commit. Keep handoffs on branch oad-2026-read-block.
```

For Gault & Millau from Nov 10, use the opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md` (its counts are still current).
