# Cowork brief: Michelin 2026 Belgium & Luxembourg

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Belgium & Luxembourg 2026 selection from guide.michelin.com with the Chrome extension. Michelin shows this guide as two country selections: **Belgium** and **Luxembourg**. Capture both. Make one CSV file and one log file for both countries together. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star or special awards. Green Star and special awards go in the log only (see "Hold register").

The ceremony was on May 4, 2026, at the Handelsbeurs in Antwerp. The ceremony was before June 1, 2026. So this guide uses the name "Green Star", not "Mindful Voices".

Counts that Michelin published at the ceremony, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Belgium & Luxembourg 2026, Michelin star list article | 2 | 22 | 115 | not published | – |
| CompassEats database, legacy rows, Belgium (reference only) | 2 | 20 | 104 | 108 | 234 |
| CompassEats database, legacy rows, Luxembourg (reference only) | 0 | 2 | 10 | 3 | 15 |

Michelin did not publish the Bib total or the split by country. Get them from the site's Distinction filter for each country and write them in the log. The ceremony article reports 7 new Bib Gourmands.

Sources (open them through the browser, because Michelin blocks plain fetchers):
- Ceremony results: https://guide.michelin.com/en/article/michelin-guide-ceremony/cuines-33-and-the-jane-awarded-two-stars-in-the-michelin-guide-belgium-and-luxembourg-2026
- Full star list (Dutch): https://guide.michelin.com/be/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-sterren-in-de-michelin-gids-belgie-en-luxemburg-2026
- Full star list (French): https://guide.michelin.com/be/fr/article/michelin-guide-ceremony/la-liste-complete-des-etoiles-dans-le-guide-michelin-belgique-et-luxembourg-2026

Rules for scope:

1. Before you start, make sure that the site still shows the **2026** selection. Open one venue page for each country. Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If any page or list shows a **2027** selection for Belgium or Luxembourg, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Two Stars: **Cuines 33** (Knokke-Heist) and **The Jane** (Antwerp).
   - One Star: **Bloesem** (Borgerhout), **La Table-Lasne by Alain Bianchin** (Ohain) and **Le Lys** (Luxembourg).
   If one of them is not in the category above, stop and tell Ben.
3. Count the entries in the full star list article for each category and country. Write the counts in the log. The article page has one block of about 34 names (Wallonia) with no clear heading. Write which category that block belongs to, with the evidence. List every entry that the article marks as closed.
4. Expect about 250 rows. The live site is months newer than the ceremony, and closed restaurants leave the list. If your star total is more than 10% away from 139, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
5. Every row must be in Belgium or Luxembourg. If a list shows a card from another country, do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-belgium-luxembourg.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,venue_name_nl,city_label_nl,venue_name_fr,city_label_fr
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-belgium-luxembourg` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path. |
| `venue_name` | exactly as the English card prints it. Do not tidy it or cut it at a dash. Keep accents and special letters. |
| `city_label` | the city that the English card prints. Do not replace a town or a district with the nearest big city (for example Borgerhout stays Borgerhout, Gentbrugge stays Gentbrugge). |
| `country_label` | `Belgium` or `Luxembourg`, from the card's `data-restaurant-country` attribute |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `belgium-2026` or `luxembourg-2026`, the same country as `country_label` |
| `venue_name_nl` | the name on the Dutch-language card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `city_label_nl` | the city on the Dutch-language card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `venue_name_fr` | the name on the French-language card (Pass 3). Blank only if Pass 3 has no card for this URL. |
| `city_label_fr` | the city on the French-language card (Pass 3). Blank only if Pass 3 has no card for this URL. |

File rules: UTF-8. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last five columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for the count check and for the city match test.

## Country rules

- The URL territory part (`/be/`, `/lu/`, `/us/`) does **not** decide the country. Use the card's `data-restaurant-country` attribute.
- A venue can be in one country list only. If a card is in both lists, stop and tell Ben.

## Price and currency

1. Copy the price symbols exactly as printed. Expect `€` for both countries. Do not convert or normalize them.
2. Open 3 venue pages for each country. Compare the card symbols with the venue page `priceRange` (JSON-LD). Make sure that the symbols are identical on the `/us/en/` page and on the local page.
3. In the log, write the count of rows for each distinct `price_symbol_raw` value, per country.
4. If a row prints no price, or a symbol that is not `€`, keep it as printed and list it in the log.

## Pass 1: English lists (the method from Germany, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<country-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`. `/page/1` redirects to the URL without `/page/1`.

Three traps:

1. **The country part must be `selection/<country-slug>`.** A wrong slug returns the worldwide list with no error, and it puts your country word in the page title. To find each real slug, type "Belgium" (then "Luxembourg") into the site's destination search box and click the plain country row under "Locations". Then make sure that each card's `data-restaurant-country` attribute shows that country.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city = first `.card__menu-footer--score` line minus ", Belgium" or ", Luxembourg"; price = second footer line before " · "; country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

**Do not use in-page `fetch()` plus `DOMParser`.** On Sep 28 it failed the proof test on the United Kingdom lists. Open every list page in the browser tab and read the rendered DOM.

Script limits:
- A browser call stops at 45 seconds, but the script keeps on in the page. Store results on `window.__x` and read them again later.
- Tool output stops at about 1,000 characters. Show the rows in the page in blocks of up to 100 lines, copy them, and check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each country and category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages (4 Belgium, 2 Luxembourg; include 2 Bib, 2 One Star, 1 Two Stars, 1 Three Stars). Compare name, city, distinction and price with the card.

## Pass 2 and Pass 3: Dutch and French lists (names and cities)

The CompassEats database files some Belgian cities under the English name (for example Antwerp, Brussels) and some under a local name. Pass 2 and Pass 3 give the match test all three.

1. Find the Dutch country slugs with the destination search box on `https://guide.michelin.com/be/nl/` (type "België", then "Luxemburg"). Find the French country slugs on `https://guide.michelin.com/be/fr/` (type "Belgique", then "Luxembourg"). Click the plain country row under the locations heading each time.
2. Read the same four distinction lists for each country with the same rules as Pass 1.
3. Join each Dutch and each French card to its Pass 1 row on the part of the URL after `/restaurant/`. Fill `venue_name_nl`, `city_label_nl`, `venue_name_fr` and `city_label_fr`.
4. In the log, write: the row count per country and category for Pass 2 and Pass 3, the number of joined rows, every row that did not join (with both URLs if any), every row where a Dutch or French category differs from the English category, and the count of rows where the city differs between the three languages (with the pairs, for example Antwerp / Antwerpen / Anvers).

## Status and name register (log only)

The CompassEats database has questions on these venues. For each one, write whether a card exists in your lists (name, category, URL), and the address from the venue page if a card exists.

- **Closed in the database:** La Paix (Brussels), with a Two Stars row. The 2026 star list names La Paix under Brussels. If no card exists, open a Michelin page for the venue if one is still online, and write what it says.
- **Two new Two Stars:** Cuines 33 and The Jane. Write the card name and city exactly.
- **Luxembourg:** list every card with its city as printed.

## Hold register (log only, no CSV rows)

- **Green Star.** Write what the site and the articles show for Belgium & Luxembourg 2026 (a Green Star list article, names, URLs). The site has no Green Star filter in some countries. Do not guess a URL. Do not make rows.
- **Special awards.** Record each 2026 special award (award, person, venue, URL), and write if the venue is in today's star or Bib list.

## Output 2: `michelin-2026-belgium-luxembourg-log.md`

Include these parts:

1. The method: the English, Dutch and French country slugs that you found, and any change from the method above.
2. A count table for each country and category: your rows, the site banner, the Distinction filter, and the published count.
3. The results of the duplicate check, the two-category check and the two-country check.
4. The 2027 check and the five named 2026 changes (scope rules 1 and 2).
5. The star list article counts and closed entries (scope rule 3), and the difference from 139 (scope rule 4).
6. Any cards that you excluded, with URLs.
7. The price and currency results.
8. The six venue-page spot checks.
9. The Pass 2 and Pass 3 results.
10. The status and name register.
11. The hold register, with URLs.
12. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the `€` and accented letters.

## Stop

After the two files, write Ben a short summary: the row count per country and category, the difference from 139 stars, the Bib count per country from the filter, the Pass 2 and Pass 3 join counts, the cards that you held out, and the answer for La Paix. Then wait for Ben.
