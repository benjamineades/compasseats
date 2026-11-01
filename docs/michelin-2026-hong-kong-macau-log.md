# Michelin 2026 Hong Kong & Macau: capture log

Run date: November 1, 2026 (America/New_York). Browser: Claude in Chrome. Batch key: `michelin-2026-hong-kong-macau`.

Result: 180 rows (Hong Kong 146, Macao 34). The brief expected about 181. The one missing row is the Hong Kong Bib Gourmand "Chiuchow Delicacies". The 2026 full list article names it, but the site has no card for it, and its venue page says "Restaurant not found" (part 6).

No database change. No GitHub change. No other guide was read.

---

## 1. Method

**Selection slugs (from the destination search box):**

| Site | Typed | Row clicked under "Locations" | Selection URL |
|---|---|---|---|
| `/us/en/` | Hong Kong | Hong Kong SAR | `https://guide.michelin.com/us/en/selection/hong-kong-sar/restaurants` |
| `/us/en/` | Macau | Macau SAR | `https://guide.michelin.com/us/en/selection/macau-sar/restaurants` |
| `/hk/zh_HK/` | 香港 | 香港特別行政區 | `https://guide.michelin.com/hk/zh_HK/selection/hong-kong-sar/restaurants` |
| `/hk/zh_HK/` | 澳門 | 澳門特別行政區 | `https://guide.michelin.com/hk/zh_HK/selection/macau-sar/restaurants` |

The English and Chinese sites use the same slugs: `hong-kong-sar` and `macau-sar`. The Bib article forms (`/hk/en/restaurants/bib-gourmand` and `selection/macao/...`) were not used.

**Chinese distinction slugs (Distinction filter checkbox values on both zh_HK selection pages):** `3-stars-michelin` (米芝蓮三星), `2-stars-michelin` (米芝蓮二星), `1-star-michelin` (米芝蓮一星), `bib-gourmand` (米芝蓮必比登美食推薦). The fifth value is `the-plate-michelin` (米芝蓮指南入選餐廳, Selected). It was not read.

**`data-restaurant-country` codes:** `hk` = Hong Kong (146 cards), `mo` = Macao (34 cards). The build script maps `hk` → `Hong Kong` and `mo` → `Macao`. No card had another code.

**Page reading and copy:**

1. Each list page was opened in the browser tab and read from the rendered DOM. No in-page `fetch()`.
2. One extraction function was stored under `localStorage.__hkmo26_fn` and run with `eval` on each list page. The function stops with `BADPATH` or `BADSEL` if the path does not match `/<territory>/<lang>/selection/<expected-slug>/restaurants/<distinction>[/page/N]`.
3. The function reads only the children of `.row.restaurant__list-row.js-restaurant__list_items`, with `textContent`. Fields: `h3 a` text and href, footer lines 1 and 2 (`.card__menu-footer--score`), and `data-restaurant-country` and `data-dtm-distinction` from all `[data-restaurant-country]` elements in the card (each card has 4, and all 4 agree on every card).
4. Each page result went to `localStorage.__hkmo26_L_<lang>_<selection>_<distinction>_<page>`.
5. A second function (`__hkmo26_bfn`) built text blocks of up to 100 lines. Fields: `tag | index | name | href | footer1 | footer2 | country code | distinction`, with `\` escaped as `\\` and `|` escaped as `\|`. It computed a SHA-256 for each block (sorted lines joined with `\n`) and for all lines.
6. Each block was shown in a `<pre>`, read with the page-text tool, and saved to a file. The build script hashed each saved block. All 4 block hashes and both full-data hashes match the browser hashes (part 15).
7. A venue-page function (`__hkmo26_vfn`) read title, meta description, JSON-LD `award`, data-sheet blocks and badge images.
8. All 49 `__hkmo26_` keys were removed at the end. No other key was read, changed or removed.

**Changes from the brief method:**

- English block 0 was first shown with 4 extra fields (`data-dtm-city`, `data-dtm-district`, `data-dtm-region`, `data-restaurant-name`). The browser check showed that these fields add nothing: city = `Hong Kong`/`Macau` on all cards, district empty on all 180 cards, and `data-restaurant-name` = card name on all 180 cards. The block was rebuilt with 8 fields. The saved copy of the first display was cut to 8 fields with code, and its hash matches the 8-field browser hash.
- The JSON-LD check output was read from a `<pre>` because tool output with `=` pairs was blocked.

---

## 2. Counts

### By category and selection

| Selection | Category | CSV rows | Site banner | Distinction filter | Published (articles) | Difference rows − published |
|---|---|---|---|---|---|---|
| Hong Kong | Three Stars | 7 | 7 | 7 | 7 | 0 |
| Hong Kong | Two Stars | 13 | 13 | 13 | 13 | 0 |
| Hong Kong | One Star | 57 | 57 | 57 | 57 | 0 |
| Hong Kong | Bib Gourmand | 69 | 69 | 69 | 70 | −1 (part 6) |
| Macau | Three Stars | 2 | 2 | 2 | 2 | 0 |
| Macau | Two Stars | 6 | 6 | 6 | 6 | 0 |
| Macau | One Star | 13 | 13 | 13 | 13 | 0 |
| Macau | Bib Gourmand | 13 | 13 | 13 | 13 | 0 |
| **All** | | **180** | **180** | **180** | **181** | **−1** |

Banner text examples: "Hong Kong SAR : 1-48 of 69 restaurants - Bib Gourmand" and "Hong Kong SAR : 49-69 of 69 restaurants - Bib Gourmand". For each category and selection, rows − banner = 0 and rows − filter = 0.

Selected (not captured): the Distinction filter shows Hong Kong 76 and Macau 27. The 2026 full list article shows 72 and 25. Selection totals on the site: Hong Kong 222, Macau 61. The ceremony article gives 219 and 59.

Pages read: Hong Kong One Star and Bib Gourmand have 2 pages each. All other lists have 1 page. Same on zh_HK.

### By city label and category

| city_label | country_label | Three Stars | Two Stars | One Star | Bib Gourmand | Total |
|---|---|---|---|---|---|---|
| Hong Kong | Hong Kong | 7 | 13 | 57 | 69 | 146 |
| Macau | Macao | 2 | 6 | 13 | 13 | 34 |

---

## 3. Duplicate, two-category and country checks

- Duplicate `source_url`: 0 (180 unique URLs).
- Venue in two categories: 0 (180 unique slugs after `/restaurant/`).
- Country: 146 cards carry `hk` and appear only in `selection/hong-kong-sar`. 34 cards carry `mo` and appear only in `selection/macau-sar`. No card from another place.
- Distinction attribute against URL filter: 0 mismatches (180 English, 180 Chinese).
- Promo cards outside the list row were not read. For example, the Hong Kong One Star page 1 has 208 `[data-restaurant-country]` elements on the page and 192 (48 cards × 4) inside the list row.
- One non-ASCII URL path: `https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/8%C2%BD-otto-e-mezzo-bombana`. The build script percent-encoded it.

---

## 4. 2026 check, 2027 check and the named 2026 changes

### 2026 check (scope rule 1)

| Page | Meta description (exact phrase) | JSON-LD `award` |
|---|---|---|
| https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/cristal-room-by-anne-sophie-pic | "a Two Stars: Excellent cooking restaurant in the 2026 MICHELIN Guide Hong Kong" | awardFor "Two Stars: Excellent cooking", dateAwarded "2026" |
| https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/dragons-den | "a Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide Hong Kong" | awardFor "Bib Gourmand: good quality, good value cooking", dateAwarded "2026" |
| https://guide.michelin.com/us/en/macau-region/macau/restaurant/the-huaiyang-garden | "a Two Stars: Excellent cooking restaurant in the 2026 MICHELIN Guide Macau" | awardFor "Two Stars: Excellent cooking", dateAwarded "2026" |
| https://guide.michelin.com/us/en/macau-region/macau/restaurant/a-lorcha | "a Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide Macau" | awardFor "Bib Gourmand: good quality, good value cooking", dateAwarded "2026" |

All 4 pages say 2026. No page says 2025.

### 2027 check

No Hong Kong or Macau list page, venue page or article that I opened shows a 2027 selection. The "related articles" area of the full list article links 2027 articles for other guides (Manila and Environs & Cebu, Beijing & Tianjin, South Australia, Chengdu). These are not Hong Kong or Macau.

### Named 2026 changes (scope rule 2)

| Name in brief | Card name (exact) | Category on site | Selection | URL |
|---|---|---|---|---|
| Cristal Room by Anne-Sophie Pic | Cristal Room by Anne-Sophie Pic | Two Stars | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/cristal-room-by-anne-sophie-pic |
| L'Atelier De Joël Robuchon | L'Atelier de Joël Robuchon | Two Stars | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/l-atelier-de-joel-robuchon |
| China Tang | China Tang | One Star | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/china-tang-446675 |
| Sushi Takeshi | Sushi Takeshi | One Star | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/sushi-takeshi |
| Don Alfonso 1890 | Don Alfonso 1890 | One Star | Macau | https://guide.michelin.com/us/en/macau-region/macau/restaurant/don-alfonso-1890-1212351 |
| Palace Garden | Palace Garden | One Star | Macau | https://guide.michelin.com/us/en/macau-region/macau/restaurant/palace-garden |
| Dragons' Den | Dragons' Den | Bib Gourmand | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/dragons-den |
| Fiata | Fiata | Bib Gourmand | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/fiata |
| Ho Ho Chak | Ho Ho Chak | Bib Gourmand | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/ho-ho-chak |
| Lai's Kitchen | Lai's Kitchen | Bib Gourmand | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/lai-s-kitchen |
| Siaw | Siaw | Bib Gourmand | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/siaw |
| Uncle Quek | Uncle Quek | Bib Gourmand | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/uncle-quek |
| A Lorcha | A Lorcha | Bib Gourmand | Macau | https://guide.michelin.com/us/en/macau-region/macau/restaurant/a-lorcha |
| Nok Song | Nok Song | Bib Gourmand | Macau | https://guide.michelin.com/us/en/macau-region/macau/restaurant/nok-song |

Three Stars (no change): all 9 are in the Three Stars lists. Hong Kong: 8 1/2 Otto e Mezzo - Bombana, Amber, Caprice, Forum, Sushi Shikon, Ta Vie, T'ang Court. Macau: Jade Dragon, Robuchon au Dôme.

NOTE: The card and the full list article print "L'Atelier de Joël Robuchon" (lower-case "de"). The ceremony article prints "L'Atelier De Joël Robuchon". The CSV uses the card name.

All named changes are in the expected category. There was no reason to stop.

---

## 5. Full list article (scope rule 3)

Source: https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list (title "The Full List of the MICHELIN Guide Hong Kong & Macau 2026", dated 19 March 2026).

| Selection | Section heading | Heading count | Names in section |
|---|---|---|---|
| Hong Kong | Three-MICHELIN-Starred | 7 | 7 |
| Hong Kong | Two-MICHELIN-Starred | 13 | 13 |
| Hong Kong | One-MICHELIN-Starred | 57 | 57 |
| Hong Kong | Selected | 72 | 72 |
| Hong Kong | Green Star | 4 | 4 |
| Hong Kong | Bib Gourmands | 70 | 70 |
| Macau | Three-MICHELIN-starred | 2 | 2 |
| Macau | Two-MICHELIN-Starred | 6 | 6 |
| Macau | One-MICHELIN-Starred | 13 | **11** |
| Macau | Selected | 25 | 25 |
| Macau | Green Star | 1 | 1 |
| Macau | Bib Gourmand | 13 | 13 |

**The 2 Macau One Star cards that the article does not name:**

| Card name | Chinese card name | URL | Venue page |
|---|---|---|---|
| 8 1/2 Otto e Mezzo - Bombana | 8 1/2 Otto e Mezzo - Bombana | https://guide.michelin.com/us/en/macau-region/macau/restaurant/8-1-2-otto-e-mezzo-bombana | meta "a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Macau", JSON-LD One Star / 2026 |
| Aji | 雅吉 | https://guide.michelin.com/us/en/macau-region/macau/restaurant/aji-1215915 | meta "a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Macau", JSON-LD One Star / 2026 |

Both were Macau One Star in the 2025 full list (part 6).

**Closed entries:** no 2026 or 2025 article that I read marks any entry as closed.

**Name differences between the 2026 article and the cards (same venue):**

| Article name | Card name | Selection, category |
|---|---|---|
| Tak Kee | Tak Kee Chiu Chou Restaurant (URL `.../restaurant/tak-kee`) | Hong Kong, Bib |
| Café Hunan (Western District) | Prof Chan's (Western District) | Hong Kong, Bib |
| Lok Kei Noodles (Patane) | Lok Kei Noodles | Macau, Bib |
| O Castiço | O Castiço (Taipa) | Macau, Bib |

The URL `https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/cafe-hunan-western-district` redirects to `https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/prof-chan-s-western-district`. The Prof Chan's card is a 2026 Bib Gourmand.

---

## 6. 2025 compared with 2026 (scope rules 4 and 5)

**2025 sources:**

- Ceremony article 2025: https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2025
- web.archive.org capture of the full list page, title "The Full List of the MICHELIN Guide Hong Kong & Macau 2025": https://web.archive.org/web/20251229115831/https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list
- Captures in the date window (CDX): 20250423084204, 20250523051522, 20250607165933, 20251229115831. I used the last one.

2025 capture counts: Hong Kong 3★ 7, 2★ 11, 1★ 58, Bib 65, Selected 65. Macau 3★ 2, 2★ 6, 1★ 11, Bib 11, Selected 24. These agree with the 2025 ceremony article for the star counts.

### Stars

| Name | 2025 | 2026 | Selection |
|---|---|---|---|
| Sushi Saito | One Star | not in 2026 lists | Hong Kong |
| Zuicho | One Star | not in 2026 lists | Hong Kong |
| Cristal Room by Anne-Sophie Pic | One Star | Two Stars | Hong Kong |
| L'Atelier de Joël Robuchon | not in 2025 lists | Two Stars | Hong Kong |
| China Tang | not in 2025 lists | One Star | Hong Kong |
| Sushi Takeshi | not in 2025 lists | One Star | Hong Kong |
| Don Alfonso 1890 | Selected | One Star | Macau |
| Palace Garden | Selected | One Star | Macau |

Arithmetic: Hong Kong One Star 58 − 2 (Sushi Saito, Zuicho) − 1 (Cristal Room) + 2 (China Tang, Sushi Takeshi) = 57. Hong Kong Two Stars 11 + 2 = 13. Macau One Star 11 + 2 = 13. Three Stars: no change.

The Hong Kong Zuicho page https://guide.michelin.com/hk/en/hong-kong-region/hong-kong/restaurant/zuicho says "Restaurant not found".

### Bib Gourmand

Hong Kong, 2025 Bib not on a 2026 card:

| 2025 name | 2026 status |
|---|---|
| Chiuchow Delicacies | No card. https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/chiuchow-delicacies says "Restaurant not found". The 2026 full list article still names it. |
| Man Yuen | Not in the 2026 lists or the 2026 article |
| Sun Yuen Hing Kee | Not in the 2026 lists or the 2026 article |
| What To Eat | Not in the 2026 lists or the 2026 article |

Hong Kong, label changes (same venue, Bib in both years): Ah Chun Shandong Dumpling → Ah Chun Shandong Dumpling (Prince Edward); Café Hunan (Western District) → Prof Chan's (Western District); Tai Wai Dining Room (Tai Wai) → Tai Wai Dining Room; Tak Kee → Tak Kee Chiu Chou Restaurant; Thai Pai Dong → Thai Pai Dong (Jordan).

Hong Kong, 2026 Bib not in the 2025 Bib list: Dragons' Den, Fiata, Ho Ho Chak, Lai's Kitchen, Siaw, Uncle Quek (the 6 new Bibs in the Bib article), and Hung's Delicacies and Lulu Baobao (Wong Chuk Hang). The 2026 full list article does not mark these last 2 as new.

Macau: A Lorcha (Selected in 2025) and Nok Song are new Bibs. Label changes: Lok Kei Noodles (Patane) → Lok Kei Noodles; O Castiço → O Castiço (Taipa); Restaurante Litoral (Taipa) → Restaurant Litoral (Taipa). No 2025 Macau Bib was removed.

Bib article: https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-guide-hong-kong-macau-bib-gourmand-selection-2026 says "8 establishments have newly received Bib Gourmand distinctions … bringing the total to 83 … 70 in Hong Kong" and 13 in Macau.

### Difference from the published counts (scope rule 5)

Only one: Hong Kong Bib Gourmand, 69 rows against 70 published. The restaurant is **Chiuchow Delicacies**. The article names it, but it has no card and its venue page says "Restaurant not found". All other categories: difference 0.

Against the database reference (legacy rows labelled 2025): Hong Kong One Star 56 → 57 rows now, Hong Kong Bib 69 → 69, Macau the same in all categories. I did not read the database. These numbers come from the brief.

---

## 7. Excluded cards

None. All list cards carry `hk` or `mo`. Out-of-scope items that I saw only in site search (not in any list): "Lai Heen" Guangzhou, Chinese Mainland (https://guide.michelin.com/us/en/guangdong-province/guangzhou/restaurant/lai-heen-559155), "Zuicho" Singapore (https://guide.michelin.com/us/en/singapore-region/singapore/restaurant/zuicho-1213876).

---

## 8. Price and currency

The cards print the symbol `$`. The CSV keeps it as printed. I did not convert it.

| Selection | `$` | `$$` | `$$$` | `$$$$` | Blank | Total |
|---|---|---|---|---|---|---|
| Hong Kong | 26 | 57 | 34 | 29 | 0 | 146 |
| Macao | 2 | 13 | 10 | 9 | 0 | 34 |

Price check (card against the printed price line, English page against Chinese page):

| Venue | Card | `/us/en/` page | `/hk/zh_HK/` page |
|---|---|---|---|
| Cristal Room by Anne-Sophie Pic (HK) | $$$$ | Price: $$$$ | 價錢: $$$$ |
| Dragons' Den (HK) | $$ | Price: $$ | 價錢: $$ |
| The Huaiyang Garden (Macau) | $$$ | Price: $$$ | 價錢: $$$ |
| A Lorcha (Macau) | $$ | Price: $$ | 價錢: $$ |

All 180 rows also have the same price on the English and Chinese cards (0 differences). JSON-LD `priceRange` holds a word label (for example "Spare no expense"). It was not used.

---

## 9. Venue-page spot checks

| Selection | Category | Card name | Page name | Distinction on page | Price card / page | Card city | Page address (end) | Result |
|---|---|---|---|---|---|---|---|---|
| Hong Kong | Bib | Dragons' Den | Dragons' Den | Bib Gourmand / 2026 | $$ / $$ | Hong Kong | "…Wong Tai Sin, Hong Kong, Hong Kong SAR" | Match |
| Hong Kong | One Star | Sushi Takeshi | Sushi Takeshi | One Star / 2026 | $$$$ / $$$$ | Hong Kong | "…Tsim Sha Tsui, Hong Kong, Hong Kong SAR" | Match |
| Hong Kong | Two Stars | Cristal Room by Anne-Sophie Pic | same | Two Stars / 2026 | $$$$ / $$$$ | Hong Kong | "…Central, Hong Kong, Hong Kong SAR" | Match |
| Macau | Bib | A Lorcha | A Lorcha | Bib Gourmand / 2026 | $$ / $$ | Macau | "…Macau, Macau, Macau SAR" | Match |
| Macau | One Star | Palace Garden | Palace Garden | One Star / 2026 | $$$ / $$$ | Macau | "…Cotai, Macau, Macau SAR" | Match |
| Macau | Two Stars | The Huaiyang Garden | The Huaiyang Garden | Two Stars / 2026 | $$$ / $$$ | Macau | "…Cotai, Macau, Macau SAR" | Match |

URLs are in part 4. Palace Garden: https://guide.michelin.com/us/en/macau-region/macau/restaurant/palace-garden. Sushi Takeshi: https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/sushi-takeshi.

NOTE: The venue page address shows a district (Central, Wong Tai Sin, Tsim Sha Tsui, Cotai). The card footer does not show a district.

---

## 10. Pass 2 (Traditional Chinese)

| Selection | Category | zh_HK rows | Banner | Filter |
|---|---|---|---|---|
| Hong Kong | Three Stars | 7 | 7 | 7 |
| Hong Kong | Two Stars | 13 | 13 | 13 |
| Hong Kong | One Star | 57 | 57 | 57 |
| Hong Kong | Bib Gourmand | 69 | 69 | 69 |
| Macau | Three Stars | 2 | 2 | 2 |
| Macau | Two Stars | 6 | 6 | 6 |
| Macau | One Star | 13 | 13 | 13 |
| Macau | Bib Gourmand | 13 | 13 | 13 |

- Joined rows: 180 of 180 (join on the part after `/restaurant/`).
- Rows not joined: 0.
- Rows where the Chinese category differs from the English category: 0.
- Chinese city labels: `Hong Kong` 146 rows, `Macau` 34 rows. The raw Chinese footer is "Hong Kong, 香港特別行政區" or "Macau, 澳門特別行政區". The city part is in English on the Chinese cards. `city_label_zh` holds that city part.
- Rows where the Chinese name is the same as the English name: 45. Amber; 8 1/2 Otto e Mezzo - Bombana (Hong Kong); Caprice; Octavium; L'Envol; Noi by Paulo Airaudo; Cristal Room by Anne-Sophie Pic; Arbor; L'Atelier de Joël Robuchon; Tosca di Angelo; Sushi Wadatsumi; Chaat; Sushi Takeshi; Épure; Tuber Umberto Bombana; Louise; Beefbar; Feuille; Hansik Goo; Belon; Andō; Mono; Arcane; New Punjab Club; Estro; Whey; Racines; Ryota Kappou Modern; Plaisance by Mauro Colagreco; Neighborhood; Yardbird; Roganic; Vea; Godenya; Ami; Saya; Uncle Quek; Art & Taste; Juno; Fiata; Ăn Chơi; Little Napoli; Lulu Baobao (Wong Chuk Hang); 8 1/2 Otto e Mezzo - Bombana (Macau); O Castiço (Taipa).

---

## 11. Raw footer lines

English card footer line 1 is the same on every card in a selection: "Hong Kong, Hong Kong SAR" (146 cards) and "Macau, Macau SAR" (34 cards). The lists show no Kowloon, Cotai or Taipa footer.

| Card | Raw footer line 1 | city_label |
|---|---|---|
| Loaf On (HK One Star) | Hong Kong, Hong Kong SAR | Hong Kong |
| Cristal Room by Anne-Sophie Pic (HK Two Stars) | Hong Kong, Hong Kong SAR | Hong Kong |
| T'ang Court (HK Three Stars) | Hong Kong, Hong Kong SAR | Hong Kong |
| Tim Ho Wan (Sham Shui Po) (HK Bib, Kowloon) | Hong Kong, Hong Kong SAR | Hong Kong |
| Sushi Takeshi (HK One Star, Tsim Sha Tsui address) | Hong Kong, Hong Kong SAR | Hong Kong |
| Lok Kei Noodles (Macau Bib) | Macau, Macau SAR | Macau |
| A Lorcha (Macau Bib) | Macau, Macau SAR | Macau |
| Palace Garden (Macau One Star, Cotai address) | Macau, Macau SAR | Macau |
| O Castiço (Taipa) (Macau Bib) | Macau, Macau SAR | Macau |
| Restaurant Litoral (Taipa) (Macau Bib) | Macau, Macau SAR | Macau |

The `data-dtm-district` attribute is empty on all 180 cards. Footer line 2 is "<price> · <cuisine>" on all cards.

---

## 12. Status and name register

### 8 1/2 Otto e Mezzo - Bombana

| Selection | English card | Chinese card | Category | City | URL |
|---|---|---|---|---|---|
| Hong Kong | 8 1/2 Otto e Mezzo - Bombana | 8 1/2 Otto e Mezzo - Bombana | Three Stars | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/8%C2%BD-otto-e-mezzo-bombana |
| Macau | 8 1/2 Otto e Mezzo - Bombana | 8 1/2 Otto e Mezzo - Bombana | One Star | Macau | https://guide.michelin.com/us/en/macau-region/macau/restaurant/8-1-2-otto-e-mezzo-bombana |

### Lai Heen (Hong Kong)

| Card | Chinese card | Category | Selection | URL |
|---|---|---|---|---|
| Lai Ching Heen | 麗晶軒 | Two Stars | Hong Kong | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/lai-ching-heen |
| Lai Heen | 麗軒 | One Star | Macau | https://guide.michelin.com/us/en/macau-region/macau/restaurant/lai-heen |

No Hong Kong card is named "Lai Heen". Site search for "Lai Heen" returns 3 cards: Lai Heen (Guangzhou), Lai Ching Heen (Hong Kong), Lai Heen (Macau).

### Names that differ from the database

All are Hong Kong cards except Feng Wei Ju, The Huaiyang Garden, Aji and Justindia (Macau).

| Database name | English card | Chinese card | Category | URL |
|---|---|---|---|---|
| Tin Lung Heen \| The Ritz-Carlton, Hong Kong | Tin Lung Heen | 天龍軒 | Two Stars | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/tin-lung-heen |
| Joël Robuchon (Two Stars) | L'Atelier de Joël Robuchon | L'Atelier de Joël Robuchon | Two Stars | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/l-atelier-de-joel-robuchon |
| 富臨飯店 Forum Restaurant | Forum | 富臨飯店 | Three Stars | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/forum |
| The Huai Yang Garden | The Huaiyang Garden | 淮揚曉宴 | Two Stars (Macau) | https://guide.michelin.com/us/en/macau-region/macau/restaurant/the-huaiyang-garden |
| Octavium Italian Restaurant | Octavium | Octavium | Two Stars | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/octavium |
| Spring Moon 嘉麟樓 | Spring Moon | 嘉麟樓 | One Star | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/spring-moon |
| Sushi Takeshi 鮨たけし | Sushi Takeshi | Sushi Takeshi | One Star | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/sushi-takeshi |
| 鮨わだつみ Sushi Wadatsumi (K11 MUSEA) | Sushi Wadatsumi | Sushi Wadatsumi | One Star | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/sushi-wadatsumi-1197866 |
| Art & Taste (美食台灣餐廳) | Art & Taste | Art & Taste | Bib Gourmand | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/art-taste |
| lulu BAOBAO 手工拉麵小籠包 [ Wong Chuk Hang ] | Lulu Baobao (Wong Chuk Hang) | Lulu Baobao (Wong Chuk Hang) | Bib Gourmand | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/lulu-baobao |
| 聚興家 Ju Xing Home | Ju Xing Home | 聚興家 | Bib Gourmand | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/ju-xing-home |
| 船記 Ship Kee | Ship Kee | 船記 | Bib Gourmand | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/ship-kee |
| 賀賀澤-潮州海鮮小炒 Ho Ho Chak Chiu Chow Restaurant | Ho Ho Chak | 賀賀澤 | Bib Gourmand | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/ho-ho-chak |
| FENG WEI JU 風味居 | Feng Wei Ju | 風味居 | Two Stars (Macau) | https://guide.michelin.com/us/en/macau-region/macau/restaurant/feng-wei-ju |
| Aji 雅吉 | Aji | 雅吉 | One Star (Macau) | https://guide.michelin.com/us/en/macau-region/macau/restaurant/aji-1215915 |
| JUSTINDIA 印象派 | Justindia | 印象派 | Bib Gourmand (Macau) | https://guide.michelin.com/us/en/macau-region/macau/restaurant/justindia |

NOTE: The ceremony article and the card both print "The Huaiyang Garden".

### Same name in both selections

| Name | Selection | Category | URL | Source |
|---|---|---|---|---|
| Zuicho (瑞兆) | Macau | One Star | https://guide.michelin.com/us/en/macau-region/macau/restaurant/zuicho-1214683 | list card |
| Zuicho | Hong Kong | no card | https://guide.michelin.com/hk/en/hong-kong-region/hong-kong/restaurant/zuicho | page says "Restaurant not found". It was Hong Kong One Star in the 2025 full list. |
| Mesa | Macau | Selected (not in the 4 lists) | https://guide.michelin.com/us/en/macau-region/macau/restaurant/mesa-1204318 | venue page: no badge, no JSON-LD award, meta "Mesa – a restaurant in the 2026 MICHELIN Guide Macau", Price: $$$, address "…Cotai, Macau, Macau SAR". The 2026 article lists "Mesa (NEW)" under Macau Selected. |

Site search for "Mesa" shows 1 Macau card only (the other "Mesa" card is in Croutelle, France). The database has 2 Macau Mesa venues. The site has 1.

### Duddell's (Hong Kong)

Card "Duddell's" / 都爹利會館, One Star, Hong Kong. URL: https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s. This is the same URL as the database 2026 One Star row. Venue page: One Star / 2026, Price: $$$.

### New stars (exact card name and city)

| Card name | Category | city_label | Chinese card |
|---|---|---|---|
| Cristal Room by Anne-Sophie Pic | Two Stars | Hong Kong | Cristal Room by Anne-Sophie Pic |
| L'Atelier de Joël Robuchon | Two Stars | Hong Kong | L'Atelier de Joël Robuchon |
| China Tang | One Star | Hong Kong | 唐人館 |
| Sushi Takeshi | One Star | Hong Kong | Sushi Takeshi |
| Don Alfonso 1890 | One Star | Macau | 當奥豐素1890 |
| Palace Garden | One Star | Macau | 御花園 |

---

## 13. Hold register (no CSV rows)

### Green Star

Source: ceremony article 2026, https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026 ("5 Restaurants Maintained Their MICHELIN Green Star Recognition"). The full list article also gives a Green Star section for each selection (Hong Kong 4, Macau 1).

- Selection pages: no Green Star filter, list or mark on either selection (Hong Kong SAR, Macau SAR). The filter keywords hold no "Green", "sustainable" or "mindful" item.
- Venue pages: each of the 5 venue pages has a green sustainability statement block (class `restaurant-details__text-background green`). A control page (Cristal Room) does not have this block.

| Venue | Selection | 2026 list category | Venue page with green block |
|---|---|---|---|
| Amber | Hong Kong | Three Stars | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/amber569032 |
| Feuille | Hong Kong | One Star | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/feuille |
| Mora | Hong Kong | One Star | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/mora |
| Roganic | Hong Kong | One Star | https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/roganic1185143 |
| UTM Educational Restaurant | Macau | Bib Gourmand | https://guide.michelin.com/us/en/macau-region/macau/restaurant/ift-educational-restaurant |

### Special awards 2026

Source: same ceremony article.

| Award | Person | Venue | In today's star or Bib list |
|---|---|---|---|
| Young Chef Award | Kim GwanJu | Sol (Hong Kong) | No. The article calls Sol "newly Selected", and the full list article lists "Sol (NEW)" under Hong Kong Selected. |
| Service Award | Jenny Ye | The Huaiyang Garden (Macau) | Yes, Two Stars |
| Sommelier Award | Floriane Hureau | Caprice (Hong Kong) | Yes, Three Stars |
| MICHELIN Guide Mentor Chef Award (first time in Hong Kong and Macau) | Lau Ping Lui, Paul | Tin Lung Heen (Hong Kong) | Yes, Two Stars |

---

## 14. Names that are not NFC

English: none. Chinese: none.

---

## 15. Hashes

Block hashes (SHA-256 of the sorted block lines joined with `\n`). The browser hash and the saved-file hash match for each block.

| Block | Lines | SHA-256 |
|---|---|---|
| English block 0 | 100 | `4fdcd207ac88e2dbdc006004694f2146c97bfcb6d34a7fe39677a892287941ab` |
| English block 1 | 80 | `163c4f21064306324bd316aa4a116c063221354ea6afc5757a4e2a91d0baf71c` |
| English full data | 180 | `d90c6397482576926973f5757ac31a2f06dc3812df174fa306d0d78083dfbeb1` |
| Chinese block 0 | 100 | `a8ddd3c67d7c5e4f6bda57fd67ba5e83ae874def4ab5a395dacabaaf401e0f6d` |
| Chinese block 1 | 80 | `2f0f0dd19163a3a26a4a5e88f9f6e43a985e57b8e65fe4df875afc486174b40b` |
| Chinese full data | 180 | `6e91c29b8060b8e5f09db1c9b910425618523211338738203aecd7af50b13866` |

**Final CSV:** `michelin-2026-hong-kong-macau.csv`, 181 lines (header + 180 rows), 17 columns, UTF-8, no BOM, LF line ends.

SHA-256: `32d9839c1ffcd5029eab8a3ae1abbf91db977eec6302481850324b1aac20adbb`
