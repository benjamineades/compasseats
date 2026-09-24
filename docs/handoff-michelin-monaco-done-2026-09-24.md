# Handoff: CompassEats, Sep 24, 2026. Monaco promoted and cleaned. Next: the remaining guides.

This file replaces `handoff-michelin-spain-done-2026-09-16.md` for live state and open items. All the working rules in that file still apply: plain `/ste` replies, populations on every count, one "go" per write batch, read-back after each commit, under-merge over over-merge, no competitor sources, and no hand-retyped files. Plan v1.24 has the full record up to Spain. The Monaco record is not in the plan yet (open item 1).

## Live state (read back after `retire-michelin-legacy-mc`)
Population: whole table.

| Table | Count |
|---|---|
| venues | 11,041 (active 10,678) |
| awards | 21,978 |
| Michelin 2025 rows | 4,511 |
| Michelin 2026 rows | 3,718 |
| listings | 11,041 |
| slugs | 11,854 |
| cities | 3,241 |
| city_label_source | 23,478 |
| price | 7,090 |
| source_capture_ledger | 29 (last id 36) |
| ingest_batches | 6, all promoted |

Legacy Michelin 2025 rows left on the cleaned guides: France 20, Italy 4, Japan 11, Spain 6, Monaco 0.

## Monaco: done
- **Capture:** 9 rows. Three Stars 1, Two Stars 3, One Star 5, Bib 0. Each category equals the site banner. Both SHA-256 values were identical. No card was held out.
- **Country slug on Michelin:** `principality-of-monaco`. The slug `monaco` returns the empty-result page. The destination box has no Monaco country row. Cowork confirmed the slug from Michelin's own country map (`"mc":{"cname":"principality-of-monaco"}`).
- **City:** all 9 rows print `Monaco`. They resolve to `ci_77f09e1229`. No new city.
- **Hold register:** no Green Star in Monaco (Cowork scanned all 16 venue pages for `data-green-star="true"`). No special award in Monaco. Marco Tognon (manager, Les Ambassadeurs) got a mention in the Service Award section. It is not one of the 4 awards.
- **Match test:** the prediction and the first stage were both 8 match / 1 new / 0 review. The decisions file has 1 row: line 5 → `use:ve_abd09cb984`. Restage: 9 / 0 / 0.
- **Promote:** batch id 7, ledger id 35. First a dry run (all 11 invariants passed, rolled back), then the real run.
- **Retire `retire-michelin-legacy-mc`:** ledger id 36. 8 same-category rows (award ids 679, 2544, 2545, 6573, 6574, 6575, 6576, 6577). 0 mismatches, 0 misfiles, 0 status fixes.

## Decisions (and why)
- **Line 5 paired with `ve_abd09cb984`** ("R - La Table d'Antonio Salvatore"). Same city, same 2025 category (One Star), the only free One Star venue after 4 exact matches, unique in both directions.
- **The third Two Star is a database gap, not a Michelin change.** Blue Bay Marcel Ravin (`ve_5f2aaf2e90`) matched exactly, but it has no Michelin 2025 row. The press release names no new Two Star in Monaco for 2026. Do not add the 2025 row now. It goes to the history backfill.
- **Model for small captures:** Opus in Cowork is enough when the capture is small and the brief gives every selector. Judgment work (match test, pairs, names) stays in chat.

## Method notes carried forward
- **All Spain method notes still apply** (pre-stage simulation, pairing, decisions checks before the restage, one gated cleanup batch per guide).
- **Cross-country misfile check:** search the whole `venues` table on each CSV name key and on name fragments. Use the Monaco query as the model.
- **The promote button has a Dry run box.** It starts unticked. A dry run writes the report file `reports/<key>-promote.md` with "Dry run – rolled back" and takes one ledger id (id 34 is missing for this reason).
- **Audit triggers:** `awards`, `venues` and `cities` have `audit_row()` triggers. Do not write audit rows by hand for them. `city_label_source` and `source_capture_ledger` have no trigger.
- **Schema facts found this session:**
  - `venues` has no country column. Country is on `cities` (`country`, `country_iso`). Join through `venues.city_id`.
  - `cities` has no `city_aliases` column. Find where aliases live before the next simulation.
  - `audit_log` columns: `id, table_name, row_pk, action, old_row, new_row, at`.
  - `information_schema.triggers` shows nothing through the Read connector. Use `pg_trigger`.
- **Cleanup batch shape that worked:** one `DO $$ … $$` block. It deletes by id, checks `ROW_COUNT`, raises an exception if the count is wrong, and inserts one ledger row with job `retire:<batch key>`.

## Artifacts
- `fixtures/ingest/michelin-2026-monaco.csv`: in the repo, final.
- `reports/michelin-2026-monaco-decisions.csv`: in the repo, final.
- `reports/michelin-2026-monaco-stage.md` and `reports/michelin-2026-monaco-promote.md`: in the repo, written by the buttons.
- `cowork-michelin-2026-monaco.md` (brief) and `michelin-2026-monaco-log.md` (log): chat files, not in the repo. Use the brief as the model for small guides. Change the slug line to the real slug.

## Open items, in order
1. **Plan v1.25:** record the Monaco batch in the Re-Architecture Plan. Ben re-saves it to `docs/` and Project Knowledge.
2. **Remaining guides,** each with a promote and then a cleanup batch. Put the cross-country misfile check in each match test. This handoff does not name the next guide. Take it from the plan's gap list.
3. **Michelin history backfill** (plan v1.24 work item). **Do not start it yet.**
   - Target back to **2018**. Fallback: 5 editions (2021–2025).
   - The pilot runs only after the migration is complete and the site is live.
   - **New item:** Blue Bay Marcel Ravin (`ve_5f2aaf2e90`), Two Stars before 2026, no 2025 row.
4. **Rename CSV:** the items from the Spain handoff, plus `ve_abd09cb984`: "R - La Table d'Antonio Salvatore" → "La Table d'Antonio Salvatore au Rampoldi" (Michelin card name).
5. **Slug decisions:** `padua/le-calandr`, `ragusa/duomo-di-milano`, `paris/paris-wr4tla`, and the street-address slugs.
6. **Special-awards batch:** fix the vocabulary first. The list is the same as in the Spain handoff. Monaco adds nothing.
7. **Cleanup:** Elche and Elx city merge; the OAD 2025 #30 row on L'Hostal de Ca l'Enric; `cities.venues_count` refresh (Monaco shows 11, San Martino 0); Sukiyabashi Jiro split; Japan `name_native` backfill and junk rows.
8. **Publish builder:** the two Michelin invariants, honest states for bare new venues, and history display.
9. **Security:** restrict the Google Maps and MapTiler browser keys in the public repo `.env` to the site domain. The repo visibility question (D8) is still open.

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-monaco-done-2026-09-24.md). Confirm live counts with a Read query. Then record the Monaco batch in the plan as v1.25, name the next Michelin guide from the gap list with its 2025 and 2026 row counts, and write its Cowork brief modeled on the Monaco brief, with step-by-step directions in /ste style.
```
