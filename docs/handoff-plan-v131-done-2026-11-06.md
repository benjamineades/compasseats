# Handoff: Plan v1.31 saved (Phase 2 publish job record). Nov 6, 2026 (23:55 Atlanta). Next: Plan v1.32 (move goals and order of work), or Gault & Millau France and Monaco 2027 from Nov 10.

This file adds to `handoff-phase2-publish-job-pr-2026-11-06.md` (publish job state, methods, dead ends) and `handoff-michelin-d-dk-vn-done-2026-11-06.md` (live state, open items, Gault & Millau opening prompt). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Plan-edit method: `handoff-plan-v130-done-2026-10-09.md`, plus the new methods below.

## Ben's input (ET, Nov 6)
- 23:29 opening prompt: Plan v1.31 with the publish-job content.
- 23:50 "What would you recommend?" Claude recommended A: save v1.31 as built, record the rest in v1.32 and later.
- 23:50 "A and go".

## Start checks (this chat)
- Date: Nov 6. The Gault & Millau prompt starts Nov 10.
- Count read Nov 7, 04:29:55 UTC, whole tables. All equal the publish-job handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321, other status 0), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Repo: `main` at `f99bc53` (merge of PR 13). Plan Version 1.30, sha256 `748defe9be3f54ecf581f374fcee74dd2024f8ea0eaf5925c89468161c672216`. The copy on `oad-2026-read-block` was the same file.

## Done
No database write. No change to the live site.

**Plan v1.31 built, checked, saved.**
- Build: `build131.py` (sandbox only). Base sha256 asserted. 11 anchored `replace` calls, each asserted to match once. 128 lines added, 5 lines changed.
- New card after the Germany card: "Phase 2 record — publish job designed, built, merged and run on a preview branch". It holds the design, Ben's choices 1-8, build choices 1-7, 5 changes to the written design (each tied to a choice or marked as a finding), the rehearsal proof, the 6 supervised runs, the deploy check, the live compare, the findings, open items, weak points and live counts.
- Small edits: header (Version, Updated, Author, Status, Responds to), a note in the §03 publish card, a status box in the Phase 2 card, a finding in the Phase 3 card (no map points), an update in the Phase 5 card (city counts, `redirects.json` 1,957 rows), version-history row 1.31.
- The header and the new card say that the award work after v1.30 (Oct 9 - Nov 6, ledger 103-376) is not in this version.

**Checks** (population: the 128 added and 5 changed lines):
- HTML: `html5lib` 2 errors, the same 2 as v1.30 (line 7, the font link). 0 tag mismatches. 0 unclosed tags.
- Number trace (`trace.py`): 122 numbers, ids, hashes and paths. All 122 are in a source file.
- Independent read-only agent, about 125 statements: 1 problem and 6 borderline points. All fixed before the save:
  1. The build session was Claude Code, not a plain chat ("Model & surface" row).
  2. The range "ledger 101-376, Oct 10 - Nov 6" was an inference. Ledger ids 101 and 102 do not exist. Now "after v1.30 (Oct 9 - Nov 6, ledger 103-376)".
  3. "9 of 9 gates" and "0 cities differ" on build 2: read from the build 2 manifest and report. Both true.
  4. "Ben's go each time" is now "Ben's instruction each time" (build #1 started on "use chrome and do this").
  5. Change 4 (empty `attribution_required`) is now marked as a finding, not a choice.
  6. The caps wording now matches §05 and the Phase 2 card separately.
  7. The PR text lists build choices 1-5 only. The card says that the handoff adds 6 and 7.
- Wording: 9 prose sentences that joined two statements with a semicolon are now split. 0 should/could/may forms.

**Save** (Ben "A and go"):
- Commit `8e08f2c` on `oad-2026-read-block` (Nov 6, 23:51 -0500), 1 file.
- Fresh clone of the branch: sha256 `f69452fe78e1e361b3dd482f7f889096c8a8580daa338d58000451c3c73f52fe`, 280,623 bytes, Version 1.31.
- Project copy over the same name (`CompassEats-Rearchitecture-Plan.html`): read back, sha256 equal, Version 1.31.
- `main` still holds v1.30. The merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Facts read in this session
- Ledger after v1.30: id 100 = Oct 9, 03:52 UTC (`rename-apply:rename-majority-2026-germany`). Ids 101 and 102 do not exist. The first id above 100 is 103 = Oct 10, 14:21 UTC (`ingest-promote:michelin-2026-texas`). Id 376 = Nov 7, 00:44 UTC (Vietnam). Rows: 74 at v1.30, 322 now (248 more, count difference).
- Both real builds (`20261107T033856Z`, `20261107T042410Z`): 9 of 9 gates. Cities that differ from `cities.venues_count`: 0 (population: 3,344 cities). Cities in `cities.json` with no region: 2,054 of 3,274. Venues with no award row: 2.
- `publish-preview` tip `4870fd1`. `channels/preview.json`: current `20261107T033856Z`, stack [`20261107T033856Z`], history 3 actions.
- Some Oct 9 decisions came after the v1.30 save (00:16 -0400). They are part of the v1.32+ backlog.

## Methods that worked (new)
- **Project copy check:** `project_read` of a large doc now returns a `local_file`. Its sha256 equals the repo file. So the project copy can be hashed. This replaces the v1.30 dead end "hashing the project copy".
- **Number trace:** `trace.py` takes every number, hex id, `ve_` id, version id and path from the added diff lines and searches a sources folder. 0 missing is a token check, not a statement check. Run it before the independent check.
- **Sources for a check, from the repo:** the handoffs are in `docs/` on `oad-2026-read-block`. `git show origin/oad-2026-read-block:docs/<file> > src/<file>`. Also the PR text through `curl https://api.github.com/repos/benjamineades/compasseats/pulls/<n>`, and the build manifests and reports from `publish-preview`.
- **Independent check:** give the agent the diff and a local sources folder (no Projects tool). Tell it to grep the large manifest, not read it. Cost: about 135k agent tokens for 128 added lines (v1.30: about 190k for 144).
- **Fetch a branch into a ref:** `git fetch --depth=1 origin +refs/heads/<b>:refs/remotes/origin/<b>`.
- **Commit to the handoff branch from the shallow clone:** `git checkout -b oad-2026-read-block origin/oad-2026-read-block`, commit, `git fetch origin main`, push. Push worked first try.

## Dead ends: do not retry
- `git fetch --depth=1 origin <branch>` with no refspec: it makes no `origin/<branch>` ref (FETCH_HEAD only). Use the refspec above.
- `html5lib` is not installed in the sandbox: `pip install --break-system-packages html5lib`.
- An anchor string from an earlier wording fix: after a fix changes a sentence, the next fix must use the new text (one script run stopped on a count of 0; the script was not changed by that run).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.31** | Final. On `oad-2026-read-block` (`8e08f2c`) and in the project (same name). `main` holds v1.30 until Ben merges | `f69452fe78e1e361b3dd482f7f889096c8a8580daa338d58000451c3c73f52fe` |
| `build131.py`, `check_html.py`, `trace.py` | Sandbox only, not in the repo. The file checksum is the record | - |

## Open items, in order
1. **Plan v1.32 (Ben: A).** Add the Nov 5 move goals (goals table in `handoff-oad-2026-small-fixes-done-2026-11-05.md`: data cutoff Dec 20, 2026; 3 design sessions Jan 9, Jan 23, Feb 6; address check Feb 21; move Feb 27-28, 2027; Lovable off about Mar 29) and the current order of work (DK-VN and Top 500 handoffs, `launch-list-2026-11-05.md`). Replace the "dates under review" text in Phase 4 and 5. Small version.
2. **Gault & Millau France and Monaco 2027 from Nov 10** (opening prompt in the DK-VN handoff). Thailand 2027 after Nov 10.
3. **Plan v1.33 and later:** the award record after v1.30 (Oct 9 - Nov 6, ledger 103-376), in 2 or 3 parts by date. Sources: the handoffs from Oct 9 on (each lists its "Plan v1.31" content).
4. **Merge `oad-2026-read-block` to `main`** (Ben, by hand, compare link above): Plan v1.31, the publish proof folder, handoffs.
5. Publish-job open items (in the v1.31 card): read-only database user and secret (Ben's "go"); cuisine tags gap (8,488 `legacy_guide` venues); Mirabelle address; Cham redirect to a closed venue; 2 venues with no award row; Lovable "Build unsuccessful" label; `actions/checkout` and runner labels in 11 workflows.
6. All other items as in `handoff-michelin-d-dk-vn-done-2026-11-06.md` and `handoff-top-500-status-done-2026-11-06.md`.

## Suggested opening prompt: Plan v1.32 (or use the Gault & Millau prompt in the DK-VN handoff from Nov 10)
```
Read claude/handoff-plan-v131-done-2026-11-06.md from the project files for the plan state, then
claude/handoff-oad-2026-small-fixes-done-2026-11-05.md for the Nov 5 move goals,
claude/launch-list-2026-11-05.md, claude/handoff-michelin-d-dk-vn-done-2026-11-06.md and
claude/handoff-top-500-status-done-2026-11-06.md for the live state and the order of work,
claude/handoff-plan-v130-done-2026-10-09.md for the plan-edit method, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html on branch
oad-2026-read-block (expect 1.31) and on main (1.31 if I merged, else 1.30). Build from the 1.31 file.
Start Plan v1.32: add the Nov 5 move goals and the current order of work, and replace the "dates under review" text in Phase 4 and 5.
Build it, check it, and present it before you commit. Keep handoffs on branch oad-2026-read-block.
```
