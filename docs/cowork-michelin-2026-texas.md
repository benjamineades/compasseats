# Cowork brief: Michelin 2026 Texas

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Texas 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected (Recommended), Mindful Voices, Green Star or special awards. These go in the log only (see "Hold register").

Michelin revealed the Texas 2026 selection on October 8, 2026. The 2026 date is after June 1, 2026. So this guide uses the name "Mindful Voices", not "Green Star" (the same as Colorado and Southwest 2026).

Counts that Michelin published, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Texas 2026, Michelin star list article | 0 | 0 | 19 | not published | – |
| Texas 2025, Michelin star list article (reference only) | 0 | 0 | 18 | not published | – |
| CompassEats database, legacy rows labelled 2025, 9 Texas cities (reference only) | 0 | 0 | 16 | 47 | 63 |

The 2026 star list article names 19 One Star restaurants: Austin 7, Houston 5, San Antonio 3, Dallas 2, Fort Worth 1, Spring 1. The press release says that the full Texas selection holds 149 restaurants, with 6 new Bib Gourmands. Michelin did not publish a Bib total. Get it from the site's Distinction filter and write it in the log.

Sources (open them through the browser, because Michelin blocks plain fetchers):
- 2026 star list: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-texas-for-2026
- 2025 star list (reference): https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-texas-2025

Rules for scope:

1. Before you start, make sure that the site shows the **2026** selection. Open 3 venue pages (2 One Star, 1 Bib). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If a page still says 2025, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - One Star: **Goldee's** (Fort Worth; promoted from Bib Gourmand), **Fabrik** (Austin; promoted), **Kappo Kappo** (Austin; new in the guide).
   If one of them is not One Star, stop and tell Ben.
3. Compare the 2026 star list with the 2025 star list. List every 2025 star restaurant that is not in the 2026 list, and every 2026 star restaurant that is not in the 2025 list, with URLs. Write if the 2026 article marks any entry as closed.
4. Expect about 19 One Star rows plus the Bib rows. If your star count differs from 19, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
5. Every row must be in Texas. Every `source_url` path must start with `/us/en/texas/`. If a list shows a card from another state, do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-texas.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-texas` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path. |
| `venue_name` | exactly as the card prints it. Do not tidy it or cut it at a dash. Keep special characters (for example "Goldee's Bar-B•Q", "Nicōsi"). |
| `city_label` | the city that the card prints. Do not replace a town with the nearest big city (for example Spring stays Spring, Bellaire stays Bellaire). |
| `country_label` | `United States` |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `texas-2026` |

File rules: UTF-8. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last column is extra. The importer ignores it and reports it as ignored. That is correct. It stays in the file for the count check.

## Price and currency

1. Copy the price symbols exactly as printed. Expect `$`. Do not convert or normalize them.
2. Open 3 venue pages. Compare the card symbols with the venue page `priceRange` (JSON-LD).
3. In the log, write the count of rows for each distinct `price_symbol_raw` value.
4. If a row prints no price, or a symbol that is not `$`, keep it as printed and list it in the log.

## Pass 1: Texas lists (the method from Colorado and Germany, obey it exactly)

URL pattern: the Texas selection list for each distinction, then `/page/<N>` if there is more than one page. Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`.

Three traps:

1. **Find the real region slug.** Type "Texas" into the site's destination search box and click the plain Texas row under "Locations". Write the slug and the list URL in the log. For Colorado the slug was `colorado`. For the Southwest the slug was `area-united-states-usa-southwest`, and the slug `southwest` returned an empty-result page. A wrong slug can return the worldwide list with no error. So make sure that every card URL contains `/texas/`.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city = first `.card__menu-footer--score` line minus the state and country part (write the raw line for 3 cards in the log); price = second footer line before " · "; distinction = `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

**Do not use in-page `fetch()` plus `DOMParser`.** On Sep 28 it failed the proof test on the United Kingdom lists. Open every list page in the browser tab and read the rendered DOM.

Script limits:
- A browser call stops at 45 seconds, but the script keeps on in the page. Store results on `window.__x` and read them again later.
- Tool output stops at about 1,000 characters. Show the rows in the page in blocks of up to 100 lines, copy them, and check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.

Checks for every row and every category:

- Each card's `data-dtm-distinction` attribute must agree with the filter in the URL.
- For each category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 5 venue pages (2 Bib, 3 One Star; include Spring and one Bib outside the four big cities). Compare name, city, distinction and price with the card.

## Name and city register (log only)

The CompassEats database has questions on these venues. For each one, write the card name, category, city and URL, or write that no card exists.

- **Goldee's** (Fort Worth): the database name is "Goldee's Barbecue" (Bib Gourmand 2025).
- **Spring**: CorkScrew BBQ (One Star 2025), Belly of the Beast and Rosemeyer Bar-B-Q (Food Truck) (Bib Gourmand 2025).
- **Small towns with a 2025 Bib in the database**: Blood Bros. BBQ (Bellaire), Barbs B Q (Lockhart), Tejas Chocolate + Barbecue (Tomball).
- **Every card city** that is not Austin, Houston, Dallas, San Antonio or Fort Worth: list the city and its cards.

## Hold register (log only, no CSV rows)

- **Mindful Voices.** Write what the site and the articles show for Texas 2026 (names, venues, URLs). The 2025 edition had 4 Green Stars: Dai Due and Emmer & Rye (2024), Nixta Taqueria and Isidore (2025). Write if each one still shows a sustainability distinction in 2026.
- **Special awards.** Record each 2026 special award (award, person, venue, URL), and write if the venue is in today's star or Bib list.

## Output 2: `michelin-2026-texas-log.md`

Include these parts:

1. The method: the region slug and list URLs that you found, and any change from the method above.
2. A count table for each category: your rows, the site banner, the Distinction filter, and the published count.
3. The results of the duplicate check, the two-category check and the state check.
4. The 2026 check and the three named 2026 changes (scope rules 1 and 2).
5. The 2025 versus 2026 star list comparison (scope rule 3), and any difference from 19 (scope rule 4).
6. Any cards that you excluded, with URLs.
7. The price results.
8. The five venue-page spot checks.
9. The name and city register.
10. The hold register, with URLs.
11. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change special characters.

## Stop

After the two files, write Ben a short summary: the row count per category, the difference from 19 stars, the Bib count from the filter, the cards that you held out, and the answers for the name and city register. Then wait for Ben.
