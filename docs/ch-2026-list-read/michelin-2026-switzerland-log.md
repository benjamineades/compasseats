# Michelin 2026 Switzerland and Liechtenstein: run log

- Run date: 2026-11-02, between 22:29 and 22:45 UTC (17:29 to 17:45 in Atlanta).
- Brief: `cowork-michelin-2026-switzerland.md`.
- Output: `michelin-2026-switzerland.csv`, 225 rows plus the header.
- Result: no stop rule applies. All checks pass. The total is 225, the same as the Michelin ceremony article.
- Database: not touched. GitHub repo: not touched. No competitor site used.

## 1. Method

1. I used the Chrome extension. I opened a tab on guide.michelin.com.
2. I read each list page with a same-origin `fetch()` and `DOMParser`, with a pause of 1 second between pages. I did not read cards from the rendered tab.
3. I read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`. Each direct child of that row is one card. The promo rail is outside the row, so it is not read.
4. Fields per card, all with `textContent` and runs of whitespace collapsed to one space:
   - name: `h3 a` text
   - `source_url`: `https://guide.michelin.com` + `h3 a` href (percent-encoding kept as in the href)
   - city and country: first `.card__menu-footer--score` line, split on the last ", "
   - price: second `.card__menu-footer--score` line, the part before " · "
   - country code and distinction: `data-restaurant-country` and `data-dtm-distinction` on the first `[data-restaurant-country]` element inside the card
5. Page count: the script read page 1, took the total from the `h1` banner, and read `/page/N` until it had all cards. No `/page/1` in any URL.
6. Storage: results were saved in `localStorage` under keys that start with `__ch26_`. At the end I removed all 19 `__ch26_` keys. I did not read or change any other key.
7. Copy method: the data was shown in the page as plain text (`<pre>`) in 7 blocks of up to 100 lines, fields separated by ` | `, with `\` escaped as `\\` and `|` as `\|`. I read each block with the page-text tool and checked it against a SHA-256 computed in the browser (sorted lines joined with `\n`). All 7 blocks and the full-data hash match (part 14).
8. The CSV was built with Python from the checked blocks (`csv` module, UTF-8, no BOM, LF line ends). No row was typed by hand.

Proof test:

- Distinct URLs per category equal the `h1` banner in every category (part 2).
- English lists read twice: read 1 started 22:29:39 UTC, read 2 started 22:34:49 UTC (5 min 10 s later). Same URL set and same name, city, price, country and distinction on every card. Difference: 0.
- German lists read three times: 22:30:37, 22:35:01 and 22:43:53 UTC. The second read came only 4 min 24 s after the first, so I added the third read (13 min 16 s after the first). All three reads are equal. Difference: 0.
- 6 venue pages opened in a real tab (part 9). All match the rows.
- Server HTML gave `data-dtm-distinction` values `3 star`, `2 star`, `1 star`, `bib`. The rendered all-restaurants page showed `data-distinction` values such as `ONE_STAR`. This matches the sign of the re-sort problem in the brief, so the fetch method was the right choice.

Changes from the brief method:

- The German list `h1` starts with `Schweiz :` (not `Switzerland :`). I accepted `Schweiz :` for the `/ch/de/` lists only. The English lists start with `Switzerland :` and `Liechtenstein :`.
- The `h1` check ran after the read, not as a stop inside the script. All 16 pages that returned 200 passed it.
- The Write tool removed trailing spaces from a few block lines (empty last fields). I found this with the block hash, put the spaces back with code, and the hash then matched. No data field changed.

## 2. Counts

| Category | Rows `ch` | Banner `switzerland` | Rows `li` | Banner `liechtenstein` | Rows total | Published (ceremony article) | Difference |
|---|---|---|---|---|---|---|---|
| Three Stars | 5 | 5 | 0 | 404 (no list) | 5 | 5 | 0 |
| Two Stars | 22 | 22 | 0 | 404 (no list) | 22 | 22 | 0 |
| One Star | 105 | 105 | 1 | 1 | 106 | 106 | 0 |
| Bib Gourmand | 92 | 92 | 0 | 404 (no list) | 92 | 92 | 0 |
| **Sum** | **224** | **224** | **1** | **1** | **225** | **225** | **0** |

Banner text: `Switzerland : 1-5 of 5 restaurants`, `1-22 of 22`, `1-48 of 105`, `1-48 of 92`; `Liechtenstein : 1-1 of 1 restaurants`. Pages: One Star 3 pages (48, 48, 9 cards), Bib 2 pages (48, 44 cards).

Source for published counts: https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/michelin-guide-schweiz-andermatt-3-sterne-restaurant ("5 Restaurants mit drei Sternen", "22 Restaurants mit zwei Sternen", "106 Restaurants mit einem Stern", "92 Restaurants mit Bib Gourmand").

### Rows by city label and category

| City label | Three Stars | Two Stars | One Star | Bib Gourmand | Total |
|---|---|---|---|---|---|
| Zurich |  | 4 | 10 | 9 | 23 |
| Geneva |  | 1 | 7 | 5 | 13 |
| Lucerne |  | 1 | 5 |  | 6 |
| Sankt Gallen |  | 1 | 3 | 2 | 6 |
| Basel | 1 | 1 | 2 | 1 | 5 |
| Zermatt |  |  | 4 | 1 | 5 |
| Andermatt | 1 | 1 | 2 |  | 4 |
| Lausanne |  | 2 | 1 | 1 | 4 |
| Lugano |  |  | 4 |  | 4 |
| Saint Moritz |  | 2 | 1 | 1 | 4 |
| Ascona |  | 1 | 1 | 1 | 3 |
| Berne |  |  | 3 |  | 3 |
| Crans-Montana |  |  | 2 | 1 | 3 |
| Fürstenau | 1 |  | 1 | 1 | 3 |
| Adelboden |  |  | 1 | 1 | 2 |
| Aubonne |  |  | 1 | 1 | 2 |
| Bad Ragaz | 1 |  | 1 |  | 2 |
| Brunnen |  |  | 1 | 1 | 2 |
| Burgdorf |  |  | 1 | 1 | 2 |
| Fribourg |  |  | 2 |  | 2 |
| Gonten |  |  | 1 | 1 | 2 |
| Grindelwald |  |  | 2 |  | 2 |
| Haute-Nendaz |  |  |  | 2 | 2 |
| Interlaken |  |  | 1 | 1 | 2 |
| Losone |  |  | 1 | 1 | 2 |
| Madulain |  |  | 1 | 1 | 2 |
| Mels |  |  | 1 | 1 | 2 |
| Montreux |  |  | 1 | 1 | 2 |
| Rehetobel |  |  | 1 | 1 | 2 |
| Riedholz |  |  | 1 | 1 | 2 |
| Romoos |  |  | 1 | 1 | 2 |
| Schaffhausen |  |  | 1 | 1 | 2 |
| Steffisburg |  |  | 1 | 1 | 2 |
| Wilderswil |  |  | 1 | 1 | 2 |
| Zug |  |  |  | 2 | 2 |
| Arosa |  | 1 |  |  | 1 |
| Avegno |  |  |  | 1 | 1 |
| Balgach |  |  | 1 |  | 1 |
| Ballaigues |  |  | 1 |  | 1 |
| Bellinzona |  |  | 1 |  | 1 |
| Bernex |  |  |  | 1 | 1 |
| Biel |  |  | 1 |  | 1 |
| Binn |  |  |  | 1 | 1 |
| Brail |  |  | 1 |  | 1 |
| Brent |  |  | 1 |  | 1 |
| Bubendorf |  |  | 1 |  | 1 |
| Bubikon |  |  | 1 |  | 1 |
| Buchs |  |  |  | 1 | 1 |
| Carouge |  |  |  | 1 | 1 |
| Castel San Pietro |  |  | 1 |  | 1 |
| Celerina |  |  |  | 1 | 1 |
| Champex-Lac |  |  | 1 |  | 1 |
| Chardonne |  |  |  | 1 | 1 |
| Cheseaux-Noréaz |  |  | 1 |  | 1 |
| Corseaux |  |  |  | 1 | 1 |
| Cossonay |  |  |  | 1 | 1 |
| Crissier | 1 |  |  |  | 1 |
| Davos Platz |  |  | 1 |  | 1 |
| Diessenhofen |  |  |  | 1 | 1 |
| Disentis |  |  |  | 1 | 1 |
| Ebersecken |  |  |  | 1 | 1 |
| Erlenbach |  |  |  | 1 | 1 |
| Ernen |  |  |  | 1 | 1 |
| Fislisbach |  |  |  | 1 | 1 |
| Fläsch |  |  |  | 1 | 1 |
| Flüh |  |  | 1 |  | 1 |
| Frauenfeld |  |  |  | 1 | 1 |
| Freidorf |  | 1 |  |  | 1 |
| Freienstein-Teufen |  |  |  | 1 | 1 |
| Frutigen |  |  |  | 1 | 1 |
| Gais |  |  | 1 |  | 1 |
| Gattikon |  |  | 1 |  | 1 |
| Grenchen |  |  |  | 1 | 1 |
| Grub |  |  |  | 1 | 1 |
| Hergiswil |  |  | 1 |  | 1 |
| Hildisrieden |  |  |  | 1 | 1 |
| Ilanz |  |  |  | 1 | 1 |
| Intragna |  |  |  | 1 | 1 |
| Kestenholz |  |  |  | 1 | 1 |
| Kriens |  |  | 1 |  | 1 |
| Künten-Sulz |  |  | 1 |  | 1 |
| La Punt-Chamues-ch |  |  | 1 |  | 1 |
| Le Brassus |  |  |  | 1 | 1 |
| Le Mont-sur-Lausanne |  |  |  | 1 | 1 |
| Le Noirmont |  | 1 |  |  | 1 |
| Lenzburg |  |  | 1 |  | 1 |
| Ligerz |  |  | 1 |  | 1 |
| Lyss |  |  |  | 1 | 1 |
| Lömmenschwil |  |  | 1 |  | 1 |
| Massagno |  |  |  | 1 | 1 |
| Meggen |  |  |  | 1 | 1 |
| Menzingen |  |  | 1 |  | 1 |
| Messen |  |  |  | 1 | 1 |
| Morbio Inferiore |  |  | 1 |  | 1 |
| Oberwil |  |  | 1 |  | 1 |
| Ollon |  |  | 1 |  | 1 |
| Pfaffnau |  |  |  | 1 | 1 |
| Pontresina |  |  |  | 1 | 1 |
| Ried-Muotathal |  |  |  | 1 | 1 |
| Riemenstalden |  |  |  | 1 | 1 |
| Rigi Kaltbad |  |  |  | 1 | 1 |
| Saanen |  |  |  | 1 | 1 |
| Saint-Légier |  |  |  | 1 | 1 |
| Satigny |  |  | 1 |  | 1 |
| Savièse |  | 1 |  |  | 1 |
| Schwarzenburg |  |  |  | 1 | 1 |
| Schwyz |  | 1 |  |  | 1 |
| Schüpfen |  |  |  | 1 | 1 |
| Sent |  |  |  | 1 | 1 |
| Solothurn |  |  |  | 1 | 1 |
| Sonceboz |  |  | 1 |  | 1 |
| Stans |  |  |  | 1 | 1 |
| Stansstad |  |  | 1 |  | 1 |
| Stäfa |  |  |  | 1 | 1 |
| Tegna |  |  |  | 1 | 1 |
| Teufen |  |  |  | 1 | 1 |
| Thun |  |  | 1 |  | 1 |
| Thônex |  |  | 1 |  | 1 |
| Trimbach |  |  | 1 |  | 1 |
| Troinex |  |  | 1 |  | 1 |
| Utzenstorf |  |  |  | 1 | 1 |
| Vaduz |  |  | 1 |  | 1 |
| Vals |  | 1 |  |  | 1 |
| Verbier |  |  | 1 |  | 1 |
| Villarepos |  |  | 1 |  | 1 |
| Vitznau |  | 1 |  |  | 1 |
| Wengi bei Büren |  |  | 1 |  | 1 |
| Wigoltingen |  | 1 |  |  | 1 |
| Wittenbach |  |  | 1 |  | 1 |
| Wölflinswil |  |  |  | 1 | 1 |
| Yens |  |  |  | 1 | 1 |
| Yverdon-les-Bains |  |  | 1 |  | 1 |
| **132 city labels** | 5 | 22 | 106 | 92 | 225 |

## 3. Duplicate, two-category and country checks

- Duplicate `source_url`: 0.
- URL in two categories: 0.
- Card `data-dtm-distinction` differs from the URL filter: 0 (English and German).
- Card `data-restaurant-country` differs from the selection (`switzerland` = `ch`, `liechtenstein` = `li`): 0.
- Codes found: `ch` on 224 rows, `li` on 1 row (Torkel). Country label in the footer matches the code on all 225 rows.
- Rows with no price: 0.

## 4. 2026 check, 2027 check and the named 2026 changes

Venue pages (meta description and JSON-LD `award.dateAwarded`):

| Venue | URL | Meta description (start) | `dateAwarded` |
|---|---|---|---|
| The Japanese Restaurant | https://guide.michelin.com/us/en/uri/andermatt/restaurant/the-japanese-restaurant | "The Japanese Restaurant – a Three Stars: Exceptional cuisine restaurant in the 2026 MICHELIN Guide Switzerland." | "2026" |
| MYLE | https://guide.michelin.com/us/en/bern-region/bern/restaurant/myle | "MYLE – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Switzerland." | "2026" |
| Torkel | https://guide.michelin.com/us/en/liechtenstein-region/vaduz/restaurant/torkel | "Torkel – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Switzerland." | "2026" |
| Culinarium Alpinum | https://guide.michelin.com/us/en/nidwalden/stans/restaurant/culinarium-alpinum | "Culinarium Alpinum – a Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide Switzerland." | "2026" |

- No page or list shows 2025. No Swiss or Liechtenstein page or list shows a 2027 selection.
- Note: the "related stories" box under the Swiss articles links to "MICHELIN Guide South Australia 2027: Alle Restaurants". That is another guide, not a Swiss selection, so it does not trigger the 2027 stop rule.
- Note: the Torkel page says "2026 MICHELIN Guide Switzerland", which agrees with Michelin counting Torkel in the Swiss One Star total.

Named 2026 changes, all found in the expected category:

| Expected | Name on card | City label | Category on site | URL |
|---|---|---|---|---|
| Three Stars, new | The Japanese Restaurant | Andermatt | Three Stars | https://guide.michelin.com/us/en/uri/andermatt/restaurant/the-japanese-restaurant |
| Three Stars | Sven Wassmer Memories | Bad Ragaz | Three Stars | https://guide.michelin.com/us/en/sankt-gallen-region/bad-ragaz/restaurant/memories |
| Three Stars | Cheval Blanc by Peter Knogl | Basel | Three Stars | https://guide.michelin.com/us/en/basel-stadt/basel/restaurant/cheval-blanc-by-peter-knogl |
| Three Stars | Restaurant de l'Hôtel de Ville | Crissier | Three Stars | https://guide.michelin.com/us/en/vaud/crissier/restaurant/restaurant-de-l-hotel-de-ville |
| Three Stars | Schloss Schauenstein | Fürstenau | Three Stars | https://guide.michelin.com/us/en/graubunden/frstenau/restaurant/schloss-schauenstein |
| One Star, new | MYLE | Berne | One Star | https://guide.michelin.com/us/en/bern-region/bern/restaurant/myle |
| One Star, new | Bärenstobe | Gonten | One Star | https://guide.michelin.com/us/en/appenzell-innerrhoden/gonten/restaurant/barenstobe |
| One Star, new | CAAA by Pietro Catalano | Lucerne | One Star | https://guide.michelin.com/us/en/luzern-region/luzern/restaurant/caaa-by-pietro-catalano |
| One Star, new | Ristorante con enoteca Origini | Morbio Inferiore | One Star | https://guide.michelin.com/us/en/ticino/morbio-inferiore_1156290/restaurant/ristorante-con-enoteca-origini |
| One Star, new | Schlüssel | Oberwil | One Star | https://guide.michelin.com/us/en/basel-landschaft/oberwil/restaurant/schlussel-1244305 |
| One Star, new | ad lib | Zermatt | One Star | https://guide.michelin.com/us/en/wallis/zermatt/restaurant/ad-lib |
| One Star, new | rémy | Zurich | One Star | https://guide.michelin.com/us/en/zurich-region/zurich/restaurant/remy |
| Bib Gourmand, new | Gasthaus Traube - Die Braustube | Buchs | Bib Gourmand | https://guide.michelin.com/us/en/sankt-gallen-region/buchs/restaurant/gasthaus-traube-die-braustube |
| Bib Gourmand, new | Ya Mama by Moses Ceylan | Celerina | Bib Gourmand | https://guide.michelin.com/us/en/graubunden/celerina/restaurant/ya-mama-by-moses-ceylan |
| Bib Gourmand, new | Löwenstobe | Gonten | Bib Gourmand | https://guide.michelin.com/us/en/appenzell-innerrhoden/gonten/restaurant/lowenstobe |
| Bib Gourmand, new | Ristorante della Stazione da YanElo | Intragna | Bib Gourmand | https://guide.michelin.com/us/en/ticino/centovalli-intragna/restaurant/yanelo |
| Bib Gourmand, new | Löwen Messen - Die Land Brasserie | Messen | Bib Gourmand | https://guide.michelin.com/us/en/solothurn-region/messen_1151365/restaurant/lowen-messen-die-land-brasserie |
| Bib Gourmand, new | Klostergasthaus Löwen - Gaststube | Pfaffnau | Bib Gourmand | https://guide.michelin.com/us/en/luzern-region/pfaffnau_1152016/restaurant/klostergasthaus-lowen-gaststube |
| Bib Gourmand, new | Dorfhus Gupf | Rehetobel | Bib Gourmand | https://guide.michelin.com/us/en/appenzell-ausserrhoden/rehetobel/restaurant/dorfhus-gupf |
| Bib Gourmand, new | Culinarium Alpinum | Stans | Bib Gourmand | https://guide.michelin.com/us/en/nidwalden/stans/restaurant/culinarium-alpinum |
| Bib Gourmand, new | Capet - Neo-Bistro | Zurich | Bib Gourmand | https://guide.michelin.com/us/en/zurich-region/zurich/restaurant/capet-neo-bistro |
| Bib Gourmand, new | Neri Cantina & Cucina | Zurich | Bib Gourmand | https://guide.michelin.com/us/en/zurich-region/zurich/restaurant/neri-cantina-cucina |
| Bib Gourmand, new | Soï 28 by Stefan Heilemann | Zurich | Bib Gourmand | https://guide.michelin.com/us/en/zurich-region/zurich/restaurant/soi-28-by-heilemann |

Note: a second card named "Restaurant de l'Hôtel de Ville" (Ollon, One Star) is a different restaurant: https://guide.michelin.com/us/en/vaud/ollon_1156456/restaurant/hotel-de-ville-179826

Bib article check (https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/neue-bib-gourmand-restaurants-schweiz-michelin-inspektoren): the 11 new Bibs that it links are all in the Bib list. The article also links 3 sister restaurants on the same address that are not Bibs (Traubensaal, Restaurant Löwen Gourmet, Negral). It spells one name "Soi 28 by Stefan Heilemann" (no diaeresis); the card prints "Soï 28 by Stefan Heilemann".

## 5. Full star list comparison

Source: https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/sternerestaurants-schweiz-2026. The article has 3 sections with 5, 22 and 106 card links (133). All links use `/ch/de/`. I joined them to my star rows on the part of the URL after the language part.

| Category | Article links | My rows | Joined | Only in article | Only in my rows | Category differs |
|---|---|---|---|---|---|---|
| Three Stars | 5 | 5 | 5 | 0 | 0 | 0 |
| Two Stars | 22 | 22 | 22 | 0 | 0 | 0 |
| One Star | 106 | 106 | 106 | 0 | 0 | 0 |
| **Sum** | **133** | **133** | **133** | **0** | **0** | **0** |

Name differences (article name / card name / card page title):

| Article name | Card name (used in CSV) | Card page title | URL |
|---|---|---|---|
| Memories | Sven Wassmer Memories | Sven Wassmer Memories – Bad Ragaz - a MICHELIN Guide Restaurant | https://guide.michelin.com/us/en/sankt-gallen-region/bad-ragaz/restaurant/memories |
| Da Vittorio | Da Vittorio - St. Moritz | Da Vittorio - St. Moritz – Saint Moritz - a MICHELIN Guide Restaurant | https://guide.michelin.com/us/en/graubunden/sankt-moritz/restaurant/da-vittorio384903 |
| The Japanese by The Chedi at Gütsch | The Japanese at Gütsch | The Japanese at Gütsch – Andermatt - a MICHELIN Guide Restaurant | https://guide.michelin.com/us/en/uri/andermatt/restaurant/the-japanese-by-the-chedi |
| Felix Lo Basso Restaurant | Soledì Restaurant | Soledì Restaurant – Lugano - a MICHELIN Guide Restaurant | https://guide.michelin.com/us/en/ticino/lugano/restaurant/felix-lo-basso-restaurant |
| Soleil d’Or by Benjamin Geisser | Soleil d’Or by David Geisser | Soleil d’Or by David Geisser – Sankt Gallen - a MICHELIN Guide Restaurant | https://guide.michelin.com/us/en/sankt-gallen-region/sankt-gallen/restaurant/soleil-d-or-by-david-geisser |

These are the same 5 differences the brief listed. No other names differ.

## 6. Differences from the published counts

- Total rows: 225. Ceremony article total: 225. Difference: 0.
- The Swiss One Star banner shows 105 and the article says 106. The difference is Torkel (Vaduz, Liechtenstein), which is in the `liechtenstein` selection: https://guide.michelin.com/us/en/liechtenstein-region/vaduz/restaurant/torkel. 105 + 1 = 106.
- Reconciliation with the morning read in the brief (reference only):
  - Three Stars 4 → 5: The Japanese Restaurant moved up from Two Stars (ceremony article: "Aufsteiger ist das The Japanese Restaurant in Andermatt, das den dritten MICHELIN Stern bekommen hat").
  - Two Stars 23 → 22: the same move.
  - One Star (Swiss list) 103 → 105: 7 new (part 4) minus 5 that left (part 11).
  - Bib Gourmand 97 → 92: 11 new (part 4) minus 16 that left (part 11).

## 7. Excluded cards

- No card from another country was on any list. Nothing was excluded for country.
- The promo rail cards (outside the list row) were not read, so they are not in the CSV.
- Liechtenstein Three Stars, Two Stars and Bib lists return HTTP 404, so they have no rows:
  - https://guide.michelin.com/us/en/selection/liechtenstein/restaurants/3-stars-michelin (404)
  - https://guide.michelin.com/us/en/selection/liechtenstein/restaurants/2-stars-michelin (404)
  - https://guide.michelin.com/us/en/selection/liechtenstein/restaurants/bib-gourmand (404)

## 8. Price and currency

Rows by category and `price_symbol_raw`:

| Category | `€` | `€€` | `€€€` | `€€€€` | `$$$` | Total |
|---|---|---|---|---|---|---|
| Three Stars |  |  |  | 5 |  | 5 |
| Two Stars |  |  |  | 22 |  | 22 |
| One Star |  | 1 | 36 | 68 | 1 | 106 |
| Bib Gourmand | 1 | 90 | 1 |  |  | 92 |

- Swiss cards print `€` symbols in both `/us/en/` and `/ch/de/`. The English and German price symbols are equal on all 225 cards.
- Unusual prices (copied as printed): One Star with `€€`: Ristorante con enoteca Origini (https://guide.michelin.com/us/en/ticino/morbio-inferiore_1156290/restaurant/ristorante-con-enoteca-origini). Bib with `€`: Klostergasthaus Löwen - Gaststube (https://guide.michelin.com/us/en/luzern-region/pfaffnau_1152016/restaurant/klostergasthaus-lowen-gaststube). Bib with `€€€`: Mont-Rouge (https://guide.michelin.com/us/en/wallis/haute-nendaz/restaurant/mont-rouge).
- Rows with no price: 0.

Torkel symbols:

| Path | Card | Venue page "Price" line |
|---|---|---|
| `/us/en/` | `$$$` (https://guide.michelin.com/us/en/selection/liechtenstein/restaurants/1-star-michelin) | `$$$` (https://guide.michelin.com/us/en/liechtenstein-region/vaduz/restaurant/torkel) |
| `/ch/de/` | `$$$` (https://guide.michelin.com/ch/de/selection/liechtenstein/restaurants/1-star-michelin) | `$$$` (https://guide.michelin.com/ch/de/liechtenstein-region/vaduz/restaurant/torkel) |
| `/li/en/` | `$$$` (https://guide.michelin.com/li/en/selection/liechtenstein/restaurants/1-star-michelin; the card link on this list is `/en/liechtenstein-region/vaduz/restaurant/torkel`, with no country part) | `$$$` (https://guide.michelin.com/li/en/liechtenstein-region/vaduz/restaurant/torkel) |

Note: `https://guide.michelin.com/li/de/selection/liechtenstein/restaurants/1-star-michelin` redirects to `/en/li/restaurants/1-star-michelin` and shows the same English card.

Venue-page price check (2 pages per price level, card symbol vs printed "Price" line, JSON-LD `priceRange` not used):

| Venue | Card | Venue page | Match |
|---|---|---|---|
| The Japanese Restaurant (https://guide.michelin.com/us/en/uri/andermatt/restaurant/the-japanese-restaurant) | `€€€€` | `€€€€` | yes |
| Einstein Gourmet (https://guide.michelin.com/us/en/sankt-gallen-region/sankt-gallen/restaurant/einstein-gourmet) | `€€€€` | `€€€€` | yes |
| Culinarium Alpinum (https://guide.michelin.com/us/en/nidwalden/stans/restaurant/culinarium-alpinum) | `€€` | `€€` | yes |
| Zum Alten Stephan (https://guide.michelin.com/us/en/solothurn-region/solothurn/restaurant/zum-alten-stephan) | `€€` | `€€` | yes |

## 9. Venue-page spot checks (real tab)

| Check | Venue page: name / address / price / award | My row: name / city / category / price | Match |
|---|---|---|---|
| Three Stars (https://guide.michelin.com/us/en/uri/andermatt/restaurant/the-japanese-restaurant) | The Japanese Restaurant / Gotthardstrasse 4, Andermatt, 6490, Switzerland / `€€€€` / Three Stars: Exceptional cuisine / 2026 | The Japanese Restaurant / Andermatt / Three Stars / `€€€€` | yes |
| Two Stars (https://guide.michelin.com/us/en/sankt-gallen-region/sankt-gallen/restaurant/einstein-gourmet) | Einstein Gourmet / Berneggstrasse 2, Sankt Gallen, 9000, Switzerland / `€€€€` / Two Stars: Excellent cooking / 2026 | Einstein Gourmet / Sankt Gallen / Two Stars / `€€€€` | yes |
| One Star (https://guide.michelin.com/us/en/bern-region/bern/restaurant/myle) | MYLE / Bubenbergplatz 5A, Berne, 3011, Switzerland / `€€€€` / One Star: High quality cooking / 2026 | MYLE / Berne / One Star / `€€€€` | yes |
| Bib Gourmand (https://guide.michelin.com/us/en/nidwalden/stans/restaurant/culinarium-alpinum) | Culinarium Alpinum / Mürgstrasse 18, Stans, 6370, Switzerland / `€€` / Bib Gourmand: good quality, good value cooking / 2026 | Culinarium Alpinum / Stans / Bib Gourmand / `€€` | yes |
| Torkel (https://guide.michelin.com/us/en/liechtenstein-region/vaduz/restaurant/torkel) | Torkel / Hintergass 9, Vaduz, 9490, Liechtenstein / `$$$` / One Star: High quality cooking / 2026 | Torkel / Vaduz / One Star / `$$$` | yes |
| Geneva card (https://guide.michelin.com/us/en/geneve-region/geneve/restaurant/arakel) | Arakel / Rue Henri Blanvalet 17, Geneva, 1207, Switzerland / `€€€` / One Star: High quality cooking / 2026 | Arakel / Geneva / One Star / `€€€` | yes |

## 10. Pass 2 (German lists)

| Category | Pass 2 rows | Pass 1 rows |
|---|---|---|
| Three Stars | 5 | 5 |
| Two Stars | 22 | 22 |
| One Star | 106 | 106 |
| Bib Gourmand | 92 | 92 |

- Joined rows: 225 of 225. Rows that did not join: 0 (English side) and 0 (German side).
- Rows where the German category differs from the English category: 0.
- Rows where the German name differs from the English name: 0.
- City label pairs that differ (English → German):

| English `city_label` | German `city_label_de` | Rows |
|---|---|---|
| Zurich | Zürich | 23 |
| Geneva | Genève | 13 |
| Lucerne | Luzern | 6 |
| Saint Moritz | Sankt Moritz | 4 |
| Berne | Bern | 3 |
| Fribourg | Freiburg | 2 |
| **Total** | | **51** |

All other 174 rows have the same city in both languages (for example "Sankt Gallen", "Basel", "Fürstenau", "Vaduz").

## 11. Registers

### Two restaurants on one address

| Place | Card 1 (name, category, URL) | Card 2 (name, category, URL) |
|---|---|---|
| Adelboden | Alpenblick - Stuba, One Star, https://guide.michelin.com/us/en/bern-region/adelboden/restaurant/alpenblick | Alpenblick - Bistro, Bib Gourmand, https://guide.michelin.com/us/en/bern-region/adelboden/restaurant/alpenblick-bistro-1208465 |
| Aubonne | Njørden, One Star, https://guide.michelin.com/us/en/vaud/aubonne/restaurant/njorden | Njørd café, Bib Gourmand, https://guide.michelin.com/us/en/vaud/aubonne/restaurant/njord-cafe |
| Brunnen | Birdy's by Achtien - The Nest, One Star, https://guide.michelin.com/us/en/luzern-region/brunnen/restaurant/birdy-s-by-achtien-the-nest | Birdy's by Achtien, Bib Gourmand, https://guide.michelin.com/us/en/luzern-region/brunnen/restaurant/birdy-s-by-achtien |
| Mels | Schlüssel - Nidbergstube, One Star, https://guide.michelin.com/us/en/sankt-gallen-region/mels/restaurant/schlussel-nidbergstube | Restaurant Schlüssel - Schlüsselstube, Bib Gourmand, https://guide.michelin.com/us/en/sankt-gallen-region/mels/restaurant/schlusselstube |
| Riedholz | Château Attisholz - Le feu, One Star, https://guide.michelin.com/us/en/solothurn-region/riedholz/restaurant/attisholz-le-feu | Château Attisholz - Brasserie la Source, Bib Gourmand, https://guide.michelin.com/us/en/solothurn-region/riedholz/restaurant/chateau-attisholz-brasserie-la-source |
| Romoos | Wiesner Mysterion - Wiesner - Zauber, One Star, https://guide.michelin.com/us/en/luzern-region/romoos_1152275/restaurant/wiesner-mysterion-zauber | Wiesner Mysterion – Werkstatt Kost, Bib Gourmand, https://guide.michelin.com/us/en/luzern-region/romoos_1152275/restaurant/wiesner-mysterion-%E2%80%93-werkstatt-kost |
| Steffisburg | Panorama - Cayenne, One Star, https://guide.michelin.com/us/en/bern-region/steffisburg/restaurant/panorama-cayenne | Panorama - Bistro, Bib Gourmand, https://guide.michelin.com/us/en/bern-region/steffisburg/restaurant/panorama-bistro |
| Wilderswil | Alpenblick, One Star, https://guide.michelin.com/us/en/bern-region/wilderswil/restaurant/alpenblick179404 | Alpenblick - Swiss Bistro, Bib Gourmand, https://guide.michelin.com/us/en/bern-region/wilderswil/restaurant/alpenblick-bistro |
| Madulain | Chesa Stüva Colani, One Star, https://guide.michelin.com/us/en/graubunden/madulain/restaurant/chesa-stuva-colani | Colani Bistrot, Bib Gourmand, https://guide.michelin.com/us/en/graubunden/madulain/restaurant/colani-bistrot |

All 18 cards are on today's lists.

### Status (database marks these closed)

| Card name | Category today | Address on venue page | Closure note on page | URL |
|---|---|---|---|---|
| After Seven | One Star | Hofmattstrasse 4, Zermatt, 3929, Switzerland | none found | https://guide.michelin.com/us/en/wallis/zermatt/restaurant/after-seven |
| Colani Bistrot | Bib Gourmand | Via Principela 20, Madulain, 7523, Switzerland | none found | https://guide.michelin.com/us/en/graubunden/madulain/restaurant/colani-bistrot |

Both venues are on the 2026 lists and their pages show a 2026 award ("One Star: High quality cooking / 2026" and "Bib Gourmand: good quality, good value cooking / 2026"). Michelin shows no closure note. The database "closed" status does not match Michelin today. Ben should decide.

### Left the star and Bib lists (21 cards)

"First phrase" is the meta description up to the first full stop. None of these 21 URLs is in today's lists.

| Morning category | Path | HTTP | Card name | First phrase of meta description | Closure note |
|---|---|---|---|---|---|
| One Star | `geneve-region/geneve/restaurant/tse-fung` | 200 | Tsé Fung | "Tsé Fung – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| One Star | `zurich-region/wangen-bei-dbendorf/restaurant/sternen-badstube` | 200 | Sternen - Badstube | "Sternen - Badstube – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| One Star | `fribourg-region/broc/restaurant/les-montagnards-le-sommet` | 200 | Les Montagnards - Le Sommet | "Les Montagnards - Le Sommet – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| One Star | `luzern-region/rigi-kaltbad/restaurant/regina-montium` | 200 | Regina Montium | "Regina Montium – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| One Star | `wallis/zermatt/restaurant/capri` | 200 | Capri | "Capri – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `geneve-region/geneve/restaurant/chez-philippe` | 200 | Chez Philippe | "Chez Philippe – a MICHELIN restaurant" | none found |
| Bib Gourmand | `sankt-gallen-region/weesen/restaurant/fischerstube` | 200 | Fischerstube | "Fischerstube – a MICHELIN restaurant" | none found |
| Bib Gourmand | `geneve-region/satigny/restaurant/cafe-de-peney` | 404 | (page not found) | (none) | (none) |
| Bib Gourmand | `geneve-region/collonge-bellerive/restaurant/collonge-cafe` | 200 | Collonge Café | "Collonge Café – a MICHELIN restaurant" | none found |
| Bib Gourmand | `geneve-region/aire-la-ville/restaurant/cafe-du-levant` | 200 | Café du Levant | "Café du Levant – a MICHELIN restaurant" | none found |
| Bib Gourmand | `zurich-region/zurich/restaurant/august` | 200 | AuGust | "AuGust – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `solothurn-region/solothurn/restaurant/le-restaurant1154949` | 200 | Le Restaurant | "Le Restaurant – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `geneve-region/geneve/restaurant/bistrot-dumas` | 404 | (page not found) | (none) | (none) |
| Bib Gourmand | `zurich-region/uster/restaurant/blume` | 200 | Blume | "Blume – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `ticino/brissago/restaurant/agora-1190920` | 404 | (page not found) | (none) | (none) |
| Bib Gourmand | `zurich-region/zurich/restaurant/rigiblick-zuriberg-beiz` | 404 | (page not found) | (none) | (none) |
| Bib Gourmand | `geneve-region/geneve/restaurant/osteria-della-bottega` | 200 | Osteria della Bottega | "Osteria della Bottega – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `solothurn-region/solothurn/restaurant/salzhaus` | 200 | SALZHAUS | "SALZHAUS – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `graubunden/davos-platz/restaurant/golden-dragon` | 404 | (page not found) | (none) | (none) |
| Bib Gourmand | `zurich-region/zurich/restaurant/la-bottega-di-mario` | 200 | La Bottega di Mario | "La Bottega di Mario – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |
| Bib Gourmand | `zurich-region/zurich/restaurant/gaijin-izakaya` | 200 | Gaijin Izakaya | "Gaijin Izakaya – a restaurant in the 2026 MICHELIN Guide Switzerland" | none found |

Summary: 5 pages return 404. 16 pages return 200 with no award in the meta description and no closure note. Of these, 12 say "a restaurant in the 2026 MICHELIN Guide Switzerland" (still in the guide as a Selected restaurant) and 4 say only "a MICHELIN restaurant" with no guide year.

### Names that differ from the database

| Card name (English) | Card name (German) | Category | Database name(s) from brief | URL |
|---|---|---|---|---|
| The Japanese Restaurant | The Japanese Restaurant | Three Stars | (brief gives no database name) | https://guide.michelin.com/us/en/uri/andermatt/restaurant/the-japanese-restaurant |
| Da Vittorio - St. Moritz | Da Vittorio - St. Moritz | Two Stars | "Carlton Hotel St. Moritz LHW", "Da Vittorio" | https://guide.michelin.com/us/en/graubunden/sankt-moritz/restaurant/da-vittorio384903 |
| Cheval Blanc by Peter Knogl | Cheval Blanc by Peter Knogl | Three Stars | "Grand Hotel Les Trois Rois" | https://guide.michelin.com/us/en/basel-stadt/basel/restaurant/cheval-blanc-by-peter-knogl |
| La Brezza | La Brezza | Two Stars | "Tschuggen Grand Hotel Arosa" | https://guide.michelin.com/us/en/graubunden/arosa/restaurant/la-brezza-1191835 |
| 7132 Silver | 7132 Silver | Two Stars | "7132 Hotel" | https://guide.michelin.com/us/en/graubunden/vals/restaurant/7132-silver |
| Magdalena | Magdalena | Two Stars | "Restaurant Magdalena" (2 venues) | https://guide.michelin.com/us/en/schwyz/schwyz/restaurant/magdalena |
| Soledì Restaurant | Soledì Restaurant | One Star | "FELIX LO BASSO RESTAURANT" | https://guide.michelin.com/us/en/ticino/lugano/restaurant/felix-lo-basso-restaurant |
| Stéphane Décotterd | Stéphane Décotterd | One Star | "Maison Décotterd" | https://guide.michelin.com/us/en/vaud/montreux/restaurant/stephane-decotterd |
| Du Bourg | Du Bourg | One Star | "Burggasse" | https://guide.michelin.com/us/en/bern-region/biel/restaurant/du-bourg-1218243 |
| LA CHAVALLERA in der Krone Säumerei am Inn | LA CHAVALLERA in der Krone Säumerei am Inn | One Star | "Restaurant La Chavallera La Punt Chamues-ch" | https://guide.michelin.com/us/en/graubunden/la-punt-chamues-ch/restaurant/gasthaus-krone |
| Balm - Bistro | Balm - Bistro | Bib Gourmand | "Hotel Balm" | https://guide.michelin.com/us/en/luzern-region/meggen/restaurant/la-pistache-bistro |
| Bistro by Regina Montium | Bistro by Regina Montium | Bib Gourmand | "Rigi Bistro" | https://guide.michelin.com/us/en/luzern-region/rigi-kaltbad/restaurant/bistrot-by-regina-montium |
| Centrale | Centrale | Bib Gourmand | "Losone" | https://guide.michelin.com/us/en/ticino/losone/restaurant/centrale178757 |

Note: there is only 1 card named "Magdalena" on today's lists (Two Stars, Schwyz). The database has 2 venues with the name "Restaurant Magdalena".

## 12. Hold register (no CSV rows)

### Green Star

- `switzerland`: the "Distinction" filter on https://guide.michelin.com/us/en/selection/switzerland/restaurants lists only 3 Stars (5), 2 Stars (22), 1 Star (105), Bib Gourmand (92) and Selected Restaurants (299). It has no Green Star option. No card on page 1 has a value in its `data-green-star` attribute (52 of 52 empty).
- `liechtenstein`: https://guide.michelin.com/us/en/selection/liechtenstein/restaurants shows 4 cards. No card has a `data-green-star` value (8 of 8 attributes empty) and the page text has no "Green Star".
- I found no Green Star list URL on the 2026 site and did not guess one. No rows made.

### Special awards

Source: https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/michelin-awards-2026

| Award | Person | Venue (card name) | In today's list? | Venue URL |
|---|---|---|---|---|
| MICHELIN Service Award (sponsored by Pernod Ricard) | Nicole Sawyere | ad lib (Zermatt) | Yes, One Star | https://guide.michelin.com/us/en/wallis/zermatt/restaurant/ad-lib |
| MICHELIN Young Chef Award | Guglielmo Curcio | Ristorante con enoteca Origini (Morbio Inferiore) | Yes, One Star | https://guide.michelin.com/us/en/ticino/morbio-inferiore_1156290/restaurant/ristorante-con-enoteca-origini |
| MICHELIN Sommelier Award | Émeline Gigaud | Arakel (Geneva) | Yes, One Star | https://guide.michelin.com/us/en/geneve-region/geneve/restaurant/arakel |
| MICHELIN Opening of the Year Award | (the restaurant; chef Markus Arnold named in text) | MYLE (Berne) | Yes, One Star | https://guide.michelin.com/us/en/bern-region/bern/restaurant/myle |

Note: the article spells the Young Chef venue "Ristorante con entoeca Origini" (typo). The card name is "Ristorante con enoteca Origini".

### Liechtenstein Selected cards

| Name | City | Price | URL |
|---|---|---|---|
| Chapter Two - modern cuisine | Vaduz, Liechtenstein | `$$$` | https://guide.michelin.com/us/en/liechtenstein-region/vaduz/restaurant/chapter-two-modern-cuisine |
| Marée | Vaduz, Liechtenstein | `$$$` | https://guide.michelin.com/us/en/liechtenstein-region/vaduz/restaurant/maree |
| Weinlaube | Schellenberg, Liechtenstein | `$$$` | https://guide.michelin.com/us/en/liechtenstein-region/schellenberg/restaurant/weinlaube |

## 13. Names that are not NFC

- English names not NFC: 0.
- German names not NFC: 0.
- City labels not NFC: 0.
- Special characters kept as printed, for example: "Njørden", "Njørd café", "Soï 28 by Stefan Heilemann", "Soleil d’Or by David Geisser" (U+2019), "Wiesner Mysterion – Werkstatt Kost" (U+2013 en dash).
- The 2 URLs with percent-encoding are kept as in the card link: `auberge-de-la-croix-d%C2%B4or-bistro` and `wiesner-mysterion-%E2%80%93-werkstatt-kost`.

## 14. Hashes

Block hashes (SHA-256 of the sorted lines of each block, joined with `\n`, computed in the browser and matched in Python):

| Block | Lines | SHA-256 | Match |
|---|---|---|---|
| 0 | 100 | `e5a0cdb6c6ad654adbea51492e94f3b5e5baf43cebf7b2d1af7b603ca813cba0` | yes |
| 1 | 100 | `c6f07fd1ac748ae9ced1305dd330b6c4c0fa4e1a9dee63ab1c6add0adfd3899f` | yes |
| 2 | 100 | `a5106afaba2d6f71ab5034cb431e4ba748b3534347615917b75eee0127cb24ff` | yes |
| 3 | 100 | `4d3f7a63706c971bead582a2d876e6200522b263f38d4208a5e217ea67c0f5db` | yes |
| 4 | 100 | `61a3051663022ff62415e89a3e28872746085df7e2e0a0111075950e7c06eea7` | yes |
| 5 | 100 | `4d463a6095f979074c720a58a22bfab9d49da14e21aca4d1ebaf01f02be7830e` | yes |
| 6 | 63 | `eac2c6667e900ca63a7677877e9f728a8a179eb6e912d7ba6d11ecf8ed0de5af` | yes |

- Full data (663 lines, sorted, joined with `\n`): `ac400517d23165cd803598948de52d6e49e429a154fe75bd083b47535a23c5ac` (match: yes)
- Final CSV `michelin-2026-switzerland.csv`: `b8a1a2f469df551273a74c73238a0be94d0f4f04aeaf6abb6911c22685ea6444`

Blocks hold: English rows and page records (en read 1), German rows and page records (de read 1), venue-page records, spot-check records, Liechtenstein selection cards, Torkel `/li/` list reads, Bib article links, and star list article links.


## 15. Ben's decisions after the run (Nov 2, 2026, 17:57 ET)

- **After Seven** (Zermatt, `ve_7077280426`, card https://guide.michelin.com/us/en/wallis/zermatt/restaurant/after-seven): keep as open. The status file sets status active and published true, in one gated file, after Ben's "go". This run did not write to the database.
- **Green Stars:** Ben asked if any were given at the ceremony. Finding: no. The ceremony article (https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/michelin-guide-schweiz-andermatt-3-sterne-restaurant) and the awards article (https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/michelin-awards-2026) name no Green Star and no "Mindful Voices" honour. The 2026 site has no Green Star filter (part 12). Michelin announced on May 18, 2026 that the Green Star "will come to an end" and "will be gradually phased out" (https://www.michelin.com/en/publications/products-and-services/the-michelin-guide-introduces-mindful-voices). The planned Swiss Green Star file has no 2026 source. Ben, 17:59 ET: "Yes take it off the plan". The Green Star file is dropped. Green Star rows already in the database stay as history.
