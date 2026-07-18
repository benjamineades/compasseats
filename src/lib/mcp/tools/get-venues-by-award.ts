import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import { getAwardSource, getVenuesByAward, getVenuePrestige } from "@/lib/venues";

export default defineTool({
  name: "get_venues_by_award",
  title: "Get venues by award",
  description:
    "List CompassEats venues recognized by a specific award or guide (Michelin, World's 50 Best Restaurants, James Beard, Tabelog, etc.). Use list_awards to discover valid slugs. Results ranked by CompassEats prestige score.",
  inputSchema: {
    award_slug: z.string().min(1).describe("Award slug, e.g. 'michelin' or 'worlds-50-best-bars'."),
    limit: z.number().int().min(1).max(500).optional().describe("Max results. Defaults to all."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ award_slug, limit }) => {
    const source = getAwardSource(award_slug);
    if (!source) {
      return {
        content: [{ type: "text", text: `Unknown award slug "${award_slug}".` }],
        isError: true,
      };
    }
    const venues = getVenuesByAward(source.slug)
      .map((v) => ({
        slug: v.slug,
        name: v.name,
        city_slug: v.city_slug,
        city: v.city_display,
        country: v.country,
        type: v.type,
        price_tier: v.price_tier,
        awards: v.awards.filter((a) => a.source === source.slug),
        prestige: getVenuePrestige(v),
        url: `https://compasseats.com/venue/${v.city_slug}/${v.slug}`,
      }))
      .sort((a, b) => b.prestige - a.prestige);
    const trimmed = limit ? venues.slice(0, limit) : venues;
    return {
      content: [{ type: "text", text: `${source.name} — ${trimmed.length} of ${venues.length} venues` }],
      structuredContent: {
        award: { slug: source.slug, name: source.name, tier: source.tier },
        venues: trimmed,
      },
    };
  },
});