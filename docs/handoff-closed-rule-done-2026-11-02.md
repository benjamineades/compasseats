# Handoff: closed-venue rule done (open item 10). 8 venues active, 350 unpublished. Nov 2, 2026 (13:45 Atlanta).

This file replaces `handoff-es-list-compare-done-2026-11-02.md` for live state. That file still holds the list-compare methods, the Swiss waiting state and the recheck list. Full open-item list: `handoff-open-items-rls-names-fr-closures-done-2026-11-02.md`, with the changes in both files. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 13:11 "1A ... 7A": 1A = apply the Aug 24 rule; 2A = temporary closure is closed and false, the reopening file sets active and true; 3A = iconic list empty today; 4A = read the 13 venues first; 5A = write after that read (replaces F1); 6A = the 34 live pages wait for the swap; 7A = a hidden venue URL gives a 404 after the swap.
- 13:26 "1A, 2A, 3A, 4A" (second set): 1A = 8 venues to active; 2A = seasonal closure is active, fire or renovation stays closed until it reopens; 3A = flip the other 350 now; 4A = sweep as an open item, 201 venues first.
- 13:40 "Go".

## Live state (read Nov 2, 18:41:00 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,296 (active **10,925**, closed **371**) |
| closed venues published / not published | **0 / 371** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs / price | 13,017 / 7,728 |
| listings / cities | 11,296 / 3,264 |
| cities.venues_count | sum **10,925**; 0 cities differ from the view |
| source_capture_ledger | 182 rows, last id 234 |
| audit_log | **118,608** rows, last id **124,122** |

## Done
`docs/fix-closed-rule-8-active-350-unpublished-2026-11-02.sql` (sha256 `39d39edf...6eaac1`). Write connector, first try, 18:40:52 UTC. Audit 123,757-124,122 (cities 8, listings 350, venues 8). No ledger row. Run record `docs/closed-rule-2026-11-02/run-closed-rule-2026-11-02.txt`. Evidence for the 8 is in the file header.
Active: Atelier (Auckland) `ve_47d4b5d515`, Muttonbird `ve_6c7a46653b`, Ed.Em `ve_540fbdb0db`, L'Impertinent `ve_9fd9ef0dbb`, Le Saint-James `ve_e998bbe81d`, Alpage `ve_e643c85d2a`, Le Cin5 `ve_a0adf5e745`, Ostaria Tyrol `ve_ec527ff975`.

## The rule, from now on
- A closed venue has `listings.published = false`. An iconic venue stays true by Ben's call per venue. The iconic list is empty.
- Each closure file sets status closed and published false. Each reopening file sets status active and published true. Same transaction.
- Temporary closure (fire, renovation): closed and false until it reopens. Seasonal closure: active.
- Check for each gate and the builder: closed published = iconic list count (0 today); active not published = 0.
- Publish builder (not built): gate on `listings.published`. A hidden venue URL gives a 404, no redirect.
- Live site reads the Sheet, and this write changes no live page. 34 closed venues show as open on the live site until the swap (Nadair and SLOW&LOW opened and confirmed). Open venues marked closed are also absent.

## Finding: many at-load closures are wrong
All at-load closures came from the Sheet `closed_venues` tab (hand-kept, plus Google "CLOSED_PERMANENTLY" through `compasseats-geo-enrich.gs`). The database holds no evidence for them. Google name matches can be wrong (punch list: Dukes).
- 13 venues with a Michelin 2026 row and no earlier status read: 8 not closed, 5 stay closed.
- Sample of 16 from the other 304 (seed 20261102): 8 closure confirmed (Pekin Cafe, Eight Tables, The Whale Wins, Alain Ducasse au Plaza Athenee, Hibiscus, Chez Matsuo Shoto, Eden, DDOBAR by one MapQuest title); 2 Michelin card live, no note (es.TABLE `ve_bafcec17d6`; Ullrs Wine & Dine `ve_e2777cbdc0`, card name Ullrs Gourmetstube, One Star 2026); 4 no closure found (White Plate `ve_26be6181da`, Circus Cocktail Bar `ve_3d9abdd5f6`, Restaurant L'equateur `ve_bf7024c9b1`, Kojima `ve_588a02f12f`); 2 not settled (Piu Higienopolis `ve_195c01f75c`, card did not open, active sibling Piu Pinheiros; Akasaka Kitafuku `ve_af6c894a24`, Tabelog says relocated). Most of this is headlines and listing titles.

## New open item: closed-venue sweep (Ben 4A)
Population: 304 venues, closed at the load (no audit row active to closed), no Michelin row 2026 or later, read before the flip. Of these, 201 hold an award from 2025 or later: read these first. 51 are 2020-2024, 52 are before 2020. Each venue found open: status active, published true, city count, in one gated file. Conflict rule applies. This is the "closed-venue sweep" that Plan v1.15 names as a pre-swap workstream.

## Rechecks added
Divellec `ve_598810e8fe` (own site: back in September 2026, not yet shown), Auberge Pyrenees Cevennes `ve_6a256f40bd` (card: closed for renovations), Udtryk `ve_357709fdf3` (own site: reopens Dec 1, no year), Adana `ve_500287c739` (conflict), Maison Decoret `ve_cde5f573b4` (fire; family hopes for early 2027). Tayer + Elementary (fire, no reopening this year). OXALIS Schluchsee: the Aug 24 pass said closed; it is active and published; no later decision read.
Carried: Hegel Eins, Sushi Saito, Ricardo Sanz Wellington, Santerra, Galanga, La Table de l'Alpaga, Erre de Roca (Michelin status), Bens d'Avall (Mar 2027). Switzerland waits for Ben's "results live".

## Methods (new)
- A status read with WebFetch: Michelin card, then own site, then the tourist office. A seasonal venue can show "closed" on Google in the off season.
- `guide.michelin.com` cards through WebFetch show "(Temporarily closed)". Some cards give a client error (Piu).
- A Write connector run with UPDATE only worked first try.
- A repo stop check asks for a commit of untracked files: use a branch before a go, then merge after the run.

## Suggested opening prompt
```
Read claude/handoff-closed-rule-done-2026-11-02.md from the project files, then
claude/handoff-es-list-compare-done-2026-11-02.md and claude/handoff-open-items-rls-names-fr-closures-done-2026-11-02.md for the open items and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 234,
audit_log 124,122, venues 11,296 (active 10,925, closed 371), awards 25,097, slugs 13,017, price 7,728, closed published 0 and cities.venues_count sum 10,925.
Then start the closed-venue sweep: read the 201 at-load closed venues with an award from 2025 or later, and show me in /ste style the status evidence
for each group and the venues to set active. Ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
