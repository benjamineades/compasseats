# Handoff: closed-venue sweep, twins and moved venues done. 2 merges, 2 renames. Nov 2, 2026 (14:45 Atlanta).

This file replaces `handoff-closed-sweep-201-done-2026-11-02.md` for live state. That file still holds the sweep groups, the population and the other open items. The closed rule and the older recheck list are in `handoff-closed-rule-done-2026-11-02.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 2)
- 14:29 "1A, 2A, 3A, 4A, 5A, 6A, 7A, 8A, 9A".
  - 1A = Chesa Stüva Colani - Ristorante: no merge, the rename and status go in the Swiss batch.
  - 2A = merge Hotel Tannenhof into Gourmetrestaurant Tannenhof, survivor active.
  - 3A = merge Baumanière 1850 into Slalom 1850, name stays Slalom 1850.
  - 4A = ACiD brianza: no merge, closed, recheck.
  - 5A = Wagyumafia (Tokyo): no merge, closed, recheck.
  - 6A = rename to Azabu-Juban Kitafuku, active.
  - 7A = rename to Revolution Wine Bistro, active.
  - 8A = 花小路さわ田: closed, recheck.
  - 9A = WAGYUMAFIA DISTRICT: active, recheck, no write.
- 14:35 "Go". 14:41 "Ran" (SQL Editor).

## Live state (read Nov 2, 19:41:59 UTC, whole tables)
| Table | Count |
|---|---|
| venues | 11,294 (active **10,990**, closed **304**) |
| closed venues published / not published | **0 / 304** |
| active venues not published | 0 |
| awards | 25,097 |
| slugs | 13,019 (canonical 11,294, non-canonical 1,725) |
| price | 7,727 |
| listings / cities | 11,294 / 3,264 |
| city_label_source | 23,989 |
| cities.venues_count | sum **10,990**; 0 cities differ from the view |
| rename_batches / rename_rows | 27 (last id 42) / 1,298 |
| source_capture_ledger | 185 rows, last id **237** |
| audit_log | **118,806** rows, last id **124,320** |

## Done
`docs/fix-closed-sweep-merge-rename-2026-11-02.sql` (sha256 `d20c666b...4bd92`). One transaction. Write connector cancelled 2 calls in 0.6 s (nothing ran). Ben ran the file in the SQL Editor, committed 19:41:19 UTC. Ledger 235-237, audit 124,291-124,320. Rename batch 42 `rename-closed-sweep-moved-2-2026-11-02`. Run record `docs/closed-sweep-2026-11-02/run-merge-rename-2026-11-02.txt`. The file header holds the evidence.

| Change | Venue | Result |
|---|---|---|
| Merge | Hotel Tannenhof `ve_aed4b4a9f3` into Gourmetrestaurant Tannenhof `ve_bd408ea3c3` | Active, published. Awards 18532 (OAD), 18533 (La Liste) moved. Label 18030 moved, 2 labels deleted. Old slug non-canonical. |
| Merge | Baumanière 1850 `ve_070ced1e07` into Slalom 1850 `ve_5f98076100` | Awards 1824 (Michelin 2025), 1825 (La Liste) moved. Legacy price and 2 labels deleted. Old slug non-canonical. |
| Rename | Katsukani Ryōri Akasaka Kitafuku to Azabu-Juban Kitafuku `ve_af6c894a24` | Native 麻布十番 きた福. Active, published. Tokyo 594. |
| Rename | Wine RVLT to Revolution Wine Bistro `ve_7e3068bc36` | Active, published. Singapore 205. |

Known limits:
- Tannenhof awards 18532 and 18533 have no URL. The link rests on hotel and town. The site gives no winter dates. Active under the seasonal rule.
- Michelin 2026 article and the hotel link use Baumanière 1850. The Michelin Slalom card and Courchevel tourism use Slalom 1850. Both Michelin cards are live.
- Revolution site title and logo write "Revolution". The body writes "Revolution wine bistro". Ben chose Revolution Wine Bistro.
- Kitafuku: source is the TableCheck booking page, recorded as `venue`. Own site not found. The Tabelog page for the new site did not open.

## Rechecks added (no write)
- ACiD brianza `ve_d230b9d155`: closed. Card and listing only (Ben's 2A of the sweep). A separate restaurant from Brianza `ve_d2804e9715`: OAD ranks both in 2025 (No. 593, No. 384). Savor Japan calls ACiD an extension of La Brianza. The group also has BRIANZA TOKYO and DepTH brianza, so the OAD "Brianza" row is not proved to be La Brianza.
- Wagyumafia `ve_024995c746` (Tokyo): closed. Loaded as "WAGYUMAFIA Hong Kong" in Tokyo, renamed Sep 9. OAD 2025 No. 346 has no address. Non-canonical slug `tokyo/wagyumafia-hong-kong` remains. Hong Kong has its own active venue `ve_d043456f0b`.
- WAGYUMAFIA DISTRICT `ve_13801fdc06`: active. The company list has no venue named DISTRICT. Its address 3-7-4 Jingumae now shows YAKINIKUMAFIA, The Burger and Teppan Private Room. Status or rename question.
- 花小路さわ田 `ve_f17195ac4b`: closed. One undated jpneazy page: moved Jul 6, 2025, now つぼつぼ（花小路さわ田）, Miyanomori 3-jo 10-chome 3-3. Old address matches Gurunavi. Needs a second source. Possible rename Tsubo Tsubo, native つぼつぼ. Slug is the machine slug `sapporo-sdi424`.

## For the Swiss batch
Chesa Stüva Colani - Ristorante `ve_8f85789bec` is Colani Bistrot (Michelin Bib card `graubunden/madulain/restaurant/colani-bistrot`, €€). It is a separate restaurant from the One Star Chesa Stuva Colani `ve_388aeca5ca`. The sweep CSV evidence for this row holds the gourmet dates. Bistro dates: Nov 27, 2026 to Apr 3, 2027 (hotelchesacolani.com). Michelin gives Via Principela 20; Foodle gives 25. Rename and status go in the Swiss status file. Switzerland still waits for Ben's "results live".

## Found, no change made
Austria holds 158 Michelin rows, all 2025, no URL (read Nov 2). The Gourmetrestaurant Tannenhof card shows the 2026 guide. No Austria 2026 batch is loaded.

## Open items from the sweep (still open)
Numbers refer to `handoff-closed-sweep-201-done-2026-11-02.md`. Item 1 and item 2 are closed by this file.
- Item 3: Scalottas Terroir, Suetomi, tsushimi, Grill at Amangani.
- Item 4: possible missing Michelin rows (Hakusi, Schlossherrnstube, Flora, CUR8, Kinship, Mural Farmhouse).
- Item 5: names (Paznauerstube, Eat and Cook, Amal Restaurant, Flora, Restavracija Lesnika).
- Item 6: rest of the sweep. 103 venues (51 last award 2020-2024, 52 before 2020), plus the 21 closed venues the flip did not change. 4 of the 21 hold a 2025 award: Hacha Agaveria, Double Deuce Lounge, A Bar Called Gemma, Little Cooler.
- Item 7: 17 temporary closures on the recheck list.
Group 3 (34 venues active on undated evidence) stays the weakest evidence of the 63.

## Methods (new)
- **Write connector:** a third file with DELETE was cancelled in 0.6 s, 2 calls. UPDATE and INSERT files ran today. Retry once, read to prove no change, then SQL Editor. Do not change a file to avoid the confirmation.
- **One file for merges and renames:** one transaction, ids not gated in ledger or audit (a failed run uses sequence numbers), counts and audit-by-table gated.
- **Rename rows with no publisher:** `source_id` = `venue`, no ledger row, as `scripts/rename/apply.ts`.
- **Repo stop check:** it asks for a commit of untracked files before the run. Commit to a branch and push. Merge after the run.
- **Twin read:** read the audit rows of each venue. The Wagyumafia load name came from `audit_log`, not from the live row.

## Suggested opening prompt
```
Read claude/handoff-closed-sweep-twins-renames-done-2026-11-02.md from the project files, then
claude/handoff-closed-sweep-201-done-2026-11-02.md for the sweep groups and open items,
claude/handoff-closed-rule-done-2026-11-02.md for the closed rule and recheck list and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm ledger 237,
audit_log 124,320, venues 11,294 (active 10,990, closed 304), awards 25,097, slugs 13,019, price 7,727, closed published 0 and cities.venues_count sum 10,990.
Then start item 6, the rest of the closed-venue sweep: first the 21 closed venues the flip did not change, with the 4 that hold a 2025 award first,
then read the 103 venues with an older last award. Show me in /ste style the status evidence for each group and the venues to set active.
Ask me any question the plan does not decide.
No write before my go. Attach the compasseats repo with push access for the commit after any write.
```
