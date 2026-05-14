import { createFileRoute } from "@tanstack/react-router";
import { useMutation } from "@tanstack/react-query";
import { useState, type FormEvent } from "react";
import { Search, MapPin, UtensilsCrossed, Loader2 } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";

type Venue = {
  name: string;
  cuisine: string;
  priceRange: "$" | "$$" | "$$$" | "$$$$";
  description: string;
  neighborhood?: string;
};

type Result = {
  city: string;
  country: string;
  venues: Venue[];
  category: "restaurants" | "cocktail bars";
};

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Top 5 Restaurants & Cocktail Bars in Any City" },
      {
        name: "description",
        content:
          "Type any city and instantly get the top 5 restaurants or cocktail bars, drawing from World's 50 Best, Michelin, and World's Best Discovery.",
      },
      { property: "og:title", content: "Top 5 Restaurants & Cocktail Bars in Any City" },
      {
        property: "og:description",
        content:
          "Top restaurants and cocktail bars in any city, sourced from World's 50 Best and World's Best Discovery.",
      },
    ],
  }),
  component: Index,
});

async function fetchVenues({
  city,
  category,
}: {
  city: string;
  category: "restaurants" | "cocktail bars";
}): Promise<Result> {
  const res = await fetch("/api/top-restaurants", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ city, category }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data?.error ?? "Something went wrong");
  return { ...(data as Omit<Result, "category">), category };
}

function Index() {
  const [restaurantCity, setRestaurantCity] = useState("");
  const [barCity, setBarCity] = useState("");
  const mutation = useMutation({ mutationFn: fetchVenues });

  const onSubmit =
    (category: "restaurants" | "cocktail bars", city: string) =>
    (e: FormEvent) => {
      e.preventDefault();
      const trimmed = city.trim();
      if (!trimmed) return;
      mutation.mutate({ city: trimmed, category });
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
            Type any city to get the top 5 restaurants or cocktail bars, drawn from World's 50 Best, Michelin, and World's Best Discovery.
          </p>
        </header>

        <div className="mt-10 space-y-4">
          <form onSubmit={onSubmit("restaurants", restaurantCity)} className="flex flex-col gap-3 sm:flex-row">
            <div className="relative flex-1">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                value={restaurantCity}
                onChange={(e) => setRestaurantCity(e.target.value)}
                placeholder="Restaurants in… Tokyo, Lisbon, Mexico City"
                className="h-12 pl-10 text-base"
                maxLength={100}
                autoFocus
              />
            </div>
            <Button type="submit" size="lg" className="h-12 px-6" disabled={mutation.isPending || !restaurantCity.trim()}>
              {mutation.isPending && mutation.variables?.category === "restaurants" ? (
                <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Searching</>
              ) : ("Find restaurants")}
            </Button>
          </form>

          <form onSubmit={onSubmit("cocktail bars", barCity)} className="flex flex-col gap-3 sm:flex-row">
            <div className="relative flex-1">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                value={barCity}
                onChange={(e) => setBarCity(e.target.value)}
                placeholder="Cocktail bars in… London, Singapore, NYC"
                className="h-12 pl-10 text-base"
                maxLength={100}
              />
            </div>
            <Button type="submit" size="lg" variant="secondary" className="h-12 px-6" disabled={mutation.isPending || !barCity.trim()}>
              {mutation.isPending && mutation.variables?.category === "cocktail bars" ? (
                <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Searching</>
              ) : ("Find cocktail bars")}
            </Button>
          </form>
        </div>

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
        Top 5 {data.category} in{" "}
        <span className="font-medium text-foreground">
          {data.city}
          {data.country ? `, ${data.country}` : ""}
        </span>
      </div>
      <ol className="space-y-3">
        {data.venues.map((r, i) => (
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
