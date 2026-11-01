# Cowork brief: Michelin 2026 Hong Kong & Macau

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Hong Kong & Macau 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star or special awards. These go in the log only (see "Hold register").

Hong Kong and Macau are two selections on the site, in one guide. Read both. This is the 18th edition. Michelin revealed the 2026 Bib Gourmand list on March 12, 2026, and the full 2026 selection on March 19, 2026 (ceremony at Grand Lisboa Palace Resort Macau).

Michelin adds cards during the year. Read the live site and report what it shows on the day of your run.

Counts that Michelin published, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Hong Kong 2026, Michelin articles | 7 | 13 | 57 | 70 | 147 |
| Macau 2026, Michelin articles | 2 | 6 | 13 | 13 | 34 |
| Hong Kong 2025, Michelin article (reference only) | 7 | 11 | 58 | not stated | - |
| Macau 2025, Michelin article (reference only) | 2 | 6 | 11 | not stated | - |
| CompassEats database, Hong Kong legacy rows labelled 2025 (reference only) | 7 | 13 | 56 | 69 | 145 |
| CompassEats database, Macau legacy rows labelled 2025 (reference only) | 2 | 6 | 13 | 13 | 34 |

The full list article also gives Selected: Hong Kong 72, Macau 25 (219 + 59 = 278 restaurants in all). Do not make rows for them.

Get the count for each category from the site's Distinction filter too, for each selection, and write both numbers in the log.

Sources (open them through the browser, because Michelin blocks plain fetchers on list pages):
- Ceremony results 2026: https://guide.michelin.com/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2026
- Full list 2026: https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list
- Bib Gourmand article 2026 (names only the 8 new Bibs): https://guide.michelin.com/tw/en/article/michelin-guide-ceremony/michelin-guide-hong-kong-macau-bib-gourmand-selection-2026
- Ceremony results 2025 (reference): https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-and-macau-full-selection-release-2025

NOTE: Michelin replaced the 2025 full list with the 2026 full list at the same URL (also at `/mo/en/article/michelin-guide-ceremony/hong-kong-macau-full-list`). The live page now shows 2026.

NOTE: The Bib article links the Bib lists as `guide.michelin.com/hk/en/restaurants/bib-gourmand` (Hong Kong) and `guide.michelin.com/mo/en/selection/macao/restaurants/bib-gourmand` (Macau). These links show two different URL forms. Do not trust either form. Find the slugs with the search box (Pass 1, trap 1).

Rules for scope:

1. Before you start, make sure that the site shows the **2026** selection. Open 4 venue pages (1 Two Stars and 1 Bib in each selection). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded` if the page has it. Write the exact phrases in the log. If a page still says 2025, stop and tell Ben. If any page or list shows a **2027** selection, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Two Stars: **Cristal Room by Anne-Sophie Pic** (Hong Kong, promoted) and **L'Atelier De Joël Robuchon** (Hong Kong, returned after refurbishment).
   - One Star: **China Tang** and **Sushi Takeshi** (Hong Kong, new); **Don Alfonso 1890** and **Palace Garden** (Macau, promoted from Selected).
   - Bib Gourmand: **Dragons' Den**, **Fiata**, **Ho Ho Chak**, **Lai's Kitchen**, **Siaw**, **Uncle Quek** (Hong Kong); **A Lorcha**, **Nok Song** (Macau).
   - Three Stars (no change): Hong Kong 8 1/2 Otto e Mezzo - Bombana, Amber, Caprice, Forum, Sushi Shikon, Ta Vie, T'ang Court; Macau Jade Dragon, Robuchon au Dôme.
   If one of them is not in the category above, stop and tell Ben.
3. Count the entries in the 2026 full list article for each star and Bib category, per selection. Write the counts in the log. A fetch on Nov 1 showed that the Macau One Star heading says 13 but names only 11: Don Alfonso 1890, Five Foot Road, Lai Heen, Mizumi, Palace Garden, Pearl Dragon, Sushi Kinetsu, Sushi Kissho by Miyakawa, Ying, Zi Yat Heen, Zuicho. Find the 2 Macau One Star cards that the article does not name, and write them with URLs. (The Macau card of 8 1/2 Otto e Mezzo - Bombana says One Star 2026. Check if it is one of the 2.) List every entry that an article marks as closed.
4. Compare 2026 with 2025 for the star categories. For 2025, use the 2025 ceremony article. Also look for a web.archive.org capture of `https://guide.michelin.com/hk/en/article/michelin-guide-ceremony/hong-kong-macau-full-list` dated between March 13, 2025 and March 18, 2026 whose title says 2025. If you find one, use it as the 2025 star and Bib list and write the capture URL. If you find none, write that and go on. List every 2025 star entry that is not in the 2026 lists, and every 2026 star entry that is not in the 2025 lists, with the category in each year. If the capture has a 2025 Bib list, do the same for the Bibs.
5. Expect about 181 rows (147 + 34). If a total differs from the published counts, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
6. Every row must be in Hong Kong or Macau. If a list shows a card from another place (for example mainland China or Taiwan), do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-hong-kong-macau.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,venue_name_zh,city_label_zh
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-hong-kong-macau` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path (the Hong Kong 8½ card path holds `%C2%BD`). |
| `venue_name` | exactly as the English card prints it. Do not tidy it or cut it at a dash (for example "8 1/2 Otto e Mezzo - Bombana" stays as printed). Keep accents and special characters (for example "L'Atelier De Joël Robuchon", "Robuchon au Dôme"). |
| `city_label` | the city that the English card prints (see "City and country rules"). |
| `country_label` | `Hong Kong` or `Macao`, mapped from the card's `data-restaurant-country` attribute. Use `Macao` (with o), because the CompassEats database writes the country that way. |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `hong-kong-macau-2026` |
| `venue_name_zh` | the name on the Traditional Chinese card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `city_label_zh` | the city on the Traditional Chinese card (Pass 2). Blank only if Pass 2 has no card for this URL. |

File rules: UTF-8, no BOM, LF line ends. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last three columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for the count check and for the name and city match test.

## City and country rules

- The URL territory part (`/hk/`, `/mo/`, `/us/`) does **not** decide the country. Use the card's `data-restaurant-country` attribute. Write the codes that you see for Hong Kong and Macau, and map them with code.
- The card footer can print a district (for example "Central"), the city, or "Hong Kong SAR" / "Macau SAR". Write the raw footer line for 5 cards in each selection in the log (include one Kowloon card and one Cotai or Taipa card if the lists have them). Then use the city part of the footer as `city_label`. Do not replace a district with the city, and do not replace the city with a district. Ben decides the city policy later with your log.
- Every card in the CSV must carry the Hong Kong code or the Macau code. A card with another code goes to the log only.

## Price and currency

1. Copy the price symbols exactly as printed. Do not guess the currency sign. Do not convert or normalize the symbols.
2. Open 4 venue pages (2 per selection). Compare the card symbols with the printed "Price" line on the venue page. Do not use JSON-LD `priceRange`. Make sure that the symbols are identical on the `/us/en/` page and on the Chinese page.
3. In the log, write the count of rows for each distinct `price_symbol_raw` value, per selection.
4. If a row prints no price, keep it blank and list it in the log.

## Pass 1: English lists (the method from Germany, Belgium, the Netherlands and Taiwan, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<selection-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs on `/us/en/`: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`. `/page/1` redirects to the URL without `/page/1`.

Three traps:

1. **The selection part must be `selection/<selection-slug>`.** A wrong slug returns the worldwide list with no error, and it puts your word in the page title. Type "Hong Kong" into the site's destination search box and click the plain row under "Locations". Do the same with "Macau". Use the slugs that the search box gives (the Bib article suggests `macao` for Macau, but check it). Then make sure that each card's `data-restaurant-country` attribute shows the right code. Make your scripts stop if the page path does not contain `selection/<selection-slug>`.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city = first `.card__menu-footer--score` line (write the raw line, see "City and country rules"); price = second footer line before " · "; country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

**Do not use in-page `fetch()` plus `DOMParser` for the list pages.** It failed the proof test on the United Kingdom lists. Open every list page in the browser tab and read the rendered DOM.

Storage and copy (the method that worked for Belgium, the Netherlands and Taiwan):

- Each list page is a new page load, so `window.__x` is lost. Store results in the browser `localStorage` of guide.michelin.com under keys that start with `__hkmo26_`. Remove your `__hkmo26_` keys at the end. Do not read, change or delete any other key (for example `__cx`, `__tw26_`, `__bl26_` or `__nl26_` keys from earlier sessions).
- Store one extraction function as a string under `__hkmo26_fn` and run it with `eval` on each list page. Store a second one under `__hkmo26_vfn` for venue pages (title, meta description, JSON-LD `award`, badge images, data-sheet blocks).
- A browser call stops at 45 seconds, but the script keeps on in the page. Read the stored results again later.
- Tool output stops at about 1,000 characters. Tool output that contains `&` or `=` pairs can come back as "[BLOCKED: Cookie/query string data]". Show the rows in the page as plain text (`<pre>`) in blocks of up to 100 lines, with ` | ` as the field separator. Escape `\` as `\\` and `|` as `\|` in the blocks, and reverse this in the build script. Read each block with the page-text tool. Check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.
- Copy the exact code points. If a block hash fails, find the cause and fix it with code. Do not normalize names. List every name that is not NFC in the log.
- The browser tab group can close during a run. `localStorage` on guide.michelin.com survives. Open a new tab and check the block hashes again before you go on.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each category and selection, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages (in each selection: 1 Bib, 1 One Star, 1 Two Stars). Compare name, city, distinction and price with the card.

## Pass 2: Traditional Chinese lists (names and cities)

The CompassEats database holds 12 legacy Hong Kong and Macau Michelin venues with Chinese or Japanese characters in the name (listed in the register below). Pass 2 gives the match test a second name for every card.

1. Find the Chinese selection slugs with the destination search box on `https://guide.michelin.com/hk/zh_HK/` (type "香港", then "澳門"). Click the plain row under the locations heading.
2. **Do not assume the distinction slugs.** Read the four distinction slugs from the Distinction filter checkbox values on the Chinese selection page. Write them in the log.
3. Read the four distinction lists for each selection with the same rules as Pass 1.
4. Join each Chinese card to its Pass 1 row on the part of the URL after `/restaurant/`. Fill `venue_name_zh` and `city_label_zh`.
5. Copy the exact code points of the Chinese names, full-width punctuation included. Do not convert full-width characters to half-width.
6. In the log, write: the row count per category and selection for Pass 2, the number of joined rows, every row that did not join (with both URLs if any), every row where the Chinese category differs from the English category, the count of rows where the Chinese name is the same as the English name (with the list), and every Chinese city label with its row count.

## Status and name register (log only)

The CompassEats database has questions on these venues. For each one, write whether a card exists in your lists (exact English card name, exact Chinese card name, category, selection, city, URL). If no card exists, open the Michelin venue page if it is still online, and write what it says (for example "Restaurant not found").

- **8 1/2 Otto e Mezzo - Bombana:** two cards, Hong Kong (Three Stars expected) and Macau (One Star expected). Write both.
- **Lai Heen (Hong Kong):** the database has a Hong Kong venue "Lai Heen" with a Two Stars row. The 2026 full list names "Lai Heen" in Macau only (One Star), and "Lai Ching Heen" in Hong Kong (Two Stars). Write the card for Lai Ching Heen and for Lai Heen. Write whether any Hong Kong card is named "Lai Heen".
- **Names that differ from the database.** Write the exact English and Chinese card names for each: Tin Lung Heen (database "Tin Lung Heen | The Ritz-Carlton, Hong Kong"), L'Atelier De Joël Robuchon (database Two Stars venue "Joël Robuchon"), Forum (database "富臨飯店 Forum Restaurant"), The Huaiyang Garden (database "The Huai Yang Garden"; the ceremony article writes "The Huaiyang Garden"), Octavium (database "Octavium Italian Restaurant"), Spring Moon (database "Spring Moon 嘉麟樓"), Sushi Takeshi (database "Sushi Takeshi 鮨たけし"), Sushi Wadatsumi (database "鮨わだつみ Sushi Wadatsumi (K11 MUSEA)"), Art & Taste (database "Art & Taste (美食台灣餐廳)"), lulu BAOBAO (database "lulu BAOBAO 手工拉麵小籠包 [ Wong Chuk Hang ]"), Ju Xing Home (database "聚興家 Ju Xing Home"), Ship Kee (database "船記 Ship Kee"), Ho Ho Chak (database "賀賀澤-潮州海鮮小炒 Ho Ho Chak Chiu Chow Restaurant"), Feng Wei Ju (database "FENG WEI JU 風味居"), Aji (database "Aji 雅吉"), Justindia (database "JUSTINDIA 印象派").
- **Same name in both selections.** Zuicho (database: Hong Kong venue closed, Macau venue active). Mesa (database: 2 Macau venues). Write every card with this name, its selection and category (Mesa can be Selected: write it from the venue page if it is not in your four lists).
- **Duddell's (Hong Kong):** the database already holds a 2026 One Star row with URL `https://guide.michelin.com/us/en/hong-kong-region/hong-kong/restaurant/duddell-s`. Write the card category and URL in your lists.
- **New stars:** write the card name and city exactly for the 2 new Two Stars and the 4 new One Stars named in scope rule 2.

## Hold register (log only, no CSV rows)

- **Green Star.** The 2026 ceremony article names 5: Amber, Feuille, Mora, Roganic (Hong Kong); UTM Educational Restaurant (Macau). Write whether the 2026 site shows a Green Star filter, list or mark for each selection. Do not guess a URL. Do not make rows.
- **Special awards.** Record each 2026 special award (award, person, venue, URL), and write if the venue is in today's star or Bib list. The ceremony article names: Young Chef Award (Kim GwanJu, Sol); Service Award (Jenny Ye, The Huaiyang Garden); Sommelier Award (Floriane Hureau, Caprice); MICHELIN Guide Mentor Chef Award, new to Hong Kong and Macau (Lau Ping Lui, Paul, Tin Lung Heen).

## Output 2: `michelin-2026-hong-kong-macau-log.md`

Include these parts:

1. The method: the English and Chinese selection slugs, the Chinese distinction slugs, the `data-restaurant-country` codes, the page-reading and copy method that you used, and any change from the method above. The next brief will copy this part.
2. A count table for each category and selection: your rows, the site banner, the Distinction filter, and the published count. Add a table by city label and category.
3. The results of the duplicate check, the two-category check and the country check.
4. The 2026 check, the 2027 check and the named 2026 changes (scope rules 1 and 2).
5. The full list article counts, the 2 Macau One Star cards it does not name, and closed entries (scope rule 3).
6. The 2025 versus 2026 comparison (scope rule 4), and the differences from the published counts (scope rule 5).
7. Any cards that you excluded, with URLs.
8. The price and currency results.
9. The six venue-page spot checks.
10. The Pass 2 results.
11. The raw footer lines (city and country rules).
12. The status and name register.
13. The hold register, with URLs.
14. The list of names that are not NFC (both languages).
15. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the Chinese characters, the price symbols and the accented letters.
