# Cowork brief: Michelin 2026 Switzerland and Liechtenstein

You work for Ben on CompassEats, a site that lists restaurants and bars with awards. Ben is not a developer and often uses a phone. Write to him in plain language. Use short sentences. Give one step at a time.

## Your job

Read the MICHELIN Guide Switzerland 2026 selection from guide.michelin.com with the Chrome extension. Make one CSV file and one log file. Then stop and wait for Ben.

- Do not touch the database.
- Do not touch the GitHub repo.
- Do not start another country or guide.
- Do not use a competitor site (joinpearl.co, thebestrestaurantsguide.com, beliapp.com) as a source. Ignore enprimeurclub.com in search results.
- Every fact in the log needs a URL. No fact from memory.

## Scope

Capture four categories only: **Three Stars, Two Stars, One Star, Bib Gourmand.** Do not make rows for MICHELIN Selected, Green Star or special awards. These go in the log only (see "Hold register").

Michelin published the Bib Gourmand list on October 23, 2026, and the star results on November 2, 2026 (ceremony in Andermatt). The edition label is 2026.

The guide covers two selections on the site: `switzerland` and `liechtenstein`. Read both. Michelin counts Torkel (Vaduz, Liechtenstein) in the Swiss One Star count, so the Swiss list banner shows 1 fewer than the article.

Michelin adds cards during the year. Read the live site and report what it shows on the day of your run.

Counts for reference:

| Population | 3 Stars | 2 Stars | 1 Star | Bib | Sum |
|---|---|---|---|---|---|
| Michelin ceremony article, Nov 2, 2026 (whole guide) | 5 | 22 | 106 | 92 | 225 |
| Selection `switzerland`, list banners, Nov 2, 2026 evening | 5 | 22 | 105 | 92 | 224 |
| Selection `liechtenstein`, list banners, Nov 2, 2026 evening | 0 | 0 | 1 | 0 | 1 |
| Selection `switzerland`, list banners, Nov 2, 2026 morning, before the update (reference only) | 4 | 23 | 103 | 97 | 227 |
| CompassEats database, Swiss and Liechtenstein legacy rows labelled 2025 (reference only) | 5 | 22 | 103 | 97 | 227 |

Expect **225 rows**.

Sources (open them through the browser, because Michelin blocks plain fetchers):
- Ceremony results: https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/michelin-guide-schweiz-andermatt-3-sterne-restaurant
- Full star list (133 entries, each with a card link): https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/sternerestaurants-schweiz-2026
- New Bib Gourmands (names only the 11 new Bibs): https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/neue-bib-gourmand-restaurants-schweiz-michelin-inspektoren
- Special awards: https://guide.michelin.com/ch/de/article/michelin-guide-ceremony/michelin-awards-2026

NOTE: Michelin publishes no full Bib list article that names all 92. The list pages are the only full source for Bibs. The article above names the 11 new Bibs, and the ceremony article gives the total of 92.

Rules for scope:

1. Before you start, make sure that the site shows the **2026** selection. Open 4 venue pages: The Japanese Restaurant (Three Stars), MYLE (One Star), Torkel (One Star), Culinarium Alpinum (Bib). Read the guide year in the page meta description and in JSON-LD `award.dateAwarded`. Write the exact phrases in the log. If a page still says 2025, stop and tell Ben. If any page or list shows a **2027** selection, stop and tell Ben.
2. Make sure that these 2026 changes are on the live site. They prove that you read the 2026 edition:
   - Three Stars, new: **The Japanese Restaurant** (Andermatt).
   - Three Stars, no change: Sven Wassmer Memories (Bad Ragaz), Cheval Blanc by Peter Knogl (Basel), Restaurant de l'Hôtel de Ville (Crissier), Schloss Schauenstein (Fürstenau).
   - One Star, new (7): **MYLE** (Bern), **Bärenstobe** (Gonten), **CAAA by Pietro Catalano** (Lucerne), **Ristorante con enoteca Origini** (Morbio Inferiore), **Schlüssel** (Oberwil), **ad lib** (Zermatt), **rémy** (Zurich).
   - Bib Gourmand, new (11): **Gasthaus Traube - Die Braustube** (Buchs), **Ya Mama by Moses Ceylan** (Celerina), **Löwenstobe** (Gonten), **Ristorante della Stazione da YanElo** (Intragna), **Löwen Messen - Die Land Brasserie** (Messen), **Klostergasthaus Löwen - Gaststube** (Pfaffnau), **Dorfhus Gupf** (Rehetobel), **Culinarium Alpinum** (Stans), **Capet - Neo-Bistro**, **Neri Cantina & Cucina**, **Soï 28 by Stefan Heilemann** (Zurich).
   If one of them is not in the category above, stop and tell Ben.
3. Compare your star rows to the 133 card links in the full star list article, on the part of the URL after the language part (`/ch/de/`). Write the counts by category. The difference must be zero. List every row where the article name and the card name differ, with both names. A read on Nov 2 showed 5:
   - Memories / Sven Wassmer Memories
   - Da Vittorio / Da Vittorio - St. Moritz
   - The Japanese by The Chedi at Gütsch / The Japanese at Gütsch
   - Felix Lo Basso Restaurant / Soledì Restaurant
   - Soleil d'Or by Benjamin Geisser / Soleil d'Or by David Geisser
   Use the **card** name in the CSV. Write all of these in the log, with the title of the card page as a third value.
4. Every row must carry the code `ch` or `li`. If a list shows a card from another place, do not put it in the CSV. List it in the log with its URL.
5. If a total differs from 225, explain the difference in the log before you deliver. Name each restaurant that explains the difference when a Michelin URL shows it.

## Output 1: `michelin-2026-switzerland.csv`

Use this exact header line:

```
batch_key,source_id,year,rank,category,distinction,source_url,venue_name,city_label,country_label,venue_category,venue_status,price_symbol_raw,note,michelin_guide,venue_name_de,city_label_de
```

One row per card. Column rules:

| Column | Value |
|---|---|
| `batch_key` | `michelin-2026-switzerland` on every row |
| `source_id` | `michelin` |
| `year` | `2026` |
| `rank` | blank |
| `category` | exactly `Three Stars`, `Two Stars`, `One Star`, or `Bib Gourmand` |
| `distinction` | blank |
| `source_url` | the venue's own page on guide.michelin.com, in the `/us/en/` form. Required on every row. No two rows can have the same URL. Keep the percent-encoding in the path exactly as the card link has it (2 Bib cards hold `%C2%B4` and `%E2%80%93`). |
| `venue_name` | exactly as the `/us/en/` card prints it. Do not tidy it or cut it at a dash (for example "Wiesner Mysterion - Wiesner - Zauber" stays as printed). Keep accents and special characters (for example "Njørden", "Soï 28 by Stefan Heilemann", the curly apostrophe in "Soleil d’Or by David Geisser"). |
| `city_label` | the city part of the `/us/en/` card footer (for example "Geneva", "Berne", "Lucerne", "Zurich", "Saint Moritz", "Sankt Gallen"). Do not change it. |
| `country_label` | `Switzerland` for code `ch`. `Liechtenstein` for code `li`. Map with code from `data-restaurant-country`. |
| `venue_category` | `restaurant` |
| `venue_status` | blank |
| `price_symbol_raw` | the price symbols exactly as the `/us/en/` card prints them |
| `note` | blank |
| `michelin_guide` | `switzerland-2026` |
| `venue_name_de` | the name on the `/ch/de/` card (Pass 2). Blank only if Pass 2 has no card for this URL. |
| `city_label_de` | the city on the `/ch/de/` card (Pass 2). Blank only if Pass 2 has no card for this URL. |

File rules: UTF-8, no BOM, LF line ends. Put quotation marks around any field that contains a comma or a quotation mark (double the inner quotation mark). Never type rows by hand. Build the file with code from the extracted data.

The last three columns are extra. The importer ignores them and reports them as ignored. That is correct. They stay in the file for the count check and for the name and city match test.

## Price and currency

1. Copy the price symbols exactly as printed. Do not guess the currency sign. Do not convert or normalize the symbols.
2. A read on Nov 2 showed `€` symbols on the Swiss cards in both `/us/en/` and `/ch/de/`, and `$$$` on the Liechtenstein cards in `/us/en/`. Write what you see. Read the Torkel card in `/us/en/`, `/ch/de/` and `/li/en/` if that path opens, and write the symbols for each.
3. Open 4 venue pages (2 per price level). Compare the card symbols with the printed "Price" line on the venue page. Do not use JSON-LD `priceRange`.
4. In the log, write the count of rows for each distinct `price_symbol_raw` value, by category.
5. If a row prints no price, keep it blank and list it in the log.

## Pass 1: English lists

URL pattern:

```
https://guide.michelin.com/us/en/selection/switzerland/restaurants/<distinction-slug>/page/<N>
https://guide.michelin.com/us/en/selection/liechtenstein/restaurants/1-star-michelin
```

Distinction slugs: `3-stars-michelin`, `2-stars-michelin`, `1-star-michelin`, `bib-gourmand`. Each page has 48 cards. On Nov 2, One Star had 3 pages and Bib had 2 pages. Do not put `/page/1` in the URL. The Liechtenstein Three Stars, Two Stars and Bib lists give a 404, which means no rows. Write that in the log.

**This method changes from earlier briefs.** Read each list page with a same-origin `fetch()` plus `DOMParser`, from a tab on guide.michelin.com, with a pause of 1 second between pages.

The reason: on Nov 2, open browser tabs gave wrong results on the Swiss lists. After a page load, the site script can sort the cards again. Page 1 and page 2 then showed the same restaurants, and other restaurants were on no page. Le Pérolles, Du Bourg, Zur Gedult, Linde and Landgasthof Ochsen were on 2 pages each. The rows from `fetch()` gave 105 and 92 different URLs, equal to the banners. A sign of the problem: rendered cards show `data-dtm-distinction` values such as `ONE_STAR`, and server HTML shows `1 star`.

Do this proof test before you trust the read:
- For each category, the number of different URLs must equal the count in the `h1` banner.
- Read each list twice, with 5 minutes between the reads. The two sets of URLs must be equal. If they differ, stop and tell Ben.
- Open 6 venue pages in a real tab (1 of each category, plus Torkel and 1 Geneva card). Compare name, city, distinction and price with your row.

Traps:

1. **The selection part must be `selection/<slug>`.** A wrong slug returns the worldwide list with no error, and it can put your word in the page title (`/selection/switzerland/restaurants/sustainable_gastronomy` shows 19,985 restaurants). Make your scripts stop if the `h1` does not start with `Switzerland :` or `Liechtenstein :`.
2. **Read only the cards inside `.row.restaurant__list-row.js-restaurant__list_items`.** The page also shows a rail of 4 promo cards (for example Neri, Capet, Bärenstobe, Chapter Two) with the same card class outside that row. Ignore them.
3. **Read fields with `textContent`, never `innerText`.**

Fields per card: name = `h3 a` text; `source_url` = the `h3 a` href with `https://guide.michelin.com` added; city and price = the `.card__menu-footer--score` lines (the first line is "City, Country", and the second line is the price before " · "); country and distinction = `data-restaurant-country` and `data-dtm-distinction` on the card's `[data-restaurant-country]` element. Collapse runs of whitespace to one space.

Storage and copy:

- Store results in the browser `localStorage` of guide.michelin.com under keys that start with `__ch26_`. Remove your `__ch26_` keys at the end. Do not read, change or delete any other key.
- A browser call stops at 45 seconds, but the script keeps on in the page. Read the stored results again later.
- Tool output stops at about 1,000 characters. Tool output that contains `&` or `=` pairs can come back as "[BLOCKED: Cookie/query string data]". Show the rows in the page as plain text (`<pre>`) in blocks of up to 100 lines, with ` | ` as the field separator. Escape `\` as `\\` and `|` as `\|` in the blocks, and reverse this in the build script. Read each block with the page-text tool. Check each block against a SHA-256 computed in the browser (sorted lines joined with `\n`). Then build the file with code.
- Copy the exact code points. If a block hash fails, find the cause and fix it with code. Do not normalize names. List every name that is not NFC in the log.

Checks for every row and every category:

- Each card's `data-restaurant-country` and `data-dtm-distinction` attributes must agree with the filter in the URL.
- For each category and selection, the row count must equal the `h1` banner. The difference must be zero.
- No duplicate `source_url`. No URL in two categories.

## Pass 2: German lists (names and cities)

Michelin's German pages print other city names (for example Genève, Bern, Luzern, Zürich, Freiburg, Sankt Moritz). Pass 2 gives the match test a second name and a second city for every card.

1. Read the four lists on `https://guide.michelin.com/ch/de/selection/switzerland/restaurants/<distinction-slug>/page/<N>` and the Torkel list on `/ch/de/selection/liechtenstein/restaurants/1-star-michelin`, with the same rules as Pass 1.
2. Join each German card to its Pass 1 row on the part of the URL after the language part. Fill `venue_name_de` and `city_label_de`.
3. In the log, write: the row count per category for Pass 2, the number of joined rows, every row that did not join, every row where the German category differs from the English category, every row where the German name differs from the English name, and every pair of city labels that differ, with the row count.

## Registers (log only)

**Two restaurants on one address.** Michelin gives each of these pairs two cards. Write both cards (name, category, URL) for each pair:
- Adelboden: `alpenblick`, `alpenblick-bistro-1208465`
- Aubonne: `njorden`, `njord-cafe`
- Brunnen: `birdy-s-by-achtien-the-nest`, `birdy-s-by-achtien`
- Mels: `schlussel-nidbergstube`, `schlusselstube`
- Riedholz: `attisholz-le-feu`, `chateau-attisholz-brasserie-la-source`
- Romoos: `wiesner-mysterion-zauber`, `wiesner-mysterion-%E2%80%93-werkstatt-kost`
- Steffisburg: `panorama-cayenne`, `panorama-bistro`
- Wilderswil: `alpenblick179404`, `alpenblick-bistro`
- Madulain: `chesa-stuva-colani`, `colani-bistrot`

**Status.** The CompassEats database marks 2 of these venues closed. Write the card name, the category, the address and any closure note on the card. Do not read other sites.
- After Seven (Zermatt): `wallis/zermatt/restaurant/after-seven`
- Colani Bistrot (Madulain): `graubunden/madulain/restaurant/colani-bistrot`

**Left the star and Bib lists.** These 21 cards were on the lists on the morning of Nov 2 and were not on the lists that evening. For each one, open `/us/en/<path>` and write the HTTP status, the card name, the first phrase of the meta description, and any closure note.
- One Star (5): `geneve-region/geneve/restaurant/tse-fung`, `zurich-region/wangen-bei-dbendorf/restaurant/sternen-badstube`, `fribourg-region/broc/restaurant/les-montagnards-le-sommet`, `luzern-region/rigi-kaltbad/restaurant/regina-montium`, `wallis/zermatt/restaurant/capri`
- Bib Gourmand (16): `geneve-region/geneve/restaurant/chez-philippe`, `sankt-gallen-region/weesen/restaurant/fischerstube`, `geneve-region/satigny/restaurant/cafe-de-peney`, `geneve-region/collonge-bellerive/restaurant/collonge-cafe`, `geneve-region/aire-la-ville/restaurant/cafe-du-levant`, `zurich-region/zurich/restaurant/august`, `solothurn-region/solothurn/restaurant/le-restaurant1154949`, `geneve-region/geneve/restaurant/bistrot-dumas`, `zurich-region/uster/restaurant/blume`, `ticino/brissago/restaurant/agora-1190920`, `zurich-region/zurich/restaurant/rigiblick-zuriberg-beiz`, `geneve-region/geneve/restaurant/osteria-della-bottega`, `solothurn-region/solothurn/restaurant/salzhaus`, `graubunden/davos-platz/restaurant/golden-dragon`, `zurich-region/zurich/restaurant/la-bottega-di-mario`, `zurich-region/zurich/restaurant/gaijin-izakaya`

**Names that differ from the database.** Write the exact English and German card names for each: The Japanese Restaurant, Da Vittorio - St. Moritz (database "Carlton Hotel St. Moritz LHW" and "Da Vittorio"), Cheval Blanc by Peter Knogl (database also "Grand Hotel Les Trois Rois"), La Brezza (database "Tschuggen Grand Hotel Arosa"), 7132 Silver (database "7132 Hotel"), Magdalena (database "Restaurant Magdalena", 2 venues), Soledì Restaurant (database "FELIX LO BASSO RESTAURANT"), Stéphane Décotterd (database "Maison Décotterd"), Du Bourg (database "Burggasse"), LA CHAVALLERA in der Krone Säumerei am Inn (database "Restaurant La Chavallera La Punt Chamues-ch"), Balm - Bistro (database "Hotel Balm"), Bistro by Regina Montium (database "Rigi Bistro"), Centrale (database "Losone").

## Hold register (log only, no CSV rows)

- **Green Star.** Ben will handle Green Stars in a separate small file after the promote. Write whether the 2026 site shows a Green Star list or filter for each selection, and the URL. Do not guess a URL. Do not make rows.
- **Special awards.** Record each 2026 special award (award, person, venue, URL), and write if the venue is in today's star or Bib list. The article names: Service Award (Nicole Sawyere, ad lib); Young Chef Award (Guglielmo Curcio, Ristorante con enoteca Origini); Sommelier Award (Émeline Gigaud, Arakel); Opening of the Year (MYLE).
- **Liechtenstein Selected cards.** Write the name and URL of Chapter Two - modern cuisine, Marée and Weinlaube. Do not make rows.

## Output 2: `michelin-2026-switzerland-log.md`

Include these parts:

1. The method: the page-reading and copy method that you used, the codes, the proof test results, and any change from the method above. The next brief will copy this part.
2. A count table for each category and selection: your rows, the `h1` banner, and the published count. Add a table by city label and category.
3. The results of the duplicate check, the two-category check and the country check.
4. The 2026 check, the 2027 check and the named 2026 changes (scope rules 1 and 2).
5. The full star list comparison and the name differences (scope rule 3).
6. The differences from the published counts (scope rule 5).
7. Any cards that you excluded, with URLs.
8. The price and currency results.
9. The six venue-page spot checks.
10. The Pass 2 results.
11. The registers.
12. The hold register, with URLs.
13. The list of names that are not NFC (both languages).
14. The block hashes, the full-data hash, and the SHA-256 of the final CSV.

## Delivery

Attach both files to this chat. If a writable local folder is connected, save them there too. Do not upload to Google Drive. Do not retype the CSV anywhere. Do not open the CSV in Excel or Numbers before you deliver it, because they can change the price symbols and the accented letters.
