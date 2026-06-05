import { ClientOnly, createFileRoute, Link, notFound } from "@tanstack/react-router";
import { lazy, type ReactNode } from "react";
import { ArrowLeft, ArrowRight, ChevronDown } from "lucide-react";

import { Compass } from "@/components/Compass";
import { VenuePhoto } from "@/components/VenuePhoto";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";

import {
  getVenue,
  getRelatedVenues,
  getAwardSource,
  getAwardPrestige,
} from "@/lib/venues";
import type { Award, Venue } from "@/lib/schema";
import { awardLabel } from "@/lib/award-label";
import {
  buildVenueStructuredData,
  buildBreadcrumbStructuredData,
} from "@/lib/structured-data";
import { CITIES_BY_SLUG } from "@/lib/cities";

const SITE_URL = "https://compasseats.com";
const DEFAULT_OG_IMAGE = `${SITE_URL}/og-image.jpg`;

// ---------------------------------------------------------------------------
// Paper palette — explicit fixed colors so the body stays light regardless
// of the global dark/light theme toggle.
// ---------------------------------------------------------------------------
const PAPER = "#F7F3EB";
const PAPER_CARD = "#FCFAF5";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const BRASS = "#C6A15B";
const HAIRLINE = "rgba(35,33,30,0.12)";

const VenueMap = lazy(() =>
  import("@/components/VenueMap").then((module) => ({ default: module.VenueMap })),
);

// ---------------------------------------------------------------------------
// Route
// ---------------------------------------------------------------------------

export const Route = createFileRoute("/venue/$city/$slug")({
  // Active venue pages are baked at build time — see vite.config.ts prerender.
  staticData: { prerender: true },
  loader: ({ params }) => {
    const venue = getVenue(params.city, params.slug);
    if (!venue || venue.status !== "active") throw notFound();
    return { venue };
  },
  head: ({ loaderData }) => {
    const v = loaderData?.venue;
    if (!v) {
      return { meta: [{ title: "Venue not found · CompassEats" }] };
    }

    const top = pickTopAward(v.awards);
    const topLabel = top
      ? `${prettyAwardSource(top.source)} ${top.category}`
      : v.type === "bar"
      ? "Cocktail bar"
      : "Restaurant";

    const title = `${v.name} — ${topLabel} · ${v.city_display} | CompassEats`;
    const description = buildMetaDescription(v);
    const canonical = `${SITE_URL}/venue/${v.city_slug}/${v.slug}`;
    const cityHero = CITIES_BY_SLUG[v.city_slug]?.imageUrl;
    const image = v.photo_url ?? cityHero ?? DEFAULT_OG_IMAGE;

    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: canonical },
        { property: "og:type", content: "restaurant.restaurant" },
        { property: "og:image", content: image },
        { name: "twitter:card", content: "summary_large_image" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
        { name: "twitter:image", content: image },
      ],
      links: [{ rel: "canonical", href: canonical }],
      scripts: [
        {
          type: "application/ld+json",
          children: JSON.stringify(buildVenueStructuredData(v)),
        },
        {
          type: "application/ld+json",
          children: JSON.stringify(buildBreadcrumbStructuredData(v)),
        },
      ],
    };
  },
  component: VenuePage,
  notFoundComponent: () => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <Compass size={40} />
      <h1 className="mt-4 font-display text-3xl font-light italic text-foreground">
        We haven't charted this one yet.
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">
        Try browsing the city or head back home.
      </p>
      <Link
        to="/"
        className="mt-6 inline-block text-sm text-accent-strong underline"
      >
        Back home
      </Link>
    </div>
  ),
  errorComponent: ({ error }) => (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center">
      <h1 className="text-2xl font-light">Something went wrong</h1>
      <p className="mt-2 text-sm text-muted-foreground">{error.message}</p>
    </div>
  ),
});

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

function VenuePage() {
  const { venue } = Route.useLoaderData() as { venue: Venue };
  const related = getRelatedVenues(venue, 4);

  const typeLabel = venue.type === "bar" ? "Cocktail bar" : "Restaurant";
  const placeLine = `${venue.neighborhood ? venue.neighborhood + ", " : ""}${venue.city_display}`;

  const cuisineLine =
    venue.cuisine_tags.length > 0
      ? venue.cuisine_tags
          .slice(0, 3)
          .map((t) => t.charAt(0).toUpperCase() + t.slice(1))
          .join(", ")
      : "";
  const metaSegments = [venue.price_tier, typeLabel, cuisineLine].filter(
    (s): s is string => Boolean(s),
  );

  const { pullQuote, bodyProse } = buildBlurbParts(venue);
  const groupedAwards = groupAwardsBySourceByPrestige(venue.awards);
  const defaultOpenSource = groupedAwards[0]?.source;

  const distinctSources = Array.from(
    new Set<string>(venue.awards.map((a: Award) => a.source)),
  );

  return (
    <main className="relative min-h-screen bg-background">
      {/* Hero image */}
      <section className="relative h-[360px] w-full overflow-hidden border-b border-border md:h-[400px]">
        <VenuePhoto src={venue.photo_url} alt={venue.name} className="h-full w-full object-cover" />
        {/* Scrim */}
        <div className="pointer-events-none absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-black/10" />

        {/* Back link */}
        <div className="absolute inset-x-0 top-0">
          <div className="mx-auto flex max-w-5xl items-center px-6 pt-5">
            <Link
              to="/city/$slug"
              params={{ slug: venue.city_slug }}
              className="interactive inline-flex items-center gap-1.5 rounded-full border border-white/20 bg-black/30 px-3 py-1.5 text-xs text-white backdrop-blur hover:border-white/50 hover:text-accent-strong"
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              Back to {venue.city_display}
            </Link>
          </div>
        </div>

        {/* Overlay content bottom-left */}
        <div className="absolute inset-x-0 bottom-0">
          <div className="mx-auto max-w-5xl px-6 pb-8 md:pb-10">
            <p className="font-display text-2xl font-light italic text-accent-strong/90 md:text-3xl">
              {placeLine}
            </p>
            <h1 className="mt-1 font-display text-4xl font-light italic tracking-tight text-white md:text-6xl">
              {venue.name}
            </h1>
            {metaSegments.length > 0 && (
              <p className="mt-3 text-sm text-white/75 md:text-base">
                {metaSegments.join(" · ")}
              </p>
            )}
          </div>
        </div>
      </section>

      {/* Paper body — explicit light surface, ignores theme toggle */}
      <div style={{ backgroundColor: PAPER, color: INK }}>
        <div className="mx-auto grid max-w-5xl gap-12 px-6 py-12 md:grid-cols-[1fr_320px]">
          {/* Main column */}
          <div className="min-w-0">
            {/* Editorial blurb */}
            <section>
              <p
                className="text-[10px] font-semibold uppercase tracking-[0.25em]"
                style={{ color: BRONZE }}
              >
                Why we point you here
              </p>
              <blockquote
                className="mt-4 pl-5 font-display text-xl font-light italic leading-snug md:text-2xl"
                style={{ borderLeft: `2px solid ${BRASS}`, color: BRONZE }}
              >
                {pullQuote}
              </blockquote>
              {bodyProse && (
                <div
                  className="mt-6 space-y-4 text-base leading-relaxed"
                  style={{ color: INK }}
                >
                  {bodyProse.split(/\n\n+/).map((p, i) => (
                    <p key={i}>{p}</p>
                  ))}
                </div>
              )}
            </section>

            {/* Accolades */}
            {groupedAwards.length > 0 && (
              <section className="mt-12">
                <h2
                  className="text-[10px] font-semibold uppercase tracking-[0.25em]"
                  style={{ color: BRONZE }}
                >
                  Accolades
                </h2>
                <div className="mt-4 space-y-2.5">
                  {groupedAwards.map((g) => (
                    <AccoladeCard
                      key={g.source}
                      group={g}
                      defaultOpen={g.source === defaultOpenSource}
                    />
                  ))}
                </div>
              </section>
            )}

            {/* Map */}
            <section className="mt-12">
              <h2
                className="mb-4 text-[10px] font-semibold uppercase tracking-[0.25em]"
                style={{ color: BRONZE }}
              >
                On the map
              </h2>
              <ClientOnly fallback={<MapPlaceholder />}>
                <VenueMap venues={[venue]} />
              </ClientOnly>
            </section>

            {/* Related */}
            {related.length > 0 && (
              <section className="mt-16">
                <h2
                  className="font-display text-2xl font-light italic"
                  style={{ color: INK }}
                >
                  Other charted spots in {venue.city_display}
                </h2>
                <p className="mt-1 text-sm" style={{ color: INK_MUTED }}>
                  Worth the detour.
                </p>
                <div className="mt-6 grid gap-3 sm:grid-cols-2">
                  {related.map((r) => (
                    <RelatedVenueCard key={r.id} venue={r} />
                  ))}
                </div>
              </section>
            )}
          </div>

          {/* Facts column */}
          <aside className="md:sticky md:top-24 md:self-start">
            <div
              className="rounded-xl p-5"
              style={{
                backgroundColor: "#FFFFFF",
                border: `1px solid ${HAIRLINE}`,
                boxShadow: "0 1px 2px rgba(35,33,30,0.04), 0 8px 24px rgba(35,33,30,0.06)",
              }}
            >
              {/* Action buttons */}
              {(venue.reservation_url || venue.website) && (
                <div className="space-y-2">
                  {venue.reservation_url && (
                    <a
                      href={venue.reservation_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="interactive inline-flex h-10 w-full items-center justify-center rounded-md text-sm font-medium"
                      style={{ backgroundColor: BRASS, color: INK }}
                    >
                      Reserve a table →
                    </a>
                  )}
                  {venue.website && (
                    <a
                      href={venue.website}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="interactive inline-flex h-10 w-full items-center justify-center rounded-md text-sm font-medium"
                      style={{
                        backgroundColor: venue.reservation_url ? "#FFFFFF" : BRASS,
                        color: INK,
                        border: `1px solid ${venue.reservation_url ? HAIRLINE : BRASS}`,
                      }}
                    >
                      Visit website ↗
                    </a>
                  )}
                </div>
              )}

              {/* Facts list */}
              <dl className="mt-5 divide-y" style={{ borderColor: HAIRLINE }}>
                {venue.hours && (
                  <FactItem label="Hours">
                    <HoursValue hours={venue.hours} />
                  </FactItem>
                )}
                <FactItem label="Address">
                  <p style={{ color: INK }}>{venue.address}</p>
                  <p style={{ color: INK_MUTED }}>
                    {venue.city_display}, {venue.country}
                  </p>
                </FactItem>
                {venue.cuisine_tags.length > 0 && (
                  <FactItem label="Cuisine">
                    <p style={{ color: INK }}>
                      {venue.cuisine_tags
                        .map((t) => t.charAt(0).toUpperCase() + t.slice(1))
                        .join(", ")}
                    </p>
                  </FactItem>
                )}
                {venue.phone && (
                  <FactItem label="Phone">
                    <a
                      href={`tel:${venue.phone}`}
                      className="interactive"
                      style={{ color: INK }}
                    >
                      {venue.phone}
                    </a>
                  </FactItem>
                )}
              </dl>
            </div>
          </aside>
        </div>

        {/* Credits footer (on paper) */}
        <div
          className="mx-auto max-w-5xl px-6 py-8 text-xs"
          style={{ borderTop: `1px solid ${HAIRLINE}`, color: INK_MUTED }}
        >
          <span
            className="font-semibold uppercase tracking-[0.2em]"
            style={{ color: BRONZE }}
          >
            Charted by
          </span>{" "}
          <span className="ml-2">
            {distinctSources.length > 0
              ? distinctSources.map(prettyAwardSource).join(" · ")
              : "CompassEats editors"}
          </span>
          {venue.last_verified && (
            <span className="ml-2">· Last verified {venue.last_verified}</span>
          )}
        </div>
      </div>
    </main>
  );
}

// ---------------------------------------------------------------------------
// Subcomponents
// ---------------------------------------------------------------------------

function FactRow({
  icon,
  label,
  children,
}: {
  icon?: ReactNode;
  label: string;
  children: ReactNode;
}) {
  return (
    <div>
      <div className="flex items-center gap-1.5 text-[10px] font-semibold uppercase tracking-[0.18em] text-muted-foreground">
        {icon}
        <span>{label}</span>
      </div>
      <div className="mt-1.5 text-sm leading-relaxed">{children}</div>
    </div>
  );
}

type DayKey = "mon" | "tue" | "wed" | "thu" | "fri" | "sat" | "sun";
const DAY_LABELS: { key: DayKey; label: string }[] = [
  { key: "mon", label: "Mon" },
  { key: "tue", label: "Tue" },
  { key: "wed", label: "Wed" },
  { key: "thu", label: "Thu" },
  { key: "fri", label: "Fri" },
  { key: "sat", label: "Sat" },
  { key: "sun", label: "Sun" },
];

function HoursBlock({ hours }: { hours: NonNullable<Venue["hours"]> }) {
  if (hours.note) {
    return (
      <FactRow icon={<Clock className="h-4 w-4" />} label="Hours">
        <p className="text-foreground">{hours.note}</p>
      </FactRow>
    );
  }
  return (
    <FactRow icon={<Clock className="h-4 w-4" />} label="Hours">
      <table className="w-full text-sm">
        <tbody>
          {DAY_LABELS.map(({ key, label }) => {
            const ranges = hours[key];
            return (
              <tr key={key} className="border-b border-border/40 last:border-0">
                <td className="py-1 pr-3 text-muted-foreground">{label}</td>
                <td className="py-1 text-right text-foreground">
                  {ranges && ranges.length > 0
                    ? ranges.map((r) => `${r.open}–${r.close}`).join(", ")
                    : <span className="text-muted-foreground">Closed</span>}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </FactRow>
  );
}

function PriceTierPills({ tier }: { tier: "$" | "$$" | "$$$" | "$$$$" }) {
  const active = tier.length;
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4].map((n) => (
        <span
          key={n}
          className={`inline-flex h-6 w-6 items-center justify-center rounded-full border text-xs ${
            n <= active
              ? "border-transparent bg-foreground text-background"
              : "border-border text-muted-foreground"
          }`}
        >
          $
        </span>
      ))}
    </div>
  );
}

function MapPlaceholder() {
  return <div className="h-72 w-full rounded-xl border border-border bg-card md:h-96" />;
}

function RelatedVenueCard({ venue }: { venue: Venue }) {
  const top = pickTopAward(venue.awards);
  return (
    <Link
      to="/venue/$city/$slug"
      params={{ city: venue.city_slug, slug: venue.slug }}
      className="interactive group block"
    >
      <Card className="h-full border-border bg-card transition-colors hover:border-accent-strong/50">
        <CardContent className="flex h-full flex-col gap-2 p-4">
          <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-accent-strong">
            {venue.type === "bar" ? "Cocktail bar" : "Restaurant"}
            {venue.neighborhood ? ` · ${venue.neighborhood}` : ""}
          </p>
          <h3 className="font-display text-lg font-light italic text-foreground group-hover:text-accent-strong">
            {venue.name}
          </h3>
          {top && (
            <p className="text-xs text-muted-foreground">
              {prettyAwardSource(top.source)} · {top.category}
            </p>
          )}
          <span className="mt-auto inline-flex items-center gap-1 text-xs text-accent-strong">
            View <ArrowRight className="h-3 w-3" />
          </span>
        </CardContent>
      </Card>
    </Link>
  );
}


// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

function pickTopAward(awards: Award[]): Award | undefined {
  if (awards.length === 0) return undefined;
  return [...awards].sort((a, b) => {
    const pa = AWARD_PRESTIGE[a.source] ?? 99;
    const pb = AWARD_PRESTIGE[b.source] ?? 99;
    if (pa !== pb) return pa - pb;
    return b.year - a.year;
  })[0];
}

function prettyAwardSource(slug: string): string {
  return getAwardSource(slug)?.name ?? slug;
}

function groupAwardsBySource(awards: Award[]) {
  const map = new Map<string, Award[]>();
  for (const a of awards) {
    if (!map.has(a.source)) map.set(a.source, []);
    map.get(a.source)!.push(a);
  }
  // sort each group by year desc, then sort groups by prestige
  for (const [, entries] of map) entries.sort((a, b) => b.year - a.year);
  return Array.from(map.entries())
    .sort((a, b) => (AWARD_PRESTIGE[a[0]] ?? 99) - (AWARD_PRESTIGE[b[0]] ?? 99))
    .map(([source, entries]) => ({ source, entries }));
}

function distinctionLabel(award: Award): string {
  if (typeof award.rank === "number" && award.rank > 0) {
    return `No. ${award.rank}`;
  }
  return award.category;
}

function groupAwardsBySourceByPrestige(
  awards: Award[],
): { source: string; entries: Award[] }[] {
  const groups = groupAwardsBySource(awards);
  const bestPrestige = (entries: Award[]) =>
    entries.reduce((m, a) => Math.max(m, getAwardPrestige(a)), 0);
  return [...groups].sort(
    (a, b) => bestPrestige(b.entries) - bestPrestige(a.entries),
  );
}

function buildBlurbParts(venue: Venue): {
  pullQuote: string;
  bodyProse: string;
} {
  const shortQ = venue.blurb_short?.trim();
  const longQ = venue.blurb_long?.trim();

  if (shortQ && longQ) {
    return { pullQuote: shortQ, bodyProse: longQ };
  }
  if (shortQ) {
    return { pullQuote: shortQ, bodyProse: "" };
  }
  if (longQ) {
    // Split first sentence as the pull-quote, rest as body prose.
    const match = longQ.match(/^(.+?[.!?])(\s+)(.*)$/s);
    if (match) {
      return { pullQuote: match[1].trim(), bodyProse: match[3].trim() };
    }
    return { pullQuote: longQ, bodyProse: "" };
  }
  const where = venue.neighborhood || venue.city_display;
  return {
    pullQuote: `A charted favorite in ${where}.`,
    bodyProse: "",
  };
}

function buildAutoSummary(awards: Award[]): string {
  if (awards.length === 0) return "A charted destination on CompassEats.";
  const lines = groupAwardsBySource(awards).slice(0, 3).map((g) => {
    const years = g.entries.map((e) => e.year).slice(0, 3).join(", ");
    const cat = g.entries[0].category;
    return `Recognized by ${prettyAwardSource(g.source)} (${cat}, ${years}).`;
  });
  return lines.join(" ");
}

function buildMetaDescription(v: Venue): string {
  const raw = v.blurb_short?.trim() || buildAutoSummary(v.awards);
  return raw.length > 155 ? raw.slice(0, 152).trimEnd() + "…" : raw;
}

function prettyHost(url: string): string {
  try {
    return new URL(url).host.replace(/^www\./, "");
  } catch {
    return url;
  }
}