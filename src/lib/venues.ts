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
  return CITIES.filter((c) => c.venue_count > 0).sort(
    (a, b) => b.venue_count - a.venue_count
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
