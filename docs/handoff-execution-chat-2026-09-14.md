# Handoff: CompassEats execution chat, Sep 10–14, 2026

Written for a fresh chat. Ben is not a developer. He is often on a phone. The next chat is the Sonnet-class execution chat: it runs gated SQL through the Supabase Write connector, reads through Supabase Read, writes Cowork and Claude Code prompts, and keeps the plan current. Fable is for rulings only.

## How Ben works with this chat
- Plain language. `/ste` style for data replies: short sentences, no contractions, one step at a time.
- Every count states its population and grouping key.
- One "go" per write batch. State expected counts before, read actual counts back after the commit, always with a Read query, never trust the write result alone.
- Writes: one `BEGIN … COMMIT` per batch. A failed statement rolls the batch back; read counts before retrying.
- Under-merge beats over-merge. Competitor sites (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) are never a source. No fact from memory; every claim needs a URL.
- Never hand-retype a data file. If a file must change, a Claude Code session edits it.
- Ben cannot edit CSVs on his phone. Files in the repo are edited by Claude Code sessions or uploaded through GitHub "Add file → Upload files".
- Cowork prompts and Claude Code briefs go in a file; Ben pastes them as the first message.
- The repo is public: `github.com/benjamineades/compasseats`. This chat cannot read folder pages there; a file page opens only after it appears in a search result. Ben pastes file contents when needed.

## Live state (population: whole table, read back Sep 14 after the last commit)
venues 11,258 (active 10,878) · awards 22,884 · listings 11,258 · slugs 11,515 · cities 3,225 · redirects 9 · ingest_batches 3 (first-batch-2026-09 promoted, michelin-2026-france promoted; id 3 is France) · source_capture_ledger 12 · Michelin 2026 rows 1,999 (1,070 with source_url, 928 legacy without).

## Plan
`CompassEats-Rearchitecture-Plan.html` is at **v1.19** (Sep 14). Ben must save it to `docs/` and re-upload to Project Knowledge; the Project Knowledge copy may still be older. Versions written in this chat: 1.16 (Sep 10 rulings), 1.17 (ingest job live, brief withdrawn), 1.18 (undo job, migration 3), 1.19 (France, patterns, splits, rename guard). Each version adds one card after the Phase 2 cards and one changelog row; nothing ratified was reopened.

## Rulings made in this chat (all recorded in the plan)
- Sep 12: specialist legal brief withdrawn. Project is private, personal use; the site is reachable but not promoted. Legal review is a public-launch trigger. If reach becomes an issue, password-gate the site. Exposure ledger and D10 caps unchanged.
- Sep 12: build the undo job **and** run Michelin in small per-guide batches. Both done.
- Sep 13: Michelin 2026 scope is stars and Bib Gourmand only. Green Star and special awards are **held, not dropped**: one later batch `michelin-2026-special-awards`, sized from each guide's log. Category vocabulary needs one spelling per award first ("Service Award" vs "Outstanding Service Award" both exist). Michelin retired Green Star on June 1, 2026 ("Mindful Voices"), so vocabulary may differ per guide.
- Sep 14: renames get a fourth job, not hand SQL (see Rename guard).
- Sep 14: slug-split rule: larger group keeps the plain slug, smaller moves to `<slug>-<iso>` (precedent `munster-fr`), moved venue gets a `redirects` row.

## The ingest pipeline (repo, GitHub Actions)
Three buttons: **Ingest — stage**, **Ingest — promote**, **Ingest — undo**. Manual: `docs/ingest-job.md` (read it; it is accurate). Connection: Session pooler string in repo secret `SUPABASE_DB_URL` (set, works). Migrations 1–3 applied.
- stage inputs: `csv_path` (a repo path, e.g. `fixtures/ingest/michelin-2026-france.csv`), `batch_key`, optional `decisions_path`. Runs in seconds now (PR #4). Report at `reports/<key>-stage.md`, review file `reports/<key>-review.csv`.
- promote: confirmation `PROMOTE <key>`. undo: `UNDO <key>`, dry run ticked by default.
- The job never creates a city, never merges, never renames. Missing cities are created by gated SQL in this chat before re-stage (pattern: `ci_` + md5(slug)[:10], display, country, ISO, no geo, kind 'city').
- Loose-name pass (PR #4 follow-up, merged): a `new_venue` row with a close same-city name comes back as `review_venue · loose_key_candidate_in_city`.
- Decisions file pattern: a Claude Code session builds `reports/<key>-decisions.csv` with candidate id/name/city/2025 tier and a proposal per review row; Ben settles blanks; re-stage with `decisions_path`. Decisions: `use:ve_x`, `new`, `city:ci_x`, `skip`.
- Batch CSVs live in the repo, not Drive (standing fix for the Cowork upload size wall).

## Michelin 2026 progress
Brief: `brief-michelin-2026-batches.md` (in this chat's outputs; the Cowork session holds it). Guide order, largest 2025 gap first: France ✅ (1,071 rows promoted Sep 14), Italy ~611, Japan ~579, Spain ~483, USA remaining ~411 (California and Florida done), China ~382, GB+IE ~391, BE+LU ~249, Switzerland ~225, Netherlands ~185, Thailand ~178, Taiwan ~176, Austria ~156, HK+MO ~180, Singapore ~126, Korea ~117, Canada ~106, then the rest. Already complete for 2026: Germany, Nordics, Vietnam, New Zealand, California, Florida.
Expect on every guide: 2025 names are Google-style, 2025 city labels are nearest-big-city; the stage report will show many review rows; run the decisions-file pattern.
France leftovers: A Mandria di Pigna (Bib, skipped because Pigna was ambiguous; `pigna-fr` now exists) can land as a one-row batch under a new key.

## Rename guard
Trigger `trg_venue_rename` blocks any change to `venues.name` unless `app.allow_rename = 'on'` is set in the session. It enforces the manual's promise. No rename job or function exists. **Do not set the flag by hand.** Build a fourth button (CSV of venue id + new name, dry run, one transaction, ledger row, refuse if current name differs from the file's expectation). 159 French rename pairs are prepared: `csv_name` from `reports/michelin-2026-france-decisions.csv` for every `use:` row where it differs from the venue's current name (21 of them add Michelin's hotel/chef suffix).

## Done in this chat, in order
Batch C narrow (5 NoMad Bar awards + fix 4) · country_iso backfill (3,155 cities + 6 policy cities) · Batch D (21 closed venues, 36 awards, fix 3 Vong) · Fix 1 (award 19237 deleted) · migration 3 · Plan 1.16–1.19 · 40 French cities created · France staged, decisions, re-staged, promoted · 8 slug splits with 9 redirects, San Juan set PR · status checks on 4 venues.

## Open items
1. **Cowork: "go" for Italy** (batch 2). Desktop needed.
2. **Rename job** (fourth button), then run the 159 French pairs.
3. **3-venue ingest CSV**: Restaurante 040 Santiago (LatAm 50 Best 2019 #37, 2020 #41; open, relocating to Mandarin Oriental Santiago), Woda Ognista Warsaw (Top 500 Bars 2024 #469; open). Casa Prunes Mexico City (Top 500 Bars 2025 #415) stays unknown: 2025 ranking vs an OpenTable listing marked closed. Source URLs are in `batch-d-verification-worklist-filled.csv` (Drive "CompassEats Staging").
4. **Salvatore at Playboy, W50B Bars 2012**: PDF says rank 45, diff said 46. Part of defect 2 (18 ranks off by 1–3 in that year). Resolve the block, not the row.
5. **Special-awards batch** after the last stars-and-Bib guide; vocabulary fix first.
6. **Publish builder prerequisite**: 351 French new venues (and every guide's) are `published=true` with no geo, photo or blurb. The builder must render bare venues through honest-geo states or gate them.
7. **Cleanup list**: 12 empty cities with no country (alsace, beersel, torrence, 9 US resort slugs); stale `cities.venues_count` on old rows; Madame Vo `ve_86b759e5f5` at 0 awards; asia-50-best-restaurants holds "3 Knives" and "99.5/100" categories; `docs/compass-schema-v1.sql` has stale `norm_key()`; 585 name-contamination candidates; Michelin 2026 special-award spelling duplicates; 2025 Michelin name correction pass per guide (after the rename job).
8. Delete stale branches (`phase2/ingest-importer`, `claude/michelin-2026-france-decisions-k7zf01`).

## Files from this chat (outputs)
`CompassEats-Rearchitecture-Plan.html` (v1.19) · `handoff-batch-cd-2026-09-10.md` · `brief-ingest-undo-job.md` · `brief-michelin-2026-batches.md` · `prompt-michelin-france-decisions.md` · `batch-d.sql` · `cowork-prompt-batch-d-verification.md` · `batch-d-verification-worklist.csv`.

## Lessons for the next chat
- `venues.norm_key` is generated; never insert it. Enum columns need a cast in a UNION. `cities` has a `slug` column, qualify names when joining temp tables.
- The 10-row acceptance batch hid a quadratic in stage; always time the first big batch.
- My own estimates were wrong twice (304/152 loose-candidate split; "cities −1" for Jiménez de Jamuz). Measure, do not extrapolate.
- A stage report is in the run summary, the artifact, and `reports/`. From here, the verdicts are also readable in `ingest_rows` by batch id.
