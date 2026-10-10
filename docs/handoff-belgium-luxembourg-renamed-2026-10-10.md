# Handoff: CompassEats, Oct 10, 2026 (17:20 Atlanta). Belgium & Luxembourg: orphans settled (status file run), rename batch 20 applied (98 venues). Next: slug file (1c).

This file replaces `claude/handoff-belgium-luxembourg-retired-2026-10-10.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-belgium-luxembourg-retired-2026-10-10.md`: the Belgium & Luxembourg capture, stage (batch 15), promote (ledger 109-110) and retire (ledger 111) record, key ids, hold register.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check, the sequence read after a dry run, the **slug-file method** (template `docs/slugs-rename-michelin-2026-texas.sql`), the status-only file method.
- `claude/handoff-germany-renamed-sets23-2026-10-09.md`: the vote method and the Q1-Q4 rulings.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, venue-delete method, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`, checked Oct 10): rule 2.1.1, rule 2.1.7, the Sep 28 standing rules.

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

## NEW standing rule (Ben, Oct 10, 17:07)
**Name ties and doubt: the venue's own spelling wins; Michelin is the fallback.** "When in doubt, or in a tie and a deal breaker needs to happen, favor the venue's own spelling and have Michelin be the fallback." The vote (majority across publishers that hold a row on the venue) still comes first; this rule settles ties and unclear cases. Applied to the Belgium & Luxembourg file: it changed no rule-decided row. Add to Plan v1.31 with the other Oct 10 decisions.

## Live state
Population: whole table. Read Oct 10, 21:19 UTC (17:19 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,233 (active 10,867, closed 366) |
| awards | 22,463 |
| Michelin 2025 / 2026 / 2027 rows | 3,545 / 5,124 / 47 |
| Michelin rows with `source_url` | 4,583 |
| listings / slugs | 11,233 / 12,576 (canonical 11,233, non-canonical 1,343) |
| venues with more or less than 1 canonical slug | 0 |
| venues with two Michelin rows of one year and category | 0 |
| venue-years with two Michelin categories | 18 (unchanged) |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,870 |
| price | 7,048 (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **83** (last id **117**) |
| audit_log | **105,953** (last id **110,286**) |
| ingest_batches | 1, 3-15 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, **20** applied (19 = rolled-back dry run). rename_rows **941**. Sequence last value 20. |

## Done in this session (Oct 10, 16:49 to 17:19 Atlanta)

**Start check:** all counts, ledger 111 and audit 110,088 matched the retired handoff. Plan sha256 correct in a fresh clone.

**1a. Orphans (3 legacy Michelin 2025 rows with no 2026 card).** All three Michelin pages give 404 "Restaurant not found" in us/en and the Belgian locales (built-in browser, Oct 10). Michelin does not say "closed".
- **La Paix** `ve_54dcd1ca27` (Brussels): closed → **active** (Ben Q1 B: relocation in the same city = same business). Anderlecht site closed July 3, 2026 (BX1); reopened Sep 15, 2026 at the Corinthia Grand Hotel Astoria, 103 rue Royale, Brussels; same name, chef David Martin (La Libre Jun 20, Paris Match Jun 4, Elle Belgium Sep 28). Awards kept: 1443 Michelin 2025 Two Stars, 1444 Best Chef 2025, 1445 OAD 2025, 1446 La Liste 2026. The standing rules did not cover a same-city relocation; Ben's B is the precedent. Recheck when Michelin publishes a card for the new address.
- **La Table de Manon** `ve_a5ee6f10f9` (Grandhan): active → **closed** (evidence agrees: Paris Match Sep 23, 2026 reports the venue site's permanent-closure notice; Paris Match Oct 5 refers to it; card gone). Venue site did not load in the pane; WebFetch robots-disallowed. Award kept: 5195.
- **Kommilfoo** `ve_697073dab3` (Antwerp): **no change, recheck list** (conflicting evidence: card gone, 2026 star article lists it at One Star, venue site `restaurantkommilfoo.be` live with menu, phone and Tablefever booking widget; no closure press). Dill precedent.
- File `docs/cleanup-michelin-2026-be-status.sql` (95 lines, ASCII), sha256 `e0225f4300629f52de0f558b36c5a05858d772b8c5ae92c3387a32e6f42b6bca`, repo commit `5f6b5dd`. Guards: id md5 `e1da375e1fb84b9cfa9f47cef0175c20`, name/city/status per venue, award ids 1443 and 5195, 5 award rows, before/after counts. pglast check passed; dry run (Read connector) stopped at the first UPDATE.
- Ben "go A". Write connector, first try, Oct 10 **21:12:42 UTC**. Audit **110,089** (La Paix closed→active) and **110,090** (La Table de Manon active→closed), status-only, one timestamp. active 10,867 and closed 366 unchanged (one each way). No ledger row.

**1b. Rename (batch 20, key `rename-michelin-2026-belgium-luxembourg`).**
- Population: the 247 batch 15 award rows joined to `ingest_rows` by `source_url`; card ≠ `venues.name` on **99** venues (39 case-only; 58 same `norm_key`). Line = `raw->>'_line'` = fixture data row.
- Inputs: live names read as hex (`encode(convert_to(name,'UTF8'),'hex')`) so the copy is ASCII; md5 of `line\tvid\tname` = SQL `ffac08bd88f017210eeb021fa3eef394`. Card names from the fixture (sha256 guard `4163c11d…`); md5 of `line\tcard\turl` = `ingest_rows` `4ae504bc73c0897b3151525baebaa4d9`.
- Votes read (Oct 10) for the 10 venues with other publishers:
  - La Liste places pages (sitemap from a laliste.com tab, 6,986 URLs): Hof van Cleve, Vrijmoed, Lea Linster, Fields, L'Air du Temps (U+0027), Hertog Jan at Botanic Antwerp.
  - OAD Europe 2025 (`/lists/europe/top-restaurants/2025`, wait 5 s): Hertog Jan Botanic, L’Air du Temps (U+2019), Oak Gent, Humus x Hortense, Vrijmoed, "Benoit et Bernard Dewitt" (sic, No. 495).
  - Best Chef 2025 (`events-results/?id=2376`): Hertog Jan at Botanic, L'Air du Temps (U+0027), Benoît & Bernard Dewitte, Hof van Cleve, HumusxHortense.
  - World's Best Steaks `worldbeststeaks.com/the-list` (the `award_sources` URL; `worldsbeststeaks.com` redirects elsewhere): "CARCASSE" (all names in capitals), Koksijde.
  - Venue sites: oakgent.be "Oak Gent"; humushortense.be mixed "humus × hortense"/"humus x hortense"; restaurantdewitte.be → benoitdewitte.be "Benoit Dewitte | Kruisem"; louis-linster.lu "Louis Linster"; airfield.lu "Fields"/"fields Restaurant"; carcasse.be "Carcasse" (2nd location Carcasse Knokke-Heist).
- Results: Hof van Cleve **no change** (card chef suffix cut before the vote = live; not in the file; its blurb untouched). Hertog Jan → Hertog Jan at Botanic (2 of 4). Vrijmoed (3 of 3). L'Air du Temps (La Liste + Best Chef, 2 of 4). Oak → Oak Gent (tie → venue site). Louis Linster (tie → venue site). Carcasse (Q4 precedent).
- **Ben's decisions (Oct 10):** Q2 **A** keep the 37 case-only rows; Q3 **A** "humus x hortense" (Michelin); Q4 **C** "Benoit Dewitte" (venue site, source `venue`); Q5 **A** "Fields" (La Liste = venue spelling); Q6 **A** NFC "Grünewald Chef’s Table" (U+2019 kept). Sense and Brasserie N4 take the card (pairing Q1/Q2 A earlier). Emoji/marks in stored names dropped by the card ("Mona Lisa 🇮🇹", "Le Tournant ️" U+FE0F, "Le Grand Verre *", "Sel et Poivre®").
- File `fixtures/rename/michelin-2026-belgium-luxembourg-names.csv`: 98 rows, LF, sha256 `e42f9a7e0c6f04c05cec28723c20bad6a316f2136d303b347dc63f5578bf7749`, repo commit `2bd6762`. Sources: michelin 94, la-liste 2, oad 1, venue 1. Parsed by `loadRenameCsv`: 98 rows, 0 duplicates; md5 expected `10ac1ce5a5f4fde0bb65013d7b14c5ce`, new `0a85341165e152161cf4de1cf120ea03` (by venue_id). Read-only: 0 same-city `norm_key` collisions, 0 slugs taken, 0 in `redirects`, 0 earlier rename rows, 0 inactive.
- **Correction to the retired handoff:** the 99 venues hold **1** blurb (Hof van Cleve, `needs_rewrite`), not 2. The renamed 98 hold 0.
- Dry run (Ben, 21:13 UTC, report commit `fce21be`): 98 rename, 0 reject, 0 review, 10 of 10 invariants; report pairs md5 = file. Used batch 19, ledger 112-114, audit 110,091-110,188 (rolled back).
- **Real run (Ben "go B", Oct 10 21:17:49 UTC):** batch **20** `applied`; rename_rows 98 (941 total); ledger **115** (la-liste, name, 2), **116** (michelin, name, 94), **117** (oad, name, 1), job `rename-apply:rename-michelin-2026-belgium-luxembourg`; the `venue` row has no ledger row by design. Audit **110,189-110,286** (98 venues UPDATE, one timestamp, 0 change more than name/norm_key). Live names md5 = file `new_name`; audit old→new md5 `880537f2bfd9239bfbc20728bef4f243` = file. Real-run report commit `224bca5`, sha256 `0ddbfcb520dcc6d1af848ba489d1312aa218c54e37415fb0e89e182ab2cac00e`.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/cleanup-michelin-2026-be-status.sql` | Run (audit 110,089-110,090), in the repo (`5f6b5dd`) | `e0225f43…6bca` |
| `fixtures/rename/michelin-2026-belgium-luxembourg-names.csv` | Run (batch 20), in the repo (`2bd6762`) | `e42f9a7e…bf7749` |
| `reports/rename-michelin-2026-belgium-luxembourg-rename.md` | Real-run report (`224bca5`) | `0ddbfcb5…ac00e` |

## Open item 1c: slug file (next)
Population: the 98 venues of rename batch 20. Read before the rename (card/final names, rule `trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g'))`): **41 need a new canonical slug**, 57 keep it; 0 new slugs taken in the same city; 0 in `redirects`. Expected after the write: slugs 12,576 → 12,617; non-canonical 1,343 → 1,384; canonical 11,233. Examples: `/antwerp/hertog-jan` → `hertog-jan-at-botanic`; `/waasmunster/hangzhou-at-west-lake-four-seasons-hotel-chinese-food-restaurant` → `sense`; `/martelange/le-vertige-des-saveurs-hotel` → `brasserie-n4`; `/gent/oak` → `oak-gent`; `/ouwegem/benoit-bernard-dewitte` → `benoit-dewitte`; `/findel/fields-restaurant` → `fields`. Grünewald (NFC) keeps `grunewald-chef-s-table`. Re-read the plan from `rename_rows` batch 20 before the build. Template `docs/slugs-rename-michelin-2026-texas.sql` (157 lines); gate the plan row count, the kept count and a plan fingerprint; dry run through the Read connector; one "go" (Write connector).

## Methods that worked (new)
- **ASCII copy of live names:** read `encode(convert_to(name,'UTF8'),'hex')` packed in one string, write it to a file, decode in Python, compare the md5 with the SQL md5. Keeps invisible characters (U+FE0F, combining marks) exact.
- **Check query on final names:** generated `VALUES` with `U&'…'` escapes and an in-SQL md5 guard; one query gives collisions, slug changes, slugs taken, redirects and blurbs.
- **Michelin card "Visit website" link:** in the pane on guide.michelin.com, `fetch(path)` + DOMParser, `a` with text "website" → the venue site URL, for many cards in one call.
- **Report vs file check:** parse the dry-run report's downstream table (unescape `\|`), md5 of sorted `vid\tfrom\tto` = file `vid\texpected\tnew`.
- **Status file with one venue each way:** two UPDATEs with per-venue ROW_COUNT checks; status-only audit check with old/new per venue.

## Dead ends: do not retry (new)
- Running a script from inside the cloned repo directory (auto-mode denial "Code from External"). Put scripts in the scratchpad and pass repo paths as arguments (`python3 -I script.py /tmp/ce/...`).
- `latabledemanon.be` in the pane (load fails) and WebFetch (robots-disallowed).
- `www.kommilfoo.be` is a cabaret duo; the restaurant is `restaurantkommilfoo.be`.
- `worldsbeststeaks.com` (redirects to an unrelated site); use `worldbeststeaks.com/the-list`.
- A leaf-element search over the whole World's Best Steaks page (result 338 KB; saved to file). Match the exact name instead.

## Open items, in order
1. **Belgium & Luxembourg cleanup:** a. done (status file). b. done (batch 20). **c. Slug file (next, above).**
2. **Switzerland after Nov 2, 2026** (option A, promote only).
3. **Hold registers:** Texas (Barley Swine 2026 Service Award; Mindful Voices on Dai Due, Emmer & Rye, Nixta Taqueria, Isidore) and Belgium & Luxembourg (Young Chef Abel Demeestere, Sommelier Nicolas Campus, Service Zilte, Opening La Villa Lorraine; Mindful Voices Màloma, Nova) → special-awards batch.
4. Price from the Michelin card (4,225 venues + Texas cards + 247 BE/LU `€` cards). Ben chooses the method. `price_capable` is false for Michelin.
5. France slug set (148 venues). Ben decides when.
6. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
7. Later-ceremony guides, promote only: American South after Oct 21; Beijing & Tianjin after the end of October; Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
8. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues; Glovers Alley → by Adam Nevin; Shu Di Dang Gui → "Shudidanggui (Wuhou)"). Re-check them under the new tie rule. Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
9. Rechecks, no date: **Kommilfoo (new)**, **La Paix (Michelin card for the new address)**, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
10. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes.
11. Repo `.env`: Ben to check that the Google Maps and MapTiler browser keys are restricted by HTTP referrer.
12. Plan v1.31: the Oct 9 decisions, the Texas result, the 66-row correction, the Killen's correction, the Belgium & Luxembourg record (batch 15, ledger 109-111, retire, Q1/Q2), **this session** (status file audit 110,089-110,090; La Paix relocation precedent; rename batch 20, ledger 115-117, audit 110,189-110,286; Q2-Q6; the blurb correction), **and the new tie rule**.
13. Project file cleanup, part 2: after the migration is done.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-belgium-luxembourg-renamed-2026-10-10.md first, then claude/handoff-texas-done-2026-10-10.md for the slug-file method, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 117, audit_log id 110,286, slugs 12,576 and rename batch 20 applied with a Read query. Then start open item 1c: build the gated slug SQL file for the venues of rename batch 20 whose slug changes (template docs/slugs-rename-michelin-2026-texas.sql), examine it read-only, present it in /ste style, and wait for my go.
```
