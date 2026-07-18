import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import { getCity, getVenuesByCity, getVenuePrestige } from "@/lib/venues";

export default defineTool({
  name: "get_city",
  title: "Get city with venues",
  description:
    "Fetch a single CompassEats city by slug (e.g. 'tokyo', 'paris', 'new-york') along with its charted venues, ranked by CompassEats prestige score. Use list_cities to discover valid slugs.",
  inputSchema: {
    slug: z.string().min(1).describe("City slug, e.g. 'tokyo' or 'saint-meloir-des-ondes'."),
    limit: z
      .number()
      .int()
      .min(1)
      .max(500)
      .optional()
      .describe("Maximum venues to return (top-ranked first). Defaults to all."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ slug, limit }) => {
    const city = getCity(slug);
    if (!city) {
      return {
        content: [{ type: "text", text: `No city with slug "${slug}".` }],
        isError: true,
      };
    }
    const venues = getVenuesByCity(slug)
      .map((v) => ({
        slug: v.slug,
        name: v.name,
        type: v.type,
        cuisine_tags: v.cuisine_tags,
        price_tier: v.price_tier,
        lat: v.lat,
        lng: v.lng,
        website: v.website,
        awards: v.awards,
        prestige: getVenuePrestige(v),
        url: `https://compasseats.com/venue/${v.city_slug}/${v.slug}`,
      }))
      .sort((a, b) => b.prestige - a.prestige);
    const trimmed = limit ? venues.slice(0, limit) : venues;
    return {
      content: [
        {
          type: "text",
          text: `${city.display}, ${city.country} — ${trimmed.length} of ${venues.length} venues`,
        },
      ],
      structuredContent: {
        city: {
          slug: city.slug,
          display: city.display,
          country: city.country,
          lat: city.lat,
          lng: city.lng,
          venue_count: city.venue_count,
          url: `https://compasseats.com/city/${city.slug}`,
        },
        venues: trimmed,
      },
    };
  },
});