import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import regionsData from "../../../../data/regions.json";
import type { Region } from "@/lib/schema";

const REGIONS = regionsData as unknown as Region[];

export default defineTool({
  name: "list_regions",
  title: "List regions",
  description:
    "List every CompassEats region (Tuscany, Kansai, Provence, etc.) with slug, display name, country, and venue/city counts.",
  inputSchema: {
    country: z.string().optional().describe("Optional country name filter (case-insensitive substring match)."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ country }) => {
    const q = country?.trim().toLowerCase();
    let rows = REGIONS.map((r) => ({
      slug: r.slug,
      display: r.display,
      country: r.country,
      city_count: r.city_count,
      venue_count: r.venue_count,
      url: `https://compasseats.com/region/${r.slug}`,
    }));
    if (q) rows = rows.filter((r) => (r.country ?? "").toLowerCase().includes(q));
    rows.sort((a, b) => b.venue_count - a.venue_count);
    return {
      content: [{ type: "text", text: `${rows.length} regions` }],
      structuredContent: { regions: rows },
    };
  },
});