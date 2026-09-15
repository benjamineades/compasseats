# Cowork brief: Michelin 2026 Japan (batch 3 of the Michelin 2026 work)

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide 2026 selection for Japan from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star, or special awards. Green Star and special awards go in the log only (see "Hold register").

Japan has three live 2026 guides. Michelin published these counts at each ceremony:

| Guide | Ceremony | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|---|
| Tokyo 2026 | Sep 25, 2025 | 12 | 26 | 122 | 114 | 274 |
| Kyoto Osaka 2026 | Apr 23, 2026 | 9 | 31 | 139 | 106 | 285 |
| Nara 2026 | May 13, 2026 | 0 | 4 | 18 | 11 | 33 |
| **Japan total** | | **21** | **61** | **279** | **231** | **592** |

Kyoto Osaka split: Kyoto 6 / 19 / 73 / 47. Osaka 3 / 12 / 66 / 59.

Sources (open them through the browser, because Michelin blocks plain fetchers):
- Tokyo: https://guide.michelin.com/jp/en/article/michelin-guide-ceremony/michelin-guide-tokyo-2026-stars-reveal
- Kyoto Osaka: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-kyoto-osaka-2026-stars-reveal
- Nara: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/michelin-guide-nara-2026-restaurants
- 2027 date: https://guide.michelin.com/us/en/article/news-and-views/michelin-guide-ceremony-tokyo-kyoto-osaka-nara-2027-selection-save-the-date

Rules for scope:

1. Michelin will show the 2027 selections for all three guides on Feb 16, 2027. Before you start, make sure that the site still shows the 2026 selection. If the site shows any 2027 selection for Japan, stop and tell Ben.
2. Expect about 592 rows. The live site is months newer than the ceremonies, so a small decrease is normal (France was +9.3% against its estimate, Italy +3.6%). If your total is more than 10% away from 592, explain the difference in the log before you deliver.
3. For reference only: the CompassEats database holds 579 Japan rows for Michelin 2025 (Three Stars 22, Two Stars 60, One Star 273, Bib Gourmand 224).
4. Every row must be in Tokyo, Kyoto Prefecture, Osaka Prefecture, or Nara Prefecture. If the Japan list shows a card from another area (for example an older regional guide), do not put it in the CSV. List it in the log with its URL.

## Output 1: `michelin-2026-japan.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,name_native_michelin
```

One row per venue. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-japan` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form that the card links to. Required on every row. No two rows can have the same URL. |
| `venue_name` | exactly as the English card prints it. Do not tidy it, translate it, or cut it at a dash. |
| `city_label` | the city that the card prints. Do not replace a town with the nearest big city. |
| `country_label` | `Japan` |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the card prints them |
| `note` | blank |
| `michelin_guide` | `tokyo-2026`, `kyoto-osaka-2026`, or `nara-2026`, from the venue location. If the location is not clear from the card, open the venue page. |
| `name_native_michelin` | the name from Michelin's Japanese-language site (Pass 2). Leave it blank if Pass 2 gives no sure match. |

File rules: UTF-8. Put quotation marks around any field that contains a comma. Never type rows by hand. Build the file with code from the extracted data.

The last two columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for later work.

**Why `name_native_michelin` is important:** the database holds 27 Japanese venues with a name only in Japanese script. The importer cannot match those names to English names. Without the Japanese name, those venues come in as new venues, and the site gets duplicates.

## Pass 1: English lists (the method from Italy, obey it exactly)

URL pattern:

```
https://guide.michelin.com/us/en/selection/<country-slug>/restaurants/<distinction-slug>/page/<N>
```

Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. Get the page links from the DOM: collect `a[href*="/page/"]`.

Three traps:

1. **The country part must be `selection/<country-slug>`.** A URL like `/us/en/jp/restaurants/...` returns the worldwide list with no error, and it puts your country word in the page title. To find the real slug, type "Japan" into the site's destination search box and click the plain country row under "Locations". Then make sure that each card's `data-restaurant-country` attribute shows Japan.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows about 4 promo cards with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.** Cards that are not rendered yet return empty strings with `innerText`, and the first visible line is often the badge "Reserve a table".

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- The row count for each category must equal the site's result banner and the count in the site's Distinction filter. The difference must be zero.
- No duplicate `source_url`. No venue in two categories.
- Open one venue page for each guide (three in total). Compare name, city, distinction, and price with the card.

Speed: in Italy, one `browser_batch` call did three pages (navigate, wait 4 seconds, extract). 633 rows took about 6 calls. No page failed.

## Pass 2: Japanese names

1. Open https://guide.michelin.com/jp/ja. Find the Japan country slug on that site with its own search box, as in trap 1. Do not assume the slug.
2. Read the same four distinction lists on the Japanese site. Use the same card scope and `textContent` rules.
3. Join a Japanese card to an English row **only** on the URL part after `/restaurant/`. Never join by position, by name, or by guess.
4. Before the full join, open 5 venues on both sites. Make sure that the URL part after `/restaurant/` is identical. If it is not identical, stop Pass 2, leave the column blank, and write what you found in the log.
5. Put the Japanese card name in `name_native_michelin` exactly as printed.
6. In the log, write the number of rows with a match, the number without a match, and the URLs of the rows without a match.

If the Japanese site blocks you or its lists do not load, leave the column blank, write the problem in the log, and deliver Pass 1. Pass 1 is the priority.

## Hold register (log only, no CSV rows)

- **Green Star.** All three ceremonies were before June 1, 2026, the date when Michelin replaced Green Star with "Mindful Voices". So these guides use the name "Green Star". Published totals: Tokyo 13, Kyoto 10, Osaka 3, Nara 7. Confirm each number through the browser and record the URL. The site has no Green Star filter. Do not try a `/green-star` URL, because it goes to the worldwide list.
- **Special awards.** For each guide, name each recipient, the award, and the venue, with URLs. Tokyo gave a Mentor Chef Award, a Service Award, and a Sommelier Award. Kyoto Osaka gave a Mentor Chef Award, a Service Award, and its first Sommelier Award. Find out if Nara gave any.
- For each special-award venue, write if it is in today's star or Bib list, or not.

## Output 2: `michelin-2026-japan-log.md`

Include these parts:

1. The method: the country slug that you found, and any change from the method above.
2. A count table for each guide and category: your rows, the site filter count, and the ceremony count.
3. The results of the duplicate check and the two-category check.
4. The cards that you excluded as outside the four areas, with URLs.
5. The Pass 2 results.
6. The three venue-page spot checks.
7. The hold register, with URLs.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere.

## Stop

After the two files, write Ben a short summary: the row count per category, the difference from 592, and the cards that you held out. Then wait for Ben.
