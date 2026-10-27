# Michelin 2026 American South — capture log

Captured on Tuesday, October 27, 2026, with the Chrome extension, from guide.michelin.com (one tab, the tab group did not reset).
Brief: `claude/cowork-michelin-2026-american-south.md`.
No database or repo was touched. No competitor site was used.

Result: **81 rows** — Three Stars 0, Two Stars 1, One Star 21, Bib Gourmand 59. This equals the published 1 / 21 / 59. The difference is zero.

---

## 1. Method

### Slugs found with the destination search box

| Search text | "Locations" row clicked | Slug | List URL | Banner |
|---|---|---|---|---|
| American South | American South, USA | `area-usa-american-south` | https://guide.michelin.com/us/en/area-usa-american-south/restaurants | American South (USA) : 1-48 of 265 restaurants |
| Alabama | Alabama, USA | `alabama` | https://guide.michelin.com/us/en/alabama/restaurants | Alabama : 1-18 of 18 restaurants |
| Georgia | Georgia, USA | `georgia` | https://guide.michelin.com/us/en/georgia/restaurants | Georgia : 1-48 of 64 restaurants |
| Louisiana | Louisiana, USA | `louisiana` | https://guide.michelin.com/us/en/louisiana/restaurants | Louisiana : 1-40 of 40 restaurants |
| Mississippi | Mississippi, USA | `mississippi` | https://guide.michelin.com/us/en/mississippi/restaurants | Mississippi : 1-13 of 13 restaurants |
| North Carolina | North Carolina, USA | `north-carolina` | https://guide.michelin.com/us/en/north-carolina/restaurants | North Carolina : 1-48 of 58 restaurants |
| South Carolina | South Carolina, USA | `south-carolina` | https://guide.michelin.com/us/en/south-carolina/restaurants | South Carolina : 1-27 of 27 restaurants |
| Tennessee | Tennessee, USA | `tennessee` | https://guide.michelin.com/us/en/tennessee/restaurants | Tennessee : 1-45 of 45 restaurants |

State totals: 18 + 64 + 40 + 13 + 58 + 27 + 45 = **265** = region total.

The territory selector on https://guide.michelin.com/us/en/articles/mindful-voices lists the seven names "USA - Alabama (American South)", "USA - Georgia (American South)", "USA - Louisiana (American South)", "USA - Mississippi (American South)", "USA - North Carolina (American South)", "USA - South Carolina (American South)", "USA - Tennessee (American South)".

### Capture lists (region list, because a region list exists)

| Category | URL | Pages |
|---|---|---|
| Three Stars | https://guide.michelin.com/us/en/area-usa-american-south/restaurants/3-stars-michelin | empty-result page |
| Two Stars | https://guide.michelin.com/us/en/area-usa-american-south/restaurants/2-stars-michelin | 1 |
| One Star | https://guide.michelin.com/us/en/area-usa-american-south/restaurants/1-star-michelin | 1 |
| Bib Gourmand | https://guide.michelin.com/us/en/area-usa-american-south/restaurants/bib-gourmand | 2 (…/bib-gourmand/page/2) |

Page links came from the DOM (`a[href*="/page/"]`). Two Stars and One Star show only `/page/1`. Bib shows `/page/1` and `/page/2`.

Each page was opened in the browser tab and read from the rendered DOM. No `fetch()` and no `DOMParser`.

### Card reading

- Only cards inside `.row.restaurant__list-row.js-restaurant__list_items` were read. Each page also had 4 promo cards outside that row (One Star page: 25 `h3 a` in the page, 21 in the row; Two Stars: 5 vs 1; Bib page 1: 52 vs 48; Bib page 2: 15 vs 11). They were ignored.
- All fields read with `textContent`, whitespace runs collapsed to one space.
- name = `h3 a` text. `source_url` = `h3 a` href with `https://guide.michelin.com` added. footer = first `.card__menu-footer--score` line. city = footer minus the last two parts. `state_label` = second-last part. price = second footer line before " · ".

Three raw footer lines (line 1 || line 2):
- Scoundrel: `Greenville, SC, USA || $$$ · French`
- (One Star card 2, Atlanta): `Atlanta, GA, USA || $$$$ · Japanese`
- Emeril’s: `New Orleans, LA, USA || $$$ · American`
- (Bib page 1, card 1): `Birmingham, AL, USA || $$ · French`

### Changes from the method in the brief

1. **Distinction attribute per card.** Each card holds 4 elements with `[data-restaurant-country]` (the icon buttons), each with its own `data-dtm-distinction`. I read the card column, collected the attribute from all 4, and checked that they agree. They agree on every card.
2. **Hash output.** The tool blocked a bare 64-character hash as "base64" and cut long output. When that happened, I printed the hash in four 16-character groups and joined them again. All block hashes were then checked in my workspace against the saved block text. All match.
3. **Bib blocks are per page.** Page 1 (48 rows) = 4 blocks of 12. Page 2 (11 rows) = 1 block.
4. **Full-data hash** was computed in my workspace from the 8 verified blocks (sorted lines joined with `\n`), because one page cannot see the rows of another page.
5. **State banners** were read by moving the same tab from page to page (`location.href`), then reading the rendered `h1`. No fetch.
6. **JSON-LD `priceRange` is a phrase, not symbols** (see section 7). I compared the card symbols with the "Price:" line on the venue page and recorded the `priceRange` phrase too.

---

## 2. Counts

### Per category

| Category | My rows | Site banner (region) | Distinction filter (region) | Published (press release) | Difference |
|---|---|---|---|---|---|
| Three Stars | 0 | empty-result page | no option | 0 | 0 |
| Two Stars | 1 | "1-1 of 1 restaurants - 2 Stars" | 1 | 1 | 0 |
| One Star | 21 | "1-21 of 21 restaurants - 1 Star" | 21 | 21 | 0 |
| Bib Gourmand | 59 | "1-48 of 59 restaurants - Bib Gourmand" / "49-59 of 59" | 59 | 59 | 0 |
| **Sum** | **81** | | 81 | 81 | **0** |

### Per state × category (my rows; each cell equals the state banner)

| State | Two Stars | One Star | Bib Gourmand | Sum |
|---|---|---|---|---|
| AL | 0 | 0 (empty page) | 5 | 5 |
| GA | 0 | 10 | 12 | 22 |
| LA | 1 | 3 | 12 | 16 |
| MS | 0 | 0 (empty page) | 3 | 3 |
| NC | 0 | 1 | 11 | 12 |
| SC | 0 | 4 | 4 | 8 |
| TN | 0 | 3 | 12 | 15 |
| **Sum** | **1** | **21** | **59** | **81** |

State banner URLs follow the pattern `https://guide.michelin.com/us/en/<state slug>/restaurants/<distinction slug>`. Banners read: AL Bib "Alabama : 1-5 of 5"; GA One Star "Georgia : 1-10 of 10", GA Bib "1-12 of 12"; LA One Star "1-3 of 3", LA Two Stars "1-1 of 1", LA Bib "1-12 of 12"; MS Bib "1-3 of 3"; NC One Star "1-1 of 1", NC Bib "1-11 of 11"; SC One Star "1-4 of 4", SC Bib "1-4 of 4"; TN One Star "1-3 of 3", TN Bib "1-12 of 12". Every Two Stars state page except Louisiana, and the AL and MS One Star pages, return "Unfortunately there are no selected restaurants in the area you've searched for."

The seven state counts add up to the region count for each category.

---

## 3. Checks

| Check | Result |
|---|---|
| `data-dtm-distinction` agrees with the URL filter | Pass. Two Stars page: all `TWO_STARS`. One Star: all `ONE_STAR`. Bib pages 1 and 2: all `BIB_GOURMAND`. |
| Duplicate `source_url` | None (81 unique). |
| Venue in two categories | None. |
| Footer ends with ", <two letters>, USA" and the letters are AL, GA, LA, MS, NC, SC or TN | Pass on all 81 cards (checked in the page on each list page). |
| `source_url` path starts with `/us/en/<one of the seven state slugs>/` | Pass on all 81. |
| Path state slug agrees with `state_label` | Pass on all 81. |
| Row count = banner = Distinction filter | Pass, difference 0 in every category. |

---

## 4. 2026 edition check (scope rules 1 and 2)

### Rule 1 — venue pages show the 2026 guide

| Venue | Category | Meta description (exact start) | JSON-LD `award.dateAwarded` |
|---|---|---|---|
| So. Fox — https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/so-fox | One Star | "So. Fox – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide USA." | "2026" (awardFor "One Star: High quality cooking") |
| Dakar NOLA — https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/dakar-nola | One Star | "Dakar NOLA – a One Star: High quality cooking restaurant in the 2026 MICHELIN Guide USA." | "2026" |
| Summerland — https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/summerland | Bib | "Summerland – a Bib Gourmand: good quality, good value cooking restaurant in the 2026 MICHELIN Guide USA." | "2026" (awardFor "Bib Gourmand: good quality, good value cooking") |

No page said 2025. Every other venue page I opened also said 2026.

### Rule 2 — named 2026 changes

| Venue | Expected | Found | URL |
|---|---|---|---|
| So. Fox (Atlanta) | One Star, new | One Star | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/so-fox |
| Uberto Restaurant (Gay, GA) | One Star, new | One Star | https://guide.michelin.com/us/en/georgia/guy_7770503/restaurant/uberto-restaurant |
| Dakar NOLA (New Orleans) | One Star, new | One Star | https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/dakar-nola |
| Summerland (Atlanta) | Bib Gourmand | Bib Gourmand | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/summerland |
| Miscellanea Spirit House (Oxford, MS) | Bib Gourmand | Bib Gourmand | https://guide.michelin.com/us/en/mississippi/oxford_2919729/restaurant/miscellanea-spirit-house |

All five pass.

---

## 5. Star lists 2025 vs 2026 (scope rules 3 and 4)

- 2026 star article (found): https://guide.michelin.com/us/en/article/michelin-guide-ceremony/every-michelin-starred-restaurant-in-the-american-south-for-2026 — "Every MICHELIN-Starred Restaurant in the American South for 2026", dated October 21, 2026. Sections "1 Restaurant Two Stars" and "21 Restaurants One Star".
- 2025 star article: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-to-the-american-south — "All the Stars in The MICHELIN Guide American South 2025". Two Stars 1, One Star 18.

The 2026 article lists exactly the 22 star rows in the CSV (same names, same URLs).

| | Venues |
|---|---|
| In 2025, not in 2026 | **None** |
| In 2026, not in 2025 | **So. Fox** (Atlanta, GA) https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/so-fox ; **Uberto Restaurant** (Gay, GA) https://guide.michelin.com/us/en/georgia/guy_7770503/restaurant/uberto-restaurant ; **Dakar NOLA** (New Orleans, LA) https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/dakar-nola |

- The 2026 article marks no entry as closed (no "closed" text in the article).
- The 2026 article says Dakar NOLA was "previously selected" and is now One Star.
- The 2025 article has "Note: This restaurant is temporarily closed." under Spring (Marietta).
- Emeril's apostrophe: straight (') in the 2025 article; curly (’) on the 2026 card, venue page and article. The CSV keeps the card form "Emeril’s".

**Scope rule 4:** rows are 1 / 21 / 59. No difference to explain.

The 14 new Bib Gourmands named in the press are all in the CSV as Bib Gourmand: A Dopo, Ajja, Bao Toan Kitchen & Bar, Ideal's, Maiz De La Vida, Miscellanea Spirit House, Okàn, Palmira, Rivayat Creative Indian, Safta's Table, Summerland, Tesoro, The Story of "Mi Cariño", Tipsy Thaiger. (Press list source given in the brief: https://www.finedininglovers.com/explore/articles/michelin-guide-american-south-2026 — not opened; every row comes from guide.michelin.com.)

---

## 6. Excluded cards

- **No card from outside the seven states** appeared in any list.
- Promo cards outside `.row.restaurant__list-row.js-restaurant__list_items` (4 per list page) were ignored.
- MICHELIN Selected (184 on the site) — not captured, by scope.

---

## 7. Price

Card symbols copied exactly. All 81 rows print a price. Every symbol is `$`.

| `price_symbol_raw` | Rows | Two Stars | One Star | Bib |
|---|---|---|---|---|
| `$` | 12 | 0 | 0 | 12 |
| `$$` | 45 | 0 | 1 | 44 |
| `$$$` | 8 | 1 | 4 | 3 |
| `$$$$` | 16 | 0 | 16 | 0 |
| **Sum** | **81** | 1 | 21 | 59 |

No row without a price. No symbol other than `$`.

Card vs venue page (9 pages opened). The venue page "Price:" line equals the card on every page. JSON-LD `priceRange` is a phrase:

| Venue | Card | Page "Price:" | JSON-LD `priceRange` |
|---|---|---|---|
| Emeril’s | $$$ | $$$ | "Special occasion" |
| So. Fox | $$$ | $$$ | "Special occasion" |
| Dakar NOLA | $$$$ | $$$$ | "Spare no expense" |
| Uberto Restaurant | $$$$ | $$$$ | "Spare no expense" |
| Spring | $$$$ | $$$$ | "Spare no expense" |
| Summerland | $$ | $$ | "A moderate spend" |
| Bayonet | $$ | $$ | "A moderate spend" |
| Miscellanea Spirit House | $$ | $$ | "A moderate spend" |
| Okàn | $$ | $$ | "A moderate spend" |

Note: Malagón Mercado y Taperia is One Star with `$$`.

---

## 8. Six venue-page spot checks

| # | Venue | URL | Name | City | State | Distinction | Price | Result |
|---|---|---|---|---|---|---|---|---|
| 1 | Emeril’s (Two Stars) | https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/emeril-s | Emeril’s | New Orleans | LA (800 Tchoupitoulas St., New Orleans, LA) | Two Stars: Excellent cooking, 2026 | $$$ | Match |
| 2 | Uberto Restaurant (Gay) | https://guide.michelin.com/us/en/georgia/guy_7770503/restaurant/uberto-restaurant | Uberto Restaurant | Gay (2 Jimmy Clark Rd., Gay, GA; JSON-LD locality "Gay") | GA | One Star, 2026 | $$$$ | Match |
| 3 | Spring (One Star) | https://guide.michelin.com/us/en/georgia/marietta_2884138/restaurant/spring-1210096 | Spring | Marietta | GA | One Star, 2026 | $$$$ | Match |
| 4 | Bayonet (Bib, Alabama) | https://guide.michelin.com/us/en/alabama/birmingham_2870441/restaurant/bayonet | Bayonet | Birmingham | AL | Bib Gourmand, 2026 | $$ | Match |
| 5 | Miscellanea Spirit House (Bib, Mississippi) | https://guide.michelin.com/us/en/mississippi/oxford_2919729/restaurant/miscellanea-spirit-house | Miscellanea Spirit House | Oxford | MS | Bib Gourmand, 2026 | $$ | Match |
| 6 | Okàn (Bib, outside big cities) | https://guide.michelin.com/us/en/south-carolina/bluffton_2952024/restaurant/okan | Okàn | Bluffton | SC | Bib Gourmand, 2026 | $$ | Match |

Uberto: the URL city segment is `guy_7770503`, but the card, address, JSON-LD and page title all say **Gay**. The CSV uses "Gay".

---

## 9. Name and city register

| Database question | Card name (exact) | Category 2026 | City, State | URL |
|---|---|---|---|---|
| Counter- (Charlotte) | **Counter** (no dash; raw `textContent` is "Counter", `data-restaurant-name` is "Counter") | One Star | Charlotte, NC | https://guide.michelin.com/us/en/north-carolina/charlotte_2987283/restaurant/counter |
| Malagón (Charleston) | **Malagón Mercado y Taperia** | One Star | Charleston, SC | https://guide.michelin.com/us/en/south-carolina/charleston_2952029/restaurant/malagon-mercado-y-taperia |
| Rodney Scott's BBQ (Charleston) | **No card.** Not among the 265 cards of the region list. Site search "Rodney Scott" shows no restaurant. | — | — | https://guide.michelin.com/us/en/area-usa-american-south/restaurants |
| Spring (Marietta) | **Spring** | One Star | Marietta, GA | https://guide.michelin.com/us/en/georgia/marietta_2884138/restaurant/spring-1210096 — 2026 page shows opening hours (Tue–Sat 5 PM) and no "temporarily closed" note. The 2025 star article had "Note: This restaurant is temporarily closed." |
| Elvie's ("Jackson") | **Elvie's** | Bib Gourmand | Jackson, MS | https://guide.michelin.com/us/en/mississippi/jackson_2919677/restaurant/elvie-s |
| Sacred Ground Barbecue ("Jackson") | **Sacred Ground Barbecue** | Bib Gourmand | Jackson, MS | https://guide.michelin.com/us/en/mississippi/jackson_2919677/restaurant/sacred-ground-barbecue |
| Birmingham, Alabama — Bayonet | Bayonet | Bib Gourmand | city text "Birmingham" (footer "Birmingham, AL, USA") | https://guide.michelin.com/us/en/alabama/birmingham_2870441/restaurant/bayonet |
| Birmingham — La Fête | La Fête | Bib Gourmand | "Birmingham", AL | https://guide.michelin.com/us/en/alabama/birmingham_2870441/restaurant/la-fete |
| Birmingham — OvenBird | OvenBird | Bib Gourmand | "Birmingham", AL | https://guide.michelin.com/us/en/alabama/birmingham_2870441/restaurant/ovenbird |
| Birmingham — Pizza Grace | Pizza Grace | Bib Gourmand | "Birmingham", AL | https://guide.michelin.com/us/en/alabama/birmingham_2870441/restaurant/pizza-grace |
| Superica (Georgia Bib change) | Superica | **Selected** (not Bib) | Atlanta, GA | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/superica |
| Table & Main (Roswell) | Table & Main | **Selected** (not Bib) | Roswell, GA | https://guide.michelin.com/us/en/georgia/roswell_2884202/restaurant/table-main |
| Masterpiece (Duluth) | **No card.** Not among the 265 cards. Site search "Masterpiece" shows no restaurant. | — | — | https://guide.michelin.com/us/en/area-usa-american-south/restaurants |
| "mother bakery & cafe \| south slope" (Asheville) | **Mother** | Bib Gourmand | Asheville, NC | https://guide.michelin.com/us/en/north-carolina/asheville_2147494/restaurant/mother-1241183 |
| "Bomb Biscuit Atlanta" | **Bomb Biscuit Co.** | Bib Gourmand | Atlanta, GA | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/bomb-biscuit-co |
| "The Busy Bee" (Atlanta) | **The Busy Bee** | Bib Gourmand | Atlanta, GA | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/the-busy-bee |
| "Lewis Barbecue Charleston" | **Lewis Barbecue** | **Selected** (not Bib, so not in the CSV) | Charleston, SC | https://guide.michelin.com/us/en/south-carolina/charleston_2952029/restaurant/lewis-barbecue |
| "Cochon Restaurant" (New Orleans) | **Cochon** | Bib Gourmand | New Orleans, LA | https://guide.michelin.com/us/en/louisiana/new-orleans_2906000/restaurant/cochon |

### Card cities other than Atlanta, New Orleans, Nashville, Charleston, Charlotte

| City | State | Cards |
|---|---|---|
| Birmingham | AL | Bayonet, La Fête, OvenBird, Pizza Grace (Bib) |
| Mobile | AL | The Noble South (Bib) |
| Avondale Estates | GA | Arepa Mia (Bib) |
| Gay | GA | Uberto Restaurant (One Star) |
| Marietta | GA | Spring (One Star) |
| Roswell | GA | Tipsy Thaiger (Bib) |
| Jackson | MS | Elvie's, Sacred Ground Barbecue (Bib) |
| Oxford | MS | Miscellanea Spirit House (Bib) |
| Asheville | NC | Little Chango, Luminosa, Mother (Bib) |
| Carrboro | NC | Tesoro (Bib) |
| Durham | NC | Ideal's (Bib) |
| Knightdale | NC | Prime Barbecue (Bib) |
| Raleigh | NC | Ajja, Mala Pata, Sam Jones BBQ (Bib) |
| Bluffton | SC | Okàn (Bib) |
| Greenville | SC | Scoundrel (One Star) |
| Chattanooga | TN | Little Coyote (Bib) |
| Knoxville | TN | A Dopo (Bib) |
| Memphis | TN | Bao Toan Kitchen & Bar, Hog & Hominy (Bib) |

Cards in cities that the brief names as shared by more than one state (use `state_label`): Birmingham AL, Jackson MS, Oxford MS, Greenville SC.

---

## 10. Hold register (log only, no CSV rows)

### Mindful Voices

Press release: Mindful Voices = **6**. It names two chefs highlighted at the ceremony: Sam Diminich (Restaurant Constance, Charlotte, NC) and Ryan Smith (Uberto Restaurant, Gay, GA). Its link goes to https://guide.michelin.com/us/en/articles/mindful-voices (the first 6 hub articles shown there are not American South).

The site has no Mindful Voices filter on the region list. Venue pages show a section headed "MINDFUL VOICES". I found 6:

| Venue | City, State | 2026 category | Person named | URL |
|---|---|---|---|---|
| Uberto Restaurant | Gay, GA | One Star | Ryan Smith | https://guide.michelin.com/us/en/georgia/guy_7770503/restaurant/uberto-restaurant |
| Restaurant Constance | Charlotte, NC | Selected | Sam Diminich | https://guide.michelin.com/us/en/north-carolina/charlotte_2987283/restaurant/restaurant-constance |
| Bacchanalia | Atlanta, GA | One Star | Anne Quatrano | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/bacchanalia-1196004 |
| January | Franklin, TN | Selected | Nate Leonard | https://guide.michelin.com/us/en/tennessee/franklin_2789448/restaurant/january |
| Luminosa | Asheville, NC | Bib Gourmand | Graham House | https://guide.michelin.com/us/en/north-carolina/asheville_2147494/restaurant/luminosa |
| THE CHASTAIN | Atlanta, GA | Selected | Christopher Grossman | https://guide.michelin.com/us/en/georgia/atlanta_2884144/restaurant/the-chastain |

I did not open all 265 venue pages. The 6 found equal the press release count.

2025 Green Stars (from the 2025 star article) in 2026:

| 2025 Green Star | 2026 sustainability mark on venue page |
|---|---|
| Bacchanalia (Atlanta) | Yes — MINDFUL VOICES section |
| Counter (Charlotte) | **No** — no MINDFUL VOICES section — https://guide.michelin.com/us/en/north-carolina/charlotte_2987283/restaurant/counter |
| January (Franklin, TN) | Yes — MINDFUL VOICES section |
| Luminosa (Asheville) | Yes — MINDFUL VOICES section |
| The Chastain (Atlanta) | Yes — MINDFUL VOICES section (card name "THE CHASTAIN") |

No 2026 page shows a Green Star distinction. Each page shows a generic related-article tag "Green Star Community"; this is not a distinction.

### Special awards (press release: https://www.michelin.com/en/publications/products-and-services/new-michelin-starred-restaurants-shine-across-the-american-south)

| Award | Person | Venue | City, State | Venue URL | In today's star or Bib list? |
|---|---|---|---|---|---|
| Exceptional Cocktails | Ally Bowen (release). The guide article says "Allison Bowen", bar manager: https://guide.michelin.com/us/en/article/michelin-guide-ceremony/miscellanea-spirit-house-oxford-michelin-guide-cocktails-award | Miscellanea Spirit House | Oxford, MS | https://guide.michelin.com/us/en/mississippi/oxford_2919729/restaurant/miscellanea-spirit-house | Yes — Bib Gourmand |
| Sommelier (sponsored by Franciacorta) | William Mellon | manna | Wilmington, NC | https://guide.michelin.com/us/en/north-carolina/wilmington_2148854/restaurant/manna-1241839 | No — Selected |
| Outstanding Service (sponsored by Capital One) | Jared Patterson | Little Betty Steak Bar | Mountain Brook, AL | https://guide.michelin.com/us/en/alabama/mountain-brook_2870462/restaurant/little-betty-steak-bar | No — Selected |
| Young Chef / Culinary Professional (sponsored by OpenTable) | Héctor González-Mora | The Story of "Mi Cariño" | Charlotte, NC | https://guide.michelin.com/us/en/north-carolina/charlotte_2987283/restaurant/the-story-of-mi-carino | Yes — Bib Gourmand |

---

## 11. Distinction filter and totals

Full Distinction filter text on https://guide.michelin.com/us/en/area-usa-american-south/restaurants:

> Distinction — 2 Stars Excellent cooking **1** · 1 Star High quality cooking **21** · Bib Gourmand Good quality, good value cooking **59** · Selected Restaurants Good cooking **184**

No 3 Stars option. No Mindful Voices option.

- **Selected = 184. Total = 265** (1 + 21 + 59 + 184; also the region banner "1-48 of 265 restaurants" and the sum of the seven state banners).
- The michelin.com release says 266 total and 185 Recommended. The site shows 265 and 184, the same as the second copy of the release (travelprnews.com, as given in the brief). The difference is one Selected restaurant. Star and Bib counts agree everywhere.

---

## 12. Hashes

Block hashes (SHA-256 of sorted lines joined with `\n`; line = path after `/us/en/`, name, city, state, price, tab-separated). Each was computed in the browser and checked again in my workspace.

| Block | Rows | SHA-256 |
|---|---|---|
| two_b0 (Two Stars) | 1 | c159ded5d8938ff025ac01fe10b775e2db6f237bb377628dae321d54d20baaa1 |
| one_b0 (One Star 1–12) | 12 | 8123201ce23c43b828a4ea819996ab53d57bf2fb79e759920a5f5cd2b8ba5c35 |
| one_b1 (One Star 13–21) | 9 | ed39e40e36ffa21beecd730328ad100f92ab08414a34cad5e2f68c3546178007 |
| bib1_b0 (Bib p1, 1–12) | 12 | f80fc27a5c88952585a450702e6ef8ead0c664af860de890c509e0ce5f2ad16c |
| bib1_b1 (Bib p1, 13–24) | 12 | 03966f684e7a6df4853020d7f595e3398e4330496731058606fd8c0e8021c7d1 |
| bib1_b2 (Bib p1, 25–36) | 12 | 90df3632f9064c637304b1d0b825c1a592f49b576eee35bb1c4d64b837221c2c |
| bib1_b3 (Bib p1, 37–48) | 12 | d976b3d4d58950b51e306959fe64fd2e5a96d0a777152b4f22bee737f933e4d2 |
| bib2_b0 (Bib p2, 1–11) | 11 | dd91db9fc51b9c26f110d05ded843b2b9612dee538485ad90c144277a0c76bd0 |

Full data (all 81 lines, sorted, joined with `\n`): **a2e18576b0022e857f92661748052f8b63ecbe5b92c6d2d4d0bae2b6ea6181a0**

Final CSV `michelin-2026-american-south.csv` (UTF-8, LF line endings, 82 lines with header): **109075a5fb349ba9d86dfef3beb41433f27937193b8aa5c4e56c6f25901b07f3**

The CSV was built with code from the verified blocks. Row order: Two Stars, One Star, Bib Gourmand; inside each, by URL path. Non-ASCII names kept as printed: Emeril’s, Mujō, Malagón Mercado y Taperia, La Fête, Domilise’s Po-Boy & Bar, The Story of "Mi Cariño", Okàn. No URL path has a non-ASCII character, so no percent-encoding was needed.
