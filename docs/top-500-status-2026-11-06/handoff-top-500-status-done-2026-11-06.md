# Handoff: Top 500 Bars 2026 status read of the 45 new venues, done. No write. Nov 6, 2026 (20:05 Atlanta). Next: Gault & Millau France and Monaco 2027 (from Nov 10), then Thailand 2027.

This file adds to `handoff-michelin-d-dk-vn-done-2026-11-06.md`. That file stays the main record for the live state, methods, dead ends and the Gault & Millau opening prompt. This file closes open item 2 of that file. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 6)
- 19:56 "Let's start with 1" (status read of the 45 Top 500 venues).
- 20:02 "1-4: A".

## Start checks (this chat)
- Count read Nov 7, 00:48 UTC: all values equal the DK-VN handoff (ledger 376, audit_log 135,045, venues 11,831 / active 11,510 / closed 321, awards 29,052, OAD 2026 2,859, OAD 2025 2,437, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510).
- Fujian 2027: not out. Jing Li card reads "2026 MICHELIN Guide Fuzhou" (read Nov 7, about 00:50 UTC). Fujian list page: 95 restaurants, no year label.
- Gault & Millau 2027: not out on Nov 6. Gala Mon Nov 9, Carrousel du Louvre. Gala page lists 28 nominees for the 2027 national awards; winners at the gala. No live-row read, no list read, no file. Ben has a Reminders alert for Tue Nov 10, 9:00 AM.

## Live state (read Nov 7, 01:02 UTC, after the choices)
Unchanged: ledger last id 376, audit_log last id 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052, slugs 13,775, price 7,759, `cities.venues_count` sum 11,510.

## Done
Read only. No database write.

Population: the 45 venues inserted by the Top 500 Bars 2026 load (audit_log 131,136-131,897, `venues` INSERT). All 45: bar, active, listing published, 1 award (top-500-bars 2026), `last_verified` NULL.

| Finding | Count |
|---|---|
| Open, dated source: Bar Leone Shanghai, Cato London, Penicillin Shanghai (reopened) | 3 |
| Open now, closes Dec 20, 2026: Everson Royce Bar | 1 |
| No closure found (1 search each, titles only) | 41 |
| Total | 45 |

Evidence: `docs/top-500-status-2026-11-06/top-500-new-45-status-evidence-2026-11-06.csv` (45 rows, sha256 `48be17cf4c91a3c24088e134d043a25f30f8b1e59c36bf50aeda5831dbb6e2e5`). Fingerprint md5 of `venue_id|name|city|rank|status` sorted by venue_id, newline join: file = database = `ab8227d107154871ed9bd975d9ffbd4a`. Commit `46b72ad` on `oad-2026-read-block`.

## Decisions (Ben, 1-4: A)
1. All 45 stay active. No write.
2. Everson Royce Bar `ve_dcc55f9f59`: stays on the recheck list. After Dec 20, 2026, read again, then close with Ben's "go". Source: Time Out LA, Oct 23, 2026 (last service Dec 20).
3. `last_verified` on the 45: no write now. Context: 10,755 of 11,831 venues hold a date (Aug 6 to Sep 10, 2026).
4. Subastor `ve_bf4269c88e` (São Paulo): add to the Phase 3 location pass. 2 sites: SubAstor below Bar Astor Vila Madalena (`ve_81f9e4134a` is Bar Astor Vila Madalena) and Bar do Cofre SubAstor at Farol Santander. Which site the list means: not known.

## Evidence notes
- Penicillin Shanghai `ve_91413848cf`: closed Dec 2025 (investor dispute, SmartShanghai Feb 5, 2026), reopened under the original team (SmartShanghai May 26, 2026). 62 Nanchang Lu. No recheck.
- Bar Leone `ve_c26e5cde50` and Penicillin `ve_91413848cf` (Shanghai) are separate from the Hong Kong venues `ve_89e647b929` (Top 500 2026 rank 1) and `ve_0398aa18f7` (rank 62).
- Press Club `ve_45dfff6467` is not National Press Club `ve_359af3ba74` (as decided Nov 5).

## Weak points
- 41 venues: 1 web search each, result titles only. "No closure found" is not proof of open.
- Full page reads: Penicillin (2 pages), Everson Royce (1), a Dubai headline (Mar 2020, COVID; not relevant).

## Dead ends: do not retry
- Closed-published check on `venues.published`: no such column. Use `listings.published` joined on `venue_id`.
- `cities.name` does not exist. Use `cities.display`.
- SmartShanghai venue page `/venue/34052/penicillin`: WebFetch gets a firewall page only.

## Open items (changes to the DK-VN list)
- Item 2 (status read of the 45): **closed**.
- Item 3 (rechecks): Everson Royce Bar after Dec 20 (already listed in the Top 500 handoff).
- Item 7 (Phase 3 location pass): add Subastor `ve_bf4269c88e`.
- All other items as in `handoff-michelin-d-dk-vn-done-2026-11-06.md`. Next: Gault & Millau 2027 from Nov 10 (use the opening prompt in that file).

## Suggested opening prompt: Phase 2 publish job (Ben asked for it, Nov 6 20:18 ET)
Repo facts read Nov 6: plan `docs/CompassEats-Rearchitecture-Plan.html` is v1.30 (Oct 9). No publish code exists yet: `scripts/` holds `ingest/`, `rename/`, `sync-sheet.ts`. Workflows: ingest stage/promote/undo/tests, rename apply/undo/tests.
```
Read claude/handoff-top-500-status-done-2026-11-06.md and claude/handoff-michelin-d-dk-vn-done-2026-11-06.md from the project files for the live state and open items, then
claude/handoff-oad-2026-small-fixes-done-2026-11-05.md for the goals and the publish job definition,
claude/handoff-phase2-ingest-2026-09-11.md for how the ingest job was built and proven, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read Phase 2 and section 3 of docs/CompassEats-Rearchitecture-Plan.html (expect v1.30), docs/ingest-job.md, and the ingest and rename scripts and workflows as the model.
Start open item 8, the Phase 2 publish job. Goal by Nov 29: a job that builds from Postgres to sharded, versioned files, to a preview only, with promote-previous-version rollback. No change to the live site and no database write.
First give me a short plain-language design: what it reads, what files it makes, where the preview lives, how rollback works, how it compares with the live site data, and what I must do by hand (for example a secret or a merge), with click steps. List the questions the plan does not decide and ask me for choices.
After my choices: build on a new branch from main, run the tests and a preview build, present the evidence, then open a pull request for me to merge by hand. Keep handoffs on branch oad-2026-read-block. Suggest a handoff break before a new large block.
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
