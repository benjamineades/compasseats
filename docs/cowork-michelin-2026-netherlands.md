# Cowork brief: Michelin 2026 Netherlands

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Netherlands 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Mindful Voices, Green Star or special awards. These go in the log only (see "Hold register").

Michelin revealed the Netherlands 2026 selection on October 5, 2026, at MECC Maastricht. The date is after June 1, 2026. So this guide uses the name "Mindful Voices", not "Green Star" (the same as Texas 2026).

The 2026 edition is new. Michelin can still add or remove cards in the days after a ceremony. Read the live site and report what it shows on the day of your run.

Counts that Michelin published, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Netherlands 2026, Michelin articles (star list, Bib list) | 1 | 20 | 98 | 77 | 196 |
| Netherlands 2025, Michelin star list article (reference only) | 1 | 20 | 98 | not checked | – |
| CompassEats database, legacy rows labelled 2025 (reference only) | 1 | 18 | 92 | 74 | 185 |

The 2026 star totals (1 / 20 / 98) come from the ceremony article. The Bib count 77 is the number of entries in the 2026 Bib list article. The ceremony article reports 499 restaurants in the selection, 2 new Two Stars, 7 new One Stars and 10 new Bib Gourmands. Get the Bib count from the site's Distinction filter too, and write both numbers in the log.

Sources (open them through the browser, because Michelin blocks plain fetchers on list pages):
- Ceremony results (English): https://guide.michelin.com/en/article/michelin-guide-ceremony/azurite-and-suis-awarded-two-michelin-stars-each-in-the-2026-netherlands-michelin-guide
- Ceremony results (Dutch): https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/azurite-en-suis-bekroond-met-twee-sterren-in-de-michelin-gids-nederland-2026
- Full star list 2026 (Dutch): https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-sterren-in-de-michelin-gids-nederland-2026
- Full Bib list 2026 (Dutch): https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-bib-gourmand-restaurants-in-de-michelin-gids-nederland-2026
- Full star list 2025 (reference): https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-sterren-in-de-michelin-gids-nederland-2025
- Full Bib list 2025 (reference): https://guide.michelin.com/nl/nl/article/michelin-guide-ceremony/de-volledige-lijst-van-de-bib-gourmand-restaurants-in-de-michelin-gids-nederland-2025

Rules for scope:

1. Before you start, make sure that the site shows the **2026** selection. Open 3 venue pages (1 Two Stars, 1 One Star, 1 Bib). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If a page still says 2025, stop and tell Ben. If any page or list shows a **2027** selection, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Two Stars: **Azurite** (Delft) and **SUIS** (Schin op Geul).
   - One Star: **De Cuijt** (Mierlo), **Le Epifaan** (Veeningen) and **Rozewied** (Kortgene).
   - Bib Gourmand: **Ramen Kitanoya** (Den Haag).
   If one of them is not in the category above, stop and tell Ben.
3. Count the entries in the 2026 star list article for each category. Write the counts in the log. A plain fetch of this page showed only 19 names under the One Star heading and a block of about 79 names with no clear heading after it. Write which category that block belongs to, with the evidence. List every entry that the article marks as closed. Do the same count for the 2026 Bib list article.
4. Compare the 2026 lists with the 2025 lists (star list and Bib list articles). List every 2025 entry that is not in the 2026 list, and every 2026 entry that is not in the 2025 list, with the category in each year. Use the URLs of the cards when they exist.
5. Expect about 196 rows. If your star total differs from 119, or your Bib total differs from 77, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
6. Every row must be in the Netherlands. If a list shows a card from another country, do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-netherlands.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,venue_name_nl,city_label_nl
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-netherlands` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path. |
| `venue_name` | exactly as the English card prints it. Do not tidy it or cut it at a dash. Keep accents, dots and special characters (for example "GEM.", "Château Neercanne"). |
| `city_label` | the city that the English card prints. Do not replace a village with the nearest big city (for example Schin op Geul stays Schin op Geul, Den Hoorn stays Den Hoorn). |
| `country_label` | `Netherlands`, from the card's `data-restaurant-country` attribute |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `netherlands-2026` |
| `venue_name_nl` | the name on the Dutch-language card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `city_label_nl` | the city on the Dutch-language card (Pass 2). Blank only if Pass 2 has no card for this URL. |

File rules: UTF-8, no BOM, LF line ends. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last three columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for the count check and for the city match test.

## Country rules

- The URL territory part (`/nl/`, `/us/`) does **not** decide the country. Use the card's `data-restaurant-country` attribute. It holds a code. In Belgium it was `be`. Write the code that you see for the Netherlands, and map it to `Netherlands` with code.
- Every card in the CSV must carry the Netherlands code. A card with another code goes to the log only.

## Price and currency

1. Copy the price symbols exactly as printed. Expect `€`. Do not convert or normalize them.
2. Open 3 venue pages. Compare the card symbols with the venue page `priceRange` (JSON-LD). Make sure that the symbols are identical on the `/us/en/` page and on the Dutch page.
3. In the log, write the count of rows for each distinct `price_symbol_raw` value.
4. If a row prints no price, or a symbol that is not `€`, keep it as printed and list it in the log.

## Pass 1: English lists (the method from Germany and Belgium, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<country-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs on `/us/en/`: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`. `/page/1` redirects to the URL without `/page/1`.

Three traps:

1. **The country part must be `selection/<country-slug>`.** A wrong slug returns the worldwide list with no error, and it puts your country word in the page title. To find the real slug, type "Netherlands" into the site's destination search box and click the plain country row under "Locations". The slug is probably `netherlands`, but use the one that the search box gives. Then make sure that each card's `data-restaurant-country` attribute shows the Netherlands code. Make your scripts stop if the page path does not contain `selection/<country-slug>`.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city = first `.card__menu-footer--score` line minus ", Netherlands" (write the raw line for 3 cards in the log); price = second footer line before " · "; country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

**Do not use in-page `fetch()` plus `DOMParser`.** On Sep 28 it failed the proof test on the United Kingdom lists. Open every list page in the browser tab and read the rendered DOM.

Storage and copy (the method that worked for Belgium on Oct 10):

- Each list page is a new page load, so `window.__x` is lost. Store results in the browser `localStorage` of guide.michelin.com under keys that start with `__nl26_`. Remove your `__nl26_` keys at the end. Do not read, change or delete any other key (for example `__cx` or `__bl26_` keys from earlier sessions).
- A browser call stops at 45 seconds, but the script keeps on in the page. Read the stored results again later.
- Tool output stops at about 1,000 characters. Show the rows in the page as plain text (`<pre>`) in blocks of up to 100 lines, with ` | ` as the field separator. Read each block with the page-text tool. Check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.
- Copy the exact code points. In Belgium, one name wrote ü as two code points (u + U+0308), and the block hash caught a copy that used one code point. If a block hash fails, find the cause and fix it with code. Do not normalize names. List every name that is not NFC in the log.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages (2 Bib, 2 One Star, 1 Two Stars, 1 Three Stars; include one village outside the big cities). Compare name, city, distinction and price with the card.

## Pass 2: Dutch lists (names and cities)

The CompassEats database files some Dutch cities under an English name (for example The Hague) and most under the Dutch name. Pass 2 gives the match test both.

1. Find the Dutch country slug with the destination search box on `https://guide.michelin.com/nl/nl/` (type "Nederland"). Click the plain country row under the locations heading.
2. **Do not assume the distinction slugs.** On the French Belgian site, the English star slugs redirected to the worldwide list with no error. Read the four distinction slugs from the Distinction filter checkbox values on the Dutch country page. Write them in the log.
3. Read the four distinction lists with the same rules as Pass 1.
4. Join each Dutch card to its Pass 1 row on the part of the URL after `/restaurant/`. Fill `venue_name_nl` and `city_label_nl`.
5. In the log, write: the row count per category for Pass 2, the number of joined rows, every row that did not join (with both URLs if any), every row where the Dutch category differs from the English category, and the count of rows where the name or the city differs between the two languages (with the pairs, for example The Hague / Den Haag).

## Status and name register (log only)

The CompassEats database has questions on these venues. For each one, write whether a card exists in your lists (exact card name, category, city, URL). If no card exists, open the Michelin venue page if it is still online, and write what it says (for example "Restaurant not found").

- **Closed in the database:** Demain (Cadzand), with a One Star 2025 row. Spectrum (Amsterdam), closed, with no Michelin row (the 2025 star list names it at Two Stars).
- **De Groene Lantaarn (Staphorst):** Two Stars in the 2025 star list. The 2026 ceremony article says that it closed earlier this year, and that chef Jarno Eggen now runs Le Epifaan (Veeningen). Write the exact sentence and the URL.
- **De Juwelier (Amsterdam)** and **Restaurant Daalder (Amsterdam):** write the 2026 category or that no card exists.
- **Names that differ from the database.** Write the exact English card name for each: GEM. (Gemert; database "Restaurant GEM."; the 2025 articles add the chef's name), Brut172 (Reijmerstok; database "Brut172 by Hans van Wolde"), FG (Rotterdam; database "François Geurds FG Restaurant"; 2025 star list "FG - François Geurds"), 't Nonnetje (Harderwijk; database "t Nonnetje"), Flore (Amsterdam; database "Restaurant Flore"), De Nieuwe Winkel (Nijmegen; database "Restaurant De Nieuwe Winkel").
- **The Hague:** write the city that the English card prints and the city that the Dutch card prints, for every card in that city.
- **New stars:** write the card name and city exactly for the 2 new Two Stars and the 7 new One Stars.

## Hold register (log only, no CSV rows)

- **Mindful Voices.** The ceremony article names Jef Schuur (Bij Jef, Den Hoorn) and Kees Meinderts (Mearkas, Eastermar). Write what the site shows for each (category, URL, and any "Mindful Voices" block on the venue page).
- **Green Star.** The 2025 edition had 23 Green Star restaurants. Write whether the 2026 site still shows a Green Star filter, list or mark for the Netherlands. Do not guess a URL. Do not make rows.
- **Special awards.** Record each 2026 special award (award, person, venue, URL), and write if the venue is in today's star or Bib list. The ceremony article names: Young Chef Award (Noëmie Haentjens and Ferdy van Rijswijk, Rozewied, Kortgene); Service Award (team of Château Neercanne, Maastricht); Sommelier Award (Matthijs Vranken and Nouri Haj Romdhane, Brut172, Reijmerstok); Opening of the Year Award (Falk van Essen and Caroline de Vries, Luwte, Groningen).

## Output 2: `michelin-2026-netherlands-log.md`

Include these parts:

1. The method: the English and Dutch country slugs, the Dutch distinction slugs, the `data-restaurant-country` code, the page-reading and copy method that you used, and any change from the method above. The next brief will copy this part.
2. A count table for each category: your rows, the site banner, the Distinction filter, and the published count.
3. The results of the duplicate check, the two-category check and the country check.
4. The 2026 check, the 2027 check and the six named 2026 changes (scope rules 1 and 2).
5. The star list and Bib list article counts and closed entries (scope rule 3).
6. The 2025 versus 2026 comparison (scope rule 4), and the differences from 119 stars and 77 Bibs (scope rule 5).
7. Any cards that you excluded, with URLs.
8. The price and currency results.
9. The six venue-page spot checks.
10. The Pass 2 results.
11. The status and name register.
12. The hold register, with URLs.
13. The list of names that are not NFC.
14. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the `€` and accented letters.

## Stop

After the two files, write Ben a short summary: the row count per category, the difference from 119 stars and from 77 Bibs, the Bib count from the filter, the Pass 2 join count, the cards that you held out, and the answers for Demain, Spectrum, De Groene Lantaarn and De Juwelier. Then wait for Ben.
