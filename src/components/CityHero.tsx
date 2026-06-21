import { useQuery } from "@tanstack/react-query";
import { Link } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";
import type { ReactNode } from "react";
import { Wordmark } from "./Compass";

type Props = {
  city: string;
  country?: string;
  blurb?: string;
  hueSeed?: string;
  imageUrl?: string;
  lat?: number;
  lng?: number;
  back: { to: "/"; label?: string } | { onClick: () => void; label?: string };
  crumbs?: { label: string; to?: "/" }[];
  counts?: { total: number; restaurants: number; bars: number };
  children?: ReactNode;
};

type WikiSummary = {
  type?: string;
  originalimage?: { source?: string };
  thumbnail?: { source?: string };
  coordinates?: { lat?: number; lon?: number };
};

async function fetchWikiImage(name: string): Promise<WikiSummary | null> {
  try {
    const res = await fetch(
      `https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(name)}`,
    );
    if (!res.ok) return null;
    const data = (await res.json()) as WikiSummary;
    // Skip disambiguation pages — they don't have a representative image.
    if (data.type === "disambiguation") return null;
    if (!data.originalimage?.source && !data.thumbnail?.source) return null;
    return data;
  } catch {
    return null;
  }
}

// Find Wikipedia articles near a set of coordinates (closest first). Lets us
// surface a real photo for smaller towns whose name alone doesn't resolve.
async function fetchGeoTitles(lat: number, lng: number): Promise<string[]> {
  try {
    const url =
      `https://en.wikipedia.org/w/api.php?action=query&list=geosearch` +
      `&gscoord=${lat}%7C${lng}&gsradius=10000&gslimit=8&format=json&origin=*`;
    const res = await fetch(url);
    if (!res.ok) return [];
    const data = (await res.json()) as {
      query?: { geosearch?: { title?: string }[] };
    };
    return (data.query?.geosearch ?? [])
      .map((g) => g.title)
      .filter((t): t is string => !!t);
  } catch {
    return [];
  }
}

// Rough distance in km between two points (haversine).
function distanceKm(aLat: number, aLng: number, bLat: number, bLng: number): number {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(bLat - aLat);
  const dLng = toRad(bLng - aLng);
  const s =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(aLat)) * Math.cos(toRad(bLat)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.min(1, Math.sqrt(s)));
}

// Trust a name match only if it sits near the city's real coordinates. This
// rejects same-name-different-subject matches — e.g. "Savannah" the grassland
// biome instead of Savannah, Georgia, or "Florence" the name vs the city.
function matchesLocation(hit: WikiSummary, lat?: number, lng?: number): boolean {
  if (typeof lat !== "number" || typeof lng !== "number") return true;
  const c = hit.coordinates;
  if (typeof c?.lat !== "number" || typeof c?.lon !== "number") return false;
  return distanceKm(lat, lng, c.lat, c.lon) <= 80;
}

async function resolveCityImage(
  city: string,
  country?: string,
  lat?: number,
  lng?: number,
): Promise<WikiSummary | null> {
  // 1. Try the city by name (accurate & iconic for well-known places), but
  //    only trust the result if it sits near the city's real coordinates.
  const candidates = [
    country ? `${city}, ${country}` : null,
    `${city} City`,
    city,
  ].filter((v): v is string => !!v);
  for (const name of candidates) {
    const hit = await fetchWikiImage(name);
    if (hit && matchesLocation(hit, lat, lng)) return hit;
  }
  // 2. Fall back to "what notable place is right here?" using coordinates.
  if (typeof lat === "number" && typeof lng === "number") {
    const titles = await fetchGeoTitles(lat, lng);
    for (const title of titles.slice(0, 5)) {
      const hit = await fetchWikiImage(title);
      if (hit) return hit;
    }
  }
  return null;
}

export function CityHero({
  city,
  country,
  blurb,
  imageUrl,
  lat,
  lng,
  back,
  crumbs,
  counts,
  children,
}: Props) {
  const query = useQuery({
    queryKey: ["city-hero", city, country ?? "", lat ?? 0, lng ?? 0],
    queryFn: () => resolveCityImage(city, country, lat, lng),
    staleTime: 1000 * 60 * 60 * 24,
    enabled: !imageUrl,
  });
  const summary = query.data;
  const image =
    imageUrl ?? summary?.originalimage?.source ?? summary?.thumbnail?.source ?? null;
  const descriptor = blurb;

  const backLabel = back.label ?? "Back to search";

  const plural = (n: number, word: string) => `${n} ${word}${n === 1 ? "" : "s"}`;

  return (
    <section
      className="relative overflow-hidden border-b border-border"
      style={{
        // No-photo fallback: a warm charcoal/brass title card. The warm color
        // holds behind the text on the left, then eases off toward the compass
        // on the right. When a photo exists, it covers this entirely.
        background:
          "linear-gradient(to right, rgba(19,17,15,0) 20%, rgba(19,17,15,0.50) 95%)," +
          " linear-gradient(135deg, hsl(32 52% 21%) 0%, hsl(24 46% 12%) 100%)",
      }}
    >
      {image && (
        <img
          src={image}
          alt=""
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 h-full w-full object-cover"
        />
      )}

      {/* Compass rose watermark — only on the no-photo fallback. */}
      {!image && (
        <svg
          viewBox="0 0 120 120"
          aria-hidden="true"
          className="pointer-events-none absolute top-1/2 -translate-y-1/2"
          style={{ right: "2%", width: "min(300px, 62%)", height: "auto", opacity: 0.2, color: "#C6A15B" }}
        >
          <circle cx="60" cy="60" r="56" stroke="currentColor" strokeWidth="1" opacity="0.5" />
          <circle cx="60" cy="60" r="44" stroke="currentColor" strokeWidth="0.6" opacity="0.3" />
          <g stroke="currentColor" strokeWidth="1" opacity="0.55">
            <line x1="60" y1="16" x2="60" y2="24" />
            <line x1="60" y1="96" x2="60" y2="104" />
            <line x1="16" y1="60" x2="24" y2="60" />
            <line x1="96" y1="60" x2="104" y2="60" />
          </g>
          <g
            fill="currentColor"
            fontFamily="var(--font-display)"
            textAnchor="middle"
            dominantBaseline="central"
          >
            <text x="60" y="10" fontStyle="italic" fontSize="10" fontWeight="500">N</text>
            <text x="110" y="60" fontSize="8" opacity="0.5">E</text>
            <text x="60" y="110" fontSize="8" opacity="0.5">S</text>
            <text x="10" y="60" fontSize="8" opacity="0.5">W</text>
          </g>
          <path d="M60 22 L67 60 L60 70 L53 60 Z" fill="currentColor" />
          <path d="M60 98 L53 60 L60 50 L67 60 Z" fill="currentColor" opacity="0.45" />
          <circle cx="60" cy="60" r="3.4" fill="#F7F3EB" />
        </svg>
      )}

      {/* Darkening wash for legibility — only over a real photo. */}
      {image && (
        <div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/70 via-black/50 to-black/40" />
      )}

      <div className="pointer-events-none absolute inset-0 opacity-[0.14] [background-image:radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] [background-size:24px_24px]" />

      <div className="relative mx-auto max-w-5xl px-6 py-12 md:py-16">
        <div className="flex items-center justify-between">
          {"to" in back ? (
            <Link to={back.to} className="inline-flex items-center gap-1.5 text-sm text-white/70 hover:text-white">
              <ArrowLeft className="h-4 w-4" />{backLabel}
            </Link>
          ) : (
            <button
              type="button"
              onClick={back.onClick}
              className="inline-flex items-center gap-1.5 text-sm text-white/70 hover:text-white"
            >
              <ArrowLeft className="h-4 w-4" />{backLabel}
            </button>
          )}
          <Wordmark className="text-white/80" />
        </div>
        {crumbs && crumbs.length > 0 && (
          <nav aria-label="Breadcrumb" className="mt-6 mb-2 text-xs">
            {crumbs.map((seg, i) => (
              <span key={i}>
                {i > 0 && <span className="mx-1.5 text-white/60">›</span>}
                {seg.to ? (
                  <Link
                    to={seg.to}
                    className="text-accent-strong no-underline hover:text-white"
                  >
                    {seg.label}
                  </Link>
                ) : (
                  <span className="text-white/60">{seg.label}</span>
                )}
              </span>
            ))}
          </nav>
        )}
        <h1 className="mt-6 font-display text-4xl font-light tracking-tight text-white md:text-6xl">
          {city}, <span className="italic text-accent-strong">charted.</span>
        </h1>
        {counts && (
          <p className="mt-2 text-sm">
            <b className="font-semibold text-accent-strong">{counts.total}</b>
            <span className="text-white/70"> {plural(counts.total, "charted spot").replace(`${counts.total} `, "")}</span>
            {counts.restaurants > 0 && (
              <>
                <span className="text-white/70"> · </span>
                <b className="font-semibold text-accent-strong">{counts.restaurants}</b>
                <span className="text-white/70"> {plural(counts.restaurants, "restaurant").replace(`${counts.restaurants} `, "")}</span>
              </>
            )}
            {counts.bars > 0 && (
              <>
                <span className="text-white/70"> · </span>
                <b className="font-semibold text-accent-strong">{counts.bars}</b>
                <span className="text-white/70"> {plural(counts.bars, "bar").replace(`${counts.bars} `, "")}</span>
              </>
            )}
          </p>
        )}
        {descriptor && (
          <p className="mt-3 max-w-2xl font-display text-xl leading-relaxed text-white/90 md:text-2xl">
            {descriptor}
          </p>
        )}
        {children}
      </div>
    </section>
  );
}
