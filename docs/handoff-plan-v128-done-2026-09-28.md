# Handoff: CompassEats, Sep 28, 2026. Plan v1.28 saved. Next: Michelin Great Britain & Ireland.

This file replaces `handoff-michelin-chengdu-2027-done-2026-09-28.md` for live state, decisions and open items. That file's other sections still apply and are not repeated here: source-reading methods, dead ends, database notes, key ids and working preferences. Attach both files to the next chat.

Working rules (unchanged):
- Plain `/ste` replies. Populations on every count.
- One "go" per write batch. Read-back after each commit.
- Under-merge over over-merge.
- No competitor sources (Pearl, TBRG, Beli). Ignore `enprimeurclub.com` and `joinpearl.co` in web search.
- No hand-retyped files.

Open item 1 of the Chengdu handoff (Plan v1.28) is closed.

## Live state
Population: whole table. Read Sep 28 at the end of this session. No database table changed in this session.

| Table | Count |
|---|---|
| venues | 11,209 (active 10,848, closed 361) |
| awards | 22,237 |
| Michelin 2025 / 2026 / 2027 rows | 4,178 / 4,265 / 47 |
| listings / slugs | 11,209 / 12,290 (canonical 11,209, non-canonical 1,081) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_label_source | 3,244 / 23,822 |
| price | 7,059 (7,049 `legacy_guide`, 10 `guide_ingest`) |
| venues with `name_native` | 18 |
| blurbs / redirects | 142 / 9 |
| source_capture_ledger | 55 (last id **70**) |
| audit_log | 102,946 (last id **105,898**) |
| ingest_batches | ids 1 and 3–10 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8 applied (France names, France dashes, China, Meet the Bund). rename_rows 533 |

**Great Britain & Ireland, Michelin rows now.** Population: Michelin award rows on venues whose city has `country_iso` GB or IE.
- GB: 349 rows, 2025, no `source_url`, on 349 venues in 141 cities.
- IE: 42 rows, 2025, no `source_url`, on 42 venues in 24 cities.
- 0 rows labelled 2026. 0 sourced rows. Total 391 (the plan's "391 / 0").

## Done in this session
- **Live check:** all handoff counts matched, including ledger id 70 and audit_log id 105,898. Ledger rows 44–70 were read one by one. The missing ids 42, 43, 46, 65, 67 and 68 are dry-run gaps.
- **Plan v1.27 recovered.** The repo and the project held v1.26. v1.27 (Sep 24) had never been saved, although every handoff since Sep 25 assumed it was. It was rebuilt from v1.26 with the exact Sep 24 edit script, which is kept in the chat "Michelin Colorado + Southwest 2026". All 5 anchors matched once.
- **Plan v1.28 built and saved** in `docs/` (commit `10d8d7f`) and in the project. Both copies have sha256 `b7ddeab77558591e00c866abaee3b0b1cbe21b4b71a04166d3d5c74050728e88`. HTML check: 0 errors. v1.28 adds:
  - A China mainland card: promote, rename, retire, cleanup and slug batches, with ledger ids 44–66.
  - A Chengdu 2027 card, which contains:
    - the promote (ledger 69–70) and Set 1 option C;
    - the updated rule 2.1.7 table (Beijing and Fujian 2027 now follow the Tokyo row: promote only);
    - 14 standing rules from Sep 25–28;
    - the new order of work, the cleanup list and the live counts.
  - A new work item: Michelin card price.
  - Phase 4 and 5 marked "Dates under review".
  - Phase 5 additions: 301s for 1,081 non-canonical slugs, the `cities.venues_count` recount, and RLS.
  - A note that Punch List v2.47 and runorder v1.5 are out of date.

## Decisions by Ben, Sep 28 (this session)
- **Base for v1.28:** rebuild v1.27 from the Sep 24 script. Ben first chose to upload his own copy, then could not find it and said `rebuild`.
- **Phase 4 and 5 dates:** "under review". The plan has no record of Phase 4 progress, and the ingest runs into October. The next plan version records new dates when Ben sets them.
- **Price:** the Michelin card price wins over a legacy price with no URL, **for every guide**. v1.28 has a price-from-card work item.
  - Population: distinct venues with at least one Michelin row with a `source_url`, which is 3,353.
  - 2,956 of them hold a legacy price, 10 hold a card price, and 387 hold no price. No venue holds more than one price row.
  - Row shape: `source` = `guide_ingest`, `method` = `published_symbol`, `publisher` = `michelin`, `currency` from the guide, `symbol_raw` as printed, `source_url` = card URL.
  - **Ben must still choose the method:** gated SQL per guide, or price writing added to the ingest job through Claude Code.
- **Punch List v2.47 and runorder v1.5:** marked out of date in v1.28. The plan sets the order of work. Their files stay in `docs/` as history.

## Dead ends: do not retry
- Trusting a handoff's plan version. **Always read the `Version` line of `docs/CompassEats-Rearchitecture-Plan.html` before building the next version.** v1.24 and v1.27 were both lost this way.
- Bash process substitution `<( )` in the sandbox fails with "Syntax error: "(" unexpected". Write to temp files instead.
- Carried: see the Chengdu handoff.

## Artifacts
- `docs/CompassEats-Rearchitecture-Plan.html` **v1.28**: final, in the repo and the project.
- `build127.py`, `build128.py`: sandbox only, not in the repo. The Sep 24 chat keeps the v1.27 script. The v1.28 file's checksum is the record.
- Earlier files as in the Chengdu handoff.

## Open items, in order (Plan v1.28, "Order of the remaining work")
1. **Michelin Great Britain & Ireland (next).**
   - First, find the 2026 ceremony date on a guide.michelin.com URL. The date decides the cleanup under amended rule 2.1.1:
     - before May 13, 2026: retire same-category twins;
     - after June 1, 2026: keep all 391 rows as 2025 history;
     - in between: the three-promotion test.
   - Check whether Michelin already shows a 2027 edition (rule 2.1.7).
   - Record the published counts (3 / 2 / 1 / Bib) for GB and for Ireland.
   - Write the Cowork brief, modeled on the Monaco and Colorado + Southwest briefs (`cowork-michelin-2026-japan.md` is in the project files as a pattern).
   - Scope: stars and Bib Gourmand only.
   - Capture `price_symbol_raw` as printed. GB and Ireland print different currency symbols: record the currency per country for the price work item.
2. Chengdu rename CSV (18 paired venues, majority rule; `ve_41a4101cbd` → "Co-"), then the slug job for them.
3. Chengdu retire and merge review: Upper House Chengdu and 8 legacy Bib venues.
4. France slug set (148 venues). Ben decides when.
5. `name_native` backfill from Michelin (China 469, Japan 585, Chengdu 47). Also: Hong Kong Xin Rong Ji duplicate check, and the Seventh Son (Tsim Sha Tsui) city check.
6. Price from the Michelin card. Ben chooses the method.
7. Guides with a later ceremony, promote only:
   - Texas after Oct 8, then American South after Oct 21.
   - Beijing & Tianjin after the end of October, then Fujian 2027 when published.
   - Northeast Cities after Dec 14.
   - Tokyo, Kyoto-Osaka, Nara 2027 after Feb 16, 2027.
8. Carried items:
   - Rename CSVs for Italy, Japan, Spain & Andorra, Monaco, Colorado + Southwest. No rename batch exists for these guides.
   - The special-awards batch (Green Star has no column).
   - The Elche/Elx merge and the Sukiyabashi Jiro split.
   - The L'Atelier OAD pairs.
9. Ben to decide before the swap:
   - new Phase 4 and 5 dates;
   - a `cities.venues_count` recount;
   - RLS on `award_categories`, `rename_batches`, `rename_rows` (do not enable RLS before access policies exist).

## Suggested opening prompt
```
Read the attached handoffs (handoff-plan-v128-done-2026-09-28.md, then handoff-michelin-chengdu-2027-done-2026-09-28.md for methods, dead ends and database notes). Confirm live counts, ledger id 70 and audit_log id 105,898 with a Read query, and read the Version line of docs/CompassEats-Rearchitecture-Plan.html (expect 1.28). Then start open item 1, Michelin Great Britain & Ireland: find the 2026 ceremony date and any 2027 edition on guide.michelin.com, record the published counts per country, tell me in /ste style which cleanup path rule 2.1.1 gives, and write the Cowork brief modeled on the Monaco and Colorado + Southwest briefs.
```
