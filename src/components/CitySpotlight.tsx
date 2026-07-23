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
import { RotateCcw } from "lucide-react";

import type { Award, City, Venue } from "@/lib/schema";
import { getAwardPrestige } from "@/lib/venues";
import { awardLabelShort } from "@/lib/award-label";
import { VenuePhoto } from "@/components/VenuePhoto";
import { AwardTooltip } from "@/components/AwardTooltip";

const INK_3 = "#34312C";
const PAPER = "#F7F3EB";
const PAPER_DIM = "#E7DFCC";
const BRASS = "#C6A15B";
const BRASS_SOFT = "#D8BE8A";
const BRONZE = "#895F2E";
const LINE = "rgba(198,161,91,.28)";
const INK = "#23211E";

const OPENERS = [
  "In the mood for somewhere special?",
  "What about this place tonight?",
  "Tonight, we'd point you here.",
  "Looking for the one? Start here.",
];

function scoreVenue(v: Venue): number {
  return v.awards.reduce((sum, a) => sum + getAwardPrestige(a), 0);
}

function buildWhy(venue: Venue, city: City): string {
  const blurb = venue.blurb_short?.trim() || venue.blurb_long?.trim();
  if (blurb) return blurb;

  // De-dupe by source, prefer highest prestige.
  const bestBySource = new Map<string, (typeof venue.awards)[number]>();
  for (const a of venue.awards) {
    const cur = bestBySource.get(a.source);
    if (!cur || getAwardPrestige(a) > getAwardPrestige(cur)) {
      bestBySource.set(a.source, a);
    }
  }
  const top = Array.from(bestBySource.values())
    .sort((a, b) => getAwardPrestige(b) - getAwardPrestige(a))
    .slice(0, 2)
    .map((a) => awardLabelShort(a));

  const typeLabel = venue.type === "bar" ? "bars" : "tables";
  if (top.length === 2) {
    return `${top[0]} and ${top[1]} — one of ${city.display}'s most decorated ${typeLabel}.`;
  }
  if (top.length === 1) {
    return `${top[0]} — one of ${city.display}'s most celebrated ${typeLabel}.`;
  }
  return `One of ${city.display}'s most celebrated ${venue.type === "bar" ? "cocktail bars" : "restaurants"}.`;
}

export function CitySpotlight({ city, venues }: { city: City; venues: Venue[] }) {
  // Selection rule: prefer photographed venues, sorted by prestige. If none
  // have a photo, fall back to top prestige overall (photo-less; compass
  // placeholder will render).
  const candidates = useMemo(() => {
    const sorted = [...venues].sort((a, b) => scoreVenue(b) - scoreVenue(a));
    const photographed = sorted.filter((v) => v.photo_url && v.photo_url.trim());
    if (photographed.length > 0) {
      return photographed.slice(0, Math.min(10, photographed.length));
    }
    return sorted.slice(0, Math.min(10, sorted.length));
  }, [venues]);

  const opener = useMemo(
    () => OPENERS[Math.floor(Math.random() * OPENERS.length)],
    [],
  );
  const [featuredIdx, setFeaturedIdx] = useState(0);
  const featured = candidates[featuredIdx % Math.max(candidates.length, 1)];

  const reroll = () => {
    if (candidates.length <= 1) return;
    let next = featuredIdx;
    while (next === featuredIdx) {
      next = Math.floor(Math.random() * candidates.length);
    }
    setFeaturedIdx(next);
  };

  if (!featured) return null;

  const where = featured.neighborhood || city.display;
  const typeCap = featured.type === "bar" ? "Cocktail bar" : "Restaurant";
  const why = buildWhy(featured, city);

  // De-dupe awards by source for pills.
  const pillAwards = useMemoAwards(featured);

  const showShuffle = candidates.length > 1;
  const hasReservation = Boolean(featured.reservation_url);

  return (
    <section style={{ backgroundColor: INK_3 }} className="px-6 py-9 md:px-12 md:py-[34px]">
      <div className="mx-auto max-w-5xl">
        <div className="mb-5 flex items-baseline gap-3">
          <h2
            className="font-display text-2xl italic"
            style={{ color: BRASS_SOFT, fontWeight: 400 }}
          >
            {opener}
          </h2>
          <span
            className="ml-auto text-xs font-semibold uppercase"
            style={{ color: PAPER_DIM, letterSpacing: "0.16em" }}
          >
            {city.display}
          </span>
        </div>

        <div className="grid gap-6 md:gap-[30px] md:[grid-template-columns:320px_1fr]">
          <div
            className="overflow-hidden"
            style={{ borderRadius: 13, minHeight: 250 }}
          >
            <div className="h-full w-full md:h-[360px]">
              <VenuePhoto src={featured.photo_url} placeId={featured.id} alt={featured.name} />
            </div>
          </div>

          <div className="flex flex-col justify-center">
            <p className="text-sm" style={{ color: PAPER_DIM }}>
              {typeCap} · {where}
            </p>
            <h3
              className="mt-2 font-display text-3xl md:text-4xl"
              style={{ color: PAPER, fontWeight: 500, lineHeight: 1 }}
            >
              {featured.name}
            </h3>
            <p
              className="text-base"
              style={{
                color: PAPER,
                fontWeight: 300,
                lineHeight: 1.6,
                maxWidth: 560,
                marginTop: 14,
              }}
            >
              {why}
            </p>

            {pillAwards.length > 0 && (
              <div className="flex flex-wrap gap-1.5" style={{ marginTop: 15 }}>
                {pillAwards.map((a, i) => (
                  <AwardTooltip key={i} source={a.source} category={a.category}>
                    <span
                      className="text-xs"
                      style={{
                        color: BRASS_SOFT,
                        border: `1px solid ${LINE}`,
                        padding: "5px 11px",
                        borderRadius: 100,
                        fontWeight: 600,
                      }}
                    >
                      {awardLabelShort(a)}
                    </span>
                  </AwardTooltip>
                ))}
              </div>
            )}

            <div
              className="flex flex-wrap items-center"
              style={{ marginTop: 20, gap: 10 }}
            >
              {hasReservation ? (
                <>
                  <a
                    href={featured.reservation_url!}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1 text-sm transition-transform hover:-translate-y-0.5"
                    style={{
                      backgroundColor: BRASS,
                      color: INK,
                      fontWeight: 600,
                      padding: "11px 22px",
                      borderRadius: 8,
                    }}
                  >
                    Reserve a table <span aria-hidden>→</span>
                  </a>
                  <Link
                    to="/venue/$city/$slug"
                    params={{ city: city.slug, slug: featured.slug }}
                    className="inline-flex items-center gap-1 text-sm"
                    style={{
                      border: `1px solid ${LINE}`,
                      color: BRASS_SOFT,
                      fontWeight: 600,
                      padding: "10px 21px",
                      borderRadius: 8,
                    }}
                  >
                    View venue <span aria-hidden>→</span>
                  </Link>
                </>
              ) : (
                <Link
                  to="/venue/$city/$slug"
                  params={{ city: city.slug, slug: featured.slug }}
                  className="inline-flex items-center gap-1 text-sm transition-transform hover:-translate-y-0.5"
                  style={{
                    backgroundColor: BRASS,
                    color: INK,
                    fontWeight: 600,
                    padding: "11px 22px",
                    borderRadius: 8,
                  }}
                >
                  View venue <span aria-hidden>→</span>
                </Link>
              )}

              {showShuffle && (
                <button
                  type="button"
                  onClick={reroll}
                  className="inline-flex items-center gap-1 bg-transparent text-xs"
                  style={{ color: BRASS, border: "none", padding: "8px 4px" }}
                >
                  <RotateCcw className="h-3 w-3" />
                  Show me another
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function useMemoAwards(venue: Venue): Award[] {
  return useMemo(() => {
    const bestBySource = new Map<string, (typeof venue.awards)[number]>();
    for (const a of venue.awards) {
      const cur = bestBySource.get(a.source);
      if (!cur || getAwardPrestige(a) > getAwardPrestige(cur)) {
        bestBySource.set(a.source, a);
      }
    }
    return Array.from(bestBySource.values())
      .sort((a, b) => getAwardPrestige(b) - getAwardPrestige(a))
      .slice(0, 3);
  }, [venue]);
}