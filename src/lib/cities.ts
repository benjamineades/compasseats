export type TopCity = {
  slug: string;
  city: string;
  country: string;
  region?: string;
  blurb: string;
  imageUrl?: string;
  lat: number;
  lng: number;
};

const UNSPLASH = (id: string) =>
  `https://images.unsplash.com/photo-${id}?w=1600&q=80&auto=format&fit=crop`;

export const TOP_CITIES: TopCity[] = [
  { slug: "paris", city: "Paris", country: "France", lat: 48.8566, lng: 2.3522, blurb: "Three-star icons, neo-bistros, and the world's most storied cocktail bars.", imageUrl: UNSPLASH("1502602898657-3e91760cbb34") },
  { slug: "tokyo", city: "Tokyo", country: "Japan", lat: 35.6762, lng: 139.6503, blurb: "More Michelin stars than any city on earth, plus precision Japanese bartending.", imageUrl: UNSPLASH("1540959733332-eab4deabeeaf") },
  { slug: "london", city: "London", country: "United Kingdom", lat: 51.5074, lng: -0.1278, blurb: "From multi-starred tasting menus to perennial World's 50 Best Bars winners.", imageUrl: UNSPLASH("1513635269975-59663e0ac1ad") },
  { slug: "new-york", city: "New York", country: "United States", region: "New York", lat: 40.7128, lng: -74.0060, blurb: "A relentless restaurant capital and the birthplace of the modern cocktail bar.", imageUrl: UNSPLASH("1496442226666-8d4d0e62e6e9") },
  { slug: "barcelona", city: "Barcelona", country: "Spain", lat: 41.3851, lng: 2.1734, blurb: "Catalan creativity, seafood, and award-winning cocktail dens.", imageUrl: UNSPLASH("1583422409516-2895a77efded") },
  { slug: "madrid", city: "Madrid", country: "Spain", lat: 40.4168, lng: -3.7038, blurb: "Classic Spanish cooking meets a buzzing, World's 50 Best-stacked bar scene.", imageUrl: UNSPLASH("1543783207-ec64e4d95325") },
  { slug: "rome", city: "Rome", country: "Italy", lat: 41.9028, lng: 12.4964, blurb: "Roman trattorias, ambitious tasting menus, and Italy's best aperitivo bars.", imageUrl: UNSPLASH("1552832230-c0197dd311b5") },
  { slug: "copenhagen", city: "Copenhagen", country: "Denmark", lat: 55.6761, lng: 12.5683, blurb: "Home of New Nordic cuisine and a deep bench of design-forward cocktail bars.", imageUrl: UNSPLASH("1513622470522-26c3c8a854bc") },
  { slug: "mexico-city", city: "Mexico City", country: "Mexico", lat: 19.4326, lng: -99.1332, blurb: "Latin America's most exciting dining city, with mezcalerías to match.", imageUrl: UNSPLASH("1518105779142-d975f22f1b0a") },
  { slug: "lima", city: "Lima", country: "Peru", lat: -12.0464, lng: -77.0428, blurb: "World's 50 Best mainstays serving ceviche, Nikkei, and Amazonian flavors.", imageUrl: UNSPLASH("1531968455001-5c5272a41129") },
  { slug: "bangkok", city: "Bangkok", country: "Thailand", lat: 13.7563, lng: 100.5018, blurb: "Street-food legends, fine-dining temples, and Asia's top cocktail bars.", imageUrl: UNSPLASH("1508009603885-50cf7c579365") },
  { slug: "singapore", city: "Singapore", country: "Singapore", lat: 1.3521, lng: 103.8198, blurb: "A tiny island packed with Michelin stars and World's 50 Best Bars.", imageUrl: UNSPLASH("1496939376851-89342e90adcd") },
  { slug: "hong-kong", city: "Hong Kong", country: "Hong Kong", lat: 22.3193, lng: 114.1694, blurb: "Dim sum, dai pai dongs, and a dense cluster of award-winning bars.", imageUrl: UNSPLASH("1536599018102-9f803c140fc1") },
  { slug: "seoul", city: "Seoul", country: "South Korea", lat: 37.5665, lng: 126.9780, blurb: "Korean fine dining ascending the World's 50 Best, plus inventive cocktail bars.", imageUrl: UNSPLASH("1538485399081-7c8979ad8254") },
  { slug: "lisbon", city: "Lisbon", country: "Portugal", lat: 38.7223, lng: -9.1393, blurb: "Seafood, petiscos, and a fast-growing modern cocktail scene.", imageUrl: UNSPLASH("1555881400-74d7acaacd8b") },
  { slug: "berlin", city: "Berlin", country: "Germany", lat: 52.5200, lng: 13.4050, blurb: "Inventive modern cuisine and one of Europe's most respected cocktail scenes.", imageUrl: UNSPLASH("1560969184-10fe8719e047") },
  { slug: "istanbul", city: "Istanbul", country: "Turkey", lat: 41.0082, lng: 28.9784, blurb: "Ottoman heritage cooking and a new wave of World's 50 Best Bars listees.", imageUrl: UNSPLASH("1524231757912-21f4fe3a7200") },
  { slug: "dubai", city: "Dubai", country: "United Arab Emirates", lat: 25.2048, lng: 55.2708, blurb: "A booming capital of flagship restaurants and high-design cocktail bars.", imageUrl: UNSPLASH("1512453979798-5ea266f8880c") },
  { slug: "sydney", city: "Sydney", country: "Australia", lat: -33.8688, lng: 151.2093, blurb: "Coastal fine dining and a long-celebrated craft cocktail culture.", imageUrl: UNSPLASH("1506973035872-a4ec16b8e8d9") },
  { slug: "buenos-aires", city: "Buenos Aires", country: "Argentina", lat: -34.6037, lng: -58.3816, blurb: "Steakhouses, modern Argentine kitchens, and South America's top cocktail bars.", imageUrl: UNSPLASH("1589909202802-8f4aadce1849") },
];

export const CITIES_BY_SLUG: Record<string, TopCity> = Object.fromEntries(
  TOP_CITIES.map((c) => [c.slug, c]),
);

export function venueAnchorId(category: string, index: number) {
  return `venue-${category === "restaurant" ? "r" : "b"}-${index}`;
}

function haversineKm(a: [number, number], b: [number, number]) {
  const [lat1, lng1] = a;
  const [lat2, lng2] = b;
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const x =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(x));
}

export function findNearestCity(coords: [number, number]): { city: TopCity; distanceKm: number } {
  let best = TOP_CITIES[0];
  let bestDist = haversineKm(coords, [best.lat, best.lng]);
  for (const c of TOP_CITIES.slice(1)) {
    const d = haversineKm(coords, [c.lat, c.lng]);
    if (d < bestDist) {
      best = c;
      bestDist = d;
    }
  }
  return { city: best, distanceKm: bestDist };
}
