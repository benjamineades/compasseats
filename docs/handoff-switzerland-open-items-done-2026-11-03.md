# Handoff: Swiss open items 1-4 done (aliases, slugs, 2025 URLs, Cheval Blanc blurb). Nov 3, 2026 (18:40 Atlanta). Next: Ben chooses.

This file replaces `handoff-switzerland-price-backfill-cleanup-done-2026-11-03.md` for the live state and open items. That file still holds the price, backfill and cleanup results. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Blurb method: `handoff-forum-blurb-done-2026-11-01.md`, `docs/CompassEats-OptionB-Pipeline-Runbook.md`.

## Ben's input (ET, Nov 3)
- 17:08 "Lets do all 4. You pick the order." (order: 1, 2, 4, 3)
- 18:10 "1A,2A, 3A, 4A": delete all 40 aliases; change all 22 slugs; fill 177 URLs and leave 48 blank (exception to ruling condition 5 for a URL fill on existing rows); blurb as drafted, database only.
- 18:20 "go" (aliases). 18:29 "done" (SQL Editor). 18:29 "go" (slugs). 18:30 "go" (URLs). 18:36 "go" (blurb).

## Live state (read Nov 3, 23:37:24 UTC, whole tables)
Venues **11,320** (active **11,028**, closed **292**). Awards **25,324**. Michelin 2025 **4,997**, no URL **3,035**. Slugs **13,166** (canonical 11,320, non-canonical **1,846**). Price **7,759** (legacy_guide 2,180). Listings 11,320. city_label_source 24,047. city_aliases **222**. Blurbs 142 (rewritten **2**, needs_rewrite **140**). Cities 3,279, `cities.venues_count` sum **11,028**, 0 cities differ from `city_venue_counts`. rename_batches 31, rename_rows 1,396. Ledger 195 rows, last id **249**. audit_log 120,026 rows, last id **125,855**. Closed published 0, active not published 0.

## Done
| Write | File (sha256) | How | Audit | Result |
|---|---|---|---|---|
| Aliases | `docs/cleanup-city-aliases-2026-11-03.sql` (`2be5579d...b5c2`) | Ben, SQL Editor, 23:29:32 UTC (Write connector question got no answer in 230 s, nothing ran) | 125,594-125,633 | 40 deleted, 262 to 222; no ledger row |
| Slugs | `docs/slugs-letters-removed-2026-11-03.sql` (`fc5392ae...8b9e`) | Write connector, first try, 23:30:14 UTC | 125,634-125,677 | 22 new canonical; old slugs non-canonical; no ledger row |
| 2025 URLs | `docs/source-url-michelin-2025-switzerland-cards.sql` (`3f91f6a2...e7a3`) | Write connector, first try, 23:32:41 UTC | 125,678-125,854 | 177 rows; ledger 249 (michelin, award, 177) |
| Blurb | `docs/rewrite-blurb-cheval-blanc-v2.sql` (`06b75bc2...a8e8`) | Write connector, first try, 23:37:12 UTC | 125,855 | `ve_46e15d96d7` v2, `rewritten`, 3 sources; no ledger row |

Build files, evidence and run record: `docs/open-items-ch-2026-11-03-build/` (`alias-check-262.csv`, `url-evidence-ch-2025.csv`, `relay-ch-2025-cards-archive.txt`, `run-record-2026-11-03.txt`).

### Aliases deleted (40). Each had 0 city labels and 0 Michelin card segments, and 0 hits in 32 fixture files.
Country 8: argentina, canada, france, ireland, mexico, united states, us, usa. Region 9: friuli venezia, gipuzkoa, grisons, huelva, powys, rugen, sicily, south wales, udine. Wrong place 4: malfa salina, sankt niklausen, vernazza, windermere. Separate town 19: blackburn, collingwood, cupar, exmouth, grange over sands, hexham, hythe, iwade, lamporecchio, lens, maidenhead, monmouth, moutfort, nonoichi, ormskirk, sedlec u mikulova, silvaplana, sorengo, suita.
Kept: 26 in use with the venue filed under a neighbor city (for example miami beach, cornaredo, grasmere; class in the CSV). Limit: place classes come from general knowledge; only St. Niklausen was checked against sources.

### Slugs
Population: 52 venues with ø, æ, œ, ß or đ in the name; 22 slugs differed from the f_unaccent slug. L'IØDE also loses "restaurant-" (`restaurant-l-i-de` to `l-iode`). The Tailory (®) is not in the set.

### 2025 URLs
Population: 225 rows, CH 224 + LI 1 (Three 4, Two 22, One 103, Bib 96). Capture 177 (4 / 22 / 90 / 61), none 48 (0 / 0 / 13 / 35). Test: timestamp 20251020-20261022 (2025 ceremony Oct 20, 2025; 2026 Bib list Oct 23, 2026); meta names 2025 and the row category. 177 of 177 passed. Stucki 1550 found at `stucki-tanja-grandits` (not on the Nov 2 morning list; capture Oct 4, 2026 names the 2025 guide and Two Stars). The 48 stay blank; list in `url-evidence-ch-2025.csv`. CH/LI Michelin 2025 rows now 229, no URL 48.

### Blurb
Sources: Michelin card (live, read in the built-in browser; text cut short), MySwitzerland, Swiss Deluxe Hotels. Removed: Bresse pigeon, antiques and chandeliers, "for years", "one of the most consistent anywhere". Sheet, `ImportOptionB.gs` and `venues.chef` (NULL) are not changed; the Sheet still holds the old text under the Trois Rois name.

## Open items
1. City `malfa` `ci_ef76cfb9a4`: slug `malfa`, display Mölnlycke, Sweden. Restaurang Signum `ve_a6a92ff828` has Michelin rows 2560, 2561, 2563 with no URL (One Star and Two Stars 2025, Two Stars 2026) and no card. Italian Signum `ve_69b7b57435` is in `malfa-it`. Not read further.
2. "The Tailory New York - Custom Suits NYC - Bespoke Tailor®" `ve_d1e61a315d`: active venue, name of a suit shop, award 15336 (World's 50 Best Bars 2009 No. 49). Not read further.
3. 26 aliases with a venue filed under a neighbor city: Ben decides if any city split is wanted.
4. 48 Swiss 2025 rows with no capture; 3,035 Michelin 2025 rows with no URL across all guides.
5. 140 blurbs `needs_rewrite`.

## Recheck list (unchanged)
Sonne Scheunenberg `ve_1ff8df1642`: Ben opens the site. Ling Ling after Nov 5, 2026; Colani Bistrot Nov 27; After Seven Dec 2; Scalottas Terroir Dec 9; Ô Bois Sauvage and The Grill at Amangani Jan 2027. No scheduled task holds these dates.

## Methods (new)
- **Write connector confirmation:** it can ask a question. No answer in 230 s = timeout, nothing runs. Tell Ben to answer within about 3 minutes. Files with no DELETE ran with no wait.
- **CDX prefix per region is too slow** (503 on most large regions). Exact URL per card, one at a time, worked: 221 cards in about 35 minutes, 62 503s. Language order: en, us/en, ch/de, ch/fr, ch/it, ch/en, gb/en; second pass de/de, fr/fr, it/it, at/de, ca/en, sg/en found 2 more.
- **Long job in the browser:** run an async loop on `window`, poll with short calls.
- **Large plan in a file:** one jsonb constant in `DECLARE`, read by `jsonb_array_elements`, keeps the file small. Gate on the md5 of the plan.
- **Find a slug with a lost letter:** compare the canonical slug with the f_unaccent slug on names that hold ø, æ, œ, ß, đ, ł, ð, þ, ı, ŋ.
- **Alias test:** normLabel of labels (whole, and part before the first comma; no country labels), Michelin card segment, other city with the same name, fixture scan.
- `audit_log` has no trigger on `city_aliases`: hand rows.

## Suggested opening prompt
```
Read claude/handoff-switzerland-open-items-done-2026-11-03.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 249,
audit_log 125,855, venues 11,320 (active 11,028, closed 292), awards 25,324, slugs 13,166, price 7,759, city_aliases 222, closed published 0 and cities.venues_count sum 11,028.
Then start the open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
