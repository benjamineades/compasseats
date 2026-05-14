import { createFileRoute } from "@tanstack/react-router";
import { useMutation } from "@tanstack/react-query";
import { useState, type FormEvent } from "react";
import { Search, MapPin, UtensilsCrossed, Loader2 } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";

type Restaurant = {
  name: string;
  cuisine: string;
  priceRange: "$" | "$$" | "$$$" | "$$$$";
  description: string;
  neighborhood?: string;
};

type Result = {
  city: string;
  country: string;
  restaurants: Restaurant[];
};

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Top 5 Restaurants in Any City — Find Where to Eat" },
      {
        name: "description",
        content:
          "Type any city in the world and instantly get the top 5 restaurants worth visiting, curated with AI.",
      },
      { property: "og:title", content: "Top 5 Restaurants in Any City" },
      {
        property: "og:description",
        content:
          "Type any city in the world and instantly get the top 5 restaurants worth visiting.",
      },
    ],
  }),
  component: Index,
});

async function fetchRestaurants(city: string): Promise<Result> {
  const res = await fetch("/api/top-restaurants", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ city }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data?.error ?? "Something went wrong");
  return data as Result;
}

function Index() {
  const [city, setCity] = useState("");
  const mutation = useMutation({ mutationFn: fetchRestaurants });

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    const trimmed = city.trim();
    if (!trimmed) return;
    mutation.mutate(trimmed);
  };

  return (
    <main className="min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header className="text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-xs font-medium text-muted-foreground">
            <UtensilsCrossed className="h-3.5 w-3.5" />
            Powered by AI
          </div>
          <h1 className="mt-6 text-4xl font-semibold tracking-tight text-foreground md:text-6xl">
            Where to eat,
            <br />
            <span className="text-muted-foreground">anywhere.</span>
          </h1>
          <p className="mx-auto mt-5 max-w-xl text-base text-muted-foreground md:text-lg">
            Type any city on the planet and get the top 5 restaurants worth your appetite.
          </p>
        </header>

        <form onSubmit={onSubmit} className="mt-10 flex flex-col gap-3 sm:flex-row">
          <div className="relative flex-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Try Tokyo, Lisbon, Mexico City…"
              className="h-12 pl-10 text-base"
              maxLength={100}
              autoFocus
            />
          </div>
          <Button
            type="submit"
            size="lg"
            className="h-12 px-6"
            disabled={mutation.isPending || !city.trim()}
          >
            {mutation.isPending ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Searching
              </>
            ) : (
              "Find restaurants"
            )}
          </Button>
        </form>

        <section className="mt-12">
          {mutation.isPending && <ResultsSkeleton />}

          {mutation.isError && (
            <div className="rounded-lg border border-destructive/30 bg-destructive/5 p-4 text-sm text-destructive">
              {(mutation.error as Error).message}
            </div>
          )}

          {mutation.isSuccess && mutation.data && (
            <Results data={mutation.data} />
          )}

          {!mutation.isPending && !mutation.isSuccess && !mutation.isError && (
            <p className="text-center text-sm text-muted-foreground">
              Enter a city above to get started.
            </p>
          )}
        </section>
      </div>
    </main>
  );
}

function Results({ data }: { data: Result }) {
  return (
    <div>
      <div className="mb-6 flex items-center gap-2 text-sm text-muted-foreground">
        <MapPin className="h-4 w-4" />
        Top 5 in{" "}
        <span className="font-medium text-foreground">
          {data.city}
          {data.country ? `, ${data.country}` : ""}
        </span>
      </div>
      <ol className="space-y-3">
        {data.restaurants.map((r, i) => (
          <li key={`${r.name}-${i}`}>
            <Card className="transition-colors hover:border-foreground/20">
              <CardContent className="flex gap-4 p-5">
                <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-foreground text-sm font-semibold text-background">
                  {i + 1}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-baseline justify-between gap-2">
                    <h2 className="text-lg font-semibold text-foreground">
                      {r.name}
                    </h2>
                    <span className="text-sm font-medium text-muted-foreground">
                      {r.priceRange}
                    </span>
                  </div>
                  <div className="mt-1 flex flex-wrap gap-1.5">
                    <Badge variant="secondary">{r.cuisine}</Badge>
                    {r.neighborhood && (
                      <Badge variant="outline">{r.neighborhood}</Badge>
                    )}
                  </div>
                  <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
                    {r.description}
                  </p>
                </div>
              </CardContent>
            </Card>
          </li>
        ))}
      </ol>
    </div>
  );
}

function ResultsSkeleton() {
  return (
    <div className="space-y-3">
      {Array.from({ length: 5 }).map((_, i) => (
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
