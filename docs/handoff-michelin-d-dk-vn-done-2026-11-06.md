# Handoff: Michelin group D Denmark and Vietnam written. Group D is done. Nov 6, 2026 (19:45 Atlanta). Next: Gault & Millau France and Monaco 2027 (after Nov 9), then Thailand 2027 (after Nov 10).

This file replaces `handoff-michelin-d-no-se-done-2026-11-06.md` for the live state, group D and the open items. That file still holds the Norway and Sweden record. `handoff-michelin-d-th-fi-lt-done-2026-11-06.md` holds the Thailand, Finland and Lithuania record. `handoff-michelin-d1-done-2026-11-06.md` holds the D1 record and the card label table. `handoff-michelin-a2-a3-b-e-done-2026-11-06.md` holds the hold register, the card-left-the-site rule, the methods and the dead ends, plus the Gault & Millau opening prompt. Launch list: `launch-list-2026-11-05.md`. Working rules: `handoff-chengdu-held-7-cleanup-done-2026-10-04.md`.

## Ben's input (ET, Nov 6)
- Denmark: 17:55 "1-5: A" and "Regarding 3: Confirmed Noma is currently open". 18:17 "Go".
- Vietnam: 19:41 "1-5: A". 19:43 "Go".

## Live state (read Nov 7, 00:44 UTC, after the last write, whole tables)
Venues **11,831** (active **11,510**, closed **321**). Awards **29,052** (last id 36,223). Michelin 2025 / 2026 / 2027 rows 4,179 / 7,821 / 311. OAD 2026 rows 2,859. OAD 2025 rows 2,437. Slugs 13,775. Price 7,759. city_aliases 222. Redirects 35. `cities.venues_count` sum **11,510**. Ledger **322** rows, last id **376**. audit_log **129,216** rows, last id **135,045**. Closed published 0, active not published 0.

## Done
Both through the Write connector, 1 transaction each, first try, all gates passed. The text sent was the whole file, header comments included.

| Write | Change | Ledger | audit_log |
|---|---|---|---|
| Denmark (about 23:18 UTC) | 56 rows labelled 2026 get the `/us/en/` card URL (Three 3, Two 6, One 27, Bib 20), including Udtryk 4643 (card note "temporarily closed, reopen in December"; venue stays closed). PAZ 3444 (FO): no write, gated. Year unchanged | 375 | 134,926-134,981: awards UPDATE 56 |
| Vietnam (about 00:43 UTC Nov 7) | 64 rows labelled 2026 get the card URL (One 9, Bib 55). Rows 10427 Phở Bò Lâm and 10516 Vị Quê Kitchen stay with no URL. Chị Mơ card: no venue, gated, no write | 376 | 134,982-135,045: awards UPDATE 64 |

**Not changed:** names, year, status, price, venues, slugs, cities, redirects, city aliases. The live site does not read Supabase, so no live page changed.

Population: Michelin rows labelled 2026 on venues in each country, rows / with a URL, read after each write.
- DK 69 / 69 (Three 3, Two 6, One 32, Bib 27, Young Chef 1).
- VN 87 / 85 (One 11/11, Bib 71/69, Green Star 3/3, Service 1/1, Young Chef 1/1).

## Files (branch `oad-2026-read-block`)
| File | sha256 |
|---|---|
| `docs/michelin-d-denmark-2026-11-06/load-michelin-d-denmark-2026-11-06.sql` (ran) | `cb04c3133cb4d2c32313cd4e064c10c2c790cfef8f41bf4b8ea67b7bb3f67d21` |
| `.../relay-dk-2026-cards-2026-11-06.txt` (equal to the browser) | `617efae6682002db090f052ebc71c72225c4414a4776d55d22cfef9579d8c89b` |
| `.../michelin-d-denmark-2026-11-06-evidence.csv` | `e4e112f87a093fec3bc65c263ab32d0fd31d12219e0f08940c394c1ce8002843` |
| `docs/michelin-d-vietnam-2026-11-06/load-michelin-d-vietnam-2026-11-06.sql` (ran) | `5499b54384f1e468a45f9ca514f61fc29de53752b500744262f260c61de64a1f` |
| `.../relay-vn-2026-cards-2026-11-06.txt` (equal to the browser) | `078938594a09918abb58daffb4235bf2388922fb82f7ac554713dcd54c5a5b5d` |
| `.../michelin-d-vietnam-2026-11-06-evidence.csv` | `14882a49b693bbdc67087f2dae30b66ba9b4df7e6bbfcda1b2f874c1c16f8094` |
| `docs/michelin-d-shared/build_d_url.py` (changed, see Methods) | `6738a2179d42017966f56f27101e111d1c568d0b8f89c9df927693f06ec2337b` |
| `docs/michelin-d-shared/readSel.js` (unchanged) | `0c373f466635b9f57763d58dec46415b3320b49fc988c8aad5505fba95775dcb` |

Each country folder also holds `baseline.json`, `pairs.tsv`, `config.json` and `relay.sha256`.

## Decisions (Ben, Nov 6)
**Denmark (1-5: A):**
1. Run as built (56 rows).
2. Udtryk `ve_357709fdf3` (closed in the DB since the Aug 14 load; card on the 2026 list, "temporarily closed and set to reopen in December"): row 4643 gets the card URL, venue stays closed and unpublished. Recheck in December, same as Lasai.
3. Noma `ve_a672e8734e` (2025 Three Stars only, no 2026 card, card 404): recheck list, no write. Ben confirms Noma is open now. Status stays active.
4. Rename batch, 25 new names (paz to PAZ is already on it): Restaurant Calma to Calma; Restaurant Gabrielle to Gabrielle; Restaurant Koefoed to Koefoed; Melee to Mêlée; No. 2 to no.2; Restaurant Rebel to Rebel; Restaurant Levi to Levi; Restaurant Domestic to Domestic; Restaurant TRI to Tri; Restaurant Aure to Aure; Restaurant JATAK to Jatak; Texture to texture; Restaurant Udtryk to Udtryk; Restaurant domæne to Domæne; Restaurant Villa Vest to Villa Vest; Restaurant MOTA to MOTA; Restaurant Aro to ARO; Hotel Frederiksminde to Frederiksminde; Restaurant Syttende to Syttende; Restaurant Lyst to LYST; Restaurant Jordnær to Jordnær; Kadeau to Kadeau Copenhagen; Restaurant Frederikshøj to Frederikshøj; Aoc to a|o|c; King Hans Cellar to Kong Hans Kælder.
5. Phase 3 location pass: Restaurant VIE (row Copenhagen, card Nordhavn), Restaurant Jordnær (row Copenhagen, card Gentofte).

**Vietnam (1-5: A):**
1. Run 64 rows, including 4 weak Da Nang pairs (each card has only 1 row left, same category): 9987 Bún Mắm Bà Đông = Bà Đông; 10002 Hờn Fishcake Noodle Soup = Bún Chả Cá Hờn; 10004 Quán cháo vịt cô chủ nhỏ = Cô Chủ Nhỏ; 10014 Nhân Méo = Quán Nhân. No address rows in the DB for them.
2. Phở Bò Lâm `ve_108b0df182` (row 10427) and Vị Quê Kitchen `ve_df42958960` (row 10516): no URL now. Recheck list and archive URL item.
3. Chị Mơ (Ho Chi Minh City): hold register.
4. Năm Hiền `ve_adac4d00e2` (2025 Bib only) and Nam Hìn `ve_1f12403d25` (2026 Bib, card `nam-hien-phan-thanh-street`): same-name pairs list, no merge.
5. Rename batch: 44 names (list by script from the evidence CSV against the row names; many differ only by a branch or street label in brackets, for example "(Hoàn Kiếm)"). The name rules decide in the batch.

## Evidence notes
- **Denmark cards (21:39-21:43 UTC):** list 3 / 7 / 32 / 27 = 69. All 69: status 200, label 2026, guide Denmark, 0 redirects. 68 with no closure note; Udtryk card text: temporarily closed, reopen in December. PAZ card `/us/en/faroe-islands/torshavn/restaurant/paz` sits in the Two Stars list; row 3444 already held it (D1, ledger 366). Noma card `/us/en/capital-region/copenhagen/restaurant/noma`: 404. News Jul-Aug 2026 (ABC News, Euronews headlines): Noma to reopen under new leadership.
- **Vietnam cards (23:19-23:24 UTC):** list 0 / 0 / 11 / 70 = 81. All 81: status 200, label 2026, guide Vietnam, 0 redirects, 0 closure notes. Ceremony Jun 4, 2026 (`/en/article/michelin-guide-ceremony/michelin-guide-vietnam-2026`). VietNamNet (Jun 5, 2026, WebFetch summary): 72 Bib Gourmands at the ceremony; the site shows 70 now. Cards `pho-bo-lam` (Hanoi) and `vi-que-kitchen` (HCMC): 404 on `/us/en/`; Michelin search still lists them in other locales. Wayback CDX, 10 locales: `pho-bo-lam` last Mar 2, 2026 (us/en), `vi-que-kitchen` last Jul 24, 2025 (vn/en); 0 after the ceremony. The Michelin 2026 article does not name them; it names Chị Mơ as a new Bib. Da Nang Fantasticity (Jun 5, 2026): 23 Da Nang Bibs, Quán Nhân not new, Năm Hiền at 46 Phan Thanh.
- **Fujian 2027:** not out. Jing Li "2026 Fuzhou" at 21:39 and 23:19 UTC.

## Group D: closed
All rows labelled 2026 with no URL in the D list are done, except these, which stay on other items:
- Malaysia 66 rows labelled 2026: archive URL item (Ben 6A of D1).
- Austria 35543 Schlosskeller Wirtshaus: archive URL item.
- Vietnam 10427, 10516: archive URL item and recheck (this file).
- 2025 rows with no URL stay out of group D: DK 57, SE 34, NO 22, FI 11, LT 11, IS 3, FO 1, VN 68.

## Hold register (new)
- **Chị Mơ**, Ho Chi Minh City, Vietnam: Bib Gourmand 2026, card `https://guide.michelin.com/us/en/ho-chi-minh/ho-chi-minh_2978179/restaurant/chi-mo`, 323 Ly Tu Trong Street, Ben Thanh Ward. No venue, no row. New in the Jun 4, 2026 article.
- All entries of the D1 and A2-E handoffs stay.

## Weak points
- The SQL text sent to the Write connector (2 files) and the dry-run text were copied from the file printout, not hashed against the file. The md5 plan gates cover the plan text.
- Pairs for DK (56 lines) and VN (64 lines) were written by hand from the live read. The gates check venue, category, year and a null URL on every plan row.
- The 4 weak Vietnam pairs rest on name form and on being the only row left; no address test.
- The 72-Bib count and the Da Nang list came through a WebFetch summary.
- Noma status rests on headlines and Ben's word.
- 2 Vietnam card URLs hold an encoded no-break space in Michelin's own path: `thia-go%C2%A0`, `ciel%C2%A0`.
- `city_venue_counts` view: column name not known in this session (a read with `n` failed); the city check was not repeated. No city count changed in these writes.

## Open items, in order
1. **Gault & Millau France and Monaco 2027 (after Nov 9).** Opening prompt in the A2-E handoff (update the counts to this file). **Thailand 2027 (after Nov 10).** The Thailand 2027 file must allow the 180 Thailand card URLs in its `url in use` gate. Latin America's 50 Best (Dec 1), La Liste 2027 (December), Northeast Cities (after Dec 14). Foundation: price method, Madame Vo, Hotel de Paris Monte-Carlo. Price item adds Atelier and Muttonbird.
2. Status read of the 45 Top 500 venues.
3. **Rechecks:** as in the A2-E, D-TH-FI-LT and D-NO-SE handoffs, plus Udtryk `ve_357709fdf3` (December reopening), Noma `ve_a672e8734e` (Ben: open), Phở Bò Lâm `ve_108b0df182`, Vị Quê Kitchen `ve_df42958960`.
4. **Same-name pairs:** as before, plus Năm Hiền `ve_adac4d00e2` / Nam Hìn `ve_1f12403d25`.
5. **Rename batch:** as before, plus the 25 Denmark names and the 44 Vietnam names above.
6. **Archive URLs:** as in the D1 handoff, plus Vietnam rows 10427 and 10516.
7. **Phase 3 location pass:** add Restaurant VIE (Nordhavn) and Restaurant Jordnær (Gentofte).
8. Phase 2 publish job (goal Nov 29), history backfill: as before.
9. Plan v1.31: add D1, Thailand (368), Finland (369), Lithuania (370), Norway (371, 372), Sweden (373, 374), Denmark (375), Vietnam (376), Ben's 5A, 6A and all group D choices.
10. Research result (after Nov 7): see the radar handoff.

## Methods (new)
- **`build_d_url.py` options (new, all optional; Finland, Lithuania, Norway, Sweden and Denmark rebuild byte for byte):**
  - `outside`: `[[award_id, venue_id, slug, iso, note]]` a card in the list on a venue of another country (PAZ). No write. Gate: the row holds the card URL and the venue's city has that `country_iso`. Counts toward card coverage.
  - `note_ok`: `{slug: [relay_note, evidence_text]}` a card with a closure note; the paired row still gets the card URL.
  - `no_row`: `[[slug, note]]` a card with no venue (hold register). No write. Gate: no award holds the card URL.
  - `urls_after`: rows of the year in scope that hold a URL after the write (default `rows_after`), for rows left with no URL.
- **Regression test after a script change:** copy each country folder to scratch, take the fingerprint and approval text from its ran SQL, rebuild, compare sha256.
- **Seat count check:** a publisher article count at the ceremony against the site list today shows cards that left the site after the ceremony (Vietnam: 72 against 70).
- **Card address read:** `.data-sheet__block--text` on the card page.
- **Long JS output:** "[BLOCKED: Cookie/query string data]" when the result holds many link hrefs; return only short text.

## Dead ends: do not retry
- WebFetch of `news.laodong.vn` articles: returns a cookie reload page only.
- `city_venue_counts.n` (no such column).
- Card slug guesses `vi-que` for Vị Quê Kitchen: 404. The real slug is `vi-que-kitchen` (also 404 now).
- All dead ends of the D1, A2-E, D-TH-FI-LT and D-NO-SE handoffs stay.

**Repo:** branch `oad-2026-read-block` holds the Denmark and Vietnam folders, the changed shared script and this handoff. Not merged. A merge is Ben's by hand: https://github.com/benjamineades/compasseats/compare/main...oad-2026-read-block

## Suggested opening prompt: Gault & Millau (after Nov 9)
```
Read claude/handoff-michelin-d-dk-vn-done-2026-11-06.md from the project files, then
claude/handoff-michelin-a2-a3-b-e-done-2026-11-06.md for methods, the hold register and dead ends,
claude/handoff-michelin-a1-greece-south-australia-dubai-done-2026-11-06.md for the Gault & Millau notes,
claude/launch-list-2026-11-05.md, and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Use plain /ste replies, with a population on every count.
Do a fresh count read and confirm ledger 376, audit_log 135,045, venues 11,831 (active 11,510, closed 321), awards 29,052,
OAD 2026 rows 2,859, OAD 2025 rows 2,437, slugs 13,775, price 7,759, city_aliases 222, redirects 35, closed published 0 and
cities.venues_count sum 11,510. Stop and tell me if any count differs.
Attach benjamineades/compasseats with push access. Work from branch oad-2026-read-block.
Before the work, read again whether Fujian 2027 is out. If it is, tell me and ask where it goes in the order.
Start Gault & Millau France and Monaco 2027: check first that the gala results of Nov 9 are out. Read the live rows again first, then read the list from the publisher and check first that it is complete. The live rows hold the 2026 edition (gala Nov 17, 2025).
Build the file first, examine it read-only with a dry run, present the evidence, then ask me for choices. After my choices: a fresh read, then wait for my "go". No write before my "go".
If you have trouble fetching sites or connecting to GitHub & Supabase, check the chrome connector.
```
