# Handoff: CompassEats, Oct 10, 2026 (10:55 Atlanta). Texas finished: rename, slugs and cleanup done. Next: Belgium & Luxembourg capture in Cowork.

This file replaces `claude/handoff-texas-promoted-2026-10-10.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-texas-promoted-2026-10-10.md`: the Texas capture, stage and promote record (batch 14, ledger 103–104, audit 109,187–109,286), the 66-row legacy correction, the hidden-pair method.
- `claude/handoff-briefs-texas-belgium-2026-10-09.md`: the Belgium & Luxembourg and Switzerland facts per guide, Ben's Oct 9 decisions (order, Switzerland option A, Luxembourg in the Belgium batch), the France slug-set read.
- `claude/handoff-plan-v130-done-2026-10-09.md`: the Plan v1.30 record, the plan-edit and fact-check methods.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit, the staged-row check, the stage dead ends.
- `claude/handoff-germany-renamed-sets23-2026-10-09.md` and `claude/handoff-germany-slugs-sets23-done-2026-10-09.md`: the vote method, the Q1–Q4 rulings, the slug-file method.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`, checked Oct 10): the Sep 14 name rulings, rule 2.1.1 (amended Sep 24), rule 2.1.7, the Sep 28 standing rules (temporary closure, conflicting evidence, Michelin-closed venue, contamination with no pairing).

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.
- Plan versions, briefs and handoffs are saved to the project over the same name (`project_write` with `local_path`).

## Live state
Population: whole table. Read Oct 10, 14:54 UTC (10:54 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,232 (active **10,866**, closed **366**) |
| awards | 22,462 |
| Michelin 2025 / 2026 / 2027 rows | 3,791 / 4,877 / 47 |
| Michelin rows with `source_url` | 4,336 |
| listings / slugs | 11,232 / **12,575** (canonical 11,232, non-canonical **1,343**) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,868 |
| price | 7,048 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **77** (last id **106**) |
| audit_log | **105,357** (last id **109,342**) |
| ingest_batches | 1, 3–14 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, **18** applied (9 rows; 11, 13, 14, 17 = rolled-back dry runs). rename_rows **843**. Sequence last value 18. |

## Done in this session (Oct 10, 10:25 to 10:54 Atlanta)

**Start check:** all counts, ledger 104, audit 109,286 and batch 14 (`michelin-2026-texas`, promoted 14:21:59 UTC) matched the Texas-promoted handoff.

**1. Texas rename (batch 18, key `rename-michelin-2026-texas`).**
- Population: the 64 `match` rows of batch 14 where the card name ≠ `venues.name`: 18 venues (= handoff list).
- Votes: Michelin is the only publisher on 17 venues. Le Jardinier also holds OAD 2025/2026 rows; OAD spelling not read, because the rule gives the same name either way (venue site `lejardinier-houston.com` title and logo print "Le Jardinier Houston" = card).
- File `fixtures/rename/michelin-2026-texas-names.csv`: 18 rows, LF, model `fixtures/rename/majority-2026-germany.csv`. Built by script: `new_name` = fixture `venue_name`, `expected_name` = live name (md5 guard `22ad2300…bfdbed` against SQL; card/URL md5 `bf49f538…ba325dc` against `ingest_rows`). Parsed by the repo's `loadRenameCsv`: 18 rows, 0 duplicates. sha256 `287cbe9415bcfa8fe806167d2d7deaa42a8ed1ed803e5d7eb3ae2ac579dce173`, repo commit `387c9c7`.
- Read-only checks: 0 same-city `norm_key` collisions; 0 blurbs; 0 earlier rename rows; `norm_key` same on 9, changes on 9.
- **Ben's decisions (Oct 10), all A:** Q-A keep the 6 case/apostrophe rows (12 InterStellar BBQ, 28 Casaema, 29 da Gama Canteen, 37 nobie's, 58 Kemuri Tatsu-ya, 70 Cullum's Attaboy; France and Germany precedent). Q-B Le Jardinier → "Le Jardinier Houston" (New York and Miami venues stay "Le Jardinier"). Q-C Annam Vietnamese Restaurant → "Annam" (venue site logo prints the long form; single-publisher rule).
- Other renames: Goldee’s Bar-B•Q (card U+2019 and bullet kept), Nicōsi, Rosemeyer Bar-B-Q, Killen's BBQ, Blood Bros BBQ, Một Hai Ba, nonna (pipe cut, Q3 A precedent), Micklethwait Craft Meats, Veracruz Fonda & Bar, Burnt Bean Co.
- Dry run: batch id 17, ledger 105, audit 109,287–109,304 used up (rolled back; max ids unchanged; sequences moved). Report commit `e2b3743` ("DRY RUN"): 18 rename, 0 reject, 0 review; 10 invariants pass.
- Real run (Ben, Oct 10 14:35:04 UTC): batch **18** `applied`, ledger **106** (michelin, name, 18, job `rename-apply:rename-michelin-2026-texas`), audit **109,305–109,322** (18 venues UPDATE, each from `expected_name` to `new_name`). Live names md5 = file md5 `d5253fd0…12321ac`. Report commit `2ec21f6`, sha256 `bc71fa04…1525774` (real run).

**2. Texas slugs (`docs/slugs-rename-michelin-2026-texas.sql`).**
- Built by script from `docs/slugs-rename-michelin-2026-germany-sets23.sql` (27 counted replacements; no Germany number left). 157 lines, sha256 `064a3b14a13ffef1b63bb92e8138c4ecaedb6a0bc391d69f56f3f7a0b4ad17d6`, repo commit `610979e`.
- Population: the 18 venues of batch 18. Rule `f_unaccent` = slug.ts on 18 of 18. **9 keep their slug** (InterStellar BBQ, Nicōsi, Casaema, da Gama Canteen, nobie's, Blood Bros BBQ, Một Hai Ba, Kemuri Tatsu-ya, Cullum's Attaboy). **9 plan rows**, fingerprint `9d235485b69aea17f8c05b9fb8e0d268`.
- Checks: 0 empty, 0 duplicate, 0 in use, 0 in `redirects`, 0 not active, 0 older non-canonical. Dry run (Read connector) stopped at the first UPDATE; no id used.
- Ben "go". Write connector, first try, Oct 10 14:44:07 UTC. slugs 12,566 → 12,575; non-canonical 1,334 → 1,343. Audit **109,323–109,340** (9 UPDATE + 9 INSERT, 1 timestamp, 0 rows on other venues). No ledger row.
- New paths: `/houston/le-jardinier-houston`, `/houston/annam`, `/fort-worth/goldee-s-bar-b-q`, `/spring/rosemeyer-bar-b-q`, `/pearland/killen-s-bbq`, `/dallas/nonna`, `/austin/micklethwait-craft-meats`, `/austin/veracruz-fonda-bar`, `/seguin/burnt-bean-co`. Old slugs stay as non-canonical rows.

**3. Texas cleanup.**
- a. **Olamaie** `ve_59ce7cc401` (Austin) → `closed`. Evidence: card "Restaurant not found" (Cowork, Oct 9); not in the 2026 star list; venue site `olamaieaustin.com` says closed Sunday, July 19; KUT (Jul 9, 2026) gives July 19, 2026. Awards kept: 3833 Michelin 2025 One Star, 3835 OAD 2025, 3834 OAD 2026.
- b. **Killen's (Houston)** `ve_6034ffec5f` → `closed`. **Correction to the Texas-promoted handoff: this venue is NOT a twin of Killen's BBQ (Pearland).** It is a separate Ronnie Killen restaurant at 101 Heights Blvd., with its own Michelin page `.../texas/houston_2986624/restaurant/killen-s` (still shows the 2025 Bib, read Oct 10). Award **10600** is a real 2025 card and stays. Not in the 2026 Bib list (54). CultureMap Houston (Jun 22), DiningOut (Jun 26, upd. Jul 8) and Hoodline (Jun 2026): final service July 19, 2026; property sold. Ben Q1 **A** (close).
- File `docs/cleanup-michelin-2026-texas-status-closed.sql` (pattern of `docs/cleanup-michelin-de-status-active.sql`), 93 lines, sha256 `8d36ff5e2158b994b76655f4193dece481b6b0bf2df27f19aabc9faaf88425d9`, repo commit `aa63b15`. Guards: venue id md5 `ac364131…ed0820`, name/city/status per venue, the 2 Michelin 2025 rows, 4 award rows.
- Ben "go". Write connector, first try, Oct 10 14:52:57 UTC. active 10,868 → 10,866, closed 364 → 366. Audit **109,341** (Olamaie) and **109,342** (Killen's), status-only. No ledger row.
- c. **Lucia** `ve_0c81b77dfc` (Dallas): no change. Built-in browser read Oct 10: card `.../dallas_2954570/restaurant/lucia-1209114` has no badge and page data `"distinction":"plate"`; the 2026 Bib article ("The Best Value Restaurants in Texas for 2026") lists Lucia in the Dallas Bibs. Conflicting evidence → no change; 2025 Bib row 10029 stays; status `active`. On the recheck list (Ben Q2 B: read now; result recorded here).
- d. **la Barbecue** (Austin): no venue exists. Michelin Selected is not ingested (Plan v1.30 scope rule). Closed with no write.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/rename/michelin-2026-texas-names.csv` | Run (batch 18), in the repo | `287cbe94…79dce173` |
| `reports/rename-michelin-2026-texas-rename.md` | Real-run report (`2ec21f6`) | `bc71fa04…1525774` |
| `docs/slugs-rename-michelin-2026-texas.sql` | Run, in the repo (`610979e`) | `064a3b14…b4ad17d6` |
| `docs/cleanup-michelin-2026-texas-status-closed.sql` | Run, in the repo (`aa63b15`) | `8d36ff5e…af88425d9` |

## Methods that worked (new)
- **Rename CSV from two md5-guarded inputs:** card names from the repo fixture (sha256 guard) and live names from a Read query written to a JSON file, with an SQL md5 of `line \t venue_id \t name` checked in the script. A second md5 of `line \t card \t url` from `ingest_rows` proves the fixture lines. Then parse the file with the repo loader (`bun` + `scripts/rename/lib/renameCsv.ts` `loadRenameCsv`).
- **Collision check before the rename job:** a generated `VALUES (venue_id, new_name)` list with an md5 guard; compare `norm_key(new_name)` with other venues in the same city.
- **Sequence read after a dry run:** `pg_sequences.last_value` for `rename_batches_id_seq`, `source_capture_ledger_id_seq` and `audit_log_id_seq` predicts the real-run ids (max(id) does not move after a rollback).
- **Michelin card award from the rendered page:** in the built-in browser, `window.dataLayer` entry with `"distinction"` (`plate` = Selected), plus `.data-sheet__badge-container` empty. A plain WebFetch of the page can return stale award text.
- **Status-only file from a Read query:** generator script writes the guards from md5-checked JSON; dry run = `DO` block through the Read connector.

## Dead ends: do not retry (new)
- `ingest_batches.key` (column is `batch_key`).
- WebFetch of a guide.michelin.com restaurant page to read the current award: it returned "Bib Gourmand" text for Lucia while the rendered card showed `plate`. Use the browser (dataLayer) for the award.
- Assuming that two same-name venues in nearby cities are twins (Killen's): check for a separate Michelin page and address first.

## Open items, in order
1. **Belgium & Luxembourg capture (next).** Ben opens a new Cowork session (Opus, Chrome extension) with the opening message below. Cowork delivers `michelin-2026-belgium-luxembourg.csv` and `michelin-2026-belgium-luxembourg-log.md`. Then (new chat): stage, promote, retire the same-category twins (Great Britain & Ireland path), La Paix status, rename, slugs.
2. **Switzerland after Nov 2, 2026** (option A, promote only).
3. **Hold register (Texas):** Barley Swine 2026 Service Award (Stefan Davis) → special-awards batch. Mindful Voices on Dai Due, Emmer & Rye, Nixta Taqueria, Isidore → hold (no column).
4. Price from the Michelin card (4,225 venues + Texas cards). Ben chooses the method. `price_capable` is false for Michelin.
5. France slug set (148 venues). Ben decides when.
6. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
7. Later-ceremony guides, promote only: American South after Oct 21; Beijing & Tianjin after the end of October; Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
8. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
9. Rechecks, no date: **Lucia (Dallas; card `plate` vs 2026 Bib article)**, Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
10. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city (option C later, if wanted); apostrophe character policy (cards use both U+0027 and U+2019; the rename follows the card).
11. Plan v1.31: the Oct 9 decisions (Switzerland option A, Luxembourg in the Belgium batch, the order), the Texas result (promoted handoff + this file), the 66-row correction, the Killen's correction.
12. Project file cleanup, part 2: after the migration is done.

## Opening message for the Belgium & Luxembourg Cowork session
```
Read the brief claude/cowork-michelin-2026-belgium-luxembourg.md from the project files with the Projects tool (the same file is docs/cowork-michelin-2026-belgium-luxembourg.md in the GitHub repo, sha256 888df1f3…71e99). Follow it exactly. Use the Chrome extension for guide.michelin.com. Do not touch the database or the repo. Deliver michelin-2026-belgium-luxembourg.csv and michelin-2026-belgium-luxembourg-log.md in this chat, then stop and wait for me.
```

## Suggested opening prompt for the next chat (after the Belgium & Luxembourg capture)
```
Read these handoffs from the project files with the Projects tool: claude/handoff-texas-done-2026-10-10.md first, then claude/handoff-briefs-texas-belgium-2026-10-09.md for the Belgium & Luxembourg facts, then claude/handoff-germany-staged-run1-2026-10-08.md for the pre-stage simulation method, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 106 and audit_log id 109,342 with a Read query. I attached michelin-2026-belgium-luxembourg.csv and michelin-2026-belgium-luxembourg-log.md from the Cowork capture. Check the CSV hash against the log, check the counts against the brief, then run the read-only pre-stage simulation and tell me in /ste style what the Belgium & Luxembourg stage, promote and retire will need. Give me click steps to upload the two files to the repo. No write before my go.
```
