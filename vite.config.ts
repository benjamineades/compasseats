import { defineConfig } from "@lovable.dev/vite-tanstack-config";
import { getAllVenuePaths, getCitiesWithVenues, getAllAwardSources } from "./src/lib/venues";
import { writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { runSync, DataValidationError, SyncSkipped } from "./scripts/sync-sheet";

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

// Runs scripts/sync-sheet.ts at the start of every PRODUCTION build
// (i.e. on every publish). Skipped during `vite dev` via `apply: "build"`,
// so editing locally doesn't hammer the Google Sheets API on every reload.
//
// Failure model (matches the CLI):
//   - DataValidationError (duplicate keys, schema fail) → re-thrown, fails the build.
//   - SyncSkipped         (missing env, fetch failure)  → warned, build continues
//                                                          on the committed JSON.
function syncSheetPlugin() {
  return {
    name: "compasseats:sync-sheet",
    apply: "build" as const,
    async buildStart() {
      try {
        await runSync();
      } catch (err) {
        if (err instanceof DataValidationError) {
          // Hard fail — committed JSON would silently drift from the Sheet.
          throw err;
        }
        if (err instanceof SyncSkipped) {
          const bar = "━".repeat(62);
          console.warn("\n" + bar);
          console.warn(" ⚠️  SYNC SKIPPED — using committed JSON, data may be stale ");
          console.warn(bar);
          console.warn("  Reason: " + err.message);
          console.warn(bar + "\n");
          return;
        }
        throw err;
      }
    },
  };
}

export default defineConfig({
  vite: {
    plugins: [syncSheetPlugin(), emitServerJsAlias()],
  },
  tanstackStart: {
    server: { entry: "server" },
    pages: [
      ...getAllVenuePaths().map((p) => ({
        path: `/venue/${p.citySlug}/${p.venueSlug}/`,
        prerender: { enabled: true },
      })),
      ...getCitiesWithVenues().map((c) => ({
        path: `/city/${c.slug}/`,
        prerender: { enabled: true },
      })),
      ...getAllAwardSources().map((s) => ({
        path: `/award/${s.slug}/`,
        prerender: { enabled: true },
      })),
    ],
  },
});