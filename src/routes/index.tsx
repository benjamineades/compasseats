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

type CitySuggestion = { city_slug: string; city_display: string; country: string };

function normalize(s: string) {
  return s.toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g, "");
}

function StaticSearch({ placeholder }: { placeholder: string }) {
  const [value, setValue] = useState("");
  const [index, setIndex] = useState<VenueIndexEntry[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);
  const wrapRef = useRef<HTMLDivElement>(null);

  const loadIndex = async () => {
    if (index || loading) return;
    setLoading(true);
    try {
      const mod = await import("../../data/venues-index.json");
      setIndex((mod.default ?? mod) as VenueIndexEntry[]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const onDoc = (e: MouseEvent) => {
      if (!wrapRef.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onDoc);
    return () => document.removeEventListener("mousedown", onDoc);
  }, []);

  const { cities, venues } = useMemo(() => {
    const q = normalize(value.trim());
    if (!index || q.length < 2) return { cities: [] as CitySuggestion[], venues: [] as VenueIndexEntry[] };
    const cityMap = new Map<string, CitySuggestion>();
    const venueHits: VenueIndexEntry[] = [];
    for (const v of index) {
      const name = normalize(v.name);
      const city = normalize(v.city_display);
      const country = normalize(v.country);
      const cityMatch = city.includes(q) || country.includes(q);
      const nameMatch = name.includes(q);
      if (cityMatch && !cityMap.has(v.city_slug)) {
        cityMap.set(v.city_slug, {
          city_slug: v.city_slug,
          city_display: v.city_display,
          country: v.country,
        });
      }
      if (nameMatch && venueHits.length < 8) {
        venueHits.push(v);
      }
    }
    return { cities: Array.from(cityMap.values()).slice(0, 6), venues: venueHits };
  }, [index, value]);

  const flat: Array<
    | { kind: "city"; data: CitySuggestion }
    | { kind: "venue"; data: VenueIndexEntry }
  > = useMemo(
    () => [
      ...cities.map((c) => ({ kind: "city" as const, data: c })),
      ...venues.map((v) => ({ kind: "venue" as const, data: v })),
    ],
    [cities, venues],
  );

  const navigate = useNavigate();
  const go = (item: (typeof flat)[number]) => {
    setOpen(false);
    if (item.kind === "city") {
      navigate({ to: "/city/$slug", params: { slug: item.data.city_slug } });
    } else {
      navigate({
        to: "/venue/$city/$slug",
        params: { city: item.data.city_slug, slug: item.data.slug },
      });
    }
  };

  const hasResults = flat.length > 0;
  const showEmpty = !!index && value.trim().length >= 2 && !hasResults;

  return (
    <div ref={wrapRef} className="relative">
      <Search className="pointer-events-none absolute left-3 top-[1.4rem] h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      {loading && (
        <Loader2 className="pointer-events-none absolute right-3 top-[1.4rem] h-4 w-4 -translate-y-1/2 animate-spin text-muted-foreground" />
      )}
      <Input
        value={value}
        onChange={(e) => {
          setValue(e.target.value);
          setOpen(true);
          setActive(0);
        }}
        onFocus={() => {
          loadIndex();
          setOpen(true);
        }}
        onKeyDown={(e) => {
          if (!open || flat.length === 0) return;
          if (e.key === "ArrowDown") {
            e.preventDefault();
            setActive((a) => (a + 1) % flat.length);
          } else if (e.key === "ArrowUp") {
            e.preventDefault();
            setActive((a) => (a - 1 + flat.length) % flat.length);
          } else if (e.key === "Enter") {
            e.preventDefault();
            go(flat[active]);
          } else if (e.key === "Escape") {
            setOpen(false);
          }
        }}
        placeholder={placeholder}
        className="h-12 pl-10 pr-10 text-base"
        maxLength={100}
        autoComplete="off"
      />
      {open && (hasResults || showEmpty) && (
        <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-96 overflow-auto rounded-md border border-border bg-popover py-1 text-sm shadow-lg">
          {cities.length > 0 && (
            <div className="px-3 py-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
              Cities
            </div>
          )}
          {cities.map((c, i) => {
            const idx = i;
            return (
              <button
                key={`c-${c.city_slug}`}
                type="button"
                onMouseDown={(e) => {
                  e.preventDefault();
                  go({ kind: "city", data: c });
                }}
                onMouseEnter={() => setActive(idx)}
                className={`flex w-full items-center gap-2 px-3 py-2 text-left ${
                  idx === active ? "bg-accent text-accent-foreground" : "text-foreground"
                }`}
              >
                <MapPin className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                <span className="truncate">
                  {c.city_display}
                  <span className="text-muted-foreground">, {c.country}</span>
                </span>
              </button>
            );
          })}
          {venues.length > 0 && (
            <div className="mt-1 px-3 py-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
              Venues
            </div>
          )}
          {venues.map((v, i) => {
            const idx = cities.length + i;
            return (
              <button
                key={`v-${v.id}`}
                type="button"
                onMouseDown={(e) => {
                  e.preventDefault();
                  go({ kind: "venue", data: v });
                }}
                onMouseEnter={() => setActive(idx)}
                className={`flex w-full items-center gap-2 px-3 py-2 text-left ${
                  idx === active ? "bg-accent text-accent-foreground" : "text-foreground"
                }`}
              >
                <Utensils className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                <span className="min-w-0 flex-1 truncate">
                  {v.name}
                  <span className="text-muted-foreground">
                    {" "}— {v.city_display}, {v.country}
                  </span>
                </span>
              </button>
            );
          })}
          {showEmpty && (
            <div className="px-3 py-3 text-xs text-muted-foreground">
              No charted matches. Try a city below.
            </div>
          )}
        </div>
      )}
    </div>
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
