# Handoff: Open item 1 done (city malfa, two Signum venues). Nov 3, 2026 (19:20 Atlanta). Next: Ben chooses.

This file replaces `handoff-switzerland-open-items-done-2026-11-03.md` for the live state and open items. That file still holds the alias, slug, 2025 URL and blurb results. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 3)
- 18:42 "1" (open item 1). 19:05 "1A, 2A": name "Signum"; `malfa-it` stays. 19:07 "go" (cleanup). 19:18 "Go" (rename and slug).

## Live state (read Nov 4, 00:19:42 UTC, whole tables)
Venues **11,320** (active **11,028**, closed **292**). Awards **25,323**. Michelin 2025 **4,996**, no URL **3,033**. Michelin 2026 **6,524**, no URL **436**. Slugs **13,167** (canonical 11,320, non-canonical **1,847**); 0 venues without exactly 1 canonical slug. Price **7,759** (legacy_guide **2,179**). Listings 11,320. city_label_source 24,047. city_aliases 222. Redirects **10**. Blurbs 142 (rewritten 2, needs_rewrite 140). Cities 3,279, `cities.venues_count` sum 11,028, 0 cities differ from `city_venue_counts`. rename_batches **32** (last id **47**), rename_rows **1,397**. Ledger **199** rows, last id **253**. audit_log **120,038** rows, last id **125,867**. Closed published 0, active not published 0.

## What was wrong
Two restaurants have the name Signum: Mölnlycke, Sweden (Hällsnäs Hotell, Michelin card `signum-1205585`) and Malfa, Salina, Italy (Martina Caruso). Repo snapshot `3d56c74` (Jun 7, 2026, `data/venues.json`) shows 3 rows with one Google place id: Mölnlycke, Sweden (Michelin 2025 Two Stars); Malfa, Italy (Michelin 2025 One Star); Malfa Salina, Italy (OAD 2025 No. 673). Snapshot `4e79226` (Jun 9) put all 3 awards on the Swedish row. Snapshot `9d9f349` (Jun 12) gave it slug `malfa`. `Reshape.gs` holds `'molnlycke': 'malfa'`. Reshape is prohibited, so it was not changed.

## Done
| Write | File (sha256) | How | Audit | Ledger |
|---|---|---|---|---|
| Cleanup | `docs/cleanup-city-malfa-signum-2026-11-03.sql` (`fbb262db9e6210388a64031775b520e991836d1186e708c74257e72d3993cc2f`) | Write connector, first try, Nov 4 00:08:46 UTC | 125,856-125,863 | 250 (michelin, award, 3), 251 (oad, award, 1), 252 (michelin, price, 1) |
| Rename and slug | `docs/rename-signum-molnlycke-2026-11-03.sql` (`41819484663f1d53d9f47b748acdb0e1a6887925bd178e9acc5a50748b404697`) | Write connector, first try, Nov 4 00:19:14 UTC | 125,864-125,867 | 253 (michelin, name, 1) |

Result:
- City `ci_ef76cfb9a4`: slug `molnlycke`, display Mölnlycke. No city has slug `malfa`. `malfa-it` is not changed.
- Venue `ve_a6a92ff828`: name Signum, batch id 47. Canonical `/molnlycke/signum`. `/molnlycke/restaurang-signum` non-canonical. Redirect `/malfa/restaurang-signum` to `/molnlycke/signum`.
- Award 2560 (2025 Two Stars): archive URL, capture 20251215153620, meta names the 2025 guide. Window: ceremony Jun 16, 2025 to ceremony Jun 1, 2026.
- Award 2563 (2026 Two Stars): live card URL. Meta names the 2026 guide.
- Award 2561 (2025 One Star): deleted. Copy of 31915 on `ve_69b7b57435`. Old row in audit 125,861.
- Award 2562 (OAD 2025 No. 673): moved to `ve_69b7b57435`, URL `https://www.oadguides.com/lists/europe/top-restaurants/2025`. The list prints Signum, Malfa Salina, Italy, Martina Caruso.
- Price `ve_a6a92ff828`: `$$$$` legacy to `€€€€` card (tier 4, EUR, guide_ingest). Sep 28 ruling.

Files: `docs/open-items-malfa-2026-11-03-build/` (`relay-signum-2026-11-03.txt` sha256 `f54ca0b02b428889b2a5a055bdc86b89207d3aa5c219340a098dce40524ac3bc`, `build_cleanup_malfa.py`, `build_rename_signum.py`), `fixtures/rename/signum-molnlycke-2026-11-03.csv` (`bac880d8...d45f`).

## Limits
- The Sheet and the static `data/` files still hold slug `malfa` and name Restaurang Signum.
- The venue's English page prints "Restaurant Signum" and "Menu Signum". No Swedish page was read.
- No city label was added on the Italian venue for OAD. Alias `malfa salina` stays deleted. If an OAD batch prints that label, it needs a decision.
- OAD Europe 2026 was not checked for Signum. The permission check refused an archive read of an OAD list; the public OAD page was read directly.
- Michelin's 2024 One Star on the Swedish card is real history and has no row (no 2024 rows in scope). Green Star 2025: no column.

## Open items
1. **New: other merged Google place ids.** Population: `3d56c74` snapshot, 11,176 rows, 9,862 ids. 617 ids are in more than 1 city slug, 260 ids in more than 1 country. Many are real groups, label noise or fixed by later work (examples: Jungsik, Da Vittorio, Sushi Sho, Noor, Pierre Gagnaire). The count on live venues is not read. The signal that found Signum: a label in the snapshot that disagrees with the live venue's city.
2. "The Tailory New York - Custom Suits NYC - Bespoke Tailor®" `ve_d1e61a315d`: active venue, name of a suit shop, award 15336 (World's 50 Best Bars 2009 No. 49). Not read further.
3. 26 aliases with a venue filed under a neighbor city: Ben decides if any city split is wanted.
4. 48 Swiss 2025 rows with no capture; **3,033** Michelin 2025 rows with no URL across all guides.
5. 140 blurbs `needs_rewrite`.

## Recheck list (unchanged)
Sonne Scheunenberg `ve_1ff8df1642`: Ben opens the site. Ling Ling after Nov 5, 2026; Colani Bistrot Nov 27; After Seven Dec 2; Scalottas Terroir Dec 9; Ô Bois Sauvage and The Grill at Amangani Jan 2027. No scheduled task holds these dates.

## Methods (new)
- **Find how a bad row formed:** `git fetch --depth=1000 origin main`, then parse `data/venues.json` at each commit that changed it (`git log -- data/venues.json`) and print the rows on a change. Early snapshots keep the publisher's label.
- **City slug change:** update `cities.slug`, update the slug row in place, add a redirect (Sep 14 form). `slugs.city_slug` has no foreign key. `redirects` has no trigger: hand audit row.
- **Second file that depends on the first:** its guards need the state after the first file, so its dry run comes after the first commit.
- **Relay by hand with `\u` escapes:** the Bash heredoc I wrote held decoded text. Compare each line with the browser hash, and re-escape non-ASCII in Python.
- **Stop hook:** it can ask for a push when the branch is already on the remote. Check with `git ls-remote`.

## Suggested opening prompt
```
Read claude/handoff-malfa-signum-done-2026-11-03.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 253,
audit_log 125,867, venues 11,320 (active 11,028, closed 292), awards 25,323, slugs 13,167, price 7,759, city_aliases 222, redirects 10, closed published 0 and cities.venues_count sum 11,028.
Then start the open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
