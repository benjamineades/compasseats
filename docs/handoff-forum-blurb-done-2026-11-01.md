# Handoff: Open item 1 done (Forum blurb v2); apostrophe item closed. Nov 1, 2026 (14:42 Atlanta). Next: Ben chooses.

This file replaces `handoff-hkmo-2025-backfill-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
Special-award rules (Q1-QH): `handoff-special-awards-sql-ready-2026-10-29.md`. Blurb method: `CompassEats-OptionB-Pipeline-Runbook.md`.

## Ben's input (ET, Nov 1)
- 13:53 open item 1: read the blurb and runbook, examine read-only, show in /ste; no write before go.
- 14:01 "A1, B1, C1, D1, E1": A1 = draft text as is; B1 = version 2, status `rewritten`, sources = 4 URLs; C1 = database only
  (Sheet and `ImportOptionB.gs` unchanged); D1 = `venues.chef` stays "Wong Lung To"; E1 = 1 ledger row (failed, see below).
- 14:10 "Go" (run 1, rolled back). 14:24 "F1" = no ledger row. 14:31 "Go" (run 2, committed).
- 14:38 continue in the same chat (apostrophe item). 14:41 "G1" = close the apostrophe item, no write.

## Live state (read Nov 1, 19:32:08 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | 23,543 (last id 30,482) |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 (**rewritten 1**, needs_rewrite 141) |
| price | 7,733 |
| source_capture_ledger | 160 rows, last id **211** (ids 210, 212 used by rolled-back runs, no rows) |
| audit_log | **116,423** rows, last id **121,935** (121,934 used by rolled-back run 1, no row) |
| cities.venues_count | sum 10,934 |

## Done in this session
1. Start check 18:53:44 UTC: all counts = the D8 handoff. Repo attached with push access (clone `1a4dff8`).
2. Read: all 142 blurbs were `needs_rewrite`, version 1, sources NULL; 135 have em dashes. Live site still reads the Sheet
   (`data/venues.json`, old name "富臨飯店 Forum Restaurant" and old text).
3. Claim check of the old Forum text against fetched sources: 7 claims confirmed, 7 not found (cut or replaced).
4. Draft `docs/forum-blurb-build/draft-forum-blurb-v2.txt` (sha256 `bf3cccf3...f7acc7`), commit `04b58c3`.
5. File `docs/rewrite-blurb-forum-v2.sql` (sha256 `e3f6c1d5...84fd5`, 50 lines) built by `build_forum_blurb_v2.py`.
6. Run 1 (19:10 UTC) rolled back: ledger `publisher` has a foreign key to `award_sources(slug)`; `compasseats` is not there.
7. **Run 2** committed 19:32:03 UTC: blurb `ve_fe4ae32eec` v2, new row md5 `523fd41f...1a526`. Audit **121,935**. No ledger row.
   Run record `docs/forum-blurb-build/run-forum-blurb-v2-2026-11-01.txt`.
8. **Apostrophe item closed (G1, no write).** Rule R6 (Oct 30, `handoff-open-items-b1-done-2026-10-30.md`) already sets the policy:
   keep the source's form per venue (site, then card). Read 19:39 UTC: Hung's Delicacies `ve_b655947dcb`, L'Atelier de Joël Robuchon
   (Hong Kong) `ve_3c0f9f5711`, Lai's Kitchen `ve_6cc88fe33b`, Prof Chan's `ve_8a5d5ef4fe`: all U+0027 live, all U+0027 in the
   site/card evidence (`docs/hkmo-2026-build/cards84-2026-11-01.tsv`, `name-diff-evidence-hkmo-2026-11-01.txt`). 4 of 4 match R6.
   Population (11,299 venues): 628 names U+0027, 56 U+2019, 0 both. Other L'Atelier venues (Dubai, Miami U+2019; Taipei, Paris,
   Tokyo U+0027) are checked only when their guide is renamed.

## Database notes (new)
- `source_capture_ledger.publisher` REFERENCES `award_sources(slug)` (23 slugs). A non-publisher job (blurb) gets no ledger row.
- `blurbs` has trigger `trg_audit_blurbs` (function `audit_row`, row_pk = venue_id). No check constraint on `status`.
- `blurbs.sources` is a jsonb array of URL strings (first use: Forum). jsonb::text uses ", " separators (matters for md5 gates).
- A dry run stops at the first write, so a foreign key on a later write is not tested. Read the constraints of every table
  the file writes (`pg_constraint` by `conrelid`) before the dry run.

## Open items, smallest first
1. Forum on the live site: the Sheet / `ImportOptionB.gs` entry `forum-restaurant` still holds the old text (C1). It changes at the
   Supabase swap, or by an `importOptionB` run if Ben chooses. `venues.chef` "Wong Lung To" vs sources "Adam Wong Lung-to" (D1 kept).
2. Blurb rewrites: 141 `needs_rewrite` (JL STUDIO, Hof van Cleve, Haerlin, Schwarzwaldstube, es:senz flagged earlier). Same method.
3. `name_native` backfill elsewhere: China 469, Japan 585, Chengdu 47. Site display of `name_native`: Ben decides.
4. Legacy price rows elsewhere: 2,380 legacy_guide rows remain (read the population by country before a plan).
5. 2025 Michelin URLs, other guides: 3,281 Michelin 2025 rows have no source_url (HK/MO done).
6. 2025 Green Star backfill, other guides (HK/MO done).
7. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` at HK & Macau 2027 (March 2027); Sol (Hong Kong) Young Chef Award,
   no venue; Man Yuen, Sun Yuen Hing Kee, What To Eat (no venue, no 2025 row).
8. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash slugs
   with digit names (Shanghai 8 1/2, 100/200 Kitchen, 80/20); Beverly Hills watch; date gates (Switzerland after Nov 2; Italy
   2027 after Nov 12; Fujian late Nov; Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau
   2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-forum-blurb-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 211,
audit_log 121,935, venues 11,299, awards 23,543, slugs 13,002, price 7,733, blurbs 142 (rewritten 1) and cities.venues_count
sum 10,934. Then show me the open items in /ste style (smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
