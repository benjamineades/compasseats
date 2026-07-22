# CompassEats — Guide Descriptions
**Website-ready copy · v1.3 · July 22, 2026 (humanizer pass + watch-list expansion)**

Plain-language write-ups for every award source in the site registry, plus sources on the backlog and the watch list. Voice: the well-traveled friend. Facts lead, wit seasons. Each source gets 3 to 6 sentences; each category gets 1 to 2.

**Category one-liners double as award-badge tooltip text.** Each must stand alone and make sense out of context.

**Publishing rule:** nothing in Part 2 or Part 3 goes on the site until that source has actually been ingested and has a slug in `AWARD_SOURCES`. Copy sitting here is inventory, not live content.

**Prose standard:** no em dashes, no "not X but Y" reframes, no hardcoded live counts that go stale. Describe rarity structurally instead.

---

## PART 1 — SOURCES ON THE SITE TODAY

These 28 slugs exist in `AWARD_SOURCES` in `schema.ts`. This is the only section cleared for publishing.

### Michelin Guide
`michelin`

The oldest and most famous restaurant rating in the world, published since the early 1900s by a French tire company that wanted motorists driving farther and wearing out more rubber. That part isn't a joke. The method hasn't changed much since: anonymous inspectors book under fake names, pay their own bills, and come back several times before they decide anything. Stars go to the food. Ingredients, technique, how the flavors hold together, whether the kitchen does it again next Tuesday. The room and the chef's reputation don't count. One star can fill a book for years, which is why chefs both chase this guide and dread it.

**Categories:**
- **Three Stars ★★★** — Michelin's own words: "exceptional cuisine, worth a special journey." In practice, get on a plane. Only a small number of restaurants worldwide hold three stars at any given moment.
- **Two Stars ★★** — "Excellent cooking, worth a detour." Deeply skilled kitchens sitting one step below the top.
- **One Star ★** — "High-quality cooking, worth a stop." Sounds modest until you learn most chefs work a whole career without getting one.
- **Bib Gourmand** — Michelin's value award, for genuinely good cooking at a fair price. No stars, no formality. It's where the inspectors eat on their day off.
- **Selected (The Plate)** — Restaurants the inspectors recommend without a star or a Bib. Appearing in the Guide at all means Michelin vouches for the place.
- **Green Star** — A separate award for restaurants doing serious work on sustainability, from sourcing through waste.

### World's 50 Best Restaurants
`worlds-50-best-restaurants` · `worlds-50-best-restaurants-51-100`

An annual ranked list of the fifty best restaurants on Earth, running since 2002. More than 1,000 chefs, food writers, and well-traveled diners vote, each naming the best meals of their recent travels. The result tracks momentum: which kitchens are setting the direction right now. It's revealed at a ceremony with real Oscar-night energy, and a high placing fills a reservation book for roughly the rest of recorded time.

**Categories:**
- **Top 50 (ranked)** — The main list. Fifty restaurants ranked No. 1 through No. 50 by academy vote.
- **51–100** — The extended list below the cut. "Only" the 73rd best restaurant on the planet is still a very good dinner.

### Asia's 50 Best Restaurants
`asia-50-best-restaurants` · `asia-50-best-restaurants-51-100`

Running since 2013, using the same voting model as the global list with a regional academy. The authority on the continent's most exciting dining, from Tokyo counters to Bangkok tasting menus.

**Categories:**
- **Top 50 (ranked)** — Asia's fifty best restaurants, ranked by regional academy vote.
- **51–100** — The extended Asian ranking.

### Latin America's 50 Best Restaurants
`latin-america-50-best-restaurants`

Also running since 2013, covering a region that produced some of this century's most influential kitchens.

**Categories:**
- **Top 50 (ranked)** — Latin America's fifty best restaurants, ranked by regional academy vote.

### Middle East & North Africa's 50 Best Restaurants
`mena-50-best-restaurants`

Launched in 2022, right around the time the region's dining scene stopped being a secret.

**Categories:**
- **Top 50 (ranked)** — The region's fifty best restaurants, ranked by regional academy vote.

### North America's 50 Best Restaurants
`north-america-50-best-restaurants`

The newest restaurant edition, bringing the same voting model to North America.

**Categories:**
- **Top 50 (ranked)** — North America's fifty best restaurants, ranked by regional academy vote.

### Africa's 50 Best Restaurants
`africa-50-best-restaurants`

*(No description. This is a roadmap slug with no corresponding real list. See Flags.)*

### World's 50 Best Bars
`worlds-50-best-bars` · `worlds-50-best-bars-51-100`

The annual ranking of the world's greatest cocktail bars, published since 2009 by the same organization behind World's 50 Best Restaurants. Hundreds of bartenders, drinks writers, and dedicated regulars vote on the best bar experiences of their year. Grand hotel institutions, ten-seat hidden rooms, everything in between. A place on this list means the drinks are worth crossing a city for, and possibly an ocean.

**Categories:**
- **Top 50 (ranked)** — The fifty best bars in the world by academy vote. The top ten fill up almost overnight.
- **51–100** — The extended ranking. Bars sitting just outside the top 50.

### Asia's 50 Best Bars
`asia-50-best-bars` · `asia-50-best-bars-51-100`

Published since 2016, covering the region that turned Singapore and Hong Kong into cocktail capitals.

**Categories:**
- **Top 50 (ranked)** — Asia's fifty best bars, ranked by regional academy vote.
- **51–100** — The extended Asian ranking.

### North America's 50 Best Bars
`north-america-50-best-bars` · `north-america-50-best-bars-51-100`

Launched in 2022 for the US, Canada, Mexico, and the Caribbean.

**Categories:**
- **Top 50 (ranked)** — North America's fifty best bars, ranked by regional academy vote.
- **51–100** — The extended North American ranking.

### Europe's 50 Best Bars
`europe-50-best-bars`

The newest regional list, first awarded in 2026 at a ceremony in Amsterdam. The continent that invented much of bar culture finally has its own scoreboard.

**Categories:**
- **Top 50 (ranked)** — Europe's fifty best bars, ranked by regional academy vote.

### Top 500 Bars
`top-500-bars`

A global ranking of the 500 most influential cocktail bars in the world, built by algorithm rather than by panel. Founded by Anthony Poncier and first published in 2019, it came out of a complaint bartenders kept repeating: the same handful of bars win everything, partly because no human jury can realistically visit hundreds of bars a year. Top 500 Bars answers that by aggregating over 2,000 sources in more than 20 languages, including expert and journalist coverage, other industry rankings, review platforms, social media, and search data. The word worth holding onto is influential, because that's what the model actually measures. The 2025 edition covered 125 cities across 53 countries, so it works as a travel list as much as a leaderboard.

**Categories:**
- **Ranked 1–500** — A numerical world ranking of the most influential cocktail bars. The top 100 are revealed at an annual ceremony, and any placing at all puts a bar among the most talked-about on the planet.

### James Beard Awards
`james-beard`

America's most prestigious food honors, presented since 1991 by the foundation named for James Beard, the cookbook author who spent a lifetime arguing that American cooking deserved to be taken seriously. People call them the Oscars of American food, and in this case there really are medallions. Chefs, restaurants, and bars across the US go through several rounds of nomination and voting by a large body of independent judges. A Beard medallion by the door is one of the surest signs in America that you've picked well.

**Categories:**
- **Outstanding Restaurant** — The top honor for a single restaurant that has been excellent for years and shows no sign of stopping.
- **Outstanding Chef** — The highest individual honor in American cooking. "Career-defining" undersells it.
- **Best Chef (by region)** — The finest chef in each US region. Very often the award that turns a local favorite into a national reservation problem.
- **Outstanding Bar** — A bar with exceptional drinks, hospitality, and atmosphere, judged as seriously as any kitchen.
- **Best New Restaurant** — The country's most impressive opening of the past year.
- **America's Classics** — Beloved, often family-run institutions. The diners, barbecue joints, and neighborhood legends no amount of money could recreate.

### The Best Chef Awards
`best-chef-awards`

A global award for the chef rather than the restaurant, voted on by a large body of chefs and food experts around the world. Since half the voters are chefs themselves, this is the profession grading its own work, and it does not grade gently. Founded in the mid-2010s, it dropped its single ranked top-100 in 2024 for a tiered knife system while still crowning one Best Chef each year. It's the clearest read available on who the people working the line actually admire.

**Categories:**
- **Three Knives** — The top tier. Chefs their own peers rank among the very best in the world.
- **Two Knives** — Chefs of outstanding international standing.
- **One Knife** — Excellence recognized on the world stage. A knife at any tier means the profession has noticed.

### Spirited Awards
`spirited-awards`

The bar world's most prestigious honors, presented since 2007 by the Tales of the Cocktail Foundation at its annual gathering in New Orleans, the industry's biggest event and a famously thirsty week. Winners come out of several rounds of voting by more than a hundred bartenders, writers, and drinks professionals. These awards measure the respect of the people working behind the bar, which is a hard thing to fake.

**Categories:**
- **World's Best Bar** — The top international honor a bar can get from its own industry, which is the toughest crowd there is.
- **Best US Bar / Best International Bar** — The finest bars inside and outside the United States, judged separately.
- **Best New Bar** — The most impressive opening of the year, in US and international editions.
- **Best Cocktail Menu / Best Bar Team** — Craft honors for the drinks list and the people pouring it.

### The Pinnacle Guide
`pinnacle-guide`

The newest serious accolade in the bar world, founded by the team behind London Cocktail Week and often described as Michelin stars for cocktail bars. The process backs the comparison up. Bars apply through an open process, get assessed across detailed criteria covering the drinks, the hospitality, the room, staff welfare, and sustainability, then receive several anonymous in-person visits before any PIN is awarded. PINs last two years and then have to be earned again. Of the hundreds of pinned bars, only a small handful ever reach three.

**Categories:**
- **One PIN** — An excellent cocktail bar, verified by anonymous reviewers.
- **Two PINs** — An outstanding cocktail bar, a clear step above.
- **Three PINs** — The guide's highest and rarest honor, held by only a select few of all pinned bars.

### OAD (Opinionated About Dining)
`oad`

A restaurant ranking built from surveys of thousands of the world's most frequent fine diners, the sort of people who fly to another country for lunch and consider it a reasonable Tuesday. Votes are weighted by how much the reviewer has eaten, so the most traveled palates count most. Because those voters eat constantly and everywhere, OAD tends to surface excellent restaurants years ahead of the bigger guides. Its European lists carry particular weight.

**Categories:**
- **Ranked lists (by region)** — Restaurants ranked numerically within regional lists such as the European Top 100+, shown as "No. 42 · OAD". The lower the number, the stronger the verdict from the world's most seasoned diners.

### La Liste
`la-liste`

A French ranking, published annually since 2015, built on one idea: ask every guide at once. La Liste aggregates hundreds of guidebooks and millions of published reviews from around the world into a single score out of 100 per restaurant, then ranks the global top 1,000. A high score means a restaurant satisfies everyone's standards at the same time, which is about as close as food gets to a unanimous decision.

**Categories:**
- **Score out of 100** — A restaurant's aggregate standing across the world's guides and reviews. The high 90s is where the arguments stop.

### World's 101 Best Steak Restaurants
`101-best-steakhouses`

*(Slug retained for URL and data stability. Display name changed. See Flags.)*

The specialist authority on one gloriously focused question: where is the best steak on Earth? Founded in London in 2018 by Ekkehard Knobelspies and published by Upper Cut Media House, it sends anonymous inspectors, called Steak Ambassadors, to eat their way through every candidate. They judge the quality and provenance of the meat, the range of cuts, the wine program, the design, and the service. Each of the 101 named restaurants gets visited once or twice a year by the ambassador responsible for its country. Useful when the mission is beef and the mission is serious.

**Categories:**
- **Ranked 1–101** — A numerical world ranking. Any spot on it marks one of the finest steak restaurants on the planet, and the top ten are worth planning a trip around.
- **Hall of Fire** — A separate honor for restaurants whose influence goes beyond a single year's list. Parrilla Don Julio in Buenos Aires entered it after three consecutive years at No. 1.

### Gault & Millau
`gault-millau`

France's other great restaurant guide, founded in 1965 by critics Henri Gault and Christian Millau, who thought French food had gotten heavy and said so loudly. They championed the lighter, more inventive style that became nouvelle cuisine. Anonymous reviewers score restaurants out of 20 and award one to five toques, the chef's hats, judging the talent and creativity in the kitchen rather than the thickness of the carpet. Across France and much of Europe, a young chef's first toque is often the earliest reliable sign that a star is being born.

**Categories:**
- **Toques (1–5)** — Chef's hats tracking the kitchen's score out of 20. Four and five toques mark the very finest kitchens. A perfect 20 is nearly mythical.

### Tabelog
`tabelog`

Japan's most trusted restaurant resource, a review platform used by millions of Japanese diners with a famously strict algorithm that weights credible, experienced reviewers most heavily. Scores run out of 5 and the curve is merciless. Crossing 3.5 already puts a restaurant in the top few percent nationwide, and 4.0 is rare air. The annual Tabelog Award, split into Gold, Silver, and Bronze, picks out the country's absolute best and promptly makes them nearly impossible to book.

**Categories:**
- **Tabelog Award, Gold** — The top tier of Japan's annual best-restaurant selection. Getting a table is a competitive sport.
- **Tabelog Award, Silver** — The second tier, still an elite national distinction.
- **Tabelog Award, Bronze** — The third tier, marking a restaurant among Japan's finest. In a country this good at food, that's saying plenty.

### Forbes Travel Guide
`forbes-travel-guide`

The company that invented the five-star rating, inspecting hotels and restaurants since 1958 under its original name, the Mobil Travel Guide, and spending the decades since making sure the stars still mean something. Its professional inspectors arrive anonymously, pay their own way, and grade against hundreds of exacting service standards, down to details you'd never consciously notice but would absolutely feel. Forbes rates the complete experience rather than the plate alone, so a Forbes star points to hospitality that holds up from the moment the door opens.

**Categories:**
- **Five-Star** — A flawless, world-class experience and the guide's highest honor. The inspectors checked everything and it all passed.
- **Four-Star** — Exceptional quality and service, just short of the summit.
- **Recommended** — Consistently excellent places the inspectors are confident sending you to.

### Wine Spectator Restaurant Awards
`wine-spectator`

The global standard for restaurant wine programs, awarded by Wine Spectator magazine since 1981. It judges the cellar, not the kitchen, which makes it a good complement to the food-first guides and explains why sommeliers keep these plaques polished. Three tiers run from a well-chosen list up to the Grand Award's vast, deep cellars. A Grand Award restaurant is a destination for the wine list every bit as much as the cooking.

**Categories:**
- **Grand Award** — The highest honor, for the world's greatest wine programs. Only a very small number of restaurants worldwide hold one.
- **Best of Award of Excellence** — Extensive lists with real depth and breadth.
- **Award of Excellence** — Well-chosen lists that pair thoughtfully with the menu.

---

## PART 2 — VERIFIED, AWAITING INGEST

Copy is written and fact-checked. These sources have no slug in `AWARD_SOURCES` yet. **Do not publish until ingested.**

### Gambero Rosso (Ristoranti d'Italia)
*Italy · tier B · core*

Italy's most influential food authority, publishing its restaurant guide since the 1980s. When Italians rank Italian food, the rest of the world tends to pay attention. Its critics score restaurants on a points scale, and the top honor, the Tre Forchette, is Italy's homegrown answer to three Michelin stars. Because the judges are Italian critics assessing Italian cooking, plenty of insiders treat it as the truer measure of the country's kitchens.

**Categories:**
- **Tre Forchette (Three Forks)** — The guide's highest rating and Italy's most coveted domestic honor, awarded by the toughest possible audience.
- **Due Forchette / Una Forchetta (Two Forks / One Fork)** — Excellent and very good restaurants respectively, on Gambero Rosso's points scale.

### Guía Repsol
*Spain · tier B · core*

Spain's beloved national restaurant guide, awarding Soles since 1979. A Sol is the Spanish counterpart to a Michelin star, handed out by Spanish gastronomy experts who know exactly what a great tortilla should taste like. Three Soles carries enormous weight at home. The guide also has a knack for celebrating deeply Spanish cooking that international guides tend to drive straight past.

**Categories:**
- **Tres Soles (Three Suns)** — The guide's highest honor, reserved for Spain's greatest restaurants.
- **Dos Soles / Un Sol (Two Suns / One Sun)** — Outstanding and excellent restaurants respectively.

### AA Rosettes
*UK & Ireland · tier B · core*

The longest-running restaurant award in the UK and Ireland, given by the AA's professional inspectors since 1956. Yes, the roadside-assistance people, which is a charming echo of Michelin's tire-company origins. Rosettes run from one to five, with four and five reserved for cooking that stands comparison with the best in the world. Five-Rosette restaurants are nearly as rare in Britain as three-star ones.

**Categories:**
- **Five / Four Rosettes** — Cooking that stands with the very best in the British Isles.
- **Three Rosettes** — Outstanding restaurants worth traveling well out of your way for.
- **One–Two Rosettes** — Excellent restaurants hitting consistently high standards.

### The Good Food Guide (UK)
*United Kingdom · tier B · core*

Britain's longest-running restaurant guide, founded in 1951 by Raymond Postgate, who was so appalled by post-war British food that he recruited volunteers to inspect restaurants and report back. It still runs on anonymous inspectors who book like ordinary guests and pay their own bills, with no freebies. Owned since 2021 by Knife & Fork Media, it moved to a digital, paid model. Getting into the Guide is a long-standing benchmark of British dining.

**Categories:**
- **Scored entry (out of 10)** — Restaurants are rated on a scale where a 10 means faultless technique and is extremely rare.
- **Top 50** — The guide's selection of the very best restaurants in Britain for the year.
- **Best Local Restaurant** — Annual awards for independent, chef- or proprietor-run neighborhood restaurants, decided with reader nominations and inspector visits.

> **Ingest note:** since 2024 the Guide no longer orders its top restaurants numerically. Treat this as an unranked, category-based source. Do not populate `rank`.

### Good Food Guide Chef Hats (Australia)
*Australia · tier B · core*

Australia's defining restaurant honor, awarded by the Good Food Guide's critics for decades. Restaurants earn one, two, or three Chef Hats. Australians treat hats the way Europeans treat stars, arguments included. A three-hatted restaurant sits at the top of one of the world's most underrated dining scenes.

**Categories:**
- **Three Hats** — The top of Australian dining.
- **Two Hats** — Excellent restaurants of national standing.
- **One Hat** — A serious distinction, marking one of the best rooms in its city.

### AAA Diamonds
*US / Canada / Mexico / Caribbean · tier B · core · restaurants only*

North America's long-running hospitality rating, with professional inspectors evaluating restaurants and hotels across the US, Canada, Mexico, and the Caribbean. Places earn one to five Diamonds. Five Diamonds is the rarest tier, held by a fraction of one percent of everything AAA rates, and it signals food and service operating at a world-class level.

**Categories:**
- **Five Diamond** — The rarest tier. Cuisine at the highest level and service so attentive it borders on telepathy.
- **Four Diamond** — Distinctive fine dining with refined service and ambiance.

### Black Pearl Restaurant Guide
*China · tier B · core*

Published by Meituan, the Chinese tech company behind the country's biggest food-delivery and review platforms, the Black Pearl launched in 2018 as a domestic answer to Michelin. Anonymous judges score restaurants on cooking, dining experience, and what the guide calls heritage and innovation, with the panel's verdict blended against usage data from Meituan and Dianping. The 2025 edition covered 370 restaurants across 34 cities, including Bangkok, Tokyo, and Singapore. Winning marks a restaurant as one of China's most respected, judged by Chinese standards rather than imported ones.

**Categories:**
- **Three Diamond (三钻)** — The top tier. A restaurant worth planning a once-in-a-lifetime meal around.
- **Two Diamond (二钻)** — A restaurant worth marking a special occasion at.
- **One Diamond (一钻)** — A restaurant recommended for gatherings and celebrations.

### Blue Ribbon Survey
*South Korea · tier B · core*

South Korea's first restaurant guide, published since 2005 by BR Media and widely treated as the country's homegrown counterpart to Michelin. It works in two steps: gather a large volume of public and reader opinion as the objective base, then layer expert assessment on top. Coverage started in Seoul and now runs nationwide through Busan, Jeju, and the provinces, listing well over a thousand places a year across fine dining, cafés, and casual eateries. A blue ribbon is a real mark of standing in Korean dining.

**Categories:**
- **Three Ribbons** — The highest rating, for a restaurant showing the most outstanding skill in its field nationally.
- **Two Ribbons** — An excellent restaurant, a step below the very top.
- **One Ribbon** — A recommended restaurant worth seeking out.

### White Guide
*Nordics · tier B · core*

The Nordic region's main restaurant guide, running since 2005 across Denmark, Finland, Iceland, Norway, and Sweden. It's an editorial product with signed reviews and trend reporting, assessing several hundred restaurants a year rather than a short list. Reviewers score on a points scale that sorts restaurants into named quality levels, and the best land on an elite Nordic top list. A high White Guide placing is one of the most credible signals in Scandinavian dining.

**Categories:**
- **Top 30 Nordic List** — The elite ranking of the best restaurants across all five Nordic countries.
- **Master Class / Very Fine / Fine** — Descending quality bands assigned from the guide's points score, marking a restaurant's overall standing.

### Falstaff
*Austria / Germany / Switzerland · tier C · core*

The restaurant guide from the Austrian food and wine magazine Falstaff, covering the German-speaking world. Its defining feature is scale. Ratings come from a large community of registered members rather than a handful of professional inspectors, on the argument that many real paying-guest impressions build a clearer picture than a few expert visits. The Austria 2026 guide drew on over 120,000 reviews of 2,050 establishments. Restaurants are scored out of 100 and awarded forks, and it's one of the most consulted guides in the DACH region.

**Categories:**
- **100 points** — The top score, reached by only a handful of restaurants in any edition.
- **Forks (Gabeln)** — Restaurants earn up to four forks based on their points total, marking overall class.

### Cuisine Good Food Awards
*New Zealand · tier B · core*

New Zealand's benchmark restaurant awards, run by Cuisine magazine with more than two decades of history. A national panel of food writers, critics, chefs, and hospitality professionals reviews restaurants anonymously and pays for its meals. Restaurants are scored out of 20, and those clearing the bar earn one, two, or three hats. Three hats requires a 19 or 20 and is treated as approaching perfection.

**Categories:**
- **Three Hats** — The highest award, a score of 19 or 20 out of 20, placing a restaurant among the country's best.
- **Two Hats** — An outstanding restaurant, well above the hat threshold.
- **One Hat** — A restaurant judged among the best in New Zealand.
- **Cuisine Destination** — A separate listing for strong restaurants that scored just below the hat cutoff.

### Eat Out Awards
*South Africa · tier B · core*

South Africa's leading restaurant awards. Over roughly eight months, a panel of anonymous independent judges visits shortlisted restaurants several times across peak and quiet periods, scoring out of 100 on food, service, ambience, and value. The result is a star system the awards call the country's gold standard. Winning a star is a headline event for a South African restaurant.

**Categories:**
- **Three Stars** — For restaurants scoring above 90 out of 100. The top of South African dining.
- **Two Stars** — For restaurants scoring between 80 and 89.
- **One Star** — For restaurants scoring between 70 and 79, still a rare distinction.
- **Restaurant of the Year** — The single highest-scoring restaurant in the country.

### Summum
*Peru · tier B · core*

Peru's national dining awards, created in 2007 and sometimes called the Oscars of Peruvian gastronomy. Its signature feature is an official survey run by the pollster IPSOS across a large panel of diners, with certain categories decided by specialist juries instead. It covers the whole chain of Peruvian cooking, from top kitchens to producers. A Summum win is national recognition inside one of the world's most celebrated food cultures.

**Categories:**
- **Ranking of best restaurants** — The headline list of Peru's top restaurants, decided by the IPSOS diner survey.
- **Specialist-jury categories** — Awards such as best chef and best cuisine type, decided by expert juries.

### Les Grandes Tables du Monde
*Global · tier C · core*

A membership association of elite restaurants rather than an inspection guide, tracing back to 1954 when six legendary French restaurateurs, from Taillevent, La Tour d'Argent, Maxim's and others, formed a group called Traditions et Qualité. Restaurants are invited and vetted rather than scored anonymously. As of its 2025 congress in Athens the association counted 206 member restaurants across 28 countries. Membership signals a place among a small, self-selected circle of the world's classic haute-cuisine houses.

**Categories:**
- **Member restaurant** — An invited, vetted place on the association's global roster.

> **Ingest note:** membership, not an inspection award. Worth surfacing differently from scored guides, and worth a plain-language note on the venue page so readers aren't misled about what it measures.

### SCMP 100 Top Tables
*Hong Kong / Macau / Greater Bay Area · tier C · undecided*

The fine-dining guide published by the South China Morning Post, Hong Kong's main English-language newspaper, first out in 2012. It's judged by the paper's own food and drink writers rather than by public vote, and it isn't pay-to-enter. Coverage centers on Hong Kong and Macau and has recently expanded into Greater Bay Area cities like Shenzhen and Guangzhou, with a bars section alongside the restaurants.

**Categories:**
- **100 Top Tables listing** — Selection as one of the region's best fine-dining restaurants, chosen by the paper's critics.
- **Best of the best** — Individual honors such as Best Chef, Best New Restaurant, and Best New Bar.

### Tatler Dining Awards
*Asia (HK / SG / PH / TW and others) · tier C · undecided*

The dining awards from Tatler's Asia editions, with a guide history reaching back to the 1980s. Winners come from a pool of restaurants reviewed by Tatler's editors and reviewers, and the wider Tatler Best program uses a jury of hundreds of regional panellists. Tatler states the awards are not pay-to-play. Across Hong Kong, Singapore, and other Asian markets a Tatler nod is a marker of prestige dining.

**Categories:**
- **Tatler Dining 20** — An unranked list of a market's most impactful restaurants for the year.
- **Best in Class** — Individual awards such as Restaurant of the Year, Best New Restaurant, and Best Service.

### Star Wine List
*Global · tier C · undecided · wine programs*

An awards program and guide focused entirely on restaurant and wine-bar lists, founded in Sweden by Krister Bengtsson, with the platform launching in 2017 and the awards in 2018. What sets it apart is who judges: panels of top sommeliers, many of them past or current national and world champions. It runs country events across many markets feeding into an annual global final. It judges the wine program, not the kitchen.

**Categories:**
- **Grand Prix** — The overall best wine list in the global final.
- **Gold Star** — The top award in a market or category, for the very best lists.
- **Category awards** — Prizes for specific strengths, such as best list for a given wine region or best by-the-glass selection.

### We're Smart Green Guide
*Global · tier C · undecided*

A guide ranking the world's best vegetable- and fruit-focused restaurants, created by the Belgian chef Frank Fol, known as The Vegetable Chef. Its rating unit is the radish, awarded one to five based on how much of the menu is fruit and vegetables, plus creativity, seasonality, and sustainability. It reviews around 1,300 restaurants across 51 countries. It's the main global reference for vegetable-forward cooking.

**Categories:**
- **Five Radishes** — The top rating, for a pure-plant pioneer working in genuinely new territory.
- **Four Radishes** — An extraordinary vegetable restaurant, fundamentally creative.
- **Three Radishes** — A vegetable-forward restaurant with extra focus on sustainability.
- **Two Radishes** — A vegetable ambassador offering surprising fruit and vegetable dishes.
- **One Radish** — A traditional restaurant evolving toward exceptional vegetable cooking.

### L'Espresso (Guida Ristoranti)
*Italy · tier C · sister*

One of Italy's established restaurant guides, published under the L'Espresso name with more than four decades behind it and reviewed by a team of inspectors. Its rating symbol is the cappello, the chef's hat, awarded on a points scale, and the guide recently tightened its selection to focus on a smaller field of top restaurants. A recent addition is the Cappelli d'Oro for restaurants treated as modern classics of Italian cooking.

**Categories:**
- **Five Cappelli** — The top rating, for Italy's very best restaurants. A select few score a perfect 20 out of 20.
- **Cappelli d'Oro (Golden Hats)** — A special honor for restaurants that have become classics in the history of Italian cuisine.
- **One to Four Cappelli** — Ascending quality ratings assigned from the guide's points score.

### Identità Golose
*Italy · tier C · undecided*

An Italian gastronomy brand built around the Identità Golose congress, the first Italian conference of chef-driven cooking, launched in Milan in 2005 from an idea by the journalist Paolo Marchi. Alongside the congress it publishes online restaurant guides, including a dedicated Pizza & Cocktail guide, and runs a year-round events hub in central Milan. It works as much as a movement and meeting point for chefs as a listing.

**Categories:**
- **Guide listing** — Selection in one of Identità Golose's online restaurant guides.
- **Pizza & Cocktail guide** — A dedicated selection recognizing notable pizzerias and cocktail venues.

### Guide Lebey
*France (Paris) · tier C · undecided*

A Paris restaurant guide founded in 1987 by Claude Lebey, covering restaurants, bistros, and cocktail bars across the city and its suburbs. It built its reputation on independence: incognito visits, paying the bill, no advertising influence. Lebey sold the brand in 2011 and the guide has moved between print and digital since, recently returning to print. Among Parisian food insiders it's a trusted, opinionated address book.

**Categories:**
- **Guide listing** — Selection among the best restaurants, bistros, and cocktail bars of Paris and its suburbs.
- **Palmarès** — Yearly awards such as best chef, best bistro, and best brasserie.

### Irish Restaurant Awards
*Ireland · tier B · undecided*

Ireland's national restaurant awards, running annually since 2010. The process starts with a large public online vote, moves to a judging stage with national experts, then to regional events across the four provinces where county winners are named, building to an all-Ireland final. Winning is a significant boost for an Irish restaurant in any county or category.

**Categories:**
- **All-Ireland winners** — The top national awards across categories, announced at the final.
- **County and Regional winners** — Local winners named across Ireland's counties and four provinces.

### 50 Top Italy
*Italy · tier C · sister*

A guide ranking the best Italian restaurants in Italy and abroad, built as ranked lists rather than a star system. It splits its main selection into grand restaurants and modern trattorias and bistros, and adds themed awards each year for specific formats, such as best plant-based bistros and best restaurants under 100 euros.

**Categories:**
- **Grandi Ristoranti** — The main ranked list of top Italian fine-dining restaurants.
- **Trattorie e Bistrò Moderni** — A ranked list of the best modern trattorias and bistros.
- **Themed awards** — Annual prizes for specific categories and price bands.

### La Liste Pastry
*Global · tier B · sister*

La Liste applies its aggregation method to pastry shops. It pools over 1,100 recognized sources, media outlets, institutions, and digital platforms, plus millions of online reviews, into a single score out of 100, with customer reviews weighted at roughly 10 percent. Because it aggregates existing critics rather than sending its own inspectors, a top score reflects broad consensus across many judges at once.

**Categories:**
- **Ranked pastry shops (scored)** — Pastry shops ranked by an aggregated score out of 100.

### VEJA Comer & Beber
*Brazil · tier D · core*

The annual dining awards of the city guides published by VEJA, the Brazilian weekly newsmagazine. Comer & Beber is a long-standing fixture in São Paulo and other Brazilian cities, naming winners across many restaurant and bar categories.

**Categories:**
- **Category winners** — Best-in-class awards across restaurant and bar types in each city edition.

### Pizza Today
*United States · tier C · sister*

Pizza Today is a US trade magazine for the pizzeria business, and its awards recognize pizzeria businesses and their operators rather than individual cooks. The PIE Awards launched in 2023 and are judged by application across operations, marketing, and community work, while Pizzeria of the Year and the Hot 100 are editorial selections. Because the honors attach to the business, they map cleanly onto a venue.

**Categories:**
- **Pizzeria of the Year** — A single national honoree recognized as the year's standout pizzeria business.
- **PIE Awards** — Business awards across categories such as regional best pizza company and pizza chain of the year.
- **Hot 100** — A ranking of the top-grossing independent pizzerias in the United States.

### World Beer Cup
*Global · tier A · sister · breweries*

Run by the Brewers Association, the US craft-brewing trade body, the World Beer Cup started in 1996 and gets called the Olympics of beer often enough that the name stuck. Judging is blind: the 2024 edition put 280 judges from 37 countries against 9,300 entries from more than 2,000 breweries across 110 categories, scoring on style accuracy, flavor, aroma, and appearance. It's open to commercial breweries worldwide.

**Categories:**
- **Gold / Silver / Bronze** — Medals awarded in each beer-style category.
- **Champion Brewery / Champion Brewer** — Top honors by brewery size, based on medal tally.

### Great American Beer Festival
*United States · tier A · sister · breweries*

The awards attached to the Great American Beer Festival, also run by the Brewers Association, founded in 1982 and the largest ticketed beer festival in the United States. Winners are chosen by blind professional panel against detailed style guidelines, entirely separate from the public festival floor. A GABF medal is one of the most coveted awards in American brewing.

**Categories:**
- **Gold / Silver / Bronze** — Medals for the best beers in each style category.
- **Brewery of the Year** — Top honors by brewery size, awarded on a points system across medals won.

### European Beer Star
*Europe · tier B · sister · breweries*

A competition organized since 2004 by the German association Private Brauereien, focused on beer styles of European origin though open to breweries worldwide. Judging is blind sensory panel across several rounds, and only the top three beers per category get recognized at all, following an Olympic-style principle.

**Categories:**
- **Gold / Silver / Bronze** — The only awards given, to the top three beers in each style category.
- **Consumers' Favourite** — A separate award decided by public tasting.

### International Brewing Awards
*Global (UK-based) · tier B · sister · breweries*

A British competition, formally the International Brewing & Cider Awards, run by the trade body BFBi with roots going back to 1888 and relaunched under the current name in 2011. Its distinctive feature is the jury: judging is done entirely by practising commercial brewers and cidermakers. Most entries now come from outside the UK.

**Categories:**
- **Gold / Silver / Bronze** — Medals for quality within each class of beer or cider.
- **Trophies** — Top prizes in categories such as cask ale, speciality beer, and cider.

### Australian International Beer Awards
*Global (Australia-based) · tier B · sister · breweries*

Run by Melbourne Royal, formerly the Royal Agricultural Society of Victoria, the AIBA began in 1992 and is one of the largest annual competitions judging both draught and packaged beer. Judging is blind expert panel at the Melbourne Showgrounds, with entries from around the world.

**Categories:**
- **Champion Australian Beer** — The top trophy for an Australian entry.
- **Champion International Beer** — The top trophy for an international entry.
- **Medals and category trophies** — Awards across many beer-style classes.

### TRY Ramen Awards
*Japan (Tokyo) · tier B · sister*

Tokyo's main ramen awards, published since 2000 by Kodansha under the name TRY, for Tokyo Ramen of the Year. A team of seasoned ramen judges eats across greater Tokyo through the year and votes by flavor genre, with results published each autumn in a guidebook. Criteria weight taste most heavily, alongside hospitality and how active a shop is. In Tokyo's ramen scene a TRY award moves real crowds.

**Categories:**
- **Grand Prix / Best New Shop** — The top award, for the standout new ramen shop of the year.
- **Genre rankings** — Rankings across styles such as shoyu, shio, miso, tonkotsu, and tsukemen.

### National Fish & Chip Awards
*United Kingdom · tier B · sister*

The UK's headline fish and chip awards, founded in 1988 by Seafish and run since 2022 by the National Federation of Fish Friers. Judging runs through interviews, live tasks, inspections, and anonymous taste tests before a London ceremony, and entry is free. A win can drive a serious jump in a chip shop's sales.

**Categories:**
- **Fish and Chip Shop of the Year** — The top national title for a takeaway chip shop.
- **Restaurant of the Year** — The top title for a sit-down fish and chip restaurant.
- **Specialist categories** — Awards for sustainability, staff training, and field-to-frier chips.

### Best Baguette of Paris (Grand Prix de la Baguette)
*France (Paris) · tier C · sister*

An annual competition run by the City of Paris with the Paris bakers' union, first held in 1994, to find the best traditional baguette in the city. Bakers submit loaves meeting strict rules on length, weight, and salt, and a jury of officials, professionals, journalists, and randomly chosen Parisians scores them blind on crust, crumb, hole structure, aroma, and taste. The prize is famous: the winner supplies the Élysée Palace for a year.

**Categories:**
- **Grand Prix winner** — The winning bakery, named official baguette supplier to the French presidential palace for one year.
- **Top 10 ranking** — The runners-up rounding out the year's best Paris baguettes.

### Best Croissant of Paris
*France (Paris) · tier C · sister*

The Paris bakers' union runs an annual contest for the best butter croissant of Greater Paris, made with Charentes-Poitou PDO butter and judged on lamination, texture, aroma, and taste. A separate national contest, the Meilleur Croissant au Beurre de France, runs as a live bake-off among a small field.

**Categories:**
- **Best croissant winner (Greater Paris)** — The top butter croissant of the Île-de-France region for the year, with a podium of runners-up.

> **Ingest note:** don't confuse this with Meilleure Boulangerie de France, which is an unrelated M6 television show.

### 50 Top Pizza
*Global · tier A · sister*

The world authority on pizza, published annually from Italy since 2017. If anyone was going to rank pizza with academic seriousness, it was always going to be the Italians. Anonymous inspectors judge everything from dough fermentation to service, producing ranked lists for Italy, the world, and major regions. A high placement has turned neighborhood pizzerias into international destinations, lines included.

**Categories:**
- **Ranked lists (World / Italy / regional)** — Numerical rankings of the best pizzerias on Earth. World No. 1 is pizza's most coveted title, and it gets defended fiercely.

---

## PART 3 — AWAITING RESEARCH

No copy written. The July 2026 research pass ran out of budget before reaching these, and the honesty firewall says an unverified guide gets a gap, not a guess. Known facts are recorded so the next pass starts warm.

**Nothing here goes on the site. These sources have no verified founding year, judging method, or tier names.**

| Source | Geography | Tier | Scope | What's missing |
|---|---|---|---|---|
| Gambero Rosso — Pizzerie d'Italia | Italy | B | sister | Tier names (spicchi system) unconfirmed |
| Gambero Rosso — Gelaterie d'Italia | Italy | B | sister | Tier names (coni system) unconfirmed |
| Gambero Rosso — Pane & Panettieri | Italy | B | sister | Tier names (pani system) unconfirmed |
| Gambero Rosso — Bar d'Italia | Italy | B | sister | Tier names (chicchi/tazzine system) unconfirmed |
| Pudlo Guide | France | C | undecided | Founding year, current status, tier names |
| Macarfi | Spain / Portugal | C | undecided | Everything |
| Schlemmer Atlas | Germany | C | undecided | Publisher, founding year, rating symbols |
| Der Feinschmecker | Germany | C | undecided | Judging method, tier structure |
| Varta Guide | Germany | C | undecided | Everything |
| A la Carte Guide | Austria | C | undecided | Everything |
| Lekker500 | Netherlands | C | undecided | Everything |
| Boa Cama Boa Mesa | Portugal | C | undecided | Judging method, tiers (published by Expresso) |
| Mesa Marcada | Portugal | C | undecided | Everything |
| 360 Eat Guide | Global (Nordic roots) | C | undecided | Everything |
| Guía México Gastronómico | Mexico | C | undecided | Everything |
| Prazeres da Mesa | Brazil | C | undecided | Founding year, method, tier names |
| Guía Óleo | Argentina | E | undecided | Everything. User-voted, likely fails trust gate |
| Círculo de Cronistas Gastronómicos | Chile | B | undecided | Everything |
| Gourmet Traveller Restaurant Awards | Australia | D | undecided | Everything |
| Metro Restaurant Awards | New Zealand (Auckland) | D | undecided | Everything |
| RAS Epicurean Star Awards | Singapore | B | undecided | Everything |
| National Restaurant Awards | United Kingdom | D | undecided | Exact judging method |
| Elite Traveler Top Restaurants | Global | D | undecided | Everything |
| Dianping Must Eat List | China | E | sister | Selection method and structure |
| MangoPlate Awards | South Korea | E | sister | Everything. Operating status uncertain |
| The Best Pizza Awards | Global | D | sister | Everything |
| World's 25 Best Burgers | Global | D | sister | **Existence unconfirmed.** No official URL found |
| National Burger Awards (UK) | United Kingdom | B | sister | Everything |
| The World's 100 Best Coffee Shops | Global | D | sister | Everything |
| Relais Desserts | Global (French roots) | B | sister | Everything |
| Gelato Festival World Ranking | Global | C | sister | Everything |
| Ramen Walker Grand Prix | Japan | C | sister | Founding year, official URL |

---

## FLAGS

### Africa's 50 Best Restaurants — dormant
`africa-50-best-restaurants` is a roadmap slug in the registry with no corresponding real list. 50 Best publishes no African restaurant ranking as of July 2026. No description written. The guides index already hides zero-count sources, so it's invisible on the site. Leave dormant; write copy only if the list actually launches.

### World's 101 Best Steak Restaurants — display name changed
The official source name is World's 101 Best Steak Restaurants, published by Upper Cut Media House, London. The old label "101 Best Steakhouses" was wrong.

**Change the `name` field only.** The slug `101-best-steakhouses` keys the `/award/101-best-steakhouses` URL and every `source_slug` value in the Sheet. Changing it would break both. Also check `AwardBadge.tsx` and any hardcoded label strings.

### Le Fooding — recommend OUT
Founded in 2000 by Alexandre Cammas and Emmanuel Rubin as a deliberate reaction against French fine-dining formality. Michelin bought a stake in 2017 and took full ownership around 2020.

**Recommendation: mark OUT, reason recorded.** France is already the site's most over-covered country through Michelin, Gault & Millau, and La Liste. A venue showing both Michelin and Le Fooding reads as two independent signals but is one owner counted twice, which cuts against the whole premise of cross-referencing independent guides. The genuine argument for it, that it reaches casual French places Michelin ignores, is a Compass Local argument rather than a flagship one.

Copy retained below in case this decision gets revisited.

> A French restaurant guide and events brand founded in 2000 by the food journalists Alexandre Cammas and Emmanuel Rubin, whose name blends "food" and "feeling." It began as a deliberate reaction against the formality of traditional French fine dining, championing casual, personality-driven cooking. Here's the twist: after buying a stake in 2017, Michelin took full ownership around 2020, so the anti-establishment guide now belongs to the establishment it once needled. Its selections and annual awards still carry real weight in France and Belgium.

### The Good Food Guide — recommend INGEST, unranked
Trust profile is one of the cleanest on the list: anonymous inspectors, ordinary bookings, own bills, no freebies, independently owned since 2021.

Since 2024 it no longer orders its top restaurants numerically. This is not a blocker. `AwardSchema.rank` is already optional and the site carries plenty of unranked awards, including every Michelin tier and every James Beard category. Ingest as a category-based source and leave `rank` empty.

### Skipped: individual and team competitions
Eight competition sources were considered and seven were skipped, because their winners are individuals competing on personal skill rather than venue proprietors. Attaching a floating employed person to a single venue is a standing no on this project.

**Skipped:** Campionato Mondiale della Pizza · International Pizza Challenge · World Coffee Championships · Mondial du Pain · World Sushi Cup Japan · Pasta World Championship · World Oyster Opening Championship

**Kept:** Pizza Today, because its awards attach to the pizzeria business and its owners rather than to a cook.

### Excluded by scope rule
Product awards do not map to venues and are out, with breweries the single exception. Cheese, olive oil, honey, tea, chocolate, wine, and spirits competitions are all catalogued on the watch list but get no copy. Coffee roasters (Golden Bean, Golden Bean Australasia) are also out under the same rule, though they're the closest call, and could be revisited for Compass Local.

---

## Changelog

- **v1.3 (July 22, 2026)** — Humanizer and delete-ai-words pass applied to the entire document: roughly 60 em dashes removed, six "where X does A, Y does B" reframe constructions rewritten as direct statements, banned vocabulary cleared (leading-edge, full stop), banned metaphors cleared (pilgrimage sites, knocking on the door), and sentence rhythm varied throughout to break the template feel. Michelin's "around 150 three-star restaurants" dropped to structural phrasing per Ben, resolving the last hardcoded live count in the document. **New copy:** Top 500 Bars (was missing entirely despite being a live registry slug), plus 30 verified backlog and watch-list sources. **Renamed:** 101 Best Steakhouses to World's 101 Best Steak Restaurants, with the Hall of Fire category added. **Restructured** into Part 1 (live registry slugs, cleared to publish), Part 2 (verified, awaiting ingest), and Part 3 (awaiting research, no copy). Wine Spectator moved from Part 2 to Part 1 since it's now a live slug. Le Fooding and The Good Food Guide flagged with recommendations.
- **v1.2.3 (July 5, 2026)** — Kept Michelin's "around 150 three-star restaurants" (later dropped in v1.3), softened Wine Spectator's Grand Award count to "only a very small number."
- **v1.2.2 (July 5, 2026)** — Removed the hardcoded three-PIN count entirely; rarity described structurally instead.
- **v1.2.1 (July 5, 2026)** — Pinnacle Guide fact correction, one 3-PIN bar to four.
- **v1.2 (July 5, 2026)** — Balanced pass: facts restored to lead each description, humor woven in rather than leading.
- **v1.1 (July 5, 2026)** — Humor pass; voice matched to Option B blurbs.
- **v1.0 (July 5, 2026)** — Initial copy; all 27 registry slugs plus 7 future sources.
