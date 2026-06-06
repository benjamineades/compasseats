import { createFileRoute, Link } from "@tanstack/react-router";

import { getCitiesWithVenues } from "@/lib/venues";
import type { City } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const PAPER_CARD = "#FCFAF5";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

type CountryGroup = {
  country: string;
  country_code: string;
  cities: City[];
  total: number;
};

function buildGroups(cities: City[]): CountryGroup[] {
  const map = new Map<string, CountryGroup>();
  for (const c of cities) {
    const key = c.country_code || c.country;
    let g = map.get(key);
    if (!g) {
      g = { country: c.country, country_code: c.country_code, cities: [], total: 0 };
      map.set(key, g);
    }
    g.cities.push(c);
    g.total += c.venue_count ?? 0;
  }
  for (const g of map.values()) {
    g.cities.sort((a, b) => (b.venue_count ?? 0) - (a.venue_count ?? 0));
  }
  return Array.from(map.values()).sort((a, b) => b.total - a.total);
}

function formatNum(n: number): string {
  return n.toLocaleString("en-US");
}

export const Route = createFileRoute("/cities")({
  staticData: { prerender: true },
  loader: () => {
    const cities = getCitiesWithVenues();
    const groups = buildGroups(cities);
    return { cities, groups };
  },
  head: ({ loaderData }) => {
    const cityCount = loaderData?.cities.length ?? 0;
    const countryCount = loaderData?.groups.length ?? 0;
    const title = `Cities — every table we've charted | CompassEats`;
    const description = `${formatNum(cityCount)} cities across ${formatNum(countryCount)} countries, charted by the world's most trusted guides.`;
    const url = `${SITE_URL}/cities`;
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
  component: CitiesPage,
});

function CitiesPage() {
  const { cities, groups } = Route.useLoaderData() as {
    cities: City[];
    groups: CountryGroup[];
  };

  return (
    <main style={{ backgroundColor: PAPER, color: INK }} className="min-h-screen">
      <div className="mx-auto max-w-5xl px-6 py-16 md:py-20">
        {/* Header block */}
        <header>
          <p
            className="text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: BRONZE }}
          >
            Every Table We've Charted
          </p>
          <h1
            className="mt-4 font-display text-4xl font-light italic tracking-tight md:text-5xl"
            style={{ color: INK }}
          >
            Cities
          </h1>
          <p
            className="mt-4 max-w-2xl text-base leading-relaxed"
            style={{ color: INK_MUTED }}
          >
            {formatNum(cities.length)} cities across {formatNum(groups.length)} countries, charted by the world's most trusted guides.
          </p>
        </header>

        {/* Jump bar */}
        <nav
          className="mt-8 flex flex-wrap gap-x-3 gap-y-2 border-y py-4"
          style={{ borderColor: HAIRLINE }}
          aria-label="Jump to country"
        >
          {groups.map((g) => (
            <a
              key={g.country_code}
              href={`#${g.country_code.toLowerCase()}`}
              className="text-[11px] uppercase tracking-wide transition-colors"
              style={{ color: INK_MUTED }}
              onMouseEnter={(e) => (e.currentTarget.style.color = BRONZE)}
              onMouseLeave={(e) => (e.currentTarget.style.color = INK_MUTED)}
            >
              {g.country_code}
            </a>
          ))}
        </nav>

        {/* Country sections */}
        <div className="mt-12 space-y-12">
          {groups.map((g) => (
            <section key={g.country_code} id={g.country_code.toLowerCase()} style={{ scrollMarginTop: 96 }}>
              <div
                className="flex items-baseline justify-between gap-4 border-b pb-3"
                style={{ borderColor: HAIRLINE }}
              >
                <h2
                  className="font-display text-2xl font-light italic"
                  style={{ color: INK }}
                >
                  {g.country}
                </h2>
                <span className="text-sm" style={{ color: INK_MUTED }}>
                  · {formatNum(g.cities.length)} {g.cities.length === 1 ? "city" : "cities"}
                </span>
              </div>
              <ul className="mt-5 grid gap-x-6 gap-y-1.5 sm:grid-cols-2 lg:grid-cols-3">
                {g.cities.map((c) => (
                  <li key={c.slug}>
                    <Link
                      to="/city/$slug"
                      params={{ slug: c.slug }}
                      className="group flex items-baseline justify-between gap-3 py-1 no-underline"
                      style={{ color: INK }}
                    >
                      <span
                        className="text-sm transition-colors group-hover:[color:var(--hover)]"
                        style={{ ["--hover" as never]: BRONZE }}
                      >
                        {c.display}
                      </span>
                      <span className="text-xs" style={{ color: INK_MUTED }}>
                        {formatNum(c.venue_count ?? 0)}
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
