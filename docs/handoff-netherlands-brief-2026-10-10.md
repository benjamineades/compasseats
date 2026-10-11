# Handoff: CompassEats, Oct 10, 2026 (22:45 Atlanta). Gap list re-read, ceremony dates found, Netherlands chosen, Netherlands Cowork brief saved. Next: Netherlands capture in Cowork.

This file replaces `claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md` for live state, decisions and open items. The other files still apply as before:
- `claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md`: the slug-file record (audit 110,287-110,368), the slug check against `slug.ts`, the template rebuild method.
- `claude/handoff-belgium-luxembourg-renamed-2026-10-10.md`: the batch 20 rename record, the **tie rule** (Oct 10), its methods and dead ends.
- `claude/handoff-belgium-luxembourg-retired-2026-10-10.md`: the Belgium & Luxembourg capture, stage, promote and retire record (the model for the Netherlands stage).
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check, the slug-file method.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit, the stage dead ends.
- `claude/handoff-briefs-texas-belgium-2026-10-09.md`: the brief method, the edition label check.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`, checked Oct 10 in a fresh clone at `880e771`): rule 2.1.1 (amended Sep 24), rule 2.1.7.

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
- Name ties and doubt (Ben, Oct 10): the vote first; in a tie or unclear case the venue's own spelling wins, Michelin is the fallback.

## Live state
Population: whole table. Read Oct 11, 01:38 UTC (Oct 10, 21:38 Atlanta). **No database table changed in this session.**

| Table | Count |
|---|---|
| venues | 11,233 (active 10,867, closed 366) |
| awards | 22,463 |
| Michelin 2025 / 2026 / 2027 rows | 3,545 / 5,124 / 47 |
| listings / slugs | 11,233 / 12,617 (canonical 11,233, non-canonical 1,384) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,251 / 258 / 23,870 |
| price | 7,048 |
| geo / addresses / photo_refs / hours | 0 / 0 / 0 / 0 |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | 83 (last id 117) |
| audit_log | 106,035 (last id 110,368) |
| ingest_batches | 1, 3-15 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20 applied. rename_rows 941. |

## Done in this session (Oct 10, 21:37 to 22:45 Atlanta)

**Start check:** all counts, ledger 117, audit 110,368, slugs 12,617 matched the slug handoff. Plan sha256 correct in a fresh clone (`880e771`).

**Gap list re-read** (population: Michelin rows by the country of the venue's city, whole table): unchanged, 28 countries with 2025 rows and 0 2026 rows, 2,009 rows.

**Ceremony dates and label checks** (label check = new stars of the edition looked up in the legacy rows by name, plus category counts against the published totals). No 2027 date found on guide.michelin.com for any country below.

| Country | Legacy 2025 rows 3/2/1/Bib | 2026 ceremony (guide.michelin.com) | Legacy rows hold | Path (rule 2.1.1) |
|---|---|---|---|---|
| Netherlands | 1/18/92/74 = 185 | Oct 5, 2026 | 2025 edition | Promote only |
| Thailand | 2/8/32/136 = 178 | Nov 27, 2025 | 2026 edition | Retire twins; 2027 edition expected about late Nov 2026 (2026 save-the-date was Oct 30, 2025): wait, then rule 2.1.7 |
| Taiwan | 3/6/29/137 = 175 | Jul 21, 2026 | 2025 edition | Promote only |
| Austria | 2/19/76/61 = 158 (156 venues) | Mar 18, 2026 | 2026 edition (3 of 6 new names found; counts = 2026) | Retire twins |
| Hong Kong + Macao | 10/19/69/82 = 180 | Mar 19, 2026 | 2026 edition | Retire twins. Macao legacy has 3 Three Stars vs 2 published: misfile check |
| Singapore | 3/7/27/89 = 126 | Aug 4, 2026 | 2025 edition | Promote only |
| South Korea | 1/10/35/71 = 117 (1 sourced) | Mar 5, 2026 | 2026 edition | Retire twins |
| Canada | 0/2/40/64 = 106 | Québec May 6, Toronto Sep 22, Vancouver Oct 6, 2026 | Québec 2026, Vancouver 2025 | Two paths, three guides |
| Portugal | 0/9/43/26 = 78 | Mar 10, 2026 | 2026 edition | Retire twins (2027 gala in Centro, date not announced) |
| Mexico | 0/2/26/48 = 76 | May 20, 2026 (window) | 2026 edition (three-promotion test passed) | Retire twins |

URLs: Netherlands https://guide.michelin.com/en/article/michelin-guide-ceremony/azurite-and-suis-awarded-two-michelin-stars-each-in-the-2026-netherlands-michelin-guide · Thailand https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/michelin-guide-thailand-2026 · Taiwan https://guide.michelin.com/ae-du/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026 · Austria https://guide.michelin.com/at/en/article/michelin-guide-ceremony/all-starred-restaurants---michelin-guide-austria-2026 · Hong Kong & Macau https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026 · Singapore https://guide.michelin.com/ae-du/en/article/michelin-guide-ceremony/singapore-full-selection-2026 · Seoul & Busan https://guide.michelin.com/sg/en/article/michelin-guide-ceremony/michelin-guide-seoul-busan-2026-highlights · Québec https://guide.michelin.com/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-quebec-for-2026-and-the-year-s-key-trends · Toronto https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-toronto-region-for-2026 · Vancouver https://guide.michelin.com/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-vancouver-for-2026 · Portugal https://guide.michelin.com/en/article/michelin-guide-ceremony/All%20MICHELIN-Starred%20Restaurants%20in%20Portugal%202026 · Mexico https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-mexico-for-2026-and-the-year-s-key-trends

**Ben's decision (Oct 10, 22:33):** the next country is **the Netherlands** (Claude's recommendation: largest open country that does not wait; site shows year-old stars; edition new, next one about Oct 2027; promote only). Second choice on record: Austria.

**Netherlands Cowork brief (Ben "go", 22:38):** `claude/cowork-michelin-2026-netherlands.md`, 186 lines, 16,976 bytes, UTF-8, LF, no BOM, NFC, sha256 `2405ef1c7d46b254cf8f88927e46094fddbe9fc403f798bfe4a2547640f03d0f`. Saved to the project (read back). **Not in the repo yet:** Ben uploads it to `docs/cowork-michelin-2026-netherlands.md`. Model: the Belgium & Luxembourg brief, with the French pass removed (17-column header; first 15 = Texas header), the Texas 2025-vs-2026 comparison rule, and the Belgium capture lessons (localStorage keys `__nl26_`, locale star slugs read from the filter, path guard, exact code points and non-NFC list).

## Facts: Netherlands
- **2026 edition:** revealed Oct 5, 2026, MECC Maastricht. 1 / 20 / 98 stars (119), 499 restaurants. New Two Stars: Azurite (Delft), SUIS (Schin op Geul). New One Stars: Ambrozijn (Valkenburg), Bij Sidney (Loenen aan de Vecht), De Cuijt (Mierlo), Le Epifaan (Veeningen), Nassau (Groningen), Rozewied (Kortgene), Wild Atelier (Hoog Soeren). Bib list article: 77 entries, 10 new (FuLu Mandarijn, Utage Sake Bar, Boon & De Koot (Amsterdam), Bistro Toost (Amstelveen), Brasserie Bruis (Haarlem), ORA | Taverna & Bar (Breda), Ramen Kitanoya (Den Haag), Bistro Luux (Weert), Wijn Boer (Zwolle), Dokjard (Groningen)). Mindful Voices: Bij Jef (Den Hoorn), Mearkas (Eastermar). Special awards: Young Chef Rozewied; Service Château Neercanne; Sommelier Brut172; Opening of the Year Luwte (Groningen). Ceremony article: De Groene Lantaarn closed; chef Jarno Eggen now at Le Epifaan.
- **2025 edition:** Oct 6, 2025, 1 / 20 / 98. New Two Stars Create by Guido Braeken (Eijsden), GEM. (Gemert).
- **Legacy rows** (population: Michelin rows on venues in Netherlands cities, read Oct 10): 185 rows on 185 venues in 104 cities, all 2025, 0 sourced, 0 labelled 2026, 0 venues with two categories. Closed: Demain (Cadzand) `ve_9a294cfd32`. The 2025 Two Stars Spectrum (Amsterdam, `ve_e75c1b364b`, closed) and De Groene Lantaarn (Staphorst, `ve_fa28a0b2dd`, active) have no Michelin row. Other publishers on NL venues: 104 rows (best-chef-awards, europe-50-best-bars, la-liste, oad, top-500-bars, worlds-50-best-bars, worlds-50-best-restaurants).
- **Label check passes:** legacy holds Create at Two Stars and 0 of the 9 new 2026 stars. So the rows are the 2025 edition.
- **Path:** ceremony after June 1, 2026 → amended rule 2.1.1: promote only; the 185 legacy rows stay as 2025 history; no retire batch (Texas, Germany, Colorado).
- **Cities:** The Hague is `ci_52d3f80546` (English name); expect "Den Haag" on Dutch cards. Card cities with no `cities` row are likely (Schin op Geul, Mierlo, Kortgene, Veeningen, Hoog Soeren, Valkenburg, Eastermar).
- **Name items for the rename CSV later:** "Restaurant GEM." `ve_7bc851dd3c`, "Brut172 by Hans van Wolde" `ve_face3f9c07`, "François Geurds FG Restaurant" `ve_7224a4542b`, "t Nonnetje" `ve_f321850bef`, "Restaurant Flore" `ve_9b831f5bbc`, "Restaurant De Nieuwe Winkel" `ve_b24eaf6c99`, "Bij Jef Restaurant & Hotel" `ve_555263f67a`, "Restaurant Daalder*" `ve_3b8f5d3656` (no Michelin row).

## Methods that worked (new)
- **Edition label check for many countries in one query:** a `VALUES` list of (country, edition, name pattern), joined to venues by `lower(f_unaccent(name)) like pattern` and to Michelin awards; plus the category split per country compared with the published totals.
- **WebFetch reads guide.michelin.com articles** in many locales (sg/en, ae-du/en, at/en, nl/nl, us/en). The search tool with `allowed_domains: guide.michelin.com` finds the article URLs.

## Dead ends: do not retry (new)
- `guide.michelin.com/at/de/tags/Announcement` with WebFetch (robots disallowed).
- Searching for a "Thailand 2027" date: none published by Oct 10.

## Open items, in order
1. **Netherlands capture (next).** Ben uploads the brief to the repo (`docs/`), then opens a new Cowork session (Opus, Chrome extension) with the opening message below. Cowork delivers `michelin-2026-netherlands.csv` and `michelin-2026-netherlands-log.md`.
2. **Netherlands stage and promote (new chat).** Ben uploads the CSV to `fixtures/ingest/` and the log to `docs/`. Then: CSV hash against the log; counts against the brief; read-only pre-stage simulation (Germany method; ASCII `U&'…'` input); city check (new cities); pairing and decisions file; stage; dry-run promote; "go"; promote. No retire. Then the status items (Demain, Spectrum, De Groene Lantaarn), rename CSV (vote + tie rule) and slugs.
3. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
4. **Switzerland after Nov 2, 2026** (option A, promote only).
5. **Gap list after the Netherlands:** retire-path countries Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; promote-only Taiwan, Singapore; Thailand after its 2027 edition (rule 2.1.7: relabel, promote, retire nothing, if 2027 arrives first); Canada as three guides.
6. **Hold registers:** Texas, Belgium & Luxembourg, and now the Netherlands (Mindful Voices Bij Jef, Mearkas; four special awards) → special-awards batch.
7. Price from the Michelin card. Ben chooses the method.
8. France slug set (148 venues). Ben decides when.
9. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
10. Later-ceremony guides, promote only: Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
11. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues). Re-check them under the tie rule. Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
12. Rechecks, no date: Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
13. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes.
14. Repo `.env`: Ben to check that the Google Maps and MapTiler browser keys are restricted by HTTP referrer.
15. Plan v1.31: everything listed in the slug handoff, **plus this session** (the ceremony-date and label-check table above, the Netherlands choice, the brief).
16. Options B (Phase 3 map-location pass) and C (publish builder): open for later.
17. Project file cleanup, part 2: after the migration is done.

## Opening message for the Netherlands Cowork session
```
Read the brief claude/cowork-michelin-2026-netherlands.md from the project files with the Projects tool (the same file is docs/cowork-michelin-2026-netherlands.md in the GitHub repo, sha256 2405ef1c…f03d0f). Follow it exactly. Use the Chrome extension for guide.michelin.com. Do not touch the database or the repo. Deliver michelin-2026-netherlands.csv and michelin-2026-netherlands-log.md in this chat, then stop and wait for me.
```

## Suggested opening prompt for the next chat (after the capture)
```
Read these handoffs from the project files with the Projects tool: claude/handoff-netherlands-brief-2026-10-10.md first, then claude/handoff-belgium-luxembourg-retired-2026-10-10.md for the capture-check, simulation, pairing, stage and promote record, then claude/handoff-germany-staged-run1-2026-10-08.md for the pre-stage simulation method, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 117 and audit_log id 110,368 with a Read query. I attached michelin-2026-netherlands.csv and michelin-2026-netherlands-log.md from the Cowork capture. Check the CSV hash against the log, check the counts against the brief, then run the read-only pre-stage simulation and tell me in /ste style what the Netherlands stage and promote will need. Give me click steps to upload the two files to the repo. No write before my go.
```
