import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Loader2 } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { VenueResults, type ResultsData } from "@/components/VenueResults";
import { CityHero } from "@/components/CityHero";

import { CITIES_BY_SLUG, TOP_CITIES, type TopCity } from "@/lib/cities";
import { useVenueLoadMore } from "@/lib/useVenueLoadMore";
import { Compass } from "@/components/Compass";

export const Route = createFileRoute("/city/$slug")({
  loader: ({ params }) => {
    const city = CITIES_BY_SLUG[params.slug];
    if (!city) throw notFound();
    return { city };
  },
  head: ({ loaderData }) => {
    const c = loaderData?.city as TopCity | undefined;
    if (!c) return { meta: [{ title: "City not found" }] };
    const title = `Top Restaurants & Cocktail Bars in ${c.city}, ${c.country}`;
    const description = `${c.blurb} Discover the best Michelin-starred restaurants and World's 50 Best cocktail bars in ${c.city}, mapped and ranked.`;
    const url = `https://www.compasseats.com/city/${c.slug}`;
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: url },
        { property: "og:type", content: "website" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
      ],
      links: [{ rel: "canonical", href: url }],
      scripts: [{
        type: "application/ld+json",
        children: JSON.stringify({
          "@context": "https://schema.org",
          "@type": "TouristDestination",
          name: `${c.city}, ${c.country}`,
          description,
          url,
        }),
      }],
    };
  },
  component: CityPage,
  notFoundComponent: () => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <h1 className="text-3xl font-light">City not yet mapped</h1>
      <p className="mt-2 text-muted-foreground">Browse our top cities below.</p>
      <div className="mt-6 flex flex-wrap justify-center gap-2">
        {TOP_CITIES.map((c) => (
          <Link key={c.slug} to="/city/$slug" params={{ slug: c.slug }}
            className="rounded-full border border-border bg-card px-3 py-1 text-sm hover:border-primary">
            {c.city}
          </Link>
        ))}
      </div>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <h1 className="text-2xl font-light">Something went wrong</h1>
      <p className="mt-2 text-muted-foreground">{error.message}</p>
      <Link to="/" className="mt-4 inline-block text-accent-strong underline">Back home</Link>
    </div>
  ),
});

async function fetchVenues(
  c: TopCity,
  tier: "charted" | "rated",
  exclude?: string[],
): Promise<ResultsData> {
  const res = await fetch("/api/top-restaurants", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      city: c.city,
      region: c.region,
      country: c.country,
      tier,
      ...(exclude && exclude.length ? { exclude } : {}),
    }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data?.error ?? "Failed to load");
  return data as ResultsData;
}

function CityPage() {
  const { city } = Route.useLoaderData();
  const queryClient = useQueryClient();

  // TIER 1 — charted (Sheet-sourced). Fast: no Firecrawl in this path.
  const charted = useQuery({
    queryKey: ["city-charted", city.slug],
    queryFn: () => fetchVenues(city, "charted"),
    staleTime: 1000 * 60 * 30,
  });

  // TIER 2 — highly rated (Yelp/TripAdvisor via AI). Slower; loads in the
  // background only AFTER the charted tier resolves, and excludes any venue
  // already shown in the charted tier so the two lists never overlap.
  const chartedNames = charted.data?.venues.map((v) => v.name) ?? [];
  const rated = useQuery({
    queryKey: ["city-rated", city.slug],
    enabled: charted.isSuccess, // don't even start until charted is done
    queryFn: () => fetchVenues(city, "rated", chartedNames.slice(0, 500)),
    staleTime: 1000 * 60 * 30,
  });

  // Load-more applies to the RATED tier (charted is a fixed accolade set).
  const { loadMore, isLoadingMore, hasMore, error: loadMoreError } = useVenueLoadMore({
    data: rated.data,
    query: { city: city.city, region: city.region, country: city.country },
    append: (newVenues) =>
      queryClient.setQueryData<ResultsData>(["city-rated", city.slug], (prev) =>
        prev ? { ...prev, venues: [...prev.venues, ...newVenues] } : prev,
      ),
  });

  const hasCharted = charted.isSuccess && charted.data.venues.length > 0;
  const hasRated = rated.isSuccess && rated.data.venues.length > 0;

  return (
    <main className="relative min-h-screen bg-background">
      <CityHero
        city={city.city}
        country={city.country}
        blurb={city.blurb}
        hueSeed={city.slug}
        imageUrl={city.imageUrl}
        back={{ to: "/" }}
      />

      <div className="mx-auto max-w-5xl px-6 py-10">
        {/* TIER 1: charted */}
        {charted.isPending && <CityLoading city={city.city} />}
        {charted.isError && (
          <Card className="border-destructive/30 bg-destructive/5">
            <CardContent className="flex flex-col items-center gap-3 p-8 text-center">
              <p className="text-sm text-destructive">{(charted.error as Error).message}</p>
              <Button onClick={() => charted.refetch()} size="sm" variant="outline">
                <Loader2 className={`mr-2 h-4 w-4 ${charted.isFetching ? "animate-spin" : ""}`} />
                Try again
              </Button>
            </CardContent>
          </Card>
        )}
        {hasCharted && (
          <section>
            <TierHeading
              eyebrow="Charted by the guides"
              sub={`Award-winning tables and bars in ${city.city}, drawn from the guides that matter.`}
            />
            <VenueResults data={charted.data} />
          </section>
        )}

        {/* TIER 2: highly rated — only meaningful once charted is done */}
        {charted.isSuccess && (
          <section className="mt-14 border-t border-border pt-10">
            <TierHeading
              eyebrow={hasCharted ? `Also highly rated in ${city.city}` : "Nearby local favorites"}
              sub={
                hasCharted
                  ? "Beyond the guides — top-rated local spots worth a look."
                  : `We haven't charted award-winners in ${city.city} yet — here are some local favorites worth a look.`
              }
              secondary
            />
            {rated.isPending && <RatedLoading />}
            {rated.isError && (
              <p className="text-sm text-muted-foreground">
                Couldn't load more spots right now. {hasCharted ? "The charted picks above are still your best bet." : "Try a nearby city."}
              </p>
            )}
            {hasRated && (
              <VenueResults
                data={rated.data}
                secondary
                onLoadMore={loadMore}
                isLoadingMore={isLoadingMore}
                hasMore={hasMore}
                loadMoreError={loadMoreError}
              />
            )}
            {rated.isSuccess && !hasRated && !hasCharted && (
              <p className="text-sm text-muted-foreground">
                We haven't charted this one yet. Try a nearby city — we've mapped the best tables in over 400 of them.
              </p>
            )}
          </section>
        )}

        <OtherCities currentSlug={city.slug} />
      </div>
    </main>
  );
}

function TierHeading({
  eyebrow, sub, secondary,
}: { eyebrow: string; sub: string; secondary?: boolean }) {
  return (
    <div className="mb-5">
      <h2
        className={
          secondary
            ? "text-lg font-light tracking-tight text-muted-foreground"
            : "text-2xl font-light tracking-tight text-foreground"
        }
      >
        {eyebrow}
      </h2>
      <p className="mt-1 text-sm text-muted-foreground">{sub}</p>
    </div>
  );
}

function RatedLoading() {
  return (
    <div className="flex items-center gap-2 rounded-lg border border-border bg-card/40 px-4 py-3 text-sm text-muted-foreground">
      <Loader2 className="h-4 w-4 animate-spin" />
      Finding more highly-rated spots…
    </div>
  );
}

function CityLoading({ city }: { city: string }) {
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-center gap-2 rounded-lg border border-border bg-card/40 px-4 py-3 text-sm text-muted-foreground">
        <Compass size={16} />
        Charting <span className="font-medium text-foreground">{city}'s</span> best tables…
      </div>
      <Skeleton className="h-72 w-full rounded-xl md:h-96" />
      {Array.from({ length: 4 }).map((_, i) => (
        <Card key={i}>
          <CardContent className="flex gap-4 p-5">
            <Skeleton className="h-9 w-9 rounded-full" />
            <div className="flex-1 space-y-2">
              <Skeleton className="h-5 w-2/3" />
              <Skeleton className="h-4 w-1/3" />
              <Skeleton className="h-4 w-full" />
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}

function OtherCities({ currentSlug }: { currentSlug: string }) {
  const others = TOP_CITIES.filter((c) => c.slug !== currentSlug).slice(0, 8);
  return (
    <div className="mt-16 border-t border-border pt-8">
      <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
        Explore other cities
      </h2>
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
        {others.map((c) => (
          <Link key={c.slug} to="/city/$slug" params={{ slug: c.slug }}
            className="group rounded-lg border border-border bg-card px-3 py-2.5 text-left hover:border-primary/50 hover:bg-accent">
            <div className="text-sm font-medium text-foreground group-hover:text-accent-strong">{c.city}</div>
            <div className="text-xs text-muted-foreground">{c.country}</div>
          </Link>
        ))}
      </div>
    </div>
  );
}
