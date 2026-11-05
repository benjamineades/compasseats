# Handoff: Top 500 Bars 2026, write done. 500 rows, 45 new venues. Nov 5, 2026 (17:10 Atlanta). Next: rest of the launch list.

This file replaces `handoff-50-best-spirited-2026-done-2026-11-05.md` for the live state and open item 1. That file still holds the 50 Best method, its decisions and its weak points. Radar and research run: `handoff-launch-list-radar-done-2026-11-05.md`. Launch list: `launch-list-2026-11-05.md`. Live-site finding and goals: `handoff-oad-2026-small-fixes-done-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 5)
- 17:05 "1-7:A". 17:07 "Go".

## Live state (read Nov 5, 22:09:59 UTC, whole tables)
Venues **11,668** (active **11,365**, closed 303). Awards **28,296** (last id **35,467**). OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs **13,612** (canonical 11,668). Price 7,759. Listings **11,668**. city_label_source **24,743**. city_aliases 222. Redirects 35. Cities **3,321**, `cities.venues_count` sum **11,365**. Ledger **252** rows, last id **306**. audit_log **126,068** rows, last id **131,897**. Closed published 0, active not published 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/top-500-bars-2026-2026-11-05/load-top-500-bars-2026-2026-11-05.sql` (sha256 `b351d42d5115000175a957d45a2b8791cc128478c0a66af2d026d684643b70ea`). Write connector, first try, 1 transaction, 22:09:32 UTC, all gates passed.

| Item | Change |
|---|---|
| Awards | 500 rows, `top-500-bars` 2026, ids 34,968-35,467, ranks 1-500, category `No. N`, all with `source_url` (publisher block page) |
| New venues | 45, all bar, active, published. No price, address, geo, blurb or chef |
| New cities | Antigua (Guatemala), Katowice (Poland). Region NULL, no lat/lng |
| Cities updated | 35 count updates |
| Ledger | 305 award, 306 city_label |
| audit_log | 131,136-131,897 (762). cities INSERT 2, cities UPDATE 35, venues 45, listings 45, slugs 45, city_label_source 90 (by hand), awards 500 |

Population of the 500 rows: 341 live venue with the same name, 114 live venue with a name that differs in more than case or spacing, 45 new venue. Of the 455 live venues, 400 hold a 2025 row, 327 hold a 2024 row, 41 hold no earlier row on this list. 2 rows are on closed venues.

**New venues (rank):** Bar Leone, Shanghai (58). Cato, London (90). Shakerato (124), Advocatuur (144), Dutch Courage (339), Amsterdam. Superfine (138), Abstract Bistrot (145), Mesures (375), Paris. Stravinsky Parfumerie, Barcelona (180). Britannia Bar, Trondheim (245). The Carlton Bar (249), BoB the other side (462), Milan. Press Club, Washington (258). Avoca, Hong Kong (299). Fede Cocktail Lab, Florence (321). Ulew Cocktail Bar, Antigua (324). Clap (374), Netsu (406), Dubai. Two Moons, Macau (377). Shady Pig, under `bali`, label Canggu (378). The Waratah, Sydney (382). Yoi, Kyoto (387). Subastor, Sao Paulo (388). Domashniy Bar, Almaty (391). Le Churchill, Marrakech (395). Morgana Lounge Bar, Taormina (405). 5L Speakeasy Bar, Sofia (412). Ory, Munich (416). Antique American Bar (417), Sky Bar & Restaurant (423), Bratislava. Speak in Code, Manchester (419). Everson Royce Bar, Los Angeles (425). Ruggine, Bologna (431). Botanical by Alfonse, Namur (440). Penicillin, Shanghai (445). Sartoria, Palermo (455). Maria Mezcal, Lima (463). El Koktel, Warsaw (465). Art, Katowice (473). Noble Roots, Belgrade (483). Dragonfly, Edinburgh (484). Bar Glue, Liverpool (486). Urania, Zagreb (490). Vibes, Nice (495). Nucleo, Rome (498).

**No change to:** names, status of a live venue, price, redirects, city aliases, `award_categories`, earlier years. The live site does not read Supabase, so no live page changed. Not checked: a live page.

Evidence: `top-500-bars-2026-evidence-2026-11-05.csv` (500 rows, sha256 `4a87b5541131803ce7438ff0498fb5482c309cd008b4cfdc752330679f8e9352`). List read: `top500-2026-raw.tsv` (hash matched the browser, `ad513cc9...c422b`). Plan: `plan_live.txt`, `plan_new.txt`. Live read: `live-read.txt`. Scripts: `build_sql.py`, `build_evidence.py`.

## List check
Population: 12 publisher pages, built-in browser. 500 rows, 500 different ranks, none missing. Time Out (Nov 4) gives 13 London bars: 13 of 13 ranks match. Of 400 venues with a 2025 row, 4 have the same rank, so the pages are not a copy of 2025. The publisher pages show no date.
Publisher errors: Line gives the place "Line" (Athens used). At least 6 website links point to another bar (Lady Bee, Tres Monos, The Clumsies, Backdoor 43, Red Frog, Dry Milano). Links were not match evidence.

## Decisions (Ben, all A)
1. 45 new venues, active and published, 2 new cities.
2. Load now. Status read of the 45 is an open item.
3. `source_url` = publisher block page. Page addresses: `1-25-2026`, `26-50-2026`, `51-75-2026`, `76-100-2026`, `150-101-2026`, `200-151-2026`, `copie-de-300-251-2026` (ranks 201-250), `300-251-2026`, `301-350-2026`, `351-400-2026`, `401-450-2026`, `451-500-2026`.
4. Closed venues keep status closed and take the row: Tayēr + Elementary (72), Dram Bar (294).
5. Hand matches accepted: Aldea (466) to Carrer de l'Aldea `ve_062ae78893`. Gorilla (478) to Gorilas `ve_1ffcac902f`. Aman Bar (315) to Aman Venice `ve_086948f186`, category restaurant. Umi (494) to `ve_a267f95c3b`, category restaurant. Alto Rooftop (332) to `ve_d6686e448b`. Eau de Vie (325) to `ve_cc4bfd02d9` (Melbourne, named Sydney). Seed Library London (81) to `ve_88c6365b3e` (London, named NYC). PDT (372) to Please Don't Tell `ve_4249f54d54`. Press Club (258) is new, not National Press Club.
6. New venue names: Advocatuur (publisher Advocaatur), Clap (publisher The Clap), Penicillin (publisher PENICILLIN). Shady Pig under `bali`.
7. No rename now. 114 names go to the rename batch: CSV, `group` = name differs.

## Weak points
- Status of the 45 new venues: 3 of 45 read (Everson Royce Bar by article; Clap and Press Club by search results only).
- Country label on the new venues of ranks 101-500 comes from the `cities` table. The publisher gives a city only. The ledger row 306 says so.
- 2 Cervia venues can be one bar: Alto Rooftop `ve_d6686e448b` (Pinnacle 2026, Top 500 2026) and ALTO - Ristorante e Cocktail Bar `ve_e0a0caabc6` (Top 500 2024, 2025). Not merged.
- Rank 466: the name Carrer de l'Aldea looks like an address. The 50 Best page says Aldea.

## Open items, in order
1. **Rest of the launch list (next).** Editions due: Gault & Millau France and Monaco 2027 (Nov 9), Latin America's 50 Best (Dec 1), La Liste 2027 (December), Kuala Lumpur & Penang 2027, Northeast Cities (after Dec 14). Michelin: Thailand, Austria, Singapore, South Korea, Canada, Portugal, Mexico, US gap. Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo.
2. **Status read of the 45 new venues.** See decision 2.
3. **Rechecks.** Dram Bar `ve_9cdafd245d`: left Soho Feb 2026, Dalston move announced for late spring, opening not read. Everson Royce Bar: closes Dec 20, 2026 (Time Out, Oct 23). Read after Dec 20, then close. Tayēr + Elementary: fire, reopening.
4. **Cervia pair.** See weak points.
5. **Rename batch.** The 63 names of the 50 Best handoff plus these 114. Fix first: Via Ceresio, 7. Seed Library NYC (London). Eau De Vie Sydney (Melbourne). Carrer de l'Aldea. Hope. The Han-Jia Pairing Dinner. Carmen Medellín.
6. **Phase 2 publish job.** Goal Nov 29. Not started.
7. **Phase 3 location pass.** Not started.
8. **Plan v1.31.** Add this write and the 50 Best write.
9. **Research result (after Nov 7).** See the radar handoff.

## Methods (new)
- **top500bars.com read:** Wix site. WebFetch and curl give no rows. In the built-in browser, `fetch` the page path and parse with `DOMParser`. Ranks 1-100: rich text blocks start `No. N`, then name, then `(City/Country)`. Ranks 101-500: anchors with text `N. Name: City`. Split at the last colon (Reka:Bar).
- **Match in SQL when the venue table is too big for the chat:** send the list as text, compute name keys in `MATERIALIZED` CTEs, join on equal keys only. A join with `position()` and `OR` gave Bad Gateway. Send about 200 rows per call.
- **Second pass:** search the unmatched names with a word boundary in the city and among all bars. Then list the 2025 rows that left the list and compare them with the new venues. This found Gorilla on Gorilas.
- **No file transfer from the connector:** save the output by heredoc, then compare a hash that the query or the browser computed.
- **Dry run:** cut the `DO` block at the first write and add 1 insert. The Read connector stops with "read-only transaction".

## Dead ends: do not retry
- curl from the workspace to top500bars.com (403 at the proxy).
- `award_sources.id` (the key is `slug`).

**Repo:** branch `oad-2026-read-block` holds this folder and handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt
```
Read claude/handoff-top-500-bars-2026-done-2026-11-05.md from the project files, then
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 306, audit_log 131,897, venues 11,668 (active 11,365, closed 303), awards 28,296,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,612, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,365. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Then tell me which launch list item is next and start it: read the list from the publisher and check first that it is complete.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
