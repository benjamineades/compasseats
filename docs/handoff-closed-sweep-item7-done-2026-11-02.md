# Handoff: closed-venue sweep item 7 done. 17 temporary closures read again, no write. Nov 2, 2026 (15:55 Atlanta).

This file replaces `handoff-closed-sweep-item6-done-2026-11-02.md` for live state. That file still holds the older recheck groups and the findings of item 6. `handoff-closed-sweep-twins-renames-done-2026-11-02.md` still holds the rechecks from items 1 and 2. `handoff-closed-sweep-201-done-2026-11-02.md` still holds items 3, 4 and 5. The closed rule and the oldest recheck list are in `handoff-closed-rule-done-2026-11-02.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. Trusted sources: `trusted-websites.md`.

## Ben's input (ET, Nov 2)
- 15:52 "1A, 2A, 3A, 4B, 5A".
  - 1A = Group A recheck dates as in the table below.
  - 2A = Gravitas and Dulce Patria move to closure evidence, no recheck. Restoran Alexander stays on the list until the manor sells.
  - 3A = Ling Ling stays closed, recheck the Atlantis page and booking after Nov 5.
  - 4B = Ô Bois Sauvage stays closed, read it again in the Swiss batch.
  - 5A = close item 7 with no SQL, commit the evidence file and this handoff.

## Live state (read Nov 2, 20:52:31 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,293 (active **10,996**, closed **297**) |
| closed venues published | **0** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs | 13,021 |
| price | 7,727 |
| cities.venues_count | sum **10,996** |
| source_capture_ledger | last id **238** |
| audit_log | **118,844** rows, last id **124,358** |

Item 7 changed no database row. Listings 11,293 and cities 3,264 come from the first read of this session (20:39:15 UTC).

## Done
Evidence for all 17: `docs/closed-sweep-2026-11-02/closed-sweep-item7-evidence-2026-11-02.csv` (sha256 `2e302739...36944d`). Note: the `verdict_recheck` column gives the read. This file gives Ben's decisions.

## Population and result
The 17 = Group 10 of the 201 (`closed-sweep-201-evidence-2026-11-02.csv`). Id-list md5 `ed2fcdf047ddc799fb9beb631412f97b` (ids sorted, joined with commas). All 17 closed and not published before and after. Same-city name-word twin check: 0 active matches.

| Group | Venues | Result |
|---|---|---|
| A Temporary closure confirmed | 12 | Closed, recheck by date |
| B Closure looks permanent | 3 | Closed. 2 no recheck, 1 recheck on sale |
| C Sources disagree | 2 | Closed, recheck (conflict rule) |

## Recheck list from item 7
| Venue | Id | Recheck after |
|---|---|---|
| Ling Ling | `ve_7468e70280` | **Nov 5, 2026.** Atlantis page and booking. Clubbable lists Thursdays from Nov 5. Forbes note still says temporarily closed |
| Tayēr + Elementary | `ve_40e59554e1` | Jan 2027 |
| The Shota | `ve_68da95719e` | Jan 2027 |
| Restaurante Manzil | `ve_13325dcc24` | Jan 2027 |
| La Mar by Gaston Acurio, Dubai | `ve_ba53bf3e87` | Jan 2027 |
| The Club Grill & Jazz Supper Club | `ve_fb966ee823` | Jan 2027 |
| Aürt | `ve_27266639a6` | Jan 2027 |
| Fusions | `ve_34a57ed68c` | Jan 2027 |
| Ōre | `ve_1b077db3b8` | Jan 2027 |
| Aulis Hong Kong | `ve_ccb4ab70dc` | Jan 2027 |
| Chat-Botté | `ve_5a6018ab72` | Jan 2027 |
| Al Muntaha | `ve_d35cc76459` | Oct 2027 |
| Ristorante L' Olivo at Al Mahara | `ve_d2c67e7d3d` | Oct 2027 |
| Restoran Alexander | `ve_cd4a28a835` | When Pädaste Manor sells (for sale May 12, 2026, no buyer named) |
| Ô Bois Sauvage | `ve_9503403a2a` | Swiss batch, after Ben's "results live" |

No scheduled task holds these dates. Read this table at each start.

Off the list (closure evidence, no recheck): Gravitas `ve_e3cd43f5af`, Dulce Patria `ve_d28e7d6c06`.

## Limits
- The page reads came through the web-fetch tool, as short reports, not raw pages.
- Ô Bois Sauvage: the Michelin card gave "Temporarily closed" on the Nov 2 read and no note today. This can be a read error. The own site blocks the tool. Other locale URLs of the card failed.
- L'Olivo: card not opened again. Hotel date read again.
- Gravitas: Washington Post not opened (date through Wikipedia). Company bankruptcy from a search result title only.
- Dulce Patria: the Tripadvisor review of Jul 5, 2026 describes breakfast in Feb 2026. It can be about Anatol, the hotel restaurant. Not proved. Ben chose no recheck.
- Dulce Patria holds an OAD 2026 row (No. 215). The Shota, Gravitas and others also hold 2026 list rows while closed. A list row is not status evidence.

## Found, no change made
- **Manzil domain:** `restaurantemanzil.com` now shows a gambling page. Do not use it as a venue URL. The award row of Manzil has no URL.
- **Names:** `Ristorante L' Olivo at Al Mahara`, `La Mar by Gaston Acurio, Dubai`, `Restaurante Manzil`, `Restoran Alexander`.
- **Not read in item 7:** the other 5 temporary closures of item 6 Group 7 (Ristorante Hotel Cipriani, The Restaurant at Meadowood, Highlands Bar & Grill, Lebensstern, Skyview Bar).

## Open items
From the sweep: item 3 (problems), item 4 (possible missing Michelin rows), item 5 (names). Numbers are in `handoff-closed-sweep-201-done-2026-11-02.md`. Items 6 and 7 are closed. Item 1 and item 2 were closed in `handoff-closed-sweep-twins-renames-done-2026-11-02.md`. Switzerland still waits for Ben's "results live".

## Methods (new)
- **Item 7 search:** two separate reads per venue, one for reopening and one for closure. 17 venues ran inline in one session with no subagent and no search limit.
- **Second read can move a verdict up or down.** Pädaste (bankruptcy, sale) and Gravitas (auction) were rated medium on Nov 2 and now look permanent. Ling Ling and Ô Bois Sauvage moved to conflict.
- **Atlantis pages:** the La Mar page says "Venue is currently closed". The Ling Ling page does not. A difference between sibling pages is a signal, not proof.
- **Old "season opening" articles:** Time Out Dubai "Ling Ling Ultra" is from Sep 2024. Check the date first.
- **Column names:** `awards` has `source_id`, `distinction`, `rank`, not `publisher`.

## Suggested opening prompt
```
Read claude/handoff-closed-sweep-item7-done-2026-11-02.md from the project files, then
claude/handoff-closed-sweep-201-done-2026-11-02.md for items 3, 4 and 5,
claude/handoff-closed-rule-done-2026-11-02.md for the closed rule and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 238,
audit_log 124,358, venues 11,293 (active 10,996, closed 297), awards 25,097, slugs 13,021, price 7,727, closed published 0 and cities.venues_count sum 10,996.
Then start item 3, the 4 venue problems, or the next open item I name. Show me in /ste style the evidence and ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
