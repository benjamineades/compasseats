# Handoff: CompassEats, Sep 28, 2026. China 2026 retire done. Next: cleanup.

This file replaces `handoff-michelin-china-renamed-2026-09-28.md` for live state, rulings and open items. All working rules in the earlier handoffs still apply: plain `/ste` replies, populations on every count, one "go" per write batch, read-back after each commit, under-merge over over-merge, no competitor sources (Pearl, TBRG, Beli), no hand-retyped files. Ignore `enprimeurclub.com` and `joinpearl.co` results in web search.

## Live state
Population: whole table. Read Sep 28 after the Guangzhou commit (02:25 UTC).

| Table | Count |
|---|---|
| venues | **11,220** (active **10,859**) |
| awards | **22,226** |
| Michelin 2025 / 2026 / 2027 rows | **4,212** / 4,265 / 0 |
| listings / slugs | **11,220** / 12,034 (non-canonical **814**) |
| cities | 3,244 |
| city_label_source | 23,838 |
| price | **7,093** (10 with `source` = `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs | 142 |
| source_capture_ledger | **39** (last id 51) |
| audit_log | **102,045** |
| ingest_batches | ids 1 and 3–9 promoted (no id 2) |
| rename_batches | ids 2, 4 (France), 6 (China) applied. rename_rows 532 |

China legacy Michelin 2025 rows (no `source_url`): **83**. Guangzhou 53 (2025 history, stays). Free venues 30: Beijing 7, Shanghai · Jiangsu · Zhejiang 18, Fujian 5.

## Done in this session (open item 1 closed)
All four batches: gated SQL through Supabase Write, one transaction each, all checks passed, read-back matched.

| Batch key | Scope | Change | Ledger id |
|---|---|---|---|
| `retire-michelin-legacy-cn-beijing` | `ci_0420a206ae` | 46 rows deleted (43 same category + 1558, 4098, 4111) | 48 |
| `retire-michelin-legacy-cn-sjz` | 8 city ids (Shanghai, Nanjing, Suzhou, Yangzhou, Changzhou, Hangzhou, Wenzhou, Taizhou) | 170 rows deleted (161 same category + B 2002, 2003, 8069, 8339 + named C 8012, 8050, 8065, 12144, 6677) | 49 |
| `retire-michelin-legacy-cn-fujian` | Fuzhou, Xiamen, Quanzhou, Ningde | 50 rows deleted (49 same category + 5099) | 50 |
| `cleanup-michelin-cn-guangzhou` | Guangzhou | 5228 moved to Jade River; 5220 deleted; Jade Garden `ve_23e6576d23` merged into Jade River `ve_cbb08ffdee` | 51 |

Guide dates used (guide.michelin.com): Beijing Oct 28, 2025; Fujian Nov 21, 2025; Shanghai · Jiangsu · Zhejiang Apr 9, 2026 (all before the capture window, so rule 2.1.1 retire applies); Guangzhou Aug 18, 2026 (after the window, legacy rows stay as 2025 history).

Jade Garden merge detail: 5228 to S; city labels 3113, 3114 to S (2 hand audit rows); T price ($$$ legacy) deleted, S keeps card price ¥¥¥; slug `guangzhou/jade-garden` moved to S as non-canonical, `guangzhou/yutang-chunnuan-restaurant` stays canonical; T listing and venue deleted.

## Rulings and choices, Sep 28 (Ben)
- **Free-venue rows (Beijing option A, applied to all China batches):** a legacy row that is the only award on a free legacy venue stays out of a retire batch. Reason: deleting only the row leaves a live venue with no award. These rows and their venues go to cleanup, with the full venue pre-check.
- **Named free-venue rows (handoff item 1 list):** deleted in the retire batch, because each venue keeps other awards.
- **Second legacy row in another category on one venue, inside the venue's own id block** (Fuchunju 4098, Wenru No.9 5099, Jiexianglou 2002/2003, Oriental Sense & Palate 8069, Ya Ba Sheng Jian 8339, BingSheng Mansion 5220): delete. One venue cannot hold two categories in one edition.
- **Guangzhou moves:** a 2025 row moves only when the decisions file proves the target card. Only 5228 qualified. 5231, 10360, 10364, 10367 have no provable card and stay.
- Line 128 `name_native`: still not confirmed by Ben (carried from the previous handoff).

## Findings
- The repo has no retire job. A retire is gated SQL (Sep 15 ruling section 4, plan rule 2.1.1 as amended Sep 24).
- Audit triggers (`audit_row()`) exist on awards, venues, price, slugs, listings. **Not** on `city_label_source` or `source_capture_ledger`: write hand audit rows for `city_label_source` changes.
- Every China city now has 0 unsourced Michelin 2026 rows, and sourced rows equal cards: Beijing 58, Shanghai · Jiangsu · Zhejiang 238, Fujian 73.
- No venue in the Beijing, Shanghai · Jiangsu · Zhejiang or Fujian city ids has zero awards.

## Dead ends: do not retry
- Deleting slugs "jinling" / "yangzhou" before a new canonical slug exists.
- Hand SQL for a name change: `trg_venue_rename` blocks it. Use the rename job.
- Deleting only the award row on a single-award free venue (leaves a live venue with no award).
- Carried: `ve_c4eac998eb` for line 299; `ve_1a25a746ec` Xiao Dadong for line 251; Lanxuan for line 260; 421 by homophone. Stage input error: `csv_path` = source CSV, `decisions_path` = decisions CSV.
- GitHub API is rate-limited from the sandbox. `git clone --depth 1` and `raw.githubusercontent.com/benjamineades/compasseats/main/<path>` work.

## Open items, in order
1. **Cleanup (next).** One judgment group at a time.
   - **a. Free-venue rows and venues (34).** Beijing: 4106, 4122, 9458, 9463, 9465, 9466, 9477. Shanghai · Jiangsu · Zhejiang: 8054, 8084, 10381, 10385, 10387, 10388, 10390, 10391, 10392, 10393, 11290, 12153, 12325, 12326, 12327, 12330, 12928, 12929. Fujian: 10232, 12976, 12983, 12986, 12989. Guangzhou (2025 history): 5231, 10360, 10364, 10367. The Beijing 7, Fujian 5 and the Shanghai · Jiangsu · Zhejiang rows except 10381 and 10388 are the only award on their venue. 10381 (Four Seasons Hotel Hangzhou At West Lake) also has La Liste 10380; 10388 (Amanfayun) also has OAD 10389. Guangzhou 4: read dependents first. Pre-check each venue: awards, price, blurbs, city_label_source, listings, slugs.
   - **b. Non-Michelin row checks.** Carried: move 8056 to the new Obscura venue; check 8057, OAD 8066 and 8067 on Sir Elly's `ve_a8f2e06702`; OAD 3135 on `ve_8ff48e1c8f`; Best Chef 2024/2025, OAD 2025 No. 78 and La Liste 2026 on `ve_78e5d38e3e`; OAD 10389 on `ve_90478c2170`; La Liste 20905 on `ve_37a333f8af`; La Liste 10380 on `ve_1882ac7b25`; Taizhou La Liste `ve_4173a16a48`. New Sep 28: Jing `ve_262d31b59b` Best Chef 1556 and La Liste 1557 (can belong to Jingji `ve_13e93ccbe7`); Lamdre `ve_c95452bfed` OAD 2025 1572 (No. 224) and 1573 (No. 265); Jiexianglou `ve_671b5f074f` OAD 2025 2004 (No. 185) and 2005 (No. 264); Yi Long Court OAD 2025 8082 (No. 296) and 8083 (No. 241). Two ranks in one list on one venue means one row can belong to another restaurant.
   - **c.** Free-list changes and merge candidates as in the Sep 27 handoff. `name_native` for lines 128, 317, 355.
2. **Slug job for the 263 renamed venues** (Claude's recommendation, not yet decided by Ben): new canonical slugs from the new names, old slugs kept as non-canonical rows. Settles "jinling" and "yangzhou". Do before the production swap (mid-October).
3. Chengdu 2027: stage, match test, promote, retire nothing.
4. Plan v1.28, then Great Britain & Ireland, then the carried items from the Sep 24 handoff.
5. Later: 14 stage-match venues with a different Michelin spelling (for example "TRB Hutong" / "Trb Hutong", "Fuchunju" / "Fu Chun Ju", "8 1/2 Otto e Mezzo Bombana" / "8 ½"). Check other publishers before any rename. `name_native` from Michelin for China (469) and Japan (585) venues.
6. Security: RLS off on `award_categories`, `rename_batches`, `rename_rows`. Ben to decide. Do not enable RLS before access policies exist.

## Artifacts
- `retire-michelin-legacy-cn-beijing.sql`, `retire-michelin-legacy-cn-sjz.sql`, `retire-michelin-legacy-cn-fujian.sql`, `cleanup-michelin-cn-guangzhou.sql`: chat files, run Sep 28, not in the repo. The ledger rows 48–51 and `audit_log` are the database record.
- `fixtures/rename/michelin-2026-china-names.csv`, `reports/rename-michelin-2026-china-rename.md`: in the repo, final.
- `fixtures/ingest/michelin-2026-china-decisions.csv` and `michelin-2026-china.csv`: in the repo, final. The decisions file holds the slot evidence for every cleanup row.

## Key ids
Beijing `ci_0420a206ae` · Shanghai `ci_22638a3131` · Guangzhou `ci_d9d7a94326` · Shenzhen `ci_21dab17afb` · Hangzhou `ci_a34cd8e6f4` · Nanjing `ci_d39ef768e9` · Suzhou `ci_3570e53b64` · Yangzhou `ci_8910716549` · Changzhou `ci_e3cbea6f57` · Wenzhou `ci_0f5c87367e` · Taizhou `ci_bab27c24fe` · Fuzhou `ci_056a82f2ca` · Xiamen `ci_627618297c` · Quanzhou `ci_13c0d3cd7c` · Ningde `ci_b11330c9c3` · Chengdu `ci_354b500e3a`.

## Working preferences
- `/ste` style for all data replies. Plain step-by-step directions; Ben is not a developer.
- Judgment decisions one group at a time, with a recommendation and tappable options. When Ben asks, re-present a decision with its evidence restated.
- Ben answers at gates with one word (`go`, `next`, `handoff`). Read the database at each gate. A choice on a tappable option is not a "go": wait for "go" before any write.
- Show each batch as: population and groups, the rows by id with venue, non-Michelin rows on the affected venues, checks (with which ones already passed read-only), exact write plan, expected read-back table.
- Build SQL with code from query results; match id lists against the live rule set before the write. Present the SQL file as the record.
- Gated SQL: pre-check read, then one `BEGIN … DO $$ … RAISE EXCEPTION on any count mismatch … $$; COMMIT;` through the Write connector, then read-back.

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-china-retired-2026-09-28.md). Confirm live counts and ledger ids 48–51 with a Read query. Then prepare open item 1a, the cleanup of the 34 free-venue rows: read each venue's dependents (awards, price, blurbs, city_label_source, listings, slugs, geo, photos, hours, addresses), group the venues by what the evidence supports (delete venue, keep, or merge), and show me the first group with a recommendation and tappable options in /ste style before any write.
```
