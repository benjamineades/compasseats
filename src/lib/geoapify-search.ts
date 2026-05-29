/**
 * Geoapify autocomplete — free tier-2 city/region search for queries
 * that don't match our charted city set.
 */

export type GeoapifyCityResult = {
  name: string;
  region?: string;
  country: string;
  lat: number;
  lng: number;
  kind: "city" | "region";
  placeId: string;
};

type GeoapifyFeature = {
  city?: string;
  name?: string;
  state?: string;
  county?: string;
  country?: string;
  lat?: number;
  lon?: number;
  place_id?: string;
  result_type?: string;
  rank?: { confidence?: number };
};

const ENDPOINT = "https://api.geoapify.com/v1/geocode/autocomplete";

async function fetchType(
  query: string,
  type: "city" | "state",
  limit: number,
  key: string,
  signal?: AbortSignal,
): Promise<GeoapifyFeature[]> {
  const url = `${ENDPOINT}?text=${encodeURIComponent(query)}&type=${type}&limit=${limit}&format=json&apiKey=${key}`;
  const res = await fetch(url, { signal });
  if (!res.ok) throw new Error(`Geoapify ${type} ${res.status}`);
  const json = (await res.json()) as { results?: GeoapifyFeature[] };
  return json.results ?? [];
}

export async function geoapifyCitySearch(
  query: string,
  signal?: AbortSignal,
): Promise<GeoapifyCityResult[]> {
  const key = import.meta.env.VITE_GEOAPIFY_KEY as string | undefined;
  if (!key) return [];

  const [cities, states] = await Promise.all([
    fetchType(query, "city", 6, key, signal),
    fetchType(query, "state", 3, key, signal).catch(() => [] as GeoapifyFeature[]),
  ]);

  const merged = [...cities, ...states];
  merged.sort(
    (a, b) => (b.rank?.confidence ?? 0) - (a.rank?.confidence ?? 0),
  );

  const mapped: GeoapifyCityResult[] = [];
  const seen = new Set<string>();
  for (const r of merged) {
    const name = r.city || r.name;
    if (!name || r.lat == null || r.lon == null || !r.country) continue;
    const id = r.place_id ?? `${name}-${r.country}-${r.lat}-${r.lon}`;
    if (seen.has(id)) continue;
    seen.add(id);
    mapped.push({
      name,
      region: r.state || r.county,
      country: r.country,
      lat: r.lat,
      lng: r.lon,
      kind: r.result_type === "city" ? "city" : "region",
      placeId: id,
    });
  }
  return mapped;
}

/** URL-safe slug for /uncharted/$slug routes. */
export function slugifyPlace(input: string): string {
  return input
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}