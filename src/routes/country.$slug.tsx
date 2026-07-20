import { useEffect, useMemo, useRef, useState } from "react";
import {
  createFileRoute,
  Link,
  notFound,
  useRouter,
} from "@tanstack/react-router";
import maplibregl from "maplibre-gl";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { VenueMap } from "@/components/VenueMap";
import { getCountries } from "@/lib/cities";
import { getCitiesWithVenues, getVenuesByCity } from "@/lib/venues";
import type { City, Venue } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";
const BRASS = "#C6A15B";

const VENUE_PIN_LIMIT = 400;

function formatNum(n: number): string {
  return n.toLocaleString("en-US");
}

type CountryCity = City & { venues: Venue[] };

type LoaderData = {
  code: string;
  name: string;
  slug: string;
  cityCount: number;
  venueCount: number;
  restaurantCount: number;
  barCount: number;
  cities: CountryCity[];
  allVenues: Venue[];
  center: { lat: number; lng: number };
  usePinsPerCity: boolean;
};

export const Route = createFileRoute("/country/$slug")({
  staticData: { prerender: true },
  loader: ({ params }): LoaderData => {
    const countries = getCountries();
    const country = countries.find((c) => c.slug === params.slug);
    if (!country) throw notFound();

    const cities = getCitiesWithVenues().filter(
      (c) => c.country_code === country.code,
    );

    const cityEntries: CountryCity[] = cities
      .map((c) => ({ ...c, venues: getVenuesByCity(c.slug) }))
      .sort((a, b) => (b.venue_count ?? 0) - (a.venue_count ?? 0));

    const allVenues = cityEntries.flatMap((c) => c.venues);
    const restaurantCount = allVenues.filter((v) => v.type === "restaurant").length;
    const barCount = allVenues.filter((v) => v.type === "bar").length;

    // Weighted centroid by venue count for a sane default map view.
    let latSum = 0;
    let lngSum = 0;
    let wSum = 0;
    for (const c of cityEntries) {
      const w = Math.max(1, c.venue_count ?? 0);
      latSum += c.lat * w;
      lngSum += c.lng * w;
      wSum += w;
    }
    const center =
      wSum > 0
        ? { lat: latSum / wSum, lng: lngSum / wSum }
        : { lat: cityEntries[0]?.lat ?? 0, lng: cityEntries[0]?.lng ?? 0 };

    return {
      code: country.code,
      name: country.name,
      slug: country.slug,
      cityCount: cityEntries.length,
      venueCount: allVenues.length,
      restaurantCount,
      barCount,
      cities: cityEntries,
      allVenues,
      center,
      usePinsPerCity: allVenues.length > VENUE_PIN_LIMIT,
    };
  },
  head: ({ loaderData }) => {
    if (!loaderData) {
      return { meta: [{ title: "Country not found | CompassEats" }] };
    }
    const title = `${loaderData.name} — ${formatNum(loaderData.venueCount)} charted spots across ${formatNum(loaderData.cityCount)} cities | CompassEats`;
    const description = `Award-winning restaurants and bars charted across ${loaderData.name}.`;
    const url = `${SITE_URL}/country/${loaderData.slug}`;
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
        <h1 className="font-display text-3xl italic">Country didn't load</h1>
        <p className="mt-3 text-sm" style={{ color: INK_MUTED }}>
          {error.message}
        </p>
        <div className="mt-6">
          <Link to="/cities" className="text-sm" style={{ color: BRONZE }}>
            ← All cities
          </Link>
        </div>
      </div>
    </main>
  ),
  notFoundComponent: () => (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-2xl px-6 py-24 text-center">
        <h1 className="font-display text-3xl italic">Country not found</h1>
        <p className="mt-3 text-sm" style={{ color: INK_MUTED }}>
          We don't have a country by that slug.
        </p>
        <div className="mt-6">
          <Link to="/cities" className="text-sm" style={{ color: BRONZE }}>
            ← All cities
          </Link>
        </div>
      </div>
    </main>
  ),
  component: CountryPage,
});

function CountryPage() {
  const data = Route.useLoaderData() as LoaderData;

  const countsLine = useMemo(() => {
    const spots = `${formatNum(data.venueCount)} charted ${data.venueCount === 1 ? "spot" : "spots"}`;
    const cityBit = `${formatNum(data.cityCount)} ${data.cityCount === 1 ? "city" : "cities"}`;
    const rBit = `${formatNum(data.restaurantCount)} ${data.restaurantCount === 1 ? "restaurant" : "restaurants"}`;
    const bBit = `${formatNum(data.barCount)} ${data.barCount === 1 ? "bar" : "bars"}`;
    return `${spots} across ${cityBit} · ${rBit} · ${bBit}`;
  }, [data]);

  return (
    <main style={{ backgroundColor: PAPER, color: INK }} className="min-h-screen">
      <div className="mx-auto max-w-5xl px-6 py-16 md:py-20">
        <header>
          <nav
            className="text-xs uppercase tracking-[0.2em]"
            style={{ color: BRONZE }}
            aria-label="Breadcrumb"
          >
            <Link to="/" style={{ color: BRONZE }}>Home</Link>
            <span className="mx-2" style={{ color: INK_MUTED }}>›</span>
            <span style={{ color: INK_MUTED }}>Country</span>
          </nav>
          <h1
            className="mt-5 font-display text-5xl md:text-6xl font-light italic tracking-tight"
            style={{ color: INK }}
          >
            {data.name}
          </h1>
          <p className="mt-4 text-base md:text-lg" style={{ color: INK_MUTED }}>
            {countsLine}
          </p>
        </header>

        <section className="mt-12 md:mt-16">
          <p
            className="mb-3 text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: BRONZE }}
          >
            On the map
          </p>
          <div className="overflow-hidden rounded-xl border" style={{ borderColor: HAIRLINE }}>
            {data.usePinsPerCity ? (
              <CountryCityMap cities={data.cities} center={data.center} />
            ) : (
              <div className="h-[460px] md:h-[560px] w-full">
                <VenueMap
                  venues={data.allVenues}
                  center={[data.center.lng, data.center.lat]}
                />
              </div>
            )}
          </div>
        </section>

        <section className="mt-16 md:mt-20">
          <p
            className="mb-3 text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: BRONZE }}
          >
            Cities in {data.name}
          </p>
          <p
            className="mb-3 text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: INK_MUTED }}
          >
            Sorted by most charted
          </p>
          <Accordion
            type="multiple"
            className="border-t"
            style={{ borderColor: HAIRLINE }}
          >
            {data.cities.map((c) => (
              <AccordionItem
                key={c.slug}
                value={c.slug}
                className="border-b"
                style={{ borderColor: HAIRLINE }}
              >
                <div className="flex items-baseline justify-between gap-4 py-4">
                  <Link
                    to="/city/$slug"
                    params={{ slug: c.slug }}
                    className="group min-w-0"
                  >
                    <span
                      className="font-display text-2xl italic transition-colors group-hover:[color:var(--hover)]"
                      style={{ color: INK, ["--hover" as never]: BRONZE }}
                    >
                      {c.display}
                    </span>
                  </Link>
                  <AccordionTrigger
                    className="shrink-0 gap-2 py-0 hover:no-underline [&>svg]:h-4 [&>svg]:w-4"
                  >
                    <span className="text-xs tabular-nums" style={{ color: INK_MUTED }}>
                      {formatNum(c.venues.length)} {c.venues.length === 1 ? "venue" : "venues"}
                    </span>
                  </AccordionTrigger>
                </div>
                <AccordionContent className="pb-4">
                  {c.venues.length > 0 ? (
                    <ul className="grid gap-x-6 gap-y-1.5 pl-1 sm:grid-cols-2 lg:grid-cols-3">
                      {c.venues.map((v) => (
                        <li key={v.slug}>
                          <Link
                            to="/venue/$city/$slug"
                            params={{ city: c.slug, slug: v.slug }}
                            className="group flex items-baseline gap-2 py-1 no-underline"
                          >
                            <span
                              className="text-sm transition-colors group-hover:[color:var(--hover)]"
                              style={{ color: INK, ["--hover" as never]: BRONZE }}
                            >
                              {v.name}
                            </span>
                            {v.type === "bar" ? (
                              <span
                                className="text-[10px] uppercase tracking-wider"
                                style={{ color: INK_MUTED }}
                              >
                                bar
                              </span>
                            ) : null}
                          </Link>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="pl-1 text-sm" style={{ color: INK_MUTED }}>
                      Venue list not available yet for this city.
                    </p>
                  )}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </section>
      </div>
    </main>
  );
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function CountryCityMap({
  cities,
  center,
}: {
  cities: CountryCity[];
  center: { lat: number; lng: number };
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);
  const router = useRouter();

  const [isDark, setIsDark] = useState(
    typeof document !== "undefined" &&
      document.documentElement.classList.contains("dark"),
  );

  useEffect(() => {
    const observer = new MutationObserver(() => {
      setIsDark(document.documentElement.classList.contains("dark"));
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class"],
    });
    return () => observer.disconnect();
  }, []);

  const styleUrl = `https://api.maptiler.com/maps/dataviz-${isDark ? "dark" : "light"}/style.json?key=${import.meta.env.VITE_MAPTILER_KEY}`;

  useEffect(() => {
    if (!containerRef.current) return;

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: styleUrl,
      center: [center.lng, center.lat],
      zoom: 4,
      attributionControl: { compact: true },
    });
    map.addControl(
      new maplibregl.NavigationControl({ showCompass: false }),
      "top-right",
    );
    map.touchZoomRotate.enable();
    map.touchZoomRotate.disableRotation();
    map.dragRotate.disable();
    map.keyboard.disableRotation();

    const markers: maplibregl.Marker[] = [];
    for (const c of cities) {
      if (
        typeof c.lat !== "number" ||
        typeof c.lng !== "number" ||
        !isFinite(c.lat) ||
        !isFinite(c.lng)
      ) {
        continue;
      }
      const el = document.createElement("button");
      el.type = "button";
      el.setAttribute("aria-label", `${c.display} — ${c.venues.length} venues`);
      el.style.cssText = [
        "width:14px",
        "height:14px",
        "border-radius:9999px",
        `background:${BRASS}`,
        "border:2px solid #fff",
        "box-shadow:0 1px 3px rgba(0,0,0,0.35)",
        "cursor:pointer",
        "padding:0",
      ].join(";");

      const popup = new maplibregl.Popup({
        offset: 14,
        closeButton: false,
        closeOnClick: false,
      }).setHTML(
        `<div style="font-family:'Hanken Grotesk',system-ui,sans-serif;font-size:12px;color:${INK};padding:2px 4px"><strong style="font-family:'Fraunces',serif;font-style:italic;font-weight:400;font-size:14px">${escapeHtml(c.display)}</strong><br/><span style="color:${INK_MUTED}">${formatNum(c.venues.length)} ${c.venues.length === 1 ? "venue" : "venues"}</span></div>`,
      );

      const marker = new maplibregl.Marker({ element: el })
        .setLngLat([c.lng, c.lat])
        .setPopup(popup)
        .addTo(map);

      el.addEventListener("mouseenter", () => marker.togglePopup());
      el.addEventListener("mouseleave", () => marker.togglePopup());
      el.addEventListener("click", (ev) => {
        ev.stopPropagation();
        router.navigate({ to: "/city/$slug", params: { slug: c.slug } });
      });

      markers.push(marker);
    }

    // Fit bounds to all cities so large countries frame naturally.
    const valid = cities.filter(
      (c) => isFinite(c.lat) && isFinite(c.lng),
    );
    if (valid.length >= 2) {
      const bounds = new maplibregl.LngLatBounds();
      for (const c of valid) bounds.extend([c.lng, c.lat]);
      map.fitBounds(bounds, { padding: 40, duration: 0, maxZoom: 8 });
    }

    mapRef.current = map;

    const t = setTimeout(() => map.resize(), 50);
    const raf = requestAnimationFrame(() => map.resize());

    return () => {
      clearTimeout(t);
      cancelAnimationFrame(raf);
      for (const m of markers) m.remove();
      map.remove();
      mapRef.current = null;
    };
  }, [cities, center.lat, center.lng, router]);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    map.setStyle(styleUrl);
  }, [styleUrl]);

  return <div ref={containerRef} className="h-[460px] md:h-[560px] w-full" />;
}