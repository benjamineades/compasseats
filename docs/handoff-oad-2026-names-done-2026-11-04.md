# Handoff: Rename batch 51 done (159 venues, new slugs). Open item 2 closed. Nov 4, 2026 (18:30 Atlanta). Next: item 3, closed venues.

This file replaces `handoff-oad-2026-holds-item1-done-2026-11-04.md` for the live state and its open item 2. That file still holds open items 1, 3, 4, 5, 6, its recheck list and its methods. `handoff-oad-2026-holds-status-done-2026-11-04.md` and `handoff-oad-2026-holds-summer-palace-done-2026-11-04.md` hold methods, dead ends and rechecks. `handoff-oad-2026-first-write-done-2026-11-03.md` holds OAD data limits. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 4)
- 10:29 "A for all 8". 18:25 "Go".
- 1A = OAD-only venues take the own site or Michelin card spelling (35 renames). 2A = Michelin card names with no site read accepted (76). 3A = text cuts renamed now (19). 4A = generic word removed (Mantúa, Les Cols, La Vasca, Arnolfo, Campo del Drago, Casas Colgadas). 5A = La Gaia to Brula. 6A = the other 17 holds: no write. 7A = 53 listing-only spellings: keep. 8A = slugs in the same transaction.

## Live state (read Nov 4, 23:27:40 UTC, whole tables)
Venues **11,594** (active **11,288**, closed **306**). Awards **27,481** (last id 34,652). OAD 2026 rows **2,859**. OAD 2025 rows 2,437. Slugs **13,534** (canonical 11,594). Price 7,759. Listings 11,594. city_label_source 24,595. city_aliases 222. Redirects 33. Cities 3,318, `cities.venues_count` sum **11,288**. Ledger **240** rows, last id **294**. audit_log **124,788** rows, last id **130,617**. rename batch last id **51**. Closed published 0, active not published 0. Venues with more or less than 1 canonical slug 0. Cities that differ from `city_venue_counts` 0.

## Done
`docs/open-items-oad-2026-names-2026-11-04/rename-oad-2026-names-2026-11-04.sql` (sha256 `b59f3e2c93edb7558e9aa725366fc626f939a050a4048f321e1f6c4e6e26d84f`). Write connector, first try, applied Nov 4 23:27:22 UTC. 1 transaction, all gates passed. Plan md5 `ca34a40be342ff28ccaed9b0405d02a0`.

Evidence: `names-evidence-2026-11-04.csv` in the same folder (266 rows). Card read: `cards-read-2026-11-04.json` (157 rows, browser hash checked). Own-site read of 30: `own-site-read-30-2026-11-04.jsonl`. Scripts: `verdicts_names.py` (hand verdicts), `build_names.py`, `build_sql_names.py`.

| Item | Result | Ids |
|---|---|---|
| Renames | 159: venue 64, michelin 76, listing 19 (`rename_rows.source_id`) | Batch 51 |
| By group | Group 1: 33. Group 2: 1. Group 3: 1. Group 4: 124 | |
| Slugs | 139 changed: 90 new rows, 49 existing own slugs set canonical again. 20 keep their slug. Old slugs non-canonical | |
| Ledger | 294 (michelin, name, 76). No row for venue or listing | |
| audit_log | 130,181-130,617 (437): venues UPDATE 159, slugs UPDATE 188, slugs INSERT 90 | |

Read-back: 159 of 159 live names equal `rename_rows.new_name`. Group 4 test now finds 17 venues on the whole table (was 141). Not listed one by one: they are the holds plus real long names, such as Pasta|Bar and Imperial Treasure.

**Weak points:**
- 19 text cuts: only listings, press or tourism pages support them, most by a search title not opened. Rows use source_id `listing`, a new value. Column has no foreign key.
- 76 Michelin card names: own site not read. 34 of the French cards show only a TheFork ad link, so no own site was on the card.
- 79 of the first 158 renames hold a non-Michelin award. The database stores no publisher spelling, so no majority vote could be counted.
- Site reads are short fetch reports, not exact text.
- Straight apostrophes used. Policy still open.
- Blurbs on Akelarre and Le Petit Nice have status `needs_rewrite` and were not changed.

**Not checked:** the live site. This session did not read a page or a deploy.

**Repo:** branch `oad-2026-read-block`. Not merged to `main` at the time of writing.

## Open items
1. **Hold rows, 5:** as in the item 1 handoff.
2. **Closed venues (item 3, next).** Read the 26 weakest only (Ben 4A), only for a status change. Filter `docs/open-items-oad-2026-holds-names-closed-2026-11-04/oad-2026-closed-venues-evidence-2026-11-04.csv` on `sweep_group` 7 (13), 9 (8), 11 (5). Not started. Agreste de Fabio & Roser was renamed in this batch and is in group 9.
3. **Names held, 17 (Ben 6A, no write):** Amâlia `ve_3314ede188` (slug `paris/amalia` is an old slug of Villa Amalia `ve_1322b9e099`, One Star: possible twin), BARE `ve_969a2eb301`, Beni Kenji Yamanaka `ve_1af6a9c4c4`, Comer mar y montana `ve_db1275e24a`, DAV Milano `ve_f2304d7d4a`, Jumbo Seafood `ve_eb0889d400`, Qi 27 `ve_7e33a36e6b` (site Sushi Nishichi), Bangkok Bold Kitchen `ve_a65b4cfbbe`, Der Kirchenwirt `ve_408dd2d0e2`, La Bastide Bourrelly `ve_23317e8d00`, La Magdeleine `ve_fa54992eff`, La Grand'Vigne `ve_f042d8773f`, Kedai Jual Beli Duit Lama `ve_15423d04be` (reads as a coin shop, row may be wrong), Le Mas Les Eydins `ve_5fb26e7a00`, Qazaq Auyl `ve_617482d4ee`, Sushi by Bou Nomad `ve_57d8d68cf5`, Палкинъ `ve_a2855ef809`. Proposals: evidence CSV, `cls` = H.
4. **Names kept, 53 (Ben 7A):** another spelling only on a listing. CSV `cls` = K2. Not to read again without a new route.
5. **Items 4, 5, 6 of the item 1 handoff:** new cities, carried items, Michelin Kuala Lumpur & Penang 2027.

## Recheck list (added; no scheduled task holds these dates)
Imperial Treasure Crowne Plaza `ve_155851d837` (own site: closes Jun 29, 2026; still active). Franky's Grill `ve_85247a0627` (own title "Coming soon"). Saap `ve_ab8204505e` (sources say Randolph, Vermont; check the live city). Brula `ve_5bc114bba1` (card and site agree; award rows read La Gaia era).

## Methods (new)
- **Michelin search page works from a tab.** `fetch('/us/en/restaurants?q=' + name)` on guide.michelin.com, `a[href*="/restaurant/"]`. Result lists end with the same fixed cards (Hen Mother Cookhouse, Chez FonFon): ignore these. Check each match by hand. A short plain query works best ("Sardaarji", "Ngoc Chi").
- **Card loop:** `h1` and `a[data-event*=website]`. French cards often link to theforkmanager: that is an ad, not the site.
- **Force a result to a file:** add 60,000 padding characters. The saved file holds a JSON array with a JSON string in `text`. Use `raw_decode`.
- **A verdict file must not hold URLs cut for display.** Take URLs from the source file by id.
- **A JS call can wait on a flag that never sets and time out at 45 s.** Read the array instead.

## Dead ends: do not retry
- A browser script that looks for Algolia keys on guide.michelin.com: permission refused.
- Plain shell `curl` to outside sites: no connection.
- `www.gardena.it`, `ochandorestaurante.com`, `palodurestaurante.es`, `restaurant-jin.de`, `toriyaki-ohana.jp` in the fetch tool: robots. `luciafreitas.es`: client error.
- Michelin cards with a 404 and no search result: BARE, Beni, Mōdan, Yunagibashi Takoyasu, Mural, Arakicho Rokkan, Cancook.

## Suggested opening prompt
```
Read claude/handoff-oad-2026-names-done-2026-11-04.md from the project files, then
claude/handoff-oad-2026-holds-item1-done-2026-11-04.md for open items and rechecks,
claude/handoff-oad-2026-holds-status-done-2026-11-04.md and claude/handoff-oad-2026-holds-summer-palace-done-2026-11-04.md for methods and dead ends, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 294, audit_log 130,617, venues 11,594 (active 11,288, closed 306), awards 27,481,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,534, price 7,759, city_aliases 222, redirects 33, closed published 0 and
cities.venues_count sum 11,288. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block. It is not merged to main.
Then work on item 3: closed venues. Read the 26 weakest venues only (Ben 4A), only for a status change.
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
