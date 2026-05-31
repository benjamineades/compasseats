import { createFileRoute } from "@tanstack/react-router";
import type {} from "@tanstack/react-start";
import {
  getAllVenuePaths,
  getAllVenues,
  getCitiesWithVenues,
  getAllAwardSources,
  getVenuesByCity,
} from "@/lib/venues";

const BASE_URL = "https://compasseats.com";
// NOTE: A single <urlset> tops out at 50,000 URLs. We're well under that
// today (~5k venues + cities + awards). If the venue count crosses ~40k,
// split into a <sitemapindex> with per-section sitemaps.

interface SitemapEntry {
  path: string;
  lastmod?: string;
  changefreq: "weekly" | "monthly";
  priority: string;
}

function maxDate(dates: (string | undefined)[]): string | undefined {
  const valid = dates.filter((d): d is string => !!d && /^\d{4}-\d{2}-\d{2}$/.test(d));
  if (valid.length === 0) return undefined;
  return valid.reduce((a, b) => (a > b ? a : b));
}

export const Route = createFileRoute("/sitemap.xml")({
  server: {
    handlers: {
      GET: async () => {
        const venues = getAllVenues();
        const globalLastmod = maxDate(venues.map((v) => v.last_verified));

        const entries: SitemapEntry[] = [
          {
            path: "/",
            lastmod: globalLastmod,
            changefreq: "weekly",
            priority: "1.0",
          },
          ...getCitiesWithVenues().map((c) => ({
            path: `/city/${c.slug}`,
            lastmod: maxDate(getVenuesByCity(c.slug).map((v) => v.last_verified)),
            changefreq: "weekly" as const,
            priority: "0.8",
          })),
          ...getAllAwardSources().map((s) => ({
            path: `/award/${s.slug}`,
            lastmod: maxDate(
              venues
                .filter((v) => v.awards.some((a) => a.source === s.slug))
                .map((v) => v.last_verified),
            ),
            changefreq: "weekly" as const,
            priority: "0.8",
          })),
          ...getAllVenuePaths().map((p) => {
            const v = venues.find(
              (x) => x.city_slug === p.citySlug && x.slug === p.venueSlug,
            );
            return {
              path: `/venue/${p.citySlug}/${p.venueSlug}`,
              lastmod: v?.last_verified || undefined,
              changefreq: "monthly" as const,
              priority: "0.6",
            };
          }),
        ];

        const urls = entries.map((e) =>
          [
            `  <url>`,
            `    <loc>${BASE_URL}${e.path}</loc>`,
            e.lastmod ? `    <lastmod>${e.lastmod}</lastmod>` : null,
            `    <changefreq>${e.changefreq}</changefreq>`,
            `    <priority>${e.priority}</priority>`,
            `  </url>`,
          ]
            .filter(Boolean)
            .join("\n"),
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
