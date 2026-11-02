# Handoff: Spain 2025 backfill done (item 4, guide 3 of 5). Nov 1, 2026 (19:45 Atlanta). Next: Japan 2025 (P2).

This file replaces `handoff-fr-2025-backfill-done-2026-11-01.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`. Working rules and database
notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md` (Methods section). France methods: the France handoff.

## Ben's input (ET, Nov 1)
- 15:50 "N1, P2, Q1, R1, S1" (see the GB&I handoff).
- 19:35 "Y3, Z1, G1": Y3 = check the 3 moved/renamed pairs against the venue's own site first; Z1 = use the 3 name-only
  pairs (closed venues); G1 = Spain 2025 stars only, Green Stars wait (no full list found).
- 19:40 "y-use, go": use the 3 Y pairs; run (committed).

## Live state (read Nov 2, 00:42:36 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,299 (active 10,934) |
| awards | **24,643** (last id **31,582**); Michelin **10,939**; Michelin 2025 **4,563** (no URL **3,221**); Green Star 2025 **31** |
| ES/AD Michelin 2025 | **285** (282 with the archive URL, 3 Bib rows unchanged) |
| slugs | 13,002 |
| listings / blurbs | 11,299 / 142 |
| price | 7,733 |
| source_capture_ledger | **164** rows, last id **216** |
| audit_log | **117,583** rows, last id **123,095** |
| cities / venues_count | 3,260 / sum 10,934 |

## Done in this session
1. Start check 00:19:34 UTC: all counts = the France handoff. Repo attached with push access (clone `dac0210`).
2. Archive read (built-in browser): stars article `todas-las-estrellas-de-la-guia-michelin-espana-2025`, capture
   20241130022008 (first capture after the Nov 26, 2024 ceremony in Murcia), title names 2025. 292 lines (16 / 33 / 243;
   One Star 242 Spain + 1 Andorra) = the article headers; NEW 1 / 3 / 32 = the headers. Relay
   `docs/es-2025-build/relay-es-2025-archive-20241130.txt` (sha256 `27850f82...55faf67`); card-link map
   `links-es-2025-archive-20241130.txt` (sha256 `99ce36e4...d8c574b6`).
3. Green Stars: article `las-estrellas-verdes-2025-9-novedades` = 9 new only. Selection page
   `es/es/selection/spain/restaurantes/sustainable_gastronomy` says 57; only page 1 archived (Aug 13, 2025: 52 cards;
   May 31, 2025: 24). Page 2 never archived. es/en, es/ca, global: no captures. gb/en: 503. G1.
4. Match: card link 273; V1 (2025 row) 3 (6331 Ricardo Sanz Wellington, 6335 Santerra, 7867 Simpar); Y 3; Z1 3;
   Q1 skipped 10 (no venue): El Poblet, Oria, Etxeko Ibiza, La Finca (Loja), Erre de Roca, NM, Es Tragon, Bens d'Avall,
   Baluarte, Cancook.
   - Y (moved/renamed, evidence from the Michelin card or press; the venues' own sites do not mention the move):
     37 Ramon Freixa Madrid -> `ve_b705060cf6` Ramon Freixa Atelier (Velazquez 24; Time Out Sep 13, 2024);
     150 Ancestral (Illescas) -> `ve_c87595d42b` Pozuelo de Alarcon (Michelin card says relocated from Illescas);
     158 Haydee (La Orotava) -> `ve_4ecd793ec3` Adeje (Vinetur Nov 28, 2025). Haydee's own site blocks automated reading.
   - Z1: 76 Aurt `ve_27266639a6`, 93 Teatro kitchen & bar `ve_6532e88951`, 132 Tohqa `ve_b1c292cecb` (database city Cadiz).
5. **Run** committed (Write connector, first try): awards 31304-31582 (279 INSERT), 3 URL fills (6331, 6335, 7867).
   Ledger **216**. Audit **122,814-123,095**. File `docs/backfill-michelin-2025-spain.sql` (sha256 `f19b35ab...0b823a`).
   Run record `docs/es-2025-build/run-backfill-es-2025-2026-11-02.txt`.

## Methods and notes (new)
- **Spanish article path is `/articulo/`, not `/article/`.** Earlier CDX searches used `article` and missed it. Check the
  local word for "article" per locale (Italy `articolo`?, Japan `article`?) before saying a list is missing.
- Spain article layout: `li` items under h2 (Tres / Dos / Una Estrella) and h3 (ANDORRA / ESPANA) in
  `.detail-page__content`. Line text `City – Name [- NOVEDAD]`; card links use `/restaurante/`. Take the name from the
  link text, the city from the text before ` – Name` (some cities and names hold an en dash: "Lasarte – Oria",
  "Alquimia – Laboratorio"). NOVEDAD can follow a hyphen or an en dash.
- **Card slug pattern:** in Postgres, use `substring(url from '/(?:restaurant|restaurante)/([^/?#]+)')`. The pattern
  `'/restaurantes?/([^/]+)/?$'` returned NULL for every row (0 matches). Spain card URLs in the database are `us/en/.../restaurant/<slug>`.
- Spain 2026 Green Star rows hold the article URL, not a card URL; the star rows hold card URLs.
- A slug can hold a URL-encoded character (`mu%e2%80%a2na`); the database URL holds the same encoding, so it matches.
- Long CDX loops: run them as a background promise that stores results on `window`, then poll (a single call times out at 45 s).

## Item 4 progress (2025 history, N1, order P2)
| Guide | State | Source |
|---|---|---|
| Great Britain & Ireland | **Done** (230 rows) | GB&I handoff |
| France (with Monaco) | **Done, stars** (593 rows). Green Stars wait (U3). | France handoff |
| Spain (with Andorra) | **Done, stars** (282 rows). Green Stars wait (G1). | see above |
| Japan | Next. Source not found yet | Each Japan guide has its own edition date (Tokyo 2026 was Sep 2025). jp/en has "new selection" articles only. Try the jp/ja article path. |
| Italy | Source not found yet | gb/en has `the-michelin-guide-italy-2025-70th-anniversary-new-three-star`. Try it/it with `articolo`. |

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Spain 2025 Green Stars (G1):** no full list (57 on the selection page; page 1 of 2 archived). Try again later or a
   2025 regional Green Star article set.
3. **France 2025 Green Stars (U3):** no full list. Try fr/en and the `restaurants/etoile-verte-michelin` search page in CDX.
4. Spain venue names that are a city name: BACK -> venue "Marbella" `ve_f29878f198`; Europa -> venue "Pamplona"
   `ve_c18fc53635`. Rename check under the Sep 14 / Oct 10 name rulings.
5. Spain card-paired venues with status closed but a 2026 One Star: SLOW&LOW `ve_18248f03f5`, Terra `ve_89ca903ac2`.
   Status check.
6. Moved restaurants (Y pairs): the 2025 row shows under the new city/name (Ancestral Pozuelo, Haydee Adeje, Ramon Freixa
   Atelier). No action unless Ben wants a "previous location" note.
7. `ve_4e77c0295c` L'Auberge de Saint-Remy (Fanny Rey & Jonathan Wahid): database city "Saint-Remy"; Michelin
   Saint-Remy-de-Provence. City check.
8. Venues named after a hotel (France card pairs): see the France handoff item 4. Rename check under the Sep 14 ruling.
9. 2026 Green Star gap: Germany and the Netherlands 0 rows for 2026; France 11, Italy 2, Ireland 0 (read Nov 1).
10. **Item 4 continued:** Japan next, then Italy. One guide per session (S1).
11. 2025 Green Star + URL backfill, guides with 2025 rows: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
12. Le Manoir venue `ve_7b865a33b7`: hotel suffix in the name, city Oxford (Michelin: Great Milton).
13. Legacy price rows: 2,380 legacy_guide rows remain.
14. `name_native` backfill: China 469, Japan 585, Chengdu 47. Site display: Ben decides.
15. Blurb rewrites: 141 `needs_rewrite`.
16. Rechecks: Chiu Chow Delicacies (North Point) `ve_d7e57d1d84` (March 2027); Sol (Hong Kong) Young Chef Award, no venue;
    Man Yuen, Sun Yuen Hing Kee, What To Eat; Paris 1930 de Hideki Takayama (Taipei, no venue).
17. Carried from b10: Le Calandre city (Padua vs Rubano); Palaash city; Best Chef entries with no venue (Credo, Scilla); hash
    slugs with digit names; Beverly Hills watch; date gates (Switzerland after Nov 2; Italy 2027 after Nov 12; Fujian late Nov;
    Spain Dec 1; Northeast Cities after Dec 14; Tokyo etc. after Feb 16, 2027; HK & Macau 2027 March 2027); Telluride.

## Suggested opening prompt
```
Read claude/handoff-es-2025-backfill-done-2026-11-01.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 216,
audit_log 123,095, venues 11,299, awards 24,643, slugs 13,002, price 7,733 and cities.venues_count sum 10,934.
Then continue item 4 with Japan 2025 (stars and Green Stars, card-link match): find a full 2025 list in the archive first
(check the local article path word per locale), examine read-only and show me in /ste style. No write before my go.
Attach the compasseats repo with push access for the commit after any write.
```
