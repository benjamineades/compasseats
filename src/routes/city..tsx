// src/routes/city.$slug.tsx
// ─────────────────────────────────────────────────────────────────────────────
// CompassEats — Static City Page
// ─────────────────────────────────────────────────────────────────────────────

import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState } from "react";

import { getCity, getVenuesByCity, getAwardSource } from "@/lib/venues";
import type { City, Venue, Award } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

// Brand brass + ink for map paint (MapLibre paint values must be literal
// strings; these mirror the tokens in src/styles.css).
const BRASS = "#C6A15B";
const INK = "#23211E";

// ── Route definition ────────────────────────────────────────────────────────
export const Route = createFileRoute("/city/")({
  staticData: { prerender: true },
  loader: ({ params }) => {
    const city = getCity(params.slug);
    if (!city) throw notFound();
    const venues = getVenuesByCity(params.slug)
      .filter((v) => v.awards.length > 0)
      .sort(byAwardPrestige);
    return { city, venues };
  },
  head: ({ loaderData }) => {
    if (!loaderData) return {};
    const { city, venues } = loaderData as { city: City; venues: Venue[] };
    const title = `${city.display}, charted — ${venues.length} of the world's best · CompassEats`;
    const description = buildMetaDescription(city, venues);
    const url = `${SITE_URL}/city/${city.slug}`;
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:type", content: "article" },
        { property: "og:url", content: url },
        ...(city.hero_image_url
          ? [{ property: "og:image", content: city.hero_image_url }]
          : []),
        {
          name: "twitter:card",
          content: city.hero_image_url ? "summary_large_image" : "summary",
        },
      ],
      links: [{ rel: "canonical", href: url }],
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(buildCityJsonLd(city, venues)),
        },
      ],
    };
  },
  component: CityPage,
  notFoundComponent: CityNotFound,
});

// ── Page ────────────────────────────────────────────────────────────────────
type Filter = "all" | "restaurants" | "bars";

function CityPage() {
  const { city, venues } = Route.useLoaderData() as {
    city: City;
    venues: Venue[];
  };
  const [filter, setFilter] = useState<Filter>("all");

  const counts = useMemo(
    () => ({
      all: venues.length,
      restaurants: venues.filter((v) => v.type === "restaurant").length,
      bars: venues.filter((v) => v.type === "bar").length,
    }),
    [venues],
  );

  const filtered = useMemo(() => {
    if (filter === "all") return venues;
    const want = filter === "bars" ? "bar" : "restaurant";
    return venues.filter((v) => v.type === want);
  }, [filter, venues]);

  const sourceCount = useMemo(() => {
    const sources = new Set<string>();
    venues.forEach((v) => v.awards.forEach((a) => sources.add(a.source)));
    return sources.size;
  }, [venues]);

  return (
    <main className="min-h-screen bg-background">
      {/* Breadcrumb */}
      <div className="mx-auto max-w-6xl px-6 pt-6 text-xs text-muted-foreground">
        <Link to="/" className="hover:text-accent-strong">
          Home
        </Link>
        <span className="mx-2 opacity-50">/</span>
        <span className="text-foreground">{city.display}, charted</span>
      </div>

      {/* Hero */}
      <section className="relative mx-auto mt-6 max-w-6xl overflow-hidden rounded-2xl border border-border bg-card">
        {city.hero_image_url && (
          <div className="absolute inset-0">
            <img
              src={city.hero_image_url}
              alt={city.display}
              className="h-full w-full object-cover opacity-40"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-background via-background/70 to-transparent" />
          </div>
        )}
        <div className="relative px-8 py-16 md:py-24">
          <div className="text-[10px] font-semibold uppercase tracking-[0.3em] text-accent-strong">
            {city.country}
          </div>
          <h1 className="mt-3 font-display text-5xl font-light italic text-foreground md:text-7xl">
            {city.display}, charted.
          </h1>
          {city.blurb && (
            <p className="mt-4 max-w-2xl text-base text-muted-foreground md:text-lg">
              {city.blurb}
            </p>
          )}
        </div>
      </section>

      {/* Stats strip */}
      <section className="mx-auto mt-8 grid max-w-6xl grid-cols-2 gap-px overflow-hidden rounded-xl border border-border bg-border md:grid-cols-4">
        <Stat label="Venues" value={counts.all} />
        <Stat label="Restaurants" value={counts.restaurants} />
        <Stat label="Bars" value={counts.bars} />
        <Stat label="Sources" value={sourceCount} />
      </section>

      {/* Map */}
      {city.lat != null && city.lng != null && (
        <section className="mx-auto mt-10 max-w-6xl px-6">
          <h2 className="mb-4 font-display text-2xl font-light italic">
            On the map
          </h2>
          <div className="overflow-hidden rounded-xl border border-border">
            <CityMap
              center={{ lat: city.lat, lng: city.lng }}
              venues={venues}
              citySlug={city.slug}
            />
          </div>
        </section>
      )}

      {/* Filter + grid */}
      <section className="mx-auto mt-12 max-w-6xl px-6 pb-20">
        <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
          <h2 className="font-display text-2xl font-light italic">The list</h2>
          <FilterPills value={filter} onChange={setFilter} counts={counts} />
        </div>

        {filtered.length === 0 ? (
          <p className="rounded-xl border border-border bg-card/40 px-6 py-12 text-center text-sm italic text-muted-foreground">
            We haven't charted any {filter === "bars" ? "bars" : "restaurants"}{" "}
            here yet.
          </p>
        ) : (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {filtered.map((v) => (
              <VenueCard key={v.slug} venue={v} citySlug={city.slug} />
            ))}
          </div>
        )}
      </section>
    </main>
  );
}

// ── Subcomponents ───────────────────────────────────────────────────────────

function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="bg-card px-6 py-6 text-center">
      <div className="font-display text-3xl font-light text-foreground">
        {value.toLocaleString()}
      </div>
      <div className="mt-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-muted-foreground">
        {label}
      </div>
    </div>
  );
}

function FilterPills({
  value,
  onChange,
  counts,
}: {
  value: Filter;
  onChange: (v: Filter) => void;
  counts: { all: number; restaurants: number; bars: number };
}) {
  const items: Array<{ key: Filter; label: string }> = [
    { key: "all", label: "All" },
    { key: "restaurants", label: "Restaurants" },
    { key: "bars", label: "Bars" },
  ];
  return (
    <div className="flex flex-wrap gap-2">
      {items.map((it) => {
        const active = value === it.key;
        return (
          <button
            key={it.key}
            onClick={() => onChange(it.key)}
            className={`inline-flex items-center gap-2 rounded-full border px-4 py-2 text-xs font-medium transition-colors ${
              active
                ? "border-primary bg-primary text-primary-foreground"
                : "border-border text-muted-foreground hover:border-accent-strong/40 hover:text-accent-strong"
            }`}
          >
            {it.label}
            <span
              className={`rounded-full px-1.5 text-[10px] ${
                active
                  ? "bg-primary-foreground/20 text-primary-foreground"
                  : "bg-muted text-muted-foreground"
              }`}
            >
              {counts[it.key]}
            </span>
          </button>
        );
      })}
    </div>
  );
}

function VenueCard({ venue, citySlug }: { venue: Venue; citySlug: string }) {
  const top = venue.awards[0];
  const topName = top ? getAwardSource(top.source)?.name ?? top.source : null;
  const extra = Math.max(0, venue.awards.length - 1);

  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: citySlug, slug: venue.slug }}
      className="group block rounded-xl border border-border bg-card p-5 transition-colors hover:border-accent-strong/50"
    >
      <div className="flex items-center gap-2 text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
        <span>{venue.type === "bar" ? "Cocktail bar" : "Restaurant"}</span>
        {venue.neighborhood && (
          <>
            <span className="opacity-50">·</span>
            <span className="text-muted-foreground">{venue.neighborhood}</span>
          </>
        )}
      </div>
      <div className="mt-2 font-display text-xl font-light italic text-foreground group-hover:text-accent-strong">
        {venue.name}
      </div>
      {topName && (
        <div className="mt-2 text-xs text-muted-foreground">
          {topName}
          {top?.rank ? ` · #${top.rank}` : ""}
          {extra > 0 && (
            <span className="text-accent-strong"> +{extra} more</span>
          )}
        </div>
      )}
    </Link>
  );
}

function CityNotFound() {
  return (
    <div className="mx-auto max-w-2xl px-6 py-24 text-center">
      <div className="text-[10px] font-semibold uppercase tracking-[0.3em] text-accent-strong">
        404
      </div>
      <h1 className="mt-3 font-display text-4xl font-light italic">
        We haven't charted this one yet.
      </h1>
      <p className="mt-4 text-sm text-muted-foreground">
        Try a nearby city — we've mapped the best tables in many of them, and
        we're roaming further every week.
      </p>
      <Link
        to="/"
        className="mt-6 inline-block text-sm text-accent-strong underline"
      >
        Find your bearings →
      </Link>
    </div>
  );
}

// ── Map (MapLibre, lazy-init client-side) ───────────────────────────────────

function CityMap({
  center,
  venues,
  citySlug,
}: {
  center: { lat: number; lng: number };
  venues: Venue[];
  citySlug: string;
}) {
  const containerRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!containerRef.current) return;
    let cancelled = false;
    let map: any = null;

    (async () => {
      const maplibre = await import("maplibre-gl");
      await import("maplibre-gl/dist/maplibre-gl.css" as any).catch(() => {});

      if (cancelled || !containerRef.current) return;

      map = new maplibre.Map({
        container: containerRef.current,
        style:
          (import.meta as any).env?.VITE_MAPTILER_STYLE_URL ??
          "https://demotiles.maplibre.org/style.json",
        center: [center.lng, center.lat],
        zoom: 11.2,
      });

      map.on("load", () => {
        const features = venues
          .filter((v) => v.lat != null && v.lng != null)
          .map((v) => ({
            type: "Feature" as const,
            geometry: {
              type: "Point" as const,
              coordinates: [v.lng, v.lat],
            },
            properties: { name: v.name, slug: v.slug, type: v.type },
          }));

        map.addSource("venues", {
          type: "geojson",
          data: { type: "FeatureCollection", features },
          cluster: true,
          clusterRadius: 38,
          clusterMaxZoom: 14,
        });

        map.addLayer({
          id: "clusters",
          type: "circle",
          source: "venues",
          filter: ["has", "point_count"],
          paint: {
            "circle-color": BRASS,
            "circle-opacity": 0.85,
            "circle-stroke-color": INK,
            "circle-stroke-width": 2,
            "circle-radius": [
              "step",
              ["get", "point_count"],
              16,
              10,
              22,
              50,
              28,
            ],
          },
        });
        map.addLayer({
          id: "cluster-count",
          type: "symbol",
          source: "venues",
          filter: ["has", "point_count"],
          layout: {
            "text-field": "{point_count_abbreviated}",
            "text-size": 12,
            "text-font": ["Noto Sans Regular"],
          },
          paint: { "text-color": INK },
        });

        map.addLayer({
          id: "venue-dot",
          type: "circle",
          source: "venues",
          filter: ["!", ["has", "point_count"]],
          paint: {
            "circle-color": BRASS,
            "circle-radius": 6,
            "circle-stroke-color": INK,
            "circle-stroke-width": 1.5,
          },
        });

        map.on("click", "venue-dot", (e: any) => {
          const f = e.features?.[0];
          if (!f) return;
          const slug = f.properties.slug;
          window.location.href = `/venue/${citySlug}/${slug}`;
        });
        map.on("mouseenter", "venue-dot", () => {
          map.getCanvas().style.cursor = "pointer";
        });
        map.on("mouseleave", "venue-dot", () => {
          map.getCanvas().style.cursor = "";
        });

        map.on("click", "clusters", (e: any) => {
          const f = map.queryRenderedFeatures(e.point, {
            layers: ["clusters"],
          })[0];
          const id = f.properties.cluster_id;
          map
            .getSource("venues")
            .getClusterExpansionZoom(id, (err: any, zoom: number) => {
              if (err) return;
              map.easeTo({ center: f.geometry.coordinates, zoom });
            });
        });
      });
    })();

    return () => {
      cancelled = true;
      if (map) map.remove();
    };
  }, [center.lat, center.lng, venues, citySlug]);

  return <div ref={containerRef} style={{ width: "100%", height: 420 }} />;
}

// ── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Prestige weight from the AWARD_SOURCES tier metadata.
 * Global guides (Michelin, World's 50 Best) outrank regional ones.
 * "michelin" and "worlds-50-best-restaurants" get a small extra bump
 * because they're the headline accolades in the brand voice.
 */
function awardWeight(a: Award): number {
  const src = getAwardSource(a.source);
  if (!src) return 0;
  let w = src.tier === "global" ? 3 : 2;
  if (
    src.slug === "michelin" ||
    src.slug === "worlds-50-best-restaurants" ||
    src.slug === "worlds-50-best-bars"
  ) {
    w += 2;
  }
  // Lower rank number = more prestigious, gives a tiny bump.
  if (a.rank && a.rank <= 50) w += (51 - a.rank) / 100;
  return w;
}

function topAwardWeight(v: Venue): number {
  return v.awards.reduce((max, a) => {
    const w = awardWeight(a);
    return w > max ? w : max;
  }, 0);
}

function byAwardPrestige(a: Venue, b: Venue) {
  const diff = topAwardWeight(b) - topAwardWeight(a);
  if (diff !== 0) return diff;
  return b.awards.length - a.awards.length;
}

function buildMetaDescription(city: City, venues: Venue[]) {
  const r = venues.filter((v) => v.type === "restaurant").length;
  const b = venues.filter((v) => v.type === "bar").length;
  const parts: string[] = [];
  if (r) parts.push(`${r} restaurant${r === 1 ? "" : "s"}`);
  if (b) parts.push(`${b} bar${b === 1 ? "" : "s"}`);
  const list = parts.join(" and ");
  return `${city.display}, charted — ${list} chosen by the guides that matter, from Michelin to World's 50 Best. The world's best, wherever you are.`;
}

function buildCityJsonLd(city: City, venues: Venue[]) {
  return {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: `${city.display}, charted`,
    description: `Top restaurants and cocktail bars in ${city.display}, ranked from authoritative guides.`,
    url: `${SITE_URL}/city/${city.slug}`,
    mainEntity: {
      "@type": "ItemList",
      numberOfItems: venues.length,
      itemListElement: venues.slice(0, 50).map((v, i) => ({
        "@type": "ListItem",
        position: i + 1,
        url: `${SITE_URL}/venue/${city.slug}/${v.slug}`,
        name: v.name,
      })),
    },
  };
}
