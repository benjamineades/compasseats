/**
 * Format a (lat, lng) decimal pair as compact degrees-minutes with
 * hemisphere suffixes, e.g. (38.7223, -9.1393) → "38°43′N · 9°08′W".
 */
export function formatCoord(lat: number, lng: number): string {
  return `${dm(lat, "N", "S")} · ${dm(lng, "E", "W")}`;
}

function dm(value: number, pos: string, neg: string): string {
  const hemi = value >= 0 ? pos : neg;
  const abs = Math.abs(value);
  const deg = Math.floor(abs);
  const min = Math.round((abs - deg) * 60);
  // Handle the 59.5+ rounding edge case (carries to next degree).
  const adjDeg = min === 60 ? deg + 1 : deg;
  const adjMin = min === 60 ? 0 : min;
  return `${adjDeg}°${String(adjMin).padStart(2, "0")}′${hemi}`;
}