import { createFileRoute } from "@tanstack/react-router";
import { useMutation } from "@tanstack/react-query";
import type { FormEvent, ReactNode } from "react";
import { useState } from "react";
import { Search, MapPin, UtensilsCrossed, Loader2, Star, Leaf, Utensils, Trophy, Award, ExternalLink, Instagram, Facebook, Globe } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { VenueMap } from "@/components/VenueMap";
import { RotatingEarth } from "@/components/RotatingEarth";

type Venue = {
  name: string;
  category: "restaurant" | "cocktail bar";
  cuisine: string;
  priceRange: string;
  description: string;
  neighborhood?: string;
  lat: number;
  lng: number;
  url?: string;
  urlType?: "website" | "instagram" | "facebook";
  michelinStars?: number;
  michelinGreenStar?: boolean;
  bibGourmand?: boolean;
  worldsBest50Restaurants?: { rank: number; year: number };
  worldsBest50Bars?: { rank: number; year: number };
  spiritedAward?: { name: string; year: number };
  chef?: string;
  signatureDish?: string;
  accoladeOverview?: string;
};

type Result = {
  city: string;
  country: string;
  lat: number;
  lng: number;
  venues: Venue[];
};

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

async function fetchVenues(city: string): Promise<Result> {
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
  const mutation = useMutation({ mutationFn: fetchVenues });

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    const trimmed = city.trim();
    if (!trimmed) return;
    mutation.mutate(trimmed);
  };

  const data = mutation.data;

  return (
    <main className="min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-6 py-12 md:py-20">
        <header className="text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-xs font-medium text-muted-foreground">
            <UtensilsCrossed className="h-3.5 w-3.5" />
            Powered by AI
          </div>
          <h1 className="mt-6 text-4xl font-semibold tracking-tight text-foreground md:text-6xl">
            Where to eat & drink,
            <br />
            <span className="text-muted-foreground">anywhere.</span>
          </h1>
          <p className="mx-auto mt-5 max-w-xl text-base text-muted-foreground md:text-lg">
            Type any city to get its top restaurants and cocktail bars, mapped and ranked from World's 50 Best, Michelin, and World's Best Discovery.
          </p>
        </header>

        <form onSubmit={onSubmit} className="mt-10 flex flex-col gap-3 sm:flex-row">
          <div className="relative flex-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Tokyo, Lisbon, Mexico City…"
              className="h-12 pl-10 text-base"
              maxLength={100}
              autoFocus
            />
          </div>
          <Button type="submit" size="lg" className="h-12 px-6" disabled={mutation.isPending || !city.trim()}>
            {mutation.isPending ? (
              <><Loader2 className="mr-2 h-4 w-4 animate-spin" />Searching</>
            ) : ("Find spots")}
          </Button>
        </form>

        <section className="mt-10">
          {mutation.isPending && <ResultsSkeleton />}

          {mutation.isError && (
            <div className="rounded-lg border border-destructive/30 bg-destructive/5 p-4 text-sm text-destructive">
              {(mutation.error as Error).message}
            </div>
          )}

          {mutation.isSuccess && data && (
            <>
              <div className="mb-4 flex items-center gap-2 text-sm text-muted-foreground">
                <MapPin className="h-4 w-4" />
                Top spots in{" "}
                <span className="font-medium text-foreground">
                  {data.city}
                  {data.country ? `, ${data.country}` : ""}
                </span>
              </div>
              <VenueMap
                center={[data.lat, data.lng]}
                pins={(() => {
                  let r = 0;
                  let b = 0;
                  return data.venues.map((v) => ({
                    index: v.category === "restaurant" ? ++r : ++b,
                    name: v.name,
                    category: v.category,
                    lat: v.lat,
                    lng: v.lng,
                  }));
                })()}
              />
              <div className="mt-3 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
                <span className="inline-flex items-center gap-1.5">
                  <span className="inline-block h-3 w-3 rounded-full" style={{ background: "#ea580c" }} />
                  Restaurants
                </span>
                <span className="inline-flex items-center gap-1.5">
                  <span className="inline-block h-3 w-3 rounded-full" style={{ background: "#7c3aed" }} />
                  Cocktail bars
                </span>
              </div>
              <VenueColumns venues={data.venues} />
            </>
          )}

          {!mutation.isPending && !mutation.isSuccess && !mutation.isError && (
            <div className="mt-6 flex flex-col items-center gap-6">
              <RotatingEarth />
              <p className="text-center text-sm text-muted-foreground">
                Pick any city on Earth to begin.
              </p>
            </div>
          )}
        </section>
      </div>
    </main>
  );
}

function VenueColumns({ venues }: { venues: Venue[] }) {
  const restaurants = venues.filter((v) => v.category === "restaurant");
  const bars = venues.filter((v) => v.category === "cocktail bar");
  return (
    <div className="mt-6 grid grid-cols-1 gap-6 md:grid-cols-2">
      <VenueColumn title="Restaurants" accent="#ea580c" items={restaurants} />
      <VenueColumn title="Cocktail Bars" accent="#7c3aed" items={bars} />
    </div>
  );
}

function VenueColumn({
  title,
  accent,
  items,
}: {
  title: string;
  accent: string;
  items: Venue[];
}) {
  return (
    <div>
      <h3 className="mb-3 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
        {title}
      </h3>
      <ol className="space-y-3">
        {items.map((v, i) => {
          const n = i + 1;
          return (
            <li key={`${v.name}-${n}`}>
              <Card className="transition-colors hover:border-foreground/20">
                <CardContent className="flex gap-3 p-4">
                  <div
                    className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-sm font-semibold text-white"
                    style={{ background: accent }}
                  >
                    {n}
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-baseline justify-between gap-2">
                      {v.url ? (
                        <a
                          href={v.url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="group inline-flex items-center gap-1.5 text-base font-semibold text-foreground hover:text-primary"
                        >
                          {v.name}
                          <LinkIcon type={v.urlType} />
                        </a>
                      ) : (
                        <h2 className="text-base font-semibold text-foreground">{v.name}</h2>
                      )}
                      <span className="text-sm font-medium text-muted-foreground">{v.priceRange}</span>
                    </div>
                    <div className="mt-1 flex flex-wrap gap-1.5">
                      <Badge variant="outline">{v.cuisine}</Badge>
                      {v.neighborhood && <Badge variant="outline">{v.neighborhood}</Badge>}
                    </div>
                    <Accolades v={v} />
                    {v.category === "restaurant" && (v.chef || v.signatureDish) && (
                      <div className="mt-2 space-y-0.5 text-sm">
                        {v.chef && (
                          <p className="text-foreground">
                            <span className="text-muted-foreground">Chef:</span> {v.chef}
                          </p>
                        )}
                        {v.signatureDish && (
                          <p className="text-foreground">
                            <span className="text-muted-foreground">Signature:</span> {v.signatureDish}
                          </p>
                        )}
                      </div>
                    )}
                    <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{v.description}</p>
                    {v.accoladeOverview && (
                      <p className="mt-2 rounded-md border-l-2 border-amber-500/40 bg-amber-500/5 px-2 py-1.5 text-sm leading-relaxed text-muted-foreground">
                        {v.accoladeOverview}
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </li>
          );
        })}
      </ol>
    </div>
  );
}

function LinkIcon({ type }: { type?: Venue["urlType"] }) {
  const cls = "h-3.5 w-3.5 opacity-70 group-hover:opacity-100";
  if (type === "instagram") return <Instagram className={cls} />;
  if (type === "facebook") return <Facebook className={cls} />;
  if (type === "website") return <Globe className={cls} />;
  return <ExternalLink className={cls} />;
}

function Accolades({ v }: { v: Venue }) {
  const stars = v.michelinStars ?? 0;
  const items: ReactNode[] = [];
  if (stars > 0) {
    items.push(
      <span
        key="m"
        title={`${stars} Michelin Star${stars > 1 ? "s" : ""}`}
        className="inline-flex items-center gap-0.5 rounded-md border border-red-500/40 bg-red-500/10 px-1.5 py-0.5 text-xs font-medium text-red-400"
      >
        {Array.from({ length: stars }).map((_, i) => (
          <Star key={i} className="h-3 w-3 fill-red-400 stroke-red-400" />
        ))}
      </span>,
    );
  }
  if (v.michelinGreenStar) {
    items.push(
      <span
        key="g"
        title="Michelin Green Star (Sustainability)"
        className="inline-flex items-center gap-1 rounded-md border border-emerald-500/40 bg-emerald-500/10 px-1.5 py-0.5 text-xs font-medium text-emerald-400"
      >
        <Leaf className="h-3 w-3" />
        Green Star
      </span>,
    );
  }
  if (v.bibGourmand) {
    items.push(
      <span
        key="b"
        title="Michelin Bib Gourmand"
        className="inline-flex items-center gap-1 rounded-md border border-orange-500/40 bg-orange-500/10 px-1.5 py-0.5 text-xs font-medium text-orange-400"
      >
        <Utensils className="h-3 w-3" />
        Bib Gourmand
      </span>,
    );
  }
  if (v.worldsBest50Restaurants) {
    items.push(
      <span
        key="w50r"
        className="inline-flex items-center gap-1 rounded-md border border-amber-500/40 bg-amber-500/10 px-1.5 py-0.5 text-xs font-medium text-amber-400"
      >
        <Trophy className="h-3 w-3" />
        World's 50 Best #{v.worldsBest50Restaurants.rank} ({v.worldsBest50Restaurants.year})
      </span>,
    );
  }
  if (v.worldsBest50Bars) {
    items.push(
      <span
        key="w50b"
        className="inline-flex items-center gap-1 rounded-md border border-amber-500/40 bg-amber-500/10 px-1.5 py-0.5 text-xs font-medium text-amber-400"
      >
        <Trophy className="h-3 w-3" />
        World's 50 Best Bars #{v.worldsBest50Bars.rank} ({v.worldsBest50Bars.year})
      </span>,
    );
  }
  if (v.spiritedAward) {
    items.push(
      <span
        key="sa"
        className="inline-flex items-center gap-1 rounded-md border border-fuchsia-500/40 bg-fuchsia-500/10 px-1.5 py-0.5 text-xs font-medium text-fuchsia-400"
      >
        <Award className="h-3 w-3" />
        {v.spiritedAward.name} ({v.spiritedAward.year})
      </span>,
    );
  }
  if (items.length === 0) return null;
  return <div className="mt-2 flex flex-wrap gap-1.5">{items}</div>;
}

function ResultsSkeleton() {
  return (
    <div className="space-y-3">
      <Skeleton className="h-72 w-full rounded-xl md:h-96" />
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
