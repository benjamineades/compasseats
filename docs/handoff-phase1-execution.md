# CompassEats — Phase 1 Execution Handoff
**From:** the re-architecture design chat (Fable, closed Aug 13, 2026)
**To:** a fresh Sonnet project chat
**Reader:** Ben runs every step himself — non-technical, click-by-click, one verified step at a time, plain language, complete file drop-ins, logs pasted back. Never assume a step succeeded: ask for the log or the count.

**Authoritative docs (Project Knowledge + repo `docs/`):** Re-Architecture Plan v1.14 · Phase 1 Schema Map v1.7 (signed off) · compass-schema-v1.sql · CompassEats-OptionB-Pipeline-Runbook.md · this handoff. **Docs override memory. Every count states its population and its grouping key.**

---

## 1 · State as of August 13, 2026

- **Ratified:** D1–D5, D7–D11. D6 rejected — no Google-derived signal in any per-venue decision. Geo gates settled: A (agreement, 90.0%), B (strong-POI, 87.3%), C (Overture exact-name, loose form, 84.6% headline / 76.4% marginal). Gate precedence A > B > C. `venue_low` means C-only rows.
- **Schema Map v1.7 signed off** — both lines, with two ratified conditions on the placeId triage (see §3).
- **Supabase live:** org `compass-network`, project `compass-canonical`, Pro plan, East US (N. Virginia). Schema v1 ran clean as one transaction; `award_sources` seeded and verified at **23**.
- **Repo private** (D8 done). **Freeze:** Sheet is ingest-only; `reshapeCompassEats` is **prohibited outright** (it erases 137 chef rows and would inject up to 2,244 quarantined Google price integers via its `price_level` fallback).
- **Price backfill cancelled permanently** (D5). The 2,244 Google integers live only in the Places Enrichment tab — the named Phase 5 purge target. Published `price_tier` = 7,095 symbol values, all award-sourced, all migrating.
- **Phase 1a complete, both passes clean:** raw venues tab == published dataset row for row. All inventories below are measured, not estimated.

## 2 · The load — task order for this chat

Source of load data: the published dataset (reconciled row-for-row with source). Path: build per-table CSVs → Ben imports via Table Editor ("Import data via CSV") in FK order → row-count verification after every table → full verification report at the end. One table per step. Never two.

**FK order:** regions → cities → city_aliases → venues → listings → slugs → awards → geo (empty at load) → addresses (empty) → price → hours (empty) → blurbs → photo_refs → city_label_source.

**Pre-load transforms (all ratified — Map v1.7 is the authority):**
1. **IDs minted fresh:** `ve_`/`ci_`/`rg_` + random suffix. The old Google placeId is NOT the id; it goes only to `photo_refs.google_place_id`, and only where the triage keeps it.
2. **Awards fold:** NA + Asia `-51-100` rows fold into parent slugs with ranks; dedupe on (venue, source, year, rank). **Expected diffs, stated in advance:** award rows 22,091 → ~21,847 (−244, the Asia restaurants double-render repaired); distinct source slugs 24 → 21. The one non-exact pair routes to review.
3. **Price:** symbol values → tier 1–4 + `symbol_raw`, source `legacy_guide`, publisher recorded (Michelin-dominant). Integers cannot enter (CHECK constraint).
4. **Country is never read from venue rows** (F39). But FIRST: the ~13 cross-country rows triage with four outcomes — label fixed (milan/Spain), venue moved, **slug split** (`san-jose` = San Jose CA 2 venues + San José CR 3 venues), or per-city policy (`san-juan` = Puerto Rico labeling). `cities.country` then derives per city from geo resolution later; seed null at load.
5. **Display collapse, four-case winner rule:** majority wins; casing normalised (kyoto); accent/alias variants → `city_aliases`; the two live wrong labels corrected (Álvaro Obregón ×2 on mexico-city, Penang ×1 on george-town). 13 slugs / 460 venues / 22 minority rows.
6. **`neighborhood` + disagreeing country strings → `city_label_source`** (renamed, on the award/ingest row). Never rendered as a neighbourhood.
7. **Pseudo-cities:** 33 candidate labels export to a review CSV; Ben classifies city vs destination_region (~11 regions expected; Brighton and Hove is a real city — that is why it is a review, not a regex). `kind` flag set accordingly; regional slugs never take centroid fallback.
8. **Blurbs:** only the 141 Option B records (131 restaurants + 10 bars, from importOptionB.gs 2026-07-18), status `needs_rewrite`. Chef rides with them (137 values).
9. **norm_key collisions:** 15 groups / 30 rows under the settled rule → merge_review CSV for Ben (citations per the merge rule; under-merge beats over-merge).
10. **Aliases:** CITY_ALIASES_ imports as `city_aliases` rows — the CHECK constraint rejects apostrophe forms; dedupe the duplicated Batch-7 block on the way in; note `port d alcudia` for a working twin.

**Expected verification numbers:** venues 10,912 (10,551 active / 361 closed) · awards ~21,847 across 21 slugs (23 seeded — tabelog and africa legitimately empty) · blurbs 141 · chef 137 · cities 3,167 with **52 venue-less** (closed-venue cities keeping links) · slugs table: zero URL collisions.

## 3 · placeId triage — dry run first, ratified conditions

The July collision worklist (CompassEatsCityCollisionsWorklist.xlsx, Project Knowledge) is the decision input. Today's 174 shared-id groups = 144 July-persisting (135 red, 8 amber, 1 green) + 30 new.

**The ratified rule:** each group keeps the placeId only on its distance-verified `pin_home_city` row; every wrongly-pinned row drops its own. Bulk Places re-query rejected (it re-runs the mechanism that created the errors). Expected cost: ~170–200 photos to the compass mark.

**Condition 1 — the match, defined conservatively:** the kept placeId's recorded Google business name (`collision_review.returned_name` / enrichment `canonicalName`, existing tabs, zero API calls) matches the pin-home venue only if their normalised forms are **equal or one fully contains the other**. Anything else is a mismatch → that group takes the group-wide drop. **Ambiguity resolves toward dropping.** `canonicalName` is read for verification only and never writes a venue name.

**Condition 2 — dry-run gated:** the preview logs every group's decision, kept venue name, and matched Google name. **The live run executes only after Ben reviews that log.** The 30 new groups run the same screen; duplicate pairs merge and keep the survivor's id.

## 4 · Rules this chat must not break

- No Google-derived value anywhere except `google_place_id` in `photo_refs`. The enums and CHECKs enforce it — do not work around them.
- Every destructive or bulk operation: dry-run preview with a report, then Ben approves, then live. No exceptions.
- Venue renames only through the job flag (`app.allow_rename`). Geo work never changes names.
- One change per patch. Every count states population + grouping key. Under-merge beats over-merge.
- Living docs get re-saved to `docs/` + Project Knowledge with version + date on any change.
- Flag model/surface fit at each task start; flag expensive steps before running them.

## 5 · Parallel tracks and open items

- **Specialist brief:** complete in Plan §6 (five questions + the measured exposure inventory, ~18,000–22,500 Michelin items). Ready to send — Ben's action.
- **Michelin briefing card:** Plan, Phase 0 area — Ben reads before the conversation advances.
- **Joined-tab measurement (owed, judgment-grade):** the two discordant pair counts, the per-stratum gate rollup, and **both reweighted arms printed together**. Escalate for design; the reviewer session holds the CSVs.
- **Award Radar checks:** Asia's 50 Best Bars 2026 absent entirely; Asia restaurants 51–100 missing 2022; four upper-band gaps (World's/NA/MENA restaurants, Europe bars) — confirm each list exists before ingest.
- **Tabelog:** Q4-gated; targeted early September as a standard v4 ingest through the new pipeline. Japan plans on zero Tabelog until then (1,099 active; ~857 projected residual).
- **Blurb program:** launch gate = hand-picks + top-10 cities (2,433, Kyoto is 196 by slug); floor = top 5 (1,642); assumption ~40/day from mid-August; floor trigger = early-September run-rate check. Runbook governs; tone checks in chat before any import.
- **Geo checkpoint (Phase 3):** re-plan residual channels if measured residual > 4,000 or Japan > 1,000. Undershoot triggers nothing.

## 6 · Escalation triggers — back to Opus/Fable, new chat, short handoff

1. Any verification report that surprises (counts off, invariants fail).
2. The joined-tab measurement verdicts.
3. Specialist or Michelin answers arriving.
4. Anything that would change a ratified rule or decision.
5. Phase 4 design sessions (D7 direction is set: evolve the brand, restart the layout).

*End of handoff. The design chapter closed August 13 with the schema live and verified at 23.*
