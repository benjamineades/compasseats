import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { useMemo, useState, useTransition, useDeferredValue } from "react";
import { ArrowRight, ChevronDown, SlidersHorizontal, X } from "lucide-react";

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
import { CityHero } from "@/components/CityHero";
import { AwardMarquee } from "@/components/AwardMarquee";

import {
  getCity,
  getVenuesByCity,
  getAwardSource,
} from "@/lib/venues";
import type { City, Venue } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

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

type QuickFilter = "restaurants" | "bars" | "openToday";

function CityPage() {
  const { city, venues } = Route.useLoaderData() as {
    city: City;
    venues: Venue[];
  };

  const [quick, setQuick] = useState<Set<QuickFilter>>(new Set());
  const [awardFilters, setAwardFilters] = useState<Set<string>>(new Set());
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

  const filtered = useMemo(() => {
    const wantRest = deferredQuick.has("restaurants");
    const wantBars = deferredQuick.has("bars");
    const wantOpen = deferredQuick.has("openToday");
    const todayKey = wantOpen ? currentDayKey(city.timezone) : null;

    return venues.filter((v) => {
      if (wantRest && !wantBars && v.type !== "restaurant") return false;
      if (wantBars && !wantRest && v.type !== "bar") return false;
      if (wantOpen) {
        if (!v.hours) return false;
        const ranges = v.hours[todayKey!];
        if (!ranges || ranges.length === 0) return false;
      }
      if (deferredAwards.size > 0) {
        const ok = v.awards.some((a) => deferredAwards.has(a.source));
        if (!ok) return false;
      }
      return true;
    });
  }, [venues, deferredQuick, deferredAwards, city.timezone]);

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
    });

  const noneSelected = quick.size === 0 && awardFilters.size === 0;

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
            <Button
              size="sm"
              variant={quick.has("openToday") ? "default" : "outline"}
              onClick={() => toggleQuick("openToday")}
              className="h-8 rounded-full text-xs"
            >
              Open Today
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
          <div className="grid gap-4 md:grid-cols-2">
            {filtered.map((v) => (
              <VenueCard key={v.id} venue={v} />
            ))}
          </div>
        )}

        {!isPending && filtered.length > 0 && (
          <p className="mt-8 text-center text-xs italic text-muted-foreground">
            Showing {filtered.length} of {venues.length} charted spot
            {venues.length === 1 ? "" : "s"} in {city.display}.
          </p>
        )}
      </div>
    </main>
  );
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

function VenueCard({ venue }: { venue: Venue }) {
  const top = venue.awards[0];
  const accoladeLabel =
    venue.awards.length > 1
      ? `${venue.awards.length} accolades`
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
// Helpers
// ---------------------------------------------------------------------------

function prettyAwardSource(slug: string): string {
  return getAwardSource(slug)?.name ?? slug;
}

type DayKey = "mon" | "tue" | "wed" | "thu" | "fri" | "sat" | "sun";
const WEEKDAY_TO_KEY: Record<string, DayKey> = {
  Mon: "mon",
  Tue: "tue",
  Wed: "wed",
  Thu: "thu",
  Fri: "fri",
  Sat: "sat",
  Sun: "sun",
};

/** Returns the current day-of-week key in the given IANA timezone. */
function currentDayKey(timezone: string | undefined): DayKey {
  try {
    const fmt = new Intl.DateTimeFormat("en-US", {
      weekday: "short",
      timeZone: timezone || undefined,
    });
    const label = fmt.format(new Date()); // "Mon", "Tue", …
    return WEEKDAY_TO_KEY[label] ?? "mon";
  } catch {
    return WEEKDAY_TO_KEY[
      new Intl.DateTimeFormat("en-US", { weekday: "short" }).format(new Date())
    ] ?? "mon";
  }
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

