# Handoff: Phase 2 publish job, design approved (1-8: A). No code yet. Nov 6, 2026 (20:50 Atlanta). Next: build the publish job in a fresh chat. Goal: Nov 29.

This file adds to `handoff-top-500-status-done-2026-11-06.md` and `handoff-michelin-d-dk-vn-done-2026-11-06.md`. Those files stay the main record for the live state, the open items and the Gault & Millau opening prompt. This file holds the publish-job design and Ben's choices. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Ingest model: `handoff-phase2-ingest-2026-09-11.md`.

## Ben's input (ET, Nov 6)
- 20:20 opening prompt: start open item 8, design first, questions, then build.
- 20:47 "1-8: A".

## Start checks (this chat)
Count read Nov 7, 01:20 UTC, whole tables. All values equal the Top 500 handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.

Repo: `main` at `d2a8647` (merge of PR 11, Nov 6 14:54 -0500). Branch `oad-2026-read-block` was at `d78dafc` before this file. Plan `docs/CompassEats-Rearchitecture-Plan.html` is v1.30.

No database write. No code change. Read only.

## Facts read for the design (Nov 7, about 01:25 UTC)
| Item | Value | Population |
|---|---|---|
| `geo` rows | 0 | whole table |
| `addresses` rows | 0 | whole table |
| Cities with a map center (`lat` not null) | 0 of 3,344 | whole `cities` table |
| Cities with no region | 2,097 of 3,344 | whole `cities` table |
| Regions | 113 | whole table |
| Cities that hold an active venue | 3,274 | distinct `city_id` over 11,510 active venues |
| Non-canonical slugs | 1,944 | whole `slugs` table (13,775) |
| Blurbs | 142: `needs_rewrite` 140, `rewritten` 2 | whole table |
| `photo_refs`, `hours` | 0 rows each | whole tables |
| award_sources | 23, all `active`, `attribution_required` empty on all 23 | whole table |
| properties | 2: `eats`, `local` | whole table |
| Active venues by category | restaurant 10,516, bar 994 | 11,510 active |

Repo facts: `scripts/` holds `ingest/`, `rename/`, `sync-sheet.ts`. Workflows: ingest stage/promote/undo/tests, rename apply/undo/tests. The live site builds from `data/venues.json` (10,912 rows; `sync-report.json` dated Aug 5, 2026 says 10,921 venues, 10,560 active). Live venue `id` is a Google place id (`ChIJ…`), and live rows carry Google `lat`, `lng`, `address`. Other live files: `cities.json`, `regions.json`, `venues-index.json`. `src/lib/venues.ts` and `src/lib/cities.ts` read them (`venues.ts` is locked for Lovable).

Sandbox facts: PostgreSQL 16 is installed at `/usr/lib/postgresql/16` (`psql` on the path). `bun` is at `/root/.bun/bin/bun`. The ingest test harness (`scripts/ingest/test/harness.ts`) builds a throwaway database from `docs/compass-schema-v1.sql` plus `supabase/migrations/`, with the live `norm_key()` body patched in.

## Design (approved, 1-8: A)
**Reads.** Existing secret `SUPABASE_DB_URL` (Session pooler). One `BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY` transaction for all reads. Tables: venues, listings (`property_id='eats'`, `published`), slugs (canonical, `eats`), cities, regions, awards, award_sources (exclude `status <> 'active'`), price, blurbs, redirects, plus geo, addresses, hours, photo_refs (empty today), and the `source_exposure` view. Records ledger last id and audit_log last id in the manifest. No database write. No new dependency (Bun built-in `SQL`, as `scripts/ingest/lib/db.ts`).

**Files, one version folder per build** (`versions/<UTC time id>/`):
- `manifest.json`: version id, build time, git sha, database ids, per-file sha256 and row count.
- `index.json`: 1 light row per published venue (11,510 today).
- `venues/<city_slug>.json`: 1 file per city with a published venue (3,274 today). Full venue rows: `ve_` id, name, `name_native`, category, city, cuisine, all award rows (all years), price (tier, symbol, currency, publisher), blurb (rule Q4).
- `cities.json`, `regions.json`: counts made by the job itself (Q5).
- `redirects.json`: 35 redirect rows plus 1,944 non-canonical slugs to their canonical slug.
- `attribution.json`: each source present, display name, row counts.
- `report.md` plus CSVs: gates, exposure table, blurb coverage, diff against the last version, compare against the live `data/venues.json`.
- Output is deterministic: sorted rows and keys, so one database state gives the same bytes. A test proves it.

**Preview store (Q1 A).** Branch `publish-preview` in the private repo: version folders plus `channels/preview.json` (current version and a history list). No site code on that branch. The live site does not read it.

**Buttons.**
| Workflow | Action | Gate |
|---|---|---|
| Publish — build | New version folder plus report. Does not move the pointer. | Build gates below |
| Publish — promote | Points `channels/preview.json` at a version | Typed `PUBLISH <version>` |
| Publish — rollback | promote-previous-version: points back to the version before, after a hash check of that folder against its manifest | Typed `ROLLBACK <version>` |
| Publish — tests | CI on push and pull request, throwaway Postgres, no secret | none |

**Build gates (fail = no version written).** Venue count in files = active published count in the database. Every venue: exactly 1 canonical `eats` slug, city exists. No closed venue, no suspended source, no Google value (`ChIJ` ids, `google` source). No venue with 2 Michelin rows of the same year and category. Active count decrease more than 0.5% from the last version needs a typed override.

**Live compare groups (as the Nov 5 table):** same address; same address, name differs; live page, closed in the database; live address is an old slug; active in the database, no live page. Plus a count of fields the live file has and the new files lack (coordinates, address). Weak point: repo file, not the deployed site.

**Proof before merge.** Export the live tables through the Read connector into scratch, load them into a local throwaway Postgres 16, run the real build against it, and show the report and hashes. No database write. After merge, Ben runs the real buttons (2 supervised runs, as the plan says).

## Ben's choices (1-8: A)
1. Preview store: branch `publish-preview` in the repo.
2. Database login: existing `SUPABASE_DB_URL`, read-only transaction. A read-only database user stays a later item (needs 1 database change with Ben's "go").
3. Closed venues (321 of 11,831): left out, as `listings.published` says. Old addresses go to the Phase 5 address check.
4. Blurbs: publish only blurbs whose status is not `needs_rewrite` (2 of 142 today).
5. City counts: the job counts venues itself and reports any difference from `cities.venues_count`.
6. Confirmation `PUBLISH <version>` and `ROLLBACK <version>`. Keep the last 10 version folders in the tree; older ones stay in git history.
7. Runs only when Ben presses the button. No schedule.
8. Exposure (D10): table in the report, no cap gate now.

## Findings for the plan (v1.31 item)
- The preview has no map points: geo 0, addresses 0, city centers 0 of 3,344. D4 and D6 keep Google coordinates out. Phase 3 fills this.
- 2,097 of 3,344 cities have no region. Region files cover only cities with a region.
- `attribution_required` is empty on all 23 sources, so the attribution CI check has nothing to enforce yet.
- The plan's word `PUBLISH` becomes `PUBLISH <version>` (same reason as the ingest `PROMOTE <batch_key>` choice).

## Weak points
- Lovable is expected to deploy from `main` only. Confirm that a push to `publish-preview` starts no Lovable or Cloudflare deploy before the first real build run.
- The live compare uses the repo file `data/venues.json`, not the deployed pages.
- The Read-connector export for the proof build is large (11,510 venues, 29,052 awards). Use `json_agg` per table, saved tool results, and decode as in the Nov 5 method.

## Dead ends: do not retry
- `register_repo_root` tool: not available in this session. The repo has no `CLAUDE.md`.
- `ls scripts scripts/*` in one command printed only `sync-sheet.ts`. Use `find scripts -type f`.
- `cities.lat` as a map center: null on all 3,344 rows.

## Open items (changes to the DK-VN and Top 500 lists)
- Item 8 (Phase 2 publish job): design done, choices 1-8 A. Next: build.
- Item 9 (Plan v1.31): add the publish-job design, the choices and the findings above.
- New later item: read-only database user and secret for the publish job (Q2 B), with Ben's "go".
- All other items as in `handoff-michelin-d-dk-vn-done-2026-11-06.md` and `handoff-top-500-status-done-2026-11-06.md`. Gault & Millau 2027 from Nov 10.

## Suggested opening prompt: build the publish job
```
Read claude/handoff-phase2-publish-design-2026-11-06.md from the project files for the approved design and my choices 1-8: A, then
claude/handoff-top-500-status-done-2026-11-06.md for the live state and open items,
claude/handoff-phase2-ingest-2026-09-11.md for how the ingest job was built and proven, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read docs/ingest-job.md, the ingest and rename scripts, the test harness and the workflows as the model.
Build the Phase 2 publish job as designed, on a new branch from main: build, promote and rollback scripts and workflows, the tests, and docs/publish-job.md with click steps.
Run the tests. Then run a preview build here against a local throwaway Postgres loaded from a read-only export of the live tables, and present the evidence: gates, file counts, hashes, the live-site compare and a rollback test.
Then open a pull request for me to merge by hand. No change to the live site and no database write. Keep handoffs on branch oad-2026-read-block.
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
