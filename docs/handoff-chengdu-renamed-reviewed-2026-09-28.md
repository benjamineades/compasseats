# Handoff: CompassEats, Sep 28, 2026. Chengdu renamed, slugs done, review done (7 held). Archive-source ruling received. Next: Chengdu 2026 archive batch, then Germany.

This file replaces `handoff-plan-v129-done-2026-09-28.md` for live state, decisions and open items. The methods, dead ends, database notes, key ids and working preferences in `handoff-michelin-chengdu-2027-done-2026-09-28.md` and `handoff-plan-v129-done-2026-09-28.md` still apply and are not repeated here. Attach all three files to the next chat.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit. Read the database at each gate.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files. A choice on a tappable option is not a "go".

Open items 1 and 2 of the v1.29 handoff are closed (item 2 with 7 venues held, see open item 1 below).

## Live state
Population: whole table. Read Sep 28 after the last write (21:13 UTC).

| Table | Count |
|---|---|
| venues | **11,211** (active **10,845**, closed 366) |
| awards | 22,241 |
| Michelin 2025 / 2026 / 2027 rows | 3,796 / 4,651 / 47 |
| listings / slugs | **11,211** / **12,310** (canonical 11,211, non-canonical **1,099**) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_label_source | 3,244 / **23,826** |
| price | **7,056** (10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | **61** (last id **79**) |
| audit_log | **103,813** (last id **107,184**) |
| ingest_batches | ids 1 and 3–11 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, **10** applied. rename_rows **551** |
| Chengdu `ci_354b500e3a` | 60 venues, 79 slug rows, 32 legacy Michelin 2026 rows |

## Done in this session
All writes: one transaction each, all checks passed, read-back matched.

**1. Chengdu rename (rename job, batch id 10, key `rename-michelin-2027-chengdu`).**
- Majority rule, population the 18 paired venues: 16 hold only Michelin rows (Michelin card name). `ve_41a4101cbd` → "Co-" (3 of 3: Michelin 2027, Asia's 50 Best 2026 No. 69, Best Chef 2025). `ve_db92193fc0`: tie 1–1 (Michelin "Young Art · Yong Ya He Xian (Tongzilin East Road)", La Liste 2026 78.5 "Yongya Hexian (TongZiLin)", laliste.com/places/yongya-hexian-tongzilin-chengdu-shi-cn). Tie to the venue site yangyayy.com (Chinese only, brand 漾亚·雍雅合鲜 = Michelin brand). **Ben: option A**, the Michelin name.
- File `fixtures/rename/michelin-2027-chengdu-names.csv`, 18 rows, sha256 `e403cc3b321455e90d11dc1504ab4a45ff25584102c9dfbeca23a92de50b112c`. Names from the fixture, expected names from the decisions file (no retyping).
- Ben ran dry run, then real run (20:38 UTC). 18 renamed, 0 reject, 0 review, 10 invariants pass. Ledger **78** (michelin, name, 18). Audit 107,124–107,141. Report `reports/rename-michelin-2027-chengdu-rename.md` (commit `e456cd1`). The dry run used ledger 77, batch id 9, audit 107,106–107,123 (rolled back).

**2. Chengdu slugs (gated SQL, Write connector).**
- File `slugs-rename-michelin-2027-chengdu.sql` (China template, 22 anchored changes), sha256 `b7dff78cd4a32fa1b827269a599f721800a44783a0a10a735089b98767626423`. Plan fingerprint `dddd1ec271c0602ba6e4162856fe7c47` (18 rows). New slugs = `slug.ts` rule 18 of 18.
- 18 old canonical rows → non-canonical, 18 new canonical rows. slugs 12,293 → 12,310 after both batches. Audit 107,142–107,177. No ledger row. Examples: `/chengdu/co`, `/chengdu/silver-pot`, `/chengdu/young-art-yong-ya-he-xian-tongzilin-east-road`.
- Ben asked to upload the file to `docs/` as the record (not confirmed done).

**3. Chengdu review, Set 1 (gated SQL, `cleanup-michelin-cn-chengdu-upper-house.sql`, sha256 `6d4c48175e512592db03dbed07694d9875e178bd68995e8f6494a0b3b8531e4a`). Ben: option A.**
- Award 4516 (legacy 2026 One Star, $$$$) moved from Upper House Chengdu `ve_7b747b10ea` to The Hall `ve_cec4b19f8b`. Upper House deleted (city labels 2359, 2360 with 2 hand audit rows, price, slug, listing, venue). Old URL gives a 404. The $$$$ price was deleted, not moved (Jade River precedent).
- Ledger **79** (michelin, award, 1, `cleanup:cleanup-michelin-cn-chengdu-upper-house`). Audit 107,178–107,184.

## Source found this session: the full Chengdu 2026 edition
- Wayback Machine holds 72 Michelin Chengdu restaurant pages from the 2026 edition period (Sep 2, 2025 to Sep 7, 2026). 40 carry a distinction: Two Stars 2, One Star 11, Bib 27 = the published counts.
- Record `chengdu-2026-archive-relay.jsonl` (40 lines: slug, distinction, edition, capture date, locale, name, address, phone, price), sha256 browser = disk `8e9a788eb2cf2ed49897a3c78502f7075b9df487360939b749a520140ce8a6c1`. Sandbox and chat output only, not in the repo.
- Legacy price = Michelin 2026 price on 24 of 24 legacy rows on correct venues.
- The 2 Bibs that left in 2027: Zhu Ji Zhi Mian Pu (Jinjiang) and Shudidanggui (Wuhou).
- The hotel at 81 Bitieshi Street: Michelin 2026 "The Temple House", 2027 "Upper House". Mi Xun Teahouse and Tivano (Selected) are there.
- Missing 2026 rows (real holders with no 2026 row): **15** = 40 published − 25 legacy rows on correct venues (Yu Zhi Lan 1, One Star 9 incl. 4516 on The Hall, Bib 15 incl. Shudidanggui). They are Xin Rong Ji (Two Stars), Hokkien Cuisine, Ma's Kitchen (Jinjiang), and 12 Bibs: Mosnack, Wan San Mian Guan, Hu Er Ge Yao Shan Ti Hua, The Woo's, Zhuan Zhuan Hui, Dumpling & Drinks, Yao Guai Mian, Ting Yuan 399, Guan Jin, Organization South, Cuo Xia, Zhu Ji Zhi Mian Pu.
- Correction: the Set 2 message in chat said 13 Bibs and the Set 1 message said 16 missing rows. The correct numbers are 12 Bibs and 15 rows.

## Ruling, Sep 28: archived Michelin pages as a source (relayed by Ben)
**Yes, with conditions.** An archived capture of a guide.michelin.com page can be the `source_url` of an award row. The publisher is Michelin, not the Wayback Machine. The competitor rule does not apply. The ruling agrees with the history-backfill work item (plan, Sep 16) and sets its test.

Conditions for every archived capture, every guide:
1. Host: `web.archive.org` only. Another archive site needs its own ruling.
2. Page: the captured URL is on `guide.michelin.com`.
3. Date: the archive timestamp is after the edition ceremony and before the next ceremony. Read it from the archive URL. Record both ceremony URLs in the decisions record.
4. Content: the captured page names the edition itself (meta description or JSON-LD, for example "2026 MICHELIN Guide Chengdu"). A timestamp alone is not enough (Forbes 2018/2019 lesson).
5. Count: capture counts per distinction equal Michelin's own article for that edition. Do not write a row that the archive does not show. A gap stays a gap.
6. Evidence: the relay file and its SHA-256 go in the repo under `reports/`. The ledger note names the file and the hash.
7. URL form: store the exact archive URL that the relay read (timestamp and `id_` flag). Use the archived venue page when one exists, else the archived list page (rows then share one URL; say so in the batch note). "All URLs distinct" applies to live batches only.
8. Same ingest job, match test, gates and scope (stars and Bib only). Batch key `michelin-2026-chengdu`, "archive" in the batch note.

What it changes for Chengdu:
- The missing 2026 rows get sourced rows. The decisions from the 2027 batch apply to the same venues.
- The 24 correct legacy rows stay legacy. No sourced twin (invariant: no venue holds two Michelin rows with the same year and category). Row 4516 on The Hall is also a correct legacy row now, so 25 rows stay legacy.
- After the promote, the 7 held venues go to cleanup under the contamination rule: full venue pre-check before any delete, one "go" per batch.
- Other guides: the method is admitted; each edition capture passes conditions 1 to 6 on its own. The general history backfill still starts after launch (Sep 16 timing).

**Count note for the ruling:** the ruling text says 16 rows and 13 Bibs. Those numbers came from my wrong chat message. The correct batch is **15 rows**: Xin Rong Ji (Two Stars), Hokkien Cuisine, Ma's Kitchen (Jinjiang), 12 Bibs.

**The Sep 28 relay does not pass the conditions as it is. Rebuild it before the batch:**
- It kept only the first capture of each page and only 8 digits of the timestamp. Condition 7 needs the full 14-digit timestamp in the stored URL.
- 6 of its 27 Bib records are Sep 1, 2025 captures with "2025" in the meta description (pre-ceremony, fail conditions 3 and 4): Dumpling & Drinks, Yao Guai Mian, Zhuan Zhuan Hui (all 3 in the batch) and Lao Chengdu, Rong Yuan, Rongrong (legacy, not in the batch).
- Later captures exist for at least 2 of the 3 batch Bibs (read Sep 28, edition text not read yet): Dumpling & Drinks `en` 20250918143854 and 20251215091704; Yao Guai Mian `us/en` 20251019105523 and 20251114022202, `en` 20250903040814. Zhuan Zhuan Hui: not read (CDX rate limit).
- The 2026 and 2027 ceremony URLs are not recorded yet (condition 3).
- The condition 5 count check is on the whole edition (40), so the rebuilt relay needs a passing capture for all 40, the 25 legacy rows included.

## Decisions by Ben after the ruling, Sep 28
1. **Pilot: no.** The Chengdu 2026 batch is "archive method test 1", not the backfill pilot. Reason: the pilot must prove the method on one large guide and size the work back to 2018; Chengdu cannot size the work and does not test an edition with no legacy rows. Plan v1.30: record "archive method test 1"; put ruling conditions 1 to 8 into the history-backfill work item as rules. The pilot stays after launch, on one large guide (France 2025 is the natural choice).
2. **The 25 correct legacy Chengdu 2026 rows: set `source_url` in place.** Reason: "legacy rows stay blank" exists because no source showed their facts; the archive now shows each row. A twin is not possible (same year, same category invariant). Delete-and-insert loses row ids and the audit line; an update keeps both. Conditions:
   1. Run it after the 15-row promote, not before.
   2. Per-row test before the "go": archive card and row agree on venue (by the 2027 decisions file), category and price. 25 of 25 must pass. A failing row stays blank and goes to the cleanup list.
   3. One `UPDATE`, one transaction, 25 rows. The `awards` trigger writes 25 audit rows. Read-back: 25 rows changed, `awards` count unchanged.
   4. Ledger row with the archive URL, the relay file name, the hash, and the note "original capture May 13 to June 1, 2026, sourced from archive". (May 13 to June 1, 2026 is the legacy snapshot window from the Sep 15 ruling.)
   5. After the batch, the rule 6 read for Chengdu 2026 shows only the 7 held rows as unsourced. After their cleanup, 0.
   NOTE: row 4516 now sits on The Hall (moved by ledger 79). Its test uses The Hall's 2027 card (26921), not the 2027 decisions file.
3. **Italy 4 and Spain 6 leftover legacy rows: after launch,** in the same per-guide cleanup item as France 20 and Japan 11, one treatment at one time. Reason: condition 5 needs the whole edition from the archive (Italy 2026 is about 649 cards). The small read (below) was done now, no writes.

Ben's decision text says "16-row batch"; the correct count is 15 (see the count note above).

## Small read, Sep 28: Italy and Spain 2026 list pages in the Wayback Machine
Population: CDX index, `guide.michelin.com/<locale>/selection/<country>/restaurants` prefix, status 200, from the ceremony to Sep 29, 2026. Locales read: us/en, en, gb/en, it/it, es/es, sg/en, hk/en, fr/fr, de/de. No writes.

| Guide | Window start (ceremony) | Distinction list pages needed (48 cards/page, ceremony counts) | Archived |
|---|---|---|---|
| Italy 2026 | Nov 19, 2025 | 16 (Three 15 → 1, Two 38 → 1, One 341 → 8, Bib 255 → 6) | **0 of 16** |
| Spain 2026 | Nov 25, 2025 | 13 (Three 16 → 1, Two 37 → 1, One 254 → 6, Bib 204 → 5) | **0 of 13** |
| Andorra 2026 | Nov 25, 2025 | 1 (One Star) | **0 of 1** |

- The only captures are the unfiltered country page 1 (all distinctions and Selected mixed, 48 cards): Italy 8 captures (us/en 20251212211228, 20260212113237, 20260415174937; gb/en 20260120052824; hk/en 20251213235618, 20260208081031; fr/fr 20251205020524; de/de 20260208091959). Spain 3 (us/en 20260213005327; gb/en 20251222091008; fr/fr 20260106065806). Andorra 0. No `/page/N` capture and no distinction-filtered capture.
- Meaning: the list-page route cannot pass condition 5 for Italy or Spain 2026. The pilot must use archived **venue pages** (the Chengdu route). Their count is not read yet (a CDX prefix per region; `matchType=domain` does not answer).
- Not checked: whether a country list page names the edition (condition 4).

## Decisions by Ben, Sep 28 (this session)
- Yongya Hexian name: **A**, "Young Art · Yong Ya He Xian (Tongzilin East Road)" (tie to venue site).
- Set 1 Upper House: **A**, move 4516 to The Hall, delete the venue, 404.
- Set 2, the 7 legacy Bib venues: **B, hold** until the archive-source ruling. Venues: Citadines South Chengdu `ve_29c8d7a57b` (9785, $$), Jincheng Fengqiwu Freshwater Fishes Restaurant `ve_a63b7965ed` (9778, $$), Shudaxia Hot Pot Luomashi Branch `ve_ff8d4998fc` (9774, $$), Tivano `ve_51c6534d14` (9789, $$, Michelin 2026 Selected only), Ma Wang Zi Chuan Restaurant `ve_8593c366aa` (9783, $), Shuyanfu `ve_c2e875e4a0` (9779, $), Zhongshuijiao `ve_27c721b197` (9775, $). None is a 2026 Bib. Price leaves 6 candidates per row, so no pairing is provable. Claude recommended A (delete under the contamination rule); Ben chose to hold.
- Shu Di Dang Gui `ve_f6f3a8b280` (9788): correct 2026 Bib, left in 2027. No change.

## Methods that worked (new this session)
- **La Liste place lookup:** `https://www.laliste.com/sitemap.xml` (4,518 URLs) from a tab on laliste.com, filter by city, then fetch the `/places/<slug>` page and read `h1` and the page text (score, address, phone). The search URL gives "Not Found". Guessed slugs give 404.
- **Wayback CDX from a tab on web.archive.org:** `/cdx/search/cdx?url=guide.michelin.com/<locale>/<region>/<city>/restaurant/&matchType=prefix&from=202509&to=202609&output=json&fl=timestamp,original&filter=statuscode:200&collapse=urlkey`. Start the fetch, store on `window.__x`, read it later (CDX answers take 10–40 s). Raw page: `/web/<ts>id_/<url>`, then the Michelin JSON-LD and meta description as usual. Wildcards in the middle of a CDX URL do not work.
- Rename CSV check query: generate the SQL `VALUES` from the CSV by script, with an md5 guard of the values checked in SQL.
- `norm_key` of a very short name ("Co-") is NULL. The column allows NULL (107 venues before), and the rename job treats NULL as "no group".

## Dead ends: do not retry (new this session)
- `audit_log.op` (the column is `action`; the key is `row_pk`).
- A 2027 check by `awards.distinction` (2027 Michelin rows use `category`, `distinction` is NULL).
- Wayback URL `.../chengdu/restaurants/bib-gourmand` (no capture). The all-restaurants list pages hold only page 1 (52 cards), so read the archived venue pages instead.
- La Liste venue page "Website" link (it is `#`).
- Bash process substitution `<( )` (again). Write temp files.
- CDX `matchType=domain` with an `original` regex filter (no answer after 40 s). Many parallel CDX calls give HTTP 429. Query one exact URL per locale, a few at a time.

## Artifacts
- `fixtures/rename/michelin-2027-chengdu-names.csv`: in the repo, final (batch 10).
- `reports/rename-michelin-2027-chengdu-rename.md`: in the repo, written by the job.
- `slugs-rename-michelin-2027-chengdu.sql`: final, run. Target `docs/` (Ben to upload; check).
- `cleanup-michelin-cn-chengdu-upper-house.sql`: chat file, run, not in the repo. Ledger 79 and audit_log are the record.
- `chengdu-2026-archive-relay.jsonl`: chat file, the 2026 evidence record (checksum above).

## Open items, in order
1. **Chengdu 2026 archive method test 1 (next), three gated steps:**
   1. Rebuild the relay under the ruling (full 14-digit timestamps, a 2026-edition capture for all 40, both ceremony URLs), SHA-256, file to `reports/`. Build the 15-row ingest file (batch key `michelin-2026-chengdu`, "archive" in the note), stage, review, promote. One "go" per write.
   2. The 25-row `source_url` update in place (Ben decision 2 conditions). One "go".
   3. Cleanup of the 7 held venues under the contamination rule (full pre-check, one "go").
2. **Germany, #8 (806 legacy / 0 sourced) (next work block):** ceremony date from a guide.michelin.com URL, 2027 edition check (rule 2.1.7), label check on the 338 rows labelled 2026, then promote and cleanup under amended rule 2.1.1.
3. France slug set (148 venues). Ben decides when.
4. `name_native` backfill (China 469, Japan 585, Chengdu 47); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
5. Price from the Michelin card (3,739 venues, plus The Hall ¥¥¥¥ now). Ben chooses the method.
6. Later-ceremony guides, promote only: Texas after Oct 8, American South after Oct 21, Beijing & Tianjin after the end of October, Fujian 2027, Northeast Cities after Dec 14, Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
7. Carried: rename CSVs for Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest and GB&I (143 paired venues; Glovers Alley by Andy McFadden → by Adam Nevin); new: Shu Di Dang Gui → "Shudidanggui (Wuhou)" (Michelin 2026, one publisher). Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs. Mi Xun Teahouse Green Star (no column).
8. Rechecks, no date: Dill (status), Kilberry Inn (reopening date), Endo at the Rotunda (reopening), Hare & Hounds (reopening after the fire).
9. Plan update (v1.30): Chengdu rename batch 10, slug file, Set 1 cleanup (ledger 79), the archive source, the held 7, the Sep 28 ruling (15-row count), Ben's three decisions ("archive method test 1"; conditions 1 to 8 as rules in the history-backfill item; pilot after launch, France 2025 the natural choice; 25-row update and its 5 conditions; Italy/Spain after launch), the Italy/Spain small-read table. Not started.
10. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows` (no RLS before access policies exist).

## Suggested opening prompt
```
Read the attached handoffs (handoff-chengdu-renamed-reviewed-2026-09-28.md first, then handoff-plan-v129-done-2026-09-28.md and handoff-michelin-chengdu-2027-done-2026-09-28.md for methods, dead ends and database notes). Confirm live counts, ledger id 79 and audit_log id 107,184 with a Read query, and check that docs/slugs-rename-michelin-2027-chengdu.sql is in the repo. Then start open item 1, the Chengdu 2026 archive batch, under the Sep 28 ruling: find the 2026 and 2027 Chengdu ceremony URLs, rebuild the archive relay with full timestamps and a 2026-edition capture for all 40 distinctions, and tell me in /ste style which conditions pass. Then build the 15-row ingest file, stage it read-only and wait for my go. No write before my go.
```
