import { createFileRoute, Link } from "@tanstack/react-router";
import { ChevronRight } from "lucide-react";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { getCitiesWithVenues } from "@/lib/venues";
import { slugifyCountry } from "@/lib/cities";
import type { City } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

// country_code -> continent. Covers every code present in the data.
const CONTINENT_BY_CODE: Record<string, string> = {
  // Europe
  FR: "Europe", IT: "Europe", ES: "Europe", DE: "Europe", GB: "Europe",
  BE: "Europe", CH: "Europe", NL: "Europe", AT: "Europe", PT: "Europe",
  IE: "Europe", SI: "Europe", DK: "Europe", HR: "Europe", TR: "Europe",
  CZ: "Europe", HU: "Europe", SE: "Europe", LU: "Europe", NO: "Europe",
  PL: "Europe", MT: "Europe", GR: "Europe", RU: "Europe", SK: "Europe",
  RS: "Europe", FI: "Europe", EE: "Europe", LV: "Europe", BG: "Europe",
  IS: "Europe", LT: "Europe", MC: "Europe", GE: "Europe", RO: "Europe",
  JE: "Europe", UA: "Europe", CY: "Europe", XK: "Europe", AD: "Europe",
  AL: "Europe", FO: "Europe", LI: "Europe",
  // North America
  US: "North America", MX: "North America", CA: "North America",
  BB: "North America", KY: "North America", CU: "North America",
  BS: "North America", PA: "North America", PR: "North America",
  SV: "North America", DO: "North America", JM: "North America",
  AG: "North America", CR: "North America", GT: "North America",
  // Asia
  JP: "Asia", CN: "Asia", TH: "Asia", IN: "Asia", PH: "Asia",
  TW: "Asia", IL: "Asia", ID: "Asia", VN: "Asia", SA: "Asia",
  MY: "Asia", KH: "Asia", AE: "Asia", KZ: "Asia", KR: "Asia",
  LK: "Asia", KW: "Asia", JO: "Asia", LB: "Asia", QA: "Asia",
  NP: "Asia", MO: "Asia", BH: "Asia", MV: "Asia", SG: "Asia",
  // South America
  BR: "South America", CO: "South America", AR: "South America",
  PE: "South America", EC: "South America", UY: "South America",
  BO: "South America", VE: "South America", CL: "South America",
  // Africa
  ZA: "Africa", MA: "Africa", EG: "Africa", TN: "Africa", GH: "Africa",
  MU: "Africa", RW: "Africa", NG: "Africa", KE: "Africa",
  // Oceania
  AU: "Oceania", NZ: "Oceania",
};

type CountryGroup = {
  code: string;
  name: string;
  slug: string;
  cities: City[];
  total: number;
};
type ContinentGroup = {
  continent: string;
  countries: CountryGroup[];
  total: number;
  cityCount: number;
};

function formatNum(n: number): string {
  return n.toLocaleString("en-US");
}

function buildTree(cities: City[]): ContinentGroup[] {
  // 1) group by country_code; pick the most common country name per code
  const byCode = new Map<string, { cities: City[]; names: Map<string, number> }>();
  for (const c of cities) {
    const code = c.country_code;
    let g = byCode.get(code);
    if (!g) {
      g = { cities: [], names: new Map() };
      byCode.set(code, g);
    }
    g.cities.push(c);
    g.names.set(c.country, (g.names.get(c.country) ?? 0) + 1);
  }

  const countries: CountryGroup[] = [];
  for (const [code, g] of byCode) {
    let name = code;
    let best = -1;
    for (const [n, count] of g.names) {
      if (count > best) {
        best = count;
        name = n;
      }
    }
    g.cities.sort((a, b) => (b.venue_count ?? 0) - (a.venue_count ?? 0));
    const total = g.cities.reduce((s, c) => s + (c.venue_count ?? 0), 0);
    countries.push({ code, name, slug: slugifyCountry(name), cities: g.cities, total });
  }

  // 2) group countries by continent
  const byCont = new Map<string, CountryGroup[]>();
  for (const c of countries) {
    const cont = CONTINENT_BY_CODE[c.code] ?? "Other";
    if (!byCont.has(cont)) byCont.set(cont, []);
    byCont.get(cont)!.push(c);
  }

  const result: ContinentGroup[] = [];
  for (const [continent, list] of byCont) {
    list.sort((a, b) => a.name.localeCompare(b.name));
    result.push({
      continent,
      countries: list,
      total: list.reduce((s, c) => s + c.total, 0),
      cityCount: list.reduce((s, c) => s + c.cities.length, 0),
    });
  }
  result.sort((a, b) => a.continent.localeCompare(b.continent));
  return result;
}

export const Route = createFileRoute("/cities")({
  staticData: { prerender: true },
  loader: () => {
    const cities = getCitiesWithVenues();
    const tree = buildTree(cities);
    const countryCount = new Set(cities.map((c) => c.country_code)).size;
    return { tree, cityCount: cities.length, countryCount };
  },
  head: ({ loaderData }) => {
    const cityCount = loaderData?.cityCount ?? 0;
    const countryCount = loaderData?.countryCount ?? 0;
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
  const { tree, cityCount, countryCount } = Route.useLoaderData() as {
    tree: ContinentGroup[];
    cityCount: number;
    countryCount: number;
  };

  return (
    <main style={{ backgroundColor: PAPER, color: INK }} className="min-h-screen">
      <div className="mx-auto max-w-5xl px-6 py-16 md:py-20">
        {/* Header */}
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
            {formatNum(cityCount)} cities across {formatNum(countryCount)} countries, charted by the world's most trusted guides.
          </p>
          <p className="mt-2 max-w-2xl text-sm" style={{ color: INK_MUTED }}>
            Choose a continent, then a country, to see its charted cities.
          </p>
        </header>

        {/* Continent accordion — all collapsed by default */}
        <Accordion
          type="multiple"
          className="mt-10 border-t"
          style={{ borderColor: HAIRLINE }}
        >
          {tree.map((cont) => (
            <AccordionItem
              key={cont.continent}
              value={cont.continent}
              className="border-b"
              style={{ borderColor: HAIRLINE }}
            >
              <AccordionTrigger className="px-1 py-5 hover:no-underline">
                <div className="flex flex-1 items-baseline justify-between gap-4 pr-3">
                  <span
                    className="font-display text-2xl font-light italic"
                    style={{ color: INK }}
                  >
                    {cont.continent}
                  </span>
                  <span className="text-xs" style={{ color: INK_MUTED }}>
                    {formatNum(cont.countries.length)} countries · {formatNum(cont.cityCount)} cities
                  </span>
                </div>
              </AccordionTrigger>
              <AccordionContent className="pb-2">
                <Accordion type="multiple" className="pl-1">
                  {cont.countries.map((country) => (
                    <div
                      key={country.code}
                      className="border-b last:border-b-0"
                      style={{ borderColor: HAIRLINE }}
                    >
                      <Link
                        to="/country/$slug"
                        params={{ slug: country.slug }}
                        className="group flex items-baseline justify-between gap-4 px-1 py-3.5 no-underline"
                        style={{ color: INK }}
                      >
                        <span
                          className="font-display text-lg font-light italic transition-colors group-hover:[color:var(--hover)]"
                          style={{ ["--hover" as never]: BRONZE }}
                        >
                          {country.name}
                        </span>
                        <span className="flex items-center gap-2 pr-1">
                          <span className="text-xs" style={{ color: INK_MUTED }}>
                            {formatNum(country.cities.length)}{" "}
                            {country.cities.length === 1 ? "city" : "cities"}
                          </span>
                          <ChevronRight
                            className="h-4 w-4 transition-transform group-hover:translate-x-0.5"
                            style={{ color: INK_MUTED }}
                          />
                        </span>
                      </Link>
                    </div>
                  ))}
                </Accordion>
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </main>
  );
}