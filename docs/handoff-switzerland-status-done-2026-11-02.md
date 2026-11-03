# Handoff: Swiss status file done. After Seven active, Colani Bistrot active and renamed. Nov 2, 2026 (21:35 Atlanta). Next: Swiss open items.

This file replaces `handoff-switzerland-decisions-2026-11-02.md` for the Swiss live state. That file still holds Ben's decisions 1-10, the 30 new venues, the 2025 rows kept as history and the methods. Plan background: `handoff-switzerland-brief-2026-11-02.md`. Recheck lists: `handoff-closed-sweep-item3-done-2026-11-02.md`, `handoff-closed-sweep-item7-done-2026-11-02.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 21:31 "1A, 2A": 1A = recheck the 2 venues after they open. 2A = read Ô Bois Sauvage after the status file, as a separate step.
- 21:32 "Go".
- 21:42 "Q1: A": Ben opens the Ô Bois Sauvage site. 22:26 "A": it stays closed, recheck after Jan 2027.

## Live state (read Nov 3, 02:33:13 UTC, whole tables)
Venues **11,323** (active **11,031**, closed **292**). Awards **25,321**. Slugs **13,053** (canonical 11,323, non-canonical 1,730). Price 7,727. Listings 11,323. city_label_source 24,049. Cities 3,279, `cities.venues_count` sum **11,031**, 0 cities differ from `city_venue_counts`. city_aliases 262. rename_batches 30 (last id 45), rename_rows 1,302. Ledger 189 rows, last id **243**. audit_log 119,235 rows, last id **125,064**. Closed published 0, closed not published 292, active not published 0.

Repo: `main` = branch `switzerland-status-pre-go` = 0b91a86, plus the commit of this file.

## Done
`docs/status-michelin-2026-switzerland-2026-11-02.sql` (sha256 `ba34978e...6486`). Write connector, first try, 02:32:54 UTC. Audit 125,056-125,064 (cities UPDATE 2, listings UPDATE 2, slugs INSERT 1 and UPDATE 1, venues UPDATE 3). Rename batch 45 `rename-status-michelin-2026-switzerland-2026-11-02`. No ledger row. Run record `docs/ch-2026-build/run-status-ch-2026-11-02.txt`. Evidence `docs/ch-2026-build/status-evidence-ch-2026-11-02.csv` (sha256 `f0d3951b...54e4`).

| Venue | Id | Result | Main evidence |
|---|---|---|---|
| After Seven | `ve_7077280426` | Active, published, Zermatt 6 to 7 | Zermatt Tourismus: closed Apr 13 to Dec 1, 2026, open from Dec 2, 2026. Michelin One Star 2026 |
| Colani Bistrot (was Chesa Stüva Colani - Ristorante) | `ve_8f85789bec` | Active, published, Madulain 1 to 2. `/madulain/colani-bistrot` canonical, old slug non-canonical | Own site: BISTROT winter Nov 27, 2026 to Apr 3, 2027. Michelin Bib 2026 |

Limits: the page reads are short reports from the web-fetch tool. The own After Seven page shows an old note (re-open Dec 6, 2024). Only Michelin prints "Colani Bistrot": the own site prints BISTROT, Pontresina Tourismus prints Bistro Bar Restaurant Colani. Ben chose Colani Bistrot.

## Ô Bois Sauvage read (2A, no write)
`ve_9503403a2a` stays closed, not published. Evidence `docs/ch-2026-build/o-bois-sauvage-recheck-2026-11-02.csv` (final sha256 in the commit of this update).
- Michelin `/us/en/` card: "Temporarily closed", meta description names the 2025 guide. Michelin `/en/` card: no closure note. The conflict of item 7 remains.
- 0 of the 224 lines of the 2026 list read match. No 2026 award. Award 10636 (Bib 2025) stays as history.
- Tripadvisor: newest review Mar 2026. Weak evidence.
- Own site refused by the fetch tool (robots_disallowed). Hérémence Tourisme and MySwitzerland did not open.
- Ben's phone, 21:43 ET: leboissauvage.ch gives "the server can't be found" (one device, one try). The fetch tool still refuses the site with and without `www`.
- Tripadvisor list: ranked first, label only "Closed today". Guidle: no closure note, no date. GaultMillau Jan 2024: no closure. restaurantguru and finde-offen did not open.
- No source gives a date or a reason for the closure, says that it is permanent, or shows the venue open now.
- Ben 22:26 ET "A": stays closed, recheck after Jan 2027 (conflict rule).

## Recheck list added
| Venue | Id | Recheck after |
|---|---|---|
| Colani Bistrot | `ve_8f85789bec` | **Nov 27, 2026** (Ben 1A) |
| After Seven | `ve_7077280426` | **Dec 2, 2026** (Ben 1A) |
| Ô Bois Sauvage | `ve_9503403a2a` | **Jan 2027** (Ben 22:26 ET "A"). Replaces the "Swiss batch" line on the item 7 list |

No scheduled task holds these dates. First due on the older lists: Ling Ling after Nov 5, 2026.

## Open items (Swiss)
1. Rename batch: Soleil d'Or (decision 5) plus the card names of the paired legacy venues. Ben decides the scope.
2. Card price file in CHF (decision 4). The legacy prices on After Seven and Colani Bistrot are not changed yet.
3. Cleanup list (decision 2): `ve_d159e1bbd3`, `ve_7c75b49d07`, `ve_7d4e3b91ec`.
4. Slugs with ø removed: `/aubonne/nj-rd-cafe`, `/aubonne/nj-rden-restaurant-cafe-brunch`.
5. 2025 backfill: La Croix d'Or Ballaigues, Bären Schwarzenburg, Bären Utzenstorf, Restaurant LA Basel.
6. Worldwide alias check (262 aliases; Swiss suspects: `grisons`, `sankt niklausen`, `silvaplana`, `lens`, `sorengo`).

## Methods (new)
- **Rename gate:** `norm_key` is a generated column. If the new name changes the key, the audit gate needs `(old_row-'name'-'norm_key')=(new_row-'name'-'norm_key')`. The Item 3 gate passed only because the key did not change there.
- **Write connector:** a file with no DELETE ran on the first try (consistent with the Nov 2 note).
- **Stop hook:** it can report a missing remote branch when the local branch has no link to the remote one. Run `git ls-remote` first, then `git branch -u`.
- **Not bypassed:** the fetch tool refused `leboissauvage.ch` (robots_disallowed). I did not read it another way.

## Suggested opening prompt
```
Read claude/handoff-switzerland-status-done-2026-11-02.md from the project files, then
claude/handoff-switzerland-decisions-2026-11-02.md for the decisions, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 243,
audit_log 125,064, venues 11,323 (active 11,031, closed 292), awards 25,321, slugs 13,053, price 7,727, closed published 0 and cities.venues_count sum 11,031.
Then start the Swiss open item I name. Build the file, examine it read-only and show me in /ste style the evidence.
Ask me any question the plan does not decide. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
