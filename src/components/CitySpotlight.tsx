/**
 * CitySpotlight — the "what about tonight?" band on a city page.
 *
 * Renders one featured venue from the city's top-prestige pool, with a
 * rotating soft opener and a re-roll control. Once hours data is populated,
 * it prefers venues that are open now (see the OPEN_NOW comment below) and
 * falls back to prestige otherwise.
 */

import { useMemo, useState } from "react";
import { Link } from "@tanstack/react-router";
import { ArrowRight, RotateCcw } from "lucide-react";

import type { City, Venue } from "@/lib/schema";
import { getAwardPrestige } from "@/lib/venues";
import { isOpenNow } from "@/lib/open-now";
import { formatCoord } from "@/lib/format-coords";
import { Button } from "@/components/ui/button";
import { AwardBadgeRow } from "@/components/AwardBadge";
import { VenuePhoto } from "@/components/VenuePhoto";

const OPENERS = [
  "In the mood for somewhere special?",
  "What about this place tonight?",
  "Tonight, we'd point you here.",
  "Looking for the one? Start here.",
];

function scoreVenue(v: Venue): number {
  return v.awards.reduce((sum, a) => sum + getAwardPrestige(a), 0);
}

export function CitySpotlight({ city, venues }: { city: City; venues: Venue[] }) {
  // Pool: top 10 by prestige — the candidate set for "show me another".
  const pool = useMemo(() => {
    return [...venues]
      .sort((a, b) => scoreVenue(b) - scoreVenue(a))
      .slice(0, Math.min(10, venues.length));
  }, [venues]);

  // OPEN_NOW: prefer venues currently open in the city's timezone. When no
  // hours are populated yet, every isOpenNow() returns null and openPool is
  // empty → we fall back to the prestige pool. This branch activates
  // automatically once `venue.hours` lands in the data.
  const openPool = useMemo(() => {
    return pool.filter((v) => isOpenNow(v, city.timezone) === true);
  }, [pool, city.timezone]);

  const candidates = openPool.length > 0 ? openPool : pool;

  // Random opener + initial featured pick, stable per render.
  const opener = useMemo(
    () => OPENERS[Math.floor(Math.random() * OPENERS.length)],
    [],
  );
  const [featuredIdx, setFeaturedIdx] = useState(0);
  const featured = candidates[featuredIdx % Math.max(candidates.length, 1)];

  const reroll = () => {
    if (candidates.length <= 1) return;
    let next = featuredIdx;
    // Avoid landing on the same venue twice in a row.
    while (next === featuredIdx) {
      next = Math.floor(Math.random() * candidates.length);
    }
    setFeaturedIdx(next);
  };

  if (!featured) return null;

  const where = featured.neighborhood || featured.city_display;
  const why =
    featured.blurb_short?.trim() ||
    `A charted favorite in ${featured.neighborhood || city.display}.`;

  return (
    <section className="relative overflow-hidden border-y border-border bg-card">
      <div className="mx-auto max-w-5xl px-6 py-12 md:py-16">
        <div className="mb-8 flex flex-wrap items-baseline justify-between gap-3">
          <h2 className="font-display text-2xl font-light italic text-foreground md:text-3xl">
            {opener}
          </h2>
          <span className="text-[10px] font-semibold uppercase tracking-[0.25em] text-accent-strong">
            {city.display}
          </span>
        </div>

        <div className="grid gap-6 md:grid-cols-[300px_1fr] md:gap-8">
          <div className="aspect-[4/5] w-full overflow-hidden rounded-xl border border-border md:aspect-auto md:h-[360px]">
            <VenuePhoto src={featured.photo_url} alt={featured.name} />
          </div>

          <div className="flex flex-col">
            <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
              {featured.type === "bar" ? "Cocktail bar" : "Restaurant"} · {where}
            </p>
            <h3 className="mt-2 font-display text-3xl font-light italic text-foreground md:text-4xl">
              {featured.name}
            </h3>
            <p className="mt-3 max-w-prose text-sm text-muted-foreground md:text-base">
              {why}
            </p>

            <div className="mt-4">
              <AwardBadgeRow venue={featured} max={3} short />
            </div>

            <div className="mt-6 flex flex-wrap items-center gap-2">
              {featured.reservation_url && (
                <Button asChild size="sm" className="interactive">
                  <a
                    href={featured.reservation_url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Reserve a table
                  </a>
                </Button>
              )}
              <Button asChild size="sm" variant="outline" className="interactive">
                <Link
                  to="/venue/$city/$slug"
                  params={{ city: featured.city_slug, slug: featured.slug }}
                >
                  View venue
                  <ArrowRight className="ml-1 h-3.5 w-3.5" />
                </Link>
              </Button>
              {candidates.length > 1 && (
                <button
                  type="button"
                  onClick={reroll}
                  className="interactive ml-auto inline-flex items-center gap-1.5 rounded-full border border-border px-3 py-1.5 text-xs text-muted-foreground hover:text-accent-strong"
                >
                  <RotateCcw className="h-3 w-3" />
                  Show me another
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Faint city coordinate, bottom-right. */}
      <span
        aria-hidden="true"
        className="pointer-events-none absolute bottom-3 right-4 font-display text-xs tracking-wider"
        style={{ color: "color-mix(in oklab, var(--primary) 12%, transparent)" }}
      >
        {formatCoord(city.lat, city.lng)}
      </span>
    </section>
  );
}