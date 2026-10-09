# Log: MICHELIN Guide Texas 2026

Run date: October 9, 2026. Tool: Claude in Chrome (rendered pages only). No database or repo change.
Every fact below has a guide.michelin.com URL. Base for short paths: `https://guide.michelin.com`.

## 1. Method

- Destination search: I typed "Texas" in the search box on `/us/en/restaurants` and clicked the plain row "Texas, USA" under "Locations".
- Result URL: https://guide.michelin.com/us/en/texas/restaurants. Region slug: **`texas`**. Banner: "Texas : 1-48 of 149 restaurants" (149 agrees with the press-release total).
- List URLs:
  - https://guide.michelin.com/us/en/texas/restaurants/3-stars-michelin (no results)
  - https://guide.michelin.com/us/en/texas/restaurants/2-stars-michelin (no results)
  - https://guide.michelin.com/us/en/texas/restaurants/1-star-michelin (1 page)
  - https://guide.michelin.com/us/en/texas/restaurants/bib-gourmand and `/page/2` (2 pages)
- Page links came from `a[href*="/page/"]` in the DOM. 1 Star: only `/page/1`. Bib: `/page/1` and `/page/2`.
- I opened every list page in the browser tab and read the rendered DOM. I did not use `fetch()` or `DOMParser`.
- I read only cards inside `.row.restaurant__list-row.js-restaurant__list_items`. I read all fields with `textContent`, and collapsed whitespace.
- Raw first footer line for 3 cards: `Spring, TX, USA` (CorkScrew BBQ), `Fort Worth, TX, USA` (Goldee’s Bar-B•Q), `San Antonio, TX, USA` (Nicōsi). City = that line minus `, TX, USA`. A check in the page confirmed that all 73 lines end with `, TX, USA`.
- Changes from the brief method:
  - Tool output stops at about 1,000 characters, so I showed each block in parts of 12 rows or fewer (not 100). The hash check was on the full block.
  - The tab group was reset once during the run. I opened a new tab and continued. No list data was lost (the 3 blocks were already copied and hashed).

## 2. Count table

| Category | My rows | Site banner | Distinction filter | Published count | Difference |
|---|---|---|---|---|---|
| Three Stars | 0 | "Unfortunately there are no selected restaurants…" | not listed | 0 | 0 |
| Two Stars | 0 | "Unfortunately there are no selected restaurants…" | not listed | 0 | 0 |
| One Star | 19 | "Texas : 1-19 of 19 restaurants - 1 Star" | 19 | 19 (2026 star article) | 0 |
| Bib Gourmand | 54 | "Texas : 1-48 of 54 restaurants - Bib Gourmand" and "49-54 of 54" | 54 | not published | 0 |
| **Total** | **73** | | | | |

Distinction filter text (Texas list page, read from the DOM): "1 Star High quality cooking 19 · Bib Gourmand Good quality, good value cooking 54 · Selected Restaurants Good cooking 76". 19 + 54 + 76 = 149.

Reference only: CompassEats legacy 2025 rows were 16 One Star and 47 Bib.

## 3. Duplicate, two-category and state checks

- Duplicate `source_url`: 0 (73 rows, 73 distinct URLs).
- Venue in two categories: 0.
- `data-dtm-distinction` against the URL filter: 0 mismatches. All 19 One Star cards = `ONE_STAR`. All 54 Bib cards = `BIB_GOURMAND`.
- State check: all 73 `source_url` paths start with `/us/en/texas/`. 0 non-ASCII characters in any URL (no encoding needed).
- Quoted fields in the CSV: 0 (no name has a comma or a quotation mark).

## 4. 2026 check (scope rules 1 and 2)

Guide year on venue pages (meta description phrase and JSON-LD `award.dateAwarded`):

| Venue | Category | Meta description phrase | dateAwarded | URL |
|---|---|---|---|---|
| Goldee’s Bar-B•Q | One Star | "a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide USA" | "2026" | https://guide.michelin.com/us/en/texas/fort-worth_2954653/restaurant/goldee-s |
| Kappo Kappo | One Star | "a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide USA" | "2026" | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/kappo-kappo |
| Barbs B Q | Bib Gourmand | "a Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide USA" | "2026" | https://guide.michelin.com/us/en/texas/lockhart_2958209/restaurant/barbs-b-q |

No page says 2025. Result: the site shows the 2026 selection.

Named 2026 changes:

| Venue | Expected | Card category | Venue page | Result |
|---|---|---|---|---|
| Goldee’s Bar-B•Q (Fort Worth) | One Star, promoted from Bib | One Star | One Star, 2026 | OK |
| Fabrik (Austin) | One Star, promoted | One Star | One Star, 2026 (https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/fabrik) | OK |
| Kappo Kappo (Austin) | One Star, new | One Star | One Star, 2026 | OK |

## 5. 2025 versus 2026 star lists (scope rules 3 and 4)

- 2026 article: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-texas-for-2026 — 19 One Star (Austin 7, Dallas 2, Fort Worth 1, Houston 5, San Antonio 3, Spring 1).
- 2025 article: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-texas-2025 — 18 One Star.

In 2025, not in 2026:

| Venue | 2025 URL | What the URL shows today |
|---|---|---|
| la Barbecue (Austin) | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/la-barbecue | Page is live. Meta says only "a MICHELIN restaurant". No `award` in JSON-LD. Page `dataLayer` distinction = `plate` (MICHELIN Selected). Not on the One Star or Bib list. |
| Olamaie (Austin) | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/olamaie | Page title "Restaurant not found". Not on any list. |

In 2026, not in 2025: Fabrik, Kappo Kappo, Goldee’s Bar-B•Q (URLs in part 4).

Arithmetic: 18 − 2 + 3 = 19.

- Closed marks: the 2026 article marks no entry as closed.
- My star count: 19. Difference from 19: **0**.
- Note: the 2026 article body has one link with no text to a Vancouver venue (`/us/en/british-columbia/ca-vancouver/restaurant/masayoshi`), between the Austin and Dallas lists. It is not a Texas entry. It does not change the count.

## 6. Excluded cards

- No card from another state was in a Texas list row.
- Each list page also shows 4 promo cards outside the list row. I did not put them in the CSV. The same 4 showed on every page that I read (1 Star, Bib page 1, Bib page 2):
  - Smoke'N Ash BBQ — /us/en/texas/arlington_2954961/restaurant/smoke-n-ash-bbq
  - Belly of the Beast — /us/en/texas/spring_2986734/restaurant/belly-of-the-beast (also a real Bib row)
  - Stillwell's — /us/en/texas/dallas_2954570/restaurant/stillwell-s
  - Nicōsi — /us/en/texas/san-antonio_2958156/restaurant/nicosi (also a real One Star row)
- The 3 Stars and 2 Stars pages had 0 list cards and 4 promo cards.

Article/site difference (log only, no CSV change):

- The Bib article https://guide.michelin.com/us/en/article/michelin-guide-ceremony/the-best-value-restaurants-in-texas-for-2026 links 55 venues. 54 agree with the site list. The extra one is **Lucia** (Dallas), https://guide.michelin.com/us/en/texas/dallas_2954570/restaurant/lucia-1209114. Its venue page shows no award in meta or JSON-LD, and `dataLayer` distinction = `plate`. The site Bib list and filter do not include it. I followed the site (54). Ben to decide.
- The same article marks 6 venues "New Bib Gourmand": Resident Taqueria, Bar Buena, Xolo, Khói Barbecue, Kitchen Rumors, Murray's Pizza & Wine. All 6 are in the CSV. This agrees with "6 new Bib Gourmands".
- The article prints "Killen's"; the card prints "Killen's BBQ". The CSV uses the card name.

## 7. Price results

| price_symbol_raw | Rows |
|---|---|
| `$` | 8 |
| `$$` | 40 |
| `$$$` | 10 |
| `$$$$` | 15 |

By category: One Star `$$` 4, `$$$$` 15. Bib `$` 8, `$$` 36, `$$$` 10.

- Every row has a price. Every symbol is `$`. Nothing to list.
- JSON-LD `priceRange` is words, not symbols. The venue page also prints a "Price:" line in symbols.

| Venue | Card | Page "Price:" | JSON-LD priceRange |
|---|---|---|---|
| Goldee’s Bar-B•Q | `$$` | — (not read) | "A moderate spend" |
| Kappo Kappo | `$$$$` | — (not read) | "Spare no expense" |
| Fabrik | `$$$$` | — (not read) | "Spare no expense" |
| Emmer & Rye | `$$$` | `$$$` | "Special occasion" |
| CorkScrew BBQ | `$$` | `$$` | "A moderate spend" |
| Tatemó | `$$$$` | `$$$$` | "Spare no expense" |

Mapping seen: `$$` = "A moderate spend", `$$$` = "Special occasion", `$$$$` = "Spare no expense". No conflict.

## 8. Venue-page spot checks (5)

| # | Venue (card) | Card city / category / price | Page h1 | Page address | Page category (meta) | Page price | Result |
|---|---|---|---|---|---|---|---|
| 1 | CorkScrew BBQ | Spring / One Star / `$$` | CorkScrew BBQ | 26608 Keith St., Spring, TX | One Star, 2026 | `$$` | Match |
| 2 | Tatemó | Houston / One Star / `$$$$` | Tatemó | 4740 Dacoma St., Unit F., Houston, TX | One Star, 2026 | `$$$$` | Match |
| 3 | Nicōsi | San Antonio / One Star / `$$$$` | Nicōsi | 221 Newell Ave., San Antonio, TX | One Star, 2026 | `$$$$` | Match |
| 4 | Barbs B Q | Lockhart / Bib / `$$` | Barbs B Q | 102 E. Market St., Lockhart, TX | Bib Gourmand, 2026 | `$$` | Match |
| 5 | Rosemeyer Bar-B-Q | Spring / Bib / `$$` | Rosemeyer Bar-B-Q | 2111 Riley Fuzzel Rd., Spring, TX | Bib Gourmand, 2026 | `$$` | Match |

URLs:
1. https://guide.michelin.com/us/en/texas/spring_2986734/restaurant/corkscrew-bbq
2. https://guide.michelin.com/us/en/texas/houston_2986624/restaurant/tatemo
3. https://guide.michelin.com/us/en/texas/san-antonio_2958156/restaurant/nicosi
4. https://guide.michelin.com/us/en/texas/lockhart_2958209/restaurant/barbs-b-q
5. https://guide.michelin.com/us/en/texas/spring_2986734/restaurant/rosemeyer-bar-b-q

Note: Isidore and Nicōsi show the same street address (221 Newell Ave.). They are two different venue pages and two rows.

## 9. Name and city register

| Database question | Card name | Category | Card city | URL |
|---|---|---|---|---|
| Goldee's (DB: "Goldee's Barbecue", Bib 2025) | Goldee’s Bar-B•Q (apostrophe is U+2019, dot is U+2022) | One Star | Fort Worth | https://guide.michelin.com/us/en/texas/fort-worth_2954653/restaurant/goldee-s |
| CorkScrew BBQ (One Star 2025) | CorkScrew BBQ | One Star | Spring | https://guide.michelin.com/us/en/texas/spring_2986734/restaurant/corkscrew-bbq |
| Belly of the Beast (Bib 2025) | Belly of the Beast | Bib Gourmand | Spring | https://guide.michelin.com/us/en/texas/spring_2986734/restaurant/belly-of-the-beast |
| Rosemeyer Bar-B-Q (Food Truck) (Bib 2025) | Rosemeyer Bar-B-Q (no "(Food Truck)") | Bib Gourmand | Spring | https://guide.michelin.com/us/en/texas/spring_2986734/restaurant/rosemeyer-bar-b-q |
| Blood Bros. BBQ (Bellaire) | Blood Bros BBQ (no period) | Bib Gourmand | Bellaire | https://guide.michelin.com/us/en/texas/bellaire_2959890/restaurant/blood-bros-bbq |
| Barbs B Q (Lockhart) | Barbs B Q | Bib Gourmand | Lockhart | https://guide.michelin.com/us/en/texas/lockhart_2958209/restaurant/barbs-b-q |
| Tejas Chocolate + Barbecue (Tomball) | Tejas Chocolate + Barbecue | Bib Gourmand | Tomball | https://guide.michelin.com/us/en/texas/tomball_2987082/restaurant/tejas-chocolate |

Goldee's has no Bib card in 2026 (not in the 54 Bib rows).

Card cities that are not Austin, Houston, Dallas, San Antonio or Fort Worth:

| City | Cards |
|---|---|
| Spring | CorkScrew BBQ (One Star); Rosemeyer Bar-B-Q, Belly of the Beast (Bib) |
| Pearland | Killen's BBQ (Bib) — /us/en/texas/pearland_2986629/restaurant/killen-s-bbq |
| Tomball | Tejas Chocolate + Barbecue (Bib) |
| Bellaire | Blood Bros BBQ (Bib) |
| Lockhart | Barbs B Q (Bib) |
| Seguin | Burnt Bean Co. (Bib) — /us/en/texas/seguin_2958298/restaurant/burnt-bean-co |

Rows per city: Houston 26, Austin 22, Dallas 8, San Antonio 8, Spring 3, Fort Worth 1, Pearland 1, Tomball 1, Bellaire 1, Lockhart 1, Seguin 1.

## 10. Hold register (no CSV rows)

**Mindful Voices.**
- The Distinction filter on the Texas list shows no Green Star or Mindful Voices option. The list cards carry no sustainability attribute (I compared all `data-*` attributes of the Dai Due and Franklin Barbecue cards).
- The 2026 star article and the 2026 Bib article do not name Mindful Voices.
- Venue pages show a block (class `data-sheet__mindful-content`) headed "MINDFUL VOICES" with a named person. Result for the 4 former Green Stars:

| Venue | 2025 status | 2026 card category | Mindful Voices block on venue page | URL |
|---|---|---|---|---|
| Dai Due | Green Star (2024) | Bib Gourmand | Yes — Jesse Griffiths | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/dai-due |
| Emmer & Rye | Green Star (2024) | Bib Gourmand | Yes — Kevin Fink | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/emmer-rye |
| Nixta Taqueria | Green Star (2025) | Bib Gourmand | Yes — Edgar Rico | https://guide.michelin.com/us/en/texas/austin_2958315/restaurant/nixta-taqueria |
| Isidore | Green Star (2025) | One Star | Yes — Ian Lanphear | https://guide.michelin.com/us/en/texas/san-antonio_2958156/restaurant/isidore |

- Pages without the block (from my checks): CorkScrew BBQ, Tatemó, Nicōsi, Barbs B Q, Rosemeyer Bar-B-Q.
- Limit: I did not open all 149 venue pages. Other Texas venues can have the block. A full sweep needs one page per venue.

**Special awards (2026).**

| Award | Person | Venue | Venue in today's lists | URL |
|---|---|---|---|---|
| MICHELIN Guide Service Award (Texas 2026) | Stefan Davis, General Manager | Barley Swine, Austin | Yes — One Star | https://guide.michelin.com/us/en/article/michelin-guide-ceremony/barley-swine-texas-michelin-guide-service-award |

- The 2026 star article also says Barley Swine won the 2026 Texas Service Award.
- I found no other 2026 Texas special award on the MICHELIN Guide Ceremony article list (https://guide.michelin.com/us/en/articles/michelin-guide-ceremony) or in a site-limited web search. The Texas Sommelier article for Suerte/Este (https://guide.michelin.com/us/en/article/michelin-guide-ceremony/suerte-este-austin-michelin-guide-sommelier-award) is the **2025** award, not 2026. Michelin can publish more award articles later.

## 11. Hashes

Canonical line per row (as hashed in the browser and again in code): `category<TAB>venue_name<TAB>source_url<TAB>city_label<TAB>price_symbol_raw`. Hash = SHA-256 of the sorted lines joined with `\n`, UTF-8.

| Block | Rows | Browser SHA-256 | Code SHA-256 | Match |
|---|---|---|---|---|
| One Star, page 1 | 19 | 4e29c898cf17213a714e289da36512239c3359b6bca14a14a26a10897bb1bc25 | same | Yes |
| Bib Gourmand, page 1 | 48 | 19430c37e2c512b56758d0b9f1f59aba3cc35fb53b6f8013a253e3976487f075 | same | Yes |
| Bib Gourmand, page 2 | 6 | 880d0d250e4be44f6f580844d4246e5c6611da73940705635ae92c7ec2b0cdae | same | Yes |
| Full data | 73 | 5dabb8d0f2db4d9769e61df0917ce6bff73f31241029961802c6ade45c707cda | same | Yes |

Final CSV `michelin-2026-texas.csv` (UTF-8, LF line ends, 74 lines with header): SHA-256 **018083df425fcc30338b09dd2997f7f6caa1393fac547389617dbb64ecd4c728**.

The CSV was built with Python `csv.writer` from the hash-checked data. I read it back in code and it agreed row by row. I did not open it in Excel or Numbers.
