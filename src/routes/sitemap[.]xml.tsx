import { createFileRoute } from "@tanstack/react-router";
import type {} from "@tanstack/react-start";
import {
  getAllVenuePaths,
  getCitiesWithVenues,
  getAllAwardSources,
} from "@/lib/venues";

const BASE_URL = "https://compasseats.com";
const TODAY = "2026-05-28";

interface SitemapEntry {
  path: string;
  lastmod: string;
  priority: string;
}

function entry(path: string, priority: string): SitemapEntry {
  return { path, lastmod: TODAY, priority };
}

export const Route = createFileRoute("/sitemap.xml")({
  server: {
    handlers: {
      GET: async () => {
        const entries: SitemapEntry[] = [
          entry("/", "1.0"),
          ...getCitiesWithVenues().map((c) =>
            entry(`/city/${c.slug}`, "0.8"),
          ),
          ...getAllAwardSources().map((s) =>
            entry(`/award/${s.slug}`, "0.7"),
          ),
          ...getAllVenuePaths().map((p) =>
            entry(`/venue/${p.citySlug}/${p.venueSlug}`, "0.6"),
          ),
        ];

        const urls = entries.map((e) =>
          [
            `  <url>`,
            `    <loc>${BASE_URL}${e.path}</loc>`,
            `    <lastmod>${e.lastmod}</lastmod>`,
            `    <priority>${e.priority}</priority>`,
            `  </url>`,
          ].join("\n"),
        );

        const xml = [
          `<?xml version="1.0" encoding="UTF-8"?>`,
          `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">`,
          ...urls,
          `</urlset>`,
        ].join("\n");

        return new Response(xml, {
          headers: {
            "Content-Type": "application/xml",
            "Cache-Control": "public, max-age=3600",
          },
        });
      },
    },
  },
});
