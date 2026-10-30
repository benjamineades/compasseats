# Handoff: Block A step 2, batch 3 done (Italy, 586 rows updated). Oct 30, 2026. Next: batch 4 (Japan).

This file replaces `handoff-price-card-p2-b2-done-2026-10-30.md` for live state and next steps. That file and
`handoff-price-card-p2-b1-done-2026-10-30.md` still hold batches 1 and 2 and the method notes.
`handoff-price-card-p2-brief-2026-10-30.md` holds the P2 definition, the batch list and the method.
`handoff-price-card-p1-done-2026-10-30.md` holds the card-read method. The working rules in
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update (Ben "go" on the batch 3 diff, which showed 4 one-step drops, Oct 30 03:03 ET).

## Live state (read Oct 30, 07:1x UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **2,094**, legacy_guide **5,488**) |
| source_capture_ledger (max id) | **143** |
| audit_log (max id) | **115,494** |
| P2 remaining | 3,493 - 586 = **2,907** (includes 7 held France rows and 10 held Italy rows) |

## Done in this session
1. Start check: price 7,582, ledger 142, audit 114,908. All matched. Repo attached with push access, clone at `c86d878`.
   Builder taken from repo `docs/build_price_update_sql.py`, sha256 `add2da65…a491e178` (unchanged).
2. P2 by country (read 06:2x UTC): Italy 596, Japan 568, Spain 478, Germany 433, UK 337, China 318, Belgium 231,
   Netherlands 174, US 146, Taiwan 139, Ireland 42, Luxembourg 15, Monaco 8, France 7 (held), Andorra 1. Total 3,493.
   Country key: `cities.country_iso` through `venues.city_id`.
3. Batch 3 list: Italy P2, all 596 rows (`ve_0297400ed5` to `ve_ffe997e479`). ids md5 `9557b62d…db748`. List sha256
   (`venue_id|card URL`, newline) `061342d6…de80cee`, checked in the browser. Old rows (596): michelin 475, none 121;
   legacy tiers 1 = 79, 2 = 172, 3 = 113, 4 = 232.
4. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.33 s per card, 06:22:53 to 06:36:07 UTC): 596
   read, 586 clean, held 10. 0 missing symbols, 0 Selected-only cards. All clean cards: country `it`, symbol €.
   Distinction: 1 star 298, 2 stars 30, 3 stars 14, Bib 244.
   Held, card moved to a new city path (status 200, real redirect):
   - La Locanda del Borgo, Telese `ve_448903808c` → `campania/telese-terme_1850913/restaurant/la-locanda-del-borgo`
   - Kresios, Telese `ve_f558535881` → `campania/telese-terme_1850913/restaurant/kresios`
   - Paca Ristorante, Prato `ve_542c195114` → `toscana/carmignano_1833819/restaurant/paca`
   - Coxinendi - Ristorante, Sanluri `ve_eef796a74d` → `sardegna/quartu-sant-elena_1840763/restaurant/coxinendi`
   - Torre del Saracino, Vico Equense `ve_69e1e106b5` → `campania/sorrento/restaurant/torre-del-saracino`
   Held, card 404: Impronte, Bergamo `ve_6c4d801f2f`; Andrea Ristorante - Enoteca, Palazzolo Acreide `ve_6d2d60d7ba`;
   Unforgettable, Turin `ve_a006de1bf7`; Nole Ristorante, Pescara `ve_ca6e409319`; Ristorante Santa Elisabetta,
   Florence `ve_e1339c5391`.
5. Relay: 586 lines, sha256 `1a3813a8…1111def3`, copied out in 3 parts (200/200/186), each part hash-checked, joined
   and hash-checked.
6. Diff (586 rows, computed in the database from the relay pairs, pair md5 `2e9d7e44…ee5`): 566 same tier;
   20 one-step changes (16 up, 4 down); 0 changes of more than one step. Old-row md5 `aef8a1d2…d278f8`.
   1→2: Antica Trattoria La Toppa, Me Cumpari Turiddu, Osteria Ristorante La Baita, Osteria Zanchetti, Ristorante La
   Civetta, Ristorante La Cucoma, Ristorante Trattoria da Burde. 2→3: Ristorante Abba. 3→4: Angelo Sabatelli,
   Dissapore, Locanda del Pilone, Oseleta, Relais Blu, 21.9 Flavio Costa, Materia Cernobbio, Ristorante Sarri.
   4→3: Casamatta (Manduria), Johannesstube (Nova Levante), Le Colline Ciociare (Acuto), Ristorante Vespasia (Norcia).
7. Dry run through the Read connector: all guards passed, stopped at the first UPDATE. Counts unchanged after.
8. Write (Ben "go", Oct 30 03:03 ET), Write connector, one transaction, all guards and post-checks passed:
   - 586 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency EUR, tier = symbol count, confidence NULL, captured_at = read time.
     Card tiers: 1 = 72, 2 = 175, 3 = 109, 4 = 230.
   - Ledger **143** (07:09:20 UTC): michelin, price, 586, job `price-card:price-michelin-card-p2-b3-2026-10-30 | …`.
   - Audit **114,909–115,494** (586, all price UPDATE).
   - Read-back samples: Osteria Francescana €€€€ EUR 4; Antica Trattoria La Toppa €€ EUR 2; Ristorante Vespasia €€€
     EUR 3; Angelo Sabatelli €€€€ EUR 4; `ve_04c2784726` (Forentum card) € EUR 1. Held rows unchanged (legacy `$`
     symbols, no currency, no URL).
   - Italy active legacy rows with no URL after the write: 15 (10 held above; 5 outside P2).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b3-2026-10-30.sql` (77 KB) | `739e5d92a4b37a8965c89c7e83dc9f66caed513d23dc0688d27a43fe6a0ac577` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b3-relay-2026-10-30.txt` (586 lines, no final newline) | `1a3813a8b08a8f742031d8af353459f76653efbff20bf2561c90923e1111def3` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 3 (Italy, 596 venues)" 7582 142 114908 <old md5>`.
- The full 596-row list went into the browser in 2 parts (`window.L1`, `window.L2`, 300 + 296 lines) as template
  literals, then hash-checked as one list. Card paths hold no backtick or `${`.
- Relay copy-out: 3 parts of 200 lines each (about 24 KB per part) work well. Write each part to a file, check its
  sha256 against the browser, then join.
- Italy card paths start with `us/en/`; France paths started with `en/`. The builder takes the path after
  `https://guide.michelin.com/` as stored, so both work.
- The dry run sends the `DO` block (without BEGIN/COMMIT) up to and including the UPDATE through the Read connector.

## Open items
- New: 5 Italy cards moved to a new city path (list in item 4). Check each venue city and the award source_url, same
  as La Torre One Fire. Note: Telese → Telese Terme (2 venues), Prato → Carmignano (Paca), Sanluri → Quartu Sant'Elena
  (Coxinendi), Vico Equense → Sorrento (Torre del Saracino).
- New: 5 Italy cards 404 (list in item 4). Status check with the other held cards.
- New: venue `ve_04c2784726` has the name "Lavello" (the city name); its card is Forentum. Name check needed.
- Carried: 5 France cards 404 from batch 2 (Le Bel'Art `ve_89439f5f35`, Fleur de Sel `ve_a8feaf520c`, Bonnie
  `ve_bf3dfbaca2`, Maison Patte Noire `ve_c4d70b9a92`, La Petite Chartreuse `ve_dde2eb588c`); 2 France cards 404 from
  batch 1 (La Chebaudière `ve_4a55e63127`, Hyacinthe & Robert `ve_6d59eb76a1`); Les Fresques name cleanup
  `ve_e574aeb7fd`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest
  151 venues (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly
  closed; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy
  special-award rows; 5 new awards on closed venues.
- Italy timing: batch 3 read all Italy P2 cards on Oct 30, before the Italy 2027 edition (Nov 12). The cards showed
  2026 data. No Italy price batch straddles Nov 12.

## Next: batch 4 (Japan, 568)
- Selection: Japan P2 (`cities.country_iso = 'JP'`) by `ORDER BY venue_id COLLATE "C"`, all 568 rows in one batch.
- Card symbol ¥, currency JPY (builder maps `jp` → JPY). Check the Japan card locale path and the Price line on one
  card before the loop.
- The Japan 2027 editions (Tokyo, Kyoto-Osaka, Nara) come after Feb 16, 2027, so there is no timing risk now.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b3-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 143 and audit_log 115,494. Then start batch 4 of
block A step 2 (Japan, 568 venues): read the cards, build the file, examine it read-only, and show me the diff.
No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
