# Response: Award coverage audit, first pass — rulings and close-out
2026-09-10 · From the Fable design chat to the Sonnet audit chat. Answers the four questions in `handoff-award-coverage-audit-2026-09-10`, corrects three premises, and revises the next steps. The audit is on track; Batches A and B stand.

## Verdict on the audit
Method is right: counts state populations, both writes were gated, the rank-keyed diff is the correct key. Two rules and two premises need correction before Batch C. Registry reconciliation confirmed: 23 is canonical (union 29 minus six retired `-51-100` slugs); 26 and 28 are dead numbers.

## Answers
**Q1 — Michelin 2026 backfill.** After the specialist brief is sent, as Phase 2's first staged batch. Route: `ingest_batches` → validation → Ben's approval → promote, one guide per batch, Chrome-assisted page reads. Not raw SQL, not shelved. Two additions to the brief before it goes: state the steady-state refresh rate (about 7,000 Michelin rows per year), because the exposure question is cumulative and a stock-only figure understates it; and state the read method (Michelin blocks the fetcher; a human-assisted browser read of public pages is the method).

**Q2 — country_iso.** No schema change. `cities.country` and `cities.country_iso` already exist; they are blank because country derives once per city from open geo resolution (ratified F39), which has not run. Interim backfill now, one Sonnet job: majority award-publisher country string per city from `city_label_source`, mapped to ISO with a static table; the 13 cross-country slugs take their triaged outcomes (label fixed / venue moved / slug split — san-jose / per-city policy — san-juan). Geo resolution confirms later. Defect 5's other two notes stand as facts, not defects: `regions` are travel regions by design; `awards.source_url` is blank on legacy rows because provenance is born at Phase 2 ingest.

**Q3 — New venues.** Never through the Sheet. The Sheet has no path to Supabase; the migration was one-time. New venues go through the Phase 2 ingest job — `ingest_batches` and `ingest_rows` exist in the schema now; the job adds validation, approval, and a promote that mints ids and slugs. Build it first. New venues start with no geo and an honest precision label; Phase 3 gates fill them.

**Q4 — The two rules.**
- "We list every venue the 50 Best organization ranks; 51–100 in wherever published": **approved.** Matches the ratified fold convention and `render_extended_above`.
- "Closed venues out": **rejected.** It conflicts with the Aug 24 closed-venue rule (award records are never deleted) and with Rule 1 itself: a published rank with no row is the gap the audit exists to close, and skipping closed venues writes the gap back in at exactly the ranks where Chez Dominique, Le Gavroche, Can Fabes and WD~50 sat. **Replacement rule:** award rows for every published rank. Closed venues get a minimal venue row — name, city, awards, `status='closed'`, `listings.published=false` (iconic → `published=true`, Ben's call) — no geo, no photo, no blurb. About 25 rows, not ~25 rows skipped.

## Three corrections before Batch C
1. **Names are not from Google Places.** Venue names are award-source names by rule. Google name overwrites were the `acceptReviewRows` incident, retired and prohibited. Rank-keyed diffing stays (rank is the stronger key), but a name that differs from the award source is contamination to fix, not noise. Run a name-contamination check against the award tabs and list the differing rows before any insert.
2. **World's 50 Best 2002–2011 is unreliable as a block.** Defects 3 and 4 (Madame Vo for Vong; the hotel for Le Louis XV) plus the joinpearl errors are three independent signals. Verify the whole block against Wikipedia year pages before the publish builder; flag mismatches, delete nothing without two sources. Defect 2 (2012 Bars) follows the same standard.
3. **Competitor sites are never a source** — accuracy and provenance both. Publisher first; Wikipedia as the second source for 2002–2011.

## Rules to write down
- A higher distinction subsumes "listed" within one source-year (Batch A generalised). Check Michelin for the same pattern before assuming it is Pinnacle-only.
- Every new award row carries `source_url`. Legacy rows stay blank and are labelled legacy.
- Category vocabulary per source is a controlled list, validated at ingest (Batch B's normalisation becomes a rule, not a one-off).
- La Liste before 2026 as policy, not defect: record it on the `award_sources` row (a `coverage_from_year` note) so the next audit does not re-flag it.

## Revised next steps (in order)
1. Name-contamination check (read query; list differing rows).
2. **Batch C, revised scope:** award inserts for true-missing rows on existing venues, all 55, closed included; fixes 1 (La Cúpula via the ingest job, then move rank 1), 3, 4. Expected counts before, actual after, one "go".
3. Country_iso interim backfill (Sonnet job).
4. Phase 2 ingest job — first deliverable; then W50B 2002–2011 verification (Cowork), 51–100 backfills (Cowork, Sonnet), Chrome-assisted pulls (Wine Spectator, Steakhouses, Top 500 gaps), and Michelin 2026 after the brief.

## Close-out
This audit chat closes with these rulings applied to its open items. Routing forward: Sonnet chat for Batch C and the country backfill; Cowork for verification and backfills; Chrome-assisted pulls as listed; escalate to the new Fable chat (see `handoff-fable-continuation-2026-09-10.md`) on any verification surprise or ratified-rule question.
