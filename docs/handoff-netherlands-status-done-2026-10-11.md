# Handoff: CompassEats, Oct 11, 2026 (16:25 Atlanta). Netherlands finished: slug file run (71 venues, audit 111,062-111,203) and status items done (Regent closed, audit 111,204). Next: Ben chooses the next block.

This file replaces `claude/handoff-netherlands-slugs-done-2026-10-11.md` (fully; its content is carried here) and `claude/handoff-netherlands-renamed-2026-10-11.md` for live state and open items. That file still applies for the batch 22 rename record (votes, Q1-Q4 of Oct 11, the chef-suffix-before-vote method, the "by" rule), its methods and dead ends, and its list of other handoff files. The other files still apply as before:
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the Netherlands stage and promote record.
- `claude/handoff-netherlands-captured-2026-10-10.md`: the capture record, the hold register, the "nothing below a Bib" rule.
- `claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md`: the slug check against `slug.ts`.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the slug-file method, the status-only file method.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`).

Working rules (unchanged): see `claude/handoff-netherlands-renamed-2026-10-11.md`.

## Live state
Population: whole table. Read Oct 11, 20:21 UTC (16:21 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,254 (active **10,886**, closed **368**) |
| awards | 22,659 |
| listings / slugs | 11,254 / **12,709** (canonical 11,254, non-canonical **1,455**) |
| venues with more or less than 1 canonical slug | 0 |
| price / blurbs / redirects | 7,048 / 142 / 9 |
| source_capture_ledger | 86 (last id 123) |
| audit_log | **106,529** (last id **111,204**) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, 22 applied. rename_rows 1,024. Sequence last value 22. |

## Done in this session (Oct 11, 16:06 to 16:25 Atlanta)

**Start check:** all counts, ledger 123, audit 111,061, slugs 12,638, batch 22 `applied` (83 rows) matched the renamed handoff. Template `docs/slugs-rename-michelin-2026-texas.sql` sha256 `064a3b14…b4ad17d6` correct in a fresh clone (repo head `cace34a`). `slug.ts` sha256 `f22bf699…ab0212`.

**Slug file (`slugs-rename-michelin-2026-netherlands.sql`).**
- Built by script (`build_slugs_nl.py`) from the Texas template: new header, 31 rules / 32 counted replacements, ASCII LF, no Texas number left (the `0-9` in the slug regex is skipped by the leftover check). 157 lines, sha256 `d23b43466be288c2362d98fa3dd80fe49d7a9e48ad4303d4d8d83f6c3c5a39b5`.
- Population: the 83 venues of batch 22. **12 keep their slug, 71 plan rows**, fingerprint `d11b3ac6e41187f4b84068adddbcfbaa`. Pre-rename plan md5 (`vid|city_slug|cur_slug|new_slug`) `2cc3c9c9…` = handoff. Live names md5 `8a7850e2…` = rename file new.
- Rule = `slug.ts` on 83 of 83.
- Checks: 0 empty or bad form, 0 duplicate, 0 in use, 0 in `redirects`, 0 not active, 0 older non-canonical rows on the 83, 0 blurbs. pglast: 3 statements, PL/pgSQL body parses. Dry run (Read connector, whole `DO` block) stopped at the first UPDATE; no id used.
- 5 new slugs of 3 letters or fewer: `/amsterdam/cue`, `/gemert/gem`, `/haarlem/ml`, `/eindhoven/nev`, `/roermond/one` (free in their cities).
- Ben "go". Write connector, first try, Oct 11 **20:12:29 UTC**. slugs 12,638 → 12,709; non-canonical 1,384 → 1,455. Audit **111,062-111,203** (71 UPDATE + 71 INSERT, 1 timestamp, 0 rows on other venues). Audit old→new pairs md5 = `2cc3c9c9…` (plan). No ledger row. All 83 canonical slugs = rule on the live name. Canonical slugs md5 on the 83 (`vid|city_slug|slug` by vid) `1419609c49639ff0412968ac2b0c7e95`.
- Examples: `/gemert/gem`, `/reijmerstok/brut172`, `/cromvoirt/nami`, `/warmond/de-moerbei`, `/utrecht/karel-5`, `/maastricht/restaurant-chateau-neercanne`, `/amsterdam/restaurant-de-kas`. Old slugs stay as non-canonical rows.
- **Uploaded:** `docs/slugs-rename-michelin-2026-netherlands.sql`, repo commit `f35d040` (Oct 11 16:14 -0400), sha256 correct in a fresh clone.

**Netherlands status items (open item 2).**
- Population: 10 venues, all `active`, 0 blurbs: Restaurant Daalder* `ve_3b8f5d3656`, Da Vinci `ve_b92ff90e25`, Sense `ve_e40817454c`, and the 7 dropped Bibs with legacy rows (Oriole Garden Bistro `ve_3e369166d3`, Bistrôt Chapeau `ve_30ec4d6d70`, LEV. aan de IJssel `ve_6d8bee674e`, HAVN `ve_6b61f17da2`, Prix de Rome `ve_ccff986445`, Regent `ve_7b3edc3520`, Avenue43 `ve_adccf8c7cf`). De Woage, Flicka, Escobar, Waers, Petite, Senang have no venue row (name search in NL cities, 0 rows): out of scope.
- Evidence read Oct 11 (web search + WebFetch + built-in browser, same-origin `fetch` of Michelin cards from a guide.michelin.com tab):
  - Daalder: moved back to its first site on Lindengracht, Amsterdam (TastyTrails Oct 5-6; Quote review Jul 18, 2026). Michelin card gone. Venue site blocks WebFetch (robots). Daalder holds Best Chef 2025 1-Knife 15848, no Michelin row. **Stays active.**
  - Da Vinci: news says it stays open; venue site restaurantdavinci.nl shows hours and a reservation form (Havenstraat 27). **Stays active.**
  - Sense: since Sep 17 runs as "New Sense" (senserestaurant.nl), same chef Dennis Middeldorp, same address Raadhuisstraat 1, Vught (Entree Magazine). **Stays active.** Name stays "Sense" (no publisher prints "New Sense" with an award).
  - Michelin 2026 Selected (no badge, meta "a restaurant in the 2026 MICHELIN Guide Netherlands"): Bistrôt Chapeau, Prix de Rome, Avenue43. On Michelin, no badge, no closure note: Oriole Garden Bistro, HAVN. LEV: venue site levfoodbar.com shows hours and October events at Iseldoks 1. **All stay active.**
  - **Regent (Bistrot Regent, Hertogstraat 71, Nijmegen): closed.** Venue site regent-nijmegen.nl (modified Jul 15, 2026): owners close the doors, last service through June 28. ChefsFriends May 12, 2026: last day Sunday June 28, 2026. Michelin `/us/en/gelderland/nijmegen/restaurant/bistrot-regent` 404 "Restaurant not found".
- File `docs/status-close-regent-nijmegen.sql`: built by script from `docs/status-close-de-groene-lantaarn.sql` (9 counted replacements), 82 lines, ASCII, sha256 `a08073abc379e48dd559b5cbeb8acc63520d238fb84e5af183e8dab38211a755`. Gates: row md5 `0646b7e8be6fb591bd7b6bbf5f50c3e3`, status `active`, 11,254 / 10,887 / 367 before, 11,254 / 10,886 / 368 after, exactly 1 status-only audit row. pglast: 3 statements, body parses. Dry run (Read connector) stopped at the UPDATE; no id used.
- Ben "go". Write connector, first try, Oct 11 **20:20:50 UTC**. Audit **111,204** (venues UPDATE, active → closed, status only). No ledger row. Award 11431 (Michelin 2025 Bib) kept. Other 9 still `active`.
- **Uploaded:** repo commit `1dcc37f` (Oct 11 16:21 -0400), sha256 correct in a fresh clone.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/slugs-rename-michelin-2026-netherlands.sql` | Run (audit 111,062-111,203), in the repo (`f35d040`) | `d23b4346…c3c5a39b5` |
| `docs/status-close-regent-nijmegen.sql` | Run (audit 111,204), in the repo (`1dcc37f`) | `a08073ab…8211a755` |
| `fixtures/rename/michelin-2026-netherlands-names.csv` | Run (batch 22), in the repo (`aa2e6aa`) | `9d48b090…48963d82f` |
| `reports/rename-michelin-2026-netherlands-rename.md` | Real-run report (`bbb39c5`) | `09a56d16…e6393b15e` |

## Methods that worked (new)
- **Dry run with the whole `DO` block:** send the full block (not cut at the first UPDATE) through the Read connector. It stops at the first UPDATE with "read-only transaction" and the text is the same as the file.
- **Michelin card status in one call:** from a guide.michelin.com tab, same-origin `fetch` of each card URL + DOMParser: status code, title, badge count (`.data-sheet__badge-container img`), meta description ("a restaurant in the 2026 MICHELIN Guide …" = Selected), `.data-sheet` text. A guessed URL that gives 404 proves nothing on its own; use it only with other evidence.
- **Audit pair check after a slug write:** join the UPDATE rows (old canonical → non-canonical) and the INSERT rows (new canonical) by `venue_id`; md5 of `vid|city|old|new` by vid = the plan md5.

## Dead ends: do not retry (new)
- A leftover-number check that treats `0-9` in `'[^a-z0-9]+'` as the number 9. Remove the regex literal before the check.

## Open items, in order
1. **Netherlands slug file: done** (uploaded `f35d040`).
2. **Netherlands status items: done** (Regent closed, audit 111,204, uploaded `1dcc37f`). **Next block: Ben chooses** (items 3-5 have dates; item 5 is the gap list).
3. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
4. **Switzerland after Nov 2, 2026** (option A, promote only).
5. **Gap list after the Netherlands:** retire-path countries Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; promote-only Taiwan, Singapore; Thailand after its 2027 edition (rule 2.1.7); Canada as three guides.
6. **Hold registers:** Texas, Belgium & Luxembourg, Netherlands (see the renamed handoff) → special-awards batch.
7. Price from the Michelin card (adds the 196 NL `€` cards). Ben chooses the method.
8. France slug set (148 venues). Ben decides when.
9. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
10. Later-ceremony guides, promote only: Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
11. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues), re-checked under the tie rule. Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
12. Rechecks, no date: Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
13. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount (the 7 new NL cities have `venues_count` 0); RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes; trademark-sign policy.
14. Repo `.env`: Ben to check that the Google Maps and MapTiler browser keys are restricted by HTTP referrer.
15. Plan v1.31: everything listed in the renamed handoff item 15, **plus this session** (slug file, audit 111,062-111,203, slug.ts 83 of 83, commit `f35d040`; status items: Regent closed, audit 111,204, commit `1dcc37f`; 9 venues stay active with the evidence above).
16. Options B (Phase 3 map-location pass) and C (publish builder): open for later.
17. Project file cleanup, part 2: after the migration is done.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-netherlands-status-done-2026-10-11.md first, then claude/handoff-netherlands-renamed-2026-10-11.md for the batch 22 record and working rules, then claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md for the gap-list read, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for database notes, methods and dead ends. Confirm live counts, ledger id 123, audit_log id 111,204 and slugs 12,709 with a Read query. Then read the Michelin gap list again (open item 5) and present the candidates for the next country in /ste style with your recommendation and the reason. Do not write the Cowork brief before I choose. No write before my go.
```

If Ben wants Plan v1.31 first, replace the last three sentences with: "Then start open item 15, Plan v1.31: build it from v1.30 with the plan-edit method, check it, and present it in /ste style before I save it."
