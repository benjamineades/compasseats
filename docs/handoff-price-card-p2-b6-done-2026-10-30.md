# Handoff: Block A step 2, batch 6 done (Germany, 432 rows updated). Oct 30, 2026. Next: batch 7 (UK + Ireland).

This file replaces `handoff-price-card-p2-b5-done-2026-10-30.md` for live state and next steps. That file and the
b1 to b4 handoffs still hold batches 1 to 5 and the method notes. `handoff-price-card-p2-brief-2026-10-30.md` holds the
P2 definition, the batch list and the method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method.
The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (unchanged, Oct 30, 2026)
1. Batch order: France 1, France 2, Italy, Japan, Spain, Germany, UK+IE, CN+TW, Benelux+MC+AD, US.
2. Card tier equals legacy tier: update the row anyway (real symbol, ISO currency, card URL).
3. Card shows Selected only: update the price anyway. Award rows do not change (Oct 10 ruling).
4. Card tier lower than legacy tier: update. Ben "go" on the batch 6 diff (4 changes of one step up, 0 bigger),
   Oct 30 05:11 ET.

## Live state (read Oct 30, 09:16 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **3,567**, legacy_guide **4,015**) |
| source_capture_ledger (max id) | **146** |
| audit_log (max id) | **116,967** |
| P2 remaining | 1,866 - 432 = **1,434** (includes 7 held France, 10 held Italy, 2 held Japan, 3 held Spain, 1 held Germany) |

## Done in this session
1. Start check (08:49 UTC): price 7,582, ledger 145, audit 116,535. All matched. Repo attached with push access,
   clone at `6a83655`. Builder from repo `docs/build_price_update_sql.py`, sha256 `add2da65…a491e178` (unchanged).
2. Germany 2027 edition: the 2026 German ceremony was June 23, 2026, in Frankfurt (Palmengarten). Frankfurt hosts
   the 2027 ceremony too, no date given (hogapage.de, Feb 25, 2026). The read does not straddle a ceremony.
3. Batch 6 list: Germany P2, all 433 rows (`ve_000416f84a` to `ve_ff9f2ff3ef`). ids md5 `590799f7…6197f`. List sha256
   (`venue_id|card URL`, newline) `59b9db4c…517bbe`, checked in the browser. Old rows (433): michelin 342, none 91;
   legacy tiers 1 = 8, 2 = 119, 3 = 44, 4 = 262. All card paths start with `us/en/`.
4. Card read (built-in browser, one tab, fetch loop 1.2 s pause, about 1.39 s per card, 08:51:21 to 09:01:22 UTC):
   433 read, 432 clean, held 1. 0 missing symbols on clean rows, 0 Selected-only cards. All clean cards: country `de`,
   symbol €. Distinction: 1 star 255, 2 stars 39, 3 stars 12, Bib 126.
   Held: Sticky Fingers, Regensburg `ve_f93b620329` (card 404, legacy `$$`, Michelin Bib Gourmand 2026 row).
5. Relay: 432 lines, sha256 `c017e2ef…a28a525d`, copied out in 3 parts (144/144/144), each part hash-checked,
   joined and hash-checked.
6. Diff (432 rows, computed in the database from the compact `id:tier:dist` string, md5 `8a979204…bd3bf9`):
   428 same tier; 4 one-step changes (all up, 3→4); 0 changes of more than one step.
   3→4: Rebers Pflug (Schwäbisch Hall), Kuultivo (Leipzig), BOK Restaurant Brust oder Keule (Münster),
   Wirtshaus Meyers Keller (Nördlingen). Old-row md5 (432 relay venues) `ee362d9f…de57f9`.
7. Syntax check (pglast parse_sql and parse_plpgsql) passed. Dry run through the Read connector (DO block cut at the
   first UPDATE, ends with RAISE EXCEPTION 'DRY RUN OK'): all guards passed. Counts unchanged after (09:10 UTC).
8. Write (Ben "go", Oct 30 05:11 ET), Write connector, one transaction, all guards and post-checks passed:
   - 432 UPDATE of `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency EUR, tier = symbol count, confidence NULL, captured_at = read time.
     Card tiers: 1 = 8, 2 = 118, 3 = 40, 4 = 266.
   - Ledger **146** (09:15:57 UTC): michelin, price, 432, job `price-card:price-michelin-card-p2-b6-2026-10-30 | …`.
   - Audit **116,536–116,967** (432, all price UPDATE).
   - Read-back samples: Haerlin €€€€ EUR 4; Schwarzwaldstube €€€€ EUR 4; Rebers Pflug €€€€ EUR 4; Kuultivo €€€€ EUR 4;
     BOK Restaurant Brust oder Keule €€€€ EUR 4; Wirtshaus Meyers Keller €€€€ EUR 4; Feine Speiseschenke € EUR 1;
     360° €€€€ EUR 4; Tipken's by Nils Henkel €€€€ EUR 4. Held row unchanged (`$$`, no currency, no URL, legacy_guide).
   - Germany active legacy rows with no URL after the write: 27 (1 held above; 26 outside P2).

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-b6-2026-10-30.sql` (59,968 bytes) | `5f6bb387c286009374917e1bca0e86284ee48bcd5dd3f5dc48da8c385a99b37d` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-b6-relay-2026-10-30.txt` (432 lines, no final newline) | `c017e2ef258af1f373966e60c0c0beb82f0ca72a668ae7d07dd7d157a28a525d` | project `claude/`, repo `docs/` |
| `build_price_update_sql.py` (unchanged) | `add2da658daf26a6857a25b609108d973cc774e28ef54874f63b94c9a491e178` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Method notes from this session
- Builder arguments: `RELAY OUT KEY "batch 6 (Germany, 433 venues)" 7582 145 116535 <old md5>`. The old md5 is read
  for the relay venues only (held rows excluded).
- List into the browser in 2 parts (217 + 216) as template literals, with the card path after
  `https://guide.michelin.com/us/en/` only (substr from 34). The browser rebuilt the full URL and checked the list sha256.
  Part 2 chained onto part 1 (`run1.then(...)`), so only one fetch ran at a time.
- The relay `captured_at` has no milliseconds this time (`2026-10-30T08:51:21Z`). The builder and the guards accept it.
- Germany card paths: 2 hold percent-encoded characters (`360%C2%B0`, `tipken%C2%B4s`). Both read with 200 and no
  redirect (decodeURI compare), and pass through the relay and the SQL unchanged. Several city segments drop umlauts
  (`mnchen`, `knigsbronn`, `bad-tlz`); these are Michelin's own paths, not errors.
- Dry run variant: the DO block cut at the first UPDATE plus `RAISE EXCEPTION 'DRY RUN OK…'` gives a clear pass
  message (instead of the read-only error).

## Open items
- New: 1 Germany card 404 (Sticky Fingers, Regensburg `ve_f93b620329`). Status check with the other held cards.
- Carried from batch 5: 2 Spain cards 404 (SLOW&LOW `ve_18248f03f5`, El Espejo `ve_6bdb3af7e7`); 1 Spain card moved
  city (El Jardín de la Sal `ve_e50adc624d`: Las Caletas → Fuencaliente de la Palma).
- Carried from batch 4: 2 Japan cards 404 (TOKi `ve_434df13957`, Vegan Ramen UZU Kyoto `ve_bb69a63e96`).
- Carried from batch 3: 5 Italy cards moved to a new city path (La Locanda del Borgo, Kresios, Paca, Coxinendi, Torre
  del Saracino); 5 Italy cards 404 (Impronte, Andrea Ristorante - Enoteca, Unforgettable, Nole Ristorante, Ristorante
  Santa Elisabetta); venue `ve_04c2784726` named "Lavello" (card is Forentum).
- Carried: 5 France cards 404 from batch 2 and 2 from batch 1; Les Fresques name cleanup `ve_e574aeb7fd`; Terra
  (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; P1 rest 151 venues (name search).
- Carried: Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7);
  Spain 2027 edition Dec 1 (Huesca); Germany 2027 edition in Frankfurt (date not found); Tokyo / Kyoto-Osaka / Nara
  2027 after Feb 16, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Florida 2026 Green
  Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new
  awards on closed venues.

## Next: batch 7 (United Kingdom + Ireland, 379)
- Selection: P2 with `cities.country_iso IN ('GB','IE')` by `ORDER BY venue_id COLLATE "C"`, all rows in one batch
  (UK 337 + Ireland 42 at the Oct 30 08:1x read; read again).
- Card symbols: £ for `gb` (GBP), € for `ie` (EUR). The builder maps both. Check one card of each country (locale path
  and Price line) before the loop. Check whether any Northern Ireland card shows `gb` with £.
- Great Britain & Ireland 2027 edition: check the ceremony date before the read, so no batch straddles it.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-b6-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p2-brief-2026-10-30.md for the P2 definition and batch list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use claude/build_price_update_sql.py
as the builder. Do a fresh count read and confirm price 7,582, ledger 146 and audit_log 116,967. Then start batch 7 of
block A step 2 (United Kingdom + Ireland, 379 venues): read the cards, build the file, examine it read-only, and show
me the diff. No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
