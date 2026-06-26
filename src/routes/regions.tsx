import { createFileRoute, Link } from "@tanstack/react-router";
import { z } from "zod";

import regionsData from "../../data/regions.json";
import { RegionSchema, type Region } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

const MULTI = "Multi-country";

type CountryGroup = {
  country: string;
  regions: Region[];
  total: number;
};

function formatNum(n: number): string {
  return n.toLocaleString("en-US");
}

function buildGroups(regions: Region[]): CountryGroup[] {
  const byCountry = new Map<string, Region[]>();
  for (const r of regions) {
    const key = r.country ?? MULTI;
    if (!byCountry.has(key)) byCountry.set(key, []);
    byCountry.get(key)!.push(r);
  }
  const groups: CountryGroup[] = [];
  for (const [country, list] of byCountry) {
    list.sort((a, b) => b.venue_count - a.venue_count);
    groups.push({
      country,
      regions: list,
      total: list.reduce((s, r) => s + r.venue_count, 0),
    });
  }
  groups.sort((a, b) => {
    if (a.country === MULTI) return 1;
    if (b.country === MULTI) return -1;
    return b.total - a.total;
  });
  return groups;
}

export const Route = createFileRoute("/regions")({
  staticData: { prerender: true },
  loader: () => {
    const regions = z.array(RegionSchema).parse(regionsData);
    const groups = buildGroups(regions);
    return {
      groups,
      regionCount: regions.length,
      countryCount: groups.filter((g) => g.country !== MULTI).length,
    };
  },
  head: ({ loaderData }) => {
    const regionCount = loaderData?.regionCount ?? 0;
    const title = `Regions — places worth traveling for | CompassEats`;
    const description = `Browse ${formatNum(regionCount)} award-winning regions — the places people actually travel to for the table.`;
    const url = `${SITE_URL}/regions`;
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: url },
        { property: "og:type", content: "website" },
        { name: "twitter:card", content: "summary_large_image" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
      ],
      links: [{ rel: "canonical", href: url }],
    };
  },
  errorComponent: ({ error }) => (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-2xl px-6 py-24 text-center">
        <h1 className="font-display text-3xl italic">Regions didn't load</h1>
        <p className="mt-3 text-sm" style={{ color: INK_MUTED }}>
          {error.message}
        </p>
      </div>
    </main>
  ),
  notFoundComponent: () => (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-2xl px-6 py-24 text-center">
        <h1 className="font-display text-3xl italic">No regions found</h1>
      </div>
    </main>
  ),
  component: RegionsPage,
});

function RegionsPage() {
  const { groups, regionCount } = Route.useLoaderData();

  return (
    <main style={{ backgroundColor: PAPER, color: INK }} className="min-h-screen">
      <div className="mx-auto max-w-4xl px-6 py-16 md:py-24">
        <header className="mb-14 md:mb-20">
          <p
            className="mb-4 text-xs uppercase tracking-[0.2em]"
            style={{ color: BRONZE }}
          >
            The Places People Travel To
          </p>
          <h1
            className="font-display text-5xl md:text-6xl font-light tracking-tight"
            style={{ color: INK }}
          >
            Explore by Region
          </h1>
          <p
            className="mt-6 max-w-2xl text-base md:text-lg leading-relaxed"
            style={{ color: INK_MUTED }}
          >
            Browse award-winning restaurants and bars by the places people
            actually travel to.
          </p>
          <p className="mt-3 max-w-2xl text-sm" style={{ color: INK_MUTED }}>
            {formatNum(regionCount)} regions, grouped by country.
          </p>
        </header>

        <div className="space-y-12">
          {groups.map((g) => (
            <section key={g.country}>
              <div className="mb-3 flex items-baseline justify-between gap-4">
                <h2
                  className="font-display text-2xl italic"
                  style={{ color: INK }}
                >
                  {g.country}
                </h2>
                <span className="text-xs" style={{ color: INK_MUTED }}>
                  {formatNum(g.regions.length)}{" "}
                  {g.regions.length === 1 ? "region" : "regions"} ·{" "}
                  {formatNum(g.total)} venues
                </span>
              </div>
              <ul
                role="list"
                className="border-t"
                style={{ borderColor: HAIRLINE }}
              >
                {g.regions.map((r) => (
                  <li
                    key={r.slug}
                    className="border-b"
                    style={{ borderColor: HAIRLINE }}
                  >
                    <Link
                      to="/region/$slug"
                      params={{ slug: r.slug }}
                      className="group flex items-baseline justify-between gap-4 py-4"
                    >
                      <span
                        className="font-display text-lg sm:text-xl"
                        style={{ color: INK }}
                      >
                        {r.display}
                      </span>
                      <span className="flex items-baseline gap-3 shrink-0">
                        <span
                          className="text-xs sm:text-sm tabular-nums"
                          style={{ color: INK_MUTED }}
                        >
                          {formatNum(r.venue_count)}{" "}
                          {r.venue_count === 1 ? "venue" : "venues"} ·{" "}
                          {formatNum(r.city_count)}{" "}
                          {r.city_count === 1 ? "city" : "cities"}
                        </span>
                        <span
                          aria-hidden
                          className="text-sm transition-transform group-hover:translate-x-0.5"
                          style={{ color: BRONZE }}
                        >
                          →
                        </span>
                      </span>
                    </Link>
                  </li>
                ))}
              </ul>
            </section>
          ))}
        </div>
      </div>
    </main>
  );
}