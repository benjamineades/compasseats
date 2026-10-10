# Log: MICHELIN Guide Belgium & Luxembourg 2026

- Batch key: `michelin-2026-belgium-luxembourg`
- Run date: 2026-10-10 (America/New_York)
- Brief: `claude/cowork-michelin-2026-belgium-luxembourg.md` (project copy). I did not check the brief SHA-256.
- Browser: Claude in Chrome. Every list page was opened in the tab and read from the rendered DOM. No in-page `fetch()`. No `DOMParser`.
- I did not touch the database, the repo or Google Drive. I did not use a competitor site.
- Result: **247 rows** (Belgium 232, Luxembourg 15).

---

## 1. Method

### Country slugs (found with the destination search box, plain country row)

| Pass | Language page | Search text | Belgium slug | Luxembourg slug |
|---|---|---|---|---|
| 1 | https://guide.michelin.com/us/en/ | Belgium / Luxembourg | `belgium` | `luxembourg` |
| 2 | https://guide.michelin.com/be/nl/ | België / Luxemburg | `belgium` | `luxembourg` |
| 3 | https://guide.michelin.com/be/fr/ | Belgique / Luxembourg | `belgium` | `luxembourg` |

Resulting list roots:
- https://guide.michelin.com/us/en/selection/belgium/restaurants (title "Belgium MICHELIN Restaurants")
- https://guide.michelin.com/us/en/selection/luxembourg/restaurants (title "Luxembourg MICHELIN Restaurants")
- https://guide.michelin.com/be/nl/selection/belgium/restaurants and /be/nl/selection/luxembourg/restaurants
- https://guide.michelin.com/be/fr/selection/belgium/restaurants and /be/fr/selection/luxembourg/restaurants

Every card in every list had `data-restaurant-country` = `be` (Belgium lists) or `lu` (Luxembourg lists).

### Distinction slugs

- English (`/us/en/`) and Dutch (`/be/nl/`): `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`.
- French (`/be/fr/`): `3-etoiles-michelin`, `2-etoiles-michelin`, `1-etoile-michelin`, `bib-gourmand`. I read these from the Distinction filter checkbox values on https://guide.michelin.com/be/fr/selection/belgium/restaurants.

### Changes from the method in the brief

1. **French star slugs are different.** On `/be/fr/`, the English star slugs redirect to the worldwide list `/be/fr/restaurants` ("1-48 sur 19 725 restaurants"). I saw this, discarded that data, and used the French slugs above. My scripts now stop if the page path is not `selection/belgium` or `selection/luxembourg`.
2. **Storage.** Each list page is a new page load, so `window.__x` is lost. I stored results in the browser `localStorage` of guide.michelin.com under keys that start with `__bl26_`. I removed these keys at the end.
3. **Old key found.** `localStorage` already had a key `__cx` from an earlier session (United Kingdom and Ireland lists). I did not use its data for this batch. I did not change or delete it.
4. **Copy method.** I showed each block of up to 100 lines in the page as plain text (`<pre>`) and read it with the page-text tool. Field separator was ` | `. I checked each block with a SHA-256 computed in the browser.
5. **Pass 2 and Pass 3 copy.** The browser joined the Dutch and French cards to the English rows. I copied only the 14 rows where a Dutch or French value differs from English. Code rebuilt all 247 lines. The full hash matched the browser hash (see part 12).
6. **Country label.** `data-restaurant-country` holds codes, not names. Code mapped `be` → `Belgium` and `lu` → `Luxembourg`.
7. **One copy error, fixed with code.** Block 2 failed its hash at first. The cause was "Grünewald Chef’s Table". The site writes the ü as two code points (u + U+0308). I had copied the one-code-point form. I fixed it with code, and the hash then matched. The CSV keeps the site form. **Note for the importer:** this is the only name that is not NFC. If the match test compares NFC text, normalize this one name first.
8. **City on Luxembourg City cards.** The first footer line is only "Luxembourg" (no ", Luxembourg" after it). `city_label` is `Luxembourg`.
9. **Session break.** The session restarted once during Pass 1 copy. The browser data was still there. I re-hashed it (same full hash) before I continued.
10. **CSV line ends.** UTF-8, no BOM, LF line ends. No field needed quotation marks.

---

## 2. Count table

"Published" = count in the full star list article (part 5). Michelin did not publish Bib counts.

| Country | Category | My rows | Site banner | Distinction filter | Published | Difference rows − banner |
|---|---|---|---|---|---|---|
| Belgium | Three Stars | 2 | 2 ("1-2 of 2 restaurants - 3 Stars") | 2 | 2 | 0 |
| Belgium | Two Stars | 19 | 19 | 19 | 20 | 0 |
| Belgium | One Star | 103 | 103 | 103 | 105 | 0 |
| Belgium | Bib Gourmand | 108 | 108 | 108 | not published | 0 |
| Luxembourg | Three Stars | 0 | 0 ("Unfortunately there are no selected restaurants…") | 0 | 0 | 0 |
| Luxembourg | Two Stars | 2 | 2 | 2 | 2 | 0 |
| Luxembourg | One Star | 10 | 10 | 10 | 10 | 0 |
| Luxembourg | Bib Gourmand | 3 | 3 | 3 | not published | 0 |
| **Total** | | **247** | **247** | **247** | | **0** |

Sources: the list pages under https://guide.michelin.com/us/en/selection/belgium/restaurants/ and https://guide.michelin.com/us/en/selection/luxembourg/restaurants/ (`/3-stars-michelin`, `/2-stars-michelin`, `/1-star-michelin` pages 1–3, `/bib-gourmand` pages 1–3). Filter counts are from the Distinction filter on https://guide.michelin.com/us/en/selection/belgium/restaurants (2 / 19 / 103 / 108, Selected 484, total 716) and https://guide.michelin.com/us/en/selection/luxembourg/restaurants (2 / 10 / 3, Selected 29, total 44; no 3 Stars row).

Pages per list: Belgium One Star 48 + 48 + 7; Belgium Bib 48 + 48 + 12. Page links came from `a[href*="/page/"]` (pages 1, 2, 3).

Each card's `data-dtm-distinction` agreed with the URL filter (`THREE_STARS`, `TWO_STARS`, `ONE_STAR`, `BIB_GOURMAND`). Each card's `data-restaurant-country` agreed with the country in the URL. Zero mismatches.

---

## 3. Duplicate, two-category and two-country checks

- Duplicate `source_url`: **0**.
- Venue in two categories: **0** (no URL appears twice across the 7 lists).
- Venue in both country lists: **0**. No join key (the part after `/restaurant/`) is in both the Belgium and the Luxembourg lists, in any language.
- Note: URL territory does not decide the country. Example: 13 Belgian cards have the region `be-luxembourg` (Belgian province of Luxembourg), and all have `data-restaurant-country` = `be`.

---

## 4. 2027 check and the five named 2026 changes

### Guide year (scope rule 1)

| Country | Venue page | Meta description (exact phrase) | JSON-LD `award.dateAwarded` |
|---|---|---|---|
| Belgium | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/t-zilte | "Zilte – a Three Stars: Exceptional cuisine restaurant in the 2026 MICHELIN Guide Belgium" | `2026` |
| Luxembourg | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/le-lys-1241469 | "Le Lys – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide Luxembourg" | `2026` |

All 13 venue pages that I opened with a distinction showed `dateAwarded` = `2026`. I saw no 2027 selection for Belgium or Luxembourg.

### Five named 2026 changes (scope rule 2) — all present

| Venue | Expected | Card category | Card name / city | URL |
|---|---|---|---|---|
| Cuines 33 | Two Stars | Two Stars | Cuines 33 / Knokke | https://guide.michelin.com/us/en/west-vlaanderen/knokke/restaurant/cuines-33 |
| The Jane | Two Stars | Two Stars | The Jane / Antwerpen | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/the-jane-1244485 |
| Bloesem | One Star | One Star | Bloesem / Borgerhout | https://guide.michelin.com/us/en/antwerpen/borgerhout/restaurant/bloesem |
| La Table-Lasne by Alain Bianchin | One Star | One Star | La Table-Lasne by Alain Bianchin / Ohain | https://guide.michelin.com/us/en/brabant-wallon/ohain/restaurant/la-table-lasne-by-alain-bianchin |
| Le Lys | One Star | One Star | Le Lys / Luxembourg | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/le-lys-1241469 |

Note: the brief and the star list article say "Knokke-Heist" for Cuines 33. The card prints "Knokke". The CSV uses "Knokke".

---

## 5. Star list article counts, closed entries and difference from 139

Sources:
- Dutch: https://guide.michelin.com/be/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-sterren-in-de-michelin-gids-belgie-en-luxemburg-2026 (dated 04 MEI 2026)
- French: https://guide.michelin.com/be/fr/article/michelin-guide-ceremony/la-liste-complete-des-etoiles-dans-le-guide-michelin-belgique-et-luxembourg-2026 (dated 04 MAI 2026)

Both articles state 2 Three Stars, 22 Two Stars and 115 One Star (139). I counted the entries with code. Both languages give the same block sizes.

| Category | Brussels | Flanders | Wallonia | Belgium total | Luxembourg | Article total |
|---|---|---|---|---|---|---|
| Three Stars | – | – | – | 2 (Zilte, Boury; no region heading) | 0 | 2 |
| Two Stars | 3 | 13 | 4 | 20 | 2 | 22 |
| One Star | 8 | 63 | 34 | 105 | 10 | 115 |
| **Stars** | | | | **127** | **12** | **139** |

Entries marked N (new): 12. The Jane, Cuines 33 (Two Stars); Bloesem, Subtiel, Moscou by Danny Horseele, EST, Vintage, Atelier Noun, Agnes, Komaf, La Table-Lasne by Alain Bianchin, Le Lys (One Star).

### The Wallonia block of 34 names

- **Category: One Star.**
- Where it is: under the "1 MICHELIN Ster:" / "1 Étoile MICHELIN :" section, after the One Star Brussels block and before the One Star Luxembourg block.
- Why it looks unclear: in the French article, the heading "Wallonie :" is an **H3**, the same level as the category headings ("1 Étoile MICHELIN :"). It comes right after an H4 link line "Découvrez la liste complète des restaurants Bib Gourmand…". A parser that reads H3 as the category, or that reads the nearest H4, can file this block wrong (as a new category or as Bib). In the Dutch article, "Wallonië:" is an H4 that comes right after the H4 Bib link line.
- Evidence that it is One Star:
  1. 63 + 8 + 34 + 10 = 115, the One Star total that the article states.
  2. 33 of the 34 names have a **One Star** card on the live site (32 by the same name, plus "La Roseraie (Modave)" = card "La Roseraie Modave"). None has a Bib card.
  3. The one other name, La Table de Manon (Grandhan), is removed from the site (below).
  4. "La Table-Lasne by Alain Bianchin (Ohain) N" is in this block. The ceremony article lists it with the 10 new One Star restaurants.

### Closed entries

The articles mark **no** entry as closed. The only marker is "N" for new.

### Difference from 139 (scope rule 4)

- Live stars today: 2 + 19 + 103 (Belgium) + 0 + 2 + 10 (Luxembourg) = **136**.
- Difference: **−3 (−2.2%)**. This is inside 10%. The three restaurants are named below.

| Article entry | Article category | Card today | Michelin page now |
|---|---|---|---|
| La Paix (Anderlecht) | Two Stars, Brussels | none | https://guide.michelin.com/us/en/bruxelles-capitale/anderlecht/restaurant/la-paix203164 → "Restaurant not found". Local page https://guide.michelin.com/be/fr/bruxelles-capitale/anderlecht/restaurant/la-paix203164 → "Restaurant non trouvé", details not available in the MICHELIN Guide Belgium. |
| Kommilfoo (Antwerpen) | One Star, Flanders | none | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/kommilfoo → "Restaurant not found". https://guide.michelin.com/be/nl/antwerpen/be-antwerpen/restaurant/kommilfoo → "Restaurant niet gevonden", not available in the MICHELIN Gids België. |
| La Table de Manon (Grandhan) | One Star, Wallonia | none | https://guide.michelin.com/us/en/be-luxembourg/grandhan/restaurant/la-table-de-manon → "Restaurant not found". https://guide.michelin.com/be/fr/be-luxembourg/grandhan/restaurant/la-table-de-manon → "Restaurant non trouvé". |

I found the three old URLs with a web search limited to guide.michelin.com. The site search https://guide.michelin.com/us/en/restaurants?q=Kommilfoo returns no restaurant. https://guide.michelin.com/us/en/restaurants?q=La%20Paix returns only La Paix in Tokyo.

So: Belgium Two Stars 20 → 19 (La Paix). Belgium One Star 105 → 103 (Kommilfoo, La Table de Manon). Luxembourg: no difference.

The live site shows no star venue that the article does not list.

---

## 6. Excluded cards

- Cards from another country inside the list row: **none**.
- Every list page also had **4 promo cards** outside `.row.restaurant__list-row.js-restaurant__list_items`. I ignored them, as the brief says. I did not read them as rows.

---

## 7. Price and currency

Count of rows for each `price_symbol_raw`, per country:

| Country | € | €€ | €€€ | €€€€ | Total |
|---|---|---|---|---|---|
| Belgium | 3 | 105 | 50 | 74 | 232 |
| Luxembourg | 0 | 2 | 3 | 10 | 15 |

- Every row prints a price. Every symbol is `€`. No row is listed as an exception.
- The three `€` rows are Belgium Bib Gourmand: Appel Thaï (Anderlecht), Alley Mian (Brussels), Car Bon (Ixelles).

Venue-page check (3 per country). "Card" = list card. "EN page" and "Local page" = the "Price:" / "Prijs:" / "Prix:" line on the venue page. JSON-LD `priceRange` is a phrase, not symbols, so I list the phrase.

| Venue | Card | EN page | Local page | `priceRange` EN | `priceRange` local |
|---|---|---|---|---|---|
| Zilte (BE) | €€€€ | €€€€ | €€€€ (/be/nl/) | Spare no expense | Pure verwennerij |
| The Jane (BE) | €€€€ | €€€€ | €€€€ (/be/nl/) | Spare no expense | Pure verwennerij |
| Glou Glou (BE) | €€ | €€ | €€ (/be/nl/) | A moderate spend | Volop genieten |
| Le Lys (LU) | €€€€ | €€€€ | €€€€ (/lu/fr/) | Spare no expense | Faire une folie |
| Ma Langue Sourit (LU) | €€€€ | €€€€ | €€€€ (/lu/fr/) | Spare no expense | Faire une folie |
| Bazaar (LU) | €€ | €€ | €€ (/lu/fr/) | A moderate spend | Se faire plaisir |

Local pages: https://guide.michelin.com/be/nl/antwerpen/be-antwerpen/restaurant/t-zilte, https://guide.michelin.com/be/nl/antwerpen/be-antwerpen/restaurant/the-jane-1244485, https://guide.michelin.com/be/nl/antwerpen/borgerhout/restaurant/glou-glou, https://guide.michelin.com/lu/fr/luxembourg/luxembourg/restaurant/le-lys-1241469, https://guide.michelin.com/lu/fr/luxembourg/oetrange/restaurant/ma-langue-sourit, https://guide.michelin.com/lu/fr/luxembourg/luxembourg/restaurant/bazaar.

Result: the symbols are identical on the card, the `/us/en/` page and the local page for all 6.

---

## 8. Six venue-page spot checks

All six agree with the card on name, city, distinction and price.

| # | Country | Category | URL | Page name | Page address | JSON-LD award | Price |
|---|---|---|---|---|---|---|---|
| 1 | Belgium | Three Stars | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/t-zilte | Zilte | Hanzestedenplaats 5, Antwerpen, 2000, Belgium | Three Stars: Exceptional cuisine (2026) | €€€€ |
| 2 | Belgium | Two Stars | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/the-jane-1244485 | The Jane | Limastraat 5, Antwerpen, 2000, Belgium | Two Stars: Excellent cooking (2026) | €€€€ |
| 3 | Belgium | One Star | https://guide.michelin.com/us/en/antwerpen/borgerhout/restaurant/bloesem | Bloesem | De Leescorfstraat 8, Borgerhout, 2140, Belgium | One Star: High quality cooking (2026) | €€€€ |
| 4 | Belgium | Bib Gourmand | https://guide.michelin.com/us/en/antwerpen/borgerhout/restaurant/glou-glou | Glou Glou | Moorkensplein 27, Borgerhout, 2140, Belgium | Bib Gourmand: good quality, good value cooking (2026) | €€ |
| 5 | Luxembourg | One Star | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/le-lys-1241469 | Le Lys | 1, Avenue Marie-Thérèse, 2132, Luxembourg | One Star: High quality cooking (2026) | €€€€ |
| 6 | Luxembourg | Bib Gourmand | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/bazaar | Bazaar | 46 Place Guillaume II, 1648, Luxembourg | Bib Gourmand: good quality, good value cooking (2026) | €€ |

---

## 9. Pass 2 (Dutch) and Pass 3 (French)

Row counts per country and category:

| Country | Category | Pass 1 EN | Pass 2 NL | Pass 3 FR |
|---|---|---|---|---|
| Belgium | Three Stars | 2 | 2 | 2 |
| Belgium | Two Stars | 19 | 19 | 19 |
| Belgium | One Star | 103 | 103 | 103 |
| Belgium | Bib Gourmand | 108 | 108 | 108 |
| Luxembourg | Three Stars | 0 | 0 | 0 |
| Luxembourg | Two Stars | 2 | 2 | 2 |
| Luxembourg | One Star | 10 | 10 | 10 |
| Luxembourg | Bib Gourmand | 3 | 3 | 3 |
| **Total** | | **247** | **247** | **247** |

Banners and filters agreed in both languages (for example "België : 97-103 van 103 restaurants - 1 Ster", "Belgique : 97-108 sur 108 restaurants - Bib Gourmand").

- Joined rows (key = part after `/restaurant/`): **Dutch 247 / 247. French 247 / 247.**
- Rows that did not join: **none**. No Dutch or French card is without an English row.
- Category differences between languages: **none**.
- Name differences between languages: **none**. Every name prints the same in all three languages.
- Rows where the city differs between the three languages: **14**.

| English card | Dutch card | French card | Rows |
|---|---|---|---|
| Brussels | Bruxelles | Bruxelles | 9 (Alley Mian, Barge, Bozar Restaurant, Comme chez Soi, Eliane, Kline, La Villa in the Sky, Selecto, Strofilia) |
| Saint Vith | Sankt Vith | Saint-Vith | 2 (Quadras, Zur Post) |
| De Panne | De Panne | La Panne | 1 (Subtiel) |
| Oudenaarde | Oudenaarde | Audenarde | 1 (The FOX) |
| Mechelen | Mechelen | Malines | 1 (Tinèlle) |

Total: 9 + 2 + 1 + 1 + 1 = 14.

Points for the city match test:
- The Dutch card prints "Bruxelles" for Brussels, not "Brussel".
- The English card prints local names for most cities: "Antwerpen" (not Antwerp), "Gent" (not Ghent), "Liège", "Namur", "Brugge". These are the same in all three languages on the cards.

---

## 10. Status and name register

### La Paix (Brussels) — closed in the database, Two Stars row

- Card in my lists: **no**. Not in any of the 7 lists, in any language.
- The 2026 star list article names "La Paix (Anderlecht)" under Two Stars, Brussels (both articles, part 5).
- Michelin page: https://guide.michelin.com/us/en/bruxelles-capitale/anderlecht/restaurant/la-paix203164 shows "Restaurant not found". The local page https://guide.michelin.com/be/fr/bruxelles-capitale/anderlecht/restaurant/la-paix203164 says the restaurant details are not available in the MICHELIN Guide Belgium.
- Michelin does not say "closed". It shows that the venue is no longer in the guide. No address is available.

### Cuines 33 and The Jane — new Two Stars

| Card name | Card city | Category | URL | Address (venue page) |
|---|---|---|---|---|
| Cuines 33 | Knokke | Two Stars | https://guide.michelin.com/us/en/west-vlaanderen/knokke/restaurant/cuines-33 | Smedenstraat 33, Knokke, 8300, Belgium |
| The Jane | Antwerpen | Two Stars | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/the-jane-1244485 | Limastraat 5, Antwerpen, 2000, Belgium |

### Luxembourg — every card (15)

| Card name | City as printed | Category | URL |
|---|---|---|---|
| Louis Linster | Frisange | Two Stars | https://guide.michelin.com/us/en/luxembourg/frisange/restaurant/lea-linster |
| Ma Langue Sourit | Oetrange | Two Stars | https://guide.michelin.com/us/en/luxembourg/oetrange/restaurant/ma-langue-sourit |
| Fields by René Mathieu | Findel | One Star | https://guide.michelin.com/us/en/luxembourg/findel/restaurant/fields-by-rene-mathieu |
| Archibald De Prince | Lauterborn | One Star | https://guide.michelin.com/us/en/grevenmacher/lauterborn/restaurant/archibald-de-prince |
| Grünewald Chef’s Table | Luxembourg | One Star | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/grunewald-chef-s-table |
| La Villa de Camille et Julien | Luxembourg | One Star | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/la-villa-de-camille-et-julien |
| Le Lys | Luxembourg | One Star | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/le-lys-1241469 |
| Mosconi | Luxembourg | One Star | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/mosconi |
| Ryôdô | Luxembourg | One Star | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/ryodo |
| Fani | Roeser | One Star | https://guide.michelin.com/us/en/luxembourg/roeser/restaurant/fani |
| Guillou Campagne | Schouweiler | One Star | https://guide.michelin.com/us/en/luxembourg/schouweiler/restaurant/guillou-campagne |
| Apdikt | Steinfort | One Star | https://guide.michelin.com/us/en/luxembourg/steinfort/restaurant/apdikt |
| Parc Le'h | Dudelange | Bib Gourmand | https://guide.michelin.com/us/en/luxembourg/dudelange/restaurant/parc-le-h |
| K restaurant | Huldange | Bib Gourmand | https://guide.michelin.com/us/en/diekirch/huldange/restaurant/k-restaurant |
| Bazaar | Luxembourg | Bib Gourmand | https://guide.michelin.com/us/en/luxembourg/luxembourg/restaurant/bazaar |

Notes: the Louis Linster URL slug is `lea-linster`. The article spells "Ma langue sourit"; the card prints "Ma Langue Sourit".

---

## 11. Hold register (no CSV rows)

### Green Star

- The Distinction filter on https://guide.michelin.com/us/en/selection/belgium/restaurants has only 4 values: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Luxembourg has `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. **No Green Star filter.**
- I found **no Green Star list article** for Belgium & Luxembourg 2026 (web search limited to guide.michelin.com).
- The ceremony article https://guide.michelin.com/en/article/michelin-guide-ceremony/cuines-33-and-the-jane-awarded-two-stars-in-the-michelin-guide-belgium-and-luxembourg-2026 does not use the words "Green Star". It names three new restaurants that it says embody the gastronomy of tomorrow:

| Name | Town (article) | Venue page | What the page shows |
|---|---|---|---|
| Instroom by Seppe Nobels | Antwerp | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/instroom-by-seppe-nobels | Selected (`data-dtm-distinction` = `plate`), no award in JSON-LD, no "Mindful Voices" block |
| Màloma | Rosières | https://guide.michelin.com/us/en/brabant-wallon/rosieres_1065683/restaurant/maloma-1242542 | Selected (`plate`), no award in JSON-LD, has a "MINDFUL VOICES" chef-statement block (`.data-sheet__mindful`) |
| Nova | Sint-Niklaas | https://guide.michelin.com/us/en/oost-vlaanderen/sint-niklaas/restaurant/nova-532765 | Selected (`plate`), no award in JSON-LD, has a "MINDFUL VOICES" chef-statement block |

None of the three is in today's star or Bib lists. I did not guess any Green Star URL. Ben to decide.

### Special awards 2026 (source: ceremony article above)

| Award | Person | Venue | Venue URL | In today's star or Bib list? |
|---|---|---|---|---|
| MICHELIN Young Chef Award | Abel Demeestere | EST (Heverlee) | https://guide.michelin.com/us/en/vlaams-brabant/heverlee/restaurant/est-1242817 | Yes — One Star |
| MICHELIN Sommelier Award | Nicolas Campus | Les Gribaumonts (Mons) | https://guide.michelin.com/us/en/hainaut/mons/restaurant/les-gribaumonts | No — page shows Selected (`plate`) |
| MICHELIN Service Award | Viviane Plaquet and Gitte Geunes | Zilte (Antwerp) | https://guide.michelin.com/us/en/antwerpen/be-antwerpen/restaurant/t-zilte | Yes — Three Stars |
| MICHELIN Opening of the Year Award | (venue award) | La Villa Lorraine (Brussels) | https://guide.michelin.com/us/en/bruxelles-capitale/bruxelles/restaurant/la-villa-lorraine-1246740 | No — page shows Selected (`plate`) |

### Other facts from the ceremony article

- Ceremony on 4 May 2026 at the Handelsbeurs in Antwerp. The 2026 edition has 764 restaurants, 139 with at least One Star. 10 new One Star restaurants.
- 7 new Bib Gourmands. The article names 3: Alley Mian (Brussels), Den Bourgondiër (Wilrijk), Basta! (Wanze). All 3 are in my Bib list.
- Bib totals from the Distinction filter: **Belgium 108, Luxembourg 3**.

---

## 12. Hashes

Pass 1 (English) lines: one line per card, fields joined by TAB: path after `/us/en/`, category code (3/2/1/B), country code, name, first footer line, price. Lines sorted, joined with `\n`.

| Block | Lines | SHA-256 (browser = copy) |
|---|---|---|
| 1 | 1–100 | `a0eb1392893aab35af2e97bbac08d6ea1689d00f847b45eaf7e72c8ff4d13eab` |
| 2 | 101–200 | `841fdde243b0083a7c03c064b1a9be1cbff4932c4a21d5701c6759df9668bc52` |
| 3 | 201–247 | `3b24845629f5134e545f28d61c22d87c68c30d8a53afc25d2f29624ef7c8fcf7` |
| Full English data | 247 | `966c7c38def321c409f787585682ea73b5a255dc750bc5e9d7074724a092d609` |

Pass 2 + 3 lines: key, Dutch name, Dutch city, French name, French city (TAB, sorted, `\n`):

| Data | Lines | SHA-256 (browser = rebuilt) |
|---|---|---|
| Full Dutch + French data | 247 | `31de4e5bc697f284994b3255d3325de48c2a1367af264b67bd6d12ce1c8f2b2d` |

Final file:

| File | Rows | Bytes | SHA-256 |
|---|---|---|---|
| `michelin-2026-belgium-luxembourg.csv` | 247 + header | 62,370 | `4163c11dd56eba2a658a201890bab252810abbb068f7ecafe905c19ef2dbf9db` |
