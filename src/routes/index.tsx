import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useEffect, useRef, useState } from "react";
import { Loader2, LocateFixed } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ExploreByGuide } from "@/components/ExploreByGuide";
import { HeroCompass } from "@/components/Compass";
import { CitySearch, type CitySearchHandle } from "@/components/CitySearch";
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
  const searchRef = useRef<CitySearchHandle>(null);

  useEffect(() => {
    if (nearMe.requested && nearMe.coords) {
      const { city } = findNearestCity(nearMe.coords);
      navigate({ to: "/city/$slug", params: { slug: city.slug } });
    }
  }, [nearMe.requested, nearMe.coords, navigate]);

  return (
    <main className="relative min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-6 py-12 md:py-20">
        <section className="relative">
          <header className="relative overflow-hidden px-2 pb-10 pt-8 text-center md:px-4 md:pb-14 md:pt-10">
            {/* Hero background layers (non-interactive) — scoped to header */}
            <div aria-hidden className="pointer-events-none absolute inset-0 -z-0">
              {/* Warm top-sourced wash — light from above, fading down before the search row */}
              <div
                className="absolute inset-0"
                style={{
                  background:
                    "radial-gradient(120% 80% at 50% -10%, color-mix(in oklab, var(--primary) 16%, transparent), transparent 60%)",
                }}
              />
              {/* Large-cell grid */}
              <div
                className="absolute inset-0"
                style={{
                  backgroundImage:
                    "linear-gradient(to right, color-mix(in oklab, var(--primary) 5%, transparent) 1px, transparent 1px), linear-gradient(to bottom, color-mix(in oklab, var(--primary) 5%, transparent) 1px, transparent 1px)",
                  backgroundSize: "110px 110px",
                  WebkitMaskImage:
                    "radial-gradient(ellipse 82% 80% at 50% 42%, transparent 8%, #000 58%, transparent 100%)",
                  maskImage:
                    "radial-gradient(ellipse 82% 80% at 50% 42%, transparent 8%, #000 58%, transparent 100%)",
                }}
              />
            </div>
            {/* Corner coordinates — pinned to header so all three are visible */}
            <div
              aria-hidden
              className="pointer-events-none absolute left-1 top-1 z-10 font-display text-[11px] tracking-wide md:left-3 md:top-3 md:text-xs"
              style={{ color: "color-mix(in oklab, var(--primary) 22%, transparent)" }}
            >
              33°45′N
            </div>
            <div
              aria-hidden
              className="pointer-events-none absolute right-1 top-1 z-10 font-display text-[11px] tracking-wide md:right-3 md:top-3 md:text-xs"
              style={{ color: "color-mix(in oklab, var(--primary) 22%, transparent)" }}
            >
              84°23′W
            </div>
            <div
              aria-hidden
              className="pointer-events-none absolute bottom-1 right-1 z-10 font-display text-[11px] tracking-[0.2em] md:bottom-3 md:right-3 md:text-xs"
              style={{ color: "color-mix(in oklab, var(--primary) 22%, transparent)" }}
            >
              ATL
            </div>

            <div className="relative z-10">
            <HeroCompass className="mx-auto mb-6 w-full max-w-[180px] md:max-w-[200px]" />
            <p className="mb-3 text-xs uppercase tracking-[0.2em] text-accent-strong">
              The world's best, wherever you are
            </p>
            <h1 className="font-display text-4xl font-light tracking-tight text-foreground md:text-6xl">
              Eat and drink well,
              <br />
              <em className="not-italic italic text-accent-strong/90" style={{ fontStyle: "italic" }}>
                anywhere on earth.
              </em>
            </h1>
            <p className="mx-auto mt-5 max-w-xl text-base text-muted-foreground md:text-lg">
              Name a city. We'll point you to its finest tables and bars — ranked by the guides that matter.
            </p>
            </div>
          </header>

          <div className="relative z-10 mt-8">
          <div className="flex flex-wrap items-center justify-center gap-3.5">
            <div className="min-w-0 flex-1">
              <CitySearch placeholder={placeholder} actionRef={searchRef} />
            </div>
            <Button
              type="button"
              onClick={() => searchRef.current?.submit()}
              className="interactive h-12 shrink-0 rounded-full bg-primary px-5 text-sm font-medium text-primary-foreground hover:bg-primary/90"
            >
              Find the best →
            </Button>
          </div>
          <div className="mt-3 text-center">
            <button
              type="button"
              onClick={() => nearMe.requestLocation()}
              disabled={nearMe.loading}
              className="interactive inline-flex items-center gap-1.5 text-xs text-accent-strong underline-offset-4 hover:underline disabled:opacity-60"
            >
              {nearMe.loading ? (
                <>
                  <Loader2 className="h-3 w-3 animate-spin" />
                  Finding your city…
                </>
              ) : (
                <>
                  <LocateFixed className="h-3.5 w-3.5" />
                  Use my location instead
                </>
              )}
            </button>
          </div>
          {nearMe.error && (
            <div className="mt-3 flex flex-col items-center gap-1 text-center">
              <p className="text-xs text-destructive">{nearMe.error}</p>
              <p className="text-[11px] text-muted-foreground">
                No problem — pick a charted city below to get started.
              </p>
            </div>
          )}
          </div>
        </section>

        <section className="mt-12">
          <TopDestinations />
          <ExploreByGuide />
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

const FIXED_EIGHT = TOP_CITIES.slice(0, 8);

function TopDestinations() {
  return (
    <div className="mt-12">
      <div className="mb-6 text-center">
        <p className="text-xs uppercase tracking-[0.2em] text-accent-strong">
          Top destinations
        </p>
      </div>
      <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
        {FIXED_EIGHT.map((c) => (
          <Link
            key={c.slug}
            to="/city/$slug"
            params={{ slug: c.slug }}
            className="interactive group flex h-full flex-col items-center justify-center rounded-lg border border-border bg-card px-4 py-5 text-center hover:border-primary/50"
          >
            <div className="font-display text-xl text-foreground group-hover:text-accent-strong">
              {c.city}
            </div>
            <div className="mt-1 text-xs uppercase tracking-[0.1em] text-muted-foreground">
              {c.country}
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
