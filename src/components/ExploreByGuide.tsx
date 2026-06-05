import { Link } from "@tanstack/react-router";
import { AWARD_SOURCES } from "@/lib/schema";

// Flagship guides featured on the homepage. Pull names from AWARD_SOURCES
// so labels never drift from the registry.
const FEATURED_SLUGS = [
  "michelin",
  "worlds-50-best-restaurants",
  "worlds-50-best-bars",
  "james-beard",
  "best-chef-awards",
  "spirited-awards",
  "la-liste",
  "pinnacle-guide",
  "oad",
] as const;

const FEATURED = FEATURED_SLUGS
  .map((slug) => AWARD_SOURCES.find((s) => s.slug === slug))
  .filter((s): s is (typeof AWARD_SOURCES)[number] => Boolean(s));

export function ExploreByGuide() {
  return (
    <section className="mt-16">
      <div className="mb-5">
        <p className="mb-1 text-xs uppercase tracking-wide text-muted-foreground">
          The registry
        </p>
        <h2 className="font-display text-2xl font-light text-foreground">
          Explore by guide
        </h2>
        <p className="mt-1 text-sm text-muted-foreground">
          The guides we chart from.
        </p>
      </div>
      <ul
        role="list"
        className="grid grid-cols-1 border-t border-border md:grid-cols-2 md:border-t-0 lg:grid-cols-3"
      >
        {FEATURED.map((g) => (
          <li key={g.slug} className="border-b border-border md:border-t">
            <Link
              to="/award/$award"
              params={{ award: g.slug }}
              className="interactive group flex items-center justify-between gap-4 px-1 py-3.5 hover:bg-accent/40"
            >
              <span className="font-display text-base text-foreground group-hover:text-accent-strong">
                {g.name}
              </span>
              <span
                aria-hidden
                className="text-sm text-muted-foreground transition-transform group-hover:translate-x-0.5 group-hover:text-accent-strong"
              >
                →
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}