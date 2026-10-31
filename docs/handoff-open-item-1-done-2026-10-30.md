# Handoff: Open item 1 done (2025 California Green Stars, Heritage 2025 One Star, 3 award URLs). Oct 30, 2026 (21:18 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b1-done-2026-10-30.md` for live state and open items. That file still holds the
Telluride city method, rule R6 (apostrophes) and the block 1 record. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 30, 2026)
- 21:01 ET: fresh count read, then start open item 1 (reads list first). Repo with push access.
- 21:05 ET "A for both": scope = item 1 rows only (wide gaps become new open items); URL = archive card URL in the guide
  year, else the edition article URL.
- 21:14 ET "I agree": Chay Garden 10486 and Hong Phat 10493 held for a later archive retry; build the file.
- 21:17 ET "Go".

## Live state (read Oct 31, 01:17:54 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,304 |
| awards | **23,358** |
| price | 7,730 |
| slugs | 12,915 |
| city_aliases | 262 |
| source_capture_ledger | last id **167** |
| audit_log | last id **118,998** |

## Done in this session
1. Start check 01:02:30 UTC: ledger 165, audit 118,990, slugs 12,915, city_aliases 262, all other counts matched. Repo
   attached with push access (clone `13e5bfc`).
2. Read of item 1 rows. Findings: 0 Michelin Green Star rows for 2025 in the whole database; 3,464 of 3,465 Michelin 2025
   rows had no URL. Ben chose item-1 scope only.
3. Reads (built-in browser, fetch from a web.archive.org tab and a guide.michelin.com tab): archive index per card (us/en and
   en paths), archive cards, 5 Michelin articles. Results in the file header of `docs/michelin-open-item-1-2026-10-30.sql`.
4. Build, relay `docs/open-items-1-build/relay.txt` (sha256 `3d575a83…6271a`, md5 `1cad3072…01e4`). pglast parse OK.
   Dry run through the Read connector: all guards passed, stopped at the first INSERT. Repo commit `2f8f002` (built, not run).
5. **Write** (Write connector, first try, ~01:17 UTC):
   - awards INSERT 30101 Pomet, 30102 Chez Panisse, 30103 Chi Spacca, 30104 Heritage (Long Beach): 2025 Green Star;
     30105 Heritage: 2025 One Star. URL = archive card URL (`web.archive.org/web/<time>id_/` form).
   - awards UPDATE source_url only: 21098 Banshee 2023 Bib (archive card 2023-12-19), 21099 Banshee 2024 Bib (archive card
     2025-04-14, dateAwarded 2024), 10494 Mặn Mòi 2025 Bib (Vietnam 2025 article).
   - Ledger **166** (history-backfill, 5), **167** (source-url, 3). Audit **118,991-118,998** (5 INSERT, 3 UPDATE).
   - Read-back matched every planned value. 10486 and 10493 still have no URL (held).

## Evidence summary
- California 2025 article (25 June 2025) `michelin-guide-california-stars-green-stars`: 17 Green Stars, incl. Chez Panisse,
  Chi Spacca, Heritage (Long Beach), Pomet; One Star list has Heritage, Long Beach.
- Archive cards in the 2025 California edition: Chez Panisse 2025-08-09, Chi Spacca 2025-07-26, Pomet 2025-09-14 (plate,
  greenstar True); Heritage 2025-09-12 (1 star, greenstar True, meta "2025 MICHELIN Guide USA").
- Heritage 2024: archive card 2025-05-04 shows One Star + Green Star, dateAwarded 2024. No 2024 rows in the database (new item).
- Banshee: 2023 Bib (card 2023-12-19), 2024 Bib (cards 2025-01-10, 2025-04-14, 2025-09-26). American South 2025 edition
  published 2025-11-04: Bib article lists 10 Atlanta Bibs (Antico Pizza, Bomb Biscuit, Estrellita, Fishmonger, Fred's,
  Heirloom Market BBQ, Little Bear, Superica, The Busy Bee, Whoopsie's), no Banshee; card 2026-04-08 plate. **No 2025 row.**
  American South 2026 edition published 2026-10-22.
- Vietnam 2025 article (2025-06-05) lists only the 9 new Bibs; names Mặn Mòi as a Bib restaurant (Service Award). Chay Garden
  last card 2025-02-20 (2024 edition); Hong Phat last card 2023-06-20; Man Moi no card in the archive.

## Methods that worked (new)
- **Archive index per card:** `web.archive.org/cdx/search/cdx?url=guide.michelin.com/<loc>/<path>&from=2022&to=2026&fl=timestamp,statuscode,original&filter=statuscode:200&collapse=timestamp:6`,
  one card and one locale per call, 1.2 s pause. Read a snapshot with `/web/<time>id_/<url>` and parse dLayer distinction,
  dLayer greenstar, meta description year and JSON-LD dateAwarded.
- **Do not** run a domain-wide prefix query (`matchType=prefix` on `guide.michelin.com/`): it timed out and the archive then
  returned "Temporarily Offline" for this session.
- Plate cards (Selected, Green Star only) give no year in the meta text. Prove the year by the snapshot date inside the edition
  window (edition article publish dates).
- Article publish date: JSON-LD `datePublished` on guide.michelin.com articles.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/michelin-open-item-1-2026-10-30.sql` (121 lines) | Run (ledger 166-167, audit 118,991-118,998) | `4b0638043ad0a1f658463b51f4bec5d0928e30c35fbcefcefb39d6653bd66833` |
| `docs/open-items-1-build/relay.txt` | Input | (relay sha256 above) |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first (item 1 closed except the 2 held rows)
1. Held from item 1: 2025 URL for Chay Garden 10486 and Hong Phat 10493. Retry the archive index one card at a time on other
   locale paths (`vn/en`, `jp/en`, `sg/en`, `vn/vi`). If none, Ben chooses: article URL or leave NULL.
2. Turkey follow-ups: Sankai by Nagaya price (₺₺₺₺, CAT_P04, TRY 4); Efendy recheck; one 2026 Turkey Bib unknown (39 vs 38);
   Efendy and Lucien Arkas legacy `$$` rows; Sankai site spam.
3. Turkey card cities that differ from ours (Revithia, Casa Lavanda, Bagarasi, Mandalya, Mezegi, Asma Yaprağı, Mezra Yalıkavak,
   Babayan Evi, Old Greek House) plus KITCHEN by Osman Sezener (card Yalıkavak, ours Bodrum). Ben chooses the city policy.
4. Status checks: Nadair (Atlanta) possibly closed; Dill (Lewes).
5. Held-P2 items: 5 city changes; 15 P2 venues that left the guide.
6. Merge and award cleanup: La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy; Duddell's (Hong Kong) possible duplicate `ve_a3512f9a51` /
   `ve_f88a5d9dc2` (norm_key `duddells`); Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved.
7. `cities.venues_count` recount: 375 cities differ from the live count (read Oct 30). Ben decides.
8. **New: 2025 Green Star backfill, all guides.** Database has 4 Michelin 2025 Green Star rows (the 4 above). California 2025
   alone had 17 (13 still missing). Part of the Michelin history backfill work item.
9. **New: 2025 Michelin URLs, all guides.** 3,463 of 3,470 Michelin 2025 rows have no URL. Part of the history backfill.
10. **New: Heritage (Long Beach) 2024** One Star + Green Star (archive card, dateAwarded 2024); no 2024 rows. History backfill.
11. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
    Fujian 2027 late Nov; Spain 2027 Dec 1; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
    Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found;
    Florida 2026 Green Stars article not found.
12. Write connector prompt closes by itself on DELETE files; SQL Editor route works. INSERT/UPDATE files run first try (again
    this session).
13. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.

## Suggested opening prompt
```
Read claude/handoff-open-item-1-done-2026-10-30.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 167,
audit_log 118,998, awards 23,358, slugs 12,915 and city_aliases 262. Then show me the next-block options in /ste style
(the open items, smallest first, with what each needs from me) and wait for my choice. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
