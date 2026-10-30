# Handoff: Turkey 2026 relabel + Turkey card price done. Oct 30, 2026. Next: Turkey follow-ups, then P1-rest held 19, then name differences.

This file replaces `handoff-price-card-p1-rest-done-2026-10-30.md` for live state and next steps. That file still holds
the P1-rest results and the list of the held venues. `handoff-price-card-p1-done-2026-10-30.md` holds the card-read
method. The working rules in `handoff-chengdu-held-7-cleanup-done-2026-10-04.md` and the Oct 29 standing rule
(Claude commits files to the repo itself) still apply.

## Ben's decisions (Oct 30, 2026)
- 13:52 ET: order of work = Turkey 2026 edition check, then the held P1-rest venues, then the name differences.
- 13:57 ET "A" for all:
  - D1 a: relabel the 53 Turkey rows that match a current card: year 2025 -> 2026, source_url NULL -> card URL.
  - D2 a: hold Efendy İstanbul `ve_51ce2088a5` and Lucien Arkas Bağları `ve_f8013e6d34` (not on the current list).
    Next: find their cards on web.archive.org near Dec 4, 2025, to prove the 2026 Bib, then relabel.
  - D3 a: Sankai by Nagaya `ve_f088b7a06a`: award relabelled to 2026; venue status `closed` (Aug 14 sheet load) not
    changed; no price row. Status check open (card Oct 30: One Star, no closure note; web search found no closure).
  - D4 a: LA Mahzen (card `1208310`, Izmir, Torbalı, Bib, ₺₺, `us/en/izmir/izmir_2809416/restaurant/la-mahzen`): not
    in the database. Hold for a separate promote batch (venue, slug, listing, city label, award, price).
  - D5 a: 16 price INSERT, currency TRY. The 36 legacy price rows on the matched venues: not changed (later P2 batch).
- 14:13 ET "go".

## Edition evidence
- The MICHELIN Guide Türkiye 2026 selection, published Dec 4, 2025:
  https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-michelin-guide-turkiye-reveals-its-2026-restaurant-selection
  Regions: Istanbul, Izmir, Muğla, Cappadocia (new). Article totals: Two Stars 2, One Star 15, Bib 39 (16 new), Green 4.
- Our 55 rows (all labelled 2025, loaded Aug 14) held 2026 content: Vino Locale Two Stars, Revithia, Araf, Mezra
  Yalıkavak and the Cappadocia venues are 2026 newcomers.
- Bib count check: 36 matched + Efendy + Lucien Arkas + LA Mahzen = 39 = the article total. The current list shows 37.

## Live state (read Oct 30, 18:15 UTC, whole tables, after the commit)
| Table | Count |
|---|---|
| price | **7,714** (guide_ingest **5,115**, TRY **16**) |
| venues | 11,307 (active 10,939, closed 368) |
| awards | 23,352 |
| source_capture_ledger (max id) | **156** |
| audit_log (max id) | **118,694** |
| Turkey Michelin rows | 2026 **53** (all with card URL), 2025 **2** (Efendy, Lucien Arkas) |
| Active Michelin star/Bib venues with no price row | **21** (19 held P1-rest + Terra, La Torre One Fire) |

## Done in this session
1. Start check (17:50 UTC): price 7,698, ledger 154, audit 118,625. All matched. Repo attached with push access,
   clone at `c543d4e`; the P1-rest SQL and relay in `docs/` have the handoff sha256.
2. Turkey list read (built-in browser, `fetch()`, 1.2 s pause): `/us/en/selection/turkey/restaurants` (the slug is
   `turkey`; `turkiye` gives 404), 4 pages, all 200, 159 Turkey cards (+4 featured US cards). Star/Bib 54: Two Stars 2,
   One Star 15, Bib 37. List file sha256 `686d2797…3bab80`.
3. Card read of the 54 (18:00 UTC): all 200, no redirect, country tr, symbol ₺ (₺ count = CAT_P0n), card
   distinction = list distinction. File `michelin-turkey-2026-card-read-2026-10-30.txt` sha256 `ba0e1d34…022c9425`
   (browser = file).
4. Database rows file (55 rows) md5 `e8cf313c73b478c68b9cbce8d8495350` (file = database read).
5. Pairing (`pair_turkey.py`): 53 pairs, same distinction on all: 49 exact loose key, 3 name subset (Ayşa Boşnak
   Börekçisi, Adil Müftüoğlu, Kemal'in Yeri), 1 manual spelling (Tersane İstanbul = Tershane: only Istanbul Bib card
   left; venue site tershanerestaurant.com uses both spellings; address Tersane Cd. No:24, Karaköy). Pairs file sha256
   `34b99295…a7557b`.
6. File `michelin-turkey-2026-relabel-price-2026-10-30.sql` (18,873 bytes, sha256
   `be6e88e8c2c4513990e88495034b61eb29fd037526e88f143e8442302a81c7d7`). Relay 53 lines, sha256
   `9ffe52567c572c77af040d2159bcb6894b3dcba2e48148f47187accd0afd5378`, md5 `ee517b3dd883960b3cd1e7b8aed45098`.
   Builder `build_turkey_2026_sql.py` (new). pglast 8.7 syntax check passed; dry run (Read connector, guards then a
   forced stop) passed. Write 18:15:09 UTC, Write connector, one transaction, all guards and post-checks passed:
   - 53 UPDATE of `awards`: year 2025 → 2026, source_url NULL → card URL (Two Stars 2, One Star 15, Bib 36). Ledger **155**.
   - 16 INSERT into `price` (TRY 16; tiers 1 = 3, 2 = 8, 4 = 5). Ledger **156**.
   - Audit **118,626–118,694**: awards UPDATE 53, price INSERT 16.
   - Samples: Urla Vino Locale ₺₺₺₺ TRY 4, Araf İstanbul ₺₺ TRY 2, Arka Ristorente Pizzeria Bodrum ₺ TRY 1.

## Method notes from this session
- The list card attributes (`data-restaurant-name`, `data-dtm-city`, `data-dtm-distinction`, `data-dtm-price`,
  `data-restaurant-country`) are on the inner `.js-favorite-restaurant` div inside `div.card__menu`, not on
  `div.card__menu` itself. `div.card__menu` holds `data-id` and `data-map-pin-name` (ONE_STAR, TWO_STARS, BIB_GOURMAND).
- The country slug for Türkiye is `turkey`.
- Turkey cards show ₺; stored as TRY.
- One card name has a non-breaking space: Asma Yaprağı (URL `asma%C2%A0yaprag%C4%B1`).
- When the year of a row changes, check `awards_no_dupes` (venue_id, source_id, year, rank, category, distinction).
- A database text read can go into a file by hand only with an md5 check against the database (done here for the
  55-row file).

## Files
| File | sha256 | Where |
|---|---|---|
| `michelin-turkey-2026-relabel-price-2026-10-30.sql` | `be6e88e8…02a81c7d7` | project `claude/`, repo `docs/` |
| `michelin-turkey-2026-relabel-price-relay-2026-10-30.txt` (53 lines, no final newline) | `9ffe5256…0afd5378` | project `claude/`, repo `docs/` |
| `michelin-turkey-2026-card-read-2026-10-30.txt` (54 lines) | `ba0e1d34…022c9425` | project `claude/`, repo `docs/` |
| `michelin-turkey-2026-pairs-2026-10-30.txt` (53 lines) | `34b99295…a7557b` | project `claude/`, repo `docs/` |
| `build_turkey_2026_sql.py`, `pair_turkey.py` (new) | (see repo commit) | project `claude/`, repo `docs/` |
| this handoff | (see repo commit) | project `claude/`, repo `docs/` |

## Open items
- **Next (Ben's order):**
  1. Turkey follow-ups: D2 archive check (Efendy İstanbul, Lucien Arkas Bağları); D4 LA Mahzen promote; D3 Sankai
     by Nagaya status check.
  2. The held P1-rest venues, now **19** (35 minus Turkey 16): Banshee, Zhu Ji Zhi Mian Pu, California no-star 5,
     other city 2, distinction 1, branch 4, no website 4, name not on site 1. List in
     `handoff-price-card-p1-rest-done-2026-10-30.md`.
  3. The name differences: 45 from P1 rest, plus 24 Turkey name differences against the card (examples: Urla Vino
     Locale → Vino Locale; Tersane İstanbul → Tershane; MACAKIZI BODRUM → Maçakızı; TURK FATIH TUTAK → TURK FATİH
     TUTAK; Pandeli Restaurant → Pandeli). Full list: compare column 5 and 6 of the pairs file.
- New from this session:
  - Turkey card cities that differ from ours (venue city not changed): Revithia (Cappadocia → Ürgüp); Casa Lavanda
    (Şile → Istanbul); Bagarasi, Mandalya (Muğla → Bodrum); Mezegi (Muğla → Fethiye); Asma Yaprağı (Alaçatı → Izmir);
    Mezra Yalıkavak (Yalıkavak → Bodrum); Babayan Evi, Old Greek House (Nevşehir → Ürgüp).
  - 36 Turkey venues keep a legacy price row (no currency); the card price is in the card-read file for a later
    P2-style UPDATE.
- Carried from the P1-rest handoff: city labels Waiheke → Waiheke Island, Wanaka → Wānaka, Dakovo → Đakovo;
  California 2026 One Star rows with no star on the current list (California edition date check); held-P2 items
  (5 city changes, 3 name differences, rechecks Café Spice Namasté and Unforgettable after Nov 12, 15 P2 venues that
  left the guide); Lavello `ve_04c2784726`; Les Fresques `ve_e574aeb7fd`; Terra (Fisterra) `ve_89ca903ac2` card 404;
  La Torre One Fire `ve_b5a5b44c26` card moved; Fujian 2027 watch (late Nov); Switzerland after Nov 2; Italy 2027
  edition Nov 12 (rule 2.1.7); Spain 2027 edition Dec 1; Germany 2027 and GB&I 2027 edition dates not found; Northeast
  Cities after Dec 14; Tokyo / Kyoto-Osaka / Nara 2027 after Feb 16, 2027; Belgium & Luxembourg 2027 (spring 2027);
  American Great Lakes first edition Apr 21, 2027; telleruide slug; apostrophe policy; Nadair (Atlanta) possibly
  closed; Dill (Lewes) status; Florida 2026 Green Stars article not found; La Table – Christophe Hay merge candidate;
  7 unproven legacy special-award rows; 5 new awards on closed venues.

## Suggested opening prompt
```
Read claude/handoff-turkey-2026-relabel-done-2026-10-30.md from the project files, then
claude/handoff-price-card-p1-rest-done-2026-10-30.md for the held P1-rest list,
claude/handoff-price-card-p1-done-2026-10-30.md for the card-read method and
claude/handoff-chengdu-held-7-cleanup-done-2026-10-04.md for working rules. Do a fresh count read and confirm
price 7,714, ledger 156 and audit_log 118,694. Then start the Turkey follow-ups: the web.archive.org check for
Efendy İstanbul and Lucien Arkas Bağları, and the Sankai by Nagaya status check. Show me the result and the LA Mahzen
promote plan in /ste style. No write before my go. Attach the compasseats repo with push access for the commit after
any write.
```
