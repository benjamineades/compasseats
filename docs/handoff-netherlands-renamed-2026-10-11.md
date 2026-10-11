# Handoff: CompassEats, Oct 11, 2026 (16:05 Atlanta). Netherlands rename batch 22 applied (83 venues, ledger 123, audit 110,979-111,061). Next: Netherlands slug file (71 venues).

This file replaces `claude/handoff-netherlands-promoted-2026-10-11.md` for live state, decisions, open items, methods and dead ends. The other files still apply as before:
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the Netherlands stage and promote record (7 NL cities, batch 16, ledger 120-121, audit 110,370-110,895), the 21 new venues, the 11 legacy rows with no 2026 card, the decisions-file pairing order.
- `claude/handoff-netherlands-captured-2026-10-10.md`: the capture record, the De Groene Lantaarn close (audit 110,369), the hold register, the "nothing below a Bib" rule.
- `claude/handoff-belgium-luxembourg-renamed-2026-10-10.md`: the batch 20 rename record and the tie rule.
- `claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md`: the slug-file record and the slug check against `slug.ts` (model for the next step).
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check, the slug-file method (template `docs/slugs-rename-michelin-2026-texas.sql`).
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`): rule 2.1.1 (amended Sep 24), rule 2.1.7, the Sep 28 standing rules.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".
- Build the file first, examine it read-only, present it, then ask for choices. After a choice: fresh read, rebuild if needed, then wait for "go".
- Claude runs gated SQL through the Write connector after Ben's "go". If the connector returns "cancelled", read the database to prove no change, retry once only, then Ben runs the same file in the Supabase SQL Editor. Ben uploads chat files to the repo and runs the GitHub Actions jobs (give click steps). Ben starting a stage, promote or real rename job is his "go".
- Suggest a handoff break before a new large block of work.
- Plan versions, briefs and handoffs are saved to the project over the same name (`project_write` with `local_path`).
- Name ties and doubt (Ben, Oct 10): the vote first; in a tie or unclear case the venue's own spelling wins, Michelin is the fallback.
- CompassEats does not track anything below a Michelin Bib (Ben, Oct 10).

## Live state
Population: whole table. Read Oct 11, 20:04 UTC (16:04 Atlanta), after the real rename run.

| Table | Count |
|---|---|
| venues | 11,254 (active 10,887, closed 367) |
| awards | 22,659 |
| Michelin 2025 / 2026 / 2027 rows | 3,545 / 5,320 / 47 (plus 2023 = 18, 2024 = 25) |
| listings / slugs | 11,254 / 12,638 (canonical 11,254, non-canonical 1,384) |
| cities / city_aliases / city_label_source | 3,258 / 259 / 23,912 |
| price / blurbs / redirects | 7,048 / 142 / 9 |
| source_capture_ledger | **86** (last id **123**) |
| audit_log | **106,386** (last id **111,061**) |
| ingest_batches | 1, 3-16 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, **22** applied (21 = rolled-back dry run). rename_rows **1,024**. Sequence last value 22. |

## Done in this session (Oct 11, 12:03 to 16:04 Atlanta)

**Start check:** all counts, ledger 121, audit 110,895, batch 16 promoted, rename batch 20 last applied, rename_rows 941 matched the promoted handoff.

**Netherlands rename (batch 22, key `rename-michelin-2026-netherlands`).**
- Population: the 196 batch-16 award rows (ids 28,898-29,093) joined to `ingest_rows` (batch 16) by `source_url`; card ≠ `venues.name` on **86** venues (2 case-only, 9 same `norm_key`, 75 other). Line = `raw->>'_line'` = fixture data row. 0 blurbs, 0 earlier rename rows on the 86.
- Inputs: live names read as hex (md5 of `line\tvid\tname` = `440666eb99ef9832082fe69d34bfd193`); card names from the repo fixture (sha256 `aa72b5e6…d7b2`; md5 of `line\tcard\turl` = `50f600adbb749e2e2b9a05a5615f182a`, same in `ingest_rows`).
- Votes read Oct 11 in the built-in browser (10 venues, 19 other-publisher rows):
  - Best Chef 2025 (`thebestchefawards.com/events-results/?id=2376`): "De Nieuwe Winkel", "Brut172", "GEM.", "Parkheuvel", "Bougainville", "RIJKS®".
  - OAD Europe 2025 (`oadguides.com/lists/europe/top-restaurants/2025`, wait 5 s): "Restaurant Wils" (612), "Restaurant Voltaire" (512), "Perceel" (570, OAD prints city Amsterdam; the venue is in Capelle aan den IJssel), "De Nieuwe Winkel" (426), "Brut 172 by Hans van Wolde" (483).
  - La Liste 2026 (sitemap from a laliste.com tab, `/places/…` h1): "'t Nonnetje" (U+0027), "De Nieuwe Winkel", "Brut 172 by Hans van Wolde", "Parkheuvel".
  - Venue sites (card "Visit website" link): brut172.com "Brut172"; restaurantgem.com "Restaurant GEM."; restaurantwils.nl "Wils Restaurant" / "Restaurant Wils" / "Wils" (unclear); parcbroekhuizen.nl "Restaurant Voltaire*"; restaurantthewhiteroom.com "The White Room by Jacob Jan Boerma"; fgrestaurant.nl "François Geurds (FG) Restaurant" / "FG Restaurant" (no dash form); aubergeamsterdam.nl "Auberge cuisine Française"; rijksrestaurant.nl title "RIJKS®", h1 "Rijks Restaurant".
- Rule results: 't Nonnetje, De Nieuwe Winkel, Bougainville, Perceel = card (majority). Brut172 = card (chef suffix cut first; 2-2 tie "Brut172" vs "Brut 172"; venue site). **GEM.** = "GEM." (chef suffix " by Soenil Bahadoer" cut first; Michelin + Best Chef 2 of 2; not the card form). Wils = card (tie; venue site unclear; Michelin fallback). **Parkheuvel no change** (Best Chef + La Liste = live, 2 of 3). **Voltaire no change** (tie; venue site = live "Restaurant Voltaire"). The other 76: Michelin is the only publisher → card.
- **Ben's decisions (Oct 11, tappable):** Q1 A **"RIJKS"** (® dropped; slug stays `/amsterdam/rijks`; vote result was "RIJKS®", slug would have been `rijks-r`). Q2 A **"François Geurds (FG) Restaurant"** (source `venue`, fgrestaurant.nl; card "FG - François Geurds" not used by the venue). Q3 A **Auberge keeps "Auberge cuisine Française"** (venue title = live; not in the file). Q4 A **"The White Room by Jacob Jan Boerma"** (the venue uses the "by" form itself). Precedent applied without a question: case-only rows stay in the file (Divino → DiVino, Landgoed De Holtweijde → Landgoed de Holtweijde; Texas Q-A, Belgium Q2 A).
- File `fixtures/rename/michelin-2026-netherlands-names.csv`: **83 rows** (86 minus Parkheuvel, Voltaire, Auberge), LF, sha256 `9d48b090b46c47f7b5308cbb7969f5f5ee7eb7b2587b01c46539ffb48963d82f`, repo commit `aa2e6aa`. Sources: michelin 82, venue 1. Parsed by `loadRenameCsv`: 83 rows, 83 distinct venues, 0 blank. md5 expected `72663467f6bfb917e1162bf0e20c3c8e`, new `8a7850e26ea614125db8c8855d8cab30` (by venue_id, `vid\tname`).
- Read-only check (md5 guard `8a7850e2…`): 0 moved, 0 not active, 0 same-city `norm_key` collisions, 0 in-file collisions, 0 blurbs, 0 earlier rename rows; `norm_key` same on 12.
- Dry run (Ben, report commit `27d3e0f`, sha256 `959c35f4…bb6b92e0`): 83 rename, 0 reject, 0 review, 10 of 10 invariants. Report downstream-table pairs md5 = file `aea8703bb351bf8c4fadf9eee3217eea`. Used batch 21, ledger 122, audit 110,896-110,978 (rolled back).
- **Real run (Ben's run = "go", Oct 11 19:57:03 UTC):** batch **22** `applied`; rename_rows 83 (1,024 total); ledger **123** (michelin, name, 82, job `rename-apply:rename-michelin-2026-netherlands`); the `venue` row has no ledger row by design. Audit **110,979-111,061** (83 `venues` UPDATE, one timestamp, 0 changes beyond name/norm_key). Live names md5 = file new `8a7850e2…`; audit old→new md5 `aea8703b…` = file. Real-run report commit `bbb39c5`, sha256 `09a56d168c6ec2381a10e4ea8500bfa2717b130d89b854564e2f5ede6393b15e`.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `fixtures/rename/michelin-2026-netherlands-names.csv` | Run (batch 22), in the repo (`aa2e6aa`) | `9d48b090…48963d82f` |
| `reports/rename-michelin-2026-netherlands-rename.md` | Real-run report (`bbb39c5`) | `09a56d16…e6393b15e` |

## Open item 1: slug file (next)
Population: the 83 venues of rename batch 22. Read before the rename with the final names (rule `trim(both '-' from regexp_replace(lower(f_unaccent(name)), '[^a-z0-9]+', '-', 'g'))`): **71 need a new canonical slug**, 12 keep it; 0 new slugs taken in the same city; 0 own non-canonical; 0 in `redirects`; 0 empty; 0 duplicates. Pre-rename plan md5 (`vid|city_slug|cur_slug|new_slug`, by vid) `2cc3c9c964089b6527667dbecf714fd2`. Expected after the write: slugs 12,638 → **12,709**; non-canonical 1,384 → **1,455**; canonical 11,254.
- Keep (12): 't Nonnetje, Restaurant Atelier, Pieters Restaurant, 't Amsterdammertje, 't Ganzenest, LEV by Mike, Te Koop in Tilburg, MOUT & HOUT, DiVino, Landgoed de Holtweijde, RIJKS, François Geurds (FG) Restaurant.
- Examples: `/gemert/restaurant-gem` → `gem`; `/reijmerstok/brut172-by-hans-van-wolde` → `brut172`; `/cromvoirt/noble-kitchen` → `nami`; `/warmond/mulberry-restaurant` → `de-moerbei`; `/utrecht/grand-hotel-karel-v` → `karel-5`; `/maastricht/chateau-neercanne` → `restaurant-chateau-neercanne`; `/amsterdam/de-kas` → `restaurant-de-kas`.
- Re-read the plan from `rename_rows` batch 22 before the build. Template `docs/slugs-rename-michelin-2026-texas.sql`; check the rule against `slug.ts`; gate the plan row count (71), the kept count (12) and a plan fingerprint; dry run through the Read connector; one "go" (Write connector).

## Methods that worked (new)
- **Votes in one browser pass:** Best Chef results page `innerText` search for each name; OAD list page after a 5 s wait; La Liste sitemap `<loc>` filter by slug words, then `fetch` + DOMParser `h1` per place page (same origin). Michelin card "Visit website" links for many cards in one call from a guide.michelin.com tab.
- **Venue site read:** `browser_batch` of navigate + one JS call returning title, `og:site_name`, h1/h2, img alt and name matches in `innerText`. Some sites need a subpage (restaurantwils.nl body is empty on `/`; use `/homenl`).
- **Chef suffix before the vote:** cut a publisher's chef suffix from every publisher's spelling first, then count (Brut172, GEM.). Keep a "by …" part only when the venue's own site uses it (White Room, Ben Q4).
- **Report vs file check:** take only the "Downstream impact" table (the report has other tables with `ve_` rows: 88 vs 83); md5 of sorted `vid\tfrom\tto`.

## Dead ends: do not retry (new)
- A self-join on the check CTE with `o.id`: the CTE column is `vid` (fix: `o.vid`, `o.nn`).
- Counting `| \`ve_` rows over the whole rename report (picks up other tables). Cut the "Downstream impact" section first.

## Open items, in order
1. **Netherlands slug file (next, above).**
2. **Netherlands status items:** Restaurant Daalder* `ve_3b8f5d3656` (active, no Michelin row, card gone, page "Restaurant niet gevonden"): read closure evidence, apply the standing rules. Read status evidence for Da Vinci, Sense and the 7 dropped Bibs (rows stay as history either way; only closure evidence gives `closed`).
3. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
4. **Switzerland after Nov 2, 2026** (option A, promote only).
5. **Gap list after the Netherlands:** retire-path countries Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; promote-only Taiwan, Singapore; Thailand after its 2027 edition (rule 2.1.7); Canada as three guides.
6. **Hold registers:** Texas, Belgium & Luxembourg, Netherlands (Mindful Voices: Bij Jef, Mearkas, De Librije/Nelson Tanate; special awards: Young Chef Rozewied `ve_12e1dee96f`, Service Restaurant Château Neercanne `ve_df2327ee2f`, Sommelier Brut172 `ve_face3f9c07`, Opening of the Year Restaurant Luwte (Groningen, Selected, no venue)) → special-awards batch.
7. Price from the Michelin card (adds the 196 NL `€` cards: €€€€ 77, €€ 75, €€€ 42, € 2). Ben chooses the method.
8. France slug set (148 venues). Ben decides when.
9. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
10. Later-ceremony guides, promote only: Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
11. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues), re-checked under the tie rule. Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
12. Rechecks, no date: Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
13. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount (the 7 new NL cities have `venues_count` 0); RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes; **trademark-sign policy** (Ben Q1 dropped ® for RIJKS; earlier "Sel et Poivre®" dropped because the card dropped it).
14. Repo `.env`: Ben to check that the Google Maps and MapTiler browser keys are restricted by HTTP referrer.
15. Plan v1.31: everything in the slug and brief handoffs, the Netherlands capture result, the "nothing below a Bib" rule, audit 110,369, the promoted session (7 NL cities, Q1/Q2, batch 16, ledger 120-121, audit 110,370-110,895), **plus this session** (rename batch 22, ledger 123, audit 110,979-111,061, Q1-Q4 of Oct 11, the chef-suffix-before-vote method, the "by" rule from Q4).
16. Options B (Phase 3 map-location pass) and C (publish builder): open for later.
17. Project file cleanup, part 2: after the migration is done.

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-netherlands-renamed-2026-10-11.md first, then claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md for the slug-file record and the slug.ts check, then claude/handoff-texas-done-2026-10-10.md for the slug-file method, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 123, audit_log id 111,061, slugs 12,638 and rename batch 22 applied with a Read query. Then start open item 1: build the gated slug SQL file for the venues of rename batch 22 whose slug changes (template docs/slugs-rename-michelin-2026-texas.sql), examine it read-only, present it in /ste style, and wait for my go.
```
