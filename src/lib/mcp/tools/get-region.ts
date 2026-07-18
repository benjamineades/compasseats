import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import regionsData from "../../../../data/regions.json";
import type { Region } from "@/lib/schema";

const REGIONS = regionsData as unknown as Region[];

export default defineTool({
  name: "get_region",
  title: "Get region",
  description:
    "Fetch a single CompassEats region by slug along with its constituent cities (each with venue count). Cities with zero charted venues are filtered out.",
  inputSchema: {
    slug: z.string().min(1).describe("Region slug, e.g. 'tuscany' or 'kansai'."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ slug }) => {
    const region = REGIONS.find((r) => r.slug === slug);
    if (!region) {
      return {
        content: [{ type: "text", text: `No region with slug "${slug}".` }],
        isError: true,
      };
    }
    const cities = region.cities
      .filter((c) => (c.venue_count ?? 0) > 0)
      .map((c) => ({
        slug: c.slug,
        display: c.display,
        country: c.country,
        lat: c.lat,
        lng: c.lng,
        venue_count: c.venue_count,
        url: `https://compasseats.com/city/${c.slug}`,
      }));
    return {
      content: [
        {
          type: "text",
          text: `${region.display}, ${region.country ?? ""} — ${cities.length} cities, ${region.venue_count} venues`,
        },
      ],
      structuredContent: {
        region: {
          slug: region.slug,
          display: region.display,
          country: region.country,
          center_lat: region.center_lat,
          center_lng: region.center_lng,
          venue_count: region.venue_count,
          city_count: region.city_count,
          url: `https://compasseats.com/region/${region.slug}`,
        },
        cities,
      },
    };
  },
});