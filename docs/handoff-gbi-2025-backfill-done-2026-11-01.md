# Handoff: GB&I 2025 backfill done (item 4, guide 1 of 5). Nov 1, 2026 (17:05 Atlanta). Next: France 2025 (P2).

This file replaces `handoff-tw-2025-backfill-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`. Working rules and database
notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.

## Ben's input (ET, Nov 1)
- 15:41 "lets do 4. Use 2025 history." (2025 history for Spain, Japan, UK, France, Italy.)
- 15:50 "N1, P2, Q1, R1, S1": N1 = stars and Green Star only, no Bib (no full 2025 Bib list exists); P2 = order GB&I, France,
  then Spain, Japan, Italy; Q1 = skip lines with no venue; R1 = source_url is the archive id_ URL of the list, existing 2025
  rows get the URL too; S1 = one guide per session, handoff at the end of each.
- 17:02 asked for a recommendation on T (6 name-only pairs). 17:03 "T1, go" (committed).

## Live state (read Nov 1, 22:04:50 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | **23,784** (last id **30,723**); Michelin **10,080**; Michelin 2025 **3,704** (no URL **3,237**); Green Star 2025 **31** |
| GB/IE/JE Michelin 2025 | **233** (230 with the archive URLs, 3 Bib rows unchanged) |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 |
| source_capture_ledger | **162** rows, last id **214** |
| audit_log | **116,708** rows, last id **122,220** |
| cities / venues_count | 3,260 / sum 10,934 |

## Done in this session
1. Start check 20:39:15 UTC: all counts = the Taiwan handoff. Repo attached with push access (clone `d7122f2`).
2. Scope read for item 4 (Michelin rows by country and year) and archive CDX read of ceremony articles. Full 2025 star and
   Green Star lists found for GB&I and France. Not found yet (archive 503s): Spain, Japan, Italy. No full 2025 Bib list for any.
3. GB&I archive read (built-in browser): stars capture 20250211084823 (10/29/181), Green Stars capture 20250211223426 (36).
   All = the Feb 10, 2025 ceremony "at a Glance". Relay 256 lines `docs/gbi-2025-build/relay-gbi-2025-archive-20250211.txt`
   (sha256 `003ae95e...7536e0`); card-link map `links-gbi-2025-archive-20250211.txt` (sha256 `60d35e7d...80bdc1`).
4. Match: card link 212; venue id 12 (Michelin row under the name); T1 name-only 6 (Le Manoir x2 `ve_7b865a33b7`, Hjem
   `ve_c905b58267`, Lyle's `ve_d8accd5787`, Taku `ve_4789a4e337`, Silo `ve_85eaf781c4`); Q1 skipped 26 (9 stars, 17 GS).
5. **Run** committed (Write connector, first try): awards 30500-30723 (224 INSERT), 6 URL fills (ids 4216, 4403, 4778, 5696,
   6036, 6090). Ledger **214**. Audit **121,991-122,220**. File `docs/backfill-michelin-2025-great-britain-ireland.sql`
   (sha256 `85677755...cd25`). Build commit `e64b42b`. Run record `docs/gbi-2025-build/run-backfill-gbi-2025-2026-11-01.txt`.

## Methods and notes (new)
- **Card-link match (use this first for all big guides):** the archived list article links each restaurant to its Michelin card
  (`/restaurant/<slug>`). The 2026 award rows hold card URLs. Match = card slug of the line = card slug of an existing Michelin
  award row of exactly 1 venue in the guide's countries. Name matching alone found only about half (the database uses card
  or venue spellings, for example "The Fat Duck", "Ynyshir Restaurant & Rooms").
- Then name pairs: a venue with a Michelin row (2025 or 2026) under the name = venue-id pair. A venue with no Michelin row =
  name-only pair, Ben decides.
- Extract links in the browser with `DOMParser` on the `id_` HTML: walk `h2` and `li` in `.detail-page__content`; take the first
  `a[href*="/restaurant/"]` of each `li`. Ignore footer `li` items (they have no restaurant link).
- A list line can have no city (Mauro Colagreco at Raffles London at The OWO). Keep the field empty; the card link pairs it.
- A name can hold the relay delimiter (`SO|LA`): escape `|` as `|`. The shell heredoc turns `|` into `|` too; re-escape.
- Two archive URLs in one job: star rows get the star-list URL, Green Star rows the Green Star-list URL (`src` S or G).
- The CDX server gives 503 often. Run CDX calls one at a time, store each result on `window`, retry after 5-6 s.
- GB&I 2026 ceremony: Feb 9, 2026; 2025 ceremony: Feb 10, 2025 (Glasgow).

## Item 4 progress (2025 history, N1, order P2)
| Guide | State | Source |
|---|---|---|
| Great Britain & Ireland | **Done** (230 rows) | see above |
| France (with Monaco) | Next | `guide-michelin-france-2025-la-liste-complete-des-etoiles` (capture 20250331212340) and `les-etoiles-vertes-du-guide-michelin-2025` (20250416160946), fr/fr ceremony path. 2025 rows now: 20 (7 Bib, 10 One Star, 3 Two Stars). Check the 2025 ceremony date (Metz, March 2025) and that the capture names 2025. |
| Spain | Source not found yet | gb/en has `michelin-guide-spain-2025-award-winners` (new awards only). Search es/es and es/en again (CDX gave 0 or 503). |
| Japan | Source not found yet | Each Japan guide has its own edition date (Tokyo 2026 was Sep 2025). jp/en has "new selection" articles only. |
| Italy | Source not found yet | gb/en has `the-michelin-guide-italy-2025-70th-anniversary-new-three-star`. it/it CDX gave 0 or 503. |

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. 2026 Green Star gap: Germany and the Netherlands have 0 Green Star rows for 2026. Low counts also: France 11, Italy 2,
   Ireland 0 (read Nov 1). Source: each guide's 2026 Green Star or full-list article.
3. **Item 4 continued:** France next, then Spain, Japan, Italy (table above). One guide per session (S1).
4. 2025 Green Star + URL backfill, guides with 2025 rows: Vietnam (70 rows, 68 no URL), China (49), US (690). Same D8 method.
5. Le Manoir venue `ve_7b865a33b7`: name has the hotel suffix ("..., A Belmond Hotel, Oxfordshire"), city Oxford (Michelin:
   Great Milton). Rename and city check under the Sep 14 name ruling.
6. Legacy price rows: 2,380 legacy_guide rows remain.
7. `name_native` backfill: China 469, Japan 585, Chengdu 47. Site display: Ben decides.
8. Blurb rewrites: 141 `needs_rewrite`.
9. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` (March 2027); Sol (Hong Kong) Young Chef Award, no venue; Man
   Yuen, Sun Yuen Hing Kee, What To Eat; Paris 1930 de Hideki Takayama (Taipei, no venue).
10. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash
   slugs with digit names; Beverly Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov;
   Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-gbi-2025-backfill-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 214,
audit_log 122,220, venues 11,299, awards 23,784, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then continue item 4 with France 2025 (stars and Green Stars, card-link match), examine read-only and show me in /ste style.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
