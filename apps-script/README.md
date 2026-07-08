# CompassEats — Apps Script (reference mirror)

These `.gs` files mirror the live **"Compass Eats"** Google Apps Script project bound to
the source Sheet (`1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s`). They are committed here
so they're version-controlled, backed up, and readable without opening the editor.

> The Apps Script project is the source of truth. Re-commit a file here whenever you edit
> it in the editor. **Last synced: 2026-07-07.**

All files run inside one project and share a **single global namespace** — constants and
helpers are visible across files, so names use prefixes/suffixes (e.g. `HERO_`, `_R`) to
avoid collisions.

## Canonical pipeline run order

Run top to bottom whenever Sheet data, matching logic, or `CITY_ALIASES_` changes:

0. `geoEnrich`                 — **conditional pre-step.** Only when new venues were added
   or names/cities changed — i.e. there's new geo to fetch. Run `auditEnrichment` first to
   refresh the worklist. Skip entirely for identity-neutral fixes (e.g. a `type`-only change).
1. `reshapeCompassEats`        — rebuild venues tab; applies `CITY_ALIASES_`; **wipes blurbs**
2. `mergeDuplicateVenues`      — collapse same place_id+city+type; cross-city → `merge_review`
3. `importBlurbsFromDrive`     — refill blurbs from `blurbs_final.csv` (matches on slug)
4. `clearWrongCityBlurbs`      — blank the hardcoded wrong-city blurb list (keyed `city_slug/slug`)
5. `importOptionB`             — write the verified premium blurbs over the marquee set
6. `generateCitiesTab`         — rebuild cities tab from venues' city_slugs (mandatory after folds)
7. `generateRegionsTab`        — rebuild `regions` tab from `city_regions` + the fresh cities/venues
   tabs; embeds each region's cities *and* their venues (powers the region-page "expand a city"
   dropdown). **Conditional:** skip only if `city_regions` is unchanged and no cities were added/removed.
   → `preflightPublish`        — gate: duplicate keys + orphan cities must both be 0
8. regenerate JSON (`venues.json`, `cities.json`, `venues-index.json`, `regions.json`) →
   upload via GitHub web → publish in Lovable

Full detail: `docs/runorder.html` (canonical — supersedes the older `CompassEats-Pipeline-Run-Order.html`,
which is kept for history only and should not be used) and `docs/CompassEats-Data-Pipeline.html`.

## Other tools in this folder

Most files above are the standing pipeline. The rest are one-off or occasional-use tools,
grouped here so a fresh session isn't left guessing what 30+ files are for:

- **Geo-collision cleanup:** `Collision Fix.gs`, `CollisionRequery.gs`, `RemoveCollisionFixRows.gs`,
  `blankcollisionnames.gs`, `geoRequeryCollisions.gs`, `geoFixDiagnostic.gs`, `geosplitscan.gs`,
  `compasseats-collision-audit.gs`, `compasseats-geo-dupe-audit.gs` — the shared-pin/cross-city
  collision workstream. High-judgment; run with a fresh live-`venues` export, never from cached
  audit tabs.
- **Region matching:** `Region Match.gs`, `Region-Match-Retry.gs` — geocode-based auto-suggest
  tool that built out the `city_regions` mapping tab (bounding-box logic to disambiguate things
  like Rocky Mountains vs. Canadian Rockies). One-time/occasional use — only re-run when a batch
  of new cities needs region assignment; NOT part of the standard per-session loop. Output feeds
  `generateRegionsTab`, which is the actual per-session step.
- **City aliasing:** `generateCityAliases.gs`, `generateCityAliasesV2.gs` — builds `CITY_ALIASES_`
  candidates for `Reshape.gs`.
- **Corruption/verification one-offs:** `fixCountryCorruption.gs`, `fix-corruption.gs` (duplicate —
  reconcile or remove one), `verifyFoldsAndStars.gs`, `verifyMarqueeMerge.gs`.
- **Photos:** `Compasseats Photos.gs`, `compasseats-hero-photos.gs`.
- **Ingest:** `Compasseats Bar Ingest.gs`, `compasseats-restaurant-ingest.gs` — write to `Bar Awards`
  / `Restaurant Awards` staging tabs (never directly to `venues`, which reshape rebuilds from scratch).

## Gotchas
- `clearWrongCityBlurbs` is keyed on `city_slug/slug`; any `CITY_ALIASES_` fold that moves a
  flagged venue silently breaks its key — re-audit that list whenever aliases change.
- `generateRegionsTab` is keyed by **city display name** (matching `city_regions` tab's City
  column against the `cities` tab's `display` column) — a display-name change (e.g. a city
  losing a disambiguating suffix like "Lindau im Bodensee" → "Lindau") silently drops that
  city from its region until the `city_regions` row is updated to match.
- Publishing does **not** auto-sync the Sheet (build-time sync needs Enterprise Build Secrets);
  the live site reads committed JSON, so data changes go live only via a JSON commit.
- New award sources (e.g. Gault & Millau, Forbes Travel Guide) commonly bring in venues
  CompassEats has never geocoded before — expect a chunk of them to land in `needs_enrichment`
  rather than `venues` on the first reshape after ingest. Run the `auditEnrichment` →
  `geoEnrich` pass before assuming an ingest is "live."
- The JSON-regen step (`sync-sheet.ts`) calls the live Google Sheets API directly and can't be
  run in a sandboxed/offline environment. The standing workaround: export the Sheet as `.xlsx`
  and have Claude reproduce the same schema-validated transform from the export (same
  `rowToVenue`/`rowToCity`/`rowToRegion`/index logic, euro→dollar `price_tier` normalization,
  Excel-datetime→ISO-date normalization for `last_verified`).
