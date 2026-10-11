# Cowork brief: Michelin 2026 Taiwan

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Taiwan 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star, Mindful Voices or special awards. These go in the log only (see "Hold register").

Michelin revealed the Taiwan 2026 Bib Gourmand list on July 14, 2026, and the full 2026 selection on July 21, 2026. This is the ninth Taiwan edition. The 2026 articles still use the name "Green Star". Write what the site shows. Do not make rows for it.

Michelin adds cards during the year (the site has "New Additions" articles). Read the live site and report what it shows on the day of your run.

Counts that Michelin published, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Taiwan 2026, Michelin articles (ceremony article, Bib article) | 3 | 9 | 49 | 146 | 207 |
| Taiwan 2025, Michelin articles (reference only) | 3 | 7 | 43 | 144 | 197 |
| CompassEats database, legacy rows labelled 2025 (reference only) | 3 | 6 | 29 | 137 | 175 |

Taiwan 2026 by city, from the Michelin articles. "All" is the city total for every category, Selected included (434 in all = 61 stars + 146 Bib + 227 Selected).

| City | 3 Stars | 2 Stars | 1 Star | Bib | All |
|---|---|---|---|---|---|
| Taipei | 2 | 9 | 36 | 37 | 156 |
| Taichung | 1 | 0 | 5 | 23 | 63 |
| Tainan | 0 | 0 | 1 | 30 | 61 |
| Kaohsiung | 0 | 0 | 6 | 21 | 56 |
| New Taipei City | 0 | 0 | 0 | 18 | 44 |
| Hsinchu County | 0 | 0 | 1 | 10 | 27 |
| Hsinchu City | 0 | 0 | 0 | 7 | 27 |

Get the count for each category from the site's Distinction filter too, and write both numbers in the log.

Sources (open them through the browser, because Michelin blocks plain fetchers on list pages):
- Ceremony results 2026: https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-stars-taiwan-2026
- Full list 2026 (stars and Selected, no Bibs): https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list
- Bib Gourmand article 2026 (names only the 13 new Bibs): https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-2026-bib-gourmand-list
- Ceremony results 2025 (reference): https://guide.michelin.com/mo/en/article/michelin-guide-ceremony/michelin-guide-taiwan-starred-restaurant-2025
- Bib Gourmand article 2025 (reference, names only the 37 new Bibs): https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-guide-taiwan-2025-bib-gourmand-selection

NOTE: Michelin replaced the 2025 full list with the 2026 full list at the same URL. The live page now shows 2026.

Rules for scope:

1. Before you start, make sure that the site shows the **2026** selection. Open 3 venue pages (1 Two Stars, 1 One Star, 1 Bib). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If a page still says 2025, stop and tell Ben. If any page or list shows a **2027** selection, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Two Stars: **Mizue** (Taipei, new) and **NOBUO** (Taipei, promoted).
   - One Star: **Yu Dao** (Tainan), **Sushi An** (Hsinchu County) and **Hābu** (Kaohsiung).
   - Bib Gourmand: **BAA Wanli Goat** (Tainan) and **Monsoon** (Hsinchu County).
   If one of them is not in the category above, stop and tell Ben.
3. Count the entries in the 2026 full list article for each star category. Write the counts in the log. A plain fetch showed 3 / 9 / 47 One Star names (Taipei 35, Taichung 5, Tainan 1, Kaohsiung 6) and no Hsinchu County heading. The ceremony article says 49 One Stars (Taipei 36, Hsinchu County 1). Find the One Star cards that the full list article does not name, and write them with URLs. List every entry that an article marks as closed.
4. Compare 2026 with 2025 for the star categories. For 2025, use the 2025 ceremony article (it names the 7 Two Stars and the 8 new One Stars). Also look for a web.archive.org capture of `https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/taiwan-full-list` dated between August 19, 2025 and July 13, 2026 whose title says 2025. If you find one, use it as the 2025 star list and write the capture URL. If you find none, write that and go on. List every 2025 star entry that is not in the 2026 lists, and every 2026 star entry that is not in the 2025 lists, with the category in each year. Do not rebuild the 2025 Bib list. Ben's database check covers the Bibs.
5. Expect about 207 rows. If your star total differs from 61, or your Bib total differs from 146, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
6. Every row must be in Taiwan. If a list shows a card from another country or territory, do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-taiwan.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,venue_name_zh,city_label_zh
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-taiwan` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path. |
| `venue_name` | exactly as the English card prints it. Do not tidy it or cut it at a dash. Keep accents, macrons, dots, hyphens and special characters (for example "A", "Circum-", "Sur-", "Taïrroir", "Hābu"). A one-letter name is correct. |
| `city_label` | the city that the English card prints. Do not replace New Taipei City with Taipei. Do not merge Hsinchu City and Hsinchu County. |
| `country_label` | `Taiwan`, mapped from the card's `data-restaurant-country` attribute |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `taiwan-2026` |
| `venue_name_zh` | the name on the Traditional Chinese card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `city_label_zh` | the city on the Traditional Chinese card (Pass 2). Blank only if Pass 2 has no card for this URL. |

File rules: UTF-8, no BOM, LF line ends. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last three columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for the count check and for the name and city match test.

## Country rules

- The URL territory part (`/tw/`, `/us/`) does **not** decide the country. Use the card's `data-restaurant-country` attribute. It holds a code. In the Netherlands it was `nl`. Write the code that you see for Taiwan, and map it to `Taiwan` with code.
- The site menu names this selection "Taiwan Region". The card footer can print a different word. Write the raw footer line for 3 cards in the log. The CSV value stays `Taiwan`.
- Every card in the CSV must carry the Taiwan code. A card with another code goes to the log only.

## Price and currency

1. Copy the price symbols exactly as printed. Do not guess the currency sign. Do not convert or normalize the symbols.
2. Open 3 venue pages. Compare the card symbols with the printed "Price" line on the venue page. Do not use JSON-LD `priceRange`: in the Netherlands it held a word label, not symbols. Make sure that the symbols are identical on the `/us/en/` page and on the Chinese page.
3. In the log, write the count of rows for each distinct `price_symbol_raw` value.
4. If a row prints no price, keep it blank and list it in the log.

## Pass 1: English lists (the method from Germany, Belgium and the Netherlands, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<country-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs on `/us/en/`: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`. `/page/1` redirects to the URL without `/page/1`.

Three traps:

1. **The country part must be `selection/<country-slug>`.** A wrong slug returns the worldwide list with no error, and it puts your country word in the page title. The 2026 full list article links to `selection/taiwan` on `/tw/en/`. Still, type "Taiwan" into the site's destination search box and click the plain country row under "Locations". Use the slug that the search box gives. Then make sure that each card's `data-restaurant-country` attribute shows the Taiwan code. Make your scripts stop if the page path does not contain `selection/<country-slug>`.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city = first `.card__menu-footer--score` line minus the country part (write the raw line for 3 cards in each of the 7 cities in the log); price = second footer line before " · "; country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

**Do not use in-page `fetch()` plus `DOMParser` for the list pages.** On Sep 28 it failed the proof test on the United Kingdom lists. Open every list page in the browser tab and read the rendered DOM.

Storage and copy (the method that worked for Belgium and the Netherlands):

- Each list page is a new page load, so `window.__x` is lost. Store results in the browser `localStorage` of guide.michelin.com under keys that start with `__tw26_`. Remove your `__tw26_` keys at the end. Do not read, change or delete any other key (for example `__cx`, `__bl26_` or `__nl26_` keys from earlier sessions).
- Store one extraction function as a string under `__tw26_fn` and run it with `eval` on each list page. Store a second one under `__tw26_vfn` for venue pages (title, meta description, JSON-LD `award`, badge images, data-sheet blocks).
- A browser call stops at 45 seconds, but the script keeps on in the page. Read the stored results again later.
- Tool output stops at about 1,000 characters. Tool output that contains `&` or `=` pairs can come back as "[BLOCKED: Cookie/query string data]". Show the rows in the page as plain text (`<pre>`) in blocks of up to 100 lines, with ` | ` as the field separator. Escape `\` as `\\` and `|` as `\|` in the blocks, and reverse this in the build script. Read each block with the page-text tool. Check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.
- Copy the exact code points. In Belgium, one name wrote ü as two code points (u + U+0308), and the block hash caught a copy that used one code point. If a block hash fails, find the cause and fix it with code. Do not normalize names. List every name that is not NFC in the log.
- The browser tab group can close during a run. `localStorage` on guide.michelin.com survives. Open a new tab and check the block hashes again before you go on.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages (2 Bib, 2 One Star, 1 Two Stars, 1 Three Stars; include one card in New Taipei City and one in Hsinchu County). Compare name, city, distinction and price with the card.

## Pass 2: Traditional Chinese lists (names and cities)

The CompassEats database holds 48 legacy Taiwan Michelin venues with Chinese characters in the name (for example "明福台菜" and "牡丹．極上 天ぷら．本店"). Pass 2 gives the match test a second name for every card.

1. Find the Chinese country slug with the destination search box on `https://guide.michelin.com/tw/zh_TW/` (type "台灣"). Click the plain country row under the locations heading.
2. **Do not assume the distinction slugs.** On the French Belgian site, the English star slugs redirected to the worldwide list with no error. Read the four distinction slugs from the Distinction filter checkbox values on the Chinese country page. Write them in the log.
3. Read the four distinction lists with the same rules as Pass 1.
4. Join each Chinese card to its Pass 1 row on the part of the URL after `/restaurant/`. Fill `venue_name_zh` and `city_label_zh`.
5. Copy the exact code points of the Chinese names, full-width punctuation included (for example "．" U+FF0E and "（" U+FF08). Do not convert full-width characters to half-width.
6. In the log, write: the row count per category for Pass 2, the number of joined rows, every row that did not join (with both URLs if any), every row where the Chinese category differs from the English category, the count of rows where the Chinese name is the same as the English name (with the list), and every Chinese city label with its row count.

## Status and name register (log only)

The CompassEats database has questions on these venues. For each one, write whether a card exists in your lists (exact English card name, exact Chinese card name, category, city, URL). If no card exists, open the Michelin venue page if it is still online, and write what it says (for example "Restaurant not found").

- **Closed in the database:** JL STUDIO (Taichung), with a Three Stars 2025 row. The 2026 articles list it at Three Stars. Write the card category and any closure or move note on the venue page. Also "麥謎食驗室 Bue mi .Lab" (Tainan), closed, with a Bib 2025 row.
- **Fleur de Sel (Taichung):** One Star 2025 row in the database. The 2026 full list names it under Selected. Write the card category.
- **A (Taipei):** the database venue for this Two Stars card is named "Taipei". Write the exact card name in both languages and the URL.
- **Names that differ from the database.** Write the exact English and Chinese card names for each: Eika (database "EIKA 盈科"), Yu Kapo (database "Yu Kappo"), Mudan (database "牡丹．極上 天ぷら．本店"), Motoichi (database "元一 天婦羅"), Ming Fu (database "明福台菜"), Ken Anhe (database "謙安和 Ken Anho"), Sho (database "承 Sho"), the FRONT HOUSE (database "方蒔 the FRONT HOUSE"), Sur- (database "澀 Sur-"), Wok by O'BOND (database "WOK by obond"), Silks House (the ceremony article heading says "Silk House"; the URL says `silks-house`).
- **No venue in the database:** Molino de Urdániz (Taipei, Two Stars in the 2025 and 2026 articles), aMaze and Sushi Kajin (Taipei, new One Stars in 2025). Write the 2026 card category and URL.
- **New Taipei City:** the database has no city row for New Taipei City. Write the number of cards per category whose English card city is New Taipei City, and the Chinese city label for them.
- **New stars:** write the card name and city exactly for the 2 new Two Stars (Mizue, NOBUO) and the 9 new One Stars (Kiku, Mume, Silks House, SHINEYU, Nibbon, Sushi An, Hābu, Restaurant 12, Yu Dao).

## Hold register (log only, no CSV rows)

- **Green Star.** The 2026 ceremony article names 9: EMBERS, Hosu, Little Tree Food (Da'an Road), Mountain and Sea House, Yangming Spring (Shilin) (all Taipei); Sur- (new) and Tu Pang (Taichung); Yu Dao (new, Tainan); Thomas Chien (Kaohsiung). Write whether the 2026 site shows a Green Star filter, list or mark, or a "Mindful Voices" block, for Taiwan. Do not guess a URL. Do not make rows.
- **Special awards.** Record each 2026 special award (award, person, venue, URL), and write if the venue is in today's star or Bib list. The ceremony article names: Service Award (Cindy Tsai, Circum-, Taipei); Sommelier Award (Bonnie Chiou, Li.nu, Kaohsiung); Young Chef Award (Liu An Hsu, Sushi An, Hsinchu County); Opening of the Year Award (Yu Dao, Tainan).

## Output 2: `michelin-2026-taiwan-log.md`

Include these parts:

1. The method: the English and Chinese country slugs, the Chinese distinction slugs, the `data-restaurant-country` code, the page-reading and copy method that you used, and any change from the method above. The next brief will copy this part.
2. A count table for each category: your rows, the site banner, the Distinction filter, and the published count. Add a table by city and category.
3. The results of the duplicate check, the two-category check and the country check.
4. The 2026 check, the 2027 check and the seven named 2026 changes (scope rules 1 and 2).
5. The full list article counts, the One Star cards it does not name, and closed entries (scope rule 3).
6. The 2025 versus 2026 star comparison (scope rule 4), and the differences from 61 stars and 146 Bibs (scope rule 5).
7. Any cards that you excluded, with URLs.
8. The price and currency results.
9. The six venue-page spot checks.
10. The Pass 2 results.
11. The status and name register.
12. The hold register, with URLs.
13. The list of names that are not NFC (both languages).
14. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the Chinese characters, the price symbols and the accented letters.

## Stop

After the two files, write Ben a short summary: the row count per category, the difference from 61 stars and from 146 Bibs, the Bib count from the filter, the Pass 2 join count, the cards that you held out, the number of New Taipei City cards, and the answers for JL STUDIO, Bue mi .Lab, Fleur de Sel and A. Then wait for Ben.
