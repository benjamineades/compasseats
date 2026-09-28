# Handoff: CompassEats, Sep 28, 2026. Meet the Bund renamed, China slug job done. Next: Chengdu 2027.

This file replaces `handoff-michelin-china-1c-done-2026-09-28.md` for live state, rulings and open items. All working rules in the earlier handoffs still apply: plain `/ste` replies, populations on every count, one "go" per write batch, read-back after each commit, under-merge over over-merge, no competitor sources (Pearl, TBRG, Beli), no hand-retyped files. Ignore `enprimeurclub.com` and `joinpearl.co` results in web search.

Open items 1 and 2 of the 1c handoff are closed. The China cleanup and the China slug problems are complete.

## Live state
Population: whole table. Read Sep 28 after the slug commit (the last write of the session).

| Table | Count |
|---|---|
| venues | 11,185 (active 10,824) |
| awards | 22,190 |
| Michelin 2025 / 2026 / 2027 rows | 4,178 / 4,265 / 0 |
| OAD 2025 rows | 2,437 |
| Asia's 50 Best rows (all years) | 587 |
| listings / slugs | 11,185 / **12,266** (non-canonical **1,081**, canonical 11,185) |
| venues with more or less than 1 canonical slug | 0 |
| cities | 3,244 |
| city_label_source | 23,774 |
| price | 7,059 (10 with `source` = `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs | 142 |
| redirects | 9 |
| source_capture_ledger | **53** (last id **66**) |
| audit_log | **102,827** (last id **105,660**) |
| ingest_batches | ids 1 and 3–9 promoted (no id 2) |
| rename_batches | ids 2, 4, 6, **8** applied. rename_rows **533** |

## Done in this session

**1. Meet the Bund name (`ve_78e5d38e3e`, Shanghai).** Renamed "Meet the Bund (Zhongshan Dong Er Road)" → "Meet the Bund" with the rename job. Batch id 8, key `rename-majority-2026-cn-meet-the-bund`, source `la-liste`, file `fixtures/rename/majority-2026-cn-meet-the-bund.csv` (sha256 `9ef05ddb…79d54b17`, in the repo). Dry run passed (1 rename, 0 reject, 0 review, all 10 invariants), then the real run. Ledger 66 (la-liste, name, 1, `rename-apply:rename-majority-2026-cn-meet-the-bund`). Audit row 105,134. Report in `reports/rename-majority-2026-cn-meet-the-bund-rename.md`.

Source reads (Sep 28, each publisher's own page):

| Publisher | Award rows | Name printed | Read |
|---|---|---|---|
| Michelin 2026 | 26678 (One Star) | Meet the Bund (Zhongshan Dong Er Road) | Chrome card. S301, 3F, South Mall, The Bund Finance Center, 600 Zhongshan Dong Er Road; +86 21 6377 7668 |
| La Liste 2026 | 15822 (80.5) | Meet the Bund | Chrome `laliste.com/places/meet-the-bund-shanghai-cn`. Same address and phone |
| OAD 2025 Asia | 15817 (No. 78) | Meet the Bund | Chrome list page. Shanghai, chef Chen Zhiping |
| Asia's 50 Best | 15818–15821 (2023–2026) | Meet the Bund | 2026 list story, No. 6 Shanghai |
| Best Chef Awards | 15815, 15816 (1-Knife) | Meet the Bund | Chrome 2025 results. Chen Zhiping, Meet the Bund, Shanghai |

**2. Slug job for the 263 venues of rename batch 6 (`rename-michelin-2026-china`).** Gated SQL through the Write connector, one transaction. For each venue: the old canonical row → `is_canonical = false` (old URL kept, same venue), and a new canonical row from the new name. No row deleted. No ledger row (a slug has no publisher). Audit rows 105,135–105,660 (slugs UPDATE 263, INSERT 263, nothing else). Slug rule = `slugify` in `scripts/ingest/lib/slug.ts`, done in SQL as `trim(both '-' from regexp_replace(lower(f_unaccent(name)),'[^a-z0-9]+','-','g'))`. The 7 non-ASCII names were tested against the real `slug.ts`: 7 of 7 match. 14 cities, 0 collisions, 0 duplicates, 0 empty, 0 `redirects` hits.

Samples: Meet the Bund `shanghai/meet-the-bund` (old `m-on-the-bund`). Hangzhou House `hangzhou/hangzhou-house` (old `grandma-s-home`, `lanxuan-restaurant`). Jin Ling Wang Jia Hun Tun `nanjing/jin-ling-wang-jia-hun-tun-jiqing-road` (old `jinling`). Yangzhou Yan `yangzhou/yangzhou-yan-38-changchun-road` (old `yangzhou`). Lamdre `beijing/lamdre` (old `ling-long`).

## Rulings, Sep 28 (Ben), this session
- **Meet the Bund:** rename to "Meet the Bund" (option A). Sep 14 majority rule, 4 of 5 publishers. The Michelin street suffix is not needed to separate the Skyline branch: La Liste lists "Meet the Bund Skyline" (79.5) as its own place, and it is not in the database. The Sep 28 China rename used Michelin only because Michelin was then "the only publisher with a URL".
- **Slug job method:** gated SQL file (option A), not a reusable button. A "Slug — apply" button (Claude Code) stays open as a later choice for France and later renames.

## Findings for later (not decided)
- **France slugs:** 148 of the 269 venues in rename batches 2 and 4 keep an old-name canonical slug (batch 2: 138 of 252, batch 4: 10 of 17). 0 collisions. The same SQL-file method can do them as a second set.
- **Old slugs with another business name**, now non-canonical: for example `beijing/ling-long` (Lamdre), `beijing/four-seasons-beijing`, `guangzhou/sheraton-guangzhou-hotel`, `shanghai/taotaoju`, `guangzhou/taotaoju`, `xiamen/waldorf-astoria-xiamen`, `nanjing/the-ritz-carlton-nanjing`, `hangzhou/le-meridien-hangzhou-binjiang`, `beijing/jade-garden`. Standing rule keeps them. Impact: the Ling Long Beijing ingest will get `ling-long-2`, and `/beijing/ling-long` opens Lamdre. Decide at that ingest.
- **New site:** each non-canonical slug (1,081) must send a 301 to the canonical URL. Add to the URL-parity check before the production swap.
- Carried from 1c: Seventh Son (Tsim Sha Tsui) `ve_a73796bf14` filed in Beijing (possible Hong Kong misfile; Beijing also has Seventh Son `ve_abccb8710d`). Future ingest list: Meet the Bund Skyline (La Liste 79.5), La Liste Shanghai Xin Rong Ji 90.5 (goes on The House of Rong), Ling Long Beijing (A50B 2023 No. 77, OAD 2025 Asia No. 265). OAD undated "Top Restaurants" rank (Meet the Bund 31, Amanfayun 436): check at the next OAD ingest. Hong Kong Xin Rong Ji `ve_f966b7e0a1` / `ve_4dc9197f86` possible duplicate. OAD row 1249 on L'Osier (list not recorded in `awards.category`). `cities.venues_count` is stale. No-Michelin venues in the 16 guide cities (JiangNan Wok `ve_1bd53c45d6` stays per ruling J2).

## Source-reading methods that worked
- **Michelin card:** Chrome navigate, wait about 3 s, read `document.documentElement.innerHTML`, regex `"name"`, `"telephone"`, `"streetAddress"`. Card URLs in `fixtures/rename/michelin-2026-china-names.csv` (`source_url`).
- **La Liste:** Chrome `https://www.laliste.com/search?query=<text>`, wait about 4 s, links with `getAttribute('href')` matching `/places/`. The place page (`/places/<slug>`) gives h1 name, score, address, phone in `innerText`.
- **OAD lists:** Chrome `https://www.oadguides.com/lists/asia/top-restaurants/2025`, wait about 4 s, `document.body.innerText`. Rank comes BEFORE the name.
- **Asia's 50 Best:** `web_search` for the list story on theworlds50best.com.
- **Best Chef Awards:** Chrome `thebestchefawards.com/events-results/?id=2376` (2025) or `?id=1874` (2024), wait about 5 s. Text gives chef, restaurant, city. Knife level is the `img` alt text.
- Close each Chrome tab after the read (`tabs_close_mcp`).
- **Michelin native names:** `fixtures/ingest/michelin-2026-china.csv`, column `name_native_michelin`. Match by `source_url`.

## Dead ends: do not retry
- Deleting old slugs ("jinling", "yangzhou", `m-on-the-bund`, `grandma-s-home`, `ling-long` …). They are non-canonical now and stay by the standing rule.
- Expecting identity ids to follow the plan after a dry run. A rolled-back dry run uses one id per identity column (this session: batch 7, ledger 65, audit 105,133 were used by the dry run and are empty). Plan read-backs by count, not by exact next id.
- `CREATE TEMP TABLE` in a gated SQL file: a read-only transaction refuses all CREATE commands, so the Read-connector dry run would stop before the pre-checks. Keep the plan in a `jsonb` variable and use `jsonb_to_recordset` (as in the slug file).
- Carried: moving legacy script to `name_native` for lines 128, 317, 355. `$$` as the `DO` marker when SQL has a `'$$'` literal (use `DO $do$ … END $do$;`). `web_fetch` on oadguides.com lists. `fetch()` of La Liste search from page JS. Chrome JS on links with query strings or `tel:` hrefs (use `getAttribute('href')` or page HTML). Deleting only the award row on a single-award free venue. Hand SQL for a name change (`trg_venue_rename` blocks it; use the rename job). `ve_c4eac998eb` for line 299; `ve_1a25a746ec` Xiao Dadong for line 251; 421 by homophone. Stage input error: `csv_path` = source CSV, `decisions_path` = decisions CSV.
- GitHub API is rate-limited from the sandbox. `git clone --depth 1` and `raw.githubusercontent.com/benjamineades/compasseats/main/<path>` work.

## Open items, in order
1. **Chengdu 2027 (next):** stage, match test, promote, retire nothing. Chengdu `ci_354b500e3a`, 38 slug rows in `chengdu` today.
2. Plan v1.28, then Great Britain & Ireland, then the carried items from the Sep 24 handoff.
3. France slug set (148 venues), same file method. Ben to decide when. Optional later: a reusable "Slug — apply" button.
4. Later: `name_native` backfill from Michelin for China (469) and Japan (585) venues, including lines 128, 317, 355 and Hangzhou House (兰轩). 14 stage-match venues with a different Michelin spelling. `cities.venues_count` recount (Ben to decide). Hong Kong Xin Rong Ji duplicate check. Seventh Son (Tsim Sha Tsui) city check.
5. Security: RLS off on `award_categories`, `rename_batches`, `rename_rows`. Ben to decide. Do not enable RLS before access policies exist.

## Artifacts
- `fixtures/rename/majority-2026-cn-meet-the-bund.csv`: in the repo, final (ran as batch 8).
- `slugs-rename-michelin-2026-china.sql` (sha256 `d5cc9d24…ff01d123`, 126 lines): chat file, run Sep 28, not in the repo. It is the version that ran. Plan fingerprint in the file: `8c89c1b50de70c2a07b1c8ba68e908a7` (263 rows). audit_log 105,135–105,660 is the database record. It can serve as the template for the France set (change `batch_id`, fingerprint and counts).
- Earlier Sep 28 files (ledger 48–64) as in the previous handoffs.

## Key ids
Beijing `ci_0420a206ae` · Shanghai `ci_22638a3131` · Guangzhou `ci_d9d7a94326` · Shenzhen `ci_21dab17afb` · Hangzhou `ci_a34cd8e6f4` · Nanjing `ci_d39ef768e9` · Suzhou `ci_3570e53b64` · Yangzhou `ci_8910716549` · Changzhou `ci_e3cbea6f57` · Wenzhou `ci_0f5c87367e` · Taizhou `ci_bab27c24fe` · Fuzhou `ci_056a82f2ca` · Xiamen `ci_627618297c` · Quanzhou `ci_13c0d3cd7c` · Ningde `ci_b11330c9c3` · Chengdu `ci_354b500e3a`.

## Database notes
- `awards` columns: id, venue_id, source_id, year, rank, category, distinction, source_url. `source_id` holds the publisher slug. Unique rule `awards_no_dupes`, NULLS NOT DISTINCT.
- `venues.status` is an enum (`active`, …).
- `source_capture_ledger`: id (identity), publisher, field_type, items, captured_at, job. Cleanup job text `cleanup:<batch key>`. Rename job writes `rename-apply:<batch key>`, field type `name`.
- `slugs`: primary key (`property_id`, `city_slug`, `slug`), `is_canonical`. **No database rule forces 1 canonical row per venue**: every slug write must check it (0 venues off today). Site route is `/venue/<city>/<slug>`. No other table stores a venue slug (only regions, cities, award_sources have `slug` columns).
- Tables with a `venue_id` foreign key: slugs, blurbs, listings, awards, geo, addresses, price, hours, photo_refs, city_label_source. Venue delete order: city labels (move or delete, with hand audit rows), then awards, price, city_label_source, slugs, listings, venues.
- Audit triggers on awards, venues, price, slugs, listings (actions `INSERT`, `UPDATE`, `DELETE`). Not on `city_label_source` or `source_capture_ledger` (hand audit rows). `audit_log.id` is an identity column.
- `price.source` is an enum (`price_source_t`): do not `coalesce(source,'')`.
- `rename_rows.expected_name` holds the pre-rename name. The rename job never changes a slug.
- A `DELETE` / `UPDATE` through the Read connector fails with "read-only transaction". Use this as the dry run.

## Working preferences
- `/ste` style for all data replies. Plain step-by-step directions; Ben is not a developer. Ben runs GitHub Actions jobs himself: give numbered click steps with exact field values.
- Judgment decisions one set at a time, with a recommendation and tappable options. A choice on a tappable option is not a "go": after the choice, do a fresh read, confirm the file matches the choice, and wait for "go". For a no-write choice, do a fresh read and close the set.
- Ben answers at gates with one word (`go`, `next`, `done`, `handoff`). Read the database at each gate.
- Show each set as: population and group, the rows by id, publisher entry per row, source reads, target and dependents, rows that stay, checks already passed read-only, exact write plan, expected read-back table, carried findings.
- Build the file first (SQL or CSV), dry-run it (Read connector for SQL, `dry_run` ticked for jobs), present the file as the record, then ask for the choice. If a write fails, read the database to prove nothing changed, fix the file, and ask for a new "go".
- Gated SQL: pre-check read, then one `BEGIN; DO $do$ … RAISE EXCEPTION on any count mismatch … END $do$; COMMIT;` through the Write connector, then read-back (last audit rows, new ledger rows). For large sets, compute the plan in the database and pin it with an md5 fingerprint instead of listing rows by hand.
- Source reads only from the publisher's own list. Third-party directories can support but never decide.
- Suggest a handoff break before a new large block of work.

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-china-slugs-done-2026-09-28.md). Confirm live counts, ledger id 66 and audit_log id 105,660 with a Read query. Then prepare open item 1, Chengdu 2027: check docs/ingest-job.md and the earlier China ingest fixtures for the stage file format, read the Chengdu list from the Michelin Guide's own site in Chrome, build the stage and decisions files, and show me the plan and checks in /ste style before any stage run.
```
