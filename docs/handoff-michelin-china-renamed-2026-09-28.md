# Handoff: CompassEats, Sep 28, 2026. China 2026 renamed. Next: retire batches.

This file replaces `handoff-michelin-china-promoted-2026-09-27.md` for live state, rulings and open items. All working rules in the earlier handoffs still apply: plain `/ste` replies, populations on every count, one "go" per write batch, read-back after each commit, under-merge over over-merge, no competitor sources (Pearl, TBRG, Beli), no hand-retyped files. Ignore `enprimeurclub.com` and `joinpearl.co` results in web search.

## Live state
Population: whole table. Read Sep 28 after the rename commit.

| Table | Count |
|---|---|
| venues | 11,221 (active **10,860**) |
| awards | 22,493 |
| Michelin 2025 / 2026 / 2027 rows | 4,479 / 4,265 / 0 |
| listings / slugs | 11,221 / 12,034 |
| cities | 3,244 |
| city_label_source | 23,838 |
| price | **7,094** (10 with `source` = `guide_ingest`) |
| venues with `name_native` | **18** |
| blurbs | 142 |
| source_capture_ledger | **35** |
| audit_log | 101,508 before the rename job (+263 name rows from the job) |
| ingest_batches | ids 1 and 3–9 promoted (no id 2). Id 9 `michelin-2026-china` promoted Sep 27 |
| rename_batches | ids 2, 4 (France) and **6 `rename-michelin-2026-china`** applied Sep 28 01:59:55 UTC. rename_rows 532 |

## Done in this session (open item 1 closed)
**Part A, gated SQL, one transaction (Ben "go", Sep 27).** All row counts and table counts passed.
- `name_native` = legacy Chinese name on 16 venues (lines 3, 65, 72, 86, 127, 160, 165, 193, 197, 208, 219, 255, 259, 268, 392, 451). Line 255 (福1015) had no instruction in the decisions file; added because it is the same restaurant as Fu 1015.
- Line 244 `ve_8ff48e1c8f`: `name_native` = 荣府宴.
- Line 276 `ve_78e5d38e3e` (Meet the Bund): `closed` → `active`.
- Price, option C (Ben): 6 UPDATE to the card tier (lines 35, 50, 65, 82, 230, 448) and 4 INSERT (lines 134, 145, 276, 299). New shape: `source` = `guide_ingest`, `method` = `published_symbol`, `publisher` = `michelin`, `currency` = `CNY`, `symbol_raw` = ¥ as printed, `source_url` = card URL.

**Part B, rename job.** `fixtures/rename/michelin-2026-china-names.csv` (263 rows, sha256 `d5b3e185…42ddbf`). Dry run, then real run. 263 rename, 0 no_change, 0 reject, 0 review, 0 collisions, all invariants passed. Read-back: 263/263 live names = new names, 263/263 active, ledger 34 → 35.

## Rulings and choices, Sep 27–28
- **Price:** the Michelin 2026 card price wins over a legacy price with no URL (Ben chose option C). Reason: the card is current and has a URL.
- **`name_native` rule used:** the legacy script moves verbatim (the standing Impérial Choisy rule). Michelin's native name was not used, except line 244 (ruled earlier).
- **Line 128** "Lucky Zhang's（ 8大道张家興）" → Zhang Lin A Shan Jiang Mu Ya: script NOT moved to `name_native`. Ben did not answer this question; the recommendation was applied (张家興 is not 张林阿山). Confirm with Ben if it comes up.
- Rule 6b, name wins, token link, rule 12, G3 exceptions, Foodle order-only, Z1 (all Sep 27): unchanged, see the earlier handoff.

## Findings
- The rename job changes only `venues.name`. `name_native`, `status`, price and slugs need gated SQL or another job.
- The rename report's "Where else the name is stored": `name_native` 16 (correct), `cities.display` 4 and `city_label_source.label` 72 are the city names Taizhou, Wenzhou, Quanzhou and Yangzhou (four venues had a city name as their name). No action.
- **Slugs do not follow the rename.** 247 renamed venues keep a slug from the old name (`/shanghai/m-on-the-bund`, `/hangzhou/grandma-s-home`, `/yangzhou/yangzhou`). The 16 venues with a legacy Chinese name have random slugs (`/guangzhou/guangzhou-fi5owy`, `/shanghai/shanghai-gjadhw`).
- Slugs "jinling" (`ve_2766d50b55`) and "yangzhou" (`ve_38a720dd68`) are **canonical and the only slug** on each venue. They cannot be deleted now: the venue would have no URL.
- The ingest writes no price rows and no `name_native`. Before this session only 1 venue in the table had `name_native`.

## Dead ends: do not retry
- Deleting slugs "jinling" / "yangzhou" before a new canonical slug exists.
- Hand SQL for a name change: the trigger `trg_venue_rename` blocks it. Use the rename job.
- Carried: `ve_c4eac998eb` for line 299; `ve_1a25a746ec` Xiao Dadong for line 251; Lanxuan for line 260; 421 by homophone. Stage input error: `csv_path` = source CSV, `decisions_path` = decisions CSV.
- GitHub API is rate-limited from the sandbox. `raw.githubusercontent.com/benjamineades/compasseats/main/<path>` works.

## Open items, in order
1. **Retire batches (next)** per the Sep 15 ruling: Beijing; Shanghai · Jiangsu · Zhejiang; Fujian (scoped by city id). Guangzhou: keep all, then move the 2025 rows off the free Guangzhou venues.
   - Orphan rows on used venues: 8069, 8339, 12324, 2002, 2003, 10386, 8021.
   - Rows on free legacy venues named: 8012 (Xiao Dadong), 6677 (Jiangnan Wok), 8065 (Sir Elly's), 12144 (Jia Jia Tang Bao), 8050 (Mr & Mrs Bund).
   - Rows that a card now uses (not free, not orphan): 3134, 3136, 10223, 10382, 10399, 10400, 11283, 12513, 12984, 12998, 13000.
2. **Cleanup after retire** (unchanged from Sep 27): move 8056 to the new Obscura venue; check 8057, OAD 8066 and 8067 on Sir Elly's `ve_a8f2e06702`; move 5228 from Jade Garden `ve_23e6576d23` to Jade River `ve_cbb08ffdee`; examine OAD 3135 on `ve_8ff48e1c8f`; Best Chef 2024/2025, OAD 2025 No. 78 and La Liste 2026 on `ve_78e5d38e3e`; OAD 10389 on `ve_90478c2170`; La Liste 20905 on `ve_37a333f8af`; La Liste 10380 on `ve_1882ac7b25`; Taizhou La Liste `ve_4173a16a48`. Free-list changes and merge candidates as in the Sep 27 handoff. Add: `name_native` for lines 128, 317, 355.
3. **Slug job for the 263 renamed venues** (Claude's recommendation, not yet decided by Ben): mint new canonical slugs from the new names, keep old slugs as non-canonical rows (standing rule). Settles "jinling" and "yangzhou". Do before the production swap (mid-October).
4. Chengdu 2027: stage, match test, promote, retire nothing.
5. Plan v1.28, then Great Britain & Ireland, then the carried items from the Sep 24 handoff.
6. Later: 14 stage-match venues with a different Michelin spelling (for example "TRB Hutong" / "Trb Hutong", "Fuchunju" / "Fu Chun Ju", "8 1/2 Otto e Mezzo Bombana" / "8 ½"). Check other publishers before any rename. `name_native` from Michelin for China (469) and Japan (585) venues.
7. Security: RLS off on `award_categories`, `rename_batches`, `rename_rows`. Ben to decide. Do not enable RLS before access policies exist.

## Artifacts
- `fixtures/rename/michelin-2026-china-names.csv`: in the repo, final, applied (batch 6).
- `reports/rename-michelin-2026-china-rename.md`: committed by the job.
- `rename-china-prep-gated.sql`: Part A SQL, run Sep 27 (chat file, not in the repo).
- `fixtures/ingest/michelin-2026-china-decisions.csv` and `michelin-2026-china.csv`: in the repo, final.

## Key ids
Beijing `ci_0420a206ae` · Shanghai `ci_22638a3131` · Guangzhou `ci_d9d7a94326` · Shenzhen `ci_21dab17afb` · Hangzhou `ci_a34cd8e6f4` · Nanjing `ci_d39ef768e9` · Suzhou `ci_3570e53b64` · Yangzhou `ci_8910716549` · Changzhou `ci_e3cbea6f57` · Wenzhou `ci_0f5c87367e` · Taizhou `ci_bab27c24fe` · Fuzhou `ci_056a82f2ca` · Xiamen `ci_627618297c` · Quanzhou `ci_13c0d3cd7c` · Ningde `ci_b11330c9c3` · Chengdu `ci_354b500e3a`.

## Working preferences
- `/ste` style for all data replies. Plain step-by-step directions; Ben is not a developer.
- Judgment decisions one group at a time, with a recommendation and tappable options.
- Ben answers at gates with one word (`go`, `staged`, `promoted`, `renamed`). Read the database at each gate. If Ben's pasted report says "DRY RUN", the real run has not happened: read the database and say so.
- Give exact GitHub Actions box values in a table.
- Gated SQL: pre-check read, then one `BEGIN … DO $$ … RAISE EXCEPTION on any count mismatch … $$; COMMIT;` through the Write connector, then read-back.

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-china-renamed-2026-09-28.md). Confirm live counts and rename batch 6 with a Read query. Then prepare open item 1, the Beijing retire batch: check the retire job format in the repo docs, list the Beijing Michelin 2025 legacy rows it will retire with their venues and any non-Michelin rows on those venues, and show me the checks and the exact write plan in /ste style before I say "go".
```
