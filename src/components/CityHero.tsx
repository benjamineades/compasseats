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
  back: { to: "/"; label?: string } | { onClick: () => void; label?: string };
  children?: ReactNode;
};

type WikiSummary = {
  type?: string;
  originalimage?: { source?: string };
  thumbnail?: { source?: string };
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

async function resolveCityImage(city: string, country?: string): Promise<WikiSummary | null> {
  const candidates = [
    country ? `${city}, ${country}` : null,
    `${city} City`,
    city,
  ].filter((v): v is string => !!v);
  for (const name of candidates) {
    const hit = await fetchWikiImage(name);
    if (hit) return hit;
  }
  return null;
}

function hueFromString(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) % 360;
  return h;
}

export function CityHero({ city, country, blurb, hueSeed, imageUrl, back, children }: Props) {
  const query = useQuery({
    queryKey: ["city-hero", city, country ?? ""],
    queryFn: () => resolveCityImage(city, country),
    staleTime: 1000 * 60 * 60 * 24,
    enabled: !imageUrl,
  });
  const summary = query.data;
  const image =
    imageUrl ?? summary?.originalimage?.source ?? summary?.thumbnail?.source ?? null;
  const descriptor = blurb;
  const hue = hueFromString(hueSeed ?? city);

  const backLabel = back.label ?? "Back to search";

  return (
    <section
      className="relative overflow-hidden border-b border-border"
      style={{
        background: `linear-gradient(135deg, hsl(${hue} 60% 18%) 0%, hsl(${hue + 40} 50% 12%) 100%)`,
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
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-b from-black/70 via-black/50 to-black/40" />
      <div className="absolute inset-0 opacity-20 [background-image:radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] [background-size:24px_24px]" />
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
        <h1 className="mt-6 font-display text-4xl font-light tracking-tight text-white md:text-6xl">
          {city}, <span className="italic text-accent-strong">charted.</span>
        </h1>
        {descriptor && (
          <p className="mt-3 max-w-2xl font-display text-xl leading-relaxed text-white/90 md:text-2xl">
            {descriptor}
          </p>
        )}
        {country && <p className="mt-3 text-sm font-medium uppercase tracking-wider text-white/60">{country}</p>}
        {children}
      </div>
    </section>
  );
}