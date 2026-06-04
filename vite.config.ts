import { defineConfig } from "@lovable.dev/vite-tanstack-config";
import { writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { runSync, DataValidationError, SyncSkipped } from "./scripts/sync-sheet";

// TanStack Start's preview-server plugin (used by the prerenderer) imports
// `dist/server/<basename(serverInput)>.js` — with our `server.entry: "server"`
// that's `dist/server/server.js`. The Cloudflare Vite plugin emits the worker
// bundle as `dist/server/index.mjs` (its virtual entry is named "index" and
// wrangler.jsonc consumes that filename). Bridge the two by writing a tiny
// `server.js` re-export that delegates to `./index.mjs`.
//
// Timing: the prerenderer runs in the `buildApp` hook (order: "post") of the
// post-build plugin, which fires AFTER every environment's `closeBundle`.
// We attach to the SSR environment's `writeBundle` so the alias exists
// before any closeBundle/post-build work — well before prerender starts.
function emitServerJsAlias() {
  return {
    name: "lovable:emit-server-js-alias",
    apply: "build" as const,
    // Run in the SSR (server) environment only; that's where the worker
    // bundle lands and where we know the output dir.
    applyToEnvironment(env: { name: string }) {
      return env.name === "server";
    },
    writeBundle: {
      order: "post" as const,
      handler(this: { environment?: { config: { build: { outDir: string } } } }) {
        const outDir =
          this.environment?.config.build.outDir ??
          join(process.cwd(), "dist", "server");
        const target = join(outDir, "index.mjs");
        const alias = join(outDir, "server.js");
        if (!existsSync(target)) {
          throw new Error(
            `[emit-server-js-alias] expected ${target} to exist after SSR build`,
          );
        }
        writeFileSync(
          alias,
          'export { default } from "./index.mjs";\nexport * from "./index.mjs";\n',
        );
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

// Run sync at config-load time during builds so the page list below reflects
// fresh data. `runSync()` is idempotent per process — the syncSheetPlugin()
// buildStart hook below hits the same guard and no-ops if we already ran.
const lifecycle = process.env.npm_lifecycle_event ?? "";
const isBuild =
  lifecycle.startsWith("build") || process.argv.includes("build");
if (isBuild) {
  try {
    await runSync();
  } catch (err) {
    if (err instanceof DataValidationError) throw err;
    if (err instanceof SyncSkipped) {
      const bar = "━".repeat(62);
      console.warn("\n" + bar);
      console.warn(" ⚠️  SYNC SKIPPED — using committed JSON, data may be stale ");
      console.warn(bar + "\n  Reason: " + err.message + "\n" + bar + "\n");
    } else {
      throw err;
    }
  }
}

// Import AFTER sync so the JSON modules reflect post-sync data.
const { getAllVenuePaths, getCitiesWithVenues, getAllAwardSources } =
  await import("./src/lib/venues");

const prerenderPages = [
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
];
const _seen = new Set<string>();
for (const p of prerenderPages) {
  if (_seen.has(p.path)) {
    throw new Error(`Duplicate prerender path generated from synced data: ${p.path}`);
  }
  _seen.add(p.path);
}
console.log(`[prerender] ${prerenderPages.length} pages (venues+cities+awards)`);

export default defineConfig({
  vite: {
    plugins: [syncSheetPlugin(), emitServerJsAlias()],
  },
  tanstackStart: {
    server: { entry: "server" },
    pages: prerenderPages,
  },
});