# Handoff: Plan v1.34 saved (award record after v1.30, part 2, cards 1-4: Nov 1-2, ledger 177-234). Nov 7, 2026 (07:40 Atlanta). Next: Plan v1.35 (part 2, cards 5-8), or Gault & Millau France and Monaco 2027 from Nov 10.

This file adds to `handoff-plan-v133-done-2026-11-07.md` (plan state before v1.34, part 1 record, part 2 source list) and `handoff-plan-v131-done-2026-11-06.md` (plan-edit methods and dead ends). Plan-edit method: `handoff-plan-v130-done-2026-10-09.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Live state, open items and the Gault & Millau opening prompt: `handoff-michelin-d-dk-vn-done-2026-11-06.md`.

## Ben's input (ET, Nov 7)
- 07:06: opening prompt for Plan v1.34.
- 07:10 "1-2: A": 1 A = part 2 in 8 cards (proposal below). 2 A = 2 builds, each with its own check, a handoff between them.
- 07:34 "Go" (commit build 1).

## Start checks (this chat)
- Date: Nov 7. Gault & Millau is due from Nov 10.
- Count read Nov 7, 12:07:25 UTC, whole tables. All equal the v1.33 handoff: ledger last id 376 (322 rows), audit_log last id 135,045 (129,216 rows), venues 11,831 (active 11,510, closed 321, other 0), awards 29,052, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0, active not published 0, `cities.venues_count` sum 11,510.
- Repo: `main` at `214a07f`, Plan 1.32 (sha256 `26fe414a…8b0f`, 290,194 bytes). `oad-2026-read-block` at `ce1c080`, Plan 1.33 (sha256 `ee258095…10ab`, 320,753 bytes).

## Part 2 sources (population: handoff files dated Nov 1-3)
44 handoffs: project 41, branch 41, both 38. Project only (3): `handoff-switzerland-brief-2026-11-02.md`, `handoff-switzerland-decisions-2026-11-02.md`, `handoff-switzerland-waiting-results-2026-11-02.md`. Branch only (3): `handoff-open-items-b7-done-2026-11-01.md`, `-b8-`, `-b9-`. By date: Nov 1 16, Nov 2 18, Nov 3 10.
Ledger 177-279: 93 rows. Ids that do not exist: 181-184 (block 9 first run), 198-199, 210, 212, 239-240 (Swiss dry run) = 10.

## The 8 cards (Ben 1 A)
| # | Card | Handoffs | Ledger rows | Version |
|---|---|---|---|---|
| 1 | Open items blocks 7 (files 2-3), 8, 9, 10, Forum blurb (Nov 1) | b7, b8, b9, b10, forum-blurb (5) | 16 (177-196) | v1.34 |
| 2 | Michelin 2026 Hong Kong & Macau (Nov 1) | hong-kong-macau-loaded, hkmo-renamed, -native, -price, -register, -2025-backfill (6) | 12 (197-211) | v1.34 |
| 3 | Michelin 2025 history backfill, 6 guides (Nov 1-2) | tw, gbi, fr, es, jp, it 2025-backfill (6) | 6 (213-218) | v1.34 |
| 4 | Italy 2026 fixes, small open items, RLS, list compare (Nov 2) | it-2026-fixes, it-2026-status, it-status-names, open-items-a1-d1, -g1-h1, -rls-names-fr-closures, es-list-compare (7) | 16 (219-234) | v1.34 |
| 5 | Closed-venue rule and closed sweep (Nov 2) | closed-rule, closed-sweep-201, -twins-renames, -item6, -item7, -item3 (6) | 4 (235-238) | v1.35 |
| 6 | Michelin 2026 Switzerland & Liechtenstein (Nov 2-3) | switzerland-waiting-results (P), -brief (P), -decisions (P), -status, -renamed, -price-backfill-cleanup, -open-items (7) | 9 (241-249) | v1.35 |
| 7 | Small open items: Malfa and Signum, Tailor and place IDs, A2-A3-D (Nov 3) | malfa-signum, placeid-tailory, a2-a3-d (3) | 16 (250-265) | v1.35 |
| 8 | OAD 2026 start (Nov 3) | oad-2026-first-write, -no-live-venue-ready, -no-live-venue-done, -read-block (4) | 14 (266-279) | v1.35 |

Totals: 44 handoffs, 93 ledger rows. Non-handoff sources for build 2: `claude/michelin-2026-switzerland-log.md`, `claude/cowork-michelin-2026-switzerland.md`, `claude/ch-2026-list-pages-read-2026-11-02.txt`, `claude/trusted-websites.md`, and the run folders on the branch (`docs/closed-rule-2026-11-02/`, `docs/closed-sweep-2026-11-02/`, `docs/ch-2026-build/`, `docs/open-items-*-2026-11-03*`).

## Done
No database write. No change to the live site.

**Plan v1.34 built, checked, saved.**
- Build: `build134a.py` (sandbox only). Base sha256 asserted. Anchored `replace` calls, each asserted to match once. 175 lines added, 4 lines changed.
- 4 new cards after the part 1 card "Name differences and open items blocks 1-7", before the Phase 2 record card (cards 1-4 above). Card 4 holds the Write-connector note for Nov 1-2, the ledger 177-234 table (50 rows, built by script from the live rows, not typed) and the counts after ledger 234 (Nov 2, 17:36 UTC, from `handoff-es-list-compare-done-2026-11-02.md`).
- Status boxes: price work item (ledger 207, 220; price 7,728 after ledger 234), history-backfill work item (7 guides, 1,707 new rows, 64 URL fills; Ben started the 2025 edition before launch on Nov 1).
- Header (Version, Author, Status, Responds to). Version-history row 1.34.

**Checks** (population: the 175 added and 4 changed lines):
- HTML: `html5lib` 2 errors, the same 2 as v1.33 (line 7, the font link). 0 tag mismatches. 0 unclosed tags.
- Number trace (`trace.py`): 276 numbers and 32 ids and paths. 9 not found: 5 path artifacts (`</code>` tail), "280" (header range), 3 sums (1,535, 1,598, 1,707), checked by the agent.
- Independent read-only agent, about 210 statements, about 229k tokens: 4 problems and 14 borderline points, all fixed before the save:
  1. Rollback line named an undo-job behavior with no source. Now names the undo job only.
  2. Cancel time "about 0.5 s" -> "0.5-0.8 s" for the 3 named files (A1-D1 0.7-0.8 s, G1-H1 0.6-0.8 s, Plaza Athénée 0.5 s).
  3. Backfill method: Japan used region selection pages, not a list article. Card-link maps only for GB&I, France, Spain.
  4. "Open at the end of Nov 2" -> "Open on Nov 2 at 12:37 ET (end of the list-compare block)".
  5. Borderline: open decisions named on cards 1 and 2 (Le Calandre and Palaash cities, Forum `importOptionB` run, Mentor Chef name form, Chiu Chow Delicacies and Sol rechecks); price box count after ledger 234; scope wording (France, Spain, Italy stars only; Japan complete sets only); Model lines add WebFetch and Claude in Chrome; GB&I 221 wording; block 7 E4 A1 timing; RLS rollback has no source SQL, removed.
- Wording: 0 should/could/would/might forms ("May" = month). 0 prose semicolons.

**Save** (Ben "Go", Nov 7 07:34 ET):
- Commit `4c0fab8` on `oad-2026-read-block` (Nov 7, 07:34 -0500), 1 file.
- Fresh clone of the branch: sha256 `ab5b627f85b1ca304b7b7c39a12101bf9ee3816a4f4d7a7b480a2951114e5f12`, 349,979 bytes, Version 1.34.
- Project copy over the same name (`CompassEats-Rearchitecture-Plan.html`): read back as `local_file`, sha256 equal, Version 1.34.
- `main` still holds v1.32. Merge only when Ben asks.

## Methods (new)
- **Ledger rows to a file, UTF-8:** the saved tool-result text is JSON with escaped quotes. Cut from `[{\"pad` to the last `}]`, then `.encode('utf-8').decode('unicode_escape').encode('latin-1').decode('utf-8')`, then `json.loads`. Without the latin-1 round trip, names come out as mojibake (`LoÃ¯s`).
- **Ledger table by script:** group consecutive ids by the job key (text before the first ` | `), write `<tr>` rows to `ledger_rows.html`, and insert that file in the build script. No retyped ids.
- **Card placement:** anchor = `  <div class="card">\n    <h3>Phase 2 record — publish job designed`. Insert build 2 cards at the same anchor (after card 4).
- **Version-history anchor for v1.35:** the end of the 1.34 row, text `Part 2 cards 5–8 (Nov 2–3, ledger 235–279) and part 3 (Nov 4–6, ledger 280–376) are not in this version.</td></tr>`.
- **Header anchor for v1.35:** status text `part 2 cards 1–4 (Nov 1–2, ledger 177–234) recorded in v1.34, part 2 cards 5–8 (Nov 2–3, ledger 235–279) and part 3 (Nov 4–6, ledger 280–376) not yet in this plan`.
- **Status boxes:** v1.34 boxes start `<b>Status, Nov 1–2 (v1.34).</b>`. For build 2 add new boxes after them (Swiss price ledger 245, Signum price 252; Swiss 2025 backfill 246, 2025 card URLs 249).

## Dead ends: do not retry
- `unicode_escape` alone on the ledger result (gives mojibake). Use the latin-1 round trip above.
- Generic claims in a card's method paragraph ("a list capture for each guide"): the agent found exceptions. Name the guide when the method differs.

## Build 2 notes
- 3 Swiss project-only handoffs are not on the branch. For the trace and the agent, copy them into the sources folder: `project_read` returns small docs inline (no `local_file`), so give the agent the Projects tool for those 3 paths only, or check them by hand.
- Card 4 "Open" line points to card 5 (open item 10, closed-venue rule) and card 6 (Switzerland). Keep these names.
- Swiss facts already read: batch 20 promoted Nov 2 (ledger 241-242), cleanup ledger 243, cities file audit 124,372-124,389, ledger 239-240 and audit 124,390-124,704 used by the rolled-back dry run; Green Star dropped by Ben (Nov 2 17:59, Michelin press release May 18, 2026); 30 new venues; CHF on all 225 price rows.
- Agent cost estimate: about 230k tokens for 175 lines.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/CompassEats-Rearchitecture-Plan.html` **v1.34** | Final. On `oad-2026-read-block` (`4c0fab8`) and in the project (same name). `main` holds v1.32 | `ab5b627f85b1ca304b7b7c39a12101bf9ee3816a4f4d7a7b480a2951114e5f12` |
| `build134a.py`, `check_html.py`, `trace.py`, `filt.py`, `ledger177_234.txt` | Sandbox only, not in the repo. The file checksum is the record | - |

## Open items, in order
1. **Gault & Millau France and Monaco 2027 from Nov 10** (opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`). Then Michelin Thailand 2027.
2. **Plan v1.35 (part 2 cards 5-8, Nov 2-3, ledger 235-279)**, then v1.36 (part 3, Nov 4-6, ledger 280-376).
3. Merge `oad-2026-read-block` to `main` when Ben asks.
4. All other items as in the v1.32 card "Move goals and order of work".

## Suggested opening prompt: Plan v1.35 (if Ben wants it before Nov 10)
```
Read claude/handoff-plan-v134-done-2026-11-07.md from the project files for the plan state and the build 2 card list, then
claude/handoff-plan-v133-done-2026-11-07.md and claude/handoff-plan-v131-done-2026-11-06.md for the plan-edit method, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
If today is Nov 10 or later, tell me first that Gault & Millau France and Monaco 2027 is due, and ask which comes first.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Read the Version line of docs/CompassEats-Rearchitecture-Plan.html on branch
oad-2026-read-block (expect 1.34, sha256 ab5b627f…5f12) and on main (1.32 unless I merged). Build from the 1.34 file.
Build Plan v1.35, part 2 cards 5-8 (Nov 2-3, ledger 235-279), as listed in the handoff. Build it, check it, and present it before you commit.
Keep handoffs on branch oad-2026-read-block.
```

For Gault & Millau from Nov 10, use the opening prompt in `handoff-michelin-d-dk-vn-done-2026-11-06.md`.
