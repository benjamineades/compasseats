import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Loader2, Locate } from "lucide-react";
import { Button } from "@/components/ui/button";
import { AwardMarquee } from "@/components/AwardMarquee";
import { ExploreByAward } from "@/components/ExploreByAward";
import { Compass, Wordmark, HeroCompass } from "@/components/Compass";
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

        <section className="mt-10">
          <div className="mt-6 flex flex-col items-center gap-6">
            <HeroCompass className="w-full max-w-[220px]" />
          </div>
          <AwardMarquee />
          <PopularCities />
          <ExploreByAward />
        </section>
      </div>
    </main>
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
