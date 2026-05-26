// Firecrawl-based supplementary venue source. When the linked spreadsheet
// doesn't have enough accolade venues for a city, we scrape Yelp (for US
// cities) or TripAdvisor (international) to get the top names. These names
// are passed to the AI as an explicit allow-list so the model never has to
// invent venues from its training data.

const FIRECRAWL_BASE = "https://api.firecrawl.dev/v2";

type Category = "restaurant" | "cocktail bar";

const isUS = (country: string): boolean => {
  const c = country.trim().toLowerCase();
  return (
    c === "usa" ||
    c === "us" ||
    c === "u.s." ||
    c === "u.s.a." ||
    c === "united states" ||
    c === "united states of america" ||
    c === "america"
  );
};

const buildYelpUrl = (
  city: string,
  region: string,
  category: Category,
): string => {
  const desc = category === "cocktail bar" ? "Cocktail Bars" : "Restaurants";
  const loc = [city, region].filter(Boolean).join(", ");
  const params = new URLSearchParams({
    find_desc: desc,
    find_loc: loc,
    sortby: "rating",
  });
  return `https://www.yelp.com/search?${params.toString()}`;
};

const buildTripAdvisorUrl = (
  city: string,
  country: string,
  category: Category,
): string => {
  const q =
    category === "cocktail bar"
      ? `best cocktail bars in ${city} ${country}`
      : `best restaurants in ${city} ${country}`;
  return `https://www.tripadvisor.com/Search?q=${encodeURIComponent(q)}`;
};

type FirecrawlScrapeResponse = {
  success?: boolean;
  data?: {
    json?: { venues?: Array<{ name?: string }> };
    metadata?: { statusCode?: number };
  };
  error?: string;
};

const scrapeNames = async (
  url: string,
  category: Category,
  cityHint: string,
): Promise<string[]> => {
  const key = process.env.FIRECRAWL_API_KEY;
  if (!key) return [];
  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 6000);
    const res = await fetch(`${FIRECRAWL_BASE}/scrape`, {
      method: "POST",
      signal: ctrl.signal,
      headers: {
        Authorization: `Bearer ${key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        url,
        onlyMainContent: true,
        waitFor: 600,
        formats: [
          {
            type: "json",
            prompt: `Extract the top ${category === "cocktail bar" ? "cocktail bars" : "restaurants"} listed on this search results page, in the order they appear. Only include actual venue businesses that are clearly located in or very near ${cityHint} — skip ads, sponsored content, blog posts, "best of" article links, generic category pages, and any venue in a different city. Return a JSON object with a "venues" array; each item has just "name" (the venue's official name, no ranking numbers or extra text).`,
            schema: {
              type: "object",
              properties: {
                venues: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: { name: { type: "string" } },
                    required: ["name"],
                  },
                },
              },
              required: ["venues"],
            },
          },
        ],
      }),
    });
    clearTimeout(timer);
    if (!res.ok) {
      console.log(
        `[venue-fallback] firecrawl ${res.status} for ${url.slice(0, 80)}`,
      );
      return [];
    }
    const body = (await res.json()) as FirecrawlScrapeResponse;
    const venues = body.data?.json?.venues ?? [];
    return venues
      .map((v) => (typeof v.name === "string" ? v.name.trim() : ""))
      .filter((n) => n.length > 1 && n.length < 120)
      .slice(0, 25);
  } catch (err) {
    console.log(
      `[venue-fallback] scrape error for ${url.slice(0, 80)}:`,
      (err as Error).message,
    );
    return [];
  }
};

export type SupplementaryVenues = {
  restaurants: string[];
  bars: string[];
  source: "yelp" | "tripadvisor" | "none";
};

export const fetchSupplementaryVenues = async (
  city: string,
  region: string,
  country: string,
): Promise<SupplementaryVenues> => {
  if (!city) return { restaurants: [], bars: [], source: "none" };
  const cityHint = [city, region, country].filter(Boolean).join(", ");

  // Pick ONE source per city — never chain Yelp then TripAdvisor serially
  // (that stacked two 25s timeouts into one request). US cities use Yelp,
  // everyone else uses TripAdvisor. Both scrape calls run in parallel with a
  // short timeout so the supplementary (rated) tier can never block the
  // response for long; the charted tier doesn't depend on this at all.
  if (isUS(country)) {
    const [restaurants, bars] = await Promise.all([
      scrapeNames(buildYelpUrl(city, region, "restaurant"), "restaurant", cityHint),
      scrapeNames(buildYelpUrl(city, region, "cocktail bar"), "cocktail bar", cityHint),
    ]);
    return { restaurants, bars, source: "yelp" };
  }

  const [restaurants, bars] = await Promise.all([
    scrapeNames(buildTripAdvisorUrl(city, country, "restaurant"), "restaurant", cityHint),
    scrapeNames(buildTripAdvisorUrl(city, country, "cocktail bar"), "cocktail bar", cityHint),
  ]);
  return { restaurants, bars, source: "tripadvisor" };
};