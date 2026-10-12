# Michelin 2026 Taiwan — capture log

Run date: Sunday, October 11, 2026 (America/New_York).
Brief: `claude/cowork-michelin-2026-taiwan.md` (sha256 b2ba863c7385b5bf14912c786800b2affcf4b8f9389a9f89dc0487dc315da1c5, same as `docs/` in the repo).
Browser: Claude in Chrome (the extension). No database or repo access in this run.
Result: 207 rows. 3 Three Stars, 9 Two Stars, 49 One Star, 146 Bib Gourmand. All counts match Michelin.

---

## 1. Method (copy this part into the next brief)

**Slugs and codes**

| Item | Value | Source |
|---|---|---|
| English country slug | `taiwan-region` | Search box on https://guide.michelin.com/us/en, typed "Taiwan", clicked "Taiwan Region" under Locations, clicked Search. Landed on https://guide.michelin.com/us/en/selection/taiwan-region/restaurants (title "Taiwan Region MICHELIN Restaurants", banner "1-48 of 434 restaurants"). |
| Chinese country slug | `taiwan-region` | Search box on https://guide.michelin.com/tw/zh_TW/, typed "台灣", clicked "台灣地區" under 地點. Landed on https://guide.michelin.com/tw/zh_TW/selection/taiwan-region/restaurants (banner "台灣地區 : 1-48 共 434 個餐廳"). |
| English distinction slugs | `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand` | Distinction filter checkbox values on the English country page. |
| Chinese distinction slugs | `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand` (Selected = `the-plate-michelin`) | Distinction filter checkbox values on the Chinese country page. Same as English. |
| `data-restaurant-country` code | `tw` | Every card in all 8 lists (English and Chinese). Mapped to `Taiwan` in the build script. |

**Notes on the slug.** The 2026 full list article links to `selection/taiwan`. I did not use that link. The search box gave `taiwan-region`. Every list page path contained `/selection/taiwan-region/`, and the script stopped on any other path.

**Page reading (same as Germany, Belgium, Netherlands, with the changes below)**

1. Opened every list page as a full page load in the tab (no in-page `fetch()`).
2. Read only the cards in `.row.restaurant__list-row.js-restaurant__list_items` (48 per page). Each page also had 4 promo cards outside this row (52 `.card__menu` in all). Ignored.
3. Read fields with `textContent`, collapsed whitespace.
4. Fields: name = `h3 a`; URL = `h3 a` href; city = first `.card__menu-footer--score` line minus ", Taiwan Region" (English) or ", 台灣地區" (Chinese); price = second footer line before " · ".
5. Stored rows in `localStorage` under `__tw26_` keys. Extraction functions stored as strings: `__tw26_fn` (lists), `__tw26_vfn` (venue pages), `__tw26_dump` (copy blocks). Removed all 33 `__tw26_` keys at the end. Did not read, change or delete other keys (2 older keys from earlier sessions are still there).
6. Copy: rows shown in a `<pre>` as ` | ` separated lines, sorted, in blocks of up to 100 lines. Read each block with the page-text tool. Checked each block against a SHA-256 computed in the browser. Built the CSV with Python from the checked blocks.

**Changes from the brief's method**

- **Four country elements per card.** Each card has 4 elements with `data-restaurant-country` (the note, visited, bookmark and favorite icons). I read all 4 and required them to agree. They did on all 641 cards read.
- **City label.** The English card prints "New Taipei", not "New Taipei City". The CSV keeps the card value "New Taipei" (brief: "the city that the English card prints").
- **Chinese cards print English city names.** Example: "Taipei, 台灣地區". So `city_label_zh` holds the English city word. Only the country part is Chinese.
- **Output limit.** The page-text tool returned full 100-line blocks (about 15,000 characters). No 1,000-character cut. One JavaScript result that returned hash strings came back as "[BLOCKED: Base64 encoded data]". Returning the hashes inside a JSON object worked.
- **Venue function.** I added the printed "Price" line (`.data-sheet__block--row`) to `__tw26_vfn`.
- **Full list article.** A scan of `<p>` and `<li>` tags missed "JL Studio" and the Tainan Green Star line. A walk over all text nodes between headings found them. Use the text-node walk next time.
- **web.archive.org.** The CDX query with `&from=…&to=…` did not load in the tab. The plain form `https://web.archive.org/cdx/search/cdx?url=<page>` worked. I filtered the dates in the page.
- **Extra list for the registers.** I also read the Selected list (`the-plate-michelin`, 227 cards, 5 pages) to answer register questions. No CSV rows came from it.

---

## 2. Counts

**By category**

| Category | CSV rows | Site banner | Distinction filter | Michelin articles | Difference |
|---|---|---|---|---|---|
| Three Stars | 3 | 3 ("1-3 of 3") | 3 | 3 | 0 |
| Two Stars | 9 | 9 ("1-9 of 9") | 9 | 9 | 0 |
| One Star | 49 | 49 ("49-49 of 49" on page 2) | 49 | 49 | 0 |
| Bib Gourmand | 146 | 146 ("145-146 of 146" on page 4) | 146 | 146 | 0 |
| **Total** | **207** | 207 | 207 | 207 | 0 |
| Selected (no rows) | — | 227 | 227 | 227 | — |

Filter text (English): "3 Stars … 3 / 2 Stars … 9 / 1 Star … 49 / Bib Gourmand … 146 / Selected Restaurants … 227". Same numbers on the Chinese filter.
Banner URLs: https://guide.michelin.com/us/en/selection/taiwan-region/restaurants/3-stars-michelin, …/2-stars-michelin, …/1-star-michelin/page/2, …/bib-gourmand/page/4.
Article counts: https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026 (61 stars, 49 One Stars) and https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-2026-bib-gourmand-list (146 Bibs).

**By city and category (CSV rows vs Michelin articles)**

| City (card label) | 3 Stars | 2 Stars | 1 Star | Bib | CSV total | Article Bib/1-Star check |
|---|---|---|---|---|---|---|
| Taipei | 2 | 9 | 36 | 37 | 84 | matches |
| Taichung | 1 | 0 | 5 | 23 | 29 | matches |
| Tainan | 0 | 0 | 1 | 30 | 31 | matches |
| Kaohsiung | 0 | 0 | 6 | 21 | 27 | matches |
| New Taipei | 0 | 0 | 0 | 18 | 18 | matches ("New Taipei City" in articles) |
| Hsinchu County | 0 | 0 | 1 | 10 | 11 | matches |
| Hsinchu City | 0 | 0 | 0 | 7 | 7 | matches |
| **Total** | 3 | 9 | 49 | 146 | 207 | |

Every cell equals the brief's table and the two 2026 articles.

**Raw footer lines (3 cards per city, English)**

| City | Card | Footer line 1 | Footer line 2 |
|---|---|---|---|
| Taipei | A Cut / Ad Astra / Ban Bo | "Taipei, Taiwan Region" (all 3) | "$$$$ · Steakhouse" / "$$$$ · European Contemporary" / "$$$ · Taiwanese contemporary" |
| Taichung | L'Atelier par Yao / Oretachi No Nikuya / SHINEYU | "Taichung, Taiwan Region" | "$$$ · French Contemporary" / "$$$ · Barbecue" / "$$$$ · Cantonese" |
| Tainan | Yu Dao / A Hsing Congee / A Wen Rice Cake | "Tainan, Taiwan Region" | "$$$$ · Taiwanese contemporary" / "$ · Congee" / "$ · Small eats" |
| Kaohsiung | GEN / HAILI / Hābu | "Kaohsiung, Taiwan Region" | "$$$$ · Cantonese" / "$$$ · Modern Cuisine" / "$$$ · Creative" |
| New Taipei | A-ba's Taro Ball / Abba Hakka / Bei Ya Duck Thick Soup | "New Taipei, Taiwan Region" | "$ · Small eats" / "$$ · Hakkanese" / "$ · Small eats" |
| Hsinchu County | Sushi An / Ang Gu / Bebu | "Hsinchu County, Taiwan Region" | "$$$$ · Sushi" / "$ · Noodles" / "$$ · Hakkanese" |
| Hsinchu City | Cat House / Dongmen Rice Noodle Soup / Garden.V | "Hsinchu City, Taiwan Region" | "$ · Noodles" / "$ · Small eats" / "$$ · Jiangzhe" |

Country part of the footer: "Taiwan Region" on all 207 English cards; "台灣地區" on all 207 Chinese cards (example: A Cut, Ad Astra, Circum- all print "Taipei, 台灣地區"). The site menu also says "Taiwan Region". CSV value: `Taiwan`.

---

## 3. Duplicate, two-category and country checks

| Check | Result |
|---|---|
| Duplicate `source_url` | 0 |
| Same venue (URL part after `/restaurant/`) in two categories | 0 |
| `data-restaurant-country` not `tw` | 0 of 207 English, 0 of 207 Chinese, 0 of 227 Selected |
| `data-dtm-distinction` not equal to the URL filter | 0 (THREE_STARS 3, TWO_STARS 9, ONE_STAR 49, BIB_GOURMAND 146) |
| Price on card not equal to footer text before " · " | 0 |
| Non-ASCII characters in `source_url` | 0 (no percent-encoding needed) |
| Fields that needed CSV quotes | 0 |

---

## 4. Edition checks (scope rules 1 and 2)

**2026 check — 3 venue pages (meta description and JSON-LD `award`)**

| Category | Venue page | Meta description (key phrase) | JSON-LD `award.awardFor` / `dateAwarded` |
|---|---|---|---|
| Two Stars | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/mizue | "Two Stars: Excellent cooking restaurant in the 2026 MICHELIN Guide Taiwan" | "Two Stars: Excellent cooking" / "2026" |
| One Star | https://guide.michelin.com/us/en/northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an | "One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Taiwan" | "One Star: High quality cooking" / "2026" |
| Bib Gourmand | https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/baa-wanli-goat | "Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide Taiwan" | "Bib Gourmand: good quality, good value cooking" / "2026" |

Result: the site shows the 2026 selection. No page said 2025.

**2027 check.** No Taiwan list or venue page showed 2027. Every venue page I opened said 2026 (Mizue, Sushi An, BAA Wanli Goat, Yu Dao, JL STUDIO, A-ba's Taro Ball, A). The only "2027" I saw was a related-article link to the Chengdu 2027 selection (China), on https://guide.michelin.com/mo/en/article/michelin-guide-ceremony/michelin-guide-taiwan-starred-restaurant-2025. Not Taiwan. No stop.

**Seven named 2026 changes — all present in the right category**

| Venue | Expected | Card category | Card city | URL |
|---|---|---|---|---|
| Mizue | Two Stars (new) | Two Stars | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/mizue |
| NOBUO | Two Stars (promoted) | Two Stars | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/nobuo |
| Yu Dao | One Star | One Star | Tainan | https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/yu-dao |
| Sushi An | One Star | One Star | Hsinchu County | https://guide.michelin.com/us/en/northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an |
| Hābu | One Star | One Star | Kaohsiung | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/habu |
| BAA Wanli Goat | Bib Gourmand | Bib Gourmand | Tainan | https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/baa-wanli-goat |
| Monsoon | Bib Gourmand | Bib Gourmand | Hsinchu County | https://guide.michelin.com/us/en/northern-taiwan/hsinchu-county_2853127/restaurant/monsoon-1245161 |

---

## 5. Full list article (scope rule 3)

Source: https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list (title "The Full List of the MICHELIN Guide Taiwan 2026").

| Category | Article heading | Text lines | Names | Cards | By city (names) |
|---|---|---|---|---|---|
| Three Stars | "3 Three-MICHELIN-Starred Restaurants" | 3 | 3 | 3 | Taipei 2, Taichung 1 |
| Two Stars | "9 Two-MICHELIN-Star Restaurants" | 9 | 9 | 9 | Taipei 9 |
| One Star | "49 One-MICHELIN-Star Restaurants" | 47 | 48 | 49 | Taipei 36, Taichung 5, Tainan 1, Kaohsiung 6 |

- **Why 47 lines but 48 names.** "ZEA" and "Ya Ge" print together on one Taipei line ("ZEA Ya Ge"). So the article names 35 Taipei lines but 36 Taipei One Stars. This explains the "Taipei 35" in the brief's plain fetch.
- **One Star card that the article does not name: 1.** Sushi An (Hsinchu County), https://guide.michelin.com/us/en/northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an. The article has no Hsinchu County heading in the One Star part, and the name "Sushi An" does not appear anywhere in the article. The ceremony article names it as a new One Star and the first in Hsinchu County (https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026).
- **Every article star name has a card in the same category.** 0 missing, 0 category differences.
- **Spelling difference:** the article prints "JL Studio"; the card prints "JL STUDIO". The CSV uses the card.
- **Entries marked closed:** none. I searched the full list article, the 2026 ceremony article and the 2026 Bib article for "closed", "closure", "permanently" and "relocat". No hits.

---

## 6. 2025 versus 2026 stars (scope rule 4) and totals (scope rule 5)

**2025 sources**
- 2025 ceremony article: https://guide.michelin.com/mo/en/article/michelin-guide-ceremony/michelin-guide-taiwan-starred-restaurant-2025 (dated 19 August 2025). Names the 7 Two Stars (A, Eika, Yu Kapo promoted; L'Atelier de Joël Robuchon, logy, Molino de Urdániz, Mudan) and the 8 new One Stars (the FRONT HOUSE, aMaze, Chuan Ya, FRASSI, Motoichi, La Vie by Thomas Bühner, Sushi Kajin, Hosu). Says 53 stars, 43 One Stars (34 Taipei, 5 Taichung, 4 Kaohsiung).
- **Archive capture found:** https://web.archive.org/web/20251115192102/https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list. Title "The Full List of the MICHELIN Guide Taiwan 2025". Headings: 3 Three Stars, 7 Two Stars, 43 One Stars, 6 Green Stars, 222 Selected. I used it as the 2025 star list. It lists 3 / 7 / 43 names (One Star: Taipei 34, Taichung 5, Kaohsiung 4), which match the 2025 ceremony article.
- Other captures in the window (CDX, https://web.archive.org/cdx/search/cdx?url=guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list): 20250904151351 (200), 20250929034821 (200), 20251115192102 (200, used), 20260208180839 (301), 20260212200511 (200), 20260701222649 (202), 20260702145946 (202), 20260702145950 (202).

**2025 star entries not in the 2026 star lists**

| Venue | 2025 | 2026 card today | URL |
|---|---|---|---|
| Fleur de Sel (Taichung) | One Star | Selected | https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/fleur-de-sel-1188695 |
| Paris 1930 de Hideki Takayama (Taipei) | One Star | Selected | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/paris-1930-de-hideki-takayama |

**Category change between years (in both lists)**

| Venue | 2025 | 2026 | URL |
|---|---|---|---|
| NOBUO (Taipei) | One Star | Two Stars | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/nobuo |

**2026 star entries not in the 2025 star lists**

| Venue | 2026 | City |
|---|---|---|
| Mizue | Two Stars | Taipei |
| Kiku | One Star | Taipei |
| Mume | One Star | Taipei |
| Silks House | One Star | Taipei |
| Restaurant 12 | One Star | Taipei |
| SHINEYU | One Star | Taichung |
| Yu Dao | One Star | Tainan |
| Hābu | One Star | Kaohsiung |
| Nibbon | One Star | Kaohsiung |
| Sushi An | One Star | Hsinchu County (not in the 2026 full list article either; see part 5) |

Arithmetic check: 43 One Stars (2025) − Fleur de Sel − Paris 1930 − NOBUO (up to Two Stars) + 9 new = 49. Two Stars: 7 + Mizue + NOBUO = 9. Three Stars: same 3.
Spelling between years: the 2025 capture prints "Sens"; the 2026 card prints "SENS".
The 2025 Bib list was not rebuilt (brief).

**Totals (scope rule 5).** Stars: 61 rows, difference from 61 = 0. Bibs: 146 rows, difference from 146 = 0. Nothing to explain.

**13 new 2026 Bibs** (https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-2026-bib-gourmand-list) all have Bib cards with the same name: Ching Jiao, Open Smile, Toriaezu Curry, Yu Yu 1969 (Taipei); Don Moo (Taichung); BAA Wanli Goat, CHAN CHI, Zhu-Ji Dong Tsai Ya (Tainan); Abba Hakka, Bei Ya Duck Thick Soup, Bitan Chiao Tou Goose (New Taipei); Monsoon, Yi Ge Rice Vermicelli (Hsinchu County).

---

## 7. Excluded cards

None. All 207 English cards in the four lists carry `tw`. No card from another country or territory appeared.
Out of scope and not in the CSV: 227 Selected cards (Green Star venues that are Selected are listed in part 12).

---

## 8. Price and currency

**Rows per `price_symbol_raw` value**

| Value | Rows |
|---|---|
| `$` | 86 |
| `$$` | 64 |
| `$$$` | 20 |
| `$$$$` | 37 |
| (blank) | 0 |

- The site prints the dollar sign `$` (U+0024) on both the `/us/en/` and the `/tw/zh_TW/` cards. All 207 joined pairs have the same price string.
- I copied the symbols as printed. No conversion. No currency guess.
- Rows with no price: none.

**Venue-page price lines (3 venues, both languages)**

| Venue | Card | `/us/en/` page "Price" line | `/tw/zh_TW/` page "價錢" line |
|---|---|---|---|
| Mizue | $$$$ | "Price: $$$$" | "價錢: $$$$" (https://guide.michelin.com/tw/zh_TW/taipei-region/taipei/restaurant/mizue) |
| Sushi An | $$$$ | "Price: $$$$" | "價錢: $$$$" (https://guide.michelin.com/tw/zh_TW/northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an) |
| BAA Wanli Goat | $$ | "Price: $$" | "價錢: $$" (https://guide.michelin.com/tw/zh_TW/tainan-region/tainan/restaurant/baa-wanli-goat) |

JSON-LD `priceRange` was not used (brief).

---

## 9. Six venue-page spot checks

| Category | Venue | Card city | Page address ends with | Card price | Page price | Page distinction | Match |
|---|---|---|---|---|---|---|---|
| Three Stars | JL STUDIO | Taichung | "…West District, Taichung, Taiwan Region" | $$$$ | $$$$ | Three Stars 2026 | yes |
| Two Stars | Mizue | Taipei | "…Songshan District, Taipei, 105021, Taiwan Region" | $$$$ | $$$$ | Two Stars 2026 | yes |
| One Star | Sushi An (Hsinchu County) | Hsinchu County | "…Zhubei City, Hsinchu County, Taiwan Region" | $$$$ | $$$$ | One Star 2026 | yes |
| One Star | Yu Dao | Tainan | "…Anping District, Tainan, Taiwan Region" | $$$$ | $$$$ | One Star 2026 | yes |
| Bib Gourmand | BAA Wanli Goat | Tainan | (Tainan) | $$ | $$ | Bib Gourmand 2026 | yes |
| Bib Gourmand | A-ba's Taro Ball (New Taipei) | New Taipei | "…Yonghe District, New Taipei, Taiwan Region" | $ | $ | Bib Gourmand 2026 | yes |

URLs: https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/jl-studio, …/taipei-region/taipei/restaurant/mizue, …/northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an, …/tainan-region/tainan/restaurant/yu-dao, …/tainan-region/tainan/restaurant/baa-wanli-goat, …/northern-taiwan/new-taipei-city_2853082/restaurant/a-ba-s-taro-ball (all under https://guide.michelin.com/us/en/). The page `h1` equals the card name on all six.

---

## 10. Pass 2 (Traditional Chinese)

| Item | Result |
|---|---|
| Rows per category | Three Stars 3, Two Stars 9, One Star 49, Bib Gourmand 146 (banners: "1-3 共 3", "1-9 共 9", "49-49 共 49", "145-146 共 146") |
| Joined to Pass 1 on the URL part after `/restaurant/` | 207 of 207 |
| Rows that did not join | 0 |
| Chinese category differs from English | 0 |
| Chinese price differs from English | 0 |
| Chinese name same as English name | 25 |

**Same name in both languages (25):** JL STUDIO, A, logy, Mizue, NOBUO, A Cut, Ad Astra, Circum-, de nuit, FRASSI, HAILI, Hābu, Impromptu by Paul Lee, INITA, L'Atelier par Yao, La Vie by Thomas Bühner, Mume, Nibbon, Restaurant 12, SENS, T+T, Wok by O'BOND, ZEA, HUGH dessert dining, Tableau by Craig Yang.

**Chinese city labels (`city_label_zh`) and row counts.** The Chinese cards print the city in English and the country in Chinese ("Taipei, 台灣地區").

| `city_label_zh` | Rows |
|---|---|
| Taipei | 84 |
| Taichung | 29 |
| Tainan | 31 |
| Kaohsiung | 27 |
| New Taipei | 18 |
| Hsinchu County | 11 |
| Hsinchu City | 7 |

Full-width and special punctuation kept as printed, for example "東沐。食在" (U+3002), "阿爸の芋圓" (U+306E), "ㄤ咕麵" (U+3124), "首烏廚EAT". Some Chinese names carry a space or a half-width bracket as printed, for example "鮨 嘉仁", "欣葉 鐘菜", "富錦樹台菜香檳 (松山)".

---

## 11. Status and name register

| Question | English card | Chinese card | Category | City | URL |
|---|---|---|---|---|---|
| JL STUDIO (closed in DB; 3★ 2025 row) | JL STUDIO | JL STUDIO | Three Stars | Taichung | https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/jl-studio |
| 麥謎食驗室 Bue mi .Lab (closed in DB; Bib 2025 row) | no card | no card | — | — | see below |
| Fleur de Sel (1★ 2025 row in DB) | Fleur de Sel | not read (Selected not in Pass 2) | Selected | Taichung | https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/fleur-de-sel-1188695 |
| A (DB venue named "Taipei") | A | A | Two Stars | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/a |

- **JL STUDIO.** The card is Three Stars. The venue page meta says Three Stars in the 2026 guide, JSON-LD `dateAwarded` "2026", address "59, Cunzhong Street, West District, Taichung, Taiwan Region". I found no closure or move note on the page. The ceremony article says it kept Three Stars (https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026).
- **Bue mi .Lab.** No card in the 434 English cards or the 207 Chinese star/Bib cards (searched "bue", "lab", "麥謎"). The venue page https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/bue-mi-lab shows "Restaurant not found". https://guide.michelin.com/tw/zh_TW/tainan-region/tainan/restaurant/bue-mi-lab and https://guide.michelin.com/hk/zh_HK/tainan-region/tainan/restaurant/bue-mi-lab show "找不到餐廳". (URL slug found with a web search of guide.michelin.com.)
- **Fleur de Sel.** The card is in the Selected list (`data-dtm-distinction` empty). The venue page meta says only "a MICHELIN restaurant" and has no JSON-LD award. The 2026 full list article names it under "227 Selected Restaurants", Taichung.
- **A.** Exact card name is the single letter "A" in both languages. Page title "A – Taipei - a MICHELIN Guide Restaurant"; meta says Two Stars in the 2026 guide.

**Names that differ from the database**

| Database name | English card | Chinese card | Category | City | URL |
|---|---|---|---|---|---|
| EIKA 盈科 | Eika | 盈科 | Two Stars | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/eika |
| Yu Kappo | Yu Kapo | 彧割烹 | Two Stars | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/yu-kapo-1198592 |
| 牡丹．極上 天ぷら．本店 | Mudan | 牡丹 | Two Stars | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/mudan |
| 元一 天婦羅 | Motoichi | 元一 | One Star | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/motoichi |
| 明福台菜 | Ming Fu | 明福台菜海產 | One Star | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/ming-fu |
| 謙安和 Ken Anho | Ken Anhe | 謙安和 | One Star | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/ken-an-ho |
| 承 Sho | Sho | 承 | One Star | Kaohsiung | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/sho |
| 方蒔 the FRONT HOUSE | the FRONT HOUSE | 方蒔 | One Star | Kaohsiung | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/the-front-house |
| 澀 Sur- | Sur- | 澀 | One Star | Taichung | https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/sur |
| WOK by obond | Wok by O'BOND | Wok by O'BOND | One Star | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/wok-by-o-bond |
| (ceremony heading "Silk House") | Silks House | 晶華軒 | One Star | Taipei | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/silks-house |

Silks House note: the 2026 ceremony article heading says "Silk House", its body and the full list article say "Silks House", and the card says "Silks House".

**No venue in the database**

| Venue | 2026 card category | English / Chinese card | URL |
|---|---|---|---|
| Molino de Urdániz | Two Stars | Molino de Urdániz / 渥達尼斯磨坊 | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/molino-de-urdaniz |
| aMaze | One Star | aMaze / 心宴 | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/amaze |
| Sushi Kajin | One Star | Sushi Kajin / 鮨 嘉仁 | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/sushi-kajin |

**New Taipei City**

| Category | Cards with English city "New Taipei" |
|---|---|
| Three Stars | 0 |
| Two Stars | 0 |
| One Star | 0 |
| Bib Gourmand | 18 |

English card label: "New Taipei" (not "New Taipei City"). Chinese card label: "New Taipei". URL path part: `northern-taiwan/new-taipei-city_2853082`.

**New stars (exact card names and cities)**

| Venue | English card | Chinese card | Category | City |
|---|---|---|---|---|
| Mizue | Mizue | Mizue | Two Stars | Taipei |
| NOBUO | NOBUO | NOBUO | Two Stars | Taipei |
| Kiku | Kiku | 掬 | One Star | Taipei |
| Mume | Mume | Mume | One Star | Taipei |
| Silks House | Silks House | 晶華軒 | One Star | Taipei |
| SHINEYU | SHINEYU | 山与 | One Star | Taichung |
| Nibbon | Nibbon | Nibbon | One Star | Kaohsiung |
| Sushi An | Sushi An | 鮨安 | One Star | Hsinchu County |
| Hābu | Hābu | Hābu | One Star | Kaohsiung |
| Restaurant 12 | Restaurant 12 | Restaurant 12 | One Star | Taipei |
| Yu Dao | Yu Dao | 予島 | One Star | Tainan |

---

## 12. Hold register (no CSV rows)

**Green Star.** The 2026 ceremony article names 9 (https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026). The full list article has a heading "9 MICHELIN Green Star Restaurants" with the same 9 (https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list).

| Venue | City | Card category today | URL |
|---|---|---|---|
| EMBERS | Taipei | Selected | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/embers |
| Hosu | Taipei | One Star | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/hosu |
| Little Tree Food (Da'an Road) | Taipei | Bib Gourmand | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/little-tree-food-da-an-road |
| Mountain and Sea House | Taipei | One Star | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/mountain-and-sea-house |
| Yangming Spring (Shilin) | Taipei | Selected | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/yangming-spring-shilin |
| Sur- (new) | Taichung | One Star | https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/sur |
| Tu Pang | Taichung | Selected | https://guide.michelin.com/us/en/taichung-region/taichung/restaurant/tu-pang |
| Yu Dao (new) | Tainan | One Star | https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/yu-dao |
| Thomas Chien | Kaohsiung | Selected | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/thomas-chien |

What the 2026 site shows for Taiwan:
- **Filter:** no Green Star filter. None of the 75 filter inputs on https://guide.michelin.com/us/en/selection/taiwan-region/restaurants/1-star-michelin has a green, sustainable or durable value.
- **List mark:** no rendered Green Star mark on list cards. The page holds an unused card template with a `greenStar` slot that points to the `gastronomie-durable` icon, but no rendered card on the One Star list (which has Hosu, Mountain and Sea House, Sur-, Yu Dao) uses it.
- **Venue page:** Yu Dao and EMBERS pages show a green-background chef quote block (`restaurant-details__text-background green`) with the `gastronomie-durable` icon. The words "Green Star" do not appear on those pages.
- **Mindful Voices:** no "Mindful Voices" text on the list page, Yu Dao, or EMBERS.
- No separate Green Star list URL was tried (brief: do not guess a URL).

**Special awards 2026** (all from https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026)

| Award | Person (as printed) | Venue | Venue in today's star or Bib list? | Venue URL |
|---|---|---|---|---|
| Service Award | Cindy TSAI | Circum-, Taipei | yes, One Star | https://guide.michelin.com/us/en/taipei-region/taipei/restaurant/circum |
| Sommelier Award | Bonnie CHIOU | Li.nu, Kaohsiung | no, Selected card | https://guide.michelin.com/us/en/kaohsiung-region/kaohsiung/restaurant/li-nu |
| Young Chef Award | Liu An HSU | Sushi An, Hsinchu County | yes, One Star | https://guide.michelin.com/us/en/northern-taiwan/hsinchu-county_2853127/restaurant/sushi-an |
| Opening of the Year Award | (venue award) | Yu Dao, Tainan | yes, One Star | https://guide.michelin.com/us/en/tainan-region/tainan/restaurant/yu-dao |

**New Additions articles.** The 2026 Bib article links to "June 2026: 6 New Additions to The MICHELIN Guide Taiwan" (before the July 2026 selection). I did not see a later Taiwan "New Additions" article. The live lists match the published 2026 counts exactly, so no card added after July 21 is in the four categories.

---

## 13. Names that are not NFC

- English `venue_name`: none (0 of 207).
- Chinese `venue_name_zh`: none (0 of 207).
Names with accents or macrons are all single code points: Taïrroir, Hābu, L'Atelier de Joël Robuchon, Molino de Urdániz, La Vie by Thomas Bühner, Küisine (West), Pàng, SÒNG JHAO.

---

## 14. Hashes

SHA-256 of sorted lines joined with `\n`, computed in the browser and checked again in the build script.

| Block | Lines | SHA-256 |
|---|---|---|
| English block 1 | 100 | 24dead0b1738552d7e99b7e5a744d3ab63f4dfebd961ab04e810c9f99acf8e38 |
| English block 2 | 100 | e1b1af57e448c7aec1b22a2043e5efbc0f3865d926c80ace0f9638e73489cc27 |
| English block 3 | 7 | d6d10de399539c45e32a927c7c1d1ac7296c1de94f28b2dd272bf70e859c84db |
| **English full data** | 207 | d26ce0079dea2cd236b8712b2a9bcfe3f023ffbd3c3458bd6a2d4abb077e547a |
| Chinese block 1 | 100 | dbcf7096e2aa1f41b25b491784e5f8888312ac164e22621e645185837d2ca2df |
| Chinese block 2 | 100 | 0c66017da425a8117ba9c1aedefb5215ab4e886ee4f7b8a63f62a3dcfebf8d8c |
| Chinese block 3 | 7 | 8fe243b8bae2ed85055966c388aef1a7efedfbb81d447a91cb5e3d50ec8c2b9a |
| **Chinese full data** | 207 | 4bc4aeaed80975895ecf96a63be5598dc9a9a1bd8b129fccdce35d3b5199dda2 |

Block line format: `distinction-slug | name | path | footer line 1 | footer line 2 | price | country code | data-dtm-distinction`.

**Final CSV:** `michelin-2026-taiwan.csv`, 208 lines (header + 207 rows), UTF-8, no BOM, LF line ends.
SHA-256: **835d3cc256b4ca4b6977a65680d154e72884c7a0eadc554567cc1b9f2f8bb046**
Row order: Three Stars, Two Stars, One Star, Bib Gourmand; then by English name.

---

## Delivery note

Both files were sent in the chat. No local folder was connected, so no local copy was saved. Nothing was uploaded to Google Drive. The CSV was not opened in Excel or Numbers.
