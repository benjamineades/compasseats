# Handoff: Taiwan 2025 backfill done (item 2, H1). Nov 1, 2026 (15:27 Atlanta). Next: Ben chooses.

This file replaces `handoff-forum-blurb-done-2026-11-01.md` for live state and open items (that file keeps the Forum blurb and
apostrophe records). Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.

## Ben's input (ET, Nov 1)
- 14:41 "G1" (apostrophe item closed, no write). 14:55 "2" (2025 Green Star backfill). 15:02 "H1" (Taiwan 2025, D8 method).
- 15:07 "J1, K1, L1, M1": J1 = fill URLs on 38 existing 2025 star rows, insert 14 missing star rows and 3 Green Star rows;
  K1 = source_url is the archive id_ URL; L1 = pairs A, Mudan (MUDAN TEMPURA), T+T by venue id; M1 = skip 5 lines with no venue.
- 15:24 "go" (committed).

## Live state (read Nov 1, 20:25:30 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | **23,560** (last id **30,499**); Michelin **9,856**; Michelin 2025 **3,480** (no URL **3,243**); Green Star 2025 **12** |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 (rewritten 1) |
| price | 7,733 |
| source_capture_ledger | **161** rows, last id **213** (210, 212 used by rolled-back runs, no rows) |
| audit_log | **116,478** rows, last id **121,990** |
| cities / venues_count | 3,260 / sum 10,934 |

## Done in this session (after the Forum handoff)
1. Read: Green Star rows by year (2025: 9, 2026: 129) and by country. Spain, Japan, UK, France, Italy have almost no 2025 history
   (a 2025 Green Star there needs a full D8-style 2025 job). Taiwan, Vietnam, China, US have 2025 rows with no URL.
2. Archive read (built-in browser): capture 20251115192102 of `/tw/en/article/michelin-guide-ceremony/taiwan-full-list`, status 200.
   Sections 3 / 7 / 43 = headings. **Green Star heading says 6, the list names 7**; the Aug 19, 2025 ceremony article confirms 7.
   Relay `docs/tw-2025-build/relay-tw-2025-archive-20251115192102.txt` (60 lines, sha256 `947c8ebe...342e0a`), commit `c5b7f07`.
3. Match: 55 of 60 lines (t1 52, use 3). 5 no venue (M1): Paris 1930 de Hideki Takayama (One Star 2025, Selected 2026); EMBERS,
   Yangming Spring (Shilin), Tu Pang, Thomas Chien (Green Star only, no star or Bib, not tracked).
4. 2025 Bib article capture 20250812045317 (`michelin-guide-taiwan-2025-bib-gourmand-selection`): 144 Bibs by count, names only
   some new ones. No archive full list for the 2025 Bibs; the Taiwan 2025 Bib rows keep no URL.
5. **Run** committed (Write connector, first try): awards 30483-30499 (17 INSERT), 38 URL fills. Ledger **213**. Audit
   **121,936-121,990**. File `docs/backfill-michelin-2025-taiwan.sql` (sha256 `6a818b00...ad9d1ee`), commit `2cf5cde`.
   Run record `docs/tw-2025-build/run-backfill-tw-2025-2026-11-01.txt`.

## Methods and notes (new)
- `norm_key()` returns NULL for the names "A" and "T+T" (venues `ve_269ab60a27`, `ve_f2f22f4cec` have NULL `norm_key`). Pair
  such names by venue id (a `use` decision); never by name.
- Green Stars: Michelin list pages have no Green Star filter. Take them from the full-list or ceremony article. Rows are made only
  for venues that hold a star or Bib (as Great Britain 2026, Taiwan 2026).
- A count heading can be wrong (Taiwan 2025 Green Star "6" for 7 names). Check a mismatch against the ceremony article.
- CDX in the browser: `cdx/search/cdx?url=guide.michelin.com/<locale>/article/michelin-guide-ceremony/*&output=json&from=&to=&collapse=urlkey`
  lists every article capture for a locale. The zh_TW CDX call returned 503 once (archive temporarily offline).

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **2026 Green Star gap: Germany and the Netherlands have 0 Green Star rows for 2026** (their ingests found no Green Star mark on
   list pages). Source: each guide's 2026 Green Star or full-list article. Check other guides too.
3. 2025 Green Star + URL backfill, next guides with 2025 rows: Vietnam (70 rows, 68 no URL, 3 GS 2026), China (49), US (690,
   several guides). Same D8 method.
4. 2025 history for guides with almost none (Spain 6, Japan 11, UK 9, France 20, Italy 4): Ben decides if wanted (full D8 job).
5. Legacy price rows: 2,380 legacy_guide rows remain (read the population by country before a plan).
6. `name_native` backfill: China 469, Japan 585, Chengdu 47. Site display of `name_native`: Ben decides.
7. Blurb rewrites: 141 `needs_rewrite`. Option B runbook + humanizer layer.
8. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` (HK & Macau 2027, March 2027); Sol (Hong Kong) Young Chef Award,
   no venue; Man Yuen, Sun Yuen Hing Kee, What To Eat; Paris 1930 de Hideki Takayama (Taipei, no venue).
9. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); Beverly Hills watch; date gates (Switzerland after Nov 2; Italy
   2027 after Nov 12; Fujian late Nov; Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau
   2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-tw-2025-backfill-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 213,
audit_log 121,990, venues 11,299, awards 23,560, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then show me the open items in /ste style (smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
