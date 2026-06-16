# CompassEats — Apps Script (reference mirror)

These `.gs` files mirror the live **"Compass Eats"** Google Apps Script project bound to
the source Sheet (`1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s`). They are committed here
so they're version-controlled, backed up, and readable without opening the editor.

> The Apps Script project is the source of truth. Re-commit a file here whenever you edit
> it in the editor. **Last synced: 2026-06-16.**

All files run inside one project and share a **single global namespace** — constants and
helpers are visible across files, so names use prefixes/suffixes (e.g. `HERO_`, `_R`) to
avoid collisions.

## Canonical pipeline run order

Run top to bottom whenever Sheet data, matching logic, or `CITY_ALIASES_` changes:

1. `reshapeCompassEats`        — rebuild venues tab; applies `CITY_ALIASES_`; **wipes blurbs**
2. `mergeDuplicateVenues`      — collapse same place_id+city+type; cross-city → `merge_review`
3. `importBlurbsFromDrive`     — refill blurbs from `blurbs_final.csv` (matches on slug)
4. `clearWrongCityBlurbs`      — blank the hardcoded wrong-city blurb list (keyed `city_slug/slug`)
5. `importOptionB`             — write the verified premium blurbs over the marquee set
6. `generateCitiesTab`         — rebuild cities tab from venues' city_slugs (mandatory after folds)
   → `preflightPublish`        — gate: duplicate keys + orphan cities must both be 0
7. regenerate JSON → upload `data/*.json` via GitHub web → publish in Lovable

Full detail: `docs/CompassEats-Pipeline-Run-Order.html` and `docs/CompassEats-Data-Pipeline.html`.

## Gotchas
- `clearWrongCityBlurbs` is keyed on `city_slug/slug`; any `CITY_ALIASES_` fold that moves a
  flagged venue silently breaks its key — re-audit that list whenever aliases change.
- Publishing does **not** auto-sync the Sheet (build-time sync needs Enterprise Build Secrets);
  the live site reads committed JSON, so data changes go live only via a JSON commit.
