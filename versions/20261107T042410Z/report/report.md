# Publish build 20261107T042410Z

**Result: PASS.** All 9 gates passed. The version folder `versions/20261107T042410Z/` is written. The preview does not point at it until you run **Publish — promote**.

| Item | Value |
|---|---|
| Built at (UTC) | 2026-11-07T04:24:10Z |
| Code (git sha) | `f99bc530308750a93f805fb138007e0be6fa5553` |
| Database read at (UTC) | 2026-11-07T04:24:10Z |
| Database transaction | repeatable read, read only = on |
| source_capture_ledger last id | 376 |
| audit_log last id | 135045 |
| Note |  |

## Gates

| Gate | Result | Detail |
|---|---|---|
| `venue_count_matches_database` | pass | files 11510 (index.json 11510, city files 11510); database active venues with a published eats listing 11510 |
| `one_canonical_slug` | pass | all 11510 venues hold exactly 1 canonical eats slug |
| `city_exists` | pass | all 11510 venues name a city that exists |
| `no_closed_venue` | pass | 0 of 11510 venues in the files are closed |
| `no_suspended_source` | pass | every source in the files is active (23 of 23 registered sources active) |
| `no_google_value` | pass | 0 Google ids, URLs or sources in 3279 files |
| `no_duplicate_michelin` | pass | 0 venues hold 2 Michelin rows of one year and category |
| `no_large_decrease` | pass | 20261107T033856Z: 11510 -> 11510 (change 0, limit 0.5%) |
| `redirect_from_unique` | pass | 1957 redirects, each from address once (2 old slugs already in the redirects table with the same answer, written once) |

## Files

| File | Rows | Population |
|---|---|---|
| `index.json` | 11,510 | 1 row per venue with a published eats listing |
| `venues/<city>.json` | 3,274 files, 11,510 venue rows | 1 file per city with a published venue |
| `cities.json` | 3,274 | cities with a published venue (counts made by this job) |
| `regions.json` | 112 | regions with a city that has a published venue |
| `redirects.json` | 1,957 | redirects table 35 + old slugs of published venues 1,922 |
| `attribution.json` | 21 | sources with at least 1 row in the files |

Data files: 3,279, 13,527,914 bytes. The folder also holds `report/` and `manifest.json` (3,288 files in all). Content hash of the data files: `3aca439f5764bf656e5c56d6dfe90b6495fc0e771a75e7c69cab2ac202689783`. `manifest.json` lists the sha256 of every file.

## Counts

| Item | Count | Population |
|---|---|---|
| Venues | 11,510 | venues with a published eats listing |
| Restaurants / bars | 10,516 / 994 | the same venues |
| Award rows | 28,274 | all years, active sources, on those venues |
| Award rows with no source URL | 14,045 | the same award rows |
| Venues with a price | 7,690 | the same venues |
| Venues with a blurb | 2 | the same venues (rule Q4) |
| Venues with no award row | 2 | the same venues |
| Cities with a published venue but no region | 2,054 | 3,274 cities in cities.json |

## Left out on purpose

| What | Count | Why |
|---|---|---|
| Award rows from a source that is not active | 0 | D10 suspension switch |
| Price rows from a source that is not active | 0 | D10 suspension switch |
| Cuisine tags from a source that is not active | 0 | D10 suspension switch |
| Blurbs with status needs_rewrite | 140 | rule Q4 |
| Blurbs on a venue with no published listing | 0 | venue not published |
| Old slugs of a venue with no published listing | 20 | no page to send them to |
| Old slugs the redirects table already sends to the same page | 2 | one answer, written once (the table row) |
| `geo` rows (0 on published venues) | 0 | read and counted only; the published shape is a Phase 3 decision |
| `addresses` rows (0 on published venues) | 0 | read and counted only; the published shape is a Phase 3 decision |
| `hours` rows (0 on published venues) | 0 | read and counted only; the published shape is a Phase 3 decision |
| `photo_refs` rows (0 on published venues) | 0 | read and counted only; the published shape is a Phase 3 decision |

## Checks (reported, not gates)

- Venue address uses a city slug that is not the venue's city: 1. `ve_bb17fb8774 /vail-and-beaver-creek-colorado/mirabelle (city beaver-creek-colorado)`
- Cities where this job's count differs from `cities.venues_count` (population: all 3,344 cities): 0. none
- Venues with no award row: 2. `ve_514f90f364`, `ve_86b759e5f5`
- Redirects whose from address is also a venue page: 0. none
- Redirects whose to address is not a venue page in this version: 1. `/cham/the-dining-room -> /cham-ch/the-dining-room`

## Exposure (D10)

Population: the `source_exposure` view (whole tables) and the rows in this version. No cap gate (choice 8). Full table: `report/exposure.csv`.

| Publisher | Field | In database | In this version |
|---|---|---|---|
| 101-best-steakhouses | award | 201 | 201 |
| asia-50-best-bars | award | 590 | 571 |
| asia-50-best-restaurants | award | 587 | 571 |
| best-chef-awards | award | 1,300 | 1,251 |
| europe-50-best-bars | award | 50 | 49 |
| forbes-travel-guide | award | 1,309 | 1,268 |
| gault-millau | award | 378 | 355 |
| gault-millau | price | 1 | 1 |
| james-beard | award | 209 | 196 |
| la-liste | award | 1,309 | 1,278 |
| la-liste | price | 1 | 1 |
| latin-america-50-best-restaurants | award | 498 | 478 |
| mena-50-best-restaurants | award | 250 | 233 |
| michelin | award | 12,375 | 12,250 |
| michelin | price | 7,132 | 7,087 |
| north-america-50-best-bars | award | 349 | 346 |
| north-america-50-best-restaurants | award | 100 | 100 |
| oad | award | 5,296 | 5,105 |
| oad | price | 1 | 1 |
| pinnacle-guide | award | 195 | 192 |
| spirited-awards | award | 124 | 119 |
| top-500-bars | award | 1,488 | 1,454 |
| wine-spectator | award | 98 | 98 |
| wine-spectator | price | 1 | 1 |
| worlds-50-best-bars | award | 1,097 | 1,014 |
| worlds-50-best-restaurants | award | 1,249 | 1,145 |

## Blurb coverage

Population: all 142 blurb rows. needs_rewrite 140, rewritten 2. Published: 2. Rule Q4: publish only blurbs whose status is not `needs_rewrite`. Rows: `report/blurbs.csv`.

## Change from the last version

Against `20261107T033856Z`. Population: venues in either version. Added 0, removed 0, changed 0, same 11,510. Rows: `report/diff.csv`.

## Compare with the live site file

Population: the 10,551 live pages (rows with status active in `data/venues.json`, 10,912 rows in all), and the 11,510 venues in this version. Address = `/<city_slug>/<slug>`. Rows: `report/compare-live.csv`.

| Group | Venues |
|---|---|
| Live page and published in the database, same address | 8,976 |
| Of those, name differs | 432 |
| Live page, closed in the database | 52 |
| Live page, address is an old (non-canonical) slug | 1,367 |
| Live page, no slug row | 156 |
| Live page, open in the database but not published | 0 |
| Published in the database, no live page | 2,534 |

Fields the live file has, against these files (population: live pages; venues in this version):

| Field | Live pages with it | Venues in files with it | Note |
|---|---|---|---|
| coordinates (lat, lng) | 10,551 | 0 | Live values are Google (D4/D6 keep them out). geo rows on published venues: 0. Phase 3. |
| street address | 10,551 | 0 | Live values are Google. addresses rows on published venues: 0. Phase 3. |
| cuisine tags | 8,430 | 0 | venues.cuisine_tags is empty on every row in the database. |
| price | 6,997 | 7,690 | Files: price rows from the database (tier, symbol, currency, publisher). |
| blurb | 9,638 | 2 | Files: blurbs whose status is not needs_rewrite (rule Q4). |
| awards (at least 1) | 10,551 | 11,508 |  |
| venue id is a Google place id | 10,551 | 0 | Files use ve_ ids only. |

## Weak points

- The live compare reads the repo file, not the deployed pages.
- The files have no map points and no street addresses until Phase 3 fills `geo` and `addresses`.
