import { createFileRoute, Link } from "@tanstack/react-router";
import { useMutation } from "@tanstack/react-query";
import type { FormEvent } from "react";
import { useMemo, useState, useEffect } from "react";
import { Loader2, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { CityAutocomplete, type CitySuggestion } from "@/components/CityAutocomplete";
import { VenueResults, type ResultsData } from "@/components/VenueResults";
import { CityHero } from "@/components/CityHero";
import { ThemeToggle } from "@/components/ThemeToggle";
import { Compass, Wordmark, HeroCompass } from "@/components/Compass";
import { TOP_CITIES } from "@/lib/cities";
import { useVenueLoadMore, type VenueQuery as LoadMoreQuery } from "@/lib/useVenueLoadMore";

const PLACEHOLDER_POOL = [
  "Tokyo", "Lisbon", "Mexico City", "Paris", "New York", "Bangkok", "Istanbul",
  "Rome", "Buenos Aires", "Cape Town", "Sydney", "Singapore", "Barcelona",
  "Marrakech", "Seoul", "Mumbai", "Rio de Janeiro", "Cairo", "London", "Berlin",
];

function pickThreePlaceholder() {
  const pool = [...PLACEHOLDER_POOL];
  const picks: string[] = [];
  for (let i = 0; i < 3 && pool.length; i++) {
    picks.push(pool.splice(Math.floor(Math.random() * pool.length), 1)[0]);
  }
  return picks.join(", ") + "…";
}

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Top Restaurants & Cocktail Bars in Any City" },
      {
        name: "description",
        content:
          "Search any city to get its top restaurants and cocktail bars on a map, drawn from World's 50 Best, Michelin, and World's Best Discovery.",
      },
    ],
  }),
  component: Index,
});

type VenueQuery = { city: string; region?: string; country?: string };

async function fetchVenues(q: VenueQuery): Promise<ResultsData> {
  const res = await fetch("/api/top-restaurants", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(q),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data?.error ?? "Something went wrong");
  return data as ResultsData;
}

function Index() {
  const [city, setCity] = useState("");
  const [selected, setSelected] = useState<CitySuggestion | null>(null);
  const [placeholder] = useState(pickThreePlaceholder);
  const [lastQuery, setLastQuery] = useState<string>("");
  const [results, setResults] = useState<ResultsData | null>(null);
  const [activeQuery, setActiveQuery] = useState<LoadMoreQuery | null>(null);
  const mutation = useMutation({
    mutationFn: fetchVenues,
    onSuccess: (data, variables) => {
      setResults(data);
      setActiveQuery(variables);
    },
  });
  const { loadMore, isLoadingMore, hasMore, error: loadMoreError } = useVenueLoadMore({
    data: results ?? undefined,
    query: activeQuery ?? undefined,
    append: (newVenues) =>
      setResults((prev) => (prev ? { ...prev, venues: [...prev.venues, ...newVenues] } : prev)),
  });

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    const trimmed = city.trim();
    if (!trimmed) return;
    setLastQuery(trimmed);
    setResults(null);
    if (selected && selected.short.toLowerCase() === trimmed.toLowerCase()) {
      mutation.mutate({ city: selected.city, region: selected.region, country: selected.country });
    } else {
      mutation.mutate({ city: trimmed });
    }
  };

  const data = results ?? mutation.data;
  const showHero = mutation.isSuccess && data && data.venues.length > 0;

  const resetSearch = () => {
    mutation.reset();
    setResults(null);
    setActiveQuery(null);
    setCity("");
    setSelected(null);
    setLastQuery("");
  };

  return (
    <main className="relative min-h-screen bg-background">
      <div className="fixed top-4 right-4 z-50">
        <ThemeToggle />
      </div>
      {showHero && (
        <CityHero
          city={data.city}
          country={data.country}
          blurb={data.cityBlurb}
          back={{ onClick: resetSearch }}
        />
      )}
      <div className="mx-auto max-w-3xl px-6 py-12 md:py-20">
        {!showHero && (
        <header className="text-center">
          <div className="inline-flex items-center gap-2.5">
            <Compass size={28} />
            <Wordmark className="text-foreground" />
          </div>
          <Link to="/" className="inline-block no-underline">
            <h1 className="mt-6 cursor-pointer font-display text-4xl font-light tracking-tight text-foreground md:text-6xl">
              Where to eat & drink,<br />
              <span className="text-muted-foreground">anywhere.</span>
            </h1>
          </Link>
          <p className="mx-auto mt-5 max-w-xl text-base text-muted-foreground md:text-lg">
            Type any city to get its top restaurants and cocktail bars, mapped and ranked from World's 50 Best, Michelin Guide, and more.
          </p>
        </header>
        )}

        {!showHero && (
        <form onSubmit={onSubmit} className="mt-10 flex flex-col gap-3 sm:flex-row">
          <CityAutocomplete
            value={city}
            onChange={(v) => { setCity(v); setSelected(null); }}
            onSelect={(s) => {
              setSelected(s); setLastQuery(s.short); setResults(null);
              mutation.mutate({ city: s.city, region: s.region, country: s.country });
            }}
            placeholder={placeholder}
            disabled={mutation.isPending}
          />
          <Button type="submit" size="lg" className="h-12 px-6" disabled={mutation.isPending || !city.trim()}>
            {mutation.isPending ? (<><Loader2 className="mr-2 h-4 w-4 animate-spin" />Charting…</>) : ("Find the best")}
          </Button>
        </form>
        )}

        <section className="mt-10">
          {mutation.isPending && <SearchingState query={lastQuery} />}

          {mutation.isError && <UnmappedCity query={lastQuery} />}

          {mutation.isSuccess && data && data.venues.length > 0 && (
            <VenueResults
              data={data}
              onLoadMore={loadMore}
              isLoadingMore={isLoadingMore}
              hasMore={hasMore}
              loadMoreError={loadMoreError}
            />
          )}

          {mutation.isSuccess && data && data.venues.length === 0 && <UnmappedCity query={lastQuery} />}

          {!mutation.isPending && !mutation.isSuccess && !mutation.isError && (
            <>
              <div className="mt-6 flex flex-col items-center gap-6">
                <HeroCompass className="w-full max-w-[220px]" />
              </div>
              <PopularCities />
            </>
          )}
        </section>
      </div>
    </main>
  );
}

function SearchingState({ query }: { query: string }) {
  const messages = useMemo(() => [
    "Consulting Michelin & World's 50 Best…",
    `Charting ${query || "your city"}…`,
    "Finding the tables worth the detour…",
    "Almost there…",
  ], [query]);
  const [idx, setIdx] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setIdx((i) => (i + 1) % messages.length);
    }, 2500);
    return () => clearInterval(id);
  }, [messages]);

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-center gap-2 rounded-lg border border-border bg-card/40 px-4 py-3 text-sm text-muted-foreground">
        <Sparkles className="h-4 w-4 animate-pulse text-primary" />
        <span>{messages[idx]}</span>
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

function UnmappedCity({ query }: { query: string }) {
  const suggestions = TOP_CITIES.slice(0, 6);
  return (
    <Card className="border-dashed">
      <CardContent className="flex flex-col items-center gap-4 p-10 text-center">
        <Compass size={40} />
        <div>
          <h3 className="text-lg font-semibold text-foreground">
            We haven't charted {query ? `"${query}"` : "this city"} yet.
          </h3>
          <p className="mt-1 text-sm text-muted-foreground">
            Try a nearby city — we're roaming further every week.
          </p>
        </div>
        <div className="flex flex-wrap justify-center gap-2">
          {suggestions.map((c) => (
            <Link key={c.slug} to="/city/$slug" params={{ slug: c.slug }}
              className="rounded-full border border-border bg-card px-3 py-1 text-xs font-medium text-foreground hover:border-primary hover:text-primary">
              {c.city}
            </Link>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}

function PopularCities() {
  return (
    <div className="mt-12">
      <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
        Start with a favourite
      </h2>
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-4">
        {TOP_CITIES.map((c) => (
          <Link key={c.slug} to="/city/$slug" params={{ slug: c.slug }}
            className="group rounded-lg border border-border bg-card px-3 py-2.5 text-left transition-colors hover:border-primary/50 hover:bg-accent">
            <div className="text-sm font-medium text-foreground group-hover:text-primary">{c.city}</div>
            <div className="text-xs text-muted-foreground">{c.country}</div>
          </Link>
        ))}
      </div>
    </div>
  );
}
