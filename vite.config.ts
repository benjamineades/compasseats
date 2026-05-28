import { defineConfig } from "@lovable.dev/vite-tanstack-config";
import { getAllVenuePaths, getCitiesWithVenues } from "./src/lib/venues";

export default defineConfig({
  tanstackStart: {
    server: { entry: "server" },
    pages: [
      ...getAllVenuePaths().map((p) => ({
        path: `/venue/${p.citySlug}/${p.venueSlug}`,
        prerender: { enabled: true },
      })),
      ...getCitiesWithVenues().map((c) => ({
        path: `/city/${c.slug}`,
        prerender: { enabled: true },
      })),
    ],
  },
});