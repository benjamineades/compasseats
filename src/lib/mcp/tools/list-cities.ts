import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import { getCitiesWithVenues } from "@/lib/venues";

export default defineTool({
  name: "list_cities",
  title: "List cities",
  description:
    "List every CompassEats city that has at least one charted restaurant or bar. Each entry includes slug, display name, country, coordinates, and venue count. Use this to discover cities before calling get_city.",
  inputSchema: {
    country: z
      .string()
      .optional()
      .describe("Optional country name filter (case-insensitive substring match)."),
    limit: z
      .number()
      .int()
      .min(1)
      .max(2000)
      .optional()
      .describe("Maximum number of cities to return. Defaults to all."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ country, limit }) => {
    const q = country?.trim().toLowerCase();
    let rows = getCitiesWithVenues().map((c) => ({
      slug: c.slug,
      display: c.display,
      country: c.country,
      lat: c.lat,
      lng: c.lng,
      venue_count: c.venue_count,
    }));
    if (q) rows = rows.filter((c) => c.country.toLowerCase().includes(q));
    rows.sort((a, b) => b.venue_count - a.venue_count);
    if (limit) rows = rows.slice(0, limit);
    return {
      content: [{ type: "text", text: `${rows.length} cities` }],
      structuredContent: { cities: rows },
    };
  },
});