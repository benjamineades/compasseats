# Handoff: Block A step 2, batch 9 done (Benelux + Monaco + Andorra, 429 rows updated). Oct 30, 2026. Next: batch 10 (US).

This file replaces `handoff-price-card-p2-b8-done-2026-10-30.md` for live state and next steps. That file and the
b1 to b7 handoffs still hold batches 1 to 8 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 9 diff (16 changes of one step: 16 up, 0 down;
   0 bigger), Oct 30 12:25 ET.

## Live state (read Oct 30, 16:30 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **4,828**, legacy_guide **2,754**) |
| source_capture_ledger (max id) | **149** |
| audit_log (max id) | **118,228** |
| P2 remaining | **173**: US 146, IT 10, FR 7, ES 3, GB 2, CN 2, JP 2, DE 1 (all 27 non-US rows are held cards) |

Correction: the b8 handoff said "29 held cards". Its own per-country list (7 FR, 10 IT, 2 JP, 3 ES, 1 DE, 2 GB, 2 CN)
adds to 27, and 602 − 575 (BE+NL+US+LU+MC+AD) = 27. The held count is **27**.

## Done in this session
1. Start check (16:01 UTC): price 7,582, ledger 148, audit 117,799. All matched. Repo attached with push access,
   clone at `be09ed3`. Builder sha256 `add2da65…a491e178` (unchanged, same in repo `docs/`).
2. Ceremony check (search Oct 30):
   - Netherlands 2026: Oct 5, 2026, MECC Maastricht (guide.michelin.com list article). Our NL award rows are 2026.
   - Belgium & Luxembourg 2026: May 4, 2026, Handelsbeurs Antwerp (guide.michelin.com). 2027 not out.
   - Monaco sits in the France guide; Andorra in the Spain guide (Spain 2027 Dec 1). No straddle in the read window.
   - Note: the b8 handoff said "Benelux 2026 editions were in spring". True for BE/LU only; NL moved to October.
3. Found in the container: relay parts `p1–p3.txt` and a browser tab with `window.RES` from an earlier attempt
   (~15:47 UTC, unknown chat). Not used. Moved to `b9/prior-attempt/`; tab reloaded; all cards read fresh.
4. Batch 9 list: P2 with `country_iso IN ('BE','NL','LU','MC','AD')`, 429 rows (`ve_00d0fd700d` to `ve_ff90d8abe8`):
   BE 231, NL 174, LU 15, MC 8, AD 1. ids md5 `78dec7bb…1f25b2`. List sha256 (`venue_id|card URL`) `ee15bb94…8d361f0c`,
   checked in the browser (part 1, 198 rows < `ve_8`, `cf00c1bf…48ab02bc`; part 2, 231 rows, `291afb2e…5f1a1a`). Old rows
   (429): michelin 361, none 68; legacy tiers 1 = 7, 2 = 172, 3 = 97, 4 = 153. All award rows Michelin 2026. All card
   paths `us/en/`. Monaco cards sit under `monaco-region/monaco/` with `restaurant_country` = `mc`.
5. Pre-check of 6 cards (one per country + the `%C5%93` path): nl, be, lu, mc, ad all €; Au Cœur de Lacuisine 200.
6. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.34 s per card, 16:04:54 to 16:14:27 UTC):
   429 read, 429 clean, **0 held**. 0 missing symbols, 0 redirects, 0 Selected-only. Country/symbol: be € 231,
   nl € 174, lu € 15, mc € 8, ad € 1. Distinction: 1 star 206, 2 stars 41, 3 stars 4, Bib 178 (= our 2026 award rows
   exactly: BE 102/19/2/108, NL 88/18/1/67, LU 10/2/0/3, MC 5/2/1/0, AD 1/0/0/0).
7. Relay: 429 lines, sha256 `951f8fe8…c05aa1f`, copied out in 3 parts of 143 (`610b21a2…`, `bf8b1dae…`,
   `e0fde27c…`), each hash-checked, joined and hash-checked. Fingerprint md5 `c1f683fa70b5418c12a7dfef97aab66f`.
   Old-row md5 (429 relay venues) `5dd3d08e87fe8392520c60b1544b6537`.
8. Diff (computed in the database from the compact `id:tier:dist` string, md5 `f4676467…fac8ca`):
   413 same tier (1→1 4, 2→2 170, 3→3 86, 4→4 153); 16 one-step changes (16 up, 0 down); 0 bigger.
   - Up 3→4 (One Star): Triptyque (Wateringen), Spetters (Breskens), La Provence (Driebergen), Basiliek (Harderwijk),
     Maeve (Utrecht), Joann (Enschede), 't Ganzenest (Rijswijk), Goffin (Bruges), Modest (Opglabbeek), Sensum Gent
     (Sint-Denijs-Westrem), Le Vieux Château (Flobecq).
   - Up 2→3 (Bib): La Charcuterie (Saint-Gilles), K restaurant (Huldange, LU).
   - Up 1→2 (Bib): A-Fusion (Amsterdam), Tabkeaw (Maastricht), Au Dos de la Cuillère (Verviers).
9. Syntax check (pglast 8.7) passed. Dry run through the Read connector (DO block cut at the first UPDATE, ends with
   RAISE EXCEPTION 'DRY RUN OK'): all guards passed. Counts unchanged after.
10. Write (Ben "go", Oct 30 12:25 ET), Write connector, one transaction, all guards and post-checks passed:
    - 429 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
      symbol_raw = card symbol, currency EUR 429, tier = symbol count, confidence NULL, captured_at = read time.
      Card tiers: 1 = 4, 2 = 173, 3 = 88, 4 = 164.
    - Ledger **149** (16:29:37 UTC): michelin, price, 429, job `price-card:price-michelin-card-p2-b9-2026-10-30 | …`.
    - Audit **117,800–118,228** (429, all price UPDATE).
    - Read-back samples: Le Louis XV €€€€ EUR 4; Zilte €€€€ 4; De Librije €€€€ 4; Boury €€€€ 4; Hof van Cleve €€€€ 4;
      Ma Langue Sourit €€€€ 4; Ibaya (Andorra) €€€€ 4; Triptyque €€€€ 4; K restaurant €€€ 3; A-Fusion €€ 2;
      Au Cœur de Lacuisine €€ 2; Car Bon € 1. All source guide_ingest, publisher michelin.

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b9-2026-10-30.sql` (57,261 bytes) | `0f520f643a7c6c4b2ff560e46d0fecd6678e127080311ee0ff486f6e62ddbd46` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b9-relay-2026-10-30.txt` (429 lines, no final newline) | `951f8fe80502125a8c3e9fae75b7bc2a24e62dff404315901e44ef287c05aa1f` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 9 (Belgium + Netherlands + Luxembourg + Monaco + Andorra, 429 venues)"
  7582 148 117799 5dd3d08e87fe8392520c60b1544b6537`.
- `cities` has no `name` column; the city label is `cities.display`.
- Card loop field names: `window.RES` items `{v, path, status, redirect, sym, cat, dist, cc, at}`; `dist` for two
  stars is `2 star` (singular). Relay parts kept on `window.RP`.
- Before a new batch, check the working folder and the browser tab for leftovers from another chat; read fresh.

## Open items
- No new holds in batch 9.
- Carried from batch 8: 2 Beijing cards 404 (Jing `ve_262d31b59b`, Ladychai `ve_8a5b0b0df3`), check with the Beijing
  2027 promote; Beijing & Tianjin 2027 is out (Oct 28, 2026) and the promote can start; Fujian 2027 watch (late Nov).
- Carried from batch 7: 2 UK cards 404 (Café Spice Namasté `ve_5911480108`, BOX-E `ve_c5a3f2e5bd`).
- Carried from batch 6: 1 Germany card 404 (Sticky Fingers, Regensburg `ve_f93b620329`).
- Carried from batch 5: 2 Spain cards 404 (SLOW&LOW `ve_18248f03f5`, El Espejo `ve_6bdb3af7e7`); 1 Spain card moved
  city (El Jardín de la Sal `ve_e50adc624d`: Las Caletas → Fuencaliente de la Palma).
- Carried from batch 4: 2 Japan cards 404 (TOKi `ve_434df13957`, Vegan Ramen UZU Kyoto `ve_bb69a63e96`).
- Carried from batch 3: 5 Italy cards moved to a new city path (La Locanda del Borgo, Kresios, Paca, Coxinendi, Torre
  del Saracino); 5 Italy cards 404 (Impronte, Andrea Ristorante - Enoteca, Unforgettable, Nole Ristorante, Ristorante
  Santa Elisabetta); venue `ve_04c2784726` named "Lavello" (card is Forentum).
- Carried: 5 France cards 404 from batch 2 and 2 from batch 1; Les Fresques name cleanup `ve_e574aeb7fd`; Terra
  (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest 151 venues (name search).
- Carried: Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7); Spain 2027 edition Dec 1 (Huesca);
  Germany 2027 edition in Frankfurt (date not found); GB&I 2027 edition (date not found); Tokyo / Kyoto-Osaka / Nara
  2027 after Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027, date not found); telleruide slug; apostrophe policy;
  Nadair (Atlanta) possibly closed; Dill (Lewes) status; Florida 2026 Green Stars article not found; La Table –
  Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Next: batch 10 (United States, 146)
- Selection: P2 with `cities.country_iso = 'US'` by `ORDER BY venue_id COLLATE "C"`, all rows in one batch (146 at
  the Oct 30 16:30 read; read again).
- Card symbol `$` for `us` (USD); the relay holds `$`-runs inside `$r$…$r$` (no conflict; check `$r$` absent).
- Ceremony check before the read: US guides are regional (California, New York, Chicago, DC, Florida, Texas,
  Colorado, Atlanta, American South, Northeast Cities after Dec 14). Check that no regional edition lands inside the read
  window, and that cards read show the edition our award rows hold (Texas after Oct 8, American South after Oct 21).
- After batch 10: a pass over the 27 held cards and the P1 rest (151).

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b9-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 149 and audit_log 118,228. Then check the
US regional ceremony dates and start batch 10 of block A step 2 (United States, 146 venues): read the cards, build the
file, examine it read-only, and show me the diff. No write before my go.
Attach the compasseats repo with push access for the commit after the write.
```
