# Handoff: Block A step 2, batch 4 done (Japan, 566 rows updated). Oct 30, 2026. Next: batch 5 (Spain).

This file replaces `handoff-price-card-p2-b3-done-2026-10-30.md` for live state and next steps. That file and the
b1/b2 handoffs still hold batches 1 to 3 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 4 diff (2 one-step drops), Oct 30 03:59 ET.

## Live state (read Oct 30, 08:0x UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **2,660**, legacy_guide **4,922**) |
| source_capture_ledger (max id) | **144** |
| audit_log (max id) | **116,060** |
| P2 remaining | 2,907 - 566 = **2,341** (includes 7 held France, 10 held Italy, 2 held Japan) |

## Done in this session
1. Start check (07:15 UTC): price 7,582, ledger 143, audit 115,494. All matched. Repo attached with push access,
   clone at `22b6fd4`. Builder from repo `docs/build_price_update_sql.py`, sha256 `add2da65…a491e178` (unchanged).
2. P2 by country (read 07:1x UTC): Japan 568, Spain 478, Germany 433, UK 337, China 318, Belgium 231, Netherlands 174,
   US 146, Taiwan 139, Ireland 42, Luxembourg 15, Italy 10 (held), Monaco 8, France 7 (held), Andorra 1. Total 2,907.
3. Batch 4 list: Japan P2, all 568 rows (`ve_0266238561` to `ve_ffca00f08e`). ids md5 `892c202c…5a`. List sha256
   (`venue_id|card URL`, newline) `f0d36aec…9fe95`, checked in the browser. Old rows (568): michelin 431, none 137;
   legacy tiers 1 = 85, 2 = 135, 3 = 183, 4 = 165. All card paths start with `us/en/`.
4. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.36 s per card, 07:18:23 to 07:31:18 UTC):
   568 read, 566 clean, held 2. 0 missing symbols, 0 redirects, 0 Selected-only cards. All clean cards: country `jp`,
   symbol ¥. Distinction: 1 star 269, 2 stars 60, 3 stars 20, Bib 217.
   Held, card 404: TOKi, Tokyo `ve_434df13957` (legacy `$$$`); Vegan Ramen UZU Kyoto `ve_bb69a63e96` (legacy `$$`).
5. Relay: 566 lines, sha256 `d5c8ff32…a275a99d`, copied out in 3 parts (190/190/186), each part hash-checked,
   joined and hash-checked.
6. Diff (566 rows, computed in the database from the relay pairs, pair md5 `e94fcab9…eb1ae`): 562 same tier;
   4 one-step changes (2 up, 2 down); 0 changes of more than one step. Old-row md5 `82320598…a23a`.
   2→3: Sakamoto Sushi (Osaka, Bib card ¥¥¥). 3→4: Iroha (Osaka). 4→3: Taian (Osaka), Kashiwaya Osaka Senriyama.
7. Syntax check (pglast parse_sql and parse_plpgsql) passed. Dry run through the Read connector: all guards passed,
   stopped at the first UPDATE. Counts unchanged after.
8. Write (Ben "go", Oct 30 03:59 ET), Write connector, one transaction, all guards and post-checks passed:
   - 566 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency JPY, tier = symbol count, confidence NULL, captured_at = read time.
     Card tiers: 1 = 85, 2 = 133, 3 = 184, 4 = 164.
   - Ledger **144** (08:05:22 UTC): michelin, price, 566, job `price-card:price-michelin-card-p2-b4-2026-10-30 | …`.
   - Audit **115,495–116,060** (566, all price UPDATE).
   - Read-back samples: Creative Dining TAKAYAMA ¥¥¥¥ JPY 4; Taian ¥¥¥ JPY 3; Kashiwaya Osaka Senriyama ¥¥¥ JPY 3;
     Sakamoto Sushi ¥¥¥ JPY 3; Iroha ¥¥¥¥ JPY 4; LURRA° ¥¥¥¥ JPY 4; Presqu'île ¥¥¥ JPY 3. Held rows unchanged
     (legacy `$` symbols, no currency, no URL).
   - Japan active legacy rows with no URL after the write: 13 (2 held above; 11 outside P2).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b4-2026-10-30.sql` (71.5 KB) | `90dfca826d8167ff969462ccc9207e35f3c94139d78988c45a9acbb59dfae293` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b4-relay-2026-10-30.txt` (566 lines, no final newline) | `d5c8ff329cc599b7a3e9123ff0024f7529434f1436f18ceab6495a49a275a99d` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 4 (Japan, 568 venues)" 7582 143 115494 <old md5>`.
- The 568-row list went into the browser in 2 parts (`window.L1`, `window.L2`, 284 + 284 lines) as template
  literals. The list query uses `substr(source_url, 33)` (the path after `https://guide.michelin.com/us/en`); the
  browser adds `us/en` back and checks the full-list hash against the database.
- New: the fetch loop can start on part 1 while part 2 loads (the loop reads `window.Q`; part 2 is pushed after its
  hash check). This saves a few minutes per batch.
- Japan card paths hold non-ASCII characters (`presqu’ile`, `lurra˚`). They pass through the template literals, the
  relay and the SQL unchanged; the hash checks prove it.
- Relay copy-out: 3 parts of about 190 lines each.

## Open items
- New: 2 Japan cards 404 (TOKi `ve_434df13957`, Vegan Ramen UZU Kyoto `ve_bb69a63e96`). Status check with the other
  held cards.
- Carried from batch 3: 5 Italy cards moved to a new city path (La Locanda del Borgo, Kresios, Paca, Coxinendi, Torre
  del Saracino); 5 Italy cards 404 (Impronte, Andrea Ristorante - Enoteca, Unforgettable, Nole Ristorante, Ristorante
  Santa Elisabetta); venue `ve_04c2784726` named "Lavello" (card is Forentum).
- Carried: 5 France cards 404 from batch 2 and 2 from batch 1; Les Fresques name cleanup `ve_e574aeb7fd`; Terra
  (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest 151 venues (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly
  closed; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy
  special-award rows; 5 new awards on closed venues.

## Next: batch 5 (Spain, 478)
- Selection: Spain P2 (`cities.country_iso = 'ES'`) by `ORDER BY venue_id COLLATE "C"`, all 478 rows in one batch.
- Card symbol €, currency EUR (builder maps `es` → EUR). Check the Spain card locale path and the Price line on one
  card before the loop. Note: Andorra (1 venue) is in batch 9, not here.
- Spain 2027 edition: check the ceremony date before the read, so no batch straddles it.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b4-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 144 and audit_log 116,060. Then start batch 5 of
block A step 2 (Spain, 478 venues): read the cards, build the file, examine it read-only, and show me the diff.
No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
