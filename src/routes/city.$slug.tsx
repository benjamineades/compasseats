import { ClientOnly, createFileRoute, Link, notFound } from "@tanstack/react-router";
import { lazy, useMemo, useState, useTransition, useDeferredValue } from "react";
import { ArrowRight, ChevronDown, SlidersHorizontal, X } from "lucide-react";

import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuCheckboxItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { CityHero } from "@/components/CityHero";
import { AwardBadgeRow } from "@/components/AwardBadge";
import { VenuePhoto } from "@/components/VenuePhoto";
import { CitySpotlight } from "@/components/CitySpotlight";
import { VenueRankedRow } from "@/components/VenueRankedRow";
import { formatCoord } from "@/lib/format-coords";
import { awardLabelShort } from "@/lib/award-label";

import {
  getCity,
  getVenuesByCity,
  getAwardSource,
  getAwardPrestige,
  getVenuePrestige,
} from "@/lib/venues";
import type { City, Venue } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";
const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_3 = "#34312C"; // darkest band (spotlight surface, set later)
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const BRASS = "#C6A15B";
const HAIRLINE = "rgba(35,33,30,0.12)";
const PAPER_DIM = "#E7DFCC";
const BRASS_SOFT = "#D8BE8A";
const BRASS_LINE = "rgba(198,161,91,.28)";

const VenueMap = lazy(() =>
  import("@/components/VenueMap").then((module) => ({ default: module.VenueMap })),
);

// ---------------------------------------------------------------------------
// Route
// ---------------------------------------------------------------------------

export const Route = createFileRoute("/city/$slug")({
  staticData: { prerender: true },
  loader: ({ params }) => {
    const city = getCity(params.slug);
    if (!city) throw notFound();
    const venues = getVenuesByCity(params.slug);
    return { city, venues };
  },
  head: ({ loaderData }) => {
    const c = loaderData?.city as City | undefined;
    const venues = (loaderData?.venues ?? []) as Venue[];
    if (!c) return { meta: [{ title: "City not found · CompassEats" }] };

    const title = `${c.display}, charted. — Best restaurants and bars | CompassEats`;
    const description = buildMetaDescription(c);
    const url = `${SITE_URL}/city/${c.slug}`;

    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: url },
        { property: "og:type", content: "website" },
        ...(c.hero_image_url
          ? [{ property: "og:image", content: c.hero_image_url }]
          : []),
        { name: "twitter:card", content: "summary_large_image" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
        ...(c.hero_image_url
          ? [{ name: "twitter:image", content: c.hero_image_url }]
          : []),
      ],
      links: [{ rel: "canonical", href: url }],
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(buildItemListJsonLd(c, venues)),
        },
      ],
    };
  },
  component: CityPage,
  notFoundComponent: () => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <h1 className="font-display text-3xl font-light italic">
        We haven't charted this city yet.
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Browse the cities we've mapped from the home page.
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
      <Link to="/" className="mt-4 inline-block text-accent-strong underline">
        Back home
      </Link>
    </div>
  ),
});

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

type QuickFilter = "restaurants" | "bars";

const INITIAL_ROW_CAP = 10;

function CityPage() {
  const { city, venues } = Route.useLoaderData() as {
    city: City;
    venues: Venue[];
  };

  const [quick, setQuick] = useState<Set<QuickFilter>>(new Set());
  const [awardFilters, setAwardFilters] = useState<Set<string>>(new Set());
  const [showAll, setShowAll] = useState(false);
  const [showAllBars, setShowAllBars] = useState(false);
  const [isPending, startTransition] = useTransition();

  // Deferred so the filter pills feel responsive while a large list filters.
  const deferredQuick = useDeferredValue(quick);
  const deferredAwards = useDeferredValue(awardFilters);

  const distinctSources = useMemo(() => {
    const set = new Set<string>();
    for (const v of venues) for (const a of v.awards) set.add(a.source);
    return Array.from(set).sort(
      (a, b) =>
        (prettyAwardSource(a) ?? a).localeCompare(prettyAwardSource(b) ?? b),
    );
  }, [venues]);

  const sortedVenues = useMemo(() => {
    const scoreOf = (v: Venue) => getVenuePrestige(v);
    return [...venues].sort((a, b) => {
      const sb = scoreOf(b);
      const sa = scoreOf(a);
      if (sb !== sa) return sb - sa;
      if (b.awards.length !== a.awards.length)
        return b.awards.length - a.awards.length;
      return a.name.localeCompare(b.name);
    });
  }, [venues]);

  const filtered = useMemo(() => {
    const wantRest = deferredQuick.has("restaurants");
    const wantBars = deferredQuick.has("bars");

    return sortedVenues.filter((v) => {
      if (wantRest && !wantBars && v.type !== "restaurant") return false;
      if (wantBars && !wantRest && v.type !== "bar") return false;
      if (deferredAwards.size > 0) {
        const ok = v.awards.some((a) => deferredAwards.has(a.source));
        if (!ok) return false;
      }
      return true;
    });
  }, [sortedVenues, deferredQuick, deferredAwards]);

  const toggleQuick = (id: QuickFilter) =>
    startTransition(() =>
      setQuick((prev) => {
        const next = new Set(prev);
        next.has(id) ? next.delete(id) : next.add(id);
        return next;
      }),
    );

  const toggleAward = (source: string) =>
    startTransition(() =>
      setAwardFilters((prev) => {
        const next = new Set(prev);
        next.has(source) ? next.delete(source) : next.add(source);
        return next;
      }),
    );

  const clearAll = () =>
    startTransition(() => {
      setQuick(new Set());
      setAwardFilters(new Set());
      setShowAll(false);
    });

  const noneSelected = quick.size === 0 && awardFilters.size === 0;

  const restaurants = useMemo(
    () => filtered.filter((v) => v.type !== "bar"),
    [filtered],
  );
  const bars = useMemo(
    () => filtered.filter((v) => v.type === "bar"),
    [filtered],
  );

  const visibleRestaurants = showAll
    ? restaurants
    : restaurants.slice(0, INITIAL_ROW_CAP);
  const hasMoreRestaurants = restaurants.length > INITIAL_ROW_CAP;

  const visibleBars = showAllBars ? bars : bars.slice(0, INITIAL_ROW_CAP);
  const hasMoreBars = bars.length > INITIAL_ROW_CAP;

  const restaurantCount = venues.filter((v) => v.type === "restaurant").length;
  const barCount = venues.filter((v) => v.type === "bar").length;
  const crumbs = [
    { label: "Home", to: "/" as const },
    ...(city.country ? [{ label: city.country }] : []),
    { label: city.display },
  ];
  const counts = { total: venues.length, restaurants: restaurantCount, bars: barCount };

  // MODE A — single-venue city: a generous feature, no filter bar, no list.
  if (venues.length === 1) {
    return (
      <main className="relative min-h-screen bg-background">
        <CityHero
          city={city.display}
          country={city.country}
          blurb={city.blurb}
          hueSeed={city.slug}
          imageUrl={city.hero_image_url}
          back={{ to: "/" }}
          crumbs={crumbs}
          counts={counts}
        />
        <SingleVenueFeature city={city} venue={venues[0]} />
      </main>
    );
  }

  // MODE B — multi-venue city: spotlight + map + ranked listings.
  return (
    <main className="relative min-h-screen" style={{ backgroundColor: PAPER }}>
      <CityHero
        city={city.display}
        country={city.country}
        blurb={city.blurb}
        hueSeed={city.slug}
        imageUrl={city.hero_image_url}
        back={{ to: "/" }}
        crumbs={crumbs}
        counts={counts}
      />

      <div style={{ backgroundColor: INK_3 }}>
        <nav
          className="mx-auto max-w-5xl px-6 pt-5 text-xs"
          style={{ color: "#E7DFCC" }}
          aria-label="Breadcrumb"
        >
          <Link to="/" style={{ color: "#D8BE8A" }} className="hover:underline">
            Home
          </Link>
          <span className="mx-1.5" style={{ color: "#E7DFCC" }}>›</span>
          <span>{city.country}</span>
          <span className="mx-1.5" style={{ color: "#E7DFCC" }}>›</span>
          <span>{city.display}</span>
        </nav>
      </div>

      <CitySpotlight city={city} venues={sortedVenues} />

      <section style={{ backgroundColor: PAPER }} className="py-10">
        <div className="mx-auto max-w-5xl px-6">
          <p
            className="text-[10px] font-semibold uppercase tracking-[0.25em]"
            style={{ color: BRONZE, marginBottom: 14 }}
          >
            The lay of the land · {city.display} · {formatCoord(city.lat, city.lng)}
          </p>
          <div
            className="overflow-hidden rounded-xl"
            style={{ border: `1px solid ${HAIRLINE}` }}
          >
            <ClientOnly fallback={<MapPlaceholder />}>
              <VenueMap venues={filtered} cityContext={city.slug} />
            </ClientOnly>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-5xl px-6 pb-10">
        {/* Section headline + segmented toggle row */}
        <div
          className="mb-6 flex flex-wrap items-end justify-between gap-4 pb-4"
          style={{ borderBottom: `2px solid ${INK}` }}
        >
          <h2
            className="font-display text-3xl font-light"
            style={{ color: INK }}
          >
            What&rsquo;s <em className="italic" style={{ color: BRONZE }}>charted</em> in {city.display}
          </h2>
          <div className="flex flex-wrap items-center gap-2">
            <div
              className="inline-flex items-center"
              style={{
                backgroundColor: "rgba(35,33,30,0.06)",
                padding: 4,
                borderRadius: 100,
                gap: 5,
              }}
            >
              <SegToggle
                active={noneSelected}
                onClick={clearAll}
                label="All"
              />
              <SegToggle
                active={quick.has("restaurants")}
                onClick={() => toggleQuick("restaurants")}
                label="Restaurants"
              />
              <SegToggle
                active={quick.has("bars")}
                onClick={() => toggleQuick("bars")}
                label="Cocktail Bars"
              />
            </div>

            {Array.from(awardFilters).map((src) => (
              <button
                key={src}
                type="button"
                onClick={() => toggleAward(src)}
                title="Remove filter"
                className="inline-flex h-8 items-center gap-1 rounded-full px-3 text-xs font-medium"
                style={{
                  border: `1px solid ${HAIRLINE}`,
                  backgroundColor: "#FCFAF5",
                  color: INK,
                }}
              >
                {prettyAwardSource(src)}
                <X className="h-3 w-3 opacity-80" />
              </button>
            ))}

            {distinctSources.length > 0 && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button
                    type="button"
                    className="inline-flex h-8 items-center gap-1.5 rounded-full px-3 text-xs font-medium transition-colors hover:text-[color:var(--seg-hover)]"
                    style={{
                      border: `1px solid ${HAIRLINE}`,
                      backgroundColor: "transparent",
                      color: INK_MUTED,
                      ["--seg-hover" as never]: BRONZE,
                    } as React.CSSProperties}
                  >
                    <SlidersHorizontal className="h-3.5 w-3.5" />
                    Awards
                    {awardFilters.size > 0 && (
                      <span
                        className="ml-0.5 rounded-full px-1.5 text-[10px] font-semibold"
                        style={{ backgroundColor: BRONZE, color: PAPER }}
                      >
                        {awardFilters.size}
                      </span>
                    )}
                    <ChevronDown className="h-3 w-3 opacity-70" />
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-64">
                  <DropdownMenuLabel>Filter by award</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  {distinctSources.map((src) => (
                    <DropdownMenuCheckboxItem
                      key={src}
                      checked={awardFilters.has(src)}
                      onCheckedChange={() => toggleAward(src)}
                      onSelect={(e) => e.preventDefault()}
                    >
                      {prettyAwardSource(src)}
                    </DropdownMenuCheckboxItem>
                  ))}
                </DropdownMenuContent>
              </DropdownMenu>
            )}
          </div>
        </div>

        {/* Results */}
        {isPending ? (
          <ResultsSkeleton />
        ) : filtered.length === 0 ? (
          <EmptyState onReset={clearAll} />
        ) : (
          <>
            {restaurants.length > 0 && (
              <Collapsible defaultOpen={false} className="mb-2">
                <CollapsibleTrigger
                  className="group flex w-full items-center justify-between border-b pb-3 mb-4 text-left [&[data-state=open]>svg]:rotate-180"
                  style={{ borderColor: HAIRLINE }}
                >
                  <h3 className="font-display text-2xl font-light" style={{ color: INK }}>
                    Where to <em className="italic" style={{ color: BRONZE }}>eat</em>
                    <span className="ml-2 text-base" style={{ color: INK_MUTED }}>
                      {restaurants.length}
                    </span>
                  </h3>
                  <ChevronDown
                    className="h-5 w-5 transition-transform duration-200"
                    style={{ color: INK_MUTED }}
                  />
                </CollapsibleTrigger>
                <CollapsibleContent className="overflow-hidden data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down">
                  <div className="divide-y divide-border/50">
                    {visibleRestaurants.map((v, i) => (
                      <VenueRankedRow key={v.id} venue={v} rank={i + 1} />
                    ))}
                  </div>
                  {hasMoreRestaurants && (
                    <div className="mt-6 flex justify-center">
                      <Button variant="outline" size="sm"
                        onClick={() => setShowAll((s) => !s)} className="rounded-full">
                        {showAll
                          ? "Show less"
                          : `Show all ${restaurants.length} places to eat in ${city.display} →`}
                      </Button>
                    </div>
                  )}
                </CollapsibleContent>
              </Collapsible>
            )}

            {bars.length > 0 && (
              <Collapsible defaultOpen={false} className={restaurants.length > 0 ? "mt-8" : ""}>
                <CollapsibleTrigger
                  className="group flex w-full items-center justify-between border-b pb-3 mb-4 text-left [&[data-state=open]>svg]:rotate-180"
                  style={{ borderColor: HAIRLINE }}
                >
                  <h3 className="font-display text-2xl font-light" style={{ color: INK }}>
                    Where to <em className="italic" style={{ color: BRONZE }}>drink</em>
                    <span className="ml-2 text-base" style={{ color: INK_MUTED }}>
                      {bars.length}
                    </span>
                  </h3>
                  <ChevronDown
                    className="h-5 w-5 transition-transform duration-200"
                    style={{ color: INK_MUTED }}
                  />
                </CollapsibleTrigger>
                <CollapsibleContent className="overflow-hidden data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down">
                  <div className="divide-y divide-border/50">
                    {visibleBars.map((v, i) => (
                      <VenueRankedRow key={v.id} venue={v} rank={i + 1} />
                    ))}
                  </div>
                  {hasMoreBars && (
                    <div className="mt-6 flex justify-center">
                      <Button variant="outline" size="sm"
                        onClick={() => setShowAllBars((s) => !s)} className="rounded-full">
                        {showAllBars
                          ? "Show less"
                          : `Show all ${bars.length} bars in ${city.display} →`}
                      </Button>
                    </div>
                  )}
                </CollapsibleContent>
              </Collapsible>
            )}
          </>
        )}

        {!isPending && filtered.length > 0 && (
          <p
            className="mt-8 text-center text-xs italic"
            style={{ color: INK_MUTED }}
          >
            Showing {visibleRestaurants.length + visibleBars.length} of{" "}
            {venues.length} charted spot{venues.length === 1 ? "" : "s"} in{" "}
            {city.display}.
          </p>
        )}
      </div>
    </main>
  );
}

// ---------------------------------------------------------------------------
// Single-venue feature (Mode A)
// ---------------------------------------------------------------------------

function SingleVenueFeature({ city, venue }: { city: City; venue: Venue }) {
  const where = venue.neighborhood || venue.city_display;
  const typeCap = venue.type === "bar" ? "Cocktail bar" : "Restaurant";
  const why = buildSingleWhy(venue, city);
  const pillAwards = buildPillAwards(venue);
  const hasReservation = Boolean(venue.reservation_url);
  // Show the photo layout when we have either a curated photo OR a Google
  // place id (the VenuePhoto component live-fetches from the photo worker).
  const hasPhoto = !!venue.photo_url?.trim() || !!venue.id?.trim();

  return (
    <>
      {/* Section 1 — dark feature band */}
      <section
        style={{ backgroundColor: INK_3 }}
        className="px-6 py-12 md:px-12 md:py-16"
      >
        <div className="mx-auto max-w-5xl">
          <div className="mb-5 flex items-baseline gap-3">
            <h2
              className="font-display text-2xl italic"
              style={{ color: BRASS_SOFT, fontWeight: 400 }}
            >
              The one worth knowing.
            </h2>
            <span
              className="ml-auto text-xs font-semibold uppercase"
              style={{ color: PAPER_DIM, letterSpacing: "0.16em" }}
            >
              {city.display}
            </span>
          </div>

          <div
            className={
              hasPhoto
                ? "grid items-stretch gap-8 md:grid-cols-[1.1fr_1fr] md:gap-10"
                : "mx-auto max-w-2xl text-center"
            }
          >
            {hasPhoto && (
              <div
                className="aspect-[4/5] w-full overflow-hidden rounded-xl"
                style={{ border: "1px solid rgba(255,255,255,0.08)" }}
              >
                <VenuePhoto src={venue.photo_url} placeId={venue.id} alt={venue.name} />
              </div>
            )}

            <div
              className={
                hasPhoto
                  ? "flex flex-col justify-center"
                  : "flex flex-col items-center"
              }
            >
              <p className="text-sm" style={{ color: PAPER_DIM }}>
                {typeCap} · {where}
              </p>
              <h3
                className="mt-2 font-display text-4xl md:text-5xl"
                style={{ color: PAPER, fontWeight: 300, lineHeight: 1.05 }}
              >
                {venue.name}
              </h3>
              <p
                className="max-w-prose text-base"
                style={{
                  color: PAPER,
                  fontWeight: 300,
                  lineHeight: 1.6,
                  marginTop: 14,
                }}
              >
                {why}
              </p>

              {pillAwards.length > 0 && (
                <div
                  className={
                    hasPhoto
                      ? "flex flex-wrap gap-1.5"
                      : "flex flex-wrap justify-center gap-1.5"
                  }
                  style={{ marginTop: 15 }}
                >
                  {pillAwards.map((label, i) => (
                    <span
                      key={i}
                      className="text-xs"
                      style={{
                        color: BRASS_SOFT,
                        border: `1px solid ${BRASS_LINE}`,
                        padding: "5px 11px",
                        borderRadius: 100,
                        fontWeight: 600,
                      }}
                    >
                      {label}
                    </span>
                  ))}
                </div>
              )}

              <div
                className={
                  hasPhoto
                    ? "flex flex-wrap items-center"
                    : "flex flex-wrap items-center justify-center"
                }
                style={{ marginTop: 20, gap: 10 }}
              >
                {hasReservation ? (
                  <>
                    <a
                      href={venue.reservation_url!}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-1 text-sm transition-transform hover:-translate-y-0.5"
                      style={{
                        backgroundColor: BRASS,
                        color: INK,
                        fontWeight: 600,
                        padding: "11px 22px",
                        borderRadius: 8,
                      }}
                    >
                      Reserve a table <span aria-hidden>→</span>
                    </a>
                    <Link
                      to="/venue/$city/$slug"
                      params={{ city: venue.city_slug, slug: venue.slug }}
                      className="inline-flex items-center gap-1 text-sm"
                      style={{
                        border: "1px solid rgba(255,255,255,0.2)",
                        color: PAPER_DIM,
                        fontWeight: 600,
                        padding: "10px 21px",
                        borderRadius: 8,
                      }}
                    >
                      View venue <span aria-hidden>→</span>
                    </Link>
                  </>
                ) : (
                  <Link
                    to="/venue/$city/$slug"
                    params={{ city: venue.city_slug, slug: venue.slug }}
                    className="inline-flex items-center gap-1 text-sm transition-transform hover:-translate-y-0.5"
                    style={{
                      backgroundColor: BRASS,
                      color: INK,
                      fontWeight: 600,
                      padding: "11px 22px",
                      borderRadius: 8,
                    }}
                  >
                    View venue <span aria-hidden>→</span>
                  </Link>
                )}

                {venue.website && (
                  <a
                    href={venue.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1 bg-transparent text-xs"
                    style={{
                      color: BRASS_SOFT,
                      border: "none",
                      padding: "8px 4px",
                    }}
                  >
                    Visit website
                  </a>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Section 2 — paper map band */}
      <section style={{ backgroundColor: PAPER }} className="py-10">
        <div className="mx-auto max-w-5xl px-6">
          <p
            className="mb-3.5 text-[10px] font-semibold uppercase"
            style={{ color: BRONZE, letterSpacing: "0.25em" }}
          >
            The lay of the land · {city.display} ·{" "}
            {formatCoord(city.lat, city.lng)}
          </p>
          <div
            className="overflow-hidden rounded-xl"
            style={{ border: `1px solid ${HAIRLINE}` }}
          >
            <ClientOnly fallback={<MapPlaceholder />}>
              <VenueMap venues={[venue]} cityContext={city.slug} />
            </ClientOnly>
          </div>
        </div>
      </section>

      {/* Section 3 — paper outro */}
      <section style={{ backgroundColor: PAPER }} className="pb-16 text-center">
        <div className="mx-auto max-w-5xl px-6">
          <Link
            to="/"
            className="inline-flex items-center gap-1.5 text-sm italic transition-colors"
            style={{ color: INK_MUTED, ["--hov" as never]: BRONZE }}
            onMouseEnter={(e) => (e.currentTarget.style.color = BRONZE)}
            onMouseLeave={(e) => (e.currentTarget.style.color = INK_MUTED)}
          >
            Looking for more? Explore other charted cities
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
      </section>
    </>
  );
}

function buildSingleWhy(venue: Venue, city: City): string {
  const blurb = venue.blurb_short?.trim() || venue.blurb_long?.trim();
  if (blurb) return blurb;

  const bestBySource = new Map<string, (typeof venue.awards)[number]>();
  for (const a of venue.awards) {
    const cur = bestBySource.get(a.source);
    if (!cur || getAwardPrestige(a) > getAwardPrestige(cur)) {
      bestBySource.set(a.source, a);
    }
  }
  const top = Array.from(bestBySource.values())
    .sort((a, b) => getAwardPrestige(b) - getAwardPrestige(a))
    .slice(0, 2)
    .map((a) => awardLabelShort(a));

  const typeLabel = venue.type === "bar" ? "bars" : "tables";
  if (top.length === 2) {
    return `${top[0]} and ${top[1]} — one of ${city.display}'s most decorated ${typeLabel}.`;
  }
  if (top.length === 1) {
    return `${top[0]} — one of ${city.display}'s most celebrated ${typeLabel}.`;
  }
  return `One of ${city.display}'s most celebrated ${venue.type === "bar" ? "cocktail bars" : "restaurants"}.`;
}

function buildPillAwards(venue: Venue): string[] {
  const bestBySource = new Map<string, (typeof venue.awards)[number]>();
  for (const a of venue.awards) {
    const cur = bestBySource.get(a.source);
    if (!cur || getAwardPrestige(a) > getAwardPrestige(cur)) {
      bestBySource.set(a.source, a);
    }
  }
  return Array.from(bestBySource.values())
    .sort((a, b) => getAwardPrestige(b) - getAwardPrestige(a))
    .slice(0, 4)
    .map((a) => awardLabelShort(a));
}

function ResultsSkeleton() {
  return (
    <div className="grid gap-4 md:grid-cols-2">
      {Array.from({ length: 6 }).map((_, i) => (
        <Card key={i} className="border-border bg-card">
          <CardContent className="space-y-3 p-5">
            <Skeleton className="h-3 w-1/3" />
            <Skeleton className="h-6 w-2/3" />
            <Skeleton className="h-4 w-1/2" />
            <Skeleton className="h-4 w-full" />
          </CardContent>
        </Card>
      ))}
    </div>
  );
}

function MapPlaceholder() {
  return (
    <div
      className="h-72 w-full md:h-96"
      style={{ backgroundColor: "#2c2a26" }}
    />
  );
}

function SegToggle({
  active,
  onClick,
  label,
}: {
  active: boolean;
  onClick: () => void;
  label: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      style={{
        border: 0,
        backgroundColor: active ? "#FCFAF5" : "transparent",
        color: active ? INK : INK_MUTED,
        fontWeight: active ? 600 : 500,
        padding: "8px 16px",
        borderRadius: 100,
        fontSize: 14,
        boxShadow: active ? "0 1px 2px rgba(0,0,0,0.06)" : "none",
        cursor: "pointer",
        transition: "background-color 120ms, color 120ms",
      }}
    >
      {label}
    </button>
  );
}

function EmptyState({ onReset }: { onReset: () => void }) {
  return (
    <div className="rounded-xl border border-border bg-card/40 px-6 py-12 text-center">
      <h3 className="font-display text-xl font-light italic text-foreground">
        Nothing matches those filters.
      </h3>
      <p className="mt-2 text-sm text-muted-foreground">
        Loosen the filters to see more charted spots.
      </p>
      <Button onClick={onReset} variant="outline" size="sm" className="mt-4">
        Clear filters
      </Button>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function prettyAwardSource(slug: string): string {
  return getAwardSource(slug)?.name ?? slug;
}

function buildMetaDescription(c: City): string {
  const raw =
    c.blurb?.trim() ||
    `The finest restaurants and cocktail bars in ${c.display}, ${c.country}, drawn from Michelin, World's 50 Best, and the guides that actually matter.`;
  return raw.length > 300 ? raw.slice(0, 297).trimEnd() + "…" : raw;
}

function buildItemListJsonLd(c: City, venues: Venue[]) {
  const items = venues.slice(0, 20).map((v, i) => ({
    "@type": "ListItem",
    position: i + 1,
    url: `${SITE_URL}/venue/${v.city_slug}/${v.slug}`,
    name: v.name,
  }));
  return {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: `Best restaurants and bars in ${c.display}`,
    itemListOrder: "https://schema.org/ItemListOrderAscending",
    numberOfItems: items.length,
    itemListElement: items,
  };
}

