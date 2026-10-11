# Handoff: CompassEats, Oct 11, 2026 (17:45 Atlanta). Gap list re-read, Taiwan chosen, Taiwan Cowork brief saved. Next: Taiwan capture in Cowork.

This file replaces `claude/handoff-netherlands-status-done-2026-10-11.md` for live state, decisions and open items. The other files still apply as before:
- `claude/handoff-netherlands-status-done-2026-10-11.md`: the Netherlands slug file (audit 111,062-111,203) and status record (Regent closed, audit 111,204), its methods and dead ends.
- `claude/handoff-netherlands-renamed-2026-10-11.md`: the batch 22 rename record, working rules, the chef-suffix-before-vote method, the "by" rule.
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the Netherlands stage and promote record (the model for the Taiwan stage; promote only, no retire).
- `claude/handoff-netherlands-captured-2026-10-10.md`: the capture-check record and capture methods.
- `claude/handoff-netherlands-brief-2026-10-10.md`: the ceremony-date and label-check table for 10 countries.
- `claude/handoff-belgium-luxembourg-slugs-done-2026-10-10.md`: the slug check against `slug.ts`.
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the slug-file method, the status-only file method.
- `claude/handoff-germany-staged-run1-2026-10-08.md`: the pre-stage simulation method, the city-label audit.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: working rules, database notes, methods and dead ends.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9…672216`): rule 2.1.1 (amended Sep 24), rule 2.1.7.

Working rules (unchanged): see `claude/handoff-netherlands-renamed-2026-10-11.md`. Plain `/ste` replies; populations on every count; one "go" per write batch; no competitor sources; no hand-retyped files; the tie rule; nothing below a Michelin Bib is tracked.

## Live state
Population: whole table. Read Oct 11, about 20:30 UTC (16:30 Atlanta). **No database table changed in this session.**

| Table | Count |
|---|---|
| venues | 11,254 (active 10,886, closed 368) |
| awards | 22,659 |
| Michelin 2025 / 2026 / 2027 rows | 3,545 / 5,320 / 47 |
| listings / slugs | 11,254 / 12,709 (canonical 11,254, non-canonical 1,455) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,258 / 259 / 23,912 |
| price / blurbs / redirects | 7,048 / 142 / 9 |
| source_capture_ledger | 86 (last id 123) |
| audit_log | 106,529 (last id 111,204) |
| ingest_batches | 1, 3-16 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, 22 applied. rename_rows 1,024. |

## Done in this session (Oct 11, 16:23 to 17:45 Atlanta)

**Start check:** all counts, ledger 123, audit 111,204, slugs 12,709 matched the status-done handoff.

**Gap list re-read** (population: Michelin 2025 and 2026 rows by the country of the venue's city): 27 countries with 2025 rows and 0 2026 rows, **1,824 rows** (2,009 minus the 185 Netherlands rows). Largest: Switzerland 226, Thailand 178, Taiwan 175, Austria 158, Hong Kong 145, Singapore 126, South Korea 117, Canada 106, Portugal 78, Mexico 76, Brazil 66, Malaysia 66, Turkey 55, UAE 50, Macao 35, Philippines 34, then 11 countries with 27 rows or fewer. Thailand 2027: no date on guide.michelin.com yet (the 2026 save-the-date came Oct 30, 2025).

**Ben's decision (Oct 11, 17:35): the next country is Taiwan.** Claude's recommendation: largest country that can start now; the site shows year-old stars; promote only; fits before American South (after Oct 21); next edition about Jul 2027. Second choice on record: Singapore (promote only). Retire-path first choice: Austria.

**Taiwan Cowork brief (Ben "go", 17:40):** `claude/cowork-michelin-2026-taiwan.md`, 203 lines, 19,262 bytes, UTF-8, LF, no BOM, NFC, sha256 `b2ba863c7385b5bf14912c786800b2affcf4b8f9389a9f89dc0487dc315da1c5`. Saved to the project (read back). **Not in the repo yet:** Ben uploads it to `docs/cowork-michelin-2026-taiwan.md`. Model: the Netherlands brief, with these changes: Pass 2 in Traditional Chinese (`/tw/zh_TW/`, columns `venue_name_zh`, `city_label_zh`; 17-column header, first 15 = Netherlands header); no assumed price sign (compare with the printed "Price" line, not JSON-LD); the 2025 star comparison from the 2025 ceremony article plus an optional web.archive.org capture; no 2025 Bib rebuild; the Netherlands capture lessons (`localStorage` helper `__tw26_fn` / `__tw26_vfn`, "[BLOCKED]" output, pipe escaping, tab-group recovery); a status and name register for the items below.

## Facts: Taiwan
- **2026 edition (ninth):** Bib list Jul 14, 2026; full selection Jul 21, 2026. 434 restaurants = 61 stars + 146 Bib + 227 Selected. Stars 3 / 9 / 49. Expected rows **207** (3 / 9 / 49 / 146).
  - By city (3 / 2 / 1 / Bib / all): Taipei 2/9/36/37/156; Taichung 1/0/5/23/63; Tainan 0/0/1/30/61; Kaohsiung 0/0/6/21/56; New Taipei City 0/0/0/18/44; Hsinchu County 0/0/1/10/27; Hsinchu City 0/0/0/7/27.
  - New Two Stars: Mizue (new), NOBUO (promoted). New One Stars: Kiku, Mume, Silks House, SHINEYU, Nibbon, Sushi An (promoted); Hābu, Restaurant 12, Yu Dao (new). 13 new Bibs (for example BAA Wanli Goat, Monsoon).
  - The full list article names only 47 One Stars (Taipei 35, no Hsinchu County heading); the ceremony article says 49.
  - Green Star (name still used): 9, new Sur- and Yu Dao. Special awards: Service Cindy Tsai (Circum-); Sommelier Bonnie Chiou (Li.nu, Selected); Young Chef Liu An Hsu (Sushi An); Opening of the Year Yu Dao.
- **2025 edition (eighth):** Bib list Aug 12, 2025; full selection Aug 19, 2025. 419 restaurants. 3 / 7 / 43 / 144 = 197. Bib by city: Taipei 37, Taichung 23, Tainan 30, Kaohsiung 24, New Taipei City 15, Hsinchu County 8, Hsinchu City 7. Two Stars: L'Atelier de Joël Robuchon, logy, Molino de Urdániz, Mudan + A, Eika, Yu Kapo (promoted). New One Stars: the FRONT HOUSE, aMaze, Chuan Ya, FRASSI, Motoichi, La Vie by Thomas Bühner, Sushi Kajin, Hosu.
  - The 2025 full list URL (`/tw/en/article/michelin-guide-ceremony/taiwan-full-list`) now shows 2026.
- **Legacy rows** (population: Michelin rows on venues in Taiwan cities): 175 rows on 175 venues in 6 cities, all labelled 2025, 0 sourced, 0 venues with two Michelin rows. 3 / 6 / 29 / 137. Taipei 79 (2/6/20/51), Tainan 28 Bib, Taichung 27 (1/0/5/21), Kaohsiung 26 (0/0/4/22), Hsinchu County 8 Bib, Hsinchu City 7 Bib. Taiwan venues 209 (34 with no Michelin row); other publishers: asia-50-best-bars 38, oad 28, asia-50-best-restaurants 22, top-500-bars 8, la-liste 7, best-chef-awards 6, worlds-50-best-bars 6.
- **Label check passes (2025 edition):** NOBUO is One Star (2026: Two); A ("Taipei"), EIKA, Yu Kappo at Two Stars; Chuan Ya, FRASSI, HOSU, the FRONT HOUSE, Motoichi ("元一 天婦羅") at One Star. 0 of the 11 new 2026 stars at the 2026 level (Mume `ve_a797b25772` and Silks House `ve_972745a42c` exist with no Michelin row; the others have no venue).
- **Path:** ceremony after June 1, 2026 → amended rule 2.1.1: promote only; the 175 legacy rows stay as 2025 history; no retire batch.
- **Legacy gaps against the 2025 articles:** Molino de Urdániz (Two Stars, no venue; the only name match is the Spanish El Molino de Urdániz y Origen `ve_30e194dd5b`, Urdániz, Spain — do not pair), 14 Taipei One Stars (for example aMaze, Sushi Kajin), 7 Bibs.
- **New Taipei City:** no `cities` row. Taipei holds 51 legacy Bibs against 37 published for Taipei in 2025 (+ 15 for New Taipei City). About 15 New Taipei City venues are likely filed under Taipei. The stage needs a new city row and a decision for those venues (ask Ben; under-merge rule).
- **Status items:** JL STUDIO `ve_506425696b` (Taichung, `closed`, Three Stars 1191; 2026 articles: Three Stars) → probably wrong status, check the card. 麥謎食驗室 Bue mi .Lab `ve_066411c152` (Tainan, `closed`, Bib). Fleur de Sel `ve_3fe7f73a2c` (Taichung, One Star 8393; 2026 full list: Selected; stays active under "nothing below a Bib").
- **Name items for the rename CSV later:** "Taipei" `ve_269ab60a27` (= A, Two Stars 3242, slug `/taipei/taipei`), "EIKA 盈科" `ve_8010044864`, "Yu Kappo" `ve_619429b2c4`, "牡丹．極上 天ぷら．本店" `ve_da97d58bf1` (Mudan), "元一 天婦羅" `ve_337cd1e0fb` (Motoichi), "明福台菜" `ve_4864070326` (Ming Fu), "謙安和 Ken Anho" `ve_83ae36b088`, "承 Sho" `ve_1b6f9b2bd8`, "方蒔 the FRONT HOUSE" `ve_f12636cf86`, "澀 Sur-" `ve_06e033a0b9`, "WOK by obond" `ve_024fc869a8`. 52 Taiwan venues hold Chinese characters in the name (48 with a Michelin row); 0 have `name_native`. The Chinese card names (`venue_name_zh`) are the input for a `name_native` decision (open item 10).
- **City ids:** Taipei `ci_39139f000b`, Taichung `ci_6d39e9b076`, Tainan `ci_8209a3aa4b`, Kaohsiung `ci_c65258d965`, Hsinchu County `ci_8e2de0ec67` (kind `destination_region`), Hsinchu City `ci_6c64d5a334`, Pingtung `ci_746e69451b` (1 venue, no Michelin row).

URLs: 2026 ceremony https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026 · 2026 full list https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list · 2026 Bib https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-2026-bib-gourmand-list · 2025 ceremony https://guide.michelin.com/mo/en/article/michelin-guide-ceremony/michelin-guide-taiwan-starred-restaurant-2025 · 2025 Bib https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-guide-taiwan-2025-bib-gourmand-selection

## Methods that worked (new)
- **WebFetch reads Taiwan articles** on `/tw/en/`, `/ae-du/en/` and `/mo/en/`. The 2025 ceremony article is still online on `/mo/en/`.
- **Legacy gap check by city:** compare the legacy Bib count per city with the per-city Bib count in the Michelin Bib article. A city with too many rows and a city with no `cities` row point to a filing under the wrong city.

## Dead ends: do not retry (new)
- WebFetch of a web.archive.org CDX URL that did not come from a search result (refused: "URL was not in any prior search or fetch result").
- The 2025 Taiwan full list at `/tw/en/article/michelin-guide-ceremony/taiwan-full-list` (now the 2026 page).

## Open items, in order
1. **Taiwan capture (next).** Ben uploads the brief to the repo (`docs/`), then opens a new Cowork session (Opus, Chrome extension) with the opening message below. Cowork delivers `michelin-2026-taiwan.csv` and `michelin-2026-taiwan-log.md`.
2. **Taiwan stage and promote (new chat).** Ben uploads the CSV to `fixtures/ingest/` and the log to `docs/`. Then: CSV hash against the log; counts against the brief (207); read-only pre-stage simulation (Germany method; ASCII `U&'…'` input); city check (New Taipei City row; Hsinchu labels); the Taipei-filed New Taipei City venues (Ben decides); pairing with English and Chinese names; decisions file; stage; dry-run promote; "go"; promote. **No retire.** Then status items (JL STUDIO, Bue mi .Lab), rename CSV (vote + tie rule) and slugs.
3. **American South after Oct 21** (promote only). Then Beijing & Tianjin after the end of October.
4. **Switzerland after Nov 2, 2026** (option A, promote only).
5. **Gap list after Taiwan:** promote-only Singapore; retire-path countries Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; Thailand after its 2027 edition (rule 2.1.7); Canada as three guides.
6. **Hold registers:** Texas, Belgium & Luxembourg, Netherlands, Taiwan (Green Star, four special awards) → special-awards batch.
7. Price from the Michelin card (adds the 196 NL `€` cards and the Taiwan cards). Ben chooses the method.
8. France slug set (148 venues). Ben decides when.
9. `name_native` backfill (China 469, Japan 585, Chengdu 47, **Taiwan from `venue_name_zh`**); Hong Kong Xin Rong Ji duplicate check; Seventh Son (Tsim Sha Tsui) city check.
10. Later-ceremony guides, promote only: Fujian 2027; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027.
11. Carried: rename CSVs (Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest, GB&I; 143 paired venues), re-checked under the tie rule. Special-awards batch; Elche/Elx merge; Sukiyabashi Jiro split; L'Atelier OAD pairs; Mi Xun Teahouse Green Star.
12. Rechecks, no date: Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
13. Ben to decide: Phase 4 and 5 dates; the price method; France slug timing; `cities.venues_count` recount; RLS on `award_categories`, `rename_batches`, `rename_rows`; legacy ß city slugs; Maximo city; apostrophe character policy; Brussels communes; trademark-sign policy.
14. Repo `.env`: Ben to check that the Google Maps and MapTiler browser keys are restricted by HTTP referrer.
15. Plan v1.31: everything listed in the status-done handoff item 15, **plus this session** (gap list 27 countries / 1,824 rows, Taiwan choice, Taiwan facts and label check, the brief).
16. Options B (Phase 3 map-location pass) and C (publish builder): open for later.
17. Project file cleanup, part 2: after the migration is done.

## Opening message for the Taiwan Cowork session
```
Read the brief claude/cowork-michelin-2026-taiwan.md from the project files with the Projects tool (the same file is docs/cowork-michelin-2026-taiwan.md in the GitHub repo, sha256 b2ba863c…315da1c5). Follow it exactly. Use the Chrome extension for guide.michelin.com. Do not touch the database or the repo. Deliver michelin-2026-taiwan.csv and michelin-2026-taiwan-log.md in this chat, then stop and wait for me.
```

## Suggested opening prompt for the next chat (after the capture)
```
Read these handoffs from the project files with the Projects tool: claude/handoff-taiwan-brief-2026-10-11.md first, then claude/handoff-netherlands-promoted-2026-10-11.md for the capture-check, simulation, pairing, stage and promote record, then claude/handoff-germany-staged-run1-2026-10-08.md for the pre-stage simulation method, then claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules, database notes, methods and dead ends. Confirm live counts, ledger id 123, audit_log id 111,204 and slugs 12,709 with a Read query. I attached michelin-2026-taiwan.csv and michelin-2026-taiwan-log.md from the Cowork capture. Check the CSV hash against the log, check the counts against the brief, then run the read-only pre-stage simulation and tell me in /ste style what the Taiwan stage and promote will need, including the New Taipei City question. Give me click steps to upload the two files to the repo. No write before my go.
```
