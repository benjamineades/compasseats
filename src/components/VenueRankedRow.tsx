/**
 * VenueRankedRow — one line in a city's ranked listings.
 *
 * Entire row is a Link to the venue detail page. Optional fields (price,
 * neighborhood, blurb, awards) all hide gracefully when absent.
 */

import { Link } from "@tanstack/react-router";
import type { Venue } from "@/lib/schema";
import { AwardBadgeRow } from "@/components/AwardBadge";

const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";
const BRASS_HOVER_BG = "rgba(198,161,91,0.06)";

const TIERS = ["$", "$$", "$$$", "$$$$"] as const;

function PriceTier({ tier }: { tier: Venue["price_tier"] }) {
  if (!tier) return null;
  const filled = tier.length;
  return (
    <span
      aria-label={`Price tier ${tier}`}
      className="font-mono text-xs"
      style={{ letterSpacing: "0.05em", fontWeight: 600 }}
    >
      <span style={{ color: BRONZE }}>{tier}</span>
      <span style={{ color: BRONZE, opacity: 0.3 }}>
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
  const typeLabel = venue.type === "bar" ? "Cocktail bar" : "Restaurant";

  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: venue.city_slug, slug: venue.slug }}
      className="group block"
      style={{
        padding: "18px 6px",
        borderBottom: `1px solid ${HAIRLINE}`,
        transition: "background-color 160ms ease, padding-left 160ms ease",
      }}
      onMouseEnter={(e) => {
        e.currentTarget.style.backgroundColor = BRASS_HOVER_BG;
        e.currentTarget.style.paddingLeft = "14px";
      }}
      onMouseLeave={(e) => {
        e.currentTarget.style.backgroundColor = "transparent";
        e.currentTarget.style.paddingLeft = "6px";
      }}
    >
      <div
        className="grid items-center gap-4 md:gap-6"
        style={{ gridTemplateColumns: "40px 1fr auto auto" }}
      >
        <div
          className="font-display text-lg"
          style={{ color: BRONZE, fontWeight: 500 }}
        >
          {String(rank).padStart(2, "0")}
        </div>

        <div className="min-w-0">
          <h3
            className="font-display"
            style={{
              color: INK,
              fontSize: "1.35rem",
              fontWeight: 400,
              lineHeight: 1.2,
              transition: "color 160ms ease",
            }}
          >
            <span
              className="group-hover:[color:var(--hov)]"
              style={{ ["--hov" as never]: BRONZE }}
            >
              {venue.name}
            </span>
          </h3>
          <p className="mt-1 text-sm" style={{ color: INK_MUTED }}>
            {typeLabel} · {where}
          </p>
          {venue.blurb_short && (
            <p
              className="mt-1.5 line-clamp-2 max-w-prose text-sm"
              style={{ color: INK_MUTED }}
            >
              {venue.blurb_short}
            </p>
          )}
          <div className="mt-2 flex flex-wrap items-center gap-2">
            <AwardBadgeRow venue={venue} max={3} short />
          </div>
        </div>

        <div className="hidden md:block">
          {venue.price_tier && <PriceTier tier={venue.price_tier} />}
        </div>

        <div />
      </div>
    </Link>
  );
}