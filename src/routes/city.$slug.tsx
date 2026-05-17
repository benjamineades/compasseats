import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { ArrowLeft, Loader2, Sparkles } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { VenueResults, type ResultsData } from "@/components/VenueResults";
import { CITIES_BY_SLUG, TOP_CITIES, type TopCity } from "@/lib/cities";

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
    const url = `https://eatanywhere.lovable.app/city/${c.slug}`;
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
      <h1 className="text-3xl font-semibold">City not yet mapped</h1>
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
      <h1 className="text-2xl font-semibold">Something went wrong</h1>
      <p className="mt-2 text-muted-foreground">{error.message}</p>
      <Link to="/" className="mt-4 inline-block text-primary underline">Back home</Link>
    </div>
  ),
});

async function fetchVenues(c: TopCity): Promise<ResultsData> {
  const res = await fetch("/api/top-restaurants", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ city: c.city, region: c.region, country: c.country }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data?.error ?? "Failed to load");
  return data as ResultsData;
}

function CityPage() {
  const { city } = Route.useLoaderData();
  const query = useQuery({
    queryKey: ["city-venues", city.slug],
    queryFn: () => fetchVenues(city),
    staleTime: 1000 * 60 * 30,
  });

  const imageQuery = useQuery({
    queryKey: ["city-image", city.slug],
    queryFn: () => fetchCityImage(city.city),
    staleTime: 1000 * 60 * 60 * 24,
  });
  const cityImage = imageQuery.data;

  return (
    <main className="min-h-screen bg-background">
      {/* Hero */}
      <section
        className="relative overflow-hidden border-b border-border"
        style={{
          background: `linear-gradient(135deg, hsl(${cityHue(city.slug)} 60% 18%) 0%, hsl(${cityHue(city.slug) + 40} 50% 12%) 100%)`,
        }}
      >
        {cityImage && (
          <img
            src={cityImage}
            alt=""
            aria-hidden="true"
            className="pointer-events-none absolute inset-0 h-full w-full object-cover opacity-30 mix-blend-luminosity"
          />
        )}
        <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/70 via-black/30 to-black/40" />
        <div className="absolute inset-0 opacity-20 [background-image:radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] [background-size:24px_24px]" />
        <div className="relative mx-auto max-w-5xl px-6 py-14 md:py-20">
          <Link to="/" className="inline-flex items-center gap-1.5 text-sm text-white/70 hover:text-white">
            <ArrowLeft className="h-4 w-4" />Back to search
          </Link>
          <h1 className="mt-6 text-4xl font-semibold tracking-tight text-white md:text-6xl">
            {city.city}
          </h1>
          <p className="mt-1 text-lg text-white/70">{city.country}</p>
          <p className="mt-4 max-w-2xl text-base text-white/80 md:text-lg">{city.blurb}</p>
        </div>
      </section>

      <div className="mx-auto max-w-5xl px-6 py-10">
        {query.isPending && <CityLoading city={city.city} />}
        {query.isError && (
          <Card className="border-destructive/30 bg-destructive/5">
            <CardContent className="flex flex-col items-center gap-3 p-8 text-center">
              <p className="text-sm text-destructive">{(query.error as Error).message}</p>
              <Button onClick={() => query.refetch()} size="sm" variant="outline">
                <Loader2 className={`mr-2 h-4 w-4 ${query.isFetching ? "animate-spin" : ""}`} />
                Try again
              </Button>
            </CardContent>
          </Card>
        )}
        {query.isSuccess && <VenueResults data={query.data} />}

        <OtherCities currentSlug={city.slug} />
      </div>
    </main>
  );
}

function CityLoading({ city }: { city: string }) {
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-center gap-2 rounded-lg border border-border bg-card/40 px-4 py-3 text-sm text-muted-foreground">
        <Sparkles className="h-4 w-4 animate-pulse text-primary" />
        Curating the best spots in <span className="font-medium text-foreground">{city}</span>…
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
            <div className="text-sm font-medium text-foreground group-hover:text-primary">{c.city}</div>
            <div className="text-xs text-muted-foreground">{c.country}</div>
          </Link>
        ))}
      </div>
    </div>
  );
}

function cityHue(slug: string): number {
  let h = 0;
  for (let i = 0; i < slug.length; i++) h = (h * 31 + slug.charCodeAt(i)) % 360;
  return h;
}
