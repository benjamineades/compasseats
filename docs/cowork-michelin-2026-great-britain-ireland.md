# Cowork brief: Michelin 2026 Great Britain & Ireland

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Great Britain & Ireland 2026 selection from guide.michelin.com with the Chrome extension. Michelin shows this guide as two country selections: **United Kingdom** and **Republic of Ireland**. Capture both. Make one CSV file and one log file for both countries together. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star, or special awards. Green Star and special awards go in the log only (see "Hold register").

The ceremony was on Monday, February 9, 2026, at the Convention Centre Dublin. The Bib Gourmands were announced one week before, on February 2, 2026. The ceremony was before June 1, 2026. So this guide uses the name "Green Star", not "Mindful Voices".

Counts that Michelin published at the ceremony:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Great Britain & Ireland 2026, Michelin "at a glance" | 10 | 28 | 192 | 168 | 398 |
| Republic of Ireland (count of the Michelin star list) | 0 | 5 | 18 | not published | – |
| United Kingdom (total minus Ireland) | 10 | 23 | 174 | not published | – |
| CompassEats database, legacy rows, United Kingdom (reference only) | 10 | 23 | 167 | 149 | 349 |
| CompassEats database, legacy rows, Ireland (reference only) | 0 | 5 | 18 | 19 | 42 |

Michelin did not publish the Bib split by country. Get it from the site's Distinction filter for each country and write it in the log.

Sources (open them through the browser, because Michelin blocks plain fetchers):
- Ceremony results: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-stars-news-uk-ireland-2026
- Full star list: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-star-restaurant-in-great-britain-ireland
- Countdown article (ceremony date): https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/michelin-guide-ceremony-countdown-2026-dublin

Rules for scope:

1. Before you start, make sure that the site still shows the **2026** selection. Open one venue page for each country. Read the guide year in the page meta description and write the exact phrase in the log. If any page or list shows a **2027** selection for Great Britain or Ireland, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Two Stars: **Bonheur by Matt Abé** (London) and **Row on 5** (London).
   - One Star: **Forest Avenue** (Dublin) and **The Pullman** (Galway).
   If one of them is not in the category above, stop and tell Ben.
3. The star list article now marks 8 One Star restaurants "[now closed]": Endo at The Rotunda, Mark Poynton at Caistor Hall, Outlaw's New Road, Simpsons, SO|LA, Somssi by Jihun Kim, Sorrel, The Masons Arms. Expect no card for them. If a card for one of them is on the live list, capture it as a normal row and list it in the log.
4. Expect about 390 rows. The live site is months newer than the ceremony, and closed restaurants leave the list. If your total is more than 10% away from 390, explain the difference in the log before you deliver.
5. Every row must be in the United Kingdom, the Channel Islands, the Isle of Man, or the Republic of Ireland. If a list shows a card from another country, do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-great-britain-ireland.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-great-britain-ireland` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. |
| `venue_name` | exactly as the English card prints it. Do not tidy it or cut it at a dash. Keep accents and special letters (for example "Bonheur by Matt Abé", "LIGИUM", "Sō–Lō"). |
| `city_label` | the city that the card prints. Do not replace a town with the nearest big city. |
| `country_label` | `United Kingdom` or `Ireland`, from the card's `data-restaurant-country` attribute (see "Country rules") |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `united-kingdom-2026` or `ireland-2026`, the same country as `country_label` |

File rules: UTF-8. Put quotation marks around any field that contains a comma. Never type rows by hand. Build the file with code from the extracted data.

The last column is extra. The importer ignores it and reports it as ignored. That is correct. It stays in the file for the count check.

## Country rules

- The URL territory part (`/gb/en/` or `/ie/en/`) does **not** decide the country. For example, one Michelin article links Homestead Cottage (Doolin, County Clare, Ireland) with a `/gb/en/` URL. Use the card's `data-restaurant-country` attribute.
- **Northern Ireland** (for example Belfast) is in the United Kingdom. `country_label` = `United Kingdom`.
- **Channel Islands and Isle of Man** (for example Saint Helier in Jersey, Vale and St Peter Port in Guernsey): use `country_label` = `United Kingdom`, because the CompassEats database files these towns under the United Kingdom. In the log, list each of these rows with its URL and the exact `data-restaurant-country` value.
- A venue can be in one country list only. If a card is in both lists, stop and tell Ben.

## Price and currency

Ben needs the currency for each country for a later price job.

1. Copy the price symbols exactly as printed. Expect `£` for the United Kingdom and `€` for Ireland. Do not convert or normalize them.
2. Open 3 venue pages for each country. Compare the card symbols with the venue page `priceRange` (JSON-LD). Also open the same 3 venues on the local site (`/gb/en/` for the United Kingdom, `/ie/en/` for Ireland). Make sure that the symbols are identical on the `/us/en/` and local pages.
3. In the log, write the symbol that each country uses, with one URL for each. Write the count of rows for each distinct `price_symbol_raw` value, per country.
4. If a row prints no price, or a symbol that is not the country's normal symbol (for example a Channel Islands card), keep it as printed and list it in the log.

## Pass 1: English lists (the method from Italy and Japan, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<country-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`.

Three traps:

1. **The country part must be `selection/<country-slug>`.** A wrong slug returns the worldwide list with no error, and it puts your country word in the page title. To find each real slug, type "United Kingdom" (then "Ireland") into the site's destination search box and click the plain country row under "Locations". Then make sure that each card's `data-restaurant-country` attribute shows that country.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Allowed alternative: in-page `fetch()` plus `DOMParser`, from a tab that is already on guide.michelin.com (a tab on another site gets "fetch blocked"). Use it only after you prove it on one page: the rows from `fetch()` and from the rendered page must give the same SHA-256 (sorted lines joined with `\n`). Write both hashes in the log.

Script limits:
- A browser call stops at 45 seconds, but the script keeps on in the page. Store results on `window.__x` and read them again later.
- Tool output stops at about 1,000 characters. Do not read a large result through one output. Build the file with code.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each country and category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages (3 per country; include one Northern Ireland venue and one Channel Islands venue). Compare name, city, distinction, and price with the card.

## Hold register (log only, no CSV rows)

- **Green Star.** Michelin says the guide holds 37 Green Stars (7 new: 1887, Eight at Gazegill by Doug Crampton, Forest Side, Glebe House, Knepp Wilding Kitchen, The Free Company, Timberyard). Record the full list from the Green Star article with URLs: https://guide.michelin.com/gb/en/article/michelin-guide-ceremony/green-stars-sustainable-gastronomy-great-britain-uk-ireland-full-list-new. The site has no Green Star filter. Do not try a `/green-star` URL.
- **Special awards (5).** For each one, record the award, the person, the venue, and the URL:
  - Opening of the Year: Shwen Shwen, Sevenoaks.
  - Young Chef: Tom Earnshaw, Bohemia, St Helier.
  - Service: Barbara Nealon, Saint Francis Provisions, Kinsale.
  - Sommelier: Roxane Dupuy, Row on 5, London.
  - Exceptional Cocktails: Alasdair Shaw, Sebb's, Glasgow.
- For each special-award venue, write if it is in today's star or Bib list, or not.

## Output 2: `michelin-2026-great-britain-ireland-log.md`

Include these parts:

1. The method: the two country slugs that you found, and any change from the method above.
2. A count table for each country and category: your rows, the site banner, the Distinction filter, and the ceremony count.
3. The results of the duplicate check, the two-category check, and the two-country check.
4. The 2027 check and the four named 2026 changes (scope rules 1 and 2).
5. The closed-restaurant check (scope rule 3).
6. The Channel Islands, Isle of Man and Northern Ireland rows, with URLs and `data-restaurant-country` values.
7. Any cards that you excluded, with URLs.
8. The price and currency results.
9. The six venue-page spot checks.
10. The hold register, with URLs.
11. The SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the `£`, `€` and accented letters.

## Stop

After the two files, write Ben a short summary: the row count per country and category, the difference from 390, the currency per country, and the cards that you held out. Then wait for Ben.
