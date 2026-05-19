// Server-side Google Sheets accolades lookup.
// Fetches the canonical accolades workbook once per isolate, caches it,
// and exposes a fast in-memory lookup by venue name.

const SPREADSHEET_ID = "1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s";
const GATEWAY_BASE = "https://connector-gateway.lovable.dev/google_sheets/v4";
const CACHE_TTL_MS = 60 * 60 * 1000; // 1 hour

export type AccoladeEntry = {
  michelinStars?: number;
  bibGourmand?: boolean;
  worldsBest50Restaurants?: { rank: number; year: number };
  worldsBest50Bars?: { rank: number; year: number };
  jamesBeardAward?: { name: string; year: number };
  bestChefAward?: { knives: number; year: number };
  // Locale hints used to disambiguate when multiple venues share a name.
  city?: string;
  country?: string;
};

type CacheShape = {
  fetchedAt: number;
  byName: Map<string, AccoladeEntry[]>;
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
  const stars = (level.match(/★/g) ?? []).length;
  if (stars >= 1) return { stars };
  if (/bib/i.test(level)) return { bib: true };
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
  const [michelin, w50, jba, chef] = await Promise.all([
    fetchSheet("Michelin Guide"),
    fetchSheet("World's 50 Best"),
    fetchSheet("James Beard Awards"),
    fetchSheet("Best Chef Awards"),
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
    push(restaurant, {
      jamesBeardAward: { name: category, year },
      city: normalizeLocale(city),
      country: normalizeLocale(state),
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
      bestChefAward: { knives, year },
      city,
      country,
    });
  }

  return { fetchedAt: Date.now(), byName };
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
// accolades, scoping to entries whose city/country matches the query when
// possible (to disambiguate same-named venues in different cities).
const mergeEntries = (
  entries: AccoladeEntry[],
  queryCity: string,
  queryCountry: string,
): AccoladeEntry => {
  const cityNorm = normalizeLocale(queryCity);
  const countryNorm = normalizeLocale(queryCountry);
  const scoped = entries.filter((e) => {
    if (cityNorm && e.city && e.city.includes(cityNorm)) return true;
    if (countryNorm && e.country && e.country.includes(countryNorm)) return true;
    return false;
  });
  const pool = scoped.length > 0 ? scoped : entries;

  const merged: AccoladeEntry = {};
  for (const e of pool) {
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
    const entries = idx.byName.get(normalizeName(venueName));
    if (!entries || entries.length === 0) return null;
    return mergeEntries(entries, queryCity, queryCountry);
  } catch (err) {
    console.error("Accolades lookup failed:", err);
    return null;
  }
};