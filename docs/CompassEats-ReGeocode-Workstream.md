# CompassEats — Shared-Pin Re-Geocode Workstream

**Scope:** the remaining cross-city collisions that are NOT city-label problems. These are cases where two or more genuinely different physical venues share a single Google `place_id`, so they collapse onto one map pin and surface as one `id` spanning multiple `city_slug` values.

This is a different job from the city-label cleanup. Folding these would wrongly merge real restaurants. The goal here is the opposite: give each real location its own pin.

---

## 1. Root cause

The reshape resolves geo for each venue identity (`name|city`) like this:

```js
var geo = enrich[nk + '|' + ck] || enrich[nk] || null;
```

The second clause is the culprit. When a specific `name|city` enrichment row does not exist, the venue falls back to a **name-only** enrichment row (`enrich[nk]`). Every city that shares that name then inherits the same `place_id` and coordinates, usually the brand's flagship. That is why "CUT by Wolfgang Puck" in Singapore, Los Angeles, and Las Vegas all land on one pin.

The fix is to create a specific `name|city` enrichment row for each real location, each carrying that location's own `place_id`, so the name-only fallback is never reached.

---

## 2. The three sub-types

Every collision in this bucket is one of three things. Triage first, because the action differs.

**A. Real brand, multiple real locations.** CUT by Wolfgang Puck, Imperial Treasure, Joël Robuchon, estiatorio Milos, Ginza Sushi Ichi, ARMANI/RISTORANTE, YOSHINO, Da Vittorio (Brusaporto / Sankt Moritz / Shanghai). Each location is a real restaurant that should appear on its own city page. → Re-geocode each location.

**B. Same-name coincidence, different restaurants.** Two unrelated venues that happen to share a name (e.g. "Alma" in the Netherlands vs Portugal; "OX" in Belfast vs Reykjavík; the Belgian "EST" vs the Tokyo "Est"). Google matched them to one pin. → Re-geocode each so they separate.

**C. Junk or non-venues.** Rows that should not be in the dataset at all (e.g. "U.S. Embassy & Consulate in the Republic of Korea"). → Remove via `closed_venues`, do not re-geocode.

---

## 3. Build the current target list

The collision universe changes every time new award data is ingested, so always regenerate from a **fresh** export, never a cached audit tab.

1. Export the live Sheet.
2. From the `venues` tab, group by `id`, count distinct `city_slug`, keep the groups with count > 1. That is the full collision set.
3. Split it:
   - single-name AND single-country → city-label fold work (the other workstream).
   - multi-name OR multi-country → this workstream.
4. For each target, list the distinct `(name, city)` pairs. Those pairs are the re-query inputs.

---

## 4. The fix procedure (per batch)

Every paired re-query costs a paid Places lookup, so this runs behind an explicit cost estimate and approval gate. One lookup per `(name, city)` pair.

1. **Assemble `TARGET_PAIRS`** as exact `(name, city)` combinations, not name-only sweeps. Name-only sweeps re-pin the correct home rows too and cause churn.
2. **Clear existing enrichment rows for those pairs first, with a backup.** `geoRequeryCollisions` is append-only and skips pairs that already have an enrichment row, so a stale row will block the re-pin. Copy the affected `Places Enrichment` rows into a backup tab, then delete them.
3. **Dry-run preview.** Confirm the pair list and the projected number of paid calls before anything hits the API.
4. **Run the paired re-query.** It writes a specific `name|city` enrichment row per pair, each with its own `place_id`, `lat`, `lng`, and address.
5. **Reshape.** `reshapeCompassEats` now finds a specific row for each location and stops falling back to the name-only pin.
6. **Verify against live data.** Re-export, recount collisions, confirm the batch's targets dropped and no new collisions appeared.

Remember the blurb sequence before any publish: `importBlurbsFromDrive → clearWrongCityBlurbs → importOptionB`.

---

## 5. Guardrails

- **Never rename a venue.** Names drive slugs, slugs key blurbs. Geo work changes coordinates, `place_id`, and city labels only.
- **Under-merge beats over-merge.** If it is unclear whether two rows are the same venue or two venues, keep them separate.
- **Verify against the live `venues` tab, not `geo_audit` / `dupe_audit` / `collision_audit` / `cities`.** Those do not auto-refresh.
- **Gate every paid run behind a dry-run preview and an explicit go.**
- **Do not touch `src/lib/venues.ts`.** This is pipeline-side work; the frontend file is locked.

---

## 6. Edge cases

- **Google returns the same `place_id` even with the city appended.** Some brands only have one strong Places entry. If a paired query still resolves to the flagship, the location cannot be auto-separated. Options: assign a known correct `place_id` by hand, or accept the venue as unresolvable and leave it parked. Do not force a wrong pin.
- **Coincidental same-names where one side is not award-worthy on its own.** If one of the two venues has no real accolade footprint, consider whether it belongs in the dataset at all before spending a lookup on it.
- **A pair resolves to a permanently closed location.** Route it to `closed_venues` instead of re-pinning.

---

## 7. Sequencing and routing

- **Triage (A vs B vs C) is judgment work** and is a good fit for Cowork on an Opus-tier model: it needs per-venue reasoning about whether locations are real branches, coincidences, or junk.
- **The clearing, re-query, and reshape runs are mechanical** and fit chat with a lighter model.
- Batch by region or by brand so each paid run is small, previewable, and easy to verify before the next one.

---

## 8. Definition of done

The collision count for this bucket reaches zero, or every remaining item is a documented "unresolvable" (Google returns one pin) or a deliberate parked case. At that point the `venues` tab has one `id` per real physical location, and each location shows on the correct city page with its own accolades.
