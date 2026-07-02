/**
 * scripts/sync-sheet.ts
 *
 * Pulls the CompassEats venue Sheet, validates every row against the schema
 * in src/lib/schema.ts, and writes four artifacts:
 *
 *   data/venues.json         full Venue[] — used by venue & city pages
 *   data/cities.json         City[] with computed venue_count — used by /city pages and homepage
 *   data/venues-index.json   slim VenueIndexEntry[] — shipped to the client for search
 *   data/regions.json        Region[] — used by /region pages
 *
 * Run before every build:
 *   bun run scripts/sync-sheet.ts
 *
 * In CI this is a prebuild step. Locally you only need to run it when the
 * Sheet has changed.
 *
 * ENV:
 *   COMPASSEATS_SHEETS_KEY   public read-only key (Sheet must be link-shared)
 *   COMPASSEATS_SHEET_ID     spreadsheet id from the URL
 *   COMPASSEATS_VENUES_TAB   tab name, defaults to "venues"
 *   COMPASSEATS_CITIES_TAB   tab name, defaults to "cities"
 *   COMPASSEATS_REGIONS_TAB  tab name, defaults to "regions"
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
  RegionSchema,
  SheetRowSchema,
  VenueSchema,
  type Award,
  type City,
  type Region,
  type Venue,
  type VenueIndexEntry,
} from "../src/lib/schema";

// -------------------------------------------------------------------------
// Config
// -------------------------------------------------------------------------

/**
 * Thrown when the Sheet can't be reached or required env vars are missing.
 * Callers (CLI / Vite plugin) decide how to surface this — both treat it as
 * a loud warning, NOT a build failure, so the committed JSON stays in use.
 */
export class SyncSkipped extends Error {
  constructor(reason: string) {
    super(reason);
    this.name = "SyncSkipped";
  }
}

function logSkipBanner(reason: string) {
  const bar = "━".repeat(62);
  console.warn("\n" + bar);
  console.warn(" ⚠️  SYNC SKIPPED — using committed JSON, data may be stale ");
  console.warn(bar);
  console.warn("  Reason: " + reason);
  console.warn(bar + "\n");
}

/**
 * Thrown for problems in the Sheet data itself (duplicate keys, schema
 * validation failures). These must FAIL the build — they cannot be papered
 * over by falling back to committed JSON, because the committed JSON would
 * silently drift from the Sheet of record.
 */
export class DataValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "DataValidationError";
  }
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

async function fetchSheetTab(
  tab: string,
  sheetId: string,
  apiKey: string,
): Promise<Record<string, string>[]> {
  const url = `https://sheets.googleapis.com/v4/spreadsheets/${sheetId}/values/${encodeURIComponent(
    tab
  )}?key=${apiKey}&majorDimension=ROWS&valueRenderOption=UNFORMATTED_VALUE`;

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
    const padded = row.slice();
    while (padded.length < headers.length) padded.push("");

    const obj: Record<string, string> = {};
    headers.forEach((h, i) => {
      const cell = padded[i];
      obj[h.trim()] = (cell ?? "").toString().trim();
    });
    return obj;
  });
}

/**
 * Like fetchSheetTab, but tolerant: returns [] if the tab is missing or has
 * no data rows, instead of throwing. Used for optional side tabs such as
 * "curated_photos" and "regions" (which may not exist yet).
 */
async function fetchOptionalTab(
  tab: string,
  sheetId: string,
  apiKey: string,
): Promise<Record<string, string>[]> {
  try {
    return await fetchSheetTab(tab, sheetId, apiKey);
  } catch {
    return [];
  }
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

/**
 * Sheets returns date cells as serial numbers (days since 1899-12-30) when
 * we request UNFORMATTED_VALUE. Normalize to ISO YYYY-MM-DD so the schema's
 * regex passes. Pass-through for empty strings and already-ISO values.
 */
function normalizeSheetDate(raw: string): string {
  const s = (raw ?? "").toString().trim();
  if (!s) return "";
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  if (/^\d+(\.\d+)?$/.test(s)) {
    const serial = Number(s);
    const ms = Math.round(serial * 86400_000) + Date.UTC(1899, 11, 30);
    const d = new Date(ms);
    const y = d.getUTCFullYear();
    const m = String(d.getUTCMonth() + 1).padStart(2, "0");
    const day = String(d.getUTCDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
  }
  return s;
}

function normalizePriceTier(raw: string): string | undefined {
  const symbols = (raw ?? "").toString().match(/\p{Sc}/gu);
  const count = symbols ? symbols.length : 0;
  if (count === 0) return undefined;
  return "$".repeat(Math.min(count, 4));
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

function rowToVenue(
  raw: Record<string, string>,
  curatedById: Map<string, string>,
): Venue {
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
    price_tier: normalizePriceTier(row.price_tier),
    phone: row.phone || undefined,
    website: row.website || undefined,
    reservation_url: row.reservation_url || undefined,
    hours: parseHours(row.hours_json),
    blurb_short: row.blurb_short || undefined,
    blurb_long: row.blurb_long || undefined,
    awards: parseAwards(row.awards_json),
    photo_url: curatedById.get(row.id) || row.photo_url || undefined,
    status: (row.status || "active").toLowerCase(),
    last_verified: normalizeSheetDate(row.last_verified) || undefined,
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
// Row → Region transformation
// -------------------------------------------------------------------------

interface RegionCityEntry {
  slug: string;
  display: string;
  country: string;
  country_code: string;
  venue_count: number;
  lat: number;
  lng: number;
}

function rowToRegion(raw: Record<string, string>): Region {
  let cities: RegionCityEntry[] = [];
  if (raw.cities_json && raw.cities_json.trim()) {
    try {
      cities = JSON.parse(raw.cities_json);
    } catch {
      cities = [];
    }
  }

  return RegionSchema.parse({
    slug: (raw.slug ?? "").toLowerCase(),
    display: raw.display,
    country: raw.country || undefined,
    center_lat: parseFloatOrNaN(raw.center_lat),
    center_lng: parseFloatOrNaN(raw.center_lng),
    venue_count: Number(raw.venue_count) || 0,
    city_count: Number(raw.city_count) || 0,
    cities,
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
    return b.year - a.year;
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

let _syncPromise: Promise<void> | null = null;
export function runSync(): Promise<void> {
  if (!_syncPromise) _syncPromise = _runSyncOnce();
  return _syncPromise;
}

async function _runSyncOnce(): Promise<void> {
  const API_KEY =
    process.env.SHEETS_API_KEY || process.env.GOOGLE_SHEETS_API_KEY;
  const SHEET_ID = process.env.COMPASSEATS_SHEET_ID;
  const VENUES_TAB = process.env.COMPASSEATS_VENUES_TAB ?? "venues";
  const CITIES_TAB = process.env.COMPASSEATS_CITIES_TAB ?? "cities";
  const CURATED_TAB =
    process.env.COMPASSEATS_CURATED_TAB ?? "curated_photos";
  const REGIONS_TAB =
    process.env.COMPASSEATS_REGIONS_TAB ?? "regions";

  if (!API_KEY || !SHEET_ID) {
    throw new SyncSkipped(
      "Missing SHEETS_API_KEY (or GOOGLE_SHEETS_API_KEY) or COMPASSEATS_SHEET_ID",
    );
  }

  console.log("Fetching Sheet…");
  let venueRows: Record<string, string>[];
  let cityRows: Record<string, string>[];
  try {
    [venueRows, cityRows] = await Promise.all([
      fetchSheetTab(VENUES_TAB, SHEET_ID, API_KEY),
      fetchSheetTab(CITIES_TAB, SHEET_ID, API_KEY),
    ]);
  } catch (err) {
    console.error((err as Error).message);
    throw new SyncSkipped("Sheet unreachable or fetch failed — see error above");
  }
  console.log(`  ${venueRows.length} venue rows, ${cityRows.length} city rows`);

  // Curated photos (id → curated_photo_url) — tolerant optional tab
  const curatedRows = await fetchOptionalTab(CURATED_TAB, SHEET_ID, API_KEY);
  const curatedById = new Map<string, string>();
  for (const r of curatedRows) {
    const id = (r.id ?? "").trim();
    const url = (r.curated_photo_url ?? "").trim();
    if (id && url) curatedById.set(id, url);
  }
  console.log(`  ${curatedById.size} curated photo(s)`);

  // Regions — tolerant optional tab (missing tab = no regions written)
  const regionRows = await fetchOptionalTab(REGIONS_TAB, SHEET_ID, API_KEY);
  console.log(`  ${regionRows.length} region row(s)`);

  const errors: ValidationError[] = [];
  const venues: Venue[] = [];

  venueRows.forEach((row, i) => {
    try {
      venues.push(rowToVenue(row, curatedById));
    } catch (err) {
      errors.push({
        rowIndex: i + 2,
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

  // Parse regions — non-fatal: a bad region row is skipped with a warning
  const regions: Region[] = [];
  regionRows.forEach((row, i) => {
    try {
      regions.push(rowToRegion(row));
    } catch (err) {
      console.warn(`  region row ${i + 2} skipped: ${(err as Error).message}`);
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
    throw new DataValidationError(`Duplicate venue keys: ${dupes.join(", ")}`);
  }

  // City venue counts
  const counts = new Map<string, number>();
  for (const v of venues) {
    if (v.status === "active") {
      counts.set(v.city_slug, (counts.get(v.city_slug) ?? 0) + 1);
    }
  }
  for (const c of cities) c.venue_count = counts.get(c.slug) ?? 0;

  // Orphan check
  const citySlugs = new Set(cities.map((c) => c.slug));
  const orphansByCity = new Map<string, string[]>();
  for (const v of venues) {
    if (v.status !== "active") continue;
    if (citySlugs.has(v.city_slug)) continue;
    if (!orphansByCity.has(v.city_slug)) orphansByCity.set(v.city_slug, []);
    orphansByCity.get(v.city_slug)!.push(`${v.id} (${v.name})`);
  }
  if (orphansByCity.size) {
    console.error(
      `\n❌ ${orphansByCity.size} city_slug value(s) used by venues are missing from the cities tab:\n`,
    );
    for (const [slug, vs] of orphansByCity) {
      console.error(`  ${slug} — ${vs.length} venue(s)`);
      vs.slice(0, 5).forEach((s) => console.error(`    ${s}`));
      if (vs.length > 5) console.error(`    …and ${vs.length - 5} more`);
    }
    console.error(
      "\nFix: add a matching row to the cities tab, or correct the city_slug on the venue row(s).\n",
    );
    throw new DataValidationError(
      `${orphansByCity.size} orphan city_slug(s): ${[...orphansByCity.keys()].join(", ")}`,
    );
  }

  if (errors.length) {
    console.error(`\n${errors.length} validation errors:\n`);
    errors.slice(0, 25).forEach((e) => {
      console.error(`  row ${e.rowIndex} (${e.id}): ${e.message}`);
    });
    if (errors.length > 25) console.error(`  …and ${errors.length - 25} more`);
    throw new DataValidationError(`${errors.length} validation errors — see details above`);
  }

  const index = buildIndex(venues);

  await mkdir(DATA_DIR, { recursive: true });

  const writeOps: Promise<void>[] = [
    writeFile(resolve(DATA_DIR, "venues.json"), JSON.stringify(venues, null, 2)),
    writeFile(resolve(DATA_DIR, "cities.json"), JSON.stringify(cities, null, 2)),
    writeFile(
      resolve(DATA_DIR, "venues-index.json"),
      JSON.stringify(index)
    ),
  ];

  // Only write regions.json when the tab was present and produced rows
  if (regions.length > 0) {
    writeOps.push(
      writeFile(resolve(DATA_DIR, "regions.json"), JSON.stringify(regions, null, 2))
    );
  }

  await Promise.all(writeOps);

  // Auditable summary
  const sample = venues.slice(0, 5).map((v) => ({
    slug: v.slug,
    city_slug: v.city_slug,
    name: v.name,
    blurb_long_head: (v.blurb_long ?? "").slice(0, 80),
  }));
  const mirazur = venues.find((v) => v.slug === "restaurant-mirazur");
  const bernardin = venues.find((v) => v.slug === "le-bernardin");
  const report = {
    generated_at: new Date().toISOString(),
    venue_count: venues.length,
    city_count: cities.length,
    region_count: regions.length,
    active_venue_count: index.length,
    sample,
    spot_checks: {
      "restaurant-mirazur": mirazur
        ? { found: true, blurb_long_head: (mirazur.blurb_long ?? "").slice(0, 80) }
        : { found: false },
      "le-bernardin": bernardin
        ? { found: true, blurb_long_head: (bernardin.blurb_long ?? "").slice(0, 80) }
        : { found: false },
    },
  };
  await writeFile(
    resolve(DATA_DIR, "sync-report.json"),
    JSON.stringify(report, null, 2),
  );

  console.log("\nWrote:");
  console.log(`  data/venues.json         ${venues.length} venues`);
  console.log(`  data/cities.json         ${cities.length} cities`);
  console.log(`  data/venues-index.json   ${index.length} active venues`);
  if (regions.length > 0) {
    console.log(`  data/regions.json        ${regions.length} regions`);
  } else {
    console.log(`  data/regions.json        (skipped — no "regions" tab in Sheet yet)`);
  }
  console.log(`  data/sync-report.json    summary + spot checks`);
  console.log(`\nAward sources registered: ${AWARD_SOURCES.length}`);
}

// CLI entrypoint
const invokedDirectly =
  typeof process !== "undefined" &&
  !!process.argv[1] &&
  /sync-sheet\.ts$/.test(process.argv[1]);

if (invokedDirectly) {
  runSync().catch((err) => {
    if (err instanceof DataValidationError) {
      console.error("\n❌ DATA VALIDATION FAILED — fix the Sheet data before rebuilding.");
      console.error(`   ${err.message}\n`);
      process.exit(1);
    }
    if (err instanceof SyncSkipped) {
      logSkipBanner(err.message);
      process.exit(0);
    }
    console.error(err);
    logSkipBanner("Unexpected error — see above");
    process.exit(0);
  });
}
