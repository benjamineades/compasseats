import {
  createFileRoute,
  Link,
  useLocation,
} from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { findNearestCities } from "@/lib/cities";
import { geoapifyCitySearch } from "@/lib/geoapify-search";

const SITE_URL = "https://compasseats.com";

type PlaceState = {
  name: string;
  region?: string;
  country: string;
  lat: number;
  lng: number;
};

function titleizeSlug(slug: string) {
  return slug
    .split("-")
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1))
    .join(" ");
}

export const Route = createFileRoute("/uncharted/$slug")({
  head: ({ params }) => {
    const name = titleizeSlug(params.slug);
    const title = `${name}, not yet charted | CompassEats`;
    const description = `We haven't charted ${name} yet. Discover top restaurants and bars in the closest charted cities.`;
    const url = `${SITE_URL}/uncharted/${params.slug}`;
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: url },
      ],
      links: [{ rel: "canonical", href: url }],
    };
  },
  component: UnchartedPage,
});

function UnchartedPage() {
  const { slug } = Route.useParams();
  const stateFromRouter = useLocation({
    select: (s) => (s.state as { place?: PlaceState } | undefined)?.place,
  });

  const [place, setPlace] = useState<PlaceState | null>(
    stateFromRouter ?? null,
  );
  const [resolving, setResolving] = useState(!stateFromRouter);

  // Fallback: direct URL hit. Resolve via Geoapify.
  useEffect(() => {
    if (place) return;
    const guessName = titleizeSlug(slug);
    let cancelled = false;
    geoapifyCitySearch(guessName)
      .then((res) => {
        if (cancelled) return;
        const first = res[0];
        if (first) {
          setPlace({
            name: first.name,
            region: first.region,
            country: first.country,
            lat: first.lat,
            lng: first.lng,
          });
        }
      })
      .catch(() => {})
      .finally(() => !cancelled && setResolving(false));
    return () => {
      cancelled = true;
    };
  }, [place, slug]);

  const nearest = useMemo(() => {
    if (!place) return [];
    return findNearestCities([place.lat, place.lng], 3);
  }, [place]);

  const displayName = place?.name ?? titleizeSlug(slug);

  return (
    <main className="relative min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-6 py-16 md:py-24">
        <header>
          <h1
            className="font-display text-4xl font-light tracking-tight text-foreground md:text-6xl"
          >
            {displayName}, not yet charted.
          </h1>
          {place && (
            <p
              className="mt-4 text-sm uppercase tracking-[0.32em]"
              style={{
                fontFamily: '"Hanken Grotesk", system-ui, sans-serif',
                color: "var(--primary)",
              }}
            >
              {place.country}
              {place.region ? ` · ${place.region}` : ""}
            </p>
          )}
        </header>

        <p
          className="mt-8 max-w-[640px]"
          style={{
            fontFamily: "Fraunces, serif",
            fontSize: "1.18rem",
            lineHeight: 1.55,
            color: "var(--foreground)",
          }}
        >
          We're roaming further every week, but we haven't mapped out {displayName}'s
          best tables and bars yet.
        </p>

        {resolving && !place && (
          <p className="mt-8 text-sm text-muted-foreground">
            Finding nearby charted cities…
          </p>
        )}

        {nearest.length > 0 && (
          <section className="mt-14">
            <div
              style={{
                fontFamily: '"Hanken Grotesk", system-ui, sans-serif',
                fontWeight: 600,
                fontSize: "0.72rem",
                letterSpacing: "0.32em",
                textTransform: "uppercase",
                color: "var(--primary)",
                marginBottom: 18,
              }}
            >
              Closest charted cities
            </div>
            <ul className="flex flex-col gap-6">
              {nearest.map(({ city, distanceKm }) => {
                const miles = Math.round(distanceKm * 0.621371);
                return (
                  <li
                    key={city.slug}
                    className="border-b border-border pb-6 last:border-0"
                  >
                    <div
                      style={{
                        fontFamily: "Fraunces, serif",
                        fontWeight: 400,
                        fontSize: "1.4rem",
                        color: "var(--foreground)",
                      }}
                    >
                      {city.display}, {city.country}
                    </div>
                    <div
                      className="mt-1"
                      style={{
                        fontFamily: '"Hanken Grotesk", system-ui, sans-serif',
                        fontWeight: 400,
                        fontSize: "0.88rem",
                        color: "var(--muted-foreground)",
                      }}
                    >
                      {miles} miles away · {city.venue_count}{" "}
                      {city.venue_count === 1 ? "venue" : "venues"}
                    </div>
                    <Link
                      to="/city/$slug"
                      params={{ slug: city.slug }}
                      className="mt-3 inline-flex items-center gap-2 text-sm hover:underline"
                      style={{ color: "var(--primary)" }}
                    >
                      Take me there →
                    </Link>
                  </li>
                );
              })}
            </ul>
          </section>
        )}

        <div className="mt-16 text-sm text-muted-foreground">
          <Link to="/" className="hover:text-foreground">
            Or find your bearings in another city →
          </Link>
        </div>
      </div>
    </main>
  );
}