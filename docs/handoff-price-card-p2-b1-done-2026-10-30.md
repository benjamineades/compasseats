# Handoff: Block A step 2, batch 1 done (France part 1, 473 rows updated). Oct 30, 2026. Next: batch 2 (France part 2).

This file replaces `handoff-price-card-p2-brief-2026-10-30.md` for live state and next steps. That brief still holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (Oct 30, 2026, start of step 2)
1. Batch order: the brief order (France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US).
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).

## Live state (read Oct 30, 05:2x UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **1,041**, legacy_guide **6,541**) |
| source_capture_ledger (max id) | **141** |
| audit_log (max id) | **114,441** |
| P2 remaining | 4,433 - 473 = **3,960** (includes the 2 held France rows) |

## Done in this session
1. Start check: price 7,582, ledger 140, audit 113,968. All matched the brief. P2 = 4,433 (France 947) matched.
2. Batch 1 list: the first 475 France P2 venues by venue_id COLLATE "C" (`ve_0046e8758c` to `ve_7dbb9707de`).
   List sha256 (`venue_id|card URL`, newline) `a675fe40…c42c18fc`, checked in the browser.
3. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.35 s per card): 475 read, 473 clean,
   held 2 (card 404): La Chebaudière, Auray `ve_4a55e63127`; Hyacinthe & Robert, Pontivy `ve_6d59eb76a1`.
   0 redirects, 0 missing symbols, 0 Selected-only cards. Distinction: 1 star 232, 2 stars 33, 3 stars 17, Bib 191.
4. Diff (473 rows): 464 same tier; 9 one-step changes; 0 changes of more than one step.
   1→2: La Virée Bistrot (Lyon). 2→3: La Table de Nernier, La Robe, Épopée. 3→4: Le Cerf, Moulin de Cambelong,
   Restaurant Frankenbourg, Ébullition. 4→3: Hôtel restaurant du Vieux Pont (Belcastel).
   Legacy publisher: michelin 395, none 78.
5. Dry run through the Read connector: all guards passed, stopped at the first UPDATE.
6. Write (Ben "go", Oct 30 01:22 ET), Write connector, one transaction, all guards and post-checks passed:
   - 473 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency EUR, tier = symbol count, confidence NULL, captured_at = read time.
   - Ledger **141**: michelin, price, 473, job `price-card:price-michelin-card-p2-b1-2026-10-30 | …`.
   - Audit **113,969–114,441** (473, all price UPDATE).
   - Read-back samples: Arpège €€€€ EUR 4; La Virée Bistrot €€ EUR 2; Vieux Pont €€€ EUR 3. Held rows unchanged
     (legacy `$$`, no currency, no URL).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b1-2026-10-30.sql` (66 KB) | `e06068d1bbcc1fdd67f09fd748925d5029f0a36c26ad007d6325d79ba3dd4a82` | project `claude/` |
| `price-michelin-card-p2-b1-relay-2026-10-30.txt` (473 lines, no final newline) | `0461133228d5637042b2358354a654bed31c7d4a4a4357ddb5cbc8e60f7103a2` | project `claude/` |
| `build_price_update_sql.py` (UPDATE builder) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/` |
| this handoff | (see repo commit) | project `claude/` |

**Repo.** The 4 files above are in the repo `docs/` (commit after `30b60d9`, Oct 30). The step 1 files were already
in `docs/` before this session (sha256 checked: `31f8e287…` and `7f22474a…`).
Push access: GH_TOKEN in the session is invalid. Push works after `add_repo` (access "push"), and the permission check
allows that only when Ben asks for it in chat. Ben asked on Oct 30, 01:40 ET. In a new session, ask Ben to request it again.

## Method notes from this session
- Builder: `python3 build_price_update_sql.py RELAY OUT_SQL FILE_KEY "batch N (label)" PRICE_BEFORE LEDGER_MAX AUDIT_MAX OLD_ROWS_MD5`.
  OLD_ROWS_MD5 = md5 of `venue_id|tier|symbol_raw|coalesce(publisher,'')` lines of the relay venues (newline,
  ORDER BY venue_id COLLATE "C"), read from the database before the build. The builder asserts relay format.
- Cross-check of the legacy list: md5 of `id|tier|'$'*tier|publisher` from the pasted list equals the database md5.
- Relay out of the browser in 2 parts (237 + 236 lines, about 29 KB each); each part hash-checked; joined hash checked.
- Batch selection SQL: France P2 rows `ORDER BY venue_id COLLATE "C" LIMIT 475`. Batch 2 = `OFFSET 475` (472 rows,
  first id `ve_7e6c2c408f`). Re-read: the held 2 stay in P2, so after batch 1 the France P2 order shifts. Select batch 2
  by `venue_id >= 've_7e6c2c408f'` instead of OFFSET.
- `project_write` with `local_path` needs a file inside the working directory (not the scratchpad).
- A row with a NULL field drops out of a `string_agg` of concatenated fields. Use coalesce in read-back samples.

## Open items
- New: 2 France cards 404 (La Chebaudière `ve_4a55e63127`, Hyacinthe & Robert `ve_6d59eb76a1`). Status check, with Terra.
- Carried from step 1: Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved
  (city and award source_url check); P1 rest 151 venues (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Florida 2026 Green Stars article not found;
  La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b1-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 141 and audit_log 114,441. Then start batch 2 of
block A step 2 (France part 2, venue_id >= ve_7e6c2c408f): read the cards, build the file, examine it read-only, and
show me the diff. No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
