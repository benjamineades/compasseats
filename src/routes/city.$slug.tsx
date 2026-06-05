import { ClientOnly, createFileRoute, Link, notFound } from "@tanstack/react-router";
import { lazy, useMemo, useState, useTransition, useDeferredValue } from "react";
import { ArrowRight, ChevronDown, SlidersHorizontal, X } from "lucide-react";

import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuCheckboxItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { CityHero } from "@/components/CityHero";
import { AwardMarquee } from "@/components/AwardMarquee";
import { AwardBadgeRow } from "@/components/AwardBadge";
import { VenuePhoto } from "@/components/VenuePhoto";
import { CitySpotlight } from "@/components/CitySpotlight";
import { VenueRankedRow } from "@/components/VenueRankedRow";
import { formatCoord } from "@/lib/format-coords";

import {
  getCity,
  getVenuesByCity,
  getAwardSource,
  getAwardPrestige,
} from "@/lib/venues";
import type { City, Venue } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";
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

const INITIAL_ROW_CAP = 50;

function CityPage() {
  const { city, venues } = Route.useLoaderData() as {
    city: City;
    venues: Venue[];
  };

  const [quick, setQuick] = useState<Set<QuickFilter>>(new Set());
  const [awardFilters, setAwardFilters] = useState<Set<string>>(new Set());
  const [showAll, setShowAll] = useState(false);
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
    const scoreOf = (v: Venue) =>
      v.awards.reduce((sum, a) => sum + getAwardPrestige(a), 0);
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

  const visible = showAll ? filtered : filtered.slice(0, INITIAL_ROW_CAP);
  const hasMore = filtered.length > INITIAL_ROW_CAP;

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
        />
        <SingleVenueFeature city={city} venue={venues[0]} />
      </main>
    );
  }

  // MODE B — multi-venue city: spotlight + map + ranked listings.
  return (
    <main className="relative min-h-screen bg-background">
      <CityHero
        city={city.display}
        country={city.country}
        blurb={city.blurb}
        hueSeed={city.slug}
        imageUrl={city.hero_image_url}
        back={{ to: "/" }}
      />

      <div className="mx-auto max-w-5xl px-6">
        <AwardMarquee />
      </div>

      <CitySpotlight city={city} venues={sortedVenues} />

      <div className="mx-auto max-w-5xl px-6 py-10">
        {/* Map — sits above the filter bar so it never gets pinned under it */}
        <div className="mb-3 flex flex-wrap items-baseline justify-between gap-2">
          <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
            The lay of the land · {city.display} · {formatCoord(city.lat, city.lng)}
          </p>
        </div>
        <div className="mb-10">
          <ClientOnly fallback={<MapPlaceholder />}>
            <VenueMap venues={sortedVenues} cityContext={city.slug} />
          </ClientOnly>
        </div>

        {/* Filter bar */}
        <div className="sticky top-[70px] z-[60] -mx-6 mb-6 border-b border-border bg-background/80 px-6 py-3 backdrop-blur-md">
          <div className="flex flex-wrap items-center gap-1.5">
            <Button
              size="sm"
              variant={noneSelected ? "default" : "outline"}
              onClick={clearAll}
              className="h-8 rounded-full text-xs"
            >
              All
            </Button>
            <Button
              size="sm"
              variant={quick.has("restaurants") ? "default" : "outline"}
              onClick={() => toggleQuick("restaurants")}
              className="h-8 rounded-full text-xs"
            >
              Restaurants
            </Button>
            <Button
              size="sm"
              variant={quick.has("bars") ? "default" : "outline"}
              onClick={() => toggleQuick("bars")}
              className="h-8 rounded-full text-xs"
            >
              Cocktail Bars
            </Button>

            {Array.from(awardFilters).map((src) => (
              <Button
                key={src}
                size="sm"
                variant="default"
                onClick={() => toggleAward(src)}
                className="h-8 gap-1 rounded-full text-xs"
                title="Remove filter"
              >
                {prettyAwardSource(src)}
                <X className="h-3 w-3 opacity-80" />
              </Button>
            ))}

            {distinctSources.length > 0 && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button
                    size="sm"
                    variant="outline"
                    className="h-8 gap-1.5 rounded-full text-xs"
                  >
                    <SlidersHorizontal className="h-3.5 w-3.5" />
                    Awards
                    {awardFilters.size > 0 && (
                      <span className="ml-0.5 rounded-full bg-primary px-1.5 text-[10px] font-semibold text-primary-foreground">
                        {awardFilters.size}
                      </span>
                    )}
                    <ChevronDown className="h-3 w-3 opacity-70" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="start" className="w-64">
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
            <div className="divide-y divide-border/50">
              {visible.map((v, i) => (
                <VenueRankedRow key={v.id} venue={v} rank={i + 1} />
              ))}
            </div>

            {hasMore && (
              <div className="mt-8 flex justify-center">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setShowAll((s) => !s)}
                  className="rounded-full"
                >
                  {showAll
                    ? "Show less"
                    : `Show all ${filtered.length} charted spots in ${city.display} →`}
                </Button>
              </div>
            )}
          </>
        )}

        {!isPending && filtered.length > 0 && (
          <p className="mt-8 text-center text-xs italic text-muted-foreground">
            Showing {visible.length} of {venues.length} charted spot
            {venues.length === 1 ? "" : "s"} in {city.display}.
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
  const why =
    venue.blurb_short?.trim() ||
    `${city.display}'s one charted spot — worth the detour.`;

  return (
    <>
      <section className="mx-auto max-w-5xl px-6 py-12 md:py-16">
        <div className="grid gap-8 md:grid-cols-[1.1fr_1fr] md:gap-10">
          <div className="aspect-[4/5] w-full overflow-hidden rounded-xl border border-border md:aspect-[4/5]">
            <VenuePhoto src={venue.photo_url} alt={venue.name} />
          </div>

          <div className="flex flex-col justify-center">
            <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
              {venue.type === "bar" ? "Cocktail bar" : "Restaurant"} · {where}
            </p>
            <h2 className="mt-3 font-display text-4xl font-light italic text-foreground md:text-5xl">
              {venue.name}
            </h2>
            <p className="mt-4 max-w-prose text-base text-muted-foreground">{why}</p>

            <div className="mt-5">
              <AwardBadgeRow venue={venue} max={4} />
            </div>

            <div className="mt-7 flex flex-wrap items-center gap-2">
              {venue.reservation_url && (
                <Button asChild className="interactive">
                  <a
                    href={venue.reservation_url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Reserve a table
                  </a>
                </Button>
              )}
              {venue.website && (
                <Button asChild variant="outline" className="interactive">
                  <a
                    href={venue.website}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Visit website
                  </a>
                </Button>
              )}
              <Button asChild variant="ghost" className="interactive">
                <Link
                  to="/venue/$city/$slug"
                  params={{ city: venue.city_slug, slug: venue.slug }}
                >
                  View venue
                  <ArrowRight className="ml-1 h-4 w-4" />
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-5xl px-6 pb-12">
        <p className="mb-3 text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
          The lay of the land · {city.display} · {formatCoord(city.lat, city.lng)}
        </p>
        <ClientOnly fallback={<MapPlaceholder />}>
          <VenueMap venues={[venue]} cityContext={city.slug} />
        </ClientOnly>
      </section>

      <section className="mx-auto max-w-5xl px-6 pb-16 text-center">
        <Link
          to="/"
          className="interactive inline-flex items-center gap-1.5 text-sm italic text-muted-foreground hover:text-accent-strong"
        >
          Looking for more? Explore other charted cities
          <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </section>
    </>
  );
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
  return <div className="h-72 w-full rounded-xl border border-border bg-card md:h-96" />;
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

