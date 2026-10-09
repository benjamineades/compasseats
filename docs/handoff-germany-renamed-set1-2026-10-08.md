# Handoff: CompassEats, Oct 8, 2026 (late night). Germany rename set 1 done (batch 12, 215 venues) and its slugs done (187). Next: Germany rename sets 2 and 3.

This file replaces `claude/handoff-germany-cleanup-done-2026-10-08.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-germany-cleanup-done-2026-10-08.md`: the cleanup record (ledger 91–92, audit 108,051–108,068), Ben's Q1/Q2 precedent, the lists for Plan v1.30.
- `claude/handoff-germany-promoted-2026-10-08.md`: the promote record (1a city fix, decisions file, Wirsberg, new venue ids, the 13 medium pairings).
- `claude/handoff-germany-staged-run1-2026-10-08.md`: Germany source facts (ceremony URLs, capture counts, status register, legacy-row profile).
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- `claude/handoff-chengdu-renamed-reviewed-2026-09-28.md`: the Sep 28 ruling and Ben's decisions; the Chengdu rename and slug method.
- `handoff-plan-v129-done-2026-09-28.md` and `handoff-michelin-chengdu-2027-done-2026-09-28.md`: methods, dead ends, database notes.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps).
- Suggest a handoff break before a new large block of work.

## Live state
Population: whole table. Read Oct 9, 01:57 UTC (Oct 8, 21:57 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,223 (active 10,859, closed 364) |
| awards | 22,389 |
| Michelin 2025 / 2026 / 2027 rows | 3,791 / 4,804 / 47 |
| listings / slugs | 11,223 / **12,509** (canonical 11,223, non-canonical **1,286**) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,850 |
| price | 7,048 (10 `guide_ingest`) |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **71** (last id **94**) |
| audit_log | **105,064** (last id **108,872**) |
| ingest_batches | 1, 3–13 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, **12** applied. rename_rows **766** |
| Germany Michelin 2026 rows (DE city) | 484, 0 unsourced |

## Done in this session (Oct 8, 20:57–21:56 Atlanta)

**Start check:** all counts, ledger 92, audit 108,068, Germany 2026 sourced 484 / unsourced 0 matched. Repo commit `51ae911`: `docs/cleanup-michelin-de-status-active.sql` `ee21e9b5…53cf3b`, `docs/cleanup-michelin-de-rows.sql` `29018b7c…4fe6297`, `docs/source-url-michelin-2026-germany-jakob.sql` `4fccd8fe…d3923b4` (all correct).

**Rename population (finding).** Population: the 484 Germany Michelin 2026 rows. 483 join to `fixtures/ingest/michelin-2026-germany.csv` by `source_url` (Gasthaus Jakob 7349 has the list URL, no card). **280 venues** have a name different from the card `venue_name` (the cleanup handoff listed about 19 examples; France had 281). Split by the Sep 14 naming rulings (Plan v1.29, line 394):
- **Set 1, 215 venues:** Michelin is the only publisher on the venue, and the card name has no spaced dash or " | ". Ruling 3 ("one publisher only" clause) → card name. **Done.**
- **Set 2, 15 venues:** card name has a spaced dash (" - " or " – ") or " | ". Ruling 2 → confirm against the venue's own site. **Open.**
- **Set 3, 50 venues:** other publishers print the venue. Ruling 3 → majority spelling. 0 of their other-publisher rows have a `source_url`, so each spelling must be read from the publisher's own page. **Open.**

**Set 1 rename (batch 12, key `rename-michelin-2026-germany`).**
- File `fixtures/rename/michelin-2026-germany-names.csv`, 215 rows, LF, sha256 `753d3d4153e99b5b696cf9ca6ccbc39eb4f0f56803f7e7848b2bf134b31eb908` (repo commit `ad139e0`). `expected_name` = live name from the database read; `new_name` = fixture `venue_name` (no retyping). Notes: 18 "case only", 197 "Michelin 2026 card name".
- Read-only check before the "go" (md5 guard `b16db2f4…e757` of `venue_id|expected|new`): 0 missing, 0 name moved, 0 no-change, 0 closed, 0 other-publisher rows, 0 blurbs, 0 earlier renames, key free, 0 same-city `norm_key` collisions. 1 NULL `norm_key`: "5" (Stuttgart, `ve_ff9f2ff3ef`; "Co-" precedent).
- Ben: question on 7 rows that add a hotel/place/chef with no dash (Le Jardin de France im Stahlbad, Pinus im Seegut, Esszimmer im Oberschwäbischen Hof, Restaurant Corona im Hotel zur Post, Kaupers Restaurant im Kapellenhof, Wirtsstube im Hotel Burkhard, Harzfenster by Johannes Steingrüber) → **option A, keep the card name** (ruling 1 covers only a spaced dash).
- Dry run (Ben): 215 rename, 0 reject, 0 review, 10 invariants pass, "where else the name is stored": nothing in 91 text columns. Used ledger 93, batch 11, audit 108,069–108,283 (rolled back).
- Real run (Ben, Oct 9 01:51:46 UTC): batch id **12**, ledger **94** (michelin, name, 215, `rename-apply:rename-michelin-2026-germany`), audit **108,284–108,498** (215 venues UPDATE, one timestamp, name only). Live names md5 `89b95a65…3b8522` = file. Report `reports/rename-michelin-2026-germany-rename.md` commit `aa82e6d`, sha256 `9f4ff688…e1bc51`.

**Set 1 slugs (`slugs-rename-michelin-2026-germany.sql`, 148 lines, sha256 `aba63b2b009fe5eeb025fa0300f4603d404047f8e249d6fb445b9832e30108db`, repo `docs/`, commit `ae8b61a`, checked).**
- Template: `docs/slugs-rename-michelin-2027-chengdu.sql`. Plan from `rename_rows` batch 12, filter `new_slug <> old_slug`: 215 venues, **28 keep their slug** (case-only and same-key renames), **187 plan rows**, fingerprint `55bcb18710dbaf5c1fec07299b17ab82`.
- Slug rule: `trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g'))`. Equals `slug.ts` on 212 of 215. Differ: Cølbo `colbo` (slug.ts `c-lbo`), Nußbaumerin `nussbaumerin` (`nu-baumerin`), Ich weiß ein Haus am See `ich-weiss-ein-haus-am-see` (= old slug; slug.ts `ich-wei-…`). **Ben: option A, the `f_unaccent` rule.**
- Ben "go". Write connector, first try, committed Oct 9 01:56:26 UTC. All gates passed. slugs 12,322 → 12,509; non-canonical 1,099 → 1,286; canonical 11,223. Audit **108,499–108,872** (187 slugs UPDATE + 187 INSERT, one timestamp). No ledger row. All 215 batch venues now hold a canonical slug equal to the rule.
- Examples: `/aschau-im-chiemgau/epicures`, `/pleiskirchen/restaurant-alexander-huber`, `/stuttgart/5` (was `stuttgart-mzj0p0`), `/munich/1804-hirschau` (was `munich-fvcnf8`), `/klingenberg-am-main/colbo`, `/berlin/nussbaumerin`.

## Decisions by Ben (this session)
- Set 1, the 7 "im/by" rows with no dash: **A**, keep the card name.
- Slug rule for ß/ø names: **A**, the `f_unaccent` database rule (not `slug.ts`).

## Set 2: 15 venues, card name has a spaced dash or " | " (ruling 2, venue's own site)
Rule: every spaced dash is confirmed against the venue's own site; sources disagree or unreachable = no rename. The pipe is not named in the ruling; Claude grouped the 2 pipe rows here (Ben has not ruled on the pipe). France method: the Michelin venue page "Stay at the hotel" block settles a hotel suffix. Line = fixture line.
- line 18 `ve_28cc28bd85` Rust: "Ammolite – House of Light" → card "Ammolite - House of Light"
- line 69 `ve_cd2f7ba3a5` Bietigheim Bissingen: "Maerz Restaurant" → card "Maerz - Das Restaurant"
- line 72 `ve_deb007b6bd` Donaueschingen: "hotel die burg" → card "die burg - fine dining"
- line 85 `ve_97a6a500a3` Grenzach-Wyhlen: "Eckert Fine Dining" → card "Eckert | Fine Dining"
- line 137 `ve_70803bb3f6` Kirchdorf: "Christians Restaurant - Christian F. Grainer" → card "Christian's Restaurant - Gasthof Grainer"
- line 162 `ve_e91ff49724` Nuremberg: "ZweiSinn Meiers - Bistro "à-la-carte-Restaurant"" → card "ZweiSinn Meiers | Fine Dining"
- line 214 `ve_b7c3a95507` Eltville am Rhein: "Pfortenhaus Kloster Eberbach" → card "Ente Wiesbaden - Pfortenhaus Kloster Eberbach" (temporary site; on the recheck list)
- line 230 `ve_ce8789421f` Feldberger Seenlandschaft: "Hotel & Restaurant Alte Schule Fürstenhagen - Daniel Schmidthaler" → card "Alte Schule - Klassenzimmer"
- line 293 `ve_b2449fc6ee` Bad Neuenahr-Ahrweiler: "Brogsitter Gasthaus Sanct Peter" → card "Restaurant Brogsitter - Historisches Gasthaus Sanct Peter"
- line 386 `ve_68870e5395` Bischofswiesen: "Kulturhof Stanggass" → card "Kulturhof Stanggass - Gasthaus"
- line 397 `ve_c86214d7a6` Gmund am Tegernsee: "Restaurant Ostiner Stub'n" → card "Hirsch & Jägerstüberl - Ostiner Stub'n"
- line 414 `ve_8a307c9575` Presseck: "Berghof Restaurant Ursprung" → card "Gasthof Berghof - Ursprung"
- line 424 `ve_f208304e7d` Wackersberg: "Tölzer Schießstätte am Buchberg - Michaela Hager" → card "Tölzer Schießstätte - Hager"
- line 464 `ve_4642412030` Vreden: "Büschker's Stuben" → card "Am Kring - Büschker's Stuben"
- line 477 `ve_4a64b5f6c8` Aue Bad Schlema: "Tausendgüldenstube" → card "Lotters Wirtschaft - Tausendgüldenstube"

## Set 3: 50 venues with other publishers (ruling 3, majority; tie → venue's own site)
Publishers (venues): La Liste 36, Gault&Millau 31, OAD 10, Best Chef 9, World's 50 Best 3. Counts in brackets = award rows on the venue. Line 26 Alois also has a spaced dash in the card (ruling 2 applies too).
- line 2 `ve_46b86c736a` Baiersbronn: "Restaurant Schwarzwaldstube" → card "Schwarzwaldstube" (best-chef 1, gault-millau 4, la-liste 1, w50b 5)
- line 3 `ve_4a8dad246a` Grassau: "Restaurant ES:SENZ" → card "es:senz" (best-chef 2, gault-millau 1, la-liste 1)
- line 4 `ve_fb89a8302d` Munich: "Jan" → card "JAN" (best-chef 2, gault-millau 2, la-liste 1, oad 1, w50b 1)
- line 7 `ve_42dc793e5d` Hamburg: "HAERLIN" → card "Restaurant Haerlin" (best-chef 1, gault-millau 2, la-liste 1)
- line 8 `ve_ed5192118c` Hamburg: "The Table" → card "The Table Kevin Fehling" (best-chef 2, gault-millau 1, la-liste 1, oad 1)
- line 12 `ve_23bb4d35e7` Perl: "Victor’s Fine Dining by Christian Bau" → card "Victor's Fine Dining by christian bau" (best-chef 2, gault-millau 4, la-liste 1)
- line 14 `ve_aeba0a7456` Donaueschingen: "ÖSCH NOIR" → card "Ösch Noir" (la-liste 1)
- line 15 `ve_5620195654` Karlsruhe: "restaurant sein **" → card "sein" (la-liste 1)
- line 16 `ve_7f35ac70b7` Constance: "Gourmetrestaurant OPHELIA**" → card "Ophelia" (la-liste 1)
- line 19 `ve_e7df93eca0` Schluchsee: "Landhaus Mühle Schluchsee" → card "Mühle" (la-liste 1)
- line 21 `ve_c400f8c12c` Sulzburg: "Hotel Restaurant Hirschen - Douce Steiner" → card "Hirschen" (gault-millau 1, la-liste 1)
- line 23 `ve_999fa337ae` Augsburg: "August" → card "AUGUST" (la-liste 1)
- line 24 `ve_8420b51edf` Berchtesgaden: "Gourmet Restaurant PUR" → card "PUR" (la-liste 1)
- line 25 `ve_3e88f531ea` Krün: "IKIGAI **" → card "IKIGAI" (gault-millau 2, la-liste 1)
- line 26 `ve_4ea2da3ad7` Munich: "Restaurant Alois - Dallmayr Fine Dining" → card "Alois - Dallmayr Fine Dining" (best-chef 1, gault-millau 1, la-liste 1)
- line 38 `ve_ecf8981481` Berlin: "Restaurant Facil" → card "FACIL" (gault-millau 3, la-liste 1)
- line 40 `ve_a4c05fac5d` Berlin: "Restaurant Tim Raue" → card "Tim Raue" (best-chef 2, gault-millau 4, la-liste 1, oad 1, w50b 8)
- line 43 `ve_0d5b0c077c` Frankfurt: "Relais & Châteaux Restaurant Lafleur" → card "Lafleur" (gault-millau 2, la-liste 1)
- line 47 `ve_746d8b48a8` Hanover: "VOTUM" → card "Votum" (gault-millau 1, la-liste 1)
- line 49 `ve_840175e4a2` Köln: "Ox&Klee" → card "Ox & Klee" (best-chef 2, gault-millau 2, la-liste 1)
- line 50 `ve_7a698e2407` Münster: "Cœur D'Artichaut" → card "Coeur D'Artichaut" (la-liste 1)
- line 51 `ve_4a2f3e3575` Bad Neuenahr-Ahrweiler: "Steinheuers Landgasthof Poststuben" → card "Steinheuers Restaurant" (gault-millau 2, la-liste 1)
- line 52 `ve_7b61b769fd` Koblenz: "GOTTHARDT'S by Yannick Noack" → card "Gotthardt's by Yannick Noack" (la-liste 1)
- line 53 `ve_9e5c4b5555` Wachenheim an der Weinstraße: "Restaurant Intense" → card "Intense" (gault-millau 1, la-liste 1, oad 1)
- line 54 `ve_7d7276d37a` Saarbrücken: "Esplanade" → card "ESPLANADE" (gault-millau 1, la-liste 1)
- line 55 `ve_57e91b5227` Saarbrücken: "Gästehaus Klaus Erfort" → card "GästeHaus Klaus Erfort" (gault-millau 3, la-liste 1)
- line 58 `ve_088567d150` Wernigerode: "Restaurant Pietsch" → card "Pietsch" (gault-millau 1, la-liste 1)
- line 59 `ve_de2b6590e5` Glücksburg: "Restaurant Meierei Dirk Luther" → card "Meierei Dirk Luther" (gault-millau 3, la-liste 1)
- line 80 `ve_b7cbf06c68` Freiburg im Breisgau: "Restaurant Eichhalde" → card "Eichhalde" (oad 1)
- line 83 `ve_c0720f338d` Freiburg im Breisgau: "Wolfshöhle" → card "Zur Wolfshöhle" (la-liste 1)
- line 87 `ve_46a88e85fa` Heidelberg: "Oben Restaurant" → card "Oben" (oad 1)
- line 96 `ve_d778d7e03c` Ravensburg: "Restaurant Kaisersaal" → card "Kaisersaal" (gault-millau 1)
- line 115 `ve_9e878421ec` Vaihingen an der Enz: "Hotel Restaurant Lamm Rosswag" → card "Lamm Rosswag" (la-liste 1)
- line 147 `ve_ab9eb80120` Munich: "Brothers Restaurant" → card "Brothers" (la-liste 1, oad 1)
- line 151 `ve_6036462df1` Munich: "Restaurant Sparkling Bistro" → card "Sparkling Bistro" (oad 1)
- line 152 `ve_07c3761513` Munich: "RESTAURANT TANTRIS DNA" → card "Tantris DNA" (la-liste 1)
- line 183 `ve_caf8559280` Würzburg: "MiZAR Fine Dining" → card "MiZAR" (gault-millau 1)
- line 189 `ve_b6778cce32` Berlin: "Hallmann und Klee" → card "hallmann & klee" (gault-millau 1)
- line 203 `ve_bc805069c7` Hamburg: "hæbel" → card "HAEBEL" (gault-millau 1)
- line 206 `ve_4a5030d511` Hamburg: "Koer Kulinarik & Bar" → card "Koer" (gault-millau 1)
- line 208 `ve_757e354c50` Hamburg: "Petit Amour *" → card "Petit Amour" (gault-millau 1)
- line 209 `ve_5f55eb3fb2` Hamburg: "Restaurant Piment" → card "Piment" (gault-millau 1)
- line 211 `ve_6c889649ae` Hamburg: "Restaurant Zeik" → card "Zeik" (oad 1)
- line 217 `ve_5e0948ed6b` Frankfurt: "Bidlabu" → card "bidlabu" (oad 1)
- line 223 `ve_ce76dfd046` Frankfurt: "SEVEN SWANS" → card "Seven Swans" (gault-millau 1)
- line 224 `ve_c45d948825` Frankfurt: "SOMMERFELD Restaurant" → card "Sommerfeld" (gault-millau 1)
- line 273 `ve_81c0fbac28` Köln: "Restaurant La Société Köln" → card "La Société" (la-liste 1)
- line 286 `ve_606583641e` Pulheim: "Restaurant Gut Lärchenhof Köln-Pulheim" → card "Gut Lärchenhof" (la-liste 1)
- line 324 `ve_6f937f16f3` Leipzig: "Stadtpfeiffer Restaurant im Gewandhaus" → card "Stadtpfeiffer" (gault-millau 1, la-liste 1)
- line 333 `ve_4feabd098d` Sylt: "Bodendorfs im Landhaus Stricker" → card "BODENDORF'S" (gault-millau 2, la-liste 1)

Notes for set 3: the spelling vote is per publisher (one vote each, Michelin included), from each publisher's own current page; Google never votes. Ruling 3 says Michelin alone does not override the majority. A publisher whose page cannot be found does not vote (say so per row). Gault&Millau: find its own German site first and check that `gault-millau` is in `award_sources` (needed as `source_id` in the rename CSV); if its site cannot be read, ask Ben. La Liste: sitemap method (Sep 28 handoff). Best Chef: `thebestchefawards.com` event results. OAD: `web_fetch` on oadguides.com lists is a dead end (use the browser). World's 50 Best: the publisher's own list pages.

## Methods that worked (new)
- **Rename population in two steps:** (1) one Read query of all DE Michelin 2026 rows with venue name, status, city and other-publisher rows (the result exceeds the output limit and lands in a tool-results file); (2) a sandbox script joins it to the fixture by `source_url` and splits the differences into the three sets. Keep scripts in the scratchpad, run with `python3 -I`.
- **Rename CSV check query:** `VALUES (venue_id, expected, new)` generated from the CSV with an md5 guard; checks for missing, name moved, no-change, status, other-publisher rows, blurbs, earlier `rename_rows`, key used, same-city `norm_key` collisions on the end state of the batch, NULL `norm_key`.
- **Fresh read after a choice:** md5 of `venue_id|name` for the file's venue ids (one `unnest(array[…])` list) = md5 of `venue_id|expected_name` from the CSV.
- **Rename read-back:** md5 of live `venue_id|name` = file `venue_id|new_name`; md5 of the audit rows' `row_pk|old name|new name` = file guard; count of audit rows that change more than `name` (ignore the generated `norm_key`) = 0.
- **Slug file after a large rename:** filter the plan to `new_slug <> old_slug` and gate both counts (all rows and unchanged rows), because case-only renames keep their slug. Check the two slug rules (`f_unaccent` vs `slug.ts`) on the new names before the build: only non-decomposable letters (ß, ø, æ) differ.
- The Write connector ran a 148-line gated file on the first try (no "cancelled" this time).

## Dead ends: do not retry (new)
- `grep -v '^| ve_'` on the rename report (rows start with a backtick: use `'^| \`ve_'`).
- Expecting a query result that fits the output limit to land in a tool-results file: it comes back inline. If the next step needs it in the sandbox, return only what the next step needs, or compute the result in SQL.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/rename/michelin-2026-germany-names.csv` | Run (batch 12), in the repo (`ad139e0`) | `753d3d41…1eb908` |
| `reports/rename-michelin-2026-germany-rename.md` | Written by the job (`aa82e6d`) | `9f4ff688…e1bc51` |
| `docs/slugs-rename-michelin-2026-germany.sql` | Run (Write connector), in the repo (`ae8b61a`) | `aba63b2b…e30108db` |
| `docs/cleanup-michelin-de-status-active.sql`, `docs/cleanup-michelin-de-rows.sql`, `docs/source-url-michelin-2026-germany-jakob.sql` | In the repo (`51ae911`), checked | as in the cleanup handoff |

## Open items, in order
1. **Germany rename, sets 2 and 3 (next).** Set 2: browser pass on the 15 rows (Michelin venue page and the venue's own site), rulings 1 and 2; ask Ben on the 2 pipe rows and any row the sources do not settle. Set 3: read each publisher's own spelling for the 50 venues, apply the majority rule, tie → venue site. Then one rename CSV per set (keys `rename-michelin-2026-germany-dashes` and `rename-majority-2026-germany`, or one combined file if Ben prefers), names from the fixture or the publisher page, never retyped; `source_id` = the publisher whose spelling wins (or `venue`). Build, examine read-only, present, one "go" each; Ben runs dry run then real run. Then the slug file for the renamed venues (this session's file as the template), second "go".
2. **Plan v1.30** (content as item 2 of the cleanup handoff, plus: the 280 rename population and the three sets, rename batch 12 (ledger 94, audit 108,284–108,498; dry run ledger 93, batch 11, audit 108,069–108,283), the slug file (audit 108,499–108,872, 187 rows, 28 kept), Ben's two A decisions (7 im/by rows; `f_unaccent` slug rule)). Plan-edit method; read the Version line first (expect 1.29).
3. France slug set (148 venues). Ben decides when.
4. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
5. Price from the Michelin card (population to read again; known differences Rebers Pflug 7906, BOK 6670, Kuultivo 5902; 30 option-A venues and AURA / Starnberg have no price row). Ben chooses the method.
6. Later-ceremony guides, promote only: **Texas (due now)**, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
7. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Special-awards batch (Germany adds 4); Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
8. Rechecks, no date: Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente.
9. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs (`wei-enbrunn`, `ma-weiler`, `kirchheim-an-der-weinstra-e`, `wachenheim-an-der-weinstra-e`) vs the `f_unaccent` rule.
10. Project file cleanup, part 2: after the migration is done (list in the staged-run1 handoff, item 11).

## Suggested opening prompt
```
Read these handoffs from the project files with the Projects tool: claude/handoff-germany-renamed-set1-2026-10-08.md first, then claude/handoff-germany-cleanup-done-2026-10-08.md, claude/handoff-germany-promoted-2026-10-08.md and claude/handoff-germany-staged-run1-2026-10-08.md for the Germany facts, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends, then claude/handoff-chengdu-renamed-reviewed-2026-09-28.md, handoff-plan-v129-done-2026-09-28.md and handoff-michelin-chengdu-2027-done-2026-09-28.md. Confirm live counts, ledger id 94, audit_log id 108,872, slugs 12,509 and rename batch 12 applied with a Read query. Then start open item 1, Germany rename sets 2 and 3: for the 15 set-2 venues, check each spaced dash against the Michelin venue page and the venue's own site (rulings 1 and 2); for the 50 set-3 venues, read each publisher's own spelling and apply the majority rule. Tell me in /ste style which names change, and ask me about any row the rules do not decide. Then build the rename CSV files from the fixture and the publisher pages, examine them read-only, and wait for my go.
```
