# Cowork brief: Michelin 2026 Germany

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Germany 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star or special awards. Special awards go in the log only (see "Hold register").

The ceremony was on June 23, 2026, at the Gesellschaftshaus Palmengarten, Frankfurt am Main. The Bib Gourmands were announced one week before.

Counts that Michelin published at the ceremony, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Germany 2026, Michelin "at a glance" | 12 | 48 | 279 | 147 | 486 |
| Germany 2025, Michelin "at a glance" (reference only) | 12 | 47 | 282 | 156 | 497 |
| CompassEats database, legacy rows labelled 2026 (reference only) | 12 | 48 | 278 | 0 | 338 |

Sources (open them through the browser, because Michelin blocks plain fetchers):
- 2026 ceremony results: https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-germany-2026-is-out
- 2025 ceremony results (reference): https://guide.michelin.com/en/article/michelin-guide-ceremony/the-michelin-guide-germany-2025-is-out

Rules for scope:

1. Before you start, make sure that the site still shows the **2026** selection. Open 3 venue pages (one per star level). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If any page or list shows a **2027** selection for Germany, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Three Stars: **L.A. Jordan** (Deidesheim).
   - Two Stars: **Mühle** (Schluchsee), **RAUSCH** (Frankfurt am Main), **THE CLOUD by Käfer** (Munich).
   - One Star: **Porte Neuf** (Detmold).
   If one of them is not in the category above, stop and tell Ben.
3. Look for a Michelin article with the full 2026 star list for Germany (search guide.michelin.com under the Germany tag; the Austria guide has one called "All Starred Restaurants - MICHELIN Guide Austria 2026"). If you find it, record the URL, and list every entry that it marks as closed. If you do not find it, write that in the log with the search that you used.
4. Expect about 480 rows. The live site is months newer than the ceremony, and closed restaurants leave the list. If your total is more than 10% away from 486, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
5. Every row must be in Germany. If a list shows a card from another country, do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-germany.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,venue_name_de,city_label_de
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-germany` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path. |
| `venue_name` | exactly as the English card prints it. Do not tidy it or cut it at a dash. Keep accents, umlauts, ß and special letters (for example "Cølbo", "Laesâ", "Gourmetrestaurant \"1751\""). |
| `city_label` | the city that the English card prints. Do not replace a town with the nearest big city. |
| `country_label` | `Germany` |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `germany-2026` |
| `venue_name_de` | the name on the German-language card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `city_label_de` | the city on the German-language card (Pass 2). Blank only if Pass 2 has no card for this URL. |

File rules: UTF-8. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last three columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for the count check and for the city match test.

## Price and currency

1. Copy the price symbols exactly as printed. Expect `€`. Do not convert or normalize them.
2. Open 3 venue pages. Compare the card symbols with the venue page `priceRange` (JSON-LD). Also open the same 3 venues on the German site (`/de/de/`). Make sure that the symbols are identical.
3. In the log, write the count of rows for each distinct `price_symbol_raw` value.
4. If a row prints no price, or a symbol that is not `€`, keep it as printed and list it in the log.

## Pass 1: English lists (the method from Great Britain & Ireland, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<country-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards (One Star: about 6 pages, Bib: about 4 pages). Get the page links from the DOM: collect `a[href*="/page/"]`. `/page/1` redirects to the URL without `/page/1`.

Three traps:

1. **The country part must be `selection/<country-slug>`.** A wrong slug returns the worldwide list with no error, and it puts your country word in the page title. To find the real slug, type "Germany" into the site's destination search box and click the plain country row under "Locations". Then make sure that each card's `data-restaurant-country` attribute shows `de`.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card (as in the Great Britain & Ireland log): name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city = first `.card__menu-footer--score` line minus ", Germany"; price = second footer line before " · "; country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

**Do not use in-page `fetch()` plus `DOMParser`.** On Sep 28 it failed the proof test on the United Kingdom lists: the fetched HTML had a different set of 48 cards on page 1 and raw distinction values. Open every list page in the browser tab and read the rendered DOM.

Script limits:
- A browser call stops at 45 seconds, but the script keeps on in the page. Store results on `window.__x` and read them again later.
- Tool output stops at about 1,000 characters. Show the rows in the page in blocks of up to 100 lines, copy them, and check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages (2 Bib, 2 One Star, 1 Two Stars, 1 Three Stars). Compare name, city, distinction and price with the card.

## Pass 2: German lists (names and cities in German)

The CompassEats database files some cities under the German name (for example Köln) and some under the English name (for example Munich). Pass 2 gives the match test both.

1. Find the German country slug with the destination search box on `https://guide.michelin.com/de/de/` (type "Deutschland", click the plain country row under the locations heading).
2. Read the same four distinction lists with the same rules as Pass 1, on `https://guide.michelin.com/de/de/selection/<slug>/restaurants/<distinction-slug>/page/<N>`.
3. Join each German card to its Pass 1 row on the part of the URL after `/restaurant/`. Fill `venue_name_de` and `city_label_de` from the German card.
4. In the log, write: the row count per category for Pass 2, the number of joined rows, every row that did not join (with both URLs if any), and every row where the German category differs from the English category.

## Status and second-restaurant register (log only)

The CompassEats database has questions on these venues. For each one, write in the log whether a card exists in your lists (name, category, URL), and the address from the venue page if a card exists.

- **Closed in the database but with a 2026 star in the database:** Gasthof Alex (Weißenbrunn), Pfortenhaus Kloster Eberbach (Eltville am Rhein). If no card exists, open a Michelin page for the venue if one is still online, and write what it says.
- **Closed in the database:** Aqua (Wolfsburg). Write if any card exists.
- **Second restaurant with a Bib Gourmand:** each of these starred restaurants has a second restaurant in the same building that held a Bib Gourmand. For each town, list every Bib Gourmand card in that town with name, URL and address, and the star card with its address: Schwingshackl ESSKULTUR (Bernried), Hämmerles Restaurant (Blieskastel), Die Mühlenhelle (Gummersbach), Restaurant HochZwei im Gasthof zum Bad (Langenau), Restaurant Hirsch (Sonnenbühl).

## Hold register (log only, no CSV rows)

- **Special awards (4).** For each one, record the award, the person, the venue, the URL, and whether the venue is in today's star or Bib list:
  - Service: Karin Weißer, Sankt Benedikt, Aachen.
  - Young Chef: Axel Boesen, Dopamin, Saarburg.
  - Sommelier: Noris F. Conrad, Tantris, Munich.
  - Opening of the Year: THE CLOUD by Käfer, Munich.
- **Green Star.** The 2026 ceremony article does not mention Green Stars. Write what the site shows for Germany 2026 (a Green Star filter, a list article, or nothing), with URLs. Do not make rows.

## Output 2: `michelin-2026-germany-log.md`

Include these parts:

1. The method: the English and German country slugs that you found, and any change from the method above.
2. A count table for each category: your rows, the site banner, the Distinction filter, and the ceremony count.
3. The results of the duplicate check, the two-category check and the country check.
4. The 2027 check and the five named 2026 changes (scope rules 1 and 2).
5. The star-list article and closed-restaurant check (scope rule 3), and the difference from 486 (scope rule 4).
6. Any cards that you excluded, with URLs.
7. The price and currency results.
8. The six venue-page spot checks.
9. The Pass 2 results.
10. The status and second-restaurant register.
11. The hold register, with URLs.
12. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the `€`, umlauts, ß and accented letters.

## Stop

After the two files, write Ben a short summary: the row count per category, the difference from 486, the Pass 2 join count, the cards that you held out, and the answers for the status register. Then wait for Ben.
