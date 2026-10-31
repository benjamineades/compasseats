# Handoff: Open items block 5 done (undo.ts text, held-P2 items: Telese display, 4 city moves, 15 left-the-guide closed). Oct 31, 2026 (00:55 Atlanta). Next: Ben chooses.

This file replaces `handoff-open-items-b4-done-2026-10-31.md` for live state and open items. Rules R1-R5:
`handoff-name-diffs-read-2026-10-30.md`. Rule R6 and the Telluride city method: `handoff-open-items-b1-done-2026-10-30.md`.
Turkey city rule (D7, Michelin city): `handoff-open-items-b2-done-2026-10-30.md` (now also outside Turkey, see D3 below).
Held-P2 record (the 27 held cards, Oct 30): `handoff-price-card-p2-held-done-2026-10-30.md`.
Working rules and database notes: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (Oct 31, 2026, ET)
- 00:15: fresh count read, next-block options, repo with push access.
- 00:18 "1&2": item 1 (undo.ts text) and item 2 (held-P2 items) as one block.
- 00:21 "Go with your recommendations": D1-D4 = A (see Decisions).
- 00:30 "Go" (file 1, Write connector). 00:43 "Try running the connector" (file 2: the prompt closed by itself after 0.5 s,
  nothing ran). 00:53 "Ran it" (file 2, Supabase SQL Editor).

## Decisions (Ben, Oct 31 00:21 ET, all A)
- D1 Commit the undo.ts text fix.
- D2 Telese -> **Telese Terme**, display name only; slug `telese` stays (as Waiheke Island).
- D3 **Michelin city rule (D7 = the city in the card URL) now applies outside Turkey too.** 4 venues moved; 3 new cities;
  3 empty cities deleted; alias only for a place inside the new city (las caletas), none for separate towns (Prato, Sanluri);
  `venues_count` kept equal to the view `city_venue_counts` in the same file.
- D4 The 15 P2 venues that left the guide: no write, item closed (Oct 30 decision 3 stands: active, legacy price kept).
  Venues: Jing, Ladychai (Beijing); Sticky Fingers; El Espejo; La Chebaudière; Hyacinthe & Robert; Le Bel'Art; Fleur de Sel;
  Bonnie; La Petite Chartreuse; BOX-E; Impronte; Nole Ristorante; Ristorante Santa Elisabetta; TOKi.

## Live state (read Oct 31, 04:54:02 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,303 (active 10,934, closed 369) |
| awards | 23,362 |
| price | 7,731 (legacy_guide 2,558) |
| slugs | **12,940** (canonical 11,303, non-canonical **1,637**); venues with other than 1 canonical slug: 0 |
| listings | 11,303 |
| cities / city_aliases / redirects | 3,259 / **266** / 9 |
| city_label_source | 24,003 |
| source_capture_ledger | last id 172 (no ledger row in this block) |
| audit_log | **114,109** rows, last id **119,393** |
| cities.venues_count | sum 10,934; cities that differ from the view: **0** |

## Done in this session
1. Start check 04:15 UTC: all b4 counts matched (ledger 172, audit 119,371, price 7,731 / legacy 2,558, venues 11,303,
   venues_count sum 10,934, 0 differ). Repo attached with push access (clone `9cd4e79`).
2. **Item 1:** `scripts/ingest/undo.ts` line 552 (the only copy of the wrong text): the report now says that
   `cities.venues_count` is a stored copy with no refresh job, and points to the view `city_venue_counts`. Commit `13a106f`.
3. **Item 2 reads.** Fresh read of the 21 held-P2 venues: all active. Built-in browser and Chrome both offline; the 6 city
   cards were read by WebFetch (all 2026 awards on the cards agree with our rows):
   Krèsios "Via San Giovanni 59, Telese Terme"; La Locanda del Borgo "Località Monte Pugliano 1, Telese Terme";
   Paca "Via delle Ginestre 45, Carmignano"; Torre del Saracino "Piazza della Vittoria 5, Sorrento"; Coxinendi "Viale del
   Golfo di Quartu 25, Quartu sant'Elena"; El Jardín de la Sal "Carretera La Costa-El Faro 5, Fuencaliente de la Palma".
   Torre del Saracino and Coxinendi: the card address is in a different town (probably a relocation).
4. Build by script `docs/open-items-b5-build/build_open_items_b5_2026_10_31.py` from `relay.txt` (planned values; md5 gates
   from the read). pglast OK. File 1 dry run (Read connector) stopped at the UPDATE. File 2 pre-check test (today's audit id)
   stopped at the first INSERT; a read after showed no id used. Repo commit `21d5bdf` (built, not run).
5. **File 1** (Write connector, first try, 04:30:28 UTC): audit **119,372**: cities UPDATE `ci_845e30f4ce`
   Telese -> Telese Terme (display only).
6. **File 2**: Write connector prompt closed by itself (0.5 s; nothing ran, checked by read 04:44:50 UTC). Ben ran it in the
   SQL Editor (04:53:16 UTC). Audit **119,373-119,393** (21): cities INSERT 3, venues UPDATE 4 (city_id only), slugs UPDATE 4 +
   INSERT 4, cities UPDATE 2 (venues_count only: Sorrento 5 -> 6, Vico Equense 2 -> 1), cities DELETE 3, city_aliases INSERT 1
   (hand row). No ledger row. Read-back matched every planned value.

## Results
| Venue | City before | City now | Canonical slug now |
|---|---|---|---|
| Paca Ristorante `ve_542c195114` | Prato | Carmignano `ci_6480e34f4d` (new) | carmignano/paca-ristorante |
| Torre del Saracino `ve_69e1e106b5` | Vico Equense | Sorrento `ci_25a0f29d02` | sorrento/torre-del-saracino |
| Coxinendi - Ristorante `ve_eef796a74d` | Sanluri | Quartu Sant'Elena `ci_cef88d0e62` (new) | quartu-sant-elena/coxinendi-ristorante |
| Restaurante Temático El Jardín de la Sal `ve_e50adc624d` | Las Caletas | Fuencaliente de la Palma `ci_06496b916c` (new) | fuencaliente-de-la-palma/restaurante-tematico-el-jardin-de-la-sal |

- New cities copy country, kind and region from the old city; lat/lng NULL (as Fethiye).
- Deleted cities: Prato `ci_c02c36007b`, Sanluri `ci_d59e7dd97f`, Las Caletas `ci_b52d606d20` (full old rows in audit).
  Old slugs stay as non-canonical rows (old URLs keep working), including prato/paca and sanluri/coxinendi.
- Alias `las caletas` -> Fuencaliente de la Palma. The labels "Prato" and "Sanluri" now resolve to no city.
- Telese Terme `ci_845e30f4ce` keeps slug `telese` and 2 venues. Vico Equense keeps Antica Osteria Nonna Rosa.

## Methods that worked (new)
- **venues_count in a city-move file:** update the stored count of each existing source/target city in the same transaction
  (gate: old value = live active count; post: 0 cities differ from `city_venue_counts`, sum unchanged). A new city is
  inserted with its count. Each update adds a cities UPDATE audit row (venues_count only).
- **jsonb plan constants** in the DO block (`jsonb_to_recordset`) in place of repeated VALUES lists: shorter file, one source.
- **Browsers offline:** WebFetch reads Michelin card address lines (one approval per page).
- **Write connector and DELETE:** closed by itself again (3rd file). For a file with a DELETE, go to the SQL Editor first.

## Files
| File | Status | sha256 |
|---|---|---|
| `scripts/ingest/undo.ts` | Committed `13a106f` | - |
| `docs/cities-display-telese-terme-2026-10-31.sql` (90 lines) | Run (audit 119,372) | `e51ca728fd03985f7ab520d2b34052bb343929486841da38e421594674ddc59c` |
| `docs/cities-held-p2-michelin-city-2026-10-31.sql` (243 lines) | Run in SQL Editor (audit 119,373-119,393) | `56c6a5ff3f52cc5b8d8c863270581ffe96592d26ddef551d27624597b9c17373` |
| `docs/open-items-b5-build/relay.txt` (23 lines, no final newline) | Input | `f266ea0ed5133a5f4d95cfec70a94827fab8a130cda791cab5179a08f19742bb` |
| `docs/open-items-b5-build/build_open_items_b5_2026_10_31.py` | Build | `deff96936ec3e6873dcbde5356c9c2c0cc0db92b5c5c3afb189bfa90e356fa18` |
| this handoff | project `claude/`, repo `docs/` | - |

## Open items, smallest first
1. **New: 4 name differences against the card** (R1-R5 name batch): Kresios (card Krèsios), Paca Ristorante (card Paca),
   Coxinendi - Ristorante (card Coxinendi), Restaurante Temático El Jardín de la Sal (card El Jardín de la Sal). Read each
   venue's own site first (R1-R5).
2. Merge and award cleanup: La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on
   closed venues; Miura / Beverly Hills city policy; Duddell's (Hong Kong) possible duplicate `ve_a3512f9a51` /
   `ve_f88a5d9dc2`; Terra (Fisterra) `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved.
3. Best Chef source URLs: 2024 519 rows (1 with URL; the 2024 list PDF covers all); 2025 781 rows (0 with URL; the 2025
   list was not readable). Also check that each 2024/2025 row pairs to a list entry.
4. 2025 Green Star backfill, all guides (California 2025: 13 of 17 missing). Ben decides how far back before a history
   backfill is scoped.
5. 2025 Michelin URLs, all guides (about 3,461 rows without a URL).
6. Date gates: Switzerland after Nov 2; Italy 2027 and the Café Spice Namasté / Unforgettable rechecks after Nov 12;
   Fujian 2027 late Nov; Spain 2027 Dec 1; Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027;
   Belgium & Luxembourg 2027 spring 2027; American Great Lakes Apr 21, 2027; Germany 2027 and GB&I 2027 dates not found;
   Florida 2026 Green Stars article not found; Turkey 2027 edition (check the unknown 2026 Bib then).
7. Telluride: 221 South Oak reopens 12/11 (seasonal); no action unless the site shows otherwise.
8. Legacy price rows outside Turkey: 2,558 (scope when Ben asks).

## Suggested opening prompt
```
Read claude/handoff-open-items-b5-done-2026-10-31.md from the project files, then claude/handoff-name-diffs-read-2026-10-30.md
for rules R1-R5, claude/handoff-open-items-b1-done-2026-10-30.md for rule R6, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 172,
audit_log 119,393, cities 3,259, city_aliases 266, slugs 12,940 and cities.venues_count sum 10,934. Then show me the
next-block options in /ste style (the open items, smallest first, with what each needs from me) and wait for my choice.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
