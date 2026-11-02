# Handoff: Italy 2026 status and gap done (open items 2-3). Nov 2, 2026 (07:30 Atlanta).

This file replaces `handoff-it-2026-fixes-done-2026-11-02.md` for live state and open items. That handoff still holds the article parse notes.
Italy 2025 methods: `handoff-it-2025-backfill-done-2026-11-02.md`. Rules R1-R5: `handoff-name-diffs-read-2026-10-30.md`. Rule R6: `handoff-open-items-b1-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`. D8 method: `handoff-hkmo-2025-backfill-done-2026-11-01.md`.
Card-link method: `handoff-gbi-2025-backfill-done-2026-11-01.md`. Selection-page method and heredoc trap: the Japan handoff.

## Ben's input (ET, Nov 2)
- 07:22 "S1, G1, V2": S1 = 5 closed venues to active, Octavin and Atman to closed, 3 stay closed; G1 = 2026 rows for Octavin and Atman; V2 = new venue for Agli Amici Dopolavoro only, the other 7 restaurants get no venue, gap of 7 stays on record.
- 07:26 "Go". Committed.

## Live state (read Nov 2, 12:27:52 UTC, whole tables)
| Table | Count |
|---|---|
| venues | **11,301** (active **10,938**, closed **363**) |
| awards | **25,085** (last id **32,024**); Michelin **11,381**; Michelin 2026 **6,283** |
| IT Michelin One Star 2026 | **334** (article 341, gap 7 by decision) |
| slugs | **13,005** (non-canonical 1,704) |
| listings / blurbs | **11,301** / 142 |
| price | 7,734 |
| source_capture_ledger | **169** rows, last id **221** |
| audit_log | **118,063** rows, last id **123,577** |
| cities / venues_count | 3,262 / sum **10,938** |
| city_aliases / city_label_source | 266 / **24,001** |

## Done in this session
1. Start check: all counts = the fixes handoff. Repo attached with push access (clone `18768df`).
2. Live Michelin read (built-in browser): Italy One Star 326, Two Stars 37, Three Stars 14. 15 One Star cards left the list after the article (341).
3. **Run:** `docs/fix-michelin-2026-italy-status-gap.sql` (sha256 `2ebb207d...e079eac8`). Status to active: Atelier `ve_41b4987ce8`, La Stua de Michil `ve_4397691f95`, La Trattoria `ve_28f49a1d8b`, Stube Hermitage `ve_f19d2083ac`, Suinsom `ve_52ff3a77a0`. Status to closed: Octavin `ve_df6d5db906`, Atman `ve_48fe5153e8`. New venue Agli Amici Dopolavoro `ve_5025ee0810` (Venice, active, published, no price). Awards 32022-32024. City counts 8. Ledger **221**. Audit **123,555-123,577**. Run record `docs/it-2026-build/run-fix-it-2026-status-2026-11-02.txt`.

## Evidence for the 7 restaurants with no venue (V2, no write)
- Don Alfonso 1890 San Barbato: closed, announced Mar 30, 2026 (scattidigusto.it).
- Il Circolino: paused Jan 27, 2026, reopening not confirmed (primamonza.it, dissapore.com). A Jun 7 site capture shows hours. Conflict: recheck.
- Sedicesimo Secolo: last service Feb 14, 2026 (italiaatavola.net).
- Gabbiano 3.0: closed, Mar 26 report; team to Barbagianni, Colle Val d'Elsa (ilforchettiere.it, iltirreno.it).
- Castello di Fighine: own post "definitivamente chiuso", May 1 report (scattidigusto.it).
- Palais Royal Restaurant: closing, one source, Mar 2 (dissapore.com). Card 404.
- Matteo Grandi in Basilica: sold to Signorvino, Mar 23 (italiaatavola.net).

## Methods and notes (new)
- Live selection pages: `/us/en/selection/italy/restaurants/1-star-michelin/page/N`. Each page adds 4 cards from outside the list (US cards appeared). Use the page header for the count, not the number of links.
- Compare the live list with the relay in the browser: `raw.githubusercontent.com` allows the fetch from a guide.michelin.com tab. Same-card test by path gives false misses when Michelin moved the city in the path (Paca, Il Patio, Il Falconiere, Assonica).
- A word test on a whole card gives false hits: "PLEASE NOTE" is in the card template. Remove script and style, then look for "temporarily closed". Test a control card (Piazza Duomo).
- WebFetch on a restaurant's own site can need an approval that times out. Use `https://web.archive.org/web/2026id_/<site>` in the browser. A date stamp with 2026 returns the nearest capture, which can be from 2025: read the timestamp in `response.url` from the robots.txt tab.
- `city_label_source` has no audit trigger; hand audit in the same statement with `WITH ins AS (INSERT ... RETURNING *) INSERT INTO audit_log ...`.

## Open items, smallest first
1. Forum on the live site (Sheet / `ImportOptionB.gs` still old text; changes at the Supabase swap or an `importOptionB` run).
2. **Italy rechecks (status):** Wood `ve_b935a2a19a` (card "temporarily closed"), Peter Brunel `ve_dbe27febdc` (car crash May 2026, reopening planned September, card 404), Quattro Passi `ve_ee9dbbdba9` (new site late 2026 to spring 2027), Il Circolino (no venue). After Nov 12 with the Italy 2027 list.
3. Off the live list, status active, closure not checked: Unforgettable `ve_a006de1bf7`, Impronte `ve_6c4d801f2f`, Santa Elisabetta `ve_e1339c5391` (Two Stars). Status check.
4. Agli Amici Dopolavoro `ve_5025ee0810`: open by press, card 404. Check the 2027 list.
5. Awards 23050 (Quattro Passi) and 23198 (Peter Brunel) hold card URLs that now give 404. No change made.
6. Italy name pairs with a different spelling: Assonica (Osteria degli Assonica), Ristorante Il Desco, Iris Ristorante a Palazzo Soave, Ristorante San Martino, Ristorante Atman. Rename check under the Sep 14 / Oct 10 rulings.
7. Closed venues with `listings.published = true`: all Italy closed venues are published, incl. Contaminazioni, Lido 84, Octavin, Atman. No change made. Ben to decide if needed.
8. Lido 84 city: database Gardone Riviera (own site, press); card Fasano del Garda. No change made.
9. **Japan 2025 missing sets (J1):** as in the Japan handoff item 2.
10. Japan legacy 2025 rows (10 left, no URL): cleanup list (Japan handoff item 3).
11. `ve_c0eba7ae71` "Naramachi Historic District" = Naramachi Kuko. Rename check.
12. **2025 Green Stars:** Spain (G1), France (U3), Italy (G1). No full list. Try new captures later.
13. Spain venue names that are a city name: BACK -> "Marbella" `ve_f29878f198`; Europa -> "Pamplona" `ve_c18fc53635`.
14. Spain card-paired venues with status closed but a 2026 One Star: SLOW&LOW `ve_18248f03f5`, Terra `ve_89ca903ac2`.
15. Moved restaurants (Y pairs, Spain): no action unless Ben wants a "previous location" note.
16. `ve_4e77c0295c` L'Auberge de Saint-Remy: city "Saint-Remy"; Michelin Saint-Remy-de-Provence.
17. Venues named after a hotel (France card pairs): France handoff item 4.
18. 2026 Green Star gap: Germany and the Netherlands 0 rows; France 11, Italy 2, Ireland 0; Japan 25 vs 33.
19. 2025 Green Star + URL backfill: Vietnam (70 rows, 68 no URL), China (49), US (690). D8 method.
20. Le Manoir `ve_7b865a33b7`: hotel suffix in the name, city Oxford (Michelin: Great Milton).
21. Legacy price rows: 2,380 legacy_guide rows remain.
22. `name_native` backfill: China 469, Japan 585, Chengdu 47.
23. Blurb rewrites: 141 `needs_rewrite`.
24. Rechecks and date gates: as in the Spain handoff items 16-17 (Italy 2027 after Nov 12; Tokyo etc. after Feb 16, 2027).

## Suggested opening prompt
```
Read claude/handoff-it-2026-status-done-2026-11-02.md from the project files, then
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 221,
audit_log 123,577, venues 11,301, awards 25,085, slugs 13,005, price 7,734 and cities.venues_count sum 10,938.
Then work open items 3 and 6 (3 Italy venues off the live list, and the Italy name pairs). Examine read-only and
show me in /ste style. No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
