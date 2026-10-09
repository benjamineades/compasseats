# Handoff: CompassEats, Oct 9, 2026 (early morning). Germany rename sets 2 and 3 done (batches 15 and 16, 59 venues). Next: their slug file.

This file replaces `claude/handoff-germany-renamed-set1-2026-10-08.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-germany-renamed-set1-2026-10-08.md`: set 1 record (batch 12, ledger 94, audit 108,284–108,498), set 1 slug file (audit 108,499–108,872), the slug method and the two A decisions.
- `claude/handoff-germany-cleanup-done-2026-10-08.md`: the cleanup record (ledger 91–92, audit 108,051–108,068), Ben's Q1/Q2 precedent, the lists for Plan v1.30.
- `claude/handoff-germany-promoted-2026-10-08.md`: the promote record.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: Germany source facts.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- `claude/handoff-chengdu-renamed-reviewed-2026-09-28.md`, `handoff-plan-v129-done-2026-09-28.md`, `handoff-michelin-chengdu-2027-done-2026-09-28.md`: methods, dead ends, database notes.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.

## Live state
Population: whole table. Read Oct 9, 03:52 UTC (Oct 8, 23:52 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,223 (active 10,859, closed 364) |
| awards | 22,389 |
| Michelin 2025 / 2026 / 2027 rows | 3,791 / 4,804 / 47 |
| listings / slugs | 11,223 / 12,509 (canonical 11,223, non-canonical 1,286) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,850 |
| price | 7,048 (10 `guide_ingest`) |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **74** (last id **100**) |
| audit_log | **105,123** (last id **108,990**) |
| ingest_batches | 1, 3–13 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, **15, 16** applied (13, 14 = rolled-back dry runs). rename_rows **825** |
| Germany Michelin 2026 rows (DE city) | 484, 0 unsourced |

## Done in this session (Oct 8, 23:17 to Oct 9, 03:53 UTC)

**Start check:** all counts, ledger 94, audit 108,872, slugs 12,509, batch 12 applied matched. Repo fixture, set 1 CSV and set 1 slug file sha256 correct.

**Population read again (finding).** Join of the 483 sourced DE Michelin 2026 rows to the fixture by `source_url`, venues not in batch 12, name different from card: **65 venues** (= handoff 15 + 50). Alois `ve_4ea2da3ad7` has a spaced dash AND other publishers; counted in set 3. All 65 `active`. NOTE: the set-1 handoff "line" numbers are fixture data-row numbers (header = row 0).

**Sources read (built-in browser pane, Oct 9):**
- Michelin venue pages (16, in-page fetch): name, "Visit Website" link, description. The block after the description lists nearby hotels, NOT the venue's own hotel (do not use it as "Stay at the hotel" evidence).
- Venue sites for all set-2 rows and the set-3 ties (URLs are in each CSV note). `burg-aasen.de` (die burg) did not load ("denied or failed"; `request_access` said no approval needed).
- **La Liste:** `/sitemap.xml` from a laliste.com tab → 6,986 URLs, 117 English `/places/…-de` pages; fetched all, read `h1`, city, score. Browser sha256 of the 117-line TSV `499f1838…5203b5b4`. Two names used in the CSV (Haerlin; Victor's Fine Dining by Christian Bau, U+0027) checked by sha256 `13c053f5…a4166883`.
- **Best Chef:** `thebestchefawards.com/events-results/?id=2376` (Guide 2025, Milan) and `?id=1874` (Guide 2024). The page lists all knives; Germany entries read as `chef | restaurant | city` lines. Events list at `/events/`.
- **OAD:** `www.oadguides.com/lists/europe/top-restaurants/2026` in the browser (content loads after ~4 s; then `document.body.innerText`). All 10 DE venues found (for example "Table by Kevin Fehling, The", "Bidlabu").
- **World's 50 Best:** now at `the50.com/restaurants/best-in-the-world/list/1-50` and `/51-100` (current = 2025 list); old years at `/previous-list/<year>` (one page holds all years 2002–2024). Schwarzwaldstube printed "Die Schwarzaldstube" (sic) 2004–2010.
- **Gault&Millau: not readable.** `gaultmillau.de` and `gault-millau.de` fail in the pane; WebFetch returns ROBOTS_DISALLOWED. `gault-millau` IS in `award_sources`.

**Set 2 (14 renamed, batch 15, key `rename-michelin-2026-germany-dashes`).** File `fixtures/rename/michelin-2026-germany-dashes.csv`, 14 rows, LF, sha256 `c19a86d828de9d0c39866e16cfa849e3bdcc09ca388f0c0d5a98c7241f58f0c8`, all `source_id` michelin. Names = fixture card name, or card cut at the first spaced dash or pipe (substring, not retyped).
- Rules decide (4): Maerz → "Maerz - Das Restaurant" (own dash); Christians Restaurant - Christian F. Grainer → "Christian's Restaurant"; Brogsitter Gasthaus Sanct Peter → "Restaurant Brogsitter"; Tölzer Schießstätte am Buchberg - Michaela Hager → "Tölzer Schießstätte".
- Q2 A (6, whole card): Alte Schule - Klassenzimmer, Kulturhof Stanggass - Gasthaus, Hirsch & Jägerstüberl - Ostiner Stub'n, Gasthof Berghof - Ursprung, Am Kring - Büschker's Stuben, Lotters Wirtschaft - Tausendgüldenstube.
- Q3 A (4, cut): die burg, Eckert, ZweiSinn Meiers, Ente Wiesbaden.
- No change (1): Ammolite – House of Light `ve_28cc28bd85` (venue site prints the en dash; card differs only in the dash character).

**Set 3 (45 renamed, batch 16, key `rename-majority-2026-germany`).** File `fixtures/rename/majority-2026-germany.csv`, 45 rows, LF, sha256 `bea5624660f16566696dd6648ea0761ddcc5bfaf285df3dd8474a0f22e3ad2f0`. michelin 43, la-liste 2.
- La Liste wins (2): HAERLIN → Haerlin (2 of 3); Victor’s → Victor's Fine Dining by Christian Bau (3-way tie, venue site title; apostrophe only).
- Majority = Michelin (23), tie → venue site = Michelin (9: es:senz, Ösch Noir, sein, PUR, FACIL, Steinheuers Restaurant, Gotthardt's by Yannick Noack, ESPLANADE, Zur Wolfshöhle), Michelin only read because G&M does not vote (9: Kaisersaal, MiZAR, hallmann & klee, HAEBEL [live was "hæbel"], Koer, Petit Amour, Piment, Seven Swans, Sommerfeld), Q4 A (2: IKIGAI, BODENDORF'S).
- No change (5): The Table, August, Cœur D'Artichaut, Gästehaus Klaus Erfort, Bidlabu.
- Vote comparison: exact spelling; a publisher's hotel/chef suffix after a spaced dash is cut before the vote (La Liste "JAN - Jan Hartwig", "Bodendorf's - Landhaus Stricker"); only publishers with a row on the venue vote; tie (including 1-1-1) → the spelling the venue site prints; venue site mixed → Ben.

**Checks before the "go"** (read-only, one query, md5 guards s2 `f61f0d58…1c2709`, s3 `62210496…133ef5`): 0 missing, 0 name moved, 0 no-change, 0 closed, 0 earlier renames, keys free, 0 same-city `norm_key` collisions on the end state of both batches, 0 NULL `norm_key`. 3 blurbs (Haerlin, Schwarzwaldstube, es:senz; `needs_rewrite`, name not in the text). Fresh read after the choices: md5 of live `id|name` = file `venue_id|expected_name` `33a550f4…4031ca`.

**Runs (Ben).** Repo fresh clone: both CSVs in `fixtures/rename/` with the sha256 above. Dry runs: 14/14 and 45/45 rename, 0 reject, 0 review, 10 of 10 invariants each, "where else the name is stored": nothing (91 columns). Dry runs used batch 13–14, ledger 95–97, audit 108,873–108,931 (rolled back).
- Real run set 2: Oct 9 03:50:46 UTC, batch **15**, ledger **98** (michelin, name, 14, `rename-apply:rename-michelin-2026-germany-dashes`), audit **108,932–108,945** (14 venues UPDATE).
- Real run set 3: Oct 9 03:52:08 UTC, batch **16**, ledger **99** (la-liste, name, 2) and **100** (michelin, name, 43), job `rename-apply:rename-majority-2026-germany`, audit **108,946–108,990** (45 venues UPDATE).
- Read-back: live `venue_id|name` md5 `8991cf65…9104ec` = files' `new_name`; audit `row_pk|old|new` md5 `f26f9fab…bb322` = files; 0 audit rows change more than name/norm_key; 0 on other venues; venues/awards/slugs/blurbs counts unchanged.
- Real-run reports: the job commits `reports/rename-michelin-2026-germany-dashes-rename.md` and `reports/rename-majority-2026-germany-rename.md` (the dry-run versions were at commit `442e9e7`; NOT yet checked that the real-run versions replaced them; check at next start).

## Decisions by Ben (this session)
- Q1 **A**: Gault&Millau does not vote when its site cannot be read (applies to set 3; up to 18 rows could change if G&M is read later).
- Q2 **A**: a card that joins a house name and a restaurant name with a spaced dash keeps the whole card name (France "Maison Vidal - Le Bistrot de Justin" precedent).
- Q3 **A**: cut at the spaced dash or pipe for a descriptor ("fine dining", "| Fine Dining") and for a temporary location (Ente). First ruling on the pipe: treated like a dash suffix.
- Q4 **A**: case tie with a mixed venue site → Michelin spelling (IKIGAI, BODENDORF'S).

## Slug file for batches 15 and 16 (open item 1)
Population: the 59 renamed venues. Rule `trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g'))` (Ben's A). Read Oct 9: **48 need a new canonical slug** (batch 15: 14; batch 16: 34), **11 keep their slug**, 0 new slugs taken by another venue in the same city. Expected after the write: slugs 12,509 → 12,557, non-canonical 1,286 → 1,334, canonical 11,223. Check the two slug rules on the new names before the build (ß in "Tölzer Schießstätte"; "hallmann & klee", "es:senz", "Victor's", "BODENDORF'S" punctuation). Template: `docs/slugs-rename-michelin-2026-germany.sql` (148 lines); plan from `rename_rows` batches 15 and 16, filter `new_slug <> old_slug`, gate both counts (48 plan rows, 11 unchanged) and a plan fingerprint.

## Methods that worked (new)
- **Population from the database plus the fixture:** one Read query of all DE Michelin 2026 rows not in earlier rename batches (venue name, status, city, source_url, other-publisher rows as one string) lands in a tool-results file; a sandbox script joins it to the fixture by `source_url` and splits by separator and other publishers.
- **Votes by publisher in the browser:** La Liste sitemap loop (500 ms pause, 117 pages in about 2 minutes, stored on `window.__ll`); Best Chef results page lines; OAD list after a 4 s wait; 50 Best list pages. Read venue sites with `document.body.textContent` (not `innerText`, which applies CSS uppercase) plus `document.title`, `og:site_name` and JSON-LD names.
- **Build script with decisions per fixture line:** modes `card`, `cut` (substring before the first ` - `, ` – ` or ` | `), `ll:<slug>` (La Liste h1, sha256-checked); assert that every population line is decided exactly once (rename or skip); assert `new_name <> expected_name`.
- **One check query for two batches:** union of both VALUES lists with a per-set md5 guard; collisions computed on the end state of both batches together.
- **Read-back for two batches:** one query with `audit_log.id > <last id>`; group by `at` to split the batches.

## Dead ends: do not retry (new)
- Gault&Millau Germany online: `gaultmillau.de`, `gault-millau.de` (pane load fails; WebFetch robots-disallowed). Ask Ben, or Ben reads it himself.
- `burg-aasen.de` in the pane (fails even after `request_access`).
- `theworlds50best.com/list/...` (redirects to `the50.com/restaurants/best-in-the-world/...`).
- Treating the Michelin page block after the description as the venue's hotel (it lists nearby hotels).
- `award_sources.name` (no such column; columns: slug, status, display, geo_capable, price_capable, capture_permission, attribution_required, render_extended_above).

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/rename/michelin-2026-germany-dashes.csv` | Run (batch 15), in the repo | `c19a86d8…58f0c8` |
| `fixtures/rename/majority-2026-germany.csv` | Run (batch 16), in the repo | `bea56246…ad2f0` |
| `reports/rename-michelin-2026-germany-dashes-rename.md`, `reports/rename-majority-2026-germany-rename.md` | Written by the job (check the real-run version) | – |
| Set 1 files | As in the set-1 handoff | – |

## Open items, in order
1. **Slug file for rename batches 15 and 16 (next).** 48 plan rows, 11 kept (see above). Build, examine read-only, present, one "go" (Write connector).
2. **Plan v1.30** (content as item 2 of the set-1 handoff, plus: rename batches 15 and 16 (ledger 98–100, audit 108,932–108,990; dry runs batch 13–14, ledger 95–97, audit 108,873–108,931), the vote method, Ben's Q1–Q4 A decisions above (first pipe ruling), G&M not readable, the slug file once done). Plan-edit method; read the Version line first (expect 1.29).
3. France slug set (148 venues). Ben decides when.
4. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
5. Price from the Michelin card (population to read again; known differences Rebers Pflug 7906, BOK 6670, Kuultivo 5902; 30 option-A venues and AURA / Starnberg have no price row). Ben chooses the method.
6. Later-ceremony guides, promote only: **Texas (due now)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
7. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
8. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente (name now "Ente Wiesbaden"; return to the Nassauer Hof later), die burg (venue site did not load), Gault&Millau Germany (re-vote set 3 if the site becomes readable).
9. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs vs the `f_unaccent` rule.
10. Project file cleanup, part 2: after the migration is done (list in the staged-run1 handoff, item 11).

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-germany-renamed-sets23-2026-10-09.md first, then claude/handoff-germany-renamed-set1-2026-10-08.md for the set-1 slug method, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 100, audit_log id 108,990, slugs 12,509 and rename batches 15 and 16 applied with a Read query, and check in a fresh clone that reports/rename-michelin-2026-germany-dashes-rename.md and reports/rename-majority-2026-germany-rename.md are the real-run versions (not "DRY RUN"). Then start open item 1: build the gated slug SQL file for the 48 venues of rename batches 15 and 16 whose slug changes (template docs/slugs-rename-michelin-2026-germany.sql), examine it read-only, present it in /ste style, and wait for my go.
```
