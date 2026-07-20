import type { Venue } from "@/lib/schema";

const INK = "#23211E";
const INK_MUTED = "#6a6253";

export type PriceTier = "$" | "$$" | "$$$" | "$$$$";
export const PRICE_TIERS: PriceTier[] = ["$", "$$", "$$$", "$$$$"];

/** True if at least one venue in the pool has a price_tier value. */
export function hasPriceCoverage(venues: Venue[]): boolean {
  for (const v of venues) if (v.price_tier) return true;
  return false;
}

/** Filter a venue list by an active price tier. Undefined = pass through. */
export function applyPriceFilter<V extends { price_tier?: string }>(
  venues: V[],
  active: PriceTier | undefined,
): V[] {
  if (!active) return venues;
  return venues.filter((v) => v.price_tier === active);
}

/**
 * Bronze-outline pill segmented control for price tier selection.
 * Mirrors the existing All/Restaurants/Bars toggle visual language.
 */
export function PriceFilter({
  value,
  onChange,
}: {
  value: PriceTier | undefined;
  onChange: (v: PriceTier | undefined) => void;
}) {
  return (
    <div
      role="radiogroup"
      aria-label="Filter by price"
      className="inline-flex items-center"
      style={{
        backgroundColor: "rgba(35,33,30,0.06)",
        padding: 4,
        borderRadius: 100,
        gap: 5,
      }}
    >
      <Pill
        active={value === undefined}
        onClick={() => onChange(undefined)}
        label="Any price"
      />
      {PRICE_TIERS.map((t) => (
        <Pill
          key={t}
          active={value === t}
          onClick={() => onChange(value === t ? undefined : t)}
          label={t}
          mono
        />
      ))}
    </div>
  );
}

function Pill({
  active,
  onClick,
  label,
  mono,
}: {
  active: boolean;
  onClick: () => void;
  label: string;
  mono?: boolean;
}) {
  return (
    <button
      type="button"
      role="radio"
      aria-checked={active}
      onClick={onClick}
      style={{
        border: 0,
        backgroundColor: active ? "#FCFAF5" : "transparent",
        color: active ? INK : INK_MUTED,
        fontWeight: active ? 600 : 500,
        padding: "8px 14px",
        borderRadius: 100,
        fontSize: 14,
        fontFamily: mono ? "ui-monospace, SFMono-Regular, Menlo, monospace" : undefined,
        letterSpacing: mono ? "0.03em" : undefined,
        boxShadow: active ? "0 1px 2px rgba(0,0,0,0.06)" : "none",
        cursor: "pointer",
        transition: "background-color 120ms, color 120ms",
      }}
    >
      {label}
    </button>
  );
}