import { createFileRoute, Link } from "@tanstack/react-router";

import { getAllAwardSources, getVenuesByAward } from "@/lib/venues";
import type { AwardSource } from "@/lib/schema";

const SITE_URL = "https://compasseats.com";

const PAPER = "#F7F3EB";
const INK = "#23211E";
const INK_MUTED = "#6a6253";
const BRONZE = "#895F2E";
const HAIRLINE = "rgba(35,33,30,0.12)";

type GuideRow = {
  slug: string;
  name: string;
  tier: "global" | "regional";
  count: number;
};

function formatNum(n: number): string {
  return n.toLocaleString("en-US");
}

function buildGuides(): {
  global: GuideRow[];
  regional: GuideRow[];
  total: number;
} {
  const rows: GuideRow[] = getAllAwardSources().map((s) => ({
    slug: s.slug,
    name: s.name,
    tier: s.tier as "global" | "regional",
    count: getVenuesByAward(s.slug as AwardSource).length,
  }));
  const byCount = (a: GuideRow, b: GuideRow) => b.count - a.count;
  const global = rows.filter((r) => r.tier === "global").sort(byCount);
  const regional = rows.filter((r) => r.tier === "regional").sort(byCount);
  const total = rows.reduce((s, r) => s + r.count, 0);
  return { global, regional, total };
}

export const Route = createFileRoute("/guides")({
  staticData: { prerender: true },
  loader: () => {
    const { global, regional, total } = buildGuides();
    return {
      global,
      regional,
      total,
      guideCount: global.length + regional.length,
    };
  },
  head: ({ loaderData }) => {
    const guideCount = loaderData?.guideCount ?? 0;
    const title = `Guides — the authorities we chart by | CompassEats`;
    const description = `The ${guideCount} culinary guides and awards CompassEats draws on — from Michelin and the World's 50 Best to regional authorities.`;
    const url = `${SITE_URL}/guides`;
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
        { property: "og:url", content: url },
        { property: "og:type", content: "website" },
        { name: "twitter:card", content: "summary_large_image" },
        { name: "twitter:title", content: title },
        { name: "twitter:description", content: description },
      ],
      links: [{ rel: "canonical", href: url }],
    };
  },
  component: GuidesPage,
});

function GuideList({ rows }: { rows: GuideRow[] }) {
  return (
    <ul role="list" className="border-t" style={{ borderColor: HAIRLINE }}>
      {rows.map((g) => (
        <li
          key={g.slug}
          className="border-b"
          style={{ borderColor: HAIRLINE }}
        >
          <Link
            to="/award/$award"
            params={{ award: g.slug }}
            className="group flex items-baseline justify-between gap-4 py-4"
          >
            <span
              className="font-display text-lg sm:text-xl"
              style={{ color: INK }}
            >
              {g.name}
            </span>
            <span className="flex items-baseline gap-3 shrink-0">
              <span
                className="text-xs sm:text-sm tabular-nums"
                style={{ color: INK_MUTED }}
              >
                {formatNum(g.count)} {g.count === 1 ? "venue" : "venues"}
              </span>
              <span
                aria-hidden
                className="text-sm transition-transform group-hover:translate-x-0.5"
                style={{ color: BRONZE }}
              >
                →
              </span>
            </span>
          </Link>
        </li>
      ))}
    </ul>
  );
}

function GuidesPage() {
  const { global, regional, guideCount } = Route.useLoaderData() as {
    global: GuideRow[];
    regional: GuideRow[];
    total: number;
    guideCount: number;
  };

  return (
    <main className="min-h-screen" style={{ background: PAPER, color: INK }}>
      <div className="mx-auto max-w-4xl px-6 py-16 md:py-24">
        <header className="mb-14 md:mb-20">
          <p
            className="mb-4 text-xs uppercase tracking-[0.2em]"
            style={{ color: BRONZE }}
          >
            The Authorities We Chart By
          </p>
          <h1
            className="font-display text-5xl md:text-6xl font-light tracking-tight"
            style={{ color: INK }}
          >
            Guides
          </h1>
          <p
            className="mt-6 max-w-2xl text-base md:text-lg leading-relaxed"
            style={{ color: INK_MUTED }}
          >
            The {guideCount} culinary guides and awards we draw on — every
            venue on CompassEats is here because one of these put it there.
            No opinions of our own, just the people the world already trusts.
          </p>
        </header>

        <section className="mb-16">
          <h2
            className="font-display text-2xl italic mb-4"
            style={{ color: INK }}
          >
            Global
          </h2>
          <GuideList rows={global} />
        </section>

        <section>
          <h2
            className="font-display text-2xl italic mb-4"
            style={{ color: INK }}
          >
            Regional
          </h2>
          <GuideList rows={regional} />
        </section>
      </div>
    </main>
  );
}