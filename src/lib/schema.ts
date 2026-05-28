/**
 * CompassEats data schema.
 *
 * This is the contract between the Google Sheet and the rest of the codebase.
 * Every venue, city, and award flows through these types.
 *
 * If you change the Sheet structure, change this file. The build will fail
 * loudly if the Sheet drifts from the schema, which is the behavior we want.
 */

import { z } from "zod";

// -------------------------------------------------------------------------
// Primitives
// -------------------------------------------------------------------------

/** URL-safe slug: lowercase, hyphens, no leading/trailing dash. */
export const SlugSchema = z
  .string()
  .min(1)
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, "must be a url-safe slug");

/** ISO date (YYYY-MM-DD). Used for award years and last_verified. */
export const IsoDateSchema = z.string().regex(/^\d{4}-\d{2}-\d{2}$/);

export const VenueTypeSchema = z.enum(["restaurant", "bar"]);
export const VenueStatusSchema = z.enum(["active", "closed", "unverified"]);
export const PriceTierSchema = z.enum(["$", "$$", "$$$", "$$$$"]);

// -------------------------------------------------------------------------
// Awards
// -------------------------------------------------------------------------

/**
 * A single accolade. `source` matches a known award source slug (see
 * AWARD_SOURCES below); `category` is the source-specific designation
 * ("three-star", "no. 12", "best new restaurant", etc).
 */
export const AwardSchema = z.object({
  source: SlugSchema,
  year: z.number().int().min(1900).max(2100),
  category: z.string().min(1),
  rank: z.number().int().positive().optional(),
});
export type Award = z.infer<typeof AwardSchema>;

/**
 * Registry of award sources. Add new sources here as you expand the database.
 * The `slug` is what appears in /award/[slug] URLs and in AwardSchema.source.
 */
export const AWARD_SOURCES = [
  { slug: "michelin", name: "Michelin Guide", tier: "global" },
  { slug: "worlds-50-best-restaurants", name: "World's 50 Best Restaurants", tier: "global" },
  { slug: "worlds-50-best-bars", name: "World's 50 Best Bars", tier: "global" },
  { slug: "james-beard", name: "James Beard Awards", tier: "regional" },
  { slug: "best-chef-awards", name: "Best Chef Awards", tier: "global" },
  { slug: "spirited-awards", name: "Spirited Awards", tier: "global" },
  { slug: "pinnacle-guide", name: "The Pinnacle Guide", tier: "global" },
  { slug: "oad", name: "OAD Top Restaurants", tier: "global" },
  { slug: "101-best-steakhouses", name: "101 Best Steakhouses", tier: "global" },
  // Bar-coverage expansion — the differentiator. 50 Best regional + extended
  // bar lists. These reuse the same row shape as the global 50 Best Bars tab
  // (Year, Rank, Name, City, Country) so ingestion is uniform.
  { slug: "worlds-50-best-bars-51-100", name: "World's 50 Best Bars (51–100)", tier: "global" },
  { slug: "north-america-50-best-bars", name: "North America's 50 Best Bars", tier: "regional" },
  { slug: "asia-50-best-bars", name: "Asia's 50 Best Bars", tier: "regional" },
  { slug: "north-america-50-best-bars-51-100", name: "North America's 50 Best Bars (51–100)", tier: "regional" },
  { slug: "asia-50-best-bars-51-100", name: "Asia's 50 Best Bars (51–100)", tier: "regional" },
  // Roadmap additions (restaurants):
  { slug: "la-liste", name: "La Liste", tier: "global" },
  { slug: "gault-millau", name: "Gault & Millau", tier: "regional" },
  { slug: "tabelog", name: "Tabelog", tier: "regional" },
  { slug: "forbes-travel-guide", name: "Forbes Travel Guide", tier: "global" },
] as const;

export type AwardSource = (typeof AWARD_SOURCES)[number]["slug"];

const AWARD_SOURCE_SLUGS = new Set(AWARD_SOURCES.map((s) => s.slug));

// -------------------------------------------------------------------------
// Hours
// -------------------------------------------------------------------------

const TimeRangeSchema = z.object({
  open: z.string().regex(/^\d{2}:\d{2}$/), // "18:00"
  close: z.string().regex(/^\d{2}:\d{2}$/), // "23:30"
});

export const HoursSchema = z.object({
  mon: z.array(TimeRangeSchema).optional(),
  tue: z.array(TimeRangeSchema).optional(),
  wed: z.array(TimeRangeSchema).optional(),
  thu: z.array(TimeRangeSchema).optional(),
  fri: z.array(TimeRangeSchema).optional(),
  sat: z.array(TimeRangeSchema).optional(),
  sun: z.array(TimeRangeSchema).optional(),
  note: z.string().optional(), // "Closed for renovation through Sept"
});
export type Hours = z.infer<typeof HoursSchema>;

// -------------------------------------------------------------------------
// City
// -------------------------------------------------------------------------

export const CitySchema = z.object({
  slug: SlugSchema, // "tokyo"
  display: z.string().min(1), // "Tokyo"
  country: z.string().min(1), // "Japan"
  country_code: z.string().length(2).toUpperCase(), // "JP"
  region: z.string().optional(), // "Kantō"
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  blurb: z.string().optional(), // 1-2 sentence intro for /city pages
  hero_image_url: z.string().url().optional(),
  venue_count: z.number().int().nonnegative().default(0), // populated by sync
  timezone: z.string().optional(), // "Asia/Tokyo" — needed for "open today" pill
});
export type City = z.infer<typeof CitySchema>;

// -------------------------------------------------------------------------
// Venue
// -------------------------------------------------------------------------

export const VenueSchema = z.object({
  // Identity
  id: z.string().min(1), // stable, never reuse
  slug: SlugSchema, // unique within city
  name: z.string().min(1),

  // Geography
  city_slug: SlugSchema,
  city_display: z.string().min(1),
  country: z.string().min(1),
  neighborhood: z.string().optional(),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  address: z.string().min(1),

  // Classification
  type: VenueTypeSchema,
  cuisine_tags: z.array(z.string()).default([]), // ["sushi", "kaiseki"]
  price_tier: PriceTierSchema.optional(),

  // Contact
  phone: z.string().optional(),
  website: z.string().url().optional(),
  reservation_url: z.string().url().optional(),

  // Hours
  hours: HoursSchema.optional(),

  // Editorial — your voice goes here
  blurb_short: z.string().max(180).optional(), // 1 sentence for cards
  blurb_long: z.string().optional(), // 2-3 paragraphs for venue page

  // Awards — the moat
  awards: z.array(AwardSchema).default([]),

  // Media
  photo_url: z.string().url().optional(),

  // Maintenance
  status: VenueStatusSchema.default("active"),
  last_verified: IsoDateSchema.optional(),
})
.refine(
  (v) => v.awards.every((a) => AWARD_SOURCE_SLUGS.has(a.source as AwardSource)),
  { message: "venue has an award with an unknown source — add it to AWARD_SOURCES" }
);

export type Venue = z.infer<typeof VenueSchema>;

// -------------------------------------------------------------------------
// Slim index — what ships to the client for search
// -------------------------------------------------------------------------

/**
 * The full Venue payload is ~1-2kb. With 5,000 venues that's 5-10mb,
 * which is fine for build output but too much to ship to the client up front.
 *
 * The slim index keeps search snappy: ~150 bytes/venue, ~750kb total
 * (uncompressed) for the full database. Gzipped this is well under 200kb.
 */
export const VenueIndexEntrySchema = z.object({
  id: z.string(),
  slug: SlugSchema,
  name: z.string(),
  city_slug: SlugSchema,
  city_display: z.string(),
  country: z.string(),
  type: VenueTypeSchema,
  // Just the highest-prestige award for card display
  top_award: z
    .object({
      source: SlugSchema,
      category: z.string(),
      year: z.number().int(),
    })
    .optional(),
  award_count: z.number().int().nonnegative(),
});
export type VenueIndexEntry = z.infer<typeof VenueIndexEntrySchema>;

// -------------------------------------------------------------------------
// Sheet row → Venue (parsing helpers)
// -------------------------------------------------------------------------

/**
 * Raw row coming back from the Google Sheets API: every column is a string.
 * The sync script transforms these into VenueSchema-shaped objects before
 * validation.
 */
export const SheetRowSchema = z.object({
  id: z.string(),
  slug: z.string(),
  name: z.string(),
  city_slug: z.string(),
  city_display: z.string(),
  country: z.string(),
  neighborhood: z.string().optional().default(""),
  type: z.string(),
  lat: z.string(),
  lng: z.string(),
  address: z.string(),
  phone: z.string().optional().default(""),
  website: z.string().optional().default(""),
  reservation_url: z.string().optional().default(""),
  hours_json: z.string().optional().default(""),
  price_tier: z.string().optional().default(""),
  cuisine_tags: z.string().optional().default(""), // comma-separated
  blurb_short: z.string().optional().default(""),
  blurb_long: z.string().optional().default(""),
  awards_json: z.string().optional().default(""), // JSON array
  photo_url: z.string().optional().default(""),
  status: z.string().optional().default("active"),
  last_verified: z.string().optional().default(""),
});
export type SheetRow = z.infer<typeof SheetRowSchema>;
