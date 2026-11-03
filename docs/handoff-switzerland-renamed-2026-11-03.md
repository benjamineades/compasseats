# Handoff: Swiss rename batch 46 (94 venues) and slugs done. Items 1 and 4 closed. Nov 3, 2026 (16:30 Atlanta). Next: Swiss open items.

This file replaces `handoff-switzerland-status-done-2026-11-02.md` for the Swiss live state and open items. That file still holds the status file, the Ô Bois Sauvage read and the recheck dates. `handoff-switzerland-decisions-2026-11-02.md` still holds decisions 1-10, the 30 new venues and the 2025 rows kept as history. **Decision 5 is replaced (below).** Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET)
- Nov 2 23:04 "1&4". 23:25 "A": no more site reads; venues with no site name count as not read, rule R5.
- Nov 3 16:17 "1A, 2A, 3A, 4A, 5A, 6A, 7A":
  1A Soleil d'Or `ve_157d527091` = "Soleil d’Or by Benjamin Geisser" (replaces decision 5, which said David).
  2A the 12 rooms take card names (Balm-Bistro takes the site spelling).
  3A Restaurant Sonne Scheunenberg `ve_1ff8df1642` held.
  4A the 11 site names accepted. 5A the 12 keeps accepted. 6A all 94 in one batch. 7A both Aubonne slugs in this batch.
- 16:18 "go" (rename). 16:25 "go" (slugs).

## Live state (read Nov 3, 21:26:38 UTC, whole tables)
Venues **11,323** (active **11,031**, closed **292**). Awards **25,321**. Slugs **13,144** (canonical 11,323, non-canonical **1,821**). Price 7,727. Listings 11,323. city_label_source 24,049. Cities 3,279, `cities.venues_count` sum **11,031**. rename_batches **31** (last id **46**), rename_rows **1,396**. Ledger **190** rows, last id **244**. audit_log **119,511** rows, last id **125,340**. Closed published 0. Venues with other than 1 canonical slug 0.

## Done
| Write | File (sha256) | Audit | Result |
|---|---|---|---|
| Rename | `docs/rename-michelin-2026-switzerland.sql` (`ad9b69b2...6cda`) | 125,065-125,158 | Batch 46, 94 venues; michelin 81, venue 13; ledger 244 (michelin, name, 81) |
| Slugs | `docs/slugs-rename-michelin-2026-switzerland.sql` (`355135db...8f6d`) | 125,159-125,340 | 91 new canonical slugs (includes Njørd café, slug only); 4 keep; no ledger row |

Write connector, first try, both files. Evidence `docs/ch-2026-build/name-diff-evidence-ch-2026-11-02.csv` (`cde8b48e...c32a`). Fixture `fixtures/rename/michelin-2026-switzerland.csv`. Build `docs/ch-2026-build/build_evidence_ch_2026_11_02.py`, `build_rename_ch_2026_11_02.py`. Card read `docs/ch-2026-build/cards107-2026-11-02.tsv`. Run records `docs/ch-2026-build/run-rename-ch-2026-11-03.txt`, `run-slugs-ch-2026-11-03.txt`.

Population: 225 cards, 107 name differences: rename 94, keep 12, hold 1.
Keeps: Restaurant de l'Hôtel de Ville de Crissier, Pic au Beau-Rivage Palace, La Chaumière, Wirtschaft im Franz, Restaurant des Trois Tours, du Cerf, SHIN, Zum alten Stephan, Salzano, Restaurant zum Pflugstein, Restaurant Pinot, Suahoy.

## Limits and name notes
- Site reads are short reports from the fetch tool, not exact text.
- 17 renames use R5: not read, or the page does not name the room. Ben rejected the `netts.ch` prompt; 4 prompts timed out (Freilager, Aldier, Bären Grub, Eintracht).
- 13 renamed venues also have an award from another publisher (la-liste, best-chef-awards, OAD). The database does not store the name those publishers print.
- "Oz" has fewer than 3 letters, so `norm_key` is NULL (78 venues before this batch).
- Magdalena `ve_1489b03a45` stays in city Rickenbach; its card says Schwyz. Not changed.
- Curly and straight apostrophes: part of the open apostrophe policy.
- Generic names now live: "Auberge Communale" (Saint-Légier), "Asia", "Ecco", "Bären". Each is unique in its city.

## Recheck list (added)
| Venue | Id | Recheck |
|---|---|---|
| Restaurant Sonne Scheunenberg | `ve_1ff8df1642` | Ben opens the site (card "Sonne"; site body "Mösching’s Sonne") |

Older dates stay: Ling Ling after Nov 5, 2026; Colani Bistrot Nov 27; After Seven Dec 2; Scalottas Terroir Dec 9; Ô Bois Sauvage and The Grill at Amangani Jan 2027. No scheduled task holds these dates.

## Open items (Swiss)
1. Card price file in CHF (decision 4). The legacy prices on After Seven and Colani Bistrot are not changed yet.
2. Cleanup list (decision 2): `ve_d159e1bbd3`, `ve_7c75b49d07`, `ve_7d4e3b91ec`.
3. 2025 backfill: La Croix d'Or Ballaigues, Bären Schwarzenburg, Bären Utzenstorf, Restaurant LA Basel.
4. Worldwide alias check (262 aliases; Swiss suspects: `grisons`, `sankt niklausen`, `silvaplana`, `lens`, `sorengo`).
5. New: slugs with letters removed outside Switzerland, for example `s-ller-d-kro`, `b-st`, `r-st`, `restaurant-frederiksh-j`. Not counted. Ben decides if and when.

## Methods (new)
- **WebFetch shows old Michelin cards.** It returned 2025 guide pages (Soleil d'Or h1 "by Benjamin"; live 2026 h1 "by David"). Use the built-in browser `fetch()` loop for card names and website links.
- **Built-in browser can appear late.** Its tools can arrive after the session link. Check again before using another route.
- **Two slug rules exist.** `f_unaccent` gives `njord-cafe`; the importer `slugify` in `scripts/ingest/lib/slug.ts` removes ø and gives `nj-rd-cafe`.
- **Slug file with an extra venue:** plan = batch venues OR the named venue id, so a slug-only row needs no rename row.
- **Do not end a shell command with a bare `cat`:** it waits for input until the timeout.
- **Stop hook in a shallow clone:** the single-branch clone has no remote-tracking ref. Set `branch.<name>.remote` and `.merge`, and fetch with `+refs/heads/<b>:refs/remotes/origin/<b>`.

## Suggested opening prompt
```
Read claude/handoff-switzerland-renamed-2026-11-03.md from the project files, then
claude/handoff-switzerland-decisions-2026-11-02.md for the decisions, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 244,
audit_log 125,340, venues 11,323 (active 11,031, closed 292), awards 25,321, slugs 13,144, price 7,727, closed published 0 and cities.venues_count sum 11,031.
Then start the Swiss open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
