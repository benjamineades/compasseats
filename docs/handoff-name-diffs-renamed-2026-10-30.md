# Handoff: Name differences renamed (batch 29, 72 venues) and slugs done. Oct 30, 2026 (19:10 Atlanta). Next: Ben chooses; the 8 held venues are the open name batch.

This file replaces `handoff-name-diffs-read-2026-10-30.md` for live state and next steps. That file still holds the card and
site read, the rules R1-R5, the group summary and the carried open items. The per-venue evidence is
`name-diff-evidence-2026-10-30.txt` (94 data lines). Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
Slug method: `handoff-germany-renamed-sets23-2026-10-09.md` and `handoff-american-south-done-2026-10-27.md`.

## Ben's input (Oct 30, 2026)
- 18:35 ET: decisions 1 = A (rules R1-R5), 2 = A (rename the 9 dagger venues on site + card agreement), 3 = hold 8 for later.
- 19:03 ET "Go": rename file. 19:08 ET "Go": slug file.

## Live state (read Oct 30, 23:09 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,304 (active 10,937) |
| awards | 23,353 |
| price | 7,730 |
| slugs | **12,909** (canonical 11,304, non-canonical **1,605**) |
| venues with other than 1 canonical slug | 0 |
| listings | 11,304 |
| city_label_source | 24,005 |
| blurbs | 142 |
| rename_batches | 15 (last id **29**); rename_rows **1,186** |
| source_capture_ledger | 119 rows, last id **163** |
| audit_log | 113,673 rows, last id **118,957** |

## Done in this session
1. Start check (22:36 UTC): all counts, ledger 162, audit 118,753 matched. Repo attached with push access (clone `fc6eeed`).
2. Fresh read of the 72 rename venues: md5 of live `id|name` (by id) `5ed99ac0a1b92ddf3c7f3887681597ca` = evidence column 3
   (the dagger is a marker in the file, not in the name). 72 active, 0 blurbs, 0 earlier rename_rows, each has 1 Michelin 2026 URL.
3. Source per row: 66 rows = card name (or card minus branch suffix) -> `michelin`, card URL. 6 rows follow the venue site
   (card differs) -> `venue`, site URL = the card website link read by WebFetch of the live card (~22:45 UTC): Union Pasadena
   (unionpasadena.com), Harry's Piccolo Poreč (harryspiccoloporec.com), Narımor Urla (narimorurla.com/fine-dining),
   Adil Müftüoğlu Uğur Lokantası (adilmuftuoglu.com.tr), Tavacı Recep Usta x2 (tavacirecepusta.com.tr).
4. Files built by script (`docs/build_name_diffs_rename.py` = build.py + mksql.py + mkslug.py). CSV parsed by the job's
   `loadRenameCsv`: 72 rows, 72 venues, 1 key, 0 blank URL, michelin 66, venue 6.
5. Check query (read-only): 0 same-city norm_key collisions on the end state, 0 NULL norm_key, norm_key same on 7.
   Slug plan from the new names: 72 venues, 66 plan rows, 6 keep (Seline, Boda, Bar Citra, Soichi, Gostilna Francl,
   Teruar Urla), fingerprint `3b871e7ea11cc1349e060b33b2672bb1`, 0 empty / duplicate / in use / in redirects.
6. pglast: both files 3 statements, PL/pgSQL parses. Rename dry run (Read connector) stopped at the first INSERT; no id used.
7. **Rename write** (Ben "go"; Write connector, first try, 23:06:58 UTC): rename batch **29** `rename-name-diffs-2026-10-30`
   applied; 72 rename_rows (verdict rename, detail = note, live_name, city_id, city_slug, slug); ledger **163** (michelin,
   name, 66, job `rename-apply:rename-name-diffs-2026-10-30 | gated SQL file ...`); audit **118,754-118,825** (72 venues
   UPDATE, 1 timestamp, 0 changes beyond name/norm_key). Live `id|name` md5 = file new `fe583e5abaa016d3df6e544ec5d680df`.
   Run as a gated SQL file with the same writes as `scripts/rename/apply.ts` (rename_batches staged -> applied,
   `app.allow_rename` on only for the UPDATE), not the GitHub job.
8. Slug dry run after the rename (Read connector) stopped at the first UPDATE; all gates passed.
9. **Slug write** (Ben "go"; Write connector, first try, 23:09 UTC): slugs 12,843 -> 12,909; non-canonical 1,539 -> 1,605;
   audit **118,826-118,891** (66 slugs UPDATE) and **118,892-118,957** (66 slugs INSERT), 1 timestamp. Read-back fingerprint
   of `id|name|city|old slug (now non-canonical)|new canonical slug` = plan `3b871e7e...`. No ledger row.
10. Repo commit `f2ba0e9` (after the rename): the 2 SQL files, the CSV, the build script; fresh clone sha256 correct.

## Name notes
- Kemal'in Yeri: live had U+2019; new name has U+0027 (card, rule R5). Harry's Piccolo Poreč: U+0027 (site, R1; card U+2019).
  Lugya'h: U+0027 (card). Part of the open apostrophe policy.
- 3 names got longer by the card: Restaurant Frank, Tantalus Estate Restaurant, Moondog Cafe & Bakery.
- Two venues are now named "Tavacı Recep Usta" (İzmir `ve_420e6f5990`, İstanbul `ve_9b55bcbafd`); different cities, no clash.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/rename-name-diffs-2026-10-30.sql` (255 lines) | Run (batch 29) | `8789d29759de22e2c78e19ac0ba48d90f9bcc524f0d06eb30206978a311fa344` |
| `docs/slugs-rename-name-diffs-2026-10-30.sql` (159 lines) | Run (audit 118,826-118,957) | `d2cab414e468ff97b4a6076de532807c4bfa5eec2162f0dbb4e9555d3fb4d79e` |
| `fixtures/rename/name-diffs-2026-10-30.csv` (72 rows) | Input, in the repo | `3e2dbd41c905ba18afa5744f6d2e83e74eb32d51d40451bb88a80f0dcd0a6a21` |
| `docs/build_name_diffs_rename.py` | Build scripts | `cad12a1f6be2b3076e95b8d3163a1b39b569923efed5984424972a04185d9110` |
| this handoff | project `claude/`, repo `docs/` | - |

## Methods that worked (new)
- **Rename as a gated SQL file:** VALUES of all CSV columns into a jsonb plan; 4 md5 input guards (id|expected, id|new,
  line|id|expected|new|source|url, id|note) catch any copy error when the block is pasted into the connector; live gates; the
  job's collision rule (`scripts/rename/lib/impact.ts`) inline; writes in the job's order with `set_config('app.allow_rename',
  'on', true)` around the UPDATE only; post-checks = the job's invariants plus audit rows changing only name/norm_key.
- **Tool result to file:** the session transcript `/root/.claude/projects/-home-claude/<session>.jsonl` holds each tool result;
  `grab.py` pulls a Read-connector result by a marker string (an md5 in the result) into JSON for the build script.
- **Card website link by WebFetch** of the live Michelin card (prompt: h1 and the website href) worked for all 6 cards.
- **Slug file gate by batch key** (not id): the slug file was built and fingerprinted before the rename, from the proposed names.

## Open items
1. **Held 8 venues (name batch 2):** Maison Patte Noire `ve_c4d70b9a92`; Bánh Bèo, Bánh Đập, Bánh Ướt `ve_f21ee3afab`; Andrea
   Ristorante - Enoteca `ve_6d2d60d7ba`; Vegan Ramen UZU Kyoto `ve_bb69a63e96`; LULU FUSION BISTRO `ve_f3378b4564`; Arka
   Ristorente Pizzeria Bodrum `ve_b4ab5979c5`; TURK FATIH TUTAK `ve_9852cbf26e`; KITCHEN by Osman Sezener `ve_f1b7fc23a0`.
   Reasons in the evidence file. Ben decides each name.
2. Apostrophe policy (Kemal'in Yeri, Harry's, Lugya'h now U+0027; Domilise's U+2019; Emeril's U+0027).
3. All other open items carried unchanged from `handoff-name-diffs-read-2026-10-30.md` (Open items section).

## Suggested opening prompt
```
Read claude/handoff-name-diffs-renamed-2026-10-30.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for the carried open items and claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count
read and confirm ledger 163, audit_log 118,957 and slugs 12,909. Then show me the next-block options in /ste style (the 8 held
venues from the name-diff evidence file first, with what each needs from me) and wait for my choice. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
