# Handoff: CompassEats, Sep 15, 2026 (night). 2025 label ruled, legacy rows retired, France and Italy twins merged. Spain & Andorra is in Cowork.

This handoff is for a fresh execution chat. Ben is not a developer, and he often uses a phone. This chat:
- runs reads through Supabase Read and gated writes through Supabase Write;
- writes Cowork briefs, decisions files and pairing files;
- keeps the plan current.

Fable gives rulings.

This file replaces `handoff-michelin-japan-done-2026-09-15.md` for live state and open items. The rules in the earlier handoffs still apply: naming rulings 1 to 4, the five buttons, the city-insert SQL pattern, the Michelin page-reading method, and the match test.

## How Ben works with this chat
- Write in plain language, in `/ste` style for data replies: short sentences, no contractions, one step at a time.
- Every count states its population and its grouping key.
- Each write batch needs one "go" from Ben. State the expected counts before the write. After the commit, read the counts back with a Read query.
- Under-merge beats over-merge.
- Competitor sites are never a source: joinpearl.co, thebestrestaurantsguide.com, beliapp.com, and enprimeurclub.com (which calls itself Pearl's app). Every claim needs a URL.
- Never hand-retype a data file. Ben uploads files with GitHub **Add file → Upload files**. To examine a repo file, read it from raw.githubusercontent.com. The repo reads without a login.
- Build a large pair list from the approved repo file with code, and put the file checksum inside the SQL.
- Ben answers each gate with one word or a short phrase: `staged`, `restaged`, `promoted`, `go <batch>`. Read the database at each gate.

## Live state (read back after the Italy merge)
Population: whole table.

| Table | Count |
|---|---|
| venues | **11,034** (active 10,666) |
| awards | **21,964** |
| Michelin 2025 rows | 4,999 |
| Michelin 2026 rows | 3,216 |
| listings | 11,034 |
| slugs | 11,847 (813 non-canonical) |
| city_label_source | 23,464 |
| price | 7,091 |
| source_capture_ledger | 24 |
| ingest_batches | 4, all promoted (ids 1, 3, 4, 5) |

## What happened today

### The ruling
The ruling is in `docs/fable-ruling-michelin-2025-label-2026-09-15.md`. The legacy Michelin "2025" rows are one website snapshot, taken between May 13 and June 1, 2026. The rules:
- When a legacy row and a sourced row are on the same venue, the sourced row wins. The legacy row is deleted in a gated batch per guide, with a ledger row `retire:<batch_key>`.
- Relabel a guide only after a three-promotion test.
- Never relabel a venue that has one of the 928 older 2026 rows.

### Retire batches
| Batch | Deleted | Ledger id |
|---|---|---|
| jp | 567 | 23 |
| fr | 697 | 24 |
| it | 310 | 25 |
| mismatch | 6 | 26 |

The six mismatch rows, by award id:
- 865 L'Ambroisie
- 1233 Kohaku
- 5237 Maison Tiegezh
- 5244 Briketenia
- 7723 Villa Salone
- 6420 La Pineta

### Twin merges
- **France:** `reports/michelin-2026-france-pairing.csv` has 260 merges. One of them is `merge-keep-twin`: La Voile is the survivor, and La Réserve Ramatuelle is the twin.
- **Italy:** `reports/michelin-2026-italy-pairing.csv` has 296 merges.
- **Design:** `docs/merge-design-michelin-twins-2026-09-15.md`.
- **Batches:** `merge-michelin-twins-fr` (ledger 27) and `merge-michelin-twins-it` (ledger 28).

What the merge did:
- The twin's slugs stayed as non-canonical URLs on the survivor.
- The city-label moves have hand-written `audit_log` rows (1,112), because that table has no audit trigger.
- 12 venues were set back to active.
- Il Falconiere moved to Cortona, and `cortona/il-falconiere` is now its canonical URL.
- Award 8447 (the old La Torre Bib row) was deleted.

**CAUTION:** `UNDO michelin-2026-france` and `UNDO michelin-2026-italy` now refuse. Recovery is through `audit_log`.

### Legacy 2025 rows left
France 20, Italy 4, Japan 11. All of them are on venues with no 2026 twin.

### Correction
An earlier note said that the ruling counted 89 Italy name pairs. That was wrong. The ruling counts 256.

## Spain & Andorra (in Cowork now)
The brief is `cowork-michelin-2026-spain.md`. Batch key: `michelin-2026-spain`. Andorra rows have `country_label` Andorra. The published total is 511 rows (16 / 37 / 254 / 204). The log includes a town list.

When Ben sends the two files and types `delivered`:
1. Read the log. Examine the counts for each country and category against 511, the excluded cards, and the special awards.
2. From the town list, find the towns with no `cities` row. Write the city inserts as gated SQL (use the Italy pattern). Get Ben's "go".
3. **Match test before the stage step** (see the Japan handoff method). Two rule changes from the ruling:
   - Pull the venue's **latest** Michelin category from the legacy rows. Do not use the words "2025 category".
   - The 27 rows that are missing from the snapshot, and Ramón Freixa Atelier, arrive as `new_venue`. **Do not pair them.**
   - Spanish articles and prefixes ("Casa", "El", "Restaurante") need the same-city, same-category pairing step.
   - Expect real town names on the Michelin rows, while the legacy rows use the nearest big city. So also look across towns, as in the Italy Il Falconiere case.
4. Ben uploads the CSV and the decisions file, then stages and promotes. Read the database at each gate.
5. **Retire batch for ES and AD** after the promote. Use the 4.0 read and then the same-category delete, as in batches 4.1 to 4.3. The ruling expects about 480 rows. Then read the rows where the category differs, and handle each one by id.
6. Check the special awards on Michelin's site. Hold them for the special-awards batch.

## Open items, in order
1. Spain & Andorra (above).
2. **Monaco batch** `michelin-2026-monaco`. Monaco has 8 legacy rows and 0 for 2026. The site count is 1 / 3 / 5 / 0. Confirm the order of the categories in the brief.
3. The remaining guides, each with a promote and then a retire batch.
4. **Rename CSV for France and Italy.** Source: the `twin_name_michelin` column of the two pairing files (555 survivors). Take out the rows where the old name is already correct. Also add:
   - the Japan wrong names (earlier handoff);
   - Le Calandre, Padua (its name has a Cyrillic "е").
5. **Slug decisions** after the rename:
   - `padua/le-calandr`
   - `ragusa/duomo-di-milano`
   - `paris/paris-wr4tla`
   - the street-address slugs (Via Fracia, Via Magnagallo Est, Via Giulio Cesare Procaccini)
6. **Special-awards batch** after the last guide. Fix the vocabulary first. Include Maxi, LOUISE Osaka (full-path URL), the Japan Green Star counts, and the Spain awards.
7. **Publish builder:** add two invariants:
   - no venue has two Michelin rows with the same year and category;
   - no venue mixes a sourced row and an unsourced row in the same year.
   The builder must also handle the bare new venues honestly (no geo, photo or blurb).
8. **`cities.venues_count`:** 717 cities disagree with their venue count. San Martino now has 0 venues. This belongs to the refresh job.
9. **Repo visibility:** the repo reads without a login, but D8 says that it is private. Ben has not answered yet.
10. Other items from the earlier handoffs:
    - Sukiyabashi Jiro split.
    - The Japan `name_native` backfill.
    - The Japan junk rows ("Tokyo", "Shinjuku City", "Tokyo Ramen Street", "Dialog in the Dark Japan", "Daimaru Shinsaibashi").
    - The 3-venue ingest CSV.
    - Salvatore at Playboy W50B.
    - Delete stale branches.
11. **Plan v1.22** is written. It records all of today's work. Ben must upload it to `docs/` and to Project Knowledge.

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-cleanup-done-2026-09-15.md). The Spain & Andorra Cowork task is done: I attached michelin-2026-spain.csv and michelin-2026-spain-log.md. Confirm live counts with a Read query, check the log, then give me the city inserts and the match-test decisions file, with step-by-step directions in /ste style.
```
