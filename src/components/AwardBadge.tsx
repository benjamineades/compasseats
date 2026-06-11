/**
 * AwardBadge — small pill for displaying a single Award.
 *
 * Visual match to the inline pill used in VenueMap popups: rounded-full,
 * 1px border, small uppercase letter-spaced text in --accent-strong over a
 * transparent background. Non-interactive label; safe to nest inside an
 * interactive parent (no hover affordance of its own).
 */

import { cn } from "@/lib/utils";
import type { Award, Venue } from "@/lib/schema";
import { awardLabel, awardLabelShort } from "@/lib/award-label";
import { getAwardPrestige } from "@/lib/venues";

export function AwardBadge({
  award,
  short = false,
  className,
}: {
  award: Award;
  short?: boolean;
  className?: string;
}) {
  const label = short ? awardLabelShort(award) : awardLabel(award);
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border border-border bg-transparent",
        "px-2.5 py-1 text-[0.7rem] uppercase tracking-[0.05em]",
        "text-accent-strong",
        className,
      )}
    >
      {label}
    </span>
  );
}

/**
 * Renders a venue's top awards as a row of badges. Picks the highest-prestige
 * award per source (so a venue with multiple Michelin years shows Michelin
 * once), then sorts by prestige and caps at `max`.
 */
export function AwardBadgeRow({
  venue,
  max = 3,
  short = false,
  className,
}: {
  venue: Venue;
  max?: number;
  short?: boolean;
  className?: string;
}) {
  const bestBySource = new Map<string, Award>();
  for (const a of venue.awards) {
    const current = bestBySource.get(a.source);
    if (!current) {
      bestBySource.set(a.source, a);
      continue;
    }
    // Keep the most recent entry per source; on a year tie, prefer the
    // better (lower) rank, treating a missing rank as worse than any number.
    const challengerRank = a.rank ?? Infinity;
    const incumbentRank = current.rank ?? Infinity;
    if (
      a.year > current.year ||
      (a.year === current.year && challengerRank < incumbentRank)
    ) {
      bestBySource.set(a.source, a);
    }
  }

  const top = Array.from(bestBySource.values())
    .sort((a, b) => getAwardPrestige(b) - getAwardPrestige(a))
    .slice(0, max);

  if (top.length === 0) return null;

  return (
    <div className={cn("flex flex-wrap items-center gap-1.5", className)}>
      {top.map((a) => (
        <AwardBadge key={`${a.source}-${a.year}-${a.category}`} award={a} short={short} />
      ))}
    </div>
  );
}