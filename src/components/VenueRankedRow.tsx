/**
 * VenueRankedRow — one line in a city's ranked listings.
 *
 * Entire row is a Link to the venue detail page. Optional fields (price,
 * neighborhood, blurb, awards) all hide gracefully when absent.
 */

import { Link } from "@tanstack/react-router";
import { ArrowRight } from "lucide-react";

import type { Venue } from "@/lib/schema";
import { AwardBadgeRow } from "@/components/AwardBadge";

const TIERS = ["$", "$$", "$$$", "$$$$"] as const;

function PriceTier({ tier }: { tier: Venue["price_tier"] }) {
  if (!tier) return null;
  const filled = tier.length;
  return (
    <span
      aria-label={`Price tier ${tier}`}
      className="font-mono text-xs tracking-tight"
    >
      <span className="text-accent-strong">{tier}</span>
      <span className="text-muted-foreground/30">
        {"$".repeat(TIERS.length - filled)}
      </span>
    </span>
  );
}

export function VenueRankedRow({
  venue,
  rank,
}: {
  venue: Venue;
  rank: number;
}) {
  const where = venue.neighborhood || venue.city_display;

  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: venue.city_slug, slug: venue.slug }}
      className="interactive group block rounded-xl border border-transparent px-4 py-4 hover:border-border hover:bg-card/60 md:px-5"
    >
      <div className="flex items-start gap-4 md:gap-6">
        <div className="w-10 shrink-0 pt-1 text-right font-display text-2xl font-light text-accent-strong md:w-12 md:text-3xl">
          {String(rank).padStart(2, "0")}
        </div>

        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
            <h3 className="font-display text-lg font-light italic text-foreground group-hover:text-accent-strong md:text-xl">
              {venue.name}
            </h3>
            <p className="text-[10px] font-semibold uppercase tracking-[0.18em] text-muted-foreground">
              {venue.type === "bar" ? "Cocktail bar" : "Restaurant"} · {where}
            </p>
            {venue.price_tier && (
              <span className="ml-auto">
                <PriceTier tier={venue.price_tier} />
              </span>
            )}
          </div>

          {venue.blurb_short && (
            <p className="mt-1.5 line-clamp-2 max-w-prose text-sm text-muted-foreground">
              {venue.blurb_short}
            </p>
          )}

          <div className="mt-3 flex flex-wrap items-center gap-2">
            <AwardBadgeRow venue={venue} max={3} short />
            <span className="ml-auto inline-flex items-center gap-1 text-xs text-accent-strong opacity-0 transition-opacity group-hover:opacity-100">
              View <ArrowRight className="h-3 w-3" />
            </span>
          </div>
        </div>
      </div>
    </Link>
  );
}