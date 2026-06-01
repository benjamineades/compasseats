import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Loader2, Locate } from "lucide-react";
import { Button } from "@/components/ui/button";
import { AwardMarquee } from "@/components/AwardMarquee";
import { ExploreByAward } from "@/components/ExploreByAward";
import { HeroCompass } from "@/components/Compass";
import { CitySearch } from "@/components/CitySearch";
import { TOP_CITIES, findNearestCity } from "@/lib/cities";
import { useNearMe } from "@/lib/useNearMe";

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

function Index() {
  const [placeholder] = useState(pickThreePlaceholder);
  const navigate = useNavigate();
  const nearMe = useNearMe();

  useEffect(() => {
    if (nearMe.requested && nearMe.coords) {
      const { city } = findNearestCity(nearMe.coords);
      navigate({ to: "/city/$slug", params: { slug: city.slug } });
    }
  }, [nearMe.requested, nearMe.coords, navigate]);

  return (
    <main className="relative min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-6 py-12 md:py-20">
        <header className="text-center">
          <HeroCompass className="mx-auto mb-6 w-full max-w-[180px] md:max-w-[200px]" />
          <Link to="/" className="inline-block no-underline">
            <h1 className="cursor-pointer font-display text-4xl font-light tracking-tight text-foreground md:text-6xl">
              CompassEats
            </h1>
          </Link>
          <p className="mx-auto mt-5 max-w-xl text-base text-muted-foreground md:text-lg">
            The world's best, wherever you are.
          </p>
        </header>

        <div className="mt-10">
          <CitySearch placeholder={placeholder} />
        </div>

        <div className="mt-4 flex flex-col items-center gap-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="h-9 rounded-full px-4 text-xs"
              onClick={() => nearMe.requestLocation()}
              disabled={nearMe.loading}
            >
              {nearMe.loading ? (
                <>
                  <Loader2 className="mr-1.5 h-3.5 w-3.5 animate-spin" />
                  Finding your city…
                </>
              ) : (
                <>
                  <Locate className="mr-1.5 h-3.5 w-3.5" />
                  Near me
                </>
              )}
            </Button>
            {nearMe.error && (
              <div className="flex flex-col items-center gap-1 text-center">
                <p className="text-xs text-destructive">{nearMe.error}</p>
                <p className="text-[11px] text-muted-foreground">
                  No problem — pick a charted city below to get started.
                </p>
              </div>
            )}
        </div>

        <TrustPoints />

        <section className="mt-10">
          <AwardMarquee />
          <PopularCities />
          <ExploreByAward />
        </section>
      </div>
    </main>
  );
}

function TrustPoints() {
  const points = [
    {
      title: "Charted, not crowdsourced",
      body: "Drawn from real award guides, never strangers' star-ratings.",
    },
    {
      title: "Anywhere you land",
      body: "Type any city and see its best tables and bars in seconds.",
    },
    {
      title: "We've done the legwork",
      body: "We cross-reference the guides so you don't have to.",
    },
  ];
  return (
    <section className="mt-10 md:mt-12">
      <p className="mx-auto max-w-[520px] text-center font-sans text-sm font-light text-muted-foreground md:text-base">
        The best restaurants and cocktail bars in any city — ranked by the guides that actually matter.
      </p>
      <div className="mx-auto mt-7 grid max-w-[640px] grid-cols-1 gap-6 md:grid-cols-3 md:gap-0">
        {points.map((p, i) => (
          <div
            key={p.title}
            className={
              "px-0 text-center md:px-[26px] " +
              (i < points.length - 1
                ? "md:border-r md:border-[rgba(198,161,91,0.18)]"
                : "")
            }
          >
            <h3 className="font-display text-base font-normal text-accent-strong md:text-lg">
              {p.title}
            </h3>
            <p className="mt-1.5 font-sans text-sm font-light text-muted-foreground">
              {p.body}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}

function PopularCities() {
  return (
    <div className="mt-12">
      <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
        SCOUT A TOP DESTINATION
      </h2>
      <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-4">
        {TOP_CITIES.map((c) => (
          <Link key={c.slug} to="/city/$slug" params={{ slug: c.slug }}
            className="group flex flex-col rounded-lg border border-border bg-card px-3 py-2.5 text-left transition-colors hover:border-primary/50 hover:bg-accent">
            <div className="text-sm font-medium text-foreground group-hover:text-accent-strong">{c.city}</div>
            <div className="text-xs text-muted-foreground">{c.country}</div>
            <div className="mt-1 line-clamp-2 text-xs text-muted-foreground/80">{c.blurb}</div>
          </Link>
        ))}
      </div>
    </div>
  );
}
