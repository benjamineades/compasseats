# Cowork brief: Michelin 2026 American South

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide American South 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected (Recommended), Mindful Voices, Green Star or special awards. These go in the log only (see "Hold register").

The guide covers seven states. The site's territory selector names them "USA - Alabama (American South)", "USA - Georgia (American South)", "USA - Louisiana (American South)", "USA - Mississippi (American South)", "USA - North Carolina (American South)", "USA - South Carolina (American South)" and "USA - Tennessee (American South)". Source: https://guide.michelin.com/us/en/event/the-michelin-guide-heads-to-nashville-for-2026-american-south

Michelin revealed the American South 2026 selection on October 21, 2026, at The Pinnacle in Nashville, Tennessee. This is the second edition. The first edition (2025) was revealed in Greenville, South Carolina. The 2026 date is after June 1, 2026. So this guide uses the name "Mindful Voices", not "Green Star" (the same as Colorado, Southwest and Texas 2026).

Counts that Michelin published, and reference counts:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| American South 2026, Michelin press release | 0 | 1 | 21 | 59 (14 new) | 81 |
| American South 2025, Michelin star list article (reference only) | 0 | 1 | 18 | not in the article | – |
| CompassEats database, legacy rows labelled 2025, 18 cities in the 7 states (reference only) | 0 | 1 | 18 | 50 | 69 |

The press release gives 6 Mindful Voices and these totals for the whole selection: 266 restaurants, 185 Recommended (32 new). A second copy of the release (travelprnews.com) gives 265 and 184. The star and Bib counts agree in both copies. Get the true totals from the site's Distinction filter and write them in the log.

Sources (open them through the browser, because Michelin blocks plain fetchers):
- 2026 press release (Michelin): https://www.michelin.com/en/publications/products-and-services/new-michelin-starred-restaurants-shine-across-the-american-south
- 2025 star list (reference): https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-to-the-american-south
- 2026 star list article on guide.michelin.com: find it (look under https://guide.michelin.com/en/tags/MICHELIN%20Guide%20Ceremony or search the site for "American South 2026"). Write its URL in the log. If you cannot find it, write that, and use the press release.

The 2026 star list, as the press reports it (verify every name on guide.michelin.com):
- Two Stars: Emeril's (New Orleans, LA).
- One Star (21): Atlanta, GA: Atlas, Bacchanalia, Hayakawa, Lazy Betty, Mujō, O by Brush, Omakase Table, So. Fox (new). Gay, GA: Uberto Restaurant (new). Marietta, GA: Spring. New Orleans, LA: Saint-Germain, Zasu, Dakar NOLA (new). Charlotte, NC: Counter-. Charleston, SC: Malagón Mercado y Taperia, Vern's, Wild Common. Greenville, SC: Scoundrel. Nashville, TN: Bastion, Locust, The Catbird Seat.
- New Bib Gourmands (14): A Dopo (Knoxville, TN), Ajja (Raleigh, NC), Bao Toan Kitchen & Bar (Memphis, TN), Ideal's (Durham, NC), Maiz De La Vida (Nashville, TN), Miscellanea Spirit House (Oxford, MS), Okàn (Bluffton, SC), Palmira (Charleston, SC), Rivayat Creative Indian (Charleston, SC), Safta's Table (New Orleans, LA), Summerland (Atlanta, GA), Tesoro (Carrboro, NC), The Story of "Mi Cariño" (Charlotte, NC), Tipsy Thaiger (Roswell, GA).
- Press source for this list: https://www.finedininglovers.com/explore/articles/michelin-guide-american-south-2026 . This is not a Michelin source. Every row in the CSV must come from guide.michelin.com.

Rules for scope:

1. Before you start, make sure that the site shows the **2026** selection. Open 3 venue pages (2 One Star, 1 Bib). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If a page still says 2025, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - One Star: **So. Fox** (Atlanta, new), **Uberto Restaurant** (Gay, GA, new), **Dakar NOLA** (New Orleans, new).
   - Bib Gourmand: **Summerland** (Atlanta) and **Miscellanea Spirit House** (Oxford, MS).
   If one of them is not in that category, stop and tell Ben.
3. Compare the 2026 star list with the 2025 star list. List every 2025 star restaurant that is not in the 2026 list, and every 2026 star restaurant that is not in the 2025 list, with URLs. Write if the 2026 article marks any entry as closed.
4. Expect 1 Two Star row, 21 One Star rows and about 59 Bib rows. If your counts differ, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.
5. Every row must be in one of the seven states. Every `source_url` path must start with `/us/en/<state slug>/`, where the state slug is one of the seven state slugs that you found (write them in the log). If a list shows a card from another state (for example Florida, Texas or a Southwest state), do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-american-south.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,state_label
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-american-south` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Percent-encode any non-ASCII character in the path. |
| `venue_name` | exactly as the card prints it. Do not tidy it or cut it at a dash. Keep special characters (for example "Mujō", "Counter-", "Okàn", the quotation marks in The Story of "Mi Cariño"). |
| `city_label` | the city that the card prints. Do not replace a town with the nearest big city (for example Marietta stays Marietta, Gay stays Gay, Carrboro stays Carrboro). |
| `country_label` | `United States` |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `american-south-2026` |
| `state_label` | the two-letter state code from the card footer (for example `GA` from "Atlanta, GA, USA") |

File rules: UTF-8. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last two columns are extra. The importer ignores them and reports them as ignored. That is correct. `michelin_guide` stays in the file for the count check. `state_label` stays in the file because many US city names exist in more than one state (for example Greenville, Jackson, Columbia, Oxford, Franklin, Birmingham). CompassEats uses it to put each venue in the correct city.

## Price and currency

1. Copy the price symbols exactly as printed. Expect `$`. Do not convert or normalize them.
2. Open 3 venue pages. Compare the card symbols with the venue page `priceRange` (JSON-LD).
3. In the log, write the count of rows for each distinct `price_symbol_raw` value.
4. If a row prints no price, or a symbol that is not `$`, keep it as printed and list it in the log.

## Pass 1: American South lists (the method from Colorado, Germany and Texas, obey it exactly)

URL pattern: the selection list for each distinction, then `/page/<N>` if there is more than one page. Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`.

Three traps:

1. **Find the real list slugs.** Type "American South" into the site's destination search box. If a plain "American South" row shows under "Locations", click it and write the slug and the list URL in the log. Then type each of the seven state names and click the plain state row under "Locations". Write each state slug and list URL in the log. For Texas the slug was `texas`. For the Southwest the slug was `area-united-states-usa-southwest`, and the slug `southwest` returned an empty-result page. A wrong slug can return the worldwide or USA-wide list with no error. So make sure that every card URL contains one of the seven state slugs.
   - If a region list exists, capture from the region list. Then read the seven state banners for each category and check that the seven state counts add up to the region count.
   - If no region list exists, capture from the seven state lists, and add them together.
   - Either way, write the per-state count table in the log (state × category).
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`.

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; footer = first `.card__menu-footer--score` line (for Texas it was "Spring, TX, USA"); city = footer minus the last two parts (state and country); `state_label` = the second-last part of the footer; price = second footer line before " · "; distinction = `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space. Write the raw footer line for 3 cards in the log. Check in the page that every footer line ends with ", <two letters>, USA", and that the two letters are one of AL, GA, LA, MS, NC, SC, TN. List any card that fails.

**Do not use in-page `fetch()` plus `DOMParser`.** On Sep 28 it failed the proof test on the United Kingdom lists. Open every list page in the browser tab and read the rendered DOM.

Script limits:
- A browser call stops at 45 seconds, but the script keeps on in the page. Store results on `window.__x` and read them again later.
- Tool output stops at about 1,000 characters. Show the rows in the page in blocks of 12 rows or fewer (the Texas run found that 12 fits). Check each full block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.
- If the tab group resets, open a new tab and continue. Write it in the log.

Checks for every row and every category:

- Each card's `data-dtm-distinction` attribute must agree with the filter in the URL.
- For each category, the row count must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open 6 venue pages: Emeril's (Two Stars), Uberto Restaurant (Gay), 1 more One Star, and 3 Bibs (one in Alabama, one in Mississippi, one outside the big cities). Compare name, city, state, distinction and price with the card.

## Name and city register (log only)

The CompassEats database has questions on these venues. For each one, write the card name, category, city, state and URL, or write that no card exists.

- **Counter-** (Charlotte): the database name is "Counter-". Write the exact card name.
- **Malagón** (Charleston): the database name is "Malagón". The press uses "Malagón Mercado y Taperia".
- **Rodney Scott's BBQ** (Charleston): the database marks this venue as closed, with a 2025 Bib Gourmand. Is there a 2026 card? What does the venue page say?
- **Spring** (Marietta, GA): the 2025 star list noted "temporarily closed". What does the 2026 card or venue page say?
- **Elvie's** and **Sacred Ground Barbecue**: the database puts them in a city "Jackson" (2025 Bib Gourmand). Write the card city and state for each.
- **Birmingham, Alabama**: the database has Bayonet, La Fête, OvenBird and Pizza Grace (2025 Bib Gourmand). Write the card city text exactly.
- **Georgia Bib changes reported by the press** (verify on the site): Superica and Table & Main (Roswell) moved to Recommended; Masterpiece (Duluth) left the guide. Write the 2026 card category or "no card".
- **Name differences to record:** "mother bakery & cafe | south slope" (Asheville), "Bomb Biscuit Atlanta", "The Busy Bee" (Atlanta), "Lewis Barbecue Charleston", "Cochon Restaurant" (New Orleans). Write the card name for each.
- **Every card city** that is not Atlanta, New Orleans, Nashville, Charleston or Charlotte: list the city, state and its cards.

## Hold register (log only, no CSV rows)

- **Mindful Voices.** The press release gives 6 for 2026. Write what the site and the articles show (names, venues, cities, URLs). The 2025 edition had 5 Green Stars: Bacchanalia (Atlanta), Counter- (Charlotte), January (Franklin, TN), Luminosa (Asheville) and The Chastain (Atlanta). Write if each one still shows a sustainability distinction in 2026.
- **Special awards.** The press release names four: Exceptional Cocktails, Ally Bowen, Miscellanea Spirit House; Sommelier, William Mellon, manna; Outstanding Service, Jared Patterson, Little Betty Steak Bar; Young Chef / Culinary Professional, Héctor González-Mora, The Story of "Mi Cariño". For each, write the award, person, venue, city, state, URL, and if the venue is in today's star or Bib list.

## Output 2: `michelin-2026-american-south-log.md`

Include these parts:

1. The method: the region slug and the seven state slugs that you found, the list URLs, and any change from the method above.
2. A count table for each category: your rows, the site banner, the Distinction filter, and the published count. Then the per-state count table (state × category).
3. The results of the duplicate check, the two-category check, the footer check and the state check.
4. The 2026 check and the five named 2026 changes (scope rules 1 and 2).
5. The 2025 versus 2026 star list comparison (scope rule 3), and any difference from 1 / 21 / 59 (scope rule 4).
6. Any cards that you excluded, with URLs.
7. The price results.
8. The six venue-page spot checks.
9. The name and city register.
10. The hold register, with URLs.
11. The full Distinction filter text, with the Selected count and the total (266 or 265).
12. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change special characters.

## Stop

After the two files, write Ben a short summary: the row count per category and per state, the difference from 1 / 21 / 59, the cards that you held out, and the answers for the name and city register. Then wait for Ben.
