# Handoff: Block A step 2, batch 5 done (Spain, 475 rows updated). Oct 30, 2026. Next: batch 6 (Germany).

This file replaces `handoff-price-card-p2-b4-done-2026-10-30.md` for live state and next steps. That file and the
b1/b2/b3 handoffs still hold batches 1 to 4 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 5 diff (1 change of 3 steps up), Oct 30 04:42 ET.

## Live state (read Oct 30, 08:4x UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **3,135**, legacy_guide **4,447**) |
| source_capture_ledger (max id) | **145** |
| audit_log (max id) | **116,535** |
| P2 remaining | 2,341 - 475 = **1,866** (includes 7 held France, 10 held Italy, 2 held Japan, 3 held Spain) |

## Done in this session
1. Start check (08:09 UTC): price 7,582, ledger 144, audit 116,060. All matched. Repo attached with push access,
   clone at `cd8f4c7`. Builder from repo `docs/build_price_update_sql.py`, sha256 `add2da65…a491e178` (unchanged).
2. P2 by country (read 08:1x UTC): Spain 478, Germany 433, UK 337, China 318, Belgium 231, Netherlands 174, US 146,
   Taiwan 139, Ireland 42, Luxembourg 15, Italy 10 (held), Monaco 8, France 7 (held), Japan 2 (held), Andorra 1.
   Total 2,341.
3. Spain 2027 edition: gala in Huesca, Tuesday Dec 1, 2026 (moved one week; Vozpópuli, Oct 20, 2026). The read
   finished Oct 30, so the batch does not straddle the ceremony.
4. Batch 5 list: Spain P2, all 478 rows (`ve_003f5e3cd0` to `ve_fee48b155c`). ids md5 `5aed6429…983949`. List sha256
   (`venue_id|card URL`, newline) `dc5bc18a…2a40db8`, checked in the browser. Old rows (478): michelin 359, none 119;
   legacy tiers 1 = 38, 2 = 160, 3 = 109, 4 = 171. All card paths start with `us/en/`.
5. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.37 s per card, 08:12:16 to 08:23:09 UTC):
   478 read, 475 clean, held 3. 0 missing symbols on clean rows, 0 Selected-only cards. All clean cards: country `es`,
   symbol €. Distinction: 1 star 232, 2 stars 36, 3 stars 16, Bib 191.
   Held: SLOW&LOW, Barcelona `ve_18248f03f5` (card 404, legacy `$$$$`); El Espejo, Sanlúcar de Barrameda
   `ve_6bdb3af7e7` (card 404, legacy `$$`); Restaurante Temático El Jardín de la Sal, Las Caletas `ve_e50adc624d`
   (card moved to `canarias/fuencaliente-de-la-palma/restaurant/el-jardin-de-la-sal`, Bib, €; legacy `$`).
6. Relay: 475 lines, sha256 `f129c62d…1b52154b`, copied out in 3 parts (160/160/155), each part hash-checked,
   joined and hash-checked.
7. Diff (475 rows, computed in the database from the relay pairs, pair md5 `3a3f630c…d48f178`): 470 same tier;
   4 one-step changes (all up); 1 change of more than one step (up).
   1→4: El Molino de Urdániz y Origen (Urdániz, Two Stars card €€€€). 1→2: Mas Concas (L'Escala, Bib card).
   3→4: Restaurante Ababol (Albacete), Restaurante La Prensa (Zaragoza), Ricardo Temiño Restaurante (Burgos).
   Old-row md5 (475 relay venues) `9b3b2748…b321d1`.
8. Syntax check (pglast parse_sql and parse_plpgsql) passed. Dry run through the Read connector: all guards passed,
   stopped at the first UPDATE. Counts unchanged after.
9. Write (Ben "go", Oct 30 04:42 ET), Write connector, one transaction, all guards and post-checks passed:
   - 475 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency EUR, tier = symbol count, confidence NULL, captured_at = read time.
     Card tiers: 1 = 35, 2 = 160, 3 = 106, 4 = 174.
   - Ledger **145** (08:46:28 UTC): michelin, price, 475, job `price-card:price-michelin-card-p2-b5-2026-10-30 | …`.
   - Audit **116,061–116,535** (475, all price UPDATE).
   - Read-back samples: El Celler de Can Roca €€€€ EUR 4; El Molino de Urdániz y Origen €€€€ EUR 4; Restaurante
     Ababol €€€€ EUR 4; Ricardo Temiño €€€€ EUR 4; La Prensa €€€€ EUR 4; Ca´n Boqueta €€ EUR 2; Mas Concas €€ EUR 2;
     Mu•na €€€€ EUR 4. Held rows unchanged (legacy `$` symbols, no currency, no URL).
   - Spain active legacy rows with no URL after the write: 9 (3 held above; 6 outside P2).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b5-2026-10-30.sql` (64.7 KB) | `6c101404335417b4b16537596dc104f7ac736d362ea6ae3ffe217e7f2c2d67ff` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b5-relay-2026-10-30.txt` (475 lines, no final newline) | `f129c62dbed0e27a87eebbf801c51716bf8f14d8bcd5b4ab90c049dd1b52154b` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 5 (Spain, 478 venues)" 7582 144 116060 <old md5>`. The old md5 is read
  for the relay venues only (held rows excluded).
- List into the browser in 2 parts (239 + 239) as template literals; the loop started on part 1 while part 2 loaded.
- Two Spain card paths hold percent-encoded characters (`ca%C2%B4n-boqueta`, `mu%E2%80%A2na`). They read with 200 and
  no redirect (decodeURI compare), and pass through the relay and the SQL unchanged.
- The diff and the tier check used a compact `id:tier:dist` string (md5-checked in the database) instead of the full
  relay. This saves one pass of the relay through the chat.

## Open items
- New: 2 Spain cards 404 (SLOW&LOW `ve_18248f03f5`, El Espejo `ve_6bdb3af7e7`); 1 Spain card moved city
  (El Jardín de la Sal `ve_e50adc624d`: Las Caletas → Fuencaliente de la Palma). Status check with the other held cards.
- Carried from batch 4: 2 Japan cards 404 (TOKi `ve_434df13957`, Vegan Ramen UZU Kyoto `ve_bb69a63e96`).
- Carried from batch 3: 5 Italy cards moved to a new city path (La Locanda del Borgo, Kresios, Paca, Coxinendi, Torre
  del Saracino); 5 Italy cards 404 (Impronte, Andrea Ristorante - Enoteca, Unforgettable, Nole Ristorante, Ristorante
  Santa Elisabetta); venue `ve_04c2784726` named "Lavello" (card is Forentum).
- Carried: 5 France cards 404 from batch 2 and 2 from batch 1; Les Fresques name cleanup `ve_e574aeb7fd`; Terra
  (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest 151 venues (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  Spain 2027 edition Dec 1 (Huesca); Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; telleruide slug; apostrophe
  policy; Nadair (Atlanta) possibly closed; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge
  candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Next: batch 6 (Germany, 433)
- Selection: Germany P2 (`cities.country_iso = 'DE'`) by `ORDER BY venue_id COLLATE "C"`, all 433 rows in one batch.
- Card symbol €, currency EUR (builder maps `de` → EUR). Check the Germany card locale path and the Price line on one
  card before the loop.
- Germany 2027 edition: check the ceremony date before the read, so no batch straddles it.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b5-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 145 and audit_log 116,535. Then start batch 6 of
block A step 2 (Germany, 433 venues): read the cards, build the file, examine it read-only, and show me the diff.
No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
