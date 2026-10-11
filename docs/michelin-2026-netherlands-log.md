# Log: Michelin 2026 Netherlands

Run date: Saturday, October 10, 2026 (America/New_York). Live site read on that day with the Chrome extension.
Brief: `claude/cowork-michelin-2026-netherlands.md`.
Database and GitHub repo: not touched. No competitor site used.

## 1. Method

| Item | Value | Evidence (URL) |
|---|---|---|
| English country slug | `netherlands` (search box "Netherlands", plain country row under "Locations") | https://guide.michelin.com/us/en/selection/netherlands/restaurants |
| Dutch country slug | `netherlands` (search box "Nederland", plain country row under "Locaties") | https://guide.michelin.com/nl/nl/selection/netherlands/restaurants |
| English distinction slugs | `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand` (checkbox values in the Distinction filter) | English country page above |
| Dutch distinction slugs | `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand` (read from the Dutch Distinction filter checkbox values; same as English) | Dutch country page above |
| `data-restaurant-country` code | `nl` on every card (both passes). Mapped to `Netherlands` in code. | every list page |
| Page path check | Each script stopped unless the path contained `/selection/netherlands/` (Pass 2: `/nl/nl/selection/netherlands/`) | – |

Page reading:
1. Opened every list page in the browser tab (no in-page `fetch()`, no `DOMParser`). Pages: 3 Stars p1; 2 Stars p1; 1 Star p1–p3; Bib p1–p2. Same for `/nl/nl/`. Page links taken from `a[href*="/page/"]` (sort and map variants with `?` ignored).
2. Read only `.js-restaurant__list_item` cards inside `.row.restaurant__list-row.js-restaurant__list_items`. Every page had 4 promo cards outside that row; they were ignored.
3. Fields read with `textContent`. Whitespace runs collapsed to one space with JS `/\s+/g`, then trimmed.
4. Each card holds 4 elements with `data-restaurant-country` (note, been-there, bookmark, favourite icons). The script read all 4 and checked that they agree.
5. One extraction function was stored in `localStorage` under `__nl26_fn` and run on each page. Results were stored under `__nl26_*` keys. All 43 `__nl26_*` keys were removed at the end. No other key was read, changed or deleted.

Copy method:
- Rows shown in a `<pre>` as `category | url path | country code | price | city EN | city NL | name EN | name NL`, in 2 blocks (100 + 96 lines), read with the page-text tool.
- Each block was checked against a browser SHA-256 (sorted lines joined with `\n`). Both matched on the first try.
- The CSV was built with Python from the verified blocks.

Changes from the brief's method:
- **Pipe in a name.** "ORA | Taverna & Bar" contains ` | `. In the copy blocks, `\` was escaped as `\\` and `|` as `\|`. The build script reverses this. The CSV holds the name exactly as printed.
- **Tab closed mid-run.** The browser tab group closed after block 1 (the session re-linked). A new tab on guide.michelin.com found all `__nl26_*` keys intact. The block and full-data hashes were recomputed and were unchanged.
- **Venue-page price.** JSON-LD `priceRange` holds a word label (for example "Spare no expense"), not symbols. The symbols were compared with the venue page's printed "Price:" / "Prijs:" line.

Raw city lines (card `textContent`, first `.card__menu-footer--score`), from https://guide.michelin.com/us/en/selection/netherlands/restaurants/2-stars-michelin and https://guide.michelin.com/us/en/selection/netherlands/restaurants/3-stars-michelin:
- Azurite: `"\n                            Delft, Netherlands\n                        "`
- SUIS: `"\n                            Schin op Geul, Netherlands\n                        "`
- De Librije: `"\n                            Zwolle, Netherlands\n                        "`
- Second line example (Azurite): `"\n                                €€€€ ·\n                            Modern Cuisine\n                        "`

## 2. Counts

| Category | CSV rows | Site banner | Distinction filter | Published count | Difference |
|---|---|---|---|---|---|
| Three Stars | 1 | 1 ("1-1 of 1 restaurants - 3 Stars") | 1 | 1 | 0 |
| Two Stars | 20 | 20 ("1-20 of 20 restaurants - 2 Stars") | 20 | 20 | 0 |
| One Star | 98 | 98 ("97-98 of 98 restaurants - 1 Star") | 98 | 98 | 0 |
| Bib Gourmand | 77 | 77 ("49-77 of 77 restaurants - Bib Gourmand") | 77 | 77 | 0 |
| **Total** | **196** | 196 | 196 | 196 | 0 |

- Country page banner: "Netherlands : 1-48 of 499 restaurants". Filter: 1 + 20 + 98 + 77 + 303 Selected Restaurants ("the-plate-michelin") = 499. Source: https://guide.michelin.com/us/en/selection/netherlands/restaurants
- Ceremony article: 499 restaurants, 119 with at least One Star, 20 Two Stars, 98 One Star. Source: https://guide.michelin.com/en/article/michelin-guide-ceremony/azurite-and-suis-awarded-two-michelin-stars-each-in-the-2026-netherlands-michelin-guide
- Dutch filter shows the same: 1 / 20 / 98 / 77 / 303. Source: https://guide.michelin.com/nl/nl/selection/netherlands/restaurants

## 3. Duplicate, two-category and country checks

- Duplicate `source_url`: 0. Duplicate URL part after `/restaurant/`: 0.
- Venue in two categories: 0.
- `data-dtm-distinction` agrees with the URL filter on every card: THREE_STARS, TWO_STARS, ONE_STAR, BIB_GOURMAND (both passes).
- `data-restaurant-country`: `nl` on all 196 English cards and all 196 Dutch cards. No card from another country.
- Every English city line ends in ", Netherlands"; every Dutch city line ends in ", Nederland".
- All `source_url` values are `/us/en/` and plain ASCII. No percent-encoding was needed.

## 4. 2026 check, 2027 check and the six named changes

Scope rule 1 (three venue pages):

| Page | Meta description phrase | JSON-LD `award` |
|---|---|---|
| SUIS (Two Stars) https://guide.michelin.com/us/en/limburg/schin-op-geul_2216951/restaurant/suis | "SUIS – a Two Stars: Excellent cooking restaurant in the 2026 MICHELIN Guide Netherlands." | `awardFor` "Two Stars: Excellent cooking", `dateAwarded` "2026" |
| Rozewied (One Star) https://guide.michelin.com/us/en/zeeland/kortgene_2215334/restaurant/rozewied | "Rozewied – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Netherlands." | `awardFor` "One Star: High quality cooking", `dateAwarded` "2026" |
| Ramen Kitanoya (Bib) https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/ramen-kitanoya | "Ramen Kitanoya – a Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide Netherlands." | `awardFor` "Bib Gourmand: good quality, good value cooking", `dateAwarded` "2026" |

Dutch pages of the same three say "uit de 2026 MICHELIN Gids Nederland" and `dateAwarded` "2026".

2027 check: no "2027" on the English country page, the 2026 star list article or the 2026 Bib list article. All 11 venue pages opened in this run say 2026. Result: no 2027 selection seen.

Scope rule 2 (named changes):

| Expected | Card name | Category on site | City | URL |
|---|---|---|---|---|
| Two Stars | Azurite | Two Stars | Delft | https://guide.michelin.com/us/en/zuid-holland/delft/restaurant/azurite |
| Two Stars | SUIS | Two Stars | Schin op Geul | https://guide.michelin.com/us/en/limburg/schin-op-geul_2216951/restaurant/suis |
| One Star | De Cuijt | One Star | Mierlo | https://guide.michelin.com/us/en/noord-brabant/mierlo_2216676/restaurant/de-cuijt |
| One Star | Le Epifaan | One Star | Veeningen | https://guide.michelin.com/us/en/drenthe/veeningen_2214724/restaurant/le-epifaan |
| One Star | Rozewied | One Star | Kortgene | https://guide.michelin.com/us/en/zeeland/kortgene_2215334/restaurant/rozewied |
| Bib Gourmand | Ramen Kitanoya | Bib Gourmand | The Hague | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/ramen-kitanoya |

All six are in the expected category.

## 5. Article counts (scope rule 3)

**2026 star list** — https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-sterren-in-de-michelin-gids-nederland-2026

| Article part | Lines | Links | Matches cards in |
|---|---|---|---|
| Heading "3 MICHELIN Sterren:" | 1 | 1 | Three Stars (1) |
| Heading "2 MICHELIN Sterren:" | 20 | 20 | Two Stars (20) |
| Heading "1 MICHELIN Ster:" | 19 | 19 | One Star (18) + RIJKS® (see below) |
| Block after the "De volledige lijst van de Bib Gourmand restaurants" link heading (4 paragraphs: 22 + 18 + 22 + 17) | 79 | 79 | One Star (79) |
| **Total** | **119** | 119 | 1 / 20 / 98 |

- The 79-name block is **One Star**. Evidence: all 79 links go to cards in the One Star list (0 to Bib, 0 to other categories). The heading above it is only a link to the Bib list article, placed between two parts of the One Star list. 19 + 79 = 98, which equals the One Star total.
- RIJKS® is linked in the article as `.../restaurant/rijks%C2%AE`. The card URL is `.../restaurant/rijks-r`. Same name, same city (Amsterdam); it is the same venue with a different URL.
- Every One Star card is in the article (with RIJKS® counted as above). No star card is missing from the article.
- Closed entries: 0. No line says "gesloten" or "closed", and no line is struck through.

**2026 Bib list** — https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-bib-gourmand-restaurants-in-de-michelin-gids-nederland-2026

- 77 links in 6 paragraphs (19 + 10 + 18 + 16 + 5 + 9). 77 distinct URLs, all 77 equal to the Bib card URLs. No Bib card is missing.
- The intro line of the article itself says the list holds 77 Bib Gourmand restaurants.
- Closed entries: 0.

**2025 star list** (reference) — https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-sterren-in-de-michelin-gids-nederland-2025
- 1 / 20 / 98. The One Star list has the same layout: 21 lines under "1 MICHELIN Ster:", then 77 lines (23 + 16 + 22 + 16) after a "LEES OOK" link heading. Closed entries: 0.

**2025 Bib list** (reference) — https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-bib-gourmand-restaurants-in-de-michelin-gids-nederland-2025
- 78 links (16 + 11 + 17 + 19 + 7 + 8). The intro line says 78. Closed entries: 0.

## 6. 2025 versus 2026 (scope rules 4 and 5)

Method: every 2025 article link was matched to a 2026 card by the URL part after `/restaurant/` (with the RIJKS® article URL mapped by name). 177 of 197 entries matched by URL. 0 matched by name only. 0 venues changed category between the two years.

**In 2025, not in 2026 (20).** URLs are from the 2025 articles (no 2026 card exists).

| 2025 category | Name (city) as printed in the 2025 article | URL |
|---|---|---|
| Two Stars | Spectrum (Amsterdam) | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/spectrum437663 |
| Two Stars | De Groene Lantaarn (Staphorst) | https://guide.michelin.com/nl/nl/overijssel/staphorst/restaurant/de-groene-lantaarn |
| One Star | Daalder (Amsterdam) | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/daalder-1200903 |
| One Star | De Juwelier (Amsterdam) | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/de-juwelier |
| One Star | Demain (Cadzand) | https://guide.michelin.com/nl/nl/zeeland/cadzand/restaurant/demain |
| One Star | De Woage (Gramsbergen) | https://guide.michelin.com/nl/nl/overijssel/gramsbergen/restaurant/de-woage |
| One Star | Flicka (Kerkdriel) | https://guide.michelin.com/nl/nl/gelderland/kerkdriel/restaurant/flicka |
| One Star | Da Vinci (Maasbracht) | https://guide.michelin.com/nl/nl/limburg/maasbracht/restaurant/da-vinci212741 |
| One Star | Sense (Vught) | https://guide.michelin.com/nl/nl/noord-brabant/vught/restaurant/sense306045 |
| Bib Gourmand | Oriole (Amsterdam) | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/oriole-1200932 |
| Bib Gourmand | Bistrôt Chapeau (Blaricum) | https://guide.michelin.com/nl/nl/noord-holland/blaricum/restaurant/bistrot-chapeau |
| Bib Gourmand | Escobar (Breskens) | https://guide.michelin.com/nl/nl/zeeland/breskens/restaurant/escobar |
| Bib Gourmand | LEV Foodbar (Doetinchem) | https://guide.michelin.com/nl/nl/gelderland/doetinchem/restaurant/lev-foodbar |
| Bib Gourmand | HAVN (Hoorn) | https://guide.michelin.com/nl/nl/noord-holland/hoorn/restaurant/havn |
| Bib Gourmand | Prix de Rome (Maastricht) N | https://guide.michelin.com/nl/nl/limburg/maastricht/restaurant/prix-de-rome |
| Bib Gourmand | Bistrot Regent (Nijmegen) | https://guide.michelin.com/nl/nl/gelderland/nijmegen/restaurant/bistrot-regent |
| Bib Gourmand | Avenue43 (Oss) N | https://guide.michelin.com/nl/nl/noord-brabant/oss/restaurant/avenue43 |
| Bib Gourmand | Waers (Roermond) | https://guide.michelin.com/nl/nl/limburg/roermond/restaurant/waers |
| Bib Gourmand | Petite (Sint-Oedenrode) N | https://guide.michelin.com/nl/nl/noord-brabant/sint-oedenrode/restaurant/petite |
| Bib Gourmand | Senang (Zwolle) | https://guide.michelin.com/nl/nl/overijssel/zwolle/restaurant/bar-senang |

Note: "N" after three 2025 Bib names is printed in the 2025 article (the 2025 "new" mark).

**In 2026, not in 2025 (19).** URLs are the 2026 cards.

| 2026 category | Card name (city) | URL |
|---|---|---|
| Two Stars | Azurite (Delft) | https://guide.michelin.com/us/en/zuid-holland/delft/restaurant/azurite |
| Two Stars | SUIS (Schin op Geul) | https://guide.michelin.com/us/en/limburg/schin-op-geul_2216951/restaurant/suis |
| One Star | Ambrozijn (Valkenburg) | https://guide.michelin.com/us/en/limburg/valkenburg/restaurant/ambrozijn |
| One Star | Bij Sidney (Loenen aan de Vecht) | https://guide.michelin.com/us/en/utrecht/loenen-aan-de-vecht/restaurant/bij-sidney |
| One Star | De Cuijt (Mierlo) | https://guide.michelin.com/us/en/noord-brabant/mierlo_2216676/restaurant/de-cuijt |
| One Star | Le Epifaan (Veeningen) | https://guide.michelin.com/us/en/drenthe/veeningen_2214724/restaurant/le-epifaan |
| One Star | Nassau (Groningen) | https://guide.michelin.com/us/en/groningen/groningen/restaurant/nassau |
| One Star | Rozewied (Kortgene) | https://guide.michelin.com/us/en/zeeland/kortgene_2215334/restaurant/rozewied |
| One Star | Wild Atelier (Hoog Soeren) | https://guide.michelin.com/us/en/gelderland/hoog-soeren_2216407/restaurant/wild-atelier |
| Bib Gourmand | Ramen Kitanoya (The Hague) | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/ramen-kitanoya |
| Bib Gourmand | Brasserie Bruis (Haarlem) | https://guide.michelin.com/us/en/noord-holland/haarlem/restaurant/bruis |
| Bib Gourmand | Boon & De Koot (Amsterdam) | https://guide.michelin.com/us/en/noord-holland/amsterdam/restaurant/boon-de-koot |
| Bib Gourmand | FuLu Mandarijn (Amsterdam) | https://guide.michelin.com/us/en/noord-holland/amsterdam/restaurant/fulu-mandarijn |
| Bib Gourmand | Bistro Toost (Amstelveen) | https://guide.michelin.com/us/en/noord-holland/amstelveen/restaurant/bistro-toost |
| Bib Gourmand | Utage Sake Bar (Amsterdam) | https://guide.michelin.com/us/en/noord-holland/amsterdam/restaurant/utage-sake-bar |
| Bib Gourmand | ORA \| Taverna & Bar (Breda) | https://guide.michelin.com/us/en/noord-brabant/breda/restaurant/ora-taverna-bar |
| Bib Gourmand | Dokjard (Groningen) | https://guide.michelin.com/us/en/groningen/groningen/restaurant/dokjard |
| Bib Gourmand | Wijn Boer (Zwolle) | https://guide.michelin.com/us/en/overijssel/zwolle/restaurant/wijn-boer |
| Bib Gourmand | Bistro Luux (Weert) | https://guide.michelin.com/us/en/limburg/weert/restaurant/bistro-luux |

Balance per category:
- Two Stars: 20 − 2 + 2 = 20.
- One Star: 98 − 7 + 7 = 98. The 7 new One Stars match the 7 in the ceremony article.
- Bib Gourmand: 78 − 11 + 10 = 77. The 10 new Bibs match the ceremony article's "10 new".

Scope rule 5: star total = 119 (difference 0). Bib total = 77 (difference 0). Nothing to explain.

## 7. Excluded cards

None. No card in the four lists had a country code other than `nl`. No promo card was read.

## 8. Price and currency

| `price_symbol_raw` | Rows |
|---|---|
| €€€€ | 77 |
| €€ | 75 |
| €€€ | 42 |
| € | 2 |
| **Total** | 196 |

- Every row prints a price. Every symbol is `€` (U+20AC). No other symbol.
- The 2 rows with `€`: Bistrobar Berlin (Nijmegen) and Ramen Kitanoya (The Hague).
- English and Dutch card symbols are identical on all 196 joined rows.
- Venue-page check (card vs page "Price:" line vs Dutch page "Prijs:" line):

| Venue | EN card | EN page | NL page | JSON-LD `priceRange` EN / NL |
|---|---|---|---|---|
| SUIS | €€€€ | €€€€ | €€€€ | "Spare no expense" / "Pure verwennerij" |
| Rozewied | €€€ | €€€ | €€€ | "Special occasion" / "Wat exclusiever" |
| Ramen Kitanoya | € | € | € | "On a budget" / "Aantrekkelijk geprijsd" |

## 9. Six venue-page spot checks

All six match the card on name, city, distinction and price.

| Category | Venue | City (card = page) | Distinction on page (JSON-LD and badge) | Price card = page | URL |
|---|---|---|---|---|---|
| Three Stars | De Librije | Zwolle | Three Stars: Exceptional cuisine; 3 star icons | €€€€ | https://guide.michelin.com/us/en/overijssel/zwolle/restaurant/de-librije |
| Two Stars | SUIS (village) | Schin op Geul | Two Stars: Excellent cooking; 2 star icons | €€€€ | https://guide.michelin.com/us/en/limburg/schin-op-geul_2216951/restaurant/suis |
| One Star | Rozewied (village) | Kortgene | One Star: High quality cooking; 1 star icon | €€€ | https://guide.michelin.com/us/en/zeeland/kortgene_2215334/restaurant/rozewied |
| One Star | Calla's | The Hague | One Star: High quality cooking; 1 star icon | €€€€ | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/calla-s115041 |
| Bib Gourmand | Ramen Kitanoya | The Hague | Bib Gourmand: good quality, good value cooking; Bib icon | € | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/ramen-kitanoya |
| Bib Gourmand | Restaurant ñ | The Hague | Bib Gourmand: good quality, good value cooking; Bib icon | €€ | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/restaurant-n |

## 10. Pass 2 (Dutch)

| Category | Dutch rows | Dutch banner |
|---|---|---|
| Three Stars | 1 | "1-1 van 1 restaurants - 3 Sterren" |
| Two Stars | 20 | "1-20 van 20 restaurants - 2 Sterren" |
| One Star | 98 | "97-98 van 98 restaurants - 1 Ster" |
| Bib Gourmand | 77 | "49-77 van 77 restaurants - Bib Gourmand" |

- Joined rows: **196 of 196**. Rows that did not join: 0 (English side and Dutch side).
- Rows where the Dutch category differs from the English category: 0.
- Rows where the name differs: 0.
- Rows where the city differs: 7. All are The Hague (EN card) / Den Haag (NL card): Calla's, Ramen Kitanoya, Tapisco, Restaurant ñ, De Basiliek, Basaal, Resumé by 6&24.
- Note: the Dutch **venue page** of Ramen Kitanoya prints "The Hague" in its address ("Bagijnestraat 6, The Hague, 2511 CK, Nederland"), while the Dutch **card** prints "Den Haag". Source: https://guide.michelin.com/nl/nl/zuid-holland/den-haag/restaurant/ramen-kitanoya

## 11. Status and name register

| Venue | In the four 2026 lists? | What the site shows | URL |
|---|---|---|---|
| Demain (Cadzand) | No card | Venue page title "Restaurant niet gevonden" | https://guide.michelin.com/nl/nl/zeeland/cadzand/restaurant/demain |
| Spectrum (Amsterdam) | No card (2025: Two Stars) | Venue page title "Restaurant niet gevonden" | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/spectrum437663 |
| De Groene Lantaarn (Staphorst) | No card (2025: Two Stars) | Venue page title "Restaurant niet gevonden". The ceremony article says chef Jarno Eggen is known from De Groene Lantaarn, "which closed earlier this year", and that he now cooks at Le Epifaan (Veeningen). | https://guide.michelin.com/nl/nl/overijssel/staphorst/restaurant/de-groene-lantaarn ; https://guide.michelin.com/en/article/michelin-guide-ceremony/azurite-and-suis-awarded-two-michelin-stars-each-in-the-2026-netherlands-michelin-guide |
| De Juwelier (Amsterdam) | No card (2025: One Star) | Venue page is online. No star or Bib badge, no `award` in JSON-LD. Meta: "De Juwelier – een restaurant uit de 2026 MICHELIN Gids Nederland." So it is in the 2026 guide below Bib level. | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/de-juwelier |
| Restaurant Daalder (Amsterdam) | No card (2025: One Star, printed "Daalder") | Venue page title "Restaurant niet gevonden" | https://guide.michelin.com/nl/nl/noord-holland/amsterdam/restaurant/daalder-1200903 |

Note on De Groene Lantaarn: the brief asks for the exact sentence. My quoting limit is under 15 words per source, so the clause above is verbatim and the rest is paraphrased. The full sentence is in the paragraph about Le Epifaan in the article at the URL above.

Names (exact English card names):

| Database name | Card name | Category | City | URL |
|---|---|---|---|---|
| Restaurant GEM. | GEM. by Soenil Bahadoer | Two Stars | Gemert | https://guide.michelin.com/us/en/noord-brabant/gemert/restaurant/gem-by-soenil-bahadoer |
| Brut172 by Hans van Wolde | Brut172 | Two Stars | Reijmerstok | https://guide.michelin.com/us/en/limburg/reijmerstok/restaurant/brut172 |
| François Geurds FG Restaurant | FG - François Geurds | Two Stars | Rotterdam | https://guide.michelin.com/us/en/zuid-holland/rotterdam/restaurant/fg-francois-geurds |
| t Nonnetje | 't Nonnetje | Two Stars | Harderwijk | https://guide.michelin.com/us/en/gelderland/harderwijk/restaurant/t-nonnetje |
| Restaurant Flore | Flore | Two Stars | Amsterdam | https://guide.michelin.com/us/en/noord-holland/amsterdam/restaurant/flore |
| Restaurant De Nieuwe Winkel | De Nieuwe Winkel | Two Stars | Nijmegen | https://guide.michelin.com/us/en/gelderland/nijmegen/restaurant/de-nieuwe-winkel |

Note: the GEM. card name still includes the chef's name ("GEM. by Soenil Bahadoer"). The CSV keeps it as printed.

The Hague (every card in that city):

| Card name | Category | EN card city | NL card city | URL |
|---|---|---|---|---|
| Calla's | One Star | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/calla-s115041 |
| Ramen Kitanoya | Bib Gourmand | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/ramen-kitanoya |
| Tapisco | Bib Gourmand | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/tapisco |
| Restaurant ñ | Bib Gourmand | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/restaurant-n |
| De Basiliek | Bib Gourmand | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/de-basiliek |
| Basaal | Bib Gourmand | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/basaal-1194865 |
| Resumé by 6&24 | Bib Gourmand | The Hague | Den Haag | https://guide.michelin.com/us/en/zuid-holland/den-haag/restaurant/resume-by-6-24 |

New stars (exact card name and city): Two Stars — Azurite (Delft), SUIS (Schin op Geul). One Star — Ambrozijn (Valkenburg), Bij Sidney (Loenen aan de Vecht), De Cuijt (Mierlo), Le Epifaan (Veeningen), Nassau (Groningen), Rozewied (Kortgene), Wild Atelier (Hoog Soeren). URLs in part 6. Note: an image caption in the English ceremony article spells SUIS's village "Schil op Geul"; the card prints "Schin op Geul".

## 12. Hold register (no CSV rows)

**Mindful Voices**

| Person | Venue | 2026 category | Mindful Voices block on venue page | URL |
|---|---|---|---|---|
| Jef Schuur | Bij Jef (Den Hoorn) | One Star (in CSV) | Yes: block `data-sheet__mindful` titled "MINDFUL VOICES", name "Jef Schuur" | https://guide.michelin.com/us/en/noord-holland/den-hoorn/restaurant/bij-jef |
| Kees Meinderts | Mearkas (Eastermar) | No star or Bib card. Page meta: "a restaurant in the 2026 MICHELIN Guide Netherlands"; no badge, no `award`. | Yes: "MINDFUL VOICES", name "Kees Meinderts" | https://guide.michelin.com/en/fryslan/eastermar_2214270/restaurant/mearkas |

Also seen: De Librije's page carries a Mindful Voices block for Nelson Tanate (not named in the ceremony article). The block links to https://guide.michelin.com/us/en/articles/mindful-voices. Other venue pages were not opened, so other Mindful Voices blocks may exist.

**Green Star**
- The English country page has no Green Star filter. Full list of 118 filter checkbox values was read; none is Green Star, sustainable or Mindful Voices. Source: https://guide.michelin.com/us/en/selection/netherlands/restaurants
- No Green Star badge on any of the 11 venue pages opened.
- The only "Green Star" text found was on the Mearkas page, inside a "Related Reads" teaser for an older (2024) article. It is not a mark on the venue.
- No Green Star URL was guessed or opened. No rows made.

**Special awards** (source: ceremony article URL in part 2)

| Award | Person(s) | Venue | In today's star or Bib list? | URL |
|---|---|---|---|---|
| Young Chef Award | Noëmie Haentjens and Ferdy van Rijswijk | Rozewied (Kortgene) | Yes, One Star | https://guide.michelin.com/us/en/zeeland/kortgene_2215334/restaurant/rozewied |
| Service Award | Team of Restaurant Château Neercanne | Restaurant Château Neercanne (Maastricht) | Yes, One Star | https://guide.michelin.com/us/en/limburg/maastricht/restaurant/chateau-neercanne |
| Sommelier Award | Matthijs Vranken and Nouri Haj Romdhane | Brut172 (Reijmerstok) | Yes, Two Stars | https://guide.michelin.com/us/en/limburg/reijmerstok/restaurant/brut172 |
| Opening of the Year Award | Falk van Essen and Caroline de Vries | Restaurant Luwte (Groningen) | No. Page meta: "a restaurant in the 2026 MICHELIN Guide Netherlands"; no badge, no `award`. | https://guide.michelin.com/en/groningen/groningen/restaurant/restaurant-luwte |

Note: the ceremony article names the Service Award venue "Restaurant Château Neercanne", the same as the card.

## 13. Names that are not NFC

None. All 196 English names, English cities, Dutch names and Dutch cities are NFC.
Names with non-ASCII characters (all NFC, kept as printed): Auberge - cuisine française, Café Samabe, Café Sjiek, Café Visscher, Café de Gaper, FG - François Geurds, Héron, RIJKS®, Restaurant Château Neercanne, Restaurant élevé, Restaurant ñ, Resumé by 6&24, The Millèn, Tout à Fait, Wils Bakery Café.

## 14. Hashes

| Item | SHA-256 |
|---|---|
| Block 1 (100 lines; browser = copy) | e71f7bdb9ef3b4863611993bc6c16bdf5a5e057dc58d468663e7ee57463b1f27 |
| Block 2 (96 lines; browser = copy) | fe198a3fd5ae4b982a78f37d3dc4819f4e478263dbbf371f29f53542be6e8e07 |
| Full data (196 lines; browser = copy) | 22fa2e4da324afce10213aae2460c38f778286ce9316dd1b5a32d7dfda63dae6 |
| Final CSV `michelin-2026-netherlands.csv` (44,886 bytes) | aa72b5e6fff0af2f4e517202a5f6d35f52cfb28b5caca03506614413d842d7b2 |

Hash rule for blocks: lines sorted, joined with `\n`, UTF-8, no trailing newline.
CSV: UTF-8, no BOM, LF line ends, 197 lines (header + 196 rows), 17 columns on every line. No field needed quotation marks.
