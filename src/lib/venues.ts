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
 * Numeric prestige score for a single award entry. Higher = more prestigious.
 *
 * Combines three factors multiplicatively:
 *   - source weight: hand-tuned per-source importance (Michelin / 50 Best
 *     Restaurants lead; tier-based fallback for the rest)
 *   - strength (0–1): derived from numeric rank when present, otherwise
 *     mapped from the category text (Michelin star levels, Bib, knives,
 *     La Liste score, etc.) using the same rank formula
 *   - recency decay: recent awards score full, older ones taper off
 *     (floored at 0.25) so a current ranking outranks a decade-old one
 */
export function getAwardPrestige(award: {
  source: string;
  rank?: number;
  category?: string;
  year?: number;
}): number {
  const src = getAwardSource(award.source);
  if (!src) return 0;

  // Source weight.
  let weight: number;
  switch (src.slug) {
    case "michelin":
    case "worlds-50-best-restaurants":
      weight = 1.0;
      break;
    case "la-liste":
      weight = 0.9;
      break;
    case "james-beard":
      weight = 0.85;
      break;
    case "worlds-50-best-bars":
      weight = 0.8;
      break;
    case "best-chef-awards":
      weight = 0.7;
      break;
    case "oad":
    case "spirited-awards":
      weight = 0.6;
      break;
    case "pinnacle-guide":
      weight = 0.5;
      break;
    default:
      weight = src.tier === "global" ? 0.55 : 0.4;
  }

  // Strength: rank-or-category, normalized to (0, 1].
  const rankToStrength = (r: number) =>
    (201 - Math.min(Math.max(r, 1), 200)) / 200;

  let equivalentRank: number;
  if (typeof award.rank === "number" && award.rank > 0) {
    equivalentRank = award.rank;
  } else {
    const cat = (award.category ?? "").toLowerCase();
    const categoryMap: Array<[string, number]> = [
      ["three stars", 1],
      ["two stars", 8],
      ["one star", 30],
      ["bib", 160],
      ["selected", 200],
      ["3-knife", 60],
      ["2-knife", 110],
      ["1-knife", 150],
    ];
    const hit = categoryMap.find(([needle]) => cat.includes(needle));
    if (hit) {
      equivalentRank = hit[1];
    } else if (src.slug === "la-liste") {
      const m = (award.category ?? "").match(/^\s*(\d+(?:\.\d+)?)/);
      if (m) {
        const score = parseFloat(m[1]);
        equivalentRank = Math.max(1, (100 - score) * 8);
      } else {
        equivalentRank = 180;
      }
    } else {
      equivalentRank = 180;
    }
  }
  const strength = rankToStrength(equivalentRank);

  // Recency decay.
  let recency: number;
  if (typeof award.year !== "number") {
    recency = 1.0;
  } else {
    const age = new Date().getFullYear() - award.year;
    recency = age <= 1 ? 1.0 : Math.max(0.25, 1.0 - 0.12 * (age - 1));
  }

  return weight * strength * recency;
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
