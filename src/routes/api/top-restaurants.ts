import "@tanstack/react-start";
import { createFileRoute } from "@tanstack/react-router";
import { generateObject } from "ai";
import { z } from "zod";
import { createLovableAiGatewayProvider } from "@/lib/ai-gateway";
import {
  lookupAccolades,
  listAccoladesForCity,
  type AccoladeEntry,
} from "@/lib/accolades.server";
import { restaurantScore, barScore } from "@/lib/ranking";
import { fetchSupplementaryVenues } from "@/lib/venue-fallback.server";

const STAR_WORDS = ["zero", "one", "two", "three"] as const;
const ordinal = (n: number) => {
  const s = ["th", "st", "nd", "rd"];
  const v = n % 100;
  return `${n}${s[(v - 20) % 10] ?? s[v] ?? s[0]}`;
};
const buildPrestigeSentence = (
  sheet: AccoladeEntry | null | undefined,
  category: string,
): string | undefined => {
  if (!sheet) return undefined;
  const parts: string[] = [];
  if (sheet.worldsBest50Restaurants) {
    const { rank, year } = sheet.worldsBest50Restaurants;
    parts.push(`#${rank} on World's 50 Best Restaurants ${year}.`);
  }
  if (sheet.worldsBest50Bars) {
    const { rank, year } = sheet.worldsBest50Bars;
    parts.push(`#${rank} on World's 50 Best Bars ${year}.`);
  }
  if (sheet.michelinStars && sheet.michelinStars > 0) {
    const word = STAR_WORDS[sheet.michelinStars] ?? String(sheet.michelinStars);
    parts.push(
      `${word.charAt(0).toUpperCase() + word.slice(1)} Michelin star${sheet.michelinStars === 1 ? "" : "s"}.`,
    );
  }
  if (sheet.bibGourmand) parts.push("Michelin Bib Gourmand.");
  if (sheet.bestChefAward) {
    const { knives, year } = sheet.bestChefAward;
    parts.push(`Best Chef Awards ${knives}-Knives (${year}).`);
  }
  if (sheet.jamesBeardAward) {
    const { name, year } = sheet.jamesBeardAward;
    parts.push(`James Beard ${name} (${year}).`);
  }
  if (sheet.pinnacleAward) {
    const { pins, year } = sheet.pinnacleAward;
    parts.push(`Pinnacle Guide ${pins}-pin (${year}).`);
  }
  if (sheet.spiritedAward) {
    const { name, year } = sheet.spiritedAward;
    parts.push(`Spirited Award — ${name} (${year}).`);
  }
  if (sheet.oadAward) {
    const { rank, year, region } = sheet.oadAward;
    parts.push(`#${rank} on OAD ${region} ${year}.`);
  }
  void category;
  void ordinal;
  return parts.length ? parts.join(" ") : undefined;
};

const QUALITATIVE_FORBIDDEN_PATTERNS = [
  /\b(?:michelin|bib\s+gourmand|world'?s\s+50\s+best|50\s+best|james\s+beard|best\s+chef|pinnacle|spirited|tales\s+of\s+the\s+cocktail|oad|opinionated\s+about\s+dining)\b/i,
  /\b(?:award|awards|awarded|winner|winning|rank|ranked|ranking|guide|stars?|starred|knives?|pins?)\b/i,
  /#\s*\d+/,
  /\b(?:19|20)\d{2}\b/,
  /\b(?:one|two|three|1|2|3)[ -]?(?:star|stars|pin|pins|knife|knives)\b/i,
] as const;

const hasAccoladeClaim = (text: string) =>
  QUALITATIVE_FORBIDDEN_PATTERNS.some((pattern) => pattern.test(text));

const scrubAiAccoladeClaims = (value: string | null | undefined): string | undefined => {
  const text = value?.replace(/\s+/g, " ").trim();
  if (!text) return undefined;
  const sentences = text.match(/[^.!?]+[.!?]*/g) ?? [text];
  const kept = sentences
    .map((sentence) => sentence.trim())
    .filter((sentence) => sentence && !hasAccoladeClaim(sentence));
  const cleaned = kept.join(" ").replace(/\s+/g, " ").trim();
  if (!cleaned) return undefined;
  return /[.!?]$/.test(cleaned) ? cleaned : `${cleaned}.`;
};

const qualitativeFallback = (venue: {
  name: string;
  category: "restaurant" | "cocktail bar";
  cuisine?: string | null;
  neighborhood?: string | null;
}) => {
  const safeCuisine = venue.cuisine && !hasAccoladeClaim(venue.cuisine)
    ? venue.cuisine.toLowerCase()
    : undefined;
  const style = venue.category === "cocktail bar"
    ? safeCuisine
      ? `${safeCuisine} drinks`
      : "a focused cocktail program"
    : safeCuisine
      ? `${safeCuisine} cooking`
      : "confident cooking";
  const place = venue.neighborhood && !hasAccoladeClaim(venue.neighborhood)
    ? ` in ${venue.neighborhood}`
    : "";
  return `${venue.name} stands out for ${style}${place}, with craft and atmosphere that make it a destination.`;
};

const bodySchema = z.object({
  city: z.string().trim().min(1).max(100),
  region: z.string().trim().max(100).optional(),
  country: z.string().trim().max(100).optional(),
  exclude: z.array(z.string().trim().min(1).max(200)).max(500).optional(),
  limit: z.coerce.number().int().min(1).max(10).optional(),
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

const absolutizeUrl = (raw: string, base: string): string | undefined => {
  try {
    return new URL(raw, base).toString();
  } catch {
    return undefined;
  }
};

const decodeHtmlAttr = (value: string) =>
  value
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;|&apos;/g, "'")
    .replace(/&#x2F;/gi, "/");

const bestSrcsetUrl = (srcset: string) => {
  const candidates = srcset
    .split(",")
    .map((part) => part.trim().split(/\s+/)[0])
    .filter(Boolean);
  return candidates.at(-1);
};

const isUsableVenueImage = (url: string) =>
  /^https?:\/\//i.test(url) &&
  !/\.(svg|gif)(?:[?#].*)?$/i.test(url) &&
  !/(favicon|logo|icon|sprite|placeholder|avatar|badge)/i.test(url);

const extractWebsiteImage = (html: string, baseUrl: string): string | undefined => {
  const candidates: Array<{ url: string; score: number }> = [];
  const addCandidate = (raw: string | undefined, score: number) => {
    if (!raw) return;
    const abs = absolutizeUrl(decodeHtmlAttr(raw.trim()), baseUrl);
    if (abs && isUsableVenueImage(abs)) candidates.push({ url: abs, score });
  };

  // Prefer explicit social preview images from the venue website.
  const patterns = [
    /<meta[^>]+property=["']og:image(?::secure_url)?["'][^>]*content=["']([^"']+)["']/i,
    /<meta[^>]+content=["']([^"']+)["'][^>]*property=["']og:image(?::secure_url)?["']/i,
    /<meta[^>]+name=["']twitter:image["'][^>]*content=["']([^"']+)["']/i,
    /<meta[^>]+content=["']([^"']+)["'][^>]*name=["']twitter:image["']/i,
    /<meta[^>]+itemprop=["']image["'][^>]*content=["']([^"']+)["']/i,
    /<meta[^>]+content=["']([^"']+)["'][^>]*itemprop=["']image["']/i,
    /<link[^>]+rel=["'][^"']*image_src[^"']*["'][^>]*href=["']([^"']+)["']/i,
    /<link[^>]+href=["']([^"']+)["'][^>]*rel=["'][^"']*image_src[^"']*["']/i,
  ];
  for (const re of patterns) {
    const m = html.match(re);
    addCandidate(m?.[1], 1000);
  }

  const jsonLdImage = html.match(/"image"\s*:\s*(?:"([^"]+)"|\[\s*"([^"]+)")/i);
  addCandidate(jsonLdImage?.[1] ?? jsonLdImage?.[2], 900);

  for (const img of html.matchAll(/<img\b[^>]*>/gi)) {
    const tag = img[0];
    const srcset = tag.match(/(?:srcset|data-srcset)=["']([^"']+)["']/i)?.[1];
    const src =
      bestSrcsetUrl(srcset ?? "") ??
      tag.match(/(?:src|data-src|data-lazy-src|data-original)=["']([^"']+)["']/i)?.[1];
    const width = Number(tag.match(/width=["']?(\d+)/i)?.[1] ?? 0);
    const height = Number(tag.match(/height=["']?(\d+)/i)?.[1] ?? 0);
    const imageText = `${src ?? ""} ${tag}`;
    const contextScore =
      /(hero|banner|restaurant|food|dish|dining|bar|cocktail|gallery|photo|image|uploads|media)/i.test(
        imageText,
      )
        ? 160
        : 0;
    const sizeScore = Math.min(width + height, 1600) / 10;
    addCandidate(src, 400 + contextScore + sizeScore);
  }

  return candidates.sort((a, b) => b.score - a.score)[0]?.url;
};

const fetchOgImage = async (pageUrl: string): Promise<string | undefined> => {
  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 2500);
    const res = await fetch(pageUrl, {
      signal: ctrl.signal,
        headers: {
          "User-Agent":
            "Mozilla/5.0 (compatible; CompassEatsBot/1.0; +https://www.compasseats.com)",
        Accept: "text/html,application/xhtml+xml",
      },
      redirect: "follow",
    });
    clearTimeout(timer);
    if (!res.ok) return undefined;
    const ct = res.headers.get("content-type") || "";
    if (!ct.includes("html")) return undefined;
    // Cap to first 200KB — og tags are always in <head>
    const reader = res.body?.getReader();
    if (!reader) return undefined;
    let received = 0;
    const chunks: Uint8Array[] = [];
    const MAX = 200_000;
    while (received < MAX) {
      const { done, value } = await reader.read();
      if (done || !value) break;
      chunks.push(value);
      received += value.length;
    }
    try {
      await reader.cancel();
    } catch {
      /* noop */
    }
    const html = new TextDecoder().decode(
      chunks.reduce((acc, c) => {
        const merged = new Uint8Array(acc.length + c.length);
        merged.set(acc, 0);
        merged.set(c, acc.length);
        return merged;
      }, new Uint8Array()),
    );
    return extractWebsiteImage(html, pageUrl);
  } catch {
    return undefined;
  }
};

// ---------------------------------------------------------------------------
// Fallback image sources: Wikipedia → Google Places → static generic.
// ---------------------------------------------------------------------------

const FALLBACK_RESTAURANT_IMAGE = "/fallback/restaurant.jpg";
const FALLBACK_BAR_IMAGE = "/fallback/bar.jpg";

const fetchWikipediaImage = async (
  name: string,
  city: string,
): Promise<string | undefined> => {
  const tryTitle = async (title: string): Promise<string | undefined> => {
    try {
      const ctrl = new AbortController();
      const timer = setTimeout(() => ctrl.abort(), 2000);
      const res = await fetch(
        `https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(title)}`,
        {
          signal: ctrl.signal,
          headers: {
            "User-Agent":
              "CompassEatsBot/1.0 (https://www.compasseats.com)",
            Accept: "application/json",
          },
        },
      );
      clearTimeout(timer);
      if (!res.ok) return undefined;
      const data = (await res.json()) as {
        type?: string;
        originalimage?: { source?: string };
        thumbnail?: { source?: string };
      };
      if (data.type === "disambiguation") return undefined;
      const img = data.originalimage?.source ?? data.thumbnail?.source;
      return img && isUsableVenueImage(img) ? img : undefined;
    } catch {
      return undefined;
    }
  };
  // Try a few title forms: "Name (restaurant)", "Name (city)", plain "Name".
  const candidates = [
    `${name} (restaurant)`,
    `${name} (bar)`,
    city ? `${name} (${city})` : null,
    name,
  ].filter((s): s is string => Boolean(s));
  for (const title of candidates) {
    const img = await tryTitle(title);
    if (img) return img;
  }
  return undefined;
};

const GOOGLE_MAPS_GATEWAY = "https://connector-gateway.lovable.dev/google_maps";

type GooglePlace = {
  id?: string;
  businessStatus?: string;
  formattedAddress?: string;
  location?: { latitude: number; longitude: number };
  photoName?: string;
};

const lookupGooglePlace = async (
  name: string,
  city: string,
  country: string,
  lat: number,
  lng: number,
): Promise<GooglePlace | null> => {
  const lovableKey = process.env.LOVABLE_API_KEY;
  const gmapsKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!lovableKey || !gmapsKey) return null;
  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 4500);
    const searchRes = await fetch(`${GOOGLE_MAPS_GATEWAY}/places/v1/places:searchText`, {
      method: "POST",
      signal: ctrl.signal,
      headers: {
        Authorization: `Bearer ${lovableKey}`,
        "X-Connection-Api-Key": gmapsKey,
        "Content-Type": "application/json",
        "X-Goog-FieldMask":
          "places.id,places.businessStatus,places.formattedAddress,places.location,places.photos",
      },
      body: JSON.stringify({
        textQuery: [name, city, country].filter(Boolean).join(", "),
        locationBias: Number.isFinite(lat) && Number.isFinite(lng)
          ? { circle: { center: { latitude: lat, longitude: lng }, radius: 48280 } }
          : undefined,
        maxResultCount: 1,
      }),
    });
    clearTimeout(timer);
    if (!searchRes.ok) return null;
    const data = (await searchRes.json()) as {
      places?: Array<{
        id?: string;
        businessStatus?: string;
        formattedAddress?: string;
        location?: { latitude: number; longitude: number };
        photos?: Array<{ name?: string }>;
      }>;
    };
    const p = data.places?.[0];
    if (!p) return null;
    return {
      id: p.id,
      businessStatus: p.businessStatus,
      formattedAddress: p.formattedAddress,
      location: p.location,
      photoName: p.photos?.[0]?.name,
    };
  } catch {
    return null;
  }
};

const fetchGooglePlacePhoto = async (
  photoName: string | undefined,
): Promise<string | undefined> => {
  if (!photoName) return undefined;
  const lovableKey = process.env.LOVABLE_API_KEY;
  const gmapsKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!lovableKey || !gmapsKey) return undefined;
  try {
    const mediaCtrl = new AbortController();
    const mediaTimer = setTimeout(() => mediaCtrl.abort(), 2500);
    const mediaRes = await fetch(
      `${GOOGLE_MAPS_GATEWAY}/places/v1/${photoName}/media?maxWidthPx=1200&skipHttpRedirect=true`,
      {
        signal: mediaCtrl.signal,
        headers: {
          Authorization: `Bearer ${lovableKey}`,
          "X-Connection-Api-Key": gmapsKey,
        },
      },
    );
    clearTimeout(mediaTimer);
    if (!mediaRes.ok) return undefined;
    const mediaData = (await mediaRes.json()) as { photoUri?: string };
    const uri = mediaData.photoUri;
    return uri && /^https?:\/\//i.test(uri) ? uri : undefined;
  } catch {
    return undefined;
  }
};

// Normalize a string for fuzzy substring matching of city/country in an address.
const normalizeForMatch = (s: string) =>
  s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();

// US state name → 2-letter code (Google addresses use the code, e.g. "FL").
const US_STATE_CODES: Record<string, string> = {
  alabama: "al", alaska: "ak", arizona: "az", arkansas: "ar", california: "ca",
  colorado: "co", connecticut: "ct", delaware: "de", florida: "fl", georgia: "ga",
  hawaii: "hi", idaho: "id", illinois: "il", indiana: "in", iowa: "ia",
  kansas: "ks", kentucky: "ky", louisiana: "la", maine: "me", maryland: "md",
  massachusetts: "ma", michigan: "mi", minnesota: "mn", mississippi: "ms",
  missouri: "mo", montana: "mt", nebraska: "ne", nevada: "nv",
  "new hampshire": "nh", "new jersey": "nj", "new mexico": "nm", "new york": "ny",
  "north carolina": "nc", "north dakota": "nd", ohio: "oh", oklahoma: "ok",
  oregon: "or", pennsylvania: "pa", "rhode island": "ri", "south carolina": "sc",
  "south dakota": "sd", tennessee: "tn", texas: "tx", utah: "ut", vermont: "vt",
  virginia: "va", washington: "wa", "west virginia": "wv", wisconsin: "wi",
  wyoming: "wy", "district of columbia": "dc",
};

// Strict city verification. The Google address MUST contain the requested
// city name. When a region is provided, the address must ALSO contain the
// region (or its US state code). Country alone is NEVER sufficient — that
// was letting Seaside, CA venues slip into Seaside, FL results.
// Aliases for cities whose Google-formatted addresses use a local name
// different from the English query (e.g. "Mexico City" → "Ciudad de México").
const CITY_ALIASES: Record<string, string[]> = {
  "mexico city": ["ciudad de mexico", "cdmx", "df", "distrito federal"],
  florence: ["firenze"],
  rome: ["roma"],
  milan: ["milano"],
  naples: ["napoli"],
  venice: ["venezia"],
  turin: ["torino"],
  munich: ["munchen"],
  cologne: ["koln"],
  vienna: ["wien"],
  prague: ["praha"],
  warsaw: ["warszawa"],
  moscow: ["moskva"],
  athens: ["athina"],
  lisbon: ["lisboa"],
  seville: ["sevilla"],
  copenhagen: ["kobenhavn"],
  gothenburg: ["goteborg"],
  "the hague": ["den haag"],
  antwerp: ["antwerpen"],
  brussels: ["bruxelles", "brussel"],
  geneva: ["geneve"],
  zurich: ["zurich"],
  bucharest: ["bucuresti"],
  belgrade: ["beograd"],
  istanbul: ["istanbul"],
  beijing: ["peking"],
  "ho chi minh city": ["ho chi minh", "saigon"],
  seoul: ["seoul"],
};

const placeIsInCity = (
  place: GooglePlace,
  city: string,
  country: string,
  region: string,
) => {
  const addr = place.formattedAddress ? normalizeForMatch(place.formattedAddress) : "";
  if (!addr) return true; // can't verify — don't drop on missing data
  // Strip anything after a comma — callers sometimes pass "Washington, DC"
  // or "Washington, District of Columbia"; we only want the bare city token.
  const cityN = normalizeForMatch((city ?? "").split(",")[0] ?? "");
  if (!cityN) return false;
  const aliases = CITY_ALIASES[cityN] ?? [];
  const cityMatches =
    addr.includes(cityN) || aliases.some((a) => addr.includes(a));
  if (!cityMatches) return false;
  const regionN = normalizeForMatch(region);
  // Region check is mainly to disambiguate same-named US cities (e.g.
  // Seaside, FL vs Seaside, CA). For non-US queries, Google's localized
  // region names ("Toscana" vs the user's "Tuscany") cause false rejections,
  // and same-name conflicts across regions are rare internationally — so
  // skip the region check unless the country looks like the US.
  const countryN = normalizeForMatch(country);
  const isUS =
    countryN === "united states" ||
    countryN === "united states of america" ||
    countryN === "usa" ||
    countryN === "us" ||
    countryN === "america";
  if (regionN && isUS) {
    const stateCode = US_STATE_CODES[regionN];
    const tokens = addr.split(" ");
    const regionAliases = CITY_ALIASES[regionN] ?? [];
    const matchesRegion =
      addr.includes(regionN) || (stateCode ? tokens.includes(stateCode) : false);
    if (!matchesRegion && !regionAliases.some((a) => addr.includes(a))) return false;
  }
  return true;
};

const genericFallback = (category: "restaurant" | "cocktail bar") =>
  category === "cocktail bar" ? FALLBACK_BAR_IMAGE : FALLBACK_RESTAURANT_IMAGE;

const resultsSchema = z.object({
  city: z.string(),
  country: z.string(),
  cityBlurb: z.string().nullish(),
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
        worldsBest50Restaurants: z.object({ rank: integerValue, year: integerValue }).nullish(),
        worldsBest50Bars: z.object({ rank: integerValue, year: integerValue }).nullish(),
        spiritedAward: z.object({ name: z.string(), year: integerValue }).nullish(),
        jamesBeardAward: z.object({ name: z.string(), year: integerValue }).nullish(),
        bestChefAward: z.object({ knives: integerValue, year: integerValue }).nullish(),
        pinnacleAward: z.object({ pins: integerValue, year: integerValue }).nullish(),
        chef: z.string().nullish(),
        signatureDish: z.string().nullish(),
        accoladeOverview: z.string().nullish(),
        whyThisPick: z.string().nullish(),
        reservationUrl: z.string().nullish(),
        reservationPlatform: z.string().nullish(),
        hours: z.string().nullish(),
        imageUrl: z.string().nullish(),
      }),
    )
      .min(0),
});

const sanitizeAiJson = (text: string) => {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) return null;

  return Array.from(text.slice(start, end + 1))
    .map((char) => {
      const code = char.charCodeAt(0);
      return code < 32 && code !== 9 && code !== 10 && code !== 13 ? " " : char;
    })
    .join("");
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
        const cityQuery = [parsed.city, parsed.region, parsed.country]
          .filter((s): s is string => Boolean(s && s.length))
          .join(", ");

        const limitForKey = parsed.limit ?? 10;
        const isInitialSearch = !parsed.exclude || parsed.exclude.length === 0;
        const cacheKey =
          [parsed.city, parsed.region ?? "", parsed.country ?? "", String(limitForKey)]
            .map((s) => s.trim().toLowerCase())
            .join("|");
        const cacheRequest = new Request(
          "https://compasseats-cache/top-restaurants?k=" + encodeURIComponent(cacheKey),
        );
        const edgeCache =
          typeof caches !== "undefined" && (caches as unknown as { default?: Cache }).default
            ? (caches as unknown as { default: Cache }).default
            : null;

        if (isInitialSearch && edgeCache) {
          try {
            const cached = await edgeCache.match(cacheRequest);
            if (cached) {
              console.log("[top-restaurants] cache hit", cacheKey);
              return cached;
            }
            console.log("[top-restaurants] cache miss", cacheKey);
          } catch (e) {
            console.log("[top-restaurants] cache read error", (e as Error).message);
          }
        }

        const apiKey = process.env.LOVABLE_API_KEY;
        if (!apiKey) {
          return Response.json({ error: "AI is not configured." }, { status: 500 });
        }

        const gateway = createLovableAiGatewayProvider(apiKey);
        // Flash is ~3–5x faster than Pro and sufficient for this task.
        const model = gateway("google/gemini-2.5-flash");

        const now = new Date();
        const currentYear = now.getUTCFullYear();
        const currentMonth = now.toLocaleString("en-US", { month: "long", timeZone: "UTC" });
        const minAccoladeYear = currentYear - 2;
        const limit = parsed.limit ?? 10;
        const excludeList = parsed.exclude ?? [];
        const isContinuation = excludeList.length > 0;
        const exclusionBlock = isContinuation
          ? `\n\nCONTINUATION CALL — the user has already seen the venues listed below and is asking for the NEXT batch. Do NOT include any of these names again; pick the next best venues in their place, continuing down the same priority order. If you genuinely cannot find ${limit} more qualified restaurants OR ${limit} more qualified cocktail bars for ${cityQuery} beyond those already shown, return as many fresh ones as you can (it is OK to return fewer than ${limit}, or even zero in one category). Already-shown venues to EXCLUDE: ${excludeList.join(", ")}.`
          : "";

        try {
          // Pre-fetch the canonical accolade venues for this city from the
          // linked spreadsheet AND scrape supplementary top-rated venues
          // from Yelp/TripAdvisor via Firecrawl. The AI is forbidden from
          // inventing venue names — every non-accolade venue must come from
          // the scraped allow-list below.
          const [cityAccolades, supplementary] = await Promise.all([
            listAccoladesForCity(parsed.city, parsed.country ?? ""),
            fetchSupplementaryVenues(
              parsed.city,
              parsed.region ?? "",
              parsed.country ?? "",
            ),
          ]);
          const seenExclude = new Set(excludeList.map((s) => s.trim().toLowerCase()));
          const seedVenues = cityAccolades
            .filter((a) => !seenExclude.has(a.name.toLowerCase()))
            .map((a) => {
              const tags: string[] = [];
              if (a.michelinStars) tags.push(`${a.michelinStars}★ Michelin`);
              if (a.bibGourmand) tags.push("Bib Gourmand");
              if (a.worldsBest50Restaurants)
                tags.push(`World's 50 Best #${a.worldsBest50Restaurants.rank} (${a.worldsBest50Restaurants.year})`);
              if (a.worldsBest50Bars)
                tags.push(`World's 50 Best Bars #${a.worldsBest50Bars.rank} (${a.worldsBest50Bars.year})`);
              if (a.bestChefAward)
                tags.push(`Best Chef ${a.bestChefAward.knives}-knives (${a.bestChefAward.year})`);
              if (a.jamesBeardAward)
                tags.push(`James Beard ${a.jamesBeardAward.name} (${a.jamesBeardAward.year})`);
              if (a.pinnacleAward)
                tags.push(`Pinnacle Guide ${a.pinnacleAward.pins}-pin (${a.pinnacleAward.year})`);
              if (a.spiritedAward)
                tags.push(`Spirited Award: ${a.spiritedAward.name} (${a.spiritedAward.year})`);
              return `  • ${a.name} — ${tags.join("; ")}`;
            })
            .slice(0, 60)
            .join("\n");
          const seedBlock = seedVenues
            ? `\n\nCANONICAL ACCOLADE VENUES FOR ${cityQuery} (from the official linked spreadsheet — these are the ONLY source of truth for accolades and rankings). You MUST include every one of these that is a restaurant or cocktail bar still operating, up to the ${limit} slots per category. Use the EXACT names below so server-side accolade enrichment can match them.\n${seedVenues}`
            : `\n\nNo canonical accolade venues are listed in the linked spreadsheet for ${cityQuery}.`;

          const formatNames = (names: string[]) =>
            names
              .filter((n) => !seenExclude.has(n.toLowerCase()))
              .slice(0, 25)
              .map((n) => `  • ${n}`)
              .join("\n");
          const restNames = formatNames(supplementary.restaurants);
          const barNames = formatNames(supplementary.bars);
          const sourceLabel = supplementary.source === "yelp" ? "Yelp" : "Trip Advisor";
          const supplementaryBlock =
            restNames || barNames
              ? `\n\nSUPPLEMENTARY VENUE ALLOW-LIST (top results scraped live from ${sourceLabel} for ${cityQuery}). When the canonical accolade list above does not fill all ${limit} slots in a category, you MUST pick names from this allow-list — do NOT invent venue names or pull from training data. Use the EXACT names shown.\n\nRESTAURANTS:\n${restNames || "  (none returned)"}\n\nCOCKTAIL BARS:\n${barNames || "  (none returned)"}`
              : `\n\nNo supplementary venues were available from Yelp or Trip Advisor for ${cityQuery}. If the canonical accolade list does not fill ${limit} slots in a category, return fewer venues for that category rather than inventing names.`;

          const { object } = await generateObject({
            model,
            schema: resultsSchema,
            experimental_repairText: async ({ text }) => sanitizeAiJson(text),
            prompt: `Today is ${currentMonth} ${currentYear}. List the ${limit} top restaurants AND the ${limit} top cocktail bars in ${cityQuery} (${limit * 2} venues total).${exclusionBlock}${seedBlock}${supplementaryBlock}

NAME SOURCE — STRICT: Every venue you return MUST come from either (a) the canonical accolade list above or (b) the supplementary allow-list above. Do NOT invent venue names. Do NOT pull venues from your training data. If neither list provides enough names to fill ${limit} slots in a category, return fewer venues in that category — better to return 6 real venues than 10 with fabricated names.

ACCOLADES — STRICT RULE: Do NOT populate michelinStars, michelinGreenStar, bibGourmand, worldsBest50Restaurants, worldsBest50Bars, jamesBeardAward, bestChefAward, pinnacleAward, or spiritedAward. The server enriches these from the linked spreadsheet. Leave all accolade fields empty/null.

RANKING PRIORITY — RESTAURANTS (apply in this STRICT order; the canonical accolade list above is the source of truth):
  1. Venues on the MOST RECENT World's 50 Best Restaurants edition (from the seed list above).
  2. Michelin 3-star restaurants (from the seed list).
  3. Best Chef Awards 3-Knives winners (from the seed list).
  4. Michelin 2-star restaurants.
  5. Best Chef Awards 2-Knives winners.
  6. James Beard Award winners (from the seed list).
  7. Michelin 1-star restaurants.
  8. Best Chef Awards 1-Knife winners.
  9. Fallback when the seed list is exhausted: highest-rated on Yelp if ${cityQuery} is in the United States (then Trip Advisor); otherwise highest-rated on Trip Advisor (then Yelp). No accolades for these.
      Pick these fallback restaurants ONLY from the supplementary allow-list above, in the order they appear there. Do not reorder or substitute.

RANKING PRIORITY — COCKTAIL BARS:
  1. Venues on the MOST RECENT World's 50 Best Bars edition (from the seed list above).
  2. Past years' World's 50 Best Bars editions (more recent first), still from the seed list.
  3. Pinnacle Guide bars (3-pin > 2-pin > 1-pin; recent year as tiebreaker) from the seed list.
  4. Tales of the Cocktail Spirited Award winners (most recent year first) from the seed list.
  5. Fallback when seed list exhausted: highest-rated on Yelp if in USA (then Trip Advisor); otherwise Trip Advisor first.
      Pick these fallback bars ONLY from the supplementary allow-list above, in the order they appear there. Do not reorder or substitute.

Return the ${limit} restaurants in priority order first, then the ${limit} cocktail bars in priority order. Do not use Google Maps for ranking, popularity, or selection. Use Google Maps ONLY for two things: (1) exclude any venue marked "Permanently closed" or otherwise known to have closed, and (2) source each venue's CURRENT precise latitude and longitude from its present-day Google Maps listing — if a venue has moved, use its current address coordinates, not historical ones.

Return JSON with: city (proper name), country, cityBlurb, lat/lng (city center coordinates), and venues (array of 20: 10 restaurants then 10 cocktail bars). Each venue: name, category ("restaurant" or "cocktail bar"), cuisine (for restaurants: cuisine type; for bars: style/specialty like speakeasy, tiki, classic), priceRange ("$", "$$", "$$$" or "$$$$"), description (see DESCRIPTION RULES), neighborhood (optional), lat/lng (precise current venue coordinates), url (the venue's official website if it has one; otherwise the Instagram profile URL; otherwise the Facebook page URL; omit only if none exist), urlType ("website" | "instagram" | "facebook" matching the url provided), imageUrl (a direct https URL to a representative photo of the venue — dining room, bar, or signature dish. SOURCE PRIORITY (use in this strict order; only fall back when the higher tier has no usable image): (1) the venue's Michelin Guide listing hero/gallery image at https://guide.michelin.com, (2) the venue's World's 50 Best Restaurants or World's 50 Best Bars listing image at https://www.theworlds50best.com, (3) the most recent high-quality post image from the venue's official Instagram account, (4) the best-looking image (well lit, aesthetic, professionally composed — prefer plated food or interior shots over crowd/selfie shots) from the venue's Yelp or TripAdvisor listing. Must end in .jpg/.jpeg/.png/.webp and be a publicly hot-linkable image, not a webpage. Omit if you cannot verify a working image URL).

CITY BLURB (cityBlurb field) — REQUIRED: ONE vivid sentence (max 28 words) describing what makes ${cityQuery} distinctive specifically for FOOD AND DRINK. Reference concrete signals — Michelin Guide presence (e.g. "home to X three-star kitchens"), World's 50 Best Restaurants/Bars representation, signature local dishes, defining ingredients, neighborhoods, or cocktail culture. Draw on the Michelin Guide and Wikipedia's culinary coverage of the city. Never generic ("a great food city"). Never mention politics, population, or geography unless directly tied to its cuisine.

DESCRIPTION RULES — RESTAURANTS: One vivid sentence, max 35 words. ALSO set these two fields when known: chef (current head/executive chef's full name — only if you're confident they are still at the venue; omit otherwise) and signatureDish (the dish the restaurant is most known for, named specifically, e.g. "smoked eel tartlet"; omit if not clearly known). For COCKTAIL BARS: one vivid sentence (max 25 words); do not set chef or signatureDish.

ACCOLADE OVERVIEW (accoladeOverview field) — REQUIRED FALLBACK:
  • For RESTAURANTS: Set accoladeOverview ONLY when BOTH chef and signatureDish are unknown. Write 1–2 sentences (max 45 words) describing the venue's culinary reputation QUALITATIVELY — cooking style, signature technique, chef pedigree, atmosphere, neighborhood/regional standing. If you have nothing concrete to say, omit the field.
  • For COCKTAIL BARS: Set accoladeOverview when you can describe the bar's craft reputation qualitatively (drink-making style, signature technique, bar program pedigree, atmosphere). 1–2 sentences (max 45 words). Omit if you have nothing concrete to say.
  • STRICT — Do NOT name specific awards, guides, star counts, ranks, or years (no "Michelin", "stars", "World's 50 Best", "#N", "2024", "Spirited Award", "James Beard", "Pinnacle", "Best Chef", "Bib Gourmand", etc.). The server prepends authoritative prestige claims from the linked spreadsheet — your job is qualitative description only.
  • NEVER cite Yelp, TripAdvisor, Google Reviews/Maps, or other user-rating platforms anywhere in this field. Never fabricate. If unsure, omit.

WHY THIS PICK (whyThisPick field) — REQUIRED for EVERY venue:
  Always populate whyThisPick with ONE concise sentence (max 25 words) describing the venue's culinary or craft reputation QUALITATIVELY — signature technique, chef pedigree, neighborhood institution status, regional influence, atmosphere. STRICT: Do NOT name specific awards, guides, star counts, ranks, or years (no "Michelin", "stars", "World's 50 Best", "#N", year numbers, "Spirited Award", "James Beard", "Pinnacle", "Best Chef", "Bib Gourmand", etc.). The server prepends the authoritative prestige sentence from the linked spreadsheet; your sentence supplies the qualitative reason only. NEVER cite Yelp, TripAdvisor, Google Reviews/Maps, Tabelog, or any user-rating platform. Never generic ("great food"). Never repeat the description verbatim.

  RESERVATIONS (reservationUrl + reservationPlatform) — set whenever the venue takes reservations through an online booking platform:
    • Applies to BOTH restaurants AND cocktail bars. Many top cocktail bars (especially World's 50 Best Bars listees) take reservations via Tock, Resy, or SevenRooms — include those.
    • reservationUrl: the venue's preferred public booking link. Prefer dedicated reservation platforms over the venue's own site. Priority order: Tock, Resy, OpenTable, SevenRooms, Seven Lamps, Yelp Reservations, Bookatable, TheFork (LaFourchette), Quandoo, Chope, TableCheck, Pocket Concierge, Tabelog reservations, Dorsia. If none of those exist, use a "Reservations" / "Book a table" page on the venue's official website. Must be a fully-qualified https URL.
    • reservationPlatform: the platform name matching the URL — e.g. "Tock", "Resy", "OpenTable", "SevenRooms", "Seven Lamps", "TheFork", "Tabelog", "Website". Capitalize properly.
    • Omit BOTH fields if the venue is walk-in only, only takes phone reservations, or you are not confident a working booking link exists. Never guess a URL.

  BUSINESS HOURS (hours field) — REQUIRED for EVERY venue (restaurants AND cocktail bars):
    Set hours to a compact human-readable summary of when the venue is open. Max 40 chars. Group consecutive days with the same hours. Use en-dash for ranges and lowercase am/pm. Examples: "Tue–Sun 6pm–2am", "Daily 5pm–1am", "Mon–Thu 6pm–12am, Fri–Sat 6pm–2am, Closed Sun", "Lunch Tue–Fri 12–2pm, Dinner Tue–Sat 7–10pm". If you are not confident about current hours, omit the field rather than guess.

Accolade fields are populated by the server from the linked spreadsheet; leave them empty. If "${cityQuery}" is ambiguous, pick the most famous match.`,
          });
          const aiRestaurants = object.venues.filter((v) => v.category === "restaurant");
          const aiBars = object.venues.filter((v) => v.category === "cocktail bar");
          // Score each venue using the strict priority rules so the order is
          // deterministic regardless of what order the AI returned things in.
          const sheetFor = async (v: { name: string }) =>
            lookupAccolades(v.name, object.city, object.country);
          const restSheets = await Promise.all(aiRestaurants.map(sheetFor));
          const barSheets = await Promise.all(aiBars.map(sheetFor));

          const restScore = (s: AccoladeEntry | null) => restaurantScore(s, currentYear);

          type Indexed<T> = { v: T; sheet: AccoladeEntry | null; score: number };
          const sortByScore = <T,>(arr: Indexed<T>[]) =>
            arr.sort((a, b) => b.score - a.score).map((x) => ({ v: x.v, sheet: x.sheet }));

          const orderedRest = sortByScore(
            aiRestaurants.map((v, i) => ({
              v,
              sheet: restSheets[i],
              score: restScore(restSheets[i]),
            })),
          ).slice(0, limit);
          const orderedBars = sortByScore(
            aiBars.map((v, i) => ({
              v,
              sheet: barSheets[i],
              score: barScore(barSheets[i]),
            })),
          ).slice(0, limit);
          const orderedPairs = [...orderedRest, ...orderedBars];
          const orderedVenues = orderedPairs.map((p) => p.v);
          const sheetAccolades = orderedPairs.map((p) => p.sheet);

          // Look up each venue on Google Places in parallel. This serves two
          // purposes: (1) drop venues that Google marks as permanently/temp
          // closed or that don't actually sit in the requested city, and
          // (2) reuse the Places photo for image fallback.
          const placeLookups = await Promise.all(
            orderedVenues.map((v) =>
              lookupGooglePlace(v.name, object.city, object.country, v.lat, v.lng),
            ),
          );
          const keepMask = orderedVenues.map((v, i) => {
            const place = placeLookups[i];
            if (!place) return true; // no Places result — keep (don't drop on API miss)
            if (
              place.businessStatus &&
              place.businessStatus !== "OPERATIONAL"
            ) {
              return false;
            }
            if (!placeIsInCity(place, parsed.city, object.country, parsed.region ?? "")) {
              // Place clearly resolves to a different city — drop.
              return false;
            }
            // Snap to current Google coords if available (handles relocations).
            if (place.location) {
              v.lat = place.location.latitude;
              v.lng = place.location.longitude;
            }
            return true;
          });
          const keptVenues = orderedVenues.filter((_, i) => keepMask[i]);
          const keptSheets = sheetAccolades.filter((_, i) => keepMask[i]);
          const keptPlaces = placeLookups.filter((_, i) => keepMask[i]);

          // Resolve images: venue site OG image → AI URL → Wikipedia →
          // Google Places photo (already fetched above) → static generic.
          const resolvedImages = await Promise.all(
            keptVenues.map(async (v, i) => {
              const aiImg = v.imageUrl && /^https?:\/\//i.test(v.imageUrl) ? v.imageUrl : undefined;
              const site = v.url && /^https?:\/\//i.test(v.url) ? v.url : undefined;
              const fromSite = site ? await fetchOgImage(site) : undefined;
              if (fromSite) return fromSite;
              if (aiImg) return aiImg;
              const fromWiki = await fetchWikipediaImage(v.name, object.city);
              if (fromWiki) return fromWiki;
              const fromPlaces = await fetchGooglePlacePhoto(keptPlaces[i]?.photoName);
              if (fromPlaces) return fromPlaces;
              return genericFallback(v.category);
            }),
          );

          const normalized = {
            ...object,
            cityBlurb: object.cityBlurb ?? undefined,
            venues: keptVenues.map((v, i) => {
              const url = v.url && /^https?:\/\//i.test(v.url) ? v.url : undefined;
              const reservationUrl =
                v.reservationUrl && /^https?:\/\//i.test(v.reservationUrl)
                  ? v.reservationUrl
                  : undefined;
              const sheet = keptSheets[i];
              const prestige = buildPrestigeSentence(sheet, v.category);
              const aiWhy = scrubAiAccoladeClaims(v.whyThisPick) ?? qualitativeFallback(v);
              const whyThisPick = prestige
                ? aiWhy
                  ? `${prestige} ${aiWhy}`
                  : prestige
                : aiWhy || undefined;
              const aiOverview = scrubAiAccoladeClaims(v.accoladeOverview);
              const accoladeOverview = prestige
                ? aiOverview
                  ? `${prestige} ${aiOverview}`
                  : prestige
                : aiOverview || undefined;
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
                // Accolades come ONLY from the linked spreadsheet now.
                michelinStars: sheet?.michelinStars ?? undefined,
                michelinGreenStar: undefined,
                bibGourmand: sheet?.bibGourmand ?? undefined,
                worldsBest50Restaurants: sheet?.worldsBest50Restaurants ?? undefined,
                worldsBest50Bars: sheet?.worldsBest50Bars ?? undefined,
                spiritedAward: sheet?.spiritedAward ?? undefined,
                pinnacleAward: sheet?.pinnacleAward ?? undefined,
                chef: v.chef ?? undefined,
                signatureDish: v.signatureDish ?? undefined,
                accoladeOverview,
                whyThisPick,
                reservationUrl,
                reservationPlatform: reservationUrl
                  ? (v.reservationPlatform ?? "Website")
                  : undefined,
                hours: v.hours ?? undefined,
                jamesBeardAward: sheet?.jamesBeardAward ?? undefined,
                bestChefAward: sheet?.bestChefAward ?? undefined,
                imageUrl: resolvedImages[i],
              };
            }),
          };
          const response = Response.json(normalized);
          if (isInitialSearch && edgeCache) {
            try {
              const cacheable = new Response(response.clone().body, response);
              cacheable.headers.set("Cache-Control", "public, max-age=86400");
              await edgeCache.put(cacheRequest, cacheable);
            } catch (e) {
              console.log("[top-restaurants] cache write error", (e as Error).message);
            }
          }
          return response;
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
