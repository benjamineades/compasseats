# Handoff: Block A step 2, held P2 cards done (9 updated, 1 closed, 17 kept). Oct 30, 2026. Next: P1 rest (151).

This file replaces `handoff-price-card-p2-b10-done-2026-10-30.md` for live state and next steps. That file and the
b1 to b9 handoffs still hold batches 1 to 10. `handoff-price-card-p2-brief-2026-10-30.md` holds the P2 definition and
method. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read method. The working rules in
`handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule still apply.

## Ben's decisions (Oct 30, 2026, "agree" 12:56 ET)
1. Held cards with a new card path: one file that updates the award `source_url` and the price row together.
2. Held cards with closure news: close in a separate file after the price file; hold Unforgettable (temporary).
   Claude also held Café Spice Namasté: the Oct 28, 2026 report calls it "temporarily closed" (see below).
3. Held cards that left the guide with no closure evidence: no write. They stay active with the legacy price.
4. Carry as open items: 5 city changes shown on the card, 3 name differences.
Ben "go" file 1 (13:01 ET), "go" file 2 (13:06 ET).

## Live state (read Oct 30, 17:07 UTC, whole tables, after both commits)
| Table | Count |
|---|---|
| price | **7,582** (guide_ingest **4,983**, legacy_guide **2,599**) |
| venues | 11,307 (active **10,939**, closed **368**) |
| awards | 23,352 |
| source_capture_ledger (max id) | **152** |
| audit_log (max id) | **118,393** |
| P2 remaining (active) | **17** (15 left the guide, 2 temporary closures; list below) |

## Done in this session
1. Start check (16:48 UTC): price 7,582 (guide_ingest 4,974, legacy_guide 2,608), ledger 150, audit 118,374. All
   matched. Repo attached with push access, clone at `84524a1`.
2. Held list read from the database: 27 (CN 2, DE 1, ES 3, FR 7, GB 2, IT 10, JP 2). Population: active venue, latest
   Michelin star/Bib card URL, legacy price row with no URL.
3. Card read (built-in browser, `fetch()`, 1.2 s pause): 6 redirect to a new path (200); 21 give 404.
4. City-list read for the 21: full current city list on guide.michelin.com, all pages (`/<region>/<city>/restaurants`
   and `/restaurants/page/N`, 48 per page; the `?q=` search does not filter on the server). French cities need the
   `/us/en/` prefix (the `/en/` city list gives 404). Kyoto page 6 once returned 202; a second fetch gave 200.
   Beijing list = 2027 edition (107). Matches: Andrea (Palazzolo Acreide, same address Via Padre Giacinto 20 as
   "Andrea - Sapori Montani"); UZU Kyoto (same address 146 Umenokicho as the shop's own page for Vegan Ramen UZU Kyoto);
   La P'tite Patte (Cholet; the card path has a curly apostrophe, our URL had a straight one).
5. Result: 9 new card path, 3 with closure news, 15 left the guide (no closure evidence in a web search).
6. File 1 `price-michelin-card-p2-held-moved-2026-10-30.sql` (13,969 bytes, sha256
   `c4d6447355811fe16da58a9a161e97c80ca83445141becd31be6659747e6b711`). Relay 9 lines, sha256
   `dd3a1706feeb9bb34a91d5a1e6944f7ffb9083c6d3f17c3f121f63db60cc5c88` (browser hash = file hash). Builder
   `build_price_moved_card_sql.py` (new). Syntax check (pglast 8.7) passed; dry run (Read connector, cut before the
   first UPDATE) passed. Write 17:02:06 UTC, all guards and post-checks passed:
   - 9 UPDATE of `awards.source_url` (ids 22682, 23079, 23083, 23258, 23350, 23588, 23667, 24729, 25629). Ledger **151**.
   - 9 UPDATE of `price` (EUR 8, JPY 1; tiers 1 = 1, 2 = 4, 4 = 4). Ledger **152**.
   - Audit **118,375–118,392**: awards UPDATE 9, price UPDATE 9.
   - Tier diff: 8 same, 1 up one step (Paca 3 → 4), 0 bigger.
   - Read-back: each price URL = award URL; symbols as the cards.
7. File 2 `status-close-slow-low-barcelona.sql` (5,587 bytes, sha256
   `948d9e0dc5543e511b9a2c461c86771d0bf0ea94224523121fd4e12bf3007d50`). SLOW&LOW `ve_18248f03f5` active → closed.
   Evidence: Time Out Barcelona (Sep 14, 2026) and Directo al Paladar (Sep 22, 2026), last service Oct 17, 2026; card
   404; not in the Barcelona list. Award 25603 (Michelin 2026 One Star) and the legacy price row stay as history.
   No ledger row (Regent precedent). Dry run stopped at the UPDATE. Write 17:07:21 UTC, audit **118,393**.

## The 9 new card paths (file 1)
| Venue | New path (after `https://guide.michelin.com/us/en/`) | Card |
|---|---|---|
| La Locanda del Borgo `ve_448903808c` | `campania/telese-terme_1850913/restaurant/la-locanda-del-borgo` | €€€€ 1 star |
| Paca Ristorante `ve_542c195114` | `toscana/carmignano_1833819/restaurant/paca` | €€€€ 1 star |
| Torre del Saracino `ve_69e1e106b5` | `campania/sorrento/restaurant/torre-del-saracino` | €€€€ 2 star |
| Andrea Ristorante - Enoteca `ve_6d2d60d7ba` | `sicilia/palazzolo-acreide/restaurant/andrea` | €€ Bib |
| Vegan Ramen UZU Kyoto `ve_bb69a63e96` | `kyoto-region/kyoto/restaurant/uzu-kyoto` | ¥¥ Bib |
| Maison Patte Noire… `ve_c4d70b9a92` | `pays-de-la-loire/cholet/restaurant/la-p%E2%80%99tite-patte` | €€ Bib |
| El Jardín de la Sal `ve_e50adc624d` | `canarias/fuencaliente-de-la-palma/restaurant/el-jardin-de-la-sal` | € Bib |
| Coxinendi - Ristorante `ve_eef796a74d` | `sardegna/quartu-sant-elena_1840763/restaurant/coxinendi` | €€ Bib |
| Kresios `ve_f558535881` | `campania/telese-terme_1850913/restaurant/kresios` | €€€€ 2 star |

## The 17 P2 venues that keep the legacy price (active)
- Left the guide, no closure evidence (15): Jing `ve_262d31b59b`, Ladychai `ve_8a5b0b0df3` (both not in Beijing 2027);
  Sticky Fingers `ve_f93b620329`; El Espejo `ve_6bdb3af7e7`; La Chebaudière `ve_4a55e63127`; Hyacinthe & Robert
  `ve_6d59eb76a1`; Le Bel'Art `ve_89439f5f35`; Fleur de Sel `ve_a8feaf520c`; Bonnie `ve_bf3dfbaca2`; La Petite Chartreuse
  `ve_dde2eb588c`; BOX-E `ve_c5a3f2e5bd`; Impronte `ve_6c4d801f2f`; Nole Ristorante `ve_ca6e409319`; Ristorante Santa
  Elisabetta `ve_e1339c5391`; TOKi `ve_434df13957`.
- Temporary closure, held (2):
  - Café Spice Namasté `ve_5911480108`: Restaurant Online, Oct 28, 2026: "temporarily closed", not a permanent
    goodbye, next venture not announced. Recheck later.
  - Unforgettable `ve_a006de1bf7`: Scatti di Gusto, Oct 13, 2026: closed since September after the chefs left; owners
    say it will reopen; Michelin listing removed. Recheck after the Italy 2027 edition (Nov 12).

## Method notes from this session
- Store a new card URL in Michelin's own link form (percent-encoded, as in the city-list `href`): the DB already holds
  13 percent-encoded award URLs against 4 non-ASCII ones.
- A held card is "new path" only with proof: a redirect from the old URL, or a city-list card with the same address.
  A similar name alone is not proof (Madame Toki and Tokihami are not TOKi).
- The award `source_url` and the price row change in one transaction, because the price guard needs card URL = latest
  award URL.
- A status-only close keeps award and price rows and adds no ledger row.

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p2-held-moved-2026-10-30.sql` | `c4d64473…47e6b711` | project `claude/`, repo `docs/` |
| `price-michelin-card-p2-held-moved-relay-2026-10-30.txt` (9 lines, no final newline) | `dd3a1706…60cc5c88` | project `claude/`, repo `docs/` |
| `build_price_moved_card_sql.py` (new) | (see repo commit) | project `claude/`, repo `docs/` |
| `status-close-slow-low-barcelona.sql` | `948d9e0d…3007d50` | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Open items
- **Next: P1 rest** (151 active venues with no price row and no card URL; name search needed). Read the count again.
- New from this session:
  - City changes shown on the card (venue city not changed): Telese → Telese Terme (La Locanda del Borgo, Kresios);
    Prato → Carmignano (Paca); Vico Equense → Sorrento (Torre del Saracino); Sanluri → Quartu Sant'Elena (Coxinendi);
    Las Caletas → Fuencaliente de la Palma (El Jardín de la Sal). Check each before any city move.
  - Name differences against the card: "Andrea Ristorante - Enoteca" vs "Andrea"; "Vegan Ramen UZU Kyoto" vs
    "UZU Kyoto"; "Maison Patte Noire "1 lieu, 2 restaurants"" vs "La P'tite Patte" (the same address also has
    "Le Patte Noire", Selected). Apply the Sep 14 / Oct 10 name rulings.
  - Rechecks: Café Spice Namasté (temporary closure); Unforgettable (temporary closure, after Nov 12).
- Carried: venue `ve_04c2784726` named "Lavello" (card is Forentum); Les Fresques name cleanup `ve_e574aeb7fd`; Terra
  (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov);
  Switzerland after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7); Spain 2027 edition Dec 1 (Huesca); Germany 2027
  edition in Frankfurt (date not found); GB&I 2027 edition (date not found); Northeast Cities after Dec 14; Tokyo /
  Kyoto-Osaka / Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027, date not found); American Great
  Lakes first edition Apr 21, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes)
  status; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge candidate; 7 unproven legacy
  special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-price-card-p2-held-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
price 7,582, ledger 152 and audit_log 118,393. Then start P1 rest: read the 151 active venues with no price row and
no card URL, and show me in /ste style how you will find each card (name search method, match proof) before any
browser run. No write before my go. Attach the compasseats repo with push access for the commit after the write.
```
