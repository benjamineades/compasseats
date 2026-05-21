import type { AccoladeEntry } from "./accolades.server";

// Pure scoring functions for venue ranking priority.
// Restaurants:
//   1. Most recent World's 50 Best Restaurants (current year or last year)
//   2. Michelin 3-star
//   3. Best Chef Awards 3-Knives
//   4. Michelin 2-star
//   5. Best Chef Awards 2-Knives
//   6. James Beard Award
//   7. Michelin 1-star
//   8. Best Chef Awards 1-Knife
//   9. Older World's 50 Best entries
//  10. Yelp / TripAdvisor fallback (no sheet entry → score 0)
// Bars: World's 50 Best Bars by year then rank.
export const restaurantScore = (
  s: AccoladeEntry | null,
  currentYear: number,
): number => {
  if (!s) return 0;
  const w50 = s.worldsBest50Restaurants;
  if (w50 && w50.year >= currentYear - 1) return 10_000_000 + (100 - w50.rank);
  if (s.michelinStars === 3) return 9_000_000;
  if (s.bestChefAward?.knives === 3) return 8_500_000 + s.bestChefAward.year;
  if (s.michelinStars === 2) return 8_000_000;
  if (s.bestChefAward?.knives === 2) return 7_500_000 + s.bestChefAward.year;
  if (s.jamesBeardAward) return 7_000_000 + s.jamesBeardAward.year;
  if (s.michelinStars === 1) return 6_500_000;
  if (s.bestChefAward?.knives === 1) return 6_000_000 + s.bestChefAward.year;
  if (w50) return 5_000_000 + w50.year * 100 + (100 - w50.rank);
  return 0;
};

export const barScore = (s: AccoladeEntry | null): number => {
  if (!s) return 0;
  let score = 0;
  const w = s.worldsBest50Bars;
  if (w) score = Math.max(score, 10_000_000 + w.year * 1000 + (100 - w.rank));
  if (s.pinnacleAward) {
    // 3-pin > 2-pin > 1-pin; recency as tiebreaker
    score = Math.max(
      score,
      8_000_000 + s.pinnacleAward.pins * 100_000 + s.pinnacleAward.year,
    );
  }
  if (s.spiritedAward) {
    score = Math.max(score, 6_000_000 + s.spiritedAward.year);
  }
  return score;
};