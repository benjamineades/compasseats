import { defineTool } from "@lovable.dev/mcp-js";
import { getAllAwardSources } from "@/lib/venues";

export default defineTool({
  name: "list_awards",
  title: "List award sources",
  description:
    "List every award / guide CompassEats tracks (Michelin, World's 50 Best, James Beard, Tabelog, La Liste, etc.), including slug, display name, and tier. Use the slug with get_venues_by_award.",
  inputSchema: {},
  annotations: { readOnlyHint: true, idempotentHint: true, openWorldHint: false },
  handler: () => {
    const sources = getAllAwardSources().map((s) => ({
      slug: s.slug,
      name: s.name,
      tier: s.tier,
      url: `https://compasseats.com/award/${s.slug}`,
    }));
    return {
      content: [{ type: "text", text: `${sources.length} award sources` }],
      structuredContent: { awards: sources },
    };
  },
});