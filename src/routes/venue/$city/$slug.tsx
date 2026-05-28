import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { useEffect, useRef, useState } from "react";
import { ArrowRight, MapPin, Phone, Globe, Clock } from "lucide-react";

import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Compass } from "@/components/Compass";

import {
  getVenue,
  getRelatedVenues,
  getAwardSource,
} from "@/lib/venues";
import type { Award, Venue } from "@/lib/schema";
import {
  buildVenueStructuredData,
  buildBreadcrumbStructuredData,
} from "@/lib/structured-data";
import { CITIES_BY_SLUG } from "@/lib/cities";

const SITE_URL = "https://compasseats.com";
const DEFAULT_OG_IMAGE = `${SITE_URL}/og-image.jpg`;

// ---------------------------------------------------------------------------
// Route
// ---------------------------------------------------------------------------

export const Route = createFileRoute("/venue/$city/$slug")({
  // Active venue pages are baked at build time — see vite.config.ts prerender.
  staticData: { prerender: true },
  loader: ({ params }) => {
    const venue = getVenue(params.city, params.slug);
    if (!venue || venue.status !== "active") throw notFound();
    return { venue };
  },
  head: ({ loaderData }) => {
    const v = loaderData?.venue;
    if (!v) {
      return { meta: [{ title: "Venue not found · CompassEats" }] };
    }

    const top = pickTopAward(v.awards);
    const topLabel = top
      ? `${prettyAwardSource(top.source)} ${top.category}`
      : v.type === "bar"
      ? "Cocktail bar"
      : "Restaurant";

    const title = `${v.name} — ${topLabel} · ${v.city_display} | CompassEats`;
    const description = buildMetaDescription(v);
    const canonical = `${SITE_URL}/venue/${v.city_slug}/${v.slug}`;
    const cityHero = CITIES_BY_SLUG[v.city_slug]?.imageUrl;
    const image = v.photo_url ?? cityHero ?? DEFAULT_OG_IMAGE;

    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: canonical },
        { property: "og:type", content: "restaurant.restaurant" },
        { property: "og:image", content: image },
        { name: "twitter:card", content: "summary_large_image" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
        { name: "twitter:image", content: image },
      ],
      links: [{ rel: "canonical", href: canonical }],
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(buildVenueStructuredData(v)),
        },
        {
          type: "application/ld+json",
          children: JSON.stringify(buildBreadcrumbStructuredData(v)),
        },
      ],
    };
  },
  component: VenuePage,
  notFoundComponent: () => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <Compass size={40} />
      <h1 className="mt-4 font-display text-3xl font-light italic text-foreground">
        We haven't charted this one yet.
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Try browsing the city or head back home.
      </p>
      <Link
        to="/"
        className="mt-6 inline-block text-sm text-accent-strong underline"
      >
        Back home
      </Link>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <h1 className="text-2xl font-light">Something went wrong</h1>
      <p className="mt-2 text-sm text-muted-foreground">{error.message}</p>
    </div>
  ),
});

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

function VenuePage() {
  const { venue } = Route.useLoaderData() as { venue: Venue };
  const related = getRelatedVenues(venue, 4);

  const top = pickTopAward(venue.awards);
  const eyebrow = `${venue.type === "bar" ? "Cocktail bar" : "Restaurant"} · ${
    venue.neighborhood ?? venue.city_display
  }`;
  const subtitle = buildSubtitle(venue, top);
  const groupedAwards = groupAwardsBySource(venue.awards);
  const blurb = venue.blurb_long?.trim() || venue.blurb_short?.trim() || buildAutoSummary(venue.awards);

  const reservationHref = venue.reservation_url ?? venue.website ?? null;
  const reservationLabel = venue.reservation_url ? "Take me there →" : "View website →";

  const distinctSources = Array.from(
    new Set<string>(venue.awards.map((a: Award) => a.source)),
  );

  return (
    <main className="relative min-h-screen bg-background">
      {/* Hero */}
      <section className="border-b border-border bg-card/40">
        <div className="mx-auto max-w-5xl px-6 py-10 md:py-14">
          <nav className="flex flex-wrap items-center gap-1.5 text-xs text-muted-foreground">
            <Link to="/" className="hover:text-accent-strong">Home</Link>
            <span aria-hidden>›</span>
            <Link
              to="/city/$slug"
              params={{ slug: venue.city_slug }}
              className="hover:text-accent-strong"
            >
              {venue.city_display}
            </Link>
            <span aria-hidden>›</span>
            <span className="text-foreground">{venue.name}</span>
          </nav>

          <p className="mt-6 text-xs font-medium uppercase tracking-[0.25em] text-accent-strong">
            {eyebrow}
          </p>
          <h1 className="mt-3 font-display text-4xl font-light italic tracking-tight text-foreground md:text-6xl">
            {venue.name}
          </h1>
          {subtitle && (
            <p className="mt-4 max-w-2xl text-base text-muted-foreground md:text-lg">
              {subtitle}
            </p>
          )}
        </div>
      </section>

      <div className="mx-auto grid max-w-5xl gap-12 px-6 py-12 md:grid-cols-[1fr_320px]">
        {/* Main column */}
        <div className="min-w-0">
          {/* Awards rail */}
          {venue.awards.length > 0 && (
            <section>
              <h2 className="text-xs font-semibold uppercase tracking-[0.2em] text-muted-foreground">
                Charted by
              </h2>
              <div className="mt-4 -mx-2 flex snap-x gap-3 overflow-x-auto pb-2 px-2">
                {groupedAwards.map((g) => (
                  <Card
                    key={g.source}
                    className="min-w-[220px] snap-start border-border bg-card"
                  >
                    <CardContent className="p-4">
                      <p className="font-display text-sm font-medium text-accent-strong">
                        {prettyAwardSource(g.source)}
                      </p>
                      <ul className="mt-2 space-y-1">
                        {g.entries.map((a, i) => (
                          <li key={i} className="text-sm text-foreground">
                            <span className="font-medium">{a.year}</span>{" "}
                            <span className="text-muted-foreground">— {a.category}</span>
                          </li>
                        ))}
                      </ul>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </section>
          )}

          {/* Editorial blurb */}
          <section className="mt-12">
            <p className="text-xs font-medium uppercase tracking-[0.25em] text-accent-strong">
              We've charted {venue.name}.
            </p>
            <div className="prose-venue mt-4 space-y-4 font-display text-lg font-light leading-relaxed text-foreground md:text-xl">
              {blurb.split(/\n\n+/).map((p, i) => (
                <p key={i}>{p}</p>
              ))}
            </div>
          </section>

          {/* Map */}
          <section className="mt-12">
            <h2 className="mb-4 text-xs font-semibold uppercase tracking-[0.2em] text-muted-foreground">
              On the map
            </h2>
            <SinglePinMap lat={venue.lat} lng={venue.lng} name={venue.name} />
          </section>

          {/* Related */}
          {related.length > 0 && (
            <section className="mt-16">
              <h2 className="font-display text-2xl font-light italic text-foreground">
                Other charted spots in {venue.city_display}
              </h2>
              <p className="mt-1 text-sm text-muted-foreground">Worth the detour.</p>
              <div className="mt-6 grid gap-3 sm:grid-cols-2">
                {related.map((r) => (
                  <RelatedVenueCard key={r.id} venue={r} />
                ))}
              </div>
            </section>
          )}
        </div>

        {/* Facts column */}
        <aside className="space-y-6 md:sticky md:top-24 md:self-start">
          <Card className="border-border bg-card">
            <CardContent className="space-y-5 p-5">
              {reservationHref && (
                <a
                  href={reservationHref}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-block w-full"
                >
                  <Button
                    className="w-full bg-[hsl(var(--brand-brass,38_50%_57%))] text-background hover:bg-[hsl(var(--brand-brass,38_50%_57%))]/90"
                    style={{ backgroundColor: "#C6A15B", color: "#1a1a1a" }}
                  >
                    {reservationLabel}
                  </Button>
                </a>
              )}

              <FactRow icon={<MapPin className="h-4 w-4" />} label="Address">
                <p className="text-foreground">{venue.address}</p>
                <p className="text-muted-foreground">
                  {venue.city_display}, {venue.country}
                </p>
              </FactRow>

              {venue.phone && (
                <FactRow icon={<Phone className="h-4 w-4" />} label="Phone">
                  <a
                    href={`tel:${venue.phone}`}
                    className="text-foreground hover:text-accent-strong"
                  >
                    {venue.phone}
                  </a>
                </FactRow>
              )}

              {venue.website && (
                <FactRow icon={<Globe className="h-4 w-4" />} label="Website">
                  <a
                    href={venue.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="break-all text-foreground hover:text-accent-strong"
                  >
                    {prettyHost(venue.website)}
                  </a>
                </FactRow>
              )}

              {venue.hours && <HoursBlock hours={venue.hours} />}

              {venue.price_tier && (
                <FactRow label="Price">
                  <PriceTierPills tier={venue.price_tier} />
                </FactRow>
              )}

              {venue.cuisine_tags.length > 0 && (
                <FactRow label="Cuisine">
                  <div className="flex flex-wrap gap-1.5">
                    {venue.cuisine_tags.map((t) => (
                      <Badge key={t} variant="secondary" className="font-normal">
                        {t}
                      </Badge>
                    ))}
                  </div>
                </FactRow>
              )}
            </CardContent>
          </Card>
        </aside>
      </div>

      {/* Credits footer */}
      <section className="border-t border-border bg-card/40">
        <div className="mx-auto max-w-5xl px-6 py-8 text-xs text-muted-foreground">
          <span className="font-semibold uppercase tracking-[0.2em] text-accent-strong">
            Charted by
          </span>{" "}
          <span className="ml-2">
            {distinctSources.length > 0
              ? distinctSources.map(prettyAwardSource).join(" · ")
              : "CompassEats editors"}
          </span>
          {venue.last_verified && (
            <span className="ml-2">· Last verified {venue.last_verified}</span>
          )}
        </div>
      </section>
    </main>
  );
}

// ---------------------------------------------------------------------------
// Subcomponents
// ---------------------------------------------------------------------------

function FactRow({
  icon,
  label,
  children,
}: {
  icon?: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <div className="flex items-center gap-1.5 text-[10px] font-semibold uppercase tracking-[0.18em] text-muted-foreground">
        {icon}
        <span>{label}</span>
      </div>
      <div className="mt-1.5 text-sm leading-relaxed">{children}</div>
    </div>
  );
}

type DayKey = "mon" | "tue" | "wed" | "thu" | "fri" | "sat" | "sun";
const DAY_LABELS: { key: DayKey; label: string }[] = [
  { key: "mon", label: "Mon" },
  { key: "tue", label: "Tue" },
  { key: "wed", label: "Wed" },
  { key: "thu", label: "Thu" },
  { key: "fri", label: "Fri" },
  { key: "sat", label: "Sat" },
  { key: "sun", label: "Sun" },
];

function HoursBlock({ hours }: { hours: NonNullable<Venue["hours"]> }) {
  if (hours.note) {
    return (
      <FactRow icon={<Clock className="h-4 w-4" />} label="Hours">
        <p className="text-foreground">{hours.note}</p>
      </FactRow>
    );
  }
  return (
    <FactRow icon={<Clock className="h-4 w-4" />} label="Hours">
      <table className="w-full text-sm">
        <tbody>
          {DAY_LABELS.map(({ key, label }) => {
            const ranges = hours[key];
            return (
              <tr key={key} className="border-b border-border/40 last:border-0">
                <td className="py-1 pr-3 text-muted-foreground">{label}</td>
                <td className="py-1 text-right text-foreground">
                  {ranges && ranges.length > 0
                    ? ranges.map((r) => `${r.open}–${r.close}`).join(", ")
                    : <span className="text-muted-foreground">Closed</span>}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </FactRow>
  );
}

function PriceTierPills({ tier }: { tier: "$" | "$$" | "$$$" | "$$$$" }) {
  const active = tier.length;
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4].map((n) => (
        <span
          key={n}
          className={`inline-flex h-6 w-6 items-center justify-center rounded-full border text-xs ${
            n <= active
              ? "border-transparent bg-foreground text-background"
              : "border-border text-muted-foreground"
          }`}
        >
          $
        </span>
      ))}
    </div>
  );
}

function RelatedVenueCard({ venue }: { venue: Venue }) {
  const top = pickTopAward(venue.awards);
  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: venue.city_slug, slug: venue.slug }}
      className="group block"
    >
      <Card className="h-full border-border bg-card transition-colors hover:border-accent-strong/50">
        <CardContent className="flex h-full flex-col gap-2 p-4">
          <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
            {venue.type === "bar" ? "Cocktail bar" : "Restaurant"}
            {venue.neighborhood ? ` · ${venue.neighborhood}` : ""}
          </p>
          <h3 className="font-display text-lg font-light italic text-foreground group-hover:text-accent-strong">
            {venue.name}
          </h3>
          {top && (
            <p className="text-xs text-muted-foreground">
              {prettyAwardSource(top.source)} · {top.category}
            </p>
          )}
          <span className="mt-auto inline-flex items-center gap-1 text-xs text-accent-strong">
            View <ArrowRight className="h-3 w-3" />
          </span>
        </CardContent>
      </Card>
    </Link>
  );
}

// Tiny single-pin map. Uses the same Google Maps loader as VenueMap but
// kept inline to avoid coupling to its multi-pin signature.
function SinglePinMap({
  lat,
  lng,
  name,
}: {
  lat: number;
  lng: number;
  name: string;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let cancelled = false;
    loadGoogleMaps()
      .then((g) => {
        if (cancelled || !containerRef.current) return;
        const map = new g.maps.Map(containerRef.current, {
          center: { lat, lng },
          zoom: 15,
          scrollwheel: false,
          gestureHandling: "cooperative",
          streetViewControl: false,
          mapTypeControl: false,
          fullscreenControl: false,
        });
        const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="36" height="44" viewBox="0 0 34 42"><path d="M17 0C7.6 0 0 6.6 0 14.7c0 11 17 27.3 17 27.3s17-16.3 17-27.3C34 6.6 26.4 0 17 0z" fill="#C6A15B" stroke="#fff" stroke-width="2"/><circle cx="17" cy="15" r="5" fill="#1a1a1a"/></svg>`;
        new g.maps.Marker({
          map,
          position: { lat, lng },
          title: name,
          icon: {
            url: `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`,
            scaledSize: new g.maps.Size(36, 44),
            anchor: new g.maps.Point(18, 42),
          },
        });
        setReady(true);
      })
      .catch((e) => setError((e as Error).message));
    return () => {
      cancelled = true;
    };
  }, [lat, lng, name]);

  if (error) {
    return (
      <div className="flex h-72 w-full items-center justify-center rounded-xl border border-border bg-muted/40 text-sm text-muted-foreground md:h-96">
        Map unavailable
      </div>
    );
  }

  return (
    <div className="relative h-72 w-full overflow-hidden rounded-xl border border-border md:h-96">
      <div ref={containerRef} className="h-full w-full" />
      {!ready && <div className="absolute inset-0 animate-pulse bg-muted/40" />}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Google Maps loader (shared promise per page load)
// ---------------------------------------------------------------------------

let mapsLoaderPromise: Promise<typeof google> | null = null;
function loadGoogleMaps(): Promise<typeof google> {
  if (typeof window === "undefined") return Promise.reject(new Error("SSR"));
  const w = window as unknown as { google?: typeof google };
  if (w.google?.maps) return Promise.resolve(w.google);
  if (mapsLoaderPromise) return mapsLoaderPromise;

  const key = import.meta.env.VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_BROWSER_KEY as
    | string
    | undefined;
  const trackingId = import.meta.env
    .VITE_LOVABLE_CONNECTOR_GOOGLE_MAPS_TRACKING_ID as string | undefined;
  if (!key) return Promise.reject(new Error("Google Maps browser key missing"));

  mapsLoaderPromise = new Promise<typeof google>((resolve, reject) => {
    const cb = `__initGmaps_${Math.random().toString(36).slice(2)}`;
    (window as unknown as Record<string, unknown>)[cb] = () => {
      resolve((window as unknown as { google: typeof google }).google);
      delete (window as unknown as Record<string, unknown>)[cb];
    };
    const params = new URLSearchParams({
      key,
      loading: "async",
      callback: cb,
      libraries: "marker",
    });
    if (trackingId) params.set("channel", trackingId);
    const s = document.createElement("script");
    s.src = `https://maps.googleapis.com/maps/api/js?${params.toString()}`;
    s.async = true;
    s.defer = true;
    s.onerror = () => {
      mapsLoaderPromise = null;
      reject(new Error("Failed to load Google Maps"));
    };
    document.head.appendChild(s);
  });
  return mapsLoaderPromise;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const AWARD_PRESTIGE: Record<string, number> = {
  michelin: 0,
  "worlds-50-best-restaurants": 1,
  "worlds-50-best-bars": 1,
  "best-chef-awards": 2,
  "la-liste": 3,
  "james-beard": 4,
  "spirited-awards": 4,
  "forbes-travel-guide": 5,
  "gault-millau": 5,
  tabelog: 6,
  oad: 6,
};

function pickTopAward(awards: Award[]): Award | undefined {
  if (awards.length === 0) return undefined;
  return [...awards].sort((a, b) => {
    const pa = AWARD_PRESTIGE[a.source] ?? 99;
    const pb = AWARD_PRESTIGE[b.source] ?? 99;
    if (pa !== pb) return pa - pb;
    return b.year - a.year;
  })[0];
}

function prettyAwardSource(slug: string): string {
  return getAwardSource(slug)?.name ?? slug;
}

function groupAwardsBySource(awards: Award[]) {
  const map = new Map<string, Award[]>();
  for (const a of awards) {
    if (!map.has(a.source)) map.set(a.source, []);
    map.get(a.source)!.push(a);
  }
  // sort each group by year desc, then sort groups by prestige
  for (const [, entries] of map) entries.sort((a, b) => b.year - a.year);
  return Array.from(map.entries())
    .sort((a, b) => (AWARD_PRESTIGE[a[0]] ?? 99) - (AWARD_PRESTIGE[b[0]] ?? 99))
    .map(([source, entries]) => ({ source, entries }));
}

function buildSubtitle(venue: Venue, top: Award | undefined): string {
  const parts: string[] = [];
  if (top) parts.push(`${top.category} · ${prettyAwardSource(top.source)}`);
  if (venue.cuisine_tags.length > 0) {
    parts.push(
      venue.cuisine_tags
        .slice(0, 3)
        .map((t) => t.charAt(0).toUpperCase() + t.slice(1))
        .join(", "),
    );
  }
  return parts.join(" · ");
}

function buildAutoSummary(awards: Award[]): string {
  if (awards.length === 0) return "A charted destination on CompassEats.";
  const lines = groupAwardsBySource(awards).slice(0, 3).map((g) => {
    const years = g.entries.map((e) => e.year).slice(0, 3).join(", ");
    const cat = g.entries[0].category;
    return `Recognized by ${prettyAwardSource(g.source)} (${cat}, ${years}).`;
  });
  return lines.join(" ");
}

function buildMetaDescription(v: Venue): string {
  const raw = v.blurb_short?.trim() || buildAutoSummary(v.awards);
  return raw.length > 155 ? raw.slice(0, 152).trimEnd() + "…" : raw;
}

function prettyHost(url: string): string {
  try {
    return new URL(url).host.replace(/^www\./, "");
  } catch {
    return url;
  }
}