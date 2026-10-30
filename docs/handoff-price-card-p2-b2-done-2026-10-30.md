# Handoff: Block A step 2, batch 2 done (France part 2, 467 rows updated). Oct 30, 2026. Next: batch 3 (Italy).

This file replaces `handoff-price-card-p2-b1-done-2026-10-30.md` for live state and next steps. That file still holds
batch 1 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the P2 definition, the batch list and
the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method. The working rules in
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).

## Live state (read Oct 30, 06:1x UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **1,508**, legacy_guide **6,074**) |
| source_capture_ledger (max id) | **142** |
| audit_log (max id) | **114,908** |
| P2 remaining | 3,960 - 467 = **3,493** (includes the 7 held France rows) |

## Done in this session
1. Start check: price 7,582, ledger 141, audit 114,441. All matched. P2 3,960; France P2 474 (2 held from batch 1
   plus 472 in batch 2). Repo attached with push access (Ben asked in the opening prompt), clone at `cfdbde2`.
2. Batch 2 list: France P2 with `venue_id COLLATE "C" >= 've_7e6c2c408f'`, 472 rows (`ve_7e6c2c408f` to `ve_feac5d24f0`).
   List sha256 (`venue_id|card URL`, newline) `6ab3ffd5…d264e`, checked in the browser. Old rows (472): michelin 410,
   none 62; legacy tiers 1 = 11, 2 = 196, 3 = 83, 4 = 182.
3. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.33 s per card, 10.5 min): 472 read, 467 clean,
   held 5 (card 404): Le Bel'Art, Champcevinel `ve_89439f5f35`; Fleur de Sel, Saint Georges sur Cher `ve_a8feaf520c`;
   Bonnie, Cahors `ve_bf3dfbaca2`; Maison Patte Noire, Cholet `ve_c4d70b9a92` (card path `la-p'tite-patte`, with an
   apostrophe); La Petite Chartreuse, La Tronche `ve_dde2eb588c`.
   0 redirects, 0 missing symbols, 0 Selected-only cards. Distinction: 1 star 227, 2 stars 25, 3 stars 13, Bib 202.
4. Diff (467 rows, computed in the database from the relay pairs, pair md5 `10bfcf34…7d53f40`): 452 same tier;
   15 one-step changes, all up; 0 down; 0 changes of more than one step.
   1→2: Auberge La Gaillotière (Château-Thébaud), Le Kitchen (Lyon). 2→3: ANTO (Annecy). 3→4: Auberge de la Forge,
   Ezia, Ithurria, JU – Maison de Cuisine, L'Impulsif, Le Mas Bottero, Le Moulin de l'Abbaye, Le Petit Léon,
   Le Vivier, Les Trois Rochers, Restaurant Hervé Busset, Les Fresques. Legacy publisher: michelin 405, none 62.
5. Dry run through the Read connector: all guards passed, stopped at the first UPDATE. Counts unchanged after.
6. Write (Ben "go", Oct 30 02:09 ET), Write connector, one transaction, all guards and post-checks passed:
   - 467 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency EUR, tier = symbol count, confidence NULL, captured_at = read time.
     Card tiers: 1 = 7, 2 = 194, 3 = 72, 4 = 194.
   - Ledger **142**: michelin, price, 467, job `price-card:price-michelin-card-p2-b2-2026-10-30 | …`.
   - Audit **114,442–114,908** (467, all price UPDATE).
   - Read-back samples: Maison Lameloise €€€€ EUR 4; Auberge La Gaillotière €€ EUR 2; La Chaumière de Pomper € EUR 1;
     Les Fresques €€€€ EUR 4. Held rows unchanged (legacy `$`/`$$`, no currency, no URL).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b2-2026-10-30.sql` (65 KB) | `fb7a56efd73d97832d26c4a7326e38fadfb3ba863351177a2be2cbefea170cb5` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b2-relay-2026-10-30.txt` (467 lines, no final newline) | `4589cdd8e2d22b4b253e790c4817ea2646cfaf4c13fbbde115379c870d823122` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder taken from the repo copy (`docs/build_price_update_sql.py`, sha256 checked), not retyped.
- The old-row md5 must cover only the relay venues (467), not the full batch list (472). Read it after the card read.
- Tier diff: send `id:card_tier` pairs (built by Python from the relay, md5 checked) to the Read connector and let the
  database compare with the live legacy rows. Faster and safer than a pasted legacy list.
- Read-back: `coalesce(p.source,'')` fails, because `price.source` is an enum (`price_source_t`). Use `p.source::text`.
- Batch 3 selection: Italy P2 by `ORDER BY venue_id COLLATE "C"`, all 596 rows in one batch (the brief size). If the
  relay is too large for one pass, split Italy in two by venue_id, as with France.

## Open items
- New: 5 France cards 404 (list in item 3 above). Status check with the other held cards.
- New: venue name of Les Fresques (Monestier) `ve_e574aeb7fd` holds extra text ("… une étoile Michelin depuis plus de
  10 ans"). Name cleanup needed; check other venue names for the same pattern.
- Carried: 2 France cards 404 from batch 1 (La Chebaudière `ve_4a55e63127`, Hyacinthe & Robert `ve_6d59eb76a1`);
  Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest 151 venues
  (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Florida 2026 Green Stars article not found;
  La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.
- Note for Italy: the Italy 2027 edition comes out Nov 12. Batch 3 reads today's cards; a card read after Nov 12 may
  show 2027 data. Ben may prefer to run Italy before Nov 12 or move it after Japan.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b2-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 142 and audit_log 114,908. Then start batch 3 of
block A step 2 (Italy, 596 venues): read the cards, build the file, examine it read-only, and show me the diff.
No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
