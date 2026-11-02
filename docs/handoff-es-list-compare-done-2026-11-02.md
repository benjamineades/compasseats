# Handoff: list compare done (open item 5). Spain 4 rows added, Simpar closed. Switzerland waits for Ben. Nov 2, 2026 (12:15 Atlanta).

This file replaces `handoff-switzerland-waiting-results-2026-11-02.md` and `handoff-open-items-rls-names-fr-closures-done-2026-11-02.md` for live state. Those files still hold the Swiss findings and the full open-item list, with the changes below. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 11:40 "1B, 2A, 3A, 4A, 5A" (Switzerland): Ben says when results are live; 9 closed venues on the list get a card and site read, then a status file; second card = new venue; Liechtenstein in the batch; Green Stars in a small file after the promote.
- 11:43 "Go" (open item 5). 11:46 "A" (compare list articles). 12:10 "1A, 2A, 3A" (add 4 Spain rows; hold 4 lines with no venue; Simpar to closed after a second source). 12:13 "Go".

## Live state (read Nov 2, 17:14:24 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,296 (active **10,920**, closed **376**) |
| awards | **25,096** (last id **32,039**); Michelin **11,392** |
| Spain + Andorra Michelin 2026 star rows | **303** (list 307) |
| slugs / price | 13,016 / 7,729 |
| source_capture_ledger | **179** rows, last id **231** |
| audit_log | **118,220** rows, last id **123,734** |
| cities.venues_count | sum **10,920**; 0 cities differ from the view |
| closed venues with `listings.published` true | **355** |

## Done
`docs/fix-es-2026-list-4-rows-simpar-closed-2026-11-02.sql` (sha256 `5c12edf4...7b90a02`). Write connector, first try. Run record `docs/list-compare-2026-11-02/run-es-list-4-2026-11-02.txt`.
- Michelin 2026 One Star rows 32036 Ricardo Sanz Wellington `ve_dffad438e0`, 32037 Santerra Restaurante `ve_a76b44705a`, 32038 Restaurante Simpar `ve_5cb5124e0b`, 32039 Teatro kitchen & bar `ve_6532e88951`. Source: list article. Ledger 231.
- Simpar closed (own site restaurantesimpar.com: closed, effective July 19; El Correo Gallego, URL date 2026/06/20). Santiago de Compostela 11 to 10. Audit 123,729-123,734.

## List compare (open item 5)
Population: venues with a Michelin 2025 star and no 2026 or 2027 star or Bib row: 796. 593 in 22 countries with 0 later star rows, 27 in HR/SI/PL, 127 US, 49 in countries with a 2026 batch plus Denmark (32 active, 17 closed).
Article lines vs database rows: Germany 339/339, Netherlands 119/119, GB+IE 220/221 (Loch Bay only in body text), Hong Kong 77/77, Macau 19/21 (header 13 One Stars, 11 lines), Taiwan 60/61 (Sushi An, header 49), Spain+Andorra 307/299. Only Spain had missing rows. Italy and France were compared earlier. Relay `docs/list-compare-2026-11-02/relay-star-list-articles-2026-11-02.txt`, script `cmp8.py`.
Not explained: Michelin press says 230 starred for GB+IE; list and database hold 221.
Single reads, no change: SEZANNE (stars removed, new team, new listing, SCMP); Noma (not in the 2026 guide, reopening Aug 5, 2026, Fortune).

## Open items, changes to the list
- Item 5: closed, except 18 active candidates not on their lists (Germany 11, Netherlands 3, UK 2, Hong Kong 1, Taiwan 1; Fleur de Sel already known as Selected). No row missing. Status not read.
- New, held with no venue (Spain 2026 One Star): SCAPAR (Barcelona; chef left, appears closed, Time Out Mar 2026), Erre de Roca (Miranda de Ebro; no closure found), Bens d'Avall (Soller; closed Mar 1 2026, new concept due Mar 2027), NM (Oviedo; permanent closure, Jan 2026).
- New recheck: Ricardo Sanz Wellington and Santerra (not on the live list, no closure found, only old pages read).
- Item 21 Switzerland: waits for Ben's "results live".

## Methods (new)
- Article parser: walk `.detail-page__content`, split at BR and block tags, keep `<<href>>`. A duplicate anchor can split one name (Bandol sur mer, SOLSTICE BY KENNY ATK + INSON): count unique URLs.
- The Netherlands list holds a stray Bib heading inside the One Star list: read to the end of the links.
- Taiwan, Hong Kong and Spain lines are mostly plain text. Spain: `City – Name [– NOVEDAD]`.
- Spain card path for guessing is not reliable. A guessed card 404 proves nothing.
- A repo stop check asks for a commit of untracked files: use a branch before a go, then merge after the run.

## Added Nov 2, 12:20 Atlanta: status read of the 18 candidates and 3 closures
Ben 12:15 "Go" (status read), 12:18 "1A, 2A" (close Nideggen and Hjem; Taku closed), 12:19 "Go".
`docs/fix-status-closed-3-nideggen-hjem-taku-2026-11-02.sql` (sha256 `93178c35...d367db`). Write connector, first try. Audit 123,735-123,740. No ledger row.
Closed: Burgrestaurant Nideggen `ve_3fede02a60` (Falstaff Aug 6 2026), Restaurant Hjem `ve_c905b58267` (Harden's Jul 10 2026), Taku `ve_4789a4e337` (Hot Dinners Feb 20 2026, now Sushi Amamoto; no venue for it unless it wins an award). Nideggen and Wall now have 0 active venues.
Live state after: venues 11,296 (active **10,917**, closed **379**); cities sum **10,917**; closed published **358**; audit_log **118,226** rows, last id **123,740**; ledger 231; awards 25,096.
Recheck, status unchanged (conflicting evidence): Hegel Eins `ve_cea4def219` (break since Dec 2025, card live), Sushi Saito `ve_a248207d2a` (card 404, Time Out lists hours, updated Sep 2026). Stay active, card live with first tag "plate" (Selected, read by tag only): Schattbuch, Bieberbau, Skykitchen, Carmelo Greco, Casala, Showroom, kochZIMMER, Roter Hahn, Le Frankenberg. Settled earlier: De Juwelier, Da Vinci, Sense, Fleur de Sel.
Note: `/us/en/greater-london/london/restaurant/taku` redirects to Taku in Cologne, so a card status check by a guessed path must compare the final URL.

## Added Nov 2, 12:32 Atlanta: Plaza Athénée merged (open item 3 closed)
Ben 12:24 "A", 12:28 "Go". `docs/merge-fr-plaza-athenee-2026-11-02.sql` (sha256 `99d33868...648898`). Write connector "cancelled" twice in about 0.5 s (nothing ran); Ben ran the file in the SQL Editor, committed 17:31:07 UTC. Ledger 232, audit 123,741-123,749.
Jean Imbert au Plaza Athénée `ve_36022e9b0a` merged into La Grande Table du Plaza Athénée `ve_ab17ada0da` (Yonder Sep 15 2026, same teams, new name). Survivor holds Gault-Millau 2023 (7234), Michelin 2025 (7233), Michelin 2026 (22238). Old slug `paris/jean-imbert-au-plaza-athenee` is non-canonical on the survivor. Legacy price deleted.
Live state after (read 17:31:23 UTC, whole tables): venues **11,295** (active **10,916**, closed 379); awards 25,096; slugs 13,016 (non-canonical **1,721**); price **7,728**; listings **11,295**; city labels **23,991**; cities sum **10,916** (0 differ); closed published 358; ledger **180** rows, last id **232**; audit_log **118,235** rows, last id **123,749**.
Note: the connector accepted status and INSERT files today and cancelled the file with DELETE statements. Cause not known. A file with DELETE can go to the SQL Editor after one retry.
