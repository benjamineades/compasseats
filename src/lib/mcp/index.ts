import { defineMcp } from "@lovable.dev/mcp-js";
import listCitiesTool from "./tools/list-cities";
import getCityTool from "./tools/get-city";
import listRegionsTool from "./tools/list-regions";
import getRegionTool from "./tools/get-region";
import getVenueTool from "./tools/get-venue";
import searchVenuesTool from "./tools/search-venues";
import listAwardsTool from "./tools/list-awards";
import getVenuesByAwardTool from "./tools/get-venues-by-award";

export default defineMcp({
  name: "compasseats-mcp",
  title: "CompassEats",
  version: "0.1.0",
  instructions:
    "CompassEats charts the world's best restaurants and cocktail bars, ranked by the guides that matter (Michelin, World's 50 Best, James Beard, Tabelog, La Liste, Gault & Millau, Forbes Travel Guide, and more). Use list_cities, list_regions, and list_awards to discover valid slugs, then get_city, get_region, get_venue, or get_venues_by_award to pull details. Use search_venues for free-text lookups by name, city, country, or cuisine. All data is publicly available on https://compasseats.com.",
  tools: [
    listCitiesTool,
    getCityTool,
    listRegionsTool,
    getRegionTool,
    getVenueTool,
    searchVenuesTool,
    listAwardsTool,
    getVenuesByAwardTool,
  ],
});