import { useEffect, useMemo, useRef, useState } from "react";
import {
  createFileRoute,
  Link,
  notFound,
  useRouter,
} from "@tanstack/react-router";
import maplibregl from "maplibre-gl";
import { z } from "zod";

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import regionsData from "../../data/regions.json";
import { RegionSchema, type Region } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";
const BRASS = "#C6A15B";

function formatNum(n: number): string {
  return n.toLocaleString("en-US");
}

export const Route = createFileRoute("/region/$slug")({
  staticData: { prerender: true },
  loader: ({ params }) => {
    const regions = z.array(RegionSchema).parse(regionsData);
    const region = regions.find((r) => r.slug === params.slug);
    if (!region) throw notFound();
    return { region };
  },
  head: ({ loaderData }) => {
    const region = loaderData?.region;
    if (!region) {
      return { meta: [{ title: "Region not found | CompassEats" }] };
    }
    const title = `${region.display} — ${formatNum(region.venue_count)} venues across ${formatNum(region.city_count)} cities | CompassEats`;
    const description = `Award-winning restaurants and bars across ${region.display}${region.country ? `, ${region.country}` : ""}.`;
    const url = `${SITE_URL}/region/${region.slug}`;
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
        <h1 className="font-display text-3xl italic">Region didn't load</h1>
        <p className="mt-3 text-sm" style={{ color: INK_MUTED }}>
          {error.message}
        </p>
        <div className="mt-6">
          <Link to="/regions" className="text-sm" style={{ color: BRONZE }}>
            ← All regions
          </Link>
        </div>
      </div>
    </main>
  ),
  notFoundComponent: () => (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-2xl px-6 py-24 text-center">
        <h1 className="font-display text-3xl italic">Region not found</h1>
        <p className="mt-3 text-sm" style={{ color: INK_MUTED }}>
          We don't have a region by that slug.
        </p>
        <div className="mt-6">
          <Link to="/regions" className="text-sm" style={{ color: BRONZE }}>
            ← All regions
          </Link>
        </div>
      </div>
    </main>
  ),
  component: RegionPage,
});

function RegionPage() {
  const { region } = Route.useLoaderData() as { region: Region };

  const multiCountry = useMemo(() => {
    const set = new Set<string>();
    for (const c of region.cities) set.add(c.country);
    return set.size > 1;
  }, [region]);

  const citiesWithVenues = useMemo(
    () => region.cities.filter((c) => c.venue_count > 0),
    [region],
  );

  return (
    <main style={{ backgroundColor: PAPER, color: INK }} className="min-h-screen">
      <div className="mx-auto max-w-5xl px-6 py-16 md:py-20">
        <header>
          <Link
            to="/regions"
            className="text-xs uppercase tracking-[0.2em]"
            style={{ color: BRONZE }}
          >
            ← Regions
          </Link>
          <h1
            className="mt-5 font-display text-5xl md:text-6xl font-light italic tracking-tight"
            style={{ color: INK }}
          >
            {region.display}
          </h1>
          {region.country ? (
            <p className="mt-3 text-base md:text-lg" style={{ color: INK_MUTED }}>
              {region.country}
            </p>
          ) : null}
          <div className="mt-5 inline-flex">
            <span
              className="rounded-full border px-3 py-1 text-xs tabular-nums"
              style={{ borderColor: HAIRLINE, color: INK_MUTED }}
            >
              {formatNum(region.venue_count)} venues · {formatNum(region.city_count)} cities
            </span>
          </div>
        </header>

        <section className="mt-12 md:mt-16">
          <p
            className="mb-3 text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: BRONZE }}
          >
            On the map
          </p>
          <div className="overflow-hidden rounded-xl border" style={{ borderColor: HAIRLINE }}>
            <RegionMap region={region} />
          </div>
        </section>

        <section className="mt-16 md:mt-20">
          <p
            className="mb-3 text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: BRONZE }}
          >
            Cities in {region.display}
          </p>
          <Accordion
            type="multiple"
            className="border-t"
            style={{ borderColor: HAIRLINE }}
          >
            {citiesWithVenues.map((c) => {
              const venues = c.venues ?? [];
              return (
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
                      {multiCountry ? (
                        <span
                          className="ml-3 text-[11px] uppercase tracking-[0.15em]"
                          style={{ color: INK_MUTED }}
                        >
                          {c.country}
                        </span>
                      ) : null}
                    </Link>
                    <AccordionTrigger
                      className="shrink-0 gap-2 py-0 hover:no-underline [&>svg]:h-4 [&>svg]:w-4"
                    >
                      <span className="text-xs tabular-nums" style={{ color: INK_MUTED }}>
                        {formatNum(c.venue_count)} {c.venue_count === 1 ? "venue" : "venues"}
                      </span>
                    </AccordionTrigger>
                  </div>
                  <AccordionContent className="pb-4">
                    {venues.length > 0 ? (
                      <ul className="grid gap-x-6 gap-y-1.5 pl-1 sm:grid-cols-2 lg:grid-cols-3">
                        {venues.map((v) => (
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
              );
            })}
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

function RegionMap({ region }: { region: Region }) {
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
      center: [region.center_lng, region.center_lat],
      zoom: 7,
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
    for (const c of region.cities.filter((c) => c.venue_count > 0)) {
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
      el.setAttribute("aria-label", `${c.display} — ${c.venue_count} venues`);
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
        `<div style="font-family:'Hanken Grotesk',system-ui,sans-serif;font-size:12px;color:${INK};padding:2px 4px"><strong style="font-family:'Fraunces',serif;font-style:italic;font-weight:400;font-size:14px">${escapeHtml(c.display)}</strong><br/><span style="color:${INK_MUTED}">${formatNum(c.venue_count)} ${c.venue_count === 1 ? "venue" : "venues"}</span></div>`,
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
  }, [region, router]);

  // React to theme changes: swap the style when isDark flips.
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    map.setStyle(styleUrl);
  }, [styleUrl]);

  return <div ref={containerRef} className="h-[460px] md:h-[560px] w-full" />;
}
