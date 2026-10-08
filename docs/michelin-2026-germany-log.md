# Log: MICHELIN Guide Germany 2026 capture

- Batch key: `michelin-2026-germany`
- Date of capture: 2026-10-04 (all pages read in Ben's Chrome through the Claude in Chrome extension)
- Output: `michelin-2026-germany.csv`, 483 rows
- Database: not touched. GitHub: not touched. No competitor site used.

---

## 1. Method

**English country slug: `germany`.**
I typed "Germany" into the destination search box on https://guide.michelin.com/us/en/restaurants and clicked the plain "Germany" row under "Locations". The site opened https://guide.michelin.com/us/en/selection/germany/restaurants (title "Germany MICHELIN Restaurants – The MICHELIN Guide").

**German country slug: `germany`.**
I typed "Deutschland" into the destination search box on https://guide.michelin.com/de/de/restaurants and clicked the plain "Deutschland" row under "Ort". The site opened https://guide.michelin.com/de/de/selection/germany/restaurants (title "Deutschland MICHELIN Restaurants - der Guide MICHELIN").

Every card in both passes has `data-restaurant-country="de"`.

**Pages read (rendered DOM in the browser tab, no in-page `fetch()`):**

| List | English pages | German pages |
|---|---|---|
| 3 Stars | `/selection/germany/restaurants/3-stars-michelin` (1 page) | same path on `/de/de/` (1 page) |
| 2 Stars | `/2-stars-michelin` (1 page) | same (1 page) |
| 1 Star | `/1-star-michelin`, `/page/2` to `/page/6` (6 pages) | same (6 pages) |
| Bib Gourmand | `/bib-gourmand`, `/page/2` to `/page/4` (4 pages) | same (4 pages) |

Page links came from `a[href*="/page/"]` in the DOM.

**Card rules used (as in the brief):** only cards inside `.row.restaurant__list-row.js-restaurant__list_items` (each page also had 4 promo cards outside that row, ignored). Fields read with `textContent`, whitespace runs collapsed to one space. Name = `h3 a`; URL = `h3 a` href; city = first `.card__menu-footer--score` line minus ", Germany" (German: ", Deutschland"); price = second footer line before " · "; country and distinction from `data-restaurant-country` and `data-dtm-distinction`. Each card has 4 elements with these attributes; I read all 4 and they agreed on every card.

**Transfer:** results were stored on the page in `sessionStorage`, sorted, then shown in the page in 5 blocks of up to 100 lines and read with the page-text tool. I saved each block and checked its SHA-256 against the hash the browser computed. All matched (part 12). The CSV was built with Python from the verified blocks. No row was typed by hand.

**Changes from the method:**
- Pass 2 transfer: the German names were identical to the English names on all 483 rows, and 59 cities differed. I transferred only the 59 city differences, rebuilt the full German data (URL tail, German name, German city) in Python, and checked it against a SHA-256 that the browser computed over the full German data. It matched.
- The venue-page price check also compared the price symbol on every one of the 483 rows between the English and German cards (not only 3). All 483 were identical.

---

## 2. Count table

| Category | CSV rows | Site banner (EN) | Distinction filter (EN) | Ceremony count | Difference from ceremony |
|---|---|---|---|---|---|
| Three Stars | 12 | "1-12 of 12 restaurants - 3 Stars" | 12 | 12 | 0 |
| Two Stars | 48 | "1-48 of 48 restaurants - 2 Stars" | 48 | 48 | 0 |
| One Star | 278 | "1-48 of 278 restaurants - 1 Star" | 278 | 279 | -1 |
| Bib Gourmand | 145 | "1-48 of 145 restaurants - Bib Gourmand" | 145 | 147 | -2 |
| **Total** | **483** | | **483** | **486** | **-3** |

Rows minus banner = 0 and rows minus filter = 0 for every category.

Distinction filter text (EN): "3 Stars Exceptional cuisine 12 | 2 Stars Excellent cooking 48 | 1 Star High quality cooking 278 | Bib Gourmand Good quality, good value cooking 145 | Selected Restaurants Good cooking 762".
Distinction filter text (DE): "3 Sterne Eine einzigartige Küche 12 | 2 Sterne Eine Spitzenküche 48 | 1 Stern Eine Küche voller Finesse 278 | Bib Gourmand Unser bestes Preis-Leistungs-Verhältnis 145".

Ceremony counts: https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-germany-2026-is-out ("12 restaurants with Three Stars ... 48 ... 279 ... 147 restaurants with a Bib Gourmand").

---

## 3. Duplicate, two-category and country checks

- Duplicate `source_url`: **0**.
- Venue in two categories: **0** (no URL appears in more than one list).
- Card `data-dtm-distinction` against list filter: **0 mismatches** (THREE_STARS, TWO_STARS, ONE_STAR, BIB_GOURMAND).
- Card `data-restaurant-country` not `de`: **0**.
- Card city not ending ", Germany": **0**.
- Duplicate URL tail (part after `/restaurant/`): 0 in English, 0 in German.

---

## 4. 2027 check and the five named 2026 changes

**Guide year (scope rule 1).** No page or list showed a 2027 selection. Exact phrases from three venue pages:

| Level | URL | Meta description (start) | JSON-LD `award.dateAwarded` |
|---|---|---|---|
| Three Stars | https://guide.michelin.com/us/en/rheinland-pfalz/deidesheim/restaurant/l-a-jordan | "L.A. Jordan – a Three Stars: Exceptional cuisine restaurant in the 2026 MICHELIN Guide Germany." | "2026" |
| Two Stars | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/the-cloud-by-kafer | "THE CLOUD by Käfer – a Two Stars: Excellent cooking restaurant in the 2026 MICHELIN Guide Germany." | "2026" |
| One Star | https://guide.michelin.com/us/en/nordrhein-westfalen/detmold/restaurant/porte-neuf | "Porte Neuf – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Germany." | "2026" |

All 16 venue pages that I opened in English and the 3 in German say 2026 (part 8 and part 10).

**Five named changes (scope rule 2).** All are on the live site in the expected category:

| Venue | Expected | Found | URL |
|---|---|---|---|
| L.A. Jordan (Deidesheim) | Three Stars | Three Stars | https://guide.michelin.com/us/en/rheinland-pfalz/deidesheim/restaurant/l-a-jordan |
| Mühle (Schluchsee) | Two Stars | Two Stars | https://guide.michelin.com/us/en/baden-wurttemberg/schluchsee/restaurant/muhle-1195341 |
| RAUSCH (Frankfurt am Main) | Two Stars | Two Stars | https://guide.michelin.com/us/en/hessen/frankfurt-am-main/restaurant/rausch |
| THE CLOUD by Käfer (Munich) | Two Stars | Two Stars | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/the-cloud-by-kafer |
| Porte Neuf (Detmold) | One Star | One Star | https://guide.michelin.com/us/en/nordrhein-westfalen/detmold/restaurant/porte-neuf |

The ceremony article names a fourth new Two Stars that the brief did not list: **the dune** (Frankfurt am Main). It is in the Two Stars list: https://guide.michelin.com/us/en/hessen/frankfurt-am-main/restaurant/the-dune

---

## 5. Star-list article, closed-restaurant check, and difference from 486

**Star-list article (scope rule 3): found.**
- "Alle Sternerestaurants - MICHELIN Guide Deutschland 2026", dated 23 Juni 2026: https://guide.michelin.com/de/de/article/michelin-guide-ceremony/alle-sternerestaurants---michelin-guide-deutschland-2026
- It is German-language only. It does not appear on the English Germany tag page (https://guide.michelin.com/en/tags/Germany). I found it with a web search limited to guide.michelin.com: `Alle Sterne-Restaurants Guide MICHELIN Deutschland 2026`. The English search `"All Starred Restaurants" MICHELIN Guide Germany 2026` found only the Austria article.
- The article lists 339 entries (12 + 48 + 279). **No entry is marked as closed** (no "geschlossen", "closed" or similar text).
- The English ceremony article's "HERE" link goes to the live list https://guide.michelin.com/en/de/restaurants/all-starred, which showed "1-48 of 338 restaurants" on 2026-10-04.

**Article against live lists (name match done in the browser):**
- 1 article entry has no live card: **"Perasdorf - Gasthaus Jakob"** (One Star in the article).
  - https://guide.michelin.com/us/en/bayern/perasdorf/restaurant/gasthaus-jakob shows the page title "Restaurant not found".
  - https://guide.michelin.com/de/de/bayern/perasdorf/restaurant/gasthaus-jakob shows the page title "Restaurant nicht gefunden".
  - A web search on guide.michelin.com still returns the first URL with the title "Gasthaus Jakob", so the page existed before.
  - No Michelin page that I found gives a reason (closed or withdrawn).
- 1 more name did not match by text, but it is the same venue: article "Rust - ammolite - The Lighthouse Restaurant" = live card "Ammolite - House of Light", URL https://guide.michelin.com/us/en/baden-wurttemberg/rust/restaurant/ammolite-the-lighthouse-restaurant (Two Stars). This is a rename, not a missing venue.

**Difference from 486 (scope rule 4):** 483 rows = 486 − 3 (0.6%, inside the 10% limit).
- Stars: −1 = **Gasthaus Jakob, Perasdorf** (see above).
- Bib Gourmand: −2. **I could not name these two.** No Michelin article lists all 147 Bib Gourmands for 2026. Searches used:
  - Germany tag page: https://guide.michelin.com/en/tags/Germany (no Bib list article for 2026)
  - Web search on guide.michelin.com: `Alle Bib Gourmand Restaurants MICHELIN Guide Deutschland 2026`
  - The new-Bib article "Zehn neue Bib Gourmands für Deutschland" (16 Juni 2026) names only the 10 new ones: https://guide.michelin.com/de/de/article/michelin-guide-ceremony/zehn-neue-bib-gourmands-fur-deutschland---die-michelin-inspektoren-sind-begeistert . All 10 have a live Bib card. One has a new name: the article's "BYBLOS – Berlin" is the live card "CHEZ NASSIB", URL https://guide.michelin.com/us/en/berlin-region/berlin/restaurant/byblos-1245987

---

## 6. Excluded cards

- Cards from another country: **none**. Every card in the result row had `data-restaurant-country="de"`.
- Promo cards outside `.row.restaurant__list-row.js-restaurant__list_items`: 4 per page on every list page. Not read, by rule.
- No other card was held out.

**Cards kept as printed, but worth a look:**
- **Kaufmann's Restaurant am Schlosspark.** The URL region and slug say Rhineland-Palatinate / "geisfeld" (https://guide.michelin.com/us/en/rheinland-pfalz/geisfeld_1330179/restaurant/kaufmann-s), but the card and venue page print city "Gersfeld" and address "Schloßplatz 11, Gersfeld, 36129, Germany". `city_label` = "Gersfeld", as printed.
- **Weinhaus Stern.** English card city "Bürgstadt", German card city "Burgstädt" (https://guide.michelin.com/us/en/bayern/brugstadt/restaurant/weinhaus-stern). Both kept as printed in their own columns.
- **St. Andreas** and **Lotters Wirtschaft - Tausendgüldenstube.** English city "Aue - Bad Schlema", German city "Aue".
- Two URLs have non-ASCII characters in the path and are percent-encoded in the CSV: `.../limburg-an-der-lahn/restaurant/360%C2%B0` (360°) and `.../keitum/restaurant/tipken%C2%B4s` (Tipken's by Nils Henkel). I opened the 360° URL in its encoded form; it loads (part 8).

---

## 7. Price and currency

Rows per `price_symbol_raw` value:

| Value | Rows |
|---|---|
| `€€€€` | 294 |
| `€€` | 136 |
| `€€€` | 43 |
| `€` | 10 |
| **Total** | **483** |

- No row is missing a price. No symbol other than `€`.
- By category: Three Stars €€€€ 12; Two Stars €€€€ 48; One Star €€€€ 234, €€€ 43, €€ 1 (Café GUPI, Weil am Rhein); Bib Gourmand €€ 135, € 10.
- English card against German card: identical price symbols on all 483 joined rows.

**Venue-page check (3 venues, card / page price / JSON-LD `priceRange`):**

| Venue | Card (EN) | EN page "Price" | EN JSON-LD `priceRange` | DE page "Preis" | DE JSON-LD `priceRange` |
|---|---|---|---|---|---|
| L.A. Jordan | €€€€ | €€€€ | "Spare no expense" | €€€€ | "Für einzigartige Momente" |
| Porte Neuf | €€€€ | €€€€ | "Spare no expense" | €€€€ | "Für einzigartige Momente" |
| Stube ZWEI.NULL | €€ | €€ | "A moderate spend" | €€ | "Sich etwas gönnen" |

JSON-LD `priceRange` is a text label, not symbols. The symbols on the card, the English page and the German page are identical.

German pages:
- https://guide.michelin.com/de/de/rheinland-pfalz/deidesheim/restaurant/l-a-jordan
- https://guide.michelin.com/de/de/nordrhein-westfalen/detmold/restaurant/porte-neuf
- https://guide.michelin.com/de/de/baden-wurttemberg/langenau/restaurant/stube-zwei-null

---

## 8. Six venue-page spot checks

| # | Level | Venue page | Name | City (address) | Distinction (JSON-LD `awardFor`, year) | Price | Matches card? |
|---|---|---|---|---|---|---|---|
| 1 | Three Stars | https://guide.michelin.com/us/en/rheinland-pfalz/deidesheim/restaurant/l-a-jordan | L.A. Jordan | Deidesheim (Ketschauerhofstraße 1, 67146) | Three Stars: Exceptional cuisine, 2026 | €€€€ | Yes |
| 2 | Two Stars | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/the-cloud-by-kafer | THE CLOUD by Käfer | Munich (Am Olympiapark 1, 80809) | Two Stars: Excellent cooking, 2026 | €€€€ | Yes |
| 3 | One Star | https://guide.michelin.com/us/en/nordrhein-westfalen/detmold/restaurant/porte-neuf | Porte Neuf | Detmold (Woldemarstraße 9, 32756) | One Star: High quality cooking, 2026 | €€€€ | Yes |
| 4 | One Star | https://guide.michelin.com/us/en/bayern/weissenbrunn/restaurant/gasthof-alex | Gasthof Alex | Weißenbrunn (Gössersdorf 25, 96369) | One Star: High quality cooking, 2026 | €€€€ | Yes |
| 5 | Bib Gourmand | https://guide.michelin.com/us/en/baden-wurttemberg/langenau/restaurant/stube-zwei-null | Stube ZWEI.NULL | Langenau (Burghof 11, 89129) | Bib Gourmand: good quality, good value cooking, 2026 | €€ | Yes |
| 6 | Bib Gourmand | https://guide.michelin.com/us/en/rheinland-pfalz/geisfeld_1330179/restaurant/kaufmann-s | Kaufmann's Restaurant am Schlosspark | Gersfeld (Schloßplatz 11, 36129) | Bib Gourmand: good quality, good value cooking, 2026 | €€ | Yes |

Extra page opened: https://guide.michelin.com/us/en/hessen/limburg-an-der-lahn/restaurant/360%C2%B0 — "360°", One Star, 2026, €€€€, Bahnhofsplatz 1a, Limburg an der Lahn, 65549. Matches card.

---

## 9. Pass 2 results (German lists)

| Category | Pass 2 rows | German banner |
|---|---|---|
| Three Stars | 12 | "Deutschland : 1-12 von 12 restaurants - 3 Sterne" |
| Two Stars | 48 | "Deutschland : 1-48 von 48 restaurants - 2 Sterne" |
| One Star | 278 | "Deutschland : 1-48 von 278 restaurants - 1 Stern" |
| Bib Gourmand | 145 | "Deutschland : 1-48 von 145 restaurants - Bib Gourmand" |
| **Total** | **483** | |

- Joined rows (on the URL part after `/restaurant/`): **483 of 483**.
- English rows with no German card: **0**. German cards with no English row: **0**.
- Rows where the German category differs from the English category: **0**.
- The full path after the language prefix is the same in both passes on all 483 rows.
- German name differs from English name: **0 rows**.
- German city differs from English city: **59 rows**. They are all the same place, in German:

| English city | German city | Rows |
|---|---|---|
| Munich | München | 17 |
| Frankfurt on the Main | Frankfurt am Main | 13 |
| Cologne | Köln | 13 |
| Nuremberg | Nürnberg | 8 |
| Hanover | Hannover | 4 |
| Aue - Bad Schlema | Aue | 2 |
| Constance | Konstanz | 1 |
| Bürgstadt | Burgstädt | 1 (see part 6) |

---

## 10. Status and second-restaurant register

**Closed in the database, but with a 2026 star in the database:**

| Venue | Card found? | Name on card | Category | URL | Address (venue page) |
|---|---|---|---|---|---|
| Gasthof Alex (Weißenbrunn) | **Yes** | Gasthof Alex | One Star | https://guide.michelin.com/us/en/bayern/weissenbrunn/restaurant/gasthof-alex | Gössersdorf 25, Weißenbrunn, 96369, Germany |
| Pfortenhaus Kloster Eberbach (Eltville am Rhein) | **Yes** | Ente Wiesbaden - Pfortenhaus Kloster Eberbach | One Star | https://guide.michelin.com/us/en/hessen/eltville-am-rhein/restaurant/ente | Kloster-Eberbach-Straße 1, Eltville am Rhein, 65346, Germany |

Both venue pages say "...restaurant in the 2026 MICHELIN Guide Germany." The Ente page also offers "Free online booking". The 2026 star-list article lists "Eltville am Rhein - Ente Wiesbaden-Pfortenhaus Kloster Eberbach" and "Weißenbrunn - Gasthof Alex".

**Closed in the database:**
- Aqua (Wolfsburg): **no card** in any of the four lists. No row has "Aqua" in the name or "Wolfsburg" as the city.

**Second restaurant with a Bib Gourmand (all star cards and all Bib cards in each town):**

| Town | Star card | Star address | Bib card(s) in town | Bib address |
|---|---|---|---|---|
| Bernried | Schwingshackl ESSKULTUR, One Star, https://guide.michelin.com/us/en/bayern/bernried_1281441/restaurant/schwingshackl-esskultur | Rebling 3, Bernried, 94505 | Schwingshackl HEIMATKÜCHE, https://guide.michelin.com/us/en/bayern/bernried_1281441/restaurant/schwingshackl-heimatkuche-1213862 | Rebling 3, Bernried, 94505 (same address) |
| Blieskastel | Hämmerle's Restaurant, One Star, https://guide.michelin.com/us/en/saarland/blieskastel/restaurant/hammerle-s-restaurant-barrique | Bliestalstraße 110a, Blieskastel, 66440 | Landgenuss, https://guide.michelin.com/us/en/saarland/blieskastel/restaurant/landgenuss | Bliestalstraße 110a, Blieskastel, 66440 (same address) |
| Gummersbach | Mühlenhelle, One Star, https://guide.michelin.com/us/en/nordrhein-westfalen/gummersbach/restaurant/muhlenhelle | Hohler Straße 1, Gummersbach, 51645 | Mühlenhelle - Bistro, https://guide.michelin.com/us/en/nordrhein-westfalen/gummersbach/restaurant/muhlenhelle-bistro | Hohler Straße 1, Gummersbach, 51645 (same address) |
| Langenau | HOCHZWEI, One Star, https://guide.michelin.com/us/en/baden-wurttemberg/langenau/restaurant/hochzwei | Burghof 11, Langenau, 89129 | Stube ZWEI.NULL, https://guide.michelin.com/us/en/baden-wurttemberg/langenau/restaurant/stube-zwei-null | Burghof 11, Langenau, 89129 (same address) |
| Sonnenbühl | Hirsch, One Star, https://guide.michelin.com/us/en/baden-wurttemberg/sonnenbhl/restaurant/hirsch77747 | Im Dorf 12, Sonnenbühl, 72820 | **None.** No Bib Gourmand card in Sonnenbühl. | — |

Note: the database calls the Langenau star "Restaurant HochZwei im Gasthof zum Bad"; the card prints "HOCHZWEI".

---

## 11. Hold register (no CSV rows)

**Special awards (4).** Sources: English ceremony article https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-germany-2026-is-out and German awards article "Die MICHELIN Awards 2026" (23 Juni 2026) https://guide.michelin.com/de/de/article/michelin-guide-ceremony/die-michelin-awards-2026

| Award | Person | Venue | Venue in today's lists? | Venue URL |
|---|---|---|---|---|
| MICHELIN Service Award | Karin Weißer | Sankt Benedikt, Aachen | Yes, One Star | https://guide.michelin.com/us/en/nordrhein-westfalen/aachen/restaurant/sankt-benedikt |
| MICHELIN Young Chef Award (sponsored by Antonius Caviar) | Axel Boesen | Dopamin, Saarburg | Yes, One Star | https://guide.michelin.com/us/en/rheinland-pfalz/saarburg_1332732/restaurant/dopamin |
| MICHELIN Sommelier Award (sponsored by Perrier-Jouët) | Noris F. Conrad | Tantris, Munich | Yes, Two Stars | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/tantris-75719 |
| MICHELIN Opening of the Year Award | — (restaurant award) | THE CLOUD by Käfer, Munich | Yes, Two Stars | https://guide.michelin.com/us/en/bayern/mnchen/restaurant/the-cloud-by-kafer |

**Green Star.** The site shows nothing for Germany 2026:
- The Germany list (https://guide.michelin.com/us/en/selection/germany/restaurants) has no Green Star or sustainable filter. No label or link with "green" or "sustainab" on the page.
- https://guide.michelin.com/us/en/selection/germany/restaurants/sustainable_gastronomy redirects to the worldwide list https://guide.michelin.com/us/en/restaurants ("1-48 of 19,719 Restaurants").
- "Die MICHELIN Awards 2026" has no mention of a Green Star ("Grün").
- The latest German Green Star article is from 2025: "14 neue Grüne Sterne bereichern Deutschlands Gastro-Szene", 17 Juni 2025, https://guide.michelin.com/de/de/article/michelin-guide-ceremony/14-neue-grune-sterne-bereichern-deutschlands-gastro-szene

---

## 12. Hashes

**Line format for the English data blocks.** Each line has 8 tab-separated fields: category code (3, 2, 1, B), card path, name, city line, price line, country, distinction, footer line count. All lines are sorted (JavaScript default sort), then joined with `\n`.

| Block | Lines | SHA-256 (browser = local copy) |
|---|---|---|
| 0 | 100 | `a8661373540cde282eb6376f6b5baf5f93b4ab343951b831ff838e41ba04eead` |
| 1 | 100 | `aaef417e9d95f484a69c42af91f8f77af78ec838539719a037f724f7f69df144` |
| 2 | 100 | `ecfa5eac2b56f234d576550db2413f8657be22dbb710042b8a2d0c0f9568519f` |
| 3 | 100 | `80ec37ab5633923546feda1b6bf01990b242aae97a4cf7a19a732d9373d6eea8` |
| 4 | 83 | `f17193fc8199bf21bb043949f8f79f1f480b490975348d41e67e3732f76ec2d9` |

- Full English data hash (all 483 lines): `b2aa2245d5256d3ad532d1fe0ae2c09a0657cbcf92c02ee3cf8b361c829a4c98` — match.
- Full German data hash (483 lines of "URL tail, German name, German city", sorted): `c017648e617e87b20eeb6ffb164c5e90c0ef2c26365eefabf56e7d43b2ca8ecf` — match.
- **SHA-256 of `michelin-2026-germany.csv`: `424ab62fea6b2812f1ac67ac4bff9ca13a256c2ebe8c4e9522b2ded283000bff`**
  - 484 lines (1 header + 483 rows), 17 fields on every line, UTF-8 with no BOM, `\n` line endings.
