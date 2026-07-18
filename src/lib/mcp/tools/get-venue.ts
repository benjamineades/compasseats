import { defineTool } from "@lovable.dev/mcp-js";
import { z } from "zod";
import { getVenue } from "@/lib/venues";

export default defineTool({
  name: "get_venue",
  title: "Get venue",
  description:
    "Fetch full details for a single CompassEats venue by city slug and venue slug: name, type, cuisine, price tier, address, coordinates, website, hours, awards, and blurb.",
  inputSchema: {
    city_slug: z.string().min(1).describe("City slug, e.g. 'paris'."),
    venue_slug: z.string().min(1).describe("Venue slug, e.g. 'le-comptoir-du-relais'."),
  },
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: ({ city_slug, venue_slug }) => {
    const v = getVenue(city_slug, venue_slug);
    if (!v) {
      return {
        content: [
          { type: "text", text: `No venue at ${city_slug}/${venue_slug}.` },
        ],
        isError: true,
      };
    }
    const url = `https://compasseats.com/venue/${v.city_slug}/${v.slug}`;
    return {
      content: [{ type: "text", text: `${v.name} — ${v.city_display} · ${url}` }],
      structuredContent: { venue: { ...v, url } },
    };
  },
});