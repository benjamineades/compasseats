# Handoff: closed-venue sweep, first 201 read. 63 venues active. Nov 2, 2026 (14:25 Atlanta).

This file replaces `handoff-closed-rule-done-2026-11-02.md` for live state. That file still holds the closed rule and the recheck list. Full open-item list: `handoff-open-items-rls-names-fr-closures-done-2026-11-02.md`, with the changes in `handoff-es-list-compare-done-2026-11-02.md` and the closed-rule handoff. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 14:14 "1A, 2A, 3A, 4A, 5A": 1A = Group 3 active; 2A = Group 7 stays closed, recheck; 3A = 5 possible twins stay closed, read each pair for a merge question; 4A = HODAN active, the other 3 moved venues stay closed until a rename read; 5A = Swiss venues in this file.
- 14:18 "Go".

## Live state (read Nov 2, 19:19:45 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,296 (active **10,988**, closed **308**) |
| closed venues published / not published | **0 / 308** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs / price | 13,017 / 7,728 |
| listings / cities | 11,296 / 3,264 |
| cities.venues_count | sum **10,988**; 0 cities differ from the view |
| source_capture_ledger | 182 rows, last id 234 |
| audit_log | **118,776** rows, last id **124,290** |

## Done
`docs/fix-status-sweep-63-active-2026-11-02.sql` (sha256 `19c7df5b...eab2c4a`). Write connector, first try, 19:19:40 UTC. Audit 124,123-124,290 (cities 42, listings 63, venues 63). No ledger row. Run record `docs/closed-sweep-2026-11-02/run-sweep-63-active-2026-11-02.txt`. The file header has one evidence line for each of the 63.
Evidence for all 201: `docs/closed-sweep-2026-11-02/closed-sweep-201-evidence-2026-11-02.csv`.

## Population and result
The 201 = closed venues whose listing the Nov 2 flip changed (audit 123,757-124,122), no audit row active to closed, no Michelin row 2026 or later, an award from 2025 or later. Id-list md5 `f7cbfa74...e0284f`. Population is the handoff count only with the flip filter: without it, 205 / 59 / 61.

| Group | Venues | Result |
|---|---|---|
| 1 Dated 2026 evidence or live booking | 20 | Active |
| 2 Seasonal, next season or season dates | 8 | Active |
| 3 Undated site or listing, no closure note | 34 | Active (Ben 1A). Weakest evidence of the 63 |
| 6 HODAN, moved within Istanbul | 1 | Active (Ben 4A) |
| 4 Possible twins | 5 | Closed, merge read next |
| 5 Name, city or status problem | 4 | Closed, recheck |
| 6 Other moved or renamed, same city | 3 | Closed, rename read |
| 7 Card or listing only | 32 | Closed, recheck (Ben 2A) |
| 8 Ended, or new site not confirmed | 7 | Closed |
| 9 Sources disagree | 10 | Closed, recheck (conflict rule) |
| 10 Temporary closure | 17 | Closed, recheck |
| 11 No usable evidence | 6 | Closed, recheck |
| 12 Closure evidence | 54 | Closed |

Group 3 holds undated own or hotel sites plus some listings. Some can be closed. My own check: 11 source pages opened again, all agree; the other venues were not checked by me. Own-site and card evidence can be stale (Silo site, Lyle's, Euphoria, Lolla, Souvenir cards).

## Open items from the sweep
1. **Twins, merge read (Ben 3A):** Chesa Stüva Colani - Ristorante `ve_8f85789bec` (Michelin 2025 Bib) / Chesa Stuva Colani `ve_388aeca5ca` (active, Michelin 2025 One Star); Gourmetrestaurant Tannenhof `ve_bd408ea3c3` (Michelin 2025 Two Stars) / Hotel Tannenhof `ve_aed4b4a9f3` (active); Baumanière 1850 `ve_070ced1e07` (Michelin 2025 Two Stars) / Slalom 1850 `ve_5f98076100` (active, Michelin 2026 Two Stars); ACiD brianza `ve_d230b9d155` / Brianza `ve_d2804e9715` (active); Wagyumafia Tokyo `ve_024995c746` / WAGYUMAFIA DISTRICT `ve_13801fdc06` (active).
2. **Rename read (Ben 4A):** 花小路さわ田 `ve_f17195ac4b` (moved Jul 2025, now つぼつぼ), Katsukani Ryōri Akasaka Kitafuku `ve_af6c894a24` (now Azabu-Juban Kitafuku), Wine RVLT `ve_7e3068bc36` (now Revolution Wine Bistro, 211 Henderson Road).
3. **Problems:** Scalottas Terroir `ve_fae8dcb6f0` (match to Scharans not confirmed), Suetomi `ve_779a1ac27f` (Foodle only, address differs), tsushimi `ve_001296abf4` (in Nirasaki, Yamanashi; database city is Tokyo), Grill at Amangani `ve_8d69af215c` ("Reopening soon": season or renovation).
4. **Possible missing Michelin rows, no change made:** Hakusi, Schlossherrnstube, Flora and CUR8 appear to hold a 2026 award and have no 2026 row. Kinship has no Michelin row, and a Michelin DC article lists one star. Mural Farmhouse card shows one star and a Green Star, and the venue has no Michelin row in the award line read.
5. **Names, no change made:** Paznauerstube (Michelin: Paznaunerstube), Eat and Cook - Best Fine Dining KL (Eat and Cook), Amal Restaurant Armani Hotel - Burj khalifa (Armani/Amal), Flora (Food & Wine) (Flora), Restavracija Lesnika (Lesnika).
6. **Rest of the sweep:** 103 venues (51 with last award 2020-2024, 52 before 2020), plus the 21 closed venues that the flip did not change. 4 of the 21 hold a 2025 award: Hacha Agaveria, Double Deuce Lounge, A Bar Called Gemma, Little Cooler.
7. **Temporary closures:** the 17 in Group 10 join the recheck list. They include Al Muntaha and L'Olivo (about late 2027), Chat-Botté (2027), Tayēr + Elementary (fire), Ōre, The Shota, Aürt, Manzil.

## Methods (new)
- **Search limit:** WebSearch has a limit of 200 searches per turn, shared across subagents. 8 batches of 25 ran out at about venue 6 to 15 of each batch. 4 batches of 23 with at most 2 searches per venue worked.
- **Second-read rule:** a live Michelin card or an undated listing alone stays weak.
- Sonnet subagents with a shared brief file, then a merge script. Agents must write verdicts to JSONL files.
- Some sites are blocked by robots or the permission layer (for example tsujita-sushi.com, futago25usa.com, dramlondon.com, sanbrussels.com).
- Twin check: `norm_key` has no spaces. Split `lower(f_unaccent(name))` into words, then match same-city active venues.

## Suggested opening prompt
```
Read claude/handoff-closed-sweep-201-done-2026-11-02.md from the project files, then
claude/handoff-closed-rule-done-2026-11-02.md for the closed rule and recheck list and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 234,
audit_log 124,290, venues 11,296 (active 10,988, closed 308), awards 25,097, slugs 13,017, price 7,728, closed published 0 and cities.venues_count sum 10,988.
Then read the 5 twin pairs (price, slugs, awards, city labels, listings, and venue evidence) and show me in /ste style the merge question for each pair.
After that, read the 3 moved venues for a rename question. Ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
