import { describe, it, expect } from "vitest";
import { restaurantScore, barScore } from "@/lib/ranking";
import type { AccoladeEntry } from "@/lib/accolades.server";

const CURRENT_YEAR = 2026;

const make = (e: Partial<AccoladeEntry>): AccoladeEntry => ({ ...e });

describe("restaurantScore — strict priority order", () => {
  // Build one venue per tier, then assert scores are strictly descending.
  const w50Current = make({ worldsBest50Restaurants: { rank: 12, year: CURRENT_YEAR } });
  const m3 = make({ michelinStars: 3 });
  const bc3 = make({ bestChefAward: { knives: 3, year: 2025 } });
  const m2 = make({ michelinStars: 2 });
  const bc2 = make({ bestChefAward: { knives: 2, year: 2025 } });
  const jba = make({ jamesBeardAward: { name: "Best Chef: NY", year: 2024 } });
  const m1 = make({ michelinStars: 1 });
  const bc1 = make({ bestChefAward: { knives: 1, year: 2025 } });
  const w50Old = make({ worldsBest50Restaurants: { rank: 5, year: 2020 } });
  const fallback = null;

  const tiers = [
    ["W50 current", w50Current],
    ["Michelin 3★", m3],
    ["Best Chef 3-knives", bc3],
    ["Michelin 2★", m2],
    ["Best Chef 2-knives", bc2],
    ["James Beard", jba],
    ["Michelin 1★", m1],
    ["Best Chef 1-knife", bc1],
    ["Older W50", w50Old],
    ["Yelp/TripAdvisor fallback", fallback],
  ] as const;

  it("scores each tier strictly higher than the next", () => {
    for (let i = 0; i < tiers.length - 1; i++) {
      const [aLabel, a] = tiers[i];
      const [bLabel, b] = tiers[i + 1];
      const sa = restaurantScore(a, CURRENT_YEAR);
      const sb = restaurantScore(b, CURRENT_YEAR);
      expect(sa, `${aLabel} (${sa}) should beat ${bLabel} (${sb})`).toBeGreaterThan(sb);
    }
  });

  it("sorts a mixed list into the expected order", () => {
    const items = tiers.map(([label, e], idx) => ({
      label,
      score: restaurantScore(e, CURRENT_YEAR),
      idx,
    }));
    // Shuffle deterministically then sort by score desc.
    const shuffled = [...items].sort((a, b) => (a.idx * 7) % 11 - (b.idx * 7) % 11);
    const ordered = [...shuffled].sort((a, b) => b.score - a.score);
    expect(ordered.map((x) => x.label)).toEqual(tiers.map(([l]) => l));
  });

  it("treats last-year's W50 as 'current'", () => {
    const lastYear = make({ worldsBest50Restaurants: { rank: 50, year: CURRENT_YEAR - 1 } });
    expect(restaurantScore(lastYear, CURRENT_YEAR)).toBeGreaterThan(restaurantScore(m3, CURRENT_YEAR));
  });

  it("treats 2-year-old W50 as 'older' (below Michelin 1★)", () => {
    const older = make({ worldsBest50Restaurants: { rank: 1, year: CURRENT_YEAR - 2 } });
    expect(restaurantScore(older, CURRENT_YEAR)).toBeLessThan(restaurantScore(m1, CURRENT_YEAR));
  });

  it("breaks W50-current ties by rank (lower rank = higher score)", () => {
    const r1 = make({ worldsBest50Restaurants: { rank: 1, year: CURRENT_YEAR } });
    const r50 = make({ worldsBest50Restaurants: { rank: 50, year: CURRENT_YEAR } });
    expect(restaurantScore(r1, CURRENT_YEAR)).toBeGreaterThan(restaurantScore(r50, CURRENT_YEAR));
  });

  it("returns 0 for null (Yelp/TripAdvisor fallback)", () => {
    expect(restaurantScore(null, CURRENT_YEAR)).toBe(0);
  });
});

describe("barScore", () => {
  it("ranks more recent World's 50 Best Bars higher", () => {
    const newer = make({ worldsBest50Bars: { rank: 50, year: CURRENT_YEAR } });
    const older = make({ worldsBest50Bars: { rank: 1, year: CURRENT_YEAR - 1 } });
    expect(barScore(newer)).toBeGreaterThan(barScore(older));
  });

  it("breaks ties by rank", () => {
    const r1 = make({ worldsBest50Bars: { rank: 1, year: CURRENT_YEAR } });
    const r50 = make({ worldsBest50Bars: { rank: 50, year: CURRENT_YEAR } });
    expect(barScore(r1)).toBeGreaterThan(barScore(r50));
  });

  it("returns 0 for bars without a W50 Bars entry", () => {
    expect(barScore(null)).toBe(0);
    expect(barScore(make({ michelinStars: 3 }))).toBe(0);
  });
});