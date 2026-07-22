// Guide descriptions for /award/$award pages and AwardBadge tooltips.
// Copy source: CompassEats-Guide-Descriptions.md v1.3 Part 1 (fact-checked, locked).
// Category resolution verified against all 2,219 distinct source+category pairs
// present in data/venues.json (21,872 award entries). Coverage: 99.7%.
// Do not edit copy here without updating the source doc first.

export interface GuideCategoryNote {
  category: string;
  note: string;
}

export interface GuideDescription {
  slug: string;
  description: string;
  categories: GuideCategoryNote[];
}

export const AWARD_DESCRIPTIONS: Record<string, GuideDescription> = {
  "michelin": {
    slug: "michelin",
    description: "The oldest and most famous restaurant rating in the world, published since the early 1900s by a French tire company that wanted motorists driving farther and wearing out more rubber. That part isn't a joke. The method hasn't changed much since: anonymous inspectors book under fake names, pay their own bills, and come back several times before they decide anything. Stars go to the food. Ingredients, technique, how the flavors hold together, whether the kitchen does it again next Tuesday. The room and the chef's reputation don't count. One star can fill a book for years, which is why chefs both chase this guide and dread it.",
    categories: [
      { category: "Three Stars ★★★", note: "Michelin's own words: \"exceptional cuisine, worth a special journey.\" In practice, get on a plane. Only a small number of restaurants worldwide hold three stars at any given moment." },
      { category: "Two Stars ★★", note: "\"Excellent cooking, worth a detour.\" Deeply skilled kitchens sitting one step below the top." },
      { category: "One Star ★", note: "\"High-quality cooking, worth a stop.\" Sounds modest until you learn most chefs work a whole career without getting one." },
      { category: "Bib Gourmand", note: "Michelin's value award, for genuinely good cooking at a fair price. No stars, no formality. It's where the inspectors eat on their day off." },
      { category: "Selected (The Plate)", note: "Restaurants the inspectors recommend without a star or a Bib. Appearing in the Guide at all means Michelin vouches for the place." },
      { category: "Green Star", note: "A separate award for restaurants doing serious work on sustainability, from sourcing through waste." },
      { category: "Sommelier Award", note: "A Michelin special award for an outstanding sommelier, recognizing the person who built the wine list and runs the cellar." },
      { category: "Exceptional Cocktails Award", note: "A Michelin special award for a restaurant whose cocktail program stands alongside its kitchen." },
      { category: "Service Award", note: "A Michelin special award for dining-room service that stands out even by star standards." },
      { category: "Outstanding Service Award", note: "A Michelin special award for dining-room service that stands out even by star standards." },
      { category: "Young Chef Award", note: "A Michelin special award for a young chef the inspectors expect to hear a great deal more from." },
      { category: "Opening of the Year Award", note: "A Michelin special award for the most impressive new restaurant of the year." },
    ],
  },
  "worlds-50-best-restaurants": {
    slug: "worlds-50-best-restaurants",
    description: "An annual ranked list of the fifty best restaurants on Earth, running since 2002. More than 1,000 chefs, food writers, and well-traveled diners vote, each naming the best meals of their recent travels. The result tracks momentum: which kitchens are setting the direction right now. It's revealed at a ceremony with real Oscar-night energy, and a high placing fills a reservation book for roughly the rest of recorded time.",
    categories: [
      { category: "Top 50 (ranked)", note: "The main list. Fifty restaurants ranked No. 1 through No. 50 by academy vote." },
    ],
  },
  "worlds-50-best-bars": {
    slug: "worlds-50-best-bars",
    description: "The annual ranking of the world's greatest cocktail bars, published since 2009 by the same organization behind World's 50 Best Restaurants. Hundreds of bartenders, drinks writers, and dedicated regulars vote on the best bar experiences of their year. Grand hotel institutions, ten-seat hidden rooms, everything in between. A place on this list means the drinks are worth crossing a city for, and possibly an ocean.",
    categories: [
      { category: "Top 50 (ranked)", note: "The fifty best bars in the world by academy vote. The top ten fill up almost overnight." },
    ],
  },
  "james-beard": {
    slug: "james-beard",
    description: "America's most prestigious food honors, presented since 1991 by the foundation named for James Beard, the cookbook author who spent a lifetime arguing that American cooking deserved to be taken seriously. People call them the Oscars of American food, and in this case there really are medallions. Chefs, restaurants, and bars across the US go through several rounds of nomination and voting by a large body of independent judges. A Beard medallion by the door is one of the surest signs in America that you've picked well.",
    categories: [
      { category: "Outstanding Restaurant", note: "The top honor for a single restaurant that has been excellent for years and shows no sign of stopping." },
      { category: "Outstanding Chef", note: "The highest individual honor in American cooking. \"Career-defining\" undersells it." },
      { category: "Best Chef (by region)", note: "The finest chef in each US region. Very often the award that turns a local favorite into a national reservation problem." },
      { category: "Outstanding Bar", note: "A bar with exceptional drinks, hospitality, and atmosphere, judged as seriously as any kitchen." },
      { category: "Best New Restaurant", note: "The country's most impressive opening of the past year." },
      { category: "America's Classics", note: "Beloved, often family-run institutions. The diners, barbecue joints, and neighborhood legends no amount of money could recreate." },
      { category: "Outstanding Hospitality", note: "For a restaurant whose welcome and warmth are as good as its food." },
      { category: "Outstanding Service", note: "For a restaurant setting the national standard in dining-room service." },
      { category: "Outstanding Restaurateur", note: "For an operator running several excellent restaurants, judged on the whole body of work." },
      { category: "Outstanding Bakery", note: "For the country's best bakery, judged as seriously as any restaurant." },
      { category: "Outstanding Pastry Chef", note: "For the best pastry work in America." },
      { category: "Outstanding Pastry Chef or Baker", note: "For the best pastry or baking work in America." },
      { category: "Outstanding Wine Program", note: "For the country's best restaurant wine list." },
      { category: "Outstanding Wine and Other Beverages Program", note: "For the best all-round drinks program, wine and beyond." },
      { category: "Outstanding Wine & Other Beverages Program", note: "For the best all-round drinks program, wine and beyond." },
      { category: "Outstanding Wine, Spirits, or Beer Professional", note: "For an individual setting the standard in American drinks service." },
      { category: "Outstanding Bar Program", note: "For the best bar program attached to a restaurant." },
      { category: "Outstanding Professional in Beverage Service", note: "For an individual setting the standard in American drinks service." },
      { category: "Outstanding Professional in Cocktail Service", note: "For an individual setting the standard behind an American bar." },
      { category: "Emerging Chef", note: "For a chef early in their career already cooking at a national level." },
      { category: "Emerging Chef of the Year", note: "For a chef early in their career already cooking at a national level." },
      { category: "Rising Star Chef", note: "For a young chef judged likely to shape the future of American cooking." },
      { category: "Rising Star Chef of the Year", note: "For a young chef judged likely to shape the future of American cooking." },
      { category: "Best New Bar", note: "The country's most impressive bar opening of the past year." },
      { category: "Outstanding Restaurant Design (75 Seats and Under)", note: "For the best-designed smaller dining room in the country." },
      { category: "Outstanding Restaurant Design (76 Seats and Over)", note: "For the best-designed larger dining room in the country." },
    ],
  },
  "best-chef-awards": {
    slug: "best-chef-awards",
    description: "A global award for the chef rather than the restaurant, voted on by a large body of chefs and food experts around the world. Since half the voters are chefs themselves, this is the profession grading its own work, and it does not grade gently. Founded in the mid-2010s, it dropped its single ranked top-100 in 2024 for a tiered knife system while still crowning one Best Chef each year. It's the clearest read available on who the people working the line actually admire.",
    categories: [
      { category: "Three Knives", note: "The top tier. Chefs their own peers rank among the very best in the world." },
      { category: "Two Knives", note: "Chefs of outstanding international standing." },
      { category: "One Knife", note: "Excellence recognized on the world stage. A knife at any tier means the profession has noticed." },
    ],
  },
  "spirited-awards": {
    slug: "spirited-awards",
    description: "The bar world's most prestigious honors, presented since 2007 by the Tales of the Cocktail Foundation at its annual gathering in New Orleans, the industry's biggest event and a famously thirsty week. Winners come out of several rounds of voting by more than a hundred bartenders, writers, and drinks professionals. These awards measure the respect of the people working behind the bar, which is a hard thing to fake.",
    categories: [
      { category: "World's Best Bar", note: "The top international honor a bar can get from its own industry, which is the toughest crowd there is." },
      { category: "Best US Bar / Best International Bar", note: "The finest bars inside and outside the United States, judged separately." },
      { category: "Best New Bar", note: "The most impressive opening of the year, in US and international editions." },
      { category: "Best Cocktail Menu / Best Bar Team", note: "Craft honors for the drinks list and the people pouring it." },
      { category: "World's Best Cocktail Menu", note: "For the year's best drinks list anywhere, judged on ideas as much as execution." },
      { category: "World's Best Spirits Selection", note: "For the deepest and best-chosen back bar in the world." },
      { category: "Best International Cocktail Bar", note: "The top cocktail bar outside the United States." },
      { category: "Best American Cocktail Bar", note: "The top cocktail bar in the United States." },
      { category: "Best U.S. Cocktail Bar", note: "The top cocktail bar in the United States." },
      { category: "Best New International Cocktail Bar", note: "The most impressive cocktail bar opening outside the United States." },
      { category: "Best New American Cocktail Bar", note: "The most impressive cocktail bar opening in the United States." },
      { category: "Best New U.S. Cocktail Bar", note: "The most impressive cocktail bar opening in the United States." },
      { category: "Best International Hotel Bar", note: "The best hotel bar outside the United States, a category with very deep benches." },
      { category: "Best American Hotel Bar", note: "The best hotel bar in the United States." },
      { category: "Best U.S. Hotel Bar", note: "The best hotel bar in the United States." },
      { category: "Best International Restaurant Bar", note: "The best bar attached to a restaurant outside the United States." },
      { category: "Best American Restaurant Bar", note: "The best bar attached to a restaurant in the United States." },
      { category: "Best U.S. Restaurant Bar", note: "The best bar attached to a restaurant in the United States." },
      { category: "Best International Bar Team", note: "For the crew behind the bar outside the United States, judged on how the whole room runs." },
      { category: "Best American Bar Team", note: "For the crew behind the bar in the United States, judged on how the whole room runs." },
      { category: "Best U.S. Bar Team", note: "For the crew behind the bar in the United States, judged on how the whole room runs." },
      { category: "Best International High Volume Cocktail Bar", note: "For a busy international bar holding its standards at full tilt, which is harder than it sounds." },
      { category: "Best American High Volume Cocktail Bar", note: "For a busy American bar holding its standards at full tilt, which is harder than it sounds." },
      { category: "Timeless International Award", note: "For a bar outside the United States that has stayed excellent for years rather than a season." },
      { category: "Timeless American Award", note: "For an American bar that has stayed excellent for years rather than a season." },
      { category: "Timeless U.S. Award", note: "For an American bar that has stayed excellent for years rather than a season." },
    ],
  },
  "pinnacle-guide": {
    slug: "pinnacle-guide",
    description: "The newest serious accolade in the bar world, founded by the team behind London Cocktail Week and often described as Michelin stars for cocktail bars. The process backs the comparison up. Bars apply through an open process, get assessed across detailed criteria covering the drinks, the hospitality, the room, staff welfare, and sustainability, then receive several anonymous in-person visits before any PIN is awarded. PINs last two years and then have to be earned again. Of the hundreds of pinned bars, only a small handful ever reach three.",
    categories: [
      { category: "One PIN", note: "An excellent cocktail bar, verified by anonymous reviewers." },
      { category: "Two PINs", note: "An outstanding cocktail bar, a clear step above." },
      { category: "Three PINs", note: "The guide's highest and rarest honor, held by only a select few of all pinned bars." },
      { category: "Listed", note: "Included in the Pinnacle Guide without a PIN. The bar cleared assessment and comes recommended, which is a filter most bars never get through." },
    ],
  },
  "oad": {
    slug: "oad",
    description: "A restaurant ranking built from surveys of thousands of the world's most frequent fine diners, the sort of people who fly to another country for lunch and consider it a reasonable Tuesday. Votes are weighted by how much the reviewer has eaten, so the most traveled palates count most. Because those voters eat constantly and everywhere, OAD tends to surface excellent restaurants years ahead of the bigger guides. Its European lists carry particular weight.",
    categories: [
      { category: "Ranked lists (by region)", note: "Restaurants ranked numerically within regional lists such as the European Top 100+, shown as \"No. 42 · OAD\". The lower the number, the stronger the verdict from the world's most seasoned diners." },
    ],
  },
  "101-best-steakhouses": {
    slug: "101-best-steakhouses",
    description: "The specialist authority on one gloriously focused question: where is the best steak on Earth? Founded in London in 2018 by Ekkehard Knobelspies and published by Upper Cut Media House, it sends anonymous inspectors, called Steak Ambassadors, to eat their way through every candidate. They judge the quality and provenance of the meat, the range of cuts, the wine program, the design, and the service. Each of the 101 named restaurants gets visited once or twice a year by the ambassador responsible for its country. Useful when the mission is beef and the mission is serious.",
    categories: [
      { category: "Ranked 1–101", note: "A numerical world ranking. Any spot on it marks one of the finest steak restaurants on the planet, and the top ten are worth planning a trip around." },
      { category: "Hall of Fire", note: "A separate honor for restaurants whose influence goes beyond a single year's list. Parrilla Don Julio in Buenos Aires entered it after three consecutive years at No. 1." },
    ],
  },
  "worlds-50-best-bars-51-100": {
    slug: "worlds-50-best-bars-51-100",
    description: "The annual ranking of the world's greatest cocktail bars, published since 2009 by the same organization behind World's 50 Best Restaurants. Hundreds of bartenders, drinks writers, and dedicated regulars vote on the best bar experiences of their year. Grand hotel institutions, ten-seat hidden rooms, everything in between. A place on this list means the drinks are worth crossing a city for, and possibly an ocean.",
    categories: [
      { category: "51–100", note: "The extended ranking. Bars sitting just outside the top 50." },
    ],
  },
  "north-america-50-best-bars": {
    slug: "north-america-50-best-bars",
    description: "Launched in 2022 for the US, Canada, Mexico, and the Caribbean.",
    categories: [
      { category: "Top 50 (ranked)", note: "North America's fifty best bars, ranked by regional academy vote." },
    ],
  },
  "asia-50-best-bars": {
    slug: "asia-50-best-bars",
    description: "Published since 2016, covering the region that turned Singapore and Hong Kong into cocktail capitals.",
    categories: [
      { category: "Top 50 (ranked)", note: "Asia's fifty best bars, ranked by regional academy vote." },
    ],
  },
  "north-america-50-best-bars-51-100": {
    slug: "north-america-50-best-bars-51-100",
    description: "Launched in 2022 for the US, Canada, Mexico, and the Caribbean.",
    categories: [
      { category: "51–100", note: "The extended North American ranking." },
    ],
  },
  "asia-50-best-bars-51-100": {
    slug: "asia-50-best-bars-51-100",
    description: "Published since 2016, covering the region that turned Singapore and Hong Kong into cocktail capitals.",
    categories: [
      { category: "51–100", note: "The extended Asian ranking." },
    ],
  },
  "europe-50-best-bars": {
    slug: "europe-50-best-bars",
    description: "The newest regional list, first awarded in 2026 at a ceremony in Amsterdam. The continent that invented much of bar culture finally has its own scoreboard.",
    categories: [
      { category: "Top 50 (ranked)", note: "Europe's fifty best bars, ranked by regional academy vote." },
    ],
  },
  "top-500-bars": {
    slug: "top-500-bars",
    description: "A global ranking of the 500 most influential cocktail bars in the world, built by algorithm rather than by panel. Founded by Anthony Poncier and first published in 2019, it came out of a complaint bartenders kept repeating: the same handful of bars win everything, partly because no human jury can realistically visit hundreds of bars a year. Top 500 Bars answers that by aggregating over 2,000 sources in more than 20 languages, including expert and journalist coverage, other industry rankings, review platforms, social media, and search data. The word worth holding onto is influential, because that's what the model actually measures. The 2025 edition covered 125 cities across 53 countries, so it works as a travel list as much as a leaderboard.",
    categories: [
      { category: "Ranked 1–500", note: "A numerical world ranking of the most influential cocktail bars. The top 100 are revealed at an annual ceremony, and any placing at all puts a bar among the most talked-about on the planet." },
    ],
  },
  "la-liste": {
    slug: "la-liste",
    description: "A French ranking, published annually since 2015, built on one idea: ask every guide at once. La Liste aggregates hundreds of guidebooks and millions of published reviews from around the world into a single score out of 100 per restaurant, then ranks the global top 1,000. A high score means a restaurant satisfies everyone's standards at the same time, which is about as close as food gets to a unanimous decision.",
    categories: [
      { category: "Score out of 100", note: "A restaurant's aggregate standing across the world's guides and reviews. The high 90s is where the arguments stop." },
    ],
  },
  "gault-millau": {
    slug: "gault-millau",
    description: "France's other great restaurant guide, founded in 1965 by critics Henri Gault and Christian Millau, who thought French food had gotten heavy and said so loudly. They championed the lighter, more inventive style that became nouvelle cuisine. Anonymous reviewers score restaurants out of 20 and award one to five toques, the chef's hats, judging the talent and creativity in the kitchen rather than the thickness of the carpet. Across France and much of Europe, a young chef's first toque is often the earliest reliable sign that a star is being born.",
    categories: [
      { category: "Toques (1–5)", note: "Chef's hats tracking the kitchen's score out of 20. Four and five toques mark the very finest kitchens. A perfect 20 is nearly mythical." },
      { category: "Grand de Demain", note: "Gault & Millau's award for a young chef expected to reach the very top. Often the earliest public signal that someone is about to become a name." },
      { category: "Chef of the Year", note: "The headline annual award in that country's edition, for the chef of the moment." },
      { category: "Pastry Chef of the Year", note: "The annual award for the country's outstanding pastry chef." },
      { category: "Riser of the Year", note: "An annual award for the kitchen making the biggest jump in that edition." },
      { category: "Discovery of the Year", note: "An annual award for the year's most striking new find." },
      { category: "Future Great of the Year", note: "An annual award for a kitchen the reviewers expect to keep climbing." },
      { category: "Young Talent of the Year", note: "An annual award for the most promising young chef of the edition." },
      { category: "Breakthrough Restaurant of the Year", note: "An annual award for the restaurant that made the biggest leap forward." },
      { category: "Home-grown Restaurant of the Year", note: "An annual award for the best restaurant rooted in local produce and tradition." },
      { category: "Restaurant of the Year", note: "The annual award for the standout restaurant in that country's edition." },
      { category: "Heritage Award", note: "An annual award for a restaurant keeping a regional cooking tradition alive." },
    ],
  },
  "tabelog": {
    slug: "tabelog",
    description: "Japan's most trusted restaurant resource, a review platform used by millions of Japanese diners with a famously strict algorithm that weights credible, experienced reviewers most heavily. Scores run out of 5 and the curve is merciless. Crossing 3.5 already puts a restaurant in the top few percent nationwide, and 4.0 is rare air. The annual Tabelog Award, split into Gold, Silver, and Bronze, picks out the country's absolute best and promptly makes them nearly impossible to book.",
    categories: [
      { category: "Tabelog Award, Gold", note: "The top tier of Japan's annual best-restaurant selection. Getting a table is a competitive sport." },
      { category: "Tabelog Award, Silver", note: "The second tier, still an elite national distinction." },
      { category: "Tabelog Award, Bronze", note: "The third tier, marking a restaurant among Japan's finest. In a country this good at food, that's saying plenty." },
    ],
  },
  "forbes-travel-guide": {
    slug: "forbes-travel-guide",
    description: "The company that invented the five-star rating, inspecting hotels and restaurants since 1958 under its original name, the Mobil Travel Guide, and spending the decades since making sure the stars still mean something. Its professional inspectors arrive anonymously, pay their own way, and grade against hundreds of exacting service standards, down to details you'd never consciously notice but would absolutely feel. Forbes rates the complete experience rather than the plate alone, so a Forbes star points to hospitality that holds up from the moment the door opens.",
    categories: [
      { category: "Five-Star", note: "A flawless, world-class experience and the guide's highest honor. The inspectors checked everything and it all passed." },
      { category: "Four-Star", note: "Exceptional quality and service, just short of the summit." },
      { category: "Recommended", note: "Consistently excellent places the inspectors are confident sending you to." },
    ],
  },
  "wine-spectator": {
    slug: "wine-spectator",
    description: "The global standard for restaurant wine programs, awarded by Wine Spectator magazine since 1981. It judges the cellar, not the kitchen, which makes it a good complement to the food-first guides and explains why sommeliers keep these plaques polished. Three tiers run from a well-chosen list up to the Grand Award's vast, deep cellars. A Grand Award restaurant is a destination for the wine list every bit as much as the cooking.",
    categories: [
      { category: "Grand Award", note: "The highest honor, for the world's greatest wine programs. Only a very small number of restaurants worldwide hold one." },
      { category: "Best of Award of Excellence", note: "Extensive lists with real depth and breadth." },
      { category: "Award of Excellence", note: "Well-chosen lists that pair thoughtfully with the menu." },
    ],
  },
  "asia-50-best-restaurants": {
    slug: "asia-50-best-restaurants",
    description: "Running since 2013, using the same voting model as the global list with a regional academy. The authority on the continent's most exciting dining, from Tokyo counters to Bangkok tasting menus.",
    categories: [
      { category: "Top 50 (ranked)", note: "Asia's fifty best restaurants, ranked by regional academy vote." },
    ],
  },
  "latin-america-50-best-restaurants": {
    slug: "latin-america-50-best-restaurants",
    description: "Also running since 2013, covering a region that produced some of this century's most influential kitchens.",
    categories: [
      { category: "Top 50 (ranked)", note: "Latin America's fifty best restaurants, ranked by regional academy vote." },
    ],
  },
  "north-america-50-best-restaurants": {
    slug: "north-america-50-best-restaurants",
    description: "The newest restaurant edition, bringing the same voting model to North America.",
    categories: [
      { category: "Top 50 (ranked)", note: "North America's fifty best restaurants, ranked by regional academy vote." },
    ],
  },
  "mena-50-best-restaurants": {
    slug: "mena-50-best-restaurants",
    description: "Launched in 2022, right around the time the region's dining scene stopped being a secret.",
    categories: [
      { category: "Top 50 (ranked)", note: "The region's fifty best restaurants, ranked by regional academy vote." },
    ],
  },
  "africa-50-best-restaurants": {
    slug: "africa-50-best-restaurants",
    description: "",
    categories: [],
  },
  "worlds-50-best-restaurants-51-100": {
    slug: "worlds-50-best-restaurants-51-100",
    description: "An annual ranked list of the fifty best restaurants on Earth, running since 2002. More than 1,000 chefs, food writers, and well-traveled diners vote, each naming the best meals of their recent travels. The result tracks momentum: which kitchens are setting the direction right now. It's revealed at a ceremony with real Oscar-night energy, and a high placing fills a reservation book for roughly the rest of recorded time.",
    categories: [
      { category: "51–100", note: "The extended list below the cut. \"Only\" the 73rd best restaurant on the planet is still a very good dinner." },
    ],
  },
  "asia-50-best-restaurants-51-100": {
    slug: "asia-50-best-restaurants-51-100",
    description: "Running since 2013, using the same voting model as the global list with a regional academy. The authority on the continent's most exciting dining, from Tokyo counters to Bangkok tasting menus.",
    categories: [
      { category: "51–100", note: "The extended Asian ranking." },
    ],
  },
};

/**
 * Category strings in the sheet do not always match the labels above.
 * Ranked sources store a rank ("No. 42"), La Liste stores a score ("77/100"),
 * and several sources use shorthand ("1-Pin", "3-Knife") or compound values
 * ("Four Toques · Chef of the Year"). These maps let one written note serve
 * every real variant. Verified against all 2,219 distinct source+category
 * pairs in data/venues.json.
 */

/** Sources whose sheet category is a rank. Value = the category label to use. */
const RANKED_FALLBACK: Record<string, string> = {
  "worlds-50-best-restaurants": "Top 50 (ranked)",
  "asia-50-best-restaurants": "Top 50 (ranked)",
  "latin-america-50-best-restaurants": "Top 50 (ranked)",
  "north-america-50-best-restaurants": "Top 50 (ranked)",
  "mena-50-best-restaurants": "Top 50 (ranked)",
  "worlds-50-best-bars": "Top 50 (ranked)",
  "asia-50-best-bars": "Top 50 (ranked)",
  "north-america-50-best-bars": "Top 50 (ranked)",
  "europe-50-best-bars": "Top 50 (ranked)",
  "top-500-bars": "Ranked 1–500",
  "oad": "Ranked lists (by region)",
  "101-best-steakhouses": "Ranked 1–101",
  "worlds-50-best-restaurants-51-100": "51–100",
  "asia-50-best-restaurants-51-100": "51–100",
  "worlds-50-best-bars-51-100": "51–100",
  "asia-50-best-bars-51-100": "51–100",
  "north-america-50-best-bars-51-100": "51–100",
};

/** Per-source shorthand seen in the sheet, mapped to the written label. */
const CATEGORY_ALIASES: Record<string, Record<string, string>> = {
  "pinnacle-guide": {
    "1 pin": "One PIN",
    "2 pin": "Two PINs",
    "3 pin": "Three PINs",
  },
  "best-chef-awards": {
    "1 knife": "One Knife",
    "2 knife": "Two Knives",
    "3 knife": "Three Knives",
    "1 knives": "One Knife",
    "2 knives": "Two Knives",
    "3 knives": "Three Knives",
  },
  "michelin": {
    "selected": "Selected (The Plate)",
    "the plate": "Selected (The Plate)",
  },
};

const RANK_PATTERN = /^no\s*\d+$/;
const SCORE_PATTERN = /^\d+(?:\s+\d+)?\s+100$/;
const TOQUE_PATTERN = /^(one|two|three|four|five)\s+(red\s+)?toques?$/;

function normalizeCategory(input: string): string {
  return input.toLowerCase().trim().replace(/[^a-z0-9]+/g, " ").trim();
}

export function getGuideDescription(slug: string): GuideDescription | undefined {
  return AWARD_DESCRIPTIONS[slug];
}

export function getCategoryNote(
  slug: string,
  category: string,
): string | undefined {
  const entry = AWARD_DESCRIPTIONS[slug];
  if (!entry || !category) return undefined;

  const find = (label: string): string | undefined => {
    const target = normalizeCategory(label);
    return entry.categories.find(
      (c) => normalizeCategory(c.category) === target,
    )?.note;
  };

  // 1. Exact match, ignoring case, punctuation, and symbols such as stars.
  const direct = find(category);
  if (direct) return direct;

  const n = normalizeCategory(category);

  // 2. Per-source shorthand.
  const alias = CATEGORY_ALIASES[slug]?.[n];
  if (alias) {
    const viaAlias = find(alias);
    if (viaAlias) return viaAlias;
  }

  // 3. Ranked sources store a rank rather than a tier name.
  if (RANK_PATTERN.test(n)) {
    const label = RANKED_FALLBACK[slug];
    if (label) {
      const viaRank = find(label);
      if (viaRank) return viaRank;
    }
  }

  // 4. La Liste stores a score out of 100.
  if (slug === "la-liste" && SCORE_PATTERN.test(n)) {
    const viaScore = find("Score out of 100");
    if (viaScore) return viaScore;
  }

  // 5. Gault & Millau compounds lead with the toque tier.
  if (slug === "gault-millau") {
    const head = normalizeCategory(category.split("·")[0]);
    if (TOQUE_PATTERN.test(head)) {
      const viaToque = find("Toques (1–5)");
      if (viaToque) return viaToque;
    }
    // Compound values may carry a named award after the separator.
    const parts = category.split("·").map((p) => p.trim());
    for (const part of parts.slice(1)) {
      const viaPart = find(part);
      if (viaPart) return viaPart;
    }
  }

  // 6. James Beard regional chef awards appear under several spellings.
  if (slug === "james-beard") {
    if (n.startsWith("best chef")) {
      const viaRegion = find("Best Chef (by region)");
      if (viaRegion) return viaRegion;
    }
  }

  // No confident match. Show no tooltip rather than a wrong one.
  return undefined;
}
