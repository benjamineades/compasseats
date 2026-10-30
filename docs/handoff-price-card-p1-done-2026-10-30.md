# Handoff: Block A step 1 done (Michelin card price, P1, 558 rows). Oct 30, 2026. Next: repo commit, then block A step 2.

This file replaces `handoff-special-awards-done-2026-10-29.md` for live state and next steps. The working rules, database
notes, methods and dead ends in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule
(Claude commits files to the repo itself) still apply.

## Live state (read Oct 30, 04:29 UTC, whole tables)
| Table | Count |
|---|---|
| awards (max id) | 23,352 (30,099) |
| venues | 11,307 |
| price | **7,582** (guide_ingest **568**, with source_url **568**) |
| source_capture_ledger (max id) | **96** (**140**) |
| audit_log (max id) | **108,684** (**113,968**) |

## Done in this session
1. Start check: all counts matched the Oct 29 handoff (ledger 139, audit 113,410).
2. Population options read and shown (whole `price` table, Michelin star/Bib base set 7,726 venues, active 7,639):
   P1 no price row 714 (active 711, active with card URL 560); P2a legacy michelin no URL 5,385 (active 5,326);
   P2b legacy no publisher no URL 1,617 (active 1,592). Ben chose the recommendation: P1 active with card URL (560).
3. Card read: built-in browser, one tab on guide.michelin.com, `fetch()` of each card URL with a 1.2 s pause, price
   parsed from raw HTML. 560 read: 558 clean; held 2 (Terra `ve_89ca903ac2` card 404; La Torre One Fire
   `ve_b5a5b44c26` card URL redirects from a Piemonte path to a Campania path). All 558 cards still show a star or Bib.
4. Write (Ben "go", Oct 30 00:24 ET), Write connector, one transaction, all guards and post-checks passed:
   - 558 INSERT into `price`: source guide_ingest, method published_symbol, publisher michelin, source_url = card URL,
     symbol_raw = card symbol, currency from card country, tier = symbol count, confidence NULL, captured_at = read time.
   - Currencies: CNY 188, EUR 224, GBP 6, JPY 17, KRW 1, TWD 68, USD 54. Tiers: 1 = 113, 2 = 185, 3 = 73, 4 = 187.
   - Ledger **140**: michelin, price, 558, job `price-card:price-michelin-card-p1-2026-10-30 | …`.
   - Audit **113,411–113,968** (558, all price INSERT).
   - Samples checked: The Hall ¥¥¥¥ CNY 4, Summerland $$ USD 2, Guy Savoy €€€€ EUR 4, Mume $$$ TWD 3, ARP ₩ KRW 1,
     La Table de Christophe Dufossé €€€€ EUR 4.
   - The Hall (¥¥¥¥) carried item is closed.

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p1-2026-10-30.sql` | `31f8e287197cbdf19928e15560cdf988ea424d85ad2c5647083f2d12eb97a2ea` | project `claude/` |
| `price-michelin-card-p1-relay-2026-10-30.txt` (558 lines, no final newline) | `7f22474a25dc9d78bbc480e1ab4b76d356304e0f69dbc73d3e2b4275325fdc1f` | project `claude/` |
| this handoff | (see repo commit) | project `claude/` |

**NOT in the repo yet.** The session could read the repo but could not push (GH_TOKEN invalid; `add_repo` with push
access was refused by the permission check). Next session: attach the repo with push access, copy the three files from
the project (`project_read`) into `docs/`, check each sha256, commit, push, fresh clone, check again.

## Methods learned this session
- **Card price from raw HTML** (no page render needed): `fetch(url, {credentials:'omit'})` from a guide.michelin.com tab.
  Symbol: regex `label">\s*Price:\s*</div>\s*<div class="data-sheet__block--text">\s*([^<]*?)\s*</div>`.
  Also in the page: `dLayer['price'] = 'CAT_P0n'` (n = symbol count), `dLayer['distinction']` (`bib`, `1 star`…),
  `dLayer['restaurant_country']` (ISO-2). JSON-LD `priceRange` is text ("A moderate spend"), not the symbol.
- Card symbols by country: $ (us, tw), ¥ (cn, jp), € (eu, mc), £ (gb), ₩ (kr). Taiwan "$" stored as TWD.
- The script loop runs about 1.3 s per card while the browser pane shows; slower when the pane is hidden.
  `javascript_tool` times out at 45 s, so poll the loop with waits of 40 s or less.
- Compare `decodeURI(response.url)` with `decodeURI(card URL)`: a percent-encoded é is not a redirect.
- **Relay inside the SQL:** the SQL holds the relay text as `$r$…$r$`, checks its sha256 against the browser hash,
  then builds the rows in SQL; a Python fingerprint (md5) cross-checks the SQL build. This halves the file size
  (75 KB for 558 rows) against a JSON literal.
- Legacy price rows store "$"-normalized symbols and no currency. Card rows store the real symbol and an ISO currency.

## Open items from this block
- Terra (Fisterra) `ve_89ca903ac2`: card 404. Status check needed (closed or left the guide?).
- La Torre One Fire `ve_b5a5b44c26`: Michelin card moved from `piemonte/annunziata` to `campania/santa-maria-annunziata`
  (same card id 139632). Check the venue city and the award source_url.
- P1 rest: 151 active venues with no price row and no card URL; 3 non-active.

## Next steps (new session)
1. Fresh read of the counts above. Ledger 140, audit 113,968. If anything moved, stop and tell Ben.
2. Commit the three files to the repo `docs/` (method above) and report the sha256.
3. Block A step 2 (Ben picks): P1 rest (151, card search by name first), or P2a/P2b one guide at a time
   (UPDATE of legacy price rows, with a diff list legacy symbol vs card symbol before "go").

## Carried open items
Beijing & Tianjin after Nov 1; Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7); telleruide slug;
apostrophe policy; Nadair (Atlanta) possibly closed; Florida 2026 Green Stars article not found; La Table – Christophe
Hay merge candidate (`ve_dd6de25c33` / `ve_3e461fe576`); 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-price-card-p1-done-2026-10-30.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
ledger 140 and audit_log 113,968. Then commit the three block A files to the repo docs/ and report the sha256.
Then show me the options for block A step 2 in /ste style. No write before my go.
```
