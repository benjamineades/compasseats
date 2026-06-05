/**
 * isOpenNow — determine if a venue is currently open in the city's local time.
 *
 * Reads the parsed `venue.hours` object (from schema: per-day arrays of
 * {open, close} time ranges in "HH:MM" 24h) and the city's IANA timezone
 * (e.g. "Asia/Tokyo"). Returns:
 *   - true  → venue is open right now in the city's local time
 *   - false → hours are known but the venue is closed at this moment
 *   - null  → hours are not populated for this venue (unknown)
 *
 * Handles overnight ranges (e.g. open 22:00, close 02:00) by treating the
 * close as the next day when close <= open. Multiple ranges per day (lunch
 * + dinner service) are supported.
 */

import type { Venue } from "./schema";

type TimeRange = { open: string; close: string };
const DAY_KEYS = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"] as const;

export function isOpenNow(venue: Venue, timezone?: string): boolean | null {
  const hours = venue.hours as
    | (Record<(typeof DAY_KEYS)[number], TimeRange[] | undefined> & { note?: string })
    | undefined;
  if (!hours) return null;

  const tz = timezone || "UTC";
  let weekdayIdx: number;
  let curMinutes: number;
  try {
    const parts = new Intl.DateTimeFormat("en-US", {
      timeZone: tz,
      hour12: false,
      weekday: "short",
      hour: "2-digit",
      minute: "2-digit",
    }).formatToParts(new Date());
    const wk = parts.find((p) => p.type === "weekday")?.value.toLowerCase();
    const hh = parts.find((p) => p.type === "hour")?.value;
    const mm = parts.find((p) => p.type === "minute")?.value;
    if (!wk || !hh || !mm) return null;
    weekdayIdx = DAY_KEYS.indexOf(wk.slice(0, 3) as (typeof DAY_KEYS)[number]);
    if (weekdayIdx === -1) return null;
    curMinutes = parseInt(hh, 10) * 60 + parseInt(mm, 10);
  } catch {
    return null;
  }

  // Check today's ranges (including overnight wraps starting today).
  const todayRanges = hours[DAY_KEYS[weekdayIdx]] ?? [];
  for (const r of todayRanges) {
    const open = toMinutes(r.open);
    let close = toMinutes(r.close);
    if (open == null || close == null) continue;
    if (close <= open) close += 24 * 60; // wraps into tomorrow
    if (curMinutes >= open && curMinutes < close) return true;
  }

  // Check yesterday's overnight range that may still cover us.
  const yIdx = (weekdayIdx + 6) % 7;
  const yRanges = hours[DAY_KEYS[yIdx]] ?? [];
  for (const r of yRanges) {
    const open = toMinutes(r.open);
    let close = toMinutes(r.close);
    if (open == null || close == null) continue;
    if (close <= open) {
      close += 24 * 60;
      const shifted = curMinutes + 24 * 60;
      if (shifted >= open && shifted < close) return true;
    }
  }

  return false;
}

function toMinutes(hhmm: string): number | null {
  const m = /^(\d{2}):(\d{2})$/.exec(hhmm);
  if (!m) return null;
  return parseInt(m[1], 10) * 60 + parseInt(m[2], 10);
}