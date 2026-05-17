import { useQuery } from "@tanstack/react-query";
import { Link } from "@tanstack/react-router";
import { ArrowLeft } from "lucide-react";
import type { ReactNode } from "react";

type Props = {
  city: string;
  country?: string;
  blurb?: string;
  hueSeed?: string;
  back: { to: "/"; label?: string } | { onClick: () => void; label?: string };
  children?: ReactNode;
};

type WikiSummary = {
  originalimage?: { source?: string };
  thumbnail?: { source?: string };
};

async function fetchWikiImage(name: string): Promise<WikiSummary | null> {
  try {
    const res = await fetch(
      `https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(name)}`,
    );
    if (!res.ok) return null;
    return (await res.json()) as WikiSummary;
  } catch {
    return null;
  }
}

function hueFromString(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) % 360;
  return h;
}

export function CityHero({ city, country, blurb, hueSeed, back, children }: Props) {
  const query = useQuery({
    queryKey: ["city-hero", city, country ?? ""],
    queryFn: () => fetchWikiImage(country ? `${city}, ${country}` : city)
      .then((r) => r ?? fetchWikiImage(city)),
    staleTime: 1000 * 60 * 60 * 24,
  });
  const summary = query.data;
  const image = summary?.originalimage?.source ?? summary?.thumbnail?.source ?? null;
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
          className="pointer-events-none absolute inset-0 h-full w-full object-cover opacity-30 mix-blend-luminosity"
        />
      )}
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-black/50" />
      <div className="absolute inset-0 opacity-20 [background-image:radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] [background-size:24px_24px]" />
      <div className="relative mx-auto max-w-5xl px-6 py-12 md:py-16">
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
        <h1 className="mt-6 text-4xl font-semibold tracking-tight text-white md:text-6xl">
          {city}
        </h1>
        {country && <p className="mt-1 text-lg text-white/70">{country}</p>}
        {descriptor && (
          <p className="mt-4 max-w-2xl text-base text-white/85 md:text-lg">{descriptor}</p>
        )}
        {children}
      </div>
    </section>
  );
}