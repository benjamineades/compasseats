# Handoff: Michelin special awards (block B) done, files in the repo (Oct 29, 2026). Next: block A, price from the Michelin card.

This file replaces `handoff-special-awards-sql-ready-2026-10-29.md` for live state and next steps. The working rules, database
notes, methods and dead ends in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` still apply, with the change below.

## New standing rule (Ben, Oct 29 23:44 ET)
- **Claude commits the recommended files to the repo itself.** Do not give Ben upload click steps any more.
  Method: attach the repo (`add_repo`, push access), `git clone --depth 1`, copy the files into the folder the handoff
  names (usually `docs/`), check each sha256 against the expected value, commit to `main`, push, then fresh clone and
  check the sha256 again. A file goes into the commit only if its hash matches.
- Handoff files go to the project (`claude/`) **and** to the repo `docs/`.
- This replaces the old rule "Ben uploads chat files to the repo (give click steps)". All other working rules stay:
  one "go" per write batch, read-back after each commit, read the database at each gate, under-merge over over-merge,
  no competitor sources, /ste replies with populations on every count.

## Live state (read Oct 29, 23:45 ET, whole tables)
| Table | Count |
|---|---|
| awards (max id) | **23,352** (30,099) |
| Michelin awards | **9,648** |
| award_categories | **2,143** |
| venues | 11,307 (active 10,940) |
| slugs / cities | 12,842 / 3,263 |
| price | 7,024 |
| source_capture_ledger (max id) | **95** (**139**) |
| audit_log (max id) | **108,126** (**113,410**) |

## Done in this session
1. Start check: all counts matched the sql-ready handoff (awards 22,922, ledger 94 / 138, audit 107,678 / 112,962).
2. Dry run of `awards-michelin-2026-special-awards.sql` through the Read connector: all guards passed (legacy md5
   `eafc864b…`, 430 rows each match one venue, expanded rows md5 `55ccab86…`, venue match md5 `077b151a…` / 362
   venues, no duplicates, counts before). Stopped at the first INSERT with "read-only transaction" as expected.
3. Ben "go" (Oct 29 22:55). Same file through the Write connector, one transaction, all post-checks passed.
4. Read-back:
   - New award ids 29,670–30,099 (430): Mindful Voices 260, Green Star 113, Service Award 17, Young Chef Award 12,
     Sommelier Award 11, Mentor Chef Award 10, Opening of the Year Award 5, Exceptional Cocktails Award 2.
   - 18 legacy rows: source_url on 18, person on 15, 0 "Outstanding Service Award" rows left (16471, 20954, 21161 now
     "Service Award").
   - New categories: Mentor Chef Award, Mindful Voices.
   - Ledger **139**: michelin, award, 430, job `special-awards:michelin-2026-special-awards | …`.
   - Audit **112,963–113,410** (448): 430 INSERT + 18 UPDATE.
   - Samples checked: 29670 Miscellanea Spirit House (Allison Bowen), 29672 Crony Green Star, 29787 Pierre Gagnaire
     Mentor Chef, 29824 Bacchanalia Mindful Voices (Anne Quatrano), 30099 Sushi An Young Chef (Liu An HSU).
5. Repo commit `ff223ad` (Oct 29 23:37 ET) on `main`, checked by a fresh clone:

| File | sha256 |
|---|---|
| `docs/awards-michelin-2026-special-awards.sql` | `30459cea957cd9175a1d7be1ff80876e0859f0be4d1f36cec06d1e0d517737a6` |
| `docs/michelin-2026-special-awards.csv` | `09cf8dc4b7bfb04bd90077f96f694a5275a7b2eabf9abf9bbee9b21d0d3e5665` |
| `docs/special-awards-relay-2026-10-29.txt` | `fe17ce67eb78250082bb4c89499f757f9b0bd217c2a54daf5d1bb9431b88243f` |

Not in the repo (project only, not on the recommended list): `special-awards-scripts-2026-10-29.txt`,
`special-awards-resolved-venues-2026-10-29.txt`.

## Methods learned this session
- **The Write (file) tool turns `\uXXXX` text into real characters.** A file that must keep JSON escapes (the SQL plan
  text, the relay) changes size and hash. Fix: after the write, run
  `python3 -I -c "… ''.join(c if ord(c)<128 else '\\u%04x'%ord(c) for c in t) …"` on the file, then check the
  sha256. Files that hold real UTF-8 (the CSV) need no fix. `\"`, `\n`, `\.` inside the text are not changed.
- Relay file: no newline at the end (554 newline characters, 555 lines). The CSV and SQL end with a newline.
- `project_read` returns these files inline (up to about 170 KB), so a copy from the project plus a sha256 check is
  the way to move a project file to the repo.
- `price` columns: venue_id, tier, symbol_raw, currency, source, method, publisher, source_url, captured_at,
  confidence (no `price_source` column; the source is in `source`).

## Items to remember (from block B)
- 5 new rows sit on venues with status `closed`: Rolland (Green Star, Mindful Voices), La Galinette, La Tana Gourmet,
  Ursus. Kept: the award is history.
- Merge candidate: La Table – Christophe Hay (`ve_dd6de25c33`, has the Mindful Voices row) and La Table de Christophe
  Hay et Lois Bee (`ve_3e461fe576`, has the Green Star). Same restaurant, two records.
- 7 legacy rows stay unproven: Kinjo, The Daytrader, Fat Beet, Kaya, Krus Kitchen, Lamai Garden, Nen.
- 59 skipped rows (venue not in the database) are in the CSV with `how = skip`.

## Next block: A, price from the Michelin card
Reference read (Oct 29 23:46 ET), for orientation only. Ben picks the method and the population definition first.
- `price` by source (whole table, 7,024 rows): legacy_guide + michelin 5,385 (0 with source_url); legacy_guide, no
  publisher 1,625; guide_ingest + michelin 10 (10 with source_url); legacy_guide la-liste / gault-millau / oad /
  wine-spectator 1 each.
- Venues with a Michelin star or Bib award and **no** price row: 714 (active 711). Population: distinct venue_id in
  `awards` where source_id = 'michelin' and category in One Star, Two Stars, Three Stars, Bib Gourmand.
- The Oct 4 handoff counted "3,739 venues" for this item before several cleanups. That number is stale. Define the
  population again with Ben (for example: Michelin venues with no price, or Michelin venues whose price has no
  source_url) and read it fresh.

## Next steps (new session)
1. Fresh read of the counts above. If anything moved, stop and tell Ben.
2. Block A: show Ben the population options with fresh counts, ask for the method (Michelin card read in the built-in
   browser, or Cowork batch). Build the file first, examine it read-only, then ask for "go".
3. After each write: read-back, then commit the files to the repo `docs/` yourself (rule above) and report the sha256.

## Carried open items
Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7); telleruide slug;
apostrophe policy; Nadair (Atlanta) possibly closed (Rough Draft), status item; Florida 2026 Green Stars article not
found; La Table – Christophe Hay merge candidate (above).

## Suggested opening prompt
```
Read claude/handoff-special-awards-done-2026-10-29.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
ledger 139 and audit_log 113,410. Then start block A, price from the Michelin card: show me the population options
with fresh counts and the method options in /ste style. No write before my go.
```
