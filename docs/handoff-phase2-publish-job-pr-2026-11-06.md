# Handoff: Phase 2 publish job built, proven on a local copy of live, PR 13 open. No write. Nov 6, 2026 (21:30 Atlanta). Next: Ben merges PR 13 and does the 2 supervised runs; Gault & Millau France and Monaco 2027 from Nov 10.

This file adds to `handoff-phase2-publish-design-2026-11-06.md` (design, choices 1-8: A), `handoff-top-500-status-done-2026-11-06.md` and `handoff-michelin-d-dk-vn-done-2026-11-06.md` (live state, open items, Gault & Millau opening prompt). Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Ingest model: `handoff-phase2-ingest-2026-09-11.md`.

## Ben's input (ET, Nov 6)
- 20:59 opening prompt: build the publish job as designed, test, preview build on a local copy, evidence, PR for a hand merge.

## Start checks (this chat)
- Date: Nov 6. The Gault & Millau prompt starts Nov 10.
- Count read Nov 7, 02:00 UTC, whole tables. All equal the design handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Repo: `main` at `0e08b6c` (merge of PR 12, Nov 6 20:57 -0500). PR 12 holds the design handoff and the Top 500 files only (docs). The design handoff said `d2a8647` (PR 11); PR 12 merged after it was written.

## Done
Read only. No database write. No change to the live site. The real `publish-preview` branch was not created.

**Branch `phase2/publish-job`** (from `main` `0e08b6c`), 3 commits:
| Commit | What |
|---|---|
| `4b6a488` | The job: `scripts/publish/` (build, promote, rollback, lib, tests, seed, live fixture, `checkout-preview.sh`), 4 workflows, `package.json` scripts, `tsconfig.scripts.json`, `harness.ts` `buildSchema()` split |
| `0d39444` | Fix found by the preview build: an old slug that the redirects table already sends to the same page is written once (2 rows) |
| `4ce8544` | `docs/publish-job.md` (manual with click steps) |

**PR 13:** https://github.com/benjamineades/compasseats/pull/13 (open, head `4ce8544`). Ben merges by hand.

**Tests** (local Postgres 16, throwaway): publish 39 pass, ingest 40 pass, rename 24 pass. Typecheck clean. GitHub Actions: Publish — tests, Ingest — tests, Rename — tests, on the push and on PR 13: 6 of 6 runs success.

**Proof** on `oad-2026-read-block`, commit `c3e1798`: `docs/publish-job-proof-2026-11-06/` (22 files, `SHA256SUMS` sha256 `ea2639e1b3ee5b7959f75b75cbb13b0f9e846a447a8058300d2242484aa4f6b8`).

| Proof | Result | Population |
|---|---|---|
| Local copy = live | md5 of every row, 12 tables: all equal, before and after the builds | award_sources, regions, cities, venues, listings, slugs, redirects, awards, price, blurbs, ledger, properties (live read Nov 7 02:17:20 UTC) |
| Gates | 9 of 9 pass | 11,510 venues with a published listing |
| Files | index 11,510; city files 3,274; cities 3,274; regions 112; redirects 1,957 (35 + 1,922); attribution 21 | version `20261107T021949Z` |
| Size and hash | 3,279 data files, 13,527,914 bytes; content `3aca439f5764bf656e5c56d6dfe90b6495fc0e771a75e7c69cab2ac202689783` | same version |
| Same bytes twice | build 2 `20261107T022009Z`: same content hash, 0 added / 0 removed / 0 changed | 11,510 venues |
| Independent check (`tools/verify.py`) | 3,287 files, 0 sha256 mismatches; awards 28,274, prices 7,690, blurbs 2, native names 340, redirects 1,957: files = SQL | both versions |
| Rollback | runs 101-112: wrong confirmations refused; promote A, B; rollback to A; changed file refused (`venues/paris.json` named); clean rollback after the revert | local stand-in for GitHub, fresh clone per run |

**Live compare** (population: 10,551 live pages in `data/venues.json`; 11,510 venues): same address 8,976 (name differs 432); live page closed in the database 52; old slug 1,367; no slug row 156; published with no live page 2,534. Fields (live / files): coordinates 10,551 / 0, address 10,551 / 0, cuisine 8,430 / 0, price 6,997 / 7,690, blurb 9,638 / 2.

## Live state (read Nov 7, 02:24 UTC, end of session)
Unchanged from the start read: ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, `cities.venues_count` sum 11,510.

## Choices made in the build (not set by the design; in the PR text for Ben)
1. `ROLLBACK <version>` names the version the preview points at now.
2. Gate 9 `redirect_from_unique`: no old address with 2 different answers. 2 old slugs repeat a redirects-table row with the same answer (`/fukui/kawaki`, `/yokahama/nakajo`): written once, as the table row.
3. `geo`, `addresses`, `hours`, `photo_refs`: read and counted, not published (Phase 3 shape). 0 rows each.
4. Award rows carry `id` and `source_url`. The compare CSV has no live ids (Google place ids).
5. Old slugs of an unpublished venue get no redirect (20 rows).
6. Version id `YYYYMMDDTHHMMSSZ` (UTC). The build refuses an id not newer than the newest in the tree.
7. Prune keeps the newest 10 plus the current version and the rollback target, at any age.

## Findings (for the plan v1.31 item)
- `venues.cuisine_tags` is NULL on all 11,831 rows; `cuisine_source = 'legacy_guide'` on 8,488. Live file: cuisine on 8,430 of 10,551 pages. Cuisine did not reach the database.
- Blurbs: 2 of 11,510 venues in the files (140 of 142 rows are `needs_rewrite`); live file: 9,638 pages.
- Mirabelle `ve_bb17fb8774`: canonical address `/vail-and-beaver-creek-colorado/mirabelle`, city slug `beaver-creek-colorado`.
- Redirect `/cham/the-dining-room` points at `/cham-ch/the-dining-room`, a closed venue (`ve_16681ee5aa`).
- 2 published venues hold no award row: `ve_514f90f364`, `ve_86b759e5f5`.
- Award rows with no `source_url`: 14,045 of 28,274 in the files.
- Cities with a published venue and no region: 2,054 of 3,274.
- `cities.venues_count`: 0 cities differ from the job's own count (population: 3,344 cities).

## Methods that worked
- **Export for a local copy:** `json_agg(json_build_array(...) order by <pk> collate "C")`, several tables per call. Results over the limit are saved to a file; `tools/decode.py` reads `{"result": ...}`, takes the text between the `untrusted-data` tags, and writes 1 JSON file per column. 3.4 MB in one call worked.
- **Load:** `tools/make_load_sql.py` writes COPY blocks; `set session_replication_role = replica` (no audit triggers, no FK order); COPY fills `GENERATED ALWAYS` identity columns; `delete from award_sources` first (the schema seeds 23). audit_log gets 1 marker row at the live last id.
- **Fingerprint:** `md5(string_agg(t::text, E'\n' order by <pk> collate "C"))` per table, in one query (one snapshot). Local session `timezone=UTC`, `extra_float_digits=0` (live values). The generated `venues.norm_key` matched, so the live `norm_key()` body is right in the harness.
- **Local Postgres:** data folder in `/var/tmp/compass-pg` (the `postgres` user cannot reach the scratchpad), port 5433.
- **Workflow rehearsal:** a bare clone as `origin`, `main` = the PR branch; `tools/wf.sh` runs each button from a fresh shallow clone with the workflow's steps.
- **Open a PR:** `curl -X POST https://api.github.com/repos/benjamineades/compasseats/pulls` with a JSON body works through the proxy (no token needed in the command). GET on `/actions/runs?head_sha=` shows CI.

## Dead ends: do not retry
- `gh` CLI: "The token in GH_TOKEN is invalid". Use `curl` to `api.github.com`.
- `register_repo_root`: not available. The repo has no `CLAUDE.md`.
- `initdb` in the scratchpad: permission denied for the `postgres` user. Use `/var/tmp`.
- `git revert -q`: not a flag.
- `/usr/bin/time`: not installed.
- A first gate rule "every redirect `from` once" failed on live data: 2 same-answer pairs. Fixed in `0d39444`.

## Weak points
- The rehearsal ran the workflow steps by script, not on GitHub Actions. The 2 supervised runs are the first real runs.
- A push to `publish-preview` starting a Lovable or Cloudflare deploy: not checked yet. The branch holds no site code. Manual step "Before the first run", 3.
- Build time on GitHub (network read through the Session pooler) is not measured. Local: about 1 second.
- The live compare reads the repo file, not the deployed pages.

## Open items (changes to the DK-VN and Top 500 lists)
- Item 8 (Phase 2 publish job): **built, PR 13 open.** Next: Ben merges, then the 2 supervised runs (`docs/publish-job.md`, "The two supervised runs"), then the deploy check. Goal Nov 29.
- Item 9 (Plan v1.31): add the publish-job design, choices 1-8, the build choices 1-7 above, and the findings above.
- New: cuisine tags gap (8,488 `legacy_guide` venues with no tags); Mirabelle address; Cham redirect to a closed venue; 2 venues with no award row.
- Later item (unchanged): read-only database user and secret for the publish job, with Ben's "go".
- All other items as in `handoff-michelin-d-dk-vn-done-2026-11-06.md` and `handoff-top-500-status-done-2026-11-06.md`. **Gault & Millau 2027 from Nov 10** (opening prompt in the DK-VN handoff).

## Suggested opening prompt: after the 2 supervised runs
```
Read claude/handoff-phase2-publish-job-pr-2026-11-06.md from the project files for the publish job state, then
claude/handoff-michelin-d-dk-vn-done-2026-11-06.md for the live state and open items, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats. I merged PR 13 and ran the 2 supervised runs. Read the publish-preview branch: channels/preview.json,
the version folders and their reports. Check each version folder against its manifest, compare the content hashes with the
Nov 7 rehearsal (3aca439f...9783), and tell me if anything differs. Then tell me what the deploy check must show.
No database write. Keep handoffs on branch oad-2026-read-block.
```
