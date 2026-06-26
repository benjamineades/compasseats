# Regions index + per-region pages

Three file touches. `src/lib/venues.ts` and `src/lib/schema.ts` are not touched.

## 1. `src/routes/regions.tsx` — `/regions`

Static-prerendered route. Loader imports `data/regions.json` and validates with `z.array(RegionSchema).parse(...)`.

Visual: paper/editorial system matching `/cities` and `/guides` (`PAPER #F7F3EB`, `INK #23211E`, `INK_MUTED #6a6253`, `BRONZE #895F2E`, `HAIRLINE rgba(35,33,30,0.12)`).

Header:
- Eyebrow "The Places People Travel To" (BRONZE, uppercase, `tracking-[0.2em]`).
- H1 "Explore by Region" (`font-display text-5xl md:text-6xl font-light`).
- Subhead: "Browse award-winning restaurants and bars by the places people actually travel to."
- Small muted meta line: "N regions, grouped by country."

Grouping:
- Bucket regions by `country` (regions with no `country` → "Multi-country" bucket, sorted last).
- Country total = sum of member regions' `venue_count`. Countries sorted desc by that total.
- Regions inside each country sorted desc by `venue_count`.
- Render each country as a section: italic country heading + muted "N regions · N venues" meta + ruled `<ul>` of region links (same row treatment as `/guides`).

Region row (`Link to "/region/$slug"`):
- Left: `region.display` in `font-display text-lg sm:text-xl`.
- Right: muted "N venues · N cities" (tabular-nums) + bronze `→` that nudges on hover.

`head()`: title `Regions — places worth traveling for | CompassEats` + matching og/twitter/canonical.

## 2. `src/routes/region.$slug.tsx` — `/region/$slug`

Loader imports `data/regions.json`, validates, finds entry by `params.slug`. If missing → `throw notFound()`.

Route config: `errorComponent`, `notFoundComponent` (paper "Region not found" with link back to `/regions`), `staticData: { prerender: true }`.

`head()` from loader data: `${display} — ${venue_count} venues across ${city_count} cities | CompassEats` + og/canonical.

Layout (max-w-5xl, paper background):

1. **Header**: crumb `← Regions` (BRONZE) · H1 `region.display` (`font-display text-5xl md:text-6xl font-light italic`) · country line beneath in INK_MUTED (omitted when undefined) · small pill "N venues · N cities" with hairline border.

2. **City cards grid**: `grid sm:grid-cols-2 lg:grid-cols-3 gap-4`. One card per `region.cities[i]`. Each card is `<Link to="/city/$slug" params={{ slug }}>`:
   - PAPER surface, hairline border, bronze accent on hover.
   - Heading `city.display` (`font-display text-2xl italic`).
   - Secondary `${venue_count} venues` (INK_MUTED, tabular-nums).
   - If region spans multiple countries (distinct `city.country` values > 1), show `city.country` in tiny muted text under the heading.

   `/cities` itself is an accordion of plain text links with no shared `CityCard` component, so this grid is built inline using the same tokens.

3. **Map**: full-bleed within max-w-5xl, `h-[460px] md:h-[560px]`, rounded with hairline border, BRONZE eyebrow "On the map".
   - Built inline with `maplibre-gl` (CSS already loaded in `__root.tsx`).
   - One marker per `region.cities[i]` at `[lng, lat]`, brass `#C6A15B`.
   - Marker click → `router.navigate({ to: "/city/$slug", params: { slug: city.slug } })`.
   - Hover popup: `city.display` + `${venue_count} venues`.
   - Initial view: `center: [region.center_lng, region.center_lat]`, `zoom: 7`. Free pan/zoom; rotation disabled (matches `VenueMap`).
   - `requestAnimationFrame` + delayed `map.resize()` on mount (same fix as `VenueMap`).

   **Why not `<VenueMap />`:** it consumes `Venue[]`, renders venue popups, has no per-pin navigation hook. City-level navigation pins are a different concern.

## 3. `src/routes/__root.tsx` — header nav

Add `<Link to="/regions">Regions</Link>` between Cities and Guides, identical classes/`activeProps` as the existing two links.

## Confirmation to report when done

(1) `/region/tuscany` URL · (2) Tuscany city card count (34 from `data/regions.json`) · (3) `src/lib/venues.ts` SHA `4039662c…` unchanged.

## Out of scope

No edits to `src/lib/venues.ts` or `src/lib/schema.ts`. No sitemap/robots changes. No shared `CityCard` extraction.
