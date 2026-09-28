# Log: Michelin 2026 Great Britain & Ireland capture

Capture date: 2026-09-28. Source: guide.michelin.com, read in Chrome through the Claude in Chrome extension. No database or GitHub changes. No competitor sites used.

Files: `michelin-2026-great-britain-ireland.csv` (386 rows) and this log.

## 1. Method

- Country slugs, found with the site's destination search box (typed the country, clicked the plain country row under "Locations"):
  - United Kingdom → `united-kingdom` → https://guide.michelin.com/us/en/selection/united-kingdom/restaurants (page title "United Kingdom MICHELIN Restaurants – The MICHELIN Guide"). Every captured card has `data-restaurant-country="gb"`.
  - Ireland → `republic-of-ireland` → https://guide.michelin.com/us/en/selection/republic-of-ireland/restaurants (page title "Ireland MICHELIN Restaurants – The MICHELIN Guide"). Every captured card has `data-restaurant-country="ie"`.
- List URL pattern: `https://guide.michelin.com/us/en/selection/<slug>/restaurants/<distinction-slug>/page/<N>`. Page links came from `a[href*="/page/"]` in the DOM. `/page/1` redirects to the URL without `/page/1`.
- Only cards inside `.row.restaurant__list-row.js-restaurant__list_items` were read. All fields were read with `textContent`, never `innerText`.
- Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href; city = first `.card__menu-footer--score` line minus ", United Kingdom" / ", Ireland"; price = second footer line before " · "; country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Runs of whitespace were collapsed to one space.
- **Change from the brief: in-page `fetch()` + `DOMParser` was NOT used.** It failed the proof test on https://guide.michelin.com/us/en/selection/united-kingdom/restaurants/1-star-michelin (page 1). Rendered page SHA-256 = `595c28fbec524dee75037edae1c0ced477fd2f676ebce7888d9a83e6ee236775`. fetch() page SHA-256 = `cdfdd0269f067ac3b3d355564bdd6a61ddee1f682c3d32a87639024c0783084f`. The two do not match: the fetched HTML had a different set of 48 cards on page 1 and raw distinction values ("1 star") instead of the rendered ones ("ONE_STAR"). So every list page was opened in the browser tab and read from the rendered DOM (14 page loads).
- Moving the data out of the browser: the browser output tool shows only ~1,000 characters, so the rows were shown in the page in 4 blocks of up to 100 lines and copied into this workspace. Each block was checked against a SHA-256 computed in the browser, line by line and as a block. After one fix (see section 7, `mýse`), all four block hashes and the full-data hash match the browser: `56f0388db55ada48454404e404ef271cfcbe1b5ed99d6fa0669fc1d117baf827` (386 lines). The CSV was then built with a Python script from that data. No row was typed by hand into the CSV.
- `source_url` values are the card href with `https://guide.michelin.com` added. One path has a non-ASCII character (an en dash) and is written percent-encoded: https://guide.michelin.com/us/en/lancashire/aughton/restaurant/so%E2%80%93lo (card name `sō–lō`).

## 2. Counts

Ceremony counts: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-stars-news-uk-ireland-2026 ("at a Glance": 10 / 28 / 192 / 168). Country split for stars from the star list article: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland

| Country | Category | CSV rows | Site banner | Distinction filter | Ceremony | Diff CSV vs banner | Diff CSV vs filter |
|---|---|---|---|---|---|---|---|
| United Kingdom | Three Stars | 10 | United Kingdom : 1-10 of 10 restaurants - 3 Stars | 10 | 10 | 0 | 0 |
| United Kingdom | Two Stars | 23 | United Kingdom : 1-23 of 23 restaurants - 2 Stars | 23 | 23 | 0 | 0 |
| United Kingdom | One Star | 165 | United Kingdom : 145-165 of 165 restaurants - 1 Star | 165 | 174 | 0 | 0 |
| United Kingdom | Bib Gourmand | 146 | United Kingdom : 145-146 of 146 restaurants - Bib Gourmand | 146 | not published | 0 | 0 |
| Ireland | Three Stars | 0 | "Unfortunately there are no selected restaurants…" (0) | 0 (no 3 Stars row in filter) | 0 | 0 | 0 |
| Ireland | Two Stars | 5 | Ireland : 1-5 of 5 restaurants - 2 Stars | 5 | 5 | 0 | 0 |
| Ireland | One Star | 18 | Ireland : 1-18 of 18 restaurants - 1 Star | 18 | 18 | 0 | 0 |
| Ireland | Bib Gourmand | 19 | Ireland : 1-19 of 19 restaurants - Bib Gourmand | 19 | not published | 0 | 0 |
| **Total** | | **386** | 386 | 386 | 398 | 0 | 0 |

Distinction filter read on https://guide.michelin.com/us/en/selection/united-kingdom/restaurants/3-stars-michelin (UK: 3 Stars 10, 2 Stars 23, 1 Star 165, Bib Gourmand 146, Selected 804) and https://guide.michelin.com/us/en/selection/republic-of-ireland/restaurants/2-stars-michelin (Ireland: 2 Stars 5, 1 Star 18, Bib Gourmand 19, Selected 75; no 3 Stars line).

**Bib split by country (not published by Michelin):** United Kingdom 146, Ireland 19 (Distinction filter, pages above).

**Difference from 390:** 386 − 390 = −4 (−1.0%). This is inside the 10% limit.

**Difference from the ceremony (398 → 386, −12):**
- Stars −9 (230 → 221). 8 are the One Star restaurants that the star list article marks "[now closed]" (section 5). The 9th: the star list article links 183 live One Star restaurants and names 8 closed ones = 191 entries, not the 192 in the ceremony total. All 221 starred restaurants that the article links are in the CSV, in the same category (checked by slug in the browser). So the one-star gap is inside Michelin's own numbers, and I cannot name the 192nd restaurant from the article.
- Bib Gourmand −3 (168 → 165). Michelin publishes no full Bib list for this guide, so I cannot name the 3 that left. One example of change: the new-Bib list in the ceremony article includes a Stockport venue, and no Stockport card is in today's Bib list.

## 3. Duplicate, two-category and two-country checks

- Duplicate `source_url`: 0 (386 rows, 386 distinct URLs).
- Venue in two categories: 0 (the URL check covers this, because one URL = one venue).
- Venue in both country lists: 0. All UK-list cards are `gb`; all Ireland-list cards are `ie`.
- Every card's `data-restaurant-country` and `data-dtm-distinction` agree with the list URL (gb/ie; THREE_STARS, TWO_STARS, ONE_STAR, BIB_GOURMAND).
- Same name, different venues (kept, different URLs and cities): Home: Penarth https://guide.michelin.com/us/en/the-vale-of-glamorgan/penarth/restaurant/home-1196052, Belfast https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/home; Root: City of Bristol https://guide.michelin.com/us/en/south-gloucestershire/bristol/restaurant/root, Wells https://guide.michelin.com/us/en/somerset/wells/restaurant/root-wells.

## 4. 2027 check and named 2026 changes

- No 2027 selection found. The word "2027" is not on either country list page or any of the 12 venue pages opened.
- Guide year in the venue page meta description:
  - United Kingdom: "L'Enclume – a Three Stars: Exceptional cuisine restaurant in the 2026 MICHELIN Guide United Kingdom." — https://guide.michelin.com/us/en/cumbria/cartmel/restaurant/l-enclume
  - Ireland: "dede – a Two Stars: Excellent cooking restaurant in the 2026 MICHELIN Guide Republic of Ireland." — https://guide.michelin.com/us/en/cork/ie-baltimore/restaurant/dede
  - JSON-LD `award.dateAwarded` = "2026" on all 12 venue pages opened.
- Bonheur by Matt Abé: Two Stars, London, United Kingdom — https://guide.michelin.com/us/en/greater-london/london/restaurant/bonheur-by-matt-abe ✔
- Row on 5: Two Stars, London, United Kingdom — https://guide.michelin.com/us/en/greater-london/london/restaurant/row-on-5 ✔
- Forest Avenue: One Star, Dublin City, Ireland — https://guide.michelin.com/us/en/dublin/dublin/restaurant/forest-avenue-1198717 ✔
- The Pullman: One Star, Galway, Ireland — https://guide.michelin.com/us/en/galway/galway/restaurant/the-pullman ✔

## 5. Closed-restaurant check

Source: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland (8 "[now closed]" marks).

No card for any of them is on the live lists: Endo at The Rotunda (London), Mark Poynton at Caistor Hall (Caistor St Edmund), Outlaw's New Road (Port Isaac), Simpsons (Birmingham), SO|LA (London), Somssi by Jihun Kim (London), Sorrel (Dorking), The Masons Arms (Knowstone). Name search in the CSV found no match (only false hits: "John's House" in Mountsorrel, "Solas" in Dingle).

## 6. Channel Islands, Isle of Man and Northern Ireland rows

All have `country_label` = `United Kingdom` and `michelin_guide` = `united-kingdom-2026`.

Channel Islands (card `data-restaurant-country` = `gb` for all):
- Vraic (Vale) — One Star — https://guide.michelin.com/us/en/guernsey/vale_7770442/restaurant/vraic — `data-restaurant-country="gb"`, region `guernsey`
- Bohemia (Saint Helier) — One Star — https://guide.michelin.com/us/en/saint-helier/saint-helier/restaurant/bohemia — `data-restaurant-country="gb"`, region `saint-helier`
- Alba Restaurant (St Peter Port) — Bib Gourmand — https://guide.michelin.com/us/en/guernsey/saint-peter-port_1751292/restaurant/alba-1241339 — `data-restaurant-country="gb"`, region `guernsey`

Isle of Man: no rows.

Northern Ireland (card `data-restaurant-country` = `gb` for all):
- The Muddlers Club (Belfast) — One Star — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/muddlers-club — region `belfast-region`
- OX (Belfast) — One Star — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/ox399109 — region `belfast-region`
- Wine & Brine (Moira) — Bib Gourmand — https://guide.michelin.com/us/en/lisburn-and-castlereagh/moira/restaurant/wine-brine — region `lisburn-and-castlereagh`
- EDŌ (Belfast) — Bib Gourmand — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/edo — region `belfast-region`
- Beau (Belfast) — Bib Gourmand — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/beau — region `belfast-region`
- Deanes at Queens (Belfast) — Bib Gourmand — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/deanes-at-queens — region `belfast-region`
- Home (Belfast) — Bib Gourmand — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/home — region `belfast-region`
- mrDeanes (Belfast) — Bib Gourmand — https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/mrdeanes — region `belfast-region`
- Noble (Holywood) — Bib Gourmand — https://guide.michelin.com/us/en/ards-and-north-down/holywood/restaurant/noble — region `ards-and-north-down`

## 7. Excluded cards and data notes

- Cards excluded from the CSV: none. No card from another country appeared in either list. The ~4 promo cards outside the list row were not read.
- MICHELIN Selected, Green Star-only and special-award venues: no rows (section 10).
- `mýse` (Hovingham, One Star, https://guide.michelin.com/us/en/north-yorkshire/hovingham/restaurant/myse): the card prints the name as `m` + `y` + combining acute accent (U+0301) + `se`, not the single letter `ý` (U+00FD). The CSV keeps it exactly as printed. It looks the same on screen, but a text match against `mýse` typed with `ý` will fail. This is the only name that is not in NFC form.
- Old slugs in the star list article that differ from the live card URL (same venue): Kitchen Table (article `/kitchen-table-at-bubbledogs`, card https://guide.michelin.com/us/en/greater-london/london/restaurant/kitchen-table) and sō–lō (article link percent-encoded, same path).
- Card spelling differs from the brief: the card prints `sō–lō` (lower case), not `Sō–Lō`. Kept as printed.
- Homestead Cottage (Doolin) card has `data-restaurant-country="ie"` and is filed under Ireland: https://guide.michelin.com/us/en/clare/doolin/restaurant/homestead-cottage

## 8. Price and currency

- United Kingdom uses `£`. Example: L'Enclume `££££` — https://guide.michelin.com/us/en/cumbria/cartmel/restaurant/l-enclume
- Ireland uses `€`. Example: dede `€€€€` — https://guide.michelin.com/us/en/cork/ie-baltimore/restaurant/dede

| Country | price_symbol_raw | Rows |
|---|---|---|
| United Kingdom | `££££` | 158 |
| United Kingdom | `£££` | 40 |
| United Kingdom | `££` | 142 |
| United Kingdom | `£` | 4 |
| Ireland | `€€€€` | 21 |
| Ireland | `€€€` | 3 |
| Ireland | `€€` | 18 |

- Rows with no price: 0. Rows with a symbol that is not the country's normal one: 0. The 3 Channel Islands rows print `£`.
- JSON-LD `priceRange` is a text label, not symbols: `££££`/`€€€€` = "Spare no expense", `€€€` = "Special occasion", `€€` = "A moderate spend". The label matches the card symbol count on all 6 pages below.

| Venue | Card | /us/en/ page | JSON-LD priceRange | Local page | Local page URL |
|---|---|---|---|---|---|
| L'Enclume | `££££` | `££££` | Spare no expense | `££££` | https://guide.michelin.com/gb/en/cumbria/cartmel/restaurant/l-enclume |
| The Muddlers Club | `££££` | `££££` | Spare no expense | `££££` | https://guide.michelin.com/gb/en/belfast-region/belfast/restaurant/muddlers-club |
| Bohemia | `££££` | `££££` | Spare no expense | `££££` | https://guide.michelin.com/gb/en/saint-helier/saint-helier/restaurant/bohemia |
| dede | `€€€€` | `€€€€` | Spare no expense | `€€€€` | https://guide.michelin.com/ie/en/cork/ie-baltimore/restaurant/dede |
| Forest Avenue | `€€€` | `€€€` | Special occasion | `€€€` | https://guide.michelin.com/ie/en/dublin/dublin/restaurant/forest-avenue-1198717 |
| Solas | `€€` | `€€` | A moderate spend | `€€` | https://guide.michelin.com/ie/en/kerry/dingle/restaurant/solas |

Symbols are identical on the card, the /us/en/ page and the local page for all 6.

## 9. Six venue-page spot checks

| Venue | Card: name / city / category / price | Venue page: h1 / JSON-LD city / award / price | Match |
|---|---|---|---|
| https://guide.michelin.com/us/en/cumbria/cartmel/restaurant/l-enclume | L'Enclume / Cartmel / Three Stars / `££££` | L'Enclume / Cartmel / Three Stars: Exceptional cuisine / `££££` | yes |
| https://guide.michelin.com/us/en/belfast-region/belfast/restaurant/muddlers-club | The Muddlers Club / Belfast / One Star / `££££` | The Muddlers Club / Belfast / One Star: High quality cooking / `££££` | yes |
| https://guide.michelin.com/us/en/saint-helier/saint-helier/restaurant/bohemia | Bohemia / Saint Helier / One Star / `££££` | Bohemia / Saint Helier / One Star: High quality cooking / `££££` | yes |
| https://guide.michelin.com/us/en/cork/ie-baltimore/restaurant/dede | dede / Baltimore / Two Stars / `€€€€` | dede / Baltimore / Two Stars: Excellent cooking / `€€€€` | yes |
| https://guide.michelin.com/us/en/dublin/dublin/restaurant/forest-avenue-1198717 | Forest Avenue / Dublin City / One Star / `€€€` | Forest Avenue / Dublin City / One Star: High quality cooking / `€€€` | yes |
| https://guide.michelin.com/us/en/kerry/dingle/restaurant/solas | Solas / Dingle / Bib Gourmand / `€€` | Solas / Dingle / Bib Gourmand: good quality, good value cooking / `€€` | yes |

Northern Ireland check = The Muddlers Club (address "1 Warehouse Lane, Belfast, BT1 2DX, United Kingdom", JSON-LD country GBR). Channel Islands check = Bohemia (address "Green Street, The Club Hotel & Spa, Saint Helier, JE2 4UH, United Kingdom", JSON-LD country GBR).

## 10. Hold register (log only, no CSV rows)

### Green Star (37)

Source: https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new (title "7 New Green Stars Announced for Great Britain & Ireland 2026", dated 09 February 2026: "bringing the total number of Green Stars to 37"). 37 restaurant links found on the page.

| # | Venue | New 2026 | In today's CSV | URL (from the article) |
|---|---|---|---|---|
| 1 | 1887 | New | One Star (United Kingdom) | https://guide.michelin.com/gb/en/highland/torridon/restaurant/1887 |
| 2 | Eight at Gazegill by Doug Crampton | New | no (not a star or Bib) | https://guide.michelin.com/gb/en/lancashire/rimington_1746208/restaurant/eight-at-gazegill-by-doug-crampton |
| 3 | Forest Side | New | One Star (United Kingdom) | https://guide.michelin.com/gb/en/cumbria/grasmere/restaurant/forest-side |
| 4 | Glebe House | New | no (not a star or Bib) | https://guide.michelin.com/gb/en/devon/southleigh/restaurant/glebe-house |
| 5 | Knepp Wilding Kitchen | New | no (not a star or Bib) | https://guide.michelin.com/gb/en/west-sussex/horsham/restaurant/knepp-wilding-kitchen |
| 6 | The Free Company | New | no (not a star or Bib) | https://guide.michelin.com/gb/en/city-of-edinburgh/balerno_1719689/restaurant/the-free-company |
| 7 | Timberyard | New | One Star (United Kingdom) | https://guide.michelin.com/gb/en/city-of-edinburgh/edinburgh/restaurant/timberyard |
| 8 | Angela's |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/kent/margate/restaurant/angela-s |
| 9 | Apricity |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/greater-london/london/restaurant/apricity |
| 10 | Black Swan |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/north-yorkshire/oldstead/restaurant/black-swan |
| 11 | Coombeshead Farm |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/cornwall/lewannick/restaurant/coombeshead-farm |
| 12 | CULTURE |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/cornwall/falmouth/restaurant/culture |
| 13 | Daylesford Organic Farm |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/gloucestershire/daylesford/restaurant/cafe-at-daylesford-organic |
| 14 | Exmoor Forest Inn |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/somerset/simonsbath_1751466/restaurant/exmoor-forest-inn |
| 15 | Forge |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/north-yorkshire/middleton-tyas/restaurant/forge-1190154 |
| 16 | Homestead Kitchen |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/north-yorkshire/goathland/restaurant/homestead-kitchen |
| 17 | Interlude |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/west-sussex/lower-beeding/restaurant/interlude |
| 18 | Jericho |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/leicestershire/plungar_7770413/restaurant/jericho |
| 19 | L'Enclume |  | Three Stars (United Kingdom) | https://guide.michelin.com/gb/en/cumbria/cartmel/restaurant/l-enclume |
| 20 | Marle |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/hampshire/heckfield/restaurant/marle |
| 21 | Moor Hall |  | Three Stars (United Kingdom) | https://guide.michelin.com/gb/en/lancashire/aughton/restaurant/moor-hall |
| 22 | Oak |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/bath-and-north-east-somerset/bath/restaurant/oak-uk |
| 23 | Osip |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/somerset/bruton/restaurant/osip |
| 24 | Petersham Nurseries Café |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/greater-london/london/restaurant/petersham-nurseries-cafe |
| 25 | Pine |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/northumberland/east-wallhouses/restaurant/pine |
| 26 | Pythouse Kitchen Garden |  | Bib Gourmand (United Kingdom) | https://guide.michelin.com/gb/en/wiltshire/tisbury/restaurant/pythouse-kitchen-garden |
| 27 | Restaurant Sat Bains |  | Two Stars (United Kingdom) | https://guide.michelin.com/gb/en/nottingham-region/nottingham/restaurant/restaurant-sat-bains |
| 28 | St. Barts |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/greater-london/london/restaurant/st-barts |
| 29 | The Small Holding |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/kent/kilndown/restaurant/the-small-holding |
| 30 | Where The Light Gets In |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/greater-manchester/stockport/restaurant/where-the-light-gets-in |
| 31 | Wild Shropshire |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/shropshire/whitchurch/restaurant/wild-shropshire |
| 32 | Wilsons |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/south-gloucestershire/bristol/restaurant/wilsons |
| 33 | Inver |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/argyll-and-bute/strachur/restaurant/inver |
| 34 | ANNWN |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/pembrokeshire/narberth/restaurant/annwn |
| 35 | CHAPTERS |  | no (not a star or Bib) | https://guide.michelin.com/gb/en/powys/hay-on-wye/restaurant/chapters |
| 36 | The Whitebrook |  | One Star (United Kingdom) | https://guide.michelin.com/gb/en/monmouthshire/whitebrook/restaurant/the-whitebrook |
| 37 | Kai Restaurant |  | no (not a star or Bib) | https://guide.michelin.com/ie/en/galway/galway/restaurant/kai |

Green Star venues with a CSV row: 15 of 37. The other 22 are not in today's star or Bib lists, so they have no row.

### Special awards (5)

Source for all 5: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-stars-news-uk-ireland-2026

| Award | Person | Venue | In today's list | Venue URL |
|---|---|---|---|---|
| MICHELIN Opening of the Year Award | Maria Bradford (chef; the award is to the restaurant) | Shwen Shwen, Sevenoaks | yes — Bib Gourmand (United Kingdom) | https://guide.michelin.com/us/en/kent/sevenoaks_1755352/restaurant/shwen-shwen |
| MICHELIN Young Chef Award (sponsored by La Rousse Foods) | Tom Earnshaw | Bohemia, Saint Helier | yes — One Star (United Kingdom) | https://guide.michelin.com/us/en/saint-helier/saint-helier/restaurant/bohemia |
| MICHELIN Service Award | Barbara Nealon | Saint Francis Provisions, Kinsale | yes — Bib Gourmand (Ireland) | https://guide.michelin.com/us/en/cork/kinsale/restaurant/saint-francis-provisions |
| MICHELIN Sommelier Award | Roxane Dupuy | Row on 5, London | yes — Two Stars (United Kingdom) | https://guide.michelin.com/us/en/greater-london/london/restaurant/row-on-5 |
| MICHELIN Exceptional Cocktails Award (sponsored by Tokaj) | Alasdair Shaw | Sebb's, Glasgow City | yes — Bib Gourmand (United Kingdom) | https://guide.michelin.com/us/en/glasgow-city/glasgow/restaurant/sebb-s |

## 11. SHA-256 of the final CSV

`6251b45cfd845edd40eb44a621a686c224123d2261b6989a2544970c54de9a3a`  michelin-2026-great-britain-ireland.csv (84484 bytes, 386 data rows + 1 header, UTF-8, LF line endings)

## Other sources

- Ceremony date and place (Monday 9 February 2026, Convention Centre Dublin) and Bib announcement date (Monday 2 February 2026): https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-stars-news-uk-ireland-2026
