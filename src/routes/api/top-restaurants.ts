import "@tanstack/react-start";
import { createFileRoute } from "@tanstack/react-router";
import { generateObject } from "ai";
import { z } from "zod";
import { createLovableAiGatewayProvider } from "@/lib/ai-gateway";

const bodySchema = z.object({
  city: z.string().trim().min(1).max(100),
});

const numericValue = z.coerce.number().finite();
const integerValue = z.coerce.number().int();
const validUrlTypes = ["website", "instagram", "facebook"] as const;

const normalizeUrlType = (url?: string, urlType?: string | null) => {
  if (validUrlTypes.includes(urlType as (typeof validUrlTypes)[number])) {
    return urlType as (typeof validUrlTypes)[number];
  }
  if (!url) return undefined;
  if (/instagram\.com/i.test(url)) return "instagram";
  if (/facebook\.com|fb\.com/i.test(url)) return "facebook";
  return "website";
};

const resultsSchema = z.object({
  city: z.string(),
  country: z.string(),
  lat: numericValue,
  lng: numericValue,
  venues: z
    .array(
      z.object({
        name: z.string(),
        category: z.enum(["restaurant", "cocktail bar"]),
        cuisine: z.string().nullish(),
        priceRange: z.string().nullish(),
        description: z.string().nullish(),
        neighborhood: z.string().nullish(),
        lat: numericValue,
        lng: numericValue,
        url: z.string().nullish(),
        urlType: z.string().nullish(),
        michelinStars: integerValue.nullish(),
        michelinGreenStar: z.boolean().nullish(),
        bibGourmand: z.boolean().nullish(),
        worldsBest50Restaurants: z
          .object({ rank: integerValue, year: integerValue })
          .nullish(),
        worldsBest50Bars: z
          .object({ rank: integerValue, year: integerValue })
          .nullish(),
        spiritedAward: z
          .object({ name: z.string(), year: integerValue })
          .nullish(),
        chef: z.string().nullish(),
        signatureDish: z.string().nullish(),
        accoladeOverview: z.string().nullish(),
        whyThisPick: z.string().nullish(),
        reservationUrl: z.string().nullish(),
        reservationPlatform: z.string().nullish(),
        hours: z.string().nullish(),
      }),
    )
    .min(0),
});

const sanitizeAiJson = (text: string) => {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) return null;

  return text
    .slice(start, end + 1)
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, " ");
};

const MAX_RADIUS_MILES = 30;
const haversineMiles = (
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
) => {
  const R = 3958.8;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
};

export const Route = createFileRoute("/api/top-restaurants")({
  server: {
    handlers: {
      POST: async ({ request }: { request: Request }) => {
        let parsed;
        try {
          const json = await request.json();
          parsed = bodySchema.parse(json);
        } catch {
          return Response.json({ error: "Invalid request" }, { status: 400 });
        }

        const apiKey = process.env.LOVABLE_API_KEY;
        if (!apiKey) {
          return Response.json(
            { error: "AI is not configured." },
            { status: 500 },
          );
        }

        const gateway = createLovableAiGatewayProvider(apiKey);
        // Flash is ~3–5x faster than Pro and sufficient for this task.
        const model = gateway("google/gemini-2.5-flash");

        const now = new Date();
        const currentYear = now.getUTCFullYear();
        const currentMonth = now.toLocaleString("en-US", { month: "long", timeZone: "UTC" });
        const minAccoladeYear = currentYear - 2;

        try {
          const { object } = await generateObject({
            model,
            schema: resultsSchema,
            experimental_repairText: async ({ text }) => sanitizeAiJson(text),
          prompt: `Today is ${currentMonth} ${currentYear}. List up to 20 top restaurants AND up to 20 top cocktail bars in or around ${parsed.city} (up to 40 venues total).

GEOGRAPHIC RADIUS (hard constraint): Every venue MUST be located within a 30-mile (≈48 km) radius of ${parsed.city}'s city center. Measure straight-line distance from the city-center lat/lng you return. Exclude any venue outside that radius even if it is famous or nearby — do NOT include venues in adjacent cities/metros beyond 30 miles. If a venue is exactly on the boundary and you aren't sure, OMIT it. Return fewer than 20 per category if there aren't enough qualifying venues within the radius — a short, in-radius list is strictly better than padding with out-of-range venues.

RECENCY IS MANDATORY. The official accolade lists you must use:
  • World's 50 Best Restaurants — the edition published in ${currentYear} (or, if not yet announced as of ${currentMonth} ${currentYear}, the ${currentYear - 1} edition). NEVER cite an older edition when a newer one exists.
  • World's 50 Best Bars — same rule: most recent edition only.
  • Michelin Guide — the CURRENT edition for ${parsed.city}'s guide region (typically published late ${currentYear - 1} or in ${currentYear}). Only include stars/Bib/Green Star that appear in the current edition; do not carry forward awards a venue has since lost.
  • Tales of the Cocktail Spirited Awards — most recent ceremony only (${currentYear} if held, else ${currentYear - 1}).
  • World's Best Discovery — current live listing.
Do NOT include any accolade with year < ${minAccoladeYear} unless that exact year is still the most recent edition of that list. If you are not confident the accolade reflects the latest edition, OMIT the accolade field entirely rather than guess. Fabricated or outdated years are worse than no badge.

ANTI-HALLUCINATION RULE (overrides the count target below): Every venue you return MUST be a real, currently-operating business that you are confident exists at the address you'd find on Google Maps / Google Business today. Do NOT invent venues, do NOT guess plausible-sounding names, do NOT include venues you only "think" might exist, do NOT include venues you remember but aren't sure are still open. If you cannot independently recall a venue from multiple credible sources (its own coverage, accolade lists, well-known press, or established review platforms) AND have no reason to believe it has closed, OMIT IT. A shorter, fully verifiable list is STRICTLY BETTER than a padded list with fabricated or defunct venues. Specifically exclude any venue that: (a) you cannot place at a specific real address, (b) Google Maps would mark "Permanently closed" / "Temporarily closed", (c) has clearly closed, moved away from ${parsed.city}, rebranded under a different name, or whose chef/team has publicly departed and the venue ceased operating, (d) feels like a generic combination of city + cuisine rather than a venue you actually know.

COUNT TARGET: Aim for up to 20 restaurants AND up to 20 cocktail bars when you can do so WITHOUT violating the anti-hallucination rule above AND while staying within the 30-mile radius. If verified in-radius supply is thinner — e.g. a small city, remote area, or a city you have limited reliable knowledge of — return however many you ARE confident about (could be 1, 5, 10, 15). NEVER fabricate or stretch the radius to reach 20. Fill remaining confident in-radius slots first from the accolade tiers below, then from venues with strong, verifiable Yelp / Trip Advisor / Tabelog presence you actually recognize.

OVERALL RULE: Within EVERY tier below, always prefer the MOST RECENT accolade year. When two venues are in the same tier, the one whose qualifying accolade was awarded in a more recent year ranks higher. Use rank as a secondary tiebreaker only when the accolade years are equal. Never use an older year's ranking when a more recent year exists.

RANKING PRIORITY — RESTAURANTS (apply in this strict order, fill up to 20 in-radius slots top-down):
  1. Venues on the MOST CURRENT World's 50 Best Restaurants list (top 50 first, then extended 51–100).
  2. Then venues in the current Michelin Guide, ordered 3 stars → 2 stars → 1 star → Green Star → Bib Gourmand.
  3. Then venues on the current World's Best Discovery (restaurants) list.
  4. ONLY if fewer than 20 restaurants qualify above, fill remaining slots with the highest-rated restaurants from Yelp, then Trip Advisor. If "${parsed.city}" is OUTSIDE the United States, prioritize Trip Advisor BEFORE Yelp.

RANKING PRIORITY — COCKTAIL BARS (apply in this strict order, fill up to 20 in-radius slots top-down):
  1. Venues on the MOST CURRENT World's 50 Best Bars list (top 50 first, then extended 51–100).
  2. Then venues that have won a Spirited Award in the most recent ceremony (then prior ceremonies).
  3. Then venues on the current World's Best Discovery (bars) list.
  4. ONLY if fewer than 20 bars qualify above, fill remaining slots with the highest-rated cocktail bars from Yelp, then Trip Advisor. If "${parsed.city}" is OUTSIDE the United States, prioritize Trip Advisor BEFORE Yelp.

Return restaurants in priority order first, then cocktail bars in priority order (up to 20 each, fewer if needed to stay truthful). Do not use Google Maps for ranking, popularity, or selection. Use Google Maps ONLY for three things: (1) confirm each venue currently exists as an active Google Business listing — if you cannot place it on Google Maps with confidence, drop it, (2) exclude any venue marked "Permanently closed" / "Temporarily closed" or otherwise known to have closed, and (3) source each venue's CURRENT precise latitude and longitude from its present-day Google Maps listing — if a venue has moved, use its current address coordinates, not historical ones.

Return JSON with: city (proper name), country, lat/lng (city center coordinates), and venues (array of 40: 20 restaurants then 20 cocktail bars). Each venue: name, category ("restaurant" or "cocktail bar"), cuisine (for restaurants: cuisine type; for bars: style/specialty like speakeasy, tiki, classic), priceRange ("$", "$$", "$$$" or "$$$$"), description (see DESCRIPTION RULES), neighborhood (optional), lat/lng (precise current venue coordinates), url (the venue's official website if it has one; otherwise the Instagram profile URL; otherwise the Facebook page URL; omit only if none exist), urlType ("website" | "instagram" | "facebook" matching the url provided).

DESCRIPTION RULES — RESTAURANTS: One vivid sentence, max 35 words. ALSO set these two fields when known: chef (current head/executive chef's full name — only if you're confident they are still at the venue; omit otherwise) and signatureDish (the dish the restaurant is most known for, named specifically, e.g. "smoked eel tartlet"; omit if not clearly known). For COCKTAIL BARS: one vivid sentence (max 25 words); do not set chef or signatureDish.

ACCOLADE OVERVIEW (accoladeOverview field) — REQUIRED FALLBACK:
  • For RESTAURANTS: Set accoladeOverview ONLY when BOTH chef and signatureDish are unknown. Write 1–2 sentences (max 45 words) that explicitly reference what the Michelin Guide and/or World's 50 Best Restaurants say about this place — start the sentence with phrasing like "The Michelin Guide notes…", "World's 50 Best describes…", or "Per the Michelin Guide and World's 50 Best…". Summarize cooking style, what critics highlight, atmosphere. If neither guide covers this venue, omit the field.
  • For COCKTAIL BARS: ALWAYS set accoladeOverview when you have any knowledge of the bar from World's 50 Best Bars, Tales of the Cocktail Spirited Awards, or other established bar guides. 1–2 sentences (max 45 words), explicitly referencing the source — e.g. "World's 50 Best Bars highlights…", "A Spirited Award winner known for…". Summarize the bar's program, signature drinks, and atmosphere. Omit only if no such coverage exists.
  • Never fabricate. If unsure, omit.

WHY THIS PICK (whyThisPick field) — REQUIRED for EVERY venue:
  Always populate whyThisPick with ONE concise sentence (max 25 words) explaining the single strongest reason this venue earned its spot on this list. Be specific: cite the exact accolade ("Holds 3 Michelin stars and ranks #4 on World's 50 Best 2024"), a defining strength ("Pioneered Nordic fermentation and still sets the regional benchmark"), or — for fallback Yelp/Trip Advisor picks — why it's the top-rated choice ("Highest-rated izakaya on Tabelog with 4.6 stars across 2,000+ reviews"). Never generic ("great food"). Never repeat the description verbatim.

  RESERVATIONS (reservationUrl + reservationPlatform) — set whenever the venue takes reservations through an online booking platform:
    • Applies to BOTH restaurants AND cocktail bars. Many top cocktail bars (especially World's 50 Best Bars listees) take reservations via Tock, Resy, or SevenRooms — include those.
    • reservationUrl: the venue's preferred public booking link. Prefer dedicated reservation platforms over the venue's own site. Priority order: Tock, Resy, OpenTable, SevenRooms, Seven Lamps, Yelp Reservations, Bookatable, TheFork (LaFourchette), Quandoo, Chope, TableCheck, Pocket Concierge, Tabelog reservations, Dorsia. If none of those exist, use a "Reservations" / "Book a table" page on the venue's official website. Must be a fully-qualified https URL.
    • reservationPlatform: the platform name matching the URL — e.g. "Tock", "Resy", "OpenTable", "SevenRooms", "Seven Lamps", "TheFork", "Tabelog", "Website". Capitalize properly.
    • Omit BOTH fields if the venue is walk-in only, only takes phone reservations, or you are not confident a working booking link exists. Never guess a URL.

  BUSINESS HOURS (hours field) — REQUIRED for EVERY venue (restaurants AND cocktail bars):
    Set hours to a compact human-readable summary of when the venue is open. Max 40 chars. Group consecutive days with the same hours. Use en-dash for ranges and lowercase am/pm. Examples: "Tue–Sun 6pm–2am", "Daily 5pm–1am", "Mon–Thu 6pm–12am, Fri–Sat 6pm–2am, Closed Sun", "Lunch Tue–Fri 12–2pm, Dinner Tue–Sat 7–10pm". If you are not confident about current hours, omit the field rather than guess.

For RESTAURANTS, also include when applicable: michelinStars (1, 2, or 3 — only from the current Michelin Guide; omit or 0 if none), michelinGreenStar (true if currently awarded the Michelin Green Star for sustainability), bibGourmand (true if currently a Michelin Bib Gourmand), worldsBest50Restaurants ({rank, year} — most recent year the restaurant placed on World's 50 Best Restaurants top 50 or extended 51–100 list, with that rank and year; omit if never listed). For COCKTAIL BARS, also include when applicable: worldsBest50Bars ({rank, year} — most recent year it placed on World's 50 Best Bars top 50 or extended 51–100, with that rank and year; omit if never listed), spiritedAward ({name, year} — most notable Tales of the Cocktail Spirited Award the bar has won, e.g. "World's Best Cocktail Bar", with the year; omit if none). Only include accolade fields you are confident about; never fabricate. If "${parsed.city}" is ambiguous, pick the most famous match.`,
          });
          const normalized = {
            ...object,
            venues: [
              ...object.venues
                .filter(
                  (v) =>
                    v.category === "restaurant" &&
                    haversineMiles(object.lat, object.lng, v.lat, v.lng) <= MAX_RADIUS_MILES,
                )
                .slice(0, 20),
              ...object.venues
                .filter(
                  (v) =>
                    v.category === "cocktail bar" &&
                    haversineMiles(object.lat, object.lng, v.lat, v.lng) <= MAX_RADIUS_MILES,
                )
                .slice(0, 20),
            ].map((v) => {
              const url = v.url && /^https?:\/\//i.test(v.url) ? v.url : undefined;
              const reservationUrl =
                v.reservationUrl && /^https?:\/\//i.test(v.reservationUrl)
                  ? v.reservationUrl
                  : undefined;
              return {
                name: v.name,
                category: v.category,
                cuisine: v.cuisine ?? "",
                priceRange: v.priceRange ?? "",
                description: v.description ?? "",
                neighborhood: v.neighborhood ?? undefined,
                lat: v.lat,
                lng: v.lng,
                url,
                urlType: normalizeUrlType(url, v.urlType),
                michelinStars: v.michelinStars ?? undefined,
                michelinGreenStar: v.michelinGreenStar ?? undefined,
                bibGourmand: v.bibGourmand ?? undefined,
                worldsBest50Restaurants: v.worldsBest50Restaurants ?? undefined,
                worldsBest50Bars: v.worldsBest50Bars ?? undefined,
                spiritedAward: v.spiritedAward ?? undefined,
                chef: v.chef ?? undefined,
                signatureDish: v.signatureDish ?? undefined,
                accoladeOverview: v.accoladeOverview ?? undefined,
                whyThisPick: v.whyThisPick ?? undefined,
                reservationUrl,
                reservationPlatform: reservationUrl ? (v.reservationPlatform ?? "Website") : undefined,
                hours: v.hours ?? undefined,
              };
            }),
          };
          return Response.json(normalized);
        } catch (err: unknown) {
          const e = err as { statusCode?: number; status?: number; message?: string };
          const status = e.statusCode ?? e.status;
          if (status === 429) {
            return Response.json(
              { error: "Too many requests. Please wait a moment and try again." },
              { status: 429 },
            );
          }
          if (status === 402) {
            return Response.json(
              { error: "AI credits exhausted. Add credits in Settings → Workspace → Usage." },
              { status: 402 },
            );
          }
          console.error("top-restaurants error:", err);
          return Response.json(
            { error: "Couldn't fetch restaurants. Try a different city." },
            { status: 500 },
          );
        }
      },
    },
  },
});