# Handoff: CompassEats, Sep 28, 2026. Michelin Chengdu 2027 promoted. Next: Plan v1.28.

This file replaces `handoff-michelin-china-slugs-done-2026-09-28.md` for live state, rulings and open items. All working rules in the earlier handoffs still apply: plain `/ste` replies, populations on every count, one "go" per write batch, read-back after each commit, under-merge over over-merge, no competitor sources (Pearl, TBRG, Beli), no hand-retyped files. Ignore `enprimeurclub.com` and `joinpearl.co` results in web search.

Open item 1 of the slugs-done handoff (Chengdu 2027) is closed.

## Live state
Population: whole table. Read Sep 28 after the Chengdu promote (the last write of the session).

| Table | Count |
|---|---|
| venues | **11,209** (active **10,848**) |
| awards | **22,237** |
| Michelin 2025 / 2026 / 2027 rows | 4,178 / 4,265 / **47** |
| OAD 2025 rows | 2,437 |
| Asia's 50 Best Restaurants rows (all years) | 587 |
| listings / slugs | **11,209** / **12,290** (non-canonical 1,081, canonical 11,209) |
| venues with more or less than 1 canonical slug | 0 |
| cities | 3,244 |
| city_label_source | **23,822** |
| price | 7,059 (10 with `source` = `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **55** (last id **70**) |
| audit_log | **102,946** (last id **105,898**) |
| ingest_batches | ids 1 and 3–**10** promoted (no id 2) |
| rename_batches | ids 2, 4, 6, 8 applied. rename_rows 533 |
| Chengdu `ci_354b500e3a` | 61 venues, 62 slug rows |

## Done in this session

**Michelin Chengdu 2027 ingest, batch 10, key `michelin-2027-chengdu`.**
- Source read (Chrome, guide.michelin.com, Sep 28): 47 cards, 1 Three Stars / 1 Two Stars / 13 One Star / 32 Bib Gourmand. The same counts are in the Chengdu 2027 ceremony article and the Sep 24 China log. All 47 venue pages say "2027 MICHELIN Guide Chengdu". Card compared with page (name, city, distinction, price): 0 differences. Chinese names 47 of 47 from the `sg/zh_CN` lists. Relay SHA-256 browser = disk `e5496015ac5035348fec67e23c69c61bc6a75ff7b6d2ec51b3ddb8ad3004ce8f`.
- Stage run 1 (no decisions): 5 match, 2 review_venue (line 1 Xin Rong Ji `same_key_other_city`, line 14 Co- `norm_key_too_short`), 40 new_venue, 0 reject.
- Stage run 2 (19 decisions): 23 match, 24 new_venue, 0 review.
- Promote dry run: all 11 invariants pass. Real promote: Sep 28 14:49 UTC.
- Write record: awards +47, venues / listings / slugs +24 each, city_label_source +48 (note `michelin-2027-chengdu`, `city_display=Chengdu` and `country=China`), price +0. Ledger 69 (michelin, award, 47) and 70 (michelin, city_label, 48), job `ingest-promote:michelin-2027-chengdu`. Audit 105,780–105,898 (119 rows: awards 47, venues 24, listings 24, slugs 24, all INSERT). The dry run used ledger 67–68 and audit 105,661–105,779 (empty).
- Row checks: 47 of 47 source URLs are Chengdu Michelin cards, all distinct. URL and category agree with the staged rows on 47 of 47. Match rows on the staged venue: 23 of 23. 0 awards outside Chengdu. Legacy Chengdu Michelin 2026 rows: 32, not changed (nothing retired).

**Facts from Michelin's own articles.**
- Chengdu 2026 (https://guide.michelin.com/mo/en/article/news-and-views/michelin-guide-chengdu-2026): Two Stars Xin Rong Ji, Yu Zhi Lan. 11 One Stars: Chaimen Hui, Fang Xiang Jing, Fu Rong Huang, Ma's Kitchen (Jinjiang), Silver Pot, Xu's Cuisine, Young Art · Yong Ya He Xian (Tongzilin East Road), Hokkien Cuisine, Mi Xun Teahouse, The Hall, Co- (promoted 2026). 27 Bib Gourmand.
- Chengdu 2027 (https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-stars-chengdu-2027): Xin Rong Ji promoted to Three Stars. The same 11 keep One Star. New One Stars: Focus by Bill Yue, Zinan. 7 new Bibs: Ban Tian Te Se Mian, Da Ya Ji, Gui Tian Yuan Zi, Mao Wu Da Jiu Dian, No.37 Lao Yuan Ba Chao Shou, Ren Ren Shui Jiao, Xiao You Shao Mai (Qingyang). So 25 Bibs carried over and 2 Bibs left. 37 Selected (new: Fu Rong Chuan, Xiao Ya Tang Wu).

**Other source reads.**
- Asia's 50 Best 2026, No. 69 = **Co-**, Chengdu (publisher press release, March 12, 2026, via PR Newswire).
- Best Chef Awards 2025 (`thebestchefawards.com/events-results/?id=2376`): Jin Yang, **Co-**, Chengdu, img alt "2 knifes".
- Michelin card descriptions: Silver Pot is Sichuan food, not hot pot. Mi Xun Teahouse is "in a quiet hotel next to Daci Temple" (address "Upper House, 81 Bitieshi Street"). The Hall is the Louis Vuitton restaurant in a 1730s heritage building (Taikoo Li).

## Rulings and decisions, Sep 28 (this session)
- **Set 1 (Ben): option C.** Pair the two legacy One Star venues that pass rule 6b: Heming Tea House `ve_37910677a4` → Mi Xun Teahouse (line 5), Xiaolongkan Old Hot Pot `ve_ad0bb34099` → Silver Pot (line 11). Upper House Chengdu `ve_7b747b10ea` is not paired (the price points to The Hall, the hotel points to Mi Xun), so The Hall is a new venue.
- **Decisions file** (Claude's pairings, staged and promoted by Ben). The 18 `use:` rows, line → venue, legacy name:
  - Line 4 Fang Xiang Jing → `ve_e1109450cf` "Aromatherapy Jing".
  - Line 5 Mi Xun Teahouse → `ve_37910677a4` "Heming Tea House".
  - Line 7 Xu's Cuisine → `ve_36ae4d6bcd` "Xujia Cai (Wangjiang Branch)".
  - Line 8 Fu Rong Huang → `ve_a3b31ca55d` "Furonghuang Garden Restaurant".
  - Line 9 Young Art · Yong Ya He Xian (Tongzilin East Road) → `ve_db92193fc0` "Yongya Hexian".
  - Line 11 Silver Pot → `ve_ad0bb34099` "Xiaolongkan Old Hot Pot".
  - Line 14 Co- → `ve_41a4101cbd` "Chenmapo Sichuan Restaurant" (it also holds the Co- rows for Asia's 50 Best 2026 No. 69 and Best Chef 2025 2-Knife).
  - Line 15 Chaimen Hui → `ve_d33390c047` "Chaimen Residence".
  - Line 17 Yangboying Chuan Tong Za Jiang Mian → `ve_9c004b1f6f`.
  - Line 18 Lao Chengdu Yi Cheng Xian San Yang Mian → `ve_4f5d44401e`.
  - Line 20 Gan Ji Fei Chang Fen → `ve_a64a235506`.
  - Line 22 Long Sen Yuan (Qingyang) → `ve_7ab59d83eb`.
  - Line 24 Bai Nian Fen Zheng Niu Rou → `ve_84dc39ab0e`.
  - Line 25 Gong Zhou · Ba Shu Wei Yuan → `ve_820878c98e` "Jinjiang Bashu Weiyuan".
  - Line 28 Nian Feng Restaurant → `ve_69877791d1` "Nianfeng Alley".
  - Line 30 Chen Mapo Tofu (Qinghua Road) → `ve_b8255461a4`.
  - Line 32 Rong Yuan Can Guan → `ve_67f01b1cdf` "Rongyuan Restaurant".
  - Line 40 Mind (Wuhou) → `ve_133ee0a10d`.
  - Line 1 Xin Rong Ji = `new` (the Hong Kong, Shenzhen and Hangzhou venues are other branches).
  - Exact matches (no decision): line 2 Yu Zhi Lan `ve_9962046586`, line 19 `ve_208a1abe67`, line 29 `ve_4500db80db`, line 37 `ve_e573ea7e30`, line 38 `ve_fa5e39740d`.
- New venues include: Xin Rong Ji `ve_b271ef2331` (`/chengdu/xin-rong-ji`), The Hall `ve_cec4b19f8b`, Ma's Kitchen (Jinjiang) `ve_6ce4e59ddf`, Zinan `ve_f4300dee32`, Focus by Bill Yue `ve_638e8e4893`. The full list is in `reports/michelin-2027-chengdu-promote.md`.
- Scope rule kept: stars and Bib Gourmand only. Selected venues are not ingested (as for China 2026).

## Findings for later (not decided)
- **Chengdu legacy 2026 rows with no 2027 card:**
  - Upper House Chengdu `ve_7b747b10ea` (One Star, $$$$).
  - 8 legacy Bib venues: Citadines South Chengdu, Jincheng Fengqiwu Freshwater Fishes Restaurant, Ma Wang Zi Chuan Restaurant, Shu Di Dang Gui, Shudaxia Hot Pot Luomashi Branch, Shuyanfu, Tivano, Zhongshuijiao.
  - Tivano is on the 2027 Selected list (¥¥¥, Italian).
  - Ma Wang Zi (马旺子) is the brand of One Star Ma's Kitchen (Jinjiang), but the category and price differ, so it was not paired.
  - Where a legacy name is contamination, the 2027 card is now a separate new venue: The Hall and 11 carried-over Bibs (Mosnack, Wan San Mian Guan, Hu Er Ge Yao Shan Ti Hua, The Woo's, Zhuan Zhuan Hui, Dumpling & Drinks, Yao Guai Mian, Ting Yuan 399, Guan Jin, Organization South, Cuo Xia).
- Stray non-canonical slug `chengdu/yuzhilan-fabrics` on Yu Zhi Lan.
- Mi Xun Teahouse has a Green Star (article). No Green Star column exists.
- **Beijing heads-up (China log, Sep 24):** Michelin said a combined Beijing & Tianjin selection comes by the end of October 2026. Expect a new Beijing edition.
- Carried from the slugs-done handoff:
  - France slugs: 148 of 269 venues in rename batches 2 and 4 keep an old-name canonical slug.
  - Old slugs with another business name (for example `beijing/ling-long` on Lamdre). The Ling Long Beijing ingest will get `ling-long-2`.
  - New site: all non-canonical slugs (1,081) need a 301 to the canonical URL in the URL-parity check.
  - Seventh Son (Tsim Sha Tsui) `ve_a73796bf14` filed in Beijing.
  - Future ingests: Meet the Bund Skyline (La Liste 79.5), La Liste Shanghai Xin Rong Ji 90.5 (on The House of Rong), Ling Long Beijing.
  - OAD undated "Top Restaurants" rank.
  - Hong Kong Xin Rong Ji `ve_f966b7e0a1` / `ve_4dc9197f86` possible duplicate.
  - OAD row 1249 on L'Osier.
  - `cities.venues_count` is stale.
  - JiangNan Wok `ve_1bd53c45d6` stays (ruling J2).

## Source-reading methods that worked (new this session)
- **Michelin city lists:** `https://guide.michelin.com/us/en/chengdu-municipality/chengdu/restaurants/<3-stars-michelin|2-stars-michelin|1-star-michelin|bib-gourmand|the-plate-michelin>`. In-page `fetch()` + `DOMParser` from a tab on guide.michelin.com. Cards only inside `.row.restaurant__list-row.js-restaurant__list_items`. The name link is the `a` with no child elements and non-empty text. City and price come from `.card__menu-footer--score` (price before " · ", cuisine after).
- **Chinese names:** the same path under `https://guide.michelin.com/sg/zh_CN/...`, joined on the URL part after `/restaurant/`.
- **Venue page:** JSON-LD `@type` Restaurant (`name`, `address.addressLocality`, `streetAddress`, `telephone`, `starRating` / `award.awardFor` as words, `priceRange` as words: On a budget ¥, A moderate spend ¥¥, Special occasion ¥¥¥, Spare no expense ¥¥¥¥). Meta description "in the YYYY MICHELIN Guide <city>".
- **Relay:** tool output stops at about 1,000 characters. Write JSON lines (non-ASCII as `\uXXXX`) into `document.body`, read them with `get_page_text`, save to disk, and compare SHA-256 (sorted lines joined with `\n`). A 64-character hash output is blocked as "base64": print it in 8-character groups.
- **Long browser scripts:** a call stops at 45 s ("Runtime.evaluate timed out"), but the script keeps on in the page. Store results on `window.__x` and read them again later.
- **Match test in SQL (read-only):** `norm_key(name)` is a database function. The loose key and city label rules are in `scripts/ingest/lib/looseKey.ts` and `db.ts` (`normLabel`). Write them inline, because there is no `norm_label()` function in the database.
- The stage job applies a `decision` to any line, not only to review lines (`applyVenueDecisions` in `scripts/ingest/stage.ts`). A decisions file needs an existing batch, so run 1 has no decisions file.
- Promote writes 2 city labels per new venue and 2 ledger rows per batch.

## Dead ends: do not retry
- Grouping `slugs` by `property_id` for the one-canonical check. `property_id` is the site ("eats"). Use `slugs.venue_id`.
- `price.symbol` (the column is `symbol_raw`), `award_sources.id` (the key is `slug`), `norm_label()` (no such function).
- `fetch()` to guide.michelin.com from a tab on another site: "fetch blocked". Navigate the tab to guide.michelin.com first.
- Regex "upper house" on Michelin page HTML: every page matches, because of shared page parts. Read the description instead.
- `git pull` on the shallow clone ("divergent branches"). Do a fresh `git clone --depth 1`.
- Carried:
  - Deleting old slugs.
  - Expecting identity ids to follow on after a dry run.
  - `CREATE TEMP TABLE` in a gated SQL file.
  - `$$` as the `DO` marker when the SQL has a `'$$'` literal.
  - `web_fetch` on oadguides.com lists.
  - `fetch()` of La Liste search from page JS.
  - Hand SQL for a name change (use the rename job).
  - The GitHub API from the sandbox (use `git clone --depth 1` or `raw.githubusercontent.com`).
  - Stage input error: `csv_path` = source CSV, `decisions_path` = decisions CSV.

## Open items, in order
1. **Plan v1.28 (next).** Then Great Britain & Ireland, then the carried items from the Sep 24 handoff. (This session did not discuss the content of v1.28.)
2. **Chengdu rename CSV:** Michelin spellings for the 18 paired legacy venues (majority rule, Sep 14). `ve_41a4101cbd` → "Co-" (3 of 3 publishers). Other publishers on some venues can change the majority: check La Liste and OAD on Yu Zhi Lan-type venues before each row. After the rename, run the slug job with the same SQL-file method as China.
3. **Chengdu retire and merge review:** Upper House Chengdu and the 8 legacy Bib venues (see Findings).
4. France slug set (148 venues), same file method. Ben to decide when. Optional: a reusable "Slug — apply" button.
5. `name_native` backfill from Michelin: China (469), Japan (585), and now Chengdu (47, column `name_native_michelin` in `fixtures/ingest/michelin-2027-chengdu.csv`). Also lines 128, 317, 355 and Hangzhou House (兰轩). 14 stage-match venues with a different Michelin spelling. `cities.venues_count` recount (Ben to decide). Hong Kong Xin Rong Ji duplicate check. Seventh Son (Tsim Sha Tsui) city check.
6. Security: RLS off on `award_categories`, `rename_batches`, `rename_rows`. Ben to decide. Do not enable RLS before access policies exist.

## Artifacts
- `fixtures/ingest/michelin-2027-chengdu.csv`: in the repo, final (batch 10). 47 rows, 16 columns (China shape), LF line ends, sha256 `c9ad56a8dadb53004270cc84e9a732014719424e753bd1b63b4242d655048f30`.
- `fixtures/ingest/michelin-2027-chengdu-decisions.csv`: in the repo, final. 19 rows, quoted, CRLF, sha256 `fe8c056a249fd8802defc6a155b7be93772999280375560c90bc9be88206d826`.
- `reports/michelin-2027-chengdu-stage.md`, `-review.csv` (0 rows after run 2), `-promote.md`: in the repo, written by the jobs.
- `relay.jsonl` (47 lines, card data plus address and phone): sandbox only, not in the repo. The checksum above is the record.
- Earlier files as in the previous handoffs (`slugs-rename-michelin-2026-china.sql` is the template for the next slug set).

## Key ids
Beijing `ci_0420a206ae` · Shanghai `ci_22638a3131` · Guangzhou `ci_d9d7a94326` · Shenzhen `ci_21dab17afb` · Hangzhou `ci_a34cd8e6f4` · Nanjing `ci_d39ef768e9` · Suzhou `ci_3570e53b64` · Yangzhou `ci_8910716549` · Changzhou `ci_e3cbea6f57` · Wenzhou `ci_0f5c87367e` · Taizhou `ci_bab27c24fe` · Fuzhou `ci_056a82f2ca` · Xiamen `ci_627618297c` · Quanzhou `ci_13c0d3cd7c` · Ningde `ci_b11330c9c3` · Chengdu `ci_354b500e3a`.

## Database notes
- `awards` columns: id, venue_id, source_id, year, rank, category, distinction, source_url. `source_id` holds the publisher slug. Unique rule `awards_no_dupes`, NULLS NOT DISTINCT.
- `slugs` columns: property_id (site, "eats"), city_slug, slug, venue_id, is_canonical. Primary key (`property_id`, `city_slug`, `slug`). **No database rule forces 1 canonical row per venue**: every slug write must check it by `venue_id` (0 venues off today).
- `award_sources` key is `slug` (michelin: `active`, `price_capable` false). `price` has `symbol_raw`, `tier`, `source` (enum `price_source_t`, do not `coalesce(source,'')`).
- `ingest_rows` columns: id, batch_id, raw (jsonb), validation (jsonb with `line`, `reason`, `venue_id`), verdict.
- `city_label_source` columns: id, venue_id, label, from_column, publisher, note.
- `source_capture_ledger`: id (identity), publisher, field_type, items, captured_at, job.
- Tables with a `venue_id` foreign key: slugs, blurbs, listings, awards, geo, addresses, price, hours, photo_refs, city_label_source. Venue delete order: city labels, then awards, price, city_label_source, slugs, listings, venues.
- Audit triggers on awards, venues, price, slugs, listings. Not on `city_label_source` or `source_capture_ledger` (hand audit rows). `audit_log.id` is an identity column.
- `rename_rows.expected_name` holds the pre-rename name. The rename job never changes a slug. `trg_venue_rename` blocks hand renames.
- A `DELETE` / `UPDATE` through the Read connector fails with "read-only transaction". Use this as the dry run.

## Working preferences
- `/ste` style for all data replies. Plain step-by-step directions. Ben is not a developer. Ben runs GitHub Actions jobs himself: give numbered click steps with exact field values, and a CAUTION when a box must be ticked or not ticked.
- Uploads: tell Ben not to open the CSVs in Excel or Numbers before the upload (Chinese characters and ¥ signs).
- Judgment decisions one set at a time, with a recommendation and tappable options. A choice on a tappable option is not a "go": after the choice, do a fresh read, confirm the file matches the choice, and wait for "go".
- Ben answers at gates with one word (`go`, `next`, `done`, `handoff`). Read the database at each gate.
- Order used for an ingest: stage run 1 (no decisions), run 2 (decisions), promote dry run, then a separate "go" for the real promote, then the read-back.
- Build the file first, check it read-only, present it as the record, then ask for the choice. If a write fails, read the database to prove nothing changed, fix the file, and ask for a new "go".
- Source reads only from the publisher's own list or release. Third-party directories can support but never decide.
- Suggest a handoff break before a new large block of work.

## Suggested opening prompt
```
Read the attached handoff (handoff-michelin-chengdu-2027-done-2026-09-28.md). Confirm live counts, ledger id 70 and audit_log id 105,898 with a Read query. Then prepare open item 1, Plan v1.28: find the current plan version and its open items in the project files (Rearchitecture Plan, Punch List, runorder) and in the repo docs, tell me in /ste style what v1.28 must change, and ask me any question where the documents do not decide it.
```
