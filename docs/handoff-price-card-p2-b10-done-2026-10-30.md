# Handoff: Block A step 2, batch 10 done (United States, 146 rows updated). Oct 30, 2026. P2 batches complete. Next: the 27 held cards, then P1 rest (151).

This file replaces `handoff-price-card-p2-b9-done-2026-10-30.md` for live state and next steps. That file and the
b1 to b8 handoffs still hold batches 1 to 9 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US. All 10 done.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 10 diff (2 changes of one step: 0 up, 2 down;
   0 bigger), Oct 30 12:43 ET.

## Live state (read Oct 30, 16:46 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **4,974**, legacy_guide **2,608**) |
| source_capture_ledger (max id) | **150** |
| audit_log (max id) | **118,374** |
| P2 remaining | **27**: IT 10, FR 7, ES 3, CN 2, GB 2, JP 2, DE 1 (all held cards from batches 1 to 8) |

## Done in this session
1. Start check (16:32 UTC): price 7,582 (guide_ingest 4,828, legacy_guide 2,754), ledger 149, audit 118,228. All
   matched. Repo attached with push access, clone at `c89f5fa`. Builder sha256 `add2da65…a491e178` (unchanged).
   Working folder and browser: no leftovers from another chat (browser pane was not open).
2. Batch 10 list: P2 with `cities.country_iso = 'US'`, 146 rows (`ve_027dca0101` to `ve_ffaacc86dd`). ids md5
   `ab89145314745ccfc3095d581cb74582`. List sha256 (`venue_id|card URL`) `e7440d4e…341713bc`, checked in the browser.
   Old rows (146): michelin 121, none 25; legacy tiers 1 = 17, 2 = 77, 3 = 18, 4 = 34. Latest award rows: One Star 42,
   Two Stars 2, Bib 102, all Michelin 2026. All card paths `us/en/`.
   By guide region (card path): Texas 63, Colorado 19, American South 64 (georgia 18, louisiana 14, tennessee 12,
   north-carolina 8, alabama 5, south-carolina 5, mississippi 2).
3. Ceremony check (search Oct 30, guide.michelin.com):
   - Colorado 2026: Sep 14, 2026 (Colorado 2026 starred list article).
   - Texas 2026: Oct 8, 2026 (Texas 2026 starred list article).
   - American South 2026: Oct 21, 2026, The Pinnacle, Nashville (event page).
   - Events page: no event Oct 29 to Nov 5. American Great Lakes first ceremony Apr 21, 2027, Detroit.
   - No straddle in the read window. Cards show the 2026 edition our award rows hold.
4. Pre-check of 3 cards (Franklin Barbecue, Bruto, Bacchanalia): all `$`, `us`, distinction as our rows.
5. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.35 s per card, 16:35:32 to 16:38:48 UTC):
   146 read, 146 clean, **0 held**. 0 missing symbols, 0 redirects, 0 Selected-only. Country/symbol: us $ 146.
   Distinction: 1 star 42, 2 star 2, bib 102 (= our award rows exactly, 0 mismatches).
6. Relay: 146 lines, sha256 `496cb95b41a1c99bd2065541b1723f3e63a67d68f0cc06584de25e5ca2d8c104`, copied out in one
   part (16,600 bytes), hash-checked after saving. Fingerprint md5 `d247e219b2de3354c1d3284a616aa8ab`.
   Old-row md5 (146 relay venues) `1fa0af67bbce8290f1d1eb204a9e0ce8`.
7. Diff (computed in the database from the compact `id:tier:dist` string, md5 `932a83c7…a1b38`):
   144 same tier (1→1 17, 2→2 75, 3→3 18, 4→4 34); 2 one-step changes (0 up, 2 down); 0 bigger.
   - Down 2→1 (Bib): Casaema (Houston), Papalo Taqueria (Houston).
8. Syntax check (pglast 8.7) passed. Dry run through the Read connector (DO block cut at the first UPDATE, ends with
   RAISE EXCEPTION 'DRY RUN OK'): all guards passed. Counts unchanged after.
9. Write (Ben "go", Oct 30 12:43 ET), Write connector, one transaction, all guards and post-checks passed:
   - 146 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency USD 146, tier = symbol count, confidence NULL, captured_at = read time.
     Card tiers: 1 = 19, 2 = 75, 3 = 18, 4 = 34.
   - Ledger **150** (16:45:27 UTC): michelin, price, 146, job `price-card:price-michelin-card-p2-b10-2026-10-30 | …`.
   - Audit **118,229–118,374** (146, all price UPDATE).
   - Read-back samples: Bacchanalia $$$$ USD 4; The Catbird Seat $$$$ 4; Lazy Betty $$$$ 4; The Wolf's Tailor $$$$ 4;
     Emeril's $$$ 3; Scoundrel $$$ 3; Franklin Barbecue $$ 2; Dooky Chase $$ 2; Casaema $ 1; Papalo Taqueria $ 1.
     All source guide_ingest, publisher michelin.

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b10-2026-10-30.sql` (24,793 bytes) | `a19d6d5c34ac877b45c295ddad7dc0b44b918e563403e48c6f8f98ce9b2a2eab` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b10-relay-2026-10-30.txt` (146 lines, no final newline) | `496cb95b41a1c99bd2065541b1723f3e63a67d68f0cc06584de25e5ca2d8c104` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 10 (United States, 146 venues)" 7582 149 118228
  1fa0af67bbce8290f1d1eb204a9e0ce8`.
- US card path region = `split_part(substr(source_url, 28), '/', 3)` (texas, colorado, georgia …). Atlanta cards sit
  under `georgia/` and belong to the American South guide.
- A batch under ~150 rows fits in one relay part (no split needed).
- The `$`-runs in the relay sit inside `$r$…$r$` with no conflict (checked `$r$` absent).

## Block A step 2 summary (P2, all 10 batches)
P2 was 4,433 at the Oct 30 04:53 read. Updated 4,406 over ledgers 141 to 150. Held 27 (card 404 or moved path). The
held list is in "Open items" below (by batch).

## Open items
- **Next: the 27 held P2 cards.** Each needs a status check (closed, left the guide, or new card path). By batch:
  - Batch 8: 2 Beijing cards 404 (Jing `ve_262d31b59b`, Ladychai `ve_8a5b0b0df3`); check with the Beijing 2027 promote
    (Beijing & Tianjin 2027 is out, Oct 28, 2026).
  - Batch 7: 2 UK cards 404 (Café Spice Namasté `ve_5911480108`, BOX-E `ve_c5a3f2e5bd`).
  - Batch 6: 1 Germany card 404 (Sticky Fingers, Regensburg `ve_f93b620329`).
  - Batch 5: 2 Spain cards 404 (SLOW&LOW `ve_18248f03f5`, El Espejo `ve_6bdb3af7e7`); 1 Spain card moved city
    (El Jardín de la Sal `ve_e50adc624d`: Las Caletas → Fuencaliente de la Palma).
  - Batch 4: 2 Japan cards 404 (TOKi `ve_434df13957`, Vegan Ramen UZU Kyoto `ve_bb69a63e96`).
  - Batch 3: 5 Italy cards moved to a new city path (La Locanda del Borgo, Kresios, Paca, Coxinendi, Torre del
    Saracino); 5 Italy cards 404 (Impronte, Andrea Ristorante - Enoteca, Unforgettable, Nole Ristorante, Ristorante
    Santa Elisabetta); venue `ve_04c2784726` named "Lavello" (card is Forentum).
  - Batches 1 and 2: 7 France cards (5 from batch 2, 2 from batch 1).
- Then: P1 rest (151 active venues with no price row and no card URL; name search needed).
- Carried: Les Fresques name cleanup `ve_e574aeb7fd`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire
  `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov); Switzerland after Nov 2; Italy 2027 edition Nov 12
  (rule 2.1.7); Spain 2027 edition Dec 1 (Huesca); Germany 2027 edition in Frankfurt (date not found); GB&I 2027
  edition (date not found); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
  Belgium & Luxembourg 2027 (spring 2027, date not found); American Great Lakes first edition Apr 21, 2027;
  telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes) status; Florida 2026 Green Stars
  article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
  closed venues.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b10-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
price 7,582, ledger 150 and audit_log 118,374. Then start the pass over the 27 held P2 cards: for each, check the
card URL, search guide.michelin.com for a new card path, and sort them into "new card path found", "left the guide"
and "closed". Show me the list in /ste style before any build. No write before my go.
Attach the compasseats repo with push access for the commit after the write.
```
