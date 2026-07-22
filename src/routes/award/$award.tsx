import { ClientOnly, createFileRoute, Link, notFound } from "@tanstack/react-router";
import { lazy, useMemo, useState, useTransition, useDeferredValue } from "react";
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
  getAwardPrestige,
} from "@/lib/venues";
import type { Venue } from "@/lib/schema";
import type { AwardSource } from "@/lib/schema";
import { getGuideDescription } from "@/lib/award-descriptions";

const SITE_URL = "https://compasseats.com";
const VenueMap = lazy(() =>
  import("@/components/VenueMap").then((module) => ({ default: module.VenueMap })),
);

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
          children: JSON.stringify(
            buildCollectionPageJsonLd(source.name, source.slug, venues),
          ),
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
  const [countryFilter, setCountryFilter] = useState<Set<string>>(new Set());
  const [isPending, startTransition] = useTransition();

  const deferredTypeFilter = useDeferredValue(typeFilter);
  const deferredCityFilter = useDeferredValue(cityFilter);
  const deferredCountryFilter = useDeferredValue(countryFilter);

  // Sort: by this source's rank ascending (rank=1 first). Unranked venues
  // fall to the end and tiebreak on overall award prestige (descending) so
  // a multi-award unranked venue still beats a single-award unranked venue.
  const sortedVenues = useMemo(() => {
    return [...venues].sort((a, b) => {
      const am = a.awards.find((x) => x.source === source.slug);
      const bm = b.awards.find((x) => x.source === source.slug);
      const ar = am?.rank ?? Infinity;
      const br = bm?.rank ?? Infinity;
      if (ar !== br) return ar - br;
      const ap = am ? getAwardPrestige(am) : 0;
      const bp = bm ? getAwardPrestige(bm) : 0;
      return bp - ap;
    });
  }, [venues, source.slug]);

  const cityOptions = useMemo(() => {
    const map = new Map<string, string>();
    for (const v of venues) {
      if (!map.has(v.city_slug)) map.set(v.city_slug, v.city_display);
    }
    return Array.from(map.entries()).sort((a, b) => a[1].localeCompare(b[1]));
  }, [venues]);

  const countryOptions = useMemo(() => {
    const set = new Set<string>();
    for (const v of venues) set.add(v.country);
    return Array.from(set).sort((a, b) => a.localeCompare(b));
  }, [venues]);

  const cityCount = new Set(venues.map((v) => v.city_slug)).size;
  const countryCount = countryOptions.length;

  // Year span across every matching award entry on every venue.
  const { minYear, maxYear } = useMemo(() => {
    let mn = Infinity;
    let mx = -Infinity;
    for (const v of venues) {
      for (const a of v.awards) {
        if (a.source !== source.slug) continue;
        if (a.year < mn) mn = a.year;
        if (a.year > mx) mx = a.year;
      }
    }
    return { minYear: isFinite(mn) ? mn : null, maxYear: isFinite(mx) ? mx : null };
  }, [venues, source.slug]);

  // Ranked vs unranked split for this source.
  const { rankedCount, unrankedCount } = useMemo(() => {
    let r = 0;
    let u = 0;
    for (const v of venues) {
      const m = v.awards.find((a) => a.source === source.slug);
      if (!m) continue;
      if (typeof m.rank === "number") r++;
      else u++;
    }
    return { rankedCount: r, unrankedCount: u };
  }, [venues, source.slug]);

  const filtered = useMemo(() => {
    const wantRest = deferredTypeFilter.has("restaurant");
    const wantBars = deferredTypeFilter.has("bar");

    return sortedVenues.filter((v) => {
      if (wantRest && !wantBars && v.type !== "restaurant") return false;
      if (wantBars && !wantRest && v.type !== "bar") return false;
      if (deferredCityFilter.size > 0 && !deferredCityFilter.has(v.city_slug))
        return false;
      if (deferredCountryFilter.size > 0 && !deferredCountryFilter.has(v.country))
        return false;
      return true;
    });
  }, [sortedVenues, deferredTypeFilter, deferredCityFilter, deferredCountryFilter]);

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

  const toggleCountry = (name: string) =>
    startTransition(() =>
      setCountryFilter((prev) => {
        const next = new Set(prev);
        next.has(name) ? next.delete(name) : next.add(name);
        return next;
      }),
    );

  const clearAll = () =>
    startTransition(() => {
      setTypeFilter(new Set());
      setCityFilter(new Set());
      setCountryFilter(new Set());
    });

  const noneSelected =
    typeFilter.size === 0 && cityFilter.size === 0 && countryFilter.size === 0;

  const blurb =
    getGuideDescription(source.slug)?.description ||
    `Every ${source.name} venue we chart, updated and verified.`;

  const yearLabel =
    minYear == null || maxYear == null
      ? null
      : minYear === maxYear
        ? String(minYear)
        : `${minYear}–${maxYear}`;

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
            {countryCount > 1 ? ` · ${countryCount} countries` : ""}
            {yearLabel ? ` · ${yearLabel}` : ""}
          </p>
          <h1 className="mt-3 font-display text-4xl font-light italic tracking-tight text-foreground md:text-6xl">
            {source.name}
          </h1>
          <p className="mt-4 max-w-2xl text-base text-muted-foreground md:text-lg">
            {blurb}
          </p>

          {/* Stat strip */}
          <dl className="mt-8 grid grid-cols-2 gap-x-6 gap-y-4 border-t border-border pt-6 sm:grid-cols-4">
            <Stat label="Venues" value={String(venues.length)} />
            <Stat
              label={countryCount === 1 ? "Country" : "Countries"}
              value={String(countryCount)}
            />
            <Stat
              label={cityCount === 1 ? "City" : "Cities"}
              value={String(cityCount)}
            />
            {yearLabel ? (
              <Stat label="Years" value={yearLabel} />
            ) : null}
            {rankedCount > 0 ? (
              <Stat
                label="Ranked / Unranked"
                value={`${rankedCount} / ${unrankedCount}`}
              />
            ) : null}
          </dl>
        </div>
      </section>

      <div className="mx-auto max-w-5xl px-6 py-10">
        {/* Map */}
        {venues.length > 0 && (
          <div className="mb-8">
            <ClientOnly fallback={<MapPlaceholder />}>
              <VenueMap venues={venues} cityContext={`award:${source.slug}`} />
            </ClientOnly>
          </div>
        )}

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

            {Array.from(countryFilter).map((name) => (
              <Button
                key={`c-${name}`}
                size="sm"
                variant="default"
                onClick={() => toggleCountry(name)}
                className="h-8 gap-1 rounded-full text-xs"
                title="Remove filter"
              >
                {name}
                <X className="h-3 w-3 opacity-80" />
              </Button>
            ))}

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

            {countryOptions.length > 1 && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button
                    size="sm"
                    variant="outline"
                    className="h-8 gap-1.5 rounded-full text-xs"
                  >
                    <ChevronDown className="h-3 w-3 opacity-70" />
                    Country
                    {countryFilter.size > 0 && (
                      <span className="ml-0.5 rounded-full bg-primary px-1.5 text-[10px] font-semibold text-primary-foreground">
                        {countryFilter.size}
                      </span>
                    )}
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="start" className="max-h-80 w-56 overflow-y-auto">
                  <DropdownMenuLabel>Filter by country</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  {countryOptions.map((name) => (
                    <DropdownMenuCheckboxItem
                      key={name}
                      checked={countryFilter.has(name)}
                      onCheckedChange={() => toggleCountry(name)}
                      onSelect={(e) => e.preventDefault()}
                    >
                      {name}
                    </DropdownMenuCheckboxItem>
                  ))}
                </DropdownMenuContent>
              </DropdownMenu>
            )}

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
                <DropdownMenuContent align="start" className="max-h-80 w-56 overflow-y-auto">
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

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <dt className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
        {label}
      </dt>
      <dd className="mt-1 font-display text-2xl font-light italic text-foreground">
        {value}
      </dd>
    </div>
  );
}

function MapPlaceholder() {
  return <div className="h-72 w-full rounded-xl border border-border bg-card md:h-96" />;
}

function buildCollectionPageJsonLd(
  sourceName: string,
  sourceSlug: string,
  venues: Venue[],
) {
  const items = venues.slice(0, 20).map((v, i) => ({
    "@type": "ListItem",
    position: i + 1,
    url: `${SITE_URL}/venue/${v.city_slug}/${v.slug}`,
    name: v.name,
  }));
  return {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: `${sourceName} — Charted venues`,
    url: `${SITE_URL}/award/${sourceSlug}`,
    mainEntity: {
      "@type": "ItemList",
      name: `${sourceName} — Charted venues`,
      itemListOrder: "https://schema.org/ItemListOrderAscending",
      numberOfItems: items.length,
      itemListElement: items,
    },
  };
}
