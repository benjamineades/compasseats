/**
 * src/lib/venues.ts
 *
 * Typed data access for the build-time JSON artifacts. Every route reads
 * through these helpers, never directly from the JSON, so the data shape
 * can evolve without touching every page.
 *
 * These imports are evaluated at module load time. With 5,000 venues this
 * is ~5-10mb in memory per server worker, which is fine for prerender but
 * something to watch as the database grows past ~20k.
 */

import venuesData from "../../data/venues.json";
import citiesData from "../../data/cities.json";
import indexData from "../../data/venues-index.json";
import {
  AWARD_SOURCES,
  type AwardSource,
  type City,
  type Venue,
  type VenueIndexEntry,
} from "./schema";

// Type assertion: JSON imports come back as `any`. We trust the build
// script's validation rather than re-running Zod at runtime.
const VENUES = venuesData as unknown as Venue[];
const CITIES = citiesData as unknown as City[];
const INDEX = indexData as unknown as VenueIndexEntry[];

// -------------------------------------------------------------------------
// Indexes (built once on import)
// -------------------------------------------------------------------------

const venueByKey = new Map<string, Venue>();
for (const v of VENUES) {
  venueByKey.set(`${v.city_slug}/${v.slug}`, v);
}

const cityBySlug = new Map<string, City>();
for (const c of CITIES) {
  cityBySlug.set(c.slug, c);
}

const venuesByCity = new Map<string, Venue[]>();
for (const v of VENUES) {
  if (!venuesByCity.has(v.city_slug)) venuesByCity.set(v.city_slug, []);
  venuesByCity.get(v.city_slug)!.push(v);
}

const venuesByAward = new Map<AwardSource, Venue[]>();
for (const v of VENUES) {
  for (const a of v.awards) {
    const src = a.source as AwardSource;
    if (!venuesByAward.has(src)) venuesByAward.set(src, []);
    venuesByAward.get(src)!.push(v);
  }
}

// Active-venue counts by city_slug, derived at module load from the venue
// join — the source of truth, independent of any stored `City.venue_count`
// (which can drift if the sync hasn't run after a venue add/remove).
const activeVenueCountByCity = new Map<string, number>();
for (const v of VENUES) {
  if (v.status !== "active") continue;
  activeVenueCountByCity.set(
    v.city_slug,
    (activeVenueCountByCity.get(v.city_slug) ?? 0) + 1,
  );
}

// -------------------------------------------------------------------------
// Cities
// -------------------------------------------------------------------------

export function getAllCities(): City[] {
  return CITIES;
}

export function getCity(slug: string): City | undefined {
  return cityBySlug.get(slug);
}

export function getCitiesWithVenues(): City[] {
  return CITIES.filter(
    (c) => (activeVenueCountByCity.get(c.slug) ?? 0) > 0,
  ).sort(
    (a, b) =>
      (activeVenueCountByCity.get(b.slug) ?? 0) -
      (activeVenueCountByCity.get(a.slug) ?? 0),
  );
}

// -------------------------------------------------------------------------
// Venues
// -------------------------------------------------------------------------

export function getVenue(citySlug: string, venueSlug: string): Venue | undefined {
  return venueByKey.get(`${citySlug}/${venueSlug}`);
}

export function getVenuesByCity(citySlug: string): Venue[] {
  const list = venuesByCity.get(citySlug) ?? [];
  return list.filter((v) => v.status === "active");
}

export function getAllVenuePaths(): { citySlug: string; venueSlug: string }[] {
  return VENUES.filter((v) => v.status === "active").map((v) => ({
    citySlug: v.city_slug,
    venueSlug: v.slug,
  }));
}

/**
 * All active venues. Mirrors `getAllVenuePaths`'s status filter so callers
 * (sitemap generator, etc.) can derive per-venue fields like `last_verified`.
 */
export function getAllVenues(): Venue[] {
  return VENUES.filter((v) => v.status === "active");
}

// -------------------------------------------------------------------------
// Awards
// -------------------------------------------------------------------------

export function getAwardSource(slug: string) {
  return AWARD_SOURCES.find((s) => s.slug === slug);
}

export function getAllAwardSources() {
  return AWARD_SOURCES;
}

export function getVenuesByAward(source: AwardSource): Venue[] {
  return (venuesByAward.get(source) ?? []).filter((v) => v.status === "active");
}

// -------------------------------------------------------------------------
// Award prestige scoring
// -------------------------------------------------------------------------

/**
 * Explicit-tier prestige scoring. Restaurants and bars are scored on
 * separate scales so their points are comparable within each cohort.
 *
 * - Status credentials (michelin, la-liste, pinnacle-guide) are awarded
 *   "until withdrawn" — they bypass the rolling window and the recency
 *   multiplier.
 * - Annual ranked lists (50 Best, OAD, James Beard, Spirited, etc.) only
 *   count if award.year is within PRESTIGE_WINDOW_YEARS, and decay with age.
 */
const PRESTIGE_WINDOW_YEARS = 5;
const CURRENT_YEAR = new Date().getFullYear();
const STATUS_SOURCES = new Set(["michelin", "la-liste", "pinnacle-guide"]);

function recencyMultiplier(year: number | undefined): number {
  if (typeof year !== "number") return 1.0;
  const age = CURRENT_YEAR - year;
  if (age <= 1) return 1.0;
  return Math.max(0.5, 1 - 0.08 * (age - 1));
}

function scoreRestaurantAward(award: {
  source: string;
  rank?: number;
  category?: string;
}): number {
  const rank = award.rank;
  const cat = (award.category ?? "").toLowerCase();
  switch (award.source) {
    case "worlds-50-best-restaurants":
    case "worlds-50-best-restaurants-51-100": {
      if (typeof rank !== "number") return 0;
      if (rank === 1) return 95;
      if (rank <= 10) return 90 - rank;
      if (rank <= 50) return 74 - rank * 0.45;
      return 0;
    }
    case "michelin": {
      if (cat.includes("three star")) return 85;
      if (cat.includes("two star")) return 68;
      if (cat.includes("one star")) return 50;
      if (cat.includes("bib")) return 18;
      return 0;
    }
    case "la-liste": {
      const m = (award.category ?? "").match(/(\d+(?:\.\d+)?)/);
      if (!m) return 0;
      const score = parseFloat(m[1]);
      if (score >= 99.5) return 83;
      if (score >= 99) return 67;
      if (score >= 97) return 52;
      if (score >= 90) return 34;
      return score * 0.2;
    }
    case "latin-america-50-best-restaurants":
    case "asia-50-best-restaurants":
    case "mena-50-best-restaurants":
    case "north-america-50-best-restaurants":
    case "africa-50-best-restaurants":
    case "asia-50-best-restaurants-51-100": {
      if (typeof rank !== "number") return 0;
      if (rank <= 10) return 60 - rank;
      if (rank <= 50) return 44 - rank * 0.3;
      return 0;
    }
    case "james-beard": {
      if (cat.includes("outstanding restaurant") || cat.includes("outstanding chef")) return 58;
      if (cat.startsWith("best chef") || cat.includes("best new")) return 42;
      if (cat.includes("america's classics") || cat.includes("americas classics")) return 28;
      return 22;
    }
    case "best-chef-awards": {
      if (cat.includes("3-knife")) return 30;
      if (cat.includes("2-knife")) return 20;
      if (cat.includes("1-knife")) return 12;
      return 0;
    }
    case "oad": {
      if (typeof rank !== "number") return 5;
      if (rank <= 50) return 38 - rank * 0.3;
      if (rank <= 200) return 22 - rank * 0.05;
      return 5;
    }
    case "101-best-steakhouses": {
      if (typeof rank !== "number") return 5;
      return Math.max(5, 30 - rank * 0.2);
    }
    default:
      return 0;
  }
}

function scoreBarAward(award: {
  source: string;
  rank?: number;
  category?: string;
}): number {
  const rank = award.rank;
  const cat = (award.category ?? "").toLowerCase();
  switch (award.source) {
    case "worlds-50-best-bars":
    case "worlds-50-best-bars-51-100": {
      if (typeof rank !== "number") return 0;
      if (rank === 1) return 100;
      if (rank <= 10) return 92 - rank;
      if (rank <= 25) return 84 - rank * 0.6;
      if (rank <= 50) return 70 - rank * 0.5;
      if (rank <= 100) return 46 - rank * 0.18;
      return 0;
    }
    case "pinnacle-guide": {
      if (typeof rank === "number") {
        if (rank <= 3) return 84;
        if (rank <= 10) return 66;
      }
      return 50;
    }
    case "spirited-awards": {
      if (cat.includes("world's best bar") && !cat.includes("international")) return 88;
      if (cat.includes("best international") || cat.startsWith("world's best")) return 60;
      if (cat.includes("best new international")) return 54;
      if (cat.includes("u.s.") || cat.includes("american")) return 38;
      return 34;
    }
    case "north-america-50-best-bars":
    case "asia-50-best-bars": {
      if (typeof rank !== "number") return 0;
      if (rank <= 25) return 60 - rank * 0.5;
      return 42 - rank * 0.3;
    }
    case "north-america-50-best-bars-51-100":
    case "asia-50-best-bars-51-100": {
      if (typeof rank !== "number") return 0;
      return Math.max(8, 38 - rank * 0.2);
    }
    default:
      return 0;
  }
}

export function getAwardPrestige(
  award: {
    source: string;
    rank?: number;
    category?: string;
    year?: number;
  },
  isBar: boolean = false,
): number {
  // 5-year window for non-status (annual) awards.
  const isStatus = STATUS_SOURCES.has(award.source);
  if (!isStatus && typeof award.year === "number") {
    if (CURRENT_YEAR - award.year > PRESTIGE_WINDOW_YEARS) return 0;
  }

  const base = isBar ? scoreBarAward(award) : scoreRestaurantAward(award);
  if (base <= 0) return 0;

  // Status credentials don't decay.
  if (isStatus) return base;
  return base * recencyMultiplier(award.year);
}

/**
 * Aggregate prestige for a venue. Each award source contributes only
 * its single highest-prestige entry, so a long ranking history on the
 * same list cannot outscore a stronger credential elsewhere.
 */
export function getVenuePrestige(venue: {
  awards: Array<{ source: string; rank?: number; category?: string; year?: number }>;
}): number {
  const bestBySource = new Map<string, number>();
  for (const a of venue.awards) {
    const p = getAwardPrestige(a);
    const cur = bestBySource.get(a.source) ?? 0;
    if (p > cur) bestBySource.set(a.source, p);
  }
  let score = 0;
  for (const v of bestBySource.values()) score += v;
  return score;
}

// -------------------------------------------------------------------------
// Related-venue suggestions (for "Other charted spots in [city]")
// -------------------------------------------------------------------------

export function getRelatedVenues(venue: Venue, limit = 4): Venue[] {
  const sameCity = getVenuesByCity(venue.city_slug).filter((v) => v.id !== venue.id);

  // Prefer same type + overlapping award sources, then same type, then anything
  const venueAwardSources = new Set(venue.awards.map((a) => a.source));
  const scored = sameCity.map((v) => {
    let score = 0;
    if (v.type === venue.type) score += 2;
    const overlap = v.awards.filter((a) => venueAwardSources.has(a.source)).length;
    score += overlap;
    return { v, score };
  });

  return scored
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((s) => s.v);
}

// -------------------------------------------------------------------------
// Client-side search index
// -------------------------------------------------------------------------

export function getSearchIndex(): VenueIndexEntry[] {
  return INDEX;
}
