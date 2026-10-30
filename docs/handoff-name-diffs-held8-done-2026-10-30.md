# Handoff: Held 8 name-diff venues renamed (batch 30) and slugs done. Oct 30, 2026 (19:40 Atlanta). Next: Ben chooses.

This file replaces `handoff-name-diffs-renamed-2026-10-30.md` for live state and next steps. That file still holds the
batch 29 record and its methods. The rules R1-R5, the group summary and the carried open items are in
`handoff-name-diffs-read-2026-10-30.md`. Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.
The name-diff work (94 venues: rename 72 + 8, keep 14) is now complete.

## Ben's input (Oct 30, 2026)
- 19:23 ET "Option 1": read the 4 sites not read before (Maison Patte Noire, Andrea, UZU Kyoto, Kitchen).
- 19:25 ET "All recommended": the 8 names below.
- 19:36 ET "Go": rename file. 19:39 ET "Go": slug file.

## Live state (read Oct 30, 23:39:57 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,304 (active 10,937) |
| awards | 23,353 |
| price | 7,730 |
| slugs | **12,913** (canonical 11,304, non-canonical **1,609**) |
| venues with other than 1 canonical slug | 0 |
| listings | 11,304 |
| city_label_source | 24,005 |
| blurbs | 142 |
| rename_batches | 16 (last id **30**); rename_rows **1,194** |
| source_capture_ledger | 120 rows, last id **164** |
| audit_log | 113,691 rows, last id **118,975** |

## Done in this session
1. Start check (23:21 UTC): all counts, ledger 163, audit 118,957, slugs 12,909 matched. Repo attached with push access
   (clone `e68947e`).
2. Site reads (WebFetch, Ben approved each, ~23:24-23:33 UTC): 4 live cards for the website link, the 4 sites, then
   2 more cards (LULU, TURK) for the website link only. Results are in `name-diff-held8-decisions-2026-10-30.txt`.
3. Fresh read of the 8 (md5 of live `id|name` by id `23a6e30878bab101db515a732999fbd1` = evidence column 3). All active,
   0 blurbs, 0 earlier rename_rows, 1 Michelin 2026 URL each. Pulled from the transcript by `grab.py` (marker = md5).
4. Build by script (`docs/build_name_diffs_held8_rename.py build`, then `slug FP 5 3`). Guards: each michelin name =
   last part of its card URL (lower case, accents off, spaces to `-`); each venue name = live name in other capitals.
5. Read-only check: 0 same-city norm_key collisions, 0 NULL norm_key, norm_key same on 3 (LULU, Turk, Kitchen).
   Slug plan 5 rows, 3 keep, fingerprint `60124224907e2d1c6f478df4bb5afbb5`, 0 empty / duplicate / in redirects,
   **1 in use = reuse** (see Slug notes).
6. pglast: both files 3 statements, PL/pgSQL parses. Rename dry run (Read connector) stopped at the first INSERT; no id used.
7. Repo commit `c7aaad4` (built, not run): 5 files; fresh clone sha256 correct.
8. **Rename write** (Write connector, first try, 23:37:42 UTC): batch **30** `rename-name-diffs-held8-2026-10-30` applied;
   8 rename_rows; ledger **164** (michelin, name, 5, job `rename-apply:rename-name-diffs-held8-2026-10-30 | ...`);
   audit **118,958-118,965** (8 venues UPDATE, 1 timestamp). Live `id|name` md5 = file new `98ba087e1e82ec0e0cfce27c5adec6fb`.
9. Slug dry run after the rename (Read connector) stopped at the first UPDATE; all gates passed.
10. **Slug write** (Write connector, first try, 23:39:35 UTC): slugs 12,909 -> 12,913; non-canonical 1,605 -> 1,609;
    audit **118,966-118,975** (6 slugs UPDATE, 4 slugs INSERT, 1 timestamp). No ledger row.

## The 8 renames
| venue_id | Old | New | Source | Canonical slug now |
|---|---|---|---|---|
| ve_c4d70b9a92 | Maison Patte Noire "1 lieu, 2 restaurants" | La P’tite Patte (U+2019) | michelin | cholet/la-p-tite-patte (reused) |
| ve_f3378b4564 | LULU FUSION BISTRO | LULU fusion bistro | venue | osijek/lulu-fusion-bistro (kept) |
| ve_9852cbf26e | TURK FATIH TUTAK | Turk Fatih Tutak | venue | istanbul/turk-fatih-tutak (kept) |
| ve_f1b7fc23a0 | KITCHEN by Osman Sezener | Kitchen by Osman Sezener | venue | bodrum/kitchen-by-osman-sezener (kept) |
| ve_b4ab5979c5 | Arka Ristorente Pizzeria Bodrum | Arka Ristorante Pizzeria | michelin | bodrum/arka-ristorante-pizzeria |
| ve_f21ee3afab | Bánh Bèo, Bánh Đập, Bánh Ướt | Bánh Bèo - Bánh đập | michelin | da-nang/banh-beo-banh-dap |
| ve_6d2d60d7ba | Andrea Ristorante - Enoteca | Andrea | michelin | palazzolo-acreide/andrea |
| ve_bb69a63e96 | Vegan Ramen UZU Kyoto | UZU Kyoto | michelin | kyoto/uzu-kyoto |

## Slug notes
- **Reuse:** `cholet/la-p-tite-patte` was already a non-canonical slug of ve_c4d70b9a92. It came from the Sep 16 merge of
  ve_17d83ed8dd (La P'tite Patte) into this venue (audit 97523). The slug file made it canonical again and inserted no
  row for it (reuse md5 `45e00aab022ead3f70e785f8640109f8`). The merged venue no longer exists; 0 redirects.
- Old canonical slugs of the 5 plan venues are now non-canonical and point to the same venues. Andrea also keeps an older
  non-canonical slug `andrea-sapori-montani` (from before this session).
- Bánh Bèo: the old slug `banh-beo-banh-ap-banh-uot` lost the capital Đ (f_unaccent); the new slug from lower-case đ is
  `banh-beo-banh-dap`.

## Methods that worked (new)
- **Slug reuse:** when a new slug is already a non-canonical row of the same venue, gate on its md5, UPDATE it to
  canonical after the old canonical goes non-canonical, and INSERT only `WHERE NOT EXISTS`. Any use by another venue or
  as a canonical slug still stops the block. Audit total stays 2 x plan rows.
- **Read-only check query built by the script** (VALUES of id|new_name) with a marker `CHECK30-<md5 of id|new_name>`:
  the marker in the result proves the pasted names equal the file.
- **grab.py fix:** keep only tool results that start with `{"result"`, and match `<untrusted-data-…>\n[ … ]\n</untrusted-data-`
  (the preamble names the tag once before the data).
- **Write tool and \u escapes:** the Write tool stores real characters, not `\u` escapes. Read names as written and
  assert NFC.

## Files
| File | Status | sha256 |
|---|---|---|
| `docs/rename-name-diffs-held8-2026-10-30.sql` (190 lines) | Run (batch 30) | `a16776f7a4f7fe0409df69a32de55d3b0de83a5be712bee03a0ea104892ced9a` |
| `docs/slugs-rename-name-diffs-held8-2026-10-30.sql` (180 lines) | Run (audit 118,966-118,975) | `0fc0715577f94817ff5aef5fee4d1e369beb354d0389708dce916668d93e9a48` |
| `fixtures/rename/name-diffs-held8-2026-10-30.csv` (8 rows) | Input | `59b0f8e3b25d3000899eb81b9aa324a34b6c3cc3778fd974271466fb04f9e36b` |
| `docs/name-diff-held8-decisions-2026-10-30.txt` | Decisions + site reads | `6b499cf2f0572f833e236b36c12a9febfd56e4318ff06a6b297870e0b75be813` |
| `docs/build_name_diffs_held8_rename.py` | Build script | `89e41cc650e5fad3f8257f755fcdf2511ebf64f81915f44fce2643f9d93a1a93` |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items
1. Apostrophe policy: now also La P’tite Patte (U+2019, card and site agree). Straight U+0027: Kemal'in Yeri, Harry's,
   Lugya'h, Emeril's. Curly U+2019: Domilise's, La P’tite Patte.
2. KITCHEN by Osman Sezener: the card address is Yalıkavak, Bodrum; our city is Bodrum (no change needed unless Ben wants
   Yalıkavak labels; see the Turkey card-city item).
3. All other open items carried unchanged from `handoff-name-diffs-read-2026-10-30.md` (Open items section): city
   labels (Waiheke Island, Wānaka, Đakovo), Les Fresques and Lavello name cleanup, Paloma Taqueria recheck, edition
   watches, and the rest.

## Suggested opening prompt
```
Read claude/handoff-name-diffs-held8-done-2026-10-30.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for the carried open items and claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count
read and confirm ledger 164, audit_log 118,975 and slugs 12,913. Then show me the next-block options in /ste style (the
carried open items, smallest first, with what each needs from me) and wait for my choice. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
