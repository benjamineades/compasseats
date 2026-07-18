import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import { getAllVenues, getVenuePrestige } from "@/lib/venues";

function fold(s: string): string {
  return s.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

export default defineTool({
  name: "search_venues",
  title: "Search venues",
  description:
    "Free-text search across all charted CompassEats restaurants and bars. Matches on venue name, city, country, and cuisine tags. Results ranked by CompassEats prestige score.",
  inputSchema: {
    query: z.string().min(1).describe("Search text — venue name, city, country, or cuisine."),
    type: z.enum(["restaurant", "bar"]).optional().describe("Optional filter: restaurants only or bars only."),
    limit: z.number().int().min(1).max(100).optional().describe("Max results (default 25)."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ query, type, limit }) => {
    const q = fold(query);
    const cap = limit ?? 25;
    const hits = getAllVenues()
      .filter((v) => (type ? v.type === type : true))
      .filter((v) => {
        const hay = fold([v.name, v.city_display, v.country, ...(v.cuisine_tags ?? [])].join(" "));
        return hay.includes(q);
      })
      .map((v) => ({
        slug: v.slug,
        name: v.name,
        city_slug: v.city_slug,
        city: v.city_display,
        country: v.country,
        type: v.type,
        cuisine_tags: v.cuisine_tags,
        price_tier: v.price_tier,
        prestige: getVenuePrestige(v),
        url: `https://compasseats.com/venue/${v.city_slug}/${v.slug}`,
      }))
      .sort((a, b) => b.prestige - a.prestige)
      .slice(0, cap);
    return {
      content: [{ type: "text", text: `${hits.length} venues match "${query}"` }],
      structuredContent: { venues: hits },
    };
  },
});