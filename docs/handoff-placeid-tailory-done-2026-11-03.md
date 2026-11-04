# Handoff: Open items 1 (first part) and 2 done. Tailor, 6 award moves, 5 new venues, Naples Florida. Nov 3, 2026 (20:30 Atlanta). Next: Ben chooses.

This file replaces `handoff-malfa-signum-done-2026-11-03.md` for the live state and open items. That file still holds the Signum result and its methods. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 19:52 "1 & 2". 20:14 "1A, 2A, 3B, 4A, 5A". 20:23 "go".

## Live state (read Nov 4, 01:26:12 UTC, whole tables)
Venues **11,325** (active **11,032**, closed **293**). Awards **25,323**. Michelin 2025 4,996, no URL **3,029**. Michelin 2026 6,524, no URL **434**. Slugs **13,173** (canonical 11,325, non-canonical **1,848**). Price 7,759 (legacy_guide 2,179). Listings 11,325. city_label_source **24,057**. city_aliases 222. Redirects **11**. Blurbs 142. Cities **3,280**, `cities.venues_count` sum **11,032**, 0 cities differ from `city_venue_counts`. rename_batches **33** (last id **48**), rename_rows **1,398**. Ledger **205** rows, last id **259**. audit_log **120,092** rows, last id **125,921**. Closed published 0, active not published 0.

## Done
`docs/fix-placeid-tailor-2026-11-03.sql` (sha256 `f5b591e643d5616ebd0c4604a0c891cbc84136ab6f4a6b10e89ccbddc081a6cb`). Write connector, first try. Audit 125,868-125,921. Ledger 254-259. Rename batch id 48, fixture `fixtures/rename/tailor-new-york-2026-11-03.csv`. Fresh clone hash correct.

- **Tailor `ve_d1e61a315d`:** was "The Tailory New York - Custom Suits NYC - Bespoke Tailor®". Closed, published false. Canonical `/new-york/tailor`. Old slug non-canonical. Award 15336 has the 50 Best URL. 50 Best prints Tailor, New York, 2009 No. 49. Punch: closed November 2009.
- **Award moves (6), each with a URL:** 15683 Asia 2026 No. 65, Ensue to Fumée `ve_38916224da`. 16923, 16921 OAD, L'Atelier to Joel Robuchon `ve_273774c457`. 17153, 17151 OAD, Fiola Mare to Fiola `ve_842d853e13`. 3422 OAD, Sukiyabashi Jiro to Roppongiten `ve_175f7d63c2`.
- **New venues (5), Bib rows moved with a URL:** Wörgötter - Wirtshaus `ve_3019edc0d9` (5938). Schlosskeller Wirtshaus `ve_d3fd2ae165` (5898). Tai Wah Pork Noodle `ve_677a6f224a` (8214). FAGN-Bistro `ve_754faabbde` (12737, 12739; 2025 capture 20250813153751 names the 2025 guide). Vyn Food & Wine Bar `ve_431ae3ca78` (3142).
- **Bleu Provence `ve_732d5cc78a`:** new city `ci_9072b5c1e5`, `naples-fl`, "Naples, Florida". Redirect `/naples/bleu-provence`. Award 21794 has no URL: the Wine Spectator page does not print 2026.

Evidence: `docs/open-items-placeid-tailory-2026-11-03/placeid-tailory-evidence-2026-11-03.csv` (31 rows, sha256 `c1c9514a...0395`), with `relay-far-rows-2026-11-03.txt` and the build scripts.

## How the tests read
- **Two ranks in one list.** Population: all awards, grouped by venue, source, year. 20 pairs (OAD 19, Asia's 50 Best 1). Compared with the publisher's list.
- **Bib and star in one Michelin year.** Population: all Michelin awards. 5 venues before, 0 after. Green Star and special awards are not in this test.
- **Country label against city.** 483 label rows disagree, nearly all spelling. 5 real.
- **Snapshot `3d56c74`.** 617 multi-city ids, 1,451 rows. 653 rows with awards have a label city more than 50 km from the Google place (1,408 awards). Live: same city 1,064, within 50 km 40, only farther than 50 km 176, no match 128. The 176 were read by eye. The 128 were not read one by one.
- These tests do not prove that no other merge exists.

## Open items
1. **A2: 12 OAD rows held (Ben 3B).** The list names a restaurant with no live venue. In the evidence file: Masa (2670, 2668, on Bar Masa), Gari (17234, 17232, on Sushi of Gari 46), Da Niko (18439), Moi Omakase (6339), Buca Yorkville (17532), Mitani (18648), Yakitori Kurosaki (18695), Yamasaki (18713), Saeki Hanten (18846), Jean Georges Shanghai (18127). 10 new venues if Ben agrees. Each needs a status read.
2. **A3:** Sushi Saito Hong Kong 18027: OAD prints the venue at No. 21 and No. 354. Tempura Yamanoue 19033: OAD prints "Tempura Yamanoure" at 498 and "Yama no Ue" at 590. Not settled.
3. **Group D, held (Ben 5A):** OAD prints Kabuki "Milan, Spain" (chef Ricardo Sanz), Carmen "Lima, Colombia" (Carmen Angel; live Carmen Medellín `ve_6cd9c1b505` holds bar awards), Fiesta "Lima, Argentina" (Germán Sitz & Pedro Peña). Next: read OAD 2026 and the venues' own sites.
4. **Merged venues left as they are:** Restaurant Wörgötter, Schlosskeller Südsteiermark, Fagn, Vyn Restaurant keep their names and prices. Michelin prints other names for the star restaurants. An old price can belong to either restaurant (Fagn `$$`). Fagn has no 2025 One Star row. New venues have no price and no 2026 row where a card shows the 2026 guide (Tai Wah, Wörgötter - Wirtshaus; Schlosskeller card shows no edition).
5. **Missing 2025 rows:** 22 venues in a snapshot label city have a Michelin 2026 row and no 2025 row (Agora London, Bagatelle Dole, Berenjak London, Cadet London, Da terra Nara, Da Vittorio Shanghai, El Gato Negro Manchester, Home Belfast, Hoppers London, Hoppers Tokyo, ima Kyoto, Imperial Treasure Shanghai, La Bécasse Osaka, Là-Haut Annecy, Masuda Osaka, Ogawa Kyoto, ShinoiS Tokyo, Sorrel San Francisco, Sushi Matsumoto Kyoto, TOKi Tokyo, YUNiCO Osaka, Zur Post Saint-Vith). Not checked against Michelin. Same family as item 7.
6. 26 aliases with a venue filed under a neighbor city: Ben decides if any city split is wanted.
7. 48 Swiss 2025 rows with no capture; **3,029** Michelin 2025 rows with no URL across all guides.
8. 140 blurbs `needs_rewrite`.

## Recheck list (unchanged)
Sonne Scheunenberg `ve_1ff8df1642`: Ben opens the site. Ling Ling after Nov 5, 2026; Colani Bistrot Nov 27; After Seven Dec 2; Scalottas Terroir Dec 9; Ô Bois Sauvage and The Grill at Amangani Jan 2027. No scheduled task holds these dates.

## Limits
- The Sheet and the static `data/` files still hold the old rows. No live page changed.
- New venue names come from Michelin. No venue's own site was read for them.
- Group D and A3 rows have no URL.

## Methods (new)
- **Live merge tests are cheap and sharp:** same source and year twice on one venue, then compare each rank with the publisher's list. Do this before a snapshot test.
- **OAD lists:** browser, `/lists/<region>/top-restaurants/<year>`. Regions read: europe, north-america, asia, japan, south-america (`latin-america` gives a 404). In the page, split `innerText` by line: rank, name, city, chef.
- **Large test against the database without files:** JSON blob in a dollar-quoted string, `md5(blob)` returned by the query, compared with the Python hash. All 4 parts matched first try.
- **Dry run:** end the `DO` block with `RAISE EXCEPTION 'DRY RUN...'` before the first write. This needs no write statement in the block.
- **Live `cities` has no lat/lng** (3,279 of 3,279 null). Use `data/cities.json` for distance.
- **Hash in the same Python run:** close the file before the hash. An empty file hash is `e3b0c442...`.
- **Stop hook:** it asked for a push when the branch was on the remote. Check with `git ls-remote`.

## Suggested opening prompt
```
Read claude/handoff-placeid-tailory-done-2026-11-03.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 259,
audit_log 125,921, venues 11,325 (active 11,032, closed 293), awards 25,323, slugs 13,173, price 7,759, city_aliases 222, redirects 11, closed published 0 and cities.venues_count sum 11,032.
Then start the open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
