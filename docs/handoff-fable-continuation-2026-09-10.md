# Handoff: CompassEats — design authority and escalation chat (continuation)
2026-09-10 · This replaces the Fable chat that authored the re-architecture plan, ran the six-document review cycle, signed the schema, supervised Phase 1, and issued the Sep 10 award-audit rulings. That chat is closed for cost. The new chat inherits its role: design decisions, escalations, ratified-rule changes, and plan-doc updates. Not mechanical execution.

## Objective
Move CompassEats from a Google-Sheet/Apps-Script pipeline with Google-derived geo to a Supabase canonical store with staged jobs, per-field provenance, and zero stored Google content except `photo_refs.google_place_id`. Production swap target: mid-October 2026. Non-commercial. Budget ceiling $200/month.

## Current state (Sep 10, 2026)
- **Phase 1 complete.** Live in Supabase (`compass-network` org, `compass-canonical`, Pro, East US): venues 10,878 · cities 3,176 (11 flagged `destination_region`) · awards 21,764 after Batches A/B · listings and slugs match venues, plus 5 non-canonical slug restores · blurbs 142 (all 141 Option B records, one covering a dual-category twin; all `needs_rewrite`) · city_aliases 263 · price 7,092 legacy-guide symbol rows · `award_sources` 23 (canonical seed; 21 hold rows, tabelog and africa empty) · norm_key NULL-guard live (120 short-key venues exempt) · geo, addresses, hours empty by design.
- **placeId triage decided in full:** 163 groups → 160 keeps, 2 name-mismatch drop-alls (Taian, ivy), 1 removal (Dialog in the Dark). `triage-final.csv` holds every verdict. The apply batch and the photo_refs load: (unconfirmed whether run; venues dropped 10,903 → 10,878 since Aug 24, consistent with the batch having run — verify with a count before assuming).
- **Phase 2 not yet built** as of the Sep 10 audit ("before the publish builder is written"). Award coverage audit pass 1 done in a Sonnet chat; its rulings are in §Rulings below and in `handoff-response-award-audit-2026-09-10.md`.
- **Repo private.** Sheet is ingest-only and has no path to Supabase; `reshapeCompassEats` prohibited outright.

## Decisions (ratified, with reasons)
- **D1–D11** in Plan v1.15 §1. Key: D5 Google price backfill cancelled permanently (2,244 quarantined integers = Phase 5 purge target); **D6 rejected** — no Google signal in any per-venue decision; D8 repo private; D10 publisher exposure ledger + caps + capture_permission per publisher; D11 residual geo cascade (venue site → open data → gated guide capture → labels).
- **Geo gates:** A agreement 90.0%, B strong-POI 87.3%, C exact-name loose 84.6% headline / 76.4% marginal; precedence A > B > C; `venue_low` = C-only rows; the "costs nothing" claim is withdrawn — the honest ledger is ~740 fewer correct pins, ~1,214 divergent (ceilings). Strata published (Japan 40, WE 35, China 30, RoA 25, NA 25, ESE 20, LatAm 15, MEA 10); no reweighted figure prints until both arms print together. Phase 3 checkpoint: re-plan if residual > 4,000 or Japan > 1,000.
- **Schema rules:** one normalisation rule (NFKD, lowercase, strip non-alphanumerics; < 3 chars → NULL); dedupe is a promote gate, never a hard block; renames only via `app.allow_rename`; every count states population and grouping key; every drop verdict cites a measurement (three drop-defaults were reversed by measurement, saving 16,034 award values).
- **Country:** never read from venue rows; `cities.country/country_iso` derive once per city (F39). Columns exist and are blank pending geo resolution — see Sep 10 ruling 2 for the interim backfill.
- **Extended lists:** parent slug + rank for all 50 Best lists; six `-51-100` slugs retired; ranks above 50 render the extended label via `render_extended_above`; awards unique on (venue, source, year, rank, category, distinction).
- **Triage rules (Aug 24):** each independently rated location of a multi-site group is its own venue with its own placeId, never shared; the id belongs to the branch the recorded address proves (Da Vittorio → Brusaporto); name mismatch beats address match; no matcher drop verdict trusted until it handles metro containment, diacritics, adjacent rural postal names; four classes MERGE / TWIN / PHANTOM / NOT A VENUE.
- **Closed-venue rule (Aug 24):** `status='closed'` + `listings.published=false`; iconic exception (elBulli) stays published; award record never deleted; publish builder gates on `listings.published`, never `venues.status`; "iconic" is Ben's per-venue call, no automated test. A closed-venue sweep across all venues is a named pre-swap workstream.
- **Blurbs:** only Option B migrates; generated set dropped (thin, coverage metric would lie). Target 2,433 (top-10 cities + hand-picks; Kyoto 196 by slug), floor 1,642, ~40/day assumption, early-September floor trigger. Ben's branch facts for six multi-branch names (Étude→Aix, Joo-ok→NYC, Hakkasan→Abu Dhabi, Sushi Shin→Tokyo, Shang Palace→HK, Niko Romito→four starred branches) are rewrite inputs.

## Rulings issued Sep 10 (award coverage audit) — fold into Plan v1.16
1. **Michelin 2026 (5,000–6,000 rows):** after the specialist brief is sent, as Phase 2's first staged batch through `ingest_batches`, one guide per batch, Chrome-assisted reads. The brief must state the steady-state refresh rate (~7,000 Michelin rows/year) and the read method, not just the stock.
2. **country_iso:** no schema change. Interim backfill now from `city_label_source` majority per city + static ISO map; 13 cross-country slugs take their triaged outcomes; geo resolution confirms later.
3. **New venues never route through the Sheet** (no path to Supabase). The Phase 2 ingest job (`ingest_batches` → validate → approve → promote, minting ids and slugs) is the path and the first Phase 2 deliverable. New venues start with no geo and an honest label.
4. **"51–100 in": approved. "Closed venues out": rejected** — conflicts with the closed-venue rule and with Rule 1. Replacement: award rows for every published rank; closed venues get a minimal venue row (`closed`, `published=false`; iconic → `published=true`), no geo/photo/blurb.
5. **Flags:** venue names are award-source names by rule, never Google — a name differing from the source is contamination to fix (run the name-contamination check against the award tabs). World's 50 Best 2002–2011 block is unreliable (defects 3, 4 + joinpearl errors): verify against Wikipedia year pages before the publish builder; flag, do not delete. **Competitor sites are never a source.** Generalise Batch A: a higher distinction subsumes "listed" within one source-year; check Michelin for the same pattern. Every new award row carries `source_url`; legacy rows stay blank, labelled legacy.

## Dead ends — do not retry
- Assuming shared Google id = duplicate (mostly real twins). Name+city Places re-query (creates the errors). Attesting column provenance from memory (measure). Multi-statement SQL in one paste (run one statement at a time; or one `BEGIN…COMMIT` through the Write connector). `''` for JSON columns (use NULL). Markdown/CSV attachments to the Fable chat (arrive empty; **share as PDF via Notes** — the only route that worked). theworlds50best.com archive URLs (JS app ignores year). joinpearl.co as a source.

## Artifacts (Project Knowledge + repo `docs/`)
- Plan v1.15 (Aug 24) — living doc; **v1.16 owed** with the Sep 10 rulings.
- Schema Map v1.7 (signed) · compass-schema-v1.sql (as run) · handoff-phase1-execution.md · handoff-phase2.md (Aug 24) · triage-final.csv · the Aug 24 verified-triage PDF · handoff-award-coverage-audit-2026-09-10 (PDF) · handoff-response-award-audit-2026-09-10.md (this session's reply to it).
- Superseded: triage-drop-review.csv (six verdicts wrong).

## Verbatim essentials
- Sheet ID `1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s` · repo `github.com/benjamineades/compasseats` (private) · Supabase project `compass-canonical`.
- ID scheme (load session): `prefix_` + md5(key)[:10]; venues key `city_slug:json_slug`; cities/regions key = slug.
- Michelin exposure inventory for the brief: ~18,000–22,500 items (8,110 awards, up to 7,101 cuisine, up to 7,088 price, ~200 labels).
- Specialist brief = Plan §6, six questions (Q6 added Aug 24: closed unpublished venues vs the cumulative ledger; interim conservative position: capture events count regardless of display).

## Working preferences
- Ben: non-technical, often on a phone. Short, plain, `/ste` for data replies; `/humanizer` + `/delete-ai-words` only for site prose. One verified step at a time; expected count before, actual after; one "go" per destructive batch; never assume a write landed.
- State chat-vs-Cowork routing and model at task start; flag mid-task switches; Sonnet for mechanical runs, Cowork for browsing-heavy batches, Fable/Opus for judgment.
- Living docs re-saved to `docs/` + Project Knowledge with version + date on any change.

## Open items
- **Next step (this chat):** write Plan v1.16 with the Sep 10 rulings, then hold for escalations.
- **Ben:** send the specialist brief (still unsent as of Aug 24 — confirm); read the Michelin card; paste the 17 twin placeIds from Google Maps share links as convenient.
- **Sonnet chats:** Batch C (award inserts for existing venues + fixes 1, 3, 4, rule 4 as replaced); country_iso interim backfill; Phase 2 ingest job, then guards and publish builder (Opus checkpoint on the invariant suite); verify whether the Aug 24 apply batch and photo_refs load ran.
- **Cowork:** W50B 2002–2011 verification; 50 Best 51–100 backfill (W50B Restaurants 2013–2025, MENA, NA); classification pass on the 137 machine-passed triage groups.
- **Chrome-assisted:** Wine Spectator 2026, 101 Best Steakhouses 2025, Top 500 Bars gaps; then Michelin 2026 after the brief.
- **Judgment-grade, owed:** the joined-tab measurement (discordant counts, per-stratum rollup, both reweighted arms). Award Radar checks: Asia Bars 2026 absent, Asia restaurants 51–100 2022, Yangzhou Shang Palace missing, LatAm 2020 existence.
- **Escalation triggers (unchanged):** verification surprises, joined-tab verdicts, specialist or Michelin answers, ratified-rule changes, Phase 4 design.

## Suggested opening prompt
> You are the design and escalation chat for CompassEats. Read handoff-fable-continuation-2026-09-10.md, then Plan v1.15 and Schema Map v1.7 in Project Knowledge. First task: write Plan v1.16 folding in the Sep 10 rulings from the handoff's Rulings section, save-ready for docs/ and Project Knowledge. Then wait for escalations. Do not redo any settled decision; every count states its population and grouping key.
