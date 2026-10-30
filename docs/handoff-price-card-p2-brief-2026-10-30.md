# Handoff: Block A step 2 brief. Michelin card price for P2 (legacy price rows, card URL known). Oct 30, 2026.

This file replaces `handoff-price-card-p1-done-2026-10-30.md` for live state and next steps. Read that file for the
card-read method and the step 1 results. The working rules, database notes, methods and dead ends in
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule (Claude commits files to the repo
itself) still apply.

## Why this block is first (recommendation, Ben agreed to start here)
- Same proven method as step 1: open the card URL that our award row already holds. No name search, so no match risk.
- Largest gain: 4,433 active venues get a real card symbol, an ISO currency and a source URL.
- The Sep 28, 2026 ruling decides it: the Michelin card price wins over a legacy price with no URL, for every guide.
- P1 rest (151 active venues with no price row and no card URL) needs a name search first. It comes after this block.

## Live state (read Oct 30, 04:53 UTC, whole tables)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest 568, legacy_guide 7,014) |
| source_capture_ledger (max id) | 96 (**140**) |
| audit_log (max id) | 108,684 (**113,968**) |
| awards / venues | 23,352 / 11,307 |
| Repo `main` | commit `f816473` (step 1 files and handoff in `docs/`) |

## Population P2 (read Oct 30, 04:53 UTC)
Definition: active venue; a Michelin One Star, Two Stars, Three Stars or Bib Gourmand award row whose `source_url`
matches `^https://guide\.michelin\.com/.*/restaurant/` (take the latest by year desc, id desc); a `price` row with
source `legacy_guide` and `source_url` null. Grouping key: `venue_id`. Total **4,433** (publisher michelin 3,558,
no publisher 875). The 4 legacy rows of other publishers (la-liste, gault-millau, oad, wine-spectator) are not in P2.

| Country | Venues | Country | Venues |
|---|---|---|---|
| France | 947 | Belgium | 231 |
| Italy | 596 | Netherlands | 174 |
| Japan | 568 | United States | 146 |
| Spain | 478 | Taiwan | 139 |
| Germany | 433 | Ireland | 42 |
| United Kingdom | 337 | Luxembourg | 15 |
| China | 318 | Monaco | 8 |
| | | Andorra | 1 |

Legacy symbols are "$"-normalized (`$` to `$$$$`) with no currency, so the diff to show Ben is tier only
(legacy tier vs card tier), plus the count of rows where only the symbol, currency and URL change.

## Suggested batches (one SQL file and one "go" per batch, about 600 rows or less)
The step 1 file was 558 rows (75 KB). Keep each batch near that size, because the relay passes through the chat
three times (browser out, dry run, write).
1. France part 1 (about 475, split by venue_id order) 2. France part 2 (about 472)
3. Italy (596) 4. Japan (568) 5. Spain (478) 6. Germany (433)
7. United Kingdom + Ireland (379) 8. China + Taiwan (457)
9. Belgium + Netherlands + Luxembourg + Monaco + Andorra (429) 10. United States (146)
Ben can change the order. One or two batches per chat session, then a handoff.

## Method (from step 1, change in the write only)
1. Fresh read of the counts. Read the batch list from the database (venue_id, card URL, legacy tier, symbol_raw,
   publisher), with an md5 of the ids and a sha256 of `venue_id|card URL` lines.
2. Built-in browser, one tab on guide.michelin.com. Load the list with the hash check. Run the `fetch()` loop
   (1.2 s pause). Parse: Price line regex, `dLayer['price']`, `dLayer['distinction']`, `dLayer['restaurant_country']`.
   Poll with waits of 40 s or less (tool timeout 45 s).
3. Hold out: status not 200, a real redirect (compare `decodeURI`), no symbol. Held rows keep the legacy price.
4. Relay: `venue_id|card path|symbol|CAT_P0n|distinction|country|captured_at`, sorted, sha256 in the browser, copied
   out in parts of about 280 lines, each part hash-checked, joined and hash-checked.
5. SQL builder (`build_price_sql.py` pattern, relay text inside the file as `$r$…$r$`), changed for UPDATE:
   - Guard each row: venue active; price row exists with source `legacy_guide`, `source_url` null; card URL = latest
     Michelin star/Bib card URL of the venue.
   - Guard the old rows: md5 of `venue_id|tier|symbol_raw|coalesce(publisher,'')` by venue_id, read before the build.
   - `UPDATE price SET tier, symbol_raw, currency, source='guide_ingest', method='published_symbol',
     publisher='michelin', source_url, captured_at, confidence=NULL` for the relay rows only.
   - Ledger row: michelin, price, n, job `price-card:<file key> | block A step 2 batch N … | updated from legacy`.
   - Post-checks: price count unchanged; audit rows = n, all `price` UPDATE with row_pk in the relay; each row now
     matches the relay.
6. Present to Ben before "go": rows to update, held rows, tier diff table (legacy tier → card tier counts), and the
   rows where the card tier is more than one step from the legacy tier (named list). Then the dry run through the Read
   connector (stops at the first UPDATE), then "go", then the Write connector, read-back, repo commit with sha256
   check by fresh clone.

## Questions for Ben at the start of step 2
1. Batch order: as above, or another order?
2. When the card tier equals the legacy tier: update anyway (adds real symbol, currency, URL)? Recommendation: yes.
3. A card that shows Selected only (no star, no Bib): update the price anyway? Recommendation: yes, the price is still
   Michelin's, and the award history does not change (Oct 10 ruling on drops to Selected).

## Open items carried from step 1
- Terra (Fisterra) `ve_89ca903ac2`: card 404. Status check.
- La Torre One Fire `ve_b5a5b44c26`: card moved from `piemonte/annunziata` to `campania/santa-maria-annunziata`
  (card id 139632). Check the venue city and the award source_url.
- P1 rest: 151 active venues with no price row and no card URL (name search needed).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Florida 2026 Green Stars article not found;
  La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-brief-2026-10-30.md from the project files, then
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
price 7,582, ledger 140 and audit_log 113,968. Then answer the three questions in the brief with me in /ste style,
and start batch 1 of block A step 2: read the cards, build the file, examine it read-only, and show me the diff.
No write before my go.
```
