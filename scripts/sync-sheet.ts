/**
 * scripts/sync-sheet.ts
 *
 * Pulls the CompassEats venue Sheet, validates every row against the schema
 * in src/lib/schema.ts, and writes three artifacts:
 *
 *   data/venues.json         full Venue[] — used by venue & city pages
 *   data/cities.json         City[] with computed venue_count — used by /city pages and homepage
 *   data/venues-index.json   slim VenueIndexEntry[] — shipped to the client for search
 *
 * Run before every build:
 *   bun run scripts/sync-sheet.ts
 *
 * In CI this is a prebuild step. Locally you only need to run it when the
 * Sheet has changed.
 *
 * ENV:
 *   GOOGLE_SHEETS_API_KEY    public read-only key (Sheet must be link-shared)
 *   COMPASSEATS_SHEET_ID     spreadsheet id from the URL
 *   COMPASSEATS_VENUES_TAB   tab name, defaults to "venues"
 *   COMPASSEATS_CITIES_TAB   tab name, defaults to "cities"
 *
 * The Sheet must have a header row matching SheetRowSchema column names.
 */

import { writeFile, mkdir } from "node:fs/promises";
import { resolve } from "node:path";
import {
  AWARD_SOURCES,
  AwardSchema,
  CitySchema,
  HoursSchema,
  SheetRowSchema,
  VenueSchema,
  type Award,
  type City,
  type Venue,
  type VenueIndexEntry,
} from "../src/lib/schema";

// -------------------------------------------------------------------------
// Config
// -------------------------------------------------------------------------

const API_KEY = process.env.GOOGLE_SHEETS_API_KEY;
const SHEET_ID = process.env.COMPASSEATS_SHEET_ID;
const VENUES_TAB = process.env.COMPASSEATS_VENUES_TAB ?? "venues";
const CITIES_TAB = process.env.COMPASSEATS_CITIES_TAB ?? "cities";

if (!API_KEY || !SHEET_ID) {
  console.error(
    "Missing env: set GOOGLE_SHEETS_API_KEY and COMPASSEATS_SHEET_ID"
  );
  process.exit(1);
}

const DATA_DIR = resolve(process.cwd(), "data");

// Prestige order — used to pick a venue's "top award" for the slim index.
// Lower index = higher prestige. Tune to taste.
const AWARD_PRESTIGE: Record<string, number> = {
  michelin: 0,
  "worlds-50-best-restaurants": 1,
  "worlds-50-best-bars": 1,
  "best-chef-awards": 2,
  "la-liste": 3,
  "james-beard": 4,
  "spirited-awards": 4,
  "forbes-travel-guide": 5,
  "gault-millau": 5,
  tabelog: 6,
  oad: 6,
};

// -------------------------------------------------------------------------
// Sheet fetch
// -------------------------------------------------------------------------

interface SheetValuesResponse {
  values?: string[][];
}

async function fetchSheetTab(tab: string): Promise<Record<string, string>[]> {
  const url = `https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/${encodeURIComponent(
    tab
  )}?key=${API_KEY}`;

  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Sheet fetch failed for "${tab}": ${res.status} ${res.statusText}`);
  }
  const json = (await res.json()) as SheetValuesResponse;
  if (!json.values || json.values.length < 2) {
    throw new Error(`Sheet tab "${tab}" is empty or missing header row`);
  }

  const [headers, ...rows] = json.values;
  return rows.map((row) => {
    const obj: Record<string, string> = {};
    headers.forEach((h, i) => {
      obj[h.trim()] = (row[i] ?? "").trim();
    });
    return obj;
  });
}

// -------------------------------------------------------------------------
// Row → Venue transformation
// -------------------------------------------------------------------------

interface ValidationError {
  rowIndex: number;
  id: string;
  message: string;
}

function parseFloatOrNaN(s: string): number {
  const n = Number(s);
  return Number.isFinite(n) ? n : NaN;
}

function parseHours(raw: string) {
  if (!raw.trim()) return undefined;
  try {
    const parsed = JSON.parse(raw);
    return HoursSchema.parse(parsed);
  } catch (err) {
    throw new Error(`hours_json invalid: ${(err as Error).message}`);
  }
}

function parseAwards(raw: string): Award[] {
  if (!raw.trim()) return [];
  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) throw new Error("awards_json must be an array");
    return parsed.map((a) => AwardSchema.parse(a));
  } catch (err) {
    throw new Error(`awards_json invalid: ${(err as Error).message}`);
  }
}

function rowToVenue(raw: Record<string, string>): Venue {
  const row = SheetRowSchema.parse(raw);

  const cuisine_tags = row.cuisine_tags
    ? row.cuisine_tags.split(",").map((t) => t.trim()).filter(Boolean)
    : [];

  const candidate = {
    id: row.id,
    slug: row.slug.toLowerCase(),
    name: row.name,
    city_slug: row.city_slug.toLowerCase(),
    city_display: row.city_display,
    country: row.country,
    neighborhood: row.neighborhood || undefined,
    lat: parseFloatOrNaN(row.lat),
    lng: parseFloatOrNaN(row.lng),
    address: row.address,
    type: row.type.toLowerCase(),
    cuisine_tags,
    price_tier: row.price_tier || undefined,
    phone: row.phone || undefined,
    website: row.website || undefined,
    reservation_url: row.reservation_url || undefined,
    hours: parseHours(row.hours_json),
    blurb_short: row.blurb_short || undefined,
    blurb_long: row.blurb_long || undefined,
    awards: parseAwards(row.awards_json),
    photo_url: row.photo_url || undefined,
    status: (row.status || "active").toLowerCase(),
    last_verified: row.last_verified || undefined,
  };

  return VenueSchema.parse(candidate);
}

function rowToCity(raw: Record<string, string>): City {
  return CitySchema.parse({
    slug: (raw.slug ?? "").toLowerCase(),
    display: raw.display,
    country: raw.country,
    country_code: (raw.country_code ?? "").toUpperCase(),
    region: raw.region || undefined,
    lat: parseFloatOrNaN(raw.lat),
    lng: parseFloatOrNaN(raw.lng),
    blurb: raw.blurb || undefined,
    hero_image_url: raw.hero_image_url || undefined,
    timezone: raw.timezone || undefined,
    venue_count: 0, // computed below
  });
}

// -------------------------------------------------------------------------
// Index builder
// -------------------------------------------------------------------------

function pickTopAward(awards: Award[]) {
  if (awards.length === 0) return undefined;
  const sorted = [...awards].sort((a, b) => {
    const ap = AWARD_PRESTIGE[a.source] ?? 99;
    const bp = AWARD_PRESTIGE[b.source] ?? 99;
    if (ap !== bp) return ap - bp;
    return b.year - a.year; // newer wins ties
  });
  const top = sorted[0];
  return { source: top.source, category: top.category, year: top.year };
}

function buildIndex(venues: Venue[]): VenueIndexEntry[] {
  return venues
    .filter((v) => v.status === "active")
    .map((v) => ({
      id: v.id,
      slug: v.slug,
      name: v.name,
      city_slug: v.city_slug,
      city_display: v.city_display,
      country: v.country,
      type: v.type,
      top_award: pickTopAward(v.awards),
      award_count: v.awards.length,
    }));
}

// -------------------------------------------------------------------------
// Main
// -------------------------------------------------------------------------

async function main() {
  console.log("Fetching Sheet…");
  const [venueRows, cityRows] = await Promise.all([
    fetchSheetTab(VENUES_TAB),
    fetchSheetTab(CITIES_TAB),
  ]);
  console.log(`  ${venueRows.length} venue rows, ${cityRows.length} city rows`);

  const errors: ValidationError[] = [];
  const venues: Venue[] = [];

  venueRows.forEach((row, i) => {
    try {
      venues.push(rowToVenue(row));
    } catch (err) {
      errors.push({
        rowIndex: i + 2, // +2 = 1-indexed + header row
        id: row.id ?? "(no id)",
        message: (err as Error).message,
      });
    }
  });

  const cities: City[] = [];
  cityRows.forEach((row, i) => {
    try {
      cities.push(rowToCity(row));
    } catch (err) {
      errors.push({
        rowIndex: i + 2,
        id: row.slug ?? "(no slug)",
        message: `city: ${(err as Error).message}`,
      });
    }
  });

  // Duplicate detection
  const venueKeys = new Set<string>();
  const dupes: string[] = [];
  for (const v of venues) {
    const key = `${v.city_slug}/${v.slug}`;
    if (venueKeys.has(key)) dupes.push(key);
    venueKeys.add(key);
  }
  if (dupes.length) {
    console.error(`Duplicate venue keys: ${dupes.join(", ")}`);
    process.exit(1);
  }

  // City venue counts
  const counts = new Map<string, number>();
  for (const v of venues) {
    if (v.status === "active") {
      counts.set(v.city_slug, (counts.get(v.city_slug) ?? 0) + 1);
    }
  }
  for (const c of cities) c.venue_count = counts.get(c.slug) ?? 0;

  // Orphan check — venues pointing to a city not in the cities tab
  const citySlugs = new Set(cities.map((c) => c.slug));
  const orphans = venues
    .filter((v) => !citySlugs.has(v.city_slug))
    .map((v) => `${v.id} → ${v.city_slug}`);
  if (orphans.length) {
    console.warn(`Warning: ${orphans.length} venues reference unknown cities:`);
    orphans.slice(0, 10).forEach((o) => console.warn(`  ${o}`));
  }

  if (errors.length) {
    console.error(`\n${errors.length} validation errors:\n`);
    errors.slice(0, 25).forEach((e) => {
      console.error(`  row ${e.rowIndex} (${e.id}): ${e.message}`);
    });
    if (errors.length > 25) console.error(`  …and ${errors.length - 25} more`);
    process.exit(1);
  }

  const index = buildIndex(venues);

  await mkdir(DATA_DIR, { recursive: true });
  await Promise.all([
    writeFile(resolve(DATA_DIR, "venues.json"), JSON.stringify(venues, null, 2)),
    writeFile(resolve(DATA_DIR, "cities.json"), JSON.stringify(cities, null, 2)),
    writeFile(
      resolve(DATA_DIR, "venues-index.json"),
      // Index is compact — no pretty-printing
      JSON.stringify(index)
    ),
  ]);

  console.log("\nWrote:");
  console.log(`  data/venues.json         ${venues.length} venues`);
  console.log(`  data/cities.json         ${cities.length} cities`);
  console.log(`  data/venues-index.json   ${index.length} active venues`);
  console.log(`\nAward sources registered: ${AWARD_SOURCES.length}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
