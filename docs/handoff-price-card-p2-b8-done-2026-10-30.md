# Handoff: Block A step 2, batch 8 done (China + Taiwan, 455 rows updated). Oct 30, 2026. Next: batch 9 (Benelux + MC + AD).

This file replaces `handoff-price-card-p2-b7-done-2026-10-30.md` for live state and next steps. That file and the
b1 to b6 handoffs still hold batches 1 to 7 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 8 diff (2 changes of one step: 0 up, 2 down;
   0 bigger), Oct 30 11:33 ET.

## Live state (read Oct 30, 15:38 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **4,399**, legacy_guide **3,183**) |
| source_capture_ledger (max id) | **148** |
| audit_log (max id) | **117,799** |
| P2 remaining | **602**: BE 231, NL 174, US 146, LU 15, IT 10, MC 8, FR 7, ES 3, GB 2, CN 2, JP 2, AD 1, DE 1 (includes 29 held cards: 7 FR, 10 IT, 2 JP, 3 ES, 1 DE, 2 GB, 2 CN; the IT 10 are all held) |

## Done in this session
1. Start check (15:07 UTC): price 7,582, ledger 147, audit 117,344. All matched. Repo attached with push access,
   clone at `ee990f6`. Builder from repo `docs/build_price_update_sql.py`, sha256 `add2da65…a491e178` (unchanged).
2. Ceremony check (search Oct 30):
   - Beijing & Tianjin 2027: released Oct 28, 2026, ceremony in Tianjin (michelin.com press release). Before the read,
     so no straddle. The Beijing cards read show the 2027 edition. Carried item "Beijing & Tianjin after Nov 1" can
     start now.
   - Guangzhou–Shenzhen 2026: released Aug 21, 2026 (michelin.com). Shanghai–Jiangsu–Zhejiang 2026: April 2026.
     Taiwan ceremony: August. Chengdu 2027: done.
   - Fujian 2027: not out. Fujian 2026 was Nov 20, 2025, so 2027 is likely late Nov 2026 (watch item).
3. Batch 8 list: CN + TW P2, all 457 rows (`ve_00c898a89c` to `ve_feb8000925`), CN 318 + TW 139. ids md5
   `20e88608…1d9cdfe`. List sha256 (`venue_id|card URL`, newline) `e4cdcdf8…7cec64b2`, checked in the browser
   (part 1, 225 rows < `ve_8`, `e85f3419…107d8e1b`; part 2, 232 rows, `9070a793…0ce338`). Old rows (457): michelin 399,
   none 58; legacy tiers 1 = 173, 2 = 163, 3 = 61, 4 = 60. All card paths `us/en/`. 0 Hong Kong / Macau cards
   (`mo-jasmine` is a Beijing slug, not Macau).
4. Pre-check of 5 cards: Beijing The Georg `cn` ¥, Beijing `poetry%E2%80%A7wine` (200, no redirect), Shanghai Fu 1015
   `cn` ¥, Taipei Mudan `tw` $, Hsinchu County Bebu `tw` $.
5. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.34 s per card, 15:11:51 to 15:22:02 UTC):
   457 read, 455 clean, held 2. 0 missing symbols, 0 Selected-only cards. Country/symbol: `cn` ¥ 316, `tw` $ 139.
   Distinction: 1 star 104, 2 stars 26, 3 stars 6, Bib 319.
   Held (card 404, legacy price kept; both likely left the guide in the Beijing 2027 edition):
   Jing, Beijing `ve_262d31b59b` (legacy `$$$$`, Michelin 2026 One Star row); Ladychai, Beijing `ve_8a5b0b0df3`
   (legacy `$`, Michelin 2026 Bib row).
6. Relay: 455 lines, sha256 `5a7840c2…1bce5948`, copied out in 3 parts (152/152/151), each part hash-checked,
   joined and hash-checked. ids md5 `9e3543f5…61abc2`. Fingerprint md5 `d6b7ca00…4547ef`.
7. Diff (455 rows, computed in the database from the compact `id:tier:dist` string, md5 `8f4a4d71…9340be`):
   453 same tier (1→1 172, 2→2 162, 3→3 60, 4→4 59); 2 one-step changes (0 up, 2 down); 0 changes of more than one
   step. Down 2→1: Gong De Lin (West Nanjing Road), Shanghai (Bib). Down 3→2: Mipon, Taipei (One Star).
   Old-row md5 (455 relay venues) `2b5e68dd…ab44be`.
8. Syntax check (pglast 8.7 parse_sql and parse_plpgsql) passed. Dry run through the Read connector (DO block cut at
   the first UPDATE, ends with RAISE EXCEPTION 'DRY RUN OK'): all guards passed. Counts unchanged after.
9. Write (Ben "go", Oct 30 11:33 ET), Write connector, one transaction, all guards and post-checks passed:
   - 455 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency CNY 316 / TWD 139, tier = symbol count, confidence NULL, captured_at = read
     time. Card tiers: 1 = 173, 2 = 163, 3 = 60, 4 = 59 (CNY 117/115/46/38, TWD 56/48/14/21).
   - Ledger **148** (15:37:47 UTC): michelin, price, 455, job `price-card:price-michelin-card-p2-b8-2026-10-30 | …`.
   - Audit **117,345–117,799** (455, all price UPDATE).
   - Read-back samples: Xin Rong Ji (Xinyuan South Road) ¥¥¥¥ CNY 4; Chao Shang Chao (Chaoyang) ¥¥¥¥ CNY 4; Tai'an
     Table ¥¥¥¥ CNY 4; Taïrroir $$$$ TWD 4; JL STUDIO $$$$ TWD 4; Gong De Lin ¥ CNY 1; Mipon $$ TWD 2;
     Poetry‧Wine ¥¥ CNY 2; Qi Cun Da Tou Hui (`taste-soar-%C3%97-da-tou-hui`) ¥¥ CNY 2; Shouning Migao ¥ CNY 1.
     Held rows unchanged (legacy_guide, no currency, no URL).
   - CN + TW active legacy rows with no URL after the write: 19 (2 held above; 17 outside P2: no Michelin star/Bib
     card URL).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b8-2026-10-30.sql` (62,102 bytes) | `e003c70b55e356d9bdd9e6a0437c6f05b10f911874d83f6b4db661ad55d59c76` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b8-relay-2026-10-30.txt` (455 lines, no final newline) | `5a7840c23535d80c06f1a220a86ed7d30e6e63b434a1c2c2f74cd9e81bce5948` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 8 (China + Taiwan, 457 venues)" 7582 147 117344 <old md5>`.
  The old md5 is read for the relay venues only (held rows excluded).
- List into the browser in 2 parts split at `ve_8` (225 + 232), each part hash-checked against a database hash, then
  the whole list hash-checked.
- The fetch loop stored results on `window.RES` (field `path`, not `p`) and ran in the background; polled with
  38–40 s waits. Relay built in the browser with times cut to whole seconds (`.replace(/\.\d+Z$/,'Z')`).
- Taiwan `$` and the SQL dollar quote: the relay holds `$`, `$$`, `$$$$` inside `$r$…$r$`; no conflict (checked
  `RELAY.includes('$r$')` = false).
- project_write `local_path` is resolved from `/home/claude`, so a file in `/home/claude/b8` needs `b8/<file>`.
- A held card that 404s right after a new edition (Beijing 2027) is likely a guide exit, not a moved card. Check it
  in the Beijing 2027 promote.

## Open items
- New: 2 Beijing cards 404 (Jing `ve_262d31b59b`, Ladychai `ve_8a5b0b0df3`). Check with the Beijing 2027 promote.
- New: Beijing & Tianjin 2027 is out (Oct 28, 2026). The carried "after Nov 1" promote can start. Cards read today
  show 2027 distinctions that differ from our 2026 award rows (for example Poetry‧Wine shows 1 star).
- New watch item: Fujian 2027 edition (likely late Nov 2026).
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
  2027 after Feb 16, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes) status;
  Florida 2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy
  special-award rows; 5 new awards on closed venues.

## Next: batch 9 (Belgium + Netherlands + Luxembourg + Monaco + Andorra, 429)
- Selection: P2 with `cities.country_iso IN ('BE','NL','LU','MC','AD')` by `ORDER BY venue_id COLLATE "C"`, all rows
  in one batch (BE 231 + NL 174 + LU 15 + MC 8 + AD 1 at the Oct 30 15:4x read; read again).
- Card symbol € for `be`, `nl`, `lu`, `mc`, `ad` (EUR). The builder maps all five. Check one card of each country
  before the loop (Monaco cards may sit under a France region path; check `restaurant_country`).
- Ceremony check before the read: Benelux 2026 editions were in spring; check for any 2027 date inside the read window.
- After batch 9: batch 10 (United States, 146), then a pass over the 29 held cards and the P1 rest (151).

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b8-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 148 and audit_log 117,799. Then check the
Benelux ceremony dates and start batch 9 of block A step 2 (Belgium + Netherlands + Luxembourg + Monaco + Andorra,
429 venues): read the cards, build the file, examine it read-only, and show me the diff. No write before my go.
Attach the compasseats repo with push access for the commit after the write.
```
