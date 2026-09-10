# Handoff: Batch C, Batch D, country backfill, Plan v1.16
2026-09-10 · Sonnet-class execution chat working from `handoff-response-award-audit-2026-09-10.md`. Written for Ben and for the next chat that continues the award backfill or the Phase 2 ingest job.

## Objective
Close the 55 true-missing award rows found by the coverage audit, apply fixes 3 and 4, run the country_iso interim backfill, and fold the Sep 10 rulings into Plan v1.16.

## Current state (end of session)
Live counts, read back after the last commit. Population: whole table.

| Table | Start of day | Now |
|---|---|---|
| venues | 10,878 | 10,899 |
| awards | 21,764 | 21,805 |
| listings | 10,878 | 10,899 |
| slugs | 11,135 | 11,156 |
| cities | 3,176 | 3,177 |
| cities with country_iso | 0 | 3,155 |
| awards with source_url | 3 | 45 |

Plan v1.16 is written: `CompassEats-Rearchitecture-Plan.html` in this session's outputs. Save to repo `docs/` and re-upload to Project Knowledge.

## Writes executed (Supabase Write, one transaction each, one "go" each)
1. **Batch C narrow.** 5 World's 50 Best Bars rows for The NoMad Bar (`ve_71c4221be3`, 2015 #36, 2016 #8, 2017 #3, 2018 #4, 2019 #4). Fix 4: award id 15471 moved from `ve_514f90f364` (hotel) to `ve_885707af72` (Le Louis XV). awards 21,764 → 21,769.
2. **Country backfill.** 3,149 unanimous cities plus 6 policy cities (hong-kong HK, macau MO, taipei TW, lima PE, milan IT, naples IT). Map: 121 label strings, 0 unmapped. 21 cities left blank on purpose.
3. **Batch D.** New city `sant-celoni` (ES). 21 closed venues as minimal rows, each with a listing (`published=false`) and a canonical slug, plus 26 `city_label_source` rows (note `batch D 2026-09-10`). 36 award inserts. Fix 3: award id 15462 moved from Madame Vo (`ve_86b759e5f5`) to the new Vong row. IDs minted as `ve_` + md5(`city_slug:slug`)[:10]. Batch D committed on the fourth attempt; the first three failed before commit and changed nothing (see lessons).

New venue ids can be recomputed from the mint rule. Slugs: shoun-ryugin, friends-and-family, genever, milk-room, hacha-agaveria, the-violet-hour, the-honey-moon, double-deuce-lounge, bar-margaux, 686-bar, bank-bar, a-bar-called-gemma, little-cooler, baragricole, papa-doble, vong, susar, le-gavroche, can-fabes (city sant-celoni), wd-50, chez-dominique.

## Decisions (Ben, Sep 10)
- San Juan is a slug split, not a per-city policy. Held with the other 8 split cities.
- Can Fabes gets a new city row, Sant Celoni, not Barcelona.
- Susar keeps the publisher spelling "Susar" (name rule: award-source name).
- The four weaker closed verdicts (Genever, The Honey Moon, 686 Bar, Papa Doble) were included. A wrong "closed" only keeps a venue unpublished.
- No iconic exception taken; all 21 new rows are `published=false`.

## Sources established
- **Publisher archive for W50B Restaurants:** `https://www.the50.com/restaurants/best-in-the-world/previous-list/<year>`. One page holds every year 2002–2024 with full ranks, and ranks 51–100 for 2023 and 2024. All 23 joinpearl-only rows matched it. Use it for the whole 2002–2011 verification and the 51–100 backfill.
- Wikipedia has no per-year pages for 2002–2011. Do not send a job there again.
- Cowork output: `batch-d-verification-worklist-filled.csv` and `batch-d-verification-log.md` in Drive "CompassEats Staging".

## Open items
- **9 rows, 7 open venues → Phase 2 ingest job:** Brabo (steakhouses 2026 #101), Corner House (Asia 2019 #49), Malabar Lima (LatAm 2019 #48), Ralph's Bar Chengdu (Top 500 2024 #417), REM Rome (Top 500 2024 #458), Café Arixi (Top 500 2025 #124), Guy Savoy Paris (W50B 2003 #30, 2004 #6, 2005 #16). Source URLs are in the filled worklist.
- **4 rows, unknown status:** Restaurante 040 Santiago (LatAm 2019 #37, 2020 #41), Woda Ognista Warsaw (Top 500 2024 #469), Casa Prunes Mexico City (Top 500 2025 #415). Need a compliant status source before a row is made.
- **Salvatore at Playboy, W50B Bars 2012:** PDF says rank 45, diff says 46. Part of defect 2 (the 2012 Bars block is off by 1–3 at 18 ranks). Resolve the block, not the row.
- **Fix 1, La Cúpula de El Capricho:** waits for the ingest job, then move steakhouses 2026 rank 1 off Bodega El Capricho (`ve_c1cc29d546`).
- **Country blanks, 21 cities:** 9 slug splits (san-jose, san-juan, cartagena, cham, lichtenberg, pigna, rust, richmond, oxford) and 12 no-label cities with 0 live venues (alsace, beersel, torrence, brevard-north-carolina, cashiers-north-carolina, franklin-north-carolina, highlands-north-carolina, lake-tahoe-california, lake-toxaway-north-carolina, sapphire-north-carolina, vail-colorado, yosemite-california).
- **Cleanup flags:** Madame Vo `ve_86b759e5f5` holds 0 awards (closed-venue sweep, no delete). `cities.venues_count` is stale on existing rows (New York 347 vs 361 live). `torrence` has `venues_count` 1 and 0 live venues.
- **Plan file provenance:** the Project Knowledge copy of the plan was v1.14. v1.16 was built on it with the 1.15 changelog row restored from the Aug 24 record. If a real v1.15 file exists, re-apply the Sep 10 addendum and the 1.16 row onto it.
- **Name contamination:** 585 candidate rows (`name-contamination-candidates.csv`), not yet actioned. 170 need a second source.

## Dead ends and lessons
- `venues.norm_key` is a generated column. Never insert it.
- Enum columns (`label_column_t`) need an explicit cast inside a `UNION`.
- `cities` also has a `slug` column; qualify column names when joining a temp table to it.
- A failed statement inside `BEGIN … COMMIT` rolls back the whole batch. Read counts back before any retry.
- theworlds50best.com year URLs ignore the year. the50.com previous-list does not.

## Working preferences (unchanged)
Ben on a phone. Short, plain, /ste for data replies. One "go" per batch. Expected counts before, actual after. Every count states population and grouping key. Under-merge beats over-merge. Competitor sites are never a source.

## Suggested next step
Phase 2 ingest job (first deliverable). Its first batch: the 7 open venues above plus La Cúpula. Then Michelin 2026 after the brief.
