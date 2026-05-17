export type TopCity = {
  slug: string;
  city: string;
  country: string;
  region?: string;
  blurb: string;
};

export const TOP_CITIES: TopCity[] = [
  { slug: "paris", city: "Paris", country: "France", blurb: "Three-star icons, neo-bistros, and the world's most storied cocktail bars." },
  { slug: "tokyo", city: "Tokyo", country: "Japan", blurb: "More Michelin stars than any city on earth, plus precision Japanese bartending." },
  { slug: "london", city: "London", country: "United Kingdom", blurb: "From multi-starred tasting menus to perennial World's 50 Best Bars winners." },
  { slug: "new-york", city: "New York", country: "United States", region: "New York", blurb: "A relentless restaurant capital and the birthplace of the modern cocktail bar." },
  { slug: "barcelona", city: "Barcelona", country: "Spain", blurb: "Catalan creativity, seafood, and award-winning cocktail dens." },
  { slug: "madrid", city: "Madrid", country: "Spain", blurb: "Classic Spanish cooking meets a buzzing, World's 50 Best-stacked bar scene." },
  { slug: "rome", city: "Rome", country: "Italy", blurb: "Roman trattorias, ambitious tasting menus, and Italy's best aperitivo bars." },
  { slug: "copenhagen", city: "Copenhagen", country: "Denmark", blurb: "Home of New Nordic cuisine and a deep bench of design-forward cocktail bars." },
  { slug: "mexico-city", city: "Mexico City", country: "Mexico", blurb: "Latin America's most exciting dining city, with mezcalerías to match." },
  { slug: "lima", city: "Lima", country: "Peru", blurb: "World's 50 Best mainstays serving ceviche, Nikkei, and Amazonian flavors." },
  { slug: "bangkok", city: "Bangkok", country: "Thailand", blurb: "Street-food legends, fine-dining temples, and Asia's top cocktail bars." },
  { slug: "singapore", city: "Singapore", country: "Singapore", blurb: "A tiny island packed with Michelin stars and World's 50 Best Bars." },
  { slug: "hong-kong", city: "Hong Kong", country: "Hong Kong", blurb: "Dim sum, dai pai dongs, and a dense cluster of award-winning bars." },
  { slug: "seoul", city: "Seoul", country: "South Korea", blurb: "Korean fine dining ascending the World's 50 Best, plus inventive cocktail bars." },
  { slug: "lisbon", city: "Lisbon", country: "Portugal", blurb: "Seafood, petiscos, and a fast-growing modern cocktail scene." },
  { slug: "berlin", city: "Berlin", country: "Germany", blurb: "Inventive modern cuisine and one of Europe's most respected cocktail scenes." },
  { slug: "istanbul", city: "Istanbul", country: "Turkey", blurb: "Ottoman heritage cooking and a new wave of World's 50 Best Bars listees." },
  { slug: "dubai", city: "Dubai", country: "United Arab Emirates", blurb: "A booming capital of flagship restaurants and high-design cocktail bars." },
  { slug: "sydney", city: "Sydney", country: "Australia", blurb: "Coastal fine dining and a long-celebrated craft cocktail culture." },
  { slug: "buenos-aires", city: "Buenos Aires", country: "Argentina", blurb: "Steakhouses, modern Argentine kitchens, and South America's top cocktail bars." },
];

export const CITIES_BY_SLUG: Record<string, TopCity> = Object.fromEntries(
  TOP_CITIES.map((c) => [c.slug, c]),
);

export function venueAnchorId(category: string, index: number) {
  return `venue-${category === "restaurant" ? "r" : "b"}-${index}`;
}
