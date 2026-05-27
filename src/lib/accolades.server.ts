// Server-side Google Sheets accolades lookup.
// Fetches the canonical accolades workbook once per isolate, caches it,
// and exposes a fast in-memory lookup by venue name.

const SPREADSHEET_ID = "1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s";
const GATEWAY_BASE = "https://connector-gateway.lovable.dev/google_sheets/v4";
const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour
const ENRICHMENT_TAB = "Places Enrichment";

export type AccoladeEntry = {
  displayName?: string;
  michelinStars?: number;
  bibGourmand?: boolean;
  worldsBest50Restaurants?: { rank: number; year: number };
  worldsBest50Bars?: { rank: number; year: number };
  jamesBeardAward?: { name: string; year: number };
  bestChefAward?: { knives: number; year: number };
  pinnacleAward?: { pins: number; year: number };
  spiritedAward?: { name: string; year: number };
  oadAward?: { rank: number; year: number; region: string };
  // Locale hints used to disambiguate when multiple venues share a name.
  city?: string;
  country?: string;
  // Google Places enrichment, joined from the "Places Enrichment" tab (built by
  // the one-time admin/enrich route). Present only for venues that have been
  // enriched. Enables rendering the charted tier straight from the sheet with
  // NO AI call, and supplies a ToS-safe photo reference instead of a raw URL.
  places?: PlacesEnrichment;
};

export type PlacesEnrichment = {
  placeId: string;
  canonicalName?: string;
  lat?: number;
  lng?: number;
  photoName?: string;
  formattedAddress?: string;
  businessStatus?: string;
};

type CacheShape = {
  fetchedAt: number;
  byName: Map<string, AccoladeEntry[]>;
  // Places enrichment keyed by the SAME normalized name key as byName.
  enrichmentByKey: Map<string, PlacesEnrichment>;
  // Second matching key: normalized canonical Google name → normalized sheet
  // key. Lets a lookup on the canonical spelling (e.g. "ben fiddich") resolve
  // to the sheet's spelling (e.g. "bar benfiddich").
  canonicalAlias: Map<string, string>;
};

let cache: CacheShape | null = null;
let inflight: Promise<CacheShape> | null = null;

const normalizeName = (raw: string): string =>
  raw
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[’'`]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim();

const normalizeLocale = (raw: string | undefined): string =>
  (raw ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();

// Country/state alias map. Keys are normalized input forms; values are the
// canonical token used for comparison. Covers common variants seen in the
// sheet (e.g. Michelin uses "USA", James Beard uses state codes) vs what
// the frontend / geocoder sends ("United States", "New York").
const COUNTRY_ALIASES: Record<string, string> = {
  "usa": "usa",
  "u s a": "usa",
  "us": "usa",
  "united states": "usa",
  "united states of america": "usa",
  "america": "usa",
  "uk": "uk",
  "u k": "uk",
  "united kingdom": "uk",
  "great britain": "uk",
  "britain": "uk",
  "england": "uk",
  "scotland": "uk",
  "wales": "uk",
  "northern ireland": "uk",
  "uae": "uae",
  "united arab emirates": "uae",
  "south korea": "south korea",
  "korea": "south korea",
  "republic of korea": "south korea",
  "czech republic": "czechia",
  "czechia": "czechia",
  "holland": "netherlands",
  "netherlands": "netherlands",
  "the netherlands": "netherlands",
};

const canonicalCountry = (loc: string): string => {
  const n = normalizeLocale(loc);
  return COUNTRY_ALIASES[n] ?? n;
};

// US state names and 2-letter codes — used to coerce James Beard rows
// (which store the state in the country column) to country = "usa".
const US_STATES = new Set<string>([
  "al","ak","az","ar","ca","co","ct","de","fl","ga","hi","id","il","in","ia","ks","ky","la","me","md","ma","mi","mn","ms","mo","mt","ne","nv","nh","nj","nm","ny","nc","nd","oh","ok","or","pa","ri","sc","sd","tn","tx","ut","vt","va","wa","wv","wi","wy","dc",
  "alabama","alaska","arizona","arkansas","california","colorado","connecticut","delaware","florida","georgia","hawaii","idaho","illinois","indiana","iowa","kansas","kentucky","louisiana","maine","maryland","massachusetts","michigan","minnesota","mississippi","missouri","montana","nebraska","nevada","new hampshire","new jersey","new mexico","new york","north carolina","north dakota","ohio","oklahoma","oregon","pennsylvania","rhode island","south carolina","south dakota","tennessee","texas","utah","vermont","virginia","washington","west virginia","wisconsin","wyoming","district of columbia",
]);

const fetchSheet = async (sheetName: string): Promise<string[][]> => {
  const apiKey = process.env.LOVABLE_API_KEY;
  const conn = process.env.GOOGLE_SHEETS_API_KEY;
  if (!apiKey || !conn) throw new Error("Google Sheets credentials missing");
  // Don't encode the range — gateway requires raw colons in path.
  const range = `'${sheetName.replace(/'/g, "''")}'!A2:Z`;
  const url = `${GATEWAY_BASE}/spreadsheets/${SPREADSHEET_ID}/values/${range}`;
  const res = await fetch(url, {
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "X-Connection-Api-Key": conn,
    },
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Sheets API ${res.status} for ${sheetName}: ${text.slice(0, 200)}`);
  }
  const data = (await res.json()) as { values?: string[][] };
  return data.values ?? [];
};

const parseMichelinStars = (level: string): { stars?: number; bib?: boolean } => {
  const glyph = (level.match(/★/g) ?? []).length;
  if (glyph >= 1) return { stars: glyph };
  const l = level.toLowerCase();
  if (/\bthree\b|\b3\b/.test(l) && /star/.test(l)) return { stars: 3 };
  if (/\btwo\b|\b2\b/.test(l) && /star/.test(l)) return { stars: 2 };
  if (/\bone\b|\b1\b/.test(l) && /star/.test(l)) return { stars: 1 };
  if (/bib/.test(l)) return { bib: true };
  return {};
};

// "Chicago, IL, USA" → { city: "chicago", country: "usa" }
const splitMichelinLocation = (loc: string) => {
  const parts = loc.split(",").map((s) => s.trim()).filter(Boolean);
  return {
    city: normalizeLocale(parts[0]),
    country: normalizeLocale(parts[parts.length - 1]),
  };
};

const buildIndex = async (): Promise<CacheShape> => {
  const OAD_SHEETS = [
    "OAD North America 2026",
    "OAD South America 2026",
    "OAD Asia 2025",
    "OAD Europe 2025",
    "OAD Japan 2025",
    "OAD North America 2025",
    "OAD South America 2025",
  ] as const;
  const [michelin, w50, jba, chef, pinnacle, spirited, ...oadSheets] = await Promise.all([
    fetchSheet("Michelin Guide"),
    fetchSheet("World's 50 Best"),
    fetchSheet("James Beard Awards"),
    fetchSheet("Best Chef Awards"),
    fetchSheet("Pinnacle Guide"),
    fetchSheet("Spirited Awards"),
    ...OAD_SHEETS.map((name) => fetchSheet(name).catch(() => [] as string[][])),
  ]);

  const byName = new Map<string, AccoladeEntry[]>();
  const push = (name: string, entry: AccoladeEntry) => {
    const key = normalizeName(name);
    if (!key) return;
    const arr = byName.get(key);
    if (arr) arr.push(entry);
    else byName.set(key, [entry]);
  };

  // Michelin Guide: [Star Level, Restaurant Name, Location, Price, Cuisine]
  for (const row of michelin) {
    const [level, name, location] = row;
    if (!name) continue;
    const { stars, bib } = parseMichelinStars(level ?? "");
    if (!stars && !bib) continue;
    const { city, country } = splitMichelinLocation(location ?? "");
    push(name, {
      displayName: name,
      michelinStars: stars,
      bibGourmand: bib,
      city,
      country,
    });
  }

  // World's 50 Best: [Year, Rank, Type, Name, City, Country]
  for (const row of w50) {
    const [yearStr, rankStr, type, name, city, country] = row;
    if (!name) continue;
    const year = Number(yearStr);
    const rank = Number(rankStr);
    if (!Number.isFinite(year) || !Number.isFinite(rank)) continue;
    const isBar = /bar/i.test(type ?? "");
    push(name, {
      displayName: name,
      [isBar ? "worldsBest50Bars" : "worldsBest50Restaurants"]: { rank, year },
      city: normalizeLocale(city),
      country: normalizeLocale(country),
    });
  }

  // James Beard: [Year, Award Category, Chef, Restaurant, City, State]
  for (const row of jba) {
    const [yearStr, category, , restaurant, city, state] = row;
    if (!restaurant || !category) continue;
    const year = Number(yearStr);
    if (!Number.isFinite(year)) continue;
    const stateNorm = normalizeLocale(state);
    const country = US_STATES.has(stateNorm) ? "usa" : stateNorm;
    push(restaurant, {
      displayName: restaurant,
      jamesBeardAward: { name: category, year },
      city: normalizeLocale(city),
      country,
    });
  }

  // Best Chef Awards: [Year, Chef Name, Restaurant, Knives, Location]
  for (const row of chef) {
    const [yearStr, , restaurant, knivesStr, location] = row;
    if (!restaurant) continue;
    const year = Number(yearStr);
    const knives = Number(knivesStr);
    if (!Number.isFinite(year) || !Number.isFinite(knives)) continue;
    const { city, country } = splitMichelinLocation(location ?? "");
    push(restaurant, {
      displayName: restaurant,
      bestChefAward: { knives, year },
      city,
      country,
    });
  }

  // Pinnacle Guide: [Number of Pins, Year Earned, Bar Name, City, Country]
  for (const row of pinnacle) {
    const [pinsStr, yearStr, bar, city, country] = row;
    if (!bar) continue;
    const pins = Number(pinsStr);
    const year = Number(yearStr);
    if (!Number.isFinite(pins) || !Number.isFinite(year)) continue;
    push(bar, {
      displayName: bar,
      pinnacleAward: { pins, year },
      city: normalizeLocale(city),
      country: normalizeLocale(country),
    });
  }

  // Spirited Awards: [Year, Award Category, Bar/Establishment, City, State, Country]
  for (const row of spirited) {
    const [yearStr, category, bar, city, , country] = row;
    if (!bar || !category) continue;
    const year = Number(yearStr);
    if (!Number.isFinite(year)) continue;
    push(bar, {
      displayName: bar,
      spiritedAward: { name: category, year },
      city: normalizeLocale(city),
      country: normalizeLocale(country),
    });
  }

  // OAD (Opinionated About Dining): one sheet per region/year.
  // Columns: [Ranking, Restaurant Name, City, State, Country, Cuisine Type]
  for (let s = 0; s < OAD_SHEETS.length; s++) {
    const sheetName = OAD_SHEETS[s];
    const match = sheetName.match(/^OAD\s+(.+?)\s+(\d{4})$/);
    if (!match) continue;
    const region = match[1];
    const year = Number(match[2]);
    for (const row of oadSheets[s] ?? []) {
      const [rankStr, restaurant, city, , country] = row;
      if (!restaurant) continue;
      const rank = Number(rankStr);
      if (!Number.isFinite(rank) || !Number.isFinite(year)) continue;
      push(restaurant, {
        displayName: restaurant,
        oadAward: { rank, year, region },
        city: normalizeLocale(city),
        country: normalizeLocale(country),
      });
    }
  }

  // Places Enrichment tab (built by the one-time admin/enrich route).
  // Columns: [normalizedKey, canonicalName, sheetName, placeId, lat, lng,
  //           photoName, formattedAddress, businessStatus, lastVerified]
  // Read defensively: the tab may not exist yet (enrichment not run), in which
  // case we just skip the join and behave exactly as before.
  const enrichmentByKey = new Map<string, PlacesEnrichment>();
  const canonicalAlias = new Map<string, string>();
  try {
    const enrichRows = await fetchSheet(ENRICHMENT_TAB);
    for (const row of enrichRows) {
      const [key, canonicalName, , placeId, latStr, lngStr, photoName, formattedAddress, businessStatus] = row;
      if (!key || !placeId) continue;
      const lat = Number(latStr);
      const lng = Number(lngStr);
      const enr: PlacesEnrichment = {
        placeId,
        canonicalName: canonicalName || undefined,
        lat: Number.isFinite(lat) ? lat : undefined,
        lng: Number.isFinite(lng) ? lng : undefined,
        photoName: photoName || undefined,
        formattedAddress: formattedAddress || undefined,
        businessStatus: businessStatus || undefined,
      };
      // Keep the first enrichment per key (stable).
      if (!enrichmentByKey.has(key)) enrichmentByKey.set(key, enr);
      // Register the canonical name as a second matching key, but never let it
      // shadow a real sheet key, and don't overwrite an existing alias.
      if (canonicalName) {
        const alias = normalizeName(canonicalName);
        if (alias && alias !== key && !byName.has(alias) && !canonicalAlias.has(alias)) {
          canonicalAlias.set(alias, key);
        }
      }
    }
  } catch (err) {
    console.warn("Places Enrichment tab unavailable — proceeding without it:", (err as Error).message);
  }

  return { fetchedAt: Date.now(), byName, enrichmentByKey, canonicalAlias };
};

const getIndex = async (): Promise<CacheShape> => {
  if (cache && Date.now() - cache.fetchedAt < CACHE_TTL_MS) return cache;
  if (inflight) return inflight;
  inflight = buildIndex()
    .then((built) => {
      cache = built;
      return built;
    })
    .finally(() => {
      inflight = null;
    });
  return inflight;
};

// Merge multiple entries for the same venue into the strongest/most-recent
// accolades. Disambiguation is STRICT: when the query supplies a country
// and the sheet has country data for this name, the country MUST match —
// otherwise we return null (it's a different venue with the same name).
// City is matched the same way as a refinement on top of country.
const localeMatches = (entryLoc: string | undefined, queryLoc: string): boolean => {
  if (!entryLoc || !queryLoc) return false;
  return entryLoc.includes(queryLoc) || queryLoc.includes(entryLoc);
};

const countryMatches = (entryCountry: string | undefined, queryCountry: string): boolean => {
  if (!entryCountry || !queryCountry) return false;
  return canonicalCountry(entryCountry) === canonicalCountry(queryCountry);
};

const mergeEntries = (
  entries: AccoladeEntry[],
  queryCity: string,
  queryCountry: string,
): AccoladeEntry | null => {
  const cityNorm = normalizeLocale(queryCity);
  const countryNorm = normalizeLocale(queryCountry);
  let pool = entries;

  if (countryNorm) {
    const byCountry = pool.filter((e) => countryMatches(e.country, countryNorm));
    if (byCountry.length > 0) {
      pool = byCountry;
    } else if (pool.some((e) => e.country)) {
      // We have country data but none matches → different venue.
      return null;
    }
  }
  if (cityNorm) {
    const byCity = pool.filter((e) => localeMatches(e.city, cityNorm));
    if (byCity.length > 0) {
      pool = byCity;
    } else if (pool.some((e) => e.city)) {
      return null;
    }
  }

  const merged: AccoladeEntry = {};
  for (const e of pool) {
    if (!merged.displayName && e.displayName) merged.displayName = e.displayName;
    if (e.michelinStars && (merged.michelinStars ?? 0) < e.michelinStars) {
      merged.michelinStars = e.michelinStars;
    }
    if (e.bibGourmand) merged.bibGourmand = true;
    if (
      e.worldsBest50Restaurants &&
      (!merged.worldsBest50Restaurants ||
        e.worldsBest50Restaurants.year > merged.worldsBest50Restaurants.year)
    ) {
      merged.worldsBest50Restaurants = e.worldsBest50Restaurants;
    }
    if (
      e.worldsBest50Bars &&
      (!merged.worldsBest50Bars ||
        e.worldsBest50Bars.year > merged.worldsBest50Bars.year)
    ) {
      merged.worldsBest50Bars = e.worldsBest50Bars;
    }
    if (
      e.jamesBeardAward &&
      (!merged.jamesBeardAward || e.jamesBeardAward.year > merged.jamesBeardAward.year)
    ) {
      merged.jamesBeardAward = e.jamesBeardAward;
    }
    if (
      e.bestChefAward &&
      (!merged.bestChefAward ||
        e.bestChefAward.year > merged.bestChefAward.year ||
        (e.bestChefAward.year === merged.bestChefAward.year &&
          e.bestChefAward.knives > merged.bestChefAward.knives))
    ) {
      merged.bestChefAward = e.bestChefAward;
    }
    if (
      e.pinnacleAward &&
      (!merged.pinnacleAward ||
        e.pinnacleAward.pins > merged.pinnacleAward.pins ||
        (e.pinnacleAward.pins === merged.pinnacleAward.pins &&
          e.pinnacleAward.year > merged.pinnacleAward.year))
    ) {
      merged.pinnacleAward = e.pinnacleAward;
    }
    if (
      e.spiritedAward &&
      (!merged.spiritedAward || e.spiritedAward.year > merged.spiritedAward.year)
    ) {
      merged.spiritedAward = e.spiritedAward;
    }
    if (
      e.oadAward &&
      (!merged.oadAward ||
        e.oadAward.year > merged.oadAward.year ||
        (e.oadAward.year === merged.oadAward.year && e.oadAward.rank < merged.oadAward.rank))
    ) {
      merged.oadAward = e.oadAward;
    }
  }
  return merged;
};

export const lookupAccolades = async (
  venueName: string,
  queryCity: string,
  queryCountry: string,
): Promise<AccoladeEntry | null> => {
  try {
    const idx = await getIndex();
    const key = normalizeName(venueName);
    // Direct hit, else fall back through the canonical-name alias (fixes the
    // "Ben Fiddich" vs sheet's "Bar Benfiddich" class of misses).
    let resolvedKey = idx.byName.has(key) ? key : idx.canonicalAlias.get(key);
    if (!resolvedKey) return null;
    const entries = idx.byName.get(resolvedKey);
    if (!entries || entries.length === 0) return null;
    const merged = mergeEntries(entries, queryCity, queryCountry);
    if (!merged) return null;
    // Attach Places enrichment if we have it for this venue.
    const enr = idx.enrichmentByKey.get(resolvedKey);
    if (enr) merged.places = enr;
    return merged;
  } catch (err) {
    console.error("Accolades lookup failed:", err);
    return null;
  }
};

// Direct Places-enrichment lookup by venue name (with canonical-alias
// fallback). Returns coordinates / placeId / photo reference for a venue, or
// null. Used by the (future) AI-free charted path to render straight from the
// sheet index without an AI or live Places call.
export const lookupEnrichment = async (
  venueName: string,
): Promise<PlacesEnrichment | null> => {
  try {
    const idx = await getIndex();
    const key = normalizeName(venueName);
    const resolvedKey = idx.enrichmentByKey.has(key)
      ? key
      : idx.canonicalAlias.get(key);
    if (!resolvedKey) return null;
    return idx.enrichmentByKey.get(resolvedKey) ?? null;
  } catch (err) {
    console.error("Enrichment lookup failed:", err);
    return null;
  }
};

// ---- Test helpers ----
// These are exported solely for unit tests. Do not call from app code.
export const __test = {
  mergeEntries,
  normalizeName,
  setIndex(entries: Array<{ name: string; entry: AccoladeEntry }>) {
    const byName = new Map<string, AccoladeEntry[]>();
    for (const { name, entry } of entries) {
      const key = normalizeName(name);
      const arr = byName.get(key);
      if (arr) arr.push(entry);
      else byName.set(key, [entry]);
    }
    cache = {
      fetchedAt: Date.now(),
      byName,
      enrichmentByKey: new Map(),
      canonicalAlias: new Map(),
    };
  },
  clearIndex() {
    cache = null;
  },
};

// Enumerate every venue in the sheet that matches the queried city/country.
// Used to seed the AI prompt with the canonical accolade venues for the city
// so it always returns them (instead of guessing from training data).
export const listAccoladesForCity = async (
  queryCity: string,
  queryCountry: string,
): Promise<Array<AccoladeEntry & { name: string }>> => {
  try {
    const idx = await getIndex();
    const out: Array<AccoladeEntry & { name: string }> = [];
    for (const [key, entries] of idx.byName.entries()) {
      const merged = mergeEntries(entries, queryCity, queryCountry);
      if (!merged) continue;
      const name = merged.displayName ?? entries.find((e) => e.displayName)?.displayName;
      if (!name) continue;
      const enr = idx.enrichmentByKey.get(key);
      if (enr) merged.places = enr;
      out.push({ ...merged, name });
    }
    return out;
  } catch (err) {
    console.error("listAccoladesForCity failed:", err);
    return [];
  }
};