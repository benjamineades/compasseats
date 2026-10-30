# Handoff: Block A step 2, batch 7 done (United Kingdom + Ireland, 377 rows updated). Oct 30, 2026. Next: batch 8 (China + Taiwan).

This file replaces `handoff-price-card-p2-b6-done-2026-10-30.md` for live state and next steps. That file and the
b1 to b5 handoffs still hold batches 1 to 6 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 7 diff (12 changes of one step: 7 up, 5 down;
   0 bigger), Oct 30 05:45 ET.

## Live state (read Oct 30, 09:49 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **3,944**, legacy_guide **3,638**) |
| source_capture_ledger (max id) | **147** |
| audit_log (max id) | **117,344** |
| P2 remaining | 1,434 - 377 = **1,057** (includes 7 held France, 10 held Italy, 2 held Japan, 3 held Spain, 1 held Germany, 2 held UK) |

## Done in this session
1. Start check (09:20 UTC): price 7,582, ledger 146, audit 116,967. All matched. Repo attached with push access,
   clone at `4c0dd14`. Builder from repo `docs/build_price_update_sql.py`, sha256 `add2da65…a491e178` (unchanged).
   P2 by country at 09:2x: GB 337, CN 318, BE 231, NL 174, US 146, TW 139, IE 42, LU 15, IT 10, MC 8, FR 7, ES 3,
   JP 2, DE 1, AD 1 (total 1,434).
2. Great Britain & Ireland 2027 edition: no date published (search Oct 30). The 2026 edition was revealed on
   Feb 9, 2026, in Dublin (guide.michelin.com, Oct 22, 2025). The read does not straddle a ceremony.
3. Batch 7 list: GB + IE P2, all 379 rows (`ve_0113e80513` to `ve_fe978a679e`). ids md5 `71610b1a…a6d70e`. List
   sha256 (`venue_id|card URL`, newline) `85aeecd0…5fa8b`, checked in the browser (part 1 sha256 `06802336…dca2`).
   Old rows (379): michelin 263, none 116; legacy tiers 1 = 3, 2 = 160, 3 = 41, 4 = 175. All card paths `us/en/`.
4. Pre-check of 6 cards: London `gb` £, Dublin `ie` €, Jersey (`saint-helier/…`) `gb` £, Guernsey (`guernsey/…`)
   `gb` £, Belfast `gb` £, and the percent-encoded `so%E2%80%93lo` path (200, no redirect).
5. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.35 s per card, 09:23:08 to 09:31:39 UTC):
   379 read, 377 clean, held 2. 0 missing symbols, 0 Selected-only cards. Country/symbol: `gb` £ 335, `ie` € 42.
   Distinction: 1 star 179, 2 stars 28, 3 stars 10, Bib 160.
   Held (card 404, legacy price kept): Café Spice Namasté, London `ve_5911480108` (legacy `$`, Michelin 2026 Bib
   row); BOX-E, Bristol `ve_c5a3f2e5bd` (legacy `$$`, Michelin 2026 Bib row).
6. Relay: 377 lines, sha256 `7119885a…d01dc07c`, copied out in 3 parts (126/126/125), each part hash-checked,
   joined and hash-checked. ids md5 `b5104b28…f55f9d`. Fingerprint md5 `e70041a9…0b1a`.
7. Diff (377 rows, computed in the database from the compact `id:tier:dist` string, md5 `721b646f…c9d647`):
   365 same tier; 12 one-step changes (7 up, 5 down); 0 changes of more than one step.
   Up 2→3: Morchella (London), Thyme Restaurant (Athlone). Up 3→4: Galvin La Chapelle (London), Bulrush (Bristol),
   The Neptune (Hunstanton), The Star Inn (Harome), House of Tides (Newcastle upon Tyne).
   Down 2→1: Gunpowder (London). Down 4→3: Winteringham Fields, The Artichoke (Amersham), Nut Tree Inn (Murcott),
   The Dysart Petersham (London). Old-row md5 (377 relay venues) `95561649…b78b73`.
8. Syntax check (pglast 8.7 parse_sql and parse_plpgsql) passed. Dry run through the Read connector (DO block cut at
   the first UPDATE, ends with RAISE EXCEPTION 'DRY RUN OK'): all guards passed. Counts unchanged after (09:40 UTC).
9. Write (Ben "go", Oct 30 05:45 ET), Write connector, one transaction, all guards and post-checks passed:
   - 377 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency GBP 335 / EUR 42, tier = symbol count, confidence NULL, captured_at = read
     time. Card tiers: 1 = 3, 2 = 156, 3 = 42, 4 = 176 (GBP 3/138/39/155, EUR 0/18/3/21).
   - Ledger **147** (09:49:34 UTC): michelin, price, 377, job `price-card:price-michelin-card-p2-b7-2026-10-30 | …`.
   - Audit **116,968–117,344** (377, all price UPDATE).
   - Read-back samples: The Clove Club ££££ GBP 4; The Fat Duck ££££ GBP 4; L'Enclume ££££ GBP 4; Restaurant Patrick
     Guilbaud €€€€ EUR 4; Gunpowder £ GBP 1; Thyme Restaurant €€€ EUR 3; Winteringham Fields £££ GBP 3; Galvin La
     Chapelle ££££ GBP 4; Bohemia (Jersey) ££££ GBP 4; Vraic (Guernsey) ££££ GBP 4; EDŌ (Belfast) ££ GBP 2;
     sō-lō Restaurant ££££ GBP 4. Held rows unchanged (legacy_guide, no currency, no URL).
   - GB + IE active legacy rows with no URL after the write: 3 (2 held above; Dill, Lewes `ve_b3825c7559`, outside P2:
     2025 Bib row with no URL; Dill status is a carried recheck item).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b7-2026-10-30.sql` (50,304 bytes) | `ec1b961649e05c5e277bd67725f15732f8a19c01b9103ec6b41fd9e2fca1a341` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b7-relay-2026-10-30.txt` (377 lines, no final newline) | `7119885ae62c043a0638f980deecc6b365d8e172196c38c17df6afc7d01dc07c` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 7 (United Kingdom + Ireland, 379 venues)" 7582 146 116967 <old md5>`.
  The old md5 is read for the relay venues only (held rows excluded).
- List into the browser in 2 parts (190 + 189) as template literals, path after `https://guide.michelin.com/us/en/`
  (substr from 34). Part 1 hash was checked against a database hash before part 2 was loaded.
- The loop stored results on `window.RES` and ran in the background; polled with 38–40 s waits.
- Jersey and Guernsey cards: Michelin region segment is `saint-helier` / `guernsey`; `restaurant_country` is `gb`.
  Our cities rows for them have `country_iso` GB, so they fall in the GB batch.
- Ireland card path segments: `ie-baltimore` (Cork) is Michelin's own path, not an error. One card path keeps an
  upper-case segment (`blackrock/restaurant/Liath`); it read with 200 and no redirect.
- `cities` has no `name` column (use `display`). pglast is not preinstalled in a new workspace
  (`pip install --break-system-packages pglast`).
- project_write `local_path` must be inside the working directory, not the scratchpad.

## Open items
- New: 2 UK cards 404 (Café Spice Namasté `ve_5911480108`, BOX-E `ve_c5a3f2e5bd`). Status check with the other held cards.
- Carried from batch 6: 1 Germany card 404 (Sticky Fingers, Regensburg `ve_f93b620329`).
- Carried from batch 5: 2 Spain cards 404 (SLOW&LOW `ve_18248f03f5`, El Espejo `ve_6bdb3af7e7`); 1 Spain card moved
  city (El Jardín de la Sal `ve_e50adc624d`: Las Caletas → Fuencaliente de la Palma).
- Carried from batch 4: 2 Japan cards 404 (TOKi `ve_434df13957`, Vegan Ramen UZU Kyoto `ve_bb69a63e96`).
- Carried from batch 3: 5 Italy cards moved to a new city path (La Locanda del Borgo, Kresios, Paca, Coxinendi, Torre
  del Saracino); 5 Italy cards 404 (Impronte, Andrea Ristorante - Enoteca, Unforgettable, Nole Ristorante, Ristorante
  Santa Elisabetta); venue `ve_04c2784726` named "Lavello" (card is Forentum).
- Carried: 5 France cards 404 from batch 2 and 2 from batch 1; Les Fresques name cleanup `ve_e574aeb7fd`; Terra
  (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest 151 venues (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  Spain 2027 edition Dec 1 (Huesca); Germany 2027 edition in Frankfurt (date not found); GB&I 2027 edition (date not
  found); Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta)
  possibly closed; Dill (Lewes) status; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge
  candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Next: batch 8 (China + Taiwan, 457)
- Selection: P2 with `cities.country_iso IN ('CN','TW')` by `ORDER BY venue_id COLLATE "C"`, all rows in one batch
  (CN 318 + TW 139 at the Oct 30 09:2x read; read again).
- Card symbols: ¥ for `cn` (CNY), $ for `tw` (TWD). The builder maps both. Check one card of each country before the
  loop. Check whether any Hong Kong or Macau venue sits in a CN city row (card country `hk`/`mo` is not in the
  builder map: hold those rows or stop and ask Ben).
- Ceremony check before the read: the carried item says Beijing & Tianjin after Nov 1. Check the Beijing (and any
  other mainland China) 2027 ceremony dates first. If a ceremony falls inside the read window, split the batch or wait.
- 457 rows is above the batch 6 size; if the relay is too long for one write call, split into CN and TW batches.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b7-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 147 and audit_log 117,344. Then check the China
ceremony dates and start batch 8 of block A step 2 (China + Taiwan, 457 venues): read the cards, build the file,
examine it read-only, and show me the diff. No write before my go. Attach the compasseats repo with push access for
the commit after the write.
```
