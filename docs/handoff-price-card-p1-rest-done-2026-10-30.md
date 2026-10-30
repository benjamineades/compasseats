# Handoff: Block A step 3, P1 rest done (116 cards found by name, price + award URL). Oct 30, 2026.

This file replaces `handoff-price-card-p2-held-done-2026-10-30.md` for live state and next steps. That file still holds
the held-P2 results and the carried open items listed below. `handoff-price-card-p1-done-2026-10-30.md` holds the
card-read method. The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule
still apply.

## Ben's decisions (Oct 30, 2026)
- 13:13 ET "agree": hold Turkey 16, Banshee, Zhu Ji Zhi Mian Pu before the search; class B (same name, other city)
  held for Ben; card distinction lower than our row: hold, no write; new currencies by card country.
- 13:32 ET "agree": DK, NO, PL, SE cards show EUR symbols, so store `EUR` (option a); NZ = `NZD` ($), VN = `VND` (₫).
  Class C1 (generic words only, same city, same distinction, the only card with that name in the list) accepted on
  name + city + distinction. Class C2 keeps the address proof on the venue's own website.
- 13:45 ET "go".

## Live state (read Oct 30, 17:46 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,698** (guide_ingest **5,099**, legacy_guide **2,599**) |
| venues | 11,307 (active 10,939, closed 368) |
| awards | 23,352 |
| source_capture_ledger (max id) | **154** |
| audit_log (max id) | **118,625** |
| Active Michelin star/Bib venues with no price row | **37** (35 held below + Terra, La Torre One Fire) |

## Done in this session
1. Start check (17:09 UTC): price 7,582, ledger 152, audit 118,393. All matched. Repo attached with push access,
   clone at `de9e589`.
2. Population: venues with a Michelin star/Bib award row, no price row, no card URL on any star/Bib row: 154 (active
   151, closed 3). Countries (active): NZ 47, US 42, TR 16, VN 16, DK 12, HR 4, LT 3, NO 3, PL 3, SE 2, FI 1, SI 1, CN 1.
   150 had `source_url` NULL; 0 had an address row; in 61 of 63 cities no other venue had a card URL.
3. List read (built-in browser, `fetch()`, 1.2 s pause), all pages, status 200: `/us/en/selection/<country>/restaurants`
   for denmark, finland, croatia, lithuania, norway, poland, sweden, slovenia, new-zealand, vietnam; `/us/en/california/restaurants`
   and `/us/en/florida/restaurants`. 1,703 cards (+4 featured on Denmark page 1). Cards parsed from `div.card__menu`:
   `data-id`, `data-restaurant-name`, `data-dtm-city`, `data-dtm-distinction`, `data-dtm-price`, `data-restaurant-country`,
   `a[href*="/restaurant/"]`. Card file sha256 `c2d6468a…b460d8df` (browser = file).
4. Name match (loose key, unaccented, trailing "(…)" removed): A 76, B 2, C 54, D 1 (133 work set).
5. Test cards per country: DK, NO, PL, SE show € (not the local currency). VN shows ₫.
6. Card read of 116 (A 71, C1 33, C2 12 with address proof): all 200, no redirect, star/Bib = our 2026 category.
   C2 proof: venue's own site shows our name and the card address (Upstairs Tasting Room, Essence (ROKI), Cicio Cacio
   Osteria, Indian Alley Wakefield (290 vs 3/290), Bombay Palace Wanaka, Moondog Cafe Key West, Bistro Loora,
   Lugya'h by Ponchos Tlayudas, Double Luck Chinese, Troubadour Bread & Bistro, Ortega Fish Shack, Mammom (23B vs 23)).
7. File `price-michelin-card-p1-rest-2026-10-30.sql` (25,549 bytes, sha256
   `19d15285106e47af89debe204352dddd27ca921c4289436172e2f5b0a7fffe32`). Relay 116 lines, sha256
   `48656407e2d1b7d95061dc0fe4fdb6644ecc4d7d53c7e798738939da0e8020a5` (browser = file). Builder
   `build_price_p1_rest_sql.py` (new). pglast 8.7 syntax check passed; dry run (Read connector, stopped at the first
   UPDATE) passed. Write 17:46:46 UTC, all guards and post-checks passed:
   - 116 UPDATE of `awards.source_url` (NULL → card URL; each venue had exactly 1 Michelin row, 2026). Ledger **153**.
   - 116 INSERT into `price` (NZD 46, USD 34, EUR 28, VND 8; tiers 1 = 17, 2 = 57, 3 = 16, 4 = 26). Ledger **154**.
   - Audit **118,394–118,625**: awards UPDATE 116, price INSERT 116.
   - Samples: Essence $$$$ NZD, ONVIT ₫₫₫ VND, akmē €€€ EUR, Troubadour $$$$ USD, Mammom ₫₫ VND.

## The 35 held venues (no write)
- Before the search (18): Turkey 16 (all 55 Turkey Michelin rows are 2025; **new item: Turkey 2026 edition not in the
  database**); Banshee `ve_466f9b5fe9` (latest 2024 Bib); Zhu Ji Zhi Mian Pu `ve_24aeca03f9` (archive URL, left in 2027).
- List card shows no star or Bib, our row 2026 One Star (5): Chez Panisse `ve_3a998c5225`, Pomet `ve_2b87774359`,
  Monte's `ve_355d4a675c`, Chi Spacca `ve_43771d354f`, Sierra Mar `ve_49fd475e56`.
- Card in another city (2): Paloma Taqueria `ve_3fad690140` (card Wānaka, ours Auckland); Miura `ve_ca50fd9f2e`
  (card Beverly Hills, ours Los Angeles).
- Distinction differs (1): Heritage `ve_95d87f1674` (ours Two Stars, Long Beach card 1 star; another Heritage in
  Fort Lauderdale, Bib).
- Different branch on the card (4): Mặn Mòi `ve_3a9de72b7b` (Bến Nghé vs An Khánh); Hủ Tiếu Hồng Phát
  `ve_595408ccd8` (Bến Thành vs Bàn Cờ); Nam Hin `ve_1f12403d25` (Han Market vs Phan Thanh St); Chay Garden
  `ve_f97f8ec140` (Nguyễn Thị Minh Khai vs Xuan Hoa, 52 Vo Van Tan).
- No website of its own (4): Crab noodle Ba ba `ve_362cf33750` (card Bánh Canh Cua Bà Ba); Xôi, Bún măng gà bà Vui
  `ve_afc5cbe328` (card Bà Vui); Bún Bò Huế - Lê Gia Khang `ve_dff956ccb3` (card Lê Gia Khang (Ngũ Hành Sơn));
  Bánh Bèo, Bánh Đập, Bánh Ướt `ve_f21ee3afab` (card Bánh Bèo - Bánh đập).
- Our name not on the site (1): Most Tumski `ve_00d8a2d2b6` (site "Restauracja Między Mostami", tasting room "Most",
  card address Księcia Witolda 1 = site).

## Method notes from this session
- Country lists on guide.michelin.com (`/us/en/selection/<country>/restaurants`, `/page/N`) and US state lists
  (`/us/en/<state>/restaurants`) render all cards in raw HTML, 48 per page; the `h1` gives "a-b of N".
- The list card attributes give name, city, distinction and price category without a card fetch. Blank
  `data-dtm-distinction` = no star or Bib.
- The US/en site shows € for DK, NO, PL, SE, FI, HR, LT, SI cards; $ for NZ; ₫ for VN.
- A card's JSON-LD `address` gives the street address for an address proof. The card `CTA_website` link gives the
  venue's own site.
- A large `javascript_tool` result is saved to a file when it is too long; pad the result to force the save, then
  parse it and compare the sha256 with the browser hash.

## Files
| File | sha256 | Where |
|---|---|---|
| `price-michelin-card-p1-rest-2026-10-30.sql` | `19d15285…a7fffe32` | project `claude/`, repo `docs/` |
| `price-michelin-card-p1-rest-relay-2026-10-30.txt` (116 lines, no final newline) | `48656407…0e8020a5` | project `claude/`, repo `docs/` |
| `build_price_p1_rest_sql.py` (new) | (see repo commit) | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Open items
- **Next (Ben picks):** the 35 held venues above, or the Turkey 2026 edition check (rule 2.1.7), or the 45 name
  differences.
- New from this session:
  - 45 name differences against the card (C1 33 + C2 12), for the Sep 14 / Oct 10 name rulings. Examples: Gatherings
    Restaurant → Gatherings; Frank → Restaurant Frank; Restoran Loora → Bistro Loora; Tantalus Estate → Tantalus Estate
    Restaurant; Harry's Piccolo → Harry's Piccolo Poreč.
  - City labels on the card that differ from ours (venue city not changed): Waiheke → Waiheke Island; Wanaka → Wānaka;
    Dakovo → Đakovo.
  - California: 5 venues with a 2026 One Star row show no star on the current list (see held). Examine the California
    edition date against our 2026 rows.
- Carried from the held-P2 handoff: 5 city changes shown on the card, 3 name differences; rechecks Café Spice Namasté
  and Unforgettable (after Nov 12); 15 P2 venues that left the guide.
- Carried: venue `ve_04c2784726` "Lavello" (card Forentum); Les Fresques name cleanup `ve_e574aeb7fd`; Terra (Fisterra)
  `ve_89ca903ac2` card 404; La Torre One Fire `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov); Switzerland
  after Nov 2; Italy 2027 edition Nov 12 (rule 2.1.7); Spain 2027 edition Dec 1 (Huesca); Germany 2027 edition (date not
  found); GB&I 2027 edition (date not found); Northeast Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after
  Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027); American Great Lakes first edition Apr 21, 2027; telleruide
  slug; apostrophe policy; Nadair (Atlanta) possibly closed; Dill (Lewes) status; Florida 2026 Green Stars article not
  found; La Table – Christophe Hay merge candidate; 7 unproven legacy special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-price-card-p1-rest-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
price 7,698, ledger 154 and audit_log 118,625. Then show me in /ste style the options for the next block: the 35 held
P1-rest venues, the Turkey 2026 edition check, or the 45 name differences. No write before my go. Attach the
compasseats repo with push access for the commit after any write.
```
