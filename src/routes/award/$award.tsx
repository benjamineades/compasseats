import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { useMemo, useState, useTransition, useDeferredValue } from "react";
import { ArrowRight, ChevronDown, X } from "lucide-react";

import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuCheckboxItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";

import {
  getAwardSource,
  getVenuesByAward,
} from "@/lib/venues";
import type { Venue } from "@/lib/schema";
import type { AwardSource } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

// ---------------------------------------------------------------------------
// Hard-coded editorial blurbs (will move to data later)
// ---------------------------------------------------------------------------

const AWARD_BLURBS: Record<string, string> = {
  michelin:
    "The red guide that set the standard. Every starred restaurant and Bib Gourmand we track, across every edition.",
  "worlds-50-best-restaurants":
    "The annual list that reshapes global dining. From No. 1 to the extended 51–100, every ranked restaurant we chart.",
  "worlds-50-best-bars":
    "The definitive bar ranking. The world's most influential cocktail destinations, ranked and mapped.",
  "james-beard":
    "America's most coveted culinary honors. The chefs, restaurants, and bars that define the national scene.",
  "best-chef-awards":
    "The global chef ranking that cuts through noise. The names and kitchens that set the pace worldwide.",
  "spirited-awards":
    "The cocktail industry's Academy Awards. The bartenders, bars, and brands shaping what we drink.",
  "pinnacle-guide":
    "A new standard for cocktail excellence. The bars that rise above in craft, hospitality, and ambition.",
  oad:
    "The discerning diner's alternative ranking. OAD's crowdsourced and jury-vetted top restaurants worldwide.",
  "101-best-steakhouses":
    "The carnivore's bible. The steakhouses that earn their place on the global list.",
  "worlds-50-best-bars-51-100":
    "The extended bar ranking. The next fifty destinations that belong on any serious drinker's itinerary.",
  "north-america-50-best-bars":
    "The continent's best cocktail bars. From Mexico City to Montreal, the fifty that lead North America.",
  "asia-50-best-bars":
    "Asia's cocktail elite. From Tokyo to Singapore, the bars defining the region's drinking culture.",
  "north-america-50-best-bars-51-100":
    "The extended North America bar ranking. The next fifty worth crossing borders for.",
  "asia-50-best-bars-51-100":
    "The extended Asia bar ranking. The next fifty that prove the region's depth.",
  "la-liste":
    "The algorithmic global restaurant ranking. The world's best tables, scored across hundreds of sources.",
  "gault-millau":
    "The French guide with teeth. The restaurants and chefs that earn Gault & Millau's toques and recognition.",
  tabelog:
    "Japan's most trusted restaurant rating. The sushi counters, ramen shops, and kaiseki rooms that top the charts.",
  "forbes-travel-guide":
    "The original luxury standard. The five-star restaurants and bars that pass the world's toughest inspections.",
};

// ---------------------------------------------------------------------------
// Route
// ---------------------------------------------------------------------------

export const Route = createFileRoute("/award/$award")({
  staticData: { prerender: true },
  loader: ({ params }) => {
    const source = getAwardSource(params.award);
    if (!source) throw notFound();
    const venues = getVenuesByAward(source.slug as AwardSource);
    return { source, venues };
  },
  head: ({ loaderData }) => {
    const source = loaderData?.source;
    const venues = (loaderData?.venues ?? []) as Venue[];
    if (!source) {
      return { meta: [{ title: "Award not found · CompassEats" }] };
    }

    const cityCount = new Set(venues.map((v) => v.city_slug)).size;
    const title = `${source.name} — every venue, charted | CompassEats`;
    const description = `${source.name}: ${venues.length} charted venues across ${cityCount} cities. The complete list on CompassEats.`;
    const url = `${SITE_URL}/award/${source.slug}`;

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
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(buildItemListJsonLd(source.name, venues)),
        },
      ],
    };
  },
  component: AwardPage,
  notFoundComponent: () => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <h1 className="font-display text-3xl font-light italic">
        We haven't charted this award yet.
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Browse the awards we've mapped from the home page.
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

type VenueTypeFilter = "restaurant" | "bar";

function AwardPage() {
  const { source, venues } = Route.useLoaderData() as {
    source: { slug: string; name: string; tier: string };
    venues: Venue[];
  };

  const [typeFilter, setTypeFilter] = useState<Set<VenueTypeFilter>>(new Set());
  const [cityFilter, setCityFilter] = useState<Set<string>>(new Set());
  const [isPending, startTransition] = useTransition();

  const deferredTypeFilter = useDeferredValue(typeFilter);
  const deferredCityFilter = useDeferredValue(cityFilter);

  // Default sort: award year desc (latest year for this source)
  const sortedVenues = useMemo(() => {
    return [...venues].sort((a, b) => {
      const aYear = latestYearForSource(a, source.slug);
      const bYear = latestYearForSource(b, source.slug);
      return bYear - aYear;
    });
  }, [venues, source.slug]);

  const cityOptions = useMemo(() => {
    const map = new Map<string, string>();
    for (const v of venues) {
      if (!map.has(v.city_slug)) map.set(v.city_slug, v.city_display);
    }
    return Array.from(map.entries()).sort((a, b) => a[1].localeCompare(b[1]));
  }, [venues]);

  const cityCount = new Set(venues.map((v) => v.city_slug)).size;

  const filtered = useMemo(() => {
    const wantRest = deferredTypeFilter.has("restaurant");
    const wantBars = deferredTypeFilter.has("bar");

    return sortedVenues.filter((v) => {
      if (wantRest && !wantBars && v.type !== "restaurant") return false;
      if (wantBars && !wantRest && v.type !== "bar") return false;
      if (deferredCityFilter.size > 0 && !deferredCityFilter.has(v.city_slug))
        return false;
      return true;
    });
  }, [sortedVenues, deferredTypeFilter, deferredCityFilter]);

  const toggleType = (id: VenueTypeFilter) =>
    startTransition(() =>
      setTypeFilter((prev) => {
        const next = new Set(prev);
        next.has(id) ? next.delete(id) : next.add(id);
        return next;
      }),
    );

  const toggleCity = (slug: string) =>
    startTransition(() =>
      setCityFilter((prev) => {
        const next = new Set(prev);
        next.has(slug) ? next.delete(slug) : next.add(slug);
        return next;
      }),
    );

  const clearAll = () =>
    startTransition(() => {
      setTypeFilter(new Set());
      setCityFilter(new Set());
    });

  const noneSelected = typeFilter.size === 0 && cityFilter.size === 0;

  const blurb =
    AWARD_BLURBS[source.slug] ??
    `Every ${source.name} venue we chart, updated and verified.`;

  return (
    <main className="relative min-h-screen bg-background">
      {/* Hero */}
      <section className="border-b border-border bg-card/40">
        <div className="mx-auto max-w-5xl px-6 py-10 md:py-14">
          <nav className="flex flex-wrap items-center gap-1.5 text-xs text-muted-foreground">
            <Link to="/" className="hover:text-accent-strong">
              Home
            </Link>
            <span aria-hidden>›</span>
            <span className="text-foreground">{source.name}</span>
          </nav>

          <p className="mt-6 text-xs font-medium uppercase tracking-[0.25em] text-accent-strong">
            {venues.length} venues · {cityCount} cit
            {cityCount === 1 ? "y" : "ies"}
          </p>
          <h1 className="mt-3 font-display text-4xl font-light italic tracking-tight text-foreground md:text-6xl">
            {source.name}
          </h1>
          <p className="mt-4 max-w-2xl text-base text-muted-foreground md:text-lg">
            {blurb}
          </p>
        </div>
      </section>

      <div className="mx-auto max-w-5xl px-6 py-10">
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
              variant={typeFilter.has("restaurant") ? "default" : "outline"}
              onClick={() => toggleType("restaurant")}
              className="h-8 rounded-full text-xs"
            >
              Restaurants
            </Button>
            <Button
              size="sm"
              variant={typeFilter.has("bar") ? "default" : "outline"}
              onClick={() => toggleType("bar")}
              className="h-8 rounded-full text-xs"
            >
              Bars
            </Button>

            {Array.from(cityFilter).map((slug) => (
              <Button
                key={slug}
                size="sm"
                variant="default"
                onClick={() => toggleCity(slug)}
                className="h-8 gap-1 rounded-full text-xs"
                title="Remove filter"
              >
                {cityOptions.find(([s]) => s === slug)?.[1] ?? slug}
                <X className="h-3 w-3 opacity-80" />
              </Button>
            ))}

            {cityOptions.length > 0 && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button
                    size="sm"
                    variant="outline"
                    className="h-8 gap-1.5 rounded-full text-xs"
                  >
                    <ChevronDown className="h-3 w-3 opacity-70" />
                    City
                    {cityFilter.size > 0 && (
                      <span className="ml-0.5 rounded-full bg-primary px-1.5 text-[10px] font-semibold text-primary-foreground">
                        {cityFilter.size}
                      </span>
                    )}
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="start" className="w-56">
                  <DropdownMenuLabel>Filter by city</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  {cityOptions.map(([slug, display]) => (
                    <DropdownMenuCheckboxItem
                      key={slug}
                      checked={cityFilter.has(slug)}
                      onCheckedChange={() => toggleCity(slug)}
                      onSelect={(e) => e.preventDefault()}
                    >
                      {display}
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
          <div className="grid gap-4 md:grid-cols-2">
            {filtered.map((v) => (
              <VenueCard key={v.id} venue={v} sourceSlug={source.slug} />
            ))}
          </div>
        )}

        {!isPending && filtered.length > 0 && (
          <p className="mt-8 text-center text-xs italic text-muted-foreground">
            Showing {filtered.length} of {venues.length} charted spot
            {venues.length === 1 ? "" : "s"}.
          </p>
        )}

        {/* Charted across cities */}
        <CityCountsSection venues={venues} />
      </div>
    </main>
  );
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

function VenueCard({
  venue,
  sourceSlug,
}: {
  venue: Venue;
  sourceSlug: string;
}) {
  const top = venue.awards[0];
  const sourceAward = venue.awards.find((a) => a.source === sourceSlug) ?? top;
  const accoladeLabel = sourceAward
    ? `${sourceAward.year} · ${sourceAward.category}`
    : top
      ? `${prettyAwardSource(top.source)} · ${top.category}`
      : null;

  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: venue.city_slug, slug: venue.slug }}
      className="group block"
    >
      <Card className="h-full border-border bg-card transition-colors hover:border-accent-strong/50">
        <CardContent className="flex h-full flex-col gap-2 p-5">
          <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
            {venue.type === "bar" ? "Cocktail bar" : "Restaurant"}
            {venue.neighborhood ? ` · ${venue.neighborhood}` : ""}
          </p>
          <h3 className="font-display text-xl font-light italic text-foreground group-hover:text-accent-strong">
            {venue.name}
          </h3>

          {accoladeLabel && (
            <p className="text-xs text-muted-foreground">{accoladeLabel}</p>
          )}

          {venue.blurb_short && (
            <p className="line-clamp-2 text-sm text-muted-foreground">
              {venue.blurb_short}
            </p>
          )}

          <div className="mt-2 flex flex-wrap items-center gap-1.5">
            {venue.price_tier && (
              <Badge variant="outline" className="font-normal">
                {venue.price_tier}
              </Badge>
            )}
            {venue.cuisine_tags.slice(0, 2).map((t) => (
              <Badge key={t} variant="secondary" className="font-normal">
                {t}
              </Badge>
            ))}
          </div>

          <span className="mt-auto inline-flex items-center gap-1 pt-2 text-xs text-accent-strong">
            View <ArrowRight className="h-3 w-3" />
          </span>
        </CardContent>
      </Card>
    </Link>
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
// City counts section
// ---------------------------------------------------------------------------

function CityCountsSection({ venues }: { venues: Venue[] }) {
  const counts = useMemo(() => {
    const map = new Map<
      string,
      { slug: string; display: string; count: number }
    >();
    for (const v of venues) {
      const existing = map.get(v.city_slug);
      if (existing) {
        existing.count++;
      } else {
        map.set(v.city_slug, {
          slug: v.city_slug,
          display: v.city_display,
          count: 1,
        });
      }
    }
    return Array.from(map.values()).sort((a, b) => b.count - a.count);
  }, [venues]);

  if (counts.length === 0) return null;

  return (
    <section className="mt-16 border-t border-border pt-10">
      <h2 className="font-display text-2xl font-light italic text-foreground">
        Charted across {counts.length} cit
        {counts.length === 1 ? "y" : "ies"}
      </h2>
      <p className="mt-1 text-sm text-muted-foreground">
        Worth the detour.
      </p>
      <div className="mt-6 flex flex-wrap gap-2">
        {counts.map(({ slug, display, count }) => (
          <Link
            key={slug}
            to="/city/$slug"
            params={{ slug }}
            className="group"
          >
            <Badge
              variant="outline"
              className="cursor-pointer gap-1 font-normal transition-colors hover:border-accent-strong/50 hover:text-accent-strong"
            >
              {display}
              <span className="text-muted-foreground">({count})</span>
            </Badge>
          </Link>
        ))}
      </div>
    </section>
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function prettyAwardSource(slug: string): string {
  return getAwardSource(slug)?.name ?? slug;
}

function latestYearForSource(venue: Venue, sourceSlug: string): number {
  const years = venue.awards
    .filter((a) => a.source === sourceSlug)
    .map((a) => a.year);
  return years.length > 0 ? Math.max(...years) : 0;
}

function buildItemListJsonLd(sourceName: string, venues: Venue[]) {
  const items = venues.slice(0, 20).map((v, i) => ({
    "@type": "ListItem",
    position: i + 1,
    url: `${SITE_URL}/venue/${v.city_slug}/${v.slug}`,
    name: v.name,
  }));
  return {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: `${sourceName} — Charted venues`,
    itemListOrder: "https://schema.org/ItemListOrderAscending",
    numberOfItems: items.length,
    itemListElement: items,
  };
}
