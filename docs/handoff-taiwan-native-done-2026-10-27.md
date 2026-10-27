# Handoff: CompassEats, Oct 27, 2026 (12:40 Atlanta). Taiwan `name_native` done: 185 venues (audit 112,467-112,651). Next: American South capture brief (promote only).

This file replaces `claude/handoff-taiwan-drops-done-2026-10-27.md` for live state, decisions, open items, methods and dead ends. That file still applies for the 5 true-drop card checks, rename batch 26 (ledger 132, audit 112,458-112,460) and its slug file (audit 112,461-112,466). The other files still apply as before:
- `claude/handoff-taiwan-contamination-done-2026-10-13.md`: contamination cleanup (ledger 130, audit 112,279-112,454), the UDN 2025 Bib list method, the SQL Editor fallback.
- `claude/handoff-taiwan-renamed-2026-10-11.md`: JL STUDIO status (audit 112,008), rename batch 24 (ledger 129), slug file (audit 112,159-112,278).
- `claude/handoff-taiwan-promoted-2026-10-11.md`: Taiwan stage and promote (batch 17, ledger 126-127), New Taipei City, the 36 legacy rows with no 2026 card.
- `claude/handoff-taiwan-brief-2026-10-11.md`: the Taiwan facts, city ids, URLs.
- `claude/handoff-netherlands-renamed-2026-10-11.md`: working rules, the vote and tie rules, the chef-suffix-before-vote method, the "by" rule.
- `claude/handoff-netherlands-promoted-2026-10-11.md`: the capture-check, simulation, pairing, stage and promote record (model for a promote-only guide).
- `claude/handoff-briefs-texas-belgium-2026-10-09.md` and `claude/cowork-michelin-2026-texas.md`: the Cowork capture brief method and a US guide brief (model for American South).
- `claude/handoff-texas-done-2026-10-10.md`: the rename-CSV method, the collision check.
- `claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md`: database notes, the gated venue-delete method.
- Plan v1.30 (`docs/CompassEats-Rearchitecture-Plan.html`, sha256 `748defe9...672216`, checked Oct 27).

Working rules (unchanged): plain `/ste` replies; populations on every count; one "go" per write batch; read-back after each commit; under-merge over over-merge; no competitor sources; no hand-retyped files; build, examine read-only, present, then ask; the tie rule (vote first; in a tie or doubt the venue's own spelling, Michelin fallback); nothing below a Michelin Bib is tracked; only closure evidence gives `closed`; Ben starting a stage, promote or real rename job is his "go".

## Live state
Population: whole table. Read Oct 27, 16:39 UTC (12:39 Atlanta), after the last commit.

| Table | Count |
|---|---|
| venues | 11,291 (active 10,924, closed 367) |
| awards | 22,841 |
| Michelin 2025 / 2026 / 2027 rows | 3,520 / 5,527 / 47 |
| listings / slugs | 11,291 / 12,816 (canonical 11,291, non-canonical 1,525) |
| venues with more or less than 1 canonical slug | 0 |
| cities / city_aliases / city_label_source | 3,259 / 259 / 23,979 |
| price / blurbs / redirects | 7,024 / 142 / 9 |
| venues with `name_native` | **203** (Taiwan 185, China 17, France 1) |
| source_capture_ledger | 91 (last id 132) |
| audit_log | **107,508** (last id **112,651**) |
| ingest_batches | 1, 3-17 promoted (no id 2) |
| rename_batches | 2, 4, 6, 8, 10, 12, 15, 16, 18, 20, 22, 24, 26 applied (25 = rolled-back dry run). rename_rows 1,102. Sequence last value 26. |

## Done in this session (Oct 27, 12:29 to 12:40 Atlanta)

**Start check:** all counts, ledger 132, audit 112,466, slugs 12,816 matched the drops handoff.

**`name_native` for Taiwan (open item 1, Taiwan part).**
- Population A (182): venues of the batch-17 award rows 29,301-29,507 (2026 cards; 207 rows on 207 venues, all active), joined to `ingest_rows` batch 17 by `source_url`, whose `venue_name_zh` holds Chinese or Japanese script. Includes the 29 Chinese-only venues of rename batch 24 (the 29 = note "Chinese characters" in `fixtures/rename/michelin-2026-taiwan-names.csv`, sha256 `4117b57e...3a8218`). Read with hex check (0 mismatch), 0 non-NFC.
- Skipped (25): cards whose `venue_name_zh` is Latin only and equal to the English name (JL STUDIO, A, logy, Mizue, NOBUO, A Cut, Ad Astra, Circum-, de nuit, FRASSI, HAILI, Hābu, Impromptu by Paul Lee, INITA, L'Atelier par Yao, La Vie by Thomas Bühner, Mume, Nibbon, Restaurant 12, SENS, T+T, Wok by O'BOND, ZEA, HUGH dessert dining, Tableau by Craig Yang). `name_native` stays null.
- Population B (3): the batch-26 venues (no 2026 card). 賣塩順 (Mai Yen Shun) and 筑馨居 (Zhu Xin Ju) from the Oct 27 zh cards (note column of `fixtures/rename/michelin-2026-taiwan-drops-names.csv`, sha256 `9f4ef858...d32530d`); 白玉樓 (Pale Jade Pavilion) from the Michelin 2025 list (UDN reprint), taken from `docs/handoff-taiwan-contamination-done-2026-10-13.md` (repo sha256 `cad9e6f4...dab6786d`).
- Before the write: 0 of the 185 had a `name_native`. On 19 of the 29, the card name differs from the old listing name (for example "良佳豬腳 最新消息請關注fb ig(已恢復長時間營業）" → card 良佳豬腳); the card wins (Ben Q3 A, Oct 11). 24 card names carry a branch part " (...)"; on all 24 the English name also has it (0 mismatch). 0 same-city duplicate Chinese names.
- Notes (no question): Kaiyuan Red-cook Spanish Mackerel `ve_96325036c3` card 開元紅燒土魠魚羮 (old listing used 𩵚魠 and 羹); MUDAN TEMPURA card 牡丹 only; 阿爸の芋圓 (kana) and 首烏廚EAT (Latin) are card text.
- **Ben's decisions (Oct 27, 12:37):** Q1 A keep the card branch part in brackets (鼎泰豐 (信義路)); Q2 A Pale Jade Pavilion = 白玉樓 (Michelin 2025 list; B venue Facebook 白玉樓經典台菜, C none, not chosen); Q3 A all 185 in one write.
- File `docs/name-native-michelin-2026-taiwan.sql`: 190 lines, ASCII, LF, sha256 `dfb9ddf2ffaf280d7fc9c79d01cecd28c9559f97b31dc41ea459e9909e94a8f2`. Built by script (`build_tw_native.py`). pglast: 3 statements, body parses. Population A values are read from `ingest_rows` inside the SQL (not typed); population B values are `U&` escapes built from the two repo files. Plan md5 (`vid|name_native` by vid): A `f58794f317f7e9dfb993d70ea33e758a`, full `3f86304ce5aec824a2815045c6b89ae0`; B (`vid|live name|name_native`) `cb2c3f8a2ab88f6e92529e72c4aa4d27`; target rows md5 `c1cf12a26560ba19d6cd9238dac97a52`. Script and database gave the same md5 values.
- Gates: counts before (11,291 / 18); plan count and md5 (A, B, full); every target active, in Taiwan, empty, B live names as expected; target rows md5; counts after (11,291 / 203); exactly 185 audit rows, venues UPDATE, only `name_native` changed, pairs md5 = plan.
- Dry run (Read connector, whole `DO` block): Gates 1-5 passed, stopped at the UPDATE ("read-only transaction"). Fresh read after Ben's choices: all values unchanged.
- **Real run:** Ben "go" (12:37). Write connector, first try, **Oct 27 16:38:33 UTC**. Audit **112,467-112,651** (185 venues UPDATE, 1 timestamp, only `name_native` changed). Audit pairs md5 = live md5 = plan `3f86304c...b6c89ae0`. No ledger row (China Sep 27 `name_native` precedent, audit 104,050-104,066, made none). slugs and awards unchanged.
- The site code does not read `name_native` yet (repo grep: only fixtures); the write changes no page.
- Review list `name-native-michelin-2026-taiwan-review.csv` (185 rows, for Ben's records only, not for the repo).
- **Not in the repo yet:** Ben uploads the SQL file to `docs/`.

## Artifacts
| File | Status | sha256 |
|---|---|---|
| `docs/name-native-michelin-2026-taiwan.sql` | Run (audit 112,467-112,651), **upload pending** | `dfb9ddf2...9e94a8f2` |
| `fixtures/rename/michelin-2026-taiwan-drops-names.csv` | Run (batch 26), in the repo (`93b5125`) | `9f4ef858...d32530d` |
| `docs/slugs-rename-michelin-2026-taiwan-drops.sql` | Run (audit 112,461-112,466), in the repo (`ebbb8f1`) | `2991db54...7f28030` |

## Methods that worked (new)
- **Values from the database inside the file:** when the value already sits in `ingest_rows.raw`, the SQL reads it there (CTE joined by `source_url`) and gates its count and md5. No CJK text in the file; the file stays ASCII.
- **CJK test in ASCII SQL:** `~ U&'[\3400-\9FFF\F900-\FAFF\3040-\30FF]'`.
- **Literal CJK values:** script-built `U&'\XXXX'` escapes (`\+XXXXXX` above U+FFFF) from hash-checked repo files.
- **`name_native`-only audit gate:** `old_row->>'name_native' IS NULL AND (old_row - 'name_native') = (new_row - 'name_native')`, plus md5 of `row_pk|new_row->>'name_native'` = plan md5.
- **Target rows fingerprint:** `md5(string_agg(md5(to_jsonb(v)::text), '' ORDER BY v.id))` over the plan venues.
- The rename guard (`guard_venue_rename`) fires on `name` only; `name_native` needs no `app.allow_rename`.

## Dead ends: do not retry (new)
- None new. Note: a read-only transaction refuses `CREATE TEMP TABLE`; repeat the plan CTE in each gate instead of a temp table.

## Open items, in order
1. **Ben:** upload `docs/name-native-michelin-2026-taiwan.sql` to the repo; Claude checks the sha256.
2. **American South (after Oct 21; now due)**, promote only. No brief yet: first the Cowork capture brief (Texas model, `claude/cowork-michelin-2026-texas.md`), then capture check, simulation, stage, promote. Then Beijing & Tianjin after the end of October.
3. **Switzerland after Nov 2, 2026** (option A, promote only).
4. **`name_native` backfill:** China 469 / Japan 585 / Chengdu 47 (from the card `venue_name_zh` / native name in `ingest_rows`; Taiwan method above). China Line 128 (Lucky Zhang's) and lines 317, 355 from the China renamed handoff.
5. **Gap list after Taiwan:** promote-only Singapore; retire-path Austria, Hong Kong & Macao, South Korea, Portugal, Mexico; Thailand after its 2027 edition; Canada as three guides.
6. Hold registers: Texas, Belgium & Luxembourg, Netherlands, Taiwan (9 Green Stars; four special awards) → special-awards batch.
7. Price from the Michelin card (Taiwan `$` cards: $ 86, $$ 64, $$$ 20, $$$$ 37; Oct 27 cards: Mai Yen Shun $$, Zhu Xin Ju $$, Cheng Tsung $). Ben chooses the method.
8. JL STUDIO blurb (`needs_rewrite`): rewrite through the Option B runbook when blurbs come up.
9. **Site display of `name_native`** (new, no date): the site does not show it yet. Ben decides if and where (venue page subtitle, search). Lovable prompt when the time comes.
10. Rechecks, no date: Pale Jade Pavilion `ve_96994a1e21` and Dong Shang Taiwanese Seafood `ve_7eb5839370` (Michelin card 404 Oct 27, no closure evidence); Kommilfoo, La Paix, Lucia (Dallas), Dill, Kilberry Inn, Endo at the Rotunda, Hare & Hounds, Zhu Ji Zhi Mian Pu, Gasthaus Jakob, Ente, die burg, Gault&Millau Germany.
11. Carried from the promoted handoff item 11 (France slugs, later-ceremony guides, carried rename CSVs, Ben's decisions list incl. `cities.venues_count` recount, repo `.env` keys, Plan v1.31 (add the Taiwan sessions, incl. the Oct 13 cleanup, the Oct 27 drops session and this session), options B and C, project cleanup part 2).

## Suggested opening prompt for the next chat
```
Read these handoffs from the project files with the Projects tool: claude/handoff-taiwan-native-done-2026-10-27.md first, then claude/handoff-briefs-texas-belgium-2026-10-09.md for the Cowork brief method, then claude/cowork-michelin-2026-texas.md as the model US brief, then claude/handoff-netherlands-promoted-2026-10-11.md for the capture-check, simulation, stage and promote record. Confirm live counts, ledger id 132, audit_log id 112,651 and slugs 12,816 with a Read query. Check that docs/name-native-michelin-2026-taiwan.sql is in the repo with sha256 dfb9ddf2...9e94a8f2. Then start open item 2, the American South 2026 guide: confirm the release date and the states and cities it covers from Michelin, read the legacy American South rows in the database (population by state and city), and write the Cowork capture brief. Ask me the questions the rules do not decide. No write before my go.
```
