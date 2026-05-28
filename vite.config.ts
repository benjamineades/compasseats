import { defineConfig } from "@lovable.dev/vite-tanstack-config";
import { getAllVenuePaths, getCitiesWithVenues, getAllAwardSources } from "./src/lib/venues";
import { writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";

// TanStack Start's preview-server plugin imports `dist/server/<entry>.js`
// (basename of `tanstackStart.server.entry`, here "server"), but the
// Cloudflare Vite plugin emits the worker bundle as `dist/server/index.js`
// (its virtual worker entry is named "index", and wrangler.jsonc consumes
// that filename). Bridge the two by writing a tiny `server.js` re-export
// alongside `index.js` after the SSR build completes.
function emitServerJsAlias() {
  return {
    name: "lovable:emit-server-js-alias",
    apply: "build" as const,
    closeBundle: {
      order: "post" as const,
      handler() {
        const dir = join(process.cwd(), "dist", "server");
        const target = join(dir, "index.js");
        const alias = join(dir, "server.js");
        if (existsSync(target)) {
          writeFileSync(
            alias,
            'export { default } from "./index.js";\nexport * from "./index.js";\n',
          );
        }
      },
    },
  };
}

export default defineConfig({
  vite: {
    plugins: [emitServerJsAlias()],
  },
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
      ...getAllAwardSources().map((s) => ({
        path: `/award/${s.slug}`,
        prerender: { enabled: true },
      })),
    ],
  },
});