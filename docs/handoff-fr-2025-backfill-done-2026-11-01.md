# Handoff: France 2025 backfill done (item 4, guide 2 of 5). Nov 1, 2026 (19:20 Atlanta). Next: Spain 2025 (P2).

This file replaces `handoff-gbi-2025-backfill-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`. Working rules and database
notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md` (Methods section).

## Ben's input (ET, Nov 1)
- 15:50 "N1, P2, Q1, R1, S1" (see the GB&I handoff).
- 19:02 "W1, x1, U3": W1 = use the 16 near-name pairs (V3); X1 = use Hemicycle (name-only), skip Villa La Coste;
  U3 = France 2025 stars only, Green Stars wait (no full list found).
- 19:13 "go" (committed).

## Live state (read Nov 2, 00:16:06 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | **24,364** (last id **31,303**); Michelin **10,660**; Michelin 2025 **4,284** (no URL **3,224**); Green Star 2025 **31** |
| FR/MC Michelin 2025 | **600** (593 with the archive URL, 7 Bib rows unchanged) |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 |
| source_capture_ledger | **163** rows, last id **215** |
| audit_log | **117,301** rows, last id **122,813** |
| cities / venues_count | 3,260 / sum 10,934 |

## Done in this session
1. Start check 23:47:51 UTC: all counts = the GB&I handoff. Repo attached with push access (clone `a537f11`).
2. Archive read (built-in browser; Claude in Chrome disconnected after the first reads): stars capture 20250331212340,
   title names 2025, 654 lines (31 / 81 / 542) = the article's "654 restaurants". Ceremony Metz, Mar 31, 2025.
   Relay `docs/fr-2025-build/relay-fr-2025-archive-20250331.txt` (sha256 `2c643dc5...7cd4c1a`); card-link map
   `links-fr-2025-archive-20250331.txt` (sha256 `fa612061...0b1b18`).
3. Green Star article `les-etoiles-vertes-du-guide-michelin-2025` = 10 new only. CDX fr/fr: no full 2025 list. U3.
4. Match: card link 543; V1 (2025 row) 13; V2 (same name, 2026 row) 20; V3 (near name, same 2026 card) 16; X1 1;
   Q1 skipped 61 (no venue 55, rejected 5, Villa La Coste 1). 22 card pairs with no slug word in the venue name: checked.
5. **Run** committed (Write connector, first try): awards 30724-31303 (580 INSERT), 13 URL fills (ids 1648, 1824, 1826,
   4402, 4748, 5885, 6463, 7220, 7233, 7241, 7250, 7270, 8926). Ledger **215**. Audit **122,221-122,813**. File
   `docs/backfill-michelin-2025-france.sql` (sha256 `93e5a388...a96e715`). Run record
   `docs/fr-2025-build/run-backfill-fr-2025-2026-11-02.txt`.

## Methods and notes (new)
- **France article layout:** no `li`. Lines are `City (dept) : <a>Name</a> [- Nouveau]` split by `<br>` inside
  `.detail-page__content` blocks: block 21 Three Stars (h2), block 24 Two Stars (h2), blocks 28-41 One Star by region (h3).
  Walk text nodes, split at BR / P / H2, skip H2 text.
- A line can hold a second, empty card link (stray `<a>` with no text). Keep the link that has the name.
- Card links in the 2025 article can be stale (Episodes -> `oka`, Etude -> `sauvage-1207141`, Pierre Grein ->
  `le-bistronomique`). They give no card match; the name step pairs them. Check card pairs by a slug word in the venue name.
- **Browser to workspace:** the Write tool turns `\uXXXX` into real letters. Re-escape with a script, then compare the hash.
  For larger files, gzip + base64 in the browser (`CompressionStream`), decode in the shell, compare the hash.
- **Short plan query:** rebuild the plan in SQL from the comma slug list (`unnest(string_to_array(...)) with ordinality`),
  the use list and the skip list; compare its md5 with the build-script plan md5.
- The Read connector dry run can use the same plan text with a short ledger text and no post-checks.
- Stop hook: before a "go", keep unrun files out of the repo (holding folder in the scratchpad), move them back after the run.

## Item 4 progress (2025 history, N1, order P2)
| Guide | State | Source |
|---|---|---|
| Great Britain & Ireland | **Done** (230 rows) | GB&I handoff |
| France (with Monaco) | **Done, stars** (593 rows). Green Stars wait (U3). | see above |
| Spain | Next. Source not found yet | gb/en has `michelin-guide-spain-2025-award-winners` (new awards only). Search es/es and es/en again (CDX gave 0 or 503). |
| Japan | Source not found yet | Each Japan guide has its own edition date (Tokyo 2026 was Sep 2025). jp/en has "new selection" articles only. |
| Italy | Source not found yet | gb/en has `the-michelin-guide-italy-2025-70th-anniversary-new-three-star`. it/it CDX gave 0 or 503. |

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **France 2025 Green Stars (U3):** no full list. Try fr/en and the `restaurants/etoile-verte-michelin` search page in CDX
   (503 on Nov 1), or a 2025 regional Green Star article set.
3. `ve_4e77c0295c` L'Auberge de Saint-Remy (Fanny Rey & Jonathan Wahid): database city "Saint-Remy"; Michelin
   Saint-Remy-de-Provence. City check.
4. Venues named after a hotel (France card pairs): Hotel La Bouitte (Rene et Maxime Meilleur), Hotel Pashmina (Les
   Explorateurs), Hotel Belles Rives (La Passagere), Chateau de Valmer (La Palmeraie), Chateau Saint-Jean (La Chapelle),
   Le Relais Bernard Loiseau (La Cote d'Or), "Restaurant Girardin - 1 etoile Michelin", "La Flibuste - Restaurant
   Gastronomique Villeneuve-Loubet", "La Table de l'Alpaga - Restaurant Gastronomique a Megeve", "Sarkara**". Rename check
   under the Sep 14 name ruling.
5. 2026 Green Star gap: Germany and the Netherlands 0 rows for 2026; France 11, Italy 2, Ireland 0 (read Nov 1).
6. **Item 4 continued:** Spain next, then Japan, Italy. One guide per session (S1).
7. 2025 Green Star + URL backfill, guides with 2025 rows: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
8. Le Manoir venue `ve_7b865a33b7`: hotel suffix in the name, city Oxford (Michelin: Great Milton).
9. Legacy price rows: 2,380 legacy_guide rows remain.
10. `name_native` backfill: China 469, Japan 585, Chengdu 47. Site display: Ben decides.
11. Blurb rewrites: 141 `needs_rewrite`.
12. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` (March 2027); Sol (Hong Kong) Young Chef Award, no venue;
   Man Yuen, Sun Yuen Hing Kee, What To Eat; Paris 1930 de Hideki Takayama (Taipei, no venue).
13. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash
   slugs with digit names; Beverly Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov;
   Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-fr-2025-backfill-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 215,
audit_log 122,813, venues 11,299, awards 24,364, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then continue item 4 with Spain 2025 (stars and Green Stars, card-link match): find a full 2025 list in the archive first,
examine read-only and show me in /ste style. No write before my go. Attach the compasseats repo with push access for the
commit after any write.
```
